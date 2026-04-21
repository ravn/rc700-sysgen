# Sub-pipeline: DRI .asm -> GNU-as .s via XIZ + dri2gnu.pl
# Run: make -f dri2gnu.mk

VCPM := java -jar /Users/ravn/z80/cpnet-z80/tools/VirtualCpm.jar
SRC  := /Users/ravn/z80/cpnet-z80/dist/src
CC   := $(firstword $(wildcard /Users/ravn/z80/llvm-z80/build-*/bin/clang))

export CPMDrive_D := $(CURDIR)/d
export CPMDrive_A := $(CURDIR)/a
export CPMDefault := d:

# Only the hardware-independent modules — cpnios/cpbios are replaced
# with RC702-native GNU-as sources (hand-written, not translated).
PORTABLE := cpnos cpndos cpbdos

.PHONY: all clean
all: $(addprefix s/,$(addsuffix .o,$(PORTABLE)))

# CRLF source for RMAC/XIZ.
d/%.asm: $(SRC)/%.asm
	@mkdir -p d
	perl -pe 's/\r?\n/\r\n/g' $< > $@

# XIZ: 8080 mnemonics -> Zilog Z80.  Runs under vcpm so the
# per-file timeout pattern below kills a potentially hung vcpm
# (workaround for an intermittent hang we observed).
d/%.z80: d/%.asm
	( $(VCPM) xiz $* 2>&1 & PID=$$!; sleep 3; kill -9 $$PID 2>/dev/null; wait 2>/dev/null; true )
	@test -s $@

# dri2gnu.pl: DRI directives + expressions -> GNU-as.
s/%.s: d/%.z80 dri2gnu.pl
	@mkdir -p s
	perl dri2gnu.pl < $< > $@

s/%.o: s/%.s
	$(CC) --target=z80 -c $< -o $@

clean:
	rm -f d/*.rel d/*.prn d/*.sym d/*.com d/*.z80 s/*.s s/*.o
