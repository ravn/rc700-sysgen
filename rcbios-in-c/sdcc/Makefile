# sdcc/Makefile — Clean target for SDCC BIOS build artifacts
# Build is handled by parent Makefile (z88dk Docker needs parent as workdir).

.PHONY: clean

clean:
	rm -f *.o bios bios.cim bios.map bios.lis bios_BOOT.bin bios_BIOS.bin
	rm -f *.sym bios.def zcc_opt.def *.c.lis *.c.asm
