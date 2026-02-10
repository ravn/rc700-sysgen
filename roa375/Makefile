# ROA375 ROM Disassembly Build
# RC702 Boot ROM (Z80)

ZMAC = ../zmac/bin/zmac
ZMAC_FLAGS = -z --dri -f

.PHONY: all verify clean

# Default target: build the main disassembly
all: clean zout/roa375.cim verify

# Build from disassembly source
zout/roa375.cim: roa375.asm
	$(ZMAC) $(ZMAC_FLAGS) roa375.asm

# Verify binary match with original ROM
verify: zout/roa375.cim
	@echo "Comparing assembled output with original ROM..."
	cmp -x zout/roa375.cim roa375.rom | perl -pe 's/^([0-9a-f]+)/sprintf("%04x", hex($$1)+0x6f97)/e' | head -n 8

# Clean build outputs
clean:
	rm -rf zout

# Build reference file (raw z80dasm output) - for testing only
test-raw: roa375_raw.asm
	$(ZMAC) $(ZMAC_FLAGS) roa375_raw.asm

#duplicate-symbols:  zout/roa375.lst
#	perl -ne '/Symbol Table:/..eof&&/(\S+)\s+([0-9A-Fa-f]+)/&&push@{$$h{uc$$2}},$$1;END{print"@h";print"$$_:@{$$h{$$_}}\n"for grep{@{$$h{$$_}}>0}sort keys%$$h}' zout/roa375.lst
