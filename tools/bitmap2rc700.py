#!/usr/bin/env python3
"""Convert a monochrome bitmap image to RC702 screen output.

Uses the ROA296 (chargen) and ROA327 (semigraphics) character ROMs to
find the best matching character for each cell of the input image.

Two modes:
  --mode block   Use 2x3 block semigraphics only (160x72 effective resolution)
  --mode full    Match against all ROM characters (80x24, 7x11 pixels per cell)

Output formats:
  --output text    ASCII preview on terminal (default)
  --output binary  Raw 1920-byte screen buffer (80x24)
  --output png     Rendered preview image showing how it looks on RC702

Usage:
  python3 bitmap2rc700.py input.png
  python3 bitmap2rc700.py input.png --mode full --output png -o preview.png
  python3 bitmap2rc700.py --test           # generate and convert test images
  python3 bitmap2rc700.py --show-charset   # render ROM charset to PNG
"""

import argparse
import os
import sys
import struct
import math

try:
    from PIL import Image, ImageDraw, ImageFont
    import numpy as np
except ImportError:
    print("Requires: pip install Pillow numpy", file=sys.stderr)
    sys.exit(1)

# RC702 screen dimensions
SCREEN_COLS = 80
SCREEN_ROWS = 24
CHAR_W = 7   # pixels per character (8275 configured for 7-pixel width)
CHAR_H = 11  # visible rows per character in ROM (rows 0-10)

# Semigraphics block dimensions within character cell
BLOCK_COLS = 2  # sub-blocks per cell horizontally
BLOCK_ROWS = 3  # sub-blocks per cell vertically
GFX_W = SCREEN_COLS * BLOCK_COLS   # 160
GFX_H = SCREEN_ROWS * BLOCK_ROWS  # 72

# ROM layout
ROM_SIZE = 2048
CHARS_PER_ROM = 128
BYTES_PER_CHAR = 16

# Block zone row ranges within character cell
BLOCK_ZONES = [(0, 3), (3, 7), (7, 11)]  # top, mid, bottom rows


def load_rom(path):
    """Load a 2KB character ROM file."""
    with open(path, "rb") as f:
        data = f.read()
    if len(data) != ROM_SIZE:
        print(f"Warning: ROM {path} is {len(data)} bytes, expected {ROM_SIZE}",
              file=sys.stderr)
    return data


def rom_char_bitmap(rom, code):
    """Extract a character bitmap from ROM as a numpy array.

    Returns 11x7 numpy array (rows x cols), 1=pixel set, 0=clear.
    8275 scans LSB-first, so bit 0 is leftmost pixel.
    Only 7 pixels wide (bits 0-6), bit 7 unused.
    """
    offset = code * BYTES_PER_CHAR
    bitmap = np.zeros((CHAR_H, CHAR_W), dtype=np.uint8)
    for row in range(CHAR_H):
        byte = rom[offset + row]
        for col in range(CHAR_W):
            bitmap[row, col] = (byte >> col) & 1
    return bitmap


def build_charset(rom296_path, rom327_path):
    """Build the full character set from both ROMs.

    Returns dict mapping screen_code -> (bitmap, rom_name).
    Screen codes 0x20-0x7F use ROA296 (chargen).
    Screen codes 0x80-0xFF use ROA327 (semigraphics).
    Codes 0x80-0x9F are 8275 attribute codes (not displayable as chars
    on real hardware), so we skip those.
    """
    rom296 = load_rom(rom296_path)
    rom327 = load_rom(rom327_path)

    charset = {}

    # ROA296: screen codes 0x20-0x7F -> ROM chars 0x20-0x7F
    for code in range(0x20, 0x80):
        bmp = rom_char_bitmap(rom296, code)
        charset[code] = (bmp, "ROA296")

    # ROA327: screen codes 0xA0-0xFF -> ROM chars 0x20-0x7F
    # (0x80-0x9F are CRT attributes, skip)
    for code in range(0xA0, 0x100):
        rom_code = code - 0x80  # 0x20-0x7F in ROM
        bmp = rom_char_bitmap(rom327, rom_code)
        charset[code] = (bmp, "ROA327")

    # ROA327: screen codes 0xC0-0xDF -> ROM chars 0x00-0x1F (line drawing)
    # These overlap with the 0xA0+ range above for 0xC0-0xDF,
    # but the ROA327 0x40-0x5F chars are same as ROA296, so keep ROA327
    # version for 0xC0+ which gives line drawing at 0xC0-0xDF
    for code in range(0xC0, 0xE0):
        rom_code = code - 0xC0  # 0x00-0x1F in ROM
        bmp = rom_char_bitmap(rom327, rom_code)
        charset[code] = (bmp, "ROA327-line")

    return charset, rom296, rom327


def image_to_mono(img, target_w, target_h, threshold=128, invert=False):
    """Convert an image to monochrome at the target resolution.

    Scales to fit within target dimensions while preserving aspect ratio.
    Returns numpy array (h x w) with 1=white, 0=black.
    """
    # Convert to grayscale
    img = img.convert("L")

    # Scale to fit within target dimensions, preserving aspect ratio
    src_w, src_h = img.size
    scale = min(target_w / src_w, target_h / src_h)
    new_w = max(1, int(src_w * scale))
    new_h = max(1, int(src_h * scale))
    img = img.resize((new_w, new_h), Image.LANCZOS)

    # Create target-sized canvas (white background)
    canvas = Image.new("L", (target_w, target_h), 255)
    # Center the image
    x_off = (target_w - new_w) // 2
    y_off = (target_h - new_h) // 2
    canvas.paste(img, (x_off, y_off))

    pixels = np.array(canvas)
    mono = (pixels >= threshold).astype(np.uint8)

    if invert:
        mono = 1 - mono

    return mono


def pattern_to_charcode(pattern):
    """Convert 6-bit block pattern to ROA327 character code.

    The 8275 GPA0 field attribute selects ROA327 instead of ROA296.
    ROA327 block patterns are at two ranges:
      pattern 0-31  -> char code 0x20 + pattern  (ROA327 0x20-0x3F)
      pattern 32-63 -> char code 0x60 + (pattern - 32)  (ROA327 0x60-0x7F)
    """
    if pattern < 32:
        return 0x20 + pattern
    else:
        return 0x60 + (pattern - 32)


def convert_block_mode(mono):
    """Convert 160x72 monochrome image to screen buffer using 2x3 blocks.

    Uses 8275 field attribute 0x84 (GPA0=1) to select ROA327 semigraphics ROM.
    The field attribute takes one screen position (displayed as blank) at the
    start of the first row; it persists for subsequent rows.

    Returns 24x80 array of screen bytes (including field attribute codes).
    All 64 block patterns (0-63) are supported.
    """
    screen = np.zeros((SCREEN_ROWS, SCREEN_COLS), dtype=np.uint8)

    for row in range(SCREEN_ROWS):
        for col in range(SCREEN_COLS):
            # First position of first row: field attribute to enable GPA0
            if row == 0 and col == 0:
                screen[row, col] = 0x84  # field attr: GPA0=1
                continue

            # Compute 6-bit pattern from 2x3 sub-block
            pattern = 0
            for sub_row in range(BLOCK_ROWS):
                for sub_col in range(BLOCK_COLS):
                    px = col * BLOCK_COLS + sub_col
                    py = row * BLOCK_ROWS + sub_row
                    if py < mono.shape[0] and px < mono.shape[1]:
                        if mono[py, px] == 0:  # dark pixel = set block
                            bit = sub_row * 2 + sub_col
                            pattern |= (1 << bit)

            screen[row, col] = pattern_to_charcode(pattern)

    return screen


def convert_full_mode(mono, charset):
    """Convert image to screen codes by matching against all ROM characters.

    Input: monochrome image at 560x264 (80*7 x 24*11) resolution.
    Returns 24x80 array of screen codes.
    """
    screen = np.zeros((SCREEN_ROWS, SCREEN_COLS), dtype=np.uint8)

    # Precompute character bitmaps as flat arrays for fast comparison
    char_list = []
    for code, (bmp, _) in sorted(charset.items()):
        char_list.append((code, bmp.flatten().astype(np.int16)))

    for row in range(SCREEN_ROWS):
        for col in range(SCREEN_COLS):
            # Extract the cell from the input image
            y0 = row * CHAR_H
            x0 = col * CHAR_W
            cell = np.zeros((CHAR_H, CHAR_W), dtype=np.int16)
            for dy in range(CHAR_H):
                for dx in range(CHAR_W):
                    py, px = y0 + dy, x0 + dx
                    if py < mono.shape[0] and px < mono.shape[1]:
                        # In ROM: 1=pixel set (dark). Input: 0=black (dark)
                        cell[dy, dx] = 1 if mono[py, px] == 0 else 0

            cell_flat = cell.flatten()

            # Find best matching character (minimize pixel differences)
            best_code = 0x20
            best_diff = CHAR_H * CHAR_W + 1

            for code, bmp_flat in char_list:
                diff = np.sum(np.abs(cell_flat - bmp_flat))
                if diff < best_diff:
                    best_diff = diff
                    best_code = code
                    if diff == 0:
                        break

            screen[row, col] = best_code

    return screen


def charcode_to_pattern(code, gpa0_active):
    """Decode a screen byte to a 6-bit block pattern, or -1 if not a block.

    When gpa0_active, character codes are looked up in ROA327:
      0x20-0x3F -> pattern 0-31
      0x60-0x7F -> pattern 32-63
    """
    if not gpa0_active:
        return -1
    if 0x20 <= code <= 0x3F:
        return code - 0x20
    elif 0x60 <= code <= 0x7F:
        return code - 0x60 + 32
    return -1


def screen_to_text(screen):
    """Convert screen codes to a text preview."""
    lines = []
    gpa0 = False  # track GPA0 state from field attributes
    for row in range(SCREEN_ROWS):
        line = ""
        for col in range(SCREEN_COLS):
            code = screen[row, col]

            # Check for field attribute codes (0x80-0xBF)
            if 0x80 <= code <= 0xBF:
                gpa0 = bool(code & 0x04)  # GPA0 is bit 2
                line += " "  # field attr position is blank
                continue

            p = charcode_to_pattern(code, gpa0)
            if p >= 0:
                # Map 2x3 pattern to Unicode (approximate with 2x2 blocks)
                tl = bool(p & 0x01)
                tr = bool(p & 0x02)
                ml = bool(p & 0x04)
                mr = bool(p & 0x08)
                bl = bool(p & 0x10)
                br = bool(p & 0x20)
                upper = (tl or ml)
                upper_r = (tr or mr)
                lower = bl
                lower_r = br
                idx = (upper << 0) | (upper_r << 1) | (lower << 2) | (lower_r << 3)
                quadrants = " ▘▝▀▖▌▞▛▗▚▐▜▄▙▟█"
                line += quadrants[idx]
            elif 0x20 <= code <= 0x7E:
                line += chr(code)
            else:
                line += "?"
        lines.append(line)
    return "\n".join(lines)


def render_screen_to_image(screen, rom296, rom327, scale=2):
    """Render screen codes to a PNG image using actual ROM glyphs.

    Tracks 8275 field attribute GPA0 state to select between ROA296/ROA327.
    Field attribute positions (0x80-0xBF) render as blank.
    """
    img_w = SCREEN_COLS * CHAR_W * scale
    img_h = SCREEN_ROWS * CHAR_H * scale
    img = Image.new("RGB", (img_w, img_h), (0, 0, 0))
    pixels = img.load()

    green = (0, 200, 0)  # RC702 green phosphor
    black = (0, 0, 0)

    gpa0 = False  # track GPA0 state from field attributes

    for row in range(SCREEN_ROWS):
        for col in range(SCREEN_COLS):
            code = screen[row, col]

            # Check for field attribute codes (0x80-0xBF)
            if 0x80 <= code <= 0xBF:
                gpa0 = bool(code & 0x04)  # GPA0 is bit 2
                continue  # field attr position is blank (black)

            # Select ROM based on GPA0 state
            if gpa0:
                rom = rom327
            else:
                rom = rom296
            rom_code = code & 0x7F

            # Get character bitmap
            offset = int(rom_code) * BYTES_PER_CHAR
            for dy in range(CHAR_H):
                byte = rom[offset + dy]
                for dx in range(CHAR_W):
                    pixel_on = (byte >> dx) & 1
                    color = green if pixel_on else black
                    for sy in range(scale):
                        for sx in range(scale):
                            px = (col * CHAR_W + dx) * scale + sx
                            py = (row * CHAR_H + dy) * scale + sy
                            pixels[px, py] = color

    return img


def generate_test_images(output_dir):
    """Generate test images for conversion testing."""
    os.makedirs(output_dir, exist_ok=True)
    images = []

    # 1. Simple smiley face (works well at low resolution)
    img = Image.new("1", (64, 64), 1)
    draw = ImageDraw.Draw(img)
    # Face outline
    draw.ellipse([8, 8, 55, 55], outline=0, width=2)
    # Eyes
    draw.ellipse([20, 18, 27, 28], fill=0)
    draw.ellipse([36, 18, 43, 28], fill=0)
    # Mouth
    draw.arc([18, 28, 45, 48], 0, 180, fill=0, width=2)
    path = os.path.join(output_dir, "smiley.png")
    img.save(path)
    images.append(("smiley.png", path))

    # 2. Ghost (Pac-Man style)
    img = Image.new("1", (48, 56), 1)
    draw = ImageDraw.Draw(img)
    # Body (rounded top, wavy bottom)
    draw.pieslice([8, 4, 39, 38], 180, 0, fill=0)  # top dome
    draw.rectangle([8, 20, 39, 46], fill=0)          # body
    # Wavy bottom
    for x in range(8, 40, 8):
        draw.pieslice([x, 40, x + 8, 52], 0, 180, fill=1)
    # Eyes (white)
    draw.ellipse([14, 14, 22, 24], fill=1)
    draw.ellipse([26, 14, 34, 24], fill=1)
    # Pupils
    draw.ellipse([17, 16, 21, 22], fill=0)
    draw.ellipse([29, 16, 33, 22], fill=0)
    path = os.path.join(output_dir, "ghost.png")
    img.save(path)
    images.append(("ghost.png", path))

    # 3. House
    img = Image.new("1", (64, 56), 1)
    draw = ImageDraw.Draw(img)
    # Roof
    draw.polygon([(32, 4), (8, 24), (56, 24)], outline=0, width=2)
    # Walls
    draw.rectangle([12, 24, 52, 50], outline=0, width=2)
    # Door
    draw.rectangle([26, 34, 38, 50], outline=0, width=2)
    # Window left
    draw.rectangle([16, 28, 24, 34], outline=0, width=2)
    # Window right
    draw.rectangle([40, 28, 48, 34], outline=0, width=2)
    # Chimney
    draw.rectangle([42, 8, 48, 20], outline=0, width=2)
    path = os.path.join(output_dir, "house.png")
    img.save(path)
    images.append(("house.png", path))

    # 4. Star
    img = Image.new("1", (64, 64), 1)
    draw = ImageDraw.Draw(img)
    # 5-pointed star
    cx, cy, r_out, r_in = 32, 32, 28, 12
    points = []
    for i in range(10):
        angle = math.radians(i * 36 - 90)
        r = r_out if i % 2 == 0 else r_in
        points.append((cx + r * math.cos(angle), cy + r * math.sin(angle)))
    draw.polygon(points, fill=0)
    path = os.path.join(output_dir, "star.png")
    img.save(path)
    images.append(("star.png", path))

    # 5. Cat silhouette
    img = Image.new("1", (56, 64), 1)
    draw = ImageDraw.Draw(img)
    # Head
    draw.ellipse([14, 14, 42, 42], fill=0)
    # Ears (triangles)
    draw.polygon([(14, 18), (8, 2), (22, 14)], fill=0)
    draw.polygon([(42, 18), (48, 2), (34, 14)], fill=0)
    # Body
    draw.ellipse([16, 34, 40, 58], fill=0)
    # Eyes (white)
    draw.ellipse([20, 22, 26, 30], fill=1)
    draw.ellipse([30, 22, 36, 30], fill=1)
    # Pupils
    draw.ellipse([22, 24, 25, 28], fill=0)
    draw.ellipse([32, 24, 35, 28], fill=0)
    # Nose
    draw.polygon([(27, 32), (29, 32), (28, 34)], fill=1)
    # Whiskers
    draw.line([(28, 33), (18, 30)], fill=1, width=1)
    draw.line([(28, 33), (38, 30)], fill=1, width=1)
    draw.line([(28, 34), (18, 34)], fill=1, width=1)
    draw.line([(28, 34), (38, 34)], fill=1, width=1)
    # Tail
    draw.arc([34, 42, 52, 62], 270, 90, fill=0, width=3)
    path = os.path.join(output_dir, "cat.png")
    img.save(path)
    images.append(("cat.png", path))

    # 6. RC logo text "RC" in blocky pixel font
    img = Image.new("1", (80, 40), 1)
    draw = ImageDraw.Draw(img)
    # R
    draw.rectangle([8, 8, 12, 32], fill=0)   # vertical
    draw.rectangle([12, 8, 28, 12], fill=0)   # top
    draw.rectangle([24, 12, 28, 20], fill=0)  # right upper
    draw.rectangle([12, 18, 28, 22], fill=0)  # middle
    draw.line([(16, 22), (28, 32)], fill=0, width=3)  # leg
    # C
    draw.rectangle([40, 8, 44, 32], fill=0)   # vertical
    draw.rectangle([44, 8, 60, 12], fill=0)   # top
    draw.rectangle([44, 28, 60, 32], fill=0)  # bottom
    path = os.path.join(output_dir, "rc_logo.png")
    img.save(path)
    images.append(("rc_logo.png", path))

    return images


def show_charset_image(rom296, rom327, output_path, scale=3):
    """Render both ROM charsets to a PNG for reference."""
    # 16 chars per row, 8 rows = 128 chars per ROM
    chars_per_row = 16
    rows_per_rom = 8

    margin = 4
    cell_w = (CHAR_W + margin) * scale
    cell_h = (CHAR_H + margin) * scale

    img_w = chars_per_row * cell_w + margin * scale
    img_h = (rows_per_rom * 2 + 1) * cell_h + margin * scale  # +1 for label row

    img = Image.new("RGB", (img_w, img_h), (40, 40, 40))
    draw = ImageDraw.Draw(img)

    green = (0, 200, 0)

    for rom_idx, (rom, label) in enumerate([(rom296, "ROA296"), (rom327, "ROA327")]):
        y_base = rom_idx * (rows_per_rom * cell_h + cell_h)

        for code in range(128):
            row = code // chars_per_row
            col = code % chars_per_row

            x0 = col * cell_w + margin * scale
            y0 = y_base + row * cell_h + margin * scale

            offset = code * BYTES_PER_CHAR
            for dy in range(CHAR_H):
                byte = rom[offset + dy]
                for dx in range(CHAR_W):
                    if (byte >> dx) & 1:
                        for sy in range(scale):
                            for sx in range(scale):
                                px = x0 + dx * scale + sx
                                py = y0 + dy * scale + sy
                                if 0 <= px < img_w and 0 <= py < img_h:
                                    img.putpixel((px, py), green)

    img.save(output_path)
    print(f"Charset image saved to {output_path}")


def find_roms():
    """Find ROM files in common locations."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_dir = os.path.dirname(script_dir)

    search_paths = [
        # MAME roms directory
        os.path.join(project_dir, "..", "mame", "roms", "rc702"),
        # rc700 emulator directory
        os.path.join(project_dir, "..", "rc700"),
        # Local roms directory
        os.path.join(project_dir, "roms"),
    ]

    rom296 = rom327 = None
    for base in search_paths:
        r296 = os.path.join(base, "roa296.rom")
        r327 = os.path.join(base, "roa327.rom")
        if os.path.exists(r296) and os.path.exists(r327):
            rom296, rom327 = r296, r327
            break

    return rom296, rom327


def main():
    parser = argparse.ArgumentParser(
        description="Convert monochrome bitmap to RC702 screen output")
    parser.add_argument("input", nargs="?", help="Input image file")
    parser.add_argument("--mode", choices=["block", "full"], default="block",
                        help="block=2x3 semigraphics (160x72), "
                             "full=character matching (80x24)")
    parser.add_argument("--output", choices=["text", "binary", "png"],
                        default="text", help="Output format")
    parser.add_argument("-o", "--outfile", help="Output file path")
    parser.add_argument("--invert", action="store_true",
                        help="Invert image (swap black/white)")
    parser.add_argument("--threshold", type=int, default=128,
                        help="B/W threshold 0-255 (default: 128)")
    parser.add_argument("--scale", type=int, default=2,
                        help="PNG output scale factor (default: 2)")
    parser.add_argument("--rom296", help="Path to ROA296 chargen ROM")
    parser.add_argument("--rom327", help="Path to ROA327 semigraphics ROM")
    parser.add_argument("--test", action="store_true",
                        help="Generate test images and convert them")
    parser.add_argument("--show-charset", action="store_true",
                        help="Render ROM charset to PNG")
    args = parser.parse_args()

    # Find ROMs
    rom296_path = args.rom296
    rom327_path = args.rom327
    if not rom296_path or not rom327_path:
        found296, found327 = find_roms()
        rom296_path = rom296_path or found296
        rom327_path = rom327_path or found327

    if not rom296_path or not rom327_path:
        print("Cannot find ROM files. Specify --rom296 and --rom327.",
              file=sys.stderr)
        sys.exit(1)

    rom296 = load_rom(rom296_path)
    rom327 = load_rom(rom327_path)

    if args.show_charset:
        out = args.outfile or "rc702_charset.png"
        show_charset_image(rom296, rom327, out, args.scale)
        return

    if args.test:
        test_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                "test_images")
        test_images = generate_test_images(test_dir)
        print(f"Generated {len(test_images)} test images in {test_dir}/")

        charset, _, _ = build_charset(rom296_path, rom327_path)

        for name, path in test_images:
            print(f"\n{'='*80}")
            print(f"  {name} (block mode)")
            print(f"{'='*80}")

            img = Image.open(path)
            mono = image_to_mono(img, GFX_W, GFX_H, args.threshold,
                                 invert=args.invert)
            screen = convert_block_mode(mono)
            print(screen_to_text(screen))

            # Save binary screen buffer
            bin_path = os.path.join(test_dir, name.replace(".png", ".bin"))
            with open(bin_path, "wb") as f:
                for r in range(SCREEN_ROWS):
                    f.write(bytes(screen[r]))

            # Also save PNG preview
            png_path = os.path.join(test_dir, name.replace(".png", "_rc702.png"))
            preview = render_screen_to_image(screen, rom296, rom327, args.scale)
            preview.save(png_path)

            # Full mode too
            print(f"\n{'='*80}")
            print(f"  {name} (full mode)")
            print(f"{'='*80}")

            mono_full = image_to_mono(img, SCREEN_COLS * CHAR_W,
                                       SCREEN_ROWS * CHAR_H,
                                       args.threshold, invert=args.invert)
            screen_full = convert_full_mode(mono_full, charset)

            png_path = os.path.join(test_dir,
                                     name.replace(".png", "_rc702_full.png"))
            preview = render_screen_to_image(screen_full, rom296, rom327,
                                              args.scale)
            preview.save(png_path)
            print(f"  (saved to {png_path})")

        print(f"\nAll previews saved to {test_dir}/")
        return

    if not args.input:
        parser.print_help()
        sys.exit(1)

    # Load and convert input image
    img = Image.open(args.input)

    charset, _, _ = build_charset(rom296_path, rom327_path)

    if args.mode == "block":
        mono = image_to_mono(img, GFX_W, GFX_H, args.threshold,
                             invert=args.invert)
        screen = convert_block_mode(mono)
    else:
        mono = image_to_mono(img, SCREEN_COLS * CHAR_W,
                             SCREEN_ROWS * CHAR_H,
                             args.threshold, invert=args.invert)
        screen = convert_full_mode(mono, charset)

    # Output
    if args.output == "text":
        print(screen_to_text(screen))
    elif args.output == "binary":
        out = args.outfile or "screen.bin"
        with open(out, "wb") as f:
            for row in range(SCREEN_ROWS):
                f.write(bytes(screen[row]))
        print(f"Screen buffer saved to {out} (1920 bytes)", file=sys.stderr)
    elif args.output == "png":
        out = args.outfile or "rc702_preview.png"
        preview = render_screen_to_image(screen, rom296, rom327, args.scale)
        preview.save(out)
        print(f"Preview saved to {out}", file=sys.stderr)


if __name__ == "__main__":
    main()
