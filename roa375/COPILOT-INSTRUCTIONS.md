Project instructions for automated and human helpers

ROA375.ASM is the disassembly of an existing rom in an old machine. 
I am interested in that the output binary is byte identical to roa375.rom as this is 
for documentation purposes, and in order to later produce a modified version
for using with the MAME emulator to provide better debug information and
other insights.

ROB358.MAC is a later version of the boot PROM for the next model RC703, 
and appears to be a rather large rewrite of the original ROA375.ASM, while
keeping the original style.  The RC703 is almost the same as the RC702 hardware wise.


- Goal: produce an output binary byte-identical to `roa375.rom`.
- Assembler: repository uses a local build at `../zmac/bin/zmac`. You can override with the `ZMAC` variable.
- Default assembler flags: `-z --dri -f` (see `ZMAC_FLAGS` in `Makefile`).
- Assemble command (example matching `Makefile`):
	- `../zmac/bin/zmac -z --dri -f roa375.asm`
	- or `make all` / `make verify` (the `all` target runs `verify`).
- Output file produced by the build: `zout/roa375.cim` (compare this to `roa375.rom`).
- Verification: run `make verify` (or `make all`) — the target runs `cmp` and shows first differences with address adjustment.
- CI: ensure the workflow calls `make all` or `make verify`.
- Do not modify canonical source files in-place; use branches or copies for experiments.
