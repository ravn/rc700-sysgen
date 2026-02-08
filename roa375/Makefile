# ROA375 ROM Disassembly Build
# RC702 Boot ROM (Z80)

ZMAC = ../zmac/bin/zmac
ZMAC_FLAGS = -z --dri

.PHONY: all clean

# Default target: build the main disassembly
all: zout/roa375.cim

# Build from disassembly source
zout/roa375.cim: roa375.asm
	$(ZMAC) $(ZMAC_FLAGS) roa375.asm

# Verify binary match with original ROM
verify: zout/roa375.cim
	@echo "Comparing assembled output with original ROM..."
	cmp -l zout/roa375.cim roa375.rom && echo "✓ Binary identical!" || echo "✗ Differences found"

# Clean build outputs
clean:
	rm -rf zout

# Build reference file (raw z80dasm output) - for testing only
test-raw: roa375_raw.asm
	$(ZMAC) $(ZMAC_FLAGS) roa375_raw.asm
