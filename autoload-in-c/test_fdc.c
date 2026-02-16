/*
 * test_fdc.c — Host unit tests for FDC state machine
 *
 * Compile with hal_host.c instead of hal_z80.c:
 *   cc -o test_fdc test_fdc.c fdc.c fmt.c boot.c init.c isr.c hal_host.c
 */

#include <stdio.h>
#include <assert.h>
#include <string.h>
#include "boot.h"

/* Mock helpers */
extern void mock_reset(void);
extern void mock_set_fdc_status(uint8_t val);
extern void mock_fdc_push_read(uint8_t val);
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

/* Test: mkdhb combines head and drive */
static void test_mkdhb(void) {
    boot_state_t st;
    TEST("mkdhb: head=1 drive=0 -> 0x04");

    memset(&st, 0, sizeof(st));
    st.curhed = 1;
    st.drvsel = 0;
    assert(mkdhb(&st) == 0x04);

    PASS();
}

static void test_mkdhb_drive1(void) {
    boot_state_t st;
    TEST("mkdhb: head=0 drive=1 -> 0x01");

    memset(&st, 0, sizeof(st));
    st.curhed = 0;
    st.drvsel = 1;
    assert(mkdhb(&st) == 0x01);

    PASS();
}

/* Test: snsdrv sends correct FDC commands */
static void test_snsdrv(void) {
    boot_state_t st;
    TEST("snsdrv sends 0x04 + drive, reads ST3");

    memset(&st, 0, sizeof(st));
    mock_reset();
    mock_fdc_push_read(0x28);   /* ST3 = track 0 + ready */

    snsdrv(&st);

    assert(st.fdcres[0] == 0x28);

    PASS();
}

/* Test: chkres success path */
static void test_chkres_ok(void) {
    boot_state_t st;
    TEST("chkres: ST0=0x00, ST1=0, ST2=0 -> success");

    memset(&st, 0, sizeof(st));
    st.drvsel = 0;
    st.reptim = 3;
    st.fdcres[0] = 0x00;       /* ST0: normal, drive 0 */
    st.fdcres[1] = 0x00;       /* ST1: no errors */
    st.fdcres[2] = 0x00;       /* ST2: no errors */

    assert(chkres(&st) == 0);

    PASS();
}

/* Test: chkres error path with retries */
static void test_chkres_error(void) {
    boot_state_t st;
    TEST("chkres: ST0 mismatch -> error, retries decremented");

    memset(&st, 0, sizeof(st));
    st.drvsel = 0;
    st.reptim = 3;
    st.fdcres[0] = 0x40;       /* ST0: abnormal termination */
    st.fdcres[1] = 0x00;
    st.fdcres[2] = 0x00;

    assert(chkres(&st) == 1);  /* Error, retries remaining */
    assert(st.reptim == 2);

    PASS();
}

/* Test: chkres retries exhausted */
static void test_chkres_exhausted(void) {
    boot_state_t st;
    TEST("chkres: retries=1, error -> exhausted (2)");

    memset(&st, 0, sizeof(st));
    st.drvsel = 0;
    st.reptim = 1;
    st.fdcres[0] = 0x40;
    st.fdcres[1] = 0x00;
    st.fdcres[2] = 0x00;

    assert(chkres(&st) == 2);
    assert(st.reptim == 0);

    PASS();
}

/* Test: clrflf clears floppy flag */
static void test_clrflf(void) {
    boot_state_t st;
    TEST("clrflf clears flpflg to 0");

    memset(&st, 0, sizeof(st));
    mock_reset();
    st.flpflg = 2;
    clrflf(&st);
    assert(st.flpflg == 0);

    PASS();
}

/* Test: flo6 reads sense interrupt status */
static void test_flo6(void) {
    boot_state_t st;
    TEST("flo6: reads ST0 and PCN");

    memset(&st, 0, sizeof(st));
    mock_reset();
    mock_fdc_push_read(0x20);   /* ST0: seek end */
    mock_fdc_push_read(0x05);   /* PCN: cylinder 5 */

    flo6(&st);

    assert(st.fdcres[0] == 0x20);
    assert(st.fdcres[1] == 0x05);

    PASS();
}

/* Test: flo6 with invalid command status (no PCN read) */
static void test_flo6_invalid(void) {
    boot_state_t st;
    TEST("flo6: ST0=0x80 (invalid) -> no PCN read");

    memset(&st, 0, sizeof(st));
    mock_reset();
    mock_fdc_push_read(0x80);   /* ST0: invalid command */

    flo6(&st);

    assert(st.fdcres[0] == 0x80);
    /* fdcres[1] should remain 0 (not read) */
    assert(st.fdcres[1] == 0x00);

    PASS();
}

int main(void) {
    printf("test_fdc: running tests...\n");

    test_mkdhb();
    test_mkdhb_drive1();
    test_snsdrv();
    test_chkres_ok();
    test_chkres_error();
    test_chkres_exhausted();
    test_clrflf();
    test_flo6();
    test_flo6_invalid();

    printf("test_fdc: %d/%d tests passed\n", tests_passed, tests_run);
    return tests_passed == tests_run ? 0 : 1;
}
