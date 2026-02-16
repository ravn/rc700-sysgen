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


uint8_t hal_read_sw1(void) {
    return port_sw1;
}

uint8_t hal_diskette_size(void) {
    return (port_sw1 >> 7) & 1;
}

void hal_prom_disable(void) {
    port_ramen = 1;
}

void hal_motor(uint8_t on) {
    port_sw1 = on ? 1 : 0;
}

void hal_beep(void) {
    port_bib = 0;
}

/* FDC basic I/O */

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

/* FL02: Wait for FDC RQM=1 DIO=0, then write data byte.
 * Returns 0 on success, non-zero on timeout. */
uint8_t hal_fdc_wait_write(uint8_t data) {
    uint8_t b = 0;
    uint8_t c = 0;
    for (;;) {
        b++;
        if (b == 0) {
            c++;
            if (c == 0) return 1; /* timeout */
        }
        if ((port_fdc_status & 0xC0) == 0x80) {
            port_fdc_data = data;
            return 0;
        }
    }
}

/* FLO3: Wait for FDC RQM=1 DIO=1, then read data byte. */
uint8_t hal_fdc_wait_read(void) {
    uint8_t b = 0;
    uint8_t c = 0;
    for (;;) {
        b++;
        if (b == 0) {
            c++;
            if (c == 0) return 0xFF; /* timeout */
        }
        if ((port_fdc_status & 0xC0) == 0xC0) {
            return port_fdc_data;
        }
    }
}

/* DMA control */

void hal_dma_command(uint8_t cmd) {
    port_dma_cmd = cmd;
}

void hal_dma_mask(uint8_t channel) {
    port_dma_smsk = channel | 0x04; /* bit2=1 -> set mask (disable) */
}

void hal_dma_unmask(uint8_t channel) {
    port_dma_smsk = channel; /* bit2=0 -> clear mask (enable) */
}

void hal_dma_clear_bp(void) {
    port_dma_clbp = 0; /* value ignored */
}

void hal_dma_mode(uint8_t mode) {
    port_dma_mode = mode;
}

void hal_dma_ch_addr(uint8_t ch, uint16_t addr) {
    switch (ch) {
        case 1: port_dma_ch1_addr = addr & 0xFF; port_dma_ch1_addr = addr >> 8; break;
        case 2: port_dma_ch2_addr = addr & 0xFF; port_dma_ch2_addr = addr >> 8; break;
        case 3: port_dma_ch3_addr = addr & 0xFF; port_dma_ch3_addr = addr >> 8; break;
    }
}

void hal_dma_ch_wc(uint8_t ch, uint16_t wc) {
    switch (ch) {
        case 1: port_dma_ch1_wc = wc & 0xFF; port_dma_ch1_wc = wc >> 8; break;
        case 2: port_dma_ch2_wc = wc & 0xFF; port_dma_ch2_wc = wc >> 8; break;
        case 3: port_dma_ch3_wc = wc & 0xFF; port_dma_ch3_wc = wc >> 8; break;
    }
}

uint8_t hal_dma_status(void) {
    return port_dma_cmd; /* Read from command port returns status */
}

void hal_dma_setup(uint8_t channel, uint16_t addr, uint16_t count, uint8_t mode) {
    hal_dma_mask(channel);
    hal_dma_mode(mode);
    hal_dma_clear_bp();
    hal_dma_ch_addr(channel, addr);
    hal_dma_ch_wc(channel, count);
    hal_dma_unmask(channel);
}

/* PIO */

void hal_pio_write_a_data(uint8_t data) { port_pio_a_data = data; }
void hal_pio_write_a_ctrl(uint8_t data) { port_pio_a_ctrl = data; }
void hal_pio_write_b_data(uint8_t data) { port_pio_b_data = data; }
void hal_pio_write_b_ctrl(uint8_t data) { port_pio_b_ctrl = data; }

/* CTC */

void hal_ctc_write(uint8_t channel, uint8_t data) {
    switch (channel) {
        case 0: port_ctc0 = data; break;
        case 1: port_ctc1 = data; break;
        case 2: port_ctc2 = data; break;
        case 3: port_ctc3 = data; break;
    }
}

/* CRT */

void hal_crt_param(uint8_t data) { port_crt_param = data; }
void hal_crt_command(uint8_t data) { port_crt_cmd = data; }
uint8_t hal_crt_status(void) { return port_crt_cmd; }

/* Delay loop — matches DELAY in roa375.asm */
void hal_delay(uint8_t outer, uint8_t inner) {
    uint8_t b, h, l;
    for (b = outer; b != 0; b--) {
        h = inner;
        l = 0xFF;
        while (h != 0 || l != 0) {
            if (l == 0) { h--; l = 0xFF; } else { l--; }
        }
    }
}

/* Interrupt control */
void hal_ei(void) {
    __asm
    ei
    __endasm;
}

void hal_di(void) {
    __asm
    di
    __endasm;
}
