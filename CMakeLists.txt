cmake_minimum_required(VERSION 3.20)
project(rc700-gensmedet C)

# This CMakeLists.txt exists for CLion indexing and navigation only.
# The actual builds use z88dk/sdcc via Makefiles in each subdirectory.

# z88dk headers for navigation (stdint.h, etc.)
set(Z88DK_INCLUDE ${CMAKE_SOURCE_DIR}/z88dk/include)

# Stub sdcc keywords so CLion's clang parser doesn't choke.
# Individual headers already guard these with #ifndef __SDCC.
add_compile_definitions(HOST_TEST)

add_subdirectory(autoload-in-c)
add_subdirectory(rcbios-in-c)
