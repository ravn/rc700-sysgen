; sections.asm — Section layout (linker scaffolding).
;
; All code and data are in C files.  This file declares section
; origins and subsection ordering for the z88dk linker.
;
;   BOOT             0x0000  begin(), init_fdc, banner_string, NMI (boot_rom.c)
;   CODE             0x7000  Copied to RAM by begin():
;     (IVT data)               16 function pointers (intvec.c)
;     code_compiler            Compiled C code
;     rodata_compiler          Const strings, tables, code_end sentinel
;     bss_compiler             Uninitialized variables (zeroed by copy)

	SECTION	BOOT
	ORG	0x0000

	SECTION	CODE
	ORG	0x7000
	SECTION	code_compiler
	SECTION	rodata_compiler
	SECTION	bss_compiler

	; NOTE: Payload size (_code_end - _intvec + 1) cannot be computed
	; at link time via DEFC — z80asm asserts on cross-subsection symbol
	; arithmetic.  Computed at runtime in begin() instead (+8 bytes).
