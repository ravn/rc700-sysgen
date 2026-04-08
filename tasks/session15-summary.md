# Session 15 Summary

Date: 2026-04-08
Branch: main

## Headline

Implemented cross-block redundant `LD A,r` removal in `Z80LateOptimization`
(ravn/llvm-z80#60), uncovered and fixed a pre-existing latent miscompile in
`Z80PostRACompareMerge` along the way (now ravn/llvm-z80#65), discovered and
fixed a downstream peephole interaction (now ravn/llvm-z80#68), and shipped
size wins in **both** PROM and BIOS.

| | clang PROM | clang BIOS | SDCC PROM | SDCC BIOS |
|---|---|---|---|---|
| Session 14 final | 1756 | 5827 | 1910 | 5797 |
| Session 15 final | **1751** | **5822** | 1910 | 5797 |
| Δ | **-5 B** | **-5 B** | — | — |

PROM gap: -8.1% → **-8.3%** (wider). BIOS gap: +0.5% → **+0.4%** (narrower).

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

### 3. Downstream peephole interaction (now #68)

After PROM verification, rebuilt BIOS to check for impact. Initial result:
**5827 → 5830 (+3 B regression)**. Tracked it down to `xyadd`:

A separate peephole at `Z80LateOptimization.cpp:3655` already handled:
```
LD A,r        ; I0
PUSH AF       ; I1
LD A,r        ; I2  (duplicate of I0, used as a temp via PUSH/POP)
LD (addr),A   ; I3
POP AF        ; I4
```
collapsing it to `LD A,r; LD (addr),A`. The cross-block #60 dataflow runs
earlier in the same pass and **correctly identifies I2 as redundant** (A
already equals r), so it eats I2. The 5-instruction matcher then no longer
fires, leaving 3 wasted bytes (`PUSH AF` + `POP AF`) per affected site.

**Fix**: extended the peephole to also accept the 4-instruction post-#60
form (`LD A,r; PUSH AF; LD (addr),A; POP AF`). Result: BIOS shrank from
5830 → **5822** — net **-5 B** vs original 5827 baseline.

Filed as ravn/llvm-z80#68 with an audit checklist of other multi-
instruction peepholes that contain `LD A,r` in the middle and might have
the same interaction pending.

### 4. Verification

| Check | Result |
|---|---|
| New lit tests (`redundant-ld-a-reg.ll`, `post-ra-cmp-merge-cp.ll`) | PASS |
| Z80 lit suite regressions | 0 (48/53 pass; same 5 pre-existing fails — see #67) |
| PROM size | 1756 → **1751 B** (-5) |
| BIOS size | 5827 → **5822 B** (-5) |
| Undocumented insn check (IXH/IXL/IYH/IYL/SLL grep) | 0 hits |
| MAME ROM CRC vs built PROM | match |
| PROM MAME boot test | PASS, banner `RC700 CL`, CP/M `A>` reached |
| BIOS MAME boot test | PASS, CP/M `A>` reached |

## Findings filed as issues

- **ravn/llvm-z80#65** — Z80PostRACompareMerge CP miscompile (latent,
  fixed in this session). Filed for traceability.
- **ravn/llvm-z80#66** — cross-block #60 follow-up: split critical edges
  to handle multi-pred merges. **Closed empirically as 0-byte prize**:
  measured all 3 multi-pred LD A,r sites in the PROM; all are real
  D→A return-value loads, not redundant reloads.
- **ravn/llvm-z80#67** — placeholder for the 5 pre-existing lit
  failures (`cmp-eq-regpressure`, `fib`, `interrupt`, `shift-opt`,
  `spill-regclass`). Not introduced by this session; filed so future
  work can tell its own regressions apart from baseline noise.
- **ravn/llvm-z80#68** — audit other multi-instruction peepholes in
  `Z80LateOptimization.cpp` for the same kind of LD A,r interaction
  that bit `xyadd`. Includes a checklist of candidate peepholes to
  inspect.

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

4. **A new optimization can defeat existing pattern peepholes that
   contain its target instruction.** The cross-block #60 dataflow
   correctly removed the inner `LD A,r` of a 5-instruction pattern
   that another peephole was waiting to collapse. The 5-instruction
   matcher then failed to match the 4-instruction residue and left
   3 wasted bytes per site. Whenever a new pass removes instructions
   that could be sub-patterns of fixed-shape peepholes elsewhere, the
   downstream peepholes need to either (a) be extended to recognize
   the post-removal residue, (b) be re-ordered to run before the new
   pass, or (c) the new pass needs to know to leave specific patterns
   alone. We chose (a) for the BSS spill push/pop peephole and filed
   ravn/llvm-z80#68 to audit the rest.

5. **Always rebuild downstream artifacts before claiming a win.**
   Initial PROM-only verification missed a +3 B BIOS regression.
   Rebuilding both PROM and BIOS as a verification step catches
   cases where a change saves bytes in one binary and costs them in
   another. The CompareMerge fix (#65) also adds bytes in some
   functions because correctness recovery is non-zero-cost — the
   only way to know is to rebuild and measure.
