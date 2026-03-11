# Peephole Optimization Rules (peephole.def)

Custom rules for z88dk's `copt` optimizer, applied to sdcc's assembly output
via `-custom-copt-rules=peephole.def`.

## File format

The file cannot contain comment lines — `;` in column 1 is treated as an
assembly line to match, not a comment.  Each rule is a pair of blocks
separated by `=` on its own line, with blank lines between rules:

```
<pattern lines>
=
<replacement lines>
```

`%1`..`%9` are capture variables that match any text to end-of-line.
A variable that appears multiple times must match the same text each time.
`_%1` and `l_%1` match labels with `_` or `l_` prefix literally.

## Rules

### 1. `ld a,0x00` → `xor a, a` (line 1)

Replace loading zero into A with XOR, which is 1 byte shorter (1 vs 2 bytes)
and also clears flags.

### 2. Redundant reload after `out` (line 5)

```
ld a,%1 ; out (%2),a ; ld a,%1  →  ld a,%1 ; out (%2),a
```

`out` does not modify A, so reloading the same value is unnecessary.
Appears in hardware init sequences that write the same value to multiple ports.

### 3–7. Redundant `xor a,a` after zero stores (lines 12–49)

Six variants covering sdcc's two spacing styles (`xor a,a` vs `xor a, a`)
and one vs two intervening stores.

After `xor a,a`, A is zero.  Storing A to memory via `ld (%1),a` does not
change A, so a subsequent `xor a,a` is redundant.  sdcc generates these when
zeroing multiple static variables in sequence.

Variants:
- `xor; ld; xor` → `xor; ld` (lines 19, 26)
- `xor; ld; ld; xor` → `xor; ld; ld` (lines 33, 42)
- `xor; out; xor` → `xor; out` (line 12)

### 8–14. Dead code after unconditional transfer (lines 51–109)

Any instruction immediately following an unconditional `jp`, `jr`, or `ret`
is unreachable dead code.  These rules eliminate the second instruction.

All combinations of `jp`/`jr`/`ret` followed by `jp`/`jr` are covered:
- `jp _%1 ; jp _%2` → `jp _%1` (and all `l_` / mixed variants)
- `jr l_%1 ; jp/jr ...` → `jr l_%1`
- `ret ; jp/jr ...` → `ret`

The `_%1` vs `l_%1` prefix distinction is needed here because these rules
use two different variables (`%1`, `%2`) and the label prefix is part of
the literal match text.

### 15–18. Jump-to-next-instruction elimination (lines 111–141)

```
jp  %1  →  (nothing)
%1:         %1:
```

Eliminates a `jp` whose target is the very next instruction — the jump is
a no-op since execution falls through anyway.  Saves 3 bytes per instance.

**Why `%1` not `_%1`**: Conditional jumps like `jp Z,_foo` won't falsely
match because `%1` captures the entire operand field (`Z,_foo`), and no
label `Z,_foo:` exists.  Labels cannot contain commas.

Three additional rules handle 1, 2, or 3 comment lines between the `jp`
and the target label.  sdcc inserts exactly 3 comment lines between
functions:

```
	jp	_cursor_right
;	---------------------------------
; Function cursor_right
; ---------------------------------
_cursor_right:
```

The pattern `;%2` matches any line starting with `;`, consuming the comment.
This enables **tail-call fall-through optimization**: by reordering function
definitions in the C source so that function B immediately follows function A,
a `jp _B` at the end of A is eliminated.

### 19–22. Conditional branch inversion (lines 143–169)

```
jr  NZ,l_%1 ; jp _%2 ; l_%1:  →  jp Z,_%2 ; l_%1:
jr  Z,l_%1  ; jp _%2 ; l_%1:  →  jp NZ,_%2 ; l_%1:
```

When sdcc generates a short conditional branch (`jr NZ/Z`) that skips over
an unconditional `jp`, the pair can be replaced by a single conditional `jp`
with the inverted condition.  Saves 2 bytes (5 → 3 bytes) and is faster on
the taken path.

Four variants cover NZ/Z conditions with `_%2` and `l_%2` target prefixes.

## Applying tail-call fall-through

To exploit rules 15–18, reorder function definitions in `bios.c`:

1. Identify a function A that ends with `jp _B` (tail call)
2. Move B's definition to immediately after A in the C source
3. Add a forward declaration for B if callers exist before the new location
4. The peephole rule eliminates the `jp _B`, saving 3 bytes

Current fall-throughs (2026-03-11):

| Caller → Callee | Bytes saved |
|---|---|
| `displ` → `cursor_right` | 3 |
| `carriage_return` → `cursorxy` | 3 |
| `erase_to_eos` → `bg_clear_from` | 3 |
| `start_xy` → `goto00` | 3 |
| `rdhst` → `sec_rw` | 3 |
| `cursor_down` → `rowdn` | 3 |

Only one caller per function can benefit (the one placed immediately before).
Prioritize the most frequently executed code path.
