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
ZFLAGS = +z80 -clib=sdcc_iy --no-crt --opt-code-size -SO3 \
         -Cs"--max-allocs-per-node 1000000" \
         -Cs"--fomit-frame-pointer" \
         -Cs"--allow-unsafe-read" \
         -Cs"--sdcccall 1" \
         -custom-copt-rules=peephole.def \
         -pragma-define:CRT_ORG_CODE=0xD480 \
         -m --list -create-app

# Disk image tools
PATCH = python3 ../rcbios/patch_bios.py
IMDINFO = python3 ../rcbios/imdinfo.py

# MAME
MAME = /Users/ravn/git/mame
MAME_BIN = $(MAME)/regnecentralen

# Disk images for testing
IMG_MINI = $(HOME)/Downloads/CPM_med_COMAL80.imd
IMG_MAXI = $(HOME)/Downloads/SW1711-I8.imd

# Size limits (bytes)
MINI_LIMIT = 6144
MAXI_LIMIT = 9984

.PHONY: all bios size clean mame-mini mame-maxi test

all: bios size

# Z80 build
bios: crt0.asm bios.c hal.h bios.h danish.bin peephole.def
	export PATH="$(Z88DK)/bin:$$PATH" && \
	export ZCCCFG="$(ZCCCFG)" && \
	$(ZCC) $(ZFLAGS) -o bios crt0.asm bios.c
	@cp bios.rom bios.cim
	@echo "bios.cim: $$(wc -c < bios.cim | tr -d ' ') bytes"

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
mame-mini: bios
	cp $(IMG_MINI) /tmp/bios_c_mini.imd
	$(PATCH) /tmp/bios_c_mini.imd bios.cim
	$(MAME_BIN) rc702mini -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_mini.imd \
		-skip_gameinfo -window -resolution 1100x720

# MAME boot test (maxi)
mame-maxi: bios
	cp $(IMG_MAXI) /tmp/bios_c_maxi.imd
	$(PATCH) /tmp/bios_c_maxi.imd bios.cim
	$(MAME_BIN) rc702 -rompath $(MAME)/roms \
		-flop1 /tmp/bios_c_maxi.imd \
		-skip_gameinfo -window -resolution 1100x720

# Host tests (TODO)
test:
	@echo "Host tests not yet implemented"

clean:
	rm -f bios bios.cim bios_CODE.bin bios.map bios.lis
	rm -f *.o *.sym bios.def zcc_opt.def *.c.lis
	rm -f /tmp/bios_c_mini.imd /tmp/bios_c_maxi.imd
