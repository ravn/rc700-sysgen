/*
 * isr.c — Interrupt service routines for RC702 autoload
 *
 * Compiled by sccz80 for Z80, by cc for host tests.
 */

#include "hal.h"
#include "boot.h"

#define ST (&g_state)

/*
 * crt_refresh — CRT vertical retrace handler
 *
 * Reprograms DMA channels 2 and 3 to implement hardware-assisted
 * circular-buffer scrolling of the 80x25 display at DSPSTR (0x7800).
 *
 * DMA Ch2 transfers from DSPSTR+scroll_offset to end of buffer.
 * DMA Ch3 transfers from DSPSTR for the full 2000-byte screen.
 * Together they present a scrolled view without copying memory.
 *
 * Called from CRTINT (CTC Ch2 interrupt) with interrupts disabled.
 */
void crt_refresh(void) {
    (void)hal_crt_status();     /* acknowledge CRT interrupt */

    hal_dma_mask(2);            /* disable Ch2 during reprogramming */
    hal_dma_mask(3);            /* disable Ch3 during reprogramming */
    hal_dma_clear_bp();         /* reset DMA byte pointer flip-flop */

    uint16_t so = scroll_offset;
    hal_dma_ch2_addr(DSPSTR_ADDR + so);
    hal_dma_ch2_wc(80 * 25 - 1 - so);  /* remaining bytes from scroll point */

    hal_dma_ch3_addr(DSPSTR_ADDR);
    hal_dma_ch3_wc(80 * 25 - 1);       /* full screen buffer */

    hal_dma_unmask(2);          /* re-enable Ch2 */
    hal_dma_unmask(3);          /* re-enable Ch3 */

    /* Rearm CTC Ch2: counter mode, interrupt, falling edge, TC follows */
    hal_ctc_write(2, 0xD7);
    hal_ctc_write(2, 0x01);    /* time constant = 1 (every retrace) */
}

void flpint_body(void) {
    ST->flpflg = 2;
    hal_delay(0, ST->fdctmo);
    if (hal_fdc_status() & 0x10) {  /* CB=1: result phase ready */
        rsult();
    } else {
        flo6();
    }
}
