# Makefile for RC702 autoload PROM rewrite
#
# Host tests:  make test
# Z80 build:   make rom      (requires z88dk)
# PROM image:  make prom     (assembles 2048-byte roa375.ic66)
# MAME launch: make mame     (builds, installs PROM, launches with debugger)
# MAME syms:   make mamesym  (generates roa375_mame.sym for debugger)
# Clean:       make clean

CC = cc
CFLAGS = -Wall -Wextra -std=c99 -DHOST_TEST

# Host test builds (uses mock HAL)
HOST_COMMON = boot.c fdc.c fmt.c init.c isr.c hal_host.c

test: test_boot test_fdc
	./test_boot
	./test_fdc

test_boot: test_boot.c $(HOST_COMMON) hal.h boot.h
	$(CC) $(CFLAGS) -o $@ test_boot.c $(HOST_COMMON)

test_fdc: test_fdc.c $(HOST_COMMON) hal.h boot.h
	$(CC) $(CFLAGS) -o $@ test_fdc.c $(HOST_COMMON)

# Z80 ROM build (requires z88dk in ../z88dk)
Z88DK = ../z88dk
ZCC = $(Z88DK)/bin/zcc
ZCCCFG = $(Z88DK)/lib/config

# sdcc compiler with sdcccall(1) register calling convention
# C files: boot.c, fdc.c, fmt.c, isr.c (compiled by sdcc into CODE section)
# boot_entry.c: compiled into BOOT section (runs from ROM before relocation)
# Assembly: crt0.asm (hand-written startup + utilities)
ZFLAGS = +z80 -clib=sdcc_iy --no-crt --opt-code-size -SO3 \
         -Cs"--max-allocs-per-node 1000000" \
         -Cs"--fomit-frame-pointer" \
         -Cs"--allow-unsafe-read" \
         -Cs"--sdcccall 1" \
         -custom-copt-rules=peephole.def \
         -pragma-define:CRT_ORG_CODE=0x0000 \
         -pragma-define:CRT_ORG_BSS=0x8000 \
         -m --list -create-app

rom: crt0.asm rom_all.c boot_entry.c boot.c fdc.c fmt.c isr.c peephole.def
	export PATH="$(Z88DK)/bin:$$PATH" && \
	export ZCCCFG="$(ZCCCFG)" && \
	$(ZCC) $(ZFLAGS) -Cs"--codeseg BOOT" -c boot_entry.c -o boot_entry.o && \
	$(ZCC) $(ZFLAGS) -o roa375 crt0.asm rom_all.c boot_entry.o
	@ls -la roa375_BOOT.bin roa375_NMI.bin roa375_CODE.bin 2>/dev/null
	@BOOT=$$(wc -c < roa375_BOOT.bin); \
	 NMI=$$(wc -c < roa375_NMI.bin); \
	 CODE=$$(wc -c < roa375_CODE.bin); \
	 GAP=$$((0x0066 - BOOT)); \
	 PROM=$$((0x0068 + CODE)); \
	 echo "BOOT: $$BOOT bytes, gap: $$GAP bytes, NMI: $$NMI bytes at 0x0066, CODE: $$CODE bytes"; \
	 echo "PROM image: $$PROM bytes (NMI_tail + CODE)"; \
	 if [ $$BOOT -gt 102 ]; then \
	   echo "ERROR: BOOT section ($$BOOT bytes) overflows into NMI handler at 0x0066"; \
	 elif [ $$PROM -gt 2048 ]; then \
	   echo "WARNING: PROM $$PROM exceeds 2048-byte limit by $$((PROM - 2048)) bytes"; \
	 else \
	   echo "OK: $$((2048 - PROM)) bytes under 2048-byte limit"; \
	 fi

# Assemble PROM image: BOOT + 0xFF gap + NMI + CODE + 0xFF pad to 2048
MAME = /Users/ravn/git/mame
MAME_ROM = $(MAME)/roms/rc702/roa375.ic66
FLOPPY = $(HOME)/Downloads/CPM_med_COMAL80.imd

prom: rom
	@BOOT=$$(wc -c < roa375_BOOT.bin | tr -d ' '); \
	 CODE=$$(wc -c < roa375_CODE.bin | tr -d ' '); \
	 { cat roa375_BOOT.bin; \
	   perl -e "print \"\\xff\" x (0x66 - $$BOOT)"; \
	   cat roa375_NMI.bin; \
	   cat roa375_CODE.bin; \
	   perl -e "print \"\\xff\" x (2048 - 0x68 - $$CODE)"; \
	 } > roa375.ic66; \
	 echo "roa375.ic66: $$(wc -c < roa375.ic66 | tr -d ' ') bytes"

mame: prom mamesym
	cp roa375.ic66 $(MAME_ROM)
	$(MAME)/regnecentralen rc702 -rompath $(MAME)/roms -debug \
		-flop1 "$(FLOPPY)"

# Convert z88dk map file to MAME debugger symbol definitions.
# Usage in MAME debugger console: copy-paste lines, or source via Lua.
# Filters to addr entries only, strips C underscore prefix, skips
# compiler-generated labels (l_*), sorts by address.
mamesym: roa375.map
	@awk '/= \$$[0-9A-Fa-f]+ ; addr,/ { \
		name = $$1; addr = $$3; \
		if (name ~ /^l_/) next; \
		sub(/^\$$/, "0x", addr); \
		sub(/^_/, "", name); \
		printf "%s %s\n", addr, name; \
	}' roa375.map | sort > roa375_mame.sym
	@echo "wrote roa375_mame.sym ($$(wc -l < roa375_mame.sym) symbols)"

clean:
	rm -f test_boot test_fdc roa375 roa375_*.bin roa375_mame.sym roa375.ic66
	rm -f *.o *.bin *.map *.sym *.lis *.def *.rom
	rm -f zcc_opt.def

.PHONY: test rom prom mame mamesym clean
