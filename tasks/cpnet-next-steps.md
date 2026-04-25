# CP/NET Next Steps — Snapshot 2026-04-15 (overtaken)

> **Overtaken 2026-04-25.** This doc was the forward plan as of
> session 18. Most phases have since been completed or superseded.
> For current state see:
>
> - [`../docs/cpnet_fast_link.md`](../docs/cpnet_fast_link.md) — fast
>   transport design (Option P, PIO-B half-duplex via J3); replaces
>   "Phase D Parallel Port Investigation" below.
> - [`cpnos-next-steps.md`](cpnos-next-steps.md) — active CP/NOS
>   handover doc (kept current).
> - [`timeline.md`](timeline.md) — chronological project log.

## What got done since this plan was written

| Phase A | CP/NET on latest BIOS in MAME against z80pack MP/M | DONE — see Phase 16 in `timeline.md` |
| Phase B | RTS flow control for disk safety | DONE — session 23 (Phase ~23 in timeline) |
| Phase C | Physical hardware serial | partial — SDLC TX bench-verified; physical async path works |
| Phase D | Parallel port investigation | SUPERSEDED — design pinned in `docs/cpnet_fast_link.md` (Option P) |
| Phase E | CP/NOS diskless client | DONE — CP/NOS boots, CCP runs, DIR works against live MP/M |

## What's still load-bearing from the snapshot below

- The IOBYTE / SIO routing decision: SIO-A = data (RDR + PUN + LST in
  most presets), SIO-B = console. Captured in
  `rcbios-in-c/bios.h:185-195`; preserved by Option P (which adds
  PIO-B for CP/NET, leaving both SIOs alone).
- The infrastructure table (SNIOS, server.py, z80pack MP/M, BIOS,
  test suite, DRI protocol doc, MP/M bug analysis) — components
  unchanged, still where they were.

The original 2026-04-15 plan text (Phase A-E walkthroughs, issue
analysis, technical risks list) is preserved in git history (latest:
`97cc565^`) — not in the working tree.
