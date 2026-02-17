/*
 * init.c — Peripheral initialization for RC702 autoload
 *
 * PIO, CTC, DMA, CRT init are in crt0.asm for the Z80 ROM build.
 * C versions kept here for host testing only.
 * FDC init stays in C for both builds (uses HAL wait functions).
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

void init_ctc(uint8_t mode) FASTCALL {
    hal_ctc_write(0, 0x08);
    hal_ctc_write(0, 0x47 | mode);
    hal_ctc_write(0, 0x20);
    hal_ctc_write(1, 0x47 | mode);
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
    hal_crt_command(0x00);
    hal_crt_param(0x4F);
    hal_crt_param(0x98);
    hal_crt_param(0x9A);
    hal_crt_param(0x5D);
    hal_crt_command(0x80);
    hal_crt_param(0x00);
    hal_crt_param(0x00);
    hal_crt_command(0xE0);
}

#endif /* HOST_TEST */

/*
 * FDC initialization — waits for FDC ready, sends SPECIFY command.
 * Z80 ROM build: implemented in assembly (crt0.asm).
 * Host test build: C implementation below.
 */
#ifdef HOST_TEST
void init_fdc(void) {
    uint8_t status;

    hal_delay(1, 0xFF);
    do {
        status = hal_fdc_status();
    } while ((status & 0x1F) != 0);

    hal_fdc_wait_write(0x03);
    hal_fdc_wait_write(0x4F);
    hal_fdc_wait_write(0x20);
}
#endif /* HOST_TEST */
