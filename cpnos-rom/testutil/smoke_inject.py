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
    # MP/M's CP/NET server only exposes its drive A: to the slave, so
    # everything runs out of slave A: (same physical disk as M80/L80).
    # M80 syntax: OUTFILE,LISTFILE=SRCFILE.EXT ; '=' separates outputs
    # from inputs, comma separates output files, '/N/E' tells L80 no-init/
    # exit-on-link-done so the final COM ends up on disk and we return
    # to the A> prompt.
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

    while time.monotonic() < deadline:
        try:
            data = conn.recv(256)
        except socket.timeout:
            continue
        if not data:
            print('peer closed', flush=True)
            break
        log.write(data)
        buf.extend(data)
        if len(buf) > 4096:
            del buf[:-4096]

        if FINISH_MARKER in buf and not saw_marker:
            saw_marker = True
            print('[marker] CPNET OK found', flush=True)
            # Keep a small tail so we capture the 4-digit result.
            deadline = min(deadline, time.monotonic() + 3.0)
            continue

        if step_idx < len(STEPS) and time.monotonic() >= cooldown_until:
            prompt, cmd = STEPS[step_idx]
            # Match the prompt at the tail of the buffer so we only
            # fire when the slave is idle waiting for input, not on
            # an A> emitted earlier as part of a banner.
            if buf[-len(prompt):] == prompt:
                print(f'[step {step_idx}] prompt {prompt!r} matched; '
                      f'sending {cmd!r}', flush=True)
                # Send one char at a time with a small inter-char
                # delay so CCP's per-char echo loop (which does a
                # SIO-B CONOUT + network bookkeeping per byte) has
                # time to drain the SIO-B RX register before the
                # next bit hits.  At 38400 baud each byte takes
                # ~260 µs over the wire; CCP's echo path is slower
                # than that once BDOS fn 10 round-trips through
                # our BIOS JT, so without pacing we lose bytes.
                for b in cmd:
                    conn.sendall(bytes([b]))
                    time.sleep(0.02)     # 20 ms per char
                step_idx += 1
                cooldown_until = time.monotonic() + 0.5
                # Drop the matched prompt from the buffer so we don't
                # re-match the SAME A>.
                buf.clear()

    conn.close()
    log.close()
    print(f'done (steps sent: {step_idx}/{len(STEPS)}, '
          f'marker seen: {saw_marker})', flush=True)
    return 0 if saw_marker else 2


if __name__ == '__main__':
    sys.exit(main())
