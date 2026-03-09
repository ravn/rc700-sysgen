/* Experimental verification of sdcccall(1) parameter passing.
 * Compile with z88dk sdcc, examine listing for register usage.
 * Each function calls a volatile sink to prevent optimization. */

#include <stdint.h>

/* Volatile sink to prevent dead code elimination */
volatile uint8_t sink8;
volatile uint16_t sink16;

/* === 1 parameter === */

void f_8(uint8_t a) {                   /* expect: a in A */
    sink8 = a;
}

void f_16(uint16_t a) {                 /* expect: a in HL */
    sink16 = a;
}

/* === 2 parameters === */

void f_8_8(uint8_t a, uint8_t b) {      /* expect: a in A, b in L */
    sink8 = a + b;
}

void f_8_16(uint8_t a, uint16_t b) {    /* expect: a in A, b in DE */
    sink8 = a;
    sink16 = b;
}

void f_16_8(uint16_t a, uint8_t b) {    /* expect: a in HL, b on stack? or in register? */
    sink16 = a;
    sink8 = b;
}

void f_16_16(uint16_t a, uint16_t b) {  /* expect: a in HL, b in DE */
    sink16 = a + b;
}

/* === 3 parameters === */

void f_8_8_8(uint8_t a, uint8_t b, uint8_t c) {
    /* expect: a in A, b in L, c on stack */
    sink8 = a + b + c;
}

void f_8_8_16(uint8_t a, uint8_t b, uint16_t c) {
    /* expect: a in A, b in L, c on stack */
    sink8 = a + b;
    sink16 = c;
}

void f_8_16_8(uint8_t a, uint16_t b, uint8_t c) {
    /* expect: a in A, b in DE, c on stack */
    sink8 = a + c;
    sink16 = b;
}

void f_16_16_16(uint16_t a, uint16_t b, uint16_t c) {
    /* expect: a in HL, b in DE, c on stack */
    sink16 = a + b + c;
}

/* === Return values === */

uint8_t ret_8(void) {                   /* expect: return in A */
    return sink8;
}

uint16_t ret_16(void) {                 /* expect: return in DE */
    return sink16;
}

/* === Callers (to see how args are set up) === */

void call_f_8(void) {
    f_8(0x42);
}

void call_f_8_8(void) {
    f_8_8(0x11, 0x22);
}

void call_f_8_16(void) {
    f_8_16(0x11, 0x2233);
}

void call_f_16_8(void) {
    f_16_8(0x1122, 0x33);
}

void call_f_16_16(void) {
    f_16_16(0x1122, 0x3344);
}

void call_f_8_8_8(void) {
    f_8_8_8(0x11, 0x22, 0x33);
}

void call_f_16_16_16(void) {
    f_16_16_16(0x1122, 0x3344, 0x5566);
}
