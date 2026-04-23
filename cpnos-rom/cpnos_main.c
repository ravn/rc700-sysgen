/* cpnos-rom cold-boot driver (Phase 1 seed)
 *
 * Runs from PROM0 after reset.s sets up the scratch stack.  Phase 1
 * responsibilities (this file grows to meet them):
 *   1. HW init: SIO-A/B, CTC, PIO, IVT stub
 *   2. Netboot: request CCP+BDOS from server, load into RAM
 *   3. Copy resident chunk from ROM (LMA) to RAM (VMA 0xF200)
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

[[noreturn]] extern void resident_entry(uint16_t entry);
extern void init_hardware(void);            /* init.c, runs from ROM */
extern void cfgtbl_init(void);              /* cfgtbl.c, populates BSS */

/* Network bootstrap entry.  Two implementations; only one lands in the
 * link, selected by SERVER=mpm|proxy in the Makefile.  Default is mpm:
 * standard CP/NET 1.2 LOGIN/OPEN/READ/CLOSE against z80pack MP/M II.
 * 'proxy' keeps the legacy FMT=0xB0 protocol for netboot_server.py. */
#ifdef NETBOOT_LEGACY
extern uint16_t netboot(void);              /* netboot.c, PROM0 */
#define NETBOOT() netboot()
#else
extern uint16_t netboot_mpm(void);          /* netboot_mpm.c, PROM1 */
#define NETBOOT() netboot_mpm()
#endif

[[noreturn]] void cpnos_main(void) {
    /* Copy resident section from ROM (LMA) to high RAM (VMA 0xED00..)
     * FIRST: the IVT at 0xF100..0xF123 lives inside this region, and
     * init_hardware's setup_ivt writes there — but memcpy would then
     * overwrite those IVT entries.  Do memcpy first so setup_ivt's
     * writes stick.  (Pre-session-33 RESIDENT at 0xF200+ was above
     * IVT, so the old order worked by accident.) */
    uint8_t *src = _resident_lma;
    uint8_t *dst = _resident_start;
    while (dst < _resident_end) {
        *dst++ = *src++;
    }

    /* Populate cfgtbl's non-zero fields (everything else stays
     * zero from BSS clear). */
    cfgtbl_init();

    /* Bring up CTC + SIO-A/B + IVT + CRT.  IVT lives at 0xEC00
     * (moved from 0xF100 session 33 follow-up, because 0xF100 is now
     * inside .resident code after BIOS_BASE dropped to 0xED00). */
    init_hardware();

    /* Try to netboot.  Server streams CCP+BDOS into RAM and returns an
     * entry point; if absent, recv times out and entry == 0. */
    uint16_t entry = NETBOOT();

    /* Hand off to resident code.  It disables the PROMs (safe from
     * 0xF200 — execution continues from RAM) and either jumps to the
     * loaded entry or falls back to a diagnostic banner.  cpnos_main
     * never runs again after this; the PROM is gone and so is the
     * init code that lives underneath it. */
    resident_entry(entry);
}
