/*
 * boot.c — Boot logic for RC702 autoload
 *
 * Register-based calling convention: functions take up to 2 params
 * via sdcccall(1) ABI and return status values directly.
 */

#include "hal.h"
#include "boot.h"

#define ST (&g_state)

/*
 * Global boot state.
 * Z80: defined in crt0.asm at 0xBF00 (DEFC _g_state = 0xBF00).
 * Host: allocated here in BSS.
 */
#ifdef HOST_TEST
boot_state_t g_state;
uint8_t dspstr[2000];
uint16_t scroll_offset;
#endif

/* Error/status message strings — non-static for assembly access */
const char msg_rc700[]   = " RC700";
const char msg_rc702[]   = " RC702";
const char msg_nosys[]   = " **NO SYSTEM FILES** ";
const char msg_nocat[]   = " **NO KATALOG** ";
const char msg_nodisk[]  = " **NO DISKETTE NOR LINEPROG** ";
const char msg_diskerr[] = "**DISKETTE ERROR** ";

#ifdef HOST_TEST
void clear_screen(void) {
    uint8_t *p = dspstr;
    uint16_t i = 80 * 25;
    while (i--) *p++ = 0x20;
}
void mcopy(uint8_t *dst, const uint8_t *src, uint8_t len) {
    while (len--) *dst++ = *src++;
}

uint8_t mcmp(const uint8_t *a, const uint8_t *b, uint8_t len) {
    while (len--) {
        if (*a++ != *b++) return 1;
    }
    return 0;
}

/* HOST_TEST halt_msg — C fallback (null-terminated copy) */
void halt_msg(const uint8_t *msg) {
    uint8_t *dst = dspstr;
    while (*msg) *dst++ = *msg++;
    halt_forever();
}

#endif /* HOST_TEST */

/* b7_cmp6 — compare 6 bytes.  Pointer-increment style generates compact
 * sdcc output (17 bytes, no IX frame) vs indexed a[i] (35 bytes with IX). */
uint8_t b7_cmp6(const uint8_t *a, const uint8_t *b) {
    uint8_t i = 6;
    do {
        if (*a++ != *b++) return 1;
    } while (--i);
    return 0;
}

/* b7_chksys — check dir entry name + attribute.  Pointer-increment for
 * the 4-byte name comparison, then direct offset for the attribute byte. */
uint8_t b7_chksys(const uint8_t *dir, const uint8_t *pattern) {
    uint8_t i = 4;
    dir++;  /* skip dir[0] */
    do {
        if (*dir++ != *pattern++) return 1;
    } while (--i);
    /* dir now at dir[5], need dir[8] */
    if ((dir[3] & 0x3F) != 0x13) return 1;
    return 0;
}

#ifdef HOST_TEST
void display_banner(void) {
    const uint8_t *src = (const uint8_t *)msg_rc700;
    uint8_t *dst = dspstr;
    uint8_t i = 6;
    while (i--) *dst++ = *src++;
    scroll_offset = 0;
    hal_crt_command(0x23);
}
#endif

void errdsp(uint8_t code) {
    ST->errsav = code;
    hal_ei();
    if (ST->dsktyp & 0x01) return;
    hal_beep();
    halt_msg((const uint8_t *)msg_diskerr);
}

/*
 * boot7 — Verify Track 0 directory contains system files.
 *
 * b7_cmp6/b7_chksys are C (pointer-increment avoids IX frame).
 * The "SYSM"/"SYSC" strings live
 * in the crt0.asm alignment gap (zero-cost).
 *
 * Uses one file-scope global (b7_dir) to avoid IX frame pointer.
 * Uses goto for shared error paths to avoid duplicate halt_msg calls.
 */
#ifdef HOST_TEST
static const char b7_sysm[] = "SYSM";
static const char b7_sysc[] = "SYSC";
#else
extern const char b7_sysm[];  /* in crt0.asm alignment gap */
extern const char b7_sysc[];
#endif

static uint8_t *b7_dir;

void boot7(void) {
    if (b7_cmp6((const uint8_t *)0x0002, (const uint8_t *)msg_rc700) == 0) {
        b7_dir = (uint8_t *)0x0B80;
        while ((uint16_t)b7_dir < 0x0D00) {
            if (*b7_dir == 0) {
                b7_dir += 0x20;
                continue;
            }
            if (b7_chksys(b7_dir, (const uint8_t *)b7_sysm) != 0)
                goto nosys;
            b7_dir += 0x20;
            if (*b7_dir == 0)
                goto nosys;
            if (b7_chksys(b7_dir, (const uint8_t *)b7_sysc) != 0)
                goto nosys;
            return;
        }
        goto nosys;
    }

    if (b7_cmp6((const uint8_t *)0x0002, (const uint8_t *)msg_rc702) == 0) {
        jump_to(*(uint16_t *)0x0000);
        return;
    }

    halt_msg((const uint8_t *)msg_nocat);
    return;

nosys:
    halt_msg((const uint8_t *)msg_nosys);
}

void check_prom1(void) {
#ifndef HOST_TEST
    if (b7_cmp6((const uint8_t *)0x2002, (const uint8_t *)msg_rc702) == 0) {
        jump_to(*(uint16_t *)0x2000);
        return;
    }
#endif
    halt_msg((const uint8_t *)msg_nodisk);
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
        uint8_t r = flseek();
        if (r == 1) { check_prom1(); return; }
        if (r != 0) { errdsp(0x06); return; }

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
    return dskauto();
}

void flboot(void) {
    ST->dsktyp = (ST->diskbits & 0x80) | ST->dsktyp;
    ST->dsktyp--;
    dskauto();
    ST->memadr = FLOPPYDATA;
    rdtrk0(0x7300 - 0x7000);
    ST->dsktyp = 1;
#ifndef HOST_TEST
    jump_to(COMALBOOT);
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
    uint8_t *p = (uint8_t *)ST;
    uint8_t i = sizeof(boot_state_t);

    /* Bulk zero entire struct */
    while (i--) *p++ = 0;

    ST->fdctmo = 3;
    ST->fdcwai = 4;
    ST->flpwai = 4;
    ST->diskbits = hal_read_sw1() & 0x80;

    hal_ei();
    hal_motor(1);
    ST->reptim = 5;
    fldsk1();
}

void syscall(uint16_t addr, uint16_t bc) {
    uint8_t b = (uint8_t)(bc >> 8);
    uint8_t c = (uint8_t)(bc & 0xFF);

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
