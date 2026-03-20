# CP/NOS Diskless Boot Client Sizing

CP/NOS diskless boot client sizing for RC702.

## Component sizes (from cpnet-z80 dist/)

| Component | Size | Purpose |
|-----------|------|---------|
| SNIOS.SPR | 1.0 KB | Serial network I/O (DRI binary protocol) |
| NDOS.SPR | 3.7 KB | Network DOS (BDOS interception, drive mapping) |
| CCP.SPR | 3.2 KB | CP/M console command processor |
| CPNETLDR.COM | 1.5 KB | Loader (copies SNIOS & NDOS, patches BDOS vector) |

Total client runtime: ~7.9 KB (SNIOS + NDOS + CCP).

## PROM bootstrap estimate

The PROM only needs the bootstrap (~1 KB per cpnet.md plan):
SIO/CTC init, serial I/O, minimal SNIOS protocol, network boot request, display.

**4 KB PROM is sufficient** — ~3 KB headroom beyond the ~1 KB bootstrap.
2 KB PROM would also work but is tighter.

The runtime (NDOS + CCP + SNIOS = ~7.9 KB) is loaded into RAM from the server,
not stored in PROM. So neither 4 KB nor 6 KB PROM fits the full client — but
that's by design; CP/NOS loads its OS over the network.

PROM1 (4 KB with jumper) is more than enough for CP/NOS bootstrap code.
