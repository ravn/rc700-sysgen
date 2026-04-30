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

# Link addresses.  cpnos.com's CODE section is 0xC0D B but the .COM
# file on disk is record-padded to 0xC80 B (with 0x1A trailing fill);
# netboot_mpm.c loads the full 0xC80 B (records can't be partial).
# So CODE_BASE + 0xC80 must sit below cpnos-rom's scratch BSS at
# 0xEA20 to avoid corrupting the slave's running cfgtbl/_msg/kbd_ring
# during the READ-SEQ loop.
#
# Phase A (2026-04-30):
#   CODE 0xDD80..0xE9FF   NDOS DD83, end butts against scratch BSS
#                         at 0xEA20 with 0x20 B headroom
#   DATA 0xD980..0xDD7F   NDOSRL D980, BDOSDS DB6A
# TPA = 0x0100..0xD97F = 0xD880 = 55424 B (54.125 KB strict; reported
# via NDOSE = NDOS+0x122 = 0xDEA2 -> 55K).
# Was: CODE LD000 / DATA DCC00 (TPA ~51 KB).  A more aggressive base
# (CODE LE080 / DATA DDC80, +1 KB TPA) overlapped scratch BSS during
# the READ-SEQ loop -- relocating scratch BSS is Phase B work.
CODE_BASE ?= LDD80
DATA_BASE ?= DD980

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
