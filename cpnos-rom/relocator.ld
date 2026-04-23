/* cpnos-rom relocator linker script.
 *
 * Links reset.s + relocator.c into two 2 KB ROM images matching the
 * RC702's physical EPROM layout: PROM0 at 0x0000, PROM1 at 0x2000.
 *
 * Sections:
 *   .reset       0x0000     reset vector (3 instructions of stack setup)
 *   .text/.rodata            C relocator code + other compiler-emitted
 *                            constants.  Lands in PROM0 above .reset.
 *   .prom0_tail              payload_a[] — the part of the payload that
 *                            piggy-backs on PROM0.  Aligned to 0x80 so
 *                            we have a fixed budget for relocator code.
 *   .prom1       0x2000      payload_b[] — rest of payload in PROM1.
 *
 * Separate from payload.ld by design: this script knows about PROMs,
 * the payload's linker doesn't.  The payload thinks it lives at 0xED00
 * and never worries about ROM geometry.
 */

ENTRY(_reset)

MEMORY {
  PROM0 (rx) : ORIGIN = 0x0000, LENGTH = 0x0800
  PROM1 (rx) : ORIGIN = 0x2000, LENGTH = 0x0800
}

SECTIONS {
  .reset 0x0000 : {
    KEEP(*(.reset))
    KEEP(*(.reset.*))
  } > PROM0

  /* C relocator body + its compiler-emitted rodata (tiny: one call
   * to memcpy twice, one tail call).  Kept below 0x80 by the
   * ASSERT; payload_a[] starts there. */
  .text : {
    *(.text*)
    *(.rodata*)
  } > PROM0

  __reloc_code_end = .;
  ASSERT(__reloc_code_end <= 0x80,
         "relocator code exceeds 128 B reservation (shrink or raise .prom0_tail base)")

  /* Payload chunk A — PROM0 tail.  Fixed base 0x80 so the Makefile
   * can compute payload_a.bin's size without re-linking. */
  .prom0_tail 0x80 : {
    KEEP(*(.prom0_tail))
  } > PROM0

  /* Payload chunk B — all of PROM1. */
  .prom1 0x2000 : {
    KEEP(*(.prom1))
  } > PROM1

  /DISCARD/ : {
    *(.comment)
    *(.eh_frame*)
    *(.note*)
    *(.addrsig)
    *(.bss*)    /* relocator is stateless — no BSS */
    *(.data*)   /* no mutable globals here */
  }
}
