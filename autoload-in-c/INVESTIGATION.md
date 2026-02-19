# ROA375 C Rewrite: Language Investigation and Post-Mortem

## Background

The RC702 autoload PROM (ROA375) is a 2048-byte boot ROM that initializes
hardware (PIO, CTC, DMA, CRT, FDC), handles interrupts, auto-detects floppy
disk density, reads the boot track, and jumps to CP/M. The original
hand-written Z80 assembly uses 2046 of the 2048 available bytes — essentially
every byte counts.

The goal was to rewrite this ROM in a high-level language to make the boot
logic more readable, maintainable, and testable on a host machine, while
still fitting in 2KB.

## The Investigation

### Requirements

- Must generate Z80 machine code for bare-metal ROM at address 0x0000
- Must support direct I/O port access (IN/OUT instructions)
- Must support Z80 Mode 2 interrupt handlers
- Must produce very compact code (target: 2048 bytes total)
- Must be testable on a host machine (x86/ARM) via hardware abstraction layer
- Inline assembly support needed for timing-critical sections

### Candidates Evaluated

Six language/compiler options were researched:

1. **z88dk with zsdcc backend** — z88dk's patched version of SDCC with
   additional Z80 peephole optimizations
2. **z88dk with sccz80 backend** — z88dk's native C compiler
3. **SDCC standalone** — Stock Small Device C Compiler for Z80
4. **Forth** — Z80 Forth implementations (subroutine-threaded)
5. **PL/M-80** — Intel's systems programming language, with modern
   reimplementations
6. **LLVM-based** (Zig, Rust via Z80Babel) — modern languages with
   experimental Z80 backends

### Findings

**z88dk/zsdcc** was assessed as the best option:
- z88dk's patched SDCC includes an extensive Z80-specific peephole rule set
  claiming 5-40% size reduction versus stock SDCC (5-10% typical)
- Supports `__sfr __at` for direct port I/O, `__z88dk_fastcall` and
  `__z88dk_callee` calling conventions to reduce call overhead
- Supports `__at()` for placing variables at fixed addresses
- Custom crt0.asm allows full control over ROM bootstrap and interrupt vectors
- Two compiler backends (zsdcc and sccz80) can be mixed per-function
- Active project with Z80-specific optimizations as a primary goal
- The `-SO3` optimization level and `--opt-code-size` flag prioritize code
  density

**z88dk/sccz80** was noted as potentially producing tighter code for some
patterns, but zsdcc was preferred for its broader optimization pipeline.

**SDCC standalone** was rejected — z88dk's patched version produces strictly
better code, so there is no reason to use stock SDCC directly.

**Forth** was rejected — the kernel/interpreter overhead consumes the 2KB
budget before any application code. Interrupt handling in Forth is awkward,
and host testability is poor.

**PL/M-80** was rejected — historically interesting but practically dead
tooling. No Z80-specific instruction support, no inline assembly mechanism,
no host testing path. Toolchain is archaeology, not engineering.

**LLVM-based (Zig/Rust)** was rejected — the Z80Babel pipeline is fragile
and experimental. Code size overhead from LLVM's IR-to-Z80 translation
negates the 2KB budget entirely.

### Size Estimates at Decision Time

The investigation estimated z88dk/zsdcc would produce code with **5-15%
overhead** versus hand-written assembly. For a ~1944-byte code payload, this
predicted roughly 2020-2240 bytes — tight but theoretically within the
2048-byte budget with careful coding.

This estimate was based on z88dk benchmark data for general-purpose Z80 code.

## What Actually Happened

### Architecture

The rewrite used a Hardware Abstraction Layer (HAL) pattern:
- `hal.h` — abstract interface for all hardware I/O
- `hal_z80.c` — real Z80 port I/O implementation
- `hal_host.c` — mock implementation logging calls for host testing
- `crt0.asm` — bootstrap stub, NMI handler, interrupt vectors, display
  interrupt handler (timing-critical DMA reprogramming that cannot be in C)
- `boot.c`, `fdc.c`, `fmt.c`, `init.c`, `isr.c` — C implementation of all
  boot logic

Host tests (`test_boot.c`, `test_fdc.c`) verify correct HAL call sequences
and logic without Z80 hardware. This part worked exactly as intended — the C
code is readable, testable, and the HAL cleanly separates hardware concerns.

### The Size Problem

The initial all-C build (with only the minimal crt0.asm bootstrap) produced:

| Build                    | CODE section | BOOT section | Total    |
|--------------------------|-------------|-------------|----------|
| Original assembly ROM    | —           | —           | 2048 B   |
| z88dk/zsdcc (all C)      | 4353 B      | 105 B       | 4458 B   |
| z88dk/sccz80 (all C)     | 2466 B      | 105 B       | 2571 B   |
| Final (all hand asm)     | 1919 B      | 105 B       | 2024 B   |

The zsdcc backend produced code **2.2x the size of the original assembly**
— not the predicted 5-15% overhead, but a **117% overhead**. Even sccz80,
which fared much better, was still **34% over budget** (2571 vs 2048 bytes).

### Why the Estimate Was Wrong

The 5-15% overhead figure comes from benchmarks on *general-purpose* Z80
code — programs with loops, arithmetic, string processing, and data
structures where compilers can apply meaningful optimizations. The ROA375
boot ROM is fundamentally different:

1. **Almost entirely I/O register manipulation.** The code is sequences of
   OUT instructions with specific values to specific ports, interspersed with
   status polling loops. A C compiler cannot optimize `out((P_FDC_DATA), 0x03);
   out((P_FDC_DATA), 0x4F); out((P_FDC_DATA), 0x20);` any better than the
   assembly — but it adds function call overhead, stack frame setup, and
   register save/restore around each call.

2. **Global state accessed everywhere.** The original assembly uses fixed
   memory addresses for FDC result bytes, disk parameters, and control flags.
   Every function accesses these directly via absolute addresses. C generates
   pointer loads, struct offset calculations, and temporary variables that
   the original assembly avoids entirely.

3. **Calling convention overhead.** Even with `__z88dk_fastcall` (single
   parameter in HL) and `__z88dk_callee` (callee pops stack), every function
   call in C involves pushing/popping registers that the hand-written assembly
   simply knows are not in use. The SDCC backend uses IX as frame pointer
   for any function with local variables, adding 4+ bytes per function for
   `push ix / ld ix,0 / add ix,sp ... pop ix`.

4. **No cross-function register allocation.** The original assembly tracks
   which registers hold which values across function boundaries. For example,
   after `flo6` (Sense Interrupt Status), the result is already in A and the
   caller knows this. In C, the return value goes through HL, the caller
   extracts it, and stores it — multiple redundant moves.

5. **Interrupt handler overhead.** The C compiler must save all registers it
   *might* use in an interrupt handler. The original assembly saves only what
   it actually uses.

6. **Format tables and string constants.** C adds alignment padding and
   section overhead for const data. The original assembly places data inline
   exactly where needed.

7. **Branch optimization.** The original assembly uses JR (relative jump,
   2 bytes) everywhere possible. The C compiler tends to emit JP (absolute
   jump, 3 bytes) even for nearby targets, and generates unnecessary
   comparison/branch sequences for simple flag checks.

### The Progression

With the all-C zsdcc build at 4458 bytes (117% over), we attempted
aggressive C-level optimization:

- `static` on all internal functions (enables inlining)
- Unity build (all .c files compiled as one translation unit)
- `__z88dk_fastcall` for single-parameter functions
- `__z88dk_callee` for multi-parameter functions
- `-SO3 --opt-code-size --max-allocs-per-node200000` compiler flags

This was still far over budget. The sccz80 backend produced 2571 bytes —
closer, but still 523 bytes over.

The only path to 2048 bytes was moving functions from C to hand-written
Z80 assembly in crt0.asm, one by one, starting with the largest and most
inefficiently compiled:

1. HAL functions (port I/O wrappers) — trivial in assembly, bloated in C
2. FDC driver (polling loops, status checks) — register-intensive
3. Format table lookups — simple indexed addressing
4. Boot logic (init sequences, density detection, error handling)
5. Everything else

Each function moved to assembly saved 30-60% of its C-compiled size. After
moving *every* function to assembly, the final ROM is 2024 bytes — 24 bytes
under the limit, and actually 24 bytes *smaller* than the original 2048-byte
ROM (which had only 2 bytes of unused padding).

### The Final State

The `autoload-in-c/` directory now contains:

- **crt0.asm** — the complete ROM in hand-written Z80 assembly (~1500 lines),
  all functions that were originally C are now assembly
- **boot.c, fdc.c, fmt.c, init.c, isr.c** — C implementations wrapped in
  `#ifdef HOST_TEST`, used only for host testing
- **hal_host.c** — mock HAL for host testing
- **test_boot.c, test_fdc.c** — host tests that verify logic via the C code
- **hal.h, boot.h** — shared declarations (with z88dk attributes for ROM,
  plain C for host tests)

The C code serves as the *specification* and *test harness*, while the
actual ROM is pure assembly. The HAL pattern successfully enables host
testing of the boot logic — just not as compiled Z80 code.

## Why z88dk Was Still the Right Choice

Despite the C code being too large for the final ROM, z88dk was the correct
choice for this project:

1. **It provided the build infrastructure.** z88dk's linker, section model,
   custom crt0 support, and binary output generation are used in the final
   build even though no C-compiled code remains. The `+z80 -clib=sdcc_iy`
   target with `--no-crt` correctly assembles crt0.asm and produces the ROM
   binary.

2. **The C code was written and tested first.** Having working, tested C
   implementations of every function made translating to assembly
   straightforward and correct. Each assembly function could be verified
   against the C reference.

3. **sccz80 came surprisingly close.** At 2571 bytes (34% over), sccz80
   was within reach of fitting if the ROM had been ~600 bytes larger (e.g.,
   a 4KB PROM). For a less extreme size constraint, C would have worked.

4. **No other toolchain would have done better.** The fundamental problem is
   that 2048 bytes is too tight for *any* compiler when the code is 95% I/O
   register manipulation. The overhead is inherent to compilation, not
   specific to z88dk.

## What If: Global Variables Instead of Parameters

In hindsight, the C code was written with conventional function signatures —
`flo7(uint8_t dh, uint8_t cyl)`, `stpdma(uint16_t addr, uint16_t count,
uint8_t mode)`, `readtk(uint8_t cmd, uint8_t retries)`, etc. — because
that is idiomatic C.  But the original assembly passes no parameters on the
stack at all.  Every function reads its inputs directly from fixed-address
global variables.  The boot ROM is single-threaded, non-reentrant, and
operates on exactly one disk drive context.  There is no reason for
parameter passing.

### The Cost of Parameters

The sccz80 build has 4 functions that use `___sdcc_enter_ix` to set up an
IX frame pointer for stack parameter access: `isrc70x`, `chk_sysfile`,
`rdtrk0`, and `syscall`.  Each pays:

- 3 bytes for `call ___sdcc_enter_ix`
- 2 bytes for `pop ix` at the end
- 3 bytes per parameter access via `ld a,(ix+N)`

The `___sdcc_enter_ix` runtime function itself costs 11 bytes (shared).

At the call sites, each parameter push costs 2-3 bytes:

- `push hl` = 1 byte (word parameter already in HL)
- `push af / inc sp` = 2 bytes (byte parameter in A)
- `ld hl,value / push hl` = 3-4 bytes (constant or memory value)

Functions like `memcopy(dst, src, len)` are called ~5 times with 7 bytes
of push setup each.  `stpdma(addr, count, mode)` pushes 5 bytes of args
that all come from `g_state` — values the function could read directly.

### Estimated Savings

| Source of savings                    | Bytes saved |
|--------------------------------------|-------------|
| Eliminate `___sdcc_enter_ix` runtime | 11          |
| Remove IX frame setup (4 functions)  | 20          |
| Remove parameter pushing (all sites) | ~120        |
| **Total estimated**                  | **~150**    |

The IX-indexed parameter reads (`dd 7e nn`, 3 bytes) would be replaced by
absolute address reads (`3a nn nn`, 3 bytes) — roughly the same size, so
no savings there.

### Would It Have Been Enough?

With globals only, sccz80's code_compiler section would shrink from 2178
to approximately 2028 bytes.  The budget is 1943 bytes (2048 minus 105 for
the BOOT section).  That leaves a gap of roughly 85 bytes — close, but
still over.

However, the estimate is conservative:

- With no stack frames to manage, the compiler might keep values in
  registers longer, avoiding redundant loads.
- `memcopy` and `memcmp_n` (called ~7 times with 3 parameters each)
  account for a disproportionate share of push overhead.  Replacing them
  with zero-parameter wrappers around global src/dst/len variables would
  save more than the per-call average.
- Some of the remaining 85-byte gap could be closed by hand-writing just
  2-3 hot functions (e.g. `rsult` at 109 bytes and `fmtlkp` at 112 bytes)
  rather than all 40+.

A globals-only C approach with sccz80, plus hand-written assembly for 3-5
functions, would likely have fit.  This hybrid would have kept ~80% of the
code in C while staying within the 2048-byte budget.

### Why This Wasn't Tried

The parameter-heavy style was chosen first because it is natural C.  By the
time the size problem became apparent, the approach of moving functions to
assembly one at a time was already working and converging.  The
globals-only rewrite would have required restructuring the entire C
codebase — changing every function signature, every call site, and every
test — for uncertain savings.  Moving to assembly was more predictable: each
function moved saved a known amount, and progress was monotonic.

The lesson is clear: **for extreme size constraints on Z80, avoid function
parameters entirely.**  Use global state like the original assembly does.
The `__z88dk_fastcall` and `__z88dk_callee` conventions help, but they only
address single-parameter and callee-cleanup cases.  For multi-parameter
functions, globals eliminate overhead that no calling convention can avoid.

## Phase 2: The Globals-Only Experiment

The "What If" analysis above predicted ~150 bytes of savings from eliminating
function parameters.  This was tested by rewriting all C code to use a
globals-only architecture:

- **No function takes parameters.  No function returns values.**
- All inputs/outputs go through fields in a single `boot_state_t g_state`
  struct at a fixed RAM address (0xBF00).
- Functions that previously returned success/fail write to `g_state.result`
  instead.
- Trivially small functions (mkdhb, errcpy, setfmt, clrflf) were inlined.

The previous parameterized version was archived to `autoload-in-asm/`.

### sccz80 Results: Globals-Only Made Things Worse

| Build | code_compiler | runtime | Total ROM |
|---|---|---|---|
| sccz80 with parameters | 2178 B | 131 B | 2571 B |
| sccz80 globals-only | 2705 B | 131 B | 3496 B |

The globals-only approach **increased** code size by 527 bytes (+24%).  The
prediction was wrong because it assumed IX-relative access (3 bytes: `ld a,
(ix+N)`) and absolute-address access (3 bytes: `ld a, (NN)`) would cost the
same.  In practice, sccz80 generates 5+ bytes per g_state field access:

```z80
    ld  hl, _g_state + 39   ; 3 bytes — load address of field
    ld  l, (hl)             ; 1 byte  — dereference
    ld  h, 0                ; 2 bytes — zero-extend to 16-bit
```

Every function reads multiple fields this way.  The overhead compounds
because sccz80 promotes all byte operations to 16-bit, generating dead
`ld h, 0` instructions throughout.  Meanwhile, the eliminated IX frame
setup saved only 10 bytes per function (195 bytes total across 15 functions),
which was overwhelmed by the more expensive field accesses.

### The `-SO3` Flag Discovery

During analysis of why sccz80 produced such large code, it was discovered
that the Makefile flag `-SO3` does **nothing for sccz80** — it controls
the sdcc peephole optimizer only.  The sccz80 equivalent is `-O3`, which
saved a modest 11 bytes (3496→3485).

This was the key finding: the build was using the wrong compiler backend
relative to its optimization flags.

### Switching to sdcc: A Dramatic Improvement

Testing the sdcc backend instead of sccz80 (using `-clib=sdcc_iy --opt-code-size`)
produced dramatically smaller code:

| Configuration | code_compiler | runtime | Total ROM |
|---|---|---|---|
| sccz80 -O3 (globals-only) | 2694 B | 131 B | 3485 B |
| sdcc --opt-code-size -SO3 | 1844 B | 11 B | 2515 B |
| sdcc + max-allocs 1M + fomit-frame-ptr | 1812 B | 11 B | 2483 B |
| sdcc + sdcccall(1) | 1726 B | 11 B | 2397 B |

sdcc generates fundamentally better code for this workload:

- **Direct byte loads**: `ld l, (hl)` instead of sccz80's load-and-extend
- **Tail-call optimization**: `jp target` instead of full epilogue + RET
- **Bit instructions**: `bit N, (hl)` for flag tests instead of load-mask-compare
- **Compact comparisons**: `sub a, N; ret Z` instead of library calls
- **Minimal runtime**: 11 bytes (just `___sdcc_enter_ix`) vs sccz80's 131 bytes
  of library functions (l_eq, l_ne, l_gt, l_and, l_or, l_gint*, l_pint*)

### z88dk Compiler Flags Reference

Flags that produced measurable size reductions:

| Flag | Via zcc | Effect | Savings |
|---|---|---|---|
| `--opt-code-size` | direct | Subroutine calls for stack frames | ~970 B |
| `-SO3` | direct | z88dk peephole optimizer level 3 (600+ rules) | included above |
| `--max-allocs-per-node 1000000` | `-Cs"..."` | Deeper register allocator search | 18 B |
| `--fomit-frame-pointer` | `-Cs"..."` | Skip IX frame where possible | 14 B |
| `--allow-unsafe-read` | `-Cs"..."` | Allow read of any memory location | 4 B |
| `--sdcccall 1` | `-Cs"..."` | New ABI: params in A/HL/DE registers | 86 B |

Flags that produced no measurable benefit:

| Flag | Notes |
|---|---|
| `--allow-undocumented-instructions` | No IXH/IXL/IYH/IYL usage generated in practice |
| `--peep-asm` | Risky with hand-crafted inline assembly |

Important distinctions:
- `-SO` (levels 0-3) controls the **sdcc** peephole optimizer.  Does nothing for sccz80.
- `-O` (levels 0-3) controls the **sccz80** copt peephole optimizer.  Does nothing for sdcc.
- `--opt-code-size` is sdcc-only.  No sccz80 equivalent exists.
- Flags passed to the underlying sdcc compiler use `-Cs"--flag"` syntax via zcc.
- **PATH issues**: z88dk tools must be invoked with full absolute paths
  (e.g. `../z88dk/bin/zcc`), not via `export PATH=...`, because the shell
  environment in some execution contexts doesn't reliably inherit PATH changes.

### Analysis: Why 2397 Bytes, Not 2048

The remaining 349-byte gap breaks down as follows:

**Budget**: BOOT (105 B) + CODE crt0 (409 B) + rodata (146 B) + runtime (11 B)
= 671 bytes of fixed overhead, leaving 1377 bytes for C-compiled code.
Actual C code: 1726 bytes — 349 bytes over.

Identifiable waste in the sdcc-generated assembly:

| Pattern | Bytes | Notes |
|---|---|---|
| Dead code after unconditional jumps | ~13 | Unreachable `jr`/`jp` the peephole missed |
| mcopy/mcmp as C loops with IX frames | ~35 | Could be LDIR/CPI assembly (~12 B each) |
| `___sdcc_enter_ix` runtime (1 user) | 11 | Only boot7 needs it |
| Redundant push/pop around absolute stores | ~6 | `push hl; ld (abs),a; pop hl` |
| g_state.result write+read pattern | ~93 | 3 B store + 3 B load vs 1 B test on return value |
| g_state parameter indirection | ~100-150 | 128 `_g_state` refs, many would be free register ops |
| Custom peephole opportunities | ~20-30 | Project-specific patterns |
| **Total identifiable** | **~280-340** | |

The largest single source of waste is the globals-only architecture itself.
With sdcccall(1), the first parameter passes in A (for char) or HL (for
pointer/int), and the second in DE — zero bytes of callee overhead.
Reading from g_state costs 3 bytes per field (`ld a, (_g_state+N)`).
The approach designed for sccz80 actively hurts sdcc.

### Path to 2048 Bytes

A viable but narrow path exists:

1. **Revert globals-only → parameterized functions** with sdcccall(1).
   The sccz80 parameterized build produced code_compiler = 2178 bytes.
   Applying the sdcc/sccz80 ratio (1726/2705 ≈ 0.64), a sdcc parameterized
   build would produce approximately 1390 bytes of code_compiler — just
   13 bytes over the 1377-byte budget.

2. **Replace mcopy/mcmp with LDIR/CPI assembly** in crt0.asm (~35 bytes).

3. **Custom peephole rules** for dead code elimination (~15-30 bytes).

4. Use `__z88dk_fastcall` on single-parameter functions and
   `__z88dk_callee` on multi-parameter functions for additional savings.

This would require a major rewrite — reverting every function signature,
every call site, and every test back to parameterized style, then rebuilding
with the sdcc backend.  The margin is thin (~50-80 bytes estimated), and the
outcome is uncertain since the 0.64 ratio is an extrapolation.

### Current State

The code in `autoload-in-c/` contains the globals-only architecture.  It
compiles with sccz80 by default (the Makefile uses `-clib=classic`).  To
build with the best-known sdcc configuration:

```bash
export PATH="../z88dk/bin:$PATH"
export ZCCCFG="../z88dk/lib/config"
../z88dk/bin/zcc +z80 -clib=sdcc_iy --no-crt -SO3 --opt-code-size \
  -Cs"--max-allocs-per-node 1000000" \
  -Cs"--fomit-frame-pointer" \
  -Cs"--allow-unsafe-read" \
  -Cs"--sdcccall 1" \
  -pragma-define:CRT_ORG_CODE=0x0000 \
  -pragma-define:CRT_ORG_BSS=0x8000 \
  -m --list -create-app \
  -o roa375 crt0.asm rom_all.c
```

### Comparison: sccz80 vs sdcc (corrected)

The Z88DK_EVALUATION.md and the first section of this document incorrectly
concluded that sccz80 produces tighter code than sdcc.  This was based on a
build where sdcc used `-clib=sdcc_iy` without `--opt-code-size`, while
sccz80 was effectively running without peephole optimization (the `-SO3`
flag was present but does nothing for sccz80).

Corrected comparison for the globals-only codebase:

| Backend | Best flags | code_compiler | runtime | Total |
|---|---|---|---|---|
| sccz80 -O3 | `-clib=classic -O3` | 2694 B | 131 B | 3485 B |
| sdcc | `--opt-code-size -SO3 --sdcccall 1` + tuning | 1726 B | 11 B | 2397 B |

**sdcc produces 36% smaller code than sccz80** for this workload when both
are properly optimized.  The earlier conclusion that "sccz80 generates
significantly tighter code" was an artifact of misconfigured optimization
flags.

## Lessons Learned

- **Compiler overhead estimates from benchmarks do not apply to I/O-heavy
  embedded code.** The 5-15% figure was for computational code. For code
  that is mostly `IN`/`OUT` sequences with status polling, compiler overhead
  is 30-120%.

- **2KB is below the practical minimum for C on Z80.** A more realistic
  lower bound for useful C code on Z80 (with z88dk) is approximately 4KB.
  Below that, the calling convention and register management overhead
  dominates.

- **The HAL pattern works for testability even when the final code is
  assembly.** Writing C first, testing it, then translating to assembly is a
  productive workflow. The C serves as executable documentation.

- **sdcc with `--opt-code-size -SO3 --sdcccall 1` produces the smallest
  code** among z88dk backends for I/O-heavy code.  sccz80 was initially
  thought to be better but this was due to misconfigured optimization flags.

- **Globals-only architecture is backend-dependent.** For sccz80, g_state
  field access and IX-relative parameter access cost similar amounts, so
  eliminating IX frames helps.  For sdcc with sdcccall(1), parameters pass
  in registers for free, making g_state indirection strictly more expensive.

- **`-SO3` and `-O3` are different flags for different compilers.**  Mixing
  them up causes silent misconfiguration — the wrong flag is simply ignored
  with no warning.

- **`--sdcccall 1`** saves significant code by passing parameters in
  registers (A, HL, DE) instead of on the stack.  This is the single most
  impactful flag after `--opt-code-size`.
