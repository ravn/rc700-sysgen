#!/usr/bin/env python3
"""SIO-B test harness: accepts MAME's bitb TCP client, logs every byte
received, and injects keystrokes when a trigger pattern appears.

MAME invocation:
    -rs232b null_modem -bitb2 "socket.127.0.0.1:<PORT>"

This script listens on <PORT> and MAME connects as client. Received
bytes stream to /tmp/cpnos_siob.raw. An optional --trigger=PATTERN
arms a one-shot: when PATTERN appears in the received stream, the
script sends --inject=BYTES and then stays connected (logging
continued output).

PATTERN and BYTES accept Python-style escapes: \\r \\n \\x03 etc.

Script exits cleanly on SIGTERM / EOF / after a --timeout.
"""
import argparse, os, select, socket, sys, time

HERE = os.path.dirname(os.path.abspath(__file__))
LOG_PATH = '/tmp/cpnos_siob.raw'


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('port', type=int)
    ap.add_argument('--trigger', default='',
                    help='ascii substring to watch for; triggers --inject')
    ap.add_argument('--inject', default='',
                    help='bytes to send once --trigger matches (\\x03 = ^C)')
    ap.add_argument('--timeout', type=float, default=90.0)
    ap.add_argument('--log', default=LOG_PATH)
    args = ap.parse_args()

    trigger = args.trigger.encode().decode('unicode_escape').encode()
    inject  = args.inject.encode().decode('unicode_escape').encode()

    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(('127.0.0.1', args.port))
    srv.listen(1)
    print(f'sio_b_driver listening on :{args.port} '
          f'trigger={trigger!r} inject={inject!r}', flush=True)

    srv.settimeout(args.timeout)
    try:
        conn, peer = srv.accept()
    except socket.timeout:
        print('no MAME connection within timeout', flush=True)
        return 2
    print(f'connected from {peer}', flush=True)
    conn.settimeout(0.5)

    log = open(args.log, 'wb', buffering=0)
    buf = bytearray()
    armed = bool(trigger)
    deadline = time.monotonic() + args.timeout

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
        # Trim buf to a window big enough for trigger matching.
        if len(buf) > 4096:
            del buf[:-4096]
        if armed and trigger in buf:
            print(f'trigger matched -> sending {inject!r}', flush=True)
            conn.sendall(inject)
            armed = False
            # Keep the connection alive briefly after injection so
            # we still capture the client's response.
            deadline = min(deadline, time.monotonic() + 20.0)

    conn.close()
    log.close()
    return 0


if __name__ == '__main__':
    sys.exit(main())
