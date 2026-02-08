# Build SYSGEN.COM from 8080/DRI assembly source and verify
# byte-exact match against the original RC702 binary (RCSYSGEN.COM).
#
# Usage:
#   make          - assemble and verify
#   make clean    - remove build artifacts
#   make verify   - assemble (if needed) and compare against reference

ZMAC = ../zmac/bin/zmac
ZMACFLAGS = -8 --dri
REFERENCE = RCSYSGEN.COM
OUTPUT = zout/SYSGEN.cim

.PHONY: all clean verify

all: verify

$(OUTPUT): SYSGEN.ASM
	$(ZMAC) $(ZMACFLAGS) $<

verify: $(OUTPUT)
	grep -q 'SIGNON.*4EF' zout/SYSGEN.lst
	cmp $(REFERENCE) $(OUTPUT)

clean:
	rm -rf zout
