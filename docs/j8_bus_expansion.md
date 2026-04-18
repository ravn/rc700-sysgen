# J8 Bus Expansion Connector — DMA and Communication Speed Analysis

**Date:** 2026-04-18
**Source:** RC702/RC703 Microcomputer Technical Manual (RCSL 44-RT2056, Feb 1983),
schematic sheets MIC 02 (page 59) and MIC 06 (page 67).
MIC 02/03/06 etc. are RC702 (MIC702/MIC703) boards; MIC704/MIC705 are the
later RC703 model.

## DMA Channel Assignments (from manual section 2.3.9, page 32)

| Channel | Assignment | DREQ source | DACK destination | Notes |
|---------|-----------|-------------|-----------------|-------|
| 0 | External (J8) | J8 pin R28 ("DEBUG REQ") | J8 (via MIC 02) | HD controller, MEM700, or custom device |
| 1 | Floppy disk | FD REQ DEL (MIC 09) | FDACK (MIC 09) | uPD765 FDC on motherboard |
| 2 | Display | DREQ2 (MIC 11) | DACK 2 (MIC 11) | 8275 CRT row buffer refill |
| 3 | Display | DREQ3 (MIC 11) | DACK 3 (MIC 11) | 8275 CRT second DMA channel |

**Important correction:** The hardware reference previously listed channel 0
as "WD1000 Winchester" and channel 3 as "available for expansion". The
manual clarifies that channel 0 is the general external/expansion channel
(active via J8), and **both** channels 2 and 3 serve the display controller.
No DMA channels are free.

## J8 Connector — Signals Routed (from MIC 02 schematic, page 59)

### Bus signals (active when ADDR EN / DMA ADDR EN asserted)

- **ADD(0:15)** — full 16-bit address bus (active when CPU or DMA owns bus)
- **BUS(0:7)** — 8-bit data bus (active when CPU or DMA owns bus)
- **CLOCK** — 4 MHz system clock (active at all times)
- **WR, RD, IORQ** — active during CPU I/O and memory cycles (active
  under ADDR EN)
- **MI** — machine cycle one (active under ADDR EN)
- **MREQ** — memory request
- **RFSH** — refresh cycle indicator
- **HALT** — CPU halt state
- **MEM RD, MEM WR** — active during DMA memory cycles (active under
  DMA ADDR EN)

### DMA handshake signals

- **J8-R28: DEBUG REQ** -> DREQ0 input on Am9517A. Active low. An
  external device asserts this to request a DMA transfer on channel 0.
- **DACK 0** (active low) -> active-low acknowledge back to the external
  device, active during the DMA cycle that services channel 0.
- **TERMINAL COUNT** -> active when the DMA word count reaches zero,
  active during the DMA cycle. Directly active on J8 (active under
  ADDR EN).
- **HOLD ACK** -> active when the CPU has released the bus in response
  to a DMA hold request. Active under ADDR EN. Active on J8.

### Control signals

- **WAIT** — active when wait states are being inserted
- **BUS REQ** — active when a device wants to claim the bus. Active
  under ADDR EN. Active on J8.
- **HOLD** — active when DMA controller requests bus from CPU (active
  under ADDR EN). Active on J8.
- **EXT ADDR STB** (J8-R30) — active pulse to external address register.
  Active under ADDR EN. Active on J8.
- **EXT REN** — active when external read is enabled (active under ADDR
  EN). Active on J8.
- **DMA ADDR EN** (directly from 68-9) — active when DMA owns the
  address/data bus. Active on J8.
- **INT PIN** (active via J8-B17) — directly active on J8. Active under
  interrupt priority. Active on J8.

### Power

- **+5V, GND** — active on J8 connector.

## Communication Speed Analysis

### DMA transfers via channel 0

The Am9517A at 4 MHz performs one bus transfer per DMA cycle. Each DMA
cycle takes 4 T-states (1 us at 4 MHz). However, the IS202A RAM
controller inserts wait states during DMA cycles when a DRAM refresh
conflicts ("WAIT DMA" signal, MIC 04/05), so effective throughput is
reduced.

**Theoretical maximum:** 1 byte / 4 T-states = 1 MB/s = 1000 KB/s

**Practical maximum** (accounting for CRT DMA contention on channels
2+3 and DRAM refresh wait states): estimated 500-800 KB/s. The 8275
CRT uses burst DMA to refill its row buffers (80 bytes per row, ~31
rows/frame at 50 Hz), consuming ~124 KB of DMA bandwidth per second
on channels 2+3. This does not directly contend with channel 0 (the
8237 services one channel at a time based on priority, ch0 highest),
but the RAM refresh wait states affect all channels equally.

### Polled I/O (no DMA)

Using Z80 block I/O instructions:
- **INIR/OTIR**: 21 T-states per byte (last iteration 16 T) = ~190 KB/s
- **IN A,(n) + LD (HL),A + INC HL**: ~14 T-states = ~286 KB/s (unrolled)
- CPU is busy during transfer (no concurrent processing)

### Comparison with current serial link

| Method | Throughput | vs serial | CPU busy? |
|--------|-----------|-----------|-----------|
| Serial 38400 async | 3.8 KB/s | 1x | Partially (ISR) |
| Polled I/O via J8 | 150-286 KB/s | 40-75x | Yes |
| DMA channel 0 via J8 | 500-1000 KB/s | 130-260x | No |

### Existing J8 devices (known)

1. **RC763 hard disk interface** — WD1000 controller on external board,
   uses DMA channel 0 for disk<->memory transfers. Connected via J8.
   Has its own CTC2 (ports 0x44-0x47) on the HD board.

2. **MEM700 RAM disk** — 64KB SRAM board, uses DMA channel 0 for
   block transfers. Connected via J8 (connector P37). Uses I/O ports
   0xEE-0xEF for track/sector addressing. Simple design: two 32Kx8
   SRAM chips + one 74HC02 quad NOR gate.

### Design considerations for a new J8 communication device

A USB-to-Z80-bus bridge on J8 would need:
- **Address decoder** for a chosen I/O port range (avoid conflicts with
  existing devices — see RC702 I/O port map)
- **DREQ0 driver** to request DMA transfers on channel 0
- **DACK0 receiver** to know when the DMA is servicing this device
- **Data buffer** (FIFO or dual-port RAM) between USB and Z80 bus
- **Status/control registers** at the decoded I/O ports

The MEM700 is an existence proof that this works with minimal logic.
Replacing its SRAM with a microcontroller + USB interface would create
a high-speed communication channel.

**Caution:** DMA channel 0 is shared. If both a hard disk and a
communication device are present, they cannot use DMA simultaneously.
The BIOS would need to arbitrate (mask channel 0 for one device while
the other transfers). Polled I/O avoids this conflict entirely at the
cost of lower throughput and CPU involvement.
