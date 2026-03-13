# TODO: MAME UPD765 Read Track ST1_ND Fix (upstream PR rejected)

## Status

Upstream MAME pull request rejected (2026-03).  The fix is applied in our
local MAME fork at `/Users/ravn/git/mame/` and must be reapplied after
any upstream merge.

## The Bug

The MAME UPD765/8272A emulation (`src/devices/machine/upd765.cpp`) sets
the ST1 No Data (ND) bit during Read Track based on sector ID matching.
This is incorrect per the datasheet: Read Track reads all sectors
sequentially from the index hole without comparing sector IDs.

### Datasheet Reference

NEC uPD765A/8272A datasheet, Read Track command description:

> "Data is read continuously from index hole to EOT ... the sector
> number is not compared."

The ND bit in ST1 means "the FDC could not find the specified sector",
but Read Track does not search for specific sectors — it reads them all
in physical order.

### What Happens

In `read_track_continue()`, the emulation calls `sector_matches()` for
each sector found, setting `ST1_ND` when the sector ID doesn't match
the R parameter in `command[4]`.  Since Read Track reads sectors R=1, 2,
3, ..., EOT but `command[4]` specifies only one value, the last sector
processed almost always leaves ST1_ND set.

### Affected Software

Any software that checks ST1 after Read Track will see a spurious error:

| PROM/Software | Machine | ST1 Check | Effect |
|---------------|---------|-----------|--------|
| ROA375 (roa375.asm:1404) | RC702 | `CP 000H` (any non-zero = error) | Boot error |
| rob358 (rob358.mac:826) | RC702 (MIC703) | `AND 035H` (includes ND bit) | Boot error |
| autoload-in-c (fdc.c:140) | RC702 | `fdcres[1] == 0` | Boot error |

Note: rob357 (RC703 PROM) also uses Read Track and checks ST1, though
we don't have the source reconstruction yet.

## The Fix

Remove the `sector_matches()` / ST1_ND logic from `read_track_continue()`:

```diff
--- a/src/devices/machine/upd765.cpp
+++ b/src/devices/machine/upd765.cpp
@@ -2342,10 +2342,9 @@ void upd765_family_device::read_track_continue(floppy_info &fi)
 						cur_live.idbuf[1],
 						cur_live.idbuf[2],
 						cur_live.idbuf[3]);
-			if(!sector_matches())
-				st1 |= ST1_ND;
-			else
-				st1 &= ~ST1_ND;
+			// Read Track does not compare sector IDs (UPD765/8272A datasheet:
+			// "data is read continuously from index hole ... the sector number
+			// is not compared").  Do not set ST1_ND based on sector matching.

 			sector_size = calc_sector_size(command[5]);
 			fifo_expect(sector_size, false);
```

File: `src/devices/machine/upd765.cpp`, function `read_track_continue()`,
around line 2342 (may shift with upstream changes).

## How to Reproduce

### Prerequisites

- MAME built from source with RC702 driver
- RC702 or RC703 ROM set (`roa375.rom` or `rob357.rom`)
- A bootable 8" or 5.25" floppy disk image (e.g., `SW1711-I8.imd`)

### Steps

1. Build MAME **without** the fix (vanilla upstream or revert the patch).

2. Boot the RC702 with a disk image:
   ```
   ./regnecentralen rc702 -rompath roms -flop1 image.mfi -debug
   ```

3. Set a breakpoint at `CHKRES` (ROA375 address varies by build; in the
   reconstructed source it's the function that reads ST0/ST1/ST2 after
   Read Track).  In the C autoload, break at the `fdc_result()` call
   after `fdc_read_track()`.

4. Observe that after Read Track completes:
   - All sector data was transferred correctly via DMA
   - ST1 has bit 2 (ND = 0x04) set
   - The PROM treats this as a read error and retries or displays an error

5. Apply the fix and repeat — ST1_ND is no longer set, boot succeeds.

### Automated Test

The `autoload-in-c/` C rewrite boots in the rc700 emulator (which has
its own FDC emulation without this bug).  To test in MAME:

```bash
cd rcbios-in-c
make mame-maxi FORCE=1    # Patches C BIOS onto disk, boots in MAME
```

If the boot hangs (blank screen or repeated disk activity), ST1_ND is
likely set.  With the fix applied, the system boots to the CP/M prompt.

## Commit in Local Fork

```
commit 536e92b7391ea344d656020e2803e5f520598b69
Author: Thorbjørn Ravn Andersen <tra@ravnand.dk>
Date:   Fri Feb 27 21:41:03 2026 +0100

    upd765: fix Read Track setting spurious ST1 No Data status
```

## Why Upstream Rejected

(Record reasons here when known — e.g., concerns about side effects on
other machines, need for broader testing, or desire for a different
approach.)