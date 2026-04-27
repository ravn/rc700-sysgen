#!/usr/bin/env python3
"""CP/NET 1.2 server over MAME cpnet_bridge (PIO-B parallel link).

Two operating modes:

1. **Self-contained** (default): dispatches CP/NET frames directly via
   netboot_server's handler.  Useful when no real CP/NET server is
   available and you want a quick Python responder for cpnos
   bring-up.

2. **Upstream proxy** (`--upstream HOST:PORT`): forwards each frame to
   a real CP/NET server (e.g. z80pack mpm-net2 SERVER.RSP listening
   on :4002) wrapped in the standard SIO ENQ/ACK/SOH/STX/ETX/EOT
   envelope.  Z80 stays on raw-PIO speed (no envelope on its side);
   the host pays the envelope cost.  Used by harness mode
   `pio-mpm-netboot`.

Wire shape on the PIO (downstream) side, slave -> master:
    [stale-prefix-byte]?      one chip-emulation artifact byte that
                              Z80-PIO Mode 1 -> Mode 0 transitions
                              emit (m_output stale latch); see
                              ravn/mame#7 + cpnos-rom/transport_pio.c
    FMT DID SID FNC SIZ       5-byte header, FMT=0x00 (request)
    payload[SIZ+1]            DRI SIZ-minus-1 convention
    CKS                       sum-to-zero (two's complement)

Stale-prefix detection by structure: the slave's SID is known
(RC702_SLAVEID=0x01), DID is 0x00 (master), FMT is 0x00 (request).
If SID lands at offset 3 instead of 2, a prefix is present.

Master -> slave responses go without prefix (Mode 0 -> Mode 1
transitions in MAME don't fire out_pb_callback).

Custom probe FNC (0xC0) is always handled locally — mpm-net2 doesn't
know it.  Reply is a PONG with mirrored header.

Usage:
    python3 cpnet_pio_server.py [BRIDGE_PORT] [--upstream HOST:PORT]
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

# DRI SIO-envelope constants (used in --upstream mode; mirror the
# Z80-side snios.s wire protocol).
SOH, STX, ETX, EOT, ENQ, ACK, NAK = 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x15


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


# ---- Upstream SIO-envelope client (talks to mpm-net2's SERVER.RSP) ---

def _recv_byte_upstream(sock):
    b = sock.recv(1)
    if not b:
        raise EOFError("upstream closed during envelope exchange")
    return b[0]


def upstream_send(sock, hdr, payload):
    """Send one SCB to upstream (master) per DRI SIO envelope.

    Sequence (slave-side; we play the slave to mpm-net2):
      -> ENQ
      <- ACK
      -> SOH + 5 hdr + HCS         (HCS makes SOH+hdr+HCS sum-to-zero)
      <- ACK
      -> STX + payload + ETX + CKS + EOT
      <- ACK
    """
    # ENQ
    sock.sendall(bytes([ENQ]))
    a = _recv_byte_upstream(sock)
    if a != ACK:
        raise IOError(f"upstream did not ACK ENQ (got 0x{a:02x})")
    # SOH + hdr + HCS
    hcs = (-(SOH + sum(hdr))) & 0xFF
    sock.sendall(bytes([SOH]) + bytes(hdr) + bytes([hcs]))
    a = _recv_byte_upstream(sock)
    if a != ACK:
        raise IOError(f"upstream did not ACK header (got 0x{a:02x})")
    # STX + data + ETX + CKS + EOT (payload is already SIZ+1 bytes)
    cks = (-(STX + sum(payload) + ETX)) & 0xFF
    sock.sendall(bytes([STX]) + bytes(payload) + bytes([ETX, cks, EOT]))
    a = _recv_byte_upstream(sock)
    if a != ACK:
        raise IOError(f"upstream did not ACK data (got 0x{a:02x})")


def upstream_recv(sock):
    """Receive one SCB from upstream (master) per DRI SIO envelope.

    Returns (hdr, payload) — payload is SIZ+1 bytes per DRI.
    """
    # Wait for ENQ (skip stray bytes)
    while True:
        b = _recv_byte_upstream(sock)
        if (b & 0x7F) == ENQ:
            break
    sock.sendall(bytes([ACK]))
    # SOH + 5 hdr + HCS
    soh = _recv_byte_upstream(sock)
    if (soh & 0x7F) != SOH:
        raise IOError(f"upstream sent 0x{soh:02x}, expected SOH")
    hdr = bytes(_recv_byte_upstream(sock) for _ in range(5))
    hcs = _recv_byte_upstream(sock)
    s = (SOH + sum(hdr) + hcs) & 0xFF
    if s != 0:
        raise IOError(f"upstream HCS bad: sum={s:#04x}")
    sock.sendall(bytes([ACK]))
    # STX + data + ETX + CKS + EOT
    stx = _recv_byte_upstream(sock)
    if (stx & 0x7F) != STX:
        raise IOError(f"upstream sent 0x{stx:02x}, expected STX")
    n = hdr[4] + 1
    payload = bytes(_recv_byte_upstream(sock) for _ in range(n))
    etx = _recv_byte_upstream(sock)
    if (etx & 0x7F) != ETX:
        raise IOError(f"upstream sent 0x{etx:02x}, expected ETX")
    cks = _recv_byte_upstream(sock)
    eot = _recv_byte_upstream(sock)
    if (eot & 0x7F) != EOT:
        raise IOError(f"upstream sent 0x{eot:02x}, expected EOT")
    s = (STX + sum(payload) + ETX + cks) & 0xFF
    if s != 0:
        raise IOError(f"upstream data CKS bad: sum={s:#04x}")
    sock.sendall(bytes([ACK]))
    return hdr, payload


def handle(sock, upstream=None):
    """Service the PIO bridge connection.

    upstream: optional connected socket to an envelope-speaking
              CP/NET server.  When given, all non-PING frames are
              forwarded there (wrapped in SIO envelope); when None,
              they're dispatched locally via netboot_server.
    """
    where = (f"upstream {upstream.getpeername()}" if upstream
             else "local netboot_server")
    print(f"connected to bridge {sock.getpeername()}; routing to {where}")
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
            # Probe stays local — the upstream server (mpm-net2)
            # doesn't recognise FNC=0xC0.
            reply_payload = handle_ping(hdr, payload)
            reply_fmt = 0x01
            reply_did = hdr[2]
            reply_sid = hdr[1]
            reply_fnc = PING_FNC
        elif upstream is not None:
            # Forward to upstream wrapped in SIO envelope.
            upstream_send(upstream, hdr, payload)
            reply_hdr, reply_payload = upstream_recv(upstream)
            reply_fmt = reply_hdr[0]
            reply_did = reply_hdr[1]
            reply_sid = reply_hdr[2]
            reply_fnc = reply_hdr[3]
        else:
            reply_payload = netboot_server.dispatch_sndmsg(hdr, payload)
            if reply_payload is None:
                print(f"  [no reply for FNC={fnc:02x}; client should retry]")
                continue
            reply_fmt = 0x01
            reply_did = hdr[2]
            reply_sid = hdr[1]
            reply_fnc = fnc
        t_post_dispatch = time.monotonic()
        send_scb(sock,
                 fmt=reply_fmt,
                 did=reply_did,
                 sid=reply_sid,
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


def run(port, upstream_addr=None):
    """Listen on :port for MAME's cpnet_bridge.  When upstream_addr
    is "host:port", connect there too and proxy non-PING frames."""
    upstream_sock = None
    if upstream_addr:
        u_host, u_port = upstream_addr.rsplit(":", 1)
        u_port = int(u_port)
        print(f"cpnet_pio_server: connecting upstream to {u_host}:{u_port}")
        # Retry briefly — mpm-net2 may still be coming up.
        end = time.monotonic() + 30.0
        while time.monotonic() < end:
            try:
                upstream_sock = socket.create_connection((u_host, u_port),
                                                        timeout=5.0)
                break
            except OSError:
                time.sleep(0.2)
        if upstream_sock is None:
            sys.exit(f"cpnet_pio_server: could not connect upstream "
                     f"{u_host}:{u_port}")
        upstream_sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        upstream_sock.settimeout(30.0)
        print(f"cpnet_pio_server: upstream connected")

    print(f"cpnet_pio_server: listening on 127.0.0.1:{port}")
    listener = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    listener.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    listener.bind(("127.0.0.1", port))
    listener.listen(1)
    listener.settimeout(60.0)
    try:
        sock, peer = listener.accept()
    except socket.timeout:
        sys.exit(f"cpnet_pio_server: no client connected within 60s")
    finally:
        listener.close()
    sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    sock.settimeout(60.0)
    print(f"cpnet_pio_server: client connected from {peer}")
    try:
        handle(sock, upstream=upstream_sock)
    except (EOFError, socket.timeout, IOError) as e:
        print(f"session ended: {type(e).__name__}: {e}")
    finally:
        sock.close()
        if upstream_sock:
            upstream_sock.close()


if __name__ == "__main__":
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument("port", nargs="?", type=int, default=DEFAULT_PORT)
    ap.add_argument("--upstream", default=None,
                    help="HOST:PORT of an envelope-speaking CP/NET server "
                         "(e.g. 127.0.0.1:4002 for mpm-net2).  When given, "
                         "non-PING frames are forwarded with SIO envelope.")
    args = ap.parse_args()
    run(args.port, upstream_addr=args.upstream)
