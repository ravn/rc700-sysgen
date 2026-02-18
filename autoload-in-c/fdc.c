/*
 * fdc.c — FDC driver for RC702 autoload
 *
 * Register-based calling convention: functions take up to 2 params
 * via sdcccall(1) ABI and return status values directly.
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

void flo7(uint8_t dh, uint8_t cyl) {
    hal_fdc_wait_write(0x0F);
    hal_fdc_wait_write(dh & 0x07);
    hal_fdc_wait_write(cyl);
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
    errdsp(0xFE);
}

uint8_t waitfl(uint8_t timeout) {
    while (--timeout) {
        hal_delay(1, 1);
        if (ST->flpflg & 0x02) {
            hal_di();
            ST->flpflg = 0;
            hal_ei();
            return 0;
        }
    }
    return 1;
}

/* Shared helper: check seek/recalibrate result */
static uint8_t chk_seekres(uint8_t expected_pcn) {
    if (waitfl(0xFF)) return 1;
    if ((ST->drvsel + 0x20) != ST->fdcres[0]) return 2;
    if (expected_pcn != ST->fdcres[1]) return 2;
    return 0;
}

uint8_t recalv(void) {
    flo4();
    return chk_seekres(0);
}

uint8_t flseek(void) {
    flo7((ST->curhed << 2) | ST->drvsel, ST->curcyl);
    return chk_seekres(ST->curcyl);
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

void flrtrk(uint8_t cmd) {
    uint8_t mfm_flag = (ST->diskbits & 0x01) ? 0x40 : 0;
    uint8_t dh = (ST->curhed << 2) | ST->drvsel;

    hal_di();
    ST->fdcflg = 0xFF;

    hal_fdc_wait_write(cmd + mfm_flag);
    hal_fdc_wait_write(dh);

    if ((cmd & 0x0F) == 0x06) {
        uint8_t *p = &ST->curcyl;
        uint8_t i;
        for (i = 0; i < 7; i++) {
            hal_fdc_wait_write(p[i]);
        }
    }
    hal_ei();
}

uint8_t chkres(void) {
    if ((ST->fdcres[0] & 0xC3) == ST->drvsel &&
        ST->fdcres[1] == 0 &&
        (ST->fdcres[2] & 0xBF) == 0) {
        return 0;
    } else {
        ST->reptim--;
        return (ST->reptim == 0) ? 2 : 1;
    }
}

uint8_t readtk(uint8_t cmd, uint8_t retries) {
    uint8_t r;
    ST->reptim = retries;

    while (1) {
        /* inline clrflf */
        hal_di();
        ST->flpflg = 0;
        hal_ei();

        if ((cmd & 0x0F) != 0x0A) {
            stpdma();
        }

        flrtrk(cmd);

        if (waitfl(0xFF)) return 1;

        r = chkres();
        if (r == 0) return 0;
        if (r == 2) return 1;
    }
}

uint8_t dskauto(void) {
    ST->diskbits &= ~0x01;

    while (1) {
        if (flseek() != 0) return 1;

        ST->trbyt = 4;
        if (readtk(0x0A, 1) == 0) break;
        if (ST->diskbits & 0x01) return 1;
        ST->diskbits |= 0x01;
    }

    ST->diskbits = (ST->diskbits & 0xE3) | (ST->fdcres[6] << 2);
    /* inline setfmt */
    ST->reclen = (ST->diskbits >> 2) & 0x07;
    fmtlkp();
    calctb();
    return 0;
}
