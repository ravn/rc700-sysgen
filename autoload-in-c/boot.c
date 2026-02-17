/*
 * boot.c — Boot logic for RC702 autoload
 *
 * All functions access g_state directly.
 */

#include "hal.h"
#include "boot.h"

#define ST (&g_state)

/* Global boot state — placed outside payload to save ROM bytes */
#ifdef __SDCC
__at(0xBF00) boot_state_t g_state;
#else
boot_state_t g_state;
#endif

#ifdef HOST_TEST
uint8_t dspstr[2000];
uint16_t scroll_offset;
#endif

/* Error/status message strings */
static const char msg_rc700[]   = " RC700";
static const char msg_rc702[]   = " RC702";
static const char msg_nosys[]   = " **NO SYSTEM FILES** ";
static const char msg_nocat[]   = " **NO KATALOG** ";
static const char msg_nodisk[]  = " **NO DISKETTE NOR LINEPROG** ";
static const char msg_diskerr[] = "**DISKETTE ERROR** ";

#ifdef HOST_TEST
/* C versions of utility functions — Z80 uses assembly in crt0.asm */

void memcopy(uint8_t *dst, const uint8_t *src, uint8_t len) {
    while (len--) *dst++ = *src++;
}

uint8_t memcmp_n(const uint8_t *a, const uint8_t *b, uint8_t len) {
    while (len--) {
        if (*a++ != *b++) return 1;
    }
    return 0;
}

void clear_screen(void) {
    uint16_t i;
    for (i = 0; i < 8 * 208; i++) {
        dspstr[i] = ' ';
    }
}
#endif /* HOST_TEST */

void display_banner(void) {
    memcopy(dspstr, (const uint8_t *)msg_rc700, 6);
    scroll_offset = 0;
    hal_crt_command(0x23);
}

void errcpy(void) {
    memcopy(dspstr, (const uint8_t *)msg_diskerr, 18);
}

void errdsp(uint8_t code) FASTCALL {
    ST->errsav = code;
    hal_ei();
    if (ST->dsktyp & 0x01) return;
    hal_beep();
    errcpy();
    for (;;) ;
}

static uint8_t isrc70x(const uint8_t *base, uint8_t which) {
    const uint8_t *sig = (which == 0x0A) ?
        (const uint8_t *)msg_rc700 : (const uint8_t *)msg_rc702;
    return memcmp_n(base + 2, sig, 6);
}

static uint8_t chk_sysfile(const uint8_t *dir_entry, const char *fname) {
    uint8_t i;
    for (i = 0; i < 4; i++) {
        if (dir_entry[1 + i] != (uint8_t)fname[i]) return 1;
    }
    if ((dir_entry[1 + ATTOFF] & 0x3F) != 0x13) return 1;
    return 0;
}

void boot7(void) {
    uint8_t *base;
    uint8_t *dir;

#ifdef __SDCC
    base = (uint8_t *)FLOPPYDATA;
#else
    return;
#endif

    if (isrc70x(base, 0x0A) == 0) {
        dir = base + DIROFF;
        while (1) {
            dir += 0x20;
            if ((uint16_t)(dir - base) >= ((uint16_t)DIREND_HI << 8))
                goto nosys;
            if (*dir == 0) continue;
            if (chk_sysfile(dir, "SYSM") != 0) goto nosys;
            dir += 0x20;
            if (*dir == 0) goto nosys;
            if (chk_sysfile(dir, "SYSC") != 0) goto nosys;
            return;
        }
    }

    if (isrc70x(base, 0x0B) == 0) {
#ifdef __SDCC
        ((void (*)(void))(*(uint16_t *)base))();
#endif
        return;
    }

    memcopy(dspstr, (const uint8_t *)msg_nocat, 15);
    for (;;) ;

nosys:
    memcopy(dspstr, (const uint8_t *)msg_nosys, 20);
    for (;;) ;
}

void check_prom1(void) {
#ifdef __SDCC
    uint8_t *prom1 = (uint8_t *)PROM1_ADDR;
    if (isrc70x(prom1, 0x0B) == 0) {
        ((void (*)(void))(*(uint16_t *)prom1))();
        return;
    }
#endif
    memcopy(dspstr, (const uint8_t *)msg_nodisk, 29);
    for (;;) ;
}

static void nxthds(void) {
    uint8_t max_head;
    ST->currec = 1;
    max_head = (ST->diskbits >> 1) & 0x01;
    if (max_head == ST->curhed) {
        ST->curhed = 0;
        ST->curcyl++;
    } else {
        ST->curhed++;
    }
}

static void calctx(void) {
    int16_t remaining;
    calctb();
    remaining = (int16_t)ST->trkovr - (int16_t)ST->trbyt;
    if (remaining > 0) {
        ST->morefl = 1;
        ST->trkovr = (uint16_t)remaining;
    } else {
        ST->morefl = 0;
        ST->trbyt = ST->trkovr;
        ST->trkovr = 0;
    }
}

static void rdtrk0(uint16_t trkovr_init) {
    ST->trkovr = trkovr_init;

    while (1) {
        uint8_t sr = flseek();
        if (sr == 1) { check_prom1(); return; }
        if (sr != 0) { errdsp(0x06); return; }

        calctx();

        if (readtk(0x06, 5) != 0) {
            errdsp(0x28);
            return;
        }

        ST->memadr += ST->trbyt;
        ST->trbyt = 0;
        nxthds();
        if (!ST->morefl) return;
    }
}

uint8_t boot_detect(void) {
    ST->curcyl = 0;
    ST->curhed = 1;
    ST->currec = 1;

    if (dskauto() == 0) {
        ST->diskbits |= 0x02;
    }

    ST->curhed = 0;
    if (dskauto() != 0) return 1;
    return 0;
}

void flboot(void) {
    ST->dsktyp = (ST->diskbits & 0x80) | ST->dsktyp;
    ST->dsktyp--;
    dskauto();
    ST->memadr = FLOPPYDATA;
    rdtrk0(0x7300 - 0x7000);
    ST->dsktyp = 1;
#ifdef __SDCC
    ((void (*)(void))COMALBOOT)();
#endif
}

static void fldsk1(void) {
    uint8_t status;

    hal_delay(1, 0xFF);

    snsdrv();
    status = ST->fdcres[0] & 0x23;
    if (status != (ST->drvsel + 0x20)) {
        check_prom1();
        return;
    }

    if (recalv() != 0) {
        check_prom1();
        return;
    }

    if (boot_detect() != 0) {
        check_prom1();
        return;
    }

    hal_prom_disable();

    while (1) {
        rdtrk0(ST->trbyt);
        if (ST->curcyl != 0) break;
        dskauto();
    }

    ST->dsktyp = 1;
    boot7();
    flboot();
}

static void preinit(void) {
    uint8_t sw1;

    ST->fdctmo = 3;
    ST->fdcwai = 4;
    ST->flpwai = 4;

    sw1 = hal_read_sw1();
    ST->diskbits = sw1 & 0x80;

    ST->curhed = 0;
    ST->drvsel = 0;
    ST->dsktyp = 0;
    ST->morefl = 0;
    ST->flpflg = 0;
    ST->memadr = 0;
    ST->trbyt = 0;
    ST->trkovr = 0;

    hal_ei();
    hal_motor(1);
    ST->reptim = 5;
    fldsk1();
}

void syscall(uint16_t addr, uint8_t b, uint8_t c) {
    ST->memadr = addr;
    ST->currec = c & 0x7F;
    ST->curcyl = b & 0x7F;

    if (ST->curcyl == 0) dskauto();

    ST->curhed = (b & 0x80) ? 1 : 0;
    rdtrk0(0);

    if ((b & 0x7F) == 0) {
        ST->curcyl = 1;
        dskauto();
    }
}

#ifndef HOST_TEST
int main(void) {
    /* PIO, CTC, DMA, CRT are initialized in crt0.asm before _main */
    init_fdc();
    clear_screen();
    display_banner();
    preinit();
    return 0;
}
#endif
