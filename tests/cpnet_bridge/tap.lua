-- license: BSD-3-Clause
--
-- MAME autoboot script — CP/NET fast-link bring-up test tap.
--
-- Watches display memory for the "RC702 CP/NOS v1.2" signon (proof
-- that cpnos-rom finished init_hardware AND netboot AND nos_handoff)
-- and the BSS counter that isr_pio_par increments (proof that bytes
-- sent over the PIO-B bridge actually reach the Z80 ISR).
--
-- BSS addresses come from /tmp/cpnos_bridge_addrs.lua (written by the
-- harness from `llvm-nm cpnos-rom/clang/payload.elf`).

local addrs = dofile("/tmp/cpnos_bridge_addrs.lua")
local PIO_PAR_BYTE_ADDR  = addrs.pio_par_byte
local PIO_PAR_COUNT_ADDR = addrs.pio_par_count
local DSPSTR             = 0xF800
local SIGNON_ROW1        = 0xF850

local READY_FILE = "/tmp/cpnos_bridge_ready.txt"
local TAP_LOG    = "/tmp/cpnos_bridge_tap.log"

do
	local f = io.open(READY_FILE, "w") if f then f:close() end
	local f2 = io.open(TAP_LOG, "w")  if f2 then f2:close() end
end

local tap_installed = false
local boot_seen     = false
local prog          = nil
local last_count    = 0
local isr_hits      = 0

emu.register_periodic(function ()
	if prog == nil then
		local cpu = manager.machine.devices[":maincpu"]
		if cpu == nil then return end
		prog = cpu.spaces["program"]
		if prog == nil then return end
	end

	-- Banner watch — write READY once cpnos-rom prints
	-- "RC702 CP/NOS v1.2" (cpnos_main.c::nos_handoff signon, runs
	-- after netboot completes and just before EI/JP NDOS COLDST).
	if not boot_seen then
		if  prog:read_u8(DSPSTR + 0) == 0x52  -- 'R'
		and prog:read_u8(DSPSTR + 1) == 0x43  -- 'C'
		and prog:read_u8(DSPSTR + 2) == 0x37  -- '7'
		and prog:read_u8(DSPSTR + 3) == 0x30  -- '0'
		and prog:read_u8(DSPSTR + 4) == 0x32  -- '2'
		then
			boot_seen = true
			local f = io.open(READY_FILE, "w")
			if f then f:write("READY\n") f:close() end
		end
	end

	-- Polled count + cross-check.  No memory taps installed:
	-- earlier experiments showed install_read_tap and
	-- install_write_tap on 0xEA38-area / 0xEF8E broke the IM2 IRQ
	-- chain in MAME's emulation (symptom: crt_ticks counter at
	-- 0xEC30 stayed at uninitialized BSS, never incrementing) so
	-- both CRT VRTC and PIO-B IRQs stopped firing.  Pure polling
	-- has no such side effect.
	local cur = prog:read_u8(PIO_PAR_COUNT_ADDR)
	if cur ~= last_count then
		local byte = prog:read_u8(PIO_PAR_BYTE_ADDR)
		local crt_ticks = prog:read_u8(0xEC30)
		local f = io.open(TAP_LOG, "a")
		if f then
			f:write(string.format("count=%d byte=0x%02X crt_ticks=%d\n",
				cur, byte, crt_ticks))
			f:close()
		end
		last_count = cur
	end
end)
