# RC702 CP/M 2.2 BIOS — Clean-Room Implementation Specification

**Purpose:** This document specifies the behavior of a CP/M 2.2 BIOS for the
RC702 microcomputer. It is intended to allow a clean-room implementation by
someone without access to existing RC702 BIOS source code or binaries.

**Target:** RC702/RC703 microcomputer (PCB527 mainboard)
**Operating System:** CP/M 2.2 (Digital Research)
**CPU:** Zilog Z80-A at 4 MHz

**Document Version:** 1.0, 2026-04-10

---

## Table of Contents

1. [System Hardware](#1-system-hardware)
2. [Memory Map](#2-memory-map)
3. [I/O Port Map](#3-io-port-map)
4. [Interrupt Architecture](#4-interrupt-architecture)
5. [CP/M BIOS Entry Points](#5-cpm-bios-entry-points)
6. [Hardware Initialization](#6-hardware-initialization)
7. [Console Driver (Display + Keyboard)](#7-console-driver)
8. [Serial I/O Driver (Printer, Punch, Reader)](#8-serial-io-driver)
9. [Floppy Disk Driver](#9-floppy-disk-driver)
10. [Hard Disk Driver](#10-hard-disk-driver)
11. [Disk Format Specifications](#11-disk-format-specifications)
12. [Boot Sequence](#12-boot-sequence)
13. [Extended BIOS Entry Points](#13-extended-bios-entry-points)
14. [Character Conversion](#14-character-conversion)
15. [Configuration (Track 0 Layout)](#15-configuration)

---

## 1. System Hardware

The RC702 mainboard contains the following chips:

| Chip | Function | I/O Ports |
|------|----------|-----------|
| Z80-A | CPU, 4 MHz | — |
| Z80-PIO | Parallel I/O (keyboard + parallel port) | 0x10–0x13 |
| Z80-CTC | Counter/Timer (baud rates + interrupts) | 0x0C–0x0F |
| Z80-CTC #2 | Counter/Timer (hard disk interrupt) | 0x44–0x47 |
| Z80-SIO/2 | Serial I/O (printer + reader/punch) | 0x08–0x0B |
| Am9517A-4 | DMA controller (4 channels) | 0xF0–0xFF |
| uPD765 | Floppy disk controller | 0x04–0x05 |
| Intel 8275 | CRT display controller | 0x00–0x01 |
| WD1000 | Winchester hard disk controller (optional) | 0x60–0x67 |

Additional hardware signals:

| Port | Function |
|------|----------|
| 0x14 | Switch register: bit 7 = drive type (1=mini/5.25", 0=maxi/8"), bit 0 = mini floppy motor control |
| 0x1C | Bell (any write produces an audible beep) |

---

## 2. Memory Map

The BIOS is designed for a 56K CP/M system (64K RAM minus 8K for CCP+BDOS+BIOS).

### Runtime Layout

```
Address     Size    Contents
---------   -----   ------------------------------------------------
0x0000      3       Warm boot vector: JP WBOOT
0x0003      1       IOBYTE (not used by RC702 BIOS)
0x0004      1       CDISK — current logged-in disk number
0x0005      3       BDOS entry vector: JP BDOS
0x0080      128     Default DMA buffer
0x0100      —       TPA start (Transient Program Area)
0xC400      —       CCP (Console Command Processor)
0xCC06      —       BDOS (Basic Disk Operating System)
0xD480      —       INIT — hardware initialization code + config tables
0xDA00      —       BIOS — jump table and driver code
```

### BIOS Variable Area (above code)

```
Address     Size    Contents
---------   -----   ------------------------------------------------
0xEE81      512     HSTBUF — host disk sector buffer
0xF081      128     DIRBF — directory scratch area (shared by all drives)
0xF101      —       Allocation and check vectors for all drives
0xF500      250     BGSTAR — semi-graphics background bit table
0xF620      96      Interrupt stack (grows downward)
0xF680      128     OUTCON — output character conversion table
0xF700      128     INCONV — input character conversion table
0xF800      2000    DSPSTR — display refresh memory (80 × 25)
0xFFD1      —       Display control variables (cursor position, state)
0xFFFC      4       Real-time clock (32-bit counter, 50 Hz tick)
```

---

## 3. I/O Port Map

### PIO (Z80 Parallel I/O)

| Port | Register |
|------|----------|
| 0x10 | Channel A Data (keyboard input) |
| 0x11 | Channel B Data (parallel output) |
| 0x12 | Channel A Control |
| 0x13 | Channel B Control |

### CTC (Z80 Counter/Timer Circuit)

| Port | Channel | Function |
|------|---------|----------|
| 0x0C | CTC Ch.0 | SIO Channel A baud rate generator |
| 0x0D | CTC Ch.1 | SIO Channel B baud rate generator |
| 0x0E | CTC Ch.2 | Display refresh / system tick (50 Hz) |
| 0x0F | CTC Ch.3 | Floppy disk interrupt trigger |

### CTC #2 (hard disk systems only)

| Port | Channel | Function |
|------|---------|----------|
| 0x44 | CTC2 Ch.0 | Hard disk interrupt trigger |
| 0x45 | CTC2 Ch.1 | Unused |
| 0x46 | CTC2 Ch.2 | Unused |
| 0x47 | CTC2 Ch.3 | Unused |

### SIO (Z80 Serial I/O)

| Port | Register |
|------|----------|
| 0x08 | Channel A Data (reader/punch) |
| 0x09 | Channel B Data (printer) |
| 0x0A | Channel A Control |
| 0x0B | Channel B Control |

### DMA (Am9517A-4)

| Port | Register |
|------|----------|
| 0xF0/0xF1 | Channel 0: Address / Word Count (hard disk) |
| 0xF2/0xF3 | Channel 1: Address / Word Count (floppy disk) |
| 0xF4/0xF5 | Channel 2: Address / Word Count (display) |
| 0xF6/0xF7 | Channel 3: Address / Word Count (display) |
| 0xF8 | Command/Status Register |
| 0xF9 | Request Register |
| 0xFA | Single Mask Register |
| 0xFB | Mode Register |
| 0xFC | Clear Byte Pointer Flip-Flop |
| 0xFF | All Channel Mask Register |

### Display Controller (Intel 8275)

| Port | Register |
|------|----------|
| 0x00 | Data (FIFO read/write) |
| 0x01 | Command/Status |

### Floppy Disk Controller (uPD765)

| Port | Register |
|------|----------|
| 0x04 | Main Status Register (read) |
| 0x05 | Data Register (read/write) |

### Hard Disk Controller (WD1000)

| Port | Read | Write |
|------|------|-------|
| 0x60 | Data | Data |
| 0x61 | Error Register | Write Precompensation |
| 0x62 | Sector Count | Sector Count |
| 0x63 | Sector Number | Sector Number |
| 0x64 | Cylinder Low | Cylinder Low |
| 0x65 | Cylinder High | Cylinder High |
| 0x66 | Size/Drive/Head | Size/Drive/Head |
| 0x67 | Status | Command |

---

## 4. Interrupt Architecture

The Z80 operates in **Interrupt Mode 2**. The I register points to a page
containing an 18-entry vector table (36 bytes, 2 bytes per entry):

| Index | Source | Purpose |
|-------|--------|---------|
| 0 | CTC Ch.0 | Dummy (baud rate, no ISR needed) |
| 1 | CTC Ch.1 | Dummy (baud rate, no ISR needed) |
| 2 | CTC Ch.2 | Display refresh + system tick |
| 3 | CTC Ch.3 | Floppy disk operation complete |
| 4 | CTC2 Ch.0 | Hard disk operation complete |
| 5 | CTC2 Ch.1 | Dummy |
| 6 | CTC2 Ch.2 | Dummy |
| 7 | CTC2 Ch.3 | Dummy |
| 8 | SIO Ch.B TX | Printer transmit buffer empty |
| 9 | SIO Ch.B EXT | Printer external status change |
| 10 | SIO Ch.B RX | Printer receive (unused) |
| 11 | SIO Ch.B SPEC | Printer special/error |
| 12 | SIO Ch.A TX | Reader/punch transmit buffer empty |
| 13 | SIO Ch.A EXT | Reader/punch external status change |
| 14 | SIO Ch.A RX | Reader data received |
| 15 | SIO Ch.A SPEC | Reader special/error |
| 16 | PIO Ch.A | Keyboard key pressed |
| 17 | PIO Ch.B | Parallel port ready |

The vector table must be aligned to a 256-byte boundary (or at minimum a
32-byte boundary, depending on the CTC vector base requirements).

Systems without hard disk omit CTC2 entries 4–7, and the SIO vector base
shifts from 0x10 to 0x08 accordingly.

### Display Refresh ISR (CTC Ch.2, 50 Hz)

This ISR is called at the display vertical retrace rate (50 Hz). It must:

1. Reprogram DMA channels 2 and 3 with the display buffer address (DSPSTR)
   and transfer count for the next frame
2. Send the "Start Display" command (0x23) to the 8275
3. Update cursor position on the 8275
4. Decrement the real-time clock countdown timers:
   - EXCNT0: general-purpose exit timer (calls a callback when it reaches 0)
   - EXCNT1: floppy motor stop timer
   - DELCNT: delay timer
5. Increment the 32-bit real-time clock at 0xFFFC

### Floppy ISR (CTC Ch.3)

Set a flag (FL_FLG) indicating the floppy operation has completed. The main
FDC driver polls this flag.

### Hard Disk ISR (CTC2 Ch.0)

Set a flag (HD_FLG) indicating the hard disk operation has completed. Also
read and save the WD1000 status and error registers.

### Keyboard ISR (PIO Ch.A)

Read the key code from PIO Port A data and store it for the CONIN routine.

---

## 5. CP/M BIOS Entry Points

The BIOS provides a jump table at its base address (0xDA00 for 56K):

| Offset | Name | Parameters | Returns | Function |
|--------|------|-----------|---------|----------|
| +0x00 | BOOT | — | — | Cold boot |
| +0x03 | WBOOT | — | — | Warm boot |
| +0x06 | CONST | — | A=0xFF if char ready, 0 if not | Console status |
| +0x09 | CONIN | — | A=character | Console input (waits) |
| +0x0C | CONOUT | C=character | — | Console output |
| +0x0F | LIST | C=character | — | Printer output |
| +0x12 | PUNCH | C=character | — | Punch output (SIO Ch.A TX) |
| +0x15 | READER | — | A=character | Reader input (SIO Ch.A RX) |
| +0x18 | HOME | — | — | Home disk (seek track 0) |
| +0x1B | SELDSK | C=disk number | HL=DPH address, or 0 if error | Select disk |
| +0x1E | SETTRK | BC=track number | — | Set track |
| +0x21 | SETSEC | BC=sector number | — | Set sector |
| +0x24 | SETDMA | BC=DMA address | — | Set DMA address |
| +0x27 | READ | — | A=0 success, 1 error | Read sector |
| +0x2A | WRITE | C=write type (0,1,2) | A=0 success, 1 error | Write sector |
| +0x2D | LISTST | — | A=0xFF if ready, 0 if busy | Printer status |
| +0x30 | SECTRAN | BC=logical sector, DE=XLT table | HL=physical sector | Sector translate |

---

## 6. Hardware Initialization

The BIOS initialization code runs once at cold boot and must configure all
hardware in this order:

### 6.1 PIO Initialization

| Step | Port | Value | Purpose |
|------|------|-------|---------|
| 1 | 0x12 | 0x4F | Channel A: input mode |
| 2 | 0x12 | 0x83 | Channel A: enable interrupts |
| 3 | 0x13 | 0x0F | Channel B: output mode |
| 4 | 0x13 | 0x83 | Channel B: enable interrupts |
| 5 | 0x12 | interrupt vector | Channel A: set interrupt vector |
| 6 | 0x13 | interrupt vector+2 | Channel B: set interrupt vector |

### 6.2 CTC Initialization

Program each channel with a mode byte followed by a count byte:

| Channel | Mode | Count | Purpose |
|---------|------|-------|---------|
| Ch.0 | 0x47 | 0x20 | Timer mode, 1200 baud for SIO Ch.A |
| Ch.1 | 0x47 | 0x20 | Timer mode, 1200 baud for SIO Ch.B |
| Ch.2 | 0xD7 | 0x01 | Counter mode, display refresh trigger |
| Ch.3 | 0xD7 | 0x01 | Counter mode, floppy interrupt trigger |

CTC Ch.0 also receives the interrupt vector base (written before the mode byte).

### 6.3 SIO Initialization

Program each channel using OTIR (block output) sequences of register-number,
value pairs:

**Channel A (Reader/Punch):**
```
WR0: 0x18   (channel reset)
WR4: 0x47   (1 stop bit, even parity, 16× clock)
WR3: 0x61   (RX enable, auto-enable, 7-bit character)
WR5: 0x20   (TX disable, 7-bit, DTR/RTS off)
WR1: 0x1B   (RX, TX, external status interrupts enabled)
```

**Channel B (Printer):**
```
WR0: 0x18   (channel reset)
WR2: vector  (interrupt vector base)
WR4: 0x47   (1 stop bit, even parity, 16× clock)
WR3: 0x60   (auto-enable, 7-bit, RX disabled)
WR5: 0x20   (TX disable, 7-bit, DTR/RTS off)
WR1: 0x1F   (all interrupts, status-affects-vector enabled)
```

### 6.4 DMA Initialization

| Step | Port | Value | Purpose |
|------|------|-------|---------|
| 1 | 0xF8 | 0x00 | Master clear |
| 2 | 0xFB | 0x48 | Channel 0 mode: single, read (hard disk) |
| 3 | 0xFB | 0x49 | Channel 1 mode: single, read (floppy) |
| 4 | 0xFB | 0x4A | Channel 2 mode: single, read (display) |
| 5 | 0xFB | 0x4B | Channel 3 mode: single, read (display) |

### 6.5 FDC Initialization

Send the SPECIFY command (0x03) followed by two parameter bytes:

| Byte | Value | Meaning |
|------|-------|---------|
| Command | 0x03 | SPECIFY |
| SRT/HUT | 0xDF | Step Rate Time = 3ms, Head Unload Time = 240ms |
| HLT/DMA | 0x28 | Head Load Time = 40ms, DMA mode |

Wait for the FDC main status register (port 0x04) to show RQM=1, DIO=0
before sending each byte.

### 6.6 Display Controller (8275) Initialization

| Step | Action | Value |
|------|--------|-------|
| 1 | Reset | OUT (0x01), 0x00 |
| 2 | Set parameters | OUT (0x01), 0x20 (set parameter command) |
| 3 | PAR1 | OUT (0x01), 0x4F (80 chars/row) |
| 4 | PAR2 | OUT (0x01), 0x98 (25 rows + retrace) |
| 5 | PAR3 | OUT (0x01), 0x7A (11 scan lines/char, underline at 8) |
| 6 | PAR4 | OUT (0x01), 0x4D (blinking block cursor) |
| 7 | Preset counters | OUT (0x01), 0xE0 |
| 8 | Clear display | Fill DSPSTR with spaces (0x20), 2000 bytes |
| 9 | Start display | OUT (0x01), 0x23 |

---

## 7. Console Driver

### 7.1 Display Output (CONOUT)

Characters are written to the display buffer at DSPSTR (0xF800). The display
ISR refreshes the physical screen from this buffer via DMA at 50 Hz.

**Character processing:**
- Characters 0x20–0x7F: display directly (after conversion table lookup)
- Characters 0x00–0x1F: control characters (see table below)
- Characters 0x80–0xBF: semi-graphics characters
- Characters 0xC0–0xFF: display attribute codes

**Control characters:**

| Code | Name | Action |
|------|------|--------|
| 0x01 | SOH | Insert line at cursor, shift lines below down |
| 0x03 | ETX | Delete line at cursor, shift lines below up |
| 0x05 | ENQ | Cursor left (wrap to end of previous line) |
| 0x06 | ACK | Start XY addressing mode (next 2 bytes are coordinates) |
| 0x07 | BEL | Sound bell (write to port 0x1C) |
| 0x08 | BS | Cursor left (same as 0x05) |
| 0x09 | TAB | Move cursor right 4 positions |
| 0x0A | LF | Cursor down; scroll up if at bottom row |
| 0x0C | FF | Clear screen (fill with spaces, home cursor) |
| 0x0D | CR | Move cursor to column 0 of current row |
| 0x19 | EM | Cursor right (wrap to start of next line) |
| 0x1A | SUB | Cursor up (no wrap past top) |
| 0x1B | ESC | Home cursor to row 0, column 0 |
| 0x1C | FS | Erase from cursor to end of line |
| 0x1D | GS | Erase from cursor to end of screen |

**XY addressing (after 0x06):**
The next two bytes received are cursor coordinates. ADRMOD selects the order:
0 = (column, row), 1 = (row, column). Column range: 0–79. Row range: 0–24.

**Scrolling:**
When the cursor moves below the last row (row 24), scroll the entire display
up by one line: copy rows 1–24 to rows 0–23, clear row 24. Also scroll the
semi-graphics bit table accordingly.

### 7.2 Keyboard Input (CONIN / CONST)

The keyboard sends 8-bit character codes via PIO Channel A. When a key is
pressed, the PIO triggers an interrupt (ASTB strobe). The ISR reads the key
code from port 0x10 and sets a ready flag.

CONST returns 0xFF if a key is ready, 0x00 if not.
CONIN waits until a key is ready, then returns it (after input conversion
table lookup). The returned character has bit 7 cleared.

---

## 8. Serial I/O Driver

### 8.1 Printer (LIST / LISTST)

The printer is connected to **SIO Channel B** (ports 0x09/0x0B).

LIST sends a character by:
1. Writing WR5 with DTR=1, RTS=1, TX enable=1 (value 0xAA)
2. Writing the character to the SIO data port (0x09)
3. Waiting for the TX buffer empty interrupt

LISTST returns 0xFF if the printer is ready (previous character sent), 0x00
if busy.

### 8.2 Punch (PUNCH)

The punch uses **SIO Channel A TX** (port 0x08). Same protocol as LIST but
on Channel A.

### 8.3 Reader (READER / READS)

The reader uses **SIO Channel A RX** (port 0x08).

READER waits for a character to be received (interrupt-driven). The RX
interrupt handler reads the character from the SIO data port and stores it.

READS returns 0xFF if a character is available, 0x00 if not.

### 8.4 Serial Configuration

Default configuration: 1200 baud, 7 data bits, even parity, 1 stop bit.

---

## 9. Floppy Disk Driver

### 9.1 Sector Deblocking

CP/M operates on 128-byte logical sectors. The RC702 floppy formats use
256-byte or 512-byte physical sectors. The BIOS uses the standard Digital
Research blocking/deblocking algorithm from the **CP/M 2.2 Alteration Guide**
(Appendix G: "Blocking and Deblocking"). This is not RC702-specific — the
algorithm, variable names (HSTBUF, HSTACT, HSTWRT, UNACNT, UNADSK, etc.),
and write-type semantics are taken directly from the DR sample code.

The algorithm maintains a single host-sector buffer (HSTBUF, 512 bytes):

1. **READ:** If the requested host sector is already in HSTBUF, copy the
   appropriate 128-byte portion to the DMA buffer. Otherwise, read the
   physical sector into HSTBUF first.
2. **WRITE:** Write the 128-byte data into the appropriate portion of
   HSTBUF. If the host sector changed, flush the previous sector to disk
   first. Flush is deferred until a different sector is needed (write-back
   caching).
3. **Write types:** Type 0 = deferred write, Type 1 = directory write
   (flush immediately), Type 2 = first sector of unallocated block (no
   pre-read needed).

Refer to the CP/M 2.2 Alteration Guide for the complete algorithm. An
implementor should use the DR sample code directly and adapt only the
physical disk read/write routines for the RC702 hardware.

### 9.2 FDC Commands

All FDC communication follows the uPD765 protocol:

**Sending a command byte:**
1. Read main status register (port 0x04)
2. Wait until RQM=1 and DIO=0 (value 0x80 masked with 0xC0)
3. Write command byte to data register (port 0x05)

**Reading a result byte:**
1. Read main status register (port 0x04)
2. Wait until RQM=1 and DIO=1 (value 0xC0 masked with 0xC0)
3. Read data register (port 0x05)
4. Continue reading while CB (bit 4) is set in the main status register

**Read/Write command sequence (9 bytes out, 7 bytes result):**
```
Byte 1: Command + MF flag (0x46 = read MFM, 0x45 = write MFM,
                            0x06 = read FM, 0x05 = write FM)
Byte 2: Head/Drive select (bits 2-0 = drive, bit 2 = head)
Byte 3: Cylinder number
Byte 4: Head number
Byte 5: Sector number (1-based)
Byte 6: Sector size code (N: 0=128, 1=256, 2=512)
Byte 7: End of track (last sector number on track)
Byte 8: Gap length
Byte 9: Data length (0xFF for standard, 0x80 for FM 128-byte)
```

**Result bytes:** ST0, ST1, ST2, C, H, R, N

### 9.3 DMA Setup for Floppy

- **DMA Channel:** 1
- **Read (disk→memory):** Mode 0x49 (single transfer, read, channel 1)
- **Write (memory→disk):** Mode 0x45 (single transfer, write, channel 1)

Setup sequence:
1. OUT (0xFC), any — clear byte pointer flip-flop
2. OUT (0xF2), addr_low — channel 1 address low byte
3. OUT (0xF2), addr_high — channel 1 address high byte
4. OUT (0xF3), count_low — channel 1 count low byte
5. OUT (0xF3), count_high — channel 1 count high byte
6. OUT (0xFB), mode — set channel mode
7. OUT (0xFA), 0x01 — unmask channel 1

### 9.4 Motor Control (5.25" Mini Floppy Only)

Mini floppy drives require software motor control via port 0x14 bit 0:
- **Motor on:** OUT (0x14), 0x01; wait ~300ms (15 timer ticks at 50 Hz)
- **Motor off:** OUT (0x14), 0x00
- **Auto-off timer:** 5 seconds of inactivity (250 ticks at 50 Hz)

Maxi (8") drives have always-on motors; skip motor control.

### 9.5 Error Recovery

On a read or write error:
1. Retry up to 10 times
2. After 5 failures, recalibrate the drive (seek to track 0)
3. After recalibration, retry the remaining attempts
4. If ST0 bit 3 (Equipment Check) is set, abort immediately (hard error)
5. Return error flag to caller

### 9.6 Sector Translation

CP/M logical sectors are mapped to physical sectors using translation tables.
The SECTRAN entry point performs this mapping. Different disk formats use
different skew factors:

| Format | Sectors | Skew | Purpose |
|--------|---------|------|---------|
| 8" SS FM | 26 | 6 | Track 0 side 0 |
| 8" DD MFM | 15 | 4 | Data tracks (×4 for CP/M 128-byte sectors) |
| 5.25" DD MFM | 9 | 2 | Data tracks (×4 for CP/M 128-byte sectors) |
| Identity | — | 1 | No translation (hard disk, some track 0 formats) |

---

## 10. Hard Disk Driver

### 10.1 WD1000 Command Protocol

1. Wait for READY (status bit 6) and SEEK COMPLETE (status bit 4)
2. Load the task file registers:
   - 0x61: Write precompensation cylinder
   - 0x62: Sector count (1 for single-sector operations)
   - 0x63: Sector number (physical)
   - 0x64: Cylinder low byte
   - 0x65: Cylinder high byte (bits 1-0 only)
   - 0x66: Size/Drive/Head (bit 5 = 512-byte sectors, bits 4-3 = drive, bits 2-0 = head)
3. Set up DMA channel 0 for the transfer
4. Write the command to port 0x67
5. Wait for the interrupt (CTC2 Ch.0)

### 10.2 WD1000 Commands

| Command | Code | Purpose |
|---------|------|---------|
| RESTORE | 0x10 + step_rate | Seek to track 0 |
| SEEK | 0x70 + step_rate | Seek to specified cylinder |
| READ | 0x28 | Read sector via DMA |
| WRITE | 0x30 | Write sector via DMA |
| FORMAT | 0x50 | Format track |

Step rate field (bits 3-0): rate × 0.5ms. Value 1 = 0.5ms (fastest).

### 10.3 DMA Setup for Hard Disk

- **DMA Channel:** 0
- **Read (disk→memory):** Mode 0x44
- **Write (memory→disk):** Mode 0x48

### 10.4 Logical-to-Physical Mapping

The BIOS maps CP/M logical sectors to physical hard disk sectors:
- Divide the CP/M sector number by sectors-per-page to get the head number
- The remainder is the physical sector within the page
- The track number maps directly to the cylinder

### 10.5 Configuration Sector

The hard disk configuration is stored in **sector 124 of the hard disk**. At
boot, the BIOS reads this sector and uses it to configure drive parameters
(format types, track offsets, partition sizes). If the configuration sector
cannot be read, the hard disk is marked offline.

---

## 11. Disk Format Specifications

### 11.1 Mini (5.25") Disk Format

| Track/Side | Encoding | Sectors | Bytes/Sector | Total |
|------------|----------|---------|--------------|-------|
| Track 0, Side 0 | FM (single density) | 16 | 128 | 2,048 |
| Track 0, Side 1 | MFM (double density) | 16 | 256 | 4,096 |
| Tracks 1–34, both sides | MFM (double density) | 9 | 512 | 4,608/track |

Total capacity: ~319 KB

### 11.2 Maxi (8") Disk Format

| Track/Side | Encoding | Sectors | Bytes/Sector | Total |
|------------|----------|---------|--------------|-------|
| Track 0, Side 0 | FM (single density) | 26 | 128 | 3,328 |
| Track 0, Side 1 | MFM (double density) | 26 | 256 | 6,656 |
| Tracks 1–76, both sides | MFM (double density) | 15 | 512 | 7,680/track |

Total capacity: ~1.2 MB

### 11.3 Disk Parameter Blocks

CP/M requires a Disk Parameter Block (DPB) for each disk format. Key fields:

| Field | Description |
|-------|-------------|
| SPT | Logical sectors per track (in 128-byte CP/M records) |
| BSH | Block shift factor (log2 of block size / 128) |
| BLM | Block mask (2^BSH - 1) |
| EXM | Extent mask |
| DSM | Total blocks - 1 (storage capacity) |
| DRM | Directory entries - 1 |
| AL0, AL1 | Directory allocation bitmap |
| CKS | Check vector size (DRM+1)/4 for removable media, 0 for fixed |
| OFF | Number of reserved tracks |

**Mini 5.25" main data format (DD 512B sectors, tracks 1+):**
```
SPT=72, BSH=4, BLM=15, EXM=1, DSM=152, DRM=127,
AL0=0xC0, AL1=0x00, CKS=32, OFF=2
```

**Maxi 8" main data format (DD 512B sectors, tracks 1+):**
```
SPT=120, BSH=4, BLM=15, EXM=0, DSM=561, DRM=127,
AL0=0xC0, AL1=0x00, CKS=32, OFF=2
```

### 11.4 FDC Parameters per Format

| Format | N | EOT | GPL | MF | DMA Count |
|--------|---|-----|-----|----|-----------|
| Mini FM 128B | 0 | 16 | 7 | 0x00 | 127 |
| Mini MFM 256B | 1 | 16 | 14 | 0x40 | 255 |
| Mini MFM 512B | 2 | 9 | 27 | 0x40 | 511 |
| Maxi FM 128B | 0 | 26 | 7 | 0x00 | 127 |
| Maxi MFM 256B | 1 | 26 | 14 | 0x40 | 255 |
| Maxi MFM 512B | 2 | 15 | 27 | 0x40 | 511 |

---

## 12. Boot Sequence

### 12.1 Cold Boot

1. Set SP to 0x0080 (DMA buffer, temporary stack)
2. Display signon message on screen
3. Initialize CDISK = 0 (drive A:)
4. Clear disk state variables (HSTACT, ERFLAG, HSTWRT = 0)
5. Read switch register (port 0x14 bit 7):
   - If bit 7 = 0: maxi (8") drives → go directly to warm boot
   - If bit 7 = 1: mini (5.25") drives → check if drive B: is online
6. Fall through to warm boot

### 12.2 Warm Boot

1. Enable interrupts
2. Select boot drive (A: for floppy, C: for hard disk)
3. Clear UNACNT, IOBYTE, DSKNO, KEYFLG
4. Home the selected drive (seek track 0)
5. Set DMA address to CCP base (0xC400)
6. Read track 1 from sector 0, loading 44 sectors (CCP + BDOS = 5,632 bytes)
7. Install warm boot vector at 0x0000: `JP WBOOT`
8. Install BDOS entry at 0x0005: `JP BDOS`
9. Restore current disk from CDISK
10. Jump to CCP

If a read error occurs during warm boot, display "Disk read error - reset"
and halt (infinite loop).

---

## 13. Extended BIOS Entry Points

Beyond the standard CP/M 2.2 jump table, the RC702 BIOS provides additional
entry points:

| Offset | Name | Parameters | Function |
|--------|------|-----------|----------|
| +0x33 | WFITR | — | Wait for FDC interrupt (used by FORMAT utility) |
| +0x36 | READS | — | Reader status (A=0xFF ready, 0 not) |
| +0x39 | LINSEL | A=port, B=line | Line selector (RC791 A/B switch) |
| +0x3C | EXIT | HL=callback, DE=count | Install timer callback |
| +0x3F | CLOCK | A=0 set, A≠0 read; DE,HL=time | Read/set 32-bit RTC |
| +0x42 | HRDFMT | — | Format hard disk track |

### 13.1 EXIT Routine

Installs a callback function that the display ISR will call after a specified
number of 20ms ticks (50 Hz). Used for floppy motor auto-off and other timed
events. DE = tick count, HL = callback address.

### 13.2 CLOCK Routine

Reads or sets the 32-bit real-time clock at 0xFFFC–0xFFFF. The clock
increments at 50 Hz (20ms per tick). To read: call with A≠0, returns
DE=low word, HL=high word. To set: call with A=0, DE=low word, HL=high word.

### 13.3 LINSEL Routine (Line Selector)

Controls the external RC791 line selector via SIO DTR/RTS signaling:
- A=0 for SIO Ch.A, A=1 for SIO Ch.B
- B=0 release, B=1 select line A, B=2 select line B
- Returns A=0xFF if selected line responded (CTS asserted), 0 if not

Protocol: wait for TX idle → release DTR/RTS → set RTS based on line →
assert DTR → wait → check CTS.

---

## 14. Character Conversion

The BIOS applies two 128-byte lookup tables for character conversion:

- **OUTCON** (0xF680): maps character codes before display output
- **INCONV** (0xF700): maps keyboard scan codes to character codes

These tables are loaded from **Track 0 sectors 3–5** during initialization.
They implement national character sets (Danish, Swedish, German, UK ASCII,
US ASCII, French). The CONFI utility allows the user to switch between
character sets by modifying the Track 0 configuration sector.

---

## 15. Configuration

### 15.1 Track 0 Layout

Track 0, Side 0 contains the system bootstrap and configuration:

| Sector | Bytes | Contents |
|--------|-------|----------|
| 1 | 0–1 | Start address (entry point for ROM bootstrap) |
| 1 | 2–7 | Reserved (zero) |
| 1 | 8–13 | Machine identifier ('RC702 ' or 'RC703 ') |
| 1 | 14–127 | Reserved for ROM bootstrap loader |
| 2 | 0–127 | Configuration parameters (disk formats, baud rates, etc.) |
| 3 | 0–127 | Output character conversion table |
| 4–5 | 0–127 | Input character conversion table (256 bytes total) |
| 6+ | — | Hardware initialization code + CP/M BIOS |

### 15.2 Configuration Parameters (Sector 2)

The configuration sector contains:

| Offset | Size | Parameter |
|--------|------|-----------|
| 0 | 1 | Cursor number (style) |
| 1 | 1 | Character conversion table selection |
| 2 | 1 | Baud rate code, SIO Channel A |
| 3 | 1 | Baud rate code, SIO Channel B |
| 4 | 1 | Address mode (0=XY, 1=YX) |
| 5 | 1 | SIO Channel A write register 5 value |
| 6 | 1 | SIO Channel B write register 5 value |
| 7 | 1 | Machine type (0=RC700, 1=RC850, 2=ITT3290, 3=RC703) |
| 8–23 | 16 | Drive format indices (FD0–FD15), 255=not configured |
| 24 | 1 | Boot disk (0=floppy, non-zero=hard disk) |

### 15.3 Drive Format Index

Each drive's format index (FD0–FD15) selects a format descriptor:

| Index | Mini (5.25") | Maxi (8") |
|-------|-------------|-----------|
| 0 | SS FM 128B (unused) | SS FM 128B |
| 8 | DD MFM 512B | DD MFM 512B |
| 16 | DD MFM 512B (data tracks) | SS FM 128B (track 0 side 0) |
| 24 | 8" DD 512B (maxi compat) | DD MFM 256B (track 0 side 1) |
| 32 | Hard disk 1 MB unit | Hard disk 1 MB unit |
| 40 | Hard disk 0.8 MB unit | Hard disk 0.8 MB unit |
| 48 | Hard disk 2 MB unit | Hard disk 2 MB unit |
| 56 | Hard disk 4 MB unit | Hard disk 4 MB unit |
| 64 | Hard disk 8 MB unit | Hard disk 8 MB unit |
| 255 | Drive not configured | Drive not configured |

---

## References

- Digital Research: CP/M 2.2 Interface Guide (BIOS entry points, DPB format)
- Zilog: Z80 CPU User Manual (instruction set, interrupt modes)
- Zilog: Z80 PIO Technical Manual (mode programming, interrupt protocol)
- Zilog: Z80 CTC Technical Manual (timer/counter modes)
- Zilog: Z80 SIO Technical Manual (register programming, baud rate generation)
- Intel: 8275 Programmable CRT Controller datasheet (command set, DMA interface)
- NEC: uPD765 Floppy Disk Controller datasheet (command protocol, status registers)
- AMD: Am9517A DMA Controller datasheet (channel programming, transfer modes)
- Western Digital: WD1000 Winchester Disk Controller (command set, task file)
