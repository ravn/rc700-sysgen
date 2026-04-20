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

    # After FNC=4, the client executes loaded code and may still write
    # console bytes (or garbage) on SIO-A.  Keep the socket open and drain
    # it so MAME doesn't get SIGPIPE when the Z80 writes post-netboot.
    print("post-FNC=4: draining client writes until MAME closes")
    c.settimeout(2.0)
    try:
        while True:
            data = c.recv(256)
            if not data:
                break
            print(f"<- drain: {data.hex()}")
    except (socket.timeout, TimeoutError):
        print("(drain timeout, staying open)")
    # Don't close; let MAME close its end when it exits.
    while True:
        try:
            if not c.recv(256):
                break
        except (socket.timeout, TimeoutError):
            pass
        except Exception:
            break


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
