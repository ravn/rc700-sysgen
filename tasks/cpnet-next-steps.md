# CP/NET Next Steps — Analysis and Plan

Date: 2026-04-15

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

## Issues and Risks

### Issue 1: BIOS/SNIOS Compatibility (HIGH)

The SNIOS calls BIOS READER/PUNCH/READS for serial I/O.  With the SIO
role swap, READER/PUNCH now route through SIO-A (the data port), which
is correct for CP/NET.  But:

- The IOBYTE routing may redirect READER/PUNCH to unexpected devices
  depending on the IOBYTE value at CP/NET load time.
- SNIOS was tested pre-swap; verify it still works with the new BIOS.

### Issue 2: Serial Data Loss During Disk I/O (HIGH)

TEST_RESULTS.md reported 74% data loss on round-trip disk tests.  Root
cause: DI during FDC operations (seek/read/write) causes SIO FIFO
overflow at 38,400 baud.  The SIO's 3-byte hardware FIFO overflows in
~0.8 ms; FDC DI periods can extend beyond that when combined with the
display ISR.

**For physical hardware, this is the main performance risk.**  Options:
- RTS flow control (designed but not implemented)
- Lower baud rate during disk operations (wastes bandwidth)
- Server-side pacing (insert delays between packets during disk writes)

### Issue 3: MAME → Real Hardware Gap (MEDIUM)

CP/NET works in MAME with the null_modem TCP bridge.  For real hardware:
- Need physical serial cable (already documented in docs/)
- Server must speak serial, not TCP (server.py uses TCP socket)
- Baud rate must match exactly (CTC divisor, SIO clock mode)
- RS-232 level shifting is handled by the RC702's built-in interface

### Issue 4: Parallel Port Hardware Uncertainty (MEDIUM)

Session 16 found that PIO Mode 2 (bidirectional) may not work on stock
RC702 hardware — ARDY appears unwired.  This blocks the parallel port
as a high-speed alternative to serial.  Hardware verification with a
meter or probe cable is needed before investing in parallel SNIOS code.

### Issue 5: CP/NOS PROM Sizing (LOW for now)

CP/NOS bootstrap fits in 2 KB PROM1.  The 4 KB option (2732 with A11
solder bridge) gives comfortable headroom.  Real hardware has 2 KB
PROMs; MAME can emulate 4 KB.  The bootstrap only needs serial init,
protocol framing, and a receive loop — the full CP/M OS loads over
the network.

## Plan

### Phase A: CP/NET on Latest BIOS in MAME

1. Rebuild SNIOS.SPR with current tool versions
2. Boot CP/M in MAME with latest BIOS
3. Load CP/NET (CPNETLDR.COM), start server.py
4. Run the existing test suite (autotest.lua + run_test.sh)
5. Fix any breakage from the SIO swap / IOBYTE changes
6. Verify: DIR N:, TYPE N:filename, PIP N:=A:file, PIP A:=N:file

### Phase B: RTS Flow Control for Disk Safety

1. Implement RTS drop before DI in FDC code paths
2. Implement RTS reassert after EI
3. Server-side: respect CTS before sending
4. Test: round-trip file copy via CP/NET with disk writes
5. Verify zero data loss at 38,400 baud

### Phase C: Physical Hardware Serial

1. Connect RC702 to host via RS-232 cable
2. Adapt server.py for real serial port (pyserial, not TCP)
3. Test at 38,400 baud — verify RTS/CTS handshaking works
4. Run file transfer tests on real hardware
5. Measure actual throughput, identify any timing issues

### Phase D: Parallel Port Investigation

1. Get DB-25 cable (see todo.md for supplier)
2. Write pioprobe.com + lptprobe.py (see todo.md investigation plan)
3. Determine if ARDY is wired, which Mode works
4. If viable: implement parallel SNIOS, compare throughput to serial

### Phase E: CP/NOS Diskless Client in PROM

1. Implement minimal PROM1 bootstrap (serial init, DRI protocol,
   receive-and-load loop, display status)
2. Target: 2 KB for real hardware, develop with 4 KB in MAME
3. Extend server.py with netboot protocol (push CCP+NDOS+SNIOS)
4. Test in MAME: boot from PROM1 with no floppy
5. Test on real hardware: burn EPROM, boot diskless

## Key Technical Risks

1. **Serial throughput with disk I/O** — the 74% loss rate must be
   fixed (RTS flow control) before real hardware is usable
2. **Parallel port viability** — unknown until hardware is probed
3. **2 KB PROM fit** — tight but feasible per CPNOS_SIZING.md;
   every byte counts for the bootstrap
4. **MP/M server** — z80pack integration is the most complex path;
   server.py may be sufficient for single-user operation
