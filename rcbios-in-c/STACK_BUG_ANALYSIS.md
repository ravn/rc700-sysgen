# BIOS-in-C: TYPE DUMP.ASM Bug — RESOLVED

## Problem
`TYPE DUMP.ASM` produced no output. `DIR *.ASM` worked correctly.

## Root Cause
**Stack corruption of BDOS during warm boot.** Both `bios_boot` (cold boot) and `bios_wboot`
had `ld sp, #0xD480` — placing the stack at the start of BIOS code. The Z80 stack grows
downward, so deep C function call chains pushed stack frames into the BDOS area (0xC400-0xD9FF)
that was being loaded simultaneously.

The corrupted BDOS byte at D46A (22 bytes below SP=0xD480) turned a `CALL CF4F` into
`JP PO, E1A8` — jumping into the BIOS `watir()` function. This caused BDOS OPEN to crash
when TYPE tried to open a file. DIR worked because its BDOS code paths avoided the corrupted
bytes.

## Investigation Trail
1. GDB stub tracing showed BDOS OPEN crashed — PC jumped to BIOS `watir()` at E1A8
2. Disk image verified: physical sector 3 on track 1 had correct bytes `CD 4F CF`
3. Memory at D46A had wrong bytes — data not from any disk sector
4. Debug output in rdhst() confirmed hstbuf received correct data from FDC
5. Immediately after rwoper's copy loop, D46A already showed corruption
6. The corruption pattern `30 30 33` was ASCII "003" — leaked stack data from `put_hex(acsec=3)`
7. Root cause: `bios_boot` set SP=0xD480, and `bios_boot_c()` calls `wboot_c()` directly,
   so the FIRST warm boot (from cold boot) ran with SP=0xD480 throughout

## Stack Depth Analysis

### Memory Layout
```
0xC400-0xD9FF  CCP+BDOS (loaded during warm boot, 44×128 = 5632 bytes)
0xDA00         BIOS jump table
0xD480         BIOS CODE section start (CRT_ORG_CODE)
0xDC21-0xE0DF  BSS (BIOS variables, hstbuf, dirbf, etc.)
0xF500         BIOS main stack (grows downward)
0xF620         ISR stack (grows downward, used by isr_crt/isr_floppy/isr_pio_kbd)
0xF680         OUTCON table
0xF800-0xFD87  Display buffer (DSPSTR, 2000 bytes)
```

### Warm Boot Call Chain (deepest path)
```
wboot_c()                    SP=0xF500, uses ~10 bytes (locals: sec, ret addr)
  └─ xread()                 ~8 bytes
      └─ rwoper()            ~16 bytes (locals: shift, i, hs, src, dst, offset)
          └─ rdhst()         ~4 bytes
              ├─ chktrk()    ~10 bytes (locals: sec, ev, tp)
              └─ secrd()     ~12 bytes (locals: fp, dma_count, repet)
                  ├─ flp_dma_setup()     ~8 bytes
                  ├─ fdc_general_cmd()   ~8 bytes
                  └─ watir()             ~4 bytes
```
**Estimated peak**: ~80 bytes of stack. With debug output (puts_p → putch → conout_body),
adds another ~30-40 bytes.

### Why 0xD480 Failed
- SP=0xD480 → stack grows below 0xD480
- Peak usage ~80 bytes → stack reaches ~0xD430
- CCP+BDOS extends up to 0xD9FF (CCP_BASE + NSECTS×128 = 0xC400 + 0x1600)
- Stack at 0xD430 is INSIDE the BDOS area being loaded
- Warm boot writes correct data to D400-D47F, then function calls push stack
  frames that overwrite those bytes

### Why 0xF500 Works
- SP=0xF500 → stack grows from 0xF500 downward
- BSS ends at 0xE0DF → 0x1421 bytes (5KB) of headroom
- ISR stack at 0xF620 is separate (ISRs save SP to `sp_sav`, switch to 0xF620)
- No overlap with CCP+BDOS area

### Original BIOS Comparison
The original assembly BIOS used `LD SP,BUFF` (0x0080) during warm boot. This works because:
- Assembly code uses minimal stack (mostly register-based, few CALLs)
- The deepest call chain is ~4 levels, ~16 bytes of stack
- 0x0080 grows down to ~0x0070, well below CCP_BASE (0xC400)

C code needs ~5× more stack due to sdcc's calling convention, frame pointers,
local variables, and helper library calls (e.g., 16-bit shift helpers).

## Fix
Changed both boot entry points to use the BIOS private stack at 0xF500:
- `bios_boot`: `ld sp, #0xF500` (was 0xD480)
- `bios_wboot`: `ld sp, #0xF500` (was 0xD480)

## Key Lessons
1. **C code stack depth**: sdcc-compiled Z80 code uses ~5× more stack than equivalent
   hand-written assembly. Always account for this when placing the stack.
2. **Stack must not overlap load target**: The warm boot stack must be outside the
   CCP+BDOS area (0xC400-0xD9FF) being loaded.
3. **Cold boot calls warm boot**: `bios_boot_c()` calls `wboot_c()` directly, so the
   cold boot's SP is used for the entire warm boot sequence.
4. **Debugging can mask root cause**: Adding debug output (puts_p/put_hex) deepened the
   call chain, making the stack corruption more severe and its pattern (ASCII hex digits)
   visible in the corrupted memory.
