/* cpnos-rom init code (runs in place from PROM0, never copied to RAM).
 *
 * Phase 1: bring up CTC+SIO-A (netboot transport) and CTC+SIO-B
 * (console).  Both at 38400 baud x16.  Receive path added for SIO-A
 * only — SIO-B is TX only until we need the console for input.
 *
 * CTC clock path: memclock/32 = 614400 Hz feeds CTC.  Time constant 1
 * at mode 0x47 outputs 614400 Hz, SIO x16 -> 38400 baud.  Values match
 * rcbios-in-c/boot_confi.c.
 */

#include <stdint.h>
#include "hal.h"

static const uint8_t sio_a_init[] = {
    0x18,           /* WR0: channel reset */
    0x04, 0x44,     /* WR4: x16 clock, 1 stop, no parity */
    0x03, 0xE1,     /* WR3: 8-bit Rx, auto enables, Rx enable */
    0x05, 0x6A,     /* WR5: 8-bit Tx, Tx enable, RTS asserted (needed
                     *      for MAME null_modem FLOW_CONTROL=0x01 to TX) */
    0x01, 0x00      /* WR1: no interrupts (polled) */
};

static const uint8_t sio_b_init[] = {
    0x18,           /* WR0: channel reset */
    0x02, 0x10,     /* WR2: interrupt vector base 0x10 */
    0x04, 0x44,     /* WR4: x16 clock, 1 stop, no parity */
    0x03, 0xE1,     /* WR3: 8-bit Rx, auto enables, Rx enable */
    0x05, 0x6A,     /* WR5: 8-bit Tx, Tx enable, RTS asserted (needed
                     *      for MAME null_modem FLOW_CONTROL=0x01 to TX) */
    0x01, 0x00      /* WR1: no interrupts (polled) */
};

void init_hardware(void) {
    /* CTC ch0 -> SIO-A baud clock, ch1 -> SIO-B baud clock.
     * Mode 0x47 = counter, no int, time const follows.  Count 1 = ÷1. */
    _port_out(PORT_CTC0, 0x47);
    _port_out(PORT_CTC0, 0x01);
    _port_out(PORT_CTC1, 0x47);
    _port_out(PORT_CTC1, 0x01);

    for (uint8_t i = 0; i < sizeof(sio_a_init); ++i) {
        _port_out(PORT_SIO_A_CTRL, sio_a_init[i]);
    }
    for (uint8_t i = 0; i < sizeof(sio_b_init); ++i) {
        _port_out(PORT_SIO_B_CTRL, sio_b_init[i]);
    }

    (void)_port_in(PORT_SIO_A_CTRL);
    (void)_port_in(PORT_SIO_B_CTRL);
}
