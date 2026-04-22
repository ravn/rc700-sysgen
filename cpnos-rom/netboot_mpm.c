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

#define PROM1_CODE __attribute__((section(".prom1"), used))

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

/* Where the image lands.  cpnos.com is linked at .cpnos_data = 0xCC00
 * and .cpnos_code = 0xD000; BOOT label of cpnos.o is first byte of code,
 * so entry is 0xD000.  We stream from 0xCC00 upward. */
#define IMG_BASE   ((uint8_t *)0xCC00)
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

/* Breadcrumbs for issue #38 (netboot boot flakiness).  Each step that
 * completes bumps a byte; on failure we return 0 and resident_entry's
 * fallback for(;;) is reached.  0xEC44 records how far we got.
 *   0x01  entered netboot_mpm
 *   0x02  snios_ntwkin succeeded
 *   0x03  LOGIN OK
 *   0x04  OPEN OK
 *   0x05  entered READ-SEQ loop
 *   0x80 | N  last record number successfully copied
 *   0xFE  EOF received -> normal exit
 *   0xFF  CLOSE completed (full success)
 * 0xEC45 records the last retcode (rc) from cpnet_xact. */
#define TRACE_NB_STEP ((volatile uint8_t *)0xEC44)
#define TRACE_NB_RC   ((volatile uint8_t *)0xEC45)

PROM1_CODE
uint16_t netboot_mpm(void) {
    *TRACE_NB_STEP = 0x01;
    /* Arm SNIOS.  Drains SIO RX and flips CFGTBL.NETST.ACTIVE. */
    if (snios_ntwkin() != 0) return 0;
    *TRACE_NB_STEP = 0x02;

    /* --- LOGIN ----------------------------------------------------- */
    for (uint8_t i = 0; i < 8; ++i) msg[DAT + i] = RC702_LOGIN_PWD[i];
    uint8_t rc = cpnet_xact(64, 7);
    *TRACE_NB_RC = rc;
    if (rc != 0) return 0;
    *TRACE_NB_STEP = 0x03;

    /* --- OPEN A:CPNOS.IMG ----------------------------------------- */
    install_fcb();
    rc = cpnet_xact(15, 36);
    *TRACE_NB_RC = rc;
    if (rc != 0) return 0;
    *TRACE_NB_STEP = 0x04;

    /* --- READ-SEQ loop -------------------------------------------- */
    *TRACE_NB_STEP = 0x05;
    uint8_t *dma = IMG_BASE;
    uint8_t rec = 0;
    for (;;) {
        reuse_fcb();
        rc = cpnet_xact(20, 36);
        *TRACE_NB_RC = rc;
        if (rc == 1) break;          /* EOF */
        if (rc != 0) return 0;       /* error */
        /* Response: DAT[0]=rc, DAT[1..36]=FCB, DAT[37..164]=128B sector. */
        for (uint16_t i = 0; i < 128; ++i) {
            dma[i] = msg[DAT + 37 + i];
        }
        dma += 128;
        rec++;
        *TRACE_NB_STEP = (uint8_t)(0x80 | (rec & 0x7F));
        /* Safety: refuse to overflow into BIOS area (now 0xED00+). */
        if (dma >= (uint8_t *)0xEC00) return 0;
    }
    *TRACE_NB_STEP = 0xFE;

    /* --- CLOSE ---------------------------------------------------- */
    reuse_fcb();
    (void)cpnet_xact(16, 36);        /* ignore — file close errors are not fatal */
    *TRACE_NB_STEP = 0xFF;

    return ENTRY_ADDR;
}
