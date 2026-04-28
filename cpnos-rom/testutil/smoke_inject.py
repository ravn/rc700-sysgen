#!/usr/bin/env python3
"""Prompt-aware SIO-B injector for the cpnet-smoke test.

Listens as the server end of MAME's `-bitb2 socket.127.0.0.1:<PORT>`.
When the expected prompt pattern appears at the tail of the slave's
SIO-B TX stream, the next command in the sequence is pushed back on
the socket.  Required because sending all commands at once overruns
the Z80 SIO-B RX buffer while CCP is busy executing the current one
(network round-trips to MP/M take seconds).

Every received byte is appended to the log file so the make target
can grep the final result.

Usage:
    smoke_inject.py <port> [--log PATH] [--timeout SEC]
"""
import argparse
import os
import socket
import sys
import time

STEPS = [
    # (expected-prompt-tail, bytes-to-send-once-matched)
    # Trimmed to just the SUMTEST steps for the bench — assemble, link,
    # run.  Removes the TINY warm-up + DIR steps so the timed section
    # is purely the assembler+linker+runtime work over CP/NET.
    (b'A>', b'm80 sumtest,=sumtest.asm\r'),
    (b'A>', b'l80 sumtest,sumtest/n/e\r'),
    (b'A>', b'sumtest\r'),
]

FINISH_MARKER = b'CPNET OK '


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('port', type=int)
    ap.add_argument('--log', default='/tmp/cpnos_siob.raw')
    ap.add_argument('--timeout', type=float, default=300.0)
    args = ap.parse_args()

    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(('127.0.0.1', args.port))
    srv.listen(1)
    print(f'smoke_inject listening on :{args.port}', flush=True)

    srv.settimeout(args.timeout)
    conn, peer = srv.accept()
    print(f'connected from {peer}', flush=True)
    conn.settimeout(0.5)

    log = open(args.log, 'wb', buffering=0)
    buf = bytearray()
    step_idx = 0
    # After sending a command, we briefly wait for its echo to start
    # before looking for the NEXT prompt — otherwise we'd match the
    # A> that triggered the first send again.
    cooldown_until = 0.0
    deadline = time.monotonic() + args.timeout
    saw_marker = False
    last_data_at = time.monotonic()
    next_nudge_at = time.monotonic() + 10.0

    bench_start = [None]   # set when first step fires
    bench_end = [None]     # set when CPNET OK detected

    def maybe_fire_step():
        nonlocal step_idx, cooldown_until
        if step_idx >= len(STEPS): return False
        if time.monotonic() < cooldown_until: return False
        prompt, cmd = STEPS[step_idx]
        if buf[-len(prompt):] != prompt: return False
        if bench_start[0] is None:
            bench_start[0] = time.monotonic()
            print(f'[bench_start] t={bench_start[0]:.3f}s', flush=True)
        print(f'[step {step_idx}] prompt {prompt!r} matched; '
              f'sending {cmd!r} (t+{time.monotonic()-bench_start[0]:.3f}s)',
              flush=True)
        for b in cmd:
            conn.sendall(bytes([b]))
            time.sleep(0.02)
        step_idx += 1
        cooldown_until = time.monotonic() + 0.5
        buf.clear()
        return True

    while time.monotonic() < deadline:
        # No nudge mechanism: with maybe_fire_step() now also called on
        # recv-timeout, the harness reliably sees a quiet A> within
        # ~0.5 s of CCP printing it.  Nudging on idle was injecting
        # phantom CRs DURING m80/l80 work (when CCP is busy and silent
        # by design), causing extra A> echoes after the program ends —
        # which is exactly the "I had to type enter" behavior we're
        # eliminating.  If a real byte got lost mid-command, the
        # harness will time out at the deadline; that's a clean fail
        # signal for the benchmark.

        try:
            data = conn.recv(256)
        except socket.timeout:
            # No new bytes — but check the buffer anyway in case the
            # slave just printed a quiet A> and is waiting for input.
            maybe_fire_step()
            continue
        if not data:
            print('peer closed', flush=True)
            break
        last_data_at = time.monotonic()
        log.write(data)
        buf.extend(data)
        if len(buf) > 4096:
            del buf[:-4096]

        if step_idx >= len(STEPS) and FINISH_MARKER in buf and not saw_marker:
            saw_marker = True
            bench_end[0] = time.monotonic()
            elapsed = bench_end[0] - bench_start[0] if bench_start[0] else -1
            print(f'[marker] CPNET OK found (bench={elapsed:.3f}s)', flush=True)
            deadline = min(deadline, time.monotonic() + 3.0)
            continue

        # Bytes arrived: check if the buf tail now ends with the
        # expected prompt and fire the next step if so.
        maybe_fire_step()

    conn.close()
    log.close()
    print(f'done (steps sent: {step_idx}/{len(STEPS)}, '
          f'marker seen: {saw_marker})', flush=True)
    return 0 if saw_marker else 2


if __name__ == '__main__':
    sys.exit(main())
