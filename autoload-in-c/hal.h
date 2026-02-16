/*
 * hal.h — Hardware Abstraction Layer for RC702 autoload PROM
 *
 * Isolates all port I/O behind a C interface so the same boot logic
 * compiles for both the real Z80 target (z88dk) and a host test harness.
 */

#ifndef HAL_H
#define HAL_H

#include <stdint.h>

/* Diskette size detection */
uint8_t hal_diskette_size(void);    /* 0 = maxi/8", 1 = mini/5.25" */

/* Switch register raw read */
uint8_t hal_read_sw1(void);

/* PROM control */
void hal_prom_disable(void);        /* Disable PROM0+PROM1, enable RAM */

/* Mini floppy motor */
void hal_motor(uint8_t on);         /* 1 = start, 0 = stop */

/* Beeper */
void hal_beep(void);

/* FDC (uPD765 / Intel 8272) */
void hal_fdc_command(uint8_t cmd);
uint8_t hal_fdc_status(void);
uint8_t hal_fdc_data_read(void);
void hal_fdc_data_write(uint8_t data);
uint8_t hal_fdc_wait_write(uint8_t data); /* FL02: poll RQM+DIO=0, write */
uint8_t hal_fdc_wait_read(void);          /* FLO3: poll RQM+DIO=1, read */

/* DMA (AM9517A / Intel 8237) */
void hal_dma_setup(uint8_t channel, uint16_t addr, uint16_t count, uint8_t mode);
void hal_dma_command(uint8_t cmd);
void hal_dma_mask(uint8_t channel);       /* Set mask (disable channel) */
void hal_dma_unmask(uint8_t channel);     /* Clear mask (enable channel) */
void hal_dma_clear_bp(void);              /* Clear byte pointer flip-flop */
void hal_dma_mode(uint8_t mode);          /* Set channel mode */
void hal_dma_ch_addr(uint8_t ch, uint16_t addr); /* Set channel address */
void hal_dma_ch_wc(uint8_t ch, uint16_t wc);     /* Set channel word count */
uint8_t hal_dma_status(void);             /* Read DMA status register */

/* PIO (Z80A-PIO) */
void hal_pio_write_a_data(uint8_t data);
void hal_pio_write_a_ctrl(uint8_t data);
void hal_pio_write_b_data(uint8_t data);
void hal_pio_write_b_ctrl(uint8_t data);

/* CTC (Z80A-CTC) */
void hal_ctc_write(uint8_t channel, uint8_t data);

/* CRT (Intel 8275) */
void hal_crt_param(uint8_t data);
void hal_crt_command(uint8_t data);
uint8_t hal_crt_status(void);

/* Delay loop (cf. rob358 FDSTAR W1/W2) */
void hal_delay(uint8_t outer, uint8_t inner);

/* Interrupt control */
void hal_ei(void);
void hal_di(void);

#endif /* HAL_H */
