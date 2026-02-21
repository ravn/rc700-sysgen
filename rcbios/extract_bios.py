#!/usr/bin/env python3
"""Extract BIOS regions from RC702 RAM dumps.

Usage: python3 extract_bios.py [output_dir]
"""

import os
import sys

DUMPS = [
    ('rccpm22_ram.bin',     'rccpm22_bios.bin',     0xDA00),
    ('cpm22_rel22_ram.bin', 'cpm22_rel22_bios.bin', 0xDA00),
    ('compas_ram.bin',      'compas_bios.bin',       0xE200),
]

DISPLAY_BUFFER = 0xF800

out_dir = sys.argv[1] if len(sys.argv) > 1 else ''

for ram_file, bios_file, base in DUMPS:
    try:
        d = open(ram_file, 'rb').read()
    except FileNotFoundError:
        print(f"  skip {ram_file} (not found)")
        continue

    # Find last non-zero byte before display buffer
    end = DISPLAY_BUFFER
    while end > base and d[end - 1] == 0:
        end -= 1

    bios = d[base:end]
    out_path = os.path.join(out_dir, bios_file)
    open(out_path, 'wb').write(bios)
    print(f"  {out_path}: {len(bios)} bytes (0x{base:04X}-0x{end - 1:04X})")
