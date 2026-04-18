# SDLC on Physical Hardware — Test Prep Notes (2026-04-18)

Follow-up to `session18-serial-speed.md`. Session 18 established the plan
(SDLC at 250 kbaud via CTC timer mode, ×1 clock, SIO-B first). This doc
captures what changed once we started preparing for a real-hardware run
instead of MAME validation.

## Decision: skip MAME, go to real RC702

MAME Phase-1 validation is blocked on two things the session-18 plan
glossed over:

- MAME's `null_modem` device is async only. SDLC framing (0x7E flags,
  zero-insertion, CRC) has no path through MAME's standard RS-232
  subsystem without a custom peer device.
- Local `mame/src/mame/regnecentralen/rc702.cpp` has the
  `z80dart`→`z80sio` fix (commit `ea7a5cf8`, 2026-04-18) but the MAME
  binary at `mame/mame` is older (2026-04-17). Needs rebuild before any
  sync-mode programming can even be tested in emulation.

Skipping MAME means the physical RC702 is the first integration point.
Chip-level SDLC validation still needs a minimal contained experiment —
see "Proposed first experiment" below.

## MAME rc702.cpp details worth remembering

- CTC ch0 → SIO-A `txca_w` + `rxca_w` (single wire, both directions)
- CTC ch1 → SIO-A `rxtxcb_w` (single wire, SIO-B combined TxC/RxC)
- CTC trg0/trg1 are driven by `clock_w` at 614 kHz (async baseline path,
  counter mode)
- CTC chip itself is clocked at `8_MHz_XTAL / 2` = 4 MHz → timer-mode
  output = 4 MHz / {16 or 256} / TC. **4 MHz / 16 / 1 = 250 kHz** is
  the session-18 number; **/ 16 / 2 = 125 kHz** is the safer target
  (see FTDI section).

## FT2232 host adapter — actual variant

`lsusb -v` on the existing adapter:

- `bcdDevice 0x0500` — D revision (FT2232H is 0x07xx, FT4232H is 0x08xx)
- `bMaxPacketSize0 = 8` — D/C only; H uses 64
- 4 bulk endpoints × 64 bytes — matches FT2232D layout
- iSerial `FT4SXZNY`, iProduct "USB FAST SERIAL ADAPTER" — generic/clone

**Verdict: FT2232D, not H.** Implications:

- Async bit-bang ceiling ≈ 1 MHz.
- At 250 kbaud that's 4× oversampling — marginal for a software DPLL,
  because drift across a long frame can eat the margin.
- At **125 kbaud** it's 8× — comfortable oversampling, still 33× the
  current 38400 async baseline.
- 62.5 kbaud would be 16× — very safe but only 16× async baseline.
- 64-byte FIFO per channel (H has 4 KB), so sustained 1 MHz capture
  depends on USB bulk-IN scheduling latency. Expect occasional hiccups
  unless the host drains aggressively.

Revised first target: **125 kbaud** rather than 250. If that works end
to end, push to 250. A later FT2232H upgrade moves the ceiling to
614.4 kbaud.

## Hardware facts from RC702-RC703 manual (extracted 2026-04-18)

Extracted from `docs/RC702-RC703_Microcomputer_technical_manual.pdf`
via `pdftotext -layout`. Figure 13 (pp. 23–24) and surrounding text.
Full pinout + MIC-variant details written into
`RC702_HARDWARE_TECHNICAL_REFERENCE.md` — not duplicated here. Key
points for SDLC:

- **J1 / J2 DB-25 carry no clock.** Only pins 1, 2, 3, 4, 5, 7, 8, 20
  are wired — standard DTE async RS-232. Pins 15 (TxC) / 17 (RxC) are
  NC on MIC702/MIC703.
- **Synchronous external-clock support is MIC704/MIC705 only.** On
  those boards, `OUT (1Eh),A` bit 1 sets a flip-flop routing a modem
  clock into SIO channel A. That port does nothing on MIC702/MIC703.
- **Z80-SIO has no DPLL.** So even if we SDLC-frame the bit stream,
  the RC702's receiver cannot clock-recover an incoming bit stream.

### What this means for the direct-over-the-wire plan

Without MIC704/MIC705 or a cable mod picking up clock from elsewhere:

| Direction | Feasibility at 125–250 kbaud sync |
|-----------|------------------------------------|
| RC702 → host (TX) | **Works**: RC702 drives its own TxCB from CTC, host does software DPLL on the RxD samples via FT2232D async bit-bang. NRZI + HDLC zero-insert guarantees transitions for DPLL lock. |
| host → RC702 (RX) | **Does not work**: SIO has no DPLL; it samples incoming RxD using its own CTC clock with no phase alignment. Unreliable at ×1 even over a single frame. |

This is exactly the session-17 finding at 250 kbaud async, and SDLC
does not fix it — SDLC buys flag framing + CRC + unlimited frame
lengths, not clock recovery.

### Three ways forward

1. **Asymmetric SDLC** — fast TX from RC702, async from host. Use
   SDLC one-way for CP/NET responses (where payload volume lives);
   keep host → RC702 at 38400 async for requests. Probably 3–4x
   effective CP/NET throughput, no hardware changes, matches a real
   cable.
2. **External-clock cable mod** — pick up a TxCB / RxCB signal from
   inside the cabinet (header pin or solder to the CTC ZC/TO pin)
   and route to the FT2232 adapter and back to the SIO as RxCB. Lifts
   the no-DPLL constraint. User has said no PCB mods, but an external
   header + ribbon out the back would be acceptable in spirit —
   question worth re-opening.
3. **J8 bus expansion** (session-18 stretch plan). Orthogonal to
   SIO/SDLC entirely; different work track.

Direction for this session: if the user accepts asymmetric SDLC,
start building Phase 1 as RC702-TX / host-RX only. Much simpler first
integration — one DPLL, on the host side, which is the easier place
to put it.

## Code wired up (2026-04-18)

- `siob_sdlc_tx.asm` — 335 B. 125 kbaud SIO-B SDLC TX, NRZI, CRC-CCITT,
  flag idle, flag-on-underrun (auto CRC). 30-byte test payload with
  bit-stuffer stress patterns; 200 ms flag preamble before the frame.
- `cim_to_hex.py` — .cim → Intel HEX at 0x0100 (feeds CP/M PIP+MLOAD).
- `sdlc_receiver.py` — async bit-bang over libftdi1 (ctypes, no
  pyftdi), 1 MHz sample rate → 8×/bit oversampling. Software DPLL via
  run-length quantisation, NRZI decode, HDLC flag+zero-delete framer,
  CRC-CCITT-X.25 verify. Self-test: CRC of "123456789" = 0x906E ✓.
- `siob_sdlc_deploy.sh` — end-to-end automation:
  1. zmac + cim_to_hex
  2. over ttyUSB0: `STAT CON:=CRT:` → `PIP SIOBSDLC.HEX=RDR:` →
     stream HEX → `^Z` → `STAT CON:=TTY:` → `MLOAD SIOBSDLC`
  3. start `sdlc_receiver.py --seconds 10 --interface B` on ttyUSB1
  4. send `SIOBSDLC` over ttyUSB0
  5. print decoded frame
- Makefile target `siob-sdlc`.

### Toolchain deps (all present on this box)

- `bison` — installed (user). zmac built cleanly.
- `libftdi1.so.2` — installed (`libftdi1-2`). ctypes loads it.
- `pyserial` — installed (3.5).

### Prereqs on the RC702 for deploy

- Already at A> prompt, CON:=TTY (serial console).
- Drive A has `STAT.COM`, `PIP.COM`, `MLOAD.COM`.
- RTS/CTS flow control on SIO-A works (same as existing BIOS deploy).
- ttyUSB1 not held by another libftdi/serial process.

### How to run

```
cd rc700-gensmedet/rcbios-in-c
make siob-sdlc
```

### Session progress (2026-04-18, real hardware)

Chain confirmed working end-to-end:
1. **DDT deploy** — `ddt_deploy.py` types bytes into DDT's `S` command
   over SIO-B console, verifies with `D`, `SAVE`s as .COM.
   Replaces the PIP+MLOAD path per user directive (keeps SIO-A free
   and avoids RX ring-buffer contamination).
2. **Z80 TX** — `sioa_sdlc_tx.asm` (now targets SIO-A — session-17
   rule: don't commandeer the console channel).  Runs, prints banner,
   transmits frame, restores async.
3. **FTDI bit-bang receive** — `sdlc_receiver.py` via libftdi1 ctypes.
   Captures samples, writes raw dump for offline analysis.
4. **Decoder** — software DPLL + NRZI + HDLC de-frame + CRC-CCITT.

Empirical findings worth remembering:

- **CTC CLK on the physical PCB530 is NOT 4 MHz as MAME models.**
  First measurements suggested 8 MHz (TC=4 → observed 125 kHz)
  but that was confounded by sample drops at 1 MHz bit-bang.
  Clean capture at 80 kHz shows TC=50 produces ~6.0–6.8 kHz on
  the SIO clock, implying CTC_CLK ≈ 5 MHz (or 4.9152 MHz from
  the 19.6608 MHz video master).  Needs scope verification.
- **MAME's rc702 clock model may be incorrect for this board.**
  `Z80CTC(config, m_ctc1, 8_MHz_XTAL / 2)` → 4 MHz.  PCB530 appears
  to be different.  Worth filing a follow-up to ravn/mame once the
  scope measurement confirms the real rate.
- **FT2232D async bit-bang max throughput is well under 1 MHz in
  practice.**  Requested sample rate 1 MHz, observed effective rate
  ~273 kHz over 10 s captures — FTDI + Python read-loop drops
  samples heavily.  The raw dump shows genuine SDLC structure but
  run-lengths are scrambled beyond DPLL recovery.

### Known bugs / deferred work

- Receiver's effective sample rate << configured.  Tried (b) above —
  removed sleep, 256 KB buffer — improved but didn't close the gap.
  Dominant run length now 16 samples at 62.5 kbaud (bit cell =
  16 µs = 1 MHz sample rate ✓) but ~50% of samples are still
  dropped mid-run, fragmenting the expected {1-cell, 7-cell} flag
  distribution.  Next steps:
  (a) write a small C capture helper (libftdi1 in C, no Python
      overhead in the read loop) — most pragmatic.
  (b) drop the line baud to 31.25 kbaud (CTC TC=16) with 1 MHz
      sampling = 32×/bit, enough margin even with 50% drops.
  (c) long-term: FT2232H adapter eliminates the bottleneck.
- `samples_to_bits` now uses a DPLL-at-bit-center approach with
  3-tap median filter; tested in isolation against raw dumps, logic
  appears sound but needs real clean samples to validate.
- MAME rc702.cpp should get `8_MHz_XTAL / 1` for CTC instead of
  `/ 2`, pending more verification.

### Open questions to resolve on first run

- FTDI bit-bang permission: opening interface B for bit-bang goes
  through libusb. On this box, `dialout` gives access to /dev/ttyUSB*
  but libusb raw access usually needs a udev rule for VID:PID
  0403:6010. If the script fails with "usb_open: -5", add a rule at
  `/etc/udev/rules.d/99-ftdi.rules`:
  `SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", MODE="0666"`
  and `sudo udevadm control --reload && sudo udevadm trigger`.
- Expected output: one "frame 0: NN B CRC OK ..." line with ASCII
  "SDLC-TX-TEST..." visible in the payload.  If we see "CRC BAD",
  the DPLL probably needs tuning (sample rate vs. actual CTC clock
  drift) — try `--baudrate-hint 124900..125100` to adjust.
- If the host gets nothing at all, first debug step is to drop the
  Z80 program back to async 38400 and confirm the FT2232D in
  bit-bang mode sees transitions (same cable, known-good data).

### Board version: PCB530 (2026-04-18)

User's RC702 mainboard silkscreen is **PCB530**. Neither PDF manual
names it directly; both describe PCB527 as the MIC702 reference
design. User's assessment is that PCB530 is a MIC702 revision; I
agree given chip complement and behaviour consistent with MIC702.

(Earlier I wrote that MIC704 adds a distinguishing "MIC LV" PLL
schematic — that was a misread. RC702tech.pdf p.83 contains a
"MIC 702 — PHASE LOCK LOOP — MIC 14" schematic which *is* on the
standard MIC702, but it's the video dot-clock PLL, nothing to do
with serial clock recovery. Scratch that as a distinguishing
feature.)

Treat as MIC702 until silkscreen/schematic evidence says otherwise.
Sync-mode features therefore assumed unavailable; only the
asymmetric SDLC path (fast RC702→host, 38400 async host→RC702) is
viable without cable/board modifications.

## Experiment plan (user decisions 2026-04-18)

- **Skip MAME** — go to real RC702.
- **Skip loopback** — go direct: RC702 SIO-B → serial cable →
  FT2232D → Linux host.

Consequence: clock recovery must be solved before any code lands.
There is no intermediate chip-level validation step to fall back on.
If the first end-to-end test fails we'll need to unwind both the Z80
programming and the host DPLL at once, which is painful.

Chosen first target: **125 kbaud**, to give the FT2232D's 1 MHz async
bit-bang ceiling an 8× oversampling margin for the software DPLL.
250 kbaud is a stretch goal once 125 works.

## Chip identity (physical, confirmed in session 18)

SIO: Z8442AB1 = Z80A-SIO/2. Supports SDLC. Bonding option 2 means
SYNCB pin is replaced by DTRB — SYNCA (channel A) is still available
if we ever want channel A externally synced.

## TODO before any code lands

- [ ] Read RC702 schematic; document DB-25 pin-out for SIO-B.
- [ ] Decide clock strategy: software DPLL (async bit-bang) vs.
      external clock wire.
- [ ] Write loopback Z80 program (see "Proposed first experiment").
- [ ] Once loopback passes, design host-side receiver (Python +
      libftdi1 / pyftdi async bit-bang + DPLL + HDLC framer).
