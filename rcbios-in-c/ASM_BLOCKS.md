# Inline Assembly Blocks in bios.c

Analysis of every `__asm` block: what it does, why it's asm, and whether it
could be rewritten in C.

## Summary

| Category | Count | Could be C? |
|----------|-------|-------------|
| ISR wrappers (stack switch + RETI) | 3 | No |
| BIOS entry stubs (stack switch) | 6 | No |
| Block memory ops (LDIR/LDDR) | 5 | Maybe (size cost) |
| Block I/O (OTIR) | 1 | Yes (loop) |
| CP/M ABI glue (BC param, A return) | 10 | No |
| Boot entry (SP setup + jump) | 2 | No |
| HALT spin loop | 1 | No |

## Cannot be C

### ISR wrappers (`isr_crt`, `isr_pio_kbd`, `isr_floppy`)

Must save/restore all registers, switch SP to ISTACK, call body, EI+RETI.
sdcc's `__interrupt` puts EI at function *entry* which enables nested
interrupts and corrupts `sp_sav`. These must stay `__naked` + asm.

### BIOS entry stubs with stack switching

`bios_conout`, `bios_home`, `bios_seldsk`, `bios_read`, `bios_write` all
switch to the BIOS private stack before calling C code. This is necessary
because CP/M uses a small stack that can't support C call depth. The pattern
is: DI, save SP to `sp_sav`, set SP to 0xF500, call C body, restore SP, EI, RET.

`bios_boot`, `bios_wboot`: set SP=0xF500 and jump to C function. Trivial asm.

### CP/M ABI glue

CP/M passes parameters in BC and expects return values in A (8-bit) or HL
(16-bit), not in the sdcccall(1) registers. These tiny stubs bridge the gap:

- `bios_const`: return 0 or 0xFF in A (keyboard status)
- `bios_conin`: wait loop + ring buffer read + INCONV lookup, return in A
- `bios_settrk/setsec/setdma`: store BC to variable (2 instructions each)
- `bios_listst`: return 0xFF in A
- `bios_sectran`: move BC to HL
- `bios_reads`: return 0 in A
- `bios_wfitr/linsel/exit/clock/hrdfmt`: bare RET stubs

These are 1–3 instructions each. Writing them in C would add function
prologue/epilogue overhead and require `__naked` anyway to control the
return register. **No benefit from C rewrite.**

### HALT

`bios_conin` uses `__asm__("halt")` to wait for interrupts. No C equivalent.

## Could potentially be C

### Block memory operations (LDIR/LDDR)

5 blocks use LDIR or LDDR for bulk memory copy/fill:

1. **`scroll()`** — LDIR 1920 bytes (ROW1→ROW0). C equivalent: `memcpy` or
   byte loop. LDIR is 21T/byte, a C loop would be ~30-40T/byte. For 1920
   bytes that's ~17K extra T-states per scroll. Scroll is visible to the user
   (screen update speed). **Keep asm.**

2. **`clear_screen()`** — LDIR fill 2000 bytes with 0x20. C: `memset` loop.
   Same timing argument as scroll. **Keep asm.**

3. **`delete_line()`** — LDIR variable count (ROW24_OFF - cury bytes).
   Complex address arithmetic in asm (13 instructions). C equivalent would be
   cleaner but slower. Count calculation uses `SBC HL,BC` which has no direct
   C equivalent that compiles efficiently. **Keep asm for speed**, but the
   code is fragile — consider C if size reduction is needed.

4. **`insert_line()`** — LDDR variable count (copy backwards). Same analysis
   as delete_line. LDDR has no C equivalent without a reverse loop.
   **Keep asm.**

5. **`init_bios()` display clear** — LDIR fill 0xF800–0xFFCF with spaces.
   Only runs once at cold boot. **Could be C** (loop), but saves nothing
   since it's the same size either way.

6. **`init_bios()` work area clear** — LDIR fill 0xFFD1–0xFFFF with zeros.
   Only runs once. **Could be C.**

### Block I/O (OTIR)

**`init_bios()` SIO programming** — OTIR sends 9/11 bytes to SIO ports.
C equivalent: `for` loop writing each byte. OTIR is faster but this only
runs once at boot. **Could be C** — a loop over the parameter arrays would
be clearer and about the same size.

### bios_conin — the largest rewritable block

24 instructions. Does:
1. Spin waiting for `kbtail != kbhead`
2. Read `kbbuf[kbtail]`
3. Increment tail with wrap (AND 0x0F)
4. Index INCONV table
5. Return character in A

This *could* be C:
```c
uint8_t bios_conin(void) {
    while (kbtail == kbhead)
        __asm__("halt");
    uint8_t raw = kbbuf[kbtail];
    kbtail = (kbtail + 1) & 0x0F;
    return *((uint8_t *)(INCONV_ADDR + raw));
}
```

**Problem**: sdcccall(1) returns 8-bit in A, which is correct. But `__naked`
is needed to avoid prologue/epilogue, and then we can't use C. The asm version
is also tighter (no static variable overhead). **Keep asm** unless the ring
buffer logic needs to change (e.g., for SIO integration).

### bios_const — 7 instructions

Could be `return (kbtail != kbhead) ? 0xFF : 0x00;` but the CP/M convention
requires the result in A, not in the sdcccall(1) return register. With
`__naked`, we'd still need asm for the return. **Keep asm.**

## Conclusion

The asm blocks fall into three groups:

1. **Hardware primitives** (ISR wrappers, DI/EI, RETI, HALT, IN/OUT): must stay asm.
2. **CP/M ABI glue** (BC params, A returns): must stay asm (1–3 instructions each).
3. **Block memory ops** (LDIR/LDDR, OTIR): could be C but would be slower and
   not significantly smaller.

The only blocks where C rewrite would *improve clarity* without significant
penalty:
- `init_bios()` SIO OTIR → C loop (runs once, same size)
- `init_bios()` memory clears → C loops (run once)

These are low-priority since they only execute during cold boot.
