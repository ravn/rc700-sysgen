#!/usr/bin/env python3
"""Verify a built CCP+BDOS.cim matches the CCP+BDOS on an RC702 IMD disk.

Reads track 1 of the IMD, deinterleaves via the skew table for that
disk's geometry, and byte-compares the first 5632 bytes against the
supplied CCP+BDOS.cim.

Should be byte-exact if the build's SERIAL= matches the disk's stamp.
"""

from __future__ import annotations
import sys
from pathlib import Path

# Skew tables per physical sectors-per-track
XLT = {
    15: [1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12],   # 8" DD 512 MAXI
    9:  [1, 3, 5, 7, 9, 2, 4, 6, 8],                           # 5.25" DD 512 MINI
    10: [1, 3, 5, 7, 9, 2, 4, 6, 8, 10],                       # RC703 MINI (10 spt)
}


def parse_imd(path: Path):
    """Return list of (cyl, head, mode, nsect, sectsize, [(secnum, data)...])."""
    data = path.read_bytes()
    hdr_end = data.index(0x1a)
    pos = hdr_end + 1
    tracks = []
    while pos < len(data):
        mode = data[pos]
        cyl = data[pos + 1]
        head = data[pos + 2] & 0x3f
        has_cyl_map = bool(data[pos + 2] & 0x80)
        has_head_map = bool(data[pos + 2] & 0x40)
        nsect = data[pos + 3]
        sectsize = 128 << data[pos + 4]
        pos += 5
        secnums = list(data[pos:pos + nsect]); pos += nsect
        if has_cyl_map:  pos += nsect
        if has_head_map: pos += nsect
        sectors = []
        for i in range(nsect):
            stype = data[pos]; pos += 1
            if stype == 0x00:
                sectors.append((secnums[i], bytes(sectsize)))
            elif stype in (0x01, 0x03, 0x05, 0x07):
                sectors.append((secnums[i], data[pos:pos + sectsize])); pos += sectsize
            elif stype in (0x02, 0x04, 0x06, 0x08):
                sectors.append((secnums[i], bytes([data[pos]]) * sectsize)); pos += 1
            else:
                raise ValueError(f"unknown sector type 0x{stype:02X} at offset {pos-1}")
        tracks.append((cyl, head, mode, nsect, sectsize, sectors))
    return tracks


def extract_ccp_bdos_from_imd(path: Path, num_cpm_sectors: int = 44) -> bytes:
    tracks = parse_imd(path)
    t1 = sorted([t for t in tracks if t[0] == 1], key=lambda t: t[1])
    if not t1:
        raise ValueError("no track 1 in IMD")
    spt = t1[0][3]
    sectsize = t1[0][4]
    if spt not in XLT:
        raise ValueError(f"unsupported geometry: {spt} spt")
    if sectsize != 512:
        raise ValueError(f"expected 512B sectors, got {sectsize}")
    xlt = XLT[spt]
    side_sectors = [{s[0]: s[1] for s in side[5]} for side in t1]
    logical = bytearray()
    for cpm in range(num_cpm_sectors):
        host = cpm >> 2
        side = host // spt
        phys_id = xlt[host % spt]
        offset = (cpm & 3) * 128
        logical.extend(side_sectors[side][phys_id][offset:offset + 128])
    return bytes(logical)


def main() -> int:
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <built.cim> <reference.imd>", file=sys.stderr)
        return 1
    built_path = Path(sys.argv[1])
    imd_path = Path(sys.argv[2])
    built = built_path.read_bytes()
    if len(built) < 5632:
        print(f"error: {built_path} is only {len(built)} bytes, need >= 5632", file=sys.stderr)
        return 1
    built = built[:5632]
    ref = extract_ccp_bdos_from_imd(imd_path)
    match = sum(1 for a, b in zip(built, ref) if a == b)
    pct = 100 * match // len(ref)
    print(f"{built_path.name} vs {imd_path.name}: {match}/{len(ref)} bytes match ({pct}%)")
    if built == ref:
        print("BYTE-EXACT MATCH")
        return 0
    diffs = [i for i in range(len(ref)) if built[i] != ref[i]]
    print(f"Differences: {len(diffs)} bytes")
    for i in diffs[:20]:
        print(f"  offset 0x{i:04X}: built=0x{built[i]:02X} ref=0x{ref[i]:02X}")
    if len(diffs) > 20:
        print(f"  ... and {len(diffs) - 20} more")
    return 0 if len(diffs) <= 6 else 1  # up to 6 byte serial diff is ok; more suggests problem


if __name__ == "__main__":
    sys.exit(main())
