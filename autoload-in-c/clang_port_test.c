// Test z88dk clang backend port I/O using z80_inp/z80_outp library functions.
// These are the intended portable mechanism for I/O across all z88dk backends.
//
// z80_inp(port):        IN L,(C) with BC=port — returns byte from port
// z80_outp(port, data): OUT (C),L with BC=port — writes data to port
//
// Compare with __sfr __at (sdcc only):
//   IN A,(n) / OUT (n),A — 2 bytes inline, no call overhead
//
// z80_inp/z80_outp have function call overhead but work with clang backend.

#include <stdint.h>
#include <z80.h>

// RC702 port addresses
#define PORT_FDC_STATUS 0x04
#define PORT_FDC_DATA   0x05
#define PORT_PIO_A_CTRL 0x12
#define PORT_CRT_PARAM  0x00
#define PORT_CRT_CMD    0x01

uint8_t read_fdc_status(void) {
    return z80_inp(PORT_FDC_STATUS);
}

void write_fdc_data(uint8_t val) {
    z80_outp(PORT_FDC_DATA, val);
}

void init_pio(void) {
    z80_outp(PORT_PIO_A_CTRL, 0xCF);  // mode 3
    z80_outp(PORT_PIO_A_CTRL, 0xFF);  // all inputs
}

void write_crt(uint8_t cmd, uint8_t param) {
    z80_outp(PORT_CRT_PARAM, param);
    z80_outp(PORT_CRT_CMD, cmd);
}
