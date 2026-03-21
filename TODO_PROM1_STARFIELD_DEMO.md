# TODO: PROM1 Starfield Demo

Create a non-trivial demo for PROM1 (0x2000) that shows a moving
starfield expanding toward the viewer.

## How it works

The boot ROM's `prom1_if_present()` checks for `" RC702"` at 0x2002
and jumps via the 16-bit vector at 0x2000.  This is the fallback path
when no bootable floppy is found.

## Constraints

- PROM1 at 0x2000, max 2KB (2716) or 4KB (2732)
- Must have `" RC702"` signature at offset 0x2002
- Must have jump address (entry point) at offset 0x2000
- Display buffer at 0x7800 (80x25 characters)
- CRT DMA refresh ISR already running from boot ROM (0x7000+)
- Character set: ASCII + RC702 character ROM (ROA296/ROA327)
- No floppy needed — runs when boot ROM finds no disk

## Starfield design

- Stars start at center (row 12, col 40) and expand outward
- Use different characters for depth: `.` `*` `o` `O`
- Each frame, move stars further from center
- Stars reaching the edge respawn at center with random direction
- Simple PRNG for star positions (LFSR or similar)

## Project structure

- `prom1-demo/` directory with own Makefile, sections.asm
- Written in C with z88dk/sdcc (same toolchain as autoload-in-c)
- Testable in MAME by installing to roms/rc702/ alongside roa375.ic66
