/*
 * bios.c — RC702 CP/M BIOS in C (REL30)
 *
 * Phase 1b: CRT display refresh ISR, keyboard input.
 * The CRT ISR programs DMA for 8275 display refresh, increments the RTC,
 * and decrements timers.  Keyboard ISR stores keys in a 16-byte ring buffer.
 *
 * ISRs that switch stacks use __naked wrappers (not __interrupt) because
 * sdcc's __interrupt puts EI at the function START, enabling nested
 * interrupts.  The CRT ISR must run with interrupts disabled to protect
 * DMA programming and the shared sp_sav variable.
 */

#include "hal.h"
#include "bios.h"

/* ================================================================
 * ISR shared state
 * ================================================================ */

static uint16_t sp_sav;           /* saved SP during ISR stack switch */

/* Keyboard ring buffer (REL30) */
static uint8_t kbbuf[KBBUFSZ];
static volatile uint8_t kbhead;   /* write index (ISR updates) */
static volatile uint8_t kbtail;   /* read index (CONIN updates) */

/* Floppy motor stop — stub for now */
static void fdstop(void)
{
    _port_sw1 = 0x00;  /* motor off */
}

/* ================================================================
 * Hardware initialization (called from crt0.asm after relocation)
 * ================================================================ */

void bios_hw_init(void)
{
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

    /* FDC: send SPECIFY command */
    while ((_port_fdc_status & 0x1F) != 0)
        ;  /* wait for FDC ready */
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

    /* Initialize motor timer reload from config */
    stptim_var = cfgstptim;
}

/* ================================================================
 * BIOS entry points
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
    /* Phase 1b: halt */
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

/* ----------------------------------------------------------------
 * Console I/O — keyboard ring buffer (REL30)
 * ---------------------------------------------------------------- */

uint8_t bios_const(void) __naked
{
    __asm
        ld a, (_kbtail)
        ld hl, #_kbhead
        sub a, (hl)
        ret z                   ; 0 = no key
        ld l, #0xFF
        ret
    __endasm;
}

uint8_t bios_conin(void) __naked
{
    __asm
    conin_wait$:
        ld a, (_kbtail)
        ld hl, #_kbhead
        sub a, (hl)
        jr z, conin_wait$       ; spin while empty

        ld hl, #_kbbuf
        ld a, (_kbtail)
        add a, l
        ld l, a                 ; HL = &kbbuf[tail]
        ld c, (hl)              ; read raw key

        ld a, (_kbtail)
        inc a
        and a, #0x0F            ; wrap at 16
        ld (_kbtail), a

        ld hl, #0xF700          ; INCONV table
        ld b, #0
        add hl, bc
        ld l, (hl)
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
 *
 * ISRs needing stack switch use __naked wrappers with explicit
 * register save/restore.  This avoids sdcc's __interrupt putting
 * EI at function entry (which would allow nested interrupts and
 * corrupt the shared sp_sav variable).
 *
 * Simple ISRs (flag-set only, stubs) use __interrupt.
 * ================================================================ */

/* ISR wrappers below use __naked with explicit register save/restore
 * and stack switch to ISTACK (0xF620).  IY saved because sdcc_iy
 * library uses it as a global register. */

/*
 * CRT display refresh ISR body (CTC ch.2)
 *
 * Called ~50 times/sec by the 8275 CRT controller.
 * Programs the DMA controller to refresh the display from DSPSTR (0xF800).
 * Also increments the 32-bit RTC and decrements timers.
 */
static void isr_crt_body(void)
{
    /* Read CRT status register to acknowledge interrupt */
    (void)_port_crt_cmd;

    /* Program DMA for 8275 display refresh */
    _port_dma_smsk = 6;         /* mask DMA ch2 */
    _port_dma_smsk = 7;         /* mask DMA ch3 */
    _port_dma_clbp = 0;         /* clear byte pointer flip-flop */

    /* DMA ch2: display data transfer (2000 bytes from DSPSTR) */
    hal_dma_ch2_addr(DSPSTR);
    hal_dma_ch2_wc(SCRN_SIZE - 1);

    /* DMA ch3: attribute data (zero length) */
    _port_dma_ch3_wc = 0;
    _port_dma_ch3_wc = 0;

    /* Unmask DMA channels */
    _port_dma_smsk = 2;         /* clear ch2 mask */
    _port_dma_smsk = 3;         /* clear ch3 mask */

    /* Reprogram CTC ch2 for next interrupt */
    _port_ctc2 = 0xD7;          /* counter mode */
    _port_ctc2 = 1;             /* count 1 */

    /* Increment 32-bit real-time clock */
    rtc0++;
    if (rtc0 == 0)
        rtc2++;

    /* Timer 0: exit routine countdown */
    if (timer1 != 0) {
        timer1--;
        if (timer1 == 0) {
            /* Call exit routine at warmjp address */
            ((void (*)(void))warmjp)();
        }
    }

    /* Timer 1: floppy motor-off countdown */
    if (timer2 != 0) {
        timer2--;
        if (timer2 == 0)
            fdstop();
    }

    /* General delay timer */
    if (delcnt != 0)
        delcnt--;
}

void isr_crt(void) __naked
{
    __asm
        push af
        push bc
        push de
        push hl
        push iy
        ld (_sp_sav), sp
        ld sp, #0xF620
        call _isr_crt_body
        ld sp, (_sp_sav)
        pop iy
        pop hl
        pop de
        pop bc
        pop af
        ei
        reti
    __endasm;
}

/*
 * Keyboard ISR body (PIO ch.A)
 * Reads keystroke from PIO and stores in 16-byte ring buffer.
 * Must read PIO data port to clear the interrupt even if buffer is full.
 */
static void isr_pio_kbd_body(void)
{
    uint8_t key, new_head;

    key = _port_pio_a_data;     /* read key (clears PIO interrupt) */
    new_head = (kbhead + 1) & KBMASK;
    if (new_head != kbtail) {   /* not full */
        kbbuf[kbhead] = key;
        kbhead = new_head;
    }
    /* if full, keystroke is discarded */
}

void isr_pio_kbd(void) __naked
{
    __asm
        push af
        push bc
        push de
        push hl
        push iy
        ld (_sp_sav), sp
        ld sp, #0xF620
        call _isr_pio_kbd_body
        ld sp, (_sp_sav)
        pop iy
        pop hl
        pop de
        pop bc
        pop af
        ei
        reti
    __endasm;
}

/*
 * Floppy completion ISR (CTC ch.3)
 * Sets completion flag. Full implementation in floppy driver phase.
 */
void isr_floppy(void) __interrupt {}

/* HD ISR stub */
void isr_hd(void) __interrupt {}

/* SIO ISR stubs */
void isr_sio_b_tx(void) __interrupt {}
void isr_sio_b_ext(void) __interrupt {}
void isr_sio_b_spec(void) __interrupt {}
void isr_sio_a_tx(void) __interrupt {}
void isr_sio_a_ext(void) __interrupt {}
void isr_sio_a_rx(void) __interrupt {}
void isr_sio_a_spec(void) __interrupt {}

/* PIO ch.B (parallel output) ISR — not used on RC702 */
void isr_pio_par(void) __interrupt {}
