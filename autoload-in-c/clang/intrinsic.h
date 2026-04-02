/*
 * intrinsic.h — Clang/LLVM-Z80 equivalents of SDCC intrinsics.
 *
 * SDCC provides <intrinsic.h> with intrinsic_di(), intrinsic_ei(), etc.
 * This header provides the same functions for Clang via inline assembly.
 */

#ifndef _INTRINSIC_H
#define _INTRINSIC_H

static inline void intrinsic_di(void) {
    __asm__ volatile("di");
}

static inline void intrinsic_ei(void) {
    __asm__ volatile("ei");
}

static inline void intrinsic_halt(void) {
    __asm__ volatile("halt");
}

static inline void intrinsic_nop(void) {
    __asm__ volatile("nop");
}

#endif /* _INTRINSIC_H */
