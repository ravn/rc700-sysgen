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

/* DMA (AM9517A / Intel 8237) */
void hal_dma_setup(uint8_t channel, uint16_t addr, uint16_t count, uint8_t mode);
void hal_dma_command(uint8_t cmd);

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

#endif /* HAL_H */
