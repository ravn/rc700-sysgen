/* cpnos-rom resident chunk (Phase 1 seed)
 *
 * Code in this file ends up in the .resident section: VMA at 0xF580 in
 * high RAM, LMA packed into PROM0 immediately after the init code.  The
 * cold-boot path memcpys LMA→VMA, then jumps to resident_entry() at VMA.
 *
 * Rodata / string literals need explicit placement too — see the .rodata
 * handling in the linker script.  For this seed we use inline char
 * constants to sidestep the issue.
 *
 * Phase 1 grows this to contain: BIOS jump table, console I/O, SNIOS
 * message layer, disk-entry stubs, and CFGTBL/DPH tables.
 */

#include <stdint.h>

static volatile uint8_t * const DISPLAY = (volatile uint8_t *)0xF800;

__attribute__((section(".resident"), used))
void resident_entry(void) {
    DISPLAY[0] = 'C';
    DISPLAY[1] = 'P';
    DISPLAY[2] = 'N';
    DISPLAY[3] = 'O';
    DISPLAY[4] = 'S';
    for (;;) { }
}
