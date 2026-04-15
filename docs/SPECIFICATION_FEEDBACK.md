# Specification Feedback for Next Iteration

This document captures everything the clean-room implementation team needs explained
better in the specification. It's written from the perspective of having attempted a
full implementation and hitting issues that were either absent from the spec, ambiguous,
or where the specification's level of detail was insufficient for a correct implementation.

The goal: another developer (or AI) should be able to read the improved specification
and produce a working BIOS without needing access to the working binary or source.

---

## 1. Interrupt Service Routine Architecture (CRITICAL)

This is the area where the most problems occurred. The specification needs a
**complete, standalone section** on ISR implementation with actual byte-level detail.

### 1.1 CTC Ch.3 (Floppy) ISR — Full Sequence

**What the spec should describe, step by step:**

1. CTC Ch.3 fires when FDC INTRQ rises (counter mode, count=1, one trigger = one interrupt)
2. The ISR must:
   - Switch to a dedicated ISR stack (e.g., 0xF5F0) — the mainline stack may not have enough room
   - Save ALL registers: AF, HL, DE, BC, IX, IY (the C compiler uses all of them)
   - Check MSR bit 4 (CB = Controller Busy):
     - **CB=1 (result phase):** Read exactly 7 result bytes, polling RQM before each byte.
       Store ST0, ST1, ST2, C, H, R, N.
     - **CB=0 (seek/recalibrate complete):** Send SENSE INTERRUPT STATUS command (0x08),
       then read 2 result bytes (ST0, PCN). Poll RQM before the command and each read.
   - Read DMA status register (port 0xF8) to clear terminal count
   - **Re-arm CTC Ch.3** — write mode byte 0xD7 then count byte 0x01 to port 0x0F
   - Set the completion flag last (after all hardware interaction is done)
   - Restore all registers
   - Restore the original SP
   - End with EI + RETI (NOT RET, NOT RETN — see section 1.5)

**Question for the working BIOS instance:**
- Does the FDC ISR re-arm CTC Ch.3 after every interrupt, or does it rely on CTC auto-reload?
- Is the re-arming done in the ISR, or before the next FDC command (in the prepare/setup function)?
- Exact sequence: is CTC Ch.3 re-armed before or after reading DMA status?

### 1.2 CTC Ch.2 (Display) ISR — Full Sequence

**What the spec should describe:**

1. CTC Ch.2 fires on 8275 VRTC (vertical retrace, 50 Hz)
2. The ISR must:
   - Switch to ISR stack
   - Save AF, HL, DE, BC (minimum)
   - Read 8275 status port (0x01) to acknowledge interrupt
   - Reprogram DMA Ch.2 for next frame:
     - Mask channels 2 and 3 (writes 0x06 and 0x07 to port 0xFA)
     - Clear byte-pointer flip-flop (write any value to port 0xFC)
     - Write Ch.2 address: low byte then high byte to port 0xF4
     - Write Ch.2 word count: low byte then high byte to port 0xF5
     - Unmask Ch.2 (write 0x02 to port 0xFA)
   - Re-arm CTC Ch.2: write 0xD7 then 0x01 to port 0x0E
   - Restore registers and SP
   - End with EI + RETI

**Key detail the spec needs:** The display buffer address (0xF800) and word count (1999 = 0x07CF).

### 1.3 DMA Programming Must Be Atomic (CRITICAL)

**This was the root cause of intermittent FDC failures.**

The Am9517A DMA controller has a shared byte-pointer flip-flop that determines
whether the next write to a 2-byte register goes to the low byte or high byte.
ALL channels share this flip-flop.

If the display ISR fires between mainline code's two-byte writes to DMA Ch.1
(the FDC channel), the ISR's `OUT (0xFC)` (clear flip-flop) corrupts the mainline's
register programming. The second byte write goes to the low byte position instead
of the high byte.

**The spec MUST state:** All DMA channel programming sequences must be wrapped
with DI/EI. Specifically, from the mask write through the unmask write, interrupts
must be disabled.

```
DI
OUT mask (disable channel)
OUT mode
OUT clear-flip-flop
OUT addr-low
OUT addr-high       ← ISR must NOT fire between these two writes
OUT count-low
OUT count-high      ← ISR must NOT fire between these two writes
OUT mask (enable channel)
EI
```

**Symptoms of getting this wrong:** FDC operations work for 12-105 iterations
then hang permanently. The FDC interrupt never fires because the DMA transfer
went to the wrong address, so the FDC never completes.

### 1.4 Z80 IM2 Vector Table Construction

**The spec needs to explain:**

- Exact vector table location (0xF600) and I register value (0xF6)
- Table size: 18 entries × 2 bytes = 36 bytes
- Entry layout (index = device_vector_byte / 2):
  - 0: unused
  - 1: PIO Ch.A (keyboard), vector 0x02
  - 2: PIO Ch.B, vector 0x04
  - 3: unused
  - 4: CTC Ch.0 (baud rate), vector 0x08
  - 5: CTC Ch.1 (baud rate), vector 0x0A
  - 6: CTC Ch.2 (display), vector 0x0C
  - 7: CTC Ch.3 (floppy), vector 0x0E
  - 8-15: SIO channels (B TX/EXT/RX/SPEC, A TX/EXT/RX/SPEC), vectors 0x10-0x1E
  - 16-17: PIO alternate vectors 0x20/0x22

**Critical:** The vector table must be populated BEFORE IM2 is enabled. The LDIR
copy from ROM data to 0xF600 must complete, then set I register, then IM 2.

**Question for the working BIOS:** Does the working BIOS initialize ALL 18 vector
entries at boot, or only the ones it uses? What address do unused vectors point to?

### 1.5 EI + RETI vs RET vs RETN

**This caused the CTC daisy chain to break.**

- All ISR handlers MUST end with EI followed by RETI
- RETI is required for the Z80 daisy chain protocol — peripheral chips monitor
  the data bus for the RETI opcode (ED 4D) to clear their interrupt-under-service latch
- Using plain RET (C9) breaks the daisy chain: the device that interrupted thinks
  its interrupt is still being serviced, blocking lower-priority interrupts
- RETN is for NMI handlers only — do NOT use `__critical __interrupt` in SDCC
  as it generates RETN instead of RETI

**For C implementations:** `__interrupt` keyword generates EI+RETI. But if you use
an assembly wrapper, the wrapper must provide EI+RETI and the C function should be
a plain function (returns with RET).

### 1.6 CTC Counter Mode Configuration

**The spec should provide exact byte values:**

- CTC Ch.2 (display): mode byte = 0xD7, count = 0x01
  - Bit 7: interrupt enabled
  - Bit 6: counter mode (external trigger)
  - Bit 4: trigger on rising edge
  - Bit 2: auto-reload after reaching zero (1)
  - Bit 1: 0 (prescaler not used in counter mode)
  - Bit 0: 1 (control word follows)
- CTC Ch.3 (floppy): mode byte = 0xD7, count = 0x01
  - Same configuration: triggers on one rising edge of INTRQ

**Question for working BIOS:** After CTC Ch.3 fires, does the counter auto-reload
and wait for the next trigger edge, or must it be explicitly re-armed? In MAME
emulation, does the CTC auto-reload work correctly?

---

## 2. CP/M ABI Register Conventions (IMPORTANT)

### 2.1 SDCC sdcccall(1) vs CP/M Register Conventions

**The spec should include a complete mapping table:**

| BIOS call | CP/M passes | sdcccall(1) expects | Wrapper needed |
|-----------|-------------|---------------------|----------------|
| CONOUT    | C = char    | A = char            | LD A,C; JP fn  |
| LIST      | C = char    | A = char            | LD A,C; JP fn  |
| PUNCH     | C = char    | A = char            | LD A,C; JP fn  |
| SELDSK    | C = disk    | A = disk            | LD A,C; CALL fn; EX DE,HL; RET |
| SETTRK    | BC = track  | HL = track          | LD H,B; LD L,C; JP fn |
| SETSEC    | BC = sector | HL = sector         | LD H,B; LD L,C; JP fn |
| SETDMA    | BC = addr   | HL = addr           | LD H,B; LD L,C; JP fn |
| WRITE     | C = type    | A = type            | LD A,C; JP fn  |
| SECTRAN   | BC = sec, DE = xlt | HL = sec, DE = xlt | LD H,B; LD L,C; CALL fn; EX DE,HL; RET |

**Return values:**
| Return type | CP/M expects | sdcccall(1) returns | Wrapper needed |
|-------------|-------------|---------------------|----------------|
| byte (0/1)  | A           | A                   | None           |
| word (DPH*) | HL          | DE                  | EX DE,HL       |
| word (SECTRAN) | HL       | DE                  | EX DE,HL       |

**Critical detail:** SELDSK and SECTRAN return word values. SDCC's sdcccall(1)
returns words in DE, but CP/M expects them in HL. The wrapper MUST include
`EX DE,HL` after the CALL. Missing this causes CP/M to use garbage DPH pointers.

### 2.2 WBOOT Stack Reset

The WBOOT entry point must reset SP to the BIOS stack (e.g., 0xF500) before
doing anything else. CP/M's CCP/BDOS may leave SP anywhere.

---

## 3. FDC Driver Details

### 3.1 FDC Result Byte Counts

**Must be explicitly stated for every command:**

| Command           | Result bytes | Notes |
|-------------------|-------------|-------|
| READ DATA         | 7           | ST0, ST1, ST2, C, H, R, N |
| WRITE DATA        | 7           | ST0, ST1, ST2, C, H, R, N |
| SENSE INT STATUS  | 2           | ST0, PCN |
| SPECIFY           | 0           | No result phase |
| RECALIBRATE       | 0           | No result; ISR does SENSE INT |
| SEEK              | 0           | No result; ISR does SENSE INT |
| SENSE DRIVE STATUS| 1           | ST3 |

**Getting the count wrong blocks the FDC:** reading too few bytes leaves the FDC
in result phase, hanging the next command. Reading too many blocks waiting for
RQM that never comes.

### 3.2 DMA Setup for FDC Operations

**The spec should include exact port sequences:**

```
DI
OUT (0xFA), 0x05    ; mask channel 1 (single mask register, bit 2=mask, bits 1:0=channel)
OUT (0xFB), mode    ; 0x45 for read (IO→mem), 0x49 for write (mem→IO)
OUT (0xFC), 0x00    ; clear byte pointer flip-flop
OUT (0xF2), addr_lo ; channel 1 base address, low byte
OUT (0xF2), addr_hi ; channel 1 base address, high byte
OUT (0xF3), count_lo; channel 1 word count, low byte
OUT (0xF3), count_hi; channel 1 word count, high byte
OUT (0xFA), 0x01    ; unmask channel 1
EI
```

Word count = (byte_count - 1). For a 512-byte sector: count = 511 = 0x01FF.

### 3.3 SPECIFY Command Timing Values

The CONFI configuration block provides SPECIFY parameters:
- Offset +0x26: SRT/HUT byte (e.g., 0xDF = SRT 3ms, HUT 240ms)
- Offset +0x27: HLT/ND byte (e.g., 0x28 = HLT 40ms, DMA mode)

---

## 4. Disk Parameter Details

### 4.1 DR Convention for secshf

CP/M 2.2 deblocking uses `secshf` = log2(physical_sectors_per_logical_sector) + 1.
The shift operation is `host_sector = logical_sector >> (secshf - 1)`.

For 512-byte physical sectors with 128-byte logical sectors: ratio = 4, secshf = 3.

**This +1 convention is non-obvious and must be explicitly stated.**

### 4.2 DPH Structure Layout

```
Offset  Size  Field
0x00    2     XLT pointer (0x0000 = no translation)
0x02    6     Scratch area (3 words, zeroed)
0x08    2     DIRBF pointer (128-byte directory buffer)
0x0A    2     DPB pointer
0x0C    2     CSV pointer (check vector, DSM/4 bytes)
0x0E    2     ALV pointer (allocation vector, DSM/8+1 bytes)
```

Total: 16 bytes per drive.

---

## 5. Boot Sequence Details

### 5.1 Exact Boot Order

1. Console/display init (set up 8275, display buffer at 0xF800)
2. Build IM2 vector table at 0xF600, set I=0xF6, enable IM2
3. Initialize CTC Ch.3 for floppy interrupts (0xD7, 0x01 to port 0x0F)
4. EI (enable interrupts — display ISR starts running)
5. Print signon message
6. Initialize subsystems (JTVARS, CONFI, deblocking, etc.)
7. FDC init: wait idle, SPECIFY, SENSE DRIVE STATUS, RECALIBRATE
8. Fall through to WBOOT (load CCP+BDOS from track 1)

### 5.2 WBOOT: Loading CCP+BDOS

- Reset SP to BIOS stack
- Select disk 0, set track 1
- Read 44 logical sectors (128 bytes each = 5632 bytes) using SETDMA/SETSEC/READ
- Sectors are on track 1 with the same interleave as user data
- Load address starts at CCP base (BIOS_base - 0x1600)
- After loading, set IOBYTE, set default DMA to 0x0080
- Jump to CCP entry point (CCP_base + 3 for warm boot)

---

## 6. Issues Encountered in MAME Emulation

These may affect anyone testing in MAME before going to real hardware:

1. **CTC counter auto-reload:** May not work identically to real hardware. Explicitly
   re-arming the CTC channel before each FDC command is safer than relying on auto-reload.

2. **IMD disk format:** MAME's IMD handler updates the in-memory image but does NOT
   write changes back to disk. Use other formats for write testing.

3. **SIO DCD float:** SIO-B DCD may float high in MAME, causing IOBYTE routing to
   think a serial terminal is connected (JOINED mode). Force IOBYTE to LOCAL at boot.

4. **Timing sensitivity:** The FDC/CTC interaction is timing-sensitive in MAME. Code
   that works with debug overhead (extra function calls, display writes) may fail
   without it. This is a symptom of the DMA flip-flop race condition.

---

## 7. Open Questions for the Working BIOS

These are specific questions that would complete the specification:

1. **CTC Ch.3 re-arming:** Does the working BIOS re-arm CTC Ch.3 in the ISR, in
   fdc_prepare (before each command), or both? Or does it rely solely on auto-reload?

2. **ISR stack:** Where exactly is the ISR stack? Is it shared between display and
   floppy ISRs? What happens if both fire nearly simultaneously?

3. **FDC ISR complete sequence:** After reading FDC results and DMA status, what
   exactly does the ISR do before RETI? Any additional CTC/DMA cleanup?

4. **Vector table hot-patching:** Does the working BIOS ever modify the vector table
   at runtime (e.g., enabling keyboard interrupts after boot)? Or is the table static?

5. **SIO initialization for daisy chain:** Does the SIO need any initialization at
   boot to prevent it from interfering with the CTC/PIO daisy chain? (SIO sitting
   between CTC and PIO in the chain, with uninitialized interrupt enable bits, might
   steal RETI acknowledgments.)

6. **FDC INTRQ to CTC Ch.3 connection:** In the working BIOS, is CTC Ch.3 CLK/TRG
   confirmed to be connected to FDC INTRQ? Or is it INT (active low)?

7. **Exact register saves in display ISR:** Does the working BIOS's display ISR save
   IX and IY? Or only AF, HL, DE, BC? (The C compiler uses IX for frame pointer.)

8. **hal_in B register:** Does the working BIOS set B=0 before IN A,(C) instructions?
   The Z80 puts B:C on the address bus during IN r,(C).

---

## 8. Compiler/Toolchain Notes

These are things the specification should mention for anyone using z88dk/SDCC:

1. **`__interrupt` generates EI+RETI** — correct for IM2 ISR functions
2. **`__critical __interrupt` generates RETN** — WRONG for IM2, only use for NMI
3. **sdcccall(1) word return is in DE**, not HL — ALL word-returning BIOS functions
   need EX DE,HL in the CP/M wrapper
4. **`__sfr __at(port)` generates IN A,(n)/OUT (n),A** — correct for this hardware
5. **Do NOT use `-debug` flag** with SDCC — causes assembler errors with arrays
6. **Optimizer (-SO3)** may reorder port I/O writes if not using `volatile` __sfr
7. **Global variables save ~8% code size** over function parameters on Z80

---

## Summary Priority

If only three things are improved in the specification, they should be:

1. **Section 1.3 — DMA programming must be atomic (DI/EI)** — This was the #1 bug
2. **Section 1.1 — Complete FDC ISR sequence with CTC re-arming details** — This is still unresolved
3. **Section 2.1 — Complete CP/M↔sdcccall(1) register mapping** — Multiple bugs from this
