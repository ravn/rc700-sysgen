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

### Direct (snios-on-PIO) — root cause found

Three independent bugs were blocking it.  Each surfaced after the
previous one was fixed.

**Bug 1 — stale-prefix byte on Mode 1→0 transitions.**
MAME's `z80pio.cpp::set_mode(MODE_OUTPUT)` immediately fires
`out_pb_callback(m_output)`.  After a recv→send transition,
`m_output` holds the previous send's last byte (or 0 at boot).  The
peer sees a stale byte before the real first byte of the new send.
Mpm-net2 ignores it as pre-ENQ noise; later sends ship `05 01...`
with stale `05` between ACK and SOH which mpm-net2 *cannot* tolerate.
Fix in `transport_pio.c::transport_pio_send_byte`: write the data
byte to `PORT_PIO_B_DATA` while still in Mode 1 (`MODE_INPUT::data_write`
latches `m_output` without firing the callback), then flip to Mode 0
— `set_mode` then emits the actual byte, no stale.

**Bug 2 — PIO-B chip IRQ stealing bytes.**
`init.c` was setting up PIO-B with chip IE enabled (`0x83`).
`isr_pio_par` fires on each byte arrival, reads `PORT_PIO_B_DATA`
from the ISR (which clears `m_ip`), and stores it in
`pio_par_byte`.  Mainline snios's busy-poll never gets to read it.
Fix: chip IE off at init (`0x83` → `0x03`).

**Bug 3 — bridge `rdy_w` skipped strobe on empty buffer.**
The smoking gun.  `cpnet_bridge::rdy_w` was gated on
`m_input_index < m_input_count` — only strobed when buffer had data.
When buffer drained mid-frame and Z80 kept busy-polling, no strobe
fired, so `m_input` retained the *last real byte* (chip's
`data_read` returns the cached `m_input` and only refetches
`if (!m_stb)` which is rarely true).  Every Z80 IN during the
buffer-empty window returned the same stale byte; snios's `NETIN`
treated each as a fresh data byte, stored duplicates, accumulated
wrong CKS, eventually hit the ETX/CKS verify and bailed after
MAXRETRY=10.

LOGIN's 1-byte payload had no buffer-empty window mid-receive
(envelope arrives in one TCP segment; chip cascades through it).
OPEN's 37-byte payload and READ-SEQ's 165-byte payload routinely
overrun the buffer; the trailing INs read duplicates.

Fix in `cpnet_bridge.cpp::rdy_w`: drop the buffer-non-empty gate.
Always strobe on BRDY rising edge.  When buffer is empty, `read()`
returns `0xff`; chip latches `0xff` into `m_input`; Z80's
`transport_pio_recv_byte` correctly treats `0xff` as "no byte yet"
and keeps polling.

### Direct (snios-on-PIO) — current status after the three fixes

- LOGIN: ✓
- OPEN: ✓
- READ-SEQ: progresses through 4-25 iterations before stalling.
  Still hits an intermittent race; need more investigation —
  possibly a fourth bug, possibly mpm-net2 session-state
  fragility from the earlier failed attempts.

Trace progresses well past where the original failure was.  Boot
strip reaches `INIT OKPNILOR` reliably; `INIT OKPNILORE` (EOF) and
`INIT OKPNILOREC+PSJ` (full netboot) intermittently.  Sufficient
to call the design viable, but the proxy is still the more
predictable winner for now.

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

## Why SIO works but PIO didn't (answer to the natural question)

SIO uses MAME's stock `null_modem` slot which sits on `bitbanger_device`
+ `posix_osd_socket` directly.  Each Z80 read of `PORT_SIO_A_DATA`
pulls one byte from the OSD socket layer; the chip emulation paces
bytes at the configured baud rate (38400 in our setup).  No interim
caching of "the last byte" — if no byte is available, the chip
correctly reports it via the SIO RR0 char-available bit, and Z80's
`transport_recv_byte` only reads `PORT_SIO_A_DATA` when that bit is
set.

PIO goes through our `cpnet_bridge.cpp` slot — Z80-PIO chip emulation
caches `m_input` between strobes, and our bridge had several quirks
the SIO path doesn't (stale prefix on mode flip, IRQ-driven byte
stealing, empty-buffer strobe-skip).  Each was addressed; the chip
emulation itself is fine.

## Verdict

**Proxy wins for routine use.**

- ✓ Works end-to-end against mpm-net2.
- ✓ Z80 runs at raw OTIR/INIR speed (1 ms/frame transfer; the host
  pays the envelope round-trips at ~µs/RT on real hardware).
- ✓ Reuses the Phase B `pio_send_msg`/`pio_recv_msg` driver
  unchanged; one new Python module.
- ✓ Self-contained: `cpnet_pio_server.py --upstream HOST:PORT`.
- ✓ Robust: tested end-to-end repeatedly without intermittent stalls.

**Direct (snios-on-PIO) is now functional but flaky.**

After the three bug fixes (`transport_pio.c` stale prefix,
`init.c` chip IE off, `cpnet_bridge.cpp` always-strobe rdy_w):
- ✓ Conceptually simpler (no host-side proxy process).
- ✓ LOGIN, OPEN, READ-SEQ all work in principle.
- ✗ Stalls intermittently after 4-25 READ-SEQ iterations —
  another race remains.
- Per-byte mode-flip cadence is fundamentally harder on the
  PIO chip's state machine than raw OTIR/INIR; even when fully
  debugged, this design will be slower in MAME than the proxy
  (more chip transitions per CP/NET frame).

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
