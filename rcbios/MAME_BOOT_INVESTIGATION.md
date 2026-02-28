# MAME RC702 Boot Investigation

Investigation into why the MAME rc702 driver variants originally failed to boot CP/M,
and the fixes applied to make all three variants work.

## Status: ALL VARIANTS BOOT CP/M

All three machine variants boot CP/M and pass the DIR test (files listed at A> prompt):

| Variant | Disk Image | Signon | Files |
|---------|-----------|--------|-------|
| `rc702` (8" maxi) | SW1711-I8.imd | `RC700   56k CP/M vers.2.2   rel. 2.3` | 21 |
| `rc702mini` (5.25" DD) | CPM_med_COMAL80.imd | `RC700   56k CP/M vers.2.2   rel.2.1` | 21 |
| `rc703` (5.25" QD) | RC703_CPM_v2.2_r1.2.imd | `RC703  56k CP/M vers. 2.2  rel. 1.2` | 35 |

`MACHINE_NOT_WORKING` flag removed from all three COMP entries.

## Original Problem

**rc703**: Booted to CP/M prompt (`-bios 1` with rob357 PROM, uniform MFM disk images).

**rc702mini** (5.25" mini): Crashed immediately after EI instruction in INIT.
Execution fell to address 0x0000 (configuration data area).

**rc702** (8" maxi): Same crash behavior as rc702mini.

## Root Cause (Confirmed)

**The PROM fails to read Track 0 Side 1 (MFM) in MAME.** MAME debug trace confirms
that the entire MFM region at 0x0800-0x17FF is all zeros when INIT starts:

```
=== INIT ENTRY: checking memory contents ===
Side 0 FM start @0000: 80 02 00 00 00 00 00 00       ← correct (entry word)
Side 0 FM @0008: 20 52 43 37 30 32 00 00 (' RC702')  ← correct (signature)
Side 0 FM end @07F8: 09 C4 85 6F 7E B7 CA 03         ← correct (BIOS data)
Side 1 MFM start @0800: 00 00 00 00 00 00 00 00       ← ALL ZEROS
Side 1 MFM @0900-@1400: 00 00 00 00 ...               ← ALL ZEROS
Side 1 MFM @1780: 00 00 00 00 00 00 00 00 (ITRTAB)   ← ALL ZEROS
Side 1 MFM end @17F8: 00 00 00 00 00 00 00 00         ← ALL ZEROS
```

And consequently:
```
=== AT EI === I=00 SP=0080 CITAB=0000 ITRTAB=0000 0000 0000 0000
=== HIT 0000 === I=00 SP=007E ret=D888
```

The PROM reads Side 0 FM (16 sectors × 128 bytes = 2048 bytes) successfully, but
**completely fails** to read Side 1 MFM (16 sectors × 256 bytes = 4096 bytes).

Since CITAB+1 is zero, I=0x00. The IM2 vector table points to 0x0000 (INIPARMS
configuration data). The first CRT interrupt reads a zero ISR address from 0x0004,
jumping to 0x0000 and crashing.

The FM→MFM density transition on Track 0 is the specific failure point in MAME's
UPD765A/FDC emulation. RC703 avoids this entirely because its disk format uses
uniform MFM on all tracks (no density switching).

## Boot Sequence Overview

```
PROM (roa375)              BIOS (INIT.MAC)              BIOS (CPMBOOT.MAC)
─────────────              ──────────────               ──────────────────
1. Self-relocate to 0x7000
2. Init PIO, CTC, DMA, CRT
3. Read Track 0 into 0x0000
   Side 0 (FM) + Side 1 (MFM)
4. Check signature " RC702"
5. Read entry word from 0x0000
6. JP (HL) → 0x0280
                           7. DI
                           8. LDIR 9089 bytes:
                              0x0000 → 0xD480
                           9. LDIR conv tables:
                              0xD580 → 0xF680
                          10. LD I,(CITAB+1)  ← should load 0xEC
                          11. IM 2
                          12. Program PIO, CTC1, CTC2,
                              SIO, DMA, CRT
                          13. EI  ← CRASH HERE
                          14. Hard disk check loop
                              (times out, no HD)
                                                        15. BOOT: print signon
                                                        16. WBOOT: read Track 1
                                                            (CCP+BDOS → 0xC400)
                                                        17. JP CCP
```

Steps 15-17 never execute because the crash happens at step 13.

## Track 0 Data Available to INIT

The PROM reads only Track 0 (both sides) before jumping to the BIOS entry point.
The amount of data read depends on the disk format:

| Format | Side 0 (FM) | Side 1 (MFM) | Total | LDIR needs |
|--------|-------------|---------------|-------|------------|
| 5.25" mini | 16 × 128 = 2048 | 16 × 256 = 4096 | **6144** | 9089 |
| 8" maxi | 26 × 128 = 3328 | 26 × 256 = 6656 | **9984** | 9089 |
| RC703 QD | 10 × 512 = 5120 | 10 × 512 = 5120 | **10240** | 9089 |

For mini, only 6144 of the 9089 bytes are valid disk data. The remaining 2945 bytes
(destination 0xEC80-0xF800) are whatever was in RAM — typically zeros after reset.
This is by design: the garbage region contains only runtime variables and the display
buffer (DSPSTR at 0xF800), which INIT clears explicitly before use.

### Critical data within the valid region

The interrupt vector table and I register value are near the end of the valid range:

| Symbol | Runtime addr | Source offset | Within 6144B? |
|--------|-------------|---------------|---------------|
| ITRTAB | 0xEC00 | 0x1780 | Yes (byte 6016) |
| CITAB | 0xEC24 | 0x17A4 | Yes (byte 6052) |
| CITAB+1 (I reg) | 0xEC25 | 0x17A5 | Yes (byte 6053) |

The I register byte (0xEC) is in the **last sector** (sector 16) of Side 1 MFM data.
If this sector is not read correctly, memory at 0x17A5 remains zero → I=0x00 →
vector table at 0x0000 instead of 0xEC00.

## Verified Disk Data (CPM_med_COMAL80.imd)

Extracted raw Track 0 with `imd2raw.py` and verified:

```
Offset 0x0000-0x0001: 80 02  → entry word = 0x0280 (DI instruction)  ✓
Offset 0x0008-0x000D: 20 52 43 37 30 32  → " RC702" signature       ✓
Offset 0x1780-0x1781: E8 EB  → ITRTAB[0] = 0xEBE8 (DUMITR)          ✓
Offset 0x1784-0x1785: 42 E2  → ITRTAB[2] = 0xE242 (DSPITR)          ✓
Offset 0x1786-0x1787: D4 E7  → ITRTAB[3] = 0xE7D4 (FLITR)           ✓
Offset 0x17A4-0x17A5: 00 EC  → CITAB = 0xEC00 (ITRTAB base)         ✓
                               I register byte = 0xEC                 ✓
```

All interrupt vectors on disk are correct and non-zero.

## The Crash

After EI at 0xD885, the first interrupt fires (CTC1 channel 2, driven by the CRT
controller). The CPU enters the IM2 interrupt sequence:

1. Read 8-bit vector byte from interrupting device
2. Form address: I_register × 256 + vector_byte
3. Read 16-bit ISR address from that memory location
4. Push PC, jump to ISR

If I=0xEC and vector_byte=0x04 (CTC1 ch.2): reads 0xEC04 → DSPITR (0xE242). Correct.

If I=0x00 and vector_byte=0x04: reads 0x0004 → bytes from INIPARMS config area.
The config area at offset 0x0004-0x0007 is padding zeros → ISR address = 0x0000.
CPU jumps to 0x0000 which is `DW CBOOT` = the entry word (0x80, 0x02), which
disassembles as meaningless instructions and quickly crashes.

**Observed behavior matches I=0x00** — execution in the configuration data area,
consistent with the interrupt vector table pointing to INIPARMS instead of ITRTAB.

## Interrupt Vector Architecture

### BIOS vector table layout (INTTAB.MAC, HARDDISK variants)

The BIOS (rel.2.1/2.2/2.3 with HARDDISK defined) allocates 18 vector entries:

```
Offset  Device     Channel    ISR
──────  ─────────  ─────────  ──────
0x00    CTC1       Ch.0       DUMITR  (SIO-A baud)
0x02    CTC1       Ch.1       DUMITR  (SIO-B baud)
0x04    CTC1       Ch.2       DSPITR  (display)
0x06    CTC1       Ch.3       FLITR   (floppy)
0x08    CTC2       Ch.0       HDITR   (WD1000 hard disk)
0x0A    CTC2       Ch.1       DUMITR
0x0C    CTC2       Ch.2       DUMITR
0x0E    CTC2       Ch.3       DUMITR
0x10    SIO        Ch.B TX    TXB
0x12    SIO        Ch.B Ext   EXTSTB
0x14    SIO        Ch.B Rx    RCB
0x16    SIO        Ch.B Spc   SPECB
0x18    SIO        Ch.A TX    TXA
0x1A    SIO        Ch.A Ext   EXTSTA
0x1C    SIO        Ch.A Rx    RCA
0x1E    SIO        Ch.A Spc   SPECA
0x20    PIO        Port A     KEYIT
0x22    PIO        Port B     PARIN
```

### Software-programmed vector bases (INIT.MAC)

```
CTC1 vector base:  0x00  (OUT to port 0x0C)
CTC2 vector base:  0x08  (OUT to port 0x44 — UNMAPPED in MAME)
SIO  WR2 vector:   0x10  (OTIR to SIO-B control)
PIO  port A:       0x20  (OUT to PIO-A control)
PIO  port B:       0x22  (OUT to PIO-B control)
```

### MAME daisy chain

```cpp
static const z80_daisy_config daisy_chain_intf[] = {
    { "ctc1" },    // CTC1 — vector base programmed to 0x00
    { "sio1" },    // SIO  — WR2 programmed to 0x10
    { "pio" },     // PIO  — vectors programmed to 0x20/0x22
    { nullptr }
};
```

No CTC2 in the daisy chain. The BIOS writes to CTC2 ports 0x44-0x47 during INIT,
but these are unmapped in MAME — the writes are silently ignored. The CTC2 vector
entries (0x08-0x0E) remain in the table but are never used since no device will
generate those vector bytes.

The daisy chain determines **priority order** only; the actual vector bytes on the
data bus come from each device's programmed registers. The absence of CTC2 from the
daisy chain does not affect the vector numbering of other devices.

## Why RC703 Boots

The RC703 uses uniform MFM (10 sectors × 512 bytes × 2 sides = 10240 bytes on Track 0).
This exceeds the 9089-byte LDIR requirement, so ALL data including ITRTAB and CITAB
is present in memory when INIT runs.

Additionally, the RC703 BIOS (rob357) does NOT define HARDDISK, so:
- No CTC2 programming (ports 0x44-0x47 not accessed)
- SIO WR2 = 0x08 (no CTC2 gap)
- PIO vectors = 0x18/0x1A
- Smaller vector table (14 entries instead of 18)
- INIT jumps directly to BIOS after IDT, skipping the HD check loop

## Confirmed Root Cause: MAME UPD765 ST0 Head Bit Regression

### The Failure Chain

The PROM's DSKAUTO routine auto-detects disk format by seeking to each head and
reading sector IDs. When DSKAUTO seeks to head 1, the following happens:

```
PROM FLSEEK: Seek command with D=0x04 (head=1, drive=0), E=0x00 (cyl=0)
MAME UPD765: Seek completes, Sense Interrupt Status → ST0=0x24
PROM FLSEEK: Expected ST0 = DRVSEL + 0x20 = 0x20
             Actual ST0 = 0x24 (0x20 + head bit)
             0x24 ≠ 0x20 → SEEKERR → DSKFAIL
```

Because DSKAUTO fails on head 1, DISKBITS bit 1 (dual-sided) is never set.
RDTRK0 only reads Side 0 FM (2048 bytes). Side 1 MFM data remains all zeros.

### The Regression in MAME

**Commit**: `272ec75ca61` — "upd765: reset st0 when starting a seek and fail if
drive isn't ready" (cracyc, 2024-10-19)

**Before** (old MAME):
```cpp
void upd765_family_device::seek_start(floppy_info &fi) {
    ...
    fi.st0 = (fi.ready ? 0 : ST0_NR);  // st0 = 0, no head bit
    seek_continue(fi);
}
// At seek completion: fi.st0 |= ST0_SE | fi.id → 0x20 | drive
```

**After** (current MAME):
```cpp
void upd765_family_device::seek_start(floppy_info &fi) {
    ...
    fi.st0 = command[1] & 7;  // ← includes HD bit (bit 2)!
    if(!fi.ready) { ... }
    seek_continue(fi);
}
// At seek completion: fi.st0 |= ST0_SE | fi.id → 0x24 for head 1
```

The change from `& 3` (drive only) to `& 7` (drive + head) causes the HD bit
from the Seek command to leak into ST0 returned by Sense Interrupt Status.

### Evidence That Real Hardware Does NOT Set HD

1. **The PROM works on real RC702 hardware** (NEC µPD765 FDC). If real hardware
   set HD in ST0 after Seek, the PROM's FLSEEK would fail on real hardware too.

2. **floooh/chips emulator** (well-known accurate chip emulator) uses
   `fdd_index = fifo[1] & 3` — masks to bits 0-1 only, excluding HD.

3. **Old MAME** (pre-Oct 2024) used `fi.st0 = 0` — no head bit preserved.

4. **uPD765 datasheet** says ST0 HD is "the state of the head at interrupt"
   but does not define what "state" means for non-data-transfer commands.
   The Seek command only moves the head carriage (cylinder positioning);
   the head select line is relevant for Read/Write but arguably not for Seek.

### PROM FLSEEK Code (roa375.asm, line 1726)

```asm
FLSEEK:
    LD  A,(CURCYL)      ; Get target cylinder
    LD  E,A
    CALL MKDHB          ; Build drive/head byte (D register)
    LD  D,A
    CALL FLO7           ; → Seek command: D=head/drive, E=cylinder
    CALL FLWRES         ; Wait for interrupt (Sense Interrupt Status)
    RET C               ; Return if timeout
    LD  A,(DRVSEL)      ; Expected = drive_select + 0x20
    ADD A,00100000b     ; Seek End bit, NO head bit
    CP  B               ; Compare with actual ST0
    JP  NZ,SEEKERR      ; ← FAILS: 0x24 ≠ 0x20
```

### Proposed Fix

In `src/devices/machine/upd765.cpp`, change `seek_start()` and
`recalibrate_start()` to mask `command[1] & 3` instead of `command[1] & 7`:

```cpp
fi.st0 = command[1] & 3;  // drive select only, not head
```

This restores the pre-regression behavior and matches both real hardware (working
PROM) and the floooh/chips reference emulator.

### Eliminated Hypotheses

**FM→MFM density switching**: Not the root cause. The density switch never happens
because DSKAUTO fails at the Seek step, before any Read commands are issued on
Side 1.

**CTC2 writes**: Not the cause — the CTC2 writes at ports 0x44-0x47 happen AFTER
the LDIR (at PC 0x02E7+), and the data is already zeros before the writes. The
problem is in the PROM's FDC reads, which happen before INIT even starts.

**Early interrupt**: Not the cause — DI is respected; the crash happens specifically
at EI because I=0x00 from the missing MFM data.

## Fixes Already Applied

### set_floppy() removal from port14_w()

The original MAME driver called `m_fdc->set_floppy()` in the port 0x14 write handler.
This assigned the same floppy device to all 4 internal FDC drive slots, causing 4
spurious ready-change interrupts on every floppy event. The PROM's FDC polling loop
would deadlock because it expected exactly 1 interrupt per operation.

Fix: Removed `set_floppy()` from `port14_w()`. The FDC connector already binds the
floppy device during `device_start()`. Port 0x14 now only controls the mini floppy
motor via `mon_w()`.

This fix was necessary but not sufficient — the boot still crashes at EI.

### FDC data rate for 8" maxi (rc702 variant)

MAME's UPD765 defaults `cur_rate` to 250000 (250 kbps) on reset. This is
correct for 5.25" DD drives (rc702m, rc703) but wrong for 8" drives which
use 500 kbps.

Without the correct data rate, the FDC PLL cannot lock onto the disk data
and Read ID returns ST0=0x40/0x44 (abnormal termination) with ST1=0x05
(ND+MA = No Data + Missing Address Mark) on every attempt. DSKAUTO fails
on all heads.

Fix: Call `m_fdc->set_rate()` in `machine_reset()` based on DIP switch S08:
```cpp
m_fdc->set_rate(BIT(ioport("DSW")->read(), 7) ? 250000 : 500000);
```
S08 bit 7: clear = maxi (8", 500 kbps), set = mini (5.25", 250 kbps).

This follows the same pattern as `imds2ioc_device::device_reset()` which
calls `set_rate(500000)` for its 8" IMD images.

## Next Steps

1. ~~Run MAME debug trace~~ — **DONE**: confirmed I=0x00, Side 1 MFM all zeros.

2. ~~Trace the PROM's FDC read commands~~ — **DONE**: traced FLSEEK failure.
   Root cause is ST0 HD bit, not density switching.

3. ~~Investigate MAME's UPD765A ST0 handling~~ — **DONE**: identified regression
   commit `272ec75ca61` (2024-10-19) that changed `fi.st0` initialization from
   `0` to `command[1] & 7`, adding the unwanted HD bit to Seek/Recalibrate ST0.

4. ~~Apply and test fix~~ — **DONE**: Changed `command[1] & 7` to `command[1] & 3`
   in both `seek_start()` and `recalibrate_start()`. Test results:
   - **rc702m**: BOOTS! DSKAUTO succeeds on both heads, DISKBITS=0x87 (dual-sided),
     I=0xEC, EI succeeds, HD probe runs, CP/M loads.
   - **rc703**: Still boots (unaffected, uses uniform MFM, no multi-density).
   - **rc702 (8" maxi)**: Initially still failed — separate issue (FDC data rate).
     Fixed with `set_rate()` — see item 6.

5. **Report upstream**: PR draft prepared at `rcbios/MAME_UPD765_PR_DRAFT.md`.
   Not yet filed — needs regression testing on other UPD765 machines (cpc6128,
   qx10, specpl3e) before submission.

6. ~~Investigate rc702 8" maxi failure~~ — **DONE**: Root cause was missing
   `set_rate()` call. MAME's UPD765 defaults to 250 kbps, but 8" drives use
   500 kbps. Fix: call `m_fdc->set_rate()` in `machine_reset()` based on DIP
   switch S08 (bit 7: clear=maxi/500k, set=mini/250k). All three variants now
   boot successfully.

7. ~~Remove MACHINE_NOT_WORKING~~ — **DONE**: All three variants verified booting
   CP/M with DIR command listing files. MACHINE_NOT_WORKING removed from all
   COMP entries.

## Related: Read Track ST1_ND Bug (PR #15031)

A separate UPD765 bug was found for the RC703 path: `read_track_continue()`
incorrectly toggled ST1_ND per sector during Read Track commands. See
`MAME_UPD765_READ_TRACK_ANALYSIS.md` for full datasheet analysis, including
a correction to the inaccurate claim in the PR description about sector ID
comparison.

## Key Source Files

| File | Description |
|------|-------------|
| `rcbios/src/INIT.MAC` | Hardware initialization, LDIR, programs all devices, EI |
| `rcbios/src/INTTAB.MAC` | Interrupt vector table (ITRTAB) and CITAB |
| `rcbios/src/INIPARMS.MAC` | Configuration data area (0xD480-0xD580), SIO/CTC params |
| `rcbios/src/CPMBOOT.MAC` | BOOT/WBOOT — runs after INIT, reads Track 1 |
| `roa375/roa375.asm` | Boot PROM source — reads Track 0, jumps to BIOS entry |
| `mame/.../rc702.cpp` | MAME driver — machine configs, daisy chain, I/O map |

## BIOS Memory Map (56K, rel.2.1)

```
Source offset  Runtime addr  Contents
────────────   ────────────  ────────
0x0000         0xD480        INIPARMS (configuration data, 256 bytes)
0x0100         0xD580        CONVTA (character conversion tables)
0x0280         0xD700        INIT entry (DI, LDIR, hardware init, EI)
  ...            ...         BIOS code (CPMBOOT, DISPLAY, FLOPPY, etc.)
0x1780         0xEC00        ITRTAB (interrupt vector table, 36 bytes)
0x17A4         0xEC24        CITAB (DW ITRTAB = 0xEC00)
0x17A5         0xEC25        I register byte (0xEC)
  ...            ...         More BIOS code
0x1A00         0xEE80        ENDPRG (start of runtime variables)
  ...            ...         Variables, ALV tables
0x2380         0xF800        DSPSTR (display buffer, 2000 bytes)
```
