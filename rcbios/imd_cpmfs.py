#!/usr/bin/env python3
"""Inject files into RC702 CP/M IMD disk images.

Usage:
    python3 imd_cpmfs.py image.imd --list
    python3 imd_cpmfs.py image.imd src_file [DEST.EXT] [-o out.imd]

Supports MAXI (8") and MINI (5.25") RC702 disk formats.
Modifies the image in place unless -o is specified.
"""

import os
import struct
import sys

# --- Disk Parameter Blocks ---

# MAXI 8" DD 512B/S data area (DPB8 from DISKTAB.MAC)
DPB_MAXI = {
    'name': 'MAXI',
    'spt': 120,          # logical records per track
    'bsh': 4,            # block shift
    'blm': 15,           # block mask
    'exm': 0,            # extent mask
    'dsm': 449,          # max block number
    'drm': 127,          # max directory entry number
    'al0': 0xC0, 'al1': 0x00,
    'off': 2,            # reserved system tracks
    'phys_spt': 15,      # physical sectors per side
    'sides': 2,
    'secsize': 512,      # physical sector size (data tracks)
    'tran': [1, 5, 9, 13, 2, 6, 10, 14, 3, 7, 11, 15, 4, 8, 12],
}

# MINI 5.25" DD 512B/S data area (DPB16 from DISKTAB.MAC)
DPB_MINI = {
    'name': 'MINI',
    'spt': 72,           # logical records per track
    'bsh': 4,
    'blm': 15,
    'exm': 1,            # extent mask (2 logical extents per phys)
    'dsm': 134,
    'drm': 127,
    'al0': 0xC0, 'al1': 0x00,
    'off': 2,
    'phys_spt': 9,
    'sides': 2,
    'secsize': 512,
    'tran': [1, 3, 5, 7, 9, 2, 4, 6, 8],
}


# --- IMD Parsing ---

def parse_imd(path):
    """Parse IMD file into header text and list of track records."""
    data = bytearray(open(path, 'rb').read())
    hdr_end = data.index(0x1A)
    header = data[:hdr_end].decode('ascii', errors='replace')
    pos = hdr_end + 1

    tracks = []
    while pos < len(data):
        rec_start = pos
        mode = data[pos]
        cyl = data[pos + 1]
        head_byte = data[pos + 2]
        head = head_byte & 0x3F
        has_cyl_map = bool(head_byte & 0x80)
        has_head_map = bool(head_byte & 0x40)
        nsect = data[pos + 3]
        sectsize = 128 << data[pos + 4]
        pos += 5

        secnums = list(data[pos:pos + nsect])
        pos += nsect
        if has_cyl_map:
            pos += nsect
        if has_head_map:
            pos += nsect

        sectors = {}
        for i in range(nsect):
            stype = data[pos]
            pos += 1
            if stype == 0x00:
                sdata = bytes(sectsize)
            elif stype in (0x01, 0x03, 0x05, 0x07):
                sdata = bytes(data[pos:pos + sectsize])
                pos += sectsize
            elif stype in (0x02, 0x04, 0x06, 0x08):
                sdata = bytes([data[pos]]) * sectsize
                pos += 1
            else:
                raise ValueError(f"Unknown sector type 0x{stype:02X}")
            sectors[secnums[i]] = sdata

        tracks.append({
            'cyl': cyl, 'head': head, 'mode': mode,
            'nsect': nsect, 'sectsize': sectsize,
            'secnums': secnums, 'sectors': sectors,
            'raw_start': rec_start,
        })

    return header, data, tracks


def write_imd(path, header, tracks):
    """Write IMD file from header and track records."""
    out = bytearray()
    out.extend(header.encode('ascii'))
    out.append(0x1A)

    for t in tracks:
        head_byte = t['head']
        # We don't use cyl/head maps for output
        out.append(t['mode'])
        out.append(t['cyl'])
        out.append(head_byte)
        out.append(t['nsect'])
        ss_code = {128: 0, 256: 1, 512: 2, 1024: 3, 2048: 4}
        out.append(ss_code[t['sectsize']])
        out.extend(t['secnums'])

        for sn in t['secnums']:
            sdata = t['sectors'][sn]
            # Check if compressible (all same byte)
            if len(set(sdata)) == 1:
                out.append(0x02)  # compressed
                out.append(sdata[0])
            else:
                out.append(0x01)  # normal
                out.extend(sdata)

    return bytes(out)


def detect_format(tracks):
    """Detect MAXI vs MINI from Track 0 sector count."""
    for t in tracks:
        if t['cyl'] == 0 and t['head'] == 0:
            if t['nsect'] == 26:
                return DPB_MAXI
            elif t['nsect'] == 16:
                return DPB_MINI
    raise ValueError("Cannot detect format from Track 0")


def find_track(tracks, cyl, head):
    """Find track record by cylinder and head."""
    for t in tracks:
        if t['cyl'] == cyl and t['head'] == head:
            return t
    return None


# --- CP/M Block I/O ---

def read_block(tracks, dpb, block_num):
    """Read a CP/M allocation block as bytes."""
    bls = 128 << dpb['bsh']  # block size
    recs_per_block = bls // 128
    first_rec = block_num * recs_per_block
    result = bytearray()

    for r in range(recs_per_block):
        rec = first_rec + r
        track = dpb['off'] + rec // dpb['spt']
        rec_in_track = rec % dpb['spt']
        group = rec_in_track // 4
        phys_per_side = dpb['phys_spt']
        head = group // phys_per_side
        phys_sec = dpb['tran'][group % phys_per_side]

        t = find_track(tracks, track, head)
        if t is None:
            result.extend(b'\xE5' * 128)
            continue

        sdata = t['sectors'].get(phys_sec, b'\xE5' * t['sectsize'])
        # Which 128-byte record within the 512-byte sector?
        rec_in_sec = rec_in_track % 4
        offset = rec_in_sec * 128
        result.extend(sdata[offset:offset + 128])

    return bytes(result)


def write_block(tracks, dpb, block_num, data):
    """Write a CP/M allocation block."""
    bls = 128 << dpb['bsh']
    assert len(data) == bls
    recs_per_block = bls // 128
    first_rec = block_num * recs_per_block

    for r in range(recs_per_block):
        rec = first_rec + r
        track_num = dpb['off'] + rec // dpb['spt']
        rec_in_track = rec % dpb['spt']
        group = rec_in_track // 4
        phys_per_side = dpb['phys_spt']
        head = group // phys_per_side
        phys_sec = dpb['tran'][group % phys_per_side]

        t = find_track(tracks, track_num, head)
        if t is None:
            raise ValueError(f"Track {track_num} head {head} not found")

        # Read current sector, modify the 128-byte record, write back
        sdata = bytearray(t['sectors'].get(phys_sec,
                                            b'\xE5' * t['sectsize']))
        rec_in_sec = rec_in_track % 4
        offset = rec_in_sec * 128
        sdata[offset:offset + 128] = data[r * 128:(r + 1) * 128]
        t['sectors'][phys_sec] = bytes(sdata)


# --- CP/M Directory ---

def read_directory(tracks, dpb):
    """Read all directory entries. Returns list of 32-byte entries."""
    bls = 128 << dpb['bsh']
    # Directory blocks are indicated by AL0/AL1
    al = (dpb['al0'] << 8) | dpb['al1']
    dir_blocks = []
    for i in range(16):
        if al & (0x8000 >> i):
            dir_blocks.append(i)

    dir_data = bytearray()
    for blk in dir_blocks:
        dir_data.extend(read_block(tracks, dpb, blk))

    entries = []
    for i in range(0, len(dir_data), 32):
        entries.append(bytearray(dir_data[i:i + 32]))
    return entries, dir_blocks


def write_directory(tracks, dpb, entries, dir_blocks):
    """Write directory entries back to disk."""
    bls = 128 << dpb['bsh']
    dir_data = bytearray()
    for e in entries:
        dir_data.extend(e)

    for i, blk in enumerate(dir_blocks):
        start = i * bls
        write_block(tracks, dpb, blk, dir_data[start:start + bls])


def get_alloc_map(entries, dpb):
    """Build allocation bitmap from directory entries."""
    dsm = dpb['dsm']
    # Block numbers are 16-bit if DSM > 255, else 8-bit
    big_blocks = dsm > 255
    alloc = set()

    # Mark directory blocks as allocated
    al = (dpb['al0'] << 8) | dpb['al1']
    for i in range(16):
        if al & (0x8000 >> i):
            alloc.add(i)

    for e in entries:
        if e[0] == 0xE5:
            continue  # unused entry
        if big_blocks:
            for i in range(16, 32, 2):
                blk = e[i] | (e[i + 1] << 8)
                if blk != 0:
                    alloc.add(blk)
        else:
            for i in range(16, 32):
                if e[i] != 0:
                    alloc.add(e[i])

    return alloc


def format_name(raw):
    """Format 8+3 name from directory entry bytes."""
    name = bytes(b & 0x7F for b in raw[1:9]).decode('ascii', errors='replace').rstrip()
    ext = bytes(b & 0x7F for b in raw[9:12]).decode('ascii', errors='replace').rstrip()
    if ext:
        return f"{name}.{ext}"
    return name


def list_files(entries, dpb):
    """List files from directory entries."""
    bls = 128 << dpb['bsh']
    big_blocks = dpb['dsm'] > 255

    # Group entries by user+name
    files = {}
    for e in entries:
        user = e[0]
        if user == 0xE5:
            continue
        name = format_name(e)
        key = (user, name)

        ex = e[12] & 0x1F  # extent number (low 5 bits)
        s2 = e[14] & 0x3F  # extent high bits
        extent = s2 * 32 + ex
        rc = e[15]  # record count in this extent

        blocks = []
        if big_blocks:
            for i in range(16, 32, 2):
                blk = e[i] | (e[i + 1] << 8)
                if blk:
                    blocks.append(blk)
        else:
            for i in range(16, 32):
                if e[i]:
                    blocks.append(e[i])

        if key not in files:
            files[key] = {'extents': [], 'name': name, 'user': user}
        files[key]['extents'].append((extent, rc, blocks))

    # Print
    print(f"{'User':>4}  {'Name':<16}  {'Size':>6}  Blocks")
    print(f"{'----':>4}  {'----':<16}  {'----':>6}  ------")
    for (user, name), info in sorted(files.items()):
        total_recs = 0
        all_blocks = []
        for ext_num, rc, blocks in sorted(info['extents']):
            total_recs += rc
            all_blocks.extend(blocks)
        size = total_recs * 128
        if size >= 1024:
            size_str = f"{size // 1024}K"
        else:
            size_str = str(size)
        blk_str = ','.join(str(b) for b in all_blocks[:8])
        if len(all_blocks) > 8:
            blk_str += '...'
        print(f"{user:4d}  {name:<16}  {size_str:>6}  {blk_str}")

    used = get_alloc_map(entries, dpb)
    total_blocks = dpb['dsm'] + 1
    free_blocks = total_blocks - len(used)
    print(f"\n{free_blocks} of {total_blocks} blocks free "
          f"({free_blocks * bls // 1024}K of {total_blocks * bls // 1024}K)")


def inject_file(tracks, dpb, entries, dir_blocks, src_path, dest_name, user=0):
    """Inject a host file into the CP/M filesystem."""
    bls = 128 << dpb['bsh']
    big_blocks = dpb['dsm'] > 255
    recs_per_extent = 128 * (dpb['exm'] + 1)  # records per logical extent
    blocks_per_extent = 8 if big_blocks else 16

    # Read source file
    with open(src_path, 'rb') as f:
        file_data = f.read()

    # Pad to 128-byte records
    total_recs = (len(file_data) + 127) // 128
    file_data = file_data.ljust(total_recs * 128, b'\x00')

    # Parse destination name
    if '.' in dest_name:
        fname, fext = dest_name.rsplit('.', 1)
    else:
        fname, fext = dest_name, ''
    fname = fname.upper()[:8].ljust(8)
    fext = fext.upper()[:3].ljust(3)

    # Check if file already exists
    for e in entries:
        if e[0] != 0xE5:
            ename = bytes(b & 0x7F for b in e[1:9]).decode('ascii')
            eext = bytes(b & 0x7F for b in e[9:12]).decode('ascii')
            if ename == fname and eext == fext and e[0] == user:
                print(f"  WARNING: {dest_name} already exists (user {user}), "
                      f"overwriting")
                e[0] = 0xE5  # mark as deleted

    # Get free blocks
    alloc = get_alloc_map(entries, dpb)
    free_blocks = sorted(b for b in range(dpb['dsm'] + 1) if b not in alloc)

    # Calculate blocks needed
    blocks_needed = (len(file_data) + bls - 1) // bls
    if blocks_needed > len(free_blocks):
        print(f"  ERROR: Need {blocks_needed} blocks, only {len(free_blocks)} free",
              file=sys.stderr)
        return False

    # Calculate extents needed
    recs_remaining = total_recs
    block_idx = 0
    extent_num = 0
    file_offset = 0

    while recs_remaining > 0:
        # Find free directory entry
        dir_idx = None
        for i, e in enumerate(entries):
            if e[0] == 0xE5:
                dir_idx = i
                break
        if dir_idx is None:
            print(f"  ERROR: No free directory entries", file=sys.stderr)
            return False

        # Allocate blocks for this extent
        recs_in_extent = min(recs_remaining, recs_per_extent)
        blocks_in_extent = (recs_in_extent * 128 + bls - 1) // bls

        ext_blocks = []
        for _ in range(blocks_in_extent):
            blk = free_blocks.pop(0)
            ext_blocks.append(blk)
            alloc.add(blk)

            # Write block data
            chunk = file_data[file_offset:file_offset + bls]
            if len(chunk) < bls:
                chunk = chunk.ljust(bls, b'\x00')
            write_block(tracks, dpb, blk, chunk)
            file_offset += bls

        # Create directory entry
        entry = bytearray(32)
        entry[0] = user
        entry[1:9] = fname.encode('ascii')
        entry[9:12] = fext.encode('ascii')
        entry[12] = extent_num & 0x1F  # EX (low 5 bits)
        entry[13] = 0  # S1
        entry[14] = (extent_num >> 5) & 0x3F  # S2 (high bits)
        entry[15] = recs_in_extent  # RC

        # Write block pointers
        if big_blocks:
            for i, blk in enumerate(ext_blocks):
                entry[16 + i * 2] = blk & 0xFF
                entry[16 + i * 2 + 1] = (blk >> 8) & 0xFF
        else:
            for i, blk in enumerate(ext_blocks):
                entry[16 + i] = blk

        entries[dir_idx] = entry
        recs_remaining -= recs_in_extent
        extent_num += 1

    print(f"  {dest_name}: {total_recs} records, {blocks_needed} blocks, "
          f"{extent_num} extent(s)")
    return True


def main():
    import argparse
    parser = argparse.ArgumentParser(
        description='Inject files into RC702 CP/M IMD disk images')
    parser.add_argument('image', help='IMD disk image')
    parser.add_argument('files', nargs='*',
                        help='Files to inject (src [DEST.EXT] ...)')
    parser.add_argument('-o', '--output', help='Output IMD (default: modify in place)')
    parser.add_argument('--list', action='store_true', help='List files on disk')
    parser.add_argument('--user', type=int, default=0, help='CP/M user number')
    args = parser.parse_args()

    header, raw_data, tracks = parse_imd(args.image)
    dpb = detect_format(tracks)
    print(f"{args.image}: {dpb['name']} format")

    entries, dir_blocks = read_directory(tracks, dpb)

    if args.list:
        list_files(entries, dpb)
        return 0

    if not args.files:
        parser.print_help()
        return 1

    # Parse file arguments: src [DEST] src [DEST] ...
    i = 0
    injected = []
    while i < len(args.files):
        src = args.files[i]
        if not os.path.exists(src):
            print(f"ERROR: {src} not found", file=sys.stderr)
            return 1

        # Check if next arg looks like a CP/M filename (not a path)
        if (i + 1 < len(args.files) and
                not os.path.exists(args.files[i + 1]) and
                '/' not in args.files[i + 1]):
            dest = args.files[i + 1]
            i += 2
        else:
            dest = os.path.basename(src).upper()
            i += 1

        if not inject_file(tracks, dpb, entries, dir_blocks, src, dest,
                          user=args.user):
            return 1
        injected.append(dest)

    # Write directory back
    write_directory(tracks, dpb, entries, dir_blocks)

    # Write IMD
    out_path = args.output or args.image
    imd_data = write_imd(out_path, header, tracks)
    with open(out_path, 'wb') as f:
        f.write(imd_data)

    print(f"\nWrote {out_path} ({len(injected)} files injected)")
    return 0


if __name__ == '__main__':
    sys.exit(main())
