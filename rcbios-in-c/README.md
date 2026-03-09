# RC702 CP/M BIOS in C (REL30)

Rewrite of the REL30 BIOS in C using z88dk with sdcc backend, following the
same approach as `autoload-in-c/` (ROA375 PROM rewrite).

See `rcbios/BIOS_IN_C_PLAN.md` for the full implementation plan.

## Status

**Phase 1f: Boot sequence** — CP/M boots to A> on MAXI 8". DIR and TYPE work.

- Phase 1a (skeleton): correct binary layout, JP table at DA00, IVT at DB00
- Phase 1b (CRT ISR): DMA refresh, RTC, timers. Keyboard 16-byte ring buffer
- Phase 1d (CONOUT): full display driver with escape sequences
- Phase 1e (floppy): blocking/deblocking, multi-density T0, DMA programming
- Phase 1f (boot): cold boot, warm boot, signon message
- Current size: ~7137 bytes (fits maxi 9984, over mini 6144 by ~993)

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

## Testing

Two CCP built-in commands exercise the BIOS file I/O path:

- **`DIR *.ASM`** — traverses directory sectors, returns 2 files on SW1711 (`direct:` at line 539 in OS2CCP.ASM)
- **`TYPE DUMP.ASM`** — opens file and reads data sectors (`type:` at line 625 in OS2CCP.ASM)

Use `run_mame.sh -t` to run both commands automatically and dump the screen.

### CP/M source reference

- **PL/M and ASM sources**: `~/Downloads/cpm2-plm/`
- **Build instructions**: https://www.jbox.dk/rc702/cpm.shtm

## Stack requirements

The C BIOS uses significantly more stack than the original assembly BIOS
(~80 bytes vs ~16 bytes at peak). No recursion exists in the codebase, so
all local variables could theoretically be made static. See `STACK_ANALYSIS.md`.

The warm boot stack must be outside the CCP+BDOS area (0xC400-0xD9FF) being
loaded. Both `bios_boot` and `bios_wboot` use SP=0xF500 (the BIOS private
stack, 5KB above BSS). See `STACK_BUG_ANALYSIS.md` for the original bug.

## Next steps

- SIO serial ring buffer with RTS flow control
- MINI (5.25") support (currently over limit by ~993 bytes)
- Tables (CLOCK, SETWARM, LINSEL)
