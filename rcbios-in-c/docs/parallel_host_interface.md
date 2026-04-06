# Parallel Host Interface via PIO-A

## Concept

Use the Z80 PIO Port A in Mode 2 (bidirectional with handshake) for
high-speed communication with a modern host computer. This provides
~25-30KB/s throughput vs ~3.8KB/s for 38400 baud serial — about 8×
faster.

## Hardware Changes

### Move keyboard from PIO-A to PIO-B

The keyboard is connected with a movable cable — trivial to relocate.

- **Before**: PIO-A = keyboard input, PIO-B = parallel printer output
- **After**: PIO-A = bidirectional host interface, PIO-B = keyboard input

PIO-B configured as Mode 1 (input) with interrupt for keyboard.
PIO-A configured as Mode 2 (bidirectional) with interrupt for host I/O.

### Z80 PIO Mode 2 (bidirectional)

Mode 2 is only available on Port A. It provides:
- 8-bit bidirectional data bus (PA0-PA7)
- ASTB (input): host strobe — latches data from host, generates interrupt
- ARDY (output): RC700 ready — signals host that data is available or
  that RC700 is ready to accept data

Protocol:
- **Host → RC700**: Host places byte on PA0-PA7, pulses ASTB. PIO latches
  data, generates interrupt, de-asserts ARDY until ISR reads the byte.
- **RC700 → Host**: CPU writes byte to PIO port, PIO asserts ARDY. Host
  reads data lines and acknowledges. PIO de-asserts ARDY.

Built-in hardware handshake — no buffer overrun possible.

### PIO is not connected to DMA

All transfers are CPU-driven (interrupt or polling). The Am9517A DMA
channels are hardwired to HD, FDC, and CRT — the PIO has no DMA path.
This is fine; interrupt-driven I/O gives ~25-30KB/s.

### Interrupt vector changes

| Vector | Before | After |
|--------|--------|-------|
| PIO-A | Keyboard input | Parallel host RX |
| PIO-B | Parallel printer | Keyboard input |

## Host-Side Hardware

### Recommended: Raspberry Pi Pico

- 26 GPIO pins (8 data + ASTB + ARDY = 10 pins)
- Native USB (appears as CDC serial device to Mac/Linux)
- PIO state machines can match Z80 PIO handshake timing precisely
- Cheap (~$4)
- Simple CircuitPython or C firmware

### Voltage Level Issue

The Z80 PIO outputs 5V TTL levels. The Pico is 3.3V and **not 5V
tolerant** (max input 3.63V). Level shifting is required.

Options (cheapest first):

1. **Resistor dividers** — 10k+20k per line for PIO→Pico direction
   (8 data + ARDY = 9 lines, 18 resistors). Pico 3.3V output is
   fine as Z80 TTL input (3.3V > 2.0V high threshold). Cheapest.

2. **Bidirectional level shifter board** — TXS0108E (8-channel) or
   similar. Clean, compact, handles both directions automatically.

3. **74LVC245** — 8-bit bus transceiver, 5V tolerant inputs, 3.3V
   outputs. Need direction control pin tied to PIO mode.

### Alternative host hardware (no level shifter needed)

- **Arduino Mega** — 5V ATmega2560, plenty of 5V-tolerant GPIO pins
- **STM32F103 "Blue Pill"** — 5V tolerant GPIO, 72MHz ARM, very fast
- **Old PC with parallel port** — DB-25 LPT port, 5V native. Rare now
  but works with simple cable. Linux `parport` driver.

### Not suitable (3.3V, not 5V tolerant)

- Raspberry Pi 3B/4 — needs level shifter like Pico
- ESP32 — not 5V tolerant

## BIOS Changes

### PIO initialization (bios_hw_init.c)

```c
/* PIO-A: Mode 2 (bidirectional), interrupt enabled → parallel host */
port_out(pio_a_ctrl, 0b10001111);  /* mode 2 */
port_out(pio_a_ctrl, par_intvect); /* interrupt vector */
port_out(pio_a_ctrl, 0b10000011);  /* interrupt enable */

/* PIO-B: Mode 1 (input), interrupt enabled → keyboard */
port_out(pio_b_ctrl, 0b01001111);  /* mode 1 (input) */
port_out(pio_b_ctrl, kbd_intvect); /* interrupt vector */
port_out(pio_b_ctrl, 0b10000011);  /* interrupt enable */
```

### ISR changes

- `isr_pio_kbd()`: read from PIO-B data port (was PIO-A)
- New `isr_pio_par()`: read from PIO-A, store in parallel ring buffer

### IOBYTE mapping

| IOBYTE device code | Physical device |
|--------------------|----------------|
| UC1: (CON: = 3) | PIO-A parallel (bidirectional console) |
| UR1: (RDR: = 2) | PIO-A parallel input |
| UP1: (PUN: = 2) | PIO-A parallel output |
| UL1: (LST: = 3) | PIO-A parallel output |

## Throughput Estimate

- PIO Mode 2 interrupt-driven: 1 byte per ISR (~30-40µs) = ~25-30KB/s
- Polling tight loop: potentially 100KB/s+
- vs serial 38400 baud: ~3.8KB/s
- Speedup: 7-8× (interrupt) to 26× (polling)

For file transfers: a 50KB hex file takes ~13s at serial, ~2s at parallel.

## Pico Firmware Sketch

```python
# CircuitPython on Pico — USB-to-Z80-PIO bridge
import board, digitalio, usb_cdc

# 8 data pins + ASTB (output to Z80) + ARDY (input from Z80)
data_pins = [board.GP0, ..., board.GP7]
astb = digitalio.DigitalInOut(board.GP8)  # strobe to Z80
ardy = digitalio.DigitalInOut(board.GP9)  # ready from Z80

# USB → Z80: read USB byte, set data pins, pulse ASTB
# Z80 → USB: wait for ARDY, read data pins, send to USB
```

Actual firmware TBD when hardware is ready.
