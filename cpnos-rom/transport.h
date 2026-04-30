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

/* The transport is fixed at build time:
 *   default          : SNIOS envelope on top of byte transport (sio /
 *                      pio-irq via linker --defsym aliases on
 *                      _xport_send_byte / _xport_recv_byte).
 *   TRANSPORT_PROXY  : raw OTIR/INIR frames; pairs with
 *                      cpnet_pio_server.py --upstream on the host.
 *
 * cpnet_send_msg / cpnet_recv_msg are #define aliases of the actual
 * implementation functions, so callers just emit a direct call (3 B
 * tail-call) instead of the vtable indirection that used to live in
 * cpnet_dispatch.c (deleted 2026-04-30).  Saved ~38 B in the payload
 * (16 B vtable structs + 2 B active_transport pointer + ~20 B of
 * dispatch wrappers + the BC<->HL conversions that snios.s no longer
 * needs to bounce through). */
#ifdef TRANSPORT_PROXY
extern uint8_t pio_send_msg(uint8_t *msg);
extern uint8_t pio_recv_msg(uint8_t *msg);
#define cpnet_send_msg pio_send_msg
#define cpnet_recv_msg pio_recv_msg
#else
extern uint8_t snios_sndmsg_c(uint8_t *msg);
extern uint8_t snios_rcvmsg_c(uint8_t *msg);
#define cpnet_send_msg snios_sndmsg_c
#define cpnet_recv_msg snios_rcvmsg_c
#endif

#endif
