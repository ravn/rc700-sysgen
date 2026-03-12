/*
 * bios.h — RC702 CP/M BIOS declarations
 *
 * Constants, memory layout, and extern declarations for fixed-address
 * variables defined in crt0.asm via DEFC.
 */

#ifndef BIOS_H
#define BIOS_H

#include <stdint.h>

typedef uint8_t  byte;
typedef uint16_t word;

/* Display memory: 25 rows × 80 columns at 0xF800, refreshed by 8275 CRT.
 * The array type is the single source of truth for all screen dimensions. */
#define DSPSTR      0xF800      /* display refresh memory base */

typedef byte DisplayRow[80];
typedef DisplayRow Display[25];

/* Dimensions derived from the display array type */
#define SCRN_COLS   ((word)sizeof(DisplayRow))          /* 80 */
#define SCRN_ROWS   (sizeof(Display) / sizeof(DisplayRow))  /* 25 */
#define SCRN_SIZE   ((word)sizeof(Display))             /* 2000 */

/* Display access: display[row] is a DisplayRow, display[row][col] is a byte.
 * screen is a flat byte pointer for offset-based access (cury+curx). */
#define display     ((DisplayRow *)DSPSTR)
#define screen      ((byte *)DSPSTR)
#define DISPLAY_ROW(n)  ((byte *)display[n])

/* Cursor coordinate limits (derived from array dimensions) */
#define COLUMN0     0
#define COLUMN79    (SCRN_COLS - 1)             /* 79 */
#define ROW0        0
#define ROW24       (SCRN_ROWS - 1)             /* 24 */
#define ROW0_OFF    0                           /* cury byte offset for row 0 */
#define ROW24_OFFSET   (ROW24 * SCRN_COLS)         /* cury byte offset for row 24 = 1920 */

/*
 * Runtime conversion tables at 0xF680 (384 bytes).
 * Initialized to identity mapping at boot; CONFI.COM may write
 * national character tables to the disk-resident copy (_convta
 * at 0xD580) which can be copied here.
 */
typedef struct {
    byte outcon[128];       /* 0xF680: output conversion */
    byte inconv[256];       /* 0xF700: input conversion */
} ConvTables;

#ifndef HOST_TEST
#define CONV (*(volatile ConvTables *)0xF680)
#else
extern volatile ConvTables _convtables;
#define CONV _convtables
#endif

#define outcon      CONV.outcon
#define inconv      CONV.inconv
#define IVT_ADDR    0xF600      /* interrupt vector table (page-aligned) */
#define ISTACK_ADDR 0xF600      /* interrupt stack top (grows down from IVT) */

/* CP/M addresses */
#define CCP_BASE    0xC400      /* CCP load address (56K) */
#define BDOS_BASE   0xCC06      /* BDOS entry */
#define BIOS_BASE   0xDA00      /* BIOS jump table */
#define BUFF        0x0080      /* default DMA buffer */
#ifdef HOST_TEST
/* Stubs for fixed-address CP/M zero-page variables */
static volatile byte wboot_jp, iobyte, cdisk, bdos_jp;
static volatile word wboot_vec, bdos_vec;
#else
static volatile byte __at(0x0000) wboot_jp;   /* JP opcode */
static volatile word __at(0x0001) wboot_vec;  /* JP WBOOT address */
static volatile byte __at(0x0003) iobyte;
static volatile byte __at(0x0004) cdisk;
static volatile byte __at(0x0005) bdos_jp;    /* JP opcode */
static volatile word __at(0x0006) bdos_vec;   /* JP BDOS address */
#endif
#define NSECTS      44          /* CCP+BDOS length in 128-byte sectors (0x1600/128) */

/* I/O port numbers (for reference; actual I/O via hal.h __sfr) */
#define PORT_PIO_A_DATA 0x10
#define PORT_PIO_A_CTRL 0x12
#define PORT_PIO_B_CTRL 0x13
#define PORT_CTC_CH0    0x0C
#define PORT_SIO_A_CTRL 0x0A
#define PORT_SIO_A_DATA 0x08
#define PORT_SIO_B_CTRL 0x0B
#define PORT_SIO_B_DATA 0x09
#define PORT_FDC        0x04
#define PORT_FDD        0x05
#define PORT_CRT_CMD    0x01
#define PORT_CRT_DATA   0x00
#define PORT_SW1        0x14
#define PORT_DMA_CMD    0xF8
#define PORT_DMA_MODE   0xFB

/* Ring buffer parameters (REL30) */
#define RXBUFSZ     256         /* SIO ring buffer size (page-aligned) */
#define RXMASK      (RXBUFSZ-1)
#define RXTHHI      (RXBUFSZ-8) /* deassert RTS threshold */
#define RXTHLO      (RXBUFSZ-16)/* reassert RTS threshold */
#define KBBUFSZ     16          /* keyboard ring buffer size */
#define KBMASK      (KBBUFSZ-1)

/*
 * Work area struct at 0xFFD0-0xFFFF.
 * Layout matches original BIOS ORG+DS block. Gaps are reserved bytes.
 */
typedef struct {
    byte  _pad0;            /* 0xFFD0: reserved */
    byte  curx;             /* 0xFFD1: cursor column (0-79) */
    word cury;          /* 0xFFD2: cursor row offset (row * 80) */
    byte  cursy;            /* 0xFFD4: cursor row number (0-24) */
    word locbuf;        /* 0xFFD5: scroll source pointer */
    byte  xflg;             /* 0xFFD7: escape state (0=normal) */
    word locad;         /* 0xFFD8: screen position offset */
    byte  usession;         /* 0xFFDA: character being output */
    byte  _pad1[3];         /* 0xFFDB-0xFFDD: gap */
    byte  adr0;             /* 0xFFDE: XY escape first coordinate */
    word timer1;        /* 0xFFDF: warm-boot countdown */
    word timer2;        /* 0xFFE1: motor stop countdown */
    word delcnt;        /* 0xFFE3: delay timer */
    word warmjp;        /* 0xFFE5: exit routine JP target */
    byte  fdtimo_var;       /* 0xFFE7: motor-off reload value */
    byte  _pad2[2];         /* 0xFFE8-0xFFE9: gap */
    word stptim_var;    /* 0xFFEA: motor timer reload */
    word clktim;        /* 0xFFEC: clock/screen-blank timer */
    byte  _pad3[14];        /* 0xFFEE-0xFFFB: gap */
    word rtc0;          /* 0xFFFC: RTC low word */
    word rtc2;          /* 0xFFFE: RTC high word */
} WorkArea;

#ifndef HOST_TEST
#define W (*(volatile WorkArea *)0xFFD0)
#else
extern volatile WorkArea _workarea;
#define W _workarea
#endif

/* Convenience accessors */
#define curx        W.curx
#define cury        W.cury
#define cursy       W.cursy
#define locbuf      W.locbuf
#define xflg        W.xflg
#define locad       W.locad
#define usession    W.usession
#define adr0        W.adr0
#define timer1      W.timer1
#define timer2      W.timer2
#define delcnt      W.delcnt
#define warmjp      W.warmjp
#define fdtimo_var  W.fdtimo_var
#define stptim_var  W.stptim_var
#define clktim      W.clktim
#define rtc0        W.rtc0
#define rtc2        W.rtc2

/*
 * JTVARS — configuration at 0xDA33+ (storage in crt0.asm binary).
 * CONFI.COM and external programs depend on these positions.
 */
typedef struct {
    byte  adrmod;           /* 0xDA33: addressing mode (0=XY, 1=YX) */
    byte  wr5a;             /* 0xDA34: SIO-A WR5 bits/char */
    byte  wr5b;             /* 0xDA35: SIO-B WR5 bits/char */
    byte  mtype;            /* 0xDA36: machine type (0=RC700) */
    byte  fd0[16];          /* 0xDA37-0xDA46: drive format table */
    byte  fd0_term;         /* 0xDA47: terminator (0xFF) */
    byte  bootd;            /* 0xDA48: boot disk (0=floppy) */
} JTVars;

#ifndef HOST_TEST
#define JT (*(volatile JTVars *)0xDA33)
#else
extern volatile JTVars _jtvars;
#define JT _jtvars
#endif

#define adrmod      JT.adrmod
#define wr5a        JT.wr5a
#define wr5b        JT.wr5b
#define mtype       JT.mtype
#define fd0         JT.fd0
#define bootd       JT.bootd

/* CP/M Disk Parameter Block */
typedef struct {
    word spt;               /* sectors per track */
    byte  bsh;                  /* block shift factor */
    byte  blm;                  /* block mask */
    byte  exm;                  /* extent mask */
    word dsm;               /* disk size - 1 (in blocks) */
    word drm;               /* directory entries - 1 */
    byte  al0, al1;             /* allocation bitmap */
    word cks;               /* check vector size */
    word off;               /* track offset */
} DPB;

/* Floppy System Parameters (16 bytes each) */
typedef struct {
    DPB  *dpb;                  /* DPB pointer */
    byte  cpmrbp;               /* records per block */
    word cpmspt;            /* CP/M sectors per track */
    byte  secmsk;               /* sector mask */
    byte  secshf;               /* sector shift */
    byte *trantb;               /* translation table pointer */
    byte  dtlv;                 /* data length value */
    byte  dsktyp;               /* disk type (0=floppy) */
    byte  _pad[5];              /* filler to 16 bytes */
} FSPA;

/* Floppy Disk Format descriptor (8 bytes each) */
typedef struct {
    byte  phys_spt;             /* physical sectors per track */
    word dma_count;         /* DMA byte count */
    byte  mf;                   /* MF flag (0=FM, 64=MFM) */
    byte  n;                    /* sector size code (0=128, 1=256, 2=512) */
    byte  eot;                  /* end of track (last sector number) */
    byte  gap;                  /* gap length */
    byte  tracks;               /* total tracks */
} FDF;

/* Disk tables (defined in bios.c) */
extern const byte tran0[], tran8[], tran16[], tran24[];
extern const DPB dpb0, dpb8, dpb16, dpb24;
extern const FSPA fspa[4];
extern const FDF fdf[4];
extern word trkoff[];

/* Write type constants */
#define WRALL   0   /* write to allocated sector */
#define WRDIR   1   /* write to directory sector */
#define WRUAL   2   /* write to unallocated sector */

/*
 * CONFI configuration block — layout on Track 0 at offset 0x080.
 * Runtime address: 0xD500 (= 0xD480 + 0x080).
 * CONFI.COM reads/writes this block; offsets are ABI.
 * Storage is in crt0.asm; C accesses via fixed-address struct.
 */
typedef struct {
    byte ctc_mode0;         /* +0x00: CTC ch0 mode */
    byte ctc_count0;        /* +0x01: CTC ch0 divisor */
    byte ctc_mode1;         /* +0x02: CTC ch1 mode */
    byte ctc_count1;        /* +0x03: CTC ch1 divisor */
    byte ctc_mode2;         /* +0x04: CTC ch2 mode */
    byte ctc_count2;        /* +0x05: CTC ch2 divisor */
    byte ctc_mode3;         /* +0x06: CTC ch3 mode */
    byte ctc_count3;        /* +0x07: CTC ch3 divisor */
    byte sioa[9];           /* +0x08: SIO-A init block (OTIR to port 0x0A) */
    byte siob[11];          /* +0x11: SIO-B init block (OTIR to port 0x0B) */
    byte dmode[4];          /* +0x1C: DMA channel modes */
    byte par1;              /* +0x20: CRT 8275 chars/row */
    byte par2;              /* +0x21: CRT 8275 rows/frame */
    byte par3;              /* +0x22: CRT 8275 lines/char */
    byte par4;              /* +0x23: CRT 8275 cursor format */
    byte fdprog_len;        /* +0x24: FDC specify length */
    byte fdprog_cmd;        /* +0x25: FDC specify command */
    byte fdprog_srt;        /* +0x26: step rate + head unload */
    byte fdprog_hlt;        /* +0x27: head load + DMA mode */
    byte cursor_num;        /* +0x28: cursor number */
    byte conv_num;          /* +0x29: conv table number */
    byte baud_a;            /* +0x2A: baud rate index A */
    byte baud_b;            /* +0x2B: baud rate index B */
    byte xyflg;             /* +0x2C: addressing mode (0=XY, 1=YX) */
    word stptim;            /* +0x2D: motor stop timer (20ms units) */
    byte infd[17];          /* +0x2F: drive format config (16 + terminator) */
    byte ndtab;             /* +0x40: HD partition count */
    byte ndt1[3];           /* +0x41: HD partition config */
    byte ctc2_mode4;        /* +0x44: CTC2 ch0 mode */
    byte ctc2_count4;       /* +0x45: CTC2 ch0 count */
    byte ctc2_mode5;        /* +0x46: CTC2 ch1 reset */
    byte ibootd;            /* +0x47: boot disk (0=floppy) */
} ConfiBlock;

/* Disk-resident conversion table area (offset 0x100, runtime 0xD580).
 * Same layout as ConvTables — can be memcpy'd to CONV at boot. */
#define CONVTA_ADDR 0xD580

#ifndef HOST_TEST
#define CFG (*(volatile ConfiBlock *)0xD500)
#else
extern volatile ConfiBlock _confiblock;
#define CFG _confiblock
#endif

/* Convenience aliases for frequently accessed CONFI fields */
#define xyflg       CFG.xyflg

#endif /* BIOS_H */
