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
# Key = 11-char normalised "NAME    EXT" (8+3, uppercase).
# CCP.SPR + NDOS.SPR are exposed for NDOS cold boot; other files
# are user-visible on DIR so step 4 of the smoke plan can iterate them.
_FILE_ROOTS = [
    os.path.join(_HERE, '..', '..', 'cpnet-z80', 'dist'),   # DRI sources
    os.path.join(_HERE, 'testutil'),                        # our test helpers (done.com etc.)
]


def _build_file_map():
    m = {}
    for root in _FILE_ROOTS:
        if not os.path.isdir(root):
            continue
        for fn in sorted(os.listdir(root)):
            full = os.path.join(root, fn)
            if not os.path.isfile(full):
                continue
            base, _, ext = fn.rpartition('.')
            if not base:
                base, ext = fn, ''
            name = base.upper().ljust(8)[:8]
            ext  = ext.upper().ljust(3)[:3]
            m[f"{name}{ext}"] = full
    m.setdefault('CCP     SPR', os.path.join(_FILE_ROOTS[0], 'ccp.spr'))
    return m


_FILE_MAP = _build_file_map()
_OPEN_FILES = {}   # key: fcb[0..11] -> bytes content (session cache for reads)
_WRITES = {}       # key: fcb[0..11] -> bytearray (ephemeral writable files)


def _seed_sub_file(slave_id=0x70, commands=None):
    """Seed $<ss>.SUB in _WRITES with a list of command lines.  CCP's
    CP/NET submit reader (ccp.asm:215-266) reads records in LIFO order:
    it reads the last record, if byte 0 != 0xFF it treats the record
    as a command, else follows the indirection pointer to the named
    record.  On a single-command SUB we want exactly one record with
    the line, so CCP reads it, sees buff[0] != 0xFF, executes, then
    notices subrr==0 and deletes the file.

    Record format: byte 0 = line length, bytes 1..len = ASCII text,
    rest zeros.  Length byte gives CCP the line length for comlen."""
    if not commands:
        return
    # CCP reads SUB records LIFO: the last record is the first command
    # executed, then truncates.  To run commands in human order we write
    # them reversed so commands[0] ends up at the tail of the file.
    key = f"${slave_id:02X}     SUB"
    buf = bytearray()
    for line in reversed(commands):
        line = line.rstrip('\r\n')
        rec = bytearray(128)
        rec[0] = len(line)
        rec[1:1 + len(line)] = line.encode('ascii', 'replace')
        buf.extend(rec)
    _WRITES[key] = buf
    print(f"seeded SUB file {key!r} with {len(commands)} command(s): {commands}")


_SUB_CMDS = os.environ.get('CPNOS_SUB', '')
if _SUB_CMDS:
    _seed_sub_file(commands=_SUB_CMDS.split('|'))


def _all_keys():
    """Union of read-only server files and ephemeral written files."""
    return sorted(set(_FILE_MAP) | set(_WRITES))


def _file_content(key):
    """Content for READ: prefer in-memory writes (fresh from MAKE +
    WRITE SEQ), fall back to read-only _FILE_MAP on disk."""
    if key in _WRITES:
        return bytes(_WRITES[key])
    path = _FILE_MAP.get(key)
    if path and os.path.exists(path):
        with open(path, 'rb') as f:
            return f.read()
    return None


def _file_size(key):
    if key in _WRITES:
        return len(_WRITES[key])
    path = _FILE_MAP.get(key)
    return os.path.getsize(path) if path and os.path.exists(path) else 0

# SEARCH FIRST / NEXT iterator state.  One global slot is fine while we
# run a single CP/NOS client at a time.
_SEARCH_STATE = {
    'pattern': None,   # 11-char pattern with '?' = any
    'pending': [],     # keys still to return (popleft)
}


def _pattern_from_search_data(data):
    """Extract the 11-char name+ext pattern from a SEARCH FIRST/NEXT
    message.  NDOS's stsf routing (cpndos.asm:747-770) produces two
    different preamble layouts depending on whether FCB[0] is '?':
        stsf1 (specific drive): [user, drive, FCB[1..35]]        -> 37 B
        stsf2 ('?' wildcard):   [drive, user, '?', FCB[1..35]]   -> 38 B
    Both end with FCB[1..35] at the tail, and the pattern (FCB[1..11])
    is the first 11 bytes of that 35-byte block.  Compute position
    relative to the end so the preamble ambiguity is absorbed."""
    if len(data) < 35:
        return '?' * 11
    start = len(data) - 35
    raw = bytes(b & 0x7F for b in data[start:start + 11])
    s = raw.decode('latin1', 'replace').upper()
    return s.ljust(11)[:11]


def _pattern_match(pattern, key):
    if len(pattern) != 11 or len(key) != 11:
        return False
    return all(p == '?' or p == k for p, k in zip(pattern, key))


def _is_system_file(key):
    """Hide our test infrastructure from DIR listings.  CP/M CCP's DIR
    built-in skips entries where FCB ext-byte-1 bit 7 (SYS attribute)
    is set.  Applies to the ephemeral submit file and anything we
    install under cpnos-rom/testutil/ — those are plumbing, not
    user-visible files."""
    if key.startswith('$'):
        return True
    path = _FILE_MAP.get(key)
    if path and os.path.sep + 'testutil' + os.path.sep in path:
        return True
    return False


def _dir_entry(key, size):
    """Build a 32-byte CP/M directory entry for a file.  We use extent 0
    only; the block map is filled with non-zero sentinels so CP/M tools
    that check allocation won't flag the entry as deleted/empty.

    SYS attribute is encoded as bit 7 of ext[1] (byte 10 of the entry)
    per DRI FCB convention — CCP's DIR masks these out.  R/O is bit 7
    of ext[0]; we mark every _FILE_MAP-sourced file R/O because the
    server never writes back to the host filesystem — BDOS will reject
    inadvertent writes cleanly instead of silently succeeding in the
    _OPEN_FILES cache but losing the change on the next OPEN."""
    name = bytearray(key[:8].encode('ascii'))
    ext  = bytearray(key[8:11].encode('ascii'))
    if key in _FILE_MAP and key not in _WRITES:
        ext[0] |= 0x80                        # R/O
    if _is_system_file(key):
        ext[1] |= 0x80                        # SYS: hide from DIR
    rc   = min(128, (size + 127) // 128)
    entry = bytearray(32)
    entry[0]    = 0x00                        # user number
    entry[1:9]  = name
    entry[9:12] = ext
    entry[12]   = 0                           # extent low
    entry[13]   = 0                           # s1
    entry[14]   = 0                           # s2 / extent high
    entry[15]   = rc                          # record count this extent
    for i in range(16, 32):
        entry[i] = 0x01                       # bogus non-zero alloc block
    return bytes(entry)

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


def _search_reply():
    """Format a SEARCH FIRST / NEXT reply: status byte + 128-byte dir
    buffer holding the next pending match at offset 0.  Returns 0xFF
    when no more matches.  We always report status 0 (entry at offset
    0) so the 128-byte buffer is just [entry|zeros*96]."""
    pending = _SEARCH_STATE['pending']
    if not pending:
        return bytes([0xFF]) + b'\0' * 128
    key = pending.pop(0)
    entry = _dir_entry(key, _file_size(key))
    return bytes([0x00]) + entry + b'\0' * (128 - len(entry))


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
        # Reply layout (34 B, matches cpnet/server.py handle_open).
        # Name+ext high bits stripped so the client's FCB doesn't
        # carry over R/O/SYS attributes -- PIPNET propagates R/O into
        # its output FCB and blocks WRITE otherwise.
        fcb_in = bytearray(data[1:37]) if len(data) >= 37 else bytearray(36)
        key = _fcb_key(fcb_in)
        content = _file_content(key)
        if content is None:
            print(f"    file-not-found key={key!r}")
            return bytes([0xFF])
        _OPEN_FILES[key] = content
        records = min(128, (len(content) + 127) // 128)
        reply = bytearray(34)
        reply[0] = 0x00
        reply[1] = data[1] & 0x0F                # drive, attributes stripped
        # FCB[1..11] = name(8) + ext(3), high bits stripped
        reply[2:13] = bytes(b & 0x7F for b in data[2:13])
        reply[13] = 0                            # ex
        reply[14] = 0                            # s1
        reply[15] = 0                            # s2
        reply[16] = records                      # rc
        # reply[17..32] alloc + cr all zero
        print(f"    opened {key!r} ({len(content)} B)")
        return bytes(reply)

    if fnc == 22:  # MAKE FILE
        # Reply layout (34 B, matches cpnet/server.py handle_make_file):
        #   byte 0     retcode
        #   byte 1     drive
        #   bytes 2-12 FCB[1..11] name + ext
        #   bytes 13-16 ex/s1/s2/rc = 0 (new empty file)
        #   bytes 17-32 allocation map = zeros
        #   byte 33    cr = 0
        # NDOS gtfcb copies 32 bytes from msgdat[2..33] into caller's
        # FCB[1..32].  Returning extra bytes (e.g. r0/r1/r2) alters
        # siz and can trigger NDOS's 35-byte ctfcrr path inadvertently.
        fcb_in = bytearray(data[1:37]) if len(data) >= 37 else bytearray(36)
        key = _fcb_key(fcb_in)
        if key in _FILE_MAP:
            print(f"    MAKE: refuse, {key!r} exists on disk")
            return bytes([0xFF])
        _WRITES[key] = bytearray()
        _OPEN_FILES[key] = bytes()
        reply = bytearray(34)
        reply[0] = 0x00                          # retcode (success)
        reply[1] = data[1] & 0x0F                # drive, attributes stripped
        reply[2:13] = bytes(b & 0x7F for b in data[2:13])   # name+ext, attrs stripped
        # bytes 13..32 stay 0: ex, s1, s2, rc, alloc (zeros), cr
        print(f"    MAKE {key!r} reply={bytes(reply).hex()}")
        return bytes(reply)

    if fnc == 21:  # WRITE SEQ
        print(f"    WRITE SEQ raw DAT[{len(data)}]={data.hex()}")
        # Request: FCB at data[1..36], 128-byte sector at data[37..164].
        fcb = bytearray(data[1:37]) if len(data) >= 37 else bytearray(36)
        sector = bytes(data[37:165]) if len(data) >= 165 else bytes(data[37:]).ljust(128, b'\0')
        key = _fcb_key(fcb)
        if key not in _WRITES:
            print(f"    WRITE: no MAKE/OPEN for {key!r}")
            return bytes([0xFF]) + bytes(fcb)
        buf = _WRITES[key]
        ex = fcb[12]
        cr = fcb[32]
        record = ex * 128 + cr
        offset = record * 128
        if offset + 128 > len(buf):
            buf.extend(b'\0' * (offset + 128 - len(buf)))
        buf[offset:offset + 128] = sector
        _OPEN_FILES[key] = bytes(buf)
        cr += 1
        if cr >= 128:
            cr = 0
            ex += 1
        fcb[12] = ex
        fcb[32] = cr
        print(f"    WRITE record {record} -> {key!r} (size now {len(buf)})")
        return bytes([0x00]) + bytes(fcb)

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
        fcb = bytearray(data[1:37]) if len(data) >= 37 else bytearray((data[1:] if data else b'').ljust(36, b'\0'))
        key = _fcb_key(fcb)
        _OPEN_FILES.pop(key, None)
        # If the client wrote to this key, persist the final contents
        # so host-side tests can byte-compare against an expected file.
        if key in _WRITES:
            out_dir = '/tmp/cpnos_writes'
            os.makedirs(out_dir, exist_ok=True)
            fn_clean = key.strip().replace(' ', '_').replace('/', '_')
            out_path = os.path.join(out_dir, fn_clean + '.bin')
            with open(out_path, 'wb') as f:
                f.write(bytes(_WRITES[key]))
            print(f"    CLOSE: flushed {key!r} ({len(_WRITES[key])} B) -> {out_path}")
        return bytes([0x00]) + bytes(fcb)

    if fnc == 35:  # COMPUTE FILE SIZE
        # Reply: status + FCB with r0/r1/r2 (bytes 33/34/35) set to
        # record count (ceil(size/128)).  CP/NET CCP reads this from
        # subrr (FCB bytes 33..34) to find the last-record index.
        fcb = bytearray(data[1:37]) if len(data) >= 37 else bytearray(36)
        key = _fcb_key(fcb)
        size = _file_size(key)
        records = (size + 127) // 128
        fcb[33] = records & 0xFF
        fcb[34] = (records >> 8) & 0xFF
        fcb[35] = (records >> 16) & 0xFF
        print(f"    FILE SIZE {key!r} = {records} records ({size} B)")
        return bytes([0x00]) + bytes(fcb)

    if fnc == 33:  # RANDOM READ
        fcb = bytearray(data[1:37]) if len(data) >= 37 else bytearray(36)
        key = _fcb_key(fcb)
        content = _file_content(key)
        if content is None:
            print(f"    RANDREAD: no file {key!r}")
            return bytes([0xFF]) + bytes(fcb) + b'\0' * 128
        record = fcb[33] | (fcb[34] << 8) | (fcb[35] << 16)
        offset = record * 128
        sector = content[offset:offset + 128] if offset < len(content) else b''
        if len(sector) < 128:
            sector = sector + b'\x1A' * (128 - len(sector))
        status = 0x00 if offset < len(content) else 0x01
        print(f"    RANDREAD {key!r} rec {record}: {sector[:8].hex()}...")
        return bytes([status]) + bytes(fcb) + bytes(sector)

    if fnc == 34:  # RANDOM WRITE
        fcb = bytearray(data[1:37]) if len(data) >= 37 else bytearray(36)
        sector = bytes(data[37:165]) if len(data) >= 165 else bytes(data[37:]).ljust(128, b'\0')
        key = _fcb_key(fcb)
        if key not in _WRITES:
            # First random-write on a read-only file: copy-on-write to _WRITES
            src = _file_content(key)
            if src is None:
                print(f"    RANDWRITE: no file {key!r}")
                return bytes([0xFF]) + bytes(fcb)
            _WRITES[key] = bytearray(src)
        buf = _WRITES[key]
        record = fcb[33] | (fcb[34] << 8) | (fcb[35] << 16)
        offset = record * 128
        if offset + 128 > len(buf):
            buf.extend(b'\0' * (offset + 128 - len(buf)))
        buf[offset:offset + 128] = sector
        print(f"    RANDWRITE {key!r} rec {record}")
        return bytes([0x00]) + bytes(fcb)

    if fnc == 19:  # DELETE FILE
        fcb = bytearray(data[1:37]) if len(data) >= 37 else bytearray(36)
        key = _fcb_key(fcb)
        if key in _WRITES:
            del _WRITES[key]
            _OPEN_FILES.pop(key, None)
            print(f"    DELETE {key!r} (ephemeral)")
            return bytes([0x00]) + bytes(fcb)
        # Files in _FILE_MAP are read-only; deletion silently refused.
        print(f"    DELETE {key!r}: not found / read-only")
        return bytes([0xFF]) + bytes(fcb)

    if fnc == 23:  # RENAME FILE
        # BDOS fn 23 FCB layout: bytes 0..15 = old (drive+name+ext+extent),
        # bytes 16..31 = new (drive+name+ext+reserved).  The new name fills
        # d1..d11 at fcb[17..27].  Build a synthetic 12-byte "drive+name+ext"
        # buffer for _fcb_key().
        fcb = bytearray(data[1:37]) if len(data) >= 37 else bytearray(36)
        old_key = _fcb_key(fcb)
        new_fcb = bytes([fcb[16]]) + bytes(fcb[17:25]) + bytes(fcb[25:28])
        new_key = _fcb_key(new_fcb)
        if old_key not in _WRITES and old_key not in _FILE_MAP:
            print(f"    RENAME {old_key!r} -> {new_key!r}: old not found")
            return bytes([0xFF]) + bytes(fcb)
        if new_key in _WRITES or new_key in _FILE_MAP:
            print(f"    RENAME {old_key!r} -> {new_key!r}: new already exists")
            return bytes([0xFF]) + bytes(fcb)
        if old_key in _WRITES:
            _WRITES[new_key] = _WRITES.pop(old_key)
        if old_key in _OPEN_FILES:
            _OPEN_FILES[new_key] = _OPEN_FILES.pop(old_key)
        if old_key in _FILE_MAP:
            # Rebind the disk-backed entry under the new key for the
            # remainder of this server session (in-memory only).
            _FILE_MAP[new_key] = _FILE_MAP.pop(old_key)
        print(f"    RENAME {old_key!r} -> {new_key!r}")
        return bytes([0x00]) + bytes(fcb)

    if fnc == 17:  # SEARCH FIRST
        pattern = _pattern_from_search_data(data)
        matches = [k for k in _all_keys() if _pattern_match(pattern, k)]
        _SEARCH_STATE['pattern'] = pattern
        _SEARCH_STATE['pending'] = matches
        print(f"    SEARCH FIRST pattern={pattern!r} matches={len(matches)}")
        return _search_reply()

    if fnc == 18:  # SEARCH NEXT
        print(f"    SEARCH NEXT remaining={len(_SEARCH_STATE['pending'])}")
        return _search_reply()

    if fnc == 12:  # GET VERSION
        # CP/M 2.2 = L:0x22, H:0 (system type = CP/M-80).  PIPNET
        # checks this during startup ("REQUIRES CP/M 2.0 OR NEWER");
        # a zero reply may throw it into a degraded code path.
        print(f"    GET VERSION -> 2.2")
        return bytes([0x22, 0x00])

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
