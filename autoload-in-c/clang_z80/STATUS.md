# Clang Z80 PROM Build Status

## Current: CP/M Boots Successfully

PROM: 3248/4096 bytes (79% full). CP/M boots in MAME in 5.5s emulated.
Both SDCC and clang builds boot from the same rom.c/rom.h source.

## What Works
- Full CP/M boot: "RC700 56k CP/M vers.2.2 rel. 2.3 A>"
- CRT display stable with ISR-driven DMA refresh at 50Hz
- Floppy disk read: Sense Drive, Recalibrate, format detection, track read
- All peripheral init: PIO, CTC, DMA, CRT — verified identical port values
- Interrupt handlers: EI;RETI epilogue, callee-save registers
- delay() via C with __asm__ volatile("") barrier
- Port I/O via inline asm (inlined at all call sites by -Os)
- BSS zeroed after self-relocation
- Banner with build timestamp

## LLVM-Z80 Backend Fixes Made

### Committed to ravn/llvm-z80 (main branch)
1. **address_space(2) port I/O** (0ff2114) — G_LOAD/G_STORE from addrspace 2 → IN/OUT
2. **Folded pointer constants** (0d71a91) — G_CONSTANT with type p2 for port address 0
3. **Register pair asm constraints** (d32e77a) — bc/de/hl/af/ix/iy/sp in inline asm
4. **EI before RETI** (4a07a09) — Z80 ISR epilogue emits EI immediately before RETI,
   after all register restores; atomic via Z80 delayed EI semantics

### Issues
- [#1](https://github.com/ravn/llvm-z80/issues/1) address_space(2) crash — fixed
- [#2](https://github.com/ravn/llvm-z80/issues/2) "hl" inline asm constraint crash — partial (constraint registered, IRTranslator limitation)
- [#3](https://github.com/ravn/llvm-z80/issues/3) Missing EI before RETI — fixed
- [#4](https://github.com/ravn/llvm-z80/issues/4) __critical equivalent — open

### Port I/O approach
The PROM uses inline asm for port I/O (`__asm__ volatile("out (N), a" : : "a"(val))`).
This is preferred over `address_space(2)` because:
- Always inlined at call sites (optimal 2-byte IN/OUT)
- No `always_inline` attribute needed — `-Os` inlines the small functions
- Avoids an address_space(2) code generation bug where IPSCCP corrupts
  non-inlined port_out functions (removes `ret`, drops argument loads)

## Build
```bash
make clang         # build PROM
make clang_prom    # build + install to MAME/RC700
make clang_asm     # show assembly
make clang_clean   # clean
```
