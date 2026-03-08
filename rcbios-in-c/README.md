# RC702 CP/M BIOS in C (REL30)

Rewrite of the REL30 BIOS in C using z88dk with sdcc backend, following the
same approach as `autoload-in-c/` (ROA375 PROM rewrite).

See `rcbios/BIOS_IN_C_PLAN.md` for the full implementation plan.

## Status

**Phase 1a: Build skeleton** — COMPLETE

All source files compile and link into a correct binary layout:
- Boot entry at offset 0x000 with CBOOT pointer and " RC702" identification
- CONFI config block at offset 0x080 (hardware init parameters)
- Conversion tables at offset 0x100 (384 bytes from danish.bin)
- INIT code at offset 0x280 (LDIR relocation, hw init, JP to BIOS)
- BIOS JP table at offset 0x580 (runtime 0xDA00, 17 standard entries)
- JTVARS at 0xDA33 (fixed addresses for CONFI.COM compatibility)
- Extended JP table at 0xDA49
- IVT at 0xDB00 (256-byte aligned, 18 entries)
- C functions (stubs) in code_compiler section at 0xDB29+
- Current size: 2032 bytes (fits both mini and maxi)

All BIOS entries are stubs: boot halts, console returns defaults, disk
returns errors. ISRs use `__interrupt` attribute (EI+RETI only).

## Building

Requires z88dk installed at `../z88dk/`.

```bash
make bios    # build bios.cim
make size    # check fit against mini/maxi limits
make clean   # remove build artifacts
```

## Architecture

- **crt0.asm**: Binary layout, JP table, IVT, fixed-address variables (DEFC)
- **bios.c**: All BIOS entry points and ISRs in C
- **bios.h**: Constants, memory layout, extern declarations
- **hal.h**: Hardware abstraction (`__sfr __at` port I/O for Z80)
- **danish.bin**: Character conversion tables (384 bytes, extracted from assembled BIOS)
- **peephole.def**: SDCC peephole optimizer rules

### z88dk notes

- `org 0xD480` in crt0.asm sets the linker section base address, but ASMPC
  remains section-relative (starts at 0). All `defs` padding expressions use
  `(target - START) - ASMPC` where `START equ 0xD480`.
- `-pragma-define:CRT_ORG_CODE=0xD480` sets the binary output origin.
- The binary starts at file offset 0 = runtime address 0xD480. The ROM
  bootstrap loads this to physical address 0x0000 and the INIT code copies
  it to 0xD480 via LDIR.

## Next steps

- Phase 1b: CRT display refresh ISR (DMA programming for 8275)
- Phase 1c: Keyboard input (PIO ISR + ring buffer)
- Phase 1d: Console output (CONOUT with escape sequences)
- Phase 1e: Floppy disk driver (blocking/deblocking)
- Phase 1f: Boot sequence (load CCP+BDOS, signon message)
