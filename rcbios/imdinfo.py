#!/usr/bin/env python3
"""Show summary information about an IMD disk image.

Usage: python3 imdinfo.py image.imd [image2.imd ...]
"""

import sys
from collections import defaultdict

MODE_STR = {0: "500k FM", 1: "300k FM", 2: "250k FM",
            3: "500k MFM", 4: "300k MFM", 5: "250k MFM"}


def imdinfo(path):
    data = open(path, 'rb').read()
    hdr_end = data.index(0x1a)
    header = data[:hdr_end].decode('ascii', errors='replace').strip()
    pos = hdr_end + 1

    tracks = []
    t0_raw = bytearray()  # sequential Track 0 data (side 0 then side 1)

    while pos < len(data):
        mode = data[pos]
        cyl = data[pos + 1]
        head_byte = data[pos + 2]
        head = head_byte & 0x3f
        has_cyl_map = (head_byte & 0x80) != 0
        has_head_map = (head_byte & 0x40) != 0
        nsect = data[pos + 3]
        sectsize = 128 << data[pos + 4]
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
                print(f"Unknown sector type 0x{stype:02X}", file=sys.stderr)
                sys.exit(1)

        tracks.append((cyl, head, mode, nsect, sectsize))

        if cyl == 0:
            for _, sdata in sorted(sectors):
                t0_raw.extend(sdata)

    max_cyl = max(t[0] for t in tracks)
    sides = 1 + max(t[1] for t in tracks)
    t0s0 = next((t for t in tracks if t[0] == 0 and t[1] == 0), None)

    if t0s0 and t0s0[3] == 26:
        fmt = "MAXI (8\")"
    elif t0s0 and t0s0[3] == 16:
        fmt = "MINI (5.25\")"
    else:
        fmt = "UNKNOWN"

    print(f"{path}: {fmt}, {max_cyl + 1} cylinders, {sides} sides")
    print(f"  {header}")

    # Group consecutive cylinders with identical geometry across all sides
    cyls = defaultdict(dict)
    for cyl, head, mode, nsect, sectsize in tracks:
        cyls[cyl][head] = (mode, nsect, sectsize)

    groups = []
    for cyl in sorted(cyls):
        geo = cyls[cyl]
        if groups and groups[-1][2] == geo and cyl == groups[-1][1] + 1:
            groups[-1] = (groups[-1][0], cyl, geo)
        else:
            groups.append((cyl, cyl, geo))

    for cyl_lo, cyl_hi, geo in groups:
        cyl_range = f"T{cyl_lo}" if cyl_lo == cyl_hi else f"T{cyl_lo}-{cyl_hi}"
        for head in sorted(geo):
            mode, nsect, sectsize = geo[head]
            enc = MODE_STR.get(mode, f"mode {mode}")
            print(f"  {cyl_range} S{head}: {enc}, {nsect} x {sectsize}B")

    # Check boot status from Track 0 first sector
    if len(t0_raw) >= 2:
        entry = t0_raw[0] | (t0_raw[1] << 8)
        if len(set(t0_raw[:128])) == 1 and t0_raw[0] == 0xE5:
            print("  System: data only (no boot sectors)")
        else:
            signon = find_signon(t0_raw)
            if entry == 0x0280:
                label = "56K CP/M BIOS"
            elif entry == 0x0380:
                label = "58K CP/M BIOS"
            else:
                label = f"boot entry 0x{entry:04X}"
            if signon:
                print(f"  System: {label} — {signon}")
            else:
                print(f"  System: {label}")


def find_signon(t0_raw):
    """Search Track 0 for the BIOS signon string.

    The signon is a printable string in the CPMBOOT/INIT area.
    56K: at ~0x060E (after INIT code), starts with "RC700"
    58K: at ~0x0575, starts with "58K" or similar
    Search for known prefixes and extract the full printable run.
    """
    # Ordered by specificity — try the most distinctive patterns first
    markers = [
        b'56k CP/M',       # 56K signon: "RC700   56k CP/M vers.2.2   rel.X.X"
        b'58K CP/M',       # 58K signon: "58K CP/M VERS 2.2"
        b'CP/M vers',      # alternate 56K
        b'CP/M VERS',      # alternate 58K
    ]
    for marker in markers:
        idx = t0_raw.find(marker)
        if idx < 0:
            continue
        # Walk backwards to find start of printable run
        start = idx
        while start > 0 and 0x20 <= t0_raw[start - 1] < 0x7F:
            start -= 1
        # Walk forwards to end of printable run
        end = idx
        while end < len(t0_raw) and 0x20 <= t0_raw[end] < 0x7F:
            end += 1
        return t0_raw[start:end].decode('ascii').strip()
    return None


if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f"usage: {sys.argv[0]} <image.imd> [...]", file=sys.stderr)
        sys.exit(1)
    for i, path in enumerate(sys.argv[1:]):
        if i > 0:
            print()
        imdinfo(path)
