/*
 * rom.c — RC702 autoload PROM: all CODE-section C source
 *
 * Single translation unit for the Z80 ROM build, enabling cross-function
 * inlining, dead code elimination, and better register allocation.
 *
 * Section order:
 *   1. HAL functions (FDC wait loops, delay)
 *   2. Initialization (post-relocation entry, peripherals, FDC, CRT)
 *   3. Format tables and geometry
 *   4. FDC driver (commands, result handling, read/seek)
 *   5. Boot logic (signature check, disk read, main)
 *   6. Interrupt service routines
 *   7. Sentinel (code_end marker)
 *
 * Separately compiled units (different link order or codeseg):
 *   - intvec.c    — IVT at 0x7000, linked first
 *   - boot_rom.c  — BOOT section at 0x0000
 *   - sections.asm — linker section layout
 */

#include <string.h>
#ifdef __SDCC
#include <intrinsic.h>
#endif
#include "rom.h"

/* ================================================================
 * 1. HAL functions
 *
 * Originally hand-written assembly; sdcc generates nearly identical
 * code from C.
 *
 * delay() timing note:
 *   Assembly used dec a / jr nz (16 T-states/iter).  sdcc generates
 *   djnz (13 T-states), making delay ~19% shorter for same params.
 *   See init_fdc() for compensated call (2, 157) matching the
 *   original (1, 0xFF) within 0.3%.
 * ================================================================ */

/* Wait for FDC ready-to-write, then write val to data register.
 * Polls MSR until RQM=1 and DIO=0 (CPU->FDC direction). */
void fdc_wait_write(byte val) {
    word t = 0;
    do {
        if ((_port_fdc_status & 0xC0) == 0x80) {
            _port_fdc_data = val;
            return;
        }
    } while (++t);
}

/* Wait for FDC ready-to-read, then read from data register.
 * Polls MSR until RQM=1 and DIO=1 (FDC->CPU direction). */
byte fdc_wait_read(void) {
    word t = 0;
    do {
        if ((_port_fdc_status & 0xC0) == 0xC0) {
            return _port_fdc_data;
        }
    } while (++t);
    return 0xFF;
}

/* Software delay loop: outer x inner x 256 iterations of DJNZ. */
void delay(byte outer, byte inner) {
    if (!outer) { return; }
    do {
        byte mid = inner;
        do {
            byte k = 0;
            do { } while (--k);
        } while (--mid);
    } while (--outer);
}

/* ================================================================
 * 2. Initialization
 * ================================================================ */

/* Set Z80 I register.  sdcccall(1) passes byte in A; ld i,a uses it.
 * Must NOT be inline — see rcbios-in-c documentation. */
static void set_i_reg(byte page)
{
    (void)page;
    __asm__("ld i, a\n");
}

/* Post-relocation entry point.  Called from begin() after LDIR copy.
 * Sets SP, I register, IM2, then calls init_peripherals() + main().
 * __naked because we set SP mid-function. */
void init_relocated(void) __naked
{
    __asm__("ld sp, #" STR(ROM_STACK) "\n");
    set_i_reg(INTVEC_PAGE);
    intrinsic_im_2();
    init_peripherals();
    main();
    for (;;)
        ;
}

/* Combined PIO/CTC/DMA/CRT initialization.
 * Macros expand to direct __sfr port writes on Z80. */
void init_peripherals(void) {
    /* PIO — Z80 PIO, Port A = keyboard input, Port B = parallel output */
    pio_write_a_ctrl(0x02);          /* Port A: interrupt vector = 0x02 */
    pio_write_b_ctrl(0x04);          /* Port B: interrupt vector = 0x04 */
    pio_write_a_ctrl(0x4F);          /* Port A: mode 1 (input) */
    pio_write_b_ctrl(0x0F);          /* Port B: mode 0 (output) */
    pio_write_a_ctrl(0x83);          /* Port A: interrupt — enable, AND, active high */
    pio_write_b_ctrl(0x83);          /* Port B: interrupt — enable, AND, active high */

    /* CTC — Z80 CTC, 4 channels */
    ctc0_write(0x08);                /* Ch0: interrupt vector base = 0x08 */
    ctc0_write(0x47);                /* Ch0: counter, falling edge, TC follows, reset */
    ctc0_write(0x20);                /* Ch0: time constant = 32 */
    ctc1_write(0x47);                /* Ch1: counter, falling edge, TC follows, reset */
    ctc1_write(0x20);                /* Ch1: time constant = 32 */
    ctc2_write(0xD7);                /* Ch2 (display): counter, interrupt, TC follows */
    ctc2_write(0x01);                /* Ch2: time constant = 1 (every retrace) */
    ctc3_write(0xD7);                /* Ch3 (floppy): counter, interrupt, TC follows */
    ctc3_write(0x01);                /* Ch3: time constant = 1 (every interrupt) */

    /* DMA — AMD Am9517A / Intel 8237 */
    dma_command(0x20);               /* master clear + standard configuration */
    dma_mode(0xC0);                  /* Ch0: cascade mode (WD1000 hard disk) */
    dma_unmask(0);                   /* Ch0: enable */
    dma_mode(0x4A);                  /* Ch2: single xfer, write mem->I/O (display) */
    dma_mode(0x4B);                  /* Ch3: single xfer, write mem->I/O (scroll) */

    /* CRT — Intel 8275 (bits 7-5 = command code) */
    crt_command(0x00);               /* reset (expect 4 param bytes) */
    crt_param(0x4F);                 /*   S=0, H=79: 80 chars/row */
    crt_param(0x98);                 /*   V=2 vretrace, R=24: 25 rows */
    crt_param(0x9A);                 /*   L=9 underline, U=10 lines/char */
    crt_param(0x5D);                 /*   F=0, M=1 transparent, C=01 blink, Z=28 */
    crt_command(0x80);               /* load cursor (expect 2 param bytes) */
    crt_param(0x00);                 /*   column = 0 */
    crt_param(0x00);                 /*   row = 0 */
    crt_command(0xE0);               /* preset counters */
}

/* Fill display memory with spaces. */
void clear_screen(void) {
    memset(dspstr, ' ', 80 * 25);
}

/* Initialize FDC with Specify command. */
void init_fdc(void) {
    delay(2, 157);                   /* wait for FDC to become ready */
    while (fdc_status() & 0x1F) {
        ;
    };  /* wait until no drives are busy */
    fdc_wait_write(0x03);            /* Specify command */
    fdc_wait_write(0x4F);            /*   SRT=4 (8ms step), HUT=F (240ms unload) */
    fdc_wait_write(0x20);            /*   HLT=10 (32ms load), ND=0 (DMA mode) */
}

/* Copy " RC700" to display and start CRT controller. */
void display_banner_and_start_crt(void) {
    memcpy(dspstr, " RC700 gensmedet", 16);
    scroll_offset = 0;
    crt_command(0x23);               /* start display: burst=0, 8 DMA cycles */
}

/* ================================================================
 * 3. Format tables and geometry
 * ================================================================ */

/* Format parameters indexed by sector size code N (0-3).
 * Each row: { side0_eot, side0_gap3, side1_eot, side1_gap3 } */
static const byte maxifmt[4][4] = {
    { 0x1A, 0x07, 0x34, 0x07 },
    { 0x0F, 0x0E, 0x1A, 0x0E },
    { 0x08, 0x1B, 0x0F, 0x1B },
    { 0x00, 0x00, 0x08, 0x35 },
};

static const byte minifmt[4][4] = {
    { 0x10, 0x07, 0x20, 0x07 },
    { 0x09, 0x0E, 0x10, 0x0E },
    { 0x05, 0x1B, 0x09, 0x1B },
    { 0x00, 0x00, 0x05, 0x35 },
};

/* Look up format parameters from disk type and sector size code. */
void format_lookup(void) {
    const byte *tbl;
    byte side_offset;
    byte n = sector_size_code & 0x03;

    if (disk_bits & 0x80) {
        tbl = minifmt[n];
    } else {
        tbl = maxifmt[n];
    }

    side_offset = (disk_bits & 0x01) ? 2 : 0;
    end_of_track = tbl[side_offset];
    gap3 = tbl[side_offset + 1];
    data_length = 0x80;
}

/* Calculate transfer byte count for current track geometry. */
void calc_track_bytes(void) {
    byte sectors;
    byte i;

    sectors = end_of_track - current_sector + 1;

    if ((disk_type & 0x80) && current_head == 1) {
        sectors = 0x0A;
    }

    /* transfer_bytes = sectors * (128 << N) = sectors << (7 + N) */
    {
        word tb = (word)sectors;
        for (i = 7 + sector_size_code; i != 0; i--) tb <<= 1;
        transfer_bytes = tb;
    }
}

/* ================================================================
 * 4. FDC driver — NEC uPD765 (Intel 8272)
 *
 * Main Status Register (fdc_status(), port 0x04):
 *   bit 7:   RQM  — ready for CPU data transfer
 *   bit 6:   DIO  — direction (0=CPU->FDC, 1=FDC->CPU)
 *   bit 5:   EXM  — in execution phase
 *   bit 4:   CB   — command busy
 *   bits 3-0:       drive busy flags
 *
 * Result registers (fdc_result[], via fdc_wait_read()):
 *   ST0 [0]: IC (7-6), SE (5), HD (2), US (1-0)
 *   ST1 [1]: error flags (EN, DE, OR, ND, NW, MA)
 *   ST2 [2]: error flags; bit 6 = CM (benign)
 *   ST3 [0]: from Sense Drive — RDY (5), HD+US (2-0)
 *   [3]-[6]: C, H, R, N
 * ================================================================ */

/*
 * wait_floppy_interrupt() timing model.
 *
 * Must cover worst-case FM track read: 8" at 360 RPM = 166ms/rev.
 * Wait for sector 1 (~1 rev) + read 26 sectors (~1 rev) = 332ms.
 * Require >= 400ms.
 *
 * delay(1,4) = 4 x 256 x 13T = 13,312T per iteration.
 * 255 iterations = 851,200T = 213ms at 4MHz.
 * Matches original assembly (511 x 24T = 12,264T) within 8%.
 */
#define WAITFL_DELAY_OUTER  1
#define WAITFL_DELAY_INNER  4

/* Compile-time check: timeout >= 400ms */
#define Z80_MHZ           4
#define WAITFL_PER_ITER  ((long)(WAITFL_DELAY_OUTER) * (WAITFL_DELAY_INNER) * 256 * 13)
#define WAITFL_MS        (255L * WAITFL_PER_ITER / (Z80_MHZ * 1000))
typedef char _wait_floppy_interrupt_timeout_check[(WAITFL_MS >= 400) ? 1 : -1];

/* Send Sense Interrupt Status; ST0 in [0], PCN in [1]. */
void fdc_sense_interrupt(void) {
    fdc_wait_write(FDC_SENSE_INT);
    fdc_result[0] = fdc_wait_read();         /* ST0 */
    if ((fdc_result[0] & 0xC0) != 0x80) {    /* IC != 10 (not invalid cmd) */
        fdc_result[1] = fdc_wait_read();     /* PCN (present cylinder) */
    }
}

/* Send Seek command to head/drive dh, cylinder cyl. */
void fdc_seek(byte dh, byte cyl) {
    fdc_wait_write(FDC_SEEK);
    fdc_wait_write(dh & 0x07);               /* HD + US (head + drive) */
    fdc_wait_write(cyl);                     /* NCN (new cylinder number) */
}

/* Read FDC result phase (up to 7 bytes into fdc_result[]). */
void fdc_read_result(void) {
    byte i;

    fdc_flag = 7;
    for (i = 0; i < 7; i++) {
        fdc_result[i] = fdc_wait_read();
        delay(0, fdc_wait);
        if (!(fdc_status() & 0x10)) {        /* CB=0: no more result bytes */
            fdc_result[i + 1] = dma_status();
            return;
        }
    }
    error_saved = 0xFE;
    error_display_halt(0xFE);
}

/* Wait for floppy interrupt (floppy_flag set by ISR).
 * Returns 0=ok, 1=timeout. */
byte wait_floppy_interrupt(byte timeout) {
    while (--timeout) {
        delay(WAITFL_DELAY_OUTER, WAITFL_DELAY_INNER);
        if (floppy_flag & 0x02) {
            di();
            floppy_flag = 0;
            ei();
            return 0;
        }
    }
    return 1;
}

/* Forward declarations for tail-call fall-through reordering */
static byte chk_seekres(byte expected_pcn);
static void fldsk1(void);

/* Seek to current_cylinder and verify.
 * Placed before chk_seekres for tail-call fall-through (saves 3 bytes). */
byte floppy_seek(void) {
    fdc_seek((current_head << 2) | drive_select, current_cylinder);
    return chk_seekres(current_cylinder);
}

/* Wait for seek/recalibrate interrupt, verify ST0 and PCN. */
static byte chk_seekres(byte expected_pcn) {
    if (wait_floppy_interrupt(0xFF)) { return 1; }
    if ((drive_select + 0x20) != fdc_result[0]) { return 2; }  /* SE+drive */
    if (expected_pcn != fdc_result[1]) { return 2; }           /* verify PCN */
    return 0;
}

/* Issue FDC read command with parameter block.
 * For Read Data, sends 7-byte block: C, H, R, N, EOT, GPL, DTL. */
void floppy_read_track(byte cmd) {
    byte mfm_flag = (disk_bits & 0x01) ? FDC_MFM : 0;
    byte dh = (current_head << 2) | drive_select;

    di();
    fdc_flag = 0xFF;
    fdc_wait_write(cmd + mfm_flag);          /* command (+MFM if double density) */
    fdc_wait_write(dh);                      /* head/drive select */

    if ((cmd & 0x0F) == FDC_READ_DATA) {
        /* 7-byte parameter block: C, H, R, N, EOT, GPL, DTL */
        byte *p = &current_cylinder;
        byte i;
        for (i = 0; i < 7; i++) {
            fdc_wait_write(p[i]);
        }
    }
    ei();
}

/* Check FDC result status.  Returns 0=ok, 1=retry, 2=give up. */
byte check_fdc_result(void) {
    if ((fdc_result[0] & 0xC3) == drive_select &&  /* ST0: IC=00 + drive */
        fdc_result[1] == 0 &&                       /* ST1: no errors */
        (fdc_result[2] & 0xBF) == 0) {              /* ST2: ignore CM */
        return 0;
    } else {
        retry_count--;
        return (retry_count == 0) ? 2 : 1;
    }
}

/* File-scope global to avoid IX frame pointer in retry loop. */
static byte read_track_cmd;

/* Read track with retries.  Returns 0=ok, 1=error. */
byte read_track(byte cmd, byte retries) {
    byte r;
    read_track_cmd = cmd;
    retry_count = retries;

    while (1) {
        /* clear floppy interrupt flag */
        di();
        floppy_flag = 0;
        ei();

        if ((read_track_cmd & 0x0F) != FDC_READ_ID) {
            /* program DMA channel 1 for floppy transfer */
            di();
            dma_mask(1);                     /* disable Ch1 during programming */
            dma_mode(0x45);                  /* Ch1: demand, incr, write I/O->mem */
            dma_clear_bp();                  /* reset byte pointer flip-flop */
            dma_ch1_addr(dma_addr);          /* transfer destination address */
            dma_ch1_wc(transfer_bytes - 1);  /* word count (N-1) */
            dma_unmask(1);                   /* enable Ch1 */
            ei();
        }

        floppy_read_track(read_track_cmd);

        if (wait_floppy_interrupt(0xFF)) {
            return 1;
        }

        r = check_fdc_result();
        if (r == 0) {
            return 0;
        }
        if (r == 2) {
            return 1;
        }
    }
}

/* Auto-detect disk format by reading sector ID.
 * Tries FM first, then MFM.  Returns 0=ok, 1=error. */
byte disk_autodetect(void) {
    disk_bits &= ~0x01;

    while (1) {
        if (floppy_seek() != 0) { return 1; }

        transfer_bytes = 4;
        if (read_track(FDC_READ_ID, 1) == 0) { break; }
        if (disk_bits & 0x01) { return 1; }
        disk_bits |= 0x01;                  /* switch to MFM and retry */
    }

    /* N (sector size code) from Read ID result */
    disk_bits = (disk_bits & 0xE3) | (fdc_result[6] << 2);
    sector_size_code = (disk_bits >> 2) & 0x07;
    format_lookup();
    calc_track_bytes();
    return 0;
}

/* ================================================================
 * 5. Boot logic
 * ================================================================ */

/* Boot state variables — initialized to zero; preinit() sets non-zero.
 *
 * FDC command block (current_cylinder..data_length) must be contiguous.
 * floppy_read_track() sends 7 bytes starting at &current_cylinder.
 * Do not reorder or insert variables between them. */
byte fdc_result[7] = {0};
byte fdc_flag = 0;
byte drive_select = 0;
byte fdc_timeout = 0;
byte fdc_wait = 0;
byte current_cylinder = 0;          /* --- FDC command block start --- */
byte current_head = 0;
byte current_sector = 0;
byte sector_size_code = 0;
byte end_of_track = 0;
byte gap3 = 0;
byte data_length = 0;               /* --- FDC command block end --- */
byte floppy_flag = 0;
byte floppy_wait = 0;
byte disk_bits = 0;
byte disk_type = 0;
byte more_flag = 0;
byte retry_count = 0;
word dma_addr = 0;
word transfer_bytes = 0;
word track_overflow = 0;
byte error_saved = 0;

/* Error/status message strings (non-static for assembly access) */
const char msg_rc702[]   = " RC702";

/* Infinite loop — never returns. */
void halt_forever(void) { for (;;); }

/* Copy 'len' bytes to display buffer, then halt forever.
 * Macro so 'len' is compile-time constant — sdcc inlines as LDIR.
 * 'len' must NOT include NUL terminator. */
#define halt_msg(msg, len) do { memcpy(dspstr, (msg), (len)); halt_forever(); } while(0)

/* Compare 6 bytes.  Pointer-increment generates compact sdcc output
 * (17 bytes, no IX frame) vs memcmp library call (24 bytes more). */
byte compare_6bytes(const byte *a, const byte *b) {
    byte i = 6;
    do {
        if (*a++ != *b++) {
            return 1;
        }
    } while (--i);
    return 0;
}

/* Check directory entry: 4-byte name match + attribute byte check. */
byte check_sysfile(const byte *dir, const byte *pattern) {
    byte i = 4;
    dir++;                                   /* skip user number (dir[0]) */
    do {
        if (*dir++ != *pattern++) {
            return 1;
        }
    } while (--i);
    /* dir now at dir[5], check attribute at dir[8] */
    if ((dir[3] & 0x3F) != 0x13) {
        return 1;
    }
    return 0;
}

/* Display error and halt (unless disk_type indicates retry). */
void error_display_halt(byte code) {
    error_saved = code;
    ei();
    if (disk_type & 0x01) { return; }
    beep();
    halt_msg("**DISKETTE ERROR** ", 19);
}

/*
 * Verify Track 0 data and boot CP/M or ID-COMAL.
 *
 * Checks two signatures in Track 0:
 *   0x0002: " RC700" — ID-COMAL: search dir for SYSM/SYSC entries
 *   0x0008: " RC702" — CP/M: jump via vector at 0x0000
 *
 * File-scope global (boot_dir) avoids IX frame pointer.
 * goto shares error path to avoid duplicate halt_msg calls.
 */
static const char sysm_name[] = "SYSM";
static const char sysc_name[] = "SYSC";

static byte *boot_dir;

void boot_sysmsysc_or_jp0_or_halt(void) {
    if (compare_6bytes((const byte *)RC700_SIG_OFF, (const byte *)" RC700") == 0) {
        boot_dir = (byte *)BOOT_DIR_OFF;
        while ((word)boot_dir < 0x0D00) {
            if (*boot_dir == 0) {
                boot_dir += 0x20;
                continue;
            }
            if (check_sysfile(boot_dir, (const byte *)sysm_name) != 0) {
                goto nosys;
            }
            boot_dir += 0x20;
            if (*boot_dir == 0) {
                goto nosys;
            }
            if (check_sysfile(boot_dir, (const byte *)sysc_name) != 0) {
                goto nosys;
            }
            return;
        }
        goto nosys;
    }

    if (compare_6bytes((const byte *)RC702_SIG_OFF, (const byte *)msg_rc702) == 0) {
        jump_to(*(word *)0x0000);
        return;
    }

    halt_msg(" **NO KATALOG** ", 16);
    return;

nosys:
    halt_msg(" **NO SYSTEM FILES** ", 21);
}

/* Check secondary PROM at 0x2000 for RC702 signature; jump or halt. */
void check_prom1(void) {
    if (compare_6bytes((const byte *)0x2002, (const byte *)msg_rc702) == 0) {
        jump_to(*(word *)0x2000);
        return;
    }
    halt_msg(" **NO DISKETTE NOR LINEPROG** ", 30);
}

/* Read Track 0 data across multiple sides/cylinders. */
static void rdtrk0(word track_overflow_init) {
    track_overflow = track_overflow_init;

    while (1) {
        byte r = floppy_seek();
        if (r == 1) {
            check_prom1();
            return;
        }
        if (r != 0) {
            error_display_halt(0x06);
            return;
        }

        /* calculate transfer size (inlined calctx) */
        {
            int16_t remaining;
            calc_track_bytes();
            remaining = (int16_t)track_overflow - (int16_t)transfer_bytes;
            if (remaining > 0) {
                more_flag = 1;
                track_overflow = (word)remaining;
            } else {
                more_flag = 0;
                transfer_bytes = track_overflow;
                track_overflow = 0;
            }
        }

        if (read_track(FDC_READ_DATA, 5) != 0) {
            error_display_halt(0x28);
            return;
        }

        dma_addr += transfer_bytes;
        transfer_bytes = 0;

        /* advance to next head/side or cylinder (inlined nxthds) */
        {
            byte max_head;
            current_sector = 1;
            max_head = (disk_bits >> 1) & 0x01;
            if (max_head == current_head) {
                current_head = 0;
                current_cylinder++;
            } else {
                current_head++;
            }
        }

        if (!more_flag) {
            return;
        }
    }
}

/* Initialize boot state and start floppy boot.
 * Placed before fldsk1 for tail-call fall-through (saves 3 bytes). */
static void preinit(void) {
    fdc_timeout = 3;
    fdc_wait = 4;
    floppy_wait = 4;
    disk_bits = read_sw1() & 0x80;           /* bit 7: 0=maxi, 1=mini */

    ei();
    motor(1);                                /* turn on floppy motor */
    retry_count = 5;
    fldsk1();
}

/* Floppy boot sequence: sense, recalibrate, detect, read, boot.
 * Placed before floppy_boot for tail-call fall-through (saves 3 bytes). */
static void fldsk1(void) {
    byte status;

    delay(1, 0xFF);

    /* sense drive status (inlined sense_drive) */
    fdc_wait_write(FDC_SENSE_DRIVE);
    fdc_wait_write(drive_select);
    fdc_result[0] = fdc_wait_read();
    status = fdc_result[0] & 0x23;           /* ST3: RDY + HD + US */

    /* recalibrate (inlined fdc_recalibrate + recalibrate_verify) */
    fdc_wait_write(FDC_RECALIBRATE);
    fdc_wait_write(drive_select);

    if (status != (drive_select + 0x20) ||   /* expect RDY + matching drive */
        chk_seekres(0) != 0) {
        check_prom1();
        return;
    }

    /* detect disk format on both sides (inlined detect_floppy_format) */
    current_cylinder = 0;
    current_head = 1;
    current_sector = 1;
    if (disk_autodetect() == 0) {
        disk_bits |= 0x02;                  /* side 1 present */
    }
    current_head = 0;
    if (disk_autodetect() != 0) {
        check_prom1();
        return;
    }

    prom_disable();                          /* disable ROM overlay */

    while (1) {
        rdtrk0(transfer_bytes);
        if (current_cylinder != 0) {
            break;
        }
        disk_autodetect();
    }

    disk_type = 1;
    boot_sysmsysc_or_jp0_or_halt();
    floppy_boot();
}

/* Boot from floppy: read COMAL boot area and jump to 0x1000. */
void floppy_boot(void) {
    disk_type = (disk_bits & 0x80) | disk_type;
    disk_type--;
    disk_autodetect();
    dma_addr = FLOPPYDATA;
    rdtrk0(0x7300 - 0x7000);
    disk_type = 1;
    jump_to(COMALBOOT);
}

/* BIOS syscall: read sectors from disk.
 * addr = DMA destination, bc = packed cylinder/head/sector. */
void syscall(word addr, word de) {
    byte d = (byte)(de >> 8);
    byte e = (byte)(de & 0xFF);

    dma_addr = addr;
    current_sector = e & 0x7F;
    current_cylinder = d & 0x7F;

    if (current_cylinder == 0) {
        disk_autodetect();
    }

    current_head = (d & 0x80) ? 1 : 0;
    rdtrk0(0);

    if ((d & 0x7F) == 0) {
        current_cylinder = 1;
        disk_autodetect();
    }
}

/* Entry point — called by init_relocated() after peripheral init. */
void main(void) {
    init_fdc();
    clear_screen();
    display_banner_and_start_crt();
    preinit();
}

/* ================================================================
 * 6. Interrupt service routines
 * ================================================================ */

/* Dummy ISR for unused interrupt vectors (generates EI + RETI). */
void nothing_int(void) __interrupt(0) {
}

/* CRT vertical retrace ISR (CTC Ch2).
 *
 * Reprograms DMA Ch2/Ch3 for circular-buffer display scrolling.
 * Ch2: from DSPSTR+scroll_offset to end of buffer (visible top->bottom).
 * Ch3: from DSPSTR for full 2000 bytes (wraps around to supply the rest).
 * Ch2 runs first (higher priority), Ch3 continues after Ch2 exhausts.
 *
 * This avoids a 1920-byte memcpy on every scroll — the BIOS just
 * increments scroll_offset by 80 and the DMA hardware handles the wrap.
 * The boot ROM itself never scrolls (scroll_offset stays 0).
 *
 * __critical keeps interrupts disabled (protects DMA programming).
 * __interrupt(N) generates register save/restore + EI + RETI. */
void crtint(void) __critical __interrupt(1) {
    (void)crt_status();                      /* acknowledge CRT interrupt */

    dma_mask(2);                             /* disable Ch2 during programming */
    dma_mask(3);                             /* disable Ch3 during programming */
    dma_clear_bp();                          /* reset byte pointer flip-flop */

    word so = scroll_offset;
    dma_ch2_addr(DSPSTR_ADDR + so);          /* Ch2: start at scroll offset */
    dma_ch2_wc(80 * 25 - 1 - so);           /* Ch2: remaining bytes */

    dma_ch3_addr(DSPSTR_ADDR);               /* Ch3: buffer base */
    dma_ch3_wc(80 * 25 - 1);                /* Ch3: full screen */

    dma_unmask(2);                           /* re-enable Ch2 */
    dma_unmask(3);                           /* re-enable Ch3 */

    ctc2_write(0xD7);                        /* rearm CTC Ch2: counter, interrupt */
    ctc2_write(0x01);                        /* time constant = 1 (every retrace) */
}

/* Floppy disk ISR (CTC Ch3).
 * Sets floppy_flag, then reads result or senses interrupt. */
void flpint(void) __critical __interrupt(2) {
    floppy_flag = 2;
    delay(0, fdc_timeout);
    if (fdc_status() & 0x10) {               /* CB=1: result phase ready */
        fdc_read_result();
    } else {
        fdc_sense_interrupt();
    }
}

/* ================================================================
 * 7. Sentinel — must be last.
 * &code_end - &intvec = payload size to relocate from ROM to RAM.
 * ================================================================ */
const byte code_end = 0xFF;
