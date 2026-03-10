# RC702 CP/M BIOS in C (REL30)
#
# Host tests:  make test       (not yet implemented)
# Z80 build:   make bios       (requires z88dk)
# Size check:  make size       (verify fits in system tracks)
# MAME test:   make mame-mini  (build, patch, boot in MAME)

CC = cc
CFLAGS = -Wall -Wextra -std=c99 -DHOST_TEST

# z88dk toolchain
Z88DK = ../z88dk
ZCC = $(Z88DK)/bin/zcc
ZCCCFG = $(Z88DK)/lib/config

# sdcc via z88dk: register calling convention, optimize for size
# --sdcccall 1: register-based parameter passing (A/HL/DE)
# --disable-warning 296: suppressed because we use --no-crt and link NO stdlib.
#   The build rule checks the map file for any accidentally-linked sdcccall(0)
#   library functions (__div*, __mod*, __mul*) and fails if found.
ZFLAGS = +z80 -clib=sdcc_iy --no-crt --opt-code-size -SO3 \
         -Cs"--max-allocs-per-node 1000000" \
         -Cs"--fomit-frame-pointer" \
         -Cs"--allow-unsafe-read" \
         -Cs"--sdcccall 1" \
         -Cs"--std-sdcc99" \
         -Cs"--disable-warning 296" \
         -custom-copt-rules=peephole.def \
         -pragma-define:CRT_ORG_CODE=0xD480 \
         -m --list -create-app

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

# Size limits (bytes)
MINI_LIMIT = 6144
MAXI_LIMIT = 9984

.PHONY: all bios size clean mame-mini mame-maxi mame-test bgstar-test test

all: bios size

# Z80 build
# sdcccall safety: warning 296 is suppressed via --disable-warning 296 because
# we use --no-crt and don't link stdlib. Instead we check the map file post-link
# for any sdcccall(0) library functions that would silently corrupt arithmetic.
builddate.h: FORCE
	@echo '#define BUILDDATE "'$$(date +%Y-%m-%d\ %H:%M)'"' > $@.tmp
	@cmp -s $@.tmp $@ 2>/dev/null || mv $@.tmp $@
	@rm -f $@.tmp

FORCE:

bios: crt0.asm bios.c hal.h bios.h builddate.h danish.bin peephole.def
	export PATH="$(Z88DK)/bin:$$PATH" && \
	export ZCCCFG="$(ZCCCFG)" && \
	$(ZCC) $(ZFLAGS) -o bios crt0.asm bios.c
	@cp bios.rom bios.cim
	@echo "bios.cim: $$(wc -c < bios.cim | tr -d ' ') bytes"
	@if grep -q 'ix[+-]\|iy[+-]' bios.c.lis 2>/dev/null; then \
		echo "ERROR: IX/IY-relative addressing found in compiled code!"; \
		echo "Local variables must be static (no recursion in BIOS)."; \
		grep 'ix[+-]\|iy[+-]' bios.c.lis; \
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
	if [ $$((0x$$BSS_TAIL)) -ge $$((0xF500)) ]; then \
		printf "ERROR: BSS (ends 0x%s) overlaps ISTACK (0xF500)!\n" $$BSS_TAIL; \
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
# IMD is read-only in MAME; convert to MFI (writable) for testing.
mame-mini: bios
	cp $(IMG_MINI) /tmp/bios_c_mini.imd
	$(PATCH) /tmp/bios_c_mini.imd bios.cim
	$(FLOPTOOL) flopconvert auto mfi /tmp/bios_c_mini.imd /tmp/bios_c_mini.mfi >/dev/null 2>&1
	rm -f /tmp/bios_c_mini.imd
	$(MAME_BIN) rc702mini -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_mini.mfi \
		-skip_gameinfo -window -resolution 1100x720

# MAME boot test (maxi)
mame-maxi: bios
	cp $(IMG_MAXI) /tmp/bios_c_maxi.imd
	$(PATCH) /tmp/bios_c_maxi.imd bios.cim
	$(FLOPTOOL) flopconvert auto mfi /tmp/bios_c_maxi.imd /tmp/bios_c_maxi.mfi >/dev/null 2>&1
	rm -f /tmp/bios_c_maxi.imd
	$(MAME_BIN) rc702 -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_maxi.mfi \
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
ZMAC = ../zmac/bin/zmac
CPMCP = /Users/ravn/.local/bin/cpmcp

bgstar-test: bios bgstar_test.asm mame_bgstar_test.lua
	$(ZMAC) -z --dri bgstar_test.asm
	cp $(IMG_MAXI) /tmp/bios_c_bgtest.imd
	$(PATCH) /tmp/bios_c_bgtest.imd bios.cim
	$(CPMCP) -f rc702-8dd /tmp/bios_c_bgtest.imd zout/bgstar_test.cim 0:BGTEST.COM
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

# Host tests (TODO)
test:
	@echo "Host tests not yet implemented"

clean:
	rm -f bios bios.rom bios.cim bios_CODE.bin bios.map bios.lis
	rm -f *.o *.sym bios.def zcc_opt.def *.c.lis builddate.h
	rm -f /tmp/bios_c_mini.imd /tmp/bios_c_maxi.imd
