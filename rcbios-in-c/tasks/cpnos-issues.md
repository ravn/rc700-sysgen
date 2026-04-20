# CP/NOS ROM — Open Issues & Follow-up Tasks

Concrete items surfaced during the planning sessions that need action before
or during implementation. Live next to `cpnos-rom-plan.md`.

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

## Decisions to defer until we have numbers

- [ ] **Single or dual network DPH (A: only, or A: + extra drives).**
      Decide after measuring ROM headroom in Phase 1.

- [ ] **How much of the current BIOS to reuse literally vs rewrite.**
      Session #23 BIOS is 6002B full-featured; cpnos-rom needs a subset
      (~2KB). Probably cleaner as a new file tree than heavy `#ifdef`
      surgery — confirm once Phase 1 scaffolding exists.
