# Clang Z80 PROM Build Status

## Current: CP/M Boots, 3014 bytes

PROM: 3014/4096 bytes (74%). CP/M boots in 2.5s emulated.
SDCC: 1872 bytes. Gap: 1142 bytes (61% larger).

## Code Size Analysis

### Where the bytes go (clang vs SDCC)

| Source | Extra bytes | Status |
|--------|-----------|--------|
| SP-relative stack access (5 bytes) vs IX-indexed (3 bytes) | ~300 | **Tradeoff**: frame pointer eliminated at -Os saves ISR overhead but costs more per stack access |
| Register spills across function calls | ~200 | Pending: only 3 GP register pairs (BC/DE/HL) |
| Signed comparison XOR pattern | ~50 | **Fixed**: precompute constant, RLCA for bit 7 |
| Machine outliner extracting tiny functions | 0 | **Fixed**: outliner disabled |
| Port I/O function calls vs inline | 0 | **Fixed**: address_space(2) inlined |
| ISR saving all registers | 0 | **Fixed**: smart frame pointer, only save used regs |

### Register allocation observations

**Leaf functions** (no calls): excellent. Locals stay in registers.
```
inc_twice: add a,2; ret           — 2 bytes (perfect)
swap_add:  ld b,a; ld a,l; add a,b; ret  — 4 bytes (perfect)
```

**Functions with calls**: locals spill to stack. Each SP-relative
access costs 5 bytes (ld hl,N; add hl,sp; ld/st) vs SDCC's IX-indexed
3 bytes (ld (ix+d),r). This is the main remaining size gap.

**Parameter passing**: sdcccall(1) working correctly.
- 1st i8 in A, 1st i16 in HL
- 2nd i8 in L, 2nd i16 in DE
- 3rd+ on stack
- Return i8 in A, i16 in DE

## LLVM-Z80 Backend Optimizations Made

| Commit | Change | Bytes saved |
|--------|--------|------------|
| 8995291 | Disable machine outliner | -268 |
| 8995291 | Allow tiny function inlining (TTI) | (included above) |
| 0d45307 | Signed comparison: precompute constant RHS | -12 |
| 0d45307 | Sign bit test: RLCA into carry | (included above) |
| 89d3ee6 | Smart frame pointer: skip IX for no-stack functions | -13 (ISRs) +46 (SP-relative) = +33 net, but 2x faster boot |

### Open issues
- [#2](https://github.com/ravn/llvm-z80/issues/2) "hl" constraint — fixed with {hl} brace syntax
- [#4](https://github.com/ravn/llvm-z80/issues/4) __critical attribute — backend ready, clang plumbing needed

### Remaining optimization opportunities

1. **IX frame pointer for functions with stack vars** (task #5): SP-relative
   costs 5 bytes/access vs IX-indexed 3 bytes. Need selective IX usage —
   use IX when function has ≥3 stack accesses, omit for simpler functions.
   Parked until register passing improvements reduce spills.

2. **Register spills** (task #9): functions with calls spill all live
   locals to stack because only 3 GP pairs (BC/DE/HL) and all are
   caller-saved. Improving this requires either more registers (EXX
   shadow set, task #4) or better spill heuristics.

3. **Machine outliner cost model** (task #10): currently disabled entirely.
   Should be re-enabled with Z80-aware costs (call=3, ret=1, only outline
   sequences >4 bytes appearing ≥2 times).

## Build
```bash
make clang         # build PROM
make clang_prom    # build + install to MAME/RC700
make clang_asm     # show assembly
make clang_clean   # clean
```

## Biggest remaining opportunity: static stack allocation

The RC700 PROM code is non-reentrant (no recursion, no threading, ISRs
are `__critical`). Local variables could be placed in static global
memory instead of the stack:

```
; Current (SP-relative, 5 bytes per access):
ld  hl, offset
add hl, sp
ld  a, (hl)

; Static allocation (3 bytes per access):
ld  a, (addr)
```

Plus eliminates frame setup/teardown (12 bytes per function).
Estimated saving: ~500 bytes → PROM ~2500 bytes (vs SDCC 1872).

The Z80 backend already has a `FeatureStaticStack` flag defined but
not implemented. See [ravn/llvm-z80#6](https://github.com/ravn/llvm-z80/issues/6).
