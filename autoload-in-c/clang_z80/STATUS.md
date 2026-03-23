# Clang Z80 PROM Build Status

## Current State: Display Stable, Floppy Boot Fails

The clang-built PROM boots in MAME, displays banner with timestamp and
error message stably. Floppy boot fails (disk not detected). CP/M does
not load. The SDCC build boots to CP/M successfully with the same floppy.

## What Works
- Full PROM builds: 2939/4096 bytes (72% full)
- Self-relocation from ROM to RAM
- All peripheral init (PIO, CTC, DMA, CRT) — correct port values verified
- CRT display with DMA autoinitialize — stable, persistent
- Banner with build timestamp: "RC700 ROA375 2026-03-23 HH.MM/user"
- Error message: "**NO DISKETTE NOR LINEPROG**"
- ISR: CRT DMA 50Hz refresh works, floppy completion ISR works
- delay() via inline asm djnz matching SDCC timing (13 T/iter)
- Port I/O via always_inline asm (workaround for compiler bugs)
- `__attribute__((interrupt))` generates correct ISR save/restore + reti

## Known Issues

### 1. Display shows in middle of screen (cosmetic)
DMA autoinitialize restarts the transfer continuously without ISR
resync, so the CRT frame boundary doesn't align with the display
buffer start. The ISR resyncs on each vertical retrace, but during
the floppy boot's di sections, the ISR can't fire and the DMA
auto-restarts at an offset.

### 2. Floppy boot fails
The FDC polling and DMA transfer code runs but doesn't successfully
read the disk. Likely caused by timing differences in the FDC
driver — the clang code is larger and slower, and the di/ei windows
differ from SDCC. Needs investigation with MAME debugger/gdbstub.

### 3. LLVM-Z80 compiler bugs (workarounds applied)
- Port_out functions lose `ret` when constant-propagated (ravn/llvm-z80#3 TODO)
- Argument A not loaded for value 0 in non-inlined port_out calls
- Both workarounded via `always_inline` on DEFPORT functions
- `"hl"` inline asm constraint crashes IRTranslator (ravn/llvm-z80#2)

## Build
```bash
make clang         # build PROM
make clang_prom    # build + install to MAME/RC700
make clang_clean   # clean
```

## Key Decisions
- IVT at 0x6000 (I=0x60) — code at 0x6000 leaves room before display at 0x7A00
- DMA ch2 autoinitialize (mode 0x5A) — keeps display stable during di sections
- Pre-program DMA ch2 before CRT Start Display — first frame renders immediately
- Inline asm port I/O with always_inline — avoids compiler constant propagation bugs
- Inline asm delay with djnz — matches SDCC timing exactly
- halt_forever disables CTC ch3 + masks DMA ch1 + enables interrupts
