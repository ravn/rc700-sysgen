; z80dasm 1.2.0
; command line: z80dasm -a -l -g 0xDA00 -S syms_56k_z80dasm.sym -b blocks_56k.def -o cpm22_rel22_bios.asm cpm22_rel22_bios.bin

	org 0da00h
biosdata_end:	equ 0xf800

BOOT:

; BLOCK 'jumptable' (start 0xda00 end 0xda33)
jumptable_start:
	jp ldb7fh		;da00
WBOOT:
	jp ldbc8h		;da03
CONST:
	jp CONST_ENTRY		;da06
CONIN:
	jp CONIN_ENTRY		;da09
CONOUT:
	jp le210h		;da0c
LIST:
	jp ldc98h		;da0f
PUNCH:
	jp ldcebh		;da12
READER:
	jp ldcdbh		;da15
HOME:
	jp le65fh		;da18
SELDSK:
	jp le2d4h		;da1b
SETTRK:
	jp le37dh		;da1e
SETSEC:
	jp le383h		;da21
SETDMA:
	jp le389h		;da24
READ:
	jp le392h		;da27
WRITE:
	jp le3a6h		;da2a
LISTST:
	jp ldc94h		;da2d
SECTRAN:
	jp le38fh		;da30
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
	defb 0b7h		;da48
	defb 0c8h		;da49
config_end:
JWFITR:

; BLOCK 'extvec' (start 0xda4a end 0xda5c)
extvec_start:
	jp le74ch		;da4a
JREADS:
	jp ldcd7h		;da4d
JLINSEL:
	jp ldb1bh		;da50
JPEXIT:
	jp ldaf8h		;da53
JPCLOCK:
	jp ldb05h		;da56
JHRDFMT:
	jp le950h		;da59
extvec_end:

; BLOCK 'pad1' (start 0xda5c end 0xda71)
pad1_start:
	defb 0c3h		;da5c
	defb 0e1h		;da5d
	defb 0e8h		;da5e
	defb 064h		;da5f
	defb 0c2h		;da60
	defb 080h		;da61
	defb 029h		;da62
	defb 07eh		;da63
	defb 0e6h		;da64
	defb 003h		;da65
	defb 0f6h		;da66
	defb 080h		;da67
	defb 077h		;da68
	defb 0f1h		;da69
	defb 0feh		;da6a
	defb 02ch		;da6b
	defb 0cah		;da6c
	defb 058h		;da6d
	defb 029h		;da6e
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
	defb 020h		;daae
	defb 032h		;daaf
	defb 02eh		;dab0
	defb 032h		;dab1
	defb 00dh		;dab2
	defb 00ah		;dab3
	defb 000h		;dab4
MSG_WAITING:
	defb 00ch		;dab5
	defb 057h		;dab6
	defb 061h		;dab7
	defb 069h		;dab8
	defb 074h		;dab9
	defb 069h		;daba
	defb 06eh		;dabb
	defb 067h		;dabc
	defb 000h		;dabd
MSG_CONFIGERR:
	defb 00ch		;dabe
	defb 043h		;dabf
	defb 061h		;dac0
	defb 06eh		;dac1
	defb 06eh		;dac2
	defb 06fh		;dac3
	defb 074h		;dac4
	defb 020h		;dac5
	defb 072h		;dac6
	defb 065h		;dac7
	defb 061h		;dac8
	defb 064h		;dac9
	defb 020h		;daca
	defb 063h		;dacb
	defb 06fh		;dacc
	defb 06eh		;dacd
	defb 066h		;dace
	defb 069h		;dacf
	defb 067h		;dad0
	defb 075h		;dad1
	defb 072h		;dad2
	defb 061h		;dad3
	defb 074h		;dad4
	defb 069h		;dad5
	defb 06fh		;dad6
	defb 06eh		;dad7
	defb 020h		;dad8
	defb 072h		;dad9
	defb 065h		;dada
	defb 063h		;dadb
	defb 06fh		;dadc
	defb 072h		;dadd
	defb 064h		;dade
	defb 00dh		;dadf
	defb 00ah		;dae0
messages_end:

; BLOCK 'bootcode' (start 0xdae1 end 0xdc8d)
bootcode_start:
	nop			;dae1
ldae2h:
	ld a,(hl)		;dae2
	or a			;dae3
	ret z			;dae4
	push hl			;dae5
	ld c,a			;dae6
	call le210h		;dae7
	pop hl			;daea
	inc hl			;daeb
	jp ldae2h		;daec
ldaefh:
	ld hl,pad1_end		;daef
	call ldae2h		;daf2
ldaf5h:
	jp ldaf5h		;daf5
ldaf8h:
	ld a,0c3h		;daf8
	ld (0ffe5h),a		;dafa
	ld (0ffe6h),hl		;dafd
	ex de,hl		;db00
	ld (0ffdfh),hl		;db01
CLOCK:
	ret			;db04
ldb05h:
	di			;db05
	or a			;db06
	jp z,ldb13h		;db07
	ld de,(0fffch)		;db0a
	ld hl,(0fffeh)		;db0e
	ei			;db11
	ret			;db12
ldb13h:
	ld (0fffch),de		;db13
	ld (0fffeh),hl		;db17
LINSEL:
	ret			;db1a
ldb1bh:
	add a,00ah		;db1b
	ld c,a			;db1d
ldb1eh:
	di			;db1e
	ld a,001h		;db1f
	out (c),a		;db21
	in a,(c)		;db23
	ei			;db25
	and 001h		;db26
	jr z,ldb1eh		;db28
	ld hl,00002h		;db2a
	call sub_e653h		;db2d
	ld d,005h		;db30
	ld a,000h		;db32
	call sub_db5eh		;db34
	dec b			;db37
	ret m			;db38
	sla b			;db39
	or b			;db3b
	call sub_db5eh		;db3c
	or 080h			;db3f
	call sub_db5eh		;db41
	ld hl,00002h		;db44
	call sub_e653h		;db47
	ld a,c			;db4a
	cp 00ah			;db4b
	ld a,(ldc90h)		;db4d
	jp z,ldb56h		;db50
	ld a,(ldc92h)		;db53
ldb56h:
	and 020h		;db56
	jp z,sub_db5eh		;db58
	ld a,0ffh		;db5b
	ret			;db5d
sub_db5eh:
	di			;db5e
	out (c),d		;db5f
	out (c),a		;db61
	ei			;db63
	ret			;db64
sub_db65h:
	xor a			;db65
	ld (0d84ch),a		;db66
	ld hl,(0d89ah)		;db69
	ld (lda6fh),hl		;db6c
	ld hl,ldb76h		;db6f
	ld (0d89ah),hl		;db72
	ret			;db75
ldb76h:
	push hl			;db76
	ld hl,(lda6fh)		;db77
	ld (0d89ah),hl		;db7a
	pop hl			;db7d
	ret			;db7e
ldb7fh:
	ld sp,00080h		;db7f
	ld hl,lda8dh		;db82
	call ldae2h		;db85
	xor a			;db88
	ld (00004h),a		;db89
	ld (lf368h),a		;db8c
	ld a,(BOOTD)		;db8f
	or a			;db92
	jp z,ldb9bh		;db93
	ld a,002h		;db96
	ld (00004h),a		;db98
ldb9bh:
	xor a			;db9b
	ld (lf33dh),a		;db9c
	ld (lf346h),a		;db9f
	ld (lf33eh),a		;dba2
	in a,(014h)		;dba5
	and 080h		;dba7
	jp z,ldbc8h		;dba9
	ld a,(lf350h)		;dbac
	cp 002h			;dbaf
	jp nc,ldbc5h		;dbb1
	ld c,001h		;dbb4
	call le2d4h		;dbb6
	call le65fh		;dbb9
	ld a,b			;dbbc
	and 010h		;dbbd
	ld a,000h		;dbbf
WBOOT_ENTRY:
	jp nz,ldbc5h		;dbc1
	inc a			;dbc4
ldbc5h:
	ld (lf350h),a		;dbc5
ldbc8h:
	ei			;dbc8
	ld c,000h		;dbc9
	ld a,(BOOTD)		;dbcb
	or a			;dbce
	jr z,ldbd4h		;dbcf
	ld a,002h		;dbd1
	ld c,a			;dbd3
ldbd4h:
	call le2d4h		;dbd4
	xor a			;dbd7
	ld (lf33fh),a		;dbd8
	ld (00003h),a		;dbdb
	ld (lf351h),a		;dbde
	ld (0ec26h),a		;dbe1
	call le65fh		;dbe4
	ld sp,00080h		;dbe7
	ld bc,0c400h		;dbea
	call le389h		;dbed
	ld bc,00001h		;dbf0
	call le37dh		;dbf3
	ld bc,00000h		;dbf6
	call le383h		;dbf9
ldbfch:
	push bc			;dbfc
	call le392h		;dbfd
	or a			;dc00
	jp nz,ldaefh		;dc01
	ld hl,(lf34ah)		;dc04
	ld de,00080h		;dc07
	add hl,de		;dc0a
	ld b,h			;dc0b
	ld c,l			;dc0c
	call le389h		;dc0d
	pop bc			;dc10
	inc bc			;dc11
	call le383h		;dc12
	ld a,c			;dc15
	cp 02ch			;dc16
	jp nz,ldbfch		;dc18
	ld bc,00080h		;dc1b
	call le389h		;dc1e
	ld a,0c3h		;dc21
	ld (00000h),a		;dc23
	ld hl,WBOOT		;dc26
	ld (00001h),hl		;dc29
	ld (00005h),a		;dc2c
	ld hl,0cc06h		;dc2f
	ld (00006h),hl		;dc32
	ld a,(00004h)		;dc35
	and 00fh		;dc38
	ld c,a			;dc3a
	ld a,(BOOTD)		;dc3b
	cp c			;dc3e
	jr z,ldc5dh		;dc3f
	call le2d4h		;dc41
	ld a,h			;dc44
	or l			;dc45
	jr z,ldc57h		;dc46
	ld bc,00002h		;dc48
	call le37dh		;dc4b
	call le383h		;dc4e
	call le392h		;dc51
	or a			;dc54
	jr z,ldc5dh		;dc55
ldc57h:
	ld a,(BOOTD)		;dc57
	ld (00004h),a		;dc5a
ldc5dh:
	ld a,(00004h)		;dc5d
	and 00fh		;dc60
	ld c,a			;dc62
	cp 002h			;dc63
	call nc,sub_db65h	;dc65
	call le2d4h		;dc68
	ld a,(00004h)		;dc6b
	ld c,a			;dc6e
	ld hl,lf368h		;dc6f
	ld a,(hl)		;dc72
	ld (hl),001h		;dc73
	or a			;dc75
	jr z,ldc88h		;dc76
	ld a,(0c407h)		;dc78
	or a			;dc7b
	jr z,ldc88h		;dc7c
	ld hl,0c409h		;dc7e
	add a,l			;dc81
	ld l,a			;dc82
	ld a,(hl)		;dc83
	or a			;dc84
	jp z,0c403h		;dc85
ldc88h:
	jp 0c400h		;dc88
ldc8bh:
	rst 38h			;dc8b
ldc8ch:
	rst 38h			;dc8c
bootcode_end:
STLIST_ENTRY:

; BLOCK 'siocode' (start 0xdc8d end 0xde00)
siocode_start:
	rst 38h			;dc8d
ldc8eh:
	nop			;dc8e
ldc8fh:
	nop			;dc8f
ldc90h:
	inc l			;dc90
LIST_ENTRY:
	nop			;dc91
ldc92h:
	inc l			;dc92
ldc93h:
	nop			;dc93
ldc94h:
	ld a,(ldc8bh)		;dc94
	ret			;dc97
ldc98h:
	ld a,(ldc8bh)		;dc98
	or a			;dc9b
	jp z,ldc98h		;dc9c
	di			;dc9f
	ld a,000h		;dca0
	ld (ldc8bh),a		;dca2
	ld a,005h		;dca5
	out (00bh),a		;dca7
	ld a,(WR5B)		;dca9
	add a,08ah		;dcac
	out (00bh),a		;dcae
	ld a,001h		;dcb0
	out (00bh),a		;dcb2
	ld a,007h		;dcb4
	out (00bh),a		;dcb6
	ld a,c			;dcb8
	out (009h),a		;dcb9
	ei			;dcbb
	ret			;dcbc
sub_dcbdh:
	di			;dcbd
	xor a			;dcbe
	ld (ldc8ch),a		;dcbf
	ld a,005h		;dcc2
	out (00ah),a		;dcc4
	ld a,(WR5A)		;dcc6
	add a,08ah		;dcc9
	out (00ah),a		;dccb
	ld a,001h		;dccd
	out (00ah),a		;dccf
	ld a,01bh		;dcd1
	out (00ah),a		;dcd3
	ei			;dcd5
	ret			;dcd6
ldcd7h:
	ld a,(ldc8ch)		;dcd7
	ret			;dcda
ldcdbh:
	call ldcd7h		;dcdb
	or a			;dcde
	jp z,ldcdbh		;dcdf
	ld a,(ldc8eh)		;dce2
	push af			;dce5
	call sub_dcbdh		;dce6
	pop af			;dce9
	ret			;dcea
ldcebh:
	ld a,(bootcode_end)	;dceb
	or a			;dcee
	jp z,ldcebh		;dcef
	di			;dcf2
	ld a,000h		;dcf3
	ld (bootcode_end),a	;dcf5
	ld a,005h		;dcf8
	out (00ah),a		;dcfa
	ld a,(WR5A)		;dcfc
	add a,08ah		;dcff
	out (00ah),a		;dd01
	ld a,001h		;dd03
	out (00ah),a		;dd05
	ld a,01bh		;dd07
	out (00ah),a		;dd09
	ld a,c			;dd0b
	out (008h),a		;dd0c
	ei			;dd0e
	ret			;dd0f
	ld (lf363h),sp		;dd10
	ld sp,lf620h		;dd14
	push af			;dd17
	ld a,028h		;dd18
	out (00bh),a		;dd1a
	ld a,0ffh		;dd1c
	ld (ldc8bh),a		;dd1e
	pop af			;dd21
	ld sp,(lf363h)		;dd22
	ei			;dd26
	reti			;dd27
	ld (lf363h),sp		;dd29
	ld sp,lf620h		;dd2d
	push af			;dd30
	in a,(00bh)		;dd31
	ld (ldc92h),a		;dd33
	ld a,010h		;dd36
	out (00bh),a		;dd38
	pop af			;dd3a
	ld sp,(lf363h)		;dd3b
	ei			;dd3f
	reti			;dd40
	ld (lf363h),sp		;dd42
	ld sp,lf620h		;dd46
	push af			;dd49
	in a,(008h)		;dd4a
	ld (ldc8fh),a		;dd4c
	pop af			;dd4f
	ld sp,(lf363h)		;dd50
	ei			;dd54
	reti			;dd55
	ld (lf363h),sp		;dd57
	ld sp,lf620h		;dd5b
	push af			;dd5e
	ld a,001h		;dd5f
	out (00bh),a		;dd61
	in a,(00bh)		;dd63
	ld (ldc93h),a		;dd65
	ld a,030h		;dd68
	out (00bh),a		;dd6a
	pop af			;dd6c
	ld sp,(lf363h)		;dd6d
	ei			;dd71
	reti			;dd72
	ld (lf363h),sp		;dd74
	ld sp,lf620h		;dd78
	push af			;dd7b
	ld a,028h		;dd7c
	out (00ah),a		;dd7e
	ld a,0ffh		;dd80
	ld (bootcode_end),a	;dd82
	pop af			;dd85
	ld sp,(lf363h)		;dd86
	ei			;dd8a
	reti			;dd8b
	ld (lf363h),sp		;dd8d
	ld sp,lf620h		;dd91
	push af			;dd94
	in a,(00ah)		;dd95
	ld (ldc90h),a		;dd97
	ld a,010h		;dd9a
	out (00ah),a		;dd9c
	pop af			;dd9e
	ld sp,(lf363h)		;dd9f
	ei			;dda3
	reti			;dda4
	ld (lf363h),sp		;dda6
	ld sp,lf620h		;ddaa
	push af			;ddad
	in a,(008h)		;ddae
	ld (ldc8eh),a		;ddb0
	ld a,0ffh		;ddb3
	ld (ldc8ch),a		;ddb5
	pop af			;ddb8
	ld sp,(lf363h)		;ddb9
	ei			;ddbd
	reti			;ddbe
	ld (lf363h),sp		;ddc0
	ld sp,lf620h		;ddc4
	push af			;ddc7
	ld a,001h		;ddc8
	out (00ah),a		;ddca
	in a,(00ah)		;ddcc
	ld (LIST_ENTRY),a	;ddce
	ld a,030h		;ddd1
	out (00ah),a		;ddd3
	ld a,000h		;ddd5
	ld (ldc8eh),a		;ddd7
	ld a,0ffh		;ddda
	ld (ldc8ch),a		;dddc
	pop af			;dddf
	ld sp,(lf363h)		;dde0
	ei			;dde4
	reti			;dde5
ldde7h:
	nop			;dde7
ldde8h:
	nop			;dde8
	nop			;dde9
sub_ddeah:
	ld a,h			;ddea
	cpl			;ddeb
	ld h,a			;ddec
	ld a,l			;dded
	cpl			;ddee
	ld l,a			;ddef
	ret			;ddf0
sub_ddf1h:
	call sub_ddeah		;ddf1
	inc hl			;ddf4
	ret			;ddf5
sub_ddf6h:
	ld hl,(0ffd2h)		;ddf6
	ld a,l			;ddf9
	cp 080h			;ddfa
	ret nz			;ddfc
	ld a,h			;ddfd
	cp 007h			;ddfe
siocode_end:

; BLOCK 'displaycode' (start 0xde00 end 0xe2cd)
displaycode_start:
	ret			;de00
sub_de01h:
	ld a,(ldde7h)		;de01
	or a			;de04
	ld a,c			;de05
	ret nz			;de06
sub_de07h:
	ld b,000h		;de07
	add hl,bc		;de09
	ld a,(hl)		;de0a
	ret			;de0b
lde0ch:
	push af			;de0c
	ld a,080h		;de0d
	out (001h),a		;de0f
	ld a,(0ffd1h)		;de11
	out (000h),a		;de14
	ld a,(0ffd4h)		;de16
	out (000h),a		;de19
	pop af			;de1b
	ret			;de1c
lde1dh:
	ld hl,(0ffd2h)		;de1d
	ld de,00050h		;de20
	add hl,de		;de23
	ld (0ffd2h),hl		;de24
	ld hl,0ffd4h		;de27
	inc (hl)		;de2a
	jp lde0ch		;de2b
lde2eh:
	ld hl,(0ffd2h)		;de2e
	ld de,0ffb0h		;de31
	add hl,de		;de34
	ld (0ffd2h),hl		;de35
	ld hl,0ffd4h		;de38
	dec (hl)		;de3b
	jp lde0ch		;de3c
sub_de3fh:
	ld hl,00000h		;de3f
	ld (0ffd2h),hl		;de42
	xor a			;de45
	ld (0ffd1h),a		;de46
	ld (0ffd4h),a		;de49
	ret			;de4c
lde4dh:
	cp b			;de4d
	ret c			;de4e
	sub b			;de4f
	jp lde4dh		;de50
lde53h:
	ld hl,(0ffd5h)		;de53
	ld d,h			;de56
	ld e,l			;de57
	inc de			;de58
	ld bc,0004fh		;de59
	ld (hl),020h		;de5c
	ldir			;de5e
	ld a,(0ffdbh)		;de60
	cp 000h			;de63
	ret z			;de65
	ld hl,(0ffdch)		;de66
	ld d,h			;de69
	ld e,l			;de6a
	inc de			;de6b
	ld bc,00009h		;de6c
	ld (hl),000h		;de6f
	ldir			;de71
	ret			;de73
lde74h:
	ld hl,0f850h		;de74
	ld de,biosdata_end	;de77
	ld bc,00780h		;de7a
	ldir			;de7d
	ld hl,0ff80h		;de7f
	ld (0ffd5h),hl		;de82
	ld a,(0ffdbh)		;de85
	cp 000h			;de88
	jp z,lde53h		;de8a
	ld hl,lf50ah		;de8d
	ld de,lf500h		;de90
	ld bc,000f0h		;de93
	ldir			;de96
	ld hl,lf5f0h		;de98
	ld (0ffdch),hl		;de9b
	jp lde53h		;de9e
sub_dea1h:
	ld a,000h		;dea1
	ld b,003h		;dea3
ldea5h:
	srl h			;dea5
	rr l			;dea7
	rra			;dea9
	dec b			;deaa
	jp nz,ldea5h		;deab
	cp 000h			;deae
	ret z			;deb0
	ld b,005h		;deb1
ldeb3h:
	rra			;deb3
	dec b			;deb4
	jp nz,ldeb3h		;deb5
	ret			;deb8
sub_deb9h:
	ld de,lf500h		;deb9
	add hl,de		;debc
	cp 000h			;debd
	ld b,a			;debf
	ld a,000h		;dec0
	jp nz,ldec8h		;dec2
	and (hl)		;dec5
	ld (hl),a		;dec6
	ret			;dec7
ldec8h:
	scf			;dec8
	rla			;dec9
	dec b			;deca
	jp nz,ldec8h		;decb
	and (hl)		;dece
	ld (hl),a		;decf
	ret			;ded0
lded1h:
	ld a,000h		;ded1
	cp c			;ded3
	jp z,ldedah		;ded4
lded7h:
	ldir			;ded7
	ret			;ded9
ldedah:
	cp b			;deda
	jp nz,lded7h		;dedb
	ret			;dede
sub_dedfh:
	ld a,000h		;dedf
	cp c			;dee1
	jp z,ldee8h		;dee2
ldee5h:
	lddr			;dee5
	ret			;dee7
ldee8h:
	cp b			;dee8
	jp nz,ldee5h		;dee9
	ret			;deec
	out (01ch),a		;deed
	ret			;deef
	call sub_de3fh		;def0
	ld a,002h		;def3
	ld (0ffd7h),a		;def5
	ret			;def8
	ret			;def9
	ld a,000h		;defa
	ld (0ffd1h),a		;defc
	jp lde0ch		;deff
	ld hl,0ffcfh		;df02
	ld de,0ffceh		;df05
	ld bc,007cfh		;df08
	ld (hl),020h		;df0b
	lddr			;df0d
	call sub_de3fh		;df0f
	call lde0ch		;df12
	ld a,(0ffdbh)		;df15
	cp 000h			;df18
	ret z			;df1a
	xor a			;df1b
	ld (0ffdbh),a		;df1c
	ld hl,lf5f9h		;df1f
	ld de,lf5f8h		;df22
	ld bc,000f9h		;df25
	ld (hl),000h		;df28
	lddr			;df2a
	ret			;df2c
	ld de,biosdata_end	;df2d
	ld hl,(0ffd2h)		;df30
	add hl,de		;df33
	ld de,0004fh		;df34
	add hl,de		;df37
	ld d,h			;df38
	ld e,l			;df39
	dec de			;df3a
	ld bc,00000h		;df3b
	ld a,(0ffd1h)		;df3e
	cpl			;df41
	inc a			;df42
	add a,04fh		;df43
	ld c,a			;df45
	ld (hl),020h		;df46
	call sub_dedfh		;df48
	ld a,(0ffdbh)		;df4b
	cp 000h			;df4e
	ret z			;df50
	ld hl,(0ffd2h)		;df51
	ld d,000h		;df54
	ld a,(0ffd1h)		;df56
	ld e,a			;df59
	add hl,de		;df5a
	call sub_dea1h		;df5b
	call sub_deb9h		;df5e
	ld a,(0ffd1h)		;df61
	srl a			;df64
	srl a			;df66
	srl a			;df68
	cpl			;df6a
	add a,009h		;df6b
	ret m			;df6d
	ld c,a			;df6e
	ld b,000h		;df6f
	inc hl			;df71
	ld d,h			;df72
	ld e,l			;df73
	inc de			;df74
	ld a,000h		;df75
	jp lded1h		;df77
	ld hl,(0ffd2h)		;df7a
	ld a,(0ffd1h)		;df7d
	ld c,a			;df80
	ld b,000h		;df81
	add hl,bc		;df83
	call sub_ddf1h		;df84
	ld de,007cfh		;df87
	add hl,de		;df8a
	ld b,h			;df8b
	ld c,l			;df8c
	ld hl,0ffcfh		;df8d
	ld de,0ffceh		;df90
	ld (hl),020h		;df93
	call sub_dedfh		;df95
	ld a,(0ffdbh)		;df98
	cp 000h			;df9b
	ret z			;df9d
	ld hl,(0ffd2h)		;df9e
	ld d,000h		;dfa1
	ld a,(0ffd1h)		;dfa3
	ld e,a			;dfa6
	add hl,de		;dfa7
	call sub_dea1h		;dfa8
	call sub_deb9h		;dfab
	call sub_ddeah		;dfae
	ld de,lf5f9h		;dfb1
	add hl,de		;dfb4
	ld a,080h		;dfb5
	and h			;dfb7
	ret nz			;dfb8
	ld b,h			;dfb9
	ld c,l			;dfba
	ld h,d			;dfbb
	ld l,e			;dfbc
	dec de			;dfbd
	ld (hl),000h		;dfbe
	jp sub_dedfh		;dfc0
	ld a,(0ffd1h)		;dfc3
	cp 000h			;dfc6
	jp z,ldfd2h		;dfc8
	dec a			;dfcb
	ld (0ffd1h),a		;dfcc
	jp lde0ch		;dfcf
ldfd2h:
	ld a,04fh		;dfd2
	ld (0ffd1h),a		;dfd4
	ld hl,(0ffd2h)		;dfd7
	ld a,l			;dfda
	or h			;dfdb
	jp nz,lde2eh		;dfdc
	ld hl,00780h		;dfdf
	ld (0ffd2h),hl		;dfe2
	ld a,018h		;dfe5
	ld (0ffd4h),a		;dfe7
	jp lde0ch		;dfea
sub_dfedh:
	ld a,(0ffd1h)		;dfed
	cp 04fh			;dff0
	jp z,ldffch		;dff2
	inc a			;dff5
	ld (0ffd1h),a		;dff6
	jp lde0ch		;dff9
ldffch:
	ld a,000h		;dffc
	ld (0ffd1h),a		;dffe
	call sub_ddf6h		;e001
	jp nz,lde1dh		;e004
	call lde0ch		;e007
	jp lde74h		;e00a
	call sub_dfedh		;e00d
	call sub_dfedh		;e010
	call sub_dfedh		;e013
	jp sub_dfedh		;e016
	call sub_ddf6h		;e019
	jp nz,lde1dh		;e01c
	jp lde74h		;e01f
	ld hl,(0ffd2h)		;e022
	ld a,l			;e025
	or h			;e026
	jp nz,lde2eh		;e027
	ld hl,00780h		;e02a
	ld (0ffd2h),hl		;e02d
	ld a,018h		;e030
	ld (0ffd4h),a		;e032
	jp lde0ch		;e035
	call sub_de3fh		;e038
	jp lde0ch		;e03b
	ld hl,(0ffd2h)		;e03e
	ld b,h			;e041
	ld c,l			;e042
	ld de,0f850h		;e043
	add hl,de		;e046
	ld (ldde8h),hl		;e047
	ld de,0ffb0h		;e04a
	add hl,de		;e04d
	ex de,hl		;e04e
	ld h,b			;e04f
	ld l,c			;e050
	call sub_ddf1h		;e051
	ld bc,00780h		;e054
	add hl,bc		;e057
	ld b,h			;e058
	ld c,l			;e059
	ld hl,(ldde8h)		;e05a
	call lded1h		;e05d
	ld hl,0ff80h		;e060
	ld (0ffd5h),hl		;e063
	ld a,(0ffdbh)		;e066
	cp 000h			;e069
	jp z,lde53h		;e06b
	ld hl,(0ffd2h)		;e06e
	call sub_dea1h		;e071
	ld b,h			;e074
	ld c,l			;e075
	ld de,lf50ah		;e076
	add hl,de		;e079
	ld (ldde8h),hl		;e07a
	ld de,0fff6h		;e07d
	add hl,de		;e080
	ex de,hl		;e081
	ld h,b			;e082
	ld l,c			;e083
	call sub_ddf1h		;e084
	ld bc,000f0h		;e087
	add hl,bc		;e08a
	ld b,h			;e08b
	ld c,l			;e08c
	ld hl,(ldde8h)		;e08d
	call lded1h		;e090
	ld hl,lf5f0h		;e093
	ld (0ffdch),hl		;e096
	jp lde53h		;e099
	ld hl,(0ffd2h)		;e09c
	ld de,biosdata_end	;e09f
	add hl,de		;e0a2
	ld (0ffd5h),hl		;e0a3
	call sub_ddf1h		;e0a6
	ld de,0ff80h		;e0a9
	add hl,de		;e0ac
	ld b,h			;e0ad
	ld c,l			;e0ae
	ld hl,0ff7fh		;e0af
	ld de,0ffcfh		;e0b2
	call sub_dedfh		;e0b5
	ld a,(0ffdbh)		;e0b8
	cp 000h			;e0bb
	jp z,lde53h		;e0bd
	ld hl,(0ffd2h)		;e0c0
	call sub_dea1h		;e0c3
	ld de,lf500h		;e0c6
	add hl,de		;e0c9
	ld (0ffdch),hl		;e0ca
	call sub_ddf1h		;e0cd
	ld de,lf5f0h		;e0d0
	add hl,de		;e0d3
	ld b,h			;e0d4
	ld c,l			;e0d5
	ld hl,lf5efh		;e0d6
	ld de,lf5f9h		;e0d9
	call sub_dedfh		;e0dc
	jp lde53h		;e0df
	ld a,002h		;e0e2
	ld (0ffdbh),a		;e0e4
	ret			;e0e7
	ld a,001h		;e0e8
	ld (0ffdbh),a		;e0ea
	ret			;e0ed
	ld hl,biosdata_end	;e0ee
	ld de,lf500h		;e0f1
	ld b,0fah		;e0f4
le0f6h:
	ld a,(de)		;e0f6
	ld c,008h		;e0f7
	cp 000h			;e0f9
	jp nz,le108h		;e0fb
le0feh:
	ld (hl),020h		;e0fe
	inc hl			;e100
	dec c			;e101
	jp nz,le0feh		;e102
	jp le113h		;e105
le108h:
	rra			;e108
	jp c,le10eh		;e109
	ld (hl),020h		;e10c
le10eh:
	inc hl			;e10e
	dec c			;e10f
	jp nz,le108h		;e110
le113h:
	inc de			;e113
	dec b			;e114
	jp nz,le0f6h		;e115
	ret			;e118
le119h:
	ld sp,hl		;e119
	sbc a,09ch		;e11a
	ret po			;e11c
	ld a,0e0h		;e11d
	ld sp,hl		;e11f
	sbc a,0f9h		;e120
	sbc a,0c3h		;e122
	rst 18h			;e124
	ret p			;e125
	sbc a,0edh		;e126
	sbc a,0c3h		;e128
	rst 18h			;e12a
	dec c			;e12b
	ret po			;e12c
	add hl,de		;e12d
	ret po			;e12e
	ld sp,hl		;e12f
	sbc a,002h		;e130
	rst 18h			;e132
	jp m,0f9deh		;e133
	sbc a,0f9h		;e136
	sbc a,0f9h		;e138
	sbc a,0f9h		;e13a
	sbc a,0f9h		;e13c
	sbc a,0f9h		;e13e
	sbc a,0e2h		;e140
	ret po			;e142
	ret pe			;e143
	ret po			;e144
	xor 0e0h		;e145
	ld sp,hl		;e147
	sbc a,0edh		;e148
	rst 18h			;e14a
	ld sp,hl		;e14b
	sbc a,022h		;e14c
	ret po			;e14e
	ld sp,hl		;e14f
	sbc a,0f9h		;e150
	sbc a,038h		;e152
	ret po			;e154
	dec l			;e155
	rst 18h			;e156
	ld a,d			;e157
	rst 18h			;e158
sub_e159h:
	ld a,000h		;e159
	ld (0ffd7h),a		;e15b
	ld a,(0ffdah)		;e15e
	rlca			;e161
	and 03eh		;e162
	ld c,a			;e164
	ld b,000h		;e165
	ld hl,le119h		;e167
	add hl,bc		;e16a
	ld e,(hl)		;e16b
	inc hl			;e16c
	ld d,(hl)		;e16d
	ex de,hl		;e16e
	jp (hl)			;e16f
sub_e170h:
	ld a,(0ffdah)		;e170
	and 07fh		;e173
	sub 020h		;e175
	ld hl,0ffd7h		;e177
	dec (hl)		;e17a
	jp z,le182h		;e17b
	ld (0ffdeh),a		;e17e
	ret			;e181
le182h:
	ld d,a			;e182
	ld a,(0ffdeh)		;e183
	ld h,a			;e186
	ld a,(jumptable_end)	;e187
	or a			;e18a
	jp z,le18fh		;e18b
	ex de,hl		;e18e
le18fh:
	ld a,h			;e18f
	ld b,050h		;e190
	call lde4dh		;e192
	ld (0ffd1h),a		;e195
	ld a,d			;e198
	ld b,019h		;e199
	call lde4dh		;e19b
	ld (0ffd4h),a		;e19e
	or a			;e1a1
	jp z,lde0ch		;e1a2
	ld hl,(0ffd2h)		;e1a5
	ld de,00050h		;e1a8
le1abh:
	add hl,de		;e1ab
	dec a			;e1ac
	jp nz,le1abh		;e1ad
	ld (0ffd2h),hl		;e1b0
	jp lde0ch		;e1b3
sub_e1b6h:
	ld hl,(0ffd2h)		;e1b6
	ld d,000h		;e1b9
	ld a,(0ffd1h)		;e1bb
	ld e,a			;e1be
	add hl,de		;e1bf
	ld (0ffd8h),hl		;e1c0
	ld a,(0ffdah)		;e1c3
	cp 0c0h			;e1c6
	jp c,le1cdh		;e1c8
	sub 0c0h		;e1cb
le1cdh:
	ld c,a			;e1cd
	cp 080h			;e1ce
	jp c,le1dch		;e1d0
	and 004h		;e1d3
	ld (ldde7h),a		;e1d5
	ld a,c			;e1d8
	jp le1e2h		;e1d9
le1dch:
	ld hl,lf680h		;e1dc
	call sub_de01h		;e1df
le1e2h:
	ld hl,(0ffd8h)		;e1e2
	ld de,biosdata_end	;e1e5
	add hl,de		;e1e8
	ld (hl),a		;e1e9
	call sub_dfedh		;e1ea
	ld a,(0ffdbh)		;e1ed
	cp 002h			;e1f0
	ret nz			;e1f2
	ld hl,(0ffd8h)		;e1f3
	call sub_dea1h		;e1f6
	ld de,lf500h		;e1f9
	add hl,de		;e1fc
	cp 000h			;e1fd
	ld b,a			;e1ff
	ld a,001h		;e200
	jp nz,le208h		;e202
	or (hl)			;e205
	ld (hl),a		;e206
	ret			;e207
le208h:
	rlca			;e208
CONOUT_ENTRY:
	dec b			;e209
	jp nz,le208h		;e20a
	or (hl)			;e20d
	ld (hl),a		;e20e
	ret			;e20f
le210h:
	di			;e210
	push hl			;e211
	ld hl,00000h		;e212
	add hl,sp		;e215
	ld sp,lf680h		;e216
	ei			;e219
	push hl			;e21a
	push af			;e21b
	push bc			;e21c
	push de			;e21d
	ld a,c			;e21e
	ld (0ffdah),a		;e21f
	ld a,(0ffd7h)		;e222
	or a			;e225
	jp z,le22fh		;e226
	call sub_e170h		;e229
	jp le240h		;e22c
le22fh:
	ld a,(0ffdah)		;e22f
	cp 020h			;e232
	jp nc,le23dh		;e234
	call sub_e159h		;e237
	jp le240h		;e23a
le23dh:
	call sub_e1b6h		;e23d
le240h:
	pop de			;e240
	pop bc			;e241
DSPITR:
	pop af			;e242
	pop hl			;e243
	di			;e244
	ld sp,hl		;e245
	pop hl			;e246
	ei			;e247
	ret			;e248
	ld (lf363h),sp		;e249
	ld sp,lf620h		;e24d
	push af			;e250
	push bc			;e251
	push de			;e252
	push hl			;e253
	in a,(001h)		;e254
	ld a,006h		;e256
	out (0fah),a		;e258
	ld a,007h		;e25a
	out (0fah),a		;e25c
	out (0fch),a		;e25e
	ld hl,biosdata_end	;e260
	ld a,l			;e263
	out (0f4h),a		;e264
	ld a,h			;e266
	out (0f4h),a		;e267
	ld hl,007cfh		;e269
	ld a,l			;e26c
	out (0f5h),a		;e26d
	ld a,h			;e26f
	out (0f5h),a		;e270
	ld a,000h		;e272
	out (0f7h),a		;e274
	out (0f7h),a		;e276
	ld a,002h		;e278
	out (0fah),a		;e27a
	ld a,003h		;e27c
	out (0fah),a		;e27e
	ld a,0d7h		;e280
	out (00eh),a		;e282
	ld a,001h		;e284
	out (00eh),a		;e286
	ld hl,0fffch		;e288
	inc (hl)		;e28b
	jp nz,le29bh		;e28c
	inc hl			;e28f
	inc (hl)		;e290
	jp nz,le29bh		;e291
	inc hl			;e294
	inc (hl)		;e295
	jp nz,le29bh		;e296
	inc hl			;e299
	inc (hl)		;e29a
le29bh:
	ld hl,(0ffdfh)		;e29b
	ld a,l			;e29e
	or h			;e29f
	jp z,le2ach		;e2a0
	dec hl			;e2a3
	ld a,l			;e2a4
	or h			;e2a5
	ld (0ffdfh),hl		;e2a6
	call z,0ffe5h		;e2a9
le2ach:
	ld hl,(0ffe1h)		;e2ac
	ld a,l			;e2af
	or h			;e2b0
	jp z,le2bdh		;e2b1
	dec hl			;e2b4
	ld a,l			;e2b5
	or h			;e2b6
	ld (0ffe1h),hl		;e2b7
	call z,sub_e649h	;e2ba
le2bdh:
	ld hl,(0ffe3h)		;e2bd
	ld a,l			;e2c0
	or h			;e2c1
	jp z,le2c9h		;e2c2
	dec hl			;e2c5
	ld (0ffe3h),hl		;e2c6
le2c9h:
	pop hl			;e2c9
	pop de			;e2ca
	pop bc			;e2cb
	pop af			;e2cc
displaycode_end:
SELDSK_ENTRY:

; BLOCK 'diskcode' (start 0xe2cd end 0xebe8)
diskcode_start:
	ld sp,(lf363h)		;e2cd
	ei			;e2d1
	reti			;e2d2
le2d4h:
	ld hl,00000h		;e2d4
	add hl,sp		;e2d7
	ld sp,lf680h		;e2d8
	push hl			;e2db
	ld hl,00000h		;e2dc
	ld a,(lf350h)		;e2df
	cp c			;e2e2
	jp c,le36bh		;e2e3
	ld a,c			;e2e6
	ld (lf32eh),a		;e2e7
	ld bc,00010h		;e2ea
	ld de,lda37h		;e2ed
	ld hl,00000h		;e2f0
le2f3h:
	or a			;e2f3
	jp z,le2fdh		;e2f4
	inc de			;e2f7
	add hl,bc		;e2f8
	dec a			;e2f9
	jp le2f3h		;e2fa
le2fdh:
	ld c,l			;e2fd
	ld b,h			;e2fe
	ex de,hl		;e2ff
	ld a,(hl)		;e300
	ld hl,lf34eh		;e301
	cp (hl)			;e304
	jp z,le317h		;e305
	push af			;e308
	push bc			;e309
	ld a,(lf33eh)		;e30a
	or a			;e30d
	call nz,sub_e515h	;e30e
	xor a			;e311
	ld (lf33eh),a		;e312
	pop bc			;e315
	pop af			;e316
le317h:
	ld (lf34eh),a		;e317
	call sub_e370h		;e31a
	ld (lf34ch),hl		;e31d
	inc hl			;e320
	inc hl			;e321
	inc hl			;e322
	inc hl			;e323
	ld a,(hl)		;e324
	ld (lf34fh),a		;e325
	push bc			;e328
	ld a,(lf34eh)		;e329
	and 0f8h		;e32c
	or a			;e32e
	rla			;e32f
	ld e,a			;e330
	ld d,000h		;e331
	ld hl,lea9ch		;e333
	add hl,de		;e336
	ld de,lf36ah		;e337
	ld bc,00010h		;e33a
	ldir			;e33d
	ld hl,(lf36ah)		;e33f
	ld bc,0000dh		;e342
	add hl,bc		;e345
	ex de,hl		;e346
	ld hl,lea8ch		;e347
	ld b,000h		;e34a
	ld a,(lf32eh)		;e34c
	ld c,a			;e34f
	add hl,bc		;e350
	add hl,bc		;e351
	ld bc,00002h		;e352
	ldir			;e355
	pop bc			;e357
	ld hl,leb74h		;e358
	add hl,bc		;e35b
	ex de,hl		;e35c
	ld hl,0000ah		;e35d
	add hl,de		;e360
	ex de,hl		;e361
	ld a,(lf36ah)		;e362
	ld (de),a		;e365
	inc de			;e366
	ld a,(lf36bh)		;e367
	ld (de),a		;e36a
le36bh:
	ex de,hl		;e36b
	pop hl			;e36c
	ld sp,hl		;e36d
	ex de,hl		;e36e
	ret			;e36f
sub_e370h:
	ld hl,0eb2dh		;e370
	ld a,(lf34eh)		;e373
SETTRK_ENTRY:
	and 0f8h		;e376
	ld e,a			;e378
	ld d,000h		;e379
	add hl,de		;e37b
SETSEC_ENTRY:
	ret			;e37c
le37dh:
	ld h,b			;e37d
	ld l,c			;e37e
	ld (lf32fh),hl		;e37f
SETDMA_ENTRY:
	ret			;e382
le383h:
	ld l,c			;e383
	ld h,b			;e384
	ld (lf331h),hl		;e385
SECTRAN_ENTRY:
	ret			;e388
le389h:
	ld h,b			;e389
	ld l,c			;e38a
READ_ENTRY:
	ld (lf34ah),hl		;e38b
	ret			;e38e
le38fh:
	ld h,b			;e38f
	ld l,c			;e390
	ret			;e391
le392h:
	xor a			;e392
	ld (lf33fh),a		;e393
	ld a,001h		;e396
	ld (lf348h),a		;e398
	ld (lf347h),a		;e39b
	ld a,002h		;e39e
	ld (lf349h),a		;e3a0
	jp le441h		;e3a3
le3a6h:
	xor a			;e3a6
	ld (lf348h),a		;e3a7
	ld a,c			;e3aa
	ld (lf349h),a		;e3ab
	cp 002h			;e3ae
	jp nz,le3cbh		;e3b0
	ld a,(lf36ch)		;e3b3
	ld (lf33fh),a		;e3b6
	ld a,(lf32eh)		;e3b9
	ld (lf340h),a		;e3bc
	ld hl,(lf32fh)		;e3bf
	ld (lf341h),hl		;e3c2
	ld hl,(lf331h)		;e3c5
	ld (lf343h),hl		;e3c8
le3cbh:
	ld a,(lf33fh)		;e3cb
	or a			;e3ce
	jp z,le437h		;e3cf
	dec a			;e3d2
	ld (lf33fh),a		;e3d3
	ld a,(lf32eh)		;e3d6
	ld hl,lf340h		;e3d9
	cp (hl)			;e3dc
	jp nz,le437h		;e3dd
	ld hl,lf341h		;e3e0
	call sub_e509h		;e3e3
	jp nz,le437h		;e3e6
	ld a,(lf331h)		;e3e9
	ld hl,lf343h		;e3ec
	cp (hl)			;e3ef
	jp nz,le437h		;e3f0
	ld a,(lf332h)		;e3f3
	inc hl			;e3f6
	cp (hl)			;e3f7
	jp nz,le437h		;e3f8
	ld hl,(lf343h)		;e3fb
	inc hl			;e3fe
	ld (lf343h),hl		;e3ff
	ex de,hl		;e402
	ld hl,lf36dh		;e403
	push bc			;e406
	ld c,(hl)		;e407
	inc hl			;e408
	ld b,(hl)		;e409
	ex de,hl		;e40a
	and a			;e40b
	sbc hl,bc		;e40c
	pop bc			;e40e
	jp c,le41fh		;e40f
	ld hl,00000h		;e412
	ld (lf343h),hl		;e415
	ld hl,(lf341h)		;e418
	inc hl			;e41b
	ld (lf341h),hl		;e41c
le41fh:
	xor a			;e41f
	ld (lf347h),a		;e420
	ld a,(lf331h)		;e423
	ld hl,lf36fh		;e426
	and (hl)		;e429
	cp (hl)			;e42a
	ld a,000h		;e42b
	jp nz,le431h		;e42d
	inc a			;e430
le431h:
	ld (lf345h),a		;e431
	jp le441h		;e434
le437h:
	xor a			;e437
	ld (lf33fh),a		;e438
	ld a,(lf36fh)		;e43b
	ld (lf347h),a		;e43e
le441h:
	ld hl,00000h		;e441
	add hl,sp		;e444
	ld sp,lf680h		;e445
	push hl			;e448
	ld a,(lf370h)		;e449
	ld b,a			;e44c
	ld hl,(lf331h)		;e44d
le450h:
	dec b			;e450
	jp z,le45bh		;e451
	srl h			;e454
	rr l			;e456
	jp le450h		;e458
le45bh:
	ld (lf33bh),hl		;e45b
	ld hl,lf33dh		;e45e
	ld a,(hl)		;e461
	ld (hl),001h		;e462
	or a			;e464
	jp z,le494h		;e465
	ld a,(lf32eh)		;e468
	ld hl,lf333h		;e46b
	cp (hl)			;e46e
	jp nz,le48dh		;e46f
	ld hl,lf334h		;e472
	call sub_e509h		;e475
	jp nz,le48dh		;e478
	ld a,(lf33bh)		;e47b
	ld hl,lf336h		;e47e
	cp (hl)			;e481
	jp nz,le48dh		;e482
	ld a,(lf33ch)		;e485
	inc hl			;e488
	cp (hl)			;e489
	jp z,le4b1h		;e48a
le48dh:
	ld a,(lf33eh)		;e48d
	or a			;e490
	call nz,sub_e515h	;e491
le494h:
	ld a,(lf32eh)		;e494
	ld (lf333h),a		;e497
	ld hl,(lf32fh)		;e49a
	ld (lf334h),hl		;e49d
	ld hl,(lf33bh)		;e4a0
	ld (lf336h),hl		;e4a3
	ld a,(lf347h)		;e4a6
	or a			;e4a9
	call nz,sub_e522h	;e4aa
	xor a			;e4ad
	ld (lf33eh),a		;e4ae
le4b1h:
	ld a,(lf331h)		;e4b1
	ld hl,lf36fh		;e4b4
	and (hl)		;e4b7
	ld l,a			;e4b8
	ld h,000h		;e4b9
	add hl,hl		;e4bb
	add hl,hl		;e4bc
	add hl,hl		;e4bd
	add hl,hl		;e4be
	add hl,hl		;e4bf
	add hl,hl		;e4c0
	add hl,hl		;e4c1
	ld de,lee81h		;e4c2
	add hl,de		;e4c5
	ex de,hl		;e4c6
	ld hl,(lf34ah)		;e4c7
	ld bc,00080h		;e4ca
	ex de,hl		;e4cd
	ld a,(lf348h)		;e4ce
	or a			;e4d1
	jp nz,le4dbh		;e4d2
	ld a,001h		;e4d5
	ld (lf33eh),a		;e4d7
	ex de,hl		;e4da
le4dbh:
	ldir			;e4db
	ld a,(lf349h)		;e4dd
	cp 001h			;e4e0
	ld hl,lf346h		;e4e2
	ld a,(hl)		;e4e5
	push af			;e4e6
	or a			;e4e7
	jp z,le4efh		;e4e8
	xor a			;e4eb
	ld (lf33dh),a		;e4ec
le4efh:
	pop af			;e4ef
	ld (hl),000h		;e4f0
	jp nz,le506h		;e4f2
	or a			;e4f5
	jp nz,le506h		;e4f6
	xor a			;e4f9
	ld (lf33eh),a		;e4fa
	call sub_e515h		;e4fd
	ld hl,lf346h		;e500
	ld a,(hl)		;e503
	ld (hl),000h		;e504
le506h:
	pop hl			;e506
	ld sp,hl		;e507
	ret			;e508
sub_e509h:
	ex de,hl		;e509
	ld hl,lf32fh		;e50a
	ld a,(de)		;e50d
	cp (hl)			;e50e
	ret nz			;e50f
	inc de			;e510
	inc hl			;e511
	ld a,(de)		;e512
	cp (hl)			;e513
	ret			;e514
sub_e515h:
	ld a,(lf374h)		;e515
	or a			;e518
	jp nz,le80ch		;e519
	call sub_e539h		;e51c
	jp le601h		;e51f
sub_e522h:
	ld a,(lf345h)		;e522
	or a			;e525
	jp nz,le52ch		;e526
	ld (lf33fh),a		;e529
le52ch:
	ld a,(lf374h)		;e52c
	or a			;e52f
	jp nz,le827h		;e530
	call sub_e539h		;e533
	jp le5b7h		;e536
sub_e539h:
	ld a,(lf336h)		;e539
	ld c,a			;e53c
	ld a,(lf34fh)		;e53d
	ld b,a			;e540
	dec a			;e541
	cp c			;e542
	ld a,(lf333h)		;e543
	jp nc,le554h		;e546
	or 004h			;e549
	ld (lf351h),a		;e54b
	ld a,c			;e54e
	sub b			;e54f
	ld c,a			;e550
	jp le557h		;e551
le554h:
	ld (lf351h),a		;e554
le557h:
	ld b,000h		;e557
	ld hl,(lf371h)		;e559
	add hl,bc		;e55c
	ld a,(hl)		;e55d
	ld (lf355h),a		;e55e
	ld a,(lf334h)		;e561
	ld (lf354h),a		;e564
	ld hl,lee81h		;e567
	ld (lf352h),hl		;e56a
	ld a,(lf333h)		;e56d
	ld hl,lf338h		;e570
	cp (hl)			;e573
	jp nz,le587h		;e574
	ld a,(lf334h)		;e577
	ld hl,lf339h		;e57a
	cp (hl)			;e57d
	jp nz,le587h		;e57e
	ld a,(lf335h)		;e581
	inc hl			;e584
	cp (hl)			;e585
	ret z			;e586
le587h:
	ld a,(lf333h)		;e587
	ld (lf338h),a		;e58a
	ld hl,(lf334h)		;e58d
	ld (lf339h),hl		;e590
	call WFITR_ENTRY	;e593
	call sub_e70fh		;e596
	call le74ch		;e599
	ld a,(lf351h)		;e59c
	and 003h		;e59f
	add a,020h		;e5a1
	cp b			;e5a3
	ret z			;e5a4
sub_e5a5h:
	call WFITR_ENTRY	;e5a5
	call sub_e6c6h		;e5a8
	push bc			;e5ab
	call le74ch		;e5ac
	call sub_e70fh		;e5af
	call le74ch		;e5b2
	pop bc			;e5b5
	ret			;e5b6
le5b7h:
	ld a,00ah		;e5b7
	ld (lf356h),a		;e5b9
le5bch:
	call sub_e62bh		;e5bc
	call WFITR_ENTRY	;e5bf
	ld hl,(lf34ch)		;e5c2
	ld c,(hl)		;e5c5
	inc hl			;e5c6
	ld b,(hl)		;e5c7
	inc hl			;e5c8
	call sub_e784h		;e5c9
	call sub_e621h		;e5cc
	call sub_e75bh		;e5cf
	ld c,000h		;e5d2
le5d4h:
	ld hl,lf357h		;e5d4
	ld a,(hl)		;e5d7
	and 0f8h		;e5d8
	ret z			;e5da
	and 008h		;e5db
	jp nz,le5f7h		;e5dd
	ld a,(lf356h)		;e5e0
	dec a			;e5e3
	ld (lf356h),a		;e5e4
	jp z,le5f7h		;e5e7
	cp 005h			;e5ea
	call z,sub_e5a5h	;e5ec
	xor a			;e5ef
	cp c			;e5f0
	jp z,le5bch		;e5f1
	jp le606h		;e5f4
le5f7h:
	ld a,c			;e5f7
	ld (lf33dh),a		;e5f8
	ld a,001h		;e5fb
	ld (lf346h),a		;e5fd
	ret			;e600
le601h:
	ld a,00ah		;e601
	ld (lf356h),a		;e603
le606h:
	call sub_e62bh		;e606
	call WFITR_ENTRY	;e609
	ld hl,(lf34ch)		;e60c
	ld c,(hl)		;e60f
	inc hl			;e610
	ld b,(hl)		;e611
	inc hl			;e612
	call sub_e763h		;e613
	call sub_e626h		;e616
	call sub_e75bh		;e619
	ld c,001h		;e61c
	jp le5d4h		;e61e
sub_e621h:
	ld a,006h		;e621
	jp le78eh		;e623
sub_e626h:
	ld a,005h		;e626
	jp le78eh		;e628
sub_e62bh:
	in a,(014h)		;e62b
	and 080h		;e62d
	ret z			;e62f
	di			;e630
	ld hl,(0ffe1h)		;e631
	ld a,l			;e634
	or h			;e635
	ld hl,(0ffe7h)		;e636
	ld (0ffe1h),hl		;e639
	ei			;e63c
	ret nz			;e63d
	ld a,001h		;e63e
	out (014h),a		;e640
	ld hl,00032h		;e642
	call sub_e653h		;e645
	ret			;e648
sub_e649h:
	in a,(014h)		;e649
	and 080h		;e64b
	ret z			;e64d
	ld a,000h		;e64e
	out (014h),a		;e650
	ret			;e652
sub_e653h:
	ld (0ffe3h),hl		;e653
le656h:
	ld hl,(0ffe3h)		;e656
	ld a,l			;e659
	or h			;e65a
	jp nz,le656h		;e65b
	ret			;e65e
le65fh:
	ld a,(lf33eh)		;e65f
	or a			;e662
	jr nz,le668h		;e663
	ld (lf33dh),a		;e665
le668h:
	ld a,(lf374h)		;e668
	and a			;e66b
	jp z,le695h		;e66c
	ld a,(lf32eh)		;e66f
	ld (lf338h),a		;e672
	ld hl,(lf36ah)		;e675
	ld de,0000dh		;e678
	add hl,de		;e67b
	ld e,(hl)		;e67c
	inc hl			;e67d
	ld d,(hl)		;e67e
	ld (lf339h),de		;e67f
	call sub_e887h		;e683
	call sub_e8cfh		;e686
	ret nc			;e689
	call sub_e8f1h		;e68a
le68dh:
	in a,(067h)		;e68d
	and 010h		;e68f
	jp z,le68dh		;e691
	ret			;e694
le695h:
	call sub_e62bh		;e695
	ld a,(lf32eh)		;e698
	ld (lf351h),a		;e69b
	ld (lf338h),a		;e69e
	xor a			;e6a1
	ld (lf339h),a		;e6a2
	ld (lf33ah),a		;e6a5
	call WFITR_ENTRY	;e6a8
	call sub_e6c6h		;e6ab
	call le74ch		;e6ae
	ret			;e6b1
le6b2h:
	in a,(004h)		;e6b2
	and 0c0h		;e6b4
	cp 080h			;e6b6
	jp nz,le6b2h		;e6b8
	ret			;e6bb
le6bch:
	in a,(004h)		;e6bc
	and 0c0h		;e6be
	cp 0c0h			;e6c0
	jp nz,le6bch		;e6c2
	ret			;e6c5
sub_e6c6h:
	call le6b2h		;e6c6
	ld a,007h		;e6c9
	out (005h),a		;e6cb
	call le6b2h		;e6cd
	ld a,(lf351h)		;e6d0
	and 003h		;e6d3
	out (005h),a		;e6d5
	ret			;e6d7
	call le6b2h		;e6d8
	ld a,004h		;e6db
	out (005h),a		;e6dd
	call le6b2h		;e6df
	ld a,(lf351h)		;e6e2
	and 003h		;e6e5
	out (005h),a		;e6e7
	call le6bch		;e6e9
	in a,(005h)		;e6ec
	ld (lf357h),a		;e6ee
	ret			;e6f1
sub_e6f2h:
	call le6b2h		;e6f2
	ld a,008h		;e6f5
	out (005h),a		;e6f7
	call le6bch		;e6f9
	in a,(005h)		;e6fc
	ld (lf357h),a		;e6fe
	and 0c0h		;e701
	cp 080h			;e703
	ret z			;e705
	call le6bch		;e706
	in a,(005h)		;e709
	ld (lf358h),a		;e70b
	ret			;e70e
sub_e70fh:
	call le6b2h		;e70f
	ld a,00fh		;e712
	out (005h),a		;e714
	call le6b2h		;e716
	ld a,(lf351h)		;e719
	and 003h		;e71c
	out (005h),a		;e71e
	call le6b2h		;e720
	ld a,(lf354h)		;e723
	out (005h),a		;e726
	ret			;e728
sub_e729h:
	ld hl,lf357h		;e729
	ld d,007h		;e72c
le72eh:
	call le6bch		;e72e
	in a,(005h)		;e731
	ld (hl),a		;e733
	inc hl			;e734
	ld a,004h		;e735
le737h:
	dec a			;e737
	jp nz,le737h		;e738
	in a,(004h)		;e73b
	and 010h		;e73d
	ret z			;e73f
	dec d			;e740
	jp nz,le72eh		;e741
	ret			;e744
WFITR_ENTRY:
	di			;e745
	xor a			;e746
	ld (lf367h),a		;e747
	ei			;e74a
	ret			;e74b
le74ch:
	call sub_e75bh		;e74c
	ld a,(lf357h)		;e74f
	ld b,a			;e752
	ld a,(lf358h)		;e753
	ld c,a			;e756
	call WFITR_ENTRY	;e757
	ret			;e75a
sub_e75bh:
	ld a,(lf367h)		;e75b
	or a			;e75e
	jp z,sub_e75bh		;e75f
	ret			;e762
sub_e763h:
	ld a,005h		;e763
	di			;e765
	out (0fah),a		;e766
	ld a,049h		;e768
le76ah:
	out (0fbh),a		;e76a
	out (0fch),a		;e76c
	ld a,(lf352h)		;e76e
	out (0f2h),a		;e771
	ld a,(lf353h)		;e773
	out (0f2h),a		;e776
	ld a,c			;e778
	out (0f3h),a		;e779
	ld a,b			;e77b
	out (0f3h),a		;e77c
	ld a,001h		;e77e
	out (0fah),a		;e780
	ei			;e782
	ret			;e783
sub_e784h:
	ld a,005h		;e784
	di			;e786
	out (0fah),a		;e787
	ld a,045h		;e789
	jp le76ah		;e78b
le78eh:
	push af			;e78e
	di			;e78f
	call le6b2h		;e790
	pop af			;e793
	ld b,(hl)		;e794
	inc hl			;e795
	add a,b			;e796
	out (005h),a		;e797
	call le6b2h		;e799
	ld a,(lf351h)		;e79c
	out (005h),a		;e79f
	call le6b2h		;e7a1
	ld a,(lf354h)		;e7a4
	out (005h),a		;e7a7
	call le6b2h		;e7a9
	ld a,(lf351h)		;e7ac
	rra			;e7af
	rra			;e7b0
	and 003h		;e7b1
	out (005h),a		;e7b3
	call le6b2h		;e7b5
	ld a,(lf355h)		;e7b8
	out (005h),a		;e7bb
	call le6b2h		;e7bd
	ld a,(hl)		;e7c0
	inc hl			;e7c1
	out (005h),a		;e7c2
	call le6b2h		;e7c4
	ld a,(hl)		;e7c7
	inc hl			;e7c8
	out (005h),a		;e7c9
	call le6b2h		;e7cb
	ld a,(hl)		;e7ce
	out (005h),a		;e7cf
	call le6b2h		;e7d1
FLITR:
	ld a,(lf373h)		;e7d4
	out (005h),a		;e7d7
	ei			;e7d9
	ret			;e7da
	ld (lf363h),sp		;e7db
	ld sp,lf620h		;e7df
	push af			;e7e2
	push bc			;e7e3
	push de			;e7e4
	push hl			;e7e5
	ld a,0ffh		;e7e6
	ld (lf367h),a		;e7e8
	ld a,005h		;e7eb
le7edh:
	dec a			;e7ed
	jp nz,le7edh		;e7ee
	in a,(004h)		;e7f1
	and 010h		;e7f3
	jp nz,le7feh		;e7f5
	call sub_e6f2h		;e7f8
	jp le801h		;e7fb
le7feh:
	call sub_e729h		;e7fe
le801h:
	pop hl			;e801
	pop de			;e802
	pop bc			;e803
	pop af			;e804
	ld sp,(lf363h)		;e805
	ei			;e809
	reti			;e80a
le80ch:
	call sub_e842h		;e80c
	call nc,sub_e887h	;e80f
	call sub_e8fdh		;e812
	ret nc			;e815
	ld hl,(lf34ch)		;e816
	ld c,(hl)		;e819
	inc hl			;e81a
	ld b,(hl)		;e81b
	call sub_e91ch		;e81c
	ld a,030h		;e81f
	out (067h),a		;e821
	call sub_e8f1h		;e823
	ret			;e826
le827h:
	call sub_e842h		;e827
	call nc,sub_e887h	;e82a
	call sub_e8fdh		;e82d
	ret nc			;e830
	ld hl,(lf34ch)		;e831
	ld c,(hl)		;e834
	inc hl			;e835
	ld b,(hl)		;e836
	call sub_e912h		;e837
	ld a,028h		;e83a
	out (067h),a		;e83c
	call sub_e8f1h		;e83e
	ret			;e841
sub_e842h:
	ld hl,lee81h		;e842
	ld (lf352h),hl		;e845
	ld a,(lf333h)		;e848
	ld hl,lf338h		;e84b
	cp (hl)			;e84e
	jp nz,le866h		;e84f
	ld a,(lf334h)		;e852
	ld hl,lf339h		;e855
	cp (hl)			;e858
	jp nz,le866h		;e859
	ld a,(lf335h)		;e85c
	inc hl			;e85f
	cp (hl)			;e860
	jp nz,le866h		;e861
	and a			;e864
	ret			;e865
le866h:
	ld a,(lf333h)		;e866
	ld (lf338h),a		;e869
	ld hl,(lf334h)		;e86c
	ld (lf339h),hl		;e86f
	call sub_e887h		;e872
	call sub_e8cfh		;e875
	jp nc,le885h		;e878
	call sub_e8f1h		;e87b
le87eh:
	in a,(067h)		;e87e
	and 010h		;e880
	jp z,le87eh		;e882
le885h:
	scf			;e885
	ret			;e886
sub_e887h:
	ld hl,(lf34ch)		;e887
	ld de,0ffffh		;e88a
	ex de,hl		;e88d
	add hl,de		;e88e
	xor a			;e88f
	ld c,(hl)		;e890
	ld b,000h		;e891
	ld hl,(lf336h)		;e893
le896h:
	and a			;e896
	sbc hl,bc		;e897
	jp c,le8a0h		;e899
	inc a			;e89c
	jp le896h		;e89d
le8a0h:
	add hl,bc		;e8a0
	ld c,a			;e8a1
	ld a,l			;e8a2
	out (063h),a		;e8a3
	ld hl,(lf339h)		;e8a5
	ld a,h			;e8a8
	or l			;e8a9
	jr z,le8b4h		;e8aa
	ld a,(lf369h)		;e8ac
	or a			;e8af
	jr z,le8b4h		;e8b0
	set 7,c			;e8b2
le8b4h:
	ld a,c			;e8b4
	ld hl,00005h		;e8b5
	add hl,de		;e8b8
	or (hl)			;e8b9
	out (066h),a		;e8ba
	ld hl,(lf339h)		;e8bc
	ld a,l			;e8bf
	out (064h),a		;e8c0
	ld a,h			;e8c2
	and 003h		;e8c3
	out (065h),a		;e8c5
	ld hl,00006h		;e8c7
	add hl,de		;e8ca
	ld a,(hl)		;e8cb
	out (061h),a		;e8cc
	ret			;e8ce
sub_e8cfh:
	ld hl,(lf34ch)		;e8cf
	ld de,00005h		;e8d2
	add hl,de		;e8d5
	ld a,070h		;e8d6
	or (hl)			;e8d8
	call sub_e8fdh		;e8d9
	ret nc			;e8dc
	out (067h),a		;e8dd
	scf			;e8df
	ret			;e8e0
	call sub_e8f1h		;e8e1
	push hl			;e8e4
	ld hl,lf346h		;e8e5
	ld a,(hl)		;e8e8
	ld (hl),000h		;e8e9
	pop hl			;e8eb
	ld bc,(lf35fh)		;e8ec
	ret			;e8f0
sub_e8f1h:
	ld a,(lf365h)		;e8f1
	or a			;e8f4
	jp z,sub_e8f1h		;e8f5
	xor a			;e8f8
	ld (lf365h),a		;e8f9
	ret			;e8fc
sub_e8fdh:
	push af			;e8fd
	in a,(067h)		;e8fe
	and 050h		;e900
	cp 050h			;e902
	jp z,le90fh		;e904
	ld a,0bbh		;e907
	ld (lf346h),a		;e909
	pop af			;e90c
	and a			;e90d
	ret			;e90e
le90fh:
	pop af			;e90f
	scf			;e910
	ret			;e911
sub_e912h:
	ld a,004h		;e912
	di			;e914
	out (0fah),a		;e915
	ld a,044h		;e917
	jp le923h		;e919
sub_e91ch:
	ld a,004h		;e91c
	di			;e91e
	out (0fah),a		;e91f
	ld a,048h		;e921
le923h:
	out (0fbh),a		;e923
	out (0fch),a		;e925
	ld a,(lf352h)		;e927
	out (0f0h),a		;e92a
	ld a,(lf353h)		;e92c
	out (0f0h),a		;e92f
	ld a,c			;e931
	out (0f1h),a		;e932
	ld a,b			;e934
	out (0f1h),a		;e935
	ld a,000h		;e937
	out (0fah),a		;e939
	ei			;e93b
	ret			;e93c
	out (066h),a		;e93d
	xor a			;e93f
	out (061h),a		;e940
	out (062h),a		;e942
	out (063h),a		;e944
	out (064h),a		;e946
	out (065h),a		;e948
	ld a,010h		;e94a
	or b			;e94c
	out (067h),a		;e94d
	ret			;e94f
le950h:
	out (066h),a		;e950
	ld a,b			;e952
	out (061h),a		;e953
	ld a,c			;e955
	out (062h),a		;e956
	ld a,e			;e958
	out (064h),a		;e959
	ld a,d			;e95b
	out (065h),a		;e95c
	ld hl,(lf34ah)		;e95e
	ld (lf352h),hl		;e961
	call sub_e8fdh		;e964
	jp nc,le97ch		;e967
	ld bc,001ffh		;e96a
	call sub_e91ch		;e96d
	ld a,050h		;e970
	out (067h),a		;e972
	call sub_e8f1h		;e974
	ld a,(lf346h)		;e977
	and a			;e97a
	ret z			;e97b
le97ch:
	xor a			;e97c
	ld (lf346h),a		;e97d
	ld a,001h		;e980
	ret			;e982
	ld (lf363h),sp		;e983
HDITR:
	ld sp,lf620h		;e987
	push af			;e98a
	push bc			;e98b
	push de			;e98c
	push hl			;e98d
	ld a,0ffh		;e98e
	ld (lf365h),a		;e990
	in a,(067h)		;e993
	ld (lf35fh),a		;e995
	and 001h		;e998
	jp z,le9aeh		;e99a
	in a,(061h)		;e99d
	ld (lf360h),a		;e99f
	ld hl,(lf361h)		;e9a2
	inc hl			;e9a5
	ld (lf361h),hl		;e9a6
	ld a,0bbh		;e9a9
	ld (lf346h),a		;e9ab
le9aeh:
	pop hl			;e9ae
	pop de			;e9af
	pop bc			;e9b0
	pop af			;e9b1
	ld sp,(lf363h)		;e9b2
	ei			;e9b6
	reti			;e9b7
	ld bc,00d07h		;e9b9
	inc de			;e9bc
	add hl,de		;e9bd
	dec b			;e9be
	dec bc			;e9bf
	ld de,00317h		;e9c0
	add hl,bc		;e9c3
	rrca			;e9c4
	dec d			;e9c5
	ld (bc),a		;e9c6
	ex af,af'		;e9c7
	ld c,014h		;e9c8
	ld a,(de)		;e9ca
	ld b,00ch		;e9cb
	ld (de),a		;e9cd
	jr $+6			;e9ce
	ld a,(bc)		;e9d0
	djnz le9e9h		;e9d1
	ld bc,00905h		;e9d3
	dec c			;e9d6
	ld (bc),a		;e9d7
	ld b,00ah		;e9d8
	ld c,003h		;e9da
	rlca			;e9dc
	dec bc			;e9dd
	rrca			;e9de
	inc b			;e9df
	ex af,af'		;e9e0
	inc c			;e9e1
	ld bc,00503h		;e9e2
	rlca			;e9e5
	add hl,bc		;e9e6
	ld (bc),a		;e9e7
	inc b			;e9e8
le9e9h:
	ld b,008h		;e9e9
le9ebh:
	ld bc,00302h		;e9eb
	inc b			;e9ee
	dec b			;e9ef
	ld b,007h		;e9f0
	ex af,af'		;e9f2
	add hl,bc		;e9f3
	ld a,(bc)		;e9f4
	dec bc			;e9f5
	inc c			;e9f6
	dec c			;e9f7
	ld c,00fh		;e9f8
	djnz lea0dh		;e9fa
	ld (de),a		;e9fc
	inc de			;e9fd
	inc d			;e9fe
	dec d			;e9ff
	ld d,017h		;ea00
	jr lea1dh		;ea02
	ld a,(de)		;ea04
	jr nz,lea07h		;ea05
lea07h:
	inc bc			;ea07
	rlca			;ea08
	nop			;ea09
	sub b			;ea0a
	nop			;ea0b
	ccf			;ea0c
lea0dh:
	nop			;ea0d
	ret nz			;ea0e
	nop			;ea0f
	djnz lea12h		;ea10
lea12h:
	nop			;ea12
	nop			;ea13
	ld b,b			;ea14
	nop			;ea15
	inc b			;ea16
	rrca			;ea17
	ld bc,00090h		;ea18
	ld a,a			;ea1b
	nop			;ea1c
lea1dh:
	ret nz			;ea1d
	nop			;ea1e
	jr nz,lea21h		;ea1f
lea21h:
	nop			;ea21
	nop			;ea22
	ld c,b			;ea23
	nop			;ea24
	inc b			;ea25
	rrca			;ea26
	ld bc,00086h		;ea27
	ld a,a			;ea2a
	nop			;ea2b
	ret nz			;ea2c
	nop			;ea2d
	jr nz,lea30h		;ea2e
lea30h:
	ld (bc),a		;ea30
	nop			;ea31
	ld a,b			;ea32
	nop			;ea33
	inc b			;ea34
	rrca			;ea35
	nop			;ea36
	rst 10h			;ea37
	ld bc,0007fh		;ea38
	ret nz			;ea3b
	nop			;ea3c
	jr nz,lea3fh		;ea3d
lea3fh:
	ld (bc),a		;ea3f
	nop			;ea40
	add a,b			;ea41
	ld bc,00f04h		;ea42
	nop			;ea45
	pop bc			;ea46
	ld bc,0007fh		;ea47
	ret nz			;ea4a
	nop			;ea4b
	nop			;ea4c
	nop			;ea4d
	inc bc			;ea4e
	nop			;ea4f
	add a,b			;ea50
	ld bc,00f04h		;ea51
	ld bc,00086h		;ea54
	ld a,a			;ea57
	nop			;ea58
	ret nz			;ea59
	nop			;ea5a
	nop			;ea5b
	nop			;ea5c
	inc bc			;ea5d
	nop			;ea5e
	add a,b			;ea5f
	ld bc,01f05h		;ea60
	ld bc,001ebh		;ea63
	rst 38h			;ea66
	ld bc,000f0h		;ea67
	nop			;ea6a
	nop			;ea6b
	dec de			;ea6c
	nop			;ea6d
	add a,b			;ea6e
	ld bc,03f06h		;ea6f
	inc bc			;ea72
	ex de,hl		;ea73
	ld bc,001ffh		;ea74
	ret nz			;ea77
	nop			;ea78
	nop			;ea79
	nop			;ea7a
	dec de			;ea7b
	nop			;ea7c
	add a,b			;ea7d
	ld bc,07f07h		;ea7e
	rlca			;ea81
	xor 001h		;ea82
	rst 38h			;ea84
	ld bc,00080h		;ea85
	nop			;ea88
	nop			;ea89
	dec de			;ea8a
	nop			;ea8b
lea8ch:
	ld (bc),a		;ea8c
	nop			;ea8d
	ld (bc),a		;ea8e
	nop			;ea8f
	inc bc			;ea90
	nop			;ea91
	rst 38h			;ea92
	rst 38h			;ea93
	rst 38h			;ea94
	rst 38h			;ea95
	rst 38h			;ea96
	rst 38h			;ea97
	rst 38h			;ea98
	rst 38h			;ea99
	rst 38h			;ea9a
	rst 38h			;ea9b
lea9ch:
	dec b			;ea9c
	jp pe,01008h		;ea9d
	nop			;eaa0
	nop			;eaa1
	ld bc,le9ebh		;eaa2
	add a,b			;eaa5
	nop			;eaa6
	dec l			;eaa7
	jr c,leadah		;eaa8
	jr nz,leafch		;eaaa
	inc d			;eaac
	jp pe,02010h		;eaad
	nop			;eab0
	ld bc,0eb02h		;eab1
	jp (hl)			;eab4
	rst 38h			;eab5
	nop			;eab6
	ld b,c			;eab7
	ld b,d			;eab8
	ld c,h			;eab9
	ld b,l			;eaba
	ld d,e			;eabb
	inc hl			;eabc
	jp pe,04810h		;eabd
	nop			;eac0
	inc bc			;eac1
	inc bc			;eac2
	jp po,0ffe9h		;eac3
	nop			;eac6
	ld b,l			;eac7
	ld c,(hl)		;eac8
	ld d,h			;eac9
	ld c,c			;eaca
	ld c,a			;eacb
	ld (010eah),a		;eacc
	ld a,b			;eacf
	nop			;ead0
	inc bc			;ead1
	inc bc			;ead2
	out (0e9h),a		;ead3
	rst 38h			;ead5
	nop			;ead6
	nop			;ead7
	nop			;ead8
	nop			;ead9
leadah:
	nop			;eada
	nop			;eadb
	ld b,c			;eadc
	jp pe,08010h		;eadd
	ld bc,00303h		;eae0
	nop			;eae3
	nop			;eae4
	nop			;eae5
	rst 38h			;eae6
	ld (bc),a		;eae7
	inc b			;eae8
	nop			;eae9
	rst 38h			;eaea
	inc bc			;eaeb
	ld d,b			;eaec
	jp pe,08010h		;eaed
	ld bc,00303h		;eaf0
	nop			;eaf3
	nop			;eaf4
	nop			;eaf5
	rst 38h			;eaf6
	nop			;eaf7
	ld d,a			;eaf8
	ld b,h			;eaf9
	ld b,e			;eafa
	ld b,d			;eafb
leafch:
	ld e,a			;eafc
	jp pe,08020h		;eafd
	ld bc,00303h		;eb00
	nop			;eb03
	nop			;eb04
	nop			;eb05
	rst 38h			;eb06
	nop			;eb07
	nop			;eb08
	nop			;eb09
	nop			;eb0a
	daa			;eb0b
	ld l,(hl)		;eb0c
	jp pe,08040h		;eb0d
	ld bc,00303h		;eb10
	nop			;eb13
	nop			;eb14
	nop			;eb15
	rst 38h			;eb16
	nop			;eb17
	nop			;eb18
	nop			;eb19
	nop			;eb1a
	nop			;eb1b
	ld a,l			;eb1c
	jp pe,08080h		;eb1d
	ld bc,00303h		;eb20
	nop			;eb23
	nop			;eb24
	nop			;eb25
	rst 38h			;eb26
	nop			;eb27
	nop			;eb28
	nop			;eb29
	nop			;eb2a
	nop			;eb2b
	jr nz,lebadh		;eb2c
	nop			;eb2e
	nop			;eb2f
	nop			;eb30
	djnz $+9		;eb31
	inc h			;eb33
	jr nz,$+1		;eb34
	nop			;eb36
	ld b,b			;eb37
	ld bc,00e10h		;eb38
	inc h			;eb3b
	ld (de),a		;eb3c
	rst 38h			;eb3d
	ld bc,00240h		;eb3e
	add hl,bc		;eb41
	dec de			;eb42
	inc h			;eb43
	ld e,0ffh		;eb44
	ld bc,00240h		;eb46
	rrca			;eb49
	dec de			;eb4a
	ld c,l			;eb4b
	djnz $+1		;eb4c
	ld bc,00018h		;eb4e
	nop			;eb51
	jr nz,leb54h		;eb52
leb54h:
	djnz $+1		;eb54
	ld bc,00018h		;eb56
	nop			;eb59
	jr nz,leb5ch		;eb5a
leb5ch:
	djnz $+1		;eb5c
	ld bc,00029h		;eb5e
	nop			;eb61
	jr nz,leb64h		;eb62
leb64h:
	djnz $+1		;eb64
	ld bc,00053h		;eb66
	nop			;eb69
	jr nz,leb6ch		;eb6a
leb6ch:
	djnz $+1		;eb6c
	ld bc,000a6h		;eb6e
	nop			;eb71
	jr nz,leb74h		;eb72
leb74h:
	nop			;eb74
	nop			;eb75
	add hl,hl		;eb76
	nop			;eb77
	nop			;eb78
	nop			;eb79
	nop			;eb7a
	nop			;eb7b
	add a,c			;eb7c
	ret p			;eb7d
	inc hl			;eb7e
	jp pe,lf148h		;eb7f
	ld bc,000f1h		;eb82
	nop			;eb85
	nop			;eb86
	nop			;eb87
	nop			;eb88
	nop			;eb89
	nop			;eb8a
	nop			;eb8b
	add a,c			;eb8c
	ret p			;eb8d
	inc hl			;eb8e
	jp pe,lf1afh		;eb8f
	ld l,b			;eb92
	pop af			;eb93
	nop			;eb94
	nop			;eb95
	nop			;eb96
	nop			;eb97
	nop			;eb98
	nop			;eb99
	nop			;eb9a
	nop			;eb9b
	add a,c			;eb9c
	ret p			;eb9d
	ld d,b			;eb9e
	jp pe,00000h		;eb9f
	rst 8			;eba2
	pop af			;eba3
	nop			;eba4
	nop			;eba5
	nop			;eba6
	nop			;eba7
	nop			;eba8
	nop			;eba9
	nop			;ebaa
	nop			;ebab
	add a,c			;ebac
lebadh:
	ret p			;ebad
	ld a,l			;ebae
	jp pe,00000h		;ebaf
	ld d,0f2h		;ebb2
	nop			;ebb4
	nop			;ebb5
	nop			;ebb6
	nop			;ebb7
	nop			;ebb8
	nop			;ebb9
	nop			;ebba
	nop			;ebbb
	add a,c			;ebbc
	ret p			;ebbd
	ld l,(hl)		;ebbe
	jp pe,00000h		;ebbf
	ld d,l			;ebc2
	jp p,00000h		;ebc3
	nop			;ebc6
	nop			;ebc7
	nop			;ebc8
	nop			;ebc9
	nop			;ebca
	nop			;ebcb
	add a,c			;ebcc
	ret p			;ebcd
	ld l,(hl)		;ebce
	jp pe,00000h		;ebcf
	sub h			;ebd2
	jp p,00000h		;ebd3
	nop			;ebd6
	nop			;ebd7
	nop			;ebd8
	nop			;ebd9
	nop			;ebda
	nop			;ebdb
	add a,c			;ebdc
	ret p			;ebdd
	ld e,a			;ebde
	jp pe,00000h		;ebdf
	out (0f2h),a		;ebe2
	ei			;ebe4
	reti			;ebe5
	ld (bc),a		;ebe7
diskcode_end:
DUMITR:

; BLOCK 'dumitr' (start 0xebe8 end 0xebee)
dumitr_start:
	ld h,d			;ebe8
	ld c,b			;ebe9
	ld c,h			;ebea
	inc b			;ebeb
	ld h,d			;ebec
	ld b,c			;ebed
dumitr_end:

; BLOCK 'intvars' (start 0xebee end 0xec00)
intvars_start:
	defb 046h		;ebee
	defb 006h		;ebef
	defb 06ah		;ebf0
	defb 049h		;ebf1
	defb 058h		;ebf2
	defb 044h		;ebf3
	defb 06ah		;ebf4
	defb 049h		;ebf5
	defb 059h		;ebf6
	defb 064h		;ebf7
	defb 072h		;ebf8
	defb 04eh		;ebf9
	defb 05ah		;ebfa
	defb 000h		;ebfb
	defb 071h		;ebfc
	defb 05ah		;ebfd
	defb 001h		;ebfe
	defb 072h		;ebff
intvars_end:
ITRTAB:

; BLOCK 'ivt' (start 0xec00 end 0xec24)
ivt_start:
	defw 0ebe4h		;ec00
	defw 0ebe4h		;ec02
	defw 0e249h		;ec04
	defw 0e7dbh		;ec06
	defw 0e983h		;ec08
	defw 0ebe4h		;ec0a
	defw 0ebe4h		;ec0c
	defw 0ebe4h		;ec0e
	defw 0dd10h		;ec10
	defw 0dd29h		;ec12
	defw 0dd42h		;ec14
	defw 0dd57h		;ec16
	defw 0dd74h		;ec18
	defw 0dd8dh		;ec1a
	defw 0dda6h		;ec1c
	defw 0ddc0h		;ec1e
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
	call sub_de07h		;ec3f
	ret			;ec42
KEYIT:
	ld (lf363h),sp		;ec43
	ld sp,lf620h		;ec47
	push af			;ec4a
	ld a,0ffh		;ec4b
	ld (0ec26h),a		;ec4d
	pop af			;ec50
	ld sp,(lf363h)		;ec51
	ei			;ec55
	reti			;ec56
PARIN:
	ld (lf363h),sp		;ec58
	ld sp,lf620h		;ec5c
	push af			;ec5f
	ld a,0ffh		;ec60
	ld (0ec27h),a		;ec62
	pop af			;ec65
	ld sp,(lf363h)		;ec66
	ei			;ec6a
	reti			;ec6b
	ld b,c			;ec6d
	ld b,(hl)		;ec6e
	defb 006h		;ec6f
kbdcode_end:

; BLOCK 'biosdata' (start 0xec70 end 0xf800)
biosdata_start:
	defb 06ah		;ec70
	defb 049h		;ec71
	defb 058h		;ec72
	defb 044h		;ec73
	defb 06ah		;ec74
	defb 049h		;ec75
	defb 059h		;ec76
	defb 064h		;ec77
	defb 072h		;ec78
	defb 04eh		;ec79
	defb 05ah		;ec7a
	defb 000h		;ec7b
	defb 071h		;ec7c
	defb 05ah		;ec7d
	defb 001h		;ec7e
	defb 072h		;ec7f
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
	defb 000h		;ee81
	defb 04dh		;ee82
	defb 055h		;ee83
	defb 053h		;ee84
	defb 049h		;ee85
	defb 04bh		;ee86
	defb 020h		;ee87
	defb 020h		;ee88
	defb 020h		;ee89
	defb 020h		;ee8a
	defb 020h		;ee8b
	defb 020h		;ee8c
	defb 000h		;ee8d
	defb 000h		;ee8e
	defb 000h		;ee8f
	defb 00fh		;ee90
	defb 06fh		;ee91
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
	defb 000h		;eea1
	defb 049h		;eea2
	defb 04eh		;eea3
	defb 049h		;eea4
	defb 054h		;eea5
	defb 020h		;eea6
	defb 020h		;eea7
	defb 020h		;eea8
	defb 020h		;eea9
	defb 043h		;eeaa
	defb 04fh		;eeab
	defb 04dh		;eeac
	defb 000h		;eead
	defb 000h		;eeae
	defb 000h		;eeaf
	defb 02ah		;eeb0
	defb 082h		;eeb1
	defb 083h		;eeb2
	defb 084h		;eeb3
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
	defb 000h		;eec1
	defb 043h		;eec2
	defb 04fh		;eec3
	defb 04eh		;eec4
	defb 046h		;eec5
	defb 049h		;eec6
	defb 058h		;eec7
	defb 020h		;eec8
	defb 020h		;eec9
	defb 043h		;eeca
	defb 04fh		;eecb
	defb 04dh		;eecc
	defb 000h		;eecd
	defb 000h		;eece
	defb 000h		;eecf
	defb 042h		;eed0
	defb 085h		;eed1
	defb 08ah		;eed2
	defb 08bh		;eed3
	defb 08ch		;eed4
	defb 08dh		;eed5
	defb 000h		;eed6
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
	defb 000h		;eee1
	defb 055h		;eee2
	defb 052h		;eee3
	defb 020h		;eee4
	defb 020h		;eee5
	defb 020h		;eee6
	defb 020h		;eee7
	defb 020h		;eee8
	defb 020h		;eee9
	defb 043h		;eeea
	defb 04fh		;eeeb
	defb 04dh		;eeec
	defb 000h		;eeed
	defb 000h		;eeee
	defb 000h		;eeef
	defb 003h		;eef0
	defb 072h		;eef1
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
	defb 048h		;ef02
	defb 044h		;ef03
	defb 046h		;ef04
	defb 04fh		;ef05
	defb 052h		;ef06
	defb 04dh		;ef07
	defb 020h		;ef08
	defb 020h		;ef09
	defb 043h		;ef0a
	defb 04fh		;ef0b
	defb 04dh		;ef0c
	defb 000h		;ef0d
	defb 000h		;ef0e
	defb 000h		;ef0f
	defb 01bh		;ef10
	defb 086h		;ef11
	defb 087h		;ef12
	defb 000h		;ef13
	defb 000h		;ef14
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
	defb 000h		;ef21
	defb 048h		;ef22
	defb 044h		;ef23
	defb 049h		;ef24
	defb 04eh		;ef25
	defb 053h		;ef26
	defb 054h		;ef27
	defb 020h		;ef28
	defb 020h		;ef29
	defb 043h		;ef2a
	defb 04fh		;ef2b
	defb 04dh		;ef2c
	defb 000h		;ef2d
	defb 000h		;ef2e
	defb 000h		;ef2f
	defb 01ch		;ef30
	defb 088h		;ef31
	defb 089h		;ef32
	defb 000h		;ef33
	defb 000h		;ef34
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
	defb 000h		;ef41
	defb 053h		;ef42
	defb 054h		;ef43
	defb 043h		;ef44
	defb 046h		;ef45
	defb 04fh		;ef46
	defb 052h		;ef47
	defb 04dh		;ef48
	defb 041h		;ef49
	defb 043h		;ef4a
	defb 04fh		;ef4b
	defb 04dh		;ef4c
	defb 000h		;ef4d
	defb 000h		;ef4e
	defb 000h		;ef4f
	defb 01eh		;ef50
	defb 08eh		;ef51
	defb 08fh		;ef52
	defb 000h		;ef53
	defb 000h		;ef54
	defb 000h		;ef55
	defb 000h		;ef56
	defb 000h		;ef57
	defb 000h		;ef58
	defb 000h		;ef59
	defb 000h		;ef5a
	defb 000h		;ef5b
	defb 000h		;ef5c
	defb 000h		;ef5d
	defb 000h		;ef5e
	defb 000h		;ef5f
	defb 000h		;ef60
	defb 000h		;ef61
	defb 04bh		;ef62
	defb 04fh		;ef63
	defb 04eh		;ef64
	defb 047h		;ef65
	defb 020h		;ef66
	defb 020h		;ef67
	defb 020h		;ef68
	defb 020h		;ef69
	defb 030h		;ef6a
	defb 030h		;ef6b
	defb 031h		;ef6c
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
	defb 000h		;ef81
	defb 043h		;ef82
	defb 050h		;ef83
	defb 04dh		;ef84
	defb 035h		;ef85
	defb 036h		;ef86
	defb 020h		;ef87
	defb 020h		;ef88
	defb 020h		;ef89
	defb 043h		;ef8a
	defb 04fh		;ef8b
	defb 04dh		;ef8c
	defb 000h		;ef8d
	defb 000h		;ef8e
	defb 000h		;ef8f
	defb 000h		;ef90
	defb 000h		;ef91
	defb 000h		;ef92
	defb 000h		;ef93
	defb 000h		;ef94
	defb 000h		;ef95
	defb 000h		;ef96
	defb 000h		;ef97
	defb 000h		;ef98
	defb 000h		;ef99
	defb 000h		;ef9a
	defb 000h		;ef9b
	defb 000h		;ef9c
	defb 000h		;ef9d
	defb 000h		;ef9e
	defb 000h		;ef9f
	defb 000h		;efa0
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
	defb 000h		;f030
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
	defb 043h		;f082
	defb 050h		;f083
	defb 04dh		;f084
	defb 035h		;f085
	defb 036h		;f086
	defb 020h		;f087
	defb 020h		;f088
	defb 020h		;f089
	defb 043h		;f08a
	defb 04fh		;f08b
	defb 04dh		;f08c
	defb 000h		;f08d
	defb 000h		;f08e
	defb 000h		;f08f
	defb 000h		;f090
	defb 000h		;f091
	defb 000h		;f092
	defb 000h		;f093
	defb 000h		;f094
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
	defb 0e5h		;f0a2
	defb 0e5h		;f0a3
	defb 0e5h		;f0a4
	defb 0e5h		;f0a5
	defb 0e5h		;f0a6
	defb 0e5h		;f0a7
	defb 0e5h		;f0a8
	defb 0e5h		;f0a9
	defb 0e5h		;f0aa
	defb 0e5h		;f0ab
	defb 0e5h		;f0ac
	defb 0e5h		;f0ad
	defb 0e5h		;f0ae
	defb 0e5h		;f0af
	defb 0e5h		;f0b0
	defb 0e5h		;f0b1
	defb 0e5h		;f0b2
	defb 0e5h		;f0b3
	defb 0e5h		;f0b4
	defb 0e5h		;f0b5
	defb 0e5h		;f0b6
	defb 0e5h		;f0b7
	defb 0e5h		;f0b8
	defb 0e5h		;f0b9
	defb 0e5h		;f0ba
	defb 0e5h		;f0bb
	defb 0e5h		;f0bc
	defb 0e5h		;f0bd
	defb 0e5h		;f0be
	defb 0e5h		;f0bf
	defb 0e5h		;f0c0
	defb 0e5h		;f0c1
	defb 0e5h		;f0c2
	defb 0e5h		;f0c3
	defb 0e5h		;f0c4
	defb 0e5h		;f0c5
	defb 0e5h		;f0c6
	defb 0e5h		;f0c7
	defb 0e5h		;f0c8
	defb 0e5h		;f0c9
	defb 0e5h		;f0ca
	defb 0e5h		;f0cb
	defb 0e5h		;f0cc
	defb 0e5h		;f0cd
	defb 0e5h		;f0ce
	defb 0e5h		;f0cf
	defb 0e5h		;f0d0
	defb 0e5h		;f0d1
	defb 0e5h		;f0d2
	defb 0e5h		;f0d3
	defb 0e5h		;f0d4
	defb 0e5h		;f0d5
	defb 0e5h		;f0d6
	defb 0e5h		;f0d7
	defb 0e5h		;f0d8
	defb 0e5h		;f0d9
	defb 0e5h		;f0da
	defb 0e5h		;f0db
	defb 0e5h		;f0dc
	defb 0e5h		;f0dd
	defb 0e5h		;f0de
	defb 0e5h		;f0df
	defb 0e5h		;f0e0
	defb 0e5h		;f0e1
	defb 0e5h		;f0e2
	defb 0e5h		;f0e3
	defb 0e5h		;f0e4
	defb 0e5h		;f0e5
	defb 0e5h		;f0e6
	defb 0e5h		;f0e7
	defb 0e5h		;f0e8
	defb 0e5h		;f0e9
	defb 0e5h		;f0ea
	defb 0e5h		;f0eb
	defb 0e5h		;f0ec
	defb 0e5h		;f0ed
	defb 0e5h		;f0ee
	defb 0e5h		;f0ef
	defb 0e5h		;f0f0
	defb 0e5h		;f0f1
	defb 0e5h		;f0f2
	defb 0e5h		;f0f3
	defb 0e5h		;f0f4
	defb 0e5h		;f0f5
	defb 0e5h		;f0f6
	defb 0e5h		;f0f7
	defb 0e5h		;f0f8
	defb 0e5h		;f0f9
	defb 0e5h		;f0fa
	defb 0e5h		;f0fb
	defb 0e5h		;f0fc
	defb 0e5h		;f0fd
	defb 0e5h		;f0fe
	defb 0e5h		;f0ff
	defb 0e5h		;f100
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
	defb 0ffh		;f10f
	defb 0ffh		;f110
	defb 0feh		;f111
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
	defb 0d7h		;f148
	defb 044h		;f149
	defb 094h		;f14a
	defb 0f3h		;f14b
	defb 0a6h		;f14c
	defb 029h		;f14d
	defb 030h		;f14e
	defb 044h		;f14f
	defb 0a3h		;f150
	defb 0d6h		;f151
	defb 06ah		;f152
	defb 09bh		;f153
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
	defb 000h		;f312
	defb 000h		;f313
	defb 000h		;f314
	defb 000h		;f315
	defb 000h		;f316
	defb 000h		;f317
	defb 000h		;f318
	defb 000h		;f319
	defb 000h		;f31a
	defb 000h		;f31b
	defb 000h		;f31c
	defb 000h		;f31d
	defb 000h		;f31e
	defb 000h		;f31f
	defb 000h		;f320
	defb 000h		;f321
	defb 000h		;f322
	defb 000h		;f323
	defb 000h		;f324
	defb 000h		;f325
	defb 000h		;f326
	defb 000h		;f327
	defb 000h		;f328
	defb 000h		;f329
	defb 000h		;f32a
	defb 000h		;f32b
	defb 000h		;f32c
	defb 000h		;f32d
lf32eh:
	defb 000h		;f32e
lf32fh:
	defb 002h		;f32f
	defb 000h		;f330
lf331h:
	defb 00ah		;f331
lf332h:
	defb 000h		;f332
lf333h:
	defb 000h		;f333
lf334h:
	defb 002h		;f334
lf335h:
	defb 000h		;f335
lf336h:
	defb 002h		;f336
	defb 000h		;f337
lf338h:
	defb 000h		;f338
lf339h:
	defb 002h		;f339
lf33ah:
	defb 000h		;f33a
lf33bh:
	defb 002h		;f33b
lf33ch:
	defb 000h		;f33c
lf33dh:
	defb 001h		;f33d
lf33eh:
	defb 000h		;f33e
lf33fh:
	defb 000h		;f33f
lf340h:
	defb 000h		;f340
lf341h:
	defb 000h		;f341
	defb 000h		;f342
lf343h:
	defb 000h		;f343
	defb 000h		;f344
lf345h:
	defb 000h		;f345
lf346h:
	defb 000h		;f346
lf347h:
	defb 001h		;f347
lf348h:
	defb 001h		;f348
lf349h:
	defb 002h		;f349
lf34ah:
	defb 080h		;f34a
	defb 000h		;f34b
lf34ch:
	defb 03dh		;f34c
	defb 0ebh		;f34d
lf34eh:
	defb 010h		;f34e
lf34fh:
	defb 009h		;f34f
lf350h:
	defb 000h		;f350
lf351h:
	defb 000h		;f351
lf352h:
	defb 081h		;f352
lf353h:
	defb 0eeh		;f353
lf354h:
	defb 002h		;f354
lf355h:
	defb 005h		;f355
lf356h:
	defb 00ah		;f356
lf357h:
	defb 000h		;f357
lf358h:
	defb 000h		;f358
	defb 000h		;f359
	defb 002h		;f35a
	defb 000h		;f35b
	defb 006h		;f35c
	defb 002h		;f35d
	defb 000h		;f35e
lf35fh:
	defb 000h		;f35f
lf360h:
	defb 000h		;f360
lf361h:
	defb 000h		;f361
	defb 000h		;f362
lf363h:
	defb 035h		;f363
	defb 0cfh		;f364
lf365h:
	defb 000h		;f365
	defb 001h		;f366
lf367h:
	defb 0ffh		;f367
lf368h:
	defb 001h		;f368
lf369h:
	defb 000h		;f369
lf36ah:
	defb 023h		;f36a
lf36bh:
	defb 0eah		;f36b
lf36ch:
	defb 010h		;f36c
lf36dh:
	defb 048h		;f36d
	defb 000h		;f36e
lf36fh:
	defb 003h		;f36f
lf370h:
	defb 003h		;f370
lf371h:
	defb 0e2h		;f371
	defb 0e9h		;f372
lf373h:
	defb 0ffh		;f373
lf374h:
	defb 000h		;f374
	defb 045h		;f375
	defb 04eh		;f376
	defb 054h		;f377
	defb 049h		;f378
	defb 04fh		;f379
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
	defb 031h		;f614
	defb 0e7h		;f615
	defb 0bdh		;f616
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
	defb 011h		;f670
	defb 0deh		;f671
	defb 001h		;f672
	defb 002h		;f673
	defb 0edh		;f674
	defb 0e1h		;f675
	defb 040h		;f676
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
	defb 040h		;f6c0
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
	defb 05bh		;f6db
	defb 05ch		;f6dc
	defb 05dh		;f6dd
	defb 05eh		;f6de
	defb 05fh		;f6df
	defb 060h		;f6e0
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
	defb 07bh		;f6fb
	defb 07ch		;f6fc
	defb 07dh		;f6fd
	defb 07eh		;f6fe
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
	defb 0c9h		;f7c9
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
