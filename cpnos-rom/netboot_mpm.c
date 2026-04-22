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

/* SNIOS C-wrappers from snios.s — pass msg buffer in HL (sdcccall(1)). */
extern uint8_t snios_sndmsg_c(uint8_t *msg);
extern uint8_t snios_rcvmsg_c(uint8_t *msg);
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
 * 0xCC00 is runtime-initialized BSS, not stored in the file).  The
 * 4 KB file is the CODE section, linked at 0xD000.  File offset 0 =
 * memory 0xD000 = `c3 21 df` (JP BIOS).
 * Verified 2026-04-22 by comparing cpnos.com bytes to in-memory
 * layout and observing that offset 0xDF21-0xCC00 = 0x1321 runs past
 * the 4 KB file end — confirming the file covers 0xD000..0xDFD9 not
 * 0xCC00..0xDFD9. */
#define IMG_BASE   ((uint8_t *)0xD000)
#define ENTRY_ADDR 0xD000

/* MP/M II default password on mpm-net2-1.dsk.  Override at build time
 * with -DRC702_LOGIN_PWD='"OTHER   "' (8 chars, space padded). */
#ifndef RC702_LOGIN_PWD
#define RC702_LOGIN_PWD "PASSWORD"
#endif

/* 36-byte FCB for A:CPNOS.IMG (pre-read state: ex=0 cr=0, blank alloc). */
static const uint8_t FCB_TEMPLATE[36] = {
    0x01,                                /* +0  drive A (1-based: 0=default,1=A) */
    'C','P','N','O','S',' ',' ',' ',     /* +1..+8  name (8, space-padded) */
    'I','M','G',                          /* +9..+11 ext */
    0, 0, 0, 0,                          /* +12..+15 ex, s1, s2, rc */
    0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0,  /* +16..+31 alloc map */
    0,                                    /* +32 cr */
    0, 0, 0                              /* +33..+35 r0, r1, r2 */
};

static uint8_t msg[MSG_MAX];

/* Build and send a CP/NET request, then wait for the response.
 * Data must already be in msg[DAT..DAT+dat_len-1].  siz_minus_1 must be
 * dat_len - 1 per DRI convention (SIZ=0 means 1 byte).
 * Returns response retcode (msg[DAT] on success); 0xFE on transport err. */
static uint8_t cpnet_xact(uint8_t fnc, uint8_t siz_minus_1) {
    msg[FMT] = 0x00;
    msg[DID] = 0x00;                 /* to master */
    msg[SID] = 0x01;                 /* our slave ID; SNIOS overwrites from CFGTBL */
    msg[FNC] = fnc;
    msg[SIZ] = siz_minus_1;
    if (snios_sndmsg_c(msg) != 0) return 0xFE;
    if (snios_rcvmsg_c(msg) != 0) return 0xFE;
    return msg[DAT];
}

/* Copy FCB_TEMPLATE into msg request area. */
static void install_fcb(void) {
    msg[DAT] = 0;                    /* user number */
    for (uint8_t i = 0; i < 36; ++i) {
        msg[DAT + 1 + i] = FCB_TEMPLATE[i];
    }
}

/* Rewrite only DAT[0]=user.  FCB is already in msg[DAT+1..DAT+36] from
 * the previous response — caller should not touch it between calls. */
static void reuse_fcb(void) {
    msg[DAT] = 0;                    /* user number */
}

PROM1_CODE
uint16_t netboot_mpm(void) {
    /* Arm SNIOS.  Drains SIO RX and flips CFGTBL.NETST.ACTIVE. */
    if (snios_ntwkin() != 0) return 0;

    /* --- LOGIN ----------------------------------------------------- */
    for (uint8_t i = 0; i < 8; ++i) msg[DAT + i] = RC702_LOGIN_PWD[i];
    if (cpnet_xact(64, 7) != 0) return 0;

    /* --- OPEN A:CPNOS.IMG ----------------------------------------- */
    install_fcb();
    /* BDOS OPEN returns directory code 0..3 on success, 0xFF on
     * not-found; MP/M passes that raw return through (issue #40). */
    if (cpnet_xact(15, 36) >= 0x04) return 0;

    /* --- READ-SEQ loop -------------------------------------------- */
    uint8_t *dma = IMG_BASE;
    for (;;) {
        reuse_fcb();
        uint8_t rc = cpnet_xact(20, 36);
        if (rc == 1) break;          /* EOF */
        if (rc != 0) return 0;       /* error */
        /* Response: DAT[0]=rc, DAT[1..36]=FCB, DAT[37..164]=128B sector. */
        for (uint16_t i = 0; i < 128; ++i) {
            dma[i] = msg[DAT + 37 + i];
        }
        dma += 128;
        impl_conout('.');            /* one dot per 128-byte sector */
        /* Safety: refuse to overflow into BIOS area (now 0xED00+). */
        if (dma >= (uint8_t *)0xEC00) return 0;
    }
    impl_conout(0x0d); impl_conout(0x0a);

    /* --- CLOSE ---------------------------------------------------- */
    reuse_fcb();
    (void)cpnet_xact(16, 36);        /* ignore — file close errors are not fatal */

    return ENTRY_ADDR;
}
