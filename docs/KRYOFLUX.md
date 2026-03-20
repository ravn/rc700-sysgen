# KryoFlux Disk Image Processing

## Tools
- **DTC** (DiskTool Console) v3.50 at `/usr/local/bin/dtc`
- Capture script: `~/Desktop/kryoflex-8-tommer/read-floppy.sh`
  - Command: `dtc -d0 -p -f$(date "+%Y-%m-%d/%H:%M")/ -e76 -i0`
  - Creates timestamped directories with `CC.S.raw` files and `graph_CC.S.bmp` visualizations
  - Note: `%H:%M` creates colons in directory names

## DTC Usage for RC702 Format

### Reading from stream files
```bash
# General syntax: -m1 (file mode), first -f/-i = input, second -f/-i = output
dtc -m1 -f"path/to/streams/" -i0 -f/tmp/output.img -i<type> -s<start> -e<end> -g2 -v360
```

### Image types for RC702
- `-i3`: FM sector image (for T0S0 single-density)
- `-i4`: MFM sector image (for data tracks double-density)
- Neither handles the RC702 mixed-density format natively

### Parameters for 8" maxi
- `-v360`: 8" drive RPM
- `-z0`: 128B sectors, `-z1`: 256B, `-z2`: 512B
- `-n26`: 26 sectors (T0), `-n15`: 15 sectors (T1-76)
- `-g2`: both sides

### Known issue: RC702 format not supported by DTC
DTC's built-in MFM/FM decoders (types 3/4) cannot decode RC702 format even with
explicit sector size/count parameters. All tracks show `MFM: <unformatted>`.
The format uses standard uPD765 sector headers but DTC's sector image types
may expect specific IBM-format interleave/gap patterns.

**Alternative approaches needed:**
- HxCFloppyEmulator software (hxcfe) — may handle non-standard formats better
- Custom Python decoder reading KryoFlux stream format directly
- greaseweazle tools (`gw`) if available
- Datamuseum.dk's FluxMyFluxCapacitor or similar specialized tools

## Disk Image: 8" maxi capture (test2/2025-07-13/19:38)

### Location
`~/Desktop/kryoflex-8-tommer/test2/2025-07-13/19:38/`

### Capture details
- 77 cylinders (00-76), 2 sides = 154 tracks
- 308 files: 154 `.raw` + 154 `graph_*.bmp`
- Drive RPM: ~358.3 (nominal 360)

### DTC analysis results
- **Track 00.0**: No index signal found — capture issue, no data recoverable
- **All other tracks**: `MFM: <unformatted>` — DTC can't find sector headers
- **Cell timing pattern**:
  - Tracks 0-26: base ~0.904 us (consistent with MFM data)
  - Tracks 42+: base ~1.813 us (double, consistent with FM or unused tracks)
  - Transition around tracks 27-41: mixed patterns

### Other captures available
- `test2/2025-07-13/`: 32 capture directories (18:41 through 19:49+)
- `session3/2025-08-07/`: 14 directories — all EMPTY (files in iCloud, not downloaded)
- `test1/`: contains disk1, disk2, disk3 subdirectories

### Status: NOT DECODED
The raw stream data exists but cannot be converted to sector data with DTC alone.
Need alternative decoding tools or manual flux analysis.
