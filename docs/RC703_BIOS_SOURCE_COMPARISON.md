# RC703 Original Source vs RC702 Reconstructed BIOS — Comparison Findings

**Date:** 2026-04-10
**Context:** The RC703 BIOS source in `rc703-div-bios-typer/` is original authored code
(Release 1.1, 83.09.14, with TFj mods 1987). The RC702 BIOS in `rcbios/src/` is
reverse-engineered from binary images. Both reconstruct byte-exactly against their
respective reference binaries (`make verify` passes all 13 variants).

**Important caveat:** The RC703 source is likely a heavily bugfixed personal fork
by Torben Fjerdingstad, diverging from rel.1.1 in 1983 and evolving independently
through 1987. The RC702 releases (rel.2.0–2.3) evolved on a separate track. Neither
source is inherently "more correct" — they represent two independent development
lines from the same ancestor. Differences may be: (a) TFj bug fixes not in the
RC702 line, (b) RC702 improvements not backported to TFj's fork, (c) RC703-specific
hardware adaptations, or (d) TFj site-specific preferences.

This document records differences found during comparison that may warrant
investigation or future work. Items are ranked by potential impact, not by
certainty that either version is wrong.

---

## HIGH Priority — Worth investigating against binaries

These differences have the highest potential functional impact. They may
reflect TFj bug fixes for problems he encountered on his RC703, or they
may be RC703-specific adaptations that don't apply to the RC702.

### 1. FLO4: Missing double-recalibrate (FLOPPY.MAC)

**Verdict: RC703-specific enhancement, not an RC702 bug.**

The RC703 source has a double-recalibrate sequence in FLO4: after the first
recalibrate, it checks ST0 bit 4 (Equipment Check — track 0 not found within
77 steps). If set, it recalibrates again. This handles 80-track YD-380
partner drives where a single 77-step recalibrate may not reach track 0.

The RC702 does a single recalibrate only. This is correct for RC702 hardware:
it only had 40-track (8") and 35-track (5.25") drives where 77 steps always
suffices. TFj added the double-recalibrate specifically for his partner drives.
No RC702 variant has this code.

**Files:** `rc703-div-bios-typer/floppy.mac:671-685` vs `rcbios/src/FLOPPY.MAC:725-732`

### 2. Missing XHOME before HD config sector read (INIT.MAC)

**Verdict: TFj defensive fix, not a known RC702 failure.**

The RC703 source calls `CALL XHOME` between `CALL SELD` and `CALL SETT` when
reading the HD configuration sector. The comment says "issue seek_command to
set step-rate". The RC702 skips this, relying on HRDRST (which runs just
above) having already configured the WD1000 step rate. This works because
SELD selects the HD (drive C:) and HRDRST already initialized the controller.
TFj's XHOME is belt-and-suspenders — ensures the step rate is set regardless
of what HRDRST left behind. No RC702 variant has the XHOME call.

**Files:** `rc703-div-bios-typer/init.mac:327` vs `rcbios/src/INIT.MAC:347-349`

### 3. FDPROG offset for head load time (INIT.MAC)

**Verdict: Likely a real bug in the RC702 binary (or a misattributed comment).**

The FDPROG table layout is identical in both versions:
```
+0: DB 3       (byte count)
+1: DB 003H    (SPECIFY command)
+2: DB 0DFH    (SRT/HUT: step rate / head unload time)
+3: DB 028H    (HLT/DMA: head load time / DMA mode)
```

The RC703 patches `FDPROG+3` (HLT/DMA byte) with `12*2+0` = 24ms head load
time, DMA mode. The RC702 patches `FDPROG+2` (SRT/HUT byte) with `0Fh` =
SRT=0 (16ms step), HUT=F (240ms unload). But the RC702 comment says
"CHANGE HEAD LOAD TIME" with HLT bit-field documentation — that description
belongs to FDPROG+3, not FDPROG+2. Either the offset or the comment is wrong.

The RC702 binary genuinely has FDPROG+2 (verified by byte-exact reconstruction).
This means either the RC702 intentionally patches the step rate for mini drives
(and the comment is copied from an older source that patched HLT), or the
original RC702 BIOS has a latent bug where the wrong SPECIFY byte gets
overwritten on mini floppy systems. Added a NOTE comment to the reconstruction.

**Files:** `rc703-div-bios-typer/init.mac:167-169` vs `rcbios/src/INIT.MAC:185-186`

### 4. HD restore stepping rate (INIT.MAC)

**Verdict: Genuine version difference. RC702 comment was wrong.**

The RC702 binary has `LD B,1` (step rate 1 = 0.5ms, fastest explicit rate).
The RC703 source has `LD B,5` (step rate 5 = 2.5ms, conservative). The
ROB358 autoload PROM also uses step rate 1 (`HDRES EQU 011H`).

Both versions carried the comment "STEPPING RATE (2,5 MILL.SECS)" but 2.5ms
corresponds to rate 5, not rate 1. The RC702 comment has been corrected to
"0.5 MS" with a note about the RC703 difference.

The RC702 uses the fastest rate, relying on the drive being able to keep up.
The RC703 plays it safer — appropriate for TFj's setup where the drive type
may vary. Not a reconstruction error, just a real version difference.

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
