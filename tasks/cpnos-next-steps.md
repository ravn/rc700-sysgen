# CP/NOS next steps

Forward-looking handover for the CP/NOS client work.  Historical
details live in `session24-cpnos-snios.md` and
`session29-ccp-prompt.md`; this doc is the short "where are we and
what's next" snapshot.

## Session 33 follow-up (2026-04-22) — BIOS_BASE moved + three bugs fixed

**BIOS_BASE 0xF200 → 0xED00.**  Grew RESIDENT from 0x600 (1.5 KB) to
0xB00 (2.75 KB) to make room for future SNIOS / rc700_console / whatever
else needs resident space.  BSS relocated to 0xEA20..0xEB20; stack to
0xEB20..0xED00; IVT relocated to 0xEC00 (was 0xF100 — fell inside the
new .resident range, which would have been clobbered by memcpy).
Verified end-to-end: cpnos-rom + cpnos-build + Python CP/NET server →
"RC702 CP/NOS v1.2 / A>" prompt → `dir` via natural_keyboard paste →
full remote DIR listing of MP/M's A: drive.  Commit d9feeaa (parent),
submodule bump 1858833b.

### Three bugs uncovered + fixed

- **Issue U** (#22, now closed): `impl_boot` and `impl_wboot` were
  unconditional `resident_entry(0)` fallback traps.  CP/NOS's warm-boot
  path hit them and dropped into our "CPNOS" banner instead of
  re-entering CCP.  Now `jump_to(0xD000)`.
- **`cpnos-build/s/cpnios.s` stale `_snios_jt` constant.**  Was
  `.equ _snios_jt, 0xF233` (= old BIOS_BASE + 0x33).  After the move
  it pointed into dead RAM, so NDOS's `call nios+0` → garbage →
  NDOS "Init Err".  Changed to `0xEA00` (NDOS-contract SNIOS JT copy
  address), which is stable across future BIOS_BASE moves.
- **IVT at 0xF100 fell inside .resident (0xED00..0xF24B).**  setup_ivt
  wrote IVT entries, then the memcpy that populates .resident clobbered
  them with impl_conout bytes.  Symptom: no keyboard input — PIO-A
  IRQ vectored to code bytes interpreted as an address = garbage.
  Fixed by relocating IVT to 0xEC00 and running memcpy before
  setup_ivt.

### Closed (out of scope, scope-locked 2026-04-25): drive B: as a local floppy on CP/NOS

**Scope decision (user, 2026-04-25):** "I do not want local floppy
support in CP/NOS. It was not designed for that, and bolting it on is
out of scope for now." Future sessions: do not re-propose this. If
the scope is reopened, a new decision must be recorded here first.

**Finding (2026-04-25, branch `fdc-variant`):** Adding a local 8" floppy
as drive B: to a CP/NOS slave is **impossible without replacing the
BDOS** — and that's by DRI's intention, not an oversight.

The smoking gun is the first line of `cpnet-z80/dist/src/cpbdos.asm`:

```
; diskless BDOS for CP/NOS - functions 0-12 only.
; may be ROMable
```

CP/NOS was designed in 1982 as a "diskless workstation" — a slave node
that boots over CP/NET and has *no* local mass storage.  Its BDOS is
intentionally stripped down to console + string I/O (functions 0–12);
all disk operations are handled by NDOS, which routes them over CP/NET
to a master node with the actual disks.  `cpbdos.asm` contains zero
references to `seldsk`, `read`, `write`, or any disk function — it
simply does not implement BDOS fns 14, 15, 17, 18, 20, 21, or 22.

The work on `fdc-variant` proved this end-to-end:
- Built a complete FDC primitive layer (`fdc.c` — init, recalibrate,
  seek, sense_int, READ DATA, DMA ch1 setup) from clean source
  inspired by rcbios.  It is correct and reachable: `fdc_init` fires
  at cold boot via `init_hardware`, and the SPECIFY command bytes
  are observed leaving on FDC port 0x05.
- Built a CP/M disk layer (`disk.c` — DPB via DISKDEF macro, DPH,
  hostbuf-aliased dirbuf, `impl_read` with 128↔512 deblocking, real
  15-entry skew-4 xlate table for 8" maxi MFM).
- Wired BIOS JT entries SELDSK/SETTRK/SETSEC/SETDMA/READ to those
  impls, including the asm push/pop ABI shims in `cpbios.asm` and
  matching `rb*` equs in cpnos-build.
- Confirmed that NDOS's `chkdsk` correctly classifies B: as LOCAL
  when `cfgtbl.drive[1] = 0x0000` and routes via `tbdosp` (jump
  back to BDOS) rather than the network path.
- Built an MFI-format acceptance disk via a new `mkmfidisk.sh`
  utility (kept on main; useful in its own right) populated with
  RC703 CP/M utilities, mounted on MAME's `-flop1`.

A MAME CPU-fetch trace of the resulting `dir b:` test showed the
exact failure mode:
- `fdc_init` fired once (cold boot), then 3× `fdc_write` for SPECIFY.
- `_bios_seldsk` (our JT entry) — **0 fetches**.  Same for SETTRK,
  SETSEC, SETDMA, READ.  Same for the NDOSRL+0x300 copies of those.
- BDOS at 0xD9B1 — 1100+ fetches.
- BIOS.CONST + BIOS.CONOUT — fetched, working as expected.

So NDOS is reaching BDOS for fn 17 (SEARCH FIRST) on local B:, but
BDOS has no fn-17 dispatch entry, returns with garbage HL/A, and
CCP loops printing the residual "dir b:" bytes from the 0x0080
DMA buffer (left over from CCP's earlier read of the SUB file via
CP/NET on A:) until timeout.

**Three theoretical paths forward, each substantial:**

1. **Replace `cpbdos.asm` with a full CP/M 2.2 BDOS.**  NDOS keeps
   its network intercept; for local drives, `tbdosp` lands on a
   BDOS that does the standard SELDSK/SETTRK/READ chain through our
   already-working BIOS shims.  Drops "diskless ROMable" property —
   monolith grows from ~3.4 KB to ~6 KB, requiring TPA shrink.

2. **Port disk fns into `cpbdos.asm` locally.**  Add fn 14/15/17/
   18/20 (+ 16 close, optionally 21/22 for write).  ~600 lines of
   asm from the public CP/M 2.2 BDOS source.  Same monolith-size
   issue as (1).

3. **Bypass BDOS for local drives.**  Have NDOS's `ckfcbd`-for-
   local branch call our BIOS directly and reimplement directory-
   scan logic inside NDOS.  Architecturally messy — NDOS would
   start duplicating BDOS internals — but doesn't grow the
   monolith as much.

**Decision: parked.**  None of the three paths is a session-sized
change, and the current CP/NET-based file workflow (`pip a:foo=b:bar`
across master/slave) covers the practical "transfer files between
machines" use case the local floppy was meant to enable.  The
discovery itself is the deliverable; the dead-end branch
`fdc-variant` is preserved in git for reference if anyone revisits.

What was kept on main from the dead-end:
- `cpnos-rom/PORT_OUTPUTS.md` — bit-level decode of every OUT byte
  the payload writes; useful regardless of disk plans.
- `cpnos-rom/testutil/mkmfidisk.sh` — folder → 8" DSDD MFI image
  pipeline, useful for any future work that needs a CP/M floppy
  in MAME (e.g. running the rcbios test suite).
- `rcbios/bin2imd.py` 8" maxi auto-detect support.

What got reverted:
- `fdc.c`, `fdc.h`, `disk.c`, `disk.h` (FDC primitive + CP/M disk
  layer — correct code, no path to use it).
- BIOS_BASE move from 0xED00 → 0xDD00/0xDE00 (only needed because
  the disk layer needed BSS room).
- `cpbios.asm` disk shims (dskshim/trkshim/...).
- `cfgtbl.drive[1] = LOCAL`.
- `fdc-acceptance` Makefile target.

### Open: VT100 subset on top of RC700 CONOUT

Investigate implementing a reasonable subset of VT100 terminal escape
sequences in `impl_conout` if payload budget allows.  Motivation:
lets modern CP/M software that assumes a VT100-ish host (many
ports/newer ports) drive the RC702 display without per-app config.

Sketch of scope: `ESC [` CSI parser feeding into the existing
`curx`/`cury` machinery.  At minimum: `ED` (erase display), `EL`
(erase in line), `CUP` (cursor position), `CUU/D/F/B` (cursor
move), `SGR 0` (attribute reset).  More adventurous: a subset of
`SGR` for reverse video if the 8275 attribute plane is ever wired
up.  Excludes: scroll regions (`DECSTBM`), alternate-screen buffer,
origin mode.

Budget: Phase 19c audit notes current payload 2126 B with 688 B
slack before the 0xF800 ceiling.  A minimal CSI parser + dispatch
is probably ~150-250 B; fits.

Caveats:
- `ESC` (0x1B) currently falls through `impl_conout`'s `c < 0x20`
  path into `specc()`'s default case (dropped).  Adding state for
  the CSI parser means `impl_conout` grows a multi-byte state
  machine like `xflg` already does for `start_xy`.
- Need to decide interaction with the native RC700 codes: does
  `ESC [2J` also invoke our `clear_screen`?  Probably yes — VT100
  layer sits above the RC700 layer, not beside it.
- Test coverage via extension to `testutil/acid.c`.

Park until some user workload actually needs it.

### Open: `cpnos-rom/cpnos-build/RELOCATABLE_SPR.md`

Design note captured mid-session — analysis + options for making
cpnos-build's CP/NOS monolith position-independent via DRI `.SPR`
format, plus a single external `BIOS_JT_BASE` patch point for the
cross-boundary reference to cpnos-rom's resident impls.  Originates
from the observation that DRI binaries are inherently relocatable and
we've been baking them against fixed addresses unnecessarily.  GitHub
issue #34 tracks it.  Parked until the memory-map coupling bites
again.

### Issues opened this round

| # | Title | State |
|---|-------|-------|
| 22 | Issue U — impl_wboot/impl_boot fallback traps | **closed** (d9feeaa) |
| 34 | Toolchain: SPR-relocatable monolith | open, parked |
| 35 | Linker ASSERT that .resident doesn't cover IVT range | open |
| 36 | RC700 terminal codes state machine — reopen | open, ready |
| 37 | 8" DS/DD dual-drive local support | open, deferred |

## Session 33 (2026-04-22) — cpnos-rom ↔ MP/M II + server rework

### Milestone BB reached

End-to-end CP/NOS boot against **stock MP/M II** (no proxy):

  RC702 (MAME, cpnos-rom PROMs)
    -> netboot_mpm (LOGIN fn 64 + OPEN CPNOS.IMG + READ-SEQ loop
                    + CLOSE, standard CP/NET 1.2)
    -> jp 0xD000
    -> CP/NOS NDOS pulls CCP.SPR over CP/NET as usual
    -> `RC702 CP/NOS v1.2  A>`  prompt

Then user typed `dir` interactively — DIR listing served by MP/M.
Interchangeable: the same cpnos-rom PROMs boot identically against
the reworked `netboot_server.py` (now MP/M-wire-compatible).

### What shipped

| Piece | Where | Notes |
|-------|-------|-------|
| `netboot_mpm.c` | `cpnos-rom/` (PROM1, 179 B of code) | LOGIN+OPEN+READ+CLOSE over full SNIOS framing |
| `-DNETBOOT_LEGACY` vs default | `cpnos-rom/Makefile` | `SERVER=mpm` default; `SERVER=proxy` keeps legacy 0xB0 via `netboot.c` |
| `-DRC702_SLAVEID=0x01` | `cpnos-rom/Makefile` | was 0x70; matches z80pack convention |
| `$(OBJS): Makefile` | `cpnos-rom/Makefile` | force rebuild on flag change — prevents stale cfgtbl.o |
| `CPNOS   IMG` virtual file | `cpnos-rom/netboot_server.py` _build_file_map | maps to cpnos-build/d/cpnos.com |
| Full CP/NET 1.2 wire | `cpnos-rom/netboot_server.py` | -195 lines; old 0xB0 / raw-byte protocol removed |
| LOGIN (fn 64) + LOGOFF (fn 65) | `cpnos-rom/netboot_server.py` dispatch_sndmsg | accepts any password |
| mpm-net2 launcher `cp` vs `ln` | `z80pack/cpmsim/mpm-net2` (submodule) | CCP deletes $$$.SUB per boot; cp keeps library pristine |
| CPNOS.IMG + CCP.SPR + NDOS.SPR | `z80pack/cpmsim/disks/library/mpm-net2-1.dsk` (submodule) | stock DRI files on MP/M A: |
| Provenance of mpm-net-1.2.tgz | `cpnet/Z80PACK_MPMNET.md` + tasks | cpmarchives.classiccmp.org mirror, 2008 |

### Open issues (session 33)

#### Issue W — smoke-plan tests not re-verified against new protocol stack

`cpnos-netboot`, `cpnos-warmboot-test`, `cpnos-sub-test`,
`cpnos-interactive` targets in `cpnos-rom/Makefile` were written
against the legacy SERVER=proxy (0xB0) protocol.  With the default
now SERVER=mpm, these may or may not work — not re-tested.
Retest + adjust as needed (expect trivial fixes: they just invoke
the server and MAME; both speak the new wire already).

#### Issue X — login password hardcoded

`netboot_mpm.c:53` defaults `RC702_LOGIN_PWD` to `"PASSWORD"` to
match z80pack's default `G$PWD`.  Override with
`-DRC702_LOGIN_PWD='"OTHER   "'` at build time.  For production use
a DIP-switch-driven / CFGTBL slot would be better; out of scope.

#### Issue Y — _seed_sub_file SID default stale

`netboot_server.py:235`: `_seed_sub_file(slave_id=0x70, ...)`.
Default should now be 0x01.  Only affects the $NN.SUB auto-submit
path, which cpnos-rom doesn't exercise by default — low-priority
cleanup.

#### Issue Z — `netboot.c` (legacy 0xB0) not deleted

Kept in-tree for `SERVER=proxy` builds, but `netboot_server.py`
no longer speaks that protocol.  So the only way to exercise
`netboot.c` is to git-revert `netboot_server.py`.  Decision:
keep as reference, or delete and simplify the Makefile to drop
the `SERVER=` switch.  No external user relies on either.

#### Issue AA — z80pack netwrkif CONIN bug not fixed

`z80pack/cpmsim/srcmpm/netwrkif-*.asm` still has the CONIN address
calculation bug documented in `cpnet/MPMNET_ANALYSIS.md`.  Our
setup sidesteps it via the 2007 prebuilt tarball disks.  Would need
the fix + MAC+LINK+GENSYS+PUTSYS rebuild to produce fresh disks
from sources.

#### Issue BB — PCB530 real-hardware path blocked by 4 KB PROMs

`netboot_mpm.c` lives in PROM1.  Real PCB530 hardware has only 2 KB
PROMs per the user.  Need either to squeeze the loader into PROM0
headroom (currently ~2 B free — not happening) or accept MAME-only
for now.  Deferred pending HW validation interest.

### What's usable right now

- `python3 netboot_server.py 4002` → full CP/NOS boot + interactive A>.
- `z80pack/cpmsim/mpm-net2` → full CP/NOS boot + interactive 0A> on
  MP/M itself (observed SID 0x01 throughout after session 33 fixes).
- Both consume the same cpnos-rom PROMs; flip between them by
  starting the other server.

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

## Session 36 (2026-04-25/26) — RC code into PROM, cpnos.com → near-pure DRI

Two-phase refactor that closes the architectural seam that bit us in
session 35 (cpnos.com had stale `rbcout = 0xDE0C` after a resident
BIOS-JT move).  Goal stated by user: "all RC-specific code in PROM,
DRI code only knows where the BIOS lives, as much C as reasonable".

**Phase 1** (commit a3941b2): moved CP/M↔clang-sdcccall(1) ABI shims
from `cpnos-build/src/cpbios.asm` (network-loaded) into
`cpnos-rom/bios_shims.s` (resident).  Resident BIOS-JT slots
ED06/9/C now `JP bios_*_shim`; cpnos.com's BIOS table now `JMP rb*`
direct.  cpnos.com -34 B.

**Phase 2A** (commit 393606c): moved boot orchestration into PROM C.
- Deleted `cpnos-build/src/cpbios.asm` (172 lines).
- New C `nos_handoff()` in `cpnos_main.c`: signon via `impl_conout`,
  memcpy resident JT 0xED00..0xED32 → 0xCF00 (NDOSRL+0x300), LDIR
  ZP[0..4].
- New thin `cpnos-build/src/cpnos.asm` (15 lines, no RC knowledge):
  set SP, ZP[5..7] = JP BDOS, JP NDOS+3.
- `cpnios-shim.asm` shrank to `NIOS EQU 0EA00h; public NIOS` — single
  line of "where SNIOS lives" knowledge.
- cpnos.com 3289 → 3099 B (-190 B total over both phases).
- Disk-install wired into `make cpnos-install` so both
  `mpm-net2-1.dsk` and `cpnetsmk-1.dsk` always carry the fresh blob.

**Subtle gotcha:** ZP[5..7] must point at `BDOS`, not `BDOS+6`.
`cpbdos.z80` puts the 6-byte serial number BEFORE the `BDOS` label,
so `BDOS` is already the dispatch entry; +6 jumped 6 bytes past it
into garbage and trapped NDOS in NWBOOT's 0x0E/0x27 retry loop.
Caught by failed cpnet-smoke, fixed in the second iteration.

**Memory note:** see `project_cpnos_address_coupling_brittle.md` for
the architectural lesson + how to spot recurrences.

## Session 36 follow-up (2026-04-26) — probe wants refresh + Phase 2B

### Probe `want` strings refreshed (issues D, F)

`mame_boot_test.lua` had four hard-coded "want" comparators that
silently drifted as resident layout / SLAVEID / Phase-2A entry stub
moved.  Fixed in this session:
- `BDOS vector want c3 06 de` → `c3 06 cc` (NDOS BDOSE intercept).
- `cfg_addr = 0xF4D4` → `0xEA46` (current `_cfgtbl`; comment now
  points at `payload.elf` for re-lookup).
- `SLAVEID want 0x70` → `0x01` (session 33).
- Removed the 0xDF21 monolith-BIOS-JT probe (cpbios.asm is gone).
- `BOOT[0xD000..2]` reframed as `c3 ?? ??` (JP-opcode invariant);
  byte 1..2 shift on every link.

Ran `cpnos-netboot` after: all four "want" lines now match actual.

### Phase 2B — cpnos.asm eliminated, NIOS-shim kept

Did the cpnos.asm half of Phase 2B; **chose not** to eliminate
cpnios-shim.asm.

Done:
- cpnos-build/Makefile: dropped `cpnos` from `MODULES`; LINK uses
  destfile syntax `cpnos=cpndos,cpnios,cpbdos[...]`.  cpnos.com now
  starts at NDOS+0 = `JP NDOSE`; NDOS+3 = COLDST = 0xD003.
- cpnos-build/src/cpnos.asm — deleted (15 lines).
- cpnos-rom/Makefile: new rule generates `clang/cpnos_addrs.h` from
  `cpnos.sym` (one perl line; emits `#define CPNOS_BDOS_ADDR 0xD996`).
  `cpnos_main.o` depends on the header.
- `cpnos_main.c::nos_handoff()`: `ZP_INIT[5..7]` now set to
  `JP CPNOS_BDOS_ADDR` (was: cpnos.asm's `lxi h, BDOS; shld 0006h`).
- `resident.c`: new `enter_coldst()` (resets SP=0x100, JP 0xD003).
  `impl_boot` and `impl_wboot` route through it; `cpnos_main`'s
  tail also calls it.  Single source for "where COLDST lives".

Caught en route by warm-boot smoke (would have shipped silently
otherwise): pre-fix `impl_wboot` was `jump_to(0xD000)`, which after
Phase 2B is `JP NDOSE` not the entry stub.  Warm boot landed in NDOS
BDOS-dispatch with garbage args and never re-fetched CCP.SPR.

Not done — kept cpnios-shim.asm:
- DRI LINK has no `--defsym` equivalent.  cpndos's `EXTRN NIOS`
  *needs* a `.rel` publishing `NIOS = 0xEA00`.  Alternatives were
  (a) generate the `.asm` in a Makefile here-doc — moves the source
  uglier without removing it, (b) write a custom `.REL` emitter —
  significant code for zero functional gain.  Keeping the file is
  the cleanest expression of the single fact "NIOS = 0xEA00".
- Comment in `cpnios-shim.asm` documents this so future-me doesn't
  re-attempt.

Smoke (4/4 PASS post-Phase-2B):
- `cpnos-netboot` cold boot to A>
- `cpnos-warmboot-test` ^C → CCP.SPR re-fetch (3 OPENs)
- `cpnos-sub-test 'dir'` 14 files from MP/M A:
- `cpnos-sub-test 'mac sysgen|load sysgen'` 1401 B SYSGEN.COM (same
  as Phase 2A baseline)

cpnos-build/src/ is now down to the 17-line cpnios-shim.asm — single
source file, single fact, no further reductions worth the glue.

## To do later

### Phase 3 — naked-C-ify resident asm where reasonable

Today's resident asm files: `bios_jt.s`, `bios_shims.s`, `isr.s`,
`runtime.s`, `reset.s`, `snios.s`.  The user accepted naked C
(`__attribute__((naked))` + inline asm) as the preferred form for
resident shim layers.  But: **clang Z80 historically doesn't support
`__attribute__((naked))` properly** (rcbios docs note "clang: coldboot
is in clang/bios_shims.s" — they fell back to .s).  Need to test with
current clang Z80 build before committing to a migration plan.

Candidates for migration if naked works:
- `bios_shims.s` → naked functions in resident.c
- `isr.s` ISR top-halves → naked C with inline `ex af,af'; exx`
- `runtime.s` memcpy/jump_to → mostly clang builtins + one naked

`reset.s` and `snios.s` stay as asm.

### MP/M disk rebuild

Today (2026-04-25/26) the pre-built `mpm-net2-1.dsk` / `cpnetsmk-1.dsk`
are treated as opaque inputs.  `z80pack/cpmsim/srcmpm/` has Udo Munk's
XIOS sources (bnkxios-net-{0,1,2}.mac, netwrkif-{0,1,2}.asm,
ldrbios.mac, boot.asm, putsys.c) but no MP/M kernel source — so a
full rebuild is not possible from the project tree alone.
- Find DRI MP/M 2 kernel source (Tim Olmstead / Gaby DRI archive).
- Wire a `make mpm-disks` target that assembles XIOS + kernel, runs
  putsys, and produces fresh `mpm-net2-{1,2}.dsk` images.
- Once buildable, increase number of slave-visible drives (the
  "only A:" comment in `cpnos-rom/testutil/mksmokedisk.sh` claims this
  as a server-side limit; needs source-level confirmation) and bump
  drive sizes for larger working sets.

### Open architectural questions

- **NDOS-walk-in-place vs JT-copy.**  Phase 2A copies the resident
  JT to 0xCF00 and lets NDOS walk that.  Could instead point ZP[1..2]
  at 0xED03 directly and let NDOS walk our resident JT in place.  The
  latter saves 51 bytes of RAM at 0xCF00 and one `__builtin_memcpy`
  call but means our JT for slots 1-5+15 gets overwritten with NDOS
  wrappers at runtime (cosmetic, since nothing else uses those slots
  post-walk).  Worth ~30 minutes' experiment.
- **BDOS_ADDR coupling.**  cpnos.asm's `lxi h, BDOS` resolves at
  cpnos-build LINK time.  PROM doesn't know BDOS's address.  If we
  ever want to drop cpnos.asm from cpnos.com, PROM needs BDOS_ADDR
  from somewhere — either cpnos.sym extraction (Phase 2B above) or
  a runtime probe (read cpnos.com's first 3 bytes after netboot to
  derive it; needs a stable convention).

## Where files live

- `cpnos-rom/netboot_server.py` — CP/NET server, dispatcher, file map
- `cpnos-rom/cpnos-build/` — CP/NOS monolithic image builder (DRI ASM → clang → ld.lld)
- `cpnos-rom/resident.c` + `init.c` + `isr.s` — our RC702 BIOS
- `cpnos-rom/testutil/` — test fixtures (done.com, copy.c/com, mac.com, load.com, sysgen.asm)
- `cpnos-rom/sio_b_driver.py` — SIO-B TCP bridge + keystroke injector
- `cpnos-rom/mame_sub_test.lua`, `mame_boot_test.lua` — gate scripts
- `cpnet-z80/dist/` — DRI reference binaries (read-only, frozen)
- `/tmp/cpnos_writes/` — server-flushed copies of written files (populated during tests)
