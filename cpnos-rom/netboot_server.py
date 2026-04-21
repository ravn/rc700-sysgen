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

    # Post-boot: service SNIOS SNDMSG/RCVMSG exchanges from NDOS.
    # Loop until the client closes or falls silent.
    print("post-boot: serving SNIOS requests")
    try:
        while True:
            hdr, data = snios_recv_sndmsg(c)
            reply = dispatch_sndmsg(hdr, data)
            if reply is None:
                print(f"  [no reply for FNC={hdr[3]:02x}]")
                continue
            snios_send_rcvmsg(c, reply_to=hdr, data=reply)
    except (socket.timeout, TimeoutError, EOFError) as e:
        print(f"SNIOS session ended: {type(e).__name__}: {e}")


# ---- DRI SNIOS framing (master side) --------------------------------
SOH, STX, ETX, EOT, ENQ, ACK, NAK = 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x15


def recv_byte(c, timeout=5.0):
    c.settimeout(timeout)
    b = c.recv(1)
    if not b:
        raise EOFError("client closed during SNIOS exchange")
    return b[0]


def snios_recv_sndmsg(c, idle_timeout=30.0, byte_timeout=5.0):
    """Receive one SNDMSG frame from the client per DRI framing.
    Returns (header_bytes, data_bytes) or raises on error/timeout.

    Protocol (client=slave, we=master):
      <- ENQ                      ; client announces a message
      -> ACK
      <- SOH hdr[5] HCS           ; 2's-complement checksum over SOH+hdr
      -> ACK
      <- STX dat[n] ETX CKS EOT
      -> ACK                       ; final ack
    """
    c.settimeout(idle_timeout)
    b = c.recv(1)
    if not b:
        raise EOFError("client closed waiting for ENQ")
    if b[0] != ENQ:
        raise EOFError(f"expected ENQ, got 0x{b[0]:02x}")
    c.sendall(bytes([ACK]))

    c.settimeout(byte_timeout)
    soh = recv_byte(c)
    if soh != SOH:
        raise EOFError(f"expected SOH, got 0x{soh:02x}")
    hdr = bytes([recv_byte(c) for _ in range(5)])
    hcs = recv_byte(c)
    run = (soh + sum(hdr) + hcs) & 0xFF
    if run != 0:
        print(f"  [warn] header checksum fail: sum={run:02x}")
    print(f"<- SOH FMT={hdr[0]:02x} DID={hdr[1]:02x} SID={hdr[2]:02x} "
          f"FNC={hdr[3]:02x} SIZ={hdr[4]}  HCS=0x{hcs:02x}")
    c.sendall(bytes([ACK]))

    stx = recv_byte(c)
    if stx != STX:
        raise EOFError(f"expected STX, got 0x{stx:02x}")
    n = hdr[4] + 1
    data = bytes([recv_byte(c) for _ in range(n)])
    etx = recv_byte(c)
    cks = recv_byte(c)
    eot = recv_byte(c)
    run = (stx + sum(data) + etx + cks) & 0xFF
    if run != 0:
        print(f"  [warn] data checksum fail: sum={run:02x}")
    if eot != EOT:
        print(f"  [warn] expected EOT, got 0x{eot:02x}")
    print(f"<- STX DAT[{n}]={data.hex()}")
    c.sendall(bytes([ACK]))
    return hdr, data


def snios_send_rcvmsg(c, reply_to, data, fnc=None):
    """Send one DRI RCVMSG frame back to the client.
    `reply_to` is the request header; we swap DID/SID and reuse FNC
    unless an override is given.
    """
    fnc = reply_to[3] if fnc is None else fnc
    fmt = 0x01                              # reply marker
    did = reply_to[2]                       # client's SID -> our DID
    sid = 0x00                              # server slave ID

    c.sendall(bytes([ENQ]))
    ack = recv_byte(c)
    if ack != ACK:
        print(f"  [warn] expected ACK after ENQ, got 0x{ack:02x}")

    siz = max(len(data), 1) - 1
    header = bytes([fmt, did, sid, fnc, siz])
    run = (SOH + sum(header)) & 0xFF
    hcs = (-run) & 0xFF
    c.sendall(bytes([SOH]) + header + bytes([hcs]))
    ack = recv_byte(c)
    if ack != ACK:
        print(f"  [warn] expected ACK after SOH, got 0x{ack:02x}")

    run = (STX + sum(data) + ETX) & 0xFF
    cks = (-run) & 0xFF
    c.sendall(bytes([STX]) + data + bytes([ETX, cks, EOT]))
    ack = recv_byte(c)
    if ack != ACK:
        print(f"  [warn] expected ACK after EOT, got 0x{ack:02x}")
    print(f"-> RCVMSG reply FNC={fnc:02x} DAT[{len(data)}]={data.hex()}")


# Host-side file repository served to the CP/NOS client.
_FILE_ROOT = os.path.join(_HERE, '..', '..', 'cpnet-z80', 'dist')
_FILE_MAP = {
    'CCP     SPR': os.path.join(_FILE_ROOT, 'ccp.spr'),
}
_OPEN_FILES = {}   # key: fcb[0..11] -> bytes content

BDOS_FNC = {
    13: "RESET DISK",
    14: "SELECT DISK",
    15: "OPEN FILE",
    16: "CLOSE FILE",
    17: "SEARCH FIRST",
    18: "SEARCH NEXT",
    19: "DELETE FILE",
    20: "READ SEQ",
    21: "WRITE SEQ",
    22: "MAKE FILE",
    23: "RENAME FILE",
    26: "SET DMA",
    32: "SET USER",
    35: "FILE SIZE",
    36: "SET RANDOM REC",
    37: "RESET DISK VEC",
    39: "FREE DRIVE (bcast)",
}


def _fcb_key(fcb):
    """Turn an FCB's 8-byte name + 3-byte ext (with high bits stripped)
    into a case-insensitive canonical 'NAME    EXT' key."""
    name = bytes(b & 0x7F for b in fcb[1:9]).decode('latin1', 'replace').strip()
    ext  = bytes(b & 0x7F for b in fcb[9:12]).decode('latin1', 'replace').strip()
    return f"{name:<8}{ext:<3}".upper()


def dispatch_sndmsg(hdr, data):
    """CP/NET BDOS-over-SNIOS dispatcher.  Handles just the subset of
    functions NDOS uses during cold-boot CCP load (fn 13, 14, 15, 16,
    20, 26, 32, 39).  Reply layout per DRI convention:
        msgdat[0]       = status byte (0..3 OK, 0xFF error)
        msgdat[1..36]   = 36-byte FCB (echoed, with ex/cr updated)
        msgdat[37..164] = 128-byte sector (READ SEQ only)
    """
    fnc = hdr[3]
    name = BDOS_FNC.get(fnc, '?')
    print(f"  dispatch FNC={fnc:#04x} ({name})")

    if fnc == 15:   # OPEN FILE
        # Request layout: data[0] = leading byte (disk/FID code), data[1..36] = FCB.
        fcb = bytearray(data[1:37]) if len(data) >= 37 else bytearray((data[1:] if data else b'').ljust(36, b'\0'))
        key = _fcb_key(fcb)
        path = _FILE_MAP.get(key)
        if path and os.path.exists(path):
            with open(path, 'rb') as f:
                content = f.read()
            _OPEN_FILES[key] = content
            # Reset sequential-access fields
            fcb[12] = 0   # ex
            fcb[13] = 0   # s1
            fcb[14] = 0   # s2
            fcb[15] = min(128, (len(content) - 0) // 128)  # rc in first extent
            fcb[32] = 0   # cr
            print(f"    opened {path} ({len(content)} B), key={key!r}")
            return bytes([0x00]) + bytes(fcb)
        print(f"    file-not-found key={key!r}")
        return bytes([0xFF]) + bytes(fcb)

    if fnc == 20:   # READ SEQ
        # Request layout: data[0] = leading byte (disk/FID code), data[1..36] = FCB.
        fcb = bytearray(data[1:37]) if len(data) >= 37 else bytearray((data[1:] if data else b'').ljust(36, b'\0'))
        key = _fcb_key(fcb)
        content = _OPEN_FILES.get(key)
        if content is None:
            print(f"    READ on unopened file key={key!r}")
            return bytes([0xFF]) + bytes(fcb) + b'\0' * 128
        # Compute absolute record: ex * 128 + cr
        ex = fcb[12]
        cr = fcb[32]
        record = ex * 128 + cr
        offset = record * 128
        if offset >= len(content):
            print(f"    EOF at record {record} (offset {offset}, len {len(content)})")
            return bytes([0x01]) + bytes(fcb) + b'\0' * 128   # 1 = EOF
        sector = content[offset:offset + 128]
        if len(sector) < 128:
            sector = sector + b'\x1A' * (128 - len(sector))   # CP/M EOF pad
        # Advance cr; handle extent roll-over (cr >= 128 -> ex++, cr=0).
        cr += 1
        if cr >= 128:
            cr = 0
            ex += 1
        fcb[12] = ex
        fcb[32] = cr
        print(f"    read record {record} @ offset {offset}: {sector[:8].hex()}...")
        return bytes([0x00]) + bytes(fcb) + bytes(sector)

    if fnc == 16:   # CLOSE FILE
        # Request layout: data[0] = leading byte (disk/FID code), data[1..36] = FCB.
        fcb = bytearray(data[1:37]) if len(data) >= 37 else bytearray((data[1:] if data else b'').ljust(36, b'\0'))
        key = _fcb_key(fcb)
        _OPEN_FILES.pop(key, None)
        return bytes([0x00]) + bytes(fcb)

    if fnc == 19:  # DELETE FILE
        # No writable filesystem yet — report "no matching file" rather
        # than faking success, so CCP's state doesn't diverge from truth.
        fcb = bytearray(data[1:37]) if len(data) >= 37 else bytearray(36)
        print(f"    DELETE: no file to delete, returning 0xFF")
        return bytes([0xFF]) + bytes(fcb)

    if fnc in (17, 18):   # SEARCH FIRST / SEARCH NEXT
        # Minimal stub: "no matching directory entry".  Returning status 0
        # with a zeroed FCB makes CCP think it found a file called
        # "\0\0\0\0\0\0\0\0.\0\0\0" and garbage-print it; 0xFF is the
        # canonical "no file" status.  Reply data buffer is 128 bytes
        # (4 x 32-byte dir entries); content is irrelevant when status
        # says not-found.
        print(f"    SEARCH {fnc}: returning no-match (0xFF)")
        return bytes([0xFF]) + b'\0' * 128

    if fnc in (13, 14, 26, 32, 39, 37):
        # Status-only responses; echo FCB-like zero padding for safety.
        return bytes([0x00]) + b'\0' * 36

    # Unknown — short reply.
    print(f"    unhandled FNC, replying 0 status")
    return bytes([0x00]) + b'\0' * 36


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
