/*
 * fdc.c — NEC uPD765 (Intel 8272) FDC driver for RC702 autoload
 *
 * Commands (defined in boot.h):
 *   0x04 = Sense Drive Status    0x07 = Recalibrate
 *   0x08 = Sense Interrupt Status 0x0F = Seek
 *   0x06 = Read Data             0x0A = Read ID
 *   MFM commands have bit 6 set (+0x40).
 *
 * Main Status Register (hal_fdc_status(), port 0x04):
 *   bit 7: RQM — ready for CPU data transfer
 *   bit 6: DIO — direction (0=CPU→FDC write, 1=FDC→CPU read)
 *   bit 5: EXM — in execution phase
 *   bit 4: CB  — command busy (FDC has a command in progress)
 *   bits 3-0:   drive busy flags (per-drive seek in progress)
 *
 * Result registers (fdcres[], read via hal_fdc_wait_read()):
 *   ST0 [0]: bit 7-6 = IC (interrupt code: 00=normal, 01=abnormal,
 *            10=invalid cmd, 11=not ready); bit 5 = SE (seek end);
 *            bit 2 = HD (head); bits 1-0 = US (unit/drive select)
 *   ST1 [1]: error flags (EN, DE, OR, ND, NW, MA)
 *   ST2 [2]: error flags; bit 6 = CM (control mark, benign)
 *   ST3 [0]: from Sense Drive Status — bit 5 = RDY; bits 2-0 = HD+US
 *   [3]-[6]: C, H, R, N (cylinder, head, record, sector size code)
 *
 * Register-based calling convention: functions take up to 2 params
 * via sdcccall(1) ABI and return status values directly.
 */

#include "hal.h"
#include "boot.h"

#define ST (&g_state)

void snsdrv(void) {
    hal_fdc_wait_write(FDC_SENSE_DRIVE);
    hal_fdc_wait_write(ST->drvsel);
    ST->fdcres[0] = hal_fdc_wait_read(); /* ST3: drive status */
}

void flo4(void) {
    hal_fdc_wait_write(FDC_RECALIBRATE);
    hal_fdc_wait_write(ST->drvsel);
}

void flo6(void) {
    hal_fdc_wait_write(FDC_SENSE_INT);
    ST->fdcres[0] = hal_fdc_wait_read();   /* ST0 */
    if ((ST->fdcres[0] & 0xC0) != 0x80) {  /* IC != 10 (not "invalid cmd") */
        ST->fdcres[1] = hal_fdc_wait_read(); /* PCN (present cylinder) */
    }
}

void flo7(uint8_t dh, uint8_t cyl) {
    hal_fdc_wait_write(FDC_SEEK);
    hal_fdc_wait_write(dh & 0x07);  /* HD + US1/US0 (head + drive) */
    hal_fdc_wait_write(cyl);        /* NCN (new cylinder number) */
}

void rsult(void) {
    uint8_t i;

    ST->fdcflg = 7;
    for (i = 0; i < 7; i++) {
        ST->fdcres[i] = hal_fdc_wait_read();
        hal_delay(0, ST->fdcwai);
        if (!(hal_fdc_status() & 0x10)) {  /* CB=0: no more result bytes */
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
    if ((ST->drvsel + 0x20) != ST->fdcres[0]) return 2; /* expect SE+drive in ST0 */
    if (expected_pcn != ST->fdcres[1]) return 2;       /* verify cylinder (PCN) */
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
    hal_dma_mode(0x45);  /* demand mode, addr increment, read, channel 1 */
    hal_dma_clear_bp();
    hal_dma_ch1_addr(ST->memadr);
    hal_dma_ch1_wc(ST->trbyt - 1);
    hal_dma_unmask(1);
    hal_ei();
}

void flrtrk(uint8_t cmd) {
    uint8_t mfm_flag = (ST->diskbits & 0x01) ? FDC_MFM : 0;
    uint8_t dh = (ST->curhed << 2) | ST->drvsel;

    hal_di();
    ST->fdcflg = 0xFF;

    hal_fdc_wait_write(cmd + mfm_flag);
    hal_fdc_wait_write(dh);

    if ((cmd & 0x0F) == FDC_READ_DATA) {
        uint8_t *p = &ST->curcyl;
        uint8_t i;
        for (i = 0; i < 7; i++) {
            hal_fdc_wait_write(p[i]);
        }
    }
    hal_ei();
}

uint8_t chkres(void) {
    if ((ST->fdcres[0] & 0xC3) == ST->drvsel &&  /* ST0: IC=00 + drive match */
        ST->fdcres[1] == 0 &&                     /* ST1: no errors */
        (ST->fdcres[2] & 0xBF) == 0) {            /* ST2: ignore CM (bit 6) */
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

        if ((cmd & 0x0F) != FDC_READ_ID) {
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
        if (readtk(FDC_READ_ID, 1) == 0) break;
        if (ST->diskbits & 0x01) return 1;
        ST->diskbits |= 0x01;
    }

    /* fdcres[6] = N (sector size code) from Read ID result */
    ST->diskbits = (ST->diskbits & 0xE3) | (ST->fdcres[6] << 2); /* store N in bits 4-2 */
    /* inline setfmt */
    ST->reclen = (ST->diskbits >> 2) & 0x07; /* extract N back from diskbits */
    fmtlkp();
    calctb();
    return 0;
}
