# CP/NET Next Steps — Analysis and Plan

Date: 2026-04-15 (updated end of session 18)

> **Update 2026-04-25.** The fast-transport design is now pinned in
> [`../docs/cpnet_fast_link.md`](../docs/cpnet_fast_link.md) (Option
> P — PIO-B half-duplex via J3, no PCB mods, no level shifter). The
> 38400-baud serial CP/NET path described below remains the *fallback*
> transport and the validated default; Option P is opt-in once the
> bring-up phase begins (deferred until Pi 4B host hardware is on
> hand). The "Parallel host link" / Mode 2 references in the original
> text below should be read in light of that supersession — see the
> banners on `cpnet/PARALLEL_TRANSPORT.md` and
> `cpnet/SPLIT_CHANNEL_TRANSPORT.md`.

## Current State

CP/NET is working in MAME with the DRI binary protocol (SNIOS + server.py).
204 KB transfer validated at 38,400 baud with zero packet loss.  However,
the BIOS has changed significantly since CP/NET was last tested:

- SIO roles swapped (SIO-B = console, SIO-A = data)
- Ring buffer renamed (rxbuf_a, rxhead_a, etc.)
- IOBYTE routing fully implemented
- Warm-boot variable grouping changed

**CP/NET has NOT been tested with the current BIOS.**  This is the first
thing to fix.

## Architecture Decision

CP/NET communicates on **SIO-A** (the data port).  Console stays on
**SIO-B**.  The SNIOS calls BIOS READER/PUNCH/READS which route to SIO-A
via the IOBYTE RDR/PUN fields (default: PTR/PTP = SIO-A).

The MAME RC702 connects to z80pack MP/M II over TCP as the test server.
z80pack is already forked at `ravn/z80pack` with NETWRKIF bug fixes
applied.  The `run_test.sh --no-server --inject` workflow connects MAME
to z80pack MP/M on TCP port 4002.

For physical hardware, the same SNIOS works — SIO-A is the RS-232 data
port with ring buffer and RTS flow control.

## Infrastructure

| Component | Location | Status |
|-----------|----------|--------|
| SNIOS.SPR | `cpnet/snios.asm` + `build_snios.py` | Working (DRI binary) |
| server.py | `cpnet/server.py` | Working (TCP, BDOS emulation) |
| z80pack MP/M | `z80pack/` submodule (ravn fork) | Forked, NETWRKIF fixed |
| BIOS (C) | `rcbios-in-c/` | Latest: SIO swap, IOBYTE, ring buffers |
| Test suite | `cpnet/run_test.sh` + `autotest.lua` | Needs re-validation |
| DRI protocol doc | `cpnet/DRI_PROTOCOL.md` | Complete |
| z80pack setup | `cpnet/Z80PACK_MPMNET.md` | Complete |
| MP/M bug analysis | `cpnet/MPMNET_ANALYSIS.md` | 3 bugs documented+fixed |

## Issues and Risks

### Issue 1: BIOS/SNIOS Compatibility (HIGH)

The SNIOS calls BIOS READER/PUNCH/READS for serial I/O.  With the SIO
role swap, READER/PUNCH now route through SIO-A (the data port), which
is correct for CP/NET.  But:

- The IOBYTE routing may redirect READER/PUNCH to unexpected devices
  depending on the IOBYTE value at CP/NET load time.
- SNIOS was tested pre-swap; verify it still works with the new BIOS.
- SNIOS hardcodes BIOS entry point addresses (DA12h, DA15h, DA4Dh) —
  verify these haven't shifted after BIOS code changes.

### Issue 2: Serial Data Loss During Disk I/O (HIGH)

TEST_RESULTS.md reported 74% data loss on round-trip disk tests.  Root
cause: DI during FDC operations (seek/read/write) causes SIO FIFO
overflow at 38,400 baud.  The SIO's 3-byte hardware FIFO overflows in
~0.8 ms; FDC DI periods can extend beyond that when combined with the
display ISR.

**For physical hardware, this is the main performance risk.**  Options:
- RTS flow control (designed but not implemented in BIOS FDC paths)
- Server-side pacing (insert delays between packets during disk writes)
- The DMA flip-flop atomicity fix (DI/EI around DMA programming) from
  the clean room analysis may interact — verify DI duration is acceptable.

### Issue 3: MAME to Real Hardware Gap (MEDIUM)

CP/NET works in MAME with the null_modem TCP bridge.  For real hardware:
- Need physical serial cable (already documented in docs/)
- Server must speak serial, not TCP (server.py needs pyserial mode,
  or use z80pack with real serial port)
- Baud rate must match exactly (CTC divisor 1, SIO x16 = 38400)
- RS-232 level shifting handled by RC702's built-in MAX232-equivalent

### Issue 4: Parallel Port Hardware Uncertainty (MEDIUM)

Session 16 found that PIO Mode 2 (bidirectional) may not work on stock
RC702 hardware — ARDY appears unwired.  Blocked on DB-25 cable for
hardware probing.

### Issue 5: CP/NOS PROM Sizing (LOW for now)

Bootstrap fits in 2 KB PROM1.  4 KB option (A11 solder bridge) gives
headroom.  Develop with 4 KB in MAME.  Real hardware: 2 KB PROMs (2716).

## Plan

### Phase A: CP/NET on Latest BIOS in MAME (against z80pack MP/M)

1. Build z80pack cpmsim on macOS (check `z80pack/cpmsim/` submodule)
2. Start z80pack MP/M II with NETWRKIF on TCP 4002
3. Rebuild SNIOS.SPR — verify BIOS entry point addresses still match
4. Boot MAME with latest BIOS, connect to z80pack via null_modem
5. CPNETLDR, LOGIN PASSWORD, NETWORK H:=B:
6. Test: DIR H:, TYPE H:file, PIP A:=H:file, PIP H:=A:file
7. Fix any breakage from SIO swap / IOBYTE / address changes
8. Run full test suite (autotest.lua + run_test.sh --no-server --inject)

### Phase B: RTS Flow Control for Disk Safety

1. Implement RTS drop before DI in FDC code paths (flp_dma_setup,
   fdc_general_cmd, fdc_seek, fdc_recalibrate)
2. Implement RTS reassert after EI
3. Server-side: respect CTS before sending (z80pack TCP is transparent;
   real serial needs CTS checking)
4. Test: round-trip file copy via CP/NET with disk writes
5. Verify zero data loss at 38,400 baud

### Phase C: Physical Hardware Serial

1. Connect RC702 to host via RS-232 cable
2. Adapt server.py for real serial (pyserial) or use z80pack with
   serial port instead of TCP
3. Test at 38,400 baud — verify RTS/CTS handshaking works
4. Run file transfer tests on real hardware
5. Measure actual throughput, identify any timing issues

### Phase D: Parallel Port Investigation

1. Get DB-25 cable (elextra.dk H11461/H11463, or Arduino Micro)
2. Write pioprobe.com + lptprobe.py (investigation plan in todo.md)
3. Determine if ARDY is wired, which PIO Mode works
4. If viable: implement parallel SNIOS, compare throughput to serial

### Phase E: CP/NOS Diskless Client in PROM

1. Implement minimal PROM1 bootstrap: SIO-A init, DRI protocol,
   receive-and-load loop, display status messages
2. Target: 2 KB for real hardware, develop with 4 KB in MAME
3. Extend server.py (or z80pack) with netboot protocol
   (push CCP+NDOS+SNIOS to client)
4. Test in MAME: boot from PROM1 with no floppy
5. Test on real hardware: burn 2716 EPROM, boot diskless

## Key Technical Risks

1. **BIOS entry point addresses** — SNIOS hardcodes DA12h/DA15h/DA4Dh;
   if BIOS code size changed, these are wrong and must be updated
2. **Serial throughput with disk I/O** — 74% loss rate must be fixed
   (RTS flow control) before real hardware is usable
3. **Parallel port viability** — unknown until hardware is probed
4. **2 KB PROM fit** — tight but feasible per CPNOS_SIZING.md
5. **z80pack build on macOS** — TCPASYNC must be disabled (macOS SIGIO
   unreliable), see MPMNET_ANALYSIS.md
