#!/usr/bin/env python3
"""Generate RC703 rel.1.0 BIOS zmac source from extracted binary.

The RC703 rel.1.0 is in MAXI format (8" multi-density):
- Binary starts at disk offset 0 (full Track 0)
- ORG = D480 (post-relocation address)
- BIOS jump table at D780 (offset 0x300)
- 9344 bytes total (5504 code/data + 3840 COMAL-80 residual tail)

Compared to rel.1.2 (QD format):
- 1-byte longer signon string
- No LINSEL timing fix (6 bytes shorter)
- No RC763 HD identification table
- 6 extended BIOS entries (not 7)
- MAXI-format DPBs instead of QD
- Tail contains COMAL-80 error messages (not VERIFY utility)

Usage:
    python3 mkbios_rel10.py ../extracted_bios/cpm22_56k_rel1.0_rc703_maxi.bin
"""

import sys, subprocess, os, re

ORG = 0xD480
BINSIZE = 9344

DATA_REGIONS = [
    # Post-jump-table data area
    (0xD7B3, 0xD7B5, 'bytes', 'JMPPAD1', 'Padding after jump table'),
    (0xD7B6, 0xD7B6, 'bytes', 'MAXDSK', 'Number of disk drives'),
    (0xD7B7, 0xD7C6, 'bytes', 'ALVINI', 'Initial ALV allocation (16 FF bytes)'),
    (0xD7C7, 0xD7C8, 'bytes', 'JMPPAD2', 'Padding'),
    (0xD7C9, 0xD7C9, 'bytes', 'RETZ', 'RET Z instruction byte (C8h)'),
    # D7CA-D7DB: 6 Extended BIOS JPs — leave as code
    (0xD7DC, 0xD7F0, 'bytes', 'SCRNDATA', 'Screen addressing data'),

    # String data
    (0xD7F1, 0xD7F2, 'bytes', 'ERRMSG_PRE', 'CR LF before error message'),
    (0xD7F3, 0xD80C, 'string', 'ERRMSG', 'Disk read error - reset'),
    (0xD80D, 0xD80D, 'bytes', 'SIGNON_FF', 'Form feed before signon'),
    (0xD80E, 0xD834, 'string', 'SIGNON', 'Signon message'),
    (0xD835, 0xD835, 'bytes', 'WAITFF', 'Form feed before waiting'),
    (0xD836, 0xD83D, 'string', 'WAITMSG', 'Waiting message'),
    (0xD83E, 0xD83E, 'bytes', 'CFGFF', 'Form feed before config error'),
    (0xD83F, 0xD861, 'string', 'CFGERR', 'Cannot read configuration record'),

    # DPBASE runtime init table
    (0xDE8C, 0xDEBC, 'words', 'DPBINIT', 'DPBASE runtime initialization table'),

    # Skew tables
    (0xE73C, 0xE755, 'bytes', 'SKEW_T0', '26-sector T0 interleave table'),
    (0xE756, 0xE764, 'bytes', 'SKEW_MAXI', 'MAXI 15-sector interleave table'),
    (0xE765, 0xE76E, 'bytes', 'SKEW_10', '10-sector skew table'),
    (0xE76F, 0xE788, 'bytes', 'SKEW_SEQ', 'Sequential 26-sector table'),

    # DPBs (9 entries, 15 bytes each)
    (0xE789, 0xE797, 'words', 'DPB_FM1', 'DPB: FM 8-inch (SPT=26, DSM=242, OFF=2)'),
    (0xE798, 0xE7A6, 'words', 'DPB_MFM1', 'DPB: MFM 8-inch (SPT=120, DSM=561, OFF=2)'),
    (0xE7A7, 0xE7B5, 'words', 'DPB_FM2', 'DPB: FM 8-inch (SPT=26, DSM=242, OFF=0)'),
    (0xE7B6, 0xE7C4, 'words', 'DPB_MFM2', 'DPB: MFM 8-inch (SPT=104, DSM=486, OFF=0)'),
    (0xE7C5, 0xE7D3, 'words', 'DPB_HD1', 'DPB: HD partition 1 (SPT=384, DSM=561)'),
    (0xE7D4, 0xE7E2, 'words', 'DPB_HD2', 'DPB: HD partition 2 (SPT=384, DSM=389)'),
    (0xE7E3, 0xE7F1, 'words', 'DPB_HD3', 'DPB: HD partition 3 (SPT=384, DSM=491)'),
    (0xE7F2, 0xE800, 'words', 'DPB_HD4', 'DPB: HD partition 4 (SPT=384, DSM=491)'),
    (0xE801, 0xE80F, 'words', 'DPB_HD5', 'DPB: HD partition 5 (SPT=384, DSM=494)'),

    # Disk config, DPH init tables, DPBASE structures
    (0xE810, 0xE97F, 'bytes', 'DPBASE', 'Disk parameter headers and config data'),

    # Interrupt vector table
    (0xE980, 0xE99F, 'words', 'INTVEC', 'Interrupt vector table (16 entries)'),

    # Post-IVT data
    (0xE9A0, 0xE9FF, 'bytes', 'HDCFG', 'HD config and workspace'),

    # Tail data (COMAL-80 residual, not loaded during boot)
    (0xEA00, 0xF8FF, 'bytes', 'TAIL', 'Residual COMAL-80 data (not BIOS code)'),
]

CODE_LABELS = {
    # INIT
    0xD480: 'START',

    # BIOS jump table
    0xD780: 'JMPTAB',

    # Extended BIOS entries
    0xD7CA: 'EXTJMP',

    # JT targets
    0xDB9A: 'BOOT',
    0xDBE2: 'WBOOT',
    0xE203: 'CONOUT_ENTRY',
    0xDCB5: 'LIST_ENTRY',
    0xDD08: 'PUNCH_ENTRY',
    0xDCF8: 'READER_ENTRY',
    0xE648: 'HOME_MAIN',
    0xE2BD: 'SELDSK_ENTRY',
    0xE366: 'SETTRK_ENTRY',
    0xE36C: 'SETSEC_ENTRY',
    0xE372: 'SETDMA_ENTRY',
    0xE37B: 'SECTRAN_ENTRY',
    0xE38F: 'READ_ENTRY',
    0xDCB1: 'WRITE_ENTRY',
    0xE378: 'LISTST_ENTRY',

    # Extended entry targets
    0xE744: 'EXTFN0',
    0xDCF4: 'EXTFN1',
    0xDB3C: 'EXTFN2',
    0xDB19: 'EXTFN3',
    0xDB26: 'EXTFN4',
    0xE953: 'EXTFN5',

    # CONST/CONIN (runtime-relocated)
    0xEC2B: 'CONST_ENTRY',
    0xEC2F: 'CONIN_ENTRY',
}

VAR_LABELS = {
    0xF36E: 'CDISK',
    0xF500: 'ATTRBUF',
    0xF620: 'ISRSTACK',
    0xF680: 'CONVTAB',
    0xF800: 'SCREENBUF',
    0xFFCF: 'SCRNEND',
    0xFFD1: 'CURX',
    0xFFD2: 'CURY',
    0xFFDF: 'TIMER1',
    0xFFE1: 'TIMER2',
    0xFFE3: 'TIMER3',
    0xFFE5: 'WARMJP',
    0xFFE7: 'MOTORTIMER',
    0xFFFC: 'RTCCNT',
}


def create_blocks_file(data, path):
    """Create z80dasm block definitions file."""
    blocks = []
    regions = sorted(DATA_REGIONS, key=lambda r: r[0])

    pos = ORG
    for start, end, dtype, label, comment in regions:
        if pos < start:
            blocks.append((pos, start - 1, 'code', None))
        btype = 'worddata' if dtype == 'words' else 'bytedata'
        blocks.append((start, end, btype, label))
        pos = end + 1

    if pos < ORG + len(data):
        blocks.append((pos, ORG + len(data) - 1, 'code', None))

    with open(path, 'w') as f:
        f.write('; z80dasm block definitions for RC703 rel.1.0 BIOS\n\n')
        for i, (start, end, btype, label) in enumerate(blocks):
            name = label.lower() if label else f'code{i:03d}'
            f.write(f'{name}:\tstart 0x{start:04X} end 0x{end + 1:04X} type {btype}\n')


def create_symbols_file(path):
    """Create z80dasm symbol file."""
    all_labels = {}
    all_labels.update(CODE_LABELS)
    all_labels.update(VAR_LABELS)
    for start, end, dtype, label, comment in DATA_REGIONS:
        all_labels[start] = label

    with open(path, 'w') as f:
        f.write('; z80dasm symbols for RC703 rel.1.0 BIOS\n\n')
        for addr in sorted(all_labels):
            f.write(f'{all_labels[addr]}:\tequ\t0x{addr:04X}\n')


def run_z80dasm(binpath, sympath, blkpath, outpath):
    """Run z80dasm on the binary."""
    cmd = [
        'z80dasm', '-a', '-l',
        '-g', f'0x{ORG:04X}',
        '-S', sympath,
        '-b', blkpath,
        '-o', outpath,
        binpath
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f'z80dasm error: {result.stderr}', file=sys.stderr)
        sys.exit(1)


def convert_to_zmac(asmpath, outpath):
    """Convert z80dasm output to zmac-compatible source."""
    with open(asmpath) as f:
        lines = f.readlines()

    out = []
    out.append('; RC703 CP/M 2.2 BIOS rel.1.0 — disassembly from extracted binary')
    out.append('; Assembled with: zmac -z --dri -DREL10 src-rc703/BIOS_REL10.MAC')
    out.append(';')
    out.append('; RC703 MAXI format (8-inch multi-density):')
    out.append(';   - Track 0 Side 0: FM, 26 sectors x 128 bytes')
    out.append(';   - Track 0 Side 1: MFM, 26 sectors x 256 bytes')
    out.append(';   - Tracks 1-76: MFM, 15 sectors x 512 bytes')
    out.append(';')
    out.append('; Differences from rel.1.2:')
    out.append(';   - No LINSEL timing fix (6 bytes shorter)')
    out.append(';   - No RC763 HD identification table')
    out.append(';   - 6 extended BIOS entries (not 7)')
    out.append(';   - MAXI-format DPBs instead of QD')
    out.append(';   - Tail: COMAL-80 residual data (not VERIFY utility)')
    out.append('')
    out.append('\t.Z80')
    out.append('')

    skip_header = True
    for line in lines:
        line = line.rstrip()
        if skip_header:
            if line.startswith(';') or line == '':
                continue
            skip_header = False

        if line.strip().startswith('org '):
            line = line.replace('org ', 'ORG ')
        line = re.sub(r'\bdefb\b', 'DB', line)
        line = re.sub(r'\bdefw\b', 'DW', line)
        out.append(line)

    with open(outpath, 'w') as f:
        f.write('\n'.join(out))
        f.write('\n')


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    binpath = sys.argv[1]
    with open(binpath, 'rb') as f:
        data = f.read()

    if len(data) != BINSIZE:
        print(f'Warning: expected {BINSIZE} bytes, got {len(data)}', file=sys.stderr)

    workdir = os.path.dirname(os.path.abspath(__file__))
    sympath = os.path.join(workdir, 'rc703_rel10.sym')
    blkpath = os.path.join(workdir, 'rc703_rel10.blk')
    asmpath = os.path.join(workdir, 'rc703_rel10_raw.asm')
    outpath = os.path.join(workdir, 'BIOS_REL10.MAC')

    print('Creating symbol file...', file=sys.stderr)
    create_symbols_file(sympath)

    print('Creating block definitions...', file=sys.stderr)
    create_blocks_file(data, blkpath)

    print('Running z80dasm...', file=sys.stderr)
    run_z80dasm(binpath, sympath, blkpath, asmpath)

    print('Converting to zmac syntax...', file=sys.stderr)
    convert_to_zmac(asmpath, outpath)

    print(f'Output: {outpath}', file=sys.stderr)


if __name__ == '__main__':
    main()
