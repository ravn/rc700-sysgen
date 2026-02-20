# RC702 CP/M BIOS - assembly, extraction, and analysis
#
# Assembly targets (from jbox.dk sources with conditional assembly):
#   make rel21    - Build rel.2.1 BIOS (5.25" mini, 56K)
#   make rel22    - Build rel.2.2 BIOS (5.25" mini, 56K)
#   make compas   - Build rel.1.4 BIOS (8" maxi, 58K, Compas disk)
#   make verify   - Build all and verify against reference binaries
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

RC700 = ../../../rc700
EMU = $(RC700)/rc700-vt100

# Disk image locations
IMG_RCCPM22 = $(RC700)/rccpm22.imd
IMG_COMAL80 = $(HOME)/Downloads/CPM_med_COMAL80.imd
IMG_REL22   = $(HOME)/Downloads/CPM_v.2.2_rel.2.2.bin
IMG_COMPAS  = $(HOME)/Downloads/Compas_v.2.13DK.imd

# RAM dumps
DUMPS = rccpm22_ram.bin cpm_comal80_ram.bin cpm22_rel22_ram.bin compas_ram.bin

# BIOS binaries and disassemblies
BIOS_BINS = rccpm22_bios.bin cpm22_rel22_bios.bin compas_bios.bin
BIOS_ASMS = rccpm22_bios.asm cpm22_rel22_bios.asm rel14_bios.asm

.PHONY: all rel21 rel22 compas verify dumps bios disasm clean emu

all: verify

# ============================================================
# Assembly targets
# ============================================================

# BIOS offset in output: BIOS base - START (code start)
# 56K: DA00 - D480 = 0x580
# 58K: E200 - DD00 = 0x500
BIOS_OFFSET_56K = 0x580
BIOS_OFFSET_58K = 0x500

rel21: src/BIOS.MAC
	$(ZMAC) $(ZMFLAGS) -DMINI -DREL21 src/BIOS.MAC

rel22: src/BIOS.MAC
	$(ZMAC) $(ZMFLAGS) -DMINI -DREL22 src/BIOS.MAC

compas: src/BIOS.MAC
	$(ZMAC) $(ZMFLAGS) -DCOMPAS src/BIOS.MAC

# Verify all variants against reference binaries
verify: verify-rel21 verify-rel22 verify-compas

verify-rel21: rel21
	python3 verify_bios.py zout/BIOS.hex rccpm22_bios.bin $(BIOS_OFFSET_56K)

verify-rel22: rel22
	python3 verify_bios.py zout/BIOS.hex cpm22_rel22_bios.bin $(BIOS_OFFSET_56K)

verify-compas: compas
	python3 verify_bios.py zout/BIOS.hex compas_bios.bin $(BIOS_OFFSET_58K)

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

rccpm22_bios.bin cpm22_rel22_bios.bin compas_bios.bin: extract_bios.py $(DUMPS)
	python3 extract_bios.py

# Extract rel.1.4 BIOS from disk image (Track 0)
rel14_bios_disk.bin: imd2raw.py $(IMG_COMPAS)
	python3 imd2raw.py $(IMG_COMPAS) compas_disk_t0.bin
	python3 -c "d=open('compas_disk_t0.bin','rb').read(); open('$@','wb').write(d[0x500:0x500+5632])"

# Disassemble
disasm: $(BIOS_ASMS)

rccpm22_bios.asm: rccpm22_bios.bin syms_56k_z80dasm.sym blocks_56k.def
	z80dasm -a -l -g 0xDA00 -S syms_56k_z80dasm.sym -b blocks_56k.def \
		-o $@ $< 2>/dev/null

cpm22_rel22_bios.asm: cpm22_rel22_bios.bin syms_56k_z80dasm.sym blocks_56k.def
	z80dasm -a -l -g 0xDA00 -S syms_56k_z80dasm.sym -b blocks_56k.def \
		-o $@ $< 2>/dev/null

rel14_bios.asm: rel14_bios_disk.bin syms_rel14_z80dasm.sym blocks_rel14.def
	z80dasm -a -l -g 0xE200 -S syms_rel14_z80dasm.sym -b blocks_rel14.def \
		-o $@ $< 2>/dev/null
	sed -i '' '/^trailing_end:.*equ/d' $@
	python3 defb2str.py $@
	python3 portnames.py $@

clean:
	rm -f $(DUMPS) $(BIOS_BINS) $(BIOS_ASMS) *.log /tmp/cpm22_rel22.imd
	rm -f *_auto.sym
	rm -rf zout
