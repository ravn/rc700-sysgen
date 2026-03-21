/*
 * rom.h — Types, constants, port I/O, and declarations for RC702 autoload PROM
 *
 * Single header for the entire ROM build.  Combines hardware abstraction
 * (port macros, intrinsics) with boot state declarations and function
 * prototypes.
 *
 * Register-based calling convention: functions take up to 2 parameters
 * and return values via sdcccall(1) ABI (first param in A/HL, second
 * in E/DE, return in L/HL).
 */

#ifndef ROM_H
#define ROM_H

#include <stdint.h>

/* Stub sdcc keywords for non-sdcc compilers (CLion, clangd) */
#ifndef __SDCC
#define __sfr
#define __at(x)
#define __interrupt(x)
#define __critical
#define __naked
#define __asm__(x)
#endif

typedef uint8_t  byte;
typedef uint16_t word;

/* ================================================================
 * Constants
 * ================================================================ */

/* NEC uPD765 (Intel 8272) FDC command bytes */
#define FDC_SENSE_DRIVE   0x04
#define FDC_RECALIBRATE   0x07
#define FDC_SENSE_INT     0x08
#define FDC_SEEK          0x0F
#define FDC_READ_DATA     0x06
#define FDC_READ_ID       0x0A
#define FDC_MFM           0x40  /* set bit 6 for MFM (double density) */

/* Stringification macros for inline asm constants */
#define STR_(x) #x
#define STR(x)  STR_(x)

/* Memory layout constants */
#define INTVEC_ADDR 0x7000      /* IVT base (page-aligned for Z80 IM2) */
#define INTVEC_PAGE (INTVEC_ADDR >> 8)  /* I register value (0x70) */
#define ROM_STACK   0xBFFF      /* Stack set by ROM entry / INIT_RELOCATED */
#define FLOPPYDATA  0x0000      /* Track 0 loaded here by ROM */
#define COMALBOOT   0x1000      /* COMAL-80 boot address */
#define PROM1_ADDR  0x2000      /* Secondary PROM (network boot) */
#define DIROFF      0x0B60      /* Directory start in Track 0 */
#define DIREND_HI   0x0D        /* Directory end high byte */
#define DSPSTR_ADDR 0x7800      /* Display refresh memory (80x24) */
#define DSP_CHARS   0x0780      /* Display buffer size (1920 bytes) */
#define ATTOFF      7           /* Attribute byte offset in dir entry */
#define SECSZ0      0x80        /* Sector size for Track 0 Side 0 (128B) */

/* Boot signature offsets in Track 0 */
#define RC700_SIG_OFF  0x0002   /* " RC700" signature at offset 2 */
#define RC702_SIG_OFF  0x0008   /* " RC702" signature at offset 8 */
#define BOOT_DIR_OFF   0x0B80   /* Directory area for RC702 format */

/* Display buffer — mapped to CRT refresh memory */
#define dspstr         ((byte *)0x7800)
#define scroll_offset  (*(word *)0x7FF5)

/* Transfer control to address — never returns.
 * Uses a function pointer call (CALL, not JP).  The dangling return
 * address on the stack is harmless since the target never returns. */
#define jump_to(addr) ((void (*)(void))(addr))()

/* ================================================================
 * Z80 port I/O — inline via __sfr
 * ================================================================ */

/* Port declarations — sdcc __sfr __at maps a C variable to a Z80 I/O port.
 * Reading the variable compiles to IN A,(port), writing to OUT (port),A.
 * Each port access is just two bytes of Z80 code with no function call
 * overhead.  However, sdcc naively reloads A between consecutive writes
 * to different ports with the same value (e.g. two OUT instructions both
 * needing A=0x4F).  Custom peephole rules in peephole.def eliminate these
 * redundant loads, saving 2 bytes per occurrence in init sequences. */
#ifdef __SDCC
__sfr __at 0x14 _port_sw1;
__sfr __at 0x18 _port_ramen;
__sfr __at 0x1C _port_bib;
__sfr __at 0x10 _port_pio_a_data;
__sfr __at 0x11 _port_pio_b_data;
__sfr __at 0x12 _port_pio_a_ctrl;
__sfr __at 0x13 _port_pio_b_ctrl;
__sfr __at 0x0C _port_ctc0;
__sfr __at 0x0D _port_ctc1;
__sfr __at 0x0E _port_ctc2;
__sfr __at 0x0F _port_ctc3;
__sfr __at 0x00 _port_crt_param;
__sfr __at 0x01 _port_crt_cmd;
__sfr __at 0x04 _port_fdc_status;
__sfr __at 0x05 _port_fdc_data;
__sfr __at 0xF2 _port_dma_ch1_addr;
__sfr __at 0xF3 _port_dma_ch1_wc;
__sfr __at 0xF4 _port_dma_ch2_addr;
__sfr __at 0xF5 _port_dma_ch2_wc;
__sfr __at 0xF6 _port_dma_ch3_addr;
__sfr __at 0xF7 _port_dma_ch3_wc;
__sfr __at 0xF8 _port_dma_cmd;
__sfr __at 0xFA _port_dma_smsk;
__sfr __at 0xFB _port_dma_mode;
__sfr __at 0xFC _port_dma_clbp;
#else
/* Stubs for non-sdcc compilers (CLion indexing, clangd, etc.) */
extern volatile unsigned char _port_sw1, _port_ramen, _port_bib;
extern volatile unsigned char _port_pio_a_data, _port_pio_b_data;
extern volatile unsigned char _port_pio_a_ctrl, _port_pio_b_ctrl;
extern volatile unsigned char _port_ctc0, _port_ctc1, _port_ctc2, _port_ctc3;
extern volatile unsigned char _port_crt_param, _port_crt_cmd;
extern volatile unsigned char _port_fdc_status, _port_fdc_data;
extern volatile unsigned char _port_dma_ch1_addr, _port_dma_ch1_wc;
extern volatile unsigned char _port_dma_ch2_addr, _port_dma_ch2_wc;
extern volatile unsigned char _port_dma_ch3_addr, _port_dma_ch3_wc;
extern volatile unsigned char _port_dma_cmd, _port_dma_smsk;
extern volatile unsigned char _port_dma_mode, _port_dma_clbp;
#endif

/* Simple port read/write — compile to single IN/OUT instructions */
#define read_sw1()              (_port_sw1)
#define diskette_size()         ((_port_sw1 >> 7) & 1)
#define prom_disable()          (_port_ramen = 1)
#define motor(on)               (_port_sw1 = (on) ? 1 : 0)
#define beep()                  (_port_bib = 0)

#define fdc_command(cmd)        (_port_fdc_data = (cmd))
#define fdc_status()            (_port_fdc_status)
#define fdc_data_read()         (_port_fdc_data)
#define fdc_data_write(d)       (_port_fdc_data = (d))

#define dma_command(cmd)        (_port_dma_cmd = (cmd))
#define dma_mask(ch)            (_port_dma_smsk = (ch) | 0x04)
#define dma_unmask(ch)          (_port_dma_smsk = (ch))
#define dma_clear_bp()          (_port_dma_clbp = 0)
#define dma_mode(m)             (_port_dma_mode = (m))
#define dma_status()            (_port_dma_cmd)

#define pio_write_a_data(d)     (_port_pio_a_data = (d))
#define pio_write_a_ctrl(d)     (_port_pio_a_ctrl = (d))
#define pio_write_b_data(d)     (_port_pio_b_data = (d))
#define pio_write_b_ctrl(d)     (_port_pio_b_ctrl = (d))

#define crt_param(d)            (_port_crt_param = (d))
#define crt_command(d)          (_port_crt_cmd = (d))
#define crt_status()            (_port_crt_cmd)

/* Use z88dk intrinsics for DI/EI — gives the compiler correct
 * register preservation information (__preserves_regs). */
#ifdef __SDCC
#include <intrinsic.h>
#define ei()  intrinsic_ei()
#define di()  intrinsic_di()
#else
static inline void ei(void) {}
static inline void di(void) {}
static inline void intrinsic_di(void) {}
static inline void intrinsic_ei(void) {}
static inline void intrinsic_im_2(void) {}
#endif

/* CTC channel writes — direct port I/O, no switch overhead.
 * Separate macros per channel avoid unreachable-code warnings
 * from dead branches when the channel is a compile-time constant. */
#define ctc0_write(d)           (_port_ctc0 = (d))
#define ctc1_write(d)           (_port_ctc1 = (d))
#define ctc2_write(d)           (_port_ctc2 = (d))
#define ctc3_write(d)           (_port_ctc3 = (d))

/* DMA channel address/word count — two consecutive port writes */
#define dma_ch1_addr(addr) do { \
    _port_dma_ch1_addr = (byte)(addr); \
    _port_dma_ch1_addr = (byte)((addr) >> 8); \
} while(0)
#define dma_ch1_wc(wc) do { \
    _port_dma_ch1_wc = (byte)(wc); \
    _port_dma_ch1_wc = (byte)((wc) >> 8); \
} while(0)
#define dma_ch2_addr(addr) do { \
    _port_dma_ch2_addr = (byte)(addr); \
    _port_dma_ch2_addr = (byte)((addr) >> 8); \
} while(0)
#define dma_ch2_wc(wc) do { \
    _port_dma_ch2_wc = (byte)(wc); \
    _port_dma_ch2_wc = (byte)((wc) >> 8); \
} while(0)
#define dma_ch3_addr(addr) do { \
    _port_dma_ch3_addr = (byte)(addr); \
    _port_dma_ch3_addr = (byte)((addr) >> 8); \
} while(0)
#define dma_ch3_wc(wc) do { \
    _port_dma_ch3_wc = (byte)(wc); \
    _port_dma_ch3_wc = (byte)((wc) >> 8); \
} while(0)

/* ================================================================
 * HAL functions (implemented in rom.c)
 * ================================================================ */

void fdc_wait_write(byte val);
byte fdc_wait_read(void);
void delay(byte outer, byte inner);

/* ================================================================
 * Boot state — extern declarations
 * ================================================================ */

/*
 * Individual globals, initialized to zero.
 * Z80: BSS is inside CODE (no separate ORG), so variables are part of
 * the PROM payload — copied to RAM by begin() as zeros.
 */

extern byte fdc_result[7];   /* FDC result bytes (ST0-N) */
extern byte fdc_flag;      /* FDC flag */
extern byte sectors_per_track;        /* end-of-track for seek */
extern byte track_size;       /* track size */
extern byte drive_select;      /* drive select */
extern byte fdc_timeout;      /* FDC timeout counter (init=3) */
extern byte fdc_wait;      /* FDC wait count (init=4) */
/* FDC command parameter block — contiguous, sent by floppy_read_track() */
extern byte current_cylinder;      /* current cylinder */
extern byte current_head;      /* current head */
extern byte current_sector;      /* current record/sector */
extern byte sector_size_code;      /* record length (N value) */
extern byte end_of_track;      /* end of track */
extern byte gap3;        /* gap 3 length */
extern byte data_length;         /* data length */
extern word sector_bytes;     /* sector byte count */
extern byte floppy_flag;      /* floppy interrupt flag (0=idle, 2=done) */
extern byte floppy_wait;      /* floppy wait count (init=4) */
extern byte disk_bits;    /* disk type bits */
extern byte disk_type;      /* disk type flag */
extern byte more_flag;      /* more data flag */
extern byte retry_count;      /* retry count */
extern word dma_addr;     /* DMA memory address */
extern word transfer_bytes;      /* transfer byte count */
extern word track_overflow;     /* track overflow */
extern byte error_saved;      /* saved error code */

/* ================================================================
 * Function declarations
 * ================================================================ */

/* init */
void init_peripherals(void);
void init_fdc(void);

/* fmt */
void format_lookup(void);
void calc_track_bytes(void);

/* fdc */
void sense_drive(void);
void fdc_recalibrate(void);
void fdc_sense_interrupt(void);
void fdc_seek(byte dh, byte cyl);
void fdc_read_result(void);
byte recalibrate_verify(void);
byte floppy_seek(void);
void floppy_read_track(byte cmd);
byte wait_floppy_interrupt(byte timeout);
byte check_fdc_result(void);
byte read_track(byte cmd, byte retries);
byte disk_autodetect(void);
void setup_dma(void);

/* boot */
void clear_screen(void);
void display_banner_and_start_crt(void);
void error_display_halt(byte code);
byte detect_floppy_format(void);
void boot_sysmsysc_or_jp0_or_halt(void);
void floppy_boot(void);
void check_prom1(void);
void halt_forever(void);
byte compare_6bytes(const byte *a, const byte *b);
byte check_sysfile(const byte *dir, const byte *pattern);
void syscall(word addr, word bc);

/* isr */
void crt_refresh(void);

#endif /* ROM_H */
