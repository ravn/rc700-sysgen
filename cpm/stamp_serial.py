#!/usr/bin/env python3
"""Stamp a DRI CP/M 2.2 serial number into assembled CCP/BDOS binaries.

DRI's 6-byte serial layout (per the CCP's serialize routine in
OS2CCP.ASM line 273, which byte-compares CCP's stamp against BDOS's):

    byte 0:    manufacturer code low byte
    byte 1:    version code (0x16 = CP/M 2.2)
    byte 2:    manufacturer code high byte
    bytes 3-5: per-disk serial, 24-bit big-endian

Regnecentralen's DRI-assigned manufacturer code is 0x08D5 = 2261.
Printed labels read "2-261-XXXX" where XXXX is the 4-digit serial.

A "master" disk has serial 0 (bytes 3-5 = 00 00 00).  The label
"2-261-0000" is safe as a default — CCP's serialize check passes
(0 == 0) so the stamp works at runtime, and it visibly marks the
disk as "not a serialized customer copy".

Usage:
    stamp_serial.py --serial 2-261-0000 --ccp OS2CCP.cim --bdos OS3BDOS.cim
    stamp_serial.py --serial 2972       --ccp OS2CCP.cim --bdos OS3BDOS.cim

CCP and BDOS have different stamp offsets:
    CCP:   offset 0x328 (memory 0xC728, the `serial:` field)
    BDOS:  offset 0x000 (memory 0xCC00, the very start)

Pass --ccp and/or --bdos to control which file gets which offset.

Arguments to --serial accepted:
    "2-XXX-YYYY"      full textual form, e.g. "2-261-2972"
    "YYYY"            bare serial (uses default vendor 2-261)
    "2261-2972"       manufacturer-dash-serial
    "D5 16 08 00 00 00"   raw hex bytes (space-separated, case-insensitive)
"""

from __future__ import annotations
import argparse
import re
import sys
from pathlib import Path

# Stamp offsets within each binary.  These are fixed by the CP/M 2.2
# source layout — CCP's `serial:` field lives at 0xC728 (= 0x328 from
# the CCP origin 0xC400), and BDOS's stamp sits at 0xCC00 (= 0x000 from
# the BDOS origin).
CCP_STAMP_OFFSET = 0x328
BDOS_STAMP_OFFSET = 0x000

# Absolute memory addresses of the two stamp locations (for HEX records).
CCP_STAMP_ADDR = 0xC728
BDOS_STAMP_ADDR = 0xCC00

# Default vendor portion (Regnecentralen, CP/M 2.2)
DEFAULT_MFG_LOW = 0xD5
DEFAULT_VERSION = 0x16  # CP/M 2.2
DEFAULT_MFG_HIGH = 0x08


def parse_serial(s: str) -> bytes:
    """Convert a user-supplied serial string to the 6 stamp bytes.

    Accepts:
      "2-261-2972"    → full form, manufacturer 2261, serial 2972
      "2261-2972"     → numeric manufacturer, dash, serial
      "2972"          → serial only, uses Regnecentralen default mfg
      "D5 16 08 00 0B 9C"  → raw hex bytes (must be exactly 6)
    """
    s = s.strip()

    # Raw hex form?
    hex_match = re.fullmatch(r'(?:[0-9A-Fa-f]{2}[\s,]*){6}', s)
    if hex_match:
        bytes_out = bytes(int(x, 16) for x in re.findall(r'[0-9A-Fa-f]{2}', s))
        if len(bytes_out) != 6:
            raise ValueError(f"raw hex form must be exactly 6 bytes, got {len(bytes_out)}")
        return bytes_out

    # Textual form: split by '-' to get manufacturer + serial.
    parts = s.split('-')
    if len(parts) == 1:
        # "2972" — serial only
        mfg, serial = (DEFAULT_MFG_HIGH << 8) | DEFAULT_MFG_LOW, int(parts[0])
    elif len(parts) == 2:
        # "2261-2972"
        mfg, serial = int(parts[0]), int(parts[1])
    elif len(parts) == 3:
        # "2-261-2972" — concat first two parts to get manufacturer
        mfg, serial = int(parts[0] + parts[1]), int(parts[2])
    else:
        raise ValueError(f"unrecognized serial form: {s!r}")

    if not 0 <= mfg <= 0xFFFF:
        raise ValueError(f"manufacturer code {mfg} outside 16-bit range")
    if not 0 <= serial <= 0xFFFFFF:
        raise ValueError(f"per-disk serial {serial} outside 24-bit range")

    return bytes([
        mfg & 0xFF,            # byte 0: mfg low
        DEFAULT_VERSION,       # byte 1: version
        (mfg >> 8) & 0xFF,     # byte 2: mfg high
        (serial >> 16) & 0xFF, # byte 3: serial high
        (serial >> 8) & 0xFF,  # byte 4: serial mid
        serial & 0xFF,         # byte 5: serial low
    ])


def format_stamp(stamp: bytes) -> str:
    """Inverse of parse_serial: stamp bytes → printable "V-MMM-SSSS"."""
    if len(stamp) != 6:
        raise ValueError("stamp must be 6 bytes")
    mfg = (stamp[2] << 8) | stamp[0]
    version = stamp[1]
    serial = (stamp[3] << 16) | (stamp[4] << 8) | stamp[5]
    mfg_str = str(mfg)
    # Split manufacturer: "2261" → "2-261"
    if len(mfg_str) > 1:
        display = f"{mfg_str[0]}-{mfg_str[1:]}-{serial:04d}"
    else:
        display = f"{mfg_str}-{serial:04d}"
    return f"{display} (version=0x{version:02X}, bytes={stamp.hex(' ')})"


def ihex_record(rtype: int, addr: int, data: bytes) -> str:
    """Build one Intel HEX record line."""
    length = len(data)
    raw = bytes([length, (addr >> 8) & 0xFF, addr & 0xFF, rtype]) + data
    checksum = (-sum(raw)) & 0xFF
    return ':' + raw.hex().upper() + f'{checksum:02X}'


def emit_hex(stamp: bytes, out_path: Path, cpm_eof: bool = True) -> None:
    """Write an Intel HEX file containing just the two 6-byte stamps.

    Two data records at 0xC728 (CCP) and 0xCC00 (BDOS), plus a
    terminator.  Default terminator is a zero-length type-00 record
    (CP/M LOAD/MLOAD convention).  Pass cpm_eof=False to emit the
    Intel-standard type-01 EOF instead.
    """
    lines = [
        "; RC702 CP/M 2.2 serial stamp overlay",
        f"; Stamp: {format_stamp(stamp)}",
        "; Apply with MLOAD on top of the base CCP+BDOS image.",
        ihex_record(0x00, CCP_STAMP_ADDR, stamp),
        ihex_record(0x00, BDOS_STAMP_ADDR, stamp),
    ]
    if cpm_eof:
        lines.append(ihex_record(0x00, 0x0000, b''))
    else:
        lines.append(":00000001FF")
    out_path.write_text('\n'.join(lines) + '\n')


def stamp_file(path: Path, offset: int, stamp: bytes, dry_run: bool = False) -> None:
    data = bytearray(path.read_bytes())
    end = offset + len(stamp)
    if end > len(data):
        raise ValueError(f"{path}: file too short ({len(data)} bytes) for stamp at offset 0x{offset:X}")

    old = bytes(data[offset:end])
    if old == stamp:
        print(f"  {path.name}: already stamped correctly, no change")
        return

    # Require current content to be either all zeros (fresh build) or
    # a previously-stamped value.  Refuse to overwrite arbitrary bytes
    # that might be real code/data.
    if any(b != 0 for b in old) and old[1] != DEFAULT_VERSION:
        raise ValueError(
            f"{path}: refusing to stamp — bytes at 0x{offset:X} are "
            f"{old.hex(' ')}, not a recognizable serial or zero block. "
            f"Are you sure you're stamping an assembled CCP/BDOS .cim?"
        )

    data[offset:end] = stamp
    if dry_run:
        print(f"  {path.name}: would stamp 0x{offset:X}: {old.hex(' ')} -> {stamp.hex(' ')}")
    else:
        path.write_bytes(bytes(data))
        print(f"  {path.name}: stamped 0x{offset:X}: {old.hex(' ')} -> {stamp.hex(' ')}")


def main() -> int:
    p = argparse.ArgumentParser(
        description=__doc__.splitlines()[0],
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument("--serial", default="2-261-0000",
                   help="serial string (default: 2-261-0000, i.e. master)")
    p.add_argument("--dry-run", action="store_true",
                   help="show what would change without writing")
    p.add_argument("--ccp", type=Path, help="CCP binary (stamp at offset 0x328)")
    p.add_argument("--bdos", type=Path, help="BDOS binary (stamp at offset 0x000)")
    p.add_argument("--hex-out", type=Path, metavar="FILE",
                   help="emit a small Intel HEX file with the stamp overlay "
                        "(both 0xC728 and 0xCC00 records), for MLOAD composition")
    p.add_argument("--intel-eof", action="store_true",
                   help="use standard Intel HEX EOF (type 01) instead of "
                        "CP/M LOAD's zero-length type-00 terminator")
    args = p.parse_args()

    try:
        stamp = parse_serial(args.serial)
    except ValueError as e:
        print(f"error: {e}", file=sys.stderr)
        return 1

    print(f"Serial: {format_stamp(stamp)}")

    if args.ccp:
        try:
            stamp_file(args.ccp, CCP_STAMP_OFFSET, stamp, args.dry_run)
        except Exception as e:
            print(f"error stamping {args.ccp}: {e}", file=sys.stderr)
            return 1

    if args.bdos:
        try:
            stamp_file(args.bdos, BDOS_STAMP_OFFSET, stamp, args.dry_run)
        except Exception as e:
            print(f"error stamping {args.bdos}: {e}", file=sys.stderr)
            return 1

    if args.hex_out:
        try:
            emit_hex(stamp, args.hex_out, cpm_eof=not args.intel_eof)
            print(f"  {args.hex_out.name}: wrote HEX stamp overlay")
        except Exception as e:
            print(f"error writing {args.hex_out}: {e}", file=sys.stderr)
            return 1

    return 0


if __name__ == "__main__":
    sys.exit(main())
