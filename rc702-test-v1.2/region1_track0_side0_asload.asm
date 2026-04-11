; z80dasm 1.2.0
; command line: z80dasm -a -l -t -g 0x0000 -o region1_track0_side0.asm region1_track0_side0.bin

	org 00000h

l0000h:
	add a,b			;0000	80		.
l0001h:
	ld (bc),a		;0001	02		.
l0002h:
	nop			;0002	00		.
l0003h:
	nop			;0003	00		.
l0004h:
	nop			;0004	00		.
	nop			;0005	00		.
	nop			;0006	00		.
	nop			;0007	00		.
	jr nz,l005ch		;0008	20 52		  R
	ld b,e			;000a	43		C
	scf			;000b	37		7
	jr nc,l0040h		;000c	30 32		0 2
	nop			;000e	00		.
l000fh:
	nop			;000f	00		.
	nop			;0010	00		.
	nop			;0011	00		.
	nop			;0012	00		.
	nop			;0013	00		.
	nop			;0014	00		.
	nop			;0015	00		.
	nop			;0016	00		.
	nop			;0017	00		.
	nop			;0018	00		.
	nop			;0019	00		.
	nop			;001a	00		.
	nop			;001b	00		.
	nop			;001c	00		.
	nop			;001d	00		.
	nop			;001e	00		.
	nop			;001f	00		.
	nop			;0020	00		.
	nop			;0021	00		.
	nop			;0022	00		.
	nop			;0023	00		.
	nop			;0024	00		.
	nop			;0025	00		.
	nop			;0026	00		.
	nop			;0027	00		.
	nop			;0028	00		.
	nop			;0029	00		.
	nop			;002a	00		.
	nop			;002b	00		.
	nop			;002c	00		.
	nop			;002d	00		.
l002eh:
	nop			;002e	00		.
	nop			;002f	00		.
	nop			;0030	00		.
	nop			;0031	00		.
	nop			;0032	00		.
	nop			;0033	00		.
	nop			;0034	00		.
	nop			;0035	00		.
	nop			;0036	00		.
	nop			;0037	00		.
	nop			;0038	00		.
	nop			;0039	00		.
	nop			;003a	00		.
	nop			;003b	00		.
	nop			;003c	00		.
	nop			;003d	00		.
	nop			;003e	00		.
	nop			;003f	00		.
l0040h:
	nop			;0040	00		.
	nop			;0041	00		.
	nop			;0042	00		.
	nop			;0043	00		.
	nop			;0044	00		.
	nop			;0045	00		.
	nop			;0046	00		.
	nop			;0047	00		.
	nop			;0048	00		.
	nop			;0049	00		.
	nop			;004a	00		.
	nop			;004b	00		.
	nop			;004c	00		.
	nop			;004d	00		.
	nop			;004e	00		.
	nop			;004f	00		.
	nop			;0050	00		.
	nop			;0051	00		.
	nop			;0052	00		.
	nop			;0053	00		.
	nop			;0054	00		.
	nop			;0055	00		.
	nop			;0056	00		.
	nop			;0057	00		.
	nop			;0058	00		.
	nop			;0059	00		.
	nop			;005a	00		.
	nop			;005b	00		.
l005ch:
	nop			;005c	00		.
	nop			;005d	00		.
	nop			;005e	00		.
	nop			;005f	00		.
	nop			;0060	00		.
	nop			;0061	00		.
	nop			;0062	00		.
	nop			;0063	00		.
	nop			;0064	00		.
	nop			;0065	00		.
	nop			;0066	00		.
	nop			;0067	00		.
	nop			;0068	00		.
	nop			;0069	00		.
	nop			;006a	00		.
	nop			;006b	00		.
	nop			;006c	00		.
	nop			;006d	00		.
	nop			;006e	00		.
	nop			;006f	00		.
	nop			;0070	00		.
	nop			;0071	00		.
	nop			;0072	00		.
	nop			;0073	00		.
	nop			;0074	00		.
	nop			;0075	00		.
	call nz,019cch		;0076	c4 cc 19	. . .
	ex de,hl		;0079	eb		.
	ld (03917h),hl		;007a	22 17 39	" . 9
	ex de,hl		;007d	eb		.
	ld c,00bh		;007e	0e 0b		. .
l0080h:
	ld b,a			;0080	47		G
	jr nz,$+73		;0081	20 47		  G
	jr nz,l005ch		;0083	20 d7		  .
	ld bc,l01d7h		;0085	01 d7 01	. . .
	jr l008eh		;0088	18 04		. .
	ld b,a			;008a	47		G
	inc bc			;008b	03		.
	ld h,c			;008c	61		a
	dec b			;008d	05		.
l008eh:
	jr nz,l0091h		;008e	20 01		  .
	dec de			;0090	1b		.
l0091h:
	jr l0095h		;0091	18 02		. .
	djnz l0099h		;0093	10 04		. .
l0095h:
	ld b,a			;0095	47		G
	inc bc			;0096	03		.
	ld h,b			;0097	60		`
	dec b			;0098	05		.
l0099h:
	jr nz,l009ch		;0099	20 01		  .
	rra			;009b	1f		.
l009ch:
	ld c,b			;009c	48		H
	ld c,c			;009d	49		I
	ld c,d			;009e	4a		J
	ld c,e			;009f	4b		K
	ld c,a			;00a0	4f		O
	sbc a,b			;00a1	98		.
	ld a,d			;00a2	7a		z
	ld c,l			;00a3	4d		M
	inc bc			;00a4	03		.
	inc bc			;00a5	03		.
	rst 18h			;00a6	df		.
	jr z,l00a9h		;00a7	28 00		( .
l00a9h:
	inc b			;00a9	04		.
	ld b,006h		;00aa	06 06		. .
	nop			;00ac	00		.
	jp m,00800h		;00ad	fa 00 08	. . .
	ex af,af'		;00b0	08		.
	jr nz,$+1		;00b1	20 ff		  .
	rst 38h			;00b3	ff		.
	rst 38h			;00b4	ff		.
	rst 38h			;00b5	ff		.
	rst 38h			;00b6	ff		.
	rst 38h			;00b7	ff		.
	rst 38h			;00b8	ff		.
	rst 38h			;00b9	ff		.
	rst 38h			;00ba	ff		.
	rst 38h			;00bb	ff		.
	rst 38h			;00bc	ff		.
	rst 38h			;00bd	ff		.
	rst 38h			;00be	ff		.
	rst 38h			;00bf	ff		.
	ld (bc),a		;00c0	02		.
	ld (bc),a		;00c1	02		.
	nop			;00c2	00		.
	nop			;00c3	00		.
	rst 10h			;00c4	d7		.
	ld bc,00103h		;00c5	01 03 01	. . .
	ld a,(03247h)		;00c8	3a 47 32	: G 2
	ld d,039h		;00cb	16 39		. 9
	ld hl,(0391bh)		;00cd	2a 1b 39	* . 9
	jp 023f5h		;00d0	c3 f5 23	. . #
	call 02472h		;00d3	cd 72 24	. r $
	call 0197ch		;00d6	cd 7c 19	. | .
	ld a,002h		;00d9	3e 02		> .
	ld (03a01h),a		;00db	32 01 3a	2 . :
	ld b,a			;00de	47		G
	ld (03916h),a		;00df	32 16 39	2 . 9
	ld hl,(0391dh)		;00e2	2a 1d 39	* . 9
	jp 023f5h		;00e5	c3 f5 23	. . #
	ld a,(03a01h)		;00e8	3a 01 3a	: . :
	or a			;00eb	b7		.
	call nz,0294fh		;00ec	c4 4f 29	. O )
	ld a,(03916h)		;00ef	3a 16 39	: . 9
	ld bc,03919h		;00f2	01 19 39	. . 9
	and 003h		;00f5	e6 03		. .
	cp 003h			;00f7	fe 03		. .
	jp z,024a0h		;00f9	ca a0 24	. . $
	add a,a			;00fc	87		.
	ld l,a			;00fd	6f		o
	ld h,000h		;00fe	26 00		& .
	nop			;0100	00		.
	ld bc,00302h		;0101	01 02 03	. . .
	inc b			;0104	04		.
	dec b			;0105	05		.
	ld b,007h		;0106	06 07		. .
	ex af,af'		;0108	08		.
	add hl,bc		;0109	09		.
	ld a,(bc)		;010a	0a		.
	dec bc			;010b	0b		.
	inc c			;010c	0c		.
	dec c			;010d	0d		.
	ld c,00fh		;010e	0e 0f		. .
	djnz $+19		;0110	10 11		. .
	ld (de),a		;0112	12		.
	inc de			;0113	13		.
	inc d			;0114	14		.
	dec d			;0115	15		.
	ld d,017h		;0116	16 17		. .
	jr $+27			;0118	18 19		. .
	ld a,(de)		;011a	1a		.
	dec de			;011b	1b		.
	inc e			;011c	1c		.
	dec e			;011d	1d		.
	ld e,01fh		;011e	1e 1f		. .
	jr nz,l0143h		;0120	20 21		  !
	ld (02423h),hl		;0122	22 23 24	" # $
	dec h			;0125	25		%
	ld h,027h		;0126	26 27		& '
	jr z,l0153h		;0128	28 29		( )
	ld hl,(02c2bh)		;012a	2a 2b 2c	* + ,
	dec l			;012d	2d		-
	ld l,02fh		;012e	2e 2f		. /
	jr nc,l0163h		;0130	30 31		0 1
	ld (03433h),a		;0132	32 33 34	2 3 4
	dec (hl)		;0135	35		5
	ld (hl),037h		;0136	36 37		6 7
	jr c,l0173h		;0138	38 39		8 9
	ld a,(03c3bh)		;013a	3a 3b 3c	: ; <
	dec a			;013d	3d		=
	ld a,03fh		;013e	3e 3f		> ?
	dec b			;0140	05		.
	ld b,c			;0141	41		A
	ld b,d			;0142	42		B
l0143h:
	ld b,e			;0143	43		C
	ld b,h			;0144	44		D
	ld b,l			;0145	45		E
	ld b,(hl)		;0146	46		F
	ld b,a			;0147	47		G
	ld c,b			;0148	48		H
	ld c,c			;0149	49		I
	ld c,d			;014a	4a		J
	ld c,e			;014b	4b		K
	ld c,h			;014c	4c		L
	ld c,l			;014d	4d		M
	ld c,(hl)		;014e	4e		N
	ld c,a			;014f	4f		O
	ld d,b			;0150	50		P
	ld d,c			;0151	51		Q
	ld d,d			;0152	52		R
l0153h:
	ld d,e			;0153	53		S
	ld d,h			;0154	54		T
	ld d,l			;0155	55		U
	ld d,(hl)		;0156	56		V
	ld d,a			;0157	57		W
	ld e,b			;0158	58		X
	ld e,c			;0159	59		Y
	ld e,d			;015a	5a		Z
	dec bc			;015b	0b		.
	inc c			;015c	0c		.
	dec c			;015d	0d		.
	ld e,(hl)		;015e	5e		^
	ld e,a			;015f	5f		_
	ld d,061h		;0160	16 61		. a
	ld h,d			;0162	62		b
l0163h:
	ld h,e			;0163	63		c
	ld h,h			;0164	64		d
	ld h,l			;0165	65		e
	ld h,(hl)		;0166	66		f
	ld h,a			;0167	67		g
	ld l,b			;0168	68		h
	ld l,c			;0169	69		i
	ld l,d			;016a	6a		j
	ld l,e			;016b	6b		k
	ld l,h			;016c	6c		l
	ld l,l			;016d	6d		m
	ld l,(hl)		;016e	6e		n
	ld l,a			;016f	6f		o
	ld (hl),b		;0170	70		p
	ld (hl),c		;0171	71		q
	ld (hl),d		;0172	72		r
l0173h:
	ld (hl),e		;0173	73		s
	ld (hl),h		;0174	74		t
	ld (hl),l		;0175	75		u
	halt			;0176	76		v
	ld (hl),a		;0177	77		w
	ld a,b			;0178	78		x
	ld a,c			;0179	79		y
	ld a,d			;017a	7a		z
	dec de			;017b	1b		.
	inc e			;017c	1c		.
	dec e			;017d	1d		.
	rrca			;017e	0f		.
	ld a,a			;017f	7f		.
l0180h:
	nop			;0180	00		.
	ld bc,00302h		;0181	01 02 03	. . .
	inc b			;0184	04		.
	dec b			;0185	05		.
	ld b,007h		;0186	06 07		. .
	ex af,af'		;0188	08		.
	add hl,bc		;0189	09		.
	ld a,(bc)		;018a	0a		.
	dec bc			;018b	0b		.
	inc c			;018c	0c		.
	dec c			;018d	0d		.
	ld c,00fh		;018e	0e 0f		. .
	djnz $+19		;0190	10 11		. .
	ld (de),a		;0192	12		.
	inc de			;0193	13		.
	inc d			;0194	14		.
	dec d			;0195	15		.
	ld d,017h		;0196	16 17		. .
	jr $+27			;0198	18 19		. .
	ld a,(de)		;019a	1a		.
	dec de			;019b	1b		.
	inc e			;019c	1c		.
	dec e			;019d	1d		.
	ld e,01fh		;019e	1e 1f		. .
	jr nz,l01c3h		;01a0	20 21		  !
	ld (02423h),hl		;01a2	22 23 24	" # $
	dec h			;01a5	25		%
	ld h,027h		;01a6	26 27		& '
	jr z,l01d3h		;01a8	28 29		( )
	ld hl,(02c2bh)		;01aa	2a 2b 2c	* + ,
	dec l			;01ad	2d		-
	ld l,02fh		;01ae	2e 2f		. /
	jr nc,l01e3h		;01b0	30 31		0 1
	ld (03433h),a		;01b2	32 33 34	2 3 4
	dec (hl)		;01b5	35		5
	ld (hl),037h		;01b6	36 37		6 7
	jr c,l01f3h		;01b8	38 39		8 9
	ld a,(03c3bh)		;01ba	3a 3b 3c	: ; <
	dec a			;01bd	3d		=
	ld a,03fh		;01be	3e 3f		> ?
	ld b,b			;01c0	40		@
	ld b,c			;01c1	41		A
	ld b,d			;01c2	42		B
l01c3h:
	ld b,e			;01c3	43		C
	ld b,h			;01c4	44		D
	ld b,l			;01c5	45		E
	ld b,(hl)		;01c6	46		F
	ld b,a			;01c7	47		G
	ld c,b			;01c8	48		H
	ld c,c			;01c9	49		I
	ld c,d			;01ca	4a		J
	ld c,e			;01cb	4b		K
	ld c,h			;01cc	4c		L
	ld c,l			;01cd	4d		M
	ld c,(hl)		;01ce	4e		N
	ld c,a			;01cf	4f		O
	ld d,b			;01d0	50		P
	ld d,c			;01d1	51		Q
	ld d,d			;01d2	52		R
l01d3h:
	ld d,e			;01d3	53		S
	ld d,h			;01d4	54		T
	ld d,l			;01d5	55		U
	ld d,(hl)		;01d6	56		V
l01d7h:
	ld d,a			;01d7	57		W
	ld e,b			;01d8	58		X
	ld e,c			;01d9	59		Y
	ld e,d			;01da	5a		Z
	ld e,e			;01db	5b		[
	ld e,h			;01dc	5c		\
	ld e,l			;01dd	5d		]
	ld e,(hl)		;01de	5e		^
	ld e,a			;01df	5f		_
	ld h,b			;01e0	60		`
	ld h,c			;01e1	61		a
	ld h,d			;01e2	62		b
l01e3h:
	ld h,e			;01e3	63		c
	ld h,h			;01e4	64		d
	ld h,l			;01e5	65		e
	ld h,(hl)		;01e6	66		f
	ld h,a			;01e7	67		g
	ld l,b			;01e8	68		h
	ld l,c			;01e9	69		i
	ld l,d			;01ea	6a		j
	ld l,e			;01eb	6b		k
	ld l,h			;01ec	6c		l
	ld l,l			;01ed	6d		m
	ld l,(hl)		;01ee	6e		n
	ld l,a			;01ef	6f		o
	ld (hl),b		;01f0	70		p
	ld (hl),c		;01f1	71		q
	ld (hl),d		;01f2	72		r
l01f3h:
	ld (hl),e		;01f3	73		s
	ld (hl),h		;01f4	74		t
	ld (hl),l		;01f5	75		u
	halt			;01f6	76		v
	ld (hl),a		;01f7	77		w
	ld a,b			;01f8	78		x
	ld a,c			;01f9	79		y
	ld a,d			;01fa	7a		z
	ld a,e			;01fb	7b		{
	ld a,h			;01fc	7c		|
	ld a,l			;01fd	7d		}
	ld a,(hl)		;01fe	7e		~
	ld a,a			;01ff	7f		.
	add a,b			;0200	80		.
	ld bc,l0382h		;0201	01 82 03	. . .
	inc b			;0204	04		.
	dec b			;0205	05		.
	add a,(hl)		;0206	86		.
	add a,a			;0207	87		.
	ex af,af'		;0208	08		.
	add hl,bc		;0209	09		.
	ld a,(bc)		;020a	0a		.
	dec bc			;020b	0b		.
	inc c			;020c	0c		.
	dec c			;020d	0d		.
	ld c,08fh		;020e	0e 8f		. .
	djnz $-109		;0210	10 91		. .
	sub d			;0212	92		.
	sub e			;0213	93		.
	inc d			;0214	14		.
	dec d			;0215	15		.
	sub (hl)		;0216	96		.
	sub a			;0217	97		.
	jr $+27			;0218	18 19		. .
	ld a,(de)		;021a	1a		.
	dec de			;021b	1b		.
	inc e			;021c	1c		.
	sbc a,l			;021d	9d		.
	ld e,09fh		;021e	1e 9f		. .
	jr nz,l0253h		;0220	20 31		  1
	ld (03433h),a		;0222	32 33 34	2 3 4
	dec (hl)		;0225	35		5
	ld (hl),037h		;0226	36 37		6 7
	jr c,$+59		;0228	38 39		8 9
	xor d			;022a	aa		.
	jr nc,l025ah		;022b	30 2d		0 -
	xor l			;022d	ad		.
	ld l,08bh		;022e	2e 8b		. .
	jr nc,$+51		;0230	30 31		0 1
	ld (03433h),a		;0232	32 33 34	2 3 4
	dec (hl)		;0235	35		5
	ld (hl),037h		;0236	36 37		6 7
	jr c,l0273h		;0238	38 39		8 9
	cp d			;023a	ba		.
	jr nc,l026ah		;023b	30 2d		0 -
	cp l			;023d	bd		.
	ld l,083h		;023e	2e 83		. .
	ld (de),a		;0240	12		.
	add a,(hl)		;0241	86		.
	jp nz,0c4c3h		;0242	c2 c3 c4	. . .
	push bc			;0245	c5		.
	add a,d			;0246	82		.
	rst 0			;0247	c7		.
	ex af,af'		;0248	08		.
	add hl,bc		;0249	09		.
	ld a,(bc)		;024a	0a		.
	add a,h			;024b	84		.
	add a,l			;024c	85		.
	call 0cfceh		;024d	cd ce cf	. . .
	add a,c			;0250	81		.
	pop de			;0251	d1		.
	add a,a			;0252	87		.
l0253h:
	out (0d4h),a		;0253	d3 d4		. .
	push de			;0255	d5		.
	add a,b			;0256	80		.
	rst 10h			;0257	d7		.
	jr $-37			;0258	18 d9		. .
l025ah:
	ld a,(de)		;025a	1a		.
	in a,(0dch)		;025b	db dc		. .
	defb 0ddh,0deh,030h ;illegal sequence	;025d	dd de 30	. . 0
	ret po			;0260	e0		.
	adc a,(hl)		;0261	8e		.
	jp po,0e4e3h		;0262	e2 e3 e4	. . .
	push hl			;0265	e5		.
	adc a,d			;0266	8a		.
	rst 20h			;0267	e7		.
	ret pe			;0268	e8		.
	jp (hl)			;0269	e9		.
l026ah:
	jp pe,08d8ch		;026a	ea 8c 8d	. . .
	defb 0edh ;next byte illegal after ed	;026d	ed		.
	xor 0efh		;026e	ee ef		. .
	adc a,c			;0270	89		.
	pop af			;0271	f1		.
	adc a,a			;0272	8f		.
l0273h:
	di			;0273	f3		.
	call p,088f5h		;0274	f4 f5 88	. . .
	rst 30h			;0277	f7		.
	ret m			;0278	f8		.
	ld sp,hl		;0279	f9		.
	jp m,0fcfbh		;027a	fa fb fc	. . .
	defb 0fdh,0feh,07fh ;illegal sequence	;027d	fd fe 7f	. . .
	di			;0280	f3		.
	ld hl,l0000h		;0281	21 00 00	! . .
	ld de,0d480h		;0284	11 80 d4	. . .
	ld bc,02381h		;0287	01 81 23	. . #
	ldir			;028a	ed b0		. .
	ld hl,0d580h		;028c	21 80 d5	! . .
	ld de,0f680h		;028f	11 80 f6	. . .
	ld bc,l0180h		;0292	01 80 01	. . .
	ldir			;0295	ed b0		. .
	ld sp,l0080h		;0297	31 80 00	1 . .
	ld a,(0ec25h)		;029a	3a 25 ec	: % .
	ld i,a			;029d	ed 47		. G
	im 2			;029f	ed 5e		. ^
	ld a,020h		;02a1	3e 20		>  
	out (012h),a		;02a3	d3 12		. .
	ld a,022h		;02a5	3e 22		> "
	out (013h),a		;02a7	d3 13		. .
	ld a,04fh		;02a9	3e 4f		> O
	out (012h),a		;02ab	d3 12		. .
	ld a,00fh		;02ad	3e 0f		> .
	out (013h),a		;02af	d3 13		. .
	ld a,083h		;02b1	3e 83		> .
	out (012h),a		;02b3	d3 12		. .
	out (013h),a		;02b5	d3 13		. .
	ld a,000h		;02b7	3e 00		> .
	out (00ch),a		;02b9	d3 0c		. .
	ld a,(0d500h)		;02bb	3a 00 d5	: . .
	out (00ch),a		;02be	d3 0c		. .
	ld a,(0d501h)		;02c0	3a 01 d5	: . .
	out (00ch),a		;02c3	d3 0c		. .
	ld a,(0d502h)		;02c5	3a 02 d5	: . .
	out (00dh),a		;02c8	d3 0d		. .
	ld a,(0d503h)		;02ca	3a 03 d5	: . .
	out (00dh),a		;02cd	d3 0d		. .
	ld a,(0d504h)		;02cf	3a 04 d5	: . .
	out (00eh),a		;02d2	d3 0e		. .
	ld a,(0d505h)		;02d4	3a 05 d5	: . .
	out (00eh),a		;02d7	d3 0e		. .
	ld a,(0d506h)		;02d9	3a 06 d5	: . .
	out (00fh),a		;02dc	d3 0f		. .
	ld a,(0d507h)		;02de	3a 07 d5	: . .
	out (00fh),a		;02e1	d3 0f		. .
	ld a,008h		;02e3	3e 08		> .
	out (044h),a		;02e5	d3 44		. D
	ld a,(0d544h)		;02e7	3a 44 d5	: D .
	out (044h),a		;02ea	d3 44		. D
	ld a,(0d545h)		;02ec	3a 45 d5	: E .
	out (044h),a		;02ef	d3 44		. D
	ld a,(0d546h)		;02f1	3a 46 d5	: F .
	out (045h),a		;02f4	d3 45		. E
	ld a,(0d546h)		;02f6	3a 46 d5	: F .
	out (046h),a		;02f9	d3 46		. F
	ld a,(0d546h)		;02fb	3a 46 d5	: F .
	out (047h),a		;02fe	d3 47		. G
	ld hl,0d508h		;0300	21 08 d5	! . .
	ld b,009h		;0303	06 09		. .
	ld c,00ah		;0305	0e 0a		. .
	otir			;0307	ed b3		. .
	ld hl,0d511h		;0309	21 11 d5	! . .
	ld b,00bh		;030c	06 0b		. .
	ld c,00bh		;030e	0e 0b		. .
	otir			;0310	ed b3		. .
	in a,(00ah)		;0312	db 0a		. .
	ld (0dc03h),a		;0314	32 03 dc	2 . .
	ld a,001h		;0317	3e 01		> .
	out (00ah),a		;0319	d3 0a		. .
	in a,(00ah)		;031b	db 0a		. .
	ld (0dc04h),a		;031d	32 04 dc	2 . .
	in a,(00bh)		;0320	db 0b		. .
	ld (0dc05h),a		;0322	32 05 dc	2 . .
	ld a,001h		;0325	3e 01		> .
	out (00bh),a		;0327	d3 0b		. .
	in a,(00bh)		;0329	db 0b		. .
	ld (0dc06h),a		;032b	32 06 dc	2 . .
	ld a,020h		;032e	3e 20		>  
	out (0f8h),a		;0330	d3 f8		. .
	ld a,(0d51ch)		;0332	3a 1c d5	: . .
	out (0fbh),a		;0335	d3 fb		. .
	ld a,(0d51eh)		;0337	3a 1e d5	: . .
	out (0fbh),a		;033a	d3 fb		. .
	ld a,(0d51fh)		;033c	3a 1f d5	: . .
	out (0fbh),a		;033f	d3 fb		. .
	in a,(014h)		;0341	db 14		. .
	and 080h		;0343	e6 80		. .
	jp z,0d7f2h		;0345	ca f2 d7	. . .
	ld hl,0d52fh		;0348	21 2f d5	! / .
	ld a,(hl)		;034b	7e		~
	cp 008h			;034c	fe 08		. .
	jp nz,0d7d3h		;034e	c2 d3 d7	. . .
	ld (hl),010h		;0351	36 10		6 .
	inc hl			;0353	23		#
	ld a,(hl)		;0354	7e		~
	cp 008h			;0355	fe 08		. .
	jp nz,0d7dch		;0357	c2 dc d7	. . .
	ld (hl),010h		;035a	36 10		6 .
	ld a,(0da36h)		;035c	3a 36 da	: 6 .
	cp 003h			;035f	fe 03		. .
	jr z,l036ah		;0361	28 07		( .
	ld a,00fh		;0363	3e 0f		> .
	ld (0d526h),a		;0365	32 26 d5	2 & .
	jr l0372h		;0368	18 08		. .
l036ah:
	ld a,018h		;036a	3e 18		> .
	ld (0d52fh),a		;036c	32 2f d5	2 / .
	ld (0d530h),a		;036f	32 30 d5	2 0 .
l0372h:
	in a,(004h)		;0372	db 04		. .
	and 01fh		;0374	e6 1f		. .
	jp nz,0d7f2h		;0376	c2 f2 d7	. . .
	ld hl,0d524h		;0379	21 24 d5	! $ .
	ld b,(hl)		;037c	46		F
	inc hl			;037d	23		#
	in a,(004h)		;037e	db 04		. .
	and 0c0h		;0380	e6 c0		. .
l0382h:
	cp 080h			;0382	fe 80		. .
	jp nz,0d7feh		;0384	c2 fe d7	. . .
	ld a,(hl)		;0387	7e		~
	out (005h),a		;0388	d3 05		. .
	dec b			;038a	05		.
	jp nz,0d7fdh		;038b	c2 fd d7	. . .
	ld hl,0f800h		;038e	21 00 f8	! . .
	ld de,0f801h		;0391	11 01 f8	. . .
	ld bc,007cfh		;0394	01 cf 07	. . .
	ld (hl),020h		;0397	36 20		6  
	ldir			;0399	ed b0		. .
	ld hl,0f500h		;039b	21 00 f5	! . .
	ld de,0f501h		;039e	11 01 f5	. . .
	ld bc,000fah		;03a1	01 fa 00	. . .
	ld (hl),000h		;03a4	36 00		6 .
	ldir			;03a6	ed b0		. .
	ld hl,0ffd1h		;03a8	21 d1 ff	! . .
	ld de,0ffd2h		;03ab	11 d2 ff	. . .
	ld (hl),000h		;03ae	36 00		6 .
	ld bc,l002eh		;03b0	01 2e 00	. . .
	ldir			;03b3	ed b0		. .
	ld a,000h		;03b5	3e 00		> .
	out (001h),a		;03b7	d3 01		. .
	ld a,(0d520h)		;03b9	3a 20 d5	:   .
	out (000h),a		;03bc	d3 00		. .
	ld a,(0d521h)		;03be	3a 21 d5	: ! .
	out (000h),a		;03c1	d3 00		. .
	ld a,(0d522h)		;03c3	3a 22 d5	: " .
	out (000h),a		;03c6	d3 00		. .
	ld a,(0d523h)		;03c8	3a 23 d5	: # .
	out (000h),a		;03cb	d3 00		. .
	ld a,080h		;03cd	3e 80		> .
	out (001h),a		;03cf	d3 01		. .
	ld a,000h		;03d1	3e 00		> .
	out (000h),a		;03d3	d3 00		. .
	out (000h),a		;03d5	d3 00		. .
	ld a,0e0h		;03d7	3e e0		> .
	out (001h),a		;03d9	d3 01		. .
	ld a,023h		;03db	3e 23		> #
	out (001h),a		;03dd	d3 01		. .
	ld de,0ee80h		;03df	11 80 ee	. . .
	ld hl,0f500h		;03e2	21 00 f5	! . .
	and a			;03e5	a7		.
	sbc hl,de		;03e6	ed 52		. R
	ld c,l			;03e8	4d		M
	ld b,h			;03e9	44		D
	ld hl,0ee81h		;03ea	21 81 ee	! . .
	ex de,hl		;03ed	eb		.
	ld (hl),000h		;03ee	36 00		6 .
	ldir			;03f0	ed b0		. .
	ld a,(0d50eh)		;03f2	3a 0e d5	: . .
	and 060h		;03f5	e6 60		. `
	ld (0da34h),a		;03f7	32 34 da	2 4 .
	ld a,(0d519h)		;03fa	3a 19 d5	: . .
	and 060h		;03fd	e6 60		. `
	ld (0da35h),a		;03ff	32 35 da	2 5 .
	ld a,(0d52ch)		;0402	3a 2c d5	: , .
	ld (0da33h),a		;0405	32 33 da	2 3 .
	ld hl,(0d52dh)		;0408	2a 2d d5	* - .
	ld (0ffe7h),hl		;040b	22 e7 ff	" . .
	ld a,0ffh		;040e	3e ff		> .
	ld (0f34fh),a		;0410	32 4f f3	2 O .
	call 0d8bfh		;0413	cd bf d8	. . .
	ld a,0ffh		;0416	3e ff		> .
	ld (0d531h),a		;0418	32 31 d5	2 1 .
	xor a			;041b	af		.
	ld (0da47h),a		;041c	32 47 da	2 G .
	call 0d8bfh		;041f	cd bf d8	. . .
	ld hl,0eb1dh		;0422	21 1d eb	! . .
	ld (0d8bdh),hl		;0425	22 bd d8	" . .
	ld hl,0da39h		;0428	21 39 da	! 9 .
	push hl			;042b	e5		.
l042ch:
	pop hl			;042c	e1		.
sub_042dh:
	push hl			;042d	e5		.
	call 0d8eah		;042e	cd ea d8	. . .
	pop hl			;0431	e1		.
	inc hl			;0432	23		#
	push hl			;0433	e5		.
	ld a,(hl)		;0434	7e		~
	cp 0ffh			;0435	fe ff		. .
	jr nz,l042ch		;0437	20 f3		  .
	pop hl			;0439	e1		.
	jp 0da00h		;043a	c3 00 da	. . .
	nop			;043d	00		.
	nop			;043e	00		.
	ld c,000h		;043f	0e 00		. .
	ld hl,0d52fh		;0441	21 2f d5	! / .
	ld de,0da37h		;0444	11 37 da	. 7 .
	ld a,(hl)		;0447	7e		~
	cp 0ffh			;0448	fe ff		. .
	jp z,0d8d4h		;044a	ca d4 d8	. . .
	ld (de),a		;044d	12		.
	inc c			;044e	0c		.
	inc de			;044f	13		.
	inc hl			;0450	23		#
	jp 0d8c7h		;0451	c3 c7 d8	. . .
	ld a,c			;0454	79		y
	dec a			;0455	3d		=
	ld (0f334h),a		;0456	32 34 f3	2 4 .
	ld a,002h		;0459	3e 02		> .
	ld (0f335h),a		;045b	32 35 f3	2 5 .
	ld hl,0d541h		;045e	21 41 d5	! A .
	ld de,0f336h		;0461	11 36 f3	. 6 .
	ld bc,l0003h		;0464	01 03 00	. . .
	ldir			;0467	ed b0		. .
	ret			;0469	c9		.
	ld de,l000fh		;046a	11 0f 00	. . .
	ld b,008h		;046d	06 08		. .
	ld a,(hl)		;046f	7e		~
	and 0f8h		;0470	e6 f8		. .
	ld hl,0e984h		;0472	21 84 e9	! . .
	or a			;0475	b7		.
	jr z,l047ch		;0476	28 04		( .
l0478h:
	add hl,de		;0478	19		.
	sub b			;0479	90		.
	jr nz,l0478h		;047a	20 fc		  .
l047ch:
	ld de,(0d8bdh)		;047c	ed 5b bd d8	. [ . .
	ex de,hl		;0480	eb		.
	ld (hl),e		;0481	73		s
	inc hl			;0482	23		#
	ld (hl),d		;0483	72		r
	ld de,l000fh		;0484	11 0f 00	. . .
l0487h:
	add hl,de		;0487	19		.
	ld (0d8bdh),hl		;0488	22 bd d8	" . .
	ret			;048b	c9		.
	xor a			;048c	af		.
	ld (03839h),a		;048d	32 39 38	2 9 8
	ld a,d			;0490	7a		z
	or a			;0491	b7		.
	jp nz,l0487h		;0492	c2 87 04	. . .
	ld a,(03940h)		;0495	3a 40 39	: @ 9
	cp 020h			;0498	fe 20		.  
	ret nz			;049a	c0		.
	ld a,e			;049b	7b		{
	dec a			;049c	3d		=
	ret m			;049d	f8		.
	jp z,l0487h		;049e	ca 87 04	. . .
	cp 010h			;04a1	fe 10		. .
	jp nc,l0487h		;04a3	d2 87 04	. . .
	inc a			;04a6	3c		<
	ld (03838h),a		;04a7	32 38 38	2 8 8
	xor a			;04aa	af		.
l04abh:
	ld h,a			;04ab	67		g
	ld l,e			;04ac	6b		k
	jp 0197fh		;04ad	c3 7f 19	. . .
	call 025dch		;04b0	cd dc 25	. . %
	ld a,d			;04b3	7a		z
	or a			;04b4	b7		.
	jp nz,l0487h		;04b5	c2 87 04	. . .
	ld a,(03833h)		;04b8	3a 33 38	: 3 8
	or a			;04bb	b7		.
	ret z			;04bc	c8		.
	ld a,e			;04bd	7b		{
	or a			;04be	b7		.
	jp z,0285dh		;04bf	ca 5d 28	. ] (
	cp 00ah			;04c2	fe 0a		. .
	call c,l0487h		;04c4	dc 87 04	. . .
	ld a,(03940h)		;04c7	3a 40 39	: @ 9
	cp 020h			;04ca	fe 20		.  
	jp nz,0285dh		;04cc	c2 5d 28	. ] (
	ld a,e			;04cf	7b		{
	ld (03877h),a		;04d0	32 77 38	2 w 8
	call 01794h		;04d3	cd 94 17	. . .
	call sub_042dh		;04d6	cd 2d 04	. - .
	jp 018bbh		;04d9	c3 bb 18	. . .
	call 00b1bh		;04dc	cd 1b 0b	. . .
	jp nz,l0487h		;04df	c2 87 04	. . .
	push af			;04e2	f5		.
	ld a,(0392ch)		;04e3	3a 2c 39	: , 9
	cp 008h			;04e6	fe 08		. .
	jp c,0287ah		;04e8	da 7a 28	. z (
	call 004b7h		;04eb	cd b7 04	. . .
	ld a,007h		;04ee	3e 07		> .
	ld hl,03927h		;04f0	21 27 39	! ' 9
	ld (hl),a		;04f3	77		w
	ld a,(03833h)		;04f4	3a 33 38	: 3 8
	or a			;04f7	b7		.
	ld (03884h),hl		;04f8	22 84 38	" . 8
	ld c,003h		;04fb	0e 03		. .
	call nz,019f2h		;04fd	c4 f2 19	. . .
	pop af			;0500	f1		.
	cp 02ch			;0501	fe 2c		. ,
	jp z,02866h		;0503	ca 66 28	. f (
	ret			;0506	c9		.
	ld a,(03871h)		;0507	3a 71 38	: q 8
	or a			;050a	b7		.
	jp nz,l04abh		;050b	c2 ab 04	. . .
	call 00b8eh		;050e	cd 8e 0b	. . .
	ld hl,(0388bh)		;0511	2a 8b 38	* . 8
	dec hl			;0514	2b		+
	call 0486eh		;0515	cd 6e 48	. n H
	or a			;0518	b7		.
	jp z,028ach		;0519	ca ac 28	. . (
	call 04931h		;051c	cd 31 49	. 1 I
	jp 004c9h		;051f	c3 c9 04	. . .
	dec a			;0522	3d		=
	ld (03871h),a		;0523	32 71 38	2 q 8
	ld hl,(0388bh)		;0526	2a 8b 38	* . 8
	ld a,(hl)		;0529	7e		~
	inc hl			;052a	23		#
	ld (0388bh),hl		;052b	22 8b 38	" . 8
	cp 021h			;052e	fe 21		. !
	jp nc,028b0h		;0530	d2 b0 28	. . (
	ret			;0533	c9		.
	call 00b8eh		;0534	cd 8e 0b	. . .
	cp 028h			;0537	fe 28		. (
	jp nz,l0487h		;0539	c2 87 04	. . .
	call 00aefh		;053c	cd ef 0a	. . .
	cp 027h			;053f	fe 27		. '
	jp nz,l0487h		;0541	c2 87 04	. . .
	call 00b1bh		;0544	cd 1b 0b	. . .
	jp nz,l0487h		;0547	c2 87 04	. . .
	cp 027h			;054a	fe 27		. '
	jp nz,l0487h		;054c	c2 87 04	. . .
	call 00aefh		;054f	cd ef 0a	. . .
	cp 029h			;0552	fe 29		. )
	jp nz,l0487h		;0554	c2 87 04	. . .
	call 00b06h		;0557	cd 06 0b	. . .
	ld a,(03833h)		;055a	3a 33 38	: 3 8
	or a			;055d	b7		.
	ret nz			;055e	c0		.
	ld a,(0392ch)		;055f	3a 2c 39	: , 9
	cp 006h			;0562	fe 06		. .
	jp c,028f3h		;0564	da f3 28	. . (
	ld a,006h		;0567	3e 06		> .
	ld de,0392dh		;0569	11 2d 39	. - 9
	ld hl,03a02h		;056c	21 02 3a	! . :
	ld b,a			;056f	47		G
	ld a,(hl)		;0570	7e		~
	or a			;0571	b7		.
	jp nz,0049fh		;0572	c2 9f 04	. . .
l0575h:
	ld a,(de)		;0575	1a		.
	ld (hl),a		;0576	77		w
	inc hl			;0577	23		#
	inc de			;0578	13		.
	dec b			;0579	05		.
	jp nz,028ffh		;057a	c2 ff 28	. . (
	ld (hl),b		;057d	70		p
	ret			;057e	c9		.
	call 03dc3h		;057f	cd c3 3d	. . =
	in a,(0c3h)		;0582	db c3		. .
	add a,(hl)		;0584	86		.
	in a,(0c3h)		;0585	db c3		. .
	jr z,l0575h		;0587	28 ec		( .
	jp 0ec2ch		;0589	c3 2c ec	. , .
	jp 0e183h		;058c	c3 83 e1	. . .
	jp 0dc0bh		;058f	c3 0b dc	. . .
	jp 0dc5eh		;0592	c3 5e dc	. ^ .
	jp 0dc4eh		;0595	c3 4e dc	. N .
	jp 0e5d2h		;0598	c3 d2 e5	. . .
	jp 0e247h		;059b	c3 47 e2	. G .
	jp 0e2f0h		;059e	c3 f0 e2	. . .
	jp 0e2f6h		;05a1	c3 f6 e2	. . .
	jp 0e2fch		;05a4	c3 fc e2	. . .
	jp 0e305h		;05a7	c3 05 e3	. . .
	jp 0e319h		;05aa	c3 19 e3	. . .
	jp 0dc07h		;05ad	c3 07 dc	. . .
	jp 0e302h		;05b0	c3 02 e3	. . .
	nop			;05b3	00		.
	nop			;05b4	00		.
	nop			;05b5	00		.
	nop			;05b6	00		.
	rst 38h			;05b7	ff		.
	rst 38h			;05b8	ff		.
	rst 38h			;05b9	ff		.
	rst 38h			;05ba	ff		.
	rst 38h			;05bb	ff		.
	rst 38h			;05bc	ff		.
	rst 38h			;05bd	ff		.
	rst 38h			;05be	ff		.
	rst 38h			;05bf	ff		.
	rst 38h			;05c0	ff		.
	rst 38h			;05c1	ff		.
	rst 38h			;05c2	ff		.
	rst 38h			;05c3	ff		.
	rst 38h			;05c4	ff		.
	rst 38h			;05c5	ff		.
	rst 38h			;05c6	ff		.
	nop			;05c7	00		.
	or a			;05c8	b7		.
	ret z			;05c9	c8		.
	jp 0e6bfh		;05ca	c3 bf e6	. . .
	jp 0dc4ah		;05cd	c3 4a dc	. J .
	jp 0dadfh		;05d0	c3 df da	. . .
	jp 0dabch		;05d3	c3 bc da	. . .
	jp 0dac9h		;05d6	c3 c9 da	. . .
	jp 0e8ceh		;05d9	c3 ce e8	. . .
	inc hl			;05dc	23		#
	ld a,(hl)		;05dd	7e		~
	and 064h		;05de	e6 64		. d
	jp nz,02980h		;05e0	c2 80 29	. . )
	ld a,(hl)		;05e3	7e		~
	and 003h		;05e4	e6 03		. .
	or 080h			;05e6	f6 80		. .
	ld (hl),a		;05e8	77		w
	pop af			;05e9	f1		.
	cp 02ch			;05ea	fe 2c		. ,
	jp z,02958h		;05ec	ca 58 29	. X )
	nop			;05ef	00		.
	nop			;05f0	00		.
	dec c			;05f1	0d		.
	ld a,(bc)		;05f2	0a		.
	rlca			;05f3	07		.
	ld b,h			;05f4	44		D
	ld l,c			;05f5	69		i
	ld (hl),e		;05f6	73		s
	ld l,e			;05f7	6b		k
	jr nz,l066ch		;05f8	20 72		  r
	ld h,l			;05fa	65		e
	ld h,c			;05fb	61		a
	ld h,h			;05fc	64		d
	jr nz,$+103		;05fd	20 65		  e
	ld (hl),d		;05ff	72		r
	ld (hl),d		;0600	72		r
	ld l,a			;0601	6f		o
	ld (hl),d		;0602	72		r
	jr nz,$+47		;0603	20 2d		  -
	jr nz,l0679h		;0605	20 72		  r
	ld h,l			;0607	65		e
	ld (hl),e		;0608	73		s
	ld h,l			;0609	65		e
	ld (hl),h		;060a	74		t
	dec c			;060b	0d		.
	ld a,(bc)		;060c	0a		.
	nop			;060d	00		.
	inc c			;060e	0c		.
	ld c,h			;060f	4c		L
	ld l,a			;0610	6f		o
	ld h,c			;0611	61		a
	ld h,h			;0612	64		d
	ld l,c			;0613	69		i
	ld l,(hl)		;0614	6e		n
	ld h,a			;0615	67		g
	jr nz,$+118		;0616	20 74		  t
	ld h,l			;0618	65		e
	ld (hl),e		;0619	73		s
	ld (hl),h		;061a	74		t
	jr nz,$+114		;061b	20 70		  p
	ld (hl),d		;061d	72		r
	ld l,a			;061e	6f		o
	ld h,a			;061f	67		g
	ld (hl),d		;0620	72		r
	ld h,c			;0621	61		a
	ld l,l			;0622	6d		m
	dec c			;0623	0d		.
	ld a,(bc)		;0624	0a		.
	nop			;0625	00		.
	ld a,(hl)		;0626	7e		~
	or a			;0627	b7		.
	ret z			;0628	c8		.
	push hl			;0629	e5		.
	ld c,a			;062a	4f		O
	call 0e183h		;062b	cd 83 e1	. . .
	pop hl			;062e	e1		.
	inc hl			;062f	23		#
	jp 0daa6h		;0630	c3 a6 da	. . .
	ld hl,0da71h		;0633	21 71 da	! q .
	call 0daa6h		;0636	cd a6 da	. . .
	jp 0dab9h		;0639	c3 b9 da	. . .
	ld a,0c3h		;063c	3e c3		> .
	ld (0ffe5h),a		;063e	32 e5 ff	2 . .
	ld (0ffe6h),hl		;0641	22 e6 ff	" . .
	ex de,hl		;0644	eb		.
	ld (0ffdfh),hl		;0645	22 df ff	" . .
	ret			;0648	c9		.
	di			;0649	f3		.
	or a			;064a	b7		.
	jp z,0dad7h		;064b	ca d7 da	. . .
	ld de,(0fffch)		;064e	ed 5b fc ff	. [ . .
	ld hl,(0fffeh)		;0652	2a fe ff	* . .
	ei			;0655	fb		.
	ret			;0656	c9		.
	ld (0fffch),de		;0657	ed 53 fc ff	. S . .
	ld (0fffeh),hl		;065b	22 fe ff	" . .
	ret			;065e	c9		.
	add a,00ah		;065f	c6 0a		. .
	ld c,a			;0661	4f		O
l0662h:
	di			;0662	f3		.
	ld a,001h		;0663	3e 01		> .
	out (c),a		;0665	ed 79		. y
	in a,(c)		;0667	ed 78		. x
	ei			;0669	fb		.
	and 001h		;066a	e6 01		. .
l066ch:
	jr z,l0662h		;066c	28 f4		( .
	ld d,005h		;066e	16 05		. .
	ld a,000h		;0670	3e 00		> .
	call 0db1ch		;0672	cd 1c db	. . .
	dec b			;0675	05		.
	ret m			;0676	f8		.
	sla b			;0677	cb 20		.  
l0679h:
	or b			;0679	b0		.
	call 0db1ch		;067a	cd 1c db	. . .
	or 080h			;067d	f6 80		. .
	call 0db1ch		;067f	cd 1c db	. . .
	ld hl,l0002h		;0682	21 02 00	! . .
	call 0e5c6h		;0685	cd c6 e5	. . .
	ld a,c			;0688	79		y
	cp 00ah			;0689	fe 0a		. .
	ld a,(0dc03h)		;068b	3a 03 dc	: . .
	jp z,0db14h		;068e	ca 14 db	. . .
	ld a,(0dc05h)		;0691	3a 05 dc	: . .
	and 020h		;0694	e6 20		.  
	jp z,0db1ch		;0696	ca 1c db	. . .
	ld a,0ffh		;0699	3e ff		> .
	ret			;069b	c9		.
	di			;069c	f3		.
	out (c),d		;069d	ed 51		. Q
	out (c),a		;069f	ed 79		. y
	ei			;06a1	fb		.
	ret			;06a2	c9		.
	xor a			;06a3	af		.
	ld (0d84ch),a		;06a4	32 4c d8	2 L .
	ld hl,(0d89ah)		;06a7	2a 9a d8	* . .
	ld (0da6fh),hl		;06aa	22 6f da	" o .
	ld hl,0db34h		;06ad	21 34 db	! 4 .
	ld (0d89ah),hl		;06b0	22 9a d8	" . .
	ret			;06b3	c9		.
	push hl			;06b4	e5		.
	ld hl,(0da6fh)		;06b5	2a 6f da	* o .
	ld (0d89ah),hl		;06b8	22 9a d8	" . .
	pop hl			;06bb	e1		.
	ret			;06bc	c9		.
	ld sp,0f384h		;06bd	31 84 f3	1 . .
	ld hl,0da8eh		;06c0	21 8e da	! . .
	call 0daa6h		;06c3	cd a6 da	. . .
	xor a			;06c6	af		.
	ld (l0004h),a		;06c7	32 04 00	2 . .
	ld (0f350h),a		;06ca	32 50 f3	2 P .
	ld a,(0da47h)		;06cd	3a 47 da	: G .
	or a			;06d0	b7		.
	jp z,0db59h		;06d1	ca 59 db	. Y .
	ld a,002h		;06d4	3e 02		> .
	ld (l0004h),a		;06d6	32 04 00	2 . .
	xor a			;06d9	af		.
	ld (0f321h),a		;06da	32 21 f3	2 ! .
	ld (0f32ah),a		;06dd	32 2a f3	2 * .
	ld (0f322h),a		;06e0	32 22 f3	2 " .
	in a,(014h)		;06e3	db 14		. .
	and 080h		;06e5	e6 80		. .
	jp z,0db86h		;06e7	ca 86 db	. . .
	ld a,(0f334h)		;06ea	3a 34 f3	: 4 .
	cp 002h			;06ed	fe 02		. .
	jp nc,0db83h		;06ef	d2 83 db	. . .
	ld c,001h		;06f2	0e 01		. .
	call 0e247h		;06f4	cd 47 e2	. G .
	call 0e5d2h		;06f7	cd d2 e5	. . .
	ld a,b			;06fa	78		x
	and 010h		;06fb	e6 10		. .
	ld a,000h		;06fd	3e 00		> .
	jp nz,0db83h		;06ff	c2 83 db	. . .
	inc a			;0702	3c		<
	ld (0f334h),a		;0703	32 34 f3	2 4 .
	ei			;0706	fb		.
	ld c,000h		;0707	0e 00		. .
	ld a,(0da47h)		;0709	3a 47 da	: G .
	or a			;070c	b7		.
	jr z,l0712h		;070d	28 03		( .
	ld a,002h		;070f	3e 02		> .
	ld c,a			;0711	4f		O
l0712h:
	call 0e247h		;0712	cd 47 e2	. G .
	xor a			;0715	af		.
	ld (0f323h),a		;0716	32 23 f3	2 # .
	ld (l0003h),a		;0719	32 03 00	2 . .
	ld (0f339h),a		;071c	32 39 f3	2 9 .
	ld (0ec26h),a		;071f	32 26 ec	2 & .
	call 0e5d2h		;0722	cd d2 e5	. . .
	ld sp,0f384h		;0725	31 84 f3	1 . .
	ld bc,l0000h		;0728	01 00 00	. . .
	call 0e2fch		;072b	cd fc e2	. . .
	ld hl,000f0h		;072e	21 f0 00	! . .
	ld (0f370h),hl		;0731	22 70 f3	" p .
	ld bc,l0001h		;0734	01 01 00	. . .
	call 0e2f0h		;0737	cd f0 e2	. . .
	ld bc,l0000h		;073a	01 00 00	. . .
	call 0e2f6h		;073d	cd f6 e2	. . .
l0740h:
	push bc			;0740	c5		.
	call 0e305h		;0741	cd 05 e3	. . .
	or a			;0744	b7		.
	jp nz,0dab3h		;0745	c2 b3 da	. . .
	ld hl,(0f370h)		;0748	2a 70 f3	* p .
	dec hl			;074b	2b		+
	ld (0f370h),hl		;074c	22 70 f3	" p .
	ld a,h			;074f	7c		|
	or l			;0750	b5		.
	jr z,l077bh		;0751	28 28		( (
	ld hl,(0f32eh)		;0753	2a 2e f3	* . .
	ld de,l0080h		;0756	11 80 00	. . .
	add hl,de		;0759	19		.
	ld b,h			;075a	44		D
	ld c,l			;075b	4d		M
	call 0e2fch		;075c	cd fc e2	. . .
	pop bc			;075f	c1		.
	inc bc			;0760	03		.
	call 0e2f6h		;0761	cd f6 e2	. . .
	ld hl,(0f354h)		;0764	2a 54 f3	* T .
	or a			;0767	b7		.
	sbc hl,bc		;0768	ed 42		. B
	jr nz,l0740h		;076a	20 d4		  .
	ld hl,(0f313h)		;076c	2a 13 f3	* . .
	inc hl			;076f	23		#
	ld (0f313h),hl		;0770	22 13 f3	" . .
	ld bc,l0000h		;0773	01 00 00	. . .
	call 0e2f6h		;0776	cd f6 e2	. . .
	jr l0740h		;0779	18 c5		. .
l077bh:
	jp l0000h		;077b	c3 00 00	. . .
	rst 38h			;077e	ff		.
	rst 38h			;077f	ff		.
	rst 38h			;0780	ff		.
	nop			;0781	00		.
	nop			;0782	00		.
	nop			;0783	00		.
	nop			;0784	00		.
	nop			;0785	00		.
	nop			;0786	00		.
	ld a,(0dbfeh)		;0787	3a fe db	: . .
	ret			;078a	c9		.
	ld a,(0dbfeh)		;078b	3a fe db	: . .
	or a			;078e	b7		.
	jp z,0dc0bh		;078f	ca 0b dc	. . .
	di			;0792	f3		.
	ld a,000h		;0793	3e 00		> .
	ld (0dbfeh),a		;0795	32 fe db	2 . .
	ld a,005h		;0798	3e 05		> .
	out (00bh),a		;079a	d3 0b		. .
	ld a,(0da35h)		;079c	3a 35 da	: 5 .
	add a,08ah		;079f	c6 8a		. .
	out (00bh),a		;07a1	d3 0b		. .
	ld a,001h		;07a3	3e 01		> .
	out (00bh),a		;07a5	d3 0b		. .
	ld a,007h		;07a7	3e 07		> .
	out (00bh),a		;07a9	d3 0b		. .
	ld a,c			;07ab	79		y
	out (009h),a		;07ac	d3 09		. .
	ei			;07ae	fb		.
	ret			;07af	c9		.
	di			;07b0	f3		.
	xor a			;07b1	af		.
	ld (0dbffh),a		;07b2	32 ff db	2 . .
	ld a,005h		;07b5	3e 05		> .
	out (00ah),a		;07b7	d3 0a		. .
	ld a,(0da34h)		;07b9	3a 34 da	: 4 .
	add a,08ah		;07bc	c6 8a		. .
	out (00ah),a		;07be	d3 0a		. .
	ld a,001h		;07c0	3e 01		> .
	out (00ah),a		;07c2	d3 0a		. .
	ld a,01bh		;07c4	3e 1b		> .
	out (00ah),a		;07c6	d3 0a		. .
	ei			;07c8	fb		.
	ret			;07c9	c9		.
	ld a,(0dbffh)		;07ca	3a ff db	: . .
	ret			;07cd	c9		.
	call 0dc4ah		;07ce	cd 4a dc	. J .
	or a			;07d1	b7		.
	jp z,0dc4eh		;07d2	ca 4e dc	. N .
	ld a,(0dc01h)		;07d5	3a 01 dc	: . .
	push af			;07d8	f5		.
	call 0dc30h		;07d9	cd 30 dc	. 0 .
	pop af			;07dc	f1		.
	ret			;07dd	c9		.
	ld a,(0dc00h)		;07de	3a 00 dc	: . .
	or a			;07e1	b7		.
	jp z,0dc5eh		;07e2	ca 5e dc	. ^ .
	di			;07e5	f3		.
	ld a,000h		;07e6	3e 00		> .
	ld (0dc00h),a		;07e8	32 00 dc	2 . .
	ld a,005h		;07eb	3e 05		> .
	out (00ah),a		;07ed	d3 0a		. .
	ld a,(0da34h)		;07ef	3a 34 da	: 4 .
	add a,08ah		;07f2	c6 8a		. .
	out (00ah),a		;07f4	d3 0a		. .
	ld a,001h		;07f6	3e 01		> .
	out (00ah),a		;07f8	d3 0a		. .
	ld a,01bh		;07fa	3e 1b		> .
	out (00ah),a		;07fc	d3 0a		. .
	ld a,c			;07fe	79		y
	defb 0d3h		;07ff	d3		.
