# BIOS-in-C Phase Tracker

## Completed Phases
- **Phase 1a**: Skeleton (builds, correct binary layout)
- **Phase 1b**: CRT display refresh ISR and keyboard input
- **Phase 1d**: CONOUT display driver with escape sequences
- **Phase 1e**: Floppy disk driver (blocking/deblocking, multi-density T0, verified 4 images)
- **Phase 1f**: Boot sequence — CP/M boots to A> prompt on MAXI 8" disk

## Remaining Work

### SIO serial ring buffer (READI)
- [ ] Arm SIO Ch.A receiver for serial ring buffer in cold boot
- [ ] Enable RTS flow control

### MINI (5.25") support
- [ ] Currently 513 bytes over MINI limit (6657 vs 6144)
- [ ] Optimize code size or conditionally exclude features

### Integration testing — BUG: TYPE/STAT/ASM produce no output
- [x] DIR works correctly (lists files on maxi 8" disk)
- [x] Warm boot works (loads CCP+BDOS from track 1)
- [ ] **BUG**: TYPE, STAT, ASM produce no output — they read 2 directory sectors, get all-E5, then warm boot
- [ ] Test with MINI disk images

#### Debug findings (2026-03-09)
The MAME Lua trace script (`mame_fdc_trace.lua`) captures BIOS READ calls via
a BSS debug buffer (dbg_idx at 0xDFE1, dbg_buf at 0xDFE2, 252 bytes / 63 entries).

**What works:**
- Cold boot: loads CCP+BDOS from track 1 sectors 0-43 → C400-D9FF. OK.
- Warm boot: same 44-sector load. OK.
- DIR: lists files correctly (uses BDOS Search First/Next, functions 17/18).
- Screen output: clean, no garbage (earlier FE00 debug writes removed).

**What fails:**
- TYPE DUMP.ASM: reads trk=2 sec=0 (dma=DE35) and sec=1 (dma=DE35), then
  immediately warm boots. DIRBF is all 0xE5 (empty). No file data reads.
- STAT and ASM also produce no output and silently return to A> prompt.
- These commands use BDOS Open (15) + Read Sequential (20), unlike DIR which
  uses Search First/Next (17/18).

**Verified correct:**
- DMA port programming: instruction-by-instruction match with original BIOS.
  Ports FA(smsk), FB(mode), FC(clbp), F2(ch1 addr lo/hi), F3(ch1 wc lo/hi), FA(unmask).
  DI/EI wraps all 8 port writes.
- DMA target: `fdc_dma_addr` only ever set to `&hstbuf[0]` (line 296 in chktrk).
- Deblocking math: deblock_shift=3 → 2 right shifts (divide by 4, correct for 512B sectors).
  deblock_mask=3 → offset = (cpm_sector & 3) << 7 (0/128/256/384). Correct.
- Sector translation: xlt_maxi_512[0]=1 maps host sector 0 to FDC sector 1. Correct.
- wboot_c calls bios_seldsk_c(0) at start and again before jumping to CCP.

**Hypotheses to investigate:**
1. FDC returns wrong data for track 2 directory sectors (different from what DIR reads).
   Need to compare: run DIR first (capture its trace), then TYPE (capture its trace).
   The comparative Lua test is prepared but not yet executed.
2. The BDOS Open codepath reads directory differently than Search First/Next.
   Both should read the same physical sectors, but the processing differs.
3. hstbuf might contain stale/wrong data after the track 2 read — need to dump
   hstbuf contents in the Lua script after directory reads.
4. erflag (disk error flag) might be set, causing hstact=0, which forces re-reads
   that also fail — need to trace erflag.

**Debug infrastructure in bios.c (temporary, remove when done):**
- `dbg_idx` (uint8_t) and `dbg_buf[252]` (static BSS) — trace ring buffer
- `dbg_trace_read()` — called at entry of rwoper(), logs cpm_track/cpm_sector/cpm_dma_addr
- Lua script resets dbg_idx=0 after each A> prompt to separate command traces

### Code quality
- [ ] Audit all BIOS wrappers returning uint16_t for DE→HL sdcccall(1) correctness
- [ ] Consider replacing assembly interrupt wrappers with __interrupt C functions
- [ ] **Dynamic disk_parameter_header table size**. Currently `dph_table[2]` is hardcoded (2 drives max
      — see `disk_parameter_header dph_table[2]` and `if (drno >= 1)` guard in bios_hw_init.c). Should
      scale to all configured drives per `fd0[]` (up to 16 entries). Requires:
      - disk_parameter_header array sized from `CFG.infd` non-0xFF count (compile-time or BSS)
      - Init loop in bios_hw_init.c instead of hand-rolled dph0/dph1
      - Matching BSS size bump for chk0..chk15, all0..all15 (or merged arrays)
      - Check CP/M assumption that disk_parameter_header block is linear in memory

### Session 16 (2026-04-15/16) — type correctness and baud prep
- [x] fdc_dma_addr: word → byte* (−35B clang, partial-constant-fold fix)
- [x] cpm_dma_addr: word → byte* (0B clang, +4B sdcc, semantic cleanup)
- [x] BUFF → BDOS_DMAADDR with (byte *) type; CCP_BASE typed
- [x] FSPA/disk_parameter_header const-correct (void* → typed fields; 6 casts removed)
- [x] bios_seldsk_c returns disk_parameter_header* (not word)
- [x] Default SIO-A and SIO-B to 38400 ×1 (CTC count=16, WR4=0x04)
      prep for 76800/115200 on real hardware — only CTC count changes
- [x] siob-baud test harness: auto-extract BSS addresses from bios.elf
- [x] llvm-z80#71: SRL A → RRCA when followed by AND mask (−13B clang)

### Session 16 — open follow-ups
- [ ] **Test 76800 / 115200 on physical RC700 hardware**
      MAME ×1 receive at >38400 fails (null_modem TX sends bytes but
      Z80-DART doesn't receive them). Real HW should work per Z80-SIO
      datasheet (×1 up to ~880 kbaud). Needs the FTDI cable.
- [ ] Investigate MAME Z80-DART ×1 receive at >38400 baud.
      Null_modem confirmed to transmit at 76800 (22 bytes read from TCP
      stream), but ring buffer stays empty. Filed upstream? Need to
      check MAME mailing list / issue tracker before filing.
- [ ] PROM rom.c: review typed address #defines (BOOT_DIR_OFF, etc.)
      for same treatment as CCP_BASE/BDOS_DMAADDR — may remove more casts.
- [ ] ravn/z88dk#2: SDCC uses byte-wise LD a,(nn) for const pointer
      copies instead of LD rr,(nn) — ~2-4B per site. Consider adding
      SDCC peephole in z88dk's sdcc fork if small.

### Session 17 (2026-04-16) — readability and naming pass
- [x] Clang -std=c23 adopted; all compiler warnings eliminated (5 clang, 5 SDCC)
- [x] FDC register vocabulary moved to bios.h: FDC_MSR_*, FDC_ST0_* named constants
      replace 9 raw binary patterns in bios.c + bios_hw_init.c
- [x] Comprehensive FDC result-phase documentation at fdc_read_result() —
      per-command byte layout + ST0/ST1/ST2/ST3 bit definitions
- [x] Major variable rename pass — 25+ CP/M cryptic 5-char mnemonics replaced
      with descriptive names (cpm_disk/track/sector, hostbuf_*, last_seek_*,
      unalloc_*, fdc_track/sector, current_format*, need_pre_read, is_read)
- [x] ISR helper renames: fl_flg/clfit/watir/wfitr → fdc_irq_fired/arm/wait/
      wait_rearm. Also: rstab→fdc_result, fdc_result()→fdc_read_result()
- [x] Type rename: DPB→disk_parameter_block, DPH→disk_parameter_header;
      .dpb field kept short (CP/M idiom, avoids type/field collision)
- [x] Disk format table rename: tran0/8/16/24 → xlt_maxi_128/512/mini_512/
      xlt_identity; dpb0/8/16/24 → dpb_maxi_128/512/mini_512/maxi_256
- [x] sec_rw loop: goto→for loop with break; static BSS `repet` preserved
- [x] Skew table build-time verification (verify_skew.py) — analog of DRI
      XLT macro; hooked into Makefile as bios-target prerequisite
- [x] MAME boot verified after rename: clang build loads SW1711-I8, reaches
      A> prompt, 2685 sectors zero errors

### Session 17 — open follow-ups
- [ ] FSPA initializer at bios.c:112-115 still positional. With renamed
      fields, designated initializers (.dpb = ..., .records_per_alloc_block
      = ...) would be more self-documenting. Verify SDCC accepts designated
      init before switching.
- [ ] Audit remaining short-name variables for clarity: `drno` (now
      `max_drive_num`) was a good case; are there others like `erflag`,
      `hstact`, `hstwrt`, `prtflg`, `ptpflg`, `cerflg`, `delcnt` that
      should also be renamed?
- [ ] `rsflag` semantic verification — currently interpreted as
      "pre-read required". Trace through rwoper() to confirm the
      three-state-flag semantics (0/1/secmsk) matches the documented
      CP/M deblocking algorithm.
- [ ] Consider migrating DRI `OS2CCP.ASM` / `OS3BDOS.ASM` to the z88dk
      assembler at build time so `make all` produces CCP+BDOS.cim
      alongside the BIOS (currently only the BIOS is built; CCP+BDOS
      comes from an existing disk image).
- [ ] Build-time TCAP verification: once ZCPR3 integration happens,
      add a verify script for cpm/rc700_z3termcap.h analogous to
      verify_skew.py, checking CP/M TCAP field layout matches manual §7.2.

### Build CCP+BDOS from source and inject on track 1
- [ ] Assemble `cpm/OS2CCP.ASM` (CCP) and `cpm/OS3BDOS.ASM` (BDOS)
      from DRI CP/M 2.2 sources. Reference: https://www.jbox.dk/rc702/index.shtm
      Pick an assembler that matches DRI syntax (zmac --dri, MAC, or m80)
      and figure out the origin flags: CCP origin = 0xC400, BDOS follows.
- [ ] Figure out the RC702 track-1 layout for CCP+BDOS (the bytes
      that the warm-boot BIOS reads back into 0xC400-0xD9FF — 44
      sectors × 128 bytes = 5632 bytes per current BIOS).
- [ ] Compare our build's output against what's already on working
      RC702 system disks (e.g. SW1711-I8.imd). Expect byte-match
      except serial number field — identify where serial lives.
- [ ] Write a tool (or extend patch_bios.py in ../rcbios/) to inject
      CCP+BDOS.bin onto track 1 of a disk image for MAME boot test.
- [ ] Verify warm boot from an injected disk image reaches A> prompt
      without errors.

### Replace CCP with ZCPR3.x / Z-System

**Terminology (verified 2026-04-16):**
- **ZCPR3** — CCP-only replacement. ~2KB, same slot as stock DRI CCP.
  Introduced 1984 by Richard Conn. Current/final version is 3.4.
- **ZRDOS** — BDOS replacement, Z80-optimized. ~3.5KB (14 pages).
  Same slot as stock BDOS. Commercial, from Echelon.
- **Z-System** (commercial) — ZCPR3 + ZRDOS bundle from Echelon.
  Total ~5.5KB, same total slot as CCP+BDOS.
- **NZ-COM** — automatic Z-System installer. Runs as `.COM` on CP/M 2.2,
  no BIOS changes required. Good for initial experimentation.

**RC702 track-1 budget:** 5632 bytes (44 × 128B sectors) for CCP+BDOS
loaded at 0xC400. Stock DRI fills it exactly (CCP 2048 + BDOS 3584).
ZCPR3+ZRDOS has the same footprint → should fit without BIOS changes.

**ZCPR3 system segments** (optional — disable for minimal install):
- ENV/Z3T — Environment Descriptor (256B): 128B environ (dynamic,
  zeroed at cold boot) + ~32B TCAP (static terminal table) + other
- RCP (Resident Command Package — built-in commands in RAM)
- FCP (Flow Command Package — IF/ELSE/XIF, 128B zero-init by BIOS)
- NDR (Named Directory Register)
- IOP (I/O Package — custom device redirection)
These live in memory ABOVE BDOS, not in the track-1 load. Full support
requires BIOS cold boot to zero-fill and relocate segment buffers.
A minimal ZCPR3 without segments behaves as a plain better-CCP and
needs no RC702 BIOS changes.

**TCAP in BIOS**: Since RC702 has a fixed display (8275 + our escape
sequences), the ZCPR3 TCAP can be compiled statically into the BIOS
image at a known RAM address, with the ENV pointer patched into the
CCP at build/install time. Skips the `*.Z3T` file-loading path entirely.
Cold boot still zeroes the 128B environ portion; the TCAP is static data.

User-supplied RC702 TCAP files (in `cpm/`):
- `cpm/rc700_z3termcap.h` — annotated C source, name field "RC700",
  all other bytes byte-identical to rc700.z3t. THIS is the canonical
  form; the .z3t binaries below are vendor reference.
- `cpm/rc700.z3t` — original binary, name "Rc700 patched3" + 2-byte
  vendor tag (80×24, CLS=0x0C, home=0x1E, `%r%+ %+ ` cursor positioning).
- `cpm/rc700gr.z3t` — original binary, graphics variant (name
  "Rc700 patched7", differs at offsets 0x25-0x29 for SO/SE highlight
  codes that enable the display's attribute mode).

Integration: `#include "cpm/rc700_z3termcap.h"` from a BIOS module
to get `static const unsigned char rc702_tcap[128]`. Point the ZCPR3
Environment Descriptor's TCAP slot at this symbol. No `.Z3T` loader
needed. Header contains a WARNING comment listing specific capability
bytes that should be verified against actual RC702 behavior before
trusting (the original was written long ago, not reviewed since).

**Staged plan:**
- [ ] **Stage 1 — NZ-COM quick-test**: boot stock RC702 CP/M, copy
      NZCOM.COM + NZCOM.LBR, run `NZCOM` from A>. No BIOS changes.
      Proves the hardware path and lets us try the command-line gains
      (aliases, history, named dirs) before committing.
- [ ] **Stage 2 — minimal ZCPR3 as CCP-only swap**: build ZCPR3 with
      segments disabled (fits 2048B CCP slot), inject via track-1 tool
      from prior task. Stock RC702 BIOS should load it unchanged.
- [ ] **Stage 3 — ZCPR3+ZRDOS full swap**: replace both CCP and BDOS
      on track 1. Still fits 5632B budget. Verify BIOS syscall handlers
      still work (ZRDOS is 2.2-ABI-compatible per docs).
- [ ] **Stage 4 — enable system segments**: extend our rcbios to
      zero-init FCP buffer during cold boot, reserve RAM for ENV/RCP/
      NDR/TCAP. This unlocks aliases, named dirs, terminal abstraction.
      Likely requires BSS layout changes and new CONFI fields.

**Sources:**
- NZ-COM manual: http://gaby.de/ftp/pub/cpm/nzcom.pdf
- ZCPR3 installation manual: https://oldcomputers.dyndns.org/public/pub/manuals/zcpr/zcpr3_installation_manual.pdf
- ZCPR 3.3 User's Guide (Jay Sage): http://gaby.de/ftp/pub/cpm/znode51/specials/manuals/zcpr3.pdf
- Z-System downloads (Gaby): http://www.gaby.de/edownf.htm
