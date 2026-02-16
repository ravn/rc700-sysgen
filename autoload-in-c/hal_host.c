/*
 * hal_host.c — Mock hardware HAL for host-native testing
 *
 * Records port writes and returns configurable values for port reads.
 * Link this instead of hal_z80.c when compiling for host unit tests.
 */

#include "hal.h"
#include <string.h>

/* Mock state — set these from test code before calling boot logic */
static uint8_t mock_sw1 = 0x80;        /* default: bit 7 set = mini floppy */
static uint8_t mock_fdc_status = 0x80;  /* RQM set, ready */
static uint8_t mock_fdc_data = 0;

/* Call log for test assertions */
#define MAX_LOG 256
static struct {
    enum { LOG_PROM_DISABLE, LOG_MOTOR, LOG_BEEP, LOG_FDC_CMD,
           LOG_DMA_SETUP, LOG_PIO, LOG_CTC, LOG_CRT } type;
    uint8_t data;
} call_log[MAX_LOG];
static int log_count = 0;

static void log_call(int type, uint8_t data) {
    if (log_count < MAX_LOG) {
        call_log[log_count].type = type;
        call_log[log_count].data = data;
        log_count++;
    }
}

/* Test helpers */
void mock_reset(void) {
    log_count = 0;
    mock_sw1 = 0x80;
    mock_fdc_status = 0x80;
    mock_fdc_data = 0;
}

void mock_set_sw1(uint8_t val) { mock_sw1 = val; }
void mock_set_fdc_status(uint8_t val) { mock_fdc_status = val; }
void mock_set_fdc_data(uint8_t val) { mock_fdc_data = val; }
int mock_get_log_count(void) { return log_count; }

/* HAL implementation */

uint8_t hal_diskette_size(void) {
    return (mock_sw1 >> 7) & 1;
}

void hal_prom_disable(void) {
    log_call(LOG_PROM_DISABLE, 0);
}

void hal_motor(uint8_t on) {
    log_call(LOG_MOTOR, on);
}

void hal_beep(void) {
    log_call(LOG_BEEP, 0);
}

void hal_fdc_command(uint8_t cmd) {
    log_call(LOG_FDC_CMD, cmd);
}

uint8_t hal_fdc_status(void) {
    return mock_fdc_status;
}

uint8_t hal_fdc_data_read(void) {
    return mock_fdc_data;
}

void hal_fdc_data_write(uint8_t data) {
    log_call(LOG_FDC_CMD, data);
}

void hal_dma_setup(uint8_t channel, uint16_t addr, uint16_t count, uint8_t mode) {
    log_call(LOG_DMA_SETUP, channel);
    (void)addr; (void)count; (void)mode;
}

void hal_dma_command(uint8_t cmd) {
    log_call(LOG_DMA_SETUP, cmd);
}

void hal_pio_write_a_data(uint8_t data) { log_call(LOG_PIO, data); }
void hal_pio_write_a_ctrl(uint8_t data) { log_call(LOG_PIO, data); }
void hal_pio_write_b_data(uint8_t data) { log_call(LOG_PIO, data); }
void hal_pio_write_b_ctrl(uint8_t data) { log_call(LOG_PIO, data); }

void hal_ctc_write(uint8_t channel, uint8_t data) {
    log_call(LOG_CTC, (channel << 4) | (data & 0x0F));
}

void hal_crt_param(uint8_t data) { log_call(LOG_CRT, data); }
void hal_crt_command(uint8_t data) { log_call(LOG_CRT, data); }
