# CP/NET Split-Channel Transport

**Status:** design proposal, 2026-04-17. Not yet implemented.

Alternative to `PARALLEL_TRANSPORT.md`. Delivers similar throughput **without
any RC702 hardware modifications** (no rewiring, no soldering, no Y-cables).
Uses the stock J3 "parallel" DSUB-25 with a **custom cable** (see
`rcbios-in-c/docs/parport_cable_investigation.md`) for the PC → RC702
direction, and the existing SIO-A serial line for the RC702 → PC direction,
exploiting the fact that each hardware channel has a natural strong
direction.

SIO-A currently carries CP/M's RDR:/PUN: devices (see `bios.c:885`), so the
fast RC702 → PC path reuses existing BIOS infrastructure — the only BIOS
change on that side is reconfiguring SIO-A TX to 250 kbaud. The keyboard
stays on PIO Port A / J4 untouched.

## Architecture

Two independent unidirectional pipes, together forming a full-duplex CP/NET
transport:

```
           ┌─── 8 data + /BSTB on J3 (custom cable, parallel) ─────┐
           │              PC → RC702                               │
           │              "BDOS responses, disk data to client,    │
           │               disk data from client on writes"        │
           ▼                                                       ▼
     Linux host                                              RC702 Z80 PIO
     AX99100 parport                                         Port B, Mode 1
                                                              (input)
           ▲                                                       │
           │              RC702 → PC                               │
           │              "BDOS requests, disk data to server,     │
           │               status, status responses"               │
           └──── SIO-A TX @ 250 kbaud → FTDI RX on ttyUSB0 ────────┘
```

SIO-B remains free for the debug console independent of this transport
(per recent `--- SIO-B debug console if SW0=1 ---` work).

Nothing needs a reverse direction on its own cable. Neither channel has a
missing-handshake problem because neither channel tries to handshake — each
is a simple one-way pipe, and synchronization happens at the CP/NET
packet-boundary layer.

## Why it maps cleanly onto CP/NET

CP/NET messages (DRI SNIOS primitive) are **bounded and self-delimiting**:

- Header (≈5 bytes): format code, source node, destination node, function,
  length, message ID.
- Payload (≤128 bytes): a single CP/M disk sector or the parameter block
  for a BDOS function.
- Maximum total packet size: **~133 bytes**.
- Packet length is carried *in* the header, so the receiver always knows
  exactly how many bytes to read.

This is important because it means every logical message fits in **one USB
transaction** in each direction, and the Z80 CP/NET client only needs a
trivial ring buffer (~260 B to hold one in-flight packet in each direction
with room to spare).

## Traffic symmetry — writes matter too

Naive reading of CP/NET makes the server-inbound direction (PC → RC702)
look dominant: client reads from server's disks, so the bulk traffic flows
that way. But **writes are first-class**:

| CP/NET operation          | Direction of big data | Typical payload size |
|---------------------------|-----------------------|----------------------|
| BDOS Read Sector          | PC → RC702           | 128 B sector         |
| BDOS Write Sector         | **RC702 → PC**       | 128 B sector         |
| BDOS Open/Close/Search    | both (small)         | <20 B                |
| BDOS Read/Write Random    | sector-sized         | 128 B + addressing   |
| Directory operations      | small                | <30 B                |
| LIST output (PUN:, LST:)  | **RC702 → PC**       | bytes-to-many-KB     |

So the RC702 → PC pipe must carry 128-byte sector blocks too, and do it at a
rate that keeps writes responsive.  A compile cycle that emits object files,
a `PIP` that copies from the local floppy to a networked drive, a
`SAVE N FILE.COM` — all of these stream full-size CP/NET packets upstream.

The split-channel architecture supports this because **SIO-A TX has been
measured at 23 KB/s clean** (see `rcbios-in-c/tasks/session17-siob-console.md`,
and note below on x1 mode asymmetry). That is comparable to the parallel
downlink's realistic ~30 KB/s ceiling, so writes run at almost the same
sector rate as reads.

## Measured channel capacities

| Channel       | Mode                      | Measured / estimated          |
|---------------|---------------------------|-------------------------------|
| Parallel down | PIO Mode 1, ISR-driven    | ~30 KB/s sustained (Z80 ISR cost bound) |
| Parallel down | PIO Mode 1, polled tight loop | ~100 KB/s burst (no other CPU work) |
| SIO-A up      | TX @ 250 kbaud, x1       | **23 KB/s measured, 0 errors / 8192 B** |
| SIO-A up      | TX @ 38400, x16          | 3.8 KB/s (conservative default) |

Key point: SIO-A is used **TX-only in CP/NET traffic** from the RC702 side
in this transport. This completely sidesteps the SIO x1-mode RX clock
recovery problem that caps normal inbound serial at 38400. The RC702's
SIO TX generates its own bit timing and is reliable at 250 kbaud (Zilog
Z80A SIO datasheet limit is 800 kbit/s at 4 MHz). SIO-A RX can stay at
its current rate (38400 x16) for ordinary RDR: input — whether that
co-exists on the same channel depends on TxCA/RxCA wiring (see
`rcbios-in-c/tasks/sio-independent-rates.md`).

## Round-trip budget for one BDOS call

Assuming 250 kbaud SIO-A TX and ~30 KB/s parallel downlink:

| Step                                        | Time    |
|---------------------------------------------|---------|
| Request up: RC702 → PC, header only         | <1 ms   |
| Request up: RC702 → PC, write-sector (~133 B) | ~6 ms |
| PC-side handler executes (host disk read)   | 1–5 ms  |
| Response down: PC → RC702, read-sector (~133 B) | ~5 ms |
| Response down: status only (~5 B)           | <1 ms   |

Read round-trip: **~7–11 ms**.
Write round-trip: **~12–16 ms**.

vs. serial-only CP/NET at 38400: ~40–50 ms per sector in either direction.

**Speedup: ~4× for reads, ~3× for writes.** In practical terms both are
fast enough that CP/NET-mounted drives feel local.

## Atomic-packet wire semantics

Because every packet is bounded and length-prefixed:

1. **Each packet = one USB transaction on the host.** No per-byte ioctls,
   no per-byte USB frames. A full 133-byte packet crosses USB in one frame
   (~1 ms overhead + wire time), not 133 frames.
2. **No mid-packet flow control.** The RC702's per-channel ring buffer is
   sized for at least one max-size packet, so the sender can blast the whole
   packet without pausing.
3. **Back-pressure only at packet boundaries.** Between packets, the PC
   simply waits until the RC702's response arrives on SIO-A. A server
   busy with a slow disk operation naturally throttles the protocol.
4. **Gaps between packets help SIO-A RX (on the PC side).** The
   multi-millisecond gap between consecutive RC702 → PC packets is
   generous; there's no continuous-stream condition to worry about on
   any channel.

## Framing

Keep it minimal. Each direction carries CP/NET packets only, with no
transport-level headers:

- **Downstream (PC → RC702 over parallel):** raw CP/NET packet bytes,
  synchronized by the PIO BSTB strobe on J3-2; Z80 ISR reads each byte
  into a ring buffer, the CP/NET layer reassembles packets by reading
  the header and then `length` more bytes.
- **Upstream (RC702 → PC over SIO-A):** raw CP/NET packet bytes. The PC
  reassembles identically.

No SIO multiplexing required. The debug console lives on SIO-B on a
separate FTDI channel; CP/NET does not touch SIO-B. RDR: / PUN: on
SIO-A can co-exist with CP/NET packets because CP/NET traffic happens
only while NIOS holds the channel — during ordinary console use, SIO-A
is idle from CP/NET's perspective.

## BIOS changes required

All software on the RC702; no RC702 hardware changes. Cable change only
(see `rcbios-in-c/docs/parport_cable_investigation.md`).

1. **PIO Port B → Mode 1 (input) with interrupt.** Currently dormant;
   initialize in `bios_hw_init`. The keyboard stays on PIO Port A / J4
   untouched.
2. **SIO-A TX → 250 kbaud x1.** Reconfigure the CTC channel feeding
   TxCA for 250 kbaud. SIO-A RX stays at its current 38400 x16 for
   RDR: input (pending the TxCA/RxCA independence question, see
   `rcbios-in-c/tasks/sio-independent-rates.md`).
3. **NIOS driver:** CP/NET network I/O shim that sends outbound packets
   via SIO-A TX (reusing the PUN: physical path) and receives inbound
   packets from the new PIO-B ring buffer.
4. **IOBYTE stays as-is.** Current RDR:/PUN: routing to SIO-A is
   preserved; NIOS runs over the same physical channel when CP/NET
   is active.

## Server changes required

All software on the PC.

1. **Parallel output via `ppdev` ioctls** (Linux kernel `ppdev` API):
   for each outbound CP/NET packet, `PPCLAIM`, loop byte-by-byte over
   `PPWDATA` + `PPWCONTROL` strobe on /STROBE (which maps to BSTB on
   the PIO via the custom cable), `PPRELEASE`. One packet per `PPCLAIM`
   keeps the loop in the kernel fast-path.
2. **Serial input from SIO-A** at 250 kbaud via pyserial on
   `/dev/ttyUSB0` (SIO-A FTDI channel; see
   `rcbios-in-c/docs/linux_host_hardware.md` for the FT2232C/D port
   identification). SIO-A is already the PUN: destination, so this
   continues working with existing tooling during the transition.
3. **Packet dispatcher** — reassemble CP/NET packets from both streams,
   route to the existing `server.py` BDOS handlers.
4. **Keep SIO-B free for debug console** on `/dev/ttyUSB1`; no
   multiplexing needed.

## Comparison with `PARALLEL_TRANSPORT.md` (Mode 2)

| Property                    | Mode 2 (PARALLEL_TRANSPORT)    | Split-channel (this doc)       |
|-----------------------------|--------------------------------|--------------------------------|
| RC702 hardware mod          | Rewiring or case-opening*      | **None**                       |
| Full-duplex                 | Yes, on one cable              | Yes, on two existing cables    |
| Max read rate               | ~150 KB/s paper; ~30 KB/s real | ~30 KB/s                       |
| Max write rate              | same as read                   | ~23 KB/s                       |
| Handshake complexity        | ARDY/ASTB/BRDY/BSTB arbitration | None — atomic-packet semantics |
| Debug console coexistence   | Separate cable needed          | SIO-B untouched — debug console stays free |
| Failure modes               | Bus-direction contention risk  | Each wire has one job          |
| Implementation effort       | NIOS + bidirectional bus driver | NIOS + two simple ISRs        |

\* `parallel_host_interface.md` and `MIC07_pinout.md` document that stock
J4 is missing ARDY, and BSTB/BRDY are on J3. Mode 2 needs soldering or a
Y-cable.

Mode 2 remains viable for a more-invasive hardware revision later. For
immediate deployment on unmodified RC702s, split-channel is the right
starting point.

## Implementation order

1. **Build the custom parallel cable** per
   `rcbios-in-c/docs/parport_cable_investigation.md`. (Current cable is
   a straight-through DB-25 and is the wrong topology.)
2. **Verify SIO-A TX at 250 kbaud** holds on the specific hardware to be
   flashed (session 17 validated this on SIO-B; re-confirm on SIO-A).
3. **PIO Port B Mode 1 ISR**: bring up a raw "byte received" counter
   over SIO-A, drive from PC `ppdev` with a monotonic pattern. Proves
   the parallel path without any protocol.
4. **Packet framing on top**: implement CP/NET-packet read/reassemble on
   both sides.
5. **Hook up to the existing CP/NET BDOS handler** (`server.py` / SNIOS)
   as a drop-in transport replacement.
6. **Measure**: bulk read, bulk write, directory-heavy workload. Compare
   against serial-only baseline.

## Open questions

- Whether SIO-A TxCA and RxCA are clocked independently on the RC702
  board, allowing 250 kbaud TX concurrent with 38400 RX. If not, SIO-A
  RX rate has to match TX rate during CP/NET sessions, and RDR:
  pass-through would need a CTC swap on session start/end. Schematic
  read pending; see `rcbios-in-c/tasks/sio-independent-rates.md`.
- Whether SIO-A RX can stay live at 38400 for ordinary RDR: input from
  the PC during a CP/NET session, as a third in-band channel. It costs one
  more Z80 SIO ISR and no hardware.
- PIO Mode 1 ring buffer size — 256 B is ample for one in-flight packet
  plus headroom, matches the existing SIO-A pattern.
- Flow control if the PC parallel driver ever outruns the Z80 ISR: on
  packet boundaries, the server can simply hold the next packet until
  it has seen the expected ACK/response on SIO-A. No out-of-band stop
  bit needed.
