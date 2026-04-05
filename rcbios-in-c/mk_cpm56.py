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


def build_checksum_loop():
    """Z80: sum A over (HL) for BC bytes.
    loop: ADD A,(HL) / INC HL / DEC BC / LD D,A / LD A,B / OR C / LD A,D / JR NZ,loop
    """
    return [0x86, 0x23, 0x0B, 0x57, 0x78, 0xB1, 0x7A, 0x20, 0xF7]


def build_validator(expected_sum, regions):
    """Build Z80 code that checksums multiple memory regions and prints OK/FAIL.

    regions: list of (addr, length) tuples to checksum consecutively.
    The 8-bit sum accumulates across all regions.
    """
    code = []
    # XOR A
    code += [0xAF]
    for addr, length in regions:
        # LD HL, addr; LD BC, length
        code += [0x21, addr & 0xFF, (addr >> 8) & 0xFF]
        code += [0x01, length & 0xFF, (length >> 8) & 0xFF]
        code += build_checksum_loop()
    # CP expected_sum
    code += [0xFE, expected_sum & 0xFF]
    # JR NZ, fail
    code += [0x20, 0x00]  # placeholder
    fail_jr_pos = len(code) - 1

    # OK: print "OK\r\n$" via BDOS
    for ch in "OK\r\n$":
        code += [0x1E, ord(ch), 0x0E, 0x02, 0xCD, 0x05, 0x00]
    code += [0xC9]  # RET

    # Patch JR NZ offset
    fail_start = len(code)
    code[fail_jr_pos] = (fail_start - (fail_jr_pos + 1)) & 0xFF

    # FAIL: print "FAIL\r\n$"
    for ch in "FAIL\r\n$":
        code += [0x1E, ord(ch), 0x0E, 0x02, 0xCD, 0x05, 0x00]
    code += [0xC9]  # RET

    return bytes(code)


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

    # Build checksum validator over CCP+BDOS + BIOS side0 + BIOS side1,
    # skipping the gap between side0 and side1.
    #
    # Memory layout (addresses = TPA + file offset):
    #   0x0900 .. 0x4500: CCP+BDOS (15360 bytes)
    #   0x4500 .. 0x5200: BIOS side 0 (SIDE0_SIZE = 3328 bytes)
    #   0x5200 .. 0x5F00: gap (GAP_SIZE = 3328 bytes) — NOT checksummed
    #   0x5F00 .. 0x5F00+s1_len: BIOS side 1
    ccpbdos_addr = LOADP                          # 0x0900
    ccpbdos_len  = T0_FILE_OFFSET - (LOADP - TPA) # 15360 bytes
    bios_s0_addr = TPA + T0_FILE_OFFSET            # 0x4500
    bios_s0_len  = s0_len
    bios_s1_addr = TPA + T0_FILE_OFFSET + SIDE0_SIZE + GAP_SIZE
    bios_s1_len  = max(0, len(cim) - SIDE0_SIZE)

    regions = [(ccpbdos_addr, ccpbdos_len),
               (bios_s0_addr, bios_s0_len)]
    if bios_s1_len > 0:
        regions.append((bios_s1_addr, bios_s1_len))

    # Compute expected checksum over the same data
    ccpbdos_off = LOADP - TPA
    checksum_data = (com[ccpbdos_off:ccpbdos_off + ccpbdos_len]
                   + com[T0_FILE_OFFSET:T0_FILE_OFFSET + s0_len]
                   + com[T0_FILE_OFFSET + SIDE0_SIZE + GAP_SIZE:
                         T0_FILE_OFFSET + SIDE0_SIZE + GAP_SIZE + bios_s1_len])
    expected_sum = sum(checksum_data) & 0xFF

    validator = build_validator(expected_sum, regions)
    total_checked = sum(length for _, length in regions)
    print(f"Validator: {len(validator)} bytes, checksum 0x{expected_sum:02X} "
          f"over {total_checked} bytes in {len(regions)} regions (gap skipped)")

    # Place validator at 0x0100 (file offset 0)
    com[0:len(validator)] = validator

    # Write patched .COM
    com_path = prefix + '.com'
    with open(com_path, 'wb') as f:
        f.write(com)
    print(f"Written: {com_path} ({len(com)} bytes)")

    # Generate Intel HEX:
    #   1. Validator at 0x0100 (small, always included)
    #   2. Payload from 0x0900 onward (CCP+BDOS+BIOS for SYSGEN)
    # Skip zero blocks to minimize file size.
    # Region 0x0100+validator_len..0x08FF is not emitted — LOAD fills with zeros.
    lines = []
    # Validator
    lines.extend(ihex_data(TPA, list(validator)))
    # Payload from 0x0900
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
    print(f"  CPM56                 (verify checksum — prints OK or FAIL)")
    print(f"  SYSGEN CPM56.COM      (skip read, write to destination)")


if __name__ == '__main__':
    main()
