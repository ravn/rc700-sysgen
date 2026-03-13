# BIOS-in-C Optimization Opportunities

Analysis date: 2026-03-13. Current size: 5473 bytes (671 spare on MINI).

## Hard Disk Support Space Budget

HD support (WD1000 controller) requires ~1120 bytes total:
- Code: ~636 bytes (509 bytes asm × 1.25 C expansion factor)
- Data: ~484 bytes (DPBs, DPHs, alloc vectors for up to 6 HD partitions)

| Target | Spare | HD cost | Fits? |
|--------|-------|---------|-------|
| MINI (5.25") | 671 bytes | ~1120 bytes | No (-449 deficit) |
| MAXI (8") | 4511 bytes | ~1120 bytes | Yes (3391 to spare) |

**Recommendation**: Use `#ifdef MAXI` conditional compilation for HD code,
matching the original BIOS's `IF HARDDISK` conditional assembly. MINI
systems rarely had hard disks.

### HD Code Components (from HARDDSK.MAC, 383 lines)

Code (~509 bytes asm):
- HWRHST/HRDHST: Physical read/write via WD1000 task file + DMA ch0
- CHKPOS: Head position check, track/disk comparison
- STSKFL: Task file setup (cylinder/head/sector/drive bit manipulation)
- HDSEEK: WD1000 seek command
- HDSYNC: Wait for HD operation + error flag (REL22+)
- WAITHD/WDCRDY: Status polling
- DMA0RD/DMA0WR/DMA010: DMA channel 0 setup for 512B sector transfers
- HRDRST: WD1000 restore (seek to track 0)
- HRDFMT: Format track routine (exposed as BIOS entry DA59)
- HDITR: HD interrupt service routine

Data (~484 bytes):
- 5 DPBs: DPB32/40/48/56/64 (1MB, 0.8MB, 2MB, 4MB, 8MB) — 80 bytes
- 6 DPHs: Drives C-H — 96 bytes
- 5 FDF entries: WD1000 format params — 40 bytes
- Allocation vectors: ~260 bytes
- TRKOFF extensions: 8 bytes

### Implementation Notes

- WD1000 task file: 8 I/O ports (0x60-0x67)
- DMA channel 0 for HD (vs channel 1 for floppy)
- CTC2 on external HD board (ports 0x44-0x47) — not on motherboard
- ISR needs `__naked` wrapper with stack switch (same pattern as floppy ISR)
- STSKFL sector calculation uses divmod — must avoid stdlib (provide own)

## Optimization Opportunities (~150 bytes recoverable)

### Tier 1: High-confidence, low-risk (~101 bytes)

**1. SIO ISR excess register saves (~56 bytes)**
Six `__critical __interrupt` ISRs push 5 register pairs but bodies only
use A (and HL in tx ISRs). Convert to `__naked` with minimal push/pop.
- isr_sio_b_tx (A+HL): -8 bytes
- isr_sio_b_ext (A only): -10 bytes
- isr_sio_b_spec (A only): -10 bytes
- isr_sio_a_tx (A+HL): -8 bytes
- isr_sio_a_ext (A only): -10 bytes
- isr_sio_a_spec (A only): -10 bytes

**2. Shared ISR epilogue (~24 bytes)**
Four `__naked` ISRs inline `isr_exit_full` (9 bytes) instead of
`jp _isr_exit_full` (3 bytes). 4 × 6 = 24 bytes.

**3. Redundant reloads in isr_crt (9 bytes)**
Three `ld (addr),hl / ld hl,(addr)` where HL is unchanged (rtc0, timer1,
timer2). Peephole rule or C restructure.

**4. Duplicate "wrap to bottom" code (12 bytes)**
cursor_left and cursor_up share identical 15-byte sequence (set cury=1920,
cursy=24, jp cursorxy). Extract shared helper.

### Tier 2: Moderate confidence (~30 bytes)

**5. Redundant `xor a,a` (6 bytes)** — bios_hw_init, bios_boot_c, wboot_c.
**6. insert_line backward copy → LDDR (10-15 bytes)** — inline asm.
**7. Factor SIO WR5+WR1 sequence (~11 bytes)** — bios_punch + readi share code.
**8. erflag read+clear (2 bytes)** — reorder to use indirect addressing.

### Tier 3: Marginal (~20 bytes)

**9. Double rxtail load in bios_reader (3 bytes)**
**10. DPH memset-first initialization (15-20 bytes)**

## Notes

- No forbidden stdlib calls found (no __div*, __mod*, __mul*).
- The specc() dispatch (if/return chains → cp/jp Z pairs) is already optimal.
- The scroll function (unrolled 16×LDI) is already optimal.
- Tail-call fall-through is already applied to 6+ function pairs.
- The deferred cursor update (cur_dirty flag) is already in place.
- Even with all optimizations (~150 bytes), MINI still can't fit HD (-299 deficit).
  HD support is MAXI-only via conditional compilation.
