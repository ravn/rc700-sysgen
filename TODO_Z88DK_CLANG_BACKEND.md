# z88dk Clang Backend Investigation

Investigated 2026-03-22 on branch `investigate-clang-backend`.

## Motivation

With sdcc, we must use `--fomit-frame-pointer` and make locals `static`
or global to avoid IX-relative addressing (each IX+d costs 2 extra bytes).
The z88dk Clang backend might produce better register allocation so locals
can stay on stack without the IX overhead, producing smaller code overall.

## How the pipeline works

```
C source → zclang (LLVM IR) → zllvm-cbe (IR → C) → sdcc (C → Z80 asm)
```

Clang doesn't generate Z80 directly. It produces LLVM IR which is
translated back to C by the LLVM C Backend, then compiled by sdcc.
This means sdcc peephole rules still apply to the final output.

## Toolchain setup

Three binaries are needed beyond the standard z88dk installation:

1. **zclang** — `ez80-clang` from [CEdev toolchain v14.2](https://github.com/CE-Programming/toolchain/releases/tag/v14.2).
   Download the macOS ARM DMG, copy `CEdev/bin/ez80-clang` to `z88dk/bin/`,
   symlink as `z88dk/bin/zclang`. Tested working on macOS ARM.

2. **zllvm-cbe** — built from [JuliaHubOSS/llvm-cbe](https://github.com/JuliaHubOSS/llvm-cbe).
   Requires LLVM 20. No macOS binary available, so we build it in Docker
   using `autoload-in-c/Dockerfile.zllvm-cbe`. A wrapper script at
   `z88dk/bin/zllvm-cbe` invokes the Docker container and applies patches
   (see below).

3. **Docker** — needed to run zllvm-cbe (Linux/amd64 binary via Docker).

Invocation: `zcc +z80 -compiler=ez80clang -clib=clang_iy ...`

## Workarounds needed (in z88dk/bin/zllvm-cbe wrapper)

Three issues required patching in the wrapper script:

1. **LLVM IR mangling mode** — ez80-clang emits `e-m:z-` (eZ80-specific)
   which standard llvm-cbe rejects ("unknown mangling mode"). Fixed by
   sed-replacing `e-m:z-` with `e-m:e-` in the .ll file before processing.

2. **Duplicate forward declarations** — llvm-cbe emits `const static T name;`
   then later `static const T name = {...};`. sdcc treats these as duplicate
   symbols. Fixed by stripping `^const static .*;$` lines from the output.

3. **Missing memcpy/memset** — llvm-cbe generates `memcpy()`/`memset()`
   calls for struct copies; z88dk maps these to `_memcpy_callee`/`_memset_callee`
   which aren't available without a CRT. Fixed by appending `__naked` asm stubs
   using LDIR to the generated .cbe.c file.

## Test results

### Simple C code — works

`clang_test.c` (add, inc_counter, get_counter) compiles end-to-end
through the full pipeline and produces valid Z80 object code.

### rom.c (PROM source) — compiles, but not functional

rom.c compiles through the full pipeline with additional workarounds:
- Port stubs: `__sfr __at` symbols provided as address constants
- Cross-module stubs: `init_fdc` and `banner_string` dummies

**Code size comparison (rom.c only, no boot_rom.c):**
- sdcc backend: **1734 bytes**
- Clang backend: **2481 bytes** (~43% larger)

The Clang output would NOT work on real hardware — port I/O uses
memory loads/stores (LD) instead of I/O instructions (IN/OUT).

## Port I/O

`__sfr __at` is supported by both sdcc and sccz80 (z88dk's own compiler),
but NOT by clang. The clang frontend doesn't understand the keyword, so
port variables become normal globals and the C→IR→C round-trip loses the
port-access semantics.

The portable alternative is `z80_inp(port)` / `z80_outp(port, data)` from
`<z80.h>`. These are library functions using `IN L,(C)` / `OUT (C),L`.
The sdcc backend optimizes them via macros to `__z88dk_fastcall` /
`__z88dk_callee` variants, reducing call overhead. Cost: ~6 bytes per
call site vs 2 bytes for `__sfr __at`.

See `clang_port_test.c` for a working example.

## Calling convention analysis

### The pipeline loses register annotations

The C→LLVM IR→C→sdcc round-trip cannot preserve register-based calling
conventions. The LLVM Z80 backend (jacobly0/llvm-project) defines several
register-passing conventions in
[`Z80CallingConv.td`](https://github.com/jacobly0/llvm-project/blob/z80/llvm/lib/Target/Z80/Z80CallingConv.td):

| Convention | ID | Registers |
|------------|-----|-----------|
| `CC_Z80_C` (default) | — | ALL on stack |
| `CC_Z80_LC` | 103 | i8: L,C; i16: HL,BC,DE,IY |
| `CC_Z80_LC_AB` | 104 | i8: A,B |
| `CC_Z80_LC_AC` | 105 | i8: A,C |
| `CC_Z80_LC_L` | 107 | i8: C,A,L,E; i16: BC,IY,HL,DE |

However, these are only used for internal compiler library calls, not user
functions. Standard `CC_Z80_C` (all params on stack) is used for all user
code. The register conventions cannot be triggered from C:

- clang rejects `__attribute__((regcall))` and `__attribute__((fastcall))`
  with "not supported for this target"
- llvm-cbe crashes on CC 103 — it cannot translate Z80-specific calling
  conventions back to C
- No Z80-specific CC attribute exists in the clang frontend

There is only one Z80 LLVM backend: [jacobly0/llvm-project](https://github.com/jacobly0/llvm-project).
All CE-Programming `ez80-clang` builds derive from it.

### Clang vs sdcccall(1): parameter passing

**Clang: ALL parameters on stack.** Every function begins with
`call ___sdcc_enter_ix` to set up a frame pointer, then loads parameters
via `(ix+N)`.

**sdcccall(1): first parameters in registers.** First u8 in A, first u16
in DE, first pointer in HL. Remaining parameters on stack.

### Clang vs sdcccall(1): return values

| Type | clang | sdcccall(1) |
|------|-------|-------------|
| `uint8_t` | L | A |
| `uint16_t` | HL | DE |
| `uint32_t` | DEHL | HLDE |
| pointer | HL | DE |

### Code size impact (from clang_calling_test.c)

| Function | clang (bytes) | sdcc (bytes) | ratio |
|----------|--------------|-------------|-------|
| `pass1_u8(u8)` | 10 | 2 | 5× |
| `pass2_u8(u8,u8)` | 13 | 2 | 6.5× |
| `pass_ptr(ptr)` | 14 | 2 | 7× |
| `read_ptr(ptr)` | 13 | 2 | 6.5× |
| Total test binary | 660 | 414 | 1.6× |

### Current limitation, not a permanent decision

The z88dk developers have not ruled out register passing for the clang
backend. The current `__stdc` convention is what works today. The
[z88dk issue #2329](https://github.com/z88dk/z88dk/issues/2329) discusses
parameter order challenges but does not make a statement about future
register passing support. The architectural constraint is the llvm-cbe
step which can only emit standard C — any solution would need to either
bypass llvm-cbe or teach it to emit sdcc register annotations.

## Key findings summary

| Feature                | sdcc backend | Clang backend |
|------------------------|-------------|---------------|
| Port I/O               | `__sfr __at` inline | `address_space(2)` inline (direct -S) |
| `sdcccall(1)` registers| native      | `__stdc` only (all on stack) |
| `__z88dk_fastcall`     | supported   | not currently supported |
| `__z88dk_callee`       | supported   | not currently supported |
| `__interrupt`          | native      | unknown |
| `__critical`           | native      | unknown |
| `__naked`              | native      | unknown |
| IX/IY register usage   | configurable| uses both |
| Code size              | smaller     | ~40-60% larger |
| Register allocation    | basic       | reportedly better |

## Port I/O portability experiment (branch `portable-port-io`)

Rewrote all `__sfr __at` port access in rom.h to use `z80_inp()` /
`z80_outp()` library functions. All 48 port accesses go through macros,
so only rom.h needed changes (no call sites modified).

**Result: CODE section grew from 1734 to 2100 bytes (+366 bytes, +21%)**
from library call overhead. Each `z80_outp_callee` call costs ~7 bytes
(push value, inc sp, ld hl port, call) vs 2 bytes for `OUT (n),A`.

Investigated whether sdcc can optimize these calls back to inline IN/OUT:
- **sdcc has no LTO** — cannot inline across compilation units
- **`z80_inp`/`z80_outp` are external asm functions** — not visible to sdcc
- **sdcc CAN inline `static inline` C functions** and constant-folds
  through them (verified: `add1(0x42)` → `ld a, 0x43`)
- **sdcc perfectly inlines `static inline` wrappers around `__sfr __at`**
  variables — the generated code is identical to direct `__sfr __at` access
- **No compiler flag exists** to make sdcc inline library function calls

Conclusion: the `__sfr __at` + macro approach in rom.h is already optimal.
sdcc inlines through the macros and emits 2-byte IN/OUT instructions.
The `z80_inp`/`z80_outp` library route cannot achieve the same code
density without peephole rules to pattern-match and replace the calls.

## `__sfr __at` is a first-class sdcc feature, not peephole

Traced through sdcc source code (documented in `SDCC_SFR_MECHANISM.md`):
1. **Parser** (`SDCC.y`): `__sfr` → `S_SFR` storage class
2. **Memory allocator** (`SDCCmem.c`): `S_SFR` → `REGSP` (I/O address space)
3. **Operand allocation** (`z80/gen.c`): `IN_REGSP` → `AOP_SFR` operand type
4. **Code emission** (`z80/gen.c`): `AOP_SFR` → `in a,(N)` / `out (N),a`
5. **Assembler**: `defc` symbol → 2-byte instruction

The Z80 I/O port space is a distinct address space in sdcc, parallel to
the memory address space. Every read/write of an `__sfr` variable emits
IN/OUT at code generation time — not via peephole optimization.

Supported by both sdcc AND sccz80 (both z88dk C backends).

## LLVM already has Z80 I/O port address space support

The jacobly0 Z80 LLVM backend defines `addrspace(2)` as 8-bit I/O ports
in its data layout string (`-p2:8:8`). Using
`__attribute__((address_space(2)))` in C produces correct `IN`/`OUT`
instructions when compiling directly with `ez80-clang -S`.

The bottleneck is llvm-cbe: it **discards all address space information**
when translating LLVM IR back to C. All pointers become plain `void*`.

| Approach to fix | Effort | Robustness |
|----------------|--------|------------|
| Patch llvm-cbe for addrspace(2) → `__sfr __at` | 2-4 days C++ | High |
| Post-process .cbe.c in wrapper script | 1-2 days | Medium |
| Skip llvm-cbe, use ez80-clang -S directly | 0 days | High, but loses sdcc |

## All LLVM-to-Z80 paths

| Project | Mechanism | Status | sdcccall | I/O ports |
|---------|-----------|--------|----------|-----------|
| [jacobly0/llvm-project](https://github.com/jacobly0/llvm-project) | Direct LLVM backend | Mature (eZ80 focus), active | No (custom) | addrspace(2) works |
| [llvm-z80/llvm-z80](https://github.com/llvm-z80/llvm-z80) | Direct LLVM (GlobalISel) | Experimental, 3 weeks old, AI-generated | Yes (sdcccall 0/1) | No |
| [JuliaHubOSS/llvm-cbe](https://github.com/JuliaHubOSS/llvm-cbe) + sdcc | IR → C → sdcc | Active, lossy round-trip | Yes (via sdcc) | Lost in llvm-cbe |
| earl1k/llvm-z80 | Direct backend | Abandoned (2013) | — | — |
| grapereader/llvm-z80 | Direct backend | Abandoned (2014) | — | — |
| gt-retro-computing/llvm-z80 | Direct backend | Abandoned (2020) | — | — |

No GCC Z80 backend exists. No viable Rust/Go/Zig path to Z80 exists.

## Direct ez80-clang experiment (branch `ez80clang-direct`)

Skipped llvm-cbe entirely. Used `ez80-clang --target=z80 -S` to compile
rom.c directly to Z80 assembly. This avoids the IR→C→sdcc round-trip
and its information loss.

### DEFPORT macro — per-port inline functions (final design)

`DEFPORT(name, addr)` generates per-port `static inline` functions.
Access via `port_in(name)` / `port_out(name, val)` macros.
All produce inline `IN A,(n)` / `OUT (n),A` — 2 bytes each.

```c
#if defined(__clang__)
#define DEFPORT(name, addr) \
    static inline uint8_t port_in_##name(void) { \
        return *(volatile __io uint8_t *)(uint8_t)(addr); \
    } \
    static inline void port_out_##name(uint8_t val) { \
        *(volatile __io uint8_t *)(uint8_t)(addr) = val; \
    }
#elif defined(__SDCC)
#define DEFPORT(name, addr) __sfr __at (addr) _sfr_##name;
#define port_in(name)       (_sfr_##name)
#define port_out(name, val) (_sfr_##name = (val))
#else
#define DEFPORT(name, addr) /* no-op stubs */
#endif

DEFPORT(fdc_status, 0x04)      // same for all backends
uint8_t x = port_in(fdc_status);    // IN A,(04)
port_out(fdc_data, 0x42);           // OUT (05),A
```

**Design evolution:**
1. Tried `z80_inp()`/`z80_outp()` library calls — +21% code size, rejected.
2. Tried three-way macro duplication (clang/sdcc/other versions of every
   hardware macro) — too much duplication, rejected by user.
3. Tried DEFPORT with `_port_X` lvalue aliases — required 26+ `#define`
   lines for clang because C preprocessor cannot emit `#define` from macro.
4. Tried `static inline` functions wrapping `static __sfr __at` in sdcc —
   sdcc emits standalone copies of all static inline functions even when
   unused, overflowing the tight BOOT section (+156 bytes of dead code).
5. **Final:** clang uses inline functions (sdcc doesn't need them), sdcc
   uses `__sfr __at` declarations (zero code). No lvalue aliases needed.

**Why sdcc uses `__sfr __at` instead of inline functions:**
sdcc always emits standalone function bodies for `static inline` functions,
even when they are fully inlined at the call site and never called directly.
With 26 ports × 2 functions × 3 bytes = 156 bytes of dead code, this
overflows the autoload PROM's BOOT section (102 byte limit). `__sfr __at`
declarations generate only `defc` equates (zero code bytes).

### Both projects ported

**Autoload PROM** (`autoload-in-c/rom.h`):
- 26 DEFPORT declarations, port_in/port_out macros for all hardware access
- rom.c: no direct `_port_X` references — all go through macros
- sdcc: 1734 bytes CODE (unchanged). MAME boot test PASS.
- clang: zero errors, zero warnings.

**BIOS** (`rcbios-in-c/hal.h`):
- 42 DEFPORT declarations, port_in/port_out for all hardware access
- bios.c: 72 `_port_X` refs converted. bios_hw_init.c: 38 refs converted.
- `__at(addr)` memory-mapped variables → `#define` pointer for clang
- Inline asm scroll block → `#ifdef __SDCC` / `#else memmove+memset`
- `__naked`, `__interrupt`, `__critical` → no-ops for clang
- `#include <intrinsic.h>` guarded with `#ifdef __SDCC`
- sdcc: 5542 bytes (unchanged). Cycle test PASS (ASM FILEX + TYPE).
- clang: zero errors, zero warnings on bios.c and bios_hw_init.c.

### Remaining gaps for a full clang build

- clang asm output uses ELF section syntax — z88dk-z80asm incompatible
- Labels with dots (`_.str.6`) parsed as floats by z88dk assembler
- External runtime: `__bshl`, `__bshru`, `__sshl`, `__sshru`, `__indcallhl`
- No linker script for BOOT/CODE section layout
- boot_rom.c and intvec.c not yet compiled with clang

## User decisions

- **IX/IY register usage**: Not considered a blocker. User plans to rework
  register allocation separately.

- **Toolchain approach**: Exploring direct `ez80-clang -S` (skip llvm-cbe).
  Also built zllvm-cbe in Docker for the CBE path experiments.

- **Port I/O design**: User rejected z80_inp/z80_outp library calls (+21%
  code size), rejected three-way macro duplication, and rejected lvalue
  aliases. User requested a single DEFPORT macro that generates per-port
  inline functions for clang and keeps `__sfr __at` for sdcc. The final
  design has zero code overhead for sdcc and zero lvalue-alias `#define`
  lines.

- **BIOS clang compat**: User requested the BIOS also be compilable with
  clang and tested with the full ASM FILEX cycle test. Code size is not
  a premium for clang — being able to compile is the goal.

- **Cycle testing**: Full ASM FILEX + TYPE FILEX.PRN cycle test run
  after every BIOS change to verify no regression.

## References

- [z88dk Clang support wiki](https://github.com/z88dk/z88dk/wiki/Clang-support)
- [CEdev toolchain releases](https://github.com/CE-Programming/toolchain/releases)
- [JuliaHubOSS/llvm-cbe](https://github.com/JuliaHubOSS/llvm-cbe)
- [jacobly0/llvm-project (Z80 LLVM backend)](https://github.com/jacobly0/llvm-project)
- [Z80CallingConv.td (register conventions)](https://github.com/jacobly0/llvm-project/blob/z80/llvm/lib/Target/Z80/Z80CallingConv.td)
- [z88dk issue #2329: ez80-clang support](https://github.com/z88dk/z88dk/issues/2329)
- [z88dk CallingConventions wiki](https://github.com/z88dk/z88dk/wiki/CallingConventions)
- [z88dk z80.h library (z80_inp, z80_outp)](https://www.z88dk.org/wiki/doku.php?id=libnew:z80)
- [z88dk intrinsics](https://github.com/z88dk/z88dk/wiki/intrinsic)
- [SDCC manual (§3.5.2: __sfr __at)](https://sdcc.sourceforge.net/doc/sdccman.pdf)
- [z88dk issue #78: compiler intrinsics for port addressing](https://github.com/z88dk/z88dk/issues/78)
