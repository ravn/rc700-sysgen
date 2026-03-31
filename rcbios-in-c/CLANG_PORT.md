# Clang/LLVM-Z80 Port of rcbios-in-c

## Status: BOOTS CP/M (6379 bytes, MAXI disk, MAME verified 2026-03-31)

## Size Comparison

| Compiler | Binary | vs Assembly | Notes |
|----------|--------|-------------|-------|
| Assembly (REL30) | 6426 B | — | Hand-written reference |
| SDCC (z88dk) | 6784 B | +358B (+5.6%) | |
| **Clang (llvm-z80)** | **6379 B** | **-47B (-0.7%)** | Smaller than hand-written asm |

MINI limit: 6144B — clang is 235B over. MAXI limit: 9984B — OK.

## Decision Log
- No `+shadow-regs` for rcbios (ISRs use explicit register save/restore)
- All assembly in single `bios_shims.s` file
- Keep clang C files assembly-free (intrinsic.h with static inline OK)
- Two jump vector tables: SDCC (naked shims in bios.c) and clang (shims in bios_shims.s)
- Banner shows compiler: `C-bios/clang` or `C-bios/sdcc`

## Bugs Found
- ravn/llvm-z80#44 — address_space(2) PHI crash on conditional port I/O
  - Workaround: noinline per-channel SIO functions (~12B overhead)
- Missing `__umodqi3` (8-bit unsigned modulo) — added to runtime.s

## Compiler Features Verified

| Feature | Status | Notes |
|---------|--------|-------|
| `__attribute__((naked))` | WORKS | Suppresses prologue/epilogue |
| `__attribute__((interrupt))` | WORKS | Generates EI + RETI (ravn/llvm-z80#3 fixed) |
| `__attribute__((section("...")))` | WORKS | Places code in named sections |
| `address_space(2)` port I/O | WORKS | Generates IN/OUT (crashes on PHI, #44) |
| Undocumented instructions | CLEAN | No IXH/IXL/IYH/IYL in output |

## Issues

### rc700-gensmedet
- #1 — Umbrella: Port rcbios-in-c to clang — **IN PROGRESS**
- #2 — Inline asm translation — **CLOSED** (bios_shims.s)
- #3 — LLD linker script — **CLOSED**
- #4 — ISR handling — **CLOSED**
- #5 — bios_shims.s — **CLOSED**

### llvm-z80
- ravn/llvm-z80#3 — EI before RETI — **CLOSED**
- ravn/llvm-z80#4 — `__critical` equivalent — OPEN (workaround: Z80 HW disables interrupts on entry)
- ravn/llvm-z80#42 — Built-in intrinsics — OPEN (low priority, intrinsic.h workaround)
- ravn/llvm-z80#43 — Custom CP/M calling convention — OPEN (low priority, shims work)
- ravn/llvm-z80#44 — address_space(2) PHI crash — OPEN (noinline workaround)

## Clang Build Command

```bash
CFLAGS="--target=z80 -Os -nostdlib -ffunction-sections -fdata-sections \
  -Xclang -target-feature -Xclang +static-stack -mllvm -disable-lsr \
  -Iclang_z80 -I. -Wno-gcc-compat -Wno-return-type -DMSIZE=56"

# Compile C files with $CFLAGS, assemble .s with --target=z80
# Link with: ld.lld --gc-sections --defsym BIOSAD=0xDA00 -T clang_z80/rc700_bios.ld
# Extract binary: llvm-objcopy -O binary bios.elf bios.bin
```

## Remaining Work
- [ ] Makefile target (`make clang_bios`)
- [ ] MINI disk support (reduce 235B to fit 6144B limit)
- [ ] Function-by-function size comparison vs SDCC
- [ ] Verify SDCC build still works after shared source changes
