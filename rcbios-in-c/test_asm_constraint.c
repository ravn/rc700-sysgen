/* memcpy_fast(dest, src, blocks16, remainder)
 * blocks16 = (n / 16) * 16  — byte count for 16xLDI loop, used as BC directly
 * remainder = n % 16         — byte count for initial LDIR (0 = skip)
 * Always inlined; all args are compile-time constants at call sites. */
// ReSharper disable CppJoinDeclarationAndAssignment
typedef unsigned short word;
typedef unsigned char byte;

static inline void
memcpy_fast(byte *dest, const byte *src, word blocks16, byte remainder)
{
    if (remainder) {
        word rem = remainder;
        __asm volatile("ldir"
            : "+{de}"(dest), "+{hl}"(src), "+{bc}"(rem) :: "memory");
    }
    if (blocks16) {
        word bc = blocks16;
        __asm volatile(
            "1: ldi\n ldi\n ldi\n ldi\n ldi\n ldi\n ldi\n ldi\n"
            "   ldi\n ldi\n ldi\n ldi\n ldi\n ldi\n ldi\n ldi\n"
            "   jp pe, 1b"
            : "+{de}"(dest), "+{hl}"(src), "+{bc}"(bc) :: "memory");
    }
}

static byte src_buf[1920];
static byte dst_buf[1920];

static word verify(word n)
{
    word i;
    for (i = 0; i < n; i++) {
        if (dst_buf[i] != src_buf[i]) return i;
    }
    if (n < 1920 && dst_buf[n] != 0xFF) return n;
    return 0xFFFF;
}

static void clear_dst(void)
{
    word i;
    for (i = 0; i < 1920; i++) dst_buf[i] = 0xFF;
}

#define N16(n) (((n) / 16) * 16)
#define NREM(n) ((n) % 16)

#define TEST(num, n) do { \
    clear_dst(); \
    memcpy_fast(dst_buf, src_buf, N16(n), NREM(n)); \
    result = verify(n); \
    if (result != 0xFFFF) { fail = (num); goto done; } \
} while(0)

void _start(void) __attribute__((noreturn));
void _start(void)
{
    word i, result;
    word fail = 0;

    for (i = 0; i < 1920; i++) src_buf[i] = (byte)i;

    TEST(1, 1920);   /* 1920 + 0 remainder */
    TEST(2, 1000);   /* 992 + 8 remainder */
    TEST(3, 80);     /* 80 + 0 remainder */
    TEST(4, 10);     /* 0 + 10 remainder */
    TEST(5, 1);      /* 0 + 1 remainder */
    TEST(6, 16);     /* 16 + 0 remainder */
    TEST(7, 17);     /* 16 + 1 remainder */
    TEST(8, 15);     /* 0 + 15 remainder */

done:
    __asm volatile(
        ".globl _halt\n_halt:\nhalt"
        :: "{de}"(fail), "{hl}"(result));
    __builtin_unreachable();
}
