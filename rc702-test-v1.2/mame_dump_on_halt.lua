-- Dump RAM 0x0000-0x26FF and quit after test completes.
-- Poll for HALT (0x76) at address 0x0341 as the "test done" signal.
local dbg = manager.machine.debugger
local done = false

emu.register_periodic(function()
    if done then return end
    local cpu = manager.machine.devices[":maincpu"]
    local mem = cpu.spaces["program"]
    local b341 = mem:read_u8(0x0341)
    if b341 == 0x76 then
        done = true
        -- Dump the full low-RAM range that gets filled by ROA375 + LDIR.
        dbg:command("save /tmp/rc702_running_0000.bin,0,0x2700")
        dbg:command("save /tmp/rc702_running_D480.bin,0xD480,0x2700")
        local log = io.open("/tmp/rc702_dump.log", "w")
        log:write(string.format("HALT detected at 0x0341; dumps written.\n"))
        log:write(string.format("bytes at 0x0341..0x0348 = %02X %02X %02X %02X %02X %02X %02X %02X\n",
            mem:read_u8(0x0341), mem:read_u8(0x0342), mem:read_u8(0x0343),
            mem:read_u8(0x0344), mem:read_u8(0x0345), mem:read_u8(0x0346),
            mem:read_u8(0x0347), mem:read_u8(0x0348)))
        log:close()
        -- Give the save commands a moment to complete, then exit
        manager.machine:schedule_exit()
    end
end)
