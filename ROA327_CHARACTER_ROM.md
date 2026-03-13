# RC702 Character ROM Analysis

The RC702 uses two character ROMs, each 2048 bytes (128 chars x 16 bytes):

| Position | ROM | Contents |
|----------|-----|----------|
| 81 | **ROA296** | Main character generator: accented chars, uppercase, lowercase |
| 82 | **ROA327** | Semigraphics: line drawing, 2x3 block graphics |

The two ROMs share identical glyphs at 0x40-0x5F (uppercase A-Z, Danish
letters) and 0x20 (space). They differ in the 0x00-0x1F, 0x21-0x3F, and
0x60-0x7F ranges.

## ROM Selection: 8275 GPA0 Field Attribute

The two ROMs are concatenated into a 4KB address space:
- ROA296 at offset 0x000-0x7FF
- ROA327 at offset 0x800-0xFFF

The 8275 CRT controller outputs 7-bit character codes (CC0-CC6). The
ROM is selected by the **GPA0** (General Purpose Attribute 0) output pin,
which is controlled by 8275 **field attribute codes** in display memory.

- **GPA0=0** (default): character codes address ROA296 (main chargen)
- **GPA0=1**: character codes address ROA327 (semigraphics)

Address formula: `rom[(linecount & 15) | (charcode << 4) | (GPA0 ? 0x800 : 0)]`

The 8275 character code is always 7 bits (`data & 0x7F`); byte values
0x80-0xBF in display memory are field attribute codes, 0xC0-0xEF are
character attribute codes, and 0xF0-0xFF are special codes. Only bytes
0x00-0x7F produce displayable characters.

### ROM Contents by Character Code

| Code Range | ROA296 (GPA0=0) | ROA327 (GPA0=1) |
|------------|-----------------|-----------------|
| 0x00-0x1F | Accented/special chars | **Line drawing** (32 chars) |
| 0x20 | Space | Space (pattern 0, blank) |
| 0x21-0x3F | Punctuation, digits | **2x3 blocks (patterns 1-31)** |
| 0x40-0x5F | @, A-Z, Æ, Ø, Å | @, A-Z, Æ, Ø, Å (same) |
| 0x60-0x7F | Lowercase a-z + accented | **2x3 blocks (patterns 32-63)** |

## 8275 Field Attribute Codes (0x80-0xBF)

Byte values 0x80-0xBF in display memory are interpreted by the 8275 as
field attribute codes (bits 7:6 = 10). They are **not** displayed as
characters. On the RC702, PAR4 bit 6 = 1, so field attributes use
"visible" mode: the attribute position is blanked (shown as empty).

The attribute applies from that position forward until the next field
attribute code, and **persists across rows**.

Field attribute bit layout:

```
Bit 7: 1 \
Bit 6: 0 / field attribute marker (always 10)
Bit 5: U   underline (LTEN)
Bit 4: R   reverse video (RVV)
Bit 3: G1  GPA1 (general purpose attribute 1)
Bit 2: G0  GPA0 (general purpose attribute 0) — ROM select
Bit 1: B   blink (VSP)
Bit 0: H   highlight
```

Common field attribute codes:

| Code | Bits Set | Effect |
|------|----------|--------|
| 0x80 | (none) | Normal: GPA0=0, no blink/reverse |
| 0x82 | B | Blink |
| 0x84 | G0 | **GPA0=1: select ROA327 (semigraphics)** |
| 0x86 | G0+B | GPA0=1 + blink |
| 0x90 | R | Reverse video |
| 0x94 | R+G0 | Reverse + GPA0=1 |

## How to Display Semigraphics (Direct Screen Memory)

To display block or line drawing characters by writing directly to
display memory at 0xF800:

### Step 1: Write a field attribute to enable GPA0

Write byte `0x84` to the first screen position. This sets GPA0=1,
selecting ROA327 for all subsequent characters. The attribute position
itself is displayed as blank.

```z80
    ld hl,0xF800
    ld (hl),0x84        ; field attr: GPA0=1 → select ROA327
```

The field attribute persists across rows (the 8275 saves/restores it
via `m_stored_attr`). One attribute at the start of the screen enables
GPA0 for all 24 rows.

### Step 2: Write character codes

With GPA0=1, character codes 0x00-0x7F are looked up in ROA327 instead
of ROA296:

```z80
    inc hl
    ld (hl),0x3F        ; full block (pattern 31: top+middle+left half)
    inc hl
    ld (hl),0x7F        ; full block (pattern 63: all 6 sub-blocks)
    inc hl
    ld (hl),0x09        ; vertical line (line drawing char)
```

### Step 3: Return to normal text (optional)

Write field attribute `0x80` to reset GPA0=0, returning to ROA296:

```z80
    ld hl,0xF800 + 80*10   ; row 10, col 0
    ld (hl),0x80            ; field attr: GPA0=0 → back to ROA296
    inc hl
    ld (hl),'H'             ; normal text from here
    inc hl
    ld (hl),'i'
```

### Mixed semigraphics and text on the same screen

Field attributes take one screen position each (displayed as blank).
Each transition between normal and semigraphics mode costs one character
position. For a screen that mixes text and graphics:

```
[0x84][gfx][gfx][gfx][0x80][ ][H][e][l][l][o][0x84][gfx][gfx]...
  ^blank   blocks      ^blank  text             ^blank   blocks
```

### Full-screen semigraphics example

For a full-screen 160x72 image, only one field attribute is needed:

```z80
    ; Position 0: field attribute (displayed as blank)
    ld hl,0xF800
    ld (hl),0x84

    ; Positions 1-1919: block pattern character codes
    ; (first row has 79 usable positions, subsequent rows have 80)
    inc hl
    ld (hl),0x20        ; blank block (pattern 0)
    inc hl
    ld (hl),0x7F        ; full block (pattern 63)
    ; ...
```

## 2x3 Block Semigraphics (Teletext-style)

### Encoding

Each character cell is divided into a 2-wide x 3-tall grid of sub-blocks,
giving an effective pixel resolution of **160 x 72** on the 80x24 screen.

The 6 sub-blocks are encoded as a 6-bit value:

```
+----+----+
| b0 | b1 |  top row     (ROM rows 0-2, 3 scanlines)
+----+----+
| b2 | b3 |  middle row  (ROM rows 3-6, 4 scanlines)
+----+----+
| b4 | b5 |  bottom row  (ROM rows 7-10, 4 scanlines)
+----+----+
```

Bit assignment:
- Bit 0 = top-left
- Bit 1 = top-right
- Bit 2 = mid-left
- Bit 3 = mid-right
- Bit 4 = bottom-left
- Bit 5 = bottom-right

Pattern value = sum of set bits (0-63).

### Character Cell Pixel Layout

Each ROM character is 8 bits wide x 16 rows tall. Only **7 pixels** are
displayed (bits 0-6); bit 7 is always 0 and is not output by the 8275
(the character clock is 11.64 MHz / 7 = 1.663 MHz, yielding exactly 7
dot clocks per character).

Block sub-cell pixel widths:
- Left half: bits 0-3 (4 pixels wide)
- Right half: bits 4-6 (3 pixels wide)

This means the left sub-block column is slightly wider (4 px) than the
right column (3 px). Adjacent characters share no gap — the full 7-pixel
width is used.

### Character Code Mapping (with GPA0=1)

The 64 block patterns (0-63) map to two ranges of ROA327:

| Pattern | ROA327 Code | Character Code | Formula |
|---------|-------------|----------------|---------|
| 0 (blank) | 0x20 | 0x20 (space) | — |
| 1-31 | 0x21-0x3F | 0x21-0x3F | code = 0x20 + P |
| 32-63 | 0x60-0x7F | 0x60-0x7F | code = 0x60 + (P - 32) |

In C:
```c
uint8_t pattern_to_charcode(uint8_t pattern) {
    if (pattern < 32)
        return 0x20 + pattern;
    else
        return 0x60 + (pattern - 32);
}
```

To decode a character code back to a pattern (when GPA0=1):
```c
uint8_t charcode_to_pattern(uint8_t code) {
    if (code >= 0x20 && code <= 0x3F)
        return code - 0x20;       /* patterns 0-31 */
    else if (code >= 0x60 && code <= 0x7F)
        return code - 0x60 + 32;  /* patterns 32-63 */
    else
        return 0;                 /* non-block character */
}
```

### Pixel Coordinate Mapping

For a virtual pixel at (x, y) where 0 <= x < 160, 0 <= y < 72:

```c
/* GPA0 must already be set to 1 via a field attribute */
uint8_t cell_x = x / 2;          /* character column (0-79) */
uint8_t cell_y = y / 3;          /* character row (0-23) */
uint8_t sub_col = x % 2;         /* 0=left, 1=right */
uint8_t sub_row = y % 3;         /* 0=top, 1=mid, 2=bottom */
uint8_t bit = sub_row * 2 + sub_col;  /* bit position in pattern */

/* Read current character from display memory */
uint16_t addr = 0xF800 + cell_y * 80 + cell_x;
uint8_t ch = mem[addr];

/* Decode current pattern */
uint8_t pattern = charcode_to_pattern(ch);

/* Set or clear the pixel */
pattern |= (1 << bit);           /* set pixel */
/* pattern &= ~(1 << bit); */    /* clear pixel */

/* Encode back to character code */
mem[addr] = pattern_to_charcode(pattern);
```

## Line Drawing Characters (ROA327 0x00-0x1F)

With GPA0=1, character codes 0x00-0x1F access the line drawing
characters in ROA327:

```
0x00: ╰  bottom-right corner    0x01: ╯  bottom-left corner
0x02: ╭  top-right corner       0x03: ╮  top-left corner
0x04: ┬  T-junction down        0x05: ┤  T-junction left
0x06: ├  T-junction right       0x07: ┴  T-junction up
0x08: ─  horizontal line        0x09: │  vertical line
0x0A: ┼  cross/intersection

0x0B: ╲  diagonal (TL to BR)    0x0C: ╱  diagonal (TR to BL)
0x0D: ⌝  upper-left arc         0x0E: ⌜  upper-right arc
0x0F: ⌞  lower-left arc         0x10: ⌟  lower-right arc
0x11: ⌢  arc top                0x12: ⌣  arc bottom
0x13: ╲  half-diagonal UL→mid   0x14: ╱  half-diagonal UR→mid
0x15: ╱  half-diagonal mid→LL   0x16: ╲  half-diagonal mid→LR
0x17: ╳  diagonal cross (X)

0x18: ╲  vertical→diagonal left 0x19: ╱  vertical→diagonal right
0x1A: ╲  diagonal left→vertical 0x1B: ╱  diagonal right→vertical

0x1C: ◆  diamond                0x1D: ▲  tree/filled arrow
0x1E: ♥  heart                  0x1F: ✳  compass star
```

Example: draw a box using line drawing characters (GPA0=1):
```z80
    ; Assumes GPA0=1 is already set
    ld hl,0xF800 + 80*5 + 10   ; row 5, col 10
    ld (hl),0x02                ; top-left corner
    inc hl
    ld (hl),0x08                ; horizontal line
    inc hl
    ld (hl),0x08                ; horizontal line
    inc hl
    ld (hl),0x03                ; top-right corner
    ; next row: vertical lines
    ld hl,0xF800 + 80*6 + 10
    ld (hl),0x09                ; vertical line
    ld hl,0xF800 + 80*6 + 13
    ld (hl),0x09                ; vertical line
    ; bottom row
    ld hl,0xF800 + 80*7 + 10
    ld (hl),0x00                ; bottom-left corner
    inc hl
    ld (hl),0x08                ; horizontal line
    inc hl
    ld (hl),0x08                ; horizontal line
    inc hl
    ld (hl),0x01                ; bottom-right corner
```

## ROA296: Main Character Generator (Position 81)

### Accented Characters (0x00-0x1F)

Contains Scandinavian accented characters, diacritics, ligatures,
cedilla, brackets, and typographic symbols for Danish/Norwegian text.
Accessed as character codes 0x00-0x1F when GPA0=0.

### Lowercase Letters (0x60-0x7F)

Standard lowercase a-z plus accented variants (æ, ø, å, etc.).

## Danish/Norwegian Characters

The standard ASCII positions for `[\]` are replaced with Danish letters:

| Character Code | Standard ASCII | RC702 |
|----------------|----------------|-------|
| 0x5B | `[` | Æ |
| 0x5C | `\` | Ø |
| 0x5D | `]` | Å |

These are identical in both ROMs (0x40-0x5F range is shared).
The BIOS OUTCON/INCONV tables can remap these for international use.

### BGSTAR Background Mode

The BIOS supports a "background mode" for semigraphics via ESC Ctrl-T
(enter) and ESC Ctrl-U (exit). In background mode, characters are OR'd
into existing semigraphic cells rather than replacing them. The BGSTAR
mechanism tracks which screen positions are in background mode via a
250-byte bit table. The BIOS handles the GPA0 field attribute insertion
internally.

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

## Tools

- `tools/bitmap2rc700.py` — Convert monochrome images to RC702 screen
  buffers (block mode: 160x72 via 2x3 blocks; full mode: 80x24 via
  character matching). Outputs binary screen buffers with correct field
  attribute encoding.
- `tools/chartest.asm` — Test program: writes field attributes and
  character codes to display memory to verify ROM selection and all
  character ranges.
- `tools/gfxshow.asm` — Viewer for 6 test images (smiley, ghost, house,
  star, cat, RC logo).

## References

- ROM files: `roa296.rom` (pos 81, chargen), `roa327.rom` (pos 82, semigraphics)
- 8275 CRT controller datasheet (field attributes, GPA output pins)
- COMAL-80 manual section C.5.1.2 (semigraphics access from COMAL)
- COMAL-80 manual section C.7.2 (RC862/RC867 printer escape commands)
- BIOS source: `rcbios/src/DISPLAY.MAC` (BGSTAR implementation)
- MAME driver: `src/mame/regnecentralen/rc702.cpp` (display_pixels callback)
- TODO: `TODO_Z88DK_RC700_TARGET.md` (semigraphics library API)
