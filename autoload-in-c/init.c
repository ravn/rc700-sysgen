/*
 * init.c — Peripheral initialization for RC702 autoload
 *
 * init_peripherals() does PIO, CTC, DMA, CRT setup in one function,
 * called from the INIT_RELOCATED asm stub in crt0.asm.
 * Individual init_pio/ctc/dma/crt kept for host testing.
 * FDC init is also here, shared between Z80 and host builds.
 */

#include "hal.h"
#include "boot.h"

#ifdef HOST_TEST

void init_pio(void) {
    hal_pio_write_a_ctrl(0x02);
    hal_pio_write_b_ctrl(0x04);
    hal_pio_write_a_ctrl(0x4F);
    hal_pio_write_b_ctrl(0x0F);
    hal_pio_write_a_ctrl(0x83);
    hal_pio_write_b_ctrl(0x83);
}

void init_ctc(void) {
    hal_ctc_write(0, 0x08);
    hal_ctc_write(0, 0x47);    /* counter mode, falling edge, TC follows, reset */
    hal_ctc_write(0, 0x20);
    hal_ctc_write(1, 0x47);
    hal_ctc_write(1, 0x20);
    hal_ctc_write(2, 0xD7);
    hal_ctc_write(2, 0x01);
    hal_ctc_write(3, 0xD7);
    hal_ctc_write(3, 0x01);
}

void init_dma(void) {
    hal_dma_command(0x20);
    hal_dma_mode(0xC0);
    hal_dma_unmask(0);
    hal_dma_mode(0x4A);
    hal_dma_mode(0x4B);
}

void init_crt(void) {
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

void init_fdc(void) {
    hal_delay(2, 157);
    while (hal_fdc_status() & 0x1F) ;
    hal_fdc_wait_write(0x03);
    hal_fdc_wait_write(0x4F);
    hal_fdc_wait_write(0x20);
}

#endif /* HOST_TEST */

/*
 * init_peripherals — combined PIO/CTC/DMA/CRT initialization.
 * Called from INIT_RELOCATED in crt0.asm after SP/I/IM2 setup.
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
