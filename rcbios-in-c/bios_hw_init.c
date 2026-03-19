/* bios_hw_init.c — One-time hardware initialization (BOOT_CODE section).
 *
 * Compiled with --codeseg BOOT_CODE so this code lives in the unrelocated
 * boot area, NOT in the resident BIOS. It runs once at cold boot and is
 * overwritten by CCP after boot — saving ~474 bytes of resident BIOS.
 *
 * All hardware I/O uses __sfr ports (work from any address).
 * References to BSS variables (wr5a, fd0[], dpbase, etc.) use their
 * relocated runtime addresses, which are valid because coldboot has
 * already copied the BIOS to BIOS_BASE before calling bios_hw_init().
 */

#include <string.h>
#include <intrinsic.h>
#include "hal.h"
#include "bios.h"

/* ISR functions in bios.c (relocated BIOS) — referenced by IVT */
extern void isr_dummy(void);
extern void isr_crt(void);
extern void isr_floppy(void);
extern void isr_hd(void);
extern void isr_sio_b_tx(void);
extern void isr_sio_b_ext(void);
extern void isr_sio_b_spec(void);
extern void isr_sio_a_tx(void);
extern void isr_sio_a_ext(void);
extern void isr_sio_a_rx(void);
extern void isr_sio_a_spec(void);
extern void isr_pio_kbd(void);
extern void isr_pio_par(void);

/* FDC write helper in bios.c (relocated BIOS) */
extern void fdc_write(byte val);

/* BSS variables in bios.c (at relocated runtime addresses) */
extern byte drno;
extern word dpbase[];
extern byte dirbf[];
extern const DPB dpb8;
extern byte chk0[], chk1[], all0[], all1[];
extern byte hstact, hstwrt, unacnt, erflag, cform, lstdsk;

/* ================================================================
 * Interrupt vector table — function pointer array
 *
 * Linker resolves ISR addresses to their runtime (relocated) values.
 * Copied to IVT_ADDR (page-aligned) by setup_ivt().
 * ================================================================ */

typedef void (*isr_fn)(void);

#define IVT_ENTRIES 18

static const isr_fn ivt_template[IVT_ENTRIES] = {
    isr_dummy,              /*  0: CTC1 ch0 — SIO-A baud rate */
    isr_dummy,              /*  1: CTC1 ch1 — SIO-B baud rate */
    isr_crt,                /*  2: CTC1 ch2 — display refresh */
    isr_floppy,             /*  3: CTC1 ch3 — floppy completion */
    isr_hd,                 /*  4: CTC2 ch0 — hard disk */
    isr_dummy,              /*  5: CTC2 ch1 — unused */
    isr_dummy,              /*  6: CTC2 ch2 — unused */
    isr_dummy,              /*  7: CTC2 ch3 — unused */
    isr_sio_b_tx,           /*  8: SIO ch.B TX */
    isr_sio_b_ext,          /*  9: SIO ch.B ext status */
    isr_dummy,              /* 10: SIO ch.B RX — disabled */
    isr_sio_b_spec,         /* 11: SIO ch.B special */
    isr_sio_a_tx,           /* 12: SIO ch.A TX */
    isr_sio_a_ext,          /* 13: SIO ch.A ext status */
    isr_sio_a_rx,           /* 14: SIO ch.A RX — ring buffer */
    isr_sio_a_spec,         /* 15: SIO ch.A special */
    isr_pio_kbd,            /* 16: PIO ch.A — keyboard */
    isr_pio_par,            /* 17: PIO ch.B — parallel output */
};

/* Set the Z80 I register.  sdcccall(1) passes byte param in A,
 * so the inline ld i,a picks it up directly.
 *
 * Must NOT be declared inline — inlining removes the call boundary
 * and with it the sdcccall(1) guarantee that A holds the parameter.
 * Tested: inline version emits ld i,a without ld a,page — wrong. */
static void set_i_reg(byte page)
{
    (void)page;
    __asm__("ld i, a\n");
}

/* Copy IVT to page-aligned RAM and enable IM2 */
static void setup_ivt(void)
{
    memcpy((void *)IVT_ADDR, ivt_template, sizeof(ivt_template));
    set_i_reg(IVT_ADDR >> 8);
    intrinsic_im_2();
}

/* ================================================================
 * Hardware initialization — called once from coldboot after relocation.
 * Configures PIO, CTC, SIO, DMA, FDC, CRT, display, and disk tables.
 * ================================================================ */

void bios_hw_init(void)
{
    /* Set up interrupt vector table and IM2 before any device init */
    setup_ivt();

    /* PIO: set interrupt vectors and modes */
    _port_pio_a_ctrl = 0x20;    /* PIO-A interrupt vector */
    _port_pio_b_ctrl = 0x22;    /* PIO-B interrupt vector */
    _port_pio_a_ctrl = 0x4F;    /* PIO-A input mode */
    _port_pio_b_ctrl = 0x0F;    /* PIO-B output mode */
    _port_pio_a_ctrl = 0x83;    /* PIO-A enable interrupt */
    _port_pio_b_ctrl = 0x83;    /* PIO-B enable interrupt */

    /* CTC: set interrupt vector and program all channels */
    _port_ctc0 = 0x00;         /* CTC interrupt vector */
    _port_ctc0 = CFG.ctc_mode0;
    _port_ctc0 = CFG.ctc_count0;
    _port_ctc1 = CFG.ctc_mode1;
    _port_ctc1 = CFG.ctc_count1;
    _port_ctc2 = CFG.ctc_mode2;
    _port_ctc2 = CFG.ctc_count2;
    _port_ctc3 = CFG.ctc_mode3;
    _port_ctc3 = CFG.ctc_count3;

    /* SIO: program channels A and B from CONFI init blocks */
    {
        byte i;
        for (i = 0; i < 9; i++)
            _port_sio_a_ctrl = CFG.sioa[i];
        for (i = 0; i < 11; i++)
            _port_sio_b_ctrl = CFG.siob[i];
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
    while (_port_fdc_status & 0x1F)
        ;  /* wait for all drives not seeking and not busy */
    fdc_write(0x03);            /* SPECIFY command */
    fdc_write(0xDF);            /* step rate 3ms, head unload 240ms */
    fdc_write(0x28);            /* head load 40ms, DMA mode */

    /* Clear display buffer with spaces */
    memset(DISPLAY_ROW(0), ' ', sizeof(Display));

    /* Clear work area (curx through end of 64K address space) */
    memset((void *)(WORK_ADDR + 1), 0, 0xFFFF - WORK_ADDR);

    /* CRT 8275: reset and program */
    _port_crt_cmd = 0x00;       /* reset */
    _port_crt_param = CFG.par1;     /* chars/row */
    _port_crt_param = CFG.par2;     /* rows/frame */
    _port_crt_param = CFG.par3;     /* lines/char + underline */
    _port_crt_param = CFG.par4;     /* cursor format */
    _port_crt_cmd = 0x80;       /* load cursor position */
    _port_crt_param = 0;        /* cursor X = 0 */
    _port_crt_param = 0;        /* cursor Y = 0 */
    _port_crt_cmd = 0xE0;       /* preset counters */
    _port_crt_cmd = 0x23;       /* start display */

    /* Initialize runtime variables */
    wr5a = CFG.sioa[6] & 0x60;  /* SIO-A bits/char from WR5 */
    wr5b = CFG.siob[8] & 0x60;  /* SIO-B bits/char from WR5 */
    adrmod = xyflg;              /* copy addressing mode (via CFG macro) */

    /* Initialize motor timer reload from config */
    stptim_var = CFG.stptim;

    /* Initialize disk subsystem */
    {
        byte d;

        /* Copy drive format table from config block */
        for (d = 0; d < 16; d++)
            fd0[d] = CFG.infd[d];

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
            memset(dph, 0, 8 * sizeof(word));       /* zero entire DPH */
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
