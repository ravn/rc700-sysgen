/* Minimal string.h for freestanding Z80 build.
 * Implementations in runtime.s (sdcccall(1) convention). */
#ifndef _STRING_H
#define _STRING_H

#include <stddef.h>

void *memcpy(void *dest, const void *src, size_t n);
void *memset(void *s, int c, size_t n);
void *memmove(void *dest, const void *src, size_t n);
void *memchr(const void *s, int c, size_t n);
void lddr_copy(void *src_end, void *dst_end, size_t n);

#endif
