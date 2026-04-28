# Session 34 — Direct snios-on-PIO stall: root cause

Date: 2026-04-27
Branch: `pio-mpm-netboot` (off main)
Closes (or reframes): ravn/rc700-gensmedet#56

## Headline

The "intermittent stall after 4-25 READ-SEQ iterations" filed in #56
is **not a race**.  It is a deterministic data-byte conflation:
`transport_pio_recv_byte` treats the value `0xFF` as the
empty-FIFO sentinel, but `0xFF` is also a legitimate data byte that
`mpm-net2` will send as part of any payload that contains it.
Whenever a `0xFF` byte arrives in the bridge buffer, snios silently
drops it and the recv frame ends up shifted by one byte — header
checksum, ETX, CKS, or any payload byte that happens to fall in the
shifted position no longer matches and the frame is rejected.

The stall point depends on the data, not on chip-emulation timing.

## Evidence — 0xFF distribution in `cpnos.com`

`cpnos.com` is what NDOS loads via READ-SEQ, 128 bytes per call.
Per-sector 0xFF count:

| Sector | 0xFF in this sector | First offset within sector |
|---:|---:|---:|
| 0 | 0 | — |
| 1 | 0 | — |
| 2 | 0 | — |
| 3 | 0 | — |
| **4** | **19** | **80** |
| 5 | 4 | 37 |
| 6 | 2 | 37 |
| 7 | 2 | 18 |
| 8 | 1 | 36 |
| 9 | 2 | 58 |
| 10 | 2 | 42 |
| 11 | 0 | — |
| 12 | 0 | — |
| 13 | 1 | 103 |
| 14 | 1 | 25 |
| 15 | 2 | 56 |
| 16 | 2 | 55 |
| 17 | 3 | 48 |
| 18 | 0 | — |
| 19 | 1 | 13 |
| 20-24 | 0 | — |

13 of 25 sectors contain at least one 0xFF.  **Sector 4 is the first
sector with 0xFF.**  Every other run has stalled "at iteration ~4".
The "4-25" range in the original report reflects the partial recovery
pattern when mpm-net2 retries a failed frame and snios occasionally
catches the next ENQ; some sectors with 0xFF happen to corrupt in a
position that survives the recovery, others do not.

(`cpnos.com` here is the relocated payload — Z80 instructions and
data — so 0xFF appears mostly as `RST 38h` opcodes, jump-vector
fillers, and unmapped table entries.  ~1.3% of bytes are 0xFF;
density is non-uniform.)

## Mechanism

`transport_pio.c::transport_pio_recv_byte`:

```c
#define PIO_RX_EMPTY_VAL 0xFF

uint16_t transport_pio_recv_byte(uint16_t timeout_ticks) {
    pio_b_set_input();
    while (timeout_ticks--) {
        uint8_t b = _port_in(PORT_PIO_B_DATA);
        if (b != PIO_RX_EMPTY_VAL) return b;   // <-- 0xFF data treated as empty
    }
    return TRANSPORT_TIMEOUT;
}
```

`PORT_PIO_B_DATA` IN goes through MAME's `z80pio.cpp::data_read`
(MODE_INPUT path):

```cpp
case MODE_INPUT:
    if (!m_stb) m_input = m_in_pb_cb(0);   // rare; m_stb is normally 1
    data = m_input;
    set_rdy(false);
    set_rdy(true);                         // fires our rdy_w(1) -> strobe pair
    break;
```

Each Z80 IN returns the byte that the *previous* strobe latched into
`m_input`, then triggers a strobe pair which fetches the *next* byte
into `m_input` (via our `cpnet_bridge::read()`).

When a real `0xFF` byte arrives:

1. Bridge has `[..., 0xFF, X, ...]` in `m_input_buffer`.
2. Strobe pair fires `read()`, returns `0xFF`.  Chip latches
   `m_input = 0xFF`.
3. Z80 IN reads `m_input = 0xFF`.  `transport_pio_recv_byte` sees
   `0xFF`, treats as empty, polls again.
4. The IN itself triggered set_rdy(true) → rdy_w → next strobe pair →
   `read()` returns `X`.  `m_input = X`.
5. Z80 IN reads `m_input = X`.  `transport_pio_recv_byte` returns `X`.

The 0xFF byte has been consumed from the bridge buffer *without* being
delivered to snios.  snios's per-call recv count (NETIN's E counter)
treats its `X` as if it were the byte at the 0xFF's position.  The
frame is now shifted by one byte; HCS / ETX / CKS no longer match.
snios bails out of `RECV` (returns from the cp-mismatch sites) and
NDOS's RCVMSG retry loop kicks in.

mpm-net2 sees the slave fail to ACK its frame, retries the same frame
(same bytes, same 0xFF), gets another silent drop, eventually gives up
on that frame.  The slave declares the network down via `NTWKER`.

## Why the SIO path doesn't have this bug

`transport_sio.c::transport_recv_byte` checks the SIO chip's
`RR0_RX_CHAR_AVAIL` status bit *before* reading the data register:

```c
while (timeout_ticks--) {
    if (_port_in(PORT_SIO_A_CTRL) & SIO_RR0_RX_CHAR_AVAIL) {
        return _port_in(PORT_SIO_A_DATA);   // any 0..255 is valid
    }
}
```

The SIO chip exposes "byte available" as a status bit visible to the
Z80 over IN.  PIO Mode 1 has no such bit — readiness is signalled by
the chip's hardware INT/BRDY lines, not via a Z80-readable status
register.  So the polled-recv design that works for SIO cannot work
for PIO without an out-of-band signal.

## Why the proxy path doesn't have this bug

The proxy (`cpnet_pio_server.py --upstream` on the host side) sees
raw SCB bytes blasted through OTIR/INIR.  The Z80 transfer count is
encoded in the SCB itself (`5 + (SIZ+1) + 1` wire bytes).  No
per-byte sentinel; OTIR/INIR ship exactly N bytes, end of story.
The host de-frames into the SIO envelope and forwards to mpm-net2.
0xFF data bytes pass through untouched.

## Fix paths

The 0xFF=empty conflation is fundamental to a polled-recv design over
PIO Mode 1.  The chip provides no "byte ready" status bit.  Three
viable fixes:

### Fix A — IRQ-driven snios-on-PIO

Re-enable PIO-B chip IE (`init.c::port_init`: `0x03 → 0x83`).  Revert
`cpnet_bridge.cpp` to "strobe only when buffer non-empty" (drop the
always-strobe Bug 3 fix; with IRQ-only consumer there is no busy-poll
to misread cached `m_input`).  Replace `transport_pio_recv_byte` with
a ring-buffer pop that an ISR pushes into; ISR reads `m_input` once
per chip strobe, which only fires when bridge has a real byte.

Effort: medium.  Touches `init.c`, `isr.c` (push the byte instead of
storing one), `transport_pio.c` (recv reads from queue), `snios.s`
(unchanged — RECVBY still calls `transport_pio_recv_byte`).
`cpnet_bridge.cpp` reverts one line.

### Fix B — Use the proxy

Already works.  Park direct mode.  Document that direct snios-on-PIO
requires the IRQ path; without it, polled recv cannot disambiguate
0xFF data from empty.

### Fix C — Out-of-band "byte ready" port on the bridge

Custom MAME extension: expose the bridge's `m_input_index <
m_input_count` state via a separate Z80 I/O port (e.g., `0x12`).
`transport_pio_recv_byte` polls this status port before reading data.
Departs from real PIO behaviour (real chip / real Pi-Pico bridge has
no such port), so this is MAME-only.  Bad fit for a design that's
supposed to mirror real-hardware behaviour.

## Recommendation

**Fix B** (park direct, recommend proxy) for now.  Fix A is the
"correct" answer if direct ever becomes desirable, but the proxy is
already faster end-to-end in MAME (1.44 s vs the direct path's
unbounded re-tries) and carries the same per-frame structure on the
PIO line.  No production reason to revisit direct.

If revisiting later: prototype Fix A on a separate branch.  The
queue-based ISR is a small, isolated change — the 0xFF=empty
conflation only exists in the polled path, so an IRQ path sidesteps
it cleanly.

## Issue #56 update

Reframe: not a race, deterministic 0xFF data-byte drop.
Reproduction: any READ-SEQ payload containing 0xFF will fail.
First-fail point for `cpnos.com` netboot: sector 4.

## Files of note

- `cpnos-rom/transport_pio.c::transport_pio_recv_byte` — the
  conflation site.
- `cpnos-rom/transport_sio.c::transport_recv_byte` — the working
  SIO equivalent, for contrast.
- `mame:src/devices/machine/z80pio.cpp::data_read` — the chip's
  MODE_INPUT read path (cached `m_input`, post-read strobe via
  `set_rdy(false)+set_rdy(true)`).
- `cpnos-rom/cpnos-build/d/cpnos.com` — the payload; sector 4
  contains the first 0xFF.
- `tasks/session32-pio-mpm-comparison.md`,
  `tasks/session33-pio-mpm-investigation.md` — earlier framing
  that called this "intermittent" and "another race".

## Lessons

### "Intermittent" framing hid a deterministic bug

Sessions 32-33 framed this as a fourth race after Bugs 1-3.  In
reality the symptom *is* deterministic at the byte level — the
"intermittent" pattern came from mpm-net2's retry semantics
sometimes recovering and sometimes giving up depending on byte
content.  When intermittence appears, **check whether the variation
is in the data path before assuming it's in the timing path**.

### Borrow status semantics from the working analog

The "why does SIO work but PIO doesn't" framing in session 33 caught
the chip-emulation quirks (Bugs 1-3) but missed the higher-level
status-bit difference.  SIO's `RR0_RX_CHAR_AVAIL` is the moral
equivalent of an "is there a byte" signal; PIO Mode 1 has nothing
analogous Z80-readable.  The implementations diverge because the
chips diverge — and copying the SIO `transport_recv_byte` shape to
PIO without an equivalent status bit was the original design
mistake.

### Count the data, not just the protocol

The diagnostic that found the bug was simply counting `0xFF` bytes
in `cpnos.com` and matching against the "stalls at sector 4-25"
report.  Earlier debugging traced byte-level wire activity and
chip-state transitions; none of it surfaced the `PIO_RX_EMPTY_VAL`
choice in `transport_pio.c` because that value looked harmless in
isolation.  When a polling driver uses a sentinel, **enumerate
which legitimate data values would alias the sentinel** before
trusting the design.
