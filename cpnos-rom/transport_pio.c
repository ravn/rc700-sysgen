/* cpnos-rom transport backend: PIO-B parallel (Option P).
 *
 * Frame-level CP/NET 1.2 transport over the RC702's Z80-PIO Port B
 * (J3 in real hardware).  Half-duplex with mode-switch:
 *   pio_send_msg -> Mode 0 (output) + OTIR
 *   pio_recv_msg -> Mode 1 (input)  + INIR
 *
 * Speed bench results (session 30, 4 MHz Z80, MAME real-time):
 *   OTIR-driven TX: 156 KiB/s   (21 T/byte instruction-only)
 *   INIR-driven RX: 148 KiB/s   (21 T/byte, chip self-clocked)
 *
 * Wire layout: blast the SCB raw — Mode 0/1 hardware handshake gives
 * per-byte delivery guarantees that subsume the SIO ENQ/ACK/SOH
 * envelope.  No framing bytes; receiver knows to read 5 hdr +
 * (SIZ+1) payload + 1 CKS = SIZ + 7 wire bytes (DRI SIZ-minus-1
 * convention).
 *
 * Frame size cap: total wire bytes must fit in one OTIR/INIR (B
 * register, 8-bit, 0 means 256 iterations).  CP/NET in our codebase
 * is well under this — biggest is READ-SEQ at 171 B (netboot_mpm).
 * The DRI spec ceiling of 262 B is unreachable through any function
 * the slave actually issues; we cap at 256 for code size.
 *
 * Interrupt policy: chip's PIO IE flip-flop is OFF during INIR/OTIR,
 * but the Z80 IFF stays ON.  Block instructions sample INT between
 * iterations so CRT VRTC interrupts (DMA refresh) keep firing
 * mid-burst.  No `di`/`ei` around the bursts — we never blind the
 * system.
 *
 * Direction state: starts in INPUT (init.c leaves PIO-B in Mode 1 +
 * IRQ).  send_msg flips to OUTPUT, blasts, leaves in OUTPUT.  recv_msg
 * flips back to INPUT.  Mode 1 -> Mode 0 transition emits one
 * stale-latch byte (m_output after reset = 0; documented chip
 * artifact, ravn/mame#7) which the peer strips by recognising the
 * SCB header signature.
 *
 * See docs/cpnet_fast_link.md (Option P design) and
 * docs/cpnet_pio_speed_results.md (the bench).
 */
#include <stdbool.h>
#include <stdint.h>
#include "hal.h"
#include "transport.h"

#ifdef __ELF__
#define RESIDENT      __attribute__((section(".resident"), used))
#define RESIDENT_DATA __attribute__((section(".resident.data"), used))
#else
#define RESIDENT
#define RESIDENT_DATA
#endif

/* Z80-PIO control-word constants (Zilog datasheet table 4 + ICW form). */
#define PIO_MODE_OUTPUT       0x0F
#define PIO_MODE_INPUT        0x4F
#define PIO_IE_DISABLE        0x03   /* set IE FF: bit7=0 -> IE off */
#define PIO_IE_ENABLE         0x83   /* set IE FF: bit7=1 -> IE on  */
#define PIO_IE_ENABLE_RESET   0x97   /* ICW: enable + mask follows */
#define PIO_INT_MASK_NONE     0x00

#define PIO_DIR_INPUT   0
#define PIO_DIR_OUTPUT  1
static uint8_t pio_b_dir;            /* zeroed BSS = INPUT initially */

/* SCB header offsets (matches netboot_mpm.c). */
#define FMT 0
#define DID 1
#define SID 2
#define FNC 3
#define SIZ 4

/* PING/PONG SCB shape — used by pio_probe. */
#define PING_FNC  0xC0
#define PING_BYTE 'P'
#define PONG_BYTE 'O'

#ifndef RC702_SLAVEID
#define RC702_SLAVEID 0x01
#endif

/* SPSC ring buffer between isr_pio_par (push) and
 * transport_pio_recv_byte (pop).  Size 64 = 0x40, mask 0x3F.  Indices
 * are kept masked at write time so the load sites are a single byte
 * fetch with no extra arithmetic.  Empty: head == tail.  Full slots
 * lost silently; under flow-controlled CP/NET this can't happen, so
 * the ISR doesn't bother to detect it.  Replaces the old 0xFF=empty
 * sentinel which conflated a real 0xFF data byte from mpm-net2 with
 * "no byte yet" (#56). */
#define PIO_RX_BUF_SIZE 256
#define PIO_RX_BUF_MASK 0xFF
/* head/tail in regular BSS (1 byte each, zeroed by relocator). */
volatile uint8_t pio_rx_head;   /* ISR writes only */
volatile uint8_t pio_rx_tail;   /* mainline writes only */
/* Buf in dedicated .pio_rx_bss section (NOLOAD, page-aligned at
 * 0xEC80 — see payload.ld PIO_RX region).  Page-alignment lets the
 * ISR use ld h,buf>>8 + ld l,head as a single fast 16-bit address.
 * 128-byte size covers the 165-byte READ-SEQ burst with mainline
 * draining during the ISR cascade. */
__attribute__((section(".pio_rx_bss")))
volatile uint8_t pio_rx_buf[PIO_RX_BUF_SIZE];

RESIDENT
static void pio_b_set_output(void) {
    if (pio_b_dir == PIO_DIR_OUTPUT) return;
    _port_out(PORT_PIO_B_CTRL, PIO_IE_DISABLE);
    _port_out(PORT_PIO_B_CTRL, PIO_MODE_OUTPUT);
    pio_b_dir = PIO_DIR_OUTPUT;
}

RESIDENT
static void pio_b_set_input(void) {
    if (pio_b_dir == PIO_DIR_INPUT) return;
    /* Mode 1 select latches direction; ICW 0x97 + mask 0x00
     * atomically clears m_ip (Mode 0 strobes will have set it).
     * Final 0x83 re-asserts IE on, so isr_pio_par fires once per
     * real chip strobe and pushes the latched byte into pio_rx_buf
     * for snios's transport_pio_recv_byte to pop. */
    _port_out(PORT_PIO_B_CTRL, PIO_MODE_INPUT);
    _port_out(PORT_PIO_B_CTRL, PIO_IE_ENABLE_RESET);
    _port_out(PORT_PIO_B_CTRL, PIO_INT_MASK_NONE);
    _port_out(PORT_PIO_B_CTRL, PIO_IE_ENABLE);
    pio_b_dir = PIO_DIR_INPUT;
}

/* The frame-level PIO transport (raw SCBs, used with the host-side
 * cpnet_pio_server.py Python responder) is disabled on this branch.
 * On pio-mpm-netboot the SNIOS envelope rides on PIO byte primitives
 * (see snios.s edit), so this raw-frame path is dead.  #if 0 instead
 * of deleting so the merge target (main) keeps the symbols visible
 * via the rest of the codebase.
 *
 * If you need the raw-frame path back, set this to #if 1 and put
 * the probe block back into cpnos_main.c. */
#if 0
RESIDENT
uint8_t pio_send_msg(uint8_t *msg) {
    pio_b_set_output();
    /* body_len = 5 hdr + (SIZ+1) payload.  uint8_t suffices: SIZ <=
     * 255 means body <= 261 — but we cap frames at 256-wire-byte
     * (one OTIR), so body_len <= 255 here.  Stick to uint8_t for the
     * loop counter so clang DJNZs it. */
    uint8_t body_len = (uint8_t)(6U + msg[SIZ]);
    uint8_t cks = 0;
    for (uint8_t i = 0; i < body_len; ++i) cks += msg[i];
    msg[body_len] = (uint8_t)(0U - cks);
    uint8_t b = (uint8_t)(body_len + 1U);
    __asm__ volatile(
        "ld   c, 0x11\n\t"
        "otir\n\t"
        : "+{hl}"(msg), "+{b}"(b)
        :
        : "a", "c", "memory"
    );
    return 0;
}

/* First-byte sentinel-wait budget.  Per-iteration cost ~36 T-states
 * (IN A,(n) + cp + jr + dec + jr).  16384 polls = ~590,000 T =
 * ~150 ms at 4 MHz emulated.  Generous enough for localhost RTT
 * including Python interpreter wake-up (~10 ms wall + MAME speed-up),
 * still fast-fails the SIO-fallback path in well under a second. */
#define PIO_FIRST_BYTE_BUDGET 0x4000U

/* Receive a complete CP/NET frame.  Reads 5 header bytes (the first
 * via PORT_PIO_B_DATA polling for non-FF, the next 4 via INIR), then
 * INIR's the (SIZ+2) payload+CKS bytes.  Returns 0 success, 0xFF on
 * timeout. */
RESIDENT
uint8_t pio_recv_msg(uint8_t *msg) {
    pio_b_set_input();
    /* First-byte sentinel-wait — empty PIO-B FIFO returns 0xFF in
     * MAME's bridge; spin until a non-FF byte appears (= FMT of the
     * response).  Bounded budget; see PIO_FIRST_BYTE_BUDGET. */
    uint16_t budget = PIO_FIRST_BYTE_BUDGET;
    uint8_t  first;
    while (budget--) {
        first = _port_in(PORT_PIO_B_DATA);
        if (first != PIO_RX_EMPTY_VAL) goto got_first;
    }
    return 0xFF;
got_first:
    msg[0] = first;
    /* INIR header bytes 1..4 (B=4). */
    {
        uint8_t b4 = 4;
        uint8_t *p = &msg[1];
        __asm__ volatile(
            "ld   c, 0x11\n\t"
            "inir\n\t"
            : "+{hl}"(p), "+{b}"(b4)
            :
            : "a", "c", "memory"
        );
    }
    /* INIR (SIZ+1) payload bytes + 1 CKS. */
    {
        uint8_t bn = (uint8_t)((uint16_t)msg[SIZ] + 2U);
        uint8_t *p = &msg[5];
        __asm__ volatile(
            "ld   c, 0x11\n\t"
            "inir\n\t"
            : "+{hl}"(p), "+{b}"(bn)
            :
            : "a", "c", "memory"
        );
    }
    /* No CKS validation here.  PIO Mode 0/1 hardware handshake gives
     * per-byte delivery; sum-to-zero would only catch a host-side
     * protocol bug, not a wire error.  Probe (pio_probe) does a
     * full validate for confidence; runtime CP/NET trusts the wire. */
    return 0;
}

/* Probe: send PING SCB, recv PONG SCB.  Validates round-trip:
 *   PING:  FMT=0x00 DID=0x00 SID=us FNC=PING_FNC SIZ=0 [P] CKS
 *   PONG:  FMT=0x01 DID=us  SID=0x00 FNC=PING_FNC SIZ=0 [O] CKS
 * Returns true on valid PONG.
 *
 * PING bytes built inline (no .rodata) so they don't depend on
 * link placement — at this point in boot the relocator has just
 * copied the payload and clear_screen hasn't run yet, but
 * literal-byte construction is robust either way.
 *
 * CKS is sum-to-zero (two's complement of the body sum). */
RESIDENT
bool pio_probe(void) {
    uint8_t msg[7];
    msg[FMT] = 0x00;
    msg[DID] = 0x00;
    msg[SID] = RC702_SLAVEID;
    msg[FNC] = PING_FNC;
    msg[SIZ] = 0x00;
    msg[5]   = PING_BYTE;
    {
        uint8_t s = 0;
        for (uint8_t i = 0; i < 6U; ++i) s += msg[i];
        msg[6] = (uint8_t)(0U - s);
    }

    if (pio_send_msg(msg) != 0) return false;
    if (pio_recv_msg(msg) != 0) return false;

    /* Validate response: sum-to-zero + mirrored header. */
    uint8_t s = 0;
    for (uint8_t i = 0; i < 7U; ++i) s += msg[i];
    return (s == 0U)
        && msg[FMT] == 0x01
        && msg[DID] == RC702_SLAVEID
        && msg[SID] == 0x00
        && msg[FNC] == PING_FNC
        && msg[SIZ] == 0x00
        && msg[5]   == PONG_BYTE;
}

RESIDENT_DATA
cpnet_transport_t transport_pio_vt = {
    .probe    = pio_probe,
    .send_msg = pio_send_msg,
    .recv_msg = pio_recv_msg,
    .name     = "PIO",
};
#endif

/* ---- Byte-level PIO transport ---------------------------------
 * snios.s (PIO-only experiment) calls these for every envelope byte.
 *
 * Stale-prefix mitigation on Mode 1->Mode 0 transitions: MAME's
 * z80pio.cpp::set_mode(MODE_OUTPUT) immediately fires
 * out_pb_callback with the chip's current m_output latch.  After a
 * direction flip there's a stale value from the previous send sitting
 * in m_output; if we just `_port_out(CTRL, MODE_OUTPUT)` and then
 * `_port_out(DATA, c)`, the peer sees stale_byte + c.  When the peer
 * is mpm-net2's SERVER.RSP, that stale byte breaks the protocol
 * (received between ACK and SOH, mpm-net2 doesn't tolerate it).
 * Workaround: write the data byte to the data port BEFORE the mode
 * switch.  That updates m_output while still in input mode (the
 * chip latches it without emitting), then the mode switch fires the
 * callback with the byte we actually want to send.  No stale prefix.
 * (See ravn/mame#7 for the underlying chip-emulation behaviour.) */
RESIDENT
void transport_pio_send_byte(uint8_t c) {
    if (pio_b_dir == PIO_DIR_OUTPUT) {
        _port_out(PORT_PIO_B_DATA, c);
        return;
    }
    _port_out(PORT_PIO_B_CTRL, PIO_IE_DISABLE);
    _port_out(PORT_PIO_B_DATA, c);              /* preload m_output */
    _port_out(PORT_PIO_B_CTRL, PIO_MODE_OUTPUT); /* fires callback with c */
    pio_b_dir = PIO_DIR_OUTPUT;
}

RESIDENT
uint16_t transport_pio_recv_byte(uint16_t timeout_ticks) {
    pio_b_set_input();
    while (timeout_ticks--) {
        uint8_t t = pio_rx_tail;
        if (pio_rx_head != t) {
            uint8_t b = pio_rx_buf[t];
            pio_rx_tail = (uint8_t)(t + 1);   /* wraps at 256 */
            return b;
        }
    }
    return TRANSPORT_TIMEOUT;
}

/* Speed-test BSS variables (referenced by isr.c).  Kept for the
 * speed-test build only. */
uint16_t pio_rx_count;
uint8_t  pio_test_done;
