# Session 16 Summary

Date: 2026-04-08
Branch: main

## Headline

Investigated the bidirectional parallel host link plan
(`rcbios-in-c/docs/parallel_host_interface.md`) by reading the
RC702 hardware schematics. Discovered the Mode 2 plan is **likely
broken on stock hardware** — at least one of the four required Port A
handshake lines (ARDY) appears not to be wired to any external
connector, and the other two (BSTB/BRDY) come out on the wrong DSUB-25
connector. Hardware verification with a meter is the next step before
any code work.

No code changes. Documentation only.

## Background

User wants to connect the RC700 to a modern host machine over a fast
parallel link, replacing the current 38400-baud serial as the file
transfer path. The existing design doc proposes:

- Move keyboard from PIO Port A to Port B (Mode 1 input)
- Reconfigure PIO Port A as Mode 2 (bidirectional with hardware
  handshake — ASTB/ARDY/BSTB/BRDY)
- Estimated throughput 25–30 KB/s interrupt-driven, ~7× faster than
  the current serial link

Two clarifications from the user up front:
- Port B is currently **unused** by the BIOS (printer is on SIO B,
  not on PIO B), so the keyboard can move to PIO B without
  displacing anything.
- Both PIO ports are exposed on the back of the machine via female
  DSUB-25 connectors, with male connectors on the cable.
- Question: would a real PC LPT port work without level shifters?

## What was investigated

### 1. PC LPT compatibility

**Electrically: yes.** Both the Z80 PIO and a real PC LPT port (not a
USB-to-LPT adapter — those almost universally only emulate the
printer class and don't expose raw bidirectional GPIO) are 5 V TTL.
No level shifter, no buffering required. This is the big advantage
over a Pi Pico or RPi GPIO, both of which are 3.3 V and not 5 V
tolerant.

**Protocol-wise: not plug-and-play.** PC LPT hardware drives the
Centronics handshake (STROBE/BUSY/ACK), which doesn't match Z80 PIO
Mode 2's ASTB/ARDY/BSTB/BRDY. Even in EPP mode the timing model is
different. The realistic plan with a real LPT host is to put the
port in EPP/byte mode and bit-bang the PIO Mode 2 handshake from
userspace via `/dev/port` or `ppdev`. Throughput will be lower than
the design doc's estimate (a few KB/s, not 25–30 KB/s) because of
the userspace bit-banging, but still much faster than 38400 baud
serial and zero added hardware.

### 2. Schematic reading — MIC07

The RC702 technical manual
(`docs/RC702-RC703_Microcomputer_technical_manual.pdf`) sheet MIC07
("Keyboard & parallel in/out") shows the PIO chip with both
connectors. The page is a hand-drawn 1983 schematic and the OCR
layer mangles the pin tables, so the page was rendered to PNG with
poppler at 450 DPI and read visually.

Renders saved to `docs/schematics/`:

- `MIC07_keyboard_parallel.png` — full sheet
- `MIC07_keyboard_parallel_crop.png` — right-side crop with
  PIO-to-connector wiring
- `MIC07_pinout.md` — transcribed pin tables and analysis

What I read off the sheet (with confidence levels — see "Open
questions" below for what's still uncertain):

- **J4** — DSUB-25, currently the keyboard connector. Carries the
  signals labeled `KEY 0…7` (data bits) and `KEYSTROBE`. By
  cross-referencing the BIOS port assignment (port `0x10` = keyboard
  = PIO Port A data) this is **almost certainly** Port A.
- **J3** — DSUB-25, currently unused by the BIOS. Carries the
  signals labeled `IN/OUT 0…7`, `STROBE`, `REGISTER READY`. This is
  **almost certainly** Port B with its full Centronics-style
  handshake (BSTB in, BRDY out).

| J4 pin | PIO signal |
|--------|-----------|
| 21 | A0 (KEY 0) |
| 22 | A1 |
| 23 | A2 |
| 24 | A3 |
| 17 | A4 |
| 18 | A5 |
| 19 | A6 |
| 20 | A7 |
| 12 | ASTB (KEYSTROBE) |

(J3 pin table in `docs/schematics/MIC07_pinout.md`.)

### 3. The bad news for the Mode 2 plan

Mode 2 needs **all four** Port A handshake lines: ASTB, ARDY, BSTB,
BRDY. From the schematic:

| Signal | Wired on... |
|--------|-------------|
| 8 data lines (PA0–PA7) | J4 ✓ |
| ASTB | J4 ✓ |
| ARDY | apparently nowhere — not seen on J4 in the cropped view ✗ |
| BSTB | J3 (Port B's connector) ✗ |
| BRDY | J3 (Port B's connector) ✗ |

The original RC702 designer only ever needed *strobed input* from
the keyboard, so ARDY was apparently left dangling on the chip. And
BSTB/BRDY are wired to the wrong connector for a single-cable Mode 2
link.

**Caveat — this is not yet hardware-verified.** I read the right-side
crop of MIC07 and didn't see ARDY routed anywhere visible, but
"didn't see it" is absence-of-evidence, not evidence-of-absence. I
also didn't trace a single `KEY n` wire pin-by-pin from J4 back to a
clearly-numbered Port A pin on the chip — I inferred Port A
identity from the BIOS port mapping plus consistent-looking chip pin
numbers near the `KEY` group. The user explicitly pushed back on
both claims and the remaining uncertainty is recorded as open
questions.

## Three options for the bidirectional link

In increasing order of hardware effort:

1. **Half-duplex, no rewiring.** Stay in PIO Mode 0/1. Use ASTB to
   drive an RX interrupt for host→Z80 transfers. Z80→host has no
   hardware ack, so the host either polls on a fixed schedule or we
   bit-bang a software handshake on a spare data line via Mode 3.
   Slower than the design doc estimate but trivially doable. **No
   soldering.**

2. **Y-cable into J3 *and* J4 simultaneously.** Picks up BSTB and
   BRDY from J3 plus the data bus and ASTB from J4. Closer to a real
   Mode 2 link. **Still missing ARDY**, so the host must insert
   fixed delays after asserting ASTB. Fragile but workable for slow
   transfers. **No soldering, but a non-standard cable.**

3. **Open the case, add 1–3 wires.** Run ARDY (PIO chip pin 18) to
   a spare J4 pin, and ideally also run BSTB and BRDY from their J3
   pins over to spare J4 pins. Then a single DSUB-25 cable into J4
   is a complete Mode 2 link and we get the full ~25–30 KB/s the
   design doc estimated. **One open-case session, but the cleanest
   long-term result.**

A real PC LPT port (5 V TTL) is electrically compatible with all
three options.

## Decision

Stop here for now. The user will look at the actual hardware later
to verify the schematic readings before any cable work or BIOS
changes. Open questions and verification steps recorded in
`tasks/todo.md` under the new "Parallel host link" section.

## Files added / changed

- `docs/schematics/MIC07_keyboard_parallel.png` (new) — 450 DPI
  render of MIC07
- `docs/schematics/MIC07_keyboard_parallel_crop.png` (new) — right
  side crop
- `docs/schematics/MIC07_pinout.md` (new) — transcribed pin tables,
  full analysis, three options
- `rcbios-in-c/docs/parallel_host_interface.md` — added "Hardware
  verification needed" section warning that the Mode 2 plan
  assumes connectivity that has not been confirmed
- `tasks/todo.md` — new "Parallel host link" section with the
  hardware-check items
- `tasks/session16-summary.md` (this file)
