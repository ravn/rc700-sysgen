cmake_minimum_required(VERSION 3.20)
project(rcbios-in-c C)

# This CMakeLists.txt exists for CLion indexing and navigation only.
# The actual build uses z88dk/sdcc via the Makefile.
# sdcc keywords are stubbed in hal.h (#ifdef HOST_TEST).

# z88dk headers (stdint.h, etc.) — from parent or standalone open
if(NOT DEFINED Z88DK_INCLUDE)
    set(Z88DK_INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/../z88dk/include)
endif()

add_library(bios_sources OBJECT
    bios.c
    bios.h
    hal.h
    boot_block.c
    boot_confi.c
    boot_entry.c
    bios_hw_init.c
    bios_jump_vector_table.c
    conout_test.c
)

target_include_directories(bios_sources PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${Z88DK_INCLUDE}
)

# Custom targets that invoke the real Makefile
add_custom_target(bios
    COMMAND make bios
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(bios-size
    COMMAND make size
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(mame-mini
    COMMAND make mame-mini
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

add_custom_target(mame-maxi
    COMMAND make mame-maxi
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
