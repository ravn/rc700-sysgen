// Minimal test for z88dk Clang pipeline
#include <stdint.h>

static const char msg[] = "Hello from Clang";
static uint8_t counter;

uint8_t add(uint8_t a, uint8_t b) {
    return a + b;
}

void inc_counter(void) {
    counter++;
}

uint8_t get_counter(void) {
    return counter;
}
