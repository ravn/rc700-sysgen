/*
 * rom_all.c — Unity build for Z80 ROM target
 *
 * Including all .c files in one translation unit allows the compiler
 * to see all functions at once, enabling cross-function inlining,
 * dead code elimination, and better register allocation.
 *
 * intvec.c is compiled separately (intvec.o) and linked first so the
 * linker places the IVT at 0x7000 (page-aligned for Z80 IM2).
 */

#include "hal_z80.c"
#include "init.c"
#include "fmt.c"
#include "fdc.c"
#include "boot.c"
#include "isr.c"

/* Sentinel — must be last in the unity build.
 * &code_end - &intvec = payload size to relocate from ROM to RAM. */
const byte code_end = 0xFF;
