# MAME Upstream PR Draft: UPD765 ST0 HD bit fix (PR #15032)

## PR title

upd765: Don't include head address in ST0 for seek/recalibrate

## PR body

Commit 272ec75ca61 ("upd765: reset st0 when starting a seek and fail if drive
isn't ready") changed `seek_start()` and `recalibrate_start()` to initialize
`fi.st0 = command[1] & 7`. The `& 7` mask preserves the HD bit (bit 2) from
the command byte, causing Sense Interrupt Status to return the head address
in ST0 after a seek completes.

The NEC µPD765 datasheet describes ST0 bit 2 (HD) as "the state of the head at
interrupt" but does not specify that it should reflect the head from a
Seek/Recalibrate command. The previous code initialized `fi.st0` to 0,
excluding the head bit. Note that the `seek_continue()` completion at
`SEEK_WAIT_DONE` already sets `fi.st0 |= ST0_SE | fi.id`, which correctly
includes only the Seek End flag and the drive unit select — not the head.

This change breaks the Regnecentralen RC702 boot PROM (roa375), which issues
Seek to head 1 during disk auto-detection and then checks ST0 against
`DRVSEL + 0x20` (seek end + drive select, no head bit). With `& 7`, ST0 is
0x24 instead of the expected 0x20, causing the seek result check to fail.
The PROM then marks the disk as single-sided, skips reading Side 1, and the
system crashes when the BIOS interrupt vector table (located in Side 1 data)
is missing.

This PROM works correctly on real RC702 hardware with a physical NEC µPD765A,
confirming that real hardware does not set HD in ST0 for Sense Interrupt Status
after Seek.

The fix restores the `& 3` mask (unit select only) while preserving the
not-ready early-exit behavior that was the primary intent of 272ec75ca61.

**Testing:**
- `rc702` (8" maxi, roa375 PROM): Was broken, now boots CP/M, DIR lists 21 files
  (tested with SW1711-I8.imd, Datamuseum.dk 8" image)
- `rc702mini` (5.25" mini, roa375 PROM): Was broken, now boots CP/M, DIR lists 21 files
  (tested with CPM_med_COMAL80.imd, Datamuseum.dk image with 1-based sectors)
- `rc703` (5.25" QD, rob357 PROM): Still boots, DIR lists 35 files (unaffected, uses uniform MFM)
- `cpc6128`: Not yet tested (requires full MAME build)
- `qx10`: Not yet tested (requires full MAME build)

---

## Bug report alternative (if PR is not appropriate)

### MAME version
0.286 (mame0286, HEAD at 4bfe11a2cf0)

### System information
macOS 15.4, Apple Silicon (arm64)

### Emulated system/software
Regnecentralen RC702 Piccolo (rc702mini), BIOS roa375, 5.25" floppy disk

### Incorrect behaviour
rc702mini fails to boot CP/M. The boot PROM's disk auto-detection routine
(DSKAUTO) seeks to head 1 and checks ST0 via Sense Interrupt Status. MAME
returns ST0=0x24 (SE=1, HD=1, US=0) but the PROM expects ST0=0x20 (SE=1,
HD=0, US=0). The seek result check fails, causing the PROM to skip reading
Side 1 of Track 0. The BIOS interrupt vector table (ITRTAB/CITAB at disk
offset 0x1780-0x17A5) is never loaded, so the I register is set to 0x00
instead of 0xEC, and the first interrupt after EI crashes into address 0x0000.

### Expected behaviour
ST0 after Seek + Sense Interrupt Status should be 0x20 (SE + drive select,
no head bit), matching real NEC µPD765A hardware behavior. The PROM should
successfully detect dual-sided media, read both sides of Track 0, and boot
CP/M.

### Steps to reproduce
```
./mame rc702mini -bios 0 -window -skip_gameinfo -flop1 CPM_med_COMAL80.imd
```
(CPM_med_COMAL80.imd is a Datamuseum.dk 5.25" mini image with 1-based sectors)

The system shows a blank screen and hangs. With `-log`, error.log shows
`SEEKERR: ST0=24 expected=20` from the PROM's FLSEEK routine.

### Additional details
The regression was introduced in commit 272ec75ca61 (2024-10-19). The previous
code initialized `fi.st0 = 0` in seek_start/recalibrate_start, which correctly
excluded the HD bit. The fix is to change `command[1] & 7` to `command[1] & 3`
in both `recalibrate_start()` (line 1696) and `seek_start()` (line 1712).

This PROM has been verified working on real RC702 hardware with a physical NEC
µPD765A FDC. The floooh/chips reference emulator (github.com/floooh/chips)
also uses `& 3` (drive select only) when building ST0 for seek completion.

---

## Diff

```diff
diff --git a/src/devices/machine/upd765.cpp b/src/devices/machine/upd765.cpp
index 161b0810ac3..3d211ce1b97 100644
--- a/src/devices/machine/upd765.cpp
+++ b/src/devices/machine/upd765.cpp
@@ -1693,7 +1693,7 @@ void upd765_family_device::recalibrate_start(floppy_info &fi)
 	fi.dir = 1;
 	fi.counter = recalibrate_steps;
 	fi.ready = get_ready(command[1] & 3);
-	fi.st0 = command[1] & 7;
+	fi.st0 = command[1] & 3;
 	if(fi.ready) {
 		seek_continue(fi);
 	} else {
@@ -1709,7 +1709,7 @@ void upd765_family_device::seek_start(floppy_info &fi)
 	fi.sub_state = SEEK_WAIT_STEP_TIME_DONE;
 	fi.dir = fi.pcn > command[2] ? 1 : 0;
 	fi.ready = get_ready(command[1] & 3);
-	fi.st0 = command[1] & 7;
+	fi.st0 = command[1] & 3;
 	if(fi.ready) {
 		seek_continue(fi);
 	} else {
```

## Testing checklist before filing

- [x] rc702 boots CP/M, DIR lists files (SW1711-I8.imd with roa375 PROM)
- [x] rc702mini boots CP/M, DIR lists files (CPM_med_COMAL80.imd with roa375 PROM)
- [x] rc703 still boots CP/M, DIR lists files (RC703_CPM_v2.2_r1.2.imd with rob357 PROM)
- [ ] cpc6128 — load files from disk (basic `cat` command)  *requires full MAME build + ROMs*
- [ ] qx10 — CP/M Plus boot (the system that motivated PR #12585)  *requires full MAME build + ROMs*
- [ ] specpl3e — load programs from disk  *requires full MAME build + ROMs*
- [ ] Any IBM PC floppy operations (seek to head 1 is common)  *requires full MAME build + ROMs*

Note: The RC702-subtarget build only includes rc702/rc702mini/rc703. Regression
testing on cpc6128/qx10/specpl3e/PC requires a full MAME build (slow, ~1 hour)
and ROM sets not available locally. These should be tested before filing the PR.

The change is low risk because:
- It only affects the initial ST0 value before seek/recalibrate completes
- The seek completion code (`SEEK_WAIT_DONE`) already sets `fi.st0 |= ST0_SE | fi.id`
  which uses fi.id (drive only, no head), so the final ST0 only differs in bit 2
- Most software doesn't check the HD bit in ST0 after seek — the RC702 PROM is
  unusual in doing a strict equality check
- Read/Write operations set ST0 from `command[1] & 7` in their own start functions
  (read_data_start, write_data_start), so data transfer ST0 is unaffected

## PR Review Discussion (2026-02-28)

### galibert (UPD765 emulation author) asked for details

On the `& 7` → `& 3` change at line 1696. Reply posted with:

1. **Mechanism**: `command[1]=0x04` (head=1, drive=0) → `fi.st0=0x04` → after
   `SEEK_WAIT_DONE` OR with `ST0_SE | fi.id` → `0x24`. Sense Interrupt Status
   returns `0x24` instead of expected `0x20`.

2. **Datasheet evidence** (NEC µPD765A, http://dunfield.classiccmp.org/r/765.pdf):
   - Seek description (p. 15): only mentions SE flag being set at completion
   - Table 5 (p. 16): Seek End interrupt defined as bits 5-7 + unit select (0-1);
     bit 2 (HD) not specified for Seek/Recalibrate
   - ST0 HD (p. 17): "the state of the head at Interrupt" — not further defined
     for non-data-transfer commands

3. **Other emulators**: floooh/chips uses `fifo[1] & 3` (excludes HD).
   Pre-regression MAME used `fi.st0 = 0`.

4. **Real hardware**: RC702 PROM works on physical NEC µPD765A with this ST0
   check. If real hardware set HD after Seek, the PROM would fail.

5. **Consistency**: `get_ready()` on the adjacent line already uses `& 3`.
