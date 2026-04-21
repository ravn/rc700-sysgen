# Build CP/NOS for RC702 via the DRI-to-GNU-as pipeline.
#
# Portable modules (cpnos, cpndos, cpbdos) come from
# cpnet-z80/dist/src/ via:
#   <m>.asm (CRLF) -> XIZ -> <m>.z80 -> dri2gnu.pl -> s/<m>.s -> s/<m>.o
#
# Hand-written RC702 replacements (cpbios, cpnios) live in src/
# and assemble directly to s/<m>.o.
#
# Final link produces d/cpnos.com — flat binary placed at
# 0xD000 code / 0xCC00 data.  Stream that via netboot.

VCPM  := java -jar /Users/ravn/z80/cpnet-z80/tools/VirtualCpm.jar
SRC   := /Users/ravn/z80/cpnet-z80/dist/src
CLANG := $(firstword $(wildcard /Users/ravn/z80/llvm-z80/build-*/bin/clang))
LD    := $(firstword $(wildcard /Users/ravn/z80/llvm-z80/build-*/bin/ld.lld))
OC    := $(firstword $(wildcard /Users/ravn/z80/llvm-z80/build-*/bin/llvm-objcopy))

export CPMDrive_D := $(CURDIR)/d
export CPMDrive_A := $(CURDIR)/a
export CPMDefault := d:

PORTABLE := cpnos cpndos cpbdos
HAND     := cpbios cpnios
OBJS     := $(addsuffix .o,$(addprefix s/,$(PORTABLE) $(HAND)))

.PHONY: all clean
all: d/cpnos.com

# Keep intermediates so rebuilds are inspectable and survive make's
# default cleanup of pattern-rule intermediates.
.SECONDARY:

# LF -> CRLF for RMAC/XIZ.
d/%.asm: $(SRC)/%.asm
	@mkdir -p d
	perl -pe 's/\r?\n/\r\n/g' $< > $@

# XIZ: 8080 -> Zilog Z80 mnemonics.  vcpm can hang — kill after 3 s.
d/%.z80: d/%.asm
	( $(VCPM) xiz $* 2>&1 & PID=$$!; sleep 3; kill -9 $$PID 2>/dev/null; wait 2>/dev/null; true )
	@test -s $@

# dri2gnu.pl: DRI syntax -> GNU-as.
s/%.s: d/%.z80 dri2gnu.pl
	@mkdir -p s
	perl dri2gnu.pl < $< > $@

# Hand-written RC702 modules — copy from src/ to s/ so they live
# alongside the translated ones for compilation.
s/cpbios.s: src/cpbios.s
	@mkdir -p s
	cp $< $@
s/cpnios.s: src/cpnios.s
	@mkdir -p s
	cp $< $@

# Assemble.
s/%.o: s/%.s
	$(CLANG) --target=z80 -c $< -o $@

# Link.
d/cpnos.com: $(OBJS) cpnos.ld
	$(LD) -T cpnos.ld $(OBJS) -o d/cpnos.elf
	$(OC) -O binary -j .cpnos_code -j .cpnos_data d/cpnos.elf $@

clean:
	rm -f d/*.rel d/*.prn d/*.sym d/*.com d/*.z80 d/*.elf s/*.s s/*.o
