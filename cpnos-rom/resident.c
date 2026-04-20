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

typedef void (*fn_t)(void);

/* SNIOS entries.  `snios_sndmsg_c` is the C-ABI wrapper (HL arg)
 * around the DRI SNDMSG (BC arg) — see snios.s for the wrapper. */
extern uint8_t snios_ntwkin(void);
extern uint8_t snios_sndmsg_c(void *msgbuf);

/* Pointer to the outbound message area inside CFGTBL.  Layout is
 * fixed by cfgtbl.c (FMT at +39..MSGBUF at +45 of the CP/NET CFGTBL
 * struct); declared here as an extern byte to avoid dragging the
 * struct definition into this file. */
extern uint8_t cfgtbl[];
#define MSGTX (&cfgtbl[39])

RESIDENT
[[noreturn]] void resident_entry(uint16_t entry) {
    /* We are at VMA 0xF200 (RAM), PROMs still mapped at 0x0000/0x2000.
     * First act: disable the PROMs.  Safe here because we execute from
     * RAM — the next instruction fetch is at 0xF58x+ which is not
     * shadowed by either PROM. */
    disable_proms();

    /* PROM-disable proof: write two distinct sentinels to 0x0000/0x0001.
     * If PROM is still mapped, writes are dropped and reads return the
     * reset-vector bytes (0xF3 0x31 ...).  The MAME boot test reads
     * these addresses back and fails on mismatch.  We don't gate the
     * banner on this — the test harness is the oracle. */
    *(volatile uint8_t *)0x0000 = 0xA5;
    *(volatile uint8_t *)0x0001 = 0x5A;

    /* Exercise SNIOS NTWKIN: drains the SIO RX buffer, seeds NETST with
     * ACTIVE, clears the SIZ field.  After the call the test harness
     * checks CFGTBL.netst == 0x10.  No wire traffic — this is a glue
     * test for SNIOS → transport → CFGTBL. */
    snios_ntwkin();

    /* Send one LIST-device message via the DRI framing — exercises
     * the full SNDMSG path (ENQ/ACK/SOH/HCS/STX/ETX/CKS/EOT/ACK).
     * CFGTBL seeds FMT=0, DID=0, FNC=5, SIZ=0, DAT=[0]; SNDMSG fills
     * in SID from CFGTBL+1.  Result code in A (0=OK, 0xFF=error)
     * parked in a BSS byte so the MAME probe can inspect it. */
    *(volatile uint8_t *)0xE210 = snios_sndmsg_c(MSGTX);

    /* If netboot delivered an entry point, hand off to it.  From here
     * on, the ROM is gone; we can't go back. */
    if (entry != 0) {
        ((fn_t)(uintptr_t)entry)();
        /* If the loaded code returns (e.g. warm-boot stub), fall
         * through to the diagnostic banner below. */
    }

    /* Fallback diagnostic banner (no server, or loaded code returned). */
    *(volatile uint8_t *)0xE200 = 0xA5;
    DISPLAY[0] = 'C';
    DISPLAY[1] = 'P';
    DISPLAY[2] = 'N';
    DISPLAY[3] = 'O';
    DISPLAY[4] = 'S';
    *(volatile uint8_t *)0xE201 = 0x5A;

    /* Serial proof-of-life (no-op until SIO init lands next turn). */
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
