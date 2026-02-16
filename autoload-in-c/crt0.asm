;
; crt0.asm — Startup code for RC702 autoload PROM
;
; This file contains the parts that must stay in assembly:
; - Self-relocation loop (runs from ROM at 0x0000, copies to RAM at 0x7000)
; - Interrupt vector table (page-aligned at 0x7300)
; - NMI stub (RETN at fixed ROM offset)
; - DISINT display interrupt handler (timing-critical DMA reprogramming)
;
; After relocation, sets up SP and calls _main in C code.
;

.Z80
