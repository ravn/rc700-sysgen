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

MODULES := cpndos cpnios cpbdos

.PHONY: all clean
all: d/cpnos.com

# Named-shim override: src/cpnios-shim.asm is our thin JP-to-0xEA00
# trampoline into cpnos-rom's resident SNIOS.  RMAC+LINK still needs
# the monolith module name to be cpnios (NDOS calls `call NIOS+N*3`
# where NIOS is the label in that module), so the source file carries
# the -shim suffix but the built .asm lands in d/ as cpnios.asm.
d/cpnios.asm: $(LOCAL_SRC)/cpnios-shim.asm
	@mkdir -p d
	perl -pe 's/\r?\n/\r\n/g' $< > $@

# Local asm (our overrides) wins over upstream for any other module.
d/%.asm: $(LOCAL_SRC)/%.asm
	@mkdir -p d
	perl -pe 's/\r?\n/\r\n/g' $< > $@

d/%.asm: $(SRC)/%.asm
	@mkdir -p d
	perl -pe 's/\r?\n/\r\n/g' $< > $@

d/%.rel: d/%.asm
	cd $(CURDIR) && $(VCPM) rmac $* 2>&1 | tail -3

# Phase 2B (2026-04-26): cpnos.asm entry stub deleted.  cpnos.com now
# starts directly at NDOS+0 (cpndos's first byte = JP NDOSE).  PROM C
# (cpnos-rom/cpnos_main.c::nos_handoff) sets ZP[5..7] = JP BDOS using
# an address extracted from cpnos.sym at PROM build time, then enters
# at 0xD003 (NDOS+3 = COLDST).
#
# `cpnos=cpndos,...` is DRI LINK's explicit destination-filename
# syntax — output goes to cpnos.com regardless of which module is
# first in the input list.
d/cpnos.com: $(addsuffix .rel,$(addprefix d/,$(MODULES)))
	cd $(CURDIR) && $(VCPM) link 'cpnos=cpndos,cpnios,cpbdos[$(CODE_BASE),$(DATA_BASE)]' 2>&1 | tail -15

clean:
	rm -f d/*.rel d/*.prn d/*.sym d/*.com d/tiny*.* d/test.*
