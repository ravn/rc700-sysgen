/* cpnos-rom PROM relocator (C23).
 *
 * Reconstructs the CP/NOS payload at RAM 0xED00 from two #embed'd
 * binary chunks that sit in PROM0 tail and PROM1, then tail-calls
 * the payload's cold entry.
 *
 * Why two chunks?  The Z80 maps PROM0 at 0x0000..0x07FF and PROM1
 * at 0x2000..0x27FF, with a 6 KB address hole in between.  The
 * payload is a single contiguous blob linked at 0xED00, but to fit
 * it in the two EPROMs we cut it at the PROM0/PROM1 boundary.  The
 * build splits payload.bin into payload_a.bin (PROM0 tail) and
 * payload_b.bin (PROM1), and this file #embed's each into its own
 * linker-placed section.
 *
 * Entry flow:
 *   reset.s (at 0x0000) DI + SP + jp _relocate  ->  this function
 *   relocate() memcpys payload_a then payload_b  ->  _cpnos_cold_entry
 *
 * The payload's cold entry address is resolved at link time via
 * --defsym (the Makefile extracts it from the payload ELF with nm).
 */
#include <stdint.h>

/* Payload cold-entry symbol.  Defined in the payload ELF; supplied to
 * this link via `--defsym _cpnos_cold_entry=0x...` (see Makefile). */
extern void cpnos_cold_entry(void) __attribute__((noreturn));

/* Chunk A: first (2 KB - relocator size) bytes of payload.  Lives in
 * PROM0 tail, placed by relocator.ld at 0x0080 (after reset vector
 * + whatever code lands in .init below).  The linker script ASSERTs
 * that .init fits below the .prom0_tail base. */
__attribute__((section(".prom0_tail"), used))
static const uint8_t payload_a[] = {
#embed "clang/payload_a.bin" if_empty(0)
};

/* Chunk B: remaining payload bytes.  Lives in PROM1 at 0x2000. */
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

/* Tail-called from reset.s.  SP is already set to 0xED00.  PROMs
 * are still mapped — the payload disables them later.
 *
 * Flow:
 *   1. memcpy payload_a (PROM0 tail) and payload_b (PROM1) to RAM
 *      starting at 0xED00.
 *   2. Sum the entire relocated payload at 0xED00.  The correction
 *      word at its tail (patched at build time) makes the total
 *      mod 65536 equal PAYLOAD_CHECKSUM_MAGIC.
 *   3. Mismatch: copy "BAD CHECKSUM" to display memory, busy-loop.
 *   4. Match: tail-call cpnos_cold_entry().
 *
 * Note: this file is compiled WITHOUT `+static-stack` (see Makefile
 * override) so C locals go on the actual stack (SP=0xED00 RAM).
 * With +static-stack the locals would land in .bss, which
 * relocator.ld discards — failing to link. */
[[noreturn]] void relocate(void) {
    __builtin_memcpy((void *)0xED00, payload_a, sizeof payload_a);
    __builtin_memcpy((uint8_t *)0xED00 + sizeof payload_a,
                     payload_b, sizeof payload_b);

    const uint16_t total = (uint16_t)(sizeof payload_a + sizeof payload_b);
    /* Word-additive sum of the relocated payload.  Cast to volatile
     * uint16_t* to read each word in one access — the Z80 backend
     * emits LD HL,(addr) sequences for that. */
    const volatile uint16_t *w = (const uint16_t *)0xED00;
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
