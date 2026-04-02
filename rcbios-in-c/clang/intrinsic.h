/*
 * intrinsic.h — Clang/LLVM-Z80 equivalents of SDCC <intrinsic.h>
 *               plus SDCC keyword compatibility stubs.
 *
 * For SDCC builds, the system <intrinsic.h> is used instead.
 * For clang builds, this file is found via -Iclang_z80.
 *
 * The __asm__(x) macro neutralizes SDCC-syntax inline asm in naked
 * functions.  These become empty stubs, removed by --gc-sections.
 * Note: __asm__(x) (function-like) does NOT match __asm__ volatile(x)
 * (keyword followed by qualifier), so this file's own intrinsics work.
 */

#ifndef _INTRINSIC_H
#define _INTRINSIC_H

/* ================================================================
 * Z80 intrinsic functions (via inline asm volatile)
 * Host clang (CLion) gets no-op stubs — only Z80 clang emits asm.
 * ================================================================ */

#ifdef __z80__
static inline void intrinsic_di(void)   { __asm__ volatile("di"); }
static inline void intrinsic_ei(void)   { __asm__ volatile("ei"); }
static inline void intrinsic_halt(void) { __asm__ volatile("halt"); }
static inline void intrinsic_nop(void)  { __asm__ volatile("nop"); }
static inline void intrinsic_im_2(void) { __asm__ volatile("im 2"); }
#else
static inline void intrinsic_di(void)   {}
static inline void intrinsic_ei(void)   {}
static inline void intrinsic_halt(void) {}
static inline void intrinsic_nop(void)  {}
static inline void intrinsic_im_2(void) {}
#endif

/* ================================================================
 * SDCC keyword stubs for source compatibility
 *
 * These allow bios.c to compile with clang without changes.
 * The naked functions become empty stubs (dead code, gc'd by linker).
 * ================================================================ */

#define __naked
#define __critical
#define __interrupt(n) __attribute__((interrupt))
#define __sdcccall(x)

/* Neutralize SDCC-syntax inline asm in naked function bodies.
 * The naked functions are dead code for clang (the jump table
 * points to shims in bios_shims.s instead). */
#define __asm__(x) ((void)0)

#endif /* _INTRINSIC_H */
