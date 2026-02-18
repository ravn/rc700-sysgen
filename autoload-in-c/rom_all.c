/*
 * rom_all.c — Unity build for Z80 ROM target
 *
 * Including all .c files in one translation unit allows the compiler
 * to see all functions at once, enabling cross-function inlining,
 * dead code elimination, and better register allocation.
 *
 * Only used for Z80 ROM build; host tests compile individually.
 */

#include "hal_z80.c"
#include "init.c"
#include "fmt.c"
#include "fdc.c"
#include "boot.c"
#include "isr.c"
