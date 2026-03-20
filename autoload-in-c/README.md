# RC702 Autoload PROM in C

Rewrite of the ROA375 autoload PROM (2048-byte boot ROM) in C using
z88dk.  The ROM initializes hardware, auto-detects floppy disk format,
reads Track 0, and boots CP/M.

2026-03-20:  Claude converted as much as it could (plus a little bit more) to C.  Still pending moving BEGIN and INTVEC to C.


## PROM image layout (roa375.ic66, 2048 bytes)

```
Offset  Size   Section  Source          Contents
------  -----  -------  ------------    -----------------------------------------
0x0000     92  BOOT     crt0.asm        Entry: DI, SP, LDIR self-relocation
                        boot_entry.c    clear_screen, init_fdc, display_banner
0x005C     10  (gap)                    0xFF fill to NMI vector
0x0066      2  NMI      nmi.c           nmi_noop (RETN)
0x0068   1855  CODE     crt0.asm        INTVEC (32B), INIT_RELOCATED, ISR wrappers
                        rom_all.c       Boot logic, FDC driver, format tables,
                                        ISR bodies, peripheral init, messages
0x07A7     89  (pad)                    0xFF fill to 2048
```

Used: 1959 / 2048 bytes (89 spare).

## Runtime memory map (after self-relocation to RAM)

The ROM entry (BEGIN) copies the entire PROM from 0x0000 to RAM at
0x6F98 via LDIR, so CODE lands at 0x7000 (page-aligned for Z80 IM2).
After relocation, the PROM is disabled and Track 0 is loaded at 0x0000.

```
Address         Size   Contents
──────────────  ─────  ──────────────────────────────────────────────
0x0000-0x6F97          Available (Track 0 loaded here after PROM off)
0x6F98-0x6FFF    104   Relocated BOOT + gap + NMI (init-only)
0x7000-0x701F     32   INTVEC: interrupt vector table (I=0x70, IM2)
0x7020-0x773E   1823   ISR wrappers + C code (boot, FDC, init, ISRs)
0x7800-0x7B7F   1920   Display memory (80×24, 8275 CRT DMA)
0x8000+                BSS (uninitialized variables)
0xBF00             72   g_state (boot_state_t at fixed address)
0xBFFF                  Stack top (set by ROM, grows down)
```

## Source files

| File | Section | Description |
|------|---------|-------------|
| crt0.asm | BOOT+CODE | Entry stub, INTVEC, ISR wrappers, halt/jump helpers |
| boot_entry.c | BOOT | Early init: clear screen, FDC specify, banner |
| nmi.c | NMI | NMI handler stub (RETN) |
| rom_all.c | CODE | Unity build of all C code (cross-function optimization) |
| boot.c | CODE | Boot logic: signature check, directory scan, disk read |
| fdc.c | CODE | FDC driver: seek, read, sense, result handling |
| fmt.c | CODE | Disk format tables and track geometry |
| init.c | CODE | Peripheral initialization (PIO, CTC, DMA, CRT) |
| isr.c | CODE | ISR bodies: CRT refresh, floppy interrupt |
| hal.h | — | Hardware abstraction: __sfr ports, intrinsic_di/ei |
| boot.h | — | Boot state struct, constants, function declarations |
| hal_host.c | — | Mock HAL for host-native testing |
| test_boot.c | — | Host tests for boot logic |
| test_fdc.c | — | Host tests for FDC driver |

## Building

```bash
make rom     # build PROM binary (roa375_*.bin)
make prom    # assemble 2048-byte image (roa375.ic66) + install
make mame    # build and launch MAME with debug
make rc700   # build and launch rc700 emulator
make test    # host-native tests
make clean   # remove build artifacts
```

