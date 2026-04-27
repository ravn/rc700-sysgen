/* cpnos-rom transport backend: PIO-B parallel (Option P).
 *
 * Implements a transport-byte API over the RC702's Z80-PIO Port B
 * (J3 in real hardware).  Half-duplex with mode-switch state machine:
 *   transport_pio_send_byte -> Mode 0 (output)
 *   transport_pio_recv_byte -> Mode 1 (input, IRQ-driven)
 * Lazy switching — direction flips only when caller flips, costing
 * one OUT-triplet per direction change (~5 us at 4 MHz).
 *
 * Receive is interrupt-driven: isr_pio_par (isr.c) reads each byte
 * from PORT_PIO_B_DATA on PIO-B IRQ and pushes it into pio_rx_ring.
 * transport_pio_recv_byte busy-polls the ring head/tail with a
 * caller-supplied tick budget; matches the transport.h shape used
 * by transport_sio.c.
 *
 * Symbols are transport_pio_* (distinct from transport_*) so this
 * file can coexist with transport_sio.c during bring-up.  Once SNIOS
 * is plumbed onto PIO, a build flag will pick which implementation
 * exports the canonical transport_send_byte / transport_recv_byte.
 *
 * See docs/cpnet_fast_link.md for the wire-level Option P design.
 */
#include <stdint.h>
#include "hal.h"
#include "transport.h"

/* Section attribute is ELF-only.  macOS clang (Mach-O) drives the
 * IDE's LSP and rejects the section name without a comma; the actual
 * build uses ELF clang.  Same pattern as resident.c. */
#ifdef __ELF__
#define RESIDENT __attribute__((section(".resident"), used))
#else
#define RESIDENT
#endif

/* Z80-PIO control-word encoding (Zilog datasheet, table 4):
 *   bit 0 = 0  -> the byte is loaded as the interrupt vector
 *   bit 0 = 1  -> it's a control word, type by low nibble:
 *     0x_F (bits 0..3 = 1111) -> mode select, bits 7..6 = mode
 *     0x_7 (bits 0..3 = 0111) -> ICW; bit 7 enable, bit 4 mask-follows
 *     0x_3 (bits 0..3 = 0011) -> set IE flip-flop, bit 7 = enable
 *
 * Only ICW (0x_7) with bit 4 set causes a mask byte to follow.  Our
 * 0x83 (set IE flip-flop, enable=1) takes no follow-up byte — emitting
 * a 0x00 after it would be parsed as "load vector = 0x00", silently
 * overwriting the 0x22 set by init.c so IRQs would dispatch through
 * IVT slot 0 (isr_noop) instead of slot 17 (isr_pio_par).  init.c does
 * use 0x83 alone for the same reason — see init.c:81-83.
 *
 * IRQ is disabled during Mode 0 so peripheral STB pulses (BSTB
 * acking output) cannot fire isr_pio_par with a stale/wrong-direction
 * byte. */
#define PIO_MODE_OUTPUT  0x0F   /* mode 0 select: 8-bit output */
#define PIO_MODE_INPUT   0x4F   /* mode 1 select: 8-bit input */
#define PIO_IE_DISABLE   0x03   /* set IE flip-flop, bit 7 = 0 */
/* ICW form (0x_7) with bit 7=1 (enable), bit 4=1 (mask follows).
 * The mask-follows path is the only one that atomically clears m_ip
 * (z80pio.cpp:632-635) — required when re-entering Mode 1 after Mode 0
 * because every Mode 0 STB pulse from the peripheral sets m_ip.  Plain
 * 0x83 (set IE flip-flop) leaves m_ip set and an immediate spurious
 * IRQ fires on EI, putting one stale byte into the RX ring before the
 * real data ever arrives. */
#define PIO_IE_ENABLE_RESET  0x97   /* ICW: enable + mask follows */
#define PIO_INT_MASK_NONE    0x00   /* mask byte: no PB bits masked */

/* Receive ring buffer.  Power-of-two size for cheap masking; 32 is
 * the upper bound that keeps .scratch_bss inside its 480-byte budget
 * (between SCRATCH origin 0xEA20 and IVT at 0xEC00).  CP/NET protocol
 * drains promptly between sends so the ring never holds a full frame
 * at once — a 5-byte SCB header + a few payload bytes is the typical
 * in-flight depth before the C side advances `tail`. */
#define PIO_RX_RING_SIZE  32
#define PIO_RX_RING_MASK  (PIO_RX_RING_SIZE - 1)
_Static_assert((PIO_RX_RING_SIZE & PIO_RX_RING_MASK) == 0,
               "ring size must be power of 2");

/* Globals — referenced from isr.c's isr_pio_par (push side) and from
 * transport_pio_recv_byte (pop side).  Uninitialised, land in BSS. */
uint8_t pio_rx_ring[PIO_RX_RING_SIZE];
uint8_t pio_rx_head;   /* ISR writes here */
uint8_t pio_rx_tail;   /* recv reads here */

/* uint16_t byte counter incremented by isr_pio_par per byte.  Wraps
 * after 65536 bytes; on wrap the ISR sets pio_test_done = 1.  Used
 * by the speed-rx benchmark to time 64 KiB-equivalent ISR throughput
 * without depending on the ring (which back-to-back ISRs starve at
 * high rates). */
uint16_t pio_rx_count;
uint8_t pio_test_done;

/* Direction state machine.  init.c leaves PIO-B in Mode 1 + IRQ
 * enabled, so initialise to PIO_DIR_INPUT — the first send forces
 * the output transition. */
#define PIO_DIR_INPUT   0
#define PIO_DIR_OUTPUT  1
static uint8_t pio_b_dir = PIO_DIR_INPUT;

RESIDENT
static void pio_b_set_output(void) {
    if (pio_b_dir == PIO_DIR_OUTPUT) return;
    _port_out(PORT_PIO_B_CTRL, PIO_IE_DISABLE);
    _port_out(PORT_PIO_B_CTRL, PIO_MODE_OUTPUT);
    pio_b_dir = PIO_DIR_OUTPUT;
}

RESIDENT
static void pio_b_set_input(void) {
    if (pio_b_dir == PIO_DIR_INPUT) return;
    _port_out(PORT_PIO_B_CTRL, PIO_MODE_INPUT);
    _port_out(PORT_PIO_B_CTRL, PIO_IE_ENABLE_RESET);
    _port_out(PORT_PIO_B_CTRL, PIO_INT_MASK_NONE);
    pio_b_dir = PIO_DIR_INPUT;
}

RESIDENT
void transport_pio_send_byte(uint8_t c) {
    pio_b_set_output();
    _port_out(PORT_PIO_B_DATA, c);
    /* Mode 0 output handshake is chip-managed: Z80 write -> chip
     * raises BRDY -> peripheral pulses BSTB -> chip clears BRDY for
     * one cycle and re-asserts on next CPU write.  In MAME the bridge
     * acks atomically (same emu instant); on real HW the host's
     * software loop must ack within the inter-OUT interval to keep
     * up with Z80 output speed.
     *
     * Wire-protocol note (chip artifact): Z80-PIO emits the current
     * output-latch value as a single byte on Mode 1->0 transition
     * (z80pio.cpp:set_mode line ~390 — "enable data output" callback
     * with m_output).  After power-on m_output = 0, so the very first
     * byte the host sees on direction switch is 0x00 even before any
     * CPU write to the data port.  After the first real OUT the latch
     * holds that data, so subsequent direction flips emit whatever was
     * last sent.  CP/NET-frame consumers will recognise frame starts
     * by SCB header signature (FMT bit pattern); this leading byte is
     * pre-frame noise and is discarded on the host side. */
}

RESIDENT
uint16_t transport_pio_recv_byte(uint16_t timeout_ticks) {
    pio_b_set_input();
    while (timeout_ticks--) {
        if (pio_rx_head != pio_rx_tail) {
            uint8_t b = pio_rx_ring[pio_rx_tail];
            pio_rx_tail = (pio_rx_tail + 1) & PIO_RX_RING_MASK;
            return b;
        }
    }
    return TRANSPORT_TIMEOUT;
}
