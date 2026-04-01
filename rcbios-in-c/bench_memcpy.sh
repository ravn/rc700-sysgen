#!/bin/zsh
# bench_memcpy.sh — Build, verify, and measure LDIR vs Duff's device memcpy
set -e

LLVM_Z80="$(cd ../../llvm-z80 && pwd)"
TICKS="$(cd ../../z88dk/src/ticks && pwd)/z88dk-ticks"
DOCKER=(docker run --rm -m 8g -v "${LLVM_Z80}:/src" -v "$(pwd):/bench" -w /bench ubuntu:24.04)

CLANG=/src/build/bin/clang
LD=/src/build/bin/ld.lld
OBJCOPY=/src/build/bin/llvm-objcopy
NM=/src/build/bin/llvm-nm

echo "=== Building benchmark ==="
"${DOCKER[@]}" $CLANG --target=z80 -c bench_memcpy.s -o bench_memcpy.o
"${DOCKER[@]}" $LD -T bench_memcpy.ld bench_memcpy.o -o bench_memcpy.elf
"${DOCKER[@]}" $OBJCOPY -O binary bench_memcpy.elf bench_memcpy.bin

get_addr() {
    "${DOCKER[@]}" $NM bench_memcpy.elf | awk "/ $1\$/{print \$1}"
}

START=$(get_addr _start)
HALT=$(get_addr _halt)

echo ""
echo "=== Correctness verification ==="
# Run with -trace to get final register values.
# The success path ends with "ld de,$0000" then halt.
# The error path jumps directly to halt with DE=test#.
# Check if "ld de,$0000" was the last instruction before -end.
TRACE=$($TICKS -mz80 -l 0x100 -pc "0x$START" -trace -end "0x$HALT" bench_memcpy.bin 2>&1 | tail -5)

if echo "$TRACE" | grep -q 'ld  *de,\$0000'; then
    echo "  ALL 9 TESTS PASSED"
else
    DE=$(echo "$TRACE" | grep -oE ' de=[0-9a-fA-F]{4}' | tail -1)
    echo "  FAIL: $DE (test number), check trace for details"
    exit 1
fi

# Measure: run to endpoint, return T-states
measure() {
    $TICKS -mz80 -l 0x100 -pc "0x$START" -end "0x$1" bench_memcpy.bin 2>&1 | tail -1
}

echo ""
echo "=== Measuring T-states ==="
T1_PRE=$(get_addr t1_ldir_pre);     T1_DONE=$(get_addr t1_ldir_done)
T2_PRE=$(get_addr t2_duff_pre);     T2_DONE=$(get_addr t2_duff_done)
T3_PRE=$(get_addr t3_ldir_pre);     T3_DONE=$(get_addr t3_ldir_done)
T4_PRE=$(get_addr t4_duff_pre);     T4_DONE=$(get_addr t4_duff_done)
T5_PRE=$(get_addr t5_ldir_pre);     T5_DONE=$(get_addr t5_ldir_done)
T6_PRE=$(get_addr t6_duff_pre);     T6_DONE=$(get_addr t6_duff_done)
T7_PRE=$(get_addr t7_ldir_pre);     T7_DONE=$(get_addr t7_ldir_done)
T8_PRE=$(get_addr t8_duff_pre);     T8_DONE=$(get_addr t8_duff_done)
T9_PRE=$(get_addr t9_duff16_pre);   T9_DONE=$(get_addr t9_duff16_done)

TS_T1_PRE=$(measure $T1_PRE);   TS_T1_DONE=$(measure $T1_DONE)
TS_T2_PRE=$(measure $T2_PRE);   TS_T2_DONE=$(measure $T2_DONE)
TS_T3_PRE=$(measure $T3_PRE);   TS_T3_DONE=$(measure $T3_DONE)
TS_T4_PRE=$(measure $T4_PRE);   TS_T4_DONE=$(measure $T4_DONE)
TS_T5_PRE=$(measure $T5_PRE);   TS_T5_DONE=$(measure $T5_DONE)
TS_T6_PRE=$(measure $T6_PRE);   TS_T6_DONE=$(measure $T6_DONE)
TS_T7_PRE=$(measure $T7_PRE);   TS_T7_DONE=$(measure $T7_DONE)
TS_T8_PRE=$(measure $T8_PRE);   TS_T8_DONE=$(measure $T8_DONE)
TS_T9_PRE=$(measure $T9_PRE);   TS_T9_DONE=$(measure $T9_DONE)

echo ""
echo "=== Results ==="
echo ""
printf "%-40s %8s %8s  %s\n" "Test" "LDIR" "Duff" "Speedup"
printf "%-40s %8s %8s  %s\n" "----" "----" "----" "-------"

show() {
    local label=$1 t_ldir=$2 t_duff=$3
    if [ "$t_ldir" -gt 0 ]; then
        local pct=$(( (t_ldir - t_duff) * 100 / t_ldir ))
        printf "%-40s %8d %8d  %d%%\n" "$label" "$t_ldir" "$t_duff" "$pct"
    fi
}

show2() {
    local label=$1 t_a=$2 t_b=$3
    printf "%-40s %8d %8d  %s\n" "$label" "$t_a" "$t_b" \
        "$([ $t_a -eq $t_b ] && echo 'identical' || echo "delta=$(( t_b - t_a ))")"
}

D1_L=$(( TS_T1_DONE - TS_T1_PRE ));  D1_D=$(( TS_T2_DONE - TS_T2_PRE ))
D2_L=$(( TS_T3_DONE - TS_T3_PRE ));  D2_D=$(( TS_T4_DONE - TS_T4_PRE ))
D3_L=$(( TS_T5_DONE - TS_T5_PRE ));  D3_D=$(( TS_T6_DONE - TS_T6_PRE ))
D4_L=$(( TS_T7_DONE - TS_T7_PRE ));  D4_D=$(( TS_T8_DONE - TS_T8_PRE ))
D9=$(( TS_T9_DONE - TS_T9_PRE ))

show "1920B (scroll, n_mod=0)"   $D1_L $D1_D
show "1000B (n_mod=8)"           $D2_L $D2_D
show "80B   (one row, n_mod=0)"  $D3_L $D3_D
show "10B   (tiny, n_mod=10)"    $D4_L $D4_D
show2 "1920B Duff n_mod=0 vs n_mod=16" $D1_D $D9

echo ""
echo "Theory: LDIR=21T/byte, 16xLDI=16T/byte + 10T/block = 16.625T/byte avg"
