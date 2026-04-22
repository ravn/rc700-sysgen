-- Periodically dump the SNIOS BDOS-FNC counter table at 0xEC80..0xECFF
-- to /tmp/cpnos_fnc_counters.txt so we can see which BDOS functions the
-- slave actually forwards over CP/NET during a smoke run.
--
-- The counters are saturating uint8 at counter[0xEC80 + (FNC & 0x7F)];
-- SNDMSG in snios.s bumps them on every call.

local f = io.open("/tmp/cpnos_fnc_counters.txt", "w")
f:write("tick   (per-FNC delta since last snapshot; '*' = saturated)\n")
f:close()

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
