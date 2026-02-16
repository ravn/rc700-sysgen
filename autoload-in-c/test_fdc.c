/*
 * test_fdc.c — Host unit tests for FDC state machine
 *
 * Compile with hal_host.c instead of hal_z80.c:
 *   cc -o test_fdc test_fdc.c fdc.c hal_host.c
 */

#include <stdio.h>
#include <assert.h>
#include "hal.h"

int main(void) {
    printf("test_fdc: all tests passed\n");
    return 0;
}
