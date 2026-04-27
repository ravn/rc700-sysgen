/* cpnos-rom hardware abstraction — port addresses only
 *
 * Port numbers match the RC702/MIC702 I/O map (see autoload-in-c/rom.h
 * and rcbios-in-c/hal.h for the canonical list).  Reads/writes go
 * through clang's address_space(2) which lowers to IN A,(n) / OUT (n),A.
 */
#ifndef CPNOS_HAL_H
#define CPNOS_HAL_H

#include <stdint.h>

#define __io __attribute__((address_space(2)))

static inline uint8_t _port_in(uint16_t p) {
    return *(volatile __io uint8_t *)p;
}
static inline void _port_out(uint16_t p, uint8_t v) {
    *(volatile __io uint8_t *)p = v;
}

/* Canonical RC702 port map (typed: 1-byte I/O addresses) */
enum : uint8_t {
    PORT_CRT_PARAM    = 0x00,
    PORT_CRT_CMD      = 0x01,
    PORT_FDC_STATUS   = 0x04,
    PORT_FDC_DATA     = 0x05,
    PORT_SIO_A_DATA   = 0x08,
    PORT_SIO_B_DATA   = 0x09,
    PORT_SIO_A_CTRL   = 0x0A,
    PORT_SIO_B_CTRL   = 0x0B,
    PORT_CTC0         = 0x0C,
    PORT_CTC1         = 0x0D,
    PORT_CTC2         = 0x0E,
    PORT_CTC3         = 0x0F,
    PORT_PIO_A_DATA   = 0x10,
    PORT_PIO_B_DATA   = 0x11,
    PORT_PIO_A_CTRL   = 0x12,
    PORT_PIO_B_CTRL   = 0x13,
    PORT_SW1          = 0x14,   /* DIP switch read (not ROM disable) */
    PORT_RAMEN        = 0x18,   /* any write disables both PROMs */
    PORT_BIB          = 0x1C
};

/* SIO RR0 bits (status register 0, shared by both channels) */
enum : uint8_t {
    SIO_RR0_RX_CHAR_AVAIL = 0x01,
    SIO_RR0_TX_BUF_EMPTY  = 0x04,
    SIO_RR0_DCD           = 0x08,
    SIO_RR0_CTS           = 0x20
};

/* 8237 DMA controller — channel 2 = CRT display, channel 3 = CRT attr. */
enum : uint16_t {
    PORT_DMA_CH2_ADDR = 0xF4,
    PORT_DMA_CH2_WC   = 0xF5,
    PORT_DMA_CH3_ADDR = 0xF6,
    PORT_DMA_CH3_WC   = 0xF7,
    PORT_DMA_CMD      = 0xF8,
    PORT_DMA_SMSK     = 0xFA,
    PORT_DMA_MODE     = 0xFB,
    PORT_DMA_CLBP     = 0xFC
};

#define DISPLAY_ADDR 0xF800
#define DISPLAY_SIZE 2000        /* 80 x 25 */

/* Boot-progress marker: write a char to display row 0, right-justified
 * starting at column BOOT_MARK_BASE (=60).  Indices 0..18 occupy cols
 * 60..78 — the upper-right corner.  Call only after init_hardware
 * (CRT alive).  Reserved indices 0..6 = "INIT OK" written by
 * init_hardware; 8..14 by netboot_mpm; 15..18 by cpnos_main.
 *
 * Upper-right placement keeps markers visible after nos_handoff prints
 * the "RC702 CP/NOS v1.2" banner on row 1 and after CCP starts writing
 * its prompt at (0,0) — only a long scroll past row 24 ages them out.
 *
 * The local volatile `_dst` is *not* cosmetic.  Without it clang's
 * Z80 backend folds `((uint8_t*)0xF800)[CONST + const]` as
 * `0xF800 + CONST + const`, dropping any further `+i` runtime offset
 * (UB-class fold — same issue family as ravn/llvm-z80#49).  Forcing
 * the base through a variable defeats the fold. */
#define BOOT_MARK_BASE 60
#define BOOT_MARK(col, ch) do { \
    volatile uint8_t *_dst = (volatile uint8_t *)DISPLAY_ADDR; \
    _dst[BOOT_MARK_BASE + (col)] = (uint8_t)(ch); \
} while (0)

#endif /* CPNOS_HAL_H */
