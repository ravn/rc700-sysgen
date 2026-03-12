# Moving bios.c to Pure C

Analysis of the remaining inline assembly in bios.c and a concrete plan
to eliminate it by moving all ABI/hardware glue to crt0.asm.

## Current state (2026-03-12)

bios.c contains ~24 `__asm__()` blocks across these categories:

| Category | Count | Functions |
|----------|-------|-----------|
| CP/M ABI shims (BC↔A, DE↔HL) | 7 | conout, seldsk, write, settrk, setsec, setdma, sectran |
| Stack-switch entries (SP setup) | 2 | boot, wboot |
| ISR stack-switch wrappers | 4 | isr_crt, isr_pio_kbd, isr_floppy, isr_sio_a_rx |
| ISR inline helpers | 4 | isr_enter, isr_exit, isr_enter_full, isr_exit_full |
| Extended BIOS ABI glue | 4 | wfitr, linsel, exit, clock |
| SIO init (OTIR) | 1 | bios_hw_init |
| Non-returning jumps | 1 | jump_ccp |
| IVT page register | 1 | bios_hw_init (ld a, #0xF6; ld i, a; im 2) |

## Root cause

The mismatch between CP/M's calling convention (params in BC, return in
HL, arbitrary register expectations) and sdcccall(1) (params in A/HL/DE,
return in A/DE) forces every BIOS entry point to have an assembly shim.
Currently these shims are `__naked` C functions with inline asm — mixing
two languages in one file.

## Key insight

**The asm boundary should be at the file level (crt0.asm vs bios.c),
not at the function level** (mixed `__naked`/C in the same file).

crt0.asm already owns the binary layout, JP table, CONFI block, section
ordering, and fixed-address symbols. It is the natural home for all
calling convention translation.

## Plan: move all shims to crt0.asm

### Step 1 — CP/M ABI shims

Move the register-shuffling wrappers from bios.c to crt0.asm. The JP
table entries (already in crt0.asm) jump to these stubs, which tail-call
the pure C functions.

Before (bios.c):
```c
void bios_conout(byte c) __naked {
    (void)c;
    __asm__("ld a, c\n");
    /* fall through to bios_conout_c */
}
static void bios_conout_c(byte c) { ... }
```

After (crt0.asm):
```asm
_bios_conout:
    ld a, c
    jp _bios_conout_c
```

After (bios.c):
```c
void bios_conout_c(byte c) { ... }   /* pure C, no __naked */
```

Functions to move:
- `bios_conout`: `ld a, c` + fall-through → `ld a, c` + `jp`
- `bios_seldsk`: `ld a, c` + `call` + `ex de, hl` + `ret`
- `bios_write`: `ld a, c` + fall-through → `ld a, c` + `jp`
- `bios_settrk`: `ld (_sektrk), bc` + `ret`
- `bios_setsec`: `ld (_seksec), bc` + `ret`
- `bios_setdma`: `ld (_dmaadr), bc` + `ret`
- `bios_sectran`: `ld h, b` + `ld l, c` + `ret`

### Step 2 — Stack-switch entries

Move SP setup to crt0.asm stubs:

```asm
_bios_boot:
    ld sp, #0xF500
    jp _bios_boot_c

_bios_wboot:
    ld sp, #0xF500
    jp _wboot_c
```

`jump_ccp` also moves here: `ld c, a` + `jp CCP_BASE`.

### Step 3 — Extended BIOS entries

Move `bios_wfitr`, `bios_linsel`, `bios_exit`, `bios_clock` shims to
crt0.asm. These have multi-register CP/M conventions (A/B params,
DE+HL returns) that are inherently asm. The function bodies that are
pure C (wfitr body, linsel body) stay in bios.c.

### Step 4 — ISR wrappers

Move the 4 `__naked` ISR wrappers to crt0.asm. Each becomes:

```asm
_isr_crt:
    push af
    ld (_sp_sav), sp
    ld sp, #ISTACK
    call _isr_crt_body
    ld sp, (_sp_sav)
    pop af
    ei
    reti
```

The C body functions (`isr_crt_body`, `isr_pio_kbd_body`, etc.) are
plain C — no `__naked`, no `__asm__`, no inline helpers needed.

This eliminates the 4 `isr_enter`/`isr_exit` inline asm helpers.

### Step 5 — Remaining one-off blocks

- **SIO OTIR** in `bios_hw_init`: move to a callable `sio_init(port,
  data, len)` in crt0.asm, or accept one `__asm__` in init code (it's
  overwritten by CCP after boot anyway).
- **IM2 setup** (`ld i, a`): same — move to crt0.asm or accept one
  `__asm__` in init.
- **DI/EI/HALT**: stay as hal.h macros. Every embedded C project has
  these. They are the minimal necessary asm.

## Result

After all steps, bios.c contains:
- **Zero** `__naked` functions
- **Zero** `__asm__()` blocks (or 1-2 in init code, acceptable)
- **Zero** ISR inline helpers
- All functions are plain C with standard sdcccall(1) conventions

crt0.asm grows by ~100 bytes of ABI glue, but this is a net win:
- Cleaner separation of concerns (asm file = hardware, C file = logic)
- Easier to read and maintain bios.c
- HOST_TEST compilation becomes trivial (no `__naked` to stub out)
- No size change (same instructions, different file)

## Shared stack-switch trampoline (optional, saves ~50 bytes)

If multiple BIOS entries need stack switching (currently only boot/wboot,
but home/seldsk/read/write had it before), a shared trampoline helps:

```asm
; HL = C function address. Switches to BIOS stack, calls, restores.
_stack_call:
    ld (_saved_sp), sp
    ld sp, #0xF500
    call _jp_hl
    ld sp, (_saved_sp)
    ret
_jp_hl:
    jp (hl)
```

Each entry becomes `ld hl, _target` + `jr _stack_call` (~5 bytes vs ~15
inline). Worth doing only if 3+ entries need it.

## What stays as asm forever

Some things are inherently Z80 assembly and will never be C:
- DI/EI/HALT intrinsics (1 instruction each)
- IM 2 setup (`ld i, a`)
- OTIR for block port I/O (no C equivalent)
- Stack pointer manipulation (no C equivalent)
- EI + RETI sequence (ISR epilogue)
- JP (HL) dispatch (no C equivalent)

The goal is not zero assembly — it is zero assembly **in bios.c**.