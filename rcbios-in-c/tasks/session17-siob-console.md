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

### CTC0 configuration: counter mode, divide-by-1

CTC0 mode = 0x47 (counter mode, not timer). Count = 1. CLK/TRG input is
614400 Hz (separate oscillator, not derived from 4 MHz CPU clock). With SIO
x16 mode (WR4 = 0x44): baud = 614400 / 16 = 38400.

### Available rates with SIO x1 mode

Switching SIO WR4 to x1 clock mode (0x04), baud = 614400 / CTC_count:

| CTC count | Baud rate | Status |
|-----------|-----------|--------|
| 1         | 614400    | SIO can handle (within Z80A 800K spec) but FTDI can't match |
| 2         | 307200    | SIO handles single bytes perfectly; FTDI 2.34% off → errors |
| 4         | 153600    | **Reliable** — both short and bulk echo tests pass |
| 8         | 76800     | Near-clean (4/256 bulk errors — FTDI 2.34% mismatch) |

### Z80A SIO theoretical limit

From Zilog Z80 SIO Product Specification (Feb 1980): "Data rates of 0 to
800K bits/second with a 4.0 MHz clock (Z80A SIO)." So 614400 is within spec.

### FTDI FT2232D limitation (current adapter)

The FT2232D uses a 12 MHz base clock with 1/8-step fractional divisors.
For 307200: nearest divisor = 2.500 → actual = 300000 (2.34% error).
For 614400: nearest divisor = 1.250 → actual = 600000 (2.34% error).
The 2.34% error exceeds SIO x1 mode tolerance (no oversampling).

### FT2232H would fix this

The FT2232H uses a 48 MHz base clock. All RC700 rates land within 0.16%:
307200 → 307692 (0.16%), 614400 → 615385 (0.16%). Single-byte tests
confirmed the SIO handles 307200 and even 614400 (85% at 614400 due to
FTDI mismatch, not SIO failure).

### Standard PC serial port (16550, 1.8432 MHz)

Cannot produce 153600, 307200, or 614400 at any integer divisor. Only
matches RC700 at 38400 and below. Not useful for speed improvement.

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
- [ ] Investigate faster SIO-A transfer speeds once FT2232H adapter acquired
      (307200 or 614400 should work)
- [ ] Formalize deploy.sh for two-port mode (console on SIO-B, HEX on SIO-A)
- [ ] Consider interrupt-based SIO-A RX at higher baud rates — one interrupt
      per character may limit throughput (user noted this)

## FTDI Adapter Upgrade — Hardware Purchase Notes

### Problem

The current FTDI adapter is an **FT2232D** (12 MHz base clock, USB Full-Speed,
serial FT4SXZNY). Its 1/8-step fractional divisors cannot match the RC700's
non-standard baud rates above 153600:

| Target   | FT2232D actual | Error  | FT232R/FT2232H actual | Error  |
|----------|---------------|--------|----------------------|--------|
| 153600   | 153846        | 0.16%  | 153846               | 0.16%  |
| 307200   | 300000        | 2.34%  | 307692               | 0.16%  |
| 614400   | 600000        | 2.34%  | 615385               | 0.16%  |

Any FTDI chip with a 48 MHz clock (FT232R, FT232H, FT2232H, FT4232H, FT231X)
can match all three rates.  The Z80A SIO is rated for up to 800 kbps (Zilog
datasheet, Feb 1980), so 614400 is within spec.

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
