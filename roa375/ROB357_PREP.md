# ROB357 — Preparing for Unified ROA375/ROB357 Source

## Goal

Create a single assembly source with conditional assembly flags that can
generate both:
- **ROA375**: RC702 autoload PROM (MIC702/MIC703) — currently reconstructed
- **ROB357**: RC703 autoload PROM (MIC705) — not yet available

This follows the same pattern used for the BIOS source reconstruction
(`rcbios/src/BIOS.MAC` with `-DREL21 -DMINI` / `-DREL22 -DMINI` etc.).

## Source Files

| File | Description |
|------|-------------|
| `roa375.asm` | Reconstructed ROA375 source (verified against `roa375.rom`) |
| `rob358.mac` | Original ROB358 source from jbox.dk (MIC703, October 1982) |
| `roa375.rom` | Reference binary for ROA375 |
| (needed) | Reference binary for ROB357 — dump from actual RC703 PROM |

## ROM Assignment per Board (hardware manual page 12, pos. 66)

| Board | Model | PROM0 (autoload) | Notes |
|-------|-------|-------------------|-------|
| MIC702 | RC702 48KB | ROA375 | roa375.asm reconstructs this |
| MIC703 | RC702 64KB | ROA375 (or ROB358?) | rob358.mac says "RC700 AND RC703" |
| MIC704 | RC702 64KB | ROB237 | Unknown, no source |
| MIC705 | RC703 64KB | ROB357 | Target for this work |

Note: ROB358.MAC header says "RC700 AND RC703" which is confusing given
the hardware manual assigns ROA375 to MIC702/MIC703 and ROB357 to MIC705.
ROB358 may be an intermediate revision or a generic source used across boards.

## Known Differences: ROA375 vs ROB358

### Structural
| Aspect | ROA375 | ROB358 |
|--------|--------|--------|
| Relocation target | 0x7000 | 0xA000 |
| Work area (variables) | After INTVEC (~0x7320) | 0xB000+ (hardcoded EQUs) |
| Stack | 0xBFFF | 0xFFFF |
| RAMEN port | 0x18 | 0x19 |
| COLOR CRT option | No | `COLOR EQU 0` conditional |

### Boot Flow
Both ROA375 and ROB358 follow the same boot sequence:
1. Self-relocate from ROM to RAM
2. Initialize hardware (PIO, CTC, DMA, CRT)
3. Start floppy motor, sense drive, recalibrate
4. Auto-detect density on both heads of Track 0
5. Disable PROMs, read Track 0 data to 0x0000
6. Check disk signatures → dispatch to CP/M or ID-COMAL boot
7. Fallback: check PROM1, halt with error if nothing found

For CP/M boot, both read **only Track 0** (both sides) then
`LD HL,(00) / JP (HL)` to the BIOS entry point.

### Format Tables (EOT values = sectors per track per side)

ROA375 MAXIFMT (8", max cyl 76):
```
N=0 (128B): side0 EOT=26  side1 EOT=52   (26 FM sectors)
N=1 (256B): side0 EOT=15  side1 EOT=26   (26 MFM sectors)
N=2 (512B): side0 EOT=8   side1 EOT=15   (15 MFM sectors)
```

ROA375 MINIFMT (5.25", max cyl 35):
```
N=0 (128B): side0 EOT=16  side1 EOT=32   (16 FM sectors)
N=1 (256B): side0 EOT=9   side1 EOT=16   (16 MFM sectors)
N=2 (512B): side0 EOT=5   side1 EOT=9    (9 MFM sectors)
```

ROB358 constants (from source):
```
MIBYT0=2047 (mini T0S0: 16*128-1)
MIBYT1=4095 (mini T0S1: 16*256-1)
MXBYT0=3327 (maxi T0S0: 26*128-1)
MXBYT1=6655 (maxi T0S1: 26*256-1)
```

These are identical to ROA375 — both use RC702 geometry (16 sectors mini,
26 sectors maxi).

### ROB357 Would Need (RC703 geometry)

RC703 mini: **10 sectors/track, 80 tracks** (vs RC702: 16 sectors, 35 tracks)

Expected MINIFMT for RC703:
```
N=0 (128B): side0 EOT=10  side1 EOT=20   (10 FM sectors)
N=1 (256B): side0 EOT=?   side1 EOT=10   (10 MFM sectors)
N=2 (512B): side0 EOT=?   side1 EOT=10   (10 MFM sectors)
```

Max cylinder: 79 (vs 35 for RC702 mini).

RC703 maxi: same as RC702 (15 sectors, 77 tracks) based on DPBs in the
r1.2 BIOS (DSM=561 matches RC702 full-capacity MAXI format).

### Signature Strings
| Check | ROA375 | ROB357 (expected) |
|-------|--------|-------------------|
| Old format (ID-COMAL) at 0x0002 | " RC700" | " RC700" (probably same) |
| New format (CP/M) at 0x0008 | " RC702" | " RC703" |
| PROM1 check at 0x2002 | " RC702" | " RC703" (maybe) |
| Banner displayed on screen | " RC700" | " RC703" or " RC700" |

The r1.2 BIOS has "RC703 " at offset 0x0008 in the config block (with
trailing space, 6 bytes), confirming the signature check.

### CALCTB Special Case (roa375.asm line 1313)

```asm
; Mini head 1: hardcoded 10 sectors
LD  L,00AH      ; Mini head 1: 10 sectors
```

This special case in CALCTB forces 10 sectors for mini head 1 regardless
of the format table. Purpose unclear — possibly handles a format quirk
where EOT doesn't correctly reflect the sector count for side 1.
ROB357 would likely need a different value here if RC703 mini uses
different per-side sector counts.

## The Track 0 Capacity Problem

The RC703 r1.2 BIOS INIT does:
```asm
DI
LD HL, 0x0000
LD DE, 0xD480
LD BC, 0x2381    ; 9089 bytes
LDIR
```

But RC703 mini Track 0 multi-density = only 3840 bytes:
- T0S0 FM: 10 x 128 = 1280B
- T0S1 MFM: 10 x 256 = 2560B

This is 5249 bytes short. The LDIR copies from 0x0000, so all 9089 bytes
must be in RAM before INIT executes. Since the autoloader only reads T0
for CP/M boot, either:

1. **ROB357 reads more than T0** — reads T0+T1 (14080B total), unlike
   ROA375/ROB358 which only read T0. This would be the most significant
   difference from ROA375.

2. **RC703 uses uniform 512B sectors on T0** (no multi-density) — T0
   would be 20 x 512 = 10240B, sufficient. But this contradicts the
   RC702/RC703 convention of FM on T0S0.

3. **The .bin image format doesn't match floppy layout** — the 819200-byte
   file might represent a hard disk image, where all sectors are 512B
   and T0 = 10240B.

**This is the key question to resolve** when analyzing a real ROB357 binary
or when an RC703 floppy IMD image becomes available.

## Conditional Assembly Strategy

Suggested flag: `-DRC703` (or `-DMIC705`)

### Affected areas in roa375.asm

1. **Constants** (lines 26-28):
   - `RAMEN`: 0x18 (RC702) vs 0x19 (RC703/ROB358)

2. **Format tables** (lines 793-802, MAXIFMT/MINIFMT):
   - MINIFMT EOT values: RC702 (16/9/5 sectors) vs RC703 (10/?/? sectors)
   - Max cylinder in FMTLKP: 35 (RC702) vs 79 (RC703)
   - MAXIFMT likely unchanged (same 8" format)

3. **Signature strings** (lines 290-291):
   - RC702TXT: " RC702" vs " RC703"

4. **CALCTB special case** (line 1313):
   - Mini head 1 hardcoded sector count may differ

5. **Banner text** (line 286-287):
   - RC700TXT: " RC700" vs " RC703" (if banner changes)

6. **Boot loading** (lines 636-643, BOOT4 loop):
   - May need to read additional tracks for RC703 (if T0 is insufficient)
   - This is the biggest potential change — might need a multi-track
     read loop instead of the single-track BOOT4 loop

7. **Relocation address** (line 188, `phase 07000H`):
   - ROB358 uses 0xA000; ROB357 is unknown
   - If 0xA000: all variable addresses change, IVT page changes

8. **COLOR CRT** (ROB358 line 12):
   - ROB358 has COLOR conditional; ROA375 does not
   - Possibly affects CRT init parameters (PARAM1/PARAM2)

### Areas likely unchanged
- DMA, CTC, PIO, CRT initialization (same hardware peripherals)
- FDC command sequences (same uPD765)
- Interrupt handling structure
- Error display logic
- COMSTR, MOVCPY utilities
- ID-COMAL boot path (SYSM/SYSC file search)

## Prerequisites Before Starting

1. **ROB357 binary dump** — need a reference to verify against. Either:
   - Dump from an actual RC703 PROM (KryoFlux of PROM, or EPROM reader)
   - Extract from a bootable RC703 disk image (the ROM is not on disk,
     but behavior can be inferred from what the BIOS expects)

2. **RC703 floppy IMD image** — to test boot in emulator. The existing
   RC703_CPM_v2.2_r1.2.bin is a raw format that the rc700 emulator
   can't directly use.

3. **Resolve the T0 capacity question** — does RC703 use multi-density T0
   or all-512B sectors? An IMD image of an RC703 floppy would answer this
   definitively.

4. **Verify ROB358 relationship** — is ROB358.MAC actually the source for
   MIC703's ROM (as stated in its header), or is it ROB357's source
   mislabeled? The header says "RC700 AND RC703" which could mean it
   targets both.
