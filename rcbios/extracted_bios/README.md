# Extracted BIOS Track 0 images

Raw Track 0 data (Side 0 + Side 1) extracted from RC702/RC703 disk images
using `imd2raw.py`. Each file contains the complete system track that the
boot PROM (roa375) loads into memory at address 0x0000 before jumping to
the BIOS entry point.

## Files (10 unique BIOSes from 12 disk images)

| File | Size | Signon | Source image(s) |
|------|------|--------|----------------|
| `comal80_v1.07_mini.bin` | 6144 | `RC700 comal80  rev. 1.07` | COMAL_v1.07_SYSTEM_RC702.imd |
| `cpm22_58k_rel1.4_maxi.bin` | 9984 | `58K CP/M VERS 2.2` | Compas_v.2.13DK.imd |
| `cpm22_58k_rel1.4_mini.bin` | 6144 | `58K CP/M VERS 2.2` | SW1711-I5_CPM2.2_r1.4.imd |
| `cpm22_56k_rel1.0_rc703_maxi.bin` | 9984 | `RC703   56k CP/M vers.2.2   rel. 1.0` | SW1311-I8.imd |
| `cpm22_56k_rel1.2_rc703.bin` | 10240 | `RC703  56k CP/M vers. 2.2  rel. 1.2` | RC703_CPM_v2.2_r1.2.imd |
| `cpm22_56k_rel2.0_mini.bin` | 6144 | `RC700   56k CP/M vers.2.2   rel.2.0` | SW1711-I5_CPM2.2_r2.0.imd |
| `cpm22_56k_rel2.1_mini.bin` | 6144 | `RC700   56k CP/M vers.2.2   rel.2.1` | CPM_med_COMAL80.imd, SW1711-I5_CPM2.2_r2.1.imd |
| `cpm22_56k_rel2.2_mini.bin` | 6144 | `RC700   56k CP/M vers.2.2   rel. 2.2` | SW1711-I5_CPM2.2_r2.2.imd |
| `cpm22_56k_rel2.3_mini.bin` | 6144 | `RC700   56k CP/M vers.2.2   rel. 2.3` | SW1711-I5_RC702_CPM_v2.3.imd |
| `cpm22_56k_rel2.3_maxi.bin` | 9984 | `RC700   56k CP/M vers.2.2   rel. 2.3` | SW1711-I8.imd |

### Duplicates removed

- **SW1711-I5_CPM2.2_r2.1.imd**: BIOS code identical to CPM_med_COMAL80.imd (both rel.2.1 mini)

### Non-bootable image skipped

- **SW1329-d8.imd**: Data-only disk (Compas Pascal 2.20), no system tracks

### Does not boot in MAME

- **SW1311-I8.imd** (`cpm22_56k_rel1.0_rc703_maxi.bin`): RC703 BIOS on 8" maxi
  format — no matching MAME machine variant. The `rc702` variant reads the disk
  but the RC703 BIOS expects different hardware. A future `rc703maxi` variant
  would be needed.

## MAME boot test results

| Image | MAME variant | Signon | DIR |
|-------|-------------|--------|-----|
| COMAL_v1.07_SYSTEM_RC702.imd | rc702mini -bios 0 | `RC700 comal80  rev. 1.07` | `SYSTEM`, `convtab` |
| Compas_v.2.13DK.imd | rc702 -bios 0 | `58K CP/M VERS 2.2` | 21 files |
| CPM_med_COMAL80.imd | rc702mini -bios 0 | `RC700   56k CP/M vers.2.2   rel.2.1` | 21 files |
| RC703_CPM_v2.2_r1.2.imd | rc703 -bios 1 | `RC703  56k CP/M vers. 2.2  rel. 1.2` | 35 files |
| SW1711-I5_CPM2.2_r1.4.imd | rc702mini -bios 0 | `58K CP/M VERS 2.2` | 17 files |
| SW1711-I5_CPM2.2_r2.0.imd | rc702mini -bios 0 | `RC700   56k CP/M vers.2.2   rel.2.0` | 22 files |
| SW1711-I5_CPM2.2_r2.1.imd | rc702mini -bios 0 | `RC700   56k CP/M vers.2.2   rel.2.1` | 21 files |
| SW1711-I5_CPM2.2_r2.2.imd | rc702mini -bios 0 | `RC700   56k CP/M vers.2.2   rel. 2.2` | 22 files |
| SW1711-I5_RC702_CPM_v2.3.imd | rc702mini -bios 0 | `RC700   56k CP/M vers.2.2   rel. 2.3` | 22 files |
| SW1711-I8.imd | rc702 -bios 0 | `RC700   56k CP/M vers.2.2   rel. 2.3` | 21 files |
| SW1311-I8.imd | rc702 -bios 0 | *(does not boot)* | — |
| SW1329-d8.imd | — | *(no system tracks)* | — |

## BIOS families

**58K BIOS** (rel.1.4): Older, smaller BIOS (5632 bytes code). No hard disk
support, no CONFI.COM language tables. Signon: `58K CP/M VERS 2.2` (no release
number). Two format variants (maxi and mini) with identical code but different
disk parameter blocks.

**56K BIOS** (rel.2.0–2.3): Larger BIOS (7680 bytes code) with hard disk
support, CONFI.COM configuration, and RC791 line selector. The extra features
reduce TPA from 58K to 56K. rel.2.2/2.3 share code; only signon string and
DISKTAB differ.

**RC703 BIOS** (rel.1.0, rel.1.2): RC703-specific. No extended BIOS entries.
Runtime-initialized DPBASE. rel.1.0 is 8" maxi format; rel.1.2 is uniform
MFM QD format.

**COMAL-80** (rev.1.07): Standalone operating system with own filesystem.
Not CP/M.

## Track 0 layout

| Format | Side 0 (FM) | Side 1 (MFM) | Total |
|--------|-------------|--------------|-------|
| 5.25" mini | 16 × 128B = 2048 | 16 × 256B = 4096 | 6144 |
| 8" maxi | 26 × 128B = 3328 | 26 × 256B = 6656 | 9984 |
| RC703 QD | 10 × 512B = 5120 | 10 × 512B = 5120 | 10240 |

The first 640 bytes (5 × 128B sectors) are the CONFI.COM configuration block.
BIOS code starts at offset 0x280.

## Extraction

```sh
python3 rcbios/imd2raw.py image.imd output.bin
```
