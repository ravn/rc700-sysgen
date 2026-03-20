/*
 * boot.c — Boot logic for RC702 autoload
 *
 * Register-based calling convention: functions take up to 2 params
 * via sdcccall(1) ABI and return status values directly.
 */

#include <string.h>
#include "hal.h"
#include "boot.h"



/* Boot state variables — see boot.h for declarations.
 * Initialized to zero; on Z80, preinit() sets non-zero values. */
byte fdcres[7] = {0};
byte fdcflg = 0;
byte epts = 0;
byte trksz = 0;
byte drvsel = 0;
byte fdctmo = 0;
byte fdcwai = 0;
byte curcyl = 0;
byte curhed = 0;
byte currec = 0;
byte reclen = 0;
byte cureot = 0;
byte gap3 = 0;
byte dtl = 0;
word secbyt = 0;
byte flpflg = 0;
byte flpwai = 0;
byte diskbits = 0;
byte dsktyp = 0;
byte morefl = 0;
byte reptim = 0;
word memadr = 0;
word trbyt = 0;
word trkovr = 0;
byte errsav = 0;

/* NOTE: FDC command block (curcyl..dtl) must be contiguous in memory.
 * flrtrk() sends 7 bytes starting at &curcyl.  The variables are
 * defined consecutively above — do not reorder or insert between them.
 * Verified at runtime by assert in test suite. */

/* Error/status message strings — non-static for assembly access */
const char msg_rc700[]   = " RC700";
const char msg_rc702[]   = " RC702";
const char msg_nosys[]   = " **NO SYSTEM FILES** ";
const char msg_nocat[]   = " **NO KATALOG** ";
const char msg_nodisk[]  = " **NO DISKETTE NOR LINEPROG** ";
const char msg_diskerr[] = "**DISKETTE ERROR** ";

/* halt_forever — infinite loop (never returns) */
void halt_forever(void) { for (;;); }

/* halt_msg — copy 'len' bytes to display buffer, then halt forever.
 *
 * Implemented as a macro so 'len' is a compile-time constant at
 * each call site — sdcc inlines memcpy as LDIR for constant lengths.
 * If halt_msg were a function, sdcc would emit a library call to
 * _memcpy instead of inlining, costing ~20 extra bytes.
 *
 * IMPORTANT: 'len' must NOT include the NUL terminator.
 * The message strings are C string literals with trailing NUL,
 * but only 'len' bytes (without the NUL) are copied to display. */
#define halt_msg(msg, len) do { memcpy(dspstr, (msg), (len)); halt_forever(); } while(0)

/* HALT_MSG(str) — display string literal and halt.
 * Automatically computes length excluding NUL terminator. */

/* b7_cmp6 — compare 6 bytes.  Pointer-increment style generates compact
 * sdcc output (17 bytes, no IX frame) vs indexed a[i] (35 bytes with IX). */
byte b7_cmp6(const byte *a, const byte *b) {
    byte i = 6;
    do {
        if (*a++ != *b++) return 1;
    } while (--i);
    return 0;
}

/* b7_chksys — check dir entry name + attribute.  Pointer-increment for
 * the 4-byte name comparison, then direct offset for the attribute byte. */
byte b7_chksys(const byte *dir, const byte *pattern) {
    byte i = 4;
    dir++;  /* skip dir[0] */
    do {
        if (*dir++ != *pattern++) return 1;
    } while (--i);
    /* dir now at dir[5], need dir[8] */
    if ((dir[3] & 0x3F) != 0x13) return 1;
    return 0;
}

void errdsp(byte code) {
    errsav = code;
    hal_ei();
    if (dsktyp & 0x01) return;
    hal_beep();
    halt_msg((const byte *)msg_diskerr, 19);
}

/*
 * boot7 — Verify Track 0 data and boot CP/M or ID-COMAL.
 *
 * After reading Track 0 into RAM at 0x0000, the boot ROM checks for
 * two disk format signatures to determine boot mode:
 *
 *   Offset 0x0002: " RC700" — ID-COMAL boot (old format)
 *     Bytes 0x0000-0x0001 are a 2-byte jump vector.  The signature
 *     immediately follows at 0x0002.  If found, search the directory
 *     area (0x0B80-0x0D00) for SYSM/SYSC file entries (BOOT8 path).
 *
 *   Offset 0x0008: " RC702" — CP/M + COMAL80 boot (new format)
 *     Bytes 0x0000-0x0001 are a 2-byte jump vector.  Bytes 0x0002-0x0007
 *     contain configuration data.  The signature is at 0x0008.  If found,
 *     jump via the 16-bit vector at 0x0000 (BOOT9 path).
 *
 * The original assembly (roa375.asm ISRC70X) derives offset 0x0008 via
 * an HL accumulation trick: ISRC70X adds 2 to HL and loads HL=6 as the
 * COMSTR length.  On the second call, HL carries over as 0x0006, so
 * HL+2 = 0x0008.  This C translation makes the offsets explicit.
 *
 * b7_cmp6/b7_chksys are C (pointer-increment avoids IX frame).
 *
 * Uses one file-scope global (b7_dir) to avoid IX frame pointer.
 * Uses goto for shared error paths to avoid duplicate halt_msg calls.
 */
static const char b7_sysm[] = "SYSM";
static const char b7_sysc[] = "SYSC";

static byte *b7_dir;

void boot7(void) {
    if (b7_cmp6((const byte *)RC700_SIG_OFF, (const byte *)msg_rc700) == 0) {
        b7_dir = (byte *)BOOT_DIR_OFF;
        while ((word)b7_dir < 0x0D00) {
            if (*b7_dir == 0) {
                b7_dir += 0x20;
                continue;
            }
            if (b7_chksys(b7_dir, (const byte *)b7_sysm) != 0)
                goto nosys;
            b7_dir += 0x20;
            if (*b7_dir == 0)
                goto nosys;
            if (b7_chksys(b7_dir, (const byte *)b7_sysc) != 0)
                goto nosys;
            return;
        }
        goto nosys;
    }

    if (b7_cmp6((const byte *)RC702_SIG_OFF, (const byte *)msg_rc702) == 0) {
        jump_to(*(word *)0x0000);
        return;
    }

    halt_msg((const byte *)msg_nocat, 16);
    return;

nosys:
    halt_msg((const byte *)msg_nosys, 21);
}

void check_prom1(void) {
    if (b7_cmp6((const byte *)0x2002, (const byte *)msg_rc702) == 0) {
        jump_to(*(word *)0x2000);
        return;
    }
    halt_msg((const byte *)msg_nodisk, 30);
}

static void nxthds(void) {
    byte max_head;
    currec = 1;
    max_head = (diskbits >> 1) & 0x01;
    if (max_head == curhed) {
        curhed = 0;
        curcyl++;
    } else {
        curhed++;
    }
}

static void calctx(void) {
    int16_t remaining;
    calctb();
    remaining = (int16_t)trkovr - (int16_t)trbyt;
    if (remaining > 0) {
        morefl = 1;
        trkovr = (word)remaining;
    } else {
        morefl = 0;
        trbyt = trkovr;
        trkovr = 0;
    }
}

static void rdtrk0(word trkovr_init) {
    trkovr = trkovr_init;

    while (1) {
        byte r = flseek();
        if (r == 1) { check_prom1(); return; }
        if (r != 0) { errdsp(0x06); return; }

        calctx();

        if (readtk(FDC_READ_DATA, 5) != 0) {
            errdsp(0x28);
            return;
        }

        memadr += trbyt;
        trbyt = 0;
        nxthds();
        if (!morefl) return;
    }
}

byte boot_detect(void) {
    curcyl = 0;
    curhed = 1;
    currec = 1;

    if (dskauto() == 0) {
        diskbits |= 0x02;
    }

    curhed = 0;
    return dskauto();
}

void flboot(void) {
    dsktyp = (diskbits & 0x80) | dsktyp;
    dsktyp--;
    dskauto();
    memadr = FLOPPYDATA;
    rdtrk0(0x7300 - 0x7000);
    dsktyp = 1;
    jump_to(COMALBOOT);
}

static void fldsk1(void) {
    byte status;

    hal_delay(1, 0xFF);

    snsdrv();
    status = fdcres[0] & 0x23;        /* ST3: RDY + HD + US (bits 5,1,0) */
    if (status != (drvsel + 0x20)) {  /* expect RDY set + matching drive */
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
        rdtrk0(trbyt);
        if (curcyl != 0) break;
        dskauto();
    }

    dsktyp = 1;
    boot7();
    flboot();
}

static void preinit(void) {
    /* Variables start at zero (copied from ROM by begin).
     * Only set non-zero initial values here. */
    fdctmo = 3;
    fdcwai = 4;
    flpwai = 4;
    diskbits = hal_read_sw1() & 0x80;

    hal_ei();
    hal_motor(1);
    reptim = 5;
    fldsk1();
}

void syscall(word addr, word bc) {
    byte b = (byte)(bc >> 8);
    byte c = (byte)(bc & 0xFF);

    memadr = addr;
    currec = c & 0x7F;
    curcyl = b & 0x7F;

    if (curcyl == 0) dskauto();

    curhed = (b & 0x80) ? 1 : 0;
    rdtrk0(0);

    if ((b & 0x7F) == 0) {
        curcyl = 1;
        dskauto();
    }
}

int main(void) {
    /* PIO, CTC, DMA, CRT are initialized in crt0.asm before _main */
    init_fdc();
    clear_screen();
    display_banner();
    preinit();
    return 0;
}
