#!/bin/zsh
# bench_memcpy_c.sh — Benchmark the inline C memcpy_fast vs LDIR
set -e

LLVM_Z80="$(cd ../../llvm-z80 && pwd)"
TICKS="$(cd ../../z88dk/src/ticks && pwd)/z88dk-ticks"
DOCKER=(docker run --rm -m 8g -v "${LLVM_Z80}:/src" -v "$(pwd):/bench" -w /bench ubuntu:24.04)

CLANG=/src/build/bin/clang
LD=/src/build/bin/ld.lld
OBJCOPY=/src/build/bin/llvm-objcopy
NM=/src/build/bin/llvm-nm

cat > bench_memcpy_c.c <<'CEOF'
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
CEOF

echo "=== Building ==="
"${DOCKER[@]}" $CLANG --target=z80 -Os -nostdlib -ffunction-sections \
    -c bench_memcpy_c.c -o bench_memcpy_c.o
"${DOCKER[@]}" $LD -T bench_memcpy.ld bench_memcpy_c.o -o bench_memcpy_c.elf
"${DOCKER[@]}" $OBJCOPY -O binary bench_memcpy_c.elf bench_memcpy_c.bin

get_addr() {
    "${DOCKER[@]}" $NM bench_memcpy_c.elf | awk "/ $1\$/{print \$1}"
}

START=$(get_addr __start)
if [ -z "$START" ]; then START=$(get_addr _start); fi

measure() {
    $TICKS -mz80 -l 0x100 -pc "0x$START" -end "0x$1" bench_memcpy_c.bin 2>&1 | tail -1
}

echo "=== Measuring ==="
T1_PRE=$(get_addr t1_ldir_pre);  T1_DONE=$(get_addr t1_ldir_done)
T2_PRE=$(get_addr t2_fast_pre);  T2_DONE=$(get_addr t2_fast_done)
T3_PRE=$(get_addr t3_ldir_pre);  T3_DONE=$(get_addr t3_ldir_done)
T4_PRE=$(get_addr t4_fast_pre);  T4_DONE=$(get_addr t4_fast_done)
T5_PRE=$(get_addr t5_ldir_pre);  T5_DONE=$(get_addr t5_ldir_done)
T6_PRE=$(get_addr t6_fast_pre);  T6_DONE=$(get_addr t6_fast_done)
T7_PRE=$(get_addr t7_ldir_pre);  T7_DONE=$(get_addr t7_ldir_done)
T8_PRE=$(get_addr t8_fast_pre);  T8_DONE=$(get_addr t8_fast_done)

TS_T1_PRE=$(measure $T1_PRE);  TS_T1_DONE=$(measure $T1_DONE)
TS_T2_PRE=$(measure $T2_PRE);  TS_T2_DONE=$(measure $T2_DONE)
TS_T3_PRE=$(measure $T3_PRE);  TS_T3_DONE=$(measure $T3_DONE)
TS_T4_PRE=$(measure $T4_PRE);  TS_T4_DONE=$(measure $T4_DONE)
TS_T5_PRE=$(measure $T5_PRE);  TS_T5_DONE=$(measure $T5_DONE)
TS_T6_PRE=$(measure $T6_PRE);  TS_T6_DONE=$(measure $T6_DONE)
TS_T7_PRE=$(measure $T7_PRE);  TS_T7_DONE=$(measure $T7_DONE)
TS_T8_PRE=$(measure $T8_PRE);  TS_T8_DONE=$(measure $T8_DONE)

echo ""
echo "=== Results: inline C memcpy_fast vs LDIR ==="
echo ""
printf "%-35s %8s %8s  %s\n" "Test" "LDIR" "Fast" "Speedup"
printf "%-35s %8s %8s  %s\n" "----" "----" "----" "-------"

show() {
    local label=$1 t_ldir=$2 t_fast=$3
    if [ "$t_ldir" -gt 0 ]; then
        local pct=$(( (t_ldir - t_fast) * 100 / t_ldir ))
        printf "%-35s %8d %8d  %d%%\n" "$label" "$t_ldir" "$t_fast" "$pct"
    fi
}

D1_L=$(( TS_T1_DONE - TS_T1_PRE ));  D1_F=$(( TS_T2_DONE - TS_T2_PRE ))
D2_L=$(( TS_T3_DONE - TS_T3_PRE ));  D2_F=$(( TS_T4_DONE - TS_T4_PRE ))
D3_L=$(( TS_T5_DONE - TS_T5_PRE ));  D3_F=$(( TS_T6_DONE - TS_T6_PRE ))
D4_L=$(( TS_T7_DONE - TS_T7_PRE ));  D4_F=$(( TS_T8_DONE - TS_T8_PRE ))

show "1920B (scroll, rem=0)"    $D1_L $D1_F
show "1000B (rem=8)"            $D2_L $D2_F
show "80B   (one row, rem=0)"   $D3_L $D3_F
show "10B   (all remainder)"    $D4_L $D4_F

echo ""
echo "Asm reference: LDIR 1920B=40345T, Duff 1920B=31950T (20%)"
