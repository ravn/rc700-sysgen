# cpnos-rom — Combined CP/NOS client ROM for RC702

Single 4KB ROM image (two 2KB EPROMs: PROM0 @ 0x0000, PROM1 @ 0x2000) that
boots the RC702 as a CP/NOS client against an MP/M master over SIO-A
async 38400 baud, with optional 8" DSDD local diskette support.

## Status

2026-04-23: Initial+minimal version of CP/NOS client ROM, fully functional in MAME against z80pack

Phase 0 (scaffolding). See
[`../rcbios-in-c/tasks/cpnos-rom-plan.md`](../rcbios-in-c/tasks/cpnos-rom-plan.md)
for the full plan.

## Build configurations

- `make cpnos ENABLE_FDC=0` — NOS-only, targets ~55–56 KB TPA
- `make cpnos ENABLE_FDC=1` — NOS + 8" DSDD local floppy, targets ~52 KB TPA

Both produce a 4096-byte image split into `prom0.bin` (0x0000–0x07FF) and
`prom1.bin` (0x2000–0x27FF) for burning.

## Design constraints

- Display RAM at 0xF800–0xFFFF unchanged (Comal80 compatibility).
- BIOS resident code relocated to high RAM before PROM disable.
- Single OUT (0x18) disables both PROMs; everything needed at runtime must
  be in RAM by that point.
- Transport abstracted behind a vtable — parallel port (J3/J4) is parked
  but drops in without restructuring.

## Files (as Phase 0 adds them)

- `Makefile` — build targets, size check, PROM image split
- `cpnos_rom.ld` — linker script, 4KB ROM region + high-RAM runtime region
- `reset.s` — reset vector, minimum init before C
- `cpnos_main.c` — cold-boot driver: copy runtime to RAM, disable PROM, netboot
- `snios.asm` — ported from `../cpnet/snios.asm`, relocated entry points
- `netboot.asm` — ported from `../../cpnet-z80/src/netboot.asm`
- `bios_jt.c` — BIOS jump table (stubs for NOS, real bodies for FDC build)
- `console.c` — CONIN/CONOUT/CONST on SIO-B
- `fdc.c`, `deblock.c`, `dpb_maxi.c` — only compiled when `ENABLE_FDC=1`
