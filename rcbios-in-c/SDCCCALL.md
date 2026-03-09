# sdcccall Calling Conventions (z88dk/sdcc for Z80)

## sdcccall(1) — Register-based (used by this project)

Selected via `--sdcccall 1`. Parameters passed in registers when possible.

### Parameter Passing

For functions without variable arguments:

| 1st param | 2nd param | Rule |
|-----------|-----------|------|
| 8-bit → **A** | 8-bit → **L** | Both fit in registers |
| 8-bit → **A** | 16-bit → **DE** | Both fit in registers |
| 16-bit → **HL** | 16-bit → **DE** | Both fit in registers |
| 32-bit → **HLDE** | — | No room for 2nd |
| any | 3rd+ param | **Stack** (right-to-left) |

**Struct/union parameters and all parameters after them are always passed on the stack.**

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
3. **Move excess params to globals** — safe when there's no recursion
4. **Prefer `(uint8_t, uint8_t)` over `(uint16_t, uint8_t)`** — first form uses A+L, second uses HL+stack

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
