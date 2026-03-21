/*
 * boot_rom.c — BOOT section code (compiled with --codeseg BOOT).
 *
 * Lives in ROM at ORG 0x0000, accessible until prom_disable().
 * Contains:
 *   - begin()          ROM entry point: self-relocate CODE to RAM
 *   - init_fdc()       FDC Specify command (pre-boot only)
 *   - banner_string    Raw banner text (referenced by display_banner in CODE)
 *   - pad_to_nmi_retn() 0xFF padding + NMI handler at 0x0066
 */

#include <string.h>
#ifdef __SDCC
#include <intrinsic.h>
#endif
#include "rom.h"

/* Linker symbols for self-relocation.
 * C adds _ prefix; linker sees __X for extern byte _X.
 * Taking &_X gives the linker-assigned address as a pointer. */
extern byte _BOOT_tail;       /* end of BOOT section = ROM source of CODE payload */
extern const byte intvec;     /* IVT at 0x7000: start of CODE payload */
extern const byte code_end;   /* sentinel at end of CODE payload */

/* Post-relocation init (in rom.c, relocated to RAM) */
extern void init_relocated(void);

/* ROM entry point — must be first function in BOOT section.
 * Copies CODE payload from ROM to RAM at 0x7000, then jumps there.
 * Payload size computed at runtime — z80asm can't DEFC across subsections. */
void begin(void) {
    intrinsic_di();
    __asm__("ld sp, #" STR(ROM_STACK) "\n");
    memcpy((void *)&intvec, &_BOOT_tail, &code_end - &intvec + 1);
    init_relocated();
}

/* Functions only used before prom_disable() — placed in BOOT section
 * to fill padding between begin() and the NMI handler.
 * Called from main() in rom.c after CODE has been copied to RAM. */

/* Initialize FDC with Specify command. */
void init_fdc(void) {
    delay(2, 157);                   /* wait for FDC to become ready */
    while (fdc_status() & 0b00011111) {
        ;
    }                                /* wait until no drives are busy */
    fdc_write_when_ready(0x03);      /* Specify command */
    fdc_write_when_ready(0x4F);      /*   SRT=4 (8ms step), HUT=F (240ms unload) */
    fdc_write_when_ready(0x20);      /*   HLT=10 (32ms load), ND=0 (DMA mode) */
}

/* Banner string — raw bytes in BOOT section, referenced by
 * display_banner_and_start_crt() in CODE via extern.
 * Fills BOOT padding that would otherwise be 0xFF. */
#include "build_stamp.h"
void banner_string(void) __naked {
    __asm__("DEFM \" RC700\"\n"
            "DEFM " BUILD_STAMP_STR "\n");
}

/* Pad with 0xFF to reach 0x0066 where the Z80 NMI vector is hardwired.
 * NMI is unused on RC702; RETN restores IFF1 from IFF2 and returns. */
void pad_to_nmi_retn(void) __naked {
    __asm__("DEFS 0x0066 - ASMPC, 0xFF\n"
        "retn\n");
}
