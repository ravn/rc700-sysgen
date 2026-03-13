# TODO: Extend z88dk RC700 Target Library

## Background

z88dk has the RC700 as a compilation target.  Add utility routines that
expose RC702-specific hardware features not available through standard
CP/M BDOS calls.

## Routines to Add

### 1. Cursor Shape/Blink Control

The Intel 8275 CRT controller cursor format is set via PAR4 bits 5:4:

| PAR4[5:4] | Cursor Style |
|-----------|-------------|
| 00 | Blinking block |
| 01 | Blinking underline |
| 10 | Non-blinking block |
| 11 | Non-blinking underline |

PAR4 is written during CRT initialization (INIPARMS) and can be
reprogrammed at runtime by rewriting the 8275 parameter registers.
Original PAR4 = 0x4D (blink block), REL30 PAR4 = 0x6D (non-blink block).

Note: CCP overwrites PAR4 after boot from the INIPARMS copy on disk.
Any runtime change persists only until warm boot unless the disk copy
is also updated.

API sketch:
```c
void rc700_cursor_style(uint8_t style);  /* 0=blink block, 1=blink underline, 2=block, 3=underline */
```

### 2. Serial Port Baud Rate

SIO baud rates are set via CTC channel divisors.  CTC clock is 0.614 MHz,
SIO uses x16 clock mode (or x64 for low rates).

| CTC divisor | Baud (x16) | Baud (x64) |
|-------------|-----------|-----------|
| 0x02 | 19200 | 4800 |
| 0x04 | 9600 | 2400 |
| 0x08 | 4800 | 1200 |
| 0x10 | 2400 | 600 |
| 0x20 | 1200 | 300 |

Channel A (terminal/modem): CTC channel 0 (port 0x0C).
Channel B (printer): CTC channel 1 (port 0x0D).

Changing baud also requires updating the SIO WR4 clock mode bit if
switching between x16 and x64.  REL30 defaults to 38400 on Channel A.

API sketch:
```c
void rc700_set_baud(uint8_t channel, uint16_t baud);  /* channel: 0=A, 1=B */
```

### 3. Character Mapping (Optional)

The RC702 BIOS has OUTCON (output conversion, 128 bytes at 0xF680) and
INCONV (input conversion, 128 bytes at 0xF700) tables.  These map
between the keyboard/screen character set and the CP/M character set,
used for Danish/Norwegian characters (Æ, Ø, Å).

The tables are loaded from the CONFI block on disk at boot.  Identity
mapping = no conversion.  CONFI.COM can reprogram them.

API sketch:
```c
void rc700_set_charmap(const uint8_t *outcon, const uint8_t *inconv);  /* 128 bytes each */
void rc700_reset_charmap(void);  /* restore identity mapping */
```

## Investigation

- Locate the RC700 target files in z88dk source tree
- Check what library routines already exist for the target
- Determine the right way to add machine-specific library functions
  (separate header? extend existing?)
- Check if z88dk has a convention for machine-specific I/O libraries

## References

- z88dk RC700 target: `z88dk/lib/target/rc700/` (or similar)
- Intel 8275 CRT: PAR4 cursor format (see CLAUDE.md)
- CTC baud rate: see `memory/MEMORY.md` baud rate section
- CONFI block: see `bios.h` ConfiBlock struct
