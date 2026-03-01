#!/usr/bin/env python3
"""Generate RC702E rel.2.20 BIOS zmac source from extracted binary.

The RC702E rel.2.20 is in RC703 format (uniform MFM QD):
- Binary starts at disk offset 0 (full Track 0)
- ORG = D480 (post-relocation address)
- BIOS jump table at D780 (offset 0x300)
- 9600 bytes total (5504 code + 4096 VERIFY utility)

Usage:
    python3 mkbios_e220.py ../extracted_bios/cpm22_56k_rc702e_rel2.20_rc703.bin
"""

import sys, subprocess, os, re

ORG = 0xD480
BINSIZE = 9600

DATA_REGIONS = [
    # Post-JT variable/data area
    (0xD7B3, 0xD7C9, 'bytes', 'JTVARS', 'Post-jump-table variables'),

    # Gaps in internal JP table
    (0xD7DF, 0xD7E1, 'bytes', 'JTGAP1', 'Gap in internal JP table'),
    (0xD7EE, 0xD7F2, 'bytes', 'JTGAP2', 'Gap after internal JPs'),

    # BIOS strings
    (0xD7F3, 0xD806, 'string', 'ERRMSG', 'Disk error - reset'),
    (0xD807, 0xD82A, 'string', 'SIGNON', 'RC702E signon message'),

    # DPBs, init tables, skew tables (large contiguous data block)
    (0xE460, 0xE6BE, 'bytes', 'DISKTAB', 'DPBs, DPH init, disk config, skew tables'),

    # Pre-IVT padding
    (0xE975, 0xE97F, 'bytes', 'IVTPAD', 'Padding before IVT'),

    # Interrupt vector table
    (0xE980, 0xE99F, 'words', 'INTVEC', 'Interrupt vector table (16 entries)'),

    # Post-IVT data (IVT addresses, CONST/CONIN code block)
    (0xE9A0, 0xE9FF, 'bytes', 'IVTDATA', 'IVT data and CONST/CONIN code'),

    # VERIFY utility (not loaded during boot)
    (0xEA00, 0xF9FF, 'bytes', 'VERIFY', 'VERIFY/BLOCKS.BAD utility (4096 bytes)'),
]

CODE_LABELS = {
    # INIT
    0xD480: 'START',

    # BIOS jump table
    0xD780: 'JMPTAB',

    # Internal JP entries
    0xD7CA: 'INTJP0',
    0xD7CD: 'INTJP1',
    0xD7D0: 'INTJP2',
    0xD7D3: 'INTJP3',
    0xD7D6: 'INTJP4',
    0xD7D9: 'INTJP5',
    0xD7DC: 'INTJP6',
    0xD7E2: 'INTJP7',
    0xD7E5: 'INTJP8',
    0xD7E8: 'INTJP9',
    0xD7EB: 'INTJP10',

    # BIOS code
    0xD82B: 'PRTMSG',
    0xD846: 'PRTJP',
    0xD849: 'HALT',
    0xD856: 'SETWARM',
    0xD869: 'CLOCK_FN',
    0xD88D: 'SIOWR',
    0xDAC5: 'CONSTAT2',
    0xDAD2: 'INTFN1',
    0xDAE8: 'INTFN2',
    0xDB0B: 'SIOWR2',
    0xDB0F: 'LINSEL',

    # BOOT/WBOOT
    0xDB71: 'BOOT',
    0xDB8D: 'WBOOT',

    # SIO ISR and console
    0xDC5E: 'LISTST',
    0xDC62: 'LIST',
    0xDC85: 'PUNCH2',
    0xDC89: 'READER2',
    0xDC9E: 'CONOUT_INT',
    0xDCA2: 'READER',
    0xDCC9: 'PUNCH',
    0xDCEC: 'ISR_SIO0',

    # Display
    0xDE73: 'DSPY_START',
    0xDEE0: 'DSPY_CHECK',
    0xDEEB: 'DSPY_XLAT',
    0xDEF0: 'DSPY_CRT',
    0xDF01: 'DSPY_DOWN',
    0xDF11: 'DSPY_UP',
    0xDF21: 'DSPY_HOME',
    0xDF2F: 'DSPY_CLR',
    0xDFA4: 'DSPY_SCRL',
    0xE009: 'ISR_CRT',
    0xE049: 'CRT_CURSOR',
    0xE05E: 'ISR_FDC',

    # CONOUT
    0xE071: 'CONOUT',
    0xE0B1: 'ISR_MAIN',

    # SELDSK
    0xE1A8: 'SELDSK',
    0xE280: 'SETTRK',
    0xE285: 'SETSEC',
    0xE28A: 'SETDMA',
    0xE28F: 'SECTRAN',
    0xE292: 'READ',
    0xE2A6: 'WRITE',

    # Disk I/O
    0xE529: 'HOME',
    0xE55C: 'FDCRESULT',
    0xE574: 'FDCDMA_RD',
    0xE594: 'FDCDMA_WR',

    # RAM disk
    0xE5E4: 'RAMDISK',
    0xE674: 'ISR_RAMD',

    # DPBASE init code (between skew tables and IVT)
    0xE6BF: 'DPBINIT',

    # CONST/CONIN (in runtime — not the disk location)
    0xEC28: 'CONST',
    0xEC2C: 'CONIN',
    0xEC61: 'ISR_DEFAULT',
}

VAR_LABELS = {
    0xF36E: 'CDISK',
    0xF49A: 'RAMDSTAT',
    0xF4AA: 'WARMJP2',
    0xF4CA: 'SIOFLG',
    0xF4CC: 'SIOFLG2',
    0xF500: 'ATTRBUF',
    0xF620: 'ISRSTACK',
    0xF680: 'CONVTAB',
    0xF700: 'CONVTAB2',
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
        f.write('; z80dasm block definitions for RC702E rel.2.20 BIOS\n\n')
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
        f.write('; z80dasm symbols for RC702E rel.2.20 BIOS\n\n')
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
    out.append('; RC702E CP/M 2.2 BIOS rel.2.20 — disassembly from extracted binary')
    out.append('; Assembled with: zmac -z --dri -DREL220 src-rc702e/BIOS_E220.MAC')
    out.append(';')
    out.append('; RC702E-specific features:')
    out.append(';   - RAM disk support (ports EE/EF, DMA-based)')
    out.append(';   - Clock display (Danish format)')
    out.append(';   - No hard disk support')
    out.append(';   - 10 DPBs (MINI, MAXI, QD, RAM disk variants)')
    out.append(';   - Embedded VERIFY/BLOCKS.BAD utility (4096 bytes)')
    out.append(';')
    out.append('; RC703 QD disk format (ORG D480, JT at D780)')
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
    sympath = os.path.join(workdir, 'rc702e_220.sym')
    blkpath = os.path.join(workdir, 'rc702e_220.blk')
    asmpath = os.path.join(workdir, 'rc702e_220_raw.asm')
    outpath = os.path.join(workdir, 'BIOS_E220.MAC')

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
