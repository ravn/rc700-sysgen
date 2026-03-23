/*
 * rc700.h — Types, constants, and port I/O for RC702 bare-metal Z80 code
 *
 * Built with LLVM-Z80 (clang --target=z80 -Os -ffreestanding -nostdlib).
 * Default calling convention is sdcccall(1):
 *   1st i8 in A, 1st i16 in HL
 *   2nd i8 in L, 2nd i16 in DE
 *   return i8 in A, return i16 in DE
 */

#ifndef RC700_H
#define RC700_H

#include <stdint.h>

typedef uint8_t  byte;
typedef uint16_t word;

/* ================================================================
 * Z80 Port I/O — inline IN A,(n) / OUT (n),A (2 bytes each)
 *
 * Port address must be a compile-time constant (immediate operand).
 * Uses GNU C statement expressions for value return.
 * ================================================================ */

/* Two-level stringify to expand macro port constants before # */
#define _STR(x) #x
#define _XSTR(x) _STR(x)

#define port_in(port) \
    ({ byte _v; __asm__ volatile("in a, (" _XSTR(port) ")" : "=a"(_v)); _v; })

#define port_out(port, val) \
    do { byte _v = (val); __asm__ volatile("out (" _XSTR(port) "), a" : : "a"(_v)); } while(0)

/* ================================================================
 * RC702 I/O Ports
 * ================================================================ */

/* Intel 8275 CRT Controller */
#define CRT_PARAM     0x00
#define CRT_CMD       0x01

/* NEC uPD765 Floppy Disk Controller */
#define FDC_STATUS    0x04
#define FDC_DATA      0x05

/* Z80 CTC (Counter/Timer Circuit) */
#define CTC0          0x0C
#define CTC1          0x0D
#define CTC2          0x0E
#define CTC3          0x0F

/* Z80 PIO (Parallel I/O) */
#define PIO_A_DATA    0x10
#define PIO_B_DATA    0x11
#define PIO_A_CTRL    0x12
#define PIO_B_CTRL    0x13

/* Hardware registers */
#define SW1           0x14    /* DIP switch (bit 7 = disk type) */
#define RAMEN         0x18    /* Write 1 to disable ROM overlay */
#define BIB           0x1C    /* Bell/beep */

/* AMD 9517A DMA Controller */
#define DMA_CH1_ADDR  0xF2
#define DMA_CH1_WC    0xF3
#define DMA_CH2_ADDR  0xF4
#define DMA_CH2_WC    0xF5
#define DMA_CH3_ADDR  0xF6
#define DMA_CH3_WC    0xF7
#define DMA_CMD       0xF8
#define DMA_SMSK      0xFA
#define DMA_MODE      0xFB
#define DMA_CLBP      0xFC

/* ================================================================
 * Z80 Intrinsics via inline assembly
 * ================================================================ */

#define z80_di()     __asm__ volatile("di")
#define z80_ei()     __asm__ volatile("ei")
#define z80_halt()   __asm__ volatile("halt")
#define z80_nop()    __asm__ volatile("nop")
#define z80_im2()    __asm__ volatile("im 2")

/* Set I register (interrupt vector page).
 * NOTE: constraint "a" works with --target=z80 but host clangd flags it. */
static inline void z80_set_i(byte page) {
    __asm__ volatile("ld i, a" : : "a"(page));
}

/* Set stack pointer — uses hardcoded immediate since "hl" constraint
 * crashes the LLVM-Z80 IRTranslator (address_space/call bug). */
#define z80_set_sp(addr) __asm__ volatile("ld sp, " #addr)

/* ================================================================
 * Hardware access helpers
 * ================================================================ */

#define read_sw1()         port_in(SW1)
#define diskette_size()    ((port_in(SW1) >> 7) & 1)
#define prom_disable()     port_out(RAMEN, 1)

/* Transfer control to address (never returns) */
#define jump_to(addr)      ((void (*)(void))(addr))()

/* ================================================================
 * Memory layout constants
 * ================================================================ */

#define INTVEC_ADDR   0x7300
#define INTVEC_PAGE   (INTVEC_ADDR >> 8)
#define ROM_STACK     0xBFFF
#define FLOPPYDATA    0x0000
#define COMALBOOT     0x1000
#define PROM1_ADDR    0x2000
#define DSPSTR_ADDR   0x7A00
#define DSP_CHARS     0x0780

#define dspstr        ((volatile byte *)DSPSTR_ADDR)

/* FDC command codes */
#define FDC_SENSE_DRIVE   0x04
#define FDC_RECALIBRATE   0x07
#define FDC_SENSE_INT     0x08
#define FDC_SEEK          0x0F
#define FDC_READ_DATA     0x06
#define FDC_READ_ID       0x0A
#define FDC_MFM           0x40

#endif /* RC700_H */
