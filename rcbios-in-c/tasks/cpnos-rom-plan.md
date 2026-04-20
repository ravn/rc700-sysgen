# CP/NOS Combined Autoloader+BIOS PROM Plan

## Goal

Single 4KB ROM image (two 2KB PROMs: PROM0 @ 0x0000, PROM1 @ 0x2000, both
disabled by one OUT (0x18)) that boots the RC700 as a CP/NOS client against
MP/M, with optional 8" DSDD diskette fallback. Written in C/clang where
practical, SNIOS kept in assembly.

## Non-goals / Parked

- Parallel-port transport (J3/J4 PIO) — parked, user will return later.
  Reserve clean abstraction (transport vtable) so it drops in without
  restructuring.
- SDLC / synchronous transport — unproven HW, parked.
- Relocatable display memory / > 56KB TPA — requires HW changes, out of scope.

## Targets

- TPA (NOS-only build):  ~55KB
- TPA (NOS+diskette):    ~52KB
- Display + work area at 0xF800–0xFFFF **unchanged** (Comal80 compat).
- Total ROM image: ≤ 4096B, split `dd` into `prom0.bin` (0x0000–0x07FF)
  and `prom1.bin` (0x2000–0x27FF) for burning.

## Memory map at runtime (NOS+diskette build)

| Region | Addr | Notes |
|---|---|---|
| Page zero | 0x0000–0x00FF | CP/M vectors (JP WBOOT, IOBYTE, CDISK, JP BDOS) |
| TPA | 0x0100–CCP-1 | ~52KB with diskette, ~55KB without |
| CCP | variable | 2KB, loaded from server |
| BDOS | CCP+0x806 | 3.5KB, loaded from server |
| BIOS resident | below 0xF600 | jump table + console + SNIOS + (optional) FDC |
| IVT | 0xF600–0xF6FF | slim, only vectors we use |
| conv_tables | 0xF680–0xF7FF | keep layout — Comal80/existing apps |
| Display | 0xF800–0xFFCF | locked |
| Work area | 0xFFD0–0xFFFF | locked |

BIOS base address becomes a build-time constant, chosen by the linker to be
the lowest multiple of 0x100 that fits the resident size + stack. Two values:
one for NOS-only, one for NOS+FDC.

## Deliverables

1. New directory `rc700-gensmedet/cpnos-rom/` (combined PROM project), or
   reuse `autoload-in-c/` with a new target. Decision in Phase 0.
2. Two build configurations via `-DENABLE_FDC=0|1`.
3. Linker script `cpnos_rom.ld` enforcing 4KB limit and split layout.
4. `make cpnos` produces `prom0.bin` + `prom1.bin` + `cpnos.elf` + `.map`.
5. `make cpnos-mame` boots MP/M (z80pack) and brings up RC702 as CP/NOS node.
6. Lit tests for any llvm-z80 codegen issues found along the way.
7. Updated `tasks/cpnos-rom-plan.md` (this file) + session summary on completion.

## Phase 0 — Scaffolding & decisions (1 session)

- [ ] Decide project layout: new `cpnos-rom/` dir vs extending `autoload-in-c/`.
      Default: new dir to keep ROA375 SDCC build intact as reference.
- [ ] Copy over build harness from `autoload-in-c/` (Makefile, docker helper).
- [ ] Stub linker script `cpnos_rom.ld` with 4KB ROM region, 2KB split assertion.
- [ ] Decide MP/M server setup: existing `cpmsim` z80pack config, or the
      `cpnet-z80/` reference MP/M image. Document in `docs/cpnos-server.md`.
- [ ] Confirm MAME RC702 driver can boot a custom PROM pair and talk to
      z80pack MP/M over the configured SIO-A null-modem bridge.

## Phase 1 — Netboot MVP, no diskette (2 sessions)

Goal: `ENABLE_FDC=0` image boots an MP/M client over SIO-A async 38400.

- [ ] Reset vector + minimum hardware init (SIO-A/B, CTC, PIO, IVT setup).
      Existing `bios_hw_init` is the reference; strip FDC/DMA bring-up.
- [ ] Console I/O (CONIN/CONOUT/CONST on SIO-B) — lift from current BIOS.
- [ ] SNIOS in assembly — lift `cpnet/snios.asm` verbatim, adapt entry points
      to new BIOS base address (build-time symbol).
- [ ] Netboot loader: new function (`FNC=0xFF` or similar) that requests
      CCP+BDOS image from server, receives into RAM at correct addresses.
      Add matching handler to `cpnet/server.py`.
- [ ] Cold boot sequence:
      1. copy resident BIOS chunk to high RAM
      2. OUT (0x18) disables both PROMs
      3. init IVT, stack, console
      4. netboot request → load CCP+BDOS
      5. jump to CCP
- [ ] BIOS jump-table stubs: console entries real, all disk entries return
      "no disk" (CP/NOS funnels disk I/O through BDOS → SNIOS, not BIOS disk ops).
      Verify this matches DRI CP/NOS semantics — **open question, confirm from
      `cpnet-z80/` reference before coding.**
- [ ] CFGTBL + single network DPH for drive A:.
- [ ] MAME boot test: reach CP/NOS prompt `A>`, run `DIR`, read a file.
- [ ] Measure actual ROM size vs budget; record in this file.

## Phase 2 — Diskette support (1–2 sessions)

Goal: `ENABLE_FDC=1` image has both NOS and local 8" DSDD support.

- [ ] Add FDC driver: init, ISR, seek, recalibrate, read, write (lift and trim
      from current BIOS). Reference: `bios.c` FDC routines + `fdf[1]` at `:151`.
- [ ] Deblocking driver (512B physical ↔ 128B logical), 512B sector buffer in BSS.
- [ ] 8" DSDD DPB + SECTRAN: lift `dpb_maxi_512` (`bios.c:141`) and
      `xlt_maxi_512` (`bios.c:79–81`).
- [ ] Second DPH for drive B: on the same format (trivial, shares DPB).
- [ ] Boot-time drive detection: attempt FDC recalibrate; if no drive, mark
      A: and B: as network-only.
- [ ] Decide A:/B: policy:
      - Option X: A: = network, B: = local floppy (simplest, distinct)
      - Option Y: A: = local if present else network; B: = the other
      - **Default: Option X**, document in `docs/cpnos-drives.md`.
- [ ] MAME test: boot NOS, then `B:DIR` reads a local floppy image.
- [ ] Record ROM size with FDC enabled; verify ≤ 4096B.

## Phase 3 — Benchmark & decide local-cache policy (1 session)

User asked to measure whether local floppy can serve CP/NOS resident files
faster than the server. This is a **decision point, not immediate code**.

- [ ] Measure: time to transfer a 4KB file
      1. over SIO-A 38400 async from MP/M (baseline)
      2. read from local 8" DSDD (FDC + deblock)
- [ ] Decide policy based on numbers. Likely outcome: diskette wins by
      ~5–10× for bulk reads. If so, phase 3.5:
- [ ] (conditional) Add a boot-time option: if B: contains a valid
      `CPNOS.SYS` (or named file list), read CCP+BDOS from B: instead of
      server. Falls back to server if read fails.
- [ ] Record numbers in `tasks/cpnos-benchmarks.md`.

## Phase 4 — Real-hardware bring-up (1 session, depends on EPROM access)

- [ ] Burn `prom0.bin` and `prom1.bin` to 2716 (or compatible) EPROMs.
- [ ] Plug into RC702, connect SIO-A null-modem to host running MP/M server.
- [ ] Verify banner, boot, `DIR`, simple BDOS calls.
- [ ] Verify Comal80 still loads (confirms 0xF800+ layout preserved).
- [ ] Verify local floppy in B: if diskette build.

## Resolved questions (investigation round 1)

1. **BIOS disk semantics (RESOLVED).** NDOS checks CFGTBL bit-7 per drive
   and routes remote drives through SNIOS directly; BIOS READ/WRITE/SELDSK
   are never called for network drives. Evidence:
   `cpnet-z80/dist/src/ndos.asm:540-558, 1188-1195`. Disk stubs in NOS-only
   build are ~30B (error return + null DPH).

2. **Netboot protocol (RESOLVED).** Standard DRI protocol in
   `cpnet-z80/src/netboot.asm`: client sends FMT=0xB0/FNC=0; server replies
   FMT=0xB1 with FNC=1 (load text), FNC=2 (set DMA), FNC=3 (128B data),
   FNC=4 (execute). Port reference asm rather than inventing. Extend
   `cpnet/server.py` with matching handler.

3. **SLAVEID (RESOLVED).** Hard-coded at build time, stored at CFGTBL+1,
   copied to every outgoing SID field. Reference:
   `cpnet-z80/dist/src/cpnios.asm:55-63`. Use `-DRC702_SLAVEID=0x70`
   build flag.

## Remaining open questions

4. **IOBYTE defaults** — map to SIO-A for NOS traffic, SIO-B for console.
   Confirm matches current `rcbios-in-c` convention.
5. **Budget update from Q1/Q2 findings**: Phase 1 netboot asm is tighter
   (~250B vs 350B) and disk stubs are smaller (~30B vs 150B). Total saving
   ~200B — puts NOS-only TPA potentially at 56KB. Remeasure after Phase 1.

## Runtime vs init code split

**Only the runtime-resident portion gets copied to high RAM.** Init code
stays in ROM and runs in place, since it only executes before PROM disable.

Runtime-resident (copied to high RAM, survives PROM disable):
- BIOS jump table
- Console I/O (CONIN/CONOUT/CONST on SIO-B)
- SNIOS message layer (send/recv/checksum/retry)
- `ENABLE_FDC`: FDC driver + deblocking + 512B sector buffer + DPH/DPB
- Network DPH/CFGTBL tables

Init-only (stays in ROM, discarded at PROM disable):
- Reset vector + hardware init (SIO/CTC/PIO, IVT stub)
- Cold-boot driver (orchestrates netboot into RAM)
- Netboot receive loop — runs once, from ROM
- One-time banner/status messages

Cold boot order:
1. Reset → hardware init (runs from ROM)
2. Netboot handshake, load CCP+BDOS into RAM (ROM-resident init code)
3. Copy resident BIOS chunk from ROM to high RAM
4. OUT (0x18) — both PROMs disabled, init code vanishes (done with it)
5. Finalize IVT / stack in high RAM, jump to CCP

**Size impact:** Init code (~500–800B estimated) lives in the 4KB ROM
budget but not in the runtime RAM footprint. Slight TPA uplift vs the
earlier assumption that everything had to be copied up. Measure in Phase 1.

## Decisions locked in (end of planning session)

- **Project layout**: new directory `rc700-gensmedet/cpnos-rom/` (created,
  README.md in place).
- **PROM disable port**: 0x18 (RAMEN), disables both PROMs. Port 0x14 is
  likely the DIP-switch read, not ROM disable. Project-root CLAUDE.md
  corrected.
- **Boot sequence order**: ROM is disabled *before* track 0 is read
  (safe because boot code runs from 0x7000 by then). Project-root CLAUDE.md
  corrected.
- **MP/M server**: z80pack `cpmsim` at `/Users/ravn/git/z80pack/cpmsim`.
- **SLAVEID**: build-time constant, `-DRC702_SLAVEID=0x70` (can change).
- **Transport**: SIO-A async 38400, RTS/CTS flow control (session #23 fix).
- **Target TPA**: 55–56KB NOS-only, ~52KB with diskette.

## Next-session starting point

Pick up at Phase 0 code artifacts:
1. Write `cpnos-rom/Makefile` (adapt from `autoload-in-c/Makefile`, add
   `ENABLE_FDC` switch, add 4KB size check, add prom0/prom1 split step).
2. Write `cpnos-rom/cpnos_rom.ld` linker script (ROM @ 0x0000 length 0x1000,
   RESIDENT region for runtime-copied BIOS, display/IVT layout preserved).
3. Write `cpnos-rom/reset.s` stub (reset vector + relocate to 0x7000 +
   jump to C entry).
4. Write `cpnos-rom/cpnos_main.c` stub (empty main, just OUT 0x18 and
   infinite loop) to verify the build pipeline.
5. Verify `make cpnos ENABLE_FDC=0` produces a 4KB image that splits cleanly.
6. Set up z80pack cpmsim MP/M config reachable over stdio/pty for MAME
   null-modem bridging. Document in `docs/cpnos-server.md`.

No code has been written yet. The repo has: plan doc, cpnos-rom/README.md,
CLAUDE.md corrections.

## Risks & mitigations

- **Size overrun**: +10–15% clang codegen slippage is typical. Mitigation:
  early size measurement after Phase 1, willing to push small hot paths
  to assembly (SNIOS is already asm).
- **SNIOS entry-point drift**: applications may hard-code 0xDA12/0xDA15/0xDA4D.
  Mitigation: keep these three addresses stable as exported linker symbols;
  verify in size check.
- **MP/M server-side protocol gaps**: custom netboot function may need
  MP/M-side work. Mitigation: use `cpnet/server.py` (Python) for early
  bring-up, move to real MP/M only once protocol is frozen.
- **MAME ↔ real HW divergence**: known MAME SIO bugs (ravn/mame#2).
  Mitigation: async 38400 is proven on real HW per session #23; stick
  with that rate until real-HW test passes.

## Success criteria

- 4KB image builds, both configurations under budget.
- MAME: RC702 boots to `A>` talking to MP/M, `DIR` works, `TYPE FOO.TXT` works.
- NOS+FDC build: `B:DIR` reads local floppy.
- Real HW (when available): same as MAME.
- Comal80 still loads on the NOS-booted machine.

## Session log pointer

Session summaries go in `rc700-gensmedet/tasks/` as
`sessionNN-cpnos-*.md`. This plan lives here and is updated per session.
