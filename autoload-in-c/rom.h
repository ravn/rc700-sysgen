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

/* NEC uPD765 (Intel 8272) FDC command bytes.
 * Datasheet: https://www.cpcwiki.eu/imgs/f/f3/UPD765_Datasheet_OCRed.pdf
 * See also Intel 8272A datasheet (pin-compatible clone). */
#define FDC_SENSE_DRIVE   0x04  /* returns ST3 (drive status) */
#define FDC_RECALIBRATE   0x07  /* seek to track 0 */
#define FDC_SENSE_INT     0x08  /* returns ST0 + PCN after seek/recalibrate */
#define FDC_SEEK          0x0F  /* seek to specified cylinder */
#define FDC_READ_DATA     0x06  /* read sector data via DMA */
#define FDC_READ_ID       0x0A  /* read next sector ID (C/H/R/N) from current
                                 * head position without transferring data.
                                 * Used by disk_autodetect() to determine
                                 * sector size (N) and density (FM vs MFM)
                                 * without knowing the disk format in advance.
                                 * Returns 7 result bytes: ST0, ST1, ST2,
                                 * C, H, R, N — where N = sector size code
                                 * (0=128, 1=256, 2=512, 3=1024 bytes). */
#define FDC_MFM           0x40  /* OR with command for MFM (double density) */

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
 * Z80 port I/O — portable via z80_inp / z80_outp
 * ================================================================ */

/* RC702 I/O port addresses */
#define PORT_CRT_PARAM    0x00
#define PORT_CRT_CMD      0x01
#define PORT_FDC_STATUS   0x04
#define PORT_FDC_DATA     0x05
#define PORT_CTC0         0x0C
#define PORT_CTC1         0x0D
#define PORT_CTC2         0x0E
#define PORT_CTC3         0x0F
#define PORT_PIO_A_DATA   0x10
#define PORT_PIO_B_DATA   0x11
#define PORT_PIO_A_CTRL   0x12
#define PORT_PIO_B_CTRL   0x13
#define PORT_SW1          0x14
#define PORT_RAMEN        0x18
#define PORT_BIB          0x1C
#define PORT_DMA_CH1_ADDR 0xF2
#define PORT_DMA_CH1_WC   0xF3
#define PORT_DMA_CH2_ADDR 0xF4
#define PORT_DMA_CH2_WC   0xF5
#define PORT_DMA_CH3_ADDR 0xF6
#define PORT_DMA_CH3_WC   0xF7
#define PORT_DMA_CMD      0xF8
#define PORT_DMA_SMSK     0xFA
#define PORT_DMA_MODE     0xFB
#define PORT_DMA_CLBP     0xFC

/* Port I/O — produces inline IN A,(n) / OUT (n),A on all Z80 backends.
 *
 * clang:       __attribute__((address_space(2))) maps to Z80 I/O space.
 * sdcc/sccz80: __sfr __at maps to Z80 I/O space (first-class feature).
 * other:       stubs for IDE indexing (CLion, clangd).
 *
 * The high-level macros (fdc_status, crt_param, etc.) are the public API.
 * Each macro expands to the appropriate backend-specific port access. */

#if defined(__clang__)
/* clang: address_space(2) = Z80 I/O port space → inline IN/OUT */
#define __io __attribute__((address_space(2)))
#define _pin(port)        (*(volatile __io uint8_t *)(uint8_t)(port))
#define _pout(port, val)  do { *(volatile __io uint8_t *)(uint8_t)(port) = (val); } while(0)
#elif defined(__SDCC) || defined(__SCCZ80)
/* sdcc/sccz80: __sfr __at → inline IN/OUT (2 bytes each) */
__sfr __at PORT_CRT_PARAM    _sfr_crt_param;
__sfr __at PORT_CRT_CMD      _sfr_crt_cmd;
__sfr __at PORT_FDC_STATUS   _sfr_fdc_status;
__sfr __at PORT_FDC_DATA     _sfr_fdc_data;
__sfr __at PORT_CTC0         _sfr_ctc0;
__sfr __at PORT_CTC1         _sfr_ctc1;
__sfr __at PORT_CTC2         _sfr_ctc2;
__sfr __at PORT_CTC3         _sfr_ctc3;
__sfr __at PORT_PIO_A_DATA   _sfr_pio_a_data;
__sfr __at PORT_PIO_B_DATA   _sfr_pio_b_data;
__sfr __at PORT_PIO_A_CTRL   _sfr_pio_a_ctrl;
__sfr __at PORT_PIO_B_CTRL   _sfr_pio_b_ctrl;
__sfr __at PORT_SW1          _sfr_sw1;
__sfr __at PORT_RAMEN        _sfr_ramen;
__sfr __at PORT_BIB          _sfr_bib;
__sfr __at PORT_DMA_CH1_ADDR _sfr_dma_ch1_addr;
__sfr __at PORT_DMA_CH1_WC   _sfr_dma_ch1_wc;
__sfr __at PORT_DMA_CH2_ADDR _sfr_dma_ch2_addr;
__sfr __at PORT_DMA_CH2_WC   _sfr_dma_ch2_wc;
__sfr __at PORT_DMA_CH3_ADDR _sfr_dma_ch3_addr;
__sfr __at PORT_DMA_CH3_WC   _sfr_dma_ch3_wc;
__sfr __at PORT_DMA_CMD      _sfr_dma_cmd;
__sfr __at PORT_DMA_SMSK     _sfr_dma_smsk;
__sfr __at PORT_DMA_MODE     _sfr_dma_mode;
__sfr __at PORT_DMA_CLBP     _sfr_dma_clbp;
#endif

/* Hardware access macros — the public API used by rom.c and boot_rom.c.
 * Each macro maps to the backend-specific port access mechanism. */
#if defined(__clang__)
#define read_sw1()              _pin(PORT_SW1)
#define diskette_size()         ((_pin(PORT_SW1) >> 7) & 1)
#define prom_disable()          _pout(PORT_RAMEN, 1)
#define motor(on)               _pout(PORT_SW1, (on) ? 1 : 0)
#define beep()                  _pout(PORT_BIB, 0)
#define fdc_command(cmd)        _pout(PORT_FDC_DATA, (cmd))
#define fdc_status()            _pin(PORT_FDC_STATUS)
#define fdc_data_read()         _pin(PORT_FDC_DATA)
#define fdc_data_write(d)       _pout(PORT_FDC_DATA, (d))
#define dma_command(cmd)        _pout(PORT_DMA_CMD, (cmd))
#define dma_mask(ch)            _pout(PORT_DMA_SMSK, (ch) | 0x04)
#define dma_unmask(ch)          _pout(PORT_DMA_SMSK, (ch))
#define dma_clear_bp()          _pout(PORT_DMA_CLBP, 0)
#define dma_mode(m)             _pout(PORT_DMA_MODE, (m))
#define dma_status()            _pin(PORT_DMA_CMD)
#define pio_write_a_data(d)     _pout(PORT_PIO_A_DATA, (d))
#define pio_write_a_ctrl(d)     _pout(PORT_PIO_A_CTRL, (d))
#define pio_write_b_data(d)     _pout(PORT_PIO_B_DATA, (d))
#define pio_write_b_ctrl(d)     _pout(PORT_PIO_B_CTRL, (d))
#define crt_param(d)            _pout(PORT_CRT_PARAM, (d))
#define crt_command(d)          _pout(PORT_CRT_CMD, (d))
#define crt_status()            _pin(PORT_CRT_CMD)
#elif defined(__SDCC) || defined(__SCCZ80)
#define read_sw1()              (_sfr_sw1)
#define diskette_size()         ((_sfr_sw1 >> 7) & 1)
#define prom_disable()          (_sfr_ramen = 1)
#define motor(on)               (_sfr_sw1 = (on) ? 1 : 0)
#define beep()                  (_sfr_bib = 0)
#define fdc_command(cmd)        (_sfr_fdc_data = (cmd))
#define fdc_status()            (_sfr_fdc_status)
#define fdc_data_read()         (_sfr_fdc_data)
#define fdc_data_write(d)       (_sfr_fdc_data = (d))
#define dma_command(cmd)        (_sfr_dma_cmd = (cmd))
#define dma_mask(ch)            (_sfr_dma_smsk = (ch) | 0x04)
#define dma_unmask(ch)          (_sfr_dma_smsk = (ch))
#define dma_clear_bp()          (_sfr_dma_clbp = 0)
#define dma_mode(m)             (_sfr_dma_mode = (m))
#define dma_status()            (_sfr_dma_cmd)
#define pio_write_a_data(d)     (_sfr_pio_a_data = (d))
#define pio_write_a_ctrl(d)     (_sfr_pio_a_ctrl = (d))
#define pio_write_b_data(d)     (_sfr_pio_b_data = (d))
#define pio_write_b_ctrl(d)     (_sfr_pio_b_ctrl = (d))
#define crt_param(d)            (_sfr_crt_param = (d))
#define crt_command(d)          (_sfr_crt_cmd = (d))
#define crt_status()            (_sfr_crt_cmd)
#else
#define read_sw1()              0
#define diskette_size()         0
#define prom_disable()          ((void)0)
#define motor(on)               ((void)0)
#define beep()                  ((void)0)
#define fdc_command(cmd)        ((void)0)
#define fdc_status()            0
#define fdc_data_read()         0
#define fdc_data_write(d)       ((void)0)
#define dma_command(cmd)        ((void)0)
#define dma_mask(ch)            ((void)0)
#define dma_unmask(ch)          ((void)0)
#define dma_clear_bp()          ((void)0)
#define dma_mode(m)             ((void)0)
#define dma_status()            0
#define pio_write_a_data(d)     ((void)0)
#define pio_write_a_ctrl(d)     ((void)0)
#define pio_write_b_data(d)     ((void)0)
#define pio_write_b_ctrl(d)     ((void)0)
#define crt_param(d)            ((void)0)
#define crt_command(d)          ((void)0)
#define crt_status()            0
#endif

/* Use z88dk intrinsics for DI/EI — gives the compiler correct
 * register preservation information (__preserves_regs). */
#ifdef __SDCC
#include <intrinsic.h>
#define ei()  intrinsic_ei()
#define di()  intrinsic_di()
#else
static inline void intrinsic_di(void) {}
static inline void intrinsic_ei(void) {}
static inline void intrinsic_im_2(void) {}
#endif

/* CTC channel writes and DMA channel address/word count macros.
 * DMA address/word count require two consecutive port writes (low, high). */
#if defined(__clang__)
#define ctc0_write(d)           _pout(PORT_CTC0, (d))
#define ctc1_write(d)           _pout(PORT_CTC1, (d))
#define ctc2_write(d)           _pout(PORT_CTC2, (d))
#define ctc3_write(d)           _pout(PORT_CTC3, (d))
#define dma_ch1_addr(a) do { _pout(PORT_DMA_CH1_ADDR,(byte)(a)); _pout(PORT_DMA_CH1_ADDR,(byte)((a)>>8)); } while(0)
#define dma_ch1_wc(w)   do { _pout(PORT_DMA_CH1_WC,(byte)(w));   _pout(PORT_DMA_CH1_WC,(byte)((w)>>8));   } while(0)
#define dma_ch2_addr(a) do { _pout(PORT_DMA_CH2_ADDR,(byte)(a)); _pout(PORT_DMA_CH2_ADDR,(byte)((a)>>8)); } while(0)
#define dma_ch2_wc(w)   do { _pout(PORT_DMA_CH2_WC,(byte)(w));   _pout(PORT_DMA_CH2_WC,(byte)((w)>>8));   } while(0)
#define dma_ch3_addr(a) do { _pout(PORT_DMA_CH3_ADDR,(byte)(a)); _pout(PORT_DMA_CH3_ADDR,(byte)((a)>>8)); } while(0)
#define dma_ch3_wc(w)   do { _pout(PORT_DMA_CH3_WC,(byte)(w));   _pout(PORT_DMA_CH3_WC,(byte)((w)>>8));   } while(0)
#elif defined(__SDCC) || defined(__SCCZ80)
#define ctc0_write(d)           (_sfr_ctc0 = (d))
#define ctc1_write(d)           (_sfr_ctc1 = (d))
#define ctc2_write(d)           (_sfr_ctc2 = (d))
#define ctc3_write(d)           (_sfr_ctc3 = (d))
#define dma_ch1_addr(a) do { _sfr_dma_ch1_addr=(byte)(a); _sfr_dma_ch1_addr=(byte)((a)>>8); } while(0)
#define dma_ch1_wc(w)   do { _sfr_dma_ch1_wc=(byte)(w);   _sfr_dma_ch1_wc=(byte)((w)>>8);   } while(0)
#define dma_ch2_addr(a) do { _sfr_dma_ch2_addr=(byte)(a); _sfr_dma_ch2_addr=(byte)((a)>>8); } while(0)
#define dma_ch2_wc(w)   do { _sfr_dma_ch2_wc=(byte)(w);   _sfr_dma_ch2_wc=(byte)((w)>>8);   } while(0)
#define dma_ch3_addr(a) do { _sfr_dma_ch3_addr=(byte)(a); _sfr_dma_ch3_addr=(byte)((a)>>8); } while(0)
#define dma_ch3_wc(w)   do { _sfr_dma_ch3_wc=(byte)(w);   _sfr_dma_ch3_wc=(byte)((w)>>8);   } while(0)
#else
#define ctc0_write(d)           ((void)0)
#define ctc1_write(d)           ((void)0)
#define ctc2_write(d)           ((void)0)
#define ctc3_write(d)           ((void)0)
#define dma_ch1_addr(a)         ((void)0)
#define dma_ch1_wc(w)           ((void)0)
#define dma_ch2_addr(a)         ((void)0)
#define dma_ch2_wc(w)           ((void)0)
#define dma_ch3_addr(a)         ((void)0)
#define dma_ch3_wc(w)           ((void)0)
#endif

/* ================================================================
 * Stuff in boot.c
 * ================================================================ */

void fdc_write_when_ready(byte val);
byte fdc_read_when_ready(void);
void delay(byte outer, byte inner);

/* ================================================================
 * Boot state — extern declarations
 * ================================================================ */

/*
 * Individual globals, initialized to zero.
 * Z80: BSS is inside CODE (no separate ORG), so variables are part of
 * the PROM payload — copied to RAM by begin() as zeros.
 */

/* FDC result bytes.  After Read Data / Read ID:
 *   st0, st1, st2, cylinder, head, sector, size_code, dma_status
 * After Sense Drive Status:
 *   st3 (in st0 position)
 * After Sense Interrupt Status:
 *   st0, pcn (present cylinder, in st1 position)
 * The dma_status byte is read from the DMA controller after transfer,
 * not from the FDC itself.
 *
 * See uPD765 datasheet Table 3 for result phase byte definitions:
 *   https://www.cpcwiki.eu/imgs/f/f3/UPD765_Datasheet_OCRed.pdf */

typedef struct {
    byte st0;           /* ST0: IC(7-6), SE(5), EC(4), NR(3), HD(2), US(1-0) */
    byte st1;           /* ST1: EN, DE, OR, ND, NW, MA — or PCN after Sense Int */
    byte st2;           /* ST2: CM(6), DD, WC, SH, SN, BC, MD, MA */
    byte cylinder;      /* C: cylinder number at end of operation */
    byte head;          /* H: head number */
    byte sector;        /* R: sector number */
    byte size_code;     /* N: sector size code (0=128, 1=256, 2=512, 3=1024, etc. we only use 128, 256 and 512) */
    byte dma_status;    /* DMA controller status (read after FDC result phase) */
} fdc_result_block;

extern fdc_result_block fdc_result;
extern byte drive_select;      /* drive select */
extern byte fdc_isr_delay;      /* FDC timeout counter (init=3) */
extern byte fdc_result_delay;      /* FDC wait count (init=4) */
/* FDC command parameter block — 7 contiguous bytes sent by floppy_read_track().
 * Fields map to uPD765 Read Data parameters: C, H, R, N, EOT, GPL, DTL. */
typedef struct {
    byte cylinder;
    byte head;
    byte sector;
    byte size_shift;     /* N value: sector size = 128 << N */
    byte eot;            /* end of track (last sector number) */
    byte gap3;           /* gap 3 length */
    byte dtl;            /* data length (0x80 when N > 0) */
} fdc_command_block;

extern fdc_command_block fdc_cmd;
extern byte floppy_operation_completed_flag;      /* floppy interrupt flag (0=idle, 2=done) */
extern byte is_mini;              /* 1=mini/5.25", 0=maxi/8" (from SW1 bit 7) */
extern byte is_mfm;              /* 1=MFM (double density), 0=FM (single) */
extern byte detected_max_head;     /* 1=side 1 present */
extern byte disk_type;      /* disk type flag */
extern byte more_tracks_to_read;      /* more data flag */
extern byte retry_count;      /* retry count */
extern word dma_transfer_address;     /* DMA memory address */
extern word dma_transfer_size;      /* transfer byte count */
extern word bytes_left_to_read;     /* bytes remaining to read */
extern byte error_saved;      /* saved error code */

/* ================================================================
 * Function declarations
 * ================================================================ */

/* init */
void init_peripherals(void);
void init_fdc(void);

/* fmt */
void lookup_sectors_and_gap3_for_current_track(void);

void calc_size_of_current_track(void);

/* fdc */
void fdc_sense_interrupt(void);
void fdc_seek(byte head_and_drive, byte cylinder);
void fdc_read_result(void);
byte fdc_select_drive_cylinder_head(void);
void fdc_write_full_cmd(byte cmd);
byte wait_fdc_ready(byte timeout);
byte check_fdc_result(void);
byte fdc_get_result_bytes(byte cmd, byte retries);
byte fdc_detect_sector_size_and_density(void);

/* boot */
void display_banner_and_start_crt(void);
void error_display_halt(byte code);
void floppy_boot(void);
void prom1_if_present(void);
void halt_forever(void);
byte compare_6bytes(const byte *a, const byte *b);
byte check_sysfile(const byte *dir, const char *pattern);
void syscall(word addr, word de);


#endif /* ROM_H */
