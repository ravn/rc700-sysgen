/*
 * hal.h — Hardware Abstraction Layer for RC702 CP/M BIOS
 *
 * Z80: inline port I/O via __sfr (single IN/OUT instructions)
 * Host: real functions in hal_host.c (for testing)
 */

#ifndef HAL_H
#define HAL_H

#include <stdint.h>

#ifdef HOST_TEST

/* Host test stubs (TODO) */
void hal_ei(void);
void hal_di(void);

#else /* Z80 TARGET */

/* I/O port declarations */
__sfr __at 0x00 _port_crt_param;     /* 8275 CRT data */
__sfr __at 0x01 _port_crt_cmd;       /* 8275 CRT command/status */
__sfr __at 0x04 _port_fdc_status;    /* uPD765 FDC status */
__sfr __at 0x05 _port_fdc_data;      /* uPD765 FDC data */
__sfr __at 0x08 _port_sio_a_data;    /* SIO channel A data */
__sfr __at 0x09 _port_sio_b_data;    /* SIO channel B data */
__sfr __at 0x0A _port_sio_a_ctrl;    /* SIO channel A control */
__sfr __at 0x0B _port_sio_b_ctrl;    /* SIO channel B control */
__sfr __at 0x0C _port_ctc0;          /* CTC channel 0 */
__sfr __at 0x0D _port_ctc1;          /* CTC channel 1 */
__sfr __at 0x0E _port_ctc2;          /* CTC channel 2 */
__sfr __at 0x0F _port_ctc3;          /* CTC channel 3 */
__sfr __at 0x10 _port_pio_a_data;    /* PIO channel A data */
__sfr __at 0x11 _port_pio_b_data;    /* PIO channel B data */
__sfr __at 0x12 _port_pio_a_ctrl;    /* PIO channel A control */
__sfr __at 0x13 _port_pio_b_ctrl;    /* PIO channel B control */
__sfr __at 0x14 _port_sw1;           /* DIP switch / motor control */
__sfr __at 0x1C _port_bell;          /* beeper */
__sfr __at 0x44 _port_ctc2_ch0;      /* CTC2 channel 0 (HD board) */
__sfr __at 0x45 _port_ctc2_ch1;      /* CTC2 channel 1 */
__sfr __at 0x46 _port_ctc2_ch2;      /* CTC2 channel 2 */
__sfr __at 0x47 _port_ctc2_ch3;      /* CTC2 channel 3 */

/* DMA ports */
__sfr __at 0xF0 _port_dma_ch0_addr;
__sfr __at 0xF1 _port_dma_ch0_wc;
__sfr __at 0xF2 _port_dma_ch1_addr;
__sfr __at 0xF3 _port_dma_ch1_wc;
__sfr __at 0xF4 _port_dma_ch2_addr;
__sfr __at 0xF5 _port_dma_ch2_wc;
__sfr __at 0xF6 _port_dma_ch3_addr;
__sfr __at 0xF7 _port_dma_ch3_wc;
__sfr __at 0xF8 _port_dma_cmd;
__sfr __at 0xF9 _port_dma_req;
__sfr __at 0xFA _port_dma_smsk;
__sfr __at 0xFB _port_dma_mode;
__sfr __at 0xFC _port_dma_clbp;
__sfr __at 0xFD _port_dma_tmp;
__sfr __at 0xFF _port_dma_mask;

/* WD1000 hard disk ports */
__sfr __at 0x60 _port_hd_data;
__sfr __at 0x61 _port_hd_error;
__sfr __at 0x62 _port_hd_secct;
__sfr __at 0x63 _port_hd_secno;
__sfr __at 0x64 _port_hd_cyllo;
__sfr __at 0x65 _port_hd_cylhi;
__sfr __at 0x66 _port_hd_sdh;
__sfr __at 0x67 _port_hd_status;

/* Inline helpers */
#define hal_ei()  __asm__("ei")
#define hal_di()  __asm__("di")

/* DMA channel address/word count (two consecutive port writes) */
#define hal_dma_ch1_addr(addr) do { \
    _port_dma_ch1_addr = (uint8_t)(addr); \
    _port_dma_ch1_addr = (uint8_t)((addr) >> 8); \
} while(0)
#define hal_dma_ch1_wc(wc) do { \
    _port_dma_ch1_wc = (uint8_t)(wc); \
    _port_dma_ch1_wc = (uint8_t)((wc) >> 8); \
} while(0)
#define hal_dma_ch2_addr(addr) do { \
    _port_dma_ch2_addr = (uint8_t)(addr); \
    _port_dma_ch2_addr = (uint8_t)((addr) >> 8); \
} while(0)
#define hal_dma_ch2_wc(wc) do { \
    _port_dma_ch2_wc = (uint8_t)(wc); \
    _port_dma_ch2_wc = (uint8_t)((wc) >> 8); \
} while(0)
#define hal_dma_ch3_addr(addr) do { \
    _port_dma_ch3_addr = (uint8_t)(addr); \
    _port_dma_ch3_addr = (uint8_t)((addr) >> 8); \
} while(0)
#define hal_dma_ch3_wc(wc) do { \
    _port_dma_ch3_wc = (uint8_t)(wc); \
    _port_dma_ch3_wc = (uint8_t)((wc) >> 8); \
} while(0)

#endif /* HOST_TEST */

#endif /* HAL_H */
