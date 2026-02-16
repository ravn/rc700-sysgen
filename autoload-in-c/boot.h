/*
 * boot.h — Shared state and function declarations for RC702 autoload
 *
 * The boot_state_t struct holds all variables that in the original ROM
 * were at fixed RAM addresses (0x8000+).  For the Z80 target, key fields
 * are placed at fixed addresses for ISR/SYSCALL compatibility.
 */

#ifndef BOOT_H
#define BOOT_H

#include <stdint.h>

/* Memory layout constants */
#define FLOPPYDATA  0x0000      /* Boot sector load address */
#define COMALBOOT   0x1000      /* ID-COMAL bootstrap entry */
#define PROM1_ADDR  0x2000      /* PROM1 address */
#define DIROFF      0x0B60      /* Directory area offset */
#define DIREND_HI   0x0D        /* Directory end boundary (high byte) */
#define DSPSTR_ADDR 0x7800      /* Display buffer address */
#define DSP_CHARS   0x0780      /* Visible display chars (80*24=1920) */
#define ATTOFF      7           /* File attribute offset */
#define SECSZ0      0x80        /* Base sector size (N=0, 128 bytes) */

/*
 * Boot state — all variables used by the boot ROM.
 * Mirrors the RAM layout at 0x8000+ in the original.
 */
typedef struct {
    /* FDC result area (7 bytes) */
    uint8_t fdcres[7];          /* ST0..N result bytes */

    /* Drive/controller state */
    uint8_t fdcflg;             /* FDC busy flag (0xFF=busy) */
    uint8_t epts;               /* Max cylinder (sectors per track label in asm) */
    uint8_t trksz;              /* Track sector size byte */
    uint8_t drvsel;             /* Drive select byte */
    uint8_t fdctmo;             /* FDC timeout counter (init=3) */
    uint8_t fdcwai;             /* FDC wait counter (init=4) */
    uint16_t spsav;             /* Stack pointer save */

    /* FDC command buffer (9 bytes: cmd, dh, C, H, R, N, EOT, GAP3, DTL) */
    uint8_t combuf[2];          /* Command byte + drive/head */
    uint8_t curcyl;             /* Current cylinder number */
    uint8_t curhed;             /* Current head address */
    uint8_t currec;             /* Current record/sector number */
    uint8_t reclen;             /* Record length N (0=128, 1=256, 2=512) */
    uint8_t cureot;             /* Current EOT (end of track) */
    uint8_t gap3;               /* GAP3 value */
    uint8_t dtl;                /* DTL value (always 0x80) */

    /* Transfer state */
    uint16_t secbyt;            /* Bytes per sector */
    uint8_t flpflg;             /* Floppy interrupt flag (0=idle, 2=done) */
    uint8_t flpwai;             /* Floppy wait counter (init=4) */

    /* Disk/boot state */
    uint8_t diskbits;           /* Status flags (bit7=mini, bit4-2=N<<2, bit1=dual-sided, bit0=side) */
    uint8_t dsktyp;             /* Disk type (bit7=mini, bit0=floppy boot) */
    uint8_t morefl;             /* More data to transfer flag */
    uint8_t reptim;             /* Retry counter */

    /* Memory transfer state */
    uint16_t memadr;            /* Memory address pointer (DMA dest) */
    uint16_t trbyt;             /* Transfer byte count */
    uint16_t trkovr;            /* Track overflow count */

    /* Error state */
    uint8_t errsav;             /* Saved error code */
} boot_state_t;

/* Global boot state instance */
extern boot_state_t g_state;

/* Display buffer — 2000 bytes at 0x7800 (Z80) or regular RAM (host) */
#ifdef __SDCC
extern __at(DSPSTR_ADDR) uint8_t dspstr[2000];
#else
extern uint8_t dspstr[2000];
#endif

/* Scroll offset for circular buffer display */
extern uint16_t scroll_offset;

/* init.c */
void init_pio(void);
void init_ctc(uint8_t mode);
void init_dma(void);
void init_crt(void);
void init_fdc(void);

/* fmt.c */
void fmtlkp(boot_state_t *st);
void calctb(boot_state_t *st);
void setfmt(boot_state_t *st);

/* fdc.c */
void snsdrv(boot_state_t *st);
void flo4(boot_state_t *st);
void flo6(boot_state_t *st);
void flo7(boot_state_t *st, uint8_t dh, uint8_t cyl);
void rsult(boot_state_t *st);
uint8_t recalv(boot_state_t *st);
uint8_t flseek(boot_state_t *st);
void flrtrk(boot_state_t *st, uint8_t cmd);
void clrflf(boot_state_t *st);
uint8_t waitfl(boot_state_t *st, uint8_t timeout);
uint8_t chkres(boot_state_t *st);
uint8_t readtk(boot_state_t *st, uint8_t cmd, uint8_t retries);
uint8_t dskauto(boot_state_t *st);
void stpdma(boot_state_t *st, uint16_t addr, uint16_t count);
void dmawrt(boot_state_t *st, uint16_t addr, uint16_t count);
uint8_t mkdhb(boot_state_t *st);

/* boot.c */
void clear_screen(void);
void display_banner(void);
void errdsp(boot_state_t *st, uint8_t code);
void errcpy(void);
uint8_t boot_detect(boot_state_t *st);
void boot7(boot_state_t *st);
void flboot(boot_state_t *st);
void check_prom1(void);

/* isr.c */
void flpint_body(void);

#endif /* BOOT_H */
