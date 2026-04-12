#!/usr/bin/env python3
"""Dual-port server for BIOS deploy via serial.

SIO-B (console, port CONSOLE_PORT): sends CP/M commands, reads output.
SIO-A (data, port DATA_PORT): sends Intel HEX file for PIP to read.

Workflow:
  1. Wait for SIO-B console trigger (Lua detects boot + serial banner)
  2. Send "PIP CPM56.HEX=RDR:[H]\r" on SIO-B console
  3. Brief pause for PIP to start reading from RDR:
  4. Send cpm56.hex contents on SIO-A data port (byte-paced for RTS)
  5. Wait for SIO-B console A> prompt (PIP done)
  6. Send "LOAD CPM56\r" on SIO-B console, wait for A>
  7. Send "SYSGEN CPM56.COM\r" on SIO-B console, wait for prompt
  8. Send "A\r" (destination drive), wait for prompt
  9. Send "\r" (confirm), wait for "FUNCTION COMPLETE"
  10. Signal Lua "done" so it can hard_reset and verify banner

Usage:
    python3 siob_deploy_server.py <hex_file> [console_port] [data_port]
"""

import os
import socket
import sys
import time

CONSOLE_PORT = int(sys.argv[2]) if len(sys.argv) > 2 else 4324
DATA_PORT = int(sys.argv[3]) if len(sys.argv) > 3 else 4325


def wait_for(conn, needle, timeout=60):
    """Read from socket until needle found. Returns all data read."""
    buf = b""
    deadline = time.time() + timeout
    while time.time() < deadline:
        conn.settimeout(max(0.1, deadline - time.time()))
        try:
            chunk = conn.recv(4096)
            if not chunk:
                break
            buf += chunk
            if needle.encode() in buf:
                return buf
        except socket.timeout:
            pass
    return buf


def main():
    if len(sys.argv) < 2:
        print(f"usage: {sys.argv[0]} <hex_file> [console_port] [data_port]")
        return 1

    hex_path = sys.argv[1]
    hex_data = open(hex_path, "rb").read()
    print(f"[deploy] HEX file: {hex_path} ({len(hex_data)} bytes)")

    # Listen on both ports
    con_srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    con_srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    con_srv.bind(("127.0.0.1", CONSOLE_PORT))
    con_srv.listen(1)

    dat_srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    dat_srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    dat_srv.bind(("127.0.0.1", DATA_PORT))
    dat_srv.listen(1)

    print(f"[deploy] console port {CONSOLE_PORT}, data port {DATA_PORT}")

    # Accept MAME connections (bitb2 = console, bitb1 = data)
    print("[deploy] waiting for MAME connections...")
    con_conn, _ = con_srv.accept()
    con_conn.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    print("[deploy] SIO-B console connected")

    dat_conn, _ = dat_srv.accept()
    dat_conn.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    print("[deploy] SIO-A data connected")

    # Wait for trigger from Lua
    trigger = "/tmp/siob_deploy_trigger"
    print(f"[deploy] waiting for trigger {trigger}...")
    for _ in range(120):
        if os.path.exists(trigger):
            os.unlink(trigger)
            break
        time.sleep(0.5)
    else:
        print("[deploy] trigger timeout!")
        return 2
    print("[deploy] trigger received")

    # Drain boot output from console
    con_conn.settimeout(0.5)
    try:
        while True:
            con_conn.recv(4096)
    except socket.timeout:
        pass
    con_conn.settimeout(None)

    # Step 1: PIP CPM56.HEX=RDR:
    print("[deploy] sending: PIP CPM56.HEX=RDR:")
    time.sleep(0.3)
    con_conn.sendall(b"PIP CPM56.HEX=RDR:\r")

    # Brief pause for PIP to initialize and start reading from SIO-A
    time.sleep(1.0)

    # Step 2: Send HEX data on SIO-A data port (line by line with pacing)
    print(f"[deploy] sending {len(hex_data)} bytes of HEX on data port...")
    lines = hex_data.split(b"\n")
    for i, line in enumerate(lines):
        line = line.rstrip(b"\r")
        if not line:
            continue
        dat_conn.sendall(line + b"\r\n")
        # Pace: ~10ms per line to stay within ring buffer capacity
        time.sleep(0.01)
        if (i + 1) % 100 == 0:
            print(f"[deploy]   sent {i+1}/{len(lines)} lines")
    # Send ^Z to end PIP input
    dat_conn.sendall(b"\x1a")
    print("[deploy] HEX transfer complete, waiting for A>...")

    data = wait_for(con_conn, "A>", timeout=30)
    print(f"[deploy] PIP done ({len(data)} bytes response)")

    # Step 3: LOAD CPM56
    time.sleep(0.3)
    print("[deploy] sending: LOAD CPM56")
    con_conn.sendall(b"LOAD CPM56\r")
    data = wait_for(con_conn, "A>", timeout=30)
    print(f"[deploy] LOAD done ({len(data)} bytes)")

    # Step 4: SYSGEN CPM56.COM
    time.sleep(0.3)
    print("[deploy] sending: SYSGEN CPM56.COM")
    con_conn.sendall(b"SYSGEN CPM56.COM\r")
    data = wait_for(con_conn, "DESTINATION DRIVE", timeout=30)
    print(f"[deploy] SYSGEN ready for destination")

    time.sleep(0.3)
    con_conn.sendall(b"A\r")
    data = wait_for(con_conn, "DESTINATION ON A", timeout=10)

    time.sleep(0.3)
    con_conn.sendall(b"\r")
    data = wait_for(con_conn, "FUNCTION COMPLETE", timeout=30)
    print("[deploy] SYSGEN complete!")

    # Signal Lua
    with open("/tmp/siob_deploy_done", "w") as f:
        f.write("done\n")
    print("[deploy] signaled Lua, waiting for MAME to exit...")

    # Keep sockets open
    try:
        while True:
            d = con_conn.recv(1024)
            if not d:
                break
    except (ConnectionResetError, BrokenPipeError):
        pass

    con_conn.close()
    dat_conn.close()
    con_srv.close()
    dat_srv.close()
    print("[deploy] done")
    return 0


if __name__ == "__main__":
    sys.exit(main())
