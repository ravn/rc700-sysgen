/*
 * boot.h — Shared state and function declarations for RC702 autoload
 *
 * Globals-only architecture: no function takes parameters or returns values.
 * All inputs/outputs go through g_state fields. This eliminates IX frame
 * entry/exit overhead and stack parameter pushing in sccz80.
 */

#ifndef BOOT_H
#define BOOT_H

#include <stdint.h>

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
    /* New fields for globals-only architecture */
    uint8_t result;         /* +39: function return value */
    uint8_t fdccmd;         /* +40: FDC command for flrtrk/readtk */
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

/* init.c / crt0.asm — all init done in crt0.asm on Z80, C for host */
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
void flo7(void);       /* reads curcyl, curhed, drvsel from g_state */
void rsult(void);
void recalv(void);     /* writes g_state.result: 0/1/2 */
void flseek(void);     /* writes g_state.result: 0/1/2 */
void flrtrk(void);     /* reads g_state.fdccmd */
void waitfl(void);     /* writes g_state.result: 0/1; hardcoded 0xFF timeout */
void chkres(void);     /* writes g_state.result: 0/1/2 */
void readtk(void);     /* reads g_state.fdccmd, g_state.reptim; writes g_state.result */
void dskauto(void);    /* writes g_state.result: 0/1 */
void stpdma(void);     /* reads g_state.memadr, g_state.trbyt; hardcoded mode 0x45 */

/* boot.c */
void clear_screen(void);
void display_banner(void);
void errdsp(void);     /* reads g_state.errsav */
void boot_detect(void); /* writes g_state.result: 0/1 */
void boot7(void);
void flboot(void);
void check_prom1(void);

/* isr.c */
void flpint_body(void);

/* Implemented in crt0.asm */
void halt_forever(void);    /* infinite loop (avoids sccz80 codegen bug) */
void jump_to(uint16_t addr); /* jump to arbitrary address */

/* syscall — the one function that keeps stack parameters */
void syscall(uint16_t addr, uint8_t b, uint8_t c);

#endif /* BOOT_H */
