/* cpnos-rom CP/NET configuration table.
 *
 * DRI CFGTBL layout (per cpnet-z80/src/snios.asm:62+):
 *   +0   NETST      Network status byte (0 = offline, 1 = online, plus error bits)
 *   +1   SLAVEID    This node's slave ID (set from RC702_SLAVEID build flag)
 *   +2   A: disk    2 bytes per drive, 16 drives total (A: .. P:), bit 7 of
 *   ...             the low byte = remote-via-network, low nibble = remote drive letter
 *   +34  console    2 bytes, bit 7 = remote console
 *   +36  list       2 bytes, bit 7 = remote list device
 *   +38  bufidx     Buffer index
 *   +39  FMT        outbound message template: 0 (request)
 *   +40  DID        outbound DID: 0 (to master)
 *   +41  SID        outbound SID: 0xFF (SNIOS initialises to our SLAVEID)
 *   +42  FNC        outbound FNC: 5 (LIST)
 *   +43  SIZ        outbound SIZ: 0
 *   +44  MSG[0]     List number (for LST:)
 *   +45..+172  MSGBUF (128-byte message buffer)
 *
 * This is a public ABI — any imported SNIOS object references it by
 * name, and the wire offsets must match the DRI specification.
 */

#include <stdint.h>

#ifndef RC702_SLAVEID
#define RC702_SLAVEID 0x70
#endif

#define RESIDENT_DATA __attribute__((section(".resident.data"), used))

/* Bit 7 of the low byte of each drive slot = "this drive is remote". In
 * CP/NOS all our drives should be remote at boot; keep them local (0) for
 * now until NDOS and SNIOS are actually running. */
#define LOCAL   0x0000

struct cfgtbl {
    uint8_t  netst;                /* +0 */
    uint8_t  slaveid;              /* +1 */
    uint16_t drive[16];            /* +2  A: .. P: */
    uint16_t console;              /* +34 */
    uint16_t list;                 /* +36 */
    uint8_t  bufidx;               /* +38 */
    uint8_t  fmt;                  /* +39 */
    uint8_t  did;                  /* +40 */
    uint8_t  sid;                  /* +41 */
    uint8_t  fnc;                  /* +42 */
    uint8_t  siz;                  /* +43 */
    uint8_t  msg0;                 /* +44 list number */
    uint8_t  msgbuf[128];          /* +45 */
};

static_assert(sizeof(struct cfgtbl) == 173, "CFGTBL layout must be 173 bytes");
static_assert(__builtin_offsetof(struct cfgtbl, slaveid) == 1, "SLAVEID @ +1");
static_assert(__builtin_offsetof(struct cfgtbl, console) == 34, "console @ +34");
static_assert(__builtin_offsetof(struct cfgtbl, fmt) == 39, "FMT @ +39");
static_assert(__builtin_offsetof(struct cfgtbl, sid) == 41, "SID @ +41");
static_assert(__builtin_offsetof(struct cfgtbl, msgbuf) == 45, "MSGBUF @ +45");

RESIDENT_DATA
struct cfgtbl cfgtbl = {
    .netst   = 0x00,            /* offline until NDOS brings us up */
    .slaveid = RC702_SLAVEID,
    .drive   = { LOCAL, LOCAL, LOCAL, LOCAL,
                 LOCAL, LOCAL, LOCAL, LOCAL,
                 LOCAL, LOCAL, LOCAL, LOCAL,
                 LOCAL, LOCAL, LOCAL, LOCAL },
    .console = LOCAL,
    .list    = LOCAL,
    .bufidx  = 0,
    .fmt     = 0x00,
    .did     = 0x00,
    .sid     = 0xFF,            /* SNIOS rewrites to SLAVEID at init */
    .fnc     = 0x05,            /* LIST function */
    .siz     = 0x00,
    .msg0    = 0,
    .msgbuf  = { 0 },
};
