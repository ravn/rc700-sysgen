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
 * BGSTAR (background bitmap) at 0xF500: 250-byte position bitmap
 * (1 bit per screen cell). Ctrl-S enters background mode; Ctrl-T
 * returns to foreground; Ctrl-U clears only foreground characters.
 */

#include <string.h>
#include "hal.h"
#include "bios.h"
#include "builddate.h"

/* Forward declarations */
static void conout_body(void);
static void putch(byte c);
static void puts_p(const char *s);
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

/* Track offset table (2 floppy drives + 6 reserved for harddisk) */
word trkoff[] = { 2, 2, 0, 0, 0, 0, 0, 0 };

/* ================================================================
 * ISR shared state
 * ================================================================ */

static word sp_sav;           /* saved SP during ISR stack switch */

/* Keyboard ring buffer (REL30) */
static byte kbbuf[KBBUFSZ];
static volatile byte kbhead;   /* write index (ISR updates) */
static volatile byte kbtail;   /* read index (CONIN updates) */

/* SIO serial ring buffer (REL30)
 * 256-byte page-aligned buffer for SIO Ch.A receiver.
 * Page alignment lets the ISR use H=page, L=index for O(1) addressing.
 * RTS flow control: deassert at RXTHHI used, reassert at RXTHLO used. */
static byte rxbuf[RXBUFSZ];
static volatile byte rxhead;   /* write index (RCA ISR updates) */
static volatile byte rxtail;   /* read index (READER updates) */

/* SIO status flags (0xFF = ready/not busy, 0x00 = busy) */
static volatile byte prtflg = 0xFF;  /* printer (Ch.B TX) ready */
static volatile byte ptpflg = 0xFF;  /* punch (Ch.A TX) ready */

/* SIO status register snapshots */
static volatile byte rr0_a, rr1_a;  /* written by SIO ISRs, read by bios_linsel */
static volatile byte rr0_b, rr1_b;

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
        ; // wait for timer to count down (20ms per tick)
}

static void fdstar(void)
{
    if (!(_port_sw1 & 0x80))    /* maxi: no motor control */
        return;
    hal_di();
    if (timer2 == 0) {
        /* motor was stopped — start and wait for spinup */
        timer2 = (word)fdtimo_var;
        hal_ei();
        _port_sw1 = 0x01;
        waitd(50);              /* 50 * 20ms = 1 second */
    } else {
        timer2 = (word)fdtimo_var;
        hal_ei();
    }
}

/* FDC Main Status Register bits:
 *   7: RQM  — Request for Master (1 = ready for CPU access)
 *   6: DIO  — Data direction (0 = CPU→FDC write, 1 = FDC→CPU read)
 *   5: EXM  — Execution mode (1 = in execution phase)
 *   4: CB   — Controller Busy (1 = command in progress)
 *   3-0:    — Drive seek status (D3-D0 busy flags)
 */

/* Wait for FDC ready, then write command/parameter byte (RQM=1, DIO=0) */
static void fdc_write(byte val)
{
    while ((_port_fdc_status & 0xC0) != 0x80)  /* RQM+DIO mask */
        ;
    _port_fdc_data = val;
}

/* Wait for FDC result byte available (RQM=1, DIO=1), return data */
static byte fdc_read(void)
{
    while ((_port_fdc_status & 0xC0) != 0xC0)  /* RQM+DIO mask */
        ;
    return _port_fdc_data;
}

static void fdc_recalibrate(void)
{
    fdc_write(0x07);            /* RECALIBRATE */
    fdc_write(dskno & 3);      /* drive */
}

static void fdc_sense_int(void)
{
    fdc_write(0x08);            /* SENSE INTERRUPT STATUS */
    rstab[0] = fdc_read();
    if ((rstab[0] & 0xC0) != 0x80)
        rstab[1] = fdc_read();
}

static void fdc_seek(void)
{
    fdc_write(0x0F);            /* SEEK */
    fdc_write(dskno & 3);      /* drive + head */
    fdc_write(actra);          /* cylinder */
}

static void fdc_result(void)
{
    byte i;
    for (i = 0; i < 7; i++) {
        byte delay;
        rstab[i] = fdc_read();
        for (delay = 4; delay; delay--)
            ;
        if (!(_port_fdc_status & 0x10))  /* CB: more result bytes? */
            return;
    }
}

/* Interrupt flag */
static void clfit(void)
{
    hal_di();
    fl_flg = 0;
    hal_ei();
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
 * CHKTRK sets dskad = HSTBUF address before calling sec_rw.
 * write=1 means FDC reads from memory (FLPR), write=0 means FDC writes to memory (FLPW)
 */
static word dma_count;      /* parameter: byte count for DMA */
static byte  dma_write;      /* parameter: 0=read(FDC→mem), 1=write(mem→FDC) */

static void flp_dma_setup(void)
{
    hal_di();
    _port_dma_smsk = 0x05;          /* mask ch1 */
    _port_dma_mode = dma_write ? 0x49 : 0x45;
    _port_dma_clbp = 0;
    _port_dma_ch1_addr = (byte)dskad;
    _port_dma_ch1_addr = (byte)(dskad >> 8);
    _port_dma_ch1_wc = (byte)dma_count;
    _port_dma_ch1_wc = (byte)(dma_count >> 8);
    _port_dma_smsk = 0x01;          /* unmask ch1 */
    hal_ei();
}

/* General FDC command (9-byte read/write sequence)
 * fdfp points past DMA count bytes, at the MF field:
 *   fdfp[0]=MF, fdfp[1]=N, fdfp[2]=EOT, fdfp[3]=gap
 */
static void fdc_general_cmd(byte cmd, byte *fdfp)
{
    hal_di();
    fdc_write(cmd + fdfp[0]);       /* command + MF flag */
    fdc_write(dskno);              /* drive + head */
    fdc_write(actra);              /* cylinder */
    fdc_write((dskno >> 2) & 3);   /* head number */
    fdc_write(acsec);              /* sector */
    fdc_write(fdfp[1]);            /* N (sector size code) */
    fdc_write(fdfp[2]);            /* EOT (final sector) */
    fdc_write(fdfp[3]);            /* gap length */
    fdc_write(dtlv);               /* data length */
    hal_ei();
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

/* Forward declaration — definition placed after rdhst for fall-through */
static void sec_rw(byte cmd, byte dma_dir);

/* Write host buffer to disk */
static void wrthst(void)
{
    chktrk();
    sec_rw(5, 1);               /* WRITE DATA, mem→FDC */
}

/* Read host buffer from disk */
static void rdhst(void)
{
    if (unamsk)
        ;                   /* force pre-read if unamsk set */
    else
        unacnt = 0;
    chktrk();
    sec_rw(6, 0);               /* READ DATA, FDC→mem */
}

/* Placed after rdhst so the tail call falls through (saves 3 bytes).
 * Sector read/write with retry.
 * cmd: 6=READ DATA, 5=WRITE DATA.  dma_dir: 0=read(FDC→mem), 1=write(mem→FDC). */
static void sec_rw(byte cmd, byte dma_dir)
{
    static byte s_cmd, s_dma_dir;
    s_cmd = cmd;
    s_dma_dir = dma_dir;
    repet = 10;
    for (;;) {
        fdstar();
        clfit();

        dma_count = form->dma_count;

        dma_write = s_dma_dir;
        flp_dma_setup();
        fdc_general_cmd(s_cmd, (byte *)&form->mf);
        watir();

        if (!(rstab[0] & 0xF8))
            return;                     /* success */

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


/* Core blocking/deblocking algorithm (DRI standard) */
static byte rwoper(void)
{
    /* compute host sector: sekhst = seksec >> (secshf-1)
     * secshf=3 → 2 shifts (divide by 4, for 512B sectors).
     * secshf=1 → 0 shifts (128B sectors, no deblocking). */
    sekhst = seksec >> (byte)(secshf - 1);

    /* check if host buffer is active and matches */
    if (hstact) {
        if (sekdsk == hstdsk && hsttrk == sektrk && sekhst == hstsec)
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
    /* Inline hstbuf offset + dmaadr in each memcpy call rather than storing
     * in static src/dst variables.  sdcc stores statics to memory then
     * immediately reloads them — inlining lets the compiler keep values
     * in registers, saving 10 bytes despite the duplicated expression. */
    if (readop) {
        /* read: copy from host buffer to DMA area */
        memcpy((byte *)dmaadr, &hstbuf[(word)(seksec & secmsk) << 7], 128);
    } else {
        /* write: copy from DMA area to host buffer */
        hstwrt = 1;
        memcpy(&hstbuf[(word)(seksec & secmsk) << 7], (byte *)dmaadr, 128);
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

    /* SIO: program channels A and B from CONFI init blocks */
    __asm__("ld hl, #_psioa   \n"
            "ld b, #9         \n"
            "ld c, #0x0A      \n"
            "otir             \n"
            "ld hl, #_psiob   \n"
            "ld b, #11        \n"
            "ld c, #0x0B      \n"
            "otir             \n");

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
    while (_port_fdc_status & 0x1F)
        ;  /* wait for all drives not seeking and not busy */
    fdc_write(0x03);            /* SPECIFY command */
    fdc_write(0xDF);            /* step rate 3ms, head unload 240ms */
    fdc_write(0x28);            /* head load 40ms, DMA mode */

    /* Clear display buffer with spaces */
    memset(DISPLAY_ROW(0), ' ', sizeof(Display));

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
    __asm__("ld sp, #0xF500       \n"  /* use BIOS private stack */
            "jp _bios_boot_c      \n");
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


/* Arm SIO Channel A receiver: enable RTS, DTR, TX, and interrupts */
static void readi(void)
{
    hal_di();
    _port_sio_a_ctrl = 0x05;            /* select WR5 */
    _port_sio_a_ctrl = wr5a + 0x8A;     /* DTR=1, TX enable, RTS=1 */
    _port_sio_a_ctrl = 0x01;            /* select WR1 */
    _port_sio_a_ctrl = 0x1B;            /* enable RX, TX, ext status ints */
    hal_ei();
}

static void wboot_c(void);
static void jump_ccp(byte drive) __naked;

void bios_boot_c(void)
{
    /* Initialize character conversion tables to identity mapping.
     * The actual tables live on the disk image (written by CONFI.COM)
     * and are NOT carried in the BIOS binary.  Identity mapping is the
     * safe default — all characters pass through unchanged. */
    {
        byte i;
        for (i = 0; i < 128; i++)
            outcon[i] = i;
        i = 0;
        do {
            inconv[i] = i;
        } while (++i != 0);
    }

    /* Cold boot: print signon, init state, then warm boot */
    puts_p("\x0C"                       /* form feed = clear screen */
           "RC700 56k CP/M 2.2 bios " BUILDDATE "\r\n");

    cdisk = 0;
    hstact = 0;
    erflag = 0;
    hstwrt = 0;
    kbhead = 0;
    kbtail = 0;
    rxhead = 0;
    rxtail = 0;
    readi();

    wboot_c();
}

static void wboot_c(void)
{
    byte sec;

    hal_ei();
    bios_seldsk_c(0);

    unacnt = 0;
    iobyte = 0;
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
    wboot_jp  = 0xC3;                        /* JP opcode */
    bdos_jp   = 0xC3;                        /* JP opcode, here for the peep hole optimizer */
    wboot_vec = BIOS_BASE + 3;              /* WBOOT entry */
    bdos_vec  = BDOS_BASE;

    /* Re-select drive to ensure clean state for CCP */
    bios_seldsk_c(0);

    /* Jump to CCP with current disk in register C */
    jump_ccp(cdisk & 0x0F);
#endif
}

/* Jump to CCP entry point — does not return.
 * drive (in A via sdcccall(1)) is moved to C for CP/M convention. */
static void jump_ccp(byte drive) __naked
{
    (void)drive;
    __asm__("ld c, a               \n"
            "jp 0xC400             \n"); /* CCP_BASE */
}

void bios_wboot(void) __naked
{
    __asm__("ld sp, #0xF500       \n"  /* use BIOS private stack */
            "jp _wboot_c          \n");
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
    return inconv[raw];
}

/* ================================================================
 * Display driver — CONOUT with escape sequences
 *
 * Implements the RC702 display protocol: control characters 0x00-0x1F
 * dispatch via jump table, ESC = X Y for cursor addressing, printable
 * characters go through OUTCON conversion table to display memory.
 *
 * BGSTAR: 250-byte bitmap, one bit per screen cell (80×25/8).
 * Ctrl-S (0x13) enters background mode, marking each written position.
 * Ctrl-T (0x14) returns to foreground mode.
 * Ctrl-U (0x15) clears foreground: erases only positions NOT marked.
 * Fixed at 0xF500 (same as original BIOS). ISR stack at 0xF620 has 38 bytes
 * above BGSTAR end (0xF5FA) — sufficient for 4 PUSHes + C body calls.
 * ================================================================ */

#define BGSTAR_SIZE 250         /* 80*25/8 = 250 bytes */
#define BG_ROW_BYTES 10         /* 80 bits / 8 = 10 bytes per row */

#define bgstar      ((byte *)0xF500)
static byte bgflg;             /* 0=off, 1=foreground, 2=background */
static byte graph;           /* graphical mode flag (sticky) */

/* Forward declarations — definitions placed for tail-call fall-through */
static void cursor_right(void);
static void cursorxy(void);

/* Reset cursor to top-left (does NOT update 8275) */
static void goto00(void);

/* Start XY addressing: set xflg and reset cursor.
 * Placed immediately before goto00 so the tail call falls through. */
static void start_xy(void)
{
    xflg = 2;
    goto00();
}

/* Placed after start_xy so the tail call falls through (saves 3 bytes) */
static void goto00(void)
{
    cury = 0;
    curx = 0;
    cursy = 0;
}

/* Forward declaration — definition placed after cursor_down for fall-through */
static void rowdn(void);

/* Move cursor up one row */
static void rowup(void)
{
    cury -= SCRN_COLS;
    cursy--;
    cursorxy();
}

/* Set a bit in BGSTAR for screen position `pos` (0-1999) */
static void bg_set_bit(word pos)
{
    static byte byteoff;
    byteoff = (byte)(pos >> 3);
    bgstar[byteoff] |= (byte)0x80 >> (byte)(pos & 7);
}

/* ======================================================================
 * SCROLL — performance-critical, hand-optimized in assembly.
 *
 * Scroll display up one line: copy ROW1..ROW24 → ROW0..ROW23, fill ROW24.
 *
 * OPTIMIZATION: Unrolled 16×LDI loop (16T/byte vs LDIR's 21T/byte).
 * Same technique as the REL30 assembly BIOS (see rcbios/src/DISPLAY.MAC).
 * 1920 bytes / 16 = 120 exact iterations, no remainder.
 *
 * Saves ~9,600 T-states per scroll call.  During TYPE FILEX.PRN (~1000
 * scrolls) this recovers ~10M cycles ≈ 5% of total execution time,
 * closing the gap between the C BIOS and the original assembly BIOS.
 *
 * The ROW24 fill uses the LDIR fill trick (write first byte, LDIR the
 * rest) instead of a DJNZ byte loop — saves another ~630T per scroll.
 * ====================================================================== */
static void scroll(void)
{
    /* --- display memory: inline asm for speed --- */
    __asm
    ;; === UNROLLED 16×LDI SCROLL (16T/byte vs 21T/byte LDIR) ===
    ;; Copy 1920 bytes: ROW1..ROW24 → ROW0..ROW23
    ld  hl, #0xF850         ; source = DSPSTR + 80
    ld  de, #0xF800         ; dest   = DSPSTR
    ld  bc, #0x0780         ; count  = 1920 (120 × 16)
scroll_ldi:
    ldi                     ; 16 × LDI = 16T each (vs 21T for LDIR)
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    ldi
    jp  PE, scroll_ldi      ; P/V set while BC > 0

    ;; === LDIR FILL TRICK for ROW24 (spaces) ===
    ;; Write first byte, then LDIR copies it forward 79 times
    ld  hl, #0xFF80         ; ROW24 = DSPSTR + 1920
    ld  (hl), #0x20         ; first byte = space
    ld  d, h
    ld  e, l
    inc de
    ld  bc, #79             ; remaining 79 bytes
    ldir
    __endasm;

    /* --- bgstar overlay: C code (not performance-critical) --- */
    if (bgflg) {
        memcpy(bgstar, bgstar + BG_ROW_BYTES, BGSTAR_SIZE - BG_ROW_BYTES);
        memset(bgstar + BGSTAR_SIZE - BG_ROW_BYTES, 0, BG_ROW_BYTES);
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
            cury = ROW24_OFFSET;
            cursy = ROW24;
            cursorxy();
        }
    }
}

/* Cursor down — scroll if on last row */
static void cursor_down(void)
{
    if (cury != ROW24_OFFSET)
        rowdn();
    else
        scroll();
}

/* Placed after cursor_down so the tail call falls through */
static void rowdn(void)
{
    cury += SCRN_COLS;
    cursy++;
    cursorxy();
}

/* Cursor up — wrap to bottom if on first row */
static void cursor_up(void)
{
    if (cury != ROW0_OFF) {
        rowup();
    } else {
        cury = ROW24_OFFSET;
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

/* Placed after carriage_return() so the tail call falls through (saves 3 bytes).
 * CR is the hottest path — every output line ends with CR+LF. */
static void cursorxy(void)
{
    _port_crt_cmd = 0x80;       /* load cursor position command */
    _port_crt_param = curx;     /* X position */
    _port_crt_param = cursy;    /* Y position */
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
    if (bgflg) {
        bgflg = 0;
        memset(bgstar, 0, BGSTAR_SIZE);
    }
}

/* Forward declaration — definition placed after erase_to_eos for fall-through */
static word bgcl_pos, bgcl_count;
static void bg_clear_from(void);

/* Erase from cursor to end of line */
static void erase_to_eol(void)
{
    byte *row = screen + cury;
    for (byte i = curx; i < SCRN_COLS; i++)
        row[i] = ' ';
    if (bgflg) {
        bgcl_pos = cury + curx;
        bgcl_count = SCRN_COLS - curx;
        bg_clear_from();
    }
}

/* Erase from cursor to end of screen */
static void erase_to_eos(void)
{
    static word pos;
    static word count;
    pos = cury + curx;
    count = SCRN_SIZE - pos;
    memset(screen + pos, ' ', count);
    if (bgflg) {
        bgcl_pos = pos;
        bgcl_count = SCRN_SIZE - pos;
        bg_clear_from();
    }
}

/* Placed after erase_to_eos so the tail call falls through (saves 3 bytes).
 * Clear BGSTAR bits from position `pos` for `count` bits.
 * Parameters passed via static variables to avoid IX frame pointer. */
static void bg_clear_from(void)
{
    static byte byteoff, bitno, whole, tail;
    if (!bgflg)
        return;
    byteoff = (byte)(bgcl_pos >> 3);
    bitno = (byte)(bgcl_pos & 7);
    /* Clear remaining bits in the first byte */
    if (bitno) {
        bgstar[byteoff] &= ~((byte)0xFF >> bitno);
        byteoff++;
        bgcl_count = (bgcl_count > (byte)(8 - bitno)) ? bgcl_count - (8 - bitno) : 0;
    }
    /* Clear whole bytes */
    whole = (byte)(bgcl_count >> 3);
    if (whole) {
        memset(bgstar + byteoff, 0, whole);
        byteoff += whole;
    }
    /* Clear leading bits of last byte */
    tail = (byte)(bgcl_count & 7);
    if (tail) {
        bgstar[byteoff] &= ~((byte)0xFF << (byte)(8 - tail));
    }
}

/* Delete line — shift lines up from cury+1 to ROW24, fill ROW24 */
static void delete_line(void)
{
    /* Inline expressions rather than static temps — avoids store/reload overhead */
    if (cury != ROW24_OFFSET)
        memcpy(screen + cury, screen + cury + SCRN_COLS, ROW24_OFFSET - cury);
    memset(DISPLAY_ROW(ROW24), ' ', SCRN_COLS);
    if (bgflg) {
        static byte dl_off, dl_bgcount;
        dl_off = (byte)(cury >> 3);  /* cury is row*80, /8 = row*10 */
        dl_bgcount = BGSTAR_SIZE - BG_ROW_BYTES - dl_off;
        if (dl_bgcount)
            memcpy(bgstar + dl_off, bgstar + dl_off + BG_ROW_BYTES, dl_bgcount);
        memset(bgstar + BGSTAR_SIZE - BG_ROW_BYTES, 0, BG_ROW_BYTES);
    }
}

/* Insert line — shift lines down from cury to ROW23, fill current line.
 * Backward copy (dst > src, overlapping) — memmove library hangs,
 * so use an explicit backward loop. */
static void insert_line(void)
{
    static word count;
    static byte *src;
    static byte *dst;

    count = ROW24_OFFSET - cury;
    if (count != 0) {
        /* Constant start addresses — sdcc loads them directly */
        src = screen + ROW24_OFFSET - 1;           /* last byte of ROW23 */
        dst = screen + ROW24_OFFSET + SCRN_COLS - 1; /* last byte of ROW24 */
        while (count--)
            *dst-- = *src--;
    }
    memset(screen + cury, ' ', SCRN_COLS);
    if (bgflg) {
        static byte il_off, il_bgcount, il_i;
        il_off = (byte)(cury >> 3);
        il_bgcount = BGSTAR_SIZE - BG_ROW_BYTES - il_off;
        if (il_bgcount) {
            /* Backward copy for overlapping shift-down (memmove hangs) */
            src = bgstar + BGSTAR_SIZE - BG_ROW_BYTES - 1;
            dst = bgstar + BGSTAR_SIZE - 1;
            for (il_i = 0; il_i < il_bgcount; il_i++)
                *dst-- = *src--;
        }
        memset(bgstar + il_off, 0, BG_ROW_BYTES);
    }
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

    /* 8275 CRT character encoding:
     * 192-255: fold to 0-63 (character ROM uses 7 address bits)
     * 128-191: semigraphics control — bit 2 sets/clears sticky graph mode
     * 0-127:   normal chars, through OUTCON unless graph mode is active */
    if (ch >= 192)
        ch -= 192;

    if (ch >= 128) {
        graph = ch & 4;         /* set/clear semigraphics mode (sticky) */
    } else if (!graph) {
        ch = outcon[ch];  /* national character conversion (CONFI.COM) */
    }

    screen[locad] = ch;
    if (bgflg == 2)
        bg_set_bit(locad);
    cursor_right();
}

/* Cursor right — advance column, wrap to next line or scroll.
 * Placed immediately after displ() so the tail call can fall through. */
static void cursor_right(void)
{
    if (curx < COLUMN79) {
        curx++;
        cursorxy();
    } else {
        curx = COLUMN0;
        if (cury != ROW24_OFFSET) {
            rowdn();
        } else {
            cursorxy();
            scroll();
        }
    }
}

/* Clear foreground: erase screen positions where BGSTAR bit is NOT set */
static void clear_foreground(void)
{
    static byte i;
    static byte *p;
    static byte bits, mask;
    p = screen;
    for (i = 0; i < BGSTAR_SIZE; i++) {
        bits = bgstar[i];
        mask = 0x80;
        while (mask) {
            if (!(bits & mask))
                *p = ' ';
            p++;
            mask >>= 1;
        }
    }
}

/* Control character dispatch (0x00-0x1F).
 * Uses if/return chains so sdcc generates cp a,N (preserving A) with
 * tail-call jp for each handler.  Ordered by frequency: CR and LF
 * first, then common cursor/editing, then rare screen ops and BGSTAR. */
static void specc(void)
{
    xflg = 0;
    /* Most frequent: every line of output */
    if (usession == 0x0D) { carriage_return(); return; }
    if (usession == 0x0A) { cursor_down(); return; }
    if (usession == 0x06) { start_xy(); return; }  /* XY addressing */
    /* Common: cursor movement, editing */
    if (usession == 0x08) { cursor_left(); return; }
    if (usession == 0x05) { cursor_left(); return; }  /* ENQ = BS */
    if (usession == 0x09) { tab(); return; }
    if (usession == 0x18) { cursor_right(); return; }
    if (usession == 0x1A) { cursor_up(); return; }
    /* Less common: screen operations */
    if (usession == 0x0C) { clear_screen(); return; }
    if (usession == 0x1D) { home(); return; }
    if (usession == 0x1E) { erase_to_eol(); return; }
    if (usession == 0x1F) { erase_to_eos(); return; }
    if (usession == 0x01) { insert_line(); return; }
    if (usession == 0x02) { delete_line(); return; }
    if (usession == 0x07) { _port_bell = 0; return; }
    /* Rare: semi-graphics */
    if (usession == 0x13) { bgflg = 2; memset(bgstar, 0, BGSTAR_SIZE); return; }
    if (usession == 0x14) { bgflg = 1; return; }
    if (usession == 0x15) { clear_foreground(); return; }
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
    __asm__("di                    \n"
            "push hl               \n"
            "ld hl, #0             \n"
            "add hl, sp            \n"  /* HL = caller SP */
            "ld sp, #0xF500        \n"  /* switch to BIOS stack */
            "ei                    \n"
            "push hl               \n"  /* save caller SP */
            "push af               \n"
            "push bc               \n"
            "push de               \n"
            "ld a, c               \n"  /* char from C register */
            "ld (0xFFDA), a        \n"  /* usession */
            "call _conout_body     \n"
            "pop de                \n"
            "pop bc                \n"
            "pop af                \n"
            "pop hl                \n"  /* caller SP */
            "di                    \n"
            "ld sp, hl             \n"  /* restore caller stack */
            "pop hl                \n"
            "ei                    \n"
            "ret                   \n");
}

/* LIST: transmit character on SIO Channel B (printer) */
void bios_list(byte c)
{
    while (!prtflg)
        ;                       /* wait for TX ready */
    hal_di();
    prtflg = 0;                 /* mark busy */
    _port_sio_b_ctrl = 0x05;    /* select WR5 */
    _port_sio_b_ctrl = wr5b + 0x8A;  /* DTR=1, TX enable, RTS=1 */
    _port_sio_b_ctrl = 0x01;    /* select WR1 */
    _port_sio_b_ctrl = 0x07;    /* TX int, ext status, status affects vector */
    _port_sio_b_data = c;
    hal_ei();
}

/* PUNCH: transmit character on SIO Channel A */
void bios_punch(byte c)
{
    while (!ptpflg)
        ;                       /* wait for TX ready */
    hal_di();
    ptpflg = 0;                 /* mark busy */
    _port_sio_a_ctrl = 0x05;    /* select WR5 */
    _port_sio_a_ctrl = wr5a + 0x8A;  /* DTR=1, TX enable, RTS=1 */
    _port_sio_a_ctrl = 0x01;    /* select WR1 */
    _port_sio_a_ctrl = 0x1B;    /* RX, TX, ext status ints */
    _port_sio_a_data = c;
    hal_ei();
}

/* READER: read character from SIO Channel A ring buffer with RTS flow control */
byte bios_reader(void)
{
    byte ch, new_tail, used;

    /* wait for data in ring buffer */
    while (rxtail == rxhead)
        ;

    /* read character and advance tail */
    new_tail = (rxtail + 1) & RXMASK;
    ch = rxbuf[rxtail];
    rxtail = new_tail;

    /* reassert RTS if buffer has drained below low watermark */
    used = (rxhead - new_tail) & RXMASK;
    if (used < RXTHLO) {
        _port_sio_a_ctrl = 0x05;        /* select WR5 */
        _port_sio_a_ctrl = wr5a + 0x8A; /* DTR=1, TX enable, RTS=1 */
    }

    return ch;
}

void bios_home(void) __naked
{
    /* CP/M calls HOME before SELDSK — flush pending writes, recalibrate */
    __asm__("di                    \n"
            "push hl               \n"
            "ld hl, #0             \n"
            "add hl, sp            \n"
            "ld sp, #0xF500        \n"
            "ei                    \n"
            "push hl               \n"
            "call _bios_home_c     \n"
            "pop hl                \n"
            "di                    \n"
            "ld sp, hl             \n"
            "pop hl                \n"
            "ei                    \n"
            "ret                   \n");
}

static void bios_home_c(void)
{
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
    __asm__("di                    \n"
            "push bc               \n"
            "ld hl, #0             \n"
            "add hl, sp            \n"
            "ld sp, #0xF500        \n"  /* switch to BIOS stack */
            "ei                    \n"
            "push hl               \n"  /* save caller SP */
            "ld a, c               \n"  /* drive number → A */
            "call _bios_seldsk_c   \n"  /* returns DPH in DE */
            "ex de, hl             \n"  /* HL = DPH (for CP/M) */
            "pop de                \n"  /* DE = saved caller SP */
            "di                    \n"
            "ex de, hl             \n"  /* DPH in DE, SP in HL */
            "ld sp, hl             \n"  /* restore caller stack */
            "ex de, hl             \n"  /* HL = DPH for CP/M */
            "pop bc                \n"
            "ei                    \n"
            "ret                   \n");
}

static word bios_seldsk_c(byte drv)
{
    static byte drive;
    static byte fmt;

    drive = drv;
    if (drive > drno)
        return 0;               /* invalid drive */

    sekdsk = drive;

    /* look up format from fd0 table */
    fmt = fd0[drive];

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
        static byte idx;
        static const FSPA *sp;
        idx = (fmt >> 3) & 3;
        sp = &fspa[idx];

        form = &fdf[idx];
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

    /* update DPB pointer in DPH (offset 10 = word 5) and return it */
    {
        static word *dph;
        dph = (word *)((byte *)dpbase + (word)drive * 16);
        dph[5] = dpblck;
        return (word)dph;
    }
}

void bios_settrk(word track) __naked
{
    (void)track;
    __asm__("ld (_sektrk), bc       \n"  /* CP/M passes track in BC */
            "ret                     \n");
}

void bios_setsec(word sector) __naked
{
    (void)sector;
    __asm__("ld (_seksec), bc       \n"  /* CP/M passes sector in BC */
            "ret                     \n");
}

void bios_setdma(word addr) __naked
{
    (void)addr;
    __asm__("ld (_dmaadr), bc       \n"  /* CP/M passes DMA address in BC */
            "ret                     \n");
}

static byte xread(void)
{
    unacnt = 0;
    readop = 1;
    rsflag = 1;
    wrtype = WRUAL;
    return rwoper();
}

static byte xwrite(byte wt)
{
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
    __asm__("di                    \n"
            "push bc               \n"
            "push de               \n"
            "push hl               \n"
            "ld hl, #0             \n"
            "add hl, sp            \n"
            "ld sp, #0xF500        \n"
            "ei                    \n"
            "push hl               \n"
            "call _xread           \n"
            "pop de                \n"
            "di                    \n"
            "ex de, hl             \n"
            "ld sp, hl             \n"
            "ex de, hl             \n"
            "pop hl                \n"
            "pop de                \n"
            "pop bc                \n"
            "ei                    \n"
            "ret                   \n");  /* A = return value */
}

byte bios_write(byte type) __naked
{
    (void)type;
    __asm__("di                    \n"
            "push bc               \n"
            "push de               \n"
            "push hl               \n"
            "ld hl, #0             \n"
            "add hl, sp            \n"
            "ld sp, #0xF500        \n"
            "ei                    \n"
            "push hl               \n"
            "ld a, c               \n"  /* write type from C register */
            "call _xwrite          \n"
            "pop de                \n"
            "di                    \n"
            "ex de, hl             \n"
            "ld sp, hl             \n"
            "ex de, hl             \n"
            "pop hl                \n"
            "pop de                \n"
            "pop bc                \n"
            "ei                    \n"
            "ret                   \n");  /* A = return value */
}

byte bios_listst(void)
{
    return prtflg;
}

word bios_sectran(word sector) __naked
{
    (void)sector;
    __asm__("ld h, b                \n"  /* return BC in HL (no translation) */
            "ld l, c                \n"
            "ret                    \n");
}

/* ================================================================
 * Extended BIOS entries (DA4A+)
 *
 * RC700-specific extensions beyond the standard CP/M 2.2 BIOS.
 * Documented in CP/M User's Guide section 4.4 "Extended BIOS Functions".
 * These use register-based calling conventions that differ from
 * sdcccall(1), so most need __naked wrappers with inline asm.
 *
 *   DA4A  JP WFITR    Wait for FDC interrupt, return result
 *   DA4D  JP READS    Reader status (0xFF=data, 0=empty)
 *   DA50  JP LINSEL   RC791 line selector control
 *   DA53  JP EXIT     Register application timeout callback
 *   DA56  JP CLOCK    Read/set 32-bit real-time clock
 *   DA59  JP HRDFMT   Format hard disk track (stub)
 * ================================================================ */

/* WFITR (DA4A): PROCEDURE WAIT_CLEAR_FD_INTERRUPT
 * Waits for FDC interrupt flag, then returns result status.
 * Returns: B=ST0 (rstab[0]), C=ST1 (rstab[1]).
 * Used by FORMAT.COM (RC700 FORMAT UTILITY VERS 1.2). */
void bios_wfitr(void) __naked
{
    wfitr();
    __asm__("ld a, (_rstab)         \n"
            "ld b, a                \n"
            "ld a, (_rstab + 1)     \n"
            "ld c, a                \n"
            "ret                    \n");
}

/* READS (DA4D): Reader status.
 * Returns: A=0xFF if character available in RX ring buffer,
 *          A=0x00 if buffer empty. */
byte bios_reads(void)
{
    return (rxtail != rxhead) ? 0xFF : 0x00;
}

/* LINSEL (DA50): PROCEDURE LINE_SELECT
 * Controls the RC791 Line Selector (Linieselektor), a V.24 multiplexer
 * that routes 8 V.24 inputs to 2 outputs.
 *
 * Input:  A = port (0=terminal SIO-A, 1=printer SIO-B)
 *         B = line (0=release, 1=select line A, 2=select line B)
 *         C = irrelevant
 * Returns: A = 0xFF if selection OK (CTS active)
 *          A = 0x00 if line busy (CTS not active, line released)
 *
 * Protocol (from original source):
 *   1. Wait for all-sent (RR1 bit 0)
 *   2. Delay between line release and new select
 *   3. DTR:=FALSE; RTS:=FALSE
 *   4. IF B<>0 THEN
 *        DTR:=FALSE; RTS:=(B=2)    (* wait at least 100 ns *)
 *        DTR:=TRUE                 (* wait 1-2 timer periods *)
 *        IF CTS THEN A:=0FFH
 *        ELSE A:=0; DTR:=FALSE; RTS:=FALSE
 *
 * The original asm uses OUT (C),r with a variable port in the C register.
 * This C version uses two code paths (SIO-A / SIO-B) with fixed ports. */

/* SIO WR5 access via fixed ports (two code paths for A/B) */
static byte ls_port;    /* 0=SIO-A, 1=SIO-B */

static void sio_wr5(byte val)
{
    if (ls_port) {
        _port_sio_b_ctrl = 5;
        _port_sio_b_ctrl = val;
    } else {
        _port_sio_a_ctrl = 5;
        _port_sio_a_ctrl = val;
    }
}

static byte sio_rd1(void)
{
    if (ls_port) {
        _port_sio_b_ctrl = 1;
        return _port_sio_b_ctrl;
    }
    _port_sio_a_ctrl = 1;
    return _port_sio_a_ctrl;
}

static byte ls_line;

void bios_linsel(void) __naked
{
    __asm__("ld (_ls_port), a       \n"  /* A=port (0=SIO-A, 1=SIO-B) */
            "ld a, b                \n"
            "ld (_ls_line), a       \n");  /* B=line (0-2) */

    /* Wait for all-sent (RR1 bit 0) */
    while (!(sio_rd1() & 0x01))
        ;

    waitd(2);

    /* Release: DTR=0, RTS=0 */
    hal_di();
    sio_wr5(0x00);
    hal_ei();

    if (ls_line == 0) {
        __asm__("xor a                \n"
                "ret                  \n");
    }

    /* Select line: line=1→DTR only, line=2→DTR+RTS */
    {
        static byte wr5val;
        wr5val = (byte)(ls_line << 1);      /* RTS bit position */
        hal_di();
        sio_wr5(wr5val);
        hal_ei();
        wr5val |= 0x80;                     /* add DTR */
        hal_di();
        sio_wr5(wr5val);
        hal_ei();
    }

    waitd(2);

    /* Check CTS (RR0 bit 5) — cached by ISR */
    if ((ls_port ? rr0_b : rr0_a) & 0x20) {
        __asm__("ld a, #0xFF           \n"
                "ret                  \n");
    }

    /* No CTS — release line */
    hal_di();
    sio_wr5(0x00);
    hal_ei();
    __asm__("xor a                  \n"
            "ret                    \n");
}

/* EXIT (DA53): PROCEDURE DEF_EXIT_ROUTINE
 * Registers an application timeout callback.
 * Input: HL = callback routine address
 *        DE = countdown in 20ms ticks
 * The CRT ISR decrements the counter every 20ms; when it reaches zero,
 * the callback at HL is invoked with interrupts disabled.
 * The callback must NOT enable interrupts and must return via RET. */
void bios_exit(void) __naked
{
    __asm__("ld (0xFFE5), hl        \n"  /* warmjp = callback address */
            "ex de, hl              \n"
            "ld (0xFFDF), hl        \n"  /* timer1 = countdown */
            "ret                    \n");
}

/* CLOCK (DA56): PROCEDURE CLOCK
 * Reads or sets the 32-bit real-time clock (incremented every 20ms
 * by the CRT ISR, stored at 0xFFFC-0xFFFF).
 * Input:  A=0  → SET clock from DE (low word) and HL (high word)
 *         A≠0  → GET clock
 * Returns (GET): DE = clock bits 0-15, HL = clock bits 16-31 */
void bios_clock(void) __naked
{
    __asm__("or a                   \n"
            "jr z, _clock_set       \n"
            "di                     \n"  /* read clock */
            "ld de, (0xFFFC)        \n"  /* rtc0 */
            "ld hl, (0xFFFE)        \n"  /* rtc2 */
            "ei                     \n"
            "ret                    \n"
            "_clock_set:            \n"
            "ld (0xFFFC), de        \n"  /* set clock */
            "ld (0xFFFE), hl        \n"
            "ret                    \n");
}

/* HRDFMT (DA59): Format hard disk track (WD1000 controller).
 * Input: A=size/drive/head, B=write precomp, C=sector count,
 *        DE=cylinder, DMAADR→format spec data.
 * Returns: A=0 success, A=1 error.
 * TODO(harddisk): Postponed until BIOS fits on mini (5.25") disk. */
void bios_hrdfmt(void) { }

/* ================================================================
 * Interrupt service routines
 *
 * CRITICAL: __interrupt(N) must ALWAYS include the (N) number.
 * Without it, __critical __interrupt generates RETN instead of
 * EI+RETI, leaving interrupts permanently disabled — fatal on
 * the RC702 where all I/O is interrupt-driven.
 *
 * The RC702 requires interrupts disabled in ALL interrupt handlers.
 * Nested interrupts are never safe on this hardware.
 *
 * The (N) numbers match the IVT index in crt0.asm (_itrtab):
 *   0-1  CTC1 ch0-1: isr_dummy          (__interrupt, baud rate)
 *   2    CTC1 ch2: isr_crt            (__naked)
 *   3    CTC1 ch3: isr_floppy         (__naked)
 *   4    CTC2 ch0: isr_hd             (__interrupt)
 *   5-7  CTC2 ch1-3: isr_dummy          (__interrupt, unused)
 *   8    SIO ch.B TX: isr_sio_b_tx    (__critical __interrupt)
 *   9    SIO ch.B ext: isr_sio_b_ext  (__critical __interrupt)
 *  10    SIO ch.B RX: isr_dummy          (__interrupt, RX disabled)
 *  11    SIO ch.B spec: isr_sio_b_spec(__critical __interrupt)
 *  12    SIO ch.A TX: isr_sio_a_tx    (__critical __interrupt)
 *  13    SIO ch.A ext: isr_sio_a_ext  (__critical __interrupt)
 *  14    SIO ch.A RX: isr_sio_a_rx    (__naked)
 *  15    SIO ch.A spec: isr_sio_a_spec(__critical __interrupt)
 *  16    PIO ch.A: isr_pio_kbd        (__naked)
 *  17    PIO ch.B: isr_pio_par        (__interrupt)
 *
 * ISRs needing stack switch use __naked wrappers with explicit
 * register save/restore and EI only immediately before RETI.
 *
 * Simple ISRs (flag-set only, stubs) use __interrupt(N).
 * ================================================================ */

/* ISR stack switch helpers.
 * All ISRs switch SP to ISTACK (0xF620) to avoid overflowing the
 * interrupted program's stack.  Two variants:
 *   isr_enter / isr_exit: save/restore AF only (for simple flag-set
 *     ISRs whose C body only touches __sfr ports and static bytes)
 *   isr_enter_full / isr_exit_full: save/restore AF,BC,DE,HL (for
 *     ISRs with C body code that may clobber all registers) */

static inline void isr_enter(void) __naked
{
    __asm__("ld (_sp_sav), sp     \n"
            "ld sp, #0xF620       \n"
            "push af              \n");
}

static inline void isr_exit(void) __naked
{
    __asm__("pop af               \n"
            "ld sp, (_sp_sav)     \n"
            "ei                   \n"
            "reti                 \n");
}

static inline void isr_enter_full(void) __naked
{
    __asm__("ld (_sp_sav), sp     \n"
            "ld sp, #0xF620       \n"
            "push af              \n"
            "push bc              \n"
            "push de              \n"
            "push hl              \n");
}

static inline void isr_exit_full(void) __naked
{
    __asm__("pop hl               \n"
            "pop de               \n"
            "pop bc               \n"
            "pop af               \n"
            "ld sp, (_sp_sav)     \n"
            "ei                   \n"
            "reti                 \n");
}

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
    isr_enter_full();

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

    isr_exit_full();
#endif
}

void isr_pio_kbd(void) __naked
{
#ifndef HOST_TEST
    isr_enter_full();

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

    isr_exit_full();
#endif
}

void isr_floppy(void) __naked
{
#ifndef HOST_TEST
    isr_enter_full();

    /* Floppy completion: set flag, read FDC result or sense interrupt */
    {
        byte delay;
        fl_flg = 0xFF;
        for (delay = 5; delay; delay--)
            ;
        if (_port_fdc_status & 0x10)     /* CB: in result phase */
            fdc_result();
        else
            fdc_sense_int();
    }

    isr_exit_full();
#endif
}

/* Dummy ISR for unused IVT slots (EI + RETI) */
void isr_dummy(void) __interrupt(0) {}

/* HD ISR stub — TODO(harddisk): Postponed until BIOS fits on mini. */
void isr_hd(void) __interrupt(4) {}

/*
 * SIO Channel B ISRs (printer port)
 *
 * NOTE: The original asm BIOS switched SP to ISTACK (0xF620) in these
 * ISRs.  The `__critical __interrupt` form does NOT switch stacks — it
 * runs on whatever stack was active when the interrupt fired.  This is
 * safe because:
 *   - The bodies are trivial (port I/O + flag store), using only AF+HL
 *   - The compiler pushes 5 register pairs = 10 bytes of stack
 *   - CP/M guarantees at least 32 bytes of stack in the CCP/BDOS area
 *   - No nested interrupts (__critical keeps DI until EI before RETI)
 * If a future change makes any of these bodies non-trivial (calls,
 * large locals), they must revert to __naked with isr_enter/isr_exit.
 */

/* TXB: Ch.B transmit complete — reset TX int, mark printer ready */
void isr_sio_b_tx(void) __critical __interrupt(8)
{
    _port_sio_b_ctrl = 0x28;   /* reset TX interrupt pending */
    prtflg = 0xFF;              /* printer ready */
}

/* EXTSTB: Ch.B external status change — read and acknowledge */
void isr_sio_b_ext(void) __critical __interrupt(9)
{
    rr0_b = _port_sio_b_ctrl;  /* read RR0 */
    _port_sio_b_ctrl = 0x10;   /* reset ext/status interrupts */
}

/* SPECB: Ch.B special receive condition — read error, reset */
void isr_sio_b_spec(void) __critical __interrupt(11)
{
    _port_sio_b_ctrl = 0x01;   /* select RR1 */
    rr1_b = _port_sio_b_ctrl;  /* read RR1 */
    _port_sio_b_ctrl = 0x30;   /* error reset */
}

/*
 * SIO Channel A ISRs (reader/punch port)
 *
 * NOTE: Same stack-switch omission as Channel B above — trivial bodies
 * run safely on the interrupted code's stack.  isr_sio_a_rx is the
 * exception: it uses local variables and ring buffer logic, so it
 * keeps __naked with isr_enter_full/isr_exit_full for the stack switch.
 */

/* TXA: Ch.A transmit complete — reset TX int, mark punch ready */
void isr_sio_a_tx(void) __critical __interrupt(12)
{
    _port_sio_a_ctrl = 0x28;   /* reset TX interrupt pending */
    ptpflg = 0xFF;              /* punch ready */
}

/* EXTSTA: Ch.A external status change — read and acknowledge */
void isr_sio_a_ext(void) __critical __interrupt(13)
{
    rr0_a = _port_sio_a_ctrl;  /* read RR0 */
    _port_sio_a_ctrl = 0x10;   /* reset ext/status interrupts */
}

/* RCA: Ch.A receive — store in ring buffer with RTS flow control */
void isr_sio_a_rx(void) __naked
{
#ifndef HOST_TEST
    isr_enter_full();

    {
        byte ch, new_head, used;

        ch = _port_sio_a_data;       /* read char (clears interrupt) */
        new_head = (rxhead + 1) & RXMASK;

        if (new_head == rxtail)
            goto rts_off;            /* buffer full — deassert RTS */

        rxbuf[rxhead] = ch;
        rxhead = new_head;

        /* check if buffer is nearly full */
        used = (new_head - rxtail) & RXMASK;
        if (used < RXTHHI)
            goto done;               /* plenty of room */

    rts_off:
        /* deassert RTS to pause sender */
        _port_sio_a_ctrl = 0x05;         /* select WR5 */
        _port_sio_a_ctrl = wr5a + 0x88;  /* DTR=1, TX enable, RTS=0 */
    done: ;
    }

    isr_exit_full();
#endif
}

/* SPECA: Ch.A special receive condition — error reset, flush buffer */
void isr_sio_a_spec(void) __critical __interrupt(15)
{
    _port_sio_a_ctrl = 0x01;   /* select RR1 */
    rr1_a = _port_sio_a_ctrl;  /* read RR1 */
    _port_sio_a_ctrl = 0x30;   /* error reset */
    rxhead = 0;                 /* flush ring buffer */
    rxtail = 0;
}

/* PIO ch.B (parallel output) ISR — not used on RC702 */
void isr_pio_par(void) __interrupt(17) {}
