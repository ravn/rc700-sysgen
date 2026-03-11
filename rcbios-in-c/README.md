# RC702 CP/M BIOS in C (REL30)

Rewrite of the REL30 BIOS in C using z88dk with sdcc backend, following the
same approach as `autoload-in-c/` (ROA375 PROM rewrite).

See `rcbios/BIOS_IN_C_PLAN.md` for the full implementation plan.

2026-03-10:  BIOS is now feature-complete (except for harddisk support) and boots CP/M to A> on the MAXI 8" disk image. Remaining work is refactoring and size reduction to fit the MINI 5.25" image.  Also making hot paths as fast as possible and move as many pointer operations to standard C idioms working on table structures etc, and then add peep hole optimization to make the generated code sharper.

2026-03-11:  Major refactoring session.  Converted all inline asm to `__asm__()` form.
Converted 6 SIO ISRs from `__naked` to `__critical __interrupt(N)` (pure C).
Discovered and documented RETN vs EI+RETI bug (`__interrupt(N)` number is mandatory).
Refactored display memory as typed 2D array (`Display[25][80]`) with all dimensions
derived from `sizeof`.  Added 7 dead-code elimination peephole rules saving 69 bytes
(discovered gap in sdcc/z88dk: neither eliminates unreachable asm after unconditional
jumps).  Fixed copt comment parsing issue (`;` lines corrupt rule boundaries).
Size: 6762 → 6702 bytes.

2026-03-11:  Binary size analysis and optimization.  Removed danish.bin character
conversion tables (384 bytes) — PROM loads tables from disk already, BIOS only needs
placeholder space.  Cold boot generates identity mapping tables instead.  Rewrote
`specc()` control character dispatch from switch to if/return chain for frequency-based
ordering (CR/LF first) — sdcc sorts switch cases by value, if/return preserves source
order.  Added 4 conditional jump inversion peephole rules (`jr NZ/jp` → `jp Z`) saving
34 bytes across 17 call sites.  Extracted `start_xy()` for tail-call optimization.
Size: 6702 → 6692 bytes.

2026-03-11:  Code pattern optimization session.  Key changes:
- Merged `secrd()`/`secwr()` into `sec_rw(cmd, dma_dir)` — eliminated 91 bytes of
  duplicated retry/recalibrate logic (the largest single saving).
- Replaced explicit shift loops (`while (n--) mask >>= 1`) with direct expressions
  (`0x80 >> n`, `0xFF >> n`, `0xFF << n`) — sdcc generates tight inline shift loops
  instead of round-tripping through static variables each iteration. Saved 79 bytes
  across `bg_set_bit`, `bg_clear_from`, and `rwoper`.
- Eliminated load-modify-store through temp variables (`val = *ptr; val &= ~mask;
  *ptr = val` → `bgstar[byteoff] &= ~mask`) — compound assignment generates direct
  read-modify-write. Saved 31 bytes in `bg_clear_from`.
- Removed dead `gfpa()` function (24 bytes), inlined `trkcmp()` (10 bytes).
- Computed SELDSK format index once instead of twice (5 bytes).
- Changed `clear_foreground` loop counter from `word` to `byte` (9 bytes).
- Added peephole rules for redundant `xor a,a` after `ld (var),a` (3 bytes).
- Also: extracted `jump_ccp()` as `__naked` function, reordered `goto00`/`start_xy`,
  made Makefile z88dk/zmac paths portable, added `lis.sh` listing navigation tool.
Size: 6692 → 6439 bytes (253 bytes saved, 36% of gap to mini closed).


## Status

**Phase 1l: Code generation optimization** — CP/M boots to A> on MAXI 8". All floppy BIOS features working.

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
- Phase 1l (codegen): OTIR for SIO init, memcpy/memset for block ops, pointer→array,
  direct shifts, compound assignments, function merging
- Current size: 6439 bytes (fits maxi 9984, over mini 6144 by 295 bytes)

### Missing features

- **Hard disk support** (WD1000 controller): HRDFMT stub and HD ISR stub present.
  Not a priority — target machine is maxi (8") without drives, using CP/NET.

### Inline assembly syntax

All inline assembly uses the `__asm__("string")` form (sdcc 3.2.0+) instead of the
older `__asm/__endasm` block form. This allows the host C compiler (clang/gcc) to
parse `__naked` functions when `#define __asm__(x)` stubs out the asm content.
Most `#ifndef HOST_TEST` guards around `__naked` functions have been removed.

Build with `cc -DHOST_TEST -Wall -Wextra -fsyntax-only bios.c` to check for
C-level errors. Remaining host warnings are expected (pointer/int cast size
differences on 64-bit, unused functions in `#ifndef HOST_TEST` blocks).

### Remaining inline assembly

24 `__asm__()` blocks remain in bios.c. Categorized by whether they can move to C:

**Must stay in asm** (ABI / hardware constraints):
- ISR stack switch helpers (`isr_enter`/`isr_exit`, 4 blocks) — SP manipulation, EI+RETI
- `bios_boot` / `bios_wboot` (2) — set SP then JP, no return
- `bios_settrk` / `bios_setsec` / `bios_setdma` (3) — CP/M passes value in BC, single `ld (var),bc` + ret
- `bios_sectran` (1) — return BC in HL, single instruction + ret
- `bios_wfitr` tail (1) — load rstab[0]→B, rstab[1]→C for CP/M ABI
- `bios_linsel` entry (1) — store A→ls_port, B→ls_line (ABI bridge)
- SIO init (1) — OTIR to ports 0x0A/0x0B (no C equivalent for OTIR)

**Could move to C** (best candidates first):
- **5 stack-switch wrappers** (`bios_conout`, `bios_home`, `bios_seldsk`, `bios_read`,
  `bios_write`) — all do the same DI/save-SP/switch-to-BIOS-stack/EI/call-C-body/
  restore-SP pattern (~15 lines each). A shared inline helper would eliminate
  duplication. The C body functions already exist.
- **`bios_exit`** (1 block) — stores HL→warmjp, DE→timer1. Two assignments, but
  needs `__naked` to receive HL/DE from CP/M ABI.
- **`bios_clock`** (1 block) — reads/sets rtc0+rtc2 with DI/EI. Return convention
  (DE+HL) makes pure C awkward.
- **`bios_linsel` returns** (3 blocks) — `xor a; ret` / `ld a,#0xFF; ret`. Could be
  `return 0`/`return 0xFF` if the function weren't `__naked`.
- **`wboot_c` tail** (1 block) — load cdisk, mask, JP to CCP. Non-returning jump.

### Pointer-to-C-idiom cleanup candidates

Analysis of remaining raw pointer patterns that could use cleaner C constructs:

**Priority 1 — CTC config** (`bios_hw_init`, lines 585-590):
`*((&mode0) + 2)` etc. — taking address of scalar then offsetting. The 8 CTC bytes
are contiguous in crt0.asm. Declaring as `extern byte ctc_config[8]` allows
`ctc_config[2]` indexing.

**Priority 2 — DPH struct** (`bios_hw_init` lines 663-672, `bios_seldsk` lines 1434-1438):
`dpbase[d * 8]` with magic offsets 0-7 could be a proper CP/M DPH struct:
```c
typedef struct { word xlt, scratch[3], dirbf, dpb, chk, alv; } DPH;
```
Eliminates magic numbers; compile-time layout checking.

**Priority 3 — INCONV lookup** (`conin_translate`, line 817):
`*((volatile byte *)(INCONV_ADDR + raw))` → define `INCONV` as array macro,
use `INCONV[raw]`.

**Priority 4 — Static variable groups** (multiple functions):
Functions like `bg_clear_from`, `insert_line`, `delete_line` have 5-9 scattered
`static` variables. Packing into structs enables HL-relative addressing (sdcc
generates shorter code for struct member access than individual absolute loads).

**Priority 5 — warmjp callback** (`isr_crt`, line 1917):
`((void (*)(void))warmjp)()` → macro `CALL_WARMJP()` for readability.

**Already idiomatic** (no changes needed): display buffer overlays (`screen`,
`DISPLAY_ROW`, `bgstar` macros), WorkArea struct at 0xFFD0, SIO init loops with
`sizeof`, ring buffer arithmetic, backward copy loops.

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
- **~~danish.bin~~**: Removed — tables live on disk image, BIOS uses placeholder space
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

sdcc provides three ways to write interrupt service routines:

**`__interrupt`** — puts `EI` at the *start* of the function (before the
push/pop prologue), enabling nested interrupts immediately.  The epilogue
ends with `RETI`.  **Never use this on the RC702** — the hardware requires
interrupts to be disabled throughout all interrupt handlers.

**`__critical __interrupt`** — keeps interrupts disabled throughout.  The
prologue pushes AF, BC, DE, HL, IY; the epilogue pops them, then does
`EI; RETI`.  This is the correct pattern for non-nesting ISRs.  The
function body is pure C — no inline assembly needed.

**`__naked`** — no compiler-generated prologue or epilogue at all.  The
programmer writes everything in inline asm.  Required when the ISR must
switch to a private stack (`sp_sav`/ISTACK) or when the compiler's
register save set (5 pairs) is too heavy.

**The `(N)` in `__interrupt(N)` is mandatory.**  Without it, `__critical
__interrupt` generates `RETN` instead of `EI; RETI`.  `RETN` leaves
interrupts permanently disabled — a fatal error on the RC702 where all
I/O (keyboard, floppy, serial) is interrupt-driven.  The number N is an
sdcc-internal slot that prevents duplicate declarations; it does NOT
generate or affect the interrupt vector table (sdcc has no IVT generation
for Z80).  Our vector table is defined manually in crt0.asm (`itrtab`
at 0xDB00).  Every `__interrupt` in this project must use `(N)`.

#### Which ISRs use which form

| ISR | Form | Why |
|-----|------|-----|
| `isr_crt` | `__naked` | Stack switch + DMA programming, must protect `sp_sav` |
| `isr_pio_kbd` | `__naked` | Stack switch, ring buffer with local variables |
| `isr_floppy` | `__naked` | Stack switch, calls `fdc_result()`/`fdc_sense_int()` |
| `isr_sio_a_rx` | `__naked` | Stack switch, ring buffer + RTS flow control |
| `isr_sio_b_tx` | `__critical __interrupt` | Trivial body (port write + flag) |
| `isr_sio_b_ext` | `__critical __interrupt` | Trivial body (port read + store) |
| `isr_sio_b_spec` | `__critical __interrupt` | Trivial body (error read + reset) |
| `isr_sio_a_tx` | `__critical __interrupt` | Trivial body (port write + flag) |
| `isr_sio_a_ext` | `__critical __interrupt` | Trivial body (port read + store) |
| `isr_sio_a_spec` | `__critical __interrupt` | Trivial body (error reset + flush) |
| `isr_hd` | `__interrupt` | Empty stub (hard disk not implemented) |
| `isr_pio_par` | `__interrupt` | Empty stub (parallel port not used) |

The 6 `__critical __interrupt` ISRs were originally `__naked` with a
stack switch to ISTACK (0xF620).  The stack switch was removed because
their bodies are trivial — the compiler pushes 5 register pairs (10 bytes)
which fits safely on any interrupted code's stack.  If a body becomes
non-trivial, it must revert to `__naked` with `isr_enter`/`isr_exit`.

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

All compiler tuning options are documented in `SDCCCALL.md` and `OPTIMIZATION_PLAN.md`.
Summary:

- **No recursion** → all locals are `static` → no IX/IY frame pointer usage
- **Makefile build guard** fails if `ix[+-]` or `iy[+-]` appear in listing
- **Makefile build guard** fails if sdcccall(0) library functions are linked
- **Makefile build guard** verifies position-sensitive symbols at expected addresses
- **FDC wait loops non-inline** (callable) — compactness over speed for wait loops
- **`--max-allocs-per-node 1000000`** for aggressive register allocation
- **`--std-sdcc99`** enables `inline` keyword
- sdcc has no automatic inlining — `inline` keyword is the only mechanism
- **Block instructions**: `memcpy`→LDIR (inlined), `memset`→LDIR, OTIR via inline asm
- **Z80 block ops used**: SIO init via OTIR, 128-byte deblocking via LDIR (memcpy)
- See `OPTIMIZATION_PLAN.md` for sdcc internals analysis and future optimization paths

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
- **SIO init** (1): OTIR to ports 0x0A/0x0B (no C equivalent for OTIR)
- **DI/EI/HALT**: `hal_di()`, `hal_ei()`, `hal_halt()` macros in hal.h
- **CCP jump**: load CDISK, jump to CCP at warm boot

See `ASM_BLOCKS.md` for full analysis.

## Binary layout (6692 bytes)

The .cim binary spans 0xD480–0xEEA3.  The INIT section (D480–DA00) is
overwritten by CCP after cold boot; only the resident portion (DA00+)
must fit the system track.

```
Address range  Size   Section
-------------  -----  ------------------------------------------
D480h–D500h      128  Boot entry point + padding
D500h–D580h      128  CONFI config block (SIO, CTC, CRT, FDC params)
D580h–D700h      384  Character conversion tables (placeholder zeros)
D700h–DA00h      768  Cold boot code (relocate, BSS clear, hw init call)
DA00h–DA33h       51  BIOS JP table (17 entries, fixed address)
DA33h–DA4Ah       23  JTVARS (CONFI configuration variables)
DA4Ah–DA70h       38  Extended JP table entries (INTJP0-10)
DA70h–DB00h      144  Saved register area + padding to IVT alignment
DB00h–DB26h       38  Interrupt vector table (itrtab, 256-byte aligned)
DB26h–ED42h     4636  C code (functions, ISRs)
ED42h–EE72h      304  Read-only data (DPBs, translation tables, FDF, FSPA)
EE72h–EE84h       18  Initialized data (trkoff, flags)
EE84h–EEA4h       32  Library code (l_ret + memset)
```

BSS (uninitialized variables) is at EF60h–F462h (1282 bytes) and is
NOT included in the binary — it is zeroed by cold boot code.

### Top 10 largest C functions

| # | Function | Bytes | Purpose |
|---|----------|------:|---------|
| 1 | `bios_hw_init` | 412 | Hardware init (INIT section, overwritten by CCP) |
| 2 | `bg_clear_from` | 274 | BGSTAR bitmap clear (semi-graphics) |
| 3 | `bios_seldsk_c` | 229 | Disk select + format table lookup |
| 4 | `rwoper` | 223 | Blocking/deblocking state machine |
| 5 | `insert_line` | 216 | Screen insert line + BGSTAR shift |
| 6 | `xwrite` | 168 | Disk write + pre-read logic |
| 7 | `isr_crt` | 150 | CRT refresh ISR (DMA, timers, keyboard scan) |
| 8 | `delete_line` | 137 | Screen delete line + BGSTAR shift |
| 9 | `chktrk` | 130 | Multi-density track 0 format switching |
| 10 | `specc` | 125 | Control character dispatch (if/return chain) |

### Space by category

| Category | Bytes | % |
|----------|------:|--:|
| crt0.asm fixed structures | 1702 | 25.4 |
| C code (functions + ISRs) | 4636 | 69.2 |
| Read-only data tables | 304 | 4.5 |
| Initialized data + library | 50 | 0.8 |
| **Total** | **6692** | |

### MINI fit analysis (need to cut 548 bytes)

| Optimization | Saving | Notes |
|--------------|-------:|-------|
| Remove BGSTAR code | 419+ | Plus tails in insert/delete line, displ |
| Shared stack-switch trampoline | ~50 | 5 wrappers → 1 trampoline |
| Additional peephole rules | ~20 | Further pattern matching opportunities |
| Micro-optimizations | ~60+ | Tail calls, shared code paths |
| **Total estimated** | **~549+** | Tight but achievable |

### specc control character dispatch

sdcc **sorts switch cases by value**, ignoring source order.  Using
`if (x == N) { handler(); return; }` chains instead preserves the
source ordering and generates `cp a,N / jr NZ / jp handler` with A
reused across comparisons (no reload).  This costs only 4 bytes more
than a switch (the `0x05`/`0x08` cursor_left case can't fall through)
but puts CR and LF first — the most frequent control codes get a
2-comparison fast path.

### Character conversion tables

The 384-byte danish.bin conversion tables are **not included** in the BIOS
binary.  The binary contains a placeholder (`defs 384`) at offset 0x100.
The actual tables live on the disk image (written by CONFI.COM) and are
loaded by the autoload PROM along with the rest of Track 0.  The cold
boot code generates identity tables (all characters map to themselves) as
a safe default.

## Next steps

- MINI (5.25") support (currently 548 bytes over mini limit, needs size reduction)
- Remove BGSTAR code (~419 bytes, largest single saving)
- Shared stack-switch trampoline (~50 bytes saving, see `OPTIMIZATION_PLAN.md`)
- Further peephole rules and micro-optimizations
