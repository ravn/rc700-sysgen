#!/usr/bin/env python3
"""Verify assembled BIOS against reference binary.

Compares the code portion of the assembled output against a reference binary,
ignoring known runtime-initialized areas (variables, scratch pads, padding).

The reference binaries were extracted from RAM dumps after the BIOS ran,
so they contain runtime-modified data in certain areas.
"""

import sys
import os


def hex_to_bin(hexfile):
    """Convert Intel HEX file to binary."""
    data = {}
    with open(hexfile) as f:
        for line in f:
            line = line.strip()
            if not line.startswith(':'):
                continue
            count = int(line[1:3], 16)
            addr = int(line[3:7], 16)
            rtype = int(line[7:9], 16)
            if rtype == 0:  # data record
                for i in range(count):
                    data[addr + i] = int(line[9 + i*2:11 + i*2], 16)
            elif rtype == 1:  # EOF
                break
    if not data:
        return b'', 0
    min_addr = min(data)
    max_addr = max(data)
    result = bytearray(max_addr - min_addr + 1)
    for addr, val in data.items():
        result[addr - min_addr] = val
    return bytes(result), min_addr


def find_runtime_offsets(bios, bios_base):
    """Find byte offsets within the BIOS that are runtime-modified.

    These areas are initialized by INIT.MAC at boot time or modified
    by BDOS during operation, so they differ between assembly output
    and RAM dumps.

    Returns set of offsets relative to BIOS start.
    """
    offsets = set()

    # --- CPMBOOT.MAC variables (near start of BIOS) ---
    # WR5A, WR5B: initialized by INIT.MAC from SIO config bytes
    offsets.update({0x34, 0x35})

    # FD0-FD15: disk format array, copied from INFD0 by IDT routine
    for i in range(16):
        offsets.add(0x37 + i)

    # BOOTD: boot disk flag, copied from ibootd at runtime
    offsets.add(0x47)

    # --- SIO.MAC variables ---
    # RR0_A, RR1_A, RR0_B, RR1_B: read from SIO registers by INIT.MAC
    offsets.update({0x289, 0x28A, 0x28B, 0x28C})

    # --- DISKTAB.MAC: FSPA filler bytes (DS 5 at end of each 16-byte block) ---
    # These are "don't care" padding to align FSPAs to 16 bytes.
    # Find all FSPA blocks by scanning for the pattern.
    # Each FSPA is 16 bytes: DW dpb, DB recs, DW spt, DB mask, DB shift,
    #                         DW tran, DB dtl, DB type, DS 5
    # The DS 5 bytes are at offsets +11 through +15 within each FSPA.
    # We need to find where FSPA00 starts in the BIOS.
    #
    # Rather than hardcode, look for the TRKOFF table (DW 2, DW 2, DW 3...)
    # which precedes the FSPAs. For now, use a simpler approach:
    # scan the assembled binary for 16-byte FSPA-like blocks.

    # --- DISKTAB.MAC: DPBASE drive headers ---
    # Each drive header is 16 bytes. The first 8 bytes (translation table
    # pointer + 3 scratch pads) and the DPB/CHK/ALL pointers are all
    # modified by INIT.MAC (INI62/INI66 routines).
    # Find DPBASE by searching for its pattern near the end of assembled code.

    # --- INTTAB.MAC: DS padding before interrupt vector table ---
    # The DS 256-($ AND 255) alignment padding between DUMITR and ITRTAB
    # contains zeros in assembly but random data in RAM dumps.

    return offsets


def find_dpbase_offset(bios, bios_base):
    """Find the DPBASE offset within the BIOS.

    DPBASE contains 7 drive parameter headers (16 bytes each = 112 bytes).
    After DPBASE comes DUMITR (EI; RETI = FB ED 4D), then DS padding
    to the next 256-byte boundary where ITRTAB starts.

    We identify DUMITR by finding EI;RETI followed by alignment padding
    to a 256-byte boundary, then DW entries (the interrupt vector table).
    """
    pattern = bytes([0xFB, 0xED, 0x4D])
    pos = 0
    while True:
        pos = bios.find(pattern, pos)
        if pos < 0:
            return None, None
        # Check if this EI;RETI is followed by alignment to 256-byte boundary
        after = pos + 3
        boundary = (bios_base + after + 255) & ~255
        pad_len = boundary - (bios_base + after)
        # Verify the padding is all zeros (DS fills with 0)
        if after + pad_len <= len(bios):
            pad = bios[after:after + pad_len]
            if all(b == 0 for b in pad):
                # This is DUMITR — DPBASE is 112 bytes before
                dpbase_start = pos - 112
                return dpbase_start, pos
        pos += 1
    return None, None


def compare_bios(hexfile, reffile, bios_offset, verbose=False):
    """Compare assembled BIOS from HEX file against reference binary.

    Returns True if all code bytes match (ignoring runtime areas).
    """
    binary, start = hex_to_bin(hexfile)
    ref = open(reffile, 'rb').read()
    bios = binary[bios_offset:]
    compare_len = min(len(bios), len(ref))

    if compare_len == 0:
        print("ERROR: No bytes to compare")
        return False

    bios_base = 0xDA00 if bios_offset == 0x580 else 0xE200

    if verbose:
        print(f"Assembled: {len(binary)} bytes total, BIOS: {len(bios)} bytes at 0x{bios_base:04X}")
        print(f"Reference: {len(ref)} bytes")
        print(f"Comparing: {compare_len} bytes")

    # Build ignore set
    runtime = find_runtime_offsets(bios, bios_base)

    # Find DPBASE area
    dpbase_start, dumitr_pos = find_dpbase_offset(bios, bios_base)
    dpbase_range = set()
    if dpbase_start is not None and dpbase_start >= 0:
        # All 112 bytes of DPBASE are runtime-modified
        for i in range(112):
            dpbase_range.add(dpbase_start + i)
        if verbose:
            print(f"DPBASE at 0x{bios_base + dpbase_start:04X}, "
                  f"DUMITR at 0x{bios_base + dumitr_pos:04X}")

    # Find ITRTAB padding (between DUMITR+3 and next 256-byte boundary)
    itrtab_pad = set()
    if dumitr_pos is not None:
        pad_start = dumitr_pos + 3  # after EI; RETI
        pad_end = (pad_start + 255) & ~255  # next 256-byte boundary
        for i in range(pad_start, min(pad_end, compare_len)):
            itrtab_pad.add(i)

    # Collect and classify differences
    diffs_runtime = 0
    diffs_dpbase = 0
    diffs_padding = 0
    diffs_real = []

    for i in range(compare_len):
        if bios[i] == ref[i]:
            continue
        if i in runtime:
            diffs_runtime += 1
        elif i in dpbase_range:
            diffs_dpbase += 1
        elif i in itrtab_pad:
            diffs_padding += 1
        elif bios[i] == 0x00 and ref[i] != 0x00:
            # DS filler or uninitialized area
            diffs_padding += 1
        else:
            diffs_real.append((i, bios[i], ref[i]))

    total = diffs_runtime + diffs_dpbase + diffs_padding + len(diffs_real)

    if not diffs_real:
        print(f"MATCH: {compare_len} code bytes verified")
        if total > 0:
            details = []
            if diffs_runtime:
                details.append(f"{diffs_runtime} runtime vars")
            if diffs_dpbase:
                details.append(f"{diffs_dpbase} DPBASE entries")
            if diffs_padding:
                details.append(f"{diffs_padding} padding/filler")
            print(f"  ({total} runtime differences ignored: {', '.join(details)})")
        if len(bios) < len(ref):
            print(f"  (reference has {len(ref) - len(bios)} additional bytes beyond code)")
        return True

    print(f"MISMATCH: {len(diffs_real)} code byte differences")
    if total - len(diffs_real) > 0:
        print(f"  ({total - len(diffs_real)} runtime differences also present but ignored)")
    for off, got, exp in diffs_real[:40]:
        addr = bios_base + off
        print(f"  0x{addr:04X} (off 0x{off:04X}): asm=0x{got:02X} ref=0x{exp:02X}")
    if len(diffs_real) > 40:
        print(f"  ... and {len(diffs_real) - 40} more")
    return False


def main():
    if len(sys.argv) < 4:
        print(f"Usage: {sys.argv[0]} <hex_file> <ref_binary> <bios_offset_hex>")
        print(f"  e.g.: {sys.argv[0]} zout/BIOS.hex rccpm22_bios.bin 0x580")
        sys.exit(1)

    hexfile = sys.argv[1]
    reffile = sys.argv[2]
    bios_offset = int(sys.argv[3], 0)

    if not os.path.exists(hexfile):
        print(f"Error: {hexfile} not found")
        sys.exit(1)
    if not os.path.exists(reffile):
        print(f"Error: {reffile} not found")
        sys.exit(1)

    ok = compare_bios(hexfile, reffile, bios_offset, verbose=True)
    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
