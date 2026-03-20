/*
 * rom.c — RC702 autoload PROM: all CODE-section C source
 *
 * Single translation unit for the Z80 ROM build, enabling cross-function
 * inlining, dead code elimination, and better register allocation.
 *
 * Section order within the file:
 *   1. HAL functions (FDC wait loops, delay)
 *   2. Initialization (post-relocation entry, peripherals, FDC, CRT)
 *   3. Format tables and geometry
 *   4. FDC driver (commands, result handling, read/seek)
 *   5. Boot logic (signature check, disk read, main)
 *   6. Interrupt service routines
 *   7. Sentinel (code_end marker)
 *
 * Separately compiled units (different link order or codeseg):
 *   - intvec.c  — IVT at 0x7000, linked first
 *   - boot_entry.c — BOOT section at 0x0000
 *   - sections.asm — linker section layout
 */

#include <string.h>
#include <intrinsic.h>
#include "rom.h"

/* ================================================================
 * 1. HAL functions
 *
 * These were originally hand-written assembly.  sdcc
 * generates nearly identical code from C.
 *
 * delay timing note:
 *   The assembly version used dec a/jr nz (16 T-states/iteration) for the
 *   innermost loop.  sdcc generates djnz (13 T-states/iteration), making
 *   the delay ~19% shorter for the same parameters.  Callers that need to
 *   match the original timing must adjust their outer/inner values.
 *   See init_fdc for the compensated call (2, 157) that matches
 *   the original (1, 0xFF) assembly timing within 0.3%.
 *   If delay is ever reverted to assembly, restore init_fdc to (1, 0xFF).
 * ================================================================ */

void fdc_wait_write(byte val) {
    word t = 0;
    do {
        if ((_port_fdc_status & 0xC0) == 0x80) {
            _port_fdc_data = val;
            return;
        }
    } while (++t);
}

byte fdc_wait_read(void) {
    word t = 0;
    do {
        if ((_port_fdc_status & 0xC0) == 0xC0) {
            return _port_fdc_data;
        }
    } while (++t);
    return 0xFF;
}

void delay(byte outer, byte inner) {
    if (!outer) return;
    do {
        byte mid = inner;
        do {
            byte k = 0;
            do { } while (--k);
        } while (--mid);
    } while (--outer);
}

/* ================================================================
 * 2. Initialization
 * ================================================================ */

/* Set Z80 I register.  sdcccall(1) passes byte in A; ld i,a uses it.
 * Must NOT be inline — see rcbios-in-c documentation. */
static void set_i_reg(byte page)
{
    (void)page;
    __asm__("ld i, a\n");
}

/* Post-relocation entry point.  Called from BEGIN after LDIR.
 * Sets SP, I register, IM2, then calls init_peripherals + main.
 * __naked because we set SP mid-function. */
void init_relocated(void) __naked
{
    __asm__("ld sp, #" STR(ROM_STACK) "\n");
    set_i_reg(INTVEC_PAGE);
    intrinsic_im_2();
    init_peripherals();
    main();
    /* halt_forever — should never reach here */
    for (;;)
        ;
}

/*
 * init_peripherals — combined PIO/CTC/DMA/CRT initialization.
 * Uses hal macros which expand to direct __sfr port writes on Z80.
 */
void init_peripherals(void) {
    /* PIO setup */
    pio_write_a_ctrl(0x02);
    pio_write_b_ctrl(0x04);
    pio_write_a_ctrl(0x4F);
    pio_write_b_ctrl(0x0F);
    pio_write_a_ctrl(0x83);
    pio_write_b_ctrl(0x83);

    /* CTC setup */
    ctc_write(0, 0x08);    /* interrupt vector base (D0=0: vector word) */
    ctc_write(0, 0x47);    /* counter mode, falling edge, TC follows, reset */
    ctc_write(0, 0x20);    /* time constant = 32 */
    ctc_write(1, 0x47);    /* same config as Ch0 */
    ctc_write(1, 0x20);
    ctc_write(2, 0xD7);
    ctc_write(2, 0x01);
    ctc_write(3, 0xD7);
    ctc_write(3, 0x01);

    /* DMA setup */
    dma_command(0x20);
    dma_mode(0xC0);
    dma_unmask(0);
    dma_mode(0x4A);
    dma_mode(0x4B);

    /* CRT setup — Intel 8275 commands (bits 7-5 = command code) */
    crt_command(0x00);  /* reset (expect 4 param bytes) */
    crt_param(0x4F);    /*   S=0, H=79: 80 chars/row */
    crt_param(0x98);    /*   V=2 vretrace, R=24: 25 rows */
    crt_param(0x9A);    /*   L=9 underline pos, U=10 lines/char */
    crt_param(0x5D);    /*   F=0, M=1 transparent, C=01 blink underline cursor, Z=28 hretrace */
    crt_command(0x80);  /* load cursor (expect 2 param bytes) */
    crt_param(0x00);    /*   column = 0 */
    crt_param(0x00);    /*   row = 0 */
    crt_command(0xE0);  /* preset counters */
}

void clear_screen(void) {
    byte *p = dspstr;
    word i = 80 * 25;
    while (i--) *p++ = 0x20;
}

void init_fdc(void) {
    delay(2, 157);
    while (fdc_status() & 0x1F) ;
    fdc_wait_write(0x03);
    fdc_wait_write(0x4F);
    fdc_wait_write(0x20);
}

void display_banner(void) {
    extern const char msg_rc700[];
    const byte *src = (const byte *)msg_rc700;
    byte *dst = dspstr;
    byte i = 6;
    while (i--) *dst++ = *src++;
    scroll_offset = 0;
    crt_command(0x23);
}

/* ================================================================
 * 3. Format tables and geometry
 * ================================================================ */

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

/* ================================================================
 * 4. FDC driver
 *
 * NEC uPD765 (Intel 8272) commands and result handling.
 *
 * Main Status Register (fdc_status(), port 0x04):
 *   bit 7: RQM — ready for CPU data transfer
 *   bit 6: DIO — direction (0=CPU->FDC write, 1=FDC->CPU read)
 *   bit 5: EXM — in execution phase
 *   bit 4: CB  — command busy (FDC has a command in progress)
 *   bits 3-0:   drive busy flags (per-drive seek in progress)
 *
 * Result registers (fdcres[], read via fdc_wait_read()):
 *   ST0 [0]: bit 7-6 = IC (interrupt code: 00=normal, 01=abnormal,
 *            10=invalid cmd, 11=not ready); bit 5 = SE (seek end);
 *            bit 2 = HD (head); bits 1-0 = US (unit/drive select)
 *   ST1 [1]: error flags (EN, DE, OR, ND, NW, MA)
 *   ST2 [2]: error flags; bit 6 = CM (control mark, benign)
 *   ST3 [0]: from Sense Drive Status — bit 5 = RDY; bits 2-0 = HD+US
 *   [3]-[6]: C, H, R, N (cylinder, head, record, sector size code)
 * ================================================================ */

/*
 * waitfl timing model — must be long enough for worst-case FM track read.
 *
 * delay(outer, inner) compiles to:
 *   outer x inner x 256 DJNZ iterations x 13 T-states = total T-states
 *
 * waitfl calls delay once per iteration, with 255 iterations max.
 * Total timeout = 255 x delay T-states.
 *
 * Worst case: 8" FM track at 360 RPM = 166ms/revolution.
 * Head may need to wait for sector 1 (~1 revolution) then read all
 * 26 sectors (~1 revolution) = 332ms.  Add margin -> require >=400ms.
 *
 * Assembly DELAY(B=1,C=1) used a 16-bit HL loop: 511x24T = 12,264T.
 * delay(1,4) = 4x256x13 = 13,312T — matches within 8%.
 */
#define WAITFL_DELAY_OUTER  1
#define WAITFL_DELAY_INNER  4

/* Compile-time timeout check */
#define Z80_MHZ           4  /* RC702: Z80-A at 4 MHz */
#define WAITFL_PER_ITER  ((long)(WAITFL_DELAY_OUTER) * (WAITFL_DELAY_INNER) * 256 * 13)
#define WAITFL_MS        (255L * WAITFL_PER_ITER / (Z80_MHZ * 1000))
typedef char _waitfl_timeout_check[(WAITFL_MS >= 400) ? 1 : -1];

void snsdrv(void) {
    fdc_wait_write(FDC_SENSE_DRIVE);
    fdc_wait_write(drvsel);
    fdcres[0] = fdc_wait_read(); /* ST3: drive status */
}

void flo4(void) {
    fdc_wait_write(FDC_RECALIBRATE);
    fdc_wait_write(drvsel);
}

void flo6(void) {
    fdc_wait_write(FDC_SENSE_INT);
    fdcres[0] = fdc_wait_read();   /* ST0 */
    if ((fdcres[0] & 0xC0) != 0x80) {  /* IC != 10 (not "invalid cmd") */
        fdcres[1] = fdc_wait_read(); /* PCN (present cylinder) */
    }
}

void flo7(byte dh, byte cyl) {
    fdc_wait_write(FDC_SEEK);
    fdc_wait_write(dh & 0x07);  /* HD + US1/US0 (head + drive) */
    fdc_wait_write(cyl);        /* NCN (new cylinder number) */
}

void rsult(void) {
    byte i;

    fdcflg = 7;
    for (i = 0; i < 7; i++) {
        fdcres[i] = fdc_wait_read();
        delay(0, fdcwai);
        if (!(fdc_status() & 0x10)) {  /* CB=0: no more result bytes */
            fdcres[i + 1] = dma_status();
            return;
        }
    }
    errsav = 0xFE;
    errdsp(0xFE);
}

byte waitfl(byte timeout) {
    while (--timeout) {
        delay(WAITFL_DELAY_OUTER, WAITFL_DELAY_INNER);
        if (flpflg & 0x02) {
            di();
            flpflg = 0;
            ei();
            return 0;
        }
    }
    return 1;
}

/* Shared helper: check seek/recalibrate result */
static byte chk_seekres(byte expected_pcn) {
    if (waitfl(0xFF)) return 1;
    if ((drvsel + 0x20) != fdcres[0]) return 2; /* expect SE+drive in ST0 */
    if (expected_pcn != fdcres[1]) return 2;       /* verify cylinder (PCN) */
    return 0;
}

byte recalv(void) {
    flo4();
    return chk_seekres(0);
}

byte flseek(void) {
    flo7((curhed << 2) | drvsel, curcyl);
    return chk_seekres(curcyl);
}

void stpdma(void) {
    di();
    dma_mask(1);
    dma_mode(0x45);  /* demand mode, addr increment, read, channel 1 */
    dma_clear_bp();
    dma_ch1_addr(memadr);
    dma_ch1_wc(trbyt - 1);
    dma_unmask(1);
    ei();
}

void flrtrk(byte cmd) {
    byte mfm_flag = (diskbits & 0x01) ? FDC_MFM : 0;
    byte dh = (curhed << 2) | drvsel;

    di();
    fdcflg = 0xFF;

    fdc_wait_write(cmd + mfm_flag);
    fdc_wait_write(dh);

    if ((cmd & 0x0F) == FDC_READ_DATA) {
        byte *p = &curcyl;
        byte i;
        for (i = 0; i < 7; i++) {
            fdc_wait_write(p[i]);
        }
    }
    ei();
}

byte chkres(void) {
    if ((fdcres[0] & 0xC3) == drvsel &&  /* ST0: IC=00 + drive match */
        fdcres[1] == 0 &&                     /* ST1: no errors */
        (fdcres[2] & 0xBF) == 0) {            /* ST2: ignore CM (bit 6) */
        return 0;
    } else {
        reptim--;
        return (reptim == 0) ? 2 : 1;
    }
}

/* File-scope global to avoid IX frame pointer in readtk's retry loop.
 * Safe: no recursion in the call graph (verified). */
static byte readtk_cmd;

byte readtk(byte cmd, byte retries) {
    byte r;
    readtk_cmd = cmd;
    reptim = retries;

    while (1) {
        /* inline clrflf */
        di();
        flpflg = 0;
        ei();

        if ((readtk_cmd & 0x0F) != FDC_READ_ID) {
            stpdma();
        }

        flrtrk(readtk_cmd);

        if (waitfl(0xFF)) return 1;

        r = chkres();
        if (r == 0) return 0;
        if (r == 2) return 1;
    }
}

byte dskauto(void) {
    diskbits &= ~0x01;

    while (1) {
        if (flseek() != 0) return 1;

        trbyt = 4;
        if (readtk(FDC_READ_ID, 1) == 0) break;
        if (diskbits & 0x01) return 1;
        diskbits |= 0x01;
    }

    /* fdcres[6] = N (sector size code) from Read ID result */
    diskbits = (diskbits & 0xE3) | (fdcres[6] << 2); /* store N in bits 4-2 */
    /* inline setfmt */
    reclen = (diskbits >> 2) & 0x07; /* extract N back from diskbits */
    fmtlkp();
    calctb();
    return 0;
}

/* ================================================================
 * 5. Boot logic
 * ================================================================ */

/* Boot state variables — initialized to zero; preinit() sets non-zero values. */
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
 * defined consecutively above — do not reorder or insert between them. */

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
 * IMPORTANT: 'len' must NOT include the NUL terminator. */
#define halt_msg(msg, len) do { memcpy(dspstr, (msg), (len)); halt_forever(); } while(0)

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
    ei();
    if (dsktyp & 0x01) return;
    beep();
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

    delay(1, 0xFF);

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

    prom_disable();

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
    diskbits = read_sw1() & 0x80;

    ei();
    motor(1);
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
    /* PIO, CTC, DMA, CRT are initialized by init_relocated() before _main */
    init_fdc();
    clear_screen();
    display_banner();
    preinit();
    return 0;
}

/* ================================================================
 * 6. Interrupt service routines
 * ================================================================ */

/*
 * crt_refresh — CRT vertical retrace handler
 *
 * Reprograms DMA channels 2 and 3 to implement hardware-assisted
 * circular-buffer scrolling of the 80x25 display at DSPSTR (0x7800).
 *
 * DMA Ch2 transfers from DSPSTR+scroll_offset to end of buffer.
 * DMA Ch3 transfers from DSPSTR for the full 2000-byte screen.
 * Together they present a scrolled view without copying memory.
 *
 * Called from CRTINT (CTC Ch2 interrupt) with interrupts disabled.
 */
void crt_refresh(void) {
    (void)crt_status();     /* acknowledge CRT interrupt */

    dma_mask(2);            /* disable Ch2 during reprogramming */
    dma_mask(3);            /* disable Ch3 during reprogramming */
    dma_clear_bp();         /* reset DMA byte pointer flip-flop */

    word so = scroll_offset;
    dma_ch2_addr(DSPSTR_ADDR + so);
    dma_ch2_wc(80 * 25 - 1 - so);  /* remaining bytes from scroll point */

    dma_ch3_addr(DSPSTR_ADDR);
    dma_ch3_wc(80 * 25 - 1);       /* full screen buffer */

    dma_unmask(2);          /* re-enable Ch2 */
    dma_unmask(3);          /* re-enable Ch3 */

    /* Rearm CTC Ch2: counter mode, interrupt, falling edge, TC follows */
    ctc_write(2, 0xD7);
    ctc_write(2, 0x01);    /* time constant = 1 (every retrace) */
}

/* dumint — dummy handler for unused interrupt vectors (generates EI; RETI) */
void dumint(void) __interrupt(0) {
}

/* crtint — CRT vertical retrace ISR (CTC Ch2).
 * __critical: keeps interrupts disabled throughout (protects DMA programming).
 * __interrupt(1): generates push/pop for all registers + EI + RETI.
 * The (N) number is mandatory — without it sdcc generates RETN not RETI. */
void crtint(void) __critical __interrupt(1) {
    crt_refresh();
}

/* flpint — Floppy disk ISR (CTC Ch3).
 * Body inlined (sdcc doesn't inline single-use static functions). */
void flpint(void) __critical __interrupt(2) {
    flpflg = 2;
    delay(0, fdctmo);
    if (fdc_status() & 0x10) {  /* CB=1: result phase ready */
        rsult();
    } else {
        flo6();
    }
}

/* ================================================================
 * 7. Sentinel — must be last.
 * &code_end - &intvec = payload size to relocate from ROM to RAM.
 * ================================================================ */
const byte code_end = 0xFF;
