# BIOS Comparison Results

Detailed comparison of 13 CP/M BIOSes from 20 disk images.
Full results in `rcbios/extracted_bios/README.md`.

## Four BIOS Families

| Family | Releases | Code size | TPA | JT base | Reloc dest |
|--------|----------|-----------|-----|---------|------------|
| 58K | rel.1.3, 1.4 | 4864B | 58K | 0xE200 | 0xDD00 |
| 56K RC700 | rel.2.0-2.3 | 4736B/8576B | 56K | 0xDA00 | 0xD480 |
| RC702E | rel.2.01, 2.20 | 4736B/8832B | 56K | 0xDA00 | 0xD480 |
| RC703 | rel.1.0, 1.2, TFj | 8576-8832B | 56K | 0xDA00 | 0xD480 |

## Key Findings

- All 13 BIOSes have exactly 17 standard CP/M 2.2 JT entries
- Mini vs maxi variants have identical code; maxi appends ~3840B DISKTAB
- rel.2.2 and rel.2.3: differ by 1 byte (signon version char)
- rel.2.0→2.1: 80% sequence match — code rearranged, not rewritten (CONST relocated from base+0x039D to base+0x1228, same polling pattern)
- rel.2.1→2.2: 83% match — +7B (signon, LINSEL delay), simplified STSKFL, new HDSYNC
- High positional diff rates (90%+) between adjacent versions are caused by byte-shifts from insertions, not actual code changes
- 58K→56K transition: BIOS nearly doubled to accommodate HD, CONFI.COM, RC791

## Cross-family Relationships

- 58K vs 56K RC700: 36% match (different codebases)
- 56K RC700 vs RC703: 43% match (shared ancestry, different drivers)
- 56K RC700 vs RC702E: 44% match (RAM disk fork)
- RC702E vs RC703: 24% match (most distant)

## Notable Content

- RC702E rel.2.01 INIT has RAM disk boot strings: "USE RAM-DISK", "RC702E Waiting.", clock display
- RC703 rel.1.0 maxi has leftover COMAL error messages in DISKTAB area (residual disk data)
- RC703 rel.1.2/TFj have embedded HD config with ASCII source comments + VERIFY utility

## Proven Original Sources

- **PHE358A.MAC**: RC702E PROM source
- **ROB358.MAC**: RC703 PROM source
- **BIOS.MAC** (jbox.dk): corresponds to 56K RC700 rel.2.1
