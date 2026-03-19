/* boot_block.c — Boot sector header (BOOT section, offset 0x000-0x07F).
 *
 * Compiled with --codeseg BOOT --constseg BOOT so the header lands
 * at the start of the BOOT section (physical address 0x0000).
 *
 * The autoload ROM reads this 128 byte sector into memory at 0x0000
 * and then looks at the " RC702" signature at offset 8
 * and decides that this is an RC702 system disk.  It considers the first word as the boot pointer and jumps there
 * after loading all of Track 0.
 */

#include "bios.h"
#include "builddate.h"

/* coldboot() in boot_entry.c (BOOT_CODE section) */
extern void coldboot(void);

/* Boot sector header — exactly 128 bytes.
 * Layout must match what the ROA375 autoload PROM expects. */
typedef struct {
    void (*boot_ptr)(void);     /* +0x00: boot pointer (address of coldboot) */
    byte  reserved[6];          /* +0x02: reserved (zeros) */
    char  signature[6];         /* +0x08: " RC702" system signature */
    char  buildinfo[114];       /* +0x0E: build timestamp + padding to 128 */
} BootHeader;

const BootHeader boot_header = {
    .boot_ptr  = coldboot,
    .reserved  = { 0 },
    .signature = " RC702",
    .buildinfo = " C-BIOS " BUILDDATE " /Thorbjoern Ravn Andersen"
};
