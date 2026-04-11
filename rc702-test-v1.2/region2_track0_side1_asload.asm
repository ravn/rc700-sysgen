; z80dasm 1.2.0
; command line: z80dasm -a -l -t -g 0x0800 -o region2_track0_side1.asm region2_track0_side1.bin

	org 00800h

	ex af,af'		;0800	08		.
	ei			;0801	fb		.
	ret			;0802	c9		.
	ld (0f34bh),sp		;0803	ed 73 4b f3	. s K .
	ld sp,0f620h		;0807	31 20 f6	1   .
	push af			;080a	f5		.
	ld a,028h		;080b	3e 28		> (
	out (00bh),a		;080d	d3 0b		. .
	ld a,0ffh		;080f	3e ff		> .
	ld (0dbfeh),a		;0811	32 fe db	2 . .
	pop af			;0814	f1		.
	ld sp,(0f34bh)		;0815	ed 7b 4b f3	. { K .
	ei			;0819	fb		.
	reti			;081a	ed 4d		. M
	ld (0f34bh),sp		;081c	ed 73 4b f3	. s K .
	ld sp,0f620h		;0820	31 20 f6	1   .
	push af			;0823	f5		.
	in a,(00bh)		;0824	db 0b		. .
	ld (0dc05h),a		;0826	32 05 dc	2 . .
	ld a,010h		;0829	3e 10		> .
	out (00bh),a		;082b	d3 0b		. .
	pop af			;082d	f1		.
	ld sp,(0f34bh)		;082e	ed 7b 4b f3	. { K .
	ei			;0832	fb		.
	reti			;0833	ed 4d		. M
	ld (0f34bh),sp		;0835	ed 73 4b f3	. s K .
	ld sp,0f620h		;0839	31 20 f6	1   .
	push af			;083c	f5		.
	in a,(008h)		;083d	db 08		. .
	ld (0dc02h),a		;083f	32 02 dc	2 . .
	pop af			;0842	f1		.
	ld sp,(0f34bh)		;0843	ed 7b 4b f3	. { K .
	ei			;0847	fb		.
	reti			;0848	ed 4d		. M
	ld (0f34bh),sp		;084a	ed 73 4b f3	. s K .
	ld sp,0f620h		;084e	31 20 f6	1   .
	push af			;0851	f5		.
	ld a,001h		;0852	3e 01		> .
	out (00bh),a		;0854	d3 0b		. .
	in a,(00bh)		;0856	db 0b		. .
	ld (0dc06h),a		;0858	32 06 dc	2 . .
	ld a,030h		;085b	3e 30		> 0
	out (00bh),a		;085d	d3 0b		. .
	pop af			;085f	f1		.
	ld sp,(0f34bh)		;0860	ed 7b 4b f3	. { K .
	ei			;0864	fb		.
	reti			;0865	ed 4d		. M
	ld (0f34bh),sp		;0867	ed 73 4b f3	. s K .
	ld sp,0f620h		;086b	31 20 f6	1   .
	push af			;086e	f5		.
	ld a,028h		;086f	3e 28		> (
	out (00ah),a		;0871	d3 0a		. .
	ld a,0ffh		;0873	3e ff		> .
	ld (0dc00h),a		;0875	32 00 dc	2 . .
	pop af			;0878	f1		.
	ld sp,(0f34bh)		;0879	ed 7b 4b f3	. { K .
	ei			;087d	fb		.
	reti			;087e	ed 4d		. M
	ld (0f34bh),sp		;0880	ed 73 4b f3	. s K .
	ld sp,0f620h		;0884	31 20 f6	1   .
	push af			;0887	f5		.
	in a,(00ah)		;0888	db 0a		. .
	ld (0dc03h),a		;088a	32 03 dc	2 . .
	ld a,010h		;088d	3e 10		> .
	out (00ah),a		;088f	d3 0a		. .
	pop af			;0891	f1		.
	ld sp,(0f34bh)		;0892	ed 7b 4b f3	. { K .
	ei			;0896	fb		.
	reti			;0897	ed 4d		. M
	ld (0f34bh),sp		;0899	ed 73 4b f3	. s K .
	ld sp,0f620h		;089d	31 20 f6	1   .
	push af			;08a0	f5		.
	in a,(008h)		;08a1	db 08		. .
	ld (0dc01h),a		;08a3	32 01 dc	2 . .
	ld a,0ffh		;08a6	3e ff		> .
	ld (0dbffh),a		;08a8	32 ff db	2 . .
	pop af			;08ab	f1		.
	ld sp,(0f34bh)		;08ac	ed 7b 4b f3	. { K .
	ei			;08b0	fb		.
	reti			;08b1	ed 4d		. M
	ld (0f34bh),sp		;08b3	ed 73 4b f3	. s K .
	ld sp,0f620h		;08b7	31 20 f6	1   .
	push af			;08ba	f5		.
	ld a,001h		;08bb	3e 01		> .
	out (00ah),a		;08bd	d3 0a		. .
	in a,(00ah)		;08bf	db 0a		. .
	ld (0dc04h),a		;08c1	32 04 dc	2 . .
	ld a,030h		;08c4	3e 30		> 0
	out (00ah),a		;08c6	d3 0a		. .
	ld a,000h		;08c8	3e 00		> .
	ld (0dc01h),a		;08ca	32 01 dc	2 . .
	ld a,0ffh		;08cd	3e ff		> .
	ld (0dbffh),a		;08cf	32 ff db	2 . .
	pop af			;08d2	f1		.
	ld sp,(0f34bh)		;08d3	ed 7b 4b f3	. { K .
	ei			;08d7	fb		.
	reti			;08d8	ed 4d		. M
	nop			;08da	00		.
	nop			;08db	00		.
	nop			;08dc	00		.
	ld a,h			;08dd	7c		|
	cpl			;08de	2f		/
	ld h,a			;08df	67		g
	ld a,l			;08e0	7d		}
	cpl			;08e1	2f		/
	ld l,a			;08e2	6f		o
	ret			;08e3	c9		.
	call 0dd5dh		;08e4	cd 5d dd	. ] .
	inc hl			;08e7	23		#
	ret			;08e8	c9		.
	ld hl,(0ffd2h)		;08e9	2a d2 ff	* . .
	ld a,l			;08ec	7d		}
	cp 080h			;08ed	fe 80		. .
	ret nz			;08ef	c0		.
	ld a,h			;08f0	7c		|
	cp 007h			;08f1	fe 07		. .
	ret			;08f3	c9		.
	ld a,(0dd5ah)		;08f4	3a 5a dd	: Z .
	or a			;08f7	b7		.
	ld a,c			;08f8	79		y
	ret nz			;08f9	c0		.
	ld b,000h		;08fa	06 00		. .
	add hl,bc		;08fc	09		.
	ld a,(hl)		;08fd	7e		~
	ret			;08fe	c9		.
	push af			;08ff	f5		.
	ld a,080h		;0900	3e 80		> .
	out (001h),a		;0902	d3 01		. .
	ld a,(0ffd1h)		;0904	3a d1 ff	: . .
	out (000h),a		;0907	d3 00		. .
	ld a,(0ffd4h)		;0909	3a d4 ff	: . .
	out (000h),a		;090c	d3 00		. .
	pop af			;090e	f1		.
	ret			;090f	c9		.
	ld hl,(0ffd2h)		;0910	2a d2 ff	* . .
	ld de,00050h		;0913	11 50 00	. P .
	add hl,de		;0916	19		.
	ld (0ffd2h),hl		;0917	22 d2 ff	" . .
	ld hl,0ffd4h		;091a	21 d4 ff	! . .
	inc (hl)		;091d	34		4
	jp 0dd7fh		;091e	c3 7f dd	. . .
	ld hl,(0ffd2h)		;0921	2a d2 ff	* . .
	ld de,0ffb0h		;0924	11 b0 ff	. . .
	add hl,de		;0927	19		.
	ld (0ffd2h),hl		;0928	22 d2 ff	" . .
	ld hl,0ffd4h		;092b	21 d4 ff	! . .
	dec (hl)		;092e	35		5
	jp 0dd7fh		;092f	c3 7f dd	. . .
	ld hl,00000h		;0932	21 00 00	! . .
	ld (0ffd2h),hl		;0935	22 d2 ff	" . .
	xor a			;0938	af		.
	ld (0ffd1h),a		;0939	32 d1 ff	2 . .
	ld (0ffd4h),a		;093c	32 d4 ff	2 . .
	ret			;093f	c9		.
	cp b			;0940	b8		.
	ret c			;0941	d8		.
	sub b			;0942	90		.
	jp 0ddc0h		;0943	c3 c0 dd	. . .
	ld hl,(0ffd5h)		;0946	2a d5 ff	* . .
	ld d,h			;0949	54		T
	ld e,l			;094a	5d		]
	inc de			;094b	13		.
	ld bc,0004fh		;094c	01 4f 00	. O .
	ld (hl),020h		;094f	36 20		6  
	ldir			;0951	ed b0		. .
	ld a,(0ffdbh)		;0953	3a db ff	: . .
	cp 000h			;0956	fe 00		. .
	ret z			;0958	c8		.
	ld hl,(0ffdch)		;0959	2a dc ff	* . .
	ld d,h			;095c	54		T
	ld e,l			;095d	5d		]
	inc de			;095e	13		.
	ld bc,00009h		;095f	01 09 00	. . .
	ld (hl),000h		;0962	36 00		6 .
	ldir			;0964	ed b0		. .
	ret			;0966	c9		.
	ld hl,0f850h		;0967	21 50 f8	! P .
	ld de,0f800h		;096a	11 00 f8	. . .
	ld bc,00780h		;096d	01 80 07	. . .
	ldir			;0970	ed b0		. .
	ld hl,0ff80h		;0972	21 80 ff	! . .
	ld (0ffd5h),hl		;0975	22 d5 ff	" . .
	ld a,(0ffdbh)		;0978	3a db ff	: . .
	cp 000h			;097b	fe 00		. .
	jp z,0ddc6h		;097d	ca c6 dd	. . .
	ld hl,0f50ah		;0980	21 0a f5	! . .
	ld de,0f500h		;0983	11 00 f5	. . .
	ld bc,000f0h		;0986	01 f0 00	. . .
	ldir			;0989	ed b0		. .
	ld hl,0f5f0h		;098b	21 f0 f5	! . .
	ld (0ffdch),hl		;098e	22 dc ff	" . .
	jp 0ddc6h		;0991	c3 c6 dd	. . .
	ld a,000h		;0994	3e 00		> .
	ld b,003h		;0996	06 03		. .
	srl h			;0998	cb 3c		. <
	rr l			;099a	cb 1d		. .
	rra			;099c	1f		.
	dec b			;099d	05		.
	jp nz,0de18h		;099e	c2 18 de	. . .
	cp 000h			;09a1	fe 00		. .
	ret z			;09a3	c8		.
	ld b,005h		;09a4	06 05		. .
	rra			;09a6	1f		.
	dec b			;09a7	05		.
	jp nz,0de26h		;09a8	c2 26 de	. & .
	ret			;09ab	c9		.
	ld de,0f500h		;09ac	11 00 f5	. . .
	add hl,de		;09af	19		.
	cp 000h			;09b0	fe 00		. .
	ld b,a			;09b2	47		G
	ld a,000h		;09b3	3e 00		> .
	jp nz,0de3bh		;09b5	c2 3b de	. ; .
	and (hl)		;09b8	a6		.
	ld (hl),a		;09b9	77		w
	ret			;09ba	c9		.
	scf			;09bb	37		7
	rla			;09bc	17		.
	dec b			;09bd	05		.
	jp nz,0de3bh		;09be	c2 3b de	. ; .
	and (hl)		;09c1	a6		.
	ld (hl),a		;09c2	77		w
	ret			;09c3	c9		.
	ld a,000h		;09c4	3e 00		> .
	cp c			;09c6	b9		.
	jp z,0de4dh		;09c7	ca 4d de	. M .
	ldir			;09ca	ed b0		. .
	ret			;09cc	c9		.
	cp b			;09cd	b8		.
	jp nz,0de4ah		;09ce	c2 4a de	. J .
	ret			;09d1	c9		.
	ld a,000h		;09d2	3e 00		> .
	cp c			;09d4	b9		.
	jp z,0de5bh		;09d5	ca 5b de	. [ .
	lddr			;09d8	ed b8		. .
	ret			;09da	c9		.
	cp b			;09db	b8		.
	jp nz,0de58h		;09dc	c2 58 de	. X .
	ret			;09df	c9		.
	out (01ch),a		;09e0	d3 1c		. .
	ret			;09e2	c9		.
	call 0ddb2h		;09e3	cd b2 dd	. . .
	ld a,002h		;09e6	3e 02		> .
	ld (0ffd7h),a		;09e8	32 d7 ff	2 . .
	ret			;09eb	c9		.
	ret			;09ec	c9		.
	ld a,000h		;09ed	3e 00		> .
	ld (0ffd1h),a		;09ef	32 d1 ff	2 . .
	jp 0dd7fh		;09f2	c3 7f dd	. . .
	ld hl,0ffcfh		;09f5	21 cf ff	! . .
	ld de,0ffceh		;09f8	11 ce ff	. . .
	ld bc,007cfh		;09fb	01 cf 07	. . .
	ld (hl),020h		;09fe	36 20		6  
	lddr			;0a00	ed b8		. .
	call 0ddb2h		;0a02	cd b2 dd	. . .
	call 0dd7fh		;0a05	cd 7f dd	. . .
	ld a,(0ffdbh)		;0a08	3a db ff	: . .
	cp 000h			;0a0b	fe 00		. .
	ret z			;0a0d	c8		.
	xor a			;0a0e	af		.
	ld (0ffdbh),a		;0a0f	32 db ff	2 . .
	ld hl,0f5f9h		;0a12	21 f9 f5	! . .
	ld de,0f5f8h		;0a15	11 f8 f5	. . .
	ld bc,000f9h		;0a18	01 f9 00	. . .
	ld (hl),000h		;0a1b	36 00		6 .
	lddr			;0a1d	ed b8		. .
	ret			;0a1f	c9		.
	ld de,0f800h		;0a20	11 00 f8	. . .
	ld hl,(0ffd2h)		;0a23	2a d2 ff	* . .
	add hl,de		;0a26	19		.
	ld de,0004fh		;0a27	11 4f 00	. O .
	add hl,de		;0a2a	19		.
	ld d,h			;0a2b	54		T
	ld e,l			;0a2c	5d		]
	dec de			;0a2d	1b		.
	ld bc,00000h		;0a2e	01 00 00	. . .
	ld a,(0ffd1h)		;0a31	3a d1 ff	: . .
	cpl			;0a34	2f		/
	inc a			;0a35	3c		<
	add a,04fh		;0a36	c6 4f		. O
	ld c,a			;0a38	4f		O
	ld (hl),020h		;0a39	36 20		6  
	call 0de52h		;0a3b	cd 52 de	. R .
	ld a,(0ffdbh)		;0a3e	3a db ff	: . .
	cp 000h			;0a41	fe 00		. .
	ret z			;0a43	c8		.
	ld hl,(0ffd2h)		;0a44	2a d2 ff	* . .
	ld d,000h		;0a47	16 00		. .
	ld a,(0ffd1h)		;0a49	3a d1 ff	: . .
	ld e,a			;0a4c	5f		_
	add hl,de		;0a4d	19		.
	call 0de14h		;0a4e	cd 14 de	. . .
	call 0de2ch		;0a51	cd 2c de	. , .
	ld a,(0ffd1h)		;0a54	3a d1 ff	: . .
	srl a			;0a57	cb 3f		. ?
	srl a			;0a59	cb 3f		. ?
	srl a			;0a5b	cb 3f		. ?
	cpl			;0a5d	2f		/
	add a,009h		;0a5e	c6 09		. .
	ret m			;0a60	f8		.
	ld c,a			;0a61	4f		O
	ld b,000h		;0a62	06 00		. .
	inc hl			;0a64	23		#
	ld d,h			;0a65	54		T
	ld e,l			;0a66	5d		]
	inc de			;0a67	13		.
	ld a,000h		;0a68	3e 00		> .
	jp 0de44h		;0a6a	c3 44 de	. D .
	ld hl,(0ffd2h)		;0a6d	2a d2 ff	* . .
	ld a,(0ffd1h)		;0a70	3a d1 ff	: . .
	ld c,a			;0a73	4f		O
	ld b,000h		;0a74	06 00		. .
	add hl,bc		;0a76	09		.
	call 0dd64h		;0a77	cd 64 dd	. d .
	ld de,007cfh		;0a7a	11 cf 07	. . .
	add hl,de		;0a7d	19		.
	ld b,h			;0a7e	44		D
	ld c,l			;0a7f	4d		M
	ld hl,0ffcfh		;0a80	21 cf ff	! . .
	ld de,0ffceh		;0a83	11 ce ff	. . .
	ld (hl),020h		;0a86	36 20		6  
	call 0de52h		;0a88	cd 52 de	. R .
	ld a,(0ffdbh)		;0a8b	3a db ff	: . .
	cp 000h			;0a8e	fe 00		. .
	ret z			;0a90	c8		.
	ld hl,(0ffd2h)		;0a91	2a d2 ff	* . .
	ld d,000h		;0a94	16 00		. .
	ld a,(0ffd1h)		;0a96	3a d1 ff	: . .
	ld e,a			;0a99	5f		_
	add hl,de		;0a9a	19		.
	call 0de14h		;0a9b	cd 14 de	. . .
	call 0de2ch		;0a9e	cd 2c de	. , .
	call 0dd5dh		;0aa1	cd 5d dd	. ] .
	ld de,0f5f9h		;0aa4	11 f9 f5	. . .
	add hl,de		;0aa7	19		.
	ld a,080h		;0aa8	3e 80		> .
	and h			;0aaa	a4		.
	ret nz			;0aab	c0		.
	ld b,h			;0aac	44		D
	ld c,l			;0aad	4d		M
	ld h,d			;0aae	62		b
	ld l,e			;0aaf	6b		k
	dec de			;0ab0	1b		.
	ld (hl),000h		;0ab1	36 00		6 .
	jp 0de52h		;0ab3	c3 52 de	. R .
	ld a,(0ffd1h)		;0ab6	3a d1 ff	: . .
	cp 000h			;0ab9	fe 00		. .
	jp z,0df45h		;0abb	ca 45 df	. E .
	dec a			;0abe	3d		=
	ld (0ffd1h),a		;0abf	32 d1 ff	2 . .
	jp 0dd7fh		;0ac2	c3 7f dd	. . .
	ld a,04fh		;0ac5	3e 4f		> O
	ld (0ffd1h),a		;0ac7	32 d1 ff	2 . .
	ld hl,(0ffd2h)		;0aca	2a d2 ff	* . .
	ld a,l			;0acd	7d		}
	or h			;0ace	b4		.
	jp nz,0dda1h		;0acf	c2 a1 dd	. . .
	ld hl,00780h		;0ad2	21 80 07	! . .
	ld (0ffd2h),hl		;0ad5	22 d2 ff	" . .
	ld a,018h		;0ad8	3e 18		> .
	ld (0ffd4h),a		;0ada	32 d4 ff	2 . .
	jp 0dd7fh		;0add	c3 7f dd	. . .
	ld a,(0ffd1h)		;0ae0	3a d1 ff	: . .
	cp 04fh			;0ae3	fe 4f		. O
	jp z,0df6fh		;0ae5	ca 6f df	. o .
	inc a			;0ae8	3c		<
	ld (0ffd1h),a		;0ae9	32 d1 ff	2 . .
	jp 0dd7fh		;0aec	c3 7f dd	. . .
	ld a,000h		;0aef	3e 00		> .
	ld (0ffd1h),a		;0af1	32 d1 ff	2 . .
	call 0dd69h		;0af4	cd 69 dd	. i .
	jp nz,0dd90h		;0af7	c2 90 dd	. . .
	call 0dd7fh		;0afa	cd 7f dd	. . .
	jp 0dde7h		;0afd	c3 e7 dd	. . .
	call 0df60h		;0b00	cd 60 df	. ` .
	call 0df60h		;0b03	cd 60 df	. ` .
	call 0df60h		;0b06	cd 60 df	. ` .
	jp 0df60h		;0b09	c3 60 df	. ` .
	call 0dd69h		;0b0c	cd 69 dd	. i .
	jp nz,0dd90h		;0b0f	c2 90 dd	. . .
	jp 0dde7h		;0b12	c3 e7 dd	. . .
	ld hl,(0ffd2h)		;0b15	2a d2 ff	* . .
	ld a,l			;0b18	7d		}
	or h			;0b19	b4		.
	jp nz,0dda1h		;0b1a	c2 a1 dd	. . .
	ld hl,00780h		;0b1d	21 80 07	! . .
	ld (0ffd2h),hl		;0b20	22 d2 ff	" . .
	ld a,018h		;0b23	3e 18		> .
	ld (0ffd4h),a		;0b25	32 d4 ff	2 . .
	jp 0dd7fh		;0b28	c3 7f dd	. . .
	call 0ddb2h		;0b2b	cd b2 dd	. . .
	jp 0dd7fh		;0b2e	c3 7f dd	. . .
	ld hl,(0ffd2h)		;0b31	2a d2 ff	* . .
	ld b,h			;0b34	44		D
	ld c,l			;0b35	4d		M
	ld de,0f850h		;0b36	11 50 f8	. P .
	add hl,de		;0b39	19		.
	ld (0dd5bh),hl		;0b3a	22 5b dd	" [ .
	ld de,0ffb0h		;0b3d	11 b0 ff	. . .
	add hl,de		;0b40	19		.
	ex de,hl		;0b41	eb		.
	ld h,b			;0b42	60		`
	ld l,c			;0b43	69		i
	call 0dd64h		;0b44	cd 64 dd	. d .
	ld bc,00780h		;0b47	01 80 07	. . .
	add hl,bc		;0b4a	09		.
	ld b,h			;0b4b	44		D
	ld c,l			;0b4c	4d		M
	ld hl,(0dd5bh)		;0b4d	2a 5b dd	* [ .
	call 0de44h		;0b50	cd 44 de	. D .
	ld hl,0ff80h		;0b53	21 80 ff	! . .
	ld (0ffd5h),hl		;0b56	22 d5 ff	" . .
	ld a,(0ffdbh)		;0b59	3a db ff	: . .
	cp 000h			;0b5c	fe 00		. .
	jp z,0ddc6h		;0b5e	ca c6 dd	. . .
	ld hl,(0ffd2h)		;0b61	2a d2 ff	* . .
	call 0de14h		;0b64	cd 14 de	. . .
	ld b,h			;0b67	44		D
	ld c,l			;0b68	4d		M
	ld de,0f50ah		;0b69	11 0a f5	. . .
	add hl,de		;0b6c	19		.
	ld (0dd5bh),hl		;0b6d	22 5b dd	" [ .
	ld de,0fff6h		;0b70	11 f6 ff	. . .
	add hl,de		;0b73	19		.
	ex de,hl		;0b74	eb		.
	ld h,b			;0b75	60		`
	ld l,c			;0b76	69		i
	call 0dd64h		;0b77	cd 64 dd	. d .
	ld bc,000f0h		;0b7a	01 f0 00	. . .
	add hl,bc		;0b7d	09		.
	ld b,h			;0b7e	44		D
	ld c,l			;0b7f	4d		M
	ld hl,(0dd5bh)		;0b80	2a 5b dd	* [ .
	call 0de44h		;0b83	cd 44 de	. D .
	ld hl,0f5f0h		;0b86	21 f0 f5	! . .
	ld (0ffdch),hl		;0b89	22 dc ff	" . .
	jp 0ddc6h		;0b8c	c3 c6 dd	. . .
	ld hl,(0ffd2h)		;0b8f	2a d2 ff	* . .
	ld de,0f800h		;0b92	11 00 f8	. . .
	add hl,de		;0b95	19		.
	ld (0ffd5h),hl		;0b96	22 d5 ff	" . .
	call 0dd64h		;0b99	cd 64 dd	. d .
	ld de,0ff80h		;0b9c	11 80 ff	. . .
	add hl,de		;0b9f	19		.
	ld b,h			;0ba0	44		D
	ld c,l			;0ba1	4d		M
	ld hl,0ff7fh		;0ba2	21 7f ff	! . .
	ld de,0ffcfh		;0ba5	11 cf ff	. . .
	call 0de52h		;0ba8	cd 52 de	. R .
	ld a,(0ffdbh)		;0bab	3a db ff	: . .
	cp 000h			;0bae	fe 00		. .
	jp z,0ddc6h		;0bb0	ca c6 dd	. . .
	ld hl,(0ffd2h)		;0bb3	2a d2 ff	* . .
	call 0de14h		;0bb6	cd 14 de	. . .
	ld de,0f500h		;0bb9	11 00 f5	. . .
	add hl,de		;0bbc	19		.
	ld (0ffdch),hl		;0bbd	22 dc ff	" . .
	call 0dd64h		;0bc0	cd 64 dd	. d .
	ld de,0f5f0h		;0bc3	11 f0 f5	. . .
	add hl,de		;0bc6	19		.
	ld b,h			;0bc7	44		D
	ld c,l			;0bc8	4d		M
	ld hl,0f5efh		;0bc9	21 ef f5	! . .
	ld de,0f5f9h		;0bcc	11 f9 f5	. . .
	call 0de52h		;0bcf	cd 52 de	. R .
	jp 0ddc6h		;0bd2	c3 c6 dd	. . .
	ld a,002h		;0bd5	3e 02		> .
	ld (0ffdbh),a		;0bd7	32 db ff	2 . .
	ret			;0bda	c9		.
	ld a,001h		;0bdb	3e 01		> .
	ld (0ffdbh),a		;0bdd	32 db ff	2 . .
	ret			;0be0	c9		.
	ld hl,0f800h		;0be1	21 00 f8	! . .
	ld de,0f500h		;0be4	11 00 f5	. . .
	ld b,0fah		;0be7	06 fa		. .
	ld a,(de)		;0be9	1a		.
	ld c,008h		;0bea	0e 08		. .
	cp 000h			;0bec	fe 00		. .
	jp nz,0e07bh		;0bee	c2 7b e0	. { .
	ld (hl),020h		;0bf1	36 20		6  
	inc hl			;0bf3	23		#
	dec c			;0bf4	0d		.
	jp nz,0e071h		;0bf5	c2 71 e0	. q .
	jp 0e086h		;0bf8	c3 86 e0	. . .
	rra			;0bfb	1f		.
	jp c,0e081h		;0bfc	da 81 e0	. . .
	ld (hl),020h		;0bff	36 20		6  
	inc hl			;0c01	23		#
	dec c			;0c02	0d		.
	jp nz,0e07bh		;0c03	c2 7b e0	. { .
	inc de			;0c06	13		.
	dec b			;0c07	05		.
	jp nz,0e069h		;0c08	c2 69 e0	. i .
	ret			;0c0b	c9		.
	ld l,h			;0c0c	6c		l
	sbc a,00fh		;0c0d	de 0f		. .
	ret po			;0c0f	e0		.
	or c			;0c10	b1		.
	rst 18h			;0c11	df		.
	ld l,h			;0c12	6c		l
	sbc a,06ch		;0c13	de 6c		. l
	sbc a,036h		;0c15	de 36		. 6
	rst 18h			;0c17	df		.
	ld h,e			;0c18	63		c
	sbc a,060h		;0c19	de 60		. `
	sbc a,036h		;0c1b	de 36		. 6
	rst 18h			;0c1d	df		.
	add a,b			;0c1e	80		.
	rst 18h			;0c1f	df		.
	adc a,h			;0c20	8c		.
	rst 18h			;0c21	df		.
	ld l,h			;0c22	6c		l
	sbc a,075h		;0c23	de 75		. u
	sbc a,06dh		;0c25	de 6d		. m
	sbc a,06ch		;0c27	de 6c		. l
	sbc a,06ch		;0c29	de 6c		. l
	sbc a,06ch		;0c2b	de 6c		. l
	sbc a,06ch		;0c2d	de 6c		. l
	sbc a,06ch		;0c2f	de 6c		. l
	sbc a,06ch		;0c31	de 6c		. l
	sbc a,055h		;0c33	de 55		. U
	ret po			;0c35	e0		.
	ld e,e			;0c36	5b		[
	ret po			;0c37	e0		.
	ld h,c			;0c38	61		a
	ret po			;0c39	e0		.
	ld l,h			;0c3a	6c		l
	sbc a,060h		;0c3b	de 60		. `
	rst 18h			;0c3d	df		.
	ld l,h			;0c3e	6c		l
	sbc a,095h		;0c3f	de 95		. .
	rst 18h			;0c41	df		.
	ld l,h			;0c42	6c		l
	sbc a,06ch		;0c43	de 6c		. l
	sbc a,0abh		;0c45	de ab		. .
	rst 18h			;0c47	df		.
	and b			;0c48	a0		.
	sbc a,0edh		;0c49	de ed		. .
	sbc a,03eh		;0c4b	de 3e		. >
	nop			;0c4d	00		.
	ld (0ffd7h),a		;0c4e	32 d7 ff	2 . .
	ld a,(0ffdah)		;0c51	3a da ff	: . .
	rlca			;0c54	07		.
	and 03eh		;0c55	e6 3e		. >
	ld c,a			;0c57	4f		O
	ld b,000h		;0c58	06 00		. .
	ld hl,0e08ch		;0c5a	21 8c e0	! . .
	add hl,bc		;0c5d	09		.
	ld e,(hl)		;0c5e	5e		^
	inc hl			;0c5f	23		#
	ld d,(hl)		;0c60	56		V
	ex de,hl		;0c61	eb		.
	jp (hl)			;0c62	e9		.
	ld a,(0ffdah)		;0c63	3a da ff	: . .
	and 07fh		;0c66	e6 7f		. .
	sub 020h		;0c68	d6 20		.  
	ld hl,0ffd7h		;0c6a	21 d7 ff	! . .
	dec (hl)		;0c6d	35		5
	jp z,0e0f5h		;0c6e	ca f5 e0	. . .
	ld (0ffdeh),a		;0c71	32 de ff	2 . .
	ret			;0c74	c9		.
	ld d,a			;0c75	57		W
	ld a,(0ffdeh)		;0c76	3a de ff	: . .
	ld h,a			;0c79	67		g
	ld a,(0da33h)		;0c7a	3a 33 da	: 3 .
	or a			;0c7d	b7		.
	jp z,0e102h		;0c7e	ca 02 e1	. . .
	ex de,hl		;0c81	eb		.
	ld a,h			;0c82	7c		|
	ld b,050h		;0c83	06 50		. P
	call 0ddc0h		;0c85	cd c0 dd	. . .
	ld (0ffd1h),a		;0c88	32 d1 ff	2 . .
	ld a,d			;0c8b	7a		z
	ld b,019h		;0c8c	06 19		. .
	call 0ddc0h		;0c8e	cd c0 dd	. . .
	ld (0ffd4h),a		;0c91	32 d4 ff	2 . .
	or a			;0c94	b7		.
	jp z,0dd7fh		;0c95	ca 7f dd	. . .
	ld hl,(0ffd2h)		;0c98	2a d2 ff	* . .
	ld de,00050h		;0c9b	11 50 00	. P .
	add hl,de		;0c9e	19		.
	dec a			;0c9f	3d		=
	jp nz,0e11eh		;0ca0	c2 1e e1	. . .
	ld (0ffd2h),hl		;0ca3	22 d2 ff	" . .
	jp 0dd7fh		;0ca6	c3 7f dd	. . .
	ld hl,(0ffd2h)		;0ca9	2a d2 ff	* . .
	ld d,000h		;0cac	16 00		. .
	ld a,(0ffd1h)		;0cae	3a d1 ff	: . .
	ld e,a			;0cb1	5f		_
	add hl,de		;0cb2	19		.
	ld (0ffd8h),hl		;0cb3	22 d8 ff	" . .
	ld a,(0ffdah)		;0cb6	3a da ff	: . .
	cp 0c0h			;0cb9	fe c0		. .
	jp c,0e140h		;0cbb	da 40 e1	. @ .
	sub 0c0h		;0cbe	d6 c0		. .
	ld c,a			;0cc0	4f		O
	cp 080h			;0cc1	fe 80		. .
	jp c,0e14fh		;0cc3	da 4f e1	. O .
	and 004h		;0cc6	e6 04		. .
	ld (0dd5ah),a		;0cc8	32 5a dd	2 Z .
	ld a,c			;0ccb	79		y
	jp 0e155h		;0ccc	c3 55 e1	. U .
	ld hl,0f680h		;0ccf	21 80 f6	! . .
	call 0dd74h		;0cd2	cd 74 dd	. t .
	ld hl,(0ffd8h)		;0cd5	2a d8 ff	* . .
	ld de,0f800h		;0cd8	11 00 f8	. . .
	add hl,de		;0cdb	19		.
	ld (hl),a		;0cdc	77		w
	call 0df60h		;0cdd	cd 60 df	. ` .
	ld a,(0ffdbh)		;0ce0	3a db ff	: . .
	cp 002h			;0ce3	fe 02		. .
	ret nz			;0ce5	c0		.
	ld hl,(0ffd8h)		;0ce6	2a d8 ff	* . .
	call 0de14h		;0ce9	cd 14 de	. . .
	ld de,0f500h		;0cec	11 00 f5	. . .
	add hl,de		;0cef	19		.
	cp 000h			;0cf0	fe 00		. .
	ld b,a			;0cf2	47		G
	ld a,001h		;0cf3	3e 01		> .
	jp nz,0e17bh		;0cf5	c2 7b e1	. { .
	or (hl)			;0cf8	b6		.
	ld (hl),a		;0cf9	77		w
	ret			;0cfa	c9		.
	rlca			;0cfb	07		.
	dec b			;0cfc	05		.
	jp nz,0e17bh		;0cfd	c2 7b e1	. { .
	or (hl)			;0d00	b6		.
	ld (hl),a		;0d01	77		w
	ret			;0d02	c9		.
	di			;0d03	f3		.
	push hl			;0d04	e5		.
	ld hl,00000h		;0d05	21 00 00	! . .
	add hl,sp		;0d08	39		9
	ld sp,0f680h		;0d09	31 80 f6	1 . .
	ei			;0d0c	fb		.
	push hl			;0d0d	e5		.
	push af			;0d0e	f5		.
	push bc			;0d0f	c5		.
	push de			;0d10	d5		.
	ld a,c			;0d11	79		y
	ld (0ffdah),a		;0d12	32 da ff	2 . .
	ld a,(0ffd7h)		;0d15	3a d7 ff	: . .
	or a			;0d18	b7		.
	jp z,0e1a2h		;0d19	ca a2 e1	. . .
	call 0e0e3h		;0d1c	cd e3 e0	. . .
	jp 0e1b3h		;0d1f	c3 b3 e1	. . .
	ld a,(0ffdah)		;0d22	3a da ff	: . .
	cp 020h			;0d25	fe 20		.  
	jp nc,0e1b0h		;0d27	d2 b0 e1	. . .
	call 0e0cch		;0d2a	cd cc e0	. . .
	jp 0e1b3h		;0d2d	c3 b3 e1	. . .
	call 0e129h		;0d30	cd 29 e1	. ) .
	pop de			;0d33	d1		.
	pop bc			;0d34	c1		.
	pop af			;0d35	f1		.
	pop hl			;0d36	e1		.
	di			;0d37	f3		.
	ld sp,hl		;0d38	f9		.
	pop hl			;0d39	e1		.
	ei			;0d3a	fb		.
	ret			;0d3b	c9		.
	ld (0f34bh),sp		;0d3c	ed 73 4b f3	. s K .
	ld sp,0f620h		;0d40	31 20 f6	1   .
	push af			;0d43	f5		.
	push bc			;0d44	c5		.
	push de			;0d45	d5		.
	push hl			;0d46	e5		.
	in a,(001h)		;0d47	db 01		. .
	ld a,006h		;0d49	3e 06		> .
	out (0fah),a		;0d4b	d3 fa		. .
	ld a,007h		;0d4d	3e 07		> .
	out (0fah),a		;0d4f	d3 fa		. .
	out (0fch),a		;0d51	d3 fc		. .
	ld hl,0f800h		;0d53	21 00 f8	! . .
	ld a,l			;0d56	7d		}
	out (0f4h),a		;0d57	d3 f4		. .
	ld a,h			;0d59	7c		|
	out (0f4h),a		;0d5a	d3 f4		. .
	ld hl,007cfh		;0d5c	21 cf 07	! . .
	ld a,l			;0d5f	7d		}
	out (0f5h),a		;0d60	d3 f5		. .
	ld a,h			;0d62	7c		|
	out (0f5h),a		;0d63	d3 f5		. .
	ld a,000h		;0d65	3e 00		> .
	out (0f7h),a		;0d67	d3 f7		. .
	out (0f7h),a		;0d69	d3 f7		. .
	ld a,002h		;0d6b	3e 02		> .
	out (0fah),a		;0d6d	d3 fa		. .
	ld a,003h		;0d6f	3e 03		> .
	out (0fah),a		;0d71	d3 fa		. .
	ld a,0d7h		;0d73	3e d7		> .
	out (00eh),a		;0d75	d3 0e		. .
	ld a,001h		;0d77	3e 01		> .
	out (00eh),a		;0d79	d3 0e		. .
	ld hl,0fffch		;0d7b	21 fc ff	! . .
	inc (hl)		;0d7e	34		4
	jp nz,0e20eh		;0d7f	c2 0e e2	. . .
	inc hl			;0d82	23		#
	inc (hl)		;0d83	34		4
	jp nz,0e20eh		;0d84	c2 0e e2	. . .
	inc hl			;0d87	23		#
	inc (hl)		;0d88	34		4
	jp nz,0e20eh		;0d89	c2 0e e2	. . .
	inc hl			;0d8c	23		#
	inc (hl)		;0d8d	34		4
	ld hl,(0ffdfh)		;0d8e	2a df ff	* . .
	ld a,l			;0d91	7d		}
	or h			;0d92	b4		.
	jp z,0e21fh		;0d93	ca 1f e2	. . .
	dec hl			;0d96	2b		+
	ld a,l			;0d97	7d		}
	or h			;0d98	b4		.
	ld (0ffdfh),hl		;0d99	22 df ff	" . .
	call z,0ffe5h		;0d9c	cc e5 ff	. . .
	ld hl,(0ffe1h)		;0d9f	2a e1 ff	* . .
	ld a,l			;0da2	7d		}
	or h			;0da3	b4		.
	jp z,0e230h		;0da4	ca 30 e2	. 0 .
	dec hl			;0da7	2b		+
	ld a,l			;0da8	7d		}
	or h			;0da9	b4		.
	ld (0ffe1h),hl		;0daa	22 e1 ff	" . .
	call z,0e5bch		;0dad	cc bc e5	. . .
	ld hl,(0ffe3h)		;0db0	2a e3 ff	* . .
	ld a,l			;0db3	7d		}
	or h			;0db4	b4		.
	jp z,0e23ch		;0db5	ca 3c e2	. < .
	dec hl			;0db8	2b		+
	ld (0ffe3h),hl		;0db9	22 e3 ff	" . .
	pop hl			;0dbc	e1		.
	pop de			;0dbd	d1		.
	pop bc			;0dbe	c1		.
	pop af			;0dbf	f1		.
	ld sp,(0f34bh)		;0dc0	ed 7b 4b f3	. { K .
	ei			;0dc4	fb		.
	reti			;0dc5	ed 4d		. M
	ld hl,00000h		;0dc7	21 00 00	! . .
	add hl,sp		;0dca	39		9
	ld sp,0f680h		;0dcb	31 80 f6	1 . .
	push hl			;0dce	e5		.
	ld hl,00000h		;0dcf	21 00 00	! . .
	ld a,(0f334h)		;0dd2	3a 34 f3	: 4 .
	cp c			;0dd5	b9		.
	jp c,0e2deh		;0dd6	da de e2	. . .
	ld a,c			;0dd9	79		y
	ld (0f312h),a		;0dda	32 12 f3	2 . .
	ld bc,00010h		;0ddd	01 10 00	. . .
	ld de,0da37h		;0de0	11 37 da	. 7 .
	ld hl,00000h		;0de3	21 00 00	! . .
	or a			;0de6	b7		.
	jp z,0e270h		;0de7	ca 70 e2	. p .
	inc de			;0dea	13		.
	add hl,bc		;0deb	09		.
	dec a			;0dec	3d		=
	jp 0e266h		;0ded	c3 66 e2	. f .
	ld c,l			;0df0	4d		M
	ld b,h			;0df1	44		D
	ex de,hl		;0df2	eb		.
	ld a,(hl)		;0df3	7e		~
	ld hl,0f332h		;0df4	21 32 f3	! 2 .
	cp (hl)			;0df7	be		.
	jp z,0e28ah		;0df8	ca 8a e2	. . .
	push af			;0dfb	f5		.
	push bc			;0dfc	c5		.
	ld a,(0f322h)		;0dfd	3a 22 f3	: " .
	or a			;0e00	b7		.
	call nz,0e488h		;0e01	c4 88 e4	. . .
	xor a			;0e04	af		.
	ld (0f322h),a		;0e05	32 22 f3	2 " .
	pop bc			;0e08	c1		.
	pop af			;0e09	f1		.
	ld (0f332h),a		;0e0a	32 32 f3	2 2 .
	call 0e2e3h		;0e0d	cd e3 e2	. . .
	ld (0f330h),hl		;0e10	22 30 f3	" 0 .
	inc hl			;0e13	23		#
	inc hl			;0e14	23		#
	inc hl			;0e15	23		#
	inc hl			;0e16	23		#
	ld a,(hl)		;0e17	7e		~
	ld (0f333h),a		;0e18	32 33 f3	2 3 .
	push bc			;0e1b	c5		.
	ld a,(0f332h)		;0e1c	3a 32 f3	: 2 .
	and 0f8h		;0e1f	e6 f8		. .
	or a			;0e21	b7		.
	rla			;0e22	17		.
	ld e,a			;0e23	5f		_
	ld d,000h		;0e24	16 00		. .
	ld hl,0ea1bh		;0e26	21 1b ea	! . .
	add hl,de		;0e29	19		.
	ld de,0f351h		;0e2a	11 51 f3	. Q .
	ld bc,00010h		;0e2d	01 10 00	. . .
	ldir			;0e30	ed b0		. .
	ld hl,(0f351h)		;0e32	2a 51 f3	* Q .
	ld bc,0000dh		;0e35	01 0d 00	. . .
	add hl,bc		;0e38	09		.
	ex de,hl		;0e39	eb		.
	ld hl,0ea0bh		;0e3a	21 0b ea	! . .
	ld b,000h		;0e3d	06 00		. .
	ld a,(0f312h)		;0e3f	3a 12 f3	: . .
	ld c,a			;0e42	4f		O
	add hl,bc		;0e43	09		.
	add hl,bc		;0e44	09		.
	ld bc,00002h		;0e45	01 02 00	. . .
	ldir			;0e48	ed b0		. .
	pop bc			;0e4a	c1		.
	ld hl,0eaf3h		;0e4b	21 f3 ea	! . .
	add hl,bc		;0e4e	09		.
	ex de,hl		;0e4f	eb		.
	ld hl,0000ah		;0e50	21 0a 00	! . .
	add hl,de		;0e53	19		.
	ex de,hl		;0e54	eb		.
	ld a,(0f351h)		;0e55	3a 51 f3	: Q .
	ld (de),a		;0e58	12		.
	inc de			;0e59	13		.
	ld a,(0f352h)		;0e5a	3a 52 f3	: R .
	ld (de),a		;0e5d	12		.
	ex de,hl		;0e5e	eb		.
	pop hl			;0e5f	e1		.
	ld sp,hl		;0e60	f9		.
	ex de,hl		;0e61	eb		.
	ret			;0e62	c9		.
	ld hl,0eaach		;0e63	21 ac ea	! . .
	ld a,(0f332h)		;0e66	3a 32 f3	: 2 .
	and 0f8h		;0e69	e6 f8		. .
	ld e,a			;0e6b	5f		_
	ld d,000h		;0e6c	16 00		. .
	add hl,de		;0e6e	19		.
	ret			;0e6f	c9		.
	ld h,b			;0e70	60		`
	ld l,c			;0e71	69		i
	ld (0f313h),hl		;0e72	22 13 f3	" . .
	ret			;0e75	c9		.
	ld l,c			;0e76	69		i
	ld h,b			;0e77	60		`
	ld (0f315h),hl		;0e78	22 15 f3	" . .
	ret			;0e7b	c9		.
	ld h,b			;0e7c	60		`
	ld l,c			;0e7d	69		i
	ld (0f32eh),hl		;0e7e	22 2e f3	" . .
	ret			;0e81	c9		.
	ld h,b			;0e82	60		`
	ld l,c			;0e83	69		i
	ret			;0e84	c9		.
	xor a			;0e85	af		.
	ld (0f323h),a		;0e86	32 23 f3	2 # .
	ld a,001h		;0e89	3e 01		> .
	ld (0f32ch),a		;0e8b	32 2c f3	2 , .
	ld (0f32bh),a		;0e8e	32 2b f3	2 + .
	ld a,002h		;0e91	3e 02		> .
	ld (0f32dh),a		;0e93	32 2d f3	2 - .
	jp 0e3b4h		;0e96	c3 b4 e3	. . .
	xor a			;0e99	af		.
	ld (0f32ch),a		;0e9a	32 2c f3	2 , .
	ld a,c			;0e9d	79		y
	ld (0f32dh),a		;0e9e	32 2d f3	2 - .
	cp 002h			;0ea1	fe 02		. .
	jp nz,0e33eh		;0ea3	c2 3e e3	. > .
	ld a,(0f353h)		;0ea6	3a 53 f3	: S .
	ld (0f323h),a		;0ea9	32 23 f3	2 # .
	ld a,(0f312h)		;0eac	3a 12 f3	: . .
	ld (0f324h),a		;0eaf	32 24 f3	2 $ .
	ld hl,(0f313h)		;0eb2	2a 13 f3	* . .
	ld (0f325h),hl		;0eb5	22 25 f3	" % .
	ld hl,(0f315h)		;0eb8	2a 15 f3	* . .
	ld (0f327h),hl		;0ebb	22 27 f3	" ' .
	ld a,(0f323h)		;0ebe	3a 23 f3	: # .
	or a			;0ec1	b7		.
	jp z,0e3aah		;0ec2	ca aa e3	. . .
	dec a			;0ec5	3d		=
	ld (0f323h),a		;0ec6	32 23 f3	2 # .
	ld a,(0f312h)		;0ec9	3a 12 f3	: . .
	ld hl,0f324h		;0ecc	21 24 f3	! $ .
	cp (hl)			;0ecf	be		.
	jp nz,0e3aah		;0ed0	c2 aa e3	. . .
	ld hl,0f325h		;0ed3	21 25 f3	! % .
	call 0e47ch		;0ed6	cd 7c e4	. | .
	jp nz,0e3aah		;0ed9	c2 aa e3	. . .
	ld a,(0f315h)		;0edc	3a 15 f3	: . .
	ld hl,0f327h		;0edf	21 27 f3	! ' .
	cp (hl)			;0ee2	be		.
	jp nz,0e3aah		;0ee3	c2 aa e3	. . .
	ld a,(0f316h)		;0ee6	3a 16 f3	: . .
	inc hl			;0ee9	23		#
	cp (hl)			;0eea	be		.
	jp nz,0e3aah		;0eeb	c2 aa e3	. . .
	ld hl,(0f327h)		;0eee	2a 27 f3	* ' .
	inc hl			;0ef1	23		#
	ld (0f327h),hl		;0ef2	22 27 f3	" ' .
	ex de,hl		;0ef5	eb		.
	ld hl,0f354h		;0ef6	21 54 f3	! T .
	push bc			;0ef9	c5		.
	ld c,(hl)		;0efa	4e		N
	inc hl			;0efb	23		#
	ld b,(hl)		;0efc	46		F
	ex de,hl		;0efd	eb		.
	and a			;0efe	a7		.
	sbc hl,bc		;0eff	ed 42		. B
	pop bc			;0f01	c1		.
	jp c,0e392h		;0f02	da 92 e3	. . .
	ld hl,00000h		;0f05	21 00 00	! . .
	ld (0f327h),hl		;0f08	22 27 f3	" ' .
	ld hl,(0f325h)		;0f0b	2a 25 f3	* % .
	inc hl			;0f0e	23		#
	ld (0f325h),hl		;0f0f	22 25 f3	" % .
	xor a			;0f12	af		.
	ld (0f32bh),a		;0f13	32 2b f3	2 + .
	ld a,(0f315h)		;0f16	3a 15 f3	: . .
	ld hl,0f356h		;0f19	21 56 f3	! V .
	and (hl)		;0f1c	a6		.
	cp (hl)			;0f1d	be		.
	ld a,000h		;0f1e	3e 00		> .
	jp nz,0e3a4h		;0f20	c2 a4 e3	. . .
	inc a			;0f23	3c		<
	ld (0f329h),a		;0f24	32 29 f3	2 ) .
	jp 0e3b4h		;0f27	c3 b4 e3	. . .
	xor a			;0f2a	af		.
	ld (0f323h),a		;0f2b	32 23 f3	2 # .
	ld a,(0f356h)		;0f2e	3a 56 f3	: V .
	ld (0f32bh),a		;0f31	32 2b f3	2 + .
	ld hl,00000h		;0f34	21 00 00	! . .
	add hl,sp		;0f37	39		9
	ld sp,0f680h		;0f38	31 80 f6	1 . .
	push hl			;0f3b	e5		.
	ld a,(0f357h)		;0f3c	3a 57 f3	: W .
	ld b,a			;0f3f	47		G
	ld hl,(0f315h)		;0f40	2a 15 f3	* . .
	dec b			;0f43	05		.
	jp z,0e3ceh		;0f44	ca ce e3	. . .
	srl h			;0f47	cb 3c		. <
	rr l			;0f49	cb 1d		. .
	jp 0e3c3h		;0f4b	c3 c3 e3	. . .
	ld (0f31fh),hl		;0f4e	22 1f f3	" . .
	ld hl,0f321h		;0f51	21 21 f3	! ! .
	ld a,(hl)		;0f54	7e		~
	ld (hl),001h		;0f55	36 01		6 .
	or a			;0f57	b7		.
	jp z,0e407h		;0f58	ca 07 e4	. . .
	ld a,(0f312h)		;0f5b	3a 12 f3	: . .
	ld hl,0f317h		;0f5e	21 17 f3	! . .
	cp (hl)			;0f61	be		.
	jp nz,0e400h		;0f62	c2 00 e4	. . .
	ld hl,0f318h		;0f65	21 18 f3	! . .
	call 0e47ch		;0f68	cd 7c e4	. | .
	jp nz,0e400h		;0f6b	c2 00 e4	. . .
	ld a,(0f31fh)		;0f6e	3a 1f f3	: . .
	ld hl,0f31ah		;0f71	21 1a f3	! . .
	cp (hl)			;0f74	be		.
	jp nz,0e400h		;0f75	c2 00 e4	. . .
	ld a,(0f320h)		;0f78	3a 20 f3	:   .
	inc hl			;0f7b	23		#
	cp (hl)			;0f7c	be		.
	jp z,0e424h		;0f7d	ca 24 e4	. $ .
	ld a,(0f322h)		;0f80	3a 22 f3	: " .
	or a			;0f83	b7		.
	call nz,0e488h		;0f84	c4 88 e4	. . .
	ld a,(0f312h)		;0f87	3a 12 f3	: . .
	ld (0f317h),a		;0f8a	32 17 f3	2 . .
	ld hl,(0f313h)		;0f8d	2a 13 f3	* . .
	ld (0f318h),hl		;0f90	22 18 f3	" . .
	ld hl,(0f31fh)		;0f93	2a 1f f3	* . .
	ld (0f31ah),hl		;0f96	22 1a f3	" . .
	ld a,(0f32bh)		;0f99	3a 2b f3	: + .
	or a			;0f9c	b7		.
	call nz,0e495h		;0f9d	c4 95 e4	. . .
	xor a			;0fa0	af		.
	ld (0f322h),a		;0fa1	32 22 f3	2 " .
	ld a,(0f315h)		;0fa4	3a 15 f3	: . .
	ld hl,0f356h		;0fa7	21 56 f3	! V .
	and (hl)		;0faa	a6		.
	ld l,a			;0fab	6f		o
	ld h,000h		;0fac	26 00		& .
	add hl,hl		;0fae	29		)
	add hl,hl		;0faf	29		)
	add hl,hl		;0fb0	29		)
	add hl,hl		;0fb1	29		)
	add hl,hl		;0fb2	29		)
	add hl,hl		;0fb3	29		)
	add hl,hl		;0fb4	29		)
	ld de,0ee81h		;0fb5	11 81 ee	. . .
	add hl,de		;0fb8	19		.
	ex de,hl		;0fb9	eb		.
	ld hl,(0f32eh)		;0fba	2a 2e f3	* . .
	ld bc,00080h		;0fbd	01 80 00	. . .
	ex de,hl		;0fc0	eb		.
	ld a,(0f32ch)		;0fc1	3a 2c f3	: , .
	or a			;0fc4	b7		.
	jp nz,0e44eh		;0fc5	c2 4e e4	. N .
	ld a,001h		;0fc8	3e 01		> .
	ld (0f322h),a		;0fca	32 22 f3	2 " .
	ex de,hl		;0fcd	eb		.
	ldir			;0fce	ed b0		. .
	ld a,(0f32dh)		;0fd0	3a 2d f3	: - .
	cp 001h			;0fd3	fe 01		. .
	ld hl,0f32ah		;0fd5	21 2a f3	! * .
	ld a,(hl)		;0fd8	7e		~
	push af			;0fd9	f5		.
	or a			;0fda	b7		.
	jp z,0e462h		;0fdb	ca 62 e4	. b .
	xor a			;0fde	af		.
	ld (0f321h),a		;0fdf	32 21 f3	2 ! .
	pop af			;0fe2	f1		.
	ld (hl),000h		;0fe3	36 00		6 .
	jp nz,0e479h		;0fe5	c2 79 e4	. y .
	or a			;0fe8	b7		.
	jp nz,0e479h		;0fe9	c2 79 e4	. y .
	xor a			;0fec	af		.
	ld (0f322h),a		;0fed	32 22 f3	2 " .
	call 0e488h		;0ff0	cd 88 e4	. . .
	ld hl,0f32ah		;0ff3	21 2a f3	! * .
	ld a,(hl)		;0ff6	7e		~
	ld (hl),000h		;0ff7	36 00		6 .
	pop hl			;0ff9	e1		.
	ld sp,hl		;0ffa	f9		.
	ret			;0ffb	c9		.
	ex de,hl		;0ffc	eb		.
	ld hl,0f313h		;0ffd	21 13 f3	! . .
	ld a,(de)		;1000	1a		.
	cp (hl)			;1001	be		.
	ret nz			;1002	c0		.
	inc de			;1003	13		.
	inc hl			;1004	23		#
	ld a,(de)		;1005	1a		.
	cp (hl)			;1006	be		.
	ret			;1007	c9		.
	ld a,(0f35bh)		;1008	3a 5b f3	: [ .
	or a			;100b	b7		.
	jp nz,0e77fh		;100c	c2 7f e7	. . .
	call 0e4ach		;100f	cd ac e4	. . .
	jp 0e574h		;1012	c3 74 e5	. t .
	ld a,(0f329h)		;1015	3a 29 f3	: ) .
	or a			;1018	b7		.
	jp nz,0e49fh		;1019	c2 9f e4	. . .
	ld (0f323h),a		;101c	32 23 f3	2 # .
	ld a,(0f35bh)		;101f	3a 5b f3	: [ .
	or a			;1022	b7		.
	jp nz,0e79ah		;1023	c2 9a e7	. . .
	call 0e4ach		;1026	cd ac e4	. . .
	jp 0e52ah		;1029	c3 2a e5	. * .
	ld a,(0f31ah)		;102c	3a 1a f3	: . .
	ld c,a			;102f	4f		O
	ld a,(0f333h)		;1030	3a 33 f3	: 3 .
	ld b,a			;1033	47		G
	dec a			;1034	3d		=
	cp c			;1035	b9		.
	ld a,(0f317h)		;1036	3a 17 f3	: . .
	jp nc,0e4c7h		;1039	d2 c7 e4	. . .
	or 004h			;103c	f6 04		. .
	ld (0f339h),a		;103e	32 39 f3	2 9 .
	ld a,c			;1041	79		y
	sub b			;1042	90		.
	ld c,a			;1043	4f		O
	jp 0e4cah		;1044	c3 ca e4	. . .
	ld (0f339h),a		;1047	32 39 f3	2 9 .
	ld b,000h		;104a	06 00		. .
	ld hl,(0f358h)		;104c	2a 58 f3	* X .
	add hl,bc		;104f	09		.
	ld a,(hl)		;1050	7e		~
	ld (0f33dh),a		;1051	32 3d f3	2 = .
	ld a,(0f318h)		;1054	3a 18 f3	: . .
	ld (0f33ch),a		;1057	32 3c f3	2 < .
	ld hl,0ee81h		;105a	21 81 ee	! . .
	ld (0f33ah),hl		;105d	22 3a f3	" : .
	ld a,(0f317h)		;1060	3a 17 f3	: . .
	ld hl,0f31ch		;1063	21 1c f3	! . .
	cp (hl)			;1066	be		.
	jp nz,0e4fah		;1067	c2 fa e4	. . .
	ld a,(0f318h)		;106a	3a 18 f3	: . .
	ld hl,0f31dh		;106d	21 1d f3	! . .
	cp (hl)			;1070	be		.
	jp nz,0e4fah		;1071	c2 fa e4	. . .
	ld a,(0f319h)		;1074	3a 19 f3	: . .
	inc hl			;1077	23		#
	cp (hl)			;1078	be		.
	ret z			;1079	c8		.
	ld a,(0f317h)		;107a	3a 17 f3	: . .
	ld (0f31ch),a		;107d	32 1c f3	2 . .
	ld hl,(0f318h)		;1080	2a 18 f3	* . .
	ld (0f31dh),hl		;1083	22 1d f3	" . .
	call 0e6b8h		;1086	cd b8 e6	. . .
	call 0e682h		;1089	cd 82 e6	. . .
	call 0e6bfh		;108c	cd bf e6	. . .
	ld a,(0f339h)		;108f	3a 39 f3	: 9 .
	and 003h		;1092	e6 03		. .
	add a,020h		;1094	c6 20		.  
	cp b			;1096	b8		.
	ret z			;1097	c8		.
	call 0e6b8h		;1098	cd b8 e6	. . .
	call 0e639h		;109b	cd 39 e6	. 9 .
	push bc			;109e	c5		.
	call 0e6bfh		;109f	cd bf e6	. . .
	call 0e682h		;10a2	cd 82 e6	. . .
	call 0e6bfh		;10a5	cd bf e6	. . .
	pop bc			;10a8	c1		.
	ret			;10a9	c9		.
	ld a,00ah		;10aa	3e 0a		> .
	ld (0f33eh),a		;10ac	32 3e f3	2 > .
	call 0e59eh		;10af	cd 9e e5	. . .
	call 0e6b8h		;10b2	cd b8 e6	. . .
	ld hl,(0f330h)		;10b5	2a 30 f3	* 0 .
	ld c,(hl)		;10b8	4e		N
	inc hl			;10b9	23		#
	ld b,(hl)		;10ba	46		F
	inc hl			;10bb	23		#
	call 0e6f7h		;10bc	cd f7 e6	. . .
	call 0e594h		;10bf	cd 94 e5	. . .
	call 0e6ceh		;10c2	cd ce e6	. . .
	ld c,000h		;10c5	0e 00		. .
	ld hl,0f33fh		;10c7	21 3f f3	! ? .
	ld a,(hl)		;10ca	7e		~
	and 0f8h		;10cb	e6 f8		. .
	ret z			;10cd	c8		.
	and 008h		;10ce	e6 08		. .
	jp nz,0e56ah		;10d0	c2 6a e5	. j .
	ld a,(0f33eh)		;10d3	3a 3e f3	: > .
	dec a			;10d6	3d		=
	ld (0f33eh),a		;10d7	32 3e f3	2 > .
	jp z,0e56ah		;10da	ca 6a e5	. j .
	cp 005h			;10dd	fe 05		. .
	call z,0e518h		;10df	cc 18 e5	. . .
	xor a			;10e2	af		.
	cp c			;10e3	b9		.
	jp z,0e52fh		;10e4	ca 2f e5	. / .
	jp 0e579h		;10e7	c3 79 e5	. y .
	ld a,c			;10ea	79		y
	ld (0f321h),a		;10eb	32 21 f3	2 ! .
	ld a,001h		;10ee	3e 01		> .
	ld (0f32ah),a		;10f0	32 2a f3	2 * .
	ret			;10f3	c9		.
	ld a,00ah		;10f4	3e 0a		> .
	ld (0f33eh),a		;10f6	32 3e f3	2 > .
	call 0e59eh		;10f9	cd 9e e5	. . .
	call 0e6b8h		;10fc	cd b8 e6	. . .
	ld hl,(0f330h)		;10ff	2a 30 f3	* 0 .
	ld c,(hl)		;1102	4e		N
	inc hl			;1103	23		#
	ld b,(hl)		;1104	46		F
	inc hl			;1105	23		#
	call 0e6d6h		;1106	cd d6 e6	. . .
	call 0e599h		;1109	cd 99 e5	. . .
	call 0e6ceh		;110c	cd ce e6	. . .
	ld c,001h		;110f	0e 01		. .
	jp 0e547h		;1111	c3 47 e5	. G .
	ld a,006h		;1114	3e 06		> .
	jp 0e701h		;1116	c3 01 e7	. . .
	ld a,005h		;1119	3e 05		> .
	jp 0e701h		;111b	c3 01 e7	. . .
	in a,(014h)		;111e	db 14		. .
	and 080h		;1120	e6 80		. .
	ret z			;1122	c8		.
	di			;1123	f3		.
	ld hl,(0ffe1h)		;1124	2a e1 ff	* . .
	ld a,l			;1127	7d		}
	or h			;1128	b4		.
	ld hl,(0ffe7h)		;1129	2a e7 ff	* . .
	ld (0ffe1h),hl		;112c	22 e1 ff	" . .
	ei			;112f	fb		.
	ret nz			;1130	c0		.
	ld a,001h		;1131	3e 01		> .
	out (014h),a		;1133	d3 14		. .
	ld hl,00032h		;1135	21 32 00	! 2 .
	call 0e5c6h		;1138	cd c6 e5	. . .
	ret			;113b	c9		.
	in a,(014h)		;113c	db 14		. .
	and 080h		;113e	e6 80		. .
	ret z			;1140	c8		.
	ld a,000h		;1141	3e 00		> .
	out (014h),a		;1143	d3 14		. .
	ret			;1145	c9		.
	ld (0ffe3h),hl		;1146	22 e3 ff	" . .
	ld hl,(0ffe3h)		;1149	2a e3 ff	* . .
	ld a,l			;114c	7d		}
	or h			;114d	b4		.
	jp nz,0e5c9h		;114e	c2 c9 e5	. . .
	ret			;1151	c9		.
	ld a,(0f322h)		;1152	3a 22 f3	: " .
	or a			;1155	b7		.
	jr nz,l115bh		;1156	20 03		  .
	ld (0f321h),a		;1158	32 21 f3	2 ! .
l115bh:
	ld a,(0f35bh)		;115b	3a 5b f3	: [ .
	and a			;115e	a7		.
	jp z,0e608h		;115f	ca 08 e6	. . .
	ld a,(0f312h)		;1162	3a 12 f3	: . .
	ld (0f31ch),a		;1165	32 1c f3	2 . .
	ld hl,(0f351h)		;1168	2a 51 f3	* Q .
	ld de,0000dh		;116b	11 0d 00	. . .
	add hl,de		;116e	19		.
	ld e,(hl)		;116f	5e		^
	inc hl			;1170	23		#
	ld d,(hl)		;1171	56		V
	ld (0f31dh),de		;1172	ed 53 1d f3	. S . .
	call 0e7fah		;1176	cd fa e7	. . .
	call 0e85dh		;1179	cd 5d e8	. ] .
	ret nc			;117c	d0		.
	call 0e86fh		;117d	cd 6f e8	. o .
	in a,(067h)		;1180	db 67		. g
	and 010h		;1182	e6 10		. .
	jp z,0e600h		;1184	ca 00 e6	. . .
	ret			;1187	c9		.
	call 0e59eh		;1188	cd 9e e5	. . .
	ld a,(0f312h)		;118b	3a 12 f3	: . .
	ld (0f339h),a		;118e	32 39 f3	2 9 .
	ld (0f31ch),a		;1191	32 1c f3	2 . .
	xor a			;1194	af		.
	ld (0f31dh),a		;1195	32 1d f3	2 . .
	ld (0f31eh),a		;1198	32 1e f3	2 . .
	call 0e6b8h		;119b	cd b8 e6	. . .
	call 0e639h		;119e	cd 39 e6	. 9 .
	call 0e6bfh		;11a1	cd bf e6	. . .
	ret			;11a4	c9		.
	in a,(004h)		;11a5	db 04		. .
	and 0c0h		;11a7	e6 c0		. .
	cp 080h			;11a9	fe 80		. .
	jp nz,0e625h		;11ab	c2 25 e6	. % .
	ret			;11ae	c9		.
	in a,(004h)		;11af	db 04		. .
	and 0c0h		;11b1	e6 c0		. .
	cp 0c0h			;11b3	fe c0		. .
	jp nz,0e62fh		;11b5	c2 2f e6	. / .
	ret			;11b8	c9		.
	call 0e625h		;11b9	cd 25 e6	. % .
	ld a,007h		;11bc	3e 07		> .
	out (005h),a		;11be	d3 05		. .
	call 0e625h		;11c0	cd 25 e6	. % .
	ld a,(0f339h)		;11c3	3a 39 f3	: 9 .
	and 003h		;11c6	e6 03		. .
	out (005h),a		;11c8	d3 05		. .
	ret			;11ca	c9		.
	call 0e625h		;11cb	cd 25 e6	. % .
	ld a,004h		;11ce	3e 04		> .
	out (005h),a		;11d0	d3 05		. .
	call 0e625h		;11d2	cd 25 e6	. % .
	ld a,(0f339h)		;11d5	3a 39 f3	: 9 .
	and 003h		;11d8	e6 03		. .
	out (005h),a		;11da	d3 05		. .
	call 0e62fh		;11dc	cd 2f e6	. / .
	in a,(005h)		;11df	db 05		. .
	ld (0f33fh),a		;11e1	32 3f f3	2 ? .
	ret			;11e4	c9		.
	call 0e625h		;11e5	cd 25 e6	. % .
	ld a,008h		;11e8	3e 08		> .
	out (005h),a		;11ea	d3 05		. .
	call 0e62fh		;11ec	cd 2f e6	. / .
	in a,(005h)		;11ef	db 05		. .
	ld (0f33fh),a		;11f1	32 3f f3	2 ? .
	and 0c0h		;11f4	e6 c0		. .
	cp 080h			;11f6	fe 80		. .
	ret z			;11f8	c8		.
	call 0e62fh		;11f9	cd 2f e6	. / .
	in a,(005h)		;11fc	db 05		. .
	ld (0f340h),a		;11fe	32 40 f3	2 @ .
	ret			;1201	c9		.
	call 0e625h		;1202	cd 25 e6	. % .
	ld a,00fh		;1205	3e 0f		> .
	out (005h),a		;1207	d3 05		. .
	call 0e625h		;1209	cd 25 e6	. % .
	ld a,(0f339h)		;120c	3a 39 f3	: 9 .
	and 003h		;120f	e6 03		. .
	out (005h),a		;1211	d3 05		. .
	call 0e625h		;1213	cd 25 e6	. % .
	ld a,(0f33ch)		;1216	3a 3c f3	: < .
	out (005h),a		;1219	d3 05		. .
	ret			;121b	c9		.
	ld hl,0f33fh		;121c	21 3f f3	! ? .
	ld d,007h		;121f	16 07		. .
	call 0e62fh		;1221	cd 2f e6	. / .
	in a,(005h)		;1224	db 05		. .
	ld (hl),a		;1226	77		w
	inc hl			;1227	23		#
	ld a,004h		;1228	3e 04		> .
	dec a			;122a	3d		=
	jp nz,0e6aah		;122b	c2 aa e6	. . .
	in a,(004h)		;122e	db 04		. .
	and 010h		;1230	e6 10		. .
	ret z			;1232	c8		.
	dec d			;1233	15		.
	jp nz,0e6a1h		;1234	c2 a1 e6	. . .
	ret			;1237	c9		.
	di			;1238	f3		.
	xor a			;1239	af		.
	ld (0f34fh),a		;123a	32 4f f3	2 O .
	ei			;123d	fb		.
	ret			;123e	c9		.
	call 0e6ceh		;123f	cd ce e6	. . .
	ld a,(0f33fh)		;1242	3a 3f f3	: ? .
	ld b,a			;1245	47		G
	ld a,(0f340h)		;1246	3a 40 f3	: @ .
	ld c,a			;1249	4f		O
	call 0e6b8h		;124a	cd b8 e6	. . .
	ret			;124d	c9		.
	ld a,(0f34fh)		;124e	3a 4f f3	: O .
	or a			;1251	b7		.
	jp z,0e6ceh		;1252	ca ce e6	. . .
	ret			;1255	c9		.
	ld a,005h		;1256	3e 05		> .
	di			;1258	f3		.
	out (0fah),a		;1259	d3 fa		. .
	ld a,049h		;125b	3e 49		> I
	out (0fbh),a		;125d	d3 fb		. .
	out (0fch),a		;125f	d3 fc		. .
	ld a,(0f33ah)		;1261	3a 3a f3	: : .
	out (0f2h),a		;1264	d3 f2		. .
	ld a,(0f33bh)		;1266	3a 3b f3	: ; .
	out (0f2h),a		;1269	d3 f2		. .
	ld a,c			;126b	79		y
	out (0f3h),a		;126c	d3 f3		. .
	ld a,b			;126e	78		x
	out (0f3h),a		;126f	d3 f3		. .
	ld a,001h		;1271	3e 01		> .
	out (0fah),a		;1273	d3 fa		. .
	ei			;1275	fb		.
	ret			;1276	c9		.
	ld a,005h		;1277	3e 05		> .
	di			;1279	f3		.
	out (0fah),a		;127a	d3 fa		. .
	ld a,045h		;127c	3e 45		> E
	jp 0e6ddh		;127e	c3 dd e6	. . .
	push af			;1281	f5		.
	di			;1282	f3		.
	call 0e625h		;1283	cd 25 e6	. % .
	pop af			;1286	f1		.
	ld b,(hl)		;1287	46		F
	inc hl			;1288	23		#
	add a,b			;1289	80		.
	out (005h),a		;128a	d3 05		. .
	call 0e625h		;128c	cd 25 e6	. % .
	ld a,(0f339h)		;128f	3a 39 f3	: 9 .
	out (005h),a		;1292	d3 05		. .
	call 0e625h		;1294	cd 25 e6	. % .
	ld a,(0f33ch)		;1297	3a 3c f3	: < .
	out (005h),a		;129a	d3 05		. .
	call 0e625h		;129c	cd 25 e6	. % .
	ld a,(0f339h)		;129f	3a 39 f3	: 9 .
	rra			;12a2	1f		.
	rra			;12a3	1f		.
	and 003h		;12a4	e6 03		. .
	out (005h),a		;12a6	d3 05		. .
	call 0e625h		;12a8	cd 25 e6	. % .
	ld a,(0f33dh)		;12ab	3a 3d f3	: = .
	out (005h),a		;12ae	d3 05		. .
	call 0e625h		;12b0	cd 25 e6	. % .
	ld a,(hl)		;12b3	7e		~
	inc hl			;12b4	23		#
	out (005h),a		;12b5	d3 05		. .
	call 0e625h		;12b7	cd 25 e6	. % .
	ld a,(hl)		;12ba	7e		~
	inc hl			;12bb	23		#
	out (005h),a		;12bc	d3 05		. .
	call 0e625h		;12be	cd 25 e6	. % .
	ld a,(hl)		;12c1	7e		~
	out (005h),a		;12c2	d3 05		. .
	call 0e625h		;12c4	cd 25 e6	. % .
	ld a,(0f35ah)		;12c7	3a 5a f3	: Z .
	out (005h),a		;12ca	d3 05		. .
	ei			;12cc	fb		.
	ret			;12cd	c9		.
	ld (0f34bh),sp		;12ce	ed 73 4b f3	. s K .
	ld sp,0f620h		;12d2	31 20 f6	1   .
	push af			;12d5	f5		.
	push bc			;12d6	c5		.
	push de			;12d7	d5		.
	push hl			;12d8	e5		.
	ld a,0ffh		;12d9	3e ff		> .
	ld (0f34fh),a		;12db	32 4f f3	2 O .
	ld a,005h		;12de	3e 05		> .
	dec a			;12e0	3d		=
	jp nz,0e760h		;12e1	c2 60 e7	. ` .
	in a,(004h)		;12e4	db 04		. .
	and 010h		;12e6	e6 10		. .
	jp nz,0e771h		;12e8	c2 71 e7	. q .
	call 0e665h		;12eb	cd 65 e6	. e .
	jp 0e774h		;12ee	c3 74 e7	. t .
	call 0e69ch		;12f1	cd 9c e6	. . .
	pop hl			;12f4	e1		.
	pop de			;12f5	d1		.
	pop bc			;12f6	c1		.
	pop af			;12f7	f1		.
	ld sp,(0f34bh)		;12f8	ed 7b 4b f3	. { K .
	ei			;12fc	fb		.
	reti			;12fd	ed 4d		. M
	call 0e7b5h		;12ff	cd b5 e7	. . .
	call nc,0e7fah		;1302	d4 fa e7	. . .
	call 0e87bh		;1305	cd 7b e8	. { .
	ret nc			;1308	d0		.
	ld hl,(0f330h)		;1309	2a 30 f3	* 0 .
	ld c,(hl)		;130c	4e		N
	inc hl			;130d	23		#
	ld b,(hl)		;130e	46		F
	call 0e89ah		;130f	cd 9a e8	. . .
	ld a,030h		;1312	3e 30		> 0
	out (067h),a		;1314	d3 67		. g
	call 0e86fh		;1316	cd 6f e8	. o .
	ret			;1319	c9		.
	call 0e7b5h		;131a	cd b5 e7	. . .
	call nc,0e7fah		;131d	d4 fa e7	. . .
	call 0e87bh		;1320	cd 7b e8	. { .
	ret nc			;1323	d0		.
	ld hl,(0f330h)		;1324	2a 30 f3	* 0 .
	ld c,(hl)		;1327	4e		N
	inc hl			;1328	23		#
	ld b,(hl)		;1329	46		F
	call 0e890h		;132a	cd 90 e8	. . .
	ld a,028h		;132d	3e 28		> (
	out (067h),a		;132f	d3 67		. g
	call 0e86fh		;1331	cd 6f e8	. o .
	ret			;1334	c9		.
	ld hl,0ee81h		;1335	21 81 ee	! . .
	ld (0f33ah),hl		;1338	22 3a f3	" : .
	ld a,(0f317h)		;133b	3a 17 f3	: . .
	ld hl,0f31ch		;133e	21 1c f3	! . .
	cp (hl)			;1341	be		.
	jp nz,0e7d9h		;1342	c2 d9 e7	. . .
	ld a,(0f318h)		;1345	3a 18 f3	: . .
	ld hl,0f31dh		;1348	21 1d f3	! . .
	cp (hl)			;134b	be		.
	jp nz,0e7d9h		;134c	c2 d9 e7	. . .
	ld a,(0f319h)		;134f	3a 19 f3	: . .
	inc hl			;1352	23		#
	cp (hl)			;1353	be		.
	jp nz,0e7d9h		;1354	c2 d9 e7	. . .
	and a			;1357	a7		.
	ret			;1358	c9		.
	ld a,(0f317h)		;1359	3a 17 f3	: . .
	ld (0f31ch),a		;135c	32 1c f3	2 . .
	ld hl,(0f318h)		;135f	2a 18 f3	* . .
	ld (0f31dh),hl		;1362	22 1d f3	" . .
	call 0e7fah		;1365	cd fa e7	. . .
	call 0e85dh		;1368	cd 5d e8	. ] .
	jp nc,0e7f8h		;136b	d2 f8 e7	. . .
	call 0e86fh		;136e	cd 6f e8	. o .
	in a,(067h)		;1371	db 67		. g
	and 010h		;1373	e6 10		. .
	jp z,0e7f1h		;1375	ca f1 e7	. . .
	scf			;1378	37		7
	ret			;1379	c9		.
	ld hl,(0f330h)		;137a	2a 30 f3	* 0 .
	ld de,0ffffh		;137d	11 ff ff	. . .
	ex de,hl		;1380	eb		.
	add hl,de		;1381	19		.
	xor a			;1382	af		.
	ld c,(hl)		;1383	4e		N
	ld b,000h		;1384	06 00		. .
	ld hl,(0f31ah)		;1386	2a 1a f3	* . .
	and a			;1389	a7		.
	sbc hl,bc		;138a	ed 42		. B
	jp c,0e813h		;138c	da 13 e8	. . .
	inc a			;138f	3c		<
	jp 0e809h		;1390	c3 09 e8	. . .
	add hl,bc		;1393	09		.
	push af			;1394	f5		.
	ld a,l			;1395	7d		}
	out (063h),a		;1396	d3 63		. c
	ld a,(0f31ch)		;1398	3a 1c f3	: . .
	ld c,000h		;139b	0e 00		. .
	ld hl,0f335h		;139d	21 35 f3	! 5 .
	sub (hl)		;13a0	96		.
	ld hl,0f336h		;13a1	21 36 f3	! 6 .
	cp (hl)			;13a4	be		.
	jp c,0e83bh		;13a5	da 3b e8	. ; .
	sub (hl)		;13a8	96		.
	inc c			;13a9	0c		.
	ld hl,0f337h		;13aa	21 37 f3	! 7 .
	cp (hl)			;13ad	be		.
	jp c,0e83bh		;13ae	da 3b e8	. ; .
	sub (hl)		;13b1	96		.
	inc c			;13b2	0c		.
	ld hl,0f338h		;13b3	21 38 f3	! 8 .
	cp (hl)			;13b6	be		.
	jp c,0e83bh		;13b7	da 3b e8	. ; .
	inc c			;13ba	0c		.
	sla c			;13bb	cb 21		. !
	sla c			;13bd	cb 21		. !
	sla c			;13bf	cb 21		. !
	pop af			;13c1	f1		.
	or c			;13c2	b1		.
	ld hl,00005h		;13c3	21 05 00	! . .
	add hl,de		;13c6	19		.
	or (hl)			;13c7	b6		.
	out (066h),a		;13c8	d3 66		. f
	ld hl,(0f31dh)		;13ca	2a 1d f3	* . .
	ld a,l			;13cd	7d		}
	out (064h),a		;13ce	d3 64		. d
	ld a,h			;13d0	7c		|
	and 003h		;13d1	e6 03		. .
	out (065h),a		;13d3	d3 65		. e
	ld hl,00006h		;13d5	21 06 00	! . .
	add hl,de		;13d8	19		.
	ld a,(hl)		;13d9	7e		~
	out (061h),a		;13da	d3 61		. a
	ret			;13dc	c9		.
	ld hl,(0f330h)		;13dd	2a 30 f3	* 0 .
	ld de,00005h		;13e0	11 05 00	. . .
	add hl,de		;13e3	19		.
	ld a,070h		;13e4	3e 70		> p
	or (hl)			;13e6	b6		.
	call 0e87bh		;13e7	cd 7b e8	. { .
	ret nc			;13ea	d0		.
	out (067h),a		;13eb	d3 67		. g
	scf			;13ed	37		7
	ret			;13ee	c9		.
	ld a,(0f34dh)		;13ef	3a 4d f3	: M .
	or a			;13f2	b7		.
	jp z,0e86fh		;13f3	ca 6f e8	. o .
	xor a			;13f6	af		.
	ld (0f34dh),a		;13f7	32 4d f3	2 M .
	ret			;13fa	c9		.
	push af			;13fb	f5		.
	in a,(067h)		;13fc	db 67		. g
	and 050h		;13fe	e6 50		. P
	cp 050h			;1400	fe 50		. P
	jp z,0e88dh		;1402	ca 8d e8	. . .
	ld a,0bbh		;1405	3e bb		> .
	ld (0f32ah),a		;1407	32 2a f3	2 * .
	pop af			;140a	f1		.
	and a			;140b	a7		.
	ret			;140c	c9		.
	pop af			;140d	f1		.
	scf			;140e	37		7
	ret			;140f	c9		.
	ld a,004h		;1410	3e 04		> .
	di			;1412	f3		.
	out (0fah),a		;1413	d3 fa		. .
	ld a,044h		;1415	3e 44		> D
	jp 0e8a1h		;1417	c3 a1 e8	. . .
	ld a,004h		;141a	3e 04		> .
	di			;141c	f3		.
	out (0fah),a		;141d	d3 fa		. .
	ld a,048h		;141f	3e 48		> H
	out (0fbh),a		;1421	d3 fb		. .
	out (0fch),a		;1423	d3 fc		. .
	ld a,(0f33ah)		;1425	3a 3a f3	: : .
	out (0f0h),a		;1428	d3 f0		. .
	ld a,(0f33bh)		;142a	3a 3b f3	: ; .
	out (0f0h),a		;142d	d3 f0		. .
	ld a,c			;142f	79		y
	out (0f1h),a		;1430	d3 f1		. .
	ld a,b			;1432	78		x
	out (0f1h),a		;1433	d3 f1		. .
	ld a,000h		;1435	3e 00		> .
	out (0fah),a		;1437	d3 fa		. .
	ei			;1439	fb		.
	ret			;143a	c9		.
	out (066h),a		;143b	d3 66		. f
	xor a			;143d	af		.
	out (061h),a		;143e	d3 61		. a
	out (062h),a		;1440	d3 62		. b
	out (063h),a		;1442	d3 63		. c
	out (064h),a		;1444	d3 64		. d
	out (065h),a		;1446	d3 65		. e
	ld a,010h		;1448	3e 10		> .
	or b			;144a	b0		.
	out (067h),a		;144b	d3 67		. g
	ret			;144d	c9		.
	out (066h),a		;144e	d3 66		. f
	ld a,b			;1450	78		x
	out (061h),a		;1451	d3 61		. a
	ld a,c			;1453	79		y
	out (062h),a		;1454	d3 62		. b
	ld a,e			;1456	7b		{
	out (064h),a		;1457	d3 64		. d
	ld a,d			;1459	7a		z
	out (065h),a		;145a	d3 65		. e
	ld hl,(0f32eh)		;145c	2a 2e f3	* . .
	ld (0f33ah),hl		;145f	22 3a f3	" : .
	call 0e87bh		;1462	cd 7b e8	. { .
	jp nc,0e8fah		;1465	d2 fa e8	. . .
	ld bc,001ffh		;1468	01 ff 01	. . .
	call 0e89ah		;146b	cd 9a e8	. . .
	ld a,050h		;146e	3e 50		> P
	out (067h),a		;1470	d3 67		. g
	call 0e86fh		;1472	cd 6f e8	. o .
	ld a,(0f32ah)		;1475	3a 2a f3	: * .
	and a			;1478	a7		.
	ret z			;1479	c8		.
	xor a			;147a	af		.
	ld (0f32ah),a		;147b	32 2a f3	2 * .
	ld a,001h		;147e	3e 01		> .
	ret			;1480	c9		.
	ld (0f34bh),sp		;1481	ed 73 4b f3	. s K .
	ld sp,0f620h		;1485	31 20 f6	1   .
	push af			;1488	f5		.
	push bc			;1489	c5		.
	push de			;148a	d5		.
	push hl			;148b	e5		.
	ld a,0ffh		;148c	3e ff		> .
	ld (0f34dh),a		;148e	32 4d f3	2 M .
	in a,(067h)		;1491	db 67		. g
	ld (0f347h),a		;1493	32 47 f3	2 G .
	and 001h		;1496	e6 01		. .
	jp z,0e92ch		;1498	ca 2c e9	. , .
	in a,(061h)		;149b	db 61		. a
	ld (0f348h),a		;149d	32 48 f3	2 H .
	ld hl,(0f349h)		;14a0	2a 49 f3	* I .
	inc hl			;14a3	23		#
	ld (0f349h),hl		;14a4	22 49 f3	" I .
	ld a,0bbh		;14a7	3e bb		> .
	ld (0f32ah),a		;14a9	32 2a f3	2 * .
	pop hl			;14ac	e1		.
	pop de			;14ad	d1		.
	pop bc			;14ae	c1		.
	pop af			;14af	f1		.
	ld sp,(0f34bh)		;14b0	ed 7b 4b f3	. { K .
	ei			;14b4	fb		.
	reti			;14b5	ed 4d		. M
	ld bc,00d07h		;14b7	01 07 0d	. . .
	inc de			;14ba	13		.
	add hl,de		;14bb	19		.
	dec b			;14bc	05		.
	dec bc			;14bd	0b		.
	ld de,00317h		;14be	11 17 03	. . .
	add hl,bc		;14c1	09		.
	rrca			;14c2	0f		.
	dec d			;14c3	15		.
	ld (bc),a		;14c4	02		.
	ex af,af'		;14c5	08		.
	ld c,014h		;14c6	0e 14		. .
	ld a,(de)		;14c8	1a		.
	ld b,00ch		;14c9	06 0c		. .
	ld (de),a		;14cb	12		.
	jr $+6			;14cc	18 04		. .
	ld a,(bc)		;14ce	0a		.
	djnz l14e7h		;14cf	10 16		. .
	ld bc,00905h		;14d1	01 05 09	. . .
	dec c			;14d4	0d		.
	ld (bc),a		;14d5	02		.
	ld b,00ah		;14d6	06 0a		. .
	ld c,003h		;14d8	0e 03		. .
	rlca			;14da	07		.
	dec bc			;14db	0b		.
	rrca			;14dc	0f		.
	inc b			;14dd	04		.
	ex af,af'		;14de	08		.
	inc c			;14df	0c		.
	ld bc,00503h		;14e0	01 03 05	. . .
	rlca			;14e3	07		.
	add hl,bc		;14e4	09		.
	ld (bc),a		;14e5	02		.
	inc b			;14e6	04		.
l14e7h:
	ld b,008h		;14e7	06 08		. .
	ld a,(bc)		;14e9	0a		.
	ld bc,00302h		;14ea	01 02 03	. . .
	inc b			;14ed	04		.
	dec b			;14ee	05		.
	ld b,007h		;14ef	06 07		. .
	ex af,af'		;14f1	08		.
	add hl,bc		;14f2	09		.
	ld a,(bc)		;14f3	0a		.
	dec bc			;14f4	0b		.
	inc c			;14f5	0c		.
	dec c			;14f6	0d		.
	ld c,00fh		;14f7	0e 0f		. .
	djnz l150ch		;14f9	10 11		. .
	ld (de),a		;14fb	12		.
	inc de			;14fc	13		.
	inc d			;14fd	14		.
	dec d			;14fe	15		.
	ld d,017h		;14ff	16 17		. .
	jr l151ch		;1501	18 19		. .
	ld a,(de)		;1503	1a		.
	ld a,(de)		;1504	1a		.
	nop			;1505	00		.
	inc bc			;1506	03		.
	rlca			;1507	07		.
	nop			;1508	00		.
	jp p,03f00h		;1509	f2 00 3f	. . ?
l150ch:
	nop			;150c	00		.
	ret nz			;150d	c0		.
	nop			;150e	00		.
	djnz l1511h		;150f	10 00		. .
l1511h:
	ld (bc),a		;1511	02		.
	nop			;1512	00		.
	ld a,b			;1513	78		x
	nop			;1514	00		.
	inc b			;1515	04		.
	rrca			;1516	0f		.
	nop			;1517	00		.
	pop bc			;1518	c1		.
	ld bc,0007fh		;1519	01 7f 00	. . .
l151ch:
	ret nz			;151c	c0		.
	nop			;151d	00		.
	jr nz,l1520h		;151e	20 00		  .
l1520h:
	ld (bc),a		;1520	02		.
	nop			;1521	00		.
	ld c,b			;1522	48		H
	nop			;1523	00		.
	inc b			;1524	04		.
	rrca			;1525	0f		.
	ld bc,00086h		;1526	01 86 00	. . .
	ld a,a			;1529	7f		.
	nop			;152a	00		.
	ret nz			;152b	c0		.
	nop			;152c	00		.
	jr nz,l152fh		;152d	20 00		  .
l152fh:
	ld (bc),a		;152f	02		.
	nop			;1530	00		.
	ld d,b			;1531	50		P
	nop			;1532	00		.
	inc b			;1533	04		.
	rrca			;1534	0f		.
	nop			;1535	00		.
	add a,l			;1536	85		.
	ld bc,0007fh		;1537	01 7f 00	. . .
	ret nz			;153a	c0		.
	nop			;153b	00		.
	jr nz,l153eh		;153c	20 00		  .
l153eh:
	ld (bc),a		;153e	02		.
l153fh:
	nop			;153f	00		.
	add a,b			;1540	80		.
	ld bc,00f04h		;1541	01 04 0f	. . .
	nop			;1544	00		.
	pop bc			;1545	c1		.
	ld bc,0007fh		;1546	01 7f 00	. . .
	ret nz			;1549	c0		.
	nop			;154a	00		.
	nop			;154b	00		.
	nop			;154c	00		.
	inc bc			;154d	03		.
	nop			;154e	00		.
	add a,b			;154f	80		.
	ld bc,00f04h		;1550	01 04 0f	. . .
	ld bc,00086h		;1553	01 86 00	. . .
	ld a,a			;1556	7f		.
	nop			;1557	00		.
	ret nz			;1558	c0		.
	nop			;1559	00		.
	nop			;155a	00		.
	nop			;155b	00		.
	inc bc			;155c	03		.
	nop			;155d	00		.
	add a,b			;155e	80		.
l155fh:
	ld bc,01f05h		;155f	01 05 1f	. . .
	ld bc,001ebh		;1562	01 eb 01	. . .
	rst 38h			;1565	ff		.
	ld bc,000f0h		;1566	01 f0 00	. . .
	nop			;1569	00		.
	nop			;156a	00		.
	dec de			;156b	1b		.
	nop			;156c	00		.
	add a,b			;156d	80		.
	ld bc,03f06h		;156e	01 06 3f	. . ?
	inc bc			;1571	03		.
	ex de,hl		;1572	eb		.
	ld bc,001ffh		;1573	01 ff 01	. . .
	ret nz			;1576	c0		.
	nop			;1577	00		.
	nop			;1578	00		.
	nop			;1579	00		.
	dec de			;157a	1b		.
	nop			;157b	00		.
	add a,b			;157c	80		.
l157dh:
	ld bc,07f07h		;157d	01 07 7f	. . .
	rlca			;1580	07		.
	xor 001h		;1581	ee 01		. .
	rst 38h			;1583	ff		.
	ld bc,00080h		;1584	01 80 00	. . .
	nop			;1587	00		.
	nop			;1588	00		.
	dec de			;1589	1b		.
	nop			;158a	00		.
	ld (bc),a		;158b	02		.
	nop			;158c	00		.
	ld (bc),a		;158d	02		.
	nop			;158e	00		.
	inc bc			;158f	03		.
	nop			;1590	00		.
	dec de			;1591	1b		.
	nop			;1592	00		.
	nop			;1593	00		.
	nop			;1594	00		.
	nop			;1595	00		.
	nop			;1596	00		.
	nop			;1597	00		.
	nop			;1598	00		.
	nop			;1599	00		.
	nop			;159a	00		.
	add a,h			;159b	84		.
	jp (hl)			;159c	e9		.
	ex af,af'		;159d	08		.
	ld a,(de)		;159e	1a		.
	nop			;159f	00		.
	nop			;15a0	00		.
	ld bc,0e937h		;15a1	01 37 e9	. 7 .
	add a,b			;15a4	80		.
	nop			;15a5	00		.
	jr nz,l15c8h		;15a6	20 20		   
	jr nz,l15cah		;15a8	20 20		   
	jr nz,l153fh		;15aa	20 93		  .
	jp (hl)			;15ac	e9		.
	djnz l1627h		;15ad	10 78		. x
	nop			;15af	00		.
	inc bc			;15b0	03		.
	inc bc			;15b1	03		.
	ld d,c			;15b2	51		Q
	jp (hl)			;15b3	e9		.
	rst 38h			;15b4	ff		.
	nop			;15b5	00		.
	ld b,h			;15b6	44		D
	dec (hl)		;15b7	35		5
	ld (00043h),a		;15b8	32 43 00	2 C .
	and d			;15bb	a2		.
	jp (hl)			;15bc	e9		.
	djnz l1607h		;15bd	10 48		. H
	nop			;15bf	00		.
	inc bc			;15c0	03		.
	inc bc			;15c1	03		.
	ld h,b			;15c2	60		`
	jp (hl)			;15c3	e9		.
	rst 38h			;15c4	ff		.
	nop			;15c5	00		.
	jr nz,l15e8h		;15c6	20 20		   
l15c8h:
	jr nz,l15eah		;15c8	20 20		   
l15cah:
	jr nz,l157dh		;15ca	20 b1		  .
	jp (hl)			;15cc	e9		.
	djnz l161fh		;15cd	10 50		. P
	nop			;15cf	00		.
	inc bc			;15d0	03		.
	inc bc			;15d1	03		.
	ld h,b			;15d2	60		`
	jp (hl)			;15d3	e9		.
	rst 38h			;15d4	ff		.
	nop			;15d5	00		.
	ld d,d			;15d6	52		R
	ld b,e			;15d7	43		C
	scf			;15d8	37		7
	jr nc,l160bh		;15d9	30 30		0 0
	ret nz			;15db	c0		.
	jp (hl)			;15dc	e9		.
	djnz l155fh		;15dd	10 80		. .
	ld bc,00303h		;15df	01 03 03	. . .
	nop			;15e2	00		.
	nop			;15e3	00		.
	nop			;15e4	00		.
	rst 38h			;15e5	ff		.
	jr nz,l163bh		;15e6	20 53		  S
l15e8h:
	ld c,a			;15e8	4f		O
	ld b,(hl)		;15e9	46		F
l15eah:
	ld d,h			;15ea	54		T
	rst 8			;15eb	cf		.
	jp (hl)			;15ec	e9		.
	djnz $-126		;15ed	10 80		. .
	ld bc,00303h		;15ef	01 03 03	. . .
	nop			;15f2	00		.
	nop			;15f3	00		.
	nop			;15f4	00		.
	rst 38h			;15f5	ff		.
	ld b,l			;15f6	45		E
	jr nz,$+52		;15f7	20 32		  2
	ld l,031h		;15f9	2e 31		. 1
	sbc a,0e9h		;15fb	de e9		. .
	jr nz,$-126		;15fd	20 80		  .
	ld bc,00303h		;15ff	01 03 03	. . .
	nop			;1602	00		.
	nop			;1603	00		.
	nop			;1604	00		.
	rst 38h			;1605	ff		.
	nop			;1606	00		.
l1607h:
	nop			;1607	00		.
	nop			;1608	00		.
	nop			;1609	00		.
	nop			;160a	00		.
l160bh:
	defb 0edh ;next byte illegal after ed	;160b	ed		.
	jp (hl)			;160c	e9		.
	ld b,b			;160d	40		@
	add a,b			;160e	80		.
	ld bc,00303h		;160f	01 03 03	. . .
	nop			;1612	00		.
	nop			;1613	00		.
	nop			;1614	00		.
	rst 38h			;1615	ff		.
	nop			;1616	00		.
	nop			;1617	00		.
	nop			;1618	00		.
	nop			;1619	00		.
	nop			;161a	00		.
	call m,080e9h		;161b	fc e9 80	. . .
	add a,b			;161e	80		.
l161fh:
	ld bc,00303h		;161f	01 03 03	. . .
	nop			;1622	00		.
	nop			;1623	00		.
	nop			;1624	00		.
	rst 38h			;1625	ff		.
	ld e,d			;1626	5a		Z
l1627h:
	dec l			;1627	2d		-
	jr c,$+50		;1628	38 30		8 0
	jr nz,$+28		;162a	20 1a		  .
	ld a,a			;162c	7f		.
	nop			;162d	00		.
	nop			;162e	00		.
	nop			;162f	00		.
	ld a,(de)		;1630	1a		.
	rlca			;1631	07		.
	ld c,l			;1632	4d		M
	ld e,0ffh		;1633	1e ff		. .
	ld bc,00240h		;1635	01 40 02	. @ .
	rrca			;1638	0f		.
	dec de			;1639	1b		.
	ld c,l			;163a	4d		M
l163bh:
	ld (de),a		;163b	12		.
	rst 38h			;163c	ff		.
	ld bc,00240h		;163d	01 40 02	. @ .
	add hl,bc		;1640	09		.
	dec de			;1641	1b		.
	inc h			;1642	24		$
	inc d			;1643	14		.
	rst 38h			;1644	ff		.
	ld bc,00240h		;1645	01 40 02	. @ .
	ld a,(bc)		;1648	0a		.
	ld a,(bc)		;1649	0a		.
	ld d,b			;164a	50		P
	djnz $+1		;164b	10 ff		. .
	ld bc,00018h		;164d	01 18 00	. . .
	nop			;1650	00		.
	jr nz,l1653h		;1651	20 00		  .
l1653h:
	djnz $+1		;1653	10 ff		. .
	ld bc,00018h		;1655	01 18 00	. . .
	nop			;1658	00		.
	jr nz,l165bh		;1659	20 00		  .
l165bh:
	djnz $+1		;165b	10 ff		. .
	ld bc,00029h		;165d	01 29 00	. ) .
	nop			;1660	00		.
	jr nz,l1663h		;1661	20 00		  .
l1663h:
	djnz $+1		;1663	10 ff		. .
	ld bc,00053h		;1665	01 53 00	. S .
	nop			;1668	00		.
	jr nz,l166bh		;1669	20 00		  .
l166bh:
	djnz $+1		;166b	10 ff		. .
	ld bc,000a6h		;166d	01 a6 00	. . .
	nop			;1670	00		.
	jr nz,l1673h		;1671	20 00		  .
l1673h:
	nop			;1673	00		.
	nop			;1674	00		.
	nop			;1675	00		.
	nop			;1676	00		.
	nop			;1677	00		.
	nop			;1678	00		.
	nop			;1679	00		.
	nop			;167a	00		.
	add a,c			;167b	81		.
	ret p			;167c	f0		.
	sub e			;167d	93		.
	jp (hl)			;167e	e9		.
	ld c,b			;167f	48		H
	pop af			;1680	f1		.
	ld bc,000f1h		;1681	01 f1 00	. . .
	nop			;1684	00		.
	nop			;1685	00		.
	nop			;1686	00		.
	nop			;1687	00		.
	nop			;1688	00		.
	nop			;1689	00		.
	nop			;168a	00		.
	add a,c			;168b	81		.
	ret p			;168c	f0		.
	sub e			;168d	93		.
	jp (hl)			;168e	e9		.
	xor a			;168f	af		.
	pop af			;1690	f1		.
	ld l,b			;1691	68		h
	pop af			;1692	f1		.
	nop			;1693	00		.
	nop			;1694	00		.
	nop			;1695	00		.
	nop			;1696	00		.
	nop			;1697	00		.
	nop			;1698	00		.
	nop			;1699	00		.
	nop			;169a	00		.
	add a,c			;169b	81		.
	ret p			;169c	f0		.
	rst 8			;169d	cf		.
	jp (hl)			;169e	e9		.
	nop			;169f	00		.
	nop			;16a0	00		.
	rst 8			;16a1	cf		.
	pop af			;16a2	f1		.
	nop			;16a3	00		.
	nop			;16a4	00		.
	nop			;16a5	00		.
	nop			;16a6	00		.
	nop			;16a7	00		.
	nop			;16a8	00		.
	nop			;16a9	00		.
	nop			;16aa	00		.
	add a,c			;16ab	81		.
	ret p			;16ac	f0		.
	call m,000e9h		;16ad	fc e9 00	. . .
	nop			;16b0	00		.
	ld d,0f2h		;16b1	16 f2		. .
	nop			;16b3	00		.
	nop			;16b4	00		.
	nop			;16b5	00		.
	nop			;16b6	00		.
	nop			;16b7	00		.
	nop			;16b8	00		.
	nop			;16b9	00		.
	nop			;16ba	00		.
	add a,c			;16bb	81		.
	ret p			;16bc	f0		.
	defb 0edh ;next byte illegal after ed	;16bd	ed		.
	jp (hl)			;16be	e9		.
	nop			;16bf	00		.
	nop			;16c0	00		.
	ld d,l			;16c1	55		U
	jp p,00000h		;16c2	f2 00 00	. . .
	nop			;16c5	00		.
	nop			;16c6	00		.
	nop			;16c7	00		.
	nop			;16c8	00		.
	nop			;16c9	00		.
	nop			;16ca	00		.
	add a,c			;16cb	81		.
	ret p			;16cc	f0		.
	defb 0edh ;next byte illegal after ed	;16cd	ed		.
	jp (hl)			;16ce	e9		.
	nop			;16cf	00		.
	nop			;16d0	00		.
	sub h			;16d1	94		.
	jp p,00000h		;16d2	f2 00 00	. . .
	nop			;16d5	00		.
	nop			;16d6	00		.
	nop			;16d7	00		.
	nop			;16d8	00		.
	nop			;16d9	00		.
	nop			;16da	00		.
	add a,c			;16db	81		.
	ret p			;16dc	f0		.
	sbc a,0e9h		;16dd	de e9		. .
	nop			;16df	00		.
	nop			;16e0	00		.
	out (0f2h),a		;16e1	d3 f2		. .
	ei			;16e3	fb		.
	reti			;16e4	ed 4d		. M
	ld e,e			;16e6	5b		[
	ld (hl),h		;16e7	74		t
	ld c,c			;16e8	49		I
	ld a,a			;16e9	7f		.
	ld c,c			;16ea	49		I
	ld bc,06f4ah		;16eb	01 4a 6f	. J o
	ld c,(hl)		;16ee	4e		N
	sub (hl)		;16ef	96		.
	ld c,c			;16f0	49		I
	dec d			;16f1	15		.
	ld d,a			;16f2	57		W
	xor (hl)		;16f3	ae		.
	ld c,c			;16f4	49		I
	adc a,d			;16f5	8a		.
	ld c,c			;16f6	49		I
	dec d			;16f7	15		.
	ld d,e			;16f8	53		S
	ld sp,hl		;16f9	f9		.
	ld c,(hl)		;16fa	4e		N
	nop			;16fb	00		.
	nop			;16fc	00		.
	ld d,e			;16fd	53		S
	ld d,c			;16fe	51		Q
	call c,0004eh		;16ff	dc 4e 00	. N .
	nop			;1702	00		.
	dec c			;1703	0d		.
	ld c,d			;1704	4a		J
	nop			;1705	00		.
	nop			;1706	00		.
	nop			;1707	00		.
	nop			;1708	00		.
	nop			;1709	00		.
	rst 38h			;170a	ff		.
	nop			;170b	00		.
	nop			;170c	00		.
	nop			;170d	00		.
	nop			;170e	00		.
	nop			;170f	00		.
	nop			;1710	00		.
	nop			;1711	00		.
	nop			;1712	00		.
	nop			;1713	00		.
	nop			;1714	00		.
	nop			;1715	00		.
	nop			;1716	00		.
	nop			;1717	00		.
	nop			;1718	00		.
	nop			;1719	00		.
	nop			;171a	00		.
	nop			;171b	00		.
	nop			;171c	00		.
	nop			;171d	00		.
	ld bc,00001h		;171e	01 01 00	. . .
	nop			;1721	00		.
	nop			;1722	00		.
	nop			;1723	00		.
	nop			;1724	00		.
	nop			;1725	00		.
	nop			;1726	00		.
	nop			;1727	00		.
	nop			;1728	00		.
	xor a			;1729	af		.
	ld h,a			;172a	67		g
	adc a,e			;172b	8b		.
	adc a,d			;172c	8a		.
	xor e			;172d	ab		.
	adc a,d			;172e	8a		.
	nop			;172f	00		.
	nop			;1730	00		.
	nop			;1731	00		.
	nop			;1732	00		.
	nop			;1733	00		.
	nop			;1734	00		.
	dec b			;1735	05		.
	call z,0c905h		;1736	cc 05 c9	. . .
	ld d,c			;1739	51		Q
	ld b,c			;173a	41		A
	rlca			;173b	07		.
	ld d,c			;173c	51		Q
	ld b,d			;173d	42		B
	nop			;173e	00		.
	ld d,c			;173f	51		Q
	ld b,e			;1740	43		C
	ld bc,04451h		;1741	01 51 44	. Q D
	ld (bc),a		;1744	02		.
	ld d,c			;1745	51		Q
	ld b,l			;1746	45		E
	inc bc			;1747	03		.
	ld d,c			;1748	51		Q
	ld c,b			;1749	48		H
	inc b			;174a	04		.
	ld d,c			;174b	51		Q
	ld c,h			;174c	4c		L
	dec b			;174d	05		.
	ld d,c			;174e	51		Q
	ld c,l			;174f	4d		M
	ld b,062h		;1750	06 62		. b
	ld d,e			;1752	53		S
	ld d,b			;1753	50		P
	ld b,063h		;1754	06 63		. c
	ld d,b			;1756	50		P
	ld d,e			;1757	53		S
	ld d,a			;1758	57		W
	ld b,051h		;1759	06 51		. Q
	ld c,c			;175b	49		I
	ex af,af'		;175c	08		.
	ld d,c			;175d	51		Q
	ld d,d			;175e	52		R
	add hl,bc		;175f	09		.
	ld h,d			;1760	62		b
	ld b,d			;1761	42		B
	ld b,e			;1762	43		C
	nop			;1763	00		.
	ld h,d			;1764	62		b
	ld b,h			;1765	44		D
	ld b,l			;1766	45		E
	ld (bc),a		;1767	02		.
	ld h,d			;1768	62		b
	ld c,b			;1769	48		H
	ld c,h			;176a	4c		L
	inc b			;176b	04		.
	ld h,d			;176c	62		b
	ld b,c			;176d	41		A
	ld b,(hl)		;176e	46		F
	ld b,06ah		;176f	06 6a		. j
	ld c,c			;1771	49		I
	ld e,b			;1772	58		X
	ld b,h			;1773	44		D
	ld l,d			;1774	6a		j
	ld c,c			;1775	49		I
	ld e,c			;1776	59		Y
	ld h,h			;1777	64		d
	ld (hl),d		;1778	72		r
	ld c,(hl)		;1779	4e		N
	ld e,d			;177a	5a		Z
	nop			;177b	00		.
	ld (hl),c		;177c	71		q
	ld e,d			;177d	5a		Z
	ld bc,06372h		;177e	01 72 63	. r c
	ex de,hl		;1781	eb		.
	ld h,e			;1782	63		c
	ex de,hl		;1783	eb		.
	cp h			;1784	bc		.
	pop hl			;1785	e1		.
	ld c,(hl)		;1786	4e		N
	rst 20h			;1787	e7		.
	ld bc,063e9h		;1788	01 e9 63	. . c
	ex de,hl		;178b	eb		.
	ld h,e			;178c	63		c
	ex de,hl		;178d	eb		.
	ld h,e			;178e	63		c
	ex de,hl		;178f	eb		.
	add a,e			;1790	83		.
	call c,0dc9ch		;1791	dc 9c dc	. . .
	or l			;1794	b5		.
	call c,0dccah		;1795	dc ca dc	. . .
	rst 20h			;1798	e7		.
	call c,0dd00h		;1799	dc 00 dd	. . .
	add hl,de		;179c	19		.
	defb 0ddh,033h,0ddh ;illegal sequence	;179d	dd 33 dd	. 3 .
	ld b,e			;17a0	43		C
	call pe,0ec58h		;17a1	ec 58 ec	. X .
	nop			;17a4	00		.
	call pe,00000h		;17a5	ec 00 00	. . .
	ld a,(0ec26h)		;17a8	3a 26 ec	: & .
	ret			;17ab	c9		.
	ld a,(0ec26h)		;17ac	3a 26 ec	: & .
	or a			;17af	b7		.
	jp z,0ec2ch		;17b0	ca 2c ec	. , .
	di			;17b3	f3		.
	xor a			;17b4	af		.
	ld (0ec26h),a		;17b5	32 26 ec	2 & .
	ei			;17b8	fb		.
	in a,(010h)		;17b9	db 10		. .
	ld c,a			;17bb	4f		O
	ld hl,0f700h		;17bc	21 00 f7	! . .
	call 0dd7ah		;17bf	cd 7a dd	. z .
	ret			;17c2	c9		.
	ld (0f34bh),sp		;17c3	ed 73 4b f3	. s K .
	ld sp,0f620h		;17c7	31 20 f6	1   .
	push af			;17ca	f5		.
	ld a,0ffh		;17cb	3e ff		> .
	ld (0ec26h),a		;17cd	32 26 ec	2 & .
	pop af			;17d0	f1		.
	ld sp,(0f34bh)		;17d1	ed 7b 4b f3	. { K .
	ei			;17d5	fb		.
	reti			;17d6	ed 4d		. M
	ld (0f34bh),sp		;17d8	ed 73 4b f3	. s K .
	ld sp,0f620h		;17dc	31 20 f6	1   .
	push af			;17df	f5		.
	ld a,0ffh		;17e0	3e ff		> .
	ld (0ec27h),a		;17e2	32 27 ec	2 ' .
	pop af			;17e5	f1		.
	ld sp,(0f34bh)		;17e6	ed 7b 4b f3	. { K .
	ei			;17ea	fb		.
	reti			;17eb	ed 4d		. M
	ld b,c			;17ed	41		A
	ld b,(hl)		;17ee	46		F
	ld b,06ah		;17ef	06 6a		. j
	ld c,c			;17f1	49		I
	ld e,b			;17f2	58		X
	ld b,h			;17f3	44		D
	ld l,d			;17f4	6a		j
	ld c,c			;17f5	49		I
	ld e,c			;17f6	59		Y
	ld h,h			;17f7	64		d
	ld (hl),d		;17f8	72		r
	ld c,(hl)		;17f9	4e		N
	ld e,d			;17fa	5a		Z
	nop			;17fb	00		.
	ld (hl),c		;17fc	71		q
	ld e,d			;17fd	5a		Z
	defb 001h,072h		;17fe	01 72		. r
