-- cpnos-rom SUB-file test gate.
--
-- Exits MAME cleanly when the CP/NOS client writes to port 0x1F.
-- DONE.COM (5 bytes: D3 1F C3 00 00) is the agreed test-done signal:
-- the server seeds $<slave>.SUB with "...|done" and the port write
-- fires the moment CCP has finished running the canned commands.
--
-- Without this tap we'd rely on a fixed -seconds_to_run timeout;
-- the tap exits the instant the test actually completes and catches
-- hangs via the outer timeout as a secondary guard.

-- DONE.COM prints "DONE\r\n" via BDOS fn 9, then JP 0.  We detect
-- completion by polling the SIO-B capture file for the marker --
-- memory / port write taps proved unreliable here (port 0x1F is the
-- beeper, and memory writes from a transient ran but didn't surface
-- in install_write_tap for reasons that were not worth chasing).
-- SIO-B capture is already first-class test evidence so reusing it
-- as the finish signal is clean.
local SIOB_FILE   = "/tmp/cpnos_siob.raw"
local DONE_MARK   = "DONE\r\n"
local RESULT_FILE = "/tmp/cpnos_boot_result.txt"
local done = false
local frame = 0

local function finish(result)
    if done then return end
    done = true
    local f = io.open(RESULT_FILE, "w")
    f:write(result .. "\n")
    f:write(string.format("frame=%d (%.1fs emulated)\n", frame, frame / 50.0))
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

-- Poll SIO-B capture every ~0.2 s; exit the instant "DONE\r\n"
-- appears.  Safety net: hard timeout at 20 s if DONE never prints.
emu.register_frame_done(function()
    frame = frame + 1
    if frame % 10 == 0 and sioB_has_done() then
        finish(string.format("PASS: DONE marker on SIO-B at frame %d", frame))
        return
    end
    if frame > 50 * 20 then
        finish("FAIL: 20 s elapsed without DONE marker")
    end
end)
