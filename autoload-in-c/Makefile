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

test_boot: test_boot.c $(HOST_COMMON) hal.h boot.h
	$(CC) $(CFLAGS) -o $@ test_boot.c $(HOST_COMMON)

test_fdc: test_fdc.c $(HOST_COMMON) hal.h boot.h
	$(CC) $(CFLAGS) -o $@ test_fdc.c $(HOST_COMMON)

# Z80 ROM build (requires z88dk in ../z88dk)
Z88DK = ../z88dk
ZCC = $(Z88DK)/bin/zcc
ZCCCFG = $(Z88DK)/lib/config

# sdcc compiler with sdcccall(1) register calling convention
# C files: boot.c, fdc.c, fmt.c, isr.c (compiled by sdcc)
# Assembly: crt0.asm (hand-written startup + utilities)
ZFLAGS = +z80 -clib=sdcc_iy --no-crt --opt-code-size -SO3 \
         -Cs"--max-allocs-per-node 1000000" \
         -Cs"--fomit-frame-pointer" \
         -Cs"--allow-unsafe-read" \
         -Cs"--sdcccall 1" \
         -pragma-define:CRT_ORG_CODE=0x0000 \
         -pragma-define:CRT_ORG_BSS=0x8000 \
         -m --list -create-app

rom: crt0.asm rom_all.c boot.c fdc.c fmt.c isr.c
	export PATH="$(Z88DK)/bin:$$PATH" && \
	export ZCCCFG="$(ZCCCFG)" && \
	$(ZCC) $(ZFLAGS) -o roa375 crt0.asm rom_all.c
	@ls -la roa375_CODE.bin 2>/dev/null; ls -la roa375_BOOT.bin 2>/dev/null
	@CODE=$$(wc -c < roa375_CODE.bin); \
	 BOOT=$$(wc -c < roa375_BOOT.bin); \
	 TOTAL=$$((CODE + BOOT)); \
	 echo "BOOT: $$BOOT bytes, CODE: $$CODE bytes, Total: $$TOTAL bytes"; \
	 if [ $$TOTAL -gt 2048 ]; then \
	   echo "WARNING: Total $$TOTAL exceeds 2048-byte PROM limit by $$((TOTAL - 2048)) bytes"; \
	 else \
	   echo "OK: $$((2048 - TOTAL)) bytes under 2048-byte limit"; \
	 fi

clean:
	rm -f test_boot test_fdc roa375 roa375_*.bin
	rm -f *.o *.bin *.map *.sym *.lis *.def *.rom
	rm -f zcc_opt.def

.PHONY: test rom clean
