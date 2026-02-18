/*
 * hal_z80.c — C implementations of HAL functions for Z80 target
 *
 * These functions were originally hand-written assembly in crt0.asm.
 * sdcc generates nearly identical code from C, so they're written in C
 * for readability.
 *
 * hal_delay timing note:
 *   The assembly version used dec a/jr nz (16 T-states/iteration) for the
 *   innermost loop.  sdcc generates djnz (13 T-states/iteration), making
 *   the delay ~19% shorter for the same parameters.  Callers that need to
 *   match the original timing must adjust their outer/inner values.
 *   See init_fdc in crt0.asm for the compensated call (2, 157) that matches
 *   the original (1, 0xFF) assembly timing within 0.3%.
 *   If hal_delay is ever reverted to assembly, restore init_fdc to (1, 0xFF).
 */

#include "hal.h"

void hal_fdc_wait_write(uint8_t data) {
    uint16_t t = 0;
    do {
        if ((_port_fdc_status & 0xC0) == 0x80) {
            _port_fdc_data = data;
            return;
        }
    } while (++t);
}

uint8_t hal_fdc_wait_read(void) {
    uint16_t t = 0;
    do {
        if ((_port_fdc_status & 0xC0) == 0xC0) {
            return _port_fdc_data;
        }
    } while (++t);
    return 0xFF;
}

void hal_delay(uint8_t outer, uint8_t inner) {
    if (!outer) return;
    do {
        uint8_t mid = inner;
        do {
            uint8_t k = 0;
            do { } while (--k);
        } while (--mid);
    } while (--outer);
}
