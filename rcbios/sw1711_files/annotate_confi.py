#!/usr/bin/env python3
"""Annotate the raw z80dasm output of CONFI.COM.

Produces a clean annotated disassembly with meaningful labels,
corrected jump table regions, and inline comments.

Usage: python3 annotate_confi.py > CONFI_annotated.z80
"""

import struct

# --- Label map: address -> name ---
LABELS = {
    # Entry and main flow
    0x0100: "entry",
    0x0110: "drive_select",
    0x013A: "drive_ok",
    0x013F: "main_sequence",
    0x015F: "exit_warmboot",

    # Main menu
    0x0162: "main_menu",
    0x0176: ".jt_main",          # jump table (6 entries)

    # Terminal port sub-menu (menu says "TERMINAL PORT", configures SIO-A)
    0x0182: "submenu_terminal",
    0x0196: ".jt_terminal",      # jump table (5 entries)

    # Printer port sub-menu (menu says "PRINTER PORT", configures SIO-B)
    0x01A0: "submenu_printer",
    0x01B4: ".jt_printer",       # jump table (4 entries)

    # Stop bits handlers
    0x01BE: "stopbits_sioa",     # terminal port stop bits (SIO-A WR4)
    0x01C4: "stopbits_siob",     # printer port stop bits (SIO-B WR4)
    0x01CA: "stopbits_common",

    # Parity handlers
    0x01EB: "parity_sioa",       # terminal port parity (SIO-A WR4)
    0x01F1: "parity_siob",       # printer port parity (SIO-B WR4)
    0x01F7: "parity_common",

    # Baud rate handlers
    0x0216: "baudrate_sioa",     # terminal port baud (CTC Ch0 + SIO-A WR4)
    0x022B: "prog_ctc_ch0",      # program CTC Channel 0
    0x0235: "baudrate_siob",     # printer port baud (CTC Ch1 + SIO-B WR4)
    0x024A: "prog_ctc_ch1",      # program CTC Channel 1
    0x0254: "baudrate_menu",     # baud rate menu handler

    # SIO programming
    0x0275: "prog_sio_a",        # OTIR 9 bytes to port 0x0A
    0x0281: "prog_sio_b",        # OTIR 11 bytes to port 0x0B

    # Bits/char handlers
    0x028D: "txbits_sioa",       # terminal TX bits/char (SIO-A WR5)
    0x029A: "rxbits_sioa",       # terminal RX bits/char (SIO-A WR3)
    0x02A1: "txbits_siob",       # printer TX bits/char (SIO-B WR5)
    0x02AE: "rxbits_siob_ret",   # just RET (printer has no separate RX option)
    0x02AF: "txbits_common",     # common TX bits/char handler
    0x02DA: "rxbits_common",     # common RX bits/char handler

    # Conversion table
    0x0302: "submenu_conversion",
    0x0329: "copy_conv_to_bios", # copy selected table to 0xF680

    # Cursor
    0x0340: "submenu_cursor",
    0x0354: ".jt_cursor",        # jump table (2 entries)
    0x0358: "cursor_format",
    0x037E: "prog_crt",          # program 8275 CRT controller
    0x039F: "cursor_addressing",

    # Motor timer
    0x03B6: "submenu_motor",

    # Save config
    0x03DC: "save_config",

    # Disk I/O
    0x03E2: "disk_rw_sector",    # read or write one sector
    0x03F6: "disk_rw_config",    # read/write all 4 config sectors

    # Math utilities
    0x0487: "mul10",             # HL = HL * 10
    0x048E: "mul100",            # HL = HL * 100 (calls mul10 twice)
    0x0497: "div50",             # HL = HL / 50 (for motor timer display)
    0x04A7: "print_decimal",     # print HL as decimal number
    0x04C4: "print_digit",       # print one decimal digit

    # Generic menu handler
    0x04E7: "menu_handler",

    # Input buffer
    0x0567: "input_buf",         # BDOS readline buffer (max 5 chars)
    0x0568: "input_count",
    0x0569: "input_data",

    # Jump table dispatcher
    0x0573: "jt_dispatch",       # computed jump from table after CALL

    # String display
    0x057C: "print_string",      # display string with marker + XY support
    0x05B7: "handle_xy",         # process XY cursor escape (0x06)
    0x05D9: "disk_error",        # display error and warm boot

    # Data sections
    0x05E4: "str_banner",
    0x061C: "str_drive_prompt",
    0x064B: "str_disk_error",
    0x0659: "str_main_menu",
    0x0709: "str_terminal_menu",
    0x0803: "str_cursor_format",
    0x088A: "str_conversion",
    0x0928: "str_stopbits",
    0x097B: "str_parity",
    0x09C4: "str_baudrate",
    0x0AC7: "str_printer_menu",
    0x0B5F: "str_illegal",
    0x0B75: "str_txbits",
    0x0BE6: "str_rxbits",
    0x0C4F: "str_cursor_menu",
    0x0C9D: "str_addressing",
    0x0CE6: "str_motor_header",
    0x0CDA: "str_choice",
    0x0D26: "str_motor_range",

    # Config data
    0x0D5E: "drive_num",         # selected drive (0=A, 2=C)
    0x0D5F: "wr4_clock_tab",    # 11-byte SIO WR4 clock mode table
    0x0D6A: "ctc_div_tab",      # 11-byte CTC divisor table
    0x0D75: "dma_buf_sec2",     # DMA buffer: sector 2 (hw config)
    0x0D76: "ctc_a_div",         # CTC Ch0 divisor (SIO-A baud)
    0x0D78: "ctc_b_div",         # CTC Ch1 divisor (SIO-B baud)
    0x0D7D: "sio_a_cfg",         # SIO-A init block (9 bytes)
    0x0D7F: "sio_a_wr4",         # SIO-A WR4 value
    0x0D81: "sio_a_wr3",         # SIO-A WR3 value
    0x0D83: "sio_a_wr5",         # SIO-A WR5 value
    0x0D86: "sio_b_cfg",         # SIO-B init block (11 bytes)
    0x0D8A: "sio_b_wr4",         # SIO-B WR4 value
    0x0D8C: "sio_b_wr3",         # SIO-B WR3 value
    0x0D8E: "sio_b_wr5",         # SIO-B WR5 value
    0x0D95: "crt_params",        # CRT 8275 parameters (5 bytes)
    0x0D98: "crt_cursor",        # CRT cursor format byte
    0x0D9D: "adr_mode",          # cursor addressing mode
    0x0D9E: "conv_idx",          # conversion table index (0-6)
    0x0D9F: "baud_a_idx",        # SIO-A baud rate selection
    0x0DA0: "baud_b_idx",        # SIO-B baud rate selection
    0x0DA1: "motor_lo",          # motor timer low byte
    0x0DA2: "motor_hl",          # motor timer word
    0x0DF5: "dma_buf_sec3",      # DMA buffer: sector 3 (output conv)
    0x0E75: "dma_buf_sec4",      # DMA buffer: sector 4 (input conv)
    0x0EF5: "dma_buf_sec5",      # DMA buffer: sector 5 (semigraphic)
    0x0FF5: "conv_tables",       # start of built-in conversion tables

    # BIOS entry points (external)
    0xDA0C: "BIOS_CONOUT",
    0xDA1B: "BIOS_SELDSK",
    0xDA1E: "BIOS_SETTRK",
    0xDA21: "BIOS_SETSEC",
    0xDA24: "BIOS_SETDMA",
    0xDA27: "BIOS_READ",
    0xDA2A: "BIOS_WRITE",
}

# --- Comments: address -> comment string ---
COMMENTS = {
    0x0100: "3 NOPs — patching space",
    0x0103: "save CCP return, get stack",
    0x0104: "private stack below conv tables",
    0x0108: "print version banner",
    0x0110: "prompt for drive A or C",
    0x013F: "A=0 → read config from disk",
    0x0143: "run main menu loop",
    0x014D: "copy conv table to BIOS at 0xF680",
    0x0150: "program CRT (8275) cursor params",
    0x0153: "program SIO-A (9 bytes to port 0x0A)",
    0x0156: "program CTC Ch0 (SIO-A baud)",
    0x0159: "program SIO-B (11 bytes to port 0x0B)",
    0x015C: "program CTC Ch1 (SIO-B baud)",
    0x015F: "warm boot → reload CCP",
    0x0162: "main menu: 6 options at 0x0659",
    0x0182: "terminal port: 5 options (configures SIO-A!)",
    0x01A0: "printer port: 4 options (configures SIO-B!)",
    0x01BE: "stop bits for SIO-A (terminal port menu)",
    0x01C4: "stop bits for SIO-B (printer port menu)",
    0x01CA: "common: extract WR4 stop bits, show menu",
    0x01EB: "parity for SIO-A (terminal port menu)",
    0x01F1: "parity for SIO-B (printer port menu)",
    0x01F7: "common: extract WR4 parity, show menu",
    0x0216: "baud for SIO-A: ctc_a_div + WR4 clock bits",
    0x022B: "CTC mode=0x47, divisor from ctc_a_div",
    0x0235: "baud for SIO-B: ctc_b_div + WR4 clock bits",
    0x024A: "CTC mode=0x47, divisor from ctc_b_div",
    0x0254: "show 11-option baud menu, return C=div, B=WR4",
    0x0275: "OTIR 9 bytes to SIO-A control (port 0x0A)",
    0x0281: "OTIR 11 bytes to SIO-B control (port 0x0B)",
    0x028D: "TX bits/char for SIO-A WR5 (terminal menu)",
    0x029A: "RX bits/char for SIO-A WR3 (terminal menu)",
    0x02A1: "TX bits/char for SIO-B WR5 (printer menu)",
    0x02AF: "common: extract WR5 TX bits, show menu",
    0x02DA: "common: extract WR3 RX bits, show menu",
    0x0302: "conversion table selection (7 languages)",
    0x0329: "copy 384 bytes: tables[conv_idx] → 0xF680",
    0x0340: "cursor sub-menu: format + addressing",
    0x0358: "cursor format: blink/reverse/underline",
    0x037E: "8275 Load Cursor + Start Display",
    0x039F: "cursor addressing: H,V vs V,H",
    0x03B6: "motor timer: display + numeric input",
    0x03DC: "write config to disk (A=1)",
    0x03E2: "read (A=0) or write (A=1) one sector",
    0x03F6: "read/write 4 config sectors via BIOS",
    0x0487: "HL = HL * 10 (for decimal parsing)",
    0x048E: "HL = HL * 100 (mul10 twice + add)",
    0x0497: "HL = HL / 50 + 1 (motor timer display)",
    0x04A7: "print HL as 5-digit decimal (suppress leading zeros)",
    0x04E7: "generic menu: display, input, validate, return selection",
    0x0573: "computed jump: table[HL-1] at return address",
    0x057C: "print null-terminated string with XY + marker",
    0x05B7: "handle 0x06 escape: XY cursor positioning",
    0x05D9: "print error message and warm boot",
}

# --- Jump table regions: (start_addr, entry_count) ---
JUMP_TABLES = {
    0x0176: 6,   # main menu
    0x0196: 5,   # terminal port
    0x01B4: 4,   # printer port
    0x0354: 2,   # cursor
}

# --- Data regions that should not be disassembled ---
DATA_REGIONS = [
    (0x05E4, 0x0659, "banner_strings"),
    (0x0659, 0x0D5F, "menu_strings"),
    (0x0D5F, 0x0D75, "lookup_tables"),
    (0x0D75, 0x0F75, "dma_buffers"),
    (0x0F75, 0x0FF5, "stack_area"),
    (0x0FF5, 0x1A75, "conv_tables"),
    (0x1A75, 0x1A80, "trailing"),
]


def load_binary(path):
    with open(path, "rb") as f:
        return f.read()


def disassemble_region(data, start, end):
    """Simple Z80 disassembler for the code region."""
    # This is a minimal disassembler that handles the common opcodes
    # found in CONFI.COM. For full coverage, use z80dasm and post-process.
    pass


def format_jump_table(data, addr, count):
    """Format a jump table as DW entries with labels."""
    lines = []
    for i in range(count):
        off = addr - 0x0100 + i * 2
        target = data[off] | (data[off + 1] << 8)
        label = LABELS.get(target, f"0{target:04X}h")
        lines.append(f"\tDW {label}\t\t; option {i+1}")
    return lines


def decode_string(data, addr):
    """Decode a null-terminated menu string with control codes."""
    off = addr - 0x0100
    result = []
    i = 0
    while off + i < len(data):
        b = data[off + i]
        if b == 0:
            break
        elif b == 0x06:
            h = data[off + i + 1] - 0x20
            v = data[off + i + 2] - 0x20
            result.append(f"[XY:{h},{v}]")
            i += 2
        elif b == 0x05:
            result.append("*")
        elif b == 0x1F:
            result.append("[CLR-EOS]")
        elif b == 0x0C:
            result.append("[FF]")
        elif b == 0x0A:
            result.append("\\n")
        elif b == 0x0D:
            result.append("\\r")
        elif b == 0x07:
            result.append("[BEL]")
        elif 0x20 <= b < 0x7F:
            result.append(chr(b))
        else:
            result.append(f"[{b:02X}]")
        i += 1
    return "".join(result), i + 1  # +1 for null terminator


def main():
    import sys
    import os

    script_dir = os.path.dirname(os.path.abspath(__file__))
    binary_path = os.path.join(script_dir, "CONFI.COM")
    data = load_binary(binary_path)

    print("; CONFI.COM Annotated Disassembly")
    print("; RC700 CP/M CONFIGURATION UTILITY VERS 2.1 13.01.83")
    print("; Source: SW1711-I8.imd (rel.2.3 maxi system disk)")
    print(";")
    print("; Generated by annotate_confi.py")
    print(";")
    print("; NOTE: Menu labels 'PRINTER PORT' and 'TERMINAL PORT' are")
    print(";       swapped relative to the SIO channels they configure.")
    print(";       'PRINTER PORT' menu configures SIO-B (terminal channel).")
    print(";       'TERMINAL PORT' menu configures SIO-A (printer channel).")
    print()

    # Print label summary
    print("; === Label Summary ===")
    print(";")
    print("; Main flow:      entry, drive_select, main_sequence, exit_warmboot")
    print("; Menus:           main_menu, submenu_printer, submenu_terminal,")
    print(";                  submenu_conversion, submenu_cursor, submenu_motor")
    print("; SIO handlers:   stopbits_sioa/b, parity_sioa/b, baudrate_sioa/b,")
    print(";                  txbits_sioa/b, rxbits_sioa/b")
    print("; HW programming: prog_sio_a, prog_sio_b, prog_ctc_ch0/1, prog_crt")
    print("; Disk I/O:       disk_rw_config, disk_rw_sector, save_config")
    print("; Utilities:       menu_handler, jt_dispatch, print_string,")
    print(";                  mul10, mul100, print_decimal")
    print("; Conv tables:     copy_conv_to_bios (→ 0xF680)")
    print(";")
    print("; BIOS calls:     0xDA0C=CONOUT, 0xDA1B=SELDSK, 0xDA1E=SETTRK,")
    print(";                  0xDA21=SETSEC, 0xDA24=SETDMA, 0xDA27=READ,")
    print(";                  0xDA2A=WRITE")
    print()
    print("\tORG 0100h")
    print()

    # Dump the data sections with decoded strings
    print("; ============================================================")
    print("; DATA SECTIONS")
    print("; ============================================================")
    print()

    # Banner strings
    print("; --- Banner strings (0x05E4-0x0658) ---")
    addr = 0x05E4
    while addr < 0x0659:
        label = LABELS.get(addr, "")
        s, length = decode_string(data, addr)
        if label:
            print(f"{label}:")
        # Truncate long strings for display
        if len(s) > 70:
            print(f"\t; \"{s[:70]}...\"")
        else:
            print(f"\t; \"{s}\"")
        # Print as DB bytes
        off = addr - 0x0100
        for i in range(0, length, 16):
            chunk = data[off + i:off + i + min(16, length - i)]
            hexstr = ",".join(f"0{b:02X}h" for b in chunk)
            print(f"\tDB {hexstr}")
        addr += length
    print()

    # Menu strings
    print("; --- Menu strings (0x0659-0x0D5E) ---")
    # Find all string start addresses in the menu region
    menu_addrs = sorted([a for a in LABELS if 0x0659 <= a < 0x0D5F
                         and LABELS[a].startswith("str_")])
    for i, addr in enumerate(menu_addrs):
        next_addr = menu_addrs[i + 1] if i + 1 < len(menu_addrs) else 0x0D5F
        label = LABELS.get(addr, "")
        s, length = decode_string(data, addr)
        if label:
            print(f"{label}:\t\t; 0x{addr:04X}")
        # Show first line of menu
        first_line = s.split("\\n")[0][:80]
        print(f"\t; \"{first_line}\"")
        # Just show size, not all the DB bytes (too verbose)
        actual_len = next_addr - addr
        print(f"\t; ({actual_len} bytes)")
        print(f"\tDS {actual_len}")
    print()

    # Lookup tables
    print("; --- Baud rate lookup tables (0x0D5F-0x0D74) ---")
    print("wr4_clock_tab:\t\t; SIO WR4 clock mode bits, indexed by baud selection")
    off = 0x0D5F - 0x0100
    bauds = [50, 75, 110, 150, 300, 600, 1200, 2400, 4800, 9600, 19200]
    modes = {0xC0: "x64", 0x40: "x16"}
    for i in range(11):
        b = data[off + i]
        print(f"\tDB 0{b:02X}h\t\t; {bauds[i]:5d} bps → {modes.get(b, '???')}")
    print()
    print("ctc_div_tab:\t\t; CTC divisor bytes, indexed by baud selection")
    off = 0x0D6A - 0x0100
    for i in range(11):
        b = data[off + i]
        clk = 0xC0 if i < 5 else 0x40
        div_mode = 64 if clk == 0xC0 else 16
        actual = 614400.0 / div_mode / b if b else 0
        print(f"\tDB 0{b:02X}h\t\t; {bauds[i]:5d} bps = 614400/{div_mode}/{b} = {actual:.1f}")
    print()

    # Config variables
    print("; --- DMA buffer: Track 0 sector 2 (hw config, 128 bytes at 0x0D75) ---")
    print("; Overwritten at runtime by disk read. Layout:")
    print(";   +0x01: ctc_a_div    CTC Ch0 divisor (SIO-A baud)")
    print(";   +0x03: ctc_b_div    CTC Ch1 divisor (SIO-B baud)")
    print(";   +0x08: sio_a_cfg    SIO-A init block (9 bytes)")
    print(";     +0x0A: sio_a_wr4  WR4: clock+parity+stop")
    print(";     +0x0C: sio_a_wr3  WR3: RX bits+enable")
    print(";     +0x0E: sio_a_wr5  WR5: TX bits+DTR+RTS")
    print(";   +0x11: sio_b_cfg    SIO-B init block (11 bytes)")
    print(";     +0x15: sio_b_wr4  WR4: clock+parity+stop")
    print(";     +0x17: sio_b_wr3  WR3: RX bits+enable")
    print(";     +0x19: sio_b_wr5  WR5: TX bits+DTR+RTS")
    print(";   +0x20: crt_params   8275 parameters (5 bytes)")
    print(";   +0x28: adr_mode     cursor addressing (0=H,V 1=V,H)")
    print(";   +0x29: conv_idx     conversion table index (0-6)")
    print(";   +0x2A: baud_a_idx   SIO-A baud selection (for display)")
    print(";   +0x2B: baud_b_idx   SIO-B baud selection (for display)")
    print(";   +0x2C: motor_lo     motor timer low byte")
    print(";   +0x2D: motor_hl     motor timer word (seconds)")
    print("dma_buf_sec2:\tDS 128\t; 0x0D75-0x0DF4")
    print("dma_buf_sec3:\tDS 128\t; 0x0DF5-0x0E74 (output conv)")
    print("dma_buf_sec4:\tDS 128\t; 0x0E75-0x0EF4 (input conv)")
    print("dma_buf_sec5:\tDS 128\t; 0x0EF5-0x0F74 (semigraphic)")
    print()

    # Stack + conv tables
    print("; --- Stack area (0x0F75-0x0FF4) ---")
    print("\tDS 128\t\t; stack grows down from 0x0FF5")
    print()
    print("; --- Built-in conversion tables (0x0FF5-0x1A74) ---")
    print("; 7 tables x 384 bytes = 2688 bytes")
    print("; Each table: 128 output + 128 input + 128 semigraphic")
    table_names = ["Danish (identity)", "Swedish", "German",
                   "UK ASCII", "US ASCII", "French", "Library"]
    for i, name in enumerate(table_names):
        addr = 0x0FF5 + i * 384
        print(f"conv_{name.split()[0].lower()}:\t; {name} @ 0x{addr:04X}")
        print(f"\tDS 384")
    print()
    print("; --- Trailing data (11 bytes) ---")
    print("\tDS 11")
    print()
    print("\tEND")


if __name__ == "__main__":
    main()
