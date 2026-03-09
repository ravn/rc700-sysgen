# sdcccall Calling Conventions (z88dk/sdcc for Z80)

## sdcccall(1) — Register-based (used by this project)

Selected via `--sdcccall 1`. Parameters passed in registers when possible.

### Parameter Passing

For functions without variable arguments:

| 1st param | 2nd param | Rule |
|-----------|-----------|------|
| 8-bit → **A** | 8-bit → **L** | Both in registers |
| 8-bit → **A** | 16-bit → **DE** | Both in registers |
| 16-bit → **HL** | 16-bit → **DE** | Both in registers |
| 16-bit → **HL** | 8-bit → **stack** | 2nd goes on stack! |
| 32-bit → **HLDE** | — | No room for 2nd |
| any | 3rd+ param | **Stack** (right-to-left) |

**Struct/union parameters and all parameters after them are always passed on the stack.**

### Experimentally Verified (z88dk sdcc 4.5.0, `--sdcccall 1 --fomit-frame-pointer`)

All combinations tested with `test_sdcccall.c` — compile and inspect listing:
```
make -f /dev/null test_sdcccall  # or see test_sdcccall.c for standalone build command
```

| Signature | 1st | 2nd | 3rd | IX? |
|-----------|-----|-----|-----|-----|
| `(u8)` | A | — | — | No |
| `(u16)` | HL | — | — | No |
| `(u8, u8)` | A | L | — | No |
| `(u8, u16)` | A | DE | — | No |
| `(u16, u8)` | HL | **stack** | — | **Yes** |
| `(u16, u16)` | HL | DE | — | No |
| `(u8, u8, u8)` | A | L | **stack** | **Yes** |
| `(u8, u8, u16)` | A | L | **stack** | **Yes** |
| `(u8, u16, u8)` | A | DE | **stack** | **Yes** |
| `(u16, u16, u16)` | HL | DE | **stack** | **Yes** |

**Key insight**: The 2nd parameter only goes in a register when:
- 1st is 8-bit (A), 2nd is 8-bit → **L**
- 1st is 8-bit (A) or 16-bit (HL), 2nd is 16-bit → **DE**

When 1st is 16-bit (HL) and 2nd is 8-bit, there is **no register available** —
the 2nd param goes on the stack and requires IX to access.

### Return Values

| Size | Register |
|------|----------|
| 8-bit | **A** |
| 16-bit | **DE** |
| 24-bit | **LDE** |
| 32-bit | **HLDE** |

### Optimization Guidelines

To minimize stack operations (and avoid IX/IY-relative addressing):

1. **Max 2 parameters per function** — 3rd+ always go on stack
2. **Put the 8-bit param first** — unlocks L for the 2nd 8-bit param
3. **Avoid `(u16, u8)`** — the only 2-param form that uses stack
4. **Move excess params to globals** — safe when there's no recursion

Optimal 2-param signatures (no stack access):
```
(u8, u8)   → A, L
(u8, u16)  → A, DE
(u16, u16) → HL, DE
```

Problematic (uses stack even with only 2 params):
```
(u16, u8)  → HL, stack  ← avoid this!
```

Example (this project):
```c
// BAD: 3rd param goes on stack → IX-relative access
void dbg_trace4(uint8_t type, uint8_t p1, uint16_t p2);

// GOOD: 2 params in registers, 3rd moved to global
static uint16_t dbg_p2;
void dbg_trace4(uint8_t type, uint8_t p1);
```

## sdcccall(0) — Stack-based (legacy, NOT used)

All parameters passed on the stack, right-to-left.

| Size | Return register |
|------|----------------|
| 8-bit | **L** |
| 16-bit | **HL** |
| 24-bit | **EHL** |
| 32-bit | **DEHL** |

**WARNING**: sdcccall(0) and sdcccall(1) are ABI-incompatible. Library functions
compiled with sdcccall(0) will silently produce wrong results when called from
sdcccall(1) code. The Makefile checks for this (div/mod/mul guard).

## No-Recursion Optimization

Since this BIOS has no recursion (see `STACK_ANALYSIS.md`), all local variables
can be declared `static`. This eliminates stack-allocated locals entirely:

- No IX/IY frame pointer setup
- Direct memory addressing instead of IX-relative
- Stack depth reduced to return addresses only (~2 bytes per call level)

The Makefile enforces this with a build guard that fails if any `ix[+-]` or
`iy[+-]` patterns appear in the compiler listing.
