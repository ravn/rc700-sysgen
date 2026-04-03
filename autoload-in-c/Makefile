# Makefile for RC702 autoload PROM rewrite
#
# Usage:
#   make prom                    Build + install PROM (default: clang)
#   make prom COMPILER=sdcc      Build + install PROM with SDCC
#   make mame                   Build + boot in MAME
#   make clean                  Clean both compiler outputs

# ================================================================
# Compiler selection
# ================================================================

COMPILER ?= clang

# ================================================================
# Shared configuration
# ================================================================

MAME = /Users/ravn/git/mame
MAME_ROM = $(MAME)/roms/rc702/roa375.ic66
MAME_RUN = $(MAME)/regnecentralend rc702 -rompath $(MAME)/roms \
	-nothrottle -window -skip_gameinfo \
	-seconds_to_run 60 \
	-autoboot_script mame_boot_test.lua \
	-flop1 "$(FLOPPY)"
RC700 = ../../rc700
FLOPPY = $(HOME)/Downloads/SW1711-I8.imd

.PHONY: all prom mame mamesym rc700 clean \
        clang_asm clang_disasm clang_src_lis clang_symbols clang_mamesym

all: prom

# ================================================================
# PROM dispatch: make prom → build + pad + install
# ================================================================

prom:
	$(MAKE) $(COMPILER)/prom.bin
	@PROM=$$(wc -c < $(COMPILER)/prom.bin | tr -d ' '); \
	 echo "$(COMPILER) PROM: $$PROM / 4096 bytes"; \
	 if [ $$PROM -gt 4096 ]; then \
	   echo "WARNING: exceeds 4096-byte limit by $$((PROM - 4096)) bytes"; \
	 else \
	   echo "OK: $$((4096 - PROM)) bytes free"; \
	 fi
	@{ cat $(COMPILER)/prom.bin; \
	   perl -e "print \"\\xff\" x (4096 - $$(wc -c < $(COMPILER)/prom.bin | tr -d ' '))"; \
	 } > $(COMPILER)/prom0.ic66
	cp $(COMPILER)/prom0.ic66 $(MAME_ROM)

# ================================================================
# MAME targets
# ================================================================

mame: prom mamesym
	@awk '{printf "comadd %s,%s\n", $$1, $$2}' $(COMPILER)/prom0_mame.sym > $(COMPILER)/prom0_debug.cmd
	$(eval EXPECT := $(if $(filter sdcc,$(COMPILER)),RC700 ROA375,RC700 CL))
	EXPECT_BANNER="$(EXPECT)" $(MAME_RUN)
	@cat /tmp/boot_test_result.txt
	@grep -q '^PASS' /tmp/boot_test_result.txt

mamesym:
ifeq ($(COMPILER),clang)
	@$(DOCKER) $(CLANG_NM) --numeric-sort clang/prom.elf | \
		awk '/ [TtBbDd] / { sub(/^_/, "", $$3); printf "%s %s\n", $$1, $$3 }' \
		> clang/prom0_mame.sym
else
	@awk '/= \$$[0-9A-Fa-f]+ ; addr,/ { \
		name = $$1; addr = $$3; \
		if (name ~ /^l_/) next; \
		sub(/^\$$/, "0x", addr); \
		sub(/^_/, "", name); \
		printf "%s %s\n", addr, name; \
	}' sdcc/prom0.map | sort > sdcc/prom0_mame.sym
endif
	@echo "wrote $(COMPILER)/prom0_mame.sym ($$(wc -l < $(COMPILER)/prom0_mame.sym) symbols)"

# ================================================================
# LLVM-Z80 clang build
# ================================================================

LLVM_Z80 = $(CURDIR)/../../llvm-z80
CLANG_BUILD = /src/build/bin

DOCKER = docker run --rm -m 8g \
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
	       -Iclang -I. -Wno-gcc-compat -Wno-return-type \
	       -Wimplicit-int-conversion

CLANG_OBJS = clang/boot.o clang/intvec.o clang/rom.o clang/runtime.o
CLANG_COMPILER = $(LLVM_Z80)/build/bin/clang

clang/prom.bin: $(CLANG_OBJS) clang/rc700_prom.ld
	$(DOCKER) $(CLANG_LD) --gc-sections -T clang/rc700_prom.ld $(CLANG_OBJS) -o clang/prom.elf
	$(DOCKER) $(CLANG_OBJCOPY) -O binary clang/prom.elf clang/prom.bin
	$(DOCKER) $(CLANG_OBJDUMP) -d --triple=z80 clang/prom.elf > clang/prom.lis

clang/banner.h:
	@STAMP=" CL $$(date '+%Y-%m-%d %H.%M')/$$(whoami) "; \
	 BANNER=$$(printf "%-42.42s" " RC700$$STAMP"); \
	 echo "#define CLANG_BANNER \"$$BANNER\"" > $@

clang/boot.o: boot_rom.c rom.h clang/banner.h $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -c $< -o $@

clang/runtime.o: clang/runtime.s $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) --target=z80 -c $< -o $@

clang/intvec.o: intvec.c rom.h $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -c intvec.c -o $@

clang/rom.o: rom.c rom.h $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -c rom.c -o $@

clang_asm: rom.c rom.h
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -S rom.c -o /dev/stdout

clang_disasm: clang/prom.bin
	$(DOCKER) $(CLANG_OBJDUMP) -d --triple=z80 clang/prom.elf

clang_src_lis: rom.c rom.h boot_rom.c intvec.c clang/rc700_prom.ld $(CLANG_COMPILER)
	$(DOCKER) sh -c '\
	$(CLANG_CC) $(CLANG_CFLAGS) -g -c boot_rom.c -o /tmp/boot_g.o && \
	$(CLANG_CC) $(CLANG_CFLAGS) -g -c intvec.c -o /tmp/intvec_g.o && \
	$(CLANG_CC) $(CLANG_CFLAGS) -g -c rom.c -o /tmp/rom_g.o && \
	$(CLANG_CC) --target=z80 -c clang/runtime.s -o /tmp/runtime_g.o && \
	$(CLANG_LD) --gc-sections -T clang/rc700_prom.ld /tmp/boot_g.o /tmp/intvec_g.o /tmp/rom_g.o /tmp/runtime_g.o -o /tmp/prom_g.elf && \
	$(CLANG_OBJDUMP) -d -S --triple=z80 /tmp/prom_g.elf' > clang/prom_src.lis
	@echo "wrote clang/prom_src.lis"

clang_symbols: clang/prom.bin
	$(DOCKER) $(CLANG_NM) --numeric-sort clang/prom.elf

clang_mamesym: clang/prom.bin
	@$(DOCKER) $(CLANG_NM) --numeric-sort clang/prom.elf | \
		awk '/ [TtBbDd] / { sub(/^_/, "", $$3); printf "%s %s\n", $$1, $$3 }' \
		> clang/prom0_mame.sym
	@echo "wrote clang/prom0_mame.sym ($$(wc -l < clang/prom0_mame.sym) symbols)"

# ================================================================
# SDCC build (via z88dk Docker)
# ================================================================

Z88DK_DOCKER = docker run --rm \
	-v $(CURDIR):/src \
	-w /src \
	z88dk:v2.4

ZFLAGS = +z80 -clib=sdcc_iy --no-crt --opt-code-size -SO3 \
         -Cs"--max-allocs-per-node 1000000" \
         -Cs"--fomit-frame-pointer" \
         -Cs"--allow-unsafe-read" \
         -Cs"--sdcccall 1" -Cs"--disable-warning 296" \
         -custom-copt-rules=sdcc/peephole.def \
         -pragma-define:CRT_ORG_CODE=0x0000 \
         -pragma-define:CRT_ORG_BSS=0x8200

ZLIB = -lz80
ZLFLAGS = -m --list -create-app -Cz"--org 0" $(ZLIB)

sdcc/prom.bin: sdcc/sections.asm rom.c rom.h boot_rom.c intvec.c sdcc/peephole.def
	@mkdir -p sdcc
	$(Z88DK_DOCKER) sh -c '\
	STAMP=" ROA375 $$(date "+%Y-%m-%d %H.%M")/$$(whoami) " && \
	printf '"'"'#define BUILD_STAMP_STR "\\"%s\\""\n#define BUILD_STAMP "%s"\n'"'"' "$$STAMP" "$$STAMP" > sdcc/build_stamp.h && \
	zcc $(ZFLAGS) -Cs"--codeseg BOOT" -c boot_rom.c -o sdcc/boot_rom.o && \
	zcc $(ZFLAGS) -c intvec.c -o sdcc/intvec.o && \
	cd sdcc && zcc $(ZFLAGS) $(ZLFLAGS) -o prom0 sections.asm intvec.o ../rom.c boot_rom.o'
	@cd sdcc && cat prom0_BOOT.bin prom0_CODE.bin > prom.bin
	@PROM=$$(wc -c < sdcc/prom.bin | tr -d ' '); \
	 echo "sdcc PROM: $$PROM bytes"

# ================================================================
# RC700 emulator
# ================================================================

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

# ================================================================
# Clean
# ================================================================

clean:
	$(MAKE) -C clang clean
	$(MAKE) -C sdcc clean
	rm -f build_stamp.h prom0.ic66 prom0_mame.sym prom0_debug.cmd
