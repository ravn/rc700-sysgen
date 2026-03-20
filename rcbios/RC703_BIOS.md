# RC703 BIOS Analysis

## RC703 rel.1.2 (RC703_CPM_v2.2_r1.2.bin)

- 819200 bytes = 80 tracks × 2 sides × 10 sectors × 512 bytes
- Signon: "RC703  56k CP/M vers. 2.2  rel. 1.2"
- Entry 0x0280, BIOS at 0xDA00, same LDIR relocation as RC702 56K
- BIOS size: 7681 bytes (0xDA00-0xF800)
- **17 standard CP/M entries only** — no extended BIOS (WFITR, LINSEL, etc.)
- DPBASE at 0xDA37, runtime-initialized (0xFF on disk)

### RC703 vs RC702 Floppy Geometry
- RC702 mini: 9 sectors/track, 35 tracks, ~319K
- RC703 mini: **10 sectors/track, 80 tracks**, 390K (SS) or 780K (DS)
- RC703 MAXI: same as RC702 (15 sectors, 77 tracks, DSM=561)

### DPBs at 0xEA03-0xEA3F
- MINI SS: SPT=40, DSM=389, DRM=63, 1K blocks, 390K
- MINI DS: SPT=80, DSM=389, DRM=255, 2K blocks, 780K
- MINI DS (dup): identical to above
- MAXI DS: SPT=120, DSM=561, DRM=127, 2K blocks, 1124K

### RC703-Specific I/O Ports
- Ports 0x60-0x67 = **WD1000/WD1010 Winchester Disk Controller**
  - 0x60=Data, 0x61=Error/WPC, 0x62=Sector count, 0x63=Sector number
  - 0x64=Cyl low, 0x65=Cyl high, 0x66=SDH, 0x67=Status/Command
  - HD commands: RESTORE(0x10), READ(0x28), WRITE(0x30), FORMAT(0x50), SEEK(0x70)
- NOT present in RC702 BIOS (RC702 uses CTC2 at 0x44-0x47 on external HD board)

### Embedded Utilities
- VERIFY/BLOCKS.BAD at 0xF489-0xF7FF (~888 bytes, 11.6% of BIOS)
- HD config table at 0xEC7F-0xF37A with ASCII assembly source comments
  - Rodime RO-103/RO-202 drive parameters
  - Full DPB field documentation as embedded strings

### Jump Table Offsets vs RC702 rel.2.1
Inconsistent offsets (+39, +3, -1, -11) confirm separate codebase,
not a conditional build of the same sources.

### Files
- `ref/rc703_rel12_bios.bin` — extracted BIOS (7681 bytes)
- `ref/rc703_rel12_t0.bin` — Track 0 raw (6144 bytes)
- Full analysis in `rcbios/ANALYSIS.md` section "RC703 BIOS (rel. 1.2)"

## ROB357 Autoload ROM (RC703, MIC705) — ANALYZED

### Binary: `~/git/rc700/rob357.rom` (2048 bytes)

ROB357 is the RC703 autoload PROM. It shares 50% of bytes with ROB358
(both target 0xA000) but only 5% with ROA375 (which targets 0x7000).

### Key Finding: RC703 Mini Track 0 Format

**RC703 mini uses uniform MFM 512B sectors on Track 0** (no FM/multi-density).
INITFL sets COMBUF for: MFM READ (0x46), N=2 (512B), EOT=10, TRBYT=0x13FF.
Both sides: 10×512 = 5120B each, total 10240B > 9089B needed by LDIR.

**MAXI**: Same as ROB358/ROA375 — FM 26×128 on T0S0, MFM 26×256 on T0S1.

### T0 Capacity — RESOLVED

| Format     | T0S0       | T0S1        | Total  | LDIR 9089B |
|------------|------------|-------------|--------|------------|
| RC702 mini | FM 16×128  | MFM 16×256  | 6144   | junk OK    |
| RC702 maxi | FM 26×128  | MFM 26×256  | 9984   | surplus    |
| RC703 mini | MFM 10×512 | MFM 10×512  | 10240  | surplus    |
| RC703 maxi | FM 26×128  | MFM 26×256  | 9984   | surplus    |

The .bin file (819200 bytes) IS the actual floppy layout: uniform 512B
sectors throughout, no multi-density.

### Structural Constants
- Relocation: 0xA000 (same as ROB358, vs ROA375's 0x7000)
- Stack: 0xFFFF (same as ROB358, vs ROA375's 0xBFFF)
- RAMEN: port 0x19 (same as ROB358, vs ROA375's 0x18)
- MOVADR: ROM offset 0x12, payload 0x07EE = 2030 bytes
- Banner: " RC703" (vs ROA375's " RC700", ROB358's " RC700")
- Signature: " RC703" (vs ROA375's " RC702", ROB358's " RC700")

### Signature Checks
1. "RC703" at disk offsets 2-6 + '0' at offset 7 → ID-COMAL
2. "RC703 " at disk offsets 8-13 → CP/M boot
3. " RC70" at disk offsets 8-12 → CP/M boot (fallback, any RC70x)

### Keyboard Shortcut Swap
F=test (T_FLG, JP 0x2000), T=floppy (FLBFLG). Reversed from ROB358.

### No PROM1 Signature Check
ROA375 checks "RC702" at 0x2002. ROB357 does NOT — T_FLG causes direct
JP 0x2000 without verification.

### Full analysis: `roa375/ROB357_PREP.md`
