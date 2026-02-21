/*
 * hal.h — Hardware Abstraction Layer for RC702 autoload PROM
 *
 * Isolates all port I/O behind a C interface so the same boot logic
 * compiles for both the real Z80 target (z88dk) and a host test harness.
 *
 * On Z80: simple port writes are inline via __sfr; only FL02/FLO3 remain
 * as real functions (they contain loops).
 * On host: all functions are real, with mock recording for test assertions.
 */

#ifndef HAL_H
#define HAL_H

#include <stdint.h>

#ifdef HOST_TEST

/* ================================================================
 * HOST TEST BUILD — all functions are real (defined in hal_host.c)
 * ================================================================ */

uint8_t hal_diskette_size(void);
uint8_t hal_read_sw1(void);
void hal_prom_disable(void);
void hal_motor(uint8_t on);
void hal_beep(void);

void hal_fdc_command(uint8_t cmd);
uint8_t hal_fdc_status(void);
uint8_t hal_fdc_data_read(void);
void hal_fdc_data_write(uint8_t data);
void hal_fdc_wait_write(uint8_t data);
uint8_t hal_fdc_wait_read(void);

void hal_dma_command(uint8_t cmd);
void hal_dma_mask(uint8_t channel);
void hal_dma_unmask(uint8_t channel);
void hal_dma_clear_bp(void);
void hal_dma_mode(uint8_t mode);
void hal_dma_ch1_addr(uint16_t addr);
void hal_dma_ch1_wc(uint16_t wc);
void hal_dma_ch2_addr(uint16_t addr);
void hal_dma_ch2_wc(uint16_t wc);
void hal_dma_ch3_addr(uint16_t addr);
void hal_dma_ch3_wc(uint16_t wc);
uint8_t hal_dma_status(void);

void hal_pio_write_a_data(uint8_t data);
void hal_pio_write_a_ctrl(uint8_t data);
void hal_pio_write_b_data(uint8_t data);
void hal_pio_write_b_ctrl(uint8_t data);

void hal_ctc_write(uint8_t channel, uint8_t data);

void hal_crt_param(uint8_t data);
void hal_crt_command(uint8_t data);
uint8_t hal_crt_status(void);

void hal_delay(uint8_t outer, uint8_t inner);
void hal_ei(void);
void hal_di(void);

#else /* Z80 TARGET BUILD */

/* ================================================================
 * Z80 BUILD — inline port I/O via __sfr, minimal function calls
 * ================================================================ */

/* Port declarations — sdcc __sfr __at maps a C variable to a Z80 I/O port.
 * Reading the variable compiles to IN A,(port), writing to OUT (port),A.
 * Each port access is just two bytes of Z80 code with no function call
 * overhead.  However, sdcc naively reloads A between consecutive writes
 * to different ports with the same value (e.g. two OUT instructions both
 * needing A=0x4F).  Custom peephole rules in peephole.def eliminate these
 * redundant loads, saving 2 bytes per occurrence in init sequences. */
__sfr __at 0x14 _port_sw1;
__sfr __at 0x18 _port_ramen;
__sfr __at 0x1C _port_bib;
__sfr __at 0x10 _port_pio_a_data;
__sfr __at 0x11 _port_pio_b_data;
__sfr __at 0x12 _port_pio_a_ctrl;
__sfr __at 0x13 _port_pio_b_ctrl;
__sfr __at 0x0C _port_ctc0;
__sfr __at 0x0D _port_ctc1;
__sfr __at 0x0E _port_ctc2;
__sfr __at 0x0F _port_ctc3;
__sfr __at 0x00 _port_crt_param;
__sfr __at 0x01 _port_crt_cmd;
__sfr __at 0x04 _port_fdc_status;
__sfr __at 0x05 _port_fdc_data;
__sfr __at 0xF2 _port_dma_ch1_addr;
__sfr __at 0xF3 _port_dma_ch1_wc;
__sfr __at 0xF4 _port_dma_ch2_addr;
__sfr __at 0xF5 _port_dma_ch2_wc;
__sfr __at 0xF6 _port_dma_ch3_addr;
__sfr __at 0xF7 _port_dma_ch3_wc;
__sfr __at 0xF8 _port_dma_cmd;
__sfr __at 0xFA _port_dma_smsk;
__sfr __at 0xFB _port_dma_mode;
__sfr __at 0xFC _port_dma_clbp;

/* Simple port read/write — compile to single IN/OUT instructions */
#define hal_read_sw1()              (_port_sw1)
#define hal_diskette_size()         ((_port_sw1 >> 7) & 1)
#define hal_prom_disable()          (_port_ramen = 1)
#define hal_motor(on)               (_port_sw1 = (on) ? 1 : 0)
#define hal_beep()                  (_port_bib = 0)

#define hal_fdc_command(cmd)        (_port_fdc_data = (cmd))
#define hal_fdc_status()            (_port_fdc_status)
#define hal_fdc_data_read()         (_port_fdc_data)
#define hal_fdc_data_write(d)       (_port_fdc_data = (d))

#define hal_dma_command(cmd)        (_port_dma_cmd = (cmd))
#define hal_dma_mask(ch)            (_port_dma_smsk = (ch) | 0x04)
#define hal_dma_unmask(ch)          (_port_dma_smsk = (ch))
#define hal_dma_clear_bp()          (_port_dma_clbp = 0)
#define hal_dma_mode(m)             (_port_dma_mode = (m))
#define hal_dma_status()            (_port_dma_cmd)

#define hal_pio_write_a_data(d)     (_port_pio_a_data = (d))
#define hal_pio_write_a_ctrl(d)     (_port_pio_a_ctrl = (d))
#define hal_pio_write_b_data(d)     (_port_pio_b_data = (d))
#define hal_pio_write_b_ctrl(d)     (_port_pio_b_ctrl = (d))

#define hal_crt_param(d)            (_port_crt_param = (d))
#define hal_crt_command(d)          (_port_crt_cmd = (d))
#define hal_crt_status()            (_port_crt_cmd)

#define hal_ei()  __asm ei __endasm
#define hal_di()  __asm di __endasm

/* CTC channel writes — direct port I/O, no switch overhead */
#define hal_ctc_write(ch, d) do { \
    if      ((ch) == 0) _port_ctc0 = (d); \
    else if ((ch) == 1) _port_ctc1 = (d); \
    else if ((ch) == 2) _port_ctc2 = (d); \
    else                _port_ctc3 = (d); \
} while(0)

/* DMA channel 1 address/word count — two consecutive port writes */
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

/* C implementations in hal_z80.c — sdcc generates near-optimal code */
void hal_fdc_wait_write(uint8_t data);
uint8_t hal_fdc_wait_read(void);
void hal_delay(uint8_t outer, uint8_t inner);

#endif /* HOST_TEST */

#endif /* HAL_H */
