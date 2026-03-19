# RC702 CP/M BIOS in C (REL30)
#
# Host tests:  make test       (not yet implemented)
# Z80 build:   make bios       (requires z88dk)
# Size check:  make size       (verify fits in system tracks)
# MAME test:   make mame-mini  (build, patch, boot in MAME)

CC = cc
CFLAGS = -Wall -Wextra -std=c99 -DHOST_TEST

# z88dk toolchain
# Prefer repository sibling ../z88dk (common layout), fall back to z88dk
ifneq ($(wildcard ../z88dk),)
Z88DK = ../z88dk
else
Z88DK = z88dk
endif
ZCC = $(Z88DK)/bin/zcc
ZCCCFG = $(Z88DK)/lib/config

# Language conversion table: DANISH (default), SWEDISH, GERMAN,
# UK_ASCII, US_ASCII, FRENCH, LIBRARY
# Pass KBLANG=<language> to select. Omit or KBLANG=DANISH for default.
KBLANG ?= DANISH

# sdcc via z88dk: register calling convention, optimize for size
# --sdcccall 1: register-based parameter passing (A/HL/DE)
# --disable-warning 296: suppressed because we use --no-crt and link NO stdlib.
#   The build rule checks the map file for any accidentally-linked sdcccall(0)
#   library functions (__div*, __mod*, __mul*) and fails if found.
# ZFLAGS: common flags for compile (-c) and link steps.
# ZLFLAGS: additional flags for the final link step only.
#   -create-app: invoke appmake to split binary into BOOT/BIOS sections.
#   -Cm"--binorg 0": tell appmake the binary starts at address 0
#     (suppresses "could not get the code ORG" warning that occurs
#     because --no-crt has no standard CRT to read the origin from).
ZFLAGS = +z80 -clib=sdcc_iy --no-crt --opt-code-size -SO3 \
         -Cs"--max-allocs-per-node 1000000" \
         -Cs"--fomit-frame-pointer" \
         -Cs"--allow-unsafe-read" \
         -Cs"--sdcccall 1" \
         -Cs"--std-sdcc99" \
         -Cs"--disable-warning 296" \
         -custom-copt-rules=peephole.def \
         -pragma-define:CRT_ORG_CODE=0x0000 \
         $(if $(filter-out DANISH,$(KBLANG)),-Ca-D$(KBLANG))

ZLFLAGS = -m --list -create-app -Cz"--org 0"

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

.PHONY: all bios size clean mame-mini mame-maxi mame-test bgstar-test asm-test cycle-test cycle-baseline profile profile-baseline test

all: bios size

# Z80 build
# sdcccall safety: warning 296 is suppressed via --disable-warning 296 because
# we use --no-crt and don't link stdlib. Instead we check the map file post-link
# for any sdcccall(0) library functions that would silently corrupt arithmetic.
builddate.h: FORCE
	@echo '#define BUILDDATE "'$$(date +%Y-%m-%d\ %H:%M)'"' > $@.tmp
	@cmp -s $@.tmp $@ 2>/dev/null || mv $@.tmp $@
	@rm -f $@.tmp

builddate.inc: FORCE
	@echo '    defm " C-BIOS '$$(date +%Y-%m-%d\ %H:%M)' /Thorbjoern Ravn Andersen"' > $@.tmp
	@cmp -s $@.tmp $@ 2>/dev/null || mv $@.tmp $@
	@rm -f $@.tmp

FORCE:

bios: crt0.asm boot_block.c boot_confi.c boot_entry.c bios_page.c bios.c hal.h bios.h builddate.h builddate.inc peephole.def
	export PATH="$(Z88DK)/bin:$$PATH" && \
	export ZCCCFG="$(ZCCCFG)" && \
	$(ZCC) $(ZFLAGS) -Cs"--codeseg BOOT" -Cs"--constseg BOOT" -c boot_block.c -o boot_block.o && \
	$(ZCC) $(ZFLAGS) -Cs"--codeseg BOOT_DATA" -Cs"--constseg BOOT_DATA" $(if $(filter-out DANISH,$(KBLANG)),-Cs"-D$(KBLANG)") -c boot_confi.c -o boot_confi.o && \
	$(ZCC) $(ZFLAGS) -Cs"--codeseg BOOT_CODE" -c boot_entry.c -o boot_entry.o && \
	$(ZCC) $(ZFLAGS) -Cs"--codeseg BIOS" -Cs"--constseg BIOS" -c bios_page.c -o bios_page.o && \
	$(ZCC) $(ZFLAGS) $(ZLFLAGS) -o bios crt0.asm bios.c boot_block.o boot_confi.o boot_entry.o bios_page.o
	@BSS_HEAD=$$(grep '__bss_compiler_head' bios.map | head -1 | sed 's/.*= \$$\([0-9A-Fa-f]*\).*/\1/'); \
	CODESIZE=$$((0x$$BSS_HEAD - 0xDA00)); \
	cat bios_BOOT.bin > bios.cim; \
	dd if=bios_BIOS.bin bs=1 count=$$CODESIZE 2>/dev/null >> bios.cim
	@echo "bios.cim: $$(wc -c < bios.cim | tr -d ' ') bytes"
	@if grep -q 'ix[+-]\|iy[+-]' bios.c.lis 2>/dev/null; then \
		echo "ERROR: IX/IY-relative addressing found in compiled code!"; \
		echo "Local variables must be static (no recursion in BIOS)."; \
		grep 'ix[+-]\|iy[+-]' bios.c.lis; \
		rm -f bios.cim; \
		exit 1; \
	fi
	@if grep -q 'call.*_memset\|call.*_memcpy\|call.*_memmove' boot_entry.c.lis 2>/dev/null; then \
		echo "ERROR: Library call in boot_entry.c — must be fully inlined!"; \
		echo "cboot_body runs before BIOS relocation; no library is available."; \
		grep 'call.*_mem' boot_entry.c.lis; \
		rm -f bios.cim; \
		exit 1; \
	fi
	@if grep -qE '__div[us]|__mod[us]|__mul[us]' bios.map 2>/dev/null; then \
		echo "ERROR: sdcccall(0) library functions linked with sdcccall(1) code!"; \
		echo "These will silently produce WRONG RESULTS (warning 296 scenario)."; \
		echo "Avoid div/mod/mul operators, or use subtraction loops instead."; \
		grep -E '__div[us]|__mod[us]|__mul[us]' bios.map; \
		rm -f bios.cim; \
		exit 1; \
	fi
	@CODE_END=$$((0xD480 + $$(wc -c < bios.cim | tr -d ' ') - 1)); \
	BSS_HEAD=$$(grep '__bss_compiler_head' bios.map | head -1 | sed 's/.*= \$$\([0-9A-Fa-f]*\).*/\1/'); \
	BSS_TAIL=$$(grep '__bss_compiler_tail' bios.map | head -1 | sed 's/.*= \$$\([0-9A-Fa-f]*\).*/\1/'); \
	if [ $$CODE_END -ge $$((0x$$BSS_HEAD)) ]; then \
		printf "ERROR: Code (ends 0x%04X) overlaps BSS (0x%s)!\n" $$CODE_END $$BSS_HEAD; \
		rm -f bios.cim; \
		exit 1; \
	fi; \
	if [ $$((0x$$BSS_TAIL)) -ge $$((0xF600)) ]; then \
		printf "ERROR: BSS (ends 0x%s) overlaps ISTACK (0xF600)!\n" $$BSS_TAIL; \
		rm -f bios.cim; \
		exit 1; \
	fi

# Size check
size: bios
	@SIZE=$$(wc -c < bios.cim | tr -d ' '); \
	echo "Binary size: $$SIZE bytes"; \
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

# MAME boot test (mini)
# MFI is preserved between sessions (user data persists).  Use FORCE=1 to recreate.
mame-mini: bios
	@if [ "$(FORCE)" = "1" ] || [ ! -f /tmp/bios_c_mini.mfi ]; then \
		cp $(IMG_MINI) /tmp/bios_c_mini.imd; \
		$(PATCH) /tmp/bios_c_mini.imd bios.cim; \
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

# MAME boot test (maxi)
# MFI is preserved between sessions.  Use FORCE=1 to recreate.
# B drive: data disk (preserved between sessions, created once from source image).
mame-maxi: bios
	@if [ "$(FORCE)" = "1" ] || [ ! -f /tmp/bios_c_maxi.mfi ]; then \
		cp $(IMG_MAXI) /tmp/bios_c_maxi.imd; \
		$(PATCH) /tmp/bios_c_maxi.imd bios.cim; \
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

# Automated MAME disk test (maxi, with Lua script)
# Usage: make mame-test [IMG=/path/to/image.imd]
IMG ?= $(IMG_MAXI)
mame-test: bios
	cp $(IMG) /tmp/bios_c_test.imd
	$(PATCH) /tmp/bios_c_test.imd bios.cim
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

# BGSTAR foreground/background autotest (maxi, with Lua script)
# Prefer repository sibling ../zmac (common layout), fall back to zmac in PATH
ifneq ($(wildcard ../zmac/bin/zmac),)
ZMAC = ../zmac/bin/zmac
else
ZMAC = zmac
endif
CPMCP = /Users/ravn/.local/bin/cpmcp

bgstar-test: bios bgstar_test.asm mame_bgstar_test.lua
	$(ZMAC) -z --dri bgstar_test.asm
	cp $(IMG_MAXI) /tmp/bios_c_bgtest.imd
	$(PATCH) /tmp/bios_c_bgtest.imd bios.cim
	$(CPMCP) -f rc702-8dd /tmp/bios_c_bgtest.imd zout/bgstar_test.cim 0:BGTEST.COM
	rm -f /tmp/bios_c_bgtest.mfi
	$(FLOPTOOL) flopconvert auto mfi /tmp/bios_c_bgtest.imd /tmp/bios_c_bgtest.mfi >/dev/null 2>&1
	rm -f /tmp/bios_c_bgtest.imd
	$(eval KBBUF_ADDR := $(shell grep '_kbbuf ' bios.map | sed 's/.*= \$$\([0-9A-F]*\).*/0x\1/'))
	$(eval KBHEAD_ADDR := $(shell grep '_kbhead ' bios.map | sed 's/.*= \$$\([0-9A-F]*\).*/0x\1/'))
	sed 's/KBBUF_ADDR/$(KBBUF_ADDR)/g; s/KBHEAD_ADDR/$(KBHEAD_ADDR)/g' mame_bgstar_test.lua > /tmp/bios_c_bgstar_test.lua
	$(MAME_BIN) rc702 -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_bgtest.mfi \
		-skip_gameinfo -window -resolution 1100x720 \
		-nothrottle \
		-autoboot_script /tmp/bios_c_bgstar_test.lua
	@echo "--- BGSTAR test results ---"
	@cat /tmp/bgstar_screens.txt

# ASM FILEX integration test: build, patch, boot MAME at full speed,
# assemble FILEX.ASM, verify output.  Uses run_mame.sh -t.
asm-test: bios
	./run_mame.sh -t

# Cycle benchmark: ASM FILEX with timing + PC profiling
cycle-test: bios
	./run_mame.sh -c

# Baseline: run cycle test with original (unpatched) BIOS
cycle-baseline:
	./run_mame.sh -oc

# Instruction-level profile: trace TYPE FILEX.PRN (needs debug MAME)
profile: bios
	./run_mame.sh -p

# Profile baseline: original BIOS instruction trace
profile-baseline:
	./run_mame.sh -op

# Host tests (TODO)
test:
	@echo "Host tests not yet implemented"

clean:
	rm -f bios bios.rom bios.cim bios_code.bin bios_BIOS.bin bios_BOOT.bin bios.map bios.lis
	rm -f *.o *.sym bios.def zcc_opt.def *.c.lis *.c.asm builddate.h builddate.inc
	rm -f /tmp/bios_c_mini.imd /tmp/bios_c_maxi.imd
