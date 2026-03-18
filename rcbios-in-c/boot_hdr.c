/* boot_hdr.c — Boot sector header (BOOT section, offset 0x000-0x07F).
 *
 * Compiled with --codeseg BOOT --constseg BOOT so the header lands
 * at the start of the BOOT section (physical address 0x0000).
 *
 * The ROM reads the first word as the boot pointer and jumps there
 * after loading Track 0.  The " RC702" signature at offset 8
 * identifies the disk as an RC702 system disk.
 */

#include "bios.h"
#include "builddate.h"

/* cboot() in boot_entry.c (BOOT_CODE section) */
extern void cboot(void);

/* Boot sector header — exactly 128 bytes.
 * Layout must match what the ROA375 autoload PROM expects. */
typedef struct {
    void (*boot_ptr)(void);     /* +0x00: boot pointer (address of cboot) */
    byte  reserved[6];          /* +0x02: reserved (zeros) */
    char  signature[6];         /* +0x08: " RC702" system signature */
    char  buildinfo[114];       /* +0x0E: build timestamp + padding to 128 */
} BootHeader;

const BootHeader boot_header = {
    .boot_ptr  = cboot,
    .reserved  = { 0 },
    .signature = " RC702",
    .buildinfo = " C-BIOS " BUILDDATE " /Thorbjoern Ravn Andersen"
};
