# Plan: Standalone BIOS Binary

## Goal

Compile the BIOS as a standalone binary at 0xDA00, separate from the
boot loader.  The BIOS is a pure C program that can be compiled,
tested, and analyzed independently.  A separate loader wraps it for
disk installation.

## Proven: Standalone compilation works

Tested: bios.c + bios_page.c compile to a standalone binary with:

```
zcc +z80 -clib=sdcc_iy --no-crt --opt-code-size -SO3 \
    -pragma-define:CRT_ORG_CODE=0xDA00 \
    -Cz"--org 0xDA00" \
    -lz80 -create-app \
    -o bios_standalone layout.asm bios.c bios_page.o
```

Output: `bios_standalone_BIOS.bin` = 6353 bytes (includes BSS gap).
Trimmed to BSS head: **4835 bytes** of code+data at 0xDA00-0xECE3.

## Architecture

```
 STANDALONE BIOS (compile once)          LOADER (separate build)
 ─────────────────────────────          ─────────────────────────
 bios.c        → code_compiler          boot_block.c  → BOOT
 bios_page.c   → BIOS (JP table)        boot_confi.c  → BOOT_DATA
 bios.h, hal.h → headers                boot_entry.c  → BOOT_CODE
 layout.asm    → section ordering
                                         Loader reads bios_core.bin
 Output: bios_core.bin (4835 bytes)      and appends it to produce
         at runtime address 0xDA00       the disk image (bios.cim)
```

## Disk image assembly

The loader produces the Track 0 disk image:

```
Offset  Source                  Contents
0x0000  boot_block.c            Boot header (128 bytes)
0x0080  boot_confi.c            CONFI + conversion tables (512 bytes)
0x0280  boot_entry.c            coldboot() + relocate_bios() (~80 bytes)
0x02CE  bios_core.bin           BIOS binary (4835 bytes, copied to 0xDA00)
```

coldboot() copies bios_core.bin from physical offset 0x02CE to runtime
address 0xDA00.  This is exactly what it does now — the change is that
the BIOS binary is compiled separately and concatenated by the Makefile
rather than linked in one step.

## Benefits

1. **Clean separation**: BIOS is a self-contained C program.  No boot
   code, no config data, no relocation logic in the same compilation.
2. **Independent testing**: The BIOS binary can be loaded into MAME
   directly at 0xDA00 for debugging without needing a bootable disk.
3. **Reusable loader**: The boot loader becomes a generic tool that
   wraps any BIOS binary for disk installation.
4. **Faster iteration**: Changing bios.c only rebuilds the BIOS, not
   the boot sector.

## Using z88dk CRT (without --no-crt)

The classic z80 CRT (`z80_crt0.asm`) supports `CRT_INCLUDE_PREAMBLE`
— a hook that includes `crt_preamble.asm` at the origin address,
BEFORE the `start:` label.  This is where the JP table goes:

```
org 0xDA00        ← CRT_ORG_CODE
JP table (113B)   ← crt_preamble.asm (= bios_page data)
start:            ← CRT init: SP, BSS zero, heap, interrupts
call _main        ← calls bios_boot_c (renamed to main)
```

The bios_boot JP entry jumps directly to `start:` (CRT init).
All other JP entries jump to their normal functions.

Benefits of using the CRT:
- BSS zeroing handled by CRT (eliminates our manual LDIR)
- Library support (memcpy, memset, intrinsics all link)
- `atexit()` support if needed
- Standard program structure with `main()`

To enable: `-pragma-define:CRT_INCLUDE_PREAMBLE=1` and provide
`crt_preamble.asm` in the include path containing the JP table data.

### Loader dependencies on BIOS

The loader (boot_entry.c) needs these values from the BIOS build:

| Value | Current source | Standalone approach |
|-------|---------------|---------------------|
| BIOS physical offset | `_BOOT_CODE_tail` (linker) | Known from BOOT size |
| Code+data size | `_bss_compiler_head - BIOS_BASE` (linker) | From BIOS .map or file size |
| BSS address | `_bss_compiler_head` (linker) | From BIOS .map |
| BSS size | `_bss_compiler_size` (linker) | From BIOS .map |

With CRT: the CRT handles BSS zeroing, so the loader only needs to
know the BIOS binary size (for LDIR copy).  BSS address/size are no
longer the loader's concern.

## Constraints

- **bios.c depends on CONFI data at CFG_ADDR (0xD500)**: The loader
  must copy CONFI defaults there before jumping to BIOS.  This is an
  implicit contract, not a link-time dependency.
- **Conversion tables at CONV_ADDR (0xF680)**: Same — loader copies.
- **IVT at 0xF600**: BIOS initializes this itself (setup_ivt).
- **JP table at 0xDA00**: Via CRT_INCLUDE_PREAMBLE in preamble.asm.

## Implementation

### Phase 1: Split the Makefile

Add a `bios-core` target that compiles bios.c + bios_page.c into
bios_core.bin (trimmed at BSS head).  The existing `bios` target
calls `bios-core`, then compiles the loader and concatenates.

### Phase 2: Separate loader

The loader (boot_block + boot_confi + boot_entry) becomes independent.
It reads bios_core.bin size to calculate relocation parameters.
coldboot() uses the size to know how many bytes to LDIR.

### Phase 3: Independent builds

bios_core.bin can be built without the loader.  The loader can wrap
any bios_core.bin.  Different CONFI configs or language tables can
be combined with the same BIOS binary.
