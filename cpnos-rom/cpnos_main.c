/* cpnos-rom cold-boot driver.
 *
 * Runs entirely from RAM at 0xED00+ after the PROM0 relocator has
 * reconstructed the payload in place.  No more LMA-vs-VMA dance —
 * what the compiler sees is what executes.
 *
 * Entry: _cpnos_cold_entry.  Tail call from relocator.s's `jp`.
 *   1. init_hardware — CTC, SIO-A/B, PIO, DMA, 8275, IM2 IVT.
 *   2. cfgtbl_init  — populate non-zero CFGTBL fields (everything else
 *      stays zero from BSS power-on).
 *   3. netboot       — fetch CCP+NDOS image from the master.
 *   4. PROM disable (OUT 0x18) — safe, we're executing from 0xED00.
 *   5. CP/M zero-page setup (JP WBOOT at 0x0000, JP BDOS at 0x0005).
 *   6. SNIOS — drain SIO RX, seed NETST=ACTIVE.
 *   7. Copy our SNIOS jump table to 0xEA00 where DRI NDOS expects it.
 *   8. Enable interrupts (CRT refresh ISR wakes the display).
 *   9. Jump to CP/NOS entry at 0xD000.
 */

#include <stdint.h>
#include "hal.h"
#include "cpnos_addrs.h"     /* CPNOS_BDOS_ADDR — extracted from cpnos.sym */

extern void init_hardware(void);
extern void cfgtbl_init(void);
extern uint8_t snios_ntwkin(void);
extern void enable_interrupts(void);
extern uint8_t snios_jt[24];
extern void jump_to(uint16_t addr) __attribute__((noreturn));
extern void enter_coldst(void) __attribute__((noreturn));

/* Netboot: two implementations, one selected by SERVER=mpm|proxy in
 * the Makefile.  Default is mpm — standard CP/NET 1.2 LOGIN / OPEN /
 * READ / CLOSE against z80pack MP/M II. */
#ifdef NETBOOT_LEGACY
extern uint16_t netboot(void);
#define NETBOOT() netboot()
#else
extern uint16_t netboot_mpm(void);
#define NETBOOT() netboot_mpm()
#endif

#define NDOS_SNIOS_ADDR  0xEA00  /* NDOS_BASE(0xDE00) + NDOS code_len(0xC00) */

/* Boot orchestration after netboot: signon + BIOS-JT copy + ZP[0..4].
 * Replaces cpbios.asm's `boot:` routine (Phase 2A).  Keeps everything
 * in C so the JT base 0xCF00 / signon string / IOBYTE convention live
 * alongside the impls they coordinate with.
 *
 * cpnos.com's tiny entry stub at 0xD000 finishes ZP setup with ZP[5..7]
 * (= JP BDOS+6, where BDOS's address is a cpnos.com link-time symbol)
 * and falls through to NDOS+3 = COLDST.  See cpnos-build/src/cpnos.asm. */
extern void impl_conout(uint8_t c);

static void nos_handoff(void) {
    static const char signon[] = "RC702 CP/NOS v1.2\r\n";

    /* Print signon via our resident impl directly — the BIOS-JT is
     * still pristine at 0xED00 (NDOS COLDST hasn't walked it yet). */
    for (const char *p = signon; *p; ++p) {
        impl_conout((uint8_t)*p);
    }

    /* Copy our 17-entry resident BIOS JT (51 B at 0xED00) to NDOSRL +
     * 0x300 = 0xCF00.  NDOS COLDST reads ZP[1..2] = 0xCF03 and walks
     * 0xCF02..0xCF34 in place, replacing slots 1..5 + 15 with NDOS
     * wrapper addresses.  Other slots (BOOT, PUNCH/READER/HOME,
     * SELDSK..WRITE, SECTRAN) keep their resident-JT targets, so any
     * disk-style call falls through to our impl_seldsk_null/disk_err. */
    __builtin_memcpy((void *)0xCF00, (const void *)0xED00, 51);

    /* CP/M 2.2 zero page bytes 0..7.  Phase 2B: ZP[5..7] is also set
     * here now (was: cpnos.asm).  BDOS's address is link-time-determined
     * inside cpnos.com; CPNOS_BDOS_ADDR comes from cpnos.sym extraction
     * at PROM build time.
     *   0x0000..0x0002 = JP 0xCF03 (= NDOSRL+0x303 — NDOS's BIOS-JT
     *                    walk target)
     *   0x0003         = IOBYTE = 0 (all TTY)
     *   0x0004         = current drive/user = 0 (A:, user 0)
     *   0x0005..0x0007 = JP CPNOS_BDOS_ADDR (= cpnos.com's BDOSE).
     *                    NDOS COLDST overwrites this with its own
     *                    intercept entry as soon as it runs, so this
     *                    is only the seed CCP would observe before
     *                    COLDST — kept for ABI conformance. */
    static const uint8_t ZP_INIT[8] = {
        0xC3, 0x03, 0xCF,                          /* JP 0xCF03 */
        0x00,                                       /* IOBYTE */
        0x00,                                       /* drive/user */
        0xC3,
        (uint8_t)(CPNOS_BDOS_ADDR & 0xFF),          /* BDOS lo */
        (uint8_t)((CPNOS_BDOS_ADDR >> 8) & 0xFF),   /* BDOS hi */
    };
    const void *src = ZP_INIT;
    void       *dst = (void *)0;
    unsigned    n   = sizeof(ZP_INIT);
    __asm__ volatile("ldir"
        : "+{de}"(dst), "+{hl}"(src), "+{bc}"(n)
        :
        : "memory");
}

[[noreturn]] void cpnos_cold_entry(void) {
    /* PROMs are still mapped at 0x0000..0x07FF and 0x2000..0x27FF;
     * we're running from RAM at 0xED00 so we don't care.  Leave them
     * enabled until step (4) below. */

    cfgtbl_init();
    init_hardware();

    uint16_t entry = NETBOOT();
    BOOT_MARK(15, entry ? '+' : '-');  /* netboot return: + ok, - fail */

    /* Disable the PROMs — exposes RAM underneath for the TPA and
     * netboot-loaded image.  We're at 0xED00; still running fine. */
    _port_out(PORT_RAMEN, 0x00);
    BOOT_MARK(16, 'P');                /* PROMs disabled */

    /* Prime SNIOS: drain SIO RX, seed NETST=ACTIVE, clear SIZ.  NDOS's
     * own NTWKIN may re-run this; idempotent. */
    snios_ntwkin();
    BOOT_MARK(17, 'S');                /* SNIOS primed */

    /* Copy our 24-byte SNIOS jump table to the address where DRI
     * NDOS expects SNIOS to live (= NIOS in cpnos.com link). */
    __builtin_memcpy((void *)NDOS_SNIOS_ADDR, snios_jt, 24);

    enable_interrupts();

    /* Phase 2B: cpnos.asm entry stub deleted.  PROM C does signon +
     * JT copy + ZP[0..7] entirely (nos_handoff above), then enters
     * NDOS COLDST.  enter_coldst lives in resident.c so the
     * "where's COLDST" knowledge has one home (impl_wboot/impl_boot
     * call it too on warm-boot re-entry). */
    if (entry != 0) {
        nos_handoff();
        BOOT_MARK(18, 'J');             /* about to JP NDOS COLDST */
        enter_coldst();
    }
    for (;;) { }
}
