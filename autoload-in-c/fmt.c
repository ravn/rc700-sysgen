/*
 * fmt.c — Format tables for RC702 autoload
 *
 * Compiled by sccz80 for Z80, by cc for host tests.
 */

#include "boot.h"


static const byte maxifmt[4][4] = {
    { 0x1A, 0x07, 0x34, 0x07 },
    { 0x0F, 0x0E, 0x1A, 0x0E },
    { 0x08, 0x1B, 0x0F, 0x1B },
    { 0x00, 0x00, 0x08, 0x35 },
};

static const byte minifmt[4][4] = {
    { 0x10, 0x07, 0x20, 0x07 },
    { 0x09, 0x0E, 0x10, 0x0E },
    { 0x05, 0x1B, 0x09, 0x1B },
    { 0x00, 0x00, 0x05, 0x35 },
};

void fmtlkp(void) {
    const byte *tbl;
    byte side_offset;
    byte n = reclen & 0x03;

    if (diskbits & 0x80) {
        tbl = minifmt[n];
        epts = 0x23;
    } else {
        tbl = maxifmt[n];
        epts = 0x4C;
    }

    side_offset = (diskbits & 0x01) ? 2 : 0;
    cureot = tbl[side_offset];
    trksz = tbl[side_offset];
    gap3 = tbl[side_offset + 1];
    dtl = 0x80;
}

void calctb(void) {
    word secbytes;
    byte sectors;
    byte i;

    secbytes = 0x80;
    for (i = 0; i < reclen; i++) {
        secbytes <<= 1;
    }
    secbyt = secbytes;

    sectors = cureot - currec + 1;

    if ((dsktyp & 0x80) && curhed == 1) {
        sectors = 0x0A;
    }

    /* trbyt = sectors * (128 << N) = sectors << (7 + N) */
    {
        word tb = (word)sectors;
        for (i = 7 + reclen; i != 0; i--) tb <<= 1;
        trbyt = tb;
    }
}
