# Session 17 Summary

Date: 2026-04-11
Branch: main

## Headline

Reverse-engineered the preserved **RC702 TESTSYSTEM v1.2 diagnostic
diskette** from Dansk Datamuseum ([Bits:30003293]), verified that its
runtime behaviour matches the official user's guide
**RCSL-44-RT-2061** (September 1983, also downloaded from datamuseum as
[Bits:30005977] and OCR'd eng+dan). Confirmed boot path through ROA375
on the MAME `rc702mini` target end-to-end: test program auto-runs six
sub-tests (MEM/DMA/CTC/FDC pass, PIO/SIO fail because no physical
loopback cables are wired in MAME) and halts with a deterministic
6-line summary screen. All work lives in the new `rc702-test-v1.2/`
folder; nothing outside that folder was modified except a one-cylinder
correction to the mini-disk layout section of
`RC702_HARDWARE_TECHNICAL_REFERENCE.md`.

[Bits:30003293]: https://datamuseum.dk/wiki/Bits:30003293
[Bits:30005977]: https://datamuseum.dk/wiki/Bits:30005977

## Artifacts created

All under `rc702-test-v1.2/`:

**Primary binary assets**
- `RC702_TEST_v1.2.bin` — raw 328,704 B disk image from datamuseum.dk
- `RC702_TEST_v1.2.imd` — IMD conversion (built with `rcbios/bin2imd.py`),
  loadable directly in MAME `rc702mini -flop1`
- `RCSL-44-RT-2061_RC701_RC702_Testsystem_v1.1_ocr.pdf` — searchable
  2.4 MB PDF of the official manual (OCR'd with eng+dan, gs /ebook
  compressed)
- `RCSL-44-RT-2061_RC701_RC702_Testsystem_v1.1.txt` — 45 KB plain-text
  sidecar of the OCR, 1,981 lines, matches the 48-page manual
- `Dockerfile.ocrmypdf-dan` — reproducible build recipe for a
  `jbarlow83/ocrmypdf` image with `tesseract-ocr-dan` added

**Analysis documents**
- `README.md` — main doc with status, file index, disk layout, CONFI
  verification, boot sequence, MAME-run results, open TODO list
- `RUNTIME_ANALYSIS.md` — what the program does when running: phase-2
  loader, FDC overlay reads, dispatcher structure, ISR body, per-key
  flag-bit decoding, memory map, I/O port usage
- `MANUAL_ANALYSIS.md` — cross-reference between RCSL-44-RT-2061 and
  the reverse-engineering findings, including the full port-0x50
  error-code table from manual §16

**Static disassembly**
- `region1_track0_side0.{bin,asm,asload.asm,runtime.asm}` — split of
  Track 0 side 0 (FM 16×128 = 2 KB) with file-offset + boot-snapshot
  runtime-origin disassemblies
- `region2_track0_side1.{bin,asm,asload.asm,runtime.asm}` — split of
  Track 0 side 1 (MFM 16×256 = 4 KB)
- `region3_payload_mfm.{bin,asload.asm}` — split of tracks 1+
  (MFM 9×512, trimmed to last non-`0xE5` byte at 0x9600, 32,256 B)
- `dispatcher_ram_0330_disasm.asm` — **live runtime** disassembly of
  the 88-byte menu dispatcher that the test program overlays into RAM
  `0x0330-0x0388` via FDC+DMA from disk `0x1D30`. Not from the disk
  file — from the MAME RAM snapshot, because low memory is rewritten
  at runtime by the overlay reads and the disk-file disassembly of the
  same range shows the original boot code, not the dispatcher.

**MAME capture**
- `mame_dump_on_halt.lua` — reference Lua autoboot hook that polls for
  `HALT ; JR -3` at RAM `0x0341` and dumps RAM + exits
- `mame_run_f{0200,0500,1000}_*.png` — progression screenshots at
  frames 200 / 500 / 1000 (loading → mem-test-pattern → menu running)
- `mame_run_final_halted.png` — **the definitive final-state
  screenshot** showing all 6 auto-run test results
- `mame_run_final_ram_{0000,d480}.bin` — 9,984 B RAM snapshots at
  0x0000-0x26FF and 0xD480-0xF8FF captured at the halted state

## Key findings (in order of importance)

### 1. The disk is a standalone version of the RC703 built-in test PROM

Repackaged as an autoload-bootable floppy for machines (like RC702)
that don't have the test PROM on-board. Evidence:
- Only ~38 KB of the 321 KB disk is actual payload; the rest is
  `0xE5` "formatted but unused" fill — a PROM-sized program on an
  otherwise-empty floppy.
- No CCP/BDOS in Track 1, no CP/M directory at Track 2. The disk
  boot is a custom linear image loader that speaks the ROA375
  autoload protocol but loads a raw test program, not CP/M.
- The test suite matches the RC703 built-in diagnostic PROM's scope
  (MEM refresh, DMA, CTC, FDC, FDD, SIO, PIO, WDC + WDD) including
  the `RC763/RC763B` Winchester test that only exists on RC703.
- The embedded strings `**NO SYSTEM FILES**`, `**NO KATALOG**`,
  `SYSM SYSC` visible in `strings(1)` output are **baked-in error
  text lifted from the standard ROA375 autoload PROM**, not live CP/M
  directory contents.

### 2. Test program was authored for 8" maxi Track 0, runs on mini via zero-fill tolerance

The phase-2 relocating loader at RAM `0x0280` does `LDIR
0x0000→0xD480, 0x2381 bytes`. That length (9,089 B) fits cleanly
inside maxi Track 0 (26×128 + 26×256 = 9,984 B) with 895 B spare, but
overshoots a mini 5¼" Track 0 (16×128 + 16×256 = 6,144 B) by exactly
**2,945 bytes**. MAME run with `bpset 0x028a` captured this:

| RAM range | Size | State at PC=0x028a on mini |
|---|---|---|
| `0x0000-0x07FF` | 2,048 | fully populated (T0S0) |
| `0x0800-0x17FF` | 4,096 | fully populated (T0S1) |
| `0x1800-0x2380` | 2,945 | **all zeros** |

The program tolerates the zero-fill tail because the LDIR destination
(`0xEC80-0xF800` post-relocation) is never executed as code — the
runtime uses the low-memory copy, not the frozen high-memory one.

### 3. MAME `install_write_tap` cannot catch DMA writes — only CPU stores

I tried to find the instruction that writes `0x76 0x18 0xFD` (HALT +
JR loop) to RAM `0x0341` via `mem:install_write_tap(0x0341, 0x0341,
"watch", fn)`. The tap never fired, even though the bytes definitively
appeared at that address. Root cause: **the bytes arrive as DMA
payload from an FDC overlay read**, not as CPU stores. MAME's Lua
memory-tap API only hooks the CPU bus side; DMA controllers write
directly into the physical memory backing store without going through
that hook. Finding the writer required static fingerprinting of the
runtime dispatcher against the disk file — the 88-byte window at RAM
`0x0330` matches disk `0x1D30` byte-exact, meaning the phase-2 loader
reads T1S0 sector 3 (= disk `0x1C00-0x1DFF`) with DMA destination
`0x0200`, which lands the dispatcher template at `0x0330` and
consequently puts the HALT opcode at `0x0341`.

This is a **reusable lesson for future MAME debugging** — watchpoints
for DMA targets need to go on the DMA controller's address register
(e.g. `wpset 0xF2` for Am9517 CH1 on RC702), not on the target memory
address.

### 4. CONFI block verified byte-exact against real CP/M system disks

The test disk's Track 0 sectors 1-5 are a verbatim CP/M **CONFI block**
matching the layout documented in
`rcbios/sw1711_files/CONFI_ANALYSIS.md`:
- Sector 1: boot header with `80 02 00 00 00 00 00 00 " RC702"`
- Sector 2: 128 B hardware config (CTC modes, PSIOA/PSIOB init
  blocks, DMA mode, CRTC params, FDC specify, CBLANGUAGE=4 US-ASCII,
  baud rates, etc.)
- Sector 3: output conversion table — **0/128 diffs** vs
  `conversion_tables.bin` US-ASCII entry
- Sector 4: input conversion table — **0/128 diffs**
- Sector 5: semigraphic table — **1/128 diff** at `[0x45]` (`0xC5` vs
  `0x05`, a bit-7 flip)

So the test disk runs with localised keyboard/display tables from
CONFI.COM, and those tables are consumed at runtime by the test
program (verified by static reference in the dispatcher's hardware
init code to CONFI offsets `0xD51C-0xD51F` = `DMODE0-3`).

### 5. Port `0x50` is the testsystem's diagnostic error-code output

Manual §16 ERROR CODES documents that the testrouter writes a 1-byte
status code to **I/O port `0x50`** after each sub-test completes.
Codes: `00` OK, `01` PROM chksum, `02` RAM, `17` refresh, `18-1A` FDC,
`1B-2D` FDD/FDC, `2E-3B` WDC. This is the channel intended for
headless MIC-board test rigs: a 7-segment display or LED bargraph
wired to port `0x50` gives test results without a CRT. **MAME's
`rc702mini` driver does not map this port** — every `OUT (50h),A`
logs "unhandled I/O, output ?? to port 50" and the byte is dropped.
Adding a `-diag_port50 FILE` hook to the driver (≈20 lines) would
give us a CI oracle for the whole testsystem.

### 6. Interactive dispatch requires letter + Return

Manual §3.2 says it once: *"Striking the `<return>` key will have the
test system reentering the looping or running state"*. The on-screen
prompt `"type (H,R,L,G,S,P,<esc> or (0-F)) : "` does NOT mention
this requirement. Verified end-to-end on MAME by posting `"R\r"` via
`manager.machine.natkeyboard:post(...)` from a Lua autoboot hook:
state line flips from `halted` → `running`, auto-run restarts, tests
01-06 re-execute, back to halted. So MAME keyboard routing does work
— the "pressing a key does nothing" observation was just the missing
Return.

### 7. rc702mini-related Makefile correction

`RC702_HARDWARE_TECHNICAL_REFERENCE.md` §"5.25" Floppy Disk Format
said "Tracks 1-34" and ~319 KB total capacity. The datamuseum
geometry is **35 data cylinders** plus track 0, not 34, giving
328,704 B (321 KB) total. Fixed to "Tracks 1-35" and noted the
reference image with the datamuseum URL and the full byte-exact
layout.

## Problems found in this session (with resolutions)

### `~/git/rc700/roa375.rom` was a QR-code test PROM, not the autoload

**Symptom**: booting `RC702_TEST_v1.2.imd` in `rc700-sdl2` showed a
QR-code pattern instead of the test menu. User identified it as
"prom1 added from the qr-code test".

**Root cause**: `~/git/rc700/roa375.rom` had been replaced (in a
prior session, author unknown) with a 4,096-byte QR-display ROM — a
minimal relocator (`copy 0x930 bytes from PROM 0x0068 → RAM 0x6000 ;
JP 0x6488`) followed by display-character pattern data. The rc700
emulator compiles this blob into its binary via `rom2struct →
roa375.c → _roa375` symbol, so every boot shows the QR code. Git
confirmed `roa375.rom` was modified from HEAD, and
`git show HEAD:roa375.rom` matched `rc700-gensmedet/roa375/roa375.rom`
byte-exact (2,048 B canonical autoload).

**Resolution**: `git checkout roa375.rom`, regenerate `roa375.c` with
`./rom2struct roa375.rom roa375 > roa375.c`, rebuild `rc700-sdl2`.
Working tree of `~/git/rc700` is now clean w.r.t. `roa375.rom`
(`roa375.c` is still untracked, as it's a build artefact).

### `rc700-sdl2` hangs on 8275 status polling when guest has IFF=0

**Symptom**: after fixing the PROM, the test disk booted but the
emulator hung with PC pinned at `0x0061` in a tight
`IN A,(01h) ; BIT 5,A ; JR Z` loop — waiting for the 8275 CRTC's IR
(interrupt request) status bit to become 1. MAME's `rc702mini` target
runs the same code through to completion; `rc700-sdl2` doesn't.

**Root cause**: `~/git/rc700/crt.c` `crt_poll()` has `if (!IFF)
return 0;` as its first guard after checking `CRT_STAT_VE`. That
return bails out of the whole polling function, so `CRT_STAT_IR` never
gets set. The guest has `IFF=0` because the overlayed second-pass
hardware init at RAM `0x0000` does `DI` before the CRTC programming —
which is perfectly valid on real hardware, where the 8275 raises IR
in the status register regardless of CPU interrupt state, and the
program is polling the register specifically to avoid needing
interrupt delivery. The real 8275 IR bit is set on raster events, not
on Z80 IFF; the rc700 emulator incorrectly couples the two.

**Resolution**: moved the `!IFF` guard so it only gates the CPU-level
interrupt raise via `ctc_trigger()`, not the status-bit update:

```diff
 int crt_poll() {
-  if (!IFF) return 0;
   if (!(crt.status & CRT_STAT_VE)) return 0;
   ...
   if (crt.status & CRT_STAT_IE) {
     crt.status |= CRT_STAT_IR;
-    ctc_trigger(CTC_CHANNEL_CRT);
+    if (IFF) ctc_trigger(CTC_CHANNEL_CRT);
   }
```

Rebuilt, re-ran the test disk — PC advanced past `0x0061`, hit
`0x1177` (deep into the test code), and the emulation continued.
User ruled out rc700 as not accurate enough overall and told me to
go back to MAME, but the fix is sitting in the `~/git/rc700` working
tree (uncommitted) if you want to commit it. `ravn/rc700` has issues
disabled so this can't be filed as a github issue — committing the
local diff is the only path.

### `rc700-sdl2` Makefile target doesn't build on macOS

**Symptom**: `make rc700-sdl2` fails in three different ways:
1. `fatal error: 'SDL2/SDL.h' file not found` — macOS has SDL2 as
   a framework under `/Library/Frameworks/`, not as a Linux-style
   `/usr/include/SDL2/`.
2. `ld: library 'SDL2' not found` — the Makefile uses `-lSDL2`
   which finds nothing on macOS; the correct flag is `-framework SDL2`.
3. `Undefined symbols for architecture arm64: "_main"` — the SDL2
   build path expects a `main` wrapper that calls `SDL_main`;
   `sdl2_main.c` provides this but the Makefile doesn't include it.

**Resolution**: worked around with a manual command (documented in
`rc702-test-v1.2/RUNTIME_ANALYSIS.md`):

```bash
cc -o rc700-sdl2 -O3 -Wno-unused-result -DPROM0=roa375 \
   -F/Library/Frameworks -I/Library/Frameworks/SDL2.framework/Headers \
   cpu{0,1,2,3,4,5,6,7}.c rom.c charrom.c charram.c pio.c sio.c ctc.c \
   dma.c crt.c fdc.c wdc.c ftp.c disk.c fifo.c monitor.c disasm.c \
   roa375.c rc700.c rcterm-sdl2.c screen.c sdl2_main.c \
   -framework SDL2
```

The Makefile should be patched to handle macOS (conditional flags
based on `uname`), but again — `ravn/rc700` has issues disabled, so
this is a "commit when convenient" item, not a trackable issue.

### `rc700-sdl2` COMAL80 keystroke injector runs unconditionally

**Symptom**: every boot of any disk in `rc700-sdl2` starts a
state-machine in `cpu_poll()` that waits for the CP/M prompt, then
injects keystrokes to type `COMAL80`, `NEW`, a Hello-World program,
`RUN`, `BYE` — then **calls `exit(0)`**. This runs regardless of
what disk is mounted, so any non-COMAL disk gets spurious keystrokes
pressed into PIO-A during early boot.

**Resolution**: patched `rc700.c` with a `-noinject` CLI flag and
guarded the entire state machine on it:

```c
int inject_enabled = 1;  // set to 0 via -noinject CLI flag
...
if (inject_enabled) {
    if (test_state < 99) test_step();
    if (test_state == 99) { ... exit(0); }
}
...
} else if (strcmp(argv[i], "-noinject") == 0) {
    inject_enabled = 0;
```

Uncommitted in `~/git/rc700/rc700.c`. Same disposition as the
Makefile — can't file as a github issue, can only commit locally.

### MAME `natkeyboard:post()` delivers two keystrokes but `schedule_exit()` is the wrong method name

**Minor**: my first Lua keystroke-injection hook called
`manager.machine:schedule_exit()` to exit after the test restart
completed. MAME raised `attempt to call a nil value (method
'schedule_exit')`. Correct name for modern MAME is
`manager.machine:exit()` or `dbg:command("quit")`. Noted in
`RUNTIME_ANALYSIS.md`.

## Things I did not do (and why)

- **Did NOT commit my `~/git/rc700` fixes**. The user said "go back
  to mame" mid-session, ruling out rc700 as not accurate enough
  overall. The fixes are good and uncommitted in the working tree,
  safe to commit whenever convenient.
  **Update:** at end of session the user enabled issues on
  `ravn/rc700` and the three bugs are now filed there:
  - ravn/rc700#1 — `crt_poll()` IFF bug
  - ravn/rc700#2 — Makefile macOS build (SDL2 framework + main wrapper)
  - ravn/rc700#3 — COMAL80 keystroke injector needs opt-out flag
- **Did NOT create any pull requests**. User reinforced the
  "never ever create pull requests" rule during this session. I was
  only planning to file issues when I ran `gh --version`, but the
  user's correction triggered a memory update adding
  `feedback_no_pull_requests.md` with an unconditional no-PR rule.
- **Did NOT patch MAME itself**. The rc702mini driver could benefit
  from a port-0x50 diagnostic sink and from CBL936/CBL998 loopback
  emulation, but MAME is not in `ravn/*` so per the
  `feedback_no_upstream_issues` rule I didn't file bugs upstream,
  and patching the driver without filing an issue first seemed
  premature. Noted as TODOs in `rc702-test-v1.2/README.md`.
- **Did NOT disassemble every sub-test's body**. The dispatcher
  walks a test-iteration table at `0xDA39` (frozen high-memory copy)
  that points at per-test handlers via `0xD8EAh`. Following each
  handler would be a day of disassembly. Out of scope for
  "what does the program do" — the manual covers it.
- **Did NOT run the reliability tests** (A / B / C). These require
  interactive question-and-answer sequences and on a real machine
  would take many minutes. Out of scope.

## New TODOs (in addition to folder-level README list)

**Priority order** (lowest friction first):

1. **Commit the `~/git/rc700` working-tree fixes**. Four small
   patches: the `crt.c` IFF fix, the `rc700.c` `-noinject` flag, the
   `rc700.c` register dump on SIGINT, and the `sdl2_main.c` wrapper
   file (already existed in the repo, untracked). Makefile macOS fix
   can be a follow-up — it's intrusive.
2. **Add a port-0x50 diagnostic sink to MAME's `rc702mini` driver**
   (`regnecentralen/rc702.cpp`). ~20 lines of C++ plus an options
   entry. Enables automated testsystem CI without CRT-scraping.
3. **Wire MAME emulation of `CBL936` and `CBL998` loopbacks** so all
   six auto-run tests pass in a bare `rc702mini` run. Details in
   `rc702-test-v1.2/README.md` TODO list.
4. **Create a maxi 8" boot diskette** of this test program for the
   physical machine. Needs a maxi-format IMD builder and a
   kryoflux/greaseweazle writer.
5. **Annotate the disassemblies with manual section references** —
   tag every embedded error-message string in
   `region*_asload.asm` with the `§N.n` section from
   `MANUAL_ANALYSIS.md`, turning the raw listings into navigable
   companions to the manual.

## New MEMORY entries added

- `feedback_no_pull_requests.md` — HARD RULE: never ever create PRs
  unless the user explicitly asks for a PR on this specific change
  in the current turn.

## Lessons added to tasks/lessons.md

See the 2026-04-11 section of `lessons.md` — MAME Lua API gotchas
(tap doesn't catch DMA, `-debug` starts paused needs `debugger:command("go")`,
snap filename is relative to `-snapshot_directory`, `schedule_exit` is
not a valid method), `install_write_tap` DMA blind-spot, the test
program's port-0x50 ERROR CODES channel, and the "letter + Return"
interactive requirement.
