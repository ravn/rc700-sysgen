/* boot_entry.c — Cold boot initialization (BOOT section).
 *
 * Compiled with --codeseg BOOT so code runs at physical address 0x0000,
 * not at BIOS runtime address.  Executes before BIOS relocation.
 *
 * The ROM (ROA375) loads Track 0 to address 0x0000, sets SP to 0xBFFF,
 * and jumps to the boot pointer at offset 0.  That points to cboot().
 */

#include "bios.h"

/* Linker symbols for section boundaries.
 * z88dk linker defines these with double underscore; C adds another
 * underscore prefix, so we use single underscore here → ___name in asm. */
extern byte _BOOT_CODE_tail;
extern byte _BIOS_head;
extern byte _bss_compiler_head;
extern word _bss_compiler_size;

/* Data blocks in BOOT_DATA section (defined in boot_data.c) */
extern const byte confi_defaults[128];
extern const byte conv_tables[384];

/* Hardware init (in BIOS section, runs after relocation) */
extern void bios_hw_init(void);

/* LDIR-based block copy: dst=HL, src=DE, count on stack (sdcccall 1). */
static void boot_copy(void *dst, const void *src, word count) __naked
{
    (void)dst; (void)src; (void)count;
    __asm__("ex de, hl        \n"   /* HL=src, DE=dst (LDIR convention) */
            "pop af            \n"   /* return address */
            "pop bc            \n"   /* count */
            "push af           \n"   /* restore return address */
            "ldir              \n"
            "ret               \n");
}

/* LDIR-based block zero: dst=HL, count=DE (sdcccall 1). */
static void boot_zero(void *dst, word count) __naked
{
    (void)dst; (void)count;
    __asm__("ld (hl), #0       \n"
            "ld b, d           \n"
            "ld c, e           \n"
            "ld e, l           \n"
            "ld d, h           \n"
            "inc de            \n"
            "dec bc            \n"
            "ldir              \n"
            "ret               \n");
}

/* Cold boot body — called from cboot() with valid SP (ROM provides it).
 * Relocates BIOS, copies config data, zeroes BSS. */
static void cboot_body(void)
{
    /* Relocate BIOS section from physical to runtime address.
     * BIOS binary starts right after the last BOOT sub-section. */
    boot_copy((void *)BIOS_BASE,
              &_BOOT_CODE_tail,
              (word)&_bss_compiler_head - BIOS_BASE);

    /* Copy CONFI defaults to CCP area (init-only) */
    boot_copy((void *)CFG_ADDR, &confi_defaults, 128);

    /* Copy conversion tables to runtime address */
    boot_copy((void *)0xF680, &conv_tables, 384);

    /* Zero BSS */
    boot_zero((void *)&_bss_compiler_head, (word)&_bss_compiler_size);
}

/* Cold boot entry point.  Called by ROM via boot pointer at offset 0.
 * __naked: no prologue/epilogue.  __critical: DI at entry (not needed
 * with __naked but documents intent). */
void cboot(void) __naked
{
    __asm__("di                        \n"
            "call _cboot_body          \n"
            "ld sp, #0x0080            \n"   /* CP/M DMA buffer area */
            "call _bios_hw_init        \n"
            "jp 0xDA00                 \n"); /* BIOSAD */
}
