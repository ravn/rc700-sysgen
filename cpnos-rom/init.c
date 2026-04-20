/* cpnos-rom init code (runs in place from PROM0, never copied to RAM).
 *
 * Phase 1: minimum to get SIO-B transmit working at 38400 baud so the
 * resident console_putc produces visible output in MAME.  Receive path
 * and SIO-A (network transport) are added next.
 *
 * CTC clock path: memclock/32 = 614400 Hz feeds CTC.  Channel 1 with
 * time constant = 1 outputs 614400 Hz pulses, SIO-B in x16 mode
 * divides to 38400 baud.  (Same values as rcbios-in-c/boot_confi.c.)
 */

#include <stdint.h>
#include "hal.h"

/* SIO-B init sequence — writes to WR registers in the order the SIO
 * accepts them.  Values taken from the CP/M BIOS default CONFI block. */
static const uint8_t siob_init[] = {
    0x18,           /* WR0: channel reset */
    0x02, 0x10,     /* WR2: interrupt vector base 0x10 */
    0x04, 0x44,     /* WR4: x16 clock, 1 stop bit, no parity */
    0x03, 0xE1,     /* WR3: 8-bit Rx, auto enables, Rx enable */
    0x05, 0x68,     /* WR5: 8-bit Tx, Tx enable, RTS (DTR/RTS on) */
    0x01, 0x00      /* WR1: no interrupts yet (Phase 1 is polled Tx) */
};

void init_hardware(void) {
    /* CTC channel 1: supply SIO-B baud clock.
     * Mode byte 0x47 = counter, no interrupt, time const follows, reset.
     * Time constant 0x01 = divide by 1 -> 614400 Hz out -> 38400 baud x16. */
    _port_out(PORT_CTC1, 0x47);
    _port_out(PORT_CTC1, 0x01);

    /* Program SIO-B. */
    for (uint8_t i = 0; i < sizeof(siob_init); ++i) {
        _port_out(PORT_SIO_B_CTRL, siob_init[i]);
    }

    /* Drain any pending SIO-B status latches. */
    (void)_port_in(PORT_SIO_B_CTRL);
}
