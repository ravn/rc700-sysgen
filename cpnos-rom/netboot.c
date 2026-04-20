/* cpnos-rom netboot client (DRI Network Boot protocol)
 *
 * Ported from cpnet-z80/src/netboot.asm to C; same wire format, same
 * client state machine.  Runs as *init-only* code from PROM0 — its job
 * ends once CCP+BDOS is in RAM, then cpnos_main hands off to the
 * resident chunk which jumps to the loaded entry point.
 *
 * Wire format (see rc700-gensmedet/cpnet/DRI_PROTOCOL.md):
 *
 *   msg[0] FMT   0xB0 = request, 0xB1 = response
 *   msg[1] DID   destination ID (master = 0x00)
 *   msg[2] SID   source ID (our SLAVEID)
 *   msg[3] FNC   function code (see below)
 *   msg[4] SIZ   payload length (0..255)
 *   msg[5..] DAT payload
 *   msg[N] CKS   additive checksum over the whole thing
 *
 * Server function codes in responses:
 *   1 = load text  (print DAT to console)
 *   2 = set DMA    (DAT[0..1] = target address, little endian)
 *   3 = load 128B  (copy DAT to current DMA, advance DMA by SIZ)
 *   4 = execute    (DAT[0..1] = entry point, return to caller with HL=entry)
 *   0 = NAK        (fatal)
 *
 * This is a *minimum viable* port — no retry loop, no framing beyond
 * the 5-byte header + checksum.  The reference netboot.asm wraps each
 * exchange in SNIOS SNDMSG/RCVMSG which do the ENQ/ACK/SOH/STX dance;
 * we call transport directly for now.  If wire reliability becomes an
 * issue, restore the SNIOS wrapper.
 */

#include <stdint.h>
#include "transport.h"

/* BIOS CONOUT — resident at 0xF20C; already in RAM by the time
 * netboot runs (cpnos_main copies the resident chunk before
 * calling netboot).  Routes to 8275 display + SIO-B. */
extern void impl_conout(uint8_t c);

/* Message buffer offsets. */
enum : uint8_t {
    FMT = 0, DID = 1, SID = 2, FNC = 3, SIZ = 4, DAT = 5
};

/* The DRI frame layout is wire-visible; prevent accidental reordering. */
static_assert(DAT == 5, "DRI message header must be exactly 5 bytes");

/* Max message payload: per DRI spec, SIZ is a byte so ≤255B.
 * cpnet-z80 reference uses 128 + 5 header + 1 CKS = 134.  We allow 256. */
#define MSG_MAX  262
static_assert(MSG_MAX >= 5 + 255 + 1, "msgbuf must hold the largest DRI frame");

/* SLAVEID is baked into CFGTBL.  Provided via -DRC702_SLAVEID=0x70. */
#ifndef RC702_SLAVEID
#define RC702_SLAVEID 0x70
#endif

/* Recv timeout: ~30k polling ticks.  transport_recv_byte returns
 * TRANSPORT_TIMEOUT (0xFFFF) if no byte arrives in time. */
/* Per-byte poll count.  First byte of a response may arrive slowly
 * (network/MAME null_modem buffering), so allow a handful of retries.
 * 50k ticks ≈ 60ms emulated; 4 retries ≈ 240ms emulated, plenty for
 * a localhost round-trip while still short enough to bail out cleanly
 * when no server is present. */
#define RECV_TIMEOUT_TICKS  50000U
#define RECV_RETRIES        8U

static uint8_t msgbuf[MSG_MAX];

/* Send a fully-formed message (header + payload + trailing checksum byte).
 * `n` is the total length including the checksum byte we append here. */
static void send_msg(uint8_t *m, uint16_t n) {
    uint8_t cks = 0;
    for (uint16_t i = 0; i < n - 1; ++i) {
        cks += m[i];
    }
    m[n - 1] = (uint8_t)(0x100 - cks);    /* two's-complement per DRI */
    for (uint16_t i = 0; i < n; ++i) {
        transport_send_byte(m[i]);
    }
}

/* Wait for one byte with retries (extends the effective timeout beyond
 * uint16_t polling ticks). */
static uint16_t recv_byte_retrying(void) {
    for (uint8_t n = 0; n < RECV_RETRIES; ++n) {
        uint16_t r = transport_recv_byte(RECV_TIMEOUT_TICKS);
        if (r != TRANSPORT_TIMEOUT) return r;
    }
    return TRANSPORT_TIMEOUT;
}

/* Receive a message into msgbuf.  Returns total byte count on success,
 * 0 on timeout/checksum-fail. */
static uint16_t recv_msg(void) {
    uint16_t r;
    /* Header is always 5 bytes; read SIZ to learn the payload length. */
    for (uint8_t i = 0; i < 5; ++i) {
        r = recv_byte_retrying();
        if (r == TRANSPORT_TIMEOUT) return 0;
        msgbuf[i] = (uint8_t)r;
    }
    uint8_t siz = msgbuf[SIZ];
    /* Payload + trailing checksum byte. */
    for (uint16_t i = 0; i < (uint16_t)siz + 1; ++i) {
        r = recv_byte_retrying();
        if (r == TRANSPORT_TIMEOUT) return 0;
        msgbuf[5 + i] = (uint8_t)r;
    }
    uint16_t total = 5 + (uint16_t)siz + 1;
    uint8_t sum = 0;
    for (uint16_t i = 0; i < total; ++i) sum += msgbuf[i];
    return (sum == 0) ? total : 0;       /* two's-comp: valid msg sums to 0 */
}

/* Run the netboot loop.  Returns entry point on success (FNC=4),
 * or 0 on error. */
uint16_t netboot(void) {
    uint8_t *dma = nullptr;          /* server sets this via FNC=2 */

    /* Build initial boot-request message: FMT=0xB0, FNC=0, SIZ=0. */
    msgbuf[FMT] = 0xB0;
    msgbuf[DID] = 0x00;
    msgbuf[SID] = RC702_SLAVEID;
    msgbuf[FNC] = 0x00;
    msgbuf[SIZ] = 0x00;
    send_msg(msgbuf, 6);              /* 5 header + 1 checksum */

    for (;;) {
        uint16_t got = recv_msg();
        if (got == 0) return 0;       /* timeout / bad checksum */
        if (msgbuf[FMT] != 0xB1) return 0;

        uint8_t fnc = msgbuf[FNC];
        uint8_t siz = msgbuf[SIZ];

        switch (fnc) {
        case 0:                       /* NAK — fatal */
            return 0;

        case 1:                       /* load text — print via CONOUT */
            for (uint8_t i = 0; i < siz; ++i) {
                impl_conout(msgbuf[DAT + i]);
            }
            break;

        case 2:                       /* set DMA */
            dma = (uint8_t *)(uintptr_t)(msgbuf[DAT] | (msgbuf[DAT + 1] << 8));
            break;

        case 3: {                     /* load data — copy DAT..DAT+SIZ to dma */
            for (uint8_t i = 0; i < siz; ++i) dma[i] = msgbuf[DAT + i];
            dma += siz;
            break;
        }

        case 4: {                     /* execute — return entry point */
            uint16_t entry = msgbuf[DAT] | (msgbuf[DAT + 1] << 8);
            return entry;
        }

        default:
            return 0;                 /* unknown function — abort */
        }

        /* ACK: send FNC=0 SIZ=0 request to get the next chunk. */
        msgbuf[FMT] = 0xB0;
        msgbuf[DID] = 0x00;
        msgbuf[SID] = RC702_SLAVEID;
        msgbuf[FNC] = 0x00;
        msgbuf[SIZ] = 0x00;
        send_msg(msgbuf, 6);
    }
}
