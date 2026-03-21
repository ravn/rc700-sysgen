# Changelog

## 2026-03-21: Dead variable removal and ISR inlining

### What was done
1. **Remove dead variable `track_size`** — always set to same value as
   `end_of_track`, never read. Saves 13 bytes.

2. **Remove dead variables `sectors_per_track` and `sector_bytes`** — both
   set but never read. Removing `sector_bytes` also eliminated the
   `128 << sector_size_code` computation. Saves 37 bytes.

3. **Inline `crt_refresh()` into `crtint()` ISR** — `crt_refresh` was only
   called from `crtint`. Inlining eliminates CALL+RET overhead. Saves 4 bytes.
   Moved the circular-buffer DMA scrolling documentation into the `crtint`
   comment block.

4. **Attempted removal of `fdc_flag` and `floppy_wait`** — both appear
   write-only in C code. Removal caused MAME boot failure. Restored.
   These variables are needed for correct FDC timing/state even though
   the C code never explicitly reads them.

5. **Documented circular-buffer scrolling** — explained why two DMA channels
   (Ch2+Ch3) are needed: Ch2 transfers from scroll_offset to end of buffer,
   Ch3 wraps around from buffer start. The boot ROM never scrolls
   (scroll_offset stays 0) but sets up the mechanism for the BIOS.

### User choices
- User confirmed BIOS reprograms everything after the boot jump, so
  ROM routines don't need to be preserved for BIOS use. This enabled
  inlining `crt_refresh` and removing its `rom.h` declaration.
- User noted `floppy_wait` may be a state/debugging variable — kept it.
- Investigated loop optimizations — all 14 loops are already optimal.

### Verification
- CODE: 1922 -> 1914 bytes (-8)
- MAME boot test passes

---

## 2026-03-21: Peephole rules and tail-call fall-through optimization

### What was done
Investigated rcbios-in-c optimization techniques (peephole rules, tail-call
fall-through, IX/IY avoidance, sdcc pitfalls) and applied applicable ones
to autoload-in-c.

1. **Copy full peephole.def from rcbios-in-c** (3 rules -> 22 rules):
   - Dead code elimination after unconditional jumps (jp/jr/ret + jp/jr)
   - Redundant `xor a,a` after store to memory (4 variants for spacing)
   - Redundant `xor a,a` after double store
   - Branch inversion (`jr NZ + jp` -> `jp Z`, 4 variants)
   - Tail-call fall-through (`jp label` where label follows, with 0-3 comments)
   - Saves 10 bytes.

2. **Function reordering for tail-call fall-through** (2 pairs):
   - `floppy_seek()` placed before `chk_seekres()` — eliminates `jp _chk_seekres`
   - `preinit()` placed before `fldsk1()` — eliminates `jp _fldsk1`
   - Added forward declarations for reordered static functions.
   - Saves 6 bytes.

3. **Investigated but not applicable**:
   - `fldsk1() -> floppy_boot()`: sdcc inserts error-path `ret` between
     the `jp` and target label, blocking the peephole rule.
   - `recalibrate_verify() -> chk_seekres()`: only one function can
     fall into `chk_seekres`; `floppy_seek` chosen (called more often).

### Verification
- CODE: 1988 -> 1972 bytes (-16 bytes, -0.8%)
- MAME boot test passes

---

## 2026-03-21: Readability overhaul

### What was done
1. **Rename 24 global variables** from cryptic abbreviations to readable
   names (e.g. `fdcres` -> `fdc_result`, `curcyl` -> `current_cylinder`,
   `drvsel` -> `drive_select`, `memadr` -> `dma_addr`, `reptim` -> `retry_count`).
   User specified `current_` prefix instead of `cur_`, and `sectors_per_track`
   for `epts`.

2. **Rename 20 functions** from assembly-era abbreviations to descriptive
   names (e.g. `snsdrv` -> `sense_drive`, `flo4` -> `fdc_recalibrate`,
   `flrtrk` -> `floppy_read_track`, `stpdma` -> `setup_dma`,
   `errdsp` -> `error_display_halt`, `boot7` -> `boot_sysmsysc_or_jp0_or_halt`).
   User specified `wait_floppy_interrupt`, `check_fdc_result`,
   `error_display_halt`, and the full `boot_sysmsysc_or_jp0_or_halt` name.

3. **Documentary comments on all port writes** — PIO control words, CTC
   channel configuration, DMA mode registers, CRT commands, FDC Specify
   parameters all now have inline comments explaining the register values.

4. **Consistent comment formatting** — all inline comments aligned at
   column 42, every function has a block comment above it, consistent
   `/* description */` style throughout, renamed `b7_dir` -> `boot_dir`,
   `sysm`/`sysc` -> `sysm_name`/`sysc_name`, added FDC command block
   start/end markers on variable definitions.

5. **Inline single-use strings** — `msg_nosys`, `msg_nocat`, `msg_nodisk`,
   `msg_diskerr`, `msg_rc700` inlined as string literals at call sites.
   `msg_rc700` in `display_banner_and_start_crt()` replaced with `memcpy`.

6. **memset for clear_screen** — manual loop replaced with
   `memset(dspstr, ' ', 80 * 25)`, saving 2 bytes.

7. **Combined three if/check_prom1 blocks** into one `||` short-circuit
   expression in `fldsk1()`, saving 8 bytes.

8. **Braces on all if bodies** — all single-line if-statement bodies now
   have `{}` braces with the body on a separate line. Saved as a permanent
   coding style rule.

9. **`sector_bytes = 128 << sector_size_code`** — replaced manual shift
   loop with direct expression (+2 bytes but clearer).

10. **Banner text** changed to `" RC700 gensmedet"` (16 chars).

11. **Renamed `dumint` -> `nothing_int`**, `display_banner` ->
    `display_banner_and_start_crt`, `boot_detect` -> `detect_floppy_format`
    (user edits in CLion).

12. **Removed `-L` path** from `-lz80` — z88dk resolves it via `-clib=sdcc_iy`.

13. **TODO_CLION_Z88DK.md** — investigate CLion custom compiler support for z88dk.

### User choices
- `current_` prefix (not `cur_`) for cylinder/head/sector
- `sectors_per_track` for `epts` (confirmed as sector count, not seek limit)
- `wait_floppy_interrupt` (not `wait_floppy`)
- `check_fdc_result` (not `check_result`)
- `error_display_halt` (not `error_display`)
- `boot_sysmsysc_or_jp0_or_halt` — user-specified verbose name
- Inline `msg_rc700` despite 7-byte duplication cost
- Keep `128 << sector_size_code` despite +2 bytes — readability over size
- Always use `{}` braces on if bodies (permanent rule)
- Various renames done directly in CLion (`dumint`, `display_banner`,
  `boot_detect`)

### Verification
- MAME boot test passes at 100% and 10% speed
- CODE size: 1988 bytes (vs 1987 before — +1 from readability changes)

---

## 2026-03-21: Build cleanup and CLion support

### What was done
1. **`ctc_write` macro split** into `ctc0_write`..`ctc3_write` — eliminates
   sdcc warning 126 (unreachable code) from dead if/else branches when the
   channel is a compile-time constant.
2. **Suppress sdcc warning 296** via `--disable-warning 296` (same approach
   as rcbios-in-c). The warning is a false positive when using `--no-crt`
   with `--sdcccall 1`.
3. **Rename build output** from `roa375` to `prom0` — output files are now
   `prom0_BOOT.bin`, `prom0_CODE.bin`, `prom0.ic66`, `prom0.map`. Emulator
   install paths keep the original `roa375` names.
4. **Add `all` target** to Makefile (`all: clean rom`) as default.
5. **CLion/CMake support** — added `CMakeLists.txt` for IDE indexing and
   `#ifndef __SDCC` guards in `rom.h` that stub sdcc keywords (`__sfr`,
   `__at`, `__interrupt`, `__critical`, `__naked`, `__asm__`) and provide
   `extern volatile unsigned char` port declarations plus inline stubs for
   intrinsic functions. Guarded `#include <intrinsic.h>` and
   `#pragma constseg` with `#ifdef __SDCC` in all source files.
6. **`.gitignore`** — added `autoload-in-c/prom0` and `cmake-build-*/`.

### User choices
- User asked to suppress warning 296 the same way as rcbios-in-c
  (`--disable-warning 296`) rather than grep-filtering
- User chose `prom0` as the build output name
- User asked for CLion project support; opened the project and iteratively
  fixed navigation for `boot_rom.c` (missing `intrinsic_di`/`intrinsic_ei`
  stubs) and `intvec.c` (unguarded `#pragma constseg`)

### Verification
- Zero warnings from z88dk build
- Binary output unchanged (68 + 1987 bytes)
- MAME boot test passes

---

## 2026-03-21: Clean up autoload-in-c naming

### What was done
1. **Remove `hal_` prefix** from all functions and macros in `rom.h` and `rom.c`.
   With the HAL abstraction gone (Z80-only build), the prefix is just noise.
   Examples: `hal_fdc_wait_write` → `fdc_wait_write`, `hal_ei` → `ei`,
   `hal_dma_mask` → `dma_mask`.
2. **Rename `boot_entry.c` → `boot_rom.c`** — clearer name for the BOOT-section
   entry point (compiled with `--codeseg BOOT`).

### User choices
- User selected `hal_` in the source and asked to remove the prefix
- User asked to rename `boot_entry.c`

### Verification
- Binary output unchanged (same BOOT/CODE sizes)

---

## 2026-03-20: Remove HOST_TEST abstraction from autoload-in-c

### What was done
Removed the host-native unit testing abstraction (HAL mock + HOST_TEST
`#ifdef` guards) from the autoload-in-c PROM rewrite. This simplifies all
sources for the Z80-only build path and eliminates dead code paths that
added complexity without current value.

**Files deleted:**
- `hal_host.c` — mock HAL implementation for host builds
- `test_boot.c` — host-native boot logic tests
- `test_fdc.c` — host-native FDC driver tests

**Files modified:**
- `hal.h` — removed `#ifdef HOST_TEST` function-declaration block (47 lines),
  kept only Z80 `__sfr` port declarations and `#define` macros
- `boot.h` — removed `dspstr[]`/`scroll_offset` array declarations,
  `mcopy`/`mcmp` declarations, `jump_to` function declaration, and
  `init_pio`/`init_ctc`/`init_dma`/`init_crt` declarations (all test-only)
- `boot.c` — removed 6 HOST_TEST blocks: heap display buffer, `clear_screen`/
  `mcopy`/`mcmp` implementations, guards around `halt_forever`, `check_prom1`,
  `flboot`, and `main()`
- `init.c` — removed 3 HOST_TEST blocks: individual init functions (duplicate
  of `init_peripherals`), guards around `set_i_reg`/`init_relocated`/
  `clear_screen`/`init_fdc`/`display_banner`
- `isr.c` — removed `#ifndef HOST_TEST` guards from ISR definitions
- `code.c` — updated comment (removed "host tests compile individually" note)
- `Makefile` — removed `CC`, `CFLAGS`, `HOST_COMMON`, `test`/`test_boot`/
  `test_fdc` targets; removed `test` from `.PHONY`; kept `CC` for rc700 target
- `CLAUDE.md` — removed `hal_host.c` and `test_boot.c`/`test_fdc.c` from listing

### User choices
- **Remove host testing entirely**: The HAL abstraction and host test harness
  added complexity for limited benefit. The user decided to consolidate all
  sources for maximum sdcc cross-function optimization in the unity build.
- **Keep intvec.c as separate compilation unit**: The plan proposed merging
  intvec.c into code.c, but this was abandoned because the linker requires
  intvec.o to be linked first to place the IVT at address 0x7000 (Z80 IM2
  page-aligned requirement). Including it in the unity build moved the IVT
  after the code, breaking the memory layout.

### Verification
- CODE binary is byte-identical to pre-change reference
- BOOT binary differs only in the 2-byte build timestamp

## 2026-03-20: Consolidate autoload-in-c source files

### What was done
Merged 8 small C files and 2 headers into 2 files (`rom.c` + `rom.h`),
eliminating the unity-build indirection layer (`code.c` including other `.c` files).

**Before (11 C files + 2 headers):**
`hal_z80.c`, `init.c`, `fmt.c`, `fdc.c`, `boot.c`, `isr.c` — included by
`code.c` unity build; `hal.h`, `boot.h` — two headers; `nmi.c` — unused.

**After (3 C files + 1 header):**
- `rom.h` — single header (types, constants, port I/O macros, declarations)
- `rom.c` — all CODE-section source (HAL, init, format, FDC, boot, ISR, sentinel)
- `intvec.c` — IVT (compiled separately, linked first for 0x7000 placement)
- `boot_entry.c` — BOOT section (unchanged, different codeseg)

**Deleted:** `hal.h`, `boot.h`, `hal_z80.c`, `init.c`, `fmt.c`, `fdc.c`,
`boot.c`, `isr.c`, `code.c`, `nmi.c` (10 files)

### User choices
- **Maximum consolidation**: user asked to combine as much as practically
  possible. All CODE-section C goes into one file; only `intvec.c` and
  `boot_entry.c` remain separate due to linker/codeseg constraints.

### Verification
- CODE binary is byte-identical to pre-consolidation build
- BOOT binary differs only in the 2-byte build timestamp

---

## 2026-03-20: Session summary

### What was done
1. **Project rename**: `rc700-sysgen` → `rc700-gensmedet` ("Reforged")
2. **Memory migration**: Found 31 memory files under old `.claude/` project path
   (`-Users-ravn-git-rc700-sysgen`), copied them to the new project path
3. **Documentation migration**: Moved 20 project knowledge files from `.claude/`
   memory into the git repo (`rcbios/`, `cpnet/`, `docs/`)
4. **Fix stale reference**: `tasks/todo.md` referenced moved file
   `memory/bgstar_analysis.md` → updated to `rcbios/BGSTAR_ANALYSIS.md`
5. **Session protocol**: Added feedback memory to always read `AGENT.md` at
   session start

### User choices
- **Keep feedback in `.claude/`**: 7 behavioral feedback files (merge policy,
  build flags, compiler testing, MAME build, MP/M server, BIOS calling
  convention) stay in `.claude/` memory — they guide Claude Code behavior
  across sessions, not project documentation
- **Move knowledge to git**: All factual project documentation (BIOS analysis,
  optimization plans, emulator notes, protocol specs, etc.) goes into the
  git repo where it is version-controlled and tool-independent
- **Always read AGENT.md**: Claude Code must read `AGENT.md` and
  `tasks/lessons.md` at the start of every session
- **Summarize before commit**: When preparing to commit, always summarize
  work and choices in the project first

---

## 2026-03-20: Project rename and documentation migration

Renamed repository from `rc700-sysgen` to `rc700-gensmedet` ("Reforged").

### Documentation migration from Claude Code memory to git

Project knowledge that was previously stored only in Claude Code's
`.claude/` memory files has been moved into the git repository so it
is version-controlled and accessible without Claude Code.

**Decision**: The user chose to keep cross-session behavioral feedback
(7 files covering merge policy, build flags, compiler testing practices,
etc.) in `.claude/` memory where they guide Claude Code's behavior.
All factual project documentation was moved into the repo.

#### Files added to `rcbios/`
- `BIOS_COMPARISON.md` — 13 BIOSes from 20 disk images, 4 families compared
- `CONOUT_OPTIMIZATION.md` — REL30 display driver timing analysis (716T→562T, 21% faster)
- `RC702E_BIOS.md` — RC702E source structure, variants, work area map
- `RC703_BIOS.md` — RC703 BIOS analysis, ROB357 PROM, Track 0 formats
- `REL30_IMPROVEMENTS.md` — parked optimization opportunities (~767 bytes recoverable)
- `REL30_SERIAL.md` — SIO ring buffer with RTS flow control, 38400 baud verified

#### Files added to `cpnet/`
- `SERIAL_PROTOCOLS.md` — DRI/ASCII/z80pack protocol comparison
- `CPNOS_SIZING.md` — diskless boot client component sizes

#### Files added to `docs/`
- `COMAL80.md` — COMAL80 on RC702 (hello world verified, command reference)
- `CPM_SOURCES.md` — CP/M PL/M and ASM source locations
- `CPM_USERS_GUIDE_NOTES.md` — full notes from RCSL No 42-i2190 user's guide
- `EMULATOR_FTP.md` — rc700 emulator FTP device protocol and Pascal utilities
- `EMULATOR_MONITOR.md` — rc700 emulator Z80SIM monitor command reference
- `KRYOFLUX.md` — KryoFlux DTC usage, RC702 format limitations
- `MAME_GDB_STUB.md` — MAME GDB RSP debugging setup and quirks
- `MAME_RC702.md` — MAME RC702 emulation: build, variants, fixes, test automation
- `SDCC_PITFALLS.md` — sdcc/z88dk pitfalls for Z80 embedded C
- `TAIL_CALL_OPTIMIZATION.md` — peephole rules for fall-through tail calls
- `VERIFY_ANALYSIS.md` — VERIFY.MAC/VERIFY.COM relationship analysis
