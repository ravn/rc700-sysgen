-- cpnos-rom CONOUT acid-test gate.
--
-- Parallel to mame_sub_test.lua: waits for the DONE\r\n marker on
-- SIO-B, then dumps the 8275 display RAM (0xF800..0xFFFF) to a file
-- and asserts specific cells that the 15 RC700 control codes were
-- supposed to leave behind.  Pass/fail is written to
-- /tmp/cpnos_boot_result.txt for the Makefile gate.

local SIOB_FILE   = "/tmp/cpnos_siob.raw"
local DONE_MARK   = "DONE\r\n"
local RESULT_FILE = "/tmp/cpnos_boot_result.txt"
local DISPLAY_DUMP = "/tmp/cpnos_display.txt"
local done = false
local frame = 0

local SCRN_COLS = 80
local SCRN_ROWS = 24
local DISPLAY_BASE = 0xF800

local function cpu_space()
    -- Main CPU program space.  RC702 has a single Z80, accessed via
    -- manager.machine.devices[":maincpu"].spaces["program"].
    return manager.machine.devices[":maincpu"].spaces["program"]
end

local function cell_at(x, y)
    return cpu_space():read_u8(DISPLAY_BASE + y * SCRN_COLS + x)
end

local function row_string(y)
    local buf = {}
    for x = 0, SCRN_COLS - 1 do
        local b = cell_at(x, y)
        if b < 0x20 or b > 0x7E then
            buf[#buf + 1] = "."
        else
            buf[#buf + 1] = string.char(b)
        end
    end
    return table.concat(buf)
end

-- Exactly the layout acid.c sets up.  Each {x, y, byte, label}.
local EXPECTED_CELLS = {
    -- "HELLO!" at row 5, cols 20..25
    {20,  5, 0x48, "H (start_xy)"},
    {21,  5, 0x45, "E"},
    {22,  5, 0x4C, "L"},
    {23,  5, 0x4C, "L"},
    {24,  5, 0x4F, "O"},
    {25,  5, 0x21, "!"},
    -- erase_to_eol left "KEEP" on row 7, everything else blank
    {0,  7, 0x4B, "K (erase_to_eol keeps prefix)"},
    {1,  7, 0x45, "E"},
    {2,  7, 0x45, "E"},
    {3,  7, 0x50, "P"},
    {4,  7, 0x20, "space after erase_to_eol"},
    {20, 7, 0x20, "mid-row blank after erase_to_eol"},
    -- Eyes on row 10 (cursor_right arithmetic)
    {4,  10, 0x3A, ": left eye (start_xy)"},
    {10, 10, 0x3A, ": right eye (5x cursor_right)"},
    -- Mouth on row 11, cols 4..10: "\UUUUU)"  (')' overwrote '/' via ENQ)
    {4,  11, 0x5C, "\\ (CR+cursor_down+cursor_right)"},
    {5,  11, 0x55, "U"},
    {9,  11, 0x55, "U"},
    {10, 11, 0x29, ") from ENQ-overwrite"},
    -- BS (0x08) test on row 13 -- "ABC" overwrote "XYZ"
    {0,  13, 0x41, "A (BS overwrote XYZ[0])"},
    {1,  13, 0x42, "B"},
    {2,  13, 0x43, "C"},
    -- TAB (0x09) test on row 14 -- T at col 0, TAB = 4x cursor_right,
    -- so X lands at col 5 (T wrote at 0, bumped cursor to 1, +4 -> 5).
    {0,  14, 0x54, "T"},
    {5,  14, 0x58, "X (cursor after TAB advanced 4 cols)"},
    -- cursor_up (0x1A): U lands at (1,15), D at (0,16)
    {1,  15, 0x55, "U (after cursor_up)"},
    {0,  16, 0x44, "D"},
    -- erase_to_eos: rows 20..23 all blank
    {0,  20, 0x20, "row 20 blanked by erase_to_eos"},
    {2,  22, 0x20, "row 22 blanked by erase_to_eos"},
    {4,  23, 0x20, "row 23 blanked by erase_to_eos"},
    -- insert_line/delete_line round-trip: STAY + GONE back on rows 3/4
    {0,  3, 0x53, "S (insert+delete returns STAY)"},
    {1,  3, 0x54, "T"},
    {0,  4, 0x47, "G (insert+delete returns GONE)"},
    {1,  4, 0x4F, "O"},
}

local function dump_display()
    local f = io.open(DISPLAY_DUMP, "w")
    if not f then return end
    for y = 0, SCRN_ROWS - 1 do
        f:write(string.format("%02d  |%s|\n", y, row_string(y)))
    end
    f:close()
end

local function verify_cells()
    local fails = {}
    for _, t in ipairs(EXPECTED_CELLS) do
        local x, y, want, label = t[1], t[2], t[3], t[4]
        local got = cell_at(x, y)
        if got ~= want then
            fails[#fails + 1] = string.format(
                "(%d,%d) want 0x%02X got 0x%02X  [%s]",
                x, y, want, got, label)
        end
    end
    return fails
end

local function finish(result)
    if done then return end
    done = true
    dump_display()
    local f = io.open(RESULT_FILE, "w")
    f:write(result .. "\n")
    f:write(string.format("frame=%d (%.1fs emulated)\n", frame, frame / 50.0))
    f:write("display dump: " .. DISPLAY_DUMP .. "\n")
    f:close()
    manager.machine:exit()
end

local function sioB_has_done()
    local f = io.open(SIOB_FILE, "rb")
    if not f then return false end
    local data = f:read("*a")
    f:close()
    return data:find(DONE_MARK, 1, true) ~= nil
end

emu.register_frame_done(function()
    frame = frame + 1
    if frame % 10 == 0 and sioB_has_done() then
        local fails = verify_cells()
        if #fails == 0 then
            finish(string.format("PASS: all 15 CONOUT codes verified at frame %d", frame))
        else
            local msg = "FAIL: " .. #fails .. " cell mismatch(es)\n"
            for _, s in ipairs(fails) do msg = msg .. "  " .. s .. "\n" end
            finish(msg)
        end
        return
    end
    if frame > 50 * 90 then
        finish("FAIL: 90 s elapsed without DONE marker on SIO-B")
    end
end)
