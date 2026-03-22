// Test calling convention for z88dk clang backend.
// Compile and inspect the generated assembly to see how parameters
// are passed (registers vs stack) and how values are returned.

#include <stdint.h>

// --- Return values ---

uint8_t ret_u8(void) { return 0x42; }
uint16_t ret_u16(void) { return 0x1234; }
uint32_t ret_u32(void) { return 0x12345678UL; }

// --- Single parameter ---

uint8_t pass1_u8(uint8_t a) { return a + 1; }
uint16_t pass1_u16(uint16_t a) { return a + 1; }
uint32_t pass1_u32(uint32_t a) { return a + 1; }

// --- Two parameters ---

uint8_t pass2_u8(uint8_t a, uint8_t b) { return a + b; }
uint16_t pass2_u16(uint16_t a, uint16_t b) { return a + b; }
uint32_t pass2_u32(uint32_t a, uint32_t b) { return a + b; }

// --- Three parameters ---

uint8_t pass3_u8(uint8_t a, uint8_t b, uint8_t c) { return a + b + c; }
uint16_t pass3_u16(uint16_t a, uint16_t b, uint16_t c) { return a + b + c; }

// --- Four parameters ---

uint8_t pass4_u8(uint8_t a, uint8_t b, uint8_t c, uint8_t d) {
    return a + b + c + d;
}

// --- Five parameters ---

uint8_t pass5_u8(uint8_t a, uint8_t b, uint8_t c, uint8_t d, uint8_t e) {
    return a + b + c + d + e;
}

// --- Six parameters ---

uint8_t pass6_u8(uint8_t a, uint8_t b, uint8_t c, uint8_t d,
                 uint8_t e, uint8_t f) {
    return a + b + c + d + e + f;
}

// --- Seven parameters ---

uint8_t pass7_u8(uint8_t a, uint8_t b, uint8_t c, uint8_t d,
                 uint8_t e, uint8_t f, uint8_t g) {
    return a + b + c + d + e + f + g;
}

// --- Pointer parameter ---

void pass_ptr(uint8_t *p) { *p = 0x42; }
uint8_t read_ptr(const uint8_t *p) { return *p; }

// --- Mixed types ---

uint16_t mixed(uint8_t a, uint16_t b, uint8_t c) { return a + b + c; }

// --- Caller side: force actual calls to see call-site code generation ---

volatile uint8_t sink8;
volatile uint16_t sink16;
volatile uint32_t sink32;

void caller_test(void) {
    sink8 = ret_u8();
    sink16 = ret_u16();
    sink32 = ret_u32();

    sink8 = pass1_u8(0x11);
    sink16 = pass1_u16(0x2222);
    sink8 = pass2_u8(0x11, 0x22);
    sink16 = pass2_u16(0x1111, 0x2222);
    sink8 = pass3_u8(0x11, 0x22, 0x33);
    sink8 = pass4_u8(0x11, 0x22, 0x33, 0x44);
    sink8 = pass5_u8(0x11, 0x22, 0x33, 0x44, 0x55);
    sink8 = pass6_u8(0x11, 0x22, 0x33, 0x44, 0x55, 0x66);
    sink8 = pass7_u8(0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77);
    sink16 = mixed(0x11, 0x2222, 0x33);
}
