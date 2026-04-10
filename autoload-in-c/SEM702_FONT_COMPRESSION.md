# SEM702 Font Compression Options

The full SEM702 font is 128 characters × 16 dot lines × 1 byte = 2048 bytes.
This won't fit in the PROM alongside the boot code (currently 1829 bytes)
within the 2KB limit. With the 4KB solder bridge closed, compressed font
data could be embedded directly in the PROM, eliminating the need for a
separate font ROM in the PROM1 socket.

## Compression approaches

### 1. Skip unused scan lines (31% savings)

The 8275 is configured for 11 lines per character (PAR3), so lines 11–15
are always zero. Store only 11 bytes per character.

- **Size:** 128 × 11 = 1408 bytes
- **Decompressor:** trivial — write 11 stored bytes, then 5 zeros per char
- **Complexity:** minimal

### 2. Skip blank characters (additional ~20%)

Control characters 0–31 and DEL (127) are typically all-zero. Store a
128-bit presence bitmap (16 bytes) indicating which characters have data.

- **Size:** ~96 chars × 11 bytes + 16 byte bitmap = ~1072 bytes
- **Decompressor:** check bitmap bit, write 11 stored bytes or 11 zeros
- **Complexity:** low

### 3. Per-line presence bitmask (best general compression)

For each character, store a 16-bit (or 11-bit) mask of which lines are
non-zero, followed by only the non-zero data bytes.

- **Size:** ~96 chars × (2 byte mask + ~8 data bytes) = ~960 bytes
- **Decompressor:** for each char, read mask, write data or zero per bit
- **Complexity:** moderate

### 4. Column trimming (diminishing returns)

Most characters are 5–7 pixels wide. Store per-character left-shift and
width, pack only the active columns. Significant complexity for ~15% gain.

- **Not recommended** — complicates the bit-reversal logic and the
  decompressor needs shift operations per line.

## Fit analysis

| Approach | Font size | Boot code | Total | Fits 2KB? | Fits 4KB? |
|----------|-----------|-----------|-------|-----------|-----------|
| Uncompressed | 2048 | 1829 | 3877 | No | Yes |
| Skip scan lines | 1408 | ~1850 | ~3258 | No | Yes |
| + Skip blanks | ~1072 | ~1880 | ~2952 | No | Yes |
| Per-line mask | ~960 | ~1920 | ~2880 | No | Yes |

Boot code size increases slightly due to the decompressor (~20–60 bytes).

All compressed approaches fit comfortably in 4KB but none fit in 2KB.
The simplest practical option is approach 2 (skip scan lines + skip
blanks) at ~1072 bytes with minimal decompressor complexity.

## Prerequisite

The 4KB PROM solder bridge on the PCB must be closed (connecting A11 to
the PROM sockets). See docs/PROM_SCHEMATICS.PNG and the hardware
technical reference for details. This is unconfirmed on actual hardware.

## Current implementation

The current `load_chargen()` in rom.c reads an uncompressed font from
PROM1 (0x2000) with bit-reversal. To use a compressed embedded font,
the function would read from a const array in the PROM code section
instead, with no bit-reversal needed (data stored in SEM702-native
LSB-first order).
