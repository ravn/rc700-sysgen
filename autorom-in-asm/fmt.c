/*
 * fmt.c — Format tables for RC702 autoload
 *
 * Z80 ROM build: all functions implemented in assembly (crt0.asm).
 * Host test build: C implementations below.
 */

#include "boot.h"

#ifdef HOST_TEST

#define ST (&g_state)

static const uint8_t maxifmt[4][4] = {
    { 0x1A, 0x07, 0x34, 0x07 },
    { 0x0F, 0x0E, 0x1A, 0x0E },
    { 0x08, 0x1B, 0x0F, 0x1B },
    { 0x00, 0x00, 0x08, 0x35 },
};

static const uint8_t minifmt[4][4] = {
    { 0x10, 0x07, 0x20, 0x07 },
    { 0x09, 0x0E, 0x10, 0x0E },
    { 0x05, 0x1B, 0x09, 0x1B },
    { 0x00, 0x00, 0x05, 0x35 },
};

void fmtlkp(void) {
    const uint8_t *tbl;
    uint8_t side_offset;
    uint8_t n = ST->reclen & 0x03;

    if (ST->diskbits & 0x80) {
        tbl = minifmt[n];
        ST->epts = 0x23;
    } else {
        tbl = maxifmt[n];
        ST->epts = 0x4C;
    }

    side_offset = (ST->diskbits & 0x01) ? 2 : 0;
    ST->cureot = tbl[side_offset];
    ST->trksz = tbl[side_offset];
    ST->gap3 = tbl[side_offset + 1];
    ST->dtl = 0x80;
}

void calctb(void) {
    uint16_t secbytes;
    uint8_t sectors;
    uint8_t i;

    secbytes = 0x80;
    for (i = 0; i < ST->reclen; i++) {
        secbytes <<= 1;
    }
    ST->secbyt = secbytes;

    sectors = ST->cureot - ST->currec + 1;

    if ((ST->dsktyp & 0x80) && (ST->curhed ^ 0x01) == 0) {
        sectors = 0x0A;
    }

    /* trbyt = sectors * (128 << N) = sectors << (7 + N) */
    {
        uint16_t trbyt = (uint16_t)sectors;
        for (i = 7 + ST->reclen; i != 0; i--) trbyt <<= 1;
        ST->trbyt = trbyt;
    }
}

void setfmt(void) {
    ST->reclen = (ST->diskbits >> 2) & 0x07;
    fmtlkp();
    calctb();
}

#endif /* HOST_TEST */
