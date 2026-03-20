# CP/M for RC702 User's Guide (RCSL No 42-i2190, January 1983)

Authors: Jeffrey C. Snider, Vibeke Nielsen
Publisher: A/S Regnecentralen af 1979, Information Department
Second edition (first edition was RCSL No 42-i2131)
Reference manual: [1] = RCSL No 42-i1610: CP/M Operating System Manual, Digital Research, 1982

## System Overview (Section 1.2)
- CP/M version 2.2 with 50 1/4 K bytes available for transient programs
- Supports one or two 8-inch OR one or two 5 1/4-inch diskette drives
- 8-inch: 900 KB capacity, 5.25-inch: 270 KB capacity
- Optional RC763 hard disk: 8,142 = 8.820 KB capacity
- CP/M disk drives A and B (ref. [1], 1.2, p.3) map to physical floppy drives
- CP/M disk drives C-G map to hard disk partitions
- Printer port = CP/M LST: output (ref. [1], 1.6.1, p.11)
- Terminal port = CP/M PUN: (punch) and RDR: (reader) devices
- RC700 Parallel I/O Port is NOT supported by CP/M
- No IOBYTE function, no STAT device assignment, no MOVCPM program

## Extended BIOS Functions (Section 4.4)

These are NOT standard CP/M BIOS calls — accessed via CALL to BIOS addresses, not via BDOS.

### 4.4.1 Real-Time Clock (BIOS+45h)
- 32-bit real-time clock, incremented in steps of 20ms
- For 56k CP/M: BIOS = 0xDA00, so clock entry = 0xDA45
- Access via `CALL 0DA45H` (not via CP/M command)
- **SET CLOCK**: A=0, DE=2 least significant bytes, HL=2 most significant bytes
- **GET CLOCK**: A=1, returns DE=2 LSB, HL=2 MSB

### 4.4.2 EXIT Routine (BIOS+48h)
- Defines a periodic callback routine
- HL=address of EXIT routine, DE=count (in 20ms units)
- After count*20ms, the routine will be called
- Runs as interrupt service — must not enable interrupts, keep processing minimal

### 4.4.3 Line Selector Control (BIOS+4Bh)
- Controls RC791 Line Selector
- A=PORT (0=terminal port, 1=printer port)
- B=FUNCTION (0=release, 1=select line A, 2=select line B)
- C=irrelevant
- **RESULT**: 255=selection OK, 0=line busy
- Selection automatically preceded by release
- Should release line after use

### 4.4.4 Reader Status (BIOS+4Ah)
- Tests RDR: reader status
- Similar to CP/M function 11 (console status)
- Returns FF if character available, 00 otherwise

## BIOS Jump Table Extended Entries
Standard CP/M BIOS entries at BIOS+0 through BIOS+2Fh (functions 0-16).
Extended RC700 entries:
- BIOS+33h: JP WFITR (format utility entry)
- BIOS+36h: JP READS (reader status)
- BIOS+39h: JP LINSEL (line selector)
- BIOS+3Ch: JP EXIT (exit routine)
- BIOS+3Fh: JP CLOCK (real-time clock)
- BIOS+42h: JP HRDFMT (hard disk format)

## RC-Specific Transient Commands

### Device Handling Commands (Section 4.3)

| Command | Version string | Purpose |
|---------|---------------|---------|
| FORMAT | `RC700 FORMAT UTILITY VERS 1.2 82.03.03` | Format diskettes |
| HDINST | `RC700 HARD DISK INSTALLATION - VERS.1.1 82.09.28` | Configure RC763 hard disk |
| BACKUP | `RC700 BACKUP VERS 2.1 82.10.12` | Copy entire diskettes |
| ASSIGN | (none) | Assign SD/DD format to 8" drive |
| VERIFY | `RC700 DISKETTE VERIFICATION VERS.1.0 82.09.14` | Check disk for bad sectors |
| STORE | `RC700 STORE VERS.1.1 83.01.03` | Backup HD files to floppy |
| RESTORE | `RC700 RESTORE VERS: 1.0 82.10.06` | Restore files from STORE backup |
| SYSGEN | `SYSGEN VERS 2.0` | Write CP/M system tracks |
| CONFI | `RC700 CP/M CONFIGURATION UTILITY vers 2.1 13.02.33` | Configure BIOS parameters |
| SELECT | (none) | Control RC791 Line Selector |
| AUTOEXEC | `RC700 Autoexec vers. 1.0 10.01.83` | Auto-execute command on boot |

### File Handling Commands

| Command | Version string | Purpose |
|---------|---------------|---------|
| TRANSFER | `RC700 TRANSFER UTILITY VERS 2.0 82.01.05` | Transfer files between formats |
| CAT | (none) | Enhanced directory listing |
| FILEX | (none) | File transfer between computers |

### FORMAT details
- 5.25" mini: always DS/DD, 36 tracks. No format prompt.
- 8" maxi: prompts for type — 1=SS/SD (128 B/S, 26 S/T) or 2=DS/DD (512 B/S, 15 S/T). 77 tracks.
- CP/M System Diskettes always use format type 2 (DS/DD).

### BACKUP details
- With `FAST` option: copies without verifying.
- If HD system has logical disk C, it may also be used as source/dest.

### TRANSFER details
- Reads up to 32K at a time. Asks user to swap disks.
- Source/dest format must be specified: SS or DD.
- 5.25" defaults to DD; format prompt only for 8".

### FILEX details
- Remote computer: `FILEX REMOTE`
- Remote drives prefixed with R (RA:, RB:)
- `MORED` option keeps remote in remote mode after transfer
- Cables: CML012/013/014 (direct), CML092/093/094 (with Line Selector)

### XSUB
- Extends SUBMIT: first command in .SUB file
- Relocates below CCP, provides buffered console input to PIP/ED/DDT
- Message `(xsub active)` when resident

## Configuration / CONFI.COM (Appendix G)

CONFI utility configures parameters stored on Track 0 of system diskette. Default values marked with *.

Main menu: 1.PRINTER PORT, 2.TERMINAL PORT, 3.CONVERSION, 4.CURSOR, 5.MINI MOTOR STOP TIMER, 6.SAVE CONFIGURATION DESCRIPTION

### G.1 Printer Port (SIO Channel A)
- G.1.1 Stop bits: 1=1bit*, 2=1.5bit, 3=2bits
- G.1.2 Parity: 1=even*, 2=no, 3=odd
- G.1.3 Baud rate: 1=50, 2=75, 3=110, 4=150, 5=300, 6=600, 7=1200*, 8=2400, 9=4800, 10=9600, 11=19200
- G.1.4 Bits/char: 1=5bits, 2=6bits, 3=7bits*, 4=8bits

### G.2 Terminal Port (SIO Channel B)
- G.2.1 Stop bits: same as G.1.1 (default: 1 stop bit)
- G.2.2 Parity: same as G.1.2 (default: even)
- G.2.3 Baud rate: same as G.1.3 (default: 1200)
- G.2.4 Bits/char to transmit: same as G.1.4 (default: 7 bits)
- G.2.5 Bits/char to receive: same as G.1.4 (default: 7 bits)

### G.3 Conversion Tables
1=Danish, 2=Swedish, 3=German, 4=UK ASCII, 5=US ASCII*, 6=French, 7=Library

### G.4 Cursor Presentation
- G.4.1 Format: 1=blinking reverse video*, 2=blinking underline, 3=reverse video, 4=underline
- G.4.2 Addressing: 1=H,V (horizontal,vertical)*, 2=V,H (vertical,horizontal)

### G.5 Mini Motor Stop Timer
- Range: 5-1200 seconds, Default: 5 seconds

## Diskette Formats (Appendix E)

### E.1 System Diskette
**5.25" Mini**: DS/DD, 512 bytes/sector, 9 sectors/track, 36 cylinders
- 270 KB drive capacity in blocks of 2 KB
- 128 directory entries
- 2 reserved cylinders
- Logical sector mapping with 2:1 interleave, zero track-to-track skew
- Recommended type: Verbatim MD550-01-1818E

**8" Maxi**: DS/DD, 512 bytes/sector, 15 sectors/track, 77 cylinders
- 900 KB drive capacity in blocks of 2 KB
- 128 directory entries
- 2 reserved cylinders
- Logical sector mapping with 4:1 interleave, zero track-to-track skew
- Recommended type: 3M 743-0-512

### E.2 Data Diskettes
8" "standard exchange" format: SS/SD, 128 bytes/sector, 26 sectors/track, 77 cylinders
- 241 KB drive capacity in blocks of 1 KB
- 64 directory entries
- 2 reserved tracks
- Logical sector mapping with 6:1 interleave, zero track-to-track skew
- Recommended type: 3M-740/2-0

## Hard Disk Configurations (Appendix H)

RC763 hard disk, configurable via HDINST command in 4 configurations:

### H.1 Configurations and Capacities
| Config | Drive C | Drive D | Drive E | Drive F | Drive G |
|--------|---------|---------|---------|---------|---------|
| 1      | 0.270/0.900 | 7.920 | - | - | - |
| 2      | 0.270/0.900 | 3.936 | 3.936 | - | - |
| 3      | 0.270/0.900 | 1.968 | 1.968 | 3.936 | - |
| 4      | 0.270/0.900 | 1.968 | 1.968 | 1.968 | 1.968 |

Drive C = floppy (0.270 mini / 0.900 maxi)

### H.2 Disk Size -> CP/M Parameters
| Capacity (MB) | Block size | Directory entries |
|---------------|-----------|-------------------|
| 0.270         | 2k        | 128               |
| 0.900         | 2k        | 128               |
| 1.968         | 4k        | 512               |
| 3.936         | 8k        | 512               |
| 7.920         | 16k       | 512               |

Hard disk boot requires DF016 autoload PROM (micro fuse, pos. 66) and CP/M system
copied to HD tracks 0+1 via HDINST.

## Display Handling (Appendix B)

### B.1 X-Y Addressing
- Control char 6 followed by two bytes: horizontal+32(20h), vertical+32(20h)
- Screen coordinates: (0,0) = upper left, (79,24) = lower right (confirmed 80x25)
- Cursor addressing order configurable: H,V (default) or V,H

### B.2 Control Characters
| Code | Function |
|------|----------|
| 1    | Insert line at cursor, scroll remainder down |
| 2    | Delete line at cursor, scroll remainder up |
| 5    | Cursor left (backspace) |
| 8    | Same as 5 (backspace) |
| 9    | Cursor 4 positions forward (tab) |
| 10   | Cursor down (line feed) |
| 12   | Clear screen, reset attributes, cursor to (0,0) |
| 13   | Cursor to position 0 on current line (CR) |
| 20   | Mark subsequent chars as background |
| 21   | Mark subsequent chars as foreground |
| 23   | Delete foreground chars without affecting background |
| 24   | Cursor right (forward-space) |
| 26   | Cursor up |
| 29   | Cursor to (0,0) home position |
| 30   | Erase from cursor to end of line |
| 31   | Erase from cursor to end of screen |

### B.3 Attributes
Each character position has an attribute byte (128 + sum of attributes):
- 2 (02h): blinking
- 4 (04h): semigraphic
- 16 (10h): inverse video
- 32 (20h): underscore
Attributes combine additively. "Set attribute" = 128+value, "Reset attribute" = 128.

### B.4 Semigraphic Character Set
Semigraphic attribute (04h) activates alternate character generator ROM (ROA327).

## Keyboard (Appendix D)
- Two keyboard layouts: RC721 and RC722
  - Early: RC721 before KBU723 serial #51, RC722 before KBU722 serial #384
  - Later productions follow different layout (Fig. 3 in manual)
- Keyboard conversion table patch address: baseaddress + key value
- Mini diskette systems: base = 0x2E80
- Maxi diskette systems: base = 0x4680
- Keyboard sends ready-to-use 8-bit codes via PIO Port A (0x10)

## Peripheral Support (Appendix F)

### F.1 Printer Port (SIO Channel A)
- Serial interface with RTS/CTS busy handshake
- DTR asserted, then RTS asserted, CTS gates TXD

### F.2 Terminal Port (SIO Channel B)
- Transmitter: same handshake as printer
- Receiver: uses DCD signal to enable receiving
- Can be used for modem, PC connection, or FILEX file transfer

## FILEX Protocol (Appendix I)

### Transaction opcodes
| Opcode | Operation | Request | Answer |
|--------|-----------|---------|--------|
| 1 | OPEN | 16B filename | result |
| 2 | MAKE | 16B filename | result |
| 3 | READ | (none) | result + 128B data |
| 4 | WRITE | 16B data | result |
| 5 | CLOSE | (none) | result |
| 6 | END | (none) | result |

Result codes: 0=ok, 1=does not exist, 2=full, 3=end of file

### Block format
1. Start: ASCII 35 (#)
2. Block size: 16-bit as 4 ASCII digits (each +64)
3. Data: each byte as 2 ASCII digits (each +64)
4. Checksum: 8-bit as 2 ASCII digits; (sum of original + checksum) mod 256 = 0
5. Stop: ASCII 13 (CR)
Total per N data bytes: 2*N + 9 characters

## System Diskette Generation (Appendix C)
1. Patch BIOS/BDOS/CCP as desired
2. Format diskette with FORMAT
3. Copy existing system using BACKUP, delete unwanted files with ERA
4. Write BIOS+BDOS+CCP using SYSGEN
- SYSGEN works with or without a previously created COM file
- Mini systems: SAVE 68 pages (256 bytes each)
- Maxi systems: SAVE 107 pages

## Error Recovery (Section 5)
- 5.1 BAD SECTOR error: retry, ignore (RETURN key), or abort (^C reboot)
- 5.2 SELECT error: non-existent disk drive selected
- 5.3 READ ONLY error: disk has R/O attribute (needs warm boot after disk change)
- 5.4 FILE R/O error: file has read-only attribute (change with STAT)
- All errors reported as: `BDOS ERR ON d: message`

## Line Editing
- Key marked `<-`: deletes last character typed
- Key marked `->`: deletes entire line typed
- Up arrow (8) used for CTRL notation: 8C = CTRL-C

## Boot Process (Section 2.2)
- Cold boot: press RESET button or power on
- Displays: `RC700  56k CP/M vers.2.2  rel.x.x` then `A>`
- Warm boot: CTRL+C (required after disk change to clear R/O status)
- AUTOEXEC can auto-run a command after cold/warm boot
