/* cpnos-rom relocator linker script.
 *
 * Links reset.s + relocator.c into two 2 KB ROM images matching the
 * RC702's physical EPROM layout: PROM0 at 0x0000, PROM1 at 0x2000.
 *
 * Sections:
 *   .reset       0x0000     reset vector (3 instructions of stack setup)
 *   .text/.rodata            C relocator code + compiler-emitted
 *                            constants.  Lands in PROM0 above .reset.
 *   .prom0_init  0x0100     init.bin — init code+rodata that runs in
 *                            place from PROM 0 (cfgtbl_init,
 *                            init_hardware, print_banner, netboot_mpm).
 *                            See tasks/todo.md "Init/resident split".
 *   .prom0_tail  0x0400     payload_a[] — first chunk of the resident
 *                            payload, copied to RAM 0xED00 by relocate().
 *   .prom1       0x2000     payload_b[] — rest of resident payload in
 *                            PROM1, copied to RAM right after payload_a.
 *
 * Separate from payload.ld by design: this script knows about PROMs,
 * the payload's linker only knows about VMA addresses (0x0100 for
 * init, 0xED00 for resident).
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

  /* C relocator body + compiler-emitted rodata.  Kept below 0x100 by
   * the ASSERT; .prom0_init starts at 0x100. */
  .text : {
    *(.text*)
    *(.rodata*)
  } > PROM0

  __reloc_code_end = .;
  ASSERT(__reloc_code_end <= 0x100,
         "relocator code exceeds 256 B reservation (shrink or raise .prom0_init base)")

  /* Init image -- 0x100..0x3FF.  Bytes are extracted from the payload
   * ELF's .init output section by `objcopy --only-section=.init`,
   * then #embed'd into relocator.c's `init_image[]` and placed here.
   * VMA == LMA so init code's absolute references resolve when it
   * executes in place from PROM. */
  .prom0_init 0x100 : {
    KEEP(*(.prom0_init))
  } > PROM0

  __init_end = .;
  ASSERT(__init_end <= 0x400,
         "init image exceeds 768 B PROM 0 reservation (raise .prom0_tail base)")

  /* Resident payload chunk A — PROM0 tail at 0x0400.  First
   * PROM0_TAIL_SIZE bytes of resident payload.  Makefile's
   * PROM0_TAIL_SIZE must match (0x800 - 0x400 = 1024 bytes
   * available between 0x400 and 0x800). */
  .prom0_tail 0x400 : {
    KEEP(*(.prom0_tail))
  } > PROM0

  /* Resident payload chunk B — all of PROM1.  Integrity checksum is
   * the last 2 bytes of the linked payload.bin (placed there by
   * payload.ld's .payload_checksum section).  After splitting it
   * ends up as the last 2 bytes of payload_b.bin.  No special
   * placement needed here. */
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
