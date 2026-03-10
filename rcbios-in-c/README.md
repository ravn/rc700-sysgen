# RC702 CP/M BIOS in C (REL30)

Rewrite of the REL30 BIOS in C using z88dk with sdcc backend, following the
same approach as `autoload-in-c/` (ROA375 PROM rewrite).

See `rcbios/BIOS_IN_C_PLAN.md` for the full implementation plan.

## Status

**Phase 1k: ISR refactoring** — CP/M boots to A> on MAXI 8". All floppy BIOS features working.

- Phase 1a (skeleton): correct binary layout, JP table at DA00, IVT at DB00
- Phase 1b (CRT ISR): DMA refresh, RTC, timers. Keyboard 16-byte ring buffer
- Phase 1d (CONOUT): full display driver with escape sequences
- Phase 1e (floppy): blocking/deblocking, multi-density T0, DMA programming
- Phase 1f (boot): cold boot, warm boot, signon message
- Phase 1g (SIO): serial ring buffer, RTS flow control, READER/PUNCH/LIST
- Phase 1h (BSS): separate code/data from uninitialized variables (BSS not on disk)
- Phase 1i (extended): WFITR, READS, LINSEL, EXIT, CLOCK entries
- Phase 1j (BGSTAR): foreground/background character bitmap (250 bytes at 0xF500)
- Phase 1k (ISR refactor): inline naked helpers for ISR stack switch
- Current size: 6872 bytes (fits maxi 9984, over mini 6144 by 728 bytes)

### Missing features

- **Hard disk support** (WD1000 controller): HRDFMT stub and HD ISR stub present.
  Postponed until the BIOS fits comfortably on the mini (5.25") disk (need to
  shrink by ~728 bytes first).

## Building

Requires z88dk installed at `../z88dk/`.

```bash
make bios    # build bios.cim
make size    # check fit against mini/maxi limits
make clean   # remove build artifacts
```

## Architecture

- **crt0.asm**: Binary layout, JP table, IVT, CONFI config block
- **bios.c**: All BIOS entry points, ISRs, and disk data tables in C
- **bios.h**: Constants, memory layout, `WorkArea`/`JTVars`/`DPB`/`FSPA`/`FDF` structs, `byte`/`word` typedefs
- **hal.h**: Hardware abstraction (`__sfr __at` port I/O, `hal_di`/`hal_ei`/`hal_halt` macros)
- **danish.bin**: Character conversion tables (384 bytes, extracted from assembled BIOS)
- **peephole.def**: SDCC peephole optimizer rules
- **bgstar_test.asm**: BGSTAR foreground/background test (draw, insert/delete line, clear FG)
- **mame_bgstar_test.lua**: Automated MAME test for bgstar_test.asm (verifies screen contents)
- **gdb_bgstar.py**: GDB RSP debug client for tracing bg_set_bit and specc breakpoints
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

ISRs use `__naked` wrappers with asm prologue (SP switch, PUSH AF/BC/DE/HL),
C body code directly in the wrapper, and asm epilogue (POP, EI, RETI).
IX/IY are not pushed since no ISR body uses them (verified via listing).
This is necessary because sdcc's `__interrupt` puts EI at the *start* of the
function, enabling nested interrupts.  The CRT ISR must run with interrupts
disabled to protect DMA programming and the shared `sp_sav` variable.
Using `static inline` body functions causes sdcc to emit dead standalone
copies that z88dk's linker cannot strip, so the body code is placed directly
in the `__naked` function between `__asm` blocks instead.

Simple ISRs (flag-set only, stubs) use `__interrupt` which is safe since
their bodies are empty or trivial.

### Code/BSS separation

The binary on disk contains only code and initialized data. Uninitialized variables
(buffers, driver state) are in a BSS section at 0xEF00, not written to the floppy
image. The cold boot code zeroes BSS using `__bss_compiler_head`/`__bss_compiler_size`
linker symbols. Section ordering is declared explicitly in crt0.asm to ensure all
code/data sections precede BSS. The `code_string` section (containing `memset`) must
be declared before BSS to avoid linker placement errors.

### Disk data tables

Translation tables (`tran0`–`tran24`), Disk Parameter Blocks (`dpb0`–`dpb24`),
Floppy Disk Format descriptors (`fdf[4]`), Floppy System Parameters (`fspa[4]`),
and track offsets (`trkoff[]`) are defined as typed C arrays/structs in bios.c.
The `form` pointer (`const FDF *`) provides struct-based access to FDF fields
(`form->dma_count`, `&form->mf`), replacing raw byte offset arithmetic.

## Testing

`run_mame.sh -t` runs the automated test: assembles FILEX.ASM with CP/M's
ASM.COM, then verifies the output via STAT and TYPE. This exercises the full
BIOS file I/O path (sequential read, sequential write, directory operations).

```
ASM FILEX        → 910-line source, 009H USE FACTOR, 0 errors
STAT FILEX.PRN   → 266 records, 34K
TYPE FILEX.PRN   → listing ends at 0x0932 with END START
```

Reference addresses are saved to `filex_ref.txt`.

`make bgstar-test` runs the BGSTAR foreground/background test: assembles bgstar_test.asm,
injects BGTEST.COM into a disk image, boots in MAME with mame_bgstar_test.lua,
and verifies that background drawing, insert/delete line, and clear foreground
all produce correct screen output.

### Writing test programs

Test programs can be written in C using z88dk (same toolchain as the BIOS) or
in Z80 assembly using zmac. Compiled programs are injected into disk images
using `cpmcp -f rc702-8dd` and run under CP/M in MAME.

### GDB RSP debugging

MAME's gdbstub provides source-level debugging via the GDB Remote Serial
Protocol. Launch MAME with `-debugger gdbstub -debugger_port 23946`, then
connect with `gdb_bgstar.py` (or any GDB RSP client). This supports breakpoints,
single-step, register/memory read/write — useful for tracing BIOS internals
without modifying the binary.

### MAME disk format

MAME cannot write back to IMD disk images (`supports_save()` returns false).
All MAME launch modes convert IMD→MFI (MAME Floppy Image) for writable disks.
Disk changes persist between interactive MAME sessions. Use `-f` to force a
fresh image from the IMD source.

### CP/M source reference

- **PL/M and ASM sources**: `~/Downloads/cpm2-plm/`
- **Build instructions**: https://www.jbox.dk/rc702/cpm.shtm

## Compiler optimization

All compiler tuning options are documented in `SDCCCALL.md`. Summary:

- **No recursion** → all locals are `static` → no IX/IY frame pointer usage
- **Makefile build guard** fails if `ix[+-]` or `iy[+-]` appear in listing
- **Makefile build guard** fails if sdcccall(0) library functions are linked
- **FDC wait loops non-inline** (callable) — compactness over speed for wait loops
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

- **ISR prologues/epilogues** (10): SP switch to ISTACK, PUSH AF/BC/DE/HL, POP, EI+RETI
- **BIOS stack-switch entries** (7): SP switch to 0xF500 before calling C body
- **CP/M ABI glue** (4): `settrk`/`setsec`/`setdma` store BC, `sectran` BC→HL
- **DI/EI/HALT**: `hal_di()`, `hal_ei()`, `hal_halt()` macros in hal.h
- **CCP jump**: load CDISK, jump to CCP at warm boot

See `ASM_BLOCKS.md` for full analysis.

## Next steps

- MINI (5.25") support (currently 640 bytes over mini limit, needs size reduction)
