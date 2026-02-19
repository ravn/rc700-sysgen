#!/usr/bin/env python3
"""Convert raw RC702 5.25" mini disk image to IMD format.

Layout of raw BIN (interleaved sides per track):
  Track 0, Side 0: 16 sectors x 128 bytes (FM)
  Track 0, Side 1: 16 sectors x 256 bytes (MFM)
  Track 1+, Side 0: 9 sectors x 512 bytes (MFM)
  Track 1+, Side 1: 9 sectors x 512 bytes (MFM)

IMD mode bytes: 0=500kbps FM, 2=250kbps FM, 3=500kbps MFM, 5=250kbps MFM
IMD sector size codes: 0=128, 1=256, 2=512
"""

import sys
import struct

def write_track(out, mode, cyl, head, nsect, sectsize_code, sectors, sector_base=1):
    """Write one track in IMD format."""
    out.write(bytes([mode, cyl, head, nsect, sectsize_code]))
    # Sector numbering map
    out.write(bytes(range(sector_base, sector_base + nsect)))
    # Sector data
    for s in sectors:
        out.write(b'\x01')  # normal data record
        out.write(s)

def convert(binpath, imdpath):
    with open(binpath, 'rb') as f:
        data = f.read()

    # Detect geometry from file size
    # Mini: T0S0=2048, T0S1=4096, then N tracks x 2 sides x 9 x 512
    t0s0_size = 16 * 128   # 2048
    t0s1_size = 16 * 256   # 4096
    track_size = 2 * 9 * 512  # 9216 per track (both sides)

    remaining = len(data) - t0s0_size - t0s1_size
    if remaining <= 0 or remaining % track_size != 0:
        print(f"ERROR: file size {len(data)} doesn't match mini disk geometry", file=sys.stderr)
        sys.exit(1)
    num_data_tracks = remaining // track_size
    total_tracks = 1 + num_data_tracks
    print(f"Geometry: {total_tracks} tracks (track 0 + {num_data_tracks} data tracks)")

    with open(imdpath, 'wb') as out:
        # IMD header
        header = f"IMD 1.18: RC702 raw2imd conversion\r\n"
        out.write(header.encode('ascii'))
        out.write(b'\x1a')

        pos = 0

        # Track 0, Side 0: FM, 16 sectors x 128 bytes
        sectors = []
        for s in range(16):
            sectors.append(data[pos:pos+128])
            pos += 128
        write_track(out, 0x02, 0, 0, 16, 0, sectors)

        # Track 0, Side 1: MFM, 16 sectors x 256 bytes
        sectors = []
        for s in range(16):
            sectors.append(data[pos:pos+256])
            pos += 256
        write_track(out, 0x05, 0, 1, 16, 1, sectors)

        # Tracks 1-N, both sides: MFM, 9 sectors x 512 bytes
        for cyl in range(1, total_tracks):
            for head in range(2):
                sectors = []
                for s in range(9):
                    sectors.append(data[pos:pos+512])
                    pos += 512
                write_track(out, 0x05, cyl, head, 9, 2, sectors)

        assert pos == len(data), f"pos={pos} != len={len(data)}"

    print(f"Wrote {imdpath} ({total_tracks} tracks, {total_tracks*2-1} track/sides)")

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <raw.bin> <output.imd>", file=sys.stderr)
        sys.exit(1)
    convert(sys.argv[1], sys.argv[2])
