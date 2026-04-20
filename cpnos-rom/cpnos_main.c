/* cpnos-rom cold-boot driver (Phase 1 seed)
 *
 * Runs from PROM0 after reset.s sets up the scratch stack.  Phase 1
 * responsibilities (this file grows to meet them):
 *   1. HW init: SIO-A/B, CTC, PIO, IVT stub
 *   2. Netboot: request CCP+BDOS from server, load into RAM
 *   3. Copy resident chunk from ROM (LMA) to RAM (VMA 0xF580)
 *   4. OUT (0x18),A  — disable both PROMs
 *   5. Jump to resident_entry() (or to CCP cold start once netboot works)
 *
 * This seed implements only steps 3, 4, 5 to verify the LMA→VMA copy.
 * Init code runs in place from ROM — no self-relocation hop (unlike the
 * current autoloader which bounces through 0x7000 because it reads
 * Track 0 into 0x0000).  Single-pass relocation: LMA→VMA once.
 */

#include <stdint.h>

#define __io __attribute__((address_space(2)))

static inline void out_ramen(uint8_t v) {
    *(volatile __io uint8_t *)(uint8_t)0x18 = v;
}

/* Linker symbols — clang Z80 prepends one underscore, so C "_x" maps to
 * asm "__x" which matches the linker script's "__x" definitions. */
extern uint8_t _resident_lma[];
extern uint8_t _resident_start[];
extern uint8_t _resident_end[];

extern void resident_entry(void);    /* defined in resident.c, at VMA 0xF580 */

void cpnos_main(void) {
    /* Copy resident section from ROM (LMA) to high RAM (VMA 0xF580+). */
    uint8_t *src = _resident_lma;
    uint8_t *dst = _resident_start;
    while (dst < _resident_end) {
        *dst++ = *src++;
    }

    /* Disable both PROMs.  Past this point, addresses 0x0000-0x07FF and
     * 0x2000-0x27FF are plain RAM.  We already copied what we needed. */
    out_ramen(0x00);

    /* Jump to the resident copy at VMA 0xF580. */
    resident_entry();

    for (;;) { }
}
