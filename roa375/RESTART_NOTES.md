# ROA375 Disassembly Restart Notes

**Date**: 2026-02-08

## Clean Slate for Disassembly

The previous disassembly attempts encountered issues due to incorrect zmac flag usage.
This has been resolved: use `-z` flag for Z80 assembly, not `-8` flag.

## Starting Files

### Essential Files (DO NOT MODIFY)
- `roa375.rom` - Original ROM binary (2048 bytes)
- `roa375_raw.asm` - Raw z80dasm output (for reference)
- `rob358.mac` - Reference MAC assembly for RC702 system

### Documentation
- `README.md` - Original project notes
- `WHY_NOT_BYTE_EXACT.md` - Notes on byte-exact reconstruction challenges
- `CONVERSION_SUMMARY.md` - Previous conversion attempts summary
- `RESTART_NOTES.md` - This file

### Build System
- `Makefile` - Build automation (uses correct `-z` flag)

## Previous Attempts (Archived for Reference)

Multiple disassembly files exist from previous work:
- `roa375.asm` - Various intermediate versions
- `roa375_new.asm`
- `roa375_disasm.asm`
- `roa375_full_disasm.asm`
- `roa375-byteidentical.asm`
- `roa375-first-try.mac`

These can be moved to an `archive/` subdirectory if needed.

## Correct Build Command

```bash
zmac -z --dri roa375.asm
```

**NOT** `zmac -8` (that's for 8080 mode)

## Next Steps for Disassembly

1. Start with `roa375_raw.asm` as the base
2. Add meaningful labels and comments
3. Identify subroutines and data sections
4. Document hardware I/O operations
5. Goal: Create a well-commented, maintainable disassembly

## Known Information

From previous analysis:
- ROM is for RC702 system (Z80-based)
- Contains boot loader and system initialization code
- Hardware-specific I/O to ports and memory-mapped regions
- See rob358.mac for similar system code structure

## zmac Flag Reference

- `-z` = Z80 mode (correct for this project)
- `-8` = 8080 mode (wrong - causes "Invalid 8080 instruction" errors)
- `--dri` = DRI compatibility mode
