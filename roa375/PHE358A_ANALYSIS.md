# PHE358A.MAC Analysis — RC702E Autoload with Memory Disk and Character Generator

## Overview

PHE358A.MAC is a modified version of the RC703 autoload PROM (`rob358.mac`), revised by **Stig Christensen on 24 October 1987** for a custom RC702 variant designated **"RC702E"**. The two major changes are:

1. **Hard disk (WD1000) boot replaced by memory disk (RAM disk) boot**
2. **Character generator loading for the SEM702 display**

The banner string identifies this as `RC702E  Autoload Version 3.0`.

---

## What Was Removed

### WD1000 Hard Disk Controller Support (Entire Subsystem)

All hard disk code from rob358.mac is stripped out:

| Removed Component | Description |
|---|---|
| **I/O ports 0x61–0x67** | WD1000 Winchester controller registers (HWPCMD, HSECCT, HSECNO, HCYLLO, HCYLHI, HSZDHD, HCMDRG/HDSTAT, HDERR) |
| **CTC2 init (ports 0x44–0x47)** | Second CTC used solely for WD1000 interrupt routing |
| **HDINT ISR** | Hard disk interrupt handler; interrupt table entry changed from `HDINT` to `DUMINT` |
| **HDREST** | Hard disk restore (recalibrate) procedure |
| **STSKFL** | WD1000 task file setup procedure |
| **HD boot sequence** | Config sector read (cyl 0, head 1, sec 15), boot sector validation, 16-sector system load |
| **HD_FLG, T_FLG, HD$RDY** | Hard disk interrupt flag, test mode flag, ready flag variables |

### Test PROM Support

The keyboard handler no longer recognizes `T` to force a jump to the test PROM at 0x2000. The `T_FLG` variable and all `JP NZ,ROM2` branches are removed. (The `ROM2 EQU 2000H` constant is retained but repurposed as the character generator font data source address.)

### Floppy Timeout via BC Countdown

The BC-register-based busy loops (`LD BC,0FFFFH` / `DEC BC`) for floppy timeouts are replaced by a CRT-interrupt-driven `TIMER` variable (see below).

---

## New Device: Memory Disk (RAM Disk)

### I/O Ports

| Port | R/W | Name | Function |
|------|-----|------|----------|
| **0xEE** | W | MDTRK | Track register — writing clears any pending error |
| **0xEE** | R | MDST | Status register |
| **0xEF** | W | MDSEC | Sector register — writing starts the DMA transfer |

### Status Register (port 0xEE, read)

| Bits | Meaning |
|------|---------|
| 0 | Parity error |
| 1 | Busy (transfer in progress) |
| 7–2 | Number of tracks (shifted right by 2: `AND 0FCH` gives track count) |

When bits 7–2 are zero, no memory disk is present (device not installed).

### DMA Interface

The memory disk uses **DMA Channel 0** (the same channel the WD1000 hard disk previously used):

| Mode | Value | Direction |
|------|-------|-----------|
| Read (disk→memory) | 0x44 | MODE0, same as original |
| Write (memory→disk) | 0x48 | New mode for memory disk writes |

The DMA command register value is changed from **0x20** (rob358) to **0x10** (PHE358A), likely reflecting different DMA priority/timing requirements for the memory disk.

A new port is used: `DMAREQ EQU 0F9H` (DMA software request register), used to force a DMA request during initial device detection.

### Transfer Protocol

1. Set DMA channel 0: address, byte count, mode (read or write)
2. Clear channel 0 mask bit to enable DMA
3. Write track number to MDTRK (port 0xEE) — also clears errors
4. Write sector number to MDSEC (port 0xEF) — **this starts the transfer**
5. Poll MDST bit 1 (busy) until clear
6. Check MDST bit 0 for parity error

### Disk Geometry

| Parameter | Value |
|-----------|-------|
| Sector size | 1024 bytes (inferred from format: `1024*16-1` = 16383 bytes per track) |
| Sectors per track | 16 |
| Track count | Variable, read from status register bits 7–2 |
| Bytes per track | 16,384 (16 × 1024) |

### Boot Sequence

The memory disk boot replaces the hard disk boot and runs **before** the floppy boot:

1. **Detection**: Read 10 bytes from track 0, sector 0 using DMA channel 0
2. **DMA wait**: Busy-wait with DJNZ loop, then check DMA terminal count (bit 0 of DMACOM)
3. **Fallback**: If DMA times out, force a DMA request via port 0xF9 and fall through to floppy boot
4. **Status check**: If parity error (status bit 0), call `MDFORM` to format the disk
5. **Boot load**: Read 8191 bytes (`BIOSL EQU 8192`, count is BIOSL-1) from track 0, sector 128 into address 0x0000
6. **Enable RAM**, start floppy motor, wait for floppy disk insertion
7. **Jump to boot address**: `LD HL,(0) / JP (HL)` — same boot handoff as hard disk/floppy paths

The sector 128 offset for the boot image suggests that the memory disk uses sector numbers as a flat byte offset mechanism (track 0, sectors 0–127 for directory/metadata, sector 128+ for the boot image).

### Format Procedure (MDFORM)

When a parity error is detected, the autoloader formats the entire memory disk:

1. Read track count from status register bits 7–2
2. Fill a 16KB buffer at 0x3000 with 0xE5 (CP/M empty marker)
3. Write this buffer to each track, displaying the track number on screen ("FORMATTING TRACK: nnn")
4. After all tracks are written, copy a "PROM directory" from **track 64, sector 0** (2048 bytes) to **track 0, sector 0**
5. Validation: the first byte of the PROM directory must be 0x20 (space character)

This suggests a two-tier storage design where track 64 holds a read-only template directory (perhaps burned into the memory disk's non-volatile portion), which gets copied to the working directory area at track 0 during formatting.

### Variables

| Name | Size | Purpose |
|------|------|---------|
| BUFFER | 2 bytes | DMA address pointer for format operations |
| HSTTRK | 1 byte | Current track number |
| HSTSEC | 1 byte | Current sector number |
| SIZE | 2 bytes | Byte transfer count |

---

## New Device: SEM702 Character Generator

### I/O Ports

| Port | Direction | Name | Function |
|------|-----------|------|----------|
| **0xD1** | W | CHARLN | Character number (0–127) |
| **0xD2** | W | DOTLN | Dot line number (0–15) |
| **0xD3** | W | CHARDA | Character pixel data (1 byte per dot line) |

### Character Format

| Parameter | Value |
|-----------|-------|
| Character count | 128 (0–127) |
| Dot lines per character | 16 (counter uses `AND 0FH` mask) |
| Bits per dot line | 8 |
| Total font data | 2048 bytes (128 × 16) |

### Font Data Source

The font data is read from address **0x2000** — the location of the "test PROM" (ROM2). This implies a second 2KB PROM is installed containing the font bitmap. Since the test PROM jump feature was removed, 0x2000 is now exclusively used as the font data source.

### Bit Reversal

Each font byte is bit-reversed before writing to the character generator. The code uses a shift loop:

```z80
LD E,(IX)       ; read byte from PROM
LD D,8          ; 8 bits to reverse
RL E            ; shift MSB into carry
RR A            ; shift carry into A's MSB (building reversed byte)
DEC D
JR NZ,...       ; repeat 8 times
OUT (CHARDA),A  ; write reversed byte
```

This reverses the bit order (MSB↔LSB), suggesting that the font PROM stores pixels in the opposite endianness from what the SEM702 display expects.

### Loading Sequence

The character generator is loaded **after** display initialization but **before** the memory disk boot attempt. The sequence:

1. Set character number to 0, dot line to 0
2. For each of 128 characters:
   - For each of 16 dot lines:
     - Read byte from PROM at (IX), bit-reverse it, write to CHARDA
     - Increment dot line counter (wraps at 16)
   - Increment character counter, write to CHARLN
3. Return

### SEM702 Context

The SEM702 appears to be a CRT display module with a programmable character generator RAM, replacing the standard RC702 CRT's fixed character ROM. This allows custom character sets to be loaded at boot time from a separate PROM. The 16 dot lines per character (vs the standard 8275's typical 10-line characters) suggests the SEM702 may support a higher-resolution character cell.

---

## Other Changes from rob358.mac

### DMA Initialization

- **COMV** changed from 0x20 to 0x10 — different DMA command register value (possibly disabling memory-to-memory transfers or changing priority)
- **MODE3 EQU 04BH** added (DMA channel 3 mode, set during init but commented "NOT USED")
- **DMAREQ EQU 0F9H** — DMA software request register, new

### Timer-Based Timeouts

The display interrupt handler (`DISINT`) now decrements a `TIMER` variable each frame:

```z80
DISINT: EX AF,AF'
        IN A,(CRTCOM)       ; acknowledge interrupt
        LD A,(TIMER)        ; if TIMER <> 0 then TIMER--
        OR A
        JR Z,DISIN1
        DEC A
        LD (TIMER),A
DISIN1: EX AF,AF'
        EI
        RETI
```

This provides a real-time countdown driven by the CRT refresh rate (~50 Hz). The floppy timeout (`READOK`) and init timeout (`INITFL`) now use `TIMER` instead of BC-register countdown loops, giving more predictable timing.

### Floppy Initialization Changes

- `INDISK` — new procedure that displays "INSERT DISKETTE IN DRIVE A" at the bottom of the screen and polls FDC sense-drive-status (command 0x04) until a disk is detected ready
- `FLO8` — new FDC sense-drive-status routine, checks bit pattern 0x23 (ready + write protected + head loaded)
- `FDSTOP` simplified — unconditionally writes 0 to SW1 port (no longer checks mini/maxi switch first)

### Display Changes

- Banner: `' RC700'` → `'RC702E  Autoload Version 3.0'`
- Cursor position set to (26, 26) — off-screen, effectively hidden (rob358 set cursor to (0, 0))
- Display buffer copy uses `MESSWR` subroutine (null-terminated string writer) instead of `LDIR` with explicit byte count

### Keyboard Handler

- No longer handles `T` key (test mode removed)
- `FLBFLG` stores the character value 'F' (0x46) instead of 1 — functionally equivalent (both are non-zero/truthy)

### Error Handling

- `ERR` procedure simplified: uses `DE` register for display buffer pointer + `MESSWR` instead of `IX`-based character copy loop
- `WRNUM` — new procedure for displaying 3-digit track numbers during memory disk formatting (divides by 100, 10, 1)

### String References

The ID-COMAL boot comparison strings are now separate labels (`IDTXT` and `CPMTXT`, both containing `' RC700'`) instead of referencing `TCMOP-6` as in rob358.

---

## Boot Priority

The PHE358A boot sequence is:

1. Initialize hardware (PIO, DMA, CTC, CRT)
2. **Load character generator** from PROM at 0x2000
3. Wait for timer countdown (display stabilization)
4. **Attempt memory disk boot** — if present and valid, boot from it
5. **Fall through to floppy boot** — standard CP/M / ID-COMAL / COMAL-80 floppy boot
6. Keyboard `F` key forces floppy boot at any stage

Compare with rob358.mac: Initialize → Hard disk boot → Floppy boot (with `T` for test PROM).

---

## Summary of Port Assignments

### New Ports (not in rob358.mac)

| Port | Device | Function |
|------|--------|----------|
| 0xD1 | SEM702 CG | Character number |
| 0xD2 | SEM702 CG | Dot line number |
| 0xD3 | SEM702 CG | Character RAM data |
| 0xEE | Memory disk | Track register (W) / Status register (R) |
| 0xEF | Memory disk | Sector register (W, triggers DMA) |
| 0xF9 | DMA | Software request register |

### Removed Ports (were in rob358.mac)

| Port | Device | Function |
|------|--------|----------|
| 0x44–0x47 | CTC2 | Second CTC for WD1000 interrupts |
| 0x61 | WD1000 | Write precomp / Error register |
| 0x62 | WD1000 | Sector count |
| 0x63 | WD1000 | Sector number |
| 0x64 | WD1000 | Cylinder low |
| 0x65 | WD1000 | Cylinder high |
| 0x66 | WD1000 | Size/Drive/Head |
| 0x67 | WD1000 | Command / Status register |
