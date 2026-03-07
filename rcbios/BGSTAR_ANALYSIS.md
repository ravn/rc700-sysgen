# BGSTAR — Selective Character Clear Feature

## Overview

BGSTAR is a **250-byte position bitmap** at `0xF500` that tracks which screen positions
were written in "background" mode. It enables an escape sequence to selectively erase only
those characters, leaving the rest of the display untouched.

This is **not** a semi-graphics or pixel-drawing feature. It operates entirely at the
character-cell level, using one bit per screen position (80×25 = 2000 positions = 250 bytes).

## Memory Layout

| Address | Size | Name | Description |
|---------|------|------|-------------|
| 0xF500 | 250 B | BGSTAR | Bitmap: 1 bit per screen cell (80×25/8) |
| 0xFFDB | 1 B | BGFLG | Current mode (0/1/2, see below) |
| 0xFFDC | 2 B | LOCBBU | Pointer into BGSTAR for current scroll line |

`BGFLG` values:
- `0` — disabled (after clear screen)
- `1` — foreground mode (after `ESC F`)
- `2` — background mode (after `ESC S`)

## Escape Sequences

| Sequence | Handler | Effect |
|----------|---------|--------|
| `ESC S` | ESCSB | Enter background mode: `BGFLG ← 2` |
| `ESC F` | ESCSF | Enter foreground mode: `BGFLG ← 1` |
| `ESC C` | ESCCF | Clear foreground: erase only positions marked in BGSTAR |

## How It Works

### Writing in background mode (BGFLG = 2)

Each character sent to `CONOUT` is displayed normally **and** its screen position
is marked in BGSTAR:

```
bit_offset = screen_position / 8   → byte index in BGSTAR
bit_number = screen_position % 8   → bit within that byte
BGSTAR[bit_offset] |= (1 << bit_number)
```

### Clear foreground (ESC C, BGFLG = 1)

Scans BGSTAR byte by byte:
- If byte = 0x00: write 8 spaces at the corresponding 8 screen positions
- If byte ≠ 0x00: test each bit; write a space at every position where the bit is set

Result: only characters that were previously written in background mode are blanked.
Normal foreground text is left intact.

### Screen operations

`LOCBBU` is updated by scroll and line insert/delete operations to keep it pointing
to the last line of BGSTAR (BGSTAR+240), so that newly scrolled-in lines start with
a clean bitmap state.

## Use Case

Typical application: a form-based UI where background text (labels, borders) is drawn
first in background mode, then interactive foreground text is layered on top. A single
`ESC C` clears all foreground input without redrawing the background.

## Presence in BIOS Variants

| Variant | BGSTAR present |
|---------|---------------|
| REL20–REL23 | Yes (0xF500, 250 bytes) |
| REL30 | Could be removed (saves **382 bytes** of code + data) |
| RC702E (rel.2.01, rel.2.20) | **No** — feature removed; 0xFFDB–0xFFDD unused |
| RC703 | Not verified |

## Code Locations (src/DISPLAY.MAC)

- `ESCSB` — enter background mode, clear BGSTAR, set BGFLG=2
- `ESCSF` — enter foreground mode, set BGFLG=1
- `ESCCF` — clear foreground: scan BGSTAR and blank marked positions
- `DISPL` — normal character output; if BGFLG=2, marks bit in BGSTAR
- Scroll handlers — update LOCBBU to track last BGSTAR line

## REL30 Removal Estimate

Removing BGSTAR for REL30 would save approximately **382 bytes**:
- 250 bytes BGSTAR table (0xF500–0xF5F9)
- ~132 bytes of ESCSB/ESCSF/ESCCF code and conditional checks in DISPL/scroll

See `DISPL_OPTIMIZATION.md` for related display optimisation notes.
