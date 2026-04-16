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
- DMA target: `dskad` only ever set to `&hstbuf[0]` (line 296 in chktrk).
- Deblocking math: secshf=3 → 2 right shifts (divide by 4, correct for 512B sectors).
  secmsk=3 → offset = (seksec & 3) << 7 (0/128/256/384). Correct.
- Sector translation: tran8[0]=1 maps host sector 0 to FDC sector 1. Correct.
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
- `dbg_trace_read()` — called at entry of rwoper(), logs sektrk/seksec/dmaadr
- Lua script resets dbg_idx=0 after each A> prompt to separate command traces

### Code quality
- [ ] Audit all BIOS wrappers returning uint16_t for DE→HL sdcccall(1) correctness
- [ ] Consider replacing assembly interrupt wrappers with __interrupt C functions

### Session 16 (2026-04-15/16) — type correctness and baud prep
- [x] dskad: word → byte* (−35B clang, partial-constant-fold fix)
- [x] dmaadr: word → byte* (0B clang, +4B sdcc, semantic cleanup)
- [x] BUFF → BDOS_DMAADDR with (byte *) type; CCP_BASE typed
- [x] FSPA/DPH const-correct (void* → typed fields; 6 casts removed)
- [x] bios_seldsk_c returns DPH* (not word)
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
