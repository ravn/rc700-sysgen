# z88dk — Z80 C compiler toolchain
#
# Downloads and unpacks the z88dk macOS release.
# The binaries (zcc, zsdcc, z80asm, etc.) end up in bin/.
#
# Usage:
#   make          — download + unpack
#   make clean    — remove everything
#   make check    — verify zcc works
#
# Requires: curl, unzip
#
# Release: https://github.com/z88dk/z88dk/releases
# Docs:    https://github.com/z88dk/z88dk/wiki

VERSION = 2.4
URL = https://github.com/z88dk/z88dk/releases/download/v$(VERSION)/z88dk-osx-$(VERSION).zip
ZIPFILE = download/z88dk-osx-$(VERSION).zip

# After unpacking, set these to use z88dk:
#   export PATH=$$PATH:$(pwd)/bin
#   export ZCCCFG=$(pwd)/lib/config

bin/zcc: download/z88dk/bin/zcc
	ln -sf download/z88dk/bin bin
	ln -sf download/z88dk/lib lib
	ln -sf download/z88dk/include include

download/z88dk/bin/zcc: $(ZIPFILE)
	cd download && unzip -qo ../$(ZIPFILE)
	touch $@

$(ZIPFILE):
	mkdir -p download
	curl -L --output $(ZIPFILE) $(URL)

check: bin/zcc
	ZCCCFG=$(CURDIR)/lib/config bin/zcc +test -v 2>&1 | head -1

clean:
	rm -rf download bin lib include

.PHONY: check clean
