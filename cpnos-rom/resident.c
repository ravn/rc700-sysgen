/* cpnos-rom resident chunk (Phase 1 seed)
 *
 * Code here lands in .resident: VMA at 0xF200, LMA packed into PROM0
 * after init code.  The cold-boot path memcpys LMA->VMA, then jumps.
 *
 * Phase 1 grows this to contain: BIOS jump table, console I/O, SNIOS
 * message layer, disk stubs, CFGTBL/DPH.
 */

#include <stdint.h>
#include "hal.h"

/* Gate the section attribute on ELF output.  The Z80 cross-compiler
 * produces ELF — the attribute applies and RESIDENT code lands in
 * .resident at VMA 0xF200.  macOS system clang drives the editor's
 * LSP and produces Mach-O, which rejects a plain ELF section name;
 * leave the attribute off there so the IDE stops warning.  Code
 * sections are only consulted at link time, which always uses the
 * Z80 toolchain. */
#ifdef __ELF__
#define RESIDENT __attribute__((section(".resident"), used))
#else
#define RESIDENT
#endif

static volatile uint8_t * const DISPLAY = (volatile uint8_t *)0xF800;

RESIDENT
static void disable_proms(void) {
    _port_out(PORT_RAMEN, 0x00);
}

/* Busy-wait SIO-B transmit.  No hardware init yet — this is skeleton
 * code verifying that clang lowers to the expected IN/OUT sequence.
 * Next turn adds CTC+SIO init so this actually transmits. */
RESIDENT
static void console_putc(uint8_t c) {
    while ((_port_in(PORT_SIO_B_CTRL) & SIO_RR0_TX_BUF_EMPTY) == 0) { }
    _port_out(PORT_SIO_B_DATA, c);
}

/* Resident tail-call trampoline: `JP (HL)` from snios.s, survives
 * PROM disable unlike clang's PROM-resident __call_iy helper. */
extern void jump_to(uint16_t addr) __attribute__((noreturn));

/* Interrupt enable helper from isr.s — deferred until after netboot
 * and SNIOS-JT copy so CRT refresh ISR doesn't race SIO polling. */
extern void enable_interrupts(void);

/* SNIOS NTWKIN is still called from the cold path as a sanity touch of
 * CFGTBL before NDOS takes over.  SNDMSG/RCVMSG smoke calls are gone —
 * NDOS drives the wire now. */
extern uint8_t snios_ntwkin(void);

/* SNIOS jump table from snios.s (8 x 3-byte `JP <impl>` = 24 bytes).
 * DRI NDOS.SPR is linked expecting SNIOS's JT at NDOS_BASE + code_len
 * (= 0xEA00 with NDOS at 0xDE00).  We copy our JT there at cold-boot
 * so NDOS's CALL NTWKIN/CNFTBL/SNDMSG/RCVMSG/etc. reach our SNIOS
 * implementation.  The JT entries use absolute targets, so the copy
 * works from either location. */
extern uint8_t snios_jt[24];
#define NDOS_SNIOS_ADDR  0xEA00  /* NDOS_BASE(0xDE00) + NDOS code_len(0xC00) */

RESIDENT
[[noreturn]] void resident_entry(uint16_t entry) {
    /* We are at VMA 0xED00 (RAM), PROMs still mapped at 0x0000/0x2000.
     * First act: disable the PROMs so 0x0000..0x07FF and 0x2000..0x27FF
     * are RAM.  Safe because we execute from 0xED00+. */
    disable_proms();

    /* CP/M 2.2 zero page:
     *   0x0000..0x0002  JP _bios_wboot   (c3 03 f2)
     *   0x0003          IOBYTE (default 0 = all TTY)
     *   0x0004          current drive/user (default 0 = A:, user 0)
     *   0x0005..0x0007  JP NDOS+6        (c3 06 de)
     *
     * Session #28's null-trap (JP 0x0000) was a diagnostic that
     * worked, but NDOS's COLDST reads TOP+1 and uses it as the BIOS
     * base for its TLBIOS-walk that patches intercepts into BIOS JT.
     * With TOP+1=0x0000 the walk scribbled wrapper addresses across
     * page 0 and clobbered our BDOS vector at 0x0005.  Real JP
     * _bios_wboot makes TOP+1=0xF203; NDOS walks the BIOS JT at
     * 0xF200+ where the intercepts belong.
     *
     * The 0xC3 opcode at 0x0000 also doubles as the PROM-disable
     * proof (would read back 0xF3 if PROM were still mapped). */
    *(volatile uint8_t *)0x0000 = 0xC3;     /* JP opcode */
    *(volatile uint8_t *)0x0001 = 0x03;     /* lo(_bios_wboot) */
    *(volatile uint8_t *)0x0002 = 0xED;     /* hi(_bios_wboot) = BIOS 0xED03
                                             * (BIOS_BASE moved from 0xF200
                                             * to 0xED00 session 33 follow-
                                             * up — see cpnos_rom.ld). */
    *(volatile uint8_t *)0x0003 = 0x00;     /* IOBYTE */
    *(volatile uint8_t *)0x0004 = 0x00;     /* current drive/user */
    *(volatile uint8_t *)0x0005 = 0xC3;     /* JP opcode */
    *(volatile uint8_t *)0x0006 = 0x06;     /* lo(NDOS_BASE + 6) */
    *(volatile uint8_t *)0x0007 = 0xDE;     /* hi(NDOS_BASE + 6) — NDOS at 0xDE00 */

    /* Prime SNIOS: drain SIO RX, seed NETST=ACTIVE, clear SIZ.  NDOS's
     * own NTWKIN may re-run this; that's fine (idempotent). */
    snios_ntwkin();

    /* Copy our SNIOS jump table to the address where DRI NDOS.SPR
     * expects SNIOS to live (NDOS + code_len).  Session #28 root
     * cause of the null-loop: without this, NDOS's CALL NTWKIN goes
     * to zero bytes and eventually dereferences BDOSE while BDOSE
     * is still uninitialised. */
    for (uint8_t i = 0; i < 24; ++i) {
        ((volatile uint8_t *)NDOS_SNIOS_ADDR)[i] = snios_jt[i];
    }

    /* Enable interrupts now that polled netboot is done and SNIOS is
     * wired up.  CRT refresh ISR (IVT slot 2 = CTC ch2) starts firing
     * and the display wakes up. */
    enable_interrupts();

    /* Hand off to cpnos.com's entry at 0xCC00 (first byte of the loaded
     * image = cpnos.asm's `JP BIOS` vector).  BIOS's boot routine sets
     * up the zero page (WBOOT vector -> NDOSRL+0x303, BDOS vector ->
     * BDOS), copies its 17-entry BIOS JT to NDOSRL+0x300, then jumps
     * to NDOS+3 (COLDST).  Our resident zero-page setup gets
     * overwritten — that's expected and correct for CP/NOS.
     *
     * Fallback: if no netboot (entry==0), fall through to the
     * diagnostic banner — useful when running without a server. */
    if (entry != 0) {
        jump_to(0xD000);
    }

    /* Fallback diagnostic banner (reached only when entry==0). */
    *(volatile uint8_t *)0xEC00 = 0xA5;
    DISPLAY[0] = 'C';
    DISPLAY[1] = 'P';
    DISPLAY[2] = 'N';
    DISPLAY[3] = 'O';
    DISPLAY[4] = 'S';
    *(volatile uint8_t *)0xEC01 = 0x5A;

    console_putc('C');
    console_putc('P');
    console_putc('N');
    console_putc('O');
    console_putc('S');
    console_putc('\r');
    console_putc('\n');

    for (;;) { }
}

/* -------------------------------------------------------------------
 * BIOS jump-table implementations.
 *
 * Targets of the `jp nn` entries in bios_jt.s.  Names follow the
 * pattern `impl_<entry>` so the linker resolves the asm references.
 * Phase 1 skeleton: CONOUT is real (SIO-B), CONST/CONIN are SIO-B
 * polled, disk entries are stubs because NDOS bypasses BIOS for
 * network drives.  Full NDOS hook-up comes with CFGTBL in a later
 * increment.
 * ------------------------------------------------------------------- */

RESIDENT
void bios_stub_ret(void) { }

RESIDENT
[[noreturn]] void impl_boot(void) {
    /* CP/M cold-boot entry.  cpnos_main tail-called resident_entry
     * directly once already, so the normal boot flow doesn't come
     * through here.  If CP/NOS itself ever jumps here (e.g. during
     * its post-handoff init before it has patched the zero page
     * to point at NDOSRL's BIOS JT), re-run the cpnos stub rather
     * than dropping into a fallback trap.  Was Issue U. */
    jump_to(0xD000);
}

RESIDENT
[[noreturn]] void impl_wboot(void) {
    /* CP/M warm boot.  In CP/NOS the whole OS image is in RAM and
     * re-runnable from its BOOT label at 0xD000, so re-entering the
     * cpnos stub is an acceptable warm-boot.  Was Issue U. */
    jump_to(0xD000);
}

/* PIO-A keyboard ring buffer.  Populated by isr_pio_kbd (isr.s) on each
 * PIO-A interrupt — one keystroke per IRQ.  Drained by impl_conin.
 * Size must be a power of two (mask = SIZE-1).  SIO-B RX is checked
 * first so automated tests driving the serial line see predictable
 * byte ordering; the PIO path only matters when a human types at the
 * physical keyboard, and the ring smooths over the ISR<->poll race. */
#define KBD_RING_SIZE 16
uint8_t kbd_ring[KBD_RING_SIZE];
uint8_t kbd_head;   /* written by ISR */
uint8_t kbd_tail;   /* written by CONIN */

/* Breadcrumbs in scratch RAM for diagnosing issue #38 (netboot boot flaky,
 * CONOUT sometimes never called).  Keep in place until the boot path is
 * reliably green — see mame_boot_test.lua dump of 0xEC00+96.
 *   0xEC40  impl_conout call count
 *   0xEC41  last byte passed to impl_conout
 *   0xEC42  impl_const call count
 *   0xEC43  impl_conin call count
 */
#define TRACE_CONOUT_CNT   ((volatile uint8_t *)0xEC40)
#define TRACE_CONOUT_LAST  ((volatile uint8_t *)0xEC41)
#define TRACE_CONST_CNT    ((volatile uint8_t *)0xEC42)
#define TRACE_CONIN_CNT    ((volatile uint8_t *)0xEC43)

RESIDENT
uint8_t impl_const(void) {
    (*TRACE_CONST_CNT)++;
    if (_port_in(PORT_SIO_B_CTRL) & SIO_RR0_RX_CHAR_AVAIL) return 0xFF;
    if (kbd_head != kbd_tail) return 0xFF;
    return 0x00;
}

/* Cursor position.  Lives in .scratch_bss (default-zero at BSS init),
 * updated by impl_conout and mirrored to the 8275 after each write. */
static uint8_t curx;
static uint8_t cury;

RESIDENT
static void crt_set_cursor(uint8_t x, uint8_t y) {
    _port_out(PORT_CRT_CMD,   0x80);   /* load cursor position */
    _port_out(PORT_CRT_PARAM, x);
    _port_out(PORT_CRT_PARAM, y);
}

RESIDENT
static void crt_scroll_up(void) {
    /* Move rows 1..24 down to 0..23, clear row 24.  Each row is 80B.
     * Straightforward copy — no LDIR intrinsic in this C file, rely
     * on the compiler to unroll or let runtime.s helpers do it. */
    volatile uint8_t *d = (volatile uint8_t *)DISPLAY_ADDR;
    for (uint16_t i = 0; i < 24U * 80U; ++i) {
        d[i] = d[i + 80];
    }
    for (uint8_t i = 0; i < 80; ++i) {
        d[24U * 80U + i] = ' ';
    }
}

RESIDENT
uint8_t impl_conin(void) {
    (*TRACE_CONIN_CNT)++;
    for (;;) {
        if (_port_in(PORT_SIO_B_CTRL) & SIO_RR0_RX_CHAR_AVAIL) {
            return _port_in(PORT_SIO_B_DATA);
        }
        if (kbd_head != kbd_tail) {
            uint8_t c = kbd_ring[kbd_tail];
            kbd_tail = (kbd_tail + 1) & (KBD_RING_SIZE - 1);
            return c;
        }
    }
}

RESIDENT
void impl_conout(uint8_t c) {
    /* Minimal CP/M CONOUT: printable chars go to the current cursor
     * position on the 8275 display; CR resets column; LF advances
     * row and scrolls when the bottom row overflows.  Serial mirror
     * goes to SIO-B so the null-modem log still captures output. */
    (*TRACE_CONOUT_CNT)++;
    *TRACE_CONOUT_LAST = c;
    console_putc(c);

    volatile uint8_t *d = (volatile uint8_t *)DISPLAY_ADDR;

    if (c == 0x0C) {
        /* Ctrl-L / form feed: clear display, home cursor. */
        for (uint16_t i = 0; i < DISPLAY_SIZE; ++i) {
            d[i] = ' ';
        }
        curx = 0;
        cury = 0;
    } else if (c == '\r') {
        curx = 0;
    } else if (c == '\n') {
        /* Treat LF as CR+LF so host-side text with '\n'-only line
         * breaks renders correctly and the banner fits under 256 B. */
        curx = 0;
        if (cury + 1 >= 25) {
            crt_scroll_up();
        } else {
            cury++;
        }
    } else if (c >= 0x20) {
        d[(uint16_t)cury * 80U + curx] = c;
        if (++curx >= 80) {
            curx = 0;
            if (cury + 1 >= 25) {
                crt_scroll_up();
            } else {
                cury++;
            }
        }
    }
    /* Other control chars (0x08 BS, 0x09 TAB, 0x07 BEL...) ignored
     * for now — add as CCP output demands them. */

    crt_set_cursor(curx, cury);
}

RESIDENT
uint16_t impl_seldsk_null(void) {
    /* No DPH — CP/M treats HL=0 as "drive not present". NDOS intercepts
     * SELDSK for network drives before this stub is reached. */
    return 0;
}

RESIDENT
uint8_t impl_disk_err(void) {
    /* READ/WRITE error. Not expected to be called in NOS-only mode. */
    return 1;
}
