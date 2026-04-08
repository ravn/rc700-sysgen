# Session 15 Summary

Date: 2026-04-08
Branch: main

## Headline

Implemented cross-block redundant `LD A,r` removal in `Z80LateOptimization`
(ravn/llvm-z80#60), uncovered and fixed a pre-existing latent miscompile in
`Z80PostRACompareMerge` along the way (now ravn/llvm-z80#65), and shipped a
PROM size win.

| | clang PROM | SDCC PROM |
|---|---|---|
| Session 14 final | 1756 | 1910 |
| Session 15 final | **1751** | 1910 |
| Δ | **-5 B** | — |

Gap to SDCC widened from -8.1% to -8.3%.

BIOS not rebuilt this session.

## What was done

### 1. Cross-block redundant LD A,r removal (#60)

The existing peephole at `Z80LateOptimization.cpp:1618` only handled the
single-MBB case: `LD r,A; ...; LD A,r` within one block, scanning forward
up to 8 instructions.

Issue #60's motivating example (`fdc_get_result_bytes` in the autoload
PROM) is **cross-block**: the `LD r,A` save sits in one MBB, the
redundant `LD A,r` reloads sit in successor MBBs because a `JR cc`
terminator splits the path:

```asm
ld   d,a       ; bb.0
cp   #2
jr   nz,.LBB_not2
ld   a,d       ; bb.1 (ret_v) ← REDUNDANT, missed by single-block scan
ret
.LBB_not2:     ; bb.2
ld   a,d       ; ← REDUNDANT
or   a
jr   nz,...
ld   a,d       ; bb.3 ← REDUNDANT
ld   ($66a0),a
```

**Implementation** (in `Z80LateOptimization.cpp`):

A small forward dataflow over MBBs tracking a tiny lattice per program
point — `Top | Bottom | Reg(r)` — meaning "what 8-bit register is A
known to equal here?". Transfer:

- `LD r,A` → `Reg(r)` (A's value now lives in r as well)
- `LD A,r` → `Reg(r)` (and if Known was already `Reg(r)`, the LD is a no-op
  and is collected for removal)
- def of A or current `Known.r` → `Bottom`
- regmask (CALL) → `Bottom`
- `OR A`, `AND A`, `LD A,A` → unchanged (idempotent on A's value despite
  TableGen marking them as `implicit-def $a`)

Meet over predecessor exits is intersection. Iterates to fixpoint with a
small iteration cap to handle loop back-edges. Removal pass walks each
MBB applying the transfer from `EntryAK[bb]`.

**Test**: `llvm/test/CodeGen/Z80/redundant-ld-a-reg.ll` — 2 positive
(cross_block_chain mirroring fdc_get_result_bytes; cp_chain_three
covering longer CP chains) + 2 negative (call clobber; immediate-store
clobber).

**Limitation**: at multi-pred join points where one predecessor leaves
A clobbered (e.g., via `AND #imm`), the meet drops to Bottom and the
reload is preserved. Filed as **ravn/llvm-z80#66** for future
edge-splitting / block-head duplication work.

### 2. Latent miscompile in Z80PostRACompareMerge (now #65)

While verifying #60, the new test surfaced a **pre-existing latent
miscompile**. `Z80PostRACompareMerge::setsZForA` listed `CP_n`/`CP_r`/
`CP_HLind`/`CP_IXd` as instructions whose Z flag reflects `A == 0`. They
do not — `cp operand` sets Z based on `(A - operand) == 0`, i.e.
`A == operand`.

A subsequent `OR A; JR Z` would be dropped because the pass thought the
prior CP already established the flag. The conditional jump then tested
the wrong condition.

**Why it was hidden**: in practice the register allocator nearly always
emitted an `LD A,r` between the CP and the OR A (reloading A from a
save register), and `LD A,r` reset `ZFlagValid`. That accidental
load-bearing `LD A,r` is exactly what #60 sets out to remove. So #60's
fix would have introduced runtime miscompiles in real code if shipped
without fixing this first.

**Fix**: removed the explicit CP_* cases from `setsZForA`. Z reflects
`A == 0` only when the instruction _defines_ A (XOR/AND/OR/ADD/SUB/INC/
DEC of A into A) and also defines FLAGS.

**Test**: `llvm/test/CodeGen/Z80/post-ra-cmp-merge-cp.ll` reproduces it
deterministically.

### 3. Verification

| Check | Result |
|---|---|
| New lit tests (`redundant-ld-a-reg.ll`, `post-ra-cmp-merge-cp.ll`) | PASS |
| Z80 lit suite regressions | 0 (48/53 pass; same 5 pre-existing fails — see #67) |
| PROM size | 1756 → **1751 B** |
| Undocumented insn check (IXH/IXL/IYH/IYL/SLL grep) | 0 hits |
| MAME ROM CRC vs built PROM | match |
| MAME boot test | PASS, banner `RC700 CL`, CP/M `A>` reached |

## Findings filed as issues

- **ravn/llvm-z80#65** — Z80PostRACompareMerge CP miscompile (latent,
  now fixed). Filed for traceability.
- **ravn/llvm-z80#66** — cross-block #60 follow-up: split critical edges
  to handle multi-pred merges. Estimated 5-15B more in PROM/BIOS.
- **ravn/llvm-z80#67** — placeholder for the 5 pre-existing lit
  failures (`cmp-eq-regpressure`, `fib`, `interrupt`, `shift-opt`,
  `spill-regclass`). Not introduced by this session; filed so future
  work can tell its own regressions apart from baseline noise.

## Lessons

1. **Test before fix really works.** Writing a failing lit test for #60
   first (per `feedback_test_before_fix`) is what surfaced the
   compare-merge miscompile. If we'd shipped #60 directly to the PROM
   build, the boot test would have caught the resulting hang somewhere
   downstream — but locating the actual bug from a hang is enormously
   harder than from a focused FileCheck failure.

2. **Removing "useless" reloads can expose latent flag-tracking bugs.**
   Any pass that observes "the previous flag-setter is still valid for
   our purposes" is implicitly relying on the precise sequence of
   instructions in between not changing. When a peephole removes a
   redundant `LD A,r`, downstream flag-validity assumptions need to
   hold under that reduced sequence. Worth re-auditing the other
   flag-tracking passes (`setsZForA` and friends) for similar bugs.

3. **Idempotent ALU instructions need a special case in dataflow.**
   `OR A`, `AND A`, `LD A,A` all carry an `implicit-def $a` in the
   MCInstrDesc despite leaving A unchanged (they only affect FLAGS).
   A dataflow that conservatively treats `implicit-def $a` as a
   clobber will lose precision through the most common test pattern
   (`save; ...; or a; jr cc`). Special-casing these three opcodes
   recovers the precision.
