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

# Keyboard PIO port: A (default, stock RC702) or B (frees A for host link)
KBDPORT ?= A

# CP/M memory layout — single source of truth for MSIZE.
MSIZE ?= 56
BIAS  = $(shell echo $$(( ($(MSIZE) - 20) * 1024 )))
CPMB  = $(shell printf '0x%04X' $$(( 0x3400 + $(BIAS) )))
BIOSAD = $(shell printf '0x%04X' $$(( 0x3400 + $(BIAS) + 0x1600 )))

# Disk image tools
PATCH = python3 ../rcbios/patch_bios.py
IMDINFO = python3 ../rcbios/imdinfo.py

# MAME — default to the submodule inside the workspace so the path
# works on any machine that has `z80-compiler-suite-workspace` checked
# out with submodules initialised.  Override with `make MAME=/path/to/mame`
# if you keep MAME somewhere else.
MAME ?= $(CURDIR)/../../mame
# Prefer the debug binary (`regnecentralend`) over the release
# (`regnecentralen`) when both exist; use whichever is present.
MAME_BIN ?= $(firstword $(wildcard $(MAME)/regnecentralend $(MAME)/regnecentralen))
FLOPTOOL = $(MAME)/floptool

# Parallelism for `make mame-debug`.  Defaults to nproc/2 so a 4-core
# box builds with -j 2 (safe for ~4 GB headroom); override on bigger
# machines with `make mame-debug MAME_BUILD_JOBS=10`.
MAME_BUILD_JOBS ?= $(shell n=$$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 2); echo $$(( n > 1 ? n / 2 : 1 )))

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
CPMCP ?= cpmcp

.PHONY: all bios size clean mame-mini mame-maxi mame-test conout-test bgstar-test \
        asm-test cycle-test cycle-baseline profile profile-baseline test \
        mame-debug mame-roms siob-iobyte-test

all: bios size

# ================================================================
# Build timestamp (shared by both compilers)
# ================================================================

builddate.h: FORCE
	@echo '#define BUILDDATE "'$$(date +%Y-%m-%d\ %H:%M)'"' > $@.$$$$; \
	 cmp -s $@.$$$$ $@ 2>/dev/null && rm -f $@.$$$$ || mv $@.$$$$ $@

builddate.inc: FORCE
	@echo '    defm " C-BIOS '$$(date +%Y-%m-%d\ %H:%M)' /Thorbjoern Ravn Andersen"' > $@.$$$$; \
	 cmp -s $@.$$$$ $@ 2>/dev/null && rm -f $@.$$$$ || mv $@.$$$$ $@

FORCE:

# ================================================================
# Compiler dispatch: make bios → $(COMPILER)/bios.cim
# ================================================================

bios: builddate.h
	$(MAKE) -C $(COMPILER) bios.cim MSIZE=$(MSIZE) KBLANG=$(KBLANG) KBDPORT=$(KBDPORT)

# SDCC build rules are in sdcc/Makefile

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
		-Cs"--std-sdcc23" -create-app -o conotest conout_test.c
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
# MAME build (regnecentralen subtarget, debug)
# ================================================================
#
# Builds the MAME binary used by every mame-* target in this file.
# Uses the exact recipe from mame/src/mame/regnecentralen/README.md:
#
#   make SUBTARGET=regnecentralen DEBUG=1 \
#        SOURCES=src/mame/regnecentralen/rc702.cpp \
#        TOOLS=1 SYMLEVEL=3 SYMBOLS=1 OSD=sdl -j ...
#
# Notes:
#   - Produces $(MAME)/regnecentralend (the "d" suffix is DEBUG=1).
#   - OSD=sdl forces SDL2 rather than MAME's default SDL3.  This is
#     correct when only libsdl2-dev is installed (macOS via brew-less
#     path, and most current Ubuntu releases).  If you have libsdl3-dev
#     installed and want to test it, override OSD: `make mame-debug OSD=sdl3`.
#   - MAME_BUILD_JOBS defaults to nproc/2 to keep the peak RSS under
#     ~4 GB per link.  Override with `make mame-debug MAME_BUILD_JOBS=10`.

OSD ?= sdl

mame-debug:
	@if [ ! -d "$(MAME)" ]; then \
		echo "ERROR: MAME directory not found at $(MAME)"; \
		echo "Initialise the submodule: git submodule update --init --depth 1 mame"; \
		exit 1; \
	fi
	@echo "=== Building MAME regnecentralen (debug) with -j $(MAME_BUILD_JOBS) ==="
	$(MAKE) -C $(MAME) \
		SUBTARGET=regnecentralen \
		DEBUG=1 \
		SOURCES=src/mame/regnecentralen/rc702.cpp \
		TOOLS=1 SYMLEVEL=3 SYMBOLS=1 \
		OSD=$(OSD) \
		-j $(MAME_BUILD_JOBS)
	@echo "=== Binary at $(MAME)/regnecentralend ==="
	@ls -lh $(MAME)/regnecentralend

# ================================================================
# RC702 ROMs (roa375, roa296, roa327, rob357, rob358)
# ================================================================
#
# Downloads the boot PROM and character generator ROMs that rc702.cpp
# references, from github.com/ravn/rc700.  Normally run once per
# workspace checkout.  Individual ROM files are listed so `make` can
# fetch missing ones incrementally.

RC702_ROM_DIR = $(MAME)/roms/rc702
RC702_ROM_BASE = https://github.com/ravn/rc700/raw/refs/heads/master
RC702_ROMS = \
	$(RC702_ROM_DIR)/roa296.rom \
	$(RC702_ROM_DIR)/roa327.rom \
	$(RC702_ROM_DIR)/rob357.rom \
	$(RC702_ROM_DIR)/rob358.rom \
	$(RC702_ROM_DIR)/roa375.ic66

mame-roms: $(RC702_ROMS)
	@echo "=== RC702 ROMs present in $(RC702_ROM_DIR) ==="
	@ls -l $(RC702_ROM_DIR)

$(RC702_ROM_DIR)/%.rom:
	@mkdir -p $(RC702_ROM_DIR)
	curl -fsSL -o $@ $(RC702_ROM_BASE)/$(notdir $@)

# roa375 has the .rom source file but is installed as .ic66 (MAME
# references the IC designator for PROM sockets).
$(RC702_ROM_DIR)/roa375.ic66:
	@mkdir -p $(RC702_ROM_DIR)
	curl -fsSL -o $@ $(RC702_ROM_BASE)/roa375.rom

# ================================================================
# SIO-B IOBYTE routing test
# ================================================================
#
# Verifies that STAT RDR:=UR1: routes RDR: through SIO-B (the new
# IOB_BAT arm in bios_reader_body).  Wires SIO-B to a TCP server and
# runs PIP CON:=RDR:[E] inside MAME, screen-scraping for a marker.
#
# Requires:
#   - MAME with -rs232b null_modem support (rc702 driver)
#   - python3 for the TCP server
#
# Pass: /tmp/siob_iobyte_result starts with "PASS"
# Fail: non-zero exit; inspect /tmp/siob_iobyte_result and MAME window

SIOB_PORT ?= 4323
SIOB_MARKER = SIOB-IOBYTE-TEST-OK

siob-iobyte-test: bios mame-roms
	@echo "=== SIO-B IOBYTE test ==="
	@if [ -z "$(MAME_BIN)" ]; then \
		echo "ERROR: no MAME binary found at $(MAME)/regnecentralend or $(MAME)/regnecentralen"; \
		echo "Run 'make mame-debug' first to build it."; \
		exit 1; \
	fi
	@echo "Using MAME_BIN=$(MAME_BIN)"
	cp $(IMG_MAXI) /tmp/bios_c_siob.imd
	$(PATCH) /tmp/bios_c_siob.imd $(COMPILER)/bios.cim
	@# Payload the server will send over SIO-B.  The Lua script scrapes
	@# the CRT for $(SIOB_MARKER) after PIP echoes it.
	@printf '$(SIOB_MARKER)\r\n' > /tmp/siob_iobyte_payload.txt
	@rm -f /tmp/siob_iobyte_trigger /tmp/siob_iobyte_result
	@echo "Starting SIO-B server on port $(SIOB_PORT) ..."
	@python3 siob_iobyte_server.py /tmp/siob_iobyte_payload.txt $(SIOB_PORT) \
		> /tmp/siob_iobyte_server.log 2>&1 & echo $$! > /tmp/siob_iobyte_server.pid
	@sleep 0.5
	-$(MAME_BIN) rc702 -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_siob.imd \
		-rs232b null_modem \
		-bitb "socket.localhost:$(SIOB_PORT)" \
		-skip_gameinfo -window -resolution 1100x720 \
		-autoboot_script $(CURDIR)/mame_siob_iobyte_test.lua
	@# Kill the server if it's still running (Lua already wrote the result)
	@if [ -f /tmp/siob_iobyte_server.pid ]; then \
		kill $$(cat /tmp/siob_iobyte_server.pid) 2>/dev/null; \
		rm -f /tmp/siob_iobyte_server.pid; \
	fi
	@echo ""
	@echo "--- SIO-B server log ---"
	@cat /tmp/siob_iobyte_server.log 2>/dev/null || echo "(no log)"
	@echo ""
	@echo "--- Lua result ---"
	@cat /tmp/siob_iobyte_result 2>/dev/null || (echo "(no result file — Lua did not finish)"; exit 1)
	@head -1 /tmp/siob_iobyte_result | grep -q '^PASS' \
		&& echo "=== SIO-B IOBYTE test PASSED ===" \
		|| (echo "=== SIO-B IOBYTE test FAILED ==="; exit 1)

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
