/*
 * test.c — Minimal bare-metal RC700 test built with LLVM-Z80
 *
 * Build:  make
 * Asm:    make asm
 */

#include "rc700.h"

/* ================================================================
 * FDC helpers
 * ================================================================ */

void fdc_write_when_ready(byte val) {
    while (!(port_in(FDC_STATUS) & 0x80))
        ;
    port_out(FDC_DATA, val);
}

byte fdc_read_when_ready(void) {
    while (!(port_in(FDC_STATUS) & 0x80))
        ;
    return port_in(FDC_DATA);
}

/* Timed delay — volatile prevents optimizer elimination */
void delay(byte outer, byte inner) {
    while (outer--) {
        volatile byte i = inner;
        while (i--)
            ;
    }
}

/* ================================================================
 * Entry point — runs from ROM at 0x0000
 * ================================================================ */

void _start(void) {
    z80_di();
    z80_set_sp(0xBFFF);

    /* Init CRT: start display */
    port_out(CRT_CMD, 0x00);
    delay(1, 100);
    port_out(CRT_PARAM, 0x47);
    port_out(CRT_PARAM, 0x18);

    /* Init PIO port A: input mode */
    port_out(PIO_A_CTRL, 0xCF);
    port_out(PIO_A_CTRL, 0xFF);

    /* Init CTC channel 2 */
    port_out(CTC2, 0xA5);
    port_out(CTC2, 0x01);

    /* FDC Specify command */
    fdc_write_when_ready(0x03);
    fdc_write_when_ready(0x4F);
    fdc_write_when_ready(0x10);

    z80_halt();
}
