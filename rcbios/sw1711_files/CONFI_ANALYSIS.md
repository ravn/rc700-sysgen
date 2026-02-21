# CONFI.COM Analysis

Disassembly and analysis of CONFI.COM from SW1711-I8.imd (rel.2.3 maxi system disk).

Source: `rcbios/sw1711_files/CONFI.COM` (6528 bytes, loads at 0x0100-0x1A7F)

Version string: `RC700 CP/M CONFIGURATION UTILITY  VERS 2.1  13.01.83`

## Memory Layout

| Address | Size | Description |
|---------|------|-------------|
| 0x0100-0x05E3 | 1252 | Main program logic, menu system, hardware programming |
| 0x05E4-0x0658 | 117 | Version banner, disk prompt, error messages |
| 0x0659-0x0D5E | 1798 | All menu/sub-menu display text (null-terminated, XY-addressed) |
| 0x0D5E | 1 | drive_num: selected drive (0=A, 2=C) |
| 0x0D5F-0x0D69 | 11 | SIO WR4 clock mode lookup table (indexed by baud selection) |
| 0x0D6A-0x0D74 | 11 | CTC divisor lookup table (indexed by baud selection) |
| 0x0D75-0x0DF4 | 128 | DMA buffer: Track 0 sector 2 (hardware config) |
| 0x0DF5-0x0E74 | 128 | DMA buffer: Track 0 sector 3 (output conv table) |
| 0x0E75-0x0EF4 | 128 | DMA buffer: Track 0 sector 4 (input conv table) |
| 0x0EF5-0x0F74 | 128 | DMA buffer: Track 0 sector 5 (semigraphic table) |
| 0x0F75-0x0FF4 | 128 | Stack area (SP initialized to 0x0FF5, grows down) |
| 0x0FF5-0x1174 | 384 | Danish conversion table (identity — ROM is natively Danish) |
| 0x1175-0x12F4 | 384 | Swedish conversion table |
| 0x12F5-0x1474 | 384 | German conversion table |
| 0x1475-0x15F4 | 384 | UK ASCII conversion table |
| 0x15F5-0x1774 | 384 | US ASCII conversion table |
| 0x1775-0x18F4 | 384 | French conversion table |
| 0x18F5-0x1A74 | 384 | Library conversion table |
| 0x1A75-0x1A7F | 11 | Trailing data (unused) |

### DMA Buffer vs "sysgen_code"

The region 0x0D75-0x0F74 was initially thought to contain disk I/O code
("sysgen_code"), but is actually the DMA buffer area where CONFI reads/writes
Track 0 disk sectors.  CONFI uses standard CP/M BIOS calls (SELDSK, SETTRK,
SETSEC, SETDMA, READ, WRITE) at their hardcoded 56K BIOS addresses
(0xDA00+offset).  There is no embedded disk I/O code — CONFI relies entirely
on the running BIOS.

The initial content of the DMA buffers in the .COM file is meaningless data
that gets overwritten when CONFI reads the disk config at startup.

## BIOS Entry Points Used

CONFI calls directly into the 56K CP/M BIOS jump table at 0xDA00:

| Address | BIOS Entry | Function |
|---------|-----------|----------|
| 0xDA0C | CONOUT | Character output (used for all screen I/O) |
| 0xDA1B | SELDSK | Select disk drive |
| 0xDA1E | SETTRK | Set track number |
| 0xDA21 | SETSEC | Set sector number |
| 0xDA24 | SETDMA | Set DMA buffer address |
| 0xDA27 | READ | Read sector |
| 0xDA2A | WRITE | Write sector |

Note: CONFI bypasses BDOS for character output, calling BIOS CONOUT directly.
This is faster but means CONFI is hardcoded for the 56K CP/M memory layout.

## Program Flow

### Entry Point (0x0100)

```
0100  NOP; NOP; NOP        ; 3 NOPs (patching space)
0103  EX (SP),HL           ; save return address, get CCP address
0104  LD SP,0FF5h          ; private stack (below conversion tables)
0107  PUSH HL              ; save CCP return address
0108  LD DE,05E4h          ; banner string
010B  LD C,9               ; BDOS print string
010D  CALL 0005h
```

### Drive Selection (0x0110)

Prompts "SELECT SYSTEM DISK FOR CONFIGURATION (A/C)?" and accepts A or C
(case-insensitive). CTRL-C exits to CP/M. The drive number (0=A, 2=C)
is stored at 0x0D5E.

### Main Sequence (0x013F-0x015F)

```
013F  XOR A                ; A=0 → read config from disk
0140  CALL sub_03F6h       ; read Track 0 sectors 2-5 via BIOS calls
0143  CALL sub_0162h       ; run the main menu loop
0146  LD C,2; LD E,0Ch     ; BDOS CONOUT: send form-feed (clear screen)
014A  CALL 0005h
014D  CALL sub_0329h       ; copy selected conv table to BIOS at 0xF680
0150  CALL sub_037Eh       ; program CRT controller (8275) with new cursor params
0153  CALL sub_0275h       ; program SIO Channel A with new config
0156  CALL sub_022Bh       ; program CTC Channel 0 (SIO-A baud rate)
0159  CALL sub_0281h       ; program SIO Channel B with new config
015C  CALL sub_024Ah       ; program CTC Channel 1 (SIO-B baud rate)
015F  JP 0000h             ; warm boot (reloads CCP)
```

The config is applied to running hardware immediately on exit.
Whether the config is also SAVED to disk depends on whether menu option 6
("SAVE CONFIGURATION DESCRIPTION") was selected during the session.

## Menu Structure

### Computed Jump Table Dispatcher (sub_0573h)

All menus use a common dispatch mechanism. After the user selects an option,
`CALL sub_0573h` reads a 2-byte target address from a jump table embedded
immediately after the CALL instruction, indexed by the selection:

```
0573  POP DE          ; DE = return address = start of jump table
0574  DEC HL          ; HL = selection (1-based from menu) → 0-based
0575  ADD HL,HL       ; HL = index × 2
0576  ADD HL,DE       ; HL = table_base + index × 2
0577  LD E,(HL)       ; load target address low
0578  INC HL
0579  LD D,(HL)       ; load target address high
057A  EX DE,HL
057B  JP (HL)         ; jump to handler
```

### Main Menu (sub_0162h)

Menu text at 0x0659, 6 options. Jump table at 0x0176:

| Option | Menu Label | Target | Handler |
|--------|-----------|--------|---------|
| 1 | PRINTER PORT | 0x01A0 | 4 sub-options, configures SIO-B + CTC Ch1 |
| 2 | TERMINAL PORT | 0x0182 | 5 sub-options, configures SIO-A + CTC Ch0 |
| 3 | CONVERSION | 0x0302 | Select language table (1-7) |
| 4 | CURSOR | 0x0340 | 2 sub-options: format + addressing |
| 5 | MINI MOTOR STOP TIMER | 0x03B6 | Numeric input (5-1200 seconds) |
| 6 | SAVE CONFIGURATION | 0x03DC | Write config back to disk |

### SIO Channel Assignment Anomaly

**The menu labels "PRINTER PORT" and "TERMINAL PORT" are swapped relative
to the SIO channels they configure:**

- Menu option 1 "PRINTER PORT" → modifies SIO-B config (0x0D86+) and
  CTC Ch1 baud (0x0D78). In the BIOS, SIO-B (port 0x0B) is the terminal/
  auxiliary channel (CP/M PUN:/RDR:).
- Menu option 2 "TERMINAL PORT" → modifies SIO-A config (0x0D7D+) and
  CTC Ch0 baud (0x0D76). In the BIOS, SIO-A (port 0x0A) is the printer
  channel (CP/M LST:).

The CP/M for RC702 User's Guide (Appendix F) confirms: SIO Channel A =
Printer Port, SIO Channel B = Terminal Port. This swap appears to be a
genuine bug in CONFI.COM — the menu text matches the User's Guide, but
the code behind each menu option configures the wrong SIO channel.

The swap is internally consistent (the "PRINTER PORT" sub-menu always
modifies the same config block), so it would only cause confusion if the
user expected "PRINTER PORT" to actually configure the printer.

### Sub-Menu: Printer Port (0x01A0)

Menu text at 0x0AC7 ("PRINTER PORT"), 4 options. Jump table at 0x01B4.
**Actually configures SIO-B (terminal channel):**

| Option | Label | Target | SIO Register |
|--------|-------|--------|-------------|
| 1 | STOPBIT | 0x01C4 | SIO-B WR4 bits 2-3 (0x0D8A) |
| 2 | PARITY | 0x01F1 | SIO-B WR4 bits 0-1 (0x0D8A) |
| 3 | BAUDRATE | 0x0235 | CTC Ch1 (0x0D78) + SIO-B WR4 bits 6-7 (0x0D8A) |
| 4 | BIT PR. CHARACTER | 0x02A1 | SIO-B WR5 bits 5-6 (0x0D8E) |

### Sub-Menu: Terminal Port (0x0182)

Menu text at 0x0709 ("TERMINAL PORT"), 5 options. Jump table at 0x0196.
**Actually configures SIO-A (printer channel):**

| Option | Label | Target | SIO Register |
|--------|-------|--------|-------------|
| 1 | STOPBIT | 0x01BE | SIO-A WR4 bits 2-3 (0x0D7F) |
| 2 | PARITY | 0x01EB | SIO-A WR4 bits 0-1 (0x0D7F) |
| 3 | BAUDRATE | 0x0216 | CTC Ch0 (0x0D76) + SIO-A WR4 bits 6-7 (0x0D7F) |
| 4 | BITS/CHAR TX | 0x028D | SIO-A WR5 bits 5-6 (0x0D83) |
| 5 | BITS/CHAR RX | 0x029A | SIO-A WR3 bits 6-7 (0x0D81) |

### Sub-Menu: Conversion (0x0302)

Menu text at 0x088A, 7 options. Direct handler (no jump table).
Copies 384 bytes from selected built-in table to workspace at 0x0DF5:

| Option | Language |
|--------|----------|
| 1 | Danish (identity — CRT ROM is natively Danish) |
| 2 | Swedish |
| 3 | German |
| 4 | UK-ASCII |
| 5 | US-ASCII |
| 6 | French |
| 7 | Library |

### Sub-Menu: Cursor (0x0340)

Menu text at 0x0C4F, 2 options. Jump table at 0x0354:

| Option | Label | Target | Description |
|--------|-------|--------|-------------|
| 1 | FORMAT | 0x0358 | 4-option sub-menu: blink+reverse, blink+underline, reverse, underline |
| 2 | ADDRESSING | 0x039F | 2-option sub-menu: H,V or V,H |

### Motor Stop Timer (0x03B6)

Displays current value, accepts numeric input (5-1200 seconds).
Stores to motor_lo (0x0DA1) and motor_hl (0x0DA2, word).

### Save Configuration (0x03DC)

```
03DC  LD A,001h           ; A=1 → write config to disk
03DE  CALL sub_03F6h      ; write Track 0 sectors 2-5
03E1  RET
```

## Hardware Configuration Block

### CTC Divisor Lookup Tables

The first part of the config area contains two 11-entry lookup tables
indexed by baud rate selection (0-10):

**SIO WR4 clock mode table (0x0D5F, 11 bytes):**

| Index | Baud | WR4 bits | Clock mode |
|-------|------|----------|------------|
| 0 | 50 | 0xC0 | x64 |
| 1 | 75 | 0xC0 | x64 |
| 2 | 110 | 0xC0 | x64 |
| 3 | 150 | 0xC0 | x64 |
| 4 | 300 | 0xC0 | x64 |
| 5 | 600 | 0x40 | x16 |
| 6 | 1200 | 0x40 | x16 |
| 7 | 2400 | 0x40 | x16 |
| 8 | 4800 | 0x40 | x16 |
| 9 | 9600 | 0x40 | x16 |
| 10 | 19200 | 0x40 | x16 |

**CTC divisor table (0x0D6A, 11 bytes):**

| Index | Baud | CTC div | Calculation |
|-------|------|---------|-------------|
| 0 | 50 | 0xC1 (193) | 614400 / 64 / 193 = 49.7 |
| 1 | 75 | 0x80 (128) | 614400 / 64 / 128 = 75.0 |
| 2 | 110 | 0x58 (88) | 614400 / 64 / 88 = 109.1 |
| 3 | 150 | 0x40 (64) | 614400 / 64 / 64 = 150.0 |
| 4 | 300 | 0x20 (32) | 614400 / 64 / 32 = 300.0 |
| 5 | 600 | 0x40 (64) | 614400 / 16 / 64 = 600.0 |
| 6 | 1200 | 0x20 (32) | 614400 / 16 / 32 = 1200.0 |
| 7 | 2400 | 0x10 (16) | 614400 / 16 / 16 = 2400.0 |
| 8 | 4800 | 0x08 (8) | 614400 / 16 / 8 = 4800.0 |
| 9 | 9600 | 0x04 (4) | 614400 / 16 / 4 = 9600.0 |
| 10 | 19200 | 0x02 (2) | 614400 / 16 / 2 = 19200.0 |

CTC input clock = 0.6144 MHz (hardware manual section 2.3.5).
Formula: baud = 614400 / (SIO_clock_mode x CTC_divisor)

### Runtime Config Variables (DMA buffer for Track 0 sector 2)

Loaded from disk at startup into 0x0D75-0x0DF4 (128 bytes). Key fields:

| Offset | Address | Var | Description |
|--------|---------|-----|-------------|
| +1 | 0x0D76 | ctc_a_div | CTC Ch0 divisor for SIO-A baud rate |
| +3 | 0x0D78 | ctc_b_div | CTC Ch1 divisor for SIO-B baud rate |
| +8 | 0x0D7D | sio_a_cfg[0..8] | SIO-A init block (9 bytes, OTIR to port 0x0A) |
| +17 | 0x0D86 | sio_b_cfg[0..10] | SIO-B init block (11 bytes, OTIR to port 0x0B) |
| +32 | 0x0D95 | crt_params[0..3] | CRT controller parameters (4 bytes to port 0x00) |
| +35 | 0x0D98 | crt_param4 | CRT param 4 (cursor format in bits 4-5) |
| +40 | 0x0D9D | adr_mode | Cursor addressing: 0=H,V 1=V,H |
| +41 | 0x0D9E | conv_idx | Conversion table index (0-6) |
| +42 | 0x0D9F | baud_a_idx | SIO-A baud rate selection (for re-display) |
| +43 | 0x0DA0 | baud_b_idx | SIO-B baud rate selection (for re-display) |
| +44 | 0x0DA1 | motor_lo | Motor stop timer (low byte) |
| +45 | 0x0DA2 | motor_hl | Motor stop timer (word, in seconds) |

### SIO Init Block Layout

**SIO-A (9 bytes at 0x0D7D):**

| Offset | Byte | Description |
|--------|------|-------------|
| 0 | WR0 cmd | Channel reset (0x18) |
| 1 | 0x04 | Select WR4 |
| 2 | WR4 val | Clock mode + parity + stop bits |
| 3 | 0x03 | Select WR3 |
| 4 | WR3 val | RX bits/char + RX enable |
| 5 | 0x05 | Select WR5 |
| 6 | WR5 val | TX bits/char + TX enable + DTR + RTS |
| 7 | 0x01 | Select WR1 |
| 8 | WR1 val | Interrupt enables |

**SIO-B (11 bytes at 0x0D86):**

| Offset | Byte | Description |
|--------|------|-------------|
| 0 | WR0 cmd | Channel reset (0x18) |
| 1 | 0x02 | Select WR2 |
| 2 | WR2 val | Interrupt vector (SIO-B only) |
| 3 | 0x04 | Select WR4 |
| 4 | WR4 val | Clock mode + parity + stop bits |
| 5 | 0x03 | Select WR3 |
| 6 | WR3 val | RX bits/char + RX enable |
| 7 | 0x05 | Select WR5 |
| 8 | WR5 val | TX bits/char + TX enable + DTR + RTS |
| 9 | 0x01 | Select WR1 |
| 10 | WR1 val | Interrupt enables |

SIO-B has 2 extra bytes for the WR2 interrupt vector register.

### SIO WR4 Bit Fields (stop bits, parity, clock mode)

```
Bits 7-6: Clock mode    (modified by baud rate handler)
  00 = x1, 01 = x16, 10 = x32, 11 = x64
Bits 3-2: Stop bits     (modified by stop bits handler)
  00 = sync, 01 = 1 bit, 10 = 1.5 bits, 11 = 2 bits
Bits 1-0: Parity        (modified by parity handler)
  x0 = no parity, 01 = odd, 11 = even
```

### SIO WR3 Bit Fields (RX config)

```
Bits 7-6: RX bits/char  (modified by RX bits/char handler)
  00 = 5 bits, 01 = 7 bits, 10 = 6 bits, 11 = 8 bits
Bit 0: RX enable
```

### SIO WR5 Bit Fields (TX config)

```
Bits 6-5: TX bits/char  (modified by TX bits/char handler)
  00 = 5 bits, 01 = 7 bits, 10 = 6 bits, 11 = 8 bits
Bit 7: DTR
Bit 3: TX enable
Bit 1: RTS
```

## Key Subroutines

### sub_0275h -- Program SIO Channel A

```
0275  LD HL,0D7Dh    ; SIO-A config block (9 bytes)
0278  LD B,9          ; byte count
027A  LD C,0Ah        ; SIO-A control port
027C  DI
027D  OTIR            ; output 9 bytes to port 0x0A
027F  EI
0280  RET
```

### sub_0281h -- Program SIO Channel B

```
0281  LD HL,0D86h    ; SIO-B config block (11 bytes)
0284  LD B,0Bh        ; byte count
0286  LD C,0Bh        ; SIO-B control port
0288  DI
0289  OTIR            ; output 11 bytes to port 0x0B
028B  EI
028C  RET
```

### sub_022Bh -- Program CTC Channel 0 (SIO-A Baud Rate)

```
022B  LD A,47h        ; CTC mode: timer, prescaler=16, next=divisor
022D  OUT (0Ch),A     ; CTC Channel 0 control
022F  LD A,(0D76h)    ; CTC divisor for SIO-A
0232  OUT (0Ch),A     ; program divisor
0234  RET
```

### sub_024Ah -- Program CTC Channel 1 (SIO-B Baud Rate)

```
024A  LD A,47h        ; CTC mode: timer, prescaler=16, next=divisor
024C  OUT (0Dh),A     ; CTC Channel 1 control
024E  LD A,(0D78h)    ; CTC divisor for SIO-B
0251  OUT (0Dh),A     ; program divisor
0253  RET
```

### sub_0254h -- Baud Rate Menu Handler

```
0254  PUSH HL          ; save pointer to baud_idx variable
0255  LD A,(HL)        ; current selection
0256  LD HL,09C4h      ; baud rate menu text
0259  LD DE,1
025C  LD BC,11         ; 11 options (50-19200 bps)
025F  CALL sub_04E7h   ; generic menu
0262  POP DE           ; DE = baud_idx pointer
0263  RET NC           ; cancelled
0264  PUSH DE
0265  DEC HL           ; HL = 0-based index
0266  EX DE,HL
0267  LD HL,0D6Ah      ; CTC divisor table
026A  ADD HL,DE        ; index into table
026B  LD C,(HL)        ; C = CTC divisor
026C  LD HL,0D5Fh      ; WR4 clock mode table
026F  ADD HL,DE        ; index into table
0270  LD B,(HL)        ; B = WR4 clock bits
0271  POP HL           ; HL = baud_idx pointer
0272  LD (HL),A        ; store new baud index
0273  SCF
0274  RET              ; return: C=divisor, B=WR4 bits
```

### sub_037Eh -- Program CRT Controller (8275)

```
037E  LD A,40h        ; 8275 "Load Cursor" command
0380  OUT (01h),A
0382  LD A,00h        ; cursor column = 0
0384  OUT (01h),A
0386  LD A,(0D95h)    ; CRT parameter 1
0389  OUT (00h),A
038B  LD A,(0D96h)    ; CRT parameter 2
038E  OUT (00h),A
0390  LD A,(0D97h)    ; CRT parameter 3
0393  OUT (00h),A
0395  LD A,(0D98h)    ; CRT parameter 4 (cursor format)
0398  OUT (00h),A
039A  LD A,23h        ; 8275 "Start Display" command
039C  OUT (01h),A
039E  RET
```

### sub_0329h -- Copy Conversion Table to BIOS

Copies the selected 384-byte conversion table from CONFI's built-in
tables to the BIOS runtime location at 0xF680:

```
0329  LD A,(0D9Eh)    ; conv_idx (0-6)
032C  LD HL,0FF5h     ; base of built-in conversion tables
032F  LD BC,0180h     ; 384 bytes per table
0332  DEC A           ; loop: skip tables until selected one
0333  JP M,033Ah      ; negative = done skipping
0336  ADD HL,BC       ; advance to next table
0337  JP 0332h
033A  LD DE,0F680h    ; BIOS conversion table location
033D  LDIR            ; copy 384 bytes
033F  RET
```

### sub_03F6h -- Read/Write Track 0 Config Block

Reads (A=0) or writes (A=1) 4 sectors from Track 0 of the selected disk
using BIOS calls at 0xDA00+.  Handles both drive A (floppy) and drive C
(hard disk), with drive-specific initialization:

```
For drive A (floppy):
  - Reads SW1 port (0x14) bit 7 to detect mini/maxi
  - Sets motor control byte at BIOS+37h (0xDA37)
  - Calls BIOS SELDSK with drive 0

For drive C (hard disk):
  - Calls BIOS SELDSK with drive 2

Then for both:
  SETTRK(0)                     ; track 0
  SETSEC(1), SETDMA(0x0D75)    ; sector 2 → hw config buffer
  READ or WRITE
  SETSEC(2), SETDMA(0x0DF5)    ; sector 3 → output conv buffer
  READ or WRITE
  SETSEC(3), SETDMA(0x0E75)    ; sector 4 → input conv buffer
  READ or WRITE
  SETSEC(4), SETDMA(0x0EF5)    ; sector 5 → semigraphic buffer
  READ or WRITE
```

SETSEC values 1-4 map through BIOS SECTRAN to physical sectors 2-5,
skipping physical sector 1 (boot entry point + signature).

### sub_04E7h -- Generic Menu Handler

```
Parameters:
  HL = pointer to menu display string (null-terminated with XY codes)
  DE = base value (first valid option, usually 1)
  BC = number of options
  A  = current selection (used for asterisk marker display)

Returns:
  Carry set: selection made
    A = 0-based selection index (user input - 1)
    HL = user input value (1-based)
  Carry clear: empty input (ESC/return to parent)
```

Displays the menu string using sub_057Ch (which handles XY positioning and
the asterisk marker for the current selection). Accepts numeric input via
BDOS readline, validates range, and returns the selection.

### sub_057Ch -- Display String with Marker

Outputs a null-terminated string character by character via BIOS CONOUT
(0xDA0C). Special character handling:

- 0x06: XY cursor addressing (next 2 bytes = H+32, V+32)
- 0x05: Marker position — if this is the currently selected option,
  display '*'; otherwise display ' '
- 0x1F: Clear to end of screen (delegated to BIOS CONOUT)
- 0x00: End of string

The asterisk marker (0x05) is tracked by a counter initialized to the
current selection value. Each 0x05 encountered decrements the counter;
when it reaches zero, an asterisk is displayed at that position.

### sub_05B7h -- XY Cursor Addressing

Handles the 0x06 escape sequence: reads H and V coordinates from the
string, checks the adr_mode variable (0x0DA3 via BIOS+33h), and outputs
them in H,V or V,H order via BIOS CONOUT.

## Conversion Tables

Each language table is 384 bytes = 3 x 128:

| Offset | Size | Purpose |
|--------|------|---------|
| +0x00 | 128 | Output conversion (application char → CRT ROM position) |
| +0x80 | 128 | Input conversion (keyboard code → application char) |
| +0x100 | 128 | Semigraphic character mapping |

**Table base address: 0x0FF5** (not 0x1000 as the block file suggests).

The Danish table (index 0) is a perfect identity map for both output and
input — the CRT character ROM (ROA296) and keyboard natively produce Danish
characters, so no conversion is needed. Other languages require remapping.

National character differences (output/input diffs vs identity map):

| Table | Language | Out diffs | Inp diffs | Semigfx diffs |
|-------|----------|-----------|-----------|---------------|
| 0 | Danish | 0 | 0 | 95 |
| 1 | Swedish | 8 | 19 | 95 |
| 2 | German | 9 | 27 | 96 |
| 3 | UK ASCII | 10 | 0 | 96 |
| 4 | US ASCII | 9 | 0 | 95 |
| 5 | French | 9 | 16 | 95 |
| 6 | Library | 6 | 15 | 105 |

The semigraphic table always has ~95+ differences from identity because
semigraphic characters use a separate ROM (ROA327) with its own layout —
the mapping is inherently non-trivial.

## Menu Display Text Strings

All menu text is stored as null-terminated strings with embedded control
codes. Each string starts with [FF] (form-feed/clear screen) or
[XY:col,row] positioning.

| Address | String |
|---------|--------|
| 0x05E4 | Version banner: "RC700 CP/M CONFIGURATION UTILITY VERS 2.1 13.01.83" |
| 0x061C | "SELECT SYSTEM DISK FOR CONFIGURATION (A/C)?" |
| 0x064B | Disk error message |
| 0x0659 | Main menu (6 options) |
| 0x0709 | Terminal port sub-menu (5 options) |
| 0x0803 | Cursor format sub-menu (4 options) |
| 0x088A | Conversion table sub-menu (7 options) |
| 0x0928 | Stop bits sub-menu (3 options: 1, 1.5, 2) |
| 0x097B | Parity sub-menu (3 options: even, no, odd) |
| 0x09C4 | Baud rate sub-menu (11 options: 50-19200) |
| 0x0AC7 | Printer port sub-menu (4 options) |
| 0x0B5F | "*** ILLEGAL ***" error with beep |
| 0x0B75 | Bits/char transmitter (4 options: 5,6,7,8) |
| 0x0BE6 | Bits/char receiver (4 options: 5,6,7,8) |
| 0x0C4F | Cursor main sub-menu (2 options: format, addressing) |
| 0x0C9D | Addressing sub-menu (2 options: H,V or V,H) |
| 0x0CE6 | Motor timer header ("CURRENT VALUE IS:") |
| 0x0CDA | "CHOICE: " prompt |
| 0x0D26 | Motor timer range prompt ("5-1200 SECONDS") |

## Disk Config Sector Layout

CONFI reads/writes Track 0, logical sectors 1-4 (physical sectors 2-5).
The 4 sectors x 128 bytes = 512 bytes contain the BIOS configuration:

| SETSEC | Physical | DMA Addr | Content |
|--------|----------|----------|---------|
| 1 | 2 | 0x0D75 | Hardware config (SIO, CTC, CRT params) |
| 2 | 3 | 0x0DF5 | Output conversion table (128 bytes) |
| 3 | 4 | 0x0E75 | Input conversion table (128 bytes) |
| 4 | 5 | 0x0EF5 | Semigraphic table (128 bytes) |

Physical sector 1 (boot entry point + signature) is not touched by CONFI.
