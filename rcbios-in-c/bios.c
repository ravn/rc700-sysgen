/*
 * bios.c — RC702 CP/M BIOS in C (REL30)
 *
 * Phase 1a: Build skeleton with stub implementations.
 * All BIOS entries return 0 or do nothing.
 * ISRs are minimal (EI + RETI via __interrupt attribute).
 */

#include "hal.h"
#include "bios.h"

/* ================================================================
 * Hardware initialization (called from crt0.asm after relocation)
 * ================================================================ */

void bios_hw_init(void)
{
    /* Phase 1a stub: hardware init will be added in Phase 1b */

    /* PIO: set interrupt vectors and modes */
    _port_pio_a_ctrl = 0x20;    /* PIO-A interrupt vector */
    _port_pio_b_ctrl = 0x22;    /* PIO-B interrupt vector */
    _port_pio_a_ctrl = 0x4F;    /* PIO-A input mode */
    _port_pio_b_ctrl = 0x0F;    /* PIO-B output mode */
    _port_pio_a_ctrl = 0x83;    /* PIO-A enable interrupt */
    _port_pio_b_ctrl = 0x83;    /* PIO-B enable interrupt */

    /* CTC: set interrupt vector and program all channels */
    _port_ctc0 = 0x00;         /* CTC interrupt vector */
    _port_ctc0 = mode0;        /* ch0 mode */
    _port_ctc0 = count0;       /* ch0 count (38400 baud) */
    _port_ctc1 = *((&mode0) + 2);  /* ch1 mode */
    _port_ctc1 = *((&mode0) + 3);  /* ch1 count */
    _port_ctc2 = *((&mode0) + 4);  /* ch2 mode (display) */
    _port_ctc2 = *((&mode0) + 5);  /* ch2 count */
    _port_ctc3 = *((&mode0) + 6);  /* ch3 mode (floppy) */
    _port_ctc3 = *((&mode0) + 7);  /* ch3 count */

    /* SIO: program via OTIR — use inline asm for the block output */
    __asm
        ld hl, _psioa
        ld b, #9
        ld c, #0x0A
        otir
        ld hl, _psiob
        ld b, #11
        ld c, #0x0B
        otir
    __endasm;

    /* SIO: read initial status registers */
    (void)_port_sio_a_ctrl;     /* read RR0-A */
    _port_sio_a_ctrl = 1;       /* select RR1 */
    (void)_port_sio_a_ctrl;     /* read RR1-A */
    (void)_port_sio_b_ctrl;     /* read RR0-B */
    _port_sio_b_ctrl = 1;       /* select RR1 */
    (void)_port_sio_b_ctrl;     /* read RR1-B */

    /* DMA: enter command mode and set channel modes */
    _port_dma_cmd = 0x20;       /* master clear */
    _port_dma_mode = 0x48;      /* ch0 mode (HD) */
    _port_dma_mode = 0x4A;      /* ch2 mode (display) */
    _port_dma_mode = 0x4B;      /* ch3 mode (display) */

    /* FDC: check mini/maxi and send SPECIFY command */
    /* (simplified for Phase 1a — full version needs mini detection) */
    while ((_port_fdc_status & 0x1F) != 0)
        ;  /* wait for FDC ready */
    /* Send SPECIFY: 03h, DFh, 28h */
    while ((_port_fdc_status & 0xC0) != 0x80)
        ;
    _port_fdc_data = 0x03;      /* SPECIFY command */
    while ((_port_fdc_status & 0xC0) != 0x80)
        ;
    _port_fdc_data = 0xDF;      /* step rate 3ms, head unload 240ms */
    while ((_port_fdc_status & 0xC0) != 0x80)
        ;
    _port_fdc_data = 0x28;      /* head load 40ms, DMA mode */

    /* Clear display buffer (fill 0xF800-0xFFCF with spaces) */
    __asm
        ld hl, #0xF800
        ld de, #0xF801
        ld bc, #0x07CF
        ld (hl), #0x20
        ldir
    __endasm;

    /* Clear work area (0xFFD1-0xFFFF with zeros) */
    __asm
        ld hl, #0xFFD1
        ld de, #0xFFD2
        ld (hl), #0
        ld bc, #0x002E
        ldir
    __endasm;

    /* CRT 8275: reset and program */
    _port_crt_cmd = 0x00;       /* reset */
    _port_crt_param = par1;     /* chars/row */
    _port_crt_param = par2;     /* rows/frame */
    _port_crt_param = par3;     /* lines/char + underline */
    _port_crt_param = par4;     /* cursor format */
    _port_crt_cmd = 0x80;       /* load cursor position */
    _port_crt_param = 0;        /* cursor X = 0 */
    _port_crt_param = 0;        /* cursor Y = 0 */
    _port_crt_cmd = 0xE0;       /* preset counters */
    _port_crt_cmd = 0x23;       /* start display */

    /* Initialize runtime variables */
    wr5a = psioa[6] & 0x60;    /* SIO-A bits/char from WR5 */
    wr5b = psiob[8] & 0x60;    /* SIO-B bits/char from WR5 */
    adrmod = xyflg;             /* copy addressing mode */
}

/* ================================================================
 * BIOS entry points — Phase 1a stubs
 * ================================================================ */

void bios_boot(void) __naked
{
    __asm
        ld sp, #0x0080          ; use DMA buffer as stack
        jp _bios_boot_c
    __endasm;
}

void bios_boot_c(void)
{
    /* Phase 1a: just halt — no signon, no CCP load yet */
    __asm
        di
        halt
    __endasm;
}

void bios_wboot(void)
{
    __asm
        di
        halt
    __endasm;
}

uint8_t bios_const(void) __naked
{
    __asm
        ld l, #0                ; no char ready
        ret
    __endasm;
}

uint8_t bios_conin(void) __naked
{
    __asm
        ld l, #0x0D             ; return CR
        ret
    __endasm;
}

void bios_conout(uint8_t c) __naked
{
    (void)c;
    __asm
        ret                     ; stub: discard output
    __endasm;
}

void bios_list(uint8_t c) __naked
{
    (void)c;
    __asm
        ret
    __endasm;
}

void bios_punch(uint8_t c) __naked
{
    (void)c;
    __asm
        ret
    __endasm;
}

uint8_t bios_reader(void) __naked
{
    __asm
        ld l, #0x1A             ; return ^Z (EOF)
        ret
    __endasm;
}

void bios_home(void) __naked
{
    __asm
        ret
    __endasm;
}

uint16_t bios_seldsk(uint8_t disk) __naked
{
    (void)disk;
    __asm
        ld hl, #0               ; return NULL (error)
        ret
    __endasm;
}

void bios_settrk(uint16_t track) __naked
{
    (void)track;
    __asm
        ret
    __endasm;
}

void bios_setsec(uint16_t sector) __naked
{
    (void)sector;
    __asm
        ret
    __endasm;
}

void bios_setdma(uint16_t addr) __naked
{
    (void)addr;
    __asm
        ret
    __endasm;
}

uint8_t bios_read(void) __naked
{
    __asm
        ld l, #1                ; return error
        ret
    __endasm;
}

uint8_t bios_write(uint8_t type) __naked
{
    (void)type;
    __asm
        ld l, #1                ; return error
        ret
    __endasm;
}

uint8_t bios_listst(void) __naked
{
    __asm
        ld l, #0xFF             ; list device ready
        ret
    __endasm;
}

uint16_t bios_sectran(uint16_t sector) __naked
{
    (void)sector;
    __asm
        ; return BC in HL (no translation)
        ld h, b
        ld l, c
        ret
    __endasm;
}

/* Extended entries */

void bios_wfitr(void) __naked
{
    __asm
        ret
    __endasm;
}

uint8_t bios_reads(void) __naked
{
    __asm
        ld l, #0                ; not ready
        ret
    __endasm;
}

void bios_linsel(void) __naked
{
    __asm
        ret
    __endasm;
}

void bios_exit(void) __naked
{
    __asm
        ret
    __endasm;
}

void bios_clock(void) __naked
{
    __asm
        ret
    __endasm;
}

void bios_hrdfmt(void) __naked
{
    __asm
        ret
    __endasm;
}

/* ================================================================
 * Interrupt service routines
 * All use __interrupt attribute: saves AF/BC/DE/HL, ends with EI+RETI
 * ================================================================ */

void isr_crt(void) __interrupt
{
    /* Phase 1a stub: CRT refresh ISR
     * Must program DMA for 8275 display refresh — without this,
     * the screen stays blank. Full implementation in Phase 1b. */
}

void isr_floppy(void) __interrupt
{
    /* Phase 1a stub: set completion flag */
}

void isr_hd(void) __interrupt
{
    /* HD ISR stub */
}

void isr_sio_b_tx(void) __interrupt {}
void isr_sio_b_ext(void) __interrupt {}
void isr_sio_b_spec(void) __interrupt {}
void isr_sio_a_tx(void) __interrupt {}
void isr_sio_a_ext(void) __interrupt {}
void isr_sio_a_rx(void) __interrupt {}
void isr_sio_a_spec(void) __interrupt {}
void isr_pio_kbd(void) __interrupt {}
void isr_pio_par(void) __interrupt {}
