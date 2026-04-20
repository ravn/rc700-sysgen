/* cpnos-rom main entry (Phase 0 skeleton)
 *
 * Proof-of-life: write 0x55 to the display memory start so a running
 * system would show a recognisable byte, then OUT (0x18) to disable
 * PROMs, then spin.  No hardware init, no protocol — just verifies the
 * build pipeline produces a sane 4KB image that splits into two 2KB
 * halves for burning.
 *
 * Phase 1 replaces this with: HW init, netboot, resident copy-out,
 * PROM disable, CCP jump.
 */

#include <stdint.h>

static volatile uint8_t * const DISPLAY = (volatile uint8_t *)0xF800;

/* Port I/O via address_space(2) — clang Z80 lowers this to OUT (n),A.
 * Same idiom as autoload-in-c/rom.h. */
#define __io __attribute__((address_space(2)))

static inline void out_ramen(uint8_t v) {
    *(volatile __io uint8_t *)(uint8_t)0x18 = v;
}

void cpnos_main(void) {
    DISPLAY[0] = 0x55;          /* visible once PROM is disabled */
    out_ramen(0x00);            /* OUT (0x18),A  — disable both PROMs */
    for (;;) { }
}
