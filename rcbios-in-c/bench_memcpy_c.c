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

static inline void
memcpy_ldir(byte *dest, const byte *src, word n)
{
    __asm volatile("ldir"
        : "+{de}"(dest), "+{hl}"(src), "+{bc}"(n) :: "memory");
}

static byte src_buf[1920];
static byte dst_buf[1920];

#define N16(n) (((n) / 16) * 16)
#define NREM(n) ((n) % 16)

#define MARKER(name) \
    __asm volatile(".globl " #name "\n" #name ":\n\tnop" ::: "memory")

void _start(void) __attribute__((noreturn));
void _start(void)
{
    word i;
    for (i = 0; i < 1920; i++) src_buf[i] = (byte)i;

    /* --- 1920 bytes --- */
    MARKER(t1_ldir_pre);
    memcpy_ldir(dst_buf, src_buf, 1920);
    MARKER(t1_ldir_done);

    MARKER(t2_fast_pre);
    memcpy_fast(dst_buf, src_buf, N16(1920), NREM(1920));
    MARKER(t2_fast_done);

    /* --- 1000 bytes --- */
    MARKER(t3_ldir_pre);
    memcpy_ldir(dst_buf, src_buf, 1000);
    MARKER(t3_ldir_done);

    MARKER(t4_fast_pre);
    memcpy_fast(dst_buf, src_buf, N16(1000), NREM(1000));
    MARKER(t4_fast_done);

    /* --- 80 bytes --- */
    MARKER(t5_ldir_pre);
    memcpy_ldir(dst_buf, src_buf, 80);
    MARKER(t5_ldir_done);

    MARKER(t6_fast_pre);
    memcpy_fast(dst_buf, src_buf, N16(80), NREM(80));
    MARKER(t6_fast_done);

    /* --- 10 bytes --- */
    MARKER(t7_ldir_pre);
    memcpy_ldir(dst_buf, src_buf, 10);
    MARKER(t7_ldir_done);

    MARKER(t8_fast_pre);
    memcpy_fast(dst_buf, src_buf, N16(10), NREM(10));
    MARKER(t8_fast_done);

    __asm volatile(".globl _halt\n_halt:\nhalt");
    __builtin_unreachable();
}
