; z80dasm 1.2.0
; command line: z80dasm -a -l -t -g 0xDC80 -o region2_track0_side1_runtime.asm region2_track0_side1.bin

	org 0dc80h

	ex af,af'		;dc80	08		.
	ei			;dc81	fb		.
	ret			;dc82	c9		.
	ld (0f34bh),sp		;dc83	ed 73 4b f3	. s K .
	ld sp,0f620h		;dc87	31 20 f6	1   .
	push af			;dc8a	f5		.
	ld a,028h		;dc8b	3e 28		> (
	out (00bh),a		;dc8d	d3 0b		. .
	ld a,0ffh		;dc8f	3e ff		> .
	ld (0dbfeh),a		;dc91	32 fe db	2 . .
	pop af			;dc94	f1		.
	ld sp,(0f34bh)		;dc95	ed 7b 4b f3	. { K .
	ei			;dc99	fb		.
	reti			;dc9a	ed 4d		. M
sub_dc9ch:
	ld (0f34bh),sp		;dc9c	ed 73 4b f3	. s K .
	ld sp,0f620h		;dca0	31 20 f6	1   .
	push af			;dca3	f5		.
	in a,(00bh)		;dca4	db 0b		. .
	ld (0dc05h),a		;dca6	32 05 dc	2 . .
	ld a,010h		;dca9	3e 10		> .
	out (00bh),a		;dcab	d3 0b		. .
	pop af			;dcad	f1		.
	ld sp,(0f34bh)		;dcae	ed 7b 4b f3	. { K .
	ei			;dcb2	fb		.
	reti			;dcb3	ed 4d		. M
	ld (0f34bh),sp		;dcb5	ed 73 4b f3	. s K .
	ld sp,0f620h		;dcb9	31 20 f6	1   .
	push af			;dcbc	f5		.
	in a,(008h)		;dcbd	db 08		. .
	ld (0dc02h),a		;dcbf	32 02 dc	2 . .
	pop af			;dcc2	f1		.
	ld sp,(0f34bh)		;dcc3	ed 7b 4b f3	. { K .
	ei			;dcc7	fb		.
	reti			;dcc8	ed 4d		. M
sub_dccah:
	ld (0f34bh),sp		;dcca	ed 73 4b f3	. s K .
	ld sp,0f620h		;dcce	31 20 f6	1   .
	push af			;dcd1	f5		.
	ld a,001h		;dcd2	3e 01		> .
	out (00bh),a		;dcd4	d3 0b		. .
	in a,(00bh)		;dcd6	db 0b		. .
	ld (0dc06h),a		;dcd8	32 06 dc	2 . .
	ld a,030h		;dcdb	3e 30		> 0
	out (00bh),a		;dcdd	d3 0b		. .
	pop af			;dcdf	f1		.
	ld sp,(0f34bh)		;dce0	ed 7b 4b f3	. { K .
	ei			;dce4	fb		.
	reti			;dce5	ed 4d		. M
	ld (0f34bh),sp		;dce7	ed 73 4b f3	. s K .
	ld sp,0f620h		;dceb	31 20 f6	1   .
	push af			;dcee	f5		.
	ld a,028h		;dcef	3e 28		> (
	out (00ah),a		;dcf1	d3 0a		. .
	ld a,0ffh		;dcf3	3e ff		> .
	ld (0dc00h),a		;dcf5	32 00 dc	2 . .
	pop af			;dcf8	f1		.
	ld sp,(0f34bh)		;dcf9	ed 7b 4b f3	. { K .
	ei			;dcfd	fb		.
	reti			;dcfe	ed 4d		. M
sub_dd00h:
	ld (0f34bh),sp		;dd00	ed 73 4b f3	. s K .
	ld sp,0f620h		;dd04	31 20 f6	1   .
	push af			;dd07	f5		.
	in a,(00ah)		;dd08	db 0a		. .
	ld (0dc03h),a		;dd0a	32 03 dc	2 . .
	ld a,010h		;dd0d	3e 10		> .
	out (00ah),a		;dd0f	d3 0a		. .
	pop af			;dd11	f1		.
	ld sp,(0f34bh)		;dd12	ed 7b 4b f3	. { K .
	ei			;dd16	fb		.
	reti			;dd17	ed 4d		. M
	ld (0f34bh),sp		;dd19	ed 73 4b f3	. s K .
	ld sp,0f620h		;dd1d	31 20 f6	1   .
	push af			;dd20	f5		.
	in a,(008h)		;dd21	db 08		. .
	ld (0dc01h),a		;dd23	32 01 dc	2 . .
	ld a,0ffh		;dd26	3e ff		> .
	ld (0dbffh),a		;dd28	32 ff db	2 . .
	pop af			;dd2b	f1		.
	ld sp,(0f34bh)		;dd2c	ed 7b 4b f3	. { K .
	ei			;dd30	fb		.
	reti			;dd31	ed 4d		. M
	ld (0f34bh),sp		;dd33	ed 73 4b f3	. s K .
	ld sp,0f620h		;dd37	31 20 f6	1   .
	push af			;dd3a	f5		.
	ld a,001h		;dd3b	3e 01		> .
	out (00ah),a		;dd3d	d3 0a		. .
	in a,(00ah)		;dd3f	db 0a		. .
	ld (0dc04h),a		;dd41	32 04 dc	2 . .
	ld a,030h		;dd44	3e 30		> 0
	out (00ah),a		;dd46	d3 0a		. .
	ld a,000h		;dd48	3e 00		> .
	ld (0dc01h),a		;dd4a	32 01 dc	2 . .
	ld a,0ffh		;dd4d	3e ff		> .
	ld (0dbffh),a		;dd4f	32 ff db	2 . .
	pop af			;dd52	f1		.
	ld sp,(0f34bh)		;dd53	ed 7b 4b f3	. { K .
	ei			;dd57	fb		.
	reti			;dd58	ed 4d		. M
ldd5ah:
	nop			;dd5a	00		.
ldd5bh:
	nop			;dd5b	00		.
	nop			;dd5c	00		.
sub_dd5dh:
	ld a,h			;dd5d	7c		|
	cpl			;dd5e	2f		/
	ld h,a			;dd5f	67		g
	ld a,l			;dd60	7d		}
	cpl			;dd61	2f		/
	ld l,a			;dd62	6f		o
	ret			;dd63	c9		.
sub_dd64h:
	call sub_dd5dh		;dd64	cd 5d dd	. ] .
	inc hl			;dd67	23		#
	ret			;dd68	c9		.
sub_dd69h:
	ld hl,(0ffd2h)		;dd69	2a d2 ff	* . .
	ld a,l			;dd6c	7d		}
	cp 080h			;dd6d	fe 80		. .
	ret nz			;dd6f	c0		.
	ld a,h			;dd70	7c		|
	cp 007h			;dd71	fe 07		. .
	ret			;dd73	c9		.
sub_dd74h:
	ld a,(ldd5ah)		;dd74	3a 5a dd	: Z .
	or a			;dd77	b7		.
	ld a,c			;dd78	79		y
	ret nz			;dd79	c0		.
sub_dd7ah:
	ld b,000h		;dd7a	06 00		. .
	add hl,bc		;dd7c	09		.
	ld a,(hl)		;dd7d	7e		~
	ret			;dd7e	c9		.
ldd7fh:
	push af			;dd7f	f5		.
	ld a,080h		;dd80	3e 80		> .
	out (001h),a		;dd82	d3 01		. .
	ld a,(0ffd1h)		;dd84	3a d1 ff	: . .
	out (000h),a		;dd87	d3 00		. .
	ld a,(0ffd4h)		;dd89	3a d4 ff	: . .
	out (000h),a		;dd8c	d3 00		. .
	pop af			;dd8e	f1		.
	ret			;dd8f	c9		.
ldd90h:
	ld hl,(0ffd2h)		;dd90	2a d2 ff	* . .
	ld de,00050h		;dd93	11 50 00	. P .
	add hl,de		;dd96	19		.
	ld (0ffd2h),hl		;dd97	22 d2 ff	" . .
	ld hl,0ffd4h		;dd9a	21 d4 ff	! . .
	inc (hl)		;dd9d	34		4
	jp ldd7fh		;dd9e	c3 7f dd	. . .
ldda1h:
	ld hl,(0ffd2h)		;dda1	2a d2 ff	* . .
	ld de,0ffb0h		;dda4	11 b0 ff	. . .
	add hl,de		;dda7	19		.
	ld (0ffd2h),hl		;dda8	22 d2 ff	" . .
	ld hl,0ffd4h		;ddab	21 d4 ff	! . .
	dec (hl)		;ddae	35		5
	jp ldd7fh		;ddaf	c3 7f dd	. . .
sub_ddb2h:
	ld hl,00000h		;ddb2	21 00 00	! . .
	ld (0ffd2h),hl		;ddb5	22 d2 ff	" . .
	xor a			;ddb8	af		.
	ld (0ffd1h),a		;ddb9	32 d1 ff	2 . .
	ld (0ffd4h),a		;ddbc	32 d4 ff	2 . .
	ret			;ddbf	c9		.
lddc0h:
	cp b			;ddc0	b8		.
	ret c			;ddc1	d8		.
	sub b			;ddc2	90		.
	jp lddc0h		;ddc3	c3 c0 dd	. . .
lddc6h:
	ld hl,(0ffd5h)		;ddc6	2a d5 ff	* . .
	ld d,h			;ddc9	54		T
	ld e,l			;ddca	5d		]
	inc de			;ddcb	13		.
	ld bc,0004fh		;ddcc	01 4f 00	. O .
	ld (hl),020h		;ddcf	36 20		6  
	ldir			;ddd1	ed b0		. .
	ld a,(0ffdbh)		;ddd3	3a db ff	: . .
	cp 000h			;ddd6	fe 00		. .
	ret z			;ddd8	c8		.
	ld hl,(0ffdch)		;ddd9	2a dc ff	* . .
	ld d,h			;dddc	54		T
	ld e,l			;dddd	5d		]
	inc de			;ddde	13		.
	ld bc,00009h		;dddf	01 09 00	. . .
	ld (hl),000h		;dde2	36 00		6 .
	ldir			;dde4	ed b0		. .
	ret			;dde6	c9		.
ldde7h:
	ld hl,0f850h		;dde7	21 50 f8	! P .
	ld de,0f800h		;ddea	11 00 f8	. . .
	ld bc,00780h		;dded	01 80 07	. . .
	ldir			;ddf0	ed b0		. .
	ld hl,0ff80h		;ddf2	21 80 ff	! . .
	ld (0ffd5h),hl		;ddf5	22 d5 ff	" . .
	ld a,(0ffdbh)		;ddf8	3a db ff	: . .
	cp 000h			;ddfb	fe 00		. .
	jp z,lddc6h		;ddfd	ca c6 dd	. . .
	ld hl,0f50ah		;de00	21 0a f5	! . .
	ld de,0f500h		;de03	11 00 f5	. . .
	ld bc,000f0h		;de06	01 f0 00	. . .
	ldir			;de09	ed b0		. .
	ld hl,0f5f0h		;de0b	21 f0 f5	! . .
	ld (0ffdch),hl		;de0e	22 dc ff	" . .
	jp lddc6h		;de11	c3 c6 dd	. . .
sub_de14h:
	ld a,000h		;de14	3e 00		> .
	ld b,003h		;de16	06 03		. .
lde18h:
	srl h			;de18	cb 3c		. <
	rr l			;de1a	cb 1d		. .
	rra			;de1c	1f		.
	dec b			;de1d	05		.
	jp nz,lde18h		;de1e	c2 18 de	. . .
	cp 000h			;de21	fe 00		. .
	ret z			;de23	c8		.
	ld b,005h		;de24	06 05		. .
lde26h:
	rra			;de26	1f		.
	dec b			;de27	05		.
	jp nz,lde26h		;de28	c2 26 de	. & .
	ret			;de2b	c9		.
sub_de2ch:
	ld de,0f500h		;de2c	11 00 f5	. . .
	add hl,de		;de2f	19		.
	cp 000h			;de30	fe 00		. .
	ld b,a			;de32	47		G
	ld a,000h		;de33	3e 00		> .
	jp nz,lde3bh		;de35	c2 3b de	. ; .
	and (hl)		;de38	a6		.
	ld (hl),a		;de39	77		w
	ret			;de3a	c9		.
lde3bh:
	scf			;de3b	37		7
	rla			;de3c	17		.
	dec b			;de3d	05		.
	jp nz,lde3bh		;de3e	c2 3b de	. ; .
	and (hl)		;de41	a6		.
	ld (hl),a		;de42	77		w
	ret			;de43	c9		.
lde44h:
	ld a,000h		;de44	3e 00		> .
	cp c			;de46	b9		.
	jp z,lde4dh		;de47	ca 4d de	. M .
lde4ah:
	ldir			;de4a	ed b0		. .
	ret			;de4c	c9		.
lde4dh:
	cp b			;de4d	b8		.
	jp nz,lde4ah		;de4e	c2 4a de	. J .
	ret			;de51	c9		.
sub_de52h:
	ld a,000h		;de52	3e 00		> .
	cp c			;de54	b9		.
	jp z,lde5bh		;de55	ca 5b de	. [ .
lde58h:
	lddr			;de58	ed b8		. .
	ret			;de5a	c9		.
lde5bh:
	cp b			;de5b	b8		.
	jp nz,lde58h		;de5c	c2 58 de	. X .
	ret			;de5f	c9		.
	out (01ch),a		;de60	d3 1c		. .
	ret			;de62	c9		.
	call sub_ddb2h		;de63	cd b2 dd	. . .
	ld a,002h		;de66	3e 02		> .
	ld (0ffd7h),a		;de68	32 d7 ff	2 . .
	ret			;de6b	c9		.
	ret			;de6c	c9		.
	ld a,000h		;de6d	3e 00		> .
	ld (0ffd1h),a		;de6f	32 d1 ff	2 . .
	jp ldd7fh		;de72	c3 7f dd	. . .
	ld hl,0ffcfh		;de75	21 cf ff	! . .
	ld de,0ffceh		;de78	11 ce ff	. . .
	ld bc,007cfh		;de7b	01 cf 07	. . .
	ld (hl),020h		;de7e	36 20		6  
	lddr			;de80	ed b8		. .
	call sub_ddb2h		;de82	cd b2 dd	. . .
	call ldd7fh		;de85	cd 7f dd	. . .
	ld a,(0ffdbh)		;de88	3a db ff	: . .
	cp 000h			;de8b	fe 00		. .
	ret z			;de8d	c8		.
	xor a			;de8e	af		.
	ld (0ffdbh),a		;de8f	32 db ff	2 . .
	ld hl,0f5f9h		;de92	21 f9 f5	! . .
	ld de,0f5f8h		;de95	11 f8 f5	. . .
	ld bc,000f9h		;de98	01 f9 00	. . .
	ld (hl),000h		;de9b	36 00		6 .
	lddr			;de9d	ed b8		. .
	ret			;de9f	c9		.
	ld de,0f800h		;dea0	11 00 f8	. . .
	ld hl,(0ffd2h)		;dea3	2a d2 ff	* . .
	add hl,de		;dea6	19		.
	ld de,0004fh		;dea7	11 4f 00	. O .
	add hl,de		;deaa	19		.
	ld d,h			;deab	54		T
	ld e,l			;deac	5d		]
	dec de			;dead	1b		.
	ld bc,00000h		;deae	01 00 00	. . .
	ld a,(0ffd1h)		;deb1	3a d1 ff	: . .
	cpl			;deb4	2f		/
	inc a			;deb5	3c		<
	add a,04fh		;deb6	c6 4f		. O
	ld c,a			;deb8	4f		O
	ld (hl),020h		;deb9	36 20		6  
	call sub_de52h		;debb	cd 52 de	. R .
	ld a,(0ffdbh)		;debe	3a db ff	: . .
	cp 000h			;dec1	fe 00		. .
	ret z			;dec3	c8		.
	ld hl,(0ffd2h)		;dec4	2a d2 ff	* . .
	ld d,000h		;dec7	16 00		. .
	ld a,(0ffd1h)		;dec9	3a d1 ff	: . .
	ld e,a			;decc	5f		_
	add hl,de		;decd	19		.
	call sub_de14h		;dece	cd 14 de	. . .
	call sub_de2ch		;ded1	cd 2c de	. , .
	ld a,(0ffd1h)		;ded4	3a d1 ff	: . .
	srl a			;ded7	cb 3f		. ?
	srl a			;ded9	cb 3f		. ?
	srl a			;dedb	cb 3f		. ?
	cpl			;dedd	2f		/
	add a,009h		;dede	c6 09		. .
	ret m			;dee0	f8		.
	ld c,a			;dee1	4f		O
	ld b,000h		;dee2	06 00		. .
	inc hl			;dee4	23		#
	ld d,h			;dee5	54		T
	ld e,l			;dee6	5d		]
	inc de			;dee7	13		.
	ld a,000h		;dee8	3e 00		> .
	jp lde44h		;deea	c3 44 de	. D .
	ld hl,(0ffd2h)		;deed	2a d2 ff	* . .
	ld a,(0ffd1h)		;def0	3a d1 ff	: . .
	ld c,a			;def3	4f		O
	ld b,000h		;def4	06 00		. .
	add hl,bc		;def6	09		.
	call sub_dd64h		;def7	cd 64 dd	. d .
	ld de,007cfh		;defa	11 cf 07	. . .
	add hl,de		;defd	19		.
	ld b,h			;defe	44		D
	ld c,l			;deff	4d		M
	ld hl,0ffcfh		;df00	21 cf ff	! . .
	ld de,0ffceh		;df03	11 ce ff	. . .
	ld (hl),020h		;df06	36 20		6  
	call sub_de52h		;df08	cd 52 de	. R .
	ld a,(0ffdbh)		;df0b	3a db ff	: . .
	cp 000h			;df0e	fe 00		. .
	ret z			;df10	c8		.
	ld hl,(0ffd2h)		;df11	2a d2 ff	* . .
	ld d,000h		;df14	16 00		. .
	ld a,(0ffd1h)		;df16	3a d1 ff	: . .
	ld e,a			;df19	5f		_
	add hl,de		;df1a	19		.
	call sub_de14h		;df1b	cd 14 de	. . .
	call sub_de2ch		;df1e	cd 2c de	. , .
	call sub_dd5dh		;df21	cd 5d dd	. ] .
	ld de,0f5f9h		;df24	11 f9 f5	. . .
	add hl,de		;df27	19		.
	ld a,080h		;df28	3e 80		> .
	and h			;df2a	a4		.
	ret nz			;df2b	c0		.
	ld b,h			;df2c	44		D
	ld c,l			;df2d	4d		M
	ld h,d			;df2e	62		b
	ld l,e			;df2f	6b		k
	dec de			;df30	1b		.
	ld (hl),000h		;df31	36 00		6 .
	jp sub_de52h		;df33	c3 52 de	. R .
	ld a,(0ffd1h)		;df36	3a d1 ff	: . .
	cp 000h			;df39	fe 00		. .
	jp z,ldf45h		;df3b	ca 45 df	. E .
	dec a			;df3e	3d		=
	ld (0ffd1h),a		;df3f	32 d1 ff	2 . .
	jp ldd7fh		;df42	c3 7f dd	. . .
ldf45h:
	ld a,04fh		;df45	3e 4f		> O
	ld (0ffd1h),a		;df47	32 d1 ff	2 . .
	ld hl,(0ffd2h)		;df4a	2a d2 ff	* . .
	ld a,l			;df4d	7d		}
	or h			;df4e	b4		.
	jp nz,ldda1h		;df4f	c2 a1 dd	. . .
	ld hl,00780h		;df52	21 80 07	! . .
	ld (0ffd2h),hl		;df55	22 d2 ff	" . .
	ld a,018h		;df58	3e 18		> .
	ld (0ffd4h),a		;df5a	32 d4 ff	2 . .
	jp ldd7fh		;df5d	c3 7f dd	. . .
sub_df60h:
	ld a,(0ffd1h)		;df60	3a d1 ff	: . .
	cp 04fh			;df63	fe 4f		. O
	jp z,ldf6fh		;df65	ca 6f df	. o .
	inc a			;df68	3c		<
	ld (0ffd1h),a		;df69	32 d1 ff	2 . .
	jp ldd7fh		;df6c	c3 7f dd	. . .
ldf6fh:
	ld a,000h		;df6f	3e 00		> .
	ld (0ffd1h),a		;df71	32 d1 ff	2 . .
	call sub_dd69h		;df74	cd 69 dd	. i .
	jp nz,ldd90h		;df77	c2 90 dd	. . .
	call ldd7fh		;df7a	cd 7f dd	. . .
	jp ldde7h		;df7d	c3 e7 dd	. . .
	call sub_df60h		;df80	cd 60 df	. ` .
	call sub_df60h		;df83	cd 60 df	. ` .
	call sub_df60h		;df86	cd 60 df	. ` .
	jp sub_df60h		;df89	c3 60 df	. ` .
	call sub_dd69h		;df8c	cd 69 dd	. i .
	jp nz,ldd90h		;df8f	c2 90 dd	. . .
	jp ldde7h		;df92	c3 e7 dd	. . .
	ld hl,(0ffd2h)		;df95	2a d2 ff	* . .
	ld a,l			;df98	7d		}
	or h			;df99	b4		.
	jp nz,ldda1h		;df9a	c2 a1 dd	. . .
	ld hl,00780h		;df9d	21 80 07	! . .
	ld (0ffd2h),hl		;dfa0	22 d2 ff	" . .
	ld a,018h		;dfa3	3e 18		> .
	ld (0ffd4h),a		;dfa5	32 d4 ff	2 . .
	jp ldd7fh		;dfa8	c3 7f dd	. . .
	call sub_ddb2h		;dfab	cd b2 dd	. . .
	jp ldd7fh		;dfae	c3 7f dd	. . .
	ld hl,(0ffd2h)		;dfb1	2a d2 ff	* . .
	ld b,h			;dfb4	44		D
	ld c,l			;dfb5	4d		M
	ld de,0f850h		;dfb6	11 50 f8	. P .
	add hl,de		;dfb9	19		.
	ld (ldd5bh),hl		;dfba	22 5b dd	" [ .
	ld de,0ffb0h		;dfbd	11 b0 ff	. . .
	add hl,de		;dfc0	19		.
	ex de,hl		;dfc1	eb		.
	ld h,b			;dfc2	60		`
	ld l,c			;dfc3	69		i
	call sub_dd64h		;dfc4	cd 64 dd	. d .
	ld bc,00780h		;dfc7	01 80 07	. . .
	add hl,bc		;dfca	09		.
	ld b,h			;dfcb	44		D
	ld c,l			;dfcc	4d		M
	ld hl,(ldd5bh)		;dfcd	2a 5b dd	* [ .
	call lde44h		;dfd0	cd 44 de	. D .
	ld hl,0ff80h		;dfd3	21 80 ff	! . .
	ld (0ffd5h),hl		;dfd6	22 d5 ff	" . .
	ld a,(0ffdbh)		;dfd9	3a db ff	: . .
	cp 000h			;dfdc	fe 00		. .
	jp z,lddc6h		;dfde	ca c6 dd	. . .
	ld hl,(0ffd2h)		;dfe1	2a d2 ff	* . .
	call sub_de14h		;dfe4	cd 14 de	. . .
	ld b,h			;dfe7	44		D
	ld c,l			;dfe8	4d		M
	ld de,0f50ah		;dfe9	11 0a f5	. . .
	add hl,de		;dfec	19		.
	ld (ldd5bh),hl		;dfed	22 5b dd	" [ .
	ld de,0fff6h		;dff0	11 f6 ff	. . .
	add hl,de		;dff3	19		.
	ex de,hl		;dff4	eb		.
	ld h,b			;dff5	60		`
	ld l,c			;dff6	69		i
	call sub_dd64h		;dff7	cd 64 dd	. d .
	ld bc,000f0h		;dffa	01 f0 00	. . .
	add hl,bc		;dffd	09		.
	ld b,h			;dffe	44		D
	ld c,l			;dfff	4d		M
	ld hl,(ldd5bh)		;e000	2a 5b dd	* [ .
	call lde44h		;e003	cd 44 de	. D .
	ld hl,0f5f0h		;e006	21 f0 f5	! . .
	ld (0ffdch),hl		;e009	22 dc ff	" . .
	jp lddc6h		;e00c	c3 c6 dd	. . .
	ld hl,(0ffd2h)		;e00f	2a d2 ff	* . .
	ld de,0f800h		;e012	11 00 f8	. . .
	add hl,de		;e015	19		.
	ld (0ffd5h),hl		;e016	22 d5 ff	" . .
	call sub_dd64h		;e019	cd 64 dd	. d .
	ld de,0ff80h		;e01c	11 80 ff	. . .
	add hl,de		;e01f	19		.
	ld b,h			;e020	44		D
	ld c,l			;e021	4d		M
	ld hl,0ff7fh		;e022	21 7f ff	! . .
	ld de,0ffcfh		;e025	11 cf ff	. . .
	call sub_de52h		;e028	cd 52 de	. R .
	ld a,(0ffdbh)		;e02b	3a db ff	: . .
	cp 000h			;e02e	fe 00		. .
	jp z,lddc6h		;e030	ca c6 dd	. . .
	ld hl,(0ffd2h)		;e033	2a d2 ff	* . .
	call sub_de14h		;e036	cd 14 de	. . .
	ld de,0f500h		;e039	11 00 f5	. . .
	add hl,de		;e03c	19		.
	ld (0ffdch),hl		;e03d	22 dc ff	" . .
	call sub_dd64h		;e040	cd 64 dd	. d .
	ld de,0f5f0h		;e043	11 f0 f5	. . .
	add hl,de		;e046	19		.
	ld b,h			;e047	44		D
	ld c,l			;e048	4d		M
	ld hl,0f5efh		;e049	21 ef f5	! . .
	ld de,0f5f9h		;e04c	11 f9 f5	. . .
	call sub_de52h		;e04f	cd 52 de	. R .
	jp lddc6h		;e052	c3 c6 dd	. . .
	ld a,002h		;e055	3e 02		> .
	ld (0ffdbh),a		;e057	32 db ff	2 . .
	ret			;e05a	c9		.
	ld a,001h		;e05b	3e 01		> .
	ld (0ffdbh),a		;e05d	32 db ff	2 . .
	ret			;e060	c9		.
	ld hl,0f800h		;e061	21 00 f8	! . .
	ld de,0f500h		;e064	11 00 f5	. . .
	ld b,0fah		;e067	06 fa		. .
le069h:
	ld a,(de)		;e069	1a		.
	ld c,008h		;e06a	0e 08		. .
	cp 000h			;e06c	fe 00		. .
	jp nz,le07bh		;e06e	c2 7b e0	. { .
le071h:
	ld (hl),020h		;e071	36 20		6  
	inc hl			;e073	23		#
	dec c			;e074	0d		.
	jp nz,le071h		;e075	c2 71 e0	. q .
	jp le086h		;e078	c3 86 e0	. . .
le07bh:
	rra			;e07b	1f		.
	jp c,le081h		;e07c	da 81 e0	. . .
	ld (hl),020h		;e07f	36 20		6  
le081h:
	inc hl			;e081	23		#
	dec c			;e082	0d		.
	jp nz,le07bh		;e083	c2 7b e0	. { .
le086h:
	inc de			;e086	13		.
	dec b			;e087	05		.
	jp nz,le069h		;e088	c2 69 e0	. i .
	ret			;e08b	c9		.
le08ch:
	ld l,h			;e08c	6c		l
	sbc a,00fh		;e08d	de 0f		. .
	ret po			;e08f	e0		.
	or c			;e090	b1		.
	rst 18h			;e091	df		.
	ld l,h			;e092	6c		l
	sbc a,06ch		;e093	de 6c		. l
	sbc a,036h		;e095	de 36		. 6
	rst 18h			;e097	df		.
	ld h,e			;e098	63		c
	sbc a,060h		;e099	de 60		. `
	sbc a,036h		;e09b	de 36		. 6
	rst 18h			;e09d	df		.
	add a,b			;e09e	80		.
	rst 18h			;e09f	df		.
	adc a,h			;e0a0	8c		.
	rst 18h			;e0a1	df		.
	ld l,h			;e0a2	6c		l
	sbc a,075h		;e0a3	de 75		. u
	sbc a,06dh		;e0a5	de 6d		. m
	sbc a,06ch		;e0a7	de 6c		. l
	sbc a,06ch		;e0a9	de 6c		. l
	sbc a,06ch		;e0ab	de 6c		. l
	sbc a,06ch		;e0ad	de 6c		. l
	sbc a,06ch		;e0af	de 6c		. l
	sbc a,06ch		;e0b1	de 6c		. l
	sbc a,055h		;e0b3	de 55		. U
	ret po			;e0b5	e0		.
	ld e,e			;e0b6	5b		[
	ret po			;e0b7	e0		.
	ld h,c			;e0b8	61		a
	ret po			;e0b9	e0		.
	ld l,h			;e0ba	6c		l
	sbc a,060h		;e0bb	de 60		. `
	rst 18h			;e0bd	df		.
	ld l,h			;e0be	6c		l
	sbc a,095h		;e0bf	de 95		. .
	rst 18h			;e0c1	df		.
	ld l,h			;e0c2	6c		l
	sbc a,06ch		;e0c3	de 6c		. l
	sbc a,0abh		;e0c5	de ab		. .
	rst 18h			;e0c7	df		.
	and b			;e0c8	a0		.
	sbc a,0edh		;e0c9	de ed		. .
	sbc a,03eh		;e0cb	de 3e		. >
	nop			;e0cd	00		.
	ld (0ffd7h),a		;e0ce	32 d7 ff	2 . .
	ld a,(0ffdah)		;e0d1	3a da ff	: . .
	rlca			;e0d4	07		.
	and 03eh		;e0d5	e6 3e		. >
	ld c,a			;e0d7	4f		O
	ld b,000h		;e0d8	06 00		. .
	ld hl,le08ch		;e0da	21 8c e0	! . .
	add hl,bc		;e0dd	09		.
	ld e,(hl)		;e0de	5e		^
	inc hl			;e0df	23		#
	ld d,(hl)		;e0e0	56		V
	ex de,hl		;e0e1	eb		.
	jp (hl)			;e0e2	e9		.
sub_e0e3h:
	ld a,(0ffdah)		;e0e3	3a da ff	: . .
	and 07fh		;e0e6	e6 7f		. .
	sub 020h		;e0e8	d6 20		.  
	ld hl,0ffd7h		;e0ea	21 d7 ff	! . .
	dec (hl)		;e0ed	35		5
	jp z,le0f5h		;e0ee	ca f5 e0	. . .
	ld (0ffdeh),a		;e0f1	32 de ff	2 . .
	ret			;e0f4	c9		.
le0f5h:
	ld d,a			;e0f5	57		W
	ld a,(0ffdeh)		;e0f6	3a de ff	: . .
	ld h,a			;e0f9	67		g
	ld a,(0da33h)		;e0fa	3a 33 da	: 3 .
	or a			;e0fd	b7		.
	jp z,le102h		;e0fe	ca 02 e1	. . .
	ex de,hl		;e101	eb		.
le102h:
	ld a,h			;e102	7c		|
	ld b,050h		;e103	06 50		. P
	call lddc0h		;e105	cd c0 dd	. . .
	ld (0ffd1h),a		;e108	32 d1 ff	2 . .
	ld a,d			;e10b	7a		z
	ld b,019h		;e10c	06 19		. .
	call lddc0h		;e10e	cd c0 dd	. . .
	ld (0ffd4h),a		;e111	32 d4 ff	2 . .
	or a			;e114	b7		.
	jp z,ldd7fh		;e115	ca 7f dd	. . .
	ld hl,(0ffd2h)		;e118	2a d2 ff	* . .
	ld de,00050h		;e11b	11 50 00	. P .
le11eh:
	add hl,de		;e11e	19		.
	dec a			;e11f	3d		=
	jp nz,le11eh		;e120	c2 1e e1	. . .
	ld (0ffd2h),hl		;e123	22 d2 ff	" . .
	jp ldd7fh		;e126	c3 7f dd	. . .
sub_e129h:
	ld hl,(0ffd2h)		;e129	2a d2 ff	* . .
	ld d,000h		;e12c	16 00		. .
	ld a,(0ffd1h)		;e12e	3a d1 ff	: . .
	ld e,a			;e131	5f		_
	add hl,de		;e132	19		.
	ld (0ffd8h),hl		;e133	22 d8 ff	" . .
	ld a,(0ffdah)		;e136	3a da ff	: . .
	cp 0c0h			;e139	fe c0		. .
	jp c,le140h		;e13b	da 40 e1	. @ .
	sub 0c0h		;e13e	d6 c0		. .
le140h:
	ld c,a			;e140	4f		O
	cp 080h			;e141	fe 80		. .
	jp c,le14fh		;e143	da 4f e1	. O .
	and 004h		;e146	e6 04		. .
	ld (ldd5ah),a		;e148	32 5a dd	2 Z .
	ld a,c			;e14b	79		y
	jp le155h		;e14c	c3 55 e1	. U .
le14fh:
	ld hl,0f680h		;e14f	21 80 f6	! . .
	call sub_dd74h		;e152	cd 74 dd	. t .
le155h:
	ld hl,(0ffd8h)		;e155	2a d8 ff	* . .
	ld de,0f800h		;e158	11 00 f8	. . .
	add hl,de		;e15b	19		.
	ld (hl),a		;e15c	77		w
	call sub_df60h		;e15d	cd 60 df	. ` .
	ld a,(0ffdbh)		;e160	3a db ff	: . .
	cp 002h			;e163	fe 02		. .
	ret nz			;e165	c0		.
	ld hl,(0ffd8h)		;e166	2a d8 ff	* . .
	call sub_de14h		;e169	cd 14 de	. . .
	ld de,0f500h		;e16c	11 00 f5	. . .
	add hl,de		;e16f	19		.
	cp 000h			;e170	fe 00		. .
	ld b,a			;e172	47		G
	ld a,001h		;e173	3e 01		> .
	jp nz,le17bh		;e175	c2 7b e1	. { .
	or (hl)			;e178	b6		.
	ld (hl),a		;e179	77		w
	ret			;e17a	c9		.
le17bh:
	rlca			;e17b	07		.
	dec b			;e17c	05		.
	jp nz,le17bh		;e17d	c2 7b e1	. { .
	or (hl)			;e180	b6		.
	ld (hl),a		;e181	77		w
	ret			;e182	c9		.
	di			;e183	f3		.
	push hl			;e184	e5		.
	ld hl,00000h		;e185	21 00 00	! . .
	add hl,sp		;e188	39		9
	ld sp,0f680h		;e189	31 80 f6	1 . .
	ei			;e18c	fb		.
	push hl			;e18d	e5		.
	push af			;e18e	f5		.
	push bc			;e18f	c5		.
	push de			;e190	d5		.
	ld a,c			;e191	79		y
	ld (0ffdah),a		;e192	32 da ff	2 . .
	ld a,(0ffd7h)		;e195	3a d7 ff	: . .
	or a			;e198	b7		.
	jp z,le1a2h		;e199	ca a2 e1	. . .
	call sub_e0e3h		;e19c	cd e3 e0	. . .
	jp le1b3h		;e19f	c3 b3 e1	. . .
le1a2h:
	ld a,(0ffdah)		;e1a2	3a da ff	: . .
	cp 020h			;e1a5	fe 20		.  
	jp nc,le1b0h		;e1a7	d2 b0 e1	. . .
	call 0e0cch		;e1aa	cd cc e0	. . .
	jp le1b3h		;e1ad	c3 b3 e1	. . .
le1b0h:
	call sub_e129h		;e1b0	cd 29 e1	. ) .
le1b3h:
	pop de			;e1b3	d1		.
	pop bc			;e1b4	c1		.
	pop af			;e1b5	f1		.
	pop hl			;e1b6	e1		.
	di			;e1b7	f3		.
	ld sp,hl		;e1b8	f9		.
	pop hl			;e1b9	e1		.
	ei			;e1ba	fb		.
	ret			;e1bb	c9		.
	ld (0f34bh),sp		;e1bc	ed 73 4b f3	. s K .
	ld sp,0f620h		;e1c0	31 20 f6	1   .
	push af			;e1c3	f5		.
	push bc			;e1c4	c5		.
	push de			;e1c5	d5		.
	push hl			;e1c6	e5		.
	in a,(001h)		;e1c7	db 01		. .
	ld a,006h		;e1c9	3e 06		> .
	out (0fah),a		;e1cb	d3 fa		. .
	ld a,007h		;e1cd	3e 07		> .
	out (0fah),a		;e1cf	d3 fa		. .
	out (0fch),a		;e1d1	d3 fc		. .
	ld hl,0f800h		;e1d3	21 00 f8	! . .
	ld a,l			;e1d6	7d		}
	out (0f4h),a		;e1d7	d3 f4		. .
	ld a,h			;e1d9	7c		|
	out (0f4h),a		;e1da	d3 f4		. .
	ld hl,007cfh		;e1dc	21 cf 07	! . .
	ld a,l			;e1df	7d		}
	out (0f5h),a		;e1e0	d3 f5		. .
	ld a,h			;e1e2	7c		|
	out (0f5h),a		;e1e3	d3 f5		. .
	ld a,000h		;e1e5	3e 00		> .
	out (0f7h),a		;e1e7	d3 f7		. .
	out (0f7h),a		;e1e9	d3 f7		. .
	ld a,002h		;e1eb	3e 02		> .
	out (0fah),a		;e1ed	d3 fa		. .
	ld a,003h		;e1ef	3e 03		> .
	out (0fah),a		;e1f1	d3 fa		. .
	ld a,0d7h		;e1f3	3e d7		> .
	out (00eh),a		;e1f5	d3 0e		. .
	ld a,001h		;e1f7	3e 01		> .
	out (00eh),a		;e1f9	d3 0e		. .
	ld hl,0fffch		;e1fb	21 fc ff	! . .
	inc (hl)		;e1fe	34		4
	jp nz,le20eh		;e1ff	c2 0e e2	. . .
	inc hl			;e202	23		#
	inc (hl)		;e203	34		4
	jp nz,le20eh		;e204	c2 0e e2	. . .
	inc hl			;e207	23		#
	inc (hl)		;e208	34		4
	jp nz,le20eh		;e209	c2 0e e2	. . .
	inc hl			;e20c	23		#
	inc (hl)		;e20d	34		4
le20eh:
	ld hl,(0ffdfh)		;e20e	2a df ff	* . .
	ld a,l			;e211	7d		}
	or h			;e212	b4		.
	jp z,le21fh		;e213	ca 1f e2	. . .
	dec hl			;e216	2b		+
	ld a,l			;e217	7d		}
	or h			;e218	b4		.
	ld (0ffdfh),hl		;e219	22 df ff	" . .
	call z,0ffe5h		;e21c	cc e5 ff	. . .
le21fh:
	ld hl,(0ffe1h)		;e21f	2a e1 ff	* . .
	ld a,l			;e222	7d		}
	or h			;e223	b4		.
	jp z,le230h		;e224	ca 30 e2	. 0 .
	dec hl			;e227	2b		+
	ld a,l			;e228	7d		}
	or h			;e229	b4		.
	ld (0ffe1h),hl		;e22a	22 e1 ff	" . .
	call z,sub_e5bch	;e22d	cc bc e5	. . .
le230h:
	ld hl,(0ffe3h)		;e230	2a e3 ff	* . .
	ld a,l			;e233	7d		}
	or h			;e234	b4		.
	jp z,le23ch		;e235	ca 3c e2	. < .
	dec hl			;e238	2b		+
	ld (0ffe3h),hl		;e239	22 e3 ff	" . .
le23ch:
	pop hl			;e23c	e1		.
	pop de			;e23d	d1		.
	pop bc			;e23e	c1		.
	pop af			;e23f	f1		.
	ld sp,(0f34bh)		;e240	ed 7b 4b f3	. { K .
	ei			;e244	fb		.
	reti			;e245	ed 4d		. M
	ld hl,00000h		;e247	21 00 00	! . .
	add hl,sp		;e24a	39		9
	ld sp,0f680h		;e24b	31 80 f6	1 . .
	push hl			;e24e	e5		.
	ld hl,00000h		;e24f	21 00 00	! . .
	ld a,(0f334h)		;e252	3a 34 f3	: 4 .
	cp c			;e255	b9		.
	jp c,le2deh		;e256	da de e2	. . .
	ld a,c			;e259	79		y
	ld (0f312h),a		;e25a	32 12 f3	2 . .
	ld bc,00010h		;e25d	01 10 00	. . .
	ld de,0da37h		;e260	11 37 da	. 7 .
	ld hl,00000h		;e263	21 00 00	! . .
le266h:
	or a			;e266	b7		.
	jp z,le270h		;e267	ca 70 e2	. p .
	inc de			;e26a	13		.
	add hl,bc		;e26b	09		.
	dec a			;e26c	3d		=
	jp le266h		;e26d	c3 66 e2	. f .
le270h:
	ld c,l			;e270	4d		M
	ld b,h			;e271	44		D
	ex de,hl		;e272	eb		.
	ld a,(hl)		;e273	7e		~
	ld hl,0f332h		;e274	21 32 f3	! 2 .
	cp (hl)			;e277	be		.
	jp z,le28ah		;e278	ca 8a e2	. . .
	push af			;e27b	f5		.
	push bc			;e27c	c5		.
	ld a,(0f322h)		;e27d	3a 22 f3	: " .
	or a			;e280	b7		.
	call nz,sub_e488h	;e281	c4 88 e4	. . .
	xor a			;e284	af		.
	ld (0f322h),a		;e285	32 22 f3	2 " .
	pop bc			;e288	c1		.
	pop af			;e289	f1		.
le28ah:
	ld (0f332h),a		;e28a	32 32 f3	2 2 .
	call sub_e2e3h		;e28d	cd e3 e2	. . .
	ld (0f330h),hl		;e290	22 30 f3	" 0 .
	inc hl			;e293	23		#
	inc hl			;e294	23		#
	inc hl			;e295	23		#
	inc hl			;e296	23		#
	ld a,(hl)		;e297	7e		~
	ld (0f333h),a		;e298	32 33 f3	2 3 .
	push bc			;e29b	c5		.
	ld a,(0f332h)		;e29c	3a 32 f3	: 2 .
	and 0f8h		;e29f	e6 f8		. .
	or a			;e2a1	b7		.
	rla			;e2a2	17		.
	ld e,a			;e2a3	5f		_
	ld d,000h		;e2a4	16 00		. .
	ld hl,lea1bh		;e2a6	21 1b ea	! . .
	add hl,de		;e2a9	19		.
	ld de,0f351h		;e2aa	11 51 f3	. Q .
	ld bc,00010h		;e2ad	01 10 00	. . .
	ldir			;e2b0	ed b0		. .
	ld hl,(0f351h)		;e2b2	2a 51 f3	* Q .
	ld bc,0000dh		;e2b5	01 0d 00	. . .
	add hl,bc		;e2b8	09		.
	ex de,hl		;e2b9	eb		.
	ld hl,lea0bh		;e2ba	21 0b ea	! . .
	ld b,000h		;e2bd	06 00		. .
	ld a,(0f312h)		;e2bf	3a 12 f3	: . .
	ld c,a			;e2c2	4f		O
	add hl,bc		;e2c3	09		.
	add hl,bc		;e2c4	09		.
	ld bc,00002h		;e2c5	01 02 00	. . .
	ldir			;e2c8	ed b0		. .
	pop bc			;e2ca	c1		.
	ld hl,leaf3h		;e2cb	21 f3 ea	! . .
	add hl,bc		;e2ce	09		.
	ex de,hl		;e2cf	eb		.
	ld hl,0000ah		;e2d0	21 0a 00	! . .
	add hl,de		;e2d3	19		.
	ex de,hl		;e2d4	eb		.
	ld a,(0f351h)		;e2d5	3a 51 f3	: Q .
	ld (de),a		;e2d8	12		.
	inc de			;e2d9	13		.
	ld a,(0f352h)		;e2da	3a 52 f3	: R .
	ld (de),a		;e2dd	12		.
le2deh:
	ex de,hl		;e2de	eb		.
	pop hl			;e2df	e1		.
	ld sp,hl		;e2e0	f9		.
	ex de,hl		;e2e1	eb		.
	ret			;e2e2	c9		.
sub_e2e3h:
	ld hl,leaach		;e2e3	21 ac ea	! . .
	ld a,(0f332h)		;e2e6	3a 32 f3	: 2 .
	and 0f8h		;e2e9	e6 f8		. .
	ld e,a			;e2eb	5f		_
	ld d,000h		;e2ec	16 00		. .
	add hl,de		;e2ee	19		.
	ret			;e2ef	c9		.
	ld h,b			;e2f0	60		`
	ld l,c			;e2f1	69		i
	ld (0f313h),hl		;e2f2	22 13 f3	" . .
	ret			;e2f5	c9		.
	ld l,c			;e2f6	69		i
	ld h,b			;e2f7	60		`
	ld (0f315h),hl		;e2f8	22 15 f3	" . .
	ret			;e2fb	c9		.
	ld h,b			;e2fc	60		`
	ld l,c			;e2fd	69		i
	ld (0f32eh),hl		;e2fe	22 2e f3	" . .
	ret			;e301	c9		.
	ld h,b			;e302	60		`
	ld l,c			;e303	69		i
	ret			;e304	c9		.
	xor a			;e305	af		.
	ld (0f323h),a		;e306	32 23 f3	2 # .
	ld a,001h		;e309	3e 01		> .
	ld (0f32ch),a		;e30b	32 2c f3	2 , .
	ld (0f32bh),a		;e30e	32 2b f3	2 + .
	ld a,002h		;e311	3e 02		> .
	ld (0f32dh),a		;e313	32 2d f3	2 - .
	jp le3b4h		;e316	c3 b4 e3	. . .
	xor a			;e319	af		.
	ld (0f32ch),a		;e31a	32 2c f3	2 , .
	ld a,c			;e31d	79		y
	ld (0f32dh),a		;e31e	32 2d f3	2 - .
	cp 002h			;e321	fe 02		. .
	jp nz,le33eh		;e323	c2 3e e3	. > .
	ld a,(0f353h)		;e326	3a 53 f3	: S .
	ld (0f323h),a		;e329	32 23 f3	2 # .
	ld a,(0f312h)		;e32c	3a 12 f3	: . .
	ld (0f324h),a		;e32f	32 24 f3	2 $ .
	ld hl,(0f313h)		;e332	2a 13 f3	* . .
	ld (0f325h),hl		;e335	22 25 f3	" % .
	ld hl,(0f315h)		;e338	2a 15 f3	* . .
	ld (0f327h),hl		;e33b	22 27 f3	" ' .
le33eh:
	ld a,(0f323h)		;e33e	3a 23 f3	: # .
	or a			;e341	b7		.
	jp z,le3aah		;e342	ca aa e3	. . .
	dec a			;e345	3d		=
	ld (0f323h),a		;e346	32 23 f3	2 # .
	ld a,(0f312h)		;e349	3a 12 f3	: . .
	ld hl,0f324h		;e34c	21 24 f3	! $ .
	cp (hl)			;e34f	be		.
	jp nz,le3aah		;e350	c2 aa e3	. . .
	ld hl,0f325h		;e353	21 25 f3	! % .
	call sub_e47ch		;e356	cd 7c e4	. | .
	jp nz,le3aah		;e359	c2 aa e3	. . .
	ld a,(0f315h)		;e35c	3a 15 f3	: . .
	ld hl,0f327h		;e35f	21 27 f3	! ' .
	cp (hl)			;e362	be		.
	jp nz,le3aah		;e363	c2 aa e3	. . .
	ld a,(0f316h)		;e366	3a 16 f3	: . .
	inc hl			;e369	23		#
	cp (hl)			;e36a	be		.
	jp nz,le3aah		;e36b	c2 aa e3	. . .
	ld hl,(0f327h)		;e36e	2a 27 f3	* ' .
	inc hl			;e371	23		#
	ld (0f327h),hl		;e372	22 27 f3	" ' .
	ex de,hl		;e375	eb		.
	ld hl,0f354h		;e376	21 54 f3	! T .
	push bc			;e379	c5		.
	ld c,(hl)		;e37a	4e		N
	inc hl			;e37b	23		#
	ld b,(hl)		;e37c	46		F
	ex de,hl		;e37d	eb		.
	and a			;e37e	a7		.
	sbc hl,bc		;e37f	ed 42		. B
	pop bc			;e381	c1		.
	jp c,le392h		;e382	da 92 e3	. . .
	ld hl,00000h		;e385	21 00 00	! . .
	ld (0f327h),hl		;e388	22 27 f3	" ' .
	ld hl,(0f325h)		;e38b	2a 25 f3	* % .
	inc hl			;e38e	23		#
	ld (0f325h),hl		;e38f	22 25 f3	" % .
le392h:
	xor a			;e392	af		.
	ld (0f32bh),a		;e393	32 2b f3	2 + .
	ld a,(0f315h)		;e396	3a 15 f3	: . .
	ld hl,0f356h		;e399	21 56 f3	! V .
	and (hl)		;e39c	a6		.
	cp (hl)			;e39d	be		.
	ld a,000h		;e39e	3e 00		> .
	jp nz,le3a4h		;e3a0	c2 a4 e3	. . .
	inc a			;e3a3	3c		<
le3a4h:
	ld (0f329h),a		;e3a4	32 29 f3	2 ) .
	jp le3b4h		;e3a7	c3 b4 e3	. . .
le3aah:
	xor a			;e3aa	af		.
	ld (0f323h),a		;e3ab	32 23 f3	2 # .
	ld a,(0f356h)		;e3ae	3a 56 f3	: V .
	ld (0f32bh),a		;e3b1	32 2b f3	2 + .
le3b4h:
	ld hl,00000h		;e3b4	21 00 00	! . .
	add hl,sp		;e3b7	39		9
	ld sp,0f680h		;e3b8	31 80 f6	1 . .
	push hl			;e3bb	e5		.
	ld a,(0f357h)		;e3bc	3a 57 f3	: W .
	ld b,a			;e3bf	47		G
	ld hl,(0f315h)		;e3c0	2a 15 f3	* . .
le3c3h:
	dec b			;e3c3	05		.
	jp z,le3ceh		;e3c4	ca ce e3	. . .
	srl h			;e3c7	cb 3c		. <
	rr l			;e3c9	cb 1d		. .
	jp le3c3h		;e3cb	c3 c3 e3	. . .
le3ceh:
	ld (0f31fh),hl		;e3ce	22 1f f3	" . .
	ld hl,0f321h		;e3d1	21 21 f3	! ! .
	ld a,(hl)		;e3d4	7e		~
	ld (hl),001h		;e3d5	36 01		6 .
	or a			;e3d7	b7		.
	jp z,le407h		;e3d8	ca 07 e4	. . .
	ld a,(0f312h)		;e3db	3a 12 f3	: . .
	ld hl,0f317h		;e3de	21 17 f3	! . .
	cp (hl)			;e3e1	be		.
	jp nz,le400h		;e3e2	c2 00 e4	. . .
	ld hl,0f318h		;e3e5	21 18 f3	! . .
	call sub_e47ch		;e3e8	cd 7c e4	. | .
	jp nz,le400h		;e3eb	c2 00 e4	. . .
	ld a,(0f31fh)		;e3ee	3a 1f f3	: . .
	ld hl,0f31ah		;e3f1	21 1a f3	! . .
	cp (hl)			;e3f4	be		.
	jp nz,le400h		;e3f5	c2 00 e4	. . .
	ld a,(0f320h)		;e3f8	3a 20 f3	:   .
	inc hl			;e3fb	23		#
	cp (hl)			;e3fc	be		.
	jp z,le424h		;e3fd	ca 24 e4	. $ .
le400h:
	ld a,(0f322h)		;e400	3a 22 f3	: " .
	or a			;e403	b7		.
	call nz,sub_e488h	;e404	c4 88 e4	. . .
le407h:
	ld a,(0f312h)		;e407	3a 12 f3	: . .
	ld (0f317h),a		;e40a	32 17 f3	2 . .
	ld hl,(0f313h)		;e40d	2a 13 f3	* . .
	ld (0f318h),hl		;e410	22 18 f3	" . .
	ld hl,(0f31fh)		;e413	2a 1f f3	* . .
	ld (0f31ah),hl		;e416	22 1a f3	" . .
	ld a,(0f32bh)		;e419	3a 2b f3	: + .
	or a			;e41c	b7		.
	call nz,sub_e495h	;e41d	c4 95 e4	. . .
	xor a			;e420	af		.
	ld (0f322h),a		;e421	32 22 f3	2 " .
le424h:
	ld a,(0f315h)		;e424	3a 15 f3	: . .
	ld hl,0f356h		;e427	21 56 f3	! V .
	and (hl)		;e42a	a6		.
	ld l,a			;e42b	6f		o
	ld h,000h		;e42c	26 00		& .
	add hl,hl		;e42e	29		)
	add hl,hl		;e42f	29		)
	add hl,hl		;e430	29		)
	add hl,hl		;e431	29		)
	add hl,hl		;e432	29		)
	add hl,hl		;e433	29		)
	add hl,hl		;e434	29		)
	ld de,0ee81h		;e435	11 81 ee	. . .
	add hl,de		;e438	19		.
	ex de,hl		;e439	eb		.
	ld hl,(0f32eh)		;e43a	2a 2e f3	* . .
	ld bc,00080h		;e43d	01 80 00	. . .
	ex de,hl		;e440	eb		.
	ld a,(0f32ch)		;e441	3a 2c f3	: , .
	or a			;e444	b7		.
	jp nz,le44eh		;e445	c2 4e e4	. N .
	ld a,001h		;e448	3e 01		> .
	ld (0f322h),a		;e44a	32 22 f3	2 " .
	ex de,hl		;e44d	eb		.
le44eh:
	ldir			;e44e	ed b0		. .
	ld a,(0f32dh)		;e450	3a 2d f3	: - .
	cp 001h			;e453	fe 01		. .
	ld hl,0f32ah		;e455	21 2a f3	! * .
	ld a,(hl)		;e458	7e		~
	push af			;e459	f5		.
	or a			;e45a	b7		.
	jp z,le462h		;e45b	ca 62 e4	. b .
	xor a			;e45e	af		.
	ld (0f321h),a		;e45f	32 21 f3	2 ! .
le462h:
	pop af			;e462	f1		.
	ld (hl),000h		;e463	36 00		6 .
	jp nz,le479h		;e465	c2 79 e4	. y .
	or a			;e468	b7		.
	jp nz,le479h		;e469	c2 79 e4	. y .
	xor a			;e46c	af		.
	ld (0f322h),a		;e46d	32 22 f3	2 " .
	call sub_e488h		;e470	cd 88 e4	. . .
	ld hl,0f32ah		;e473	21 2a f3	! * .
	ld a,(hl)		;e476	7e		~
	ld (hl),000h		;e477	36 00		6 .
le479h:
	pop hl			;e479	e1		.
	ld sp,hl		;e47a	f9		.
	ret			;e47b	c9		.
sub_e47ch:
	ex de,hl		;e47c	eb		.
	ld hl,0f313h		;e47d	21 13 f3	! . .
	ld a,(de)		;e480	1a		.
	cp (hl)			;e481	be		.
	ret nz			;e482	c0		.
	inc de			;e483	13		.
	inc hl			;e484	23		#
	ld a,(de)		;e485	1a		.
	cp (hl)			;e486	be		.
	ret			;e487	c9		.
sub_e488h:
	ld a,(0f35bh)		;e488	3a 5b f3	: [ .
	or a			;e48b	b7		.
	jp nz,le77fh		;e48c	c2 7f e7	. . .
	call sub_e4ach		;e48f	cd ac e4	. . .
	jp le574h		;e492	c3 74 e5	. t .
sub_e495h:
	ld a,(0f329h)		;e495	3a 29 f3	: ) .
	or a			;e498	b7		.
	jp nz,le49fh		;e499	c2 9f e4	. . .
	ld (0f323h),a		;e49c	32 23 f3	2 # .
le49fh:
	ld a,(0f35bh)		;e49f	3a 5b f3	: [ .
	or a			;e4a2	b7		.
	jp nz,le79ah		;e4a3	c2 9a e7	. . .
	call sub_e4ach		;e4a6	cd ac e4	. . .
	jp le52ah		;e4a9	c3 2a e5	. * .
sub_e4ach:
	ld a,(0f31ah)		;e4ac	3a 1a f3	: . .
	ld c,a			;e4af	4f		O
	ld a,(0f333h)		;e4b0	3a 33 f3	: 3 .
	ld b,a			;e4b3	47		G
	dec a			;e4b4	3d		=
	cp c			;e4b5	b9		.
	ld a,(0f317h)		;e4b6	3a 17 f3	: . .
	jp nc,le4c7h		;e4b9	d2 c7 e4	. . .
	or 004h			;e4bc	f6 04		. .
	ld (0f339h),a		;e4be	32 39 f3	2 9 .
	ld a,c			;e4c1	79		y
	sub b			;e4c2	90		.
	ld c,a			;e4c3	4f		O
	jp le4cah		;e4c4	c3 ca e4	. . .
le4c7h:
	ld (0f339h),a		;e4c7	32 39 f3	2 9 .
le4cah:
	ld b,000h		;e4ca	06 00		. .
	ld hl,(0f358h)		;e4cc	2a 58 f3	* X .
	add hl,bc		;e4cf	09		.
	ld a,(hl)		;e4d0	7e		~
	ld (0f33dh),a		;e4d1	32 3d f3	2 = .
	ld a,(0f318h)		;e4d4	3a 18 f3	: . .
	ld (0f33ch),a		;e4d7	32 3c f3	2 < .
	ld hl,0ee81h		;e4da	21 81 ee	! . .
	ld (0f33ah),hl		;e4dd	22 3a f3	" : .
	ld a,(0f317h)		;e4e0	3a 17 f3	: . .
	ld hl,0f31ch		;e4e3	21 1c f3	! . .
	cp (hl)			;e4e6	be		.
	jp nz,le4fah		;e4e7	c2 fa e4	. . .
	ld a,(0f318h)		;e4ea	3a 18 f3	: . .
	ld hl,0f31dh		;e4ed	21 1d f3	! . .
	cp (hl)			;e4f0	be		.
	jp nz,le4fah		;e4f1	c2 fa e4	. . .
	ld a,(0f319h)		;e4f4	3a 19 f3	: . .
	inc hl			;e4f7	23		#
	cp (hl)			;e4f8	be		.
	ret z			;e4f9	c8		.
le4fah:
	ld a,(0f317h)		;e4fa	3a 17 f3	: . .
	ld (0f31ch),a		;e4fd	32 1c f3	2 . .
	ld hl,(0f318h)		;e500	2a 18 f3	* . .
	ld (0f31dh),hl		;e503	22 1d f3	" . .
	call sub_e6b8h		;e506	cd b8 e6	. . .
	call sub_e682h		;e509	cd 82 e6	. . .
	call sub_e6bfh		;e50c	cd bf e6	. . .
	ld a,(0f339h)		;e50f	3a 39 f3	: 9 .
	and 003h		;e512	e6 03		. .
	add a,020h		;e514	c6 20		.  
	cp b			;e516	b8		.
	ret z			;e517	c8		.
sub_e518h:
	call sub_e6b8h		;e518	cd b8 e6	. . .
	call sub_e639h		;e51b	cd 39 e6	. 9 .
	push bc			;e51e	c5		.
	call sub_e6bfh		;e51f	cd bf e6	. . .
	call sub_e682h		;e522	cd 82 e6	. . .
	call sub_e6bfh		;e525	cd bf e6	. . .
	pop bc			;e528	c1		.
	ret			;e529	c9		.
le52ah:
	ld a,00ah		;e52a	3e 0a		> .
	ld (0f33eh),a		;e52c	32 3e f3	2 > .
le52fh:
	call sub_e59eh		;e52f	cd 9e e5	. . .
	call sub_e6b8h		;e532	cd b8 e6	. . .
	ld hl,(0f330h)		;e535	2a 30 f3	* 0 .
	ld c,(hl)		;e538	4e		N
	inc hl			;e539	23		#
	ld b,(hl)		;e53a	46		F
	inc hl			;e53b	23		#
	call sub_e6f7h		;e53c	cd f7 e6	. . .
	call sub_e594h		;e53f	cd 94 e5	. . .
	call sub_e6ceh		;e542	cd ce e6	. . .
	ld c,000h		;e545	0e 00		. .
le547h:
	ld hl,0f33fh		;e547	21 3f f3	! ? .
	ld a,(hl)		;e54a	7e		~
	and 0f8h		;e54b	e6 f8		. .
	ret z			;e54d	c8		.
	and 008h		;e54e	e6 08		. .
	jp nz,le56ah		;e550	c2 6a e5	. j .
	ld a,(0f33eh)		;e553	3a 3e f3	: > .
	dec a			;e556	3d		=
	ld (0f33eh),a		;e557	32 3e f3	2 > .
	jp z,le56ah		;e55a	ca 6a e5	. j .
	cp 005h			;e55d	fe 05		. .
	call z,sub_e518h	;e55f	cc 18 e5	. . .
	xor a			;e562	af		.
	cp c			;e563	b9		.
	jp z,le52fh		;e564	ca 2f e5	. / .
	jp le579h		;e567	c3 79 e5	. y .
le56ah:
	ld a,c			;e56a	79		y
	ld (0f321h),a		;e56b	32 21 f3	2 ! .
	ld a,001h		;e56e	3e 01		> .
	ld (0f32ah),a		;e570	32 2a f3	2 * .
	ret			;e573	c9		.
le574h:
	ld a,00ah		;e574	3e 0a		> .
	ld (0f33eh),a		;e576	32 3e f3	2 > .
le579h:
	call sub_e59eh		;e579	cd 9e e5	. . .
	call sub_e6b8h		;e57c	cd b8 e6	. . .
	ld hl,(0f330h)		;e57f	2a 30 f3	* 0 .
	ld c,(hl)		;e582	4e		N
	inc hl			;e583	23		#
	ld b,(hl)		;e584	46		F
	inc hl			;e585	23		#
	call sub_e6d6h		;e586	cd d6 e6	. . .
	call sub_e599h		;e589	cd 99 e5	. . .
	call sub_e6ceh		;e58c	cd ce e6	. . .
	ld c,001h		;e58f	0e 01		. .
	jp le547h		;e591	c3 47 e5	. G .
sub_e594h:
	ld a,006h		;e594	3e 06		> .
	jp le701h		;e596	c3 01 e7	. . .
sub_e599h:
	ld a,005h		;e599	3e 05		> .
	jp le701h		;e59b	c3 01 e7	. . .
sub_e59eh:
	in a,(014h)		;e59e	db 14		. .
	and 080h		;e5a0	e6 80		. .
	ret z			;e5a2	c8		.
	di			;e5a3	f3		.
	ld hl,(0ffe1h)		;e5a4	2a e1 ff	* . .
	ld a,l			;e5a7	7d		}
	or h			;e5a8	b4		.
	ld hl,(0ffe7h)		;e5a9	2a e7 ff	* . .
	ld (0ffe1h),hl		;e5ac	22 e1 ff	" . .
	ei			;e5af	fb		.
	ret nz			;e5b0	c0		.
	ld a,001h		;e5b1	3e 01		> .
	out (014h),a		;e5b3	d3 14		. .
	ld hl,00032h		;e5b5	21 32 00	! 2 .
	call sub_e5c6h		;e5b8	cd c6 e5	. . .
	ret			;e5bb	c9		.
sub_e5bch:
	in a,(014h)		;e5bc	db 14		. .
	and 080h		;e5be	e6 80		. .
	ret z			;e5c0	c8		.
	ld a,000h		;e5c1	3e 00		> .
	out (014h),a		;e5c3	d3 14		. .
	ret			;e5c5	c9		.
sub_e5c6h:
	ld (0ffe3h),hl		;e5c6	22 e3 ff	" . .
le5c9h:
	ld hl,(0ffe3h)		;e5c9	2a e3 ff	* . .
	ld a,l			;e5cc	7d		}
	or h			;e5cd	b4		.
	jp nz,le5c9h		;e5ce	c2 c9 e5	. . .
	ret			;e5d1	c9		.
	ld a,(0f322h)		;e5d2	3a 22 f3	: " .
	or a			;e5d5	b7		.
	jr nz,le5dbh		;e5d6	20 03		  .
	ld (0f321h),a		;e5d8	32 21 f3	2 ! .
le5dbh:
	ld a,(0f35bh)		;e5db	3a 5b f3	: [ .
	and a			;e5de	a7		.
	jp z,le608h		;e5df	ca 08 e6	. . .
	ld a,(0f312h)		;e5e2	3a 12 f3	: . .
	ld (0f31ch),a		;e5e5	32 1c f3	2 . .
	ld hl,(0f351h)		;e5e8	2a 51 f3	* Q .
	ld de,0000dh		;e5eb	11 0d 00	. . .
	add hl,de		;e5ee	19		.
	ld e,(hl)		;e5ef	5e		^
	inc hl			;e5f0	23		#
	ld d,(hl)		;e5f1	56		V
	ld (0f31dh),de		;e5f2	ed 53 1d f3	. S . .
	call sub_e7fah		;e5f6	cd fa e7	. . .
	call sub_e85dh		;e5f9	cd 5d e8	. ] .
	ret nc			;e5fc	d0		.
	call sub_e86fh		;e5fd	cd 6f e8	. o .
le600h:
	in a,(067h)		;e600	db 67		. g
	and 010h		;e602	e6 10		. .
	jp z,le600h		;e604	ca 00 e6	. . .
	ret			;e607	c9		.
le608h:
	call sub_e59eh		;e608	cd 9e e5	. . .
	ld a,(0f312h)		;e60b	3a 12 f3	: . .
	ld (0f339h),a		;e60e	32 39 f3	2 9 .
	ld (0f31ch),a		;e611	32 1c f3	2 . .
	xor a			;e614	af		.
	ld (0f31dh),a		;e615	32 1d f3	2 . .
	ld (0f31eh),a		;e618	32 1e f3	2 . .
	call sub_e6b8h		;e61b	cd b8 e6	. . .
	call sub_e639h		;e61e	cd 39 e6	. 9 .
	call sub_e6bfh		;e621	cd bf e6	. . .
	ret			;e624	c9		.
le625h:
	in a,(004h)		;e625	db 04		. .
	and 0c0h		;e627	e6 c0		. .
	cp 080h			;e629	fe 80		. .
	jp nz,le625h		;e62b	c2 25 e6	. % .
	ret			;e62e	c9		.
le62fh:
	in a,(004h)		;e62f	db 04		. .
	and 0c0h		;e631	e6 c0		. .
	cp 0c0h			;e633	fe c0		. .
	jp nz,le62fh		;e635	c2 2f e6	. / .
	ret			;e638	c9		.
sub_e639h:
	call le625h		;e639	cd 25 e6	. % .
	ld a,007h		;e63c	3e 07		> .
	out (005h),a		;e63e	d3 05		. .
	call le625h		;e640	cd 25 e6	. % .
	ld a,(0f339h)		;e643	3a 39 f3	: 9 .
	and 003h		;e646	e6 03		. .
	out (005h),a		;e648	d3 05		. .
	ret			;e64a	c9		.
	call le625h		;e64b	cd 25 e6	. % .
	ld a,004h		;e64e	3e 04		> .
	out (005h),a		;e650	d3 05		. .
	call le625h		;e652	cd 25 e6	. % .
	ld a,(0f339h)		;e655	3a 39 f3	: 9 .
	and 003h		;e658	e6 03		. .
	out (005h),a		;e65a	d3 05		. .
	call le62fh		;e65c	cd 2f e6	. / .
	in a,(005h)		;e65f	db 05		. .
	ld (0f33fh),a		;e661	32 3f f3	2 ? .
	ret			;e664	c9		.
sub_e665h:
	call le625h		;e665	cd 25 e6	. % .
	ld a,008h		;e668	3e 08		> .
	out (005h),a		;e66a	d3 05		. .
	call le62fh		;e66c	cd 2f e6	. / .
	in a,(005h)		;e66f	db 05		. .
	ld (0f33fh),a		;e671	32 3f f3	2 ? .
	and 0c0h		;e674	e6 c0		. .
	cp 080h			;e676	fe 80		. .
	ret z			;e678	c8		.
	call le62fh		;e679	cd 2f e6	. / .
	in a,(005h)		;e67c	db 05		. .
	ld (0f340h),a		;e67e	32 40 f3	2 @ .
	ret			;e681	c9		.
sub_e682h:
	call le625h		;e682	cd 25 e6	. % .
	ld a,00fh		;e685	3e 0f		> .
	out (005h),a		;e687	d3 05		. .
	call le625h		;e689	cd 25 e6	. % .
	ld a,(0f339h)		;e68c	3a 39 f3	: 9 .
	and 003h		;e68f	e6 03		. .
	out (005h),a		;e691	d3 05		. .
	call le625h		;e693	cd 25 e6	. % .
	ld a,(0f33ch)		;e696	3a 3c f3	: < .
	out (005h),a		;e699	d3 05		. .
	ret			;e69b	c9		.
sub_e69ch:
	ld hl,0f33fh		;e69c	21 3f f3	! ? .
	ld d,007h		;e69f	16 07		. .
le6a1h:
	call le62fh		;e6a1	cd 2f e6	. / .
	in a,(005h)		;e6a4	db 05		. .
	ld (hl),a		;e6a6	77		w
	inc hl			;e6a7	23		#
	ld a,004h		;e6a8	3e 04		> .
le6aah:
	dec a			;e6aa	3d		=
	jp nz,le6aah		;e6ab	c2 aa e6	. . .
	in a,(004h)		;e6ae	db 04		. .
	and 010h		;e6b0	e6 10		. .
	ret z			;e6b2	c8		.
	dec d			;e6b3	15		.
	jp nz,le6a1h		;e6b4	c2 a1 e6	. . .
	ret			;e6b7	c9		.
sub_e6b8h:
	di			;e6b8	f3		.
	xor a			;e6b9	af		.
	ld (0f34fh),a		;e6ba	32 4f f3	2 O .
	ei			;e6bd	fb		.
	ret			;e6be	c9		.
sub_e6bfh:
	call sub_e6ceh		;e6bf	cd ce e6	. . .
	ld a,(0f33fh)		;e6c2	3a 3f f3	: ? .
	ld b,a			;e6c5	47		G
	ld a,(0f340h)		;e6c6	3a 40 f3	: @ .
	ld c,a			;e6c9	4f		O
	call sub_e6b8h		;e6ca	cd b8 e6	. . .
	ret			;e6cd	c9		.
sub_e6ceh:
	ld a,(0f34fh)		;e6ce	3a 4f f3	: O .
	or a			;e6d1	b7		.
	jp z,sub_e6ceh		;e6d2	ca ce e6	. . .
	ret			;e6d5	c9		.
sub_e6d6h:
	ld a,005h		;e6d6	3e 05		> .
	di			;e6d8	f3		.
	out (0fah),a		;e6d9	d3 fa		. .
	ld a,049h		;e6db	3e 49		> I
le6ddh:
	out (0fbh),a		;e6dd	d3 fb		. .
	out (0fch),a		;e6df	d3 fc		. .
	ld a,(0f33ah)		;e6e1	3a 3a f3	: : .
	out (0f2h),a		;e6e4	d3 f2		. .
	ld a,(0f33bh)		;e6e6	3a 3b f3	: ; .
	out (0f2h),a		;e6e9	d3 f2		. .
	ld a,c			;e6eb	79		y
	out (0f3h),a		;e6ec	d3 f3		. .
	ld a,b			;e6ee	78		x
	out (0f3h),a		;e6ef	d3 f3		. .
	ld a,001h		;e6f1	3e 01		> .
	out (0fah),a		;e6f3	d3 fa		. .
	ei			;e6f5	fb		.
	ret			;e6f6	c9		.
sub_e6f7h:
	ld a,005h		;e6f7	3e 05		> .
	di			;e6f9	f3		.
	out (0fah),a		;e6fa	d3 fa		. .
	ld a,045h		;e6fc	3e 45		> E
	jp le6ddh		;e6fe	c3 dd e6	. . .
le701h:
	push af			;e701	f5		.
	di			;e702	f3		.
	call le625h		;e703	cd 25 e6	. % .
	pop af			;e706	f1		.
	ld b,(hl)		;e707	46		F
	inc hl			;e708	23		#
	add a,b			;e709	80		.
	out (005h),a		;e70a	d3 05		. .
	call le625h		;e70c	cd 25 e6	. % .
	ld a,(0f339h)		;e70f	3a 39 f3	: 9 .
	out (005h),a		;e712	d3 05		. .
	call le625h		;e714	cd 25 e6	. % .
	ld a,(0f33ch)		;e717	3a 3c f3	: < .
	out (005h),a		;e71a	d3 05		. .
	call le625h		;e71c	cd 25 e6	. % .
	ld a,(0f339h)		;e71f	3a 39 f3	: 9 .
	rra			;e722	1f		.
	rra			;e723	1f		.
	and 003h		;e724	e6 03		. .
	out (005h),a		;e726	d3 05		. .
	call le625h		;e728	cd 25 e6	. % .
	ld a,(0f33dh)		;e72b	3a 3d f3	: = .
	out (005h),a		;e72e	d3 05		. .
	call le625h		;e730	cd 25 e6	. % .
	ld a,(hl)		;e733	7e		~
	inc hl			;e734	23		#
	out (005h),a		;e735	d3 05		. .
	call le625h		;e737	cd 25 e6	. % .
	ld a,(hl)		;e73a	7e		~
	inc hl			;e73b	23		#
	out (005h),a		;e73c	d3 05		. .
	call le625h		;e73e	cd 25 e6	. % .
	ld a,(hl)		;e741	7e		~
	out (005h),a		;e742	d3 05		. .
	call le625h		;e744	cd 25 e6	. % .
	ld a,(0f35ah)		;e747	3a 5a f3	: Z .
	out (005h),a		;e74a	d3 05		. .
	ei			;e74c	fb		.
	ret			;e74d	c9		.
	ld (0f34bh),sp		;e74e	ed 73 4b f3	. s K .
	ld sp,0f620h		;e752	31 20 f6	1   .
	push af			;e755	f5		.
	push bc			;e756	c5		.
	push de			;e757	d5		.
	push hl			;e758	e5		.
	ld a,0ffh		;e759	3e ff		> .
	ld (0f34fh),a		;e75b	32 4f f3	2 O .
	ld a,005h		;e75e	3e 05		> .
le760h:
	dec a			;e760	3d		=
	jp nz,le760h		;e761	c2 60 e7	. ` .
	in a,(004h)		;e764	db 04		. .
	and 010h		;e766	e6 10		. .
	jp nz,le771h		;e768	c2 71 e7	. q .
	call sub_e665h		;e76b	cd 65 e6	. e .
	jp le774h		;e76e	c3 74 e7	. t .
le771h:
	call sub_e69ch		;e771	cd 9c e6	. . .
le774h:
	pop hl			;e774	e1		.
	pop de			;e775	d1		.
	pop bc			;e776	c1		.
	pop af			;e777	f1		.
	ld sp,(0f34bh)		;e778	ed 7b 4b f3	. { K .
	ei			;e77c	fb		.
	reti			;e77d	ed 4d		. M
le77fh:
	call sub_e7b5h		;e77f	cd b5 e7	. . .
	call nc,sub_e7fah	;e782	d4 fa e7	. . .
	call sub_e87bh		;e785	cd 7b e8	. { .
	ret nc			;e788	d0		.
	ld hl,(0f330h)		;e789	2a 30 f3	* 0 .
	ld c,(hl)		;e78c	4e		N
	inc hl			;e78d	23		#
	ld b,(hl)		;e78e	46		F
	call sub_e89ah		;e78f	cd 9a e8	. . .
	ld a,030h		;e792	3e 30		> 0
	out (067h),a		;e794	d3 67		. g
	call sub_e86fh		;e796	cd 6f e8	. o .
	ret			;e799	c9		.
le79ah:
	call sub_e7b5h		;e79a	cd b5 e7	. . .
	call nc,sub_e7fah	;e79d	d4 fa e7	. . .
	call sub_e87bh		;e7a0	cd 7b e8	. { .
	ret nc			;e7a3	d0		.
	ld hl,(0f330h)		;e7a4	2a 30 f3	* 0 .
	ld c,(hl)		;e7a7	4e		N
	inc hl			;e7a8	23		#
	ld b,(hl)		;e7a9	46		F
	call sub_e890h		;e7aa	cd 90 e8	. . .
	ld a,028h		;e7ad	3e 28		> (
	out (067h),a		;e7af	d3 67		. g
	call sub_e86fh		;e7b1	cd 6f e8	. o .
	ret			;e7b4	c9		.
sub_e7b5h:
	ld hl,0ee81h		;e7b5	21 81 ee	! . .
	ld (0f33ah),hl		;e7b8	22 3a f3	" : .
	ld a,(0f317h)		;e7bb	3a 17 f3	: . .
	ld hl,0f31ch		;e7be	21 1c f3	! . .
	cp (hl)			;e7c1	be		.
	jp nz,le7d9h		;e7c2	c2 d9 e7	. . .
	ld a,(0f318h)		;e7c5	3a 18 f3	: . .
	ld hl,0f31dh		;e7c8	21 1d f3	! . .
	cp (hl)			;e7cb	be		.
	jp nz,le7d9h		;e7cc	c2 d9 e7	. . .
	ld a,(0f319h)		;e7cf	3a 19 f3	: . .
	inc hl			;e7d2	23		#
	cp (hl)			;e7d3	be		.
	jp nz,le7d9h		;e7d4	c2 d9 e7	. . .
	and a			;e7d7	a7		.
	ret			;e7d8	c9		.
le7d9h:
	ld a,(0f317h)		;e7d9	3a 17 f3	: . .
	ld (0f31ch),a		;e7dc	32 1c f3	2 . .
	ld hl,(0f318h)		;e7df	2a 18 f3	* . .
	ld (0f31dh),hl		;e7e2	22 1d f3	" . .
	call sub_e7fah		;e7e5	cd fa e7	. . .
	call sub_e85dh		;e7e8	cd 5d e8	. ] .
	jp nc,le7f8h		;e7eb	d2 f8 e7	. . .
	call sub_e86fh		;e7ee	cd 6f e8	. o .
le7f1h:
	in a,(067h)		;e7f1	db 67		. g
	and 010h		;e7f3	e6 10		. .
	jp z,le7f1h		;e7f5	ca f1 e7	. . .
le7f8h:
	scf			;e7f8	37		7
	ret			;e7f9	c9		.
sub_e7fah:
	ld hl,(0f330h)		;e7fa	2a 30 f3	* 0 .
	ld de,0ffffh		;e7fd	11 ff ff	. . .
	ex de,hl		;e800	eb		.
	add hl,de		;e801	19		.
	xor a			;e802	af		.
	ld c,(hl)		;e803	4e		N
	ld b,000h		;e804	06 00		. .
	ld hl,(0f31ah)		;e806	2a 1a f3	* . .
le809h:
	and a			;e809	a7		.
	sbc hl,bc		;e80a	ed 42		. B
	jp c,le813h		;e80c	da 13 e8	. . .
	inc a			;e80f	3c		<
	jp le809h		;e810	c3 09 e8	. . .
le813h:
	add hl,bc		;e813	09		.
	push af			;e814	f5		.
	ld a,l			;e815	7d		}
	out (063h),a		;e816	d3 63		. c
	ld a,(0f31ch)		;e818	3a 1c f3	: . .
	ld c,000h		;e81b	0e 00		. .
	ld hl,0f335h		;e81d	21 35 f3	! 5 .
	sub (hl)		;e820	96		.
	ld hl,0f336h		;e821	21 36 f3	! 6 .
	cp (hl)			;e824	be		.
	jp c,le83bh		;e825	da 3b e8	. ; .
	sub (hl)		;e828	96		.
	inc c			;e829	0c		.
	ld hl,0f337h		;e82a	21 37 f3	! 7 .
	cp (hl)			;e82d	be		.
	jp c,le83bh		;e82e	da 3b e8	. ; .
	sub (hl)		;e831	96		.
	inc c			;e832	0c		.
	ld hl,0f338h		;e833	21 38 f3	! 8 .
	cp (hl)			;e836	be		.
	jp c,le83bh		;e837	da 3b e8	. ; .
	inc c			;e83a	0c		.
le83bh:
	sla c			;e83b	cb 21		. !
	sla c			;e83d	cb 21		. !
	sla c			;e83f	cb 21		. !
	pop af			;e841	f1		.
	or c			;e842	b1		.
	ld hl,00005h		;e843	21 05 00	! . .
	add hl,de		;e846	19		.
	or (hl)			;e847	b6		.
	out (066h),a		;e848	d3 66		. f
	ld hl,(0f31dh)		;e84a	2a 1d f3	* . .
	ld a,l			;e84d	7d		}
	out (064h),a		;e84e	d3 64		. d
	ld a,h			;e850	7c		|
	and 003h		;e851	e6 03		. .
	out (065h),a		;e853	d3 65		. e
	ld hl,00006h		;e855	21 06 00	! . .
	add hl,de		;e858	19		.
	ld a,(hl)		;e859	7e		~
	out (061h),a		;e85a	d3 61		. a
	ret			;e85c	c9		.
sub_e85dh:
	ld hl,(0f330h)		;e85d	2a 30 f3	* 0 .
	ld de,00005h		;e860	11 05 00	. . .
	add hl,de		;e863	19		.
	ld a,070h		;e864	3e 70		> p
	or (hl)			;e866	b6		.
	call sub_e87bh		;e867	cd 7b e8	. { .
	ret nc			;e86a	d0		.
	out (067h),a		;e86b	d3 67		. g
	scf			;e86d	37		7
	ret			;e86e	c9		.
sub_e86fh:
	ld a,(0f34dh)		;e86f	3a 4d f3	: M .
	or a			;e872	b7		.
	jp z,sub_e86fh		;e873	ca 6f e8	. o .
	xor a			;e876	af		.
	ld (0f34dh),a		;e877	32 4d f3	2 M .
	ret			;e87a	c9		.
sub_e87bh:
	push af			;e87b	f5		.
	in a,(067h)		;e87c	db 67		. g
	and 050h		;e87e	e6 50		. P
	cp 050h			;e880	fe 50		. P
	jp z,le88dh		;e882	ca 8d e8	. . .
	ld a,0bbh		;e885	3e bb		> .
	ld (0f32ah),a		;e887	32 2a f3	2 * .
	pop af			;e88a	f1		.
	and a			;e88b	a7		.
	ret			;e88c	c9		.
le88dh:
	pop af			;e88d	f1		.
	scf			;e88e	37		7
	ret			;e88f	c9		.
sub_e890h:
	ld a,004h		;e890	3e 04		> .
	di			;e892	f3		.
	out (0fah),a		;e893	d3 fa		. .
	ld a,044h		;e895	3e 44		> D
	jp le8a1h		;e897	c3 a1 e8	. . .
sub_e89ah:
	ld a,004h		;e89a	3e 04		> .
	di			;e89c	f3		.
	out (0fah),a		;e89d	d3 fa		. .
	ld a,048h		;e89f	3e 48		> H
le8a1h:
	out (0fbh),a		;e8a1	d3 fb		. .
	out (0fch),a		;e8a3	d3 fc		. .
	ld a,(0f33ah)		;e8a5	3a 3a f3	: : .
	out (0f0h),a		;e8a8	d3 f0		. .
	ld a,(0f33bh)		;e8aa	3a 3b f3	: ; .
	out (0f0h),a		;e8ad	d3 f0		. .
	ld a,c			;e8af	79		y
	out (0f1h),a		;e8b0	d3 f1		. .
	ld a,b			;e8b2	78		x
	out (0f1h),a		;e8b3	d3 f1		. .
	ld a,000h		;e8b5	3e 00		> .
	out (0fah),a		;e8b7	d3 fa		. .
	ei			;e8b9	fb		.
	ret			;e8ba	c9		.
	out (066h),a		;e8bb	d3 66		. f
	xor a			;e8bd	af		.
	out (061h),a		;e8be	d3 61		. a
	out (062h),a		;e8c0	d3 62		. b
	out (063h),a		;e8c2	d3 63		. c
	out (064h),a		;e8c4	d3 64		. d
	out (065h),a		;e8c6	d3 65		. e
	ld a,010h		;e8c8	3e 10		> .
	or b			;e8ca	b0		.
	out (067h),a		;e8cb	d3 67		. g
	ret			;e8cd	c9		.
	out (066h),a		;e8ce	d3 66		. f
	ld a,b			;e8d0	78		x
	out (061h),a		;e8d1	d3 61		. a
	ld a,c			;e8d3	79		y
	out (062h),a		;e8d4	d3 62		. b
	ld a,e			;e8d6	7b		{
	out (064h),a		;e8d7	d3 64		. d
	ld a,d			;e8d9	7a		z
	out (065h),a		;e8da	d3 65		. e
	ld hl,(0f32eh)		;e8dc	2a 2e f3	* . .
	ld (0f33ah),hl		;e8df	22 3a f3	" : .
	call sub_e87bh		;e8e2	cd 7b e8	. { .
	jp nc,le8fah		;e8e5	d2 fa e8	. . .
	ld bc,001ffh		;e8e8	01 ff 01	. . .
	call sub_e89ah		;e8eb	cd 9a e8	. . .
	ld a,050h		;e8ee	3e 50		> P
	out (067h),a		;e8f0	d3 67		. g
	call sub_e86fh		;e8f2	cd 6f e8	. o .
	ld a,(0f32ah)		;e8f5	3a 2a f3	: * .
	and a			;e8f8	a7		.
	ret z			;e8f9	c8		.
le8fah:
	xor a			;e8fa	af		.
	ld (0f32ah),a		;e8fb	32 2a f3	2 * .
	ld a,001h		;e8fe	3e 01		> .
	ret			;e900	c9		.
	ld (0f34bh),sp		;e901	ed 73 4b f3	. s K .
	ld sp,0f620h		;e905	31 20 f6	1   .
	push af			;e908	f5		.
	push bc			;e909	c5		.
	push de			;e90a	d5		.
	push hl			;e90b	e5		.
	ld a,0ffh		;e90c	3e ff		> .
	ld (0f34dh),a		;e90e	32 4d f3	2 M .
	in a,(067h)		;e911	db 67		. g
	ld (0f347h),a		;e913	32 47 f3	2 G .
	and 001h		;e916	e6 01		. .
	jp z,le92ch		;e918	ca 2c e9	. , .
	in a,(061h)		;e91b	db 61		. a
	ld (0f348h),a		;e91d	32 48 f3	2 H .
	ld hl,(0f349h)		;e920	2a 49 f3	* I .
	inc hl			;e923	23		#
	ld (0f349h),hl		;e924	22 49 f3	" I .
	ld a,0bbh		;e927	3e bb		> .
	ld (0f32ah),a		;e929	32 2a f3	2 * .
le92ch:
	pop hl			;e92c	e1		.
	pop de			;e92d	d1		.
	pop bc			;e92e	c1		.
	pop af			;e92f	f1		.
	ld sp,(0f34bh)		;e930	ed 7b 4b f3	. { K .
	ei			;e934	fb		.
	reti			;e935	ed 4d		. M
le937h:
	ld bc,00d07h		;e937	01 07 0d	. . .
	inc de			;e93a	13		.
	add hl,de		;e93b	19		.
	dec b			;e93c	05		.
	dec bc			;e93d	0b		.
	ld de,00317h		;e93e	11 17 03	. . .
	add hl,bc		;e941	09		.
	rrca			;e942	0f		.
	dec d			;e943	15		.
	ld (bc),a		;e944	02		.
	ex af,af'		;e945	08		.
	ld c,014h		;e946	0e 14		. .
	ld a,(de)		;e948	1a		.
	ld b,00ch		;e949	06 0c		. .
	ld (de),a		;e94b	12		.
	jr $+6			;e94c	18 04		. .
	ld a,(bc)		;e94e	0a		.
	djnz le967h		;e94f	10 16		. .
	ld bc,00905h		;e951	01 05 09	. . .
	dec c			;e954	0d		.
	ld (bc),a		;e955	02		.
	ld b,00ah		;e956	06 0a		. .
	ld c,003h		;e958	0e 03		. .
	rlca			;e95a	07		.
	dec bc			;e95b	0b		.
	rrca			;e95c	0f		.
	inc b			;e95d	04		.
	ex af,af'		;e95e	08		.
	inc c			;e95f	0c		.
	ld bc,00503h		;e960	01 03 05	. . .
	rlca			;e963	07		.
	add hl,bc		;e964	09		.
	ld (bc),a		;e965	02		.
	inc b			;e966	04		.
le967h:
	ld b,008h		;e967	06 08		. .
	ld a,(bc)		;e969	0a		.
	ld bc,00302h		;e96a	01 02 03	. . .
	inc b			;e96d	04		.
	dec b			;e96e	05		.
	ld b,007h		;e96f	06 07		. .
	ex af,af'		;e971	08		.
	add hl,bc		;e972	09		.
	ld a,(bc)		;e973	0a		.
	dec bc			;e974	0b		.
	inc c			;e975	0c		.
	dec c			;e976	0d		.
	ld c,00fh		;e977	0e 0f		. .
	djnz le98ch		;e979	10 11		. .
	ld (de),a		;e97b	12		.
	inc de			;e97c	13		.
	inc d			;e97d	14		.
	dec d			;e97e	15		.
	ld d,017h		;e97f	16 17		. .
	jr le99ch		;e981	18 19		. .
	ld a,(de)		;e983	1a		.
	ld a,(de)		;e984	1a		.
	nop			;e985	00		.
	inc bc			;e986	03		.
	rlca			;e987	07		.
	nop			;e988	00		.
	jp p,03f00h		;e989	f2 00 3f	. . ?
le98ch:
	nop			;e98c	00		.
	ret nz			;e98d	c0		.
	nop			;e98e	00		.
	djnz le991h		;e98f	10 00		. .
le991h:
	ld (bc),a		;e991	02		.
	nop			;e992	00		.
	ld a,b			;e993	78		x
	nop			;e994	00		.
	inc b			;e995	04		.
	rrca			;e996	0f		.
	nop			;e997	00		.
	pop bc			;e998	c1		.
	ld bc,0007fh		;e999	01 7f 00	. . .
le99ch:
	ret nz			;e99c	c0		.
	nop			;e99d	00		.
	jr nz,le9a0h		;e99e	20 00		  .
le9a0h:
	ld (bc),a		;e9a0	02		.
	nop			;e9a1	00		.
	ld c,b			;e9a2	48		H
	nop			;e9a3	00		.
	inc b			;e9a4	04		.
	rrca			;e9a5	0f		.
	ld bc,00086h		;e9a6	01 86 00	. . .
	ld a,a			;e9a9	7f		.
	nop			;e9aa	00		.
	ret nz			;e9ab	c0		.
	nop			;e9ac	00		.
	jr nz,le9afh		;e9ad	20 00		  .
le9afh:
	ld (bc),a		;e9af	02		.
	nop			;e9b0	00		.
	ld d,b			;e9b1	50		P
	nop			;e9b2	00		.
	inc b			;e9b3	04		.
	rrca			;e9b4	0f		.
	nop			;e9b5	00		.
	add a,l			;e9b6	85		.
	ld bc,0007fh		;e9b7	01 7f 00	. . .
	ret nz			;e9ba	c0		.
	nop			;e9bb	00		.
	jr nz,le9beh		;e9bc	20 00		  .
le9beh:
	ld (bc),a		;e9be	02		.
le9bfh:
	nop			;e9bf	00		.
	add a,b			;e9c0	80		.
	ld bc,00f04h		;e9c1	01 04 0f	. . .
	nop			;e9c4	00		.
	pop bc			;e9c5	c1		.
	ld bc,0007fh		;e9c6	01 7f 00	. . .
	ret nz			;e9c9	c0		.
	nop			;e9ca	00		.
	nop			;e9cb	00		.
	nop			;e9cc	00		.
	inc bc			;e9cd	03		.
	nop			;e9ce	00		.
	add a,b			;e9cf	80		.
	ld bc,00f04h		;e9d0	01 04 0f	. . .
	ld bc,00086h		;e9d3	01 86 00	. . .
	ld a,a			;e9d6	7f		.
	nop			;e9d7	00		.
	ret nz			;e9d8	c0		.
	nop			;e9d9	00		.
	nop			;e9da	00		.
	nop			;e9db	00		.
	inc bc			;e9dc	03		.
	nop			;e9dd	00		.
	add a,b			;e9de	80		.
le9dfh:
	ld bc,01f05h		;e9df	01 05 1f	. . .
	ld bc,001ebh		;e9e2	01 eb 01	. . .
	rst 38h			;e9e5	ff		.
	ld bc,000f0h		;e9e6	01 f0 00	. . .
	nop			;e9e9	00		.
	nop			;e9ea	00		.
	dec de			;e9eb	1b		.
	nop			;e9ec	00		.
	add a,b			;e9ed	80		.
	ld bc,03f06h		;e9ee	01 06 3f	. . ?
	inc bc			;e9f1	03		.
	ex de,hl		;e9f2	eb		.
	ld bc,001ffh		;e9f3	01 ff 01	. . .
	ret nz			;e9f6	c0		.
	nop			;e9f7	00		.
	nop			;e9f8	00		.
	nop			;e9f9	00		.
	dec de			;e9fa	1b		.
	nop			;e9fb	00		.
	add a,b			;e9fc	80		.
le9fdh:
	ld bc,07f07h		;e9fd	01 07 7f	. . .
	rlca			;ea00	07		.
	xor 001h		;ea01	ee 01		. .
	rst 38h			;ea03	ff		.
	ld bc,00080h		;ea04	01 80 00	. . .
	nop			;ea07	00		.
	nop			;ea08	00		.
	dec de			;ea09	1b		.
	nop			;ea0a	00		.
lea0bh:
	ld (bc),a		;ea0b	02		.
	nop			;ea0c	00		.
	ld (bc),a		;ea0d	02		.
	nop			;ea0e	00		.
	inc bc			;ea0f	03		.
	nop			;ea10	00		.
	dec de			;ea11	1b		.
	nop			;ea12	00		.
	nop			;ea13	00		.
	nop			;ea14	00		.
	nop			;ea15	00		.
	nop			;ea16	00		.
	nop			;ea17	00		.
	nop			;ea18	00		.
	nop			;ea19	00		.
	nop			;ea1a	00		.
lea1bh:
	add a,h			;ea1b	84		.
	jp (hl)			;ea1c	e9		.
	ex af,af'		;ea1d	08		.
	ld a,(de)		;ea1e	1a		.
	nop			;ea1f	00		.
	nop			;ea20	00		.
	ld bc,le937h		;ea21	01 37 e9	. 7 .
	add a,b			;ea24	80		.
	nop			;ea25	00		.
	jr nz,lea48h		;ea26	20 20		   
	jr nz,lea4ah		;ea28	20 20		   
	jr nz,le9bfh		;ea2a	20 93		  .
	jp (hl)			;ea2c	e9		.
	djnz leaa7h		;ea2d	10 78		. x
	nop			;ea2f	00		.
	inc bc			;ea30	03		.
	inc bc			;ea31	03		.
	ld d,c			;ea32	51		Q
	jp (hl)			;ea33	e9		.
	rst 38h			;ea34	ff		.
	nop			;ea35	00		.
	ld b,h			;ea36	44		D
	dec (hl)		;ea37	35		5
	ld (00043h),a		;ea38	32 43 00	2 C .
	and d			;ea3b	a2		.
	jp (hl)			;ea3c	e9		.
	djnz lea87h		;ea3d	10 48		. H
	nop			;ea3f	00		.
	inc bc			;ea40	03		.
	inc bc			;ea41	03		.
	ld h,b			;ea42	60		`
	jp (hl)			;ea43	e9		.
	rst 38h			;ea44	ff		.
	nop			;ea45	00		.
	jr nz,lea68h		;ea46	20 20		   
lea48h:
	jr nz,lea6ah		;ea48	20 20		   
lea4ah:
	jr nz,le9fdh		;ea4a	20 b1		  .
	jp (hl)			;ea4c	e9		.
	djnz lea9fh		;ea4d	10 50		. P
	nop			;ea4f	00		.
	inc bc			;ea50	03		.
	inc bc			;ea51	03		.
	ld h,b			;ea52	60		`
	jp (hl)			;ea53	e9		.
	rst 38h			;ea54	ff		.
	nop			;ea55	00		.
	ld d,d			;ea56	52		R
	ld b,e			;ea57	43		C
	scf			;ea58	37		7
	jr nc,lea8bh		;ea59	30 30		0 0
	ret nz			;ea5b	c0		.
	jp (hl)			;ea5c	e9		.
	djnz le9dfh		;ea5d	10 80		. .
	ld bc,00303h		;ea5f	01 03 03	. . .
	nop			;ea62	00		.
	nop			;ea63	00		.
	nop			;ea64	00		.
	rst 38h			;ea65	ff		.
	jr nz,leabbh		;ea66	20 53		  S
lea68h:
	ld c,a			;ea68	4f		O
	ld b,(hl)		;ea69	46		F
lea6ah:
	ld d,h			;ea6a	54		T
	rst 8			;ea6b	cf		.
	jp (hl)			;ea6c	e9		.
	djnz $-126		;ea6d	10 80		. .
	ld bc,00303h		;ea6f	01 03 03	. . .
	nop			;ea72	00		.
	nop			;ea73	00		.
	nop			;ea74	00		.
	rst 38h			;ea75	ff		.
	ld b,l			;ea76	45		E
	jr nz,$+52		;ea77	20 32		  2
	ld l,031h		;ea79	2e 31		. 1
	sbc a,0e9h		;ea7b	de e9		. .
	jr nz,$-126		;ea7d	20 80		  .
	ld bc,00303h		;ea7f	01 03 03	. . .
	nop			;ea82	00		.
	nop			;ea83	00		.
	nop			;ea84	00		.
	rst 38h			;ea85	ff		.
	nop			;ea86	00		.
lea87h:
	nop			;ea87	00		.
	nop			;ea88	00		.
	nop			;ea89	00		.
	nop			;ea8a	00		.
lea8bh:
	defb 0edh ;next byte illegal after ed	;ea8b	ed		.
	jp (hl)			;ea8c	e9		.
	ld b,b			;ea8d	40		@
	add a,b			;ea8e	80		.
	ld bc,00303h		;ea8f	01 03 03	. . .
	nop			;ea92	00		.
	nop			;ea93	00		.
	nop			;ea94	00		.
	rst 38h			;ea95	ff		.
	nop			;ea96	00		.
	nop			;ea97	00		.
	nop			;ea98	00		.
	nop			;ea99	00		.
	nop			;ea9a	00		.
	call m,080e9h		;ea9b	fc e9 80	. . .
	add a,b			;ea9e	80		.
lea9fh:
	ld bc,00303h		;ea9f	01 03 03	. . .
	nop			;eaa2	00		.
	nop			;eaa3	00		.
	nop			;eaa4	00		.
	rst 38h			;eaa5	ff		.
	ld e,d			;eaa6	5a		Z
leaa7h:
	dec l			;eaa7	2d		-
	jr c,$+50		;eaa8	38 30		8 0
	jr nz,$+28		;eaaa	20 1a		  .
leaach:
	ld a,a			;eaac	7f		.
	nop			;eaad	00		.
	nop			;eaae	00		.
	nop			;eaaf	00		.
	ld a,(de)		;eab0	1a		.
	rlca			;eab1	07		.
	ld c,l			;eab2	4d		M
	ld e,0ffh		;eab3	1e ff		. .
	ld bc,00240h		;eab5	01 40 02	. @ .
	rrca			;eab8	0f		.
	dec de			;eab9	1b		.
	ld c,l			;eaba	4d		M
leabbh:
	ld (de),a		;eabb	12		.
	rst 38h			;eabc	ff		.
	ld bc,00240h		;eabd	01 40 02	. @ .
	add hl,bc		;eac0	09		.
	dec de			;eac1	1b		.
	inc h			;eac2	24		$
	inc d			;eac3	14		.
	rst 38h			;eac4	ff		.
	ld bc,00240h		;eac5	01 40 02	. @ .
	ld a,(bc)		;eac8	0a		.
	ld a,(bc)		;eac9	0a		.
	ld d,b			;eaca	50		P
	djnz $+1		;eacb	10 ff		. .
	ld bc,00018h		;eacd	01 18 00	. . .
	nop			;ead0	00		.
	jr nz,lead3h		;ead1	20 00		  .
lead3h:
	djnz $+1		;ead3	10 ff		. .
	ld bc,00018h		;ead5	01 18 00	. . .
	nop			;ead8	00		.
	jr nz,leadbh		;ead9	20 00		  .
leadbh:
	djnz $+1		;eadb	10 ff		. .
	ld bc,00029h		;eadd	01 29 00	. ) .
	nop			;eae0	00		.
	jr nz,leae3h		;eae1	20 00		  .
leae3h:
	djnz $+1		;eae3	10 ff		. .
	ld bc,00053h		;eae5	01 53 00	. S .
	nop			;eae8	00		.
	jr nz,leaebh		;eae9	20 00		  .
leaebh:
	djnz $+1		;eaeb	10 ff		. .
	ld bc,000a6h		;eaed	01 a6 00	. . .
	nop			;eaf0	00		.
	jr nz,leaf3h		;eaf1	20 00		  .
leaf3h:
	nop			;eaf3	00		.
	nop			;eaf4	00		.
	nop			;eaf5	00		.
	nop			;eaf6	00		.
	nop			;eaf7	00		.
	nop			;eaf8	00		.
	nop			;eaf9	00		.
	nop			;eafa	00		.
	add a,c			;eafb	81		.
	ret p			;eafc	f0		.
	sub e			;eafd	93		.
	jp (hl)			;eafe	e9		.
	ld c,b			;eaff	48		H
	pop af			;eb00	f1		.
	ld bc,000f1h		;eb01	01 f1 00	. . .
	nop			;eb04	00		.
	nop			;eb05	00		.
	nop			;eb06	00		.
	nop			;eb07	00		.
	nop			;eb08	00		.
	nop			;eb09	00		.
	nop			;eb0a	00		.
	add a,c			;eb0b	81		.
	ret p			;eb0c	f0		.
	sub e			;eb0d	93		.
	jp (hl)			;eb0e	e9		.
	xor a			;eb0f	af		.
	pop af			;eb10	f1		.
	ld l,b			;eb11	68		h
	pop af			;eb12	f1		.
	nop			;eb13	00		.
	nop			;eb14	00		.
	nop			;eb15	00		.
	nop			;eb16	00		.
	nop			;eb17	00		.
	nop			;eb18	00		.
	nop			;eb19	00		.
	nop			;eb1a	00		.
	add a,c			;eb1b	81		.
	ret p			;eb1c	f0		.
	rst 8			;eb1d	cf		.
	jp (hl)			;eb1e	e9		.
	nop			;eb1f	00		.
	nop			;eb20	00		.
	rst 8			;eb21	cf		.
	pop af			;eb22	f1		.
	nop			;eb23	00		.
	nop			;eb24	00		.
	nop			;eb25	00		.
	nop			;eb26	00		.
	nop			;eb27	00		.
	nop			;eb28	00		.
	nop			;eb29	00		.
	nop			;eb2a	00		.
	add a,c			;eb2b	81		.
	ret p			;eb2c	f0		.
	call m,000e9h		;eb2d	fc e9 00	. . .
	nop			;eb30	00		.
	ld d,0f2h		;eb31	16 f2		. .
	nop			;eb33	00		.
	nop			;eb34	00		.
	nop			;eb35	00		.
	nop			;eb36	00		.
	nop			;eb37	00		.
	nop			;eb38	00		.
	nop			;eb39	00		.
	nop			;eb3a	00		.
	add a,c			;eb3b	81		.
	ret p			;eb3c	f0		.
	defb 0edh ;next byte illegal after ed	;eb3d	ed		.
	jp (hl)			;eb3e	e9		.
	nop			;eb3f	00		.
	nop			;eb40	00		.
	ld d,l			;eb41	55		U
	jp p,00000h		;eb42	f2 00 00	. . .
	nop			;eb45	00		.
	nop			;eb46	00		.
	nop			;eb47	00		.
	nop			;eb48	00		.
	nop			;eb49	00		.
	nop			;eb4a	00		.
	add a,c			;eb4b	81		.
	ret p			;eb4c	f0		.
	defb 0edh ;next byte illegal after ed	;eb4d	ed		.
	jp (hl)			;eb4e	e9		.
	nop			;eb4f	00		.
	nop			;eb50	00		.
	sub h			;eb51	94		.
	jp p,00000h		;eb52	f2 00 00	. . .
	nop			;eb55	00		.
	nop			;eb56	00		.
	nop			;eb57	00		.
	nop			;eb58	00		.
	nop			;eb59	00		.
	nop			;eb5a	00		.
	add a,c			;eb5b	81		.
	ret p			;eb5c	f0		.
	sbc a,0e9h		;eb5d	de e9		. .
	nop			;eb5f	00		.
	nop			;eb60	00		.
	out (0f2h),a		;eb61	d3 f2		. .
	ei			;eb63	fb		.
	reti			;eb64	ed 4d		. M
	ld e,e			;eb66	5b		[
	ld (hl),h		;eb67	74		t
	ld c,c			;eb68	49		I
	ld a,a			;eb69	7f		.
	ld c,c			;eb6a	49		I
	ld bc,06f4ah		;eb6b	01 4a 6f	. J o
	ld c,(hl)		;eb6e	4e		N
	sub (hl)		;eb6f	96		.
	ld c,c			;eb70	49		I
	dec d			;eb71	15		.
	ld d,a			;eb72	57		W
	xor (hl)		;eb73	ae		.
	ld c,c			;eb74	49		I
	adc a,d			;eb75	8a		.
	ld c,c			;eb76	49		I
	dec d			;eb77	15		.
	ld d,e			;eb78	53		S
	ld sp,hl		;eb79	f9		.
	ld c,(hl)		;eb7a	4e		N
	nop			;eb7b	00		.
	nop			;eb7c	00		.
	ld d,e			;eb7d	53		S
	ld d,c			;eb7e	51		Q
	call c,0004eh		;eb7f	dc 4e 00	. N .
	nop			;eb82	00		.
	dec c			;eb83	0d		.
	ld c,d			;eb84	4a		J
	nop			;eb85	00		.
	nop			;eb86	00		.
	nop			;eb87	00		.
	nop			;eb88	00		.
	nop			;eb89	00		.
	rst 38h			;eb8a	ff		.
	nop			;eb8b	00		.
	nop			;eb8c	00		.
	nop			;eb8d	00		.
	nop			;eb8e	00		.
	nop			;eb8f	00		.
	nop			;eb90	00		.
	nop			;eb91	00		.
	nop			;eb92	00		.
	nop			;eb93	00		.
	nop			;eb94	00		.
	nop			;eb95	00		.
	nop			;eb96	00		.
	nop			;eb97	00		.
	nop			;eb98	00		.
	nop			;eb99	00		.
	nop			;eb9a	00		.
	nop			;eb9b	00		.
	nop			;eb9c	00		.
	nop			;eb9d	00		.
	ld bc,00001h		;eb9e	01 01 00	. . .
	nop			;eba1	00		.
	nop			;eba2	00		.
	nop			;eba3	00		.
	nop			;eba4	00		.
	nop			;eba5	00		.
	nop			;eba6	00		.
	nop			;eba7	00		.
	nop			;eba8	00		.
	xor a			;eba9	af		.
	ld h,a			;ebaa	67		g
	adc a,e			;ebab	8b		.
	adc a,d			;ebac	8a		.
	xor e			;ebad	ab		.
	adc a,d			;ebae	8a		.
	nop			;ebaf	00		.
	nop			;ebb0	00		.
	nop			;ebb1	00		.
	nop			;ebb2	00		.
	nop			;ebb3	00		.
	nop			;ebb4	00		.
	dec b			;ebb5	05		.
	call z,0c905h		;ebb6	cc 05 c9	. . .
	ld d,c			;ebb9	51		Q
	ld b,c			;ebba	41		A
	rlca			;ebbb	07		.
	ld d,c			;ebbc	51		Q
	ld b,d			;ebbd	42		B
	nop			;ebbe	00		.
	ld d,c			;ebbf	51		Q
	ld b,e			;ebc0	43		C
	ld bc,04451h		;ebc1	01 51 44	. Q D
	ld (bc),a		;ebc4	02		.
	ld d,c			;ebc5	51		Q
	ld b,l			;ebc6	45		E
	inc bc			;ebc7	03		.
	ld d,c			;ebc8	51		Q
	ld c,b			;ebc9	48		H
	inc b			;ebca	04		.
	ld d,c			;ebcb	51		Q
	ld c,h			;ebcc	4c		L
	dec b			;ebcd	05		.
	ld d,c			;ebce	51		Q
	ld c,l			;ebcf	4d		M
	ld b,062h		;ebd0	06 62		. b
	ld d,e			;ebd2	53		S
	ld d,b			;ebd3	50		P
	ld b,063h		;ebd4	06 63		. c
	ld d,b			;ebd6	50		P
	ld d,e			;ebd7	53		S
	ld d,a			;ebd8	57		W
	ld b,051h		;ebd9	06 51		. Q
	ld c,c			;ebdb	49		I
	ex af,af'		;ebdc	08		.
	ld d,c			;ebdd	51		Q
	ld d,d			;ebde	52		R
	add hl,bc		;ebdf	09		.
	ld h,d			;ebe0	62		b
	ld b,d			;ebe1	42		B
	ld b,e			;ebe2	43		C
	nop			;ebe3	00		.
	ld h,d			;ebe4	62		b
	ld b,h			;ebe5	44		D
	ld b,l			;ebe6	45		E
	ld (bc),a		;ebe7	02		.
	ld h,d			;ebe8	62		b
	ld c,b			;ebe9	48		H
	ld c,h			;ebea	4c		L
	inc b			;ebeb	04		.
	ld h,d			;ebec	62		b
	ld b,c			;ebed	41		A
	ld b,(hl)		;ebee	46		F
	ld b,06ah		;ebef	06 6a		. j
	ld c,c			;ebf1	49		I
	ld e,b			;ebf2	58		X
	ld b,h			;ebf3	44		D
	ld l,d			;ebf4	6a		j
	ld c,c			;ebf5	49		I
	ld e,c			;ebf6	59		Y
	ld h,h			;ebf7	64		d
	ld (hl),d		;ebf8	72		r
	ld c,(hl)		;ebf9	4e		N
	ld e,d			;ebfa	5a		Z
	nop			;ebfb	00		.
	ld (hl),c		;ebfc	71		q
	ld e,d			;ebfd	5a		Z
	ld bc,06372h		;ebfe	01 72 63	. r c
	ex de,hl		;ec01	eb		.
	ld h,e			;ec02	63		c
	ex de,hl		;ec03	eb		.
	cp h			;ec04	bc		.
	pop hl			;ec05	e1		.
	ld c,(hl)		;ec06	4e		N
	rst 20h			;ec07	e7		.
	ld bc,063e9h		;ec08	01 e9 63	. . c
	ex de,hl		;ec0b	eb		.
	ld h,e			;ec0c	63		c
	ex de,hl		;ec0d	eb		.
	ld h,e			;ec0e	63		c
	ex de,hl		;ec0f	eb		.
	add a,e			;ec10	83		.
	call c,sub_dc9ch	;ec11	dc 9c dc	. . .
	or l			;ec14	b5		.
	call c,sub_dccah	;ec15	dc ca dc	. . .
	rst 20h			;ec18	e7		.
	call c,sub_dd00h	;ec19	dc 00 dd	. . .
	add hl,de		;ec1c	19		.
	defb 0ddh,033h,0ddh ;illegal sequence	;ec1d	dd 33 dd	. 3 .
	ld b,e			;ec20	43		C
	call pe,sub_ec58h	;ec21	ec 58 ec	. X .
	nop			;ec24	00		.
	call pe,00000h		;ec25	ec 00 00	. . .
	ld a,(0ec26h)		;ec28	3a 26 ec	: & .
	ret			;ec2b	c9		.
lec2ch:
	ld a,(0ec26h)		;ec2c	3a 26 ec	: & .
	or a			;ec2f	b7		.
	jp z,lec2ch		;ec30	ca 2c ec	. , .
	di			;ec33	f3		.
	xor a			;ec34	af		.
	ld (0ec26h),a		;ec35	32 26 ec	2 & .
	ei			;ec38	fb		.
	in a,(010h)		;ec39	db 10		. .
	ld c,a			;ec3b	4f		O
	ld hl,0f700h		;ec3c	21 00 f7	! . .
	call sub_dd7ah		;ec3f	cd 7a dd	. z .
	ret			;ec42	c9		.
	ld (0f34bh),sp		;ec43	ed 73 4b f3	. s K .
	ld sp,0f620h		;ec47	31 20 f6	1   .
	push af			;ec4a	f5		.
	ld a,0ffh		;ec4b	3e ff		> .
	ld (0ec26h),a		;ec4d	32 26 ec	2 & .
	pop af			;ec50	f1		.
	ld sp,(0f34bh)		;ec51	ed 7b 4b f3	. { K .
	ei			;ec55	fb		.
	reti			;ec56	ed 4d		. M
sub_ec58h:
	ld (0f34bh),sp		;ec58	ed 73 4b f3	. s K .
	ld sp,0f620h		;ec5c	31 20 f6	1   .
	push af			;ec5f	f5		.
	ld a,0ffh		;ec60	3e ff		> .
	ld (0ec27h),a		;ec62	32 27 ec	2 ' .
	pop af			;ec65	f1		.
	ld sp,(0f34bh)		;ec66	ed 7b 4b f3	. { K .
	ei			;ec6a	fb		.
	reti			;ec6b	ed 4d		. M
	ld b,c			;ec6d	41		A
	ld b,(hl)		;ec6e	46		F
	ld b,06ah		;ec6f	06 6a		. j
	ld c,c			;ec71	49		I
	ld e,b			;ec72	58		X
	ld b,h			;ec73	44		D
	ld l,d			;ec74	6a		j
	ld c,c			;ec75	49		I
	ld e,c			;ec76	59		Y
	ld h,h			;ec77	64		d
	ld (hl),d		;ec78	72		r
	ld c,(hl)		;ec79	4e		N
	ld e,d			;ec7a	5a		Z
	nop			;ec7b	00		.
	ld (hl),c		;ec7c	71		q
	ld e,d			;ec7d	5a		Z
	defb 001h,072h		;ec7e	01 72		. r
