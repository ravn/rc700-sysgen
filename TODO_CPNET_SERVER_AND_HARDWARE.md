# TODO: CP/NET Physical Server and Diskless Boot

## Prerequisites

- CP/NET working with the C-BIOS in MAME (serial path, current SNIOS)

## Phase 1: MP/M Server on macOS

Investigate running an MP/M server process outside MAME that serves
CP/NET requests.  Options:

- **Python server.py** (current): already speaks DRI binary protocol over
  serial.  Extend to serve multiple clients or run as a daemon.
- **z80pack cpmsim**: runs MP/M II with NETSERVR.RSP.  Connect via TCP
  socket.  See `tasks/todo.md` Phase 2 notes.
- **CpnetSerialServer.jar**: Java server in cpnet-z80/contrib/, supports
  DRI protocol.  Needs decompiled sources (Phase 4 in tasks/todo.md).

Goal: reliable file serving from macOS to RC702 running in MAME over
serial, then over real serial hardware.

## Phase 2: Standalone Server (Raspberry Pi / PC)

Move the CP/NET server to a standalone machine:

- **Raspberry Pi**: USB-to-serial adapter or GPIO UART.  Run Python
  server or z80pack.  Low power, always-on.
- **PC with parallel port**: Direct parallel port connection to RC702
  PIO.  Higher bandwidth than serial (8-bit parallel vs bit-serial).
- **Network bridge**: Server on LAN, RC702 connects via serial or
  parallel to a bridge device.

## Phase 3: Parallel Port Data Transfer

Investigate using the RC702 PIO parallel port for CP/NET data transfer
instead of (or in addition to) the SIO serial port.

### PIO Port Assignment Problem

- **PIO-A (0x10)**: Currently used for keyboard input (directly active on main bus).
- **PIO-B (0x11)**: Currently used for output (active accent LED, active beeper).

To use PIO for bidirectional data transfer, the keyboard must move off
PIO-A.  Options:

1. **Move keyboard to PIO-B**: PIO-B is currently output-only with
   accent LED and beeper.  These could potentially share with keyboard
   scan (accent LED is active low, bit 5; beeper is active high, bit 4).
   Requires hardware analysis of the MIC702/703/704 keyboard interface.

2. **Use PIO-B for parallel data**: Keep keyboard on PIO-A, use PIO-B
   for parallel data.  Requires PIO-B to become bidirectional — check
   if accent LED and beeper can be sacrificed or relocated.

3. **Add external PIO**: Mount a second Z80-PIO on the expansion bus.
   Clean solution but requires hardware modification.

### Parallel Protocol Design

- PIO in mode 0 (output) or mode 1 (input) with handshake lines
- Strobe/acknowledge using PIO handshake (ARDY/ASTB or BRDY/BSTB)
- Byte-at-a-time with hardware handshake: ~100 KB/s potential
  (vs ~4.8 KB/s serial at 38400 baud)

## Phase 4: Diskless CP/NOS Client in PROM1

Investigate fitting a diskless CP/NOS network boot client in the 2 KB
PROM1 slot (address 0x2000).

### What CP/NOS Needs

- Network I/O driver (SNIOS-like, minimal)
- Enough protocol to send a boot request to the server
- Server responds with CCP+BDOS+BIOS image
- Client loads image to RAM and jumps to cold boot

### Size Budget

- PROM1 is 2048 bytes (2 KB)
- The ROA375 boot PROM (PROM0) is 2048 bytes and fits: self-relocate,
  hardware init, FDC driver, directory scan, boot load
- A network boot client needs: serial/parallel init, protocol framing,
  receive loop, memory load.  Should be feasible in 2 KB if the
  protocol is simple (no retransmit, server-initiated transfer).

### PROM Hardware Investigation

The RC702 technical manual specifies 2716 (2 KB) or 2732 (4 KB) EPROMs
for the PROM sockets.  Current hardware has a 2716 mounted in PROM1.

Questions:

- **2716 vs 2732 pinout compatibility**: The 2732 has A11 on pin 21
  where the 2716 has Vpp.  Check if the MIC702/703/704 board active routes
  pin 21 to an address line or ties it to Vcc.  If tied to Vcc, a 2732
  would only expose its upper 2 KB half (A11=1), which is usable but
  not ideal.
- **Board jumper or trace**: Some boards have jumpers to select 2716 vs
  2732.  Check MIC702/703/704 schematics.
- **4 KB would help**: With 4 KB, the CP/NOS client could include a
  more robust protocol (retransmit, error recovery) and even a minimal
  serial terminal for status messages.

### Reference

- CP/NOS: Digital Research's diskless CP/NET client OS
- PROM0 at 0x0000: ROA375 boot ROM (always present)
- PROM1 at 0x2000: optional, active used for "lineprog" (network boot) on
  some RC702 configurations
- RAMEN port write disables PROMs, enabling full RAM
