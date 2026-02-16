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
static uint8_t mock_dma_status = 0;

/* FDC data FIFO for multi-byte read sequences */
#define FDC_FIFO_SIZE 16
static uint8_t fdc_read_fifo[FDC_FIFO_SIZE];
static int fdc_read_fifo_head = 0;
static int fdc_read_fifo_count = 0;

/* Call log for test assertions */
#define MAX_LOG 512

enum log_type {
    LOG_PROM_DISABLE, LOG_MOTOR, LOG_BEEP,
    LOG_FDC_CMD, LOG_FDC_WRITE,
    LOG_DMA_SETUP, LOG_DMA_CMD, LOG_DMA_MASK, LOG_DMA_UNMASK,
    LOG_DMA_MODE, LOG_DMA_CLEAR_BP, LOG_DMA_ADDR, LOG_DMA_WC,
    LOG_PIO_A_DATA, LOG_PIO_A_CTRL, LOG_PIO_B_DATA, LOG_PIO_B_CTRL,
    LOG_CTC, LOG_CRT_PARAM, LOG_CRT_CMD,
    LOG_DELAY, LOG_EI, LOG_DI,
    LOG_SW1_WRITE
};

typedef struct {
    enum log_type type;
    uint8_t data;
    uint16_t data16;
} log_entry_t;

static log_entry_t call_log[MAX_LOG];
static int log_count = 0;

static void log_call(enum log_type type, uint8_t data) {
    if (log_count < MAX_LOG) {
        call_log[log_count].type = type;
        call_log[log_count].data = data;
        call_log[log_count].data16 = 0;
        log_count++;
    }
}

static void log_call16(enum log_type type, uint8_t data, uint16_t data16) {
    if (log_count < MAX_LOG) {
        call_log[log_count].type = type;
        call_log[log_count].data = data;
        call_log[log_count].data16 = data16;
        log_count++;
    }
}

/* Test helpers — declared extern in test files */
void mock_reset(void) {
    log_count = 0;
    mock_sw1 = 0x80;
    mock_fdc_status = 0x80;
    mock_fdc_data = 0;
    mock_dma_status = 0;
    fdc_read_fifo_head = 0;
    fdc_read_fifo_count = 0;
}

void mock_set_sw1(uint8_t val) { mock_sw1 = val; }
void mock_set_fdc_status(uint8_t val) { mock_fdc_status = val; }
void mock_set_fdc_data(uint8_t val) { mock_fdc_data = val; }
void mock_set_dma_status(uint8_t val) { mock_dma_status = val; }
int mock_get_log_count(void) { return log_count; }

void mock_fdc_push_read(uint8_t val) {
    if (fdc_read_fifo_count < FDC_FIFO_SIZE) {
        int idx = (fdc_read_fifo_head + fdc_read_fifo_count) % FDC_FIFO_SIZE;
        fdc_read_fifo[idx] = val;
        fdc_read_fifo_count++;
    }
}

log_entry_t *mock_get_log(void) { return call_log; }

/* HAL implementation */

uint8_t hal_read_sw1(void) {
    return mock_sw1;
}

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
    if (fdc_read_fifo_count > 0) {
        uint8_t val = fdc_read_fifo[fdc_read_fifo_head];
        fdc_read_fifo_head = (fdc_read_fifo_head + 1) % FDC_FIFO_SIZE;
        fdc_read_fifo_count--;
        return val;
    }
    return mock_fdc_data;
}

void hal_fdc_data_write(uint8_t data) {
    log_call(LOG_FDC_WRITE, data);
}

uint8_t hal_fdc_wait_write(uint8_t data) {
    log_call(LOG_FDC_WRITE, data);
    return 0; /* always succeeds in mock */
}

uint8_t hal_fdc_wait_read(void) {
    return hal_fdc_data_read();
}

/* DMA */

void hal_dma_command(uint8_t cmd) {
    log_call(LOG_DMA_CMD, cmd);
}

void hal_dma_mask(uint8_t channel) {
    log_call(LOG_DMA_MASK, channel);
}

void hal_dma_unmask(uint8_t channel) {
    log_call(LOG_DMA_UNMASK, channel);
}

void hal_dma_clear_bp(void) {
    log_call(LOG_DMA_CLEAR_BP, 0);
}

void hal_dma_mode(uint8_t mode) {
    log_call(LOG_DMA_MODE, mode);
}

void hal_dma_ch_addr(uint8_t ch, uint16_t addr) {
    log_call16(LOG_DMA_ADDR, ch, addr);
}

void hal_dma_ch_wc(uint8_t ch, uint16_t wc) {
    log_call16(LOG_DMA_WC, ch, wc);
}

uint8_t hal_dma_status(void) {
    return mock_dma_status;
}

void hal_dma_setup(uint8_t channel, uint16_t addr, uint16_t count, uint8_t mode) {
    log_call(LOG_DMA_MASK, channel);
    log_call(LOG_DMA_MODE, mode);
    log_call(LOG_DMA_CLEAR_BP, 0);
    log_call16(LOG_DMA_ADDR, channel, addr);
    log_call16(LOG_DMA_WC, channel, count);
    log_call(LOG_DMA_UNMASK, channel);
}

/* PIO */

void hal_pio_write_a_data(uint8_t data) { log_call(LOG_PIO_A_DATA, data); }
void hal_pio_write_a_ctrl(uint8_t data) { log_call(LOG_PIO_A_CTRL, data); }
void hal_pio_write_b_data(uint8_t data) { log_call(LOG_PIO_B_DATA, data); }
void hal_pio_write_b_ctrl(uint8_t data) { log_call(LOG_PIO_B_CTRL, data); }

/* CTC */

void hal_ctc_write(uint8_t channel, uint8_t data) {
    log_call(LOG_CTC, (channel << 4) | (data & 0x0F));
}

/* CRT */

void hal_crt_param(uint8_t data) { log_call(LOG_CRT_PARAM, data); }
void hal_crt_command(uint8_t data) { log_call(LOG_CRT_CMD, data); }
uint8_t hal_crt_status(void) { return 0; }

/* Delay — no-op in host tests */
void hal_delay(uint8_t outer, uint8_t inner) {
    log_call(LOG_DELAY, outer);
    (void)inner;
}

/* Interrupt control — no-op in host tests */
void hal_ei(void) { log_call(LOG_EI, 0); }
void hal_di(void) { log_call(LOG_DI, 0); }
