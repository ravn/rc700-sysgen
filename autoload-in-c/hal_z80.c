/*
 * hal_z80.c — C implementations of HAL functions for Z80 target
 *
 * These functions were originally hand-written assembly in crt0.asm.
 * sdcc generates nearly identical code from C (±1 byte), so they're
 * written in C for readability. hal_delay remains in assembly (crt0.asm)
 * because sdcc generates 8 bytes more than the hand-written version.
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
