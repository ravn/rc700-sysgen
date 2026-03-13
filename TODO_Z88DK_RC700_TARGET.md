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

### 4. Semigraphics Mode (Crude Graphics Demo)

The RC702 uses two character ROMs: ROA296 (main chargen, position 81)
and ROA327 (semigraphics, position 82).  The 8275 CRT controller's
**GPA0** output pin selects the ROM.  GPA0 is set via **field attribute
codes** written to display memory.  See `ROA327_CHARACTER_ROM.md` for
full details.

ROM selection:
- Write field attribute `0x84` to display memory to set GPA0=1 (ROA327)
- Write field attribute `0x80` to reset GPA0=0 (ROA296, normal text)
- Field attributes persist across rows; one `0x84` at the start of the
  screen enables ROA327 for all subsequent characters
- Field attribute positions display as blank (one lost character position)

ROA327 contains 2x3 block graphics (Teletext-style) and line drawing
characters.  Each character cell is divided into a 2-wide by 3-tall
grid of "pixels", giving an effective resolution of 160x72.

Block encoding (6-bit pattern, bit 0 = top-left):
```
+----+----+
| b0 | b1 |  top     bit = sub_row * 2 + sub_col
+----+----+
| b2 | b3 |  mid     sub_col: 0=left, 1=right
+----+----+
| b4 | b5 |  bot     sub_row: 0=top, 1=mid, 2=bot
+----+----+
```

Character codes (with GPA0=1):
- pattern 0-31 → char code `0x20 + P` (ROA327 0x20-0x3F)
- pattern 32-63 → char code `0x60 + (P - 32)` (ROA327 0x60-0x7F)
- line drawing → char codes `0x00-0x1F` (ROA327 0x00-0x1F)

The BIOS BGSTAR (background/foreground star) mechanism tracks which
screen positions are in "background mode" via a 250-byte bit table.
ESC Ctrl-T enters background mode, ESC Ctrl-U returns to foreground.
Characters written in background mode are OR'd into the semigraphic
cells rather than replacing them.  The BIOS handles the GPA0 field
attribute insertion internally.

ROA327 also has 32 line drawing characters (corners, T-junctions,
diagonals, arcs, curves, and symbols like diamond/heart/star) at
char codes 0x00-0x1F (with GPA0=1).

API sketch:
```c
void rc700_gfx_plot(uint8_t x, uint8_t y);    /* set pixel at 160x72 */
void rc700_gfx_clear(uint8_t x, uint8_t y);   /* clear pixel */
void rc700_gfx_cls(void);                      /* clear graphics screen */
uint8_t rc700_gfx_get(uint8_t x, uint8_t y);  /* test pixel */
```

Implementation: ensure GPA0=1 (field attr 0x84 at screen start), then
map (x,y) to character cell (x/2, y/3), compute the bit within the
2x3 block (bit = sub_row*2 + sub_col), decode the current character
code to a 6-bit pattern, OR/AND the bit, encode back to character
code, write to display memory at 0xF800.

A demo program could draw lines, boxes, or simple animations to
showcase the semigraphics capability.

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
