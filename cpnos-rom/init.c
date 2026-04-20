/* cpnos-rom init code (runs in place from PROM0, never copied to RAM).
 *
 * Brings up CTC + SIO-A/B (netboot transport + console) and (session
 * #30) IVT + CTC ch2 + 8237 DMA + 8275 CRT.  Interrupts stay DISABLED
 * throughout init and through netboot; resident_entry enables them
 * after PROM disable so the CRT refresh ISR can fire without racing
 * SIO poll loops.
 */

#include <stdint.h>
#include "hal.h"

/* ISRs + helpers from isr.s. */
extern void isr_crt(void);
extern void isr_noop(void);
extern void set_i_reg(uint8_t page);
extern void enable_im2(void);

#define IVT_ADDR     0xF100
#define IVT_ENTRIES  18

static const uint8_t sio_a_init[] = {
    0x18,           /* WR0: channel reset */
    0x04, 0x44,     /* WR4: x16 clock, 1 stop, no parity */
    0x03, 0xE1,     /* WR3: 8-bit Rx, auto enables, Rx enable */
    0x05, 0x6A,     /* WR5: 8-bit Tx, Tx enable, RTS asserted */
    0x01, 0x00      /* WR1: no interrupts (polled) */
};

static const uint8_t sio_b_init[] = {
    0x18,           /* WR0: channel reset */
    0x02, 0x10,     /* WR2: interrupt vector base 0x10 */
    0x04, 0x44,     /* WR4: x16 clock, 1 stop, no parity */
    0x03, 0xE1,     /* WR3: 8-bit Rx, auto enables, Rx enable */
    0x05, 0x6A,     /* WR5: 8-bit Tx, Tx enable, RTS asserted */
    0x01, 0x00      /* WR1: no interrupts (polled) */
};

static void setup_ivt(void) {
    /* 18 x 16-bit slots at IVT_ADDR (page-aligned).  All slots default
     * to isr_noop; CTC ch2 (slot 2) gets the CRT refresh ISR. */
    volatile uint16_t *ivt = (volatile uint16_t *)IVT_ADDR;
    for (uint8_t i = 0; i < IVT_ENTRIES; ++i) {
        ivt[i] = (uint16_t)(uintptr_t)&isr_noop;
    }
    ivt[2] = (uint16_t)(uintptr_t)&isr_crt;
    set_i_reg(IVT_ADDR >> 8);
    enable_im2();
}

static void init_display(void) {
    /* 8237 DMA: master clear, then set ch2 + ch3 to auto-initialize
     * single-mode mem->IO (bit 4 set = autoinit so each terminal count
     * auto-reloads the programmed address + word count).  This lets
     * the 8275 refresh continuously without an ISR reprogramming DMA
     * every VRTC. */
    _port_out(PORT_DMA_CMD, 0x20);
    _port_out(PORT_DMA_MODE, 0x58 | 2);   /* ch2: display data */
    _port_out(PORT_DMA_MODE, 0x58 | 3);   /* ch3: attributes */

    /* Clear byte-pointer FF and program ch2 base/wc for the display. */
    _port_out(PORT_DMA_CLBP, 0);
    _port_out(PORT_DMA_CH2_ADDR, DISPLAY_ADDR & 0xFF);
    _port_out(PORT_DMA_CH2_ADDR, DISPLAY_ADDR >> 8);
    _port_out(PORT_DMA_CH2_WC,   (DISPLAY_SIZE - 1) & 0xFF);
    _port_out(PORT_DMA_CH2_WC,   (DISPLAY_SIZE - 1) >> 8);
    /* Attribute ch3: WC=0, address unused (no attr bytes). */
    _port_out(PORT_DMA_CH3_WC,   0);
    _port_out(PORT_DMA_CH3_WC,   0);

    /* Unmask ch2 and ch3 so the 8275 can pull bytes each VRTC. */
    _port_out(PORT_DMA_SMSK, 0x02);   /* mask clear ch2 */
    _port_out(PORT_DMA_SMSK, 0x03);   /* mask clear ch3 */

    /* Clear display with spaces so subsequent CONOUT output is
     * readable against a blank background. */
    for (uint16_t i = 0; i < DISPLAY_SIZE; ++i) {
        ((volatile uint8_t *)DISPLAY_ADDR)[i] = ' ';
    }

    /* 8275 CRT: reset + geometry + start.  Constants from
     * rcbios-in-c/boot_confi.c (80x25, 7 scan lines/row). */
    _port_out(PORT_CRT_CMD,   0x00);
    _port_out(PORT_CRT_PARAM, 0x4F);
    _port_out(PORT_CRT_PARAM, 0x98);
    _port_out(PORT_CRT_PARAM, 0x7A);
    _port_out(PORT_CRT_PARAM, 0x6D);   /* CM=01 blink underline,
                                        * 7 lines/row — same as rcbios,
                                        * which is what MAME actually
                                        * animates as a visible blink. */
    _port_out(PORT_CRT_CMD,   0x80);
    _port_out(PORT_CRT_PARAM, 0);
    _port_out(PORT_CRT_PARAM, 0);
    _port_out(PORT_CRT_CMD,   0xE0);
    _port_out(PORT_CRT_CMD,   0x23);
}

void init_hardware(void) {
    /* IVT + IM2 first so any stray interrupt lands on isr_noop rather
     * than the reset vector.  Interrupts stay disabled; resident_entry
     * does EI after PROM disable. */
    setup_ivt();

    /* CTC ch0 vector = 0x00 (applies to ch0..ch3: slots 0..3).
     * ch0/ch1: SIO baud timers.  ch2: CRT refresh (VRTC counter, IRQ
     * armed).  ch3: unused. */
    _port_out(PORT_CTC0, 0x00);
    _port_out(PORT_CTC0, 0x47);
    _port_out(PORT_CTC0, 0x01);
    _port_out(PORT_CTC1, 0x47);
    _port_out(PORT_CTC1, 0x01);
    _port_out(PORT_CTC2, 0xD7);
    _port_out(PORT_CTC2, 0x01);

    for (uint8_t i = 0; i < sizeof(sio_a_init); ++i) {
        _port_out(PORT_SIO_A_CTRL, sio_a_init[i]);
    }
    for (uint8_t i = 0; i < sizeof(sio_b_init); ++i) {
        _port_out(PORT_SIO_B_CTRL, sio_b_init[i]);
    }

    (void)_port_in(PORT_SIO_A_CTRL);
    (void)_port_in(PORT_SIO_B_CTRL);

    init_display();
}
