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

#include "hal.h"
#include "bios.h"
#include "builddate.h"

/* Forward declarations */
static void conout_body(void);
static void putch(uint8_t c);
static void puts_p(const char *s);
static void put_hex(uint16_t val);
static void put_dec(uint16_t val);
static uint16_t bios_seldsk_c(uint8_t drive);
static void bios_home_c(void);
static uint8_t xread(void);
static uint8_t xwrite(uint8_t wt);

/* ================================================================
 * ISR shared state
 * ================================================================ */

static uint16_t sp_sav;           /* saved SP during ISR stack switch */

/* Keyboard ring buffer (REL30) */
static uint8_t kbbuf[KBBUFSZ];
static volatile uint8_t kbhead;   /* write index (ISR updates) */
static volatile uint8_t kbtail;   /* read index (CONIN updates) */

/* ================================================================
 * Floppy disk driver — variables and buffers
 * ================================================================ */

/* Host sector buffer (512 bytes) and directory scratch (128 bytes) */
static uint8_t hstbuf[512];
static uint8_t dirbf[128];

/* Allocation and check vectors (2 drives) */
static uint8_t all0[71], chk0[32];
static uint8_t all1[71], chk1[32];

/* CP/M requested disk/track/sector (set by BDOS calls) */
static uint8_t  sekdsk;
static uint16_t sektrk;
static uint16_t seksec;

/* Host buffer state (what's cached in hstbuf) */
static uint8_t  hstdsk;
static uint16_t hsttrk;
static uint16_t hstsec;

/* Last seek position (skip redundant FDC seeks) */
static uint8_t  lstdsk;
static uint16_t lsttrk;

/* Intermediate: seksec >> secshf */
static uint16_t sekhst;

/* Buffer status */
static uint8_t  hstact;     /* 0=empty, 1=valid */
static uint8_t  hstwrt;     /* 0=clean, 1=dirty */

/* Unallocated sector tracking */
static uint8_t  unacnt;
static uint8_t  unadsk;
static uint16_t unatrk;
static uint16_t unasec;
static uint8_t  unamsk;

/* I/O operation control */
static uint8_t  erflag;
static uint8_t  rsflag;
static uint8_t  readop;
static uint8_t  wrtype;  /* renamed to avoid conflict with WRTYPE macro */

/* DMA and format state */
static uint16_t dmaadr;  /* CP/M DMA address */
static uint16_t form;    /* pointer to FDF block */
static uint8_t  cform;   /* current format index */
static uint8_t  eotv;        /* sectors per side on track 0 */
static uint8_t  drno;        /* highest drive number */

/* Physical disk control */
static uint8_t  dskno;       /* drive + head select bits */
static uint16_t dskad;       /* DMA address for FDC */
static uint8_t  actra;       /* actual track */
static uint8_t  acsec;       /* actual sector (1-based) */
static uint8_t  repet;       /* retry counter */
static volatile uint8_t rstab[8];    /* FDC result table */
static volatile uint8_t fl_flg;      /* floppy completion flag */

/* FSPA working copy (set by SELDSK) */
static uint16_t dpblck;      /* DPB pointer */
static uint8_t  cpmrbp;      /* records per block */
static uint16_t cpmspt;      /* CP/M sectors per track */
static uint8_t  secmsk;      /* sector mask */
static uint8_t  secshf;      /* sector shift count */
static uint16_t trantb;      /* translation table pointer */
static uint8_t  dtlv;        /* data length value */
static uint8_t  dsktyp;      /* 0=floppy, 0xFF=HD */

/* Disk Parameter Headers — 2 drives × 16 bytes (8 words) each
 * DPH layout: XLT(2), scratch(6), DIRBF(2), DPB(2), CHK(2), ALV(2)
 * Initialized at boot; DPB pointer updated by SELDSK.
 */
static uint16_t dpbase[2 * 8];

/* Motor control */
static void fdstop(void)
{
    if (!(_port_sw1 & 0x80))    /* maxi: no motor control */
        return;
    _port_sw1 = 0x00;
}

static void waitd(uint16_t ticks)
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
        timer2 = (uint16_t)fdtimo_var;
        __asm__("ei");
        _port_sw1 = 0x01;
        waitd(50);              /* 50 * 20ms = 1 second */
    } else {
        timer2 = (uint16_t)fdtimo_var;
        __asm__("ei");
    }
}

/* FDC low-level */
static void fdc_wait_write(void)
{
    while ((_port_fdc_status & 0xC0) != 0x80)
        ;
}

static void fdc_wait_read(void)
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
    uint8_t i;
    for (i = 0; i < 7; i++) {
        uint8_t delay;
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
static void flp_dma_setup(uint16_t count, uint8_t write)
{
    __asm__("di");
    _port_dma_smsk = 0x05;          /* mask ch1 */
    _port_dma_mode = write ? 0x49 : 0x45;
    _port_dma_clbp = 0;
    _port_dma_ch1_addr = (uint8_t)dskad;
    _port_dma_ch1_addr = (uint8_t)(dskad >> 8);
    _port_dma_ch1_wc = (uint8_t)count;
    _port_dma_ch1_wc = (uint8_t)(count >> 8);
    _port_dma_smsk = 0x01;          /* unmask ch1 */
    __asm__("ei");
}

/* General FDC command (9-byte read/write sequence)
 * fdfp points past DMA count bytes, at the MF field:
 *   fdfp[0]=MF, fdfp[1]=N, fdfp[2]=EOT, fdfp[3]=gap
 */
static void fdc_general_cmd(uint8_t cmd, uint8_t *fdfp)
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
    uint8_t sec, ev;
    uint8_t *tp;

    sec = (uint8_t)hstsec;
    ev = eotv;
    dskno = hstdsk;

    if (sec >= ev) {
        /* head 1 (track 0 side 1, or beyond EOTV) */
        dskno |= 4;
        sec -= ev;
    }

    /* sector translation */
    tp = (uint8_t *)trantb;
    acsec = tp[sec];
    actra = (uint8_t)hsttrk;
    dskad = (uint16_t)&hstbuf[0];

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
    uint8_t *fp;
    uint16_t dma_count;

    repet = 10;
    for (;;) {
        fdstar();
        clfit();

        /* form points to FDF start: [dma_count_lo, dma_count_hi, MF, N, EOT, gap] */
        fp = (uint8_t *)form;
        dma_count = fp[0] | ((uint16_t)fp[1] << 8);

        flp_dma_setup(dma_count, 0);    /* write to memory */
        fdc_general_cmd(6, fp + 2);     /* READ DATA, skip DMA count */
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
    uint8_t *fp;
    uint16_t dma_count;

    repet = 10;
    for (;;) {
        fdstar();
        clfit();

        fp = (uint8_t *)form;
        dma_count = fp[0] | ((uint16_t)fp[1] << 8);

        flp_dma_setup(dma_count, 1);    /* read from memory */
        fdc_general_cmd(5, fp + 2);     /* WRITE DATA, skip DMA count */
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

/* 16-bit track compare: *(uint16_t *)p == sektrk */
static uint8_t trkcmp(uint16_t *p)
{
    return *p == sektrk;
}

/* Core blocking/deblocking algorithm (DRI standard) */
static uint8_t rwoper(void)
{
    uint8_t shift, i;
    uint16_t hs;
    uint8_t *src, *dst;
    uint16_t offset;

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
    offset = (uint16_t)(seksec & secmsk) << 7;
    src = &hstbuf[offset];
    dst = (uint8_t *)dmaadr;

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
        uint8_t err = erflag;
        erflag = 0;
        return err;
    }
}

/* GFPA: get format parameter address from CFORM */
static uint8_t *gfpa(void)
{
    return (uint8_t *)&fdf1 + (cform & 0xF8);
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

    /* SIO: program via OTIR — use inline asm for the block output */
#ifndef HOST_TEST
    __asm
        ld hl, _psioa
        ld b, #9
        ld c, #0x0A
        otir
        ld hl, _psiob
        ld b, #11
        ld c, #0x0B
        otir
    __endasm;
#endif

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

    /* Clear display buffer (fill 0xF800-0xFFCF with spaces) */
#ifndef HOST_TEST
    __asm
        ld hl, #0xF800
        ld de, #0xF801
        ld bc, #0x07CF
        ld (hl), #0x20
        ldir
    __endasm;
#endif

    /* Clear work area (0xFFD1-0xFFFF with zeros) */
#ifndef HOST_TEST
    __asm
        ld hl, #0xFFD1
        ld de, #0xFFD2
        ld (hl), #0
        ld bc, #0x002E
        ldir
    __endasm;
#endif

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
        uint8_t d;

        /* Copy initial drive format from config block */
        *(&fd0 + 0) = infd0;       /* drive A format */
        *(&fd0 + 1) = 0xFF;        /* end of drive table */

        /* Count configured drives from fd0 table */
        drno = 0;
        for (d = 0; d < 16; d++) {
            if (*(&fd0 + d) == 0xFF)
                break;
            drno = d;
        }

        /* Initialize DPH entries for each drive */
        for (d = 0; d <= drno && d < 2; d++) {
            uint16_t *dph = &dpbase[d * 8];
            dph[0] = 0;                        /* XLT */
            dph[1] = 0;                        /* scratch */
            dph[2] = 0;
            dph[3] = 0;
            dph[4] = (uint16_t)dirbf;          /* DIRBF */
            dph[5] = (uint16_t)dpb8;           /* DPB (initial) */
            dph[6] = d == 0 ? (uint16_t)chk0 : (uint16_t)chk1;
            dph[7] = d == 0 ? (uint16_t)all0 : (uint16_t)all1;
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
        ld sp, #0xD480          ; use area below BIOS code as stack
        jp _bios_boot_c
    __endasm;
#endif
}

static void putch(uint8_t c)
{
    usession = c;
    conout_body();
}

static void puts_p(const char *s)
{
    while (*s)
        putch(*s++);
}

static void put_hex(uint16_t val)
{
    uint8_t i;
    char buf[5];
    for (i = 0; i < 4; i++) {
        uint8_t nib = (val >> 12) & 0xF;
        buf[i] = nib < 10 ? '0' + nib : 'A' + nib - 10;
        val <<= 4;
    }
    buf[4] = 0;
    puts_p(buf);
}

static void put_dec(uint16_t val)
{
    uint8_t d;
    if (val >= 10000) { d = 0; while (val >= 10000) { val -= 10000; d++; } putch('0' + d); }
    if (val >= 1000)  { d = 0; while (val >= 1000)  { val -= 1000;  d++; } putch('0' + d); }
    if (val >= 100)   { d = 0; while (val >= 100)   { val -= 100;   d++; } putch('0' + d); }
    if (val >= 10)    { d = 0; while (val >= 10)     { val -= 10;    d++; } putch('0' + d); }
    putch('0' + (uint8_t)val);
}

static void wboot_c(void);

void bios_boot_c(void)
{
    /* Cold boot: print signon, init state, then warm boot */
    puts_p("\x0C"                       /* form feed = clear screen */
           "RC700   56k CP/M 2.2 bios " BUILDDATE "\r\n");

    *(volatile uint8_t *)CDISK_ADDR = 0;
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
    uint8_t sec;

    hal_ei();
    bios_seldsk_c(0);

    unacnt = 0;
    *(volatile uint8_t *)IOBYTE_ADDR = 0;
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
                __asm__("halt");
        }
        dmaadr += 128;
    }

    dmaadr = BUFF;

    /* Set up JP vectors at page zero */
#ifndef HOST_TEST
    *(volatile uint8_t *)0x0000 = 0xC3;        /* JP opcode */
    *(volatile uint16_t *)0x0001 = BIOS_BASE + 3;  /* WBOOT entry */
    *(volatile uint8_t *)0x0005 = 0xC3;        /* JP opcode */
    *(volatile uint16_t *)0x0006 = BDOS_BASE;

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
        ld sp, #0xD480          ; reset stack (below BIOS code)
        jp _wboot_c
    __endasm;
#endif
}

/* ----------------------------------------------------------------
 * Console I/O — keyboard ring buffer (REL30)
 * ---------------------------------------------------------------- */

uint8_t bios_const(void) __naked
{
#ifndef HOST_TEST
    __asm
        ld a, (_kbtail)
        ld hl, #_kbhead
        sub a, (hl)
        ret z                   ; A=0 = no key (CP/M reads A)
        ld a, #0xFF             ; A=0xFF = key available
        ret
    __endasm;
#else
    return 0;
#endif
}

uint8_t bios_conin(void) __naked
{
#ifndef HOST_TEST
    __asm
    conin_wait$:
        ld a, (_kbtail)
        ld hl, #_kbhead
        sub a, (hl)
        jr z, conin_wait$       ; spin while empty

        ld hl, #_kbbuf
        ld a, (_kbtail)
        add a, l
        ld l, a                 ; HL = &kbbuf[tail]
        ld c, (hl)              ; read raw key

        ld a, (_kbtail)
        inc a
        and a, #0x0F            ; wrap at 16
        ld (_kbtail), a

        ld hl, #0xF700          ; INCONV table
        ld b, #0
        add hl, bc
        ld a, (hl)              ; return in A (CP/M reads A, not L)
        ret
    __endasm;
#else
    return 0;
#endif
}

/* ================================================================
 * Display driver — CONOUT with escape sequences
 *
 * Implements the RC702 display protocol: control characters 0x00-0x1F
 * dispatch via jump table, ESC = X Y for cursor addressing, printable
 * characters go through OUTCON conversion table to display memory.
 * BGSTAR (background bitmap) is intentionally omitted.
 * ================================================================ */

static uint8_t graph;           /* graphical mode flag (sticky) */

/* Update 8275 cursor position from curx/cursy */
static void wp75(void)
{
    _port_crt_cmd = 0x80;       /* load cursor position command */
    _port_crt_param = curx;     /* X position */
    _port_crt_param = cursy;    /* Y position */
}

/* Reset cursor to top-left (does NOT update 8275) */
static void es0h(void)
{
    cury = 0;
    curx = 0;
    cursy = 0;
}

/* Fill 80 bytes at addr with spaces */
static void fill_line(uint8_t *addr)
{
    for (uint8_t i = 0; i < 80; i++)
        addr[i] = ' ';
}

/* Move cursor down one row */
static void rowdn(void)
{
    cury += 80;
    cursy++;
    wp75();
}

/* Move cursor up one row */
static void rowup(void)
{
    cury -= 80;
    cursy--;
    wp75();
}

/* Scroll display up one line: copy 1920 bytes, fill last line */
static void scroll(void)
{
#ifndef HOST_TEST
    __asm
        ld hl, #0xF850          ; DSPSTR + 80
        ld de, #0xF800          ; DSPSTR
        ld bc, #1920
        ldir
    __endasm;
#endif
    fill_line((uint8_t *)(DSPSTR + 1920));
}

/* Cursor right — advance column, wrap to next line or scroll */
static void cursor_right(void)
{
    if (curx < 79) {
        curx++;
        wp75();
    } else {
        curx = 0;
        if (cury != 1920) {
            rowdn();
        } else {
            wp75();
            scroll();
        }
    }
}

/* Cursor left — wrap to previous line if at column 0 */
static void cursor_left(void)
{
    if (curx != 0) {
        curx--;
        wp75();
    } else {
        curx = 79;
        if (cury != 0) {
            rowup();
        } else {
            cury = 1920;
            cursy = 24;
            wp75();
        }
    }
}

/* Cursor down — scroll if on last row */
static void cursor_down(void)
{
    if (cury != 1920)
        rowdn();
    else
        scroll();
}

/* Cursor up — wrap to bottom if on first row */
static void cursor_up(void)
{
    if (cury != 0) {
        rowup();
    } else {
        cury = 1920;
        cursy = 24;
        wp75();
    }
}

/* Carriage return — column 0, update cursor */
static void carriage_return(void)
{
    curx = 0;
    wp75();
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
    es0h();
    wp75();
}

/* Clear screen — fill display with spaces, home */
static void clear_screen(void)
{
#ifndef HOST_TEST
    __asm
        ld hl, #0xF800          ; DSPSTR
        ld de, #0xF801
        ld (hl), #0x20
        ld bc, #1999
        ldir
    __endasm;
#endif
    es0h();
    wp75();
}

/* Erase from cursor to end of line */
static void erase_to_eol(void)
{
    uint8_t *row = (uint8_t *)(DSPSTR + cury);
    for (uint8_t i = curx; i < 80; i++)
        row[i] = ' ';
}

/* Erase from cursor to end of screen */
static void erase_to_eos(void)
{
    uint16_t pos = cury + curx;
    uint8_t *p = (uint8_t *)(DSPSTR + pos);
    uint16_t count = 2000 - pos;
    while (count--)
        *p++ = ' ';
}

/* Delete line — shift lines up, fill last line */
static void delete_line(void)
{
    uint16_t row_off = cury;
    uint16_t count = 1920 - row_off;
    if (count != 0) {
#ifndef HOST_TEST
        __asm
            ld hl, (_cury)
            ld de, #0xF800      ; DSPSTR
            add hl, de          ; HL = DSPSTR + cury (dest)
            push hl
            ld de, #80
            add hl, de          ; HL = DSPSTR + cury + 80 (src)
            ex de, hl           ; DE = src ... wait, LDIR: HL=src, DE=dst
            pop hl              ; HL = dst
            ex de, hl           ; DE = dst, HL = src
            ld bc, (_cury)
            push hl
            ld hl, #1920
            or a
            sbc hl, bc          ; HL = 1920 - cury = count
            ld b, h
            ld c, l
            pop hl
            ldir
        __endasm;
#endif
    }
    fill_line((uint8_t *)(DSPSTR + 1920));
}

/* Insert line — shift lines down, fill current line */
static void insert_line(void)
{
    uint16_t row_off = cury;
    uint16_t count = 1920 - row_off;
    if (count != 0) {
#ifndef HOST_TEST
        __asm
            ; LDDR from DSPSTR+1919 to DSPSTR+1999
            ld bc, (_cury)
            ld hl, #1920
            or a
            sbc hl, bc          ; HL = count = 1920 - cury
            ld b, h
            ld c, l
            ld hl, #(0xF800 + 1919)  ; DSPSTR + 1919 (src end)
            ld de, #(0xF800 + 1999)  ; DSPSTR + 1999 (dst end)
            lddr
        __endasm;
#endif
    }
    fill_line((uint8_t *)(DSPSTR + cury));
}

/* XY cursor addressing — called for each byte after ctrl-F */
static void xyadd(void)
{
    uint8_t val = (usession & 0x7F) - 32;
    xflg--;
    if (xflg != 0) {
        adr0 = val;             /* save first coordinate */
        return;
    }
    /* Second byte: compute final position */
    uint8_t x_val, y_val;
    if (adrmod == 0) {
        x_val = adr0;           /* XY mode: first=X, second=Y */
        y_val = val;
    } else {
        x_val = val;            /* YX mode: first=Y, second=X */
        y_val = adr0;
    }
    /* Modular arithmetic (matches original CHKDC) */
    while (x_val >= 80) x_val -= 80;
    while (y_val >= 25) y_val -= 25;
    curx = x_val;
    cursy = y_val;
    cury = (uint16_t)y_val * 80;
    wp75();
}

/* Display printable character — convert, write, advance cursor */
static void displ(void)
{
    uint8_t ch = usession;

    locad = cury + curx;

    if (ch >= 192)
        ch -= 192;

    if (ch >= 128) {
        graph = ch & 4;         /* set/clear graphical mode */
    } else if (!graph) {
        ch = *((uint8_t *)(OUTCON_ADDR + ch));  /* OUTCON conversion */
    }

    *((uint8_t *)(DSPSTR + locad)) = ch;
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
    case 0x06: es0h(); xflg = 2; break;  /* start XY addressing */
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
void bios_conout(uint8_t c) __naked
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
        ld (_usession), a
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

void bios_list(uint8_t c) __naked
{
    (void)c;
#ifndef HOST_TEST
    __asm
        ret
    __endasm;
#endif
}

void bios_punch(uint8_t c) __naked
{
    (void)c;
#ifndef HOST_TEST
    __asm
        ret
    __endasm;
#endif
}

uint8_t bios_reader(void) __naked
{
#ifndef HOST_TEST
    __asm
        ld a, #0x1A             ; return ^Z (EOF) — CP/M reads A
        ret
    __endasm;
#else
    return 0x1A;
#endif
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

uint16_t bios_seldsk(uint8_t disk) __naked
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
        ex de, hl               ; save HL (return val), HL = caller SP
        ld sp, hl               ; restore caller stack
        ex de, hl               ; HL = return value
        pop bc
        ei
        ret
    __endasm;
#else
    return 0;
#endif
}

static uint16_t bios_seldsk_c(uint8_t drive)
{
    uint8_t fmt, *fp;
    uint16_t dph_offset;

    if (drive > drno)
        return 0;               /* invalid drive */

    sekdsk = drive;

    /* look up format from fd0 table */
    fp = &fd0 + drive;
    fmt = *fp;

    /* if format changed, flush dirty buffer */
    if (fmt != cform) {
        if (hstwrt) {
            wrthst();
            hstwrt = 0;
        }
    }

    cform = fmt;

    /* get format descriptor (FDF) pointer */
    form = (uint16_t)((uint8_t *)&fdf1 + (fmt & 0xF8));

    /* get EOTV from format block: byte at offset 4 from FDF start is EOT */
    {
        uint8_t *fdfp = (uint8_t *)form;
        eotv = fdfp[4];        /* EOT value (end-of-track) */
    }

    /* copy FSPA format parameters to working area */
    {
        uint8_t *src = &fspa00[((fmt & 0xF8) >> 3) * 16];
        dpblck = src[0] | (src[1] << 8);
        cpmrbp = src[2];
        cpmspt = src[3] | (src[4] << 8);
        secmsk = src[5];
        secshf = src[6];
        trantb = src[7] | (src[8] << 8);
        dtlv = src[9];
        dsktyp = src[10];
    }

    /* compute DPH offset */
    dph_offset = (uint16_t)drive * 16;

    /* update DPB pointer in DPH (offset 10 = word 5) */
    {
        uint16_t *dph = (uint16_t *)((uint8_t *)dpbase + dph_offset);
        dph[5] = dpblck;
    }

    /* copy track offset for this drive */
    {
        uint16_t *dpb_ptr = (uint16_t *)dpblck;
        uint16_t off = dpb_ptr[7];  /* OFF field is at DPB offset 14 (word 7) */
        /* not used currently, but original does LDIR from DPB offset to TRKOFF */
        (void)off;
    }

    return (uint16_t)((uint8_t *)dpbase + dph_offset);
}

void bios_settrk(uint16_t track) __naked
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

void bios_setsec(uint16_t sector) __naked
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

void bios_setdma(uint16_t addr) __naked
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

static uint8_t xread(void)
{
    unacnt = 0;
    readop = 1;
    rsflag = 1;
    wrtype = WRUAL;
    return rwoper();
}

static uint8_t xwrite(uint8_t wt)
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

uint8_t bios_read(void) __naked
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

uint8_t bios_write(uint8_t type) __naked
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

uint8_t bios_listst(void) __naked
{
#ifndef HOST_TEST
    __asm
        ld a, #0xFF             ; list device ready (CP/M reads A)
        ret
    __endasm;
#else
    return 0xFF;
#endif
}

uint16_t bios_sectran(uint16_t sector) __naked
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

void bios_wfitr(void) __naked
{
#ifndef HOST_TEST
    __asm
        ret
    __endasm;
#endif
}

uint8_t bios_reads(void) __naked
{
#ifndef HOST_TEST
    __asm
        xor a                   ; A=0 = not ready (CP/M reads A)
        ret
    __endasm;
#else
    return 0;
#endif
}

void bios_linsel(void) __naked
{
#ifndef HOST_TEST
    __asm
        ret
    __endasm;
#endif
}

void bios_exit(void) __naked
{
#ifndef HOST_TEST
    __asm
        ret
    __endasm;
#endif
}

void bios_clock(void) __naked
{
#ifndef HOST_TEST
    __asm
        ret
    __endasm;
#endif
}

void bios_hrdfmt(void) __naked
{
#ifndef HOST_TEST
    __asm
        ret
    __endasm;
#endif
}

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
static void isr_crt_body(void)
{
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
}

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
        push ix
        push iy
        call _isr_crt_body
        pop iy
        pop ix
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

/*
 * Keyboard ISR body (PIO ch.A)
 * Reads keystroke from PIO and stores in 16-byte ring buffer.
 * Must read PIO data port to clear the interrupt even if buffer is full.
 */
static void isr_pio_kbd_body(void)
{
    uint8_t key, new_head;

    key = _port_pio_a_data;     /* read key (clears PIO interrupt) */
    new_head = (kbhead + 1) & KBMASK;
    if (new_head != kbtail) {   /* not full */
        kbbuf[kbhead] = key;
        kbhead = new_head;
    }
    /* if full, keystroke is discarded */
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
        push ix
        push iy
        call _isr_pio_kbd_body
        pop iy
        pop ix
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

/*
 * Floppy completion ISR (CTC ch.3)
 * Sets fl_flg, then reads FDC result or SENSE INTERRUPT STATUS.
 */
static void isr_floppy_body(void)
{
    uint8_t delay;

    fl_flg = 0xFF;

    /* brief delay for FDC status stabilization */
    for (delay = 5; delay; delay--)
        ;

    if (_port_fdc_status & 0x10)
        fdc_result();           /* result phase — read full result */
    else
        fdc_sense_int();        /* seek/recal — sense interrupt status */
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
        push ix
        push iy
        call _isr_floppy_body
        pop iy
        pop ix
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
