# z88dk Compiler Evaluation for ROA375 Boot ROM

## Background

The ROA375 autoload PROM is a 2048-byte Z80 boot ROM for the RC702
computer.  A byte-exact assembly reconstruction (`roa375/roa375.asm`)
already existed; the question was whether the boot logic could be
rewritten in C for maintainability and testability while still fitting
in the 2 KB PROM.

## Compiler investigation

Five Z80 C compiler options were evaluated:

| Compiler           | Code density vs asm | Verdict                              |
|--------------------|---------------------|--------------------------------------|
| z88dk + zsdcc      | 5-15% overhead      | Best fit — recommended               |
| z88dk + sccz80     | 20-40% overhead     | Feasible but looser code             |
| SDCC standalone    | 10-30% overhead     | Lacks z88dk peephole rules, known bugs |
| Hi-Tech C for Z80  | Good                | Requires DOS emulation, no host tests |
| PL/M-80            | Excellent           | Dead toolchain, 8080 only, no RETN/DJNZ |

Z80 Forth and LLVM-based languages (Rust, Zig via Z80Babel) were also
considered and rejected — Forth's kernel alone consumes 1-2 KB, and
LLVM Z80 backends are experimental with poor code density.

## Why z88dk with zsdcc was chosen

z88dk with the zsdcc (patched SDCC) backend was selected for these
reasons:

1. **Estimated 5-15% code size overhead** vs hand-written assembly.
   The original ROM payload is 1944 bytes, so even 15% overhead (2136
   bytes) would leave room for the ~100-byte bootstrap stub, fitting
   within 2048 bytes.

2. **`__sfr __at` port declarations** generate direct `IN`/`OUT`
   instructions with no function call overhead — critical for a ROM
   that is mostly I/O register manipulation.

3. **`__interrupt` keyword** for Z80 IM2 interrupt handlers with
   automatic register save/restore and RETI.

4. **`__z88dk_fastcall`** passes a single argument in HL, avoiding
   stack frame setup for simple functions.

5. **`__z88dk_callee`** lets the callee clean the stack, saving `pop`
   instructions at every call site.

6. **Custom `crt0.asm`** support allows hand-written bootstrap code
   (self-relocation, NMI handler, interrupt vectors) while linking C
   code for the main logic.

7. **Host-native compilation** of the same C source (with a mock HAL)
   enables unit testing without a Z80 emulator.

8. **z88dk's peephole optimizer** applies Z80-specific optimizations
   that stock SDCC misses, claiming 5-40% size reduction over vanilla
   SDCC output.

## What actually happened

The 5-15% overhead estimate proved optimistic for the initial approach.
Here is the full size progression:

| Stage                              | CODE.bin | vs target | Notes                    |
|------------------------------------|----------|-----------|--------------------------|
| Original assembly ROM payload      | 1944 B   | baseline  | What must fit in 2048    |
| Initial C compilation              | 4353 B   | +124%     | Default zsdcc flags      |
| `--opt-code-size` + allocs tuning  | 3053 B   | +57%      | Compiler flags only      |
| + `__z88dk_fastcall/callee`, no switch | 2421 B | +25%   | Calling convention work  |
| + Init routines moved to asm       | 2249 B   | +16%      | PIO/CTC/DMA/CRT in asm  |
| All C functions moved to asm       | 2042 B   | +5%       | Interim all-assembly     |
| Hand-optimized assembly            | 1937 B   | -0.4%     | Fits in 2048 with 6 spare |
| **sdcc + sdcccall(1), mostly C**   | **~1880 B** | **-3%** | **Final: 1984 B total** |

The initial pure C version was **2.2x the target size**.  However, the
initial approach used suboptimal compiler flags and the wrong backend.
After discovering that sdcc with `--sdcccall 1` produces 36% smaller code
than sccz80, and adding custom peephole rules, almost all code was moved
**back from assembly to C**.  The final ROM is **1984 bytes** — 64 bytes
under the 2048-byte limit — and boots successfully in the rc700 emulator.

## Compiler overhead analysis

The initial builds revealed significant overhead from the compiler, but
most of it was addressable through configuration and coding style changes.

### Sources of overhead (and mitigations)

| Source | Initial cost | Mitigation | Status |
|--------|-------------|------------|--------|
| IX frame pointer | 5+ B/function | `--fomit-frame-pointer` | Eliminated |
| Stack parameter passing | 3-7 B/call | `sdcccall(1)`: params in A/HL/DE | Eliminated |
| sccz80 byte→word promotion | 2+ B/access | Switch to sdcc backend | Eliminated |
| Redundant register loads | 2 B/occurrence | Custom peephole rules | Eliminated |
| No LDIR/CPI generation | 4-8 B/block op | Hand-written in crt0.asm | Mitigated |
| ISR register save overhead | ~10 B/ISR | Manual wrappers in crt0.asm | Mitigated |
| JP vs JR for short branches | 1 B/branch | z88dk peephole rules (-SO3) | Partially |
| No cross-function register alloc | varies | Unity build helps somewhat | Accepted |

The key insight was that **the initial overhead was not inherent to C
compilation** — it was largely caused by using the wrong backend (sccz80
instead of sdcc) with wrong flags (missing `--sdcccall 1` and
`--fomit-frame-pointer`).  With correct configuration, sdcc produces
code dense enough for a 2KB ROM.

### What remains in assembly

Only a few constructs genuinely require hand-written assembly:

- **Entry stub**: DI, SP setup, LDIR relocation (18 bytes)
- **ISR wrappers**: Manual PUSH/POP + SP switch + EI+RETI (because
  `__interrupt` enables interrupts too early for safe DMA reprogramming)
- **`jp (hl)`**: No C equivalent for indirect one-way jump
- **Interrupt vector table**: 32-byte table of 16-bit pointers

These total ~267 lines of crt0.asm — the structural skeleton of the ROM.
All boot logic, FDC driver, peripheral initialization, format tables,
and interrupt handler bodies are compiled C.

## Conclusion

z88dk with the sdcc backend and `sdcccall(1)` can produce a working
2KB Z80 boot ROM in C.  The final ROM is **1984 bytes** (64 bytes under
the 2048-byte limit) and boots successfully.

The initial 5-15% overhead estimate was wrong for the initial compiler
configuration, but the project proved that iterating on backend selection,
calling conventions, and peephole rules can close the gap.  The critical
flags are:

```
-clib=sdcc_iy --opt-code-size -SO3
-Cs"--sdcccall 1" -Cs"--fomit-frame-pointer"
-custom-copt-rules=peephole.def
```

The HAL/mock architecture enables host-native testing of the same C
source that compiles into the ROM — no separate reference implementation
is needed.

### Lessons learned

1. **Backend and calling convention selection matter more than any other
   optimization.**  sdcc with `sdcccall(1)` produces 36% smaller code
   than sccz80 for this workload.  This single change made the difference
   between "impossible" and "64 bytes to spare".

2. **`-SO3` and `-O3` are different flags for different compilers.**
   Mixing them up causes silent misconfiguration.  `-SO3` is for sdcc;
   `-O3` is for sccz80.

3. **Custom peephole rules are essential** for I/O-heavy code.
   The compiler naively reloads registers between consecutive port writes
   with the same value; project-specific rules fix this at no risk.

4. **2KB is achievable for C on Z80** with the right compiler
   configuration.  The earlier conclusion that "ROMs under 4KB require
   hand-written assembly" was proven wrong.

5. **The HAL/mock architecture works.** Designing with a hardware
   abstraction layer enables host testing and makes the code readable
   and maintainable — which was the whole point of the C rewrite.
