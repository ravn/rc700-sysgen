# Clang/LLVM-Z80 Port of rcbios-in-c

## Status: Planning

## Decision Log
- No `+shadow-regs` for rcbios (user decision 2026-03-31)
- All assembly in single `bios_shims.s` file (user decision 2026-03-31)
- Keep clang C files assembly-free (user decision 2026-03-31)
  - `hal_ei()`/`hal_di()`/`hal_halt()`/`intrinsic_im_2()` via `intrinsic.h` — OK (clang inlines them, verified)
  - All naked functions → `bios_shims.s`
  - `set_i_reg()` → `bios_shims.s`
  - No `__asm__` in application .c files for clang build

## Compiler Feature Verification (2026-03-31)

| Feature | Status | Notes |
|---------|--------|-------|
| `__attribute__((naked))` | WORKS | Suppresses prologue/epilogue |
| `__attribute__((interrupt))` | WORKS | Generates EI + RETI (issue #3 fixed) |
| `__attribute__((section("...")))` | WORKS | Places code in named sections |
| `address_space(2)` port I/O | WORKS | Generates IN/OUT instructions |
| `__attribute__((critical))` | MISSING | ravn/llvm-z80#4 (workaround: manual DI/EI) |

## Issues Filed

### rc700-gensmedet
- #1 — Umbrella: Port rcbios-in-c to clang/LLVM-Z80
- #2 — Inline asm translation: SDCC → GNU as syntax
- #3 — LLD linker script for BIOS memory layout
- #4 — ISR handling for clang
- #5 — Create bios_shims.s (all assembly in one file)

### llvm-z80 (dependencies)
- ravn/llvm-z80#3 — EI before RETI — **CLOSED** (verified fixed)
- ravn/llvm-z80#4 — `__critical` equivalent — OPEN (workaround available)
- ravn/llvm-z80#35 — No libc — OPEN (workaround: runtime.s stubs)

## Clang Build Flags (planned)

```
--target=z80 -Os -nostdlib
-ffunction-sections -fdata-sections
-Xclang -target-feature -Xclang +static-stack
-mllvm -disable-lsr
-Iclang_z80 -I. -Wno-gcc-compat -Wno-return-type
```

Note: NO `+shadow-regs` for BIOS (ISRs use explicit register save/restore).

## Architecture

### Binary layout (clang build)
```
File offset    Section      Content
-----------    -------      -------
0x0000         BOOT         boot_block.c (128B header)
0x0080         BOOT_DATA    boot_confi.c (128B CONFI + 384B tables)
0x0280         BOOT_CODE    boot_entry.c + bios_hw_init.c
0x02CE+        BIOS         bios_jump_vector_table.c + bios.c + bios_shims.s
               BSS          (not in binary, zeroed at runtime)
```

### Files for clang build
- `clang_z80/intrinsic.h` — DI/EI/HALT/IM2 via inline asm (reuse from autoload)
- `clang_z80/runtime.s` — memcpy/memset/memmove/__call_iy (reuse from autoload)
- `clang_z80/bios_shims.s` — all 22 naked functions + ISR wrappers
- `clang_z80/rc700_bios.ld` — LLD linker script
- Makefile additions for `make clang_bios`

### C source changes needed
- hal.h: fix clang section (currently blocks all inline asm with `.error`)
- bios.c: `#ifdef __clang__` to exclude naked function bodies (in bios_shims.s instead)
- bios.h: already has clang `__at()` fallback
- boot_entry.c: conditional `#include` for intrinsic.h
- bios_hw_init.c: conditional `#include` for intrinsic.h, `set_i_reg()` → shims file

## Work Order

1. **hal.h cleanup** — replace clang error-blocker with working stubs
2. **clang_z80/ support files** — intrinsic.h, runtime.s (copy from autoload)
3. **bios_shims.s** — translate all 22 naked functions + ISR wrappers
4. **C source `#ifdef`s** — guard out SDCC-only code paths for clang
5. **Linker script** — rc700_bios.ld
6. **Makefile** — add `make clang_bios` target
7. **Compile test** — get it to compile
8. **Link test** — get it to link
9. **MAME boot test** — verify it boots CP/M
10. **Size comparison** — clang vs SDCC
