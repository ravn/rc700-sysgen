# Optimization Plan: C Idioms and Compiler Exploitation

Three investigations into making the C BIOS generate better Z80 code:
accepting BC as a parameter, stack switching from C, and triggering
block instructions (LDIR, OTIR) from C source.

## 1. Accepting BC as a Function Parameter

### Problem

CP/M passes BIOS parameters in BC. sdcccall(1) accepts parameters in
A, HL, DE — never BC. Every BIOS entry that receives BC needs an asm
wrapper to move it into a sdcccall register.

### Findings

**No mechanism exists** in sdcc or z88dk to declare "this function
receives a parameter in BC". The register allocation is hardcoded in
the sdcc compiler source (not in the z88dk tree — z88dk patches sdcc
but doesn't change the parameter register set).

Available calling conventions:
- `sdcccall(1)`: A, HL, DE only
- `__z88dk_fastcall`: single param in HL (or L for 8-bit)
- `__z88dk_callee`: callee cleans stack, same registers as sdcccall
- `__naked`: no prologue/epilogue, full manual control

**Workaround options:**

a) **`__naked` + static variable** (current approach): asm stores BC
   to a static, C body reads the static. Cost: `ld (var),bc` (4 bytes)
   per entry point.

b) **`__naked` + inline asm preamble** (current approach for 8-bit):
   `ld a,c` then C body receives in A. Cost: 1 byte per entry.

c) **Custom sdcc patch**: Add BC to the sdcccall(1) register set.
   Would require modifying `src/z80/gen.c` in the sdcc source.
   The z88dk patches are at `z88dk/src/zsdcc/sdcc-*-z88dk.patch`.
   **High risk** — could break library ABI and register allocator
   assumptions. Not recommended without deep sdcc expertise.

### Source-level analysis of `aopArg()` (gen.c:2221-2302)

The sdcccall(1) parameter-to-register mapping is defined in a single
function: `aopArg()` in `gen.c`. It returns the register operand for
each parameter position, or `0` (stack) for anything that doesn't fit.

For Z80 (non-SM83), the mapping is:

| Param | Size | Register | Code path |
|-------|------|----------|-----------|
| 1 | 8-bit | A | `ASMOP_A` |
| 1 | 16-bit | HL | `ASMOP_HL` |
| 1 | 32-bit | HLDE | `ASMOP_HLDE` |
| 2 | 8-bit | L | only if param1 = A |
| 2 | 16-bit | DE | if param1 = A or HL |
| 3+ | any | stack | `return 0` |

**BC is never returned by `aopArg()` for Z80.** However, the SM83
(Game Boy) target already uses BC for param2 when param1 is in DE
(gen.c:2281: `return ASMOP_BC`), proving the infrastructure supports it.

The caller side (`genSend()`, gen.c:6337) and callee side
(`genReceive()`, gen.c:15997) both delegate to `aopArg()` — they
would automatically handle BC if `aopArg()` returned it.

### Why BC is excluded

The modern register allocator (`ralloc2.cc:78`) treats BC and DE as
the **only two 16-bit pairs** available for local variable allocation.
HL is reserved for code generation temporaries (address calculations,
pointer dereferencing). Consuming BC for parameter passing would leave
only DE for the allocator, increasing register pressure significantly.

The code generator (`genCall()`, gen.c:6414-6420) already checks
whether BC is used as a parameter:
```c
bool bc_not_parm = !z80IsParmInCall(ftype, "b") && !z80IsParmInCall(ftype, "c");
```
This is used to determine which registers are free for temporaries
during call setup. Adding BC as a parameter register would work here
without changes.

### What a patch would look like

Adding BC as param3 for Z80 would require ~10 lines in `aopArg()`:
```c
if (!IS_SM83 && i == 3 && aopArg(ftype, 2) == ASMOP_DE
    && getSize(arg->type) == 2)
    return ASMOP_BC;
```

But this creates **ABI incompatibility** with all existing sdcccall(1)
code. A safer approach: a new attribute (`__z88dk_bccall` or
`sdcccall(2)`) that keeps the standard convention untouched.

### Callee-only patch for CP/M BIOS entries

For BIOS entry points, **the caller is CP/M** (fixed asm that always
passes values in BC). The C compiler only generates the **callee**
side. This means the caller-side code generation (`genSend()`) is
irrelevant — we only need `aopArg()` to return `ASMOP_BC` for the
callee's `genReceive()`.

`genReceive()` (gen.c:16000) is fully data-driven: it calls
`aopArg()` to find the source register, then `genMove()` to move
the value to wherever the register allocator placed the variable.
It would handle BC without any changes.

**Tricking `IS_SM83`** to get BC does not work. SM83 changes the
entire param1 mapping (16-bit → DE instead of HL) and disables
Z80-specific instructions throughout gen.c. The generated code
would be invalid for a Z80.

**Smallest viable patch: `sdcccall(2)`**

The `FUNC_SDCCCALL` field already stores an integer. Currently only
0 and 1 are valid (gen.c:2253 asserts `== 1`). Adding `sdcccall(2)`
requires only:

1. Remove the assert at gen.c:2253 (or change to `<= 2`)
2. Add to `aopArg()` before the `return 0` at line 2298:
   ```c
   if (FUNC_SDCCCALL(ftype) == 2 && i == 1 && getSize(arg->type) == 2)
       return ASMOP_BC;
   if (FUNC_SDCCCALL(ftype) == 2 && i == 1 && getSize(arg->type) == 1)
       return ASMOP_C;
   ```

Usage in C:
```c
void bios_settrk(uint16_t track) __sdcccall(2) {
    sektrk = track;  /* compiler emits: ld (sektrk), bc */
}
```

No parser changes needed — `__sdcccall(N)` already accepts any
integer. No ABI risk — sdcccall(1) is unchanged. The patch is
~5 lines in a single function.

**Limitation**: Only the callee side works. Calling a `sdcccall(2)`
function from C would not place the argument in BC (genSend would
need changes too). This is fine for BIOS entries called from CP/M.

### Affected functions (4)

| Function | Current asm | Pure C with `sdcccall(2)` |
|---|---|---|
| `bios_settrk` | `ld (sektrk),bc; ret` | `{ sektrk = track; }` |
| `bios_setsec` | `ld (seksec),bc; ret` | `{ seksec = sector; }` |
| `bios_setdma` | `ld (dmaadr),bc; ret` | `{ dmaadr = addr; }` |
| `bios_sectran` | `ld h,b; ld l,c; ret` | `{ return sector; }` |

### Verdict

A callee-only `sdcccall(2)` patch is feasible (~5 lines in
`aopArg()`), safe (doesn't touch sdcccall(1)), and would eliminate
4 `__naked` asm wrappers. The current `__naked` wrappers are 3-4
bytes each (12-16 bytes total), so the practical saving is small.
The value is in code clarity — pure C instead of inline asm.

## 2. Stack Switching from C

### Problem

Five BIOS entries (conout, home, seldsk, read, write) must run on the
BIOS stack (0xF500) instead of the caller's stack. Each has a ~20-byte
asm wrapper that saves SP, switches, calls the C body, and restores.

### Findings

**No stack-switch library function exists** in z88dk. The z88dk
library has ISR helpers but no generic "call function on alternate
stack" facility. The sdcc documentation confirms no `__stack(addr)`
attribute or equivalent exists.

**Workaround options:**

a) **Current approach**: Each function has its own asm wrapper that
   does the SP switch manually. ~100 bytes total for 5 functions.

b) **Shared asm trampoline**: Write a single `call_on_bios_stack`
   function in asm that takes a function pointer and calls it on the
   BIOS stack. Each BIOS entry becomes a thin wrapper that passes the
   C body address. Saves ~40-60 bytes by eliminating duplicated
   switch code, but adds call overhead.

   ```c
   /* In crt0.asm or hal.h */
   extern void call_on_bios_stack(void (*fn)(void));

   /* In bios.c */
   void bios_home(void) __naked {
       call_on_bios_stack(bios_home_c);
   }
   ```

   The trampoline in asm (~20 bytes, written once):
   ```asm
   _call_on_bios_stack:
       ; HL = function pointer (sdcccall 1st param)
       di
       push bc
       push de
       ex de, hl           ; DE = function
       ld hl, #0
       add hl, sp          ; HL = caller SP
       ld sp, #0xF500
       ei
       push hl             ; save caller SP on BIOS stack
       ex de, hl           ; HL = function
       call _call_hl       ; call via JP (HL)
       pop hl              ; caller SP
       di
       ld sp, hl
       pop de
       pop bc
       ei
       ret
   _call_hl:
       jp (hl)
   ```

c) **setjmp/longjmp trick**: Not applicable — these save/restore
   context but don't switch stacks cleanly.

d) **Compiler extension**: Would need a `__stack(addr)` attribute.
   Does not exist in sdcc or z88dk.

### Verdict

Option (b) — shared trampoline — is the best practical approach.
Reduces ~100 bytes of duplicated asm to ~25 bytes of trampoline +
5 × ~5 bytes of thin wrappers = ~50 bytes total. Net saving ~50 bytes
and each BIOS entry becomes a one-liner. The trampoline needs
variants for different register save sets and return value handling.

## 3. Generating LDIR, LDDR, OTIR from C

### Problem

The original asm BIOS uses OTIR to output SIO/CTC init blocks to
sequential ports. The C version uses `for` loops that compile to
individual `out` instructions. LDIR is used by memcpy but the
compiler doesn't generate it from hand-written loops.

### Findings

**sdcc never generates block instructions from user code.** Confirmed
by reviewing sdcc's peephole rules (`peeph.def`, 3097 lines) and the
code generator — no pattern recognition for LDIR, LDDR, OTIR, or
OTDR exists. Block instructions only appear via library calls.

z88dk provides **three mechanisms** for block instructions:

### 3a. Library functions (simplest)

`#include <z80.h>` (path: `_DEVELOPMENT/sdcc/z80.h`)

```c
void *z80_otir(void *src, uint8_t port, uint8_t num);
void *z80_inir(void *dst, uint8_t port, uint8_t num);
```

These are thin wrappers around the Z80 OTIR/INIR instructions.
The `_callee` variants save a few bytes at call sites:

```c
#define z80_otir(a,b,c) z80_otir_callee(a,b,c)  /* auto-redirected */
```

**Usage for SIO init:**
```c
#include <z80.h>
z80_otir(psioa, 0x0A, sizeof(psioa));   /* → OTIR to port 0x0A */
z80_otir(psiob, 0x0B, sizeof(psiob));   /* → OTIR to port 0x0B */
```

**Caveat**: OTIR outputs B bytes from (HL) to port C, **incrementing
HL and decrementing B**. It writes to a **single port**. The CTC init
pattern writes to **sequential ports** (0x04, 0x05, 0x06, 0x07) — this
is NOT an OTIR pattern. OTIR only applies to SIO init (9 or 11 bytes
to the same port) and FDC SPECIFY (3 bytes to the same port).

### 3b. Compiler intrinsics (zero-overhead, compile-time constants)

`#include <intrinsic.h>`

```c
intrinsic_outi(src, port, num);
intrinsic_ini(dst, port, num);
```

**How it works**: The macro expands to three fake function calls:
```c
intrinsic_outi(psioa, 0x0A, 9);
/* expands to: */
{ intrinsic_outi(psioa);           /* → ld hl, psioa */
  intrinsic_outi_port_0x0A();      /* → ld c, #0x0A  */
  intrinsic_outi_num_9(); }        /* → call ____sdcc_outi-18 */
```

The peephole optimizer (in z88dk's `sdcc_peeph.0`, **not** sdcc's own
`peeph.def`) recognizes these fake calls and replaces them with inline
Z80 instructions. Port and count must be **compile-time constants**
(they become part of the function name via token pasting).

**Advantage**: Zero call overhead — the peephole optimizer replaces
the entire sequence with inline OTIR (or unrolled OUTI for small
counts). No library function call needed.

**Limitation**: Requires `-clib=sdcc_iy` or `-clib=sdcc_ix` to get
the peephole rules. The `--no-crt` build used here may not load them
automatically. Need to verify the peephole file is being used.

### 3c. Custom peephole rules

sdcc supports `--peep-file <filename>` to add custom peephole rules.
We already use `peephole.def` for project-specific rules. The rule
format is pattern-match-and-replace:

```
replace {
    <assembly pattern>
} by {
    <replacement>
} if <condition>
```

Pattern variables (`%1`, `%2`, ...) match identical strings across the
pattern. Built-in condition functions include `notUsed`, `deadMove`,
`labelRefCount`, `notVolatile`, etc. See `SDCCpeeph.c` for the full
list.

We could write project-specific rules to recognize our output loops
and replace them with OTIR, but this is fragile (depends on exact
code generation patterns that may change with compiler options).

### 3d. memcpy/memset → LDIR (already working)

The z88dk `memcpy` implementation uses LDIR internally. The compiler
already emits `call _memcpy` for `memcpy()` calls, and the library
function executes LDIR. No source changes needed.

For **hand-written copy loops**, sdcc does **not** automatically
recognize the pattern and replace with LDIR. The loop:
```c
while (n--) *dst++ = *src++;
```
compiles to individual LD instructions, not LDIR. Use `memcpy()`
explicitly to get LDIR.

For **backward copies** (overlapping regions), `memmove()` should use
LDDR but the z88dk implementation may not work correctly in all cases
(existing comment in bios.c says memmove hangs). The manual
`*dst-- = *src--` loop is the safe alternative.

### 3e. What C patterns trigger block instructions?

| C pattern | Generated code | Block instruction? |
|---|---|---|
| `memcpy(dst, src, n)` | `call _memcpy` → LDIR | **Yes** |
| `memset(dst, val, n)` | `call _memset` → LDIR | **Yes** |
| `while(n--) *d++ = *s++` | individual LD loop | **No** |
| `for(i=0;i<n;i++) port = arr[i]` | individual OUT loop | **No** |
| `z80_otir(src, port, n)` | `call _z80_otir` → OTIR | **Yes** |
| `intrinsic_outi(src, port, n)` | inline OTIR (peephole) | **Yes** |

## 4. sdcc Compiler Capabilities Summary

Based on study of sdcc 4.5.0 source code and documentation.

### Calling conventions available

| Convention | Params | Return | Notes |
|---|---|---|---|
| `sdcccall(0)` | all stack | L/HL/EHL/DEHL | Legacy, stack-based |
| `sdcccall(1)` | A, HL, DE | A/DE/LDE/HLDE | Default, register-based |
| `__z88dk_fastcall` | single in HL | L/HL/DEHL | One param only |
| `__z88dk_callee` | same as above | same | Callee cleans stack |
| `__smallc` | stack, left-to-right | same as sdcccall(0) | Small-C compat |
| `__naked` | manual | manual | No prologue/epilogue |

No mechanism for custom parameter register sets. No `sdcccall(2)`.

### Key compiler options (Z80)

| Option | Effect |
|---|---|
| `--sdcccall 1` | Register-based calling convention |
| `--opt-code-size` | Prefer smaller sequences |
| `--max-allocs-per-node N` | Register allocator search depth |
| `--fomit-frame-pointer` | Don't use IX as frame pointer |
| `--allow-unsafe-read` | Assume no memory-mapped I/O side effects |
| `--callee-saves-bc` | Force all functions to preserve BC |
| `--reserve-regs-iy` | Don't use IY (OS-reserved) |
| `--peep-file <file>` | Custom peephole rules |
| `--peep-asm` | Apply peephole optimizer to inline asm |
| `--std-sdcc99` | Enable `inline` keyword |

### Default optimizations (all enabled, all beneficial)

These run automatically unless explicitly disabled:

- **GCSE** — Global common subexpression elimination
- **Dead code elimination** — Removes unreachable code, unused assignments
- **Copy propagation** — `i=10; j=i; return j` → `return 10`
- **Loop invariant lifting** — Moves loop-constant expressions outside loop
- **Strength reduction** — Replaces multiplication with addition in loops
- **Loop reversal** — Converts count-up to count-down when possible
- **LOSPRE** — Lifetime-optimal speculative partial redundancy elimination
- **Constant folding/propagation** — Compile-time constant computation
- **Algebraic simplifications** — `x+0→x`, `x*1→x`, unsigned `/2→>>1`
- **Peephole optimization** — 294 built-in rules + 1 Z80-specific rule

### What sdcc cannot do (confirmed)

- Generate block instructions (LDIR/OTIR) from user code patterns
- Accept parameters in BC (Z80 target)
- Switch stacks automatically
- Inline functions automatically (only explicit `static inline`)
- Recognize memcpy-like loops and replace with LDIR

## 5. Current Build Configuration Assessment

### Flags in use (all correct for size-critical embedded BIOS)

```
+z80                           Z80 target
-clib=sdcc_iy                  sdcc runtime, IY available
--no-crt                       Custom crt0.asm
-SO3                           z88dk optimization level 3
--opt-code-size                Prefer smaller code sequences
--sdcccall 1                   Register-based params (A/HL/DE)
--fomit-frame-pointer          No IX frame pointer
--allow-unsafe-read            Safe in controlled BIOS memory
--max-allocs-per-node 1000000  Maximum register allocator depth
--std-sdcc99                   Enable inline keyword
--disable-warning 296          Suppress sdcccall mismatch (no stdlib)
-custom-copt-rules=peephole.def  3 project-specific peephole rules
-pragma-define:CRT_ORG_CODE=0xD480  BIOS origin
```

### Custom peephole rules (peephole.def)

3 rules targeting C-generated I/O patterns:
1. `ld a,0x00` → `xor a,a` (saves 1 byte per occurrence)
2. Redundant `ld a,%1` after `out` to same value (saves 2 bytes)
3. Redundant `xor a,a` after `out` of zero (saves 1 byte)

### Build guards (Makefile)

- **IX/IY guard**: Fails if `ix[+-]` or `iy[+-]` appear in listing
  (all locals must be `static` to avoid frame pointer access)
- **sdcccall(0) guard**: Fails if sdcccall(0) library functions are linked
  (ABI mismatch detection)
- **Address guard**: Verifies psioa, psiob, pchsav, itrtab at expected addresses

### Optimizations NOT currently used — worth investigating

1. **Per-function `#pragma opt_code_speed`**: The BIOS is globally
   size-optimized, but FDC hot paths (sector read/write polling loops)
   are timing-sensitive. Wrapping them with:
   ```c
   #pragma save
   #pragma opt_code_speed
   static void fdc_read_sector(void) { ... }
   #pragma restore
   ```
   Would generate faster code for those functions at the cost of a few
   extra bytes. `--opt-code-speed` uses native `ex (sp),hl` (1 byte,
   10T) instead of `ld 0(sp),hl` (2 bytes, 19T), and unrolls small
   loops more aggressively. Estimated: +5-15 bytes, 10-20% faster on
   hot paths.

2. **More custom peephole rules**: Only 3 rules in `peephole.def`.
   Inspecting the listing for repeated patterns (redundant register
   shuffles in the display driver, repeated address loads in the
   floppy driver) could yield 20-50 bytes. Rule format:
   ```
   replace {
       <asm pattern with %1, %2 variables>
   } by {
       <replacement>
   } if <condition>
   ```
   Built-in conditions: `notUsed`, `deadMove`, `notVolatile`,
   `labelRefCount`, `operandsNotRelated`, etc.

3. **`#pragma callee_saves func1,func2`**: Makes specified functions
   save/restore registers themselves, eliminating push/pop at every
   call site. Best candidates: frequently-called small functions.
   Each call site saves 2-4 bytes (push/pop pair), but the function
   itself grows by the same amount. Net saving depends on call count:
   - 1 call site: no saving (break even)
   - 2+ call sites: saves (callcount-1) × push/pop size
   Requires careful checking that the pragma works with z88dk's
   linker and doesn't conflict with `--no-crt`.

### Optimizations NOT useful for this project

| Option | Why not |
|---|---|
| `--opt-code-speed` (global) | Opposite of size goal |
| `--peep-asm` | Risks mangling 23 hand-written asm blocks |
| `--allow-undocumented-instructions` | ~0-2 bytes, portability concern |
| `--callee-saves-bc` (global) | Conflicts with z88dk ABI |
| `--reserve-regs-iy` | Reduces allocator efficiency |
| `--nmos-z80` | Z80-A is NMOS but sdcc rarely emits `ld a,i`/`ld a,r` |
| Disabling defaults (nogcse etc.) | Would increase code size |

## Action Items

### Immediate (low risk, high value)

1. **Replace SIO init loops with `z80_otir`**:
   ```c
   z80_otir(psioa, 0x0A, sizeof(psioa));  /* was: for loop */
   z80_otir(psiob, 0x0B, sizeof(psiob));
   ```
   Saves ~20 bytes (loop overhead → single OTIR) and is faster.

2. **Replace FDC SPECIFY loop** (if it exists as a loop) with
   `z80_otir` to the FDC data port.

3. **Verify `intrinsic_outi` works** with our build flags. If the
   peephole rules load correctly, switch from `z80_otir` to
   `intrinsic_outi` for zero call overhead.

### Medium term (moderate effort)

4. **Implement shared stack-switch trampoline** in crt0.asm. Convert
   5 BIOS wrappers to use it. Estimated saving: ~50 bytes of asm.

5. **Try `z80_otir` for CTC init** — but CTC uses 4 different ports,
   so OTIR doesn't apply. Keep the current approach or restructure
   as 4 × 2-byte OTIR calls (one per channel).

### Future: z88dk RC700 target extensions

z88dk already has an RC700 target. Extend it with:

a) **RC700-specific library functions**: `rc700_set_cursor_form()`,
   and other hardware-specific helpers that wrap BIOS/hardware calls
   with proper C interfaces.

b) **`sdcccall(2)` for BC parameter passing**: Add callee-only
   support for receiving parameters in BC (see section 1). This is
   a ~5 line patch to `aopArg()` in gen.c. Useful for any CP/M BIOS
   or OS entry point where the caller passes values in BC. Cannot be
   done externally (no plugin system, peephole rules cannot change
   register assignments) — requires rebuilding zsdcc in the z88dk
   tree.

## References

- z88dk z80 library headers: `z88dk/include/_DEVELOPMENT/sdcc/z80.h`
- Intrinsics header: `z88dk/include/intrinsic.h`
- Peephole rules (OTIR): `z88dk/libsrc/_DEVELOPMENT/sdcc_peeph.0`
- OTIR library impl: `z88dk/libsrc/_DEVELOPMENT/z80/z80/asm_z80_otir.asm`
- sdcc patches: `z88dk/src/zsdcc/sdcc-*-z88dk.patch`
- sdcc calling convention: `SDCCCALL.md` in this directory
- sdcc 4.5.0 source: `~/Downloads/sdcc-4.5.0/`
- sdcc documentation: `~/Downloads/doc/sdccman.txt` (text version)
- Parameter mapping: `sdcc-4.5.0/src/z80/gen.c` — `aopArg()` (line 2221)
- Caller codegen: `sdcc-4.5.0/src/z80/gen.c` — `genSend()` (line 6337)
- Callee codegen: `sdcc-4.5.0/src/z80/gen.c` — `genReceive()` (line 15997)
- Call setup: `sdcc-4.5.0/src/z80/gen.c` — `genCall()` (line 6394)
- Register defs: `sdcc-4.5.0/src/z80/ralloc.c` — `z80_regs[]` (line 91)
- Modern allocator: `sdcc-4.5.0/src/z80/ralloc2.cc` — pair constraints (line 78)
- ABI defaults: `sdcc-4.5.0/src/SDCCsymt.c` — `FUNC_SDCCCALL` (line 3398)
- Peephole rules: `sdcc-4.5.0/src/z80/peeph.def` (3097 lines, no block instructions)
- Peephole engine: `sdcc-4.5.0/src/SDCCpeeph.c` (condition functions)
