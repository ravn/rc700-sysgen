/*
 * init.c — Peripheral initialization for RC702 autoload
 *
 * Initializes PIO, CTC, DMA, CRT, and FDC controllers.
 * Init sequences derived from roa375.asm (lines 348-481).
 */

#include "hal.h"

/*
 * PIO initialization — from PIOINT (roa375.asm lines 348-364)
 * Sets up Z80A-PIO for keyboard input (port A) and parallel output (port B).
 */
void init_pio(void) {
    /* Set interrupt vectors */
    hal_pio_write_a_ctrl(0x02); /* Port A interrupt vector = 2 */
    hal_pio_write_b_ctrl(0x04); /* Port B interrupt vector = 4 */

    /* Set operating modes */
    hal_pio_write_a_ctrl(0x4F); /* Port A: input mode, I/O select follows */
    hal_pio_write_b_ctrl(0x0F); /* Port B: output mode, I/O select follows */

    /* Set interrupt control words */
    hal_pio_write_a_ctrl(0x83); /* Port A: enable int, OR-mode, low active, mask follows */
    hal_pio_write_b_ctrl(0x83); /* Port B: same */
}

/*
 * CTC initialization — from CTCINT (roa375.asm lines 373-404)
 * Configures 4 counter/timer channels.  Ch2 = display interrupt, Ch3 = floppy.
 *
 * Note: the POP AF between vector write and Ch0 config retrieves the mode
 * byte pushed by PIOINT.  In C we pass it via the 'mode' parameter.
 */
void init_ctc(uint8_t mode) {
    /* Channel 0: set interrupt vector base (bit0=0 means vector word) */
    hal_ctc_write(0, 0x08);     /* Vector base = 8 for all 4 channels */

    /* Channel 0: counter, prescale=16, falling edge, TC follows, reset */
    hal_ctc_write(0, 0x47 | mode); /* 0x47 OR'd with mode bits */
    hal_ctc_write(0, 0x20);     /* Time constant = 32 */

    /* Channel 1: same config as Ch0 */
    hal_ctc_write(1, 0x47 | mode);
    hal_ctc_write(1, 0x20);     /* Time constant = 32 */

    /* Channel 2: display interrupt */
    hal_ctc_write(2, 0xD7);     /* Int enable, counter, prescale=16, falling, TC follows, reset */
    hal_ctc_write(2, 0x01);     /* Time constant = 1 (interrupt on every edge) */

    /* Channel 3: floppy interrupt */
    hal_ctc_write(3, 0xD7);     /* Same config as Ch2 */
    hal_ctc_write(3, 0x01);     /* Time constant = 1 */
}

/*
 * DMA initialization — from DMAINT (roa375.asm lines 407-420)
 * Sets up AM9517A DMA controller.
 */
void init_dma(void) {
    /* Command register: fixed priority, normal timing, late write, DREQ high, DACK low */
    hal_dma_command(0x20);

    /* Ch0: cascade mode (pass-through) */
    hal_dma_mode(0xC0);         /* Cascade mode, channel 0 */
    hal_dma_unmask(0);          /* Enable channel 0 */

    /* Ch2: demand write mode (CRT display) */
    hal_dma_mode(0x4A);         /* Demand mode, addr increment, no auto-init, write, ch2 */

    /* Ch3: demand write mode (CRT display) */
    hal_dma_mode(0x4B);         /* Demand mode, addr increment, no auto-init, write, ch3 */
}

/*
 * CRT initialization — from CRTINT (roa375.asm lines 424-447)
 * Sets up Intel 8275 CRT controller for 80x25 display.
 */
void init_crt(void) {
    /* Reset CRT controller */
    hal_crt_command(0x00);      /* Reset, expect 4 parameter bytes */

    /* Screen format parameters */
    hal_crt_param(0x4F);        /* 80 chars/row (H=79) */
    hal_crt_param(0x98);        /* 25 rows, vretrace=2 scan lines */
    hal_crt_param(0x9A);        /* Underline on scan line 9, 10 lines/char */
    hal_crt_param(0x5D);        /* Non-transparent field attr, blink underline cursor, 28 hretrace */

    /* Load cursor position */
    hal_crt_command(0x80);      /* Load cursor command */
    hal_crt_param(0x00);        /* Cursor column = 0 */
    hal_crt_param(0x00);        /* Cursor row = 0 */

    /* Preset counters — CRT ready but display not started yet */
    hal_crt_command(0xE0);      /* Preset counters */
}

/*
 * FDC initialization — from FDCINT (roa375.asm lines 458-481)
 * Waits for FDC ready, sends SPECIFY command (3 bytes).
 */
void init_fdc(void) {
    uint8_t status;

    /* Wait for FDC to be idle (lower 5 bits = 0) */
    hal_delay(1, 0xFF);
    do {
        status = hal_fdc_status();
    } while ((status & 0x1F) != 0);

    /* Send SPECIFY command: 0x03, parameters 0x4F and 0x20 */
    /* Wait for RQM=1,DIO=0 before each write */
    hal_fdc_wait_write(0x03);   /* SPECIFY command */
    hal_fdc_wait_write(0x4F);   /* SRT=4ms, HUT=15ms (step rate/head unload) */
    hal_fdc_wait_write(0x20);   /* HLT=16ms, ND=0 (head load/non-DMA) */
}
