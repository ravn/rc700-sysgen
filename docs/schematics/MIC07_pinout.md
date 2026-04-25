# MIC07 — Keyboard & Parallel In/Out (Z80 PIO connectors)

Source: `RC702-RC703_Microcomputer_technical_manual.pdf`, sheet MIC07
(PDF page 77). Image renders alongside this file:

- `MIC07_keyboard_parallel.png` — full sheet at 450 DPI
- `MIC07_keyboard_parallel_crop.png` — right side, PIO chip + connector
  pin assignments, easier to read

## Z80 PIO chip (Z80A-PIO/2)

| PIO pin | Signal | Notes |
|---------|--------|-------|
| 2  | D7    | data bus |
| 4  | CE    | chip enable |
| 5  | C/D SEL | (sheet labels "CONT/DATA") |
| 6  | B/A SEL | port select |
| 7  | D6 |   |
| 8  | A5 | Port A bit 5 |
| 9  | A4 | Port A bit 4 |
| 10 | D3 |   |
| 12 | A3 | Port A bit 3 |
| 13 | A2 | Port A bit 2 |
| 14 | A1 | Port A bit 1 |
| 15 | A0 | Port A bit 0 |
| 16 | ASTB | Port A strobe (input). Pulled up to +5V via R38 (15K). |
| 17 | BSTB | Port B strobe (input). Pulled up to +5V via R39 (15K). |
| 18 | (unused on this sheet — actually B/A SEL routing, see schematic) |
| 19 | D0 |   |
| 20 | D1 |   |
| 21 | BRDY | Port B ready (output) — wired to J3 |
| 22 | IEO | interrupt enable out |
| 23 | INT | interrupt request |
| 24 | IEI | interrupt enable in |
| 25 | C   | clock |
| 27 | B0 | Port B bit 0 |
| 28 | (ARDY — see note) |
| 29 | B2 | Port B bit 2 |
| 30 | B3 | Port B bit 3 |
| 31 | B4 | Port B bit 4 |
| 32 | B5 *and* D4 — sheet label is ambiguous, double-check on second pass |
| 33 | B6 |   |
| 34 | B7 |   |
| 35 | RD |   |
| 36 | IORQ |   |
| 37 | M1 |   |
| 39 | D5 |   |

(The exact data-bus / Bn pin numbering should be cross-checked against
the Z80 PIO datasheet — the OCR/handwriting on the sheet is hard to
read in a few places. The connector mapping below is the load-bearing
part and is unambiguous.)

## J4 — "keyboard" connector (PIO Port A side)

DSUB-25 female on the back of the machine. **Verified 2026-04-17 from
MIC07 schematic (page 69 of the technical manual PDF).**

| J4 pin | PIO pin | PIO signal | Sheet label |
|--------|---------|-----------|-------------|
| 22 | 15 | A0 | KEY 0 |
| 23 | 14 | A1 | KEY 1 |
| 24 | 13 | A2 | KEY 2 |
| 21 | 12 | A3 | KEY 3 |
| 17 | 9  | A4 | KEY 4 |
| 18 | 8  | A5 | KEY 5 |
| 19 | 7  | A6 | KEY 6 |
| 20 | 6  | A7 | KEY 7 |
| 12 | 16 | ASTB | KEYSTROBE (pulled up via R38 15K → +5V) |
| 1  | — | **0V (GND)** | power ground |
| 25 | — | **+5V** | logic supply |
| 3, 13, 14 | — | **+12V** | auxiliary supply (not GND — keyboard pulls its +12V from here) |
| remaining | — | unused | — |

**ARDY (Z80 PIO pin 28) is NOT wired out to J4.** The original RC702
firmware only ever needed strobed *input* from the keyboard, so the
designer left ARDY unconnected on the chip side.

**Caveat for cable work:** J4-3/13/14 carry **+12V**, not ground. A cable
that shorts those pins to ground (or to a 5 V logic line) could damage
the supply regulator. Use J4-1 as the ground reference, not pins 3/13/14.

## J3 — "parallel" connector (PIO Port B side)

DSUB-25 female. Currently unused by the BIOS. **Verified 2026-04-17
from MIC07 schematic (page 69 of the technical manual PDF).**

| J3 pin | PIO pin | PIO signal | Sheet label |
|--------|---------|-----------|-------------|
| 22 | 27 | B0 | IN/OUT 0 |
| 23 | 28 | B1 | IN/OUT 1 |
| 24 | 29 | B2 | IN/OUT 2 |
| **21** | 30 | B3 | IN/OUT 3 |
| 17 | 31 | B4 | IN/OUT 4 |
| 18 | 32 | B5 | IN/OUT 5 |
| 19 | 33 | B6 | IN/OUT 6 |
| 20 | 34 | B7 | IN/OUT 7 |
| **2**  | 17 | BSTB | /STROBE (input, pulled up via R39 15K → +5V) |
| 12 | 21 | BRDY | (B) REGISTER READY (output) |
| 3, 13, 14 | — | 0V (ground) |

Corrections vs. prior OCR pass:
- **B3 is on J3-21**, not J3-25 as previously guessed.
- **BSTB is on J3-2** (the obscured pin number in the earlier crop).
- J3-25 is unused (no signal shown on the schematic).

## Implications for the bidirectional host link plan

The original design intent was PIO Port A in **Mode 2** (bidirectional)
using J4 as a single-cable host link. Mode 2 needs four handshake lines
on Port A: ASTB, ARDY, BSTB, BRDY. From this sheet:

| Signal | Wired on... |
|--------|-------------|
| 8 data lines (PA0–PA7) | J4 ✓ |
| ASTB | J4 ✓ |
| ARDY | **nowhere — not connected to either J3 or J4** ✗ |
| BSTB | J3 (would be needed on J4 for Mode 2) ✗ |
| BRDY | J3 (would be needed on J4 for Mode 2) ✗ |

**Mode 2 cannot work through J4 alone.** Combined with the 2026-04-25
keyboard-on-J4 constraint (the physical RC722 keyboard must remain
plugged into J4 in production), the original three workaround options
(half-duplex on J4, Y-cable J3+J4, case-open ARDY rewire) are all dead.

**Resolution (2026-04-25):** the network channel moved entirely to
**PIO-B / J3** instead of PIO-A / J4. J3 has both BSTB and BRDY routed
natively, so Port B can run a full-handshake Mode 1 input or Mode 0
output without any rewiring. The keyboard stays on PIO-A / J4. See
[`../cpnet_fast_link.md`](../cpnet_fast_link.md) for the committed
design ("Option P", PIO-B half-duplex, direction-switched at CP/NET
frame boundaries). The schematic findings above remain useful as the
load-bearing evidence behind that pivot.

Earlier "open items" about ringing out J4 pins for ARDY routing or
identifying spare J4 pins are no longer relevant — Option P touches
neither J4 nor the PIO chip's ARDY pin.
