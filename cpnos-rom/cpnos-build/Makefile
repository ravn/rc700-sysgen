# Build CP/NOS from cpnet-z80 sources via VirtualCpm (DRI RMAC+LINK).
# Produces d/cpnos.com (4KB monolithic image linked at 0xF000/0xEC00).
#
# Prereqs:
#   - java on PATH
#   - /Users/ravn/z80/cpnet-z80 cloned (source + VirtualCpm.jar + vcpm tools)
#   - RMAC needs CRLF line endings (handled by the asm.crlf rule).

VCPM := java -jar /Users/ravn/z80/cpnet-z80/tools/VirtualCpm.jar
SRC  := /Users/ravn/z80/cpnet-z80/dist/src

export CPMDrive_D := $(CURDIR)/d
export CPMDrive_A := $(CURDIR)/a
export CPMDefault := d:

MODULES := cpnos cpndos cpnios cpbdos cpbios

.PHONY: all clean
all: d/cpnos.com

d/%.asm: $(SRC)/%.asm
	@mkdir -p d
	perl -pe 's/\r?\n/\r\n/g' $< > $@

d/%.rel: d/%.asm
	cd $(CURDIR) && $(VCPM) rmac $* 2>&1 | tail -3

d/cpnos.com: $(addsuffix .rel,$(addprefix d/,$(MODULES)))
	cd $(CURDIR) && $(VCPM) link 'cpnos,cpndos,cpnios,cpbdos,cpbios[LF000,DEC00]' 2>&1 | tail -15

clean:
	rm -f d/*.rel d/*.prn d/*.sym d/*.com d/tiny*.* d/test.*
