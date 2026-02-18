/*
 * boot.h — Shared state and function declarations for RC702 autoload
 *
 * Register-based calling convention: functions take up to 2 parameters
 * and return values via sdcccall(1) ABI (first param in A/HL, second
 * in E/DE, return in L/HL).
 */

#ifndef BOOT_H
#define BOOT_H

#include <stdint.h>

/* NEC uPD765 (Intel 8272) FDC command bytes */
#define FDC_SENSE_DRIVE   0x04
#define FDC_RECALIBRATE   0x07
#define FDC_SENSE_INT     0x08
#define FDC_SEEK          0x0F
#define FDC_READ_DATA     0x06
#define FDC_READ_ID       0x0A
#define FDC_MFM           0x40  /* set bit 6 for MFM (double density) */

/* Memory layout constants */
#define FLOPPYDATA  0x0000
#define COMALBOOT   0x1000
#define PROM1_ADDR  0x2000
#define DIROFF      0x0B60
#define DIREND_HI   0x0D
#define DSPSTR_ADDR 0x7800
#define DSP_CHARS   0x0780
#define ATTOFF      7
#define SECSZ0      0x80

/*
 * Boot state — all variables used by the boot ROM.
 *
 * FDC command buffer: curcyl through dtl are contiguous and sent
 * sequentially by flrtrk() as the 7-byte parameter block.
 */
typedef struct {
    uint8_t fdcres[7];      /* +0:  FDC result bytes */
    uint8_t fdcflg;         /* +7:  FDC flag */
    uint8_t epts;           /* +8:  end-of-track for seek */
    uint8_t trksz;          /* +9:  track size */
    uint8_t drvsel;         /* +10: drive select */
    uint8_t fdctmo;         /* +11: FDC timeout */
    uint8_t fdcwai;         /* +12: FDC wait count */
    uint16_t spsav;         /* +13: saved SP */
    uint8_t combuf[2];      /* +15: command buffer prefix */
    /* FDC command parameter block — contiguous, sent by flrtrk */
    uint8_t curcyl;         /* +17: current cylinder */
    uint8_t curhed;         /* +18: current head */
    uint8_t currec;         /* +19: current record/sector */
    uint8_t reclen;         /* +20: record length (N value) */
    uint8_t cureot;         /* +21: end of track */
    uint8_t gap3;           /* +22: gap 3 length */
    uint8_t dtl;            /* +23: data length */
    uint16_t secbyt;        /* +24: sector bytes */
    uint8_t flpflg;         /* +26: floppy interrupt flag */
    uint8_t flpwai;         /* +27: floppy wait count */
    uint8_t diskbits;       /* +28: disk type bits */
    uint8_t dsktyp;         /* +29: disk type */
    uint8_t morefl;         /* +30: more data flag */
    uint8_t reptim;         /* +31: retry count */
    uint16_t memadr;        /* +32: memory address */
    uint16_t trbyt;         /* +34: transfer bytes */
    uint16_t trkovr;        /* +36: track overflow */
    uint8_t errsav;         /* +38: saved error code */
} boot_state_t;

/*
 * Global boot state.
 * Z80: defined in crt0.asm at fixed address 0xBF00.
 * Host: allocated in boot.c BSS.
 */
extern boot_state_t g_state;

/* Display buffer */
#ifdef HOST_TEST
extern uint8_t dspstr[2000];
extern uint16_t scroll_offset;
#else
#define dspstr         ((uint8_t *)0x7800)
#define scroll_offset  (*(uint16_t *)0x7FF5)
#endif

/* init.c — peripheral init called from crt0.asm after SP/I/IM2 setup */
void init_peripherals(void);
void init_pio(void);
void init_ctc(void);
void init_dma(void);
void init_crt(void);
void init_fdc(void);

/* fmt.c */
void fmtlkp(void);
void calctb(void);

/* fdc.c */
void snsdrv(void);
void flo4(void);
void flo6(void);
void flo7(uint8_t dh, uint8_t cyl);
void rsult(void);
uint8_t recalv(void);         /* returns 0/1/2 */
uint8_t flseek(void);         /* returns 0/1/2 */
void flrtrk(uint8_t cmd);
uint8_t waitfl(uint8_t timeout); /* returns 0=ok, 1=timeout */
uint8_t chkres(void);         /* returns 0/1/2 */
uint8_t readtk(uint8_t cmd, uint8_t retries); /* returns 0=ok, 1=error */
uint8_t dskauto(void);        /* returns 0/1 */
void stpdma(void);

/* boot.c */
void clear_screen(void);
void display_banner(void);
void errdsp(uint8_t code);
uint8_t boot_detect(void);    /* returns 0/1 */
void boot7(void);
void flboot(void);
void check_prom1(void);

/* isr.c */
void disint_handler(void);
void flpint_body(void);

/* Implemented in crt0.asm (C fallback in boot.c for HOST_TEST) */
void halt_msg(const uint8_t *msg);

/* Comparison helpers — C in boot.c (pointer-increment avoids IX frame) */
uint8_t b7_cmp6(const uint8_t *a, const uint8_t *b);
uint8_t b7_chksys(const uint8_t *dir, const uint8_t *pattern);

#ifdef HOST_TEST
void mcopy(uint8_t *dst, const uint8_t *src, uint8_t len);
uint8_t mcmp(const uint8_t *a, const uint8_t *b, uint8_t len);
#endif

/* Implemented in crt0.asm */
void halt_forever(void);
void jump_to(uint16_t addr);

/* syscall — addr in HL, bc packed as 16-bit in DE */
void syscall(uint16_t addr, uint16_t bc);

#endif /* BOOT_H */
