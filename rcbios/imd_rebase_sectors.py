#!/usr/bin/env python3
"""Rebase sector IDs in an IMD disk image.

Some IMD images were ripped with 0-based sector IDs (0..N-1) instead of the
standard 1-based IDs (1..N) expected by emulators that use physical sector
numbers (e.g. MAME's UPD765 core).  This tool creates a corrected copy.

The sector numbering map for every track is incremented by DELTA (default +1).
All other image data -- track headers, optional cylinder/head maps, sector
data bytes -- is copied verbatim.  Compressed sectors remain compressed.

Usage:
  imd_rebase_sectors.py <input.imd> -o <output.imd>   # create fixed copy
  imd_rebase_sectors.py <input.imd>                    # patch in place
  imd_rebase_sectors.py <input.imd> --info             # show info, no write
  imd_rebase_sectors.py <input.imd> --delta -1 -o ...  # 1-based -> 0-based
"""

import sys
import argparse


def rebase(data, delta, verbose=True):
    """Return (new_data, report_lines, track_count) with sector IDs += delta."""
    hdr_end = data.index(0x1a)
    out = bytearray(data[:hdr_end + 1])   # copy header + 0x1A terminator
    pos = hdr_end + 1

    report = []
    track_count = 0

    while pos < len(data):
        mode = data[pos]
        cyl = data[pos + 1]
        head_byte = data[pos + 2]
        head = head_byte & 0x3f
        has_cyl_map = (head_byte & 0x80) != 0
        has_head_map = (head_byte & 0x40) != 0
        nsect = data[pos + 3]
        sectsize_code = data[pos + 4]
        sectsize = 128 << sectsize_code

        # Copy 5-byte track header verbatim
        out.extend(data[pos:pos + 5])
        pos += 5

        # Sector number map — the only thing we change
        secnums_orig = list(data[pos:pos + nsect])
        secnums_new = [s + delta for s in secnums_orig]
        out.extend(bytes(secnums_new))
        pos += nsect

        if verbose and nsect > 0:
            mode_str = "FM " if mode <= 2 else "MFM"
            report.append(
                f"  T{cyl:02d}S{head}: {mode_str} {nsect:2d}x{sectsize:3d}B  "
                f"sectors {secnums_orig[0]:2d}..{secnums_orig[-1]:2d}"
                f" -> {secnums_new[0]:2d}..{secnums_new[-1]:2d}"
            )

        # Optional cylinder map — copy verbatim
        if has_cyl_map:
            out.extend(data[pos:pos + nsect])
            pos += nsect

        # Optional head map — copy verbatim
        if has_head_map:
            out.extend(data[pos:pos + nsect])
            pos += nsect

        # Sector data — copy verbatim, advance pos by exact byte count per type
        for _ in range(nsect):
            stype = data[pos]
            out.append(stype)
            pos += 1
            if stype == 0x00:
                pass                                    # unavailable, no data bytes
            elif stype in (0x01, 0x03, 0x05, 0x07):    # normal data
                out.extend(data[pos:pos + sectsize])
                pos += sectsize
            elif stype in (0x02, 0x04, 0x06, 0x08):    # compressed (fill byte)
                out.append(data[pos])
                pos += 1
            else:
                print(f"ERROR: unknown sector type 0x{stype:02X} at offset {pos - 1}",
                      file=sys.stderr)
                sys.exit(1)

        track_count += 1

    return bytes(out), report, track_count


def main():
    ap = argparse.ArgumentParser(
        description='Rebase sector IDs in an IMD disk image.')
    ap.add_argument('input', help='Input IMD file')
    ap.add_argument('-o', '--output',
                    help='Output IMD file (default: patch input in place)')
    ap.add_argument('--delta', type=int, default=1,
                    help='Value added to each sector ID (default: +1)')
    ap.add_argument('--info', action='store_true',
                    help='Print sector map and exit without writing')
    args = ap.parse_args()

    data = open(args.input, 'rb').read()
    hdr_end = data.index(0x1a)
    header_text = data[:hdr_end].decode('ascii', errors='replace').strip()

    print(f"Input:  {args.input}")
    print(f"Header: {header_text}")
    print(f"Delta:  {args.delta:+d}")
    print()

    new_data, report, track_count = rebase(data, args.delta)
    for line in report:
        print(line)
    print()
    print(f"Tracks: {track_count}")

    if args.info:
        print("(--info: no output written)")
        return

    out_path = args.output if args.output else args.input
    with open(out_path, 'wb') as f:
        f.write(new_data)
    print(f"Written: {out_path} ({len(new_data)} bytes)")


if __name__ == '__main__':
    main()
