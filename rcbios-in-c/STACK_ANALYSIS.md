# BIOS-in-C Stack Analysis

## No Recursion

The C BIOS has **no recursive function calls**, either direct or indirect.
All call chains terminate without cycling back. This means:

- **All local variables could be made global (static) without corruption.**
- sdcc's `--fno-frame-pointer` and static overlay would be safe to use.
- This is the same property the original assembly BIOS has — it uses fixed
  memory locations for all "local" state.

## Deepest Call Chain (~80 bytes of stack)

```
bios_boot_c / wboot_c          ~10 bytes
  └─ xread                     ~8 bytes
      └─ rwoper                ~16 bytes (shift, i, hs, src, dst, offset)
          └─ rdhst             ~4 bytes
              ├─ chktrk        ~10 bytes (sec, ev, tp)
              └─ secrd         ~12 bytes (fp, dma_count, repet)
                  ├─ flp_dma_setup    ~8 bytes
                  ├─ fdc_general_cmd  ~8 bytes
                  └─ watir            ~4 bytes
```

With CONOUT (debug output or console I/O during warm boot):
```
  └─ puts_p → putch → conout_body → specc/scroll_up/etc.  ~30-40 bytes
```

## ISR Re-Entrancy

Three functions are called from both main code and ISR context:

1. **fdc_sense_int()** — main (secrd retry) + ISR (isr_floppy_body). Safe: ISR
   completes before main code reads rstab[] (synchronized via watir/fl_flg).

2. **fdc_result()** — ISR only (isr_floppy_body). No re-entrancy.

3. **fdstop()** — main (fdstar) + ISR (isr_crt_body timer). Safe: stateless,
   just writes port. fdstar uses DI/EI around motor-start.

No display functions are called from ISR bodies. The ISR and main code stacks
are separate (0xF620 vs 0xF500).

## Stack Layout

```
0xC400-0xD9FF  CCP+BDOS (warm boot load target — stack must NOT be here)
0xDA00         BIOS jump table
0xD480         BIOS CODE start
0xDC21-0xE0DF  BSS (variables, hstbuf, dirbf)
               ~5KB free
0xF500         BIOS main stack top (grows downward)
               288 bytes
0xF620         ISR stack top (grows downward, shared via sp_sav)
0xF680         OUTCON character translation table
0xF800-0xFD87  Display buffer (DSPSTR)
```

## Implications for Code Size

Since there is no recursion, sdcc could use static local variables (overlaid
in fixed memory) instead of stack-allocated locals. This would:
- Eliminate frame pointer setup/teardown
- Allow direct memory addressing instead of IX-relative
- Reduce stack depth to just return addresses (~2 bytes per call level)

The sdcc `--fno-frame-pointer` flag is already used. Further optimization
would require `--stack-auto` to be disabled (making locals static by default),
but this requires confirming no recursion — which this analysis does.

## Historical Bug

The warm boot stack was originally at 0xD480 (start of BIOS code). This placed
it inside the CCP+BDOS area being loaded, causing stack frames to overwrite BDOS
bytes. Fixed by moving to 0xF500. See STACK_BUG_ANALYSIS.md.
