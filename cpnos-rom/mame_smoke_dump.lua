-- Periodically dump the SNIOS BDOS-FNC counter table at 0xEC80..0xECFF
-- to /tmp/cpnos_fnc_counters.txt so we can see which BDOS functions the
-- slave actually forwards over CP/NET during a smoke run.
--
-- The counters are saturating uint8 at counter[0xEC80 + (FNC & 0x7F)];
-- SNDMSG in snios.s bumps them on every call.

local f = io.open("/tmp/cpnos_fnc_counters.txt", "w")
f:write("tick   FNC_code_with_nonzero_count  (format: FNC=n count=m)\n")
f:close()

local last_snapshot_tick = 0

emu.register_periodic(function()
    local cpu = manager.machine.devices[":maincpu"]
    if cpu == nil then return end
    local mem = cpu.spaces["program"]
    if mem == nil then return end
    local now = os.time()
    if now - last_snapshot_tick < 2 then return end
    last_snapshot_tick = now

    local out = io.open("/tmp/cpnos_fnc_counters.txt", "a")
    out:write(string.format("--- t=%d ---\n", now))
    for fnc = 0, 127 do
        local v = mem:read_u8(0xEC80 + fnc)
        if v ~= 0 then
            out:write(string.format("  FNC=%3d (0x%02X)  count=%d\n",
                                    fnc, fnc, v))
        end
    end
    out:close()
end)
