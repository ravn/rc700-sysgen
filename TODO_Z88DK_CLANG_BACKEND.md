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
| `__sfr __at` port I/O  | native      | NOT supported (use z80_inp/z80_outp) |
| `sdcccall(1)` registers| native      | `__stdc` only (all on stack) |
| `__z88dk_fastcall`     | supported   | not currently supported |
| `__z88dk_callee`       | supported   | not currently supported |
| `__interrupt`          | native      | unknown |
| `__critical`           | native      | unknown |
| `__naked`              | native      | unknown |
| IX/IY register usage   | configurable| uses both |
| Code size              | smaller     | ~40-60% larger |
| Register allocation    | basic       | reportedly better |

## User decisions

- **IX/IY register usage**: Not considered a blocker. User plans to rework
  register allocation separately, so clib compatibility can be investigated
  when the toolchain is fully operational.

- **Toolchain approach**: Rather than building all of z88dk from source in
  Docker (which hit submodule failures and would be heavyweight), we build
  only zllvm-cbe in Docker and use the existing macOS z88dk binary
  distribution for everything else.

- **Port I/O**: Accepted as a known limitation. Portable alternative is
  `z80_inp()` / `z80_outp()` from `<z80.h>`.

## TODO

- Consider rewriting port variables from `__sfr __at` to `z80_inp()` /
  `z80_outp()` to make the C source portable across all z88dk backends
  (sdcc, sccz80, clang). Cost: ~6 bytes per call site vs 2 bytes for
  `__sfr __at`.

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
