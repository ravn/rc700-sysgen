/*
 * hal_z80.c — Z80 HAL functions (z88dk/zsdcc target)
 *
 * Most HAL functions are inlined as macros in hal.h.
 * Functions here contain loops that can't be macros.
 */

#include "hal.h"

/* FL02: Wait for FDC RQM=1 DIO=0, then write data byte.
 * Returns 0 on success, non-zero on timeout. */
uint8_t hal_fdc_wait_write(uint8_t data) __z88dk_fastcall {
    uint8_t b = 0;
    uint8_t c = 0;
    for (;;) {
        b++;
        if (b == 0) {
            c++;
            if (c == 0) return 1; /* timeout */
        }
        if ((_port_fdc_status & 0xC0) == 0x80) {
            _port_fdc_data = data;
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
        if ((_port_fdc_status & 0xC0) == 0xC0) {
            return _port_fdc_data;
        }
    }
}

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
