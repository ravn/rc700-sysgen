/*
 * boot.c — Boot logic for RC702 autoload
 *
 * Main entry point, drive detection, catalogue verification, PROM1 check.
 * Derived from roa375.asm lines 586-1086.
 */

#include "hal.h"
#include "boot.h"

/* Global boot state */
boot_state_t g_state;

/* Display buffer and scroll offset */
#ifndef __SDCC
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

/* Helper: memory copy */
static void memcopy(uint8_t *dst, const uint8_t *src, uint8_t len) {
    while (len--) {
        *dst++ = *src++;
    }
}

/* Helper: memory compare, returns 0 if equal */
static uint8_t memcmp_n(const uint8_t *a, const uint8_t *b, uint8_t len) {
    while (len--) {
        if (*a++ != *b++) return 1;
    }
    return 0;
}

/*
 * CLRSCR — Clear screen (roa375.asm lines 493-512)
 * Clears 8 rows x 208 bytes each with spaces.
 */
void clear_screen(void) {
    uint8_t row, col;
    for (row = 0; row < 8; row++) {
        for (col = 0; col < 208; col++) {
            dspstr[row * 208 + col] = ' ';
        }
    }
}

/*
 * DISPMG — Display banner and init scroll state (roa375.asm lines 514-542)
 */
void display_banner(void) {
    memcopy(dspstr, (const uint8_t *)msg_rc700, 6);
    scroll_offset = 0;

    /* Start display: burst mode with 8 DMA cycles per burst */
    hal_crt_command(0x23);
}

/*
 * ERRCPY — Copy error text to display (roa375.asm lines 1003-1014)
 */
void errcpy(void) {
    memcopy(dspstr, (const uint8_t *)msg_diskerr, 18);
}

/*
 * ERRDSP — Error display and halt/return (roa375.asm lines 991-1001)
 */
void errdsp(boot_state_t *st, uint8_t code) {
    st->errsav = code;
    hal_ei();
    if (st->dsktyp & 0x01) return; /* Return via saved SP path */
    hal_beep();
    errcpy();
    for (;;) ;                      /* Halt loop */
}

/*
 * ERRHLT — Display message and halt (used by error paths)
 */
static void errhlt(void) {
    for (;;) ;
}

/*
 * ISRC70X — Check for RC700 or RC702 signature (roa375.asm lines 703-716)
 * Returns 0 if signature matches.
 */
static uint8_t isrc70x(const uint8_t *base, uint8_t which) {
    const uint8_t *sig;
    uint8_t len;

    /* Skip 2-byte jump vector */
    base += 2;

    if (which == 0x0A) {
        sig = (const uint8_t *)msg_rc700;
        len = 6;
    } else {
        sig = (const uint8_t *)msg_rc702;
        len = 6;
    }
    return memcmp_n(base, sig, len);
}

/*
 * CHKSYSM/CHKSYSC + SUB_4F — Check for system file entries (roa375.asm lines 225-258)
 * dir_entry points to start of directory entry.
 * fname is "SYSM " or "SYSC " (4 chars).
 * Returns 0 if file found with correct attribute.
 */
static uint8_t chk_sysfile(const uint8_t *dir_entry, const char *fname) {
    uint8_t i;

    /* Compare filename at dir_entry+1 against fname (4 chars) */
    for (i = 0; i < 4; i++) {
        if (dir_entry[1 + i] != (uint8_t)fname[i]) return 1;
    }
    /* Check attribute: byte at offset 1+ATTOFF, bits 5-0 must be 0x13 */
    if ((dir_entry[1 + ATTOFF] & 0x3F) != 0x13) return 1;
    return 0;
}

/*
 * BOOT7 — Verify catalogue (roa375.asm lines 656-701)
 * Checks for RC700 (0x0A) or RC702 (0x0B) signature at boot data.
 */
void boot7(boot_state_t *st) {
    uint8_t *base;
    uint8_t *dir;

    (void)st;

#ifdef __SDCC
    base = (uint8_t *)FLOPPYDATA;
#else
    /* On host, boot7 is not callable — needs real memory at 0x0000 */
    return;
#endif

    /* Check for RC700 signature */
    if (isrc70x(base, 0x0A) == 0) {
        /* RC700: search directory for SYSM and SYSC */
        dir = base + DIROFF;
        while (1) {
            dir += 0x20;            /* Advance to next 32-byte entry */
            if ((uint16_t)(dir - base) >= ((uint16_t)DIREND_HI << 8)) {
                goto nosys;
            }
            if (*dir == 0) continue; /* Empty entry */

            if (chk_sysfile(dir, "SYSM") != 0) goto nosys;

            /* Check next entry for SYSC */
            dir += 0x20;
            if (*dir == 0) goto nosys;
            if (chk_sysfile(dir, "SYSC") != 0) goto nosys;
            return;                  /* Both found — success */
        }
    }

    /* Check for RC702 signature */
    if (isrc70x(base, 0x0B) == 0) {
        /* RC702: jump via vector at address 0 */
        void (*entry)(void) = (void (*)(void))(*(uint16_t *)base);
        entry();
        return; /* Should not reach here */
    }

    /* Neither found */
    memcopy(dspstr, (const uint8_t *)msg_nocat, 15);
    errhlt();
    return;

nosys:
    memcopy(dspstr, (const uint8_t *)msg_nosys, 20);
    errhlt();
}

/*
 * CHECK_PROM1 — Check for PROM1 line program (roa375.asm lines 728-737)
 */
void check_prom1(void) {
#ifdef __SDCC
    uint8_t *prom1 = (uint8_t *)PROM1_ADDR;

    if (isrc70x(prom1, 0x0B) == 0) {
        /* PROM1 present — jump via vector */
        void (*entry)(void) = (void (*)(void))(*(uint16_t *)prom1);
        entry();
        return;
    }
#endif
    /* No PROM1 — halt with error */
    memcopy(dspstr, (const uint8_t *)msg_nodisk, 29);
    errhlt();
}

/*
 * NXTHDS — Advance to next head/side (roa375.asm lines 1088-1105)
 */
static void nxthds(boot_state_t *st) {
    uint8_t max_head;

    st->currec = 1;
    max_head = (st->diskbits >> 1) & 0x01;
    if (max_head == st->curhed) {
        /* Same head — advance cylinder */
        st->curhed = 0;
        st->curcyl++;
    } else {
        /* Switch to other head */
        st->curhed++;
    }
}

/*
 * CALCTX — Calculate track transfer with overflow (roa375.asm lines 1112-1135)
 */
static void calctx(boot_state_t *st) {
    int16_t remaining;

    calctb(st);
    remaining = (int16_t)st->trkovr - (int16_t)st->trbyt;

    if (remaining > 0) {
        st->morefl = 1;
        st->trkovr = (uint16_t)remaining;
    } else {
        st->morefl = 0;
        st->trkovr = 0;
        st->trbyt = st->trkovr; /* Use original overflow as transfer count */
    }
}

/*
 * RDTRK0 — Read track 0 data (roa375.asm lines 1056-1086)
 * trkovr_init = initial overflow count (bytes to read).
 */
static void rdtrk0(boot_state_t *st, uint16_t trkovr_init) {
    st->trkovr = trkovr_init;

    while (1) {
        /* Seek */
        uint8_t sr = flseek(st);
        if (sr == 1) { check_prom1(); return; }
        if (sr != 0) { errdsp(st, 0x06); return; }

        /* Calculate transfer with overflow */
        calctx(st);

        /* Read track */
        if (readtk(st, 0x06, 5) != 0) {
            errdsp(st, 0x28);
            return;
        }

        /* Update memory pointer */
        st->memadr += st->trbyt;
        st->trbyt = 0;

        /* Advance head/side */
        nxthds(st);

        /* Check if more data needed */
        if (!st->morefl) return;
    }
}

/*
 * BOOT — Auto-detect density on both heads (roa375.asm lines 586-610)
 * Returns 0 on success, 1 on error.
 */
uint8_t boot_detect(boot_state_t *st) {
    st->curcyl = 0;
    st->curhed = 1;
    st->currec = 1;

    /* Try head 1 first */
    if (dskauto(st) == 0) {
        /* Success on head 1 — set dual-sided bit */
        st->diskbits |= 0x02;
    }

    /* Try head 0 */
    st->curhed = 0;
    if (dskauto(st) != 0) {
        return 1;                   /* Both heads failed */
    }
    return 0;
}

/*
 * FLBOOT — Final floppy boot (roa375.asm lines 1035-1054)
 */
void flboot(boot_state_t *st) {
    st->dsktyp = (st->diskbits & 0x80) | st->dsktyp;
    st->dsktyp--;
    dskauto(st);
    st->memadr = FLOPPYDATA;
    rdtrk0(st, 0x7300 - 0x7000);   /* Read to interrupt vector area */
    st->dsktyp = 1;
#ifdef __SDCC
    /* Jump to COMALBOOT (0x1000) — in real Z80, this is JP 0x1000 */
    ((void (*)(void))COMALBOOT)();
#endif
}

/*
 * FLDSK1 — Floppy disk boot entry (roa375.asm lines 615-649)
 */
static void fldsk1(boot_state_t *st) {
    uint8_t status;

    hal_delay(1, 0xFF);

    /* Sense drive status */
    snsdrv(st);
    status = st->fdcres[0] & 0x23;
    if (status != (st->drvsel + 0x20)) {
        check_prom1();
        return;
    }

    /* Recalibrate */
    if (recalv(st) != 0) {
        check_prom1();
        return;
    }

    /* FLDSK3: Boot detection and read */
    if (boot_detect(st) != 0) {
        check_prom1();
        return;
    }

    /* Disable PROMs — full RAM now */
    hal_prom_disable();

    /* Read track 0 */
    while (1) {
        rdtrk0(st, st->trbyt);
        if (st->curcyl != 0) break;
        dskauto(st);
    }

    /* BOOT2 */
    st->dsktyp = 1;
    boot7(st);
    flboot(st);
}

/*
 * PREINIT — Pre-initialization (roa375.asm lines 136-171)
 * Reads switches, zeros work area, starts motor, enters floppy boot.
 */
static void preinit(boot_state_t *st) {
    uint8_t sw1;

    st->fdctmo = 3;
    st->fdcwai = 4;
    st->flpwai = 4;

    /* Read switch settings */
    sw1 = hal_read_sw1();
    st->diskbits = sw1 & 0x80;

    /* Zero state variables */
    st->curhed = 0;
    st->drvsel = 0;
    st->dsktyp = 0;
    st->morefl = 0;
    st->flpflg = 0;
    st->memadr = 0;
    st->trbyt = 0;
    st->trkovr = 0;

    hal_ei();

    /* Start mini floppy motor */
    hal_motor(1);

    st->reptim = 5;

    /* Enter floppy boot */
    fldsk1(st);
}

/*
 * SYSCALL — Disk I/O entry point for CP/M BIOS (roa375.asm lines 826-862)
 * Called by CP/M BIOS to read disk tracks.
 * B = bit7: head, bits 6-0: cylinder
 * C = bit7: (unused), bits 6-0: record
 * HL = memory destination address
 */
void syscall(boot_state_t *st, uint16_t addr, uint8_t b, uint8_t c) {
    st->memadr = addr;
    st->currec = c & 0x7F;
    st->curcyl = b & 0x7F;

    if (st->curcyl == 0) dskauto(st);

    st->curhed = (b & 0x80) ? 1 : 0;

    rdtrk0(st, 0);

    if ((b & 0x7F) == 0) {
        st->curcyl = 1;
        dskauto(st);
    }
}

#ifndef HOST_TEST
/*
 * main — Entry point called from crt0.asm after relocation
 *
 * Initializes all hardware, clears display, enters boot sequence.
 */
int main(void) {
    boot_state_t *st = &g_state;

    /* Delay for hardware settle */
    hal_delay(1, 0xFF);

    /* Initialize all peripherals */
    init_pio();
    init_ctc(0x99);             /* Mode byte from PIO init (POP AF in asm) */
    init_dma();
    init_crt();
    init_fdc();

    /* Clear display and show banner */
    clear_screen();
    display_banner();

    /* Enter pre-init and boot sequence */
    preinit(st);
    return 0;
}
#endif
