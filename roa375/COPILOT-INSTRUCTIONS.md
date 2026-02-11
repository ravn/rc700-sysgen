Project instructions for automated and human helpers

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
