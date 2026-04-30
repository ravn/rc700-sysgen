/* cpnos-rom CP/NET 1.2 standard bootstrap for MP/M II servers.
 *
 * Replaces netboot.c's custom FMT=0xB0 protocol with a stock DRI CP/NET
 * sequence that works against z80pack cpmsim's mpm-net2 SERVER.RSP with
 * no custom responder code.
 *
 * Wire sequence:
 *   LOGIN  (fn 64)  DAT = 8-byte password
 *   OPEN   (fn 15)  DAT[0]=user, DAT[1..36]=FCB for A:CPNOS.IMG
 *   loop:
 *     READ_SEQ (fn 20)  DAT[0]=user, DAT[1..36]=FCB (updated from prev resp)
 *     response DAT[0]=retcode (0 ok, 1 EOF, 0xFF err)
 *             DAT[1..36]=updated FCB
 *             DAT[37..164]=128-byte sector
 *     copy 128 bytes to growing DMA pointer
 *   CLOSE  (fn 16)
 *
 * Lives in PROM1 (2 KB, currently empty).  Before PROM disable only.
 *
 * Size target: ~500 B.  See tasks/cpnos-next-steps.md for the rationale
 * (session 32/33 retarget onto standard MP/M II).
 */

#include <stdint.h>
#include "hal.h"
#include "transport.h"

/* memcpy from runtime.s — no libc headers in a freestanding build. */
extern void *memcpy(void *dest, const void *src, unsigned int n);

/* SNIOS NTWKIN — drains SIO RX, sets ACTIVE flag.  Always SIO-side
 * because the only thing it does that matters (cfgtbl.NETST = ACTIVE)
 * is transport-agnostic.  PIO has nothing to drain. */
extern uint8_t snios_ntwkin(void);

/* BIOS CONOUT — resident at 0xF20C after cpnos_main copies .resident. */
extern void impl_conout(uint8_t c);

/* Used to live in a dedicated PROM1 section at 0x2000.  Merged into
 * PROM0 in Phase 18 (issue #39) — no longer section-pinned. */
#define PROM1_CODE

/* DRI CP/NET frame header offsets. */
#define FMT 0
#define DID 1
#define SID 2
#define FNC 3
#define SIZ 4
#define DAT 5

/* Biggest response is READ-SEQ: 5 hdr + 1 rc + 36 FCB + 128 data + 1 cks = 171.
 * Round up for safety. */
#define MSG_MAX 200

/* cpnos.com produced by RMAC+LINK is CODE-only (DATA section at
 * NDOSRL is runtime-initialized BSS, not stored in the file).
 * Phase A (2026-04-30) placement:
 *   CODE_BASE = 0xDD80 (NDOS), DATA_BASE = 0xD980 (NDOSRL)
 * The .COM file is the CODE section -- 3085 B linked at 0xDD80
 * and record-padded to 3200 B (0xC80) on disk; file offset 0 =
 * memory CPNOS_NDOS_ADDR.  Source of truth is cpnos.sym (extracted
 * into clang/cpnos_addrs.h as CPNOS_NDOS_ADDR). */
#include "cpnos_addrs.h"
#define IMG_BASE   ((uint8_t *)CPNOS_NDOS_ADDR)
#define ENTRY_ADDR (CPNOS_NDOS_ADDR)

/* MP/M II default password on mpm-net2-1.dsk.  Override at build time
 * with -DRC702_LOGIN_PWD='"OTHER   "' (8 chars, space padded). */
#ifndef RC702_LOGIN_PWD
#define RC702_LOGIN_PWD "PASSWORD"
#endif

/* FCB header for A:CPNOS.IMG (drive + 8.3 name).  Bytes +12..+35
 * are left zero — msg[] lives in BSS so the zero tail is already
 * there, and install_fcb only runs once before any FCB response
 * has overwritten those slots. */
__attribute__((section(".init.rodata")))
static const uint8_t FCB_HEAD[12] = {
    0x01,                                /* +0  drive A (1-based) */
    'C','P','N','O','S',' ',' ',' ',     /* +1..+8  name */
    'I','M','G',                          /* +9..+11 ext */
};

/* msg[] lives in the high scratch region (0xEC24..0xECFF -- the 220 B
 * gap between IVT and payload).  Phase B (2026-04-30): pulled out of
 * the low scratch_bss to free it for cpnos.com's load region, lifting
 * NDOS from 0xDD80 -> 0xDEA0.  The buffer is only used during netboot
 * -- post-netboot, NDOS hands its own buffer pointer to SNDMSG/RCVMSG. */
static uint8_t msg[MSG_MAX] __attribute__((section(".scratch_bss_hi")));

/* Build and send a CP/NET request, then wait for the response.
 * Data must already be in msg[DAT..DAT+dat_len-1].  siz_minus_1 must be
 * dat_len - 1 per DRI convention (SIZ=0 means 1 byte).
 * Returns response retcode (msg[DAT] on success); 0xFE on transport err. */
__attribute__((section(".init.text")))
static uint8_t cpnet_xact(uint8_t fnc, uint8_t siz_minus_1) {
    msg[FMT] = 0x00;
    msg[DID] = 0x00;                 /* to master */
    msg[SID] = 0x01;                 /* our slave ID; SNIOS overwrites from CFGTBL */
    msg[FNC] = fnc;
    msg[SIZ] = siz_minus_1;
    if (cpnet_send_msg(msg) != 0) return 0xFE;
    if (cpnet_recv_msg(msg) != 0) return 0xFE;
    return msg[DAT];
}

/* Copy the 12-byte FCB header into msg.  The 24-byte zero tail is
 * already zero in BSS. */
__attribute__((section(".init.text")))
static void install_fcb(void) {
    msg[DAT] = 0;                    /* user number */
    __builtin_memcpy(&msg[DAT + 1], FCB_HEAD, 12);
}

/* Rewrite only DAT[0]=user.  FCB is already in msg[DAT+1..DAT+36] from
 * the previous response — caller should not touch it between calls. */
__attribute__((section(".init.text")))
static void reuse_fcb(void) {
    msg[DAT] = 0;                    /* user number */
}

__attribute__((section(".init.text")))
uint16_t netboot_mpm(void) {
    BOOT_MARK(8, 'N');               /* entered netboot_mpm */
    /* Arm SNIOS.  Drains SIO RX and flips CFGTBL.NETST.ACTIVE. */
    if (snios_ntwkin() != 0) return 0;
    BOOT_MARK(9, 'I');               /* NTWKIN ok */

    /* --- LOGIN -----------------------------------------------------
     * Direct __builtin_memcpy(8) was unrolled by clang into 4× 16-bit
     * immediate stores (~40 B).  Setting byte 0 manually and memcpying
     * the trailing 7 bytes drops below the unroll threshold and
     * dispatches to the runtime _memcpy stub (LDIR), which is much
     * smaller per call site (the stub itself is shared). */
    msg[DAT] = RC702_LOGIN_PWD[0];
    __builtin_memcpy(&msg[DAT + 1], &RC702_LOGIN_PWD[1], 7);
    if (cpnet_xact(64, 7) != 0) return 0;
    BOOT_MARK(10, 'L');              /* LOGIN ok */

    /* --- OPEN A:CPNOS.IMG ----------------------------------------- */
    install_fcb();
    /* BDOS OPEN returns directory code 0..3 on success, 0xFF on
     * not-found; MP/M passes that raw return through (issue #40). */
    if (cpnet_xact(15, 36) >= 0x04) return 0;
    BOOT_MARK(11, 'O');              /* OPEN ok */

    /* --- READ-SEQ loop -------------------------------------------- */
    uint8_t *dma = IMG_BASE;
    for (;;) {
        reuse_fcb();
        uint8_t rc = cpnet_xact(20, 36);
        if (rc == 1) break;          /* EOF */
        if (rc != 0) return 0;       /* error */
        BOOT_MARK(12, 'R');          /* first/each READ ok (idempotent) */
        /* Response: DAT[0]=rc, DAT[1..36]=FCB, DAT[37..164]=128B sector. */
        __builtin_memcpy(dma, &msg[DAT + 37], 128);
        dma += 128;
        impl_conout('.');            /* one dot per 128-byte sector */
        /* Safety: refuse to overflow into our running scratch BSS lo
         * region (cfgtbl / kbd_ring -- netboot uses those through the
         * READ-SEQ loop).  Phase B (2026-04-30): _msg moved to the
         * high scratch region so the lo region butts against IVT at
         * 0xEC00; cpnos.com loads into 0xDEA0..0xEB20.  Strict `>`:
         * dma == 0xEB20 means the last 128 B sector landed exactly
         * at the limit (loaded into 0xEAA0..0xEB1F), which is fine --
         * the next iteration's READ-SEQ returns EOF and breaks. */
        if (dma > (uint8_t *)0xEB20) return 0;
    }
    BOOT_MARK(13, 'E');              /* EOF reached */
    impl_conout(0x0d); impl_conout(0x0a);

    /* --- print build stamp from last 24 B of payload --------------
     * stamp_cpnos.py wrote 23 ASCII bytes + 0x00 sentinel into the
     * trailing 0x1A padding of cpnos.com.  dma now points one past
     * the last loaded byte, so the stamp lives at dma-24..dma-1. */
    {
        const uint8_t *s = dma - 24;
        for (uint8_t i = 0; i < 23 && s[i] != 0; ++i) impl_conout(s[i]);
        impl_conout(0x0d); impl_conout(0x0a);
    }

    /* --- CLOSE ---------------------------------------------------- */
    reuse_fcb();
    (void)cpnet_xact(16, 36);        /* ignore — file close errors are not fatal */
    BOOT_MARK(14, 'C');              /* CLOSE done */

    return ENTRY_ADDR;
}
