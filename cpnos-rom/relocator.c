/* cpnos-rom PROM relocator (C23).
 *
 * Reconstructs the CP/NOS resident payload at RAM `bios_boot` from
 * two #embed'd binary chunks that sit in PROM0 tail and PROM1, then
 * tail-calls the payload's cold entry.  Init code (init.bin) is
 * embedded separately at PROM 0 0x0100 and runs in place -- it is
 * NOT copied to RAM.  See tasks/todo.md "Init/resident split".
 *
 * Why two chunks for the resident?  The Z80 maps PROM0 at
 * 0x0000..0x07FF and PROM1 at 0x2000..0x27FF, with a 6 KB address
 * hole in between.  The resident is a single contiguous blob; the
 * build splits payload.bin (resident bytes only) into payload_a.bin
 * (PROM0 tail) and payload_b.bin (PROM1), each #embed'd into its own
 * linker-placed section.
 *
 * Entry flow:
 *   reset.s (at 0x0000) DI + SP + jp _relocate  ->  this function
 *   relocate() memcpys payload_a then payload_b -> _cpnos_cold_entry
 *
 * cpnos_cold_entry runs from RAM and calls cfgtbl_init /
 * init_hardware / print_banner / netboot_mpm at PROM addresses
 * (0x0100..0x03FF) -- those run in place from PROM until PROM
 * disable.
 *
 * The destination RAM address (`bios_boot`) and the payload's cold
 * entry address (`_cpnos_cold_entry`) are both resolved at link time
 * via --defsym from payload.elf -- the Makefile extracts them with
 * llvm-nm.  Hardcoding either was previously a footgun (Path 3
 * BIOS_BASE move silently broke boot because the relocator copied to
 * the old 0xED00 instead of the new 0xEE00); the link-time defsym
 * removes the duplication.
 */
#include <stdint.h>

/* Payload cold-entry symbol.  Defined in the payload ELF; supplied to
 * this link via `--defsym _cpnos_cold_entry=0x...` (see Makefile). */
extern void cpnos_cold_entry(void) __attribute__((noreturn));

/* Resident-payload destination address in RAM (= BIOS_BASE in
 * payload.ld).  Declared as a flat byte array so `bios_boot` decays
 * to a uint8_t* whose value is the link-time-defined address.
 * Supplied via `--defsym _bios_boot=0x...` from payload.elf at
 * relocator link time, mirroring _cpnos_cold_entry.  Touch this
 * symbol's value (or any of the C uses below) and the build fails
 * cleanly -- never silently misroutes the memcpy.  Z80 ABI prepends
 * `_` to C symbols, so the C-visible name is `bios_boot` and the
 * linker symbol is `_bios_boot`. */
extern uint8_t bios_boot[];

/* Init image: lives at PROM 0 0x0100 -- linked at the same VMA as
 * the .init output section in payload.elf so absolute references
 * inside init code resolve.  Never copied to RAM; runs in place
 * from PROM until PROM disable.  See tasks/todo.md, step 3. */
__attribute__((section(".prom0_init"), used))
static const uint8_t init_image[] = {
#embed "clang/init.bin" if_empty(0)
};

/* Chunk A: first PROM0_TAIL_SIZE bytes of resident payload.  Lives
 * in PROM0 tail, placed by relocator.ld at 0x0400 (after .reset +
 * relocator code + .prom0_init).  The Makefile keeps PROM0_TAIL_SIZE
 * in sync with the relocator.ld base. */
__attribute__((section(".prom0_tail"), used))
static const uint8_t payload_a[] = {
#embed "clang/payload_a.bin" if_empty(0)
};

/* Chunk B: remaining resident payload bytes.  Lives in PROM1 at 0x2000. */
__attribute__((section(".prom1"), used))
static const uint8_t payload_b[] = {
#embed "clang/payload_b.bin" if_empty(0)
};

/* Magic constant: the word-additive sum (treating the payload as
 * a sequence of little-endian 16-bit words) of the entire relocated
 * payload — including the correction word patched into its tail
 * by cpnos-build/patch_payload_checksum.py — must equal this value.
 * Word-additive instead of byte-additive so a 2-byte correction
 * can hit any 16-bit target.  Change here AND in the patcher if
 * you ever want a different magic. */
#define PAYLOAD_CHECKSUM_MAGIC 0xCAFE

/* "BAD CHECKSUM" message copied into display memory at 0xF800 when
 * the integrity check fails — appears at the top-left of the screen
 * and is visible to mame_boot_test.lua's display-memory probe. */
static const char BAD_CHECKSUM_MSG[] = "BAD CHECKSUM";

/* Tail-called from reset.s.  SP is already set to __stack_top by
 * reset.s.  PROMs are still mapped — the payload disables them later.
 *
 * Flow:
 *   1. memcpy payload_a (PROM0 tail) and payload_b (PROM1) to RAM
 *      starting at bios_boot.
 *   2. Sum the entire relocated payload at bios_boot.  The correction
 *      word at its tail (patched at build time) makes the total
 *      mod 65536 equal PAYLOAD_CHECKSUM_MAGIC.
 *   3. Mismatch: copy "BAD CHECKSUM" to display memory, busy-loop.
 *   4. Match: tail-call cpnos_cold_entry().
 *
 * Note: this file is compiled WITHOUT `+static-stack` (see Makefile
 * override) so C locals go on the actual stack.  With +static-stack
 * the locals would land in .bss, which relocator.ld discards —
 * failing to link. */
[[noreturn]] void relocate(void) {
    __builtin_memcpy(bios_boot, payload_a, sizeof payload_a);
    __builtin_memcpy(bios_boot + sizeof payload_a,
                     payload_b, sizeof payload_b);

    const uint16_t total = (uint16_t)(sizeof payload_a + sizeof payload_b);
    /* Word-additive sum of the relocated payload.  Cast to volatile
     * uint16_t* to read each word in one access — the Z80 backend
     * emits LD HL,(addr) sequences for that. */
    const volatile uint16_t *w = (const volatile uint16_t *)bios_boot;
    const uint16_t word_count = total >> 1;

    uint16_t sum = 0;
    for (uint16_t i = 0; i < word_count; ++i)
        sum += w[i];

    if (sum != PAYLOAD_CHECKSUM_MAGIC) {
        __builtin_memcpy((void *)0xF800, BAD_CHECKSUM_MSG,
                         sizeof BAD_CHECKSUM_MSG - 1);
        for (;;) { }
    }

    cpnos_cold_entry();
}
