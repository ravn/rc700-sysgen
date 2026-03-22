#!/bin/sh
# clang2z88dk.sh — Convert ez80-clang Z80 assembly to z88dk-z80asm format.
#
# Fixes:
#   1. ELF section syntax → z88dk SECTION
#   2. Dot-labels (_.str.6) → underscore labels (_dot_str_6)
#   3. Remove ident directive
#   4. Remove Unwind externs (not needed for bare-metal)

sed \
    -e 's/section	\.text,"ax",@progbits/SECTION code_compiler/' \
    -e 's/section	\.rodata,"a",@progbits/SECTION rodata_compiler/' \
    -e 's/section	\.bss,"aw",@nobits/SECTION bss_compiler/' \
    -e 's/_\.str\./_dot_str_/g' \
    -e 's/_\.str/_dot_str/g' \
    -e '/^	ident	/d' \
    -e '/^	extern	__Unwind/d' \
    "$@"
