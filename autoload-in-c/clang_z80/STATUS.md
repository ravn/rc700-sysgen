# Clang Z80 PROM Build Status

## Current: CP/M Boots, 2453 bytes

PROM: 2453/4096 bytes (60%). CP/M boots in MAME.
SDCC: 1872 bytes. Gap: 581 bytes (31% larger).

Boot section (boot_rom.c) is now C with 4 irreducible asm
instructions (di, ld sp, jp, retn).  The compiler inlines
boot_copy/boot_zero and generates LDIR for both.

## Build
```bash
make clang         # build PROM
make clang_prom    # build + install to MAME/RC700
make clang_asm     # show assembly
make clang_clean   # clean
```

## Enabled compiler features

| Flag | Effect |
|------|--------|
| `-Os` | Optimize for size |
| `+static-stack` | Allocate locals in BSS (non-reentrant) |
| `+shadow-regs` | Use EXX for ISR save/restore |
| `--gc-sections` | Dead code elimination |
| `-ffunction-sections` | Per-function sections for GC |
| `-disable-lsr` | Disable loop strength reduction (saves ~90 bytes) |
| `-fno-freestanding` | Enable memcpy→LDIR inlining |

## Known code quality issues

### IX used to hold constant across LDIR (boot_main)

The compiler loads BSS size into IX before the first LDIR, then
transfers it to BC via `dec ix; push ix; pop bc` (6 bytes, 33T).
Optimal would be `ld bc, imm` (3 bytes, 10T) after the first LDIR.

```asm
; Current (6 bytes):
    dd 2b        dec  ix
    dd e5        push ix
    c1           pop  bc
    ed b0        ldir

; Optimal (5 bytes):
    01 5c 00     ld   bc, $5c
    ed b0        ldir
```

Root cause: register allocator puts the BSS size in IX because
BC/DE/HL are all occupied by the first LDIR.  A peephole or
post-RA optimization in the backend could fix this.

### Other known issues

See [BUGS.md](BUGS.md) for backend bugs found during development.
See [llvm-z80 issues](https://github.com/ravn/llvm-z80/issues) for
filed backend issues.
