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

DSUB-25 female on the back of the machine.

| J4 pin | PIO pin | PIO signal | Sheet label |
|--------|---------|-----------|-------------|
| 21 | 15 | A0 | KEY 0 |
| 22 | 14 | A1 | KEY 1 |
| 23 | 13 | A2 | KEY 2 |
| 24 | 12 | A3 | KEY 3 |
| 17 | 9  | A4 | KEY 4 |
| 18 | 8  | A5 | KEY 5 |
| 19 | 7  | A6 | KEY 6 |
| 20 | 6  | A7 | KEY 7 |
| 12 | 16 | ASTB | KEYSTROBE (pulled up via R38 15K → +5V) |
| 1, 25, 3, 13, 14, 15 | — | +5V / 0V (power & ground pins; exact split TBD on next pass) |

**ARDY (Z80 PIO pin 28) is NOT wired out to J4.** The original RC702
firmware only ever needed strobed *input* from the keyboard, so the
designer left ARDY unconnected on the chip side.

## J3 — "parallel" connector (PIO Port B side)

DSUB-25 female. Currently unused by the BIOS.

| J3 pin | PIO pin | PIO signal | Sheet label |
|--------|---------|-----------|-------------|
| 22 | 27 | B0 | IN/OUT 0 |
| 23 | 28 | B1 | IN/OUT 1 |
| 24 | 29 | B2 | IN/OUT 2 |
| 25 | 30 | B3 | IN/OUT 3 |
| 17 | 31 | B4 | IN/OUT 4 |
| 18 | 32 | B5 | IN/OUT 5 |
| 19 | 33 | B6 | IN/OUT 6 |
| 20 | 34 | B7 | IN/OUT 7 |
|  ? | 17 | BSTB | STROBE (input, pulled up via R39 15K → +5V) |
| 12 | 21 | BRDY | REGISTER READY (output) |
| 3, 13, 14 | — | 0V (ground) |

(The BSTB pin number on J3 is partly obscured in the crop — needs a
second look at MIC07 to confirm.)

## Implications for the bidirectional host link plan

We wanted to put PIO Port A in **Mode 2** (bidirectional) and use J4 as
a single-cable host link. Mode 2 needs four handshake lines on Port A:
ASTB, ARDY, BSTB, BRDY. From this sheet:

| Signal | Wired on... |
|--------|-------------|
| 8 data lines (PA0–PA7) | J4 ✓ |
| ASTB | J4 ✓ |
| ARDY | **nowhere — not connected to either J3 or J4** ✗ |
| BSTB | J3 (would be needed on J4 for Mode 2) ✗ |
| BRDY | J3 (would be needed on J4 for Mode 2) ✗ |

**Mode 2 cannot work through J4 alone.** Three options, in increasing
order of effort:

1. **Half-duplex, no rewiring.** Stay in Mode 0/1 + interrupt-driven
   RX via ASTB. Host→Z80 transfers work fine. Z80→host is unhandshaked
   — host has to poll the data lines on a known schedule, or we drop
   into Mode 3 (bit control) and bit-bang a software handshake on a
   spare data line. Slow but no soldering.

2. **Y-cable into J3 + J4.** Wire a single host-side connector to
   *both* J3 and J4. This gets us BSTB and BRDY (from J3) plus the data
   bus and ASTB (from J4). **Still missing ARDY.** Without ARDY the
   PIO can't tell the host "I've taken your input byte, you can drop
   ASTB". The host would have to insert a fixed delay, which is fragile
   but works for a slow link.

3. **Open the machine, add 1–3 wires.** Run ARDY (PIO chip pin 28) to a
   spare J4 pin, and optionally also run BSTB and BRDY from their J3
   pins over to spare J4 pins. Then a single DSUB-25 cable into J4 is
   a complete Mode 2 link. This is the only option that gives the
   full ~25–30 KB/s the design doc estimated.

A PC LPT port is still electrically compatible with all three options
(5 V TTL on both sides), so the level-shifter discussion doesn't
change.

## Open items before committing to a hardware plan

- Confirm the J4 pin numbers above by re-reading MIC07 at higher zoom,
  particularly the +5V/0V pin assignments.
- Check whether the J4 connector has unused pins available to take
  ARDY (and optionally BSTB/BRDY) without colliding with anything.
- Cross-check J3's BSTB pin number — the crop is partly obscured.
- Decide which of the three options above is acceptable. If option 3
  (open the case) is on the table, this becomes a much nicer protocol.
