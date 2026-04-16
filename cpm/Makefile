# Build CCP + BDOS from DRI CP/M 2.2 sources
#
# Two independent outputs:
#
#   stamped/CCPBDOS.cim   Raw CCP + BDOS concatenated and padded to their
#                         memory section sizes (2048 + 3584 = 5632 B).
#                         Serial stamps at 0xC728 and 0xCC00 are zeros —
#                         "master" convention.  CP/M boots and runs
#                         because CCP's serialize check compares CCP's
#                         stamp against BDOS's and both are zero → pass.
#
#   stamped/serial.hex    Tiny Intel HEX overlay with just the two
#                         6-byte stamps (at 0xC728 and 0xCC00), generated
#                         from the SERIAL variable.  Apply with MLOAD on
#                         top of the raw CCP+BDOS (in HEX form) to stamp
#                         a customer-specific serial for SYSGEN injection.
#
# Default SERIAL is "2-261-0000", which produces a no-op overlay
# (already matches the zero stamps in the raw build).  Override to
# stamp a real serial:
#
#     make SERIAL=2-261-2972    # stamp as Regnecentralen serial 2972
#     make SERIAL=4252          # shorthand, default vendor
#     make SERIAL="d5 16 08 00 0b 9c"    # raw hex
#
# Verify the raw build against a real RC702 disk (expects the disk
# to be a master with serial 0):
#
#     make verify REF=~/Downloads/SW1711-I8.imd

ZMAC       := ../zmac/bin/zmac
ZMAC_FLAGS := -8 --dri
SERIAL     ?= 2-261-0000
OUT        := stamped

.PHONY: all raw serial-hex stamped clean verify verify-stamped help

all: $(OUT)/CCPBDOS.cim $(OUT)/serial.hex $(OUT)/CCPBDOS_stamped.cim

zout/OS2CCP.cim: OS2CCP.ASM
	$(ZMAC) $(ZMAC_FLAGS) OS2CCP.ASM

zout/OS3BDOS.cim: OS3BDOS.ASM
	$(ZMAC) $(ZMAC_FLAGS) OS3BDOS.ASM

# Raw CCP + BDOS concatenated and padded to section sizes.
# CCP occupies 0xC400-0xCBFF (2048 B); BDOS occupies 0xCC00-0xD9FF (3584 B).
# zmac emits only the used byte range, so we pad with zeros to the full size.
$(OUT)/CCPBDOS.cim: zout/OS2CCP.cim zout/OS3BDOS.cim
	@mkdir -p $(OUT)
	python3 -c "\
from pathlib import Path; \
ccp = Path('zout/OS2CCP.cim').read_bytes(); \
bdos = Path('zout/OS3BDOS.cim').read_bytes(); \
ccp_padded = ccp + b'\\x00' * (0x800 - len(ccp)); \
bdos_padded = bdos + b'\\x00' * (0xE00 - len(bdos)); \
assert len(ccp_padded) == 0x800, f'CCP padded = {len(ccp_padded)}'; \
assert len(bdos_padded) == 0xE00, f'BDOS padded = {len(bdos_padded)}'; \
Path('$(OUT)/CCPBDOS.cim').write_bytes(ccp_padded + bdos_padded); \
print(f'  CCPBDOS.cim: {len(ccp_padded)+len(bdos_padded)} B (CCP {len(ccp_padded)} + BDOS {len(bdos_padded)})')"

# Tiny Intel HEX overlay — just the two 6-byte stamp records.
# Always rebuilt (SERIAL= change wouldn't otherwise trigger a rebuild).
.PHONY: $(OUT)/serial.hex
$(OUT)/serial.hex: stamp_serial.py Makefile
	@mkdir -p $(OUT)
	python3 stamp_serial.py --serial "$(SERIAL)" --hex-out $(OUT)/serial.hex

# Compose the raw CCP+BDOS with the serial.hex overlay to produce the
# final stamped image — what MLOAD would emit.  This IS the byte-
# identical reproduction of a real RC702 system disk's track 1 once
# SERIAL= matches that disk's printed label.
$(OUT)/CCPBDOS_stamped.cim: $(OUT)/CCPBDOS.cim $(OUT)/serial.hex apply_hex.py
	python3 apply_hex.py --base 0xC400 $(OUT)/CCPBDOS.cim $(OUT)/serial.hex -o $(OUT)/CCPBDOS_stamped.cim

# Verify the RAW output (zero stamps) against a reference disk.
# Only matches for "truly blank" disks (COMAL_v1.07 etc.).  For real
# RC disks use `verify-stamped`.
verify: $(OUT)/CCPBDOS.cim
	@if [ -z "$(REF)" ]; then \
		echo "usage: make verify REF=<path to .imd>"; exit 1; \
	fi
	python3 verify_against_imd.py $(OUT)/CCPBDOS.cim $(REF)

# Verify the STAMPED output (raw + serial.hex) against a reference disk.
# For SERIAL= matching the reference's label, this should be BYTE-EXACT.
verify-stamped: $(OUT)/CCPBDOS_stamped.cim
	@if [ -z "$(REF)" ]; then \
		echo "usage: make verify-stamped REF=<path to .imd> [SERIAL=...]"; \
		exit 1; \
	fi
	python3 verify_against_imd.py $(OUT)/CCPBDOS_stamped.cim $(REF)

clean:
	rm -rf zout $(OUT)

help:
	@echo "Targets:"
	@echo "  all (default) — build raw CCPBDOS.cim (zero serial) + serial.hex"
	@echo "  verify REF=X  — compare raw CCPBDOS.cim against an IMD's track 1"
	@echo "  clean         — remove zout/ and $(OUT)/"
	@echo ""
	@echo "Variables:"
	@echo "  SERIAL  - serial for the HEX overlay (default: $(SERIAL))"
	@echo "            forms: '2-261-XXXX', 'XXXX', '2261-XXXX', raw hex"
	@echo ""
	@echo "MLOAD composition (on CP/M side):"
	@echo "  MLOAD CPM56=OS2CCP.HEX,OS3BDOS.HEX,serial.hex"
	@echo "  -> stamped CPM56.COM ready for SYSGEN"
