/* cpnos-rom CP/NET transport dispatcher.
 *
 * Single seam between callers (netboot, SNIOS jt) and the two
 * transport backends (SIO/PIO).  active_transport is set at boot by
 * cpnos_main's probe step before netboot or any NDOS traffic.
 *
 * Default at link time is SIO so that even before probe runs, the
 * vtable is non-null — guards against accidental dispatch through
 * NULL if init order changes.
 */

#include <stdbool.h>
#include <stdint.h>
#include "transport.h"

#ifdef __ELF__
#define RESIDENT      __attribute__((section(".resident"), used))
#define RESIDENT_DATA __attribute__((section(".resident.data"), used))
#else
#define RESIDENT
#define RESIDENT_DATA
#endif

/* Lives in .resident.data so it has a known initialiser at load time
 * and writeable storage at runtime (the .resident section is RAM
 * after the relocator copies it).
 *
 * TRANSPORT_PROXY (Makefile -D, set by TRANSPORT=pio-proxy) selects
 * raw OTIR/INIR frames via transport_pio_vt; pairs with
 * cpnet_pio_server.py --upstream on the host.  Default is the SIO-
 * shaped vtable, which carries the SNIOS ENQ/ACK/SOH envelope on
 * whatever byte transport the linker's _xport_send_byte alias picks
 * (sio: SIO-A; pio-irq: PIO-B IRQ ring). */
RESIDENT_DATA
#ifdef TRANSPORT_PROXY
cpnet_transport_t *active_transport = &transport_pio_vt;
#else
cpnet_transport_t *active_transport = &transport_sio_vt;
#endif

RESIDENT
uint8_t cpnet_send_msg(uint8_t *msg) {
    return active_transport->send_msg(msg);
}

RESIDENT
uint8_t cpnet_recv_msg(uint8_t *msg) {
    return active_transport->recv_msg(msg);
}

RESIDENT
bool cpnet_probe(void) {
    return active_transport->probe();
}
