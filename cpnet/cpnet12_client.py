#!/usr/bin/env python3
"""Minimal CP/NET 1.2 client for testing MP/M server connectivity.

Connects to TCP port (z80pack console port) and speaks DRI binary
serial protocol: ENQ/ACK/SOH/STX/ETX/EOT framing with two's complement
checksums.

Usage:
    python3 cpnet12_client.py [--port PORT] [--verbose]
"""

import argparse
import socket
import sys
import time

# DRI protocol control characters
SOH = 0x01
STX = 0x02
ETX = 0x03
EOT = 0x04
ENQ = 0x05
ACK = 0x06
NAK = 0x15


def checksum(data, init=0):
    """Two's complement checksum."""
    s = init
    for b in data:
        s = (s + b) & 0xFF
    return (-s) & 0xFF


class CPNetClient:
    def __init__(self, host, port, verbose=False):
        self.host = host
        self.port = port
        self.verbose = verbose
        self.sock = None
        self.slave_id = 0x01

    def log(self, msg):
        if self.verbose:
            print(f"  [{msg}]", file=sys.stderr)

    def connect(self):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.connect((self.host, self.port))
        self.sock.settimeout(5.0)
        print(f"Connected to {self.host}:{self.port}")

    def close(self):
        if self.sock:
            self.sock.close()
            self.sock = None

    def send_byte(self, b):
        self.log(f"TX: {b:02x}")
        self.sock.send(bytes([b]))

    def recv_byte(self, timeout=5.0):
        old_timeout = self.sock.gettimeout()
        self.sock.settimeout(timeout)
        try:
            data = self.sock.recv(1)
            if not data:
                raise ConnectionError("Connection closed")
            self.log(f"RX: {data[0]:02x}")
            return data[0]
        except socket.timeout:
            raise TimeoutError(f"No response after {timeout}s")
        finally:
            self.sock.settimeout(old_timeout)

    def wait_for_ack(self, label="ACK"):
        """Wait for ACK, return True if received."""
        try:
            b = self.recv_byte()
            if (b & 0x7F) == ACK:
                print(f"  Got {label}")
                return True
            else:
                print(f"  Expected ACK, got 0x{b:02x}")
                return False
        except TimeoutError:
            print(f"  Timeout waiting for {label}")
            return False

    def send_message(self, fmt, did, sid, fnc, siz, data):
        """Send a CP/NET message using DRI binary framing."""
        header = bytes([fmt, did, sid, fnc, siz])

        print(f"Sending: FMT={fmt:02x} DID={did:02x} SID={sid:02x} "
              f"FNC={fnc:02x} SIZ={siz:02x} data={data.hex()}")

        # Step 1: Send ENQ
        self.send_byte(ENQ)
        if not self.wait_for_ack("ACK (ENQ)"):
            return False

        # Step 2: Send SOH + header + HCS
        hdr_with_soh = bytes([SOH]) + header
        hcs = checksum(hdr_with_soh)
        for b in hdr_with_soh:
            self.send_byte(b)
        self.send_byte(hcs)
        if not self.wait_for_ack("ACK (header)"):
            return False

        # Step 3: Send STX + data + ETX + CKS + EOT
        data_block = bytes([STX]) + data + bytes([ETX])
        cks = checksum(data_block)
        for b in data_block:
            self.send_byte(b)
        self.send_byte(cks)
        self.send_byte(EOT)
        if not self.wait_for_ack("ACK (data)"):
            return False

        print("  Message sent OK")
        return True

    def recv_message(self):
        """Receive a CP/NET message using DRI binary framing."""
        print("Waiting for server response...")

        # Step 1: Wait for ENQ from server
        try:
            b = self.recv_byte(timeout=10.0)
        except TimeoutError:
            print("  Timeout waiting for server ENQ")
            return None

        if (b & 0x7F) != ENQ:
            print(f"  Expected ENQ, got 0x{b:02x}")
            return None

        # Step 2: Send ACK
        self.send_byte(ACK)

        # Step 3: Receive SOH + header + HCS
        b = self.recv_byte()
        if (b & 0x7F) != SOH:
            print(f"  Expected SOH, got 0x{b:02x}")
            return None

        cksum = SOH
        header = bytearray()
        for _ in range(5):
            b = self.recv_byte()
            header.append(b)
            cksum = (cksum + b) & 0xFF

        hcs = self.recv_byte()
        cksum = (cksum + hcs) & 0xFF
        if cksum != 0:
            print(f"  Bad header checksum: {cksum:02x}")
            self.send_byte(NAK)
            return None

        # Send ACK for header
        self.send_byte(ACK)

        # Step 4: Receive STX + data + ETX + CKS
        b = self.recv_byte()
        if (b & 0x7F) != STX:
            print(f"  Expected STX, got 0x{b:02x}")
            return None

        data_len = header[4] + 1  # SIZ + 1
        cksum = STX
        data = bytearray()
        for _ in range(data_len):
            b = self.recv_byte()
            data.append(b)
            cksum = (cksum + b) & 0xFF

        b = self.recv_byte()
        if (b & 0x7F) != ETX:
            print(f"  Expected ETX, got 0x{b:02x}")
            return None
        cksum = (cksum + ETX) & 0xFF

        cks = self.recv_byte()
        cksum = (cksum + cks) & 0xFF

        # Receive EOT
        b = self.recv_byte()
        if (b & 0x7F) != EOT:
            print(f"  Expected EOT, got 0x{b:02x}")
            return None

        if cksum != 0:
            print(f"  Bad data checksum: {cksum:02x}")
            self.send_byte(NAK)
            return None

        # Send ACK
        self.send_byte(ACK)

        fmt, did, sid, fnc, siz = header
        print(f"Received: FMT={fmt:02x} DID={did:02x} SID={sid:02x} "
              f"FNC={fnc:02x} SIZ={siz:02x} data={data.hex()}")
        return header, data

    def test_login(self):
        """Send FNC=64 (LOGIN) to MP/M server."""
        # LOGIN message: FMT=0, DID=0 (server), SID=slave_id, FNC=64, SIZ=7
        # Data: 8-byte password ("PASSWORD" matches netwrkif-2.asm configtbl)
        password = b'PASSWORD'
        if not self.send_message(0x00, 0x00, self.slave_id, 64,
                                 len(password) - 1, password):
            return False
        resp = self.recv_message()
        if resp:
            hdr, data = resp
            print(f"LOGIN response: {data.hex()}")
            return True
        return False

    def test_dir(self, drive=1):
        """Send FNC=17 (Search First) for *.* on given drive."""
        # Build FCB for *.*
        fcb = bytearray(36)
        fcb[0] = drive  # drive number (1=A:, 2=B:, etc.)
        for i in range(1, 12):
            fcb[i] = ord('?')  # wildcard
        if not self.send_message(0x00, 0x00, self.slave_id, 17,
                                 len(fcb) - 1, bytes(fcb)):
            return False
        resp = self.recv_message()
        if resp:
            hdr, data = resp
            print(f"DIR response ({len(data)} bytes): {data[:32].hex()}...")
            return True
        return False


def main():
    parser = argparse.ArgumentParser(description="CP/NET 1.2 test client")
    parser.add_argument("--host", default="localhost")
    parser.add_argument("--port", type=int, default=4002)
    parser.add_argument("--verbose", "-v", action="store_true")
    parser.add_argument("--test", choices=["enq", "login", "dir"],
                        default="enq",
                        help="Test to run (default: enq)")
    args = parser.parse_args()

    client = CPNetClient(args.host, args.port, args.verbose)

    try:
        client.connect()
        time.sleep(0.5)  # let server accept

        if args.test == "enq":
            print("\n--- ENQ/ACK test ---")
            print("Sending ENQ...")
            client.send_byte(ENQ)
            try:
                b = client.recv_byte(timeout=5.0)
                print(f"Got response: 0x{b:02x} "
                      f"({'ACK' if b == ACK else 'NOT ACK'})")
            except TimeoutError:
                print("No response to ENQ (timeout)")

        elif args.test == "login":
            print("\n--- LOGIN test ---")
            client.test_login()

        elif args.test == "dir":
            print("\n--- DIR test ---")
            client.test_dir(drive=1)

    except ConnectionError as e:
        print(f"Connection error: {e}")
    except KeyboardInterrupt:
        print("\nInterrupted")
    finally:
        client.close()


if __name__ == "__main__":
    main()
