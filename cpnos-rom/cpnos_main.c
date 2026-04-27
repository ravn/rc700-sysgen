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
#include "transport.h"
#include "cpnos_addrs.h"           /* CPNOS_BDOS_ADDR — extracted from cpnos.sym */
#include "clang/cpnos_buildinfo.h" /* BUILD_INFO_STR — regenerated every build */

extern void init_hardware(void);
extern void cfgtbl_init(void);
extern uint8_t snios_ntwkin(void);
extern void enable_interrupts(void);
extern uint8_t snios_jt[24];
extern void jump_to(uint16_t addr) __attribute__((noreturn));
extern void enter_coldst(void) __attribute__((noreturn));

#if defined(PIO_SPEED_TEST) || defined(PIO_LOOPBACK_TEST)
extern void     transport_pio_send_byte(uint8_t c);
extern uint16_t transport_pio_recv_byte(uint16_t timeout_ticks);
extern uint8_t  pio_test_done;            /* defined in transport_pio.c */
#endif

#ifdef PIO_SPEED_TEST
/* Speed test (Option P — bench).  100 * 4 * 256 = 102400 bytes ≈
 * 100 KiB.  Variant selected by PIO_SPEED_TEST value (1/2/3).
 *
 * Three nested uint8_t loops in variants 1+3 sidestep a clang Z80
 * backend bug where uint16_t loop counters get read from an
 * uninitialised static-stack slot rather than the live register
 * (see disasm of the earlier uint16_t-inner version: `ld hl,
 * ($eaXX)` instead of `ld h,b; ld l,c`).  Three 8-bit loops make
 * every counter fit in a single 8-bit register, avoiding the
 * affected codegen path. */
#define PIO_SPEED_OUTER 100
#define PIO_SPEED_MID   4
#define PIO_SPEED_BYTES ((unsigned long)PIO_SPEED_OUTER * \
                         PIO_SPEED_MID * 256UL)

#if PIO_SPEED_TEST == 1
/* Variant 1: TX, C function-call per byte.  Pattern `outer ^
 * inner_low`; verifies the function-call codepath of
 * transport_pio_send_byte. */
static void pio_loopback_test(void) {
    for (uint8_t outer = 0; outer < PIO_SPEED_OUTER; ++outer) {
        for (uint8_t mid = 0; mid < PIO_SPEED_MID; ++mid) {
            uint8_t inner = 0;
            do {
                transport_pio_send_byte((uint8_t)(outer ^ inner));
                ++inner;
            } while (inner != 0);
        }
    }
    pio_test_done = 1;
}
#endif

#if PIO_SPEED_TEST == 2
/* Variant 2: TX, inline OTIR.  Z80's tightest output instruction
 * (`OUT (C),(HL); INC HL; DEC B; JR NZ`, 21 T/byte).  First byte
 * goes through the C path to establish Mode 0; remaining 102399
 * bytes are blasted via inline asm.  Pattern is a 32-byte ramp
 * 0..31 in .rodata (32-byte buffer keeps .data small enough to fit
 * the payload budget, and OTIR-with-B=32 works the same way).
 * Pattern repeats every 32 bytes: byte at offset i = i & 0x1F.
 *
 * 25 outer * 128 mid * 32 inner OTIR = 102400 bytes total. */
const uint8_t pio_speed_buf[32] = {
    0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
   16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31
};

static void pio_loopback_test(void) {
    /* Inline Mode 0 setup + OTIR.  Avoids transport_pio_send_byte's
     * function-call overhead and the extra byte 0 it would emit
     * before OTIR.  3200 OTIR chunks * 32 bytes = 102400 bytes total.
     *
     * 0x03 = ICW: disable IE (Mode 0 STB pulses set m_ip; we re-clear
     *        on Mode 1 entry but here we just want to silence them).
     * 0x0F = mode 0 select (output).
     * The chip's set_mode(MODE_OUTPUT) immediately fires out_pb_cb
     * with m_output (0 after reset) — that leading 0x00 is the
     * documented chip-emulation prefix, stripped on the host side.
     *
     * Per-byte cost:
     *   OTIR  21 T  (per byte)
     *   chunk reload (HL=buf, B=32, dec/jr) ~25 T total per 32-byte chunk
     *   = 21.78 T/byte avg; theoretical 4 MHz / 21.78 = 184 KiB/s. */
    __asm__ volatile(
        /* PIO-B Mode 0 setup */
        "ld   a, 0x03\n\t"            /* ICW: IE disable */
        "out  (0x13), a\n\t"
        "ld   a, 0x0F\n\t"            /* mode 0 select */
        "out  (0x13), a\n\t"
        /* OTIR loop */
        "ld   c, 0x11\n\t"            /* data port */
        "ld   d, 25\n\t"              /* outer chunks */
        "1:\n\t"
        "ld   e, 128\n\t"             /* mid chunks */
        "2:\n\t"
        "ld   hl, _pio_speed_buf\n\t"
        "ld   b, 32\n\t"              /* bytes per OTIR */
        "otir\n\t"
        "dec  e\n\t"
        "jr   nz, 2b\n\t"
        "dec  d\n\t"
        "jr   nz, 1b\n\t"
        : : : "a", "b", "c", "d", "e", "hl", "memory"
    );
    pio_test_done = 1;
}
#endif

#if PIO_SPEED_TEST == 3
/* Variant 3: RX.  ISR-driven; the test simply enables PIO-B input
 * mode and busy-waits for pio_test_done to flip.  isr_pio_par
 * increments uint16_t pio_rx_count per byte and sets pio_test_done
 * on wrap (65536 bytes received).  This bypasses the ring-buffer
 * starvation problem: at high RX rates the chip's BRDY toggle in
 * data_read drives back-to-back strobes, leaving the mainline
 * (recv_byte loop) too few cycles to drain the 32-byte ring.  Just
 * counting in ISR — and signalling done from ISR — measures pure
 * chip+ISR throughput without that bottleneck.
 *
 * Test target: 65536 bytes (= 64 KiB).  Host sends exactly this and
 * waits for pio_test_done. */
static void pio_loopback_test(void) {
    /* Force PIO-B into Mode 1 + IE enabled + IP cleared.  We can't
     * use transport_pio_recv_byte (its first call sets up Mode 1),
     * so do it inline.  Same sequence as transport_pio.c's
     * pio_b_set_input(): mode 1, ICW with mask-follows + IE enable,
     * mask = 0 to atomically clear m_ip. */
    __asm__ volatile(
        "ld   a, 0x4F\n\t"        /* mode 1 input */
        "out  (0x13), a\n\t"
        "ld   a, 0x97\n\t"        /* ICW: enable + mask follows */
        "out  (0x13), a\n\t"
        "ld   a, 0x00\n\t"        /* mask: no PB bits masked */
        "out  (0x13), a\n\t"
        : : : "a"
    );
    /* Busy-wait for ISR to flip pio_test_done after 65536 bytes. */
    while (pio_test_done == 0) { }
}
#endif

#if PIO_SPEED_TEST == 4
/* Variant 4: RX via tight INIR busy-poll, NO interrupts.
 *
 * Host sends [0xAA sentinel byte] + [65536 data bytes].  Z80 polls
 * the data port until it sees 0xAA (consumes the sentinel), then runs
 * INIR for 65536 bytes.  The sentinel gives a clean "start" boundary
 * so we don't time the host-side TCP setup/buffer-fill phase.
 *
 * Z80-PIO Mode 1 input chip behaviour (from MAME z80pio.cpp::data_read):
 *
 *   case MODE_INPUT:
 *     if (!m_stb)
 *       m_input = m_device->m_in_pb_cb(0);   // re-fetch from peripheral
 *     data = m_input;
 *     set_rdy(false);
 *     set_rdy(true);
 *     break;
 *
 * Each CPU IN to the data port:
 *   1. (m_stb is 1 from previous strobe) returns m_input -> latched byte N
 *   2. set_rdy(false); set_rdy(true) toggles BRDY
 *   3. bridge's rdy_w(1) sees rising edge with data, calls strobe_w(0); strobe_w(1)
 *   4. chip strobe(0): m_input = bridge.read() -> pops byte N+1 from FIFO
 *   5. chip strobe(1): trigger_interrupt() (m_ip=true) + set_rdy(false)
 *
 * IE is disabled (0x03) so trigger_interrupt does NOT fire an IRQ —
 * m_ip is set but the chip never asserts INT.  Each subsequent IN
 * returns the freshly latched byte.  Net effect: one byte per IN,
 * no ISR overhead.  Z80 cost is just INIR's 21 T-states/byte =
 * 4 MHz / 21 = 190 KiB/s theoretical.
 *
 * Discard buffer at 0xC000 (TPA region — unused while test runs;
 * NDOS/CCP get re-loaded on warm-boot anyway).  256 chunks of 256
 * bytes each via INIR with B=0 (= 256 iter) gives 65536 bytes
 * total. */
static void pio_loopback_test(void) {
    __asm__ volatile(
        /* PIO-B Mode 1 input, IE disabled, IP cleared.
         * 0x97 + 0x00 (ICW with mask-follows + enable=1) clears m_ip
         * atomically.  Then 0x03 disables IE again — m_ip cleared,
         * m_ie=false, perfect state for busy-poll. */
        "ld   a, 0x4F\n\t"            /* mode 1 input */
        "out  (0x13), a\n\t"
        "ld   a, 0x97\n\t"            /* ICW: mask follows + enable */
        "out  (0x13), a\n\t"
        "ld   a, 0x00\n\t"            /* mask: no PB bits masked */
        "out  (0x13), a\n\t"
        "ld   a, 0x03\n\t"            /* set IE flip-flop = 0 */
        "out  (0x13), a\n\t"

        /* Wait for the host's 0xAA sentinel.  Empty-FIFO reads return
         * 0xFF; busy-spin until something other than 0xFF appears
         * (the sentinel itself).  This consumes the sentinel byte. */
        "2:\n\t"
        "in   a, (0x11)\n\t"
        "cp   0xFF\n\t"
        "jr   z, 2b\n\t"

        /* INIR loop: 256 chunks of 256 bytes -> 65536 data bytes. */
        "ld   c, 0x11\n\t"            /* PIO-B data port */
        "ld   d, 0\n\t"               /* outer chunk counter (0 = 256) */
        "1:\n\t"
        "ld   hl, 0xC000\n\t"         /* discard buffer (TPA, unused) */
        "ld   b, 0\n\t"               /* INIR iterations: 0 = 256 */
        "inir\n\t"                    /* 21 T/byte */
        "dec  d\n\t"
        "jr   nz, 1b\n\t"
        : : : "a", "b", "c", "d", "hl", "memory"
    );
    pio_test_done = 1;
}
#endif

#elif defined(PIO_LOOPBACK_TEST)
/* Bring-up frame test (Option P (3) — design-exploration step).  Sends
 * a 10-byte CP/NET-shaped request frame via PIO-B Mode 0, expects the
 * host to mirror it as a response (FMT toggled to 0x81, DID/SID
 * swapped, payload echoed, checksum recomputed), then validates frame
 * structure on the way back in via Mode 1 input.  Proves the full
 * frame mechanics work over the parallel link before committing to a
 * SNIOS-mirror vs. byte-blast upper-layer shape.
 *
 * Frame layout (CP/NET 1.2 SCB shape, no ENQ/ACK envelope — PIO has
 * hardware handshake that subsumes serial framing reliability):
 *   [0] FMT   0x80 request, 0x81 response
 *   [1] DID   destination ID
 *   [2] SID   source ID
 *   [3] FNC   function code
 *   [4] SIZ   payload length
 *   [5..]     payload (SIZ bytes)
 *   [last]    CKS   sum-to-zero checksum (two's complement of header+payload)
 */

#define PIO_FRAME_LEN 10
static const uint8_t pio_test_request_frame[PIO_FRAME_LEN] = {
    0x80,                        /* FMT: request */
    0x00,                        /* DID: master */
    0x01,                        /* SID: us (matches RC702_SLAVEID) */
    0x05,                        /* FNC: arbitrary, mirrored back */
    0x04,                        /* SIZ: 4-byte payload */
    0xDE, 0xAD, 0xBE, 0xEF,      /* payload */
    0xC4,                        /* CKS: 0x100 - (sum of bytes 0..8) & 0xFF */
};
uint8_t pio_test_recv[PIO_FRAME_LEN];   /* host response lands here (BSS) */
uint8_t pio_test_passed;                /* 1 = frame valid, 0 = invalid (BSS) */

static void pio_loopback_test(void) {
    /* TX: blast the request frame at the host.  No ENQ/ACK envelope
     * because PIO Mode 0/1 hardware handshake guarantees byte
     * delivery; the per-byte STB+BRDY round-trip is the wire-level
     * reliability mechanism. */
    for (uint8_t i = 0; i < PIO_FRAME_LEN; ++i) {
        transport_pio_send_byte(pio_test_request_frame[i]);
    }
    /* RX: drain the response frame.  Each recv polls for ~150 ms
     * emulated (uint16_t max ticks); harness echoes immediately so
     * the first byte arrives well within the first call's budget. */
    for (uint8_t i = 0; i < PIO_FRAME_LEN; ++i) {
        uint16_t r = transport_pio_recv_byte(0xFFFFU);
        pio_test_recv[i] = (uint8_t)r;
    }
    /* Validate response shape and checksum.  ok == 1 only if every
     * field matches the expected mirror semantics. */
    uint8_t sum = 0;
    for (uint8_t i = 0; i < PIO_FRAME_LEN; ++i) sum += pio_test_recv[i];
    uint8_t ok = (pio_test_recv[0] == 0x81)               /* FMT response */
              && (pio_test_recv[1] == 0x01)               /* DID was SID */
              && (pio_test_recv[2] == 0x00)               /* SID was DID */
              && (pio_test_recv[3] == 0x05)               /* FNC echoed */
              && (pio_test_recv[4] == 0x04)               /* SIZ echoed */
              && (pio_test_recv[5] == 0xDE)
              && (pio_test_recv[6] == 0xAD)
              && (pio_test_recv[7] == 0xBE)
              && (pio_test_recv[8] == 0xEF)
              && (sum == 0);                              /* CKS sum-to-zero */
    pio_test_passed = ok;
    pio_test_done = 1;
}
#endif

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
    /* Banner: "RC702 CP/NOS XXX yyyy-mm-dd <hash>\r\n".  XXX is patched
     * in place from active_transport->name (3 chars, not NUL-term).
     * Banner is .data (mutable) so the patch sticks at runtime.
     * Build date + short git hash come from cpnos_buildinfo.h. */
    static char banner[] = "RC702 CP/NOS XXX " BUILD_INFO_STR "\r\n";
    const char *xname = active_transport->name;
    banner[13] = xname[0];
    banner[14] = xname[1];
    banner[15] = xname[2];
    for (const char *p = banner; *p; ++p) impl_conout((uint8_t)*p);

    /* Copy our 17-entry resident BIOS JT (51 B at 0xED00) to NDOSRL +
     * 0x300 = 0xCF00.  NDOS COLDST reads ZP[1..2] = 0xCF03 and walks
     * 0xCF02..0xCF34 in place, replacing slots 1..5 + 15 with NDOS
     * wrapper addresses.  Other slots (BOOT, PUNCH/READER/HOME,
     * SELDSK..WRITE, SECTRAN) keep their resident-JT targets — all
     * unreachable in CP/NOS (cpbdos implements only fn 0..12, no disk
     * dispatch), so they all land harmlessly on bios_stub_ret. */
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

    /* Transport probe.  Try PIO first (Option P fast link); on PONG
     * within ~100 ms emulated, switch active_transport to PIO so
     * netboot + runtime CP/NET both go through the parallel port.
     * On no-PONG, leave active_transport at its default (SIO) and
     * netboot continues over SIO-A async as before. */
    if (transport_pio_vt.probe()) {
        active_transport = &transport_pio_vt;
        BOOT_MARK(7, 'P');             /* PIO transport selected */
    } else {
        BOOT_MARK(7, 'S');             /* SIO fallback (default) */
    }

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

#if defined(PIO_SPEED_TEST) || defined(PIO_LOOPBACK_TEST)
    /* PIO-B bring-up test runs after IRQs are on so the receive ring
     * fills via isr_pio_par.  Skipped if netboot failed — without
     * netboot we can't trust resident state. */
    if (entry != 0) {
        pio_loopback_test();
    }
#endif

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
