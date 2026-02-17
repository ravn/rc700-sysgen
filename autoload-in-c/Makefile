# Makefile for RC702 autoload PROM rewrite
#
# Host tests:  make test
# Z80 build:   make rom    (requires z88dk)
# Clean:       make clean

CC = cc
CFLAGS = -Wall -Wextra -std=c99 -DHOST_TEST

# Host test builds (uses mock HAL)
HOST_COMMON = boot.c fdc.c fmt.c init.c isr.c hal_host.c

test: test_boot test_fdc
	./test_boot
	./test_fdc

test_boot: test_boot.c $(HOST_COMMON) hal.h
	$(CC) $(CFLAGS) -o $@ test_boot.c $(HOST_COMMON)

test_fdc: test_fdc.c $(HOST_COMMON) hal.h
	$(CC) $(CFLAGS) -o $@ test_fdc.c $(HOST_COMMON)

# Z80 ROM build (requires z88dk in ../z88dk)
Z88DK = ../z88dk
ZCC = $(Z88DK)/bin/zcc
ZCCCFG = $(Z88DK)/lib/config

Z80_SRC = hal_z80.c init.c fdc.c fmt.c boot.c isr.c
ZFLAGS = +z80 -clib=sdcc_iy --no-crt \
         -pragma-define:CRT_ORG_CODE=0x0000 \
         -pragma-define:CRT_ORG_BSS=0x8000 \
         -m -create-app

rom: $(Z80_SRC) crt0.asm hal.h
	export PATH="$(Z88DK)/bin:$$PATH" && export ZCCCFG="$(ZCCCFG)" && $(ZCC) $(ZFLAGS) -o roa375 crt0.asm $(Z80_SRC)
	@ls -l roa375.bin 2>/dev/null && echo "ROM size:" && wc -c < roa375.bin || true

clean:
	rm -f test_boot test_fdc roa375 roa375_*.bin
	rm -f *.o *.bin *.map *.sym *.lis *.def *.rom
	rm -f zcc_opt.def

.PHONY: test rom clean
