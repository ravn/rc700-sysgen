#!/usr/bin/env python3
"""TCP server for SIO-B serial console test.

MAME connects via -bitb2 "socket.localhost:PORT".
The server waits for the A> prompt, sends commands, captures output.
All received serial output is logged to a file for comparison with CRT.

Usage:
    python3 siob_console_server.py [port]
"""

import socket
import sys
import time

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 4324
COMMANDS = [
    b"DIR\r",
    b"ASM FILEX\r",
    b"TYPE FILEX.PRN\r",
]

def wait_for(conn, needle, timeout=30):
    """Read from socket until needle is found. Returns all data read."""
    buf = b""
    deadline = time.time() + timeout
    while time.time() < deadline:
        conn.settimeout(max(0.1, deadline - time.time()))
        try:
            chunk = conn.recv(4096)
            if not chunk:
                break
            buf += chunk
            text = buf.decode("ascii", errors="replace")
            if needle in text:
                return buf
        except socket.timeout:
            pass
    return buf

def main():
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(("127.0.0.1", PORT))
    srv.listen(1)
    print(f"[console] listening on port {PORT}")

    conn, addr = srv.accept()
    conn.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
    print(f"[console] MAME connected from {addr}")

    all_output = b""

    # Wait for initial boot banner + first A> prompt
    print("[console] waiting for first A> prompt...")
    data = wait_for(conn, "A>", timeout=60)
    all_output += data
    text = data.decode("ascii", errors="replace")
    print(f"[console] boot output ({len(data)} bytes):")
    for line in text.split("\r\n"):
        if line.strip():
            print(f"  {line.rstrip()}")

    # Send each command and capture output.
    # Each command: send, then wait for next "A>" prompt (disk I/O can be slow).
    for cmd in COMMANDS:
        cmd_str = cmd.decode().rstrip()
        time.sleep(0.5)  # let CCP settle after previous prompt
        print(f"[console] sending: {cmd_str}")
        conn.sendall(cmd)

        # Wait for next A> prompt (allow 60s for slow disk operations like ASM)
        data = wait_for(conn, "A>", timeout=60)
        all_output += data
        text = data.decode("ascii", errors="replace")
        print(f"[console] response ({len(data)} bytes):")
        for line in text.split("\r\n"):
            if line.strip():
                print(f"  {line.rstrip()}")

    # Write all serial output to file
    with open("/tmp/siob_console_serial.txt", "w") as f:
        f.write(all_output.decode("ascii", errors="replace"))
    print(f"[console] wrote {len(all_output)} bytes to /tmp/siob_console_serial.txt")

    # Signal Lua that we're done
    with open("/tmp/siob_console_done", "w") as f:
        f.write("done\n")

    # Keep socket open until MAME exits
    try:
        while True:
            d = conn.recv(1024)
            if not d:
                break
    except (ConnectionResetError, BrokenPipeError):
        pass
    conn.close()
    srv.close()
    print("[console] done")

if __name__ == "__main__":
    main()
