# Changelog

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
