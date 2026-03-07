# RC700-SYSGEN Project Timeline

## Phase 1: SYSGEN Reconstruction (Apr-May 2023)
- **2023-04-28**: Initial commit. SYSGEN.ASM from CP/M 2.2 source, RCSYSGEN.COM from RC702 system
- **2023-04-28**: MAC assembler chosen (Digital Research native CP/M assembler)
- **2023-04-29**: SYSGEN.COM byte-identical to RCSYSGEN.COM — first byte-exact reconstruction
- **2023-04-29**: Multi-density track/sector mapping documented (mini/maxi translation tables)
- **2023-05-07**: Added SYSTEM.ORG for reference comparisons

## Phase 2: Toolchain Modernization (Sep 2025)
- **2025-09-21**: Added zmac assembler (macOS native) — cross-assembly without CP/M emulator
- **2025-09-21**: Toolchain decision: zmac with DRI syntax compatibility over MAC under emulation

## Phase 3: ROA375 Boot PROM (Jun 2025, then Feb 2026)
- **2025-06-29**: Added ROA375 autoload PROM binary and ROB358 (RC703 variant) source reference
- **2026-02-08**: Ghidra seeding script for ROM analysis; Makefile for SYSGEN
- **2026-02-08**: Fresh ROM disassembly started with PORT14 documentation
- **2026-02-09**: Byte-exact disassembly of ROA375 achieved (z80dasm + manual cleanup)
- **2026-02-10**: Raw disassembly converted to annotated style with EQUs and labels
- **2026-02-11**: CLAUDE.md created; rob358.mac adapted for zmac
- **2026-02-14**: Systematic documentation: port values, CRT work area, comment style standardized

## Phase 4: ROA375 C Rewrite (Feb 16-19, 2026)
- **2026-02-16**: Architectural decision: rewrite ROA375 in C using z88dk with sdcc backend
- **2026-02-16**: z88dk toolchain added; autoload-in-c/ scaffold created
- **2026-02-16**: Full C implementation: boot logic, FDC driver, HAL abstraction, host tests
- **2026-02-17**: Code too large for 2KB PROM — all C moved to hand-written assembly
- **2026-02-17**: Key decision: switch to sdcccall(1) ABI — params in A/HL/DE
- **2026-02-17**: Reversed course: globals-only C experiment showed sdcc can be small enough
- **2026-02-18**: Progressive migration back to C: boot7, hal_delay, init functions
- **2026-02-18**: Final result: 1984 bytes (64 to spare), boots in rc700 emulator
- **2026-02-19**: CRT/display interrupt handler documented and renamed

## Phase 5: CP/M BIOS Reverse Engineering (Feb 19-21, 2026)
- **2026-02-19**: BIOS RE analysis started — imd2raw.py extracts Track 0 from disk images
- **2026-02-20**: jbox.dk rel.2.1 BIOS sources obtained — modular structure identified
- **2026-02-20**: 58K Compas BIOS disassembled from disk image, byte-verified
- **2026-02-20**: verify_bios.py created for automated BIOS verification
- **2026-02-21**: patch_bios.py, imdinfo.py tools created for disk image manipulation
- **2026-02-21**: Conditional assembly restructured: COMPAS renamed to REL14
- **2026-02-21**: CONFI.COM reverse engineered (SIO label swap bug discovered)

## Phase 6: BIOS Source Reconstruction — All 13 Variants (Feb 21 - Mar 1, 2026)
- **2026-02-21**: rel.2.3 MAXI build added; RC703 analysis began
- **2026-02-24**: PHE358A.MAC analyzed (RC702E variant PROM with RAM disk)
- **2026-02-25**: bin2imd.py: RC703 format support added
- **2026-02-27**: 14 unique BIOSes extracted from 20 disk images
- **2026-02-27**: MAME boot testing: UPD765 ST0 HD bit regression discovered
- **2026-02-28**: REL20 conditional assembly added — 5 variants from shared source
- **2026-03-01**: All 13 BIOS variants byte-verified:
  - src/ (shared): REL20, REL21, REL22, REL23-mini, REL23-maxi (5)
  - src-58k/: REL13-mini, REL14-mini, REL14-maxi (3)
  - src-rc703/: REL10, REL12, RELTFj (3)
  - src-rc702e/: REL201-mini, REL220-QD (2)

## Phase 7: REL30 New BIOS Development (Mar 1-3, 2026)
- **2026-03-01**: BIOS rel.3.0 created — new features, not a reconstruction
- **2026-03-01**: SIO ring buffer (256B, page-aligned) + PIO keyboard ring buffer (16B)
- **2026-03-01**: 8-N-1 at 38400 baud on SIO Channel A (was 7-E-1 at 1200)
- **2026-03-01**: Bidirectional serial verified: PIP file transfer byte-identical
- **2026-03-02**: RTS flow control with hysteresis (deassert at 248, re-assert at 240)
- **2026-03-02**: AUTOEXEC.COM disassembled; run_mame.sh automation script
- **2026-03-03**: Ring buffer optimization: register-cached TAIL, parametric size
- **2026-03-03**: SCROLL optimization: unrolled LDIR into 16-wide LDI loop (20% faster)

## Phase 8: CP/NET Implementation (Mar 6, 2026)
- **2026-03-06**: CP/NET test infrastructure with --inject and --serial-transfer modes
- **2026-03-06**: CP/NET server: BDOS function handlers (F14-F23, F28, F30, F33-F35, F39, F40, F70)
- **2026-03-06**: File transfer proven: 204KB, 1600 records, zero packet loss at 38400 baud
- **2026-03-06**: SNIOS hex-encoded CRC-16 protocol working

## Phase 9: RC702E Modular Source (Mar 7, 2026)
- **2026-03-07**: RC702E BIOS split into modular source files (current branch: rc702e-modular)
- **2026-03-07**: Work area 0xFFD0-0xFFFF mapped with ORG+DS layout

## Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| zmac over MAC | Cross-assemble on macOS without CP/M emulator |
| z88dk/sdcc for C rewrite | Only Z80 C compiler that fits 2KB PROM constraint |
| sdcccall(1) ABI | 36% smaller code than sccz80, params in registers |
| Byte-exact reconstruction | Proves understanding of original code; enables verification |
| Conditional assembly | Single source tree for 5 BIOS variants (src/) |
| Separate source trees | 58K, RC703, RC702E too different for conditional assembly |
| Ring buffers in REL30 | Enable reliable serial at 38400 baud for CP/NET |
| verify_bios.py approach | Compares code bytes only, ignoring runtime-modified variables |
| patch_bios.py | Direct IMD patching avoids SYSGEN round-trip |

## Key Tools Created

| Tool | Purpose |
|------|---------|
| verify_bios.py | Verify assembled BIOS against reference binaries |
| patch_bios.py | Patch assembled BIOS onto IMD disk images |
| imdinfo.py | Show disk image summary (format, geometry, boot status) |
| imd2raw.py | Extract raw Track 0 from IMD images |
| bin2imd.py | Convert raw BIN to IMD format (mini, maxi, RC703) |
| run_mame.sh | Automated build+patch+launch cycle for MAME testing |
