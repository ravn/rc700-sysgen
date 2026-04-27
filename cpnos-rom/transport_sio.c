/* cpnos-rom transport backend: SIO-A async 38400 (polled).
 *
 * Implements transport.h's byte-level + frame-level API over the
 * RC702's SIO-A channel.  Frame-level (send_msg/recv_msg) wraps the
 * existing SNIOS SOH/STX/ETX/EOT envelope (see snios.s).  Byte-level
 * (transport_send_byte/recv_byte) is the lowest layer SNIOS
 * internally drives the envelope through.
 *
 * Lands in the resident section because netboot calls it after PROM
 * disable.
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

/* Frame-level send/recv.  The SIO wire format wraps each SCB in
 * ENQ/ACK/SOH+CKS/EOT (see snios.s) — so the C-callable entry points
 * are the existing snios_sndmsg_c / snios_rcvmsg_c.  Both take HL=msg
 * (sdcccall(1)) and return A=0 success / 0xFF error. */
extern uint8_t snios_sndmsg_c(uint8_t *msg);
extern uint8_t snios_rcvmsg_c(uint8_t *msg);

/* Probe for SIO is a no-op: there is always a SIO peer at boot
 * time (or we wouldn't have netbooted via SIO in the first place
 * before this driver landed).  If probe() ever needs to be more
 * thoughtful, it would emit a PING SCB and wait for a PONG; left as
 * unconditional success because the meaningful reachability test
 * happens at netboot LOGIN time anyway. */
RESIDENT
static bool sio_probe(void) {
    return true;
}

RESIDENT_DATA
cpnet_transport_t transport_sio_vt = {
    .probe    = sio_probe,
    .send_msg = snios_sndmsg_c,
    .recv_msg = snios_rcvmsg_c,
};
