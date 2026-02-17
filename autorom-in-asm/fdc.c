/*
 * fdc.c — FDC driver for RC702 autoload
 *
 * uPD765/8272 floppy disk controller interface.
 * Z80 ROM build: all functions implemented in assembly (crt0.asm).
 * Host test build: C implementations below.
 */

#include "hal.h"
#include "boot.h"

#ifdef HOST_TEST

#define ST (&g_state)

uint8_t mkdhb(void) {
    return (ST->curhed << 2) | ST->drvsel;
}

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
    errdsp(0xFE);
}

void clrflf(void) {
    hal_di();
    ST->flpflg = 0;
    hal_ei();
}

uint8_t waitfl(uint8_t timeout) FASTCALL {
    while (--timeout) {
        hal_delay(1, 1);
        if (ST->flpflg & 0x02) {
            clrflf();
            return 0;
        }
    }
    return 1;
}

uint8_t recalv(void) {
    uint8_t st0;

    flo4();
    if (waitfl(0xFF)) return 1;
    st0 = ST->fdcres[0];
    if ((ST->drvsel + 0x20) != st0) return 2;
    if (ST->fdcres[1] != 0) return 2;
    return 0;
}

uint8_t flseek(void) {
    uint8_t st0;

    flo7(mkdhb(), ST->curcyl);
    if (waitfl(0xFF)) return 1;
    st0 = ST->fdcres[0];
    if ((ST->drvsel + 0x20) != st0) return 2;
    if (ST->curcyl != ST->fdcres[1]) return 2;
    return 0;
}

void stpdma(uint16_t addr, uint16_t count, uint8_t mode) {
    hal_di();
    hal_dma_mask(1);
    hal_dma_mode(mode);
    hal_dma_clear_bp();
    hal_dma_ch1_addr(addr);
    hal_dma_ch1_wc(count);
    hal_dma_unmask(1);
    hal_ei();
}

void flrtrk(uint8_t cmd) FASTCALL {
    uint8_t mfm_flag = (ST->diskbits & 0x01) ? 0x40 : 0;

    hal_di();
    ST->fdcflg = 0xFF;

    hal_fdc_wait_write(cmd + mfm_flag);
    hal_fdc_wait_write(mkdhb());

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
    if ((ST->fdcres[0] & 0xC3) != ST->drvsel) goto error;
    if (ST->fdcres[1] != 0) goto error;
    if ((ST->fdcres[2] & 0xBF) != 0) goto error;
    return 0;
error:
    ST->reptim--;
    return (ST->reptim == 0) ? 2 : 1;
}

uint8_t readtk(uint8_t cmd, uint8_t retries) {
    uint8_t result;

    ST->reptim = retries;

    while (1) {
        clrflf();

        if ((cmd & 0x0F) != 0x0A) {
            stpdma(ST->memadr, ST->trbyt - 1, 0x45);
        }

        flrtrk(cmd);

        if (waitfl(0xFF)) return 1;

        result = chkres();
        if (result == 0) return 0;
        if (result == 2) return 1;
    }
}

uint8_t dskauto(void) {
    ST->diskbits &= ~0x01;

retry:
    if (flseek() != 0) return 1;

    ST->trbyt = 4;
    if (readtk(0x0A, 1) != 0) {
        if (ST->diskbits & 0x01) return 1;
        ST->diskbits |= 0x01;
        goto retry;
    }

    ST->diskbits = (ST->diskbits & 0xE3) | (ST->fdcres[6] << 2);
    setfmt();
    return 0;
}

#endif /* HOST_TEST */
