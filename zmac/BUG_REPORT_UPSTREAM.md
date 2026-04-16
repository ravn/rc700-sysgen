# Bug report for zmac upstream

**Send to:** george@48k.ca (zmac maintainer)
**Project home:** http://48k.ca/zmac.html

**Title:** `--dri` mode: silent byte drift when assembling DRI CP/M 2.2
sources (OS2CCP, OS3BDOS)

**Version tested:** `zmac version 18oct2022` (from http://48k.ca/zmac.zip)

**Command line:** `zmac -8 --dri OS2CCP.ASM` (and similarly for OS3BDOS.ASM)

## Summary

Two independent defects in `--dri` tokenisation cause zmac to produce
output that differs from what DRI's MAC.COM produces when assembling
well-formed DRI CP/M 2.2 sources. One defect silently drops
statements; the other raises a spurious "Syntax error" and aborts the
build.

Both are fully `--dri`-gated fixes — no behaviour change in any other
mode.

## Background: DRI MAC's `!` semantics

In MAC.COM, `!` is an always-effective statement separator. It takes
precedence over `;`-comment state: a `!` character encountered inside
a comment terminates the comment and begins a new statement on the
same line. This is documented behaviour and is used pervasively in
DRI-shipped CP/M 2.2 sources.

Representative examples from OS2CCP.ASM:

```asm
nosub:  ;no submit file! call del$sub        ; line 229
        mvi c,rbuff! lxi d,maxlen! call bdos ; line 232
```

And from OS3BDOS.ASM:

```asm
lda blkmsk! mov b,a! ana l! cmp b!inx h ;    ; line 1688
```

## Defect 1 — `!` absorbed into `;`-comment

### Symptom

In zmac 18oct2022 `--dri` mode, line 229 of OS2CCP.ASM assembles as
if the `;no submit file! call del$sub` portion were entirely comment.
The `call del$sub` instruction is silently dropped.

No warning is emitted. The build succeeds. The resulting CCP binary
is 14 bytes shorter than what MAC.COM produces, with 77% of bytes
differing because every symbol defined after the dropped instruction
sits at a different address.

### Reproduction

```
$ cat test_comment_bang.asm
        org 0100h
nosub:  ;no submit file! call del$sub
done:   ret
        end

$ zmac -8 --dri test_comment_bang.asm
```

Expected: two instructions (`call del$sub` + `ret`) = 4 bytes.
Actual: one instruction (`ret`) = 1 byte.

### Root cause

In `zmac.y`, `found_multi()` tracks `;` as entering "comment state"
(`mc_quote = ';'`) and gates statement-separator recognition on
`mc_quote < 0`:

```c
int found_multi(int ch)
{
    if (ch == mc_quote && (mc_quote == '"' || mc_quote == '\''))
        mc_quote = -1;
    else if (mc_quote < 0 && (ch == '\'' || ch == '"' || ch == ';'))
        mc_quote = ch;                /* <-- enters ';' quote-like state */
    else if (ch == '*' && mc_first)
        mc_quote = '*';

    mc_first = 0;
    if (ch == separator && mc_quote < 0)   /* <-- suppresses '!' in comment */
        return 1;
    return 0;
}
```

The `;` comment-state check is appropriate for most assemblers, but
DRI MAC's `!` must always split regardless of comment state.

### Suggested patch

```c
int found_multi(int ch)
{
    if (ch == mc_quote && (mc_quote == '"' || mc_quote == '\''))
        mc_quote = -1;
    else if (mc_quote < 0 && (ch == '\'' || ch == '"' || ch == ';'))
        mc_quote = ch;
    else if (ch == '*' && mc_first)
        mc_quote = '*';

    mc_first = 0;
    /* DRI MAC: '!' always terminates a comment and starts a new
     * statement.  See OS2CCP.ASM line 229 for an example triggering case. */
    if (ch == separator && (mc_quote < 0 || (driopt && mc_quote == ';'))) {
        if (mc_quote == ';')
            mc_quote = -1;
        return 1;
    }
    return 0;
}
```

## Defect 2 — continuation line at column 0 after `!` split

### Symptom

When a `!` separator is immediately followed by a mnemonic with no
whitespace (e.g. `cmp b!inx h`), the continuation statement is
placed in the next logical line starting at column 0. zmac then
interprets the mnemonic as a label (DRI-style column-0 label
convention) and raises a syntax error.

### Reproduction

```
$ cat test_bang_no_space.asm
        org 0100h
        cmp b!inx h     ; no space between ! and inx
        end

$ zmac -8 --dri test_bang_no_space.asm
test_bang_no_space.asm(2) : Syntax error
inx h     ; no space between ! and inx

1 errors
```

The equivalent source with a space (`cmp b! inx h`) assembles
correctly. MAC.COM accepts both forms identically.

### Root cause

`found_multi` returns 1 for the `!`, the containing loop writes
`\n` to the buffer and breaks. The next line starts afresh with the
character immediately after `!` in the file (here, `i` from `inx`).
That puts `inx` in column 0. DRI's column convention then parses
it as a label, producing a syntax error when no `:` follows.

### Suggested patch

In the file-reading branch of the line-input routine, prepend a space
when the previous line ended via a `--dri` multiline split:

```c
    else {
        start_multi_check();

        /* DRI MAC: if the previous line ended with a '!' statement
         * separator, the continuation shouldn't be parsed as starting
         * at column 0 (which would make mnemonics look like labels).
         * Prepend a space so "cmp b!inx h" → line "inx h" reads with
         * a leading space, same as "cmp b! inx h" would.
         * See OS3BDOS.ASM line 1688 for a triggering case. */
        if (driopt && prev_multiline)
            *p++ = ' ';

        for (;;) {
            ch = nextline_peek != NOPEEK ? nextline_peek : getc(now_file);
            /* ... rest unchanged ... */
```

## Testing

Applying both patches and re-assembling Ringgaard's RC702-CP/M
sources (public DRI CP/M 2.2 distribution) gives 99% byte match
against a known-good reference disk — the remaining 1% is exactly
the 6-byte DRI serial stamp, which is expected to differ between
installations.

Before fixes: `OS2CCP.cim` 23% matching (1965 bytes).
After fixes:  `OS2CCP.cim` 99% matching (1979 bytes, only serial differs).

Before fixes: `OS3BDOS.ASM` fails with `Syntax error at line 1688`.
After fixes:  `OS3BDOS.cim` 99% matching (only serial differs).

## Both fixes are --dri-gated

Both suggested code changes are guarded by `driopt`, so non-DRI
assembly (standard Zilog, MRAS, etc.) is completely unaffected. The
changes only activate when the user invoked `zmac --dri`.

## Combined patch file

The two fixes together as a unified diff (36 lines) are in this
repository at `zmac/zmac_dri_fixes.patch`.

---

Reporter: Thorbjørn Ravn Andersen (tra@ravnand.dk), RC702 CP/M
reconstruction project (https://www.jbox.dk/rc702/ lineage).

Investigation and patches developed 2026-04-16 while verifying
byte-exact reproduction of Regnecentralen CP/M 2.2 system disks
from sources.
