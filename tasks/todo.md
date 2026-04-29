# Build all 13 CP/M BIOSes from source

## Completed
- [x] Step 1: Fetch jbox.dk originals → `rcbios/jbox-originals/` (16 files)
- [x] Step 2: Trivial targets — rel14-mini, rel23-mini added to Makefile
- [x] Step 3: REL20 conditional (56K rel.2.0) — byte-verified
- [x] Step 4: RC703 family (separate source tree) — 3 variants byte-verified
- [x] Step 5: RC702E family (separate source tree) — 2 variants byte-verified
- [x] Step 6: 58K family (separate source tree) — 3 variants byte-verified
- [x] Step 7: 58K label renaming — auto-labels replaced with meaningful names

## Done: MAME RC702 serial port + CP/NET (completed)
- [x] SIO Channel A wired in MAME with null_modem
- [x] REL30 BIOS: 256B ring buffer, RTS flow control, 38400 baud
- [x] SNIOS.SPR: hex-encoded CRC-16 serial framing
- [x] Python CP/NET server: BDOS F13-F40, F64-F65, F70-F71
- [x] 204KB file transfer validated, zero packet loss
- [x] Automated test suite (autotest.lua + run_test.sh)
- See [cpnet.md](../cpnet.md) for full details

## Next: Switch to DRI binary protocol + MP/M server

### Investigation findings (2026-03-07)

**Three CP/NET serial protocols exist** (cpnet-z80 project):

| Protocol | Framing | Encoding | Checksum | Server option |
|----------|---------|----------|----------|---------------|
| `serial` (ASCII) | `++`...`--` | Hex-encoded | CRC-16 (0x8408) | `proto=ASCII` |
| `ser-dri` (DRI) | ENQ/ACK/SOH/STX/ETX/EOT | Binary or ASCII | Two's complement sum | `proto=DRI` |
| z80pack | DRI protocol | Binary (`Binary$ASCII=FFh`) | Two's complement sum | Built-in |

**Our current RC702 SNIOS uses the `serial` (ASCII/hex) protocol.**
This is incompatible with DRI standard and z80pack.

**z80pack has:**
- MP/M II V2.0 on disk images (mpm-1.dsk, mpm-2.dsk)
- Network I/O via TCP socket on port 50/51 (`net_client.conf` → host:port)
- Three SNIOS variants: snios-0 (original DRI), snios-1 (CP/NET 1.1), snios-2 (CP/NET 1.2)
- All use DRI protocol in binary mode by default

**CP/NET version**: Our CPNETLDR.COM says "CP/NET 1.2". Versions 1.1 and 1.2 are
NOT binary compatible. Must use matching client/server versions.

**MP/M as server**: cpnet-z80 has an MP/M Server implementation (NETSERVR.RSP)
but currently only builds for W5500 NIC (Ethernet), not serial.
Would need: serial NIOS for MP/M server side, or adapt z80pack's socket I/O.

**CpnetSerialServer.jar** (Java, in cpnet-z80/contrib) supports both ASCII and DRI
protocols via `cpnet_proto=` config. This is the easiest server to use.

### Recommended approach

**Phase 1: Switch SNIOS to DRI binary protocol**
- [x] Rewrite RC702 SNIOS to use DRI ENQ/ACK/SOH/STX/ETX/EOT framing
- [x] Use binary mode (no hex encoding) — 8-bit clean serial link
- [x] Simple two's complement checksum (code is 32B larger due to retry/ACK)
- [x] Keep FNC=FFh init and FNC=FEh shutdown (same across all protocols)
- [x] Update server.py to speak DRI binary protocol
- [x] Test with MAME (end-to-end validation)
- [ ] Test with CpnetSerialServer.jar (`proto=DRI`) as alternative server

**Phase 2: MP/M server via z80pack**
- [ ] Build z80pack cpmsim on macOS
- [ ] Boot MP/M II with CP/NET server (NETSERVR.RSP)
- [ ] Connect: RC702 (MAME, DRI SNIOS) ↔ TCP ↔ z80pack (MP/M server)
- [ ] Challenge: need serial NIOS on MP/M side, or bridge via TCP

**Phase 3: cpmtools3 for disk image file injection** (DONE)
- [x] RC702 diskdefs: rc702-5dd, rc702-8dd, rc703-qd in `rcbios/diskdefs`
- [x] cpmtools3 binaries installed to `~/.local/bin/`, diskdefs symlinked
- [x] Handles IMD files natively (including multi-density RC702)
- [x] run_test.sh --inject uses `cpmcp` from PATH
- [x] imd_cpmfs.py deleted (replaced by cpmtools3)

### Protocol savings (DRI binary vs current hex)
- Wire: 8+N bytes vs 18+2N bytes per message (2x bandwidth)
- SNIOS code: ~80 bytes smaller (no hex encode/decode, simpler checksum)
- Server code: ~90% smaller framing code
- Throughput: ~4.8 KB/s vs ~2.4 KB/s at 38400 baud

**Phase 4: Recreate Java server sources**
- [ ] CpnetSerialServer.jar in cpnet-z80/contrib/ is distributed as .class files only
- [ ] Decompile and recreate source for CpnetSerialServer, CpnetDRIProtocol,
      CpnetSerialProtocol, CpnetSimpleProtocol, HostFileBdos, etc.
- [ ] Key classes: ServerDispatch, NetworkServer, SerialDevice, TtySerial
- [ ] Goal: maintainable source for the DRI protocol serial server

### Resources
- z80pack: https://retrocmp.de/emulator/z80pack/z80pack.htm
- z80pack fork: https://github.com/ravn/z80pack (local: submodule at z80pack/)
- cpnet-z80: https://github.com/durgadas311/cpnet-z80 (local: ~/git/cpnet-z80)
- CP/NET docs: http://sebhc.durgadas.com/CPNET-docs/cpnet.html
- CpnetSerialServer.jar: cpnet-z80/contrib/ (Java, supports DRI+ASCII protocols)
- cpmtools3: ~/git/cpmtools3

## REL30 Code Size Optimizations (not yet implemented)

### JP→JR replacement (~110 bytes)
~110 shared-code JP instructions can be replaced with JR (1 byte each).
All are in-range and use JR-compatible conditions. Needs `IFDEF REL30` guards
or a macro to preserve byte-verification of existing releases.
2 additional savings in REL30-only code.

### BGSTAR semi-graphics removal (~382 bytes)
BGSTAR is a 250-byte bit table tracking which screen positions were written
in "background mode" — a semi-graphics feature used by ESC codes Ctrl-T/U/V.
Making all BGSTAR-related code conditional for REL30 saves 382 bytes across
11 code sections in DISPLAY.MAC (ADDOFF, CLRBIT, ESCSB/ESCSF/ESCCF procedures,
plus background tails in FILL, SCROLL, ESCE, ESCK, ESCY, ESCDL, ESCIL, DISPL).
TAB1 jump table entries for the 3 ESC handlers should point to DUMMY for REL30.
See `rcbios/BGSTAR_ANALYSIS.md` for section-by-section breakdown with addresses
and byte counts.

## Done: SYSGEN BIOS install via CPM56.COM (completed 2026-04-03)

Workflow to install C BIOS onto a disk using standard CP/M tools:
- [x] SYSGEN memory layout reverse-engineered (track 1 at 0x0900, track 0 at 0x4500)
- [x] mk_cpm56.py: patches bios.cim into CPM56.COM, generates Intel HEX
- [x] cpm56_original.com: CCP+BDOS extracted from distribution disk via SYSGEN+SAVE
- [x] Tested in MAME: LOAD CPM56 → SYSGEN CPM56.COM → boots with clang banner
- [x] MAME rs232a defaults changed to 1200 7E1 (matches distribution disk)
- [x] Serial transfer investigated: blocked by original BIOS 1-char SIO buffer
- See `rcbios-in-c/SYSGEN_INSTALL.md` for full documentation

### Remaining
- [ ] Serial PIP transfer: needs clang BIOS ring buffer (chicken-and-egg)
- [ ] Rebuild CCP+BDOS for different MTYPE (memory size) values
- [ ] USB video grabber for monitoring physical machine
- [ ] Test on real RC702 hardware

## Done: IOBYTE routing + SIO role swap (branch: iobyte-swap-sio)

IOBYTE fully implemented. SIO roles swapped:
- [x] SIO-B = console/control port (CON:=TTY/UC1, LST:=TTY)
- [x] SIO-A = data port (RDR:=PTR/TTY, PUN:=PTP/TTY, LST:=LPT)
- [x] Auto-detect host on SIO-B via DCD at boot
- [x] Banner: "Console also on serial port B at 38400 8N1"
- [x] Source-annotated listing (llvm-objdump -d -S)
- [x] Serial console MAME test (siob-console-test): DIR/ASM/TYPE via SIO-B
- [x] BIOS deploy via dual serial (deploy-serial): SIO-B commands + SIO-A data
  - PIP CPM56.HEX=RDR: → MLOAD CPM56.COM=BDOSCCP.COM,CPM56.HEX → CPM56 (verify) → SYSGEN
  - Test boots SDCC BIOS, deploys clang BIOS, hard resets, verifies banner change
  - MAME driver: RTS flow control on SIO-A, DCD wired for both channels
  - MFI disk format for writable SYSGEN, MLOAD.COM via cpmcp

### Remaining
- [ ] Test with generic Kermit-80 in MAME (Kermit uses IOBYTE flipping)
- [ ] Refactor serial_conout to share TX code with list_lpt (−~20B)
- [ ] Make DCD detection a switch indicator (TODO in bios.c)
- [ ] Full CCP+BDOS+BIOS download mode (user can provide replacement CCP/BDOS)
- [ ] Clean up cfg/ stale overrides in Makefile (delete before MAME runs)

## Upstream bug reports for jacobly0/llvm-z80

Collect all codegen bugs found during BIOS/PROM work and file them as
issues against the upstream jacobly0/llvm-z80 with thorough test cases
(XFAIL lit tests). Do NOT submit pull requests — some bugs may be
side-effects of less-researched features and a fresh fix effort by the
upstream maintainer will likely produce better code.

Known bugs to file:
- [ ] #69: Comparison reversal peephole erases live-out register (fixed in ravn fork)
- [ ] #65: PostRACompareMerge wrongly treats CP variants as setsZForA
- [ ] #67: Pre-existing lit test failures (cmp-eq-regpressure, fib, interrupt, shift-opt, spill-regclass)
- [ ] Redundant XOR A,A when A already holds 0 across consecutive BSS stores (3B in bios_boot_c)
- [ ] Audit ravn/llvm-z80 issues list for others that affect upstream

## Parked (not working on now)
- [ ] **NDOS into the PROMs (only CCP.SPR loads from disk).** Investigate folding the NDOS+SNIOS half of `cpnos.com` into the cpnos-rom PROM payload (today PROM0+PROM1 = 4 KB; payload is 2548 B, so ~1.5 KB headroom but NDOS+SNIOS is bigger than that — see `cpnos-build/d/cpndos.prn` for size). If feasible, the cold-boot netboot collapses from "OPEN+READ-SEQ on CPNOS.IMG (~4 KB)" to "OPEN+READ-SEQ on CCP.SPR (~2 KB)" — half the disk traffic, and the slave is operational without any master at all up to the CCP-prompt point. May require splitting NDOS reloc'able into ROM-resident + RAM-init halves. (recorded 2026-04-29)
- [x] **ISRs: drop EXX/EX AF,AF', PUSH only what's used** — done 2026-04-29.  PolyPascal v3.10 (PPAS.COM) holds persistent runtime state in the shadow bank (233 EXX/EX AF,AF' instructions in disassembly).  Switched all three ISRs from `EX AF,AF'; EXX` bracket to explicit per-register PUSH/POP: `isr_crt` uses AF+HL (4B saves), `isr_pio_kbd` uses AF+BC+DE+HL (8B), `isr_pio_par` uses AF+DE+HL (6B); none touch IX/IY.  +6 B payload (2548→2554 with MIRROR_SIOB=1; 2528→2534 with MIRROR_SIOB=0).  Verified live: `PPAS PRIMES` runs cleanly under the new ISRs.
- [ ] **Rewrite ISR routines in C using port variables** (user request 2026-04-29).  `isr_crt`, `isr_pio_kbd`, `isr_pio_par` in `cpnos-rom/isr.c` are currently `__attribute__((naked))` with hand-written PUSH/POP + asm body.  Two-step migration:
  1. Convert each to a non-naked C function with `__attribute__((interrupt))` so clang emits the prologue/epilogue (including `EI` immediately before `RETI`) and computes the save set from the body — no hand-written PUSH/POP.
  2. Replace the inline-asm OUT/IN sequences with port variables: `*(volatile __attribute__((address_space(2))) uint8_t *)0x10`-style accesses, so the ISR body becomes pure C plus a few helpers.  Today this crashes the GlobalISel Legalizer (CLAUDE.md: "address_space(2) crashes Legalizer (port I/O uses inline asm workaround)") — file/track that fix as a prereq.
  - Backend support already in place (`Z80FrameLowering.cpp:386-398`, `Z80CallLowering.cpp:245-264`, `Z80RegisterInfo.cpp:104-112`); without `+shadow-regs` (our build) the CSR list `Z80_Interrupt_CSR = {AF,BC,DE,HL,IX,IY}` is filtered down to only the registers the body actually clobbers.
  - Lit test `llvm/test/CodeGen/Z80/interrupt.ll` confirms a one-store ISR emits exactly `push af / ... / pop af / ei / reti`.
  - End result: identical or smaller bytes vs today's hand-written naked form; the win is that adding/removing a register from the body automatically flows through the save set, and the ISR source reads as ordinary C.
- [ ] 58K rel.1.4: 4 ISR-specific auto-labels remain in BIOS_58K_14.MAC (sub_e43dh, lee8ah, lee8bh, lf421h)
- [ ] VERIFY.COM disassembly: Pascal-compiled disk verification utility (10KB). VERIFY.MAC in RC702E BIOS is a related but separate compilation (4KB app block, missing runtime). Low value — compiler output won't produce readable source.
- [x] **Microcontroller-as-host-bridge** — resolved 2026-04-25 by
  the CP/NET fast-link design (`docs/cpnet_fast_link.md`, Option P):
  Pi Pico drives **PIO-B / J3** (not PIO-A — keyboard stays there),
  3.3V GPIO works directly on Z80 PIO without level shifting (cbl923
  rig empirically proves the drive direction; series resistors on
  Pico inputs handle the reverse direction), Mode 2 abandoned in
  favour of half-duplex Mode 0/1 with mode-switching at CP/NET frame
  boundaries. See the new doc for the full design + bring-up plan.

## Verification Status (13 targets) — all MATCH
| # | Target | Source | Status |
|---|--------|--------|--------|
| 1 | rel13-mini | src-58k/BIOS_58K.MAC | MATCH |
| 2 | rel14-mini | src-58k/BIOS_58K_14.MAC | MATCH |
| 3 | rel14-maxi | src-58k/BIOS_58K_14.MAC | MATCH |
| 4 | rel20-mini | src/BIOS.MAC -DREL20 | MATCH |
| 5 | rel21-mini | src/BIOS.MAC -DREL21 | MATCH |
| 6 | rel22-mini | src/BIOS.MAC -DREL22 | MATCH |
| 7 | rel23-mini | src/BIOS.MAC -DREL23 -DMINI | MATCH |
| 8 | rel23-maxi | src/BIOS.MAC -DREL23 -DMAXI | MATCH |
| 9 | rc702e-rel201 | src-rc702e/BIOS_E201.MAC | MATCH |
| 10 | rc702e-rel220 | src-rc702e/BIOS_E220.MAC | MATCH |
| 11 | rc703-rel10 | src-rc703/BIOS_REL10.MAC | MATCH |
| 12 | rc703-rel12 | src-rc703/BIOS.MAC -DREL12 | MATCH |
| 13 | rc703-relTFj | src-rc703/BIOS.MAC -DRELTFJ | MATCH |

## Note: +static-stack removal option

Without `+static-stack`, BIOS is 6617B (+908B, 16% larger) but boots correctly
with banner and avoids the entire class of BSS self-clobber bugs (#51, #53).
Still fits MAXI disk (9984B limit, 3367B headroom). Consider removing
`+static-stack` if the compiler bugs prove too hard to fix.

Sizes: with +static-stack 5709B, without 6617B, SDCC 5570B.

## CP/NET fast host link (PIO-B / J3)

**Design committed (2026-04-25):** `docs/cpnet_fast_link.md` — Option P.
PIO-B half-duplex via J3, keyboard untouched on PIO-A / J4, machine
remains usable normally with the link unplugged.

Supersedes the earlier Mode-2 plan. The previous "Three options to
choose from" / "Hardware verification" / cable shopping notes are now
obsolete — see deprecation banner on
`rcbios-in-c/docs/parallel_host_interface.md`.

### Phase

- [x] **Design phase** — pinned in `docs/cpnet_fast_link.md`
- [ ] Implementation phase — **deferred**: user does not currently have
      Pi 4B / 3B host hardware on hand. Do NOT write Pico firmware,
      Z80 bench tests, MAME patches, or host daemons until an explicit
      "start coding" signal that follows hardware acquisition.

### Deferred bring-up sequence (when hardware available)

1. PIO-B input bench (mirror cbl923 keyboard rig but on J3).
2. PIO-B output bench (Z80 OTIR + host BSTB ack).
3. Direction-switch bench (mode-1 <-> mode-0 transitions clean).
4. End-to-end CP/NET frame test.
5. MAME parity (rc702.cpp PIO-B + virtual host bridge).
6. Pi 4B native deployment (Topology B, headless production).
7. Outside-world services on Pi (out of scope for this link).

### Open design questions (resolvable on paper)

- [ ] Sentinel-byte option for keyboard/CP-NET multiplexing on PIO-A is
      no longer needed under Option P. Remove if it appears anywhere.
- [ ] Optional 1-byte XOR checksum at frame end: yes/no decision after
      Step 4 above.
- [x] Level-shifter chip choice — **resolved 2026-04-25**: no chip
      needed.  Pico drives Z80 PIO directly (cbl923 rig empirically
      proves the Pico->Z80 direction); add 470 Ω - 1 kΩ series
      resistor on each Pico-input pin to current-limit the protection
      diode in the reverse direction.  Fallback to TXS0108E breakout
      only if Z80 PIO VOH measures above ~3.7V at bring-up.
- [ ] Pi-side z80pack invocation: in-process Python binding vs
      subprocess with TCP loopback.

### TODO (2026-04-28): use CP/NET disk traffic as "program running" signal

The sumtest workload tap currently detects "command done, ready for next"
via display-cursor stability + new-A>-row.  Works but slightly fragile
(needs row > last_prompt_row, which can be wrong if the screen
scrolls between commands).

A more robust signal: watch CP/NET frame traffic on the bridge.  When
a program is running and doing file I/O, bytes flow.  When CCP is
idle at A>, no bytes flow.  Idle for ~500ms = CCP at prompt, ready
for next command.

Could be done by:
- Instrumenting cpnet_bridge.cpp with a timestamped "last RX byte" and
  exposing it via a known address Lua can read; OR
- Parsing host-side proxy log (cpnet_pio_server.py) per-frame timing
  in real time; OR
- Watching MAME's bitbanger socket for activity.

### TODO (2026-04-28): port the cpnet_pio_server proxy to a Pico

`cpnos-rom/cpnet_pio_server.py` currently runs on the host PC: it
listens on TCP, talks DRI envelope upstream to mpm-net2 (port 4002),
and forwards raw SCB frames downstream to MAME's bridge / a real
Pi-Pico bridge (port 4003).  Question: can the proxy run on the Pico
itself, eliminating the host PC from the production setup?

Two angles:
1. **MicroPython port** of cpnet_pio_server.py.  ~600 lines fits
   easily in 264 KB SRAM (RP2040) or 520 KB SRAM (RP2350).  Throughput
   is the question: MicroPython ~10-50× slower than CPython; per-byte
   envelope ops would slow per-frame to ~10 ms vs ~1 ms host.  Pico W
   adds WiFi latency to mpm-net2 (~5-20 ms typical).  Enough for cold
   netboot, marginal for sustained workloads.
2. **C SDK port** for production.  PIO state machine handles
   STB/BRDY in hardware (zero-CPU per byte); lwIP for TCP to
   mpm-net2.  Closer to host-Python performance, fully embedded.
   Bigger engineering investment.

Goal: eliminate the host-PC dependency.  Slave (Z80 + RC702) +
Pi/Pico (CP/NET proxy + bridge) connects directly to mpm-net2 server.

### TODO (2026-04-28): investigate multi-channel SNIOS in any CP/NET impl

Question: do any CP/NET SNIOS implementations support more than one
communications channel (e.g., one over SIO + one over PIO simultaneously,
with traffic routed by frame type / priority)?  If yes, the design might
be applicable here — fast PIO link for bulk, slow SIO for control.  If
no (every SNIOS we've seen is single-transport), worth knowing as a
reference point for any multi-link design we'd build.

Sources to check:
- cpnet-z80 contrib SNIOS variants (snios-0/1/2 on z80pack).
- DRI's original CP/NET 1.2 distribution.
- CpnetSerialServer.jar / Java NIOS implementations.
- SEBHC docs (http://sebhc.durgadas.com/CPNET-docs/).

### DONE (2026-04-28, commit 092d323): 32-bit CRT frame counter

cpnos-rom's `isr_crt` now increments a 32-bit counter at
`0xFFFC..0xFFFF` on every CTC ch2 VRTC IRQ — mirrors rcbios's RTC
location (`RC702_BIOS_SPECIFICATION.md` §3.4).  Used by the file-I/O
bench (`testutil/filecopy.asm`) to record frames-to-completion via
the FILECOPY OK marker's S=/E= fields.  ~13 bytes of asm in `isr.c`,
INC (HL) sets Z so borrow-propagate via jr nz from each byte.

### TODO (2026-04-28): pulse — raw-bandwidth bench, no protocol

Slave program that bypasses BDOS / SNIOS / `active_transport`,
drives PIO-B / SIO-A chip ports directly to measure raw chip-level
bandwidth.  TX phase + ACK + RX phase + frame snapshots.

Host requires `pulse_host.py` (~150 LoC borrowed from
`netboot_server.py`) that handles netboot then transitions on a
sentinel byte sequence to byte-counter mode.  Replaces mpm-net2 for
the duration of the bench.

Time: ~3 h full (3 modes × 2 dir), ~1 h reduced (SIO + PIO-IRQ TX).
Detailed design in `tasks/session36-fileio-bench-and-pulse-design.md`.

### TODO (2026-04-28): install_write_tap on IO space — open puzzle

`mame_porttap.lua` installs `install_write_tap` on IO space ports
0x80 / 0x81 with `ok=true err=nil`, but the callbacks never fire when
slave does Z80 OUT.  Verified the OUT does execute (sumtest's
`out 80h` runs because we see the subsequent CONOUT bytes).

Hypothesis: API arg-shape mismatch, or `cpu.spaces["io"]` doesn't
intercept OUT in this MAME tree.  Worth a 30 min sanity check by
tapping a known-active IO port (e.g., 0x10 PIO-A data, written every
key event) — if THAT fires, the issue is something else; if not, it's
the API/MAME-build interaction.

Side-effect of the puzzle: warm-boot port-0x81 instrumentation
(commit `b06e6dd`) is unreachable telemetry.  Either fix the tap or
remove the OUT.

### TODO (2026-04-28): consider polled-PIO mode using bare bitbanger

Documented in `docs/cpnet_bridge_vs_bitbanger.md`.  Drop
`cpnet_bridge` slot device + slave's IRQ ring, use Mode-1 INIR
busy-poll receive instead.  Aligns with the project goal of "Z80
side as fast as possible, host side does the complex work" since
the slave path becomes a tight INIR loop with no ISR / ring / handshake
state machine.  Trade-off: slave busy-polls during transfers, can't
do concurrent CRT / keyboard work — fine for benches, may not be
fine for production.

Worth a one-day spike: gut `cpnet_bridge` to a bare bitbanger wrapper,
build cpnos with `transport_pio_recv_byte` rewritten as INIR,
re-run the 3-way bench, see if the simpler architecture pays off.

### TODO (2026-04-28): TCP_NODELAY on MAME ↔ mpm-net2 socket

Per `docs/cpnet_throughput_analysis.md`, ENQ (1 byte) is exactly
the kind of small write Nagle penalises.  CP/NET has many of these
turnarounds per frame.  TCP_NODELAY status on the mpm-net2 listener
+ MAME bitbanger client isn't verified; could be eating tens of ms
per turnaround out of the measured 58 ms per RTT.

Cheap to set, possibly large effect.  30 min check:

1. `mpm-net2`'s SERVER.RSP socket setup — find the accept/listen
   path, add `setsockopt(SOL_TCP, TCP_NODELAY, 1)`.
2. MAME's bitbanger TCP socket — check `osd/modules/...` for the
   socket creation path.
3. Re-run filecopy bench — compare emulated frames before/after.

If the delta is significant (>10%), wins for free on every CP/NET
configuration.

### TODO (2026-04-28): native (non-z80pack) host CP/NET server

mpm-net2 is itself a simulated Z80 (z80pack/cpmsim running MP/M II's
SERVER.RSP), so every SCB byte arriving at the host TCP listener is
parsed at 4 MHz emulated Z80 speed — adding ~5-10 emulated ms per
frame to the bench.  Replace with a native Python/C server that does
SCB parsing at host CPU speed.

`cpnos-rom/netboot_server.py` is a starting point — already speaks
LOGIN / OPEN / READ-SEQ / CLOSE for cpnos.img.  Would need to grow
to cover full CP/NET BDOS surface (DIR, FCB tracking across extents,
WRITE-RAND, RENAME, COMPUTE FILE SIZE, etc) before it could replace
mpm-net2 for general workload benches.

Estimated effect: 2-4× on PIO modes (host-side parsing was substantial),
no effect on SIO (still line-rate-limited at 38400 baud).

Aligns with project goal "host side does the complex work."

### TODO (2026-04-28): physical-hardware bring-up to verify projection

`docs/cpnet_throughput_analysis.md` projects PIO/SIO ratio widens
from ~2× (MAME) to ~4-7× (physical RC702 with Pi/Pico bridge on J3).
Verify by actually wiring it.

Steps (rough):
1. Pi/Pico-side firmware that responds to chip STB strobes,
   forwards to a host CP/NET server.
2. Cable/connector for J3 expansion port.
3. Same filecopy bench, real RC702.
4. Report frames-to-completion + KB/s; compare to MAME numbers.

Memory project_pico_count says user has 2 Pi Picos available — one
already on the cbl923 keyboard rig, second earmarked for J3.
Hardware is on hand.

### TODO (2026-04-28): reduce MAME cpnet_bridge poll quantum

The `m_poll_timer` in `cpnet_bridge.cpp` fires every 1 ms.  Per
`docs/cpnet_throughput_analysis.md`, CP/NET frames have 4 ACK
turnarounds where the slave waits for a host byte; each eats at least
1 ms of the timer quantum.  Lowering to ~100 µs would shave ~3
emulated seconds off the filecopy bench.  Trade-off: more host CPU
in the timer callback.

Test with `attotime::from_usec(100)` instead of `from_msec(1)`,
re-run bench, compare.  Cheap to test.

## cpnos-rom payload codegen analysis (2026-04-29)

Payload is 2536 B in PROM0+PROM1 (4 KB).  Long-term goal per memory
[CP/NOS → PROM 1 via compiler]: fit in PROM 1 (2 KB).  Gap: ~488 B.

### Already filed against ravn/llvm-z80 (compiler-side)
- [ ] #73 — small fixed-length `__builtin_memcpy` (≤8 B) unrolls to ~40 B of immediate stores instead of LDIR.  Worked around in `netboot_mpm.c:120-123` with a hand byte loop; still not optimal (17 B vs ~11 B LDIR).
- [ ] #74 — short-lived 16-bit spills go to BSS (or SP-relative) instead of PUSH/POP.  Hits `_xport_recv_byte` and `_cpnos_cold_entry`.
- [ ] #78 — LDIR's post-state DE/HL = dst+count not reused for `ptr += count`; hot path in `_netboot_mpm` reloads from BSS and re-adds (~6 B × 358 RTTs).
- [ ] #83 — dead `and 1` after `ld a,1` for `_Bool` store (PIO direction flag).  ~4 B.
- [ ] #84 — IVT loop and marker-print loop back up HL through BC unnecessarily; in-place writes already advance HL.  ~9 B per loop.
- [ ] #85 — sequential consecutive-address stores not lowered to HL-walked `ld (hl),v / inc hl` chain.  `_cpnet_xact` init alone is ~4 B; pattern recurs.
- [ ] #86 — switch range-check on `u8` discriminant uses 16-bit SUB/SBC instead of 8-bit CP.  Hits `_specc` (~5-7 B).
- Comments added: #60 (xor a; out; ld a,$0; out variant in `_isr_crt`), #18 (constant-routed-through-DE→L→A in `_init_hardware` set_i_reg call).

### Source-side wins independent of compiler
- [ ] **Drop vtable indirection (~38 B).**  Build is already TRANSPORT-specific (`-DTRANSPORT_NAME=...` + linker `--defsym`).  `cpnet_send_msg` (18 B), `cpnet_recv_msg` (20 B), `cpnet_probe`, `transport_sio_vt` (8 B data), `active_transport` (2 B) and the `__call_iy` dispatch path are pure overhead — nothing else picks transport at runtime.  Replace with a direct call (alias `cpnet_send_msg → snios_sndmsg_c` / `pio_send_msg` per build).
- [ ] **Gate BOOT_MARK in production (~30-50 B).**  `_netboot_mpm` and `_cpnos_cold_entry` together write ~12 BOOT_MARK bytes to `$f843..$f84e` (5 B each).  `-DBOOT_MARK_ENABLED=0` for shipping builds.
- [ ] **Pad LOGIN_PWD copy to 12 bytes** (or unroll to HL-walk) so it hits the LDIR threshold (issue #73 workaround).  ~6 B.

### Other observations
- Hand-written 8080 SNIOS asm: tight, no waste.
- ISRs: ~2-6 B each savable (mostly via #60 / #84-class fixes).
- Console subsystem (`_specc`, `_impl_conout`, cursor functions): ~5-15 B savable, mostly via #85 / #86.
- Realistic shave with current compiler (source-only): ~80-100 B → ~2440 B.
- Plus compiler fixes (#73, #74, #78, #83-#86): another ~100-150 B → ~2300 B.
- Plus drop vtable: → ~2260 B.
- Closing the full 488 B gap to slot-1 (2 KB) needs all of the above plus a console-subsystem refactor.  Not yet planned.

