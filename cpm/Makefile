# Build CCP + BDOS from DRI CP/M 2.2 sources
#
# Produces byte-exact CCP.cim + BDOS.cim stamped with a chosen serial.
# Default is "2-261-0000" (Regnecentralen vendor, serial 0 — "master",
# which every RC master disk in the survey has).
#
# Override the serial at invocation:
#     make SERIAL=2-261-2972        # stamp as customer serial 2972
#     make SERIAL=4252              # shorthand, uses default vendor
#     make SERIAL="d5 16 08 00 0b 9c"   # raw hex
#
# Outputs end up in zout/:
#     zout/OS2CCP.cim     assembled CCP (2048 B, pristine)
#     zout/OS3BDOS.cim    assembled BDOS (3584 B, pristine)
#     stamped/CCP.cim     stamped with SERIAL
#     stamped/BDOS.cim    stamped with SERIAL
#     stamped/CCPBDOS.cim CCP+BDOS concatenated, ready for SYSGEN injection
#
# Verify against a real RC702 disk (must run imdinfo to confirm the
# reference CCP+BDOS matches):
#     make SERIAL=2-261-2972 verify REF=~/Downloads/SW1711-I5_CPM2.2_r2.1.imd

ZMAC      := ../zmac/bin/zmac
ZMAC_FLAGS := -8 --dri
SERIAL    ?= 2-261-0000
STAMPED   := stamped

.PHONY: all stamp clean verify help

all: stamp

zout/OS2CCP.cim: OS2CCP.ASM
	$(ZMAC) $(ZMAC_FLAGS) OS2CCP.ASM

zout/OS3BDOS.cim: OS3BDOS.ASM
	$(ZMAC) $(ZMAC_FLAGS) OS3BDOS.ASM

stamp: $(STAMPED)/CCP.cim $(STAMPED)/BDOS.cim $(STAMPED)/CCPBDOS.cim $(STAMPED)/serial.hex

# Tiny Intel HEX overlay with just the two 6-byte serial stamps.
# Composes with the base CCP+BDOS HEX via MLOAD:
#     MLOAD CPM56=OS2CCP.HEX,OS3BDOS.HEX,serial.hex
# Regenerate after each SERIAL change.
$(STAMPED)/serial.hex: stamp_serial.py Makefile
	@mkdir -p $(STAMPED)
	python3 stamp_serial.py --serial "$(SERIAL)" --hex-out $(STAMPED)/serial.hex
	@cat $(STAMPED)/serial.hex

$(STAMPED)/CCP.cim: zout/OS2CCP.cim stamp_serial.py
	@mkdir -p $(STAMPED)
	cp zout/OS2CCP.cim $(STAMPED)/CCP.cim
	python3 stamp_serial.py --serial "$(SERIAL)" --ccp $(STAMPED)/CCP.cim

$(STAMPED)/BDOS.cim: zout/OS3BDOS.cim stamp_serial.py
	@mkdir -p $(STAMPED)
	cp zout/OS3BDOS.cim $(STAMPED)/BDOS.cim
	python3 stamp_serial.py --serial "$(SERIAL)" --bdos $(STAMPED)/BDOS.cim

# CCP+BDOS memory layout: CCP at 0xC400 (2048 B), BDOS at 0xCC00 (3584 B).
# zmac emits just the non-zero tail for each, so we pad to full section size.
$(STAMPED)/CCPBDOS.cim: $(STAMPED)/CCP.cim $(STAMPED)/BDOS.cim
	python3 -c "\
import sys; \
from pathlib import Path; \
ccp = Path('$(STAMPED)/CCP.cim').read_bytes(); \
bdos = Path('$(STAMPED)/BDOS.cim').read_bytes(); \
ccp_padded = ccp + b'\\x00' * (0x800 - len(ccp)); \
bdos_padded = bdos + b'\\x00' * (0xE00 - len(bdos)); \
assert len(ccp_padded) == 0x800, f'CCP padded = {len(ccp_padded)}'; \
assert len(bdos_padded) == 0xE00, f'BDOS padded = {len(bdos_padded)}'; \
Path('$(STAMPED)/CCPBDOS.cim').write_bytes(ccp_padded + bdos_padded); \
print(f'  Combined CCP+BDOS: {len(ccp_padded)+len(bdos_padded)} B (CCP {len(ccp_padded)}, BDOS {len(bdos_padded)})')"
	@ls -l $(STAMPED)/CCPBDOS.cim

verify: $(STAMPED)/CCPBDOS.cim
	@if [ -z "$(REF)" ]; then \
		echo "usage: make verify REF=<path to .imd>"; exit 1; \
	fi
	python3 verify_against_imd.py $(STAMPED)/CCPBDOS.cim $(REF)

clean:
	rm -rf zout $(STAMPED)

help:
	@echo "Targets:"
	@echo "  all (default) — build stamped CCP + BDOS + concatenated image"
	@echo "  clean         — remove zout/ and $(STAMPED)/"
	@echo "  verify REF=X  — compare stamped output against an IMD's track 1"
	@echo ""
	@echo "Variables:"
	@echo "  SERIAL  - serial to stamp (default: $(SERIAL))"
	@echo "            forms: '2-261-XXXX', 'XXXX', '2261-XXXX', or raw hex"
	@echo ""
	@echo "Example: make SERIAL=2-261-2972"
