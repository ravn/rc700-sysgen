#!/usr/bin/env python3
"""Extract character conversion tables from CONFI.COM.

CONFI.COM (RC702 CP/M Configuration Utility) contains 7 built-in
character conversion tables, each 384 bytes = 3 × 128:
  - Output conversion:  application char → CRT ROM position (ROA296)
  - Input conversion:   keyboard code → application char (lower 128)
  - Extended/semigfx:   extended keyboard + semigraphic mapping (upper 128)

The tables start at file offset 0x0EF5 (address 0x0FF5) and are
contiguous, 384 bytes apart.

Usage:
    python3 extract_conv_tables.py [CONFI.COM] [--mac-dir DIR]

Outputs:
    conversion_tables.md  — Human-readable reference with diffs vs identity
    conversion_tables.bin — Raw 2688 bytes (7 × 384), for programmatic use
    <mac-dir>/*.MAC       — Assembly include files for BIOS build (if --mac-dir)
"""

import sys
import os

LANGUAGES = ["Danish", "Swedish", "German", "UK_ASCII", "US_ASCII", "French", "Library"]
TABLE_OFFSET = 0x0EF5  # file offset (address 0x0FF5 - 0x0100 load address)
TABLE_SIZE = 384        # 3 × 128 bytes per table
SUB_SIZE = 128          # each sub-table

def extract_tables(data):
    """Extract 7 conversion tables from CONFI.COM binary."""
    tables = []
    for i in range(7):
        offset = TABLE_OFFSET + i * TABLE_SIZE
        raw = data[offset:offset + TABLE_SIZE]
        if len(raw) != TABLE_SIZE:
            raise ValueError(f"Table {i} ({LANGUAGES[i]}): expected {TABLE_SIZE} bytes at offset 0x{offset:04X}, got {len(raw)}")
        tables.append({
            "name": LANGUAGES[i],
            "output": list(raw[0:128]),
            "input": list(raw[128:256]),
            "semigraphic": list(raw[256:384]),
        })
    return tables


def identity_map():
    """Return the identity table (0x00..0x7F)."""
    return list(range(128))


def char_repr(b):
    """Printable representation of a byte value."""
    if 0x20 <= b <= 0x7E:
        return chr(b)
    return f"0x{b:02X}"


def format_diffs(table, identity):
    """Return list of (index, identity_val, table_val) for differences."""
    return [(i, identity[i], table[i]) for i in range(128) if table[i] != identity[i]]


def write_markdown(tables, outpath):
    """Write human-readable conversion table reference."""
    ident = identity_map()

    with open(outpath, "w") as f:
        f.write("# RC702 Character Conversion Tables\n\n")
        f.write("Extracted from CONFI.COM (SW1711-I8 disk image).\n\n")
        f.write("## Overview\n\n")
        f.write("The RC702 CRT controller uses a character ROM (ROA296) with Danish national\n")
        f.write("characters as the native character set. The keyboard also produces Danish\n")
        f.write("codes natively. For other languages, CONFI.COM installs conversion tables\n")
        f.write("into the BIOS at address 0xF680 (3 × 128 = 384 bytes).\n\n")
        f.write("Each table has three 128-byte sub-tables:\n\n")
        f.write("| Offset | Purpose | Direction |\n")
        f.write("|--------|---------|-----------|\n")
        f.write("| +0x00  | Output conversion | Application char → CRT ROM position |\n")
        f.write("| +0x80  | Input conversion  | Keyboard code → application char |\n")
        f.write("| +0x100 | Semigraphic map   | Semigraphic character mapping (ROA327) |\n\n")
        f.write("The Danish table is the identity map (no conversion needed).\n\n")

        # Summary table
        f.write("## Summary\n\n")
        f.write("| # | Language | Output diffs | Input diffs | Semigfx diffs |\n")
        f.write("|---|----------|-------------|-------------|---------------|\n")
        for i, t in enumerate(tables):
            od = len(format_diffs(t["output"], ident))
            id_ = len(format_diffs(t["input"], ident))
            sd = len(format_diffs(t["semigraphic"], ident))
            f.write(f"| {i} | {t['name']} | {od} | {id_} | {sd} |\n")
        f.write("\n")

        # RC702 national character positions
        f.write("## RC702 National Character Positions\n\n")
        f.write("The following ASCII positions are used for national characters in the\n")
        f.write("RC702 CRT ROM (ROA296). These are the positions that differ between\n")
        f.write("language tables:\n\n")
        f.write("| Hex  | ASCII | Danish (ROM) | Notes |\n")
        f.write("|------|-------|-------------|-------|\n")
        national_positions = [0x23, 0x40, 0x5B, 0x5C, 0x5D, 0x5E, 0x60, 0x7B, 0x7C, 0x7D, 0x7E]
        danish_names = {
            0x23: "#",
            0x40: "@→Ä (strstreg-A)",
            0x5B: "[→Æ",
            0x5C: "\\→Ø",
            0x5D: "]→Å",
            0x5E: "^",
            0x60: "`→ä",
            0x7B: "{→æ",
            0x7C: "|→ø",
            0x7D: "}→å",
            0x7E: "~→ü",
        }
        for pos in national_positions:
            f.write(f"| 0x{pos:02X} | {chr(pos)} | {danish_names.get(pos, chr(pos))} | |\n")
        f.write("\n")

        # Detailed per-language tables
        for i, t in enumerate(tables):
            f.write(f"## {i}. {t['name']}\n\n")

            # Output conversion
            out_diffs = format_diffs(t["output"], ident)
            f.write(f"### Output conversion ({len(out_diffs)} differences)\n\n")
            if not out_diffs:
                f.write("Identity map — no conversion.\n\n")
            else:
                f.write("Maps application character codes to CRT ROM positions.\n\n")
                f.write("| Position | Identity | Mapped to | Notes |\n")
                f.write("|----------|----------|-----------|-------|\n")
                for pos, orig, mapped in out_diffs:
                    f.write(f"| 0x{pos:02X} ({char_repr(orig)}) | 0x{orig:02X} | 0x{mapped:02X} ({char_repr(mapped)}) | |\n")
                f.write("\n")

            # Input conversion
            inp_diffs = format_diffs(t["input"], ident)
            f.write(f"### Input conversion ({len(inp_diffs)} differences)\n\n")
            if not inp_diffs:
                f.write("Identity map — no conversion.\n\n")
            else:
                f.write("Maps keyboard scan codes to application character codes.\n\n")
                f.write("| Position | Identity | Mapped to | Notes |\n")
                f.write("|----------|----------|-----------|-------|\n")
                for pos, orig, mapped in inp_diffs:
                    f.write(f"| 0x{pos:02X} ({char_repr(orig)}) | 0x{orig:02X} | 0x{mapped:02X} ({char_repr(mapped)}) | |\n")
                f.write("\n")

            # Semigraphic — just count, full dump is too large
            sem_diffs = format_diffs(t["semigraphic"], ident)
            f.write(f"### Semigraphic map ({len(sem_diffs)} differences)\n\n")
            if not sem_diffs:
                f.write("Identity map.\n\n")
            else:
                f.write("Maps character codes to semigraphic ROM (ROA327) positions.\n")
                f.write(f"{len(sem_diffs)} positions differ from identity (semigraphic ROM\n")
                f.write("has its own character layout). See `conversion_tables.bin` for raw data.\n\n")

        # Raw hex dump of all tables
        f.write("## Raw Table Data\n\n")
        f.write("Full hex dump of each table (384 bytes = 3 × 128).\n\n")
        for i, t in enumerate(tables):
            f.write(f"### {t['name']}\n\n")
            all_bytes = t["output"] + t["input"] + t["semigraphic"]
            for sub_name, sub_offset in [("Output", 0), ("Input", 128), ("Semigraphic", 256)]:
                f.write(f"**{sub_name}** (+0x{sub_offset:02X}):\n```\n")
                for row in range(8):
                    start = sub_offset + row * 16
                    hexpart = " ".join(f"{all_bytes[start+j]:02X}" for j in range(16))
                    ascpart = "".join(
                        chr(all_bytes[start+j]) if 0x20 <= all_bytes[start+j] <= 0x7E else "."
                        for j in range(16)
                    )
                    f.write(f"  {start:04X}: {hexpart}  {ascpart}\n")
                f.write("```\n\n")


def write_c_header(table, filepath):
    """Write a C header file with the conversion table as a byte array initializer."""
    name = table["name"]
    all_bytes = table["output"] + table["input"] + table["semigraphic"]

    with open(filepath, "w") as f:
        f.write(f"/* {name} character conversion tables for RC702\n")
        f.write(f" * Generated from CONFI.COM by extract_conv_tables.py\n")
        f.write(f" * 384 bytes: outcon[128] + inconv[128] + extended/semigraphic[128] */\n")

        sections = [
            ("outcon[128]: output conversion", 0, 128),
            ("inconv lower[128]: input conversion", 128, 256),
            ("inconv upper[128]: extended keyboard / semigraphic", 256, 384),
        ]

        for label, start, end in sections:
            f.write(f"\n    /* {label} */\n")
            for row_start in range(start, end, 8):
                row = all_bytes[row_start:row_start + 8]
                hex_vals = ", ".join(f"0x{b:02X}" for b in row)
                comma = "," if row_start + 8 < 384 else ""
                f.write(f"    {hex_vals}{comma}\n")


def write_z88dk_inc(table, filepath):
    """Write a z88dk-format .inc file for inclusion in crt0.asm."""
    name = table["name"]
    all_bytes = table["output"] + table["input"] + table["semigraphic"]

    with open(filepath, "w") as f:
        f.write(f"; {name} character conversion tables for RC702\n")
        f.write(f"; Generated from CONFI.COM by extract_conv_tables.py\n")
        f.write(f"; 384 bytes: outcon[128] + inconv[128] + extended/semigraphic[128]\n\n")

        sections = [
            ("outcon[128]: output conversion (character -> display)", 0, 128),
            ("inconv lower[128]: input conversion (keyboard -> internal)", 128, 256),
            ("inconv upper[128]: extended keyboard / semigraphic", 256, 384),
        ]

        for label, start, end in sections:
            f.write(f"    ; --- {label} ---\n")
            for row_start in range(start, end, 8):
                row = all_bytes[row_start:row_start + 8]
                hex_vals = ",".join(f"0x{b:02X}" for b in row)
                hi = row_start // 16
                f.write(f"    defb {hex_vals} ; {hi:X}x\n")
            f.write("\n")


MAC_FILENAMES = {
    "Danish": "DANISH.MAC",
    "Swedish": "SWEDISH.MAC",
    "German": "GERMAN.MAC",
    "UK_ASCII": "UK_ASCII.MAC",
    "US_ASCII": "US_ASCII.MAC",
    "French": "FRENCH.MAC",
    "Library": "LIBRARY.MAC",
}

# Comments for output table positions (from original DANISH.MAC)
OUTPUT_COMMENTS = {
    0: "not used", 1: "A-CTRL", 2: None, 3: "C-CTRL", 4: "D-CTRL",
    5: "<--", 6: "F-CTRL", 7: "G-CTRL", 8: "H-CTRL", 9: "-->",
    10: "DOWN ARROW", 11: "K-CTRL", 12: "CLEAR", 13: "LEFT KNEE, M-CTRL, CR",
    14: "N-CTRL", 15: None, 16: None, 17: None, 18: "B-CTRL", 19: "S-CTRL",
    20: None, 21: None, 22: None, 23: None, 24: "X-CTRL", 25: None,
    26: "UP ARROW, Z-CTRL", 27: "ESCAPE", 28: None, 29: None, 30: None, 31: None,
    32: "SPACE", 33: "!", 34: '"', 35: "# (PARAGRAPH)", 36: "$",
    37: "%", 38: "&", 39: "'", 40: "(", 41: ")", 42: "*", 43: "+",
    44: ",", 45: "- (MINUS)", 46: ".", 47: "/",
    48: "0", 49: "1", 50: "2", 51: "3", 52: "4", 53: "5", 54: "6", 55: "7",
    56: "8", 57: "9", 58: ":", 59: ";", 60: "<", 61: "=", 62: ">", 63: "?",
    64: "@", 65: "A", 66: "B", 67: "C", 68: "D", 69: "E", 70: "F", 71: "G",
    72: "H", 73: "I", 74: "J", 75: "K", 76: "L", 77: "M", 78: "N", 79: "O",
    80: "P", 81: "Q", 82: "R", 83: "S", 84: "T", 85: "U", 86: "V", 87: "W",
    88: "X", 89: "Y", 90: "Z", 91: "[", 92: "\\", 93: "]", 94: "^",
    95: "_", 96: "`", 97: "a", 98: "b", 99: "c", 100: "d", 101: "e",
    102: "f", 103: "g", 104: "h", 105: "i", 106: "j", 107: "k", 108: "l",
    109: "m", 110: "n", 111: "o", 112: "p", 113: "q", 114: "r", 115: "s",
    116: "t", 117: "u", 118: "v", 119: "w", 120: "x", 121: "y", 122: "z",
    123: "{", 124: "|", 125: "}", 126: "~", 127: "RUBOUT",
}

# Comments for input table lower half (0-127)
INPUT_COMMENTS = {
    0: None, 1: "A-CTRL", 2: "B-CTRL", 3: "C-CTRL", 4: "D-CTRL",
    5: "E-CTRL", 6: "F-CTRL", 7: "G-CTRL", 8: "H-CTRL", 9: "I-CTRL",
    10: "J-CTRL", 11: "K-CTRL", 12: "L-CTRL", 13: "M-CTRL, CR",
    14: "N-CTRL", 15: "O-CTRL", 16: "P-CTRL", 17: "Q-CTRL", 18: "R-CTRL",
    19: "S-CTRL", 20: "T-CTRL", 21: "U-CTRL", 22: "V-CTRL", 23: "W-CTRL",
    24: "X-CTRL", 25: "Y-CTRL", 26: "Z-CTRL",
    27: "ESC", 28: None, 29: None, 30: "ERA EOLN", 31: "ERA EOS",
    32: "SPACE", 33: "!", 34: '"', 35: "#", 36: "$",
    37: "%", 38: "&", 39: "'", 40: "(", 41: ")", 42: "*", 43: "+",
    44: ",", 45: "-", 46: ".", 47: "/",
    48: "0", 49: "1", 50: "2", 51: "3", 52: "4", 53: "5", 54: "6", 55: "7",
    56: "8", 57: "9", 58: ":", 59: ";", 60: "<", 61: "=", 62: ">", 63: "?",
    64: "@", 65: "A", 66: "B", 67: "C", 68: "D", 69: "E", 70: "F", 71: "G",
    72: "H", 73: "I", 74: "J", 75: "K", 76: "L", 77: "M", 78: "N", 79: "O",
    80: "P", 81: "Q", 82: "R", 83: "S", 84: "T", 85: "U", 86: "V", 87: "W",
    88: "X", 89: "Y", 90: "Z", 91: "[", 92: "\\", 93: "]", 94: "^",
    95: "_", 96: "`", 97: "a", 98: "b", 99: "c", 100: "d", 101: "e",
    102: "f", 103: "g", 104: "h", 105: "i", 106: "j", 107: "k", 108: "l",
    109: "m", 110: "n", 111: "o", 112: "p", 113: "q", 114: "r", 115: "s",
    116: "t", 117: "u", 118: "v", 119: "w", 120: "x", 121: "y", 122: "z",
    123: "{", 124: "|", 125: "}", 126: "~", 127: "RUBOUT",
}

# Comments for input table upper half (128-255) — extended keyboard codes
INPUT_UPPER_COMMENTS = {
    128: None, 129: "HOME", 130: None, 131: "PA1", 132: "PA2",
    133: "LEFT TAB", 134: None, 135: None, 136: "LEFT ARROW",
    137: "RIGHT TAB", 138: "DOWN ARROW", 139: "PA3", 140: "CLEAR",
    141: "CR", 142: "PA4", 143: None, 144: "PA5", 145: None, 146: None,
    147: None, 148: "SHIFT PA1", 149: "SHIFT PA2", 150: None, 151: None,
    152: "RIGHT ARROW", 153: "SHIFT PA3", 154: "UP ARROW",
    155: "SHIFT ESCAPE", 156: "SHIFT PA4", 157: None, 158: "SHIFT PA5",
    159: None, 160: "SPACE", 161: "1 (NUMPAD)", 162: "2", 163: "3",
    164: "4", 165: "5", 166: "6", 167: "7", 168: "8", 169: "9",
    170: None, 171: "0", 172: "-", 173: None, 174: ".", 175: "SHIFT PF4",
    176: "0", 177: "1", 178: "2", 179: "3", 180: "4", 181: "5",
    182: "6", 183: "7", 184: "8", 185: "9", 186: None, 187: "0",
    188: "-", 189: None, 190: ".", 191: "PF4", 192: "SHIFT HOME",
    193: "PF7", 194: None, 195: None, 196: None, 197: "SHIFT LEFT TAB",
    198: "PF3", 199: None, 200: "SHIFT LEFT ARROW", 201: "SHIFT RIGHT TAB",
    202: "SHIFT DOWN ARROW", 203: "PF5", 204: "PF6", 205: None, 206: None,
    207: None, 208: "PF2", 209: None, 210: "PF8", 211: None, 212: None,
    213: None, 214: "PF1", 215: None, 216: "SHIFT RIGHT ARROW",
    217: None, 218: "SHIFT UP ARROW", 219: None, 220: None, 221: None,
    222: None, 223: "0 (NUL)", 224: None, 225: "SHIFT PF7", 226: None,
    227: None, 228: None, 229: None, 230: "SHIFT PF3", 231: None,
    232: None, 233: None, 234: None, 235: "SHIFT PF5", 236: "SHIFT PF6",
    237: None, 238: None, 239: None, 240: "SHIFT PF2", 241: None,
    242: "SHIFT PF8", 243: None, 244: None, 245: None, 246: "SHIFT PF1",
    247: None, 248: None, 249: None, 250: None, 251: None, 252: None,
    253: None, 254: None, 255: "SHIFT RUBOUT",
}


def format_db(value, position, comments):
    """Format a single DB line with optional comment."""
    comment = comments.get(position)
    if comment:
        return f"\tDB\t{value:3d};\t\t{position:3d}:\t\t{comment}\n"
    else:
        return f"\tDB\t{value:3d};\t\t{position:3d}:\n"


def write_mac_file(table, filepath):
    """Write a .MAC conversion table file matching DANISH.MAC format."""
    name = table["name"].upper().replace("_", " ")

    with open(filepath, "w") as f:
        f.write(f"\tTITLE\tOUTPUT CONVERSION TABLE\n")
        f.write(f"; SUBTTL\t{name}\n")
        f.write(f"\tPAGE\n\n")
        f.write(f";              ASCII          OUTPUT            COMMENT\n")

        # Output conversion table (128 bytes)
        for i in range(128):
            f.write(format_db(table["output"][i], i, OUTPUT_COMMENTS))
            if i in (35, 73, 83, 111, 124):
                f.write(f"\n\tPAGE\n\n")

        f.write(f"\n\t; TITLE INPUT CONVERSION TABLE\n")
        f.write(f"\t; SUBTTL {name}\n")
        f.write(f"\n\tPAGE\n\n")
        f.write(f";             ASCII     INPUT\t\tCOMMENT\n")

        # Input conversion table lower (128 bytes)
        for i in range(128):
            f.write(format_db(table["input"][i], i, INPUT_COMMENTS))
            if i in (35, 73, 83, 111, 124):
                f.write(f"\n\tPAGE\n\n")

        # Input conversion table upper / extended keyboard (128 bytes)
        for i in range(128):
            pos = i + 128
            f.write(format_db(table["semigraphic"][i], pos, INPUT_UPPER_COMMENTS))
            if pos in (149, 185, 222, 245):
                f.write(f"\n\tPAGE\n\n")

        f.write("\n")


def main():
    mac_dir = None
    comfile = None

    args = sys.argv[1:]
    i = 0
    while i < len(args):
        if args[i] == "--mac-dir" and i + 1 < len(args):
            mac_dir = args[i + 1]
            i += 2
        else:
            comfile = args[i]
            i += 1

    if comfile is None:
        comfile = os.path.join(os.path.dirname(__file__), "CONFI.COM")

    with open(comfile, "rb") as fp:
        data = fp.read()

    print(f"Read {len(data)} bytes from {comfile}")

    tables = extract_tables(data)

    # Verify Danish is identity
    ident = identity_map()
    assert tables[0]["output"] == ident, "Danish output table is not identity!"
    assert tables[0]["input"] == ident, "Danish input table is not identity!"
    print("Danish identity check: OK")

    # Write binary
    binpath = os.path.join(os.path.dirname(comfile), "conversion_tables.bin")
    with open(binpath, "wb") as fp:
        for t in tables:
            fp.write(bytes(t["output"] + t["input"] + t["semigraphic"]))
    print(f"Wrote {7 * TABLE_SIZE} bytes to {binpath}")

    # Write markdown
    mdpath = os.path.join(os.path.dirname(comfile), "conversion_tables.md")
    write_markdown(tables, mdpath)
    print(f"Wrote {mdpath}")

    # Write .MAC files (zmac/DRI format for rcbios/src/)
    if mac_dir:
        os.makedirs(mac_dir, exist_ok=True)
        for t in tables:
            macpath = os.path.join(mac_dir, MAC_FILENAMES[t["name"]])
            write_mac_file(t, macpath)
            print(f"Wrote {macpath}")

    # Write z88dk .inc files (for rcbios-in-c/crt0.asm)
    if mac_dir:
        # mac_dir is e.g. rcbios/src, so go up two levels to repo root
        repo_root = os.path.dirname(os.path.dirname(os.path.abspath(mac_dir)))
        inc_dir = os.path.join(repo_root, "rcbios-in-c")
        if os.path.isdir(inc_dir):
            for t in tables:
                incpath = os.path.join(inc_dir, t["name"].lower() + "_tables.inc")
                write_z88dk_inc(t, incpath)
                print(f"Wrote {incpath}")
            # Also generate C header files
            for t in tables:
                hpath = os.path.join(inc_dir, t["name"].lower() + "_tables.h")
                write_c_header(t, hpath)
                print(f"Wrote {hpath}")


if __name__ == "__main__":
    main()
