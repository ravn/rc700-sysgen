# CP/NET Parallel Port Transport — REJECTED

> **REJECTED 2026-04-25.** The Mode 2 PIO-A plan that used to live here
> is dead. Current CP/NET fast-link design is **Option P** in
> [`docs/cpnet_fast_link.md`](../docs/cpnet_fast_link.md): PIO-B
> half-duplex via J3, no PCB modifications, no level-shifter chip,
> RC722 keyboard untouched on PIO-A / J4.

## Why Mode 2 was rejected

- **ARDY** (Z80 PIO chip pin 28, required for the Mode 2 handshake) is
  not routed to any external connector. Verified from the MIC07
  schematic in session 16, also documented in
  [`../docs/schematics/MIC07_pinout.md`](../docs/schematics/MIC07_pinout.md).
  Mode 2 cannot complete its handshake without case-opening + soldering
  ARDY to a spare J4 pin, which is excluded by the no-PCB-modifications
  constraint.
- **BSTB and BRDY**, also needed by Port A in Mode 2, are wired only to
  J3 (Port B's connector), not to J4. A single DSUB-25 cable into J4
  cannot pick them up.
- The 2026-04-25 keyboard constraint locks PIO-A / J4 to the physical
  RC722 keyboard in production. Even if ARDY were patched in, this
  channel is no longer available for a host link.

## Where to look instead

- Current design: [`docs/cpnet_fast_link.md`](../docs/cpnet_fast_link.md)
  (Option P + Option H comparison plan).
- Schematic evidence: [`docs/schematics/MIC07_pinout.md`](../docs/schematics/MIC07_pinout.md).
- Companion supersession: [`SPLIT_CHANNEL_TRANSPORT.md`](SPLIT_CHANNEL_TRANSPORT.md)
  (the J4-input + SIO-A 250 kbaud TX alternative — also abandoned).

The pre-2026-04-25 Mode 2 design walkthrough, throughput estimates,
Pi Pico firmware sketch, and J10 bus connector futures are preserved
in git history (latest: commit `97cc565^`) — not in the working tree.
