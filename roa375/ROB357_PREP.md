# ROB357 — Analysis and Unified Source Preparation

## Goal

Create a single assembly source with conditional assembly flags that can
generate both:
- **ROA375**: RC702 autoload PROM (MIC702/MIC703) — currently reconstructed
- **ROB357**: RC703 autoload PROM (MIC705) — binary available at `~/git/rc700/rob357.rom`

This follows the same pattern used for the BIOS source reconstruction
(`rcbios/src/BIOS.MAC` with `-DREL21 -DMINI` / `-DREL22 -DMINI` etc.).

## Source Files

| File | Description |
|------|-------------|
| `roa375.asm` | Reconstructed ROA375 source (verified against `roa375.rom`) |
| `rob358.mac` | Original ROB358 source from jbox.dk (MIC703, October 1982) |
| `roa375.rom` | Reference binary for ROA375 (2048 bytes) |
| `rob357.rom` | Reference binary for ROB357 (2048 bytes, at `~/git/rc700/`) |
| `rob358.rom` | Reference binary for ROB358 (2048 bytes, at `~/git/rc700/`) |

## ROM Assignment per Board (hardware manual page 12, pos. 66)

| Board | Model | PROM0 (autoload) | Notes |
|-------|-------|-------------------|-------|
| MIC702 | RC702 48KB | ROA375 | roa375.asm reconstructs this |
| MIC703 | RC702 64KB | ROA375 (or ROB358?) | rob358.mac says "RC700 AND RC703" |
| MIC704 | RC702 64KB | ROB237 | Unknown, no source |
| MIC705 | RC703 64KB | ROB357 | Binary analyzed below |

## ROM Binary Comparison

All three ROMs are 2048 bytes. Byte-level comparison:

| Comparison | Differing bytes | Percentage |
|------------|----------------|------------|
| ROA375 vs ROB357 | 1951 / 2048 | 95% different |
| ROA375 vs ROB358 | 1959 / 2048 | 96% different |
| ROB357 vs ROB358 | 1031 / 2048 | 50% different |

**ROB357 and ROB358 share the same codebase.** They have the same relocation
target (0xA000), stack (0xFFFF), code structure, and ~50% byte identity.
The differences are primarily shifted addresses from slightly different
code sizes, plus the key functional differences documented below.

**ROA375 is a fundamentally different codebase** from both ROB357 and ROB358
(95%+ different). Despite this, all three implement the same boot algorithm
and the functional differences are well-defined.

### Structural Comparison

| Aspect | ROA375 | ROB357 | ROB358 |
|--------|--------|--------|--------|
| Relocation target | 0x7000 | 0xA000 | 0xA000 |
| MOVADR (ROM offset) | 0x0068 | 0x0012 | 0x0012 |
| Payload size | 0x0758 (1880B) | 0x07EE (2030B) | 0x07EE (2030B) |
| Stack | 0xBFFF | 0xFFFF | 0xFFFF |
| RAMEN port | 0x18 | 0x19 | 0x19 |
| Work area | After code (~0x7320) | 0xB000+ (hardcoded) | 0xB000+ (hardcoded) |
| Banner text | " RC700" | " RC703" | " RC700" |
| Signature text | " RC702" | " RC703" | " RC700" |
| CTC2 init (HD) | No | Yes (ports 0x44-47) | Yes (ports 0x44-47) |
| HD boot section | No | Yes (WD1000) | Yes (WD1000) |
| COLOR CRT option | No | No | `COLOR EQU 0` |
| PROM1 sig check | Yes (at 0x2002) | No (direct JP 0x2000) | Not checked |
| Format tables | MAXIFMT/MINIFMT | In COMBUF/INITFL | In COMBUF/INITFL |

### Entry Point Comparison

All three ROMs begin with the same pattern:
```
DI ; LD SP,xxxx ; LD HL,MOVADR ; LD DE,dest ; LD BC,size ; LDIR ; JP autol
```

### Interrupt Vector Table

ROB357 and ROB358 have the IVT at runtime 0xA000 (12 DW entries = 24 bytes):

| Entry | ROB357 | ROB358 | Function |
|-------|--------|--------|----------|
| 0 | 0xA4B1 | 0xA4CC | DUMINT (EI; RETI) |
| 1 | 0xA4B4 | 0xA4CF | KBINT (keyboard) |
| 2-3 | DUMINT | DUMINT | Dummy |
| 4 | 0xA4D1 | 0xA4EC | HDINT (WD1000 hard disk) |
| 5-9 | DUMINT | DUMINT | Dummy |
| 10 | 0xA509 | 0xA524 | DISINT (CRT display) |
| 11 | 0xA4EA | 0xA505 | FLPINT (floppy) |

ROA375 has a completely different IVT structure at 0x7000 (18 DW entries).

## Key Finding: RC703 Mini Track 0 Format

**RESOLVED: RC703 mini uses uniform MFM 512B sectors on Track 0.**

This is the most important finding from the ROB357 binary analysis. It
resolves the "Track 0 capacity problem" identified earlier.

### ROB357 INITFL Sets MFM 512B for MINI

When INITFL detects a MINI drive (SW1 bit 7 = 1), it modifies the FDC
command buffer to:

```
COMBUF[0] = 0x46  (MFM READ DATA — not FM!)
COMBUF[5] = 0x02  (N=2 → 512 bytes/sector)
COMBUF[6] = 0x0A  (EOT=10 → 10 sectors/track)
COMBUF[7] = 0x0A  (GAP3=10)
COMBUF[8] = 0xFF  (DTL)
TRBYT     = 0x13FF (5119 = 10×512-1)
```

For MAXI drives, INITFL leaves the default COMBUF intact:
```
COMBUF[0] = 0x02  (FM READ TRACK — single density)
COMBUF[6] = 0x1A  (EOT=26 → 26 sectors/track)
COMBUF[5] = 0x00  (N=0 → 128 bytes/sector)
TRBYT     = 0x0CFF (3327 = 26×128-1)
```

### Track 0 Capacity Comparison

```
           RC702 (ROA375/ROB358)     RC703 (ROB357)
           ----------------------    ----------------
MINI T0S0: FM  16×128  = 2048B      MFM 10×512 = 5120B
MINI T0S1: MFM 16×256  = 4096B      MFM 10×512 = 5120B
MINI Total:              6144B                   10240B
LDIR needs:              9089B                    9089B
Result:    Deficit 2945B (junk)      Surplus 1151B ✓

MAXI T0S0: FM  26×128  = 3328B      FM  26×128 = 3328B
MAXI T0S1: MFM 26×256  = 6656B      MFM 26×256 = 6656B
MAXI Total:              9984B                    9984B
LDIR needs:              9089B                    9089B
Result:    Surplus 895B ✓            Surplus 895B ✓
```

**Conclusion**: RC703 mini does NOT use multi-density Track 0. Both sides
of T0 are MFM 512B. This gives 10240B total, more than enough for the
9089-byte BIOS LDIR. The hypothesis #2 from the original analysis was correct.

This also means the RC703_CPM_v2.2_r1.2.bin file (819200 bytes = 80 tracks
× 2 sides × 10 sectors × 512 bytes) represents the actual floppy layout
with uniform 512B sectors throughout, including Track 0.

### CPCOMB: Reading Track 0 Side 1

After reading T0S0 and checking signatures, the CP/M boot path reads T0S1:

**MINI** (at runtime 0xA1F2):
- Sets COMBUF+1 = 0x04 (drive 0, head 1)
- Sets cylinder = 0, record = 1
- Uses DE = 0x13FF (5119 = 10×512-1)
- Same MFM 512B command set by INITFL — no change needed

**MAXI** (at runtime 0xA204):
- Sets COMBUF = 0x42 (MFM READ, dual density)
- Sets COMBUF+1 = 0x04 (drive 0, head 1)
- Sets N = 1 (256B sectors), GAP3 = 0x0E, DTL = 0xFF
- Uses DE = 0x19FF (6655 = 26×256-1)
- Same as ROB358 MAXI path

## Signature Checks (Verified from Binary)

ROB357 performs three checks on disk data after reading T0S0:

| # | Bytes | Offset | String | Match action |
|---|-------|--------|--------|-------------|
| 1 | 5 | 2-6 | "RC703" + check offset 7 = '0' | ID-COMAL boot |
| 2 | 6 | 8-13 | "RC703 " (with trailing space) | CP/M boot |
| 3 | 5 | 8-12 | " RC70" (generic fallback) | CP/M boot |

Check 3 is a compatibility fallback — it matches any " RC70x" signature
at offset 8, allowing RC702 CP/M disks to boot on an RC703.

For comparison, ROA375 checks:
- 6 bytes at offset 2-7: " RC700" → ID-COMAL boot
- 6 bytes at offset 8-13: " RC702" → CP/M boot
- Fallback: PROM1 signature check at 0x2002

ROB357 does NOT check the PROM1 signature (no "BOOTIFOK" equivalent).
The T_FLG keyboard shortcut jumps directly to 0x2000 (ROM2/PROM1).

### Banner and Signature Strings

| ROM | Banner (on screen) | Disk signature |
|-----|-------------------|---------------|
| ROA375 | " RC700" | " RC702" |
| ROB357 | " RC703" | " RC703" |
| ROB358 | " RC700" | " RC700" |

ROB357's banner " RC703" is at runtime 0xA592 (ROM offset 0x05A4).
This is displayed via RCCOL/LDIR to the display buffer at DSPSTR (0xB020).

## Other Differences

### Keyboard Handler (KBINT)

ROB357 swaps the F and T key assignments compared to ROB358:

| Key | ROB358 | ROB357 |
|-----|--------|--------|
| F | Force floppy boot (FLBFLG=1) | Force test/PROM1 (T_FLG=1) |
| T | Force test/PROM1 (T_FLG=1) | Force floppy boot (FLBFLG=1) |

Both mask to uppercase (AND 0x5F) before comparing.

### Hard Disk Boot

Both ROB357 and ROB358 include a full WD1000 hard disk boot section
(absent in ROA375). This uses:
- CTC2 at ports 0x44-0x47 for HD interrupts
- WD1000 at ports 0x60-0x67 for HD commands
- DMA channel 0 for HD data transfer
- Reads configuration sector from cylinder 0, head 1, sector 15
- If HD bootable, reads 16 sectors from cylinder 0 head 0

The HD boot runs BEFORE floppy boot — it's the primary boot device.
FLBFLG forces skipping HD boot and going straight to floppy.

### ID-COMAL Boot Path

ROB357 has a simplified ID-COMAL boot path compared to ROB358:

**ROB358**: Two separate loops for MINI (IDRL1: reads both sides per track,
advances by MIBYT0+MINS1) and MAXI (IDRL2: reads one side, advances by SBID).

**ROB357**: Single loop — reads one side per track, advances by 0x0D00
(3328 = 26×128). No mini/maxi branching. This matches the MAXI byte count.
For MINI drives with MFM 512B format, the READ function transfers 5120 bytes
per call (set by TRBYT=0x13FF) but MEMADR only advances 3328 — possible
data overlap issue, suggesting ID-COMAL on RC703 mini may not have been
supported or tested.

### STSKFL (HD Taskfile Setup)

ROB357's STSKFL is different from ROB358's — it sends an additional
RESTORE command (0x11) to the WD1000 before setting up the taskfile.
The function is at runtime 0xA488 (ROM offset 0x049A):
```
OUT (HCMDRG),0x11  ; RESTORE command
OUT (HWPCMD),0      ; write precomp = 0
OUT (HSECCT),0      ; sector count = 0
OUT (HCYLLO),0      ; cylinder low = 0
OUT (HCYLHI),0      ; cylinder high = 0
OUT (HSECNO),C      ; sector number from C reg
OUT (HSZDHD),B      ; size/drive/head from B reg
```

ROB358 does not include the initial RESTORE in STSKFL.

## Variable Map (ROB357)

### In-code variables (runtime 0xA4xx)

| Address | Name | Description |
|---------|------|-------------|
| 0xA472 | COMBUF | FDC command buffer (9 bytes) |
| 0xA47B | TRBYT | DMA transfer byte count (word) |
| 0xA47D | FDCINI | FDC specify command buffer (4 bytes) |
| 0xA52F | FLBFLG | Force floppy boot flag |
| 0xA530 | T_FLG | Force test/PROM1 flag |
| 0xA531 | FL_FLG | Floppy interrupt flag |
| 0xA532 | HD_FLG | Hard disk interrupt flag |
| 0xA533 | HD_RDY | Hard disk ready flag |

### Work area variables (0xB000+, same as ROB358)

| Address | Name | Description |
|---------|------|-------------|
| 0xB000 | TRK | ID-COMAL read track count |
| 0xB003 | RSTAB | FDC result status area (10 bytes) |
| 0xB00D | ERFLAG | Hard disk error flag |
| 0xB00E | SECTOR | Hard disk sector read count |
| 0xB00F | MEMADR | Memory address pointer (DMA target) |
| 0xB011 | REPTIM | Repeat operation indicator |
| 0xB020 | DSPSTR | Display memory buffer (2000 bytes) |

## Function Address Map (ROB357)

| Runtime | ROM offset | Function | Description |
|---------|-----------|----------|-------------|
| 0xA018 | 0x002A | AUTOL | Main entry after relocation |
| 0xA0C3 | 0x00D5 | REPHD | Hard disk autoload start |
| 0xA19E | 0x01B0 | (end HD) | HD boot ends with JP (HL) |
| 0xA1A0 | 0x01B2 | FLOPPY | Floppy boot section entry |
| 0xA1EC | 0x01FE | CPCOMB | CP/M-COMAL boot (read T0S1) |
| 0xA247 | 0x0259 | IDBOOT | ID-COMAL boot section |
| 0xA2DA | 0x02EC | COMSTR | String compare utility |
| 0xA2E3 | 0x02F5 | READ | Read track procedure |
| 0xA303 | 0x0315 | INITFL | Initialize floppy |
| 0xA372 | 0x0384 | FLO2 | Wait FDC ready write |
| 0xA37B | 0x038D | FLO3 | Wait FDC ready read |
| 0xA384 | 0x0396 | FLO4 | Recalibrate drive 0 |
| 0xA393 | 0x03A5 | FLO6 | Sense interrupt status |
| 0xA3B0 | 0x03C2 | FLO7 | Seek track |
| 0xA3DB | 0x03ED | RSULT | Read FDC result |
| 0xA405 | 0x0417 | FDSTAR | Start mini motor |
| 0xA417 | 0x0429 | FDSTOP | Stop mini motor |
| 0xA421 | 0x0433 | FLRTRK | FDC read track command |
| 0xA433 | 0x0445 | READOK | Check reading OK |
| 0xA488 | 0x049A | STSKFL | HD set up taskfile |
| 0xA49D | 0x04AF | STPDMA | Set up DMA transfer |
| 0xA4B1 | 0x04C3 | DUMINT | Dummy ISR (EI; RETI) |
| 0xA4B4 | 0x04C6 | KBINT | Keyboard ISR |
| 0xA4D1 | 0x04E3 | HDINT | Hard disk ISR |
| 0xA4EA | 0x04FC | FLPINT | Floppy ISR |
| 0xA509 | 0x051B | DISINT | Display ISR |
| 0xA510 | 0x0522 | ERR | Error abort (display message, beep, halt) |

## Feasibility Assessment: Unified Source

### Challenge: ROA375 vs ROB357/ROB358 Are Different Codebases

The 95% byte difference between ROA375 and ROB357 reflects genuine
structural differences, not just address shifts:

1. **Code organization**: ROA375 has format tables (MAXIFMT/MINIFMT),
   auto-density detection (CALCTB, FMTLKP), and BOOT4 multi-format
   reading. ROB357/ROB358 use hardcoded COMBUF parameters and simpler
   read procedures.

2. **Boot priority**: ROA375 does floppy-first boot (no HD support).
   ROB357/ROB358 do HD-first boot with floppy as fallback.

3. **Variable placement**: ROA375 puts variables immediately after code.
   ROB357/ROB358 use a fixed work area at 0xB000.

4. **Relocation**: ROA375 relocates to 0x7000 with minimal ROM-phase
   code. ROB357/ROB358 relocate to 0xA000 with a much shorter ROM
   preamble (only 18 bytes vs 104 bytes).

### Recommended Approach

A unified source from ROA375 would require extensive conditionals — nearly
every function would need `IFDEF RC703` blocks. A better approach may be:

**Option A**: Use ROB358.MAC as the base for ROB357 reconstruction (50%
match), then maintain ROA375 and ROB357 as separate-but-related sources.

**Option B**: Reconstruct ROB357 from ROB358.MAC first (since they share
the same codebase), verify against rob357.rom, then assess what can be
shared with ROA375 via include files.

## Remaining Prerequisites

1. ~~ROB357 binary dump~~ — **DONE** (`~/git/rc700/rob357.rom`, 2048 bytes)

2. **RC703 floppy IMD image** — to test boot in emulator. The existing
   RC703_CPM_v2.2_r1.2.bin (819200 bytes) should be convertible to IMD
   now that the format is known: uniform 512B MFM, 80 tracks, 10 sectors,
   DS/DD.

3. ~~Resolve T0 capacity question~~ — **RESOLVED**: RC703 mini uses uniform
   MFM 512B sectors on T0 (no FM). 10×512×2 = 10240B > 9089B needed.

4. **ROB358 relationship**: ROB358.MAC is the closest source to ROB357
   (50% byte match). Both target 0xA000. ROB358 uses RC702 disk geometry
   (16-sector mini). ROB357 is a later revision with RC703 geometry
   (10-sector 512B mini) and " RC703" signatures. The header "RC700 AND
   RC703" in ROB358.MAC may refer to disk compatibility rather than
   hardware targets.

## Detailed Difference List: ROB357 vs ROB358

The 1031 differing bytes fall into 60 runs. Most are 1-2 byte differences
(shifted addresses from code size changes). The significant functional
differences are:

1. **IVT entries** (addresses differ due to code size): 12 bytes
2. **KBINT F/T key swap**: F→T_FLG, T→FLBFLG (reversed from ROB358)
3. **INITFL MINI format**: MFM 512B vs FM 128B (the key difference)
4. **CPCOMB MINI path**: different transfer sizes (0x13FF vs 0x0FFF)
5. **Signature checks**: "RC703" vs "RC700", plus fallback " RC70" check
6. **Banner string**: " RC703" vs " RC700"
7. **STSKFL**: includes RESTORE command before taskfile setup
8. **ID-COMAL path**: simplified to single loop (no mini/maxi split)
9. **Error messages**: Same text, different addresses
