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

## Parked (not working on now)
- [ ] 58K rel.1.4: 4 ISR-specific auto-labels remain in BIOS_58K_14.MAC (sub_e43dh, lee8ah, lee8bh, lf421h)
- [ ] VERIFY.COM disassembly: Pascal-compiled disk verification utility (10KB). VERIFY.MAC in RC702E BIOS is a related but separate compilation (4KB app block, missing runtime). Low value — compiler output won't produce readable source.

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
