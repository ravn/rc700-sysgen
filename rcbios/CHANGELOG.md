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

## RC702E (rel.2.01 mini, rel.2.20 QD) — Source Reconstruction

Two variants of an RC702E-specific BIOS, assembled from a single modular
source tree in `src-rc702e/` using `-DREL201` / `-DREL220`.

### RC702E hardware differences from RC700

- **RAM disk**: DMA-based RAM expansion disk (ports 0xEE/0xEF area), replacing
  the hard disk entirely
- **Clock display**: Danish-format clock shown on top-right of terminal screen
- **No hard disk**: WD1000 support removed; CTC2 slots reserved but unused
- **10 DPBs**: MINI, MAXI, QD, and RAM disk variants
- **VERIFY utility** (rel.2.20 only): 4096-byte embedded VERIFY/BLOCKS.BAD

### Memory map

| Variant | ORG | Jump table | Size |
|---------|-----|-----------|------|
| rel.2.01 (mini) | 0xD700 | 0xDA00 | 5504 bytes |
| rel.2.20 (QD) | 0xD480 | 0xD780 | 9600 bytes |

### Interrupt table

Device assignment identical to REL20 HARDDISK (56K) BIOS:
- CTC1 CH.2 (0x04) → ISR_CRT (display)
- CTC1 CH.3 (0x06) → FDC ISR
- CTC2 slots (0x08–0x0E) → ISR_DEFAULT (unused, no HD)
- SIO base vector 0x10 (same as REL20 HARDDISK)
- PIO: KEYIT (0x20 = keyboard), PARIN (0x22 = parallel)

### Work area (0xFFD0–0xFFFF, 48 bytes after 80×25 display RAM)

Display RAM: 0xF800–0xFFCF (2000 bytes). Work area variables:

| Address | Label | Description |
|---------|-------|-------------|
| 0xFFD1 | CURX | Cursor X (column) |
| 0xFFD2 | CURY | Cursor Y (row×80, word) |
| 0xFFD4 | CURSY | CRT row-within-char counter |
| 0xFFD5 | LOCBUF | Scroll source pointer (word) |
| 0xFFD7 | XFLG | Display mode / XY escape state |
| 0xFFD8 | LOCAD | Screen address for CONOUT (word) |
| 0xFFDA | USHER | Character being output |
| 0xFFDB–0xFFDD | — | Unused (REL20: BGFLG/LOCBBU selective-clear feature) |
| 0xFFDE | ADR0 | XY escape first coordinate |
| 0xFFDF | TIMER1 | Warm-boot countdown (word) |
| 0xFFE1 | TIMER2 | Motor stop countdown (word) |
| 0xFFE3 | DELCNT | TIMER2 reload value (word) |
| 0xFFE5 | WARMJP | FDC seek delay counter (word, NOT a JP instruction) |
| 0xFFE7 | FDTIMO | JP opcode 0xC3 — self-modifying stub written by HALT |
| 0xFFE8 | — | JP target (WBOOT); ISR_CRT calls when TIMER1 = 0 |
| 0xFFEA | STPTIM | TIMER2 reload from boot config (word) |
| 0xFFEC | CLKTIM | Clock/screen-blank timer (word) |
| 0xFFFC | RTCCNT | SETWARM save area for DE |
| 0xFFFE | — | SETWARM save area for HL |

### Source notes

- E220's `code008` block (~12KB, 0xD82B–0xE45F) merges all of
  CPMBOOT+SIO+DISPLAY+FLOPPY+RAMDISK; those modules are stubs for REL220
- `MOTORTIMER` is a code function label in FLOPPY.MAC (REL201, ~0xE608);
  for REL220 it is an EQU alias pointing to the FDTIMO RAM slot (0xFFE7)
