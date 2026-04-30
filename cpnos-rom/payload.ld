/* cpnos-rom payload linker script.
 *
 * Everything lives at VMA = LMA = 0xED00 — the final RAM destination
 * of the CP/NOS BIOS + SNIOS + init + netboot code, as a single
 * contiguous blob.  The linker has NO knowledge of the two physical
 * EPROMs (roa375.ic66 at 0x0000, prom1.ic65 at 0x2000).
 *
 * After this ELF is produced:
 *   1. objcopy strips to raw payload.bin (starting at 0xED00).
 *   2. split_proms.py carves it into prom0.bin + prom1.bin.
 *   3. A separate relocator (relocator.s, linked against 0x0000)
 *      sits at PROM0 start, reconstructs this payload in RAM from
 *      both PROMs, then JPs to _cpnos_cold_entry.
 *
 * Why this design:
 *   - Keeps the compiler/linker free of PROM geometry — no AT(),
 *     no LMA-vs-VMA gymnastics, no "which section lands in which
 *     EPROM" decisions leaking into link logic.
 *   - Eliminates a class of bug: switch jump tables (and any other
 *     compiler-emitted .rodata) are at the same address as the code
 *     that references them, because the whole payload relocates
 *     as one unit.  No more "jumptable landed in PROM0 then got
 *     overwritten when TPA came in" footguns.
 *
 * The relocator is expected to copy roughly 4 KB from the two
 * PROMs to 0xED00.  Keep payload size < ~3.9 KB to leave room
 * for the relocator itself.  Hard assert below.
 */

ENTRY(_cpnos_cold_entry)

MEMORY {
  /* Payload: up to 4 KB.  Limited by the combined size of the two
   * 2 KB EPROMs minus the relocator.  Real cap is tracked by the
   * ASSERT below once we have both artifacts. */
  PAYLOAD (rwx) : ORIGIN = 0xED00, LENGTH = 0x1000

  /* Zero-init RAM used by C code (static locals without initializer,
   * runtime-populated tables).  NOT carried in the ROM image — the
   * relocator doesn't touch this region.  Power-on RAM = 0x00 in MAME
   * and typically on real hardware too; real-HW warm boot relies on
   * the prior image having left it in a sensible state. */
  SCRATCH (rwx) : ORIGIN = 0xEA20, LENGTH = 0x1E0   /* ends at 0xEC00 (IVT) */

  /* PIO-B receive ring buffer (.pio_rx_buf section).  Page-aligned
   * 256-byte buffer at 0xF700 — the head/tail are 8-bit so wrap is
   * free (uint8_t arithmetic).  Sits in the unused tail of the
   * payload memory region (0xED00..0xF800).  Hard-asserted to not
   * overlap actual payload code below. */
  PIO_RX (rwx) : ORIGIN = 0xF700, LENGTH = 0x100
}

/* IVT location shared with init.c (setup_ivt).  Defined here so the
 * ASSERTs can check overlap with .payload / .scratch_bss.  Issue #35. */
__ivt_start = 0xEC00;
__ivt_end   = __ivt_start + 18 * 2;

/* PIO ring page address — kept consistent with PIO_RX MEMORY region
 * origin.  isr.c uses _pio_rx_buf_page as a high-byte literal in
 * `ld h, _pio_rx_buf_page` since the GAS-on-Z80 assembler doesn't
 * accept (_pio_rx_buf >> 8) as an immediate. */
_pio_rx_buf_page = 0xF7;

SECTIONS {
  .payload 0xED00 : {
    __payload_start = .;

    /* BIOS jump table MUST come first — its entries are the BIOS's
     * public ABI (BOOT at +0, WBOOT at +3, CONST at +6, ...).  The
     * `.resident.*` section names are historical — keep them so we
     * don't churn every source file; the linker just glues everything
     * into .payload here. */
    KEEP(*(.resident.jumptable))
    KEEP(*(.resident.snios_jt))
    KEEP(*(.resident.snios))
    KEEP(*(.resident.isr))
    *(.resident)
    *(.resident.*)
    KEEP(*(.resident.data))

    /* Everything else — init code, netboot, C helpers, runtime stubs,
     * compiler-emitted rodata (switch tables etc).  All lands at RAM
     * addresses so jumptables resolve correctly after relocation. */
    *(.text.init)
    *(.text.init.*)
    *(.text*)
    *(.rodata*)
    *(.data*)

    /* Pad to a 2-byte boundary so the word-additive sum the
     * relocator computes processes whole words.  Without this,
     * an odd-sized .payload would leave one byte uncovered and
     * the patcher rejects odd-length input. */
    . = ALIGN(2);

    /* Payload integrity checksum — last 2 bytes of the .payload
     * section.  Placeholder is 0xFFFF at link time;
     * cpnos-build/patch_payload_checksum.py overwrites it post-link
     * with the correction value that makes the word-additive sum
     * over the entire .payload equal PAYLOAD_CHECKSUM_MAGIC
     * (0xCAFE).  The relocator (relocator.c) recomputes this sum
     * after copying the payload to RAM and halts on mismatch with
     * "BAD CHECKSUM" displayed.  Catches missing prom1.ic65, bit
     * rot, and version mismatches.  KEEP because the placeholder
     * has no incoming references. */
    __payload_checksum_start = .;
    KEEP(*(.payload_checksum))
    __payload_end = .;
    ASSERT(__payload_end - __payload_checksum_start == 2,
           ".payload_checksum must be exactly 2 bytes")
  } > PAYLOAD

  ASSERT(_bios_boot == 0xED00, "BIOS jump table must start at 0xED00")
  ASSERT(_bios_conout - _bios_boot == 12, "BIOS CONOUT offset must be +12")
  ASSERT(_bios_sectran - _bios_boot == 48, "BIOS SECTRAN offset must be +48")

  /* cpnos-build/src/cpnios-shim.asm pins NDOS's NIOS extern symbol at
   * 0xED33 directly, so NDOS calls land in the resident SNIOS jump
   * table without a runtime memcpy.  If _snios_jt ever drifts, the
   * shim must be updated in lockstep -- this assert turns drift into
   * a build failure with a clear message.  Phase A (2026-04-30). */
  ASSERT(_snios_jt == 0xED33,
         "_snios_jt drifted; update cpnos-build/src/cpnios-shim.asm NIOS EQU")

  __payload_size = __payload_end - __payload_start;

  /* Hard guard: payload must fit in the available ROM space.  Exact
   * budget is (2 * 2048) - relocator_size; relocator.bin tracks the
   * high-water mark and split_proms.py fails if the payload
   * doesn't fit.  Here we just guard the generous upper bound. */
  ASSERT(__payload_size <= 0x1000,
         "payload exceeds 4 KB combined PROM budget")

  /* CRITICAL: payload must NOT overlap display memory at 0xF800.
   * If it did, the relocator would write code/rodata into display RAM
   * at boot, then init_hardware's clear_screen() would wipe it back
   * to spaces — silently corrupting any string literals / const arrays
   * the compiler placed there.  Symptom: "INIT OK" boot marker shows
   * blank, RC702_LOGIN_PWD turns into spaces, signon string vanishes.
   * Catch at link time. */
  ASSERT(__payload_end <= 0xF800,
         "payload overflows into display memory at 0xF800 — shrink it")

  .scratch_bss (NOLOAD) : {
    __scratch_bss_start = .;
    /* Force-keep harness-observed symbols even though their writers
     * (legacy polled-PIO ISR) were removed in commit f10c99f.
     * tests/cpnet_bridge/harness.py treats them as required; without
     * KEEP, ld.lld --gc-sections drops them despite __attribute__((used))
     * on the C declarations. */
    KEEP(*(.bss._pio_par_byte))
    KEEP(*(.bss._pio_par_count))
    *(.bss*)
    *(COMMON)
    __scratch_bss_end = .;
  } > SCRATCH

  ASSERT(__scratch_bss_end <= 0xEC00,
         "scratch_bss overflowed into IVT region!")

  /* PIO-B receive ring (page-aligned at 0xF700). */
  .pio_rx_bss 0xF700 (NOLOAD) : {
    *(.pio_rx_bss)
  } > PIO_RX

#ifdef TRANSPORT_PROXY
  /* TRANSPORT_PROXY mode skips the IRQ ring buffer (transport_pio.c
   * #ifndef TRANSPORT_PROXY around pio_rx_buf etc), so .pio_rx_bss
   * is empty and payload may extend up to display memory at 0xF800. */
  ASSERT(__payload_end <= 0xF800,
         "payload overflows display memory at 0xF800 — shrink it")
#else
  ASSERT(__payload_end <= 0xF700,
         "payload grew into pio_rx_bss region — shrink payload or move buffer")
#endif

  /* Issue #35: IVT must not overlap payload or BSS (memcpy / BSS
   * clear would stomp the vector table). */
  ASSERT(__ivt_end <= __payload_start || __ivt_start >= __payload_end,
         "IVT overlaps .payload")
  ASSERT(__ivt_end <= __scratch_bss_start || __ivt_start >= __scratch_bss_end,
         "IVT overlaps .scratch_bss")

  /DISCARD/ : {
    *(.comment)
    *(.eh_frame*)
    *(.note*)
    *(.addrsig)
  }
}
