# RC700-SYSGEN Project Timeline

## Phase 1: SYSGEN Reconstruction (Apr-May 2023)
- **2023-04-28**: Initial commit. SYSGEN.ASM from CP/M 2.2 source, RCSYSGEN.COM from RC702 system
- **2023-04-28**: MAC assembler chosen (Digital Research native CP/M assembler)
- **2023-04-29**: SYSGEN.COM byte-identical to RCSYSGEN.COM — first byte-exact reconstruction
- **2023-04-29**: Multi-density track/sector mapping documented (mini/maxi translation tables)
- **2023-05-07**: Added SYSTEM.ORG for reference comparisons

## Phase 2: Toolchain Modernization (Sep 2025)
- **2025-09-21**: Added zmac assembler (macOS native) — cross-assembly without CP/M emulator
- **2025-09-21**: Toolchain decision: zmac with DRI syntax compatibility over MAC under emulation

## Phase 3: ROA375 Boot PROM (Jun 2025, then Feb 2026)
- **2025-06-29**: Added ROA375 autoload PROM binary and ROB358 (RC703 variant) source reference
- **2026-02-08**: Ghidra seeding script for ROM analysis; Makefile for SYSGEN
- **2026-02-08**: Fresh ROM disassembly started with PORT14 documentation
- **2026-02-09**: Byte-exact disassembly of ROA375 achieved (z80dasm + manual cleanup)
- **2026-02-10**: Raw disassembly converted to annotated style with EQUs and labels
- **2026-02-11**: CLAUDE.md created; rob358.mac adapted for zmac
- **2026-02-14**: Systematic documentation: port values, CRT work area, comment style standardized

## Phase 4: ROA375 C Rewrite (Feb 16-19, 2026)
- **2026-02-16**: Architectural decision: rewrite ROA375 in C using z88dk with sdcc backend
- **2026-02-16**: z88dk toolchain added; autoload-in-c/ scaffold created
- **2026-02-16**: Full C implementation: boot logic, FDC driver, HAL abstraction, host tests
- **2026-02-17**: Code too large for 2KB PROM — all C moved to hand-written assembly
- **2026-02-17**: Key decision: switch to sdcccall(1) ABI — params in A/HL/DE
- **2026-02-17**: Reversed course: globals-only C experiment showed sdcc can be small enough
- **2026-02-18**: Progressive migration back to C: boot7, hal_delay, init functions
- **2026-02-18**: Final result: 1984 bytes (64 to spare), boots in rc700 emulator
- **2026-02-19**: CRT/display interrupt handler documented and renamed

## Phase 5: CP/M BIOS Reverse Engineering (Feb 19-21, 2026)
- **2026-02-19**: BIOS RE analysis started — imd2raw.py extracts Track 0 from disk images
- **2026-02-20**: jbox.dk rel.2.1 BIOS sources obtained — modular structure identified
- **2026-02-20**: 58K Compas BIOS disassembled from disk image, byte-verified
- **2026-02-20**: verify_bios.py created for automated BIOS verification
- **2026-02-21**: patch_bios.py, imdinfo.py tools created for disk image manipulation
- **2026-02-21**: Conditional assembly restructured: COMPAS renamed to REL14
- **2026-02-21**: CONFI.COM reverse engineered (SIO label swap bug discovered)

## Phase 6: BIOS Source Reconstruction — All 13 Variants (Feb 21 - Mar 1, 2026)
- **2026-02-21**: rel.2.3 MAXI build added; RC703 analysis began
- **2026-02-24**: PHE358A.MAC analyzed (RC702E variant PROM with RAM disk)
- **2026-02-25**: bin2imd.py: RC703 format support added
- **2026-02-27**: 14 unique BIOSes extracted from 20 disk images
- **2026-02-27**: MAME boot testing: UPD765 ST0 HD bit regression discovered
- **2026-02-28**: REL20 conditional assembly added — 5 variants from shared source
- **2026-03-01**: All 13 BIOS variants byte-verified:
  - src/ (shared): REL20, REL21, REL22, REL23-mini, REL23-maxi (5)
  - src-58k/: REL13-mini, REL14-mini, REL14-maxi (3)
  - src-rc703/: REL10, REL12, RELTFj (3)
  - src-rc702e/: REL201-mini, REL220-QD (2)

## Phase 7: REL30 New BIOS Development (Mar 1-3, 2026)
- **2026-03-01**: BIOS rel.3.0 created — new features, not a reconstruction
- **2026-03-01**: SIO ring buffer (256B, page-aligned) + PIO keyboard ring buffer (16B)
- **2026-03-01**: 8-N-1 at 38400 baud on SIO Channel A (was 7-E-1 at 1200)
- **2026-03-01**: Bidirectional serial verified: PIP file transfer byte-identical
- **2026-03-02**: RTS flow control with hysteresis (deassert at 248, re-assert at 240)
- **2026-03-02**: AUTOEXEC.COM disassembled; run_mame.sh automation script
- **2026-03-03**: Ring buffer optimization: register-cached TAIL, parametric size
- **2026-03-03**: SCROLL optimization: unrolled LDIR into 16-wide LDI loop (20% faster)

## Phase 8: CP/NET Implementation (Mar 4-6, 2026)
- **2026-03-04**: SNIOS.SPR written (1280B Z80 assembly): hex-encoded CRC-16 serial framing
- **2026-03-04**: Python CP/NET server: BDOS F13-F40, F64-F65, F70-F71 over TCP
- **2026-03-04**: SPR relocatable format implemented (dual-assembly bitmap technique)
- **2026-03-04**: File transfer validated: 204KB BIGFILE.DAT, 1600 records, zero packet loss
- **2026-03-06**: Automated test suite: autotest.lua (MAME Lua) + run_test.sh orchestrator
- **2026-03-06**: imd_cpmfs.py: CP/M file injector for IMD disk images
- **2026-03-06**: Server expanded: F28/F30/F33-F35/F40 handlers added
- **Key decision**: Custom hex-encoded CRC-16 protocol (from cpnet-z80 serial SNIOS)
  over DRI's original ENQ/ACK protocol — simpler, proven in other Z80 implementations
- **Key decision**: BIOS READER/PUNCH entry points for I/O (not direct SIO access)
  — simpler SNIOS, ring buffer handled by BIOS ISR

## Phase 9: RC702E Modular Source (Mar 7, 2026)
- **2026-03-07**: RC702E BIOS split into modular source files (current branch: rc702e-modular)
- **2026-03-07**: Work area 0xFFD0-0xFFFF mapped with ORG+DS layout

## Phase 10: CP/NOS autoloader PROM — bring-up (Apr 20, 2026)
- **2026-04-20**: New subtree `cpnos-rom/` — combined autoloader + runtime BIOS image
  intended to burn into RC702's two 2 KB EPROMs.  Goal: cold-boot a CP/NOS slave
  directly from PROM, no 8″ floppy required.  **(Easy)** basic skeleton (reset.s,
  linker script, clang Z80 build) landed in hours.
- **2026-04-20**: PROM-disable hazard diagnosed and fixed — `OUT (0x18),A` has
  to be issued from RAM-resident code, not from PROM-backed code that's about
  to vanish from under the program counter.  **(Hard)** MAME boot test reliably
  reproduced the hazard only after explicit PROM-mapping assertions were added.
- **2026-04-20**: SIO-B (polled) + SIO-A (transport) + CTC bring-up in C;
  38400 8N1 TX verified.  **(Easy)** — same ports as rcbios-in-c, semantics
  unchanged.
- **2026-04-20**: Netboot protocol wired end-to-end against the Python server;
  cold-boot fetches a remote image into RAM.  First hang was in FNC=4 (execute)
  — server-side protocol quirk, not Z80 side.  **(Medium)**

## Phase 11: CP/NET on bare CP/NOS — real NDOS/CCP (Apr 20, 2026)
- **2026-04-20**: Ported SNIOS from rcbios-in-c into cpnos-rom, dropped BIOS_BASE
  to 0xF200 to make room; SNDMSG/RCVMSG round-trip PASS.  **(Easy)** — SNIOS was
  already hardware-independent above the BIOS layer.
- **2026-04-20**: DRI .SPR page-relocator written in C — streams NDOS.SPR and
  CCP.SPR from the server, walks the bitmap, installs at chosen RAM addresses.
  **(Hard)** the 128-byte "ignored sector" at the head of the .SPR threw off
  the relocator until the alignment bug was caught.
- **2026-04-20**: CCP reaches PC inside NDOS entry — first sign the relocated
  modules are cross-calling correctly.
- **2026-04-20**: 8275 CRT + 8237 DMA bring-up in C; display refreshes from RAM.
  **(Medium)** — CRT parameter values were transcribed from rcbios-in-c, DMA
  autoinit-mode discovered experimentally.
- **2026-04-21**: Zero-page convention switched from null-trap to real WBOOT
  vector so NDOS's TLBIOS-walk patches the right BIOS JT.  **(Hard)** —
  debugging NDOS's opaque post-handoff behaviour required memory dumps at
  multiple instants to find where page 0 was getting scribbled.
- **2026-04-21**: SIO-B captured to `/tmp/cpnos_siob.raw`; ^C warm-boot via
  SIO-B injection works.
- **2026-04-21**: Server gains full CP/NET BDOS surface: OPEN/READ/WRITE,
  SEARCH FIRST/NEXT, MAKE, DELETE, RENAME, GET VERSION, plus R/O and SYS
  attribute handling.  `$$.SUB` automation lets MAME execute scripted
  CCP command sequences for regression tests.

## Phase 12: DRI CP/NOS monolith build (Apr 21, 2026)
- **2026-04-21**: `cpnos-build/` — a separate subdir that runs DRI's original
  RMAC+LINK under VirtualCpm (Java) to assemble and link `cpnos.asm` +
  `cpndos.asm` + `cpnios.asm` + `cpbdos.asm` + `cpbios.asm` into one
  flat `cpnos.com` image.  **(Medium)** — most friction was in VirtualCpm
  invocation, not the 8080 sources themselves.
- **2026-04-21**: Link addresses relocked to `CODE=0xD000 / DATA=0xCC00`
  so CP/NOS doesn't collide with our resident BIOS + display RAM above.
- **2026-04-21**: `dri_split.py` + `dri2gnu.pl` bridge — one-instruction-per
  -line reformatted DRI sources, then mechanical translation into GNU-as
  Z80 syntax.  Enables double-assembly for byte-verification of CCP.SPR.
- **2026-04-21**: First full boot: `cpnos.com` streams from server, NDOS
  routes BDOS through SNIOS, CCP reaches `A>`.  **This was the first
  end-to-end PASS.**

## Phase 13: MP/M II retarget (Apr 22, 2026)
- **2026-04-22**: Decision: replace the Python proxy server with a live
  MP/M II running on the host under z80pack cpmsim.  Goal: prove the
  stack works against a stock unmodified master.  Motivation: the Python
  server risked drifting into a bespoke protocol the DRI slave wouldn't
  accept on real MP/M.  **(Hard)** the decision itself — and documenting
  which MP/M version + disk images to use.
- **2026-04-22**: `netboot_mpm.c` replaces the legacy FMT=0xB0 custom
  protocol with standard CP/NET 1.2 LOGIN (fn 64) + OPEN (fn 15) +
  READ-SEQ (fn 20) + CLOSE (fn 16) against a virtual A:CPNOS.IMG.
  **(Medium)** — the DRI functions were documented but MP/M's exact
  response framing needed trial-and-error.
- **2026-04-22**: `netboot_server.py` rewritten to implement the same
  CP/NET 1.2 surface, so the slave can be tested without cpmsim running
  — the two servers are now wire-compatible.
- **2026-04-22**: SLAVEID normalized to 0x01 end-to-end (was 0x70 from
  historical RC-in-house choice).  `Makefile: $(OBJS): Makefile` dep
  added after a stale `cfgtbl.o` sent 0x70 on the wire despite flag
  change — **(painful)** lesson in build-graph hygiene.
- **2026-04-22**: BIOS_BASE moved 0xF200 → 0xED00 (RESIDENT grows 1.5 KB
  → 2.75 KB).  Three follow-up bugs fell out: IVT at 0xF100 got copied
  over by the resident memcpy (fixed by moving IVT to 0xEC00, issue #35
  added a linker ASSERT); SNIOS JT constant in cpnios.s stale; impl_wboot/
  impl_boot traps re-pointed at 0xD000 (issue U).  **(Hard)** — each bug
  was silent at build time and only showed up as a mid-boot lockup.

## Phase 17 summary (wrap-up)
- **Goal reached 2026-04-22**: "CP/NOS on a physical RC702 against a
  live MP/M II over serial" validated in emulation — cpnet-smoke PASS
  with stock MP/M (z80pack mpm-net2) serving a slave that assembles a
  1000-iter unrolled program via M80 + L80, executes it, and prints
  the correct checksum.  Eight commits this session; closed #40 and
  #41; filed #43/#44/#45 for polish work.
- **Lessons crystallized**:
  - When the network clearly delivers correct bytes (TYPE works,
    buffer dumps match disk), stop theorizing transport bugs and
    look at *interpretation* differences (CRLF, segments, ABI).
  - BDOS return codes are *function-specific*: OPEN (fn 15) returns
    0..3 on success, 0xFF on fail — don't apply the generic
    "0 ok / non-zero error" heuristic.
  - A Lua tap on 0x0005 with per-call DMA-buffer dump is the single
    most valuable diagnostic we have for slave-side BDOS behavior.
    Kept as permanent infrastructure in mame_smoke_dump.lua.
  - Any text file destined for a CP/M disk image needs CR+LF.  Saved
    as a standing memory rule.

## Phase 17: cpnet-smoke harness + "DIR was a Python false positive" (Apr 22, 2026)
- **2026-04-22**: User asked for a non-trivial regression test that
  exercises the OS end-to-end by having the on-master assembler (M80)
  compile a computed program on the slave's behalf.  Scaffolded
  `testutil/sumtest.asm` (fully unrolled sum-of-1..1000 = 0xA314),
  `mksmokeasm.py`, `mksmokedisk.sh`, `smoke_inject.py` (prompt-aware
  SIO-B sequencer with per-char pacing), and `Makefile: cpnet-smoke`.
  Per user direction: pass oracle = what the program prints,
  not byte-exactness of artifacts — any CP/NET read/write corruption
  makes the assembler emit a wrong COM → program prints wrong
  string → test fails.  **(Medium)** — several orchestration gotchas
  (RMAC label mangling was old; new ones: M80 source extension,
  SIO-B FIFO overrun from burst-inject).
- **2026-04-22**: **Fourth fragility class discovered.**  Multiple
  recent "A>" successes — including today's DIR test against what we
  thought was MP/M — were actually served by a stray
  `python3 netboot_server.py` still listening on :4002 from an
  earlier manual test.  MAME's bitbanger bound to it instead of
  cpmsim-hosted MP/M; Python's mock CP/NET responses looked plausible
  enough to fool the test harness.  Killing the zombie Python exposed
  that real MP/M gets past LOGIN (NB_step=0x03) but OPEN returns
  rc=0x02.  **(Painful)** — had to backtrack days of work because
  the oracle was wrong.  Filed #42 for test-hygiene guard.
- **2026-04-22**: Related finding: `cpnos.com` on stock
  `mpm-net2-1.dsk` (4292 B) targets z80pack's generic slave, not our
  RC702 BIOS/SNIOS layout.  Even with MP/M serving correctly, the
  fetched image would drive wrong I/O.  `mksmokedisk.sh` now
  overwrites CPNOS.IMG with our `cpnos-build/d/cpnos.com`.
- **Remaining:** #40 — real-MP/M OPEN rc=0x02 after LOGIN.  Harness
  (#41) blocked on this.
- **2026-04-22 (post-compact)**: **#40 fix identified.**  `rc=0x02` is
  NOT an error — it's a CP/M BDOS OPEN success code.  BDOS fn 15
  returns directory code 0..3 on success (the found entry's offset
  mod 4), 0xFF on not-found.  `netboot_mpm.c` treated any non-zero
  rc as failure; changed the guard to `if (rc >= 0x04) return 0;`.
  **(Easy)** once misread — hours were burned assuming 0x02 was an
  error code before re-reading the BDOS spec.  Underscores the rule:
  when a retcode looks weird, check whether it's BDOS-passthrough
  (raw directory code) vs. CP/NET transport (normalized 0/0xFF).
- **2026-04-22 (later still)**: **cpnet-smoke PASS.**  Program
  assembled on the slave by M80+L80 over CP/NET prints
  `CPNET OK A314` — sum(1..1000) & 0xFFFF computed correctly.
  Root cause chain (not what I first thought): **M80 requires
  CR+LF line endings.**  Our generator wrote LF-only source; M80's
  line scanner couldn't recognize statement boundaries, so every
  pseudo-op including `END` read as part of a single mega-line.
  Buffer-content dump via Lua tap (reading M80's read-DMA area)
  proved the file *did* reach M80 with END in it — M80's parser
  just didn't see it without the CR.  Two secondary source-level
  bugs surfaced after that: (a) M80 defaults to relocatable, need
  explicit `ASEG` for CP/M .COM output; (b) BDOS PRINTS (fn 9)
  does not preserve HL, so the print-then-format logic needs
  PUSH/POP H around the BDOS call.  Saved `feedback_crlf_cpm_disk`
  as a standing rule.  **(Painful → Easy once found)** — seven
  rounds of "it's CP/NET extent handling" / "it's READ_SEQ return
  values" / "it's source syntax" before the buffer-dump made the
  CR-LF gap obvious.  Deep lesson: when content clearly reaches
  the target correctly, look for *interpretation* differences
  before blaming transport.
- **2026-04-22 (late)**: Netboot fix validated end-to-end — CP/NOS
  loads, banner, CCP prompt, M80 + L80 run.  But assembled program
  is empty (3-byte stub).  Built cpnet-smoke harness with TYPE +
  M80 + DIR + L80 + exec stages, a saturating uint8 counter per
  CP/NET FNC at 0xEC80..0xECFF (plus 16-bit READ_SEQ at 0xEC7E),
  and a MAME Lua tap on 0x0005 to capture the **full** BDOS call
  stream (6351 calls in a typical run).  TYPE reads the source
  perfectly — CP/NET READ is not the transport-level problem.
  zmac assembles the same source cleanly — the source is valid.
  **Hypothesis confirmed via trace analysis:** M80 issues exactly
  17 READ_SEQ calls per OPEN regardless of file size (tested with
  TINY.ASM=20B and SUMTEST.ASM=5790B).  Since TINY.ASM fits in a
  single record, 16 of those reads are past-EOF.  Implication: the
  CP/NET slave chain (SNIOS → NDOS → slave BDOS) is returning
  `rc=0` (success) for past-EOF reads instead of `rc=1` (EOF),
  so M80 never sees the EOF signal that would make it finalize
  assembly.  Next: instrument the return value (A on BDOS RET)
  to prove it, or fix the NDOS/BDOS EOF path in our cpnos.com
  build.  **(Hard)** — needed three distinct diagnostic layers
  (FNC counter, BDOS tap, trace analysis) to triangulate.

## Phase 16: First end-to-end DIR against live MP/M (Apr 22, 2026)
- **2026-04-22**: CONST/CONIN echoed `F G H I` (0x46..0x49) for input
  `d i r \r`.  Diagnosis via a 4-slot CONIN input ring at 0xEC46+:
  impl_conin delivered the correct bytes `64 69 72 0d`.  The corruption
  was in the monolith's cishim/cshim: `mov a, l` after the call, on
  the assumption sdcccall(1) returns 8-bit values in L.  Disassembly of
  impl_conin / impl_const showed both end with `ld a,d; ret` — clang
  Z80 returns 8-bit in **A**, not L.  Fixed by removing `mov a, l`.
  **(Painful)** — the stale HL happened to track the input-ring scratch
  address, producing a deceptively-plausible incrementing pattern that
  looked like an off-by-one input bug rather than an ABI mismatch.
- **2026-04-22**: **First successful DIR over the wire.**  CP/NOS slave
  in MAME, bitbanger SIO-A to TCP 4002 = z80pack cpmsim mpm-net2 MP/M II
  master.  `A>dir` lists `CCP SPR / CPNETLDR COM / CPNOS IMG / NDOS SPR
  / PIPNET COM ...` — real files on `mpm-net2-1.dsk` served by MP/M's
  stock CP/NET server through our RC702-retargeted cpbios + cpnios-shim.
  CONOUT=254 for that one command, confirming full BDOS+NDOS+BIOS chain.
  The goal ("physical RC702 against live MP/M over 38400 8N1") is met
  in emulation; physical hardware next.

## Phase 15: Remote drives for slave workload (Apr 22, 2026)
- **2026-04-22**: `z80pack/cpmsim/mpm-net2` launcher now stages four disks:
  A=mpm-net2-1 (boot + CPNOS.IMG), B=cpm22-1 (DRI/MS assemblers: ASM, MAC,
  RMAC, M80, L80, LINK, Z80ASM, SLRNK, CREF80 + DDT/SID/STAT/PIP),
  C=cpm22-2 (sources: BIOS.Z80, BOOT.Z80, SURVEY.MAC, W.ASM, CLS.MAC,
  BYE.ASM, SPEED.C), D=mpm-net2-2 (MP/M system image kept around for
  tinkering).  Goal: prove CP/NET remote file access with a real workload
  (e.g. `B:MAC C:SURVEY.MAC`).  **(Easy)** — slave `cfgtbl.c` already
  declared A/B/C/D as network-mapped to master drives of the same letter,
  so no slave-side change was needed.
- **Pending:** confirm MP/M `SERVER.RSP` exposes B: and C: to slave
  SID=0x01; if not, reconfigure via GENSYS or direct edit.

## Phase 14: RC702 retarget of DRI reference modules (Apr 22, 2026)
- **2026-04-22**: Decision: the slave must NOT ship DRI's Altos-targeted
  reference code.  The stock `cpbios.asm` bangs ports 0x1C/0x1D/0x1E/0x1F
  (Altos console) and `cpnios.asm` bangs 0x3E/0x3F (Altos serial) — both
  absent on RC702.  **(Easy, once it was seen.)**
- **2026-04-22**: `cpnos-build/src/cpbios.asm` added — RC702 BIOS as a
  trampoline into the cpnos-rom resident at 0xED00+.  17-entry JT matches
  DRI's ABI exactly; CONOUT/CONIN/CONST/LIST shims translate CP/M's
  C-register arg convention and A-register return into clang's sdcccall(1).
- **2026-04-22**: Two RMAC syntax pitfalls surfaced during the cpbios
  retarget.  **(Very hard — silent failures.)**  First, `jmp` is a reserved
  mnemonic; `jmp_op equ 0c3h` assembled but resolved to zero, so the
  zero-page `sta 0000h / sta 0005h` wrote NOPs and CP/M saw a broken
  BDOS vector.  Second, RMAC truncates labels containing underscore, so
  `const_shim` appeared in the sym table as `CONST` and JT entries
  referencing the full name resolved to `JP 0x0000`.  Fixed by renaming
  to short no-underscore labels (`jpopc`, `cshim`, `coshim`, …).
- **2026-04-22**: `cpnos-build/src/cpnios-shim.asm` — 24-byte trampoline
  from the DRI SNIOS JT slot (linked at NIOS=`0xD993` in the monolith)
  into our resident SNIOS JT at `0xEA00`.  Filename carries `-shim`
  suffix per user preference; Makefile maps `cpnios-shim.asm` →
  `d/cpnios.asm` because the link needs the module name RMAC+LINK
  expects (`NIOS:` label).  **(Easy)** now the pattern was established.
- **2026-04-22**: Both trampolines in place; first end-to-end PASS on the
  RC702-retargeted monolith: banner at row 2, `A>` at row 4, 38 CONOUT
  calls (banner 22 + prompt 4 + NDOS addenda 12).  **This closes the
  tripwire that had been blocking since the BIOS_BASE move.**

## What was Hard vs Easy (through Phase 14)

**Easy** (hours, straightforward):
- Initial cpnos-rom skeleton + clang Z80 + lld linker script.
- Porting SNIOS from rcbios-in-c (hardware-abstracted cleanly).
- Adding breadcrumb counters + Lua snapshots for post-hoc analysis.
- Local-override mechanism in cpnos-build/Makefile for shim modules.

**Medium** (a session of focused debugging):
- 8275 CRT + 8237 DMA bring-up.
- DRI .SPR page-relocator (once the 128 B skip-sector was understood).
- MP/M II CP/NET 1.2 wire protocol from DRI docs.

**Hard** (multi-session, required instrumentation to root-cause):
- PROM-disable hazard and its subtle interaction with resident-copy ordering.
- NDOS's TLBIOS-walk of the zero-page BIOS vector.
- BIOS_BASE move and the cascade of silent-until-runtime address drift.
- RMAC's reserved-mnemonic + underscore-label mangling — both assemble
  cleanly, both produce `JP 0x0000` at runtime, neither generates a warning.

**Painful** (wasted time until caught):
- **Stray Python server on :4002 fooling the oracle** — hours of
  "real MP/M" tests were actually Python.  Kill-before-test guard
  filed as #42.
- **Stock CPNOS.IMG on MP/M disk was z80pack-generic, not our RC702
  build** — even when MP/M was in the loop, the fetched image would
  have driven wrong I/O ports.  `mksmokedisk.sh` now overwrites it.

- Stale `.o` files after `-D` flag changes (SLAVEID=0x70 persisted despite
  source edit) — fixed by `$(OBJS): Makefile` dep.
- PROM1 install step missing from `cpnos-install` when `.resident` LMA
  overflowed into PROM1 — silent, produced garbage at the JT LMA.
- Chasing "baseline was flaky" for hours when really one PASS had been a
  lucky single run on an otherwise broken baseline.

## Format for ongoing entries

Each new entry should record: date, phase, what changed, and a
`**(Easy|Medium|Hard|Painful)**` difficulty marker with one-line reason.
Aggregate into a "What was Hard vs Easy" summary at phase boundaries or
when the project reaches a stated goal.

## Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| zmac over MAC | Cross-assemble on macOS without CP/M emulator |
| z88dk/sdcc for C rewrite | Only Z80 C compiler that fits 2KB PROM constraint |
| sdcccall(1) ABI | 36% smaller code than sccz80, params in registers |
| Byte-exact reconstruction | Proves understanding of original code; enables verification |
| Conditional assembly | Single source tree for 5 BIOS variants (src/) |
| Separate source trees | 58K, RC703, RC702E too different for conditional assembly |
| Ring buffers in REL30 | Enable reliable serial at 38400 baud for CP/NET |
| BIOS entry points for SNIOS | Simpler than direct SIO access, ring buffer in BIOS ISR |
| Hex-encoded CRC-16 protocol | Proven in cpnet-z80, simpler than DRI ENQ/ACK |
| Python CP/NET server | Quick iteration, handles all BDOS functions over TCP |
| verify_bios.py approach | Compares code bytes only, ignoring runtime-modified variables |
| patch_bios.py | Direct IMD patching avoids SYSGEN round-trip |
| cpnos-rom clang+lld | Z80 backend produces small, readable asm; same toolchain as autoload-in-c |
| DRI RMAC+LINK for monolith | Keep cpnos.com binary-compatible with CP/NET 1.2 semantics rather than reinvent |
| Local-override source dir | `cpnos-build/src/` overrides `cpnet-z80/dist/src/` on a per-file basis |
| -shim suffix for DRI replacements | Makes "this is our RC702 trampoline, not DRI's reference code" explicit at file level |
| Shim at 24 bytes (cpnios) | Smaller than re-implementing SNIOS on the CP/NOS side; resident owns wire logic |
| Breadcrumbs stay until goal is green | Keeps post-hoc trace analysis cheap across sessions; remove only after reliable PASS |
| Monolith addresses locked 0xD000/0xCC00 | Cpnos.com is non-relocatable; acceptable while we ship one slave hardware target |
| Live MP/M over serial as the target | Avoids bespoke-protocol drift vs. goal of stock-MP/M compatibility |

## Key Tools Created

| Tool | Purpose |
|------|---------|
| verify_bios.py | Verify assembled BIOS against reference binaries |
| patch_bios.py | Patch assembled BIOS onto IMD disk images |
| imdinfo.py | Show disk image summary (format, geometry, boot status) |
| imd2raw.py | Extract raw Track 0 from IMD images |
| bin2imd.py | Convert raw BIN to IMD format (mini, maxi, RC703) |
| run_mame.sh | Automated build+patch+launch cycle for MAME testing |
| diskdefs | RC700/RC702/RC703 disk definitions for cpmtools3 |
| build_snios.py | Build SNIOS.SPR with relocation bitmap |
| server.py | Python CP/NET server (BDOS emulation over TCP) |
| autotest.lua | MAME Lua test automation for CP/NET |
| run_test.sh | Full CP/NET test orchestration |
| chksum.asm | CP/M file checksum utility (16-bit sum) |
| bin2ihex.py | Binary to Intel HEX converter for serial transfer |
