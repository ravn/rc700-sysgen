/* cpnos-rom transport abstraction
 *
 * Two byte-level transports (SIO async 38400, PIO Mode 0/1 parallel)
 * plus a frame-level vtable so SNIOS/netboot can switch between them
 * at runtime without source changes.
 *
 * Selection at boot: cpnos_main probes PIO first (sends a CP/NET
 * PING SCB through PIO-B; on PONG within ~100 ms the PIO transport
 * wins).  Falls back to SIO if no peer responds.
 *
 * Vtable shape: send_msg / recv_msg take a complete CP/NET 1.2 SCB
 * (FMT/DID/SID/FNC/SIZ + payload + CKS, DRI SIZ-minus-1 convention).
 * The transport adds whatever wire envelope it needs (SIO does
 * ENQ/ACK/SOH/CKS/EOT; PIO blasts the SCB raw because Mode 0/1
 * hardware handshake handles per-byte reliability).
 *
 * The byte-level transport_send_byte/transport_recv_byte API stays
 * for SNIOS internals (the SOH envelope is per-byte) — those names
 * remain bound to the SIO backend.
 */
#ifndef CPNOS_TRANSPORT_H
#define CPNOS_TRANSPORT_H

#include <stdbool.h>
#include <stdint.h>

/* recv_byte timeout sentinel.  Protocol layers treat -1/0xFFFF as timeout. */
#define TRANSPORT_TIMEOUT 0xFFFF

/* SIO byte-level (used by SNIOS for the wire envelope). */
void transport_send_byte(uint8_t c);
uint16_t transport_recv_byte(uint16_t timeout_ticks);

/* Frame-level vtable.  Each backend implements one instance. */
typedef struct cpnet_transport {
    /* probe(): try to elicit a PONG response from the host.  Returns
     * true on a valid PONG, false on timeout/bad-frame.  May take up
     * to ~100 ms emulated. */
    bool    (*probe)(void);
    /* send_msg(msg): hand a fully-formed SCB (msg[0..]=FMT..CKS) to
     * the wire.  Caller has computed the CKS.  Returns 0 success,
     * 0xFF error. */
    uint8_t (*send_msg)(uint8_t *msg);
    /* recv_msg(msg): read header (5 B), parse SIZ, read payload+CKS
     * into the same buffer.  Returns 0 success, 0xFF error. */
    uint8_t (*recv_msg)(uint8_t *msg);
} cpnet_transport_t;

extern cpnet_transport_t transport_sio_vt;
extern cpnet_transport_t transport_pio_vt;
extern cpnet_transport_t *active_transport;

/* Active-transport dispatch — the single seam SNIOS jt and netboot
 * route through. */
uint8_t cpnet_send_msg(uint8_t *msg);
uint8_t cpnet_recv_msg(uint8_t *msg);
bool    cpnet_probe(void);

#endif
