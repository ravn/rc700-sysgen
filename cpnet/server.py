#!/usr/bin/env python3
"""CP/NET server for RC702 over MAME null_modem TCP.

Connects to MAME's null_modem serial port and serves CP/NET requests
from the RC702 SNIOS using the DRI binary serial protocol.

Usage:
    python3 server.py [--host HOST] [--port PORT] [--drive-dir DIR] [--node NODE]

The server maps CP/NET network drives to host directories. By default,
drive H: (network drive index 0) maps to the current directory.

Protocol: DRI binary serial framing
  Send: ENQ → ACK → SOH HDR(5) HCS → ACK → STX DATA ETX CKS EOT → ACK
  Recv: ENQ → ACK → SOH HDR(5) HCS → ACK → STX DATA ETX CKS EOT → ACK
  Checksum: two's complement sum (0 - sum_of_bytes)
"""

import argparse
import os
import socket
import struct
import sys
import threading
import time

# CP/NET BDOS function codes
FUNC_RESET_DISK = 13
FUNC_SELECT_DISK = 14
FUNC_SEARCH_FIRST = 17
FUNC_SEARCH_NEXT = 18
FUNC_READ_SEQ = 20
FUNC_WRITE_SEQ = 21
FUNC_MAKE_FILE = 22
FUNC_OPEN_FILE = 15
FUNC_CLOSE_FILE = 16
FUNC_DELETE_FILE = 19
FUNC_RENAME_FILE = 23
FUNC_RET_CURRENT = 25
FUNC_SET_DMA = 26
FUNC_GET_ALLOC = 27
FUNC_WRITE_PROT = 28
FUNC_GET_RO = 29
FUNC_SET_ATTRS = 30
FUNC_GET_DPB = 31
FUNC_GET_USER = 32
FUNC_READ_RAND = 33
FUNC_WRITE_RAND = 34
FUNC_FILE_SIZE = 35
FUNC_SET_REC = 36
FUNC_RESET_DRIVE = 37
FUNC_WRITE_RAND_ZF = 40
FUNC_ACCESS_DRIVE = 38
FUNC_LIST_OUTPUT = 5
FUNC_FREE_DRIVE = 39
FUNC_GET_LOGIN_VECTOR = 24
FUNC_NETWORK_LOGIN = 64
FUNC_NETWORK_LOGOFF = 65
FUNC_NETWORK_STATUS = 70
FUNC_GET_SERVER_CFG = 71
FUNC_NETWORK_INIT = 0xFF
FUNC_NETWORK_DOWN = 0xFE

# DRI protocol control characters
SOH = 0x01  # Start of Header
STX = 0x02  # Start of Data
ETX = 0x03  # End of Data
EOT = 0x04  # End of Transmission
ENQ = 0x05  # Enquire
ACK = 0x06  # Acknowledge
NAK = 0x15  # Negative Acknowledge


def checksum(data, init=0):
    """Compute two's complement checksum.
    Returns the byte that makes the running sum zero."""
    s = init
    for b in data:
        s = (s + b) & 0xFF
    return (-s) & 0xFF


class ThroughputMonitor:
    """Tracks bytes sent/received per second and writes to CSV."""

    def __init__(self, log_file="/tmp/serial_monitor.csv"):
        self.log_file = log_file
        self.tx_bytes = 0
        self.rx_bytes = 0
        self.second = 0
        self._lock = threading.Lock()
        self._running = False

    def start(self):
        with open(self.log_file, "w") as f:
            f.write("second,tx_bytes,rx_bytes\n")
        self._running = True
        self._thread = threading.Thread(target=self._run, daemon=True)
        self._thread.start()

    def stop(self):
        self._running = False

    def add_tx(self, n):
        with self._lock:
            self.tx_bytes += n

    def add_rx(self, n):
        with self._lock:
            self.rx_bytes += n

    def _run(self):
        while self._running:
            time.sleep(1.0)
            self.second += 1
            with self._lock:
                tx, rx = self.tx_bytes, self.rx_bytes
                self.tx_bytes = 0
                self.rx_bytes = 0
            with open(self.log_file, "a") as f:
                f.write(f"{self.second},{tx},{rx}\n")


class SerialConnection:
    """Manages TCP connection to MAME null_modem using DRI binary protocol."""

    def __init__(self, host, port):
        self.host = host
        self.port = port
        self.sock = None
        self.monitor = ThroughputMonitor()

    def connect(self):
        """Connect to MAME null_modem TCP socket."""
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect((self.host, self.port))
        self.sock.settimeout(30.0)
        self.monitor.start()
        print(f"Connected to {self.host}:{self.port}")

    def send_byte(self, b):
        """Send a single byte."""
        self.sock.sendall(bytes([b]))
        self.monitor.add_tx(1)

    def recv_byte(self, timeout=30.0):
        """Receive a single byte with timeout. timeout=None blocks forever."""
        self.sock.settimeout(timeout)
        try:
            data = self.sock.recv(1)
            if not data:
                raise ConnectionError("Connection closed")
            self.monitor.add_rx(1)
            return data[0]
        except socket.timeout:
            return None

    def recv_bytes(self, n, timeout=5.0):
        """Receive exactly n bytes with timeout."""
        result = bytearray()
        for _ in range(n):
            b = self.recv_byte(timeout)
            if b is None:
                return None
            result.append(b)
        return bytes(result)

    def send_frame(self, hdr, payload):
        """Send a DRI-framed message (server → client).
        ENQ → wait ACK → SOH+header+HCS → wait ACK → STX+data+ETX+CKS+EOT → wait ACK"""
        # Send ENQ
        self.send_byte(ENQ)

        # Wait for ACK
        b = self.recv_byte(timeout=5.0)
        if b is None or (b & 0x7F) != ACK:
            print(f"  No ACK after ENQ (got {b})")
            return False

        # Send SOH + 5 header bytes
        self.send_byte(SOH)
        hcs = SOH
        for byte in hdr[:5]:
            self.send_byte(byte)
            hcs = (hcs + byte) & 0xFF
        # Send HCS (two's complement)
        self.send_byte((-hcs) & 0xFF)

        # Wait for ACK
        b = self.recv_byte(timeout=5.0)
        if b is None or (b & 0x7F) != ACK:
            print(f"  No ACK after header (got {b})")
            return False

        # Send STX + data + ETX
        self.send_byte(STX)
        cks = STX
        for byte in payload:
            self.send_byte(byte)
            cks = (cks + byte) & 0xFF
        self.send_byte(ETX)
        cks = (cks + ETX) & 0xFF
        # Send CKS (two's complement)
        cks_byte = (-cks) & 0xFF
        self.send_byte(cks_byte)
        # Account for CKS byte in the running sum for Net$out compatibility
        # Actually, the DRI protocol sends CKS via Net$out which also updates D,
        # but the receiver checks that the total sum is 0, so we just send the
        # two's complement and then EOT.
        self.send_byte(EOT)

        # Wait for final ACK
        b = self.recv_byte(timeout=5.0)
        if b is None or (b & 0x7F) != ACK:
            print(f"  No ACK after data (got {b})")
            return False

        return True

    def recv_frame(self):
        """Receive a DRI-framed message (client → server).
        Wait for ENQ → send ACK → receive SOH+header+HCS → send ACK/NAK →
        receive STX+data+ETX+CKS+EOT → send ACK/NAK.
        Returns (hdr, payload) or None."""
        # Wait for ENQ (no timeout — client may not send for a long time)
        byte_count = 0
        while True:
            b = self.recv_byte(timeout=None)
            if b is None:
                return None
            byte_count += 1
            if b == ENQ:
                break
            if byte_count <= 50:
                ch = chr(b) if 0x20 <= b < 0x7F else '.'
                print(f"  rx[{byte_count}]: 0x{b:02X} '{ch}' (waiting for ENQ)")
            elif byte_count == 51:
                print(f"  ... (suppressing further non-ENQ bytes)")

        # Got ENQ, send ACK
        self.send_byte(ACK)

        # Receive SOH
        b = self.recv_byte(timeout=5.0)
        if b is None or (b & 0x7F) != SOH:
            print(f"  Expected SOH, got {b}")
            return None
        hcs = b & 0x7F  # Init HCS with SOH

        # Receive 5 header bytes
        hdr_data = self.recv_bytes(5, timeout=5.0)
        if hdr_data is None:
            print("  Timeout receiving header")
            return None
        for byte in hdr_data:
            hcs = (hcs + byte) & 0xFF

        # Receive HCS
        b = self.recv_byte(timeout=5.0)
        if b is None:
            print("  Timeout receiving HCS")
            return None
        hcs = (hcs + b) & 0xFF
        if hcs != 0:
            print(f"  Header checksum error: {hcs:02X}")
            self.send_byte(NAK)
            return None

        # Header OK, send ACK
        self.send_byte(ACK)

        # Receive STX
        b = self.recv_byte(timeout=5.0)
        if b is None or (b & 0x7F) != STX:
            print(f"  Expected STX, got {b}")
            return None
        cks = b & 0x7F  # Init CKS with STX

        # Get payload length from SIZ field (header byte 4)
        siz = hdr_data[4]
        payload_len = siz + 1  # 0 means 1 byte

        # Receive data bytes
        payload = self.recv_bytes(payload_len, timeout=5.0)
        if payload is None:
            print("  Timeout receiving payload")
            return None
        for byte in payload:
            cks = (cks + byte) & 0xFF

        # Receive ETX
        b = self.recv_byte(timeout=5.0)
        if b is None or (b & 0x7F) != ETX:
            print(f"  Expected ETX, got {b}")
            return None
        cks = (cks + (b & 0x7F)) & 0xFF

        # Receive CKS
        b = self.recv_byte(timeout=5.0)
        if b is None:
            print("  Timeout receiving CKS")
            return None
        cks = (cks + b) & 0xFF

        # Receive EOT
        b = self.recv_byte(timeout=5.0)
        if b is None or (b & 0x7F) != EOT:
            print(f"  Expected EOT, got {b}")
            return None

        # Verify checksum
        if cks != 0:
            print(f"  Data checksum error: {cks:02X}")
            self.send_byte(NAK)
            return None

        # All OK, send ACK
        self.send_byte(ACK)
        return (hdr_data, payload)

    def close(self):
        if self.sock:
            self.sock.close()
            self.sock = None


class CPNetServer:
    """CP/NET server handling BDOS function requests."""

    def __init__(self, conn, drive_dirs, server_node=0, client_node=1,
                 error_file=None, printer_file=None):
        self.conn = conn
        self.drive_dirs = drive_dirs  # {drive_index: host_path}
        self.server_node = server_node
        self.client_node = client_node
        self.open_files = {}  # {(user, name): file_handle_info}
        self.dma = bytearray(128)
        self.search_state = None
        self.error_file = error_file      # path to write unhandled-call errors
        self.printer_file = printer_file  # path to collect LST: output

    def run(self):
        """Main server loop."""
        print("CP/NET server running. Waiting for requests...")
        print("  (waiting for CPNETLDR to send init...)")
        while True:
            try:
                result = self.conn.recv_frame()
                if result is None:
                    print("Frame error (CRC/timeout), retrying...")
                    continue
                hdr, payload = result
                self.handle_request(hdr, payload)
            except ConnectionError as e:
                print(f"Connection closed: {e}")
                break
            except KeyboardInterrupt:
                print("\nShutdown requested")
                break

    def handle_request(self, hdr, payload):
        """Dispatch a CP/NET request."""
        fmt, did, sid, fnc, siz = hdr[0], hdr[1], hdr[2], hdr[3], hdr[4]

        if fnc == FUNC_NETWORK_INIT:
            self.handle_init(sid)
            return

        if fnc == FUNC_NETWORK_DOWN:
            print(f"Client {sid} shutdown")
            return

        print(f"BDOS F{fnc}: DID={did:02X} SID={sid:02X} "
              f"SIZ={siz+1} data={payload[:16].hex()}")

        # Dispatch to handler
        handler = self.handlers.get(fnc)
        if handler:
            resp_data = handler(self, payload)
        else:
            msg = f"UNHANDLED_BDOS_F{fnc}"
            print(f"  ERROR: {msg} — returning 0xFF", flush=True)
            if self.error_file:
                with open(self.error_file, 'a') as ef:
                    ef.write(msg + "\n")
            resp_data = bytes([0xFF])

        # Send response (FMT=1 for responses, per DRI server convention)
        resp_hdr = bytes([1, sid, self.server_node, fnc,
                          (len(resp_data) - 1) & 0xFF])
        self.conn.send_frame(resp_hdr, resp_data)

    def handle_init(self, client_sid):
        """Handle network initialization (FNC=FFh)."""
        self.client_node = client_sid if client_sid else 1
        print(f"Network init: client={self.client_node}, "
              f"server={self.server_node}")

        # Response: FMT=0, DID=client, SID=server, FNC=0, SIZ=1
        # Payload: [client_node, server_node]
        resp_hdr = bytes([0, self.client_node, self.server_node, 0, 1])
        resp_data = bytes([self.client_node, self.server_node])
        self.conn.send_frame(resp_hdr, resp_data)
        print(f"  Assigned node IDs: client={self.client_node}, "
              f"server={self.server_node}")

    def _resolve_path(self, drive, name):
        """Resolve a CP/M filename to a host path."""
        drive_dir = self.drive_dirs.get(drive)
        if not drive_dir:
            return None
        # CP/M filename: 8.3 format, space-padded
        fname = name[:8].rstrip().decode('ascii', errors='replace')
        ext = name[8:11].rstrip().decode('ascii', errors='replace')
        if ext:
            return os.path.join(drive_dir, f"{fname}.{ext}")
        return os.path.join(drive_dir, fname)

    def _fcb_name(self, payload, offset=0):
        """Extract 8+3 filename from FCB in payload.
        Strips high bits (CP/M uses bit 7 for file attributes)."""
        raw = payload[offset+1:offset+12]
        return bytes(b & 0x7F for b in raw)

    def _fcb_drive(self, payload, offset=0):
        """Extract drive number from FCB (0=default, 1=A, 2=B, ...).
        Returns 0-based drive index (0=A, 1=B, ...) to match drive_dirs keys."""
        d = payload[offset] & 0x0F
        return d - 1 if d > 0 else 0

    def handle_open(self, payload):
        """BDOS 15: Open file.
        Payload format: user(1) + drive(1) + FCB[1..35](35) + DMA(8).
        Response: retcode(1) + drive(1) + FCB[1..32](32) = 34 bytes.
        NDOS GTFCCR: extracts retcode, skips drive, copies 32 bytes to FCB[1..32]."""
        drive = self._fcb_drive(payload, offset=1)
        name = self._fcb_name(payload, offset=1)
        print(f"  Open: drive={drive} name={name[:11]} payload[0:4]={payload[:4].hex()}")
        path = self._resolve_path(drive, name)
        if path and os.path.exists(path):
            size = os.path.getsize(path)
            records = (size + 127) // 128
            print(f"  Open OK: {path} ({records} records)")
            # Response: retcode + FCB[0..32]
            resp = bytearray(34)
            resp[0] = 0  # return code (success)
            resp[1] = (drive + 1) & 0xFF  # FCB[0] = drive (1-based)
            resp[2:13] = name[:11]  # FCB[1..11] = name + ext
            resp[13] = 0  # FCB[12] = EX
            resp[14] = 0  # FCB[13] = S1
            resp[15] = 0  # FCB[14] = S2
            resp[16] = min(records, 128)  # FCB[15] = RC
            # resp[17..32] = allocation map (zeros)
            resp[33] = 0  # FCB[32] = CR
            return bytes(resp)
        print(f"  Open failed: {path}")
        return bytes([0xFF])  # File not found

    def handle_close(self, payload):
        """BDOS 16: Close file."""
        return bytes([0])  # Success

    def handle_search_first(self, payload):
        """BDOS 17: Search for first matching file.
        Payload format: skip(1) + user(1) + FCB(36 bytes)."""
        drive = self._fcb_drive(payload, offset=2)
        name = self._fcb_name(payload, offset=2)
        drive_dir = self.drive_dirs.get(drive)
        print(f"  Search first: drive={drive} ({chr(ord('A')+drive)}:) "
              f"pattern={name[:11]} dir={drive_dir}")
        if not drive_dir:
            print(f"  No mapping for drive {drive}")
            return bytes([0xFF])

        # Build list of matching files
        pattern_name = name[:8].decode('ascii', errors='replace').rstrip()
        pattern_ext = name[8:11].decode('ascii', errors='replace').rstrip()

        matches = []
        try:
            for entry in os.listdir(drive_dir):
                parts = entry.rsplit('.', 1)
                fname = parts[0].upper()[:8]
                fext = parts[1].upper()[:3] if len(parts) > 1 else ''

                if self._match_pattern(pattern_name, fname) and \
                   self._match_pattern(pattern_ext, fext):
                    matches.append(entry)
        except OSError:
            pass

        self.search_state = {'matches': matches, 'index': 0, 'drive': drive}
        return self._search_result()

    def handle_search_next(self, payload):
        """BDOS 18: Search for next matching file."""
        if not self.search_state:
            return bytes([0xFF])
        return self._search_result()

    def _search_result(self):
        """Return next search result as directory entry."""
        if not self.search_state:
            return bytes([0xFF])

        matches = self.search_state['matches']
        idx = self.search_state['index']
        drive = self.search_state['drive']

        if idx >= len(matches):
            self.search_state = None
            return bytes([0xFF])

        entry = matches[idx]
        self.search_state['index'] = idx + 1

        # Build 32-byte directory entry
        direntry = bytearray(32)
        direntry[0] = 0  # User number

        parts = entry.rsplit('.', 1)
        fname = parts[0].upper()[:8].ljust(8)
        fext = (parts[1].upper()[:3] if len(parts) > 1 else '').ljust(3)

        direntry[1:9] = fname.encode('ascii')
        direntry[9:12] = fext.encode('ascii')

        # Calculate size
        drive_dir = self.drive_dirs.get(drive, '.')
        path = os.path.join(drive_dir, entry)
        try:
            size = os.path.getsize(path)
            records = (size + 127) // 128
        except OSError:
            records = 0

        direntry[12] = 0  # EX
        direntry[15] = min(records, 128)  # RC

        print(f"  Search result: {fname}.{fext} ({records} records)")

        # Return: directory code (0-3) + 32-byte entry
        resp = bytearray(33)
        resp[0] = 0  # directory code
        resp[1:33] = direntry
        return bytes(resp)

    def _match_pattern(self, pattern, name):
        """Match CP/M wildcard pattern (? matches any char)."""
        pattern = pattern.upper()
        name = name.upper()
        if not pattern or pattern == '?' * len(pattern):
            return True  # All wildcards
        # Pad to same length
        maxlen = max(len(pattern), len(name))
        pattern = pattern.ljust(maxlen)
        name = name.ljust(maxlen)
        for p, n in zip(pattern, name):
            if p != '?' and p != n:
                return False
        return True

    def handle_read_seq(self, payload):
        """BDOS 20: Read sequential.
        Payload format: user(1) + drive(1) + FCB[1..35](35) = 37 bytes.
        Response: retcode(1) + drive+FCB[1..35](36) + data(128) = 165 bytes.
        NDOS GTFCCR copies resp[2..33] → FCB[1..32].
        NDOS GTOSCT copies resp[37..164] → DMA (128 bytes)."""
        drive = self._fcb_drive(payload, offset=1)
        name = self._fcb_name(payload, offset=1)
        # FCB fields: EX at payload[13] (user+drive+FCB[1..11]+EX), CR at payload[33]
        ex = payload[13] if len(payload) > 13 else 0
        cr = payload[33] if len(payload) > 33 else 0
        path = self._resolve_path(drive, name)
        print(f"  Read seq: drive={drive} name={name[:11]} ex={ex} cr={cr}")
        if not path:
            return bytes([0xFF])

        record = ex * 128 + cr
        offset = record * 128

        try:
            with open(path, 'rb') as f:
                f.seek(offset)
                data = f.read(128)
                if not data:
                    print(f"  Read seq: EOF at record {record}")
                    return bytes([1])  # EOF
                data = data.ljust(128, b'\x1A')
                print(f"  Read seq: OK, record {record}")

                # Advance CR
                cr += 1
                if cr >= 128:
                    cr = 0
                    ex += 1

                # Build response: retcode + drive+FCB[1..35] + sector_data
                resp = bytearray(165)
                resp[0] = 0  # return code
                # Echo drive + FCB[1..35] from payload (skip user byte)
                fcb_data = payload[1:37]  # drive + FCB[1..35]
                resp[1:1+len(fcb_data)] = fcb_data
                # Update EX and CR in response
                resp[13] = ex   # FCB[12] = EX (at resp offset 1+12=13)
                resp[33] = cr   # FCB[32] = CR (at resp offset 1+32=33)
                # Sector data at offset 37
                resp[37:165] = data
                return bytes(resp)
        except OSError:
            return bytes([0xFF])

    def handle_read_rand(self, payload):
        """BDOS 33: Read random.
        Payload format: user(1) + drive(1) + FCB[1..35](35).
        Response: retcode(1) + drive+FCB[1..35](36) + data(128) = 165 bytes.
        NDOS uses GTFCCR which copies resp[2..33] → FCB[1..32], so the full
        FCB must be echoed back (same format as handle_read_seq).  Returning
        only retcode+data (129 bytes) causes NDOS to overwrite the FCB name
        field with the first 32 bytes of file data, corrupting all subsequent
        calls that use the same FCB."""
        drive = self._fcb_drive(payload, offset=1)
        name = self._fcb_name(payload, offset=1)
        path = self._resolve_path(drive, name)
        if not path:
            return bytes([0xFF])

        # Random record number: FCB[33..35] = payload[34..36] (with +1 for user byte)
        if len(payload) < 37:
            return bytes([0xFF])
        rec = payload[34] | (payload[35] << 8) | (payload[36] << 16)
        offset = rec * 128

        try:
            with open(path, 'rb') as f:
                f.seek(offset)
                data = f.read(128)
                if not data:
                    return bytes([6])  # Seek past end
                data = data.ljust(128, b'\x1A')
                print(f"  Read rand: OK, record {rec}")

                # Update EX and CR to reflect sequential position for this record
                cr = rec % 128
                ex = (rec // 128) % 32

                # Build response: retcode + drive+FCB[1..35] + sector_data (165 bytes)
                resp = bytearray(165)
                resp[0] = 0  # return code
                fcb_data = payload[1:37]  # drive + FCB[1..35]
                resp[1:1+len(fcb_data)] = fcb_data
                resp[13] = ex   # FCB[12] = EX
                resp[33] = cr   # FCB[32] = CR
                resp[37:165] = data
                return bytes(resp)
        except OSError:
            return bytes([0xFF])

    def handle_get_user(self, payload):
        """BDOS 32: Get/set user number."""
        # Return user 0
        return bytes([0])

    def handle_get_login_vector(self, payload):
        """BDOS 24: Get login vector.
        Returns a 16-bit vector where bit N=1 means drive N is logged in.
        NDOS calls this for each remote server to check which drives are active.
        We report all drives we serve as logged in."""
        print(f"  Get login vector")
        return bytes([0xFF, 0xFF])  # All drives logged in

    def handle_list_output(self, payload):
        """BDOS 5: List output — character to network list device (printer).
        Forwarded by NDOS when LST: is assigned to a network server.
        Characters are collected in printer_file (if set) for review after
        MAME exits."""
        ch = payload[0] if payload else 0
        if self.printer_file:
            with open(self.printer_file, 'ab') as pf:
                pf.write(bytes([ch]))
        return bytes([0])  # Success

    def handle_network_login(self, payload):
        """BDOS 64: Network login."""
        print(f"  Network login request")
        return bytes([0])  # Success

    def handle_network_logoff(self, payload):
        """BDOS 65: Network logoff."""
        print(f"  Network logoff request")
        return bytes([0])  # Success

    def handle_get_server_cfg(self, payload):
        """BDOS 71: Get server config. NDOS copies 23 bytes into its CURSCF buffer."""
        print(f"  Get server config")
        return bytes(23)  # 23 zero bytes — minimal server config

    def handle_reset_drive(self, payload):
        """BDOS 37: Reset drive."""
        return bytes([0])  # Success

    def handle_access_drive(self, payload):
        """BDOS 38: Access drive."""
        return bytes([0])  # Success

    def handle_free_drive(self, payload):
        """BDOS 39: Free drive (release network drive access).
        Returns just a success code."""
        return bytes([0])

    def handle_get_dpb(self, payload):
        """BDOS 31: Get disk parameter block."""
        # Return a minimal DPB (17 bytes)
        dpb = bytearray(17)
        dpb[0:2] = (72).to_bytes(2, 'little')   # SPT (sectors per track)
        dpb[2] = 4                                # BSH (block shift)
        dpb[3] = 15                               # BLM (block mask)
        dpb[4] = 1                                # EXM (extent mask)
        dpb[5:7] = (242).to_bytes(2, 'little')   # DSM (max block number)
        dpb[7:9] = (63).to_bytes(2, 'little')    # DRM (max directory entries - 1)
        dpb[9] = 0xC0                             # AL0
        dpb[10] = 0x00                            # AL1
        dpb[11:13] = (16).to_bytes(2, 'little')  # CKS (checksum vector size)
        dpb[13:15] = (2).to_bytes(2, 'little')   # OFF (tracks offset)
        return bytes([0]) + bytes(dpb)

    def handle_set_dma(self, payload):
        """BDOS 26: Set DMA address (server-side, just acknowledge)."""
        return bytes([0])

    def handle_network_status(self, payload):
        """BDOS 70: CP/NET network status.
        Returns network status byte (0 = OK)."""
        print(f"  Network status request")
        return bytes([0])

    def handle_select_disk(self, payload):
        """BDOS 14: Select disk.
        Payload byte 0 = drive number (0=A, 1=B, ...).
        Returns 0 on success."""
        drive = payload[0] if payload else 0
        print(f"  Select disk {chr(ord('A') + drive)}:")
        return bytes([0])

    def handle_reset_disk(self, payload):
        """BDOS 13: Reset disk system."""
        print(f"  Reset disk system")
        return bytes([0])

    def handle_ret_current(self, payload):
        """BDOS 25: Return current disk."""
        return bytes([0])  # Drive A

    def handle_delete(self, payload):
        """BDOS 19: Delete file."""
        drive = self._fcb_drive(payload, offset=1)
        name = self._fcb_name(payload, offset=1)
        path = self._resolve_path(drive, name)
        if path and os.path.exists(path):
            try:
                os.remove(path)
                print(f"  Delete: {path}")
                return bytes([0])
            except OSError as e:
                print(f"  Delete failed: {e}")
        return bytes([0xFF])

    def handle_make_file(self, payload):
        """BDOS 22: Make (create) file.
        Payload format: user(1) + drive(1) + FCB[1..35](35) + DMA(8)."""
        drive = self._fcb_drive(payload, offset=1)
        name = self._fcb_name(payload, offset=1)
        path = self._resolve_path(drive, name)
        if not path:
            return bytes([0xFF])
        try:
            open(path, 'ab').close()  # Create if not exists
            print(f"  Make: {path}")
            resp = bytearray(payload[:33])
            resp[0] = 0  # directory code (success)
            resp[12] = 0  # EX
            resp[13] = 0  # S1
            resp[14] = 0  # S2
            resp[15] = 0  # RC
            if len(resp) > 32:
                resp[32] = 0  # CR
            return bytes(resp)
        except OSError as e:
            print(f"  Make failed: {e}")
            return bytes([0xFF])

    def handle_rename(self, payload):
        """BDOS 23: Rename file.
        Payload: user(1) + drive(1) + FCB[1..11](11) + FCB[12..15](4) +
                 FCB[16](1) + FCB[17..27](11) = 29+ bytes.
        New name is at payload offset 18 (user+drive+old11+extent4+newdrive1)."""
        drive = self._fcb_drive(payload, offset=1)
        old_name = bytes(b & 0x7F for b in payload[2:13])   # FCB[1..11]
        new_name = bytes(b & 0x7F for b in payload[18:29])  # FCB[17..27]
        old_path = self._resolve_path(drive, old_name)
        new_path = self._resolve_path(drive, new_name)
        if not old_path or not new_path:
            return bytes([0xFF])
        try:
            os.rename(old_path, new_path)
            print(f"  Rename: {os.path.basename(old_path)} -> {os.path.basename(new_path)}")
            return bytes([0])
        except OSError as e:
            print(f"  Rename failed: {e}")
            return bytes([0xFF])

    def handle_set_rec(self, payload):
        """BDOS 36: Set random record (no-op for sequential access)."""
        return bytes([0])

    def handle_write_seq(self, payload):
        """BDOS 21: Write sequential.
        Payload format: user(1) + drive(1) + FCB[1..35](35) + DMA(128)."""
        drive = self._fcb_drive(payload, offset=1)
        name = self._fcb_name(payload, offset=1)
        path = self._resolve_path(drive, name)
        if not path:
            return bytes([0xFF])

        # FCB fields with user+drive prefix: EX at [13], CR at [33]
        ex = payload[13] if len(payload) > 13 else 0
        cr = payload[33] if len(payload) > 33 else 0
        record = ex * 128 + cr
        offset = record * 128

        # DMA data (128 bytes) follows user+drive+FCB[1..35] = 37 bytes
        data_start = 37
        if len(payload) < data_start + 128:
            print(f"  Write seq: insufficient data ({len(payload)} bytes, need {data_start + 128})")
            return bytes([0xFF])

        data = payload[data_start:data_start + 128]

        try:
            with open(path, 'r+b' if os.path.exists(path) else 'wb') as f:
                f.seek(offset)
                f.write(data)
            print(f"  Write: {path} record {record}")

            # Advance CR in response
            cr += 1
            if cr >= 128:
                cr = 0
                ex += 1

            # Return updated FCB (drive + FCB[1..35])
            fcb_copy = bytearray(payload[1:37])  # skip user, keep drive+FCB
            fcb_copy[12] = ex  # EX
            if len(fcb_copy) > 32:
                fcb_copy[32] = cr  # CR
            return bytes([0]) + bytes(fcb_copy)
        except OSError as e:
            print(f"  Write failed: {e}")
            return bytes([0xFF])

    def handle_file_size(self, payload):
        """BDOS 35: Compute file size.
        Payload format: user(1) + drive(1) + FCB[1..35](35).
        Response: retcode(1) + drive+FCB[1..35](36) = 37 bytes, with
        r0,r1,r2 (FCB[33,34,35] = resp[34,35,36]) set to total 128-byte records."""
        drive = self._fcb_drive(payload, offset=1)
        name = self._fcb_name(payload, offset=1)
        path = self._resolve_path(drive, name)
        if not path or not os.path.exists(path):
            return bytes([0xFF])

        size = os.path.getsize(path)
        records = (size + 127) // 128
        print(f"  File size: {path} = {records} records")

        # Echo back drive+FCB[1..35], then overwrite r0,r1,r2
        resp = bytearray(37)  # retcode + drive + FCB[1..35]
        resp[0] = 0  # success
        src = payload[1:37]
        resp[1:1+len(src)] = src
        # r0,r1,r2 are at FCB[33,34,35] = resp[34,35,36]
        resp[34] = records & 0xFF
        resp[35] = (records >> 8) & 0xFF
        resp[36] = (records >> 16) & 0xFF
        return bytes(resp)

    def handle_get_alloc(self, payload):
        """BDOS 27: Get allocation vector address.
        Returns success (allocation info is local to BDOS)."""
        return bytes([0])

    def handle_get_ro(self, payload):
        """BDOS 29: Get read-only vector. Returns 0 (no R/O drives)."""
        return bytes([0, 0])

    def handle_write_prot(self, payload):
        """BDOS 28: Write protect disk. No-op — server drives are always writable."""
        return bytes([0])

    def handle_set_attrs(self, payload):
        """BDOS 30: Set file attributes (R/O, SYS, Archive). No-op on host."""
        drive = self._fcb_drive(payload, offset=1)
        name = self._fcb_name(payload, offset=1)
        print(f"  Set attrs: drive={drive} name={name[:11]} (no-op)")
        return bytes([0])

    def handle_write_rand(self, payload):
        """BDOS 34: Write random.
        Payload format: user(1) + drive(1) + FCB[1..35](35) + DMA(128).
        Response: retcode(1) + drive+FCB[1..35](36) = 37 bytes."""
        drive = self._fcb_drive(payload, offset=1)
        name = self._fcb_name(payload, offset=1)
        path = self._resolve_path(drive, name)
        if not path:
            return bytes([0xFF])

        if len(payload) < 37:
            return bytes([0xFF])
        rec = payload[34] | (payload[35] << 8) | (payload[36] << 16)
        offset = rec * 128

        data_start = 37
        if len(payload) < data_start + 128:
            print(f"  Write rand: insufficient data ({len(payload)} bytes)")
            return bytes([0xFF])
        data = payload[data_start:data_start + 128]

        try:
            mode = 'r+b' if os.path.exists(path) else 'wb'
            with open(path, mode) as f:
                f.seek(offset)
                f.write(data)
            print(f"  Write rand: {path} record {rec}")

            cr = rec % 128
            ex = (rec // 128) % 32
            resp = bytearray(37)
            resp[0] = 0
            fcb_data = payload[1:37]
            resp[1:1+len(fcb_data)] = fcb_data
            resp[13] = ex
            resp[33] = cr
            return bytes(resp)
        except OSError as e:
            print(f"  Write rand failed: {e}")
            return bytes([0xFF])

    def handle_write_rand_zf(self, payload):
        """BDOS 40: Write random with zero fill.
        Same as F34 but the server fills any unwritten gap with zeros."""
        drive = self._fcb_drive(payload, offset=1)
        name = self._fcb_name(payload, offset=1)
        path = self._resolve_path(drive, name)
        if not path:
            return bytes([0xFF])

        if len(payload) < 37:
            return bytes([0xFF])
        rec = payload[34] | (payload[35] << 8) | (payload[36] << 16)
        offset = rec * 128

        data_start = 37
        if len(payload) < data_start + 128:
            return bytes([0xFF])
        data = payload[data_start:data_start + 128]

        try:
            mode = 'r+b' if os.path.exists(path) else 'wb'
            with open(path, mode) as f:
                cur_size = f.seek(0, 2)  # seek to end
                if offset > cur_size:
                    f.write(b'\x00' * (offset - cur_size))  # zero fill
                f.seek(offset)
                f.write(data)
            print(f"  Write rand ZF: {path} record {rec}")

            cr = rec % 128
            ex = (rec // 128) % 32
            resp = bytearray(37)
            resp[0] = 0
            fcb_data = payload[1:37]
            resp[1:1+len(fcb_data)] = fcb_data
            resp[13] = ex
            resp[33] = cr
            return bytes(resp)
        except OSError as e:
            print(f"  Write rand ZF failed: {e}")
            return bytes([0xFF])

    # Handler dispatch table
    handlers = {
        FUNC_RESET_DISK: handle_reset_disk,
        FUNC_SELECT_DISK: handle_select_disk,
        FUNC_OPEN_FILE: handle_open,
        FUNC_CLOSE_FILE: handle_close,
        FUNC_SEARCH_FIRST: handle_search_first,
        FUNC_SEARCH_NEXT: handle_search_next,
        FUNC_DELETE_FILE: handle_delete,
        FUNC_RENAME_FILE: handle_rename,
        FUNC_READ_SEQ: handle_read_seq,
        FUNC_WRITE_SEQ: handle_write_seq,
        FUNC_MAKE_FILE: handle_make_file,
        FUNC_SET_REC: handle_set_rec,
        FUNC_RET_CURRENT: handle_ret_current,
        FUNC_SET_DMA: handle_set_dma,
        FUNC_GET_ALLOC: handle_get_alloc,
        FUNC_GET_RO: handle_get_ro,
        FUNC_WRITE_PROT: handle_write_prot,
        FUNC_SET_ATTRS: handle_set_attrs,
        FUNC_GET_DPB: handle_get_dpb,
        FUNC_WRITE_RAND: handle_write_rand,
        FUNC_WRITE_RAND_ZF: handle_write_rand_zf,
        FUNC_GET_USER: handle_get_user,
        FUNC_READ_RAND: handle_read_rand,
        FUNC_FILE_SIZE: handle_file_size,
        FUNC_RESET_DRIVE: handle_reset_drive,
        FUNC_ACCESS_DRIVE: handle_access_drive,
        FUNC_FREE_DRIVE: handle_free_drive,
        FUNC_GET_LOGIN_VECTOR: handle_get_login_vector,
        FUNC_LIST_OUTPUT: handle_list_output,
        FUNC_NETWORK_LOGIN: handle_network_login,
        FUNC_NETWORK_LOGOFF: handle_network_logoff,
        FUNC_NETWORK_STATUS: handle_network_status,
        FUNC_GET_SERVER_CFG: handle_get_server_cfg,
    }


def send_hex_files(sock, hex_dir):
    """Send all CP/NET hex files over the serial connection.

    CP/M reads each file via 'PIP FILENAME.HEX=RDR:'.  Each file is
    terminated with ^Z (0x1A) so PIP closes it and returns to the prompt.
    The BIOS ring buffer + RTS flow control throttle the send rate to match
    CP/M's consumption speed at 38400 baud.

    Files are sent in the order that autotest.lua issues PIP commands.
    """
    # GO.SUB: CP/M SUBMIT batch — PIPs each hex file from RDR:, LOADs it,
    # renames the SPR modules, and finally runs CPNETLDR.
    # SUBMIT reads commands from a file, so it bypasses the 16-byte BIOS
    # keyboard ring buffer that would overflow if we typed all commands at once.
    # PIP inside SUBMIT reads from READER (BDOS fn 3), not from the console,
    # so SUBMIT's console-redirection does not interfere with PIP RDR:.
    # The hex files must be sent in the same order the PIP commands appear here.
    go_sub = (
        b'PIP CHKSUM.HEX=RDR:\r'
        b'LOAD CHKSUM\r'
        b'PIP CPNETLDR.HEX=RDR:\r'
        b'LOAD CPNETLDR\r'
        b'PIP NETWORK.HEX=RDR:\r'
        b'LOAD NETWORK\r'
        b'PIP CCP.HEX=RDR:\r'
        b'LOAD CCP\r'
        b'REN CCP.SPR=CCP.COM\r'
        b'PIP SNIOS.HEX=RDR:\r'
        b'LOAD SNIOS\r'
        b'REN SNIOS.SPR=SNIOS.COM\r'
        b'PIP NDOS.HEX=RDR:\r'
        b'LOAD NDOS\r'
        b'REN NDOS.SPR=NDOS.COM\r'
        b'CPNETLDR\r'
    )
    print(f"[transfer] Sending GO.SUB ({len(go_sub)} bytes)...")
    try:
        sock.sendall(go_sub)
        sock.sendall(b'\x1a')   # ^Z terminates PIP RDR: for this file
    except OSError as e:
        print(f"[transfer] Send error for GO.SUB: {e}")
        return
    total = len(go_sub) + 1
    print(f"[transfer] GO.SUB sent")

    FILE_ORDER = [
        'CHKSUM.HEX',
        'CPNETLDR.HEX',
        'NETWORK.HEX',
        'CCP.HEX',
        'SNIOS.HEX',
        'NDOS.HEX',
    ]
    for fname in FILE_ORDER:
        path = os.path.join(hex_dir, fname)
        if not os.path.exists(path):
            print(f"[transfer] WARNING: {path} not found, skipping")
            continue
        with open(path, 'rb') as f:
            data = f.read()
        print(f"[transfer] Sending {fname} ({len(data)} bytes)...")
        try:
            sock.sendall(data)
            sock.sendall(b'\x1a')   # ^Z terminates PIP RDR: for this file
        except OSError as e:
            print(f"[transfer] Send error for {fname}: {e}")
            return
        total += len(data) + 1
        print(f"[transfer] {fname} sent")
    print(f"[transfer] All files sent ({total} bytes total)")


def main():
    parser = argparse.ArgumentParser(description='CP/NET server for RC702')
    parser.add_argument('--host', default='localhost',
                        help='MAME null_modem host (default: localhost)')
    parser.add_argument('--port', type=int, default=4000,
                        help='MAME null_modem port (default: 4000)')
    parser.add_argument('--drive-dir', action='append', nargs=2,
                        metavar=('LETTER', 'DIR'),
                        help='Map drive letter to host directory '
                        '(e.g., --drive-dir H /tmp/cpnet)')
    parser.add_argument('--node', type=int, default=0,
                        help='Server node ID (default: 0)')
    parser.add_argument('--wait', action='store_true',
                        help='Wait for MAME to connect (listen mode)')
    parser.add_argument('--hex-dir', metavar='DIR',
                        help='Directory of .HEX files to send over serial '
                        'before CP/NET mode (for PIP RDR: file transfer)')
    parser.add_argument('--error-file', metavar='FILE',
                        help='Write unhandled BDOS function names to FILE '
                        '(for automated test failure detection)')
    parser.add_argument('--printer-file', metavar='FILE',
                        help='Collect LST: (BDOS F5) output to FILE')
    args = parser.parse_args()

    # Set up drive mappings
    drive_dirs = {}
    if args.drive_dir:
        for letter, dirpath in args.drive_dir:
            idx = ord(letter.upper()) - ord('A')
            drive_dirs[idx] = os.path.abspath(dirpath)
    else:
        # Default: map ALL drives (A-P) to current directory
        # so any 'network x:=y:' works regardless of drive letter
        for i in range(16):
            drive_dirs[i] = os.getcwd()

    print("CP/NET server for RC702 (DRI binary protocol)")
    print(f"Drive mappings:")
    for idx in sorted(drive_dirs):
        print(f"  {chr(ord('A') + idx)}: → {drive_dirs[idx]}")

    conn = SerialConnection(args.host, args.port)

    if args.wait:
        # Listen mode: wait for MAME to connect
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        srv.bind((args.host, args.port))
        srv.listen(1)
        print(f"Listening on {args.host}:{args.port}...")
        client_sock, addr = srv.accept()
        print(f"Connection from {addr}")
        conn.sock = client_sock
        conn.sock.settimeout(30.0)
        conn.monitor.start()
        srv.close()
    else:
        try:
            conn.connect()
        except ConnectionRefusedError:
            print(f"Cannot connect to {args.host}:{args.port}")
            print("Start MAME with null_modem first, or use --wait")
            return 1

    # If hex files are staged, stream them over serial immediately.
    # CP/M reads them via 'PIP FILENAME.HEX=RDR:' while the daemon thread
    # sends.  When all files are consumed, CPNETLDR runs and the main thread
    # (blocking in recv_frame()) picks up the CP/NET init frame.
    if args.hex_dir:
        hex_dir = os.path.abspath(args.hex_dir)
        print(f"[transfer] Hex dir: {hex_dir}")
        t = threading.Thread(target=send_hex_files, args=(conn.sock, hex_dir),
                             daemon=True)
        t.start()

    server = CPNetServer(conn, drive_dirs, server_node=args.node,
                         error_file=args.error_file,
                         printer_file=args.printer_file)

    try:
        server.run()
    finally:
        conn.close()

    return 0


if __name__ == '__main__':
    sys.exit(main())
