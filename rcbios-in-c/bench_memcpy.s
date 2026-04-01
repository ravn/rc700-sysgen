; bench_memcpy.s — T-state benchmark: LDIR vs 16x LDI Duff's device
;
; Verifies correctness after each copy by comparing src/dst byte-by-byte.
; On mismatch: DE = test number (1-8), HL = offset of first bad byte.
; On success:  DE = 0.
;
; Source pattern: incrementing bytes (0x00, 0x01, ..., 0xFF, 0x00, ...)
; Destination cleared to 0xFF before each copy.

	.section .text,"ax",@progbits
	.globl	_start
_start:
	ld	sp, 0xFFF0	; set up stack

	; --- Fill source with incrementing pattern ---
	ld	hl, src_buf
	ld	bc, 1920
	xor	a
.Lfill:
	ld	(hl), a
	inc	hl
	inc	a		; wraps 0xFF → 0x00
	dec	bc
	push	af
	ld	a, b
	or	c
	jr	nz, .Lfill_cont
	pop	af
	jr	.Lfill_done
.Lfill_cont:
	pop	af
	jr	.Lfill

.Lfill_done:
	; ========================================
	; Test 1: LDIR — 1920 bytes
	; ========================================
	ld	de, 1		; test number
	call	clear_dst_1920
	.globl	t1_ldir_pre
t1_ldir_pre:
	ld	hl, src_buf
	ld	de, dst_buf
	ld	bc, 1920
	ldir
	.globl	t1_ldir_done
t1_ldir_done:
	nop
	ld	de, 1
	ld	bc, 1920
	call	verify
	; returns here only if OK

	; ========================================
	; Test 2: 16x LDI Duff — 1920 bytes (n_mod=0)
	; ========================================
	ld	de, 2
	call	clear_dst_1920
	.globl	t2_duff_pre
t2_duff_pre:
	ld	hl, src_buf
	ld	de, dst_buf
	ld	bc, 1920
.Lt2_ldi:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	jp	pe, .Lt2_ldi
	.globl	t2_duff_done
t2_duff_done:
	nop
	ld	de, 2
	ld	bc, 1920
	call	verify

	; ========================================
	; Test 3: LDIR — 1000 bytes
	; ========================================
	ld	de, 3
	call	clear_dst_1920
	.globl	t3_ldir_pre
t3_ldir_pre:
	ld	hl, src_buf
	ld	de, dst_buf
	ld	bc, 1000
	ldir
	.globl	t3_ldir_done
t3_ldir_done:
	nop
	ld	de, 3
	ld	bc, 1000
	call	verify

	; ========================================
	; Test 4: 16x LDI Duff — 1000 bytes (n_mod=8)
	; ========================================
	ld	de, 4
	call	clear_dst_1920
	.globl	t4_duff_pre
t4_duff_pre:
	ld	hl, src_buf
	ld	de, dst_buf
	ld	bc, 1000
	jr	.Lt4_entry
.Lt4_ldi:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
.Lt4_entry:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	jp	pe, .Lt4_ldi
	.globl	t4_duff_done
t4_duff_done:
	nop
	ld	de, 4
	ld	bc, 1000
	call	verify

	; ========================================
	; Test 5: LDIR — 80 bytes (one row)
	; ========================================
	ld	de, 5
	call	clear_dst_1920
	.globl	t5_ldir_pre
t5_ldir_pre:
	ld	hl, src_buf
	ld	de, dst_buf
	ld	bc, 80
	ldir
	.globl	t5_ldir_done
t5_ldir_done:
	nop
	ld	de, 5
	ld	bc, 80
	call	verify

	; ========================================
	; Test 6: 16x LDI Duff — 80 bytes (n_mod=0)
	; ========================================
	ld	de, 6
	call	clear_dst_1920
	.globl	t6_duff_pre
t6_duff_pre:
	ld	hl, src_buf
	ld	de, dst_buf
	ld	bc, 80
.Lt6_ldi:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	jp	pe, .Lt6_ldi
	.globl	t6_duff_done
t6_duff_done:
	nop
	ld	de, 6
	ld	bc, 80
	call	verify

	; ========================================
	; Test 7: LDIR — 10 bytes (tiny)
	; ========================================
	ld	de, 7
	call	clear_dst_1920
	.globl	t7_ldir_pre
t7_ldir_pre:
	ld	hl, src_buf
	ld	de, dst_buf
	ld	bc, 10
	ldir
	.globl	t7_ldir_done
t7_ldir_done:
	nop
	ld	de, 7
	ld	bc, 10
	call	verify

	; ========================================
	; Test 8: 16x LDI Duff — 10 bytes (n_mod=10)
	; ========================================
	ld	de, 8
	call	clear_dst_1920
	.globl	t8_duff_pre
t8_duff_pre:
	ld	hl, src_buf
	ld	de, dst_buf
	ld	bc, 10
	jr	.Lt8_entry
.Lt8_ldi:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
.Lt8_entry:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	jp	pe, .Lt8_ldi
	.globl	t8_duff_done
t8_duff_done:
	nop
	ld	de, 8
	ld	bc, 10
	call	verify

	; ========================================
	; Test 9: 16x LDI Duff — 1920 bytes, n_mod=16 (edge case)
	; Should be identical to n_mod=0 (enter at top).
	; ========================================
	ld	de, 9
	call	clear_dst_1920
	.globl	t9_duff16_pre
t9_duff16_pre:
	ld	hl, src_buf
	ld	de, dst_buf
	ld	bc, 1920
	; n_mod=16 → (16-16)%16 = 0 → enter at top, same as test 2
.Lt9_ldi:
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	ldi
	jp	pe, .Lt9_ldi
	.globl	t9_duff16_done
t9_duff16_done:
	nop
	ld	de, 9
	ld	bc, 1920
	call	verify

	; All tests passed: DE = 0
	ld	de, 0
	.globl	_halt
_halt:
	halt

; ========================================
; verify — compare src_buf with dst_buf for BC bytes
;   DE = test number (preserved for error report)
;   BC = byte count to compare
;   On match: returns normally
;   On mismatch: halts with DE=test#, HL=offset
; ========================================
verify:
	push	de		; save test number
	ld	hl, src_buf
	ld	de, dst_buf
.Lv_loop:
	ld	a, (de)
	cp	(hl)
	jr	nz, .Lv_fail
	inc	hl
	inc	de
	dec	bc
	ld	a, b
	or	c
	jr	nz, .Lv_loop
	; passed
	pop	de
	ret
.Lv_fail:
	; HL = address of mismatch in src_buf
	; compute offset = HL - src_buf
	push	de		; save test # (again, for stack)
	ld	de, src_buf
	ld	a, l
	sub	e
	ld	l, a
	ld	a, h
	sbc	a, d
	ld	h, a		; HL = offset
	pop	de		; DE = test number
	pop	af		; clean stack (discard saved DE)
	jr	_halt		; halt with DE=test#, HL=offset

; ========================================
; clear_dst_1920 — fill dst_buf with 0xFF (distinct from any src pattern)
;   Clobbers: HL, DE, BC, A
; ========================================
clear_dst_1920:
	ld	hl, dst_buf
	ld	(hl), 0xFF
	ld	d, h
	ld	e, l
	inc	de
	ld	bc, 1919
	ldir
	ret

	; ========================================
	; Buffers in BSS
	; ========================================
	.section .bss,"aw",@nobits
src_buf:
	.space	1920
dst_buf:
	.space	1920
