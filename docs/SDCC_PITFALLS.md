# sdcc/z88dk Pitfalls for RC702 BIOS-in-C

## WARNING 296 is an ERROR
- "warning 296: non-default sdcccall specified, but default stdlib or crt0"
- Means library functions (e.g. `__divuint`, `__moduint`) use stack-based calling convention (sdcccall 0) but compiled code uses register-based (sdcccall 1)
- Result: **silently corrupt arithmetic** — div/mod return garbage
- **MUST be treated as a build error**. Either fix the library linkage or avoid division/modulo entirely.
- Workaround: use subtraction loops instead of div/mod for small values (put_dec)

## ISR wrappers MUST save IX and IY
- `-clib=sdcc_iy` reserves IY as a library global register
- IX is the frame pointer in sdcccall(1)
- Any ISR body compiled by sdcc will clobber BOTH IX and IY
- All `__naked` ISR wrappers must: `push ix; push iy` ... `pop iy; pop ix`
- Missing IX save causes local variables in interrupted code to be corrupted
- Symptom: function-local variables appear to contain random/constant wrong values

## sdcccall(1) parameter passing
- `--sdcccall 1` flag makes ALL functions use register calling convention
- 1st 8-bit param: A, 1st 16-bit param: HL, 2nd 8-bit param: L (not E!)
- Do NOT add redundant `__sdcccall(1)` annotations — the global flag covers everything
- `#define __sdcccall(x)` needed in HOST_TEST hal.h for clang compatibility

## Boot stack location
- `bios_boot` must NOT use SP=0x0080 — stack grows down and wraps to 0xFFxx, corrupting work area
- Use SP=0xD480 (below BIOS code) during boot; CCP/BDOS area is free

## Static variables vs local variables vs inlined expressions
- **Static variables**: sdcc stores to memory and reloads on every access. Even
  if a value was just computed in A/HL, it gets written to a static address and
  immediately read back. This costs 6+ bytes per store/reload cycle.
- **Local variables**: sdcc uses IX-relative addressing (frame pointer). Much
  tighter code — variables live on the stack, no memory round-trips. BUT: the
  BIOS runs on CP/M's tiny stack (64 bytes), so IX-relative addressing is
  forbidden (checked by build: `ERROR: IX/IY-relative addressing found`).
- **Inlined expressions**: best option when a value is used 1-2 times. Even if
  the expression is duplicated, it's often smaller than static store+reload.
  Example: `memcpy(dst, src, 128)` with static `dst`/`src` costs 6 bytes each
  for the store-then-reload; inlining the expressions directly in memcpy args
  saves 10+ bytes.
- **Variable-count shifts**: `x >> y` generates a tight DJNZ loop in registers.
  The old pattern `while (y--) x >>= 1` with static `x` and `y` forces memory
  read/write/decrement per iteration — 22+ bytes vs 6 bytes for the inline form.
- **Rule**: ALWAYS add a comment explaining why when inlining for codegen reasons.

## Danish character ROM
- `[` and `]` display as Danish characters (AE/AA). Use `(` and `)` in debug output.
- Characters 128-191 enable graphical/blink mode (sticky). Never output bytes >=0x80.
