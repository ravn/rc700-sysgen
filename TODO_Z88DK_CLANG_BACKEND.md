# TODO: Examine z88dk Clang backend

z88dk has experimental Clang support that may produce better Z80 code
than sdcc. Key potential benefit: better register allocation, meaning
fewer local variables need to be made global to avoid IX frame pointer.

## Link

https://github.com/z88dk/z88dk/wiki/Clang-support

## Why this matters

With sdcc, we must use `--fomit-frame-pointer` and make locals `static`
or global to avoid IX-relative addressing. The Clang backend may handle
register allocation well enough that locals can stay on the stack without
the IX overhead, producing smaller code overall.

## Things to investigate

- Does the Clang backend support `--sdcccall 1` or equivalent?
- Does it support `__interrupt`, `__critical`, `__naked`?
- Does it support `__sfr __at` for port I/O?
- Does it inline `memcpy`/`memset` as LDIR?
- Can it use the existing peephole rules?
- What is the output size compared to sdcc for the same C source?
- Is it stable enough for production use?
