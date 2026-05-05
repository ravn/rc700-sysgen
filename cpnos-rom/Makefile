# Makefile for cpnos-rom — combined CP/NOS autoloader+BIOS PROM
#
# Usage:
#   make cpnos                    Build NOS-only image (ENABLE_FDC=0)
#   make cpnos ENABLE_FDC=1       Build NOS + 8" DSDD image
#   make cpnos-size               Size breakdown, verify <= 4096 bytes
#   make cpnos-burn               Produce prom0.bin + prom1.bin for burner
#   make cpnos-disasm             Disassemble the ELF
#   make cpnos-clean              Remove build artifacts
#
# Phase 0: proof-of-life.  All code lands in PROM0, PROM1 is 0xFF-padded.

ENABLE_FDC ?= 0

# Mirror every impl_conout byte to SIO-B as well as the CRT.  Default 1
# matches existing smoke / netboot tests that grep /tmp/cpnos_siob.raw
# for the boot prompt.  Set MIRROR_SIOB=0 for CRT-only -- impl_conout
# becomes a single-target write, ~12 B smaller in resident code, and
# SIO-B stays silent so the channel is free for other uses.
MIRROR_SIOB ?= 1

# Boot-progress marker: 19 single-byte writes to the upper-right of
# row 0 ("INIT OKPNILOREC+PSJ" by the time CCP starts).  Default 1
# keeps the marker on for bring-up / debugging.  Set to 0 for the
# tightest production PROM -- saves ~30-50 B by collapsing every
# BOOT_MARK() call site to a no-op.  See hal.h for placement.
BOOT_MARK_ENABLED ?= 1

# Bring-up scaffolding: enables the PIO-B 10-byte CP/NET frame loopback
# test in cpnos_main (Z80 sends -> harness mirrors -> Z80 validates).
# Off by default since session 33 — the real driver (transport_pio.c
# pio_send_msg / pio_recv_msg, with the boot-time probe) supersedes
# the bring-up scaffolding.  Set to 1 only to re-run the historical
# harness mode `loopback`.
PIO_LOOPBACK_TEST ?= 0
# Speed test (overrides PIO_LOOPBACK_TEST when nonzero):
#   1 = C-loop TX     (transport_pio_send_byte per byte; function-call cost)
#   2 = inline OTIR TX (raw OUT (C),(HL); INC HL; DEC B; ~21 T/byte)
#   3 = RX (ISR-driven; back-to-back ISRs; ring overflow at high rates)
#   4 = RX (INIR busy-poll; IE disabled; ~21 T/byte, no IRQ overhead)
PIO_SPEED_TEST    ?= 0

LLVM_Z80 = $(CURDIR)/../../llvm-z80
CLANG_BUILD = $(firstword $(wildcard $(LLVM_Z80)/build-linux/bin \
                                     $(LLVM_Z80)/build-macos/bin \
                                     $(LLVM_Z80)/build/bin))

CC      = $(CLANG_BUILD)/clang
LD      = $(CLANG_BUILD)/ld.lld
OBJCOPY = $(CLANG_BUILD)/llvm-objcopy
OBJDUMP = $(CLANG_BUILD)/llvm-objdump
NM      = $(CLANG_BUILD)/llvm-nm

CFLAGS = --target=z80 -std=c23 -Oz -nostdlib -g \
         -ffunction-sections -fdata-sections \
         -Xclang -target-feature -Xclang +static-stack \
         -mllvm -disable-lsr \
         -DENABLE_FDC=$(ENABLE_FDC) \
         -DMIRROR_SIOB=$(MIRROR_SIOB) \
         -DBOOT_MARK_ENABLED=$(BOOT_MARK_ENABLED) \
         -DRC702_SLAVEID=0x01 \
         $(SERVER_CFLAGS) \
         -Iclang -I. \
         -Weverything \
         -Wno-unsafe-buffer-usage \
         -Wno-reserved-macro-identifier \
         -Wno-reserved-identifier \
         -Wno-gcc-compat \
         -Wno-declaration-after-statement \
         -Wno-pre-c11-compat \
         -Wno-pre-c23-compat \
         -Wno-int-to-pointer-cast \
         -Wno-cast-qual \
         -Wno-padded \
         -Wno-missing-prototypes \
         -Wno-missing-variable-declarations \
         -Wno-missing-noreturn \
         -Wno-sign-conversion

ifneq ($(PIO_SPEED_TEST),0)
CFLAGS += -DPIO_SPEED_TEST=$(PIO_SPEED_TEST)
else ifeq ($(PIO_LOOPBACK_TEST),1)
CFLAGS += -DPIO_LOOPBACK_TEST
endif

ASFLAGS = --target=z80 -g

# Server side: default is standard MP/M II (cpmsim mpm-net2).
# Override with SERVER=proxy to use the legacy Python netboot_server.py
# (FMT=0xB0 custom protocol).
SERVER ?= mpm

ifeq ($(SERVER),mpm)
NETBOOT_OBJ = clang/netboot_mpm.o
SERVER_CFLAGS =
else ifeq ($(SERVER),proxy)
NETBOOT_OBJ = clang/netboot.o
SERVER_CFLAGS = -DNETBOOT_LEGACY
else
$(error SERVER must be 'mpm' or 'proxy')
endif

# Transport selection — picks which chip drives the byte-level CP/NET
# wire.  SNIOS calls _xport_send_byte / _xport_recv_byte (snios.s);
# we ld --defsym those names to the chip-specific implementations.
#
#   pio-irq  : Z80-PIO Mode 1, IRQ-driven 256-byte SPSC ring buffer
#              (transport_pio.c).  Default for this branch.
#   sio      : SIO-A async polled (transport_sio.c).  Original wire,
#              ~38400 baud, ~3.8 KB/s.
#
# Used by `make pio-irq-smoke`, `make sio-smoke`, etc.
TRANSPORT ?= pio-irq
ifeq ($(TRANSPORT),pio-irq)
TRANSPORT_DEFSYMS = --defsym=_xport_send_byte=_transport_pio_send_byte \
                    --defsym=_xport_recv_byte=_transport_pio_recv_byte
TRANSPORT_NAME = PIO-IRQ
else ifeq ($(TRANSPORT),sio)
TRANSPORT_DEFSYMS = --defsym=_xport_send_byte=_transport_send_byte \
                    --defsym=_xport_recv_byte=_transport_recv_byte
TRANSPORT_NAME = SIO
else ifeq ($(TRANSPORT),pio-proxy)
# pio-proxy uses raw OTIR/INIR frames (transport_pio_vt) — no SNIOS
# envelope, so the byte-level _xport_* aliases aren't on the hot path.
# Still need to alias them or the linker complains; point at the PIO
# byte primitives (the bridge tolerates whatever bytes appear on the
# wire — only the frame-level matters for correctness).
TRANSPORT_DEFSYMS = --defsym=_xport_send_byte=_transport_pio_send_byte \
                    --defsym=_xport_recv_byte=_transport_pio_recv_byte
TRANSPORT_NAME = PIO-PRX
SERVER_CFLAGS += -DTRANSPORT_PROXY
else
$(error TRANSPORT must be 'pio-irq', 'sio', or 'pio-proxy')
endif

# Banner tag baked into transport_sio_vt.name (cpnos prints it as the
# wire-mode at boot — "RC702 CP/NOS WWW-MMM ...").  Padded to 7 chars
# (DRI's wire-mode field) — the build aborts if shorter.
SERVER_CFLAGS += -DTRANSPORT_NAME='"$(TRANSPORT_NAME)"'

# ---- Payload (linked at 0xED00, no PROM knowledge) ----------------
# The payload is the single contiguous blob of everything that runs
# at runtime.  The payload linker doesn't know about the two EPROMs;
# a separate relocator stitches it back together at cold boot.
PAYLOAD_OBJS = clang/runtime.o clang/bios_jt.o \
               clang/cpnos_main.o \
               clang/resident.o clang/cfgtbl.o clang/init.o \
               clang/transport_sio.o clang/transport_pio.o \
               $(NETBOOT_OBJ) \
               clang/snios.o clang/isr.o \
               clang/payload_checksum.o
PAYLOAD_LD = clang/payload.ld

# Preprocess payload.ld so the linker sees TRANSPORT_PROXY-conditional
# ASSERTs (e.g., the upper bound for __payload_end depends on whether
# the IRQ ring buffer at 0xF700 is in the layout).  ld.lld doesn't run
# cpp on linker scripts itself.
clang/payload.ld: payload.ld clang/transport_stamp
	@mkdir -p clang
	$(CC) --target=z80 -E -P -x c $(SERVER_CFLAGS) -o $@ $<

# ---- Relocator (PROM0 reset + #embed'd payload halves) -----------
# Tiny: reset.s for stack setup, relocator.c with two #embed arrays.
# Linked with PROM knowledge so the chunks land in physical ROM.
RELOC_OBJS = clang/reset.o clang/relocator.o
RELOC_LD = relocator.ld

ALL_OBJS = $(PAYLOAD_OBJS) $(RELOC_OBJS)

.PHONY: all cpnos cpnos-size cpnos-burn cpnos-disasm cpnos-clean \
        integration-test test cpnos-polypascal-test

all: cpnos

# Integration test: full E2E with z80pack mpm-net2 + MAME running CP/NOS
# slave + PolyPascal compiling and running PRIMES.PAS.  Catches the
# whole stack (transport, NDOS, BDOS, console, keyboard, file load,
# code execution, output framing).  Not part of `all` -- a normal build
# shouldn't boot MAME.  `make test` is an alias.
integration-test test: cpnos-polypascal-test

# Backwards-compatible alias for the old `make cpnos-ppas-test` name.
.PHONY: cpnos-ppas-test
cpnos-ppas-test: cpnos-polypascal-test

cpnos: clang/cpnos.bin cpnos-size cpnos-lis

# Flag changes (e.g. -DRC702_SLAVEID=) must invalidate all objects.
$(ALL_OBJS): Makefile clang/transport_stamp

# Re-stamp whenever TRANSPORT changes so a `make cpnos TRANSPORT=sio`
# after a `TRANSPORT=pio-irq` build (or vice versa) actually picks up
# the new -DTRANSPORT_NAME / --defsym aliases instead of relinking
# stale .o files.  The stamp's content is the current TRANSPORT value.
.PHONY: clang/transport_stamp
clang/transport_stamp:
	@mkdir -p clang
	@if [ ! -f $@ ] || [ "$$(cat $@ 2>/dev/null)" != "$(TRANSPORT)" ]; then \
	    echo "$(TRANSPORT)" > $@; \
	    echo "transport stamp: $(TRANSPORT)"; \
	fi

# ---- Compile ------------------------------------------------------

clang/reset.o: reset.s
	@mkdir -p clang
	$(CC) $(ASFLAGS) -c $< -o $@

clang/runtime.o: runtime.s
	@mkdir -p clang
	$(CC) $(ASFLAGS) -c $< -o $@

clang/bios_jt.o: bios_jt.s
	@mkdir -p clang
	$(CC) $(ASFLAGS) -c $< -o $@

clang/snios.o: snios.s
	@mkdir -p clang
	$(CC) $(ASFLAGS) -c $< -o $@

# Phase 2B: cpnos_main.c (nos_handoff) writes ZP[5..7] = JP BDOS
# itself, replacing cpnos-build's deleted cpnos.asm entry stub.
# BDOS's address is link-time-determined inside cpnos.com; extract it
# from cpnos.sym into a generated header.
clang/cpnos_addrs.h: cpnos-build/d/cpnos.com
	@mkdir -p clang
	@perl -ne 'while (/([0-9A-Fa-f]{4})\s+BDOS\b/g) { print "#define CPNOS_BDOS_ADDR 0x$$1\n"; last }' \
	    cpnos-build/d/cpnos.sym > $@.tmp
	@grep -q '^#define CPNOS_BDOS_ADDR' $@.tmp || \
	    { echo "ERROR: BDOS symbol missing from cpnos.sym"; rm -f $@.tmp; exit 1; }
	@# TPA top reported by CP/M utilities = NDOSE = NDOS + 0x0122 (the
	@# NDOS BDOS-replacement entry).  TPA size = TPA top - 0x0100.
	@N=$$(perl -ne 'while (/([0-9A-Fa-f]{4})\s+NDOS\b/g) { print "$$1"; last }' cpnos-build/d/cpnos.sym); \
	 [ -n "$$N" ] || { echo "ERROR: NDOS symbol missing from cpnos.sym"; rm -f $@.tmp; exit 1; }; \
	 NV=$$((0x$$N)); \
	 TPA_KB=$$(( (NV + 0x122 - 0x100) / 1024 )); \
	 echo "#define CPNOS_NDOS_ADDR 0x$$N" >> $@.tmp; \
	 echo "#define CPNOS_TPA_KB $$TPA_KB" >> $@.tmp
	@mv $@.tmp $@
	@echo "cpnos_addrs.h: $$(grep -E 'BDOS_ADDR|NDOS_ADDR|TPA_KB' $@ | tr '\n' ' ')"

# Build info — UTC date + short git hash, regenerated every build so
# the signon banner reflects the moment this PROM was burnt.  The
# `cmp` dance avoids pointlessly retouching the file (and rebuilding
# cpnos_main.o) when neither field changed since last build.
.PHONY: clang/cpnos_buildinfo.h
clang/cpnos_buildinfo.h:
	@mkdir -p clang
	@D=$$(date -u +"%Y-%m-%d %H:%M"); \
	 H=$$(git rev-parse --short HEAD 2>/dev/null || echo "????"); \
	 if ! git diff --quiet -- . 2>/dev/null; then H="$$H+"; fi; \
	 { \
	   echo '#ifndef CPNOS_BUILDINFO_H'; \
	   echo '#define CPNOS_BUILDINFO_H'; \
	   echo "#define BUILD_DATE_STR \"$$D\""; \
	   echo "#define GIT_HASH_STR   \"$$H\""; \
	   echo '#define BUILD_INFO_STR BUILD_DATE_STR " " GIT_HASH_STR'; \
	   echo '#endif'; \
	 } > $@.tmp; \
	 if cmp -s $@.tmp $@ 2>/dev/null; then rm -f $@.tmp; \
	 else mv $@.tmp $@; echo "buildinfo: $$D $$H"; fi

clang/cpnos_main.o: cpnos_main.c hal.h clang/cpnos_addrs.h clang/cpnos_buildinfo.h
	@mkdir -p clang
	$(CC) $(CFLAGS) -c $< -o $@

clang/resident.o: resident.c hal.h
	@mkdir -p clang
	$(CC) $(CFLAGS) -c $< -o $@

clang/payload_checksum.o: payload_checksum.c
	@mkdir -p clang
	$(CC) $(CFLAGS) -c $< -o $@

clang/cfgtbl.o: cfgtbl.c
	@mkdir -p clang
	$(CC) $(CFLAGS) -c $< -o $@

clang/init.o: init.c hal.h
	@mkdir -p clang
	$(CC) $(CFLAGS) -c $< -o $@

clang/isr.o: isr.c hal.h
	@mkdir -p clang
	$(CC) $(CFLAGS) -c $< -o $@

clang/transport_sio.o: transport_sio.c transport.h hal.h
	@mkdir -p clang
	$(CC) $(CFLAGS) -c $< -o $@

clang/transport_pio.o: transport_pio.c transport.h hal.h
	@mkdir -p clang
	$(CC) $(CFLAGS) -c $< -o $@

clang/netboot.o: netboot.c transport.h hal.h
	@mkdir -p clang
	$(CC) $(CFLAGS) -c $< -o $@

clang/netboot_mpm.o: netboot_mpm.c hal.h
	@mkdir -p clang
	$(CC) $(CFLAGS) -c $< -o $@

# Relocator #embed's payload_a.bin/payload_b.bin — depend on them so
# a payload change retriggers the relocator compile.
# Relocator compile flags: same as CFLAGS but without the
# `-Xclang -target-feature -Xclang +static-stack` sequence.  The
# relocator stack is at SP=0xED00 (RAM) and stack-allocated C
# locals work fine; +static-stack would put them in .bss, which
# relocator.ld discards — link fails on .bss relocation.
CFLAGS_RELOC = $(subst -Xclang -target-feature -Xclang +static-stack,,$(CFLAGS))

clang/relocator.o: relocator.c clang/init.bin clang/payload_a.bin clang/payload_b.bin
	@mkdir -p clang
	$(CC) $(CFLAGS_RELOC) -c $< -o $@

# ---- Link payload (no PROM awareness) ----------------------------

clang/payload.elf: $(PAYLOAD_OBJS) $(PAYLOAD_LD) cpnos-build/d/cpnos.sym
	@# Extract NDOS load address from cpnos.sym and pass cpnos.com end
	@# (NDOS + 0xC80) as a linker symbol so payload.ld's stack/cpnos
	@# overlap ASSERTs can fire.  Catches the Option β bring-up bug
	@# (stack at 0xED00 colliding with raised cpnos.com top) at link
	@# time instead of as silent boot-time RAM corruption.
	@N=$$(perl -ne 'while (/([0-9A-Fa-f]{4})\s+NDOS\b/g) { print "$$1"; last }' cpnos-build/d/cpnos.sym); \
	 [ -n "$$N" ] || { echo "ERROR: NDOS symbol missing from cpnos.sym"; exit 1; }; \
	 NEND=$$(printf '0x%X' $$(( 0x$$N + 0xC80 ))); \
	 echo "payload.elf: __cpnos_load_end = $$NEND (NDOS 0x$$N + 0xC80)"; \
	 $(LD) --gc-sections --emit-relocs -T $(PAYLOAD_LD) \
	    --defsym=__cpnos_load_end=$$NEND \
	    $(TRANSPORT_DEFSYMS) $(PAYLOAD_OBJS) -o $@

clang/payload.bin: clang/payload.elf cpnos-build/patch_payload_checksum.py
	$(OBJCOPY) -O binary --only-section=.payload $< $@
	# Patch the payload integrity checksum into the last 2 bytes
	# of the resident image.  See patch_payload_checksum.py /
	# payload.ld (.payload_checksum section).
	python3 cpnos-build/patch_payload_checksum.py $@

# Init image: .init output section -- runs in place from PROM 0
# at 0x0100, never copied to RAM.  Init/resident split, step 3.
clang/init.bin: clang/payload.elf
	$(OBJCOPY) -O binary --only-section=.init $< $@

# Split resident payload.bin into the two chunks the relocator
# #embed's.  Split point = relocator.ld's .prom0_tail base.  After
# the init/resident split (step 3) PROM 0 layout is:
#   0x0000 reset (0x0F)
#   0x0010 relocator code (~0x?? B, capped at 0x100)
#   0x0100 init.bin (.init runs in place, up to 0x300)
#   0x0400 .prom0_tail = first PROM0_TAIL_SIZE bytes of resident
#   0x2000 .prom1     = remaining resident bytes
# PROM0_TAIL_SIZE = 0x800 - 0x400 = 0x400 = 1024 bytes.
PROM0_TAIL_SIZE = 1024
clang/payload_a.bin clang/payload_b.bin: clang/payload.bin
	dd if=$< of=clang/payload_a.bin bs=1 count=$(PROM0_TAIL_SIZE) status=none
	dd if=$< of=clang/payload_b.bin bs=1 skip=$(PROM0_TAIL_SIZE) status=none

# ---- Link relocator ----------------------------------------------
# --defsym injects _cpnos_cold_entry's address from the payload ELF
# (extracted via nm) so relocator.c's extern reference resolves.

clang/relocator.elf: $(RELOC_OBJS) $(RELOC_LD) clang/payload.elf
	@addr=$$($(NM) clang/payload.elf | awk '/ _cpnos_cold_entry$$/ {print "0x"$$1}'); \
	 test -n "$$addr" || { echo "ERROR: _cpnos_cold_entry not found in payload"; exit 1; }; \
	 stack=$$($(NM) clang/payload.elf | awk '/ __stack_top$$/ {print "0x"$$1}'); \
	 test -n "$$stack" || { echo "ERROR: __stack_top not found in payload"; exit 1; }; \
	 bios=$$($(NM) clang/payload.elf | awk '/ _bios_boot$$/ {print "0x"$$1}'); \
	 test -n "$$bios" || { echo "ERROR: _bios_boot not found in payload"; exit 1; }; \
	 echo "relocator: _cpnos_cold_entry=$$addr  __stack_top=$$stack  _bios_boot=$$bios"; \
	 $(LD) --gc-sections -T $(RELOC_LD) \
	       --defsym=_cpnos_cold_entry=$$addr \
	       --defsym=__stack_top=$$stack \
	       --defsym=_bios_boot=$$bios \
	       $(RELOC_OBJS) -o $@

# ---- Produce prom0.bin / prom1.bin --------------------------------

clang/cpnos.bin: clang/relocator.elf
	$(OBJCOPY) -O binary --gap-fill=0xFF --pad-to=0x2800 $< clang/cpnos.raw
	dd if=clang/cpnos.raw of=clang/prom0.bin bs=2048 count=1 status=none
	dd if=clang/cpnos.raw of=clang/prom1.bin bs=2048 skip=4 count=1 status=none
	cat clang/prom0.bin clang/prom1.bin > $@

# ---- Size check ---------------------------------------------------

cpnos-size: clang/cpnos.bin
	@P0=$$(wc -c < clang/prom0.bin | tr -d ' '); \
	 P1=$$(wc -c < clang/prom1.bin | tr -d ' '); \
	 PLD=$$(wc -c < clang/payload.bin | tr -d ' '); \
	 TOTAL=$$(wc -c < clang/cpnos.bin | tr -d ' '); \
	 echo "payload:  $$PLD bytes (linked at 0xED00)"; \
	 echo "PROM0:    $$P0 / 2048 bytes"; \
	 echo "PROM1:    $$P1 / 2048 bytes"; \
	 echo "TOTAL:    $$TOTAL / 4096 bytes"; \
	 test $$TOTAL -eq 4096 || { echo "ERROR: image not exactly 4096 bytes"; exit 1; }
	@echo "--- payload section sizes ---"
	@$(OBJDUMP) --headers clang/payload.elf | awk '/\.(payload|scratch)/ { printf "%-16s 0x%s VMA=0x%s\n", $$2, $$3, $$4 }'
	@echo "--- top payload symbols ---"
	@$(NM) --numeric-sort --size-sort --reverse-sort clang/payload.elf | head -10
	@echo "--- actual code bytes in PROM0 (non-0xFF) ---"
	@od -An -tx1 clang/prom0.bin | tr -s ' ' '\n' | grep -v '^$$' | grep -v '^ff$$' | wc -l | awk '{ printf "%d non-padding bytes\n", $$1 }'

# ---- CP/M .COM loader (test PROMs without burning) ---------------
#
# Produces a ~4 KB .COM that, when executed from the CP/M prompt,
# copies prom0.bin into 0x0000 and prom1.bin into 0x2000 then JPs
# to 0x0000 — mimicking a cold boot against new PROM payloads
# without touching physical EPROMs.  See build_loader.py for layout.

cpnos-loader: clang/cpnos.bin
	python3 build_loader.py clang/prom0.bin clang/prom1.bin clang/cpnos_loader.com
	cp clang/cpnos_loader.com testutil/cpnosldr.com
	@echo "staged testutil/cpnosldr.com (run 'cpnosldr' from CP/M A>)"

# ---- Split for burner --------------------------------------------

cpnos-burn: clang/cpnos.bin
	@echo "PROM0 (0x0000-0x07FF): clang/prom0.bin ($$(wc -c < clang/prom0.bin | tr -d ' ') B)"
	@echo "PROM1 (0x2000-0x27FF): clang/prom1.bin ($$(wc -c < clang/prom1.bin | tr -d ' ') B)"

# ---- Switch MAME into cpnos boot mode ----------------------------
#
# RC702 has two PROM slots and the MAME rc702 driver loads each from
# a separate file:
#     PROM 0 ($0000..$07FF) <- mame/roms/rc702/roa375.ic66
#     PROM 1 ($2000..$27FF) <- mame/roms/rc702/prom1.ic65
#
# This target SWITCHES MAME into the cpnos network-boot mode by
# overwriting BOTH files with today's cpnos build:
#     prom0.bin -> roa375.ic66
#     prom1.bin -> prom1.ic65
#
# Both MUST be refreshed in lockstep.  Refreshing only one
# mismatches the patcher's checksum correction (which lives in
# payload_b -> prom1.bin) against today's body sum, triggering the
# cpnos PROM's BAD CHECKSUM infinite loop -- visible as a black
# screen with "BAD CHECKSUM" at row 0 of the CRT.
#
# Mode swap: to go back to the rcbios standalone (autoload-PROM)
# boot mode, run `make prom` in ../autoload-in-c/, which writes
# autoload-in-c's prom.bin -> roa375.ic66 (overwriting cpnos's
# PROM 0).  prom1.ic65 is unused in autoload mode but stays as
# whatever was last installed.
#
# Note: cpnos requires a host-side z80pack mpm-net2 server to do
# anything beyond the banner (per project_cpnos_mame_prereqs).
# This target refreshes PROMs only -- spinning up mpm is the
# user's job.  For BIOS-only verification work (no cpnos network
# code), use rcbios standalone mode instead -- it boots end-to-end
# without mpm.

MAME_ROMS_DIR ?= $(CURDIR)/../../mame/roms/rc702

mame-roms-cpnos: clang/cpnos.bin
	@test -d "$(MAME_ROMS_DIR)" || \
	    { echo "ERROR: MAME_ROMS_DIR=$(MAME_ROMS_DIR) does not exist"; exit 1; }
	@P0=$$(wc -c < clang/prom0.bin | tr -d ' '); \
	 P1=$$(wc -c < clang/prom1.bin | tr -d ' '); \
	 test "$$P0" = "2048" || { echo "ERROR: prom0.bin is $$P0 B, expected 2048"; exit 1; }; \
	 test "$$P1" = "2048" || { echo "ERROR: prom1.bin is $$P1 B, expected 2048"; exit 1; }
	cp clang/prom0.bin "$(MAME_ROMS_DIR)/roa375.ic66"
	cp clang/prom1.bin "$(MAME_ROMS_DIR)/prom1.ic65"
	@echo "Switched MAME into cpnos mode:"
	@echo "  $(MAME_ROMS_DIR)/roa375.ic66 (cpnos prom0)"
	@echo "  $(MAME_ROMS_DIR)/prom1.ic65 (cpnos prom1)"
	@echo "To switch back to rcbios standalone mode, run:"
	@echo "  cd ../autoload-in-c && make prom"

# ---- Inspection --------------------------------------------------

cpnos-disasm: clang/payload.elf clang/relocator.elf
	$(OBJDUMP) -d --triple=z80 clang/payload.elf
	@echo '=== relocator ==='
	$(OBJDUMP) -d --triple=z80 clang/relocator.elf

# ---- MAME boot test ----------------------------------------------

MAME = /Users/ravn/git/mame
MAME_PROM0 = $(MAME)/roms/rc702/roa375.ic66
MAME_PROM1 = $(MAME)/roms/rc702/prom1.ic65

# Disk-image install: rebuild cpnos.com from cpnos-build/ and inject the
# fresh blob into both MP/M library disks.  Prevents the "PROM updated
# but disk still has stale cpnos.com" trap (2026-04-25 incident — see
# memory: project_cpnos_address_coupling_brittle).  The launcher prefers
# cpnetsmk-1.dsk if present, so updating only mpm-net2-1.dsk silently
# fails to take effect — both must be refreshed.
MPM_DISK_LIB = ../z80pack/cpmsim/disks/library
cpnos-disk-install: cpnos-build/d/cpnos.com
	@echo "=== stamping cpnos.com with build timestamp ==="
	@python3 cpnos-build/stamp_cpnos.py cpnos-build/d/cpnos.com clang/cpnos_stamped.com
	@echo "=== installing stamped cpnos.com onto MP/M library disks ==="
	@cpmrm -f ibm-3740 $(MPM_DISK_LIB)/mpm-net2-1.dsk 0:cpnos.img 2>/dev/null || true
	cpmcp -f ibm-3740 $(MPM_DISK_LIB)/mpm-net2-1.dsk \
	    clang/cpnos_stamped.com 0:cpnos.img
	@if [ -f $(MPM_DISK_LIB)/cpnetsmk-1.dsk ]; then \
	    cpmrm -f ibm-3740 $(MPM_DISK_LIB)/cpnetsmk-1.dsk 0:cpnos.img 2>/dev/null || true; \
	    cpmcp -f ibm-3740 $(MPM_DISK_LIB)/cpnetsmk-1.dsk \
	        clang/cpnos_stamped.com 0:cpnos.img; \
	    echo "  refreshed cpnos.img on cpnetsmk-1.dsk"; \
	 fi
	@echo "  refreshed cpnos.img on mpm-net2-1.dsk"

# Force cpnos.com to rebuild whenever any of its sources change.
.PHONY: cpnos-disk-install
cpnos-build/d/cpnos.com: $(wildcard cpnos-build/src/*.asm cpnos-build/src/*.s) cpnos-build/Makefile
	$(MAKE) -C cpnos-build all

# Install prom0.bin into MAME (4KB slot, pad with 0xFF).  PROM1 at
# 0x2000 in MAME is 0xFF by default — fine for Phase 1 where our
# PROM1 is unused.
#
# Depends on cpnos-disk-install so a single `make cpnos-install` (and
# anything that pulls in cpnos-install — cpnet-smoke, cpnos-mame, etc.)
# guarantees the disk-side cpnos.com matches the freshly-built PROM.
cpnos-install: clang/cpnos.bin cpnos-disk-install
	@P0=$$(wc -c < clang/prom0.bin | tr -d ' '); \
	 { cat clang/prom0.bin; perl -e "print \"\\xff\" x (4096 - $$P0)"; } \
	   > clang/prom0_padded.ic66
	cp clang/prom0_padded.ic66 $(MAME_PROM0)
	cp clang/prom1.bin         $(MAME_PROM1)
	@echo "installed cpnos prom0 -> $(MAME_PROM0)"
	@echo "installed cpnos prom1 -> $(MAME_PROM1)"

# ---- cpnet-smoke: end-to-end test against live MP/M ---------------
#
# Non-trivial test: slave drives CP/M ASM (from master B:) to assemble
# an unrolled sum-of-1..1000 program from master D:, LOADs the HEX to
# COM (also on D:), and runs it.  The program computes 0xA314 and
# prints "CPNET OK A314".  Any CP/NET or CCP/BDOS/BIOS regression
# corrupts the assembler's output → the running program prints the
# wrong string or crashes → grep fails → make target fails.
#
# Preconditions:
#   - MP/M is running in a screen session (see
#     z80pack/cpmsim/mpm-net2).  Target restarts it so the drive
#     staging is fresh.
#   - cpnos-rom is built and installed into MAME.
#
# Prints PASS or FAIL and exits accordingly.
MPM_DIR ?= $(CURDIR)/../z80pack/cpmsim
SMOKE_PORT ?= 9001

# WORKLOAD selects which CCP-driven program the bench harness runs.
# Each value here is a key in WORKLOADS (testutil/smoke_inject.py)
# plus a corresponding finish-marker string + 1-line description.
#   sumtest  : m80 sumtest,=sumtest.asm + l80 + sumtest (CPU-bound,
#              ~10:1 read:write CP/NET RTTs; deterministic CPNET OK
#              A314 verifies arithmetic).
#   filecopy : pre-staged FILECOPY.COM reads SUMTEST.ASM record-by-
#              record via BDOS F_READ and writes SUMTEST.CPY via
#              F_WRITE.  Pure file I/O, no compiler in the timed
#              window.  Verify step extracts both files via cpmcp and
#              byte-compares them.
WORKLOAD ?= sumtest
ifeq ($(WORKLOAD),sumtest)
WORKLOAD_MARKER = CPNET OK A314
WORKLOAD_DESC   = m80+l80+sumtest
else ifeq ($(WORKLOAD),filecopy)
WORKLOAD_MARKER = FILECOPY OK
WORKLOAD_DESC   = filecopy (R+W SUMTEST.ASM via CP/NET)
else
$(error WORKLOAD must be 'sumtest' or 'filecopy')
endif

# ---- preflight checks: setup must match target ---------------------
#
# The "wire-mode tag" baked into the cpnos banner (and visible at
# runtime as e.g. "RC702 CP/NOS PIO-IRQ ...") is set from
# active_transport->name in transport_sio.c.  The string lives at a
# fixed offset in cpnos.bin, so a literal grep on the binary tells us
# what the slave will report.  Targets assert the right tag is present
# (or absent) to avoid the topology-mismatch class of bug from
# 2026-04-28 (Phase 27c — see tasks/timeline.md).
#
# Likewise we check that MAME_IRQ exists with the cpnet_bridge gate
# fix before pio-irq-* targets launch — otherwise the slave's IRQ
# path silently drops bytes when poll_tick over-strobes.

# Slave was built with active_transport->name = "PIO-IRQ"
_check-tag-pio-irq:
	@if ! strings clang/cpnos.bin 2>/dev/null | grep -q '^PIO-IRQ '; then \
	    echo "FAIL: cpnos.bin does not contain wire-mode tag 'PIO-IRQ'."; \
	    echo "      This target requires a PIO-IRQ build; check"; \
	    echo "      transport_sio.c's transport_sio_vt.name."; \
	    exit 1; \
	fi

# Slave was NOT built for PIO-IRQ (cpnet-smoke wires SIO-A, not PIO-B)
_check-tag-not-pio-irq:
	@if strings clang/cpnos.bin 2>/dev/null | grep -q '^PIO-IRQ '; then \
	    echo "FAIL: cpnos.bin reports wire-mode 'PIO-IRQ' but this target"; \
	    echo "      wires SIO-A only.  Either rebuild cpnos for SIO mode"; \
	    echo "      or use 'make pio-irq-smoke' instead."; \
	    exit 1; \
	fi

# Slave was built with active_transport->name = "PIO-PRX" (pio-proxy mode).
_check-tag-pio-prx:
	@if ! strings clang/cpnos.bin 2>/dev/null | grep -q '^PIO-PRX '; then \
	    echo "FAIL: cpnos.bin does not contain wire-mode tag 'PIO-PRX'."; \
	    echo "      This target requires a TRANSPORT=pio-proxy build."; \
	    exit 1; \
	fi

# MAME_IRQ tree contains the cpnet_bridge gate fix (commit 60e2b9a032f
# on pio-mpm-irq-fix branch).  We check by source-grep, not by binary
# inspection — robust against the binary being rebuilt without the fix.
_check-mame-irq:
	@if [ ! -x $(MAME_IRQ)/regnecentralend ]; then \
	    echo "FAIL: $(MAME_IRQ)/regnecentralend not found or not executable"; \
	    exit 1; \
	fi
	@if [ ! -f $(MAME_IRQ)/src/devices/bus/rc702/pio_port/cpnet_bridge.cpp ]; then \
	    echo "FAIL: $(MAME_IRQ) is not a MAME tree (no cpnet_bridge.cpp)"; \
	    exit 1; \
	fi
	@if ! grep -q 'm_brdy_high' $(MAME_IRQ)/src/devices/bus/rc702/pio_port/cpnet_bridge.cpp; then \
	    echo "FAIL: $(MAME_IRQ) cpnet_bridge.cpp missing the gate fix."; \
	    echo "      Need branch with poll_tick gated on m_brdy_high"; \
	    echo "      (commit 60e2b9a032f on ravn/mame:pio-mpm-irq-fix)."; \
	    exit 1; \
	fi
	@if [ ! $(MAME_IRQ)/regnecentralend -nt $(MAME_IRQ)/src/devices/bus/rc702/pio_port/cpnet_bridge.cpp ]; then \
	    echo "FAIL: $(MAME_IRQ)/regnecentralend is older than cpnet_bridge.cpp."; \
	    echo "      Rebuild MAME (cd $(MAME_IRQ) && make)."; \
	    exit 1; \
	fi

# ---- _verify-bench: shared bench verifier (post-MAME) -----------
# Asserts SIO-B contains the workload's finish marker, prints the
# smoke_inject "bench=X.XXXs" timing, and (for filecopy) extracts
# SUMTEST.ASM + SUMTEST.CPY from the master's drivea.dsk and byte-
# compares them.  WORKLOAD must already be set by the caller.
.PHONY: _verify-bench
_verify-bench:
	@echo "=== verify ($(WORKLOAD)): marker '$(WORKLOAD_MARKER)' ==="
	@echo "--- inject log ---"
	@cat /tmp/cpnos_smoke_inject.log
	@echo "--- SIO-B tail ---"
	@tr -cd '\11\12\15\40-\176' < /tmp/cpnos_siob.raw 2>/dev/null | tail -c 400
	@echo
	@grep -q '$(WORKLOAD_MARKER)' /tmp/cpnos_siob.raw \
	    && echo "PASS: marker '$(WORKLOAD_MARKER)' present" \
	    || (echo "FAIL: marker '$(WORKLOAD_MARKER)' not in SIO-B"; exit 1)
	@bench=$$(grep -oE 'bench=[0-9.]+s' /tmp/cpnos_smoke_inject.log | tail -1); \
	 [ -n "$$bench" ] && echo "BENCH (-nothrottle, $(WORKLOAD_DESC)): $$bench" \
	   || echo "(bench timing not found)"
ifeq ($(WORKLOAD),filecopy)
	@echo "--- frames-to-completion / throughput (from FILECOPY OK) ---"
	@line=$$(grep 'FILECOPY OK' /tmp/cpnos_siob.raw | tail -1 | tr -d '\r'); \
	 echo "  $$line"; \
	 r=$$(echo "$$line" | sed -nE 's/.*FILECOPY OK ([0-9A-F]{4}) .*/\1/p'); \
	 s=$$(echo "$$line" | sed -nE 's/.*S=([0-9A-F]{8}).*/\1/p'); \
	 e=$$(echo "$$line" | sed -nE 's/.*E=([0-9A-F]{8}).*/\1/p'); \
	 if [ -n "$$r" ] && [ -n "$$s" ] && [ -n "$$e" ]; then \
	   recs=$$(printf '%d' $$((0x$$r))); \
	   d=$$(printf '%d' $$((0x$$e - 0x$$s))); \
	   bytes_dir=$$((recs * 128)); \
	   bytes_total=$$((bytes_dir * 2)); \
	   echo "  records = $$recs ($$bytes_dir B per direction, $$bytes_total B total R+W)"; \
	   echo "  frames  = E - S = $$d (= $$(echo "scale=2; $$d / 50" | bc) s emulated @ 50 Hz CRT)"; \
	   if [ "$$d" -gt 0 ]; then \
	     kbps_dir=$$(echo "scale=2; $$bytes_dir * 50 / $$d / 1024" | bc); \
	     kbps_tot=$$(echo "scale=2; $$bytes_total * 50 / $$d / 1024" | bc); \
	     echo "  THROUGHPUT (one direction) = $$kbps_dir KB/s emulated"; \
	     echo "  THROUGHPUT (R+W combined)  = $$kbps_tot KB/s emulated"; \
	   fi; \
	 fi
	@echo "--- byte-compare SUMTEST.ASM vs SUMTEST.CPY ---"
	@DRIVE_A=$(MPM_DIR)/disks/drivea.dsk; \
	 cpmcp -f ibm-3740 $$DRIVE_A 0:SUMTEST.ASM /tmp/_ref.asm 2>/dev/null || \
	     (echo "FAIL: cpmcp could not extract SUMTEST.ASM from $$DRIVE_A"; exit 1); \
	 cpmcp -f ibm-3740 $$DRIVE_A 0:SUMTEST.CPY /tmp/_cpy.asm 2>/dev/null || \
	     (echo "FAIL: cpmcp could not extract SUMTEST.CPY"; exit 1); \
	 ref_n=$$(wc -c < /tmp/_ref.asm | tr -d ' '); \
	 cpy_n=$$(wc -c < /tmp/_cpy.asm | tr -d ' '); \
	 echo "  SUMTEST.ASM: $$ref_n bytes"; \
	 echo "  SUMTEST.CPY: $$cpy_n bytes"; \
	 head -c $$ref_n /tmp/_cpy.asm > /tmp/_cpy_head.asm; \
	 if cmp -s /tmp/_ref.asm /tmp/_cpy_head.asm; then \
	     echo "PASS: first $$ref_n bytes identical (CPY tail is record-pad)"; \
	 else \
	     echo "FAIL: byte mismatch in CPY[0..$$ref_n]; first 5 offsets:"; \
	     cmp -l /tmp/_ref.asm /tmp/_cpy_head.asm 2>/dev/null | head -5; \
	     exit 1; \
	 fi
endif

cpnet-smoke: cpnos-install _check-tag-not-pio-irq

# ---- sio-smoke: pio-irq-smoke counterpart for SIO mode ------------
# Recursive make invocation so TRANSPORT=sio reaches all the rebuild
# rules (the stamp triggers the .o invalidation).  cpnet-smoke's own
# preflight (_check-tag-not-pio-irq) verifies the build came out right.
.PHONY: sio-smoke
sio-smoke:
	$(MAKE) cpnet-smoke TRANSPORT=sio WORKLOAD=$(WORKLOAD)
	@echo "=== 1/5 regenerating sumtest.asm + smoke disk ==="
	python3 testutil/mksmokeasm.py
	testutil/mksmokedisk.sh
	@echo "=== 2/5 restarting MP/M with fresh drive D: ==="
	-screen -S mpm -X quit >/dev/null 2>&1 || true
	@sleep 1
	@# Guard: make sure nothing else is squatting on :4002 (stray
	@# netboot_server.py, orphan cpmsim, ...) — any phantom listener
	@# will intercept MAME's netboot and produce misleading results.
	@if lsof -nP -iTCP:4002 -sTCP:LISTEN 2>/dev/null | grep -q .; then \
	    echo "ERROR: port 4002 already bound — kill the squatter first:"; \
	    lsof -nP -iTCP:4002 -sTCP:LISTEN; \
	    exit 1; \
	fi
	cd $(MPM_DIR) && screen -dmS mpm ./mpm-net2
	@echo "=== 3/5 waiting for MP/M CP/NET server on :4002 ==="
	@until nc -z 127.0.0.1 4002 2>/dev/null; do sleep 0.5; done
	@sleep 4
	@echo "=== 4/5 launching MAME + smoke injector (workload: $(WORKLOAD)) ==="
	@rm -f /tmp/cpnos_siob.raw /tmp/cpnos_smoke_inject.log /tmp/cpnos_boot_marks.txt
	@python3 -u testutil/smoke_inject.py $(SMOKE_PORT) \
	    --workload $(WORKLOAD) \
	    --log /tmp/cpnos_siob.raw --timeout 240 \
	    > /tmp/cpnos_smoke_inject.log 2>&1 & \
	 echo $$! > /tmp/cpnos_smoke_inject.pid
	@sleep 0.3
	-$(MAME)/regnecentralend rc702 -rompath $(MAME)/roms \
	    -nothrottle -window -skip_gameinfo \
	    -seconds_to_run 1200 \
	    -rs232a null_modem -bitb1 socket.127.0.0.1:4002 \
	    -rs232b null_modem -bitb2 socket.127.0.0.1:$(SMOKE_PORT) \
	    -autoboot_script mame_porttap.lua
	@kill $$(cat /tmp/cpnos_smoke_inject.pid) 2>/dev/null || true
	@$(MAKE) _verify-bench WORKLOAD=$(WORKLOAD)

cpnos-mame: cpnos-install
	$(MAME)/regnecentralend rc702 -rompath $(MAME)/roms \
	    -nothrottle -window -skip_gameinfo \
	    -seconds_to_run 8 \
	    -rs232a null_modem \
	    -bitb1 /tmp/cpnos_sioa.raw \
	    -autoboot_script mame_boot_test.lua

# ---- pio-irq-netboot: PIO-IRQ-direct topology against mpm-net2 -----
#
# The irq-fix branch slave drives SNDMSG/RCVMSG over PIO byte primitives
# (transport_pio_send_byte / transport_pio_recv_byte in transport_pio.c)
# but keeps the SNIOS envelope (ENQ/ACK/SOH/STX/ETX/EOT framing).  Since
# mpm-net2 also speaks the SNIOS envelope on its TCP port, the slave
# byte stream and mpm-net2's wire stream are bit-identical — no host
# proxy required.  Just connect MAME's PIO-B bridge directly to :4002.
#
# This target uses the IRQ-fix MAME tree at ../../mame (branch
# pio-mpm-irq-fix), which has the cpnet_bridge gate fix that the
# stock master tree doesn't.
#
# Pass criterion: boot-strip column 18 = 'J' (NDOS COLDST reached) and
# clean A> on SIO-B.
MAME_IRQ ?= $(CURDIR)/../../mame
pio-irq-netboot: cpnos-install _check-tag-pio-irq _check-mame-irq
	@echo "=== 1/4 restarting MP/M with fresh disks ==="
	-screen -S mpm -X quit >/dev/null 2>&1 || true
	@sleep 1
	@if lsof -nP -iTCP:4002 -sTCP:LISTEN 2>/dev/null | grep -q .; then \
	    echo "ERROR: port 4002 already bound — kill the squatter first:"; \
	    lsof -nP -iTCP:4002 -sTCP:LISTEN; \
	    exit 1; \
	fi
	cd $(MPM_DIR) && screen -dmS mpm ./mpm-net2
	@echo "=== 2/4 waiting for MP/M CP/NET server on :4002 ==="
	@until nc -z 127.0.0.1 4002 2>/dev/null; do sleep 0.3; done
	@sleep 2
	@echo "=== 3/4 syncing ROMs to IRQ-fix MAME tree ==="
	cp $(MAME)/roms/rc702/roa375.ic66 $(MAME_IRQ)/roms/rc702/roa375.ic66
	cp $(MAME)/roms/rc702/prom1.ic65  $(MAME_IRQ)/roms/rc702/prom1.ic65
	@rm -f /tmp/cpnos_siob.raw /tmp/cpnos_screen.txt /tmp/cpnos_boot_marks.txt
	@echo "=== 4/4 launching MAME (PIO-B -> mpm-net2 :4002) ==="
	-$(MAME_IRQ)/regnecentralend rc702 -rompath $(MAME_IRQ)/roms \
	    -nothrottle -window -skip_gameinfo \
	    -seconds_to_run 30 \
	    -rs232a null_modem -bitb1 /tmp/cpnos_sioa.raw \
	    -rs232b null_modem -bitb2 /tmp/cpnos_siob.raw \
	    -piob cpnet_bridge \
	    -bitb3 socket.127.0.0.1:4002 \
	    -autoboot_script mame_porttap.lua
	@echo "--- boot-marker strip ---"
	@cat /tmp/cpnos_boot_marks.txt 2>/dev/null && echo
	@echo "--- SIO-B (printable) ---"
	@tr -cd '\11\12\15\40-\176' < /tmp/cpnos_siob.raw 2>/dev/null && echo
	@strip=$$(cat /tmp/cpnos_boot_marks.txt 2>/dev/null); \
	 if [ "$${strip:18:1}" = "J" ] && grep -q 'E>' /tmp/cpnos_siob.raw 2>/dev/null; then \
	     echo "PASS: NDOS COLDST reached (J) and E> seen on SIO-B"; \
	 else \
	     echo "FAIL: strip='$$strip', expected J at col 18 + 'E>' in SIO-B"; \
	     exit 1; \
	 fi

# ---- pio-irq-smoke: pio-irq-netboot + SUMTEST workload ------------
#
# Same wiring as pio-irq-netboot (PIO-B -> mpm-net2 :4002), but adds
# smoke_inject on SIO-B to drive m80 / l80 / sumtest.  This is the
# end-to-end verification path for the warm-boot port-0x81 OUT
# (commit b06e6dd) AND the sumtest port-0x80 done signal: each program
# exit overwrites CCP which warm-boots itself, firing port 0x81; the
# running sumtest emits port 0x80 at end-of-run.
#
# Pass criterion: port-0x80 written once (sumtest done) AND port-0x81
# written >= 3 times (m80, l80, sumtest each warm-boot CCP).
pio-irq-smoke: cpnos-install _check-tag-pio-irq _check-mame-irq
	@echo "=== 1/5 regenerating sumtest.asm + smoke disk ==="
	python3 testutil/mksmokeasm.py
	testutil/mksmokedisk.sh
	@echo "=== 2/5 restarting MP/M with fresh disks ==="
	-screen -S mpm -X quit >/dev/null 2>&1 || true
	@sleep 1
	@if lsof -nP -iTCP:4002 -sTCP:LISTEN 2>/dev/null | grep -q .; then \
	    echo "ERROR: port 4002 already bound"; \
	    lsof -nP -iTCP:4002 -sTCP:LISTEN; exit 1; \
	fi
	cd $(MPM_DIR) && screen -dmS mpm ./mpm-net2
	@until nc -z 127.0.0.1 4002 2>/dev/null; do sleep 0.3; done
	@sleep 2
	@echo "=== 3/5 syncing ROMs to IRQ-fix MAME tree ==="
	cp $(MAME)/roms/rc702/roa375.ic66 $(MAME_IRQ)/roms/rc702/roa375.ic66
	cp $(MAME)/roms/rc702/prom1.ic65  $(MAME_IRQ)/roms/rc702/prom1.ic65
	@rm -f /tmp/cpnos_siob.raw /tmp/cpnos_wboot.txt /tmp/cpnos_boot_result.txt \
	    /tmp/cpnos_smoke_inject.log /tmp/cpnos_boot_marks.txt
	@echo "=== 4/5 launching smoke_inject + MAME (workload: $(WORKLOAD)) ==="
	@python3 -u testutil/smoke_inject.py $(SMOKE_PORT) \
	    --workload $(WORKLOAD) \
	    --log /tmp/cpnos_siob.raw --timeout 240 \
	    > /tmp/cpnos_smoke_inject.log 2>&1 & \
	 echo $$! > /tmp/cpnos_smoke_inject.pid
	@sleep 0.4
	-$(MAME_IRQ)/regnecentralend rc702 -rompath $(MAME_IRQ)/roms \
	    -nothrottle -window -skip_gameinfo \
	    -seconds_to_run 1200 \
	    -rs232a null_modem -bitb1 /tmp/cpnos_sioa.raw \
	    -rs232b null_modem -bitb2 socket.127.0.0.1:$(SMOKE_PORT) \
	    -piob cpnet_bridge \
	    -bitb3 socket.127.0.0.1:4002 \
	    -autoboot_script mame_porttap.lua
	@kill $$(cat /tmp/cpnos_smoke_inject.pid) 2>/dev/null || true
	@$(MAKE) _verify-bench WORKLOAD=$(WORKLOAD)

# ---- pio-proxy-smoke: PIO-B raw OTIR/INIR via cpnet_pio_server proxy
#
# Slave is built with TRANSPORT=pio-proxy (cpnet_dispatch.c sets
# active_transport = &transport_pio_vt; transport_pio.c's pio_send_msg
# / pio_recv_msg use raw OTIR/INIR — no SNIOS envelope).  Host runs
# cpnet_pio_server.py --upstream 127.0.0.1:4002 on :4003 to translate
# raw frames into SIO envelope and forward to mpm-net2.
#
# Topology:
#   slave PIO-B --bitb3-> cpnet_pio_server :4003 -> mpm-net2 :4002
#   slave SIO-B --bitb2-> smoke_inject :SMOKE_PORT
#
# Same pass criterion / bench timing as pio-irq-smoke.
.PHONY: pio-proxy-smoke
pio-proxy-smoke:
	$(MAKE) _pio-proxy-smoke-impl TRANSPORT=pio-proxy WORKLOAD=$(WORKLOAD)

PIO_BRIDGE_PORT ?= 4003
_pio-proxy-smoke-impl: cpnos-install _check-tag-pio-prx _check-mame-irq
	@echo "=== 1/6 regenerating sumtest.asm + smoke disk ==="
	python3 testutil/mksmokeasm.py
	testutil/mksmokedisk.sh
	@echo "=== 2/6 restarting MP/M with fresh disks ==="
	-screen -S mpm -X quit >/dev/null 2>&1 || true
	@sleep 1
	@if lsof -nP -iTCP:4002 -sTCP:LISTEN 2>/dev/null | grep -q .; then \
	    echo "ERROR: port 4002 already bound"; \
	    lsof -nP -iTCP:4002 -sTCP:LISTEN; exit 1; \
	fi
	@if lsof -nP -iTCP:$(PIO_BRIDGE_PORT) -sTCP:LISTEN 2>/dev/null | grep -q .; then \
	    echo "ERROR: port $(PIO_BRIDGE_PORT) already bound"; \
	    lsof -nP -iTCP:$(PIO_BRIDGE_PORT) -sTCP:LISTEN; exit 1; \
	fi
	cd $(MPM_DIR) && screen -dmS mpm ./mpm-net2
	@until nc -z 127.0.0.1 4002 2>/dev/null; do sleep 0.3; done
	@sleep 2
	@echo "=== 3/6 spawning cpnet_pio_server --upstream localhost:4002 ==="
	@rm -f /tmp/cpnos_pio_server.log
	@python3 -u cpnet_pio_server.py $(PIO_BRIDGE_PORT) \
	    --upstream 127.0.0.1:4002 \
	    > /tmp/cpnos_pio_server.log 2>&1 & \
	 echo $$! > /tmp/cpnos_pio_server.pid
	@# Don't `nc -z` to verify — that connect-and-close trips the
	@# server's single-shot accept loop, leaving MAME's bitb3 connect
	@# refused.  Just give the listener time to bind.
	@sleep 1.0
	@echo "=== 4/6 syncing ROMs to IRQ-fix MAME tree ==="
	cp $(MAME)/roms/rc702/roa375.ic66 $(MAME_IRQ)/roms/rc702/roa375.ic66
	cp $(MAME)/roms/rc702/prom1.ic65  $(MAME_IRQ)/roms/rc702/prom1.ic65
	@rm -f /tmp/cpnos_siob.raw /tmp/cpnos_wboot.txt /tmp/cpnos_boot_result.txt \
	    /tmp/cpnos_smoke_inject.log /tmp/cpnos_boot_marks.txt
	@echo "=== 5/6 launching smoke_inject + MAME (workload: $(WORKLOAD)) ==="
	@python3 -u testutil/smoke_inject.py $(SMOKE_PORT) \
	    --workload $(WORKLOAD) \
	    --log /tmp/cpnos_siob.raw --timeout 240 \
	    > /tmp/cpnos_smoke_inject.log 2>&1 & \
	 echo $$! > /tmp/cpnos_smoke_inject.pid
	@sleep 0.4
	-$(MAME_IRQ)/regnecentralend rc702 -rompath $(MAME_IRQ)/roms \
	    -nothrottle -window -skip_gameinfo \
	    -seconds_to_run 1200 \
	    -rs232a null_modem -bitb1 /tmp/cpnos_sioa.raw \
	    -rs232b null_modem -bitb2 socket.127.0.0.1:$(SMOKE_PORT) \
	    -piob cpnet_bridge \
	    -bitb3 socket.127.0.0.1:$(PIO_BRIDGE_PORT) \
	    -autoboot_script mame_porttap.lua
	@kill $$(cat /tmp/cpnos_smoke_inject.pid) 2>/dev/null || true
	@kill $$(cat /tmp/cpnos_pio_server.pid)   2>/dev/null || true
	@$(MAKE) _verify-bench WORKLOAD=$(WORKLOAD)

# End-to-end netboot test: Python server on localhost, MAME bridged to
# it over SIO-A null_modem.
NETBOOT_PORT ?= 9000
SIOB_PORT    ?= 9001
SIOB_TRIGGER ?=
SIOB_INJECT  ?=
cpnos-netboot: cpnos-install
	@rm -f /tmp/cpnos_netboot_server.log /tmp/cpnos_siob.raw /tmp/cpnos_siob_driver.log
	@python3 -u netboot_server.py $(NETBOOT_PORT) > /tmp/cpnos_netboot_server.log 2>&1 & \
	 echo $$! > /tmp/cpnos_netboot_server.pid
	@python3 -u sio_b_driver.py $(SIOB_PORT) \
	    $(if $(SIOB_TRIGGER),--trigger '$(SIOB_TRIGGER)') \
	    $(if $(SIOB_INJECT),--inject '$(SIOB_INJECT)') \
	    > /tmp/cpnos_siob_driver.log 2>&1 & \
	 echo $$! > /tmp/cpnos_siob_driver.pid
	@sleep 0.3
	-$(MAME)/regnecentralend rc702 -rompath $(MAME)/roms \
	    -nothrottle -window -skip_gameinfo \
	    -seconds_to_run 70 \
	    -rs232a null_modem \
	    -bitb1 "socket.127.0.0.1:$(NETBOOT_PORT)" \
	    -rs232b null_modem \
	    -bitb2 "socket.127.0.0.1:$(SIOB_PORT)" \
	    -autoboot_script mame_boot_test.lua
	@kill $$(cat /tmp/cpnos_netboot_server.pid) 2>/dev/null || true
	@kill $$(cat /tmp/cpnos_siob_driver.pid) 2>/dev/null || true
	@echo "--- server log ---"
	@cat /tmp/cpnos_netboot_server.log
	@echo "--- SIO-B driver log ---"
	@cat /tmp/cpnos_siob_driver.log
	@echo "--- SIO-B capture (printable) ---"
	@tr -cd '\11\12\15\40-\176' < /tmp/cpnos_siob.raw 2>/dev/null || true
	@echo
	@echo "--- boot test ---"
	@cat /tmp/cpnos_boot_result.txt
	@grep -q '^PASS' /tmp/cpnos_boot_result.txt

# Step 1 of the smoke plan: ^C warm boot via SIO-B injection.
# Runs long enough for cold boot + ^C + full CCP.SPR reload, then
# asserts the server observed two OPEN events for CCP.SPR.
cpnos-warmboot-test: cpnos-install
	@rm -f /tmp/cpnos_netboot_server.log /tmp/cpnos_siob.raw /tmp/cpnos_siob_driver.log
	@python3 -u netboot_server.py $(NETBOOT_PORT) > /tmp/cpnos_netboot_server.log 2>&1 & \
	 echo $$! > /tmp/cpnos_netboot_server.pid
	@python3 -u sio_b_driver.py $(SIOB_PORT) \
	    --trigger 'E>' --inject '\x03' --timeout 30 \
	    > /tmp/cpnos_siob_driver.log 2>&1 & \
	 echo $$! > /tmp/cpnos_siob_driver.pid
	@sleep 0.3
	-$(MAME)/regnecentralend rc702 -rompath $(MAME)/roms \
	    -nothrottle -window -skip_gameinfo \
	    -seconds_to_run 25 \
	    -rs232a null_modem \
	    -bitb1 "socket.127.0.0.1:$(NETBOOT_PORT)" \
	    -rs232b null_modem \
	    -bitb2 "socket.127.0.0.1:$(SIOB_PORT)"
	@kill $$(cat /tmp/cpnos_netboot_server.pid) 2>/dev/null || true
	@kill $$(cat /tmp/cpnos_siob_driver.pid) 2>/dev/null || true
	@echo "--- server log (OPEN events) ---"
	@grep -E 'opened|FNC=0x0f' /tmp/cpnos_netboot_server.log || true
	@echo "--- SIO-B driver log ---"
	@cat /tmp/cpnos_siob_driver.log
	@echo "--- SIO-B capture (printable) ---"
	@tr -cd '\11\12\15\40-\176' < /tmp/cpnos_siob.raw 2>/dev/null || true
	@echo
	@echo "--- assertion ---"
	@n=$$(grep -cE '    opened ' /tmp/cpnos_netboot_server.log); \
	 echo "CCP.SPR OPEN count: $$n"; \
	 [ "$$n" -ge 2 ] || { echo 'FAIL: expected >= 2 OPEN events'; exit 1; }; \
	 echo 'PASS: warm boot re-fetched CCP.SPR'

# Auto-run a canned CP/NOS session via $70.SUB (native CP/M batch
# mechanism — the server seeds the SUB file, CCP reads+executes it
# at the first prompt, then deletes it).  Pass commands pipe-separated:
#   make cpnos-sub-test CPNOS_SUB='dir'
#   make cpnos-sub-test CPNOS_SUB='dir|pip foo.txt=login.com|dir'
# Asserts that the SUB file is opened (proving execution) and that
# afterwards CCP is idle at the prompt (no SNIOS traffic for >2 s).
CPNOS_SUB ?= dir
cpnos-sub-test: cpnos-install
	@rm -f /tmp/cpnos_netboot_server.log /tmp/cpnos_siob.raw /tmp/cpnos_siob_driver.log /tmp/cpnos_boot_result.txt
	@CPNOS_SUB='$(CPNOS_SUB)|done' python3 -u netboot_server.py $(NETBOOT_PORT) > /tmp/cpnos_netboot_server.log 2>&1 & \
	 echo $$! > /tmp/cpnos_netboot_server.pid
	@python3 -u sio_b_driver.py $(SIOB_PORT) --timeout 30 \
	    > /tmp/cpnos_siob_driver.log 2>&1 & \
	 echo $$! > /tmp/cpnos_siob_driver.pid
	@sleep 0.3
	-$(MAME)/regnecentralend rc702 -rompath $(MAME)/roms \
	    -nothrottle -window -skip_gameinfo \
	    -seconds_to_run 70 \
	    -rs232a null_modem \
	    -bitb1 "socket.127.0.0.1:$(NETBOOT_PORT)" \
	    -rs232b null_modem \
	    -bitb2 "socket.127.0.0.1:$(SIOB_PORT)" \
	    -autoboot_script mame_sub_test.lua
	@kill $$(cat /tmp/cpnos_netboot_server.pid) 2>/dev/null || true
	@kill $$(cat /tmp/cpnos_siob_driver.pid) 2>/dev/null || true
	@echo "--- SIO-B (printable) ---"
	@tr -cd '\11\12\15\40-\176' < /tmp/cpnos_siob.raw | sed 's/$$/ /'
	@echo
	@echo "--- result ---"
	@cat /tmp/cpnos_boot_result.txt 2>/dev/null || echo '(no result file)'
	@grep -q '^PASS' /tmp/cpnos_boot_result.txt

# ---- CONOUT acid test --------------------------------------------
#
# Builds testutil/acid.com with z88dk (+cpm), boots CP/NOS via
# netboot_server.py with CPNOS_SUB='acid' so CCP runs it at first
# prompt, then mame_acid_test.lua dumps the 8275 display RAM at
# 0xF800 and asserts the known pixel pattern the 15 RC700 control
# codes are supposed to produce.
#
# Finish marker: the .COM emits "DONE\r\n" through BIOS CONOUT,
# which mirrors to SIO-B -- same gate as mame_sub_test.lua.
Z88DK_ROOT = $(CURDIR)/../z88dk
Z88DK_ZCC  = $(Z88DK_ROOT)/bin/zcc
testutil/acid.com: testutil/acid.c
	cd testutil && \
	    PATH=$(Z88DK_ROOT)/bin:$$PATH \
	    ZCCCFG=$(Z88DK_ROOT)/lib/config \
	    zcc +cpm --opt-code-size \
	    -create-app -o acid acid.c
	@echo "built testutil/acid.com ($$(wc -c < testutil/acid.com | tr -d ' ') B)"

conout-acid: cpnos-install testutil/acid.com
	@rm -f /tmp/cpnos_netboot_server.log /tmp/cpnos_siob.raw /tmp/cpnos_siob_driver.log /tmp/cpnos_boot_result.txt /tmp/cpnos_display.txt
	@CPNOS_SUB='acid|done' python3 -u netboot_server.py $(NETBOOT_PORT) > /tmp/cpnos_netboot_server.log 2>&1 & \
	 echo $$! > /tmp/cpnos_netboot_server.pid
	@python3 -u sio_b_driver.py $(SIOB_PORT) --timeout 90 \
	    > /tmp/cpnos_siob_driver.log 2>&1 & \
	 echo $$! > /tmp/cpnos_siob_driver.pid
	@sleep 0.3
	-$(MAME)/regnecentralend rc702 -rompath $(MAME)/roms \
	    -nothrottle -window -skip_gameinfo \
	    -seconds_to_run 100 \
	    -rs232a null_modem \
	    -bitb1 "socket.127.0.0.1:$(NETBOOT_PORT)" \
	    -rs232b null_modem \
	    -bitb2 "socket.127.0.0.1:$(SIOB_PORT)" \
	    -autoboot_script mame_acid_test.lua
	@kill $$(cat /tmp/cpnos_netboot_server.pid) 2>/dev/null || true
	@kill $$(cat /tmp/cpnos_siob_driver.pid) 2>/dev/null || true
	@echo "--- display dump ---"
	@cat /tmp/cpnos_display.txt 2>/dev/null || echo '(no display dump)'
	@echo "--- result ---"
	@cat /tmp/cpnos_boot_result.txt 2>/dev/null || echo '(no result file)'
	@grep -q '^PASS' /tmp/cpnos_boot_result.txt

# PolyPascal regression: drive cpnos through "PPAS PRIMES" / "R" / "Q"
# (PPAS is the PolyPascal interpreter command), verify primes are
# printed (looks for the last prime, 29989), and verify Q returns to
# the CCP E> prompt.  Forces MIRROR_SIOB=1 so the Lua script can
# scrape /tmp/cpnos_siob.raw for completion markers.  MP/M is
# restarted from scratch so the run is hermetic.
cpnos-polypascal-test:
	@echo "=== 1/4 (re)starting MP/M with fresh disks ==="
	-screen -S mpm -X quit >/dev/null 2>&1 || true
	@sleep 1
	@if lsof -nP -iTCP:4002 -sTCP:LISTEN 2>/dev/null | grep -q .; then \
	    echo "ERROR: port 4002 already bound -- kill the squatter first:"; \
	    lsof -nP -iTCP:4002 -sTCP:LISTEN; \
	    exit 1; \
	fi
	cd $(MPM_DIR) && screen -dmS mpm ./mpm-net2
	@echo "=== 2/4 waiting for MP/M CP/NET server on :4002 ==="
	@until nc -z 127.0.0.1 4002 2>/dev/null; do sleep 0.3; done
	@sleep 2
	@echo "=== 3/4 building cpnos-rom with MIRROR_SIOB=1 + installing ==="
	$(MAKE) MIRROR_SIOB=1 cpnos-install
	@rm -f /tmp/cpnos_siob.raw /tmp/cpnos_sioa.raw \
	       /tmp/cpnos_polypascal_log.txt /tmp/cpnos_polypascal_result.txt
	@echo "=== 4/4 syncing ROMs to IRQ-fix MAME tree ==="
	cp $(MAME)/roms/rc702/roa375.ic66 $(MAME_IRQ)/roms/rc702/roa375.ic66
	cp $(MAME)/roms/rc702/prom1.ic65  $(MAME_IRQ)/roms/rc702/prom1.ic65
	@echo "=== generating clang/cpnos_polypascal_addrs.lua from payload.elf ==="
	@KH=$$($(NM) clang/payload.elf | awk '/_kbd_head$$/{print $$1}'); \
	 KR=$$($(NM) clang/payload.elf | awk '/_kbd_ring$$/{print $$1}'); \
	 [ -n "$$KH" ] && [ -n "$$KR" ] || { echo "ERROR: kbd_head/kbd_ring missing from payload.elf"; exit 1; }; \
	 printf 'return {\n  kbd_head = 0x%s,\n  kbd_ring = 0x%s,\n}\n' "$$KH" "$$KR" \
	   > clang/cpnos_polypascal_addrs.lua
	@cat clang/cpnos_polypascal_addrs.lua
	@echo "=== launching MAME with PolyPascal test driver (max ~4 min) ==="
	-$(MAME_IRQ)/regnecentralend rc702 -rompath $(MAME_IRQ)/roms \
	    -nothrottle -window -skip_gameinfo \
	    -seconds_to_run 240 \
	    -rs232a null_modem -bitb1 /tmp/cpnos_sioa.raw \
	    -rs232b null_modem -bitb2 /tmp/cpnos_siob.raw \
	    -piob cpnet_bridge \
	    -bitb3 socket.127.0.0.1:4002 \
	    -autoboot_script mame_polypascal_test.lua
	@echo "--- polypascal-test log tail ---"
	@tail -30 /tmp/cpnos_polypascal_log.txt 2>/dev/null
	@echo "--- result ---"
	@cat /tmp/cpnos_polypascal_result.txt 2>/dev/null || echo '(no result file)'
	@grep -q '^PASS' /tmp/cpnos_polypascal_result.txt 2>/dev/null

# Interactive: boot CP/NOS, leave MAME running at the E> prompt so a
# human can type on the native keyboard (PIO-A path).  SIO-B output
# still streams to /tmp/cpnos_siob.raw so the other side can watch
# what got typed + echoed.  Exit by closing the MAME window (Esc).
cpnos-interactive: cpnos-install
	@rm -f /tmp/cpnos_netboot_server.log /tmp/cpnos_siob.raw /tmp/cpnos_siob_driver.log
	@python3 -u netboot_server.py $(NETBOOT_PORT) > /tmp/cpnos_netboot_server.log 2>&1 & \
	 echo $$! > /tmp/cpnos_netboot_server.pid
	@python3 -u sio_b_driver.py $(SIOB_PORT) --timeout 3600 \
	    > /tmp/cpnos_siob_driver.log 2>&1 & \
	 echo $$! > /tmp/cpnos_siob_driver.pid
	@sleep 0.3
	@echo "netboot server pid=$$(cat /tmp/cpnos_netboot_server.pid)"
	@echo "sio-b driver  pid=$$(cat /tmp/cpnos_siob_driver.pid)"
	@echo "Watch typed output:  tail -f /tmp/cpnos_siob.raw"
	-$(MAME)/regnecentralend rc702 -rompath $(MAME)/roms \
	    -window -skip_gameinfo \
	    -rs232a null_modem \
	    -bitb1 "socket.127.0.0.1:$(NETBOOT_PORT)" \
	    -rs232b null_modem \
	    -bitb2 "socket.127.0.0.1:$(SIOB_PORT)"
	@kill $$(cat /tmp/cpnos_netboot_server.pid) 2>/dev/null || true
	@kill $$(cat /tmp/cpnos_siob_driver.pid) 2>/dev/null || true

# CPU trace: captures every executed instruction to /tmp/cpnos_trace.log.
# Use for debugging control-flow issues.  Pipe through tail or head to
# avoid filling the disk (per project memory).
cpnos-trace: cpnos-install
	$(MAME)/regnecentralend rc702 -rompath $(MAME)/roms \
	    -nothrottle -window -skip_gameinfo \
	    -seconds_to_run 2 \
	    -autoboot_script mame_boot_test.lua \
	    -debug -debugscript trace.dbg
	@echo "trace written to /tmp/cpnos_trace.log"

# Source-interleaved disassembly (requires -g, enabled in CFLAGS).
# The -S flag interleaves the original C lines with emitted Z80 asm.
cpnos-lis: clang/payload.elf
	$(OBJDUMP) -d -S -r --symbolize-operands --triple=z80 $< > clang/cpnos.lis
	@echo "wrote clang/cpnos.lis (with C source + symbol-resolved operands)"

cpnos-map: clang/payload.elf
	$(NM) --numeric-sort $<

# Note: per-TU listings from .o files don't work reliably because
# unlinked object files have incomplete DWARF (relocations unresolved
# until link).  The linked-ELF listing from cpnos-lis gives the same
# C-source-interleaved output for the whole program; see it there.

# ---- CP/NET fast-link MAME bridge smoke test ---------------------
# Prerequisite: ravn/mame:cpnet-fast-link branch built; a CP/NET
# server (z80pack on :4002) running so cpnos-rom actually loads via
# netboot in MAME — without it the Z80 sits in the autoload PROM and
# isr_pio_par never gets a chance to fire.  See
# ../tests/cpnet_bridge/README.md for the full prereq list.
cpnet-mame-test: cpnos
	cd .. && python3 tests/cpnet_bridge/harness.py

# ---- Clean --------------------------------------------------------

cpnos-clean:
	rm -rf clang
