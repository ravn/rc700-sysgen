# CP/NET Parallel Port Transport (Future)

> **SUPERSEDED 2026-04-25.** The Mode 2 plan below is **abandoned**.
> Current design is **Option P** in
> [`docs/cpnet_fast_link.md`](../docs/cpnet_fast_link.md): PIO-B
> half-duplex via J3, keyboard untouched on PIO-A / J4, no PCB
> modifications, no level-shifter chip.
>
> Mode 2 was ruled out because (a) ARDY is not routed to any external
> connector — verified MIC07 schematic, session 16 — making Mode 2
> impossible without case-opening; and (b) the 2026-04-25 keyboard
> constraint locks PIO-A to the RC722 keyboard in production.
> `SPLIT_CHANNEL_TRANSPORT.md` (referenced below) is also superseded
> by the same Option P design — see its own banner.
>
> The text below is preserved for archaeological reference only.

## Overview

Use the RC702's Z80-PIO Port A in Mode 2 (bidirectional) for CP/NET transfers,
replacing the serial port transport with a much faster parallel link.

## Z80-PIO Mode Constraints

The Z80-PIO has four operating modes:

| Mode | Name | Port A | Port B | Description |
|------|------|--------|--------|-------------|
| 0 | Output | Yes | Yes | 8-bit output with handshake |
| 1 | Input | Yes | Yes | 8-bit input with handshake |
| 2 | Bidirectional | **Yes** | **No** | Uses all 4 handshake lines |
| 3 | Bit Control | Yes | Yes | Individual bit I/O |

**Only Port A supports Mode 2 (bidirectional).** When Port A is in Mode 2,
it monopolizes all four handshake signals (ASTB, ARDY, BSTB, BRDY), leaving
Port B without handshaking.

## Current RC702 PIO Assignment

| Port | Address | Current Use | Mode |
|------|---------|-------------|------|
| Port A | 0x10 | Keyboard input | Mode 1 (input) |
| Port B | 0x11 | General output | Mode 0 (output) |

## Proposed Reconfiguration

| Port | Address | New Use | Mode |
|------|---------|---------|------|
| Port A | 0x10 | CP/NET parallel transfers | Mode 2 (bidirectional) |
| Port B | 0x11 | Keyboard input | Mode 1 (input) |

### Implications

- Keyboard moves from Port A to Port B (requires hardware rewiring or adapter)
- Port B in Mode 1 has no handshaking available (BSTB/BRDY stolen by Port A Mode 2)
  - Keyboard must use interrupt-driven polling or Mode 3 bit-level handshake
  - The RC702 keyboard is a smart peripheral sending ready ASCII codes, so
    interrupt-on-data-ready should still work via Port B's interrupt mechanism
    (Port B can still generate interrupts in Mode 1 without handshake lines)
- Port A gains full bidirectional 8-bit transfer with hardware handshaking

### Handshake Signals in Mode 2

```
Port A Mode 2 (bidirectional):
  ASTB  ← peripheral: "I've put data on the bus" (input strobe)
  ARDY  → peripheral: "I'm ready for more output data" (output ready)
  BSTB  ← peripheral: "Take the output data now" (output strobe, repurposed)
  BRDY  → peripheral: "I have input data ready" (input ready, repurposed)
```

## Transfer Speed Estimates

### Hardware Limits (4 MHz Z80)

| Method | Cycles/byte | Throughput | Notes |
|--------|-------------|------------|-------|
| DMA transfer | 8 T | 500 KB/s | Theoretical maximum |
| Programmed I/O (tight loop) | 12 T | 333 KB/s | IN/OUT + loop control |
| Programmed I/O (realistic) | 16 T | 250 KB/s | With buffer management |
| With CP/NET framing | ~20-30 T | 130-200 KB/s | Header, checksum, ACK |

### Comparison with Serial Transport

| Transport | Speed | Relative |
|-----------|-------|----------|
| Serial (38400 baud) | 3.8 KB/s | 1x |
| Parallel (programmed I/O) | ~150 KB/s | ~40x |
| Parallel (DMA) | ~400 KB/s | ~100x |

## Server Side

The server needs a parallel port capable of bidirectional transfers:
- PC with IEEE 1284 EPP/ECP parallel port (bidirectional)
- USB-to-parallel adapter (if it supports bidirectional mode)
- Custom interface (FPGA, microcontroller with parallel I/O)
- Raspberry Pi GPIO (directly bit-banged, 3.3V level shifting needed)

### Cable

Custom cable required. RC702 PIO connector pinout needs to be mapped to
the server's parallel port. Active signals:
- 8 data lines (D0-D7)
- ASTB, ARDY (Port A handshake)
- BSTB, BRDY (repurposed for Port A Mode 2)
- Ground

## Implementation Plan

### Phase 1: BIOS Changes
- Move keyboard ISR from Port A to Port B
- Reconfigure Port B as Mode 1 input with interrupts
- Verify keyboard still works in MAME

### Phase 2: NIOS Driver
- Write parallel NIOS (Network I/O System) for CP/NET
- Implement Mode 2 bidirectional transfer routines
- DRI protocol framing over parallel link
- Interrupt-driven or polled receive

### Phase 3: Server Software
- Parallel port driver on host (Linux/macOS)
- CP/NET server speaking DRI protocol over parallel
- Adapt existing server.py or CpnetSerialServer

### Phase 4: Hardware
- Build adapter cable (RC702 PIO ↔ server parallel port)
- Level shifting if needed (Z80 is 5V TTL, modern PCs are 3.3V)
- Test with real RC702 hardware

### Phase 5: DMA Integration (Optional)
- Use the Am9517A DMA controller for PIO↔memory transfers
- **DMA Channel 0 is available** (assigned to WD1000 HD controller, not present
  on the target machine). Channel 1 (FDC) and Channel 2 (CRT) stay as-is.
- PIO ARDY signal is active-high, compatible with DMA DREQ input polarity
- Requires wiring PIO ARDY to DMA CH0 DREQ (no existing board trace)
- CRT DMA (Channel 2) uses burst transfers into the 8275's internal FIFO
  (2×80 character buffer) — does not block the bus continuously, so contention
  with parallel DMA is negligible (no display glitches observed)
- Single DMA channel is sufficient: reconfigure direction (receive/transmit)
  per transfer. Setup overhead is a few OUT instructions, negligible vs transfer.
- On a diskless CP/NOS client, Channel 1 (FDC) also becomes available,
  enabling pre-configured receive+transmit channels for zero-overhead
  direction switching.
- Could achieve 500-800 KB/s sustained throughput with CPU free for protocol
  processing (double-buffering becomes practical)

## Z80 Bus Connector (J10) — Longer Term

The RC702 has a bus connector (J10, exact designation TBD) providing direct
access to the Z80 data/address bus. This opens the possibility of:

- A modern "memdisk" device: external hardware that responds to I/O port
  reads/writes, providing block storage at bus speed
- Memory-mapped shared buffer: host writes data into Z80 address space
- DMA-capable external device: transfer blocks at full bus speed

This would be the highest-bandwidth option but requires custom hardware
development and careful bus timing analysis. See the RC702 hardware
technical reference for J10 connector pinout and bus timing specifications.
