/*
 * bios.c — RC702 CP/M BIOS in C (REL30)
 *
 * Phase 1d: CRT ISR, keyboard input, console output with escape sequences.
 *
 * ISRs that switch stacks use __naked wrappers (not __interrupt) because
 * sdcc's __interrupt puts EI at the function START, enabling nested
 * interrupts.  The CRT ISR must run with interrupts disabled to protect
 * DMA programming and the shared sp_sav variable.
 *
 * CONOUT switches to BIOS stack (0xF500) and dispatches: escape state
 * (XY addressing), control characters (cursor, scroll, clear), or
 * printable characters (OUTCON conversion, display, advance cursor).
 * BGSTAR (background bitmap) is omitted — saves ~382 bytes.
 */

#include <string.h>
#include "hal.h"
#include "bios.h"
#include "builddate.h"

/* Forward declarations */
static void conout_body(void);
static void putch(byte c);
static void puts_p(const char *s);
static void put_hex(word val);
static void put_dec(word val);
static word bios_seldsk_c(byte drv);
static void bios_home_c(void);
static byte xread(void);
static byte xwrite(byte wt);

/* ================================================================
 * Disk data tables (moved from crt0.asm)
 * ================================================================ */

/* Sector translation tables */
const byte tran0[] = {                  /* 8" SS 128 B/S, skew 6 */
    1,7,13,19, 25,5,11,17, 23,3,9,15,
    21,2,8,14, 20,26,6,12, 18,24,4,10, 16,22
};
const byte tran8[] = {                  /* 8" DD 512 B/S, skew 4 */
    1,5,9,13, 2,6,10,14, 3,7,11,15, 4,8,12
};
const byte tran16[] = {                 /* 5.25" DD 512 B/S, skew 2 */
    1,3,5,7, 9,2,4,6, 8
};
const byte tran24[] = {                 /* 8" DD 256 B/S, no translation */
    1,2,3,4, 5,6,7,8, 9,10,11,12,
    13,14,15,16, 17,18,19,20, 21,22,23,24, 25,26
};

/* Disk Parameter Blocks */
const DPB dpb0 = {                      /* 8" SS 128 B/S (IBM standard) */
    26, 3, 7, 0, 242, 63, 192, 0, 16, 2
};
const DPB dpb8 = {                      /* 8" DD 512 B/S (data area) */
    120, 4, 15, 0, 449, 127, 192, 0, 32, 2
};
const DPB dpb16 = {                     /* 5.25" DD 512 B/S */
    26, 3, 7, 0, 242, 63, 192, 0, 16, 0
};
const DPB dpb24 = {                     /* 8" DD 256 B/S (track 0 side 1) */
    104, 4, 15, 0, 471, 127, 192, 0, 32, 0
};

/* Floppy Disk Format descriptors */
const FDF fdf[4] = {
    { 26, 127,  0, 0, 26,  7, 77 },    /* 8" SS 128 B/S (FM) */
    { 30, 511, 64, 2, 15, 27, 77 },    /* 8" DD 512 B/S (MFM) */
    { 26, 127,  0, 0, 26,  7, 77 },    /* 8" SS 128 B/S (T0 S0) */
    { 52, 255, 64, 1, 26, 14, 77 },    /* 8" DD 256 B/S (T0 S1) */
};

/* Floppy System Parameters (16 bytes each) */
const FSPA fspa[4] = {
    { (DPB *)&dpb0,   8,  26, 0, 1, (byte *)tran0,  128, 0, {0} },
    { (DPB *)&dpb8,  16, 120, 3, 3, (byte *)tran8,  255, 0, {0} },
    { (DPB *)&dpb16,  8,  26, 0, 1, (byte *)tran24, 128, 0, {0} },
    { (DPB *)&dpb24,  8, 104, 1, 2, (byte *)tran24, 255, 0, {0} },
};

/* Track offset table (2 floppy drives + 6 unused) */
word trkoff[] = { 2, 2, 0, 0, 0, 0, 0, 0 };

/* ================================================================
 * ISR shared state
 * ================================================================ */

static word sp_sav;           /* saved SP during ISR stack switch */

/* Keyboard ring buffer (REL30) */
static byte kbbuf[KBBUFSZ];
static volatile byte kbhead;   /* write index (ISR updates) */
static volatile byte kbtail;   /* read index (CONIN updates) */

/* ================================================================
 * Floppy disk driver — variables and buffers
 * ================================================================ */

/* Host sector buffer (512 bytes) and directory scratch (128 bytes) */
static byte hstbuf[512];
static byte dirbf[128];

/* Allocation and check vectors (2 drives) */
static byte all0[71], chk0[32];
static byte all1[71], chk1[32];

/* CP/M requested disk/track/sector (set by BDOS calls) */
static byte  sekdsk;
static word sektrk;
static word seksec;

/* Host buffer state (what's cached in hstbuf) */
static byte  hstdsk;
static word hsttrk;
static word hstsec;

/* Last seek position (skip redundant FDC seeks) */
static byte  lstdsk;
static word lsttrk;

/* Intermediate: seksec >> secshf */
static word sekhst;

/* Buffer status */
static byte  hstact;     /* 0=empty, 1=valid */
static byte  hstwrt;     /* 0=clean, 1=dirty */

/* Unallocated sector tracking */
static byte  unacnt;
static byte  unadsk;
static word unatrk;
static word unasec;
static byte  unamsk;

/* I/O operation control */
static byte  erflag;
static byte  rsflag;
static byte  readop;
static byte  wrtype;  /* renamed to avoid conflict with WRTYPE macro */

/* DMA and format state */
static word dmaadr;  /* CP/M DMA address */
static const FDF *form;  /* pointer to current FDF entry */
static byte  cform;   /* current format index */
static byte  eotv;        /* sectors per side on track 0 */
static byte  drno;        /* highest drive number */

/* Physical disk control */
static byte  dskno;       /* drive + head select bits */
static word dskad;       /* DMA address for FDC */
static byte  actra;       /* actual track */
static byte  acsec;       /* actual sector (1-based) */
static byte  repet;       /* retry counter */
static volatile byte rstab[8];    /* FDC result table */
static volatile byte fl_flg;      /* floppy completion flag */

/* FSPA working copy (set by SELDSK) */
static word dpblck;      /* DPB pointer */
static byte  cpmrbp;      /* records per block */
static word cpmspt;      /* CP/M sectors per track */
static byte  secmsk;      /* sector mask */
static byte  secshf;      /* sector shift count */
static word trantb;      /* translation table pointer */
static byte  dtlv;        /* data length value */
static byte  dsktyp;      /* 0=floppy, 0xFF=HD */

/* Disk Parameter Headers — 2 drives × 16 bytes (8 words) each
 * DPH layout: XLT(2), scratch(6), DIRBF(2), DPB(2), CHK(2), ALV(2)
 * Initialized at boot; DPB pointer updated by SELDSK.
 */
static word dpbase[2 * 8];

/* Motor control */
static void fdstop(void)
{
    if (!(_port_sw1 & 0x80))    /* maxi: no motor control */
        return;
    _port_sw1 = 0x00;
}

static void waitd(word ticks)
{
    delcnt = ticks;
    while (delcnt)
        ;
}

static void fdstar(void)
{
    if (!(_port_sw1 & 0x80))    /* maxi: no motor control */
        return;
    __asm__("di");
    if (timer2 == 0) {
        /* motor was stopped — start and wait for spinup */
        timer2 = (word)fdtimo_var;
        __asm__("ei");
        _port_sw1 = 0x01;
        waitd(50);              /* 50 * 20ms = 1 second */
    } else {
        timer2 = (word)fdtimo_var;
        __asm__("ei");
    }
}

/* FDC low-level — inlined for speed on hot path (saves 27 T-states per call) */
static inline void fdc_wait_write(void)
{
    while ((_port_fdc_status & 0xC0) != 0x80)
        ;
}

static inline void fdc_wait_read(void)
{
    while ((_port_fdc_status & 0xC0) != 0xC0)
        ;
}

static void fdc_recalibrate(void)
{
    fdc_wait_write();
    _port_fdc_data = 0x07;      /* RECALIBRATE */
    fdc_wait_write();
    _port_fdc_data = dskno & 3; /* drive */
}

static void fdc_sense_int(void)
{
    fdc_wait_write();
    _port_fdc_data = 0x08;      /* SENSE INTERRUPT STATUS */
    fdc_wait_read();
    rstab[0] = _port_fdc_data;
    if ((rstab[0] & 0xC0) != 0x80) {
        fdc_wait_read();
        rstab[1] = _port_fdc_data;
    }
}

static void fdc_seek(void)
{
    fdc_wait_write();
    _port_fdc_data = 0x0F;      /* SEEK */
    fdc_wait_write();
    _port_fdc_data = dskno & 3; /* drive + head */
    fdc_wait_write();
    _port_fdc_data = actra;     /* cylinder */
}

static void fdc_result(void)
{
    byte i;
    for (i = 0; i < 7; i++) {
        byte delay;
        fdc_wait_read();
        rstab[i] = _port_fdc_data;
        for (delay = 4; delay; delay--)
            ;
        if (!(_port_fdc_status & 0x10))
            return;
    }
}

/* Interrupt flag */
static void clfit(void)
{
    __asm__("di");
    fl_flg = 0;
    __asm__("ei");
}

static void watir(void)
{
    while (!fl_flg)
        ;
}

static void wfitr(void)
{
    watir();
    clfit();
}

/* DMA setup for FDC transfers (channel 1)
 * CHKTRK sets dskad = HSTBUF address before calling secrd/secwr.
 * write=1 means FDC reads from memory (FLPR), write=0 means FDC writes to memory (FLPW)
 */
static word dma_count;      /* parameter: byte count for DMA */
static byte  dma_write;      /* parameter: 0=read(FDC→mem), 1=write(mem→FDC) */

static void flp_dma_setup(void)
{
    __asm__("di");
    _port_dma_smsk = 0x05;          /* mask ch1 */
    _port_dma_mode = dma_write ? 0x49 : 0x45;
    _port_dma_clbp = 0;
    _port_dma_ch1_addr = (byte)dskad;
    _port_dma_ch1_addr = (byte)(dskad >> 8);
    _port_dma_ch1_wc = (byte)dma_count;
    _port_dma_ch1_wc = (byte)(dma_count >> 8);
    _port_dma_smsk = 0x01;          /* unmask ch1 */
    __asm__("ei");
}

/* General FDC command (9-byte read/write sequence)
 * fdfp points past DMA count bytes, at the MF field:
 *   fdfp[0]=MF, fdfp[1]=N, fdfp[2]=EOT, fdfp[3]=gap
 */
static void fdc_general_cmd(byte cmd, byte *fdfp)
{
    __asm__("di");
    fdc_wait_write();
    _port_fdc_data = cmd + fdfp[0]; /* command + MF flag */
    fdc_wait_write();
    _port_fdc_data = dskno;         /* drive + head */
    fdc_wait_write();
    _port_fdc_data = actra;         /* cylinder */
    fdc_wait_write();
    _port_fdc_data = (dskno >> 2) & 3;  /* head number */
    fdc_wait_write();
    _port_fdc_data = acsec;         /* sector */
    fdc_wait_write();
    _port_fdc_data = fdfp[1];       /* N (sector size code) */
    fdc_wait_write();
    _port_fdc_data = fdfp[2];       /* EOT (final sector) */
    fdc_wait_write();
    _port_fdc_data = fdfp[3];       /* gap length */
    fdc_wait_write();
    _port_fdc_data = dtlv;          /* data length */
    __asm__("ei");
}

/* CHKTRK: multi-density track dispatch + sector translation + seek */
static void chktrk(void)
{
    byte sec, ev;
    byte *tp;

    sec = (byte)hstsec;
    ev = eotv;
    dskno = hstdsk;

    if (sec >= ev) {
        /* head 1 (track 0 side 1, or beyond EOTV) */
        dskno |= 4;
        sec -= ev;
    }

    /* sector translation */
    tp = (byte *)trantb;
    acsec = tp[sec];
    actra = (byte)hsttrk;
    dskad = (word)&hstbuf[0];

    /* check if seek needed */
    if (hstdsk == lstdsk && hsttrk == lsttrk)
        return;

    /* need to seek */
    lstdsk = hstdsk;
    lsttrk = hsttrk;
    clfit();
    fdc_seek();
    wfitr();

    /* check seek completion */
    if (rstab[0] == ((dskno & 3) | 0x20))
        return;

    /* seek failed — recalibrate and retry */
    clfit();
    fdc_recalibrate();
    wfitr();
    fdc_sense_int();
    clfit();
    fdc_seek();
    wfitr();
    fdc_sense_int();
}

/* Sector read with retry */
static void secrd(void)
{
    repet = 10;
    for (;;) {
        fdstar();
        clfit();

        dma_count = form->dma_count;

        dma_write = 0;
        flp_dma_setup();                /* FDC → memory */
        fdc_general_cmd(6, (byte *)&form->mf);  /* READ DATA */
        watir();

        if (!(rstab[0] & 0xF8))
            return;                     /* success */

        /* debug: show result bytes on first error */
        if (repet == 10) {
            putch('(');
            put_hex(rstab[0]);
            putch(' ');
            put_hex(rstab[1]);
            putch(' ');
            put_hex(rstab[2]);
            putch(')');
        }

        if (rstab[0] & 0x08)            /* write protected — no retry */
            goto fail;

        if (--repet == 0)
            goto fail;

        if (repet == 5) {
            /* recalibrate and retry */
            clfit();
            fdc_recalibrate();
            wfitr();
            fdc_sense_int();
            clfit();
            fdc_seek();
            wfitr();
            fdc_sense_int();
        }
    }
fail:
    hstact = 0;
    erflag = 1;
}

/* Sector write with retry */
static void secwr(void)
{
    repet = 10;
    for (;;) {
        fdstar();
        clfit();

        dma_count = form->dma_count;

        dma_write = 1;
        flp_dma_setup();                /* memory → FDC */
        fdc_general_cmd(5, (byte *)&form->mf);  /* WRITE DATA */
        watir();

        if (!(rstab[0] & 0xF8))
            return;                     /* success */

        if (rstab[0] & 0x08)            /* write protected */
            goto fail;

        if (--repet == 0)
            goto fail;

        if (repet == 5) {
            clfit();
            fdc_recalibrate();
            wfitr();
            fdc_sense_int();
            clfit();
            fdc_seek();
            wfitr();
            fdc_sense_int();
        }
    }
fail:
    hstact = 0;
    erflag = 1;
}

/* Write host buffer to disk */
static void wrthst(void)
{
    chktrk();
    secwr();
}

/* Debug: dump N bytes from addr as hex */
static void dbg_hexdump(byte n, byte *p)
{
    byte i;
    for (i = 0; i < n; i++) {
        put_hex(p[i]);
        putch(' ');
    }
}

static byte wboot_count;

/* Debug trace ring buffer in BSS
 * Each entry: [type, p1, p2_lo, p2_hi]
 * Type codes: 'H'=HOME, 'S'=SELDSK, 'T'=SETTRK, 's'=SETSEC, 'D'=SETDMA,
 *             'R'=READ, 'W'=WRITE, 'X'=SECTRAN, 'B'=WBOOT
 */
#define DBG_BUFSZ 252
static byte dbg_idx;
static byte dbg_buf[DBG_BUFSZ];
static word dbg_p2;            /* 3rd parameter for dbg_trace4 */

static void dbg_trace4(byte type, byte p1)
{
    static byte idx;
    idx = dbg_idx;
    if (idx < DBG_BUFSZ) {
        dbg_buf[idx] = type;
        dbg_buf[idx + 1] = p1;
        dbg_buf[idx + 2] = (byte)dbg_p2;
        dbg_buf[idx + 3] = (byte)(dbg_p2 >> 8);
        dbg_idx = idx + 4;
    }
}

/* Read host buffer from disk */
static void rdhst(void)
{
    if (unamsk)
        ;                   /* force pre-read if unamsk set */
    else
        unacnt = 0;
    chktrk();
    secrd();
}

/* 16-bit track compare: *(word *)p == sektrk */
static byte trkcmp(word *p)
{
    return *p == sektrk;
}

/* Core blocking/deblocking algorithm (DRI standard) */
static byte rwoper(void)
{
    static byte shift, i;
    static word hs;
    static byte *src, *dst;
    static word offset;

    /* compute host sector: sekhst = seksec >> (secshf-1)
     * Original asm: DEC B first, then shift if nonzero.
     * secshf=3 → 2 shifts (divide by 4, for 512B sectors).
     * secshf=1 → 0 shifts (128B sectors, no deblocking). */
    shift = secshf;
    hs = seksec;
    for (i = 1; i < shift; i++)
        hs >>= 1;
    sekhst = hs;

    /* check if host buffer is active and matches */
    if (hstact) {
        if (sekdsk == hstdsk && trkcmp(&hsttrk) && sekhst == hstsec)
            goto match;
        /* not matching — flush if dirty */
        if (hstwrt)
            wrthst();
    }

    /* fill host buffer */
    hstact = 1;
    hstdsk = sekdsk;
    hsttrk = sektrk;
    hstsec = sekhst;
    if (rsflag)
        rdhst();
    hstwrt = 0;

match:
    /* compute offset into host buffer */
    offset = (word)(seksec & secmsk) << 7;
    src = &hstbuf[offset];
    dst = (byte *)dmaadr;

    if (readop) {
        /* read: copy from host buffer to DMA area */
        for (i = 0; i < 128; i++)
            dst[i] = src[i];
    } else {
        /* write: copy from DMA area to host buffer */
        hstwrt = 1;
        for (i = 0; i < 128; i++)
            src[i] = dst[i];
    }

    /* post-processing */
    if (erflag) {
        hstact = 0;
    }

    if (wrtype == WRDIR && !erflag) {
        /* directory write: flush immediately */
        hstwrt = 0;
        wrthst();
    }

    {
        byte err = erflag;
        erflag = 0;
        return err;
    }
}

/* GFPA: get format descriptor from CFORM */
static const FDF *gfpa(void)
{
    return &fdf[(cform >> 3) & 3];
}

/* ================================================================
 * Hardware initialization (called from crt0.asm after relocation)
 * ================================================================ */

void bios_hw_init(void)
{
    /* PIO: set interrupt vectors and modes */
    _port_pio_a_ctrl = 0x20;    /* PIO-A interrupt vector */
    _port_pio_b_ctrl = 0x22;    /* PIO-B interrupt vector */
    _port_pio_a_ctrl = 0x4F;    /* PIO-A input mode */
    _port_pio_b_ctrl = 0x0F;    /* PIO-B output mode */
    _port_pio_a_ctrl = 0x83;    /* PIO-A enable interrupt */
    _port_pio_b_ctrl = 0x83;    /* PIO-B enable interrupt */

    /* CTC: set interrupt vector and program all channels */
    _port_ctc0 = 0x00;         /* CTC interrupt vector */
    _port_ctc0 = mode0;        /* ch0 mode */
    _port_ctc0 = count0;       /* ch0 count (38400 baud) */
    _port_ctc1 = *((&mode0) + 2);  /* ch1 mode */
    _port_ctc1 = *((&mode0) + 3);  /* ch1 count */
    _port_ctc2 = *((&mode0) + 4);  /* ch2 mode (display) */
    _port_ctc2 = *((&mode0) + 5);  /* ch2 count */
    _port_ctc3 = *((&mode0) + 6);  /* ch3 mode (floppy) */
    _port_ctc3 = *((&mode0) + 7);  /* ch3 count */

    /* SIO: program channels A and B */
    {
        byte i;
        for (i = 0; i < 9; i++)
            _port_sio_a_ctrl = psioa[i];
        for (i = 0; i < 11; i++)
            _port_sio_b_ctrl = psiob[i];
    }

    /* SIO: read initial status registers */
    (void)_port_sio_a_ctrl;     /* read RR0-A */
    _port_sio_a_ctrl = 1;       /* select RR1 */
    (void)_port_sio_a_ctrl;     /* read RR1-A */
    (void)_port_sio_b_ctrl;     /* read RR0-B */
    _port_sio_b_ctrl = 1;       /* select RR1 */
    (void)_port_sio_b_ctrl;     /* read RR1-B */

    /* DMA: enter command mode and set channel modes */
    _port_dma_cmd = 0x20;       /* master clear */
    _port_dma_mode = 0x48;      /* ch0 mode (HD) */
    _port_dma_mode = 0x4A;      /* ch2 mode (display) */
    _port_dma_mode = 0x4B;      /* ch3 mode (display) */

    /* FDC: send SPECIFY command */
    while ((_port_fdc_status & 0x1F) != 0)
        ;  /* wait for FDC ready */
    while ((_port_fdc_status & 0xC0) != 0x80)
        ;
    _port_fdc_data = 0x03;      /* SPECIFY command */
    while ((_port_fdc_status & 0xC0) != 0x80)
        ;
    _port_fdc_data = 0xDF;      /* step rate 3ms, head unload 240ms */
    while ((_port_fdc_status & 0xC0) != 0x80)
        ;
    _port_fdc_data = 0x28;      /* head load 40ms, DMA mode */

    /* Clear display buffer (DSPROW(0) to SCRNEND with spaces) */
    memset(DSPROW(0), ' ', SCRNEND - DSPSTR + 1);

    /* Clear work area (0xFFD1-0xFFFF with zeros) */
    memset((void *)0xFFD1, 0, 0x002F);

    /* CRT 8275: reset and program */
    _port_crt_cmd = 0x00;       /* reset */
    _port_crt_param = par1;     /* chars/row */
    _port_crt_param = par2;     /* rows/frame */
    _port_crt_param = par3;     /* lines/char + underline */
    _port_crt_param = par4;     /* cursor format */
    _port_crt_cmd = 0x80;       /* load cursor position */
    _port_crt_param = 0;        /* cursor X = 0 */
    _port_crt_param = 0;        /* cursor Y = 0 */
    _port_crt_cmd = 0xE0;       /* preset counters */
    _port_crt_cmd = 0x23;       /* start display */

    /* Initialize runtime variables */
    wr5a = psioa[6] & 0x60;    /* SIO-A bits/char from WR5 */
    wr5b = psiob[8] & 0x60;    /* SIO-B bits/char from WR5 */
    adrmod = xyflg;             /* copy addressing mode */

    /* Initialize motor timer reload from config */
    stptim_var = cfgstptim;

    /* Initialize disk subsystem */
    {
        byte d;

        /* Copy initial drive format from config block */
        fd0[0] = infd0;            /* drive A format */
        fd0[1] = 0xFF;             /* end of drive table */

        /* Count configured drives from fd0 table */
        drno = 0;
        for (d = 0; d < 16; d++) {
            if (fd0[d] == 0xFF)
                break;
            drno = d;
        }

        /* Initialize DPH entries for each drive */
        for (d = 0; d <= drno && d < 2; d++) {
            word *dph = &dpbase[d * 8];
            dph[0] = 0;                        /* XLT */
            dph[1] = 0;                        /* scratch */
            dph[2] = 0;
            dph[3] = 0;
            dph[4] = (word)dirbf;          /* DIRBF */
            dph[5] = (word)&dpb8;          /* DPB (initial) */
            dph[6] = d == 0 ? (word)chk0 : (word)chk1;
            dph[7] = d == 0 ? (word)all0 : (word)all1;
        }

        /* Clear disk state */
        hstact = 0;
        hstwrt = 0;
        unacnt = 0;
        erflag = 0;
        cform = 0xFF;       /* force format reload on first SELDSK */
        lstdsk = 0xFF;      /* force seek on first access */
    }
}

/* ================================================================
 * BIOS entry points
 * ================================================================ */

void bios_boot(void) __naked
{
#ifndef HOST_TEST
    __asm
        ld sp, #0xF500          ; use BIOS private stack
        jp _bios_boot_c
    __endasm;
#endif
}

static void putch(byte c)
{
    usession = c;
    conout_body();
}

static void puts_p(const char *s)
{
    while (*s)
        putch(*s++);
}

static void put_hex(word v)
{
    static byte i;
    static byte nib;
    static char buf[5];
    static word val;
    val = v;
    for (i = 0; i < 4; i++) {
        nib = (val >> 12) & 0xF;
        buf[i] = nib < 10 ? '0' + nib : 'A' + nib - 10;
        val <<= 4;
    }
    buf[4] = 0;
    puts_p(buf);
}

static void put_dec(word val)
{
    byte d;
    if (val >= 10000) { d = 0; while (val >= 10000) { val -= 10000; d++; } putch('0' + d); }
    if (val >= 1000)  { d = 0; while (val >= 1000)  { val -= 1000;  d++; } putch('0' + d); }
    if (val >= 100)   { d = 0; while (val >= 100)   { val -= 100;   d++; } putch('0' + d); }
    if (val >= 10)    { d = 0; while (val >= 10)     { val -= 10;    d++; } putch('0' + d); }
    putch('0' + (byte)val);
}

static void wboot_c(void);

void bios_boot_c(void)
{
    /* Cold boot: print signon, init state, then warm boot */
    puts_p("\x0C"                       /* form feed = clear screen */
           "RC700 56k CP/M 2.2 bios " BUILDDATE "\r\n");

    *(volatile byte *)CDISK_ADDR = 0;
    hstact = 0;
    erflag = 0;
    hstwrt = 0;
    kbhead = 0;
    kbtail = 0;
    /* TODO: READI — arm SIO Ch.A receiver for serial ring buffer */

    wboot_c();
}

static void wboot_c(void)
{
    byte sec;

    wboot_count++;
    hal_ei();
    bios_seldsk_c(0);

    unacnt = 0;
    *(volatile byte *)IOBYTE_ADDR = 0;
    dskno = 0;

    bios_home_c();

    /* Load CCP+BDOS from track 1 into CCP_BASE */
    dmaadr = CCP_BASE;
    sektrk = 1;

    for (sec = 0; sec < NSECTS; sec++) {
        seksec = sec;
        if (xread()) {
            puts_p("\r\nDisk read error - reset\r\n");
            for (;;)
                hal_halt();
        }
        dmaadr += 128;
    }

    dmaadr = BUFF;

    /* Set up JP vectors at page zero */
#ifndef HOST_TEST
    *(volatile byte *)0x0000 = 0xC3;        /* JP opcode */
    *(volatile word *)0x0001 = BIOS_BASE + 3;  /* WBOOT entry */
    *(volatile byte *)0x0005 = 0xC3;        /* JP opcode */
    *(volatile word *)0x0006 = BDOS_BASE;

    /* Re-select drive to ensure clean state for CCP */
    bios_seldsk_c(0);

    /* Jump to CCP with current disk in C */
    __asm
        ld a, (#0x0004)             ; CDISK
        and #0x0F                   ; mask off user bits
        ld c, a
        jp CCP_BASE
    __endasm;
#endif
}

void bios_wboot(void) __naked
{
#ifndef HOST_TEST
    __asm
        ld sp, #0xF500          ; use BIOS private stack
        jp _wboot_c
    __endasm;
#endif
}

/* ----------------------------------------------------------------
 * Console I/O — keyboard ring buffer (REL30)
 * ---------------------------------------------------------------- */

byte bios_const(void)
{
    return (kbtail != kbhead) ? 0xFF : 0x00;
}

byte bios_conin(void)
{
    while (kbtail == kbhead)
        hal_halt();
    byte raw = kbbuf[kbtail];
    kbtail = (kbtail + 1) & (KBBUFSZ - 1);
    return *((volatile byte *)(INCONV_ADDR + raw));
}

/* ================================================================
 * Display driver — CONOUT with escape sequences
 *
 * Implements the RC702 display protocol: control characters 0x00-0x1F
 * dispatch via jump table, ESC = X Y for cursor addressing, printable
 * characters go through OUTCON conversion table to display memory.
 * BGSTAR (background bitmap) is intentionally omitted.
 * ================================================================ */

static byte graph;           /* graphical mode flag (sticky) */

/* Update 8275 cursor position from curx/cursy */
static void cursorxy(void)
{
    _port_crt_cmd = 0x80;       /* load cursor position command */
    _port_crt_param = curx;     /* X position */
    _port_crt_param = cursy;    /* Y position */
}

/* Reset cursor to top-left (does NOT update 8275) */
static void goto00(void)
{
    cury = 0;
    curx = 0;
    cursy = 0;
}

/* Move cursor down one row */
static void rowdn(void)
{
    cury += SCRN_COLS;
    cursy++;
    cursorxy();
}

/* Move cursor up one row */
static void rowup(void)
{
    cury -= SCRN_COLS;
    cursy--;
    cursorxy();
}

/* Scroll display up one line: copy ROW1..ROW24 to ROW0..ROW23, fill ROW24 */
static void scroll(void)
{
    memcpy(DSPROW(0), DSPROW(1), ROW24_OFF);
    memset(DSPROW(ROW24), ' ', SCRN_COLS);
}

/* Cursor right — advance column, wrap to next line or scroll */
static void cursor_right(void)
{
    if (curx < COLUMN79) {
        curx++;
        cursorxy();
    } else {
        curx = COLUMN0;
        if (cury != ROW24_OFF) {
            rowdn();
        } else {
            cursorxy();
            scroll();
        }
    }
}

/* Cursor left — wrap to previous line if at column 0 */
static void cursor_left(void)
{
    if (curx != COLUMN0) {
        curx--;
        cursorxy();
    } else {
        curx = COLUMN79;
        if (cury != ROW0_OFF) {
            rowup();
        } else {
            cury = ROW24_OFF;
            cursy = ROW24;
            cursorxy();
        }
    }
}

/* Cursor down — scroll if on last row */
static void cursor_down(void)
{
    if (cury != ROW24_OFF)
        rowdn();
    else
        scroll();
}

/* Cursor up — wrap to bottom if on first row */
static void cursor_up(void)
{
    if (cury != ROW0_OFF) {
        rowup();
    } else {
        cury = ROW24_OFF;
        cursy = ROW24;
        cursorxy();
    }
}

/* Carriage return — column 0, update cursor */
static void carriage_return(void)
{
    curx = COLUMN0;
    cursorxy();
}

/* Tab — 4 cursor rights */
static void tab(void)
{
    cursor_right();
    cursor_right();
    cursor_right();
    cursor_right();
}

/* Home — top-left + update cursor */
static void home(void)
{
    goto00();
    cursorxy();
}

/* Clear screen — fill display with spaces, home */
static void clear_screen(void)
{
    memset(screen, ' ', SCRN_SIZE);
    goto00();
    cursorxy();
}

/* Erase from cursor to end of line */
static void erase_to_eol(void)
{
    byte *row = screen + cury;
    for (byte i = curx; i < SCRN_COLS; i++)
        row[i] = ' ';
}

/* Erase from cursor to end of screen */
static void erase_to_eos(void)
{
    word pos = cury + curx;
    byte *p = screen + pos;
    word count = SCRN_SIZE - pos;
    while (count--)
        *p++ = ' ';
}

/* Delete line — shift lines up from cury+1 to ROW24, fill ROW24 */
static void delete_line(void)
{
    static word count;
    static byte *dst;
    count = ROW24_OFF - cury;
    dst = screen + cury;
    if (count != 0)
        memcpy(dst, dst + SCRN_COLS, count);
    memset(DSPROW(ROW24), ' ', SCRN_COLS);
}

/* Insert line — shift lines down from cury to ROW23, fill current line.
 * Backward copy (dst > src, overlapping) — memmove library hangs,
 * so use an explicit backward loop. */
static void insert_line(void)
{
    static word count;
    static byte *src;
    static byte *dst;

    count = ROW24_OFF - cury;
    if (count != 0) {
        src = screen + ROW24_OFF - 1;           /* last byte of ROW23 */
        dst = screen + ROW24_OFF + SCRN_COLS - 1; /* last byte of ROW24 */
        while (count--)
            *dst-- = *src--;
    }
    memset(screen + cury, ' ', SCRN_COLS);
}

/* XY cursor addressing — called for each byte after ctrl-F */
static void xyadd(void)
{
    byte val = (usession & 0x7F) - 32;
    xflg--;
    if (xflg != 0) {
        adr0 = val;             /* save first coordinate */
        return;
    }
    /* Second byte: compute final position */
    byte x_val, y_val;
    if (adrmod == 0) {
        x_val = adr0;           /* XY mode: first=X, second=Y */
        y_val = val;
    } else {
        x_val = val;            /* YX mode: first=Y, second=X */
        y_val = adr0;
    }
    /* Modular arithmetic (matches original CHKDC) */
    while (x_val >= SCRN_COLS) x_val -= SCRN_COLS;
    while (y_val >= SCRN_ROWS) y_val -= SCRN_ROWS;
    curx = x_val;
    cursy = y_val;
    cury = (word)y_val * SCRN_COLS;
    cursorxy();
}

/* Display printable character — convert, write, advance cursor */
static void displ(void)
{
    byte ch = usession;

    locad = cury + curx;

    if (ch >= 192)
        ch -= 192;

    if (ch >= 128) {
        graph = ch & 4;         /* set/clear graphical mode */
    } else if (!graph) {
        ch = *((byte *)(OUTCON_ADDR + ch));  /* OUTCON conversion */
    }

    screen[locad] = ch;
    cursor_right();
}

/* Control character dispatch (0x00-0x1F) */
static void specc(void)
{
    xflg = 0;                   /* cancel pending XY addressing */
    switch (usession) {
    case 0x01: insert_line(); break;
    case 0x02: delete_line(); break;
    case 0x05:                  /* ENQ = cursor left (same as BS) */
    case 0x08: cursor_left(); break;
    case 0x06: goto00(); xflg = 2; break;  /* start XY addressing */
    case 0x07: _port_bell = 0; break;    /* bell */
    case 0x09: tab(); break;
    case 0x0A: cursor_down(); break;
    case 0x0C: clear_screen(); break;
    case 0x0D: carriage_return(); break;
    case 0x18: cursor_right(); break;
    case 0x1A: cursor_up(); break;
    case 0x1D: home(); break;
    case 0x1E: erase_to_eol(); break;
    case 0x1F: erase_to_eos(); break;
    default: break;
    }
}

/* CONOUT body — dispatches based on escape state and char value */
static void conout_body(void)
{
    if (xflg != 0)
        xyadd();
    else if (usession < 32)
        specc();
    else
        displ();
}

/*
 * CONOUT entry point — stack-switching wrapper
 *
 * CP/M passes character in C register.  We switch to the BIOS stack
 * (0xF680) with interrupts disabled during the switch, then dispatch.
 * Matches the original CONOUT: DI, save SP, switch stack, EI, work,
 * DI, restore SP, EI, RET.
 */
void bios_conout(byte c) __naked
{
    (void)c;
#ifndef HOST_TEST
    __asm
        di
        push hl
        ld hl, #0
        add hl, sp              ; HL = caller SP (after push hl)
        ld sp, #0xF500          ; switch to BIOS stack
        ei
        push hl                 ; save caller SP on BIOS stack
        push af
        push bc
        push de
        ld a, c                 ; get char from C register
        ld (0xFFDA), a          ; usession
        call _conout_body
        pop de
        pop bc
        pop af
        pop hl                  ; caller SP
        di
        ld sp, hl               ; restore caller stack
        pop hl                  ; restore original HL
        ei
        ret
    __endasm;
#endif
}

void bios_list(byte c)
{
    (void)c;
}

void bios_punch(byte c)
{
    (void)c;
}

byte bios_reader(void)
{
    return 0x1A;    /* ^Z (EOF) — sdcccall(1) returns 8-bit in A, matches CP/M */
}

void bios_home(void) __naked
{
    /* CP/M calls HOME before SELDSK — flush pending writes, recalibrate */
#ifndef HOST_TEST
    __asm
        di
        push hl
        ld hl, #0
        add hl, sp
        ld sp, #0xF500
        ei
        push hl
        call _bios_home_c
        pop hl
        di
        ld sp, hl
        pop hl
        ei
        ret
    __endasm;
#endif
}

static void bios_home_c(void)
{
    dbg_p2 = 0; dbg_trace4('H', sekdsk);
    if (hstwrt) {
        wrthst();
    } else {
        hstact = 0;
    }
    fdstar();
    dskno = sekdsk;
    lstdsk = sekdsk;
    lsttrk = 0;
    clfit();
    fdc_recalibrate();
    wfitr();
}

word bios_seldsk(byte disk) __naked
{
    /* CP/M passes drive in C register, expects DPH in HL */
    (void)disk;
#ifndef HOST_TEST
    __asm
        di
        push bc
        ld hl, #0
        add hl, sp
        ld sp, #0xF500          ; switch to BIOS stack
        ei
        push hl                 ; save caller SP
        ld a, c                 ; drive number in A (sdcccall 1)
        call _bios_seldsk_c    ; returns DPH in DE (sdcccall 1)
        ex de, hl               ; HL = DPH (for CP/M), DE = garbage
        pop de                  ; DE = saved caller SP
        di
        ex de, hl               ; save DPH in DE, HL = caller SP
        ld sp, hl               ; restore caller stack
        ex de, hl               ; HL = DPH (return value for CP/M)
        pop bc
        ei
        ret
    __endasm;
#else
    return 0;
#endif
}

static word bios_seldsk_c(byte drv)
{
    static byte drive;
    static byte fmt;
    static byte *fp;
    static word dph_offset;

    drive = drv;
    dbg_p2 = 0; dbg_trace4('S', drive);
    if (drive > drno)
        return 0;               /* invalid drive */

    sekdsk = drive;

    /* look up format from fd0 table */
    fp = &fd0[drive];
    fmt = *fp;

    /* if format changed, flush dirty buffer */
    if (fmt != cform) {
        if (hstwrt) {
            wrthst();
            hstwrt = 0;
        }
    }

    cform = fmt;

    /* get format descriptor (FDF) and system parameters (FSPA) */
    {
        static byte fi;
        static const FSPA *sp;
        fi = (fmt >> 3) & 3;           /* format index 0-3 */
        sp = &fspa[fi];

        form = &fdf[fi];
        eotv = form->eot;

        /* copy FSPA format parameters to working area */
        dpblck = (word)sp->dpb;
        cpmrbp = sp->cpmrbp;
        cpmspt = sp->cpmspt;
        secmsk = sp->secmsk;
        secshf = sp->secshf;
        trantb = (word)sp->trantb;
        dtlv = sp->dtlv;
        dsktyp = sp->dsktyp;
    }

    /* compute DPH offset */
    dph_offset = (word)drive * 16;

    /* update DPB pointer in DPH (offset 10 = word 5) */
    {
        word *dph = (word *)((byte *)dpbase + dph_offset);
        dph[5] = dpblck;
    }

    return (word)((byte *)dpbase + dph_offset);
}

void bios_settrk(word track) __naked
{
    /* CP/M passes track in BC */
    (void)track;
#ifndef HOST_TEST
    __asm
        ld (_sektrk), bc
        ret
    __endasm;
#endif
}

void bios_setsec(word sector) __naked
{
    /* CP/M passes sector in BC */
    (void)sector;
#ifndef HOST_TEST
    __asm
        ld (_seksec), bc
        ret
    __endasm;
#endif
}

void bios_setdma(word addr) __naked
{
    /* CP/M passes DMA address in BC */
    (void)addr;
#ifndef HOST_TEST
    __asm
        ld (_dmaadr), bc
        ret
    __endasm;
#endif
}

static byte xread(void)
{
    unacnt = 0;
    readop = 1;
    rsflag = 1;
    wrtype = WRUAL;
    {
        static byte rc;
        static byte *d;
        rc = rwoper();
        d = (byte *)dmaadr;
        dbg_p2 = seksec; dbg_trace4('R', (byte)sektrk);
        dbg_p2 = (word)(d[0] | (d[1] << 8)); dbg_trace4('D', (byte)(dmaadr >> 8));
        return rc;
    }
}

static byte xwrite(byte wt)
{
    dbg_p2 = seksec; dbg_trace4('W', wt);
    readop = 0;
    wrtype = wt;

    if (wt == WRUAL) {
        /* first write to unallocated block */
        cpmrbp = cpmrbp;  /* keep as-is, just set unacnt */
        unacnt = cpmrbp;
        unadsk = sekdsk;
        unatrk = sektrk;
        unasec = seksec;
    }

    /* check for continuation of unallocated writes */
    if (unacnt) {
        unacnt--;
        if (sekdsk != unadsk || sektrk != unatrk || seksec != unasec)
            goto alloc;

        /* match — advance unalloc pointer */
        unasec++;
        if (unasec >= cpmspt) {
            unasec = 0;
            unatrk++;
        }

        /* check if pre-read needed */
        rsflag = 0;
        if ((seksec & secmsk) == secmsk)
            unamsk = 1;
        else
            unamsk = 0;
        return rwoper();
    }

alloc:
    unacnt = 0;
    rsflag = secmsk;
    return rwoper();
}

byte bios_read(void) __naked
{
#ifndef HOST_TEST
    __asm
        di
        push bc
        push de
        push hl
        ld hl, #0
        add hl, sp
        ld sp, #0xF500
        ei
        push hl
        call _xread
        pop de
        di
        ex de, hl
        ld sp, hl
        ex de, hl
        pop hl
        pop de
        pop bc
        ei
        ret                     ; A = return value
    __endasm;
#else
    return 0;
#endif
}

byte bios_write(byte type) __naked
{
    /* CP/M passes write type in C */
    (void)type;
#ifndef HOST_TEST
    __asm
        di
        push bc
        push de
        push hl
        ld hl, #0
        add hl, sp
        ld sp, #0xF500
        ei
        push hl
        ld a, c                 ; write type from C register
        call _xwrite
        pop de
        di
        ex de, hl
        ld sp, hl
        ex de, hl
        pop hl
        pop de
        pop bc
        ei
        ret                     ; A = return value
    __endasm;
#else
    return 0;
#endif
}

byte bios_listst(void)
{
    return 0xFF;
}

word bios_sectran(word sector) __naked
{
    (void)sector;
#ifndef HOST_TEST
    __asm
        ; return BC in HL (no translation)
        ld h, b
        ld l, c
        ret
    __endasm;
#else
    return 0;
#endif
}

/* Extended entries */

void bios_wfitr(void) { }
byte bios_reads(void) { return 0; }
void bios_linsel(void) { }
void bios_exit(void) { }
void bios_clock(void) { }
void bios_hrdfmt(void) { }

/* ================================================================
 * Interrupt service routines
 *
 * ISRs needing stack switch use __naked wrappers with explicit
 * register save/restore.  This avoids sdcc's __interrupt putting
 * EI at function entry (which would allow nested interrupts and
 * corrupt the shared sp_sav variable).
 *
 * Simple ISRs (flag-set only, stubs) use __interrupt.
 * ================================================================ */

/* ISR wrappers below use __naked with explicit register save/restore
 * and stack switch to ISTACK (0xF620).  IY saved because sdcc_iy
 * library uses it as a global register. */

/*
 * CRT display refresh ISR body (CTC ch.2)
 *
 * Called ~50 times/sec by the 8275 CRT controller.
 * Programs the DMA controller to refresh the display from DSPSTR (0xF800).
 * Also increments the 32-bit RTC and decrements timers.
 */
void isr_crt(void) __naked
{
#ifndef HOST_TEST
    __asm
        ; Save SP and switch stack FIRST (original BIOS pattern).
        ; Only the hardware-pushed return address (2 bytes) touches
        ; the interrupted stack.
        ld (_sp_sav), sp
        ld sp, #0xF620
        push af
        push bc
        push de
        push hl
    __endasm;

    /* Read CRT status register to acknowledge interrupt */
    (void)_port_crt_cmd;

    /* Program DMA for 8275 display refresh */
    _port_dma_smsk = 6;         /* mask DMA ch2 */
    _port_dma_smsk = 7;         /* mask DMA ch3 */
    _port_dma_clbp = 0;         /* clear byte pointer flip-flop */

    /* DMA ch2: display data transfer (2000 bytes from DSPSTR) */
    hal_dma_ch2_addr(DSPSTR);
    hal_dma_ch2_wc(SCRN_SIZE - 1);

    /* DMA ch3: attribute data (zero length) */
    _port_dma_ch3_wc = 0;
    _port_dma_ch3_wc = 0;

    /* Unmask DMA channels */
    _port_dma_smsk = 2;         /* clear ch2 mask */
    _port_dma_smsk = 3;         /* clear ch3 mask */

    /* Reprogram CTC ch2 for next interrupt */
    _port_ctc2 = 0xD7;          /* counter mode */
    _port_ctc2 = 1;             /* count 1 */

    /* Increment 32-bit real-time clock */
    rtc0++;
    if (rtc0 == 0)
        rtc2++;

    /* Timer 0: exit routine countdown */
    if (timer1 != 0) {
        timer1--;
        if (timer1 == 0) {
            /* Call exit routine at warmjp address */
            ((void (*)(void))warmjp)();
        }
    }

    /* Timer 1: floppy motor-off countdown */
    if (timer2 != 0) {
        timer2--;
        if (timer2 == 0)
            fdstop();
    }

    /* General delay timer */
    if (delcnt != 0)
        delcnt--;

    __asm
        pop hl
        pop de
        pop bc
        pop af
        ld sp, (_sp_sav)
        ei
        reti
    __endasm;
#endif
}

void isr_pio_kbd(void) __naked
{
#ifndef HOST_TEST
    __asm
        ld (_sp_sav), sp
        ld sp, #0xF620
        push af
        push bc
        push de
        push hl
    __endasm;

    /* Read keystroke from PIO (clears interrupt even if buffer full) */
    {
        byte key, new_head;
        key = _port_pio_a_data;
        new_head = (kbhead + 1) & KBMASK;
        if (new_head != kbtail) {
            kbbuf[kbhead] = key;
            kbhead = new_head;
        }
    }

    __asm
        pop hl
        pop de
        pop bc
        pop af
        ld sp, (_sp_sav)
        ei
        reti
    __endasm;
#endif
}

void isr_floppy(void) __naked
{
#ifndef HOST_TEST
    __asm
        ld (_sp_sav), sp
        ld sp, #0xF620
        push af
        push bc
        push de
        push hl
    __endasm;

    /* Floppy completion: set flag, read FDC result or sense interrupt */
    {
        byte delay;
        fl_flg = 0xFF;
        for (delay = 5; delay; delay--)
            ;
        if (_port_fdc_status & 0x10)
            fdc_result();
        else
            fdc_sense_int();
    }

    __asm
        pop hl
        pop de
        pop bc
        pop af
        ld sp, (_sp_sav)
        ei
        reti
    __endasm;
#endif
}

/* HD ISR stub */
void isr_hd(void) __interrupt {}

/* SIO ISR stubs */
void isr_sio_b_tx(void) __interrupt {}
void isr_sio_b_ext(void) __interrupt {}
void isr_sio_b_spec(void) __interrupt {}
void isr_sio_a_tx(void) __interrupt {}
void isr_sio_a_ext(void) __interrupt {}
void isr_sio_a_rx(void) __interrupt {}
void isr_sio_a_spec(void) __interrupt {}

/* PIO ch.B (parallel output) ISR — not used on RC702 */
void isr_pio_par(void) __interrupt {}
