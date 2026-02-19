/*
 * isr.c — Interrupt service routines for RC702 autoload
 *
 * Z80 ROM build: flpint_body implemented in assembly (crt0.asm).
 * Host test build: C implementation below.
 */

#include "hal.h"
#include "boot.h"

#ifdef HOST_TEST

#define ST (&g_state)

void flpint_body(void) {
    ST->flpflg = 2;
    hal_delay(0, ST->fdctmo);
    if (hal_fdc_status() & 0x10) {
        rsult();
    } else {
        flo6();
    }
}

#endif /* HOST_TEST */
