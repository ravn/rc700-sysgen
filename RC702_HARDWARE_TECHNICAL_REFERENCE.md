# RC702 Hardware Technical Reference
## For SYSGEN and Autoload ROM Development

This document provides comprehensive technical information about the RC702 hardware architecture, specifically focused on aspects relevant to the SYSGEN utility and ROA375 autoload ROM development.

**Document Version:** 1.0
**Date:** 2026-02-07
**Sources:** Analysis of jbox.dk RC702 documentation, ROB358.MAC, and SYSGEN.ASM

---

## Table of Contents

1. [System Overview](#system-overview)
2. [Memory Architecture](#memory-architecture)
3. [I/O Port Map](#io-port-map)
4. [Floppy Disk Format Specifications](#floppy-disk-format-specifications)
5. [Boot and Initialization Sequence](#boot-and-initialization-sequence)
6. [Hardware Controllers](#hardware-controllers)
7. [Multi-Density Disk Support](#multi-density-disk-support)

---

## System Overview

### Core Components

- **CPU:** Zilog Z80-A running at 4 MHz
- **RAM:** 64KB (0x0000-0xFFFF in normal operation)
- **ROM:** 2KB boot loader (ROA375) with software-controlled mapping
- **Display:** 80x24 character text display at memory address 0x7800

### I/O Controllers

1. **Zilog Z80-SIO/2** - Serial I/O controller
2. **Zilog Z80-PIO** - Parallel I/O controller
3. **Zilog Z80-CTC** - Counter and Timer Controller (2 units)
4. **AMD Am9517A-4** (or Intel 8237-2) - DMA Controller
5. **NEC uPD765** (or Intel 8272) - Floppy Disk Controller
6. **Intel 8275** - Programmable CRT Controller
7. **Western Digital WDC1002** - Winchester Disk Controller (optional)

### Configuration

- 8 DIP configuration switches
- Support for 1 or 2 5.25" floppy disk drives
- Optional 10MB Winchester hard disk
- Speaker for audible feedback

---

## Memory Architecture

### ROM Mapping

The ROA375 boot ROM is a 2KB PROM that is initially mapped into the Z80's address space starting at 0x0000. After the boot sequence initializes, the ROM can be disabled by writing to port 0x14, allowing the full 64KB RAM to be linearly accessible.

### Memory Layout During Boot

```
0x0000-0x07FF   2KB Boot ROM (ROA375) - disabled after boot
0x0000-0xFFFF   64KB RAM (accessible after ROM disabled)
0x7800-0x7FFF   CRT display buffer (2K, 80x24 characters)
0xA000-0xBFFF   Bootstrap code copied from ROM
0xB000-0xB0FF   Working area for boot process
0xBFFF          Initial stack pointer during ROM boot
```

### Working Memory Areas (Boot Time)

```
0xB000  TRK        - Track count for ID COMAL
0xB003  RSTAB      - Floppy save status area
0xB00D  ERFLAG     - Hard disk error flag
0xB00E  SECTOR     - Hard disk sector read count
0xB00F  MEMADR     - Memory address pointer (DMA)
0xB011  REPTIM     - Repeat operation indicator
0xB020  DSPSTR     - Display memory buffer
```

---

## I/O Port Map

### Z80 PIO (Parallel I/O)

```
0x10  KEYDAT     - Keyboard data port (Port A)
0x12  KEYCON     - Keyboard control port (Port A)
```

**PIO Programming Values:**
- `0x4F` - PIO mode = INPUT
- `0x02` - PIO interrupt vector
- `0x87` - Enable interrupts
- `0x07` - Disable interrupts

### Z80 CTC (Counter/Timer Controller)

```
0x0C  CTCCH0     - Channel 0 (not used during bootstrap)
0x0D  CTCCH1     - Channel 1 (not used during bootstrap)
0x0E  CTCCH2     - Channel 2 (Display interrupt input)
0x0F  CTCCH3     - Channel 3 (Floppy controller interrupt)
```

**CTC Programming Values:**
- `0x10` - CTC interrupt vector base (Display=0x14, Floppy=0x16)
- `0xD7` - Mode = interrupt after one count
- `0x01` - Count = 1
- `0x03` - Reset channel command

### Z80 CTC2 (Second Counter/Timer for Hard Disk)

```
0x44  CT2CH0     - Channel 0 (WD1000 hard disk interrupt)
0x45  CT2CH1     - Channel 1 (not used)
0x46  CT2CH2     - Channel 2 (not used)
0x47  CT2CH3     - Channel 3 (not used)
```

**CTC2 Programming Values:**
- `0x08` - Interrupt vector for WD1000

### Intel 8275 CRT Controller

```
0x00  CRTDAT     - CRT data register
0x01  CRTCOM     - CRT control/command register
```

**CRT Commands:**
- `0x00` - Reset CRT controller
- `0x80` - Load cursor command
- `0xA0` - Enable interrupt
- `0xE0` - Preset counters command
- `0x23` - Start display

**CRT Parameters:**
- `0x4F` - 80 characters/row, normal rows
- `0x98` - 25 rows per frame
- `0x7A` - Underline position 8-10, characters per line
- `0x4D` - Cursor format: block, blink, reverse video

### AMD Am9517A / Intel 8237 DMA Controller

```
0xF0  CH0ADR     - Channel 0 address register (WD1000 hard disk)
0xF1  WCREG0     - Channel 0 word count register
0xF2  CH1ADR     - Channel 1 address register (Floppy disk)
0xF3  WCREG1     - Channel 1 word count register
0xF4  CH2ADR     - Channel 2 address register (Display)
0xF5  WCREG2     - Channel 2 word count register
0xF8  DMACOM     - DMA command register
0xFA  SMSK       - Single mask register
0xFB  DMAMOD     - DMA mode register
0xFC  CLBP       - Clear byte counter register
0xFF  FULMSK     - Full mask register
```

**DMA Channel Assignments:**
- Channel 0: WD1000 Winchester disk controller
- Channel 1: NEC uPD765 floppy disk controller
- Channel 2: Intel 8275 display controller
- Channel 3: Not used during bootstrap

**DMA Programming Values:**
- `0x20` - Command value (standard configuration)
- `0x44` - Mode 0: Transfer disk to memory, CH0
- `0x45` - Mode 1: Transfer disk to memory, CH1
- `0x5A` - Mode 2: Transfer memory to display, CH2 (auto-initialize)
- `0x0F` - Set all DMA channel mask bits
- `0x00` - Clear CH0 mask bit
- `0x01` - Clear CH1 mask bit
- `0x02` - Clear CH2 mask bit
- `0x04` - Set CH0 mask bit
- `0x05` - Set CH1 mask bit

### System Control Ports

```
0x14  SW1/RAMEN  - ROM disable / Mini/Maxi switch
0x19  RAMEN      - RAM enable port
0x1C  BIB        - Speaker/beep control
```

---

## Floppy Disk Format Specifications

The RC702 uses a sophisticated multi-density disk format to maintain backward compatibility while maximizing storage capacity. The system uses the NEC uPD765 (or Intel 8272) floppy disk controller, which supports both FM (single density) and MFM (double density) encoding.

### 5.25" Floppy Disk Format (Standard CP/M Format)

This is the primary format used for CP/M operation on the RC702 system with maxi floppy (standard 5.25" double-sided) drives.

#### Track 0 - Special Mixed-Density Format

**Track 0, Side 0** (Single Density FM):
- Encoding: FM (Frequency Modulation)
- Sectors per track: 16
- Bytes per sector: 128
- Total capacity: 2,048 bytes (2KB)
- Physical sector numbers: 0-15

**Track 0, Side 1** (Double Density MFM):
- Encoding: MFM (Modified Frequency Modulation)
- Sectors per track: 16
- Bytes per sector: 256
- Total capacity: 4,096 bytes (4KB)
- Physical sector numbers: 0-15

**Track 0 Total:** 6,144 bytes (6KB)

#### Tracks 1-34 - Standard Double Density

**All remaining tracks, both sides:**
- Encoding: MFM (Modified Frequency Modulation)
- Sectors per track: 9
- Bytes per sector: 512
- Sector interleave: 2:1
- Physical sector order: 0, 2, 4, 6, 8, 1, 3, 5, 7

**Total data tracks:** 34 tracks × 2 sides × 9 sectors × 512 bytes = 313,344 bytes (306KB)

**Total disk capacity:** ~319KB (including Track 0)

### CP/M Logical Structure

- **Block size:** 2,048 bytes (2KB) = 4 sectors of 512 bytes
- **Directory location:** First two blocks on Track 2
- **Reserved tracks:** Track 0 and Track 1 (boot and system)
- **Data area:** Tracks 2-34

### 8" Floppy Disk Formats

The RC702 also supports 8" floppy diskettes in two formats:

#### Type 1: Single-Sided Single-Density (SS/SD)

- Sides: 1 (single-sided)
- Tracks: 77
- Encoding: FM (single density)
- Sectors per track: 26
- Bytes per sector: 128
- Total capacity: ~247KB

#### Type 2: Double-Sided Double-Density (DS/DD)

**Track 0 - Special Format:**
- Track 0, Side 0: 26 sectors × 128 bytes (FM encoding)
- Track 0, Side 1: 26 sectors × 256 bytes (MFM encoding)

**Tracks 1-77 - Standard Format:**
- Both sides: 15 sectors × 512 bytes (MFM encoding)

**Total capacity:** ~1.2MB

### Alternative RC Format (Non-CP/M)

Some specialty RC702 disks use an alternative format:

- Encoding: FM (single density)
- Sides: 2 (double-sided)
- Tracks per side: 35
- Sectors per track: 16
- Bytes per sector: 128
- Total capacity: ~140KB

This format was used for certain RC-specific software but the file system structure has not been fully documented.

---

## Boot and Initialization Sequence

The RC702 boot process is a multi-stage operation that carefully initializes all hardware components and loads the operating system from floppy disk.

### Stage 1: ROM Bootstrap (Executes at 0x0000)

1. **CPU Reset Vector (0x0000)**
   - Disable interrupts (`DI`)
   - Set stack pointer to 0xBFFF

2. **Self-Relocation**
   - Locate boot code (scan for first non-zero byte after 0x0068)
   - Copy boot loader from ROM (0x0069) to RAM (0x7000)
   - Size: 0x0798 bytes
   - Jump to entry point at 0x70D0

### Stage 2: RAM-Based Initialization (Executes at 0x7000)

#### Interrupt Vector Setup (0x7300)

The bootstrap establishes an interrupt vector table using Z80 Mode 2 interrupts:

```
0x7300  INT0    - Dummy interrupt
0x7302  INT1    - PIO Keyboard interrupt
0x7304  INT2    - Dummy interrupt
0x7306  INT3    - Dummy interrupt
0x7308  INT4    - CTC2 WD1000 hard disk interrupt
0x730A  INT5    - Dummy interrupt
0x730C  INT6    - CRT display interrupt
0x730E  INT7    - FDC floppy disk interrupt
```

#### Hardware Initialization Order

1. **Z80 PIO - Keyboard Interface**
   - Set keyboard interrupt vector
   - Configure Port A as input
   - Enable keyboard interrupts
   - Read PIO data port to clear any pending data

2. **AMD 9517 DMA Controller**
   - Set command options (0x20)
   - Configure Channel 0: WD1000 disk-to-memory transfer
   - Configure Channel 1: Floppy disk-to-memory transfer
   - Configure Channel 2: Memory-to-CRT transfer (auto-initialize mode)
   - Set all channel mask bits (disable all channels initially)

3. **Z80 CTC - Counter/Timer Controller**
   - Set interrupt vector base (0x10)
   - Reset channels 0 and 1
   - Configure Channel 2 for display interrupts (mode 0xD7, count 1)
   - Configure Channel 3 for floppy interrupts (mode 0xD7, count 1)

4. **Z80 CTC2 - Hard Disk Controller Timer**
   - Set interrupt vector (0x08)
   - Configure Channel 0 for WD1000 interrupts
   - Reset channels 1, 2, and 3

5. **Display Buffer Initialization**
   - Initialize display buffer at 0xB020 (DSPSTR)
   - Fill 2,000 bytes with space characters (0x20)
   - Copy "RC700" prompt and color attributes to buffer

6. **Intel 8275 CRT Controller**
   - Reset controller
   - Set parameters:
     - 80 characters per row
     - 25 rows per frame
     - Underline position and character height
     - Cursor format (block, blink, reverse video)
   - Load cursor position (0,0)
   - Preset counters
   - Configure DMA Channel 2 for display refresh
     - Set base address to display buffer (0xB020)
     - Set word count to 0x07CF (2,000 characters)
   - Enable display and show "RC700" prompt

### Stage 3: Boot Device Selection

The system attempts to boot from devices in the following priority order:

1. **Hard Disk Boot (WD1000)**
   - Initialize hard disk controller
   - Issue restore command
   - Wait for ready signal or timeout
   - Check DIP switch bit 7 for forced floppy boot
   - If hard disk fails or timeout, fall through to floppy boot

2. **Floppy Disk Boot**
   - Check DIP switch bit 7 to determine disk size (5.25" vs 8")
   - For 5.25" drives:
     - Read 0x0800 bytes (2KB) from Track 0, Side 0 to RAM address 0x0000
     - Read 0x1000 bytes (4KB) from Track 0, Side 1 to RAM address 0x0800
   - For 8" drives:
     - Read appropriate track 0 data based on format

3. **Disable ROM Mapping**
   - Write to port 0x14 to disable ROM
   - This frees lower memory (0x0000-0x07FF) for operating system use

4. **Transfer Control to Operating System**
   - Jump to bootstrap entry point at address 0x0000
   - The loaded code takes over and continues CP/M bootstrap

### DIP Switch Configuration

**Bit 7:** Disk size selection
- 0 = 8" floppy drives
- 1 = 5.25" floppy drives

Other switch settings control various hardware options but are not documented in available sources.

---

## Hardware Controllers

### NEC uPD765 Floppy Disk Controller

The uPD765 (or Intel 8272 equivalent) is an LSI floppy disk controller capable of interfacing with up to 4 floppy disk drives.

#### Density Format Support

- **FM (Frequency Modulation):** Single density, IBM 3740 format
- **MFM (Modified Frequency Modulation):** Double density, IBM System 34 format
- **Multi-side:** Supports double-sided recording
- **Multi-track:** Can read/write multiple tracks in sequence

#### Data Rate and Clocking

For 4 MHz FDC operation:
- **FM mode:** 250 kHz data rate
- **MFM mode:** 500 kHz data rate

For 8 MHz FDC operation:
- **FM mode:** 500 kHz data rate
- **MFM mode:** 1 MHz data rate

#### Sector Size Support

Variable recording length per sector:
- 128 bytes
- 256 bytes
- 512 bytes
- 1024 bytes
- 2048 bytes
- 4096 bytes
- 8192 bytes

#### DMA Operation

The uPD765 provides handshaking signals for DMA operation:
- Compatible with external DMA controllers (e.g., Intel 8257, AMD 9517)
- Can operate in DMA or non-DMA (programmed I/O) mode
- DMA requests are generated during data transfers

#### Multi-Density Switching

The MFM mode signal controls density:
- **High (logic 1):** MFM double density mode
- **Low (logic 0):** FM single density mode

This signal allows the data recovery circuit to switch between density modes, which is critical for the RC702's mixed-density Track 0 format.

#### Command Set

Key commands relevant to SYSGEN and boot operations:
- **Read Data:** Read sectors from disk
- **Write Data:** Write sectors to disk
- **Format Track:** Format a complete track
- **Read ID:** Read sector header information
- **Seek:** Position head to specified track
- **Recalibrate:** Move head to track 0
- **Sense Drive Status:** Query drive ready status
- **Sense Interrupt Status:** Query interrupt cause

### AMD Am9517A / Intel 8237 DMA Controller

The DMA controller enables high-speed data transfer between memory and I/O devices without CPU intervention.

#### Transfer Capabilities

- **Transfer rate:** Up to 1.6 megabytes per second
- **Channel capacity:** Each channel can address full 64KB memory
- **Transfer size:** Up to 64KB per channel with single programming

#### Four DMA Channels

The 8237 provides four independent DMA channels that can be programmed individually:

**RC702 Channel Assignment:**
- **Channel 0:** WD1000 Winchester hard disk controller
- **Channel 1:** NEC uPD765 floppy disk controller
- **Channel 2:** Intel 8275 CRT controller (display refresh)
- **Channel 3:** Available for expansion

#### Transfer Modes

1. **Single Mode**
   - One DMA cycle per request
   - Interleaves with CPU cycles
   - Continues until word count reaches zero

2. **Block Mode**
   - Continuous transfer until word count reaches zero
   - Or until EOP (End of Process) signal activates
   - Highest transfer rate

3. **Demand Mode**
   - Transfers continue while DRQ (DMA Request) is active
   - Stops when TC (Terminal Count) or EOP activates
   - Or when DRQ goes inactive
   - Optimized for high-speed peripherals

4. **Cascade Mode**
   - Used to cascade additional DMA controllers
   - Expands beyond four channels

#### Programming Registers

Each channel has:
- **Base Address Register** (16-bit): Starting memory address
- **Word Count Register** (16-bit): Number of transfers minus 1
- **Mode Register**: Transfer mode, direction, auto-initialize

Global registers:
- **Command Register**: Controller-wide options
- **Status Register**: Channel status and TC flags
- **Mask Register**: Enable/disable individual channels
- **Request Register**: Software DMA requests

#### RC702-Specific DMA Configuration

**Channel 1 (Floppy):**
- Mode: 0x45 (Transfer disk to memory, increment address)
- Used for reading boot sectors and CP/M system tracks
- DMA address set to 0x0000 during boot
- Word count set based on track/sector size

**Channel 2 (Display):**
- Mode: 0x5A (Memory to display, auto-initialize)
- Base address: 0xB020 (display buffer)
- Word count: 0x07CF (2000 characters = 80×25)
- Auto-initialize mode continuously refreshes display

### Intel 8275 Programmable CRT Controller

The 8275 is a single-chip CRT controller that manages raster scan displays.

#### Primary Functions

- **Display Refresh:** Buffers information from main memory
- **Position Tracking:** Keeps track of screen position
- **DMA Interface:** Requests DMA transfers for row buffer refills

#### Architecture

**Row Buffers:**
- Two 80-character buffers
- Filled from system memory via DMA
- Allows continuous display while CPU accesses memory

**FIFOs:**
- Two 16-character FIFOs
- Provide extra buffering in Transparent Attribute Mode
- Smooths DMA request timing

#### Programmable Parameters

**Screen Format:**
- Characters per row (programmable)
- Rows per frame (programmable)
- Lines per character (affects character height)

**Raster Timing:**
- Derived from character clock input
- All timing parameters set at reset
- Clock provided by external dot timing logic

**Cursor Control:**
- Position (X, Y coordinates)
- Format (block, underline, etc.)
- Blink rate
- Reverse video

#### DMA Operation

**DMA Request Modes:**
- Single character requests
- Burst mode: 2, 4, 8, or 16 character bursts
- Programmable intervals between requests

**RC702 Configuration:**
- Burst mode with auto-initialize
- Continuous refresh from display buffer at 0xB020
- 2000 bytes transferred per frame (80×25 characters)

#### Initialization Sequence

1. Reset controller
2. Load screen format parameters
3. Set cursor position
4. Preset internal counters
5. Configure DMA parameters
6. Start display

---

## Multi-Density Disk Support

The RC702's multi-density disk support is one of its most sophisticated features, requiring careful coordination between SYSGEN and the BIOS.

### Density Mode Definitions

The RC702 uses a disk format descriptor byte to specify the density and sector layout:

```
Disk Format Codes (from SYSGEN.ASM and CPMBOOT.MAC):

0x00/0xFF  - Drive type indicator (0x00=floppy, 0xFF=hard disk)

For maxi (8") floppy disks:
0x08 - DD (Double Density): 512 B/S, 30 S/T  [Standard CP/M format]
0x10 - SS (Single Density): 128 B/S, 26 S/T  [Track 0, Side 0]
0x18 - DD (Double Density): 256 B/S, 26 S/T  [Track 0, Side 1]

For mini (5.25") floppy disks:
0x08 - DD: 512 B/S, 20 S/T
0x10 - DD: 512 B/S, 20 S/T
0x18 - DD: 512 B/S, 30 S/T
```

### SYSGEN Multi-Density Handling

The SYSGEN utility must handle the complex track layout when reading or writing the CP/M system tracks (Track 0 and Track 1).

#### Track 0 Processing

When accessing Track 0, SYSGEN must:

1. **Set density for Track 0, Side 0:**
   - Switch to FM (single density) mode
   - Configure for 128-byte sectors
   - Format code: 0x10

2. **Set density for Track 0, Side 1:**
   - Switch to MFM (double density) mode
   - Configure for 256-byte sectors
   - Format code: 0x18

3. **Read/write 16 sectors per side**

#### Track 1 Processing (Complex Multi-Density)

Track 1 uses an even more complex format with THREE different density zones:

**SYSGEN.ASM defines these parameters:**

```asm
rccpmfmt:      db 08h  ; Normal CP/M format (DD, 512 B/S)
                        ; Restored at exit

rctrk1fmt1:    db 10h  ; Track 1 format for sectors < rcmaxsect1
rctrk1fmt2:    db 18h  ; Track 1 format for sectors > rcmaxsect1

rcmaxsect1:    db 19h  ; Largest sector in part ONE (sector 25)
rcmaxsect2:    db 34h  ; Largest sector in part TWO (sector 52)
rcoffset2:     db 1Ah  ; Offset for sectors in part TWO (26)
```

**Track 1 Sector Mapping:**

- **Sectors 0-25 (0x00-0x19):** Format 0x10 (SS, 128 B/S)
- **Sectors 26-52 (0x1A-0x34):** Format 0x18 (DD, 256 B/S)
- **Sectors 53+ (0x35+):** Format 0x08 (DD, 512 B/S) [actually these are on Track 2+]

The SYSGEN code must dynamically switch density modes while reading/writing Track 1:

```asm
; Pseudocode logic from SYSGEN.ASM:

IF sector < rcmaxsect1 THEN
    format = rctrk1fmt1  ; 0x10 = SS, 128 B/S
ELSE IF sector < rcmaxsect2 THEN
    format = rctrk1fmt2  ; 0x18 = DD, 256 B/S
    actual_sector = sector + rcoffset2
ELSE
    format = rccpmfmt    ; 0x08 = DD, 512 B/S
END IF
```

### Sector Interleaving

The RC702 uses a 2:1 sector interleave on data tracks to optimize performance:

**Physical sector order:** 0, 2, 4, 6, 8, 1, 3, 5, 7

This allows the CPU time to process one sector before the next sector arrives under the read head, reducing the need for full-track rotations.

**Translation Tables:**

SYSGEN.ASM includes two sector translation tables:

1. **minitrans:** For mini (5.25") floppy disks
2. **maxitrans:** For maxi (8") floppy disks

```asm
maxitrans:  db 0, 4, 8, 0Ch, 10h, 14h, 18h
            db 1, 5, 9, 0Dh, 11h, 15h, 19h
            db 2, 6, 0Ah, 0Eh, 12h, 16h
            db 3, 7, 0Bh, 0Fh, 13h, 17h
```

### BIOS Disk Parameter Blocks

The CP/M BIOS maintains Disk Parameter Blocks (DPBs) that define the disk geometry and allocation for each drive and format type. These parameters must match the physical disk format:

**Key DPB fields:**
- **SPT:** Sectors Per Track (logical sectors)
- **BSH/BLM:** Block shift/mask for allocation block size
- **EXM:** Extent mask
- **DSM:** Maximum block number (disk capacity)
- **DRM:** Maximum directory entry number
- **AL0/AL1:** Directory allocation bitmap
- **CKS:** Directory check vector size
- **OFF:** Number of reserved tracks

### Runtime Format Detection

The RC702 BIOS and SYSGEN must detect whether the system is running on:

1. **Mini floppy (5.25"):** DIP switch bit 7 = 1
2. **Maxi floppy (8"):** DIP switch bit 7 = 0

Based on this detection, different translation tables and sector layouts are selected.

### Challenges for SYSGEN

The SYSGEN utility faces several challenges due to this multi-density format:

1. **Dynamic Density Switching:** Must change FDC mode between FM and MFM while reading the same track

2. **Variable Sector Sizes:** Must handle 128, 256, and 512-byte sectors in the same copy operation

3. **Logical-to-Physical Mapping:** Must translate logical CP/M sector numbers to physical disk sectors with correct density mode

4. **Boundary Conditions:** Must carefully handle transitions between density zones, especially on Track 1

5. **BIOS Coordination:** Must match the exact sector layout that the BIOS expects

---

## Implementation Notes for Developers

### SYSGEN Modifications for Multi-Density

The RC702 SYSGEN differs significantly from the standard Digital Research SYSGEN.COM:

1. **Format Detection Code:** Added runtime detection of mini vs. maxi floppy
2. **Multiple Translation Tables:** Separate tables for different disk formats
3. **Track-Specific Formatting:** Special handling for Track 0 and Track 1
4. **Density Switching Logic:** Code to change FDC density mode during track access
5. **BIOS Interface Changes:** Modified to pass format codes to BIOS sector I/O routines

### Bootstrap ROM (ROA375) Development

When developing or modifying the ROA375 autoload ROM:

1. **Size Constraint:** Must fit in 2KB (0x0000-0x07FF)
2. **Self-Relocation:** Must copy itself to RAM before disabling ROM mapping
3. **Hardware Initialization:** Must properly initialize all controllers in correct order
4. **Interrupt Vectors:** Must establish Mode 2 interrupt table before enabling interrupts
5. **Display Early:** Initialize display early for user feedback
6. **Multi-Density Boot:** Must correctly read mixed-density Track 0
7. **Error Handling:** Must gracefully fall back between boot devices

### Testing Considerations

1. **Multi-Density Transitions:** Test reading/writing across density boundaries
2. **Format Detection:** Verify correct operation on both 5.25" and 8" drives
3. **BIOS Compatibility:** Ensure SYSGEN matches exact BIOS sector layout
4. **Edge Cases:** Test boundary sectors (e.g., sector 25/26 on Track 1)
5. **Hardware Variations:** Test with both NEC uPD765 and Intel 8272 FDCs
6. **DMA Timing:** Verify DMA transfers complete before next operation

---

## References and Sources

### Primary Sources

- **RC702 Boot Process:** [http://www.jbox.dk/rc702/boot.shtm](http://www.jbox.dk/rc702/boot.shtm)
- **RC702 Emulator Hardware Specs:** [http://www.jbox.dk/rc702/emulator.shtm](http://www.jbox.dk/rc702/emulator.shtm)
- **RC700 CP/M BIOS:** [http://www.jbox.dk/rc702/rcbios.shtm](http://www.jbox.dk/rc702/rcbios.shtm)
- **RC702 Disk Formats:** [http://www.jbox.dk/rc702/disks.shtm](http://www.jbox.dk/rc702/disks.shtm)
- **RC702 Manuals Collection:** [http://www.jbox.dk/rc702/manuals.shtm](http://www.jbox.dk/rc702/manuals.shtm)
- **RC702 Overview:** [http://www.jbox.dk/rc702/index.shtm](http://www.jbox.dk/rc702/index.shtm)

### Source Code Analysis

- **ROB358.MAC:** RC703 autoloader PROM source code
- **ROA375.MAC:** RC702 autoloader ROM (reconstruction in progress)
- **SYSGEN.ASM:** RC702-modified SYSGEN utility source code

### Hardware Datasheets

#### NEC uPD765 Floppy Disk Controller
- [NEC uPD765 Application Note (PDF)](https://hxc2001.com/download/datasheet/floppy/thirdparty/FDC/NEC/uPD765_App_Note_Mar79.pdf)
- [uPD765 Datasheet OCR'd (CPC Wiki)](https://www.cpcwiki.eu/imgs/f/f3/UPD765_Datasheet_OCRed.pdf)
- [765 FDC - CPCWiki Reference](https://www.cpcwiki.eu/index.php/765_FDC)

#### Intel 8237/AMD 9517 DMA Controller
- [Intel 8237A High Performance DMA Controller (PDF)](https://pdos.csail.mit.edu/6.828/2018/readings/hardware/8237A.pdf)
- [8237 DMA Controller - Lo-tech Wiki](https://www.lo-tech.co.uk/wiki/8237_DMA_Controller)
- [Intel 8237 - Wikipedia](https://en.wikipedia.org/wiki/Intel_8237)

#### Intel 8275 CRT Controller
- [Intel 8275 Programmable CRT Controller (1984) (PDF)](http://bitsavers.informatik.uni-stuttgart.de/components/intel/8275/1984_8275.pdf)
- [Intel 8275 Programmable CRT Controller (1979) (PDF)](https://bitsavers.org/components/intel/8275/1979_8275.pdf)
- [Intel 8275 CRTC - Scribd](https://www.scribd.com/doc/19068954/Intel-8275-CRTC)

### Additional Resources

- **CP/M 2.2 Operating System Manual:** [Digital Research CP/M Documentation](http://www.cpm.z80.de/)
- **Z80 Family CPU and Peripherals User Manual:** Zilog official documentation

---

## Document Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-02-07 | Analysis | Initial document creation from jbox.dk sources and source code analysis |

---

## Appendix A: Quick Reference Tables

### I/O Port Summary

| Port | Device | Function |
|------|--------|----------|
| 0x00 | 8275 | CRT Data Register |
| 0x01 | 8275 | CRT Command Register |
| 0x0C | CTC | Channel 0 |
| 0x0D | CTC | Channel 1 |
| 0x0E | CTC | Channel 2 (Display) |
| 0x0F | CTC | Channel 3 (Floppy) |
| 0x10 | PIO | Keyboard Data |
| 0x12 | PIO | Keyboard Control |
| 0x14 | System | ROM Disable / Switches |
| 0x19 | System | RAM Enable |
| 0x1C | System | Speaker Control |
| 0x44 | CTC2 | Channel 0 (Hard Disk) |
| 0x45 | CTC2 | Channel 1 |
| 0x46 | CTC2 | Channel 2 |
| 0x47 | CTC2 | Channel 3 |
| 0xF0 | DMA | CH0 Address (HD) |
| 0xF1 | DMA | CH0 Word Count |
| 0xF2 | DMA | CH1 Address (FDC) |
| 0xF3 | DMA | CH1 Word Count |
| 0xF4 | DMA | CH2 Address (CRT) |
| 0xF5 | DMA | CH2 Word Count |
| 0xF8 | DMA | Command Register |
| 0xFA | DMA | Single Mask Register |
| 0xFB | DMA | Mode Register |
| 0xFC | DMA | Clear Byte Pointer |
| 0xFF | DMA | Full Mask Register |

### Disk Format Summary

| Format | Tracks | Sides | Encoding | Sect/Trk | Bytes/Sect | Capacity |
|--------|--------|-------|----------|----------|------------|----------|
| 5.25" CP/M Trk 0 Side 0 | 1 | 1 | FM | 16 | 128 | 2 KB |
| 5.25" CP/M Trk 0 Side 1 | 1 | 1 | MFM | 16 | 256 | 4 KB |
| 5.25" CP/M Trk 1-34 | 34 | 2 | MFM | 9 | 512 | 306 KB |
| 8" SS/SD | 77 | 1 | FM | 26 | 128 | 247 KB |
| 8" DS/DD Trk 0 | 1 | 2 | FM/MFM | 26 | 128/256 | 10 KB |
| 8" DS/DD Trk 1-77 | 77 | 2 | MFM | 15 | 512 | 1.2 MB |

### Interrupt Vector Table (Mode 2)

| Vector | Offset | Handler | Source |
|--------|--------|---------|--------|
| 0x00 | 0xA000 | DUMINT | Dummy |
| 0x02 | 0xA002 | KBINT | PIO Keyboard |
| 0x04 | 0xA004 | DUMINT | Dummy |
| 0x06 | 0xA006 | DUMINT | Dummy |
| 0x08 | 0xA008 | HDINT | CTC2 Hard Disk |
| 0x0A | 0xA00A | DUMINT | Dummy |
| 0x0C | 0xA00C | DUMINT | Dummy |
| 0x0E | 0xA00E | DUMINT | Dummy |
| 0x10 | 0xA010 | DUMINT | CTC Channel 0 |
| 0x12 | 0xA012 | DUMINT | CTC Channel 1 |
| 0x14 | 0xA014 | DISINT | CTC Channel 2 Display |
| 0x16 | 0xA016 | FLPINT | CTC Channel 3 Floppy |

---

**END OF DOCUMENT**
