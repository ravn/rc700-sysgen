# RC702 ROA375 autoload PROM in C

Full rewrite of the ROA375 autoload PROM (boot ROM) in C using z88dk with
sdcc backend.  The ROM initializes hardware, auto-detects floppy disk
format, reads Track 0, and boots the system — tested with CP/M.

See `BOOT_SEQUENCE.md` for the full invocation order from power-on to `A>`.
See `ZSDCC_NOTES.md` for sdcc/z88dk quirks and optimization techniques.

## Current status

PROM size: 1843 bytes (BOOT 104 + CODE 1739) out of 4096 (debug mode).
MAME boot test passes at 100% and 10% speed.
CP/M and ID-COMAL boot verified.

## PROM size history

```
Date        BOOT  CODE  Total  Change  Description
----------  ----  ----  -----  ------  -----------
2026-03-20    68  1987   2055          Starting point (pure C rewrite)
2026-03-21    68  1972   2040    -15   Peephole rules + tail-call fall-through
2026-03-21    68  1914   1982    -58   Remove dead vars, inline crt_refresh
2026-03-21    68  1889   1957    -25   Manual inlining, remove DMA Ch3
2026-03-21    68  1865   1933    -24   Remove fdc_busy + floppy_wait, structs
2026-03-21   104  1800   1904    -29   NMI handler, move functions to BOOT
2026-03-21   104  1785   1889    -15   Format table struct, rename labels
2026-03-21   104  1778   1882     -7   Banner string in BOOT, timestamp
2026-03-21   104  1761   1865    -17   Remove write-only fdc_busy + floppy_wait
2026-03-21   104  1739   1843    -22   Split disk_bits, combined format table
                                ----
                         Total: -212 bytes (-10.3%)
```

Key optimization techniques:
- **Dead variable removal** — variables set but never read (-58 bytes)
- **DMA Ch3 removal** — boot ROM never scrolls, Ch3 unnecessary (-44 bytes)
- **Manual inlining** — sdcc has no inlining; `static inline` leaves dead code (-25 bytes)
- **BOOT section utilization** — fill 0xFF padding before NMI with code + data
- **Peephole rules** — 22 rules from rcbios-in-c (dead code, branch inversion)
- **Tail-call fall-through** — reorder functions so `jp` becomes no-op (-9 bytes)
- **Split packed bitfields** — separate bytes cheaper than bit shifting (-22 bytes)
- **Combined format table** — 3D array `[is_mini][N][side]` vs ternary select (-6 bytes)

## PROM image layout (prom0.ic66 → roa375.ic66)

```
Offset  Size  Section  Source         Contents
------  ----  -------  ------------- ----------------------------------------
0x0000    31  BOOT     boot_rom.c    begin(): DI, SP, memcpy CODE to RAM, JP
0x001F    27  BOOT     boot_rom.c    init_fdc(): FDC Specify command
0x003A    41  BOOT     boot_rom.c    banner_string: " RC700 ROA375 date/user"
0x0063     3  BOOT     boot_rom.c    0xFF padding + RETN (NMI handler at 0x66)
0x0068  1778  CODE     intvec.c      IVT: 16 function pointers (32 bytes)
                       rom.c         All C code: boot, FDC, init, ISRs, fmt
                                     Read-only data: messages, format tables
                                     BSS: variables (zeroed by ROM copy)
                       rom.c         code_end sentinel (1 byte)
0x0802   pad                         0xFF fill to 4096 bytes
```

## Runtime memory map (after self-relocation)

begin() copies CODE from ROM to RAM at 0x7000.  BSS variables are
inside CODE, so they start as zero.  After prom_disable(), Track 0
is loaded at 0x0000 and ROM is no longer accessible.

```
Address         Size   Contents
--------------  -----  -----------------------------------------------
0x0000-0x0CFF   3328   Track 0 data (loaded after PROM disabled)
0x7000-0x701F     32   IVT: interrupt vector table (I=0x70, Z80 IM2)
0x7020-0x76xx  ~1740   C code: boot logic, FDC driver, ISRs, init
                        Read-only data: messages, format tables
                        BSS: boot state variables
                        code_end sentinel
0x7800-0x7F97   1960   Display memory (80×25, Intel 8275 CRT via DMA)
0xBFFF                 Stack top (grows down)
```

## Source files

| File | Section | Description |
|------|---------|-------------|
| `sections.asm` | — | Section ORGs and ordering (linker scaffolding) |
| `boot_rom.c` | BOOT | begin(), init_fdc(), banner_string, NMI handler |
| `intvec.c` | CODE | IVT: const function-pointer array (`#pragma constseg CODE`) |
| `rom.c` | CODE | All CODE-section C: HAL, init, FDC, format, boot, ISRs |
| `rom.h` | — | Types, constants, port I/O macros, struct defs, declarations |
| `peephole.def` | — | 22 custom sdcc peephole optimization rules |
| `CMakeLists.txt` | — | CLion project (indexing only, build via Makefile) |

## Key design decisions

- **Unity build**: `rom.c` is the single CODE translation unit, enabling
  cross-function optimization, tail-call fall-through, and dead code
  elimination.  `intvec.c` is compiled separately — `#pragma constseg`
  is file-global, and IVT must be linked first for 0x7000 placement.

- **BOOT section padding**: Functions only used before `prom_disable()`
  (`init_fdc`) and the banner string are placed in BOOT to fill the
  gap between `begin()` and the NMI handler at 0x66.  Saves total PROM
  size by using space that would otherwise be 0xFF padding.

- **FDC command block struct**: `fdc_command_block` ensures the 7 bytes
  (C, H, R, N, EOT, GPL, DTL) are contiguous.  `fdc_write_full_cmd()`
  sends them via `((byte *)&fdc_cmd)[i]` with `sizeof(fdc_cmd)`.

- **FDC result struct**: `fdc_result_block` with named fields (`.st0`,
  `.st1`, `.st2`, `.cylinder`, `.head`, `.sector`, `.size_code`,
  `.dma_status`) replaces magic array indices.

- **BSS inside CODE**: Variables are in `bss_compiler` subsection of
  CODE.  The PROM contains zeros at these positions.  `begin()` copies
  everything to RAM, so variables start zeroed — no explicit init needed.
  `get_floppy_ready()` only sets non-zero values.

- **No recursion**: All 30+ functions form a pure DAG.  File-scope
  globals are safe.  No stack frames needed (`--fomit-frame-pointer`).

- **Tail-call fall-through**: Functions placed in source order so sdcc's
  `jp _target` becomes a no-op when target immediately follows.  Chains:
  `fdc_select_drive_cylinder_head` → `verify_seek_result`,
  `main` → `get_floppy_ready` → `boot_from_floppy_or_jump_prom1`.

- **Manual inlining**: sdcc's `static inline` leaves dead standalone
  copies (no `--gc-sections`).  Single-call functions are manually
  inlined for size.  See `ZSDCC_NOTES.md`.

- **Binary constants**: All bitmask operations use `0b` notation for
  clarity.  Port initialization values stay hex.

- **Payload size at runtime**: `&code_end - &intvec + 1` computed at
  runtime (8 extra bytes).  DEFC could compute it at link time — noted
  as future optimization.

## Building

```bash
make              # clean + build (default target)
make rom_parts    # build Z80 binary (requires z88dk in ../z88dk)
make prom         # assemble PROM image + install to emulators
make mame         # build, install, boot test in MAME (auto PASS/FAIL)
make rc700        # build and launch rc700 emulator
make clean        # remove build artifacts
```
