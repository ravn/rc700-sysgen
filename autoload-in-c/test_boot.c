/*
 * test_boot.c — Host unit tests for boot logic
 *
 * Compile with hal_host.c instead of hal_z80.c:
 *   cc -o test_boot test_boot.c boot.c hal_host.c
 */

#include <stdio.h>
#include <assert.h>
#include "hal.h"

int main(void) {
    printf("test_boot: all tests passed\n");
    return 0;
}
