# Makefile for RC702 autoload PROM rewrite
#
# SDCC build:  make rom_parts (requires z88dk — default)
# Clang build: make clang     (requires docker + ~/git/llvm-z80/build/)
# PROM image:  make prom      (assembles 4096-byte prom0.ic66 from SDCC build)
# Clang PROM:  make clang_prom (assembles 4096-byte prom0.ic66 from clang build)
# MAME launch: make mame      (builds, installs PROM, launches with debugger)
# MAME syms:   make mamesym   (generates prom0_mame.sym for debugger)
# RC700 emu:   make rc700     (builds PROM, compiles & runs rc700 emulator)
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
         -pragma-define:CRT_ORG_BSS=0x8200

ZLIB = -lz80

ZLFLAGS = -m --list -create-app -Cz"--org 0" $(ZLIB)

all: clean rom_parts

rom_parts: sections.asm rom.c rom.h boot_rom.c intvec.c peephole.def
	export PATH="$(Z88DK)/bin:$$PATH" && \
	export ZCCCFG="$(ZCCCFG)" && \
	STAMP=" ROA375 $$(date '+%Y-%m-%d %H.%M')/$$(whoami) " && \
	printf '#define BUILD_STAMP_STR "\\"%s\\""\n#define BUILD_STAMP "%s"\n' "$$STAMP" "$$STAMP" > build_stamp.h && \
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
	@SENTINEL=$$(grep '__code_sentinel_tail' prom0.map | awk '{print $$3}' | tr -d '$$'); \
	if [ -n "$$SENTINEL" ] && [ $$((16#$$SENTINEL)) -gt $$((0x7A00)) ]; then \
		echo "FATAL: CODE overlaps display memory at 0x7A00 (sentinel at 0x$$SENTINEL)"; \
		exit 1; \
	fi

# Assemble PROM image: BOOT + INTVEC+CODE + 0xFF pad to 4096
# (temporarily using 4KB/2732 for debug; revert to 2048/2716 for release)
# Without NMI section, BOOT and INTVEC+CODE are contiguous in the binary.
MAME = /Users/ravn/git/mame
MAME_ROM = $(MAME)/roms/rc702/roa375.ic66
RC700 = ../../rc700
FLOPPY = $(HOME)/Downloads/SW1711-I8.imd

prom: rom_parts
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

# ================================================================
# LLVM-Z80 clang build (requires Docker + ~/git/llvm-z80/build/)
# ================================================================
# Same rom.c, rom.h, and boot_rom.c — dual-compiler compatible via
# #ifdef __clang__.  boot_rom.c uses file-scope __asm__ with GNU as
# directives for clang, SDCC asm directives for z88dk.

LLVM_Z80 = $(HOME)/git/llvm-z80
CLANG_BUILD = /src/build/bin

DOCKER = docker run --rm \
	-v $(LLVM_Z80):/src \
	-v $(CURDIR):/rom \
	-w /rom \
	ubuntu:24.04

CLANG_CC      = $(CLANG_BUILD)/clang
CLANG_LD      = $(CLANG_BUILD)/ld.lld
CLANG_OBJCOPY = $(CLANG_BUILD)/llvm-objcopy
CLANG_OBJDUMP = $(CLANG_BUILD)/llvm-objdump
CLANG_NM      = $(CLANG_BUILD)/llvm-nm

CLANG_CFLAGS = --target=z80 -Os -nostdlib \
	       -ffunction-sections -fdata-sections \
	       -Xclang -target-feature -Xclang +static-stack \
	       -Xclang -target-feature -Xclang +shadow-regs \
	       -mllvm -disable-lsr \
	       -Iclang_z80 -I. -Wno-gcc-compat -Wno-return-type

CLANG_OBJS = clang_z80/boot.o clang_z80/intvec.o clang_z80/rom.o clang_z80/runtime.o
CLANG_COMPILER = $(LLVM_Z80)/build/bin/clang

clang: $(CLANG_OBJS) clang_z80/rc700_prom.ld
	$(DOCKER) $(CLANG_LD) --gc-sections -T clang_z80/rc700_prom.ld $(CLANG_OBJS) -o clang_z80/prom.elf
	$(DOCKER) $(CLANG_OBJCOPY) -O binary clang_z80/prom.elf clang_z80/prom.bin
	$(DOCKER) $(CLANG_OBJDUMP) -d --triple=z80 clang_z80/prom.elf > clang_z80/prom.lis
	@PROM=$$(wc -c < clang_z80/prom.bin | tr -d ' '); \
	 echo "clang PROM: $$PROM / 4096 bytes"; \
	 if [ $$PROM -gt 4096 ]; then \
	   echo "WARNING: exceeds 4096-byte limit by $$((PROM - 4096)) bytes"; \
	 else \
	   echo "OK: $$((4096 - PROM)) bytes free"; \
	 fi

clang_z80/banner.h:
	@STAMP=" CL $$(date '+%Y-%m-%d %H.%M')/$$(whoami) "; \
	 BANNER=$$(printf "%-42.42s" " RC700$$STAMP"); \
	 echo "#define CLANG_BANNER \"$$BANNER\"" > $@

clang_z80/boot.o: boot_rom.c rom.h clang_z80/banner.h $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -c $< -o $@

clang_z80/runtime.o: clang_z80/runtime.s $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) --target=z80 -c $< -o $@

clang_z80/intvec.o: intvec.c rom.h $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -c intvec.c -o $@

clang_z80/rom.o: rom.c rom.h $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -c rom.c -o $@

clang_prom: clang
	@{ cat clang_z80/prom.bin; \
	   perl -e "print \"\\xff\" x (4096 - $$(wc -c < clang_z80/prom.bin | tr -d ' '))"; \
	 } > prom0.ic66
	@echo "prom0.ic66: $$(wc -c < prom0.ic66 | tr -d ' ') bytes (clang build)"
	cp prom0.ic66 $(MAME_ROM)
	cp prom0.ic66 $(RC700)/roa375.rom

clang_asm: rom.c rom.h
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -S rom.c -o /dev/stdout

clang_disasm: clang
	$(DOCKER) $(CLANG_OBJDUMP) -d --triple=z80 clang_z80/prom.elf

clang_symbols: clang
	$(DOCKER) $(CLANG_NM) --numeric-sort clang_z80/prom.elf

clang_mamesym: clang
	@$(DOCKER) $(CLANG_NM) --numeric-sort clang_z80/prom.elf | \
		awk '/ [TtBbDd] / { sub(/^_/, "", $$3); printf "%s %s\n", $$1, $$3 }' \
		> prom0_mame.sym
	@echo "wrote prom0_mame.sym ($$(wc -l < prom0_mame.sym) symbols)"

clang_clean:
	rm -f clang_z80/*.o clang_z80/prom.elf clang_z80/prom.bin

clean:
	rm -f prom0 prom0_*.bin prom0_mame.sym prom0_debug.cmd prom0.ic66
	rm -f *.o *.bin *.map *.sym *.lis zcc_opt.def *.rom
	rm -f zcc_opt.def
	rm -f clang_z80/*.o clang_z80/prom.elf clang_z80/prom.bin clang_z80/banner.h

.PHONY: all rom_parts prom mame mamesym rc700 clean \
	clang clang_prom clang_asm clang_disasm clang_symbols clang_mamesym clang_clean
