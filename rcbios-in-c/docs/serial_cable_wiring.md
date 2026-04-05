# RC700 Serial Cable Wiring

## RC700 SIO-A Configuration

The RC700 SIO Channel A (terminal/modem port) uses **Auto Enables**
(WR3 bit 5 = 1):
- **CTS gates the transmitter**: SIO won't send unless CTS is asserted
- **DCD gates the receiver**: SIO ignores incoming data unless DCD is asserted

Both signals MUST be driven by the cable for reliable communication.

Default serial parameters: **19200 baud, 8-N-1** (configurable via CONFI.COM).

## FTDI USB-Serial (DB-9) ↔ RC700 (DB-25)

Note: DB-9 and DB-25 use different pin numbers for TX/RX.
Both sides are DTE (Data Terminal Equipment).

### Pin reference

| Signal | Direction | FTDI DB-9 | RC700 DB-25 |
|--------|-----------|-----------|-------------|
| TX     | output    | Pin 3     | Pin 2       |
| RX     | input     | Pin 2     | Pin 3       |
| RTS    | output    | Pin 7     | Pin 4       |
| CTS    | input     | Pin 8     | Pin 5       |
| DTR    | output    | Pin 4     | Pin 20      |
| DSR    | input     | Pin 6     | Pin 6       |
| DCD    | input     | Pin 1     | Pin 8       |
| GND    |           | Pin 5     | Pin 7       |

### Cable wiring

```
FTDI DB-9                    RC700 DB-25
─────────                    ───────────
Pin 3 (TX)  ──────────────── Pin 3 (RX)        Data: Mac → RC700
Pin 2 (RX)  ──────────────── Pin 2 (TX)        Data: RC700 → Mac
Pin 5 (GND) ──────────────── Pin 7 (GND)       Ground

Pin 4 (DTR) ──┬───────────── Pin 8 (DCD)       Assert DCD (SIO accepts data)
              └───────────── Pin 6 (DSR)       Assert DSR

Pin 8 (CTS) ──────────────── Pin 4 (RTS)       Flow control: RC700 → FTDI
Pin 7 (RTS) ──────────────── Pin 5 (CTS)       Flow control: FTDI → RC700
```

### Why each connection matters

- **Pin 3↔3, Pin 2↔2**: Data lines. Note: DB-9 pin 3 = TX, DB-25 pin 3 = RX,
  so same pin numbers but crossed function — no null modem needed.

- **FTDI DTR → RC700 DCD+DSR**: The SIO's Auto Enables feature requires DCD
  to be asserted before it will accept incoming data. Without this, the SIO
  silently drops received bytes. DSR is also driven for completeness.
  The FTDI asserts DTR when the port is opened.

- **RC700 RTS → FTDI CTS**: Hardware flow control. When the RC700's receive
  buffer fills, it de-asserts RTS. The FTDI sees CTS drop and stops sending.
  **This is the critical connection that prevents buffer overruns.**

- **FTDI RTS → RC700 CTS**: Allows the RC700 to send. The SIO's Auto Enables
  requires CTS to be asserted before it will transmit.

### Mac serial port configuration

```bash
# With hardware flow control (crtscts):
stty -f /dev/cu.usbserial-FT4SXZNY1 19200 cs8 -parenb -cstopb crtscts

# For screen:
screen /dev/cu.usbserial-FT4SXZNY1 19200,crtscts
```

The `crtscts` flag is essential — without it, the FTDI ignores CTS even
if the cable is wired correctly.

## Previous working cable (RC700 DB-25 ↔ PC DB-25)

This cable was used with a modem and straight serial connection (circa 1993).
Notes from the original build: `2-3, 3-2, (4+5 internally), 6+8-20, 7-7`.

```
RC700 DB-25                  PC DB-25
───────────                  ────────
Pin 2 (TX)  ──────────────── Pin 3 (RX)        Data crossover
Pin 3 (RX)  ──────────────── Pin 2 (TX)        Data crossover
Pin 7 (GND) ──────────────── Pin 7 (GND)       Ground

Pin 6 (DSR) ──┐
              ├──────────── Pin 20 (DTR)      PC DTR → RC700 DCD+DSR
Pin 8 (DCD) ──┘

                             Pin 4 (RTS) ──┐   PC RTS looped to CTS
                             Pin 5 (CTS) ──┘   (internal short on PC side)
```

This cable worked because:
- PC DTR drove RC700 DCD — satisfying Auto Enables for reception
- PC RTS↔CTS were shorted — PC always thought it could send
- No hardware flow control from RC700 to PC — relied on the PC being
  fast enough (or software flow control via XON/XOFF)

The lack of RC700 RTS → PC CTS meant no hardware flow control from the
RC700 side, which worked at the time because the modem/PC could keep up.
With modern file transfers (PIP from serial), hardware flow control is
needed to prevent buffer overruns.

## Current problem (9-25 null modem cable)

The user's current cable is a generic 9-25 null modem with pins 6+19
shorted on the 25-pin side. Problems:

1. **RC700 DCD likely not asserted**: Without FTDI DTR → RC700 DCD,
   Auto Enables intermittently blocks reception
2. **No flow control**: RC700 RTS not connected to FTDI CTS, so the
   FTDI sends continuously regardless of RC700 buffer state
3. **Buffer overruns at 16KB boundaries**: CP/M PIP writes to disk in
   16KB extents — during disk writes, the SIO receive buffer fills
   and overflows because the FTDI doesn't stop sending

## Troubleshooting

If characters still drop after wiring the cable correctly:

1. Verify `crtscts` is set on the Mac side
2. Check with `stty -f /dev/cu.usbserial-FT4SXZNY1 -a` that crtscts is shown
3. Test flow control: send a large file while monitoring RC700 RTS with
   a multimeter — it should toggle during disk writes
4. If the FTDI dual-port chip shares RTS/CTS between channels, try port 0
5. Reduce baud rate as a workaround: `9600` is more forgiving of timing
