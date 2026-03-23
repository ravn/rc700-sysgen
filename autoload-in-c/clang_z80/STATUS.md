# Clang Z80 PROM Build Status

## What Works
- rom.c compiles with `clang --target=z80 -Os` (dual-compatible with SDCC)
- Full PROM builds: boot.s + intvec.c + rom.c + runtime.s → 2914/4096 bytes
- Self-relocation (LDIR from ROM to RAM) works
- All peripheral initialization (PIO, CTC, DMA, CRT) produces correct port values
- CRT displays banner "RC700 ROA375 clang-z80 /ravn" and error messages
- Interrupt vector table at I=0x60 works
- CRT DMA 50Hz ISR fires and programs DMA correctly
- Floppy boot sequence runs (FDC Specify, Sense Drive, Recalibrate, Read ID)
- `delay()` uses inline asm djnz matching SDCC timing (13 T/iter)
- `__attribute__((interrupt))` generates correct ISR save/restore + reti

## Known Issue: Display Disappears After ~0.1 Seconds

The CRT display appears briefly then goes blank (orange with cursor).
The display buffer at 0x7A00 retains correct data throughout.
The SDCC build shows the display stably in the same error scenario.

### Root Cause (narrowed down)
- IFF1 was found to be 0 (interrupts disabled) at the halt point
- Added `ei()` to `halt_forever()` — display appears but then disappears
- Floppy completion ISR (`floppy_completed_operation_interrupt`) fires during
  the boot sequence and blocks the CRT ISR with its delay() call
- Added `ctc3_write(0x03)` to disable floppy interrupts in halt_forever
- Display still disappears — the corruption happens DURING the boot sequence,
  before halt_forever runs

### Suspected Issues
1. **Floppy ISR blocks CRT ISR too long**: The floppy ISR calls delay() and
   FDC functions. While it runs, no CRT refresh happens. If the CRT
   controller loses sync or enters an error state, it may stop requesting
   DMA transfers permanently.

2. **Compiler-generated code may be wrong**: The user warned the compiler
   may be broken. Verify all generated code, especially:
   - Function calls from ISRs (delay, fdc_sense_interrupt, fdc_read_result)
   - Register save/restore in ISRs (the floppy ISR uses IX frame + saves
     AF/BC/DE/HL/IY, but verify nothing is corrupted)
   - Port writes from within ISRs (verify all "out (port),a" have correct
     A values)

### Next Steps
1. Use MAME debug build (`+d`) or gdbstub to trace ISR execution
2. Compare port I/O trace between SDCC and clang builds
3. Check if the floppy ISR corrupts DMA ch2 state (the ISR reads
   `dma_status` via `in a,($f8)` which might affect the DMA controller)
4. Try disabling the floppy ISR entirely (set IVT entry [7] to nothing_int)
   to see if the display stays stable without it
5. Verify all compiler-generated register loads before port writes are correct

## LLVM-Z80 Compiler Bugs Found

### Fixed
1. **address_space(2) not legalized** (ravn/llvm-z80#1) — fixed, IN/OUT work
2. **G_CONSTANT with P2 type not legalized** — fixed (folded inttoptr(0))

### Workarounds Applied
3. **Port_out functions lose `ret` when constant-propagated** (ravn/llvm-z80#3 TODO)
   — workaround: `always_inline` on DEFPORT functions
4. **Argument A not loaded for value 0 in non-inlined port_out calls**
   — workaround: same `always_inline` fix
5. **"hl" inline asm constraint crashes IRTranslator** (ravn/llvm-z80#2)
   — workaround: use macro with stringified immediate for `ld sp`

### TODO
- File issue #3 for the missing-ret / argument-not-loaded bugs
- Reduce ISR code size overhead (port I/O calls, IX frame setup)

## Build Commands
```bash
make clang         # build PROM
make clang_prom    # build + install to MAME and RC700 emulator
make clang_asm     # show assembly output
make clang_disasm  # disassemble linked ELF
make clang_clean   # remove build artifacts
```

## File Layout
- `boot.s` — BOOT section (entry, init_fdc, banner, NMI) — hand-written asm
- `runtime.s` — memcpy, memset, __call_iy — hand-written asm
- `rc700_prom.ld` — linker script (BOOT at 0x0000, CODE at 0x6000)
- `string.h`, `intrinsic.h` — freestanding header stubs
