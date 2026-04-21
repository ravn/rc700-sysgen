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
(0xC9), written at DMA=CCP_BASE, with execute-entry = CCP_BASE.  The
client netboot returns CCP_BASE; cpnos_main CALLs it, RET comes
straight back, and the fall-through path drops into resident_entry
which paints "CPNOS" on the display.  The MAME test then also sees
CCP_BASE == 0xC9 as evidence that FNC=3 landed data at the right VMA.

Usage:  python3 netboot_server.py [PORT]   (default PORT=9000)
"""

import datetime
import os
import socket
import struct
import sys

DEFAULT_PORT = 9000
# CCP base address.  Moved from 0xDF80 to 0xDB80 in session #24.
# Session #25 revisits the map with real NDOS.SPR (code_len=0x0C00=3KB):
#   CCP  (2.5KB actual, ccp.spr code_len=0x0A00)  0xD900..0xE2FF
#   NDOS (3KB)                                    0xE300..0xEEFF
#   BIOS                                          0xF200..~0xF562
# Page-aligned NDOS base required by SPR relocator (low byte must be 0).
DMA = 0xDB80
ENTRY = 0xDB80

# CP/NOS composite image built by cpnos-build — single .com carrying
# cpnos + cpndos + cpnios + cpbdos + cpbios, linked at data 0xCC00 /
# code 0xD000.
_HERE = os.path.dirname(os.path.abspath(__file__))
CPNOS_COM = os.path.join(_HERE, 'cpnos-build', 'd', 'cpnos.com')
CPNOS_BASE = 0xCC00     # where the .com's first byte lives in memory
ENTRY_ADDR = 0xD000     # BOOT label (first byte of code segment)

# Legacy single-module SPRs — kept for reference, not currently used.
NDOS_SPR = os.path.join(_HERE, '..', '..', 'cpnet-z80', 'dist', 'ndos.spr')
CCP_SPR  = os.path.join(_HERE, '..', '..', 'cpnet-z80', 'dist', 'ccp.spr')
NDOS_BASE = 0xDE00
CCP_BASE  = 0xD000


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


def spr_relocate(spr_bytes, base_addr):
    """Apply DRI SPR page-relocation.

    File layout (per cpnetldr.asm:530-644):
      [0..128)                 parameter sector (hdr[1..2]=code_len LE,
                               hdr[4..5]=data_len LE)
      [128..256)               ignored sector — loader does CALL OSREAD
                               then discards the result (cpnetldr.asm:566).
                               Always zero in modules we've seen.
      [256..256+code_len)      code image linked at origin 0x0000
      [..)                     data_len bytes (no relocation applied)
      [..)                     code_len/8 bytes relocation bitmap,
                               MSB-first: bit (7-(i&7)) of bitmap[i>>3]
                               flags code byte i for +base_page 8-bit ADD.

    Base must be page-aligned (low byte 0) because relocation is a plain
    8-bit add with no carry into the low byte.
    """
    assert base_addr & 0xFF == 0, f"SPR base 0x{base_addr:04x} not page-aligned"
    base_page = (base_addr >> 8) & 0xFF
    code_len = spr_bytes[1] | (spr_bytes[2] << 8)
    data_len = spr_bytes[4] | (spr_bytes[5] << 8)
    HDR = 128
    IGNORED = 128          # undocumented DRI quirk, see docstring
    code_off = HDR + IGNORED
    code = bytearray(spr_bytes[code_off:code_off + code_len])
    data = spr_bytes[code_off + code_len:code_off + code_len + data_len]
    bm_off = code_off + code_len + data_len
    bitmap = spr_bytes[bm_off:bm_off + code_len // 8]
    assert len(bitmap) == code_len // 8, \
        f"bitmap short: {len(bitmap)} != {code_len // 8}"
    for i in range(code_len):
        if (bitmap[i >> 3] >> (7 - (i & 7))) & 1:
            code[i] = (code[i] + base_page) & 0xFF
    return bytes(code) + data


def stream_payload(c, client_sid, dma_base, payload, label):
    """Write `payload` to client RAM starting at `dma_base` using
    FNC=2 (set DMA) once, then 128B FNC=3 blocks.  Client auto-advances
    dma after each FNC=3."""
    msg = make_msg(0xB1, client_sid, 0x00, 2,
                   bytes([dma_base & 0xFF, dma_base >> 8]))
    print(f"-> FNC=2 set DMA=0x{dma_base:04x} ({label}): {msg.hex()}")
    c.sendall(msg)
    ack = recv_msg(c)
    print(f"<- ack: {ack.hex()}")

    CHUNK = 128
    n_blocks = (len(payload) + CHUNK - 1) // CHUNK
    for i in range(n_blocks):
        block = payload[i * CHUNK:(i + 1) * CHUNK]
        if len(block) < CHUNK:
            block = block + b'\x00' * (CHUNK - len(block))
        msg = make_msg(0xB1, client_sid, 0x00, 3, block)
        print(f"-> FNC=3 block {i+1}/{n_blocks} @ 0x{dma_base + i*CHUNK:04x}: "
              f"{block[:8].hex()}...")
        c.sendall(msg)
        ack = recv_msg(c)


def handle(c):
    req = recv_msg(c)
    print(f"<- request: {req.hex()}  "
          f"FMT={req[0]:02x} DID={req[1]:02x} SID={req[2]:02x} "
          f"FNC={req[3]:02x} SIZ={req[4]}")
    if req[0] != 0xB0 or req[3] != 0:
        print("  not a boot request, ignoring")
        return
    client_sid = req[2]

    # Multi-line banner the client prints via CONOUT — verifies the
    # CR/LF + scroll path before CP/NOS ever gets handed control.
    now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    banner = (
        b'\x0c'                               # Ctrl-L: clear screen, home cursor
        b'\n cpnos-rom netboot - ' + now.encode('ascii') + b'\n'
        b'\n Console via BIOS CONOUT:\n'
        b'   - 8275 CRT (80x25, auto-init DMA)\n'
        b'   - SIO-B null-modem (polled, 38400)\n'
        b'\n Streaming cpnos.com -> 0xcc00\n\n'
    )
    # Fits in one FNC=1 frame because SIZ <= 255.
    assert len(banner) <= 255, f"banner too long ({len(banner)} > 255)"
    msg = make_msg(0xB1, client_sid, 0x00, 1, banner)
    print(f"-> FNC=1 (load text, {len(banner)} B)")
    c.sendall(msg)
    ack = recv_msg(c)
    print(f"<- ack: {ack.hex()}")

    # Stream the monolithic CP/NOS image: one DMA set to 0xCC00
    # followed by 34 FNC=3 blocks of cpnos.com (4292 bytes, rounded).
    with open(CPNOS_COM, 'rb') as f:
        image = f.read()
    print(f"cpnos.com: {len(image)} B -> 0x{CPNOS_BASE:04x}..0x{CPNOS_BASE+len(image)-1:04x}")
    stream_payload(c, client_sid, CPNOS_BASE, image, 'CPNOS')

    # Execute at BOOT (cpnos stub at 0xD000).  cpnos.s is `jmp BIOS`;
    # BIOS init sets up zero-page vectors, copies BIOS JT to
    # NDOSRL+0x300, and hands off to NDOS cold-start.
    msg = make_msg(0xB1, client_sid, 0x00, 4,
                   bytes([ENTRY_ADDR & 0xFF, ENTRY_ADDR >> 8]))
    print(f"-> FNC=4 (execute 0x{ENTRY_ADDR:04x}): {msg.hex()}")
    c.sendall(msg)

    # From here CCP runs, calls NDOS for BDOS services, NDOS drives
    # SNIOS for network I/O.  No more one-shot SNDMSG/RCVMSG probe —
    # whatever the client asks for, we either respond or let it time out.
    # For this bring-up the server just drains until MAME closes.
    print("post-boot: draining client writes until MAME closes")
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

    # Master -> slave RCVMSG round-trip.  Client has called
    # snios_rcvmsg_c() and is waiting for an ENQ from us.
    sniosro_send(c, fmt=0x01, did=hdr[2], sid=0x00, fnc=0x05,
                 data=bytes([0x42]))


def sniosro_send(c, fmt, did, sid, fnc, data):
    """Send one DRI frame (master -> slave).

    Mirror of the client's SNDMSG: ENQ/ACK, SOH+header+HCS/ACK,
    STX+data+ETX+CKS+EOT/ACK.  Data length on the wire is len(data)
    (clipped to >=1), SIZ field carries len-1 per DRI "0 means 1".
    """
    c.sendall(bytes([ENQ]))
    print("-> ENQ")
    ack = recv_byte(c)
    print(f"<- ACK 0x{ack:02x}" + ("" if ack == ACK else " [WARN]"))

    siz = max(len(data), 1) - 1
    header = bytes([fmt, did, sid, fnc, siz])
    run = (SOH + sum(header)) & 0xFF
    hcs = (-run) & 0xFF
    c.sendall(bytes([SOH]) + header + bytes([hcs]))
    print(f"-> SOH {header.hex()} HCS=0x{hcs:02x}")
    ack = recv_byte(c)
    print(f"<- ACK 0x{ack:02x}" + ("" if ack == ACK else " [WARN]"))

    run = (STX + sum(data) + ETX) & 0xFF
    cks = (-run) & 0xFF
    c.sendall(bytes([STX]) + data + bytes([ETX, cks, EOT]))
    print(f"-> STX DAT={data.hex()} ETX CKS=0x{cks:02x} EOT")
    ack = recv_byte(c)
    print(f"<- ACK 0x{ack:02x} (final)" + ("" if ack == ACK else " [WARN]"))
    print("SNIOS: RCVMSG round-trip complete")


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
