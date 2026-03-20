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

typedef uint8_t  byte;
typedef uint16_t word;

/* NEC uPD765 (Intel 8272) FDC command bytes */
#define FDC_SENSE_DRIVE   0x04
#define FDC_RECALIBRATE   0x07
#define FDC_SENSE_INT     0x08
#define FDC_SEEK          0x0F
#define FDC_READ_DATA     0x06
#define FDC_READ_ID       0x0A
#define FDC_MFM           0x40  /* set bit 6 for MFM (double density) */

/* byte/word typedefs above — hal.h includes this header */

/* Stringification macros for inline asm constants */
#define STR_(x) #x
#define STR(x)  STR_(x)

/* Memory layout constants */
#define INTVEC_ADDR 0x7000      /* IVT base (page-aligned for Z80 IM2) */
#define INTVEC_PAGE (INTVEC_ADDR >> 8)  /* I register value (0x70) */
#define ROM_STACK   0xBFFF      /* Stack set by ROM entry / INIT_RELOCATED */
#define FLOPPYDATA  0x0000      /* Track 0 loaded here by ROM */
#define COMALBOOT   0x1000      /* COMAL-80 boot address */
#define PROM1_ADDR  0x2000      /* Secondary PROM (network boot) */
#define DIROFF      0x0B60      /* Directory start in Track 0 */
#define DIREND_HI   0x0D        /* Directory end high byte */
#define DSPSTR_ADDR 0x7800      /* Display refresh memory (80x24) */
#define DSP_CHARS   0x0780      /* Display buffer size (1920 bytes) */
#define ATTOFF      7           /* Attribute byte offset in dir entry */
#define SECSZ0      0x80        /* Sector size for Track 0 Side 0 (128B) */

/* Boot signature offsets in Track 0 */
#define RC700_SIG_OFF  0x0002   /* " RC700" signature at offset 2 */
#define RC702_SIG_OFF  0x0008   /* " RC702" signature at offset 8 */
#define BOOT_DIR_OFF   0x0B80   /* Directory area for RC702 format */

/*
 * Boot state — all variables used by the boot ROM.
 *
 * FDC command buffer: curcyl through dtl are contiguous and sent
 * sequentially by flrtrk() as the 7-byte parameter block.
 */
/*
 * Boot state — individual const globals, initialized to zero.
 *
 * Z80: BSS is inside CODE (no separate ORG), so variables are part of
 * the PROM payload — copied to RAM by begin() as zeros.
 */

extern byte fdcres[7];   /* FDC result bytes (ST0-N) */
extern byte fdcflg;      /* FDC flag */
extern byte epts;        /* end-of-track for seek */
extern byte trksz;       /* track size */
extern byte drvsel;      /* drive select */
extern byte fdctmo;      /* FDC timeout counter (init=3) */
extern byte fdcwai;      /* FDC wait count (init=4) */
/* FDC command parameter block — contiguous, sent by flrtrk() */
extern byte curcyl;      /* current cylinder */
extern byte curhed;      /* current head */
extern byte currec;      /* current record/sector */
extern byte reclen;      /* record length (N value) */
extern byte cureot;      /* end of track */
extern byte gap3;        /* gap 3 length */
extern byte dtl;         /* data length */
extern word secbyt;     /* sector byte count */
extern byte flpflg;      /* floppy interrupt flag (0=idle, 2=done) */
extern byte flpwai;      /* floppy wait count (init=4) */
extern byte diskbits;    /* disk type bits */
extern byte dsktyp;      /* disk type flag */
extern byte morefl;      /* more data flag */
extern byte reptim;      /* retry count */
extern word memadr;     /* DMA memory address */
extern word trbyt;      /* transfer byte count */
extern word trkovr;     /* track overflow */
extern byte errsav;      /* saved error code */

/* Display buffer */
#define dspstr         ((byte *)0x7800)
#define scroll_offset  (*(word *)0x7FF5)

/* init.c — peripheral init called from crt0.asm after SP/I/IM2 setup */
void init_peripherals(void);
void init_fdc(void);

/* fmt.c */
void fmtlkp(void);
void calctb(void);

/* fdc.c */
void snsdrv(void);
void flo4(void);
void flo6(void);
void flo7(byte dh, byte cyl);
void rsult(void);
byte recalv(void);         /* returns 0/1/2 */
byte flseek(void);         /* returns 0/1/2 */
void flrtrk(byte cmd);
byte waitfl(byte timeout); /* returns 0=ok, 1=timeout */
byte chkres(void);         /* returns 0/1/2 */
byte readtk(byte cmd, byte retries); /* returns 0=ok, 1=error */
byte dskauto(void);        /* returns 0/1 */
void stpdma(void);

/* boot.c */
void clear_screen(void);
void display_banner(void);
void errdsp(byte code);
byte boot_detect(void);    /* returns 0/1 */
void boot7(void);
void flboot(void);
void check_prom1(void);

/* isr.c */
void crt_refresh(void);

/* halt_msg is a macro in boot.c — must include boot.c or boot.h+boot.c.
 * IMPORTANT: len must NOT include NUL terminator.
 * halt_msg(msg_ptr, byte_count) — copies to display then halts. */

/* Comparison helpers — C in boot.c (pointer-increment avoids IX frame) */
byte b7_cmp6(const byte *a, const byte *b);
byte b7_chksys(const byte *dir, const byte *pattern);

/* Implemented in crt0.asm */
void halt_forever(void);

/* Transfer control to address — never returns.
 * Uses a function pointer call (CALL, not JP).  The dangling return
 * address on the stack is harmless since the target never returns. */
#define jump_to(addr) ((void (*)(void))(addr))()

/* syscall — addr in HL, bc packed as 16-bit in DE */
void syscall(word addr, word bc);

#endif /* BOOT_H */
