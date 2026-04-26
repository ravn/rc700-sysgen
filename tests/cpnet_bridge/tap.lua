-- license: BSD-3-Clause
--
-- MAME autoboot script — CP/NET fast-link bring-up test tap.
--
-- Two responsibilities:
--   1. Watch the boot-progress strip on row 1 for "INIT OK" — that's
--      the marker init.c writes once init_hardware completes (which
--      includes arming PIO-B for IRQ-driven receive).  When it appears,
--      write "READY\n" to /tmp/cpnos_bridge_ready.txt so the harness
--      knows the Z80 is ready to receive bytes via PIO-B.
--   2. Install a write-tap on the BSS counter that isr_pio_par
--      increments.  Each fire appends a line to
--      /tmp/cpnos_bridge_tap.log so the harness can verify the byte
--      stream.
--
-- Pattern: lazy init from inside register_periodic.  emu.register_start
-- is deprecated on current MAME and its callback does not always fire;
-- register_periodic does, and we guard against the maincpu not yet
-- being available.  Same pattern as cpnos-rom/mame_smoke_dump.lua.
--
-- BSS addresses come from /tmp/cpnos_bridge_addrs.lua, written by the
-- harness from `llvm-nm cpnos-rom/clang/payload.elf` so they stay
-- in sync with the just-built payload.  Hardcoding addresses here
-- guaranteed silent drift the moment BSS layout shifted.
--
-- Display: 0xF800 = row 0; row 1 starts at 0xF850 (DISPLAY_ADDR + 80).
-- BOOT_MARK(col, ch) writes 0xF850 + col, so init.c's "INIT OK" lands
-- at 0xF850..0xF856.

local addrs = dofile("/tmp/cpnos_bridge_addrs.lua")
local PIO_PAR_BYTE_ADDR  = addrs.pio_par_byte
local PIO_PAR_COUNT_ADDR = addrs.pio_par_count
local INIT_OK_ADDR       = 0xF850   -- row 1 col 0

local READY_FILE = "/tmp/cpnos_bridge_ready.txt"
local TAP_LOG    = "/tmp/cpnos_bridge_tap.log"

-- Reset both files on every run so stale data doesn't leak between
-- test invocations.
do
	local f = io.open(READY_FILE, "w") if f then f:close() end
	local f2 = io.open(TAP_LOG, "w")  if f2 then f2:close() end
end

local tap_installed = false
local boot_seen     = false
local prog          = nil
local DEBUG_ROW1    = "/tmp/cpnos_bridge_row1.log"
local last_dump     = ""

do
	local f = io.open(DEBUG_ROW1, "w")  if f then f:close() end
end

emu.register_periodic(function ()
	-- Lazy device discovery — devices[":maincpu"] is nil before the
	-- machine has fully started.
	if prog == nil then
		local cpu = manager.machine.devices[":maincpu"]
		if cpu == nil then return end
		prog = cpu.spaces["program"]
		if prog == nil then return end
	end

	-- (1) Tap on the BSS counter — install once, leave armed.
	if not tap_installed then
		prog:install_write_tap(PIO_PAR_COUNT_ADDR, PIO_PAR_COUNT_ADDR,
			"pio_par_count_tap",
			function (offset, data, mask)
				local byte = prog:read_u8(PIO_PAR_BYTE_ADDR)
				local f = io.open(TAP_LOG, "a")
				if f then
					f:write(string.format("count=%d byte=0x%02X\n", data, byte))
					f:close()
				end
			end)
		tap_installed = true
	end

	-- (2) Boot-progress watch — write READY once "INIT OK" appears on
	-- row 1.  init.c writes that marker the moment init_hardware
	-- completes, which includes arming PIO-B for IRQ-driven receive.
	-- That's the precise prerequisite the harness needs before sending
	-- bytes; netboot completion is irrelevant to this layer.
	if not boot_seen then
		-- Snapshot row 1 (cols 0..15) to a debug log when it changes.
		local s = ""
		for i = 0, 15 do
			local b = prog:read_u8(INIT_OK_ADDR + i)
			s = s .. string.format("%02X ", b)
		end
		if s ~= last_dump then
			local f = io.open(DEBUG_ROW1, "a")
			if f then f:write(s .. "\n") f:close() end
			last_dump = s
		end

		-- "INIT OK" = 49 4E 49 54 20 4F 4B
		if  prog:read_u8(INIT_OK_ADDR + 0) == 0x49
		and prog:read_u8(INIT_OK_ADDR + 1) == 0x4E
		and prog:read_u8(INIT_OK_ADDR + 2) == 0x49
		and prog:read_u8(INIT_OK_ADDR + 3) == 0x54
		and prog:read_u8(INIT_OK_ADDR + 4) == 0x20
		and prog:read_u8(INIT_OK_ADDR + 5) == 0x4F
		and prog:read_u8(INIT_OK_ADDR + 6) == 0x4B then
			boot_seen = true
			local f = io.open(READY_FILE, "w")
			if f then f:write("READY\n") f:close() end
		end
	end
end)
