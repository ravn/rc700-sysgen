# RC702 CP/M BIOS Reverse Engineering

## Goal

Extract, disassemble, and document the actual CP/M BIOS code from RC702 disk
images.  The BIOS is loaded by the ROA375 boot ROM (Track 0) and relocated to
high memory by the cold boot code.

## Source Disk Images

| Image | Type | Boot Banner | TPA | BIOS Variant |
|-------|------|-------------|-----|--------------|
| rccpm22.imd | 5.25" mini | RC700   56k CP/M vers.2.2   rel.2.1 | 56K | Stock rel.2.1 |
| CPM_med_COMAL80.imd | 5.25" mini | RC700   56k CP/M vers.2.2   rel.2.1 | 56K | Stock rel.2.1 |
| Compas_v.2.13DK.imd | 8" maxi | 58K CP/M VERS 2.2 | 58K | Unknown variant |

## CP/M 2.2 Memory Layout

### 56K System (rccpm22, CPM_med_COMAL80)
```
0x0000  Low memory (vectors, scratch)
0x0100  TPA (Transient Program Area)
0xC400  CCP (Console Command Processor) — 2048 bytes
0xCC06  BDOS entry — ~3.5K
0xDA00  BIOS base — jump table + resident code
0xF800  Display buffer (80x25 = 2000 bytes)
0xFFFF  Top of RAM
```

### 58K System (Compas)
```
0x0000  Low memory
0x0100  TPA
0xC800  CCP (estimated, +1K from 56K)
0xD006  BDOS entry (estimated)
0xDE00  BIOS base (estimated)
0xF800  Display buffer
0xFFFF  Top of RAM
```

## BIOS Jump Table

Standard CP/M 2.2 BIOS has 17 entry points at 3-byte intervals:

| Offset | Vector   | Function |
|--------|----------|----------|
| +0x00  | BOOT     | Cold boot |
| +0x03  | WBOOT    | Warm boot (reload CCP+BDOS) |
| +0x06  | CONST    | Console status |
| +0x09  | CONIN    | Console input |
| +0x0C  | CONOUT   | Console output |
| +0x0F  | LIST     | List (printer) output |
| +0x12  | PUNCH    | Punch (aux) output |
| +0x15  | READER   | Reader (aux) input |
| +0x18  | HOME     | Home disk head |
| +0x1B  | SELDSK   | Select disk |
| +0x1E  | SETTRK   | Set track |
| +0x21  | SETSEC   | Set sector |
| +0x24  | SETDMA   | Set DMA address |
| +0x27  | READ     | Read sector |
| +0x2A  | WRITE    | Write sector |
| +0x2D  | LISTST   | List device status |
| +0x30  | SECTRAN  | Sector translate |

RC702 BIOS may have additional non-standard vectors after SECTRAN (drive
configuration, FDC status, line selector, clock, etc.).

## Reference Sources

### jbox.dk (rel.2.1) — Primary Reference
- Source: https://www.jbox.dk/rc702/rcbios.shtm
- Version: "RC700 56k CP/M vers.2.2 rel.2.1"
- Likely closest match to the stock BIOS on our disk images
- Modular: BIOS.MAC includes CPMBOOT.MAC, SIO.MAC, DISPLAY.MAC,
  FLOPPY.MAC, HARDDSK.MAC, DISKTAB.MAC, INTTAB.MAC, PIO.MAC

### rc702-bios (rel.2.2) — Secondary Reference
- Source: ~/git/rc702-bios/ (user's 1991 disassembly, extensively modified)
- Heavily customized: keyboard buffering, VT52, status line, ISO-8859-1, clock
- Useful for understanding RC702 hardware interaction patterns (FDC, DMA, CRT)
- NOT expected to match any disk image binaries

## Approach

1. Run rc700 emulator with `--memdump` to capture 64K RAM after CP/M boots
2. Locate BIOS jump table in RAM dump (17 consecutive JP instructions)
3. Extract BIOS region to separate binary
4. Disassemble with z80dasm, label standard + non-standard entry points
5. Cross-reference with jbox.dk and rc702-bios sources
6. Document findings in ANALYSIS.md

## Files

- `README.md` — This file
- `Makefile` — Build rules for extraction and disassembly
- `ANALYSIS.md` — Detailed findings
- `*_ram.bin` — 64K RAM dumps (generated, not committed)
- `*_bios.bin` — Extracted BIOS binaries (generated)
- `*_bios.asm` — Disassembled BIOS (generated)
