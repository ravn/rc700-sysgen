cmake_minimum_required(VERSION 3.20)
project(autoload-in-c C)

# This CMakeLists.txt exists for CLion indexing and navigation only.
# The actual build uses z88dk/sdcc or llvm-z80/clang via the Makefile.
# Configured to show clang code paths (not HOST_TEST, not SDCC).

# z88dk headers (stdint.h, etc.) — from parent or standalone open
if(NOT DEFINED Z88DK_INCLUDE)
    set(Z88DK_INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/../z88dk/include)
endif()

add_library(rom_sources OBJECT
    rom.c
    rom.h
    boot_rom.c
    intvec.c
)

target_include_directories(rom_sources PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/clang_z80
    ${Z88DK_INCLUDE}
)

# Define __z80__ so CLion shows the Z80/Clang code paths.
target_compile_definitions(rom_sources PRIVATE
    __z80__=1
)

# Custom targets that invoke the real Makefile
add_custom_target(rom
    COMMAND make rom
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(prom
    COMMAND make prom
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(mame-autoload
    COMMAND make mame
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
