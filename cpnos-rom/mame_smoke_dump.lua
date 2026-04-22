-- Periodically dump the SNIOS BDOS-FNC counter table at 0xEC80..0xECFF
-- to /tmp/cpnos_fnc_counters.txt so we can see which BDOS functions the
-- slave actually forwards over CP/NET during a smoke run.
--
-- The counters are saturating uint8 at counter[0xEC80 + (FNC & 0x7F)];
-- SNDMSG in snios.s bumps them on every call.

local f = io.open("/tmp/cpnos_fnc_counters.txt", "w")
f:write("tick   (per-FNC delta since last snapshot; '*' = saturated)\n")
f:close()

-- Tap every CPU fetch of 0x0005 (CP/M BDOS entry).  On hit, log
-- C register (BDOS FN code) and DE (param).  Gives us the FULL
-- BDOS call stream including local-only fns like SET_DMA (26) and
-- PRINT_STRING (9) that our SNIOS counter misses.
local bdos_log = io.open("/tmp/cpnos_bdos_trace.txt", "w")
bdos_log:write("pc=0005 tap: fn de pc_caller\n")
bdos_log:close()

bdos_tap = nil
bdos_tap_installed = false

emu.register_periodic(function()
    if bdos_tap_installed then return end
    local cpu3 = manager.machine.devices[":maincpu"]
    if cpu3 == nil then return end
    local space = cpu3.spaces["program"]
    if space == nil then return end
    bdos_tap = space:install_read_tap(
        0x0005, 0x0005, "bdos_entry",
        function(offset, data)
            local st = cpu3.state
            local c = st["C"].value
            local de = st["DE"].value
            local sp = st["SP"].value
            local caller_lo = space:read_u8(sp)
            local caller_hi = space:read_u8(sp + 1)
            local caller = caller_hi * 256 + caller_lo - 3
            local bl = io.open("/tmp/cpnos_bdos_trace.txt", "a")
            bl:write(string.format("fn=%3d DE=0x%04x caller=0x%04x\n",
                                    c, de, caller))
            bl:close()
        end)
    bdos_tap_installed = true
end)

local last_snapshot_tick = 0
local prev = {}
local prev_rs16 = 0
for i = 0, 127 do prev[i] = 0 end

emu.register_periodic(function()
    local cpu = manager.machine.devices[":maincpu"]
    if cpu == nil then return end
    local mem = cpu.spaces["program"]
    if mem == nil then return end
    local now = os.time()
    if now - last_snapshot_tick < 1 then return end
    last_snapshot_tick = now

    local out = io.open("/tmp/cpnos_fnc_counters.txt", "a")
    local rs_lo = mem:read_u8(0xEC7E)
    local rs_hi = mem:read_u8(0xEC7F)
    local rs16 = rs_hi * 256 + rs_lo
    local any = false
    local line = string.format("t=%-8d RS16=%-4d drs=%-4d ",
                                now, rs16, rs16 - prev_rs16)
    for fnc = 0, 127 do
        local v = mem:read_u8(0xEC80 + fnc)
        local d = v - prev[fnc]
        if d ~= 0 then
            any = true
            local sat = (v == 0xFF) and "*" or " "
            line = line .. string.format(" %d%s=%d",
                                          fnc, sat, d)
        end
        prev[fnc] = v
    end
    prev_rs16 = rs16
    if any then
        out:write(line .. "\n")
    end
    out:close()
end)
