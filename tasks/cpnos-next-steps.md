# CP/NOS next steps

Forward-looking handover for the CP/NOS client work.  Historical
details live in `session24-cpnos-snios.md` and
`session29-ccp-prompt.md`; this doc is the short "where are we and
what's next" snapshot.

## Session 32 (2026-04-21 → 2026-04-22) — RC702 ↔ MP/M II GREEN

### Milestone AA reached — end-to-end LOGIN + remote file ops PASS

After installing prebuilt `mpm-net2` package into z80pack submodule
and fixing the launcher to `cp` disks (so CCP's `$$$.SUB` cleanup
doesn't clobber the library), ran `bash cpnet/run_test.sh --no-server
--inject --auto --headless`.  Result from `/tmp/cpnet_test_results.txt`:

    RESULT: PASS — prompt visible after NETWORK
    RESULT: PASS — ERA H:HLCOPY2.TXT succeeded
    RESULT: PASS — HELP ERA EXAMPLES succeeded

Lua autoboot output (cpnet_38400.lua) shows the exact boot sequence:

    RC700 56k CP/M 2.2 C-bios/clang 2026-04-22
    A>CPNETLDR
    CP/NET 1.2 Loader
    BIOS         DA00H  2600H
    BDOS         CC00H  0E00H
    SNIOS   SPR  C900H  0300H
    NDOS    SPR  BD00H  0C00H
    TPA          0000H  BD00H
    CP/NET 1.2 loading complete.
    A>LOGIN PASSWORD
    (network drive usable)

Infrastructure snapshot at milestone:

| Piece | Location | Notes |
|-------|----------|-------|
| MP/M II server | `z80pack/cpmsim/` submodule, `./mpm-net2` | CCP auto-runs MPMLDR via $$$.SUB; listens TCP 4002 |
| RC702 (MAME)   | `~/git/mame/regnecentralend rc702` | PROM: stock ROA375 (SHA1 306af9fc) — required for this path, NOT cpnos-rom |
| RC702 BIOS     | `rcbios-in-c/clang/bios.cim` | clang-built C-BIOS, 38400 baud, RTS flow |
| SNIOS.SPR      | `cpnet/zout/SNIOS.SPR` | 1024 B, built from cpnet/snios.asm |
| Wiring         | MAME `-bitb1 socket.localhost:4002` | null_modem TCP client → cpmsim console 3 |
| Driver         | `cpnet/run_test.sh --no-server --inject --auto --headless` | SUB = CPNETLDR → LOGIN PASSWORD → NETWORK H:=B: |

### Pitfalls recorded

1. **cpmsim needs `srctools/cpmrecv`.**  Without it cpmsim does
   `kill(SIGQUIT)` on the whole process group during startup
   (simio.c:427).  Fix: build `z80pack/cpmsim/srctools/` with `make`.
2. **Tarball uses `.cpm` extensions; modern cpmsim wants `.dsk`.**
   Patched the mpm-net2 launcher.
3. **`$$$.SUB` is one-shot.**  CCP deletes it after executing.  With
   hard-linked drives the library got mutated.  Fix: launcher uses
   `cp` (not `ln`), and the library disk carries a fresh `$$$.SUB`.
4. **Stock ROA375 PROM required in `~/git/mame/roms/rc702/`.**
   cpnos-rom PROM (session 31) does its own SIO netboot which MP/M
   does not serve — MAME will hang on the "CPNOS" banner.  Stock ROM
   SHA1 is `306af9fc779e3d4f51645ba04f8a99b11b5e6084`, size 2048 B
   (MAME pads internally to the 0x1000 region with FF).
5. **Old macOS `screen` (v4.00.03, 2006).**  `-X stuff` flushing to
   the log is unreliable; use a real terminal for interactive driving
   of cpmsim console 0.  For headless automation, $$$.SUB is cleaner.

### Next steps

- **Path-B test: cpnos-rom ↔ MP/M II via Python 0xB0 proxy.**  Now
  that the stock path is validated, it becomes the reference.  Then
  write a minimal proxy in front of cpmsim:4002 that intercepts 0xB0
  cold-boot requests and responds with the cpnos-build image, while
  forwarding all other CP/NET traffic transparently.  When the proxy
  sees LOGIN/DIR go through, success.
- **SLAVEID consistency.**  stock path uses 0x01 from `cpnet/snios.asm`.
  cpnos-rom-plan hardcodes 0x70.  Change `cpnos-rom/Makefile`
  `-DRC702_SLAVEID=0x70` to `0x01` before attempting path-B.
- **Restore cpnos-rom PROM in MAME after path-B work.**  Swap in
  `cpnos-rom/clang/prom0_padded.ic66` when testing cpnos-rom; swap
  back to `roa375/roa375.rom` for path-A smoke.  Could automate via
  `cpnos-install` / `autoload-install` make targets.

## Session 32 (2026-04-21) — retarget: CP/NOS + z80pack MP/M II

**Decision.** Retarget the server side from our Python `netboot_server.py`
to a real DRI MP/M II running in z80pack `cpmsim` (submodule at
`z80pack/`, ravn fork).  This is the *officially intended* CP/NOS
topology per DRI app note 03.

**Protocol research (agent, session 32):**

- CP/NOS is **linked statically** on the slave
  (`LINK CPNOS,CPNDOS,CPNIOS,CPBDOS,CPBIOS[LF000,DEC000]`) and the
  whole image lives in the slave's PROM.  `cpnos.asm` is a 10-line
  stub; no bytes cross the wire at cold boot.
- Server-side `CPNETLDR.ASM` is for CP/M (local-disk) slaves, not
  CP/NOS.
- DRI's `NETBOOT` extension (FMT=0xB0 req / 0xB1 resp, sub-fns
  ldtxt/stdma/load128/execute) is optional and has **no responder
  in the DRI MP/M II server** (`dist/mpm/server.asm`) nor in
  z80pack's `srcmpm/netwrkif-*.asm`.  Left to the integrator.
- `LOGIN` is **explicit** (user runs `LOGIN.COM`), CP/NET fn 64,
  not part of boot.
- MP/M II routes slaves by **SIO port**, not by in-band slave ID.
- Frame format unchanged (ENQ/SOH/header/HCS/STX/data/ETX/CKS/EOT).

**Target architecture.**
1. RC702 cold-boots CP/NOS entirely from its own PROMs (full
   CCP+NDOS+SNIOS+CPBDOS+CPBIOS image, no netboot download).
2. Local A> prompt appears with **no bytes on the wire**.
3. User types `LOGIN`; CP/NET fn 64 is the first frame emitted.
4. MAME SIO-A -> TCP bridge -> z80pack cpmsim virtual SIO port
   (`mpm-net2` target).  Bridge is pure byte relay.

**PROM size policy (user, 2026-04-21).**
"Booting first, memory later."  **MAME may use 4 KB PROMs
temporarily** if the linked image doesn't fit 2 × 2 KB.  PCB530
real HW stays at 2 KB — we'll shrink before physical testing.

### Architecture note — warm boot forces server-side image reload

RC702 PROM disable is **one-way** (`OUT (0x18),A` can't be undone
without hardware reset).  So even if cold boot copied CCP+NDOS from
PROM, warm boot cannot re-read PROM.  Options were (a) shadow
CCP+NDOS in ~6 KB of high RAM permanently, (b) reload from server
on warm boot.  Picked (b) — it's what the whole MP/M-II work is
about anyway.

**Consequence:** no PROM embedding.  Cpnos-rom stays unchanged
(cold boot netboots, warm boot reloads CCP.SPR via BDOS READ — same
as today).  The MP/M-II integration lives entirely in the
Python-side proxy + cpmsim, not in ROM.

### Prebuilt MP/M + CP/NET disks — where from

`mpm-net2-1.dsk` / `mpm-net2-2.dsk` come from Udo Munk's historic ftp
archive, not the modern GitHub tree:

    http://cpmarchives.classiccmp.org/cpm/mirrors/www.unix4fun.org/z80pack/ftp/mpm-net-1.2.tgz

Local: `~/Downloads/mpm-net-1.2.tgz` (242 KB, 2008-07-05).  Full
notes in `cpnet/Z80PACK_MPMNET.md` under "Disk image provenance".
Submodule's `srcmpm/netwrkif-*.asm` still has the MPMNET_ANALYSIS
CONIN bug; prebuilt tarball avoids it for reasons unknown.

### Slave ID change

RC702 slave ID switches from **0x70** (cpnos-rom-plan default) to
**0x01** to match the prior z80pack MP/M config.  One-liner in
`cpnos-rom/Makefile` (`-DRC702_SLAVEID=0x70` -> `0x01`) at build time.

### New tasks (revised, path A')

| ID | Summary |
|----|---------|
| W' | Extend `netboot_server.py`: keep 0xB0 NETBOOT + `.SPR` file serving local; add TCP-forward path to cpmsim for post-LOGIN CP/NET traffic |
| Y  | Build z80pack `cpmsim` from submodule; bring up `mpm-net2` headless |
| Z  | Wire cpmsim's slave SIO port to a TCP listener (conf/net_server.conf — consoles 1-4 on ports 4000-4003) |
| AA | First milestone: RC702 boots via Python (as today), user types `LOGIN 70`, frame reaches MP/M II, `DIR` on a remote drive lists MP/M files |

### Issue V — UPDATED

Loader 4 KB cap is now irrelevant for MP/M integration (no PROM
embedding).  Loader still useful for iterating on sub-4 KB cpnos-rom
changes without burning.

### Issue U — unchanged

Still open as a latent bug on `cpnos-rc700-console`.  Not on the
critical path for MP/M integration.

## Session 31 (2026-04-21) — loader + RENAME

- **CP/M `.COM` loader for PROM swap without burning** — committed
  in `73206be`.  `build_loader.py` + Makefile `cpnos-loader` target
  produce `clang/cpnos_loader.com` (4125 B = 3 B entry + 2 KB
  prom0 + 2 KB prom1 + 26 B stub that DIs, LDIRs both payloads
  into 0x0000 / 0x2000, then `jp 0`).  Stub lives at 0x1103 so
  both LDIRs leave it untouched (first LDIR has dest<src so the
  overlapping copy from 0x0103→0x0000 is safe).  End-to-end
  verified via CP/NOS netboot (CCP loaded .COM, stub ran, cpnos
  re-emitted a fresh 0xB0 cold-boot request on SIO-A).  Also
  verified under the stock `rcbios-in-c/clang/bios.cim` via
  `mame-maxi` — `cpmcp`-injected the .COM onto the A: disk and
  saw the CP/NOS "CPNOS" fallback banner appear on the 8275
  display, proving the swap worked across BIOSes.
- **BDOS fn 23 RENAME** implemented in `netboot_server.py`
  (commit `b17128b`).  Handles both ephemeral `_WRITES` entries
  and in-memory rebind of disk-backed `_FILE_MAP` entries.
  Verified with CCP `REN foo.com=login.com` + two DIR lookups.
  Step-6 copy regression still passes.  Closes the one real
  dispatcher gap flagged by the BDOS-coverage audit.
- **RC700 console branch parked.**  `cpnos-rc700-console` WIP at
  `5ed23da` — full memory-layout surgery landed (IVT 0xEE00,
  SP 0xF000, `.resident` LMA PROM1, two memcpys, RC700 state
  machine), but boot fails with PC in `resident_entry`'s fallback
  `for(;;){}` at 0xF516.  Root cause traced to Issue U below,
  not the console code itself.

### Issue U — impl_wboot / impl_boot are unconditional fallback traps

`resident.c` has `[[noreturn]] impl_boot`/`impl_wboot` both doing
`resident_entry(0)`.  On `main`'s smoke plan CCP never hits WBOOT
so the trap never fires, but the parked console branch exposed
the bug: on first CONOUT something in the early CCP path lands
in WBOOT, `resident_entry(0)` takes its `entry == 0` fallback,
prints `CPNOS\r\n`, and spins `jr $f516`.  SP=0x00F6 in that
state matches `cpbios.s` `ld sp, BUFF+0x80 = 0x0100` minus 5
pushes — proof CCP was live underneath.

Fix: point both entries at the loaded CCP base (`jump_to(0xD000)`
for wboot; boot probably needs to re-netboot instead).  Doing
this on `main` first would make any future branch failure
announce itself as an obvious re-entry loop into CCP rather
than a misleading silent fallback banner.

## Where we are (2026-04-21, session 29 close)

CP/NOS cold-boots on MAME `rc702` against the Python
`netboot_server.py` and runs real CP/M programs against a Python-
backed directory.  **All seven smoke-plan steps are green.**
Automated tests:

| Make target | What it proves | Wall time |
|-------------|----------------|-----------|
| `cpnos-netboot` | cold boot to `A>` | ~3 s |
| `cpnos-warmboot-test` | ^C warm boot (step 1) | ~3 s |
| `cpnos-sub-test CPNOS_SUB='dir'` | DIR listing (steps 2-4) | ~3 s |
| `cpnos-sub-test CPNOS_SUB='copy mailcopy.com mail.com'` | end-to-end file copy, byte-verified | ~7 s |
| `cpnos-sub-test CPNOS_SUB='mac sysgen $$pz\|load sysgen'` | MAC+LOAD assembling SYSGEN.ASM (step 7) | ~14 s |
| `cpnos-interactive` | leave MAME up; PIO-A keyboard + SIO-B injection both drive CONIN | (manual) |

Last SYSGEN assembly run produced output that is **1401 / 1408
bytes byte-identical to `sysgen/RCSYSGEN.COM`** (the zmac-built
gold reference).  The 7-byte diff is inside a string-table gap
where DRI's MAC leaves leftover bytes from the prior literal
(`'RETURN TO SKIP'`) that zmac zero-pads — unrelated to any
server or transport issue.

## CCP rebuild capability (new this session)

We can now reproduce `cpnet-z80/dist/ccp.spr` byte-for-byte from
source, on two independent paths:

| Tool | Script | Output | Verified |
|------|--------|--------|----------|
| RMAC + LINK (VirtualCpm) | `cpnos-build/build-ccp.sh` | Full .SPR (3200 B) | byte-identical to `dist/ccp.spr` |
| zmac -8 --dri (host) | `cpnos-build/build-ccp-zmac.sh` | Code section only (2560 B) | byte-identical to SPR offset 256..2815 (zero-padded trailing DEFS) |

Both consume `cpnos-build/dri_split.py` output — the original
`ccp.asm` preprocessed so each DRI-MAC `!`-joined statement lands on
its own line (922 → 1410 lines), still assembles to the same bytes.

This gives a clean base for Z80-conversion experiments: edit the
split source, run either build, cmp against the original.  The zmac
path is preferred for iteration because it's pure host-side, no
VirtualCpm launch overhead, and zmac has none of RMAC's 8080-only /
M80's 6-char limits.

## Smoke plan status

| Step | What | Status |
|------|------|--------|
| 1 | ^C warm boot | PASS |
| 2 | ENTER on empty line | PASS (via SUB) |
| 3 | `DIR` → NO FILE | PASS |
| 4 | `DIR` on populated dir (13 files) | PASS |
| 5 | Transient `.COM` (PIPNET, MAIL, DONE, COPY) | PASS |
| 6 | File copy, byte-verified | PASS via `testutil/copy.com` (8192 B of MAIL.COM round-trip identical) |
| 7 | MAC+LOAD of SYSGEN.ASM, byte-diff against gold | PASS (1401/1408 B match; 7 B are a MAC vs zmac string-table quirk) |

## Known open items (none blocking)

### Issue V — Loader carries max 4 KB payload

`cpnos_loader.com` copies exactly 2 KB to 0x0000 and 2 KB to
0x2000 because that's the physical PROM layout.  If cpnos-rom
outgrows the 4 KB cap (currently PROM0 2040 / 2048 B, PROM1
0 / 2048 B), the stub can just widen the LDIR counts — but
`cpnos_main`'s reset path and `cpnos_rom.ld` still assume
2 KB + 2 KB.  Coordinated change required.  Not urgent.

### Issue N — PIPNET.COM sends a zeroed FCB on WRITE SEQ
PIPNET-specific quirk, not a server bug.  Our write path is
proven correct via `testutil/copy.com` (same server, same NDOS,
same wire protocol → step 6 + 7 PASS).  Resolving would mean
disassembling `cpnet-z80/dist/pipnet.com` (no source in cpnet-z80
or z80pack) to find what FCB pointer PIPNET actually hands to
BDOS fn 21 and why its contents are wiped between MAKE and WRITE.
Pick up only if PIPNET specifically is required.

### Deferred (none urgent)

| ID | Summary | Why deferred |
|----|---------|--------------|
| D  | `mame_boot_test.lua` hardcodes `cfg_addr = 0xF4D4` | Resident moved; probe needs `llvm-nm` lookup at build time |
| E  | Lua PASS gate doesn't test CONIN | Now covered by step-1 warm-boot test |
| F  | BDOS vector "want c3 06 de" is stale | Cosmetic — cpbios rewrites to `c3 06 cc` by design |
| J  | SEARCH FIRST preamble ambiguity (stsf1 vs stsf2) | Absorbed by `data[len-35:len-24]`; revisit if we touch CP/NET docs |
| K  | Single-client SEARCH iterator state | Only matters with >1 slave |
| L  | Task-notification ≠ MAME-exit | Known; use `pgrep -f regnecentralend` |
| M  | DIR entries are single-extent only | No served file exceeds 16 KB yet |
| O  | M80 unsuitable for ccp.asm | 6-char symbol truncation + `$`-in-binary-literals unsupported; documented in session notes, see MS M80 manual |
| P  | zmac build produces code-only, not SPR | Need a small wrapper tool to emit full SPR (header + data sector + code + relocation bitmap) if we want zmac output to drop in as a replacement for dist/ccp.spr |

## PROM space budget

PROM image is 4096 B total (2 × 2 KB chips).
- PROM0 in use: **2040 B** code + **8 B** padding headroom
- PROM1 in use: **0 B** — **all 2048 B free**

(As of session 31 the `.COM` loader carries the same 4 KB; iterate
without burning via `make cpnos-loader` + staged `CPNOSLDR.COM`.)

Candidate uses for PROM1 (tracked but not yet picked).  The
constraining rule is the RC702 hardware one-way PROM disable: once
`OUT (0x18), A` fires, both PROMs are unmapped until hardware
reset.  So any PROM content has to be **copied once at cold boot**
to survive, *and* has to be either read-only / non-regenerable by
runtime code, or have a cheap warm-boot recovery path (since warm
boot doesn't re-enable PROM).

1. **Hardware monitor** (~1 KB) — peek/poke/port for on-bench
   debugging without a working network stack.  Natural fit: code
   only runs during cold-boot diagnostic sequences, copy-once to
   RAM is fine, and it's explicitly optional for warm boot.
2. **Netboot retry/progress UI** (~300 B) — visible "waiting for
   server…" state instead of silent hang.  Cold-boot only, no
   warm-boot path, perfect fit.
3. Leave as headroom — default if nothing else bids.

### Deferred: Z80-converted CCP in PROM1

*Why parked:* RAM is precious.  A PROM-sourced CCP has to sit in
RAM to be executable, which costs the same RAM as the network-
loaded one.  And warm boot expects CCP to be re-freshable — PROM
is disabled by then, so we'd need a second pristine copy in RAM to
restore from, *doubling* the RAM cost for zero functional gain.
The byte-identity-verified build infrastructure (build-ccp.sh,
build-ccp-zmac.sh, dri_split.py) stays useful for unrelated CCP
work (e.g. shrinking the binary to reduce the cold-boot streaming
burst without moving it).  Revisit if the RAM math changes or if
we find a no-warm-boot use case.

## What could happen next

- **Z80 CCP experiment.**  With two byte-identical build paths in
  place plus the split source, the iteration loop is: edit splits
  → zmac → cmp → test in MAME.  Pilot: translate a hot loop (e.g.
  a `mvi b, n / dcr / jnz` idiom) to `djnz`, verify boot still
  works, measure -N bytes.  Parked at the decision of whether to
  target full SPR (keep current load path) or PROM1 absolute
  (requires PROM-disable timing changes).
- **Back to the actual project goal** (per `~/z80/CLAUDE.md`):
  optimize the LLVM-Z80 backend against SDCC code density.  PROM
  is 1756 B clang vs 1910 B SDCC; BIOS 6021 vs 6123.  Paused for
  the CP/NOS detour — ready to resume.
- **Physical RC702 test** of today's work: laptop running
  `netboot_server.py` on SIO-A, real hardware booting the new
  PROM.  Would flush out any MAME-specific assumptions.
- **PIPNET disassembly** (issue N) — only if required.
- **zmac instead of MAC** in step 7 — closes the 7-byte diff, but
  returns zero functional value.

## Where files live

- `cpnos-rom/netboot_server.py` — CP/NET server, dispatcher, file map
- `cpnos-rom/cpnos-build/` — CP/NOS monolithic image builder (DRI ASM → clang → ld.lld)
- `cpnos-rom/resident.c` + `init.c` + `isr.s` — our RC702 BIOS
- `cpnos-rom/testutil/` — test fixtures (done.com, copy.c/com, mac.com, load.com, sysgen.asm)
- `cpnos-rom/sio_b_driver.py` — SIO-B TCP bridge + keystroke injector
- `cpnos-rom/mame_sub_test.lua`, `mame_boot_test.lua` — gate scripts
- `cpnet-z80/dist/` — DRI reference binaries (read-only, frozen)
- `/tmp/cpnos_writes/` — server-flushed copies of written files (populated during tests)
