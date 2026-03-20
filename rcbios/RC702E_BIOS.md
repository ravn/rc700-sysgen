# RC702E BIOS Details

## Source Structure (src-rc702e/)

| Module | Content |
|--------|---------|
| BIOS.MAC | Top-level: ORG, port equates, work area DS layout, INCLUDE chain |
| INIT.MAC | Startup, relocation, hardware init |
| CPMBOOT.MAC | Jump table, cold/warm boot, CLOCK, LINSEL, signon; **REL220 also contains DISPLAY+FLOPPY+RAMDISK** (code008, ~12KB) |
| DISPLAY.MAC | REL201 only: DSPY_* + ISR_CRT + CONOUT; REL220 stub |
| FLOPPY.MAC | REL201 only: SELDSK through FLUSH; REL220 stub |
| RAMDISK.MAC | REL201 only: RAMDISK/RD/WR/DMA/IO/INT; REL220 stub |
| DISKTAB.MAC | 10 DPBs + skew tables; layout differs E201 vs E220 |
| INTTAB.MAC | IVT + ISR_DEFAULT + CONST/CONIN |
| VERIFY.MAC | REL220 only: 4096-byte VERIFY/BLOCKS.BAD utility |

E220's code008 block (0xD82B–0xE45F, ~12KB) merges all CPMBOOT+SIO+DISPLAY+FLOPPY+RAMDISK.
All function addresses in E220 are forward EQUs in BIOS.MAC; no internal labels.

## Variants

| | REL201 (mini) | REL220 (QD) |
|---|---|---|
| Flag | `-DREL201` | `-DREL220` |
| ORG | 0xD700 | 0xD480 |
| Jump table | 0xDA00 | 0xD780 |
| Verified | MATCH 5504 bytes | MATCH 9600 bytes |
| Reference | extracted_bios/cpm22_56k_rc702e_rel2.01_mini.bin | extracted_bios/cpm22_56k_rc702e_rel2.20_rc703.bin |

## Interrupt Table

Device assignment **identical to REL20 HARDDISK/56K**. SIO base vector = 0x10.

| Vector | Device | Handler |
|--------|--------|---------|
| I+0x00/02 | CTC1 CH.0/1 (baud) | DUMITR |
| I+0x04 | CTC1 CH.2 (display) | ISR_CRT |
| I+0x06 | CTC1 CH.3 (floppy) | FDC ISR |
| I+0x08–0x0E | CTC2 (unused, no HD) | ISR_DEFAULT |
| I+0x10–0x1E | SIO chain (TXB…SPECA) | SIO handlers |
| I+0x20 | PIO CH.A (keyboard) | KEYIT |
| I+0x22 | PIO CH.B (parallel) | PARIN |

All REL20 port equates apply directly (CTCCH0-3, SIOAC/SIOAD/SIOBC/SIOBD, PIOAC/PIOAD/PIOBC/PIOBD, DSPLC/DSPLD, FDC/FDD, DMAC/DMAMOD/DMAMAS/DMAxxn).

## Work Area Layout (0xFFD0–0xFFFF)

Defined with ORG+DS in BIOS.MAC after all INCLUDEs. 80×25 display RAM ends at 0xFFCF.

| Address | Size | Label | Description |
|---------|------|-------|-------------|
| 0xFFD0 | 1 | — | unused |
| 0xFFD1 | 1 | CURX / CCTAD | cursor X, column 0..79 |
| 0xFFD2 | 2 | CURY / RCTAD | cursor Y, row×80 (word) |
| 0xFFD4 | 1 | CURSY | CRT row-within-char counter |
| 0xFFD5 | 2 | LOCBUF | scroll source pointer (word) |
| 0xFFD7 | 1 | XFLG | display mode / XY escape state |
| 0xFFD8 | 2 | LOCAD | screen address for CONOUT (word) |
| 0xFFDA | 1 | USHER | character being output |
| 0xFFDB | 1 | — | unused (REL20: BGFLG — selective-clear mode) |
| 0xFFDC | 2 | — | unused (REL20: LOCBBU — BGSTAR pointer) |
| 0xFFDE | 1 | ADR0 | XY escape first coordinate byte |
| 0xFFDF | 2 | TIMER1 / EXCNT0 | warm-boot countdown (CRT ISR decrements) |
| 0xFFE1 | 2 | TIMER2 / EXCNT1 | motor stop countdown (FDC ISR decrements) |
| 0xFFE3 | 2 | DELCNT | TIMER2 reload / motor stop delay |
| 0xFFE5 | 2 | WARMJP / EXROUT | FDC seek delay counter (busy-wait, NOT a JP) |
| 0xFFE7 | 1 | FDTIMO / MOTORTIMER(E220) | JP opcode 0xC3 written by HALT |
| 0xFFE8 | 2 | — | JP target = WBOOT; called by ISR_CRT when TIMER1=0 |
| 0xFFEA | 2 | STPTIM | TIMER2 reload from boot config |
| 0xFFEC | 2 | CLKTIM | clock/screen-blank timer (FDC ISR decrements) |
| 0xFFEE | 14 | — | unused |
| 0xFFFC | 2 | RTCCNT | SETWARM save area for DE |
| 0xFFFE | 2 | — | SETWARM save area for HL |

**MOTORTIMER** is a code function label in FLOPPY.MAC (REL201 only, ~0xE608).
For REL220 it is an EQU alias (`MOTORTIMER EQU 0FFE7H`) pointing to the FDTIMO RAM slot.

## Known Gotchas

- **VERIFY.MAC `SCREENBUF:` label**: renamed to `verify_f800:` to avoid conflict with SCREENBUF EQU.
- **SIO.MAC not substitutable**: E201 uses hardcoded addresses (0xF4B2, 0xF526, 0xF4C9) where src/SIO.MAC uses symbolic refs. ISR block kept inline in CPMBOOT.MAC.
- **INIPARMS not in E201 binary**: E201 hardware tables live at 0xD500–0xD580 (below ORG 0xD700), not in assembled output.
- **zmac output rename**: `cp zout/BIOS.hex zout/BIOS_E{201,220}.hex` needed because zmac names output after input file.
