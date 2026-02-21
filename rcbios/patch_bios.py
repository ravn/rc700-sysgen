#!/usr/bin/env python3
"""Patch RC702 BIOS onto an IMD disk image.

Writes a zmac .cim binary (contiguous INIT+BIOS code) onto Track 0 of an
IMD disk image, mapping bytes sequentially to sectors sorted by sector number:
first all Side 0 sectors, then Side 1 sectors.

Supports both MINI (5.25") and MAXI (8") formats.

Usage:
    python3 patch_bios.py image.imd BIOS.cim -o patched.imd   # create copy
    python3 patch_bios.py image.imd BIOS.cim                   # patch in place
    python3 patch_bios.py image.imd --info                     # show Track 0 info
"""

import sys
import argparse


def parse_imd(data):
    """Parse IMD file into header + list of track records.

    Returns (header_bytes, tracks) where each track is a dict with:
        cyl, head, mode, nsect, sectsize, secnums, sectors[(secnum, data)],
        raw_start, raw_end (byte offsets in original file)
    """
    hdr_end = data.index(0x1a)
    header = data[:hdr_end + 1]
    pos = hdr_end + 1

    tracks = []
    while pos < len(data):
        raw_start = pos
        mode = data[pos]
        cyl = data[pos + 1]
        head_byte = data[pos + 2]
        head = head_byte & 0x3f
        has_cyl_map = (head_byte & 0x80) != 0
        has_head_map = (head_byte & 0x40) != 0
        nsect = data[pos + 3]
        sectsize_code = data[pos + 4]
        sectsize = 128 << sectsize_code
        pos += 5

        secnums = list(data[pos:pos + nsect])
        pos += nsect

        if has_cyl_map:
            pos += nsect
        if has_head_map:
            pos += nsect

        sectors = []
        for i in range(nsect):
            stype = data[pos]
            pos += 1
            if stype == 0x00:
                sectors.append((secnums[i], bytes(sectsize)))
            elif stype in (0x01, 0x03, 0x05, 0x07):
                sectors.append((secnums[i], data[pos:pos + sectsize]))
                pos += sectsize
            elif stype in (0x02, 0x04, 0x06, 0x08):
                sectors.append((secnums[i], bytes([data[pos]]) * sectsize))
                pos += 1
            else:
                print(f"Unknown sector type 0x{stype:02X} at offset {pos - 1}",
                      file=sys.stderr)
                sys.exit(1)

        tracks.append({
            'cyl': cyl,
            'head': head,
            'head_byte': head_byte,
            'mode': mode,
            'nsect': nsect,
            'sectsize_code': sectsize_code,
            'sectsize': sectsize,
            'secnums': secnums,
            'sectors': sectors,
            'raw_start': raw_start,
            'raw_end': pos,
        })

    return header, tracks


def write_track(out, trk, sectors_data):
    """Write a track record in IMD format.

    sectors_data is a list of (secnum, data) sorted by desired output order.
    Uses original sector numbering map order from trk['secnums'].
    """
    out.append(trk['mode'])
    out.append(trk['cyl'])
    out.append(trk['head_byte'])
    out.append(trk['nsect'])
    out.append(trk['sectsize_code'])

    # Sector numbering map — preserve original physical order
    out.extend(trk['secnums'])

    # Build lookup from secnum -> data
    data_map = {secnum: data for secnum, data in sectors_data}

    # Write sector data in physical order (matching secnums order)
    for secnum in trk['secnums']:
        sdata = data_map[secnum]
        # Check if sector is all one byte (compressible)
        if len(set(sdata)) == 1:
            out.append(0x02)  # compressed
            out.append(sdata[0])
        else:
            out.append(0x01)  # normal data
            out.extend(sdata)


def format_type(mode):
    """Return encoding type string for IMD mode byte."""
    if mode in (0x00, 0x01, 0x02):
        return "FM"
    return "MFM"


def detect_format(t0s0):
    """Detect MINI vs MAXI from Track 0 Side 0 sector count."""
    if t0s0['nsect'] == 26:
        return "MAXI"
    elif t0s0['nsect'] == 16:
        return "MINI"
    return f"UNKNOWN({t0s0['nsect']} sectors)"


def show_info(imd_path):
    """Display Track 0 information from an IMD file."""
    data = open(imd_path, 'rb').read()
    header, tracks = parse_imd(data)

    # Show IMD header (text before 0x1A)
    hdr_text = header[:-1].decode('ascii', errors='replace').strip()
    print(f"Image: {imd_path}")
    print(f"  Header: {hdr_text}")

    t0_tracks = [t for t in tracks if t['cyl'] == 0]
    if not t0_tracks:
        print("  No Track 0 found!")
        return

    t0s0 = next((t for t in t0_tracks if t['head'] == 0), None)
    if t0s0:
        fmt = detect_format(t0s0)
        print(f"  Format: {fmt}")

    for t in t0_tracks:
        enc = format_type(t['mode'])
        smin = min(t['secnums'])
        smax = max(t['secnums'])
        total = t['nsect'] * t['sectsize']
        print(f"  Track 0 Side {t['head']}: {enc} {t['nsect']} sectors x "
              f"{t['sectsize']}B = {total}B (sectors {smin}-{smax})")

    # Show total Track 0 capacity
    total_bytes = sum(t['nsect'] * t['sectsize'] for t in t0_tracks)
    print(f"  Track 0 total: {total_bytes} bytes")
    print(f"  Total tracks in image: {len(tracks)}")


def patch(imd_path, cim_path, out_path):
    """Patch .cim data onto Track 0 of an IMD image."""
    imd_data = open(imd_path, 'rb').read()
    cim_data = open(cim_path, 'rb').read()
    header, tracks = parse_imd(imd_data)

    # Find Track 0 sides
    t0_tracks = [t for t in tracks if t['cyl'] == 0]
    t0s0 = next((t for t in t0_tracks if t['head'] == 0), None)
    t0s1 = next((t for t in t0_tracks if t['head'] == 1), None)

    if not t0s0:
        print("ERROR: No Track 0 Side 0 found", file=sys.stderr)
        sys.exit(1)

    fmt = detect_format(t0s0)
    s0_total = t0s0['nsect'] * t0s0['sectsize']
    s1_total = t0s1['nsect'] * t0s1['sectsize'] if t0s1 else 0
    t0_total = s0_total + s1_total

    print(f"Image:  {imd_path} ({fmt})")
    print(f"  Track 0 Side 0: {format_type(t0s0['mode'])} "
          f"{t0s0['nsect']} x {t0s0['sectsize']}B = {s0_total}B")
    if t0s1:
        print(f"  Track 0 Side 1: {format_type(t0s1['mode'])} "
              f"{t0s1['nsect']} x {t0s1['sectsize']}B = {s1_total}B")
    print(f"BIOS:   {cim_path} ({len(cim_data)} bytes)")

    if len(cim_data) > t0_total:
        print(f"ERROR: .cim ({len(cim_data)}B) exceeds Track 0 capacity ({t0_total}B)",
              file=sys.stderr)
        sys.exit(1)

    # Map .cim bytes to sectors, sorted by sector number
    cim_pos = 0
    s0_patched = 0
    s1_patched = 0

    # Patch Side 0
    sorted_s0 = sorted(t0s0['sectors'], key=lambda s: s[0])
    new_s0 = []
    for secnum, orig_data in sorted_s0:
        ss = t0s0['sectsize']
        if cim_pos < len(cim_data):
            remaining = len(cim_data) - cim_pos
            if remaining >= ss:
                new_s0.append((secnum, cim_data[cim_pos:cim_pos + ss]))
            else:
                # Partial sector: blend with original
                patched = bytearray(cim_data[cim_pos:cim_pos + remaining])
                patched.extend(orig_data[remaining:])
                new_s0.append((secnum, bytes(patched)))
            cim_pos += ss
            s0_patched += 1
        else:
            new_s0.append((secnum, orig_data))

    # Patch Side 1
    new_s1 = None
    if t0s1 and cim_pos < len(cim_data):
        sorted_s1 = sorted(t0s1['sectors'], key=lambda s: s[0])
        new_s1 = []
        for secnum, orig_data in sorted_s1:
            ss = t0s1['sectsize']
            if cim_pos < len(cim_data):
                remaining = len(cim_data) - cim_pos
                if remaining >= ss:
                    new_s1.append((secnum, cim_data[cim_pos:cim_pos + ss]))
                else:
                    patched = bytearray(cim_data[cim_pos:cim_pos + remaining])
                    patched.extend(orig_data[remaining:])
                    new_s1.append((secnum, bytes(patched)))
                cim_pos += ss
                s1_patched += 1
            else:
                new_s1.append((secnum, orig_data))

    print(f"Patched: {s0_patched} sectors on side 0, {s1_patched} sectors on side 1 "
          f"({len(cim_data)}/{t0_total} bytes)")

    # Rebuild IMD file
    out = bytearray(header)

    for trk in tracks:
        if trk['cyl'] == 0 and trk['head'] == 0:
            write_track(out, trk, new_s0)
        elif trk['cyl'] == 0 and trk['head'] == 1 and new_s1 is not None:
            write_track(out, trk, new_s1)
        else:
            # Copy track verbatim from original
            out.extend(imd_data[trk['raw_start']:trk['raw_end']])

    with open(out_path, 'wb') as f:
        f.write(out)
    print(f"Written: {out_path}")


def main():
    parser = argparse.ArgumentParser(
        description="Patch RC702 BIOS onto an IMD disk image")
    parser.add_argument('image', help="IMD disk image file")
    parser.add_argument('cim', nargs='?', help="BIOS .cim binary (zmac output)")
    parser.add_argument('-o', '--output', help="Output file (default: patch in place)")
    parser.add_argument('--info', action='store_true',
                        help="Show Track 0 info and exit")

    args = parser.parse_args()

    if args.info:
        show_info(args.image)
        return

    if not args.cim:
        parser.error("BIOS .cim file required (or use --info)")

    out_path = args.output if args.output else args.image
    patch(args.image, args.cim, out_path)


if __name__ == '__main__':
    main()
