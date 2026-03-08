# Phase 1e: Floppy Disk Driver

## Overview
Port the CP/M 2.2 blocking/deblocking floppy driver from rcbios/src/FLOPPY.MAC
and rcbios/src/DISKTAB.MAC to C.  REL30 is floppy-only (no hard disk support),
which simplifies the driver significantly.

## Steps

### 1. Data structures and tables (crt0.asm + bios.h)
- [ ] Add disk driver variables in crt0.asm (SEKDSK through DUM block)
- [ ] Add HSTBUF (512B), DIRBF (128B), ALLx, CHKx buffers
- [ ] Add DPB tables (DPB16 for mini 512B, DPB8 for mini track0 256B, etc.)
- [ ] Add FSPA format parameter blocks (FSPA00-FSPA24)
- [ ] Add FDF format descriptor blocks (FDF1-FDF4)
- [ ] Add sector translation tables (TRAN0, TRAN8, TRAN16, TRAN24)
- [ ] Add DPBASE disk parameter headers (2 drives: A and B)
- [ ] Add TRKOFF track offset table
- [ ] Declare all new externs in bios.h

### 2. Simple BIOS entry points (bios.c)
- [ ] SETTRK: store BC in sektrk
- [ ] SETSEC: store BC in seksec
- [ ] SETDMA: store BC in dmaadr
- [ ] SECTRAN: return HL=BC (no translation, done in CHKTRK)

### 3. SELDSK — drive select with format lookup (bios.c)
- [ ] Validate drive <= drno
- [ ] Look up format from fd0 table
- [ ] Flush dirty buffer if format changed
- [ ] Copy FSPA block to DPBLCK working area
- [ ] Extract EOTV from format table
- [ ] Set DPB pointer in DPH
- [ ] Copy TRKOFF for selected drive
- [ ] Return DPH address

### 4. FDC low-level routines (bios.c)
- [ ] fdc_wait_write() — wait FDC ready for command byte (FLO2)
- [ ] fdc_wait_read() — wait FDC ready for result byte (FLO3)
- [ ] fdc_recalibrate() — recal command (FLO4)
- [ ] fdc_sense_int() — sense interrupt status (FLO6)
- [ ] fdc_seek() — seek to cylinder (FLO7)
- [ ] fdc_result() — read 7-byte result phase (RSULT)
- [ ] fdc_general_cmd() — 9-byte read/write command (GNCOM)

### 5. DMA setup (bios.c)
- [ ] flp_dma_read() — DMA ch1 write mode for FDC→memory (FLPW)
- [ ] flp_dma_write() — DMA ch1 read mode for memory→FDC (FLPR)

### 6. Motor control (bios.c)
- [ ] fdstar() — start mini floppy motor, wait 1s spinup
- [ ] fdstop() — stop mini floppy motor (called from CRT ISR timer)
- [ ] waitd() — delay via delcnt timer

### 7. Sector read/write with retry (bios.c)
- [ ] secrd() — FDC read + DMA + retry loop (10 retries, recal at 5)
- [ ] secwr() — FDC write + DMA + retry loop

### 8. CHKTRK — multi-density track dispatch (bios.c)
- [ ] Split track 0 sectors by EOTV (head 0 vs head 1)
- [ ] Sector translation via TRANTB
- [ ] LSTDSK/LSTTRK optimization (skip seek if unchanged)
- [ ] Seek + recalibrate on seek failure

### 9. Blocking/deblocking algorithm (bios.c)
- [ ] xread() — set flags, call rwoper
- [ ] xwrite() — set unalloc tracking, call rwoper
- [ ] chkuna() — check unallocated sector continuation
- [ ] rwoper() — core cache algorithm (compute host sector, match/flush/fill)
- [ ] wrthst()/rdhst() — dispatch to chktrk+secrd/secwr

### 10. HOME (bios.c)
- [ ] Flush dirty buffer
- [ ] Start motor, recalibrate, wait for completion

### 11. Floppy ISR (bios.c + crt0.asm)
- [ ] Full floppy ISR: save regs, set FL_FLG, read result or sense int
- [ ] Replace current empty `isr_floppy` stub
- [ ] ISR needs stack switching (like CRT ISR)

### 12. Integration and testing
- [ ] Build and verify size fits mini/maxi limits
- [ ] Test in MAME: does CP/M boot? (requires Phase 1f boot sequence)
- [ ] Note: full boot test needs WBOOT to load CCP+BDOS from disk

## Key decisions
- REL30 is floppy-only: skip all HARDDISK ifdefs
- MINI vs MAXI: need both sets of tables (selected at runtime via SW1 port)
  OR: build separate mini/maxi binaries (original approach)
  Decision: follow original — conditional at build time (MINI or MAXI define)
- Start with MINI (5.25") since that's what we've been testing with

## Size budget
- Current: 3141 bytes. Mini limit: 6144. Available: ~3000 bytes.
- Floppy driver assembly is ~900 bytes. C will be larger but should fit.
- DPB/FSPA/FDF/TRAN tables: ~300 bytes (data, same size as asm)
- Buffers (HSTBUF+DIRBF+ALLx+CHKx): ~900 bytes (BSS, not in binary)
