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

## Key findings

| Feature                | sdcc backend | Clang backend |
|------------------------|-------------|---------------|
| `__sfr __at` port I/O  | native      | NOT supported |
| `__interrupt`          | native      | unknown       |
| `__critical`           | native      | unknown       |
| `__naked`              | native      | unknown       |
| `sdcccall(1)`          | native      | `__stdc` only |
| `__z88dk_fastcall`     | supported   | NOT supported |
| IX/IY register usage   | configurable| uses both     |
| Code size              | smaller     | ~40% larger   |
| Register allocation    | basic       | reportedly better |

The `__sfr __at` incompatibility is the core blocker for bare-metal code.
Clang doesn't understand this sdcc extension, so port variables become
normal globals. The C→IR→C round-trip loses the port-access semantics
and sdcc generates LD (memory) instead of IN/OUT (I/O).

## User decisions

- **IX/IY register usage**: Not considered a blocker. User plans to rework
  register allocation separately, so clib compatibility can be investigated
  when the toolchain is fully operational.

- **Toolchain approach**: Rather than building all of z88dk from source in
  Docker (which hit submodule failures and would be heavyweight), we build
  only zllvm-cbe in Docker and use the existing macOS z88dk binary
  distribution for everything else.

- **Port I/O incompatibility**: Accepted as a known limitation for now.
  The goal was to get the pipeline compiling to assess code size and
  feasibility, not to produce working hardware code.

## Conclusion

The z88dk Clang backend is **not viable for bare-metal Z80 ROM code**
that uses `__sfr __at` for port I/O. The pipeline works for pure
computational C code but the C→IR→C round-trip loses hardware I/O
semantics and produces ~40% larger code.

For the RC702 autoload PROM, sdcc with manual optimizations (static
locals, peephole rules, `--fomit-frame-pointer`) remains the right choice.

The Clang backend could be useful for projects that:
- Don't need direct port I/O (application-level CP/M code)
- Can use z88dk's CRT and standard library
- Benefit from better register allocation on compute-heavy code

## References

- [z88dk Clang support wiki](https://github.com/z88dk/z88dk/wiki/Clang-support)
- [CEdev toolchain releases](https://github.com/CE-Programming/toolchain/releases)
- [JuliaHubOSS/llvm-cbe](https://github.com/JuliaHubOSS/llvm-cbe)
