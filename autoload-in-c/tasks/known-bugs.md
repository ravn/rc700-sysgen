# autoload-in-c known bugs

## 1. C autoload hangs in FDC detect, never hands off to BIOS

**Status:** open as of 2026-05-04.  Hand-assembled `roa375/roa375.rom`
boots rcbios end-to-end; C reimplementation does not.

**Symptom:** with `mame/roms/rc702/roa375.ic66` set to autoload-in-c's
`clang/prom.bin` (padded to 4096 B, install via `make prom`):

  - PROM display at `0x7A00` shows the autoload banner: ` RC700 CL
    2026-04-15 12.15/ravn` (build-date string in `boot_rom.c` is
    hard-coded and stale; not the cause of this bug).
  - BIOS display at `0xF800` stays blank (BIOS never starts).
  - PC stuck in `_fdc_detect_sector_size_and_density` (LMA `0x02D6`
    in PROM 0; VMA `0x626E` in the RAM-relocated `.text`).
  - `mame_boot_test.lua` reports `FAIL: PROM error (see display)`
    after 10 sim-seconds (any non-blank text at `0x7A00` past the
    initial 10s window counts as PROM error per the harness).

**Comparison: hand-assembled `roa375/roa375.rom` (a136b144) WORKS.**
Same disk image, same MAME version, same FDC chip emulation.
Boots through to the BIOS prompt:

```
RC700 56k CP/M 2.2 C-bios/clang 2026-05-04 02:31
SIO-B debugging enabled (38400 8N1)
```

So the bug is in `autoload-in-c/rom.c`'s FDC detection /
initialization path, not in MAME or the disk image.  The function
involved is:

```c
byte fdc_detect_sector_size_and_density(void) {
    is_mfm = 0;
    while (1) {
        if (fdc_select_drive_cylinder_head() != 0) return 1;
        dma_transfer_size = 4;
        if (fdc_get_result_bytes(FDC_READ_ID, 1) == 0) break;
        if (is_mfm) return 1;
        is_mfm = 1; /* switch to MFM and retry */
    }
    fdc_cmd.size_shift = fdc_result.size_code & 0b00000111;
    lookup_sectors_and_gap3_for_current_track();
    calc_size_of_current_track();
    return 0;
}
```

Likely failure modes (not yet diagnosed):

  1. `fdc_select_drive_cylinder_head` (which calls `fdc_seek` →
     `verify_seek_result`) returns non-zero → outer caller loops on
     this function expecting eventual success.
  2. Some interrupt-handler / IM 2 vector setup is wrong, causing
     the FDC interrupt callback to run incorrectly or never.
  3. The DMA / FDC port write sequence diverges from the
     hand-assembled ROA375.

To diagnose: capture a trace of `IN/OUT` to FDC ports (0x04/0x05)
and the FDC interrupt firing, comparing the C version's sequence
to the hand-assembly version's sequence on the same disk image.
MAME has a `-d` debug mode and a `Lua install_read_tap` /
`install_write_tap` API for this (see
`feedback_lua_no_port_reads` memory rule for caveats).

**Workaround:** for any work that needs rcbios standalone MAME
boot (the value-oracle MAME path -- see
`llvm-z80/tasks/lessons-2026-05-04-structural-fix-failures.md`),
install the assembly ROA375 instead:

```
cd rc700-gensmedet/rcbios-in-c && make mame-roms-rcbios
```

This is the working PROM.  Continue using autoload-in-c only for
its own development work (and for now, expect it to hang).

## 2. Banner string is hard-coded and stale

`boot_rom.c` defines:

```c
const char banner_string[] = "RC700 CL 2026-04-15 12.15/ravn";
```

The build date is not auto-generated.  Should be regenerated from
`builddate.h` (parallel to rcbios-in-c's pattern) or removed if
the autoload PROM doesn't need a build date stamp.  Cosmetic, not
a blocker.

## 3. MAME path was wrong (FIXED 2026-05-04)

`MAME = /Users/ravn/git/mame` — pre-workspace-restructuring
location, no longer exists.  Fixed to
`MAME ?= $(CURDIR)/../../mame` in commit `b6c797d` 2026-05-04.
