# RC702 CP/M BIOS in C (REL30)
#
# Usage:
#   make bios                 Build with default compiler (clang)
#   make bios COMPILER=sdcc   Build with SDCC via z88dk
#   make mame-maxi            Build + boot in MAME
#   make cycle-test            Cycle benchmark (ASM FILEX + TYPE FILEX.PRN)
#   make size                 Check binary size
#   make clean                Clean both compiler outputs
#
# Both compilers produce $(COMPILER)/bios.cim from the same shared sources.

# ================================================================
# Compiler selection
# ================================================================

COMPILER ?= clang

# ================================================================
# Shared configuration
# ================================================================

CC = cc
CFLAGS = -Wall -Wextra -std=c99 -DHOST_TEST

# Language conversion table: DANISH (default), SWEDISH, GERMAN,
# UK_ASCII, US_ASCII, FRENCH, LIBRARY
KBLANG ?= DANISH

# CP/M memory layout — single source of truth for MSIZE.
MSIZE ?= 56
BIAS  = $(shell echo $$(( ($(MSIZE) - 20) * 1024 )))
CPMB  = $(shell printf '0x%04X' $$(( 0x3400 + $(BIAS) )))
BIOSAD = $(shell printf '0x%04X' $$(( 0x3400 + $(BIAS) + 0x1600 )))

# Disk image tools
PATCH = python3 ../rcbios/patch_bios.py
IMDINFO = python3 ../rcbios/imdinfo.py

# MAME
MAME = /Users/ravn/git/mame
MAME_BIN = $(MAME)/regnecentralen
FLOPTOOL = $(MAME)/floptool

# Disk images for testing
IMG_MINI = $(HOME)/Downloads/CPM_med_COMAL80.imd
IMG_MAXI = $(HOME)/Downloads/SW1711-I8.imd
IMG_DATA = $(HOME)/Downloads/PolyPascal_3.10.imd

# Size limits (bytes)
MINI_LIMIT = 6144
MAXI_LIMIT = 9984

# zmac assembler
ifneq ($(wildcard ../zmac/bin/zmac),)
ZMAC = ../zmac/bin/zmac
else
ZMAC = zmac
endif
CPMCP = /Users/ravn/.local/bin/cpmcp

.PHONY: all bios size clean mame-mini mame-maxi mame-test conout-test bgstar-test \
        asm-test cycle-test cycle-baseline profile profile-baseline test \
        clang_asm clang_src_lis

all: bios size

# ================================================================
# Build timestamp (shared by both compilers)
# ================================================================

builddate.h: FORCE
	@echo '#define BUILDDATE "'$$(date +%Y-%m-%d\ %H:%M)'"' > $@.tmp
	@cmp -s $@.tmp $@ 2>/dev/null || mv $@.tmp $@
	@rm -f $@.tmp

builddate.inc: FORCE
	@echo '    defm " C-BIOS '$$(date +%Y-%m-%d\ %H:%M)' /Thorbjoern Ravn Andersen"' > $@.tmp
	@cmp -s $@.tmp $@ 2>/dev/null || mv $@.tmp $@
	@rm -f $@.tmp

FORCE:

# ================================================================
# Compiler dispatch: make bios → $(COMPILER)/bios.cim
# ================================================================

bios:
	$(MAKE) $(COMPILER)/bios.cim

# ================================================================
# LLVM-Z80 clang build
# ================================================================

LLVM_Z80 = $(CURDIR)/../../llvm-z80
CLANG_BUILD = /src/build/bin

DOCKER = docker run --rm -m 8g \
	-v $(LLVM_Z80):/src \
	-v $(CURDIR):/bios \
	-w /bios \
	ubuntu:24.04

CLANG_CC      = $(CLANG_BUILD)/clang
CLANG_LD      = $(CLANG_BUILD)/ld.lld
CLANG_OBJCOPY = $(CLANG_BUILD)/llvm-objcopy
CLANG_OBJDUMP = $(CLANG_BUILD)/llvm-objdump
CLANG_NM      = $(CLANG_BUILD)/llvm-nm
CLANG_COMPILER = $(LLVM_Z80)/build/bin/clang

CLANG_CFLAGS = --target=z80 -Oz -g -nostdlib \
	       -ffunction-sections -fdata-sections \
	       -Xclang -target-feature -Xclang +static-stack \
	       -mllvm -disable-lsr \
	       -Iclang -I. -Wno-gcc-compat -Wno-return-type \
	       -Wimplicit-int-conversion \
	       -fdebug-prefix-map=/bios=. \
	       -DMSIZE=$(MSIZE)

CLANG_OBJS = clang/boot_block.o clang/boot_confi.o \
	     clang/boot_entry.o clang/bios_hw_init.o \
	     clang/bios_jump_vector_table.o clang/bios.o \
	     clang/bios_shims.o clang/runtime.o

clang/bios.cim: builddate.h $(CLANG_OBJS) clang/rc700_bios.ld
	$(DOCKER) $(CLANG_LD) --gc-sections --defsym BIOSAD=$(BIOSAD) \
		-T clang/rc700_bios.ld $(CLANG_OBJS) -o clang/bios.elf
	$(DOCKER) $(CLANG_OBJCOPY) -O binary clang/bios.elf clang/bios.cim
	$(DOCKER) $(CLANG_OBJDUMP) -d --triple=z80 clang/bios.elf > clang/bios.lis
	@echo "clang BIOS: $$(wc -c < clang/bios.cim | tr -d ' ') bytes"
	@SIG=$$(dd if=clang/bios.cim bs=1 skip=8 count=6 2>/dev/null); \
	if [ "$$SIG" != " RC702" ]; then \
		echo "ERROR: RC702 signature not found!"; exit 1; \
	fi

clang/boot_block.o: boot_block.c bios.h builddate.h $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -c $< -o $@

clang/boot_confi.o: boot_confi.c bios.h $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) $(if $(filter-out DANISH,$(KBLANG)),-D$(KBLANG)) -c $< -o $@

clang/boot_entry.o: boot_entry.c bios.h hal.h clang/intrinsic.h $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -c $< -o $@

clang/bios_hw_init.o: bios_hw_init.c bios.h hal.h clang/intrinsic.h $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -c $< -o $@

clang/bios_jump_vector_table.o: clang/bios_jump_vector_table.c bios.h $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -c $< -o $@

clang/bios.o: bios.c bios.h hal.h clang/intrinsic.h clang/string.h builddate.h $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -c $< -o $@

clang/bios_shims.o: clang/bios_shims.s $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) --target=z80 -c $< -o $@

clang/runtime.o: clang/runtime.s $(CLANG_COMPILER)
	$(DOCKER) $(CLANG_CC) --target=z80 -c $< -o $@

clang_asm: bios.c bios.h hal.h clang/intrinsic.h clang/string.h builddate.h
	$(DOCKER) $(CLANG_CC) $(CLANG_CFLAGS) -S bios.c -o /dev/stdout

clang_src_lis: clang/bios.cim
	docker run --rm -m 8g \
		-v $(LLVM_Z80):/src \
		-v $(CURDIR):$(CURDIR):ro \
		-w $(CURDIR) \
		ubuntu:24.04 \
		$(CLANG_OBJDUMP) -d -S -l --triple=z80 $(CURDIR)/clang/bios.elf | \
		sed 's|^; \(\./.*\):\([0-9]*\)$$|\1:\2:|' > clang/bios_src.S
	@echo "wrote clang/bios_src.S ($$(wc -l < clang/bios_src.S) lines)"

# ================================================================
# SDCC build (via z88dk)
# ================================================================

# z88dk toolchain
ifneq ($(wildcard ../z88dk),)
Z88DK = ../z88dk
else
Z88DK = z88dk
endif
ZCC = $(Z88DK)/bin/zcc
ZCCCFG = $(Z88DK)/lib/config

ZFLAGS = +z80 -clib=sdcc_iy --no-crt --opt-code-size -SO3 \
         -Cs"--max-allocs-per-node 1000000" \
         -Cs"--fomit-frame-pointer" \
         -Cs"--allow-unsafe-read" \
         -Cs"--sdcccall 1" \
         -Cs"--std-sdcc99" \
         -Cs"--disable-warning 296" \
         -custom-copt-rules=sdcc/peephole.def \
         -pragma-define:CRT_ORG_CODE=0x0000 \
         -Cs"-DMSIZE=$(MSIZE)" \
         -Ca-DBIOSAD=$(BIOSAD) \
         $(if $(filter-out DANISH,$(KBLANG)),-Ca-D$(KBLANG))

ZLIB = -L$(Z88DK)/libsrc/_DEVELOPMENT/lib/sdcc_iy -lz80
ZLFLAGS = -m --list -create-app -Cz"--org 0" $(ZLIB)

sdcc/bios.cim: sdcc/z88dk_section_layout.asm boot_block.c boot_confi.c boot_entry.c \
               bios_hw_init.c bios_jump_vector_table.c bios.c hal.h bios.h \
               builddate.h builddate.inc sdcc/peephole.def
	@mkdir -p sdcc
	export PATH="$(Z88DK)/bin:$$PATH" && \
	export ZCCCFG="$(ZCCCFG)" && \
	$(ZCC) $(ZFLAGS) -Cs"--codeseg BOOT" -Cs"--constseg BOOT" -c boot_block.c -o sdcc/boot_block.o && \
	$(ZCC) $(ZFLAGS) -Cs"--codeseg BOOT_DATA" -Cs"--constseg BOOT_DATA" $(if $(filter-out DANISH,$(KBLANG)),-Cs"-D$(KBLANG)") -c boot_confi.c -o sdcc/boot_confi.o && \
	$(ZCC) $(ZFLAGS) -Cs"--codeseg BOOT_CODE" -c boot_entry.c -o sdcc/boot_entry.o && \
	$(ZCC) $(ZFLAGS) -Cs"--codeseg BOOT_CODE" -c bios_hw_init.c -o sdcc/bios_hw_init.o && \
	$(ZCC) $(ZFLAGS) -Cs"--codeseg BIOS" -Cs"--constseg BIOS" -c bios_jump_vector_table.c -o sdcc/bios_jump_vector_table.o && \
	cd sdcc && $(ZCC) $(ZFLAGS) $(ZLFLAGS) -o bios z88dk_section_layout.asm ../bios.c \
		boot_block.o boot_confi.o boot_entry.o bios_hw_init.o bios_jump_vector_table.o
	@cd sdcc && \
	BSS_HEAD=$$(grep '__bss_compiler_head' bios.map | head -1 | sed 's/.*= \$$\([0-9A-Fa-f]*\).*/\1/'); \
	CODESIZE=$$((0x$$BSS_HEAD - $(BIOSAD))); \
	cat bios_BOOT.bin > bios.cim; \
	dd if=bios_BIOS.bin bs=1 count=$$CODESIZE 2>/dev/null >> bios.cim
	@echo "sdcc BIOS: $$(wc -c < sdcc/bios.cim | tr -d ' ') bytes"
	@SIG=$$(dd if=sdcc/bios.cim bs=1 skip=8 count=6 2>/dev/null); \
	if [ "$$SIG" != " RC702" ]; then \
		echo "ERROR: RC702 signature not found!"; exit 1; \
	fi

# ================================================================
# Size check
# ================================================================

size: bios
	@SIZE=$$(wc -c < $(COMPILER)/bios.cim | tr -d ' '); \
	echo "$(COMPILER) BIOS: $$SIZE bytes"; \
	if [ $$SIZE -le $(MINI_LIMIT) ]; then \
		echo "  MINI (5.25\"): OK ($$(($(MINI_LIMIT) - SIZE)) bytes to spare)"; \
	else \
		echo "  MINI (5.25\"): OVER by $$((SIZE - $(MINI_LIMIT))) bytes"; \
	fi; \
	if [ $$SIZE -le $(MAXI_LIMIT) ]; then \
		echo "  MAXI (8\"):   OK ($$(($(MAXI_LIMIT) - SIZE)) bytes to spare)"; \
	else \
		echo "  MAXI (8\"):   OVER by $$((SIZE - $(MAXI_LIMIT))) bytes"; \
	fi

# ================================================================
# MAME boot targets — use $(COMPILER)/bios.cim
# ================================================================

mame-mini: bios
	@if [ "$(FORCE)" = "1" ] || [ ! -f /tmp/bios_c_mini.mfi ]; then \
		cp $(IMG_MINI) /tmp/bios_c_mini.imd; \
		$(PATCH) /tmp/bios_c_mini.imd $(COMPILER)/bios.cim; \
		rm -f /tmp/bios_c_mini.mfi; \
		$(FLOPTOOL) flopconvert auto mfi /tmp/bios_c_mini.imd /tmp/bios_c_mini.mfi >/dev/null 2>&1; \
		rm -f /tmp/bios_c_mini.imd; \
		echo "Created fresh MFI: /tmp/bios_c_mini.mfi"; \
	else \
		echo "Reusing existing MFI: /tmp/bios_c_mini.mfi (use FORCE=1 to recreate)"; \
	fi
	$(MAME_BIN) rc702mini -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_mini.mfi \
		-skip_gameinfo -window -resolution 1100x720

mame-maxi: bios
	@if [ "$(FORCE)" = "1" ] || [ ! -f /tmp/bios_c_maxi.mfi ]; then \
		cp $(IMG_MAXI) /tmp/bios_c_maxi.imd; \
		$(PATCH) /tmp/bios_c_maxi.imd $(COMPILER)/bios.cim; \
		rm -f /tmp/bios_c_maxi.mfi; \
		$(FLOPTOOL) flopconvert auto mfi /tmp/bios_c_maxi.imd /tmp/bios_c_maxi.mfi >/dev/null 2>&1; \
		rm -f /tmp/bios_c_maxi.imd; \
		echo "Created fresh A: drive MFI: /tmp/bios_c_maxi.mfi"; \
	else \
		echo "Reusing existing A: drive MFI (use FORCE=1 to recreate)"; \
	fi
	@if [ ! -f /tmp/bios_c_data.mfi ]; then \
		cp $(IMG_DATA) /tmp/bios_c_data.imd; \
		rm -f /tmp/bios_c_data.mfi; \
		$(FLOPTOOL) flopconvert auto mfi /tmp/bios_c_data.imd /tmp/bios_c_data.mfi >/dev/null 2>&1; \
		rm -f /tmp/bios_c_data.imd; \
		echo "Created B: data disk: /tmp/bios_c_data.mfi"; \
	else \
		echo "Reusing existing B: data disk"; \
	fi
	$(MAME_BIN) rc702 -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_maxi.mfi \
		-flop2 /tmp/bios_c_data.mfi \
		-skip_gameinfo -window -resolution 1100x720

# ================================================================
# Test targets
# ================================================================

# CONOTEST.COM — display control code exercise (CP/M program, built with SDCC)
conotest: conout_test.c builddate.h
	export PATH="$(Z88DK)/bin:$$PATH" && \
	export ZCCCFG="$(ZCCCFG)" && \
	$(ZCC) +cpm -clib=sdcc_iy -SO3 --opt-code-size \
		-Cs"--std-sdcc99" -create-app -o conotest conout_test.c
	@echo "conotest.com: $$(wc -c < conotest.com | tr -d ' ') bytes"

conout-test: bios conotest
	cp $(IMG_MAXI) /tmp/bios_c_conout.imd
	$(PATCH) /tmp/bios_c_conout.imd $(COMPILER)/bios.cim
	$(CPMCP) -f rc702-8dd /tmp/bios_c_conout.imd conotest.com 0:CONOTEST.COM
	$(eval KBBUF_ADDR := $(shell grep '_kbbuf ' $(COMPILER)/bios.map 2>/dev/null | sed 's/.*= \$$\([0-9A-F]*\).*/0x\1/' || echo 0))
	$(eval KBHEAD_ADDR := $(shell grep '_kbhead ' $(COMPILER)/bios.map 2>/dev/null | sed 's/.*= \$$\([0-9A-F]*\).*/0x\1/' || echo 0))
	sed 's/KBBUF_ADDR/$(KBBUF_ADDR)/g; s/KBHEAD_ADDR/$(KBHEAD_ADDR)/g' mame_conout_autotest.lua > /tmp/bios_c_conout_test.lua
	$(MAME_BIN) rc702 -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_conout.imd \
		-skip_gameinfo -window -resolution 1100x720 \
		-nothrottle \
		-autoboot_script /tmp/bios_c_conout_test.lua
	@echo "--- CONOUT test result ---"
	@cat /tmp/conout_result.txt
	@grep -q '^PASS' /tmp/conout_result.txt && echo "=== CONOUT TEST PASSED ===" || (echo "=== CONOUT TEST FAILED ==="; exit 1)

IMG ?= $(IMG_MAXI)
mame-test: bios
	cp $(IMG) /tmp/bios_c_test.imd
	$(PATCH) /tmp/bios_c_test.imd $(COMPILER)/bios.cim
	python3 verify_checksums.py /tmp/bios_c_test.imd > /tmp/expected_checksums.txt
	$(MAME_BIN) rc702 -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_test.imd \
		-skip_gameinfo -window -resolution 1100x720 \
		-nothrottle \
		-autoboot_script mame_disk_test.lua
	@echo "--- MAME screen ---"
	@cat /tmp/screen.txt
	@echo "--- Expected ---"
	@cat /tmp/expected_checksums.txt

bgstar-test: bios bgstar_test.asm mame_bgstar_test.lua
	$(ZMAC) -z --dri bgstar_test.asm
	cp $(IMG_MAXI) /tmp/bios_c_bgtest.imd
	$(PATCH) /tmp/bios_c_bgtest.imd $(COMPILER)/bios.cim
	$(CPMCP) -f rc702-8dd /tmp/bios_c_bgtest.imd zout/bgstar_test.cim 0:BGTEST.COM
	rm -f /tmp/bios_c_bgtest.mfi
	$(FLOPTOOL) flopconvert auto mfi /tmp/bios_c_bgtest.imd /tmp/bios_c_bgtest.mfi >/dev/null 2>&1
	rm -f /tmp/bios_c_bgtest.imd
	$(eval KBBUF_ADDR := $(shell grep '_kbbuf ' $(COMPILER)/bios.map 2>/dev/null | sed 's/.*= \$$\([0-9A-F]*\).*/0x\1/' || echo 0))
	$(eval KBHEAD_ADDR := $(shell grep '_kbhead ' $(COMPILER)/bios.map 2>/dev/null | sed 's/.*= \$$\([0-9A-F]*\).*/0x\1/' || echo 0))
	sed 's/KBBUF_ADDR/$(KBBUF_ADDR)/g; s/KBHEAD_ADDR/$(KBHEAD_ADDR)/g' mame_bgstar_test.lua > /tmp/bios_c_bgstar_test.lua
	$(MAME_BIN) rc702 -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_bgtest.mfi \
		-skip_gameinfo -window -resolution 1100x720 \
		-nothrottle \
		-autoboot_script /tmp/bios_c_bgstar_test.lua
	@echo "--- BGSTAR test results ---"
	@cat /tmp/bgstar_screens.txt

asm-test: bios
	./run_mame.sh -t

cycle-test: bios
	./run_mame.sh -c

cycle-baseline:
	./run_mame.sh -oc

profile: bios
	./run_mame.sh -p

profile-baseline:
	./run_mame.sh -op

# ================================================================
# Host tests (TODO)
# ================================================================

test:
	@echo "Host tests not yet implemented"

# ================================================================
# Clean
# ================================================================

clean:
	$(MAKE) -C clang clean
	$(MAKE) -C sdcc clean
	rm -f builddate.h builddate.inc
	rm -f /tmp/bios_c_mini.imd /tmp/bios_c_maxi.imd
