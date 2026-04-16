#!/usr/bin/env python3
"""Apply an Intel HEX overlay to a binary image.

Simulates MLOAD's composition: each type-00 data record in the HEX
writes `length` bytes at `address` into the output binary, overwriting
whatever was there.  Addresses are absolute (not TPA-relative).

The input binary is assumed to be positioned at a known base address,
supplied via --base.  For our CCP+BDOS.cim the base is 0xC400 (CCP origin).

Usage:
    apply_hex.py --base 0xC400 CCPBDOS.cim serial.hex -o CCPBDOS_stamped.cim

The combined output is what MLOAD would produce when fed the base
image's HEX together with the overlay HEX.
"""

from __future__ import annotations
import argparse
import sys
from pathlib import Path


def parse_hex(path: Path) -> list[tuple[int, bytes]]:
    """Return list of (absolute_addr, data_bytes) for type-00 records."""
    records = []
    for lineno, line in enumerate(path.read_text().splitlines(), 1):
        line = line.strip()
        if not line or not line.startswith(':'):
            continue
        try:
            raw = bytes.fromhex(line[1:])
        except ValueError as e:
            raise ValueError(f"{path}:{lineno}: bad hex: {e}")
        if len(raw) < 5:
            raise ValueError(f"{path}:{lineno}: record too short")
        length, addr_hi, addr_lo, rtype = raw[:4]
        data = raw[4:4 + length]
        checksum = raw[-1]
        computed = (-sum(raw[:-1])) & 0xFF
        if checksum != computed:
            raise ValueError(f"{path}:{lineno}: checksum {checksum:02X} != {computed:02X}")
        addr = (addr_hi << 8) | addr_lo
        if rtype == 0x00:
            records.append((addr, data))
        elif rtype == 0x01:
            break
        # rtype 0x00 with length 0 is CP/M's EOF marker — no data but also not a terminator
    return records


def apply_records(base_addr: int, data: bytearray, records: list[tuple[int, bytes]]) -> None:
    for abs_addr, chunk in records:
        rel_off = abs_addr - base_addr
        if rel_off < 0 or rel_off + len(chunk) > len(data):
            # A zero-length record at 0x0000 is the CP/M terminator — ignore
            if len(chunk) == 0:
                continue
            raise ValueError(
                f"record at 0x{abs_addr:04X} (offset {rel_off} in binary) "
                f"falls outside the binary range [{base_addr:04X}..{base_addr + len(data):04X})"
            )
        data[rel_off:rel_off + len(chunk)] = chunk


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    p.add_argument("binary", type=Path, help="base binary (e.g. CCPBDOS.cim)")
    p.add_argument("hex_files", type=Path, nargs='+', help="HEX overlay(s) to apply, in order")
    p.add_argument("--base", required=True,
                   help="absolute memory address that offset 0 of the binary represents "
                        "(e.g. 0xC400 for CCP+BDOS)")
    p.add_argument("-o", "--output", type=Path, required=True, help="output binary path")
    args = p.parse_args()

    try:
        base = int(args.base, 0)
    except ValueError:
        print(f"error: bad --base {args.base!r}", file=sys.stderr)
        return 1

    data = bytearray(args.binary.read_bytes())
    original_len = len(data)

    for hex_path in args.hex_files:
        try:
            records = parse_hex(hex_path)
        except ValueError as e:
            print(f"error: {e}", file=sys.stderr)
            return 1
        try:
            apply_records(base, data, records)
        except ValueError as e:
            print(f"error applying {hex_path.name}: {e}", file=sys.stderr)
            return 1
        nbytes = sum(len(d) for _, d in records)
        print(f"  applied {hex_path.name}: {len(records)} records, {nbytes} bytes overlaid")

    assert len(data) == original_len, "binary length must not change"
    args.output.write_bytes(bytes(data))
    print(f"  wrote {args.output.name}: {len(data)} bytes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
