-- mame_trace_fdc.lua — High-frequency trace of flpflg during boot

local frame = 0
local done = false
local G_STATE = 0xBF00
local RESULT_FILE = "/tmp/boot_test_result.txt"
local trace = {}
local last_flpflg = -1
local isr_count = 0

local function hex(v) return string.format("%02X", v) end

-- Use periodic callback for higher resolution
emu.register_periodic(function()
    if done then return end

    local space = manager.machine.devices[":maincpu"].spaces["program"]
    local cpu = manager.machine.devices[":maincpu"]
    local pc = cpu.state["PC"].value
    local flpflg = space:read_u8(G_STATE + 26)

    if flpflg ~= last_flpflg then
        isr_count = isr_count + 1
        trace[#trace + 1] = string.format("flpflg: %02X->%02X PC=%04X (#%d)",
            last_flpflg == -1 and 0 or last_flpflg, flpflg, pc, isr_count)
        last_flpflg = flpflg
    end

    -- Detect halt_forever (JR -2 = 18 FE)
    if pc >= 0x7000 and pc <= 0x7FFF then
        if space:read_u8(pc) == 0x18 and space:read_u8(pc + 1) == 0xFE then
            trace[#trace + 1] = string.format("HALT at PC=%04X", pc)
            trace[#trace + 1] = string.format("  fdcres: %s %s %s %s %s %s %s",
                hex(space:read_u8(G_STATE)), hex(space:read_u8(G_STATE+1)),
                hex(space:read_u8(G_STATE+2)), hex(space:read_u8(G_STATE+3)),
                hex(space:read_u8(G_STATE+4)), hex(space:read_u8(G_STATE+5)),
                hex(space:read_u8(G_STATE+6)))
            trace[#trace + 1] = string.format("  errsav=%s reptim=%s flpflg=%s diskbits=%s",
                hex(space:read_u8(G_STATE+38)), hex(space:read_u8(G_STATE+31)),
                hex(flpflg), hex(space:read_u8(G_STATE+28)))
            local mem0 = ""
            for i = 0, 15 do mem0 = mem0 .. hex(space:read_u8(i)) .. " " end
            trace[#trace + 1] = "  mem@0000: " .. mem0
            trace[#trace + 1] = string.format("  isr_count=%d", isr_count)

            local f = io.open(RESULT_FILE, "w")
            for _, line in ipairs(trace) do f:write(line .. "\n") end
            f:close()
            done = true
            manager.machine:exit()
        end
    end
end, 0.0001) -- every 0.1ms
