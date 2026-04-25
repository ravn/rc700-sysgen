# Parallel port as high-throughput host link

> **SUPERSEDED 2026-04-25.** This investigation plan targeted PIO
> Channel A (J4) with the `KBDPORT=B` keyboard relocation. Both
> assumptions are now obsolete:
>
> - Current design is **Option P** in
>   [`../../docs/cpnet_fast_link.md`](../../docs/cpnet_fast_link.md)
>   — PIO-B half-duplex via J3, keyboard stays on PIO-A / J4.
> - `KBDPORT=B` is no longer used; the keyboard remains on PIO-A
>   under the 2026-04-25 keyboard-on-J4 constraint.
> - The Linux-PC-with-LPT host approach is replaced by Pi 4B + Pi
>   Pico over USB-CDC; see the new doc.
>
> The text below is preserved for archaeological reference only.

## Motivation

Session 17 established that SIO-A async RX is hard-limited to 38400 baud by
the Z80 SIO's x1 clock recovery (see `session17-siob-console.md`). The user
is moving to a host with a real parallel port to investigate the RC700's
PIO Channel A as a higher-throughput data path.

## Hardware

- **RC700 side:** Z80-PIO Channel A, exposed at the external parallel
  connector. The existing BIOS uses it as output (parallel printer) in
  default `KBD_PIO_A` mode; an alternate `KBDPORT=B` build-time flag moves
  the keyboard to PIO Ch.B and frees Ch.A for host link.
- **Host side:** standard IEEE-1284 parallel port (`/dev/parport0` after
  `modprobe ppdev`).

See `docs/parallel_host_interface.md` if it exists, and the commit history
of `bios_jump_vector_table.c` / `bios_hw_init.c` for the PIO wiring.

## Advantages over serial

- 8 bits parallel → ~8× fewer handshakes per byte vs serial bit-banging
- Z80-PIO has mode 2 bidirectional with handshake (STB/RDY) — hardware
  flow control built in, no async framing / clock recovery issues
- No baud rate constraints — speed is gated by Z80 service loop only
- Could reach 50–200 kB/s with simple polled handshake

## Unknowns to investigate

- [ ] Current BIOS uses PIO-A for output (printer). Determine what
      re-purposing for host link breaks (parallel printer support).
- [ ] Verify `KBDPORT=B` build works on real hardware (was reportedly
      tested in MAME only).
- [ ] Physical wiring: which RC700 connector pins carry PIO-A data +
      handshake, and how do they map to DB-25 parallel (data 2-9, STROBE,
      ACK, BUSY)?
- [ ] Host-side driver: use `ppdev` ioctls or IEEE-1284 EPP mode for
      higher throughput?
- [ ] Z80-PIO mode 2 (bidirectional) vs mode 0 (output) vs mode 1 (input)
      — which protocol matches what the parallel port provides?

## Related work already on `sio-b-test-console` branch

- `KBD_PIO_B` compile flag (commit `b746c0c`): moves keyboard to PIO Ch.B
- Parked todo in `tasks/todo.md`: RP2040/Arduino parallel server

## References

- RC702 Hardware Technical Reference: PIO port mappings
- Z80-PIO datasheet (Zilog): mode 0/1/2 operation
- IEEE-1284 standard (parallel port modes)
