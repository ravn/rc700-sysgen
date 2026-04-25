# CP/NET Split-Channel Transport — REJECTED

> **REJECTED 2026-04-25.** This split-channel design (J4 / PIO-A for
> PC -> RC702 + SIO-A sync TX for RC702 -> PC) is dead. Current
> CP/NET fast-link design is **Option P** in
> [`docs/cpnet_fast_link.md`](../docs/cpnet_fast_link.md): PIO-B
> half-duplex via J3.

## Why this design was rejected

- The 2026-04-25 keyboard-on-J4 constraint locks PIO-A / J4 to the
  RC722 keyboard. PC -> RC702 traffic cannot share that connector
  without a Pico pass-through arrangement that's awkward to build
  reliably.
- The 2026-04-25 SIO-A-keeps-RDR/PUN/LST constraint rules out
  consuming SIO-A for the RC702 -> PC sync TX. `bios.h:185-195`
  routes RDR + PUN to SIO-A under all default IOBYTE presets.
- The bench-verified TX bit clock at ÷1 is **~614 kbaud**, not the
  250 kbaud assumed throughout this doc. Doesn't reverse the
  rejection but updates the throughput projection that survives
  into Option H.

## What survives into the current design

The technically-load-bearing findings from this investigation are
now folded into [`docs/cpnet_fast_link.md`](../docs/cpnet_fast_link.md):

- **Z80-SIO/2 has no DPLL or BRG.** "SIO/2" is bonding option 2, not
  a feature version. Sync RX is impossible without an external clock
  on TxCA/RxCA — and pins 15/17 are NC on MIC702/MIC703. So sync
  mode is TX-only on this hardware. (Captured in `docs/cpnet_fast_link.md`
  "Verified hardware facts" table and in
  `RC702_HARDWARE_TECHNICAL_REFERENCE.md` SDLC paragraph.)
- **CTC channel 0 clocks both TxCA and RxCA from a single wire.**
  No independent TX/RX baud rates on SIO-A. Documented in
  [`../rcbios-in-c/tasks/sio-independent-rates.md`](../rcbios-in-c/tasks/sio-independent-rates.md)
  (RESOLVED).
- **CP/NET frames are length-prefixed and atomic.** Each ~133-byte
  frame carries its own size; the receiver always knows when a frame
  is complete. This shape underpins Option P's direction-switching
  protocol in the current design.
- **Option H** (SIO-A sync TX at ÷1, retained as comparison target
  in `docs/cpnet_fast_link.md`) recapitulates this doc's RC702 -> PC
  fast path, but on top of an Option P base instead of a J4 input.

The 2026-04-17 architecture diagram, BIOS programming sketches, and
implementation order list (which assumed J4 input + 250 kbaud SIO-A
TX) are preserved in git history (latest: `97cc565^`) — not in the
working tree.
