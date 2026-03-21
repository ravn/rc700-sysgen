# Migration Plan: autoload-in-c patterns → rcbios-in-c

Branch: `rcbios-cleanup`

## Step 1: Binary bitmask constants (mechanical, low risk)

Convert ~14 hex bitmask operations in bios.c to binary notation.
Same pattern as autoload-in-c: `& 0xC0` → `& 0b11000000`.

Port initialization values (0x4F, 0x47, etc.) stay hex — only
bit-test/bit-set/bit-clear operations change.

**Files:** bios.c
**Risk:** None — binary literals are compile-time identical to hex.
**Verify:** `make verify` (byte-identical BIOS output).

## Step 2: `#ifndef __SDCC` header guards (additive)

Add sdcc keyword stubs to hal.h and bios.h for CLion indexing.
The existing `#ifdef HOST_TEST` blocks stay — they serve a different
purpose (mock HAL for host-native tests).  The `#ifndef __SDCC`
guards handle CLion's clang parser, which is separate from HOST_TEST.

```c
#ifndef __SDCC
#define __sfr
#define __at(x)
#define __interrupt(x)
#define __critical
#define __naked
#define __asm__(x)
static inline void intrinsic_di(void) {}
static inline void intrinsic_ei(void) {}
static inline void intrinsic_im_2(void) {}
#endif
```

**Files:** hal.h, bios.h
**Risk:** Low — additive, no existing code changes.
**Verify:** `make verify` + CLion navigation works.

## Step 3: `fdc_result_block` struct (most invasive)

Replace `rstab[8]` with named struct:

```c
typedef struct {
    byte st0;       /* ST0 or ST3 (after Sense Drive) */
    byte st1;       /* ST1 or PCN (after Sense Interrupt) */
    byte st2;       /* ST2 */
    byte cylinder;  /* C */
    byte head;      /* H */
    byte sector;    /* R */
    byte size_code; /* N */
    byte pad;       /* unused (was rstab[7]) */
} fdc_result_block;
```

11 references in bios.c + 2 in assembly (bios_wfitr).  The asm
references use `_rstab` and `_rstab + 1` — these become
`_fdc_result` and `_fdc_result + 1` (same layout, just renamed).

**Files:** bios.c, bios.h
**Risk:** Medium — struct must be `volatile` (ISR writes it),
assembly references must match.  The asm reads st0→B and st1→C
for CP/M ABI return, so field order matters.
**Verify:** `make verify` + MAME boot test.
