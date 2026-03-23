# Makefile for building RC700 autoload PROM with LLVM-Z80
#
# Prerequisites: Docker with the llvm-z80 build at ~/git/llvm-z80/build/
#
# Usage:
#   make              — build prom.bin (full PROM image)
#   make asm          — show rom.c assembly output
#   make disasm       — disassemble linked ELF
#   make symbols      — show symbol table
#   make clean        — remove build artifacts

BUILD_DIR := /src/build/bin

CC      := $(BUILD_DIR)/clang
LD      := $(BUILD_DIR)/ld.lld
OBJCOPY := $(BUILD_DIR)/llvm-objcopy
OBJDUMP := $(BUILD_DIR)/llvm-objdump
NM      := $(BUILD_DIR)/llvm-nm

TARGET  := --target=z80
CFLAGS  := $(TARGET) -Os -ffreestanding -nostdlib -I. -I.. -Wno-gcc-compat
ASFLAGS := $(TARGET) -c

# Docker wrapper
DOCKER := docker run --rm \
    -v $(HOME)/git/llvm-z80:/src \
    -v $(CURDIR)/..:/rom \
    -w /rom/clang_z80 \
    ubuntu:24.04

OBJS := boot.o intvec.o rom.o runtime.o
ELF  := prom.elf
BIN  := prom.bin

.PHONY: all asm disasm symbols clean

all: $(BIN)

boot.o: boot.s
	$(DOCKER) $(CC) $(ASFLAGS) $< -o $@

intvec.o: ../intvec.c ../rom.h
	$(DOCKER) $(CC) $(CFLAGS) -c ../intvec.c -o $@

rom.o: ../rom.c ../rom.h
	$(DOCKER) $(CC) $(CFLAGS) -c ../rom.c -o $@

runtime.o: runtime.s
	$(DOCKER) $(CC) $(ASFLAGS) $< -o $@

$(ELF): $(OBJS) rc700_prom.ld
	$(DOCKER) $(LD) -T rc700_prom.ld $(OBJS) -o $@

$(BIN): $(ELF)
	$(DOCKER) $(OBJCOPY) -O binary $< $@
	@echo "=== PROM size: $$(wc -c < $@) / 4096 bytes ==="

asm: ../rom.c ../rom.h
	$(DOCKER) $(CC) $(CFLAGS) -S ../rom.c -o /dev/stdout

disasm: $(ELF)
	$(DOCKER) $(OBJDUMP) -d --triple=z80 $<

symbols: $(ELF)
	$(DOCKER) $(NM) --numeric-sort $<

clean:
	rm -f $(OBJS) $(ELF) $(BIN)
