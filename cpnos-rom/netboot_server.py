#!/usr/bin/env python3
"""Minimal DRI netboot server for cpnos-rom bring-up.

Listens on a TCP port (MAME -bitb1 socket.HOST:PORT connects) and
services a single boot exchange per connection:

  client -> 0xB0 DID=0 SID=slave FNC=0 SIZ=0 CKS     (boot request)
  server <- 0xB1 DID=slave SID=0 FNC=1 <text>        (load text)
  client -> 0xB0 ... FNC=0 (ack)
  server <- 0xB1 ... FNC=2 <lo hi>                   (set DMA)
  client -> ack
  server <- 0xB1 ... FNC=3 <128 data bytes>          (load block)
  client -> ack
  server <- 0xB1 ... FNC=4 <lo hi>                   (execute entry)

Sends a canned payload: one 128-byte block whose first byte is RET
(0xC9), written at DMA=0xDF80, with execute-entry = 0xDF80.  The
client netboot returns 0xDF80; cpnos_main CALLs it, RET comes
straight back, and the fall-through path drops into resident_entry
which paints "CPNOS" on the display.  The MAME test then also sees
0xDF80 == 0xC9 as evidence that FNC=3 landed data at the right VMA.

Usage:  python3 netboot_server.py [PORT]   (default PORT=9000)
"""

import socket
import struct
import sys

DEFAULT_PORT = 9000
DMA = 0xDF80
ENTRY = 0xDF80


def checksum(msg):
    return (-sum(msg)) & 0xFF


def make_msg(fmt, did, sid, fnc, data=b''):
    assert len(data) <= 255
    hdr = bytes([fmt, did, sid, fnc, len(data)])
    body = hdr + data
    return body + bytes([checksum(body)])


def recv_exact(c, n):
    buf = b''
    while len(buf) < n:
        chunk = c.recv(n - len(buf))
        if not chunk:
            raise EOFError(f"client closed after {len(buf)}/{n} bytes")
        buf += chunk
    return buf


def recv_msg(c):
    hdr = recv_exact(c, 5)
    siz = hdr[4]
    tail = recv_exact(c, siz + 1)
    msg = hdr + tail
    sumv = sum(msg) & 0xFF
    if sumv != 0:
        print(f"  [warn] checksum fail: sum={sumv:02x} msg={msg.hex()}")
    return msg


def handle(c):
    req = recv_msg(c)
    print(f"<- request: {req.hex()}  "
          f"FMT={req[0]:02x} DID={req[1]:02x} SID={req[2]:02x} "
          f"FNC={req[3]:02x} SIZ={req[4]}")
    if req[0] != 0xB0 or req[3] != 0:
        print("  not a boot request, ignoring")
        return
    client_sid = req[2]

    banner = b'CPNOS  '
    payload_block = b'\xc9' + b'\x00' * 127  # RET + zeros
    steps = [
        (1, banner,                 'load text'),
        (2, bytes([DMA & 0xFF, DMA >> 8]),   'set DMA'),
        (3, payload_block,          'load 128B'),
        (4, bytes([ENTRY & 0xFF, ENTRY >> 8]), 'execute'),
    ]
    for fnc, data, desc in steps:
        msg = make_msg(0xB1, client_sid, 0x00, fnc, data)
        print(f"-> FNC={fnc} ({desc}): {msg.hex()}")
        c.sendall(msg)
        if fnc == 4:
            break
        ack = recv_msg(c)
        print(f"<- ack: {ack.hex()}")

    # After FNC=4, the client jumps to 0xDF80 (RET) and falls back into
    # resident_entry, which calls NTWKIN then SNDMSG.  Switch to the
    # DRI SNIOS framing and service one SNDMSG round-trip.
    try:
        sniosro_handshake(c)
    except Exception as e:
        print(f"  snios exchange error: {e}")

    # Drain any remaining post-handshake bytes so MAME doesn't SIGPIPE.
    print("post-SNIOS: draining client writes until MAME closes")
    c.settimeout(2.0)
    try:
        while True:
            data = c.recv(256)
            if not data:
                break
            print(f"<- drain: {data.hex()}")
    except (socket.timeout, TimeoutError):
        print("(drain timeout, staying open)")
    while True:
        try:
            if not c.recv(256):
                break
        except (socket.timeout, TimeoutError):
            pass
        except Exception:
            break


# ---- DRI SNIOS framing (master side) --------------------------------
SOH, STX, ETX, EOT, ENQ, ACK, NAK = 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x15


def recv_byte(c, timeout=5.0):
    c.settimeout(timeout)
    b = c.recv(1)
    if not b:
        raise EOFError("client closed during SNIOS exchange")
    return b[0]


def sniosro_handshake(c):
    """Service one SNDMSG from the client per DRI framing.

    Protocol (client=slave, we=master):
      <- ENQ          ; client announces a message
      -> ACK
      <- SOH hdr[5] HCS   ; 2's-complement checksum over SOH+hdr
      -> ACK
      <- STX dat[n] ETX CKS EOT
      -> ACK          ; final ack
    """
    print("SNIOS: waiting for ENQ")
    c.settimeout(10.0)
    b = recv_byte(c, timeout=10.0)
    if b != ENQ:
        print(f"  [warn] expected ENQ (0x05), got 0x{b:02x}")
        return
    print(f"<- ENQ")
    c.sendall(bytes([ACK]))
    print("-> ACK")

    soh = recv_byte(c)
    if soh != SOH:
        print(f"  [warn] expected SOH, got 0x{soh:02x}")
        return
    hdr = bytes([recv_byte(c) for _ in range(5)])  # FMT DID SID FNC SIZ
    hcs = recv_byte(c)
    run = (soh + sum(hdr) + hcs) & 0xFF
    status = "ok" if run == 0 else f"BAD (sum={run:02x})"
    print(f"<- SOH {hdr.hex()} HCS=0x{hcs:02x} [{status}]")
    print(f"   FMT={hdr[0]:02x} DID={hdr[1]:02x} SID={hdr[2]:02x} "
          f"FNC={hdr[3]:02x} SIZ={hdr[4]}")
    c.sendall(bytes([ACK]))
    print("-> ACK")

    stx = recv_byte(c)
    if stx != STX:
        print(f"  [warn] expected STX, got 0x{stx:02x}")
        return
    n = hdr[4] + 1                       # SIZ=0 means 1 byte (DRI)
    data = bytes([recv_byte(c) for _ in range(n)])
    etx = recv_byte(c)
    cks = recv_byte(c)
    eot = recv_byte(c)
    run = (stx + sum(data) + etx + cks) & 0xFF
    status = "ok" if run == 0 else f"BAD (sum={run:02x})"
    eot_status = "ok" if eot == EOT else f"got 0x{eot:02x}"
    print(f"<- STX DAT({n})={data.hex()} ETX CKS=0x{cks:02x} "
          f"EOT [{status}, EOT {eot_status}]")
    c.sendall(bytes([ACK]))
    print("-> ACK (final)")
    print("SNIOS: SNDMSG round-trip complete")


def run(port):
    srv = socket.socket()
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(('127.0.0.1', port))
    srv.listen(1)
    print(f"netboot server listening on 127.0.0.1:{port}")
    while True:
        c, addr = srv.accept()
        print(f"client {addr} connected")
        try:
            handle(c)
        except Exception as e:
            print(f"  error: {e}")
        finally:
            c.close()
            print("client closed\n")


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_PORT
    try:
        run(port)
    except KeyboardInterrupt:
        pass
