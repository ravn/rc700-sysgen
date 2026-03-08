/*
 * bios.h — RC702 CP/M BIOS declarations
 *
 * Constants, memory layout, and extern declarations for fixed-address
 * variables defined in crt0.asm via DEFC.
 */

#ifndef BIOS_H
#define BIOS_H

#include <stdint.h>

/* Memory layout constants */
#define DSPSTR      0xF800      /* display refresh memory base */
#define SCRNEND     0xFFCF      /* last byte of display RAM */
#define SCRN_COLS   80
#define SCRN_ROWS   25
#define SCRN_SIZE   (SCRN_COLS * SCRN_ROWS)  /* 2000 bytes */

#define OUTCON_ADDR 0xF680      /* output conversion table */
#define INCONV_ADDR 0xF700      /* input conversion table */
#define ISTACK_ADDR 0xF620      /* interrupt stack top */
#define STACK_ADDR  0xF680      /* BIOS driver stack top */

/* CP/M addresses */
#define CCP_BASE    0xC400      /* CCP load address (56K) */
#define BDOS_BASE   0xCC06      /* BDOS entry */
#define BIOS_BASE   0xDA00      /* BIOS jump table */
#define BUFF        0x0080      /* default DMA buffer */
#define IOBYTE_ADDR 0x0003
#define CDISK_ADDR  0x0004
#define NSECTS      176         /* CCP+BDOS length in 128-byte sectors */

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
 * Fixed-address variables (defined in crt0.asm via DEFC)
 * On Z80: these are at absolute addresses in the 0xFFD0-0xFFFF work area.
 * On host: regular globals (TODO: define in hal_host.c)
 */
#ifndef HOST_TEST

extern volatile uint8_t  curx;          /* 0xFFD1: cursor column */
extern volatile uint16_t cury;          /* 0xFFD2: cursor row offset */
extern volatile uint8_t  cursy;         /* 0xFFD4: cursor row number */
extern volatile uint16_t locbuf;        /* 0xFFD5: scroll source pointer */
extern volatile uint8_t  xflg;          /* 0xFFD7: escape state */
extern volatile uint16_t locad;         /* 0xFFD8: screen position */
extern volatile uint8_t  usession;      /* 0xFFDA: char being output */

extern volatile uint8_t  adr0;          /* 0xFFDE: XY escape coordinate */
extern volatile uint16_t timer1;        /* 0xFFDF: warm-boot countdown */
extern volatile uint16_t timer2;        /* 0xFFE1: motor stop countdown */
extern volatile uint16_t delcnt;        /* 0xFFE3: delay timer */
extern volatile uint16_t warmjp;        /* 0xFFE5: exit routine address */
extern volatile uint8_t  fdtimo_var;    /* 0xFFE7: motor-off reload */
extern volatile uint16_t stptim_var;    /* 0xFFEA: motor timer reload */
extern volatile uint16_t clktim;        /* 0xFFEC: clock timer */
extern volatile uint16_t rtc0;          /* 0xFFFC: RTC low word */
extern volatile uint16_t rtc2;          /* 0xFFFE: RTC high word */

/* JTVARS (fixed at 0xDA33+, defined in crt0.asm) */
extern uint8_t  adrmod;        /* 0xDA33 */
extern uint8_t  wr5a;          /* 0xDA34 */
extern uint8_t  wr5b;          /* 0xDA35 */
extern uint8_t  mtype;         /* 0xDA36 */
extern uint8_t  fd0;           /* 0xDA37 (16-byte array) */
extern uint8_t  bootd;         /* 0xDA48 */

#endif /* !HOST_TEST */

/* CONFI config block (in crt0.asm, fixed layout on Track 0) */
extern uint8_t mode0, count0;
extern uint8_t psioa[];        /* 9 bytes */
extern uint8_t psiob[];        /* 11 bytes */
extern uint8_t par1, par2, par3, par4;
extern uint8_t fdprog[];
extern uint8_t xyflg;
extern uint16_t cfgstptim;
extern uint8_t infd0;

#endif /* BIOS_H */
