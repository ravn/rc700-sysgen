/*
 * boot_rom.c — BOOT section code.
 *
 * Lives in ROM at ORG 0x0000, accessible until prom_disable().
 *
 * boot_main() is shared plain C: DI, set SP, copy CODE to RAM,
 * zero BSS, jump to init_relocated.  Clang inlines memcpy/memset
 * as LDIR; SDCC links against its standard library.
 *
 * Compiler-specific parts: entry point placement (address 0x0000),
 * linker symbols, banner string, and NMI handler (address 0x0066).
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
 * Compiler-specific: linker symbols, entry point, banner, NMI
 * ================================================================ */

#if defined(__clang__) && !defined(HOST_TEST)

extern char _code_load[], _code_start[], _code_size[];
extern char _bss_start[], _bss_size[];

/* Banner string — 42 bytes, referenced by display_banner in CODE. */
#include "clang_z80/banner.h"
__attribute__((section(".text"), used))
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

#endif

/* ================================================================
 * Shared: boot_main — disable interrupts, set stack, relocate, start
 * ================================================================ */

#if !defined(HOST_TEST)

void boot_main(void) {
    intrinsic_di();
    SET_SP(ROM_STACK);
    memcpy(RELOC_DST, RELOC_SRC, RELOC_SIZE);
#if defined(__clang__)
    memset(BSS_DST, 0, BSS_SIZE);
#endif
    init_relocated();
}

#endif

/* ================================================================
 * SDCC-only: entry point (must be first function) and padding
 * ================================================================ */

#ifdef __SDCC

/* ROM entry point — first function in BOOT section = address 0x0000. */
void begin(void) {
    boot_main();
}

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
