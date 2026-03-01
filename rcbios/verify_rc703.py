#!/usr/bin/env python3
"""Verify assembled RC703 BIOS against reference binary.

RC703 BIOSes use a different structure from RC700:
- Binary starts at ORG D480h (INIT code), not at the BIOS jump table
- No standard JP-based jump table at BIOS entry
- Tail region (offset 0x1580+) may contain disk-specific data

Verification modes:
  --full    Compare all bytes (for rel.1.2 where tail data is known)
  --code    Compare only the code portion (first 5504 bytes, for TFj where
            tail is residual disk data)

Usage:
    python3 verify_rc703.py zout/BIOS.hex reference.bin [--full|--code]
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
        print(f"Usage: {sys.argv[0]} <hex_file> <ref_binary> [--full|--code]")
        sys.exit(1)

    hexfile = sys.argv[1]
    reffile = sys.argv[2]
    mode = sys.argv[3] if len(sys.argv) > 3 else '--full'

    if not os.path.exists(hexfile):
        print(f"Error: {hexfile} not found")
        sys.exit(1)
    if not os.path.exists(reffile):
        print(f"Error: {reffile} not found")
        sys.exit(1)

    hex_data = hex_to_bin(hexfile)
    ref = open(reffile, 'rb').read()

    base = 0xD480  # RC703 INIT start address

    if mode == '--code':
        compare_len = min(0x1580, len(ref))  # Code portion only (5504 bytes)
        label = "code"
    else:
        compare_len = len(ref)
        label = "full"

    diffs = 0
    first_diffs = []
    compared = 0

    for i in range(compare_len):
        addr = base + i
        if addr in hex_data:
            compared += 1
            if hex_data[addr] != ref[i]:
                diffs += 1
                if len(first_diffs) < 20:
                    first_diffs.append((addr, hex_data[addr], ref[i]))

    if diffs == 0:
        print(f"MATCH: {compared} {label} bytes verified")
        if mode == '--code' and len(ref) > 0x1580:
            print(f"  (tail region {len(ref) - 0x1580} bytes not compared — disk-specific data)")
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
