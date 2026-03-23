; runtime.s — Minimal Z80 runtime stubs for freestanding PROM build
;
; Provides memcpy, memset, and __call_iy (indirect call via IY).

	.text

; void *memcpy(void *dest, const void *src, size_t n)
; sdcccall(1): dest=HL, src=DE, n=stack (2 bytes)
; Callee cleanup: pop n before returning.
; Returns dest in DE.
	.globl	_memcpy
_memcpy:
	pop	iy		; save return address in IY
	pop	bc		; n (callee-cleanup the stack arg)
	; HL=dest, DE=src, BC=n
	ex	de, hl		; DE=dest, HL=src
	ld	a, b
	or	c
	jr	z, .Lmemcpy_done
	ldir
.Lmemcpy_done:
	; return dest in DE (already there)
	jp	(iy)		; return via IY (stack is clean)

; void *memset(void *s, int c, size_t n)
; sdcccall(1): s=HL, c=E (truncated to byte), n=stack (2 bytes)
; Callee cleanup: pop n before returning.
	.globl	_memset
_memset:
	pop	iy		; save return address in IY
	pop	bc		; n (callee-cleanup the stack arg)
	; HL=s, E=c (fill byte), BC=n
	ld	a, b
	or	c
	jr	z, .Lmemset_done
	ld	(hl), e		; store first byte
	dec	bc
	ld	a, b
	or	c
	jr	z, .Lmemset_done
	ld	d, h
	ld	e, l
	inc	de		; DE = s+1
	ldir			; fill rest
.Lmemset_done:
	jp	(iy)		; return via IY (stack is clean)

; __call_iy — indirect function call via IY register
; Used by the compiler for calls through function pointers.
; IY holds the target address; JP (IY) transfers control.
	.globl	__call_iy
__call_iy:
	jp	(iy)
