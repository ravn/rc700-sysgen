/* boot_entry.c — Cold boot initialization (BOOT_CODE section).
 *
 * Compiled with --codeseg BOOT_CODE so code runs at physical addresses
 * after the BOOT data sections, not at BIOS runtime address.
 * Executes before BIOS relocation.
 *
 * The ROM (ROA375) loads Track 0 to address 0x0000, sets SP to 0xBFFF,
 * and jumps to the boot pointer at offset 0.  That points to coldboot().
 *
 * Memory layout during coldboot execution:
 *
 *   Physical (loaded by ROM)       Runtime (after relocation)
 *   ─────────────────────────      ──────────────────────────
 *   0x0000  BOOT header (128B)     0x0000  CP/M zero page
 *   0x0080  CONFI defaults (128B)  ──→ CFG_ADDR (0xD500, CCP area)
 *   0x0100  Conv tables (384B)     ──→ 0xF680 (OUTCON/INCONV)
 *   0x0280  Boot code (this file)  (discarded after boot)
 *   0x02CE+ BIOS binary            ──→ 0xDA00 (BIOS_BASE)
 *                                      0xDA00  JP table + JTVARS (113B)
 *                                      0xDA71+ BIOS code
 *                                      BSS     ──→ zeroed by coldboot
 *                                      0xF600  IVT + interrupt stack
 *                                      0xF680  OUTCON/INCONV (384B)
 *                                      0xF800  Display memory (80×25)
 *
 * All memcpy/memset calls MUST be inlined by sdcc (no library available).
 * The Makefile checks boot_entry.c.lis for any call _mem* and fails.
 */

#include <string.h>
#include "bios.h"

/* Linker symbols for section boundaries.
 * z88dk linker defines these with double underscore; C adds another
 * underscore prefix, so we use single underscore here → ___name in asm. */
extern byte _BOOT_CODE_tail;
extern byte _BIOS_head;
extern byte _bss_compiler_head;
extern word _bss_compiler_size;

/* Data blocks in BOOT_DATA section (defined in boot_confi.c) */
extern const byte confi_on_disk[128];
extern const byte conv_tables[384];

/* Hardware init (in BIOS section, runs after relocation) */
extern void bios_hw_init(void);

/* Cold boot body — called from coldboot() with valid SP (ROM provides it).
 * Relocates BIOS, copies config data, zeroes BSS.
 *
 * sdcc inlines memcpy as LDIR and memset as LDIR (large) or DJNZ (small).
 * No library functions are linked — verified in the .asm listing. */
static void relocate_bios(void)
{
    /* Relocate BIOS section from physical to runtime address.
     * BIOS binary starts right after the last BOOT sub-section. */
    memcpy((void *)BIOS_BASE,
           &_BOOT_CODE_tail,
           (word)&_bss_compiler_head - BIOS_BASE);

    /* Copy CONFI defaults to CCP area (init-only) */
    memcpy((void *)CFG_ADDR, confi_on_disk, 128);

    /* Copy conversion tables to runtime address */
    memcpy((void *)CONV_ADDR, conv_tables, 384);

    /* Zero BSS.  Cannot use memset() here because __bss_compiler_size
     * is a linker symbol, not a compile-time constant — sdcc emits a
     * library call instead of inlining LDIR. */
    {
        byte *p = &_bss_compiler_head;
        word n = (word)&_bss_compiler_size;
        *p = 0;
        memcpy(p + 1, p, n - 1);
    }
}

/* Forward declaration — bios_boot() never returns. */
extern void bios_boot(void);

/* Cold boot entry point.  Called by ROM via boot pointer at offset 0.
 * __naked: no prologue/epilogue (SP changes mid-function, can't have
 * compiler-generated push/pop). */
void coldboot(void) __naked
{
    __asm__("di\n");
    relocate_bios();
    __asm__("ld sp, #0x0080\n");       /* switch to CP/M DMA buffer area */
    bios_hw_init();
    bios_boot();                       /* enter BIOS cold boot — never returns */
}
