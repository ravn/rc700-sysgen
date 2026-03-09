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

## Inlining

sdcc has **no automatic inlining** at any optimization level. Functions are only
inlined when explicitly marked `static inline` and compiled with `--std-sdcc99`.

Via z88dk: `-Cs"--std-sdcc99"`

### Behavior

- `static inline` expands the function body at each call site
- The original function is eliminated if all calls are inlined
- `__sdcccall(1)` conventions are irrelevant for inlined code (parameters become
  ordinary variables handled by the register allocator)
- `--opt-code-size` does **not** suppress inline expansion

### Cost/benefit (experimentally verified)

Each inlined call saves 27 T-states (CALL=17 + RET=10) but costs ~6 bytes
(inline body minus the eliminated CALL instruction, plus the RET is gone).

| What was inlined | Calls | Size delta |
|------------------|-------|------------|
| `clfit` + `watir` | 14 | +60 bytes |
| `fdc_wait_write` + `fdc_wait_read` | 18 | +70 bytes |
| 6 small functions | ~40 | +159 bytes |

### Per-function inlining analysis

Each function was evaluated for inlining based on: body size (bytes), number of
call sites, whether it's on a hot path (disk I/O), and net size impact.

**Inlined (speed-critical hot path):**

| Function | Body | Calls | Why inline |
|----------|------|-------|------------|
| `fdc_wait_write` | 9B | 15 | FDC status polling loop, called before every register write. 27 T-states saved per FDC access. +70B total for both. |
| `fdc_wait_read` | 9B | 3 | FDC status polling loop, called before every register read. Same reasoning. |

**Not inlined (size cost too high or no speed benefit):**

| Function | Body | Calls | Why not |
|----------|------|-------|---------|
| `clfit` | 7B | 11 | 3 instructions (DI, store, EI). 11 call sites × ~4B = +44B for negligible speed gain — not on a tight loop. |
| `watir` | 5B | 3 | Busy-wait on `fl_flg`. Only 3 calls, but the wait itself dominates — saving 27T on entry is meaningless vs thousands of loops. |
| `wfitr` | 6B | 8 | Calls `watir` + `clfit`. Inlining would expand both, compounding size cost. |
| `fdstop` | 8B | 1 | Called once — no benefit from inlining. |
| `fdc_recalibrate` | ~20B | 2 | Too large to inline, and not called in the sector read/write hot path. |
| `fdc_sense_int` | ~30B | 2 | Too large, contains a loop. |
| `flp_dma_setup` | ~40B | 2 | Large function with many port writes. |
| `wrthst`/`rdhst` | ~15B | 4/1 | Wrappers that call other functions — inlining saves nothing. |

**Decision rule:** Only inline functions where (a) the body is smaller than ~10 bytes,
(b) the function is called in a tight timing-critical loop, and (c) the CALL/RET
overhead (27 T-states) is significant relative to the function body execution time.

### Other compiler tuning (already maxed out)

| Setting | Value | Notes |
|---------|-------|-------|
| `--max-allocs-per-node` | 1000000 | Register allocator search depth (default 3000). Diminishing returns above ~200000. |
| `-SO3` | max | Highest z88dk optimization level. |
| `--fomit-frame-pointer` | on | Avoids IX as frame pointer. |
| `--allow-unsafe-read` | on | Enables some memory access optimizations. |
| `--opt-code-size` | on | Prefers smaller sequences (subroutine calls for stack frame setup). |
| `--std-sdcc99` | on | Enables `inline` keyword support. |
| Unity build | yes | All code in single `bios.c` gives sdcc full cross-function visibility. |

sdcc has no `-finline-functions`, no inline threshold, no automatic inlining at
any optimization level. The `inline` keyword is the only mechanism.

`--stack-auto` has no effect on Z80 (8051-only feature).
