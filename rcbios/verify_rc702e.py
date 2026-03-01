#!/usr/bin/env python3
"""Verify assembled RC702E BIOS against reference binary.

RC702E BIOSes exist in two formats:
- MINI (rel.2.01): ORG D700, 5504 bytes
- RC703/QD (rel.2.20): ORG D480, 9600 bytes

Usage:
    python3 verify_rc702e.py zout/BIOS_E201.hex reference.bin --mini
    python3 verify_rc702e.py zout/BIOS_E220.hex reference.bin --qd
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
        print(f"Usage: {sys.argv[0]} <hex_file> <ref_binary> [--mini|--qd]")
        sys.exit(1)

    hexfile = sys.argv[1]
    reffile = sys.argv[2]
    mode = sys.argv[3] if len(sys.argv) > 3 else '--mini'

    if not os.path.exists(hexfile):
        print(f"Error: {hexfile} not found")
        sys.exit(1)
    if not os.path.exists(reffile):
        print(f"Error: {reffile} not found")
        sys.exit(1)

    hex_data = hex_to_bin(hexfile)
    ref = open(reffile, 'rb').read()

    if mode == '--mini':
        base = 0xD700  # MINI format: ORG D700
        label = "mini"
    elif mode == '--qd':
        base = 0xD480  # RC703/QD format: ORG D480
        label = "qd"
    else:
        print(f"Unknown mode: {mode}")
        sys.exit(1)

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
        print(f"MATCH: {compared} {label} bytes verified")
        sys.exit(0)
    else:
        print(f"MISMATCH: {diffs} differences in {compared} {label} bytes")
        for addr, got, exp in first_diffs:
            print(f"  {addr:04X}: got {got:02X} expected {exp:02X}")
        if len(first_diffs) < diffs:
            print(f"  ... and {diffs - len(first_diffs)} more")
        sys.exit(1)


if __name__ == '__main__':
    main()
