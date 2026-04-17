# SIO-B console: DIP switch selection (replace ENQ probe)

## Current behavior

On cold boot, `bios_hw_init()` sends ENQ (0x05) on SIO-B TX and polls for
~300 ms. If a reply byte arrives, IOBYTE is set to `0x96` (CON:=BAT →
keyboard + SIO-B + CRT echo). Otherwise falls back to `0x97` (CON:=UC1 →
keyboard + SIO-A). See `session17-siob-console.md` for full details.

## User request

Replace the ENQ probe with a DIP switch read, similar to how SW1 #7
selects mini/maxi floppy density. The switch would directly select SIO-B
vs SIO-A as console, avoiding:

- The 300 ms probe delay on every cold boot
- The dependency on a host being present with a listener running
- The need to restart the daemon before every RC700 reset

## Implementation sketch

- Find which DIP switch bit is free (read `~/git/.../docs` or existing
  `bios_hw_init.c`). SW1 appears to be read from PIO Ch.B input during
  init — check which bits are already assigned.
- Replace `siob_console_probe()` call in `bios_hw_init()` end with a DIP
  switch read:
  ```c
  iobyte = (dip_switches & SW_SIOB_CONSOLE)
           ? IOBYTE_DEFAULT_SIOB : IOBYTE_DEFAULT;
  ```
- The probe function and ENQ-reply protocol can then be deleted, saving
  ~40 bytes of BOOT_CODE (which is overwritten anyway, so no resident
  BIOS savings).

## Open questions

- [ ] Which DIP switch position should be used?
- [ ] Should the probe be kept as a fallback when the DIP is off, for
      backward compatibility with existing scripts?
- [ ] Does the SIO-B console mode need a runtime toggle (e.g., via STAT
      CON:=…) independent of the boot-time DIP reading?
