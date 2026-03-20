# RC702 Autoload PROM in C

Rewrite of the ROA375 autoload PROM (boot ROM) in C using z88dk with
sdcc backend.  The ROM initializes hardware, auto-detects floppy disk
format, reads Track 0, and boots CP/M.

Only assembly remaining: `sections.asm` (21 lines of section ORG
declarations — no code, no data, no symbols).  Everything else is C.

## PROM image layout (roa375.ic66)

```
Offset  Size  Section  Source          Contents
------  ----  -------  ------------   ----------------------------------------
0x0000    31  BOOT     boot_entry.c   begin(): DI, SP, memcpy relocation, JP
0x001F    37  BOOT     boot_entry.c   Build timestamp (ASCII, never executed)
0x0044  1987  CODE     intvec.c       IVT: 16 function pointers (32 bytes)
                       code.c         All C code: boot, FDC, init, ISRs, fmt
                                      Read-only data: messages, format tables
                                      BSS: individual variables (zeroed by copy)
                       code.c         code_end sentinel (1 byte)
0x0807   pad                          0xFF fill to image size
```

Image size: 4096 bytes (2732 EPROM, debug mode).
Used: ~2055 / 4096 bytes.

TODO: Revert to 2048 bytes (2716 EPROM) for release.  Requires
reverting Makefile pad size and MAME rc702.cpp ROM_LOAD size + PROMCFG
default.  Should be tested on physical hardware before switching back.

## Runtime memory map (after self-relocation to RAM)

begin() copies the CODE section from ROM to RAM at 0x7000 via memcpy.
BSS variables are inside CODE, so they start as zero after copy.
After relocation, the PROM is disabled and Track 0 is loaded at 0x0000.

```
Address         Size   Contents
--------------  -----  -----------------------------------------------
0x0000-0x0CFF   3328   Track 0 data (loaded after PROM disabled)
0x7000-0x701F     32   IVT: interrupt vector table (I=0x70, Z80 IM2)
0x7020-0x77xx  ~1700   C code: boot logic, FDC driver, ISRs, init
                        Read-only data: messages, format tables
                        BSS: boot state variables (zeroed by ROM copy)
                        code_end sentinel
0x7800-0x7BCF   1488   Display memory (80×24, Intel 8275 CRT DMA)
0xBFFF                 Stack top (grows down)
```

## Source files

| File | Section | Description |
|------|---------|-------------|
| sections.asm | — | Section ORGs and ordering (linker scaffolding only) |
| boot_entry.c | BOOT | begin(): memcpy self-relocation + build timestamp |
| intvec.c | CODE | IVT: const function-pointer array (#pragma constseg CODE) |
| code.c | CODE | Unity build of all C code (cross-function optimization) |
| boot.c | CODE | Boot logic: signature check, directory scan, disk read |
| fdc.c | CODE | FDC driver: seek, read, sense, result handling |
| fmt.c | CODE | Disk format tables and track geometry |
| init.c | CODE | Peripheral init (PIO, CTC, DMA, CRT, FDC) + clear_screen, display_banner |
| isr.c | CODE | ISR bodies: CRT refresh, floppy interrupt, dummy |
| hal.h | — | Hardware abstraction: __sfr ports, intrinsic_di/ei |
| boot.h | — | Boot state variables, constants, function declarations |
| hal_z80.c | CODE | C implementations of HAL functions (hal_delay, FDC wait) |
| hal_host.c | — | Mock HAL for host-native testing |
| test_boot.c | — | Host tests for boot logic |
| test_fdc.c | — | Host tests for FDC driver |

## Key design decisions

- **intvec.c compiled separately**: `#pragma constseg CODE` is file-global.
  In the unity build, sdcc emits code before const data, pushing the IVT
  past the 0x7000 page boundary.  Separate compilation + link order
  (intvec.o first) guarantees the IVT is at 0x7000.

- **BSS inside CODE**: Boot state variables are in bss_compiler, which is
  a subsection of CODE (declared after rodata_compiler in sections.asm).
  The PROM contains zeros at these positions.  begin() copies the entire
  CODE section to RAM, so variables start at zero — no explicit zeroing
  needed.  preinit() only sets non-zero initial values (fdctmo, fdcwai, etc).

- **Individual globals, not a struct**: g_state struct was dissolved into
  individual variables.  sdcc generates direct absolute addressing
  (`ld a, (_varname)`) instead of base+offset, producing smaller code.
  No recursion in the call graph (verified: 45 functions, pure DAG), so
  file-scope globals are safe.

- **FDC command block contiguity**: curcyl through dtl (7 bytes) must be
  contiguous — flrtrk() sends them sequentially to the FDC.  They are
  defined consecutively in boot.c.  Do not reorder or insert between them.

- **readtk_cmd as global**: The `cmd` parameter in `readtk()` is stored in
  a file-scope global to avoid IX frame pointer usage.

- **waitfl timing**: `hal_delay(1,4)` per iteration, 255 iterations max.
  Compile-time static assert verifies total timeout >= 400ms (two FM
  revolutions at 360 RPM).  The original assembly DELAY used a 16-bit HL
  loop; hal_delay uses DJNZ — parameters adjusted to match within 8%.

- **Payload size at runtime**: `&code_end - &intvec + 1` is computed at
  runtime in begin() (8 extra bytes).  No way found to make the linker
  compute it without assembly code (DEFC).

## Building

```bash
make test    # host-native tests (18 tests)
make rom     # build Z80 binary (requires z88dk in ../z88dk)
make prom    # assemble PROM image (roa375.ic66) + install
make mame    # build, install, boot test in MAME (auto-exit PASS/FAIL)
make rc700   # build and launch rc700 emulator
make clean   # remove build artifacts
```
