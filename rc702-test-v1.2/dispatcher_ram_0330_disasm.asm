; z80dasm 1.2.0
; command line: z80dasm -a -l -t -g 0x0330 -o /tmp/rc702_ram_0330.asm /tmp/rc702_ram_0330.bin

	org 00330h

	ld d,b			;0330	50		P
	cp 000h			;0331	fe 00		. .
	ret z			;0333	c8		.
	ld a,(0ffffh)		;0334	3a ff ff	: . .
	bit 7,a			;0337	cb 7f		. .
	ret nz			;0339	c0		.
	di			;033a	f3		.
	ld hl,002a2h		;033b	21 a2 02	! . .
	call 0031fh		;033e	cd 1f 03	. . .
l0341h:
	halt			;0341	76		v
	jr l0341h		;0342	18 fd		. .
	ei			;0344	fb		.
sub_0345h:
	reti			;0345	ed 4d		. M
	push af			;0347	f5		.
	push bc			;0348	c5		.
	push de			;0349	d5		.
	push hl			;034a	e5		.
	push iy			;034b	fd e5		. .
	push ix			;034d	dd e5		. .
	ld ix,(0fffch)		;034f	dd 2a fc ff	. * . .
	push ix			;0353	dd e5		. .
	ld a,(0ffffh)		;0355	3a ff ff	: . .
	push af			;0358	f5		.
	set 5,a			;0359	cb ef		. .
	ld (0ffffh),a		;035b	32 ff ff	2 . .
	ld hl,002b6h		;035e	21 b6 02	! . .
	ld ix,0f0abh		;0361	dd 21 ab f0	. ! . .
	call 01161h		;0365	cd 61 11	. a .
l0368h:
	in a,(010h)		;0368	db 10		. .
	cp 01bh			;036a	fe 1b		. .
	jr nz,l03b5h		;036c	20 47		  G
l036eh:
	ld hl,00292h		;036e	21 92 02	! . .
	call 0031fh		;0371	cd 1f 03	. . .
	in a,(010h)		;0374	db 10		. .
	cp 00dh			;0376	fe 0d		. .
	jr nz,l0368h		;0378	20 ee		  .
	ld ix,0f0cfh		;037a	dd 21 cf f0	. ! . .
	ld b,02ah		;037e	06 2a		. *
	ld (ix+000h),b		;0380	dd 70 00	. p .
	call sub_0345h		;0383	cd 45 03	. E .
	jp 00407h		;0386	c3 07 04	. . .
l0389h:
	ld c,b			;0389	48		H
	ld d,d			;038a	52		R
	ld c,h			;038b	4c		L
	ld b,a			;038c	47		G
	ld d,e			;038d	53		S
	ld d,b			;038e	50		P
	ld b,(hl)		;038f	46		F
	ld b,l			;0390	45		E
	ld b,h			;0391	44		D
	ld b,e			;0392	43		C
	ld b,d			;0393	42		B
	ld b,c			;0394	41		A
	add hl,sp		;0395	39		9
	jr c,$+57		;0396	38 37		8 7
	ld (hl),035h		;0398	36 35		6 5
	inc (hl)		;039a	34		4
	inc sp			;039b	33		3
	ld (03031h),a		;039c	32 31 30	2 1 0
l039fh:
	jr nc,$+51		;039f	30 31		0 1
	ld (03433h),a		;03a1	32 33 34	2 3 4
	dec (hl)		;03a4	35		5
	ld (hl),037h		;03a5	36 37		6 7
	jr c,$+59		;03a7	38 39		8 9
	ld b,c			;03a9	41		A
	ld b,d			;03aa	42		B
	ld b,e			;03ab	43		C
	ld b,h			;03ac	44		D
	ld b,l			;03ad	45		E
	ld b,(hl)		;03ae	46		F
	ld d,b			;03af	50		P
	ld d,e			;03b0	53		S
	ld b,a			;03b1	47		G
	ld c,h			;03b2	4c		L
	ld d,d			;03b3	52		R
	ld c,b			;03b4	48		H
l03b5h:
	ld ix,0f0cfh		;03b5	dd 21 cf f0	. ! . .
	ld hl,l0389h		;03b9	21 89 03	! . .
	ld bc,00016h		;03bc	01 16 00	. . .
	cpir			;03bf	ed b1		. .
	jr nz,l036eh		;03c1	20 ab		  .
	ld hl,l039fh		;03c3	21 9f 03	! . .
	add hl,bc		;03c6	09		.
	ld a,(hl)		;03c7	7e		~
	ld (ix+000h),a		;03c8	dd 77 00	. w .
	ld a,00fh		;03cb	3e 0f		> .
	cp c			;03cd	b9		.
	jr c,l03dbh		;03ce	38 0b		8 .
	ld a,(0ffffh)		;03d0	3a ff ff	: . .
	and 0f0h		;03d3	e6 f0		. .
	or c			;03d5	b1		.
	ld (0ffffh),a		;03d6	32 ff ff	2 . .
	jr l036eh		;03d9	18 93		. .
l03dbh:
	ld a,c			;03db	79		y
	ld hl,0ffffh		;03dc	21 ff ff	! . .
	cp 010h			;03df	fe 10		. .
	jr nz,l03e5h		;03e1	20 02		  .
	res 4,(hl)		;03e3	cb a6		. .
l03e5h:
	cp 011h			;03e5	fe 11		. .
	jr nz,l03ebh		;03e7	20 02		  .
	set 4,(hl)		;03e9	cb e6		. .
l03ebh:
	cp 012h			;03eb	fe 12		. .
	jr nz,l03f1h		;03ed	20 02		  .
	res 6,(hl)		;03ef	cb b6		. .
l03f1h:
	cp 013h			;03f1	fe 13		. .
	jr nz,l03f7h		;03f3	20 02		  .
	set 6,(hl)		;03f5	cb f6		. .
l03f7h:
	cp 014h			;03f7	fe 14		. .
	jr nz,l03fdh		;03f9	20 02		  .
	set 7,(hl)		;03fb	cb fe		. .
l03fdh:
	cp 015h			;03fd	fe 15		. .
	defb 0c2h		;03ff	c2		.
