/*
 * sdcc_compat.h — Map SDCC keywords/intrinsics to clang --target=z80 equivalents
 *
 * Include this BEFORE rom.h when building with LLVM-Z80 clang.
 * Defines __SDCC-like macros so rom.c compiles with minimal changes.
 */

#ifndef SDCC_COMPAT_H
#define SDCC_COMPAT_H

/* Do NOT define __SDCC — rom.h's port I/O uses the __clang__ path
 * (address_space(2)) which now works with our Legalizer fix.
 *
 * rom.h has `#ifndef __SDCC` stubs for __naked, __interrupt, __critical,
 * __asm__, and empty intrinsic_* functions. We predefine all of these
 * before rom.h is included so the stubs are either overridden or skipped. */
#define LLVM_Z80 1

/* Override rom.h's stub block (lines 19-26) by pre-defining the macros
 * it would define under #ifndef __SDCC. rom.h checks each with #define,
 * so if already defined, its #define is a no-op redefinition (warning). */

/* Keep __naked as empty — clang naked only allows asm statements */
/* __interrupt: map to clang's interrupt attribute */
/* __critical: empty for now */
/* __sfr / __at: not needed — clang path uses address_space(2) */

/* Suppress rom.h's intrinsic stubs by providing real implementations
 * before rom.h is included. rom.h's #ifndef __SDCC block defines
 * empty intrinsic_* functions — we define __SDCC to skip that block,
 * but also define HOST_TEST=0 so port I/O uses the __clang__ path. */
#define __SDCC 1

/* Override __sfr/__at to be harmless for the __SDCC port I/O path.
 * With __SDCC defined, rom.h's DEFPORT uses __sfr __at which declares
 * global volatile vars. We redirect to the __clang__ path instead
 * by undefining __SDCC just for the DEFPORT section. */

/* Actually — simplest approach: define __SDCC so intrinsic stubs are
 * skipped, but then we need port I/O to work. The __SDCC DEFPORT path
 * uses __sfr __at which won't produce IN/OUT. So we need a different
 * approach: temporarily undefine __SDCC around DEFPORT.
 *
 * Cleaner: just override rom.h's intrinsic stubs and keyword stubs
 * by not defining __SDCC, and instead patching the conflicts. */
#undef __SDCC

/* Pre-define intrinsic functions with real inline asm bodies.
 * rom.h will try to redefine them as empty stubs — the compiler
 * will warn but use these definitions. Actually, C doesn't allow
 * redefinition of functions. We need to prevent rom.h from defining them.
 *
 * Solution: #define guards for the stub section. */

/* Prevent rom.h line 19 (#ifndef __SDCC) stubs by defining __SDCC,
 * then immediately undef to keep __clang__ port I/O path.
 * Problem: rom.h also uses __SDCC at line 113 for DEFPORT.
 *
 * Final approach: patch rom.h to check LLVM_Z80, or use -D flags
 * to override specific functions. Let's use the -D approach. */

/* Override rom.h's keyword stubs with real implementations */
#define __naked /* stripped — clang naked is asm-only */
#define __interrupt(n) __attribute__((interrupt))
#define __critical /* TODO: di/ei wrapper */

/* Provide intrinsics that rom.h's #else branch would stub out.
 * Use attribute((always_inline)) and overloadable to avoid ODR conflicts. */
#define intrinsic_di() __asm__ volatile("di")
#define intrinsic_ei() __asm__ volatile("ei")
#define intrinsic_im_2() __asm__ volatile("im 2")

#endif /* SDCC_COMPAT_H */
