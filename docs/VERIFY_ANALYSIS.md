# VERIFY.MAC / VERIFY.COM Analysis

## Files
- `rcbios/src-rc702e/VERIFY.MAC` — 3252 lines, raw DB dump at 0xEA00-0xFA00 (4096 bytes)
- `rcbios/sw1711_files/VERIFY.COM` — 10624 bytes, standalone CP/M transient program

## Relationship
Related programs with shared Pascal heritage, but **separate compilations** — NOT relocations of each other.

### Evidence
- **Same Pascal compiler**: stack-based calling convention, jump table structure, "DIV 0" runtime string
- **Different runtime addresses**: library function offsets differ inconsistently (+0x2A, +0x3D, etc.)
- **Only 10.9% byte-sequence overlap** (8-byte sampling)
- **Different I/O layers**: VERIFY.COM uses BDOS (`CALL 0005h`); BIOS block has zero BDOS/BIOS calls

### Feature differences
- **COM-only**: machine detection ("RC700", "RC855"), version ("VERS. 1.0"), date ("82.10.12"), drive selection, file creation feedback
- **BIOS-only**: safety prompts ("WARNING: THIS MAY DESTROY THE CONTENTS OF THE DISKETTE", "CONTINUE (Y/N)")

### BIOS block is incomplete
The 4KB block contains only application logic. Calls runtime at 0x22xx-0x29xx and subroutines at 0x0Bxx-0x17xx (outside the block). Full program would be ~9-10KB. `mkbios_e220.py` marks it "not loaded during boot."

## Conclusion
Two versions of the same disk verification utility:
- **VERIFY.COM** (v1.0, 12 Oct 1982): RC700/RC855, 8" MAXI, BDOS I/O, complete executable
- **BIOS VERIFY block**: RC702E-specific, added safety prompts, removed machine signon, non-BDOS I/O, app-only (runtime loaded separately)

## Status: PARKED
Pascal compiler output doesn't reconstruct into readable source. Low priority unless specific algorithm understanding needed.
