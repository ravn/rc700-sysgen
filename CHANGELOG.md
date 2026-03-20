# Changelog

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
