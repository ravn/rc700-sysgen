#!/usr/bin/env python3
"""CP/NET 1.2 server over MAME cpnet_bridge (PIO-B parallel link).

Talks to MAME's cpnet_bridge slot card on TCP :4003.  Reads CP/NET
SCBs raw (no SOH/ENQ/ACK envelope — PIO Mode 0/1 hardware handshake
provides per-byte delivery), dispatches via netboot_server's
existing handler, sends responses back as raw SCBs.

Wire shape (slave -> master, repeated):
    [stale-prefix-byte]?      one chip-emulation artifact byte that
                              Z80-PIO Mode 1 -> Mode 0 transitions
                              emit (m_output stale latch); see
                              ravn/mame#7 + cpnos-rom/transport_pio.c
    FMT DID SID FNC SIZ       5-byte header, FMT=0x00 (request)
    payload[SIZ+1]            DRI SIZ-minus-1 convention
    CKS                       sum-to-zero (two's complement)

Detect/strip the stale prefix by structure: the slave's SID is
known (RC702_SLAVEID=0x01), DID is 0x00 (master), FMT is 0x00
(request).  If SID lands at offset 3 instead of 2, a prefix is
present.

Master -> slave responses go without prefix (Mode 0 -> Mode 1
transitions in MAME don't fire out_pb_callback).

Custom probe FNC (0xC0): mirror as PONG.  Other FNCs deferred to
netboot_server.dispatch_sndmsg so the full netboot sequence works
the same way the SIO server does (LOGIN, OPEN A:CPNOS.IMG,
READ-SEQ loop, CLOSE).

Usage:
    python3 cpnet_pio_server.py [BRIDGE_PORT]   (default 4003)
"""

import os
import socket
import sys
import time
from pathlib import Path

# Line-buffer stdout so the harness can tail the spawned server's
# log live.  Default in Python 3 is fully buffered when stdout is
# redirected to a file (which the harness does); -u helps but
# `print(..., flush=True)` per call is fragile.  reconfigure once.
sys.stdout.reconfigure(line_buffering=True)
sys.stderr.reconfigure(line_buffering=True)

_HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, _HERE)
import netboot_server   # type: ignore  # noqa: E402

# Silence netboot_server's verbose dispatch prints in PIO mode — they
# add ~25 ms wall-time per frame round-trip, which translates to
# ~125 ms of emulated Z80 busy-polling at MAME -nothrottle (~5× speed).
# Re-enable with CPNET_PIO_VERBOSE=1.
if not os.environ.get('CPNET_PIO_VERBOSE'):
    netboot_server.print = lambda *a, **kw: None

DEFAULT_PORT  = 4003
SLAVE_SID     = int(os.environ.get('CPNOS_SLAVEID', '0x01'), 0)
MASTER_DID    = 0x00
PING_FNC      = 0xC0
PING_BYTE     = ord('P')
PONG_BYTE     = ord('O')


def _recv_exact(sock, n):
    buf = bytearray()
    while len(buf) < n:
        chunk = sock.recv(n - len(buf))
        if not chunk:
            raise EOFError(f"client closed waiting for {n - len(buf)} more bytes")
        buf.extend(chunk)
    return bytes(buf)


def recv_scb(sock):
    """Receive one SCB.  Returns (hdr, payload, cks_byte).

    Reads 6 bytes initially; the 6th byte is either part of the
    header (after stripping the stale prefix) or the first payload
    byte (no prefix).  Distinguishes by SID position: clean header
    has SID at index 2, prefixed header has SID at index 3.
    """
    raw = _recv_exact(sock, 6)
    if raw[2] == SLAVE_SID:
        hdr = raw[0:5]
        seed = raw[5:6]                       # 1 byte already past header
    elif raw[3] == SLAVE_SID:
        hdr = raw[1:6]                        # stale prefix at raw[0]
        seed = b''
    else:
        raise ValueError(f"unrecognized SCB header structure: {raw.hex()} "
                         f"(expected SID={SLAVE_SID:#04x} at offset 2 or 3)")

    siz = hdr[4]
    n_payload = siz + 1                       # DRI: SIZ=0 means 1 byte
    n_remaining = n_payload + 1 - len(seed)   # +1 for trailing CKS
    body = seed + (_recv_exact(sock, n_remaining) if n_remaining > 0 else b'')
    payload = body[0:n_payload]
    cks = body[n_payload]

    s = (sum(hdr) + sum(payload) + cks) & 0xFF
    if s != 0:
        raise ValueError(f"SCB CKS bad: hdr+payload+cks sum={s:#04x}")

    if os.environ.get('CPNET_PIO_VERBOSE'):
        print(f"<- SCB FMT={hdr[0]:02x} DID={hdr[1]:02x} SID={hdr[2]:02x} "
              f"FNC={hdr[3]:02x} SIZ={hdr[4]} DAT[{n_payload}]={payload.hex()}")
    return hdr, payload, cks


def send_scb(sock, fmt, did, sid, fnc, payload):
    """Send a complete SCB to the slave."""
    if not payload:
        payload = b'\x00'                     # DRI: minimum 1-byte payload
    siz = len(payload) - 1
    hdr = bytes([fmt, did, sid, fnc, siz])
    body = hdr + payload
    cks = (-sum(body)) & 0xFF
    frame = body + bytes([cks])
    sock.sendall(frame)
    if os.environ.get('CPNET_PIO_VERBOSE'):
        print(f"-> SCB FMT={fmt:02x} DID={did:02x} SID={sid:02x} "
              f"FNC={fnc:02x} SIZ={siz} DAT[{len(payload)}]={payload.hex()} "
              f"CKS={cks:02x}")


def handle_ping(hdr, payload):
    """Mirror PING -> PONG: swap DID/SID, replace 'P' with 'O'."""
    if not payload or payload[0] != PING_BYTE:
        raise ValueError(f"PING payload should start with 0x{PING_BYTE:02x} "
                         f"('P'); got {payload.hex()}")
    return bytes([PONG_BYTE])


def handle(sock):
    print(f"connected to bridge {sock.getpeername()}")
    n_frames = 0
    total_recv_ms = 0.0
    total_dispatch_ms = 0.0
    total_send_ms = 0.0
    while True:
        t_pre_recv = time.monotonic()
        hdr, payload, cks = recv_scb(sock)
        t_post_recv = time.monotonic()
        fnc = hdr[3]
        if fnc == PING_FNC:
            reply_payload = handle_ping(hdr, payload)
            reply_fnc = PING_FNC
        else:
            reply_payload = netboot_server.dispatch_sndmsg(hdr, payload)
            if reply_payload is None:
                print(f"  [no reply for FNC={fnc:02x}; client should retry]")
                continue
            reply_fnc = fnc
        t_post_dispatch = time.monotonic()
        send_scb(sock,
                 fmt=0x01,
                 did=hdr[2],                  # was SID
                 sid=hdr[1],                  # was DID
                 fnc=reply_fnc,
                 payload=reply_payload)
        t_post_send = time.monotonic()
        recv_ms     = (t_post_recv - t_pre_recv) * 1000.0
        dispatch_ms = (t_post_dispatch - t_post_recv) * 1000.0
        send_ms     = (t_post_send - t_post_dispatch) * 1000.0
        n_frames += 1
        total_recv_ms     += recv_ms
        total_dispatch_ms += dispatch_ms
        total_send_ms     += send_ms
        print(f"  T fnc={fnc:02x}  recv={recv_ms:6.2f}ms "
              f"dispatch={dispatch_ms:6.2f}ms send={send_ms:6.2f}ms "
              f"total={recv_ms+dispatch_ms+send_ms:6.2f}ms",
              flush=True)
        if n_frames % 10 == 0 or fnc in (16, 0xC0):  # CLOSE or PING
            print(f"  T cumulative ({n_frames} frames): "
                  f"recv={total_recv_ms:.1f} ms, "
                  f"dispatch={total_dispatch_ms:.1f} ms, "
                  f"send={total_send_ms:.1f} ms, "
                  f"sum={total_recv_ms+total_dispatch_ms+total_send_ms:.1f} ms",
                  flush=True)


def run(port):
    """Connect (as TCP CLIENT) to MAME's bridge listener and serve."""
    print(f"cpnet_pio_server: connecting to 127.0.0.1:{port}")
    # MAME may not have bound the listener yet — retry briefly.
    end = time.monotonic() + 30.0
    sock = None
    while time.monotonic() < end:
        try:
            sock = socket.create_connection(("127.0.0.1", port), timeout=2.0)
            break
        except OSError:
            time.sleep(0.2)
    if sock is None:
        sys.exit(f"cpnet_pio_server: could not connect to :{port}")
    sock.settimeout(60.0)
    try:
        handle(sock)
    except (EOFError, socket.timeout) as e:
        print(f"session ended: {type(e).__name__}: {e}")
    finally:
        sock.close()


if __name__ == "__main__":
    p = int(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_PORT
    run(p)
