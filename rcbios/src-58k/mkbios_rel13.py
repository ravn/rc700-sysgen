#!/usr/bin/env python3
"""Generate 58K rel.1.3 BIOS zmac source from extracted binary.

The 58K rel.1.3 BIOS uses MINI format (5.25" multi-density):
- Binary starts at boot entry offset 0x0380 (ORG E080)
- BIOS jump table at E200 (offset 0x180)
- 5248 bytes total
- Uses EX AF,AF'/EXX for ISR register save (changed to stack-switch in rel.1.4)

Usage:
    python3 mkbios_rel13.py ../extracted_bios/cpm22_58k_rel1.3_mini.bin
"""

import sys, subprocess, os, re

ORG = 0xE080
BINSIZE = 5248

DATA_REGIONS = [
    # INIT padding before JT
    (0xE1BD, 0xE1FF, 'bytes', 'INITPAD', 'Padding before jump table'),

    # Extended entry config and FD array
    (0xE233, 0xE249, 'bytes', 'EXTCFG', 'Extended entry config and FD array'),

    # Padding after internal JPs
    (0xE259, 0xE25B, 'bytes', 'MSGPAD', 'Padding before error message'),

    # Strings
    (0xE25C, 0xE273, 'string', 'ERRMSG', 'DISKETTE READ ERROR message'),
    (0xE274, 0xE289, 'string', 'SIGNON', '58K CP/M VERS 2.2 signon'),

    # IVT + ISR dispatch table (32 word entries)
    (0xE7FC, 0xE83B, 'words', 'INTVEC', 'Interrupt vectors and ISR dispatch table'),

    # Skew tables
    (0xE9B2, 0xE9CB, 'bytes', 'SKEW_T0', '26-sector T0 interleave'),
    (0xE9CC, 0xE9DA, 'bytes', 'SKEW_MAXI', 'MAXI 15-sector skew'),
    (0xE9DB, 0xE9E3, 'bytes', 'SKEW_MINI', 'MINI 9-sector skew'),
    (0xE9E4, 0xE9FD, 'bytes', 'SKEW_SEQ', 'Sequential 26-sector table'),

    # DPBs (4 entries, 15 bytes each)
    (0xE9FE, 0xEA0C, 'words', 'DPB_FM1', 'DPB: FM 8-inch (SPT=26, DSM=242, OFF=2)'),
    (0xEA0D, 0xEA1B, 'words', 'DPB_MFM1', 'DPB: MFM 8-inch (SPT=120, DSM=449, OFF=2)'),
    (0xEA1C, 0xEA2A, 'words', 'DPB_FM2', 'DPB: FM 8-inch (SPT=26, DSM=242, OFF=0)'),
    (0xEA2B, 0xEA39, 'words', 'DPB_MFM2', 'DPB: MFM 8-inch (SPT=104, DSM=471, OFF=0)'),

    # Disk config init tables + DPH templates
    (0xEA3A, 0xEAB9, 'bytes', 'DSKCFG', 'Disk config and DPH init tables'),

    # Runtime workspace (zeros — DPBASE, ALV, CSV, directory buffer)
    (0xEABA, 0xEE14, 'bytes', 'WORKSPACE', 'Runtime workspace'),

    # Second workspace gap
    (0xF2BF, 0xF2FF, 'bytes', 'WORKSPACE2', 'Runtime workspace'),

    # Trailing zeros
    (0xF4BF, 0xF4FF, 'bytes', 'TRAILING', 'Trailing zeros'),
]

CODE_LABELS = {
    # INIT
    0xE080: 'START',

    # BIOS jump table
    0xE200: 'JMPTAB',

    # Internal JP table
    0xE24A: 'INTJP',

    # JT targets
    0xE2F8: 'BOOT',
    0xE328: 'WBOOT',
    0xE49B: 'CONST',
    0xE49F: 'CONIN',
    0xE8F3: 'CONOUT',
    0xE3AC: 'LIST',
    0xE3FF: 'PUNCH',
    0xE3EF: 'READER',
    0xF14A: 'HOME',
    0xEE29: 'SELDSK',
    0xEEA3: 'SETTRK',
    0xEEA9: 'SETSEC',
    0xEEAE: 'SETDMA',
    0xEEB7: 'SECTRAN',
    0xEEC7: 'READ',
    0xE3A8: 'WRITE',
    0xEEB4: 'LISTST',

    # Internal JP targets
    0xF201: 'READS',
    0xE3EB: 'LINSEL',
    0xE2C0: 'EXIT',
    0xE29F: 'CLOCK',
    0xE2AC: 'INTFN5',
}

VAR_LABELS = {
    0xF500: 'ATTRBUF',
    0xF620: 'ISRSTACK',
    0xF680: 'CONVTAB',
    0xF800: 'SCREENBUF',
    0xFFCF: 'SCRNEND',
    0xFFD1: 'CURX',
    0xFFD2: 'CURY',
    0xFFDF: 'TIMER1',
    0xFFE1: 'TIMER2',
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
        f.write('; z80dasm block definitions for 58K rel.1.3 BIOS\n\n')
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
        f.write('; z80dasm symbols for 58K rel.1.3 BIOS\n\n')
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
    out.append('; 58K CP/M 2.2 BIOS rel.1.3 — disassembly from extracted binary')
    out.append('; Assembled with: zmac -z --dri -DREL13 src-58k/BIOS_58K.MAC')
    out.append(';')
    out.append('; 58K family (no hard disk support, 4864 bytes code):')
    out.append(';   - ORG E080 (boot entry at Track 0 offset 0x0380)')
    out.append(';   - BIOS JT at E200, no extended BIOS JP entries')
    out.append(';   - ISR save: EX AF,AF\'/EXX (compact, pre-rel.1.4)')
    out.append(';   - Same strings and DPBs as rel.1.4')
    out.append(';   - IVT page at F300 (F400 in rel.1.4)')
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
    sympath = os.path.join(workdir, 'bios_58k.sym')
    blkpath = os.path.join(workdir, 'bios_58k.blk')
    asmpath = os.path.join(workdir, 'bios_58k_raw.asm')
    outpath = os.path.join(workdir, 'BIOS_58K.MAC')

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
