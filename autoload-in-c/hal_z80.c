/*
 * hal_z80.c — Real hardware HAL for RC702 (z88dk/zsdcc target)
 *
 * Uses __sfr __at for zero-overhead IN/OUT port access.
 * See RC702 hardware manual fig. 9 (page 15) for port assignments.
 */

#include "hal.h"

/* System control ports (mirrored in groups of 4 on MIC702/703) */
__sfr __at 0x14 port_sw1;          /* Read: DIP switches; Write: motor */
__sfr __at 0x18 port_ramen;        /* Write: disable PROMs, enable RAM */
__sfr __at 0x1C port_bib;          /* Write: beeper */

/* Z80A-PIO ports */
__sfr __at 0x10 port_pio_a_data;   /* Keyboard data */
__sfr __at 0x11 port_pio_b_data;   /* Parallel I/O data */
__sfr __at 0x12 port_pio_a_ctrl;   /* Keyboard control */
__sfr __at 0x13 port_pio_b_ctrl;   /* Parallel I/O control */

/* Z80A-CTC ports */
__sfr __at 0x0C port_ctc0;         /* Channel 0: SIO-A baud */
__sfr __at 0x0D port_ctc1;         /* Channel 1: SIO-B baud */
__sfr __at 0x0E port_ctc2;         /* Channel 2: display interrupt */
__sfr __at 0x0F port_ctc3;         /* Channel 3: floppy interrupt */

/* Intel 8275 CRT controller */
__sfr __at 0x00 port_crt_param;    /* Parameter port */
__sfr __at 0x01 port_crt_cmd;      /* Command port */

/* uPD765 FDC ports */
__sfr __at 0x04 port_fdc_status;   /* Main status register */
__sfr __at 0x05 port_fdc_data;     /* Data register */

/* AM9517A DMA ports */
__sfr __at 0xF2 port_dma_ch1_addr;
__sfr __at 0xF3 port_dma_ch1_wc;
__sfr __at 0xF4 port_dma_ch2_addr;
__sfr __at 0xF5 port_dma_ch2_wc;
__sfr __at 0xF6 port_dma_ch3_addr;
__sfr __at 0xF7 port_dma_ch3_wc;
__sfr __at 0xF8 port_dma_cmd;
__sfr __at 0xFA port_dma_smsk;
__sfr __at 0xFB port_dma_mode;
__sfr __at 0xFC port_dma_clbp;


uint8_t hal_diskette_size(void) {
    return (port_sw1 >> 7) & 1;
}

void hal_prom_disable(void) {
    port_ramen = 0;
}

void hal_motor(uint8_t on) {
    port_sw1 = on ? 1 : 0;
}

void hal_beep(void) {
    port_bib = 0;
}

void hal_fdc_command(uint8_t cmd) {
    port_fdc_data = cmd;
}

uint8_t hal_fdc_status(void) {
    return port_fdc_status;
}

uint8_t hal_fdc_data_read(void) {
    return port_fdc_data;
}

void hal_fdc_data_write(uint8_t data) {
    port_fdc_data = data;
}

void hal_dma_setup(uint8_t channel, uint16_t addr, uint16_t count, uint8_t mode) {
    /* TODO: implement per-channel DMA setup */
    (void)channel; (void)addr; (void)count; (void)mode;
}

void hal_dma_command(uint8_t cmd) {
    port_dma_cmd = cmd;
}

void hal_pio_write_a_data(uint8_t data) { port_pio_a_data = data; }
void hal_pio_write_a_ctrl(uint8_t data) { port_pio_a_ctrl = data; }
void hal_pio_write_b_data(uint8_t data) { port_pio_b_data = data; }
void hal_pio_write_b_ctrl(uint8_t data) { port_pio_b_ctrl = data; }

void hal_ctc_write(uint8_t channel, uint8_t data) {
    switch (channel) {
        case 0: port_ctc0 = data; break;
        case 1: port_ctc1 = data; break;
        case 2: port_ctc2 = data; break;
        case 3: port_ctc3 = data; break;
    }
}

void hal_crt_param(uint8_t data) { port_crt_param = data; }
void hal_crt_command(uint8_t data) { port_crt_cmd = data; }
