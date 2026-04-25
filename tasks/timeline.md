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

## Phase 19: PROM-oblivious payload + C23 #embed relocator (Apr 23, 2026) — branch `conout-codes`

- **Goal**: split the 2 KB PROM0 budget across both physical EPROMs
  (PROM0 0x0000..0x07FF + PROM1 0x2000..0x27FF) to fit a full RC700
  CONOUT control-code set (ported from `rcbios-in-c/bios.c:specc`),
  AND restructure the build so the payload linker has *no* knowledge
  of ROM geometry — class-of-bug elimination.

- **Before**: one ELF, `.reset`+`.init` packed into PROM0, `.resident`
  LMA'd into PROM0 tail, copied to 0xED00 at cold boot.  Switch
  jumptables emitted to `.rodata` landed in `.init` (PROM0) with
  absolute addresses baked in; after `OUT (0x18)` that RAM was
  overwritten by CCP TPA and the dispatch table JP'd to garbage.
  Root-caused during the first CONOUT refactor attempt when a new
  `switch (c)` in `specc()` triggered exactly this — serial trace
  showed banner then silence post-netboot.

- **After** — new architecture in 4 new files + a refactor:
  | File | Role |
  |---|---|
  | `payload.ld` | Links everything at VMA=LMA=0xED00 as one blob `.payload`.  No PROM regions, no AT(), no LMA tracking. |
  | `relocator.c` | C23 `#embed` of `payload_a.bin` (PROM0 tail) and `payload_b.bin` (PROM1), two `__builtin_memcpy`s into 0xED00, tail call to `cpnos_cold_entry`. |
  | `reset.s` | 3 instructions: `di; ld sp,0xED00; jp _relocate`.  Required because clang-z80 doesn't reliably honor `__attribute__((naked))` to set the stack before its own C prologue pushes. |
  | `relocator.ld` | Places `.reset` at 0x0000, C body below 0x80, `.prom0_tail` at 0x80, `.prom1` at 0x2000.  Knows about PROMs — that knowledge is *only* here. |
  | Makefile | Two-stage link: payload → `nm` extracts `_cpnos_cold_entry` → relocator linked with `--defsym` of that address.  `dd` splits `payload.bin` at byte 1920 into the two `#embed` inputs. |

- **Side effects / collapses**:
  - `cpnos_main.c`'s LMA-copy loop deleted (relocator does the copy).
  - `resident_entry` merged into `cpnos_cold_entry`; two-stage
    init/resident split was only there because of the LMA dance.
  - `.resident`/`.init` section attributes kept for minimal churn
    — the payload script just globs `.resident.*` + `.text.*` into
    `.payload`.  No jumptable-routing footgun anymore: switch
    tables and their readers are now co-located inside the payload.
  - `cpnos_rom.ld` deleted.
  - `impl_conout` gained full RC700 control-code dispatch (specc):
    CR, LF, BS, TAB, BEL, clear, home, erase-EOL/EOS, insert/delete
    line, cursor L/R/U/D, XY addressing (ctrl-F + two coord bytes).
    Excludes bg/fg (0x13/14/15) — need BGSTAR buffer we don't carry.

- **Sizes**: payload 2126 B at 0xED00.  PROM0 = 33 B relocator + 95 B
  pad + 1920 B payload_a.  PROM1 = 206 B payload_b + 1842 B pad.
  Both EPROMs actively used for the first time since Phase 18.

- **Smoke**: `make cpnet-smoke` PASS end-to-end.  Full CCP + M80
  assembly + L80 link + `sumtest.com` execution prints `CPNET OK A314`.

- **Lessons**:
  - A single switch statement was enough to trip the jumptable-
    landed-in-wrong-PROM class of bug.  Architectural fix > local
    workaround (`-fno-jump-tables` would have papered over it).
  - C23 `#embed` is the right tool for carrying a binary payload
    through a compile — it keeps the tool-flow declarative instead
    of Python-shell-string-munging.  Two `#embed`s + linker-placed
    sections is cleaner than one array + a runtime split.
  - Clang-z80 lacks `naked` + reliable `[[noreturn]]` tail calls —
    tiny asm shim for SP setup, accept `CALL` at end of `relocate`
    (payload's cold entry is marked noreturn, so the return slot
    is harmless).
  - Reserving a fixed 128 B budget for the relocator code avoids
    a chicken-and-egg (its size determines where payload_a lives,
    but payload_a's size is known only after the split).

- **Filed / TODO**:
  - #50 — Investigate why `memcpy`/`memmove` compile to large code
    at call sites (118 B for one `memmove` before inline-LDDR rewrite).
  - #51 — Clean up dead `build_loader.py`, `cpnos-loader` target.
  - #52 — Replace `EXX` in CRT/PIO ISRs with selective register
    save: slave programs can legally use shadow regs (was #48).
  - Earlier todo-laters still open: ISR-driven SIO-B RX ring (#44),
    MEMORY_MAP.md needs a Phase 19 refresh.

### Phase 19b: CONOUT acid test (Apr 23, 2026) — Medium

- **Goal**: reproducible test that exercises all 15 RC700 CONOUT
  control codes end-to-end (not just `make cpnet-smoke` which only
  touches print+CR/LF) and asserts the resulting 8275 framebuffer.
- **Shape**: `testutil/acid.c` — z88dk `+cpm` C program using
  stdlib `bdos(6, c)` (Direct Console I/O) to bypass BDOS fn 2's
  TAB-to-spaces expansion so raw control bytes reach our BIOS
  CONOUT JT.  `mame_acid_test.lua` boots the slave, waits for
  `DONE\r\n` on SIO-B, dumps 0xF800..0xFFFF, asserts 30 specific
  cells.  `make conout-acid` target wires it up — runs in ~7 s.
- **Lessons / footguns hit**:
  - BDOS fn 2 expands TAB to spaces at the BDOS layer; fn 6 is
    the right call for exercising raw BIOS CONOUT.
  - Don't pass `--sdcccall 1` to z88dk when linking against the
    default crt/stdlib — mismatch produces a working-looking
    .COM that corrupts its first BDOS call arg.
  - RC700 `start_xy` (0x06) coord bytes are ASCII-offset by `' '`
    (matches rcbios `specc`).  Sending raw binary col/row
    underflows `uint8_t` in `xy_step`, and our unrolled
    `mod SCRN_ROWS` only subtracts 3× — residual `val` ≥ 25
    makes `CELL()` write outside display RAM and corrupt the
    payload.  Fixed in acid.c by adding 32 to both coords; file
    a follow-up to either bound-check in `xy_step` or widen the
    mod-unroll to cover 0..255 input.
  - Netboot server's `_seed_sub_file` default was `slave_id=0x70`
    but our build hardcodes `RC702_SLAVEID=0x01`.  Added
    `CPNOS_SLAVEID` env var overriding the default to 0x01 so
    `cpnos-sub-test` and `conout-acid` both hit the right `$nn.SUB`.
- **Result**: `PASS: all 15 CONOUT codes verified at frame 370
  (7.4s emulated)`.  Display shows the full intended pattern —
  HELLO! at (20,5), smiley at rows 10-11, STAY/GONE preserved,
  erase_to_eol/eos regions blank.

### Phase 19c: payload size analysis + clang-z80 codegen audit (Apr 23, 2026) — Medium

Read-only pass over the payload (2126 B at 0xED00; 688 B slack before
the 0xF800 resident ceiling; PROM1 has 1842 B of pad).  Nothing
ROM- or RAM-constrained; savings below are tidiness, not unblocking.

- **Size-sorted symbol dump** (`llvm-nm --size-sort clang/payload.elf`):
  top 6 by function size are `netboot_mpm` (170), `port_init` (104),
  `specc` (101), `init_hardware` (99), `impl_conout` (97), `delete_line`
  (76).  Biggest data: `_msg` 200 B (CP/NET frame, fixed), `_cfgtbl`
  173 B (DRI layout, fixed).

- **Tier 1 savings (~95 B, mechanical)**:
  1. `scroll_up` triplicated — exists as 26 B symbol AND inlined in
     `cursor_right` (25 B tail of 52 B) AND `cursor_down` (25 B tail
     of 38 B).  `__attribute__((noinline))` reuses standalone copy.
     ~50 B.
  2. `xy_step` 3×-unrolled `mod SCRN_ROWS` — 48 of 68 B is two
     triple-subtracts for row + col.  Replacing with a clamp-on-
     overflow fixes the acid-test underflow bug AND shrinks the
     function.  ~35 B.
  3. `init_hardware` inlines a 4th copy of the scroll/clear LDIR —
     calling `clear_screen` saves ~10 B.

- **Tier 2 savings (~35 B, medium)**: impl_conout BSS spill of `c`
  (~12 B), cfgtbl_init LDIR-template for pointer fields (~10 B),
  port-init + IVT-fill 16-bit-for-small-count loops (~10-15 B).

- **Tier 3 uncertain (~40-80 B)**: specc switch + 60 B jumptable →
  hand-rolled dispatch; netboot_mpm `sframe` BSS spills.  Both
  higher-effort, unclear savings.

- **Nothing reclaimable**: `_msg`, `_cfgtbl`, `_FCB_HEAD`, and
  clang's per-switch `LJTI_*` jumptable overhead — all intrinsic.

- **Recursion check**: zero.  Call-graph is a DAG (Tarjan's on the
  disasm), no self-loops.  Deepest chain: 5 levels
  (`cpnos_cold_entry → netboot_mpm → cpnet_xact → snios_rcvmsg_c
  → transport_recv_byte`).  Two `jp (hl)` sites exist — one is the
  `specc` switch jumptable, other is the `_jump_to` CCP trampoline.
  Neither introduces cycles.  ISRs contain zero `CALL`s so they
  add nothing to stack depth when they fire.  Worst-case stack
  high-water ~14 B against SP=0xED00.

- **BSS spill attribution**: 13 B total across 6 functions
  (`delete_line` 4 B, the rest 1-2 B).  **Zero** of it is parameter
  overflow — every payload fn takes 0-2 args, well within
  sdcccall(1)'s register budget.  All 13 B is register-alloc
  spill of locals or parameters that can't stay live across a
  CALL or LDIR setup.

- **Push/pop vs BSS spill** (filed as ravn/llvm-z80#74): Z80
  `push hl`/`pop hl` is 2 B / 21 T for a spill-reload pair vs
  BSS `ld (nn),hl`/`ld hl,(nn)` at 6 B / 32 T.  Dropping
  `+static-stack` doesn't help — clang falls back to SP-relative
  alloca (10 B per spill side) which is +77 B worse across
  resident.c.  Minimal self-contained repro posted on the issue.
  Interesting: clang-z80 *does* use push/pop for simple "one
  value crosses one CALL" but gives up on the multi-value
  LDIR-setup shape.

- **Tail-call peephole** (filed as ravn/llvm-z80#75): TCO exists at
  `Z80LateOptimization.cpp:2913` but is MBB-local.  Common early-
  return pattern produces `CALL` in one MBB that falls through to
  a separate `RET`-only MBB — branch folding already handles the
  explicit early-return (`ret c` in-place) but misses the CALL-
  fall-through-to-RET case.  Likely pass-ordering (BranchFolding
  considers the merge before `JR_C → RET_C` drops the other
  predecessor).  Fix: run TCO peephole *after* branch folding,
  or widen it to follow the fall-through edge.

- **SDCC peephole.def vs clang**: 20+ rules in the custom
  `sdcc/peephole.def` — ALL handled by clang natively at -Oz:
  `ld a, 0 → xor a`, redundant trailing `xor a`, `out (p), a` A-
  preservation, dead `jp`/`ret` sequences, `jp X; X:` fall-
  through, `jr cond; jp` → inverted-cond consolidation.  Clang
  goes *beyond* the rules in several cases: branchless ?: (r5
  repro emits `sub 0; add ff; sbc a,a; and 1` — 7 B, zero
  branches); vectorizes 4×byte-zero into `ld hl, 0; ld (n), hl;
  ld (n+2), hl` (9 B vs SDCC's 13+ B); OUT-chain A reuse
  generalizes beyond SDCC's 2-OUT rule.  The .def file exists to
  paper over zsdcc gaps that clang doesn't have.  Nothing to
  port.

### Phase 19c follow-throughs (Apr 23, 2026) — applied

Three commits after the audit:

1. **CR inline fast-path** (`c38ff77`): `\r` (0x0D) was routing through
   the `specc()` switch jumptable (two CALLs deep); hoisting it inline
   alongside `\n` lets clang tail-merge both into the same
   `xor a; ld (curx), a` tail.  +4 B impl_conout, ~-50 T per CR,
   +7 T per printable char.
2. **CRT-ISR-deferred cursor update** (`0773f09`): `impl_conout` used
   to reprogram the 8275 cursor via 3 port OUTs per character —
   visibly flickered on fast streams.  Replaced with `cur_dirty = 1`;
   `_isr_crt` reads the flag at each VRTC and pushes curx/cury once
   per frame.  impl_conout 101→88 B, -40 T per CONOUT call, bounded
   flicker → zero.  Also trimmed two leading CR/LFs from the signon
   banner in cpbios.asm.
3. **Tier 1 shrink** (`03fbc78`): `scroll_up __attribute__((noinline))`
   (cursor_right 52→30, cursor_down 38→15), `xy_step` clamp instead
   of 3×-unrolled mod (68→50, also fixes the acid-test underflow
   bug directly instead of just dodging it in acid.c), and
   `init_hardware` calls `clear_screen` instead of inlining a 4th
   LDIR copy (99→87).  Payload .text 2126 → 2054 B (−72 B).

- Three issues filed against `ravn/llvm-z80` for codegen gaps
  surfaced during the audit (all open, no PRs yet):
  - **#74** register-alloc spills go to BSS instead of push/pop
  - **#75** `CALL; RET → JP` peephole misses on fall-through MBB
    pairs (common early-return fan-in pattern)
  - **#76** `ld a, (hl); ld r, a` not peepholed to `ld r, (hl)`

- Tier 2 (~35 B) and Tier 3 (~40-80 B) savings from the audit
  remain on the table if payload pressure returns.  Not urgent:
  760+ B slack remains below the 0xF800 resident ceiling.

### Phase 21: Tier 2 mini-pass (Apr 25, 2026) — Easy

- Investigated the audit's Tier 2 candidates.  Shipped what worked,
  filed issues for the rest.  Payload .text 2054 → 2047 B (-7 B).

- **Applied** (`init.c`):
  - `setup_ivt`: pointer-walk + 8-bit countdown loop instead of
    `for (i=0; i<18; ++i) ivt[i]=...`.  -1 B.  clang still emits a
    parallel BC pointer dance and `dec a; ld d, a; or a; jr nz`
    instead of `dec d; jr nz` — see #77.
  - `init_hardware` port-init loop: pointer-walk + 8-bit countdown,
    same shape.  Drops 16-bit DE counter for 8-bit L counter.  -7 B.
    Same flag-routing pessimism applies.

- **Tried, rejected**:
  - `cfgtbl_init` 4× sequential `cfgtbl.drive[i] = 0x80+i` →
    `__builtin_memcpy(const)`: **+19 B**.  clang refuses to inline
    LDIR for 8-byte memcpy, unrolls into a base-pointer dance.
    Worse than direct stores.
  - `impl_const` invert second `if`: 0 B.  The 12 B
    `(x != y) ? 0xFF : 0` mask chain is the same regardless of
    polarity — see #79.

- **Blocked, deferred to llvm-z80 fixes**:
  - `impl_conout` BSS spill of `c`: ~12 B, blocked on #74.
  - `netboot_mpm` `sframe` reload-after-LDIR: ~7 B, file as #78.
  - `impl_const` mask chain: ~7 B, file as #79.

- Three more issues filed against `ravn/llvm-z80` from this
  mini-pass (all open, with self-contained C reproducers):
  - **#77** 8-bit countdown loops emit `dec a; ld r, a; or a` instead
    of flag-using `dec r` (or `djnz`) — hits every countdown loop.
  - **#78** LDIR's post-state `DE = dst+count` not used; subsequent
    `dst += count` reloads from BSS.  ~10 B per occurrence.
  - **#79** `(x != y) ? 0xFF : 0` materialised as 7-instruction mask
    chain instead of 2-instruction `add a,$ff; sbc a,a`.  ~9 B per
    occurrence.

- **Verdict**: audit's "~35 B" Tier 2 estimate optimistic by ~5×.
  Real mechanical wins cap around 7 B without compiler fixes;
  rest is gated on llvm-z80.  6 issues now open against codegen.

### Phase 21b: cross-codebase codegen sweep (Apr 25, 2026) — Easy

- User asked for a wider scan: walk BIOS + autoload + CP/NOS payload
  for clang-z80 anti-patterns worth filing as enhancements against
  ravn/llvm-z80.  Three Explore agents in parallel.

- **rcbios-in-c** — clean against #74-#79.  The only oddity is the
  `push hl; pop iy; call __call_iy` indirect-call thunk used for
  `((void(*)(void))warmjp)()`; that's load-bearing for the chosen
  sdcccall(1) ABI (no native indirect-call instruction; runtime.s
  funnels through IY).  Volatile reloads in `isr_ctc_a` are
  semantically required.  No new issues.

- **autoload-in-c** — one new actionable pattern surfaced (filed
  as #80).  The mask chain in `check_sysfile` is already covered
  by #60.  Rest is clean.

- **cpnos-rom** — the deep-scan agent flagged five candidates,
  three of which are duplicates of existing issues (#60, #74) or
  semantically required.  Two genuinely new patterns are minor:
  - sequential 16-bit immediate stores to consecutive addresses
    not folded to `ld hl, K; ld (a), hl; inc hl; ld (a+2), hl;...`
    (cfgtbl_init: 4× `ld hl, $80..$83; ld (...), hl` could be
    one `ld hl` + 3 `inc hl` + 4 stores — saves ~6 B).  Not filed:
    very narrow, single-function impact.
  - tail-merge of multiple `ld de, $0; ret` early-exit paths in
    `netboot_mpm` (~3 sites).  Not filed: generic LLVM tail-merge
    territory, may be Z80 ABI-specific quirk worth investigating
    only if anyone hits it elsewhere.

- One new issue filed:
  - **#80** `ld bc, (nn)` / `ld de, (nn)` direct addressing not
    used; clang loads to HL then `ld c, l; ld b, h`.  ~1 B per
    site, mechanical fix.

- Spurious agent finding worth recording: the autoload audit
  suggested `ld (nn), (hl)` as a fold target.  **That instruction
  does not exist on Z80** — agent hallucinated.  Pattern dropped.

- 7 codegen issues open against ravn/llvm-z80 from the cpnos
  audit cycle: #74, #75, #76, #77, #78, #79, #80.

### Phase 20: drive B: as local floppy on CP/NOS (Apr 24-25, 2026) — branch `fdc-variant` — Painful

- **Goal**: give the RC702 slave a local 8" floppy as drive B:
  alongside its existing CP/NET-served drives.  Read-only initially,
  with `pip a:foo=b:bar` style file movement as the acceptance test.
- **What got built (correct, on the dead branch)**:
  - `fdc.c`/`fdc.h` — clean µPD765 primitives (init/recal/seek/sense_int/
    READ DATA + DMA ch1 setup).  Globals-based arg passing to dodge
    clang-z80's IX-frame overhead.  ~330 B.
  - `disk.c`/`disk.h` — CP/M disk layer.  rcbios's DISKDEF macro
    verbatim for byte-identical DPB derivation; `dpb_maxi_data =
    DISKDEF(15,512,2,2048,450,128,1,2)`; DPH with `xlt=NULL` so BDOS
    skips SECTRAN; xlt_maxi_side[15] real skew-4 table; impl_read
    with 128↔512 deblocking; hostbuf-aliased dirbuf saves 128 B BSS.
  - `cpbios.asm` shims (dskshim/trkshim/...) tail-calling our BIOS.
  - `cfgtbl.drive[1] = LOCAL` so NDOS's chkdsk classifies B: local.
  - BIOS_BASE relocation from 0xED00 → 0xDD00 → 0xDE00 to make
    room for the disk BSS region.
  - 8"-DSDD MFI disk-builder pipeline (`mkmfidisk.sh` +
    `bin2imd.py` 8" maxi auto-detect).
- **Wall hit**: instrumented MAME CPU-fetch trace showed
  `_bios_seldsk` and `_bios_read` get **0** fetches during
  `dir b:`.  NDOS correctly classified B: local and JP'd to BDOS,
  but BDOS never made the BIOS calls.
- **Root cause** (the deliverable): `cpnet-z80/dist/src/cpbdos.asm`
  line 1: *"diskless BDOS for CP/NOS - functions 0-12 only.  may be
  ROMable"*.  By design.  CP/NOS was a 1982 diskless-workstation
  spec — no BDOS fns 14/15/17/18/20/21/22.  Local disks need a
  different BDOS.  See `tasks/cpnos-next-steps.md` for the three
  non-session-sized fix paths (replace BDOS / port disk fns / NDOS
  bypasses BDOS).
- **Resolution**: parked.  `pip a:=b:` over CP/NET already covers
  practical file transfer.  Cherry-picked the standalone-useful
  artifacts onto main:
  - `PORT_OUTPUTS.md` (621-line bit-level OUT-byte reference).
  - `cpnos-rom/testutil/mkmfidisk.sh` + `rcbios/bin2imd.py`
    8" maxi support (any future CP/M-floppy work benefits).
  Reverted on main: fdc.c, disk.c, BIOS_BASE move, cpbios.asm
  shims, cfgtbl.drive[1]=LOCAL, fdc-acceptance target.  Branch
  `fdc-variant` preserved locally for reference.
- **Lessons**:
  - Read the asm source headers FIRST.  The "diskless BDOS" comment
    on line 1 of cpbdos.asm was the answer to the entire mystery,
    visible the whole time.  ~3 sessions of debugging in BIOS/JT/
    NDOS/cfgtbl space could have been minutes of reading.
  - RMAC 1.1 silently emits `c3 0000` for forward references >
    ~0x90 bytes (no error, no warning, just `I` prefix in the
    listing).  And RMAC 1.1 is ASCII-only — UTF-8 em-dashes/
    arrows in comments break the parser silently.  Two foot-guns
    worth a comment in `tasks/cpnos-next-steps.md` for any future
    cpnos-build edit.
  - clang-z80's `--gc-sections` is good — fdc.c/disk.c never made
    it into the live payload bytes despite being compiled and
    linked, because nothing called them.  Made the experiment
    cheap to keep around (no PROM cost) and clean to revert.

### Phase 22: CP/NET fast-link design — Option P pinned (Apr 25, 2026) — Easy

- **Goal**: pick a host<->RC702 transport that beats the current 38400-
  baud async path (~3.8 KB/s) for CP/NET + CP/NOS traffic, without PCB
  modifications, while leaving the machine "usable normally" — physical
  RC722 keyboard plugged into J4, both SIOs free for terminal/printer.

- **Design phase only.** User does not have Pi 4B / 3B host hardware on
  hand and explicitly asked for design artifacts only — no Pico
  firmware, no Z80 bench tests, no MAME patches yet. Bring-up deferred
  until hardware is acquired.

- **Investigated scenarios** (using SIO and PIO ports, no J8):
  - SIO-only async tweaks — capped at 38400 baud, dead-end without mods.
  - SIO-only SDLC — TX works but RX blocked by missing DPLL + NC TxC/RxC
    pins on J1.  Asymmetric only.
  - PIO-A (J4) repurposed for fast link — ruled out by RC722-keyboard
    constraint and missing ARDY chip pin (Mode 2 impossible).
  - PIO-B half-duplex via J3 — full handshake (BSTB+BRDY both routed),
    keyboard untouched, SIOs untouched.  ~30-50 KB/s sustained.
  - Hybrid PIO-B in + SIO-A SDLC TX — ~70 KB/s response side, costs
    SIO-A.  Documented as future upgrade if response throughput needs.

- **Pinned**: Option P — PIO-B half-duplex via J3, direction-switched at
  CP/NET frame boundaries.  Design doc at `docs/cpnet_fast_link.md`.
  Hard upper bound: ~30 KB/s in, ~50 KB/s out (8-13× current).
  Production target: Pi 4B running z80pack-as-CP/NET-master natively,
  driving J3 cable through level shifter (Topology B).  Development
  iteration shape: Mac + Pico USB-CDC (Topology A), same wire protocol.

- **Languages locked**: C (clang-z80) for Z80 BIOS, Python 3 for host
  bridge, C with Pico SDK for optional Pico firmware, C++ for MAME.

- **Superseded**: `rcbios-in-c/docs/parallel_host_interface.md`
  Mode-2-on-PIO-A plan.  Deprecation banner added; previous "three
  options" / cable-shopping notes in `tasks/todo.md` rewritten.

- **Verified hardware facts** (consolidated from sessions 16/18/20-21
  and the schematic):
  - SIO-A bit clock at ÷1 = ~614 kbaud TX-direction signaling works.
    Framing layer (SDLC vs monosync) **uncertain** — earlier
    "SDLC specifically verified" claims should be treated as
    unverified bit-level signaling only.
  - PIO-A Mode 1 input + ASTB strobe works on this RC702 (`ravn/cbl923`
    Pico keyboard rig is the existence proof).
  - PIO-B (J3) is electrically symmetric to PIO-A but has never been
    bench-tested — first bring-up step when hardware arrives.

- **Memory pinned**: project goal "fast link is CP/NET-only", "physical
  RC722 keyboard remains attached", "Pi as production sidecar (Pi
  hardware not yet acquired)" all recorded in user memory so future
  sessions inherit the constraints without re-deriving them.

- **Decision rationale formalised** (later in same day, after the
  initial design pin): user requested a thorough report in the project
  on the Option-P decision and why the alternatives were rejected.
  Added a "Decision rationale" section at the top of
  `docs/cpnet_fast_link.md` with: priority-ordered constraint list,
  full options-considered matrix (P, H, H', Mode-2, K, A1-A4, B/C
  variants, Y-cable, keyboard-relocation, J8), per-option rejection
  analysis, and an explicit "Long-term: full-speed SIO TX comparison"
  subsection capturing the user's plan to ship P, bench it, then
  build an H prototype to determine empirically whether the response-
  side throughput improvement justifies H's costs.  Existing "Option H
  alternative / future upgrade" subsection retitled "long-term
  comparison target" to match.

- **MAME bridge design specified** (same day, post-cleanup):
  expanded the "MAME side" section of `docs/cpnet_fast_link.md` from
  a 3-bullet stub to a full design spec.  Initially scoped narrowly
  (CP/NET-specific PIO-B wiring); user redirected the same day to
  a generic-slot pattern that mirrors how MAME exposes RS-232 ports.
  Branch: `cpnet-fast-link`.

  Final shape (4 changes in `ravn/mame`):
  - (1) `rc702_pio_slot_device` — generic 8-bit + STB/RDY/MODE slot
    that mirrors `rs232_port_device` for PIO ports.
  - (2) `rc702_pio_devices` slot-option list — peripherals: `nothing`
    (default empty slot), `keyboard` (existing model, slot-ified),
    `cpnet_bridge` (new, see #4), open for future entries.
  - (3) Refactor `rc702.cpp` to expose PIO-A and PIO-B as slots.
    Default config: PIO-A=keyboard, PIO-B=nothing.  Matches today's
    behaviour exactly when no `-piob` argument given.  Drops the
    incorrect 2016 comment "Printer (PIO port B commented out)" —
    PIO-B was never the printer port (printer is on a SIO channel
    per the hardware reference and per `bios.h:185-195`).
  - (4) `rc702_cpnet_bridge_device` peripheral implementing the
    slot interface — talks Z80-PIO handshake on one side, Unix/TCP
    socket on the other, same wire protocol the Pi+Pico USB-CDC
    bridge will speak in production.

  Why generic-slot framing matters: lets us run any historical
  RC702 software (CP/M, COMAL, BASIC) in MAME with PIO-B simply
  empty, exactly as on real hardware.  CP/NET activation becomes
  a `-piob cpnet_bridge:localhost:4003` command-line argument,
  not a build-time wiring decision.  Steps (1)-(3) are also a
  credible upstream MAME contribution candidate; only the bridge
  peripheral (step 4) needs to stay fork-only.  Bridge is the
  first concrete bring-up step — needs only a working `ravn/mame`
  build (already maintained) and a stub `isr_pio_par` on the Z80
  side, no Pi 4B or J3 cable required.

- **Level-shifter requirement dropped** (same day, post-rationale):
  user pointed out that the existing `ravn/cbl923` Pi Pico keyboard
  rig drives the Z80 PIO directly from 3.3V GPIO without level
  shifting, and the Z80 reads it cleanly (TTL VIH min 2.0V).  Z80 PIO
  is signal-only on J3 (no +5V or +12V rail — unlike J4 which powers
  the keyboard).  Updated `docs/cpnet_fast_link.md` cable spec, host
  side, and constraint-#5 satisfaction text:  no TXS0108E / 74LVC245
  / shifter chip required;  add 470 Ω - 1 kΩ series resistor on each
  Pico-input pin to current-limit protection diodes in the
  Z80-drives-Pico direction;  Topology B switched from "Pi 4B GPIO
  direct + level shifter" to "Pi 4B + Pi Pico over USB-CDC" so one
  firmware codepath covers both dev and production.  Cable BOM is
  now 11 wires + 9 series resistors.  Open question retained:
  measure Z80 PIO VOH on this RC702 at bring-up to confirm the
  no-shifter cable holds.

## Phase 18: PROM shrink pass (Apr 23, 2026) — branch `snios-compact`
- **Goal**: create breathing room in the 2 KB PROM0 ceiling (11 B
  slack after #39).  Target: ≥ 200 B for future work (signature
  prefix for #46, ISR-driven SIO-B ring, etc.).
- **Analysis-first**: built a per-function size breakdown of the
  2037 B payload; cross-compared with `rcbios-in-c` patterns
  (table-driven port init, shared ISR structure, SBC A,A idioms)
  to pick high-yield / low-risk changes.  See
  `cpnos-rom/MEMORY_MAP.md` + the GH issue #47 task list.
- **Tier 1 (c54229c)**: strip all trace instrumentation added
  during Phase 16-17 — SNIOS per-FNC counter, CONOUT/CONIN/CONST
  counters, CONIN ring, netboot breadcrumbs.  **-121 B** (vs ~70 B
  predicted — the compiler compacted adjacent basic blocks after
  the bumps went).
- **Tier 2a (0dae340)**: collapse ~30 inline `_port_out` calls
  in `init_hardware` + folded-in `init_pio_kbd`/`init_display`
  into one unified `port_init[]` table + for-loop.  **-39 B**.
- **Interim (9add5ba)**: smoke_inject now sends a CR nudge after
  10 s of SIO-B silence — practical workaround for issue #44 (the
  "had to type Enter manually" annoyance) until Tier 4 gives us an
  ISR-driven SIO-B ring.  Doesn't change PROM size.
- **Current slack after 12 commits**: **524 B** (from 11 B).
  | Step | Delta | Slack |
  |---|---|---|
  | main@155cca7 baseline | — | 11 B |
  | Tier 1: strip trace code | +121 | 132 B |
  | port-init table | +39 | 171 B |
  | netboot memcpy + banner trim | +90 | 261 B |
  | impl_conout dedup + no-FF | +54 | 315 B |
  | cfgtbl → BSS (runtime init) | +130 | 445 B |
  | SNIOS RECVBT tail merge | +4 | 449 B |
  | crt_scroll_up memcpy/memset + FCB trim | +29 | 478 B |
  | zero-page + JT inline LDIR | +32 | 510 B |
  | display-clear memset + 8-byte loop fix | +14 | 524 B |
- **Filed along the way**: #47 (tracking issue), #48 (ISRs unconditionally
  EXX/EX AF,AF' — unsafe), #49 (clang elides memcpy-to-0), and
  ravn/llvm-z80#73 (8-byte inline memcpy cost model).
- **Lessons**: (a) Compiler's `-Oz` inliner can still generate
  pathological code for small memcpys — always disassemble and
  measure, don't trust the intent; (b) BSS-as-ROM-substitute for
  mostly-zero static data paid the biggest single win (130 B);
  (c) Inline `ldir` via clang-z80's +{de}/+{hl}/+{bc} constraints
  is the right tool when \_\_builtin_memcpy gets UB-elided or
  cost-modeled into a pessimal inline.
- **Lessons**: (a) kill diagnostic code with the bug it diagnosed,
  not later — it had been burning space in every boot for two
  phases; (b) when a pattern appears N times inline, a table + loop
  break-evens at N ≈ 3; (c) unify before optimising — consolidating
  init_pio_kbd + init_display into one table was a bigger win than
  any local micro-opt.


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
