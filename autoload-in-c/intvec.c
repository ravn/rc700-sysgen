/*
 * intvec.c — Z80 IM2 interrupt vector table
 *
 * 16 entries at 0x7000 (page-aligned, I register = 0x70).
 * Placed in INTVEC section via #pragma constseg.
 * Compiled with default codeseg (no --codeseg flag needed).
 */

/* ISR declarations — defined in isr.c */
extern void dumint(void);
extern void crtint(void);
extern void flpint(void);

typedef void (*isr_t)(void);

#pragma constseg CODE

const isr_t intvec[16] = {
    dumint,     /*  +0: Dummy */
    dumint,     /*  +2: PIO Port A */
    dumint,     /*  +4: PIO Port B */
    dumint,     /*  +6: Dummy */
    dumint,     /*  +8: CTC CH0 */
    dumint,     /* +10: CTC CH1 */
    crtint,     /* +12: CTC CH2 — Display refresh */
    flpint,     /* +14: CTC CH3 — Floppy completion */
    dumint,     /* +16: Dummy */
    dumint,     /* +18: Dummy */
    dumint,     /* +20: Dummy */
    dumint,     /* +22: Dummy */
    dumint,     /* +24: Dummy */
    dumint,     /* +26: Dummy */
    dumint,     /* +28: Dummy */
    dumint,     /* +30: Dummy */
};
