; z80dasm 1.2.0
; command line: z80dasm -a -l -t -b /tmp/roa375_blocks.txt -g 0x73CA -o /Users/ravn/git/rc700-sysgen/roa375/roa375_tail.asm /tmp/roa375_tail.bin

	org 073cah


; BLOCK 'errdsp' (start 0x73ca end 0x73f1)
errdsp_start:
	ld (08003h),a		;73ca	32 03 80	2 . .
	ei			;73cd	fb		.
	ld a,(08060h)		;73ce	3a 60 80	: ` .
	and 001h		;73d1	e6 01		. .
	jp nz,0735dh		;73d3	c2 5d 73	. ] s
	out (01ch),a		;73d6	d3 1c		. .
	call 073deh		;73d8	cd de 73	. . s
	or a			;73db	b7		.
	jp 073dah		;73dc	c3 da 73	. . s
	ld bc,07800h		;73df	01 00 78	. . x
	ld de,l73f0h		;73e2	11 f0 73	. . s
	ld hl,00012h		;73e5	21 12 00	! . .
	ld a,(de)		;73e8	1a		.
	ld (bc),a		;73e9	02		.
	inc bc			;73ea	03		.
	inc de			;73eb	13		.
	dec l			;73ec	2d		-
	jp nz,073e7h		;73ed	c2 e7 73	. . s
l73f0h:
	ret			;73f0	c9		.
errdsp_end:

; BLOCK 'errmsg' (start 0x73f1 end 0x7404)
errmsg_start:
	defb '**DISKETTE ERROR** '	;73f1-7403

; BLOCK 'main' (start 0x7404 end 0x7798)
main_start:
	ld a,(07320h)		;7404	3a 20 73	:   s
	and 080h		;7407	e6 80		. .
	ld hl,08060h		;7409	21 60 80	! ` .
	or (hl)			;740c	b6		.
	ld (hl),a		;740d	77		w
	dec (hl)		;740e	35		5
	call sub_74cbh		;740f	cd cb 74	. . t
	ld hl,00000h		;7412	21 00 00	! . .
	ld (08065h),hl		;7415	22 65 80	" e .
	ld hl,07300h		;7418	21 00 73	! . s
	call 07425h		;741b	cd 25 74	. % t
	ld a,001h		;741e	3e 01		> .
	ld (08060h),a		;7420	32 60 80	2 ` .
	jp 01000h		;7423	c3 00 10	. . .
	ld a,000h		;7426	3e 00		> .
	ld (08069h),hl		;7428	22 69 80	" i .
	call sub_7721h		;742b	cd 21 77	. ! w
	jp c,072c4h		;742e	da c4 72	. . r
	jp z,07438h		;7431	ca 38 74	. 8 t
	ld a,006h		;7434	3e 06		> .
	jp 073c9h		;7436	c3 c9 73	. . s
	call sub_7481h		;7439	cd 81 74	. . t
	ld a,006h		;743c	3e 06		> .
	ld c,005h		;743e	0e 05		. .
	call sub_7583h		;7440	cd 83 75	. . u
	jp nc,0744ah		;7443	d2 4a 74	. J t
	ld a,028h		;7446	3e 28		> (
	jp 073c9h		;7448	c3 c9 73	. . s
	ld hl,(08067h)		;744b	2a 67 80	* g .
	ex de,hl		;744e	eb		.
	ld hl,(08065h)		;744f	2a 65 80	* e .
	add hl,de		;7452	19		.
	ld (08065h),hl		;7453	22 65 80	" e .
	ld l,000h		;7456	2e 00		. .
	ld h,l			;7458	65		e
	ld (08067h),hl		;7459	22 67 80	" g .
	call 07466h		;745c	cd 66 74	. f t
	ld a,(08061h)		;745f	3a 61 80	: a .
	or a			;7462	b7		.
	ret z			;7463	c8		.
	jp 0742ah		;7464	c3 2a 74	. * t
	ld a,001h		;7467	3e 01		> .
	ld (08034h),a		;7469	32 34 80	2 4 .
	ld a,(07320h)		;746c	3a 20 73	:   s
	and 002h		;746f	e6 02		. .
	rrca			;7471	0f		.
	ld hl,08033h		;7472	21 33 80	! 3 .
	cp (hl)			;7475	be		.
	jp z,l747ah		;7476	ca 7a 74	. z t
	inc (hl)		;7479	34		4
l747ah:
	ret			;747a	c9		.
	xor a			;747b	af		.
	ld (hl),a		;747c	77		w
	ld hl,08032h		;747d	21 32 80	! 2 .
	inc (hl)		;7480	34		4
sub_7481h:
	ret			;7481	c9		.
	ld hl,(08069h)		;7482	2a 69 80	* i .
	push hl			;7485	e5		.
	call sub_7547h		;7486	cd 47 75	. G u
	call sub_74aeh		;7489	cd ae 74	. . t
	pop de			;748c	d1		.
	add hl,de		;748d	19		.
	jp nc,l749eh		;748e	d2 9e 74	. . t
	ld a,h			;7491	7c		|
	or l			;7492	b5		.
	jp z,l749eh		;7493	ca 9e 74	. . t
	ld a,001h		;7496	3e 01		> .
	ld (08061h),a		;7498	32 61 80	2 a .
	ld (08069h),hl		;749b	22 69 80	" i .
l749eh:
	ret			;749e	c9		.
	ld a,000h		;749f	3e 00		> .
	ld (08061h),a		;74a1	32 61 80	2 a .
	ld (08069h),a		;74a4	32 69 80	2 i .
	ld (0806ah),a		;74a7	32 6a 80	2 j .
	ex de,hl		;74aa	eb		.
	ld (08067h),hl		;74ab	22 67 80	" g .
sub_74aeh:
	ret			;74ae	c9		.
	push af			;74af	f5		.
	ld a,l			;74b0	7d		}
	cpl			;74b1	2f		/
	ld l,a			;74b2	6f		o
	ld a,h			;74b3	7c		|
	cpl			;74b4	2f		/
	ld h,a			;74b5	67		g
	inc hl			;74b6	23		#
	pop af			;74b7	f1		.
sub_74b8h:
	ret			;74b8	c9		.
	ld a,(07320h)		;74b9	3a 20 73	:   s
	and 01ch		;74bc	e6 1c		. .
	rra			;74be	1f		.
	rra			;74bf	1f		.
	and 007h		;74c0	e6 07		. .
	ld (08035h),a		;74c2	32 35 80	2 5 .
	call sub_750ah		;74c5	cd 0a 75	. . u
	call sub_7547h		;74c8	cd 47 75	. G u
sub_74cbh:
	ret			;74cb	c9		.
	ld a,(07320h)		;74cc	3a 20 73	:   s
	and 0feh		;74cf	e6 fe		. .
	ld (07320h),a		;74d1	32 20 73	2   s
	call sub_7721h		;74d4	cd 21 77	. ! w
	jp nz,l7508h		;74d7	c2 08 75	. . u
	ld l,004h		;74da	2e 04		. .
	ld h,000h		;74dc	26 00		& .
	ld (08067h),hl		;74de	22 67 80	" g .
	ld a,00ah		;74e1	3e 0a		> .
	ld c,001h		;74e3	0e 01		. .
	call sub_7583h		;74e5	cd 83 75	. . u
	ld hl,07320h		;74e8	21 20 73	!   s
	jp nc,074f7h		;74eb	d2 f7 74	. . t
	ld a,(hl)		;74ee	7e		~
	and 001h		;74ef	e6 01		. .
	jp nz,l7508h		;74f1	c2 08 75	. . u
	inc (hl)		;74f4	34		4
	jp 074d3h		;74f5	c3 d3 74	. . t
	ld a,(08016h)		;74f8	3a 16 80	: . .
	rlca			;74fb	07		.
	rlca			;74fc	07		.
	ld b,a			;74fd	47		G
	ld a,(hl)		;74fe	7e		~
	and 0e3h		;74ff	e6 e3		. .
	add a,b			;7501	80		.
	ld (hl),a		;7502	77		w
	call sub_74b8h		;7503	cd b8 74	. . t
	scf			;7506	37		7
	ccf			;7507	3f		?
l7508h:
	ret			;7508	c9		.
	scf			;7509	37		7
sub_750ah:
	ret			;750a	c9		.
	ld a,(08035h)		;750b	3a 35 80	: 5 .
	rla			;750e	17		.
	rla			;750f	17		.
	ld e,a			;7510	5f		_
	ld d,000h		;7511	16 00		. .
	ld hl,072d6h		;7513	21 d6 72	! . r
	ld a,(07320h)		;7516	3a 20 73	:   s
	and 080h		;7519	e6 80		. .
	ld a,04ch		;751b	3e 4c		> L
	jp z,07524h		;751d	ca 24 75	. $ u
	ld a,023h		;7520	3e 23		> #
	ld hl,072e6h		;7522	21 e6 72	! . r
	ld (0800ch),a		;7525	32 0c 80	2 . .
	add hl,de		;7528	19		.
	ld a,(07320h)		;7529	3a 20 73	:   s
	and 001h		;752c	e6 01		. .
	jp z,l7535h		;752e	ca 35 75	. 5 u
	ld e,002h		;7531	1e 02		. .
	ld d,000h		;7533	16 00		. .
l7535h:
	add hl,de		;7535	19		.
	ex de,hl		;7536	eb		.
	ld hl,08036h		;7537	21 36 80	! 6 .
	ld a,(de)		;753a	1a		.
	ld (hl),a		;753b	77		w
	ld (0800dh),a		;753c	32 0d 80	2 . .
	inc hl			;753f	23		#
	inc de			;7540	13		.
	ld a,(de)		;7541	1a		.
	ld (hl),a		;7542	77		w
	inc hl			;7543	23		#
	ld a,080h		;7544	3e 80		> .
	ld (hl),a		;7546	77		w
sub_7547h:
	ret			;7547	c9		.
	ld hl,00080h		;7548	21 80 00	! . .
	ld a,(08035h)		;754b	3a 35 80	: 5 .
	or a			;754e	b7		.
	jp z,07556h		;754f	ca 56 75	. V u
	add hl,hl		;7552	29		)
	dec a			;7553	3d		=
	jp nz,07551h		;7554	c2 51 75	. Q u
	ld (08039h),hl		;7557	22 39 80	" 9 .
	ex de,hl		;755a	eb		.
	ld a,(08034h)		;755b	3a 34 80	: 4 .
	ld l,a			;755e	6f		o
	ld a,(08036h)		;755f	3a 36 80	: 6 .
	sub l			;7562	95		.
	inc a			;7563	3c		<
	ld l,a			;7564	6f		o
	ld a,(08060h)		;7565	3a 60 80	: ` .
	and 080h		;7568	e6 80		. .
	jp z,07576h		;756a	ca 76 75	. v u
	ld a,(08033h)		;756d	3a 33 80	: 3 .
	xor 001h		;7570	ee 01		. .
	jp nz,07576h		;7572	c2 76 75	. v u
	ld l,00ah		;7575	2e 0a		. .
	ld a,l			;7577	7d		}
	ld l,000h		;7578	2e 00		. .
l757ah:
	ld h,l			;757a	65		e
	add hl,de		;757b	19		.
	dec a			;757c	3d		=
	jp nz,l757ah		;757d	c2 7a 75	. z u
	ld (08067h),hl		;7580	22 67 80	" g .
sub_7583h:
	ret			;7583	c9		.
	push af			;7584	f5		.
	ld a,c			;7585	79		y
	ld (08062h),a		;7586	32 62 80	2 b .
	call sub_769dh		;7589	cd 9d 76	. . v
	ld hl,(08067h)		;758c	2a 67 80	* g .
	ld b,h			;758f	44		D
	ld c,l			;7590	4d		M
	dec bc			;7591	0b		.
	ld hl,(08065h)		;7592	2a 65 80	* e .
	pop af			;7595	f1		.
	push af			;7596	f5		.
	and 00fh		;7597	e6 0f		. .
	cp 00ah			;7599	fe 0a		. .
	call nz,sub_7632h	;759b	c4 32 76	. 2 v
	pop af			;759e	f1		.
	ld c,a			;759f	4f		O
	call sub_75ddh		;75a0	cd dd 75	. . u
	ld a,0ffh		;75a3	3e ff		> .
	call sub_76c3h		;75a5	cd c3 76	. . v
	ret c			;75a8	d8		.
	ld a,c			;75a9	79		y
	call 075b3h		;75aa	cd b3 75	. . u
	ret nc			;75ad	d0		.
	ret z			;75ae	c8		.
	ld a,c			;75af	79		y
	push af			;75b0	f5		.
	jp 07588h		;75b1	c3 88 75	. . u
	ld hl,08010h		;75b4	21 10 80	! . .
	ld a,(hl)		;75b7	7e		~
	and 0c3h		;75b8	e6 c3		. .
	ld b,a			;75ba	47		G
	ld a,(0801bh)		;75bb	3a 1b 80	: . .
	cp b			;75be	b8		.
	jp nz,l75d4h		;75bf	c2 d4 75	. . u
	inc hl			;75c2	23		#
	ld a,(hl)		;75c3	7e		~
	cp 000h			;75c4	fe 00		. .
	jp nz,l75d4h		;75c6	c2 d4 75	. . u
	inc hl			;75c9	23		#
	ld a,(hl)		;75ca	7e		~
	and 0bfh		;75cb	e6 bf		. .
	cp 000h			;75cd	fe 00		. .
	jp nz,l75d4h		;75cf	c2 d4 75	. . u
	scf			;75d2	37		7
	ccf			;75d3	3f		?
l75d4h:
	ret			;75d4	c9		.
	ld a,(08062h)		;75d5	3a 62 80	: b .
	dec a			;75d8	3d		=
	ld (08062h),a		;75d9	32 62 80	2 b .
	scf			;75dc	37		7
sub_75ddh:
	ret			;75dd	c9		.
	push bc			;75de	c5		.
	push af			;75df	f5		.
	di			;75e0	f3		.
	ld a,0ffh		;75e1	3e ff		> .
	ld hl,08030h		;75e3	21 30 80	! 0 .
	ld (0800bh),a		;75e6	32 0b 80	2 . .
	ld a,(07320h)		;75e9	3a 20 73	:   s
	and 001h		;75ec	e6 01		. .
	jp z,075f2h		;75ee	ca f2 75	. . u
	ld a,040h		;75f1	3e 40		> @
	ld b,a			;75f3	47		G
	pop af			;75f4	f1		.
	push af			;75f5	f5		.
	add a,b			;75f6	80		.
	ld (hl),a		;75f7	77		w
	inc hl			;75f8	23		#
	call sub_76a4h		;75f9	cd a4 76	. . v
	ld (hl),a		;75fc	77		w
	dec hl			;75fd	2b		+
	pop af			;75fe	f1		.
	and 00fh		;75ff	e6 0f		. .
	cp 006h			;7601	fe 06		. .
	ld c,009h		;7603	0e 09		. .
	jp z,07609h		;7605	ca 09 76	. . v
	ld c,002h		;7608	0e 02		. .
	ld a,(hl)		;760a	7e		~
	inc hl			;760b	23		#
	call 0763ch		;760c	cd 3c 76	. < v
	dec c			;760f	0d		.
	jp nz,07609h		;7610	c2 09 76	. . v
	pop bc			;7613	c1		.
	ei			;7614	fb		.
	ret			;7615	c9		.
	ld a,005h		;7616	3e 05		> .
	di			;7618	f3		.
	out (0fah),a		;7619	d3 fa		. .
	ld a,049h		;761b	3e 49		> I
	out (0fbh),a		;761d	d3 fb		. .
	out (0fch),a		;761f	d3 fc		. .
	ld a,l			;7621	7d		}
	out (0f2h),a		;7622	d3 f2		. .
	ld a,h			;7624	7c		|
	out (0f2h),a		;7625	d3 f2		. .
	ld a,c			;7627	79		y
	out (0f3h),a		;7628	d3 f3		. .
	ld a,b			;762a	78		x
	out (0f3h),a		;762b	d3 f3		. .
	ld a,001h		;762d	3e 01		> .
	out (0fah),a		;762f	d3 fa		. .
	ei			;7631	fb		.
sub_7632h:
	ret			;7632	c9		.
	ld a,005h		;7633	3e 05		> .
	di			;7635	f3		.
	out (0fah),a		;7636	d3 fa		. .
	ld a,045h		;7638	3e 45		> E
	jp 0761ch		;763a	c3 1c 76	. . v
	push af			;763d	f5		.
	push bc			;763e	c5		.
	ld b,000h		;763f	06 00		. .
	ld c,000h		;7641	0e 00		. .
	inc b			;7643	04		.
	call z,sub_766ah	;7644	cc 6a 76	. j v
	in a,(004h)		;7647	db 04		. .
	and 0c0h		;7649	e6 c0		. .
	cp 080h			;764b	fe 80		. .
	jp nz,07642h		;764d	c2 42 76	. B v
	pop bc			;7650	c1		.
	pop af			;7651	f1		.
	out (005h),a		;7652	d3 05		. .
sub_7654h:
	ret			;7654	c9		.
	push bc			;7655	c5		.
	ld b,000h		;7656	06 00		. .
	ld c,000h		;7658	0e 00		. .
	inc b			;765a	04		.
	call z,sub_766ah	;765b	cc 6a 76	. j v
	in a,(004h)		;765e	db 04		. .
	and 0c0h		;7660	e6 c0		. .
	cp 0c0h			;7662	fe c0		. .
	jp nz,07659h		;7664	c2 59 76	. Y v
	pop bc			;7667	c1		.
	in a,(005h)		;7668	db 05		. .
sub_766ah:
	ret			;766a	c9		.
	ld b,000h		;766b	06 00		. .
	inc c			;766d	0c		.
	ret nz			;766e	c0		.
	ei			;766f	fb		.
	jp 072c4h		;7670	c3 c4 72	. . r
	ld a,004h		;7673	3e 04		> .
	call 0763ch		;7675	cd 3c 76	. < v
	ld a,(0801bh)		;7678	3a 1b 80	: . .
	call 0763ch		;767b	cd 3c 76	. < v
	call sub_7654h		;767e	cd 54 76	. T v
	ld (08010h),a		;7681	32 10 80	2 . .
sub_7684h:
	ret			;7684	c9		.
	ld a,008h		;7685	3e 08		> .
	call 0763ch		;7687	cd 3c 76	. < v
	call sub_7654h		;768a	cd 54 76	. T v
	ld (08010h),a		;768d	32 10 80	2 . .
	and 0c0h		;7690	e6 c0		. .
	cp 080h			;7692	fe 80		. .
	jp z,0769ch		;7694	ca 9c 76	. . v
	call sub_7654h		;7697	cd 54 76	. T v
	ld (08011h),a		;769a	32 11 80	2 . .
sub_769dh:
	ret			;769d	c9		.
	di			;769e	f3		.
	xor a			;769f	af		.
	ld (08041h),a		;76a0	32 41 80	2 A .
	ei			;76a3	fb		.
sub_76a4h:
	ret			;76a4	c9		.
	push de			;76a5	d5		.
	ld a,(08033h)		;76a6	3a 33 80	: 3 .
	rla			;76a9	17		.
	rla			;76aa	17		.
	ld d,a			;76ab	57		W
	ld a,(0801bh)		;76ac	3a 1b 80	: . .
	add a,d			;76af	82		.
	pop de			;76b0	d1		.
sub_76b1h:
	ret			;76b1	c9		.
	push af			;76b2	f5		.
l76b3h:
	push hl			;76b3	e5		.
	ld h,c			;76b4	61		a
	ld l,0ffh		;76b5	2e ff		. .
	dec hl			;76b7	2b		+
	ld a,l			;76b8	7d		}
	or h			;76b9	b4		.
	jp nz,076b6h		;76ba	c2 b6 76	. . v
	dec b			;76bd	05		.
	jp nz,l76b3h		;76be	c2 b3 76	. . v
	pop hl			;76c1	e1		.
	pop af			;76c2	f1		.
sub_76c3h:
	ret			;76c3	c9		.
l76c4h:
	push bc			;76c4	c5		.
	dec a			;76c5	3d		=
	scf			;76c6	37		7
	jp z,076dfh		;76c7	ca df 76	. . v
	ld b,001h		;76ca	06 01		. .
	ld c,001h		;76cc	0e 01		. .
	call sub_76b1h		;76ce	cd b1 76	. . v
	ld b,a			;76d1	47		G
	ld a,(08041h)		;76d2	3a 41 80	: A .
	and 002h		;76d5	e6 02		. .
	ld a,b			;76d7	78		x
	jp z,l76c4h		;76d8	ca c4 76	. . v
	scf			;76db	37		7
	ccf			;76dc	3f		?
	call sub_769dh		;76dd	cd 9d 76	. . v
	pop bc			;76e0	c1		.
sub_76e1h:
	ret			;76e1	c9		.
	ld a,0ffh		;76e2	3e ff		> .
	call sub_76c3h		;76e4	cd c3 76	. . v
	ld a,(08010h)		;76e7	3a 10 80	: . .
	ld b,a			;76ea	47		G
	ld a,(08011h)		;76eb	3a 11 80	: . .
	ld c,a			;76ee	4f		O
sub_76efh:
	ret			;76ef	c9		.
	ld a,007h		;76f0	3e 07		> .
	call 0763ch		;76f2	cd 3c 76	. < v
	ld a,(0801bh)		;76f5	3a 1b 80	: . .
	call 0763ch		;76f8	cd 3c 76	. < v
sub_76fbh:
	ret			;76fb	c9		.
	ld a,00fh		;76fc	3e 0f		> .
	call 0763ch		;76fe	cd 3c 76	. < v
	ld a,d			;7701	7a		z
	and 007h		;7702	e6 07		. .
	call 0763ch		;7704	cd 3c 76	. < v
	ld a,e			;7707	7b		{
	call 0763ch		;7708	cd 3c 76	. < v
	ret			;770b	c9		.
	call sub_76efh		;770c	cd ef 76	. . v
	call sub_76e1h		;770f	cd e1 76	. . v
	ret c			;7712	d8		.
	ld a,(0801bh)		;7713	3a 1b 80	: . .
	add a,020h		;7716	c6 20		.  
	cp b			;7718	b8		.
	jp nz,0771eh		;7719	c2 1e 77	. . w
	ld a,c			;771c	79		y
	cp 000h			;771d	fe 00		. .
	scf			;771f	37		7
	ccf			;7720	3f		?
sub_7721h:
	ret			;7721	c9		.
	ld a,(08032h)		;7722	3a 32 80	: 2 .
	ld e,a			;7725	5f		_
	call sub_76a4h		;7726	cd a4 76	. . v
	ld d,a			;7729	57		W
	call sub_76fbh		;772a	cd fb 76	. . v
	call sub_76e1h		;772d	cd e1 76	. . v
	ret c			;7730	d8		.
	ld a,(0801bh)		;7731	3a 1b 80	: . .
	add a,020h		;7734	c6 20		.  
	cp b			;7736	b8		.
	jp nz,l773dh		;7737	c2 3d 77	. = w
	ld a,(08032h)		;773a	3a 32 80	: 2 .
l773dh:
	cp c			;773d	b9		.
	scf			;773e	37		7
	ccf			;773f	3f		?
sub_7740h:
	ret			;7740	c9		.
	ld hl,08010h		;7741	21 10 80	! . .
	ld b,007h		;7744	06 07		. .
	ld a,b			;7746	78		x
	ld (0800bh),a		;7747	32 0b 80	2 . .
	call sub_7654h		;774a	cd 54 76	. T v
	ld (hl),a		;774d	77		w
	inc hl			;774e	23		#
	ld a,(0801dh)		;774f	3a 1d 80	: . .
	dec a			;7752	3d		=
	jp nz,07751h		;7753	c2 51 77	. Q w
	in a,(004h)		;7756	db 04		. .
	and 010h		;7758	e6 10		. .
	jp z,07765h		;775a	ca 65 77	. e w
	dec b			;775d	05		.
	jp nz,07749h		;775e	c2 49 77	. I w
	ld a,0feh		;7761	3e fe		> .
	jp 073c9h		;7763	c3 c9 73	. . s
	in a,(0f8h)		;7766	db f8		. .
	ld (hl),a		;7768	77		w
	dec b			;7769	05		.
	ret z			;776a	c8		.
	ei			;776b	fb		.
	ld a,0fdh		;776c	3e fd		> .
	jp 073c9h		;776e	c3 c9 73	. . s
	push af			;7771	f5		.
	push bc			;7772	c5		.
	push hl			;7773	e5		.
	ld a,002h		;7774	3e 02		> .
	ld (08041h),a		;7776	32 41 80	2 A .
	ld a,(0801ch)		;7779	3a 1c 80	: . .
	dec a			;777c	3d		=
	jp nz,0777bh		;777d	c2 7b 77	. { w
	in a,(004h)		;7780	db 04		. .
	and 010h		;7782	e6 10		. .
	jp nz,0778ch		;7784	c2 8c 77	. . w
	call sub_7684h		;7787	cd 84 76	. . v
	jp 0778fh		;778a	c3 8f 77	. . w
	call sub_7740h		;778d	cd 40 77	. @ w
	pop hl			;7790	e1		.
	pop bc			;7791	c1		.
	pop af			;7792	f1		.
	ei			;7793	fb		.
	reti			;7794	ed 4d		. M
	nop			;7796	00		.
main_last:
	nop			;7797	00		.
