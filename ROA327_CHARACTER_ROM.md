# RC702 Character ROM Analysis

The RC702 uses two character ROMs, each 2048 bytes (128 chars x 16 bytes):

| Position | ROM | Contents |
|----------|-----|----------|
| 81 | **ROA296** | Main character generator: accented chars, uppercase, lowercase |
| 82 | **ROA327** | Semigraphics: line drawing, 2x3 block graphics |

The two ROMs share identical glyphs at 0x40-0x5F (uppercase A-Z, Danish
letters) and 0x20 (space). They differ in the 0x00-0x1F, 0x21-0x3F, and
0x60-0x7F ranges.

The 8275 CRT controller shifts character pixels out LSB-first, so bit 0
is the leftmost pixel on screen.

## Character Set Layout

| Screen Code Range | ROM Address | ROA296 (pos 81) | ROA327 (pos 82) |
|-------------------|-------------|------------------|------------------|
| 0x00-0x1F | (control codes) | Not displayed | Not displayed |
| 0x20 | 0x20 | Space | Space |
| 0x21-0x3F | 0x21-0x3F | Punctuation, digits | **2x3 blocks (1-31)** |
| 0x40-0x5F | 0x40-0x5F | @, A-Z, Æ, Ø, Å | @, A-Z, Æ, Ø, Å (same) |
| 0x60-0x7F | 0x60-0x7F | Lowercase a-z + accented | **2x3 blocks (32-63)** |
| 0x80-0x9F | (CRT attributes) | Not displayed | Not displayed |
| 0xA0-0xBF | 0x20-0x3F | (same as 0x20-0x3F) | (same as 0x20-0x3F) |
| 0xC0-0xDF | 0x00-0x1F | Accented/special chars | **Line drawing** |
| 0xE0-0xFF | 0x20-0x3F | (same as 0x20-0x3F) | **2x3 blocks (0-31)** |

### ROM Selection Hardware

The two ROMs are concatenated into a 4KB address space:
- ROA296 at offset 0x000-0x7FF (charcode bit 7 = 0)
- ROA327 at offset 0x800-0xFFF (charcode bit 7 = 1)

Address formula: `rom[(linecount & 15) | (charcode << 4)]`

So **bit 7 of the character code selects the ROM**:
- Screen codes 0x00-0x7F → ROA296 (main chargen)
- Screen codes 0x80-0xFF → ROA327 (semigraphics)

Within ROA327, the screen code maps as:
- 0x80-0x9F → ROA327 chars 0x00-0x1F (line drawing) — but these
  overlap with 8275 attribute codes; access mechanism unclear
- 0xA0-0xBF → ROA327 chars 0x20-0x3F (space + 2x3 blocks 1-31)
- 0xC0-0xDF → ROA327 chars 0x40-0x5F (uppercase, same as ROA296)
- 0xE0-0xFF → ROA327 chars 0x60-0x7F (2x3 blocks 32-63)

**Open question**: Screen codes 0x80-0x9F are normally intercepted by
the 8275 as attribute codes and not displayed. How does the real hardware
access the line drawing characters at ROA327 0x00-0x1F? Possibilities:
1. The 8275 GPA (General Purpose Attribute) output selects the ROM
   independently of the character code
2. The BGSTAR mode overrides the 8275's attribute handling
3. The BIOS uses a different mechanism (e.g., DMA to display memory
   writes both character and attribute bytes)

## ROA296: Main Character Generator (Position 81)

### Accented Characters (0x00-0x1F, screen 0xC0-0xDF)

Contains Scandinavian accented characters, diacritics, ligatures,
cedilla, brackets, and typographic symbols for Danish/Norwegian text.

### Lowercase Letters (0x60-0x7F)

Standard lowercase a-z plus accented variants (æ, ø, å, etc.).

## CRT Attribute Codes (0x80-0x9F)

Screen codes 128-159 are interpreted by the 8275 CRT controller as
character attribute instructions, not as characters. They modify the
display of subsequent characters.

| Code | Attribute |
|------|-----------|
| 0x80 | Normal (no highlight) |
| 0x82 | Blink |
| 0x90 | Reverse video |
| 0x92 | Reverse + blink |

Base attribute code is 0x80. Add +2 for blink, +16 for reverse video.

## Danish/Norwegian Characters

The standard ASCII positions for `[\]` are replaced with Danish letters:

| Screen Code | ROM Code | Standard ASCII | RC702 |
|-------------|----------|----------------|-------|
| 0x5B | 0x5B | `[` | Æ |
| 0x5C | 0x5C | `\` | Ø |
| 0x5D | 0x5D | `]` | Å |

The BIOS OUTCON/INCONV tables can remap these for international use.

## Line Drawing Characters (ROM 0x00-0x1F, screen 0xC0-0xDF)

```
0xC0: ╰  bottom-right corner    0xC1: ╯  bottom-left corner
0xC2: ╭  top-right corner       0xC3: ╮  top-left corner
0xC4: ┬  T-junction down        0xC5: ┤  T-junction left
0xC6: ├  T-junction right       0xC7: ┴  T-junction up
0xC8: ─  horizontal line        0xC9: │  vertical line
0xCA: ┼  cross/intersection

0xCB: ╲  diagonal (TL to BR)    0xCC: ╱  diagonal (TR to BL)
0xCD: ⌝  upper-left arc         0xCE: ⌜  upper-right arc
0xCF: ⌞  lower-left arc         0xD0: ⌟  lower-right arc
0xD1: ⌢  arc top                0xD2: ⌣  arc bottom
0xD3: ╲  half-diagonal UL→mid   0xD4: ╱  half-diagonal UR→mid
0xD5: ╱  half-diagonal mid→LL   0xD6: ╲  half-diagonal mid→LR
0xD7: ╳  diagonal cross (X)

0xD8: ╲  vertical→diagonal left 0xD9: ╱  vertical→diagonal right
0xDA: ╲  diagonal left→vertical 0xDB: ╱  diagonal right→vertical

0xDC: ◆  diamond                0xDD: ▲  tree/filled arrow
0xDE: ♥  heart                  0xDF: ✳  compass star
```

## 2x3 Block Semigraphics (Teletext-style)

### Encoding

Each character cell is divided into a 2-wide x 3-tall grid of sub-blocks,
giving an effective pixel resolution of **160 x 72** on the 80x24 screen.

The 6 sub-blocks are encoded as a 6-bit value:

```
+----+----+
| b0 | b1 |  top row     (ROM rows 0-2)
+----+----+
| b2 | b3 |  middle row  (ROM rows 3-6)
+----+----+
| b4 | b5 |  bottom row  (ROM rows 7-10)
+----+----+
```

Bit assignment (8275 LSB-first scan: bit 0 = leftmost pixel):
- Bit 0 = top-left
- Bit 1 = top-right
- Bit 2 = mid-left
- Bit 3 = mid-right
- Bit 4 = bottom-left
- Bit 5 = bottom-right

Pattern value = sum of set bits (0-63).

### Screen Code Computation

The 64 block patterns (0-63) are split across two screen code ranges:

| Pattern | ROM Address | Screen Code | Formula |
|---------|-------------|-------------|---------|
| 0 (blank) | 0x20 | 0x20 (space) | — |
| 1-31 | 0x21-0x3F | 0xE1-0xFF | screen = 0xE0 + P |
| 32-63 | 0x60-0x7F | 0x60-0x7F | screen = 0x40 + P |

To compute screen code from a 6-bit pattern P:
```c
screen_code = (P < 32) ? (0xE0 + P) : (0x40 + P);
```

### Pixel Coordinate Mapping

For a virtual pixel at (x, y) where 0 <= x < 160, 0 <= y < 72:

```c
uint8_t cell_x = x / 2;          /* character column (0-79) */
uint8_t cell_y = y / 3;          /* character row (0-23) */
uint8_t sub_col = x % 2;         /* 0=left, 1=right */
uint8_t sub_row = y % 3;         /* 0=top, 1=mid, 2=bottom */
uint8_t bit = sub_row * 2 + sub_col;  /* bit position in pattern */

/* Read current character from display memory */
uint16_t addr = 0xF800 + cell_y * 80 + cell_x;
uint8_t ch = mem[addr];

/* Decode current pattern from screen code */
uint8_t pattern;
if (ch >= 0xE0)
    pattern = ch - 0xE0;         /* patterns 0-31 */
else if (ch >= 0x60 && ch <= 0x7F)
    pattern = ch - 0x60 + 32;    /* patterns 32-63 */
else
    pattern = 0;                 /* non-graphic char, treat as blank */

/* Set or clear the pixel */
pattern |= (1 << bit);           /* set pixel */
/* pattern &= ~(1 << bit); */    /* clear pixel */

/* Encode back to screen code */
if (pattern < 32)
    mem[addr] = 0xE0 + pattern;
else
    mem[addr] = 0x60 + (pattern - 32);
```

### BGSTAR Background Mode

The BIOS supports a "background mode" for semigraphics via ESC Ctrl-T
(enter) and ESC Ctrl-U (exit). In background mode, characters are OR'd
into existing semigraphic cells rather than replacing them. The BGSTAR
mechanism tracks which screen positions are in background mode via a
250-byte bit table.

## Character Cell Dimensions

Each character in the ROM is 8 pixels wide x 16 rows tall:
- Rows 0-10: character body (11 rows)
- Rows 11-15: blank (descender/spacing area, always zero in this ROM)

The 2x3 block characters use:
- Top block: rows 0-2 (3 rows)
- Middle block: rows 3-6 (4 rows)
- Bottom block: rows 7-10 (4 rows)

Left block: bits 0-2 (3 pixels wide, leftmost on screen)
Right block: bits 4-7 (4 pixels wide, rightmost on screen)

## COMAL-80 Access Convention

In COMAL-80, the ESC prefix (`CHR$(27)`) before a character code causes
it to be printed literally to the screen rather than being interpreted
by the COMAL-80 interpreter. This is the standard way COMAL-80 programs
access semigraphics and line drawing characters. The ESC convention is
a COMAL-80 interpreter feature, not a hardware mechanism.

## Printer Semigraphics (RC862/RC867)

The RC862 and RC867 printers may have had firmware upgrades to support
the same semigraphics character set as the RC702 screen. The COMAL-80
manual section C.7.2 documents the escape commands understood by these
printers.

## References

- ROM files: `roa296.rom` (pos 81, chargen), `roa327.rom` (pos 82, semigraphics)
- 8275 CRT controller datasheet (character addressing, LSB-first scan)
- COMAL-80 manual section C.5.1.2 (semigraphics access from COMAL)
- COMAL-80 manual section C.7.2 (RC862/RC867 printer escape commands)
- BIOS source: `rcbios/src/DISPLAY.MAC` (BGSTAR implementation)
- TODO: `TODO_Z88DK_RC700_TARGET.md` (semigraphics library API)
