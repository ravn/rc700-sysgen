/* acid.com -- RC700 CONOUT control-code acid test.
 *
 * Exercises every RC700 control code our BIOS CONOUT dispatcher
 * implements (see cpnos-rom/resident.c:specc) and leaves a fixed,
 * verifiable pattern on the 8275 display.  mame_acid_test.lua
 * dumps display RAM at 0xF800 after the run and asserts specific
 * cells, and the run finishes by emitting "DONE\r\n" via CONOUT
 * which is mirrored to SIO-B for the test gate.
 *
 * Built with z88dk +cpm (default sdcccall) + standard cpm.h bdos().
 * We deliberately use BDOS fn 6 (DIRECT console I/O) rather than
 * fn 2, because fn 2 expands TAB -> spaces in the BDOS layer and
 * would bypass our BIOS CONOUT JT's tab handler.  Fn 6 passes the
 * byte straight to BIOS CONOUT, which is exactly what we're testing.
 */

#include <stdint.h>
#include <cpm.h>

#define CPM_DCIO 6   /* BDOS Direct Console I/O (raw CONOUT) */

static void putb(uint8_t c) {
    /* bdos() signature: int bdos(int func, int arg).  For fn 6, the
     * "arg" (low byte of E) carries the byte; anything 0x00..0xFE is
     * emitted, 0xFF means "read console status" (we never use it). */
    bdos(CPM_DCIO, c);
}

static void puts_raw(const char *s) {
    while (*s) putb((uint8_t)*s++);
}

static void xy(uint8_t col, uint8_t row) {
    /* RC700 start_xy convention (matches rcbios specc): coord bytes
     * are ASCII-offset by ' '.  Sending raw binary col/row underflows
     * uint8_t in xy_step and sends CELL() writes outside display RAM. */
    putb(0x06);
    putb((uint8_t)(col + 32));
    putb((uint8_t)(row + 32));
}

int main(void) {
    uint8_t i;

    /* 1. clear_screen + home. */
    putb(0x0C);
    putb(0x1D);

    /* 2. "HELLO!" at (col=20, row=5) via start_xy. */
    xy(20, 5);
    puts_raw("HELLO!");

    /* 3. Eyes: ':' at (4,10); five cursor_right land the next ':' at (10,10).
     *    (putb(':') advances col to 5, +5 rights -> col 10.) */
    xy(4, 10);
    putb(':');
    for (i = 0; i < 5; i++) putb(0x18);
    putb(':');

    /* 4. Mouth at row 11, cols 4..10: "\UUUUU)".
     *    CR + cursor_down + 4x cursor_right -> (4,11); print "\UUUUU/", then
     *    ENQ (cursor_left, 0x05) over '/' and replace with ')'. */
    putb(0x0D);
    putb(0x0A);
    for (i = 0; i < 4; i++) putb(0x18);
    puts_raw("\\UUUUU/");
    putb(0x05);
    putb(')');

    /* 5. BS (0x08) test: "XYZ" then BS*3 then "ABC" -> row shows "ABC". */
    xy(0, 13);
    puts_raw("XYZ");
    putb(0x08); putb(0x08); putb(0x08);
    puts_raw("ABC");

    /* 6. Tab (0x09) test: 'T' at col 0, TAB (BIOS tab = 4x cursor_right),
     *    'X' -> 'X' lands at col 5.  (resident.c:tab() advances 4 cols
     *    regardless of starting column.) */
    xy(0, 14);
    putb('T');
    putb(0x09);
    putb('X');

    /* 7. cursor_up (0x1A) test: 'D' at (0,16), cursor_up, 'U' -> 'U' at (1,15). */
    xy(0, 16);
    putb('D');
    putb(0x1A);
    putb('U');

    /* 8. erase_to_eol (0x1E): fill row 7, seek to col 4, erase -> only "KEEP". */
    xy(0, 7);
    puts_raw("KEEP12345678901234567890");
    xy(4, 7);
    putb(0x1E);

    /* 9. erase_to_eos (0x1F): fill rows 20..23, seek (0,20), erase. */
    xy(0, 20); puts_raw("row20");
    xy(0, 21); puts_raw("row21");
    xy(0, 22); puts_raw("row22");
    xy(0, 23); puts_raw("row23");
    xy(0, 20);
    putb(0x1F);

    /* 10. insert_line / delete_line round-trip: write "STAY" at (0,3),
     *     "GONE" at (0,4), insert_line at row 4 (GONE moves to row 5),
     *     delete_line at row 4 (row 5 pulled up).  Net: STAY on row 3,
     *     GONE on row 4 -- exact same layout as before.  Proves both
     *     ops run without crashing and that the scroll region is sane. */
    xy(0, 3);  puts_raw("STAY");
    xy(0, 4);  puts_raw("GONE");
    xy(0, 4);  putb(0x01);
    xy(0, 4);  putb(0x02);

    /* 11. Bell (0x07): no visible effect; just proves the dispatch arm
     *     doesn't trash cursor state. */
    putb(0x07);

    /* 12. Finish marker -- park the cursor on an unchecked row first so
     *     "DONE\r\n" doesn't trample any of the verifier's expected cells.
     *     The marker is mirrored to SIO-B by console_putc, which is where
     *     the MAME Lua gate watches. */
    xy(0, 18);
    puts_raw("DONE\r\n");

    return 0;
}
