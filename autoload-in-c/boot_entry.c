/*
 * boot_entry.c — BOOT section C code (runs from ROM at 0x0000)
 *
 * Compiled with --codeseg BOOT to place code in BOOT section (ORG 0x0000).
 * These functions run from ROM before hal_prom_disable() disables it.
 * Relocation (ROM→RAM copy) is done by LDIR in crt0.asm BEGIN.
 *
 * Contains:
 *   clear_screen()    — fills display buffer with spaces
 *   init_fdc()        — waits for FDC ready, sends SPECIFY command
 *   display_banner()  — writes " RC700" to screen, enables CRT
 */

#include "hal.h"
#include "boot.h"

extern const char msg_rc700[];

void clear_screen(void) {
    uint8_t *p = dspstr;
    uint16_t i = 80 * 25;
    while (i--) *p++ = 0x20;
}

void init_fdc(void) {
    hal_delay(2, 157);
    while (hal_fdc_status() & 0x1F) ;
    hal_fdc_wait_write(0x03);
    hal_fdc_wait_write(0x4F);
    hal_fdc_wait_write(0x20);
}

void display_banner(void) {
    const uint8_t *src = (const uint8_t *)msg_rc700;
    uint8_t *dst = dspstr;
    uint8_t i = 6;
    while (i--) *dst++ = *src++;
    scroll_offset = 0;
    hal_crt_command(0x23);  /* start display: burst space=0, 8 DMA cycles/burst */
}
