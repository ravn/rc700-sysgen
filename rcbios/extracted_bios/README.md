# Extracted BIOS binaries

BIOS code extracted from RC702/RC703 disk images. Each file contains the
BIOS portion of Track 0, starting from the boot entry address stored as
a 16-bit word at offset 0x0000 (0x0280 for 56K, 0x0380 for 58K).

## Files (14 unique BIOSes from 20 disk images)

| File | Size | Boot | Signon | Source image(s) |
|------|------|------|--------|-----------------|
| `comal80_v1.07_mini.bin` | 5248 | 0x0380 | `RC700 comal80  rev. 1.07` | COMAL_v1.07_SYSTEM_RC702.imd |
| `cpm22_58k_rel1.3_mini.bin` | 5248 | 0x0380 | `58K CP/M VERS 2.2` | SW7503-2.imd |
| `cpm22_58k_rel1.4_mini.bin` | 5248 | 0x0380 | `58K CP/M VERS 2.2` | SW1711-I5_CPM2.2_r1.4.imd |
| `cpm22_58k_rel1.4_maxi.bin` | 9088 | 0x0380 | `58K CP/M VERS 2.2` | Compas_v.2.13DK.imd |
| `cpm22_56k_rel2.0_mini.bin` | 5504 | 0x0280 | `RC700   56k CP/M vers.2.2   rel.2.0` | SW1711-I5_CPM2.2_r2.0.imd |
| `cpm22_56k_rel2.1_mini.bin` | 5504 | 0x0280 | `RC700   56k CP/M vers.2.2   rel.2.1` | CPM_med_COMAL80.imd, CPM_v.2.2_rel.2.1.imd, SW1711-15.imd, SW1711-I5_r2.1.imd |
| `cpm22_56k_rel2.2_mini.bin` | 5504 | 0x0280 | `RC700   56k CP/M vers.2.2   rel. 2.2` | CPM_v.2.2_rel.2.2.imd, SW1711-I5_r2.2.imd |
| `cpm22_56k_rel2.3_mini.bin` | 5504 | 0x0280 | `RC700   56k CP/M vers.2.2   rel. 2.3` | SW1711-I5_RC702_CPM_v2.3.imd |
| `cpm22_56k_rel2.3_maxi.bin` | 9344 | 0x0280 | `RC700   56k CP/M vers.2.2   rel. 2.3` | SW1711-I8.imd, PolyPascal_3.10.imd |
| `cpm22_56k_rc702e_rel2.01_mini.bin` | 5504 | 0x0280 | `RC702E 56k CP/M Ver 2.2 Rel 2.01` | PolyPascal_v3.10.imd |
| `cpm22_56k_rc702e_rel2.20_rc703.bin` | 9600 | 0x0280 | `RC702E 56k CP/M Ver 2.2 Rel 2.20` | RC703_BDS_C_v1.50_workdisk.imd |
| `cpm22_56k_rel1.0_rc703_maxi.bin` | 9344 | 0x0280 | `RC703   56k CP/M vers.2.2   rel. 1.0` | SW1311-I8.imd |
| `cpm22_56k_rel1.2_rc703.bin` | 9600 | 0x0280 | `RC703  56k CP/M vers. 2.2  rel. 1.2` | RC703_CPM_v2.2_r1.2.imd, SW1311_cpm_v.2.2.imd |
| `cpm22_56k_relTFj_rc703.bin` | 9600 | 0x0280 | `RC703  56k CP/M vers. 2.2  rel. TFj` | RC703_Div_BIOS_typer.imd |

### Duplicates (same BIOS byte-for-byte)

- rel.2.1 mini: CPM_med_COMAL80 = CPM_v.2.2_rel.2.1 = SW1711-15 = SW1711-I5_r2.1
- rel.2.2 mini: CPM_v.2.2_rel.2.2 = SW1711-I5_r2.2
- rel.2.3 maxi: SW1711-I8 = PolyPascal_3.10
- rel.1.2 rc703: RC703_CPM_v2.2_r1.2 = SW1311_cpm_v.2.2

### Non-bootable images skipped

- **RC703_DIV_ROA.imd**: Data-only disk, no system tracks
- **SW1329-d8.imd**: Data-only disk (Compas Pascal 2.20), no system tracks
- **Metanic_COMAL-80D_v1.8.imd**: Non-standard format (uniform MFM, no FM T0)

## BIOS families

**58K BIOS** (rel.1.3, rel.1.4): Older, smaller BIOS (5248 bytes from boot entry).
No hard disk support, no CONFI.COM language tables. Signon: `58K CP/M VERS 2.2`
(no release number in signon). rel.1.3 and rel.1.4 differ in code. Mini and maxi
variants have identical code but different disk parameter blocks.

**56K BIOS** (rel.2.0-2.3): Larger BIOS (5504 bytes mini, 9344 bytes maxi) with
hard disk support, CONFI.COM configuration, and RC791 line selector. The extra
features reduce TPA from 58K to 56K. rel.2.2/2.3 share code; only signon string
and DISKTAB differ.

**RC702E BIOS** (rel.2.01, rel.2.20): Variant for RC702E hardware. rel.2.01 is
mini format, rel.2.20 is on RC703-format disk. Different signon format from
standard RC700 BIOS.

**RC703 BIOS** (rel.1.0, rel.1.2, rel.TFj): RC703-specific. No extended BIOS
entries. Runtime-initialized DPBASE. rel.1.0 is 8" maxi format; rel.1.2 and
rel.TFj are uniform MFM QD format.

**COMAL-80** (rev.1.07): Standalone operating system with own filesystem. Not CP/M.

## Extraction

The boot entry address is stored as a 16-bit little-endian word at offset 0x0000
of Track 0. The BIOS binary is the data from that offset to the end of Track 0.

```sh
python3 rcbios/imd2raw.py image.imd /tmp/t0.bin    # extract raw Track 0
python3 -c "
import struct
t0 = open('/tmp/t0.bin','rb').read()
boot = struct.unpack_from('<H', t0, 0)[0]
open('bios.bin','wb').write(t0[boot:])
print(f'Boot entry: 0x{boot:04X}, BIOS size: {len(t0)-boot}')
"
```
