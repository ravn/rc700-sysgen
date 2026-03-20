-- mame_debug_fdc.lua — Dump g_state when errdsp is called
-- g_state at 0xBF00, errdsp at 0x73CE

local frame = 0
local done = false
local DSPSTR = 0xF800
local PROM_DSP = 0x7800
local RESULT_FILE = "/tmp/boot_test_result.txt"
local G_STATE = 0xBF00
local ERRDSP = 0x73CE

local function hex(v) return string.format("%02X", v) end
local function hex16(v) return string.format("%04X", v) end

local function read16(space, addr)
    return space:read_u8(addr) + space:read_u8(addr + 1) * 256
end

local function screen_text(space, base)
    local lines = {}
    for row = 0, 24 do
        local line = ""
        for col = 0, 79 do
            local ch = space:read_u8(base + row * 80 + col)
            line = line .. (ch >= 0x20 and ch < 0x7F and string.char(ch) or " ")
        end
        lines[#lines + 1] = line:gsub("%s+$", "")
    end
    return table.concat(lines, "\n")
end

local function dump_state(space)
    local s = ""
    s = s .. "fdcres:  "
    for i = 0, 6 do s = s .. hex(space:read_u8(G_STATE + i)) .. " " end
    s = s .. "\n"
    s = s .. "fdcflg:  " .. hex(space:read_u8(G_STATE + 7)) .. "\n"
    s = s .. "epts:    " .. hex(space:read_u8(G_STATE + 8)) .. "\n"
    s = s .. "trksz:   " .. hex(space:read_u8(G_STATE + 9)) .. "\n"
    s = s .. "drvsel:  " .. hex(space:read_u8(G_STATE + 10)) .. "\n"
    s = s .. "fdctmo:  " .. hex(space:read_u8(G_STATE + 11)) .. "\n"
    s = s .. "fdcwai:  " .. hex(space:read_u8(G_STATE + 12)) .. "\n"
    s = s .. "spsav:   " .. hex16(read16(space, G_STATE + 13)) .. "\n"
    s = s .. "combuf:  " .. hex(space:read_u8(G_STATE + 15)) .. " " .. hex(space:read_u8(G_STATE + 16)) .. "\n"
    s = s .. "curcyl:  " .. hex(space:read_u8(G_STATE + 17)) .. "\n"
    s = s .. "curhed:  " .. hex(space:read_u8(G_STATE + 18)) .. "\n"
    s = s .. "currec:  " .. hex(space:read_u8(G_STATE + 19)) .. "\n"
    s = s .. "reclen:  " .. hex(space:read_u8(G_STATE + 20)) .. "\n"
    s = s .. "cureot:  " .. hex(space:read_u8(G_STATE + 21)) .. "\n"
    s = s .. "gap3:    " .. hex(space:read_u8(G_STATE + 22)) .. "\n"
    s = s .. "dtl:     " .. hex(space:read_u8(G_STATE + 23)) .. "\n"
    s = s .. "secbyt:  " .. hex16(read16(space, G_STATE + 24)) .. "\n"
    s = s .. "flpflg:  " .. hex(space:read_u8(G_STATE + 26)) .. "\n"
    s = s .. "flpwai:  " .. hex(space:read_u8(G_STATE + 27)) .. "\n"
    s = s .. "diskbits:" .. hex(space:read_u8(G_STATE + 28)) .. "\n"
    s = s .. "dsktyp:  " .. hex(space:read_u8(G_STATE + 29)) .. "\n"
    s = s .. "morefl:  " .. hex(space:read_u8(G_STATE + 30)) .. "\n"
    s = s .. "reptim:  " .. hex(space:read_u8(G_STATE + 31)) .. "\n"
    s = s .. "memadr:  " .. hex16(read16(space, G_STATE + 32)) .. "\n"
    s = s .. "trbyt:   " .. hex16(read16(space, G_STATE + 34)) .. "\n"
    s = s .. "trkovr:  " .. hex16(read16(space, G_STATE + 36)) .. "\n"
    s = s .. "errsav:  " .. hex(space:read_u8(G_STATE + 38)) .. "\n"
    return s
end

-- Use breakpoint callback on errdsp
local bp_set = false

emu.register_frame_done(function()
    if done then return end
    frame = frame + 1

    if not bp_set then
        local cpu = manager.machine.devices[":maincpu"]
        local dbg = cpu.debug
        if dbg then
            dbg:bpset(ERRDSP, "1")
            bp_set = true
        end
    end

    -- Check every second
    if frame % 50 ~= 0 then return end

    local space = manager.machine.devices[":maincpu"].spaces["program"]

    -- Check if PC is at errdsp (breakpoint hit)
    local cpu = manager.machine.devices[":maincpu"]
    local pc = cpu.state["PC"].value

    if pc == ERRDSP or frame > 50 * 55 then
        local f = io.open(RESULT_FILE, "w")
        if pc == ERRDSP then
            f:write("ERRDSP hit at frame " .. frame .. "\n\n")
        else
            f:write("TIMEOUT at frame " .. frame .. " PC=" .. hex16(pc) .. "\n\n")
        end
        f:write("=== g_state dump ===\n")
        f:write(dump_state(space))
        f:write("\n--- PROM display (0x7800) ---\n")
        f:write(screen_text(space, PROM_DSP) .. "\n")
        f:write("\n--- BIOS display (0xF800) ---\n")
        f:write(screen_text(space, DSPSTR) .. "\n")
        f:close()
        done = true
        manager.machine:exit()
    end
end)
