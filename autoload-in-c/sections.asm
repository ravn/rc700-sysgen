; sections.asm — Section layout (linker scaffolding).
;
; All code and data are in C files.  This file declares section
; origins and subsection ordering for the z88dk linker.
;
;   BOOT             0x0000  begin() + build timestamp (boot_entry.c)
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
