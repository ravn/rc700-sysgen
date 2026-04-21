# Session 29 — CP/NOS reaches `A>` prompt

Date: 2026-04-21

## Milestone

Full cold-boot chain works end-to-end in MAME:

```
netboot stream -> cpnos.com at 0xD000/0xCC00
  -> cpbios banner "RC702 CP/NOS v1.2"
  -> cpndos NWBOOT
  -> 20x SNIOS READ SEQ of CCP.SPR (128 B/record) from Python server
  -> CCP at A>
```

`mame_boot_test.lua` now gates on `A>` appearing in the 8275 display
buffer (0xF800). Observed at frame 225 (4.5 s emulated).

## Changes landed

- **`netboot_server.py`** — DRI SNIOS wire dispatch extended to real
  file serving. `CCP     SPR` mapped to `cpnet-z80/dist/ccp.spr` via
  `_FILE_MAP`; `_OPEN_FILES` caches file contents across OPEN/READ/
  CLOSE. `_fcb_key` normalises FCB name+ext to the canonical 11-char
  key. READ SEQ walks `ex` and `cr` FCB fields (cr 0..127, then rolls
  to next extent), returning 128-byte records padded with `0x1A` at
  EOF. Unhandled BDOS fns return success+empty FCB (placeholder).

- **`mame_boot_test.lua`** — PASS gate rewritten. Old gate fired at
  2.5 s when PC happened to land in 0xD000..0xF800 with C3 opcodes
  in zero page; that condition is satisfied mid-way through NDOS's
  CCP load and produced false-green runs. New gate scans the display
  for `A>` anywhere in rows 0..24. Timeout extended to 60 s.

- **`Makefile`** — `-seconds_to_run 40` -> `70` so MAME outlives
  the Lua 60 s timeout on slower hosts.

- **`.gitignore`** — `cpnos-build/d/` (XIZ+dri2gnu.pl intermediate
  output, regenerated on every build).

## Validation

- `make cpnos-netboot` prints `PASS (A> at row 13 col 0)` and exits
  cleanly. Server log shows OPEN/READ x 20/CLOSE for CCP.SPR, no
  protocol retries.

## Known issues / open work

### Issue A — CCP is at the prompt but nothing has been typed
No command has been executed yet. No DIR, no TYPE, no warm-boot.
Before declaring CCP "works", we need to inject keystrokes via SIO-B
or null_modem bitbang and see CCP echo + respond. Candidate tests:
- `DIR` -> should list empty directory (server returns FILE-NOT-FOUND
  for every SEARCH FIRST) + `A>` reprompt
- `^C` -> warm boot -> re-fetches CCP.SPR

### Issue B — Server's SNIOS dispatch is stub-shaped for most fns
Only fns 13/14/15/16/20 actually do anything sensible. Fns unhandled
(return all-zeros success): 17 (SEARCH FIRST), 18 (SEARCH NEXT), 19
(DELETE), 21 (WRITE SEQ), 22 (MAKE), 23 (RENAME), 33/34 (RANDOM I/O),
35 (FILE SIZE), 36 (SET RANDOM RECORD). DIR will call 17/18 and get
back garbage. First keystroke likely exposes this.

### Issue C — File map is hardcoded single entry
`_FILE_MAP = {'CCP     SPR': '.../ccp.spr'}`. A real server needs to
walk a directory (e.g. `cpnet-z80/dist/`) per slave and per user area,
honour drive letter (A..P) plus user number (0..15), and translate
CP/M wildcards (`*`, `?`) to SEARCH FIRST/NEXT results.

### Issue D — `mame_boot_test.lua` uses hardcoded `cfg_addr = 0xF4D4`
CFGTBL symbol address is linker-determined; dump shows that address
now holds cpbios code, not CFGTBL. The Lua probe should read the
linker map / `llvm-nm cpnos.elf` output and be handed the right
address at build time (e.g. emit a generated `mame_symbols.lua`).

### Issue E — Lua PASS gate doesn't verify CCP responds to input
Finding `A>` proves CCP reached its prompt, not that the BIOS/CONIN
path works. Next-level gate: write a char to SIO-B, observe echo on
display or in serial log.

### Issue F — BDOS vector dump says `want c3 06 de`
Cosmetic: after cpbios runs, 0x0005 is rewritten to `c3 06 cc` (BDOS
lives inside the 0xCC00 data region). The "want" string in
`mame_boot_test.lua:finish()` is stale from pre-cpbios days.

## Next session

Pick one:
1. **Type a char into CCP** (Issue A+E) — minimal new code, exercises
   the input side of the stack. Likely reveals Issue B immediately
   when CCP runs the command.
2. **Implement SEARCH FIRST/NEXT + WRITE on the server** (Issue B+C)
   so `DIR` and `SAVE` work against a real directory.
3. **Wire CFGTBL address from `llvm-nm`** (Issue D) so the boot test
   can re-check SLAVEID/NETST post-NDOS.

Recommendation: 1 first — it's the smallest step that still proves
the stack is alive in both directions.
