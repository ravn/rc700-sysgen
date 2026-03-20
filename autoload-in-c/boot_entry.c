/*
 * boot_entry.c — BOOT section C code (runs from ROM at 0x0000)
 *
 * Compiled with --codeseg BOOT to place code in BOOT section (ORG 0x0000).
 * These functions run from ROM before hal_prom_disable() disables it.
 *
 * Contains:
 *   begin()           — ROM entry: DI, SP, LDIR self-relocation, JP init
 *   clear_screen()    — fills display buffer with spaces
 *   init_fdc()        — waits for FDC ready, sends SPECIFY command
 *   display_banner()  — writes " RC700" to screen, enables CRT
 */

#include <string.h>
#include <intrinsic.h>
#include "hal.h"
#include "boot.h"

/* Linker symbols for self-relocation.
 * C adds _ prefix: _X → __X in linker namespace. */
extern byte _CODE_head;     /* __CODE_head = 0x7000 (IVT/CODE start) */
extern byte _NMI_tail;      /* __NMI_tail  = 0x0068 (PROM offset of CODE) */
extern byte _tail;           /* __tail = end of last section */

/* Post-relocation init (in init.c, relocated to RAM) */
extern void init_relocated(void);

/* ROM entry point — called at address 0x0000 (must be first in BOOT).
 * Copies entire PROM from ROM to RAM so CODE lands at 0x7000,
 * then jumps to init_relocated (now in RAM).
 *
 * __naked: SP is set mid-function.
 * LDIR addresses use linker expressions (resolved at link time, not
 * runtime) — inline asm is more compact than C pointer arithmetic. */
void begin(void) __naked
{
    intrinsic_di();
    __asm__("ld sp, #" STR(ROM_STACK) "   \n"
            "ld hl, #0x0000               \n"
            "ld de, #__CODE_head - __NMI_tail  \n"
            "ld bc, #__tail - __CODE_head + __NMI_tail \n"
            "ldir                         \n");
    init_relocated();
}

extern const char msg_rc700[];

void clear_screen(void) {
    byte *p = dspstr;
    word i = 80 * 25;
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
    const byte *src = (const byte *)msg_rc700;
    byte *dst = dspstr;
    byte i = 6;
    while (i--) *dst++ = *src++;
    scroll_offset = 0;
    hal_crt_command(0x23);  /* start display: burst space=0, 8 DMA cycles/burst */
}
