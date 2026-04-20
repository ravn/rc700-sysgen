# CP/NOS ROM — Open Issues & Follow-up Tasks

Concrete items surfaced during the planning sessions that need action before
or during implementation. Live next to `cpnos-rom-plan.md`.

## MAME observations (Phase 1 work-in-progress)

- **Display RAM at 0xF800 is not visible until CRT + interrupts are
  enabled.** Writing bytes via `LD ($F800),A` from ROM code did not
  produce readable bytes at 0xF800 in the MAME boot test — either MAME
  emulates display RAM as CRT-DMA-gated (reads return 0 while CRT is
  idle) or some other interaction keeps our writes invisible.  Either
  way, the MVP path is: enable IVT + PIO + DMA + 8275 CRT + interrupts
  in init_hardware before expecting display-based test oracles to work.
- **Alternative test oracles while CRT is still offline:** SIO-B TxD
  toggles (capture via MAME null-modem image), MAME debugger memory
  dump of 0xF800 after a known delay, or a software-maintained "alive"
  byte at a non-display RAM address polled by the lua script.

## Verification tasks (before Phase 1 code)

- [ ] **Confirm port 0x14 is DIP switch on MIC702.** User stated this is
      "probably" the case. Verify against `RC702_HARDWARE_TECHNICAL_REFERENCE.md`
      and/or MAME `rc702.cpp` port map. If confirmed, document in the
      hardware reference; if wrong, fix here.

- [ ] **Verify MAME rc702 driver implements OUT 0x18 → PROM disable.**
      Write a tiny test (OUT 0x18, then read 0x0000, expect RAM value we
      just wrote, not PROM byte). Needed before Phase 1 because MAME is
      our main test harness.

- [ ] **Confirm SNIOS entry-point address stability requirement.**
      Current 0xDA12 / 0xDA15 / 0xDA4D — are these hard-coded into any
      CP/NOS applications we need to run, or is everything we'll load
      fresh enough to use whatever addresses we pick? Check `cpnet-z80/`
      client utilities.

- [ ] **Find NDOS.SPR (or equivalent) for the CP/NOS client runtime.**
      The combined image loads CCP+BDOS via netboot; CP/NOS uses NDOS
      (not standard CP/M BDOS). Need to confirm which binary the server
      streams — NDOS is in `cpnet-z80/dist/src/ndos.asm`, need the
      assembled image and to verify it fits the 6–8KB budget.

## Server-side work

- [x] **Stream real NDOS.SPR (session #25).** `netboot_server.py` now
      reads `cpnet-z80/dist/ndos.spr`, applies DRI SPR page-relocation
      (128B header -> code_len body -> code_len/8 MSB-first bitmap,
      add base_page to flagged bytes) to NDOS_BASE=0xE300, and streams
      24x 128B blocks via one FNC=2 + N FNC=3 pairs.  MAME verifies
      relocation correctness at 0xE702/0xE705 (link-relative 0x01/0x05
      -> 0xE4/0xE8 after +base_page).  CCP still pending.

- [ ] **Stream real CCP.SPR.**  Same pattern as NDOS.  ccp.spr
      code_len=0x0A00 (2.5KB) -> CCP_BASE=0xD900, 20 blocks.  Needed
      before the FNC=4 execute can hand off to real CCP instead of
      the current RET stub at 0xDB80.

- [ ] **z80pack cpmsim MP/M netboot handler.** Extend the MP/M master
      running on z80pack to respond to FMT=0xB0/FNC=0 boot request with
      the CP/NOS load sequence (FNC=1/2/3/4). Reference:
      `cpnet-z80/src/netboot.asm`. May need host-side Python bridge if
      z80pack cpmsim MP/M doesn't have a netboot handler out of the box.

- [ ] **Document the z80pack ↔ MAME null-modem pipe.** How does MAME's
      SIO-A null-modem image connect to z80pack's CP/NET character device?
      Likely a PTY bridge or named pipe. Add to `docs/cpnos-server.md`.

## Parked / future

- [ ] **Parallel-port transport (J3/J4 PIO Mode 2).** Design the transport
      vtable in Phase 1 so this drops in without restructuring. ~520B
      reserved in the budget but not implemented.

- [ ] **Local-diskette cache policy.** Phase 3 benchmark: is local 8" DSDD
      read meaningfully faster than SIO-A 38400 for the CCP+BDOS image?
      If so, add boot-time `CPNOS.SYS` lookup on B: with server fallback.

- [ ] **IOBYTE defaults.** Map SIO-A for NOS traffic, SIO-B for console.
      Confirm matches `rcbios-in-c` convention and document in
      `docs/cpnos-iobyte.md`.

- [ ] **Multi-node SLAVEID story.** Current plan is hard-coded 0x70.
      If multiple RC702s ever need to share one MP/M master, either:
      build per-node variants, or read a DIP-switch byte at boot. Decide
      only when the need arises.

## llvm-z80 codegen risks (monitor during Phase 1)

- [ ] **Transport vtable indirection.** `(HL)` call-through-pointer patterns
      may stress GlobalISel. If codegen bloats the transport layer,
      consider flattening to direct calls with `#if ENABLE_PARALLEL`.

- [ ] **Asm ↔ C interop for SNIOS/netboot.** Porting `snios.asm` and
      `netboot.asm` means clang must link DRI-style asm. Check
      `autoload-in-c/` for precedent — current autoloader does C+asm mix.

## Session 24 (SNIOS port) — new issues

## Session 26 (SPR relocator correction, CCP blocker) — new issues

- [x] **SPR format: ignored sector between header and code (resolved).**
      The DRI SPR file layout carries a 128B "ignored" sector after the
      128B parameter sector and before the code image.  The loader
      `cpnetldr.asm:566` reads it with `CALL OSREAD ;GET DATA & IGNORE`
      and discards the buffer.  Session #25's relocator missed this and
      was reading 128B of zero padding as the start of code — shifting
      every byte offset by 128.  The NDOS smoke check at 0xE702/0xE705
      passed coincidentally because both the "code" and the "bitmap" I
      was reading were shifted together and the particular bit arithmetic
      happened to produce the right delta.  Real NDOS entry after fix:
      **0xE300 = JP 0xE571 (NDOSE)**, **0xE303 = JP 0xE4F6 (COLDST)**.

- [ ] **CCP placement stomps scratch_bss.** CCP is 2560B at 0xD900, so
      it ends at 0xE2FF — directly on top of `.scratch_bss` (0xE000..
      0xE217) which holds `rx_buf` (261B), `msgbuf` (262B), and other
      BIOS BSS.  Streaming CCP before resident_entry runs corrupts all
      of this, causing PC to wander (observed PC=0x826F, SP=0xE1FB).
      Decide: (a) move `.scratch_bss` to above CCP (e.g. 0xF000..0xF1FF,
      below BIOS base), (b) shrink/split scratch usage so both fit in
      the gap 0xE300..0xF1FF (with NDOS at 0xE300..0xEEFF that's only
      0xEF00..0xF1FF = 768B), or (c) re-layout CCP+NDOS+BSS so BSS sits
      above CCP end.  Option (a) cleanest; requires linker-script shift
      and re-sizing.  Blocks CCP streaming + cold-boot handoff.

- [ ] **Update memory-map documentation.**  The runtime map in
      cpnos-rom-plan.md still shows CCP at 0xDB80 (2KB) and NDOS at
      0xE380 (3.5KB).  Real fit is CCP 0xD900..0xE2FF (2.5KB) + NDOS
      0xE300..0xEEFF (3KB).  Both now must be page-aligned (SPR
      requirement) and bases were chosen "lower than needed to be
      safe" with later tightening planned.

## Session 25 (NDOS SPR streaming) — new issues

- [ ] **CCP streaming + real cold-boot handoff.**  NDOS is in RAM at
      0xE300 but nothing calls it.  Next steps: (a) relocate+stream
      ccp.spr to 0xD900, (b) change FNC=4 execute from the RET stub
      at 0xDB80 to the CCP cold-start entry, (c) wire NDOS's BIOS
      vector back-pointer so NDOS can find BIOS entries (typically
      BIOS base is passed in HL at CCP entry, or baked into NDOS at
      link time via a fixed address).  Decide which convention the
      cpnet-z80 NDOS expects — inspect `cpnet-z80/dist/src/ndos.asm`.

- [ ] **SPR relocator coverage.**  Current Python relocator asserts
      page-alignment + bitmap length but doesn't handle data_len>0
      (both ndos.spr and ccp.spr have data_len=0).  Add a path for
      modules with pre-initialised data when we stream those later
      (e.g. future FDOS.SPR).  Small: copy data_len bytes unchanged
      immediately after code.

- [x] **NDOS entry discovery (resolved).**  Inspected
      `cpnet-z80/dist/src/ndos.asm:80-88`.  Module starts at `org 0`
      with `NDOSTP: JMP NDOSE` (BDOS dispatch) at offset 0 followed
      by `JMP COLDST` at offset 3.  After our relocation to 0xE300:
      **0xE300 = BDOS entry**, **0xE303 = COLDST**.  CP/M BDOS vector
      at 0x0005 should be `JP 0xE303` (the +3 half-convention where
      the low byte of the BDOS vector doubles as the top-of-TPA
      marker).  `BDOSE` word at NDOS+? stores a host-supplied entry —
      need a closer read when wiring CCP handoff.

- [ ] **Wire BDOS vector + CCP cold-boot handoff.**  After CCP.SPR is
      streamed and relocated to 0xD900, cold-boot path needs to:
      (a) write `JP 0xE303` at 0x0005 (BDOS vector);
      (b) populate NDOS's BDOSE word with the BDOS entry;
      (c) call CCP cold-start at 0xD900 (or 0xD900+8, convention
          varies — cpnet CCP.ASM header will tell).
      Currently FNC=4 executes a RET stub at 0xDB80 which is unrelated.

- [ ] **Remove SNIOS smoke calls from resident_entry once real NDOS
      runs.**  The `snios_ntwkin`/`sndmsg_c`/`rcvmsg_c` calls in
      `resident.c:71-86` are Session #24 smoke tests; in production
      NDOS is the caller of SNIOS.  Keep them behind a debug flag or
      delete once NDOS drives the net traffic end-to-end.

## Session 24 (SNIOS port) — new issues

- [x] **NDOS/BIOS memory collision (resolved).** Took option (a):
      CCP base moved from 0xDF80 -> 0xDB80 in `netboot_server.py`.
      Runtime map now CCP 0xDB80..0xE37F (2KB), NDOS 0xE380..0xF17F
      (3.5KB est.), BIOS 0xF200..~0xF562, display 0xF800+.  ~130B
      slack between NDOS top and BIOS.  TPA drops from 56KB to 54.6KB
      (plan's TPA target was 55KB for NOS-only; we come in 0.4KB under
      but still well within the "55KB+" bullet).  Revalidate when
      cpnet-z80's real NDOS.SPR hits the stream — if NDOS turns out
      smaller than 3.5KB we can reclaim some TPA by raising CCP back up.

- [ ] **SNIOS jump table not yet wired to NDOS.** `_snios_jt` is
      exposed at 0xF233 but nothing references it.  Once the server
      starts streaming real NDOS, the cold-boot handoff has to tell
      NDOS where SNIOS lives (typical DRI convention: a BIOS entry
      returns the SNIOS address, or the address is baked into NDOS at
      server-side link time).  Wiring TBD when real NDOS lands.

- [ ] **SNIOS NTWKDR drain timeout.** Per-poll `transport_recv_byte`
      timeout hard-coded to 64 ticks.  Fine for MAME but may miss
      trailing stale bytes on real hardware if the SIO buffer drains
      slowly.  Measure on real HW before declaring NTWKIN reliable.

- [ ] **SNIOS CHKACK `AND 7FH` mask.** Carried over from the DRI
      original, which targeted 7-bit async links.  Redundant on our
      8N1 transport but harmless — costs 2B.  Remove if we need the
      space.

- [ ] **SNIOS not protocol-tested yet.** Smoke test verified jump
      table placement and CFGTBL data only.  Need `cpnet/server.py`
      brought up against SNIOS on cpnos-rom to confirm wire format
      round-trips (ENQ/ACK/SOH header/STX data path).  Blocker for
      Phase 1 end state.

- [ ] **CFGTBL symbol naming.** Renamed `_cfgtbl` → `cfgtbl` in
      `cfgtbl.c` so the asm-visible symbol is `_cfgtbl` (clang Z80
      prefixes one underscore). Document the convention for future
      C↔asm shared data: C source should NOT start identifiers with
      underscore or the asm name ends up double-prefixed.

- [ ] **MAME lua probe hardcodes CFGTBL address.** `mame_boot_test.lua`
      has `cfg_addr = 0xF4BC` baked in; every time the resident layout
      shifts, the constant needs manual update (last shifted from
      0xF4B3 -> 0xF4BC when `snios_ntwkin()` call landed).  Fix:
      either resolve the symbol from the ELF at test time, or
      memory-scan for the SLAVEID+16-zero-drives pattern.

- [ ] **Init stack 0xF200 vs netboot DMA.** Stack pointer init moved
      to 0xF200, grows down into 0xF1FF..0xF000.  If netboot ever
      receives payload with SIZ+DMA landing in 0xF000..0xF1FF, stack
      would corrupt or be corrupted.  Add an assert in netboot or a
      comment pinning the DMA range before real NDOS lands here.

## Decisions to defer until we have numbers

- [ ] **Single or dual network DPH (A: only, or A: + extra drives).**
      Decide after measuring ROM headroom in Phase 1.

- [ ] **How much of the current BIOS to reuse literally vs rewrite.**
      Session #23 BIOS is 6002B full-featured; cpnos-rom needs a subset
      (~2KB). Probably cleaner as a new file tree than heavy `#ifdef`
      surgery — confirm once Phase 1 scaffolding exists.
