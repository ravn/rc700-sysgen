# Clang vs SDCC BIOS Size Analysis (2026-03-31)

## Overall

| Section | SDCC | Clang | Delta |
|---------|------|-------|-------|
| Boot | 1145 B | 1320 B | +175 B |
| BIOS code (.text) | 3906 B | 4303 B | +397 B |
| BIOS rodata | ~260 B | 303 B | +43 B |
| JP table | 113 B | 113 B | 0 |
| **Binary total** | **5561 B** | **6041 B** | **+480 B (+8.6%)** |

## Boot section (+175B)

- coldboot in bios_shims.s (assembly) vs SDCC inline
- relocate_bios not inlined (non-static for clang shim access)
- memcpy/memset inlined as LDIR in both compilers
- Linker symbol arithmetic for BSS size slightly less efficient

## BIOS code (+397B)

Clang inlines many small functions that SDCC keeps separate. The top-level
function sizes aren't directly comparable. Grouped analysis needed.

### Largest clang functions

| Function | Clang | Notes |
|----------|-------|-------|
| bios_conout_c | 1188 B | CONOUT display driver (inlined specc, xyadd, displ, etc.) |
| sec_rw | 287 B | Sector read/write |
| bg_clear_from | 264 B | Background bitmap clear |
| rwoper | 261 B | Read/write operation dispatcher |
| isr_crt | 225 B | CRT refresh ISR |
| bios_seldsk_c | 209 B | Disk select |
| bios_write_c | 176 B | Write entry |
| chktrk | 136 B | Track check/format |
| wboot_c | 125 B | Warm boot |

### SDCC functions NOT in clang (inlined or eliminated)

| Function | SDCC | Inlined into |
|----------|------|--------------|
| specc | 125 B | bios_conout_c |
| insert_line | 220 B | bios_conout_c |
| delete_line | 121 B | bios_conout_c |
| xyadd | 86 B | bios_conout_c |
| xwrite | 169 B | bios_conout_c |
| clear_foreground | 75 B | bios_conout_c / bg_clear_from |
| displ | 73 B | bios_conout_c |
| erase_to_eol | 71 B | bios_conout_c |
| flp_dma_setup | 48 B | sec_rw / rwoper |
| fdc_general_cmd | 41 B | sec_rw / rwoper |
| clear_screen | 39 B | bios_conout_c |

## Optimization targets

1. **Boot section** (-175B potential): make relocate_bios static again for clang
   by having the shim call it through a wrapper, or inline the boot sequence
2. **CONOUT inlining** (~100B potential): clang inlines aggressively into
   bios_conout_c. SDCC keeps functions separate with tail-call optimization.
   May benefit from `__attribute__((noinline))` on selected display helpers.
3. **Disk I/O** (~50B): sec_rw and rwoper are larger. Need assembly comparison.
4. **ISR overhead** (~50B): __attribute__((interrupt)) generates more register
   saves than SDCC's __critical __interrupt.
