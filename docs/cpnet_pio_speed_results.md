# PIO-B throughput — measured 2026-04-27

Speed bench for the Option P parallel-port driver
(see [`cpnet_fast_link.md`](cpnet_fast_link.md)).  All measurements are
**at MAME real-time (no `-nothrottle`)**, so wall elapsed equals Z80
emulated time at the chip's 4 MHz clock — the numbers below approximate
what real hardware delivers.

## Headline

| Direction | Mechanism | Throughput | Per-byte cost | Cycles/byte |
|---|---|---|---|---|
| Z80 → host | `transport_pio_send_byte` per byte (C function call) | **22 KiB/s** | 4593 ms / 100 KiB | ~180 T |
| Z80 → host | inline `OTIR` over a 32-byte ramp buffer | **156 KiB/s** | 639 ms / 100 KiB | ~26 T |
| host → Z80 | ISR-driven (chip IE on; counter wrap at 65536) | **15 KiB/s** | 4216 ms / 64 KiB | ~270 T (observed; theoretical ~120 T) |
| host → Z80 | inline `INIR` busy-poll (chip IE off) | **148 KiB/s** | 431 ms / 64 KiB | ~27 T |

Theoretical 4 MHz Z80 ceilings for instruction-only cost:
- `OUT (C),(HL)` (= OTIR body): 21 T → 190 KiB/s
- `IN (HL),(C)` (= INIR body): 21 T → 190 KiB/s

The OTIR and INIR variants reach **78–82% of theoretical**, with the
remainder lost to chunk-reload overhead (~25 T per 256-byte chunk =
0.1 T/byte) and MAME-side chip+bridge overhead per byte.

## Test methodology

**Harness:** `tests/cpnet_bridge/harness.py` with `--mode=` selecting:
- `speed`: TX C-loop, 100 KiB
- `speed-otir`: TX inline OTIR, 100 KiB
- `speed-rx`: RX via ISR + uint16_t-counter wrap, 64 KiB
- `speed-rx-inir`: RX via INIR busy-poll, 64 KiB (preceded by a 0xAA
  sentinel that gates the timed phase on host actually delivering data)

The harness:
1. Builds cpnos-rom with the matching `PIO_SPEED_TEST=N` flag
   (recompiles cleanly per mode — not just rebuild-if-stale).
2. Spawns `netboot_server.py` on `:4002` and `sio_b_driver.py` on `:9001`
   so cpnos boots normally.
3. Launches MAME at **real-time** (no `-nothrottle`) with
   `-piob cpnet_bridge`.
4. Waits for `pio_test_done = 1` to be observed via `tap.lua` writing
   `/tmp/cpnos_loopback_result.txt`.
5. Computes wall elapsed = Z80 emulated time at 4 MHz.

**Measurement window:**
- TX modes: from "first byte arrives at the bridge socket" (host's
  `recv()` returns) to "last byte arrives".
- RX modes: from `bridge.sendall(payload)` start to `pio_test_done`
  observed by tap.

## Per-variant analysis

### TX C-loop (22 KiB/s)
Every byte goes through `transport_pio_send_byte()` — a C function with
a mode-dirty check, an OUT, and a return.  The 180 T/byte is dominated
by the function-call envelope; the OUT itself is 11 T.

Useful when the byte source is an irregular sequence (driver code,
protocol packet building) where each byte takes meaningful work to
produce.  Not useful when the bottleneck is the wire.

### TX OTIR (156 KiB/s)
Z80's tightest output instruction.  21 T/byte for `OUT (C),(HL); INC HL;
DEC B; JR NZ`-equivalent microcode.  Buffer in `.rodata` (32-byte ramp;
kept small so the test code fits in the static-stack budget).  The ramp
walks 400 times for 102400 bytes total.

Useful when streaming a prepared block: BIOS reads from disk (sector
data already in a buffer), bulk file transfer, prepared CP/NET
responses with the payload already laid out.

### RX ISR (15 KiB/s, observed)
Chip's IE flip-flop on; each strobe fires an IRQ.  ISR is naked,
~30 T-states of body, but the IRQ accept (~30 T) + RETI (~14 T) +
chip+bridge overhead in MAME push observed throughput well below the
~120 T theoretical lower-bound.  At MAME 100% target the simulator
falls behind because each byte's chip+bridge work doesn't fit in the
Z80's per-byte cycle budget — the wall-time shows 270 T/byte, not 120.

This is the path that would handle CP/NET frames if we wanted host →
Z80 to be naturally interrupt-driven (e.g., command frames arriving
unsolicited).  It works correctly but the throughput cap matters.

**Side finding (commit message references):** the original
`transport_pio_recv_byte` ring path is unusable for sustained RX
streaming.  Each CPU read of the data port triggers
`set_rdy(false); set_rdy(true)`, which fires the bridge's `rdy_w(1)`
callback synchronously, which calls `strobe_w(0); strobe_w(1)` — that
queues the next byte into `m_input` and sets `m_ip`.  After the ISR's
RETI, the next IRQ is taken immediately.  Mainline (the recv_byte
loop) gets at most one instruction per ISR cycle.  At full RX rate the
mainline can't drain the 32-byte ring before the ISR overflows it.
The ISR-counter approach in this report sidesteps the ring entirely
by counting in the ISR and using a uint16_t wrap to signal completion.

### RX INIR (148 KiB/s)
Chip's IE flip-flop off; CPU runs `INIR` (256 chunks of 256 bytes for
65536 total).  Each `IN` triggers `data_read`; `data_read` calls
`set_rdy(false); set_rdy(true)`; that synchronously fires
`bridge.rdy_w(1)` which calls `strobe_w(0); strobe_w(1)`; chip's
`strobe(0)` pops the next byte from FIFO into `m_input`; chip's
`strobe(1)` sets `m_ip` but no IRQ fires because `m_ie = false`.

End result: each `INIR` iteration is exactly 21 T-states from the Z80's
view, the chip+bridge work happens in MAME's emu thread synchronously
with the IN, and bytes flow at near-instruction-cost rate.

The 5% gap to TX OTIR (148 vs 156 KiB/s) reflects:
- The brief sentinel-wait phase before the INIR loop starts (~ms wall).
- Small per-chunk reload overhead (`ld hl,0xC000; ld b,0; dec d; jr nz`
  ~25 T per 256-byte chunk = 0.1 T/byte).

## Implications for the upper-layer protocol

Recommendation in the design doc was Option (2): **byte-blast frames
with sum-to-zero CKS, no ENQ/ACK envelope**.  The numbers reinforce
this — both directions are wire-bound at ~150 KiB/s when using the
appropriate Z80 instruction (OTIR for TX, INIR for RX, both 21 T/byte).
Per-byte ENQ/ACK overhead would dominate at this rate.

| Frame size | Round-trip @ 150 KiB/s | Round-trip via 38400 baud SIO async |
|---|---|---|
| 5 B header + 0 B payload | ~70 µs | ~3 ms |
| 5 B + 128 B payload | ~900 µs | ~36 ms |
| 5 B + 1024 B payload | ~7 ms | ~270 ms |

Roughly **40× faster** than the current SIO baseline at 38400 baud.

## Caveats

1. **MAME emulator overhead.**  The chip + bridge per-byte work in
   MAME costs wall time in the emu thread.  At MAME 100% throttle the
   emu thread tries to keep Z80 pacing; if it can't, MAME slows below
   100% and our wall measurement undercounts the actual Z80 rate.
   The OTIR/INIR numbers include MAME falling slightly below 100%;
   real hardware (where the bridge is real silicon, not a mutex-locked
   FIFO) would likely match or exceed the theoretical 190 KiB/s.

2. **ISR RX rate is a lower bound.**  The 15 KiB/s figure for the
   ISR-driven path includes MAME's chip+bridge overhead per IRQ, not
   just Z80 cycles.  Real HW (with hardware IRQ controller, no MAME
   simulation) could deliver 30–35 KiB/s.  Still well below INIR's
   148 KiB/s.

3. **Chip-emulation prefix.**  Z80-PIO Mode 1 → Mode 0 transition
   immediately fires `out_pb_callback` with `m_output` (0 after reset),
   producing a stale 0x00 byte before the first real CPU OUT.  The
   harness strips this (looks for `len == N+1` with `buf[0] == 0x00`).
   On real hardware, the data lines drive whatever's in the output
   latch on mode entry — the peripheral has to know to discard
   pre-frame "noise" by recognising the SCB header signature.  Same
   wire-protocol convention applies.

4. **Compiler bug encountered.**  The original TX C-loop had a
   `uint16_t inner` counter that clang stored in BC for the loop test
   but read from a never-written static-stack slot at the call-arg
   use site (ravn/llvm-z80#82).  Worked around with three nested
   `uint8_t` loops.  XFAIL lit test in
   `llvm/test/CodeGen/Z80/static-stack-loop-counter-desync.ll`.

## Reproducing

```
cd /Users/ravn/z80/rc700-gensmedet
python3 tests/cpnet_bridge/harness.py --mode=speed         # TX C-loop
python3 tests/cpnet_bridge/harness.py --mode=speed-otir    # TX OTIR
python3 tests/cpnet_bridge/harness.py --mode=speed-rx      # RX ISR
python3 tests/cpnet_bridge/harness.py --mode=speed-rx-inir # RX INIR
```

Each run takes ~10–20 s wall: ~3.5 s cpnos boot + the test + cleanup.

## What's not measured here

- **Real-hardware throughput** with a Pi+Pico bridge.  Pending HW.
  Expectation: should reach or exceed the 148–156 KiB/s figures since
  no MAME emulator overhead.
- **Half-duplex direction switching cost.**  Each Z80→host then host→Z80
  flip costs one Mode 0/1 reconfiguration: a handful of OUTs to the
  PIO control port (~50 T = 12.5 µs).  Negligible vs even a 5-byte
  CP/NET header (5 × 21 T = 105 T = 26 µs) — the mode-switch is
  ~50% of the smallest frame's transfer time, which is already much
  faster than the current SIO baseline.
- **CRC or stronger checksum cost.**  The current Option P design uses
  a 1-byte sum-to-zero CKS.  CRC-16 would add ~70 T-states per byte
  on a tight Z80 implementation — would cut throughput by ~3×.  The
  reliability story (PIO hardware handshake guarantees byte delivery)
  doesn't justify CRC; sum-to-zero stays.
- **Sustained throughput under contention.**  These tests are
  single-stream.  In production, CRT VRTC ISR and other periodic work
  steal a small percentage.  Unmeasured but trivially bounded
  (CRT ISR ~50 Hz, ~30 T/fire = 0.04% overhead).
