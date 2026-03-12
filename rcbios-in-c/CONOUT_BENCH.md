# CONOUT Benchmark — ASM FILEX Test

Cycle counts for the ASM FILEX integration test, comparing BIOS variants.
TYPE FILEX.PRN is dominated by CONOUT (character output) — the key metric.

## Results

| Date | BIOS | TYPE cycles | TYPE time | ASM cycles | PC samples |
|------|------|-------------|-----------|------------|------------|
| 2026-03-11 | original-maxi | 178,996,914 | 44.749s | 187,238,614 | 4462 |
| 2026-03-11 | c-bios-6402B | 188,278,829 | 47.070s | 188,598,895 | 4570 |
| 2026-03-11 | c-bios-6438B | 169,554,967 | 42.389s | 188,598,895 | 4336 |
| 2026-03-12 | c-bios-6449B | 162,193,449 | 40.548s | 190,599,307 | 4277 |

## Analysis (2026-03-12)

### After kbstat cached status optimization (c-bios-6449B)

The C BIOS is now **9.4% faster** than the original REL2.3 assembly BIOS
on TYPE FILEX.PRN (162.2M vs 179.0M cycles).  Pre-computing the console
status byte (`kbstat`) in the keyboard ISR and CONIN — instead of
comparing head/tail pointers on every `bios_const` call — saved ~7.4M
cycles.  `bios_const` is called ~86,000 times during TYPE (once per BDOS
character output), so reducing it from 6 instructions to 2 (`ld a,(kbstat)`
+ `ret`) adds up.

## Analysis (2026-03-11)

### After unrolled LDI scroll optimization (c-bios-6438B)

The C BIOS is now **5.3% faster** than the original REL2.3 assembly BIOS
on TYPE FILEX.PRN (169.6M vs 179.0M cycles).  The unrolled 16×LDI scroll
(16T/byte vs 21T/byte LDIR) recovered ~18.7M cycles from the previous
C BIOS measurement — even more than the predicted 10M, likely because
the LDIR fill trick for memset contributed additional savings.

### Before optimization (c-bios-6402B)

The C BIOS was **5.2% slower** on TYPE FILEX.PRN compared to the original
REL2.3 assembly BIOS.  ASM and STAT times are within 1%, so the difference
was concentrated in character output (CONOUT), not disk I/O.

### Methodology

- `run_mame.sh -c` / `run_mame.sh -oc` run identical tests:
  `ASM FILEX`, `STAT FILEX.PRN`, `TYPE FILEX.PRN`
- Keyboard input via MAME natural keyboard (`emu.keypost`) — BIOS-agnostic
- Timing via `manager.machine.time` (emulated time at 4 MHz Z80 clock)
- PC sampled at 50 Hz (frame rate) during all commands

### C BIOS PC profile (50 Hz sampling, 4570 samples)

| Function | Samples | % | Notes |
|----------|---------|---|-------|
| `_watir` | 1716 | 37.5% | CRT DMA refresh busy-wait (ISR) |
| `__code_compiler_size` | 1136 | 24.9% | BDOS code (not BIOS) |
| `_scroll` | 565 | 12.4% | Screen scroll (memcpy 80×24) |
| `__CODE_size` | 437 | 9.6% | CCP/TPA code |
| `_displ` | 185 | 4.0% | Display character on screen |
| `_bios_conout` | 143 | 3.1% | CONOUT entry + specc dispatch |
| `_cboot` | 100 | 2.2% | Cold boot init (one-time) |
| `_rwoper` | 57 | 1.2% | Disk read/write |
| `_bios_const` | 51 | 1.1% | Console status check |
| `_conout_body` | 43 | 0.9% | CONOUT inner processing |
| `_cursorxy` | 43 | 0.9% | Cursor positioning |
| `_cursor_right` | 32 | 0.7% | Advance cursor |

### Original BIOS PC profile (50 Hz, 4462 samples, no symbol map)

| Address range | Samples | % | Likely function |
|---------------|---------|---|-----------------|
| 0xE75B–0xE761 | 1642 | 36.8% | CRT DMA refresh (≈ `_watir`) |
| 0xDE7D–0xDE7F | 493 | 11.0% | CONIN/CONST busy-wait |
| 0xE4DB–0xE4DD | 59 | 1.3% | Display-related |
| 0xE1B6–0xE249 | ~300 | ~6.7% | Display/scroll code |

### Optimization targets

1. **`_scroll` (12.4%)** — largest BIOS-only hotspot.  The C version uses
   `memcpy()` which may generate slower code than the hand-tuned `LDIR`
   loop in the original BIOS.  Consider inline asm LDIR for the 1920-byte
   screen scroll.

2. **`_displ` + `_bios_conout` + `_conout_body` (8.0%)** — the CONOUT
   call chain.  Function call overhead (push/pop, parameter passing) adds
   up across ~34,000 calls during TYPE.  Merging or inlining small
   functions could help.

3. **`_cursorxy` + `_cursor_right` (1.6%)** — called on every character.
   Already optimized with tail-call fall-through.  Further gains possible
   by simplifying the row×80 multiplication.

## Test infrastructure

```
make cycle-test         # C BIOS: timing + 50 Hz PC profile
make cycle-baseline     # Original BIOS: same test, unpatched disk
make profile            # C BIOS: instruction-level trace (debug MAME)
make profile-baseline   # Original BIOS: instruction-level trace
make asm-test           # Correctness test only (no timing)
```
