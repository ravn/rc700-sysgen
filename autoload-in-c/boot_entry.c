/*
 * boot_entry.c — Self-relocation loop (runs from ROM at 0x0000)
 *
 * Compiled with --codeseg BOOT to place code in BOOT section (ORG 0x0000).
 * Called from crt0.asm entry point after DI + SP setup.
 *
 * Copies the CODE section payload from ROM (right after BOOT) to RAM at 0x7000.
 * Uses linker-generated symbols to determine source address and byte count.
 */

#include <stdint.h>

/* Linker-generated section boundary symbols */
extern uint8_t _NMI_tail[];    /* end of NMI section in ROM = start of payload */
extern uint8_t _CODE_head[];   /* logical start of CODE section (0x7000) */
extern uint8_t _tail[];        /* logical end of all relocated sections */

void relocate(void) {
    uint16_t len = (uint16_t)_tail - (uint16_t)_CODE_head;
    uint8_t *src = _NMI_tail;
    uint8_t *dst = (uint8_t *)0x7000;
    do { *dst++ = *src++; } while (--len);
}
