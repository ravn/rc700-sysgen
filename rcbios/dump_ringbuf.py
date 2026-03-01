#!/usr/bin/env python3
"""Analyze ring buffer contents from MAME memory dump.

Usage:
  1. In MAME debugger, save memory around ring buffers:
       save /tmp/ringbuf.bin,F370,200
     (dumps F370-F56F, covering pointers + KBBUF + gap + RXBUF)

  2. Run this script:
       python3 /tmp/dump_ringbuf.py /tmp/ringbuf.bin

  Or use full 64K dump:
       python3 /tmp/dump_ringbuf.py /tmp/memdump.bin --base 0
"""
import sys, os

def main():
    if len(sys.argv) < 2:
        print("Usage: dump_ringbuf.py <memfile> [--base ADDR]")
        sys.exit(1)

    filename = sys.argv[1]
    base = 0xF370  # default: save /tmp/ringbuf.bin,F370,200

    if '--base' in sys.argv:
        idx = sys.argv.index('--base')
        base = int(sys.argv[idx + 1], 0)

    with open(filename, 'rb') as f:
        data = f.read()

    def byte_at(addr):
        off = addr - base
        if 0 <= off < len(data):
            return data[off]
        return None

    # Ring buffer pointer addresses (from BIOS.lst)
    RXHEAD = 0xF37B
    RXTAIL = 0xF37C
    KBHEAD = 0xF37D
    KBTAIL = 0xF37E
    KBBUF  = 0xF37F  # 16 bytes
    RXBUF  = 0xF400  # 256 bytes

    rxhead = byte_at(RXHEAD)
    rxtail = byte_at(RXTAIL)
    kbhead = byte_at(KBHEAD)
    kbtail = byte_at(KBTAIL)

    print("=== Ring Buffer Pointers ===")
    print(f"  RXHEAD (F37B) = {rxhead:#04x}  (SIO write position)")
    print(f"  RXTAIL (F37C) = {rxtail:#04x}  (SIO read position)")
    if rxhead is not None and rxtail is not None:
        pending = (rxhead - rxtail) & 0xFF
        print(f"  SIO pending bytes: {pending}")
    print(f"  KBHEAD (F37D) = {kbhead:#04x}  (keyboard write position)")
    print(f"  KBTAIL (F37E) = {kbtail:#04x}  (keyboard read position)")
    if kbhead is not None and kbtail is not None:
        kpending = (kbhead - kbtail) & 0x0F
        print(f"  Keyboard pending keys: {kpending}")

    print()
    print("=== Keyboard Ring Buffer (KBBUF F37F-F38E, 16 bytes) ===")
    kb_bytes = []
    for i in range(16):
        b = byte_at(KBBUF + i)
        kb_bytes.append(b)
    hex_line = ' '.join(f'{b:02x}' if b is not None else '??' for b in kb_bytes)
    asc_line = ''.join(chr(b) if b and 0x20 <= b < 0x7f else '.' for b in kb_bytes)
    print(f"  {hex_line}")
    print(f"  {asc_line}")
    if kbtail is not None:
        print(f"  tail={kbtail} head={kbhead}", end="")
        markers = []
        for i in range(16):
            if i == kbtail and i == kbhead:
                markers.append("T/H")
            elif i == kbtail:
                markers.append("T")
            elif i == kbhead:
                markers.append("H")
            else:
                markers.append(" ")
        print("  [" + "|".join(f"{m:>2s}" for m in markers) + "]")

    print()
    print("=== SIO Ring Buffer (RXBUF F400-F4FF, 256 bytes) ===")
    # Show in 16-byte rows
    for row in range(16):
        addr = RXBUF + row * 16
        row_bytes = [byte_at(addr + i) for i in range(16)]
        hex_str = ' '.join(f'{b:02x}' if b is not None else '??' for b in row_bytes)
        asc_str = ''.join(chr(b) if b and 0x20 <= b < 0x7f else '.' for b in row_bytes)
        # Mark head/tail positions
        marker = ""
        for i in range(16):
            pos = row * 16 + i
            if rxtail is not None and pos == rxtail:
                marker += f" TAIL@{pos}"
            if rxhead is not None and pos == rxhead:
                marker += f" HEAD@{pos}"
        print(f"  F4{row*16:02X}: {hex_str}  {asc_str}{marker}")

    # Show non-zero content summary
    if rxhead is not None and rxtail is not None:
        nonzero = sum(1 for i in range(256) if byte_at(RXBUF + i) not in (None, 0))
        print(f"\n  Non-zero bytes in RXBUF: {nonzero}/256")
        if rxhead == rxtail:
            print("  Buffer is empty (head == tail) — all data consumed by READER")
        elif pending > 0:
            print(f"  {pending} bytes unconsumed (tail={rxtail:#04x} to head={rxhead:#04x})")

if __name__ == '__main__':
    main()
