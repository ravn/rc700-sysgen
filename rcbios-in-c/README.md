# RC702 CP/M BIOS in C (REL30)

Rewrite of the REL30 BIOS in C using z88dk with sdcc backend, following the
same approach as `autoload-in-c/` (ROA375 PROM rewrite).

See `rcbios/BIOS_IN_C_PLAN.md` for the full implementation plan.

## Status

**Phase 1b: CRT ISR + keyboard** — COMPLETE

- Phase 1a (skeleton): correct binary layout, all stubs in place
- Phase 1b (display): CRT ISR programs DMA for 8275 display refresh,
  increments 32-bit RTC, decrements timers (exit routine, motor-off, delay)
- Keyboard ISR stores keys in 16-byte ring buffer (REL30)
- CONST/CONIN read from keyboard ring buffer with INCONV table conversion
- Current size: 2343 bytes (fits both mini and maxi)

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

### ISR design

ISRs needing stack switching use `__naked` wrappers with explicit register
save/restore (PUSH AF/BC/DE/HL/IY, SP switch, CALL body, restore, EI, RETI).
This is necessary because sdcc's `__interrupt` puts EI at the *start* of the
function, enabling nested interrupts.  The CRT ISR must run with interrupts
disabled to protect DMA programming and the shared `sp_sav` variable.

Simple ISRs (flag-set only, stubs) use `__interrupt` which is safe since
their bodies are empty or trivial.

## Next steps

- Phase 1b: CRT display refresh ISR (DMA programming for 8275)
- Phase 1c: Keyboard input (PIO ISR + ring buffer)
- Phase 1d: Console output (CONOUT with escape sequences)
- Phase 1e: Floppy disk driver (blocking/deblocking)
- Phase 1f: Boot sequence (load CCP+BDOS, signon message)
