#!/usr/bin/env python3
"""Post-process z80dasm output: replace literal I/O port numbers with symbolic names.

Port names from BIOS.MAC (rcbios/src/) and roa375.asm (roa375/).
"""

import re
import sys

# I/O port name mapping (port number -> symbolic name)
# Names match rcbios/src/BIOS.MAC definitions
PORTS = {
    0x00: 'DSPLD',    # CRT 8275 data register
    0x01: 'DSPLC',    # CRT 8275 control register
    0x04: 'FDC',      # FDC uPD765 main status register
    0x05: 'FDD',      # FDC uPD765 data register
    0x08: 'SIOAD',    # SIO channel A data
    0x09: 'SIOBD',    # SIO channel B data
    0x0A: 'SIOAC',    # SIO channel A control
    0x0B: 'SIOBC',    # SIO channel B control
    0x0C: 'CTCCH0',   # CTC channel 0
    0x0D: 'CTCCH1',   # CTC channel 1
    0x0E: 'CTCCH2',   # CTC channel 2 (display refresh)
    0x0F: 'CTCCH3',   # CTC channel 3 (floppy interrupt)
    0x10: 'PIOAD',    # PIO port A data (keyboard)
    0x11: 'PIOBD',    # PIO port B data
    0x12: 'PIOAC',    # PIO port A control
    0x13: 'PIOBC',    # PIO port B control
    0x14: 'SW1',      # DIP switches (read) / motor control (write)
    0x1C: 'BELL',     # Beeper/speaker
    0xF0: 'DMAAD0',   # DMA channel 0 address
    0xF1: 'DMACN0',   # DMA channel 0 word count
    0xF2: 'DMAAD1',   # DMA channel 1 address (floppy)
    0xF3: 'DMACN1',   # DMA channel 1 word count
    0xF4: 'DMAAD2',   # DMA channel 2 address (display)
    0xF5: 'DMACN2',   # DMA channel 2 word count
    0xF6: 'DMAAD3',   # DMA channel 3 address (display)
    0xF7: 'DMACN3',   # DMA channel 3 word count
    0xF8: 'DMAC',     # DMA command register
    0xFA: 'DMAMAS',   # DMA mask register
    0xFB: 'DMAMOD',   # DMA mode register
    0xFC: 'DMACBC',   # DMA clear byte counter
}

# Build EQU block
PORT_EQUS = []
for port, name in sorted(PORTS.items()):
    PORT_EQUS.append(f'{name}:\tequ 0{port:02x}h')

def replace_ports(lines):
    """Add port EQU definitions and replace literal port numbers in IN/OUT."""
    result = []
    equs_inserted = False

    # Build regex: match (0XXh) in in/out instructions
    # Captures the hex digits to look up in PORTS
    port_re = re.compile(r'(\t(?:in a,|out )\()0([0-9a-f]{2})h(\))')

    for line in lines:
        # Insert port EQUs after the org line
        if not equs_inserted and line.strip().startswith('org '):
            result.append(line)
            result.append('\n')
            for eq in PORT_EQUS:
                result.append(eq + '\n')
            equs_inserted = True
            continue

        # Replace port numbers in in/out instructions
        m = port_re.search(line)
        if m:
            port_num = int(m.group(2), 16)
            if port_num in PORTS:
                name = PORTS[port_num]
                line = line[:m.start()] + m.group(1) + name + m.group(3) + line[m.end():]

        result.append(line)

    return result

def main():
    path = sys.argv[1]
    with open(path, 'r') as f:
        lines = f.readlines()
    lines = replace_ports(lines)
    with open(path, 'w') as f:
        f.writelines(lines)

if __name__ == '__main__':
    main()
