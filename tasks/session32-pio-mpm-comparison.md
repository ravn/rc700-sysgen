# Session 32 — PIO-to-MP/M: proxy vs direct snios

Date: 2026-04-27
Branch: `pio-mpm-netboot` (off main)

## Headline

Compared two designs for plumbing CP/NET-over-PIO to a real
`mpm-net2` master (instead of our Python responder
`netboot_server.py`).

| Design | Z80 work | Host work | End-to-end (MAME) | Status |
|---|---|---|---|---|
| **Proxy** (raw PIO + Python translator) | OTIR/INIR raw SCBs | Python translates raw↔envelope, forwards :4002 | **1.44 s emulated, full netboot** | ✓ NDOS COLDST reached |
| **Direct** (snios envelope on PIO bytes) | snios envelope round-trips per byte | None — MAME bridge straight to mpm-net2 | LOGIN succeeds; OPEN response stuck | ✗ stuck at LOGIN marker |

Reference: SIO-only end-to-end netboot at 38400 baud emulates in
~2 s.

## Designs

### Proxy

```
Z80 PIO (raw SCB)  <-->  MAME bridge (4003)  <-->  cpnet_pio_server.py
                                                       |
                                                       v
                                                 SIO envelope client
                                                       |
                                                       v
                                                 mpm-net2 :4002
```

- Z80 transport: `transport_pio.c::pio_send_msg` / `pio_recv_msg`
  (OTIR/INIR over raw SCB; same as the Phase B design that talked to
  our Python responder).
- Host: `cpnet_pio_server.py --upstream HOST:PORT` (commit `62c2b61`).
  Adds `upstream_send` / `upstream_recv` mirroring snios.s envelope as
  a Python client.  PING (FNC=0xC0) handled locally; everything else
  forwarded.

### Direct (experiment)

```
Z80 snios envelope on PIO byte primitives  <-->  MAME bridge (4002)  <-->  mpm-net2
```

- Z80: `snios.s` calls `_transport_pio_send_byte` /
  `_transport_pio_recv_byte` instead of the SIO chip versions.  Same
  envelope code (ENQ/ACK/SOH/CKS/EOT), different chip ports.
- Stale-prefix mitigation: pre-load `m_output` via data-port write in
  Mode 1 (z80pio.cpp `MODE_INPUT::data_write` latches without firing
  callback) before flipping to Mode 0; mode switch then emits the
  intended byte not the stale one.  Confirmed in trace: clean `05 06
  01 00 ...` envelope (no leading `00` or `05` stale prefix between
  ACK and SOH).
- Frame-level transport_pio_vt and probe block deleted (not used) —
  saved ~340 bytes payload.

## Measurements

End-to-end CP/NOS netboot in MAME -nothrottle, against fresh
`mpm-net2`:

### Proxy
- Boot strip: `INIT OKPNILOREC+PSJ` (NDOS COLDST entered)
- Total emulated time: **1.44 s**
- Per-frame host wall-clock cost (60 frames):
  - recv (raw SCB from MAME): 1-7 ms
  - dispatch (envelope ENQ/ACK with mpm-net2): 5-10 ms
  - send (raw SCB to MAME): 0.01 ms
  - cumulative: 178 ms recv + 482 ms dispatch = 660 ms wall total
- Dispatch-time breakdown shows the SIO-envelope round-trips are the
  dominant per-frame cost on the host side (~10 ms wall), not the
  raw-PIO TCP I/O.

### Direct (snios-on-PIO)
- Boot strip: `INIT OKPNIL` then stuck (no `O`/`R`/`E`/`C`/`+`/`P`/`S`/`J`)
- LOGIN frame round-trip: **completes correctly** (mpm-net2 returns
  rc=0)
- OPEN (FNC=15) request sent; mpm-net2 responds with valid
  37-byte FCB payload + sum-to-zero CKS=0x1B (verified by hand
  against trace).
- Slave receives the OPEN response payload **but doesn't ACK it** —
  trace ends with mpm-net2's EOT, no ACK follows from slave.
- snios.s::RECV expected to call SNDACK after EOT byte arrives.
  Either RECVBY-ing the EOT timed out, or snios reached BADCKS,
  or the response data triggered an early `ret` somewhere.  Not
  yet root-caused.
- No `INIT OKPNILO` marker means cpnet_xact for OPEN returned 0xFE
  (transport error) — so snios_rcvmsg_c returned 0xFF.

Wire trace shows protocol bytes are clean.  My initial CKS-mismatch
hypothesis was wrong — recomputing by hand: payload sum 0x4E0 + STX
(0x02) + ETX (0x03) + CKS (0x1B) = 0x500 = 0 mod 256 ✓.  So CKS is
fine; the failure is something else in snios.s reading the response
or in the byte-level PIO recv timing.

## Why direct is not just "snios elsewhere"

The byte-level swap (SIO chip ports → PIO chip ports) compiles
cleanly and the protocol bytes look right on the wire.  But each
envelope byte involves a Mode flip cycle on PIO:

- send byte: `pio_b_set_output()` (no-op if already in output).
- recv byte: `pio_b_set_input()` (mode flip on each transition).

snios.s alternates send and recv per byte for ACK exchanges
(SENDBY ENQ → RECVBY ACK → SENDBY SOH → ... → RECVBY ACK → ...).
That's many mode flips per frame.

Each flip:
- On Mode 0→1 (send→recv): no callback fired in MAME, but the
  z80pio chip resets state.
- On Mode 1→0 (recv→send): originally fires `out_pb_callback` with
  stale `m_output`; mitigated by pre-loading m_output via data port
  write while still in input mode.

The extra mode-switch state machine on every byte makes the byte-
level snios path more fragile than raw OTIR/INIR which only flips
direction once per frame.

The OPEN response (37-byte payload) might be hitting a corner of
this state machine that LOGIN (1-byte payload) doesn't.

## Verdict

**Proxy wins for now.**

- ✓ Works end-to-end against mpm-net2.
- ✓ Z80 runs at raw OTIR/INIR speed (1 ms/frame transfer; the host
  pays the envelope round-trips at ~µs/RT on real hardware).
- ✓ Reuses the Phase B `pio_send_msg`/`pio_recv_msg` driver
  unchanged; one new Python module.
- ✓ Self-contained: `cpnet_pio_server.py --upstream HOST:PORT`.

**Direct (snios-on-PIO):**
- ✓ Conceptually simpler (no host-side proxy process).
- ✗ Currently stuck at OPEN response — needs root-cause work on
  why snios.s::RECV doesn't reach SNDACK after the data block.
- Even when fixed, snios's per-byte mode-flip cadence is harder on
  the PIO chip's state machine than raw OTIR/INIR.

## Real-hardware projection

Both designs project to roughly the same speed on real Pi/Pico
hardware:

- Proxy: ~50 ms total (~1 ms wire + host envelope at µs RTT).
- Direct: ~50–100 ms total (~1 ms wire + ~5 envelope round-trips ×
  25 frames × ~µs each).

In MAME, the proxy is faster because the envelope round-trips
happen entirely on the host TCP loop (which is fast), while the
direct design does them through MAME's emu thread one byte at a
time (each byte is a Z80 instruction + PIO chip + bridge dispatch).

vs SIO baseline:
- SIO (38400 baud): ~2 s total in MAME, ~2 s on real hardware.
- Both PIO designs: **~40× faster** than SIO on real hardware.

## Commits on `pio-mpm-netboot`

- `62c2b61` cpnet_pio_server: WIP --upstream proxy mode (envelope
  client to mpm-net2).
- `20d9203` EXPERIMENT: snios speaks PIO byte primitives directly to
  mpm-net2.
- (this doc) tasks: session 32 PIO-to-MP/M comparison.

## Next steps

1. Pick proxy as the working design; merge to main once it's been
   wired into the harness as a `pio-mpm-netboot` mode (covers the
   real-MP/M test case alongside existing `pio-netboot` against the
   Python responder).
2. Park the snios-on-PIO experiment.  If the OPEN-response stuck
   point is ever debugged, it could be revived as a "no proxy"
   alternative.
3. File the open root-cause issue on the direct path so the data
   doesn't get lost.
