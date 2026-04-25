-- license: BSD-3-Clause
--
-- MAME autoboot script — CP/NET fast-link bring-up test tap.
--
-- Watches the cpnos-rom BSS counter that isr_pio_par increments on
-- each PIO-B byte received.  Emits one line per change to stdout
-- so the host-side Python harness can observe end-to-end progress.
--
-- Addresses are pinned by the current cpnos-rom layout (see
-- clang/cpnos.lis after `make cpnos`):
--
--     0xEA39  _pio_par_byte    (last byte received)
--     0xEA3A  _pio_par_count   (count of bytes received, wraps at 0xFF)
--
-- If the cpnos-rom BSS layout shifts these addresses, this tap will
-- need updating.  Re-derive from `grep _pio_par cpnos-rom/clang/cpnos.lis`.

local PIO_PAR_BYTE_ADDR  = 0xEA39
local PIO_PAR_COUNT_ADDR = 0xEA3A

print(string.format("[tap] watching pio_par_byte=0x%04X count=0x%04X",
		PIO_PAR_BYTE_ADDR, PIO_PAR_COUNT_ADDR))

emu.register_start(function ()
	local cpu  = manager.machine.devices[":maincpu"]
	local prog = cpu.spaces["program"]

	prog:install_write_tap(PIO_PAR_COUNT_ADDR, PIO_PAR_COUNT_ADDR, "pio_par_count_tap",
		function (offset, data, mask)
			local byte = prog:read_u8(PIO_PAR_BYTE_ADDR)
			print(string.format("[tap] count=%d byte=0x%02X", data, byte))
			io.flush()
		end)

	print("[tap] write-tap installed on pio_par_count")
	io.flush()
end)
