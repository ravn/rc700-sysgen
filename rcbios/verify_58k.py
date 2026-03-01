#!/usr/bin/env python3
"""Verify assembled 58K BIOS against reference binary.

58K BIOSes start at ORG E080h (boot entry at Track 0 offset 0x0380).
The binary is a straight disassembly starting at E080h.

Usage:
    python3 verify_58k.py zout/BIOS_58K.hex reference.bin
"""

import sys
import os


def hex_to_bin(hexfile):
    """Convert Intel HEX file to dict of addr->byte."""
    data = {}
    with open(hexfile) as f:
        for line in f:
            line = line.strip()
            if not line.startswith(':'):
                continue
            count = int(line[1:3], 16)
            addr = int(line[3:7], 16)
            rtype = int(line[7:9], 16)
            if rtype == 0:
                for i in range(count):
                    data[addr + i] = int(line[9 + i*2:11 + i*2], 16)
            elif rtype == 1:
                break
    return data


def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <hex_file> <ref_binary>")
        sys.exit(1)

    hexfile = sys.argv[1]
    reffile = sys.argv[2]

    if not os.path.exists(hexfile):
        print(f"Error: {hexfile} not found")
        sys.exit(1)
    if not os.path.exists(reffile):
        print(f"Error: {reffile} not found")
        sys.exit(1)

    hex_data = hex_to_bin(hexfile)
    ref = open(reffile, 'rb').read()

    base = 0xE080  # 58K boot entry address

    diffs = 0
    first_diffs = []
    compared = 0

    for i in range(len(ref)):
        addr = base + i
        if addr in hex_data:
            compared += 1
            if hex_data[addr] != ref[i]:
                diffs += 1
                if len(first_diffs) < 20:
                    first_diffs.append((addr, hex_data[addr], ref[i]))

    if diffs == 0:
        print(f"MATCH: {compared} bytes verified")
        sys.exit(0)
    else:
        print(f"MISMATCH: {diffs} differences in {compared} bytes")
        for addr, got, exp in first_diffs:
            print(f"  {addr:04X}: got {got:02X} expected {exp:02X}")
        if len(first_diffs) < diffs:
            print(f"  ... and {diffs - len(first_diffs)} more")
        sys.exit(1)


if __name__ == '__main__':
    main()
