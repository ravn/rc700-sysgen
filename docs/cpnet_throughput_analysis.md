# CP/NET throughput analysis — why PIO doesn't appear faster

Captured 2026-04-28 to explain the bench results in `tasks/timeline.md`
Phase 27d.  The measured PIO-vs-SIO ratio for the filecopy workload is
1.81-2.02×, far below the chip-level ratio you'd expect from raw line
rates.

## Theoretical chip-level ceilings

| Wire | Line rate | Notes |
|------|-----------|-------|
| SIO async 38400 8N1 | 3840 B/s | 10 bits per byte (1 start + 8 data + 1 stop) |
| PIO Mode 0/1 OTIR/INIR | ~190 KB/s | 4 MHz / 21 T-states per byte; strobe-paced |

Ratio: PIO / SIO ≈ **50×**.

## Measured filecopy throughput (one direction, mpm-net2 backend, MAME `-nothrottle`)

| Mode | KB/s emul | % of ceiling |
|------|----------:|-------------:|
| SIO | 1.27 | ~33% |
| PIO-IRQ | 2.34 | ~1% |
| PIO-PROXY | 2.55 | ~1.3% |

Ratio measured: **~1.8-2.0×**, not 50×.

## Where the time actually goes

filecopy makes 716 CP/NET round-trips (358 reads + 358 writes).  PIO-IRQ
total = 8.4 s wall × 5 (nothrottle) ≈ 42 s emulated → **~58 ms per RTT**.
A 130-byte envelope frame at chip-level PIO bandwidth would clear in
<2 ms.  The remaining 56 ms per RTT is software latency.

Per-RTT cost breakdown (rough):

1. **MAME `cpnet_bridge` `poll_tick` timer** — fires every 1 ms.  Each
   CP/NET frame has 4 ACK turnarounds where the slave waits for a host
   ACK before sending the next chunk.  Each ACK eats at least 1 ms of
   the bridge timer quantum.  ~4 ms minimum per RTT just from emulation
   timing.

2. **mpm-net2 server is itself a simulated Z80** — z80pack/cpmsim
   running MP/M II's SERVER.RSP.  Every SCB byte arriving at TCP :4002
   is parsed at 4 MHz emulated Z80 speed.  Likely 5-10 ms emulated per
   frame just for the server-side envelope work, then another emulated-
   second for FCB lookup + disk read.

3. **TCP localhost between MAME and mpm-net2** — Nagle/socket
   scheduling.  ENQ (1 byte) is exactly the kind of small write Nagle
   penalises.  TCP_NODELAY status on either end isn't verified; could
   be eating tens of ms per turnaround.

4. **Slave-side SNIOS envelope code** — SNDMSG / RCVMSG do ENQ/ACK
   exchange + byte-by-byte SOH/STX dispatch + checksum accumulation.
   ~150-300 T-states per envelope byte → ~5-10 ms emulated per
   130-byte frame.

5. **CP/M's 128-byte record granularity** — hard ceiling on amortising
   envelope cost.  Larger record sizes would let one RTT carry more
   payload, lowering per-byte overhead.  CP/M 3 has 128 KB random
   access; cpnos doesn't.

6. **CP/NET 1.2 is strict request/response** — no pipelining.  Slave
   issues read N+1 only after read N's response arrives.  At 716 RTTs
   serially, latency dominates.

## Why PIO-PROXY is ~9% faster than PIO-IRQ on filecopy

The slave-side envelope code (SNIOS SNDMSG/RCVMSG) is the dominant
slave-side cost per frame, and PIO-PROXY skips it — slave does raw
OTIR/INIR; the cpnet_pio_server.py proxy adds the envelope toward
mpm-net2.  Saved cost: ~5-10 ms emulated per frame slave-side.  At
716 RTTs that's ~4-7 emulated seconds out of 37 — close to the
observed 9% delta.

The chip-level wire is identical between PIO-IRQ and PIO-PROXY (both
use PIO-B with the same byte cadence).  The difference is purely the
slave-side envelope work being absent in PROXY.

## What would lift the ceiling

1. **Native host CP/NET server** (not z80pack-emulated MP/M).  Replace
   mpm-net2 with a Python/C server that handles SCB parsing at native
   host speed.  `netboot_server.py` is a starting point but it's
   simplistic — would need to grow to handle the whole CP/NET BDOS
   surface (DIR, FCB tracking, multi-extent files, etc).
   Estimated effect: probably 2-4× on PIO modes, no effect on SIO
   (still line-rate limited).

2. **TCP_NODELAY on both ends.**  Cheap to set, possibly large effect
   on small ENQ/ACK turnarounds.  Worth a 30 min investigation.

3. **Reduce MAME cpnet_bridge poll quantum** from 1 ms to ~100 µs.
   `m_poll_timer = timer_alloc(...)` with a shorter period.  Trade-off:
   more host CPU spent in the bridge timer.  Easy to test.

4. **Wider records.**  CP/M 2.2 random-access uses 128-byte records;
   no widening without a full BDOS rewrite.  Hardware limit.

5. **Skip CP/NET entirely — use raw chip transfer (the `pulse` bench
   design).**  Bypasses BDOS, SNIOS, FCB tracking, and per-record
   acks.  Would show the actual chip-level ceiling.  Currently parked
   in `tasks/todo.md`.

## Physical hardware projection

Assuming a Pi/Pico-on-J3 bridge replacing MAME's emulated cpnet_bridge,
and a native Python/C host CP/NET server replacing z80pack-emulated
mpm-net2:

| Mode | MAME emul-s | physical estimate |
|------|-----------:|------------------:|
| SIO | ~68 s | ~68 s — line-rate-limited, no emulation inefficiency to remove |
| PIO-IRQ | ~37 s | ~10-20 s — strips bridge timer + emulated-host-server cost |
| PIO-PROXY | ~33 s | ~8-15 s — same plus less slave envelope work |

Ratio expected to **widen from ~2× (MAME) to ~4-7× (physical)** — the
SIO ceiling stays put while PIO sheds emulation overhead.

Costs unchanged on physical:

- Z80 chip speed (4 MHz)
- Slave-side SNIOS envelope work (same instructions)
- 716 RTT count (CP/M-2.2 record granularity is the hard ceiling)
- SIO 38400 baud line rate (the wire ceiling)

## Bottom line

The bench numbers reflect **per-RTT software latency at 716 round-trips**,
not the underlying transport bandwidth.  The transport DOES matter at
chip level — PIO has ~50× more headroom than SIO — but the workload's
overhead profile drowns it out.  The pulse bench (parked) would surface
the chip-level ratio; native-host server work would close most of the
emulation-vs-physical gap.
