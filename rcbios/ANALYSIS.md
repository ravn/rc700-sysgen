# RC702 CP/M BIOS Analysis

## Cold Boot Code

The autoload PROM (ROA375) reads Track 0 (both sides) to RAM at 0x0000, then
reads Track 1 to follow.  It checks for " RC702" at offset 0x0008. If found,
it reads the **16-bit word at offset 0x0000** as a jump target and executes it.

### Entry point per format

| Format | Entry word | Entry address | Reason |
|--------|-----------|---------------|--------|
| 5.25" mini | `80 02` | 0x0280 | INIT starts at sector 6 of T0S0 (5 config sectors × 128B) |
| 8" maxi | `80 03` | 0x0380 | **DIFFERS**: 7 sectors before INIT (5 config + 2 extra data) |

The entry point difference is due to the maxi format having extra data
sectors at disk offsets 0x0280-0x037F (containing disk parameter blocks
for the hard disk and additional format descriptors).

### Relocation: 56K (rel.2.1 / rel.2.2)

```asm
0280: DI
0281: LD HL, 0x0000           ; Source: loaded Track 0+1 data
0284: LD DE, 0xD480           ; Destination: CODEDESTINAT
0287: LD BC, 0x2381           ; Length: 9089 bytes (CODELENGTH)
028A: LDIR                    ; Copy system image to high memory
028C: LD HL, 0xD580           ; Source: character conversion tables (relocated)
028F: LD DE, 0xF680           ; Destination: final table location
0292: LD BC, 0x0180           ; Length: 384 bytes (3 × 128, CONVLENGTH)
0295: LDIR                    ; Copy conversion tables to final position
0297: LD SP, 0x0080           ; Set stack pointer
029A: LD A, (0xEC25)          ; Load interrupt vector page number
029D: LD I, A                 ; Set Z80 I register for IM 2
029F: IM 2                    ; Enable Mode 2 interrupts
```

### Relocation: 58K (Compas) — **DIFFERS**

```asm
0380: DI
0381: LD HL, 0x0000           ; Source: same
0384: LD DE, 0xDD00           ; *** CODEDESTINAT = 0xDD00 (not 0xD480)
0387: LD BC, 0x1B01           ; *** CODELENGTH = 6913 bytes (not 9089)
038A: LDIR
038C: LD HL, 0xDE00           ; *** Char tables at 0xDE00 (= 0xDD00 + 0x100)
038F: LD DE, 0xF680           ; Destination: same
0392: LD BC, 0x0180           ; Length: same (384 bytes)
0395: LDIR
0397: LD SP, 0x0080           ; Same
039A: LD A, (0xF421)          ; *** IVT page at 0xF421 (not 0xEC25)
039D: LD I, A
039F: IM 2
03A1: JP 0xE0A4               ; *** Jump to 58K INIT continuation
```

### INIT hardware setup (continues after IM 2)

After relocation, the INIT code programs all hardware controllers in sequence:
1. **PIO** (ports 0x12-0x13): keyboard interrupt vector, I/O modes
2. **CTC** (ports 0x0C-0x0F): baud rates, display interrupt, floppy interrupt
3. **CTC2** (ports 0x44-0x47): hard disk interrupt
4. **SIO** (ports 0x0A-0x0B): serial port initialization
5. **DMA** (ports 0xF0-0xFF): floppy, display, hard disk channels
6. **FDC** (ports 0x04-0x05): floppy controller specify command
7. **CRT** (ports 0x00-0x01): 8275 display controller, screen clear
8. **Floppy detection**: reads SW1 bit 7 for mini/maxi, sets format tables
9. **Hard disk probe**: attempts restore command, reads config sector if online

The INIT code runs from the **loaded** Track 0 data area (0x0280-0x04xx for
mini, 0x0380-0x05xx for maxi) which is still at low memory during INIT.
After INIT completes, it jumps to `BOOT_ENTRY` in the relocated BIOS at
0xDB78 (56K rel.2.1) / 0xDB7F (56K rel.2.2) / 0xE2F8 (58K).

CTC and SIO initialization parameters are read from the hardware config block
at disk offset 0x0080 (see Configuration Blocks section below).  INIT reads
these values from their relocated addresses in high memory (0xD500 for 56K,
0xDD80 for 58K) and sends them to the hardware ports via OTIR instructions.

### I/O Port Map (used by INIT)

| Port | Device | Name | Function |
|------|--------|------|----------|
| 0x00 | 8275 | DSPLD | CRT data register |
| 0x01 | 8275 | DSPLC | CRT command register |
| 0x04 | µPD765 | FDC | FDC main status register (read) |
| 0x05 | µPD765 | FDD | FDC data register (read/write) |
| 0x08 | Z80-SIO | SIOAD | SIO Channel A data |
| 0x09 | Z80-SIO | SIOBD | SIO Channel B data |
| 0x0A | Z80-SIO | SIOAC | SIO Channel A control |
| 0x0B | Z80-SIO | SIOBC | SIO Channel B control |
| 0x0C | Z80-CTC | CTCCH0 | CTC Channel 0 (SIO-A baud rate) |
| 0x0D | Z80-CTC | CTCCH1 | CTC Channel 1 (SIO-B baud rate) |
| 0x0E | Z80-CTC | CTCCH2 | CTC Channel 2 (display interrupt) |
| 0x0F | Z80-CTC | CTCCH3 | CTC Channel 3 (floppy interrupt) |
| 0x10 | Z80-PIO | PIOAD | PIO Port A data (keyboard input) |
| 0x12 | Z80-PIO | PIOAC | PIO Port A control |
| 0x11 | Z80-PIO | PIOBD | PIO Port B data (parallel output) |
| 0x13 | Z80-PIO | PIOBC | PIO Port B control |
| 0x14 | System | SW1 | DIP switches (read), motor control (write) |
| 0x44 | Z80-CTC | CTC2C0 | CTC2 Channel 0 (hard disk int) — external |
| 0x45 | Z80-CTC | CTC2C1 | CTC2 Channel 1 (unused) — external |
| 0x46 | Z80-CTC | CTC2C2 | CTC2 Channel 2 (unused) — external |
| 0x47 | Z80-CTC | CTC2C3 | CTC2 Channel 3 (unused) — external |
| 0xF8 | Am9517 | DMAC | DMA command register |
| 0xFB | Am9517 | DMAMOD | DMA mode register |

### INIT Annotated Disassembly (56K, rel.2.1)

Disassembled from rccpm22 disk image, disk offset 0x0280.  Config block
references use notation `CFG+xx` for offset within the hardware config
block (disk 0x0080, relocated to 0xD500).  The rel.2.2 INIT code is
**byte-identical** through the hardware setup; only BIOS address operands
differ (+7 offset in store targets like RR0_A, RR1_A, etc.).

#### Relocation

```asm
0280: F3            DI                     ; Disable interrupts during init
0281: 21 00 00      LD   HL, 0x0000        ; Source: Track 0+1 loaded at 0x0000
0284: 11 80 D4      LD   DE, 0xD480        ; Dest: CODEDESTINAT
0287: 01 81 23      LD   BC, 0x2381        ; Length: CODELENGTH (9089 bytes)
028A: ED B0         LDIR                   ; Copy system image to high memory

028C: 21 80 D5      LD   HL, 0xD580        ; Source: character conversion tables
028F: 11 80 F6      LD   DE, 0xF680        ; Dest: OUTCON (final table location)
0292: 01 80 01      LD   BC, 0x0180        ; Length: 384 bytes (3 × 128)
0295: ED B0         LDIR                   ; Copy output + input + semi-gfx tables

0297: 31 80 00      LD   SP, 0x0080        ; Stack pointer = BUFF area
029A: 3A 25 EC      LD   A, (0xEC25)       ; IVT page byte (CITAB+1)
029D: ED 47         LD   I, A              ; Set Z80 interrupt register
029F: ED 5E         IM   2                 ; Enable Mode 2 vectored interrupts
```

#### PIO: Keyboard + Parallel Port

```asm
; Z80-PIO programming protocol:
;   Byte with bit 0 = 0              → interrupt vector
;   Byte with bits 3:0 = 1111 (0xXF) → mode select (bits 7:6 = mode)
;   Byte with bits 3:0 = 0011 (0xX3) → interrupt control word

02A1: 3E 20         LD   A, 0x20           ; Interrupt vector = 0x20
02A3: D3 12         OUT  (PIOAC), A        ; PIO Port A: keyboard int vector
                                           ;   IVT offset 0x20 → handler KEYIT

02A5: 3E 22         LD   A, 0x22           ; Interrupt vector = 0x22
02A7: D3 13         OUT  (PIOBC), A        ; PIO Port B: parallel port int vector
                                           ;   IVT offset 0x22 → handler PARIN

02A9: 3E 4F         LD   A, 0x4F           ; Mode select: bits 7:6 = 01 = Mode 1
02AB: D3 12         OUT  (PIOAC), A        ; PIO Port A: Input mode (keyboard)

02AD: 3E 0F         LD   A, 0x0F           ; Mode select: bits 7:6 = 00 = Mode 0
02AF: D3 13         OUT  (PIOBC), A        ; PIO Port B: Output mode (parallel)

02B1: 3E 83         LD   A, 0x83           ; Interrupt control: bit 7=1 (enable)
02B3: D3 12         OUT  (PIOAC), A        ; PIO Port A: enable keyboard interrupt
02B5: D3 13         OUT  (PIOBC), A        ; PIO Port B: enable parallel interrupt
```

#### CTC: Baud Rate Generators + Interrupt Timers

```asm
; Z80-CTC control word bits:
;   D0=1: control word   D1: reset   D2: time constant follows
;   D3: auto trigger     D4: edge    D5: prescaler (0=÷16, 1=÷256)
;   D6: mode (0=timer, 1=counter)    D7: interrupt enable
;
; 0x47 = counter mode, no interrupt, time constant follows, auto trigger
; 0xD7 = timer mode, interrupt enabled, time constant follows, ÷16 prescaler

02B7: 3E 00         LD   A, 0x00           ; CTC interrupt vector base = 0x00
02B9: D3 0C         OUT  (CTCCH0), A       ;   Ch.0 vec=0x00, Ch.1=0x02,
                                           ;   Ch.2=0x04, Ch.3=0x06

; Channel 0: SIO-A baud rate clock generator
02BB: 3A 00 D5      LD   A, (CFG+0x00)     ; CTC mode = 0x47 (counter, no int)
02BE: D3 0C         OUT  (CTCCH0), A
02C0: 3A 01 D5      LD   A, (CFG+0x01)     ; Time constant = 0x20 (32)
02C3: D3 0C         OUT  (CTCCH0), A       ; → 614kHz / 32 = 19.2kHz to SIO-A

; Channel 1: SIO-B baud rate clock generator
02C5: 3A 02 D5      LD   A, (CFG+0x02)     ; CTC mode = 0x47
02C8: D3 0D         OUT  (CTCCH1), A
02CA: 3A 03 D5      LD   A, (CFG+0x03)     ; Time constant = 0x20 (32)
02CD: D3 0D         OUT  (CTCCH1), A       ; → 614kHz / 32 = 19.2kHz to SIO-B

; Channel 2: Display refresh interrupt (50 Hz)
02CF: 3A 04 D5      LD   A, (CFG+0x04)     ; CTC mode = 0xD7 (timer, int enabled)
02D2: D3 0E         OUT  (CTCCH2), A
02D4: 3A 05 D5      LD   A, (CFG+0x05)     ; Time constant = 0x01 (1 count)
02D7: D3 0E         OUT  (CTCCH2), A       ; → interrupt on every trigger pulse

; Channel 3: Floppy disk completion interrupt
02D9: 3A 06 D5      LD   A, (CFG+0x06)     ; CTC mode = 0xD7 (timer, int enabled)
02DC: D3 0F         OUT  (CTCCH3), A
02DE: 3A 07 D5      LD   A, (CFG+0x07)     ; Time constant = 0x01
02E1: D3 0F         OUT  (CTCCH3), A       ; → interrupt on every trigger pulse
```

#### CTC2: Hard Disk Interrupt (external)

The CTC2 is **not on the motherboard** — it resides on the external hard
disk interface board, connected via the Z80 bus expansion connector.
The full Z80 bus is exposed on a single motherboard connector, and the
hard disk enclosure contains additional circuitry including this CTC.
Systems without a hard disk have no CTC2; writing to ports 0x44-0x47
has no effect.

```asm
02E3: 3E 08         LD   A, 0x08           ; CTC2 interrupt vector base = 0x08
02E5: D3 44         OUT  (CTC2C0), A       ;   Ch.0 vec=0x08 → handler HDITR

; Channel 0: WD1000 hard disk completion interrupt
02E7: 3A 44 D5      LD   A, (CFG+0x44)     ; CTC2 mode = 0xD7 (timer, int enabled)
02EA: D3 44         OUT  (CTC2C0), A
02EC: 3A 45 D5      LD   A, (CFG+0x45)     ; Time constant = 0x01
02EF: D3 44         OUT  (CTC2C0), A       ; → interrupt on trigger

; Channels 1-3: unused, reset
02F1: 3A 46 D5      LD   A, (CFG+0x46)     ; Reset command = 0x03 (D0=ctrl, D1=reset)
02F4: D3 45         OUT  (CTC2C1), A       ; Channel 1: software reset
02F6: 3A 46 D5      LD   A, (CFG+0x46)     ; Same value (0x03)
02F9: D3 46         OUT  (CTC2C2), A       ; Channel 2: software reset
02FB: 3A 46 D5      LD   A, (CFG+0x46)     ; Same value (0x03)
02FE: D3 47         OUT  (CTC2C3), A       ; Channel 3: software reset
```

#### SIO: Serial Ports

```asm
; SIO init bytes sent via OTIR (block output) from config block.
; See "SIO Init Sequence Decode" section for byte-by-byte register decode.

0300: 21 08 D5      LD   HL, CFG+0x08      ; SIO-A init: 9 bytes
0303: 06 09         LD   B, 9              ;   18 04 47 03 61 05 20 01 1B
0305: 0E 0A         LD   C, SIOAC          ; Port 0x0A (Ch.A control)
0307: ED B3         OTIR                   ; Send: reset, WR4, WR3, WR5, WR1

0309: 21 11 D5      LD   HL, CFG+0x11      ; SIO-B init: 11 bytes
030C: 06 0B         LD   B, 11             ;   18 02 10 04 47 03 60 05 20 01 1F
030E: 0E 0B         LD   C, SIOBC          ; Port 0x0B (Ch.B control)
0310: ED B3         OTIR                   ; Send: reset, WR2, WR4, WR3, WR5, WR1

; Read back initial SIO status registers
0312: DB 0A         IN   A, (SIOAC)        ; Read SIO-A RR0 (Tx/Rx/CTS/DCD status)
0314: 32 89 DC      LD   (RR0_A), A        ; Store for later reference
0317: 3E 01         LD   A, 0x01           ; Select RR1
0319: D3 0A         OUT  (SIOAC), A
031B: DB 0A         IN   A, (SIOAC)        ; Read SIO-A RR1 (error flags)
031D: 32 8A DC      LD   (RR1_A), A

0320: DB 0B         IN   A, (SIOBC)        ; Read SIO-B RR0
0322: 32 8B DC      LD   (RR0_B), A
0325: 3E 01         LD   A, 0x01           ; Select RR1
0327: D3 0B         OUT  (SIOBC), A
0329: DB 0B         IN   A, (SIOBC)        ; Read SIO-B RR1
032B: 32 8C DC      LD   (RR1_B), A
```

#### DMA: Hard Disk, Floppy, Display Channels

```asm
; Am9517A (8237) DMA mode register bits:
;   D1:D0 = channel select (00=Ch0, 01=Ch1, 10=Ch2, 11=Ch3)
;   D3:D2 = transfer type (01=write/IO→mem, 10=read/mem→IO)
;   D4    = auto-init enable
;   D5    = address decrement (0=increment)
;   D7:D6 = mode (00=demand, 01=single, 10=block, 11=cascade)

032E: 3E 20         LD   A, 0x20           ; DMA command register:
0330: D3 F8         OUT  (DMAC), A         ;   D5=1 (late write), D2=0 (enabled)

; Ch.0 mode (hard disk): set from config
0332: 3A 1C D5      LD   A, (CFG+0x1C)     ; = 0x48: Ch0, read/mem→IO, single
0335: D3 FB         OUT  (DMAMOD), A       ; HD default: memory → disk (write)

; Ch.1 mode (floppy): NOT set by INIT — programmed per-operation by disk driver

; Ch.2 mode (display): set from config
0337: 3A 1E D5      LD   A, (CFG+0x1E)     ; = 0x4A: Ch2, read/mem→IO, single
033A: D3 FB         OUT  (DMAMOD), A       ; Display: memory → 8275 CRT

; Ch.3 mode (display continued): set from config
033C: 3A 1F D5      LD   A, (CFG+0x1F)     ; = 0x4B: Ch3, read/mem→IO, single
033F: D3 FB         OUT  (DMAMOD), A       ; Display: memory → 8275 CRT (row 2)
```

#### FDC: Floppy Controller + Mini/Maxi Detection

```asm
; Check DIP switch for diskette size, then send SPECIFY command to µPD765
0341: DB 14         IN   A, (SW1)          ; Read DIP switches
0343: E6 80         AND  0x80              ; Test bit 7: diskette size
0345: CA E1 D7      JP   Z, IFD0           ; 0 = maxi disk, skip mini fixup

; Mini disk detected — change format table entries from 8 (maxi) to 16 (mini)
0348: 21 2F D5      LD   HL, CFG+0x2F      ; INFD0: floppy format byte
034B: 7E            LD   A, (HL)           ; Read format value
034C: FE 08         CP   0x08              ; Is it 8 (maxi format)?
034E: C2 D3 D7      JP   NZ, IFDX          ; Skip if already mini
0351: 36 10         LD   (HL), 0x10        ; Change to 16 (mini format)
0353: 23            INC  HL                ; Next drive slot (CFG+0x30)
0354: 7E            LD   A, (HL)
0355: FE 08         CP   0x08
0357: C2 DC D7      JP   NZ, IFDY
035A: 36 10         LD   (HL), 0x10        ; Change to 16

; Change FDC SPECIFY SRT/HUT for mini drives
IFDY:
035C: 3E 0F         LD   A, 0x0F           ; New SRT/HUT value
035E: 32 26 D5      LD   (CFG+0x26), A     ; Modify FDPROG+2: SRT=0 (slower step),
                                           ;   HUT=F (240ms head unload)

; Wait for FDC ready, then send SPECIFY command
IFD0:
0361: DB 04         IN   A, (FDC)          ; Read FDC main status register
0363: E6 1F         AND  0x1F              ; Mask drive-busy and command-busy bits
0365: C2 E1 D7      JP   NZ, IFD0          ; Wait until all bits clear (idle)

0368: 21 24 D5      LD   HL, CFG+0x24      ; FDPROG: FDC command block
036B: 46            LD   B, (HL)           ; B = byte count (3)

IFD1:
036C: 23            INC  HL                ; Point to next command byte
IFD2:
036D: DB 04         IN   A, (FDC)          ; Read FDC status
036F: E6 C0         AND  0xC0              ; Test RQM (bit 7) and DIO (bit 6)
0371: FE 80         CP   0x80              ; RQM=1, DIO=0: ready for CPU→FDC
0373: C2 ED D7      JP   NZ, IFD2          ; Wait

0376: 7E            LD   A, (HL)           ; Load command byte
0377: D3 05         OUT  (FDD), A          ; → FDC data port
0379: 05            DEC  B
037A: C2 EC D7      JP   NZ, IFD1          ; Loop: sends 03 DF 28

; FDPROG sends SPECIFY command (0x03) with:
;   SRT/HUT = 0xDF: SRT=D (step rate), HUT=F (head unload time)
;   HLT/ND  = 0x28: HLT=0x14 (head load time), ND=0 (DMA mode)
; Mini disk override changes SRT/HUT to 0x0F (slower stepping for mini drives)
```

Note: JP targets use relocated addresses (0xD700+) because the assembler
assigns labels at their runtime positions.  After the initial LDIR, both
the low-memory original and high-memory copy contain identical code, so
jumps to relocated addresses work correctly and smoothly transition
execution to the high-memory copy.

#### Display Buffer Clear

```asm
; Clear screen memory with spaces, clear background flags and variables
037D: 21 00 F8      LD   HL, 0xF800        ; DSPSTR: display buffer
0380: 11 01 F8      LD   DE, 0xF801
0383: 01 CF 07      LD   BC, 0x07CF        ; 2000-1 bytes (80×25)
0386: 36 20         LD   (HL), 0x20        ; Fill with space character
0388: ED B0         LDIR

038A: 21 00 F5      LD   HL, 0xF500        ; BGSTAR: background bit table
038D: 11 01 F5      LD   DE, 0xF501
0390: 01 FA 00      LD   BC, 250
0393: 36 00         LD   (HL), 0x00        ; Clear to zeros
0395: ED B0         LDIR

; Clear variable area CCTAD through end of RAM (0xFFD1-0xFFFF)
0397: 21 D1 FF      LD   HL, 0xFFD1
039A: 11 D2 FF      LD   DE, 0xFFD2
039D: 36 00         LD   (HL), 0x00
039F: 01 2E 00      LD   BC, 0x002E
03A2: ED B0         LDIR
```

#### CRT: Intel 8275 Display Controller

```asm
; 8275 CRT reset command: write 0x00 to command port, then 4 parameter bytes
; to data port.  Parameters read from config block +0x20 through +0x23.

03A4: 3E 00         LD   A, 0x00
03A6: D3 01         OUT  (DSPLC), A        ; CRT Reset command

03A8: 3A 20 D5      LD   A, (CFG+0x20)     ; PAR1 = 0x4F
03AB: D3 00         OUT  (DSPLD), A        ; Characters per row: (0x4F & 0x7F)+1 = 80

03AD: 3A 21 D5      LD   A, (CFG+0x21)     ; PAR2 = 0x98
03B0: D3 00         OUT  (DSPLD), A        ; Rows per frame: (0x98 & 0x3F)+1 = 25
                                           ; Underline position: (0x98 >> 4) = 9

03B2: 3A 22 D5      LD   A, (CFG+0x22)     ; PAR3 = 0x7A
03B5: D3 00         OUT  (DSPLD), A        ; H retrace: (0x7A & 0x1F)+2 = 28 chars
                                           ; V retrace: (0x7A >> 5)+1 = 4 lines

03B7: 3A 23 D5      LD   A, (CFG+0x23)     ; PAR4 = 0x4D
03BA: D3 00         OUT  (DSPLD), A        ; Lines/char: (0x4D >> 4)+1 = 5
                                           ; Cursor: D1:D0=01 = blinking block
                                           ; (comal80: 0x6D → 7 lines/char)

03BC: 3E 80         LD   A, 0x80
03BE: D3 01         OUT  (DSPLC), A        ; Load Cursor command

03C0: 3E 00         LD   A, 0x00
03C2: D3 00         OUT  (DSPLD), A        ; Cursor X position = 0
03C4: D3 00         OUT  (DSPLD), A        ; Cursor Y position = 0 (top-left)

03C6: 3E E0         LD   A, 0xE0
03C8: D3 01         OUT  (DSPLC), A        ; Preset Counters command

03CA: 3E 23         LD   A, 0x23
03CC: D3 01         OUT  (DSPLC), A        ; Start Display command
                                           ;   (0x23 = start, interrupt enable)
```

#### Runtime Variable Init + Boot Continuation

After the CRT setup, INIT clears BIOS variables, copies SIO WR5 settings
to runtime locations, copies the drive format table from config to BIOS
data area, then enables interrupts and proceeds to probe for a hard disk.
If the hard disk responds, it reads a configuration sector; otherwise it
sets boot drive to A: (floppy) and jumps to `BOOT_ENTRY` (0xDB78 for
rel.2.1, 0xDB7F for rel.2.2) which prints the signon banner and loads
CCP+BDOS from Track 1.

---

## Configuration Blocks (disk offsets 0x0000-0x027F)

The first 5 sectors of Track 0 Side 0 (5 × 128 = 640 bytes) contain
configuration data that is **modifiable by CONFI.COM** (or CONFIX.COM).
These sectors are loaded to RAM at 0x0000 by the boot ROM, then copied to
high memory by the first LDIR.  After WBOOT, the original locations at
0xD480-0xD6FF are **overwritten by BDOS code** — only the character
conversion tables at their final locations (0xF680-0xF7FF) persist.

### Disk layout of config sectors

```
Disk     RAM (after   Sector  Contents
Offset   1st LDIR)    (mini)
------   ---------    ------  --------
0x0000   0xD480       S1      Entry word + " RC702" signature + padding
0x0080   0xD500       S2      Hardware config (CTC, SIO, DMA, CRT, FDC)
0x0100   0xD580       S3      Output character conversion table (128 bytes)
0x0180   0xD600       S4      Input character conversion table (128 bytes)
0x0200   0xD680       S5      Semi-graphics conversion table (128 bytes)
```

The three 128-byte character tables are copied by the second LDIR from
0xD580-0xD6FF to their final locations at 0xF680-0xF7FF (56K) or from
0xDE00-0xDE7F to 0xF680-0xF7FF (58K).

For the 8" maxi format, two additional data sectors (0x0280-0x037F) contain
disk parameter blocks and format descriptors for the hard disk, before the
INIT code starts at 0x0380.

### Block 0: Entry + Signature (disk 0x0000-0x007F)

| Offset | Size | Field | rel.2.1 | rel.2.2 | compas | Description |
|--------|------|-------|---------|---------|--------|-------------|
| +0x00 | 2 | ENTRY | 80 02 | 80 02 | **80 03** | Entry address (LE word) |
| +0x02 | 6 | — | 00... | 00... | 00... | Zeros |
| +0x08 | 6 | SIG | " RC702" | " RC702" | " RC702" | Signature for boot ROM |
| +0x0E | 114 | — | 00... | 00... | 00... | Padding (rest of sector) |

### Block 1: Hardware Config (disk 0x0080-0x00FF)

This block contains initialization parameters for all hardware controllers.
INIT reads these values and sends them to I/O ports via OTIR sequences.

All four images are **identical** except where marked with **DIFFERS**.

| Offset | Size | Field | rel.2.1 | comal80 | rel.2.2 | compas | Description |
|--------|------|-------|---------|---------|---------|--------|-------------|
| +0x00 | 2 | CTC_CH0 | 47 20 | 47 20 | 47 **02** | 47 20 | CTC Ch.0 mode+count (SIO-A baud) |
| +0x02 | 2 | CTC_CH1 | 47 20 | 47 20 | 47 20 | 47 20 | CTC Ch.1 mode+count (SIO-B baud) |
| +0x04 | 2 | CTC_CH2 | D7 01 | D7 01 | D7 01 | D7 01 | CTC Ch.2 mode+count (display int) |
| +0x06 | 2 | CTC_CH3 | D7 01 | D7 01 | D7 01 | D7 01 | CTC Ch.3 mode+count (floppy int) |
| +0x08 | 9 | SIO_A | 18 04 47 03 61 05 20 01 1B | (same) | (same) | (same) | SIO Ch.A init (see decode below) |
| +0x11 | 11 | SIO_B | 18 02 10 04 47 03 60 05 20 01 1F | (same) | (same) | (same) | SIO Ch.B init (see decode below) |
| +0x1C | 4 | DMA | 48 49 4A 4B | (same) | (same) | **C0 4A 4B 00** | DMA channel config |
| +0x20 | 4 | CRT_PAR | 4F 98 7A 4D | 4F 98 7A **6D** | 4F 98 7A 4D | 4F 98 7A 4D | 8275 CRT reset params |
| +0x24 | 4 | FDPROG | 03 03 DF 28 | (same) | (same) | (same) | FDC SPECIFY cmd (count, cmd, SRT/HUT, HLT/ND) |
| +0x28 | 2 | FDC_CFG1 | 00 04 | **02 00** | **00 00** | 00 04 | FDC runtime config (driver use) |
| +0x2A | 2 | FDC_CFG2 | 06 06 | 06 06 | **0A** 06 | 06 06 | FDC runtime config (driver use) |
| +0x2C | 1 | FDC_GAP | 00 | 00 | 00 | 00 | FDC gap length |
| +0x2D | 1 | FDC_DTL | FA | FA | FA | FA | FDC data length |
| +0x2E | 1 | FDC_FILL | 00 | 00 | 00 | 00 | FDC fill byte |
| +0x2F | 1 | FDC_FMT | 08 | 08 | 08 | **00** | Floppy format (08=mini, 00=maxi) |
| +0x30 | 2 | DRV_CFG | 08 20 | 08 20 | 08 20 | **00 00** | Drive type/format |
| +0x32 | 14 | DRV_TBL | FF×14 | FF×14 | FF×14 | **00×14** | Drive table (FF=absent) |
| +0x40 | 4 | — | 02 02 00 00 | (same) | **24 CD 7C 19** | **00×4** | Unknown (not read by INIT) |
| +0x44 | 4 | CTC2 | D7 01 03 00 | (same) | D7 01 03 **01** | **00×4** | CTC2 Ch.0 mode+count, Ch.1-3 reset |
| +0x48 | 56 | — | 00×56 | 00×56 | **(code data)** | 00×56 | Padding (or rel.2.2 extra code) |

#### SIO Init Sequence Decode

INIT sends these bytes to the SIO control ports via `OTIR` (from config
offsets +0x08 and +0x11, relocated to 0xD508 and 0xD511 for 56K):

```asm
; At INIT+0x85 (0x0305 for mini):
LD HL, 0xD508    ; SIO-A config bytes (relocated config block +0x08)
LD B, 9          ; 9 bytes
LD C, 0x0A       ; SIO-A control port
OTIR             ; Send all bytes sequentially

LD HL, 0xD511    ; SIO-B config bytes (relocated config block +0x11)
LD B, 11         ; 11 bytes (2 extra for WR2 interrupt vector)
LD C, 0x0B       ; SIO-B control port
OTIR
```

**SIO Ch.A** (9 bytes: `18 04 47 03 61 05 20 01 1B`):

| Byte | Value | Register | Decode |
|------|-------|----------|--------|
| 1 | 0x18 | WR0 | Channel Reset |
| 2 | 0x04 | WR0 | Select WR4 |
| 3 | 0x47 | WR4 | ×16 clock, 1 stop bit, even parity |
| 4 | 0x03 | WR0 | Select WR3 |
| 5 | 0x61 | WR3 | Rx Enable, 7 bits/char, Auto Enables (CTS/DCD) |
| 6 | 0x05 | WR0 | Select WR5 |
| 7 | 0x20 | WR5 | Tx 7 bits, Tx disabled, DTR off, RTS off |
| 8 | 0x01 | WR0 | Select WR1 |
| 9 | 0x1B | WR1 | Ext Int + Tx Int + Rx Int on all chars |

**SIO Ch.B** (11 bytes: `18 02 10 04 47 03 60 05 20 01 1F`):

| Byte | Value | Register | Decode |
|------|-------|----------|--------|
| 1 | 0x18 | WR0 | Channel Reset |
| 2 | 0x02 | WR0 | Select WR2 |
| 3 | 0x10 | WR2 | Interrupt vector base = 0x10 (Ch.B only) |
| 4 | 0x04 | WR0 | Select WR4 |
| 5 | 0x47 | WR4 | ×16 clock, 1 stop bit, even parity |
| 6 | 0x03 | WR0 | Select WR3 |
| 7 | 0x60 | WR3 | Rx **disabled**, 7 bits/char, Auto Enables |
| 8 | 0x05 | WR0 | Select WR5 |
| 9 | 0x20 | WR5 | Tx 7 bits, Tx disabled, DTR off, RTS off |
| 10 | 0x01 | WR0 | Select WR1 |
| 11 | 0x1F | WR1 | Ext Int + Tx Int + Rx Int + Parity Special |

Both channels use **7-bit characters with even parity** — the standard
Danish/Nordic terminal configuration.  Ch.A (serial port) has Rx enabled
at init; Ch.B (printer/auxiliary) has Rx disabled.  Both have Tx disabled
at init (enabled only when actively transmitting).

The RC702 SIO operates in **async mode only** (WR4 D3:D2=01 selects 1 stop
bit, confirming async operation; D5:D4 sync mode bits are irrelevant).
The RC703 (MIC705) may additionally support synchronous mode via the sync
select port at 0x1E-0x1F.

When CONFI.COM changes the baud rate, it modifies the WR4 byte within
the SIO init sequence (byte 3 in the sequence, at config offset +0x0A
for Ch.A, +0x15 for Ch.B):
- **0x47** for 600–19200 baud (×16 clock mode)
- **0xC7** for 50–300 baud (×64 clock mode)

#### CTC Baud Rate Generation

From hardware manual section 2.3.5, page 32:

> "Channel 0 and 1 are used to generate the clock to channel A and B in the
> Z80A-SIO/2. [...] Input to these two channels is a clock of 0.614 MHz."

CTC mode byte 0x47 = counter mode, interrupt disabled, auto trigger,
time constant follows.  The CTC divides the 0.614 MHz input clock by the
count value.  The resulting frequency is then divided by the SIO's clock
mode (set in SIO WR4 bits D7:D6) to produce the baud rate.

The SIO init bytes in the config block set WR4 = 0x47:
- D7:D6 = 01 → **×16 clock mode**
- D3:D2 = 01 → 1 stop bit
- D1:D0 = 11 → even parity enabled

With CTC count = 0x20 (32) and ×16 clock: 614000 / 32 / 16 = **1200 baud**.
With CTC count = 0x02 (2) and ×16 clock: 614000 / 2 / 16 ≈ **19200 baud**.

**Baud rate table** (from hardware manual fig. 16, page 35):

| CTC count | SIO WR4 clock | Baud rate |
|-----------|---------------|-----------|
| 193 | ×64 (WR4=0xC7) | 50 |
| 128 | ×64 | 75 |
| 83 | ×64 | 110 |
| 64 | ×64 | 150 |
| 32 | ×64 | 300 |
| 64 | ×16 (WR4=0x47) | 600 |
| 32 | ×16 | **1200** (default) |
| 16 | ×16 | 2400 |
| 8 | ×16 | 4800 |
| 4 | ×16 | 9600 |
| 2 | ×16 | **19200** (rel.2.2 default) |

The SIO clock divisor changes between high and low baud rates: **×16 for
600–19200 baud, ×64 for 50–300 baud**.  When CONFI.COM changes the baud
rate, it modifies both the CTC count byte (config offset +0x00/+0x02)
**and** the SIO WR4 byte within the SIO init sequence (config offset
+0x0A for Ch.A, +0x15 for Ch.B).  These changes are written to Track 0
on disk and take effect at next boot, when INIT sends the config bytes
to the hardware via OTIR.

Config block default baud rates:

| Version | CTC Ch.0 count | SIO WR4 | Baud rate |
|---------|----------------|---------|-----------|
| rel.2.1 | 0x20 (32) | 0x47 (×16) | **1200** |
| comal80 | 0x20 (32) | 0x47 (×16) | **1200** |
| **rel.2.2** | **0x02 (2)** | 0x47 (×16) | **19200** |
| compas | 0x20 (32) | 0x47 (×16) | **1200** |

#### 8275 CRT Parameters

The CRT reset command (4 bytes) configures display geometry and cursor:

| Field | Bits | rel.2.1 | comal80 | Description |
|-------|------|---------|---------|-------------|
| PAR1 | 0x4F | 80 chars/row | same | Horizontal characters per row - 1 |
| PAR2 | 0x98 | 25 rows | same | Vertical rows, underline position |
| PAR3 | 0x7A | 27 H retrace, 4 V retrace | same | Retrace widths |
| PAR4 | 0x4D | **5 lines/char, blink uline** | **0x6D: 7 lines/char** | Lines per char row + cursor type |

PAR4 bits 0-1 control cursor appearance:
- 00 = blinking underline
- 01 = blinking block
- 10 = non-blinking underline
- 11 = non-blinking block

PAR4 bits 4-7 control lines per character row (value + 1).
CONFI.COM can modify PAR4 to change cursor shape and character height.

**comal80 DIFFERS**: PAR4 = 0x6D (7 lines/char) vs 0x4D (5 lines/char).
This gives taller characters with more inter-line spacing.

### Block 2: Output Character Conversion (disk 0x0100-0x017F → 0xF680)

128-byte table mapping character codes 0x00-0x7F for console output.
Applied by CONOUT before sending characters to the display.

| Version | Mapping |
|---------|---------|
| **rel.2.1** | **Danish/Norwegian**: @→Ø [\]→ÆØÅ `→ä {&#124;}→æø }→å ~→ü |
| comal80 | Identity (ASCII pass-through) |
| rel.2.2 | Identity (ASCII pass-through) |
| **compas** | **Danish/Norwegian** (same as rel.2.1) |

The Danish mapping substitutes ASCII punctuation with Nordic characters
from the RC702 character generator ROM (ROA296):

| ASCII | Code | CG code | Character |
|-------|------|---------|-----------|
| @ | 0x40 | 0x05 | Ø (capital) |
| [ | 0x5B | 0x0B | Æ |
| \ | 0x5C | 0x0C | Ø |
| ] | 0x5D | 0x0D | Å |
| ` | 0x60 | 0x16 | ä |
| { | 0x7B | 0x1B | æ |
| &#124; | 0x7C | 0x1C | ø |
| } | 0x7D | 0x1D | å |
| ~ | 0x7E | 0x0F | ü |

This is the standard Scandinavian 7-bit ASCII substitution scheme used in
1970s-80s terminals (DS 2089 / ECMA-94 variant).  CONFI.COM can switch
between Danish and ASCII output mapping.

### Block 3: Input Character Conversion (disk 0x0180-0x01FF → 0xF700)

128-byte table mapping character codes 0x00-0x7F for console input.
Applied by CONIN after reading keyboard characters.

**All four images: identity mapping** (no input translation).

### Block 4: Semi-Graphics Conversion (disk 0x0200-0x027F → 0xF780)

128-byte table used by the display driver for semi-graphics character
mapping.  Maps ASCII codes to the semi-graphics character generator ROM
(ROA327) addresses.  95 of 128 entries differ from identity.

The mapping sets bit 7 for most alphabetic characters and remaps digits
and punctuation to semi-graphic block elements.

Minor differences between versions (2-3 bytes):

| Position | rel.2.1 | comal80 | rel.2.2 | compas |
|----------|---------|---------|---------|--------|
| E (0x45) | 0x05 | 0x05 | 0x05 | **0xC5** |
| I (0x49) | 0x09 | **0xC9** | **0xC9** | 0x09 |

---

## BIOS Memory Map

### 56K System (rccpm22, CPM_med_COMAL80, CPM_v.2.2_rel.2.2)

```
Disk      After LDIR    Contents
Offset    to 0xD480
------    ----------    --------
0x0000    0xD480        Entry word + " RC702" signature
0x0080    0xD500        Hardware config block (ephemeral — overwritten by BDOS)
0x0100    0xD580        Output char table → copied to 0xF680
0x0180    0xD600        Input char table → copied to 0xF700
0x0200    0xD680        Semi-graphics table → copied to 0xF780
0x0280    0xD700        INIT code (one-time boot, overwritten by BDOS)
0x0580    0xDA00        BIOS base — permanent resident code

Final high-memory layout (after boot):
0xC400         CCP (Console Command Processor)
0xCC06         BDOS entry point (overwrites 0xCC06-0xD9FF including config area)
0xDA00         BIOS base — permanent resident code
0xEC00         Interrupt vector table (256-byte aligned, I=0xEC)
0xEC24+        Keyboard/parallel ISR code
0xEC70+        BIOS variables (disk state, FDC results, etc.)
0xEE80+        Directory buffer, disk parameter headers, allocation vectors
0xF500         Background bit table
0xF620         Interrupt stack
0xF680         Output character conversion table (128 bytes, persists)
0xF700         Input character conversion table (128 bytes, persists)
0xF780         Semi-graphics conversion table (128 bytes, persists)
0xF800-0xFFFF  Display buffer (80×25 = 2000 bytes + spare)
```

### 58K System (Compas) — **DIFFERS**

```
Disk      After LDIR    Contents
Offset    to 0xDD00
------    ----------    --------
0x0000    0xDD00        Entry word + signature
0x0080    0xDD80        Hardware config block
0x0100    0xDE00        Character tables → copied to 0xF680
0x0280    0xDF80        Extra data (DPB, format descriptors for hard disk)
0x0380    0xE080        INIT code (one-time)
...       0xE200        BIOS base

Final high-memory layout:
0xC800         CCP (estimated, +0x400 from 56K)
0xD006         BDOS entry
0xE200         BIOS base
0xF421         Interrupt vector page (I register value stored here)
0xF680-0xF7FF  Character conversion tables (same final location as 56K)
0xF800-0xFFFF  Display buffer (same)
```

Key differences from 56K:
- CODEDESTINAT = 0xDD00 (not 0xD480)
- CODELENGTH = 0x1B01 / 6913 bytes (not 0x2381 / 9089)
- IVT page stored at 0xF421 (not 0xEC25)
- INIT continues via JP 0xE0A4 (not inline)

---

## BIOS Jump Table

### Standard CP/M 2.2 Vectors (17 entries)

| Entry    | rel.2.1 | rel.2.2 | 58K    | Function |
|----------|---------|---------|--------|----------|
| BOOT     | DA00→DB78 | DA00→DB7F | E200→E2F8 | Cold boot |
| WBOOT    | DA03→DBC1 | DA03→DBC8 | E203→E328 | Warm boot |
| CONST    | DA06→EC28 | DA06→EC28 | E206→E4F3 | Console status |
| CONIN    | DA09→EC2C | DA09→EC2C | E209→E4F7 | Console input |
| CONOUT   | DA0C→E209 | DA0C→E210 | E20C→E961 | Console output |
| LIST     | DA0F→DC91 | DA0F→DC98 | E20F→E3AC | List output |
| PUNCH    | DA12→DCE4 | DA12→DCEB | E212→E3FF | Punch output |
| READER   | DA15→DCD4 | DA15→DCDB | E215→E3EF | Reader input |
| HOME     | DA18→E658 | DA18→E65F | E218→F1BF | Home disk |
| SELDSK   | DA1B→E2CD | DA1B→E2D4 | E21B→EE9E | Select disk |
| SETTRK   | DA1E→E376 | DA1E→E37D | E21E→EF18 | Set track |
| SETSEC   | DA21→E37C | DA21→E383 | E221→EF1E | Set sector |
| SETDMA   | DA24→E382 | DA24→E389 | E224→EF23 | Set DMA address |
| READ     | DA27→E38B | DA27→E392 | E227→EF2C | Read sector |
| WRITE    | DA2A→E39F | DA2A→E3A6 | E22A→EF3C | Write sector |
| LISTST   | DA2D→DC8D | DA2D→DC94 | E22D→E3A8 | List status |
| SECTRAN  | DA30→E388 | DA30→E38F | E230→EF29 | Sector translate |

**rel.2.2** jump targets are consistently offset by **+7 bytes** from rel.2.1.

### Non-Standard Extension Area (after SECTRAN)

At BIOS+0x33, configuration bytes and additional JP vectors:

```
+0x33  ADRMOD    1 byte   XY addressing mode flag
+0x34  WR5A      1 byte   SIO Write Reg 5 Ch.A value (rel.2.1: 0x20)
+0x35  WR5B      1 byte   SIO Write Reg 5 Ch.B value (rel.2.1: 0x20)
+0x36  MTYPE     1 byte   Machine type (rel.2.1: 0x00)
+0x37  (reserved) 2 bytes  (0x10 0x10 in rel.2.1)
+0x39  FD0-FD14  15 bytes Drive format config (0x20=mini, 0xFF=not present)
+0x47  BOOTD     1 byte   Boot device (0=floppy)
+0x48  (reserved) 2 bytes
+0x4A  JP WFITR           Wait for floppy interrupt (format utility)
+0x4D  JP READS           Reader status
+0x50  JP LINSEL          Line selector
+0x53  JP EXIT            Timer-based exit callback
+0x56  JP CLOCK           Clock access
+0x59  JP HRDFMT          Hard disk format
```

In the 56K rel.2.1 BIOS, FD0=0x20 (mini format), FD1-FD14=0xFF (not present).

### Extended BIOS Function Calling Conventions

The extended BIOS functions are called directly via `CALL` to absolute addresses
(not through BDOS).  Register conventions documented in the CP/M for RC702
User's Guide (RCSL No 42-i2190, Appendix A / Section 4.4).

#### CLOCK — Real-Time Clock (BIOS+56h / JP at +0x56)

32-bit real-time clock, incremented in steps of 20 ms by the display refresh ISR.

```
SET CLOCK:  A=0, DE=2 least significant bytes, HL=2 most significant bytes
GET CLOCK:  A=1, returns DE=2 LSB, HL=2 MSB
```

For 56K CP/M: `CALL 0DA56H`.  The clock value is stored at RTC0 (0xFFFC, 4 bytes).

#### EXIT — Periodic Callback (BIOS+53h / JP at +0x53)

Defines a routine to be called periodically from the display refresh ISR.

```
Entry:  HL = address of user routine
        DE = interval count (in 20 ms units)
```

After `count × 20 ms`, the routine at (HL) is called as an interrupt service
routine — it must not enable interrupts and should keep processing minimal.
The BIOS supports two independent EXIT routines (EXCNT0/EXCNT1).

#### LINSEL — Line Selector Control (BIOS+50h / JP at +0x50)

Controls the RC791 Line Selector (Linieselektor) for serial port multiplexing.

```
Entry:  A = port (0 = terminal/SIO Ch.A, 1 = printer/SIO Ch.B)
        B = function (0 = release line, 1 = select Line A, 2 = select Line B)
        C = irrelevant
Return: A = 0xFF if selection OK, 0x00 if line busy
```

Selection is automatically preceded by a release.  The line should be released
after use.  Uses SIO WR5 DTR/RTS signals for the handshake protocol.

#### READS — Reader Status (BIOS+4Dh / JP at +0x4D)

Tests reader (serial input) status, analogous to CP/M BDOS function 11
(console status).

```
Return: A = 0xFF if character available, 0x00 if none
```

#### WFITR — Wait for Floppy Interrupt (BIOS+4Ah / JP at +0x4A)

Entry point used by the FORMAT utility to wait for floppy controller interrupt
completion.

#### HRDFMT — Hard Disk Format (BIOS+59h / JP at +0x59)

Entry point for hard disk track formatting.

---

## Interrupt Vector Table (page 0xEC for 56K)

| Offset | Vector  | Handler   | Purpose |
|--------|---------|-----------|---------|
| +0x00  | CTC Ch.0 | 0xEBE8 (DUMITR) | SIO Ch.A baud rate (no ISR needed) |
| +0x02  | CTC Ch.1 | 0xEBE8 (DUMITR) | SIO Ch.B baud rate |
| +0x04  | CTC Ch.2 | 0xE242 (DSPITR) | Display refresh (50 Hz) |
| +0x06  | CTC Ch.3 | 0xE7D4 (FLITR)  | Floppy disk completion |
| +0x08  | CTC2 Ch.0 | 0xE987 (HDITR) | Hard disk completion |
| +0x0A  | CTC2 Ch.1 | 0xEBE8 (DUMITR) | Unused |
| +0x0C  | CTC2 Ch.2 | 0xEBE8 (DUMITR) | Unused |
| +0x0E  | CTC2 Ch.3 | 0xEBE8 (DUMITR) | Unused |
| +0x10  | SIO B TX  | 0xDD09 (TXB)   | Printer transmit |
| +0x12  | SIO B Ext | 0xDD22 (EXTSTB) | External status Ch.B |
| +0x14  | SIO B RX  | 0xDD3B (RCB)   | Printer receive |
| +0x16  | SIO B Spc | 0xDD50 (SPECB) | Special condition Ch.B |
| +0x18  | SIO A TX  | 0xDD6D (TXA)   | Serial transmit |
| +0x1A  | SIO A Ext | 0xDD86 (EXTSTA)| External status Ch.A |
| +0x1C  | SIO A RX  | 0xDD9F (RCA)   | Serial receive |
| +0x1E  | SIO A Spc | 0xDDB9 (SPECA) | Special condition Ch.A |
| +0x20  | PIO A     | 0xEC43 (KEYIT) | Keyboard interrupt |
| +0x22  | PIO B     | 0xEC58 (PARIN) | Parallel port ready |

`DUMITR` at 0xEBE8 is simply `EI; RETI`.

---

## Display Refresh (DSPITR at 0xE242)

The display ISR runs at 50 Hz (CTC Ch.2 interrupt) and:
1. Saves SP, switches to interrupt stack
2. Reads CRT status (port 0x01)
3. Programs DMA channels 2+3 for display buffer transfer
4. Sets DMA source to display buffer at 0xF800
5. Starts 8275 DMA display cycle (port 0x01)
6. Updates real-time clock counters
7. Checks exit routine timers
8. Manages floppy motor stop timer
9. Restores SP, returns via `EI; RETI`

---

## Floppy Disk Driver

The FDC driver uses sector blocking/deblocking — CP/M works with 128-byte
records but the physical disk uses 512-byte sectors (on data tracks).  The
BIOS maintains a host buffer (`HSTBUF`, 512 bytes) and translates CP/M
sector numbers to physical track/sector/offset within the host buffer.

### Warm boot sector loading
WBOOT reads 44 sectors (128 bytes each = 5632 bytes = CCP + BDOS) from Track 1
directly to CCPENTRY (0xC400), bypassing the blocking/deblocking logic.

---

## Version Comparison

### rel.2.1 vs rel.2.1 (rccpm22 vs CPM_med_COMAL80)

The two 56K rel.2.1 images have **identical BIOS code** — the single byte
difference at 0xEB7A is a runtime variable (not on disk).

**Configuration differences** (CONFI.COM-modifiable):

| Field | rccpm22 | comal80 | Impact |
|-------|---------|---------|--------|
| CRT PAR4 | 0x4D (5 lines/char) | **0x6D (7 lines/char)** | Taller characters |
| FDC SPECIFY | 00 04 | **02 00** | Different step rate/head timing |
| Output conv | Danish (Ø Æ Å) | **ASCII identity** | COMAL-80 needs ASCII |

### rel.2.1 vs rel.2.2 — **MAJOR DIFFERENCES**

| Aspect | rel.2.1 | rel.2.2 |
|--------|---------|---------|
| Signon | "rel.2.1" | "rel. 2.2" (extra space) |
| CTC Ch.0 count | **0x20 (32)** | **0x02 (2)** — different SIO-A baud rate |
| FDC SPECIFY | 00 04 | **00 00** |
| FDC extra +2A | 06 | **0A** |
| CTC2 config | 02 02 00 00 | **24 CD 7C 19** — completely different |
| CTC2 +44..+47 | D7 01 03 00 | D7 01 03 **01** |
| Padding +48..+7F | zeros | **code/data** — extra initialization |
| Output conv | Danish (Ø Æ Å) | **ASCII identity** |
| Jump table | DB78, DBC1, ... | **DB7F, DBC8, ...** (+7 offset) |
| BIOS code | baseline | **4245 bytes differ** in 0xDA00-0xEC40 |

The rel.2.2 config block at offsets 0x40-0x7F contains what appears to be
additional initialization code (Z80 opcodes: CALL, LD, JP sequences) rather
than the zeros found in rel.2.1.  This may represent hard disk support code
or extended INIT routines.

### 56K vs 58K (Compas) — **DIFFERENT BIOS VARIANT**

| Aspect | 56K | 58K (Compas) |
|--------|-----|--------------|
| Entry point | **0x0280** | **0x0380** |
| CODEDESTINAT | **0xD480** | **0xDD00** |
| CODELENGTH | **0x2381** (9089) | **0x1B01** (6913) |
| BIOS base | **0xDA00** | **0xE200** |
| IVT page addr | 0xEC25 | **0xF421** |
| BIOS size | 7680 bytes | **5632 bytes** |
| DMA config | 48 49 4A 4B | **C0 4A 4B 00** |
| FDC format | 08 (mini) | **00 (maxi)** |
| Drive table | FF×14 (absent) | **00×14** |
| CTC2 | 02 02 ... D7 01 03 00 | **00×8** (no CTC2) |
| Output conv | Danish | Danish |

---

## CONFI.COM / CONFIX.COM

**CONFI.COM** is Regnecentralen's standard configuration utility for the
RC702.  It modifies the config block on Track 0 Side 0 of the system disk
(and possibly also updates the running system in memory).  Changes take
effect at next boot when INIT reads the config bytes and programs the
hardware via OTIR.  **No CONFI.COM found on any of the four examined disk
images** — it may have been on a separate utility disk.

**CONFIX.COM** found on the rel.2.2 disk image only.  May be an extended
version of CONFI.COM, or may belong to a different utility suite.

### Official CONFI.COM Parameter Menu

The complete parameter set is documented in the CP/M for RC702 User's Guide
(RCSL No 42-i2190, Appendix G).  Default values marked with *.

#### G.1 Printer Port (SIO Channel A)

| Parameter | Options | Config location |
|-----------|---------|-----------------|
| G.1.1 Stop bits | 1=1 bit*, 2=1.5 bits, 3=2 bits | SIO-A WR4 (config +0x0A) |
| G.1.2 Parity | 1=even*, 2=none, 3=odd | SIO-A WR4 (config +0x0A) |
| G.1.3 Baud rate | 1=50, 2=75, 3=110, 4=150, 5=300, 6=600, 7=1200*, 8=2400, 9=4800, 10=9600, 11=19200 | CTC Ch.0 (config +0x00) + SIO-A WR4 |
| G.1.4 Bits/char | 1=5, 2=6, 3=7*, 4=8 | SIO-A WR3/WR5 (config +0x0C/+0x0E) |

#### G.2 Terminal Port (SIO Channel B)

| Parameter | Options | Config location |
|-----------|---------|-----------------|
| G.2.1 Stop bits | Same as G.1.1 (default: 1 bit) | SIO-B WR4 (config +0x15) |
| G.2.2 Parity | Same as G.1.2 (default: even) | SIO-B WR4 (config +0x15) |
| G.2.3 Baud rate | Same as G.1.3 (default: 1200) | CTC Ch.1 (config +0x02) + SIO-B WR4 |
| G.2.4 Bits/char Tx | Same as G.1.4 (default: 7) | SIO-B WR5 (config +0x18) |
| G.2.5 Bits/char Rx | Same as G.1.4 (default: 7) | SIO-B WR3 (config +0x16) |

The terminal port has separate Tx and Rx character width settings.

#### G.3 Conversion Tables

| Option | Language |
|--------|----------|
| 1 | Danish |
| 2 | Swedish |
| 3 | German |
| 4 | UK ASCII |
| 5 | US ASCII* |
| 6 | French |
| 7 | Library |

Changes the output and input character conversion tables (config sectors 3-4,
disk offsets 0x0100-0x01FF).

#### G.4 Cursor Presentation

| Parameter | Options |
|-----------|---------|
| G.4.1 Format | 1=blinking reverse video*, 2=blinking underline, 3=reverse video, 4=underline |
| G.4.2 Addressing | 1=H,V (horizontal,vertical)*, 2=V,H (vertical,horizontal) |

Cursor format modifies 8275 PAR4 byte (config +0x23).  Addressing order
modifies ADRMOD byte (BIOS+0x33).

#### G.5 Mini Motor Stop Timer

Range: 5–1200 seconds.  Default: 5 seconds.  Controls how long the 5.25"
floppy motor runs after the last disk access before being powered down.

### Config Block ↔ CONFI.COM Mapping

Summary of which config block fields each CONFI.COM parameter modifies:

- **Baud rates**: CTC time constants (config +0x00/+0x02) **and** SIO WR4
  clock divisor (config +0x0A/+0x15) — both must change together when
  crossing the 300/600 baud boundary (×64 below, ×16 above)
- **CRT display**: character height (lines/char), cursor shape (line/block),
  cursor blink (on/off) — via 8275 PAR4 byte (config +0x23)
- **Character mapping**: output and input conversion tables
  (config sectors 3-4, disk offsets 0x0100-0x01FF)
- **FDC timing**: step rate, head load time, head unload time (config +0x28)
- **Drive configuration**: mini/maxi format, drive presence table (config +0x2F)

**CONFIX.COM** found on the rel.2.2 disk image only.  May be an extended
version of CONFI.COM, or may belong to a different utility suite.  Not yet
disassembled.

---

## Hard Disk Configurations (RC763)

From CP/M for RC702 User's Guide, Appendix H.  The RC763 hard disk is
configurable via the HDINST command into 4 partition layouts.  These
correspond to the drive format entries FD5-FD9 in CPMBOOT.MAC (Winchester
disk types at format codes 32, 40, 48, 56, 64).

### Partition Layouts

| Config | Drive C (floppy) | Drive D | Drive E | Drive F | Drive G |
|--------|-----------------|---------|---------|---------|---------|
| 1 | 0.270 / 0.900 MB | 7.920 MB | — | — | — |
| 2 | 0.270 / 0.900 MB | 3.936 MB | 3.936 MB | — | — |
| 3 | 0.270 / 0.900 MB | 1.968 MB | 1.968 MB | 3.936 MB | — |
| 4 | 0.270 / 0.900 MB | 1.968 MB | 1.968 MB | 1.968 MB | 1.968 MB |

Drive C is always floppy (0.270 MB for mini, 0.900 MB for maxi).

### Disk Size → CP/M Parameters

| Capacity (MB) | Block size | Directory entries | DISKTAB.MAC format |
|----------------|-----------|-------------------|-------------------|
| 0.270 | 2 KB | 128 | Mini floppy DPB |
| 0.900 | 2 KB | 128 | Maxi floppy DPB |
| 1.968 | 4 KB | 512 | FD7 (code 48) |
| 3.936 | 8 KB | 512 | FD8 (code 56) |
| 7.920 | 16 KB | 512 | FD9 (code 64) |

The rel.2.2 DISKTAB.MAC TRKOFF change (drive D offset from 27 to 255) may
relate to partition reconfiguration.

---

## System Diskette Generation

From CP/M for RC702 User's Guide, Appendix C.  After patching BIOS/BDOS/CCP
as desired, the system is written to disk using SYSGEN:

1. Format diskette with FORMAT
2. Copy existing system using BACKUP, delete unwanted files with ERA
3. Write BIOS+BDOS+CCP using SYSGEN

**SYSGEN SAVE page counts** (256 bytes per page):
- Mini (5.25"): **68 pages** = 17,408 bytes
- Maxi (8"): **107 pages** = 27,392 bytes

These sizes represent the combined CCP + BDOS + BIOS image.  For 56K systems:
CCP starts at 0xC400, BIOS ends near 0xF500, giving ~12,544 bytes for the
56K resident code.  The difference between resident size and SAVE size accounts
for Track 0 config blocks and INIT code that are overwritten after boot.

---

## Disk Images Summary

| Image | Type | Entry | BIOS Base | CODEDESTINAT | Signon | Files |
|-------|------|-------|-----------|--------------|--------|-------|
| rccpm22.imd | 5.25" | 0x0280 | 0xDA00 | 0xD480 | rel.2.1 | 25 |
| CPM_med_COMAL80.imd | 5.25" | 0x0280 | 0xDA00 | 0xD480 | rel.2.1 | 21 |
| CPM_v.2.2_rel.2.2.bin | 5.25" | 0x0280 | 0xDA00 | 0xD480 | rel. 2.2 | 41 |
| Compas_v.2.13DK.imd | 8" | **0x0380** | **0xE200** | **0xDD00** | 58K CP/M VERS 2.2 | 21 |

---

## Reference Cross-Reference

### jbox.dk (rel.2.1)
The jbox.dk source closely matches our rel.2.1 disk images.  The module
structure (BIOS.MAC → CPMBOOT.MAC, SIO.MAC, DISPLAY.MAC, FLOPPY.MAC,
HARDDSK.MAC, DISKTAB.MAC, INTTAB.MAC, PIO.MAC) maps directly to the code
regions we see in the disassembly.

### rc702-bios (rel.2.2, heavily modified)
The rc702-bios memory map constants (CODEDESTINAT=0xD480, CODELENGTH=0x2381,
CONVLENGTH=0x0180, BIOSBASE=0xDA00) match all our 56K dumps exactly.
The INIT code structure and hardware port programming sequences are preserved.
The user's modifications (keyboard buffering, VT52, status line, ISO-8859-1,
clock) are NOT present in any of the stock disk images.

Note: rc702-bios places a "long-term configuration datablock" at 0xD500.
In the stock BIOS, this address is ephemeral (overwritten by BDOS after boot).
The rc702-bios author likely reorganized the memory layout to keep config
data persistent, which is NOT how the stock BIOS works.

---

## Generated Files

- `*_ram.bin` — Full 64K RAM dumps (captured via rc700 emulator `--memdump`)
- `*_bios.bin` — Extracted BIOS regions
- `*_bios.asm` — Z80 disassembly with labels
- `syms_56k_z80dasm.sym` — Symbol definitions for z80dasm
- `blocks_56k.def` — Code/data block boundaries for z80dasm
- `extract_bios.py` — BIOS extraction from RAM dumps
- `bin2imd.py` — Converter for raw BIN disk images to IMD format
