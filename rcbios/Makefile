# RC702 CP/M BIOS - assembly, extraction, and analysis
#
# Assembly targets (from jbox.dk sources with conditional assembly):
#   make rel21-mini  - Build rel.2.1 BIOS (5.25" mini, 56K)
#   make rel22-mini  - Build rel.2.2 BIOS (5.25" mini, 56K)
#   make rel14-maxi  - Build rel.1.4 BIOS (8" maxi, 58K)
#   make verify      - Build all and verify against reference binaries
#
# Patch and test:
#   make patch-test  - Patch BIOS onto disk images and boot-test in emulator
#
# Disassembly targets:
#   make rel14_bios.asm  - Regenerate annotated rel.1.4 disassembly
#
# Extraction targets (require emulator and disk images):
#   make dumps    - Extract RAM dumps from disk images
#   make bios     - Extract BIOS binaries from RAM dumps
#   make disasm   - Disassemble extracted BIOS binaries

ZMAC = ../zmac/bin/zmac
ZMFLAGS = -z --dri -I src

RC700 = $(HOME)/git/rc700
EMU = $(RC700)/rc700-vt100

# Disk image locations
IMG_RCCPM22 = $(RC700)/rccpm22.imd
IMG_COMAL80 = $(HOME)/Downloads/CPM_med_COMAL80.imd
IMG_REL22   = $(HOME)/Downloads/CPM_v.2.2_rel.2.2.bin
IMG_COMPAS  = $(HOME)/Downloads/Compas_v.2.13DK.imd
IMG_SW1711  = $(HOME)/Downloads/SW1711-I8.imd
IMG_RC703R12 = $(HOME)/Downloads/RC703_CPM_v2.2_r1.2.bin

# RAM dumps
DUMPS = rccpm22_ram.bin cpm_comal80_ram.bin cpm22_rel22_ram.bin compas_ram.bin

# BIOS binaries and disassemblies
BIOS_BINS = ref/rccpm22_bios.bin ref/cpm22_rel22_bios.bin ref/compas_bios.bin
BIOS_ASMS = rccpm22_bios.asm cpm22_rel22_bios.asm rel14_bios.asm

.PHONY: all rel21-mini rel22-mini rel23-maxi rel14-maxi verify dumps bios disasm clean emu patch-test mame-test

all: verify

# ============================================================
# Assembly targets
# ============================================================

# BIOS offset in output: BIOS base - START (code start)
# 56K: DA00 - D480 = 0x580
# 58K: E200 - DD00 = 0x500
BIOS_OFFSET_56K = 0x580
BIOS_OFFSET_58K = 0x500

rel21-mini: src/BIOS.MAC
	$(ZMAC) $(ZMFLAGS) -DREL21 -DMINI src/BIOS.MAC

rel22-mini: src/BIOS.MAC
	$(ZMAC) $(ZMFLAGS) -DREL22 -DMINI src/BIOS.MAC

rel23-maxi: src/BIOS.MAC
	$(ZMAC) $(ZMFLAGS) -DREL23 -DMAXI src/BIOS.MAC

rel14-maxi: src/BIOS.MAC
	$(ZMAC) $(ZMFLAGS) -DREL14 -DMAXI src/BIOS.MAC

# Verify all variants against reference binaries
verify: verify-rel21-mini verify-rel22-mini verify-rel23-maxi verify-rel14-maxi

verify-rel21-mini: rel21-mini
	python3 verify_bios.py zout/BIOS.hex ref/rccpm22_bios.bin $(BIOS_OFFSET_56K)

verify-rel22-mini: rel22-mini
	python3 verify_bios.py zout/BIOS.hex ref/cpm22_rel22_bios.bin $(BIOS_OFFSET_56K)

verify-rel23-maxi: rel23-maxi
	python3 verify_bios.py zout/BIOS.hex ref/sw1711_rel23_bios.bin $(BIOS_OFFSET_56K)

# The rel.1.4 build is functionally equivalent but NOT byte-identical
# to the original disk image, which was an independently written codebase.
# Verify only that it assembles without errors.
verify-rel14-maxi: rel14-maxi
	@echo "rel14-maxi: assembled OK (no byte-level verification — different codebase)"

# ============================================================
# Extraction and disassembly targets
# ============================================================

# Build the emulator with --memdump support
emu:
	cd $(RC700) && cc -DSDL_main=main -DSDL_MAIN_HANDLED \
		-o rc700-vt100 -O3 -Wno-unused-result \
		cpu0.c cpu1.c cpu2.c cpu3.c cpu4.c cpu5.c cpu6.c cpu7.c \
		rom.c charrom.c charram.c pio.c sio.c ctc.c dma.c crt.c \
		fdc.c wdc.c ftp.c disk.c fifo.c monitor.c disasm.c \
		rob358.c rc700.c rcterm-vt100.c

# Extract RAM dumps
dumps: $(DUMPS)

rccpm22_ram.bin: $(EMU) $(IMG_RCCPM22)
	$(EMU) -memdump $@ $(IMG_RCCPM22) > /dev/null 2>$@.log

cpm_comal80_ram.bin: $(EMU) $(IMG_COMAL80)
	$(EMU) -memdump $@ $(IMG_COMAL80) > /dev/null 2>$@.log

cpm22_rel22_ram.bin: $(EMU) /tmp/cpm22_rel22.imd
	$(EMU) -memdump $@ /tmp/cpm22_rel22.imd > /dev/null 2>$@.log

/tmp/cpm22_rel22.imd: $(IMG_REL22) bin2imd.py
	python3 bin2imd.py $(IMG_REL22) $@

compas_ram.bin: $(EMU) $(IMG_COMPAS)
	$(EMU) -maxi -memdump $@ $(IMG_COMPAS) > /dev/null 2>$@.log

# Extract BIOS binaries from RAM dumps
bios: $(BIOS_BINS)

ref/rccpm22_bios.bin ref/cpm22_rel22_bios.bin ref/compas_bios.bin: extract_bios.py $(DUMPS)
	python3 extract_bios.py ref/

# Extract rel.1.4 BIOS from disk image (Track 0)
ref/rel14_bios_disk.bin: imd2raw.py $(IMG_COMPAS)
	python3 imd2raw.py $(IMG_COMPAS) ref/compas_disk_t0.bin
	python3 -c "d=open('ref/compas_disk_t0.bin','rb').read(); open('$@','wb').write(d[0x500:0x500+5632])"

# Extract rel.1.2 RC703 BIOS from raw disk image (contiguous multi-density layout)
ref/rc703_rel12_bios.bin ref/rc703_rel12_t0.bin: $(IMG_RC703R12)
	python3 -c "d=open('$(IMG_RC703R12)','rb').read(); open('ref/rc703_rel12_t0.bin','wb').write(d[:6144])"
	python3 -c "d=open('$(IMG_RC703R12)','rb').read(); b=d[0x580:0x2381]; open('ref/rc703_rel12_bios.bin','wb').write(b)"

# Disassemble
disasm: $(BIOS_ASMS)

rccpm22_bios.asm: ref/rccpm22_bios.bin syms_56k_z80dasm.sym blocks_56k.def
	z80dasm -a -l -g 0xDA00 -S syms_56k_z80dasm.sym -b blocks_56k.def \
		-o $@ $< 2>/dev/null

cpm22_rel22_bios.asm: ref/cpm22_rel22_bios.bin syms_56k_z80dasm.sym blocks_56k.def
	z80dasm -a -l -g 0xDA00 -S syms_56k_z80dasm.sym -b blocks_56k.def \
		-o $@ $< 2>/dev/null

rel14_bios.asm: ref/rel14_bios_disk.bin syms_rel14_z80dasm.sym blocks_rel14.def
	z80dasm -a -l -g 0xE200 -S syms_rel14_z80dasm.sym -b blocks_rel14.def \
		-o $@ $< 2>/dev/null
	sed -i '' '/^trailing_end:.*equ/d' $@
	python3 defb2str.py $@
	python3 portnames.py $@

# ============================================================
# Patch test: build BIOS, patch onto disk image, boot in emulator
# ============================================================

# Patch rel.2.2 BIOS onto rel.2.1 mini image — signon should change
# Patch rel.2.3 BIOS onto SW1711 maxi image — should boot identically
patch-test: rel22-mini
	cp zout/BIOS.cim /tmp/rel22_mini.cim
	$(MAKE) rel23-maxi
	cp zout/BIOS.cim /tmp/rel23_maxi.cim
	python3 patch_bios.py $(IMG_RCCPM22) /tmp/rel22_mini.cim -o /tmp/patched_mini.imd
	python3 patch_bios.py $(IMG_SW1711) /tmp/rel23_maxi.cim -o /tmp/patched_maxi.imd
	$(EMU) -memdump /tmp/patched_mini_ram.bin /tmp/patched_mini.imd > /dev/null 2>/tmp/patched_mini.log
	grep -q 'rel\. 2\.2' /tmp/patched_mini.log && echo "MINI: rel. 2.2 signon OK" || (echo "MINI: FAILED"; exit 1)
	$(EMU) -maxi -memdump /tmp/patched_maxi_ram.bin /tmp/patched_maxi.imd > /dev/null 2>/tmp/patched_maxi.log
	grep -q 'rel\. 2\.3' /tmp/patched_maxi.log && echo "MAXI: rel. 2.3 signon OK" || (echo "MAXI: FAILED"; exit 1)
	@echo "patch-test: PASS"

# ============================================================
# MAME boot test: boot all disk images and verify signon
# ============================================================

mame-test:
	bash mame_boot_test.sh

clean:
	rm -f $(DUMPS) $(BIOS_BINS) $(BIOS_ASMS) *.log /tmp/cpm22_rel22.imd
	rm -f *_auto.sym
	rm -rf zout
