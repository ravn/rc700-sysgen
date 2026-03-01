#!/usr/bin/env python3
"""Generate RC703 BIOS zmac source from extracted binary.

Creates a z80dasm disassembly of the code regions and DB directives for
data regions, then converts to zmac-compatible syntax. The output can be
assembled with zmac to reproduce the original binary byte-for-byte.

Usage:
    python3 mkbios.py extracted_bios/cpm22_56k_rel1.2_rc703.bin > src-rc703/BIOS.MAC
"""

import sys, struct, subprocess, tempfile, os, re

# Memory layout
ORG = 0xD480         # Start of binary in memory
BIOS_OFFSET = 0x580  # Offset of BIOS jump table from ORG (address DA00 - D480)

# Known data regions (address ranges inclusive)
# Format: (start_addr, end_addr, type, label, comment)
DATA_REGIONS = [
    # INIT data embedded in code (D6EE-D6FC: RC763 hard disk model data)
    (0xD6EE, 0xD6FC, 'bytes', 'RC763TAB', 'RC763 hard disk identification data'),

    # BIOS jump table area data
    (0xD7B3, 0xD7B5, 'bytes', 'JMPPAD1', 'Padding after jump table'),
    (0xD7B6, 0xD7B6, 'bytes', 'MAXDSK', 'Number of disk drives'),
    (0xD7B7, 0xD7C6, 'bytes', 'ALVINI', 'Initial ALV allocation (16 FF bytes)'),
    (0xD7C7, 0xD7C8, 'bytes', 'JMPPAD2', 'Padding'),
    (0xD7C9, 0xD7C9, 'bytes', 'RETZ', 'RET Z instruction byte (C8h)'),
    # D7CA-D7DE: Extended entry JPs - leave as code
    (0xD7DF, 0xD7F0, 'bytes', 'SCRNDATA', 'Screen addressing data'),

    # String data
    (0xD7F1, 0xD7F2, 'bytes', 'ERRMSG_PRE', 'CR LF before error message'),
    (0xD7F3, 0xD80C, 'string', 'ERRMSG', 'Disk read error - reset'),
    (0xD80D, 0xD80D, 'bytes', 'SIGNON_FF', 'Form feed before signon'),
    (0xD80E, 0xD833, 'string', 'SIGNON', 'Signon message'),
    (0xD834, 0xD834, 'bytes', 'WAITFF', 'Form feed before waiting'),
    (0xD835, 0xD83C, 'string', 'WAITMSG', 'Waiting message'),
    (0xD83D, 0xD83D, 'bytes', 'CFGFF', 'Form feed before config error'),
    (0xD83E, 0xD860, 'string', 'CFGERR', 'Cannot read configuration record'),

    # DPBASE runtime init table
    (0xDE91, 0xDEC1, 'words', 'DPBINIT', 'DPBASE runtime initialization table'),

    # Skew tables and DPBs (E736-E97F)
    (0xE736, 0xE749, 'bytes', 'SKEW_QD', 'QD 10-sector skew table'),
    (0xE74A, 0xE758, 'bytes', 'SKEW_MAXI', 'MAXI 15-sector skew table'),
    (0xE759, 0xE772, 'bytes', 'SKEW_SEQ', 'Sequential 26-sector table'),
    # DPBs
    (0xE773, 0xE782, 'words', 'DPB_QD1', 'DPB: QD floppy (SPT=40, DSM=389)'),
    (0xE783, 0xE792, 'words', 'DPB_QD2', 'DPB: QD floppy (SPT=80, DSM=389)'),
    (0xE793, 0xE7A2, 'words', 'DPB_QD3', 'DPB: QD floppy (SPT=80, DSM=389)'),
    (0xE7A3, 0xE7B2, 'words', 'DPB_MAXI', 'DPB: MAXI 8-inch (SPT=120, DSM=561)'),
    # HD DPBs - 4 partitions
    (0xE7B3, 0xE7C2, 'words', 'DPB_HD1', 'DPB: HD partition 1'),
    (0xE7C3, 0xE7D2, 'words', 'DPB_HD2', 'DPB: HD partition 2'),
    (0xE7D3, 0xE7E2, 'words', 'DPB_HD3', 'DPB: HD partition 3'),
    (0xE7E3, 0xE7F2, 'words', 'DPB_HD4', 'DPB: HD partition 4'),
    # DPBASE structures
    (0xE7F3, 0xE97F, 'bytes', 'DPBASE', 'Disk parameter base structures'),

    # Interrupt vector table (E980-E99F)
    (0xE980, 0xE99F, 'words', 'INTVEC', 'Interrupt vector table (16 entries)'),

    # Variables/workspace after IVT (E9A0-E9FF)
    (0xE9A0, 0xE9FF, 'bytes', 'HDCFG', 'HD config and workspace'),
]

# Known code labels (address -> label)
CODE_LABELS = {
    # INIT
    0xD480: 'START',
    0xD500: 'SIOINIT',
    0xD55F: 'FDCWAIT',
    0xD580: 'CLRSCR',
    0xD5A7: 'INITCRT',
    0xD5D4: 'CLRVARS',
    0xD608: 'INITDONE',
    0xD612: 'BOOTSTART',
    0xD621: 'FDCPOLL',
    0xD680: 'CFGCOPY',
    0xD697: 'CFGCHECK',
    0xD6FD: 'CFGPROC',
    0xD712: 'INITDPBASE',
    0xD746: 'GOCPM1',
    0xD749: 'INITCFG2',
    0xD764: 'NOCFG',

    # Jump table
    0xD780: 'JMPTAB',
    0xD7CA: 'EXTJMP',

    # BIOS entry code at DA00
    0xDA00: 'GOCPM',
    0xDA33: 'IOBYTE',
    0xDA36: 'CONSTAT',
    0xDA3A: 'CONOUT_SER',
    0xDA5F: 'CONIN_INIT',
    0xDA79: 'CONIN_RD',
    0xDA7D: 'LIST_OUT',
    0xDA8D: 'READER_IN',

    # SIO ISR handlers
    0xDAB2: 'ISR_SIO_BT',
    0xDACB: 'ISR_SIO_BE',
    0xDAE4: 'ISR_SIO_BR',
    0xDAF9: 'ISR_SIO_BS',
    0xDB16: 'ISR_SIO_AT',
    0xDB2F: 'ISR_SIO_AE',
    0xDB48: 'ISR_SIO_AR',
    0xDB62: 'ISR_SIO_AS',

    # Display
    0xDB89: 'DSPY_NEG',
    0xDB93: 'DSPY_INC',
    0xDB98: 'DSPY_CHECK',
    0xDBA3: 'DSPY_XLAT',
    0xDBAE: 'DSPY_CRT',
    0xDBBF: 'DSPY_DOWN',
    0xDBD0: 'DSPY_UP',
    0xDBE1: 'DSPY_HOME',
    0xDBF4: 'DSPY_CLR',
    0xDC15: 'DSPY_SCRL',
    0xDC42: 'DSPY_DIV8',
    0xDC56: 'DSPY_SETBIT',
    0xDC68: 'DSPY_LDIR',
    0xDC6E: 'DSPY_LDDR',
    0xDC74: 'DSPY_BELL',
    0xDC77: 'DSPY_ATTR',
    0xDC80: 'DSPY_NOP',
    0xDC81: 'DSPY_CR',
    0xDC89: 'DSPY_CLEAR',

    # More display + SIO data
    0xDCB4: 'LISTDATA',
    0xDCBA: 'LIST_ENTRY',
    0xDCFD: 'READER_ENTRY',
    0xDD0D: 'PUNCH_ENTRY',

    # CPMBOOT
    0xDB9F: 'BOOT',
    0xDBE7: 'WBOOT',
    0xD861: 'PRTMSG',
    0xD86D: 'CRTADDR',
    0xD875: 'SETCRTPOS',
    0xD890: 'HALT',
    0xD898: 'SETWARM',
    0xD8A5: 'CLOCK',
    0xD8BB: 'LINSEL',
    0xD8FE: 'SIOWR',
    0xD905: 'SETEXITHL',
    0xD916: 'RSTEXITHL',
    0xD91F: 'WBOOT_ENTRY',

    # CRT ISR
    0xDFBD: 'ISR_CRT',
    0xDFEF: 'CRT_CURSOR',

    # SELDSK / disk ops
    0xE042: 'SELDSK_ENTRY',
    0xE0DE: 'GETDPB',
    0xE0EB: 'SETTRK_ENTRY',
    0xE0F1: 'SETSEC_ENTRY',
    0xE0F7: 'SETDMA_ENTRY',
    0xE0FD: 'SECTRAN_ENTRY',
    0xE100: 'READ_ENTRY',
    0xE208: 'CONOUT_ENTRY',
    0xE283: 'READ_HD',
    0xE290: 'WRITE_HD',

    # Blocking/deblocking
    0xE2C2: 'SELDSK_MAIN',
    0xE325: 'DISK_READ',
    0xE36F: 'DISK_WRITE',
    0xE399: 'MOTOR_CTL',
    0xE3B7: 'MOTOR_OFF',
    0xE3C1: 'TIMER_SET',
    0xE3CD: 'FLUSH',

    # FDC operations
    0xE420: 'FDC_RQMWAIT',
    0xE42A: 'FDC_DIORQM',
    0xE434: 'FDC_RECAL',
    0xE455: 'FDC_SEEK',
    0xE46F: 'FDC_RDID',
    0xE48C: 'FDC_WRCMD',
    0xE4A6: 'FDC_RESULT',
    0xE4C2: 'FDC_CLRINT',

    # DMA for FDC
    0xE4E0: 'DMA_FDCRD',
    0xE501: 'DMA_FDCWR',

    # FDC ISR
    0xE558: 'ISR_FDC',

    # HD operations
    0xE589: 'HD_RECAL',
    0xE5A4: 'HD_WRITE_OP',
    0xE5BF: 'HD_CHECK',
    0xE619: 'HD_SETUP',
    0xE64C: 'HOME_MAIN',
    0xE65E: 'HD_SYNC',
    0xE66E: 'HD_CLRINT',
    0xE68F: 'DMA_HDRD',
    0xE699: 'DMA_HDWR',
    0xE6BA: 'HD_CMD',
    0xE6CD: 'HD_CMD2',

    # HD ISR
    0xE700: 'ISR_HD',

    # CONST/CONIN at high address
    0xEC2B: 'CONST_ENTRY',
    0xEC2F: 'CONIN_ENTRY',
}

# Variable locations (in runtime memory, referenced by code)
VAR_LABELS = {
    0xDCAD: 'SIOBFLG',
    0xDCAE: 'SIOAFLG',
    0xDCAF: 'SIOADATA',
    0xDCB0: 'SIOADATA2',
    0xDCB1: 'SIOBDATA',
    0xDCB2: 'SIOBSTAT',
    0xDCB3: 'SIOASTAT',
    0xDCB4: 'SIOBEXT',
    0xDCB5: 'SIOAEXT',
    0xEE80: 'ENDPRG',
    0xF36E: 'CDISK',
    0xF371: 'SEKTRK',
    0xF374: 'SEKHEAD',
    0xF376: 'SEKSEC',
    0xF378: 'HSTDSK',
    0xF379: 'HSTTRK',
    0xF37B: 'HSTSEC',
    0xF37D: 'HSTACT',
    0xF37E: 'HSTWRT',
    0xF381: 'UNACNT',
    0xF386: 'ERFLAG',
    0xF387: 'WRTYPE',
    0xF38A: 'DMAADR',
    0xF38E: 'DSKTYPE',
    0xF390: 'MAXDSK2',
    0xF391: 'DRIVESEL',
    0xF392: 'DMABASE',
    0xF396: 'RETRYCNT',
    0xF3A0: 'HDSTAT',
    0xF3A1: 'HDCNT',
    0xF3A3: 'SAVSP',
    0xF3A5: 'FDCINT',
    0xF3A6: 'FDCINT2',
    0xF3A7: 'FDCINIT',
    0xF3A8: 'DSKCFG',
    0xF3A9: 'HDPRESENT',
    0xF500: 'ATTRBUF',
    0xF5F0: 'ATTREND',
    0xF620: 'ISRSTACK',
    0xF680: 'CONVTAB',
    0xF800: 'SCREENBUF',
    0xFFCF: 'SCRNEND',
    0xFFD1: 'CURX',
    0xFFD2: 'CURY',
    0xFFD4: 'CURROW',
    0xFFD5: 'ATTRPTR',
    0xFFD7: 'ESCSTATE',
    0xFFD8: 'CURSAVE',
    0xFFDA: 'CURCHAR',
    0xFFDB: 'ATTRMODE',
    0xFFDC: 'ATTRPTR2',
    0xFFDE: 'ESCBUF',
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

    # Sort data regions by start address
    regions = sorted(DATA_REGIONS, key=lambda r: r[0])

    # Everything not in a data region is code
    # But we only process up to the code portion (first 0x1580 bytes)
    code_end = ORG + 0x1580  # EA00

    pos = ORG
    for start, end, dtype, label, comment in regions:
        if start >= code_end:
            break
        if pos < start:
            blocks.append((pos, start - 1, 'code'))
        btype = 'bytedata'
        if dtype == 'words':
            btype = 'worddata'
        blocks.append((start, min(end, code_end - 1), btype))
        pos = end + 1

    if pos < code_end:
        blocks.append((pos, code_end - 1, 'code'))

    # Tail region as bytedata
    if code_end < ORG + len(data):
        blocks.append((code_end, ORG + len(data) - 1, 'bytedata'))

    with open(path, 'w') as f:
        f.write('; z80dasm block definitions for RC703 BIOS\n\n')
        for i, (start, end, btype) in enumerate(blocks):
            name = f'blk{i:03d}'
            # Try to get a meaningful name from DATA_REGIONS
            for rs, re_, dt, label, comment in DATA_REGIONS:
                if rs == start:
                    name = label.lower()
                    break
            else:
                if btype == 'code':
                    name = f'code{i:03d}'
            f.write(f'{name}:\tstart 0x{start:04X} end 0x{end + 1:04X} type {btype}\n')

    return blocks


def create_symbols_file(path):
    """Create z80dasm symbol file."""
    all_labels = {}
    all_labels.update(CODE_LABELS)
    all_labels.update(VAR_LABELS)
    for start, end, dtype, label, comment in DATA_REGIONS:
        all_labels[start] = label

    with open(path, 'w') as f:
        f.write('; z80dasm symbols for RC703 BIOS\n\n')
        for addr in sorted(all_labels):
            f.write(f'{all_labels[addr]}:\tequ\t0x{addr:04X}\n')


def run_z80dasm(binpath, org, sympath, blkpath, outpath):
    """Run z80dasm on the binary."""
    cmd = [
        'z80dasm', '-a', '-l',
        '-g', f'0x{org:04X}',
        '-S', sympath,
        '-b', blkpath,
        '-o', outpath,
        binpath
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f'z80dasm error: {result.stderr}', file=sys.stderr)
        sys.exit(1)
    return outpath


def convert_to_zmac(asmpath, outpath, data):
    """Convert z80dasm output to zmac-compatible source."""
    with open(asmpath) as f:
        lines = f.readlines()

    out = []
    out.append('; RC703 CP/M 2.2 BIOS — disassembly from rel.1.2 reference binary')
    out.append('; Assembled with: zmac -z --dri -DREL12 src-rc703/BIOS.MAC')
    out.append(';')
    out.append('; Supports conditional assembly:')
    out.append(';   -DREL12  - rel.1.2 (primary reference, QD format)')
    out.append(';   -DRELTFJ - rel.TFj (identical code, different signon)')
    out.append(';   -DREL10  - rel.1.0 (MAXI format, older code)')
    out.append('')
    out.append('\t.Z80')
    out.append('')

    # Add conditional signon
    out.append('; Signon string (conditional)')
    out.append('IFDEF\tREL12')
    out.append("SIGVER\tMACRO")
    out.append("\tDB\t'1.2'")
    out.append("\tENDM")
    out.append('ENDIF')
    out.append('IFDEF\tRELTFJ')
    out.append("SIGVER\tMACRO")
    out.append("\tDB\t'TFj'")
    out.append("\tENDM")
    out.append('ENDIF')
    out.append('')

    # Process z80dasm output
    skip_header = True
    for line in lines:
        line = line.rstrip()

        # Skip z80dasm header
        if skip_header:
            if line.startswith(';') or line == '':
                continue
            skip_header = False

        # Convert 'org' to uppercase
        if line.strip().startswith('org '):
            line = line.replace('org ', 'ORG ')

        # Convert 'defb' to 'DB', 'defw' to 'DW'
        line = re.sub(r'\bdefb\b', 'DB', line)
        line = re.sub(r'\bdefw\b', 'DW', line)

        # Handle the signon string - replace literal version with macro call
        if 'SIGNON:' in line or ("DB\t'" in line and '1.2' in line and 'rel.' in line):
            # We'll handle this specially
            pass

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

    print(f'Read {len(data)} bytes from {binpath}', file=sys.stderr)

    # Create temp files for z80dasm
    workdir = os.path.dirname(os.path.abspath(__file__))
    sympath = os.path.join(workdir, 'rc703.sym')
    blkpath = os.path.join(workdir, 'rc703.blk')
    asmpath = os.path.join(workdir, 'rc703_raw.asm')
    outpath = os.path.join(workdir, 'BIOS.MAC')

    print('Creating symbol file...', file=sys.stderr)
    create_symbols_file(sympath)

    print('Creating block definitions...', file=sys.stderr)
    create_blocks_file(data, blkpath)

    print('Running z80dasm...', file=sys.stderr)
    run_z80dasm(binpath, ORG, sympath, blkpath, asmpath)

    print('Converting to zmac syntax...', file=sys.stderr)
    convert_to_zmac(asmpath, outpath, data)

    print(f'Output written to {outpath}', file=sys.stderr)
    print(f'Symbol file: {sympath}', file=sys.stderr)
    print(f'Block defs: {blkpath}', file=sys.stderr)


if __name__ == '__main__':
    main()
