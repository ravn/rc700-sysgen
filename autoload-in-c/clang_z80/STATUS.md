# Clang Z80 PROM Build Status

## Current: Display Stable, FDC Interrupt Not Firing

PROM: 2953/4096 bytes. Display stable at 0x7A00. Banner with timestamp.
Floppy boot fails — `floppy_operation_completed_flag` never set by ISR.

## What Works
- CRT display stable (pre-programmed DMA + ISR refresh)
- BSS zeroed correctly after self-relocation
- delay() timing matches SDCC (djnz 13T/iter, L constraint for inner param)
- Port I/O via always_inline asm
- All init_peripherals port values verified correct
- IVT verified correct (CTC ch2→CRT ISR, CTC ch3→floppy ISR)

## Root Cause of Floppy Boot Failure

The floppy ISR (CTC ch3) never fires. `floppy_operation_completed_flag`
stays 0. The FDC sends a Sense Drive command and gets a response (the
code reaches fdc_read_when_ready), then sends Recalibrate and waits for
the interrupt — which never comes.

Possible causes:
1. The FDC command bytes aren't being sent correctly (fdc_write_when_ready
   uses `xor 0x80; cp` instead of SDCC's `bit 7,a; bit 6,a` — logically
   equivalent but check with debugger)
2. The FDC completes but the interrupt signal doesn't reach CTC ch3
   (DMA ch1 not configured yet? timing issue?)
3. Something in the clang-compiled code corrupts CTC ch3 state

## Next Steps
- Use MAME gdbstub or debug build to trace FDC port writes
- Compare exact FDC command/response sequence between SDCC and clang
- Set breakpoint at fdc_write_when_ready to verify each byte sent
- Check CTC ch3 state after init_peripherals

## Build: `make clang` / `make clang_prom`
