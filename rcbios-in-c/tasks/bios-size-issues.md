# BIOS Code Density Issues for ravn/llvm-z80

Found during session 12 (2026-04-06) comparing clang 5952B vs SDCC 5797B (+155B, +2.7%).

Each issue below is a standalone upstream report with a minimal C reproducer.
No fix code is included — the goal is a fresh look at each problem.

---

## Issue #62: Constant address expression not folded to single load

**Summary:** When computing `&array[constant_index]`, the compiler emits a
runtime ADD instead of folding to a link-time constant.

**Reproducer:**
```c
unsigned char buf[100];
unsigned char *get_ptr(void) {
    return &buf[50];
}
```

**Compile:** `clang --target=z80 -Oz -ffreestanding -S`

**Actual (9 bytes):**
```asm
ld  de, 50
ld  hl, _buf
add hl, de
ex  de, hl
ret
```

**Expected (4 bytes):**
```asm
ld  de, _buf+50
ret
```

**Impact:** 5 bytes per occurrence. In the BIOS, `scroll()` has 2 instances and
`bios_conout_c()` has 3 instances of `base + constant_offset` computed at
runtime. Both operands are link-time constants; the linker can resolve
`_buf+50` as a single relocatable symbol+addend.

**Where it shows:** scroll (+25B vs SDCC), bios_conout_c (+61B vs SDCC).

---

## Issue #63: Missing SUB (HL) / CP (HL) memory-operand instructions

**Summary:** When comparing a value in A with a global variable, the compiler
loads both to registers and uses `SUB reg`. The Z80 has `SUB (HL)` and
`CP (HL)` which compare A directly with memory, saving a register and bytes.

**Reproducer:**
```c
volatile unsigned char a, b;
_Bool test_memcmp(void) { return a == b; }
```

**Compile:** `clang --target=z80 -Oz -ffreestanding -S`

**Actual (16 bytes):**
```asm
ld  a, (_a)
ld  d, a          ; save A in D
ld  a, (_b)
ld  e, a          ; save in E (unnecessary)
ld  a, d          ; restore A from D
sub e             ; compare via register
sub 1
sbc a, a
and 1
ret
```

**Expected (13 bytes):**
```asm
ld  a, (_a)
ld  hl, _b
sub (hl)          ; compare A directly with memory
sub 1
sbc a, a
and 1
ret
```

**Impact:** 3 bytes per comparison. SDCC uses `SUB A,(HL)` extensively — 15+
occurrences across the BIOS. Same applies to `CP (HL)`, `AND (HL)`, `OR (HL)`,
`XOR (HL)` — none of these memory-operand ALU instructions are generated.

**Where it shows:** sec_rw (+172B vs SDCC uses `SUB A,(HL)` for 5 comparisons),
rwoper (+64B), bios_write_c (+8B).

---

## Issue #64: Missing INC (HL) / DEC (HL) read-modify-write instructions

**Summary:** For incrementing or decrementing a byte in memory, the compiler
does load-to-A / modify / store-from-A. The Z80 has `INC (HL)` and `DEC (HL)`
which perform the entire read-modify-write in a single instruction.

**Reproducer:**
```c
volatile unsigned char counter;
void test_inc_mem(void) { counter++; }
```

**Compile:** `clang --target=z80 -Oz -ffreestanding -S`

**Actual (8 bytes):**
```asm
ld  a, (_counter)   ; 3B
inc a               ; 1B
ld  (_counter), a   ; 3B
ret                 ; 1B
```

**Expected (5 bytes):**
```asm
ld  hl, _counter    ; 3B
inc (hl)            ; 1B
ret                 ; 1B
```

**Impact:** 3 bytes per occurrence. SDCC generates `INC (HL)` and `DEC (HL)`
for in-memory increment/decrement of globals. Used in sec_rw (retry counter),
bg_clear_from (byte offset), bios_write_c (unacnt).

**Note:** `INC (HL)` sets the same flags as `INC A` (Z, H, N, S, P/V — all
except C), so flag-dependent code after the increment remains valid.

---

## Issue #65: Missing DJNZ for counted byte loops

**Summary:** The compiler does not generate DJNZ (Decrement B and Jump if
Not Zero) for simple counted loops. Instead it moves B to A, decrements A,
moves back to B, and uses JR NZ.

**Reproducer (simple):**
```c
volatile unsigned char sink;
void test_djnz(void) {
    unsigned char n = 10;
    do {
        sink = n;
    } while (--n);
}
```

**Compile:** `clang --target=z80 -Oz -ffreestanding -S`

**Actual loop body (10 bytes):**
```asm
.LBB0_1:
  ld  a, b            ; 1B — move B to A
  ld  (_sink), a      ; 3B
  dec a               ; 1B — decrement in A
  ld  b, a            ; 1B — move back to B
  jr  nz, .LBB0_1    ; 2B
```

**Expected loop body (8 bytes):**
```asm
.loop:
  ld  a, b            ; 1B
  ld  (_sink), a      ; 3B
  djnz .loop          ; 2B — decrement B and branch
```

**Impact:** 2 bytes per loop. Worse: when the loop body contains a function
call, the counter gets widened to 16 bits (see next reproducer).

**Reproducer (loop with call — catastrophic widening):**
```c
void sink(void);
void test_djnz_pure(void) {
    unsigned char n = 5;
    do { sink(); } while (--n);
}
```

**Actual with +static-stack (~40 bytes):**
```asm
  ld  l, 251            ; starts at -5 (!) counting UP to 0
  ld  d, 0              ; widened to 16-bit
  ...
  inc hl                ; 16-bit increment
  ld  a, h / xor d      ; 16-bit comparison
  ld  a, l / xor e
  or  b
  add a, 255 / sbc a,a / and 1 / xor 1   ; boolean materialize
  jr  nz, .LBB0_1
```

**Expected:**
```asm
  ld  b, 5
.loop:
  push bc               ; save counter across call
  call _sink
  pop  bc
  djnz .loop
```

The compiler transforms `unsigned char` countdown into a 16-bit count-up loop
with negated initial value. This is the single worst code generation pattern
found — it turns a 2-byte DJNZ loop into ~30 bytes of 16-bit arithmetic.

**Where it shows:** Any loop with `unsigned char` counter and a function call
in the body. In the BIOS: bg_clear_from loops, scroll clear loops.

---

## Issue #66: Redundant BSS static-stack reloads

**Summary:** With `+static-stack`, the compiler stores local variables to BSS
slots and then reloads them unnecessarily — either immediately after storing,
or after code that cannot modify the BSS location.

**Reproducer:**
```c
volatile unsigned char x, y;
void sink(unsigned char v);
void test_dead_pushpop(void) {
    unsigned char a = x;
    unsigned char b = y;
    sink(a);
    sink(b);
    sink(a + b);
}
```

**Compile:** `clang --target=z80 -Oz -ffreestanding -Xclang -target-feature -Xclang +static-stack -S`

**Actual (key section):**
```asm
  ld  a, (_x)
  ld  d, a
  ld  hl, 0
  add hl, sp
  ld  (hl), a                    ; store a to stack slot 0
  ld  a, (_y)
  ld  hl, 1
  add hl, sp
  ld  (hl), a                    ; store b to stack slot 1
  ld  a, d                       ; a was already in D!
  call _sink
  ld  hl, 1
  add hl, sp
  ld  a, (hl)                    ; reload b from stack
  call _sink
  ld  hl, 1
  add hl, sp
  ld  a, (hl)                    ; reload b AGAIN
  ld  hl, 0
  add hl, sp
  ld  d, (hl)                    ; reload a from stack
  add a, d
  call _sink
```

**Expected:**
```asm
  ld  a, (_x)
  ld  (__slot0), a
  ld  a, (_y)
  ld  (__slot1), a
  ld  a, (__slot0)
  call _sink
  ld  a, (__slot1)
  call _sink
  ld  a, (__slot1)
  ld  d, a
  ld  a, (__slot0)
  add a, d
  call _sink
```

The `ld hl, N / add hl, sp / ld (hl), a` pattern (5 bytes) for each BSS
access is expensive. With static-stack, these should be direct `ld (addr), a`
(3 bytes) since the addresses are known at link time.

**Impact:** In the BIOS, this pattern accounts for ~30 bytes across sec_rw,
isr_crt, rwoper, and bios_conout_c. Each unnecessary BSS round-trip wastes
3-6 bytes.

**Where it shows:** sec_rw (+172B), isr_crt, rwoper, bios_conout_c.

**Note:** The stack-relative access pattern (`ld hl,N / add hl,sp / ld a,(hl)`)
suggests the static-stack lowering may not be fully converting SP-relative
accesses to absolute BSS addresses.

---

## Summary: prioritized by BIOS byte impact

| # | Issue | Per-occurrence | BIOS impact | Worst function |
|---|-------|---------------|-------------|----------------|
| 65 | 8→16 loop widening + missing DJNZ | 20-30B/loop | ~60B | bg_clear_from, scroll |
| 66 | BSS static-stack reloads (SP-relative) | 3-6B/access | ~30B | sec_rw |
| 62 | Constant address not folded | 5B/expr | ~25B | scroll, bios_conout_c |
| 63 | Missing SUB/CP (HL) | 3B/compare | ~20B | sec_rw, rwoper |
| 64 | Missing INC/DEC (HL) | 3B/inc | ~10B | sec_rw, bg_clear_from |
| 65 | Missing DJNZ (simple case) | 2B/loop | ~10B | multiple |

Total recoverable: ~155B — closing the entire gap with SDCC.
