# Makefile for RC702 autoload PROM rewrite
#
# Z80 build:   make rom      (requires z88dk)
# PROM image:  make prom     (assembles 2048-byte prom0.ic66)
# MAME launch: make mame     (builds, installs PROM, launches with debugger)
# MAME syms:   make mamesym  (generates prom0_mame.sym for debugger)
# RC700 emu:   make rc700    (builds PROM, compiles & runs rc700 emulator)
# Clean:       make clean

# Z80 ROM build (requires z88dk in ../z88dk)
Z88DK = ../z88dk
ZCC = $(Z88DK)/bin/zcc
ZCCCFG = $(Z88DK)/lib/config

# sdcc compiler with sdcccall(1) register calling convention
# rom.c: single-file Z80 build (HAL, init, FDC, format, boot, ISR)
# boot_rom.c: compiled into BOOT section (runs from ROM before relocation)
# intvec.c: IVT, compiled separately and linked first for 0x7000 placement
# sections.asm: linker section layout
#
# ZFLAGS: compile flags (used for -c steps and final link).
# ZLFLAGS: link-only flags (appmake, library).
#   -Cz"--org 0": tell appmake the binary starts at address 0
#     (suppresses "could not get the code ORG" warning with --no-crt).
ZFLAGS = +z80 -clib=sdcc_iy --no-crt --opt-code-size -SO3 \
         -Cs"--max-allocs-per-node 1000000" \
         -Cs"--fomit-frame-pointer" \
         -Cs"--allow-unsafe-read" \
         -Cs"--sdcccall 1" -Cs"--disable-warning 296" \
         -custom-copt-rules=peephole.def \
         -pragma-define:CRT_ORG_CODE=0x0000 \
         -pragma-define:CRT_ORG_BSS=0x8000

# z88dk library: provides intrinsic_di/ei/im_2, etc.
# Only referenced symbols are linked — zero overhead if unused.
ZLIB = -L$(Z88DK)/libsrc/_DEVELOPMENT/lib/sdcc_iy -lz80

ZLFLAGS = -m --list -create-app -Cz"--org 0" $(ZLIB)

all: clean rom

rom: sections.asm rom.c rom.h boot_rom.c intvec.c peephole.def
	export PATH="$(Z88DK)/bin:$$PATH" && \
	export ZCCCFG="$(ZCCCFG)" && \
	printf '#define BUILD_STAMP_STR "\\"%s\\""\n' "  ROA375-gensmedet $$(date '+%Y-%m-%d %H.%M')  " > build_stamp.h && \
	$(ZCC) $(ZFLAGS) -Cs"--codeseg BOOT" -c boot_rom.c -o boot_rom.o && \
	$(ZCC) $(ZFLAGS) -c intvec.c -o intvec.o && \
	$(ZCC) $(ZFLAGS) $(ZLFLAGS) -o prom0 sections.asm intvec.o rom.c boot_rom.o
	@ls -la prom0_BOOT.bin prom0_CODE.bin 2>/dev/null
	@BOOT=$$(wc -c < prom0_BOOT.bin); \
	 CODE=$$(wc -c < prom0_CODE.bin); \
	 PROM=$$((BOOT + CODE)); \
	 echo "BOOT: $$BOOT bytes, CODE: $$CODE bytes"; \
	 echo "PROM image: $$PROM bytes (BOOT + INTVEC+CODE)"; \
	 if [ $$PROM -gt 4096 ]; then \
	   echo "WARNING: PROM $$PROM exceeds 4096-byte limit by $$((PROM - 4096)) bytes"; \
	 else \
	   echo "OK: $$((4096 - PROM)) bytes under 4096-byte limit (debug 4KB mode)"; \
	 fi
	@if grep -q 'ix[+-]\|iy[+-]' rom.c.lis 2>/dev/null; then \
		echo "WARNING: IX/IY-relative addressing found (check if locals can be static):"; \
		grep 'ix[+-]\|iy[+-]' rom.c.lis; \
	fi
	@if grep -qE '__div[us]|__mod[us]|__mul[us]' prom0.map 2>/dev/null; then \
		echo "ERROR: sdcccall(0) library functions linked with sdcccall(1) code!"; \
		grep -E '__div[us]|__mod[us]|__mul[us]' prom0.map; \
		exit 1; \
	fi

# Assemble PROM image: BOOT + INTVEC+CODE + 0xFF pad to 4096
# (temporarily using 4KB/2732 for debug; revert to 2048/2716 for release)
# Without NMI section, BOOT and INTVEC+CODE are contiguous in the binary.
MAME = /Users/ravn/git/mame
MAME_ROM = $(MAME)/roms/rc702/roa375.ic66
RC700 = ../../rc700
FLOPPY = $(HOME)/Downloads/SW1711-I8.imd

prom: rom
	@BOOT=$$(wc -c < prom0_BOOT.bin | tr -d ' '); \
	 CODE=$$(wc -c < prom0_CODE.bin | tr -d ' '); \
	 TOTAL=$$((BOOT + CODE)); \
	 { cat prom0_BOOT.bin; \
	   cat prom0_CODE.bin; \
	   perl -e "print \"\\xff\" x (4096 - $$TOTAL)"; \
	 } > prom0.ic66; \
	 echo "prom0.ic66: $$(wc -c < prom0.ic66 | tr -d ' ') bytes"
	cp prom0.ic66 $(MAME_ROM)
	cp prom0.ic66 $(RC700)/roa375.rom

mame: prom mamesym
	@awk '{printf "comadd %s,%s\n", $$1, $$2}' prom0_mame.sym > prom0_debug.cmd
	$(MAME)/regnecentralend rc702 -rompath $(MAME)/roms \
		-nothrottle -window -skip_gameinfo \
		-seconds_to_run 60 \
		-autoboot_script mame_boot_test.lua \
		-flop1 "$(FLOPPY)"
	@cat /tmp/boot_test_result.txt
	@grep -q '^PASS' /tmp/boot_test_result.txt

# Build and run the RC700 emulator with SDL2
CC = cc
RC700_SRC = cpu0.c cpu1.c cpu2.c cpu3.c cpu4.c cpu5.c cpu6.c cpu7.c \
            rom.c charrom.c charram.c pio.c sio.c ctc.c dma.c crt.c \
            fdc.c wdc.c ftp.c disk.c fifo.c monitor.c disasm.c

rc700: prom
	cd $(RC700) && ./rom2struct roa375.rom roa375 > roa375.c && \
	$(CC) -DSDL_main=main -DSDL_MAIN_HANDLED -DPROM0=roa375 \
		-o rc700-sdl2 -O3 -Wno-unused-result \
		$(RC700_SRC) roa375.c rc700.c rcterm-sdl2.c screen.c \
		-F/Library/Frameworks -framework SDL2 \
		-Wl,-rpath,/Library/Frameworks
	$(RC700)/rc700-sdl2 "$(FLOPPY)"

# Convert z88dk map file to MAME debugger symbol definitions.
mamesym: prom0.map
	@awk '/= \$$[0-9A-Fa-f]+ ; addr,/ { \
		name = $$1; addr = $$3; \
		if (name ~ /^l_/) next; \
		sub(/^\$$/, "0x", addr); \
		sub(/^_/, "", name); \
		printf "%s %s\n", addr, name; \
	}' prom0.map | sort > prom0_mame.sym
	@echo "wrote prom0_mame.sym ($$(wc -l < prom0_mame.sym) symbols)"

clean:
	rm -f prom0 prom0_*.bin prom0_mame.sym prom0_debug.cmd prom0.ic66
	rm -f *.o *.bin *.map *.sym *.lis zcc_opt.def *.rom
	rm -f zcc_opt.def

.PHONY: all rom prom mame mamesym rc700 clean
