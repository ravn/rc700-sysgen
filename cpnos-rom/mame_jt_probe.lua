-- Probe JT integrity.  Runs MAME for ~25s, then dumps:
--   * display row 0 + row 1 (CCP output / boot markers)
--   * 0xED00..0xED33  — our linked BIOS JT
--   * 0xCF00..0xCF33  — NDOS-patched copy CCP actually calls through
-- Result file: /tmp/cpnos_jt_probe.txt
local frame = 0
local done = false
local OUT = "/tmp/cpnos_jt_probe.txt"

local function row_text(space, base)
    local out = ""
    for col = 0, 79 do
        local ch = space:read_u8(base + col)
        out = out .. (ch >= 0x20 and ch < 0x7F and string.char(ch) or ".")
    end
    return out
end

local function decode_jt(space, base, label)
    local lines = {label}
    local names = {
        "boot   ", "wboot  ", "const  ", "conin  ", "conout ",
        "list   ", "punch  ", "reader ", "home   ", "seldsk ",
        "settrk ", "setsec ", "setdma ", "read   ", "write  ",
        "listst ", "sectran",
    }
    for i = 0, 16 do
        local addr = base + i * 3
        local b0 = space:read_u8(addr)
        local b1 = space:read_u8(addr + 1)
        local b2 = space:read_u8(addr + 2)
        local tgt = b1 + b2 * 256
        local mark = (b0 == 0xC3) and "JP" or "??"
        lines[#lines + 1] = string.format(
            "  %04X  %s %02x %02x %02x  -> %04X %s",
            addr, names[i + 1], b0, b1, b2, tgt, mark)
    end
    return table.concat(lines, "\n")
end

emu.register_frame_done(function()
    if done then return end
    frame = frame + 1
    if frame < 25 * 50 then return end  -- wait 25s

    done = true
    local space = manager.machine.devices[":maincpu"].spaces["program"]
    local f = io.open(OUT, "w")
    f:write(string.format("frame=%d (%.1fs)\n", frame, frame / 50.0))
    local pc = manager.machine.devices[":maincpu"].state["PC"].value
    local sp = manager.machine.devices[":maincpu"].state["SP"].value
    f:write(string.format("PC=%04X  SP=%04X\n", pc, sp))
    f:write("\nrow 0 (CCP / loader): " .. row_text(space, 0xF800) .. "\n")
    f:write("row 1 (boot markers): " .. row_text(space, 0xF800 + 80) .. "\n")
    f:write("\n=== ED00 (linked BIOS JT) ===\n")
    f:write(decode_jt(space, 0xED00, "addr  entry    bytes      tgt") .. "\n")
    f:write("\n=== CF00 (NDOS-patched copy = NDOSRL+0x300) ===\n")
    f:write(decode_jt(space, 0xCF00, "addr  entry    bytes      tgt") .. "\n")
    f:close()
    manager.machine:exit()
end)
