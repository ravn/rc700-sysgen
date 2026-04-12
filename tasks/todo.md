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
- z80pack fork: https://github.com/ravn/z80pack (local: ~/git/z80pack)
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
- [ ] 58K rel.1.4: 4 ISR-specific auto-labels remain in BIOS_58K_14.MAC (sub_e43dh, lee8ah, lee8bh, lf421h)
- [ ] VERIFY.COM disassembly: Pascal-compiled disk verification utility (10KB). VERIFY.MAC in RC702E BIOS is a related but separate compilation (4KB app block, missing runtime). Low value — compiler output won't produce readable source.
- [ ] **Microcontroller-as-PIO-A-server (investigate)**: pick a small MCU
  (Raspberry Pi Pico / RP2040, Arduino, ATmega328) for direct connection
  to the RC700's Z80-PIO Channel A parallel port to provide a bidirectional
  data exchange / server peripheral. Open questions:
  * 5 V tolerance vs level shifting (RP2040 GPIO is 3.3 V; ATmega328 is 5 V native)
  * STROBE/READY (Z80-PIO Mode 2) handshake timing — RP2040 PIO state
    machines look ideal; Arduino bit-bang may be too slow
  * Wiring: PIO-A 8 data lines + ASTB + ARDY + GND, plus a reset/IRQ
    return path for bidirectional half-duplex
  * Software model: BIOS PUNCH/READER routed via IOBYTE to PIO-A?
    A new BIOS device? An optional "RDR:=PIO" patch?
  * Reuse target: same use-case as the FTDI serial cable
    (`docs/serial_cable_wiring.md`, `docs/serial_motherboard_uart.md`)
    but with much higher throughput than 38400 baud SIO-A.

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

## Parallel host link (PIO Port A bidirectional)

Goal: replace the 38400-baud serial transport with a fast parallel link
between RC700 and a modern host machine (e.g. a Linux box with a real
DSUB-25 LPT port — 5 V TTL, electrically compatible with the Z80 PIO).

Design doc: `rcbios-in-c/docs/parallel_host_interface.md`.
Schematic analysis: `docs/schematics/MIC07_pinout.md`.
Investigation log: `tasks/session16-summary.md`.

### Status

- Design doc exists from before session 16, assuming Mode 2
  (bidirectional with full hardware handshake) on PIO Port A.
- Session 16 read MIC07 and found that Mode 2 likely **does not work
  on stock hardware** — ARDY appears unwired and BSTB/BRDY are on the
  wrong DSUB-25 connector. Schematic reading is not yet
  hardware-verified.
- `KBDPORT=B` compile-time flag implemented and verified on both
  clang and SDCC (commit b746c0c). Default build unchanged.
- **Blocked: waiting for DB-25 M/M cable.**
  Candidate: elextra.dk H11461 (49 DKK, 2m) or H11463 (79 DKK, 5m).
  Confirm 1:1 straight-through wiring before buying (phone 9684 0619).
  Alternative host hardware: Arduino Micro (elextra H36812, 199 DKK,
  5V native, no level shifter needed).

### When the cable arrives — investigation plan

Prerequisites: cable, Linux PC with real LPT port (`/dev/parport0`),
RC700 with serial console working, keyboard unplugged from J4.

1. Write `pioprobe.com` — small CP/M test program loaded over serial.
   Takes single-letter commands, configures PIO modes, reads/writes
   ports, reports results back on serial console.
2. Write `lptprobe.py` — Linux-side script using `ppdev`/`pyparallel`.
   Drives LPT data + control lines, reads status lines.
3. **Cable mapping** (investigation #1): drive each LPT data line
   high one at a time, read PIO port on RC700 → builds the complete
   "LPT pin → J4 pin → PIO bit" map for this specific cable.
4. **ARDY discovery** (investigation #2, the critical one): configure
   PIO-A as Mode 0 output on RC700, write a byte, read all 5 LPT
   status inputs on Linux. Any status pin that toggles in step with
   the RC700 OUT instruction is ARDY wired through. Settles the
   load-bearing question without a meter or opening the case.
5. **Confirm J4 = Port A** (investigation #3): drive LPT line, read
   both port 0x10 and 0x11 on RC700, see which responds.
6. **Mode feasibility**: try Mode 0/1/2/3, see which round-trips data.
7. **Throughput benchmark**: push 64 KB block, time it, compare to
   38400 baud serial.
8. Based on results → pick option 1/2/3, start BIOS + host firmware.

### Hardware verification (do these on the actual machine)

- [ ] Confirm J4 = PIO Port A by ringing out J4 pin 21 (alleged A0)
      with a meter back to a known Port A data pin on the Z80 PIO chip.
- [ ] Confirm J3 = PIO Port B the same way (J3 pin 22 → B0).
- [ ] **Critical:** check whether ARDY (Z80 PIO chip pin 18) is wired
      to *any* J4 pin. If yes, Mode 2 is much closer to viable. If no,
      see option 3 below.
- [ ] Confirm BSTB's exact pin number on J3 — partly obscured in the
      schematic crop.
- [ ] Identify which J4 pins are unused (i.e. not data, not strobe,
      not power, not ground). These are candidates for option 3 wiring.

### Schematic re-read tasks (do at the keyboard)

- [ ] Re-render MIC07 *uncropped* and trace one `KEY n` wire
      pin-by-pin from J4 back to a clearly-numbered Port A pin on the
      PIO chip. Confirms the J4 = Port A claim from the schematic
      side, independent of the BIOS port mapping.
- [ ] Look for ARDY in the left half of MIC07 (cropped out in
      session 16) and on adjacent sheets (MIC06, MIC08).
- [ ] Look for a tabular connector pinout appendix in the manual
      text — many RC manuals have one separate from the schematic
      sheets. Would settle the J3/J4 question definitively.

### Three options to choose from once hardware is verified

1. **Half-duplex, no rewiring.** Mode 0/1 + ASTB-driven RX
   interrupt. Host→Z80 fully handshaked. Z80→host polled with fixed
   timing or bit-banged via Mode 3. Slowest, simplest, no soldering.

2. **Y-cable into J3 + J4.** Picks up BSTB/BRDY from J3 and the
   data bus + ASTB from J4. Still missing ARDY (host inserts fixed
   delay). Non-standard cable, no soldering.

3. **Open the case, run 1–3 wires.** ARDY (PIO pin 18) → spare J4
   pin, optionally also BSTB/BRDY → spare J4 pins. Single DSUB-25
   into J4 then becomes a complete Mode 2 link with the full
   ~25–30 KB/s the design doc estimated.

### Once an option is picked

- [ ] Update `rcbios-in-c/docs/parallel_host_interface.md` to match
      reality (drop the warning header, document the chosen option).
- [ ] BIOS work: PIO init swap (Port A to chosen mode, Port B to
      Mode 1 input for keyboard), ISR rename, parallel ring buffer.
- [ ] Move keyboard cable from J4 to J3 physically.
- [ ] Host-side firmware/driver for the chosen option.
- [ ] Lit test for the new BIOS init bytes per CLAUDE.md
      "always add a lit test" rule (where applicable).

