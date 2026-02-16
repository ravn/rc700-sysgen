/*
 * fdc.c — FDC driver for RC702 autoload
 *
 * uPD765/8272 floppy disk controller interface.
 * Density auto-detect, read, seek, retries.
 * Derived from roa375.asm lines 1176-1753.
 */

#include "hal.h"
#include "boot.h"

/*
 * MKDHB — Make drive/head byte (roa375.asm lines 1579-1588)
 * Returns (head << 2) | drive
 */
uint8_t mkdhb(boot_state_t *st) {
    return (st->curhed << 2) | st->drvsel;
}

/*
 * SNSDRV — Sense drive status, FDC command 0x04 (roa375.asm lines 1537-1544)
 */
void snsdrv(boot_state_t *st) {
    hal_fdc_wait_write(0x04);       /* Sense drive status command */
    hal_fdc_wait_write(st->drvsel); /* Drive select byte */
    st->fdcres[0] = hal_fdc_wait_read(); /* Read ST3 */
}

/*
 * FLO4 — Recalibrate drive, FDC command 0x07 (roa375.asm lines 1654-1659)
 */
void flo4(boot_state_t *st) {
    hal_fdc_wait_write(0x07);       /* Recalibrate command */
    hal_fdc_wait_write(st->drvsel); /* Drive select */
}

/*
 * FLO6 — Sense interrupt status, FDC command 0x08 (roa375.asm lines 1550-1561)
 */
void flo6(boot_state_t *st) {
    hal_fdc_wait_write(0x08);       /* Sense interrupt status */
    st->fdcres[0] = hal_fdc_wait_read(); /* Read ST0 */
    if ((st->fdcres[0] & 0xC0) != 0x80) {
        /* Not invalid command — read present cylinder number */
        st->fdcres[1] = hal_fdc_wait_read(); /* PCN */
    }
}

/*
 * FLO7 — Seek to cylinder, FDC command 0x0F (roa375.asm lines 1666-1674)
 */
void flo7(boot_state_t *st, uint8_t dh, uint8_t cyl) {
    (void)st;
    hal_fdc_wait_write(0x0F);       /* Seek command */
    hal_fdc_wait_write(dh & 0x07);  /* Drive/head bits */
    hal_fdc_wait_write(cyl);        /* Cylinder number */
}

/*
 * RSULT — Read FDC result bytes (roa375.asm lines 1725-1753)
 * Reads up to 7 result bytes from FDC into fdcres buffer.
 */
void rsult(boot_state_t *st) {
    uint8_t i;
    uint8_t status;

    st->fdcflg = 7;                 /* Mark FDC busy */
    for (i = 0; i < 7; i++) {
        st->fdcres[i] = hal_fdc_wait_read();

        /* Small delay (matches FDCWAI loop) */
        volatile uint8_t d = st->fdcwai;
        while (d > 0) d--;

        /* Check if FDC still in execution mode (bit 4) */
        status = hal_fdc_status();
        if (!(status & 0x10)) {
            /* Not in execution mode — read DMA status and store */
            st->fdcres[i + 1] = hal_dma_status();
            return;
        }
    }
    /* Too many result bytes — error */
    errdsp(st, 0xFE);
}

/*
 * CLRFLF — Clear floppy interrupt flag (roa375.asm lines 1567-1572)
 */
void clrflf(boot_state_t *st) {
    hal_di();
    st->flpflg = 0;
    hal_ei();
}

/*
 * WAITFL — Wait for floppy interrupt (roa375.asm lines 1616-1634)
 * Returns 0 on success (interrupt received), 1 on timeout.
 */
uint8_t waitfl(boot_state_t *st, uint8_t timeout) {
    uint8_t a = timeout;
    while (a > 0) {
        a--;
        if (a == 0) return 1;       /* Timeout */
        hal_delay(1, 1);            /* Short delay */
        if (st->flpflg & 0x02) {
            /* Interrupt received */
            clrflf(st);
            return 0;               /* Success */
        }
    }
    return 1;
}

/*
 * FLWRES — Wait for floppy result (roa375.asm lines 1641-1648)
 * Waits for interrupt, returns ST0 in *st0, PCN in *pcn.
 * Returns 1 on timeout.
 */
static uint8_t flwres(boot_state_t *st, uint8_t *st0, uint8_t *pcn) {
    if (waitfl(st, 0xFF)) return 1;
    *st0 = st->fdcres[0];
    *pcn = st->fdcres[1];
    return 0;
}

/*
 * RECALV — Recalibrate and verify (roa375.asm lines 1681-1694)
 * Returns: 0 = success (Z flag in asm), 1 = timeout (C), 2 = error (NZ+NC)
 */
uint8_t recalv(boot_state_t *st) {
    uint8_t st0, pcn;

    flo4(st);                       /* Recalibrate */
    if (flwres(st, &st0, &pcn)) return 1; /* Timeout */

    /* Check: ST0 should be seek_end + drive */
    if ((st->drvsel + 0x20) != st0) return 2;
    if (pcn != 0) return 2;         /* Should be at cylinder 0 */
    return 0;                       /* Success */
}

/*
 * FLSEEK — Seek to current cylinder with verify (roa375.asm lines 1701-1718)
 * Returns: 0 = success (Z), 1 = timeout (C), 2 = error (NZ+NC)
 */
uint8_t flseek(boot_state_t *st) {
    uint8_t st0, pcn;
    uint8_t dh;

    dh = mkdhb(st);
    flo7(st, dh, st->curcyl);
    if (flwres(st, &st0, &pcn)) return 1;

    /* Check result */
    if ((st->drvsel + 0x20) != st0) return 2;
    if (st->curcyl != pcn) return 2;
    return 0;
}

/*
 * STPDMA — Set up DMA for read (roa375.asm lines 1472-1477)
 * Channel 1, demand mode, read (memory -> FDC), auto-init.
 */
void stpdma(boot_state_t *st, uint16_t addr, uint16_t count) {
    (void)st;
    hal_di();
    hal_dma_mask(1);                /* Disable ch1 */
    hal_dma_mode(0x45);             /* Demand, addr inc, auto-init, read, ch1 */
    hal_dma_clear_bp();
    hal_dma_ch_addr(1, addr);
    hal_dma_ch_wc(1, count);
    hal_dma_unmask(1);              /* Enable ch1 */
    hal_ei();
}

/*
 * DMAWRT — Set up DMA for write (roa375.asm lines 1446-1465)
 */
void dmawrt(boot_state_t *st, uint16_t addr, uint16_t count) {
    (void)st;
    hal_di();
    hal_dma_mask(1);
    hal_dma_mode(0x49);             /* Demand, addr inc, auto-init, write, ch1 */
    hal_dma_clear_bp();
    hal_dma_ch_addr(1, addr);
    hal_dma_ch_wc(1, count);
    hal_dma_unmask(1);
    hal_ei();
}

/*
 * FLRTRK — Send FDC read/write command (roa375.asm lines 1404-1439)
 * Builds command buffer and sends to FDC.
 * For format commands (0x06), sends 9 bytes; otherwise 2 bytes.
 */
void flrtrk(boot_state_t *st, uint8_t cmd) {
    uint8_t mfm_flag = 0;
    uint8_t buf[9];
    uint8_t count, i;

    hal_di();
    st->fdcflg = 0xFF;             /* Mark FDC busy */

    /* Set MFM flag for side 1 */
    if (st->diskbits & 0x01) {
        mfm_flag = 0x40;
    }

    /* Build command buffer */
    buf[0] = cmd + mfm_flag;       /* Command + MFM */
    buf[1] = mkdhb(st);            /* Drive/head byte */

    /* Format command sends full 9-byte buffer */
    if ((cmd & 0x0F) == 0x06) {
        buf[2] = st->curcyl;
        buf[3] = st->curhed;
        buf[4] = st->currec;
        buf[5] = st->reclen;
        buf[6] = st->cureot;
        buf[7] = st->gap3;
        buf[8] = st->dtl;
        count = 9;
    } else {
        count = 2;
    }

    /* Send command bytes to FDC */
    for (i = 0; i < count; i++) {
        hal_fdc_wait_write(buf[i]);
    }
    hal_ei();
}

/*
 * CHKRES — Check FDC result status bytes (roa375.asm lines 1370-1396)
 * Returns: 0 = OK, 1 = error with retries remaining, 2 = retries exhausted
 */
uint8_t chkres(boot_state_t *st) {
    uint8_t expected_st0;

    /* Check ST0: mask to command/drive bits */
    expected_st0 = st->drvsel;
    if ((st->fdcres[0] & 0xC3) != expected_st0) goto error;

    /* Check ST1: must be zero */
    if (st->fdcres[1] != 0) goto error;

    /* Check ST2: mask bit 6 (control mark), rest must be zero */
    if ((st->fdcres[2] & 0xBF) != 0) goto error;

    return 0; /* Success */

error:
    st->reptim--;
    return (st->reptim == 0) ? 2 : 1;
}

/*
 * READTK — Read track with retry (roa375.asm lines 1304-1332)
 * Returns: 0 = success, 1 = timeout/error
 */
uint8_t readtk(boot_state_t *st, uint8_t cmd, uint8_t retries) {
    uint8_t result;
    uint16_t count;

    st->reptim = retries;

    while (1) {
        clrflf(st);
        count = st->trbyt - 1;

        /* Set up DMA if not Read ID command */
        if ((cmd & 0x0F) != 0x0A) {
            stpdma(st, st->memadr, count);
        }

        /* Send FDC command */
        flrtrk(st, cmd);

        /* Wait for floppy interrupt */
        if (waitfl(st, 0xFF)) return 1; /* Timeout */

        /* Check result */
        result = chkres(st);
        if (result == 0) return 0;  /* Success */
        if (result == 2) return 1;  /* Retries exhausted */
        /* result == 1: retry */
    }
}

/*
 * DSKAUTO — Auto-detect disk density (roa375.asm lines 1176-1215)
 * Returns: 0 = success, 1 = error
 */
uint8_t dskauto(boot_state_t *st) {
    uint8_t n;

    /* Clear side bit */
    st->diskbits &= ~0x01;

retry:
    /* Seek to current cylinder */
    if (flseek(st) != 0) return 1;

    /* Read ID (4 bytes) */
    st->trbyt = 4;
    if (readtk(st, 0x0A, 1) != 0) {
        /* Read failed — try other side */
        if (st->diskbits & 0x01) return 1; /* Already tried */
        st->diskbits |= 0x01;
        goto retry;
    }

    /* Detect format from N value in result byte 6 */
    n = st->fdcres[6];
    st->diskbits = (st->diskbits & 0xE3) | (n << 2);
    setfmt(st);
    return 0; /* Success */
}
