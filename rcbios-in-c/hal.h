/*
 * hal.h — Hardware Abstraction Layer for RC702 CP/M BIOS
 *
 * Port I/O compiles to inline IN/OUT on all Z80 backends:
 *   clang:       __attribute__((address_space(2)))
 *   sdcc/sccz80: __sfr __at
 *   HOST_TEST:   no-op stubs
 */

#ifndef HAL_H
#define HAL_H

#include <stdint.h>

/* ================================================================
 * Port I/O — DEFPORT macro, same approach as autoload-in-c/rom.h
 * ================================================================ */

/* RC702 I/O port addresses */
#define PORT_CRT_PARAM    0x00
#define PORT_CRT_CMD      0x01
#define PORT_FDC_STATUS   0x04
#define PORT_FDC_DATA     0x05
#define PORT_SIO_A_DATA   0x08
#define PORT_SIO_B_DATA   0x09
#define PORT_SIO_A_CTRL   0x0A
#define PORT_SIO_B_CTRL   0x0B
#define PORT_CTC0         0x0C
#define PORT_CTC1         0x0D
#define PORT_CTC2         0x0E
#define PORT_CTC3         0x0F
#define PORT_PIO_A_DATA   0x10
#define PORT_PIO_B_DATA   0x11
#define PORT_PIO_A_CTRL   0x12
#define PORT_PIO_B_CTRL   0x13
#define PORT_SW1          0x14
#define PORT_BELL         0x1C
#define PORT_CTC2_CH0     0x44
#define PORT_CTC2_CH1     0x45
#define PORT_CTC2_CH2     0x46
#define PORT_CTC2_CH3     0x47
#define PORT_HD_DATA      0x60
#define PORT_HD_ERROR     0x61
#define PORT_HD_SECCT     0x62
#define PORT_HD_SECNO     0x63
#define PORT_HD_CYLLO     0x64
#define PORT_HD_CYLHI     0x65
#define PORT_HD_SDH       0x66
#define PORT_HD_STATUS    0x67
#define PORT_DMA_CH0_ADDR 0xF0
#define PORT_DMA_CH0_WC   0xF1
#define PORT_DMA_CH1_ADDR 0xF2
#define PORT_DMA_CH1_WC   0xF3
#define PORT_DMA_CH2_ADDR 0xF4
#define PORT_DMA_CH2_WC   0xF5
#define PORT_DMA_CH3_ADDR 0xF6
#define PORT_DMA_CH3_WC   0xF7
#define PORT_DMA_CMD      0xF8
#define PORT_DMA_REQ      0xF9
#define PORT_DMA_SMSK     0xFA
#define PORT_DMA_MODE     0xFB
#define PORT_DMA_CLBP     0xFC
#define PORT_DMA_TMP      0xFD
#define PORT_DMA_MASK     0xFF

/* DEFPORT: one macro, three backends */
#if defined(__clang__) && !defined(HOST_TEST)
#define __io __attribute__((address_space(2)))
#define DEFPORT(name, addr) \
    static inline uint8_t port_in_##name(void) { \
        return *(volatile __io uint8_t *)(uint8_t)(addr); \
    } \
    static inline void port_out_##name(uint8_t val) { \
        *(volatile __io uint8_t *)(uint8_t)(addr) = val; \
    }
#define port_in(name)       port_in_##name()
#define port_out(name, val) port_out_##name(val)
#elif defined(__SDCC) || defined(__SCCZ80)
#define DEFPORT(name, addr) __sfr __at (addr) _sfr_##name;
#define port_in(name)       (_sfr_##name)
#define port_out(name, val) (_sfr_##name = (val))
#else
#define DEFPORT(name, addr) \
    static inline uint8_t port_in_##name(void) { return 0; } \
    static inline void port_out_##name(uint8_t val) { (void)val; }
#define port_in(name)       port_in_##name()
#define port_out(name, val) port_out_##name(val)
#endif

DEFPORT(crt_param,    PORT_CRT_PARAM)
DEFPORT(crt_cmd,      PORT_CRT_CMD)
DEFPORT(fdc_status,   PORT_FDC_STATUS)
DEFPORT(fdc_data,     PORT_FDC_DATA)
DEFPORT(sio_a_data,   PORT_SIO_A_DATA)
DEFPORT(sio_b_data,   PORT_SIO_B_DATA)
DEFPORT(sio_a_ctrl,   PORT_SIO_A_CTRL)
DEFPORT(sio_b_ctrl,   PORT_SIO_B_CTRL)
DEFPORT(ctc0,         PORT_CTC0)
DEFPORT(ctc1,         PORT_CTC1)
DEFPORT(ctc2,         PORT_CTC2)
DEFPORT(ctc3,         PORT_CTC3)
DEFPORT(pio_a_data,   PORT_PIO_A_DATA)
DEFPORT(pio_b_data,   PORT_PIO_B_DATA)
DEFPORT(pio_a_ctrl,   PORT_PIO_A_CTRL)
DEFPORT(pio_b_ctrl,   PORT_PIO_B_CTRL)
DEFPORT(sw1,          PORT_SW1)
DEFPORT(bell,         PORT_BELL)
DEFPORT(ctc2_ch0,     PORT_CTC2_CH0)
DEFPORT(ctc2_ch1,     PORT_CTC2_CH1)
DEFPORT(ctc2_ch2,     PORT_CTC2_CH2)
DEFPORT(ctc2_ch3,     PORT_CTC2_CH3)
DEFPORT(dma_ch0_addr, PORT_DMA_CH0_ADDR)
DEFPORT(dma_ch0_wc,   PORT_DMA_CH0_WC)
DEFPORT(dma_ch1_addr, PORT_DMA_CH1_ADDR)
DEFPORT(dma_ch1_wc,   PORT_DMA_CH1_WC)
DEFPORT(dma_ch2_addr, PORT_DMA_CH2_ADDR)
DEFPORT(dma_ch2_wc,   PORT_DMA_CH2_WC)
DEFPORT(dma_ch3_addr, PORT_DMA_CH3_ADDR)
DEFPORT(dma_ch3_wc,   PORT_DMA_CH3_WC)
DEFPORT(dma_cmd,      PORT_DMA_CMD)
DEFPORT(dma_req,      PORT_DMA_REQ)
DEFPORT(dma_smsk,     PORT_DMA_SMSK)
DEFPORT(dma_mode,     PORT_DMA_MODE)
DEFPORT(dma_clbp,     PORT_DMA_CLBP)
DEFPORT(dma_tmp,      PORT_DMA_TMP)
DEFPORT(dma_mask,     PORT_DMA_MASK)
DEFPORT(hd_data,      PORT_HD_DATA)
DEFPORT(hd_error,     PORT_HD_ERROR)
DEFPORT(hd_secct,     PORT_HD_SECCT)
DEFPORT(hd_secno,     PORT_HD_SECNO)
DEFPORT(hd_cyllo,     PORT_HD_CYLLO)
DEFPORT(hd_cylhi,     PORT_HD_CYLHI)
DEFPORT(hd_sdh,       PORT_HD_SDH)
DEFPORT(hd_status,    PORT_HD_STATUS)

/* ================================================================
 * DMA channel helpers, CPU control, sdcc keyword compatibility
 * ================================================================ */

/* DMA channel address/word count (two consecutive port writes) */
#define hal_dma_ch1_addr(addr) do { port_out(dma_ch1_addr,(uint8_t)(addr)); port_out(dma_ch1_addr,(uint8_t)((addr)>>8)); } while(0)
#define hal_dma_ch1_wc(wc)    do { port_out(dma_ch1_wc,(uint8_t)(wc));     port_out(dma_ch1_wc,(uint8_t)((wc)>>8));     } while(0)
#define hal_dma_ch2_addr(addr) do { port_out(dma_ch2_addr,(uint8_t)(addr)); port_out(dma_ch2_addr,(uint8_t)((addr)>>8)); } while(0)
#define hal_dma_ch2_wc(wc)    do { port_out(dma_ch2_wc,(uint8_t)(wc));     port_out(dma_ch2_wc,(uint8_t)((wc)>>8));     } while(0)
#define hal_dma_ch3_addr(addr) do { port_out(dma_ch3_addr,(uint8_t)(addr)); port_out(dma_ch3_addr,(uint8_t)((addr)>>8)); } while(0)
#define hal_dma_ch3_wc(wc)    do { port_out(dma_ch3_wc,(uint8_t)(wc));     port_out(dma_ch3_wc,(uint8_t)((wc)>>8));     } while(0)

#ifdef HOST_TEST
/* Host testing stubs */
void hal_ei(void);
void hal_di(void);
#define __naked
#define __critical
#define __interrupt(n)
#define __sdcccall(x)
#define __asm__(x) ((void)0)
#define hal_halt() ((void)0)
#elif defined(__SDCC) || defined(__SCCZ80)
/* Z80 inline helpers */
#define hal_ei()    __asm__("ei")
#define hal_di()    __asm__("di")
#define hal_halt()  __asm__("halt")
#elif defined(__clang__)
/* clang: keyword stubs and intrinsics from clang_z80/intrinsic.h.
 * Found via -Iclang_z80 on the compile command line. */
#include <intrinsic.h>
#define hal_ei()   intrinsic_ei()
#define hal_di()   intrinsic_di()
#define hal_halt() intrinsic_halt()
#endif

#endif /* HAL_H */
