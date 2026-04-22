# Build CP/NOS from cpnet-z80 sources via VirtualCpm (DRI RMAC+LINK).
# Produces d/cpnos.com (4KB monolithic image).
#
# Prereqs:
#   - java on PATH
#   - /Users/ravn/z80/cpnet-z80 cloned (source + VirtualCpm.jar + vcpm tools)
#   - RMAC needs CRLF line endings (handled by the asm -> asm rule).

VCPM := java -jar /Users/ravn/z80/cpnet-z80/tools/VirtualCpm.jar
SRC  := /Users/ravn/z80/cpnet-z80/dist/src
# Local overrides for DRI sources we've replaced (RC702-specific vs
# Altos).  If src/<name>.asm exists it wins over $(SRC)/<name>.asm.
LOCAL_SRC := src

# Link addresses.  Must sit below our BIOS resident at 0xF200 and
# display RAM at 0xF800.  Current choice:
#   CODE 0xD000..0xDFF8   NDOS D003, NIOS D993, BDOS DCAA, BIOS DF21
#   DATA 0xCC00..0xCEE4   NDOSRL CC00, BDOSDS CEA8
# Leaves TPA 0x0100..0xCBFF (~51 KB) and everything above 0xDFF8 free
# for the RC702-native BIOS + IVT + BSS + display.
CODE_BASE ?= LD000
DATA_BASE ?= DCC00

export CPMDrive_D := $(CURDIR)/d
export CPMDrive_A := $(CURDIR)/a
export CPMDefault := d:

MODULES := cpnos cpndos cpnios cpbdos cpbios

.PHONY: all clean
all: d/cpnos.com

# Local asm (our overrides) wins; fall back to cpnet-z80 upstream.
d/%.asm: $(LOCAL_SRC)/%.asm
	@mkdir -p d
	perl -pe 's/\r?\n/\r\n/g' $< > $@

d/%.asm: $(SRC)/%.asm
	@mkdir -p d
	perl -pe 's/\r?\n/\r\n/g' $< > $@

d/%.rel: d/%.asm
	cd $(CURDIR) && $(VCPM) rmac $* 2>&1 | tail -3

d/cpnos.com: $(addsuffix .rel,$(addprefix d/,$(MODULES)))
	cd $(CURDIR) && $(VCPM) link 'cpnos,cpndos,cpnios,cpbdos,cpbios[$(CODE_BASE),$(DATA_BASE)]' 2>&1 | tail -15

clean:
	rm -f d/*.rel d/*.prn d/*.sym d/*.com d/tiny*.* d/test.*
