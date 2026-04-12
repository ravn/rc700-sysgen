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
        asm-test cycle-test cycle-baseline profile profile-baseline test

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

siob-iobyte-test: bios
	@echo "=== SIO-B IOBYTE test ==="
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
		-bitb2 "socket.localhost:$(SIOB_PORT)" \
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
# SIO-B direct BIOS test (no PIP/STAT — calls BIOS READER directly)
# ================================================================

siob-test: bios
	@echo "=== SIO-B direct BIOS test ==="
	../zmac/bin/zmac -z siob_test.asm
	cp $(IMG_MAXI) /tmp/bios_c_siob2.imd
	$(PATCH) /tmp/bios_c_siob2.imd $(COMPILER)/bios.cim
	$(CPMCP) -f rc702-8dd /tmp/bios_c_siob2.imd zout/siob_test.cim 0:SIOBTEST.COM
	@printf '$(SIOB_MARKER)\r\n' > /tmp/siob_test_payload.txt
	@rm -f /tmp/siob_iobyte_trigger /tmp/siob_test_result
	@echo "Starting SIO-B server on port $(SIOB_PORT) ..."
	@python3 siob_iobyte_server.py /tmp/siob_test_payload.txt $(SIOB_PORT) \
		> /tmp/siob_test_server.log 2>&1 & echo $$! > /tmp/siob_test_server.pid
	@sleep 0.5
	-$(MAME_BIN) rc702 -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_siob2.imd \
		-bitb2 "socket.localhost:$(SIOB_PORT)" \
		-skip_gameinfo -window -resolution 1100x720 \
		-autoboot_script $(CURDIR)/mame_siob_test.lua
	@if [ -f /tmp/siob_test_server.pid ]; then \
		kill $$(cat /tmp/siob_test_server.pid) 2>/dev/null; \
		rm -f /tmp/siob_test_server.pid; \
	fi
	@echo ""
	@echo "--- SIO-B server log ---"
	@cat /tmp/siob_test_server.log 2>/dev/null || echo "(no log)"
	@echo ""
	@echo "--- Lua result ---"
	@cat /tmp/siob_test_result 2>/dev/null || (echo "(no result file)"; exit 1)
	@head -1 /tmp/siob_test_result | grep -q '^PASS' \
		&& echo "=== SIO-B direct test PASSED ===" \
		|| (echo "=== SIO-B direct test FAILED ==="; exit 1)

# ================================================================
# BIOS deploy via dual serial (SIO-B console + SIO-A data)
# Uploads Intel HEX, runs LOAD+SYSGEN, hard resets, verifies banner.
# ================================================================

DEPLOY_CON_PORT ?= 4324
DEPLOY_DAT_PORT ?= 4325

deploy-serial: bios
	@echo "=== BIOS deploy via serial ==="
	python3 mk_cpm56.py cpm56_original.com $(COMPILER)/bios.cim cpm56
	cp $(IMG_MAXI) /tmp/bios_deploy.imd
	$(PATCH) /tmp/bios_deploy.imd $(COMPILER)/bios.cim
	@rm -f /tmp/siob_deploy_trigger /tmp/siob_deploy_done /tmp/siob_deploy_result
	@echo "Starting deploy server..."
	@python3 -u siob_deploy_server.py cpm56.hex $(DEPLOY_CON_PORT) $(DEPLOY_DAT_PORT) \
		> /tmp/siob_deploy_server.log 2>&1 & echo $$! > /tmp/siob_deploy_server.pid
	@sleep 0.5
	-EXPECTED_BANNER="C-bios/clang" \
		$(MAME_BIN) rc702 -rompath $(MAME)/roms \
		-flop1 /tmp/bios_deploy.imd \
		-bitb1 "socket.localhost:$(DEPLOY_DAT_PORT)" \
		-bitb2 "socket.localhost:$(DEPLOY_CON_PORT)" \
		-skip_gameinfo -window -resolution 1100x720 -nothrottle \
		-autoboot_script $(CURDIR)/mame_siob_deploy_test.lua
	@if [ -f /tmp/siob_deploy_server.pid ]; then \
		kill $$(cat /tmp/siob_deploy_server.pid) 2>/dev/null; \
		rm -f /tmp/siob_deploy_server.pid; \
	fi
	@echo ""
	@echo "--- Deploy server log ---"
	@cat /tmp/siob_deploy_server.log 2>/dev/null || echo "(no log)"
	@echo ""
	@echo "--- Result ---"
	@cat /tmp/siob_deploy_result 2>/dev/null || (echo "(no result)"; exit 1)
	@head -1 /tmp/siob_deploy_result | grep -q '^PASS' \
		&& echo "=== DEPLOY TEST PASSED ===" \
		|| (echo "=== DEPLOY TEST FAILED ==="; exit 1)

# ================================================================
# SIO-B serial console integration test
# Sends DIR / ASM FILEX / TYPE FILEX.PRN via serial, verifies output
# appears on both CRT display and serial port.
# ================================================================

CONSOLE_PORT ?= 4324

siob-console-test: bios
	@echo "=== SIO-B serial console test ==="
	cp $(IMG_MAXI) /tmp/bios_c_console.imd
	$(PATCH) /tmp/bios_c_console.imd $(COMPILER)/bios.cim
	@rm -f /tmp/siob_console_done /tmp/siob_console_result /tmp/siob_console_serial.txt /tmp/siob_console_crt.txt /tmp/siob_console_trigger
	@echo "Starting console server on port $(CONSOLE_PORT) ..."
	@python3 -u siob_console_server.py $(CONSOLE_PORT) \
		> /tmp/siob_console_server.log 2>&1 & echo $$! > /tmp/siob_console_server.pid
	@sleep 0.5
	-$(MAME_BIN) rc702 -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_console.imd \
		-bitb2 "socket.localhost:$(CONSOLE_PORT)" \
		-skip_gameinfo -window -resolution 1100x720 -nothrottle \
		-autoboot_script $(CURDIR)/mame_siob_console_test.lua
	@if [ -f /tmp/siob_console_server.pid ]; then \
		kill $$(cat /tmp/siob_console_server.pid) 2>/dev/null; \
		rm -f /tmp/siob_console_server.pid; \
	fi
	@echo ""
	@echo "--- Server log ---"
	@cat /tmp/siob_console_server.log 2>/dev/null || echo "(no log)"
	@echo ""
	@echo "--- Result ---"
	@cat /tmp/siob_console_result 2>/dev/null || (echo "(no result)"; exit 1)
	@head -1 /tmp/siob_console_result | grep -q '^PASS' \
		&& echo "=== SERIAL CONSOLE TEST PASSED ===" \
		|| (echo "=== SERIAL CONSOLE TEST FAILED ==="; exit 1)

# ================================================================
# SIO-B baud rate experiment
# Usage: make siob-baud BAUD_IDX=0  (38400, baseline)
#        make siob-baud BAUD_IDX=1  (76800, x1 mode)
#        make siob-baud BAUD_IDX=2  (115200, x1 mode, 6.7% error)
# ================================================================

BAUD_IDX ?= 0
# Map BAUD_IDX to MAME RS232_BAUD value
BAUD_MAME_0 = 11
BAUD_MAME_1 = 23
BAUD_MAME_2 = 13
BAUD_MAME_3 = 13
BAUD_MAME = $(BAUD_MAME_$(BAUD_IDX))

siob-baud: bios
	@echo "=== SIO-B baud rate test (idx=$(BAUD_IDX)) ==="
	../zmac/bin/zmac -z siob_baud_test.asm
	cp $(IMG_MAXI) /tmp/bios_c_siob_baud.imd
	$(PATCH) /tmp/bios_c_siob_baud.imd $(COMPILER)/bios.cim
	$(CPMCP) -f rc702-8dd /tmp/bios_c_siob_baud.imd zout/siob_baud_test.cim 0:SIOBBAUD.COM
	@printf '$(SIOB_MARKER)\r\n' > /tmp/siob_test_payload.txt
	@rm -f /tmp/siob_iobyte_trigger /tmp/siob_baud_result
	@python3 siob_iobyte_server.py /tmp/siob_test_payload.txt $(SIOB_PORT) \
		> /tmp/siob_baud_server.log 2>&1 & echo $$! > /tmp/siob_baud_server.pid
	@sleep 0.5
	-SIOB_BAUD_IDX=$(BAUD_IDX) SIOB_BAUD_MAME=$(BAUD_MAME) \
		$(MAME_BIN) rc702 -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_siob_baud.imd \
		-bitb2 "socket.localhost:$(SIOB_PORT)" \
		-skip_gameinfo -window -resolution 1100x720 \
		-autoboot_script $(CURDIR)/mame_siob_baud_test.lua
	@if [ -f /tmp/siob_baud_server.pid ]; then \
		kill $$(cat /tmp/siob_baud_server.pid) 2>/dev/null; \
		rm -f /tmp/siob_baud_server.pid; \
	fi
	@echo ""
	@echo "--- result ---"
	@cat /tmp/siob_baud_result 2>/dev/null || echo "(no result)"
	@head -1 /tmp/siob_baud_result | grep -q '^PASS' \
		&& echo "=== BAUD TEST PASSED ===" \
		|| (echo "=== BAUD TEST FAILED ==="; exit 1)

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
