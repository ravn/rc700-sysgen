# Session 19: Compiler Fix #69 + Warm-Boot Memset (2026-04-12)

## Compiler Fix: ravn/llvm-z80#69

The comparison reversal peephole in `Z80LateOptimization.cpp` transforms:
```
LD r,A; LD A,#imm; CP r; JR C/NC  →  CP #(imm+1); JR NC/C
```
saving 2 bytes. But it erased `LD r,A` unconditionally, even when `r` was
live-out to a successor block (used for a second comparison in switch
statements).

**Root cause**: Found by tracing through `-print-after-all`:
- After register allocation: `$d = COPY $a` correctly saved discriminant
- After `PostRA Machine Sink`: still present
- After `Z80 Late Optimizations`: **gone** — erased by comparison reversal

**Fix**: Before erasing `LD r,A`, check `isLiveIn(SavedReg)` on all
successors. If live-out, emit a new `LD r,A` before the folded `CP #imm`.

**Result**: Original `switch` in `bios_reader_body` and `bios_reads_body`
now compiles correctly. Workaround (if-else with local variable) reverted.
BIOS: 5969 bytes (same as with workaround).

Commit: `178935c438f0` in ravn/llvm-z80.

## Warm-Boot Memset (branch: warmboot-memset)

Grouped 10 warm-boot-zeroed variables into `volatile WarmBootState wb` struct.
Warm boot now does `__builtin_memset(&wb, 0, sizeof(wb))` (one LDIR) instead
of 10 individual stores.

Variables moved into `wb`: kbhead, kbtail, kbstat, rxhead_a, rxtail_a,
rxhead_b, rxtail_b, hstact, hstwrt, erflag. `cdisk` stays at CP/M fixed
address 0x0004.

`#define` macros in `bios.h` keep all existing code unchanged. `extern volatile
WarmBootState wb` allows `bios_hw_init.c` to access the members.

Also renamed SIO-A ring buffer: `rxbuf`→`rxbuf_a`, `rxhead`→`rxhead_a`,
`rxtail`→`rxtail_a` for consistency with SIO-B naming.

Clang: 5969 → 5964 bytes (−5B). Both compilers build, both tests pass.

## Baud Rate Clock Documentation

Traced the 0.6144 MHz baud rate clock to its source on RC702tech.pdf page 89:
two cascaded 74LS393 divide the 19.6608 MHz memory clock by 32.
Documented in `RC702_HARDWARE_TECHNICAL_REFERENCE.md` (CTC section + new
"Serial Baud Rate Limits" subsection).

## Issues

- ravn/llvm-z80#69: Fixed (comparison reversal peephole)
- New todo: redundant `XOR A,A` across consecutive BSS stores (3B in bios_boot_c)
- New todo: collect all bugs for upstream jacobly0/llvm-z80 issue filing

## Problems Found

- **CLion ninja path**: ninja is bundled at
  `/Applications/CLion.app/Contents/bin/ninja/mac/aarch64/ninja`,
  not on PATH. Found via CMakeCache.txt `CMAKE_MAKE_PROGRAM`.
- **MAME persists ioport overrides**: baud rate experiment left `user_value=23`
  (76800) on rs232b. Had to force-reset in Lua script.
- **`replace_all` substring matching**: renaming `rxtail` also matched inside
  `rxtail_b`, creating `rxtail_a_b`. Required two-pass fix.
