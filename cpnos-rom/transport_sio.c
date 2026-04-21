/* cpnos-rom transport backend: SIO-A async 38400 (polled).
 *
 * Implements transport.h over the RC702's SIO-A channel.  Identical
 * busy-wait pattern as console_putc for SIO-B.  Lands in the resident
 * section because netboot calls it after PROM disable (actually during
 * boot too, but ROM+resident both work before OUT (0x18)).
 */
#include <stdint.h>
#include "hal.h"
#include "transport.h"

#define RESIDENT __attribute__((section(".resident"), used))

RESIDENT
void transport_send_byte(uint8_t c) {
    while ((_port_in(PORT_SIO_A_CTRL) & SIO_RR0_TX_BUF_EMPTY) == 0) { }
    _port_out(PORT_SIO_A_DATA, c);
}

RESIDENT
uint16_t transport_recv_byte(uint16_t timeout_ticks) {
    while (timeout_ticks--) {
        if (_port_in(PORT_SIO_A_CTRL) & SIO_RR0_RX_CHAR_AVAIL) {
            return _port_in(PORT_SIO_A_DATA);
        }
    }
    return TRANSPORT_TIMEOUT;
}
