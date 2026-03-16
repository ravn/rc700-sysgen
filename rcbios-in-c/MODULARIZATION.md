# C-BIOS Modularization Analysis

Branch: `cbios-modularize` (3 commits, parked)

## Motivation

Split the monolithic `bios.c` (~1300 lines) into modules to enable code
sharing with a future CP/NOS bootstrap BIOS (PROM1) that needs serial and
floppy drivers but not display/keyboard.

## Module structure

| Module | Lines | Contents |
|--------|------:|----------|
| bios.c | 603 | IVT, hw_init, boot/wboot, extended BIOS (LINSEL, EXIT, CLOCK, HRDFMT), CRT ISR, stub ISRs |
| serial.c | 226 | SIO driver, RX ring buffer with RTS flow control, 7 SIO ISRs |
| display.c | 552 | Console output, escape sequences, cursor, scroll, BGSTAR bitmap, keyboard ring buffer, PIO ISR |
| floppy.c | 685 | FDC/DMA driver, blocking/deblocking, all disk BIOS entries, data tables, floppy ISR |

Each module has a matching header (serial.h, display.h, floppy.h).
Shared ISR stack-switch helpers are in isr_helpers.h.

### Cross-module dependencies

- CRT ISR (bios.c) calls `fdstop()` (floppy.c) and reads `cur_dirty` (display.c)
- LINSEL (bios.c) calls `waitd()` (floppy.c)
- hw_init (bios.c) calls `fdc_write()` (floppy.c)
- boot/wboot (bios.c) calls into all three modules
- IVT (bios.c) references ISR function pointers from all four modules

## Size overhead

| Build | Size | Notes |
|-------|-----:|-------|
| Original single-file (b3e80d0) | 5477 bytes | All code in bios.c |
| Unity build (same sources, single TU) | 5486 bytes | `#include` all .c files |
| Modular (separate compilation) | 5600 bytes | 4 object files linked |
| **Overhead** | **+114 bytes (2.1%)** | Still fits MINI with 544 to spare |

### Root cause

All 114 bytes come from sdcc losing cross-module optimization.  With
separate compilation, sdcc cannot:

1. **Inline extern functions** — `keyboard_reset()`, `serial_reset()`,
   `serial_readi()` were `static` and inlined; now they're `extern` calls
2. **Share register state** across functions in different translation units
3. **Eliminate redundant loads** when caller and callee are in different files

A unity build (`#include` all .c files into one TU) recovers the original
size completely, confirming the overhead is purely from separate compilation.

The C-level code changes account for ~15 bytes (new wrapper functions);
the remaining ~100 bytes are less efficient variable access patterns for
`extern` vs `static` variables.

### `--opt-code-speed` experiment

Compiled display.c with `--opt-code-speed` instead of `--opt-code-size`.
Cost 19 extra bytes, zero cycle improvement.  The display hot path
(`scroll`) uses hand-written unrolled 16xLDI (16T/byte vs LDIR's 21T/byte)
which no compiler flag can generate.  Reverted.

## Conclusion

The modularization works correctly (all MAME integration tests pass) and
the 2.1% size overhead is acceptable.  The branch is parked for when
CP/NOS bootstrap work begins and code sharing becomes necessary.
