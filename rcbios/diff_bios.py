#!/usr/bin/env python3
"""Compare rel.2.1 and rel.2.2 BIOS reference binaries instruction by instruction.

Strategy: Walk through both binaries simultaneously, tracking the expected address
shift. When instructions match (same opcode, addresses differ by the expected shift),
they're considered equivalent. When they don't match, the difference is genuine.

The shift starts at 0 and changes at known insertion points:
- After SIGNON: +1 (longer version string)
- After LINSEL delay insertion: +7 total (+6 more)

Usage: python3 diff_bios.py
"""

import sys
import struct


def load_bin(path):
    with open(path, 'rb') as f:
        return f.read()


BASE = 0xDA00


def z80_insn_len(data, off):
    """Return instruction length at given offset."""
    if off >= len(data):
        return 1
    b = data[off]
    if b in (0xCB, 0xED):
        if off + 1 >= len(data):
            return 2
        b2 = data[off + 1]
        if b == 0xED:
            # 4-byte ED instructions: LD (nn),rr / LD rr,(nn)
            if b2 & 0xCF in (0x43, 0x4B):
                return 4
            return 2
        return 2  # CB prefix
    if b in (0xDD, 0xFD):
        # IX/IY prefix - simplistic
        if off + 1 >= len(data):
            return 2
        b2 = data[off + 1]
        if b2 == 0xCB:
            return 4
        if b2 in (0x21, 0x22, 0x2A, 0x36, 0xE5, 0xE1):
            return 4 if b2 in (0x22, 0x2A, 0x36) else 3 if b2 == 0x21 else 2
        return 2
    # Single byte
    single_byte = {
        0x00, 0x02, 0x03, 0x04, 0x05, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0F,
        0x12, 0x13, 0x14, 0x15, 0x17, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1F,
        0x23, 0x24, 0x25, 0x27, 0x29, 0x2B, 0x2C, 0x2D, 0x2F,
        0x33, 0x34, 0x35, 0x37, 0x39, 0x3B, 0x3C, 0x3D, 0x3F,
        0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,
        0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F,
        0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57,
        0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F,
        0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,
        0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F,
        0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77,
        0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F,
        0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,
        0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F,
        0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97,
        0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F,
        0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7,
        0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF,
        0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7,
        0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF,
        0xC0, 0xC1, 0xC5, 0xC8, 0xC9, 0xD0, 0xD1, 0xD5, 0xD8, 0xD9,
        0xE0, 0xE1, 0xE3, 0xE5, 0xE8, 0xE9, 0xEB, 0xF0, 0xF1, 0xF3,
        0xF5, 0xF8, 0xF9, 0xFB,
    }
    if b in single_byte:
        return 1
    # 2-byte: immediate byte, relative jump, RST
    two_byte = {
        0x06, 0x0E, 0x10, 0x16, 0x18, 0x1E, 0x20, 0x26, 0x28, 0x2E,
        0x30, 0x36, 0x38, 0x3E,
        0xC6, 0xCE, 0xD3, 0xD6, 0xDB, 0xDE, 0xE6, 0xEE, 0xF6, 0xFE,
    }
    if b in two_byte:
        return 2
    # RST instructions
    if b & 0xC7 == 0xC7:
        return 1
    # 3-byte: JP, CALL, LD with 16-bit immediate/address
    return 3


def hexbytes(data, off, length):
    return ' '.join(f'{data[off+i]:02X}' for i in range(min(length, len(data)-off)))


def main():
    ref21 = load_bin('rccpm22_bios.bin')
    ref22 = load_bin('cpm22_rel22_bios.bin')

    # Find key landmarks
    signon21 = ref21.find(b'rel.2.1')
    signon22 = ref22.find(b'rel. 2.2')
    print(f"Signon end in rel.2.1: offset 0x{signon21+7:04X}")
    print(f"Signon end in rel.2.2: offset 0x{signon22+8:04X}")

    # Expected shift progression:
    # Before signon end: shift = 0
    # After signon end: shift = +1
    # After LINSEL delay: shift = +7

    # First: compare the non-shifting fixed area (jump table + vars + extended entries)
    print(f"\n{'='*72}")
    print("FIXED AREA (jump table + variables + extended entries)")
    print(f"{'='*72}")

    # Check jumptable address operands
    print("\nJump table address comparison:")
    for i in range(0, 0x30, 3):
        assert ref21[i] == 0xC3 and ref22[i] == 0xC3
        a21 = ref21[i+1] | (ref21[i+2] << 8)
        a22 = ref22[i+1] | (ref22[i+2] << 8)
        delta = a22 - a21
        label = ["BOOT","WBOOT","CONST","CONIN","CONOUT","LIST","PUNCH","READER",
                 "HOME","SELD","SETT","SETS","SETD","XREAD","XWRITE","STLIST","SECTRA"][i//3]
        flag = "" if delta == 7 else f"  *** EXPECTED +7, GOT {delta:+d}"
        print(f"  {label:8s}: 0x{a21:04X} -> 0x{a22:04X} ({delta:+d}){flag}")

    # Variables area
    print("\nConfig/variables (offsets 0x30-0x47):")
    for i in range(0x30, 0x48):
        if ref21[i] != ref22[i]:
            labels = {0x30: "ADRMOD", 0x31: "WR5A", 0x32: "WR5B", 0x33: "MTYPE",
                     0x44: "BOOTD", 0x45: "reserved", 0x46: "reserved"}
            if 0x34 <= i <= 0x43:
                label = f"FD{i-0x34}"
            else:
                label = labels.get(i, f"off_{i:02X}")
            print(f"  0x{i:04X} {label}: 0x{ref21[i]:02X} -> 0x{ref22[i]:02X}")

    # Reserved bytes at 0x45-0x46 (DS 2) and 0x48-0x49
    # Actually 0x48-0x49 is DS 2, 0x45-0x46 is part of BOOTD area
    # Let me recheck from listing

    # Extended jump entries
    print("\nExtended entries (offsets 0x4A-0x5B):")
    names = ["WFITR", "READS", "LINSEL", "EXIT", "CLOCK", "HRDFMT"]
    for j, i in enumerate(range(0x4A, 0x5C, 3)):
        assert ref21[i] == 0xC3 and ref22[i] == 0xC3
        a21 = ref21[i+1] | (ref21[i+2] << 8)
        a22 = ref22[i+1] | (ref22[i+2] << 8)
        delta = a22 - a21
        # Expected: depends on where the function is
        # LINSEL, EXIT, CLOCK are before the LINSEL +6 insertion, so shift = +1
        # WFITR, READS are after, so shift = +7
        # HRDFMT is special
        print(f"  {names[j]:8s}: 0x{a21:04X} -> 0x{a22:04X} ({delta:+d})")

    # Reserved DS 2 bytes at offset 0x48
    print(f"\nReserved bytes at 0x48-0x49:")
    print(f"  rel.2.1: {ref21[0x48]:02X} {ref21[0x49]:02X}")
    print(f"  rel.2.2: {ref22[0x48]:02X} {ref22[0x49]:02X}")

    # PAD1 area (DS 16 at offsets 0x5C-0x6B + DB 0,0,0 at 0x6C-0x6E)
    print(f"\nPAD1 area (offsets 0x5C-0x6E):")
    print(f"  rel.2.1: {hexbytes(ref21, 0x5C, 19)} (all zeros)")
    print(f"  rel.2.2: {hexbytes(ref22, 0x5C, 19)}")
    # Disassemble rel.2.2 PAD1
    pos = 0x5C
    while pos < 0x6F:
        if ref22[pos] == 0 and all(ref22[pos+j] == 0 for j in range(min(3, 0x6F-pos))):
            break
        length = z80_insn_len(ref22, pos)
        print(f"    {BASE+pos:04X}: {hexbytes(ref22, pos, length)}")
        pos += length

    # PCHSAV area
    print(f"\nPCHSAV at offset 0x6F-0x70:")
    print(f"  rel.2.1: {ref21[0x6F]:02X} {ref21[0x70]:02X}")
    print(f"  rel.2.2: {ref22[0x6F]:02X} {ref22[0x70]:02X}")

    # Now do the big comparison: walk through the code portion
    # starting after BOTMSG/messages, comparing with appropriate shift
    print(f"\n{'='*72}")
    print("CODE COMPARISON (instruction-level)")
    print(f"{'='*72}")

    # The messages start at offset 0x71 (BOTMSG)
    # They include BOTMSG, SIGNON, WMESS, HDERR — these are strings
    # After HDERR comes PRMSG (code)

    # Find where code starts after messages
    # HDERR ends with 0D 0A 00. Find it.
    hderr_str = b'Cannot read configuration record'
    h21 = ref21.find(hderr_str)
    h22 = ref22.find(hderr_str)
    # End of HDERR: after the string + CR LF NUL
    hderr_end21 = h21 + len(hderr_str) + 3  # +CR+LF+NUL
    hderr_end22 = h22 + len(hderr_str) + 3
    print(f"HDERR end: offset 0x{hderr_end21:04X} (r21) / 0x{hderr_end22:04X} (r22), delta={hderr_end22-hderr_end21:+d}")

    # Compare message area
    print(f"\nMessage area comparison (offsets 0x71 to ~0xE0):")
    msg_diffs = []
    for i in range(0x71, min(hderr_end21, hderr_end22)):
        if ref21[i] != ref22[i]:
            msg_diffs.append(i)
    if not msg_diffs:
        print("  Messages before signon: identical")
    else:
        print(f"  {len(msg_diffs)} differences in message area")
        for i in msg_diffs:
            print(f"    0x{i:04X}: 0x{ref21[i]:02X} -> 0x{ref22[i]:02X} ('{chr(ref21[i]) if 32<=ref21[i]<127 else '?'}' -> '{chr(ref22[i]) if 32<=ref22[i]<127 else '?'}')")

    # Now walk through code section with shift tracking
    # Start from the end of HDERR where code begins
    # The shift at this point is +1 (from signon)

    # PRMSG starts right after HDERR
    code_start_21 = hderr_end21
    code_start_22 = hderr_end22

    print(f"\nCode starts at: offset 0x{code_start_21:04X} (r21) / 0x{code_start_22:04X} (r22)")
    print(f"Current shift: {code_start_22 - code_start_21:+d}")

    # Walk instructions in parallel
    p21 = code_start_21
    p22 = code_start_22
    genuine_diffs = []
    addr_prop_count = 0
    identical_count = 0

    # We need the end of the code portion (before DISKTAB data and DPBASE)
    # DPBASE is near offset 0x1178 in rel.2.1 (from listing: EB78 - DA00 = 0x1178)
    # Let's find EI;RETI (FB ED 4D) which marks DUMITR just after DPBASE
    dumitr21 = ref21.find(bytes([0xFB, 0xED, 0x4D]), 0x1000)
    dumitr22 = ref22.find(bytes([0xFB, 0xED, 0x4D]), 0x1000)
    dpbase21 = dumitr21 - 112 if dumitr21 > 0 else len(ref21)
    dpbase22 = dumitr22 - 112 if dumitr22 > 0 else len(ref22)
    print(f"DPBASE: offset 0x{dpbase21:04X} (r21) / 0x{dpbase22:04X} (r22)")

    # Walk until we reach the data tables
    while p21 < dpbase21 and p22 < dpbase22:
        len21 = z80_insn_len(ref21, p21)
        len22 = z80_insn_len(ref22, p22)

        # Get instruction bytes
        bytes21 = ref21[p21:p21+len21]
        bytes22 = ref22[p22:p22+len22]

        if bytes21 == bytes22:
            # Identical instruction (including any addresses)
            identical_count += 1
            p21 += len21
            p22 += len22
            continue

        if len21 == len22 and len21 >= 3 and bytes21[0] == bytes22[0]:
            # Same opcode, possibly different address
            # Check if address bytes differ by the current shift
            shift = p22 - p21
            if len21 == 3:
                a21 = bytes21[1] | (bytes21[2] << 8)
                a22 = bytes22[1] | (bytes22[2] << 8)
                if a22 - a21 == shift:
                    addr_prop_count += 1
                    p21 += len21
                    p22 += len22
                    continue
            elif len21 == 4 and bytes21[0] == 0xED and bytes21[1] == bytes22[1]:
                a21 = bytes21[2] | (bytes21[3] << 8)
                a22 = bytes22[2] | (bytes22[3] << 8)
                if a22 - a21 == shift:
                    addr_prop_count += 1
                    p21 += len21
                    p22 += len22
                    continue

        # Also check for address propagation in RAM variables
        # Variables are at ~0xF300+ and shift differently
        if len21 == len22 and len21 >= 3 and bytes21[0] == bytes22[0]:
            shift = p22 - p21
            if len21 == 3:
                a21 = bytes21[1] | (bytes21[2] << 8)
                a22 = bytes22[1] | (bytes22[2] << 8)
                delta = a22 - a21
                # RAM variables shift by a different amount than code
                # Accept any consistent shift for addresses in RAM variable area (0xEE80+)
                if a21 >= 0xEE80 and delta > 0 and delta < 64:
                    addr_prop_count += 1
                    p21 += len21
                    p22 += len22
                    continue
            elif len21 == 4 and bytes21[0] == 0xED and bytes21[1] == bytes22[1]:
                a21 = bytes21[2] | (bytes21[3] << 8)
                a22 = bytes22[2] | (bytes22[3] << 8)
                delta = a22 - a21
                if a21 >= 0xEE80 and delta > 0 and delta < 64:
                    addr_prop_count += 1
                    p21 += len21
                    p22 += len22
                    continue

        # Genuine difference
        genuine_diffs.append((p21, p22, bytes21, bytes22))
        p21 += len21
        p22 += len22

    print(f"\nInstruction comparison results:")
    print(f"  Identical: {identical_count}")
    print(f"  Address propagation: {addr_prop_count}")
    print(f"  Genuine differences: {len(genuine_diffs)}")
    print(f"  Final shift: {p22 - p21:+d}")

    if genuine_diffs:
        # Group by approximate module
        print(f"\n{'='*72}")
        print("GENUINE INSTRUCTION DIFFERENCES")
        print(f"{'='*72}")

        # Module boundaries (approximate, from rel.2.1)
        modules = [
            (0x00E1, 0x01C1, "CPMBOOT (code)"),
            (0x0280, 0x0300, "SIO"),
            (0x0300, 0x0700, "DISPLAY"),
            (0x0700, 0x0930, "FLOPPY"),
            (0x0930, 0x0B30, "HARDDSK"),
            (0x0B30, 0x1178, "DISKTAB"),
        ]

        for off21, off22, b21, b22 in genuine_diffs:
            mod = "UNKNOWN"
            for mstart, mend, mname in modules:
                if mstart <= off21 < mend:
                    mod = mname
                    break
            h21 = ' '.join(f'{b:02X}' for b in b21)
            h22 = ' '.join(f'{b:02X}' for b in b22)
            print(f"  {BASE+off21:04X}/{BASE+off22:04X} [{h21:12s}] -> [{h22:12s}]  ({mod})")

    # Compare data tables section (DISKTAB area)
    print(f"\n{'='*72}")
    print("DATA TABLES COMPARISON (DISKTAB area)")
    print(f"{'='*72}")

    # Walk the DISKTAB/data area from where code ends to DPBASE
    # These are data bytes, not instructions
    # First find where DISKTAB starts by looking for the sector translation tables
    tran0_21 = ref21.find(bytes([1, 7, 13, 19, 25, 5, 11, 17]))
    tran0_22 = ref22.find(bytes([1, 7, 13, 19, 25, 5, 11, 17]))
    if tran0_21 >= 0 and tran0_22 >= 0:
        print(f"TRAN0: offset 0x{tran0_21:04X} (r21) / 0x{tran0_22:04X} (r22)")

        # Compare data from TRAN0 to DPBASE
        shift = tran0_22 - tran0_21
        data_diffs = []
        for i in range(min(dpbase21 - tran0_21, dpbase22 - tran0_22)):
            if ref21[tran0_21 + i] != ref22[tran0_22 + i]:
                data_diffs.append(i)

        if data_diffs:
            print(f"  {len(data_diffs)} data byte differences (shift={shift:+d})")
            for i in data_diffs:
                off21 = tran0_21 + i
                off22 = tran0_22 + i
                v21 = ref21[off21]
                v22 = ref22[off22]
                # Check if it's an address byte (DW pointer in a table)
                print(f"    0x{BASE+off21:04X}/0x{BASE+off22:04X}: 0x{v21:02X} -> 0x{v22:02X}")
        else:
            print(f"  All data bytes identical (with shift={shift:+d})")
    else:
        print("  Could not find TRAN0 pattern")


if __name__ == '__main__':
    main()
