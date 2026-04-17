# SIO-A split TX/RX rates (deferred)

**Status:** deferred 2026-04-17. Not blocking current work.

## Goal

Run SIO-A with **TX @ 250 kbaud x1** (RC702 → PC, fast uplink) simultaneously
with **RX @ 38400 x16** (PC → RC702, normal RDR: input). This would give
the fast uplink that CP/NET split-channel transport wants, while keeping
the PC→RC702 direction inside the SIO's x1-mode framing-error-free regime.

## What's known

- **SIO chip supports it natively.** The Z80 SIO (Z8430/Z8470) has separate
  TxCA and RxCA clock input pins on channel A. `WR4` configures TX and RX
  clock multipliers (x1/x16/x32/x64) independently.
- **TX at 250 kbaud x1 is measured working** on SIO-B (session 17,
  23 KB/s, 0 errors / 8192 B). Same SIO chip, so SIO-A should behave
  identically.
- **Zilog datasheet limit:** 0–800 kbit/s at 4 MHz Z80 clock. 250 kbaud is
  well inside spec.
- **RC702 has two CTC clock domains available:** CTC0 counter mode from
  614400 Hz oscillator, CTC1–3 timer mode from 4 MHz CPU /16 (250 kHz
  base). Two clock families means independent rates are plausible at the
  system level.

## Open question — needs schematic reading

Are **TxCA and RxCA on channel A fed from separate CTC outputs**, or tied
to one CTC channel?

- If separate: split rates work.
- If tied: we're stuck at a single rate per channel.

Check the RC702 MIC schematic sheet covering the SIO section (not MIC07
which is PIO). Same technical manual PDF as for the PIO pinout.

## Test plan when resumed

1. Read schematic, confirm TxCA/RxCA wiring on SIO-A.
2. If independent: reuse session 17's `siob_baud_test` harness retargeted
   to SIO-A. Confirm 250 kbaud TX holds.
3. Verify 38400 RX on the same channel still works concurrently with
   250 kbaud TX.
4. If tied: document as "not achievable on stock RC702" and defer further.

## Why deferred

Current work is the parallel-port investigation and CP/NET split-channel
transport. Schedule after those yield a working end-to-end path.
