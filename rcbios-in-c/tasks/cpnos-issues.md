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

- [ ] **NDOS/BIOS memory collision.** BIOS_BASE moved to 0xF200 to fit
      SNIOS in the resident region; NDOS loaded at 0xE786 (size ~3.5KB)
      now reaches ~0xF585, overlapping the new BIOS area (~900B of
      overlap). Harmless today because `netboot_server.py` streams
      only a single RET byte, but must be resolved before real NDOS
      bytes hit the wire. Options: (a) push CCP down by ~0x400 and
      NDOS follows (costs ~1KB TPA), (b) shrink SNIOS further, (c)
      split SNIOS off into PROM1 and keep only a jump-table trampoline
      resident.  Decide once we have real NDOS bytes to measure.

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
