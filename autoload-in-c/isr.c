/*
 * isr.c — Interrupt service routines for RC702 autoload
 *
 * FLPBDY (floppy interrupt body) — called from crt0.asm FLPINT wrapper.
 * DISINT stays in crt0.asm (timing-critical DMA reprogramming).
 *
 * Derived from roa375.asm lines 1759-1782.
 */

#include "hal.h"
#include "boot.h"

/*
 * FLPBDY — Floppy interrupt handler body (roa375.asm lines 1759-1782)
 *
 * Called from assembly FLPINT wrapper with registers already saved.
 * Sets floppy interrupt flag, delays briefly, then reads FDC status
 * to determine whether to call rsult() (full result phase) or
 * flo6() (sense interrupt status).
 */
void flpint_body(void) {
    boot_state_t *st = &g_state;
    uint8_t status;
    volatile uint8_t d;

    /* Set floppy interrupt flag */
    st->flpflg = 2;

    /* Small delay (FDCTMO loop) */
    d = st->fdctmo;
    while (d > 0) d--;

    /* Check FDC status */
    status = hal_fdc_status();
    if (status & 0x10) {
        /* Non-DMA execution mode — read full result */
        rsult(st);
    } else {
        /* DMA mode — sense interrupt status */
        flo6(st);
    }
}
