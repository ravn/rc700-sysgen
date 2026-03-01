# Build all 13 CP/M BIOSes from source

## Completed
- [x] Step 1: Fetch jbox.dk originals → `rcbios/jbox-originals/` (16 files)
- [x] Step 2: Trivial targets — rel14-mini, rel23-mini added to Makefile
- [x] Step 3: REL20 conditional (56K rel.2.0) — byte-verified
- [x] Step 4: RC703 family (separate source tree) — 3 variants byte-verified
- [x] Step 5: RC702E family (separate source tree) — 2 variants byte-verified
- [x] Step 6: 58K family (separate source tree) — 3 variants byte-verified
- [x] Step 7: 58K label renaming — auto-labels replaced with meaningful names

## Next: MAME RC702 serial port + CP/NET

### Goal
Add SIO Channel B (terminal serial port) to MAME rc702 driver so CP/M programs
can communicate over serial — initially to a macOS host shell or telnet to localhost.
Longer term: run a CP/NET client on CP/M talking to a CP/NET server on the macOS host
to exchange files.

### Steps
1. Wire up SIO Channel B in MAME rc702.cpp (currently only Channel A / printer is connected)
2. Connect to a bitbanger or rs232 port so MAME exposes it as a host-side serial device
3. Modify BIOS SIO Channel B receive ISR to use a ring buffer (e.g., 256 bytes)
   instead of single-byte variable. CONST checks head!=tail, CONIN reads from tail.
   Note: doesn't help during DI (FDC ops) — SIO 3-byte FIFO is the limit there.
4. Test with a CP/M terminal program (e.g. MEX, MODEM7, or similar)
5. Build CP/NET client for RC702 CP/M (BIOS PUNCH/READER or dedicated serial driver)
6. Build CP/NET server on macOS host (file server, console redirection)

### Notes
- RC702 SIO: Channel A = printer port, Channel B = terminal port
  (CONFI.COM labels are swapped — see MEMORY.md)
- BIOS LINSEL entry controls DTR/RTS for RC791 line selector
- Default serial config: 7-bit, even parity, 1 stop, 1200 baud (CTC=0x20)
- rel.2.2 defaults to 19200 baud (CTC=0x02)
- SIO port B should run as fast as the physical hardware allows (CTC=1 → 38400 baud with x16 clock)
- In MAME the emulated baud rate is artificial — run at max speed the hardware permits
- See [cpnet.md](../cpnet.md) for full CP/NET research, software sources, and protocol details

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
See `memory/bgstar_analysis.md` for section-by-section breakdown with addresses
and byte counts.

## Parked (not working on now)
- [ ] 58K rel.1.4: 4 ISR-specific auto-labels remain in BIOS_58K_14.MAC (sub_e43dh, lee8ah, lee8bh, lf421h)

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
