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
- Current size: 7321 bytes (fits maxi 9984, over mini 6144 by ~1177)

## Building

Requires z88dk installed at `../z88dk/`.

```bash
make bios    # build bios.cim
make size    # check fit against mini/maxi limits
make clean   # remove build artifacts
```

## Architecture

- **crt0.asm**: Binary layout, JP table, IVT, disk tables, CONFI config block
- **bios.c**: All BIOS entry points and ISRs in C (uses `byte` typedef for `uint8_t`)
- **bios.h**: Constants, memory layout, `WorkArea` and `JTVars` structs
- **hal.h**: Hardware abstraction (`__sfr __at` port I/O for Z80)
- **danish.bin**: Character conversion tables (384 bytes, extracted from assembled BIOS)
- **peephole.def**: SDCC peephole optimizer rules
- **conout_test.asm**: CONOUT control code exerciser (insert/delete line, scroll, erase)
- **SDCCCALL.md**: Calling conventions, register allocation, inlining guide
- **ASM_BLOCKS.md**: Analysis of all inline asm blocks and C convertibility
- **STACK_ANALYSIS.md**: Call graph, no-recursion proof, stack depth
- **STACK_BUG_ANALYSIS.md**: Warm boot stack corruption bug and fix
- **test_sdcccall.c**: Experimental verification of sdcccall(1) register usage

### Memory-mapped variables

Fixed-address hardware variables are defined as C structs with pointer casts:

- **`WorkArea`** at 0xFFD0: cursor state, timers, ISR variables (cleared at boot)
- **`JTVars`** at 0xDA33: CONFI configuration, drive format table (in binary)

Accessed via macros (`curx`, `cury`, `timer1`, `fd0[n]`, etc.) that expand to
`W.field` or `JT.field` where `W`/`JT` are volatile struct pointers. This
generates efficient direct-address code and saved 33 bytes vs individual `__at()`.

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

## Compiler optimization

All compiler tuning options are documented in `SDCCCALL.md`. Summary:

- **No recursion** → all locals are `static` → no IX/IY frame pointer usage
- **Makefile build guard** fails if `ix[+-]` or `iy[+-]` appear in listing
- **Makefile build guard** fails if sdcccall(0) library functions are linked
- **FDC wait loops inlined** (`static inline`) for 27 T-states/call saving
- **`--max-allocs-per-node 1000000`** for aggressive register allocation
- **`--std-sdcc99`** enables `inline` keyword
- sdcc has no automatic inlining — `inline` keyword is the only mechanism

## Stack requirements

The C BIOS uses significantly more stack than the original assembly BIOS
(~80 bytes vs ~16 bytes at peak). No recursion exists in the codebase, so
all local variables are declared `static`. See `STACK_ANALYSIS.md`.

The warm boot stack must be outside the CCP+BDOS area (0xC400-0xD9FF) being
loaded. Both `bios_boot` and `bios_wboot` use SP=0xF500 (the BIOS private
stack, 5KB above BSS). See `STACK_BUG_ANALYSIS.md` for the original bug.

## Remaining inline assembly

All block memory operations (scroll, clear, insert/delete line) are now pure C
using `memcpy`/`memset`/loops. The remaining asm blocks are:

- **ISR wrappers** (3): stack switch to ISTACK, save all regs, EI+RETI
- **BIOS stack-switch entries** (7): SP switch to 0xF500 before calling C body
- **CP/M ABI glue** (4): `settrk`/`setsec`/`setdma` store BC, `sectran` BC→HL
- **DI/EI/HALT intrinsics**: interrupt control, wait-for-interrupt
- **CCP jump**: load CDISK, jump to CCP at warm boot

See `ASM_BLOCKS.md` for full analysis.

## Next steps

- SIO serial ring buffer with RTS flow control
- MINI (5.25") support (currently over limit by ~1177 bytes)
- Tables (CLOCK, SETWARM, LINSEL)
- Replace `__asm__("di")`/`__asm__("ei")`/`__asm__("halt")` with z88dk intrinsics
