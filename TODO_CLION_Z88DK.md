# TODO: CLion support for z88dk

Investigate configuring CLion to use z88dk/sdcc as a custom compiler
so it can build, navigate, and error-check Z80 code natively instead
of relying on `#ifndef __SDCC` stubs for clang.

## Inspiration

JetBrains custom compiler support:
https://blog.jetbrains.com/clion/2022/09/custom-compilers/

## Current workaround

`CMakeLists.txt` registers sources for indexing only.  `rom.h` has
`#ifndef __SDCC` guards that stub `__sfr`, `__at`, `__interrupt`,
`__critical`, `__naked`, `__asm__` and provide `extern volatile
unsigned char` port declarations.  Build uses `make` via custom
CMake targets.
