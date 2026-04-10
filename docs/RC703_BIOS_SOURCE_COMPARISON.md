# RC703 Original Source vs RC702 Reconstructed BIOS — Comparison Findings

**Date:** 2026-04-10
**Context:** The RC703 BIOS source in `rc703-div-bios-typer/` is original authored code
(Release 1.1, 83.09.14, with TFj mods 1987). The RC702 BIOS in `rcbios/src/` is
reverse-engineered from binary images. Both reconstruct byte-exactly against their
respective reference binaries (`make verify` passes all 13 variants).

This document records differences found during comparison that may warrant
investigation or future work.

---

## HIGH Priority — Worth investigating against binaries

### 1. FLO4: Missing double-recalibrate (FLOPPY.MAC)

The RC703 source has a double-recalibrate sequence in FLO4: after the first
recalibrate, it checks ST0 bit 4 (Equipment Check — track 0 not found within
77 steps). If set, it recalibrates again. This handles drives with more than
77 tracks (e.g., 80-track 96-tpi 5.25" mini drives) where a single recalibrate
from track 79 wouldn't reach track 0.

The RC702 reconstruction does a single recalibrate only. If this is accurate to
the binary, it means the RC702 BIOS has a latent bug for 96-tpi drives far from
track 0. If the RC702 binary does have the double-recalibrate, the reconstruction
is missing it.

**Files:** `rc703-div-bios-typer/floppy.mac:671-685` vs `rcbios/src/FLOPPY.MAC:725-732`

### 2. Missing XHOME before HD config sector read (INIT.MAC)

The RC703 source calls `CALL XHOME` between `CALL SELD` and `CALL SETT` when
reading the hard disk configuration sector. This ensures the drive heads are at
a known position before seeking. The RC702 reconstruction goes directly from
SELD to SETT with no XHOME.

Without XHOME, the WD1000 step rate may be uninitialized on the first hard disk
access after restore, potentially causing seek failures.

**Files:** `rc703-div-bios-typer/init.mac:327` vs `rcbios/src/INIT.MAC:347-349`

### 3. FDPROG offset for head load time (INIT.MAC)

The RC703 patches `FDPROG+3` (the HLT/ND byte of the FDC SPECIFY command) with
`12*2+0` (HLT=24ms, DMA mode). The RC702 reconstruction patches `FDPROG+2`
(the SRT/HUT byte) with `0Fh` (SRT=0=fastest, HUT=15=240ms).

These patch different bytes of the SPECIFY command. One of them may be wrong,
or they may reflect different FDPROG table layouts between versions. Needs
verification against the actual binary bytes at this offset.

**Files:** `rc703-div-bios-typer/init.mac:167-169` vs `rcbios/src/INIT.MAC:185-186`

### 4. HD restore stepping rate (INIT.MAC)

The RC703 uses `LD B,0101B` (5 = conservative step rate) for the initial HD
restore command. The RC702 reconstruction uses `LD B,1` (fastest step rate).
The WD1000 RESTORE command encodes the step rate in the low 4 bits.

A too-fast step rate could cause the restore to fail if the drive can't keep
up. This needs verification — if the binary has 01h, the reconstruction is
correct; if it has 05h, it's wrong.

**Files:** `rc703-div-bios-typer/init.mac:291` vs `rcbios/src/INIT.MAC:312`

---

## MEDIUM Priority — Documented differences

### 5. FDI4 label typo (CPMBOOT.MAC)

The reconstruction has `FDI4` (capital I) where the RC703 original has `FD14`
(number 1, for drive format index 14). Since the FD0–FD15 array is accessed
by computed offset rather than by label, this doesn't affect the binary. Still
worth fixing for consistency.

**File:** `rcbios/src/CPMBOOT.MAC:59`

### 6. MOVUP/MOVDWN: Different zero-length check (DISPLAY.MAC)

RC703 uses the clean `LD A,B / OR C / RET Z` pattern to skip LDIR when BC=0.
The RC702 reconstruction uses a more complex two-comparison pattern
(`CP C / JP Z,... / CP B / JP NZ,...`). Both are functionally identical.
If the reconstruction matches the binary, this is just a less elegant original.

### 7. ESCK: Double-ADD vs single-ADD (DISPLAY.MAC)

RC703 computes `DSPSTR+79+RCTAD` in one ADD (loads DE=DSPSTR+79). The RC702
uses two ADDs (first adds DSPSTR, then adds 79). Both correct, the RC703
version is a minor optimization.

### 8. Config sector byte count: 15 vs 19 (INIT.MAC)

RC703 copies 15 bytes from the HD configuration sector. RC702 copies 19 bytes.
Could be an intentional version difference (RC702 has more config fields) or
one version is wrong. The extra 4 bytes would overwrite whatever follows the
config area.

### 9. Track offset computation algorithm (INIT.MAC)

The RC703 uses IY-indexed format descriptor tables (FDF5–FDF10, TRKSIZ) to
compute track offsets. The RC702 uses hardcoded magic constants (029H, 052H,
0A5H). Both should produce the same results if the constants match the table
values, but the RC702 approach is less maintainable.

### 10. BOOT: Hardcoded drive 2 vs register C (CPMBOOT.MAC)

RC703: `LD A,C / LD (CDISK),A` — sets current disk from register C (flexible).
RC702: `LD A,2 / LD (CDISK),A` — hardcodes drive C: (2). In practice the HD
boot drive is always C:, so this is functionally equivalent.

### 11. Mystery `DB 0,0,0` bytes (CPMBOOT.MAC)

The RC702 reconstruction has 3 mystery zero bytes (line 96, marked `; ???`)
between the jump table area and PCHSAV. The RC703 source has no such padding.
Purpose unknown — could be removed code, alignment, or a feature stub.

---

## Intentional version differences (not bugs)

These are confirmed differences between RC703 rel.1.1 and RC702 rel.2.x that
are expected and correct for their respective platforms:

- **Machine ID**: `RC703` vs `RC702` in signon and Track 0 header
- **MTYPE**: 3 (RC703) vs 0 (RC700)
- **FDC SPECIFY**: 0EAH (TFj slower drives) vs 0DFH (factory default)
- **Motor stop timer**: 500 ticks (TFj) vs 250 ticks (factory)
- **INFD0/INFD1**: 16 (mini, TFj) vs 08 (maxi, factory)
- **Color support**: RC703 has Pcolour, BGSTAR bit tables, 8-color attributes; RC702 does not
- **RC763B Rodime 202**: RC703 has detection and DPB patching; RC702 does not
- **Partner drive support**: RC703/TFj adds YD-380 via QQMM/QQMP/QQPP variants
- **REL30 enhancements**: Ring buffers (PIO, SIO), 8-N-1 serial, 38400 baud, unrolled scroll — RC702 only
- **CTC2 entries**: Unconditional in RC703 vs `IFDEF HARDDISK` in RC702
- **JR vs JP**: RC703 uses JR (2 bytes) in several places where RC702 uses JP (3 bytes)
- **DJNZ vs DEC B/JP NZ**: RC703 uses DJNZ; some RC702 versions use the expanded form

---

## Actions taken

- Comments from the RC703 original source were backported into the RC702
  reconstruction (`rcbios/src/`) where they describe shared behavior
- All 13 BIOS variants verified byte-exact after comment additions
- RC703 source files cleaned: Ctrl-Z stripped, WordStar high-bit formatting
  removed from bios.doc, trailing garbage removed from copifil.asm
