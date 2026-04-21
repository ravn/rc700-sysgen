/* cpnos-rom transport abstraction
 *
 * SNIOS and netboot talk to the wire through a tiny polled byte-stream
 * interface.  Phase 1 has exactly one implementation (SIO-A async 38400);
 * the vtable prep lets a future parallel-port backend drop in at
 * build time without touching the protocol layers.
 *
 * Polled, blocking — no interrupts required for Phase 1 netboot.
 * Phase 2+ may grow an interrupt-driven RX ring buffer.
 */
#ifndef CPNOS_TRANSPORT_H
#define CPNOS_TRANSPORT_H

#include <stdint.h>

/* recv_byte timeout sentinel.  Protocol layers treat -1/0xFFFF as timeout. */
#define TRANSPORT_TIMEOUT 0xFFFF

/* Blocking byte send (waits for TX empty, then OUTs). */
void transport_send_byte(uint8_t c);

/* Blocking byte recv with coarse timeout.  timeout_ticks is a polling
 * count, not wall-clock — ~10k ticks ≈ tens of ms at 4MHz.  Returns the
 * byte (0-255) in low byte, or TRANSPORT_TIMEOUT (0xFFFF) on timeout. */
uint16_t transport_recv_byte(uint16_t timeout_ticks);

#endif
