# MEM700 — Static RAM Disk for RC700

**Source:** Schematic in `docs/RC702tech.pdf` physical page 219, titled
"MEM700 V 1.00 — STATIC RAM FOR RC 700". Software support in
`roa375/PHE358A.MAC` (RC702E autoload PROM).

## Overview

The MEM700 is a 64KB static RAM disk board for the RC700/RC702 system.
It provides non-volatile (while powered) solid-state storage that can be
used as a boot device, replacing or supplementing the floppy disk. The
PROM boot code (PHE358A) attempts to boot from the MEM700 before falling
back to floppy.

## Hardware

### RAM Chips

Two **HM61256** (or compatible 62256) 32K×8 static RAM chips:

| Chip | Capacity | Address Range | CE Control |
|------|----------|---------------|------------|
| Upper | 32K (32K–64K) | A0–A14 + A15=1 | Active-low CE via A15 inverted |
| Lower | 32K (0K–32K) | A0–A14 + A15=0 | Active-low CE via A15 direct |

Total: 64KB addressable space.

### Connectors

| Connector | Pins | Function |
|-----------|------|----------|
| P37 | 35 pins | RC700 bus interface (address, data, control) |
| P45 | ~10 pins | Data bus output (active when read enabled) |

### Pin Assignments (P37 — RC700 Bus)

| Pin | Signal | Direction | Function |
|-----|--------|-----------|----------|
| P37-6 | ADD 0 | In | Address bit 0 |
| P37-8 | ADD 1 | In | Address bit 1 |
| P37-10 | ADD 2 | In | Address bit 2 |
| P37-14 | ADD 3 | In | Address bit 3 |
| P37-4V | ADD 4 | In | Address bit 4 |
| P37-18 | ADD 5 | In | Address bit 5 |
| P37-5 | ADD 6 | In | Address bit 6 (active label "ADD D") |
| P37-4 | ADD 7 | In | Address bit 7 |
| P37-3 | ADD 8 | In | Address bit 8 |
| P37-2 | ADD 9 | In | Address bit 9 |
| P37-36 | ADD 10 | In | Address bit 10 |
| P37-34 | ADD 11 | In | Address bit 11 |
| P37-30 | ADD 12 | In | Address bit 12 |
| P37-24 | ADD 13 | In | Address bit 13 |
| P37-31 | 7 MEM WE | In | Memory write enable |
| A-3-1 | 7 RAM RD | In | Memory read enable |
| P31-25/P45 | A15 | In | Bank select (directly to upper chip CE, inverted for lower) |
| P37-32 | 7 MEMRD | In | DMA memory read signal |
| P45-1 | 7 EN DW OUT | In | Enable data write out |
| P37-30 | SACK | In | DMA acknowledge (active low, from Am9517 pin 30) |

### Data Bus Output (P45)

| Pin | Signal |
|-----|--------|
| P45-2 | BUS 0 |
| P45-5 | BUS 1 |
| P45-6 | BUS 2 |
| P45-4 | BUS 3 |
| P45-12 | BUS 4 |
| P45-15 | BUS 5 |
| P45-16 | BUS 6 |
| P45-19 | BUS 7 |

### Glue Logic

A single **74HC02** (quad NOR gate) provides:

1. **Bank select**: A15 directly enables lower chip CE; inverted A15 enables
   upper chip CE. Only one chip is active at a time.
2. **Read control**: Combines SACK (DMA acknowledge) and read signals to
   generate the active RAM read enable (7 RAMRD).

### Power

- **Pin 28**: Vcc (+5V)
- **Pin 14**: GND

## I/O Ports

The MEM700 uses a simple register-based interface for track/sector addressing:

| Port | Address | Read | Write |
|------|---------|------|-------|
| 0xEE | MDST/MDTRK | Status register | Track register |
| 0xEF | — | — | Sector register (writing starts DMA) |

Note: The track and status registers share port 0xEE. Writing sets the
track number (and clears any pending error). Reading returns status.

### Status Register (0xEE, read)

| Bits | Function |
|------|----------|
| 0 | Parity error flag |
| 1 | Busy (DMA transfer in progress) |
| 7–2 | Number of tracks available (shifted right 2 bits) |

The track count in bits 7–2 indicates the physical capacity. A value of
0 (after masking 0xFC) means no MEM700 is present.

### Track Register (0xEE, write)

Sets the track number for the next operation. Also clears any pending
parity error.

### Sector Register (0xEF, write)

Sets the sector number for the next operation. **Writing to this register
starts the DMA transfer** — the MEM700 asserts DREQ on DMA channel 0.

## DMA Interface

The MEM700 uses **DMA Channel 0** (Am9517A) for all data transfers.

### DMA Modes

| Operation | Mode Byte | Description |
|-----------|-----------|-------------|
| Read (disk→memory) | 0x44 | Single transfer, read, channel 0 |
| Write (memory→disk) | 0x48 | Single transfer, write, channel 0 |

### Transfer Sequence

1. **DI** — disable interrupts during setup
2. Set DMA channel 0 mask bit: `OUT (0xFA), 0x04`
3. Set DMA mode: `OUT (0xFB), mode`
4. Clear byte pointer flip-flop: `OUT (0xFC), any`
5. Set DMA address (low, high): `OUT (0xF0), low; OUT (0xF0), high`
6. Set DMA word count (low, high): `OUT (0xF1), low; OUT (0xF1), high`
7. Clear DMA channel 0 mask bit: `OUT (0xFA), 0x00`
8. **EI** — re-enable interrupts
9. Set track: `OUT (0xEE), track`
10. Set sector (starts DMA): `OUT (0xEF), sector`
11. Poll status register (0xEE) bit 1 until not busy
12. Check status register bit 0 for parity error

## Disk Geometry

From the format routine in PHE358A.MAC:

| Parameter | Value |
|-----------|-------|
| Sector size | 1024 bytes (16 sectors × 1024 = 16KB per track) |
| Sectors per track | 16 (implied by format: `1024*16-1` byte count) |
| Track count | Variable (read from status register bits 7–2) |
| Total capacity | Up to 64KB (4 tracks × 16KB) |
| Fill byte | 0xE5 (standard CP/M empty directory marker) |

The sector numbering starts from 0. Track numbering starts from 0.

## Boot Protocol (PHE358A.MAC)

The PROM boot sequence for MEM700:

### 1. Detection

```
IN A,(MDST)         ; read status
AND 0FCH            ; mask track count bits
RET Z               ; if 0 tracks, no MEM700 present
```

### 2. Initial Read (10 bytes)

Read 10 bytes from track 0, sector 0 to detect if the MEM700 contains
valid data:

```
HSTTRK = 0, HSTSEC = 0, SIZE = 10
MDRD (DMA read)
```

If DMA does not complete (channel 0 terminal count not reached), the
MEM700 is not functional — fall back to floppy boot.

### 3. Parity Check and Format

If the parity error bit is set, the MEM700 RAM contains invalid data.
The PROM then **formats the entire disk**:

1. Fill a 16KB buffer at 0x3000 with 0xE5
2. Write each track sequentially, displaying progress on screen
3. After formatting all tracks, check for a "PROM directory" at track 64:
   - Read 2048 bytes from track 64, sector 0 into buffer at 0x3000
   - If first byte is 0x20, copy this directory to track 0, sector 0
     (bootstrap the directory from a reserved area)
4. Return to main boot sequence

### 4. CP/M Boot

If parity is OK (or after formatting):

1. Disable PROMs: `OUT (RAMEN), A`
2. Read 8192 bytes (BIOSL) from **track 0, sector 128** to address 0x0000
3. Wait for DMA completion
4. If parity error, fall back to floppy
5. Start floppy motor and wait for drive ready
6. Jump to address stored at memory location 0x0000 (CP/M cold boot entry)

The boot image lives at track 0, sector 128 (i.e., the second half of
track 0's address space), while the directory occupies track 0, sectors 0–127.

## Relationship to Standard BIOS

The MEM700 is **not** supported by the standard RC702 BIOS (releases 1.4
through 2.3). It requires the PHE358A PROM (RC702E variant) which includes
the MEM700 driver code. The standard ROA375 PROM does not have MEM700 support.

The RC702E BIOS variants (rel.2.01 mini, rel.2.20) in `rcbios/src-rc702e/`
include a RAMDISK.MAC module that provides CP/M disk driver support for the
MEM700 during normal operation (after boot).

## Notes

- The MEM700 is volatile — contents are lost at power-off
- The PROM formats the MEM700 on every cold boot if parity errors are detected
- Track 64 is reserved as a "PROM directory" source — a pre-initialized
  directory that gets copied to track 0 during formatting
- The SACK signal connects to pin 30 of the Am9517 DMA controller
  (active low DMA acknowledge), confirming direct bus-level DMA operation
