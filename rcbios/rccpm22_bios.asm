; z80dasm 1.2.0
; command line: z80dasm -a -l -g 0xDA00 -S syms_56k_z80dasm.sym -b blocks_56k.def -o rccpm22_bios.asm rccpm22_bios.bin

	org 0da00h
biosdata_end:	equ 0xf800

BOOT:

; BLOCK 'jumptable' (start 0xda00 end 0xda33)
jumptable_start:
	jp BOOT_ENTRY		;da00
WBOOT:
	jp WBOOT_ENTRY		;da03
CONST:
	jp CONST_ENTRY		;da06
CONIN:
	jp CONIN_ENTRY		;da09
CONOUT:
	jp CONOUT_ENTRY		;da0c
LIST:
	jp LIST_ENTRY		;da0f
PUNCH:
	jp PUNCH_ENTRY		;da12
READER:
	jp READER_ENTRY		;da15
HOME:
	jp HOME_ENTRY		;da18
SELDSK:
	jp displaycode_end	;da1b
SETTRK:
	jp SETTRK_ENTRY		;da1e
SETSEC:
	jp SETSEC_ENTRY		;da21
SETDMA:
	jp SETDMA_ENTRY		;da24
READ:
	jp READ_ENTRY		;da27
WRITE:
	jp WRITE_ENTRY		;da2a
LISTST:
	jp bootcode_end		;da2d
SECTRAN:
	jp SECTRAN_ENTRY	;da30
jumptable_end:
ADRMOD:

; BLOCK 'config' (start 0xda33 end 0xda4a)
config_start:
	defb 000h		;da33
WR5A:
	defb 020h		;da34
WR5B:
	defb 020h		;da35
MTYPE:
	defb 000h		;da36
lda37h:
	defb 010h		;da37
	defb 010h		;da38
FD0:
	defb 020h		;da39
	defb 0ffh		;da3a
	defb 0ffh		;da3b
	defb 0ffh		;da3c
	defb 0ffh		;da3d
	defb 0ffh		;da3e
	defb 0ffh		;da3f
	defb 0ffh		;da40
	defb 0ffh		;da41
	defb 0ffh		;da42
	defb 0ffh		;da43
	defb 0ffh		;da44
	defb 0ffh		;da45
	defb 0ffh		;da46
BOOTD:
	defb 000h		;da47
	defb 000h		;da48
	defb 000h		;da49
config_end:
JWFITR:

; BLOCK 'extvec' (start 0xda4a end 0xda5c)
extvec_start:
	jp WFITR_ENTRY		;da4a
JREADS:
	jp READS_ENTRY		;da4d
JLINSEL:
	jp LINSEL		;da50
JPEXIT:
	jp EXIT			;da53
JPCLOCK:
	jp CLOCK		;da56
JHRDFMT:
	jp HRDFMT_ENTRY		;da59
extvec_end:

; BLOCK 'pad1' (start 0xda5c end 0xda71)
pad1_start:
	defb 000h		;da5c
	defb 000h		;da5d
	defb 000h		;da5e
	defb 000h		;da5f
	defb 000h		;da60
	defb 000h		;da61
	defb 000h		;da62
	defb 000h		;da63
	defb 000h		;da64
	defb 000h		;da65
	defb 000h		;da66
	defb 000h		;da67
	defb 000h		;da68
	defb 000h		;da69
	defb 000h		;da6a
	defb 000h		;da6b
	defb 000h		;da6c
	defb 000h		;da6d
	defb 000h		;da6e
lda6fh:
	defb 000h		;da6f
	defb 000h		;da70
pad1_end:
MSG_DISKERR:

; BLOCK 'messages' (start 0xda71 end 0xdae1)
messages_start:
	defb 00dh		;da71
	defb 00ah		;da72
	defb 044h		;da73
	defb 069h		;da74
	defb 073h		;da75
	defb 06bh		;da76
	defb 020h		;da77
	defb 072h		;da78
	defb 065h		;da79
	defb 061h		;da7a
	defb 064h		;da7b
	defb 020h		;da7c
	defb 065h		;da7d
	defb 072h		;da7e
	defb 072h		;da7f
	defb 06fh		;da80
	defb 072h		;da81
	defb 020h		;da82
	defb 02dh		;da83
	defb 020h		;da84
	defb 072h		;da85
	defb 065h		;da86
	defb 073h		;da87
	defb 065h		;da88
	defb 074h		;da89
	defb 00dh		;da8a
	defb 00ah		;da8b
	defb 000h		;da8c
lda8dh:
	defb 00ch		;da8d
SIGNON:
	defb 052h		;da8e
	defb 043h		;da8f
	defb 037h		;da90
	defb 030h		;da91
	defb 030h		;da92
	defb 020h		;da93
	defb 020h		;da94
	defb 020h		;da95
	defb 035h		;da96
	defb 036h		;da97
	defb 06bh		;da98
	defb 020h		;da99
	defb 043h		;da9a
	defb 050h		;da9b
	defb 02fh		;da9c
	defb 04dh		;da9d
	defb 020h		;da9e
	defb 076h		;da9f
	defb 065h		;daa0
	defb 072h		;daa1
	defb 073h		;daa2
	defb 02eh		;daa3
	defb 032h		;daa4
	defb 02eh		;daa5
	defb 032h		;daa6
	defb 020h		;daa7
	defb 020h		;daa8
	defb 020h		;daa9
	defb 072h		;daaa
	defb 065h		;daab
	defb 06ch		;daac
	defb 02eh		;daad
	defb 032h		;daae
	defb 02eh		;daaf
	defb 031h		;dab0
	defb 00dh		;dab1
	defb 00ah		;dab2
	defb 000h		;dab3
	defb 00ch		;dab4
MSG_WAITING:
	defb 057h		;dab5
	defb 061h		;dab6
	defb 069h		;dab7
	defb 074h		;dab8
	defb 069h		;dab9
	defb 06eh		;daba
	defb 067h		;dabb
	defb 000h		;dabc
	defb 00ch		;dabd
MSG_CONFIGERR:
	defb 043h		;dabe
	defb 061h		;dabf
	defb 06eh		;dac0
	defb 06eh		;dac1
	defb 06fh		;dac2
	defb 074h		;dac3
	defb 020h		;dac4
	defb 072h		;dac5
	defb 065h		;dac6
	defb 061h		;dac7
	defb 064h		;dac8
	defb 020h		;dac9
	defb 063h		;daca
	defb 06fh		;dacb
	defb 06eh		;dacc
	defb 066h		;dacd
	defb 069h		;dace
	defb 067h		;dacf
	defb 075h		;dad0
	defb 072h		;dad1
	defb 061h		;dad2
	defb 074h		;dad3
	defb 069h		;dad4
	defb 06fh		;dad5
	defb 06eh		;dad6
	defb 020h		;dad7
	defb 072h		;dad8
	defb 065h		;dad9
	defb 063h		;dada
	defb 06fh		;dadb
	defb 072h		;dadc
	defb 064h		;dadd
	defb 00dh		;dade
	defb 00ah		;dadf
	defb 000h		;dae0
messages_end:

; BLOCK 'bootcode' (start 0xdae1 end 0xdc8d)
bootcode_start:
	ld a,(hl)		;dae1
	or a			;dae2
	ret z			;dae3
	push hl			;dae4
	ld c,a			;dae5
	call CONOUT_ENTRY	;dae6
	pop hl			;dae9
	inc hl			;daea
	jp messages_end		;daeb
ldaeeh:
	ld hl,pad1_end		;daee
	call messages_end	;daf1
ldaf4h:
	jp ldaf4h		;daf4
EXIT:
	ld a,0c3h		;daf7
	ld (0ffe5h),a		;daf9
	ld (0ffe6h),hl		;dafc
	ex de,hl		;daff
	ld (0ffdfh),hl		;db00
	ret			;db03
CLOCK:
	di			;db04
	or a			;db05
	jp z,ldb12h		;db06
	ld de,(0fffch)		;db09
	ld hl,(0fffeh)		;db0d
	ei			;db10
	ret			;db11
ldb12h:
	ld (0fffch),de		;db12
	ld (0fffeh),hl		;db16
	ret			;db19
LINSEL:
	add a,00ah		;db1a
	ld c,a			;db1c
ldb1dh:
	di			;db1d
	ld a,001h		;db1e
	out (c),a		;db20
	in a,(c)		;db22
	ei			;db24
	and 001h		;db25
	jr z,ldb1dh		;db27
	ld d,005h		;db29
	ld a,000h		;db2b
	call sub_db57h		;db2d
	dec b			;db30
	ret m			;db31
	sla b			;db32
	or b			;db34
	call sub_db57h		;db35
	or 080h			;db38
	call sub_db57h		;db3a
	ld hl,00002h		;db3d
	call sub_e64ch		;db40
	ld a,c			;db43
	cp 00ah			;db44
	ld a,(ldc89h)		;db46
	jp z,ldb4fh		;db49
	ld a,(ldc8bh)		;db4c
ldb4fh:
	and 020h		;db4f
	jp z,sub_db57h		;db51
	ld a,0ffh		;db54
	ret			;db56
sub_db57h:
	di			;db57
	out (c),d		;db58
	out (c),a		;db5a
	ei			;db5c
	ret			;db5d
sub_db5eh:
	xor a			;db5e
	ld (0d84ch),a		;db5f
	ld hl,(0d89ah)		;db62
	ld (lda6fh),hl		;db65
	ld hl,ldb6fh		;db68
	ld (0d89ah),hl		;db6b
	ret			;db6e
ldb6fh:
	push hl			;db6f
	ld hl,(lda6fh)		;db70
	ld (0d89ah),hl		;db73
	pop hl			;db76
	ret			;db77
BOOT_ENTRY:
	ld sp,00080h		;db78
	ld hl,lda8dh		;db7b
	call messages_end	;db7e
	xor a			;db81
	ld (00004h),a		;db82
	ld (lf350h),a		;db85
	ld a,(BOOTD)		;db88
	or a			;db8b
	jp z,ldb94h		;db8c
	ld a,002h		;db8f
	ld (00004h),a		;db91
ldb94h:
	xor a			;db94
	ld (lf321h),a		;db95
	ld (lf32ah),a		;db98
	ld (lf322h),a		;db9b
	in a,(014h)		;db9e
	and 080h		;dba0
	jp z,WBOOT_ENTRY	;dba2
	ld a,(lf334h)		;dba5
	cp 002h			;dba8
	jp nc,ldbbeh		;dbaa
	ld c,001h		;dbad
	call displaycode_end	;dbaf
	call HOME_ENTRY		;dbb2
	ld a,b			;dbb5
	and 010h		;dbb6
	ld a,000h		;dbb8
	jp nz,ldbbeh		;dbba
	inc a			;dbbd
ldbbeh:
	ld (lf334h),a		;dbbe
WBOOT_ENTRY:
	ei			;dbc1
	ld c,000h		;dbc2
	ld a,(BOOTD)		;dbc4
	or a			;dbc7
	jr z,ldbcdh		;dbc8
	ld a,002h		;dbca
	ld c,a			;dbcc
ldbcdh:
	call displaycode_end	;dbcd
	xor a			;dbd0
	ld (lf323h),a		;dbd1
	ld (00003h),a		;dbd4
	ld (lf339h),a		;dbd7
	ld (0ec26h),a		;dbda
	call HOME_ENTRY		;dbdd
	ld sp,00080h		;dbe0
	ld bc,0c400h		;dbe3
	call SETDMA_ENTRY	;dbe6
	ld bc,00001h		;dbe9
	call SETTRK_ENTRY	;dbec
	ld bc,00000h		;dbef
	call SETSEC_ENTRY	;dbf2
ldbf5h:
	push bc			;dbf5
	call READ_ENTRY		;dbf6
	or a			;dbf9
	jp nz,ldaeeh		;dbfa
	ld hl,(lf32eh)		;dbfd
	ld de,00080h		;dc00
	add hl,de		;dc03
	ld b,h			;dc04
	ld c,l			;dc05
	call SETDMA_ENTRY	;dc06
	pop bc			;dc09
	inc bc			;dc0a
	call SETSEC_ENTRY	;dc0b
	ld a,c			;dc0e
	cp 02ch			;dc0f
	jp nz,ldbf5h		;dc11
	ld bc,00080h		;dc14
	call SETDMA_ENTRY	;dc17
	ld a,0c3h		;dc1a
	ld (00000h),a		;dc1c
	ld hl,WBOOT		;dc1f
	ld (00001h),hl		;dc22
	ld (00005h),a		;dc25
	ld hl,0cc06h		;dc28
	ld (00006h),hl		;dc2b
	ld a,(00004h)		;dc2e
	and 00fh		;dc31
	ld c,a			;dc33
	ld a,(BOOTD)		;dc34
	cp c			;dc37
	jr z,ldc56h		;dc38
	call displaycode_end	;dc3a
	ld a,h			;dc3d
	or l			;dc3e
	jr z,ldc50h		;dc3f
	ld bc,00002h		;dc41
	call SETTRK_ENTRY	;dc44
	call SETSEC_ENTRY	;dc47
	call READ_ENTRY		;dc4a
	or a			;dc4d
	jr z,ldc56h		;dc4e
ldc50h:
	ld a,(BOOTD)		;dc50
	ld (00004h),a		;dc53
ldc56h:
	ld a,(00004h)		;dc56
	and 00fh		;dc59
	ld c,a			;dc5b
	cp 002h			;dc5c
	call nc,sub_db5eh	;dc5e
	call displaycode_end	;dc61
	ld a,(00004h)		;dc64
	ld c,a			;dc67
	ld hl,lf350h		;dc68
	ld a,(hl)		;dc6b
	ld (hl),001h		;dc6c
	or a			;dc6e
	jr z,ldc81h		;dc6f
	ld a,(0c407h)		;dc71
	or a			;dc74
	jr z,ldc81h		;dc75
	ld hl,0c409h		;dc77
	add a,l			;dc7a
	ld l,a			;dc7b
	ld a,(hl)		;dc7c
	or a			;dc7d
	jp z,0c403h		;dc7e
ldc81h:
	jp 0c400h		;dc81
ldc84h:
	rst 38h			;dc84
ldc85h:
	rst 38h			;dc85
ldc86h:
	rst 38h			;dc86
ldc87h:
	nop			;dc87
ldc88h:
	nop			;dc88
ldc89h:
	inc l			;dc89
ldc8ah:
	nop			;dc8a
ldc8bh:
	inc l			;dc8b
ldc8ch:
	nop			;dc8c
bootcode_end:
STLIST_ENTRY:

; BLOCK 'siocode' (start 0xdc8d end 0xde00)
siocode_start:
	ld a,(ldc84h)		;dc8d
	ret			;dc90
LIST_ENTRY:
	ld a,(ldc84h)		;dc91
	or a			;dc94
	jp z,LIST_ENTRY		;dc95
	di			;dc98
	ld a,000h		;dc99
	ld (ldc84h),a		;dc9b
	ld a,005h		;dc9e
	out (00bh),a		;dca0
	ld a,(WR5B)		;dca2
	add a,08ah		;dca5
	out (00bh),a		;dca7
	ld a,001h		;dca9
	out (00bh),a		;dcab
	ld a,007h		;dcad
	out (00bh),a		;dcaf
	ld a,c			;dcb1
	out (009h),a		;dcb2
	ei			;dcb4
	ret			;dcb5
sub_dcb6h:
	di			;dcb6
	xor a			;dcb7
	ld (ldc85h),a		;dcb8
	ld a,005h		;dcbb
	out (00ah),a		;dcbd
	ld a,(WR5A)		;dcbf
	add a,08ah		;dcc2
	out (00ah),a		;dcc4
	ld a,001h		;dcc6
	out (00ah),a		;dcc8
	ld a,01bh		;dcca
	out (00ah),a		;dccc
	ei			;dcce
	ret			;dccf
READS_ENTRY:
	ld a,(ldc85h)		;dcd0
	ret			;dcd3
READER_ENTRY:
	call READS_ENTRY	;dcd4
	or a			;dcd7
	jp z,READER_ENTRY	;dcd8
	ld a,(ldc87h)		;dcdb
	push af			;dcde
	call sub_dcb6h		;dcdf
	pop af			;dce2
	ret			;dce3
PUNCH_ENTRY:
	ld a,(ldc86h)		;dce4
	or a			;dce7
	jp z,PUNCH_ENTRY	;dce8
	di			;dceb
	ld a,000h		;dcec
	ld (ldc86h),a		;dcee
	ld a,005h		;dcf1
	out (00ah),a		;dcf3
	ld a,(WR5A)		;dcf5
	add a,08ah		;dcf8
	out (00ah),a		;dcfa
	ld a,001h		;dcfc
	out (00ah),a		;dcfe
	ld a,01bh		;dd00
	out (00ah),a		;dd02
	ld a,c			;dd04
	out (008h),a		;dd05
	ei			;dd07
	ret			;dd08
	ld (lf34bh),sp		;dd09
	ld sp,lf620h		;dd0d
	push af			;dd10
	ld a,028h		;dd11
	out (00bh),a		;dd13
	ld a,0ffh		;dd15
	ld (ldc84h),a		;dd17
	pop af			;dd1a
	ld sp,(lf34bh)		;dd1b
	ei			;dd1f
	reti			;dd20
	ld (lf34bh),sp		;dd22
	ld sp,lf620h		;dd26
	push af			;dd29
	in a,(00bh)		;dd2a
	ld (ldc8bh),a		;dd2c
	ld a,010h		;dd2f
	out (00bh),a		;dd31
	pop af			;dd33
	ld sp,(lf34bh)		;dd34
	ei			;dd38
	reti			;dd39
	ld (lf34bh),sp		;dd3b
	ld sp,lf620h		;dd3f
	push af			;dd42
	in a,(008h)		;dd43
	ld (ldc88h),a		;dd45
	pop af			;dd48
	ld sp,(lf34bh)		;dd49
	ei			;dd4d
	reti			;dd4e
	ld (lf34bh),sp		;dd50
	ld sp,lf620h		;dd54
	push af			;dd57
	ld a,001h		;dd58
	out (00bh),a		;dd5a
	in a,(00bh)		;dd5c
	ld (ldc8ch),a		;dd5e
	ld a,030h		;dd61
	out (00bh),a		;dd63
	pop af			;dd65
	ld sp,(lf34bh)		;dd66
	ei			;dd6a
	reti			;dd6b
	ld (lf34bh),sp		;dd6d
	ld sp,lf620h		;dd71
	push af			;dd74
	ld a,028h		;dd75
	out (00ah),a		;dd77
	ld a,0ffh		;dd79
	ld (ldc86h),a		;dd7b
	pop af			;dd7e
	ld sp,(lf34bh)		;dd7f
	ei			;dd83
	reti			;dd84
	ld (lf34bh),sp		;dd86
	ld sp,lf620h		;dd8a
	push af			;dd8d
	in a,(00ah)		;dd8e
	ld (ldc89h),a		;dd90
	ld a,010h		;dd93
	out (00ah),a		;dd95
	pop af			;dd97
	ld sp,(lf34bh)		;dd98
	ei			;dd9c
	reti			;dd9d
	ld (lf34bh),sp		;dd9f
	ld sp,lf620h		;dda3
	push af			;dda6
	in a,(008h)		;dda7
	ld (ldc87h),a		;dda9
	ld a,0ffh		;ddac
	ld (ldc85h),a		;ddae
	pop af			;ddb1
	ld sp,(lf34bh)		;ddb2
	ei			;ddb6
	reti			;ddb7
	ld (lf34bh),sp		;ddb9
	ld sp,lf620h		;ddbd
	push af			;ddc0
	ld a,001h		;ddc1
	out (00ah),a		;ddc3
	in a,(00ah)		;ddc5
	ld (ldc8ah),a		;ddc7
	ld a,030h		;ddca
	out (00ah),a		;ddcc
	ld a,000h		;ddce
	ld (ldc87h),a		;ddd0
	ld a,0ffh		;ddd3
	ld (ldc85h),a		;ddd5
	pop af			;ddd8
	ld sp,(lf34bh)		;ddd9
	ei			;dddd
	reti			;ddde
ldde0h:
	nop			;dde0
ldde1h:
	nop			;dde1
	nop			;dde2
sub_dde3h:
	ld a,h			;dde3
	cpl			;dde4
	ld h,a			;dde5
	ld a,l			;dde6
	cpl			;dde7
	ld l,a			;dde8
	ret			;dde9
sub_ddeah:
	call sub_dde3h		;ddea
	inc hl			;dded
	ret			;ddee
sub_ddefh:
	ld hl,(0ffd2h)		;ddef
	ld a,l			;ddf2
	cp 080h			;ddf3
	ret nz			;ddf5
	ld a,h			;ddf6
	cp 007h			;ddf7
	ret			;ddf9
sub_ddfah:
	ld a,(ldde0h)		;ddfa
	or a			;ddfd
	ld a,c			;ddfe
	ret nz			;ddff
siocode_end:

; BLOCK 'displaycode' (start 0xde00 end 0xe2cd)
displaycode_start:
	ld b,000h		;de00
	add hl,bc		;de02
	ld a,(hl)		;de03
	ret			;de04
lde05h:
	push af			;de05
	ld a,080h		;de06
	out (001h),a		;de08
	ld a,(0ffd1h)		;de0a
	out (000h),a		;de0d
	ld a,(0ffd4h)		;de0f
	out (000h),a		;de12
	pop af			;de14
	ret			;de15
lde16h:
	ld hl,(0ffd2h)		;de16
	ld de,00050h		;de19
	add hl,de		;de1c
	ld (0ffd2h),hl		;de1d
	ld hl,0ffd4h		;de20
	inc (hl)		;de23
	jp lde05h		;de24
lde27h:
	ld hl,(0ffd2h)		;de27
	ld de,0ffb0h		;de2a
	add hl,de		;de2d
	ld (0ffd2h),hl		;de2e
	ld hl,0ffd4h		;de31
	dec (hl)		;de34
	jp lde05h		;de35
sub_de38h:
	ld hl,00000h		;de38
	ld (0ffd2h),hl		;de3b
	xor a			;de3e
	ld (0ffd1h),a		;de3f
	ld (0ffd4h),a		;de42
	ret			;de45
lde46h:
	cp b			;de46
	ret c			;de47
	sub b			;de48
	jp lde46h		;de49
lde4ch:
	ld hl,(0ffd5h)		;de4c
	ld d,h			;de4f
	ld e,l			;de50
	inc de			;de51
	ld bc,0004fh		;de52
	ld (hl),020h		;de55
	ldir			;de57
	ld a,(0ffdbh)		;de59
	cp 000h			;de5c
	ret z			;de5e
	ld hl,(0ffdch)		;de5f
	ld d,h			;de62
	ld e,l			;de63
	inc de			;de64
	ld bc,00009h		;de65
	ld (hl),000h		;de68
	ldir			;de6a
	ret			;de6c
lde6dh:
	ld hl,0f850h		;de6d
	ld de,biosdata_end	;de70
	ld bc,00780h		;de73
	ldir			;de76
	ld hl,0ff80h		;de78
	ld (0ffd5h),hl		;de7b
	ld a,(0ffdbh)		;de7e
	cp 000h			;de81
	jp z,lde4ch		;de83
	ld hl,lf50ah		;de86
	ld de,lf500h		;de89
	ld bc,000f0h		;de8c
	ldir			;de8f
	ld hl,lf5f0h		;de91
	ld (0ffdch),hl		;de94
	jp lde4ch		;de97
sub_de9ah:
	ld a,000h		;de9a
	ld b,003h		;de9c
lde9eh:
	srl h			;de9e
	rr l			;dea0
	rra			;dea2
	dec b			;dea3
	jp nz,lde9eh		;dea4
	cp 000h			;dea7
	ret z			;dea9
	ld b,005h		;deaa
ldeach:
	rra			;deac
	dec b			;dead
	jp nz,ldeach		;deae
	ret			;deb1
sub_deb2h:
	ld de,lf500h		;deb2
	add hl,de		;deb5
	cp 000h			;deb6
	ld b,a			;deb8
	ld a,000h		;deb9
	jp nz,ldec1h		;debb
	and (hl)		;debe
	ld (hl),a		;debf
	ret			;dec0
ldec1h:
	scf			;dec1
	rla			;dec2
	dec b			;dec3
	jp nz,ldec1h		;dec4
	and (hl)		;dec7
	ld (hl),a		;dec8
	ret			;dec9
ldecah:
	ld a,000h		;deca
	cp c			;decc
	jp z,lded3h		;decd
lded0h:
	ldir			;ded0
	ret			;ded2
lded3h:
	cp b			;ded3
	jp nz,lded0h		;ded4
	ret			;ded7
sub_ded8h:
	ld a,000h		;ded8
	cp c			;deda
	jp z,ldee1h		;dedb
ldedeh:
	lddr			;dede
	ret			;dee0
ldee1h:
	cp b			;dee1
	jp nz,ldedeh		;dee2
	ret			;dee5
	out (01ch),a		;dee6
	ret			;dee8
	call sub_de38h		;dee9
	ld a,002h		;deec
	ld (0ffd7h),a		;deee
	ret			;def1
	ret			;def2
	ld a,000h		;def3
	ld (0ffd1h),a		;def5
	jp lde05h		;def8
	ld hl,0ffcfh		;defb
	ld de,0ffceh		;defe
	ld bc,007cfh		;df01
	ld (hl),020h		;df04
	lddr			;df06
	call sub_de38h		;df08
	call lde05h		;df0b
	ld a,(0ffdbh)		;df0e
	cp 000h			;df11
	ret z			;df13
	xor a			;df14
	ld (0ffdbh),a		;df15
	ld hl,lf5f9h		;df18
	ld de,lf5f8h		;df1b
	ld bc,000f9h		;df1e
	ld (hl),000h		;df21
	lddr			;df23
	ret			;df25
	ld de,biosdata_end	;df26
	ld hl,(0ffd2h)		;df29
	add hl,de		;df2c
	ld de,0004fh		;df2d
	add hl,de		;df30
	ld d,h			;df31
	ld e,l			;df32
	dec de			;df33
	ld bc,00000h		;df34
	ld a,(0ffd1h)		;df37
	cpl			;df3a
	inc a			;df3b
	add a,04fh		;df3c
	ld c,a			;df3e
	ld (hl),020h		;df3f
	call sub_ded8h		;df41
	ld a,(0ffdbh)		;df44
	cp 000h			;df47
	ret z			;df49
	ld hl,(0ffd2h)		;df4a
	ld d,000h		;df4d
	ld a,(0ffd1h)		;df4f
	ld e,a			;df52
	add hl,de		;df53
	call sub_de9ah		;df54
	call sub_deb2h		;df57
	ld a,(0ffd1h)		;df5a
	srl a			;df5d
	srl a			;df5f
	srl a			;df61
	cpl			;df63
	add a,009h		;df64
	ret m			;df66
	ld c,a			;df67
	ld b,000h		;df68
	inc hl			;df6a
	ld d,h			;df6b
	ld e,l			;df6c
	inc de			;df6d
	ld a,000h		;df6e
	jp ldecah		;df70
	ld hl,(0ffd2h)		;df73
	ld a,(0ffd1h)		;df76
	ld c,a			;df79
	ld b,000h		;df7a
	add hl,bc		;df7c
	call sub_ddeah		;df7d
	ld de,007cfh		;df80
	add hl,de		;df83
	ld b,h			;df84
	ld c,l			;df85
	ld hl,0ffcfh		;df86
	ld de,0ffceh		;df89
	ld (hl),020h		;df8c
	call sub_ded8h		;df8e
	ld a,(0ffdbh)		;df91
	cp 000h			;df94
	ret z			;df96
	ld hl,(0ffd2h)		;df97
	ld d,000h		;df9a
	ld a,(0ffd1h)		;df9c
	ld e,a			;df9f
	add hl,de		;dfa0
	call sub_de9ah		;dfa1
	call sub_deb2h		;dfa4
	call sub_dde3h		;dfa7
	ld de,lf5f9h		;dfaa
	add hl,de		;dfad
	ld a,080h		;dfae
	and h			;dfb0
	ret nz			;dfb1
	ld b,h			;dfb2
	ld c,l			;dfb3
	ld h,d			;dfb4
	ld l,e			;dfb5
	dec de			;dfb6
	ld (hl),000h		;dfb7
	jp sub_ded8h		;dfb9
	ld a,(0ffd1h)		;dfbc
	cp 000h			;dfbf
	jp z,ldfcbh		;dfc1
	dec a			;dfc4
	ld (0ffd1h),a		;dfc5
	jp lde05h		;dfc8
ldfcbh:
	ld a,04fh		;dfcb
	ld (0ffd1h),a		;dfcd
	ld hl,(0ffd2h)		;dfd0
	ld a,l			;dfd3
	or h			;dfd4
	jp nz,lde27h		;dfd5
	ld hl,00780h		;dfd8
	ld (0ffd2h),hl		;dfdb
	ld a,018h		;dfde
	ld (0ffd4h),a		;dfe0
	jp lde05h		;dfe3
sub_dfe6h:
	ld a,(0ffd1h)		;dfe6
	cp 04fh			;dfe9
	jp z,ldff5h		;dfeb
	inc a			;dfee
	ld (0ffd1h),a		;dfef
	jp lde05h		;dff2
ldff5h:
	ld a,000h		;dff5
	ld (0ffd1h),a		;dff7
	call sub_ddefh		;dffa
	jp nz,lde16h		;dffd
	call lde05h		;e000
	jp lde6dh		;e003
	call sub_dfe6h		;e006
	call sub_dfe6h		;e009
	call sub_dfe6h		;e00c
	jp sub_dfe6h		;e00f
	call sub_ddefh		;e012
	jp nz,lde16h		;e015
	jp lde6dh		;e018
	ld hl,(0ffd2h)		;e01b
	ld a,l			;e01e
	or h			;e01f
	jp nz,lde27h		;e020
	ld hl,00780h		;e023
	ld (0ffd2h),hl		;e026
	ld a,018h		;e029
	ld (0ffd4h),a		;e02b
	jp lde05h		;e02e
	call sub_de38h		;e031
	jp lde05h		;e034
	ld hl,(0ffd2h)		;e037
	ld b,h			;e03a
	ld c,l			;e03b
	ld de,0f850h		;e03c
	add hl,de		;e03f
	ld (ldde1h),hl		;e040
	ld de,0ffb0h		;e043
	add hl,de		;e046
	ex de,hl		;e047
	ld h,b			;e048
	ld l,c			;e049
	call sub_ddeah		;e04a
	ld bc,00780h		;e04d
	add hl,bc		;e050
	ld b,h			;e051
	ld c,l			;e052
	ld hl,(ldde1h)		;e053
	call ldecah		;e056
	ld hl,0ff80h		;e059
	ld (0ffd5h),hl		;e05c
	ld a,(0ffdbh)		;e05f
	cp 000h			;e062
	jp z,lde4ch		;e064
	ld hl,(0ffd2h)		;e067
	call sub_de9ah		;e06a
	ld b,h			;e06d
	ld c,l			;e06e
	ld de,lf50ah		;e06f
	add hl,de		;e072
	ld (ldde1h),hl		;e073
	ld de,0fff6h		;e076
	add hl,de		;e079
	ex de,hl		;e07a
	ld h,b			;e07b
	ld l,c			;e07c
	call sub_ddeah		;e07d
	ld bc,000f0h		;e080
	add hl,bc		;e083
	ld b,h			;e084
	ld c,l			;e085
	ld hl,(ldde1h)		;e086
	call ldecah		;e089
	ld hl,lf5f0h		;e08c
	ld (0ffdch),hl		;e08f
	jp lde4ch		;e092
	ld hl,(0ffd2h)		;e095
	ld de,biosdata_end	;e098
	add hl,de		;e09b
	ld (0ffd5h),hl		;e09c
	call sub_ddeah		;e09f
	ld de,0ff80h		;e0a2
	add hl,de		;e0a5
	ld b,h			;e0a6
	ld c,l			;e0a7
	ld hl,0ff7fh		;e0a8
	ld de,0ffcfh		;e0ab
	call sub_ded8h		;e0ae
	ld a,(0ffdbh)		;e0b1
	cp 000h			;e0b4
	jp z,lde4ch		;e0b6
	ld hl,(0ffd2h)		;e0b9
	call sub_de9ah		;e0bc
	ld de,lf500h		;e0bf
	add hl,de		;e0c2
	ld (0ffdch),hl		;e0c3
	call sub_ddeah		;e0c6
	ld de,lf5f0h		;e0c9
	add hl,de		;e0cc
	ld b,h			;e0cd
	ld c,l			;e0ce
	ld hl,lf5efh		;e0cf
	ld de,lf5f9h		;e0d2
	call sub_ded8h		;e0d5
	jp lde4ch		;e0d8
	ld a,002h		;e0db
	ld (0ffdbh),a		;e0dd
	ret			;e0e0
	ld a,001h		;e0e1
	ld (0ffdbh),a		;e0e3
	ret			;e0e6
	ld hl,biosdata_end	;e0e7
	ld de,lf500h		;e0ea
	ld b,0fah		;e0ed
le0efh:
	ld a,(de)		;e0ef
	ld c,008h		;e0f0
	cp 000h			;e0f2
	jp nz,le101h		;e0f4
le0f7h:
	ld (hl),020h		;e0f7
	inc hl			;e0f9
	dec c			;e0fa
	jp nz,le0f7h		;e0fb
	jp le10ch		;e0fe
le101h:
	rra			;e101
	jp c,le107h		;e102
	ld (hl),020h		;e105
le107h:
	inc hl			;e107
	dec c			;e108
	jp nz,le101h		;e109
le10ch:
	inc de			;e10c
	dec b			;e10d
	jp nz,le0efh		;e10e
	ret			;e111
le112h:
	jp p,095deh		;e112
	ret po			;e115
	scf			;e116
	ret po			;e117
	jp p,lf2deh		;e118
	sbc a,0bch		;e11b
	rst 18h			;e11d
	jp (hl)			;e11e
	sbc a,0e6h		;e11f
	sbc a,0bch		;e121
	rst 18h			;e123
	ld b,0e0h		;e124
	ld (de),a		;e126
	ret po			;e127
	jp p,0fbdeh		;e128
	sbc a,0f3h		;e12b
	sbc a,0f2h		;e12d
	sbc a,0f2h		;e12f
	sbc a,0f2h		;e131
	sbc a,0f2h		;e133
	sbc a,0f2h		;e135
	sbc a,0f2h		;e137
	sbc a,0dbh		;e139
	ret po			;e13b
	pop hl			;e13c
	ret po			;e13d
	rst 20h			;e13e
	ret po			;e13f
	jp p,le6deh		;e140
	rst 18h			;e143
	jp p,01bdeh		;e144
	ret po			;e147
	jp p,lf2deh		;e148
	sbc a,031h		;e14b
	ret po			;e14d
	ld h,0dfh		;e14e
	ld (hl),e		;e150
	rst 18h			;e151
sub_e152h:
	ld a,000h		;e152
	ld (0ffd7h),a		;e154
	ld a,(0ffdah)		;e157
	rlca			;e15a
	and 03eh		;e15b
	ld c,a			;e15d
	ld b,000h		;e15e
	ld hl,le112h		;e160
	add hl,bc		;e163
	ld e,(hl)		;e164
	inc hl			;e165
	ld d,(hl)		;e166
	ex de,hl		;e167
	jp (hl)			;e168
sub_e169h:
	ld a,(0ffdah)		;e169
	and 07fh		;e16c
	sub 020h		;e16e
	ld hl,0ffd7h		;e170
	dec (hl)		;e173
	jp z,le17bh		;e174
	ld (0ffdeh),a		;e177
	ret			;e17a
le17bh:
	ld d,a			;e17b
	ld a,(0ffdeh)		;e17c
	ld h,a			;e17f
	ld a,(jumptable_end)	;e180
	or a			;e183
	jp z,le188h		;e184
	ex de,hl		;e187
le188h:
	ld a,h			;e188
	ld b,050h		;e189
	call lde46h		;e18b
	ld (0ffd1h),a		;e18e
	ld a,d			;e191
	ld b,019h		;e192
	call lde46h		;e194
	ld (0ffd4h),a		;e197
	or a			;e19a
	jp z,lde05h		;e19b
	ld hl,(0ffd2h)		;e19e
	ld de,00050h		;e1a1
le1a4h:
	add hl,de		;e1a4
	dec a			;e1a5
	jp nz,le1a4h		;e1a6
	ld (0ffd2h),hl		;e1a9
	jp lde05h		;e1ac
sub_e1afh:
	ld hl,(0ffd2h)		;e1af
	ld d,000h		;e1b2
	ld a,(0ffd1h)		;e1b4
	ld e,a			;e1b7
	add hl,de		;e1b8
	ld (0ffd8h),hl		;e1b9
	ld a,(0ffdah)		;e1bc
	cp 0c0h			;e1bf
	jp c,le1c6h		;e1c1
	sub 0c0h		;e1c4
le1c6h:
	ld c,a			;e1c6
	cp 080h			;e1c7
	jp c,le1d5h		;e1c9
	and 004h		;e1cc
	ld (ldde0h),a		;e1ce
	ld a,c			;e1d1
	jp le1dbh		;e1d2
le1d5h:
	ld hl,lf680h		;e1d5
	call sub_ddfah		;e1d8
le1dbh:
	ld hl,(0ffd8h)		;e1db
	ld de,biosdata_end	;e1de
	add hl,de		;e1e1
	ld (hl),a		;e1e2
	call sub_dfe6h		;e1e3
	ld a,(0ffdbh)		;e1e6
	cp 002h			;e1e9
	ret nz			;e1eb
	ld hl,(0ffd8h)		;e1ec
	call sub_de9ah		;e1ef
	ld de,lf500h		;e1f2
	add hl,de		;e1f5
	cp 000h			;e1f6
	ld b,a			;e1f8
	ld a,001h		;e1f9
	jp nz,le201h		;e1fb
	or (hl)			;e1fe
	ld (hl),a		;e1ff
	ret			;e200
le201h:
	rlca			;e201
	dec b			;e202
	jp nz,le201h		;e203
	or (hl)			;e206
	ld (hl),a		;e207
	ret			;e208
CONOUT_ENTRY:
	di			;e209
	push hl			;e20a
	ld hl,00000h		;e20b
	add hl,sp		;e20e
	ld sp,lf680h		;e20f
	ei			;e212
	push hl			;e213
	push af			;e214
	push bc			;e215
	push de			;e216
	ld a,c			;e217
	ld (0ffdah),a		;e218
	ld a,(0ffd7h)		;e21b
	or a			;e21e
	jp z,le228h		;e21f
	call sub_e169h		;e222
	jp le239h		;e225
le228h:
	ld a,(0ffdah)		;e228
	cp 020h			;e22b
	jp nc,le236h		;e22d
	call sub_e152h		;e230
	jp le239h		;e233
le236h:
	call sub_e1afh		;e236
le239h:
	pop de			;e239
	pop bc			;e23a
	pop af			;e23b
	pop hl			;e23c
	di			;e23d
	ld sp,hl		;e23e
	pop hl			;e23f
	ei			;e240
	ret			;e241
DSPITR:
	ld (lf34bh),sp		;e242
	ld sp,lf620h		;e246
	push af			;e249
	push bc			;e24a
	push de			;e24b
	push hl			;e24c
	in a,(001h)		;e24d
	ld a,006h		;e24f
	out (0fah),a		;e251
	ld a,007h		;e253
	out (0fah),a		;e255
	out (0fch),a		;e257
	ld hl,biosdata_end	;e259
	ld a,l			;e25c
	out (0f4h),a		;e25d
	ld a,h			;e25f
	out (0f4h),a		;e260
	ld hl,007cfh		;e262
	ld a,l			;e265
	out (0f5h),a		;e266
	ld a,h			;e268
	out (0f5h),a		;e269
	ld a,000h		;e26b
	out (0f7h),a		;e26d
	out (0f7h),a		;e26f
	ld a,002h		;e271
	out (0fah),a		;e273
	ld a,003h		;e275
	out (0fah),a		;e277
	ld a,0d7h		;e279
	out (00eh),a		;e27b
	ld a,001h		;e27d
	out (00eh),a		;e27f
	ld hl,0fffch		;e281
	inc (hl)		;e284
	jp nz,le294h		;e285
	inc hl			;e288
	inc (hl)		;e289
	jp nz,le294h		;e28a
	inc hl			;e28d
	inc (hl)		;e28e
	jp nz,le294h		;e28f
	inc hl			;e292
	inc (hl)		;e293
le294h:
	ld hl,(0ffdfh)		;e294
	ld a,l			;e297
	or h			;e298
	jp z,le2a5h		;e299
	dec hl			;e29c
	ld a,l			;e29d
	or h			;e29e
	ld (0ffdfh),hl		;e29f
	call z,0ffe5h		;e2a2
le2a5h:
	ld hl,(0ffe1h)		;e2a5
	ld a,l			;e2a8
	or h			;e2a9
	jp z,le2b6h		;e2aa
	dec hl			;e2ad
	ld a,l			;e2ae
	or h			;e2af
	ld (0ffe1h),hl		;e2b0
	call z,sub_e642h	;e2b3
le2b6h:
	ld hl,(0ffe3h)		;e2b6
	ld a,l			;e2b9
	or h			;e2ba
	jp z,le2c2h		;e2bb
	dec hl			;e2be
	ld (0ffe3h),hl		;e2bf
le2c2h:
	pop hl			;e2c2
	pop de			;e2c3
	pop bc			;e2c4
	pop af			;e2c5
	ld sp,(lf34bh)		;e2c6
	ei			;e2ca
	reti			;e2cb
displaycode_end:
SELDSK_ENTRY:

; BLOCK 'diskcode' (start 0xe2cd end 0xebe8)
diskcode_start:
	ld hl,00000h		;e2cd
	add hl,sp		;e2d0
	ld sp,lf680h		;e2d1
	push hl			;e2d4
	ld hl,00000h		;e2d5
	ld a,(lf334h)		;e2d8
	cp c			;e2db
	jp c,le364h		;e2dc
	ld a,c			;e2df
	ld (lf312h),a		;e2e0
	ld bc,00010h		;e2e3
	ld de,lda37h		;e2e6
	ld hl,00000h		;e2e9
le2ech:
	or a			;e2ec
	jp z,le2f6h		;e2ed
	inc de			;e2f0
	add hl,bc		;e2f1
	dec a			;e2f2
	jp le2ech		;e2f3
le2f6h:
	ld c,l			;e2f6
	ld b,h			;e2f7
	ex de,hl		;e2f8
	ld a,(hl)		;e2f9
	ld hl,lf332h		;e2fa
	cp (hl)			;e2fd
	jp z,le310h		;e2fe
	push af			;e301
	push bc			;e302
	ld a,(lf322h)		;e303
	or a			;e306
	call nz,sub_e50eh	;e307
	xor a			;e30a
	ld (lf322h),a		;e30b
	pop bc			;e30e
	pop af			;e30f
le310h:
	ld (lf332h),a		;e310
	call sub_e369h		;e313
	ld (lf330h),hl		;e316
	inc hl			;e319
	inc hl			;e31a
	inc hl			;e31b
	inc hl			;e31c
	ld a,(hl)		;e31d
	ld (lf333h),a		;e31e
	push bc			;e321
	ld a,(lf332h)		;e322
	and 0f8h		;e325
	or a			;e327
	rla			;e328
	ld e,a			;e329
	ld d,000h		;e32a
	ld hl,leaa0h		;e32c
	add hl,de		;e32f
	ld de,lf351h		;e330
	ld bc,00010h		;e333
	ldir			;e336
	ld hl,(lf351h)		;e338
	ld bc,0000dh		;e33b
	add hl,bc		;e33e
	ex de,hl		;e33f
	ld hl,lea90h		;e340
	ld b,000h		;e343
	ld a,(lf312h)		;e345
	ld c,a			;e348
	add hl,bc		;e349
	add hl,bc		;e34a
	ld bc,00002h		;e34b
	ldir			;e34e
	pop bc			;e350
	ld hl,leb78h		;e351
	add hl,bc		;e354
	ex de,hl		;e355
	ld hl,0000ah		;e356
	add hl,de		;e359
	ex de,hl		;e35a
	ld a,(lf351h)		;e35b
	ld (de),a		;e35e
	inc de			;e35f
	ld a,(lf352h)		;e360
	ld (de),a		;e363
le364h:
	ex de,hl		;e364
	pop hl			;e365
	ld sp,hl		;e366
	ex de,hl		;e367
	ret			;e368
sub_e369h:
	ld hl,0eb31h		;e369
	ld a,(lf332h)		;e36c
	and 0f8h		;e36f
	ld e,a			;e371
	ld d,000h		;e372
	add hl,de		;e374
	ret			;e375
SETTRK_ENTRY:
	ld h,b			;e376
	ld l,c			;e377
	ld (lf313h),hl		;e378
	ret			;e37b
SETSEC_ENTRY:
	ld l,c			;e37c
	ld h,b			;e37d
	ld (lf315h),hl		;e37e
	ret			;e381
SETDMA_ENTRY:
	ld h,b			;e382
	ld l,c			;e383
	ld (lf32eh),hl		;e384
	ret			;e387
SECTRAN_ENTRY:
	ld h,b			;e388
	ld l,c			;e389
	ret			;e38a
READ_ENTRY:
	xor a			;e38b
	ld (lf323h),a		;e38c
	ld a,001h		;e38f
	ld (lf32ch),a		;e391
	ld (lf32bh),a		;e394
	ld a,002h		;e397
	ld (lf32dh),a		;e399
	jp le43ah		;e39c
WRITE_ENTRY:
	xor a			;e39f
	ld (lf32ch),a		;e3a0
	ld a,c			;e3a3
	ld (lf32dh),a		;e3a4
	cp 002h			;e3a7
	jp nz,le3c4h		;e3a9
	ld a,(lf353h)		;e3ac
	ld (lf323h),a		;e3af
	ld a,(lf312h)		;e3b2
	ld (lf324h),a		;e3b5
	ld hl,(lf313h)		;e3b8
	ld (lf325h),hl		;e3bb
	ld hl,(lf315h)		;e3be
	ld (lf327h),hl		;e3c1
le3c4h:
	ld a,(lf323h)		;e3c4
	or a			;e3c7
	jp z,le430h		;e3c8
	dec a			;e3cb
	ld (lf323h),a		;e3cc
	ld a,(lf312h)		;e3cf
	ld hl,lf324h		;e3d2
	cp (hl)			;e3d5
	jp nz,le430h		;e3d6
	ld hl,lf325h		;e3d9
	call sub_e502h		;e3dc
	jp nz,le430h		;e3df
	ld a,(lf315h)		;e3e2
	ld hl,lf327h		;e3e5
	cp (hl)			;e3e8
	jp nz,le430h		;e3e9
	ld a,(lf316h)		;e3ec
	inc hl			;e3ef
	cp (hl)			;e3f0
	jp nz,le430h		;e3f1
	ld hl,(lf327h)		;e3f4
	inc hl			;e3f7
	ld (lf327h),hl		;e3f8
	ex de,hl		;e3fb
	ld hl,lf354h		;e3fc
	push bc			;e3ff
	ld c,(hl)		;e400
	inc hl			;e401
	ld b,(hl)		;e402
	ex de,hl		;e403
	and a			;e404
	sbc hl,bc		;e405
	pop bc			;e407
	jp c,le418h		;e408
	ld hl,00000h		;e40b
	ld (lf327h),hl		;e40e
	ld hl,(lf325h)		;e411
	inc hl			;e414
	ld (lf325h),hl		;e415
le418h:
	xor a			;e418
	ld (lf32bh),a		;e419
	ld a,(lf315h)		;e41c
	ld hl,lf356h		;e41f
	and (hl)		;e422
	cp (hl)			;e423
	ld a,000h		;e424
	jp nz,le42ah		;e426
	inc a			;e429
le42ah:
	ld (lf329h),a		;e42a
	jp le43ah		;e42d
le430h:
	xor a			;e430
	ld (lf323h),a		;e431
	ld a,(lf356h)		;e434
	ld (lf32bh),a		;e437
le43ah:
	ld hl,00000h		;e43a
	add hl,sp		;e43d
	ld sp,lf680h		;e43e
	push hl			;e441
	ld a,(lf357h)		;e442
	ld b,a			;e445
	ld hl,(lf315h)		;e446
le449h:
	dec b			;e449
	jp z,le454h		;e44a
	srl h			;e44d
	rr l			;e44f
	jp le449h		;e451
le454h:
	ld (lf31fh),hl		;e454
	ld hl,lf321h		;e457
	ld a,(hl)		;e45a
	ld (hl),001h		;e45b
	or a			;e45d
	jp z,le48dh		;e45e
	ld a,(lf312h)		;e461
	ld hl,lf317h		;e464
	cp (hl)			;e467
	jp nz,le486h		;e468
	ld hl,lf318h		;e46b
	call sub_e502h		;e46e
	jp nz,le486h		;e471
	ld a,(lf31fh)		;e474
	ld hl,lf31ah		;e477
	cp (hl)			;e47a
	jp nz,le486h		;e47b
	ld a,(lf320h)		;e47e
	inc hl			;e481
	cp (hl)			;e482
	jp z,le4aah		;e483
le486h:
	ld a,(lf322h)		;e486
	or a			;e489
	call nz,sub_e50eh	;e48a
le48dh:
	ld a,(lf312h)		;e48d
	ld (lf317h),a		;e490
	ld hl,(lf313h)		;e493
	ld (lf318h),hl		;e496
	ld hl,(lf31fh)		;e499
	ld (lf31ah),hl		;e49c
	ld a,(lf32bh)		;e49f
	or a			;e4a2
	call nz,sub_e51bh	;e4a3
	xor a			;e4a6
	ld (lf322h),a		;e4a7
le4aah:
	ld a,(lf315h)		;e4aa
	ld hl,lf356h		;e4ad
	and (hl)		;e4b0
	ld l,a			;e4b1
	ld h,000h		;e4b2
	add hl,hl		;e4b4
	add hl,hl		;e4b5
	add hl,hl		;e4b6
	add hl,hl		;e4b7
	add hl,hl		;e4b8
	add hl,hl		;e4b9
	add hl,hl		;e4ba
	ld de,lee81h		;e4bb
	add hl,de		;e4be
	ex de,hl		;e4bf
	ld hl,(lf32eh)		;e4c0
	ld bc,00080h		;e4c3
	ex de,hl		;e4c6
	ld a,(lf32ch)		;e4c7
	or a			;e4ca
	jp nz,le4d4h		;e4cb
	ld a,001h		;e4ce
	ld (lf322h),a		;e4d0
	ex de,hl		;e4d3
le4d4h:
	ldir			;e4d4
	ld a,(lf32dh)		;e4d6
	cp 001h			;e4d9
	ld hl,lf32ah		;e4db
	ld a,(hl)		;e4de
	push af			;e4df
	or a			;e4e0
	jp z,le4e8h		;e4e1
	xor a			;e4e4
	ld (lf321h),a		;e4e5
le4e8h:
	pop af			;e4e8
	ld (hl),000h		;e4e9
	jp nz,le4ffh		;e4eb
	or a			;e4ee
	jp nz,le4ffh		;e4ef
	xor a			;e4f2
	ld (lf322h),a		;e4f3
	call sub_e50eh		;e4f6
	ld hl,lf32ah		;e4f9
	ld a,(hl)		;e4fc
	ld (hl),000h		;e4fd
le4ffh:
	pop hl			;e4ff
	ld sp,hl		;e500
	ret			;e501
sub_e502h:
	ex de,hl		;e502
	ld hl,lf313h		;e503
	ld a,(de)		;e506
	cp (hl)			;e507
	ret nz			;e508
	inc de			;e509
	inc hl			;e50a
	ld a,(de)		;e50b
	cp (hl)			;e50c
	ret			;e50d
sub_e50eh:
	ld a,(lf35bh)		;e50e
	or a			;e511
	jp nz,le805h		;e512
	call sub_e532h		;e515
	jp le5fah		;e518
sub_e51bh:
	ld a,(lf329h)		;e51b
	or a			;e51e
	jp nz,le525h		;e51f
	ld (lf323h),a		;e522
le525h:
	ld a,(lf35bh)		;e525
	or a			;e528
	jp nz,le820h		;e529
	call sub_e532h		;e52c
	jp le5b0h		;e52f
sub_e532h:
	ld a,(lf31ah)		;e532
	ld c,a			;e535
	ld a,(lf333h)		;e536
	ld b,a			;e539
	dec a			;e53a
	cp c			;e53b
	ld a,(lf317h)		;e53c
	jp nc,le54dh		;e53f
	or 004h			;e542
	ld (lf339h),a		;e544
	ld a,c			;e547
	sub b			;e548
	ld c,a			;e549
	jp le550h		;e54a
le54dh:
	ld (lf339h),a		;e54d
le550h:
	ld b,000h		;e550
	ld hl,(lf358h)		;e552
	add hl,bc		;e555
	ld a,(hl)		;e556
	ld (lf33dh),a		;e557
	ld a,(lf318h)		;e55a
	ld (lf33ch),a		;e55d
	ld hl,lee81h		;e560
	ld (lf33ah),hl		;e563
	ld a,(lf317h)		;e566
	ld hl,lf31ch		;e569
	cp (hl)			;e56c
	jp nz,le580h		;e56d
	ld a,(lf318h)		;e570
	ld hl,lf31dh		;e573
	cp (hl)			;e576
	jp nz,le580h		;e577
	ld a,(lf319h)		;e57a
	inc hl			;e57d
	cp (hl)			;e57e
	ret z			;e57f
le580h:
	ld a,(lf317h)		;e580
	ld (lf31ch),a		;e583
	ld hl,(lf318h)		;e586
	ld (lf31dh),hl		;e589
	call sub_e73eh		;e58c
	call sub_e708h		;e58f
	call WFITR_ENTRY	;e592
	ld a,(lf339h)		;e595
	and 003h		;e598
	add a,020h		;e59a
	cp b			;e59c
	ret z			;e59d
sub_e59eh:
	call sub_e73eh		;e59e
	call sub_e6bfh		;e5a1
	push bc			;e5a4
	call WFITR_ENTRY	;e5a5
	call sub_e708h		;e5a8
	call WFITR_ENTRY	;e5ab
	pop bc			;e5ae
	ret			;e5af
le5b0h:
	ld a,00ah		;e5b0
	ld (lf33eh),a		;e5b2
le5b5h:
	call sub_e624h		;e5b5
	call sub_e73eh		;e5b8
	ld hl,(lf330h)		;e5bb
	ld c,(hl)		;e5be
	inc hl			;e5bf
	ld b,(hl)		;e5c0
	inc hl			;e5c1
	call sub_e77dh		;e5c2
	call sub_e61ah		;e5c5
	call sub_e754h		;e5c8
	ld c,000h		;e5cb
le5cdh:
	ld hl,lf33fh		;e5cd
	ld a,(hl)		;e5d0
	and 0f8h		;e5d1
	ret z			;e5d3
	and 008h		;e5d4
	jp nz,le5f0h		;e5d6
	ld a,(lf33eh)		;e5d9
	dec a			;e5dc
	ld (lf33eh),a		;e5dd
	jp z,le5f0h		;e5e0
	cp 005h			;e5e3
	call z,sub_e59eh	;e5e5
	xor a			;e5e8
	cp c			;e5e9
	jp z,le5b5h		;e5ea
	jp le5ffh		;e5ed
le5f0h:
	ld a,c			;e5f0
	ld (lf321h),a		;e5f1
	ld a,001h		;e5f4
	ld (lf32ah),a		;e5f6
	ret			;e5f9
le5fah:
	ld a,00ah		;e5fa
	ld (lf33eh),a		;e5fc
le5ffh:
	call sub_e624h		;e5ff
	call sub_e73eh		;e602
	ld hl,(lf330h)		;e605
	ld c,(hl)		;e608
	inc hl			;e609
	ld b,(hl)		;e60a
	inc hl			;e60b
	call sub_e75ch		;e60c
	call sub_e61fh		;e60f
	call sub_e754h		;e612
	ld c,001h		;e615
	jp le5cdh		;e617
sub_e61ah:
	ld a,006h		;e61a
	jp le787h		;e61c
sub_e61fh:
	ld a,005h		;e61f
	jp le787h		;e621
sub_e624h:
	in a,(014h)		;e624
	and 080h		;e626
	ret z			;e628
	di			;e629
	ld hl,(0ffe1h)		;e62a
	ld a,l			;e62d
	or h			;e62e
	ld hl,(0ffe7h)		;e62f
	ld (0ffe1h),hl		;e632
	ei			;e635
	ret nz			;e636
	ld a,001h		;e637
	out (014h),a		;e639
	ld hl,00032h		;e63b
	call sub_e64ch		;e63e
	ret			;e641
sub_e642h:
	in a,(014h)		;e642
	and 080h		;e644
	ret z			;e646
	ld a,000h		;e647
	out (014h),a		;e649
	ret			;e64b
sub_e64ch:
	ld (0ffe3h),hl		;e64c
le64fh:
	ld hl,(0ffe3h)		;e64f
	ld a,l			;e652
	or h			;e653
	jp nz,le64fh		;e654
	ret			;e657
HOME_ENTRY:
	ld a,(lf322h)		;e658
	or a			;e65b
	jr nz,le661h		;e65c
	ld (lf321h),a		;e65e
le661h:
	ld a,(lf35bh)		;e661
	and a			;e664
	jp z,le68eh		;e665
	ld a,(lf312h)		;e668
	ld (lf31ch),a		;e66b
	ld hl,(lf351h)		;e66e
	ld de,0000dh		;e671
	add hl,de		;e674
	ld e,(hl)		;e675
	inc hl			;e676
	ld d,(hl)		;e677
	ld (lf31dh),de		;e678
	call sub_e880h		;e67c
	call sub_e8e3h		;e67f
	ret nc			;e682
	call sub_e8f5h		;e683
le686h:
	in a,(067h)		;e686
	and 010h		;e688
	jp z,le686h		;e68a
	ret			;e68d
le68eh:
	call sub_e624h		;e68e
	ld a,(lf312h)		;e691
	ld (lf339h),a		;e694
	ld (lf31ch),a		;e697
	xor a			;e69a
	ld (lf31dh),a		;e69b
	ld (lf31eh),a		;e69e
	call sub_e73eh		;e6a1
	call sub_e6bfh		;e6a4
	call WFITR_ENTRY	;e6a7
	ret			;e6aa
le6abh:
	in a,(004h)		;e6ab
	and 0c0h		;e6ad
	cp 080h			;e6af
	jp nz,le6abh		;e6b1
	ret			;e6b4
le6b5h:
	in a,(004h)		;e6b5
	and 0c0h		;e6b7
	cp 0c0h			;e6b9
	jp nz,le6b5h		;e6bb
	ret			;e6be
sub_e6bfh:
	call le6abh		;e6bf
	ld a,007h		;e6c2
	out (005h),a		;e6c4
	call le6abh		;e6c6
	ld a,(lf339h)		;e6c9
	and 003h		;e6cc
	out (005h),a		;e6ce
	ret			;e6d0
	call le6abh		;e6d1
	ld a,004h		;e6d4
	out (005h),a		;e6d6
	call le6abh		;e6d8
	ld a,(lf339h)		;e6db
le6deh:
	and 003h		;e6de
	out (005h),a		;e6e0
	call le6b5h		;e6e2
	in a,(005h)		;e6e5
	ld (lf33fh),a		;e6e7
	ret			;e6ea
sub_e6ebh:
	call le6abh		;e6eb
	ld a,008h		;e6ee
	out (005h),a		;e6f0
	call le6b5h		;e6f2
	in a,(005h)		;e6f5
	ld (lf33fh),a		;e6f7
	and 0c0h		;e6fa
	cp 080h			;e6fc
	ret z			;e6fe
	call le6b5h		;e6ff
	in a,(005h)		;e702
	ld (lf340h),a		;e704
	ret			;e707
sub_e708h:
	call le6abh		;e708
	ld a,00fh		;e70b
	out (005h),a		;e70d
	call le6abh		;e70f
	ld a,(lf339h)		;e712
	and 003h		;e715
	out (005h),a		;e717
	call le6abh		;e719
	ld a,(lf33ch)		;e71c
	out (005h),a		;e71f
	ret			;e721
sub_e722h:
	ld hl,lf33fh		;e722
	ld d,007h		;e725
le727h:
	call le6b5h		;e727
	in a,(005h)		;e72a
	ld (hl),a		;e72c
	inc hl			;e72d
	ld a,004h		;e72e
le730h:
	dec a			;e730
	jp nz,le730h		;e731
	in a,(004h)		;e734
	and 010h		;e736
	ret z			;e738
	dec d			;e739
	jp nz,le727h		;e73a
	ret			;e73d
sub_e73eh:
	di			;e73e
	xor a			;e73f
	ld (lf34fh),a		;e740
	ei			;e743
	ret			;e744
WFITR_ENTRY:
	call sub_e754h		;e745
	ld a,(lf33fh)		;e748
	ld b,a			;e74b
	ld a,(lf340h)		;e74c
	ld c,a			;e74f
	call sub_e73eh		;e750
	ret			;e753
sub_e754h:
	ld a,(lf34fh)		;e754
	or a			;e757
	jp z,sub_e754h		;e758
	ret			;e75b
sub_e75ch:
	ld a,005h		;e75c
	di			;e75e
	out (0fah),a		;e75f
	ld a,049h		;e761
le763h:
	out (0fbh),a		;e763
	out (0fch),a		;e765
	ld a,(lf33ah)		;e767
	out (0f2h),a		;e76a
	ld a,(lf33bh)		;e76c
	out (0f2h),a		;e76f
	ld a,c			;e771
	out (0f3h),a		;e772
	ld a,b			;e774
	out (0f3h),a		;e775
	ld a,001h		;e777
	out (0fah),a		;e779
	ei			;e77b
	ret			;e77c
sub_e77dh:
	ld a,005h		;e77d
	di			;e77f
	out (0fah),a		;e780
	ld a,045h		;e782
	jp le763h		;e784
le787h:
	push af			;e787
	di			;e788
	call le6abh		;e789
	pop af			;e78c
	ld b,(hl)		;e78d
	inc hl			;e78e
	add a,b			;e78f
	out (005h),a		;e790
	call le6abh		;e792
	ld a,(lf339h)		;e795
	out (005h),a		;e798
	call le6abh		;e79a
	ld a,(lf33ch)		;e79d
	out (005h),a		;e7a0
	call le6abh		;e7a2
	ld a,(lf339h)		;e7a5
	rra			;e7a8
	rra			;e7a9
	and 003h		;e7aa
	out (005h),a		;e7ac
	call le6abh		;e7ae
	ld a,(lf33dh)		;e7b1
	out (005h),a		;e7b4
	call le6abh		;e7b6
	ld a,(hl)		;e7b9
	inc hl			;e7ba
	out (005h),a		;e7bb
	call le6abh		;e7bd
	ld a,(hl)		;e7c0
	inc hl			;e7c1
	out (005h),a		;e7c2
	call le6abh		;e7c4
	ld a,(hl)		;e7c7
	out (005h),a		;e7c8
	call le6abh		;e7ca
	ld a,(lf35ah)		;e7cd
	out (005h),a		;e7d0
	ei			;e7d2
	ret			;e7d3
FLITR:
	ld (lf34bh),sp		;e7d4
	ld sp,lf620h		;e7d8
	push af			;e7db
	push bc			;e7dc
	push de			;e7dd
	push hl			;e7de
	ld a,0ffh		;e7df
	ld (lf34fh),a		;e7e1
	ld a,005h		;e7e4
le7e6h:
	dec a			;e7e6
	jp nz,le7e6h		;e7e7
	in a,(004h)		;e7ea
	and 010h		;e7ec
	jp nz,le7f7h		;e7ee
	call sub_e6ebh		;e7f1
	jp le7fah		;e7f4
le7f7h:
	call sub_e722h		;e7f7
le7fah:
	pop hl			;e7fa
	pop de			;e7fb
	pop bc			;e7fc
	pop af			;e7fd
	ld sp,(lf34bh)		;e7fe
	ei			;e802
	reti			;e803
le805h:
	call sub_e83bh		;e805
	call nc,sub_e880h	;e808
	call sub_e901h		;e80b
	ret nc			;e80e
	ld hl,(lf330h)		;e80f
	ld c,(hl)		;e812
	inc hl			;e813
	ld b,(hl)		;e814
	call sub_e920h		;e815
	ld a,030h		;e818
	out (067h),a		;e81a
	call sub_e8f5h		;e81c
	ret			;e81f
le820h:
	call sub_e83bh		;e820
	call nc,sub_e880h	;e823
	call sub_e901h		;e826
	ret nc			;e829
	ld hl,(lf330h)		;e82a
	ld c,(hl)		;e82d
	inc hl			;e82e
	ld b,(hl)		;e82f
	call sub_e916h		;e830
	ld a,028h		;e833
	out (067h),a		;e835
	call sub_e8f5h		;e837
	ret			;e83a
sub_e83bh:
	ld hl,lee81h		;e83b
	ld (lf33ah),hl		;e83e
	ld a,(lf317h)		;e841
	ld hl,lf31ch		;e844
	cp (hl)			;e847
	jp nz,le85fh		;e848
	ld a,(lf318h)		;e84b
	ld hl,lf31dh		;e84e
	cp (hl)			;e851
	jp nz,le85fh		;e852
	ld a,(lf319h)		;e855
	inc hl			;e858
	cp (hl)			;e859
	jp nz,le85fh		;e85a
	and a			;e85d
	ret			;e85e
le85fh:
	ld a,(lf317h)		;e85f
	ld (lf31ch),a		;e862
	ld hl,(lf318h)		;e865
	ld (lf31dh),hl		;e868
	call sub_e880h		;e86b
	call sub_e8e3h		;e86e
	jp nc,le87eh		;e871
	call sub_e8f5h		;e874
le877h:
	in a,(067h)		;e877
	and 010h		;e879
	jp z,le877h		;e87b
le87eh:
	scf			;e87e
	ret			;e87f
sub_e880h:
	ld hl,(lf330h)		;e880
	ld de,0ffffh		;e883
	ex de,hl		;e886
	add hl,de		;e887
	xor a			;e888
	ld c,(hl)		;e889
	ld b,000h		;e88a
	ld hl,(lf31ah)		;e88c
le88fh:
	and a			;e88f
	sbc hl,bc		;e890
	jp c,le899h		;e892
	inc a			;e895
	jp le88fh		;e896
le899h:
	add hl,bc		;e899
	push af			;e89a
	ld a,l			;e89b
	out (063h),a		;e89c
	ld a,(lf31ch)		;e89e
	ld c,000h		;e8a1
	ld hl,lf335h		;e8a3
	sub (hl)		;e8a6
	ld hl,lf336h		;e8a7
	cp (hl)			;e8aa
	jp c,le8c1h		;e8ab
	sub (hl)		;e8ae
	inc c			;e8af
	ld hl,lf337h		;e8b0
	cp (hl)			;e8b3
	jp c,le8c1h		;e8b4
	sub (hl)		;e8b7
	inc c			;e8b8
	ld hl,lf338h		;e8b9
	cp (hl)			;e8bc
	jp c,le8c1h		;e8bd
	inc c			;e8c0
le8c1h:
	sla c			;e8c1
	sla c			;e8c3
	sla c			;e8c5
	pop af			;e8c7
	or c			;e8c8
	ld hl,00005h		;e8c9
	add hl,de		;e8cc
	or (hl)			;e8cd
	out (066h),a		;e8ce
	ld hl,(lf31dh)		;e8d0
	ld a,l			;e8d3
	out (064h),a		;e8d4
	ld a,h			;e8d6
	and 003h		;e8d7
	out (065h),a		;e8d9
	ld hl,00006h		;e8db
	add hl,de		;e8de
	ld a,(hl)		;e8df
	out (061h),a		;e8e0
	ret			;e8e2
sub_e8e3h:
	ld hl,(lf330h)		;e8e3
	ld de,00005h		;e8e6
	add hl,de		;e8e9
	ld a,070h		;e8ea
	or (hl)			;e8ec
	call sub_e901h		;e8ed
	ret nc			;e8f0
	out (067h),a		;e8f1
	scf			;e8f3
	ret			;e8f4
sub_e8f5h:
	ld a,(lf34dh)		;e8f5
	or a			;e8f8
	jp z,sub_e8f5h		;e8f9
	xor a			;e8fc
	ld (lf34dh),a		;e8fd
	ret			;e900
sub_e901h:
	push af			;e901
	in a,(067h)		;e902
	and 050h		;e904
	cp 050h			;e906
	jp z,le913h		;e908
	ld a,0bbh		;e90b
	ld (lf32ah),a		;e90d
	pop af			;e910
	and a			;e911
	ret			;e912
le913h:
	pop af			;e913
	scf			;e914
	ret			;e915
sub_e916h:
	ld a,004h		;e916
	di			;e918
	out (0fah),a		;e919
	ld a,044h		;e91b
	jp le927h		;e91d
sub_e920h:
	ld a,004h		;e920
	di			;e922
	out (0fah),a		;e923
	ld a,048h		;e925
le927h:
	out (0fbh),a		;e927
	out (0fch),a		;e929
	ld a,(lf33ah)		;e92b
	out (0f0h),a		;e92e
	ld a,(lf33bh)		;e930
	out (0f0h),a		;e933
	ld a,c			;e935
	out (0f1h),a		;e936
	ld a,b			;e938
	out (0f1h),a		;e939
	ld a,000h		;e93b
	out (0fah),a		;e93d
	ei			;e93f
	ret			;e940
	out (066h),a		;e941
	xor a			;e943
	out (061h),a		;e944
	out (062h),a		;e946
	out (063h),a		;e948
	out (064h),a		;e94a
	out (065h),a		;e94c
	ld a,010h		;e94e
	or b			;e950
	out (067h),a		;e951
	ret			;e953
HRDFMT_ENTRY:
	out (066h),a		;e954
	ld a,b			;e956
	out (061h),a		;e957
	ld a,c			;e959
	out (062h),a		;e95a
	ld a,e			;e95c
	out (064h),a		;e95d
	ld a,d			;e95f
	out (065h),a		;e960
	ld hl,(lf32eh)		;e962
	ld (lf33ah),hl		;e965
	call sub_e901h		;e968
	jp nc,le980h		;e96b
	ld bc,001ffh		;e96e
	call sub_e920h		;e971
	ld a,050h		;e974
	out (067h),a		;e976
	call sub_e8f5h		;e978
	ld a,(lf32ah)		;e97b
	and a			;e97e
	ret z			;e97f
le980h:
	xor a			;e980
	ld (lf32ah),a		;e981
	ld a,001h		;e984
	ret			;e986
HDITR:
	ld (lf34bh),sp		;e987
	ld sp,lf620h		;e98b
	push af			;e98e
	push bc			;e98f
	push de			;e990
	push hl			;e991
	ld a,0ffh		;e992
	ld (lf34dh),a		;e994
	in a,(067h)		;e997
	ld (lf347h),a		;e999
	and 001h		;e99c
	jp z,le9b2h		;e99e
	in a,(061h)		;e9a1
	ld (lf348h),a		;e9a3
	ld hl,(lf349h)		;e9a6
	inc hl			;e9a9
	ld (lf349h),hl		;e9aa
	ld a,0bbh		;e9ad
	ld (lf32ah),a		;e9af
le9b2h:
	pop hl			;e9b2
	pop de			;e9b3
	pop bc			;e9b4
	pop af			;e9b5
	ld sp,(lf34bh)		;e9b6
	ei			;e9ba
	reti			;e9bb
	ld bc,00d07h		;e9bd
	inc de			;e9c0
	add hl,de		;e9c1
	dec b			;e9c2
	dec bc			;e9c3
	ld de,00317h		;e9c4
	add hl,bc		;e9c7
	rrca			;e9c8
	dec d			;e9c9
	ld (bc),a		;e9ca
	ex af,af'		;e9cb
	ld c,014h		;e9cc
	ld a,(de)		;e9ce
	ld b,00ch		;e9cf
	ld (de),a		;e9d1
	jr $+6			;e9d2
	ld a,(bc)		;e9d4
	djnz le9edh		;e9d5
	ld bc,00905h		;e9d7
	dec c			;e9da
	ld (bc),a		;e9db
	ld b,00ah		;e9dc
	ld c,003h		;e9de
	rlca			;e9e0
	dec bc			;e9e1
	rrca			;e9e2
	inc b			;e9e3
	ex af,af'		;e9e4
	inc c			;e9e5
	ld bc,00503h		;e9e6
	rlca			;e9e9
	add hl,bc		;e9ea
	ld (bc),a		;e9eb
	inc b			;e9ec
le9edh:
	ld b,008h		;e9ed
le9efh:
	ld bc,00302h		;e9ef
	inc b			;e9f2
	dec b			;e9f3
	ld b,007h		;e9f4
	ex af,af'		;e9f6
	add hl,bc		;e9f7
	ld a,(bc)		;e9f8
	dec bc			;e9f9
	inc c			;e9fa
	dec c			;e9fb
	ld c,00fh		;e9fc
	djnz lea11h		;e9fe
	ld (de),a		;ea00
	inc de			;ea01
	inc d			;ea02
	dec d			;ea03
	ld d,017h		;ea04
	jr lea21h		;ea06
	ld a,(de)		;ea08
	jr nz,lea0bh		;ea09
lea0bh:
	inc bc			;ea0b
	rlca			;ea0c
	nop			;ea0d
	sub b			;ea0e
	nop			;ea0f
	ccf			;ea10
lea11h:
	nop			;ea11
	ret nz			;ea12
	nop			;ea13
	djnz lea16h		;ea14
lea16h:
	nop			;ea16
	nop			;ea17
	ld b,b			;ea18
	nop			;ea19
	inc b			;ea1a
	rrca			;ea1b
	ld bc,00090h		;ea1c
	ld a,a			;ea1f
	nop			;ea20
lea21h:
	ret nz			;ea21
	nop			;ea22
	jr nz,lea25h		;ea23
lea25h:
	nop			;ea25
	nop			;ea26
	ld c,b			;ea27
	nop			;ea28
	inc b			;ea29
	rrca			;ea2a
	ld bc,00086h		;ea2b
	ld a,a			;ea2e
	nop			;ea2f
	ret nz			;ea30
	nop			;ea31
	jr nz,lea34h		;ea32
lea34h:
	ld (bc),a		;ea34
	nop			;ea35
	ld a,b			;ea36
	nop			;ea37
	inc b			;ea38
	rrca			;ea39
	nop			;ea3a
	rst 10h			;ea3b
	ld bc,0007fh		;ea3c
	ret nz			;ea3f
	nop			;ea40
	jr nz,lea43h		;ea41
lea43h:
	ld (bc),a		;ea43
	nop			;ea44
	add a,b			;ea45
	ld bc,00f04h		;ea46
	nop			;ea49
	pop bc			;ea4a
	ld bc,0007fh		;ea4b
	ret nz			;ea4e
	nop			;ea4f
	nop			;ea50
	nop			;ea51
	inc bc			;ea52
	nop			;ea53
	add a,b			;ea54
	ld bc,00f04h		;ea55
	ld bc,00086h		;ea58
	ld a,a			;ea5b
	nop			;ea5c
	ret nz			;ea5d
	nop			;ea5e
	nop			;ea5f
	nop			;ea60
	inc bc			;ea61
	nop			;ea62
	add a,b			;ea63
	ld bc,01f05h		;ea64
	ld bc,001ebh		;ea67
	rst 38h			;ea6a
	ld bc,000f0h		;ea6b
	nop			;ea6e
	nop			;ea6f
	dec de			;ea70
	nop			;ea71
	add a,b			;ea72
	ld bc,03f06h		;ea73
	inc bc			;ea76
	ex de,hl		;ea77
	ld bc,001ffh		;ea78
	ret nz			;ea7b
	nop			;ea7c
	nop			;ea7d
	nop			;ea7e
	dec de			;ea7f
	nop			;ea80
	add a,b			;ea81
	ld bc,07f07h		;ea82
	rlca			;ea85
	xor 001h		;ea86
	rst 38h			;ea88
	ld bc,00080h		;ea89
	nop			;ea8c
	nop			;ea8d
	dec de			;ea8e
	nop			;ea8f
lea90h:
	ld (bc),a		;ea90
	nop			;ea91
	ld (bc),a		;ea92
	nop			;ea93
	inc bc			;ea94
	nop			;ea95
	dec de			;ea96
	nop			;ea97
	nop			;ea98
	nop			;ea99
	nop			;ea9a
	nop			;ea9b
lea9ch:
	nop			;ea9c
	nop			;ea9d
	nop			;ea9e
	nop			;ea9f
leaa0h:
	add hl,bc		;eaa0
	jp pe,01008h		;eaa1
	nop			;eaa4
	nop			;eaa5
	ld bc,le9efh		;eaa6
	add a,b			;eaa9
	nop			;eaaa
	ld a,e			;eaab
	sub l			;eaac
	ld l,a			;eaad
	ld a,d			;eaae
	sbc a,h			;eaaf
	jr lea9ch		;eab0
	djnz lead4h		;eab2
	nop			;eab4
	ld bc,lef02h		;eab5
	jp (hl)			;eab8
	rst 38h			;eab9
	nop			;eaba
	ld c,d			;eabb
	ld hl,(039e8h)		;eabc
	ex de,hl		;eabf
	daa			;eac0
	jp pe,04810h		;eac1
	nop			;eac4
	inc bc			;eac5
	inc bc			;eac6
	and 0e9h		;eac7
	rst 38h			;eac9
	nop			;eaca
	push de			;eacb
	ld hl,(039e4h)		;eacc
	pop de			;eacf
	ld (hl),0eah		;ead0
	djnz $+122		;ead2
lead4h:
	nop			;ead4
	inc bc			;ead5
	inc bc			;ead6
	rst 10h			;ead7
	jp (hl)			;ead8
	rst 38h			;ead9
	nop			;eada
	nop			;eadb
	nop			;eadc
	nop			;eadd
	nop			;eade
	nop			;eadf
	ld b,l			;eae0
	jp pe,08010h		;eae1
	ld bc,00303h		;eae4
	nop			;eae7
	nop			;eae8
	nop			;eae9
	rst 38h			;eaea
	ld (03a31h),a		;eaeb
	call 05465h		;eaee
	jp pe,08010h		;eaf1
	ld bc,00303h		;eaf4
	nop			;eaf7
	nop			;eaf8
	nop			;eaf9
	rst 38h			;eafa
	add hl,de		;eafb
	ex de,hl		;eafc
	ld hl,00000h		;eafd
	ld h,e			;eb00
	jp pe,08020h		;eb01
	ld bc,00303h		;eb04
	nop			;eb07
	nop			;eb08
	nop			;eb09
	rst 38h			;eb0a
	ld hl,042b4h		;eb0b
	ld e,(hl)		;eb0e
	inc hl			;eb0f
	ld (hl),d		;eb10
	jp pe,08040h		;eb11
	ld bc,00303h		;eb14
	nop			;eb17
	nop			;eb18
	nop			;eb19
	rst 38h			;eb1a
	nop			;eb1b
	add hl,de		;eb1c
	ld e,(hl)		;eb1d
	inc hl			;eb1e
	ld d,(hl)		;eb1f
	add a,c			;eb20
	jp pe,08080h		;eb21
	ld bc,00303h		;eb24
	nop			;eb27
	nop			;eb28
	nop			;eb29
	rst 38h			;eb2a
	nop			;eb2b
	jp 03a39h		;eb2c
	call 07f20h		;eb2f
	nop			;eb32
	nop			;eb33
	nop			;eb34
	djnz $+9		;eb35
	inc h			;eb37
	jr nz,$+1		;eb38
	nop			;eb3a
	ld b,b			;eb3b
	ld bc,00e10h		;eb3c
	inc h			;eb3f
	ld (de),a		;eb40
	rst 38h			;eb41
	ld bc,00240h		;eb42
	add hl,bc		;eb45
	dec de			;eb46
	inc h			;eb47
	ld e,0ffh		;eb48
	ld bc,00240h		;eb4a
	rrca			;eb4d
	dec de			;eb4e
	ld c,l			;eb4f
	djnz $+1		;eb50
	ld bc,00018h		;eb52
	nop			;eb55
	jr nz,leb58h		;eb56
leb58h:
	djnz $+1		;eb58
	ld bc,00018h		;eb5a
	nop			;eb5d
	jr nz,leb60h		;eb5e
leb60h:
	djnz $+1		;eb60
	ld bc,00029h		;eb62
	nop			;eb65
	jr nz,leb68h		;eb66
leb68h:
	djnz $+1		;eb68
	ld bc,00053h		;eb6a
	nop			;eb6d
	jr nz,leb70h		;eb6e
leb70h:
	djnz $+1		;eb70
	ld bc,000a6h		;eb72
	nop			;eb75
	jr nz,leb78h		;eb76
leb78h:
	nop			;eb78
	nop			;eb79
	dec h			;eb7a
	nop			;eb7b
	nop			;eb7c
	nop			;eb7d
	nop			;eb7e
	nop			;eb7f
	add a,c			;eb80
	ret p			;eb81
	daa			;eb82
	jp pe,lf148h		;eb83
	ld bc,000f1h		;eb86
	nop			;eb89
	nop			;eb8a
	nop			;eb8b
	nop			;eb8c
	nop			;eb8d
	nop			;eb8e
	nop			;eb8f
	add a,c			;eb90
	ret p			;eb91
	daa			;eb92
	jp pe,lf1afh		;eb93
	ld l,b			;eb96
	pop af			;eb97
	nop			;eb98
	nop			;eb99
	nop			;eb9a
	nop			;eb9b
	nop			;eb9c
	nop			;eb9d
	nop			;eb9e
	nop			;eb9f
	add a,c			;eba0
	ret p			;eba1
	ld b,l			;eba2
	jp pe,00000h		;eba3
	rst 8			;eba6
	pop af			;eba7
	nop			;eba8
	nop			;eba9
	nop			;ebaa
	nop			;ebab
	nop			;ebac
	nop			;ebad
	nop			;ebae
	nop			;ebaf
	add a,c			;ebb0
	ret p			;ebb1
	add a,c			;ebb2
	jp pe,00000h		;ebb3
	ld d,0f2h		;ebb6
	nop			;ebb8
	nop			;ebb9
	nop			;ebba
	nop			;ebbb
	nop			;ebbc
	nop			;ebbd
	nop			;ebbe
	nop			;ebbf
	add a,c			;ebc0
	ret p			;ebc1
	ld (hl),d		;ebc2
	jp pe,00000h		;ebc3
	ld d,l			;ebc6
	jp p,00000h		;ebc7
	nop			;ebca
	nop			;ebcb
	nop			;ebcc
	nop			;ebcd
	nop			;ebce
	nop			;ebcf
	add a,c			;ebd0
	ret p			;ebd1
	ld (hl),d		;ebd2
	jp pe,00000h		;ebd3
	sub h			;ebd6
	jp p,00000h		;ebd7
	nop			;ebda
	nop			;ebdb
	nop			;ebdc
	nop			;ebdd
	nop			;ebde
	nop			;ebdf
	add a,c			;ebe0
	ret p			;ebe1
	ld h,e			;ebe2
	jp pe,00000h		;ebe3
	out (0f2h),a		;ebe6
diskcode_end:
DUMITR:

; BLOCK 'dumitr' (start 0xebe8 end 0xebee)
dumitr_start:
	ei			;ebe8
	reti			;ebe9
	push de			;ebeb
	defb 0cdh,00ah		;ebec
dumitr_end:

; BLOCK 'intvars' (start 0xebee end 0xec00)
intvars_start:
	defb 03bh		;ebee
	defb 03ah		;ebef
	defb 003h		;ebf0
	defb 03bh		;ebf1
	defb 026h		;ebf2
	defb 000h		;ebf3
	defb 06fh		;ebf4
	defb 0e3h		;ebf5
	defb 0e9h		;ebf6
	defb 000h		;ebf7
	defb 000h		;ebf8
	defb 000h		;ebf9
	defb 000h		;ebfa
	defb 000h		;ebfb
	defb 000h		;ebfc
	defb 0c3h		;ebfd
	defb 000h		;ebfe
	defb 000h		;ebff
intvars_end:
ITRTAB:

; BLOCK 'ivt' (start 0xec00 end 0xec24)
ivt_start:
	defw 0ebe8h		;ec00
	defw 0ebe8h		;ec02
	defw 0e242h		;ec04
	defw 0e7d4h		;ec06
	defw 0e987h		;ec08
	defw 0ebe8h		;ec0a
	defw 0ebe8h		;ec0c
	defw 0ebe8h		;ec0e
	defw 0dd09h		;ec10
	defw 0dd22h		;ec12
	defw 0dd3bh		;ec14
	defw 0dd50h		;ec16
	defw 0dd6dh		;ec18
	defw 0dd86h		;ec1a
	defw 0dd9fh		;ec1c
	defw 0ddb9h		;ec1e
	defw 0ec43h		;ec20
	defw 0ec58h		;ec22
ivt_end:

; BLOCK 'kbdcode' (start 0xec24 end 0xec70)
kbdcode_start:
	nop			;ec24
	call pe,00000h		;ec25
CONST_ENTRY:
	ld a,(0ec26h)		;ec28
	ret			;ec2b
CONIN_ENTRY:
	ld a,(0ec26h)		;ec2c
	or a			;ec2f
	jp z,CONIN_ENTRY	;ec30
	di			;ec33
	xor a			;ec34
	ld (0ec26h),a		;ec35
	ei			;ec38
	in a,(010h)		;ec39
	ld c,a			;ec3b
	ld hl,lf700h		;ec3c
	call siocode_end	;ec3f
	ret			;ec42
KEYIT:
	ld (lf34bh),sp		;ec43
	ld sp,lf620h		;ec47
	push af			;ec4a
	ld a,0ffh		;ec4b
	ld (0ec26h),a		;ec4d
	pop af			;ec50
	ld sp,(lf34bh)		;ec51
	ei			;ec55
	reti			;ec56
PARIN:
	ld (lf34bh),sp		;ec58
	ld sp,lf620h		;ec5c
	push af			;ec5f
	ld a,0ffh		;ec60
	ld (0ec27h),a		;ec62
	pop af			;ec65
	ld sp,(lf34bh)		;ec66
	ei			;ec6a
	reti			;ec6b
	ld a,(bc)		;ec6d
	dec sp			;ec6e
	defb 03ah		;ec6f
kbdcode_end:

; BLOCK 'biosdata' (start 0xec70 end 0xf800)
biosdata_start:
	defb 003h		;ec70
	defb 03bh		;ec71
	defb 026h		;ec72
	defb 000h		;ec73
	defb 06fh		;ec74
	defb 0e3h		;ec75
	defb 0e9h		;ec76
	defb 000h		;ec77
	defb 000h		;ec78
	defb 000h		;ec79
	defb 000h		;ec7a
	defb 000h		;ec7b
	defb 000h		;ec7c
	defb 0c3h		;ec7d
	defb 000h		;ec7e
	defb 000h		;ec7f
	defb 000h		;ec80
	defb 000h		;ec81
	defb 000h		;ec82
	defb 000h		;ec83
	defb 000h		;ec84
	defb 000h		;ec85
	defb 000h		;ec86
	defb 000h		;ec87
	defb 000h		;ec88
	defb 000h		;ec89
	defb 000h		;ec8a
	defb 000h		;ec8b
	defb 000h		;ec8c
	defb 000h		;ec8d
	defb 000h		;ec8e
	defb 000h		;ec8f
	defb 000h		;ec90
	defb 000h		;ec91
	defb 000h		;ec92
	defb 000h		;ec93
	defb 000h		;ec94
	defb 000h		;ec95
	defb 000h		;ec96
	defb 000h		;ec97
	defb 000h		;ec98
	defb 000h		;ec99
	defb 000h		;ec9a
	defb 000h		;ec9b
	defb 000h		;ec9c
	defb 000h		;ec9d
	defb 000h		;ec9e
	defb 000h		;ec9f
	defb 000h		;eca0
	defb 000h		;eca1
	defb 000h		;eca2
	defb 000h		;eca3
	defb 000h		;eca4
	defb 000h		;eca5
	defb 000h		;eca6
	defb 000h		;eca7
	defb 000h		;eca8
	defb 000h		;eca9
	defb 000h		;ecaa
	defb 000h		;ecab
	defb 000h		;ecac
	defb 000h		;ecad
	defb 000h		;ecae
	defb 000h		;ecaf
	defb 000h		;ecb0
	defb 000h		;ecb1
	defb 000h		;ecb2
	defb 000h		;ecb3
	defb 000h		;ecb4
	defb 000h		;ecb5
	defb 000h		;ecb6
	defb 000h		;ecb7
	defb 000h		;ecb8
	defb 000h		;ecb9
	defb 000h		;ecba
	defb 000h		;ecbb
	defb 000h		;ecbc
	defb 000h		;ecbd
	defb 000h		;ecbe
	defb 000h		;ecbf
	defb 000h		;ecc0
	defb 000h		;ecc1
	defb 000h		;ecc2
	defb 000h		;ecc3
	defb 000h		;ecc4
	defb 000h		;ecc5
	defb 000h		;ecc6
	defb 000h		;ecc7
	defb 000h		;ecc8
	defb 000h		;ecc9
	defb 000h		;ecca
	defb 000h		;eccb
	defb 000h		;eccc
	defb 000h		;eccd
	defb 000h		;ecce
	defb 000h		;eccf
	defb 000h		;ecd0
	defb 000h		;ecd1
	defb 000h		;ecd2
	defb 000h		;ecd3
	defb 000h		;ecd4
	defb 000h		;ecd5
	defb 000h		;ecd6
	defb 000h		;ecd7
	defb 000h		;ecd8
	defb 000h		;ecd9
	defb 000h		;ecda
	defb 000h		;ecdb
	defb 000h		;ecdc
	defb 000h		;ecdd
	defb 000h		;ecde
	defb 000h		;ecdf
	defb 000h		;ece0
	defb 000h		;ece1
	defb 000h		;ece2
	defb 000h		;ece3
	defb 000h		;ece4
	defb 000h		;ece5
	defb 000h		;ece6
	defb 000h		;ece7
	defb 000h		;ece8
	defb 000h		;ece9
	defb 000h		;ecea
	defb 000h		;eceb
	defb 000h		;ecec
	defb 000h		;eced
	defb 000h		;ecee
	defb 000h		;ecef
	defb 000h		;ecf0
	defb 000h		;ecf1
	defb 000h		;ecf2
	defb 000h		;ecf3
	defb 000h		;ecf4
	defb 000h		;ecf5
	defb 000h		;ecf6
	defb 000h		;ecf7
	defb 000h		;ecf8
	defb 000h		;ecf9
	defb 000h		;ecfa
	defb 000h		;ecfb
	defb 000h		;ecfc
	defb 000h		;ecfd
	defb 000h		;ecfe
	defb 000h		;ecff
	defb 000h		;ed00
	defb 000h		;ed01
	defb 000h		;ed02
	defb 000h		;ed03
	defb 000h		;ed04
	defb 000h		;ed05
	defb 000h		;ed06
	defb 000h		;ed07
	defb 000h		;ed08
	defb 000h		;ed09
	defb 000h		;ed0a
	defb 000h		;ed0b
	defb 000h		;ed0c
	defb 000h		;ed0d
	defb 000h		;ed0e
	defb 000h		;ed0f
	defb 000h		;ed10
	defb 000h		;ed11
	defb 000h		;ed12
	defb 000h		;ed13
	defb 000h		;ed14
	defb 000h		;ed15
	defb 000h		;ed16
	defb 000h		;ed17
	defb 000h		;ed18
	defb 000h		;ed19
	defb 000h		;ed1a
	defb 000h		;ed1b
	defb 000h		;ed1c
	defb 000h		;ed1d
	defb 000h		;ed1e
	defb 000h		;ed1f
	defb 000h		;ed20
	defb 000h		;ed21
	defb 000h		;ed22
	defb 000h		;ed23
	defb 000h		;ed24
	defb 000h		;ed25
	defb 000h		;ed26
	defb 000h		;ed27
	defb 000h		;ed28
	defb 000h		;ed29
	defb 000h		;ed2a
	defb 000h		;ed2b
	defb 000h		;ed2c
	defb 000h		;ed2d
	defb 000h		;ed2e
	defb 000h		;ed2f
	defb 000h		;ed30
	defb 000h		;ed31
	defb 000h		;ed32
	defb 000h		;ed33
	defb 000h		;ed34
	defb 000h		;ed35
	defb 000h		;ed36
	defb 000h		;ed37
	defb 000h		;ed38
	defb 000h		;ed39
	defb 000h		;ed3a
	defb 000h		;ed3b
	defb 000h		;ed3c
	defb 000h		;ed3d
	defb 000h		;ed3e
	defb 000h		;ed3f
	defb 000h		;ed40
	defb 000h		;ed41
	defb 000h		;ed42
	defb 000h		;ed43
	defb 000h		;ed44
	defb 000h		;ed45
	defb 000h		;ed46
	defb 000h		;ed47
	defb 000h		;ed48
	defb 000h		;ed49
	defb 000h		;ed4a
	defb 000h		;ed4b
	defb 000h		;ed4c
	defb 000h		;ed4d
	defb 000h		;ed4e
	defb 000h		;ed4f
	defb 000h		;ed50
	defb 000h		;ed51
	defb 000h		;ed52
	defb 000h		;ed53
	defb 000h		;ed54
	defb 000h		;ed55
	defb 000h		;ed56
	defb 000h		;ed57
	defb 000h		;ed58
	defb 000h		;ed59
	defb 000h		;ed5a
	defb 000h		;ed5b
	defb 000h		;ed5c
	defb 000h		;ed5d
	defb 000h		;ed5e
	defb 000h		;ed5f
	defb 000h		;ed60
	defb 000h		;ed61
	defb 000h		;ed62
	defb 000h		;ed63
	defb 000h		;ed64
	defb 000h		;ed65
	defb 000h		;ed66
	defb 000h		;ed67
	defb 000h		;ed68
	defb 000h		;ed69
	defb 000h		;ed6a
	defb 000h		;ed6b
	defb 000h		;ed6c
	defb 000h		;ed6d
	defb 000h		;ed6e
	defb 000h		;ed6f
	defb 000h		;ed70
	defb 000h		;ed71
	defb 000h		;ed72
	defb 000h		;ed73
	defb 000h		;ed74
	defb 000h		;ed75
	defb 000h		;ed76
	defb 000h		;ed77
	defb 000h		;ed78
	defb 000h		;ed79
	defb 000h		;ed7a
	defb 000h		;ed7b
	defb 000h		;ed7c
	defb 000h		;ed7d
	defb 000h		;ed7e
	defb 000h		;ed7f
	defb 000h		;ed80
	defb 000h		;ed81
	defb 000h		;ed82
	defb 000h		;ed83
	defb 000h		;ed84
	defb 000h		;ed85
	defb 000h		;ed86
	defb 000h		;ed87
	defb 000h		;ed88
	defb 000h		;ed89
	defb 000h		;ed8a
	defb 000h		;ed8b
	defb 000h		;ed8c
	defb 000h		;ed8d
	defb 000h		;ed8e
	defb 000h		;ed8f
	defb 000h		;ed90
	defb 000h		;ed91
	defb 000h		;ed92
	defb 000h		;ed93
	defb 000h		;ed94
	defb 000h		;ed95
	defb 000h		;ed96
	defb 000h		;ed97
	defb 000h		;ed98
	defb 000h		;ed99
	defb 000h		;ed9a
	defb 000h		;ed9b
	defb 000h		;ed9c
	defb 000h		;ed9d
	defb 000h		;ed9e
	defb 000h		;ed9f
	defb 000h		;eda0
	defb 000h		;eda1
	defb 000h		;eda2
	defb 000h		;eda3
	defb 000h		;eda4
	defb 000h		;eda5
	defb 000h		;eda6
	defb 000h		;eda7
	defb 000h		;eda8
	defb 000h		;eda9
	defb 000h		;edaa
	defb 000h		;edab
	defb 000h		;edac
	defb 000h		;edad
	defb 000h		;edae
	defb 000h		;edaf
	defb 000h		;edb0
	defb 000h		;edb1
	defb 000h		;edb2
	defb 000h		;edb3
	defb 000h		;edb4
	defb 000h		;edb5
	defb 000h		;edb6
	defb 000h		;edb7
	defb 000h		;edb8
	defb 000h		;edb9
	defb 000h		;edba
	defb 000h		;edbb
	defb 000h		;edbc
	defb 000h		;edbd
	defb 000h		;edbe
	defb 000h		;edbf
	defb 000h		;edc0
	defb 000h		;edc1
	defb 000h		;edc2
	defb 000h		;edc3
	defb 000h		;edc4
	defb 000h		;edc5
	defb 000h		;edc6
	defb 000h		;edc7
	defb 000h		;edc8
	defb 000h		;edc9
	defb 000h		;edca
	defb 000h		;edcb
	defb 000h		;edcc
	defb 000h		;edcd
	defb 000h		;edce
	defb 000h		;edcf
	defb 000h		;edd0
	defb 000h		;edd1
	defb 000h		;edd2
	defb 000h		;edd3
	defb 000h		;edd4
	defb 000h		;edd5
	defb 000h		;edd6
	defb 000h		;edd7
	defb 000h		;edd8
	defb 000h		;edd9
	defb 000h		;edda
	defb 000h		;eddb
	defb 000h		;eddc
	defb 000h		;eddd
	defb 000h		;edde
	defb 000h		;eddf
	defb 000h		;ede0
	defb 000h		;ede1
	defb 000h		;ede2
	defb 000h		;ede3
	defb 000h		;ede4
	defb 000h		;ede5
	defb 000h		;ede6
	defb 000h		;ede7
	defb 000h		;ede8
	defb 000h		;ede9
	defb 000h		;edea
	defb 000h		;edeb
	defb 000h		;edec
	defb 000h		;eded
	defb 000h		;edee
	defb 000h		;edef
	defb 000h		;edf0
	defb 000h		;edf1
	defb 000h		;edf2
	defb 000h		;edf3
	defb 000h		;edf4
	defb 000h		;edf5
	defb 000h		;edf6
	defb 000h		;edf7
	defb 000h		;edf8
	defb 000h		;edf9
	defb 000h		;edfa
	defb 000h		;edfb
	defb 000h		;edfc
	defb 000h		;edfd
	defb 000h		;edfe
	defb 000h		;edff
	defb 000h		;ee00
	defb 000h		;ee01
	defb 000h		;ee02
	defb 000h		;ee03
	defb 000h		;ee04
	defb 000h		;ee05
	defb 000h		;ee06
	defb 000h		;ee07
	defb 000h		;ee08
	defb 000h		;ee09
	defb 000h		;ee0a
	defb 000h		;ee0b
	defb 000h		;ee0c
	defb 000h		;ee0d
	defb 000h		;ee0e
	defb 000h		;ee0f
	defb 000h		;ee10
	defb 000h		;ee11
	defb 000h		;ee12
	defb 000h		;ee13
	defb 000h		;ee14
	defb 000h		;ee15
	defb 000h		;ee16
	defb 000h		;ee17
	defb 000h		;ee18
	defb 000h		;ee19
	defb 000h		;ee1a
	defb 000h		;ee1b
	defb 000h		;ee1c
	defb 000h		;ee1d
	defb 000h		;ee1e
	defb 000h		;ee1f
	defb 000h		;ee20
	defb 000h		;ee21
	defb 000h		;ee22
	defb 000h		;ee23
	defb 000h		;ee24
	defb 000h		;ee25
	defb 000h		;ee26
	defb 000h		;ee27
	defb 000h		;ee28
	defb 000h		;ee29
	defb 000h		;ee2a
	defb 000h		;ee2b
	defb 000h		;ee2c
	defb 000h		;ee2d
	defb 000h		;ee2e
	defb 000h		;ee2f
	defb 000h		;ee30
	defb 000h		;ee31
	defb 000h		;ee32
	defb 000h		;ee33
	defb 000h		;ee34
	defb 000h		;ee35
	defb 000h		;ee36
	defb 000h		;ee37
	defb 000h		;ee38
	defb 000h		;ee39
	defb 000h		;ee3a
	defb 000h		;ee3b
	defb 000h		;ee3c
	defb 000h		;ee3d
	defb 000h		;ee3e
	defb 000h		;ee3f
	defb 000h		;ee40
	defb 000h		;ee41
	defb 000h		;ee42
	defb 000h		;ee43
	defb 000h		;ee44
	defb 000h		;ee45
	defb 000h		;ee46
	defb 000h		;ee47
	defb 000h		;ee48
	defb 000h		;ee49
	defb 000h		;ee4a
	defb 000h		;ee4b
	defb 000h		;ee4c
	defb 000h		;ee4d
	defb 000h		;ee4e
	defb 000h		;ee4f
	defb 000h		;ee50
	defb 000h		;ee51
	defb 000h		;ee52
	defb 000h		;ee53
	defb 000h		;ee54
	defb 000h		;ee55
	defb 000h		;ee56
	defb 000h		;ee57
	defb 000h		;ee58
	defb 000h		;ee59
	defb 000h		;ee5a
	defb 000h		;ee5b
	defb 000h		;ee5c
	defb 000h		;ee5d
	defb 000h		;ee5e
	defb 000h		;ee5f
	defb 000h		;ee60
	defb 000h		;ee61
	defb 000h		;ee62
	defb 000h		;ee63
	defb 000h		;ee64
	defb 000h		;ee65
	defb 000h		;ee66
	defb 000h		;ee67
	defb 000h		;ee68
	defb 000h		;ee69
	defb 000h		;ee6a
	defb 000h		;ee6b
	defb 000h		;ee6c
	defb 000h		;ee6d
	defb 000h		;ee6e
	defb 000h		;ee6f
	defb 000h		;ee70
	defb 000h		;ee71
	defb 000h		;ee72
	defb 000h		;ee73
	defb 000h		;ee74
	defb 000h		;ee75
	defb 000h		;ee76
	defb 000h		;ee77
	defb 000h		;ee78
	defb 000h		;ee79
	defb 000h		;ee7a
	defb 000h		;ee7b
	defb 000h		;ee7c
	defb 000h		;ee7d
	defb 000h		;ee7e
	defb 000h		;ee7f
	defb 000h		;ee80
lee81h:
	defb 0e5h		;ee81
	defb 047h		;ee82
	defb 045h		;ee83
	defb 04eh		;ee84
	defb 045h		;ee85
	defb 052h		;ee86
	defb 052h		;ee87
	defb 032h		;ee88
	defb 020h		;ee89
	defb 020h		;ee8a
	defb 020h		;ee8b
	defb 020h		;ee8c
	defb 000h		;ee8d
	defb 000h		;ee8e
	defb 000h		;ee8f
	defb 005h		;ee90
	defb 07ah		;ee91
	defb 000h		;ee92
	defb 000h		;ee93
	defb 000h		;ee94
	defb 000h		;ee95
	defb 000h		;ee96
	defb 000h		;ee97
	defb 000h		;ee98
	defb 000h		;ee99
	defb 000h		;ee9a
	defb 000h		;ee9b
	defb 000h		;ee9c
	defb 000h		;ee9d
	defb 000h		;ee9e
	defb 000h		;ee9f
	defb 000h		;eea0
	defb 0e5h		;eea1
	defb 047h		;eea2
	defb 045h		;eea3
	defb 04eh		;eea4
	defb 045h		;eea5
	defb 052h		;eea6
	defb 052h		;eea7
	defb 020h		;eea8
	defb 020h		;eea9
	defb 020h		;eeaa
	defb 020h		;eeab
	defb 020h		;eeac
	defb 000h		;eead
	defb 000h		;eeae
	defb 000h		;eeaf
	defb 004h		;eeb0
	defb 07bh		;eeb1
	defb 000h		;eeb2
	defb 000h		;eeb3
	defb 000h		;eeb4
	defb 000h		;eeb5
	defb 000h		;eeb6
	defb 000h		;eeb7
	defb 000h		;eeb8
	defb 000h		;eeb9
	defb 000h		;eeba
	defb 000h		;eebb
	defb 000h		;eebc
	defb 000h		;eebd
	defb 000h		;eebe
	defb 000h		;eebf
	defb 000h		;eec0
	defb 0e5h		;eec1
	defb 04fh		;eec2
	defb 056h		;eec3
	defb 045h		;eec4
	defb 052h		;eec5
	defb 050h		;eec6
	defb 020h		;eec7
	defb 020h		;eec8
	defb 020h		;eec9
	defb 020h		;eeca
	defb 020h		;eecb
	defb 020h		;eecc
	defb 000h		;eecd
	defb 000h		;eece
	defb 000h		;eecf
	defb 055h		;eed0
	defb 059h		;eed1
	defb 05ah		;eed2
	defb 05bh		;eed3
	defb 05dh		;eed4
	defb 05eh		;eed5
	defb 05fh		;eed6
	defb 000h		;eed7
	defb 000h		;eed8
	defb 000h		;eed9
	defb 000h		;eeda
	defb 000h		;eedb
	defb 000h		;eedc
	defb 000h		;eedd
	defb 000h		;eede
	defb 000h		;eedf
	defb 000h		;eee0
	defb 0e5h		;eee1
	defb 043h		;eee2
	defb 04fh		;eee3
	defb 04dh		;eee4
	defb 04dh		;eee5
	defb 045h		;eee6
	defb 04eh		;eee7
	defb 054h		;eee8
	defb 020h		;eee9
	defb 050h		;eeea
	defb 041h		;eeeb
	defb 053h		;eeec
	defb 000h		;eeed
	defb 000h		;eeee
	defb 000h		;eeef
	defb 001h		;eef0
	defb 052h		;eef1
	defb 000h		;eef2
	defb 000h		;eef3
	defb 000h		;eef4
	defb 000h		;eef5
	defb 000h		;eef6
	defb 000h		;eef7
	defb 000h		;eef8
	defb 000h		;eef9
	defb 000h		;eefa
	defb 000h		;eefb
	defb 000h		;eefc
	defb 000h		;eefd
	defb 000h		;eefe
	defb 000h		;eeff
	defb 000h		;ef00
	defb 000h		;ef01
lef02h:
	defb 041h		;ef02
	defb 053h		;ef03
	defb 04dh		;ef04
	defb 020h		;ef05
	defb 020h		;ef06
	defb 020h		;ef07
	defb 020h		;ef08
	defb 020h		;ef09
	defb 043h		;ef0a
	defb 04fh		;ef0b
	defb 04dh		;ef0c
	defb 000h		;ef0d
	defb 000h		;ef0e
	defb 000h		;ef0f
	defb 040h		;ef10
	defb 07dh		;ef11
	defb 07eh		;ef12
	defb 07fh		;ef13
	defb 080h		;ef14
	defb 000h		;ef15
	defb 000h		;ef16
	defb 000h		;ef17
	defb 000h		;ef18
	defb 000h		;ef19
	defb 000h		;ef1a
	defb 000h		;ef1b
	defb 000h		;ef1c
	defb 000h		;ef1d
	defb 000h		;ef1e
	defb 000h		;ef1f
	defb 000h		;ef20
	defb 0e5h		;ef21
	defb 04dh		;ef22
	defb 055h		;ef23
	defb 053h		;ef24
	defb 049h		;ef25
	defb 04bh		;ef26
	defb 032h		;ef27
	defb 020h		;ef28
	defb 020h		;ef29
	defb 042h		;ef2a
	defb 041h		;ef2b
	defb 04bh		;ef2c
	defb 000h		;ef2d
	defb 000h		;ef2e
	defb 000h		;ef2f
	defb 03ch		;ef30
	defb 053h		;ef31
	defb 054h		;ef32
	defb 055h		;ef33
	defb 056h		;ef34
	defb 000h		;ef35
	defb 000h		;ef36
	defb 000h		;ef37
	defb 000h		;ef38
	defb 000h		;ef39
	defb 000h		;ef3a
	defb 000h		;ef3b
	defb 000h		;ef3c
	defb 000h		;ef3d
	defb 000h		;ef3e
	defb 000h		;ef3f
	defb 000h		;ef40
	defb 0e5h		;ef41
	defb 04dh		;ef42
	defb 055h		;ef43
	defb 053h		;ef44
	defb 049h		;ef45
	defb 04bh		;ef46
	defb 032h		;ef47
	defb 020h		;ef48
	defb 020h		;ef49
	defb 050h		;ef4a
	defb 041h		;ef4b
	defb 053h		;ef4c
	defb 000h		;ef4d
	defb 000h		;ef4e
	defb 000h		;ef4f
	defb 076h		;ef50
	defb 060h		;ef51
	defb 062h		;ef52
	defb 063h		;ef53
	defb 07ch		;ef54
	defb 081h		;ef55
	defb 082h		;ef56
	defb 083h		;ef57
	defb 084h		;ef58
	defb 000h		;ef59
	defb 000h		;ef5a
	defb 000h		;ef5b
	defb 000h		;ef5c
	defb 000h		;ef5d
	defb 000h		;ef5e
	defb 000h		;ef5f
	defb 000h		;ef60
	defb 0e5h		;ef61
	defb 054h		;ef62
	defb 045h		;ef63
	defb 053h		;ef64
	defb 054h		;ef65
	defb 020h		;ef66
	defb 020h		;ef67
	defb 020h		;ef68
	defb 020h		;ef69
	defb 043h		;ef6a
	defb 04fh		;ef6b
	defb 04dh		;ef6c
	defb 000h		;ef6d
	defb 000h		;ef6e
	defb 000h		;ef6f
	defb 000h		;ef70
	defb 000h		;ef71
	defb 000h		;ef72
	defb 000h		;ef73
	defb 000h		;ef74
	defb 000h		;ef75
	defb 000h		;ef76
	defb 000h		;ef77
	defb 000h		;ef78
	defb 000h		;ef79
	defb 000h		;ef7a
	defb 000h		;ef7b
	defb 000h		;ef7c
	defb 000h		;ef7d
	defb 000h		;ef7e
	defb 000h		;ef7f
	defb 000h		;ef80
	defb 0e5h		;ef81
	defb 0e5h		;ef82
	defb 0e5h		;ef83
	defb 0e5h		;ef84
	defb 0e5h		;ef85
	defb 0e5h		;ef86
	defb 0e5h		;ef87
	defb 0e5h		;ef88
	defb 0e5h		;ef89
	defb 0e5h		;ef8a
	defb 0e5h		;ef8b
	defb 0e5h		;ef8c
	defb 0e5h		;ef8d
	defb 0e5h		;ef8e
	defb 0e5h		;ef8f
	defb 0e5h		;ef90
	defb 0e5h		;ef91
	defb 0e5h		;ef92
	defb 0e5h		;ef93
	defb 0e5h		;ef94
	defb 0e5h		;ef95
	defb 0e5h		;ef96
	defb 0e5h		;ef97
	defb 0e5h		;ef98
	defb 0e5h		;ef99
	defb 0e5h		;ef9a
	defb 0e5h		;ef9b
	defb 0e5h		;ef9c
	defb 0e5h		;ef9d
	defb 0e5h		;ef9e
	defb 0e5h		;ef9f
	defb 0e5h		;efa0
	defb 0e5h		;efa1
	defb 0e5h		;efa2
	defb 0e5h		;efa3
	defb 0e5h		;efa4
	defb 0e5h		;efa5
	defb 0e5h		;efa6
	defb 0e5h		;efa7
	defb 0e5h		;efa8
	defb 0e5h		;efa9
	defb 0e5h		;efaa
	defb 0e5h		;efab
	defb 0e5h		;efac
	defb 0e5h		;efad
	defb 0e5h		;efae
	defb 0e5h		;efaf
	defb 0e5h		;efb0
	defb 0e5h		;efb1
	defb 0e5h		;efb2
	defb 0e5h		;efb3
	defb 0e5h		;efb4
	defb 0e5h		;efb5
	defb 0e5h		;efb6
	defb 0e5h		;efb7
	defb 0e5h		;efb8
	defb 0e5h		;efb9
	defb 0e5h		;efba
	defb 0e5h		;efbb
	defb 0e5h		;efbc
	defb 0e5h		;efbd
	defb 0e5h		;efbe
	defb 0e5h		;efbf
	defb 0e5h		;efc0
	defb 0e5h		;efc1
	defb 0e5h		;efc2
	defb 0e5h		;efc3
	defb 0e5h		;efc4
	defb 0e5h		;efc5
	defb 0e5h		;efc6
	defb 0e5h		;efc7
	defb 0e5h		;efc8
	defb 0e5h		;efc9
	defb 0e5h		;efca
	defb 0e5h		;efcb
	defb 0e5h		;efcc
	defb 0e5h		;efcd
	defb 0e5h		;efce
	defb 0e5h		;efcf
	defb 0e5h		;efd0
	defb 0e5h		;efd1
	defb 0e5h		;efd2
	defb 0e5h		;efd3
	defb 0e5h		;efd4
	defb 0e5h		;efd5
	defb 0e5h		;efd6
	defb 0e5h		;efd7
	defb 0e5h		;efd8
	defb 0e5h		;efd9
	defb 0e5h		;efda
	defb 0e5h		;efdb
	defb 0e5h		;efdc
	defb 0e5h		;efdd
	defb 0e5h		;efde
	defb 0e5h		;efdf
	defb 0e5h		;efe0
	defb 0e5h		;efe1
	defb 0e5h		;efe2
	defb 0e5h		;efe3
	defb 0e5h		;efe4
	defb 0e5h		;efe5
	defb 0e5h		;efe6
	defb 0e5h		;efe7
	defb 0e5h		;efe8
	defb 0e5h		;efe9
	defb 0e5h		;efea
	defb 0e5h		;efeb
	defb 0e5h		;efec
	defb 0e5h		;efed
	defb 0e5h		;efee
	defb 0e5h		;efef
	defb 0e5h		;eff0
	defb 0e5h		;eff1
	defb 0e5h		;eff2
	defb 0e5h		;eff3
	defb 0e5h		;eff4
	defb 0e5h		;eff5
	defb 0e5h		;eff6
	defb 0e5h		;eff7
	defb 0e5h		;eff8
	defb 0e5h		;eff9
	defb 0e5h		;effa
	defb 0e5h		;effb
	defb 0e5h		;effc
	defb 0e5h		;effd
	defb 0e5h		;effe
	defb 0e5h		;efff
	defb 0e5h		;f000
	defb 0e5h		;f001
	defb 0e5h		;f002
	defb 0e5h		;f003
	defb 0e5h		;f004
	defb 0e5h		;f005
	defb 0e5h		;f006
	defb 0e5h		;f007
	defb 0e5h		;f008
	defb 0e5h		;f009
	defb 0e5h		;f00a
	defb 0e5h		;f00b
	defb 0e5h		;f00c
	defb 0e5h		;f00d
	defb 0e5h		;f00e
	defb 0e5h		;f00f
	defb 0e5h		;f010
	defb 0e5h		;f011
	defb 0e5h		;f012
	defb 0e5h		;f013
	defb 0e5h		;f014
	defb 0e5h		;f015
	defb 0e5h		;f016
	defb 0e5h		;f017
	defb 0e5h		;f018
	defb 0e5h		;f019
	defb 0e5h		;f01a
	defb 0e5h		;f01b
	defb 0e5h		;f01c
	defb 0e5h		;f01d
	defb 0e5h		;f01e
	defb 0e5h		;f01f
	defb 0e5h		;f020
	defb 0e5h		;f021
	defb 0e5h		;f022
	defb 0e5h		;f023
	defb 0e5h		;f024
	defb 0e5h		;f025
	defb 0e5h		;f026
	defb 0e5h		;f027
	defb 0e5h		;f028
	defb 0e5h		;f029
	defb 0e5h		;f02a
	defb 0e5h		;f02b
	defb 0e5h		;f02c
	defb 0e5h		;f02d
	defb 0e5h		;f02e
	defb 0e5h		;f02f
	defb 0e5h		;f030
	defb 0e5h		;f031
	defb 0e5h		;f032
	defb 0e5h		;f033
	defb 0e5h		;f034
	defb 0e5h		;f035
	defb 0e5h		;f036
	defb 0e5h		;f037
	defb 0e5h		;f038
	defb 0e5h		;f039
	defb 0e5h		;f03a
	defb 0e5h		;f03b
	defb 0e5h		;f03c
	defb 0e5h		;f03d
	defb 0e5h		;f03e
	defb 0e5h		;f03f
	defb 0e5h		;f040
	defb 0e5h		;f041
	defb 0e5h		;f042
	defb 0e5h		;f043
	defb 0e5h		;f044
	defb 0e5h		;f045
	defb 0e5h		;f046
	defb 0e5h		;f047
	defb 0e5h		;f048
	defb 0e5h		;f049
	defb 0e5h		;f04a
	defb 0e5h		;f04b
	defb 0e5h		;f04c
	defb 0e5h		;f04d
	defb 0e5h		;f04e
	defb 0e5h		;f04f
	defb 0e5h		;f050
	defb 0e5h		;f051
	defb 0e5h		;f052
	defb 0e5h		;f053
	defb 0e5h		;f054
	defb 0e5h		;f055
	defb 0e5h		;f056
	defb 0e5h		;f057
	defb 0e5h		;f058
	defb 0e5h		;f059
	defb 0e5h		;f05a
	defb 0e5h		;f05b
	defb 0e5h		;f05c
	defb 0e5h		;f05d
	defb 0e5h		;f05e
	defb 0e5h		;f05f
	defb 0e5h		;f060
	defb 0e5h		;f061
	defb 0e5h		;f062
	defb 0e5h		;f063
	defb 0e5h		;f064
	defb 0e5h		;f065
	defb 0e5h		;f066
	defb 0e5h		;f067
	defb 0e5h		;f068
	defb 0e5h		;f069
	defb 0e5h		;f06a
	defb 0e5h		;f06b
	defb 0e5h		;f06c
	defb 0e5h		;f06d
	defb 0e5h		;f06e
	defb 0e5h		;f06f
	defb 0e5h		;f070
	defb 0e5h		;f071
	defb 0e5h		;f072
	defb 0e5h		;f073
	defb 0e5h		;f074
	defb 0e5h		;f075
	defb 0e5h		;f076
	defb 0e5h		;f077
	defb 0e5h		;f078
	defb 0e5h		;f079
	defb 0e5h		;f07a
	defb 0e5h		;f07b
	defb 0e5h		;f07c
	defb 0e5h		;f07d
	defb 0e5h		;f07e
	defb 0e5h		;f07f
	defb 0e5h		;f080
	defb 000h		;f081
	defb 041h		;f082
	defb 053h		;f083
	defb 04dh		;f084
	defb 020h		;f085
	defb 020h		;f086
	defb 020h		;f087
	defb 020h		;f088
	defb 020h		;f089
	defb 043h		;f08a
	defb 04fh		;f08b
	defb 04dh		;f08c
	defb 000h		;f08d
	defb 000h		;f08e
	defb 000h		;f08f
	defb 040h		;f090
	defb 07dh		;f091
	defb 07eh		;f092
	defb 07fh		;f093
	defb 080h		;f094
	defb 000h		;f095
	defb 000h		;f096
	defb 000h		;f097
	defb 000h		;f098
	defb 000h		;f099
	defb 000h		;f09a
	defb 000h		;f09b
	defb 000h		;f09c
	defb 000h		;f09d
	defb 000h		;f09e
	defb 000h		;f09f
	defb 000h		;f0a0
	defb 0e5h		;f0a1
	defb 04dh		;f0a2
	defb 055h		;f0a3
	defb 053h		;f0a4
	defb 049h		;f0a5
	defb 04bh		;f0a6
	defb 032h		;f0a7
	defb 020h		;f0a8
	defb 020h		;f0a9
	defb 042h		;f0aa
	defb 041h		;f0ab
	defb 04bh		;f0ac
	defb 000h		;f0ad
	defb 000h		;f0ae
	defb 000h		;f0af
	defb 03ch		;f0b0
	defb 053h		;f0b1
	defb 054h		;f0b2
	defb 055h		;f0b3
	defb 056h		;f0b4
	defb 000h		;f0b5
	defb 000h		;f0b6
	defb 000h		;f0b7
	defb 000h		;f0b8
	defb 000h		;f0b9
	defb 000h		;f0ba
	defb 000h		;f0bb
	defb 000h		;f0bc
	defb 000h		;f0bd
	defb 000h		;f0be
	defb 000h		;f0bf
	defb 000h		;f0c0
	defb 0e5h		;f0c1
	defb 04dh		;f0c2
	defb 055h		;f0c3
	defb 053h		;f0c4
	defb 049h		;f0c5
	defb 04bh		;f0c6
	defb 032h		;f0c7
	defb 020h		;f0c8
	defb 020h		;f0c9
	defb 050h		;f0ca
	defb 041h		;f0cb
	defb 053h		;f0cc
	defb 000h		;f0cd
	defb 000h		;f0ce
	defb 000h		;f0cf
	defb 076h		;f0d0
	defb 060h		;f0d1
	defb 062h		;f0d2
	defb 063h		;f0d3
	defb 07ch		;f0d4
	defb 081h		;f0d5
	defb 082h		;f0d6
	defb 083h		;f0d7
	defb 084h		;f0d8
	defb 000h		;f0d9
	defb 000h		;f0da
	defb 000h		;f0db
	defb 000h		;f0dc
	defb 000h		;f0dd
	defb 000h		;f0de
	defb 000h		;f0df
	defb 000h		;f0e0
	defb 0e5h		;f0e1
	defb 054h		;f0e2
	defb 045h		;f0e3
	defb 053h		;f0e4
	defb 054h		;f0e5
	defb 020h		;f0e6
	defb 020h		;f0e7
	defb 020h		;f0e8
	defb 020h		;f0e9
	defb 043h		;f0ea
	defb 04fh		;f0eb
	defb 04dh		;f0ec
	defb 000h		;f0ed
	defb 000h		;f0ee
	defb 000h		;f0ef
	defb 000h		;f0f0
	defb 000h		;f0f1
	defb 000h		;f0f2
	defb 000h		;f0f3
	defb 000h		;f0f4
	defb 000h		;f0f5
	defb 000h		;f0f6
	defb 000h		;f0f7
	defb 000h		;f0f8
	defb 000h		;f0f9
	defb 000h		;f0fa
	defb 000h		;f0fb
	defb 000h		;f0fc
	defb 000h		;f0fd
	defb 000h		;f0fe
	defb 000h		;f0ff
	defb 000h		;f100
	defb 0ffh		;f101
	defb 0ffh		;f102
	defb 0ffh		;f103
	defb 0ffh		;f104
	defb 0ffh		;f105
	defb 0ffh		;f106
	defb 0ffh		;f107
	defb 0ffh		;f108
	defb 0ffh		;f109
	defb 0ffh		;f10a
	defb 0ffh		;f10b
	defb 0ffh		;f10c
	defb 0ffh		;f10d
	defb 0ffh		;f10e
	defb 0fch		;f10f
	defb 007h		;f110
	defb 080h		;f111
	defb 000h		;f112
	defb 000h		;f113
	defb 000h		;f114
	defb 000h		;f115
	defb 000h		;f116
	defb 000h		;f117
	defb 000h		;f118
	defb 000h		;f119
	defb 000h		;f11a
	defb 000h		;f11b
	defb 000h		;f11c
	defb 000h		;f11d
	defb 000h		;f11e
	defb 000h		;f11f
	defb 000h		;f120
	defb 000h		;f121
	defb 000h		;f122
	defb 000h		;f123
	defb 000h		;f124
	defb 000h		;f125
	defb 000h		;f126
	defb 000h		;f127
	defb 000h		;f128
	defb 000h		;f129
	defb 000h		;f12a
	defb 000h		;f12b
	defb 000h		;f12c
	defb 000h		;f12d
	defb 000h		;f12e
	defb 000h		;f12f
	defb 000h		;f130
	defb 000h		;f131
	defb 000h		;f132
	defb 000h		;f133
	defb 000h		;f134
	defb 000h		;f135
	defb 000h		;f136
	defb 000h		;f137
	defb 000h		;f138
	defb 000h		;f139
	defb 000h		;f13a
	defb 000h		;f13b
	defb 000h		;f13c
	defb 000h		;f13d
	defb 000h		;f13e
	defb 000h		;f13f
	defb 000h		;f140
	defb 000h		;f141
	defb 000h		;f142
	defb 000h		;f143
	defb 000h		;f144
	defb 000h		;f145
	defb 000h		;f146
	defb 000h		;f147
lf148h:
	defb 04fh		;f148
	defb 072h		;f149
	defb 0c2h		;f14a
	defb 050h		;f14b
	defb 0bbh		;f14c
	defb 016h		;f14d
	defb 08ch		;f14e
	defb 01eh		;f14f
	defb 09dh		;f150
	defb 03fh		;f151
	defb 080h		;f152
	defb 080h		;f153
	defb 080h		;f154
	defb 080h		;f155
	defb 080h		;f156
	defb 080h		;f157
	defb 080h		;f158
	defb 080h		;f159
	defb 080h		;f15a
	defb 080h		;f15b
	defb 080h		;f15c
	defb 080h		;f15d
	defb 080h		;f15e
	defb 080h		;f15f
	defb 080h		;f160
	defb 080h		;f161
	defb 080h		;f162
	defb 080h		;f163
	defb 080h		;f164
	defb 080h		;f165
	defb 080h		;f166
	defb 080h		;f167
	defb 000h		;f168
	defb 000h		;f169
	defb 000h		;f16a
	defb 000h		;f16b
	defb 000h		;f16c
	defb 000h		;f16d
	defb 000h		;f16e
	defb 000h		;f16f
	defb 000h		;f170
	defb 000h		;f171
	defb 000h		;f172
	defb 000h		;f173
	defb 000h		;f174
	defb 000h		;f175
	defb 000h		;f176
	defb 000h		;f177
	defb 000h		;f178
	defb 000h		;f179
	defb 000h		;f17a
	defb 000h		;f17b
	defb 000h		;f17c
	defb 000h		;f17d
	defb 000h		;f17e
	defb 000h		;f17f
	defb 000h		;f180
	defb 000h		;f181
	defb 000h		;f182
	defb 000h		;f183
	defb 000h		;f184
	defb 000h		;f185
	defb 000h		;f186
	defb 000h		;f187
	defb 000h		;f188
	defb 000h		;f189
	defb 000h		;f18a
	defb 000h		;f18b
	defb 000h		;f18c
	defb 000h		;f18d
	defb 000h		;f18e
	defb 000h		;f18f
	defb 000h		;f190
	defb 000h		;f191
	defb 000h		;f192
	defb 000h		;f193
	defb 000h		;f194
	defb 000h		;f195
	defb 000h		;f196
	defb 000h		;f197
	defb 000h		;f198
	defb 000h		;f199
	defb 000h		;f19a
	defb 000h		;f19b
	defb 000h		;f19c
	defb 000h		;f19d
	defb 000h		;f19e
	defb 000h		;f19f
	defb 000h		;f1a0
	defb 000h		;f1a1
	defb 000h		;f1a2
	defb 000h		;f1a3
	defb 000h		;f1a4
	defb 000h		;f1a5
	defb 000h		;f1a6
	defb 000h		;f1a7
	defb 000h		;f1a8
	defb 000h		;f1a9
	defb 000h		;f1aa
	defb 000h		;f1ab
	defb 000h		;f1ac
	defb 000h		;f1ad
	defb 000h		;f1ae
lf1afh:
	defb 000h		;f1af
	defb 000h		;f1b0
	defb 000h		;f1b1
	defb 000h		;f1b2
	defb 000h		;f1b3
	defb 000h		;f1b4
	defb 000h		;f1b5
	defb 000h		;f1b6
	defb 000h		;f1b7
	defb 000h		;f1b8
	defb 000h		;f1b9
	defb 000h		;f1ba
	defb 000h		;f1bb
	defb 000h		;f1bc
	defb 000h		;f1bd
	defb 000h		;f1be
	defb 000h		;f1bf
	defb 000h		;f1c0
	defb 000h		;f1c1
	defb 000h		;f1c2
	defb 000h		;f1c3
	defb 000h		;f1c4
	defb 000h		;f1c5
	defb 000h		;f1c6
	defb 000h		;f1c7
	defb 000h		;f1c8
	defb 000h		;f1c9
	defb 000h		;f1ca
	defb 000h		;f1cb
	defb 000h		;f1cc
	defb 000h		;f1cd
	defb 000h		;f1ce
	defb 000h		;f1cf
	defb 000h		;f1d0
	defb 000h		;f1d1
	defb 000h		;f1d2
	defb 000h		;f1d3
	defb 000h		;f1d4
	defb 000h		;f1d5
	defb 000h		;f1d6
	defb 000h		;f1d7
	defb 000h		;f1d8
	defb 000h		;f1d9
	defb 000h		;f1da
	defb 000h		;f1db
	defb 000h		;f1dc
	defb 000h		;f1dd
	defb 000h		;f1de
	defb 000h		;f1df
	defb 000h		;f1e0
	defb 000h		;f1e1
	defb 000h		;f1e2
	defb 000h		;f1e3
	defb 000h		;f1e4
	defb 000h		;f1e5
	defb 000h		;f1e6
	defb 000h		;f1e7
	defb 000h		;f1e8
	defb 000h		;f1e9
	defb 000h		;f1ea
	defb 000h		;f1eb
	defb 000h		;f1ec
	defb 000h		;f1ed
	defb 000h		;f1ee
	defb 000h		;f1ef
	defb 000h		;f1f0
	defb 000h		;f1f1
	defb 000h		;f1f2
	defb 000h		;f1f3
	defb 000h		;f1f4
	defb 000h		;f1f5
	defb 000h		;f1f6
	defb 000h		;f1f7
	defb 000h		;f1f8
	defb 000h		;f1f9
	defb 000h		;f1fa
	defb 000h		;f1fb
	defb 000h		;f1fc
	defb 000h		;f1fd
	defb 000h		;f1fe
	defb 000h		;f1ff
	defb 000h		;f200
	defb 000h		;f201
	defb 000h		;f202
	defb 000h		;f203
	defb 000h		;f204
	defb 000h		;f205
	defb 000h		;f206
	defb 000h		;f207
	defb 000h		;f208
	defb 000h		;f209
	defb 000h		;f20a
	defb 000h		;f20b
	defb 000h		;f20c
	defb 000h		;f20d
	defb 000h		;f20e
	defb 000h		;f20f
	defb 000h		;f210
	defb 000h		;f211
	defb 000h		;f212
	defb 000h		;f213
	defb 000h		;f214
	defb 000h		;f215
	defb 000h		;f216
	defb 000h		;f217
	defb 000h		;f218
	defb 000h		;f219
	defb 000h		;f21a
	defb 000h		;f21b
	defb 000h		;f21c
	defb 000h		;f21d
	defb 000h		;f21e
	defb 000h		;f21f
	defb 000h		;f220
	defb 000h		;f221
	defb 000h		;f222
	defb 000h		;f223
	defb 000h		;f224
	defb 000h		;f225
	defb 000h		;f226
	defb 000h		;f227
	defb 000h		;f228
	defb 000h		;f229
	defb 000h		;f22a
	defb 000h		;f22b
	defb 000h		;f22c
	defb 000h		;f22d
	defb 000h		;f22e
	defb 000h		;f22f
	defb 000h		;f230
	defb 000h		;f231
	defb 000h		;f232
	defb 000h		;f233
	defb 000h		;f234
	defb 000h		;f235
	defb 000h		;f236
	defb 000h		;f237
	defb 000h		;f238
	defb 000h		;f239
	defb 000h		;f23a
	defb 000h		;f23b
	defb 000h		;f23c
	defb 000h		;f23d
	defb 000h		;f23e
	defb 000h		;f23f
	defb 000h		;f240
	defb 000h		;f241
	defb 000h		;f242
	defb 000h		;f243
	defb 000h		;f244
	defb 000h		;f245
	defb 000h		;f246
	defb 000h		;f247
	defb 000h		;f248
	defb 000h		;f249
	defb 000h		;f24a
	defb 000h		;f24b
	defb 000h		;f24c
	defb 000h		;f24d
	defb 000h		;f24e
	defb 000h		;f24f
	defb 000h		;f250
	defb 000h		;f251
	defb 000h		;f252
	defb 000h		;f253
	defb 000h		;f254
	defb 000h		;f255
	defb 000h		;f256
	defb 000h		;f257
	defb 000h		;f258
	defb 000h		;f259
	defb 000h		;f25a
	defb 000h		;f25b
	defb 000h		;f25c
	defb 000h		;f25d
	defb 000h		;f25e
	defb 000h		;f25f
	defb 000h		;f260
	defb 000h		;f261
	defb 000h		;f262
	defb 000h		;f263
	defb 000h		;f264
	defb 000h		;f265
	defb 000h		;f266
	defb 000h		;f267
	defb 000h		;f268
	defb 000h		;f269
	defb 000h		;f26a
	defb 000h		;f26b
	defb 000h		;f26c
	defb 000h		;f26d
	defb 000h		;f26e
	defb 000h		;f26f
	defb 000h		;f270
	defb 000h		;f271
	defb 000h		;f272
	defb 000h		;f273
	defb 000h		;f274
	defb 000h		;f275
	defb 000h		;f276
	defb 000h		;f277
	defb 000h		;f278
	defb 000h		;f279
	defb 000h		;f27a
	defb 000h		;f27b
	defb 000h		;f27c
	defb 000h		;f27d
	defb 000h		;f27e
	defb 000h		;f27f
	defb 000h		;f280
	defb 000h		;f281
	defb 000h		;f282
	defb 000h		;f283
	defb 000h		;f284
	defb 000h		;f285
	defb 000h		;f286
	defb 000h		;f287
	defb 000h		;f288
	defb 000h		;f289
	defb 000h		;f28a
	defb 000h		;f28b
	defb 000h		;f28c
	defb 000h		;f28d
	defb 000h		;f28e
	defb 000h		;f28f
	defb 000h		;f290
	defb 000h		;f291
	defb 000h		;f292
	defb 000h		;f293
	defb 000h		;f294
	defb 000h		;f295
	defb 000h		;f296
	defb 000h		;f297
	defb 000h		;f298
	defb 000h		;f299
	defb 000h		;f29a
	defb 000h		;f29b
	defb 000h		;f29c
	defb 000h		;f29d
	defb 000h		;f29e
	defb 000h		;f29f
	defb 000h		;f2a0
	defb 000h		;f2a1
	defb 000h		;f2a2
	defb 000h		;f2a3
	defb 000h		;f2a4
	defb 000h		;f2a5
	defb 000h		;f2a6
	defb 000h		;f2a7
	defb 000h		;f2a8
	defb 000h		;f2a9
	defb 000h		;f2aa
	defb 000h		;f2ab
	defb 000h		;f2ac
	defb 000h		;f2ad
	defb 000h		;f2ae
	defb 000h		;f2af
	defb 000h		;f2b0
	defb 000h		;f2b1
	defb 000h		;f2b2
	defb 000h		;f2b3
	defb 000h		;f2b4
	defb 000h		;f2b5
	defb 000h		;f2b6
	defb 000h		;f2b7
	defb 000h		;f2b8
	defb 000h		;f2b9
	defb 000h		;f2ba
	defb 000h		;f2bb
	defb 000h		;f2bc
	defb 000h		;f2bd
	defb 000h		;f2be
	defb 000h		;f2bf
	defb 000h		;f2c0
	defb 000h		;f2c1
	defb 000h		;f2c2
	defb 000h		;f2c3
	defb 000h		;f2c4
	defb 000h		;f2c5
	defb 000h		;f2c6
	defb 000h		;f2c7
	defb 000h		;f2c8
	defb 000h		;f2c9
	defb 000h		;f2ca
	defb 000h		;f2cb
	defb 000h		;f2cc
	defb 000h		;f2cd
	defb 000h		;f2ce
	defb 000h		;f2cf
	defb 000h		;f2d0
	defb 000h		;f2d1
	defb 000h		;f2d2
	defb 000h		;f2d3
	defb 000h		;f2d4
	defb 000h		;f2d5
	defb 000h		;f2d6
	defb 000h		;f2d7
	defb 000h		;f2d8
	defb 000h		;f2d9
	defb 000h		;f2da
	defb 000h		;f2db
	defb 000h		;f2dc
	defb 000h		;f2dd
lf2deh:
	defb 000h		;f2de
	defb 000h		;f2df
	defb 000h		;f2e0
	defb 000h		;f2e1
	defb 000h		;f2e2
	defb 000h		;f2e3
	defb 000h		;f2e4
	defb 000h		;f2e5
	defb 000h		;f2e6
	defb 000h		;f2e7
	defb 000h		;f2e8
	defb 000h		;f2e9
	defb 000h		;f2ea
	defb 000h		;f2eb
	defb 000h		;f2ec
	defb 000h		;f2ed
	defb 000h		;f2ee
	defb 000h		;f2ef
	defb 000h		;f2f0
	defb 000h		;f2f1
	defb 000h		;f2f2
	defb 000h		;f2f3
	defb 000h		;f2f4
	defb 000h		;f2f5
	defb 000h		;f2f6
	defb 000h		;f2f7
	defb 000h		;f2f8
	defb 000h		;f2f9
	defb 000h		;f2fa
	defb 000h		;f2fb
	defb 000h		;f2fc
	defb 000h		;f2fd
	defb 000h		;f2fe
	defb 000h		;f2ff
	defb 000h		;f300
	defb 000h		;f301
	defb 000h		;f302
	defb 000h		;f303
	defb 000h		;f304
	defb 000h		;f305
	defb 000h		;f306
	defb 000h		;f307
	defb 000h		;f308
	defb 000h		;f309
	defb 000h		;f30a
	defb 000h		;f30b
	defb 000h		;f30c
	defb 000h		;f30d
	defb 000h		;f30e
	defb 000h		;f30f
	defb 000h		;f310
	defb 000h		;f311
lf312h:
	defb 000h		;f312
lf313h:
	defb 002h		;f313
	defb 000h		;f314
lf315h:
	defb 009h		;f315
lf316h:
	defb 000h		;f316
lf317h:
	defb 000h		;f317
lf318h:
	defb 002h		;f318
lf319h:
	defb 000h		;f319
lf31ah:
	defb 002h		;f31a
	defb 000h		;f31b
lf31ch:
	defb 000h		;f31c
lf31dh:
	defb 002h		;f31d
lf31eh:
	defb 000h		;f31e
lf31fh:
	defb 002h		;f31f
lf320h:
	defb 000h		;f320
lf321h:
	defb 001h		;f321
lf322h:
	defb 000h		;f322
lf323h:
	defb 000h		;f323
lf324h:
	defb 000h		;f324
lf325h:
	defb 000h		;f325
	defb 000h		;f326
lf327h:
	defb 000h		;f327
	defb 000h		;f328
lf329h:
	defb 000h		;f329
lf32ah:
	defb 000h		;f32a
lf32bh:
	defb 001h		;f32b
lf32ch:
	defb 001h		;f32c
lf32dh:
	defb 002h		;f32d
lf32eh:
	defb 080h		;f32e
	defb 000h		;f32f
lf330h:
	defb 041h		;f330
	defb 0ebh		;f331
lf332h:
	defb 010h		;f332
lf333h:
	defb 009h		;f333
lf334h:
	defb 000h		;f334
lf335h:
	defb 002h		;f335
lf336h:
	defb 002h		;f336
lf337h:
	defb 000h		;f337
lf338h:
	defb 000h		;f338
lf339h:
	defb 000h		;f339
lf33ah:
	defb 081h		;f33a
lf33bh:
	defb 0eeh		;f33b
lf33ch:
	defb 002h		;f33c
lf33dh:
	defb 005h		;f33d
lf33eh:
	defb 00ah		;f33e
lf33fh:
	defb 000h		;f33f
lf340h:
	defb 000h		;f340
	defb 000h		;f341
	defb 002h		;f342
	defb 000h		;f343
	defb 006h		;f344
	defb 002h		;f345
	defb 000h		;f346
lf347h:
	defb 000h		;f347
lf348h:
	defb 000h		;f348
lf349h:
	defb 000h		;f349
	defb 000h		;f34a
lf34bh:
	defb 035h		;f34b
	defb 0cfh		;f34c
lf34dh:
	defb 000h		;f34d
	defb 001h		;f34e
lf34fh:
	defb 0ffh		;f34f
lf350h:
	defb 001h		;f350
lf351h:
	defb 027h		;f351
lf352h:
	defb 0eah		;f352
lf353h:
	defb 010h		;f353
lf354h:
	defb 048h		;f354
	defb 000h		;f355
lf356h:
	defb 003h		;f356
lf357h:
	defb 003h		;f357
lf358h:
	defb 0e6h		;f358
	defb 0e9h		;f359
lf35ah:
	defb 0ffh		;f35a
lf35bh:
	defb 000h		;f35b
	defb 0d5h		;f35c
	defb 02ah		;f35d
	defb 0e4h		;f35e
	defb 039h		;f35f
	defb 0d1h		;f360
	defb 000h		;f361
	defb 000h		;f362
	defb 000h		;f363
	defb 000h		;f364
	defb 000h		;f365
	defb 000h		;f366
	defb 000h		;f367
	defb 000h		;f368
	defb 000h		;f369
	defb 000h		;f36a
	defb 000h		;f36b
	defb 000h		;f36c
	defb 000h		;f36d
	defb 000h		;f36e
	defb 000h		;f36f
	defb 000h		;f370
	defb 000h		;f371
	defb 000h		;f372
	defb 000h		;f373
	defb 000h		;f374
	defb 000h		;f375
	defb 000h		;f376
	defb 000h		;f377
	defb 000h		;f378
	defb 000h		;f379
	defb 000h		;f37a
	defb 000h		;f37b
	defb 000h		;f37c
	defb 000h		;f37d
	defb 000h		;f37e
	defb 000h		;f37f
	defb 000h		;f380
	defb 000h		;f381
	defb 000h		;f382
	defb 000h		;f383
	defb 000h		;f384
	defb 000h		;f385
	defb 000h		;f386
	defb 000h		;f387
	defb 000h		;f388
	defb 000h		;f389
	defb 000h		;f38a
	defb 000h		;f38b
	defb 000h		;f38c
	defb 000h		;f38d
	defb 000h		;f38e
	defb 000h		;f38f
	defb 000h		;f390
	defb 000h		;f391
	defb 000h		;f392
	defb 000h		;f393
	defb 000h		;f394
	defb 000h		;f395
	defb 000h		;f396
	defb 000h		;f397
	defb 000h		;f398
	defb 000h		;f399
	defb 000h		;f39a
	defb 000h		;f39b
	defb 000h		;f39c
	defb 000h		;f39d
	defb 000h		;f39e
	defb 000h		;f39f
	defb 000h		;f3a0
	defb 000h		;f3a1
	defb 000h		;f3a2
	defb 000h		;f3a3
	defb 000h		;f3a4
	defb 000h		;f3a5
	defb 000h		;f3a6
	defb 000h		;f3a7
	defb 000h		;f3a8
	defb 000h		;f3a9
	defb 000h		;f3aa
	defb 000h		;f3ab
	defb 000h		;f3ac
	defb 000h		;f3ad
	defb 000h		;f3ae
	defb 000h		;f3af
	defb 000h		;f3b0
	defb 000h		;f3b1
	defb 000h		;f3b2
	defb 000h		;f3b3
	defb 000h		;f3b4
	defb 000h		;f3b5
	defb 000h		;f3b6
	defb 000h		;f3b7
	defb 000h		;f3b8
	defb 000h		;f3b9
	defb 000h		;f3ba
	defb 000h		;f3bb
	defb 000h		;f3bc
	defb 000h		;f3bd
	defb 000h		;f3be
	defb 000h		;f3bf
	defb 000h		;f3c0
	defb 000h		;f3c1
	defb 000h		;f3c2
	defb 000h		;f3c3
	defb 000h		;f3c4
	defb 000h		;f3c5
	defb 000h		;f3c6
	defb 000h		;f3c7
	defb 000h		;f3c8
	defb 000h		;f3c9
	defb 000h		;f3ca
	defb 000h		;f3cb
	defb 000h		;f3cc
	defb 000h		;f3cd
	defb 000h		;f3ce
	defb 000h		;f3cf
	defb 000h		;f3d0
	defb 000h		;f3d1
	defb 000h		;f3d2
	defb 000h		;f3d3
	defb 000h		;f3d4
	defb 000h		;f3d5
	defb 000h		;f3d6
	defb 000h		;f3d7
	defb 000h		;f3d8
	defb 000h		;f3d9
	defb 000h		;f3da
	defb 000h		;f3db
	defb 000h		;f3dc
	defb 000h		;f3dd
	defb 000h		;f3de
	defb 000h		;f3df
	defb 000h		;f3e0
	defb 000h		;f3e1
	defb 000h		;f3e2
	defb 000h		;f3e3
	defb 000h		;f3e4
	defb 000h		;f3e5
	defb 000h		;f3e6
	defb 000h		;f3e7
	defb 000h		;f3e8
	defb 000h		;f3e9
	defb 000h		;f3ea
	defb 000h		;f3eb
	defb 000h		;f3ec
	defb 000h		;f3ed
	defb 000h		;f3ee
	defb 000h		;f3ef
	defb 000h		;f3f0
	defb 000h		;f3f1
	defb 000h		;f3f2
	defb 000h		;f3f3
	defb 000h		;f3f4
	defb 000h		;f3f5
	defb 000h		;f3f6
	defb 000h		;f3f7
	defb 000h		;f3f8
	defb 000h		;f3f9
	defb 000h		;f3fa
	defb 000h		;f3fb
	defb 000h		;f3fc
	defb 000h		;f3fd
	defb 000h		;f3fe
	defb 000h		;f3ff
	defb 000h		;f400
	defb 000h		;f401
	defb 000h		;f402
	defb 000h		;f403
	defb 000h		;f404
	defb 000h		;f405
	defb 000h		;f406
	defb 000h		;f407
	defb 000h		;f408
	defb 000h		;f409
	defb 000h		;f40a
	defb 000h		;f40b
	defb 000h		;f40c
	defb 000h		;f40d
	defb 000h		;f40e
	defb 000h		;f40f
	defb 000h		;f410
	defb 000h		;f411
	defb 000h		;f412
	defb 000h		;f413
	defb 000h		;f414
	defb 000h		;f415
	defb 000h		;f416
	defb 000h		;f417
	defb 000h		;f418
	defb 000h		;f419
	defb 000h		;f41a
	defb 000h		;f41b
	defb 000h		;f41c
	defb 000h		;f41d
	defb 000h		;f41e
	defb 000h		;f41f
	defb 000h		;f420
	defb 000h		;f421
	defb 000h		;f422
	defb 000h		;f423
	defb 000h		;f424
	defb 000h		;f425
	defb 000h		;f426
	defb 000h		;f427
	defb 000h		;f428
	defb 000h		;f429
	defb 000h		;f42a
	defb 000h		;f42b
	defb 000h		;f42c
	defb 000h		;f42d
	defb 000h		;f42e
	defb 000h		;f42f
	defb 000h		;f430
	defb 000h		;f431
	defb 000h		;f432
	defb 000h		;f433
	defb 000h		;f434
	defb 000h		;f435
	defb 000h		;f436
	defb 000h		;f437
	defb 000h		;f438
	defb 000h		;f439
	defb 000h		;f43a
	defb 000h		;f43b
	defb 000h		;f43c
	defb 000h		;f43d
	defb 000h		;f43e
	defb 000h		;f43f
	defb 000h		;f440
	defb 000h		;f441
	defb 000h		;f442
	defb 000h		;f443
	defb 000h		;f444
	defb 000h		;f445
	defb 000h		;f446
	defb 000h		;f447
	defb 000h		;f448
	defb 000h		;f449
	defb 000h		;f44a
	defb 000h		;f44b
	defb 000h		;f44c
	defb 000h		;f44d
	defb 000h		;f44e
	defb 000h		;f44f
	defb 000h		;f450
	defb 000h		;f451
	defb 000h		;f452
	defb 000h		;f453
	defb 000h		;f454
	defb 000h		;f455
	defb 000h		;f456
	defb 000h		;f457
	defb 000h		;f458
	defb 000h		;f459
	defb 000h		;f45a
	defb 000h		;f45b
	defb 000h		;f45c
	defb 000h		;f45d
	defb 000h		;f45e
	defb 000h		;f45f
	defb 000h		;f460
	defb 000h		;f461
	defb 000h		;f462
	defb 000h		;f463
	defb 000h		;f464
	defb 000h		;f465
	defb 000h		;f466
	defb 000h		;f467
	defb 000h		;f468
	defb 000h		;f469
	defb 000h		;f46a
	defb 000h		;f46b
	defb 000h		;f46c
	defb 000h		;f46d
	defb 000h		;f46e
	defb 000h		;f46f
	defb 000h		;f470
	defb 000h		;f471
	defb 000h		;f472
	defb 000h		;f473
	defb 000h		;f474
	defb 000h		;f475
	defb 000h		;f476
	defb 000h		;f477
	defb 000h		;f478
	defb 000h		;f479
	defb 000h		;f47a
	defb 000h		;f47b
	defb 000h		;f47c
	defb 000h		;f47d
	defb 000h		;f47e
	defb 000h		;f47f
	defb 000h		;f480
	defb 000h		;f481
	defb 000h		;f482
	defb 000h		;f483
	defb 000h		;f484
	defb 000h		;f485
	defb 000h		;f486
	defb 000h		;f487
	defb 000h		;f488
	defb 000h		;f489
	defb 000h		;f48a
	defb 000h		;f48b
	defb 000h		;f48c
	defb 000h		;f48d
	defb 000h		;f48e
	defb 000h		;f48f
	defb 000h		;f490
	defb 000h		;f491
	defb 000h		;f492
	defb 000h		;f493
	defb 000h		;f494
	defb 000h		;f495
	defb 000h		;f496
	defb 000h		;f497
	defb 000h		;f498
	defb 000h		;f499
	defb 000h		;f49a
	defb 000h		;f49b
	defb 000h		;f49c
	defb 000h		;f49d
	defb 000h		;f49e
	defb 000h		;f49f
	defb 000h		;f4a0
	defb 000h		;f4a1
	defb 000h		;f4a2
	defb 000h		;f4a3
	defb 000h		;f4a4
	defb 000h		;f4a5
	defb 000h		;f4a6
	defb 000h		;f4a7
	defb 000h		;f4a8
	defb 000h		;f4a9
	defb 000h		;f4aa
	defb 000h		;f4ab
	defb 000h		;f4ac
	defb 000h		;f4ad
	defb 000h		;f4ae
	defb 000h		;f4af
	defb 000h		;f4b0
	defb 000h		;f4b1
	defb 000h		;f4b2
	defb 000h		;f4b3
	defb 000h		;f4b4
	defb 000h		;f4b5
	defb 000h		;f4b6
	defb 000h		;f4b7
	defb 000h		;f4b8
	defb 000h		;f4b9
	defb 000h		;f4ba
	defb 000h		;f4bb
	defb 000h		;f4bc
	defb 000h		;f4bd
	defb 000h		;f4be
	defb 000h		;f4bf
	defb 000h		;f4c0
	defb 000h		;f4c1
	defb 000h		;f4c2
	defb 000h		;f4c3
	defb 000h		;f4c4
	defb 000h		;f4c5
	defb 000h		;f4c6
	defb 000h		;f4c7
	defb 000h		;f4c8
	defb 000h		;f4c9
	defb 000h		;f4ca
	defb 000h		;f4cb
	defb 000h		;f4cc
	defb 000h		;f4cd
	defb 000h		;f4ce
	defb 000h		;f4cf
	defb 000h		;f4d0
	defb 000h		;f4d1
	defb 000h		;f4d2
	defb 000h		;f4d3
	defb 000h		;f4d4
	defb 000h		;f4d5
	defb 000h		;f4d6
	defb 000h		;f4d7
	defb 000h		;f4d8
	defb 000h		;f4d9
	defb 000h		;f4da
	defb 000h		;f4db
	defb 000h		;f4dc
	defb 000h		;f4dd
	defb 000h		;f4de
	defb 000h		;f4df
	defb 000h		;f4e0
	defb 000h		;f4e1
	defb 000h		;f4e2
	defb 000h		;f4e3
	defb 000h		;f4e4
	defb 000h		;f4e5
	defb 000h		;f4e6
	defb 000h		;f4e7
	defb 000h		;f4e8
	defb 000h		;f4e9
	defb 000h		;f4ea
	defb 000h		;f4eb
	defb 000h		;f4ec
	defb 000h		;f4ed
	defb 000h		;f4ee
	defb 000h		;f4ef
	defb 000h		;f4f0
	defb 000h		;f4f1
	defb 000h		;f4f2
	defb 000h		;f4f3
	defb 000h		;f4f4
	defb 000h		;f4f5
	defb 000h		;f4f6
	defb 000h		;f4f7
	defb 000h		;f4f8
	defb 000h		;f4f9
	defb 000h		;f4fa
	defb 000h		;f4fb
	defb 000h		;f4fc
	defb 000h		;f4fd
	defb 000h		;f4fe
	defb 000h		;f4ff
lf500h:
	defb 000h		;f500
	defb 000h		;f501
	defb 000h		;f502
	defb 000h		;f503
	defb 000h		;f504
	defb 000h		;f505
	defb 000h		;f506
	defb 000h		;f507
	defb 000h		;f508
	defb 000h		;f509
lf50ah:
	defb 000h		;f50a
	defb 000h		;f50b
	defb 000h		;f50c
	defb 000h		;f50d
	defb 000h		;f50e
	defb 000h		;f50f
	defb 000h		;f510
	defb 000h		;f511
	defb 000h		;f512
	defb 000h		;f513
	defb 000h		;f514
	defb 000h		;f515
	defb 000h		;f516
	defb 000h		;f517
	defb 000h		;f518
	defb 000h		;f519
	defb 000h		;f51a
	defb 000h		;f51b
	defb 000h		;f51c
	defb 000h		;f51d
	defb 000h		;f51e
	defb 000h		;f51f
	defb 000h		;f520
	defb 000h		;f521
	defb 000h		;f522
	defb 000h		;f523
	defb 000h		;f524
	defb 000h		;f525
	defb 000h		;f526
	defb 000h		;f527
	defb 000h		;f528
	defb 000h		;f529
	defb 000h		;f52a
	defb 000h		;f52b
	defb 000h		;f52c
	defb 000h		;f52d
	defb 000h		;f52e
	defb 000h		;f52f
	defb 000h		;f530
	defb 000h		;f531
	defb 000h		;f532
	defb 000h		;f533
	defb 000h		;f534
	defb 000h		;f535
	defb 000h		;f536
	defb 000h		;f537
	defb 000h		;f538
	defb 000h		;f539
	defb 000h		;f53a
	defb 000h		;f53b
	defb 000h		;f53c
	defb 000h		;f53d
	defb 000h		;f53e
	defb 000h		;f53f
	defb 000h		;f540
	defb 000h		;f541
	defb 000h		;f542
	defb 000h		;f543
	defb 000h		;f544
	defb 000h		;f545
	defb 000h		;f546
	defb 000h		;f547
	defb 000h		;f548
	defb 000h		;f549
	defb 000h		;f54a
	defb 000h		;f54b
	defb 000h		;f54c
	defb 000h		;f54d
	defb 000h		;f54e
	defb 000h		;f54f
	defb 000h		;f550
	defb 000h		;f551
	defb 000h		;f552
	defb 000h		;f553
	defb 000h		;f554
	defb 000h		;f555
	defb 000h		;f556
	defb 000h		;f557
	defb 000h		;f558
	defb 000h		;f559
	defb 000h		;f55a
	defb 000h		;f55b
	defb 000h		;f55c
	defb 000h		;f55d
	defb 000h		;f55e
	defb 000h		;f55f
	defb 000h		;f560
	defb 000h		;f561
	defb 000h		;f562
	defb 000h		;f563
	defb 000h		;f564
	defb 000h		;f565
	defb 000h		;f566
	defb 000h		;f567
	defb 000h		;f568
	defb 000h		;f569
	defb 000h		;f56a
	defb 000h		;f56b
	defb 000h		;f56c
	defb 000h		;f56d
	defb 000h		;f56e
	defb 000h		;f56f
	defb 000h		;f570
	defb 000h		;f571
	defb 000h		;f572
	defb 000h		;f573
	defb 000h		;f574
	defb 000h		;f575
	defb 000h		;f576
	defb 000h		;f577
	defb 000h		;f578
	defb 000h		;f579
	defb 000h		;f57a
	defb 000h		;f57b
	defb 000h		;f57c
	defb 000h		;f57d
	defb 000h		;f57e
	defb 000h		;f57f
	defb 000h		;f580
	defb 000h		;f581
	defb 000h		;f582
	defb 000h		;f583
	defb 000h		;f584
	defb 000h		;f585
	defb 000h		;f586
	defb 000h		;f587
	defb 000h		;f588
	defb 000h		;f589
	defb 000h		;f58a
	defb 000h		;f58b
	defb 000h		;f58c
	defb 000h		;f58d
	defb 000h		;f58e
	defb 000h		;f58f
	defb 000h		;f590
	defb 000h		;f591
	defb 000h		;f592
	defb 000h		;f593
	defb 000h		;f594
	defb 000h		;f595
	defb 000h		;f596
	defb 000h		;f597
	defb 000h		;f598
	defb 000h		;f599
	defb 000h		;f59a
	defb 000h		;f59b
	defb 000h		;f59c
	defb 000h		;f59d
	defb 000h		;f59e
	defb 000h		;f59f
	defb 000h		;f5a0
	defb 000h		;f5a1
	defb 000h		;f5a2
	defb 000h		;f5a3
	defb 000h		;f5a4
	defb 000h		;f5a5
	defb 000h		;f5a6
	defb 000h		;f5a7
	defb 000h		;f5a8
	defb 000h		;f5a9
	defb 000h		;f5aa
	defb 000h		;f5ab
	defb 000h		;f5ac
	defb 000h		;f5ad
	defb 000h		;f5ae
	defb 000h		;f5af
	defb 000h		;f5b0
	defb 000h		;f5b1
	defb 000h		;f5b2
	defb 000h		;f5b3
	defb 000h		;f5b4
	defb 000h		;f5b5
	defb 000h		;f5b6
	defb 000h		;f5b7
	defb 000h		;f5b8
	defb 000h		;f5b9
	defb 000h		;f5ba
	defb 000h		;f5bb
	defb 000h		;f5bc
	defb 000h		;f5bd
	defb 000h		;f5be
	defb 000h		;f5bf
	defb 000h		;f5c0
	defb 000h		;f5c1
	defb 000h		;f5c2
	defb 000h		;f5c3
	defb 000h		;f5c4
	defb 000h		;f5c5
	defb 000h		;f5c6
	defb 000h		;f5c7
	defb 000h		;f5c8
	defb 000h		;f5c9
	defb 000h		;f5ca
	defb 000h		;f5cb
	defb 000h		;f5cc
	defb 000h		;f5cd
	defb 000h		;f5ce
	defb 000h		;f5cf
	defb 000h		;f5d0
	defb 000h		;f5d1
	defb 000h		;f5d2
	defb 000h		;f5d3
	defb 000h		;f5d4
	defb 000h		;f5d5
	defb 000h		;f5d6
	defb 000h		;f5d7
	defb 000h		;f5d8
	defb 000h		;f5d9
	defb 000h		;f5da
	defb 000h		;f5db
	defb 000h		;f5dc
	defb 000h		;f5dd
	defb 000h		;f5de
	defb 000h		;f5df
	defb 000h		;f5e0
	defb 000h		;f5e1
	defb 000h		;f5e2
	defb 000h		;f5e3
	defb 000h		;f5e4
	defb 000h		;f5e5
	defb 000h		;f5e6
	defb 000h		;f5e7
	defb 000h		;f5e8
	defb 000h		;f5e9
	defb 000h		;f5ea
	defb 000h		;f5eb
	defb 000h		;f5ec
	defb 000h		;f5ed
	defb 000h		;f5ee
lf5efh:
	defb 000h		;f5ef
lf5f0h:
	defb 000h		;f5f0
	defb 000h		;f5f1
	defb 000h		;f5f2
	defb 000h		;f5f3
	defb 000h		;f5f4
	defb 000h		;f5f5
	defb 000h		;f5f6
	defb 000h		;f5f7
lf5f8h:
	defb 000h		;f5f8
lf5f9h:
	defb 000h		;f5f9
	defb 000h		;f5fa
	defb 000h		;f5fb
	defb 000h		;f5fc
	defb 000h		;f5fd
	defb 000h		;f5fe
	defb 000h		;f5ff
	defb 000h		;f600
	defb 000h		;f601
	defb 000h		;f602
	defb 000h		;f603
	defb 000h		;f604
	defb 000h		;f605
	defb 000h		;f606
	defb 000h		;f607
	defb 000h		;f608
	defb 000h		;f609
	defb 000h		;f60a
	defb 000h		;f60b
	defb 000h		;f60c
	defb 000h		;f60d
	defb 000h		;f60e
	defb 000h		;f60f
	defb 000h		;f610
	defb 000h		;f611
	defb 000h		;f612
	defb 000h		;f613
	defb 02ah		;f614
	defb 0e7h		;f615
	defb 0b6h		;f616
	defb 0e2h		;f617
	defb 00eh		;f618
	defb 0cfh		;f619
	defb 006h		;f61a
	defb 0c4h		;f61b
	defb 07fh		;f61c
	defb 000h		;f61d
	defb 044h		;f61e
	defb 000h		;f61f
lf620h:
	defb 000h		;f620
	defb 000h		;f621
	defb 000h		;f622
	defb 000h		;f623
	defb 000h		;f624
	defb 000h		;f625
	defb 000h		;f626
	defb 000h		;f627
	defb 000h		;f628
	defb 000h		;f629
	defb 000h		;f62a
	defb 000h		;f62b
	defb 000h		;f62c
	defb 000h		;f62d
	defb 000h		;f62e
	defb 000h		;f62f
	defb 000h		;f630
	defb 000h		;f631
	defb 000h		;f632
	defb 000h		;f633
	defb 000h		;f634
	defb 000h		;f635
	defb 000h		;f636
	defb 000h		;f637
	defb 000h		;f638
	defb 000h		;f639
	defb 000h		;f63a
	defb 000h		;f63b
	defb 000h		;f63c
	defb 000h		;f63d
	defb 000h		;f63e
	defb 000h		;f63f
	defb 000h		;f640
	defb 000h		;f641
	defb 000h		;f642
	defb 000h		;f643
	defb 000h		;f644
	defb 000h		;f645
	defb 000h		;f646
	defb 000h		;f647
	defb 000h		;f648
	defb 000h		;f649
	defb 000h		;f64a
	defb 000h		;f64b
	defb 000h		;f64c
	defb 000h		;f64d
	defb 000h		;f64e
	defb 000h		;f64f
	defb 000h		;f650
	defb 000h		;f651
	defb 000h		;f652
	defb 000h		;f653
	defb 000h		;f654
	defb 000h		;f655
	defb 000h		;f656
	defb 000h		;f657
	defb 000h		;f658
	defb 000h		;f659
	defb 000h		;f65a
	defb 000h		;f65b
	defb 000h		;f65c
	defb 000h		;f65d
	defb 000h		;f65e
	defb 000h		;f65f
	defb 000h		;f660
	defb 000h		;f661
	defb 000h		;f662
	defb 000h		;f663
	defb 000h		;f664
	defb 000h		;f665
	defb 000h		;f666
	defb 000h		;f667
	defb 000h		;f668
	defb 000h		;f669
	defb 000h		;f66a
	defb 000h		;f66b
	defb 000h		;f66c
	defb 000h		;f66d
	defb 000h		;f66e
	defb 000h		;f66f
	defb 00ah		;f670
	defb 0deh		;f671
	defb 001h		;f672
	defb 002h		;f673
	defb 0e6h		;f674
	defb 0e1h		;f675
	defb 039h		;f676
	defb 0e2h		;f677
	defb 03eh		;f678
	defb 0cbh		;f679
	defb 03eh		;f67a
	defb 000h		;f67b
	defb 044h		;f67c
	defb 000h		;f67d
	defb 039h		;f67e
	defb 0cfh		;f67f
lf680h:
	defb 000h		;f680
	defb 001h		;f681
	defb 002h		;f682
	defb 003h		;f683
	defb 004h		;f684
	defb 005h		;f685
	defb 006h		;f686
	defb 007h		;f687
	defb 008h		;f688
	defb 009h		;f689
	defb 00ah		;f68a
	defb 00bh		;f68b
	defb 00ch		;f68c
	defb 00dh		;f68d
	defb 00eh		;f68e
	defb 00fh		;f68f
	defb 010h		;f690
	defb 011h		;f691
	defb 012h		;f692
	defb 013h		;f693
	defb 014h		;f694
	defb 015h		;f695
	defb 016h		;f696
	defb 017h		;f697
	defb 018h		;f698
	defb 019h		;f699
	defb 01ah		;f69a
	defb 01bh		;f69b
	defb 01ch		;f69c
	defb 01dh		;f69d
	defb 01eh		;f69e
	defb 01fh		;f69f
	defb 020h		;f6a0
	defb 021h		;f6a1
	defb 022h		;f6a2
	defb 023h		;f6a3
	defb 024h		;f6a4
	defb 025h		;f6a5
	defb 026h		;f6a6
	defb 027h		;f6a7
	defb 028h		;f6a8
	defb 029h		;f6a9
	defb 02ah		;f6aa
	defb 02bh		;f6ab
	defb 02ch		;f6ac
	defb 02dh		;f6ad
	defb 02eh		;f6ae
	defb 02fh		;f6af
	defb 030h		;f6b0
	defb 031h		;f6b1
	defb 032h		;f6b2
	defb 033h		;f6b3
	defb 034h		;f6b4
	defb 035h		;f6b5
	defb 036h		;f6b6
	defb 037h		;f6b7
	defb 038h		;f6b8
	defb 039h		;f6b9
	defb 03ah		;f6ba
	defb 03bh		;f6bb
	defb 03ch		;f6bc
	defb 03dh		;f6bd
	defb 03eh		;f6be
	defb 03fh		;f6bf
	defb 005h		;f6c0
	defb 041h		;f6c1
	defb 042h		;f6c2
	defb 043h		;f6c3
	defb 044h		;f6c4
	defb 045h		;f6c5
	defb 046h		;f6c6
	defb 047h		;f6c7
	defb 048h		;f6c8
	defb 049h		;f6c9
	defb 04ah		;f6ca
	defb 04bh		;f6cb
	defb 04ch		;f6cc
	defb 04dh		;f6cd
	defb 04eh		;f6ce
	defb 04fh		;f6cf
	defb 050h		;f6d0
	defb 051h		;f6d1
	defb 052h		;f6d2
	defb 053h		;f6d3
	defb 054h		;f6d4
	defb 055h		;f6d5
	defb 056h		;f6d6
	defb 057h		;f6d7
	defb 058h		;f6d8
	defb 059h		;f6d9
	defb 05ah		;f6da
	defb 00bh		;f6db
	defb 00ch		;f6dc
	defb 00dh		;f6dd
	defb 05eh		;f6de
	defb 05fh		;f6df
	defb 016h		;f6e0
	defb 061h		;f6e1
	defb 062h		;f6e2
	defb 063h		;f6e3
	defb 064h		;f6e4
	defb 065h		;f6e5
	defb 066h		;f6e6
	defb 067h		;f6e7
	defb 068h		;f6e8
	defb 069h		;f6e9
	defb 06ah		;f6ea
	defb 06bh		;f6eb
	defb 06ch		;f6ec
	defb 06dh		;f6ed
	defb 06eh		;f6ee
	defb 06fh		;f6ef
	defb 070h		;f6f0
	defb 071h		;f6f1
	defb 072h		;f6f2
	defb 073h		;f6f3
	defb 074h		;f6f4
	defb 075h		;f6f5
	defb 076h		;f6f6
	defb 077h		;f6f7
	defb 078h		;f6f8
	defb 079h		;f6f9
	defb 07ah		;f6fa
	defb 01bh		;f6fb
	defb 01ch		;f6fc
	defb 01dh		;f6fd
	defb 00fh		;f6fe
	defb 07fh		;f6ff
lf700h:
	defb 000h		;f700
	defb 001h		;f701
	defb 002h		;f702
	defb 003h		;f703
	defb 004h		;f704
	defb 005h		;f705
	defb 006h		;f706
	defb 007h		;f707
	defb 008h		;f708
	defb 009h		;f709
	defb 00ah		;f70a
	defb 00bh		;f70b
	defb 00ch		;f70c
	defb 00dh		;f70d
	defb 00eh		;f70e
	defb 00fh		;f70f
	defb 010h		;f710
	defb 011h		;f711
	defb 012h		;f712
	defb 013h		;f713
	defb 014h		;f714
	defb 015h		;f715
	defb 016h		;f716
	defb 017h		;f717
	defb 018h		;f718
	defb 019h		;f719
	defb 01ah		;f71a
	defb 01bh		;f71b
	defb 01ch		;f71c
	defb 01dh		;f71d
	defb 01eh		;f71e
	defb 01fh		;f71f
	defb 020h		;f720
	defb 021h		;f721
	defb 022h		;f722
	defb 023h		;f723
	defb 024h		;f724
	defb 025h		;f725
	defb 026h		;f726
	defb 027h		;f727
	defb 028h		;f728
	defb 029h		;f729
	defb 02ah		;f72a
	defb 02bh		;f72b
	defb 02ch		;f72c
	defb 02dh		;f72d
	defb 02eh		;f72e
	defb 02fh		;f72f
	defb 030h		;f730
	defb 031h		;f731
	defb 032h		;f732
	defb 033h		;f733
	defb 034h		;f734
	defb 035h		;f735
	defb 036h		;f736
	defb 037h		;f737
	defb 038h		;f738
	defb 039h		;f739
	defb 03ah		;f73a
	defb 03bh		;f73b
	defb 03ch		;f73c
	defb 03dh		;f73d
	defb 03eh		;f73e
	defb 03fh		;f73f
	defb 040h		;f740
	defb 041h		;f741
	defb 042h		;f742
	defb 043h		;f743
	defb 044h		;f744
	defb 045h		;f745
	defb 046h		;f746
	defb 047h		;f747
	defb 048h		;f748
	defb 049h		;f749
	defb 04ah		;f74a
	defb 04bh		;f74b
	defb 04ch		;f74c
	defb 04dh		;f74d
	defb 04eh		;f74e
	defb 04fh		;f74f
	defb 050h		;f750
	defb 051h		;f751
	defb 052h		;f752
	defb 053h		;f753
	defb 054h		;f754
	defb 055h		;f755
	defb 056h		;f756
	defb 057h		;f757
	defb 058h		;f758
	defb 059h		;f759
	defb 05ah		;f75a
	defb 05bh		;f75b
	defb 05ch		;f75c
	defb 05dh		;f75d
	defb 05eh		;f75e
	defb 05fh		;f75f
	defb 060h		;f760
	defb 061h		;f761
	defb 062h		;f762
	defb 063h		;f763
	defb 064h		;f764
	defb 065h		;f765
	defb 066h		;f766
	defb 067h		;f767
	defb 068h		;f768
	defb 069h		;f769
	defb 06ah		;f76a
	defb 06bh		;f76b
	defb 06ch		;f76c
	defb 06dh		;f76d
	defb 06eh		;f76e
	defb 06fh		;f76f
	defb 070h		;f770
	defb 071h		;f771
	defb 072h		;f772
	defb 073h		;f773
	defb 074h		;f774
	defb 075h		;f775
	defb 076h		;f776
	defb 077h		;f777
	defb 078h		;f778
	defb 079h		;f779
	defb 07ah		;f77a
	defb 07bh		;f77b
	defb 07ch		;f77c
	defb 07dh		;f77d
	defb 07eh		;f77e
	defb 07fh		;f77f
	defb 080h		;f780
	defb 001h		;f781
	defb 082h		;f782
	defb 003h		;f783
	defb 004h		;f784
	defb 005h		;f785
	defb 086h		;f786
	defb 087h		;f787
	defb 008h		;f788
	defb 009h		;f789
	defb 00ah		;f78a
	defb 00bh		;f78b
	defb 00ch		;f78c
	defb 00dh		;f78d
	defb 00eh		;f78e
	defb 08fh		;f78f
	defb 010h		;f790
	defb 091h		;f791
	defb 092h		;f792
	defb 093h		;f793
	defb 014h		;f794
	defb 015h		;f795
	defb 096h		;f796
	defb 097h		;f797
	defb 018h		;f798
	defb 019h		;f799
	defb 01ah		;f79a
	defb 01bh		;f79b
	defb 01ch		;f79c
	defb 09dh		;f79d
	defb 01eh		;f79e
	defb 09fh		;f79f
	defb 020h		;f7a0
	defb 031h		;f7a1
	defb 032h		;f7a2
	defb 033h		;f7a3
	defb 034h		;f7a4
	defb 035h		;f7a5
	defb 036h		;f7a6
	defb 037h		;f7a7
	defb 038h		;f7a8
	defb 039h		;f7a9
	defb 0aah		;f7aa
	defb 030h		;f7ab
	defb 02dh		;f7ac
	defb 0adh		;f7ad
	defb 02eh		;f7ae
	defb 08bh		;f7af
	defb 030h		;f7b0
	defb 031h		;f7b1
	defb 032h		;f7b2
	defb 033h		;f7b3
	defb 034h		;f7b4
	defb 035h		;f7b5
	defb 036h		;f7b6
	defb 037h		;f7b7
	defb 038h		;f7b8
	defb 039h		;f7b9
	defb 0bah		;f7ba
	defb 030h		;f7bb
	defb 02dh		;f7bc
	defb 0bdh		;f7bd
	defb 02eh		;f7be
	defb 083h		;f7bf
	defb 012h		;f7c0
	defb 086h		;f7c1
	defb 0c2h		;f7c2
	defb 0c3h		;f7c3
	defb 0c4h		;f7c4
	defb 005h		;f7c5
	defb 082h		;f7c6
	defb 0c7h		;f7c7
	defb 008h		;f7c8
	defb 009h		;f7c9
	defb 00ah		;f7ca
	defb 084h		;f7cb
	defb 085h		;f7cc
	defb 0cdh		;f7cd
	defb 0ceh		;f7ce
	defb 0cfh		;f7cf
	defb 081h		;f7d0
	defb 0d1h		;f7d1
	defb 087h		;f7d2
	defb 0d3h		;f7d3
	defb 0d4h		;f7d4
	defb 0d5h		;f7d5
	defb 080h		;f7d6
	defb 0d7h		;f7d7
	defb 018h		;f7d8
	defb 0d9h		;f7d9
	defb 01ah		;f7da
	defb 0dbh		;f7db
	defb 0dch		;f7dc
	defb 0ddh		;f7dd
	defb 0deh		;f7de
	defb 030h		;f7df
	defb 0e0h		;f7e0
	defb 08eh		;f7e1
	defb 0e2h		;f7e2
	defb 0e3h		;f7e3
	defb 0e4h		;f7e4
	defb 0e5h		;f7e5
	defb 08ah		;f7e6
	defb 0e7h		;f7e7
	defb 0e8h		;f7e8
	defb 0e9h		;f7e9
	defb 0eah		;f7ea
	defb 08ch		;f7eb
	defb 08dh		;f7ec
	defb 0edh		;f7ed
	defb 0eeh		;f7ee
	defb 0efh		;f7ef
	defb 089h		;f7f0
	defb 0f1h		;f7f1
	defb 08fh		;f7f2
	defb 0f3h		;f7f3
	defb 0f4h		;f7f4
	defb 0f5h		;f7f5
	defb 088h		;f7f6
	defb 0f7h		;f7f7
	defb 0f8h		;f7f8
	defb 0f9h		;f7f9
	defb 0fah		;f7fa
	defb 0fbh		;f7fb
	defb 0fch		;f7fc
	defb 0fdh		;f7fd
	defb 0feh		;f7fe
	defb 07fh		;f7ff
biosdata_end:
DSPSTR:
