/*
 * test_boot.c — Host unit tests for boot logic and initialization
 *
 * Compile with hal_host.c instead of hal_z80.c:
 *   cc -o test_boot test_boot.c boot.c fdc.c fmt.c init.c isr.c hal_host.c
 */

#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "boot.h"

/* Mock helpers (defined in hal_host.c) */
extern void mock_reset(void);
extern void mock_set_sw1(uint8_t val);
extern int mock_get_log_count(void);

static int tests_run = 0;
static int tests_passed = 0;

#define TEST(name) do { \
    tests_run++; \
    printf("  %-50s", name); \
} while(0)

#define PASS() do { \
    tests_passed++; \
    printf("OK\n"); \
} while(0)

/* Test: clear_screen fills display buffer with spaces */
static void test_clear_screen(void) {
    int i;
    TEST("clear_screen fills with spaces");

    /* Poison buffer */
    memset(dspstr, 0xFF, sizeof(dspstr));

    clear_screen();

    /* Check first 8 rows (8*208=1664 bytes) are spaces */
    for (i = 0; i < 8 * 208; i++) {
        assert(dspstr[i] == ' ');
    }

    PASS();
}

/* Test: display_banner writes " RC700" to display */
static void test_display_banner(void) {
    TEST("display_banner writes RC700 to display");

    memset(dspstr, 0, sizeof(dspstr));
    display_banner();

    assert(dspstr[0] == ' ');
    assert(dspstr[1] == 'R');
    assert(dspstr[2] == 'C');
    assert(dspstr[3] == '7');
    assert(dspstr[4] == '0');
    assert(dspstr[5] == '0');
    assert(scroll_offset == 0);

    PASS();
}

/* Test: errcpy writes diskette error message */
static void test_errcpy(void) {
    TEST("errcpy writes DISKETTE ERROR to display");

    memset(dspstr, 0, sizeof(dspstr));
    errcpy();

    assert(dspstr[0] == '*');
    assert(dspstr[1] == '*');
    assert(dspstr[2] == 'D');

    PASS();
}

/* Test: format table lookup — maxi N=0 side 0 */
static void test_fmtlkp_maxi_n0_s0(void) {
    boot_state_t st;
    TEST("fmtlkp maxi N=0 side0: EOT=26, GAP3=7");

    memset(&st, 0, sizeof(st));
    st.diskbits = 0x00;         /* maxi, side 0 */
    st.reclen = 0;              /* N=0 */
    fmtlkp(&st);

    assert(st.cureot == 0x1A);  /* 26 */
    assert(st.gap3 == 0x07);
    assert(st.epts == 0x4C);    /* 76 */
    assert(st.dtl == 0x80);

    PASS();
}

/* Test: format table lookup — mini N=2 side 1 */
static void test_fmtlkp_mini_n2_s1(void) {
    boot_state_t st;
    TEST("fmtlkp mini N=2 side1: EOT=9, GAP3=27");

    memset(&st, 0, sizeof(st));
    st.diskbits = 0x81;         /* mini (bit7), side 1 (bit0) */
    st.reclen = 2;              /* N=2 */
    fmtlkp(&st);

    assert(st.cureot == 0x09);
    assert(st.gap3 == 0x1B);    /* 27 */
    assert(st.epts == 0x23);    /* 35 */

    PASS();
}

/* Test: calctb — maxi N=0, EOT=26, REC=1 → 26 * 128 = 3328 */
static void test_calctb_maxi_n0(void) {
    boot_state_t st;
    TEST("calctb maxi N=0: 26 * 128 = 3328");

    memset(&st, 0, sizeof(st));
    st.reclen = 0;
    st.cureot = 0x1A;           /* 26 */
    st.currec = 1;
    st.dsktyp = 0;              /* maxi */
    st.curhed = 0;
    calctb(&st);

    assert(st.secbyt == 128);
    assert(st.trbyt == 3328);

    PASS();
}

/* Test: calctb — maxi N=2, EOT=15, REC=1 → 15 * 512 = 7680 */
static void test_calctb_maxi_n2(void) {
    boot_state_t st;
    TEST("calctb maxi N=2: 15 * 512 = 7680");

    memset(&st, 0, sizeof(st));
    st.reclen = 2;
    st.cureot = 0x0F;           /* 15 */
    st.currec = 1;
    st.dsktyp = 0;
    st.curhed = 0;
    calctb(&st);

    assert(st.secbyt == 512);
    assert(st.trbyt == 7680);

    PASS();
}

/* Test: setfmt extracts density and calls fmtlkp + calctb */
static void test_setfmt(void) {
    boot_state_t st;
    TEST("setfmt extracts N from diskbits, calls fmtlkp+calctb");

    memset(&st, 0, sizeof(st));
    st.diskbits = 0x08;         /* N=2 in bits 4-2 (0000_1000), maxi, side 0 */
    st.currec = 1;
    st.dsktyp = 0;
    st.curhed = 0;
    setfmt(&st);

    assert(st.reclen == 2);
    assert(st.cureot == 0x08);  /* maxi N=2 side0: EOT=8 */
    assert(st.trbyt == 4096);   /* 8 * 512 */

    PASS();
}

/* Test: init_pio generates correct HAL calls */
static void test_init_pio(void) {
    TEST("init_pio generates PIO control writes");

    mock_reset();
    init_pio();

    /* Should have generated at least 6 control writes */
    assert(mock_get_log_count() >= 6);

    PASS();
}

/* Test: init_dma generates correct HAL calls */
static void test_init_dma(void) {
    TEST("init_dma generates DMA setup calls");

    mock_reset();
    init_dma();

    assert(mock_get_log_count() >= 5);

    PASS();
}

/* Test: init_crt generates correct HAL calls */
static void test_init_crt(void) {
    TEST("init_crt generates CRT param and command writes");

    mock_reset();
    init_crt();

    assert(mock_get_log_count() >= 9);

    PASS();
}

int main(void) {
    printf("test_boot: running tests...\n");

    test_clear_screen();
    test_display_banner();
    test_errcpy();
    test_fmtlkp_maxi_n0_s0();
    test_fmtlkp_mini_n2_s1();
    test_calctb_maxi_n0();
    test_calctb_maxi_n2();
    test_setfmt();
    test_init_pio();
    test_init_dma();
    test_init_crt();

    printf("test_boot: %d/%d tests passed\n", tests_passed, tests_run);
    return tests_passed == tests_run ? 0 : 1;
}
