/*
 * boot_rom.c — BOOT section code.
 *
 * Lives in ROM at ORG 0x0000, accessible until prom_disable().
 *
 * start() is the shared entry point: DI, set SP, copy CODE to RAM,
 * zero BSS, jump to init_relocated.  Clang inlines memcpy/memset
 * as LDIR; SDCC links against its standard library.
 *
 * Compiler-specific parts: linker symbols, banner string, and
 * NMI handler (address 0x0066).
 */

#ifdef __SDCC
#include <string.h>
#include <intrinsic.h>
#else
#include <string.h>
#endif
#include "rom.h"

extern void init_relocated(void);

/* ================================================================
 * Compiler-specific: linker symbols, banner, NMI
 * ================================================================ */

#if defined(__z80__)

extern char _code_load[], _code_start[], _code_size[];
extern char _bss_start[], _bss_size[];

/* Banner string — 42 bytes, referenced by display_banner in CODE. */
#include "clang_z80/banner.h"
#ifdef __ELF__
__attribute__((section(".pagezero.data"), used))
#endif
const char banner_string[42] = CLANG_BANNER;

/* NMI handler — placed at 0x0066 by linker script (.nmi section). */
__asm__(
    ".section .nmi,\"ax\"\n"
    ".globl _nmi_handler\n"
    "_nmi_handler:\n"
    "\tretn\n"
    ".section .text\n"
);

#define RELOC_DST   (_code_start)
#define RELOC_SRC   ((const void *)_code_load)
#define RELOC_SIZE  ((unsigned)_code_size)
#define BSS_DST     (_bss_start)
#define BSS_SIZE    ((unsigned)_bss_size)

#elif defined(__SDCC)

extern byte _BOOT_tail;
extern const byte intvec;
extern const byte code_end;

#define RELOC_DST   ((void *)&intvec)
#define RELOC_SRC   ((const void *)&_BOOT_tail)
#define RELOC_SIZE  ((unsigned)(&code_end - &intvec + 1))
#define BSS_DST     ((void *)0)
#define BSS_SIZE    ((unsigned)0)

#else
/* IDE fallback — stubs so CLion can parse start() */
#define RELOC_DST   ((void *)0)
#define RELOC_SRC   ((const void *)0)
#define RELOC_SIZE  ((unsigned)0)
#define BSS_DST     ((void *)0)
#define BSS_SIZE    ((unsigned)0)

#endif

/* ================================================================
 * Shared entry point: DI, set SP, relocate CODE, zero BSS, start
 *
 * For Clang: placed at 0x0000 by linker script (ENTRY(_start)).
 * For SDCC: must be the first function in the BOOT section.
 * ================================================================ */

#ifdef __ELF__
__attribute__((section(".pagezero.text")))
#endif
void start(void) {
    intrinsic_di();
    SET_SP(ROM_STACK);
    memcpy(RELOC_DST, RELOC_SRC, RELOC_SIZE);
    if (BSS_SIZE)
        memset(BSS_DST, 0, BSS_SIZE);
    init_relocated();
}

/* ================================================================
 * SDCC-only: banner and NMI padding
 * ================================================================ */

#ifdef __SDCC

/* Banner string */
#include "build_stamp.h"
void banner_string(void) __naked {
    __asm__("DEFM \" RC700\"\n"
            "DEFM " BUILD_STAMP_STR "\n");
}

/* Pad to NMI vector at 0x0066 */
void pad_to_nmi_retn(void) __naked {
    __asm__("DEFS 0x0066 - ASMPC, 0xFF\n"
        "retn\n");
}

#endif
