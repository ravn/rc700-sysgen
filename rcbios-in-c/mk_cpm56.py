#!/usr/bin/env python3
"""Patch bios.cim into CPM56.COM and generate Intel HEX for CP/M transfer.

Takes the original CPM56.COM (extracted via SYSGEN+SAVE) and replaces
the track 0 (BIOS) portion with new BIOS data from bios.cim.
Outputs both a patched .COM and a .HEX file.

The HEX file can be transferred to CP/M via PIP and converted with LOAD.
Then SYSGEN CPM56.COM writes the system tracks to disk.

Usage:
    python3 mk_cpm56.py <cpm56_original.com> <bios.cim> <output_prefix>
"""

import sys

SIDE0_SIZE = 26 * 128   # 3328
GAP_SIZE   = 26 * 128   # 3328
SIDE1_SIZE = 26 * 256   # 6656

TPA   = 0x0100
LOADP = 0x0900
# In CPM56.COM file: track 0 starts at offset LOADP-TPA + 15360 = 0x4400
T0_FILE_OFFSET = (LOADP - TPA) + 15360  # 0x4400


def ihex_record(rtype, addr, data):
    length = len(data)
    record = [length, (addr >> 8) & 0xFF, addr & 0xFF, rtype] + list(data)
    checksum = (-sum(record)) & 0xFF
    return ':' + ''.join(f'{b:02X}' for b in record) + f'{checksum:02X}'


def ihex_data(addr, data, max_per_line=32):
    lines = []
    for offset in range(0, len(data), max_per_line):
        chunk = data[offset:offset + max_per_line]
        lines.append(ihex_record(0x00, addr + offset, chunk))
    return lines


def main():
    if len(sys.argv) != 4:
        print(f"usage: {sys.argv[0]} <cpm56_original.com> <bios.cim> <output_prefix>",
              file=sys.stderr)
        sys.exit(1)

    com = bytearray(open(sys.argv[1], 'rb').read())
    cim = open(sys.argv[2], 'rb').read()
    prefix = sys.argv[3]

    print(f"Original CPM56.COM: {len(com)} bytes")
    print(f"New BIOS (bios.cim): {len(cim)} bytes")

    # Patch track 0: side 0 + gap + side 1
    s0_len = min(len(cim), SIDE0_SIZE)
    com[T0_FILE_OFFSET:T0_FILE_OFFSET + s0_len] = cim[:s0_len]

    # Zero the gap
    gap_off = T0_FILE_OFFSET + SIDE0_SIZE
    com[gap_off:gap_off + GAP_SIZE] = bytes(GAP_SIZE)

    # Side 1 (only within original file bounds)
    if len(cim) > SIDE0_SIZE:
        s1_off = T0_FILE_OFFSET + SIDE0_SIZE + GAP_SIZE
        s1_data = cim[SIDE0_SIZE:]
        s1_end = min(s1_off + len(s1_data), len(com))
        com[s1_off:s1_end] = s1_data[:s1_end - s1_off]
        # Zero remainder within file bounds
        zero_start = s1_end
        zero_end = min(s1_off + SIDE1_SIZE, len(com))
        if zero_end > zero_start:
            com[zero_start:zero_end] = bytes(zero_end - zero_start)

    # Ensure RET at 0x0100 (file offset 0)
    com[0] = 0xC9

    # Write patched .COM
    com_path = prefix + '.com'
    with open(com_path, 'wb') as f:
        f.write(com)
    print(f"Written: {com_path} ({len(com)} bytes)")

    # Generate Intel HEX — only emit from LOADP (0x0900) onward.
    # SYSGEN pre-reads and discards bytes before LOADP, so they don't matter.
    # LOAD.COM fills unspecified addresses with zeros.
    # Skip zero blocks to minimize file size.
    lines = []
    payload_start = LOADP - TPA  # file offset 0x0800
    for offset in range(payload_start, len(com), 32):
        chunk = com[offset:offset + 32]
        if any(b != 0 for b in chunk):
            lines.append(ihex_record(0x00, TPA + offset, chunk))
    lines.append(ihex_record(0x00, 0x0000, []))  # CP/M EOF

    hex_path = prefix + '.hex'
    with open(hex_path, 'w') as f:
        f.write('\r\n'.join(lines) + '\r\n')
    print(f"Written: {hex_path} ({len(lines)} records)")

    print(f"\nCP/M workflow:")
    print(f"  PIP CPM56.HEX=RDR:   (download over serial)")
    print(f"  LOAD CPM56            (creates CPM56.COM)")
    print(f"  SYSGEN CPM56.COM      (writes system tracks)")


if __name__ == '__main__':
    main()
