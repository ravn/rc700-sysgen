/* cpnos-rom resident chunk (Phase 1 seed)
 *
 * Code here lands in .resident: VMA at 0xF580, LMA packed into PROM0
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

RESIDENT
void resident_entry(void) {
    /* We are at VMA 0xF580 (RAM), PROMs still mapped at 0x0000/0x2000.
     * First act: disable PROMs.  Safe here because we execute from RAM. */
    disable_proms();

    /* Breadcrumb marker in plain RAM (outside display area).  If this
     * byte lands at 0xE200 we know resident_entry executed. */
    *(volatile uint8_t *)0xE200 = 0xA5;

    /* Display writes (may or may not stick depending on CRT state). */
    DISPLAY[0] = 'C';
    DISPLAY[1] = 'P';
    DISPLAY[2] = 'N';
    DISPLAY[3] = 'O';
    DISPLAY[4] = 'S';

    /* Second breadcrumb after display writes, before serial. */
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
