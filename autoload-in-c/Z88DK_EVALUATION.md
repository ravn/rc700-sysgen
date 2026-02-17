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

The 5-15% overhead estimate proved optimistic for this workload.
Here is the size progression:

| Stage                              | CODE.bin | vs target | Notes                    |
|------------------------------------|----------|-----------|--------------------------|
| Original assembly ROM payload      | 1944 B   | baseline  | What must fit in 2048    |
| Initial C compilation              | 4353 B   | +124%     | Default zsdcc flags      |
| `--opt-code-size` + allocs tuning  | 3053 B   | +57%      | Compiler flags only      |
| + `__z88dk_fastcall/callee`, no switch | 2421 B | +25%   | Calling convention work  |
| + Init routines moved to asm       | 2249 B   | +16%      | PIO/CTC/DMA/CRT in asm  |
| All C functions moved to asm       | 2042 B   | +5%       | Only asm, no C files     |
| Hand-optimized assembly            | 1937 B   | -0.4%     | Fits in 2048 with 6 spare |

The pure C version was **2.2x the target size**.  Even after exhaustive
optimization of compiler flags, calling conventions, and code structure,
the best achievable C output was still 25% over budget (2421 bytes vs
1943 usable).  Fitting the ROM required moving every function to
hand-written Z80 assembly.

## Why the compiler couldn't match hand-written assembly

### 1. IX frame pointer overhead (5+ bytes per function)

zsdcc uses the IX register as a frame pointer.  Every function with
local variables or multiple parameters generates:

```z80
    call ___sdcc_enter_ix    ; 3 bytes (+ 11-byte runtime function)
    ...
    ld sp, ix                ; 2 bytes
    pop ix                   ; 2 bytes
    ret                      ; 1 byte
```

The `___sdcc_enter_ix` runtime function (11 bytes, shared) plus the
per-function prologue/epilogue adds at least 5 bytes per function.
With ~25 functions in the ROM, this alone accounts for ~125 bytes plus
the 11-byte runtime — roughly 7% of the budget consumed by function
preambles.

Hand-written assembly avoids IX entirely, using register pairs and
direct stack manipulation.

### 2. The ROM is almost entirely I/O register manipulation

The ROA375 boot ROM has very little algorithmic content.  It is
dominated by:

- Writing initialization sequences to hardware ports (PIO, CTC, DMA, CRT)
- Polling FDC status registers in tight loops
- Building 9-byte FDC command buffers and sending them byte-by-byte
- Copying small blocks with LDIR
- Comparing short byte sequences

For this workload, C's abstraction overhead (function calls, stack
frames, parameter passing) is pure cost with no compensating benefit.
The "5-15% overhead" estimate assumes a mix of algorithmic and I/O
code; a ROM that is 90% hardware register manipulation hits the worst
case.

### 3. No Z80-specific idiom generation

The compiler cannot generate several Z80 idioms that the hand-written
code uses extensively:

| Idiom              | Hand-written      | Compiler output         | Overhead |
|--------------------|-------------------|-------------------------|----------|
| Block copy         | `LDIR` (2 bytes)  | Loop with `LD A,(HL)` etc. | 4-8 B |
| Counted loop       | `DJNZ label` (2B) | `DEC; JR NZ` (3B)      | 1 B/loop |
| Direct port I/O    | `IN A,(n)` (2B)   | `__sfr` works well      | 0        |
| Compare-and-branch | `CP (HL)` (1B)    | `LD A,(HL); CP n` (3B) | 2 B      |
| Tail call          | `JP target` (3B)  | Full epilogue + RET (5-7B) | 2-4 B |
| Inline delay       | 12 bytes inline   | CALL + frame (17+ B)   | 5+ B    |

These add up across the ~25 functions and ~40 loops in the ROM.

### 4. Section and alignment overhead

The z88dk linker generates separate CODE and BSS sections.  The
interrupt vector table requires `ALIGN 256`, wasting up to 255 bytes
of padding.  In practice this consumed ~23 bytes, but the section
headers and linker metadata add further overhead that hand-written
assembly avoids by controlling layout directly.

### 5. Calling convention overhead for multi-parameter functions

Functions like `flo7(drive_head, cylinder)`, `readtk(command, retries)`,
and `stpdma(address, count, mode)` require stack-based parameter
passing.  Each call site pushes 2-3 words onto the stack; even with
`__z88dk_callee` the callee must pop them.  Hand-written assembly
keeps values in registers across related calls, avoiding the
push/pop overhead entirely.

### 6. No cross-function optimization

zsdcc compiles one function at a time.  It cannot:

- Inline small functions into callers
- Propagate constants across function boundaries
- Eliminate redundant port reads when the same status register is
  checked by caller and callee
- Share register allocations between caller and callee

A "unity build" (`#include` all .c files into one translation unit)
was tried but did not help — zsdcc still respects function boundaries.

## Conclusion

z88dk was the correct choice among available Z80 C compilers — no
other toolchain would have produced smaller output.  However, the
5-15% overhead estimate does not apply to hardware-register-heavy
bare-metal code with many small functions, tight loops, and Z80-
specific idioms.  For this class of workload the actual overhead
was 25-125%, depending on optimization effort.

The project architecture still proved valuable: the C source files
serve as the **host-testable reference implementation** (compiled with
`-DHOST_TEST` using the mock HAL), while the Z80 ROM is built entirely
from `crt0.asm`.  This gives both the readability/testability benefits
of C and the density of hand-written assembly, at the cost of
maintaining two implementations that must be kept in sync.

### Lessons learned

1. **"5-15% overhead" is a best-case figure** for mixed algorithmic/IO
   code.  Pure I/O manipulation code should budget 30-50% overhead
   minimum.

2. **Frame pointer elimination** is the single biggest win — if zsdcc
   could avoid IX frames for leaf functions, the overhead would drop
   significantly.

3. **For ROMs under 4 KB**, hand-written assembly remains the pragmatic
   choice if size is a hard constraint.  C becomes viable at 8 KB+
   where the fixed overhead is proportionally smaller.

4. **The HAL/mock architecture works regardless** of whether the final
   target code is C or assembly.  Designing the C version first and
   then translating to assembly was faster than writing the assembly
   from scratch, because the C version served as an unambiguous
   specification with test coverage.
