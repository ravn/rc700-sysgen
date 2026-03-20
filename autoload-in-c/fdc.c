/*
 * fdc.c — NEC uPD765 (Intel 8272) FDC driver for RC702 autoload
 *
 * Commands (defined in boot.h):
 *   0x04 = Sense Drive Status    0x07 = Recalibrate
 *   0x08 = Sense Interrupt Status 0x0F = Seek
 *   0x06 = Read Data             0x0A = Read ID
 *   MFM commands have bit 6 set (+0x40).
 *
 * Main Status Register (hal_fdc_status(), port 0x04):
 *   bit 7: RQM — ready for CPU data transfer
 *   bit 6: DIO — direction (0=CPU→FDC write, 1=FDC→CPU read)
 *   bit 5: EXM — in execution phase
 *   bit 4: CB  — command busy (FDC has a command in progress)
 *   bits 3-0:   drive busy flags (per-drive seek in progress)
 *
 * Result registers (fdcres[], read via hal_fdc_wait_read()):
 *   ST0 [0]: bit 7-6 = IC (interrupt code: 00=normal, 01=abnormal,
 *            10=invalid cmd, 11=not ready); bit 5 = SE (seek end);
 *            bit 2 = HD (head); bits 1-0 = US (unit/drive select)
 *   ST1 [1]: error flags (EN, DE, OR, ND, NW, MA)
 *   ST2 [2]: error flags; bit 6 = CM (control mark, benign)
 *   ST3 [0]: from Sense Drive Status — bit 5 = RDY; bits 2-0 = HD+US
 *   [3]-[6]: C, H, R, N (cylinder, head, record, sector size code)
 *
 * Register-based calling convention: functions take up to 2 params
 * via sdcccall(1) ABI and return status values directly.
 */

#include "hal.h"
#include "boot.h"

/*
 * waitfl timing model — must be long enough for worst-case FM track read.
 *
 * hal_delay(outer, inner) compiles to:
 *   outer × inner × 256 DJNZ iterations × 13 T-states = total T-states
 *
 * waitfl calls hal_delay once per iteration, with 255 iterations max.
 * Total timeout = 255 × hal_delay T-states.
 *
 * Worst case: 8" FM track at 360 RPM = 166ms/revolution.
 * Head may need to wait for sector 1 (~1 revolution) then read all
 * 26 sectors (~1 revolution) = 332ms.  Add margin → require ≥400ms.
 *
 * Assembly DELAY(B=1,C=1) used a 16-bit HL loop: 511×24T = 12,264T.
 * hal_delay(1,4) = 4×256×13 = 13,312T — matches within 8%.
 */
#define WAITFL_DELAY_OUTER  1
#define WAITFL_DELAY_INNER  4

/* Compute timeout in ms using long arithmetic to avoid 16-bit overflow.
 * T-states = 255 × outer × inner × 256 × 13 (DJNZ at 13T/iteration).
 * Split: per_iter = outer × inner × 256 × 13, total_ms = 255 × per_iter / (MHz×1000). */
#define Z80_MHZ           4  /* RC702: Z80-A at 4 MHz */
#define WAITFL_PER_ITER  ((long)(WAITFL_DELAY_OUTER) * (WAITFL_DELAY_INNER) * 256 * 13)
#define WAITFL_MS        (255L * WAITFL_PER_ITER / (Z80_MHZ * 1000))

/* Compile-time check: timeout must cover two FM revolutions + margin */
typedef char _waitfl_timeout_check[(WAITFL_MS >= 400) ? 1 : -1];



void snsdrv(void) {
    hal_fdc_wait_write(FDC_SENSE_DRIVE);
    hal_fdc_wait_write(drvsel);
    fdcres[0] = hal_fdc_wait_read(); /* ST3: drive status */
}

void flo4(void) {
    hal_fdc_wait_write(FDC_RECALIBRATE);
    hal_fdc_wait_write(drvsel);
}

void flo6(void) {
    hal_fdc_wait_write(FDC_SENSE_INT);
    fdcres[0] = hal_fdc_wait_read();   /* ST0 */
    if ((fdcres[0] & 0xC0) != 0x80) {  /* IC != 10 (not "invalid cmd") */
        fdcres[1] = hal_fdc_wait_read(); /* PCN (present cylinder) */
    }
}

void flo7(byte dh, byte cyl) {
    hal_fdc_wait_write(FDC_SEEK);
    hal_fdc_wait_write(dh & 0x07);  /* HD + US1/US0 (head + drive) */
    hal_fdc_wait_write(cyl);        /* NCN (new cylinder number) */
}

void rsult(void) {
    byte i;

    fdcflg = 7;
    for (i = 0; i < 7; i++) {
        fdcres[i] = hal_fdc_wait_read();
        hal_delay(0, fdcwai);
        if (!(hal_fdc_status() & 0x10)) {  /* CB=0: no more result bytes */
            fdcres[i + 1] = hal_dma_status();
            return;
        }
    }
    errsav = 0xFE;
    errdsp(0xFE);
}

byte waitfl(byte timeout) {
    while (--timeout) {
        hal_delay(WAITFL_DELAY_OUTER, WAITFL_DELAY_INNER);
        if (flpflg & 0x02) {
            hal_di();
            flpflg = 0;
            hal_ei();
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
    hal_di();
    hal_dma_mask(1);
    hal_dma_mode(0x45);  /* demand mode, addr increment, read, channel 1 */
    hal_dma_clear_bp();
    hal_dma_ch1_addr(memadr);
    hal_dma_ch1_wc(trbyt - 1);
    hal_dma_unmask(1);
    hal_ei();
}

void flrtrk(byte cmd) {
    byte mfm_flag = (diskbits & 0x01) ? FDC_MFM : 0;
    byte dh = (curhed << 2) | drvsel;

    hal_di();
    fdcflg = 0xFF;

    hal_fdc_wait_write(cmd + mfm_flag);
    hal_fdc_wait_write(dh);

    if ((cmd & 0x0F) == FDC_READ_DATA) {
        byte *p = &curcyl;
        byte i;
        for (i = 0; i < 7; i++) {
            hal_fdc_wait_write(p[i]);
        }
    }
    hal_ei();
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
        hal_di();
        flpflg = 0;
        hal_ei();

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
