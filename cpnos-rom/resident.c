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

#define RESIDENT __attribute__((section(".resident"), used))

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

/* SNIOS NTWKIN is still called from the cold path as a sanity touch of
 * CFGTBL before NDOS takes over.  SNDMSG/RCVMSG smoke calls are gone —
 * NDOS drives the wire now. */
extern uint8_t snios_ntwkin(void);

RESIDENT
[[noreturn]] void resident_entry(uint16_t entry) {
    /* We are at VMA 0xF200 (RAM), PROMs still mapped at 0x0000/0x2000.
     * First act: disable the PROMs so 0x0000..0x07FF and 0x2000..0x27FF
     * are RAM.  Safe because we execute from 0xF200+. */
    disable_proms();

    /* PROM-disable proof sentinels (checked by MAME probe). */
    *(volatile uint8_t *)0x0000 = 0xA5;
    *(volatile uint8_t *)0x0001 = 0x5A;

    /* BDOS vector at 0x0005: `JP <NDOS_BASE+6>`.  NDOS's COLDST reads
     * BDOS+1 (the 16-bit operand of this JP) and caches it as BDOSE for
     * internal use — see ndos.asm:196.  The +6 offset lands on NDOS's
     * second `JMP NDOSE` block (ndos.asm:86-88), matching CP/M's
     * "BDOS entry = module_base + 6" convention that leaves a 6-byte
     * preamble for the self-JPs and version/ID bytes. */
    *(volatile uint8_t *)0x0005 = 0xC3;     /* JP opcode */
    *(volatile uint8_t *)0x0006 = 0x06;     /* lo(NDOS_BASE + 6) */
    *(volatile uint8_t *)0x0007 = 0xDE;     /* hi(NDOS_BASE + 6) — NDOS at 0xDE00 */

    /* Prime SNIOS: drain SIO RX, seed NETST=ACTIVE, clear SIZ.  NDOS's
     * own NTWKIN may re-run this; that's fine (idempotent). */
    snios_ntwkin();

    /* Hand off to CCP ccpstart (or whatever netboot delivered via
     * FNC=4).  CCP's prologue does `LXI SP,stack` so it resets SP;
     * we don't need to preserve our stack.  Never returns.
     *
     * Fallback: if entry is zero (no netboot), fall through to the
     * diagnostic banner — useful when running without a server. */
    if (entry != 0) {
        jump_to(entry);
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
    /* Cold-start entry once CCP+BDOS are loaded; not used by our own
     * init path (cpnos_main tail-calls resident_entry directly). If
     * something ever calls through the jump table at cold boot, land
     * in the banner path so it's obvious we got here. */
    resident_entry(0);
}

RESIDENT
[[noreturn]] void impl_wboot(void) {
    /* Warm boot in NOS mode re-requests CCP from the server. Not
     * wired yet — fall into BOOT for now. */
    resident_entry(0);
}

RESIDENT
uint8_t impl_const(void) {
    return (_port_in(PORT_SIO_B_CTRL) & SIO_RR0_RX_CHAR_AVAIL) ? 0xFF : 0x00;
}

RESIDENT
uint8_t impl_conin(void) {
    while ((_port_in(PORT_SIO_B_CTRL) & SIO_RR0_RX_CHAR_AVAIL) == 0) { }
    return _port_in(PORT_SIO_B_DATA);
}

RESIDENT
void impl_conout(uint8_t c) {
    console_putc(c);
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
