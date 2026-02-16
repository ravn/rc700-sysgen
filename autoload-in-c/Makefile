# Makefile for RC702 autoload PROM rewrite
#
# Host tests:  make test
# Z80 build:   make rom    (requires z88dk)
# Clean:       make clean

CC = cc
CFLAGS = -Wall -Wextra -std=c99

# Host test builds (uses mock HAL)
HOST_COMMON = boot.c fdc.c fmt.c init.c isr.c hal_host.c

test: test_boot test_fdc
	./test_boot
	./test_fdc

test_boot: test_boot.c $(HOST_COMMON) hal.h
	$(CC) $(CFLAGS) -o $@ test_boot.c $(HOST_COMMON)

test_fdc: test_fdc.c $(HOST_COMMON) hal.h
	$(CC) $(CFLAGS) -o $@ test_fdc.c $(HOST_COMMON)

# Z80 ROM build (requires z88dk installed)
# TODO: configure z88dk crt0 and linker settings
rom:
	@echo "Z80 ROM build not yet implemented — needs z88dk setup"

clean:
	rm -f test_boot test_fdc *.o *.bin

.PHONY: test rom clean
