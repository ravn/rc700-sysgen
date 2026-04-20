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

/* Linker symbols — clang Z80 prepends one underscore, so C "_x" maps to
 * asm "__x" which matches the linker script's "__x" definitions. */
extern uint8_t _resident_lma[];
extern uint8_t _resident_start[];
extern uint8_t _resident_end[];

extern void resident_entry(void);    /* defined in resident.c, at VMA 0xF580 */
extern void init_hardware(void);     /* defined in init.c, runs from ROM */
extern uint16_t netboot(void);       /* defined in netboot.c, ROM-only */

typedef void (*fn_t)(void);

[[noreturn]] void cpnos_main(void) {
    /* Bring up CTC + SIO-A/B.  (PIO, IVT, DMA, CRT are Phase 2.) */
    init_hardware();

    /* Copy resident section from ROM (LMA) to high RAM (VMA 0xF580+)
     * BEFORE netboot: netboot calls transport_send_byte / recv_byte
     * which live in the resident section at 0xF5xx.  Calling them
     * before the copy lands the CPU in uninitialized RAM (NOP sled). */
    uint8_t *src = _resident_lma;
    uint8_t *dst = _resident_start;
    while (dst < _resident_end) {
        *dst++ = *src++;
    }

    /* Try to netboot.  If a server is present it streams CCP+BDOS into
     * RAM and returns an entry point; if not, recv timeout returns 0. */
    *(volatile uint8_t *)0xE400 = 0xAA;   /* pre-netboot */
    uint16_t entry = netboot();
    *(volatile uint8_t *)0xE401 = 0xBB;   /* post-netboot */

    *(volatile uint8_t *)0xE402 = (uint8_t)(entry & 0xFF);
    *(volatile uint8_t *)0xE403 = (uint8_t)(entry >> 8);

    if (entry != 0) {
        /* Netboot succeeded.  Jump to loaded CCP entry point.  NB:
         * PROM disable still needs to happen; today the resident chunk
         * does it.  We'll move it to happen *before* the CCP jump once
         * netboot is wired end-to-end. */
        ((fn_t)entry)();
    }

    /* No server: fall back to resident banner (diagnostics). */
    resident_entry();

    for (;;) { }
}
