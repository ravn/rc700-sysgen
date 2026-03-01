#!/usr/bin/env python3
"""Generate RC702E rel.2.01 BIOS zmac source from extracted binary.

The RC702E rel.2.01 is in MINI format (same layout as RC700 56K):
- Binary starts at cold boot entry (disk offset 0x0280)
- ORG = D700 (= D480 + 0x0280, post-relocation address)
- BIOS jump table at DA00 (offset 0x300)
- 5504 bytes total

Usage:
    python3 mkbios_e201.py ../extracted_bios/cpm22_56k_rc702e_rel2.01_mini.bin
"""

import sys, subprocess, os, re

ORG = 0xD700
BINSIZE = 5504

# Data regions (address ranges, inclusive end)
# Format: (start, end, type, label, comment)
DATA_REGIONS = [
    # INIT boot strings
    (0xD950, 0xD95B, 'string', 'STR_RAMDISK', 'USE RAM-DISK'),
    (0xD95C, 0xD96E, 'string', 'STR_NOTINST', ' NOT INSTALLED.\\n\\r'),
    (0xD96F, 0xD977, 'string', 'STR_NOTUSED', ' NOT USED'),
    (0xD978, 0xD98B, 'string', 'STR_WAITING', '\\fRC702E Waiting.\\r\\n'),
    (0xD98C, 0xD99E, 'string', 'STR_BOOTQ', ' AS BOOTDISK?(Y/N)'),
    (0xD99F, 0xD9AB, 'string', 'STR_CLOCK', 'Kl.00.00.00'),
    (0xD9AC, 0xD9C3, 'string', 'STR_TIMEINIT', 'TIME NOT INITIALIZED.\\n\\r'),

    # Post-JT variable/data area
    (0xDA33, 0xDA49, 'bytes', 'JTVARS', 'Post-jump-table variables'),

    # NOP gap in internal JP table
    (0xDA5F, 0xDA61, 'bytes', 'JTGAP', 'Gap in internal JP table'),

    # End-of-JPs padding
    (0xDA6E, 0xDA6F, 'bytes', 'JTPAD', 'End of internal JP table'),

    # BIOS strings
    (0xDA70, 0xDA77, 'bytes', 'ERRPRE', 'Pre-error padding/data'),
    (0xDA78, 0xDA92, 'string', 'ERRMSG', 'Disk read error - reset'),
    (0xDA93, 0xDAB5, 'string', 'SIGNON', 'RC702E signon message'),

    # DPBs (10 DPBs × 15 bytes = 150 bytes)
    (0xE717, 0xE7AC, 'bytes', 'DPBTAB', 'Disk parameter blocks (10 DPBs)'),

    # Runtime workspace (zeros, DPH area)
    (0xE7AD, 0xE82D, 'bytes', 'DPBASE', 'DPBASE runtime workspace'),

    # DPH initialization table (9 entries × 16 bytes)
    (0xE82E, 0xE8BD, 'bytes', 'DPHINIT', 'DPH initialization table'),

    # More workspace (zeros)
    (0xE8BE, 0xE91D, 'bytes', 'WKSP1', 'Runtime workspace'),

    # Disk config data table
    (0xE91E, 0xE97E, 'bytes', 'DSKCFG', 'Disk configuration data'),

    # Workspace
    (0xE97F, 0xE9AD, 'bytes', 'WKSP2', 'Runtime workspace'),

    # DPH structures
    (0xE9AE, 0xEA07, 'bytes', 'DPHDATA', 'DPH structures'),

    # Skew tables
    (0xEA08, 0xEA21, 'bytes', 'SKEW_MAXI26', 'MAXI 26-sector skew table'),
    (0xEA22, 0xEA30, 'bytes', 'SKEW_MAXI15', 'MAXI 15-sector skew table'),
    (0xEA31, 0xEA3A, 'bytes', 'SKEW_QD10A', 'QD 10-sector skew table (2:1)'),
    (0xEA3B, 0xEA54, 'bytes', 'SKEW_SEQ26', 'Sequential 26-sector table'),
    (0xEA55, 0xEA5E, 'bytes', 'SKEW_QD10B', 'QD 10-sector skew table (3:1)'),

    # Workspace (all zeros)
    (0xEA62, 0xEBFB, 'bytes', 'WKSP3', 'Runtime workspace (ALV/CSV)'),

    # Interrupt vector table
    (0xEBFC, 0xEC1B, 'words', 'INTVEC', 'Interrupt vector table (16 entries)'),

    # Data between IVT and CONST
    (0xEC1C, 0xEC27, 'bytes', 'IVTDATA', 'IVT-related data'),

    # Trailing data after CONST/CONIN code
    (0xEC78, 0xEC7F, 'bytes', 'TRAILING', 'Trailing data'),
]

# Code labels
CODE_LABELS = {
    # INIT
    0xD700: 'START',
    0xD73E: 'INITCONT',
    0xD821: 'INIT2',
    0xD87A: 'INIT3',
    0xD91D: 'INIT4',
    0xD936: 'INIT5',
    0xD9C4: 'INIT6',

    # BIOS jump table
    0xDA00: 'JMPTAB',

    # Internal JP entries
    0xDA4A: 'INTJP0',
    0xDA4D: 'INTJP1',
    0xDA50: 'INTJP2',
    0xDA53: 'INTJP3',
    0xDA56: 'INTJP4',
    0xDA59: 'INTJP5',
    0xDA5C: 'INTJP6',
    0xDA62: 'INTJP7',
    0xDA65: 'INTJP8',
    0xDA68: 'INTJP9',
    0xDA6B: 'INTJP10',

    # BIOS string display
    0xDAB6: 'PRTMSG',
    0xDAC2: 'PRTLOOP',
    0xDAD8: 'HALT',
    0xDAE5: 'SETWARM',
    0xDAFB: 'CLOCK',
    0xDB1E: 'SIOWR',
    0xDB22: 'LINSEL',

    # BOOT/WBOOT
    0xDB63: 'BOOTCHK',
    0xDB6A: 'BOOT',
    0xDB73: 'BOOTMSG',
    0xDB83: 'WBOOT',
    0xDBB5: 'WBOOT2',

    # SIO / Console
    0xDC05: 'CONSTAT2',
    0xDC67: 'LISTST',
    0xDC6B: 'LIST',
    0xDC8E: 'PUNCH2',
    0xDC92: 'READER2',
    0xDCA7: 'CONOUT_INT',
    0xDCAB: 'READER',
    0xDCD2: 'PUNCH',
    0xDCF5: 'ISR_SIO0',

    # Display
    0xDDD7: 'DSPY_START',
    0xDDDE: 'DSPY_NEG',
    0xDDE3: 'DSPY_INC',
    0xDDEE: 'DSPY_CHECK',
    0xDDF4: 'DSPY_XLAT',
    0xDDF9: 'DSPY_CRT',
    0xDE0A: 'DSPY_DOWN',
    0xDE1A: 'DSPY_UP',
    0xDE2A: 'DSPY_HOME',
    0xDE38: 'DSPY_CLR',
    0xDE3D: 'DSPY_SCRL',
    0xDE4B: 'DSPY_SCRL2',
    0xDE74: 'DSPY_DIV8',
    0xDE7A: 'DSPY_SETBIT',
    0xDF1B: 'ISR_CRT',
    0xDFBC: 'CRT_CURSOR',
    0xDFFC: 'ISR_FDC',

    # CONOUT (large in RC702E — includes clock display)
    0xE013: 'CONOUT_DISP',
    0xE056: 'CONOUT_PROC',
    0xE08A: 'CONOUT_CLOCK',
    0xE096: 'CONOUT',
    0xE0D6: 'ISR_MAIN',
    0xE135: 'CONOUT_END',

    # SELDSK
    0xE1C5: 'SELDSK_PRE',
    0xE1D5: 'SELDSK',
    0xE2A3: 'SELDSK_RET',
    0xE2A7: 'SELDSK_DPB',

    # Standard BIOS entries
    0xE2B4: 'SETTRK',
    0xE2B9: 'SETSEC',
    0xE2BE: 'SETDMA',
    0xE2C3: 'SECTRAN',
    0xE2C6: 'READ',
    0xE2DA: 'WRITE',

    # Disk I/O
    0xE366: 'DISKIO',
    0xE41D: 'DISKRD',
    0xE43F: 'DISKWR',
    0xE4FF: 'FDCWAIT',
    0xE51E: 'FDCRESULT',
    0xE523: 'FDCRESULT2',
    0xE528: 'FDCREAD',
    0xE536: 'FDCWRITE',
    0xE554: 'FDCSEEK',
    0xE55F: 'HOME',
    0xE591: 'FDCRECAL',
    0xE59A: 'FDCCMD',
    0xE5A3: 'FDCDMA_RD',
    0xE5C3: 'FDCDMA_WR',
    0xE5CF: 'FDCMOTOR',
    0xE5EC: 'MOTOROFF',
    0xE608: 'MOTORTIMER',
    0xE622: 'FLUSH',

    # RAM disk I/O
    0xE629: 'RAMDISK',
    0xE636: 'RAMDISK_RD',
    0xE63D: 'RAMDISK_WR',
    0xE65E: 'RAMDISK_DMA',
    0xE667: 'RAMDISK_IO',
    0xE6D3: 'RAMDISK_END',
    0xE6E2: 'RAMDISK_INT',
    0xE6E6: 'RAMDISK_INT2',
    0xE6FF: 'RAMDISK_RET',

    # End of code before DPBs
    0xE716: 'CODE_END',

    # Default ISR handler (in data area)
    0xEA5F: 'ISR_DEFAULT',

    # CONST/CONIN
    0xEC28: 'CONST',
    0xEC2C: 'CONIN',
}

# Variable labels (referenced by code but outside binary)
VAR_LABELS = {
    0xF36E: 'CDISK',
    0xF3A5: 'FDCINT',
    0xF49A: 'RAMDSTAT',
    0xF4CA: 'SIOFLG',
    0xF4CC: 'SIOFLG2',
    0xF500: 'ATTRBUF',
    0xF5F0: 'ATTREND',
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
        f.write('; z80dasm block definitions for RC702E rel.2.01 BIOS\n\n')
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
        f.write('; z80dasm symbols for RC702E rel.2.01 BIOS\n\n')
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
    out.append('; RC702E CP/M 2.2 BIOS rel.2.01 — disassembly from extracted binary')
    out.append('; Assembled with: zmac -z --dri -DREL201 src-rc702e/BIOS_E201.MAC')
    out.append(';')
    out.append('; RC702E-specific features:')
    out.append(';   - RAM disk support (ports E6/E7)')
    out.append(';   - Clock display (Danish format)')
    out.append(';   - No hard disk support')
    out.append(';   - 10 DPBs (MINI, MAXI, QD, RAM disk variants)')
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
    sympath = os.path.join(workdir, 'rc702e_201.sym')
    blkpath = os.path.join(workdir, 'rc702e_201.blk')
    asmpath = os.path.join(workdir, 'rc702e_201_raw.asm')
    outpath = os.path.join(workdir, 'BIOS_E201.MAC')

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
