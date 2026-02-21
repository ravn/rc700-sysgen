# RC702 CP/M BIOS Version Changelog

## rel.1.4 (58K, 8" maxi, floppy-only)

First known version. 5632-byte BIOS at E200H, leaving 58K for CP/M TPA.
No hard disk support. Only floppy drives A and B.

Signon: `58K CP/M VERS 2.2`

## rel.2.1 (56K, 5.25" mini, HD support)

Major upgrade adding Winchester hard disk support, growing the BIOS to
7680 bytes and reducing TPA to 56K.

### Hard disk support added
- WD1000 Winchester disk controller driver (HARDDSK.MAC)
- CTC2 initialization for HD interrupt handling
- Up to 7 HD partition configurations (0.3-8MB units)
- HD online detection and configuration sector read at cold boot
- BDOS patching for HD warm boot (PCHBDS/PCHFIX)
- DMA channel 0 setup for HD transfers

### Memory map change
- BIOS grown from 5632 to 7680 bytes (+2KB for HD code)
- TPA reduced from 58K to 56K
- BIOS base moved from E200H to DA00H

### Boot enhancements
- BOOTD flag: warm/cold boot from floppy or hard disk
- WBFLAG: warm boot detection, CCP command buffer preservation
- HD configuration sector read with fallback to floppy defaults
- Drive probe on cold boot (check if drive B online)

### LINSEL improvement
- Added RESLIN wait loop: waits for SIO transmitter buffer empty before
  DTR/RTS manipulation on RC791 Line Selector. Prevents signal corruption
  if data still being transmitted.

### CONFI.COM infrastructure
- Configuration block layout in Track 0 for CONFI.COM utility
- Conversion table support (7 languages)
- Extended BIOS entries: WFITR, READS, LINSEL, EXIT, CLOCK, HRDFMT

### Signon change
- From `58K CP/M VERS 2.2` to `RC700   56k CP/M vers.2.2   rel.2.1`

## rel.2.2 (56K, 5.25" mini, HD+bugfixes)

Bugfix release addressing LINSEL timing and HD head selection issues.

### Bug fix: LINSEL race condition
- Added `LD HL,2 / CALL WAITD` delay (+6 bytes) between releasing a line
  and selecting a new one on the RC791 Line Selector. Without this delay,
  the selector might not register the line release before the new selection
  begins, causing connection failures.

### Bug fix: STSKFL head selection
- Replaced UNK1-4 partition boundary calculation (48 bytes) with simpler
  HDHFLG check + `SET 7,C` (21 bytes). The original code computed head
  select bits by iterating through partition size variables. The new code
  uses a single flag (HDHFLG) set during HD configuration, fixing incorrect
  head selection on some partition layouts.

### New function: HDSYNC
- Added 16-byte helper: `CALL WAITHD`, read/clear ERFLAG, load MHDTSR
  status mirrors. Centralizes post-HD-operation status handling.

### Drive D disabled
- TRKOFF for drive D changed from 27 to 255 (not configured).

### Signon
- Changed from `rel.2.1` to `rel. 2.2` (+1 byte, note added space)
