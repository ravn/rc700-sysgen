cmake_minimum_required(VERSION 3.20)
project(autoload-in-c C)

# This CMakeLists.txt exists for CLion indexing and navigation only.
# The actual build uses z88dk/sdcc via the Makefile.
# sdcc keywords are stubbed in rom.h (#ifndef __SDCC).

add_library(rom_sources OBJECT
    rom.c
    rom.h
    boot_rom.c
    intvec.c
)

# Custom targets that invoke the real Makefile
add_custom_target(rom
    COMMAND make rom
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

add_custom_target(prom
    COMMAND make prom
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)

add_custom_target(mame
    COMMAND make mame
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
)
