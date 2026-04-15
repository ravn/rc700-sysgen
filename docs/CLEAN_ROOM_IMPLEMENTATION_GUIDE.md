# Clean Room Implementation Guide — Verified Answers

**Purpose:** This document provides verified, detailed answers to questions
that arose during a clean room BIOS reimplementation attempt (April 2026).
Every answer was verified against the working BIOS source code and tested
in MAME.  Read this alongside `RC702_BIOS_SPECIFICATION.md`.

Use this document to avoid the pitfalls encountered in the first attempt.
No source code is included — only behavioral descriptions and register-level
hardware interaction sequences.

**Companion documents:**
- `RC702_BIOS_SPECIFICATION.md` — the specification itself
- `SPECIFICATION_FEEDBACK.md` — feedback from the first attempt (has some errors; corrections noted below)
- `MAME_RC702.md` — MAME emulator setup and known issues

---

## 1. Critical: DMA Programming Must Be Atomic

This was the root cause of the first attempt's intermittent FDC failures
(hangs after 12-15 operations).

### The Problem

The Am9517A DMA controller has a single byte-pointer flip-flop shared by
all four channels.  Writing to any channel's address or word-count register
is a two-step process: low byte first, high byte second, toggled by this
flip-flop.  The `OUT (0xFC)` instruction (clear byte pointer) resets it
globally.

The display ISR fires at 50 Hz and clears this flip-flop every frame as
part of reprogramming DMA channel 2.  If the display ISR fires between a
mainline two-byte write to channel 1 (FDC), the second write goes to the
low-byte position instead of the high-byte position.  The channel 1
address or count is corrupted, the FDC DMA transfer goes to the wrong
place, the FDC never completes, and the system hangs.

### The Rule

ALL DMA channel programming must be wrapped with DI/EI.  From the moment
you write the mask register through the unmask write, interrupts must be
disabled.  The working BIOS does this consistently:

    DI
    write single-mask register: mask channel being programmed
    write mode register
    write clear-byte-pointer (0xFC)
    write address register: low byte
    write address register: high byte
    write count register: low byte
    write count register: high byte
    write single-mask register: unmask channel
    EI

This applies to every DMA channel programming sequence — floppy (ch 1),
display (ch 2), attributes (ch 3), and hard disk (ch 0).

### Symptoms

FDC operations succeed for 12-105 iterations, then hang permanently.
The count depends on timing — it fails whenever a 50 Hz display ISR
happens to coincide with the two-byte DMA register write window.
Disabling the display ISR makes the problem disappear entirely (but
obviously the screen stops refreshing).

---

## 2. Interrupt Service Routines

### 2.1 General ISR Rules

Every IM2 ISR must end with EI followed by RETI (opcode ED 4D).  Using
plain RET (C9) breaks the Z80 daisy chain — the interrupting device
never sees the RETI bus cycle, keeps its interrupt-under-service latch
set, and permanently blocks all lower-priority interrupts on the same
device.

For the CTC specifically: channels 0-3 share an internal daisy chain
with priority Ch0 > Ch1 > Ch2 > Ch3.  If Ch2 (display) ends its ISR
with RET instead of RETI, Ch3 (floppy) is permanently blocked, even
though Ch2 appears to continue working.

### 2.2 ISR Register Saves

The working BIOS saves AF, BC, DE, HL (4 register pairs, 8 bytes).
It does NOT save IX or IY.  This is sufficient because the ISR body
functions are compiled as leaf functions that the compiler does not
allocate IX/IY for.  If your compiler uses IX as a frame pointer in
ISR bodies, you must save it too — but consider restructuring to
avoid that overhead (50 Hz * 64 extra T-states = significant).

### 2.3 ISR Stack

All ISRs switch SP to a dedicated interrupt stack at 0xF600 (grows
downward, below the IVT).  The pattern is:

    save SP to a global variable (sp_sav)
    set SP to interrupt stack address
    push registers
    ... ISR body ...
    pop registers
    restore SP from sp_sav
    EI
    RETI

The interrupt stack is shared among all naked ISRs.  This is safe
because every ISR runs with interrupts disabled throughout — there
is no window for nesting.  The EI immediately before RETI allows the
next interrupt only after the current RETI completes.

The sp_sav variable is shared.  The two instructions
`LD (sp_sav), SP` and `LD SP, ISTACK` must be adjacent with no
possibility of interruption between them.  On Z80, interrupts are
checked only between instructions, so two adjacent instructions are
inherently atomic in this regard.

### 2.4 Floppy ISR (CTC Ch.3)

The floppy ISR does the following, in order:

1. Switch to ISR stack (save SP, load ISTACK, push AF/BC/DE/HL)
2. Set completion flag to 0xFF
3. Short delay (5 empty loop iterations — gives the FDC time to
   update its MSR after asserting INTRQ)
4. Read FDC Main Status Register (port 0x04), test bit 4 (CB):
   - CB=1 (result phase): read up to 7 result bytes.  For each byte,
     poll MSR until RQM=1 and DIO=1, read data port (0x05), then
     check CB after a short delay.  Stop when CB clears.
   - CB=0 (seek/recalibrate complete): send SENSE INTERRUPT STATUS
     command (0x08) via the write-when-ready path, then read 2
     result bytes (ST0 and PCN).
5. Restore registers and SP
6. EI; RETI

The ISR does NOT:
- Re-arm CTC Ch.3 (not needed — counter mode auto-reloads)
- Read DMA status register
- Touch any CTC or DMA registers
- Enable interrupts before RETI

### 2.5 Display ISR (CTC Ch.2)

The display ISR does the following, in order:

1. Switch to ISR stack
2. Read 8275 status port (0x01) to acknowledge the interrupt
3. Reprogram DMA channels 2 and 3 for next frame:
   - Mask channel 2 (write 0x06 to port 0xFA)
   - Mask channel 3 (write 0x07 to port 0xFA)
   - Clear byte pointer flip-flop (write any value to port 0xFC)
   - Write channel 2 address: 0x00 then 0xF8 to port 0xF4 (=0xF800)
   - Write channel 2 count: 0xCF then 0x07 to port 0xF5 (=1999)
   - Write channel 3 count: 0x00 then 0x00 to port 0xF7
   - Unmask channel 2 (write 0x02 to port 0xFA)
   - Unmask channel 3 (write 0x03 to port 0xFA)
4. Re-arm CTC Ch.2: write 0xD7 then 0x01 to port 0x0E
5. Increment 32-bit real-time clock at 0xFFFC
6. Decrement timer variables (motor-off, delay, exit routine)
7. Restore registers and SP
8. EI; RETI

The display ISR does NOT touch DMA channel 1 (floppy) or CTC Ch.3.

### 2.6 CTC Counter Auto-Reload

CTC counter mode with time constant 1 auto-reloads after firing.
Each trigger edge (FDC INTRQ for Ch.3, 8275 VRTC for Ch.2) produces
exactly one interrupt.  The counter does not need re-arming.

The working BIOS programs CTC Ch.3 once at boot and never touches it
again (except at halt, where it disables Ch.3 with mode byte 0x03 to
prevent stray floppy interrupts from blocking display refresh).

CTC Ch.2 IS re-armed in the display ISR (0xD7 + 0x01).  This is
because the mode byte includes bit 2 (software reset), which is
needed to properly re-sync with the 8275 retrace signal.

CTC auto-reload works correctly in MAME.  If Ch.3 stops firing after
a number of operations, the cause is elsewhere (DMA flip-flop race,
daisy chain RETI issue, or SIO initialization problem).

---

## 3. FDC Driver Details

### 3.1 MSR Polling Pattern

Before every FDC data port access, poll the Main Status Register
(port 0x04):

- Before writing a command/parameter byte: wait for bits 7:6 = 10
  (RQM=1, DIO=0).  Mask with 0xC0, compare to 0x80.
- Before reading a result byte: wait for bits 7:6 = 11
  (RQM=1, DIO=1).  Mask with 0xC0, compare to 0xC0.

### 3.2 Result Phase Reading

After reading each result byte, check MSR bit 4 (CB = Controller
Busy).  If CB=0, stop reading — there are no more result bytes.
The maximum is 7 bytes for READ/WRITE DATA.  For SENSE INTERRUPT
STATUS, CB clears after 2 bytes (or 1 byte if the command was
invalid).

A short delay (4-5 empty loop iterations) between reading the data
port and checking CB is important — it gives the FDC time to update
MSR after the read.

### 3.3 Seek and Recalibrate

The BIOS uses explicit SEEK commands (0x0F).  It does NOT rely on
implied seek during READ DATA.  The sequence for a sector read is:

1. Check if seek is needed (compare requested track/drive with last
   seek position).  Skip seek if already there.
2. If seek needed: clear interrupt flag, send SEEK (3 bytes: 0x0F,
   drive, cylinder), wait for interrupt.
3. ISR fires, does SENSE INTERRUPT STATUS, populates ST0 and PCN.
4. Mainline checks ST0 for Seek End (bit 5) + correct drive.
5. On failure: recalibrate (CLFIT, RECALIBRATE, wait, SENSE INT),
   then seek again (CLFIT, SEEK, wait, SENSE INT).

### 3.4 READ DATA Sequence

1. Set up DMA channel 1 (with DI/EI around it — see section 1)
2. Send 9-byte command with DI/EI around the entire sequence:
   command+MFM flag, drive/head, cylinder, head, sector, N, EOT,
   GPL, DTL
3. DMA runs autonomously — CPU does not participate in data transfer
4. Wait for interrupt (spin on flag with interrupts enabled)
5. ISR fires, reads 7 result bytes (CB=1 path), sets flag
6. Mainline checks ST0/ST1/ST2 for errors

### 3.5 SPECIFY Must Precede All Operations

Before the first RECALIBRATE or SEEK, send the SPECIFY command
(0x03) with SRT/HUT and HLT/ND bytes from the CONFI configuration
block.  Without SPECIFY, the FDC may behave unpredictably.

### 3.6 No Pending Interrupt Drain at Boot

The working BIOS does NOT issue SENSE INTERRUPT STATUS in a loop at
boot to drain pending interrupts.  Instead, init_fdc waits for MSR
bits 4:0 to all be zero (no channels busy, not in command), then
sends SPECIFY.  By the time the BIOS runs (after PROM loaded track
0), any FDC activity from the boot load has long completed.

---

## 4. Port I/O Instruction Form

All port I/O uses the fixed-port form: IN A,(n) and OUT (n),A.
The port address is an 8-bit immediate in the instruction.  The
IN A,(C) / OUT (C),A form (where B appears on the upper address
bus) is never used for FDC, DMA, CTC, or any other peripheral
access.

For z88dk SDCC, `__sfr __at(addr)` declarations generate this form.
For clang, `address_space(2)` pointer dereferences generate this form.

---

## 5. CP/M ABI and sdcccall(1)

### 5.1 Register Convention Mapping

CP/M passes parameters in registers that differ from sdcccall(1):

| BIOS Entry | CP/M Register | sdcccall(1) | Wrapper Action |
|------------|--------------|-------------|----------------|
| CONOUT     | C = char     | A = char    | LD A,C; JP fn  |
| LIST       | C = char     | A = char    | LD A,C; JP fn  |
| PUNCH      | C = char     | A = char    | LD A,C; CALL fn |
| SELDSK     | C = drive    | A = drive   | LD A,C; CALL fn; EX DE,HL; RET |
| SETTRK     | BC = track   | store to memory | LD (sektrk),BC; RET |
| SETSEC     | BC = sector  | store to memory | LD (seksec),BC; RET |
| SETDMA     | BC = addr    | store to memory | LD (dmaadr),BC; RET |
| WRITE      | C = type     | A = type    | LD A,C; JP fn  |
| SECTRAN    | BC = sector  | identity    | LD H,B; LD L,C; RET |

SELDSK returns a DPH pointer.  sdcccall(1) returns words in DE;
CP/M expects HL.  The wrapper MUST include EX DE,HL after the call.
Missing this causes CP/M to use a garbage DPH pointer.

SECTRAN is a pass-through (returns the input unchanged).  The BIOS
handles sector translation internally in the deblocking layer.

### 5.2 WBOOT Must Reset SP

The WBOOT entry point must set SP to the BIOS stack before doing
anything else.  CP/M's CCP may leave SP anywhere in the TPA.

---

## 6. Disk Parameters

### 6.1 DPB for 8" DD MFM (512 B/S, tracks 1-76)

    SPT  = 120   (128-byte logical sectors per track, both sides)
    BSH  = 4     (block shift, 2 KB blocks)
    BLM  = 15    (block mask)
    EXM  = 0     (extent mask)
    DSM  = 449   (total blocks minus 1)
    DRM  = 127   (directory entries minus 1)
    AL0  = 0xC0  (directory allocation bitmap high byte)
    AL1  = 0x00  (directory allocation bitmap low byte)
    CKS  = 32    (check vector size = (DRM+1)/4)
    OFF  = 2     (reserved tracks for system)

### 6.2 DPH Layout

    Offset  Size  Field
    +0      2     XLT:  0x0000 (no translation table)
    +2      6     Scratch: 3 words, zeroed by BIOS at init
    +8      2     DIRBF: pointer to 128-byte directory buffer (shared)
    +10     2     DPB:   pointer to Disk Parameter Block (read-only)
    +12     2     CSV:   pointer to check vector (32 bytes, per-drive)
    +14     2     ALV:   pointer to allocation vector (71 bytes, per-drive)

XLT = 0 because sector translation is done internally by the BIOS.
DIRBF must be shared (same pointer for all drives).  CSV and ALV
must be separate per drive and in writable RAM.  DPB can be in
read-only memory — BDOS never writes to it.

ALV minimum size: (DSM/8)+1 = 57 bytes.  The working BIOS allocates
71 bytes to accommodate the largest possible disk format.

### 6.3 Deblocking Parameters

For 8" DD 512B sectors:
- secshf = 3 (host sector = logical sector >> (secshf-1) = >> 2)
- secmsk = 3 (record within host sector = logical sector & 3)
- cpmspt = 120 (logical sectors per track, both sides)
- eotv = 15 (physical sectors on first side)
- trantb = {1,5,9,13,2,6,10,14,3,7,11,15,4,8,12} (skew-4 table)

Host sector range: 0-29 (30 host sectors = 15 per side).
Host sectors 0-14 map to head 0, 15-29 map to head 1.
After the head split, the table index (0-14) is used to look up
the physical sector number (1-15) from the translation table.

### 6.4 Common Deblocking Bug

If physical sector 23 (or any value > 15) reaches the FDC, the
deblocking layer is broken.  The most common causes:
- SPT wrong in DPB (e.g., 128 instead of 120)
- secshf wrong (e.g., 2 instead of 3)
- Head split threshold (eotv) wrong or uninitialized
- Logical sector passed to FDC without deblocking
- Sector translation applied twice (by BDOS via XLT and by BIOS)

---

## 7. Hardware Initialization Order

The working BIOS initializes hardware in this exact order:

1. Copy IVT to page-aligned RAM (0xF600), set I register, IM 2
2. PIO: interrupt vectors (0x20, 0x22), modes, interrupt enable
3. CTC: vector base 0x00 to Ch0, then mode+count for all 4 channels
4. SIO: channel reset (WR0=0x18) on both channels, then full WR
   programming (vector, clock, modes, interrupt enables)
5. SIO status read: read RR0 and RR1 on both channels to clear
   pending conditions
6. DMA: master clear (0x20 to port 0xF8), channel mode setup
7. FDC: SPECIFY command
8. CRT: reset, parameter bytes, cursor, preset counters
9. Display buffer clear, start CRT
10. EI

### 7.1 CTC Vector Base

The CTC interrupt vector base is written ONCE, to the Ch0 port
(0x0C).  It applies to all four channels.  The CTC adds the channel
offset (0, 2, 4, 6) automatically.  With vector base 0x00:
- Ch0 vector = 0x00, Ch1 = 0x02, Ch2 = 0x04, Ch3 = 0x06

The vector byte has bit 0 = 0, which the CTC uses to distinguish
it from a control word (bit 0 = 1).

### 7.2 SIO Initialization Is Required

The SIO sits in the middle of the MAME daisy chain (CTC > SIO > PIO).
If the SIO is not initialized, it may have undefined interrupt state
that interferes with RETI acknowledgment.  The channel reset command
(WR0 = 0x18) clears pending interrupt conditions.  Send this to BOTH
SIO channels before enabling CTC interrupts.

### 7.3 CTC Channel Order

Channels do not need to be initialized in order.  However, the
vector base must be written to Ch0's port before any channel is
armed for interrupts.  The working BIOS programs them in order
(Ch0, Ch1, Ch2, Ch3) by convention.

---

## 8. MAME Testing Notes

### 8.1 Disk Image Format

The PROM uses IMD images directly (read-only in MAME).
The BIOS uses MFI images (converted from IMD via `floptool flopconvert
auto mfi`) for writable disk support.  For initial testing, IMD works.

### 8.2 Machine Variants

- `rc702` — 8" maxi drives, FDC at 500 kbps, DIP S08 bit 7 = 0
- `rc702mini` — 5.25" mini drives, FDC at 250 kbps, DIP S08 bit 7 = 1
- For mini: must write 0x01 to port 0x14 (motor on) and wait ~1 second

### 8.3 Required MAME Patches

- UPD765 ST0 HD bit fix: change `command[1] & 7` to `command[1] & 3`
  in seek_start() and recalibrate_start() in upd765.cpp
- FDC data rate: rc702.cpp machine_reset() must call
  `m_fdc->set_rate(500000)` for 8" maxi drives

### 8.4 MAME Daisy Chain

The MAME driver defines the daisy chain as: ctc1, sio1, pio.
This is fixed in hardware and cannot be changed from software.
CTC has highest priority, PIO lowest.

---

## 9. Corrections to SPECIFICATION_FEEDBACK.md

The feedback document from the first implementation attempt contains
several errors.  Corrections:

### Section 1.1: CTC Ch.3 Re-arming

**FEEDBACK SAYS:** Re-arm CTC Ch.3 in the ISR (write 0xD7 + 0x01).
**CORRECTION:** Not needed.  CTC counter mode auto-reloads.  The
working BIOS programs Ch.3 once at boot and never touches it again.
The intermittent failures were caused by the DMA flip-flop race
condition (section 1.3 of the feedback), not by missing re-arming.

### Section 1.1: Read DMA Status Register

**FEEDBACK SAYS:** Read DMA status register (port 0xF8) in the ISR.
**CORRECTION:** The BIOS floppy ISR does NOT read DMA status.  Only
the PROM's result-read function does this (and stores it after the
7 FDC result bytes).

### Section 1.1: Save IX and IY

**FEEDBACK SAYS:** Save ALL registers including IX and IY.
**CORRECTION:** The working BIOS saves only AF, BC, DE, HL.  Saving
IX/IY is unnecessary if the ISR body code doesn't use them.

### Section 1.5 and 8.2: __critical __interrupt Generates RETN

**FEEDBACK SAYS:** `__critical __interrupt` generates RETN — wrong for IM2.
**CORRECTION:** Only true for `__critical __interrupt` WITHOUT a number.
With a number — `__critical __interrupt(N)` — z88dk's zsdcc generates
EI+RETI, which is correct.  The working BIOS uses `__critical __interrupt(N)`
for many ISRs.  The rule: always include the (N) parameter.

### Section 6.1: CTC Auto-Reload May Not Work in MAME

**FEEDBACK SAYS:** Explicitly re-arming CTC Ch.3 is safer than auto-reload.
**CORRECTION:** CTC auto-reload works correctly in MAME.  The failures
were caused by the DMA flip-flop race, not CTC auto-reload.

### Section 5.2: "Read 44 Logical Sectors"

**FEEDBACK SAYS:** WBOOT reads exactly 44 sectors.
**CORRECTION:** The count depends on CCP+BDOS size and memory layout.
It is not fixed at 44.

### Section 4.2: CSV Size

**FEEDBACK SAYS:** CSV = DSM/4 bytes.
**CORRECTION:** CSV = (DRM+1)/4 bytes.  With DRM=127, that's 32 bytes.
