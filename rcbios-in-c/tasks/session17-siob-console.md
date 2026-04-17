# Session 17: SIO-B Shadow Console + Baud Rate Investigation

## Date: 2026-04-17

## Summary

Implemented SIO-B as a shadow console for the RC700, allowing a host to
control the machine over SIO-B (ttyUSB1) while SIO-A (ttyUSB0) remains free
for RDR:/PUN: data transfers (HEX uploads). Also investigated maximum baud
rates achievable on SIO-A.

## BIOS Changes (branch: sio-b-test-console)

### 1. SIO-B console probe at cold boot (bios_hw_init.c)

New `siob_console_probe()` function in BOOT_CODE (overwritten after boot, no
resident cost). Sends ENQ (0x05) on SIO-B TX, polls RR0 for ~300 ms for any
reply byte. If host responds, sets `iobyte = IOBYTE_DEFAULT_SIOB` (0x96,
CON:=BAT). Otherwise falls back to `IOBYTE_DEFAULT` (0x97, CON:=UC1).

Probe runs with interrupts disabled, polls SIO-B directly (ISR not active).

### 2. IOB_BAT = keyboard + SIO-B joined console (bios.c, bios.h)

Repurposed the CON:=BAT IOBYTE mode to mean "console on SIO-B":

- **CONIN (bios_conin):** polls both keyboard ring buffer AND SIO-B ring
  buffer (rxbuf_b). First source with data wins.
- **CONST (bios_const):** checks both keyboard and SIO-B ring for data ready.
- **CONOUT (bios_conout_c):** sends to SIO-B via polled TX (`siob_conout`),
  PLUS echoes to the CRT display. Both local user and remote host see output.

Keyboard encoding changed from `(con & 1)` to `(con != IOB_TTY)` so keyboard
works in BAT mode (was previously keyboard-disabled for BAT).

### 3. Polled SIO-B TX (siob_conout)

New `siob_conout()` function replaces `list_lpt()` for CON:=BAT output.
Uses polled I/O (checks RR0 bit 2 for TX empty) instead of interrupt-driven
TX via `prtflg`. **Critical fix:** `list_lpt()` spins on `while (!prtflg)`
which requires the SIO-B TX ISR, but the cold-boot signon banner is printed
before `EI` — causing a deadlock. Polled TX works with interrupts disabled.

### 4. IOBYTE_DEFAULT_SIOB constant (bios.h)

`#define IOBYTE_DEFAULT_SIOB 0x96` — same as IOBYTE_DEFAULT (0x97) but with
CON field changed from UC1(3) to BAT(2). RDR:, PUN:, LST: unchanged.

### Sizes

| Compiler | Before | After | Delta |
|----------|--------|-------|-------|
| Clang    | 6021   | 6108  | +87   |
| SDCC     | 6049   | —     | —     |

The +87 bytes are from siob_conout, expanded conin/const logic, and CRT echo
code in bios_conout_c. The probe itself is in BOOT_CODE (free).

## Host-Side Tooling

### SIO-B console daemon (/tmp/siob_daemon.py)

Python daemon that holds ttyUSB1 open, reads serial → stdout + log file
(`/tmp/siob_console.log`), reads command FIFO (`/tmp/siob_cmd`) → serial.
Auto-responds to ENQ probe at boot. Runs detached via `nohup`.

### Dual-port deploy flow

Successfully deployed BIOS using SIO-B for console and SIO-A for HEX:
1. PIP CPM56.HEX=RDR: (console command on SIO-B)
2. HEX data streamed on SIO-A (RDR: default = PTR = SIO-A)
3. MLOAD, verify, SYSGEN all driven through SIO-B console

No more blind spots — console visible throughout the entire deploy.

## Baud Rate Investigation

### Clock sources

Two clock sources feed the CTC for SIO baud generation:
- **614400 Hz external oscillator** → CTC counter mode → 614400/N
- **4 MHz CPU clock** → CTC timer mode (prescaler /16) → 250000/N

The SIO supports x1, x16, x32, x64 clock multipliers. In x16 mode the SIO
oversamples 16× and finds the center of each bit. In x1 mode it samples
once per bit on the clock edge — no oversampling.

### Z80A SIO theoretical limit

From Zilog Z80 SIO Product Specification (Feb 1980): "Data rates of 0 to
800K bits/second with a 4.0 MHz clock (Z80A SIO)."

### TX vs RX asymmetry

TX (Z80→host) at x1 250000 baud: **8192 bytes, 0 errors, 23 KB/s.** The
transmitter generates its own timing and works perfectly at x1.

RX (host→Z80) at x1 mode: has inherent framing errors for continuous data
(see below).

### Definitive RX sweep (2 stop bits, DI, SIO auto-RTS, 8KB per rate)

Tested all achievable baud rates on clean-booted hardware. Both with and
without SIO Auto Enables (WR3 bit 5 = hardware RTS/CTS flow control).
Results were identical — flow control doesn't help because the Z80 poll
loop reads faster than data arrives, so the 3-byte FIFO never fills and
RTS never drops.

| Baud    | Clock source     | SIO  | FTDI err | RX    | Errors | Rate  |
|---------|------------------|------|----------|-------|--------|-------|
| **38400**   | **ctr/1**    | **x16** | **0.16%** | **8192** | **0** | **0.0%** |
| 41667   | tmr16/6          | x1   | 0.00%    | 8192  | 46     | 0.6%  |
| 50000   | tmr16/5          | x1   | 0.00%    | 8192  | 56     | 0.7%  |
| 62500   | tmr16/4          | x1   | 0.00%    | 8192  | 58     | 0.7%  |
| 76800   | ctr/8            | x1   | 0.16%    | 8192  | 167    | 2.0%  |
| 83333   | tmr16/3          | x1   | 0.00%    | 8192  | 92     | 1.1%  |
| 125000  | tmr16/2          | x1   | 0.00%    | 8191  | 897    | 10.9% |
| 153600  | ctr/4            | x1   | 0.16%    | 8190  | 3765   | 46.0% |
| 250000  | tmr16/1          | x1   | 0.00%    | 8187  | 6531   | 79.8% |

### Root cause of x1 RX errors

In x16 mode the SIO counts 8 clock edges from the start bit's falling edge
to find the **center** of each bit, then samples every 16 clocks. In x1
mode, data is sampled directly on clock edges which land at **bit
boundaries** — not bit centers. For isolated bytes with idle gaps the start
bit detection works. For continuous streams the sampling point cannot
re-center and framing errors cascade.

Key evidence:
- Timer mode (clean square wave from 4 MHz) and counter mode (from 614400
  Hz oscillator) give the same error pattern — not a waveform quality issue
- 0.00% FTDI baud match (250000) fails just as badly as 0.16% (153600) —
  not a clock mismatch issue
- SIO Auto Enables (hardware RTS/CTS) doesn't help — not a buffer overflow
- Channel reset before WR4 change makes no difference
- DI (no ISR interference) makes no difference
- Single isolated bytes work at all rates up to 614400 — the SIO hardware
  CAN clock at these speeds, just not for continuous async data

### Conclusion

**38400 x16 is the maximum reliable continuous RX rate** with the RC700's
614400 Hz oscillator and Z80 SIO in asynchronous mode. No software or
adapter change can fix the x1 mode framing problem — it's a fundamental
limitation of the SIO's x1 async clock recovery.

Paths to faster inbound data:
- Replace the 614400 Hz oscillator with a higher frequency (hardware mod)
  so x16 mode gives a higher baud (e.g., 1.2288 MHz → 76800 x16)
- Use synchronous mode (requires non-UART host interface)
- Use the parallel PIO port instead of serial
- Accept 38400 and optimize the protocol (fewer round-trips)

### Standard PC serial port (16550, 1.8432 MHz) — NOT useful

Cannot produce any rate the RC700 uses above 38400. Even the Nuvoton
NCT6681D high-speed mode (24 MHz) misses: 24M/16/N doesn't hit 153600 etc.

## Bugs Found and Fixed

### Deadlock: list_lpt at cold boot (FIXED)

**Symptom:** machine hung after probe succeeded — no signon, no A>.
**Root cause:** `bios_conout_c` IOB_BAT case called `list_lpt()` which spins
on `while (!prtflg)`. The `prtflg` flag is set by `isr_sio_b_tx`, but
interrupts are disabled during the cold-boot signon banner. Deadlock.
**Fix:** replaced with `siob_conout()` using polled TX (RR0 bit 2 check).

### DDT test program stuck (FIXED in test program)

**Symptom:** baud rate test program's SIO-B exit key not recognized.
**Root cause:** SIO-B RX ISR consumed the byte before the polling loop saw it.
**Fix:** added DI at program start (the test uses polled I/O for everything).

## Future Work

- [ ] Make SIO-B console conditional on a DIP switch (similar to SW1 #7
      mini/maxi), instead of ENQ probe — user request
- [ ] Formalize deploy.sh for two-port mode (console on SIO-B, HEX on SIO-A)
- [ ] Investigate faster inbound data paths: oscillator change, PIO parallel
      port, or synchronous SIO mode with MPSSE host interface
- [ ] FT2232H adapter would NOT help RX speed (x1 mode is the bottleneck,
      not FTDI clock mismatch) — but would enable 250000 baud TX (Z80→host)

## FTDI Adapter Upgrade — Hardware Purchase Notes

### Status: adapter upgrade NOT needed for RX speed

The baud rate investigation conclusively showed that the SIO's x1 async mode
has inherent framing errors at all rates, regardless of FTDI clock accuracy.
An FT2232H (48 MHz) would NOT improve inbound (host→Z80) transfer speed —
38400 x16 is the ceiling due to the SIO, not the FTDI.

An FT2232H WOULD enable 250000 baud TX (Z80→host) with exact clock match
(currently the FT2232D matches 250000 exactly too, so this is already fine).

The current FT2232D adapter is adequate for all practical use cases.

### Standard PC serial port (16550 UART) — NOT useful

1.8432 MHz crystal cannot produce 153600, 307200, or 614400 at any integer
divisor.  Even the Nuvoton NCT6681D high-speed mode (24 MHz) misses: 24M/16/N
doesn't hit any of these rates.  Only matches RC700 at 38400 and below.

### Recommended adapters

**Quick — Danish stock (Proshop.dk):**
Two × StarTech ICUSB2321F (264 kr each, FT232RL, single DB9, in stock,
next-day delivery). One for SIO-A (fast data), one for SIO-B (38400 console).
FT232RL has 48 MHz internal clock — confirmed capable of 307200/614400.
StarTech's "max 115.2 kbps" is conservative marketing; the chip does 3 Mbaud.
https://www.proshop.dk/Netvaerksadapter-netkort-printserver-mv/StarTechcom-1-Port-FTDI-USB-to-Serial-RS232-DB9/2350285

**Cheaper — Amazon.de (2-5 day delivery to DK):**
AYA FT2232H dual DB9 cable (~€20-25). Single USB, two DB9, confirmed FT2232H.
https://www.amazon.de/Serial-RS232-Konverter-Adapter-FT2232H-Linux/dp/B0798HQ6DV

**Avoid:**
- Plexgear/unbranded adapters that don't specify chipset — likely PL2303 or
  CH340 with 12 MHz clock or poor non-standard baud support on Linux.
- Any adapter listing only "FT2232" without the "H" suffix — may be FT2232D
  (12 MHz), same limitation as current adapter.

### Wiring notes

The RC700 has DB-25 RS-232 connectors. Current setup uses a straight DB-9 to
DB-25 cable with a mini null-modem adapter (see `docs/serial_cable_wiring.md`).
New adapter(s) would use the same cable/wiring — only the USB end changes.

SIO-B stays at 38400 (CTC1 count=1, SIO x16) regardless of adapter.
SIO-A speed upgrade requires both the new adapter AND reprogramming CTC0+WR4
to x1 clock mode (done at transfer time, restored after).
