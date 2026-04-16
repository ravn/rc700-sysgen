/* rc700_z3termcap.h — RC702 ZCPR3 Terminal Capabilities (TCAP), 128 bytes.
 *
 * Derived from the binary rc700.z3t (kept in this directory for
 * reference), with annotations added per the ZCPR3 Installation Manual
 * section 7.2 "Internal Structure of a Z3T File". The terminal name
 * has been rewritten as a clean "RC700" + space fill (the original
 * z3t used "Rc700 patched3" + a 2-byte vendor tag).
 *
 * WARNING — contents not verified: the original rc700.z3t was written
 * long ago and the individual capability bytes have NOT been checked
 * against current RC702 behavior. Before trusting this table in a
 * ZCPR3 integration, verify each field against the RC702 display
 * protocol in bios.c (display driver / escape sequences):
 *
 *   name:   DS 16   ; Name of terminal (space-filled on right)
 *   arrows: DS  4   ; UP, DOWN, RIGHT, LEFT key codes
 *   delays: DS  3   ; Post-sequence delays (ms): CLS, CM, CE
 *   cl:     DS N1+1 ; Clear-Screen sequence + null terminator
 *   cm:     DS N2+1 ; Cursor-Motion (GOTOXY) sequence + null
 *   ce:     DS N3+1 ; Clear to End-of-Line + null
 *   so:     DS N4+1 ; Begin highlight (Standout On) + null
 *   se:     DS N5+1 ; End highlight (Standout End) + null
 *   ti:     DS N6+1 ; Terminal Init + null
 *   to:     DS N7+1 ; Terminal Deinit + null
 *   (trailing extended/padding bytes to total 128)
 *
 * Specific items to verify before trusting this table:
 *   - Cursor positioning lead-in 0x06 (ACK): matches RC702 protocol?
 *   - Cursor offset 0x20 added to both row and col: is the 0-based?
 *   - Clear-to-EOL code 0x1E (RS): matches RC702 erase-to-EOL?
 *   - Form-feed 0x0C for CLS: correct on RC702?
 *   - The 7 bytes of extended/Z-System data at 0x29-0x2F (undocumented).
 *
 * For ZCPR3 integration, point the Environment Descriptor's TCAP
 * slot at this table. See tasks/todo.md "Replace CCP with ZCPR3.x".
 */
#ifndef RC700_Z3TERMCAP_H
#define RC700_Z3TERMCAP_H

static const unsigned char rc702_tcap[] = {
    /* --- 0x00-0x0F: Name (16 bytes, ASCII, space-filled on right) --- */
    'R', 'C', '7', '0', '0', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',

    /* --- 0x10-0x13: Arrow keys (WordStar movement convention) -------- */
    0x05,  /* UP    — ^E (CTRL-E) */
    0x18,  /* DOWN  — ^X (CTRL-X) */
    0x04,  /* RIGHT — ^D (CTRL-D) */
    0x13,  /* LEFT  — ^S (CTRL-S) */

    /* --- 0x14-0x16: Post-sequence delays (ms). RC702 needs none. ----- */
    0x00,  /* after Clear Screen */
    0x00,  /* after Cursor Motion */
    0x00,  /* after Clear to EOL */

    /* --- 0x17-0x18: Clear Screen (cl) --------------------------------
     * Single byte 0x0C (form feed) — RC702's clear-screen code.
     */
    0x0C,
    0x00,  /* null terminator */

    /* --- 0x19-0x22: Cursor Motion / GOTOXY (cm) ---------------------
     * Lead-in 0x06 (ACK — the RC702 cursor-positioning start code),
     * followed by a ZCPR3 cursor-motion template:
     *   %r    — reverse order: output column first, then row
     *   %+ '  — add 0x20 to column, output one binary byte
     *   %+ '  — add 0x20 to row, output one binary byte
     * Effective sequence sent to screen: 0x06, col+0x20, row+0x20.
     */
    0x06,
    '%', 'r',           /* reverse row/col order */
    '%', '+', ' ',      /* col: add 0x20, binary byte */
    '%', '+', ' ',      /* row: add 0x20, binary byte */
    0x00,               /* null terminator */

    /* --- 0x23-0x24: Clear to End of Line (ce) ------------------------ */
    0x1E,  /* RS — RC702 erase-to-EOL */
    0x00,

    /* --- 0x25: Standout Begin (so) — not supported, empty ----------- */
    0x00,  /* null terminator (zero content bytes) */

    /* --- 0x26: Standout End (se) — empty ---------------------------- */
    0x00,

    /* --- 0x27: Terminal Init (ti) — empty --------------------------- */
    0x00,

    /* --- 0x28: Terminal Deinit (to) — empty ------------------------- */
    0x00,

    /* --- 0x29-0x30: Extended fields ---------------------------------
     * The base ZCPR3 TCAP (sec. 7.2) ends at 'to'. The original
     * rc700.z3t has additional bytes here from later Z-System / NZ-COM
     * TCAP extensions (likely function-key codes and/or attribute
     * modes). Semantics not documented in the base manual; preserved
     * verbatim from the reference binary.
     *
     * Structurally the extensions read as null-terminated sequences:
     *   02 00 | 01 00 | 00 | 00 | 1F 00
     * The trailing 0x00 was offset 0x30 (first byte of the padding
     * region) in the original 128B file — kept here to terminate the
     * sequence ending with 0x1F.
     */
    0x02, 0x00, 0x01, 0x00, 0x00, 0x00, 0x1F, 0x00,
};


#endif /* RC700_TCAP_H */
