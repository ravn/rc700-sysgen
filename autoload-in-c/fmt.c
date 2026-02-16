/*
 * fmt.c — Format tables for RC702 autoload
 *
 * FMTLKP, CALCTB, format parameter tables for mini and maxi diskettes.
 * Derived from roa375.asm lines 768-1296.
 */

#include "boot.h"

/*
 * Format parameter tables — 4 entries per table, 4 bytes per entry.
 * Each entry: { side0_EOT, side0_GAP3, side1_EOT, side1_GAP3 }
 * Indexed by density N (0=128B, 1=256B, 2=512B, 3=unused).
 */
static const uint8_t maxifmt[4][4] = {
    { 0x1A, 0x07, 0x34, 0x07 },    /* N=0: side0 EOT=26,GAP3=7   side1 EOT=52,GAP3=7 */
    { 0x0F, 0x0E, 0x1A, 0x0E },    /* N=1: side0 EOT=15,GAP3=14  side1 EOT=26,GAP3=14 */
    { 0x08, 0x1B, 0x0F, 0x1B },    /* N=2: side0 EOT=8, GAP3=27  side1 EOT=15,GAP3=27 */
    { 0x00, 0x00, 0x08, 0x35 },    /* N=3: unused */
};

static const uint8_t minifmt[4][4] = {
    { 0x10, 0x07, 0x20, 0x07 },    /* N=0: side0 EOT=16,GAP3=7   side1 EOT=32,GAP3=7 */
    { 0x09, 0x0E, 0x10, 0x0E },    /* N=1: side0 EOT=9, GAP3=14  side1 EOT=16,GAP3=14 */
    { 0x05, 0x1B, 0x09, 0x1B },    /* N=2: side0 EOT=5, GAP3=27  side1 EOT=9, GAP3=27 */
    { 0x00, 0x00, 0x05, 0x35 },    /* N=3: unused */
};

/*
 * FMTLKP — Format table lookup by density (roa375.asm lines 1223-1258)
 *
 * Selects MAXIFMT or MINIFMT based on diskbits bit7.
 * Within the selected table, indexes by reclen (N) and side bit.
 * Stores EOT in cureot/trksz, GAP3 in gap3, DTL = 0x80.
 * Also sets epts (max cylinder) = 76 (maxi) or 35 (mini).
 */
void fmtlkp(boot_state_t *st) {
    const uint8_t *tbl;
    uint8_t side_offset;
    uint8_t n = st->reclen & 0x03;

    if (st->diskbits & 0x80) {
        /* Mini (5.25") */
        tbl = minifmt[n];
        st->epts = 0x23;           /* Max cylinder = 35 */
    } else {
        /* Maxi (8") */
        tbl = maxifmt[n];
        st->epts = 0x4C;           /* Max cylinder = 76 */
    }

    side_offset = (st->diskbits & 0x01) ? 2 : 0;
    st->cureot = tbl[side_offset];
    st->trksz = tbl[side_offset];
    st->gap3 = tbl[side_offset + 1];
    st->dtl = 0x80;
}

/*
 * CALCTB — Calculate transfer byte count (roa375.asm lines 1266-1296)
 *
 * Computes: sectors_remaining * bytes_per_sector
 * Sets trbyt with the result.
 */
void calctb(boot_state_t *st) {
    uint16_t secbytes;
    uint8_t sectors;
    uint16_t total;
    uint8_t i;

    /* Compute bytes per sector: 128 << N */
    secbytes = 0x80;
    for (i = 0; i < st->reclen; i++) {
        secbytes <<= 1;
    }
    st->secbyt = secbytes;

    /* Sectors remaining = EOT - CURREC + 1 */
    sectors = st->cureot - st->currec + 1;

    /* Mini head 1 special case: 10 sectors */
    if ((st->dsktyp & 0x80) && (st->curhed ^ 0x01) == 0) {
        sectors = 0x0A;
    }

    /* Multiply: total = sectors * secbytes */
    total = 0;
    for (i = 0; i < sectors; i++) {
        total += secbytes;
    }
    st->trbyt = total;
}

/*
 * SETFMT — Set disk format parameters from status flags (roa375.asm lines 1159-1168)
 *
 * Extracts density from diskbits, calls fmtlkp + calctb.
 */
void setfmt(boot_state_t *st) {
    st->reclen = (st->diskbits >> 2) & 0x07;
    fmtlkp(st);
    calctb(st);
}
