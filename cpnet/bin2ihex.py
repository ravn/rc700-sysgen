#!/usr/bin/env python3
"""Convert a binary file to Intel HEX format (for CP/M LOAD.COM).

Usage:
  python3 bin2ihex.py input.bin [base_hex] > output.hex
  python3 bin2ihex.py input.bin [base_hex] -o output.hex

Default base address: 0x0100 (CP/M TPA, correct for .COM files).
"""
import sys

def to_ihex(data, base_addr=0x0100, record_len=16):
    lines = []
    for i in range(0, len(data), record_len):
        chunk = data[i:i+record_len]
        addr = base_addr + i
        record = bytearray([len(chunk), (addr >> 8) & 0xFF, addr & 0xFF, 0x00]) + bytearray(chunk)
        checksum = (-sum(record)) & 0xFF
        lines.append(':' + record.hex().upper() + f'{checksum:02X}')
    lines.append(':00000001FF')
    return '\r'.join(lines) + '\r'

if __name__ == '__main__':
    args = sys.argv[1:]
    out_file = None
    if '-o' in args:
        idx = args.index('-o')
        out_file = args[idx + 1]
        args = args[:idx] + args[idx+2:]

    if not args:
        print(f'Usage: {sys.argv[0]} input.bin [base_hex] [-o output.hex]', file=sys.stderr)
        sys.exit(1)

    in_file = args[0]
    base = int(args[1], 16) if len(args) > 1 else 0x0100

    with open(in_file, 'rb') as f:
        data = f.read()

    hex_text = to_ihex(data, base)

    if out_file:
        with open(out_file, 'w', newline='') as f:
            f.write(hex_text)
        print(f'Wrote {len(data)} bytes as Intel HEX to {out_file}', file=sys.stderr)
    else:
        sys.stdout.write(hex_text)
