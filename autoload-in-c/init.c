/*
 * init.c — Peripheral initialization for RC702 autoload
 *
 * init_peripherals() does PIO, CTC, DMA, CRT setup in one function,
 * called from the INIT_RELOCATED asm stub in crt0.asm.
 * FDC init is also here, called from main() in boot.c.
 */

#include "hal.h"
#include "boot.h"

#include <intrinsic.h>

/* Set Z80 I register.  sdcccall(1) passes byte in A; ld i,a uses it.
 * Must NOT be inline — see rcbios-in-c documentation. */
static void set_i_reg(byte page)
{
    (void)page;
    __asm__("ld i, a\n");
}

/* Post-relocation entry point.  Called from BEGIN after LDIR.
 * Sets SP, I register, IM2, then calls init_peripherals + main.
 * __naked because we set SP mid-function. */
void init_relocated(void) __naked
{
    __asm__("ld sp, #" STR(ROM_STACK) "\n");
    set_i_reg(INTVEC_PAGE);
    intrinsic_im_2();
    init_peripherals();
    main();
    /* halt_forever — should never reach here */
    for (;;)
        ;
}

/*
 * init_peripherals — combined PIO/CTC/DMA/CRT initialization.
 * Uses hal macros which expand to direct __sfr port writes on Z80.
 */
void init_peripherals(void) {
    /* PIO setup */
    hal_pio_write_a_ctrl(0x02);
    hal_pio_write_b_ctrl(0x04);
    hal_pio_write_a_ctrl(0x4F);
    hal_pio_write_b_ctrl(0x0F);
    hal_pio_write_a_ctrl(0x83);
    hal_pio_write_b_ctrl(0x83);

    /* CTC setup */
    hal_ctc_write(0, 0x08);    /* interrupt vector base (D0=0: vector word) */
    hal_ctc_write(0, 0x47);    /* counter mode, falling edge, TC follows, reset */
    hal_ctc_write(0, 0x20);    /* time constant = 32 */
    hal_ctc_write(1, 0x47);    /* same config as Ch0 */
    hal_ctc_write(1, 0x20);
    hal_ctc_write(2, 0xD7);
    hal_ctc_write(2, 0x01);
    hal_ctc_write(3, 0xD7);
    hal_ctc_write(3, 0x01);

    /* DMA setup */
    hal_dma_command(0x20);
    hal_dma_mode(0xC0);
    hal_dma_unmask(0);
    hal_dma_mode(0x4A);
    hal_dma_mode(0x4B);

    /* CRT setup — Intel 8275 commands (bits 7-5 = command code) */
    hal_crt_command(0x00);  /* reset (expect 4 param bytes) */
    hal_crt_param(0x4F);    /*   S=0, H=79: 80 chars/row */
    hal_crt_param(0x98);    /*   V=2 vretrace, R=24: 25 rows */
    hal_crt_param(0x9A);    /*   L=9 underline pos, U=10 lines/char */
    hal_crt_param(0x5D);    /*   F=0, M=1 transparent, C=01 blink underline cursor, Z=28 hretrace */
    hal_crt_command(0x80);  /* load cursor (expect 2 param bytes) */
    hal_crt_param(0x00);    /*   column = 0 */
    hal_crt_param(0x00);    /*   row = 0 */
    hal_crt_command(0xE0);  /* preset counters */
}

/* Functions moved from boot_entry.c (BOOT section) to CODE section
 * so the unity build can optimize across them.  They run after
 * relocation to RAM, called from main() in boot.c. */

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
    extern const char msg_rc700[];
    const byte *src = (const byte *)msg_rc700;
    byte *dst = dspstr;
    byte i = 6;
    while (i--) *dst++ = *src++;
    scroll_offset = 0;
    hal_crt_command(0x23);
}
