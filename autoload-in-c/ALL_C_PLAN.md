# Plan: Convert Remaining crt0.asm to C

Goal: reduce crt0.asm to section declarations only (like rcbios-in-c's
z88dk_section_layout.asm), with all code and data in C files.

## Current assembly inventory (121 bytes in 7 blocks)

| Block | Lines | Size | Purpose | Can move to C? |
|-------|-------|------|---------|---------------|
| BEGIN | 60-77 | 18B | DI, SP, LDIR relocation, JP | Partial — LDIR+JP need asm |
| INTVEC | 108-124 | 32B | Interrupt vector table (data) | Yes — C function pointer array |
| INIT_RELOCATED | 130-137 | 16B | SP, LD I, IM2, call init, call main | Partial — LD I needs asm |
| CRTINT | 176-188 | 24B | ISR wrapper: push/call/pop/ei/reti | No — must control EI timing |
| FLPINT | 199-211 | 24B | ISR wrapper: push/call/pop/ei/reti | No — same as CRTINT |
| _jump_to | 226-228 | 3B | JP (HL) — no C equivalent | No |
| _halt_msg | 242-252 | 20B | LDI copy loop + halt | Partial — C is ~4B larger |
| _halt_forever | 250-252 | 2B | JR $ infinite loop | Trivial in C |
| Constants | 258,265 | 0B | EQU/DEFC | Can be C #define |

**Budget: 89 bytes spare.  Any change that grows the binary is risky.**

## What can move to C (estimated savings)

### Phase 1: INTVEC as C function pointer array (like rcbios-in-c)

The interrupt vector table is 16 `DW` entries — pure data.  In C:

```c
static const void (*ivt[])(void) = {
    dumint, dumint, crt_refresh, flpint_body, ...
};
```

Compiled with `--constseg CODE` so it lands at 0x7000.  The linker
resolves ISR addresses.  **Size: identical (32 bytes of DW).**

Need to verify the C array lands at the start of CODE section (before
any compiler-generated code) — section ordering in crt0.asm controls this.

### Phase 2: INIT_RELOCATED → C with set_i_reg pattern

```c
void init_relocated(void) __naked {
    __asm__("ld sp, #0xBFFF\n");
    set_i_reg(0x70);       /* from rcbios-in-c pattern */
    intrinsic_im_2();
    init_peripherals();
    main();
    /* falls through to halt_forever */
}
```

The `set_i_reg` pattern (non-inline function, sdcccall(1) passes byte
in A, inline `ld i,a`) is proven in rcbios-in-c.  `intrinsic_im_2()`
replaces the `IM 2` asm.  **Size: ~same or +2 bytes (call overhead).**

### Phase 3: BEGIN → C with inline asm for LDIR

Similar to rcbios-in-c's coldboot pattern:

```c
void begin(void) __naked {
    intrinsic_di();
    __asm__("ld sp, #0xBFFF\n");
    /* memcpy for relocation — but source/dest/count are linker symbols */
    relocate_prom();
    __asm__("jp _init_relocated\n");  /* jump to relocated code */
}
```

The LDIR relocation uses linker symbols (__tail, INTVEC) that are
tricky in C.  Could use the memcpy pattern from rcbios-in-c's
boot_entry.c with `_BOOT_tail` etc.

**Risk: the LDIR source/dest/count involve complex linker expressions.
Test carefully.**

### Phase 4: _halt_msg and _halt_forever → C

```c
void halt_msg(const char *msg) {
    volatile byte *dsp = (volatile byte *)DSPSTR_ADDR;
    while (*msg)
        *dsp++ = *msg++;
    for (;;);  /* halt_forever */
}
```

**Size: +4 bytes** (C loop vs LDI instruction).  With 89 spare, this
fits but reduces headroom.

### ISR wrappers (CRTINT, FLPINT) — CANNOT move to C

These must stay in assembly because:
- `__interrupt` enables interrupts at function ENTRY (unsafe for DMA)
- `__critical __interrupt(N)` generates correct EI+RETI (tested in
  rcbios-in-c), BUT the push/pop set may differ from what we need
- Manual register save order (AF,BC,DE,HL) matches what the C bodies
  clobber — sdcc's `__critical __interrupt` saves AF,BC,DE,HL,IY
  (5 pairs vs our 4 — wastes 2 bytes per ISR)

**Could use `__critical __interrupt(N)` if the extra IY push/pop
(+4 bytes total) is acceptable.  Currently 89 bytes spare, so it fits.
But must verify sdcc generates RETI not RETN.**

### _jump_to — CANNOT move to C

`JP (HL)` has no C equivalent.  A function pointer call generates
`CALL (HL)` which pushes a return address.  Must stay as 3 bytes of asm.

## Execution order

1. **INTVEC → C array** (zero risk, zero size change)
2. **INIT_RELOCATED → C** (low risk, ~same size)
3. **BEGIN → C** (medium risk, linker symbol handling)
4. **_halt_msg/_halt_forever → C** (costs ~4 bytes)
5. **ISR wrappers → `__critical __interrupt`** (costs ~4 bytes, needs testing)
6. **Constants → C #define** (trivial)

After all phases, crt0.asm contains only section declarations + org
directives + the 3-byte _jump_to.

## Size budget

| Phase | Change | Size impact |
|-------|--------|-------------|
| 1. INTVEC | Data → C array | 0 |
| 2. INIT_RELOCATED | Code → C | +2 |
| 3. BEGIN | Code → C | +4 |
| 4. halt_msg/forever | Code → C | +4 |
| 5. ISR wrappers | Code → __critical | +4 |
| **Total** | | **+14 bytes** |

With 89 bytes spare, all phases fit comfortably.
