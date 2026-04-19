# Session 23 (2026-04-19/20) — SIO flow control bug + integration test

## Summary

Found and fixed a long-standing bug in the BIOS async TX paths that
defeated RTS flow control on both serial ports.  Added symmetric RTS
flow control to SIO-B.  Built a reusable 4096-byte bidirectional
integration test (`make sio-echo-test`) that exercises both SIOs via
BIOS routines directly.  Net BIOS size: 6013 → 6002 B (−11 B).

## The bug

`list_lpt`, `bios_punch_body` (SIO-A path), and `serial_conout` each
rewrote the SIO's WR5/WR1 on **every** transmitted byte, forcing
`RTS=1` (asserted) into bit 1 of WR5.  The RX ISR correctly deasserted
RTS when its 256-byte ring buffer hit `RXTHHI=248`, but the very next
TX byte clobbered it back.  Net effect on sustained bidirectional
traffic: null_modem never saw a sustained RTS-deassert, never paused
its TX, and the RX ring overran.

Observed on a 1024-byte bidirectional BIOS-direct echo test before the
fix:
- 276 bytes lost out of 1024
- ~1-in-3 byte loss rate after the first full 256-byte cycle
- Program hung at byte 748 of 1024 (RX blocked)
- MAME instrumentation showed `wr5=ea` (RTS=1) after every data_write

After the fix:
- 4096-byte bidirectional test passes clean (count=4096 mismatch=0)
- Instrumentation shows `wr5=e8` (RTS=0) during sustained RX → sender
  is paused as intended

## Fixes

### `rcbios-in-c/bios.c`

1. Removed WR5/WR1 per-byte rewrites from `list_lpt`,
   `bios_punch_body` SIO-A branch, `serial_conout`.  They had always
   been copies of an older defensive idiom that re-enables TX every
   byte; once the SIO is armed by `readi()` at boot, TX stays armed.
2. `readi()` now arms both SIO-A and SIO-B at boot (WR5 = wr5b+0x8A,
   WR1 = 0x1F) instead of just SIO-A.
3. Moved `readi()` to run **before** the cold-boot banner.  Previously
   banner bytes were lost on SIO-B because TX was not yet enabled and
   interrupts were off.
4. Added symmetric RTS flow control to `isr_sio_b_rx`: deassert at
   `RXTHHI`, drop on full.  `serial_conin` reasserts on empty.
5. Removed `serial_conout`'s 255-iteration timeout fallback (it was a
   workaround for pre-EI banner printing; no longer needed).

### `mame/src/mame/regnecentralen/rc702.cpp`

- `rs232b_defaults`: `FLOW_CONTROL` `0x00` → `0x01`.  Without this,
  even though the BIOS drives RTS-B correctly, null_modem ignored it.

## Integration test

New Makefile targets:

- `make sio-a-echo-test` — 4096 bytes bidirectional on SIO-A via BIOS
  `READER`/`PUNCH` direct (no BDOS).  Uses `tests/bios_echo_big.asm`,
  0xA5 sync handshake.  PASS iff `count=4096 mismatch=0 status=0xAA`.
- `make sio-b-echo-test` — 4096 bytes on SIO-B via BIOS `CONIN`/`LIST`
  (with `IOBYTE=0` so both routes to SIO-B only, bypassing CRT).
- `make sio-echo-test` — runs both.

Test harness:
- `tests/sioa_trace.lua` — MAME autoboot Lua that taps IO 0x08-0x0B
  (non-destructive), types the command at `A>`, dumps screen + result
  block on exit.  Keyboard buffer addresses read from bios.elf via
  `llvm-objdump` to survive BIOS size changes.
- `tests/sioa_feed_and_read.py` — TCP bridge that listens on port
  (4001 SIO-A, 4002 SIO-B), optionally waits for a sync byte from the
  CP/M program, sends the configured bytes, then captures the echoes.
- `tests/run_sioa_rx_test.sh` / `tests/run_siob_echo_test.sh` — shell
  drivers: patch bios.cim into disk image, install `.COM` via cpmcp,
  convert to MFI, launch MAME with the Lua script + socket.

## Open follow-ups

- [ ] RX ring hysteresis: `bios_reader` / `serial_conin` reassert RTS
      only when the ring is fully empty.  `RXTHLO=240` is defined in
      bios.h but unused.  Using a real low-threshold hysteresis would
      shorten the sender-paused interval under sustained load.
      Trade-off: more frequent RTS toggles.  Not urgent now that 4 KB
      passes clean, but worth revisiting if the echo throughput profile
      ever matters.
- [ ] The integration test currently kills MAME on a 30 s wall-clock
      timeout rather than detecting program completion on screen.  The
      status byte at 0x180 tells us pass/fail after the fact, but a
      completion marker-based MAME exit would shave seconds.
- [ ] The `0xA5` sync-byte handshake in the test programs is a
      convenience to avoid "first bytes lost to whatever ran before the
      CONIN loop" race.  The BIOS itself doesn't need it, but any
      future stress test should adopt the same pattern.

## Not touched

- SDLC / sync mode (sessions 18–21): the fixes are in async TX paths
  only; standalone SDLC programs re-initialize the SIO from scratch.
  No retest needed.
- Session-22 CP/NET bring-up hang: the general RTS-clobber bug I fixed
  here *could* have been a contributor (SNIOS does many short PUNCHes),
  but re-running CP/NET end-to-end is its own task.  If it still hangs,
  the present work at least removes one variable.

## Related MAME PR-track state

- `ravn/mame#5` (SIO TX hang) was filed from session 22 findings.  The
  root cause is **partly in the BIOS** (fixed here) and **partly in
  MAME** (rs232b FLOW_CONTROL default — also fixed here).  The MAME
  fork change is staged in `~/git/mame` on branch `master`.
