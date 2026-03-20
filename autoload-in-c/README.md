# autoload in C

The original ROA375 autoload PROM was written in hand-optimized Z80 assembly, but the code was difficult to read and maintain.  This project rewrites the autoload
logic in C using the z88dk toolchain, with a custom `crt0.asm` for the bootstrap code.  The resulting binary is byte-exact with the original assembly version, demonstrating that a C implementation can fit within the 2048-byte ROM size constraint while still being maintainable and testable.

TODO: Memory map here, with links to source files and documentation for each region.

Now finish the conversion completely to C eliminating the cr0.asm.

