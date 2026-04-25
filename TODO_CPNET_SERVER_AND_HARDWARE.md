# TODO: CP/NET Physical Server and Diskless Boot — Snapshot (overtaken)

> **Overtaken 2026-04-25.** Most phases of this top-level plan have
> completed or been formally designed. For current state see:
>
> - [`docs/cpnet_fast_link.md`](docs/cpnet_fast_link.md) — fast
>   transport design (Option P, PIO-B half-duplex via J3) covering
>   the original Phase 2 (Standalone Server) and Phase 3 (Parallel
>   Port) at the transport-layer.
> - [`tasks/cpnos-next-steps.md`](tasks/cpnos-next-steps.md) —
>   active CP/NOS handover doc (Phase 4 work; CP/NOS is alive,
>   CCP runs against live MP/M).
> - [`tasks/timeline.md`](tasks/timeline.md) — chronological log of
>   what's been done.

## Status of original phases

| Phase 1 | MP/M server on macOS | DONE — `cpnet/server.py` and z80pack-as-MP/M-master both work |
| Phase 2 | Standalone server (Pi / PC) | DESIGNED — `docs/cpnet_fast_link.md` Option P; implementation deferred until Pi 4B host hardware acquired |
| Phase 3 | Parallel-port data transfer | SUPERSEDED — Option P assigns PIO-B / J3 to CP/NET, keyboard stays on PIO-A / J4. The "PIO Port Assignment Problem" speculation in the original text is resolved by the schematic findings in `docs/schematics/MIC07_pinout.md` |
| Phase 4 | Diskless CP/NOS client in PROM1 | DONE — CP/NOS boots, CCP runs, DIR works against live MP/M (see Phase 16 + later in `tasks/timeline.md`) |

## What still survives as forward work

- Implementation of Option P once Pi 4B host hardware is acquired.
- Bench-comparison of Option P vs Option H (long-term: full-speed SIO
  TX) per `docs/cpnet_fast_link.md` "Long-term: full-speed SIO TX
  comparison" subsection.
- Outside-world services on the Pi sidecar (SSH, file shares, HTTP) —
  out of scope for the link itself; tracked in `docs/cpnet_fast_link.md`
  bring-up sequence as Step 7.

The original speculative content (PROM hardware investigation for
2716 vs 2732, three-options-for-PIO-port-assignment, parallel
protocol throughput estimates) is preserved in git history (latest:
`97cc565^`) — not in the working tree.
