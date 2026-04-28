/* cpnos-rom interrupt helpers + IM2 ISRs.
 *
 * Z80 IM2 interrupt handling for display refresh + keyboard + PIO-B.
 * IVT lives at 0xEC00 (set up by init.c).  Each entry is a 16-bit
 * pointer to one of the ISR symbols below.
 *
 * Register preservation: every ISR swaps to the Z80 shadow register
 * set via `ex af,af'` + `exx`, so the body's use of A/BC/DE/HL is
 * safe.  Compiled C is built with +shadow-regs, which means the main
 * register set is the one live at interrupt time; the shadow set is
 * therefore free for the ISR.  IX/IY are not swapped but the ISRs
 * never touch them.
 *
 * Encoding wart: clang's integrated assembler (like GNU-as on Z80)
 * rejects the apostrophe in `ex af, af'`, so the swap is encoded as
 * `.byte 0x08`.  The same trick is in the prior isr.s.
 *
 * All ISRs live in `.resident.isr` so they survive the OUT (0x18)
 * PROM disable.  The init helpers below (set_i_reg / enable_im2 /
 * enable_interrupts / disable_interrupts) are also resident so they
 * can be called from resident contexts (warm boot path) without a
 * PROM-vs-RAM dance.
 *
 * Phase 3 step 2 (2026-04-26): replaced isr.s.  Co-location with
 * resident.c's BSS vars (kbd_ring, pio_par_*, curx/cury, cur_dirty)
 * is the win — the ISRs and the BSS they touch live in the same
 * compilation unit family now.  Same instructions, same encoding.
 */

#include <stdint.h>

/* Gate the ELF-only section attribute the same way resident.c does
 * (only the Z80 ELF compile path takes it; macOS system clang driving
 * the IDE LSP would reject it on Mach-O). */
#ifdef __ELF__
#define ISR_SECTION  __attribute__((section(".resident.isr"), used))
#else
#define ISR_SECTION
#endif

/* Init-time helpers ------------------------------------------------ */

ISR_SECTION
__attribute__((naked))
void set_i_reg(__attribute__((unused)) uint8_t page) {
    /* page lands in A under sdcccall(1); body uses A directly. */
    __asm__ volatile(
        "ld   i, a\n\t"
        "ret\n\t"
    );
}

ISR_SECTION
__attribute__((naked))
void enable_im2(void) {
    __asm__ volatile(
        "im   2\n\t"
        "ret\n\t"
    );
}

ISR_SECTION
__attribute__((naked))
void enable_interrupts(void) {
    __asm__ volatile(
        "ei\n\t"
        "ret\n\t"
    );
}

ISR_SECTION
__attribute__((naked))
void disable_interrupts(void) {
    __asm__ volatile(
        "di\n\t"
        "ret\n\t"
    );
}

/* ISRs ------------------------------------------------------------- */

/* No-op ISR for unused IM2 slots.  Must use RETI so the daisy-chained
 * interrupt-priority hardware (CTC, PIO) can advance past this device. */
ISR_SECTION
__attribute__((naked))
void isr_noop(void) {
    __asm__ volatile(
        "ei\n\t"
        "reti\n\t"
    );
}

/* CRT refresh ISR.  On each VRTC interrupt:
 *   - ack CRT status read
 *   - mask DMA display+attr channels, clear byte-pointer FF
 *   - (re)load display base address + word count
 *   - (re)load attribute word count = 0 (no attributes used)
 *   - unmask DMA channels
 *   - re-arm CTC ch2 for next frame
 *   - bump tick counter at 0xEC30 (MAME probe verifies we fired)
 *   - if cur_dirty: push 8275 cursor regs, clear flag (defers per-char
 *     8275 writes from impl_conout to once-per-frame here, eliminating
 *     visible flicker on netboot banner / CCP DIR / etc.)
 *
 * Mainline writes cur_dirty *after* curx/cury, so reading them here
 * races benignly: we may see a slightly-stale position one frame later,
 * but never a torn pair (single-byte stores are atomic on Z80). */
ISR_SECTION
__attribute__((naked))
void isr_crt(void) {
    __asm__ volatile(
        ".byte 0x08\n\t"           /* ex af,af' */
        "exx\n\t"

        /* Breadcrumb tick at 0xEC30 (was 0xEC20 pre-IVT-relocation). */
        "ld   hl, 0xEC30\n\t"
        "inc  (hl)\n\t"

        /* Ack CRT status register. */
        "in   a, (0x01)\n\t"        /* PORT_CRT_CMD */

        /* Mask DMA channels 2 + 3. */
        "ld   a, 0x06\n\t"
        "out  (0xFA), a\n\t"
        "ld   a, 0x07\n\t"
        "out  (0xFA), a\n\t"

        /* Clear DMA byte-pointer flip-flop. */
        "xor  a\n\t"
        "out  (0xFC), a\n\t"

        /* Display source addr = 0xF800. */
        "ld   a, 0x00\n\t"
        "out  (0xF4), a\n\t"
        "ld   a, 0xF8\n\t"
        "out  (0xF4), a\n\t"

        /* Display word count = DISPLAY_SIZE-1 = 0x07CF. */
        "ld   a, 0xCF\n\t"
        "out  (0xF5), a\n\t"
        "ld   a, 0x07\n\t"
        "out  (0xF5), a\n\t"

        /* Attribute word count = 0. */
        "xor  a\n\t"
        "out  (0xF7), a\n\t"
        "out  (0xF7), a\n\t"

        /* Unmask channels 2 + 3. */
        "ld   a, 0x02\n\t"
        "out  (0xFA), a\n\t"
        "ld   a, 0x03\n\t"
        "out  (0xFA), a\n\t"

        /* Re-arm CTC ch2 for the next VRTC. */
        "ld   a, 0xD7\n\t"
        "out  (0x0E), a\n\t"
        "ld   a, 0x01\n\t"
        "out  (0x0E), a\n\t"

        /* Deferred 8275 cursor update. */
        "ld   a, (_cur_dirty)\n\t"
        "or   a\n\t"
        "jr   z, 1f\n\t"
        "xor  a\n\t"
        "ld   (_cur_dirty), a\n\t"
        "ld   a, 0x80\n\t"          /* 8275 "load cursor position" */
        "out  (0x01), a\n\t"
        "ld   a, (_curx)\n\t"
        "out  (0x00), a\n\t"
        "ld   a, (_cury)\n\t"
        "out  (0x00), a\n\t"
    "1:\n\t"

        "exx\n\t"
        ".byte 0x08\n\t"           /* ex af,af' */
        "ei\n\t"
        "reti\n\t"
    );
}

/* PIO-A keyboard ISR.  Fires on each PIO-A interrupt (one per keystroke
 * with PIO-A in input mode + IRQ enabled).  Reads the byte and enqueues
 * to kbd_ring; drops on full ring.  Ring buffer symbols (kbd_ring /
 * kbd_head / kbd_tail) live in resident.c. */
ISR_SECTION
__attribute__((naked))
void isr_pio_kbd(void) {
    __asm__ volatile(
        ".byte 0x08\n\t"           /* ex af,af' */
        "exx\n\t"

        "in   a, (0x10)\n\t"        /* PORT_PIO_A_DATA -> A */
        "ld   e, a\n\t"             /* stash key */

        /* new_head = (head + 1) & 0x0F */
        "ld   hl, _kbd_head\n\t"
        "ld   a, (hl)\n\t"
        "inc  a\n\t"
        "and  0x0F\n\t"
        "ld   d, a\n\t"             /* D = new_head */

        /* if (new_head == tail) drop */
        "ld   hl, _kbd_tail\n\t"
        "ld   a, (hl)\n\t"
        "cp   d\n\t"
        "jr   z, 1f\n\t"

        /* ring[head] = key;  head = new_head */
        "ld   hl, _kbd_head\n\t"
        "ld   a, (hl)\n\t"
        "ld   h, 0\n\t"
        "ld   l, a\n\t"
        "ld   bc, _kbd_ring\n\t"
        "add  hl, bc\n\t"
        "ld   (hl), e\n\t"
        "ld   a, d\n\t"
        "ld   (_kbd_head), a\n\t"
    "1:\n\t"

        "exx\n\t"
        ".byte 0x08\n\t"           /* ex af,af' */
        "ei\n\t"
        "reti\n\t"
    );
}

/* PIO-B parallel ISR.  Fires once per chip strobe (= once per byte
 * delivered by the bridge) when chip IE is on.  Reads the latched
 * byte from PORT_PIO_B_DATA (the IN itself clears chip IP), pushes
 * into the snios receive ring (pio_rx_buf, head/tail in
 * transport_pio.c).  Mirrors the isr_pio_kbd pattern.
 *
 * Legacy harness counters (pio_par_byte, pio_par_count, pio_rx_count,
 * pio_test_done) are no longer touched here — they were for the
 * host-send / speed-rx test modes which don't use the IRQ-driven
 * recv ring.  --gc-sections drops the unused BSS allocations.
 *
 * Shadow registers (after exx + ex af,af') so we don't perturb mainline
 * code's register state. */
ISR_SECTION
__attribute__((naked))
void isr_pio_par(void) {
    __asm__ volatile(
        ".byte 0x08\n\t"           /* ex af,af' */
        "exx\n\t"

        "in   a, (0x11)\n\t"        /* PORT_PIO_B_DATA -> A; clears chip IP */
        "ld   e, a\n\t"             /* stash byte */

        /* SPSC ring push for snios.  256-byte buffer at page-aligned
         * address (0xF700 per payload.ld), so HL = page<<8 | head is
         * a single 16-bit address.  uint8_t wrap is free — no mask. */
        /* new_head = (uint8_t)(head + 1) — wraps at 256. */
        "ld   hl, _pio_rx_head\n\t"
        "ld   a, (hl)\n\t"
        "inc  a\n\t"
        "ld   d, a\n\t"             /* D = new_head */

        /* if (new_head == tail) drop — ring full, byte lost. */
        "ld   hl, _pio_rx_tail\n\t"
        "ld   a, (hl)\n\t"
        "cp   d\n\t"
        "jr   z, 2f\n\t"

        /* ring[head] = byte; head = new_head.  Page-aligned 256-byte
         * buf — H = buf>>8 (0xf7) is a constant; L = head. */
        "ld   a, (_pio_rx_head)\n\t"
        "ld   l, a\n\t"
        "ld   h, _pio_rx_buf_page\n\t"
        "ld   (hl), e\n\t"
        "ld   a, d\n\t"
        "ld   (_pio_rx_head), a\n\t"
    "2:\n\t"

        "exx\n\t"
        ".byte 0x08\n\t"           /* ex af,af' */
        "ei\n\t"
        "reti\n\t"
    );
}
