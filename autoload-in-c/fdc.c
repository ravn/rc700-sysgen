/*
 * fdc.c — FDC driver for RC702 autoload
 *
 * Globals-only: no function parameters, no return values.
 * All functions access g_state directly via ST->.
 *
 * Compiled by sccz80 for Z80, by cc for host tests.
 */

#include "hal.h"
#include "boot.h"

#define ST (&g_state)

void snsdrv(void) {
    hal_fdc_wait_write(0x04);
    hal_fdc_wait_write(ST->drvsel);
    ST->fdcres[0] = hal_fdc_wait_read();
}

void flo4(void) {
    hal_fdc_wait_write(0x07);
    hal_fdc_wait_write(ST->drvsel);
}

void flo6(void) {
    hal_fdc_wait_write(0x08);
    ST->fdcres[0] = hal_fdc_wait_read();
    if ((ST->fdcres[0] & 0xC0) != 0x80) {
        ST->fdcres[1] = hal_fdc_wait_read();
    }
}

void flo7(void) {
    uint8_t dh = (ST->curhed << 2) | ST->drvsel;
    hal_fdc_wait_write(0x0F);
    hal_fdc_wait_write(dh & 0x07);
    hal_fdc_wait_write(ST->curcyl);
}

void rsult(void) {
    uint8_t i;

    ST->fdcflg = 7;
    for (i = 0; i < 7; i++) {
        ST->fdcres[i] = hal_fdc_wait_read();
        hal_delay(0, ST->fdcwai);
        if (!(hal_fdc_status() & 0x10)) {
            ST->fdcres[i + 1] = hal_dma_status();
            return;
        }
    }
    ST->errsav = 0xFE;
    errdsp();
}

void waitfl(void) {
    uint8_t timeout = 0xFF;
    while (--timeout) {
        hal_delay(1, 1);
        if (ST->flpflg & 0x02) {
            hal_di();
            ST->flpflg = 0;
            hal_ei();
            ST->result = 0;
            return;
        }
    }
    ST->result = 1;
}

void recalv(void) {
    uint8_t st0;

    flo4();
    waitfl();
    if (ST->result) { ST->result = 1; return; }
    st0 = ST->fdcres[0];
    if ((ST->drvsel + 0x20) != st0) { ST->result = 2; return; }
    if (ST->fdcres[1] != 0) { ST->result = 2; return; }
    ST->result = 0;
}

void flseek(void) {
    uint8_t st0;

    flo7();
    waitfl();
    if (ST->result) { ST->result = 1; return; }
    st0 = ST->fdcres[0];
    if ((ST->drvsel + 0x20) != st0) { ST->result = 2; return; }
    if (ST->curcyl != ST->fdcres[1]) { ST->result = 2; return; }
    ST->result = 0;
}

void stpdma(void) {
    hal_di();
    hal_dma_mask(1);
    hal_dma_mode(0x45);
    hal_dma_clear_bp();
    hal_dma_ch1_addr(ST->memadr);
    hal_dma_ch1_wc(ST->trbyt - 1);
    hal_dma_unmask(1);
    hal_ei();
}

void flrtrk(void) {
    uint8_t mfm_flag = (ST->diskbits & 0x01) ? 0x40 : 0;
    uint8_t dh = (ST->curhed << 2) | ST->drvsel;

    hal_di();
    ST->fdcflg = 0xFF;

    hal_fdc_wait_write(ST->fdccmd + mfm_flag);
    hal_fdc_wait_write(dh);

    if ((ST->fdccmd & 0x0F) == 0x06) {
        uint8_t *p = &ST->curcyl;
        uint8_t i;
        for (i = 0; i < 7; i++) {
            hal_fdc_wait_write(p[i]);
        }
    }
    hal_ei();
}

void chkres(void) {
    if ((ST->fdcres[0] & 0xC3) == ST->drvsel &&
        ST->fdcres[1] == 0 &&
        (ST->fdcres[2] & 0xBF) == 0) {
        ST->result = 0;
    } else {
        ST->reptim--;
        ST->result = (ST->reptim == 0) ? 2 : 1;
    }
}

void readtk(void) {
    while (1) {
        /* inline clrflf */
        hal_di();
        ST->flpflg = 0;
        hal_ei();

        if ((ST->fdccmd & 0x0F) != 0x0A) {
            stpdma();
        }

        flrtrk();

        waitfl();
        if (ST->result) { ST->result = 1; return; }

        chkres();
        if (ST->result == 0) return;
        if (ST->result == 2) { ST->result = 1; return; }
    }
}

void dskauto(void) {
    ST->diskbits &= ~0x01;

    while (1) {
        flseek();
        if (ST->result != 0) { ST->result = 1; return; }

        ST->trbyt = 4;
        ST->fdccmd = 0x0A;
        ST->reptim = 1;
        readtk();
        if (ST->result == 0) break;
        if (ST->diskbits & 0x01) { ST->result = 1; return; }
        ST->diskbits |= 0x01;
    }

    ST->diskbits = (ST->diskbits & 0xE3) | (ST->fdcres[6] << 2);
    /* inline setfmt */
    ST->reclen = (ST->diskbits >> 2) & 0x07;
    fmtlkp();
    calctb();
    ST->result = 0;
}
