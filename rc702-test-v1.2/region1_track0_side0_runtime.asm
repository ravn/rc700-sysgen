; z80dasm 1.2.0
; command line: z80dasm -a -l -t -g 0xD480 -o region1_track0_side0_runtime.asm region1_track0_side0.bin

	org 0d480h

ld480h:
	add a,b			;d480	80		.
	ld (bc),a		;d481	02		.
	nop			;d482	00		.
	nop			;d483	00		.
	nop			;d484	00		.
	nop			;d485	00		.
	nop			;d486	00		.
	nop			;d487	00		.
	jr nz,ld4dch		;d488	20 52		  R
	ld b,e			;d48a	43		C
	scf			;d48b	37		7
	jr nc,ld4c0h		;d48c	30 32		0 2
	nop			;d48e	00		.
	nop			;d48f	00		.
	nop			;d490	00		.
	nop			;d491	00		.
	nop			;d492	00		.
	nop			;d493	00		.
	nop			;d494	00		.
	nop			;d495	00		.
	nop			;d496	00		.
	nop			;d497	00		.
	nop			;d498	00		.
	nop			;d499	00		.
	nop			;d49a	00		.
	nop			;d49b	00		.
	nop			;d49c	00		.
	nop			;d49d	00		.
	nop			;d49e	00		.
	nop			;d49f	00		.
	nop			;d4a0	00		.
	nop			;d4a1	00		.
	nop			;d4a2	00		.
	nop			;d4a3	00		.
	nop			;d4a4	00		.
	nop			;d4a5	00		.
	nop			;d4a6	00		.
	nop			;d4a7	00		.
	nop			;d4a8	00		.
	nop			;d4a9	00		.
	nop			;d4aa	00		.
	nop			;d4ab	00		.
	nop			;d4ac	00		.
	nop			;d4ad	00		.
	nop			;d4ae	00		.
	nop			;d4af	00		.
	nop			;d4b0	00		.
	nop			;d4b1	00		.
	nop			;d4b2	00		.
	nop			;d4b3	00		.
	nop			;d4b4	00		.
	nop			;d4b5	00		.
	nop			;d4b6	00		.
	nop			;d4b7	00		.
	nop			;d4b8	00		.
	nop			;d4b9	00		.
	nop			;d4ba	00		.
	nop			;d4bb	00		.
	nop			;d4bc	00		.
	nop			;d4bd	00		.
	nop			;d4be	00		.
	nop			;d4bf	00		.
ld4c0h:
	nop			;d4c0	00		.
	nop			;d4c1	00		.
	nop			;d4c2	00		.
	nop			;d4c3	00		.
	nop			;d4c4	00		.
	nop			;d4c5	00		.
	nop			;d4c6	00		.
	nop			;d4c7	00		.
	nop			;d4c8	00		.
	nop			;d4c9	00		.
	nop			;d4ca	00		.
	nop			;d4cb	00		.
	nop			;d4cc	00		.
	nop			;d4cd	00		.
	nop			;d4ce	00		.
	nop			;d4cf	00		.
	nop			;d4d0	00		.
	nop			;d4d1	00		.
	nop			;d4d2	00		.
	nop			;d4d3	00		.
	nop			;d4d4	00		.
	nop			;d4d5	00		.
	nop			;d4d6	00		.
	nop			;d4d7	00		.
	nop			;d4d8	00		.
	nop			;d4d9	00		.
	nop			;d4da	00		.
	nop			;d4db	00		.
ld4dch:
	nop			;d4dc	00		.
	nop			;d4dd	00		.
	nop			;d4de	00		.
	nop			;d4df	00		.
	nop			;d4e0	00		.
	nop			;d4e1	00		.
	nop			;d4e2	00		.
	nop			;d4e3	00		.
	nop			;d4e4	00		.
	nop			;d4e5	00		.
	nop			;d4e6	00		.
	nop			;d4e7	00		.
	nop			;d4e8	00		.
	nop			;d4e9	00		.
	nop			;d4ea	00		.
	nop			;d4eb	00		.
	nop			;d4ec	00		.
	nop			;d4ed	00		.
	nop			;d4ee	00		.
	nop			;d4ef	00		.
	nop			;d4f0	00		.
	nop			;d4f1	00		.
	nop			;d4f2	00		.
	nop			;d4f3	00		.
	nop			;d4f4	00		.
	nop			;d4f5	00		.
	call nz,019cch		;d4f6	c4 cc 19	. . .
	ex de,hl		;d4f9	eb		.
	ld (03917h),hl		;d4fa	22 17 39	" . 9
	ex de,hl		;d4fd	eb		.
	ld c,00bh		;d4fe	0e 0b		. .
ld500h:
	ld b,a			;d500	47		G
ld501h:
	jr nz,$+73		;d501	20 47		  G
ld503h:
	jr nz,ld4dch		;d503	20 d7		  .
ld505h:
	ld bc,001d7h		;d505	01 d7 01	. . .
ld508h:
	jr ld50eh		;d508	18 04		. .
	ld b,a			;d50a	47		G
	inc bc			;d50b	03		.
	ld h,c			;d50c	61		a
	dec b			;d50d	05		.
ld50eh:
	jr nz,ld511h		;d50e	20 01		  .
	dec de			;d510	1b		.
ld511h:
	jr ld515h		;d511	18 02		. .
	djnz ld519h		;d513	10 04		. .
ld515h:
	ld b,a			;d515	47		G
	inc bc			;d516	03		.
	ld h,b			;d517	60		`
	dec b			;d518	05		.
ld519h:
	jr nz,ld51ch		;d519	20 01		  .
	rra			;d51b	1f		.
ld51ch:
	ld c,b			;d51c	48		H
	ld c,c			;d51d	49		I
ld51eh:
	ld c,d			;d51e	4a		J
ld51fh:
	ld c,e			;d51f	4b		K
ld520h:
	ld c,a			;d520	4f		O
ld521h:
	sbc a,b			;d521	98		.
ld522h:
	ld a,d			;d522	7a		z
ld523h:
	ld c,l			;d523	4d		M
ld524h:
	inc bc			;d524	03		.
	inc bc			;d525	03		.
ld526h:
	rst 18h			;d526	df		.
	jr z,ld529h		;d527	28 00		( .
ld529h:
	inc b			;d529	04		.
	ld b,006h		;d52a	06 06		. .
ld52ch:
	nop			;d52c	00		.
ld52dh:
	jp m,00800h		;d52d	fa 00 08	. . .
ld530h:
	ex af,af'		;d530	08		.
ld531h:
	jr nz,$+1		;d531	20 ff		  .
	rst 38h			;d533	ff		.
	rst 38h			;d534	ff		.
	rst 38h			;d535	ff		.
	rst 38h			;d536	ff		.
	rst 38h			;d537	ff		.
	rst 38h			;d538	ff		.
	rst 38h			;d539	ff		.
	rst 38h			;d53a	ff		.
	rst 38h			;d53b	ff		.
	rst 38h			;d53c	ff		.
	rst 38h			;d53d	ff		.
	rst 38h			;d53e	ff		.
	rst 38h			;d53f	ff		.
	ld (bc),a		;d540	02		.
ld541h:
	ld (bc),a		;d541	02		.
	nop			;d542	00		.
	nop			;d543	00		.
ld544h:
	rst 10h			;d544	d7		.
ld545h:
	ld bc,00103h		;d545	01 03 01	. . .
	ld a,(03247h)		;d548	3a 47 32	: G 2
	ld d,039h		;d54b	16 39		. 9
	ld hl,(0391bh)		;d54d	2a 1b 39	* . 9
	jp 023f5h		;d550	c3 f5 23	. . #
	call 02472h		;d553	cd 72 24	. r $
	call 0197ch		;d556	cd 7c 19	. | .
	ld a,002h		;d559	3e 02		> .
	ld (03a01h),a		;d55b	32 01 3a	2 . :
	ld b,a			;d55e	47		G
	ld (03916h),a		;d55f	32 16 39	2 . 9
	ld hl,(0391dh)		;d562	2a 1d 39	* . 9
	jp 023f5h		;d565	c3 f5 23	. . #
	ld a,(03a01h)		;d568	3a 01 3a	: . :
	or a			;d56b	b7		.
	call nz,0294fh		;d56c	c4 4f 29	. O )
	ld a,(03916h)		;d56f	3a 16 39	: . 9
	ld bc,03919h		;d572	01 19 39	. . 9
	and 003h		;d575	e6 03		. .
	cp 003h			;d577	fe 03		. .
	jp z,024a0h		;d579	ca a0 24	. . $
	add a,a			;d57c	87		.
	ld l,a			;d57d	6f		o
	ld h,000h		;d57e	26 00		& .
ld580h:
	nop			;d580	00		.
	ld bc,00302h		;d581	01 02 03	. . .
	inc b			;d584	04		.
	dec b			;d585	05		.
	ld b,007h		;d586	06 07		. .
	ex af,af'		;d588	08		.
	add hl,bc		;d589	09		.
	ld a,(bc)		;d58a	0a		.
	dec bc			;d58b	0b		.
	inc c			;d58c	0c		.
	dec c			;d58d	0d		.
	ld c,00fh		;d58e	0e 0f		. .
	djnz $+19		;d590	10 11		. .
	ld (de),a		;d592	12		.
	inc de			;d593	13		.
	inc d			;d594	14		.
	dec d			;d595	15		.
	ld d,017h		;d596	16 17		. .
	jr $+27			;d598	18 19		. .
	ld a,(de)		;d59a	1a		.
	dec de			;d59b	1b		.
	inc e			;d59c	1c		.
	dec e			;d59d	1d		.
	ld e,01fh		;d59e	1e 1f		. .
	jr nz,ld5c3h		;d5a0	20 21		  !
	ld (02423h),hl		;d5a2	22 23 24	" # $
	dec h			;d5a5	25		%
	ld h,027h		;d5a6	26 27		& '
	jr z,ld5d3h		;d5a8	28 29		( )
	ld hl,(02c2bh)		;d5aa	2a 2b 2c	* + ,
	dec l			;d5ad	2d		-
	ld l,02fh		;d5ae	2e 2f		. /
	jr nc,ld5e3h		;d5b0	30 31		0 1
	ld (03433h),a		;d5b2	32 33 34	2 3 4
	dec (hl)		;d5b5	35		5
	ld (hl),037h		;d5b6	36 37		6 7
	jr c,ld5f3h		;d5b8	38 39		8 9
	ld a,(03c3bh)		;d5ba	3a 3b 3c	: ; <
	dec a			;d5bd	3d		=
	ld a,03fh		;d5be	3e 3f		> ?
	dec b			;d5c0	05		.
	ld b,c			;d5c1	41		A
	ld b,d			;d5c2	42		B
ld5c3h:
	ld b,e			;d5c3	43		C
	ld b,h			;d5c4	44		D
	ld b,l			;d5c5	45		E
	ld b,(hl)		;d5c6	46		F
	ld b,a			;d5c7	47		G
	ld c,b			;d5c8	48		H
	ld c,c			;d5c9	49		I
	ld c,d			;d5ca	4a		J
	ld c,e			;d5cb	4b		K
	ld c,h			;d5cc	4c		L
	ld c,l			;d5cd	4d		M
	ld c,(hl)		;d5ce	4e		N
	ld c,a			;d5cf	4f		O
	ld d,b			;d5d0	50		P
	ld d,c			;d5d1	51		Q
	ld d,d			;d5d2	52		R
ld5d3h:
	ld d,e			;d5d3	53		S
	ld d,h			;d5d4	54		T
	ld d,l			;d5d5	55		U
	ld d,(hl)		;d5d6	56		V
	ld d,a			;d5d7	57		W
	ld e,b			;d5d8	58		X
	ld e,c			;d5d9	59		Y
	ld e,d			;d5da	5a		Z
	dec bc			;d5db	0b		.
	inc c			;d5dc	0c		.
	dec c			;d5dd	0d		.
	ld e,(hl)		;d5de	5e		^
	ld e,a			;d5df	5f		_
	ld d,061h		;d5e0	16 61		. a
	ld h,d			;d5e2	62		b
ld5e3h:
	ld h,e			;d5e3	63		c
	ld h,h			;d5e4	64		d
	ld h,l			;d5e5	65		e
	ld h,(hl)		;d5e6	66		f
	ld h,a			;d5e7	67		g
	ld l,b			;d5e8	68		h
	ld l,c			;d5e9	69		i
	ld l,d			;d5ea	6a		j
	ld l,e			;d5eb	6b		k
	ld l,h			;d5ec	6c		l
	ld l,l			;d5ed	6d		m
	ld l,(hl)		;d5ee	6e		n
	ld l,a			;d5ef	6f		o
	ld (hl),b		;d5f0	70		p
	ld (hl),c		;d5f1	71		q
	ld (hl),d		;d5f2	72		r
ld5f3h:
	ld (hl),e		;d5f3	73		s
	ld (hl),h		;d5f4	74		t
	ld (hl),l		;d5f5	75		u
	halt			;d5f6	76		v
	ld (hl),a		;d5f7	77		w
	ld a,b			;d5f8	78		x
	ld a,c			;d5f9	79		y
	ld a,d			;d5fa	7a		z
	dec de			;d5fb	1b		.
	inc e			;d5fc	1c		.
	dec e			;d5fd	1d		.
	rrca			;d5fe	0f		.
	ld a,a			;d5ff	7f		.
	nop			;d600	00		.
	ld bc,00302h		;d601	01 02 03	. . .
	inc b			;d604	04		.
	dec b			;d605	05		.
	ld b,007h		;d606	06 07		. .
	ex af,af'		;d608	08		.
	add hl,bc		;d609	09		.
	ld a,(bc)		;d60a	0a		.
	dec bc			;d60b	0b		.
	inc c			;d60c	0c		.
	dec c			;d60d	0d		.
	ld c,00fh		;d60e	0e 0f		. .
	djnz $+19		;d610	10 11		. .
	ld (de),a		;d612	12		.
	inc de			;d613	13		.
	inc d			;d614	14		.
	dec d			;d615	15		.
	ld d,017h		;d616	16 17		. .
	jr $+27			;d618	18 19		. .
	ld a,(de)		;d61a	1a		.
	dec de			;d61b	1b		.
	inc e			;d61c	1c		.
	dec e			;d61d	1d		.
	ld e,01fh		;d61e	1e 1f		. .
	jr nz,ld643h		;d620	20 21		  !
	ld (02423h),hl		;d622	22 23 24	" # $
	dec h			;d625	25		%
	ld h,027h		;d626	26 27		& '
	jr z,ld653h		;d628	28 29		( )
	ld hl,(02c2bh)		;d62a	2a 2b 2c	* + ,
	dec l			;d62d	2d		-
	ld l,02fh		;d62e	2e 2f		. /
	jr nc,ld663h		;d630	30 31		0 1
	ld (03433h),a		;d632	32 33 34	2 3 4
	dec (hl)		;d635	35		5
	ld (hl),037h		;d636	36 37		6 7
	jr c,ld673h		;d638	38 39		8 9
	ld a,(03c3bh)		;d63a	3a 3b 3c	: ; <
	dec a			;d63d	3d		=
	ld a,03fh		;d63e	3e 3f		> ?
	ld b,b			;d640	40		@
	ld b,c			;d641	41		A
	ld b,d			;d642	42		B
ld643h:
	ld b,e			;d643	43		C
	ld b,h			;d644	44		D
	ld b,l			;d645	45		E
	ld b,(hl)		;d646	46		F
	ld b,a			;d647	47		G
	ld c,b			;d648	48		H
	ld c,c			;d649	49		I
	ld c,d			;d64a	4a		J
	ld c,e			;d64b	4b		K
	ld c,h			;d64c	4c		L
	ld c,l			;d64d	4d		M
	ld c,(hl)		;d64e	4e		N
	ld c,a			;d64f	4f		O
	ld d,b			;d650	50		P
	ld d,c			;d651	51		Q
	ld d,d			;d652	52		R
ld653h:
	ld d,e			;d653	53		S
	ld d,h			;d654	54		T
	ld d,l			;d655	55		U
	ld d,(hl)		;d656	56		V
	ld d,a			;d657	57		W
	ld e,b			;d658	58		X
	ld e,c			;d659	59		Y
	ld e,d			;d65a	5a		Z
	ld e,e			;d65b	5b		[
	ld e,h			;d65c	5c		\
	ld e,l			;d65d	5d		]
	ld e,(hl)		;d65e	5e		^
	ld e,a			;d65f	5f		_
	ld h,b			;d660	60		`
	ld h,c			;d661	61		a
	ld h,d			;d662	62		b
ld663h:
	ld h,e			;d663	63		c
	ld h,h			;d664	64		d
	ld h,l			;d665	65		e
	ld h,(hl)		;d666	66		f
	ld h,a			;d667	67		g
	ld l,b			;d668	68		h
	ld l,c			;d669	69		i
	ld l,d			;d66a	6a		j
	ld l,e			;d66b	6b		k
	ld l,h			;d66c	6c		l
	ld l,l			;d66d	6d		m
	ld l,(hl)		;d66e	6e		n
	ld l,a			;d66f	6f		o
	ld (hl),b		;d670	70		p
	ld (hl),c		;d671	71		q
	ld (hl),d		;d672	72		r
ld673h:
	ld (hl),e		;d673	73		s
	ld (hl),h		;d674	74		t
	ld (hl),l		;d675	75		u
	halt			;d676	76		v
	ld (hl),a		;d677	77		w
	ld a,b			;d678	78		x
	ld a,c			;d679	79		y
	ld a,d			;d67a	7a		z
	ld a,e			;d67b	7b		{
	ld a,h			;d67c	7c		|
	ld a,l			;d67d	7d		}
	ld a,(hl)		;d67e	7e		~
	ld a,a			;d67f	7f		.
	add a,b			;d680	80		.
	ld bc,00382h		;d681	01 82 03	. . .
	inc b			;d684	04		.
	dec b			;d685	05		.
	add a,(hl)		;d686	86		.
	add a,a			;d687	87		.
	ex af,af'		;d688	08		.
	add hl,bc		;d689	09		.
	ld a,(bc)		;d68a	0a		.
	dec bc			;d68b	0b		.
	inc c			;d68c	0c		.
	dec c			;d68d	0d		.
	ld c,08fh		;d68e	0e 8f		. .
	djnz $-109		;d690	10 91		. .
	sub d			;d692	92		.
	sub e			;d693	93		.
	inc d			;d694	14		.
	dec d			;d695	15		.
	sub (hl)		;d696	96		.
	sub a			;d697	97		.
	jr $+27			;d698	18 19		. .
	ld a,(de)		;d69a	1a		.
	dec de			;d69b	1b		.
	inc e			;d69c	1c		.
	sbc a,l			;d69d	9d		.
	ld e,09fh		;d69e	1e 9f		. .
	jr nz,ld6d3h		;d6a0	20 31		  1
	ld (03433h),a		;d6a2	32 33 34	2 3 4
	dec (hl)		;d6a5	35		5
	ld (hl),037h		;d6a6	36 37		6 7
	jr c,$+59		;d6a8	38 39		8 9
	xor d			;d6aa	aa		.
	jr nc,ld6dah		;d6ab	30 2d		0 -
	xor l			;d6ad	ad		.
	ld l,08bh		;d6ae	2e 8b		. .
	jr nc,$+51		;d6b0	30 31		0 1
	ld (03433h),a		;d6b2	32 33 34	2 3 4
	dec (hl)		;d6b5	35		5
	ld (hl),037h		;d6b6	36 37		6 7
	jr c,ld6f3h		;d6b8	38 39		8 9
	cp d			;d6ba	ba		.
	jr nc,ld6eah		;d6bb	30 2d		0 -
	cp l			;d6bd	bd		.
	ld l,083h		;d6be	2e 83		. .
	ld (de),a		;d6c0	12		.
	add a,(hl)		;d6c1	86		.
	jp nz,0c4c3h		;d6c2	c2 c3 c4	. . .
	push bc			;d6c5	c5		.
	add a,d			;d6c6	82		.
	rst 0			;d6c7	c7		.
	ex af,af'		;d6c8	08		.
	add hl,bc		;d6c9	09		.
	ld a,(bc)		;d6ca	0a		.
	add a,h			;d6cb	84		.
	add a,l			;d6cc	85		.
	call 0cfceh		;d6cd	cd ce cf	. . .
	add a,c			;d6d0	81		.
	pop de			;d6d1	d1		.
	add a,a			;d6d2	87		.
ld6d3h:
	out (0d4h),a		;d6d3	d3 d4		. .
	push de			;d6d5	d5		.
	add a,b			;d6d6	80		.
	rst 10h			;d6d7	d7		.
	jr $-37			;d6d8	18 d9		. .
ld6dah:
	ld a,(de)		;d6da	1a		.
	in a,(0dch)		;d6db	db dc		. .
	defb 0ddh,0deh,030h ;illegal sequence	;d6dd	dd de 30	. . 0
	ret po			;d6e0	e0		.
	adc a,(hl)		;d6e1	8e		.
	jp po,0e4e3h		;d6e2	e2 e3 e4	. . .
	push hl			;d6e5	e5		.
	adc a,d			;d6e6	8a		.
	rst 20h			;d6e7	e7		.
	ret pe			;d6e8	e8		.
	jp (hl)			;d6e9	e9		.
ld6eah:
	jp pe,08d8ch		;d6ea	ea 8c 8d	. . .
	defb 0edh ;next byte illegal after ed	;d6ed	ed		.
	xor 0efh		;d6ee	ee ef		. .
	adc a,c			;d6f0	89		.
	pop af			;d6f1	f1		.
	adc a,a			;d6f2	8f		.
ld6f3h:
	di			;d6f3	f3		.
	call p,088f5h		;d6f4	f4 f5 88	. . .
	rst 30h			;d6f7	f7		.
	ret m			;d6f8	f8		.
	ld sp,hl		;d6f9	f9		.
	jp m,0fcfbh		;d6fa	fa fb fc	. . .
	defb 0fdh,0feh,07fh ;illegal sequence	;d6fd	fd fe 7f	. . .
	di			;d700	f3		.
	ld hl,00000h		;d701	21 00 00	! . .
	ld de,ld480h		;d704	11 80 d4	. . .
	ld bc,02381h		;d707	01 81 23	. . #
	ldir			;d70a	ed b0		. .
	ld hl,ld580h		;d70c	21 80 d5	! . .
	ld de,0f680h		;d70f	11 80 f6	. . .
	ld bc,00180h		;d712	01 80 01	. . .
	ldir			;d715	ed b0		. .
	ld sp,00080h		;d717	31 80 00	1 . .
	ld a,(0ec25h)		;d71a	3a 25 ec	: % .
	ld i,a			;d71d	ed 47		. G
	im 2			;d71f	ed 5e		. ^
	ld a,020h		;d721	3e 20		>  
	out (012h),a		;d723	d3 12		. .
	ld a,022h		;d725	3e 22		> "
	out (013h),a		;d727	d3 13		. .
	ld a,04fh		;d729	3e 4f		> O
	out (012h),a		;d72b	d3 12		. .
	ld a,00fh		;d72d	3e 0f		> .
	out (013h),a		;d72f	d3 13		. .
	ld a,083h		;d731	3e 83		> .
	out (012h),a		;d733	d3 12		. .
	out (013h),a		;d735	d3 13		. .
	ld a,000h		;d737	3e 00		> .
	out (00ch),a		;d739	d3 0c		. .
	ld a,(ld500h)		;d73b	3a 00 d5	: . .
	out (00ch),a		;d73e	d3 0c		. .
	ld a,(ld501h)		;d740	3a 01 d5	: . .
	out (00ch),a		;d743	d3 0c		. .
	ld a,(ld501h+1)		;d745	3a 02 d5	: . .
	out (00dh),a		;d748	d3 0d		. .
	ld a,(ld503h)		;d74a	3a 03 d5	: . .
	out (00dh),a		;d74d	d3 0d		. .
	ld a,(ld503h+1)		;d74f	3a 04 d5	: . .
	out (00eh),a		;d752	d3 0e		. .
	ld a,(ld505h)		;d754	3a 05 d5	: . .
	out (00eh),a		;d757	d3 0e		. .
	ld a,(ld505h+1)		;d759	3a 06 d5	: . .
	out (00fh),a		;d75c	d3 0f		. .
	ld a,(ld505h+2)		;d75e	3a 07 d5	: . .
	out (00fh),a		;d761	d3 0f		. .
	ld a,008h		;d763	3e 08		> .
	out (044h),a		;d765	d3 44		. D
	ld a,(ld544h)		;d767	3a 44 d5	: D .
	out (044h),a		;d76a	d3 44		. D
	ld a,(ld545h)		;d76c	3a 45 d5	: E .
	out (044h),a		;d76f	d3 44		. D
	ld a,(ld545h+1)		;d771	3a 46 d5	: F .
	out (045h),a		;d774	d3 45		. E
	ld a,(ld545h+1)		;d776	3a 46 d5	: F .
	out (046h),a		;d779	d3 46		. F
	ld a,(ld545h+1)		;d77b	3a 46 d5	: F .
	out (047h),a		;d77e	d3 47		. G
	ld hl,ld508h		;d780	21 08 d5	! . .
	ld b,009h		;d783	06 09		. .
	ld c,00ah		;d785	0e 0a		. .
	otir			;d787	ed b3		. .
	ld hl,ld511h		;d789	21 11 d5	! . .
	ld b,00bh		;d78c	06 0b		. .
	ld c,00bh		;d78e	0e 0b		. .
	otir			;d790	ed b3		. .
	in a,(00ah)		;d792	db 0a		. .
	ld (ldc03h),a		;d794	32 03 dc	2 . .
	ld a,001h		;d797	3e 01		> .
	out (00ah),a		;d799	d3 0a		. .
	in a,(00ah)		;d79b	db 0a		. .
	ld (ldc04h),a		;d79d	32 04 dc	2 . .
	in a,(00bh)		;d7a0	db 0b		. .
	ld (ldc05h),a		;d7a2	32 05 dc	2 . .
	ld a,001h		;d7a5	3e 01		> .
	out (00bh),a		;d7a7	d3 0b		. .
	in a,(00bh)		;d7a9	db 0b		. .
	ld (ldc06h),a		;d7ab	32 06 dc	2 . .
	ld a,020h		;d7ae	3e 20		>  
	out (0f8h),a		;d7b0	d3 f8		. .
	ld a,(ld51ch)		;d7b2	3a 1c d5	: . .
	out (0fbh),a		;d7b5	d3 fb		. .
	ld a,(ld51eh)		;d7b7	3a 1e d5	: . .
	out (0fbh),a		;d7ba	d3 fb		. .
	ld a,(ld51fh)		;d7bc	3a 1f d5	: . .
	out (0fbh),a		;d7bf	d3 fb		. .
	in a,(014h)		;d7c1	db 14		. .
	and 080h		;d7c3	e6 80		. .
	jp z,ld7f2h		;d7c5	ca f2 d7	. . .
	ld hl,ld52dh+2		;d7c8	21 2f d5	! / .
	ld a,(hl)		;d7cb	7e		~
	cp 008h			;d7cc	fe 08		. .
	jp nz,ld7d3h		;d7ce	c2 d3 d7	. . .
	ld (hl),010h		;d7d1	36 10		6 .
ld7d3h:
	inc hl			;d7d3	23		#
	ld a,(hl)		;d7d4	7e		~
	cp 008h			;d7d5	fe 08		. .
	jp nz,ld7dch		;d7d7	c2 dc d7	. . .
	ld (hl),010h		;d7da	36 10		6 .
ld7dch:
	ld a,(lda36h)		;d7dc	3a 36 da	: 6 .
	cp 003h			;d7df	fe 03		. .
	jr z,ld7eah		;d7e1	28 07		( .
	ld a,00fh		;d7e3	3e 0f		> .
	ld (ld526h),a		;d7e5	32 26 d5	2 & .
	jr ld7f2h		;d7e8	18 08		. .
ld7eah:
	ld a,018h		;d7ea	3e 18		> .
	ld (ld52dh+2),a		;d7ec	32 2f d5	2 / .
	ld (ld530h),a		;d7ef	32 30 d5	2 0 .
ld7f2h:
	in a,(004h)		;d7f2	db 04		. .
	and 01fh		;d7f4	e6 1f		. .
	jp nz,ld7f2h		;d7f6	c2 f2 d7	. . .
	ld hl,ld524h		;d7f9	21 24 d5	! $ .
	ld b,(hl)		;d7fc	46		F
ld7fdh:
	inc hl			;d7fd	23		#
ld7feh:
	in a,(004h)		;d7fe	db 04		. .
	and 0c0h		;d800	e6 c0		. .
	cp 080h			;d802	fe 80		. .
	jp nz,ld7feh		;d804	c2 fe d7	. . .
	ld a,(hl)		;d807	7e		~
	out (005h),a		;d808	d3 05		. .
	dec b			;d80a	05		.
	jp nz,ld7fdh		;d80b	c2 fd d7	. . .
	ld hl,0f800h		;d80e	21 00 f8	! . .
	ld de,0f801h		;d811	11 01 f8	. . .
	ld bc,007cfh		;d814	01 cf 07	. . .
	ld (hl),020h		;d817	36 20		6  
	ldir			;d819	ed b0		. .
	ld hl,0f500h		;d81b	21 00 f5	! . .
	ld de,0f501h		;d81e	11 01 f5	. . .
	ld bc,000fah		;d821	01 fa 00	. . .
	ld (hl),000h		;d824	36 00		6 .
	ldir			;d826	ed b0		. .
	ld hl,0ffd1h		;d828	21 d1 ff	! . .
	ld de,0ffd2h		;d82b	11 d2 ff	. . .
	ld (hl),000h		;d82e	36 00		6 .
	ld bc,0002eh		;d830	01 2e 00	. . .
	ldir			;d833	ed b0		. .
	ld a,000h		;d835	3e 00		> .
	out (001h),a		;d837	d3 01		. .
	ld a,(ld520h)		;d839	3a 20 d5	:   .
	out (000h),a		;d83c	d3 00		. .
	ld a,(ld521h)		;d83e	3a 21 d5	: ! .
	out (000h),a		;d841	d3 00		. .
	ld a,(ld522h)		;d843	3a 22 d5	: " .
	out (000h),a		;d846	d3 00		. .
	ld a,(ld523h)		;d848	3a 23 d5	: # .
	out (000h),a		;d84b	d3 00		. .
	ld a,080h		;d84d	3e 80		> .
	out (001h),a		;d84f	d3 01		. .
	ld a,000h		;d851	3e 00		> .
	out (000h),a		;d853	d3 00		. .
	out (000h),a		;d855	d3 00		. .
	ld a,0e0h		;d857	3e e0		> .
	out (001h),a		;d859	d3 01		. .
	ld a,023h		;d85b	3e 23		> #
	out (001h),a		;d85d	d3 01		. .
	ld de,0ee80h		;d85f	11 80 ee	. . .
	ld hl,0f500h		;d862	21 00 f5	! . .
	and a			;d865	a7		.
	sbc hl,de		;d866	ed 52		. R
	ld c,l			;d868	4d		M
	ld b,h			;d869	44		D
	ld hl,0ee81h		;d86a	21 81 ee	! . .
	ex de,hl		;d86d	eb		.
	ld (hl),000h		;d86e	36 00		6 .
	ldir			;d870	ed b0		. .
	ld a,(ld50eh)		;d872	3a 0e d5	: . .
	and 060h		;d875	e6 60		. `
	ld (lda34h),a		;d877	32 34 da	2 4 .
	ld a,(ld519h)		;d87a	3a 19 d5	: . .
	and 060h		;d87d	e6 60		. `
	ld (lda35h),a		;d87f	32 35 da	2 5 .
	ld a,(ld52ch)		;d882	3a 2c d5	: , .
	ld (lda33h),a		;d885	32 33 da	2 3 .
	ld hl,(ld52dh)		;d888	2a 2d d5	* - .
	ld (0ffe7h),hl		;d88b	22 e7 ff	" . .
	ld a,0ffh		;d88e	3e ff		> .
	ld (0f34fh),a		;d890	32 4f f3	2 O .
	call sub_d8bfh		;d893	cd bf d8	. . .
	ld a,0ffh		;d896	3e ff		> .
	ld (ld531h),a		;d898	32 31 d5	2 1 .
	xor a			;d89b	af		.
	ld (lda47h),a		;d89c	32 47 da	2 G .
	call sub_d8bfh		;d89f	cd bf d8	. . .
	ld hl,0eb1dh		;d8a2	21 1d eb	! . .
	ld (ld8bdh),hl		;d8a5	22 bd d8	" . .
	ld hl,lda39h		;d8a8	21 39 da	! 9 .
	push hl			;d8ab	e5		.
ld8ach:
	pop hl			;d8ac	e1		.
	push hl			;d8ad	e5		.
	call sub_d8eah		;d8ae	cd ea d8	. . .
	pop hl			;d8b1	e1		.
	inc hl			;d8b2	23		#
	push hl			;d8b3	e5		.
	ld a,(hl)		;d8b4	7e		~
	cp 0ffh			;d8b5	fe ff		. .
	jr nz,ld8ach		;d8b7	20 f3		  .
	pop hl			;d8b9	e1		.
	jp 0da00h		;d8ba	c3 00 da	. . .
ld8bdh:
	nop			;d8bd	00		.
	nop			;d8be	00		.
sub_d8bfh:
	ld c,000h		;d8bf	0e 00		. .
	ld hl,ld52dh+2		;d8c1	21 2f d5	! / .
	ld de,lda37h		;d8c4	11 37 da	. 7 .
ld8c7h:
	ld a,(hl)		;d8c7	7e		~
	cp 0ffh			;d8c8	fe ff		. .
	jp z,ld8d4h		;d8ca	ca d4 d8	. . .
	ld (de),a		;d8cd	12		.
	inc c			;d8ce	0c		.
	inc de			;d8cf	13		.
	inc hl			;d8d0	23		#
	jp ld8c7h		;d8d1	c3 c7 d8	. . .
ld8d4h:
	ld a,c			;d8d4	79		y
	dec a			;d8d5	3d		=
	ld (0f334h),a		;d8d6	32 34 f3	2 4 .
	ld a,002h		;d8d9	3e 02		> .
	ld (0f335h),a		;d8db	32 35 f3	2 5 .
	ld hl,ld541h		;d8de	21 41 d5	! A .
	ld de,0f336h		;d8e1	11 36 f3	. 6 .
	ld bc,00003h		;d8e4	01 03 00	. . .
	ldir			;d8e7	ed b0		. .
	ret			;d8e9	c9		.
sub_d8eah:
	ld de,0000fh		;d8ea	11 0f 00	. . .
	ld b,008h		;d8ed	06 08		. .
	ld a,(hl)		;d8ef	7e		~
	and 0f8h		;d8f0	e6 f8		. .
	ld hl,0e984h		;d8f2	21 84 e9	! . .
	or a			;d8f5	b7		.
	jr z,ld8fch		;d8f6	28 04		( .
ld8f8h:
	add hl,de		;d8f8	19		.
	sub b			;d8f9	90		.
	jr nz,ld8f8h		;d8fa	20 fc		  .
ld8fch:
	ld de,(ld8bdh)		;d8fc	ed 5b bd d8	. [ . .
	ex de,hl		;d900	eb		.
	ld (hl),e		;d901	73		s
	inc hl			;d902	23		#
	ld (hl),d		;d903	72		r
	ld de,0000fh		;d904	11 0f 00	. . .
	add hl,de		;d907	19		.
	ld (ld8bdh),hl		;d908	22 bd d8	" . .
	ret			;d90b	c9		.
	xor a			;d90c	af		.
	ld (03839h),a		;d90d	32 39 38	2 9 8
	ld a,d			;d910	7a		z
	or a			;d911	b7		.
	jp nz,00487h		;d912	c2 87 04	. . .
	ld a,(03940h)		;d915	3a 40 39	: @ 9
	cp 020h			;d918	fe 20		.  
	ret nz			;d91a	c0		.
	ld a,e			;d91b	7b		{
	dec a			;d91c	3d		=
	ret m			;d91d	f8		.
	jp z,00487h		;d91e	ca 87 04	. . .
	cp 010h			;d921	fe 10		. .
	jp nc,00487h		;d923	d2 87 04	. . .
	inc a			;d926	3c		<
	ld (03838h),a		;d927	32 38 38	2 8 8
	xor a			;d92a	af		.
	ld h,a			;d92b	67		g
	ld l,e			;d92c	6b		k
	jp 0197fh		;d92d	c3 7f 19	. . .
	call 025dch		;d930	cd dc 25	. . %
	ld a,d			;d933	7a		z
	or a			;d934	b7		.
	jp nz,00487h		;d935	c2 87 04	. . .
	ld a,(03833h)		;d938	3a 33 38	: 3 8
	or a			;d93b	b7		.
	ret z			;d93c	c8		.
	ld a,e			;d93d	7b		{
	or a			;d93e	b7		.
	jp z,0285dh		;d93f	ca 5d 28	. ] (
	cp 00ah			;d942	fe 0a		. .
	call c,00487h		;d944	dc 87 04	. . .
	ld a,(03940h)		;d947	3a 40 39	: @ 9
	cp 020h			;d94a	fe 20		.  
	jp nz,0285dh		;d94c	c2 5d 28	. ] (
	ld a,e			;d94f	7b		{
	ld (03877h),a		;d950	32 77 38	2 w 8
	call 01794h		;d953	cd 94 17	. . .
	call 0042dh		;d956	cd 2d 04	. - .
	jp 018bbh		;d959	c3 bb 18	. . .
	call 00b1bh		;d95c	cd 1b 0b	. . .
	jp nz,00487h		;d95f	c2 87 04	. . .
	push af			;d962	f5		.
	ld a,(0392ch)		;d963	3a 2c 39	: , 9
	cp 008h			;d966	fe 08		. .
	jp c,0287ah		;d968	da 7a 28	. z (
	call 004b7h		;d96b	cd b7 04	. . .
	ld a,007h		;d96e	3e 07		> .
	ld hl,03927h		;d970	21 27 39	! ' 9
	ld (hl),a		;d973	77		w
	ld a,(03833h)		;d974	3a 33 38	: 3 8
	or a			;d977	b7		.
	ld (03884h),hl		;d978	22 84 38	" . 8
	ld c,003h		;d97b	0e 03		. .
	call nz,019f2h		;d97d	c4 f2 19	. . .
	pop af			;d980	f1		.
	cp 02ch			;d981	fe 2c		. ,
	jp z,02866h		;d983	ca 66 28	. f (
	ret			;d986	c9		.
	ld a,(03871h)		;d987	3a 71 38	: q 8
	or a			;d98a	b7		.
	jp nz,004abh		;d98b	c2 ab 04	. . .
	call 00b8eh		;d98e	cd 8e 0b	. . .
	ld hl,(0388bh)		;d991	2a 8b 38	* . 8
	dec hl			;d994	2b		+
	call 0486eh		;d995	cd 6e 48	. n H
	or a			;d998	b7		.
	jp z,028ach		;d999	ca ac 28	. . (
	call 04931h		;d99c	cd 31 49	. 1 I
	jp 004c9h		;d99f	c3 c9 04	. . .
	dec a			;d9a2	3d		=
	ld (03871h),a		;d9a3	32 71 38	2 q 8
	ld hl,(0388bh)		;d9a6	2a 8b 38	* . 8
	ld a,(hl)		;d9a9	7e		~
	inc hl			;d9aa	23		#
	ld (0388bh),hl		;d9ab	22 8b 38	" . 8
	cp 021h			;d9ae	fe 21		. !
	jp nc,028b0h		;d9b0	d2 b0 28	. . (
	ret			;d9b3	c9		.
	call 00b8eh		;d9b4	cd 8e 0b	. . .
	cp 028h			;d9b7	fe 28		. (
	jp nz,00487h		;d9b9	c2 87 04	. . .
	call 00aefh		;d9bc	cd ef 0a	. . .
	cp 027h			;d9bf	fe 27		. '
	jp nz,00487h		;d9c1	c2 87 04	. . .
	call 00b1bh		;d9c4	cd 1b 0b	. . .
	jp nz,00487h		;d9c7	c2 87 04	. . .
	cp 027h			;d9ca	fe 27		. '
	jp nz,00487h		;d9cc	c2 87 04	. . .
	call 00aefh		;d9cf	cd ef 0a	. . .
	cp 029h			;d9d2	fe 29		. )
	jp nz,00487h		;d9d4	c2 87 04	. . .
	call 00b06h		;d9d7	cd 06 0b	. . .
	ld a,(03833h)		;d9da	3a 33 38	: 3 8
	or a			;d9dd	b7		.
	ret nz			;d9de	c0		.
	ld a,(0392ch)		;d9df	3a 2c 39	: , 9
	cp 006h			;d9e2	fe 06		. .
	jp c,028f3h		;d9e4	da f3 28	. . (
	ld a,006h		;d9e7	3e 06		> .
	ld de,0392dh		;d9e9	11 2d 39	. - 9
	ld hl,03a02h		;d9ec	21 02 3a	! . :
	ld b,a			;d9ef	47		G
	ld a,(hl)		;d9f0	7e		~
	or a			;d9f1	b7		.
	jp nz,0049fh		;d9f2	c2 9f 04	. . .
ld9f5h:
	ld a,(de)		;d9f5	1a		.
	ld (hl),a		;d9f6	77		w
	inc hl			;d9f7	23		#
	inc de			;d9f8	13		.
	dec b			;d9f9	05		.
	jp nz,028ffh		;d9fa	c2 ff 28	. . (
	ld (hl),b		;d9fd	70		p
	ret			;d9fe	c9		.
	call 03dc3h		;d9ff	cd c3 3d	. . =
	in a,(0c3h)		;da02	db c3		. .
	add a,(hl)		;da04	86		.
	in a,(0c3h)		;da05	db c3		. .
	jr z,ld9f5h		;da07	28 ec		( .
	jp 0ec2ch		;da09	c3 2c ec	. , .
	jp 0e183h		;da0c	c3 83 e1	. . .
	jp ldc0bh		;da0f	c3 0b dc	. . .
	jp ldc5eh		;da12	c3 5e dc	. ^ .
	jp ldc4eh		;da15	c3 4e dc	. N .
	jp 0e5d2h		;da18	c3 d2 e5	. . .
	jp 0e247h		;da1b	c3 47 e2	. G .
	jp 0e2f0h		;da1e	c3 f0 e2	. . .
	jp 0e2f6h		;da21	c3 f6 e2	. . .
	jp 0e2fch		;da24	c3 fc e2	. . .
	jp 0e305h		;da27	c3 05 e3	. . .
	jp 0e319h		;da2a	c3 19 e3	. . .
	jp ldc07h		;da2d	c3 07 dc	. . .
	jp 0e302h		;da30	c3 02 e3	. . .
lda33h:
	nop			;da33	00		.
lda34h:
	nop			;da34	00		.
lda35h:
	nop			;da35	00		.
lda36h:
	nop			;da36	00		.
lda37h:
	rst 38h			;da37	ff		.
	rst 38h			;da38	ff		.
lda39h:
	rst 38h			;da39	ff		.
	rst 38h			;da3a	ff		.
	rst 38h			;da3b	ff		.
	rst 38h			;da3c	ff		.
	rst 38h			;da3d	ff		.
	rst 38h			;da3e	ff		.
	rst 38h			;da3f	ff		.
	rst 38h			;da40	ff		.
	rst 38h			;da41	ff		.
	rst 38h			;da42	ff		.
	rst 38h			;da43	ff		.
	rst 38h			;da44	ff		.
	rst 38h			;da45	ff		.
	rst 38h			;da46	ff		.
lda47h:
	nop			;da47	00		.
	or a			;da48	b7		.
	ret z			;da49	c8		.
	jp 0e6bfh		;da4a	c3 bf e6	. . .
	jp ldc4ah		;da4d	c3 4a dc	. J .
	jp ldadfh		;da50	c3 df da	. . .
	jp ldabch		;da53	c3 bc da	. . .
	jp ldac9h		;da56	c3 c9 da	. . .
	jp 0e8ceh		;da59	c3 ce e8	. . .
	inc hl			;da5c	23		#
	ld a,(hl)		;da5d	7e		~
	and 064h		;da5e	e6 64		. d
	jp nz,02980h		;da60	c2 80 29	. . )
	ld a,(hl)		;da63	7e		~
	and 003h		;da64	e6 03		. .
	or 080h			;da66	f6 80		. .
	ld (hl),a		;da68	77		w
	pop af			;da69	f1		.
	cp 02ch			;da6a	fe 2c		. ,
	jp z,02958h		;da6c	ca 58 29	. X )
lda6fh:
	nop			;da6f	00		.
	nop			;da70	00		.
lda71h:
	dec c			;da71	0d		.
	ld a,(bc)		;da72	0a		.
	rlca			;da73	07		.
	ld b,h			;da74	44		D
	ld l,c			;da75	69		i
	ld (hl),e		;da76	73		s
	ld l,e			;da77	6b		k
	jr nz,ldaech		;da78	20 72		  r
	ld h,l			;da7a	65		e
	ld h,c			;da7b	61		a
	ld h,h			;da7c	64		d
	jr nz,$+103		;da7d	20 65		  e
	ld (hl),d		;da7f	72		r
	ld (hl),d		;da80	72		r
	ld l,a			;da81	6f		o
	ld (hl),d		;da82	72		r
	jr nz,$+47		;da83	20 2d		  -
	jr nz,ldaf9h		;da85	20 72		  r
	ld h,l			;da87	65		e
	ld (hl),e		;da88	73		s
	ld h,l			;da89	65		e
	ld (hl),h		;da8a	74		t
	dec c			;da8b	0d		.
	ld a,(bc)		;da8c	0a		.
	nop			;da8d	00		.
lda8eh:
	inc c			;da8e	0c		.
	ld c,h			;da8f	4c		L
	ld l,a			;da90	6f		o
	ld h,c			;da91	61		a
	ld h,h			;da92	64		d
	ld l,c			;da93	69		i
	ld l,(hl)		;da94	6e		n
	ld h,a			;da95	67		g
	jr nz,$+118		;da96	20 74		  t
	ld h,l			;da98	65		e
	ld (hl),e		;da99	73		s
	ld (hl),h		;da9a	74		t
	jr nz,$+114		;da9b	20 70		  p
	ld (hl),d		;da9d	72		r
	ld l,a			;da9e	6f		o
	ld h,a			;da9f	67		g
	ld (hl),d		;daa0	72		r
	ld h,c			;daa1	61		a
	ld l,l			;daa2	6d		m
	dec c			;daa3	0d		.
	ld a,(bc)		;daa4	0a		.
	nop			;daa5	00		.
ldaa6h:
	ld a,(hl)		;daa6	7e		~
	or a			;daa7	b7		.
	ret z			;daa8	c8		.
	push hl			;daa9	e5		.
	ld c,a			;daaa	4f		O
	call 0e183h		;daab	cd 83 e1	. . .
	pop hl			;daae	e1		.
	inc hl			;daaf	23		#
	jp ldaa6h		;dab0	c3 a6 da	. . .
ldab3h:
	ld hl,lda71h		;dab3	21 71 da	! q .
	call ldaa6h		;dab6	cd a6 da	. . .
ldab9h:
	jp ldab9h		;dab9	c3 b9 da	. . .
ldabch:
	ld a,0c3h		;dabc	3e c3		> .
	ld (0ffe5h),a		;dabe	32 e5 ff	2 . .
	ld (0ffe6h),hl		;dac1	22 e6 ff	" . .
	ex de,hl		;dac4	eb		.
	ld (0ffdfh),hl		;dac5	22 df ff	" . .
	ret			;dac8	c9		.
ldac9h:
	di			;dac9	f3		.
	or a			;daca	b7		.
	jp z,ldad7h		;dacb	ca d7 da	. . .
	ld de,(0fffch)		;dace	ed 5b fc ff	. [ . .
	ld hl,(0fffeh)		;dad2	2a fe ff	* . .
	ei			;dad5	fb		.
	ret			;dad6	c9		.
ldad7h:
	ld (0fffch),de		;dad7	ed 53 fc ff	. S . .
	ld (0fffeh),hl		;dadb	22 fe ff	" . .
	ret			;dade	c9		.
ldadfh:
	add a,00ah		;dadf	c6 0a		. .
	ld c,a			;dae1	4f		O
ldae2h:
	di			;dae2	f3		.
	ld a,001h		;dae3	3e 01		> .
	out (c),a		;dae5	ed 79		. y
	in a,(c)		;dae7	ed 78		. x
	ei			;dae9	fb		.
	and 001h		;daea	e6 01		. .
ldaech:
	jr z,ldae2h		;daec	28 f4		( .
	ld d,005h		;daee	16 05		. .
	ld a,000h		;daf0	3e 00		> .
	call sub_db1ch		;daf2	cd 1c db	. . .
	dec b			;daf5	05		.
	ret m			;daf6	f8		.
	sla b			;daf7	cb 20		.  
ldaf9h:
	or b			;daf9	b0		.
	call sub_db1ch		;dafa	cd 1c db	. . .
	or 080h			;dafd	f6 80		. .
	call sub_db1ch		;daff	cd 1c db	. . .
	ld hl,00002h		;db02	21 02 00	! . .
	call 0e5c6h		;db05	cd c6 e5	. . .
	ld a,c			;db08	79		y
	cp 00ah			;db09	fe 0a		. .
	ld a,(ldc03h)		;db0b	3a 03 dc	: . .
	jp z,ldb14h		;db0e	ca 14 db	. . .
	ld a,(ldc05h)		;db11	3a 05 dc	: . .
ldb14h:
	and 020h		;db14	e6 20		.  
	jp z,sub_db1ch		;db16	ca 1c db	. . .
	ld a,0ffh		;db19	3e ff		> .
	ret			;db1b	c9		.
sub_db1ch:
	di			;db1c	f3		.
	out (c),d		;db1d	ed 51		. Q
	out (c),a		;db1f	ed 79		. y
	ei			;db21	fb		.
	ret			;db22	c9		.
	xor a			;db23	af		.
	ld (0d84ch),a		;db24	32 4c d8	2 L .
	ld hl,(0d89ah)		;db27	2a 9a d8	* . .
	ld (lda6fh),hl		;db2a	22 6f da	" o .
	ld hl,ldb34h		;db2d	21 34 db	! 4 .
	ld (0d89ah),hl		;db30	22 9a d8	" . .
	ret			;db33	c9		.
ldb34h:
	push hl			;db34	e5		.
	ld hl,(lda6fh)		;db35	2a 6f da	* o .
	ld (0d89ah),hl		;db38	22 9a d8	" . .
	pop hl			;db3b	e1		.
	ret			;db3c	c9		.
	ld sp,0f384h		;db3d	31 84 f3	1 . .
	ld hl,lda8eh		;db40	21 8e da	! . .
	call ldaa6h		;db43	cd a6 da	. . .
	xor a			;db46	af		.
	ld (00004h),a		;db47	32 04 00	2 . .
	ld (0f350h),a		;db4a	32 50 f3	2 P .
	ld a,(lda47h)		;db4d	3a 47 da	: G .
	or a			;db50	b7		.
	jp z,ldb59h		;db51	ca 59 db	. Y .
	ld a,002h		;db54	3e 02		> .
	ld (00004h),a		;db56	32 04 00	2 . .
ldb59h:
	xor a			;db59	af		.
	ld (0f321h),a		;db5a	32 21 f3	2 ! .
	ld (0f32ah),a		;db5d	32 2a f3	2 * .
	ld (0f322h),a		;db60	32 22 f3	2 " .
	in a,(014h)		;db63	db 14		. .
	and 080h		;db65	e6 80		. .
	jp z,ldb86h		;db67	ca 86 db	. . .
	ld a,(0f334h)		;db6a	3a 34 f3	: 4 .
	cp 002h			;db6d	fe 02		. .
	jp nc,ldb83h		;db6f	d2 83 db	. . .
	ld c,001h		;db72	0e 01		. .
	call 0e247h		;db74	cd 47 e2	. G .
	call 0e5d2h		;db77	cd d2 e5	. . .
	ld a,b			;db7a	78		x
	and 010h		;db7b	e6 10		. .
	ld a,000h		;db7d	3e 00		> .
	jp nz,ldb83h		;db7f	c2 83 db	. . .
	inc a			;db82	3c		<
ldb83h:
	ld (0f334h),a		;db83	32 34 f3	2 4 .
ldb86h:
	ei			;db86	fb		.
	ld c,000h		;db87	0e 00		. .
	ld a,(lda47h)		;db89	3a 47 da	: G .
	or a			;db8c	b7		.
	jr z,ldb92h		;db8d	28 03		( .
	ld a,002h		;db8f	3e 02		> .
	ld c,a			;db91	4f		O
ldb92h:
	call 0e247h		;db92	cd 47 e2	. G .
	xor a			;db95	af		.
	ld (0f323h),a		;db96	32 23 f3	2 # .
	ld (00003h),a		;db99	32 03 00	2 . .
	ld (0f339h),a		;db9c	32 39 f3	2 9 .
	ld (0ec26h),a		;db9f	32 26 ec	2 & .
	call 0e5d2h		;dba2	cd d2 e5	. . .
	ld sp,0f384h		;dba5	31 84 f3	1 . .
	ld bc,00000h		;dba8	01 00 00	. . .
	call 0e2fch		;dbab	cd fc e2	. . .
	ld hl,000f0h		;dbae	21 f0 00	! . .
	ld (0f370h),hl		;dbb1	22 70 f3	" p .
	ld bc,00001h		;dbb4	01 01 00	. . .
	call 0e2f0h		;dbb7	cd f0 e2	. . .
	ld bc,00000h		;dbba	01 00 00	. . .
	call 0e2f6h		;dbbd	cd f6 e2	. . .
ldbc0h:
	push bc			;dbc0	c5		.
	call 0e305h		;dbc1	cd 05 e3	. . .
	or a			;dbc4	b7		.
	jp nz,ldab3h		;dbc5	c2 b3 da	. . .
	ld hl,(0f370h)		;dbc8	2a 70 f3	* p .
	dec hl			;dbcb	2b		+
	ld (0f370h),hl		;dbcc	22 70 f3	" p .
	ld a,h			;dbcf	7c		|
	or l			;dbd0	b5		.
	jr z,ldbfbh		;dbd1	28 28		( (
	ld hl,(0f32eh)		;dbd3	2a 2e f3	* . .
	ld de,00080h		;dbd6	11 80 00	. . .
	add hl,de		;dbd9	19		.
	ld b,h			;dbda	44		D
	ld c,l			;dbdb	4d		M
	call 0e2fch		;dbdc	cd fc e2	. . .
	pop bc			;dbdf	c1		.
	inc bc			;dbe0	03		.
	call 0e2f6h		;dbe1	cd f6 e2	. . .
	ld hl,(0f354h)		;dbe4	2a 54 f3	* T .
	or a			;dbe7	b7		.
	sbc hl,bc		;dbe8	ed 42		. B
	jr nz,ldbc0h		;dbea	20 d4		  .
	ld hl,(0f313h)		;dbec	2a 13 f3	* . .
	inc hl			;dbef	23		#
	ld (0f313h),hl		;dbf0	22 13 f3	" . .
	ld bc,00000h		;dbf3	01 00 00	. . .
	call 0e2f6h		;dbf6	cd f6 e2	. . .
	jr ldbc0h		;dbf9	18 c5		. .
ldbfbh:
	jp 00000h		;dbfb	c3 00 00	. . .
ldbfeh:
	rst 38h			;dbfe	ff		.
ldbffh:
	rst 38h			;dbff	ff		.
ldc00h:
	rst 38h			;dc00	ff		.
ldc01h:
	nop			;dc01	00		.
	nop			;dc02	00		.
ldc03h:
	nop			;dc03	00		.
ldc04h:
	nop			;dc04	00		.
ldc05h:
	nop			;dc05	00		.
ldc06h:
	nop			;dc06	00		.
ldc07h:
	ld a,(ldbfeh)		;dc07	3a fe db	: . .
	ret			;dc0a	c9		.
ldc0bh:
	ld a,(ldbfeh)		;dc0b	3a fe db	: . .
	or a			;dc0e	b7		.
	jp z,ldc0bh		;dc0f	ca 0b dc	. . .
	di			;dc12	f3		.
	ld a,000h		;dc13	3e 00		> .
	ld (ldbfeh),a		;dc15	32 fe db	2 . .
	ld a,005h		;dc18	3e 05		> .
	out (00bh),a		;dc1a	d3 0b		. .
	ld a,(lda35h)		;dc1c	3a 35 da	: 5 .
	add a,08ah		;dc1f	c6 8a		. .
	out (00bh),a		;dc21	d3 0b		. .
	ld a,001h		;dc23	3e 01		> .
	out (00bh),a		;dc25	d3 0b		. .
	ld a,007h		;dc27	3e 07		> .
	out (00bh),a		;dc29	d3 0b		. .
	ld a,c			;dc2b	79		y
	out (009h),a		;dc2c	d3 09		. .
	ei			;dc2e	fb		.
	ret			;dc2f	c9		.
sub_dc30h:
	di			;dc30	f3		.
	xor a			;dc31	af		.
	ld (ldbffh),a		;dc32	32 ff db	2 . .
	ld a,005h		;dc35	3e 05		> .
	out (00ah),a		;dc37	d3 0a		. .
	ld a,(lda34h)		;dc39	3a 34 da	: 4 .
	add a,08ah		;dc3c	c6 8a		. .
	out (00ah),a		;dc3e	d3 0a		. .
	ld a,001h		;dc40	3e 01		> .
	out (00ah),a		;dc42	d3 0a		. .
	ld a,01bh		;dc44	3e 1b		> .
	out (00ah),a		;dc46	d3 0a		. .
	ei			;dc48	fb		.
	ret			;dc49	c9		.
ldc4ah:
	ld a,(ldbffh)		;dc4a	3a ff db	: . .
	ret			;dc4d	c9		.
ldc4eh:
	call ldc4ah		;dc4e	cd 4a dc	. J .
	or a			;dc51	b7		.
	jp z,ldc4eh		;dc52	ca 4e dc	. N .
	ld a,(ldc01h)		;dc55	3a 01 dc	: . .
	push af			;dc58	f5		.
	call sub_dc30h		;dc59	cd 30 dc	. 0 .
	pop af			;dc5c	f1		.
	ret			;dc5d	c9		.
ldc5eh:
	ld a,(ldc00h)		;dc5e	3a 00 dc	: . .
	or a			;dc61	b7		.
	jp z,ldc5eh		;dc62	ca 5e dc	. ^ .
	di			;dc65	f3		.
	ld a,000h		;dc66	3e 00		> .
	ld (ldc00h),a		;dc68	32 00 dc	2 . .
	ld a,005h		;dc6b	3e 05		> .
	out (00ah),a		;dc6d	d3 0a		. .
	ld a,(lda34h)		;dc6f	3a 34 da	: 4 .
	add a,08ah		;dc72	c6 8a		. .
	out (00ah),a		;dc74	d3 0a		. .
	ld a,001h		;dc76	3e 01		> .
	out (00ah),a		;dc78	d3 0a		. .
	ld a,01bh		;dc7a	3e 1b		> .
	out (00ah),a		;dc7c	d3 0a		. .
	ld a,c			;dc7e	79		y
	defb 0d3h		;dc7f	d3		.
