/*
 * boot.h — Shared state and function declarations for RC702 autoload
 */

#ifndef BOOT_H
#define BOOT_H

#include <stdint.h>

/* Calling convention macros — only active on Z80 target */
#ifdef __SDCC
#define FASTCALL __z88dk_fastcall
#define CALLEE   __z88dk_callee
#else
#define FASTCALL
#define CALLEE
#endif

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
 */
typedef struct {
    uint8_t fdcres[7];
    uint8_t fdcflg;
    uint8_t epts;
    uint8_t trksz;
    uint8_t drvsel;
    uint8_t fdctmo;
    uint8_t fdcwai;
    uint16_t spsav;
    uint8_t combuf[2];
    uint8_t curcyl;
    uint8_t curhed;
    uint8_t currec;
    uint8_t reclen;
    uint8_t cureot;
    uint8_t gap3;
    uint8_t dtl;
    uint16_t secbyt;
    uint8_t flpflg;
    uint8_t flpwai;
    uint8_t diskbits;
    uint8_t dsktyp;
    uint8_t morefl;
    uint8_t reptim;
    uint16_t memadr;
    uint16_t trbyt;
    uint16_t trkovr;
    uint8_t errsav;
} boot_state_t;

/* Global boot state — accessed directly by all functions */
#ifdef __SDCC
extern __at(0xBF00) boot_state_t g_state;
#else
extern boot_state_t g_state;
#endif

/* Display buffer */
#ifdef HOST_TEST
extern uint8_t dspstr[2000];
extern uint16_t scroll_offset;
#else
#define dspstr         ((uint8_t *)0x7800)
#define scroll_offset  (*(uint16_t *)0x7FF5)
#endif

/* init.c / crt0.asm */
void init_pio(void);
void init_ctc(uint8_t mode) FASTCALL;
void init_dma(void);
void init_crt(void);
void init_fdc(void);

/* Utility functions — asm in crt0.asm, C for HOST_TEST */
void memcopy(uint8_t *dst, const uint8_t *src, uint8_t len) CALLEE;
uint8_t memcmp_n(const uint8_t *a, const uint8_t *b, uint8_t len) CALLEE;

/* fmt.c / crt0.asm */
void fmtlkp(void);
void calctb(void);
void setfmt(void);

/* fdc.c / crt0.asm */
void snsdrv(void);
void flo4(void);
void flo6(void);
void flo7(uint8_t dh, uint8_t cyl) CALLEE;
void rsult(void);
uint8_t recalv(void);
uint8_t flseek(void);
void flrtrk(uint8_t cmd) FASTCALL;
void clrflf(void);
uint8_t waitfl(uint8_t timeout) FASTCALL;
uint8_t chkres(void);
uint8_t readtk(uint8_t cmd, uint8_t retries) CALLEE;
uint8_t dskauto(void);
void stpdma(uint16_t addr, uint16_t count, uint8_t mode);
uint8_t mkdhb(void);

/* boot.c */
void clear_screen(void);
void display_banner(void);
void errdsp(uint8_t code) FASTCALL;
void errcpy(void);
uint8_t boot_detect(void);
void boot7(void);
void flboot(void);
void check_prom1(void);

/* isr.c */
void flpint_body(void);

#endif /* BOOT_H */
