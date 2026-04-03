#!/usr/bin/env python3
"""Generate Intel HEX for SYSGEN BIOS install via PIP+LOAD.

Creates a HEX file that, when LOADed and run as a .COM:
  - At 0x0100: checksum validator that verifies the payload at 0x4500,
    prints OK/FAIL, then exits
  - Places BIOS track 0 data at 0x4500 in SYSGEN's memory layout
    (side0 FM + 3328B gap + side1 MFM)

The workflow:
  1. SYSGEN read A: (loads CCP+BDOS at 0x0900)
  2. PIP BIOS.HEX=RDR: (receives this file over serial)
  3. LOAD BIOS (creates BIOS.COM, loads data into memory)
  4. BIOS (runs .COM — validates checksum, prints result, exits.
     Memory at 0x4500 is set regardless.)
  5. SYSGEN (skip read, write A:)

Usage:
    python3 mk_sysgen_hex.py bios.cim sysgen_bios.hex
"""

import sys

SIDE0_SIZE = 26 * 128   # 3328 bytes (FM side 0)
GAP_SIZE   = 26 * 128   # 3328 bytes (gap)
SIDE1_SIZE = 26 * 256   # 6656 bytes (MFM side 1)
T0_SIZE    = SIDE0_SIZE + GAP_SIZE + SIDE1_SIZE  # 13312

COM_BASE   = 0x0100     # CP/M .COM load address
T0_ADDR    = 0x4500     # SYSGEN track 0 location in memory


def ihex_record(rtype, addr, data):
    """Format one Intel HEX record."""
    length = len(data)
    record = [length, (addr >> 8) & 0xFF, addr & 0xFF, rtype] + list(data)
    checksum = (-sum(record)) & 0xFF
    hex_bytes = ''.join(f'{b:02X}' for b in record)
    return f':{hex_bytes}{checksum:02X}'


def ihex_data(addr, data, max_per_line=16):
    """Generate Intel HEX data records for a block of data."""
    lines = []
    offset = 0
    while offset < len(data):
        chunk = data[offset:offset + max_per_line]
        lines.append(ihex_record(0x00, addr + offset, chunk))
        offset += len(chunk)
    return lines


def build_checksum_loop():
    """Return Z80 bytes for: sum A over (HL) for BC bytes, clobbers D.
    loop: ADD A,(HL) / INC HL / DEC BC / LD D,A / LD A,B / OR C / LD A,D / JR NZ,loop
    JR NZ offset: from PC after JR (= loop+9), back to loop (= loop+0) = -9 = 0xF7
    """
    return [0x86, 0x23, 0x0B, 0x57, 0x78, 0xB1, 0x7A, 0x20, 0xF7]


def build_split_validator(expected_sum, addr1, len1, addr2, len2):
    """Build Z80 code that checksums two memory regions and prints OK/FAIL.

    Checksums addr1..addr1+len1 and addr2..addr2+len2, compares combined
    8-bit sum against expected_sum.
    """
    code = []
    # XOR A
    code += [0xAF]
    # LD HL, addr1; LD BC, len1
    code += [0x21, addr1 & 0xFF, (addr1 >> 8) & 0xFF]
    code += [0x01, len1 & 0xFF, (len1 >> 8) & 0xFF]
    # Checksum loop 1
    code += build_checksum_loop()
    # A now has partial sum; continue with region 2
    if len2 > 0:
        # LD HL, addr2; LD BC, len2
        code += [0x21, addr2 & 0xFF, (addr2 >> 8) & 0xFF]
        code += [0x01, len2 & 0xFF, (len2 >> 8) & 0xFF]
        # Checksum loop 2 (A carries over)
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
    if len(sys.argv) != 3:
        print(f"usage: {sys.argv[0]} <bios.cim> <output.hex>", file=sys.stderr)
        sys.exit(1)

    cim = open(sys.argv[1], 'rb').read()
    print(f"bios.cim: {len(cim)} bytes")

    if len(cim) > SIDE0_SIZE + SIDE1_SIZE:
        print(f"ERROR: bios.cim too large ({len(cim)}B > {SIDE0_SIZE + SIDE1_SIZE}B)",
              file=sys.stderr)
        sys.exit(1)

    # Checksum over bios.cim only (the actual payload)
    expected_sum = sum(cim) & 0xFF
    print(f"Payload checksum: 0x{expected_sum:02X} (sum of {len(cim)} bytes)")

    # Build validator code — checksums bios.cim bytes at their SYSGEN addresses:
    #   side 0 at T0_ADDR (3328 bytes), side 1 at T0_ADDR+SIDE0_SIZE+GAP_SIZE
    # For simplicity, checksum side 0 and side 1 separately and combine.
    # Actually, just checksum side 0 (at 0x4500) + side 1 (at 0x5F00) = bios.cim
    s0_len = min(len(cim), SIDE0_SIZE)
    s1_len = max(0, len(cim) - SIDE0_SIZE)
    validator = build_split_validator(expected_sum, T0_ADDR, s0_len,
                                      T0_ADDR + SIDE0_SIZE + GAP_SIZE, s1_len)
    print(f"Validator: {len(validator)} bytes at 0x{COM_BASE:04X}")

    lines = []

    # Validator code at 0x0100
    lines.extend(ihex_data(COM_BASE, list(validator)))

    # Side 0 FM data at 0x4500
    s0_data = cim[:s0_len]
    s1_data = cim[SIDE0_SIZE:] if len(cim) > SIDE0_SIZE else b''
    lines.extend(ihex_data(T0_ADDR, s0_data))

    # Gap is zeros — not included in HEX (SYSGEN buffer already has zeros
    # from the SYSGEN read, or it doesn't matter since the BIOS doesn't use
    # these sectors).

    # Side 1 MFM data at 0x5F00 (only actual data, no padding)
    if len(cim) > SIDE0_SIZE:
        s1_addr = T0_ADDR + SIDE0_SIZE + GAP_SIZE
        lines.extend(ihex_data(s1_addr, s1_data))

    # CP/M EOF: zero-length data record (type 00), not Intel type 01
    lines.append(ihex_record(0x00, 0x0000, []))

    hex_content = '\r\n'.join(lines) + '\r\n'
    # Also write a CR-only version for CP/M serial transfer
    hex_content_cr = '\r'.join(lines) + '\r'
    cr_path = sys.argv[2].replace('.hex', '_cr.hex')
    with open(cr_path, 'wb') as f:
        f.write(hex_content_cr.encode('ascii'))
    print(f"CR-only: {cr_path}")

    with open(sys.argv[2], 'w') as f:
        f.write(hex_content)

    total_data = len(validator) + len(s0_data) + (len(cim) - SIDE0_SIZE if len(cim) > SIDE0_SIZE else 0)
    print(f"HEX file: {len(lines)} records, {total_data} data bytes")
    print(f"  0x{COM_BASE:04X}: validator ({len(validator)} bytes)")
    print(f"  0x{T0_ADDR:04X}: side 0 ({len(s0_data)} bytes)")
    s1_used = max(0, len(cim) - SIDE0_SIZE)
    if s1_used:
        print(f"  0x{T0_ADDR + SIDE0_SIZE + GAP_SIZE:04X}: side 1 ({s1_used} bytes)")
    print(f"Written: {sys.argv[2]}")


if __name__ == '__main__':
    main()
