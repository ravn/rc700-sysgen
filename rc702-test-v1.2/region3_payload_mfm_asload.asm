; z80dasm 1.2.0
; command line: z80dasm -a -l -t -g 0x1800 -o region3_payload_mfm.asm region3_payload_mfm.bin

	org 01800h

	xor a			;1800	af		.
	ld (0ffffh),a		;1801	32 ff ff	2 . .
	di			;1804	f3		.
	out (001h),a		;1805	d3 01		. .
	ld sp,(0ffffh)		;1807	ed 7b ff ff	. { . .
	out (0fdh),a		;180b	d3 fd		. .
	ld a,018h		;180d	3e 18		> .
	out (00ah),a		;180f	d3 0a		. .
	out (00bh),a		;1811	d3 0b		. .
	ld a,003h		;1813	3e 03		> .
l1815h:
	out (00ch),a		;1815	d3 0c		. .
	out (00dh),a		;1817	d3 0d		. .
l1819h:
	out (00eh),a		;1819	d3 0e		. .
	out (00fh),a		;181b	d3 0f		. .
	im 2			;181d	ed 5e		. ^
	ld a,000h		;181f	3e 00		> .
	out (001h),a		;1821	d3 01		. .
	ld a,04fh		;1823	3e 4f		> O
	out (000h),a		;1825	d3 00		. .
	ld a,098h		;1827	3e 98		> .
	out (000h),a		;1829	d3 00		. .
	ld a,09ah		;182b	3e 9a		> .
	out (000h),a		;182d	d3 00		. .
	ld a,05dh		;182f	3e 5d		> ]
	out (000h),a		;1831	d3 00		. .
	ld a,080h		;1833	3e 80		> .
	out (001h),a		;1835	d3 01		. .
	ld a,051h		;1837	3e 51		> Q
	out (000h),a		;1839	d3 00		. .
l183bh:
	ld a,01ah		;183b	3e 1a		> .
	out (000h),a		;183d	d3 00		. .
	out (0fdh),a		;183f	d3 fd		. .
	ld a,020h		;1841	3e 20		>  
	out (0f8h),a		;1843	d3 f8		. .
	ld a,05ah		;1845	3e 5a		> Z
	out (0fbh),a		;1847	d3 fb		. .
	ld a,000h		;1849	3e 00		> .
	out (0f4h),a		;184b	d3 f4		. .
	ld a,0f0h		;184d	3e f0		> .
	out (0f4h),a		;184f	d3 f4		. .
	ld a,0cfh		;1851	3e cf		> .
	out (0f5h),a		;1853	d3 f5		. .
	ld a,007h		;1855	3e 07		> .
	out (0f5h),a		;1857	d3 f5		. .
	ld a,020h		;1859	3e 20		>  
	out (001h),a		;185b	d3 01		. .
	in a,(001h)		;185d	db 01		. .
l185fh:
	in a,(001h)		;185f	db 01		. .
	bit 5,a			;1861	cb 6f		. o
	jr z,l185fh		;1863	28 fa		( .
l1865h:
	ld a,00bh		;1865	3e 0b		> .
	out (0ffh),a		;1867	d3 ff		. .
	jp 00088h		;1869	c3 88 00	. . .
	ld hl,06000h		;186c	21 00 60	! . `
	xor a			;186f	af		.
	ex af,af'		;1870	08		.
	xor a			;1871	af		.
l1872h:
	ex af,af'		;1872	08		.
	dec hl			;1873	2b		+
	adc a,(hl)		;1874	8e		.
	ex af,af'		;1875	08		.
	cp h			;1876	bc		.
	jr nz,l1872h		;1877	20 f9		  .
	cp l			;1879	bd		.
	jr nz,l1872h		;187a	20 f6		  .
	ex af,af'		;187c	08		.
	cp 0ffh			;187d	fe ff		. .
	jr z,l1888h		;187f	28 07		( .
	ld a,001h		;1881	3e 01		> .
	jp 00155h		;1883	c3 55 01	. U .
l1886h:
	out (019h),a		;1886	d3 19		. .
l1888h:
	xor a			;1888	af		.
	ld c,a			;1889	4f		O
	ld de,00000h		;188a	11 00 00	. . .
l188dh:
	ex af,af'		;188d	08		.
	ld b,004h		;188e	06 04		. .
	ld hl,06000h		;1890	21 00 60	! . `
l1893h:
	ex af,af'		;1893	08		.
l1894h:
	djnz l1899h		;1894	10 03		. .
	ld b,003h		;1896	06 03		. .
	cpl			;1898	2f		/
l1899h:
	bit 0,c			;1899	cb 41		. A
	jr nz,l18a0h		;189b	20 03		  .
	ld (hl),a		;189d	77		w
	jr l18a7h		;189e	18 07		. .
l18a0h:
	ld i,a			;18a0	ed 47		. G
	xor (hl)		;18a2	ae		.
	jr nz,l191bh		;18a3	20 76		  v
	ld a,i			;18a5	ed 57		. W
l18a7h:
	ex af,af'		;18a7	08		.
l18a8h:
	inc hl			;18a8	23		#
	ld a,h			;18a9	7c		|
	cp d			;18aa	ba		.
	jr nz,l1893h		;18ab	20 e6		  .
	ld a,l			;18ad	7d		}
	cp e			;18ae	bb		.
	jr nz,l1893h		;18af	20 e2		  .
	inc c			;18b1	0c		.
	bit 1,c			;18b2	cb 49		. I
l18b4h:
	jr nz,l18beh		;18b4	20 08		  .
	bit 2,c			;18b6	cb 51		. Q
	jr nz,l18c3h		;18b8	20 09		  .
	ex af,af'		;18ba	08		.
	xor a			;18bb	af		.
	jr l188dh		;18bc	18 cf		. .
l18beh:
	ex af,af'		;18be	08		.
	xor a			;18bf	af		.
	cpl			;18c0	2f		/
l18c1h:
	jr l188dh		;18c1	18 ca		. .
l18c3h:
	ld a,0afh		;18c3	3e af		> .
l18c5h:
	ld hl,06000h		;18c5	21 00 60	! . `
	cp (hl)			;18c8	be		.
l18c9h:
	jr z,l18f2h		;18c9	28 27		( '
	ld hl,00000h		;18cb	21 00 00	! . .
	ld de,06000h		;18ce	11 00 60	. . `
	ld bc,06000h		;18d1	01 00 60	. . `
	ldir			;18d4	ed b0		. .
	ld iy,l608ah		;18d6	fd 21 8a 60	. ! . `
	ld hl,06000h		;18da	21 00 60	! . `
	ld (iy+001h),l		;18dd	fd 75 01	. u .
	ld (iy+002h),h		;18e0	fd 74 02	. t .
	ld iy,06090h		;18e3	fd 21 90 60	. ! . `
	ld (iy+001h),000h	;18e7	fd 36 01 00	. 6 . .
	ld (iy+002h),000h	;18eb	fd 36 02 00	. 6 . .
	jp 06086h		;18ef	c3 86 60	. . `
l18f2h:
	ld hl,06000h		;18f2	21 00 60	! . `
	ld de,00000h		;18f5	11 00 00	. . .
	ld bc,06000h		;18f8	01 00 60	. . `
	ldir			;18fb	ed b0		. .
	ld iy,0008ah		;18fd	fd 21 8a 00	. ! . .
	ld hl,00000h		;1901	21 00 00	! . .
	ld (iy+001h),l		;1904	fd 75 01	. u .
	ld (iy+002h),h		;1907	fd 74 02	. t .
	ld iy,00090h		;190a	fd 21 90 00	. ! . .
	ld hl,06000h		;190e	21 00 60	! . `
	ld (iy+001h),l		;1911	fd 75 01	. u .
	ld (iy+002h),h		;1914	fd 74 02	. t .
	xor a			;1917	af		.
	jp 00155h		;1918	c3 55 01	. U .
l191bh:
	ld b,a			;191b	47		G
	ld a,i			;191c	ed 57		. W
	ld e,a			;191e	5f		_
	xor b			;191f	a8		.
	ld d,a			;1920	57		W
	ld a,002h		;1921	3e 02		> .
	jp 00155h		;1923	c3 55 01	. U .
l1926h:
	ld hl,l37dbh+1		;1926	21 dc 37	! . 7
l1929h:
	in a,(0f8h)		;1929	db f8		. .
	rra			;192b	1f		.
	jr c,l1933h		;192c	38 05		8 .
	dec hl			;192e	2b		+
	ld a,l			;192f	7d		}
	or h			;1930	b4		.
	jr nz,l1929h		;1931	20 f6		  .
l1933h:
	jp (iy)			;1933	fd e9		. .
l1935h:
	ld bc,007d0h		;1935	01 d0 07	. . .
	ld hl,0f000h		;1938	21 00 f0	! . .
	ld (hl),020h		;193b	36 20		6  
	ld de,0f001h		;193d	11 01 f0	. . .
	ldir			;1940	ed b0		. .
	jp (iy)			;1942	fd e9		. .
	ld l,l			;1944	6d		m
	ld h,l			;1945	65		e
sub_1946h:
	ld l,l			;1946	6d		m
	jr nz,l19aeh		;1947	20 65		  e
	ld (hl),d		;1949	72		r
	ld (hl),d		;194a	72		r
	ld h,e			;194b	63		c
	ld l,b			;194c	68		h
	ld l,e			;194d	6b		k
	ld (hl),e		;194e	73		s
	ld (hl),l		;194f	75		u
	ld l,l			;1950	6d		m
	jr nz,$+103		;1951	20 65		  e
	ld (hl),d		;1953	72		r
	ld (hl),d		;1954	72		r
	ld i,a			;1955	ed 47		. G
	exx			;1957	d9		.
	ld iy,0015eh		;1958	fd 21 5e 01	. ! ^ .
	jr l1926h		;195c	18 c8		. .
	ld iy,00164h		;195e	fd 21 64 01	. ! d .
	jr l1935h		;1962	18 d1		. .
	ld de,002dbh		;1964	11 db 02	. . .
	ld ix,0f000h		;1967	dd 21 00 f0	. ! . .
	ld b,011h		;196b	06 11		. .
	ld iy,0017fh		;196d	fd 21 7f 01	. ! . .
	jp 00174h		;1971	c3 74 01	. t .
l1974h:
	ld a,(de)		;1974	1a		.
	ld (ix+000h),a		;1975	dd 77 00	. w .
	inc de			;1978	13		.
	inc ix			;1979	dd 23		. #
	djnz l1974h		;197b	10 f7		. .
	jp (iy)			;197d	fd e9		. .
	ld a,006h		;197f	3e 06		> .
	out (0fah),a		;1981	d3 fa		. .
	in a,(001h)		;1983	db 01		. .
l1985h:
	in a,(001h)		;1985	db 01		. .
	bit 5,a			;1987	cb 6f		. o
	jr z,l1985h		;1989	28 fa		( .
	ld a,002h		;198b	3e 02		> .
	out (0fah),a		;198d	d3 fa		. .
	ld iy,001cah		;198f	fd 21 ca 01	. ! . .
	ld a,i			;1993	ed 57		. W
	cp 000h			;1995	fe 00		. .
	jr z,l19cah		;1997	28 31		( 1
	ld de,0014bh		;1999	11 4b 01	. K .
	ld b,00ah		;199c	06 0a		. .
	bit 0,a			;199e	cb 47		. G
	jr nz,l1974h		;19a0	20 d2		  .
	ld de,00144h		;19a2	11 44 01	. D .
	ld b,007h		;19a5	06 07		. .
	ld iy,001adh		;19a7	fd 21 ad 01	. ! . .
	jr l1974h		;19ab	18 c7		. .
	exx			;19ad	d9		.
l19aeh:
	ld a,h			;19ae	7c		|
	ld iy,001b5h		;19af	fd 21 b5 01	. ! . .
	jr l19d3h		;19b3	18 1e		. .
	ld a,l			;19b5	7d		}
	ld iy,001bch		;19b6	fd 21 bc 01	. ! . .
	jr l19d3h		;19ba	18 17		. .
	ld a,e			;19bc	7b		{
	ld iy,001c3h		;19bd	fd 21 c3 01	. ! . .
	jr l19d3h		;19c1	18 10		. .
	ld a,d			;19c3	7a		z
	ld iy,001cah		;19c4	fd 21 ca 01	. ! . .
sub_19c8h:
	jr l19d3h		;19c8	18 09		. .
l19cah:
	ld (0ffffh),sp		;19ca	ed 73 ff ff	. s . .
	ld a,i			;19ce	ed 57		. W
	jp 00470h		;19d0	c3 70 04	. p .
l19d3h:
	ld b,003h		;19d3	06 03		. .
	ld c,a			;19d5	4f		O
	rlca			;19d6	07		.
	rlca			;19d7	07		.
	rlca			;19d8	07		.
	rlca			;19d9	07		.
l19dah:
	inc ix			;19da	dd 23		. #
	djnz l19e0h		;19dc	10 02		. .
	jp (iy)			;19de	fd e9		. .
l19e0h:
	and 00fh		;19e0	e6 0f		. .
	cp 00ah			;19e2	fe 0a		. .
	jr nc,l19eah		;19e4	30 04		0 .
	add a,030h		;19e6	c6 30		. 0
	jr l19ech		;19e8	18 02		. .
l19eah:
	add a,037h		;19ea	c6 37		. 7
l19ech:
	ld (ix+000h),a		;19ec	dd 77 00	. w .
	ld a,c			;19ef	79		y
	jr l19dah		;19f0	18 e8		. .
	nop			;19f2	00		.
	nop			;19f3	00		.
	nop			;19f4	00		.
	nop			;19f5	00		.
	nop			;19f6	00		.
	nop			;19f7	00		.
	nop			;19f8	00		.
	nop			;19f9	00		.
	nop			;19fa	00		.
	nop			;19fb	00		.
	nop			;19fc	00		.
	nop			;19fd	00		.
	nop			;19fe	00		.
	nop			;19ff	00		.
	rrca			;1a00	0f		.
	rra			;1a01	1f		.
sub_1a02h:
	add hl,bc		;1a02	09		.
	dec de			;1a03	1b		.
	djnz $+31		;1a04	10 1d		. .
	ld de,l1819h		;1a06	11 19 18	. . .
	reti			;1a09	ed 4d		. M
l1a0bh:
	ld (0fffeh),a		;1a0b	32 fe ff	2 . .
l1a0eh:
	ld a,(0ffc0h)		;1a0e	3a c0 ff	: . .
	call 00d7fh		;1a11	cd 7f 0d	. . .
	call 01161h		;1a14	cd 61 11	. a .
l1a17h:
	pop hl			;1a17	e1		.
	pop de			;1a18	d1		.
	pop bc			;1a19	c1		.
	pop af			;1a1a	f1		.
	reti			;1a1b	ed 4d		. M
	ld a,007h		;1a1d	3e 07		> .
	call 00c66h		;1a1f	cd 66 0c	. f .
	jp nz,00d6eh		;1a22	c2 6e 0d	. n .
	ld a,b			;1a25	78		x
	call 00c66h		;1a26	cd 66 0c	. f .
	jp nz,00d6eh		;1a29	c2 6e 0d	. n .
	ret			;1a2c	c9		.
	ld a,b			;1a2d	78		x
	bit 3,a			;1a2e	cb 5f		. _
	jp nz,00ba8h		;1a30	c2 a8 0b	. . .
	bit 7,a			;1a33	cb 7f		. .
	jp nz,00aadh		;1a35	c2 ad 0a	. . .
	bit 6,a			;1a38	cb 77		. w
	jr nz,l1a5ch		;1a3a	20 20		   
	bit 5,a			;1a3c	cb 6f		. o
	jr nz,l1a56h		;1a3e	20 16		  .
l1a40h:
	ld hl,008deh		;1a40	21 de 08	! . .
	ld ix,(0fffch)		;1a43	dd 2a fc ff	. * . .
	push af			;1a47	f5		.
	call 01161h		;1a48	cd 61 11	. a .
	pop af			;1a4b	f1		.
	call 01180h		;1a4c	cd 80 11	. . .
	ld a,031h		;1a4f	3e 31		> 1
	ld (0fffeh),a		;1a51	32 fe ff	2 . .
	jr l1a17h		;1a54	18 c1		. .
l1a56h:
	pop hl			;1a56	e1		.
	pop de			;1a57	d1		.
	pop bc			;1a58	c1		.
	pop af			;1a59	f1		.
	reti			;1a5a	ed 4d		. M
l1a5ch:
	bit 5,a			;1a5c	cb 6f		. o
	jr nz,l1a67h		;1a5e	20 07		  .
	ld hl,00910h		;1a60	21 10 09	! . .
	ld a,035h		;1a63	3e 35		> 5
	jr l1a0bh		;1a65	18 a4		. .
l1a67h:
	bit 4,a			;1a67	cb 67		. g
	jr nz,l1a6dh		;1a69	20 02		  .
	jr l1a40h		;1a6b	18 d3		. .
l1a6dh:
	ld hl,00922h		;1a6d	21 22 09	! " .
	ld a,036h		;1a70	3e 36		> 6
	jr l1a0bh		;1a72	18 97		. .
	ld a,00fh		;1a74	3e 0f		> .
	call 00c66h		;1a76	cd 66 0c	. f .
	jp nz,00d6eh		;1a79	c2 6e 0d	. n .
	ld a,b			;1a7c	78		x
	call 00c66h		;1a7d	cd 66 0c	. f .
	jp nz,00d6eh		;1a80	c2 6e 0d	. n .
	ld a,c			;1a83	79		y
	call 00c66h		;1a84	cd 66 0c	. f .
	jp nz,00d6eh		;1a87	c2 6e 0d	. n .
	ret			;1a8a	c9		.
sub_1a8bh:
	ld a,b			;1a8b	78		x
	bit 3,a			;1a8c	cb 5f		. _
	jp nz,00ba8h		;1a8e	c2 a8 0b	. . .
	bit 7,a			;1a91	cb 7f		. .
	jr nz,l1aadh		;1a93	20 18		  .
	bit 6,a			;1a95	cb 77		. w
	jr nz,l1aa0h		;1a97	20 07		  .
	bit 5,a			;1a99	cb 6f		. o
	jr nz,l1a56h		;1a9b	20 b9		  .
	jp 00a40h		;1a9d	c3 40 0a	. @ .
l1aa0h:
	bit 5,a			;1aa0	cb 6f		. o
	jp nz,00a40h		;1aa2	c2 40 0a	. @ .
	ld hl,008edh		;1aa5	21 ed 08	! . .
	ld a,032h		;1aa8	3e 32		> 2
	jp 00a0bh		;1aaa	c3 0b 0a	. . .
l1aadh:
	bit 6,a			;1aad	cb 77		. w
	jr nz,l1ab9h		;1aaf	20 08		  .
	ld hl,008f8h		;1ab1	21 f8 08	! . .
	ld a,033h		;1ab4	3e 33		> 3
	jp 00a0bh		;1ab6	c3 0b 0a	. . .
l1ab9h:
	ld hl,00906h		;1ab9	21 06 09	! . .
	ld a,034h		;1abc	3e 34		> 4
	jp 00a0bh		;1abe	c3 0b 0a	. . .
	ld a,046h		;1ac1	3e 46		> F
	call 00c66h		;1ac3	cd 66 0c	. f .
	jp nz,00d6eh		;1ac6	c2 6e 0d	. n .
	ld a,b			;1ac9	78		x
	call 00c66h		;1aca	cd 66 0c	. f .
	jp nz,00d6eh		;1acd	c2 6e 0d	. n .
	ld a,c			;1ad0	79		y
	call 00c66h		;1ad1	cd 66 0c	. f .
	jp nz,00d6eh		;1ad4	c2 6e 0d	. n .
	ld a,d			;1ad7	7a		z
	call 00c66h		;1ad8	cd 66 0c	. f .
	jp nz,00d6eh		;1adb	c2 6e 0d	. n .
	ld a,e			;1ade	7b		{
	call 00c66h		;1adf	cd 66 0c	. f .
	jp nz,00d6eh		;1ae2	c2 6e 0d	. n .
	ld a,002h		;1ae5	3e 02		> .
	call 00c66h		;1ae7	cd 66 0c	. f .
	jp nz,00d6eh		;1aea	c2 6e 0d	. n .
	ld a,00fh		;1aed	3e 0f		> .
	call 00c66h		;1aef	cd 66 0c	. f .
	jp nz,00d6eh		;1af2	c2 6e 0d	. n .
	ld a,01bh		;1af5	3e 1b		> .
	call 00c66h		;1af7	cd 66 0c	. f .
	jp nz,00d6eh		;1afa	c2 6e 0d	. n .
	ld a,0ffh		;1afd	3e ff		> .
	call 00c66h		;1aff	cd 66 0c	. f .
	jp nz,00d6eh		;1b02	c2 6e 0d	. n .
	ret			;1b05	c9		.
	ld a,(0ffe2h)		;1b06	3a e2 ff	: . .
	bit 7,a			;1b09	cb 7f		. .
	jp nz,00bb0h		;1b0b	c2 b0 0b	. . .
	bit 6,a			;1b0e	cb 77		. w
	jr nz,l1b18h		;1b10	20 06		  .
	pop hl			;1b12	e1		.
	pop de			;1b13	d1		.
	pop bc			;1b14	c1		.
	pop af			;1b15	f1		.
	reti			;1b16	ed 4d		. M
l1b18h:
	bit 3,a			;1b18	cb 5f		. _
	jp nz,00ba8h		;1b1a	c2 a8 0b	. . .
	ld bc,0ffe2h		;1b1d	01 e2 ff	. . .
	dec bc			;1b20	0b		.
	ld a,(bc)		;1b21	0a		.
	cp 000h			;1b22	fe 00		. .
	jr nz,l1b43h		;1b24	20 1d		  .
l1b26h:
	dec bc			;1b26	0b		.
	ld a,(bc)		;1b27	0a		.
	bit 4,a			;1b28	cb 67		. g
sub_1b2ah:
	jr nz,l1b3bh		;1b2a	20 0f		  .
	bit 1,a			;1b2c	cb 4f		. O
	jr nz,l1b33h		;1b2e	20 03		  .
	jp 00a40h		;1b30	c3 40 0a	. @ .
l1b33h:
	ld hl,00953h		;1b33	21 53 09	! S .
	ld a,038h		;1b36	3e 38		> 8
	jp 00a0bh		;1b38	c3 0b 0a	. . .
l1b3bh:
	ld hl,00960h		;1b3b	21 60 09	! ` .
	ld a,039h		;1b3e	3e 39		> 9
	jp 00a0bh		;1b40	c3 0b 0a	. . .
l1b43h:
	bit 7,a			;1b43	cb 7f		. .
	jp nz,00ba0h		;1b45	c2 a0 0b	. . .
	bit 5,a			;1b48	cb 6f		. o
	jr nz,l1b8ah		;1b4a	20 3e		  >
	bit 4,a			;1b4c	cb 67		. g
	jr nz,l1b82h		;1b4e	20 32		  2
	bit 2,a			;1b50	cb 57		. W
	jr nz,l1b7ah		;1b52	20 26		  &
	bit 1,a			;1b54	cb 4f		. O
	jr z,l1b60h		;1b56	28 08		( .
	ld hl,008c8h		;1b58	21 c8 08	! . .
	ld a,041h		;1b5b	3e 41		> A
	jp 00a0bh		;1b5d	c3 0b 0a	. . .
l1b60h:
	bit 0,a			;1b60	cb 47		. G
	jr z,l1b26h		;1b62	28 c2		( .
	dec bc			;1b64	0b		.
	ld a,(bc)		;1b65	0a		.
	bit 0,a			;1b66	cb 47		. G
	jr nz,l1b72h		;1b68	20 08		  .
	ld hl,0096fh		;1b6a	21 6f 09	! o .
	ld a,03ah		;1b6d	3e 3a		> :
	jp 00a0bh		;1b6f	c3 0b 0a	. . .
l1b72h:
	ld hl,00934h		;1b72	21 34 09	! 4 .
	ld a,037h		;1b75	3e 37		> 7
	jp 00a0bh		;1b77	c3 0b 0a	. . .
l1b7ah:
	ld hl,0098dh		;1b7a	21 8d 09	! . .
	ld a,03bh		;1b7d	3e 3b		> ;
	jp 00a0bh		;1b7f	c3 0b 0a	. . .
l1b82h:
	ld hl,009c7h		;1b82	21 c7 09	! . .
	ld a,03fh		;1b85	3e 3f		> ?
	jp 00a0bh		;1b87	c3 0b 0a	. . .
l1b8ah:
	dec bc			;1b8a	0b		.
	ld a,(bc)		;1b8b	0a		.
	bit 5,a			;1b8c	cb 6f		. o
	jr nz,l1b98h		;1b8e	20 08		  .
	ld hl,009a0h		;1b90	21 a0 09	! . .
	ld a,03ch		;1b93	3e 3c		> <
	jp 00a0bh		;1b95	c3 0b 0a	. . .
l1b98h:
	ld hl,009b3h		;1b98	21 b3 09	! . .
	ld a,03dh		;1b9b	3e 3d		> =
	jp 00a0bh		;1b9d	c3 0b 0a	. . .
	ld hl,009cfh		;1ba0	21 cf 09	! . .
	ld a,040h		;1ba3	3e 40		> @
	jp 00a0bh		;1ba5	c3 0b 0a	. . .
	ld hl,008beh		;1ba8	21 be 08	! . .
	ld a,03eh		;1bab	3e 3e		> >
	jp 00a0bh		;1bad	c3 0b 0a	. . .
	bit 6,a			;1bb0	cb 77		. w
	jr nz,l1bbch		;1bb2	20 08		  .
	ld hl,008f8h		;1bb4	21 f8 08	! . .
	ld a,033h		;1bb7	3e 33		> 3
	jp 00a0bh		;1bb9	c3 0b 0a	. . .
l1bbch:
	ld hl,00906h		;1bbc	21 06 09	! . .
	ld a,034h		;1bbf	3e 34		> 4
	jp 00a0bh		;1bc1	c3 0b 0a	. . .
	ld a,045h		;1bc4	3e 45		> E
	jp 00ac3h		;1bc6	c3 c3 0a	. . .
	jp 00b06h		;1bc9	c3 06 0b	. . .
	push af			;1bcc	f5		.
	push bc			;1bcd	c5		.
	push de			;1bce	d5		.
	push hl			;1bcf	e5		.
	ld a,e			;1bd0	7b		{
	cp 0aah			;1bd1	fe aa		. .
	jr nz,l1bdbh		;1bd3	20 06		  .
	pop hl			;1bd5	e1		.
	pop de			;1bd6	d1		.
	pop bc			;1bd7	c1		.
	pop af			;1bd8	f1		.
	reti			;1bd9	ed 4d		. M
l1bdbh:
	ld b,007h		;1bdb	06 07		. .
	ld c,005h		;1bdd	0e 05		. .
	ld hl,0ffe2h		;1bdf	21 e2 ff	! . .
l1be2h:
	ld a,00ah		;1be2	3e 0a		> .
l1be4h:
	dec a			;1be4	3d		=
	jr nz,l1be4h		;1be5	20 fd		  .
	in a,(004h)		;1be7	db 04		. .
	and 0c0h		;1be9	e6 c0		. .
	cp 0c0h			;1beb	fe c0		. .
	jp nz,00bfah		;1bed	c2 fa 0b	. . .
	ind			;1bf0	ed aa		. .
	jr nz,l1be2h		;1bf2	20 ee		  .
	ld a,(0ffe2h)		;1bf4	3a e2 ff	: . .
	ld b,a			;1bf7	47		G
	jr l1c06h		;1bf8	18 0c		. .
	ld a,008h		;1bfa	3e 08		> .
	call 00c66h		;1bfc	cd 66 0c	. f .
	call 00264h		;1bff	cd 64 02	. d .
	ld h,h			;1c02	64		d
	ld (bc),a		;1c03	02		.
	ld h,h			;1c04	64		d
	ld (bc),a		;1c05	02		.
l1c06h:
	call z,sub_640bh	;1c06	cc 0b 64	. . d
	ld (bc),a		;1c09	02		.
	ld h,h			;1c0a	64		d
	ld (bc),a		;1c0b	02		.
	ld h,h			;1c0c	64		d
	ld (bc),a		;1c0d	02		.
	ld e,a			;1c0e	5f		_
	dec e			;1c0f	1d		.
	ld hl,l6442h		;1c10	21 42 64	! B d
	ld (bc),a		;1c13	02		.
	ld h,h			;1c14	64		d
	ld (bc),a		;1c15	02		.
	ld h,h			;1c16	64		d
	ld (bc),a		;1c17	02		.
l1c18h:
	and e			;1c18	a3		.
	ld b,0afh		;1c19	06 af		. .
	ld b,0bbh		;1c1b	06 bb		. .
	ld b,0c7h		;1c1d	06 c7		. .
	ld b,00fh		;1c1f	06 0f		. .
	inc de			;1c21	13		.
	ld (hl),h		;1c22	74		t
	ld (de),a		;1c23	12		.
	call m,0aa12h		;1c24	fc 12 aa	. . .
	ld (de),a		;1c27	12		.
	jr nc,l1c3dh		;1c28	30 13		0 .
	ld l,(hl)		;1c2a	6e		n
	ld (de),a		;1c2b	12		.
	and 012h		;1c2c	e6 12		. .
	and e			;1c2e	a3		.
	ld (de),a		;1c2f	12		.
	ld a,(hl)		;1c30	7e		~
l1c31h:
	ld (de),a		;1c31	12		.
	ld a,(hl)		;1c32	7e		~
	ld (de),a		;1c33	12		.
	ld a,(hl)		;1c34	7e		~
	ld (de),a		;1c35	12		.
	halt			;1c36	76		v
	inc de			;1c37	13		.
	or 036h			;1c38	f6 36		. 6
	ld h,h			;1c3a	64		d
	ld (bc),a		;1c3b	02		.
	ld h,h			;1c3c	64		d
l1c3dh:
	ld (bc),a		;1c3d	02		.
	ld h,h			;1c3e	64		d
	ld (bc),a		;1c3f	02		.
	ld h,h			;1c40	64		d
	ld (bc),a		;1c41	02		.
	ld h,h			;1c42	64		d
	ld (bc),a		;1c43	02		.
	ld h,h			;1c44	64		d
	ld (bc),a		;1c45	02		.
	ld a,c			;1c46	79		y
	jr c,l1cadh		;1c47	38 64		8 d
	ld (bc),a		;1c49	02		.
	ld h,h			;1c4a	64		d
	ld (bc),a		;1c4b	02		.
	ld b,b			;1c4c	40		@
l1c4dh:
	inc sp			;1c4d	33		3
	ld h,h			;1c4e	64		d
	ld (bc),a		;1c4f	02		.
	ld b,a			;1c50	47		G
	inc bc			;1c51	03		.
	ld h,h			;1c52	64		d
	ld (bc),a		;1c53	02		.
	ld c,d			;1c54	4a		J
	dec de			;1c55	1b		.
	ld h,h			;1c56	64		d
	ld (bc),a		;1c57	02		.
	inc c			;1c58	0c		.
	ld b,b			;1c59	40		@
	ld h,h			;1c5a	64		d
	ld (bc),a		;1c5b	02		.
	djnz l1c8fh		;1c5c	10 31		. 1
	ld b,(hl)		;1c5e	46		F
	ld sp,l334ah		;1c5f	31 4a 33	1 J 3
	ld h,h			;1c62	64		d
	ld (bc),a		;1c63	02		.
	ei			;1c64	fb		.
	reti			;1c65	ed 4d		. M
	halt			;1c67	76		v
	ld h,l			;1c68	65		e
	ld (hl),d		;1c69	72		r
	jr nz,l1c8ch		;1c6a	20 20		   
	ld sp,l322eh		;1c6c	31 2e 32	1 . 2
	jr nz,l1c91h		;1c6f	20 20		   
	jr nz,l1c93h		;1c71	20 20		   
	inc l			;1c73	2c		,
	jr nz,l1ceah		;1c74	20 74		  t
	ld h,l			;1c76	65		e
	ld (hl),e		;1c77	73		s
	ld (hl),h		;1c78	74		t
	jr nz,l1ce9h		;1c79	20 6e		  n
	ld l,a			;1c7b	6f		o
	jr nz,l1cb8h		;1c7c	20 3a		  :
	cpl			;1c7e	2f		/
	jr nz,l1cadh		;1c7f	20 2c		  ,
	jr nz,l1cf6h		;1c81	20 73		  s
	ld (hl),h		;1c83	74		t
	ld h,c			;1c84	61		a
	ld (hl),h		;1c85	74		t
	ld h,l			;1c86	65		e
	ld a,(l2f20h)		;1c87	3a 20 2f	:   /
	ld (hl),d		;1c8a	72		r
	ld (hl),l		;1c8b	75		u
l1c8ch:
	ld l,(hl)		;1c8c	6e		n
	ld l,(hl)		;1c8d	6e		n
l1c8eh:
	ld l,c			;1c8e	69		i
l1c8fh:
	ld l,(hl)		;1c8f	6e		n
	ld h,a			;1c90	67		g
l1c91h:
	cpl			;1c91	2f		/
	ld (hl),e		;1c92	73		s
l1c93h:
	ld (hl),h		;1c93	74		t
	ld l,a			;1c94	6f		o
	ld (hl),b		;1c95	70		p
	ld (hl),b		;1c96	70		p
	ld h,l			;1c97	65		e
	ld h,h			;1c98	64		d
	cpl			;1c99	2f		/
	ld l,h			;1c9a	6c		l
	ld l,a			;1c9b	6f		o
	ld l,a			;1c9c	6f		o
	ld (hl),b		;1c9d	70		p
	ld l,c			;1c9e	69		i
	ld l,(hl)		;1c9f	6e		n
	ld h,a			;1ca0	67		g
	cpl			;1ca1	2f		/
	ld l,b			;1ca2	68		h
	ld h,c			;1ca3	61		a
	ld l,h			;1ca4	6c		l
	ld (hl),h		;1ca5	74		t
	ld h,l			;1ca6	65		e
l1ca7h:
	ld h,h			;1ca7	64		d
l1ca8h:
	jr nz,l1cd9h		;1ca8	20 2f		  /
	ld l,e			;1caa	6b		k
	ld h,l			;1cab	65		e
	ld a,c			;1cac	79		y
l1cadh:
	ld h,d			;1cad	62		b
	ld l,a			;1cae	6f		o
	ld h,c			;1caf	61		a
	ld (hl),d		;1cb0	72		r
	ld h,h			;1cb1	64		d
	jr nz,l1ceeh		;1cb2	20 3a		  :
	jr nz,l1ce5h		;1cb4	20 2f		  /
	ld (hl),h		;1cb6	74		t
	ld a,c			;1cb7	79		y
l1cb8h:
	ld (hl),b		;1cb8	70		p
	ld h,l			;1cb9	65		e
	jr nz,l1ce4h		;1cba	20 28		  (
l1cbch:
	ld c,b			;1cbc	48		H
	inc l			;1cbd	2c		,
	ld d,d			;1cbe	52		R
	inc l			;1cbf	2c		,
	ld c,h			;1cc0	4c		L
	inc l			;1cc1	2c		,
	ld b,a			;1cc2	47		G
	inc l			;1cc3	2c		,
	ld d,e			;1cc4	53		S
	inc l			;1cc5	2c		,
	ld d,b			;1cc6	50		P
	inc l			;1cc7	2c		,
	inc a			;1cc8	3c		<
	ld h,l			;1cc9	65		e
	ld (hl),e		;1cca	73		s
	ld h,e			;1ccb	63		c
	ld a,020h		;1ccc	3e 20		>  
	ld l,a			;1cce	6f		o
	ld (hl),d		;1ccf	72		r
	jr nz,l1cfah		;1cd0	20 28		  (
	jr nc,l1d01h		;1cd2	30 2d		0 -
	ld b,(hl)		;1cd4	46		F
	add hl,hl		;1cd5	29		)
	add hl,hl		;1cd6	29		)
	jr nz,l1d13h		;1cd7	20 3a		  :
l1cd9h:
	jr nz,l1d0ah		;1cd9	20 2f		  /
	ld d,d			;1cdb	52		R
	ld b,e			;1cdc	43		C
	scf			;1cdd	37		7
	jr nc,$+50		;1cde	30 30		0 0
	jr nz,$+86		;1ce0	20 54		  T
	ld b,l			;1ce2	45		E
	ld d,e			;1ce3	53		S
l1ce4h:
	ld d,h			;1ce4	54		T
l1ce5h:
	ld d,e			;1ce5	53		S
	ld e,c			;1ce6	59		Y
	ld d,e			;1ce7	53		S
	ld d,h			;1ce8	54		T
l1ce9h:
	ld b,l			;1ce9	45		E
l1ceah:
	ld c,l			;1cea	4d		M
	jr nz,l1cf1h		;1ceb	20 04		  .
	nop			;1ced	00		.
l1ceeh:
	dec l			;1cee	2d		-
	dec b			;1cef	05		.
	pop bc			;1cf0	c1		.
l1cf1h:
	dec b			;1cf1	05		.
	rst 38h			;1cf2	ff		.
	ld b,002h		;1cf3	06 02		. .
	ex af,af'		;1cf5	08		.
l1cf6h:
	ld c,l			;1cf6	4d		M
	ld sp,014d6h		;1cf7	31 d6 14	1 . .
l1cfah:
	defb 0ddh,00dh,09fh ;illegal sequence	;1cfa	dd 0d 9f	. . .
	jr c,l1ca8h		;1cfd	38 a9		8 .
	jr c,l1c8eh		;1cff	38 8d		8 .
l1d01h:
	dec h			;1d01	25		%
	ld h,(hl)		;1d02	66		f
	inc sp			;1d03	33		3
	ld a,044h		;1d04	3e 44		> D
	inc b			;1d06	04		.
	nop			;1d07	00		.
	inc b			;1d08	04		.
	nop			;1d09	00		.
l1d0ah:
	inc b			;1d0a	04		.
	nop			;1d0b	00		.
	ld hl,00267h		;1d0c	21 67 02	! g .
	ld ix,0f050h		;1d0f	dd 21 50 f0	. ! P .
l1d13h:
	call 01161h		;1d13	cd 61 11	. a .
	ld a,(0ffffh)		;1d16	3a ff ff	: . .
	and 00fh		;1d19	e6 0f		. .
	call 01180h		;1d1b	cd 80 11	. . .
	ret			;1d1e	c9		.
	push hl			;1d1f	e5		.
	ld hl,0027fh		;1d20	21 7f 02	! . .
	ld ix,0f06ch		;1d23	dd 21 6c f0	. ! l .
	call 01161h		;1d27	cd 61 11	. a .
	pop hl			;1d2a	e1		.
	call 01161h		;1d2b	cd 61 11	. a .
	ret			;1d2e	c9		.
	out (050h),a		;1d2f	d3 50		. P
	cp 000h			;1d31	fe 00		. .
	ret z			;1d33	c8		.
	ld a,(0ffffh)		;1d34	3a ff ff	: . .
	bit 7,a			;1d37	cb 7f		. .
	ret nz			;1d39	c0		.
	di			;1d3a	f3		.
	ld hl,002a2h		;1d3b	21 a2 02	! . .
	call 0031fh		;1d3e	cd 1f 03	. . .
l1d41h:
	halt			;1d41	76		v
	jr l1d41h		;1d42	18 fd		. .
	ei			;1d44	fb		.
	reti			;1d45	ed 4d		. M
	push af			;1d47	f5		.
	push bc			;1d48	c5		.
	push de			;1d49	d5		.
	push hl			;1d4a	e5		.
	push iy			;1d4b	fd e5		. .
	push ix			;1d4d	dd e5		. .
	ld ix,(0fffch)		;1d4f	dd 2a fc ff	. * . .
	push ix			;1d53	dd e5		. .
	ld a,(0ffffh)		;1d55	3a ff ff	: . .
	push af			;1d58	f5		.
	set 5,a			;1d59	cb ef		. .
	ld (0ffffh),a		;1d5b	32 ff ff	2 . .
	ld hl,002b6h		;1d5e	21 b6 02	! . .
	ld ix,0f0abh		;1d61	dd 21 ab f0	. ! . .
	call 01161h		;1d65	cd 61 11	. a .
l1d68h:
	in a,(010h)		;1d68	db 10		. .
	cp 01bh			;1d6a	fe 1b		. .
	jr nz,l1db5h		;1d6c	20 47		  G
l1d6eh:
	ld hl,00292h		;1d6e	21 92 02	! . .
	call 0031fh		;1d71	cd 1f 03	. . .
	in a,(010h)		;1d74	db 10		. .
	cp 00dh			;1d76	fe 0d		. .
	jr nz,l1d68h		;1d78	20 ee		  .
	ld ix,0f0cfh		;1d7a	dd 21 cf f0	. ! . .
	ld b,02ah		;1d7e	06 2a		. *
	ld (ix+000h),b		;1d80	dd 70 00	. p .
	call 00345h		;1d83	cd 45 03	. E .
	jp 00407h		;1d86	c3 07 04	. . .
	ld c,b			;1d89	48		H
	ld d,d			;1d8a	52		R
	ld c,h			;1d8b	4c		L
	ld b,a			;1d8c	47		G
	ld d,e			;1d8d	53		S
	ld d,b			;1d8e	50		P
	ld b,(hl)		;1d8f	46		F
l1d90h:
	ld b,l			;1d90	45		E
	ld b,h			;1d91	44		D
	ld b,e			;1d92	43		C
	ld b,d			;1d93	42		B
	ld b,c			;1d94	41		A
	add hl,sp		;1d95	39		9
	jr c,$+57		;1d96	38 37		8 7
	ld (hl),035h		;1d98	36 35		6 5
	inc (hl)		;1d9a	34		4
	inc sp			;1d9b	33		3
	ld (l3031h),a		;1d9c	32 31 30	2 1 0
	jr nc,$+51		;1d9f	30 31		0 1
	ld (03433h),a		;1da1	32 33 34	2 3 4
	dec (hl)		;1da4	35		5
	ld (hl),037h		;1da5	36 37		6 7
	jr c,$+59		;1da7	38 39		8 9
	ld b,c			;1da9	41		A
	ld b,d			;1daa	42		B
	ld b,e			;1dab	43		C
	ld b,h			;1dac	44		D
	ld b,l			;1dad	45		E
	ld b,(hl)		;1dae	46		F
	ld d,b			;1daf	50		P
	ld d,e			;1db0	53		S
	ld b,a			;1db1	47		G
	ld c,h			;1db2	4c		L
	ld d,d			;1db3	52		R
	ld c,b			;1db4	48		H
l1db5h:
	ld ix,0f0cfh		;1db5	dd 21 cf f0	. ! . .
	ld hl,00389h		;1db9	21 89 03	! . .
	ld bc,00016h		;1dbc	01 16 00	. . .
	cpir			;1dbf	ed b1		. .
	jr nz,l1d6eh		;1dc1	20 ab		  .
	ld hl,0039fh		;1dc3	21 9f 03	! . .
	add hl,bc		;1dc6	09		.
	ld a,(hl)		;1dc7	7e		~
	ld (ix+000h),a		;1dc8	dd 77 00	. w .
	ld a,00fh		;1dcb	3e 0f		> .
	cp c			;1dcd	b9		.
	jr c,l1ddbh		;1dce	38 0b		8 .
	ld a,(0ffffh)		;1dd0	3a ff ff	: . .
	and 0f0h		;1dd3	e6 f0		. .
	or c			;1dd5	b1		.
	ld (0ffffh),a		;1dd6	32 ff ff	2 . .
	jr l1d6eh		;1dd9	18 93		. .
l1ddbh:
	ld a,c			;1ddb	79		y
	ld hl,0ffffh		;1ddc	21 ff ff	! . .
	cp 010h			;1ddf	fe 10		. .
	jr nz,l1de5h		;1de1	20 02		  .
	res 4,(hl)		;1de3	cb a6		. .
l1de5h:
	cp 011h			;1de5	fe 11		. .
	jr nz,l1debh		;1de7	20 02		  .
	set 4,(hl)		;1de9	cb e6		. .
l1debh:
	cp 012h			;1deb	fe 12		. .
	jr nz,l1df1h		;1ded	20 02		  .
	res 6,(hl)		;1def	cb b6		. .
l1df1h:
	cp 013h			;1df1	fe 13		. .
	jr nz,l1df7h		;1df3	20 02		  .
	set 6,(hl)		;1df5	cb f6		. .
l1df7h:
	cp 014h			;1df7	fe 14		. .
	jr nz,l1dfdh		;1df9	20 02		  .
	set 7,(hl)		;1dfb	cb fe		. .
l1dfdh:
	cp 015h			;1dfd	fe 15		. .
	jp nz,00c4fh		;1dff	c2 4f 0c	. O .
	ld b,a			;1e02	47		G
	call 00c4fh		;1e03	cd 4f 0c	. O .
	call 00c26h		;1e06	cd 26 0c	. & .
	push bc			;1e09	c5		.
	ld b,a			;1e0a	47		G
	call 00da2h		;1e0b	cd a2 0d	. . .
	pop bc			;1e0e	c1		.
	ld a,(hl)		;1e0f	7e		~
	cp 000h			;1e10	fe 00		. .
	jp z,00a2dh		;1e12	ca 2d 0a	. - .
	cp 001h			;1e15	fe 01		. .
	jp z,00a8bh		;1e17	ca 8b 0a	. . .
	cp 002h			;1e1a	fe 02		. .
	jr z,$-83		;1e1c	28 ab		( .
	cp 003h			;1e1e	fe 03		. .
	jp z,00b06h		;1e20	ca 06 0b	. . .
	jp 00a56h		;1e23	c3 56 0a	. V .
	push bc			;1e26	c5		.
	bit 1,b			;1e27	cb 48		. H
	jr nz,l1e3dh		;1e29	20 12		  .
	bit 0,b			;1e2b	cb 40		. @
	jr nz,l1e36h		;1e2d	20 07		  .
	ld a,000h		;1e2f	3e 00		> .
	ld (0ffc0h),a		;1e31	32 c0 ff	2 . .
	pop bc			;1e34	c1		.
	ret			;1e35	c9		.
l1e36h:
	ld a,001h		;1e36	3e 01		> .
	ld (0ffc0h),a		;1e38	32 c0 ff	2 . .
	pop bc			;1e3b	c1		.
	ret			;1e3c	c9		.
l1e3dh:
	bit 0,b			;1e3d	cb 40		. @
	jr nz,l1e48h		;1e3f	20 07		  .
	ld a,002h		;1e41	3e 02		> .
	ld (0ffc0h),a		;1e43	32 c0 ff	2 . .
	pop bc			;1e46	c1		.
	ret			;1e47	c9		.
l1e48h:
	ld a,003h		;1e48	3e 03		> .
	ld (0ffc0h),a		;1e4a	32 c0 ff	2 . .
	pop bc			;1e4d	c1		.
	ret			;1e4e	c9		.
	push bc			;1e4f	c5		.
	ld b,0ffh		;1e50	06 ff		. .
	push af			;1e52	f5		.
l1e53h:
	pop af			;1e53	f1		.
	in a,(004h)		;1e54	db 04		. .
	and 0c0h		;1e56	e6 c0		. .
	cp 0c0h			;1e58	fe c0		. .
	jr z,l1e62h		;1e5a	28 06		( .
	push af			;1e5c	f5		.
	djnz l1e53h		;1e5d	10 f4		. .
	pop af			;1e5f	f1		.
	pop bc			;1e60	c1		.
	ret			;1e61	c9		.
l1e62h:
	in a,(005h)		;1e62	db 05		. .
	pop bc			;1e64	c1		.
	ret			;1e65	c9		.
	push de			;1e66	d5		.
	push bc			;1e67	c5		.
	ld d,a			;1e68	57		W
	ld b,0ffh		;1e69	06 ff		. .
	push af			;1e6b	f5		.
l1e6ch:
	pop af			;1e6c	f1		.
	in a,(004h)		;1e6d	db 04		. .
	and 0c0h		;1e6f	e6 c0		. .
	cp 080h			;1e71	fe 80		. .
	jr z,l1e7ch		;1e73	28 07		( .
	push af			;1e75	f5		.
	djnz l1e6ch		;1e76	10 f4		. .
	pop af			;1e78	f1		.
	pop bc			;1e79	c1		.
	pop de			;1e7a	d1		.
	ret			;1e7b	c9		.
l1e7ch:
	ld a,d			;1e7c	7a		z
	out (005h),a		;1e7d	d3 05		. .
	pop bc			;1e7f	c1		.
	pop de			;1e80	d1		.
	ret			;1e81	c9		.
	in a,(014h)		;1e82	db 14		. .
	and 080h		;1e84	e6 80		. .
	jr z,l1efdh		;1e86	28 75		( u
	call 00da2h		;1e88	cd a2 0d	. . .
	ld a,(hl)		;1e8b	7e		~
	cp 0ffh			;1e8c	fe ff		. .
	ret nz			;1e8e	c0		.
	ld a,007h		;1e8f	3e 07		> .
	call 00c66h		;1e91	cd 66 0c	. f .
	jp nz,00d6eh		;1e94	c2 6e 0d	. n .
	ld e,0aah		;1e97	1e aa		. .
	ld a,b			;1e99	78		x
	ld d,b			;1e9a	50		P
	call 00c66h		;1e9b	cd 66 0c	. f .
	jp nz,00d6eh		;1e9e	c2 6e 0d	. n .
	ld b,00fh		;1ea1	06 0f		. .
	call 01106h		;1ea3	cd 06 11	. . .
	ld a,007h		;1ea6	3e 07		> .
	call 00c66h		;1ea8	cd 66 0c	. f .
	jp nz,00d6eh		;1eab	c2 6e 0d	. n .
	ld a,d			;1eae	7a		z
	ld e,0aah		;1eaf	1e aa		. .
	call 00c66h		;1eb1	cd 66 0c	. f .
	jp nz,00d6eh		;1eb4	c2 6e 0d	. n .
	ld b,00fh		;1eb7	06 0f		. .
	call 01106h		;1eb9	cd 06 11	. . .
	ld e,000h		;1ebc	1e 00		. .
	ld a,008h		;1ebe	3e 08		> .
	call 00c66h		;1ec0	cd 66 0c	. f .
	jp nz,00d6eh		;1ec3	c2 6e 0d	. n .
	call 00c4fh		;1ec6	cd 4f 0c	. O .
	jp nz,00d6eh		;1ec9	c2 6e 0d	. n .
	ld c,a			;1ecc	4f		O
	call 00c4fh		;1ecd	cd 4f 0c	. O .
	jp nz,00d6eh		;1ed0	c2 6e 0d	. n .
	ld b,d			;1ed3	42		B
	ld a,c			;1ed4	79		y
	and 0f0h		;1ed5	e6 f0		. .
	cp 020h			;1ed7	fe 20		.  
	jr z,l1ee2h		;1ed9	28 07		( .
	call 00da2h		;1edb	cd a2 0d	. . .
	ld a,0cch		;1ede	3e cc		> .
	ld (hl),a		;1ee0	77		w
	ret			;1ee1	c9		.
l1ee2h:
	ld a,004h		;1ee2	3e 04		> .
	call 00c66h		;1ee4	cd 66 0c	. f .
	jp nz,00d6eh		;1ee7	c2 6e 0d	. n .
	ld a,b			;1eea	78		x
	call 00c66h		;1eeb	cd 66 0c	. f .
	jp nz,00d6eh		;1eee	c2 6e 0d	. n .
	call 00c4fh		;1ef1	cd 4f 0c	. O .
	bit 6,a			;1ef4	cb 77		. w
	ret nz			;1ef6	c0		.
	xor a			;1ef7	af		.
	call 00da2h		;1ef8	cd a2 0d	. . .
	ld (hl),a		;1efb	77		w
	ret			;1efc	c9		.
l1efdh:
	ld a,004h		;1efd	3e 04		> .
	call 00c66h		;1eff	cd 66 0c	. f .
	jr nz,l1f6eh		;1f02	20 6a		  j
	ld a,b			;1f04	78		x
	call 00c66h		;1f05	cd 66 0c	. f .
	jr nz,l1f6eh		;1f08	20 64		  d
	call 00c4fh		;1f0a	cd 4f 0c	. O .
	jr nz,l1f6eh		;1f0d	20 5f		  _
	ld c,a			;1f0f	4f		O
l1f10h:
	call 00da2h		;1f10	cd a2 0d	. . .
	ld a,(hl)		;1f13	7e		~
	cp 0ffh			;1f14	fe ff		. .
	jr nz,l1f20h		;1f16	20 08		  .
	bit 5,c			;1f18	cb 69		. i
	ret z			;1f1a	c8		.
	bit 6,c			;1f1b	cb 71		. q
	ret nz			;1f1d	c0		.
	xor a			;1f1e	af		.
	ld (hl),a		;1f1f	77		w
l1f20h:
	bit 5,c			;1f20	cb 69		. i
	ret nz			;1f22	c0		.
	ld hl,008beh		;1f23	21 be 08	! . .
	ld a,03eh		;1f26	3e 3e		> >
	ld (0fffeh),a		;1f28	32 fe ff	2 . .
	ld a,b			;1f2b	78		x
	call 00d7fh		;1f2c	cd 7f 0d	. . .
	call 01161h		;1f2f	cd 61 11	. a .
	ret			;1f32	c9		.
	in a,(014h)		;1f33	db 14		. .
	and 080h		;1f35	e6 80		. .
	ld hl,009e9h		;1f37	21 e9 09	! . .
	jr z,l1f3fh		;1f3a	28 03		( .
	ld hl,009f9h		;1f3c	21 f9 09	! . .
l1f3fh:
	ld (0ffc2h),hl		;1f3f	22 c2 ff	" . .
	ret			;1f42	c9		.
	xor a			;1f43	af		.
	out (014h),a		;1f44	d3 14		. .
	ret			;1f46	c9		.
	ld a,001h		;1f47	3e 01		> .
	out (014h),a		;1f49	d3 14		. .
	ld b,014h		;1f4b	06 14		. .
l1f4dh:
	ld hl,l30d4h		;1f4d	21 d4 30	! . 0
l1f50h:
	dec hl			;1f50	2b		+
	ld a,l			;1f51	7d		}
	or h			;1f52	b4		.
	jr nz,l1f50h		;1f53	20 fb		  .
	djnz l1f4dh		;1f55	10 f6		. .
	ret			;1f57	c9		.
	ld a,003h		;1f58	3e 03		> .
	call 00c66h		;1f5a	cd 66 0c	. f .
	jr nz,l1f6eh		;1f5d	20 0f		  .
	ld a,06ah		;1f5f	3e 6a		> j
	call 00c66h		;1f61	cd 66 0c	. f .
	jr nz,l1f6eh		;1f64	20 08		  .
	ld a,028h		;1f66	3e 28		> (
	call 00c66h		;1f68	cd 66 0c	. f .
	jr nz,l1f6eh		;1f6b	20 01		  .
	ret			;1f6d	c9		.
l1f6eh:
	ld a,030h		;1f6e	3e 30		> 0
	ld (0fffeh),a		;1f70	32 fe ff	2 . .
	ld hl,00895h		;1f73	21 95 08	! . .
	ld ix,(0fffch)		;1f76	dd 2a fc ff	. * . .
	call 01161h		;1f7a	cd 61 11	. a .
	reti			;1f7d	ed 4d		. M
	push hl			;1f7f	e5		.
	push bc			;1f80	c5		.
	push af			;1f81	f5		.
	ld hl,0088ch		;1f82	21 8c 08	! . .
	ld ix,(0fffch)		;1f85	dd 2a fc ff	. * . .
	call 01161h		;1f89	cd 61 11	. a .
	pop af			;1f8c	f1		.
	push af			;1f8d	f5		.
	call 01180h		;1f8e	cd 80 11	. . .
	ld a,020h		;1f91	3e 20		>  
	ld (ix+000h),a		;1f93	dd 77 00	. w .
	inc ix			;1f96	dd 23		. #
	inc ix			;1f98	dd 23		. #
	ld (0fffch),ix		;1f9a	dd 22 fc ff	. " . .
	pop af			;1f9e	f1		.
	pop bc			;1f9f	c1		.
	pop hl			;1fa0	e1		.
	ret			;1fa1	c9		.
	ld l,b			;1fa2	68		h
	ld h,000h		;1fa3	26 00		& .
	ld e,l			;1fa5	5d		]
	ld d,h			;1fa6	54		T
	add hl,hl		;1fa7	29		)
	add hl,hl		;1fa8	29		)
	add hl,de		;1fa9	19		.
	ex de,hl		;1faa	eb		.
	ld hl,0ffc4h		;1fab	21 c4 ff	! . .
	add hl,de		;1fae	19		.
	ret			;1faf	c9		.
	ld a,005h		;1fb0	3e 05		> .
	out (0fah),a		;1fb2	d3 fa		. .
	ld a,h			;1fb4	7c		|
	out (0fbh),a		;1fb5	d3 fb		. .
	out (0fch),a		;1fb7	d3 fc		. .
	ld a,c			;1fb9	79		y
	out (0f2h),a		;1fba	d3 f2		. .
	ld a,b			;1fbc	78		x
	out (0f2h),a		;1fbd	d3 f2		. .
	ld a,e			;1fbf	7b		{
	out (0f3h),a		;1fc0	d3 f3		. .
	ld a,d			;1fc2	7a		z
	out (0f3h),a		;1fc3	d3 f3		. .
	ld a,001h		;1fc5	3e 01		> .
	out (0fah),a		;1fc7	d3 fa		. .
	ret			;1fc9	c9		.
	push hl			;1fca	e5		.
	push af			;1fcb	f5		.
	ld hl,00200h		;1fcc	21 00 02	! . .
	ld a,l			;1fcf	7d		}
	out (00ch),a		;1fd0	d3 0c		. .
	ld a,0d7h		;1fd2	3e d7		> .
	out (00fh),a		;1fd4	d3 0f		. .
	ld a,001h		;1fd6	3e 01		> .
	out (00fh),a		;1fd8	d3 0f		. .
	pop af			;1fda	f1		.
	pop hl			;1fdb	e1		.
	ret			;1fdc	c9		.
	ld hl,00880h		;1fdd	21 80 08	! . .
	ld ix,0f320h		;1fe0	dd 21 20 f3	. !   .
	call 01161h		;1fe4	cd 61 11	. a .
	ld bc,00002h		;1fe7	01 02 00	. . .
	ld ix,0a000h		;1fea	dd 21 00 a0	. ! . .
	call 0109bh		;1fee	cd 9b 10	. . .
	call 00dcah		;1ff1	cd ca 0d	. . .
	ld b,003h		;1ff4	06 03		. .
	call 00da2h		;1ff6	cd a2 0d	. . .
	ld a,0ffh		;1ff9	3e ff		> .
	ld (hl),a		;1ffb	77		w
	dec b			;1ffc	05		.
	ld a,b			;1ffd	78		x
	cp 000h			;1ffe	fe 00		. .
l2000h:
	ld l,(hl)		;2000	6e		n
	inc bc			;2001	03		.
	res 7,(hl)		;2002	cb be		. .
	jp 0036eh		;2004	c3 6e 03	. n .
	ld a,(0ffffh)		;2007	3a ff ff	: . .
	and 00fh		;200a	e6 0f		. .
	ld b,a			;200c	47		G
	pop af			;200d	f1		.
	and 00fh		;200e	e6 0f		. .
	cp b			;2010	b8		.
	call nz,00435h		;2011	c4 35 04	. 5 .
	ld hl,0028ah		;2014	21 8a 02	! . .
	ld a,(0ffffh)		;2017	3a ff ff	: . .
	bit 6,a			;201a	cb 77		. w
	jr z,l2021h		;201c	28 03		( .
	ld hl,0029ah		;201e	21 9a 02	! . .
l2021h:
	call 0031fh		;2021	cd 1f 03	. . .
	pop ix			;2024	dd e1		. .
	ld (0fffch),ix		;2026	dd 22 fc ff	. " . .
l202ah:
	pop ix			;202a	dd e1		. .
	pop iy			;202c	fd e1		. .
	pop hl			;202e	e1		.
l202fh:
	pop de			;202f	d1		.
	pop bc			;2030	c1		.
	pop af			;2031	f1		.
	ei			;2032	fb		.
	reti			;2033	ed 4d		. M
	ld a,(0f000h)		;2035	3a 00 f0	: . .
	cp 052h			;2038	fe 52		. R
l203ah:
	jr z,l2047h		;203a	28 0b		( .
	ld hl,0e000h		;203c	21 00 e0	! . .
	ld de,0f000h		;203f	11 00 f0	. . .
	ld bc,007d0h		;2042	01 d0 07	. . .
	ldir			;2045	ed b0		. .
l2047h:
	out (0fdh),a		;2047	d3 fd		. .
	ld a,020h		;2049	3e 20		>  
	out (0f8h),a		;204b	d3 f8		. .
	in a,(001h)		;204d	db 01		. .
l204fh:
	in a,(001h)		;204f	db 01		. .
	bit 5,a			;2051	cb 6f		. o
	jr z,l204fh		;2053	28 fa		( .
	ld a,002h		;2055	3e 02		> .
	out (0fah),a		;2057	d3 fa		. .
	ld a,018h		;2059	3e 18		> .
	out (00ah),a		;205b	d3 0a		. .
	out (00bh),a		;205d	d3 0b		. .
	ld a,003h		;205f	3e 03		> .
	out (00ch),a		;2061	d3 0c		. .
	out (00dh),a		;2063	d3 0d		. .
	out (00eh),a		;2065	d3 0e		. .
	out (00fh),a		;2067	d3 0f		. .
	ld hl,004d0h		;2069	21 d0 04	! . .
	ex (sp),hl		;206c	e3		.
	ei			;206d	fb		.
	reti			;206e	ed 4d		. M
	ld hl,00200h		;2070	21 00 02	! . .
	ld sp,l8000h		;2073	31 00 80	1 . .
	ex af,af'		;2076	08		.
	ld a,h			;2077	7c		|
	ld i,a			;2078	ed 47		. G
	call 00345h		;207a	cd 45 03	. E .
	ld hl,00250h		;207d	21 50 02	! P .
	ld a,l			;2080	7d		}
	out (012h),a		;2081	d3 12		. .
	ld a,04fh		;2083	3e 4f		> O
	out (012h),a		;2085	d3 12		. .
	ld a,087h		;2087	3e 87		> .
	out (012h),a		;2089	d3 12		. .
	ld hl,002aah		;208b	21 aa 02	! . .
	ld ix,0f0a0h		;208e	dd 21 a0 f0	. ! . .
	call 01161h		;2092	cd 61 11	. a .
	call 0030ch		;2095	cd 0c 03	. . .
	ld b,01eh		;2098	06 1e		. .
	call 01106h		;209a	cd 06 11	. . .
	ex af,af'		;209d	08		.
	call 0032fh		;209e	cd 2f 03	. / .
	ld a,(0ffffh)		;20a1	3a ff ff	: . .
	bit 5,a			;20a4	cb 6f		. o
	jr nz,l20afh		;20a6	20 07		  .
	ld a,009h		;20a8	3e 09		> .
	ld (0f7e0h),a		;20aa	32 e0 f7	2 . .
	jr l20b4h		;20ad	18 05		. .
l20afh:
	ld a,007h		;20af	3e 07		> .
	ld (0f7e0h),a		;20b1	32 e0 f7	2 . .
l20b4h:
	xor a			;20b4	af		.
	ld hl,0ffffh		;20b5	21 ff ff	! . .
	rrd			;20b8	ed 67		. g
	bit 2,(hl)		;20ba	cb 56		. V
	jr nz,l20c9h		;20bc	20 0b		  .
	ld iy,0f7e0h		;20be	fd 21 e0 f7	. ! . .
	inc a			;20c2	3c		<
	cp (iy+000h)		;20c3	fd be 00	. . .
	jr c,l20c9h		;20c6	38 01		8 .
	xor a			;20c8	af		.
l20c9h:
	ld b,005h		;20c9	06 05		. .
	rld			;20cb	ed 6f		. o
	call 01106h		;20cd	cd 06 11	. . .
	call 0030ch		;20d0	cd 0c 03	. . .
	ld hl,0028ah		;20d3	21 8a 02	! . .
	ld a,(0ffffh)		;20d6	3a ff ff	: . .
	bit 6,a			;20d9	cb 77		. w
	jr z,l20e0h		;20db	28 03		( .
	ld hl,0029ah		;20dd	21 9a 02	! . .
l20e0h:
	call 0031fh		;20e0	cd 1f 03	. . .
	ld sp,l8000h		;20e3	31 00 80	1 . .
	ld iy,002ech		;20e6	fd 21 ec 02	. ! . .
	ld a,(0ffffh)		;20ea	3a ff ff	: . .
	and 00fh		;20ed	e6 0f		. .
	ld c,a			;20ef	4f		O
	rlc c			;20f0	cb 01		. .
	xor a			;20f2	af		.
	ld b,a			;20f3	47		G
	add iy,bc		;20f4	fd 09		. .
	ld h,(iy+001h)		;20f6	fd 66 01	. f .
	ld l,(iy+000h)		;20f9	fd 6e 00	. n .
	xor a			;20fc	af		.
	cp h			;20fd	bc		.
	jr nz,l2100h		;20fe	20 00		  .
l2100h:
	jp (hl)			;2100	e9		.
	ld c,l			;2101	4d		M
	ld b,l			;2102	45		E
	ld c,l			;2103	4d		M
	jr nz,l2178h		;2104	20 72		  r
	ld h,l			;2106	65		e
	ld h,(hl)		;2107	66		f
	ld (hl),d		;2108	72		r
	ld h,l			;2109	65		e
	ld (hl),e		;210a	73		s
	ld l,b			;210b	68		h
	jr nz,l2182h		;210c	20 74		  t
	ld h,l			;210e	65		e
	ld (hl),e		;210f	73		s
	ld (hl),h		;2110	74		t
	jr nz,l214dh		;2111	20 3a		  :
	jr nz,$+49		;2113	20 2f		  /
	ld h,h			;2115	64		d
	ld h,c			;2116	61		a
	ld (hl),h		;2117	74		t
	ld h,c			;2118	61		a
	jr nz,l2188h		;2119	20 6d		  m
	ld l,a			;211b	6f		o
	ld h,h			;211c	64		d
	ld l,c			;211d	69		i
	ld h,(hl)		;211e	66		f
	ld l,c			;211f	69		i
	ld h,l			;2120	65		e
	ld h,h			;2121	64		d
	jr nz,$+107		;2122	20 69		  i
	ld l,(hl)		;2124	6e		n
	jr nz,l2189h		;2125	20 62		  b
	ld a,c			;2127	79		y
	ld (hl),h		;2128	74		t
	ld h,l			;2129	65		e
	jr nz,$+60		;212a	20 3a		  :
	cpl			;212c	2f		/
l212dh:
	ld ix,0f0f0h		;212d	dd 21 f0 f0	. ! . .
	ld hl,00501h		;2131	21 01 05	! . .
	call 01161h		;2134	cd 61 11	. a .
	ld c,000h		;2137	0e 00		. .
	ld de,0f000h		;2139	11 00 f0	. . .
l213ch:
	ld hl,l8000h		;213c	21 00 80	! . .
l213fh:
	ld a,l			;213f	7d		}
l2140h:
	xor h			;2140	ac		.
	bit 0,c			;2141	cb 41		. A
	jr nz,l2148h		;2143	20 03		  .
	ld (hl),a		;2145	77		w
	jr l214ch		;2146	18 04		. .
l2148h:
	ld b,a			;2148	47		G
	xor (hl)		;2149	ae		.
	jr nz,l2161h		;214a	20 15		  .
l214ch:
	inc hl			;214c	23		#
l214dh:
	ld a,h			;214d	7c		|
	cp d			;214e	ba		.
	jr nz,l213fh		;214f	20 ee		  .
	ld a,l			;2151	7d		}
	cp e			;2152	bb		.
	jr nz,l2140h		;2153	20 eb		  .
	bit 0,c			;2155	cb 41		. A
	jr nz,l2190h		;2157	20 37		  7
	inc c			;2159	0c		.
	ld b,032h		;215a	06 32		. 2
	call 01106h		;215c	cd 06 11	. . .
	jr l213ch		;215f	18 db		. .
l2161h:
	xor b			;2161	a8		.
	ld e,b			;2162	58		X
	ld d,a			;2163	57		W
	push hl			;2164	e5		.
	ld hl,00515h		;2165	21 15 05	! . .
	ld ix,(0fffch)		;2168	dd 2a fc ff	. * . .
	call 01161h		;216c	cd 61 11	. a .
	pop hl			;216f	e1		.
	ld a,h			;2170	7c		|
	call 01180h		;2171	cd 80 11	. . .
	ld a,l			;2174	7d		}
	call 01180h		;2175	cd 80 11	. . .
l2178h:
	ld hl,01076h		;2178	21 76 10	! v .
	call 01161h		;217b	cd 61 11	. a .
	ld a,e			;217e	7b		{
	call 01180h		;217f	cd 80 11	. . .
l2182h:
	ld hl,0107ch		;2182	21 7c 10	! | .
	call 01161h		;2185	cd 61 11	. a .
l2188h:
	ld a,d			;2188	7a		z
l2189h:
	call 01180h		;2189	cd 80 11	. . .
	ld a,017h		;218c	3e 17		> .
	jr l219bh		;218e	18 0b		. .
l2190h:
	ld hl,0105ah		;2190	21 5a 10	! Z .
	ld ix,(0fffch)		;2193	dd 2a fc ff	. * . .
	call 01161h		;2197	cd 61 11	. a .
	xor a			;219a	af		.
l219bh:
	ld (0fffeh),a		;219b	32 fe ff	2 . .
	ld a,(0ffffh)		;219e	3a ff ff	: . .
	bit 6,a			;21a1	cb 77		. w
	jp nz,00537h		;21a3	c2 37 05	. 7 .
	ld a,(0fffeh)		;21a6	3a fe ff	: . .
	jp 0049eh		;21a9	c3 9e 04	. . .
	ld b,h			;21ac	44		D
	ld c,l			;21ad	4d		M
	ld b,c			;21ae	41		A
	dec l			;21af	2d		-
	ld (hl),h		;21b0	74		t
	ld h,l			;21b1	65		e
	ld (hl),e		;21b2	73		s
	ld (hl),h		;21b3	74		t
	jr nz,l2219h		;21b4	20 63		  c
	ld l,b			;21b6	68		h
	jr nz,l21e9h		;21b7	20 30		  0
	jr nz,$+47		;21b9	20 2d		  -
	jr nz,$+51		;21bb	20 31		  1
	jr nz,l21f9h		;21bd	20 3a		  :
	jr nz,l21f0h		;21bf	20 2f		  /
	ld ix,0f140h		;21c1	dd 21 40 f1	. ! @ .
	ld hl,005ach		;21c5	21 ac 05	! . .
	call 01161h		;21c8	cd 61 11	. a .
	ld ix,0c000h		;21cb	dd 21 00 c0	. ! . .
	ld bc,00004h		;21cf	01 04 00	. . .
	call 0109bh		;21d2	cd 9b 10	. . .
	ei			;21d5	fb		.
	ld hl,0c400h		;21d6	21 00 c4	! . .
	ld de,0c400h		;21d9	11 00 c4	. . .
	inc de			;21dc	13		.
	ld bc,003ffh		;21dd	01 ff 03	. . .
	ld (hl),000h		;21e0	36 00		6 .
	di			;21e2	f3		.
l21e3h:
	ldir			;21e3	ed b0		. .
	ld a,006h		;21e5	3e 06		> .
	out (0fah),a		;21e7	d3 fa		. .
l21e9h:
	ld a,001h		;21e9	3e 01		> .
	out (0f8h),a		;21eb	d3 f8		. .
	ld bc,0c400h		;21ed	01 00 c4	. . .
l21f0h:
	ld de,003ffh		;21f0	11 ff 03	. . .
	ld a,003h		;21f3	3e 03		> .
	out (0ffh),a		;21f5	d3 ff		. .
	ld a,085h		;21f7	3e 85		> .
l21f9h:
	out (0fbh),a		;21f9	d3 fb		. .
	out (0fch),a		;21fb	d3 fc		. .
	ld a,c			;21fd	79		y
	out (0f2h),a		;21fe	d3 f2		. .
	jp p,00df6h		;2200	f2 f6 0d	. . .
	ld a,0ffh		;2203	3e ff		> .
	out (005h),a		;2205	d3 05		. .
	xor a			;2207	af		.
	ld (0fffeh),a		;2208	32 fe ff	2 . .
	call 00c4fh		;220b	cd 4f 0c	. O .
	call 00d58h		;220e	cd 58 0d	. X .
	ld a,(0fffeh)		;2211	3a fe ff	: . .
	cp 000h			;2214	fe 00		. .
	jp nz,00fefh		;2216	c2 ef 0f	. . .
l2219h:
	call 00a09h		;2219	cd 09 0a	. . .
	call 00d47h		;221c	cd 47 0d	. G .
	ld b,004h		;221f	06 04		. .
	ld hl,0ffc4h		;2221	21 c4 ff	! . .
l2224h:
	xor a			;2224	af		.
	inc hl			;2225	23		#
	ld (hl),a		;2226	77		w
	inc hl			;2227	23		#
	ld (hl),a		;2228	77		w
	inc hl			;2229	23		#
	ld (hl),a		;222a	77		w
	inc hl			;222b	23		#
	inc a			;222c	3c		<
	ld (hl),a		;222d	77		w
	inc hl			;222e	23		#
	djnz l2224h		;222f	10 f3		. .
	xor a			;2231	af		.
	cpl			;2232	2f		/
	ld (0ffc0h),a		;2233	32 c0 ff	2 . .
	call 00d33h		;2236	cd 33 0d	. 3 .
	xor a			;2239	af		.
	ld (0ffbeh),a		;223a	32 be ff	2 . .
l223dh:
	ld b,003h		;223d	06 03		. .
	call 00c82h		;223f	cd 82 0c	. . .
	ld a,(0fffeh)		;2242	3a fe ff	: . .
	cp 000h			;2245	fe 00		. .
	jp nz,00fefh		;2247	c2 ef 0f	. . .
	dec b			;224a	05		.
	jp p,00e3fh		;224b	f2 3f 0e	. ? .
	ld b,003h		;224e	06 03		. .
	call 00da2h		;2250	cd a2 0d	. . .
	ld a,(hl)		;2253	7e		~
	cp 0bbh			;2254	fe bb		. .
	jp c,00f31h		;2256	da 31 0f	. 1 .
	dec b			;2259	05		.
	jp p,00e50h		;225a	f2 50 0e	. P .
	ld a,(0ffbeh)		;225d	3a be ff	: . .
	cp 000h			;2260	fe 00		. .
	jr nz,l2272h		;2262	20 0e		  .
	cpl			;2264	2f		/
	ld (0ffbeh),a		;2265	32 be ff	2 . .
	ld hl,008b0h		;2268	21 b0 08	! . .
	ld ix,(0fffch)		;226b	dd 2a fc ff	. * . .
l226fh:
	call 01161h		;226f	cd 61 11	. a .
l2272h:
	ld b,005h		;2272	06 05		. .
	ei			;2274	fb		.
l2275h:
	ld hl,0300ch		;2275	21 0c 30	! . 0
l2278h:
	ld a,(0ffc0h)		;2278	3a c0 ff	: . .
	cp 0ffh			;227b	fe ff		. .
	jr nz,l22b8h		;227d	20 39		  9
	dec hl			;227f	2b		+
	ld a,l			;2280	7d		}
	or h			;2281	b4		.
	jr nz,l2278h		;2282	20 f4		  .
	djnz l2275h		;2284	10 ef		. .
	di			;2286	f3		.
	ld b,003h		;2287	06 03		. .
	call 00da2h		;2289	cd a2 0d	. . .
	ld a,(hl)		;228c	7e		~
	cp 0bbh			;228d	fe bb		. .
	inc hl			;228f	23		#
	jr nc,l22a9h		;2290	30 17		0 .
	ld a,(hl)		;2292	7e		~
	cp 000h			;2293	fe 00		. .
	jr nz,l22a9h		;2295	20 12		  .
	ld a,b			;2297	78		x
	call 00d7fh		;2298	cd 7f 0d	. . .
	ld hl,008d6h		;229b	21 d6 08	! . .
	call 01161h		;229e	cd 61 11	. a .
	ld a,042h		;22a1	3e 42		> B
	ld (0fffeh),a		;22a3	32 fe ff	2 . .
	jp 00fefh		;22a6	c3 ef 0f	. . .
l22a9h:
	xor a			;22a9	af		.
	ld (hl),a		;22aa	77		w
	dec b			;22ab	05		.
	jp p,00e89h		;22ac	f2 89 0e	. . .
	ld a,(0ffbeh)		;22af	3a be ff	: . .
	cp 000h			;22b2	fe 00		. .
	jr nz,l223dh		;22b4	20 87		  .
	jr l2272h		;22b6	18 ba		. .
l22b8h:
	ld b,a			;22b8	47		G
	ld a,(0fffeh)		;22b9	3a fe ff	: . .
	cp 000h			;22bc	fe 00		. .
	jp nz,00fefh		;22be	c2 ef 0f	. . .
	call 00da2h		;22c1	cd a2 0d	. . .
	inc hl			;22c4	23		#
	ld a,0ffh		;22c5	3e ff		> .
	ld (hl),a		;22c7	77		w
	ld (0ffc0h),a		;22c8	32 c0 ff	2 . .
	dec hl			;22cb	2b		+
	ld a,(hl)		;22cc	7e		~
	cp 0aah			;22cd	fe aa		. .
	jr nc,l2272h		;22cf	30 a1		0 .
	xor a			;22d1	af		.
	ld (0ffbeh),a		;22d2	32 be ff	2 . .
	inc (hl)		;22d5	34		4
	ld a,003h		;22d6	3e 03		> .
	cp (hl)			;22d8	be		.
	push af			;22d9	f5		.
	push hl			;22da	e5		.
	push bc			;22db	c5		.
	jr nc,l22fdh		;22dc	30 1f		0 .
	ld ix,0a000h		;22de	dd 21 00 a0	. ! . .
	ld iy,0b000h		;22e2	fd 21 00 b0	. ! . .
	ld bc,00002h		;22e6	01 02 00	. . .
	call 010a6h		;22e9	cd a6 10	. . .
	and 043h		;22ec	e6 43		. C
	ld (0fffeh),a		;22ee	32 fe ff	2 . .
	jr z,l22fdh		;22f1	28 0a		( .
	pop bc			;22f3	c1		.
	pop hl			;22f4	e1		.
	pop af			;22f5	f1		.
	ld a,b			;22f6	78		x
	call 00d7fh		;22f7	cd 7f 0d	. . .
	jp 00fefh		;22fa	c3 ef 0f	. . .
l22fdh:
	pop bc			;22fd	c1		.
	pop hl			;22fe	e1		.
	pop af			;22ff	f1		.
	jr nc,l2319h		;2300	30 17		0 .
	ld (hl),001h		;2302	36 01		6 .
	inc hl			;2304	23		#
	inc hl			;2305	23		#
	inc (hl)		;2306	34		4
	inc hl			;2307	23		#
	inc (hl)		;2308	34		4
	ld a,00fh		;2309	3e 0f		> .
	cp (hl)			;230b	be		.
	jp c,00fc9h		;230c	da c9 0f	. . .
	inc hl			;230f	23		#
l2310h:
	inc (hl)		;2310	34		4
	ld a,(hl)		;2311	7e		~
	cp 009h			;2312	fe 09		. .
	jr c,l2318h		;2314	38 02		8 .
	ld a,001h		;2316	3e 01		> .
l2318h:
	ld (hl),a		;2318	77		w
l2319h:
	ld a,b			;2319	78		x
	dec a			;231a	3d		=
	and 003h		;231b	e6 03		. .
	ld b,a			;231d	47		G
	call 00c82h		;231e	cd 82 0c	. . .
	ld a,(0fffeh)		;2321	3a fe ff	: . .
	cp 000h			;2324	fe 00		. .
	jp nz,00fefh		;2326	c2 ef 0f	. . .
	call 00da2h		;2329	cd a2 0d	. . .
	ld a,(hl)		;232c	7e		~
	cp 0aah			;232d	fe aa		. .
	jr nc,l2319h		;232f	30 e8		0 .
	inc hl			;2331	23		#
	inc hl			;2332	23		#
	ld d,000h		;2333	16 00		. .
	bit 0,(hl)		;2335	cb 46		. F
	jr z,l233dh		;2337	28 04		( .
	set 2,b			;2339	cb d0		. .
	ld d,001h		;233b	16 01		. .
l233dh:
	inc hl			;233d	23		#
	ld c,(hl)		;233e	4e		N
	inc hl			;233f	23		#
	ld e,(hl)		;2340	5e		^
	ld hl,(0ffc2h)		;2341	2a c2 ff	* . .
	dec hl			;2344	2b		+
	inc hl			;2345	23		#
	dec c			;2346	0d		.
	jp p,00f45h		;2347	f2 45 0f	. E .
	ld c,(hl)		;234a	4e		N
	cp 000h			;234b	fe 00		. .
	jr nz,l236ch		;234d	20 1d		  .
	ld a,b			;234f	78		x
	and 003h		;2350	e6 03		. .
	ld b,a			;2352	47		G
	call 00c82h		;2353	cd 82 0c	. . .
	ld a,(0fffeh)		;2356	3a fe ff	: . .
	cp 000h			;2359	fe 00		. .
	jp nz,00fefh		;235b	c2 ef 0f	. . .
	call 00a1dh		;235e	cd 1d 0a	. . .
	ld a,(0fffeh)		;2361	3a fe ff	: . .
	cp 000h			;2364	fe 00		. .
	jp nz,00fefh		;2366	c2 ef 0f	. . .
	jp 00e72h		;2369	c3 72 0e	. r .
l236ch:
	cp 001h			;236c	fe 01		. .
	jr nz,l237eh		;236e	20 0e		  .
	call 00a74h		;2370	cd 74 0a	. t .
	ld a,(0fffeh)		;2373	3a fe ff	: . .
	cp 000h			;2376	fe 00		. .
	jp nz,00fefh		;2378	c2 ef 0f	. . .
	jp 00e72h		;237b	c3 72 0e	. r .
l237eh:
	cp 002h			;237e	fe 02		. .
	jr nz,l239fh		;2380	20 1d		  .
	push bc			;2382	c5		.
	push de			;2383	d5		.
	ld bc,0a000h		;2384	01 00 a0	. . .
	ld de,001ffh		;2387	11 ff 01	. . .
	ld h,049h		;238a	26 49		& I
	call 00db0h		;238c	cd b0 0d	. . .
	pop de			;238f	d1		.
	pop bc			;2390	c1		.
	call 00bc4h		;2391	cd c4 0b	. . .
	ld a,(0fffeh)		;2394	3a fe ff	: . .
	cp 000h			;2397	fe 00		. .
	jp nz,00fefh		;2399	c2 ef 0f	. . .
l239ch:
	jp 00e72h		;239c	c3 72 0e	. r .
l239fh:
	push bc			;239f	c5		.
	push de			;23a0	d5		.
	ld hl,0b000h		;23a1	21 00 b0	! . .
	ld e,l			;23a4	5d		]
	ld d,h			;23a5	54		T
	inc de			;23a6	13		.
	ld (hl),000h		;23a7	36 00		6 .
	ld bc,001ffh		;23a9	01 ff 01	. . .
	ldir			;23ac	ed b0		. .
	ld bc,0b000h		;23ae	01 00 b0	. . .
	ld de,001ffh		;23b1	11 ff 01	. . .
	ld h,045h		;23b4	26 45		& E
	call 00db0h		;23b6	cd b0 0d	. . .
	pop de			;23b9	d1		.
	pop bc			;23ba	c1		.
	call 00ac1h		;23bb	cd c1 0a	. . .
	ld a,(0fffeh)		;23be	3a fe ff	: . .
	cp 000h			;23c1	fe 00		. .
	jp nz,00fefh		;23c3	c2 ef 0f	. . .
	jp 00e72h		;23c6	c3 72 0e	. r .
	ld a,b			;23c9	78		x
	call 00d7fh		;23ca	cd 7f 0d	. . .
	call 00da2h		;23cd	cd a2 0d	. . .
	ld (hl),0aah		;23d0	36 aa		6 .
	ld b,003h		;23d2	06 03		. .
	call 00da2h		;23d4	cd a2 0d	. . .
	ld a,(hl)		;23d7	7e		~
	cp 0aah			;23d8	fe aa		. .
	jp c,00f19h		;23da	da 19 0f	. . .
	dec b			;23dd	05		.
	jp p,00fd4h		;23de	f2 d4 0f	. . .
	xor a			;23e1	af		.
	ld (0fffeh),a		;23e2	32 fe ff	2 . .
	ld hl,0105ah		;23e5	21 5a 10	! Z .
	ld ix,(0fffch)		;23e8	dd 2a fc ff	. * . .
	call 01161h		;23ec	cd 61 11	. a .
	ld b,004h		;23ef	06 04		. .
l23f1h:
	dec b			;23f1	05		.
	jr z,$+16		;23f2	28 0e		( .
	call 00da2h		;23f4	cd a2 0d	. . .
	ld a,(hl)		;23f7	7e		~
	cp 0bbh			;23f8	fe bb		. .
	jr nc,l23f1h		;23fa	30 f5		0 .
	xor a			;23fc	af		.
	ld (hl),a		;23fd	77		w
	inc b			;23fe	04		.
	dec b			;23ff	05		.
	ld a,b			;2400	78		x
	out (0f2h),a		;2401	d3 f2		. .
	ld a,e			;2403	7b		{
	out (0f3h),a		;2404	d3 f3		. .
	ld a,d			;2406	7a		z
	out (0f3h),a		;2407	d3 f3		. .
	ld bc,0c000h		;2409	01 00 c0	. . .
	ld a,088h		;240c	3e 88		> .
	out (0fbh),a		;240e	d3 fb		. .
	out (0fch),a		;2410	d3 fc		. .
	ld a,c			;2412	79		y
	out (0f0h),a		;2413	d3 f0		. .
	ld a,b			;2415	78		x
	out (0f0h),a		;2416	d3 f0		. .
	ld a,00ch		;2418	3e 0c		> .
	out (0ffh),a		;241a	d3 ff		. .
	ld a,004h		;241c	3e 04		> .
	out (0f9h),a		;241e	d3 f9		. .
	ld b,002h		;2420	06 02		. .
	call 011d5h		;2422	cd d5 11	. . .
	ld a,020h		;2425	3e 20		>  
	out (0f8h),a		;2427	d3 f8		. .
	jr nz,l243ch		;2429	20 11		  .
	ld hl,0103eh		;242b	21 3e 10	! > .
	ld ix,(0fffch)		;242e	dd 2a fc ff	. * . .
	call 01161h		;2432	cd 61 11	. a .
	ld a,004h		;2435	3e 04		> .
	ld (0fffeh),a		;2437	32 fe ff	2 . .
	jr l2469h		;243a	18 2d		. -
l243ch:
	ld ix,0c000h		;243c	dd 21 00 c0	. ! . .
	ld iy,0c400h		;2440	fd 21 00 c4	. ! . .
	ld bc,00004h		;2444	01 04 00	. . .
	call 010a6h		;2447	cd a6 10	. . .
	and 003h		;244a	e6 03		. .
	ld (0fffeh),a		;244c	32 fe ff	2 . .
	cp 000h			;244f	fe 00		. .
	jr nz,l2469h		;2451	20 16		  .
	ld hl,0105ah		;2453	21 5a 10	! Z .
	ld ix,(0fffch)		;2456	dd 2a fc ff	. * . .
	call 01161h		;245a	cd 61 11	. a .
	in a,(001h)		;245d	db 01		. .
l245fh:
	in a,(001h)		;245f	db 01		. .
	bit 5,a			;2461	cb 6f		. o
	jr z,l245fh		;2463	28 fa		( .
	ld a,002h		;2465	3e 02		> .
	out (0fah),a		;2467	d3 fa		. .
l2469h:
	ld ix,0f140h		;2469	dd 21 40 f1	. ! @ .
	ld iy,005ach		;246d	fd 21 ac 05	. ! . .
	ld hl,0f190h		;2471	21 90 f1	! . .
	call 0119ch		;2474	cd 9c 11	. . .
	ld a,(0ffffh)		;2477	3a ff ff	: . .
	bit 6,a			;247a	cb 77		. w
	jp nz,005d5h		;247c	c2 d5 05	. . .
	ld a,(0fffeh)		;247f	3a fe ff	: . .
	jp 0049eh		;2482	c3 9e 04	. . .
	ld b,e			;2485	43		C
	ld d,h			;2486	54		T
	ld b,e			;2487	43		C
	dec l			;2488	2d		-
	ld (hl),h		;2489	74		t
	ld h,l			;248a	65		e
	ld (hl),e		;248b	73		s
	ld (hl),h		;248c	74		t
	jr nz,$+60		;248d	20 3a		  :
	jr nz,l24c0h		;248f	20 2f		  /
	ld l,(hl)		;2491	6e		n
	ld l,a			;2492	6f		o
	jr nz,$+107		;2493	20 69		  i
	ld l,(hl)		;2495	6e		n
	ld (hl),h		;2496	74		t
	ld h,l			;2497	65		e
	ld (hl),d		;2498	72		r
	ld (hl),d		;2499	72		r
	ld (hl),l		;249a	75		u
	ld (hl),b		;249b	70		p
	ld (hl),h		;249c	74		t
	inc l			;249d	2c		,
	ld h,e			;249e	63		c
	ld l,b			;249f	68		h
	jr nz,l24dch		;24a0	20 3a		  :
	cpl			;24a2	2f		/
	di			;24a3	f3		.
	ld a,003h		;24a4	3e 03		> .
	out (00ch),a		;24a6	d3 0c		. .
	ld a,(0fffbh)		;24a8	3a fb ff	: . .
	ld b,000h		;24ab	06 00		. .
	jr l24d3h		;24ad	18 24		. $
	di			;24af	f3		.
	ld a,003h		;24b0	3e 03		> .
	out (00dh),a		;24b2	d3 0d		. .
	ld a,(0fffbh)		;24b4	3a fb ff	: . .
	ld b,001h		;24b7	06 01		. .
sub_24b9h:
	jr l24d3h		;24b9	18 18		. .
	di			;24bb	f3		.
	ld a,003h		;24bc	3e 03		> .
	out (00eh),a		;24be	d3 0e		. .
l24c0h:
	ld a,(0fffbh)		;24c0	3a fb ff	: . .
	ld b,002h		;24c3	06 02		. .
	jr l24d3h		;24c5	18 0c		. .
	di			;24c7	f3		.
sub_24c8h:
	ld a,003h		;24c8	3e 03		> .
	out (00fh),a		;24ca	d3 0f		. .
	ld a,(0fffbh)		;24cc	3a fb ff	: . .
	ld b,003h		;24cf	06 03		. .
	jr l24d3h		;24d1	18 00		. .
l24d3h:
	cp b			;24d3	b8		.
	ld a,b			;24d4	78		x
	ld (0fff7h),a		;24d5	32 f7 ff	2 . .
	ld hl,00793h		;24d8	21 93 07	! . .
	ex (sp),hl		;24db	e3		.
l24dch:
	jr z,l24f5h		;24dc	28 17		( .
	ld hl,01082h		;24de	21 82 10	! . .
	ld ix,(0fffch)		;24e1	dd 2a fc ff	. * . .
	call 01161h		;24e5	cd 61 11	. a .
	ld a,(0fff7h)		;24e8	3a f7 ff	: . .
	ld b,00ch		;24eb	06 0c		. .
	add a,b			;24ed	80		.
	call 01180h		;24ee	cd 80 11	. . .
	ld a,009h		;24f1	3e 09		> .
	jr l24fah		;24f3	18 05		. .
l24f5h:
	ld hl,00757h		;24f5	21 57 07	! W .
	ex (sp),hl		;24f8	e3		.
	xor a			;24f9	af		.
l24fah:
	ld (0fffeh),a		;24fa	32 fe ff	2 . .
	reti			;24fd	ed 4d		. M
	ld ix,0f190h		;24ff	dd 21 90 f1	. ! . .
	ld hl,00685h		;2503	21 85 06	! . .
	call 01161h		;2506	cd 61 11	. a .
	ld hl,00218h		;2509	21 18 02	! . .
	ld a,l			;250c	7d		}
	out (00ch),a		;250d	d3 0c		. .
	xor a			;250f	af		.
	ld (0fffbh),a		;2510	32 fb ff	2 . .
l2513h:
	ld c,00ch		;2513	0e 0c		. .
	ld a,(0fffbh)		;2515	3a fb ff	: . .
	add a,c			;2518	81		.
	ld c,a			;2519	4f		O
	ld a,0e7h		;251a	3e e7		> .
	out (c),a		;251c	ed 79		. y
	ld a,0feh		;251e	3e fe		> .
	out (c),a		;2520	ed 79		. y
l2522h:
	ei			;2522	fb		.
sub_2523h:
	ld b,003h		;2523	06 03		. .
l2525h:
	ld hl,l30d4h		;2525	21 d4 30	! . 0
l2528h:
	dec hl			;2528	2b		+
	in a,(001h)		;2529	db 01		. .
	ld a,l			;252b	7d		}
	or h			;252c	b4		.
	jr nz,l2528h		;252d	20 f9		  .
	djnz l2525h		;252f	10 f4		. .
	di			;2531	f3		.
	ld a,(0fffbh)		;2532	3a fb ff	: . .
	ld c,00ch		;2535	0e 0c		. .
	add a,c			;2537	81		.
	ld c,a			;2538	4f		O
	ld a,003h		;2539	3e 03		> .
	out (c),a		;253b	ed 79		. y
	call 00264h		;253d	cd 64 02	. d .
	ld hl,00691h		;2540	21 91 06	! . .
	ld ix,(0fffch)		;2543	dd 2a fc ff	. * . .
	call 01161h		;2547	cd 61 11	. a .
	ld a,(0fffbh)		;254a	3a fb ff	: . .
	call 01180h		;254d	cd 80 11	. . .
sub_2550h:
	ld a,00bh		;2550	3e 0b		> .
	ld (0fffeh),a		;2552	32 fe ff	2 . .
	jr l2593h		;2555	18 3c		. <
	ld a,(0fffbh)		;2557	3a fb ff	: . .
	cp 003h			;255a	fe 03		. .
	jr z,l2585h		;255c	28 27		( '
	inc a			;255e	3c		<
	ld (0fffbh),a		;255f	32 fb ff	2 . .
	cp 002h			;2562	fe 02		. .
	jr c,l2513h		;2564	38 ad		8 .
	ld a,(0fffbh)		;2566	3a fb ff	: . .
	cp 003h			;2569	fe 03		. .
	jr z,l2579h		;256b	28 0c		( .
	ld c,00eh		;256d	0e 0e		. .
	ld a,0afh		;256f	3e af		> .
	out (c),a		;2571	ed 79		. y
	ld a,0feh		;2573	3e fe		> .
	out (c),a		;2575	ed 79		. y
	jr l2522h		;2577	18 a9		. .
l2579h:
	ld c,00fh		;2579	0e 0f		. .
	ld a,0a7h		;257b	3e a7		> .
	out (c),a		;257d	ed 79		. y
	ld a,0feh		;257f	3e fe		> .
	out (c),a		;2581	ed 79		. y
	jr l2522h		;2583	18 9d		. .
l2585h:
	ld hl,0105ah		;2585	21 5a 10	! Z .
	ld ix,(0fffch)		;2588	dd 2a fc ff	. * . .
	call 01161h		;258c	cd 61 11	. a .
	xor a			;258f	af		.
	ld (0fffeh),a		;2590	32 fe ff	2 . .
l2593h:
	ld ix,0f190h		;2593	dd 21 90 f1	. ! . .
	ld iy,00685h		;2597	fd 21 85 06	. ! . .
	ld hl,0f1e0h		;259b	21 e0 f1	! . .
	call 0119ch		;259e	cd 9c 11	. . .
	ld a,(0ffffh)		;25a1	3a ff ff	: . .
	bit 6,a			;25a4	cb 77		. w
	jp nz,0070fh		;25a6	c2 0f 07	. . .
	ld a,(0fffeh)		;25a9	3a fe ff	: . .
	jp 0049eh		;25ac	c3 9e 04	. . .
	ld b,(hl)		;25af	46		F
	ld b,h			;25b0	44		D
	ld b,e			;25b1	43		C
	ld e,a			;25b2	5f		_
	ld (hl),h		;25b3	74		t
	ld h,l			;25b4	65		e
	ld (hl),e		;25b5	73		s
	ld (hl),h		;25b6	74		t
	jr nz,l25f3h		;25b7	20 3a		  :
	jr nz,l25eah		;25b9	20 2f		  /
	ld l,(hl)		;25bb	6e		n
	ld l,a			;25bc	6f		o
	ld (hl),h		;25bd	74		t
	jr nz,$+116		;25be	20 72		  r
	ld h,l			;25c0	65		e
	ld h,c			;25c1	61		a
	ld h,h			;25c2	64		d
	ld a,c			;25c3	79		y
	jr nz,l2638h		;25c4	20 72		  r
	ld h,l			;25c6	65		e
	ld h,e			;25c7	63		c
	ld h,l			;25c8	65		e
	ld l,c			;25c9	69		i
	halt			;25ca	76		v
	ld h,l			;25cb	65		e
	dec l			;25cc	2d		-
	ld (hl),h		;25cd	74		t
	ld (hl),d		;25ce	72		r
	ld h,c			;25cf	61		a
	ld l,(hl)		;25d0	6e		n
	ld (hl),e		;25d1	73		s
	ld l,l			;25d2	6d		m
	ld l,c			;25d3	69		i
	ld (hl),h		;25d4	74		t
	jr nz,l2606h		;25d5	20 2f		  /
	ld (hl),a		;25d7	77		w
	ld (hl),d		;25d8	72		r
	ld l,a			;25d9	6f		o
	ld l,(hl)		;25da	6e		n
	ld h,a			;25db	67		g
	jr nz,$+102		;25dc	20 64		  d
	ld h,c			;25de	61		a
	ld (hl),h		;25df	74		t
	ld h,c			;25e0	61		a
	ld h,h			;25e1	64		d
	ld l,c			;25e2	69		i
	ld (hl),d		;25e3	72		r
	ld h,l			;25e4	65		e
	ld h,e			;25e5	63		c
	ld (hl),h		;25e6	74		t
	ld l,c			;25e7	69		i
	ld l,a			;25e8	6f		o
	ld l,(hl)		;25e9	6e		n
l25eah:
	cpl			;25ea	2f		/
	ld h,(hl)		;25eb	66		f
	ld h,c			;25ec	61		a
	ld (hl),l		;25ed	75		u
	ld l,h			;25ee	6c		l
	ld (hl),h		;25ef	74		t
	jr nz,l2665h		;25f0	20 73		  s
	ld (hl),h		;25f2	74		t
l25f3h:
	ld h,c			;25f3	61		a
	ld (hl),h		;25f4	74		t
	ld (hl),l		;25f5	75		u
	ld (hl),e		;25f6	73		s
	jr nz,l266bh		;25f7	20 72		  r
	ld h,l			;25f9	65		e
	ld h,a			;25fa	67		g
	ld l,c			;25fb	69		i
	ld (hl),e		;25fc	73		s
	ld (hl),h		;25fd	74		t
	ld h,l			;25fe	65		e
	ld (hl),d		;25ff	72		r
	jr $-15			;2600	18 ef		. .
	call 00da2h		;2602	cd a2 0d	. . .
	ld a,(hl)		;2605	7e		~
l2606h:
	cp 0bbh			;2606	fe bb		. .
	jr nc,l260ch		;2608	30 02		0 .
	xor a			;260a	af		.
	ld (hl),a		;260b	77		w
l260ch:
	ld a,0ffh		;260c	3e ff		> .
	out (005h),a		;260e	d3 05		. .
	call 00c4fh		;2610	cd 4f 0c	. O .
	ld bc,00002h		;2613	01 02 00	. . .
	ld hl,0a000h		;2616	21 00 a0	! . .
l2619h:
	inc (hl)		;2619	34		4
	inc hl			;261a	23		#
	djnz l2619h		;261b	10 fc		. .
	dec c			;261d	0d		.
	jr nz,l2619h		;261e	20 f9		  .
	ei			;2620	fb		.
	ld ix,0f320h		;2621	dd 21 20 f3	. !   .
	ld iy,00880h		;2625	fd 21 80 08	. ! . .
	ld hl,0f370h		;2629	21 70 f3	! p .
	di			;262c	f3		.
	call 0119ch		;262d	cd 9c 11	. . .
	ld a,(0ffffh)		;2630	3a ff ff	: . .
	bit 6,a			;2633	cb 77		. w
	jp nz,00e03h		;2635	c2 03 0e	. . .
l2638h:
	ld a,(0fffeh)		;2638	3a fe ff	: . .
	jp 0049eh		;263b	c3 9e 04	. . .
	jr nz,l2694h		;263e	20 54		  T
	ld b,e			;2640	43		C
	jr nz,l26b7h		;2641	20 74		  t
	ld l,c			;2643	69		i
	ld l,l			;2644	6d		m
	ld h,l			;2645	65		e
	ld l,a			;2646	6f		o
	ld (hl),l		;2647	75		u
	ld (hl),h		;2648	74		t
	jr nz,l267dh		;2649	20 32		  2
	jr nc,l267dh		;264b	30 30		0 0
	jr nz,l26bch		;264d	20 6d		  m
	ld (hl),e		;264f	73		s
	cpl			;2650	2f		/
	ld (hl),h		;2651	74		t
	ld l,c			;2652	69		i
	ld l,l			;2653	6d		m
	ld h,l			;2654	65		e
	ld l,a			;2655	6f		o
	ld (hl),l		;2656	75		u
	ld (hl),h		;2657	74		t
	jr nz,l2689h		;2658	20 2f		  /
	jr nz,$+81		;265a	20 4f		  O
	ld c,e			;265c	4b		K
	cpl			;265d	2f		/
	jr nz,$+102		;265e	20 64		  d
	ld h,c			;2660	61		a
	ld (hl),h		;2661	74		t
	ld h,c			;2662	61		a
	jr nz,$+103		;2663	20 65		  e
l2665h:
	ld (hl),d		;2665	72		r
	ld (hl),d		;2666	72		r
	ld l,a			;2667	6f		o
	ld (hl),d		;2668	72		r
	jr nz,l2697h		;2669	20 2c		  ,
l266bh:
	cpl			;266b	2f		/
	jr nz,$+100		;266c	20 62		  b
	ld a,c			;266e	79		y
	ld (hl),h		;266f	74		t
	ld h,l			;2670	65		e
	jr nz,$+112		;2671	20 6e		  n
	ld l,a			;2673	6f		o
	ld a,(l202fh)		;2674	3a 2f 20	: /  
	ld h,l			;2677	65		e
	ld a,b			;2678	78		x
	ld (hl),b		;2679	70		p
	ld a,(l202fh)		;267a	3a 2f 20	: /  
l267dh:
	ld (hl),d		;267d	72		r
	ld h,l			;267e	65		e
	ld h,e			;267f	63		c
	ld a,(l202fh)		;2680	3a 2f 20	: /  
	ld l,c			;2683	69		i
	ld l,h			;2684	6c		l
	ld l,h			;2685	6c		l
	ld h,l			;2686	65		e
	ld h,a			;2687	67		g
	ld h,c			;2688	61		a
l2689h:
	ld l,h			;2689	6c		l
	jr nz,$+107		;268a	20 69		  i
	ld l,(hl)		;268c	6e		n
	ld (hl),h		;268d	74		t
	ld h,l			;268e	65		e
	ld (hl),d		;268f	72		r
	ld (hl),d		;2690	72		r
	ld (hl),l		;2691	75		u
	ld (hl),b		;2692	70		p
	ld (hl),h		;2693	74		t
l2694h:
	inc l			;2694	2c		,
	ld (hl),b		;2695	70		p
	ld l,a			;2696	6f		o
l2697h:
	ld (hl),d		;2697	72		r
	ld (hl),h		;2698	74		t
	ld a,(0dd2fh)		;2699	3a 2f dd	: / .
	ld (hl),b		;269c	70		p
	nop			;269d	00		.
	inc ix			;269e	dd 23		. #
	djnz $-5		;26a0	10 f9		. .
	dec c			;26a2	0d		.
	jr nz,$-8		;26a3	20 f6		  .
	ret			;26a5	c9		.
	push de			;26a6	d5		.
	push hl			;26a7	e5		.
	push iy			;26a8	fd e5		. .
l26aah:
	ld a,(ix+000h)		;26aa	dd 7e 00	. ~ .
	ld d,(iy+000h)		;26ad	fd 56 00	. V .
	cp d			;26b0	ba		.
	jr nz,l26c1h		;26b1	20 0e		  .
	inc ix			;26b3	dd 23		. #
	inc iy			;26b5	fd 23		. #
l26b7h:
	djnz l26aah		;26b7	10 f1		. .
	dec c			;26b9	0d		.
	jr nz,l26aah		;26ba	20 ee		  .
l26bch:
	xor a			;26bc	af		.
	pop iy			;26bd	fd e1		. .
	jr l2703h		;26bf	18 42		. B
l26c1h:
	di			;26c1	f3		.
	ld e,a			;26c2	5f		_
	push iy			;26c3	fd e5		. .
	ld hl,0105eh		;26c5	21 5e 10	! ^ .
	call 01161h		;26c8	cd 61 11	. a .
	ld hl,0106ch		;26cb	21 6c 10	! l .
	call 01161h		;26ce	cd 61 11	. a .
	pop hl			;26d1	e1		.
	pop bc			;26d2	c1		.
	sbc hl,bc		;26d3	ed 42		. B
	ld a,h			;26d5	7c		|
	ld ix,(0fffch)		;26d6	dd 2a fc ff	. * . .
	call 01180h		;26da	cd 80 11	. . .
	ld a,l			;26dd	7d		}
	ld ix,(0fffch)		;26de	dd 2a fc ff	. * . .
	call 01180h		;26e2	cd 80 11	. . .
	ld hl,01076h		;26e5	21 76 10	! v .
	call 01161h		;26e8	cd 61 11	. a .
	ld a,e			;26eb	7b		{
	ld ix,(0fffch)		;26ec	dd 2a fc ff	. * . .
	call 01180h		;26f0	cd 80 11	. . .
	ld hl,0107ch		;26f3	21 7c 10	! | .
	call 01161h		;26f6	cd 61 11	. a .
	ld a,d			;26f9	7a		z
	ld ix,(0fffch)		;26fa	dd 2a fc ff	. * . .
	call 01180h		;26fe	cd 80 11	. . .
	ld a,0ffh		;2701	3e ff		> .
l2703h:
	pop hl			;2703	e1		.
	pop de			;2704	d1		.
	ret			;2705	c9		.
	push hl			;2706	e5		.
	ei			;2707	fb		.
l2708h:
	ld hl,l30d4h		;2708	21 d4 30	! . 0
l270bh:
	dec hl			;270b	2b		+
	ld a,l			;270c	7d		}
	or h			;270d	b4		.
	jr nz,l270bh		;270e	20 fb		  .
	djnz l2708h		;2710	10 f6		. .
	di			;2712	f3		.
	pop hl			;2713	e1		.
	ret			;2714	c9		.
	ld bc,0ffffh		;2715	01 ff ff	. . .
	scf			;2718	37		7
	ccf			;2719	3f		?
l271ah:
	inc bc			;271a	03		.
	sbc hl,de		;271b	ed 52		. R
	jr nc,l271ah		;271d	30 fb		0 .
	add hl,de		;271f	19		.
	ret			;2720	c9		.
	ld b,003h		;2721	06 03		. .
l2723h:
	sla l			;2723	cb 25		. %
	rl h			;2725	cb 14		. .
	djnz l2723h		;2727	10 fa		. .
	ret			;2729	c9		.
	djnz l2753h		;272a	10 27		. '
	ret pe			;272c	e8		.
	inc bc			;272d	03		.
	ld h,h			;272e	64		d
	nop			;272f	00		.
	ld a,(bc)		;2730	0a		.
	nop			;2731	00		.
	ld bc,03a00h		;2732	01 00 3a	. . :
	rst 38h			;2735	ff		.
	rst 38h			;2736	ff		.
	bit 4,a			;2737	cb 67		. g
	ret nz			;2739	c0		.
	push de			;273a	d5		.
	push iy			;273b	fd e5		. .
	push bc			;273d	c5		.
	ld iy,0112ah		;273e	fd 21 2a 11	. ! * .
l2742h:
	ld e,(iy+000h)		;2742	fd 5e 00	. ^ .
	ld d,(iy+001h)		;2745	fd 56 01	. V .
	call 01115h		;2748	cd 15 11	. . .
	ld a,030h		;274b	3e 30		> 0
	add a,c			;274d	81		.
	ld (ix+000h),a		;274e	dd 77 00	. w .
	inc ix			;2751	dd 23		. #
l2753h:
	inc iy			;2753	fd 23		. #
	inc iy			;2755	fd 23		. #
	ld a,001h		;2757	3e 01		> .
	cp e			;2759	bb		.
	jr nz,l2742h		;275a	20 e6		  .
	pop bc			;275c	c1		.
	pop iy			;275d	fd e1		. .
	pop de			;275f	d1		.
	ret			;2760	c9		.
	ld a,(0ffffh)		;2761	3a ff ff	: . .
	bit 4,a			;2764	cb 67		. g
	ret nz			;2766	c0		.
	push de			;2767	d5		.
	ld iy,0117ah		;2768	fd 21 7a 11	. ! z .
	ld d,h			;276c	54		T
	ld e,l			;276d	5d		]
	ld b,000h		;276e	06 00		. .
l2770h:
	ld a,(hl)		;2770	7e		~
	cp 02fh			;2771	fe 2f		. /
	jp z,00174h		;2773	ca 74 01	. t .
	inc b			;2776	04		.
	inc hl			;2777	23		#
	jr l2770h		;2778	18 f6		. .
	ld (0fffch),ix		;277a	dd 22 fc ff	. " . .
	pop de			;277e	d1		.
	ret			;277f	c9		.
	push hl			;2780	e5		.
	ld hl,0ffffh		;2781	21 ff ff	! . .
	bit 4,(hl)		;2784	cb 66		. f
	pop hl			;2786	e1		.
	ret nz			;2787	c0		.
	push de			;2788	d5		.
	push bc			;2789	c5		.
	ld (ix+000h),020h	;278a	dd 36 00 20	. 6 .  
	ld iy,01195h		;278e	fd 21 95 11	. ! . .
	jp 001d3h		;2792	c3 d3 01	. . .
	pop bc			;2795	c1		.
	ld (0fffch),ix		;2796	dd 22 fc ff	. " . .
	pop de			;279a	d1		.
	ret			;279b	c9		.
	ld a,(0fffeh)		;279c	3a fe ff	: . .
	call 0032fh		;279f	cd 2f 03	. / .
	ld a,(0ffffh)		;27a2	3a ff ff	: . .
	bit 4,a			;27a5	cb 67		. g
	ret nz			;27a7	c0		.
	push de			;27a8	d5		.
	push bc			;27a9	c5		.
	xor a			;27aa	af		.
	ld bc,(0fffch)		;27ab	ed 4b fc ff	. K . .
	sbc hl,bc		;27af	ed 42		. B
	jr nc,l27d2h		;27b1	30 1f		0 .
l27b3h:
	ld a,(iy+000h)		;27b3	fd 7e 00	. ~ .
sub_27b6h:
	cp 02fh			;27b6	fe 2f		. /
	jr z,l27c0h		;27b8	28 06		( .
	inc ix			;27ba	dd 23		. #
	inc iy			;27bc	fd 23		. #
	jr l27b3h		;27be	18 f3		. .
l27c0h:
	ld (0fffch),ix		;27c0	dd 22 fc ff	. " . .
	ld hl,(0fffch)		;27c4	2a fc ff	* . .
l27c7h:
	ld (hl),020h		;27c7	36 20		6  
	inc hl			;27c9	23		#
	ld a,b			;27ca	78		x
	cp h			;27cb	bc		.
	jr nz,l27c7h		;27cc	20 f9		  .
	ld a,c			;27ce	79		y
	cp l			;27cf	bd		.
	jr nc,l27c7h		;27d0	30 f5		0 .
l27d2h:
	pop bc			;27d2	c1		.
	pop de			;27d3	d1		.
	ret			;27d4	c9		.
	push hl			;27d5	e5		.
	ld hl,l32c8h		;27d6	21 c8 32	! . 2
l27d9h:
	in a,(0f8h)		;27d9	db f8		. .
	and 00fh		;27db	e6 0f		. .
	and b			;27dd	a0		.
	jr nz,l27e5h		;27de	20 05		  .
	dec hl			;27e0	2b		+
l27e1h:
	ld a,l			;27e1	7d		}
	or h			;27e2	b4		.
	jr nz,l27d9h		;27e3	20 f4		  .
l27e5h:
	pop hl			;27e5	e1		.
	ret			;27e6	c9		.
	inc b			;27e7	04		.
	ld b,a			;27e8	47		G
	inc bc			;27e9	03		.
	pop bc			;27ea	c1		.
	dec b			;27eb	05		.
	jp pe,01611h		;27ec	ea 11 16	. . .
	di			;27ef	f3		.
	ld b,008h		;27f0	06 08		. .
	otir			;27f2	ed b3		. .
	ret			;27f4	c9		.
	ld l,h			;27f5	6c		l
	ld l,c			;27f6	69		i
	ld l,(hl)		;27f7	6e		n
	ld h,l			;27f8	65		e
	ld (l203ah),a		;27f9	32 3a 20	2 :  
	cpl			;27fc	2f		/
	ld l,h			;27fd	6c		l
	ld l,c			;27fe	69		i
	ld l,(hl)		;27ff	6e		n
sub_2800h:
	jr nz,$+49		;2800	20 2f		  /
	ld hl,007afh		;2802	21 af 07	! . .
	ld ix,0f1e0h		;2805	dd 21 e0 f1	. ! . .
	call 01161h		;2809	cd 61 11	. a .
l280ch:
	in a,(004h)		;280c	db 04		. .
	bit 7,a			;280e	cb 7f		. .
	jr z,l2838h		;2810	28 26		( &
	ld a,0ffh		;2812	3e ff		> .
	out (005h),a		;2814	d3 05		. .
	ld b,001h		;2816	06 01		. .
	call 01106h		;2818	cd 06 11	. . .
	in a,(004h)		;281b	db 04		. .
	bit 7,a			;281d	cb 7f		. .
	jr z,l2838h		;281f	28 17		( .
	bit 6,a			;2821	cb 77		. w
	jr z,l2846h		;2823	28 21		( !
	in a,(005h)		;2825	db 05		. .
	cp 080h			;2827	fe 80		. .
	jr nz,l2854h		;2829	20 29		  )
	ld hl,0105ah		;282b	21 5a 10	! Z .
	ld ix,(0fffch)		;282e	dd 2a fc ff	. * . .
	call 01161h		;2832	cd 61 11	. a .
	xor a			;2835	af		.
	jr l2860h		;2836	18 28		. (
l2838h:
	ld hl,007bbh		;2838	21 bb 07	! . .
	ld ix,(0fffch)		;283b	dd 2a fc ff	. * . .
	call 01161h		;283f	cd 61 11	. a .
	ld a,018h		;2842	3e 18		> .
	jr l2860h		;2844	18 1a		. .
l2846h:
	ld hl,007d7h		;2846	21 d7 07	! . .
	ld ix,(0fffch)		;2849	dd 2a fc ff	. * . .
	call 01161h		;284d	cd 61 11	. a .
	ld a,019h		;2850	3e 19		> .
	jr l2860h		;2852	18 0c		. .
l2854h:
	ld hl,007ebh		;2854	21 eb 07	! . .
	ld ix,(0fffch)		;2857	dd 2a fc ff	. * . .
	call 01161h		;285b	cd 61 11	. a .
	ld a,020h		;285e	3e 20		>  
l2860h:
	ld (0fffeh),a		;2860	32 fe ff	2 . .
	ld hl,0f230h		;2863	21 30 f2	! 0 .
	ld ix,0f1e0h		;2866	dd 21 e0 f1	. ! . .
	ld iy,007afh		;286a	fd 21 af 07	. ! . .
	call 0119ch		;286e	cd 9c 11	. . .
	ei			;2871	fb		.
	ld a,(0ffffh)		;2872	3a ff ff	: . .
	bit 6,a			;2875	cb 77		. w
	di			;2877	f3		.
	jr nz,l280ch		;2878	20 92		  .
	ld a,(0fffeh)		;287a	3a fe ff	: . .
	jp 0049eh		;287d	c3 9e 04	. . .
	ld b,(hl)		;2880	46		F
	ld b,h			;2881	44		D
	ld b,h			;2882	44		D
	dec l			;2883	2d		-
	ld (hl),h		;2884	74		t
	ld h,l			;2885	65		e
	ld (hl),e		;2886	73		s
	ld (hl),h		;2887	74		t
	jr nz,l28c4h		;2888	20 3a		  :
	jr nz,l28bbh		;288a	20 2f		  /
	ld hl,(l6420h)		;288c	2a 20 64	*   d
	ld (hl),d		;288f	72		r
	ld l,c			;2890	69		i
	halt			;2891	76		v
	ld h,l			;2892	65		e
	ld a,(l2a2fh)		;2893	3a 2f 2a	: / *
	jr nz,l28feh		;2896	20 66		  f
	ld h,c			;2898	61		a
	ld (hl),l		;2899	75		u
	ld l,h			;289a	6c		l
	ld (hl),h		;289b	74		t
	jr nz,l2907h		;289c	20 69		  i
	ld l,(hl)		;289e	6e		n
	jr nz,l290eh		;289f	20 6d		  m
	ld h,c			;28a1	61		a
	ld l,c			;28a2	69		i
	ld l,(hl)		;28a3	6e		n
	jr nz,l2919h		;28a4	20 73		  s
	ld (hl),h		;28a6	74		t
	ld h,c			;28a7	61		a
	ld (hl),h		;28a8	74		t
	ld (hl),l		;28a9	75		u
	ld (hl),e		;28aa	73		s
	jr nz,l291fh		;28ab	20 72		  r
	ld h,l			;28ad	65		e
	ld h,a			;28ae	67		g
	cpl			;28af	2f		/
	ld hl,(06120h)		;28b0	2a 20 61	*   a
	ld l,h			;28b3	6c		l
	ld l,h			;28b4	6c		l
	jr nz,l291bh		;28b5	20 64		  d
	ld (hl),d		;28b7	72		r
	ld l,c			;28b8	69		i
	halt			;28b9	76		v
	ld h,l			;28ba	65		e
l28bbh:
	ld (hl),e		;28bb	73		s
	ld a,(l6e20h)		;28bc	3a 20 6e	:   n
	ld l,a			;28bf	6f		o
	ld (hl),h		;28c0	74		t
	jr nz,l2935h		;28c1	20 72		  r
	ld h,l			;28c3	65		e
l28c4h:
	ld h,c			;28c4	61		a
	ld h,h			;28c5	64		d
	ld a,c			;28c6	79		y
	cpl			;28c7	2f		/
	ld (hl),a		;28c8	77		w
	ld (hl),d		;28c9	72		r
	ld l,c			;28ca	69		i
	ld (hl),h		;28cb	74		t
	ld h,l			;28cc	65		e
	jr nz,l293fh		;28cd	20 70		  p
	ld (hl),d		;28cf	72		r
	ld l,a			;28d0	6f		o
	ld (hl),h		;28d1	74		t
	ld h,l			;28d2	65		e
	ld h,e			;28d3	63		c
	ld (hl),h		;28d4	74		t
	cpl			;28d5	2f		/
	ld (hl),h		;28d6	74		t
	ld l,c			;28d7	69		i
	ld l,l			;28d8	6d		m
	ld h,l			;28d9	65		e
	ld l,a			;28da	6f		o
	ld (hl),l		;28db	75		u
	ld (hl),h		;28dc	74		t
	cpl			;28dd	2f		/
	ld hl,(06620h)		;28de	2a 20 66	*   f
	ld h,c			;28e1	61		a
	ld (hl),l		;28e2	75		u
	ld l,h			;28e3	6c		l
	ld (hl),h		;28e4	74		t
	jr nz,l2950h		;28e5	20 69		  i
	ld l,(hl)		;28e7	6e		n
	jr nz,l2950h		;28e8	20 66		  f
	ld h,h			;28ea	64		d
	ld h,e			;28eb	63		c
	cpl			;28ec	2f		/
	ld (hl),e		;28ed	73		s
	ld h,l			;28ee	65		e
	ld h,l			;28ef	65		e
	ld l,e			;28f0	6b		k
	jr nz,l2958h		;28f1	20 65		  e
	ld (hl),d		;28f3	72		r
	ld (hl),d		;28f4	72		r
	ld l,a			;28f5	6f		o
	ld (hl),d		;28f6	72		r
	cpl			;28f7	2f		/
	ld h,e			;28f8	63		c
	ld l,a			;28f9	6f		o
	ld l,l			;28fa	6d		m
	ld l,l			;28fb	6d		m
	ld h,c			;28fc	61		a
	ld l,(hl)		;28fd	6e		n
l28feh:
	ld h,h			;28fe	64		d
	jr nz,l2962h		;28ff	20 61		  a
	ld h,d			;2901	62		b
	ld l,a			;2902	6f		o
	ld (hl),d		;2903	72		r
	ld (hl),h		;2904	74		t
	cpl			;2905	2f		/
	ld h,h			;2906	64		d
l2907h:
	ld l,a			;2907	6f		o
	ld l,a			;2908	6f		o
	ld (hl),d		;2909	72		r
	jr nz,l297bh		;290a	20 6f		  o
	ld (hl),b		;290c	70		p
	ld h,l			;290d	65		e
l290eh:
	ld l,(hl)		;290e	6e		n
	cpl			;290f	2f		/
	ld (hl),d		;2910	72		r
	ld h,l			;2911	65		e
	ld h,e			;2912	63		c
	ld h,c			;2913	61		a
	ld l,h			;2914	6c		l
	ld l,c			;2915	69		i
	ld h,d			;2916	62		b
	ld (hl),d		;2917	72		r
	ld h,c			;2918	61		a
l2919h:
	ld (hl),h		;2919	74		t
	ld h,l			;291a	65		e
l291bh:
	jr nz,l2982h		;291b	20 65		  e
	ld (hl),d		;291d	72		r
	ld (hl),d		;291e	72		r
l291fh:
	ld l,a			;291f	6f		o
	ld (hl),d		;2920	72		r
	cpl			;2921	2f		/
	ld l,(hl)		;2922	6e		n
	ld l,a			;2923	6f		o
	jr nz,l299ah		;2924	20 74		  t
	ld (hl),d		;2926	72		r
	ld h,c			;2927	61		a
	ld h,e			;2928	63		c
	ld l,e			;2929	6b		k
	jr nz,l295ch		;292a	20 30		  0
	jr nz,l29a1h		;292c	20 73		  s
	ld l,c			;292e	69		i
	ld h,a			;292f	67		g
	ld l,(hl)		;2930	6e		n
	ld h,c			;2931	61		a
	ld l,h			;2932	6c		l
	cpl			;2933	2f		/
	ld l,l			;2934	6d		m
l2935h:
	ld l,c			;2935	69		i
l2936h:
	ld (hl),e		;2936	73		s
	ld (hl),e		;2937	73		s
	ld l,c			;2938	69		i
sub_2939h:
	ld l,(hl)		;2939	6e		n
	ld h,a			;293a	67		g
	jr nz,l299eh		;293b	20 61		  a
	ld h,h			;293d	64		d
	ld h,h			;293e	64		d
l293fh:
	ld (hl),d		;293f	72		r
	ld h,l			;2940	65		e
	ld (hl),e		;2941	73		s
	ld (hl),e		;2942	73		s
	jr nz,l29b2h		;2943	20 6d		  m
	ld h,c			;2945	61		a
	ld (hl),d		;2946	72		r
	ld l,e			;2947	6b		k
	jr nz,l29aeh		;2948	20 64		  d
	ld h,c			;294a	61		a
	ld (hl),h		;294b	74		t
	ld h,c			;294c	61		a
	ld h,(hl)		;294d	66		f
	ld l,c			;294e	69		i
	ld h,l			;294f	65		e
l2950h:
	ld l,h			;2950	6c		l
	ld h,h			;2951	64		d
	cpl			;2952	2f		/
	ld h,d			;2953	62		b
	ld h,c			;2954	61		a
	ld h,h			;2955	64		d
	jr nz,l29bbh		;2956	20 63		  c
l2958h:
	ld a,c			;2958	79		y
	ld l,h			;2959	6c		l
	ld l,c			;295a	69		i
	ld l,(hl)		;295b	6e		n
l295ch:
	ld h,h			;295c	64		d
	ld h,l			;295d	65		e
	ld (hl),d		;295e	72		r
	cpl			;295f	2f		/
	ld (hl),a		;2960	77		w
	ld (hl),d		;2961	72		r
l2962h:
	ld l,a			;2962	6f		o
	ld l,(hl)		;2963	6e		n
	ld h,a			;2964	67		g
	jr nz,l29cah		;2965	20 63		  c
	ld a,c			;2967	79		y
	ld l,h			;2968	6c		l
	ld l,c			;2969	69		i
	ld l,(hl)		;296a	6e		n
	ld h,h			;296b	64		d
	ld h,l			;296c	65		e
	ld (hl),d		;296d	72		r
	cpl			;296e	2f		/
	ld l,l			;296f	6d		m
	ld l,c			;2970	69		i
	ld (hl),e		;2971	73		s
	ld (hl),e		;2972	73		s
	ld l,c			;2973	69		i
	ld l,(hl)		;2974	6e		n
	ld h,a			;2975	67		g
	jr nz,l29d9h		;2976	20 61		  a
	ld h,h			;2978	64		d
	ld h,h			;2979	64		d
	ld (hl),d		;297a	72		r
l297bh:
	ld h,l			;297b	65		e
	ld (hl),e		;297c	73		s
	ld (hl),e		;297d	73		s
	jr nz,l29edh		;297e	20 6d		  m
	ld h,c			;2980	61		a
	ld (hl),d		;2981	72		r
l2982h:
	ld l,e			;2982	6b		k
	jr nz,l29eeh		;2983	20 69		  i
	ld h,h			;2985	64		d
	ld e,a			;2986	5f		_
	ld h,(hl)		;2987	66		f
	ld l,c			;2988	69		i
	ld h,l			;2989	65		e
	ld l,h			;298a	6c		l
	ld h,h			;298b	64		d
	cpl			;298c	2f		/
	ld h,e			;298d	63		c
	ld h,c			;298e	61		a
	ld l,(hl)		;298f	6e		n
	ld l,(hl)		;2990	6e		n
	ld l,a			;2991	6f		o
	ld (hl),h		;2992	74		t
	jr nz,$+104		;2993	20 66		  f
	ld l,c			;2995	69		i
	ld l,(hl)		;2996	6e		n
	ld h,h			;2997	64		d
	jr nz,l2a0dh		;2998	20 73		  s
l299ah:
	ld h,l			;299a	65		e
	ld h,e			;299b	63		c
	ld (hl),h		;299c	74		t
	ld l,a			;299d	6f		o
l299eh:
	ld (hl),d		;299e	72		r
	cpl			;299f	2f		/
	ld h,e			;29a0	63		c
l29a1h:
	ld (hl),d		;29a1	72		r
l29a2h:
	ld h,e			;29a2	63		c
	jr nz,l2a0bh		;29a3	20 66		  f
	ld h,c			;29a5	61		a
	ld (hl),l		;29a6	75		u
	ld l,h			;29a7	6c		l
	ld (hl),h		;29a8	74		t
	jr nz,l2a14h		;29a9	20 69		  i
	ld h,h			;29ab	64		d
	ld e,a			;29ac	5f		_
	ld h,(hl)		;29ad	66		f
l29aeh:
	ld l,c			;29ae	69		i
	ld h,l			;29af	65		e
	ld l,h			;29b0	6c		l
	ld h,h			;29b1	64		d
l29b2h:
	cpl			;29b2	2f		/
	ld h,e			;29b3	63		c
	ld (hl),d		;29b4	72		r
	ld h,e			;29b5	63		c
	jr nz,l2a1eh		;29b6	20 66		  f
	ld h,c			;29b8	61		a
	ld (hl),l		;29b9	75		u
	ld l,h			;29ba	6c		l
l29bbh:
	ld (hl),h		;29bb	74		t
	jr nz,l2a22h		;29bc	20 64		  d
	ld h,c			;29be	61		a
	ld (hl),h		;29bf	74		t
	ld h,c			;29c0	61		a
	ld h,(hl)		;29c1	66		f
	ld l,c			;29c2	69		i
	ld h,l			;29c3	65		e
	ld l,h			;29c4	6c		l
	ld h,h			;29c5	64		d
	cpl			;29c6	2f		/
	ld l,a			;29c7	6f		o
	halt			;29c8	76		v
sub_29c9h:
	ld h,l			;29c9	65		e
l29cah:
	ld (hl),d		;29ca	72		r
	ld (hl),d		;29cb	72		r
	ld (hl),l		;29cc	75		u
	ld l,(hl)		;29cd	6e		n
	cpl			;29ce	2f		/
	ld h,c			;29cf	61		a
	ld h,e			;29d0	63		c
	ld h,e			;29d1	63		c
	ld h,l			;29d2	65		e
	ld (hl),e		;29d3	73		s
	ld (hl),e		;29d4	73		s
	jr nz,l2a39h		;29d5	20 62		  b
	ld h,l			;29d7	65		e
	ld a,c			;29d8	79		y
l29d9h:
	ld l,a			;29d9	6f		o
	ld l,(hl)		;29da	6e		n
	ld h,h			;29db	64		d
	jr nz,$+110		;29dc	20 6c		  l
	ld h,c			;29de	61		a
	ld (hl),e		;29df	73		s
	ld (hl),h		;29e0	74		t
	jr nz,l2a56h		;29e1	20 73		  s
	ld h,l			;29e3	65		e
	ld h,e			;29e4	63		c
	ld (hl),h		;29e5	74		t
	ld l,a			;29e6	6f		o
l29e7h:
	ld (hl),d		;29e7	72		r
	cpl			;29e8	2f		/
	dec b			;29e9	05		.
	inc a			;29ea	3c		<
	ld b,03bh		;29eb	06 3b		. ;
l29edh:
	rlca			;29ed	07		.
l29eeh:
	ld a,(02808h)		;29ee	3a 08 28	: . (
	add hl,sp		;29f1	39		9
	add hl,bc		;29f2	09		.
	jr c,l2a19h		;29f3	38 24		8 $
	dec a			;29f5	3d		=
	dec h			;29f6	25		%
	ld h,027h		;29f7	26 27		& '
	dec b			;29f9	05		.
	jr nz,$+8		;29fa	20 06		  .
	ld e,007h		;29fc	1e 07		. .
	inc e			;29fe	1c		.
	ex af,af'		;29ff	08		.
	ld h,l			;2a00	65		e
	ld sp,l203ah		;2a01	31 3a 20	1 :  
	cpl			;2a04	2f		/
	ld (hl),h		;2a05	74		t
	ld l,c			;2a06	69		i
	ld l,l			;2a07	6d		m
	ld h,l			;2a08	65		e
	ld l,a			;2a09	6f		o
	ld (hl),l		;2a0a	75		u
l2a0bh:
	ld (hl),h		;2a0b	74		t
	cpl			;2a0c	2f		/
l2a0dh:
	ld h,d			;2a0d	62		b
	ld (hl),b		;2a0e	70		p
	ld (hl),e		;2a0f	73		s
	cpl			;2a10	2f		/
	ld b,e			;2a11	43		C
	ld d,h			;2a12	54		T
	ld d,e			;2a13	53		S
l2a14h:
	jr nz,$+113		;2a14	20 6f		  o
	ld (hl),d		;2a16	72		r
	jr nz,$+70		;2a17	20 44		  D
l2a19h:
	ld b,e			;2a19	43		C
	ld b,h			;2a1a	44		D
	jr nz,l2a82h		;2a1b	20 65		  e
	ld (hl),d		;2a1d	72		r
l2a1eh:
	ld (hl),d		;2a1e	72		r
	ld l,a			;2a1f	6f		o
	ld (hl),d		;2a20	72		r
	inc l			;2a21	2c		,
l2a22h:
	cpl			;2a22	2f		/
	ld b,e			;2a23	43		C
	ld c,c			;2a24	49		I
	jr nz,l2a96h		;2a25	20 6f		  o
	ld (hl),d		;2a27	72		r
	jr nz,l2a6eh		;2a28	20 44		  D
	ld d,e			;2a2a	53		S
	ld d,d			;2a2b	52		R
	jr nz,l2a93h		;2a2c	20 65		  e
	ld (hl),d		;2a2e	72		r
l2a2fh:
	ld (hl),d		;2a2f	72		r
	ld l,a			;2a30	6f		o
	ld (hl),d		;2a31	72		r
	inc l			;2a32	2c		,
	cpl			;2a33	2f		/
	ld (hl),b		;2a34	70		p
	ld h,c			;2a35	61		a
	ld (hl),d		;2a36	72		r
	ld l,c			;2a37	69		i
	ld (hl),h		;2a38	74		t
l2a39h:
	ld a,c			;2a39	79		y
	jr nz,l2aa1h		;2a3a	20 65		  e
	ld (hl),d		;2a3c	72		r
	ld (hl),d		;2a3d	72		r
	ld l,a			;2a3e	6f		o
	ld (hl),d		;2a3f	72		r
	cpl			;2a40	2f		/
	ld (hl),d		;2a41	72		r
	ld h,l			;2a42	65		e
	ld h,e			;2a43	63		c
	ld h,l			;2a44	65		e
	ld l,c			;2a45	69		i
	halt			;2a46	76		v
	ld h,l			;2a47	65		e
	ld (hl),d		;2a48	72		r
	jr nz,$+113		;2a49	20 6f		  o
	halt			;2a4b	76		v
	ld h,l			;2a4c	65		e
	ld (hl),d		;2a4d	72		r
	ld (hl),d		;2a4e	72		r
	ld (hl),l		;2a4f	75		u
	ld l,(hl)		;2a50	6e		n
	cpl			;2a51	2f		/
	ld d,e			;2a52	53		S
	ld c,c			;2a53	49		I
	ld c,a			;2a54	4f		O
	dec l			;2a55	2d		-
l2a56h:
	ld (hl),h		;2a56	74		t
	ld h,l			;2a57	65		e
	ld (hl),e		;2a58	73		s
	ld (hl),h		;2a59	74		t
	jr nz,l2a96h		;2a5a	20 3a		  :
	jr nz,$+49		;2a5c	20 2f		  /
	nop			;2a5e	00		.
	nop			;2a5f	00		.
	add a,b			;2a60	80		.
	ex af,af'		;2a61	08		.
	add a,d			;2a62	82		.
	jr z,l29e7h		;2a63	28 82		( .
sub_2a65h:
	jr z,l2a6fh		;2a65	28 08		( .
	add hl,bc		;2a67	09		.
	dec bc			;2a68	0b		.
	dec bc			;2a69	0b		.
	inc bc			;2a6a	03		.
	rlca			;2a6b	07		.
	rrca			;2a6c	0f		.
	rrca			;2a6d	0f		.
l2a6eh:
	push af			;2a6e	f5		.
l2a6fh:
	push bc			;2a6f	c5		.
	ld c,00ah		;2a70	0e 0a		. .
	jr l2a78h		;2a72	18 04		. .
	push af			;2a74	f5		.
	push bc			;2a75	c5		.
	ld c,00bh		;2a76	0e 0b		. .
l2a78h:
	ld a,010h		;2a78	3e 10		> .
	out (c),a		;2a7a	ed 79		. y
	jr l2a82h		;2a7c	18 04		. .
	push af			;2a7e	f5		.
	push bc			;2a7f	c5		.
	ld c,00ch		;2a80	0e 0c		. .
l2a82h:
	ld ix,(0fffch)		;2a82	dd 2a fc ff	. * . .
	exx			;2a86	d9		.
	ld hl,01082h		;2a87	21 82 10	! . .
	ld c,000h		;2a8a	0e 00		. .
	call 01161h		;2a8c	cd 61 11	. a .
	exx			;2a8f	d9		.
	ld a,c			;2a90	79		y
	set 0,c			;2a91	cb c1		. .
l2a93h:
	call 01180h		;2a93	cd 80 11	. . .
l2a96h:
	pop bc			;2a96	c1		.
	ld a,010h		;2a97	3e 10		> .
	ld (0fffeh),a		;2a99	32 fe ff	2 . .
	pop af			;2a9c	f1		.
l2a9dh:
	ld hl,013e7h		;2a9d	21 e7 13	! . .
	ex (sp),hl		;2aa0	e3		.
l2aa1h:
	reti			;2aa1	ed 4d		. M
	ld hl,011fdh		;2aa3	21 fd 11	! . .
	ld c,00ah		;2aa6	0e 0a		. .
	jr l2ab1h		;2aa8	18 07		. .
	ld hl,011f5h		;2aaa	21 f5 11	! . .
	ld c,00bh		;2aad	0e 0b		. .
	jr l2ab1h		;2aaf	18 00		. .
l2ab1h:
	ld a,001h		;2ab1	3e 01		> .
	out (c),a		;2ab3	ed 79		. y
	in e,(c)		;2ab5	ed 58		. X
	ld a,030h		;2ab7	3e 30		> 0
	out (c),a		;2ab9	ed 79		. y
	ld a,012h		;2abb	3e 12		> .
	ld (0fffeh),a		;2abd	32 fe ff	2 . .
	ld ix,(0fffch)		;2ac0	dd 2a fc ff	. * . .
	ld c,000h		;2ac4	0e 00		. .
	call 01161h		;2ac6	cd 61 11	. a .
	bit 4,e			;2ac9	cb 63		. c
	jr z,l2ad2h		;2acb	28 05		( .
	ld hl,01234h		;2acd	21 34 12	! 4 .
	jr l2ad9h		;2ad0	18 07		. .
l2ad2h:
	bit 5,e			;2ad2	cb 6b		. k
	jr z,l2ad9h		;2ad4	28 03		( .
	ld hl,01241h		;2ad6	21 41 12	! A .
l2ad9h:
	ld c,000h		;2ad9	0e 00		. .
	call 01161h		;2adb	cd 61 11	. a .
	ld a,e			;2ade	7b		{
	set 0,c			;2adf	cb c1		. .
	call 01180h		;2ae1	cd 80 11	. . .
	jr l2a9dh		;2ae4	18 b7		. .
	push af			;2ae6	f5		.
	push hl			;2ae7	e5		.
	ld hl,0fff1h		;2ae8	21 f1 ff	! . .
	set 0,(hl)		;2aeb	cb c6		. .
	in a,(008h)		;2aed	db 08		. .
	ld hl,(0ffdah)		;2aef	2a da ff	* . .
	ld (hl),a		;2af2	77		w
	inc hl			;2af3	23		#
	ld (0ffdah),hl		;2af4	22 da ff	" . .
l2af7h:
	pop hl			;2af7	e1		.
	pop af			;2af8	f1		.
	ei			;2af9	fb		.
	reti			;2afa	ed 4d		. M
	push af			;2afc	f5		.
	push hl			;2afd	e5		.
	ld hl,0fff1h		;2afe	21 f1 ff	! . .
	set 1,(hl)		;2b01	cb ce		. .
	in a,(009h)		;2b03	db 09		. .
	ld hl,(0ffd8h)		;2b05	2a d8 ff	* . .
	ld (hl),a		;2b08	77		w
	inc hl			;2b09	23		#
	ld (0ffd8h),hl		;2b0a	22 d8 ff	" . .
	jr l2af7h		;2b0d	18 e8		. .
	push af			;2b0f	f5		.
	push hl			;2b10	e5		.
	ld hl,(0ffe6h)		;2b11	2a e6 ff	* . .
	inc hl			;2b14	23		#
	ld (0ffe6h),hl		;2b15	22 e6 ff	" . .
	ld hl,(0ffe0h)		;2b18	2a e0 ff	* . .
	ld a,0a0h		;2b1b	3e a0		> .
	cp h			;2b1d	bc		.
	jp z,0132bh		;2b1e	ca 2b 13	. + .
	ld a,(hl)		;2b21	7e		~
	out (009h),a		;2b22	d3 09		. .
	inc hl			;2b24	23		#
	ld (0ffe0h),hl		;2b25	22 e0 ff	" . .
	jp 01354h		;2b28	c3 54 13	. T .
	push bc			;2b2b	c5		.
	ld c,00bh		;2b2c	0e 0b		. .
	jr l2b4fh		;2b2e	18 1f		. .
	push af			;2b30	f5		.
	push hl			;2b31	e5		.
	ld hl,(0ffe8h)		;2b32	2a e8 ff	* . .
	inc hl			;2b35	23		#
	ld (0ffe8h),hl		;2b36	22 e8 ff	" . .
	ld hl,(0ffe2h)		;2b39	2a e2 ff	* . .
	ld a,0a0h		;2b3c	3e a0		> .
	cp h			;2b3e	bc		.
	jp z,0134ch		;2b3f	ca 4c 13	. L .
	ld a,(hl)		;2b42	7e		~
	out (008h),a		;2b43	d3 08		. .
	inc hl			;2b45	23		#
	ld (0ffe2h),hl		;2b46	22 e2 ff	" . .
	jp 01354h		;2b49	c3 54 13	. T .
	push bc			;2b4c	c5		.
	ld c,00ah		;2b4d	0e 0a		. .
l2b4fh:
	ld a,028h		;2b4f	3e 28		> (
	out (c),a		;2b51	ed 79		. y
	pop bc			;2b53	c1		.
	pop hl			;2b54	e1		.
	pop af			;2b55	f1		.
	reti			;2b56	ed 4d		. M
	ld a,03ch		;2b58	3e 3c		> <
	ld (0fff6h),a		;2b5a	32 f6 ff	2 . .
	ld hl,0ffe6h		;2b5d	21 e6 ff	! . .
	ld b,004h		;2b60	06 04		. .
l2b62h:
	ld (hl),000h		;2b62	36 00		6 .
	inc hl			;2b64	23		#
	djnz l2b62h		;2b65	10 fb		. .
	ld hl,00230h		;2b67	21 30 02	! 0 .
	ld a,l			;2b6a	7d		}
	out (00ch),a		;2b6b	d3 0c		. .
	ld a,0a7h		;2b6d	3e a7		> .
	out (00fh),a		;2b6f	d3 0f		. .
	ld a,0ffh		;2b71	3e ff		> .
	out (00fh),a		;2b73	d3 0f		. .
	ret			;2b75	c9		.
	push af			;2b76	f5		.
	push bc			;2b77	c5		.
	push de			;2b78	d5		.
	push hl			;2b79	e5		.
	push iy			;2b7a	fd e5		. .
	push ix			;2b7c	dd e5		. .
	ld hl,0fff6h		;2b7e	21 f6 ff	! . .
	dec (hl)		;2b81	35		5
	jr nz,l2bc5h		;2b82	20 41		  A
	ld ix,(0fffch)		;2b84	dd 2a fc ff	. * . .
	push ix			;2b88	dd e5		. .
	ld a,(0ffeah)		;2b8a	3a ea ff	: . .
	bit 0,a			;2b8d	cb 47		. G
	jr nz,l2ba3h		;2b8f	20 12		  .
	ld ix,0f2d0h		;2b91	dd 21 d0 f2	. ! . .
	ld hl,011fdh		;2b95	21 fd 11	! . .
	ld c,000h		;2b98	0e 00		. .
	call 01161h		;2b9a	cd 61 11	. a .
	ld hl,(0ffe8h)		;2b9d	2a e8 ff	* . .
	call 013d0h		;2ba0	cd d0 13	. . .
l2ba3h:
	ld a,(0ffeah)		;2ba3	3a ea ff	: . .
	bit 1,a			;2ba6	cb 4f		. O
	jr nz,l2bbch		;2ba8	20 12		  .
	ld ix,0f2e4h		;2baa	dd 21 e4 f2	. ! . .
	ld hl,011f5h		;2bae	21 f5 11	! . .
	ld c,000h		;2bb1	0e 00		. .
	call 01161h		;2bb3	cd 61 11	. a .
	ld hl,(0ffe6h)		;2bb6	2a e6 ff	* . .
	call 013d0h		;2bb9	cd d0 13	. . .
l2bbch:
	pop ix			;2bbc	dd e1		. .
	ld (0fffch),ix		;2bbe	dd 22 fc ff	. " . .
	call 01358h		;2bc2	cd 58 13	. X .
l2bc5h:
	pop ix			;2bc5	dd e1		. .
	pop iy			;2bc7	fd e1		. .
	pop hl			;2bc9	e1		.
	pop de			;2bca	d1		.
	pop bc			;2bcb	c1		.
	pop af			;2bcc	f1		.
	ei			;2bcd	fb		.
	reti			;2bce	ed 4d		. M
	ex de,hl		;2bd0	eb		.
	ld hl,00000h		;2bd1	21 00 00	! . .
	add hl,de		;2bd4	19		.
	call 01121h		;2bd5	cd 21 11	. ! .
	add hl,de		;2bd8	19		.
	add hl,de		;2bd9	19		.
	add hl,de		;2bda	19		.
	call 01134h		;2bdb	cd 34 11	. 4 .
	ld hl,0120dh		;2bde	21 0d 12	! . .
	set 0,c			;2be1	cb c1		. .
	call 01161h		;2be3	cd 61 11	. a .
	ret			;2be6	c9		.
	ld a,(0fffeh)		;2be7	3a fe ff	: . .
	cp 000h			;2bea	fe 00		. .
	jr z,l2bf4h		;2bec	28 06		( .
	di			;2bee	f3		.
	ld hl,015dfh		;2bef	21 df 15	! . .
	ex (sp),hl		;2bf2	e3		.
	ret			;2bf3	c9		.
l2bf4h:
	ei			;2bf4	fb		.
	ld hl,(0ffdah)		;2bf5	2a da ff	* . .
	ld bc,0b000h		;2bf8	01 00 b0	. . .
	scf			;2bfb	37		7
	ccf			;2bfc	3f		?
	sbc hl,bc		;2bfd	ed 42		. B
	jr c,$-108		;2bff	38 92		8 .
	add hl,de		;2c01	19		.
	cp 0ffh			;2c02	fe ff		. .
	jp z,01d56h		;2c04	ca 56 1d	. V .
	ld c,a			;2c07	4f		O
	ld b,009h		;2c08	06 09		. .
l2c0ah:
	add a,c			;2c0a	81		.
	dec b			;2c0b	05		.
	jr nz,l2c0ah		;2c0c	20 fc		  .
	ld (0f80ch),a		;2c0e	32 0c f8	2 . .
	ld hl,0f1edh		;2c11	21 ed f1	! . .
	ld (hl),d		;2c14	72		r
	pop af			;2c15	f1		.
	reti			;2c16	ed 4d		. M
	in a,(010h)		;2c18	db 10		. .
	ld d,a			;2c1a	57		W
	call 01992h		;2c1b	cd 92 19	. . .
	cp 0ffh			;2c1e	fe ff		. .
	jp z,01d56h		;2c20	ca 56 1d	. V .
	ld hl,0f80ch		;2c23	21 0c f8	! . .
	add a,(hl)		;2c26	86		.
	ld (0f80ch),a		;2c27	32 0c f8	2 . .
	ld hl,0f1eeh		;2c2a	21 ee f1	! . .
	ld (hl),d		;2c2d	72		r
	pop af			;2c2e	f1		.
	reti			;2c2f	ed 4d		. M
	in a,(010h)		;2c31	db 10		. .
	ld d,a			;2c33	57		W
	call 01992h		;2c34	cd 92 19	. . .
	cp 0ffh			;2c37	fe ff		. .
	jp z,01d56h		;2c39	ca 56 1d	. V .
	ld c,a			;2c3c	4f		O
	ld b,009h		;2c3d	06 09		. .
l2c3fh:
	add a,c			;2c3f	81		.
	dec b			;2c40	05		.
	jr nz,l2c3fh		;2c41	20 fc		  .
	ld (0f80eh),a		;2c43	32 0e f8	2 . .
	ld hl,0f23bh		;2c46	21 3b f2	! ; .
	ld (hl),d		;2c49	72		r
	pop af			;2c4a	f1		.
	reti			;2c4b	ed 4d		. M
	in a,(010h)		;2c4d	db 10		. .
	ld d,a			;2c4f	57		W
	call 01992h		;2c50	cd 92 19	. . .
	cp 0ffh			;2c53	fe ff		. .
	jp z,01d56h		;2c55	ca 56 1d	. V .
	ld hl,0f80eh		;2c58	21 0e f8	! . .
	add a,(hl)		;2c5b	86		.
	ld (0f80eh),a		;2c5c	32 0e f8	2 . .
	ld hl,0f23ch		;2c5f	21 3c f2	! < .
	ld (hl),d		;2c62	72		r
	pop af			;2c63	f1		.
	reti			;2c64	ed 4d		. M
	in a,(010h)		;2c66	db 10		. .
	ld d,a			;2c68	57		W
	call 01992h		;2c69	cd 92 19	. . .
	cp 002h			;2c6c	fe 02		. .
	jp nc,01d56h		;2c6e	d2 56 1d	. V .
	ld c,a			;2c71	4f		O
	ld b,009h		;2c72	06 09		. .
l2c74h:
	add a,c			;2c74	81		.
	dec b			;2c75	05		.
	jr nz,l2c74h		;2c76	20 fc		  .
	ld (0f88eh),a		;2c78	32 8e f8	2 . .
	ld hl,0f296h		;2c7b	21 96 f2	! . .
	ld (hl),d		;2c7e	72		r
	pop af			;2c7f	f1		.
	reti			;2c80	ed 4d		. M
	in a,(010h)		;2c82	db 10		. .
	ld d,a			;2c84	57		W
	call 01992h		;2c85	cd 92 19	. . .
	cp 0ffh			;2c88	fe ff		. .
	jp z,01d56h		;2c8a	ca 56 1d	. V .
	ld hl,0f297h		;2c8d	21 97 f2	! . .
	ld (hl),d		;2c90	72		r
	ld hl,0f88eh		;2c91	21 8e f8	! . .
	add a,(hl)		;2c94	86		.
	cp 010h			;2c95	fe 10		. .
	jr nc,l2c9fh		;2c97	30 06		0 .
	ld (0f88eh),a		;2c99	32 8e f8	2 . .
	pop af			;2c9c	f1		.
	reti			;2c9d	ed 4d		. M
l2c9fh:
	ld a,010h		;2c9f	3e 10		> .
	ld (0f88eh),a		;2ca1	32 8e f8	2 . .
	pop af			;2ca4	f1		.
	reti			;2ca5	ed 4d		. M
	in a,(010h)		;2ca7	db 10		. .
	ld d,a			;2ca9	57		W
	call 01992h		;2caa	cd 92 19	. . .
	cp 002h			;2cad	fe 02		. .
	jp nc,01d56h		;2caf	d2 56 1d	. V .
	ld (0f814h),a		;2cb2	32 14 f8	2 . .
	ld hl,0f1abh		;2cb5	21 ab f1	! . .
	ld (hl),d		;2cb8	72		r
	pop af			;2cb9	f1		.
	reti			;2cba	ed 4d		. M
	in a,(010h)		;2cbc	db 10		. .
	ld d,a			;2cbe	57		W
	call 01992h		;2cbf	cd 92 19	. . .
	cp 0ffh			;2cc2	fe ff		. .
	jp z,01d56h		;2cc4	ca 56 1d	. V .
	ld (0f88ah),a		;2cc7	32 8a f8	2 . .
	ld hl,0f2e0h		;2cca	21 e0 f2	! . .
	ld (hl),d		;2ccd	72		r
	pop af			;2cce	f1		.
	reti			;2ccf	ed 4d		. M
	in a,(010h)		;2cd1	db 10		. .
	ld d,a			;2cd3	57		W
	call 01992h		;2cd4	cd 92 19	. . .
	cp 002h			;2cd7	fe 02		. .
	jr nc,l2d56h		;2cd9	30 7b		0 {
	ld (0f88ch),a		;2cdb	32 8c f8	2 . .
	ld hl,0f34ch		;2cde	21 4c f3	! L .
	ld (hl),d		;2ce1	72		r
	pop af			;2ce2	f1		.
	reti			;2ce3	ed 4d		. M
	in a,(010h)		;2ce5	db 10		. .
	ld d,a			;2ce7	57		W
	call 01992h		;2ce8	cd 92 19	. . .
	cp 002h			;2ceb	fe 02		. .
	jr nc,l2d56h		;2ced	30 67		0 g
	ld (0f888h),a		;2cef	32 88 f8	2 . .
	ld hl,0f38eh		;2cf2	21 8e f3	! . .
	ld (hl),d		;2cf5	72		r
	pop af			;2cf6	f1		.
	reti			;2cf7	ed 4d		. M
	in a,(010h)		;2cf9	db 10		. .
	ld d,a			;2cfb	57		W
	call 01992h		;2cfc	cd 92 19	. . .
	cp 002h			;2cff	fe 02		. .
	jr nc,l2d56h		;2d01	30 53		0 S
	ld (0f87ch),a		;2d03	32 7c f8	2 | .
l2d06h:
	ld a,(0f88ch)		;2d06	3a 8c f8	: . .
	cp 000h			;2d09	fe 00		. .
	jr nz,l2d13h		;2d0b	20 06		  .
	ld hl,0f386h		;2d0d	21 86 f3	! . .
	ld (hl),d		;2d10	72		r
	jr l2d17h		;2d11	18 04		. .
l2d13h:
	ld hl,0f3d6h		;2d13	21 d6 f3	! . .
	ld (hl),d		;2d16	72		r
l2d17h:
	pop af			;2d17	f1		.
	reti			;2d18	ed 4d		. M
	ei			;2d1a	fb		.
	ld hl,0ffffh		;2d1b	21 ff ff	! . .
l2d1eh:
	dec hl			;2d1e	2b		+
	ld a,l			;2d1f	7d		}
	or h			;2d20	b4		.
	jr nz,l2d1eh		;2d21	20 fb		  .
	di			;2d23	f3		.
	ld a,003h		;2d24	3e 03		> .
	out (00fh),a		;2d26	d3 0f		. .
l2d28h:
	in a,(010h)		;2d28	db 10		. .
	cp 046h			;2d2a	fe 46		. F
	jr nz,l2d3ah		;2d2c	20 0c		  .
	call 019b9h		;2d2e	cd b9 19	. . .
	ld sp,(0ffffh)		;2d31	ed 7b ff ff	. { . .
	xor a			;2d35	af		.
	di			;2d36	f3		.
	jp 00155h		;2d37	c3 55 01	. U .
l2d3ah:
	cp 048h			;2d3a	fe 48		. H
	jr z,l2d28h		;2d3c	28 ea		( .
	cp 052h			;2d3e	fe 52		. R
	jr nz,l2d4bh		;2d40	20 09		  .
	call 00264h		;2d42	cd 64 02	. d .
	ld sp,l8000h		;2d45	31 00 80	1 . .
	jp 0258dh		;2d48	c3 8d 25	. . %
l2d4bh:
	ld a,0d7h		;2d4b	3e d7		> .
	out (00fh),a		;2d4d	d3 0f		. .
	ld a,001h		;2d4f	3e 01		> .
	out (00fh),a		;2d51	d3 0f		. .
	pop af			;2d53	f1		.
	reti			;2d54	ed 4d		. M
l2d56h:
	pop af			;2d56	f1		.
	ld a,03fh		;2d57	3e 3f		> ?
	ld de,0f708h		;2d59	11 08 f7	. . .
	ld (de),a		;2d5c	12		.
	reti			;2d5d	ed 4d		. M
	push af			;2d5f	f5		.
	push bc			;2d60	c5		.
	push de			;2d61	d5		.
	push hl			;2d62	e5		.
	ld a,(0f80ah)		;2d63	3a 0a f8	: . .
	cp 005h			;2d66	fe 05		. .
	jp z,l1d90h		;2d68	ca 90 1d	. . .
	cp 004h			;2d6b	fe 04		. .
	jr z,l2d90h		;2d6d	28 21		( !
	cp 003h			;2d6f	fe 03		. .
	jr z,l2d89h		;2d71	28 16		( .
	cp 002h			;2d73	fe 02		. .
	jr z,l2d82h		;2d75	28 0b		( .
	ld a,001h		;2d77	3e 01		> .
	ld (0f826h),a		;2d79	32 26 f8	2 & .
l2d7ch:
	pop hl			;2d7c	e1		.
	pop de			;2d7d	d1		.
	pop bc			;2d7e	c1		.
	pop af			;2d7f	f1		.
	reti			;2d80	ed 4d		. M
l2d82h:
	ld a,001h		;2d82	3e 01		> .
	ld (0f826h),a		;2d84	32 26 f8	2 & .
	jr l2d7ch		;2d87	18 f3		. .
l2d89h:
	ld a,001h		;2d89	3e 01		> .
	ld (0f826h),a		;2d8b	32 26 f8	2 & .
	jr l2d7ch		;2d8e	18 ec		. .
l2d90h:
	ld a,001h		;2d90	3e 01		> .
	ld (0f826h),a		;2d92	32 26 f8	2 & .
	call 00c4fh		;2d95	cd 4f 0c	. O .
	jp nz,l2ec7h		;2d98	c2 c7 2e	. . .
	push af			;2d9b	f5		.
	bit 7,a			;2d9c	cb 7f		. .
	jr nz,l2dceh		;2d9e	20 2e		  .
	bit 6,a			;2da0	cb 77		. w
	jr nz,l2dceh		;2da2	20 2a		  *
	ld a,(0f88ch)		;2da4	3a 8c f8	: . .
	cp 000h			;2da7	fe 00		. .
	jr nz,l2db7h		;2da9	20 0c		  .
	ld a,(0f80ah)		;2dab	3a 0a f8	: . .
	cp 005h			;2dae	fe 05		. .
	jr nz,l2db7h		;2db0	20 05		  .
	call sub_19c8h		;2db2	cd c8 19	. . .
	jr nz,l2dceh		;2db5	20 17		  .
l2db7h:
	pop af			;2db7	f1		.
	xor a			;2db8	af		.
	ld (0f870h),a		;2db9	32 70 f8	2 p .
	ld (0f872h),a		;2dbc	32 72 f8	2 r .
	ld b,006h		;2dbf	06 06		. .
l2dc1h:
	call 00c4fh		;2dc1	cd 4f 0c	. O .
	jp nz,l2ec7h		;2dc4	c2 c7 2e	. . .
	djnz l2dc1h		;2dc7	10 f8		. .
	call sub_1b2ah		;2dc9	cd 2a 1b	. * .
	jr l2d7ch		;2dcc	18 ae		. .
l2dceh:
	ld ix,0f900h		;2dce	dd 21 00 f9	. ! . .
	ld b,006h		;2dd2	06 06		. .
l2dd4h:
	call 00c4fh		;2dd4	cd 4f 0c	. O .
	jp nz,l2ec7h		;2dd7	c2 c7 2e	. . .
	ld (ix+000h),a		;2dda	dd 77 00	. w .
	inc ix			;2ddd	dd 23		. #
	djnz l2dd4h		;2ddf	10 f3		. .
	ld ix,0f900h		;2de1	dd 21 00 f9	. ! . .
	ld iy,0f88ah		;2de5	fd 21 8a f8	. ! . .
	ld bc,(0f88ah)		;2de9	ed 4b 8a f8	. K . .
	pop af			;2ded	f1		.
l2deeh:
	bit 7,a			;2dee	cb 7f		. .
	jr nz,$+29		;2df0	20 1b		  .
	bit 6,a			;2df2	cb 77		. w
	jr nz,$+120		;2df4	20 76		  v
	ld a,(0f872h)		;2df6	3a 72 f8	: r .
	cp (iy+000h)		;2df9	fd be 00	. . .
	jr z,$+17		;2dfc	28 0f		( .
	inc a			;2dfe	3c		<
	ld (l212dh),a		;2dff	32 2d 21	2 - !
	jp pe,0cbffh		;2e02	ea ff cb	. . .
	ld b,(hl)		;2e05	46		F
	jr nz,l2e2eh		;2e06	20 26		  &
	set 0,(hl)		;2e08	cb c6		. .
	di			;2e0a	f3		.
	ld hl,011fdh		;2e0b	21 fd 11	! . .
	ld ix,(0fffch)		;2e0e	dd 2a fc ff	. * . .
	set 0,c			;2e12	cb c1		. .
	call 01161h		;2e14	cd 61 11	. a .
	ld bc,00010h		;2e17	01 10 00	. . .
	ld iy,0a000h		;2e1a	fd 21 00 a0	. ! . .
	ld ix,l9000h		;2e1e	dd 21 00 90	. ! . .
	call 010a6h		;2e22	cd a6 10	. . .
	and 013h		;2e25	e6 13		. .
	cp 000h			;2e27	fe 00		. .
	ld (0fffeh),a		;2e29	32 fe ff	2 . .
	jr nz,$-69		;2e2c	20 b9		  .
l2e2eh:
	ld hl,(0ffd8h)		;2e2e	2a d8 ff	* . .
	ld bc,0c000h		;2e31	01 00 c0	. . .
	scf			;2e34	37		7
	ccf			;2e35	3f		?
	sbc hl,bc		;2e36	ed 42		. B
	jr c,l2e67h		;2e38	38 2d		8 -
	ld hl,0ffeah		;2e3a	21 ea ff	! . .
	bit 1,(hl)		;2e3d	cb 4e		. N
	jr nz,l2e67h		;2e3f	20 26		  &
	set 1,(hl)		;2e41	cb ce		. .
	di			;2e43	f3		.
	ld hl,011f5h		;2e44	21 f5 11	! . .
	ld ix,(0fffch)		;2e47	dd 2a fc ff	. * . .
	set 0,c			;2e4b	cb c1		. .
	call 01161h		;2e4d	cd 61 11	. a .
	ld bc,00010h		;2e50	01 10 00	. . .
	ld iy,0b000h		;2e53	fd 21 00 b0	. ! . .
	ld ix,l9000h		;2e57	dd 21 00 90	. ! . .
	call 010a6h		;2e5b	cd a6 10	. . .
	and 014h		;2e5e	e6 14		. .
	ld (0fffeh),a		;2e60	32 fe ff	2 . .
	cp 000h			;2e63	fe 00		. .
	jr nz,$-126		;2e65	20 80		  .
l2e67h:
	ld hl,(0fff3h)		;2e67	2a f3 ff	* . .
	dec hl			;2e6a	2b		+
	ld (0fff3h),hl		;2e6b	22 f3 ff	" . .
	xor a			;2e6e	af		.
	cp l			;2e6f	bd		.
	jp nz,013e7h		;2e70	c2 e7 13	. . .
	cp h			;2e73	bc		.
	jp nz,013e7h		;2e74	c2 e7 13	. . .
	ld hl,00fffh		;2e77	21 ff 0f	! . .
	ld (0fff3h),hl		;2e7a	22 f3 ff	" . .
	ld a,(0fff1h)		;2e7d	3a f1 ff	: . .
	ld b,a			;2e80	47		G
	ld a,(0ffeah)		;2e81	3a ea ff	: . .
	or b			;2e84	b0		.
	ld (0fff1h),a		;2e85	32 f1 ff	2 . .
	bit 0,a			;2e88	cb 47		. G
	jr nz,l2ea9h		;2e8a	20 1d		  .
	ld a,00ch		;2e8c	3e 0c		> .
	ld (0fffeh),a		;2e8e	32 fe ff	2 . .
	ld hl,011fdh		;2e91	21 fd 11	! . .
l2e94h:
	di			;2e94	f3		.
	ld ix,(0fffch)		;2e95	dd 2a fc ff	. * . .
	ld c,000h		;2e99	0e 00		. .
	call 01161h		;2e9b	cd 61 11	. a .
	ld hl,01205h		;2e9e	21 05 12	! . .
	set 0,c			;2ea1	cb c1		. .
	call 01161h		;2ea3	cd 61 11	. a .
l2ea6h:
	jp 013e7h		;2ea6	c3 e7 13	. . .
l2ea9h:
	ld a,(0fff1h)		;2ea9	3a f1 ff	: . .
	bit 1,a			;2eac	cb 4f		. O
	jr nz,l2ebah		;2eae	20 0a		  .
	ld hl,011f5h		;2eb0	21 f5 11	! . .
	ld a,00dh		;2eb3	3e 0d		> .
	ld (0fffeh),a		;2eb5	32 fe ff	2 . .
	jr l2e94h		;2eb8	18 da		. .
l2ebah:
	ld a,(0ffeah)		;2eba	3a ea ff	: . .
	ld (0fff1h),a		;2ebd	32 f1 ff	2 . .
	cp 0ffh			;2ec0	fe ff		. .
	ret z			;2ec2	c8		.
	jp 013e7h		;2ec3	c3 e7 13	. . .
	ld d,h			;2ec6	54		T
l2ec7h:
	ld e,l			;2ec7	5d		]
	inc de			;2ec8	13		.
	ld (hl),000h		;2ec9	36 00		6 .
	ld bc,00fffh		;2ecb	01 ff 0f	. . .
	ldir			;2ece	ed b0		. .
	ld hl,l9000h		;2ed0	21 00 90	! . .
	ld a,(hl)		;2ed3	7e		~
	inc hl			;2ed4	23		#
	ret			;2ed5	c9		.
	ld ix,0f280h		;2ed6	dd 21 80 f2	. ! . .
	ld hl,01252h		;2eda	21 52 12	! R .
	set 0,c			;2edd	cb c1		. .
	call 01161h		;2edf	cd 61 11	. a .
	ld ix,l9000h		;2ee2	dd 21 00 90	. ! . .
	ld bc,00010h		;2ee6	01 10 00	. . .
	call 0109bh		;2ee9	cd 9b 10	. . .
	ld c,00ch		;2eec	0e 0c		. .
	ld b,002h		;2eee	06 02		. .
l2ef0h:
	ld a,045h		;2ef0	3e 45		> E
	out (c),a		;2ef2	ed 79		. y
	ld a,004h		;2ef4	3e 04		> .
	out (c),a		;2ef6	ed 79		. y
	inc c			;2ef8	0c		.
	djnz l2ef0h		;2ef9	10 f5		. .
	xor a			;2efb	af		.
	ld (0fffeh),a		;2efc	32 fe ff	2 . .
	ld b,004h		;2eff	06 04		. .
	ld hl,0ffe6h		;2f01	21 e6 ff	! . .
l2f04h:
	ld (hl),a		;2f04	77		w
	inc hl			;2f05	23		#
	djnz l2f04h		;2f06	10 fc		. .
	cpl			;2f08	2f		/
	ld (hl),a		;2f09	77		w
	ld hl,00fffh		;2f0a	21 ff 0f	! . .
	ld (0fff3h),hl		;2f0d	22 f3 ff	" . .
	ld hl,00220h		;2f10	21 20 02	!   .
	ld a,002h		;2f13	3e 02		> .
	out (00bh),a		;2f15	d3 0b		. .
l2f17h:
	ld a,l			;2f17	7d		}
	out (00bh),a		;2f18	d3 0b		. .
	ld c,00ah		;2f1a	0e 0a		. .
	ld iy,01266h		;2f1c	fd 21 66 12	. ! f .
l2f20h:
	ld hl,011fdh		;2f20	21 fd 11	! . .
l2f23h:
	ld ix,0125eh		;2f23	dd 21 5e 12	. ! ^ .
	ld b,004h		;2f27	06 04		. .
l2f29h:
	ld a,005h		;2f29	3e 05		> .
	out (c),a		;2f2b	ed 79		. y
	ld a,(ix+000h)		;2f2d	dd 7e 00	. ~ .
	out (c),a		;2f30	ed 79		. y
	ld a,010h		;2f32	3e 10		> .
	out (c),a		;2f34	ed 79		. y
	in a,(c)		;2f36	ed 78		. x
	and 028h		;2f38	e6 28		. (
	inc ix			;2f3a	dd 23		. #
	cp (ix+000h)		;2f3c	dd be 00	. . .
	jr nz,l2f6ah		;2f3f	20 29		  )
	in a,(01ch)		;2f41	db 1c		. .
	and 00fh		;2f43	e6 0f		. .
	cp (iy+000h)		;2f45	fd be 00	. . .
	inc ix			;2f48	dd 23		. #
	inc iy			;2f4a	fd 23		. #
	djnz l2f29h		;2f4c	10 db		. .
	ld a,00bh		;2f4e	3e 0b		> .
	cp c			;2f50	b9		.
	jr z,l2fa3h		;2f51	28 50		( P
	ld c,a			;2f53	4f		O
	ld iy,0126ah		;2f54	fd 21 6a 12	. ! j .
	ld hl,011f5h		;2f58	21 f5 11	! . .
	jr l2f23h		;2f5b	18 c6		. .
	ld d,a			;2f5d	57		W
	ld e,(iy+000h)		;2f5e	fd 5e 00	. ^ .
	ld hl,01223h		;2f61	21 23 12	! # .
	ld ix,(0fffch)		;2f64	dd 2a fc ff	. * . .
	jr l2f7ah		;2f68	18 10		. .
l2f6ah:
	ld d,a			;2f6a	57		W
	ld e,(ix+000h)		;2f6b	dd 5e 00	. ^ .
	ld ix,(0fffch)		;2f6e	dd 2a fc ff	. * . .
	ld c,000h		;2f72	0e 00		. .
	call 01161h		;2f74	cd 61 11	. a .
	ld hl,01211h		;2f77	21 11 12	! . .
l2f7ah:
	ld c,000h		;2f7a	0e 00		. .
	call 01161h		;2f7c	cd 61 11	. a .
	ld hl,01076h		;2f7f	21 76 10	! v .
	ld c,000h		;2f82	0e 00		. .
	call 01161h		;2f84	cd 61 11	. a .
	ld a,e			;2f87	7b		{
	ld c,000h		;2f88	0e 00		. .
	call 01180h		;2f8a	cd 80 11	. . .
	ld hl,0107ch		;2f8d	21 7c 10	! | .
	ld c,000h		;2f90	0e 00		. .
	call 01161h		;2f92	cd 61 11	. a .
	ld a,d			;2f95	7a		z
	set 0,c			;2f96	cb c1		. .
	call 01180h		;2f98	cd 80 11	. . .
	ld a,00fh		;2f9b	3e 0f		> .
	ld (0fffeh),a		;2f9d	32 fe ff	2 . .
	jp 015dfh		;2fa0	c3 df 15	. . .
l2fa3h:
	ld hl,011e7h		;2fa3	21 e7 11	! . .
	ld c,00bh		;2fa6	0e 0b		. .
	call 011efh		;2fa8	cd ef 11	. . .
	ld hl,011e7h		;2fab	21 e7 11	! . .
	ld c,00ah		;2fae	0e 0a		. .
	call 011efh		;2fb0	cd ef 11	. . .
	ld hl,0ffeah		;2fb3	21 ea ff	! . .
	res 1,(hl)		;2fb6	cb 8e		. .
	ld hl,0b000h		;2fb8	21 00 b0	! . .
	ld (0ffd8h),hl		;2fbb	22 d8 ff	" . .
	call 014c6h		;2fbe	cd c6 14	. . .
	ld (0ffe0h),hl		;2fc1	22 e0 ff	" . .
	out (009h),a		;2fc4	d3 09		. .
	ld hl,0ffeah		;2fc6	21 ea ff	! . .
	res 0,(hl)		;2fc9	cb 86		. .
	ld hl,0a000h		;2fcb	21 00 a0	! . .
	ld (0ffdah),hl		;2fce	22 da ff	" . .
	call 014c6h		;2fd1	cd c6 14	. . .
	ld (0ffe2h),hl		;2fd4	22 e2 ff	" . .
	out (008h),a		;2fd7	d3 08		. .
	call 01358h		;2fd9	cd 58 13	. X .
	call 013e7h		;2fdc	cd e7 13	. . .
	di			;2fdf	f3		.
	ld a,(0fffeh)		;2fe0	3a fe ff	: . .
	cp 000h			;2fe3	fe 00		. .
	jr nz,l2ff3h		;2fe5	20 0c		  .
	ld hl,0105ah		;2fe7	21 5a 10	! Z .
	ld ix,(0fffch)		;2fea	dd 2a fc ff	. * . .
	set 0,c			;2fee	cb c1		. .
	call 01161h		;2ff0	cd 61 11	. a .
l2ff3h:
	ld a,018h		;2ff3	3e 18		> .
	out (00ah),a		;2ff5	d3 0a		. .
	out (00bh),a		;2ff7	d3 0b		. .
	ld a,003h		;2ff9	3e 03		> .
	out (00ch),a		;2ffb	d3 0c		. .
	out (00dh),a		;2ffd	d3 0d		. .
	out (072h),a		;2fff	d3 72		. r
sub_3001h:
	ret m			;3001	f8		.
	ld a,001h		;3002	3e 01		> .
	ld (0f870h),a		;3004	32 70 f8	2 p .
	call sub_1b2ah		;3007	cd 2a 1b	. * .
	jp 01d7ch		;300a	c3 7c 1d	. | .
	call sub_1b2ah		;300d	cd 2a 1b	. * .
	ld a,(0f872h)		;3010	3a 72 f8	: r .
	cp (iy+000h)		;3013	fd be 00	. . .
	jr z,l3026h		;3016	28 0e		( .
	inc a			;3018	3c		<
	ld (0f872h),a		;3019	32 72 f8	2 r .
	out (01ch),a		;301c	d3 1c		. .
	ld a,001h		;301e	3e 01		> .
	ld (0f870h),a		;3020	32 70 f8	2 p .
	jp 01d7ch		;3023	c3 7c 1d	. | .
l3026h:
	ld hl,(0f86eh)		;3026	2a 6e f8	* n .
	inc hl			;3029	23		#
	ld (0f86eh),hl		;302a	22 6e f8	" n .
	ld ix,0f578h		;302d	dd 21 78 f5	. ! x .
l3031h:
	call 01134h		;3031	cd 34 11	. 4 .
	ld hl,(0f816h)		;3034	2a 16 f8	* . .
	ld ix,0f582h		;3037	dd 21 82 f5	. ! . .
	call 01134h		;303b	cd 34 11	. 4 .
	ld hl,(0f818h)		;303e	2a 18 f8	* . .
	ld ix,0f58ch		;3041	dd 21 8c f5	. ! . .
	call 01134h		;3045	cd 34 11	. 4 .
	ld hl,(0f81ah)		;3048	2a 1a f8	* . .
	ld ix,0f596h		;304b	dd 21 96 f5	. ! . .
	call 01134h		;304f	cd 34 11	. 4 .
	call sub_24b9h		;3052	cd b9 24	. . $
	xor a			;3055	af		.
	ld (0f870h),a		;3056	32 70 f8	2 p .
	ld (0f872h),a		;3059	32 72 f8	2 r .
	ld a,(0f80ah)		;305c	3a 0a f8	: . .
	cp 004h			;305f	fe 04		. .
	jp nz,01d7ch		;3061	c2 7c 1d	. | .
	ld a,001h		;3064	3e 01		> .
	ld (0f874h),a		;3066	32 74 f8	2 t .
	jp 01d7ch		;3069	c3 7c 1d	. | .
	ld a,(ix+000h)		;306c	dd 7e 00	. ~ .
	bit 5,a			;306f	cb 6f		. o
	jp z,l212dh+2		;3071	ca 2f 21	. / !
	ld a,(ix+001h)		;3074	dd 7e 01	. ~ .
	bit 5,a			;3077	cb 6f		. o
	jp nz,01f9ch		;3079	c2 9c 1f	. . .
	ld a,(0f816h)		;307c	3a 16 f8	: . .
	cp 000h			;307f	fe 00		. .
	jp nz,l1f10h		;3081	c2 10 1f	. . .
	ld a,(0f852h)		;3084	3a 52 f8	: R .
	inc a			;3087	3c		<
	ld (0f852h),a		;3088	32 52 f8	2 R .
	call sub_24c8h		;308b	cd c8 24	. . $
	ld hl,(0f850h)		;308e	2a 50 f8	* P .
	inc hl			;3091	23		#
	ld (0f850h),hl		;3092	22 50 f8	" P .
	ld ix,0f2eeh		;3095	dd 21 ee f2	. ! . .
	call 01134h		;3099	cd 34 11	. 4 .
	ld hl,(0f818h)		;309c	2a 18 f8	* . .
	ld ix,0f30ch		;309f	dd 21 0c f3	. ! . .
	call 01134h		;30a3	cd 34 11	. 4 .
	ld hl,(0f81ah)		;30a6	2a 1a f8	* . .
	ld ix,0f316h		;30a9	dd 21 16 f3	. ! . .
	call 01134h		;30ad	cd 34 11	. 4 .
	ld a,(0f872h)		;30b0	3a 72 f8	: r .
	cp (iy+000h)		;30b3	fd be 00	. . .
	jr z,l30c6h		;30b6	28 0e		( .
	inc a			;30b8	3c		<
	ld (0f872h),a		;30b9	32 72 f8	2 r .
l30bch:
	ld a,001h		;30bc	3e 01		> .
	ld (0f870h),a		;30be	32 70 f8	2 p .
	out (01ch),a		;30c1	d3 1c		. .
l30c3h:
	jp 01d7ch		;30c3	c3 7c 1d	. | .
l30c6h:
	xor a			;30c6	af		.
	ld (0f870h),a		;30c7	32 70 f8	2 p .
l30cah:
	ld (0f872h),a		;30ca	32 72 f8	2 r .
	ld a,(0f80ah)		;30cd	3a 0a f8	: . .
	cp 004h			;30d0	fe 04		. .
	jr nz,l30d9h		;30d2	20 05		  .
l30d4h:
	ld a,001h		;30d4	3e 01		> .
	ld (0f874h),a		;30d6	32 74 f8	2 t .
l30d9h:
	ld a,(0f852h)		;30d9	3a 52 f8	: R .
	sub 001h		;30dc	d6 01		. .
	cp (iy+000h)		;30de	fd be 00	. . .
	jr z,l30e9h		;30e1	28 06		( .
	call sub_1b2ah		;30e3	cd 2a 1b	. * .
	jp 01d7ch		;30e6	c3 7c 1d	. | .
l30e9h:
	ld hl,(0f84eh)		;30e9	2a 4e f8	* N .
	inc hl			;30ec	23		#
	ld (0f84eh),hl		;30ed	22 4e f8	" N .
	ld ix,0f2f8h		;30f0	dd 21 f8 f2	. ! . .
	call 01134h		;30f4	cd 34 11	. 4 .
l30f7h:
	ld hl,(0f850h)		;30f7	2a 50 f8	* P .
	sbc hl,bc		;30fa	ed 42		. B
	dec hl			;30fc	2b		+
	ld (0f850h),hl		;30fd	22 50 f8	" P .
	ld ix,0f2eeh		;3100	dd 21 ee f2	. ! . .
	call 01134h		;3104	cd 34 11	. 4 .
	call 024d7h		;3107	cd d7 24	. . $
	call sub_1b2ah		;310a	cd 2a 1b	. * .
	jp 01d7ch		;310d	c3 7c 1d	. | .
	ld a,(0f858h)		;3110	3a 58 f8	: X .
	inc a			;3113	3c		<
	ld (0f858h),a		;3114	32 58 f8	2 X .
	call sub_24c8h		;3117	cd c8 24	. . $
	ld hl,(0f856h)		;311a	2a 56 f8	* V .
	inc hl			;311d	23		#
	ld (0f856h),hl		;311e	22 56 f8	" V .
	ld ix,0f33eh		;3121	dd 21 3e f3	. ! > .
	call 01134h		;3125	cd 34 11	. 4 .
	ld hl,(0f818h)		;3128	2a 18 f8	* . .
	ld ix,0f35ch		;312b	dd 21 5c f3	. ! \ .
	call 01134h		;312f	cd 34 11	. 4 .
	ld hl,(0f81ah)		;3132	2a 1a f8	* . .
	ld ix,0f366h		;3135	dd 21 66 f3	. ! f .
	call 01134h		;3139	cd 34 11	. 4 .
	ld a,(0f872h)		;313c	3a 72 f8	: r .
	cp (iy+000h)		;313f	fd be 00	. . .
	jr z,l3152h		;3142	28 0e		( .
	inc a			;3144	3c		<
	ld (0f872h),a		;3145	32 72 f8	2 r .
	ld a,001h		;3148	3e 01		> .
	ld (0f870h),a		;314a	32 70 f8	2 p .
	out (01ch),a		;314d	d3 1c		. .
	jp 01d7ch		;314f	c3 7c 1d	. | .
l3152h:
	xor a			;3152	af		.
	ld (0f870h),a		;3153	32 70 f8	2 p .
	ld (0f872h),a		;3156	32 72 f8	2 r .
	ld a,(0f80ah)		;3159	3a 0a f8	: . .
	cp 004h			;315c	fe 04		. .
	jr nz,l3165h		;315e	20 05		  .
	ld a,001h		;3160	3e 01		> .
	ld (0f874h),a		;3162	32 74 f8	2 t .
l3165h:
	ld a,(0f858h)		;3165	3a 58 f8	: X .
	sub 001h		;3168	d6 01		. .
	cp (iy+000h)		;316a	fd be 00	. . .
	jr z,l3175h		;316d	28 06		( .
	call sub_1b2ah		;316f	cd 2a 1b	. * .
	jp 01d7ch		;3172	c3 7c 1d	. | .
l3175h:
	ld hl,(0f854h)		;3175	2a 54 f8	* T .
	inc hl			;3178	23		#
	ld (0f854h),hl		;3179	22 54 f8	" T .
	ld ix,0f348h		;317c	dd 21 48 f3	. ! H .
	call 01134h		;3180	cd 34 11	. 4 .
	ld hl,(0f856h)		;3183	2a 56 f8	* V .
	sbc hl,bc		;3186	ed 42		. B
	dec hl			;3188	2b		+
	ld (0f856h),hl		;3189	22 56 f8	" V .
	ld ix,0f33eh		;318c	dd 21 3e f3	. ! > .
	call 01134h		;3190	cd 34 11	. 4 .
	call 024d7h		;3193	cd d7 24	. . $
	call sub_1b2ah		;3196	cd 2a 1b	. * .
	jp 01d7ch		;3199	c3 7c 1d	. | .
	ld a,(0f88ch)		;319c	3a 8c f8	: . .
	cp 000h			;319f	fe 00		. .
	jr nz,$+110		;31a1	20 6c		  l
	ld a,(0f80ah)		;31a3	3a 0a f8	: . .
	cp 005h			;31a6	fe 05		. .
	jr z,$+103		;31a8	28 65		( e
	call sub_19c8h		;31aa	cd c8 19	. . .
	ld bc,(0f88ah)		;31ad	ed 4b 8a f8	. K . .
	jr nz,$+94		;31b1	20 5c		  \
	ld a,(0f872h)		;31b3	3a 72 f8	: r .
	cp (iy+000h)		;31b6	fd be 00	. . .
	jr z,l31c9h		;31b9	28 0e		( .
	inc a			;31bb	3c		<
	ld (0f872h),a		;31bc	32 72 f8	2 r .
	ld a,001h		;31bf	3e 01		> .
	ld (0f870h),a		;31c1	32 70 f8	2 p .
	out (01ch),a		;31c4	d3 1c		. .
	jp 01d7ch		;31c6	c3 7c 1d	. | .
l31c9h:
	ld hl,(0f86ch)		;31c9	2a 6c f8	* l .
	inc hl			;31cc	23		#
	ld (0f86ch),hl		;31cd	22 6c f8	" l .
	ld ix,0f528h		;31d0	dd 21 28 f5	. ! ( .
	call 01134h		;31d4	cd 34 11	. 4 .
	ld hl,(0f816h)		;31d7	2a 16 f8	* . .
	ld ix,0f532h		;31da	dd 21 32 f5	. ! 2 .
	call 01134h		;31de	cd 34 11	. 4 .
	ld hl,(0f818h)		;31e1	2a 18 f8	* . .
	ld ix,0f53ch		;31e4	dd 21 3c f5	. ! < .
	call 01134h		;31e8	cd 34 11	. 4 .
	ld hl,(0f81ah)		;31eb	2a 1a f8	* . .
	ld ix,0f546h		;31ee	dd 21 46 f5	. ! F .
	call 01134h		;31f2	cd 34 11	. 4 .
	call sub_24b9h		;31f5	cd b9 24	. . $
	xor a			;31f8	af		.
	ld (0f870h),a		;31f9	32 70 f8	2 p .
	ld (0f872h),a		;31fc	32 72 f8	2 r .
	ld a,(0d30eh)		;31ff	3a 0e d3	: . .
	rrca			;3202	0f		.
	ld ix,0f280h		;3203	dd 21 80 f2	. ! . .
	ld iy,01252h		;3207	fd 21 52 12	. ! R .
	ld hl,0f2d0h		;320b	21 d0 f2	! . .
	call 0119ch		;320e	cd 9c 11	. . .
	ei			;3211	fb		.
	ld a,(0ffffh)		;3212	3a ff ff	: . .
	bit 6,a			;3215	cb 77		. w
	di			;3217	f3		.
	jp nz,014ech		;3218	c2 ec 14	. . .
	ld a,(0fffeh)		;321b	3a fe ff	: . .
	jp 0049eh		;321e	c3 9e 04	. . .
	ld b,(hl)		;3221	46		F
	ld b,h			;3222	44		D
	ld b,h			;3223	44		D
	jr nz,l3278h		;3224	20 52		  R
	ld b,l			;3226	45		E
	ld c,h			;3227	4c		L
	ld c,c			;3228	49		I
	ld b,c			;3229	41		A
	ld b,d			;322a	42		B
	ld c,c			;322b	49		I
	ld c,h			;322c	4c		L
	ld c,c			;322d	49		I
l322eh:
	ld d,h			;322e	54		T
l322fh:
	ld e,c			;322f	59		Y
l3230h:
	jr nz,$+86		;3230	20 54		  T
	ld b,l			;3232	45		E
	ld d,e			;3233	53		S
	ld d,h			;3234	54		T
	ld h,h			;3235	64		d
	ld (hl),d		;3236	72		r
	ld l,c			;3237	69		i
	halt			;3238	76		v
	ld h,l			;3239	65		e
	jr nz,$+42		;323a	20 28		  (
	jr nc,l326dh		;323c	30 2f		0 /
	ld sp,02029h		;323e	31 29 20	1 )  
	ld a,(l6973h)		;3241	3a 73 69	: s i
	ld l,(hl)		;3244	6e		n
	ld h,a			;3245	67		g
l3246h:
	ld l,h			;3246	6c		l
	ld h,l			;3247	65		e
	cpl			;3248	2f		/
	ld h,h			;3249	64		d
	ld l,a			;324a	6f		o
	ld (hl),l		;324b	75		u
	ld h,d			;324c	62		b
	ld l,h			;324d	6c		l
	ld h,l			;324e	65		e
	jr nz,$+102		;324f	20 64		  d
	ld h,l			;3251	65		e
	ld l,(hl)		;3252	6e		n
	ld (hl),e		;3253	73		s
	ld l,c			;3254	69		i
	ld (hl),h		;3255	74		t
	ld a,c			;3256	79		y
	jr nz,l3281h		;3257	20 28		  (
l3259h:
	jr nc,l328ah		;3259	30 2f		0 /
	ld sp,02029h		;325b	31 29 20	1 )  
	ld a,(l7265h+1)		;325e	3a 66 72	: f r
	ld l,a			;3261	6f		o
	ld l,l			;3262	6d		m
	jr nz,l32d9h		;3263	20 74		  t
	ld (hl),d		;3265	72		r
	ld h,c			;3266	61		a
	ld h,e			;3267	63		c
	ld l,e			;3268	6b		k
l3269h:
	jr nz,$+60		;3269	20 3a		  :
	ld (hl),h		;326b	74		t
sub_326ch:
	ld l,a			;326c	6f		o
l326dh:
	jr nz,l32e3h		;326d	20 74		  t
	ld (hl),d		;326f	72		r
	ld h,c			;3270	61		a
	ld h,e			;3271	63		c
	ld l,e			;3272	6b		k
	jr nz,l32afh		;3273	20 3a		  :
	ld l,l			;3275	6d		m
	ld l,c			;3276	69		i
	ld l,(hl)		;3277	6e		n
l3278h:
	ld l,c			;3278	69		i
	cpl			;3279	2f		/
sub_327ah:
	ld l,l			;327a	6d		m
	ld h,c			;327b	61		a
	ld a,b			;327c	78		x
	ld l,c			;327d	69		i
	cpl			;327e	2f		/
	ld (hl),c		;327f	71		q
	ld (hl),l		;3280	75		u
l3281h:
	ld h,c			;3281	61		a
	ld h,h			;3282	64		d
	jr nz,l32adh		;3283	20 28		  (
	jr nc,l32b6h		;3285	30 2f		0 /
	ld sp,l322fh		;3287	31 2f 32	1 / 2
l328ah:
	add hl,hl		;328a	29		)
	jr nz,l32c7h		;328b	20 3a		  :
	ld (hl),e		;328d	73		s
	ld l,c			;328e	69		i
	ld l,(hl)		;328f	6e		n
	ld h,a			;3290	67		g
	ld l,h			;3291	6c		l
	ld h,l			;3292	65		e
	cpl			;3293	2f		/
	ld h,h			;3294	64		d
	ld l,a			;3295	6f		o
	ld (hl),l		;3296	75		u
	ld h,d			;3297	62		b
	ld l,h			;3298	6c		l
	ld h,l			;3299	65		e
sub_329ah:
	jr nz,l330fh		;329a	20 73		  s
	ld l,c			;329c	69		i
	ld h,h			;329d	64		d
	ld h,l			;329e	65		e
	jr nz,l32c9h		;329f	20 28		  (
	jr nc,l32d2h		;32a1	30 2f		0 /
	ld sp,02029h		;32a3	31 29 20	1 )  
	ld a,(l7473h)		;32a6	3a 73 74	: s t
sub_32a9h:
	ld h,l			;32a9	65		e
	ld (hl),b		;32aa	70		p
	ld (hl),d		;32ab	72		r
	ld h,c			;32ac	61		a
l32adh:
	ld (hl),h		;32ad	74		t
sub_32aeh:
	ld h,l			;32ae	65		e
l32afh:
	jr nz,l331eh		;32af	20 6d		  m
	ld (hl),e		;32b1	73		s
	jr nz,l32dch		;32b2	20 28		  (
	jr nc,l32e7h		;32b4	30 31		0 1
l32b6h:
	dec l			;32b6	2d		-
	ld sp,l2936h		;32b7	31 36 29	1 6 )
	jr nz,l32f6h		;32ba	20 3a		  :
	ld l,c			;32bc	69		i
	ld h,(hl)		;32bd	66		f
	jr nz,l332dh		;32be	20 6d		  m
sub_32c0h:
	ld l,c			;32c0	69		i
	ld l,(hl)		;32c1	6e		n
	ld l,c			;32c2	69		i
	jr nz,$+102		;32c3	20 64		  d
	ld (hl),d		;32c5	72		r
	ld l,c			;32c6	69		i
l32c7h:
	halt			;32c7	76		v
l32c8h:
	ld h,l			;32c8	65		e
l32c9h:
	jr nz,l333fh		;32c9	20 74		  t
	ld l,b			;32cb	68		h
	ld h,l			;32cc	65		e
	ld l,(hl)		;32cd	6e		n
	jr nz,$+117		;32ce	20 73		  s
	ld (hl),h		;32d0	74		t
sub_32d1h:
	ld h,l			;32d1	65		e
l32d2h:
	ld (hl),b		;32d2	70		p
	ld (hl),d		;32d3	72		r
	ld h,c			;32d4	61		a
	ld (hl),h		;32d5	74		t
	ld h,l			;32d6	65		e
	jr nz,l3350h		;32d7	20 77		  w
l32d9h:
	ld l,c			;32d9	69		i
	ld l,h			;32da	6c		l
	ld l,h			;32db	6c		l
l32dch:
	jr nz,l3340h		;32dc	20 62		  b
sub_32deh:
	ld h,l			;32de	65		e
	jr nz,l334eh		;32df	20 6d		  m
	ld (hl),l		;32e1	75		u
	ld l,h			;32e2	6c		l
l32e3h:
	ld (hl),h		;32e3	74		t
	ld l,c			;32e4	69		i
	ld (hl),b		;32e5	70		p
	ld l,h			;32e6	6c		l
l32e7h:
	ld l,c			;32e7	69		i
	ld h,l			;32e8	65		e
	ld h,h			;32e9	64		d
	jr nz,l3363h		;32ea	20 77		  w
	ld l,c			;32ec	69		i
	ld (hl),h		;32ed	74		t
	ld l,b			;32ee	68		h
	jr nz,l3323h		;32ef	20 32		  2
	ld (hl),d		;32f1	72		r
	ld h,l			;32f2	65		e
	ld (hl),h		;32f3	74		t
	ld (hl),d		;32f4	72		r
	ld l,c			;32f5	69		i
l32f6h:
	ld h,l			;32f6	65		e
	ld (hl),e		;32f7	73		s
	jr nz,l3322h		;32f8	20 28		  (
	jr nc,$+47		;32fa	30 2d		0 -
	add hl,sp		;32fc	39		9
	add hl,hl		;32fd	29		)
	jr nz,$+60		;32fe	20 3a		  :
	ld h,h			;3300	64		d
	ld l,c			;3301	69		i
	ld (hl),e		;3302	73		s
	ld l,e			;3303	6b		k
	ld h,l			;3304	65		e
	ld (hl),h		;3305	74		t
	ld (hl),h		;3306	74		t
	ld h,l			;3307	65		e
	jr nz,$+118		;3308	20 74		  t
	ld h,l			;330a	65		e
	ld (hl),e		;330b	73		s
	ld (hl),h		;330c	74		t
sub_330dh:
	jr nz,l3337h		;330d	20 28		  (
l330fh:
	ld l,a			;330f	6f		o
	ld l,(hl)		;3310	6e		n
	ld l,h			;3311	6c		l
	ld a,c			;3312	79		y
	jr nz,l3387h		;3313	20 72		  r
	ld h,l			;3315	65		e
	ld h,c			;3316	61		a
	ld h,h			;3317	64		d
	ld l,c			;3318	69		i
	ld l,(hl)		;3319	6e		n
	ld h,a			;331a	67		g
	add hl,hl		;331b	29		)
	jr nz,$+112		;331c	20 6e		  n
l331eh:
	ld l,a			;331e	6f		o
	cpl			;331f	2f		/
	ld a,c			;3320	79		y
	ld h,l			;3321	65		e
l3322h:
	ld (hl),e		;3322	73		s
l3323h:
	jr nz,l334dh		;3323	20 28		  (
	jr nc,$+49		;3325	30 2f		0 /
	ld sp,02029h		;3327	31 29 20	1 )  
	ld a,(l6572h)		;332a	3a 72 65	: r e
l332dh:
	ld h,c			;332d	61		a
	ld h,h			;332e	64		d
	jr nz,$+114		;332f	20 70		  p
	ld (hl),d		;3331	72		r
	ld h,l			;3332	65		e
	ld h,(hl)		;3333	66		f
	ld l,a			;3334	6f		o
	ld (hl),d		;3335	72		r
	ld l,l			;3336	6d		m
l3337h:
	ld h,c			;3337	61		a
	ld (hl),h		;3338	74		t
	jr nz,l33a9h		;3339	20 6e		  n
	ld l,a			;333b	6f		o
	cpl			;333c	2f		/
	ld a,c			;333d	79		y
	ld h,l			;333e	65		e
l333fh:
	ld (hl),e		;333f	73		s
l3340h:
	jr nz,l336ah		;3340	20 28		  (
	jr nc,$+49		;3342	30 2f		0 /
	ld sp,02029h		;3344	31 29 20	1 )  
	ld a,(l6f66h)		;3347	3a 66 6f	: f o
l334ah:
	ld (hl),d		;334a	72		r
	ld l,l			;334b	6d		m
	ld h,c			;334c	61		a
l334dh:
	ld (hl),h		;334d	74		t
l334eh:
	jr nz,$+112		;334e	20 6e		  n
l3350h:
	ld l,a			;3350	6f		o
	cpl			;3351	2f		/
	ld a,c			;3352	79		y
	ld h,l			;3353	65		e
	ld (hl),e		;3354	73		s
	jr nz,l337fh		;3355	20 28		  (
	jr nc,l3388h		;3357	30 2f		0 /
	ld sp,02029h		;3359	31 29 20	1 )  
	ld a,(l4148h)		;335c	3a 48 41	: H A
	ld d,d			;335f	52		R
	ld b,h			;3360	44		D
	jr nz,$+71		;3361	20 45		  E
l3363h:
	ld d,d			;3363	52		R
	ld d,d			;3364	52		R
	ld c,a			;3365	4f		O
l3366h:
	ld d,d			;3366	52		R
	jr nz,l33b1h		;3367	20 48		  H
	ld b,c			;3369	41		A
l336ah:
	ld d,d			;336a	52		R
	ld b,h			;336b	44		D
	jr nz,l33b3h		;336c	20 45		  E
	ld d,d			;336e	52		R
	ld d,d			;336f	52		R
	ld c,a			;3370	4f		O
	ld d,d			;3371	52		R
	jr nz,$+74		;3372	20 48		  H
	ld b,c			;3374	41		A
	ld d,d			;3375	52		R
	ld b,h			;3376	44		D
	jr nz,$+71		;3377	20 45		  E
	ld d,d			;3379	52		R
	ld d,d			;337a	52		R
	ld c,a			;337b	4f		O
	ld d,d			;337c	52		R
	jr nz,l33c7h		;337d	20 48		  H
l337fh:
	ld b,c			;337f	41		A
	ld c,h			;3380	4c		L
	ld d,h			;3381	54		T
	ld b,l			;3382	45		E
	ld b,h			;3383	44		D
	ld d,d			;3384	52		R
	ld b,l			;3385	45		E
	ld d,h			;3386	54		T
l3387h:
	ld d,d			;3387	52		R
l3388h:
	ld c,c			;3388	49		I
	ld b,l			;3389	45		E
	ld d,e			;338a	53		S
	jr nz,l33c7h		;338b	20 3a		  :
	ld d,b			;338d	50		P
	ld b,c			;338e	41		A
	ld d,e			;338f	53		S
	ld d,e			;3390	53		S
	jr nz,l33cdh		;3391	20 3a		  :
	ld c,(hl)		;3393	4e		N
	ld c,a			;3394	4f		O
	ld d,h			;3395	54		T
	jr nz,l33dch		;3396	20 44		  D
	ld b,l			;3398	45		E
	ld d,h			;3399	54		T
	ld b,l			;339a	45		E
	ld b,e			;339b	43		C
	ld d,h			;339c	54		T
	jr nz,l33e8h		;339d	20 49		  I
	ld b,h			;339f	44		D
	jr nz,l33efh		;33a0	20 4d		  M
	ld b,c			;33a2	41		A
	ld d,d			;33a3	52		R
	ld c,e			;33a4	4b		K
	jr nz,l33d7h		;33a5	20 30		  0
	jr nz,l33e3h		;33a7	20 3a		  :
l33a9h:
	ld c,(hl)		;33a9	4e		N
	ld c,a			;33aa	4f		O
	ld d,h			;33ab	54		T
	jr nz,l33f2h		;33ac	20 44		  D
	ld b,l			;33ae	45		E
	ld d,h			;33af	54		T
	ld b,l			;33b0	45		E
l33b1h:
	ld b,e			;33b1	43		C
	ld d,h			;33b2	54		T
l33b3h:
	jr nz,l33feh		;33b3	20 49		  I
	ld b,h			;33b5	44		D
	jr nz,$+79		;33b6	20 4d		  M
	ld b,c			;33b8	41		A
	ld d,d			;33b9	52		R
	ld c,e			;33ba	4b		K
	jr nz,$+51		;33bb	20 31		  1
	jr nz,l33f9h		;33bd	20 3a		  :
	ld c,(hl)		;33bf	4e		N
	ld c,a			;33c0	4f		O
	ld d,h			;33c1	54		T
	jr nz,$+70		;33c2	20 44		  D
	ld b,l			;33c4	45		E
	ld d,h			;33c5	54		T
	ld b,l			;33c6	45		E
l33c7h:
	ld b,e			;33c7	43		C
	ld d,h			;33c8	54		T
	jr nz,l340fh		;33c9	20 44		  D
	ld b,c			;33cb	41		A
	ld d,h			;33cc	54		T
l33cdh:
	ld b,c			;33cd	41		A
	jr nz,$+79		;33ce	20 4d		  M
	ld b,c			;33d0	41		A
	ld d,d			;33d1	52		R
	ld c,e			;33d2	4b		K
	jr nz,$+50		;33d3	20 30		  0
	jr nz,$+60		;33d5	20 3a		  :
l33d7h:
	ld c,(hl)		;33d7	4e		N
	ld c,a			;33d8	4f		O
	ld d,h			;33d9	54		T
	jr nz,$+70		;33da	20 44		  D
l33dch:
	ld b,l			;33dc	45		E
	ld d,h			;33dd	54		T
	ld b,l			;33de	45		E
	ld b,e			;33df	43		C
	ld d,h			;33e0	54		T
	jr nz,$+70		;33e1	20 44		  D
l33e3h:
	ld b,c			;33e3	41		A
	ld d,h			;33e4	54		T
	ld b,c			;33e5	41		A
	jr nz,$+79		;33e6	20 4d		  M
l33e8h:
	ld b,c			;33e8	41		A
	ld d,d			;33e9	52		R
	ld c,e			;33ea	4b		K
	jr nz,l341eh		;33eb	20 31		  1
	jr nz,$+60		;33ed	20 3a		  :
l33efh:
	ld c,(hl)		;33ef	4e		N
	ld c,a			;33f0	4f		O
	ld d,h			;33f1	54		T
l33f2h:
	jr nz,$+72		;33f2	20 46		  F
	ld c,c			;33f4	49		I
	ld c,(hl)		;33f5	4e		N
	ld b,h			;33f6	44		D
	jr nz,l344ch		;33f7	20 53		  S
l33f9h:
	ld b,l			;33f9	45		E
	ld b,e			;33fa	43		C
	ld d,h			;33fb	54		T
	ld c,a			;33fc	4f		O
	ld d,d			;33fd	52		R
l33feh:
	jr nz,$+50		;33fe	20 30		  0
	ld a,(bc)		;3400	0a		.
	ret m			;3401	f8		.
	cp 004h			;3402	fe 04		. .
	jp nz,01d7ch		;3404	c2 7c 1d	. | .
	ld a,001h		;3407	3e 01		> .
	ld (0f874h),a		;3409	32 74 f8	2 t .
	jp 01d7ch		;340c	c3 7c 1d	. | .
l340fh:
	ld a,(0f816h)		;340f	3a 16 f8	: . .
	cp 000h			;3412	fe 00		. .
	jp nz,020a3h		;3414	c2 a3 20	. .  
	ld a,(0f85eh)		;3417	3a 5e f8	: ^ .
	inc a			;341a	3c		<
	ld (0f85eh),a		;341b	32 5e f8	2 ^ .
l341eh:
	call sub_24c8h		;341e	cd c8 24	. . $
	ld hl,(0f85ch)		;3421	2a 5c f8	* \ .
	inc hl			;3424	23		#
	ld (0f85ch),hl		;3425	22 5c f8	" \ .
	ld ix,0f38eh		;3428	dd 21 8e f3	. ! . .
	call 01134h		;342c	cd 34 11	. 4 .
	ld hl,(0f818h)		;342f	2a 18 f8	* . .
	ld ix,0f3ach		;3432	dd 21 ac f3	. ! . .
	call 01134h		;3436	cd 34 11	. 4 .
	ld hl,(0f81ah)		;3439	2a 1a f8	* . .
	ld ix,0f3b6h		;343c	dd 21 b6 f3	. ! . .
	call 01134h		;3440	cd 34 11	. 4 .
	ld a,(0f872h)		;3443	3a 72 f8	: r .
	cp (iy+000h)		;3446	fd be 00	. . .
	jr z,l3459h		;3449	28 0e		( .
	inc a			;344b	3c		<
l344ch:
	ld (0f872h),a		;344c	32 72 f8	2 r .
	ld a,001h		;344f	3e 01		> .
	ld (0f870h),a		;3451	32 70 f8	2 p .
	out (01ch),a		;3454	d3 1c		. .
	jp 01d7ch		;3456	c3 7c 1d	. | .
l3459h:
	xor a			;3459	af		.
	ld (0f870h),a		;345a	32 70 f8	2 p .
	ld (0f872h),a		;345d	32 72 f8	2 r .
	ld a,(0f80ah)		;3460	3a 0a f8	: . .
	cp 004h			;3463	fe 04		. .
	jr nz,l346ch		;3465	20 05		  .
	ld a,001h		;3467	3e 01		> .
	ld (0f874h),a		;3469	32 74 f8	2 t .
l346ch:
	ld a,(0f85eh)		;346c	3a 5e f8	: ^ .
	sub 001h		;346f	d6 01		. .
	cp (iy+000h)		;3471	fd be 00	. . .
	jr z,l347ch		;3474	28 06		( .
	call sub_1b2ah		;3476	cd 2a 1b	. * .
	jp 01d7ch		;3479	c3 7c 1d	. | .
l347ch:
	ld hl,(0f85ah)		;347c	2a 5a f8	* Z .
	inc hl			;347f	23		#
	ld (0f85ah),hl		;3480	22 5a f8	" Z .
	ld ix,0f398h		;3483	dd 21 98 f3	. ! . .
	call 01134h		;3487	cd 34 11	. 4 .
	ld hl,(0f85ch)		;348a	2a 5c f8	* \ .
	sbc hl,bc		;348d	ed 42		. B
	dec hl			;348f	2b		+
	ld (0f85ch),hl		;3490	22 5c f8	" \ .
	ld ix,0f38eh		;3493	dd 21 8e f3	. ! . .
	call 01134h		;3497	cd 34 11	. 4 .
	call 024d7h		;349a	cd d7 24	. . $
	call sub_1b2ah		;349d	cd 2a 1b	. * .
	jp 01d7ch		;34a0	c3 7c 1d	. | .
	ld a,(0f864h)		;34a3	3a 64 f8	: d .
	inc a			;34a6	3c		<
	ld (0f864h),a		;34a7	32 64 f8	2 d .
	call sub_24c8h		;34aa	cd c8 24	. . $
	ld hl,(0f862h)		;34ad	2a 62 f8	* b .
	inc hl			;34b0	23		#
	ld (0f862h),hl		;34b1	22 62 f8	" b .
	ld ix,0f3deh		;34b4	dd 21 de f3	. ! . .
	call 01134h		;34b8	cd 34 11	. 4 .
	ld hl,(0f818h)		;34bb	2a 18 f8	* . .
	ld ix,0f3fch		;34be	dd 21 fc f3	. ! . .
	call 01134h		;34c2	cd 34 11	. 4 .
	ld hl,(0f81ah)		;34c5	2a 1a f8	* . .
	ld ix,0f406h		;34c8	dd 21 06 f4	. ! . .
	call 01134h		;34cc	cd 34 11	. 4 .
	ld a,(0f872h)		;34cf	3a 72 f8	: r .
	cp (iy+000h)		;34d2	fd be 00	. . .
	jr z,l34e5h		;34d5	28 0e		( .
	inc a			;34d7	3c		<
	ld (0f872h),a		;34d8	32 72 f8	2 r .
l34dbh:
	ld a,001h		;34db	3e 01		> .
	ld (0f870h),a		;34dd	32 70 f8	2 p .
	out (01ch),a		;34e0	d3 1c		. .
	jp 01d7ch		;34e2	c3 7c 1d	. | .
l34e5h:
	xor a			;34e5	af		.
	ld (0f870h),a		;34e6	32 70 f8	2 p .
	ld (0f872h),a		;34e9	32 72 f8	2 r .
	ld a,(0f80ah)		;34ec	3a 0a f8	: . .
	cp 004h			;34ef	fe 04		. .
	jr nz,l34f8h		;34f1	20 05		  .
	ld a,001h		;34f3	3e 01		> .
	ld (0f874h),a		;34f5	32 74 f8	2 t .
l34f8h:
	ld a,(0f864h)		;34f8	3a 64 f8	: d .
	sub 001h		;34fb	d6 01		. .
	cp (iy+000h)		;34fd	fd be 00	. . .
	jr z,l3508h		;3500	28 06		( .
	call sub_1b2ah		;3502	cd 2a 1b	. * .
	jp 01d7ch		;3505	c3 7c 1d	. | .
l3508h:
	ld hl,(0f860h)		;3508	2a 60 f8	* ` .
	inc hl			;350b	23		#
	ld (0f860h),hl		;350c	22 60 f8	" ` .
	ld ix,0f3e8h		;350f	dd 21 e8 f3	. ! . .
	call 01134h		;3513	cd 34 11	. 4 .
l3516h:
	ld hl,(0f862h)		;3516	2a 62 f8	* b .
	sbc hl,bc		;3519	ed 42		. B
	dec hl			;351b	2b		+
	ld (0f862h),hl		;351c	22 62 f8	" b .
	ld ix,0f3deh		;351f	dd 21 de f3	. ! . .
	call 01134h		;3523	cd 34 11	. 4 .
	call 024d7h		;3526	cd d7 24	. . $
	call sub_1b2ah		;3529	cd 2a 1b	. * .
	jp 01d7ch		;352c	c3 7c 1d	. | .
	ld a,(0f88ch)		;352f	3a 8c f8	: . .
	cp 000h			;3532	fe 00		. .
	jr nz,l3547h		;3534	20 11		  .
	ld a,(0f80ah)		;3536	3a 0a f8	: . .
	cp 005h			;3539	fe 05		. .
l353bh:
	jr nz,l3547h		;353b	20 0a		  .
	call sub_19c8h		;353d	cd c8 19	. . .
	ld bc,(0f88ah)		;3540	ed 4b 8a f8	. K . .
	jp nz,01fb3h		;3544	c2 b3 1f	. . .
l3547h:
	ld a,(ix+000h)		;3547	dd 7e 00	. ~ .
	bit 2,a			;354a	cb 57		. W
	jp z,l226fh		;354c	ca 6f 22	. o "
	ld a,(0f816h)		;354f	3a 16 f8	: . .
l3552h:
	cp 000h			;3552	fe 00		. .
	jp nz,l21e3h		;3554	c2 e3 21	. . !
	ld a,(0f846h)		;3557	3a 46 f8	: F .
	inc a			;355a	3c		<
	ld (0f846h),a		;355b	32 46 f8	2 F .
	call sub_24c8h		;355e	cd c8 24	. . $
	ld hl,(0f844h)		;3561	2a 44 f8	* D .
	inc hl			;3564	23		#
	ld (0f844h),hl		;3565	22 44 f8	" D .
	ld ix,0f24eh		;3568	dd 21 4e f2	. ! N .
	call 01134h		;356c	cd 34 11	. 4 .
	ld hl,(0f818h)		;356f	2a 18 f8	* . .
	ld ix,0f26ch		;3572	dd 21 6c f2	. ! l .
	call 01134h		;3576	cd 34 11	. 4 .
	ld hl,(0f81ah)		;3579	2a 1a f8	* . .
	ld ix,0f276h		;357c	dd 21 76 f2	. ! v .
	call 01134h		;3580	cd 34 11	. 4 .
	ld a,(0f872h)		;3583	3a 72 f8	: r .
	cp (iy+000h)		;3586	fd be 00	. . .
	jr z,l3599h		;3589	28 0e		( .
	inc a			;358b	3c		<
	ld (0f872h),a		;358c	32 72 f8	2 r .
	ld a,001h		;358f	3e 01		> .
	ld (0f870h),a		;3591	32 70 f8	2 p .
	out (01ch),a		;3594	d3 1c		. .
	jp 01d7ch		;3596	c3 7c 1d	. | .
l3599h:
	xor a			;3599	af		.
	ld (0f870h),a		;359a	32 70 f8	2 p .
	ld (0f872h),a		;359d	32 72 f8	2 r .
	ld a,(0f80ah)		;35a0	3a 0a f8	: . .
	cp 004h			;35a3	fe 04		. .
	jr nz,l35ach		;35a5	20 05		  .
	ld a,001h		;35a7	3e 01		> .
	ld (0f874h),a		;35a9	32 74 f8	2 t .
l35ach:
	ld a,(0f846h)		;35ac	3a 46 f8	: F .
	sub 001h		;35af	d6 01		. .
	cp (iy+000h)		;35b1	fd be 00	. . .
	jr z,l35bch		;35b4	28 06		( .
	call sub_1b2ah		;35b6	cd 2a 1b	. * .
	jp 01d7ch		;35b9	c3 7c 1d	. | .
l35bch:
	ld hl,(0f842h)		;35bc	2a 42 f8	* B .
	inc hl			;35bf	23		#
	ld (0f842h),hl		;35c0	22 42 f8	" B .
l35c3h:
	ld ix,0f258h		;35c3	dd 21 58 f2	. ! X .
	call 01134h		;35c7	cd 34 11	. 4 .
	ld hl,(0f844h)		;35ca	2a 44 f8	* D .
	sbc hl,bc		;35cd	ed 42		. B
	dec hl			;35cf	2b		+
	ld (0f844h),hl		;35d0	22 44 f8	" D .
	ld ix,0f24eh		;35d3	dd 21 4e f2	. ! N .
	call 01134h		;35d7	cd 34 11	. 4 .
l35dah:
	call 024d7h		;35da	cd d7 24	. . $
	call sub_1b2ah		;35dd	cd 2a 1b	. * .
	jp 01d7ch		;35e0	c3 7c 1d	. | .
	ld a,(0f84ch)		;35e3	3a 4c f8	: L .
	inc a			;35e6	3c		<
	ld (0f84ch),a		;35e7	32 4c f8	2 L .
	call sub_24c8h		;35ea	cd c8 24	. . $
	ld hl,(0f84ah)		;35ed	2a 4a f8	* J .
	inc hl			;35f0	23		#
	ld (0f84ah),hl		;35f1	22 4a f8	" J .
	ld ix,0f29eh		;35f4	dd 21 9e f2	. ! . .
	call 01134h		;35f8	cd 34 11	. 4 .
	ld hl,(0f818h)		;35fb	2a 18 f8	* . .
	ld ix,03a20h		;35fe	dd 21 20 3a	. !   :
sub_3602h:
	ld c,(hl)		;3602	4e		N
	ld c,a			;3603	4f		O
	ld d,h			;3604	54		T
	jr nz,$+72		;3605	20 46		  F
	ld c,c			;3607	49		I
	ld c,(hl)		;3608	4e		N
	ld b,h			;3609	44		D
	jr nz,l365fh		;360a	20 53		  S
	ld b,l			;360c	45		E
	ld b,e			;360d	43		C
	ld d,h			;360e	54		T
	ld c,a			;360f	4f		O
	ld d,d			;3610	52		R
	jr nz,l3644h		;3611	20 31		  1
	jr nz,$+60		;3613	20 3a		  :
	ld b,e			;3615	43		C
	ld d,d			;3616	52		R
	ld b,e			;3617	43		C
	jr nz,l365fh		;3618	20 45		  E
	ld d,d			;361a	52		R
	ld d,d			;361b	52		R
	ld c,a			;361c	4f		O
sub_361dh:
	ld d,d			;361d	52		R
	jr nz,l3669h		;361e	20 49		  I
	ld c,(hl)		;3620	4e		N
	jr nz,l366ch		;3621	20 49		  I
	ld b,h			;3623	44		D
	jr nz,l3656h		;3624	20 30		  0
	jr nz,$+60		;3626	20 3a		  :
	ld b,e			;3628	43		C
	ld d,d			;3629	52		R
	ld b,e			;362a	43		C
	jr nz,l3672h		;362b	20 45		  E
	ld d,d			;362d	52		R
sub_362eh:
	ld d,d			;362e	52		R
	ld c,a			;362f	4f		O
	ld d,d			;3630	52		R
	jr nz,l367ch		;3631	20 49		  I
	ld c,(hl)		;3633	4e		N
	jr nz,l367fh		;3634	20 49		  I
	ld b,h			;3636	44		D
	jr nz,l366ah		;3637	20 31		  1
	jr nz,l3675h		;3639	20 3a		  :
	ld b,e			;363b	43		C
	ld d,d			;363c	52		R
	ld b,e			;363d	43		C
sub_363eh:
	jr nz,$+71		;363e	20 45		  E
	ld d,d			;3640	52		R
	ld d,d			;3641	52		R
	ld c,a			;3642	4f		O
	ld d,d			;3643	52		R
l3644h:
	jr nz,l368fh		;3644	20 49		  I
	ld c,(hl)		;3646	4e		N
	jr nz,l368dh		;3647	20 44		  D
	ld b,c			;3649	41		A
	ld d,h			;364a	54		T
	ld b,c			;364b	41		A
	jr nz,l367eh		;364c	20 30		  0
	jr nz,l368ah		;364e	20 3a		  :
	ld b,e			;3650	43		C
	ld d,d			;3651	52		R
	ld b,e			;3652	43		C
	jr nz,l369ah		;3653	20 45		  E
	ld d,d			;3655	52		R
l3656h:
	ld d,d			;3656	52		R
	ld c,a			;3657	4f		O
	ld d,d			;3658	52		R
	jr nz,l36a4h		;3659	20 49		  I
	ld c,(hl)		;365b	4e		N
	jr nz,l36a2h		;365c	20 44		  D
	ld b,c			;365e	41		A
l365fh:
	ld d,h			;365f	54		T
	ld b,c			;3660	41		A
	jr nz,l3694h		;3661	20 31		  1
	jr nz,l369fh		;3663	20 3a		  :
	ld b,e			;3665	43		C
	ld d,d			;3666	52		R
	ld b,e			;3667	43		C
	ld e,a			;3668	5f		_
l3669h:
	ld d,d			;3669	52		R
l366ah:
	ld b,l			;366a	45		E
	ld b,c			;366b	41		A
l366ch:
	ld b,h			;366c	44		D
sub_366dh:
	ld c,c			;366d	49		I
	ld c,(hl)		;366e	4e		N
	ld b,a			;366f	47		G
	jr nz,l36b7h		;3670	20 45		  E
l3672h:
	ld d,d			;3672	52		R
	ld d,d			;3673	52		R
	ld c,a			;3674	4f		O
l3675h:
	ld d,d			;3675	52		R
	jr nz,l36b2h		;3676	20 3a		  :
	ld d,e			;3678	53		S
	ld b,l			;3679	45		E
	ld b,l			;367a	45		E
	ld c,e			;367b	4b		K
l367ch:
	jr nz,l36c3h		;367c	20 45		  E
l367eh:
	ld d,d			;367e	52		R
l367fh:
	ld d,d			;367f	52		R
	ld c,a			;3680	4f		O
	ld d,d			;3681	52		R
	jr nz,l36b4h		;3682	20 30		  0
	jr nz,$+60		;3684	20 3a		  :
	ld d,e			;3686	53		S
	ld b,l			;3687	45		E
	ld b,l			;3688	45		E
	ld c,e			;3689	4b		K
l368ah:
	jr nz,l36d1h		;368a	20 45		  E
	ld d,d			;368c	52		R
l368dh:
	ld d,d			;368d	52		R
	ld c,a			;368e	4f		O
l368fh:
	ld d,d			;368f	52		R
	jr nz,l36c3h		;3690	20 31		  1
	jr nz,l36ceh		;3692	20 3a		  :
l3694h:
	ld b,(hl)		;3694	46		F
l3695h:
	ld b,h			;3695	44		D
	ld b,e			;3696	43		C
	jr nz,l36deh		;3697	20 45		  E
	ld d,d			;3699	52		R
l369ah:
	ld d,d			;369a	52		R
	ld c,a			;369b	4f		O
	ld d,d			;369c	52		R
	jr nz,l36d9h		;369d	20 3a		  :
l369fh:
	ld d,h			;369f	54		T
	ld c,c			;36a0	49		I
	ld c,l			;36a1	4d		M
l36a2h:
	ld b,l			;36a2	45		E
	ld c,a			;36a3	4f		O
l36a4h:
	ld d,l			;36a4	55		U
	ld d,h			;36a5	54		T
	jr nz,l36e2h		;36a6	20 3a		  :
	ld d,d			;36a8	52		R
	ld b,l			;36a9	45		E
	ld b,c			;36aa	41		A
	ld b,h			;36ab	44		D
	jr nz,l36f3h		;36ac	20 45		  E
	ld d,d			;36ae	52		R
	ld d,d			;36af	52		R
	ld c,a			;36b0	4f		O
	ld d,d			;36b1	52		R
l36b2h:
	jr nz,l36eeh		;36b2	20 3a		  :
l36b4h:
	ld d,a			;36b4	57		W
	ld d,d			;36b5	52		R
	ld c,c			;36b6	49		I
l36b7h:
	ld d,h			;36b7	54		T
	ld b,l			;36b8	45		E
	jr nz,$+71		;36b9	20 45		  E
	ld d,d			;36bb	52		R
	ld d,d			;36bc	52		R
	ld c,a			;36bd	4f		O
	ld d,d			;36be	52		R
	jr nz,l36fbh		;36bf	20 3a		  :
	ld d,e			;36c1	53		S
	ld c,a			;36c2	4f		O
l36c3h:
	ld b,(hl)		;36c3	46		F
	ld d,h			;36c4	54		T
	ld c,b			;36c5	48		H
	ld b,c			;36c6	41		A
	ld d,d			;36c7	52		R
	ld b,h			;36c8	44		D
	ld c,b			;36c9	48		H
	ld b,l			;36ca	45		E
	ld b,c			;36cb	41		A
	ld b,h			;36cc	44		D
	ld b,e			;36cd	43		C
l36ceh:
	ld e,c			;36ce	59		Y
	ld c,h			;36cf	4c		L
	ld c,c			;36d0	49		I
l36d1h:
	ld c,(hl)		;36d1	4e		N
	ld b,h			;36d2	44		D
	ld b,l			;36d3	45		E
	ld d,d			;36d4	52		R
	ld d,e			;36d5	53		S
	ld b,l			;36d6	45		E
	ld b,e			;36d7	43		C
	ld d,h			;36d8	54		T
l36d9h:
	ld c,a			;36d9	4f		O
	ld d,d			;36da	52		R
	ld b,e			;36db	43		C
	ld d,l			;36dc	55		U
	ld d,d			;36dd	52		R
l36deh:
	ld d,d			;36de	52		R
	ld b,l			;36df	45		E
	ld c,(hl)		;36e0	4e		N
	ld d,h			;36e1	54		T
l36e2h:
	jr nz,l371eh		;36e2	20 3a		  :
	ld h,(hl)		;36e4	66		f
	ld l,a			;36e5	6f		o
	ld (hl),d		;36e6	72		r
	ld l,l			;36e7	6d		m
	ld h,c			;36e8	61		a
	ld (hl),h		;36e9	74		t
	jr nz,l3751h		;36ea	20 65		  e
	ld (hl),d		;36ec	72		r
	ld (hl),d		;36ed	72		r
l36eeh:
	ld l,a			;36ee	6f		o
	ld (hl),d		;36ef	72		r
	jr nz,l372ch		;36f0	20 3a		  :
	ld (hl),d		;36f2	72		r
l36f3h:
	ld h,l			;36f3	65		e
	ld h,e			;36f4	63		c
	ld h,c			;36f5	61		a
	ld l,h			;36f6	6c		l
	ld l,c			;36f7	69		i
	ld h,d			;36f8	62		b
	ld (hl),d		;36f9	72		r
	ld h,c			;36fa	61		a
l36fbh:
	ld (hl),h		;36fb	74		t
	ld l,c			;36fc	69		i
	ld l,a			;36fd	6f		o
	ld l,(hl)		;36fe	6e		n
	jr nz,$+103		;36ff	20 65		  e
	ld (hl),d		;3701	72		r
	ld (hl),d		;3702	72		r
	ld l,a			;3703	6f		o
	ld (hl),d		;3704	72		r
	jr nz,$+102		;3705	20 64		  d
	ld (hl),d		;3707	72		r
	ld l,c			;3708	69		i
	halt			;3709	76		v
	ld h,l			;370a	65		e
	jr nz,$+60		;370b	20 3a		  :
	ld c,b			;370d	48		H
	ld b,c			;370e	41		A
	ld c,h			;370f	4c		L
	ld d,h			;3710	54		T
	ld b,l			;3711	45		E
	ld b,h			;3712	44		D
	jr nz,$+114		;3713	20 70		  p
l3715h:
	ld (hl),d		;3715	72		r
	ld h,l			;3716	65		e
	ld (hl),e		;3717	73		s
	ld (hl),e		;3718	73		s
	jr nz,l378dh		;3719	20 72		  r
	ld h,l			;371b	65		e
	ld (hl),h		;371c	74		t
	ld (hl),l		;371d	75		u
l371eh:
	ld (hl),d		;371e	72		r
	ld l,(hl)		;371f	6e		n
	jr nz,$+118		;3720	20 74		  t
	ld l,a			;3722	6f		o
	jr nz,$+118		;3723	20 74		  t
	ld (hl),d		;3725	72		r
	ld a,c			;3726	79		y
	jr nz,$+99		;3727	20 61		  a
	ld h,a			;3729	67		g
	ld h,c			;372a	61		a
	ld l,c			;372b	69		i
l372ch:
	ld l,(hl)		;372c	6e		n
	ld (hl),e		;372d	73		s
	ld h,l			;372e	65		e
	ld h,l			;372f	65		e
	ld l,e			;3730	6b		k
	jr nz,l3798h		;3731	20 65		  e
	ld (hl),d		;3733	72		r
	ld (hl),d		;3734	72		r
	ld l,a			;3735	6f		o
	ld (hl),d		;3736	72		r
	jr nz,$+60		;3737	20 3a		  :
	ld b,h			;3739	44		D
	ld c,c			;373a	49		I
	ld d,e			;373b	53		S
	ld c,e			;373c	4b		K
	ld b,l			;373d	45		E
	ld d,h			;373e	54		T
	ld d,h			;373f	54		T
	ld b,l			;3740	45		E
	jr nz,$+86		;3741	20 54		  T
	ld b,l			;3743	45		E
	ld d,e			;3744	53		S
	ld d,h			;3745	54		T
	ld a,005h		;3746	3e 05		> .
	out (0fah),a		;3748	d3 fa		. .
	ld hl,(0f802h)		;374a	2a 02 f8	* . .
	ld a,049h		;374d	3e 49		> I
	out (0fbh),a		;374f	d3 fb		. .
l3751h:
	out (0fch),a		;3751	d3 fc		. .
	ld a,000h		;3753	3e 00		> .
	out (0f2h),a		;3755	d3 f2		. .
	ld a,0e0h		;3757	3e e0		> .
	out (0f2h),a		;3759	d3 f2		. .
l375bh:
	ld hl,(0f802h)		;375b	2a 02 f8	* . .
	dec hl			;375e	2b		+
	ld a,l			;375f	7d		}
	out (0f3h),a		;3760	d3 f3		. .
	ld a,h			;3762	7c		|
	out (0f3h),a		;3763	d3 f3		. .
	ld a,001h		;3765	3e 01		> .
	out (0fah),a		;3767	d3 fa		. .
	ret			;3769	c9		.
	ld a,005h		;376a	3e 05		> .
	out (0fah),a		;376c	d3 fa		. .
	ld a,045h		;376e	3e 45		> E
	out (0fbh),a		;3770	d3 fb		. .
	out (0fch),a		;3772	d3 fc		. .
	ld a,000h		;3774	3e 00		> .
	out (0f2h),a		;3776	d3 f2		. .
	ld a,0e2h		;3778	3e e2		> .
	out (0f2h),a		;377a	d3 f2		. .
	jr l375bh		;377c	18 dd		. .
	jr nc,$+51		;377e	30 31		0 1
	ld (03433h),a		;3780	32 33 34	2 3 4
	dec (hl)		;3783	35		5
	ld (hl),037h		;3784	36 37		6 7
	jr c,$+59		;3786	38 39		8 9
	nop			;3788	00		.
	ld bc,00302h		;3789	01 02 03	. . .
	inc b			;378c	04		.
l378dh:
	dec b			;378d	05		.
	ld b,007h		;378e	06 07		. .
	ex af,af'		;3790	08		.
	add hl,bc		;3791	09		.
	ld hl,0197eh		;3792	21 7e 19	! ~ .
	ld bc,0000ah		;3795	01 0a 00	. . .
l3798h:
	cpir			;3798	ed b1		. .
	jr nz,l37a7h		;379a	20 0b		  .
	ld (0f878h),hl		;379c	22 78 f8	" x .
	ld ix,(0f878h)		;379f	dd 2a 78 f8	. * x .
	ld a,(ix+009h)		;37a3	dd 7e 09	. ~ .
	ret			;37a6	c9		.
l37a7h:
	ld a,0ffh		;37a7	3e ff		> .
	ret			;37a9	c9		.
	ld a,020h		;37aa	3e 20		>  
	ld hl,0f370h		;37ac	21 70 f3	! p .
	ld de,0f371h		;37af	11 71 f3	. q .
	ld bc,00050h		;37b2	01 50 00	. P .
	ld (hl),a		;37b5	77		w
	ldir			;37b6	ed b0		. .
	ret			;37b8	c9		.
	ld hl,0f000h		;37b9	21 00 f0	! . .
	ld de,0f001h		;37bc	11 01 f0	. . .
	ld bc,007d0h		;37bf	01 d0 07	. . .
	ld a,020h		;37c2	3e 20		>  
	ld (hl),a		;37c4	77		w
	ldir			;37c5	ed b0		. .
	ret			;37c7	c9		.
	ld bc,(0f802h)		;37c8	ed 4b 02 f8	. K . .
	ld hl,0e000h		;37cc	21 00 e0	! . .
	ld de,0e200h		;37cf	11 00 e2	. . .
l37d2h:
	ld a,(de)		;37d2	1a		.
	cp (hl)			;37d3	be		.
	ret nz			;37d4	c0		.
	inc hl			;37d5	23		#
	inc de			;37d6	13		.
	dec bc			;37d7	0b		.
	ld a,c			;37d8	79		y
	cp 000h			;37d9	fe 00		. .
l37dbh:
	jr nz,l37d2h		;37db	20 f5		  .
	ld a,b			;37dd	78		x
	cp 000h			;37de	fe 00		. .
	jr nz,l37d2h		;37e0	20 f0		  .
	ret			;37e2	c9		.
	ld a,(0f81ch)		;37e3	3a 1c f8	: . .
	ld de,0e000h		;37e6	11 00 e0	. . .
	ld hl,(0f802h)		;37e9	2a 02 f8	* . .
	ld b,a			;37ec	47		G
l37edh:
	ld a,b			;37ed	78		x
	ld (de),a		;37ee	12		.
	inc a			;37ef	3c		<
	inc de			;37f0	13		.
	dec hl			;37f1	2b		+
	ld b,a			;37f2	47		G
	xor a			;37f3	af		.
	cp l			;37f4	bd		.
	jr nz,l37edh		;37f5	20 f6		  .
	cp h			;37f7	bc		.
	jr nz,l37edh		;37f8	20 f3		  .
	ld a,(0f81ch)		;37fa	3a 1c f8	: . .
	inc a			;37fd	3c		<
	ld (0bc1ch),a		;37fe	32 1c bc	2 . .
	jp p,034cdh		;3801	f2 cd 34	. . 4
	ld de,01a2ah		;3804	11 2a 1a	. * .
	ret m			;3807	f8		.
	ld ix,0f2c6h		;3808	dd 21 c6 f2	. ! . .
	call 01134h		;380c	cd 34 11	. 4 .
	ld a,(0f872h)		;380f	3a 72 f8	: r .
	cp (iy+000h)		;3812	fd be 00	. . .
	jr z,l3825h		;3815	28 0e		( .
	inc a			;3817	3c		<
	ld (0f872h),a		;3818	32 72 f8	2 r .
	ld a,001h		;381b	3e 01		> .
	ld (0f870h),a		;381d	32 70 f8	2 p .
	out (01ch),a		;3820	d3 1c		. .
	jp 01d7ch		;3822	c3 7c 1d	. | .
l3825h:
	xor a			;3825	af		.
	ld (0f870h),a		;3826	32 70 f8	2 p .
	ld (0f872h),a		;3829	32 72 f8	2 r .
	ld a,(0f80ah)		;382c	3a 0a f8	: . .
	cp 004h			;382f	fe 04		. .
	jr nz,l3838h		;3831	20 05		  .
	ld a,001h		;3833	3e 01		> .
	ld (0f874h),a		;3835	32 74 f8	2 t .
l3838h:
	ld a,(0f84ch)		;3838	3a 4c f8	: L .
	sub 001h		;383b	d6 01		. .
	cp (iy+000h)		;383d	fd be 00	. . .
	jr z,l3848h		;3840	28 06		( .
	call sub_1b2ah		;3842	cd 2a 1b	. * .
	jp 01d7ch		;3845	c3 7c 1d	. | .
l3848h:
	ld hl,(0f848h)		;3848	2a 48 f8	* H .
	inc hl			;384b	23		#
	ld (0f848h),hl		;384c	22 48 f8	" H .
	ld ix,0f2a8h		;384f	dd 21 a8 f2	. ! . .
	call 01134h		;3853	cd 34 11	. 4 .
	ld hl,(0f84ah)		;3856	2a 4a f8	* J .
	sbc hl,bc		;3859	ed 42		. B
	dec hl			;385b	2b		+
	ld (0f84ah),hl		;385c	22 4a f8	" J .
	ld ix,0f29eh		;385f	dd 21 9e f2	. ! . .
	call 01134h		;3863	cd 34 11	. 4 .
	call 024d7h		;3866	cd d7 24	. . $
	call sub_1b2ah		;3869	cd 2a 1b	. * .
	jp 01d7ch		;386c	c3 7c 1d	. | .
	bit 0,a			;386f	cb 47		. G
	jp z,01e0dh		;3871	ca 0d 1e	. . .
	ld a,(ix+001h)		;3874	dd 7e 01	. ~ .
	bit 0,a			;3877	cb 47		. G
	jp nz,l239ch		;3879	c2 9c 23	. . #
	ld a,(0f816h)		;387c	3a 16 f8	: . .
	cp 000h			;387f	fe 00		. .
	jp nz,l2310h		;3881	c2 10 23	. . #
	ld a,(0f82eh)		;3884	3a 2e f8	: . .
	inc a			;3887	3c		<
	ld (0f82eh),a		;3888	32 2e f8	2 . .
	call sub_24c8h		;388b	cd c8 24	. . $
	ld hl,(0f82ch)		;388e	2a 2c f8	* , .
	inc hl			;3891	23		#
	ld (0f82ch),hl		;3892	22 2c f8	" , .
	ld ix,0f10eh		;3895	dd 21 0e f1	. ! . .
	call 01134h		;3899	cd 34 11	. 4 .
	ld hl,(0f818h)		;389c	2a 18 f8	* . .
	ld ix,0f12ch		;389f	dd 21 2c f1	. ! , .
	call 01134h		;38a3	cd 34 11	. 4 .
	ld hl,(0f81ah)		;38a6	2a 1a f8	* . .
	ld ix,0f136h		;38a9	dd 21 36 f1	. ! 6 .
	call 01134h		;38ad	cd 34 11	. 4 .
	ld a,(0f872h)		;38b0	3a 72 f8	: r .
	cp (iy+000h)		;38b3	fd be 00	. . .
	jr z,l38c6h		;38b6	28 0e		( .
	inc a			;38b8	3c		<
	ld (0f872h),a		;38b9	32 72 f8	2 r .
	ld a,001h		;38bc	3e 01		> .
	ld (0f870h),a		;38be	32 70 f8	2 p .
	out (01ch),a		;38c1	d3 1c		. .
	jp 01d7ch		;38c3	c3 7c 1d	. | .
l38c6h:
	xor a			;38c6	af		.
	ld (0f870h),a		;38c7	32 70 f8	2 p .
	ld (0f872h),a		;38ca	32 72 f8	2 r .
	ld a,(0f80ah)		;38cd	3a 0a f8	: . .
	cp 004h			;38d0	fe 04		. .
	jr nz,l38d9h		;38d2	20 05		  .
	ld a,001h		;38d4	3e 01		> .
	ld (0f874h),a		;38d6	32 74 f8	2 t .
l38d9h:
	ld a,(0f82eh)		;38d9	3a 2e f8	: . .
	sub 001h		;38dc	d6 01		. .
	cp (iy+000h)		;38de	fd be 00	. . .
	jr z,l38e9h		;38e1	28 06		( .
	call sub_1b2ah		;38e3	cd 2a 1b	. * .
	jp 01d7ch		;38e6	c3 7c 1d	. | .
l38e9h:
	ld hl,(0f82ah)		;38e9	2a 2a f8	* * .
	inc hl			;38ec	23		#
	ld (0f82ah),hl		;38ed	22 2a f8	" * .
	ld ix,0f118h		;38f0	dd 21 18 f1	. ! . .
	call 01134h		;38f4	cd 34 11	. 4 .
	ld hl,(0f82ch)		;38f7	2a 2c f8	* , .
	sbc hl,bc		;38fa	ed 42		. B
	dec hl			;38fc	2b		+
	ld (0f82ch),hl		;38fd	22 2c f8	" , .
	ld ix,0f10eh		;3900	dd 21 0e f1	. ! . .
	call 01134h		;3904	cd 34 11	. 4 .
	call 024d7h		;3907	cd d7 24	. . $
	call sub_1b2ah		;390a	cd 2a 1b	. * .
	jp 01d7ch		;390d	c3 7c 1d	. | .
	ld a,(0f834h)		;3910	3a 34 f8	: 4 .
	inc a			;3913	3c		<
	ld (0f834h),a		;3914	32 34 f8	2 4 .
	call sub_24c8h		;3917	cd c8 24	. . $
	ld hl,(0f832h)		;391a	2a 32 f8	* 2 .
	inc hl			;391d	23		#
	ld (0f832h),hl		;391e	22 32 f8	" 2 .
	ld ix,0f15eh		;3921	dd 21 5e f1	. ! ^ .
	call 01134h		;3925	cd 34 11	. 4 .
	ld hl,(0f818h)		;3928	2a 18 f8	* . .
	ld ix,0f17ch		;392b	dd 21 7c f1	. ! | .
	call 01134h		;392f	cd 34 11	. 4 .
	ld hl,(0f81ah)		;3932	2a 1a f8	* . .
	ld ix,0f186h		;3935	dd 21 86 f1	. ! . .
	call 01134h		;3939	cd 34 11	. 4 .
	ld a,(0f872h)		;393c	3a 72 f8	: r .
	cp (iy+000h)		;393f	fd be 00	. . .
	jr z,l3952h		;3942	28 0e		( .
	inc a			;3944	3c		<
	ld (0f872h),a		;3945	32 72 f8	2 r .
	ld a,001h		;3948	3e 01		> .
	ld (0f870h),a		;394a	32 70 f8	2 p .
	out (01ch),a		;394d	d3 1c		. .
	jp 01d7ch		;394f	c3 7c 1d	. | .
l3952h:
	xor a			;3952	af		.
	ld (0f870h),a		;3953	32 70 f8	2 p .
	ld (0f872h),a		;3956	32 72 f8	2 r .
	ld a,(0f80ah)		;3959	3a 0a f8	: . .
	cp 004h			;395c	fe 04		. .
	jr nz,l3965h		;395e	20 05		  .
	ld a,001h		;3960	3e 01		> .
	ld (0f874h),a		;3962	32 74 f8	2 t .
l3965h:
	ld a,(0f834h)		;3965	3a 34 f8	: 4 .
	sub 001h		;3968	d6 01		. .
	cp (iy+000h)		;396a	fd be 00	. . .
	jr z,l3975h		;396d	28 06		( .
	call sub_1b2ah		;396f	cd 2a 1b	. * .
	jp 01d7ch		;3972	c3 7c 1d	. | .
l3975h:
	ld hl,(0f830h)		;3975	2a 30 f8	* 0 .
	inc hl			;3978	23		#
	ld (0f830h),hl		;3979	22 30 f8	" 0 .
	ld ix,0f168h		;397c	dd 21 68 f1	. ! h .
	call 01134h		;3980	cd 34 11	. 4 .
	ld hl,(0f832h)		;3983	2a 32 f8	* 2 .
	sbc hl,bc		;3986	ed 42		. B
	dec hl			;3988	2b		+
	ld (0f832h),hl		;3989	22 32 f8	" 2 .
	ld ix,0f15eh		;398c	dd 21 5e f1	. ! ^ .
	call 01134h		;3990	cd 34 11	. 4 .
	call 024d7h		;3993	cd d7 24	. . $
	call sub_1b2ah		;3996	cd 2a 1b	. * .
	jp 01d7ch		;3999	c3 7c 1d	. | .
	ld a,(0f816h)		;399c	3a 16 f8	: . .
	cp 000h			;399f	fe 00		. .
	jp nz,02430h		;39a1	c2 30 24	. 0 $
	ld a,(0f83ah)		;39a4	3a 3a f8	: : .
	inc a			;39a7	3c		<
	ld (0f83ah),a		;39a8	32 3a f8	2 : .
	call sub_24c8h		;39ab	cd c8 24	. . $
	ld hl,(0f838h)		;39ae	2a 38 f8	* 8 .
	inc hl			;39b1	23		#
	ld (0f838h),hl		;39b2	22 38 f8	" 8 .
	ld ix,0f1aeh		;39b5	dd 21 ae f1	. ! . .
	call 01134h		;39b9	cd 34 11	. 4 .
	ld hl,(0f818h)		;39bc	2a 18 f8	* . .
	ld ix,0f1cch		;39bf	dd 21 cc f1	. ! . .
	call 01134h		;39c3	cd 34 11	. 4 .
	ld hl,(0f81ah)		;39c6	2a 1a f8	* . .
	ld ix,0f1d6h		;39c9	dd 21 d6 f1	. ! . .
	call 01134h		;39cd	cd 34 11	. 4 .
	ld a,(0f872h)		;39d0	3a 72 f8	: r .
	cp (iy+000h)		;39d3	fd be 00	. . .
	jr z,l39e6h		;39d6	28 0e		( .
	inc a			;39d8	3c		<
	ld (0f872h),a		;39d9	32 72 f8	2 r .
	ld a,001h		;39dc	3e 01		> .
	ld (0f870h),a		;39de	32 70 f8	2 p .
	out (01ch),a		;39e1	d3 1c		. .
	jp 01d7ch		;39e3	c3 7c 1d	. | .
l39e6h:
	xor a			;39e6	af		.
	ld (0f870h),a		;39e7	32 70 f8	2 p .
	ld (0f872h),a		;39ea	32 72 f8	2 r .
	ld a,(0f80ah)		;39ed	3a 0a f8	: . .
	cp 004h			;39f0	fe 04		. .
	jr nz,l39f9h		;39f2	20 05		  .
	ld a,001h		;39f4	3e 01		> .
	ld (0f874h),a		;39f6	32 74 f8	2 t .
l39f9h:
	ld a,(0f83ah)		;39f9	3a 3a f8	: : .
	sub 001h		;39fc	d6 01		. .
	cp (iy-008h)		;39fe	fd be f8	. . .
	ret			;3a01	c9		.
	di			;3a02	f3		.
	ld a,(0f808h)		;3a03	3a 08 f8	: . .
	rlca			;3a06	07		.
	rlca			;3a07	07		.
	rlca			;3a08	07		.
	rlca			;3a09	07		.
	rlca			;3a0a	07		.
	rlca			;3a0b	07		.
	or 005h			;3a0c	f6 05		. .
	call 00c66h		;3a0e	cd 66 0c	. f .
	jp nz,l2ec7h		;3a11	c2 c7 2e	. . .
	ld a,(0f816h)		;3a14	3a 16 f8	: . .
	rlca			;3a17	07		.
	rlca			;3a18	07		.
	ld b,a			;3a19	47		G
	ld a,(0f804h)		;3a1a	3a 04 f8	: . .
	or b			;3a1d	b0		.
	call 00c66h		;3a1e	cd 66 0c	. f .
	jp nz,l2ec7h		;3a21	c2 c7 2e	. . .
	ld a,(0f818h)		;3a24	3a 18 f8	: . .
	call 00c66h		;3a27	cd 66 0c	. f .
	jp nz,l2ec7h		;3a2a	c2 c7 2e	. . .
	ld a,(0f816h)		;3a2d	3a 16 f8	: . .
	call 00c66h		;3a30	cd 66 0c	. f .
	jp nz,l2ec7h		;3a33	c2 c7 2e	. . .
	ld a,(0f81ah)		;3a36	3a 1a f8	: . .
	call 00c66h		;3a39	cd 66 0c	. f .
	jp nz,l2ec7h		;3a3c	c2 c7 2e	. . .
	ld a,(0f81eh)		;3a3f	3a 1e f8	: . .
	call 00c66h		;3a42	cd 66 0c	. f .
	jp nz,l2ec7h		;3a45	c2 c7 2e	. . .
	ld a,(0f812h)		;3a48	3a 12 f8	: . .
	call 00c66h		;3a4b	cd 66 0c	. f .
	jp nz,l2ec7h		;3a4e	c2 c7 2e	. . .
	ld a,(0f808h)		;3a51	3a 08 f8	: . .
l3a54h:
	cp 001h			;3a54	fe 01		. .
	jr z,l3a69h		;3a56	28 11		( .
	ld a,007h		;3a58	3e 07		> .
	call 00c66h		;3a5a	cd 66 0c	. f .
	jp nz,l2ec7h		;3a5d	c2 c7 2e	. . .
	ld a,080h		;3a60	3e 80		> .
	call 00c66h		;3a62	cd 66 0c	. f .
	jp nz,l2ec7h		;3a65	c2 c7 2e	. . .
l3a68h:
	ret			;3a68	c9		.
l3a69h:
	ld a,(0f806h)		;3a69	3a 06 f8	: . .
	cp 001h			;3a6c	fe 01		. .
	jr z,l3a7ah		;3a6e	28 0a		( .
	ld a,00ah		;3a70	3e 0a		> .
	call 00c66h		;3a72	cd 66 0c	. f .
	jp nz,l2ec7h		;3a75	c2 c7 2e	. . .
	jr l3a82h		;3a78	18 08		. .
l3a7ah:
	ld a,01bh		;3a7a	3e 1b		> .
	call 00c66h		;3a7c	cd 66 0c	. f .
	jp nz,l2ec7h		;3a7f	c2 c7 2e	. . .
l3a82h:
	ld a,0ffh		;3a82	3e ff		> .
	call 00c66h		;3a84	cd 66 0c	. f .
	jp nz,l2ec7h		;3a87	c2 c7 2e	. . .
	ret			;3a8a	c9		.
	di			;3a8b	f3		.
	ld a,(0f808h)		;3a8c	3a 08 f8	: . .
	rlca			;3a8f	07		.
	rlca			;3a90	07		.
	rlca			;3a91	07		.
	rlca			;3a92	07		.
l3a93h:
	rlca			;3a93	07		.
	rlca			;3a94	07		.
	or 006h			;3a95	f6 06		. .
	jp l1a0eh		;3a97	c3 0e 1a	. . .
	push hl			;3a9a	e5		.
	push ix			;3a9b	dd e5		. .
	xor a			;3a9d	af		.
	ld (0f876h),a		;3a9e	32 76 f8	2 v .
	ld (0f826h),a		;3aa1	32 26 f8	2 & .
l3aa4h:
	ei			;3aa4	fb		.
	ld hl,00bb8h		;3aa5	21 b8 0b	! . .
l3aa8h:
	dec hl			;3aa8	2b		+
	ld a,l			;3aa9	7d		}
	or h			;3aaa	b4		.
	jr nz,l3aa8h		;3aab	20 fb		  .
	di			;3aad	f3		.
	pop ix			;3aae	dd e1		. .
	pop hl			;3ab0	e1		.
	ld a,(0f826h)		;3ab1	3a 26 f8	: & .
	cp 001h			;3ab4	fe 01		. .
	ret z			;3ab6	c8		.
	push hl			;3ab7	e5		.
	push ix			;3ab8	dd e5		. .
l3abah:
	djnz l3aa4h		;3aba	10 e8		. .
	ld a,001h		;3abc	3e 01		> .
	ld (0f876h),a		;3abe	32 76 f8	2 v .
	pop ix			;3ac1	dd e1		. .
	pop hl			;3ac3	e1		.
	ret			;3ac4	c9		.
	di			;3ac5	f3		.
	ld a,003h		;3ac6	3e 03		> .
	call 00c66h		;3ac8	cd 66 0c	. f .
	jp nz,l2ec7h		;3acb	c2 c7 2e	. . .
	call 01ae0h		;3ace	cd e0 1a	. . .
	call 00c66h		;3ad1	cd 66 0c	. f .
	jp nz,l2ec7h		;3ad4	c2 c7 2e	. . .
	ld a,028h		;3ad7	3e 28		> (
	call 00c66h		;3ad9	cd 66 0c	. f .
	jp nz,l2ec7h		;3adc	c2 c7 2e	. . .
	ret			;3adf	c9		.
	ld a,(0f88eh)		;3ae0	3a 8e f8	: . .
l3ae3h:
	ld hl,01afch		;3ae3	21 fc 1a	! . .
	ld bc,00010h		;3ae6	01 10 00	. . .
l3ae9h:
	cpir			;3ae9	ed b1		. .
	ld (0f890h),hl		;3aeb	22 90 f8	" . .
	ld ix,(0f890h)		;3aee	dd 2a 90 f8	. * . .
l3af2h:
	ld a,(ix+00fh)		;3af2	dd 7e 0f	. ~ .
	rlca			;3af5	07		.
	rlca			;3af6	07		.
	rlca			;3af7	07		.
	rlca			;3af8	07		.
	add a,00ah		;3af9	c6 0a		. .
l3afbh:
	ret			;3afb	c9		.
	ld bc,00302h		;3afc	01 02 03	. . .
	inc b			;3aff	04		.
	dec b			;3b00	05		.
	ld b,007h		;3b01	06 07		. .
	ex af,af'		;3b03	08		.
	add hl,bc		;3b04	09		.
	ld a,(bc)		;3b05	0a		.
	dec bc			;3b06	0b		.
	inc c			;3b07	0c		.
	dec c			;3b08	0d		.
	ld c,00fh		;3b09	0e 0f		. .
	djnz $+17		;3b0b	10 0f		. .
	ld c,00dh		;3b0d	0e 0d		. .
	inc c			;3b0f	0c		.
	dec bc			;3b10	0b		.
	ld a,(bc)		;3b11	0a		.
	add hl,bc		;3b12	09		.
	ex af,af'		;3b13	08		.
	rlca			;3b14	07		.
	ld b,005h		;3b15	06 05		. .
	inc b			;3b17	04		.
l3b18h:
	inc bc			;3b18	03		.
	ld (bc),a		;3b19	02		.
	ld bc,l3e00h		;3b1a	01 00 3e	. . >
	ld bc,014d3h		;3b1d	01 d3 14	. . .
	ld b,0c8h		;3b20	06 c8		. .
	call 01a9ah		;3b22	cd 9a 1a	. . .
	ret			;3b25	c9		.
	xor a			;3b26	af		.
	out (014h),a		;3b27	d3 14		. .
	ret			;3b29	c9		.
	xor a			;3b2a	af		.
	ld (0f82eh),a		;3b2b	32 2e f8	2 . .
l3b2eh:
	ld (0f834h),a		;3b2e	32 34 f8	2 4 .
	ld (0f83ah),a		;3b31	32 3a f8	2 : .
	ld (0f840h),a		;3b34	32 40 f8	2 @ .
	ld (0f846h),a		;3b37	32 46 f8	2 F .
	ld (0f84ch),a		;3b3a	32 4c f8	2 L .
	ld (0f852h),a		;3b3d	32 52 f8	2 R .
	ld (0f858h),a		;3b40	32 58 f8	2 X .
	ld (0f85eh),a		;3b43	32 5e f8	2 ^ .
	ld (0f864h),a		;3b46	32 64 f8	2 d .
	ret			;3b49	c9		.
	push af			;3b4a	f5		.
	in a,(010h)		;3b4b	db 10		. .
	cp 052h			;3b4d	fe 52		. R
	jp z,01d1ah		;3b4f	ca 1a 1d	. . .
	ld a,(0f898h)		;3b52	3a 98 f8	: . .
	cp 00fh			;3b55	fe 0f		. .
	jp z,01d1ah		;3b57	ca 1a 1d	. . .
	ld a,020h		;3b5a	3e 20		>  
	ld de,0f708h		;3b5c	11 08 f7	. . .
	ld (de),a		;3b5f	12		.
	ld a,(0f898h)		;3b60	3a 98 f8	: . .
	cp 00eh			;3b63	fe 0e		. .
	jp z,01c82h		;3b65	ca 82 1c	. . .
	cp 00dh			;3b68	fe 0d		. .
	jp z,01c66h		;3b6a	ca 66 1c	. f .
	cp 00ch			;3b6d	fe 0c		. .
	jp z,l1ce5h		;3b6f	ca e5 1c	. . .
	cp 00bh			;3b72	fe 0b		. .
	jp z,01cd1h		;3b74	ca d1 1c	. . .
	cp 00ah			;3b77	fe 0a		. .
	jp z,l1cbch		;3b79	ca bc 1c	. . .
	cp 009h			;3b7c	fe 09		. .
	jp z,01cf9h		;3b7e	ca f9 1c	. . .
	cp 008h			;3b81	fe 08		. .
	jp z,l1ca7h		;3b83	ca a7 1c	. . .
	cp 007h			;3b86	fe 07		. .
	jp z,l1c4dh		;3b88	ca 4d 1c	. M .
	cp 006h			;3b8b	fe 06		. .
l3b8dh:
	jp z,l1c31h		;3b8d	ca 31 1c	. 1 .
	cp 005h			;3b90	fe 05		. .
	jp z,l1c18h		;3b92	ca 18 1c	. . .
	cp 004h			;3b95	fe 04		. .
	jr z,l3bfch		;3b97	28 63		( c
	cp 003h			;3b99	fe 03		. .
	jr z,l3bcbh		;3b9b	28 2e		( .
	cp 002h			;3b9d	fe 02		. .
	jr z,l3bb6h		;3b9f	28 15		( .
	in a,(010h)		;3ba1	db 10		. .
	ld d,a			;3ba3	57		W
	call 01992h		;3ba4	cd 92 19	. . .
	cp 002h			;3ba7	fe 02		. .
l3ba9h:
	jp nc,01d56h		;3ba9	d2 56 1d	. V .
	ld (0f804h),a		;3bac	32 04 f8	2 . .
	ld hl,0f0aeh		;3baf	21 ae f0	! . .
	ld (hl),d		;3bb2	72		r
	pop af			;3bb3	f1		.
	reti			;3bb4	ed 4d		. M
l3bb6h:
	in a,(010h)		;3bb6	db 10		. .
	ld d,a			;3bb8	57		W
	call 01992h		;3bb9	cd 92 19	. . .
	cp 003h			;3bbc	fe 03		. .
	jp nc,01d56h		;3bbe	d2 56 1d	. V .
l3bc1h:
	ld (0f806h),a		;3bc1	32 06 f8	2 . .
	ld hl,0f109h		;3bc4	21 09 f1	! . .
	ld (hl),d		;3bc7	72		r
	pop af			;3bc8	f1		.
	reti			;3bc9	ed 4d		. M
l3bcbh:
	in a,(010h)		;3bcb	db 10		. .
	ld d,a			;3bcd	57		W
	call 01992h		;3bce	cd 92 19	. . .
	cp 002h			;3bd1	fe 02		. .
	jp nc,01d56h		;3bd3	d2 56 1d	. V .
	ld (0f808h),a		;3bd6	32 08 f8	2 . .
	ld hl,0f15eh		;3bd9	21 5e f1	! ^ .
	ld (hl),d		;3bdc	72		r
	cp 001h			;3bdd	fe 01		. .
	jr z,l3beeh		;3bdf	28 0d		( .
	xor a			;3be1	af		.
	ld (0f81eh),a		;3be2	32 1e f8	2 . .
	ld hl,00080h		;3be5	21 80 00	! . .
	ld (0f89ah),hl		;3be8	22 9a f8	" . .
	pop af			;3beb	f1		.
l3bech:
	reti			;3bec	ed 4d		. M
l3beeh:
	ld a,002h		;3bee	3e 02		> .
	ld (0f81eh),a		;3bf0	32 1e f8	2 . .
	ld hl,00200h		;3bf3	21 00 02	! . .
	ld (0f89ah),hl		;3bf6	22 9a f8	" . .
	pop af			;3bf9	f1		.
	reti			;3bfa	ed 4d		. M
l3bfch:
	in a,(010h)		;3bfc	db 10		. .
l3bfeh:
	ld d,a			;3bfe	57		W
	call sub_2800h		;3bff	cd 00 28	. . (
	ld b,0cdh		;3c02	06 cd		. .
	ld hl,(0c31bh)		;3c04	2a 1b c3	* . .
	ld a,h			;3c07	7c		|
	dec e			;3c08	1d		.
	ld hl,(0f836h)		;3c09	2a 36 f8	* 6 .
	inc hl			;3c0c	23		#
l3c0dh:
	ld (0f836h),hl		;3c0d	22 36 f8	" 6 .
	ld ix,0f1b8h		;3c10	dd 21 b8 f1	. ! . .
	call 01134h		;3c14	cd 34 11	. 4 .
	ld hl,(0f838h)		;3c17	2a 38 f8	* 8 .
	sbc hl,bc		;3c1a	ed 42		. B
	dec hl			;3c1c	2b		+
l3c1dh:
	ld (0f838h),hl		;3c1d	22 38 f8	" 8 .
	ld ix,0f1aeh		;3c20	dd 21 ae f1	. ! . .
	call 01134h		;3c24	cd 34 11	. 4 .
	call 024d7h		;3c27	cd d7 24	. . $
l3c2ah:
	call sub_1b2ah		;3c2a	cd 2a 1b	. * .
	jp 01d7ch		;3c2d	c3 7c 1d	. | .
	ld a,(0f840h)		;3c30	3a 40 f8	: @ .
	inc a			;3c33	3c		<
	ld (0f840h),a		;3c34	32 40 f8	2 @ .
	call sub_24c8h		;3c37	cd c8 24	. . $
	ld hl,(0f83eh)		;3c3a	2a 3e f8	* > .
	inc hl			;3c3d	23		#
	ld (0f83eh),hl		;3c3e	22 3e f8	" > .
	ld ix,0f1feh		;3c41	dd 21 fe f1	. ! . .
l3c45h:
	call 01134h		;3c45	cd 34 11	. 4 .
	ld hl,(0f818h)		;3c48	2a 18 f8	* . .
	ld ix,0f21ch		;3c4b	dd 21 1c f2	. ! . .
l3c4fh:
	call 01134h		;3c4f	cd 34 11	. 4 .
	ld hl,(0f81ah)		;3c52	2a 1a f8	* . .
	ld ix,0f226h		;3c55	dd 21 26 f2	. ! & .
	call 01134h		;3c59	cd 34 11	. 4 .
	ld a,(0f872h)		;3c5c	3a 72 f8	: r .
	cp (iy+000h)		;3c5f	fd be 00	. . .
	jr z,l3c72h		;3c62	28 0e		( .
	inc a			;3c64	3c		<
	ld (0f872h),a		;3c65	32 72 f8	2 r .
	ld a,001h		;3c68	3e 01		> .
	ld (0f870h),a		;3c6a	32 70 f8	2 p .
	out (01ch),a		;3c6d	d3 1c		. .
	jp 01d7ch		;3c6f	c3 7c 1d	. | .
l3c72h:
	xor a			;3c72	af		.
	ld (0f870h),a		;3c73	32 70 f8	2 p .
	ld (0f872h),a		;3c76	32 72 f8	2 r .
	ld a,(0f80ah)		;3c79	3a 0a f8	: . .
	cp 004h			;3c7c	fe 04		. .
	jr nz,l3c85h		;3c7e	20 05		  .
	ld a,001h		;3c80	3e 01		> .
	ld (0f874h),a		;3c82	32 74 f8	2 t .
l3c85h:
	ld a,(0f840h)		;3c85	3a 40 f8	: @ .
	sub 001h		;3c88	d6 01		. .
	cp (iy+000h)		;3c8a	fd be 00	. . .
	jr z,l3c92h		;3c8d	28 03		( .
	jp 01d7ch		;3c8f	c3 7c 1d	. | .
l3c92h:
	ld hl,(0f83ch)		;3c92	2a 3c f8	* < .
	inc hl			;3c95	23		#
	ld (0f83ch),hl		;3c96	22 3c f8	" < .
	ld ix,0f208h		;3c99	dd 21 08 f2	. ! . .
	call 01134h		;3c9d	cd 34 11	. 4 .
	ld hl,(0f83eh)		;3ca0	2a 3e f8	* > .
	sbc hl,bc		;3ca3	ed 42		. B
	dec hl			;3ca5	2b		+
	ld (0f83eh),hl		;3ca6	22 3e f8	" > .
	ld ix,0f1feh		;3ca9	dd 21 fe f1	. ! . .
	call 01134h		;3cad	cd 34 11	. 4 .
	call 024d7h		;3cb0	cd d7 24	. . $
	call sub_1b2ah		;3cb3	cd 2a 1b	. * .
	jp 01d7ch		;3cb6	c3 7c 1d	. | .
	ld a,(0f80ah)		;3cb9	3a 0a f8	: . .
	cp 005h			;3cbc	fe 05		. .
	jr nz,l3cc4h		;3cbe	20 04		  .
	call sub_2550h		;3cc0	cd 50 25	. P %
	ret			;3cc3	c9		.
l3cc4h:
	call l2513h		;3cc4	cd 13 25	. . %
	ret			;3cc7	c9		.
	ld a,(0f80ah)		;3cc8	3a 0a f8	: . .
	cp 005h			;3ccb	fe 05		. .
	jr nz,l3cd3h		;3ccd	20 04		  .
	call sub_2523h		;3ccf	cd 23 25	. # %
	ret			;3cd2	c9		.
l3cd3h:
	call 024e6h		;3cd3	cd e6 24	. . $
	ret			;3cd6	c9		.
	ld a,(0f80ah)		;3cd7	3a 0a f8	: . .
	cp 005h			;3cda	fe 05		. .
	jr nz,l3ce2h		;3cdc	20 04		  .
	call 02565h		;3cde	cd 65 25	. e %
	ret			;3ce1	c9		.
l3ce2h:
	call l2579h		;3ce2	cd 79 25	. y %
	ret			;3ce5	c9		.
	ld hl,(0f87eh)		;3ce6	2a 7e f8	* ~ .
	inc hl			;3ce9	23		#
	ld (0f87eh),hl		;3cea	22 7e f8	" ~ .
	ld ix,0f6aeh		;3ced	dd 21 ae f6	. ! . .
	call 01134h		;3cf1	cd 34 11	. 4 .
l3cf4h:
	ld hl,(0f816h)		;3cf4	2a 16 f8	* . .
	ld ix,0f6c2h		;3cf7	dd 21 c2 f6	. ! . .
	call 01134h		;3cfb	cd 34 11	. 4 .
	ld hl,(0f818h)		;3cfe	2a 18 f8	* . .
	ld ix,0f6cch		;3d01	dd 21 cc f6	. ! . .
	call 01134h		;3d05	cd 34 11	. 4 .
	ld hl,(0f81ah)		;3d08	2a 1a f8	* . .
	ld ix,0f6d6h		;3d0b	dd 21 d6 f6	. ! . .
	call 01134h		;3d0f	cd 34 11	. 4 .
	ret			;3d12	c9		.
sub_3d13h:
	ld hl,(0f880h)		;3d13	2a 80 f8	* . .
	inc hl			;3d16	23		#
	ld (0f880h),hl		;3d17	22 80 f8	" . .
	ld ix,0f6b8h		;3d1a	dd 21 b8 f6	. ! . .
	call 01134h		;3d1e	cd 34 11	. 4 .
	jr l3cf4h		;3d21	18 d1		. .
	ld hl,(0f882h)		;3d23	2a 82 f8	* . .
	inc hl			;3d26	23		#
	ld (0f882h),hl		;3d27	22 82 f8	" . .
	ld ix,0f6feh		;3d2a	dd 21 fe f6	. ! . .
	call 01134h		;3d2e	cd 34 11	. 4 .
l3d31h:
	ld hl,(0f816h)		;3d31	2a 16 f8	* . .
	ld ix,0f712h		;3d34	dd 21 12 f7	. ! . .
	call 01134h		;3d38	cd 34 11	. 4 .
	ld hl,(0f818h)		;3d3b	2a 18 f8	* . .
	ld ix,0f71ch		;3d3e	dd 21 1c f7	. ! . .
	call 01134h		;3d42	cd 34 11	. 4 .
	ld hl,(0f81ah)		;3d45	2a 1a f8	* . .
	ld ix,0f726h		;3d48	dd 21 26 f7	. ! & .
	call 01134h		;3d4c	cd 34 11	. 4 .
	ret			;3d4f	c9		.
	ld hl,(0f884h)		;3d50	2a 84 f8	* . .
	inc hl			;3d53	23		#
	ld (0f884h),hl		;3d54	22 84 f8	" . .
	ld ix,0f708h		;3d57	dd 21 08 f7	. ! . .
	call 01134h		;3d5b	cd 34 11	. 4 .
	ld a,001h		;3d5e	3e 01		> .
	ld (0f886h),a		;3d60	32 86 f8	2 . .
	jr l3d31h		;3d63	18 cc		. .
	call sub_2550h		;3d65	cd 50 25	. P %
	ld hl,(0f882h)		;3d68	2a 82 f8	* . .
	sbc hl,bc		;3d6b	ed 42		. B
sub_3d6dh:
	dec hl			;3d6d	2b		+
	ld (0f882h),hl		;3d6e	22 82 f8	" . .
	ld ix,0f6feh		;3d71	dd 21 fe f6	. ! . .
	call 01134h		;3d75	cd 34 11	. 4 .
	ret			;3d78	c9		.
	call l2513h		;3d79	cd 13 25	. . %
	ld hl,(0f87eh)		;3d7c	2a 7e f8	* ~ .
	sbc hl,bc		;3d7f	ed 42		. B
	dec hl			;3d81	2b		+
	ld (0f87eh),hl		;3d82	22 7e f8	" ~ .
	ld ix,0f6aeh		;3d85	dd 21 ae f6	. ! . .
	call 01134h		;3d89	cd 34 11	. 4 .
	ret			;3d8c	c9		.
	di			;3d8d	f3		.
	call 019b9h		;3d8e	cd b9 19	. . .
	ld hl,01621h		;3d91	21 21 16	! ! .
	ld de,0f01fh		;3d94	11 1f f0	. . .
	ld bc,00014h		;3d97	01 14 00	. . .
	ldir			;3d9a	ed b0		. .
	call 00264h		;3d9c	cd 64 02	. d .
	ld hl,00254h		;3d9f	21 54 02	! T .
	ld a,l			;3da2	7d		}
sub_3da3h:
	out (012h),a		;3da3	d3 12		. .
	ld a,04fh		;3da5	3e 4f		> O
	out (012h),a		;3da7	d3 12		. .
	ld a,087h		;3da9	3e 87		> .
	out (012h),a		;3dab	d3 12		. .
	in a,(010h)		;3dad	db 10		. .
	ld a,003h		;3daf	3e 03		> .
	out (00ch),a		;3db1	d3 0c		. .
	out (00dh),a		;3db3	d3 0d		. .
	out (00eh),a		;3db5	d3 0e		. .
	out (00fh),a		;3db7	d3 0f		. .
	ld hl,00208h		;3db9	21 08 02	! . .
	ld a,l			;3dbc	7d		}
	out (00ch),a		;3dbd	d3 0c		. .
	ld hl,00000h		;3dbf	21 00 00	! . .
	ld (0f816h),hl		;3dc2	22 16 f8	" . .
	ld (0f818h),hl		;3dc5	22 18 f8	" . .
	ld (0f804h),hl		;3dc8	22 04 f8	" . .
	ld (0f81ah),hl		;3dcb	22 1a f8	" . .
	ld (0f88ah),hl		;3dce	22 8a f8	" . .
l3dd1h:
	ei			;3dd1	fb		.
	ld a,001h		;3dd2	3e 01		> .
	ld (0f898h),a		;3dd4	32 98 f8	2 . .
	ld hl,01635h		;3dd7	21 35 16	! 5 .
	ld de,0f0a0h		;3dda	11 a0 f0	. . .
	ld bc,0000dh		;3ddd	01 0d 00	. . .
	ldir			;3de0	ed b0		. .
	ei			;3de2	fb		.
	halt			;3de3	76		v
	cp 03fh			;3de4	fe 3f		. ?
	jr z,l3dd1h		;3de6	28 e9		( .
l3de8h:
	ld a,002h		;3de8	3e 02		> .
	ld (0f898h),a		;3dea	32 98 f8	2 . .
	ld hl,01675h		;3ded	21 75 16	! u .
	ld de,0f0f0h		;3df0	11 f0 f0	. . .
	ld bc,00018h		;3df3	01 18 00	. . .
	ldir			;3df6	ed b0		. .
	ei			;3df8	fb		.
	halt			;3df9	76		v
	cp 03fh			;3dfa	fe 3f		. ?
	jr z,l3de8h		;3dfc	28 ea		( .
	ld a,003h		;3dfe	3e 03		> .
l3e00h:
	call 01134h		;3e00	cd 34 11	. 4 .
	ld hl,(0f818h)		;3e03	2a 18 f8	* . .
	ld ix,0f7bch		;3e06	dd 21 bc f7	. ! . .
	call 01134h		;3e0a	cd 34 11	. 4 .
	ld hl,(0f81ah)		;3e0d	2a 1a f8	* . .
	ld ix,0f7c6h		;3e10	dd 21 c6 f7	. ! . .
	call 01134h		;3e14	cd 34 11	. 4 .
	call sub_1a02h		;3e17	cd 02 1a	. . .
	ld b,0c8h		;3e1a	06 c8		. .
	call 01a9ah		;3e1c	cd 9a 1a	. . .
	ld a,(0f876h)		;3e1f	3a 76 f8	: v .
	cp 000h			;3e22	fe 00		. .
	jr z,l3e39h		;3e24	28 13		( .
	ld hl,(0f86ah)		;3e26	2a 6a f8	* j .
	inc hl			;3e29	23		#
	ld (0f86ah),hl		;3e2a	22 6a f8	" j .
	ld ix,0f4d8h		;3e2d	dd 21 d8 f4	. ! . .
	call 01134h		;3e31	cd 34 11	. 4 .
	call sub_24b9h		;3e34	cd b9 24	. . $
	jr l3e79h		;3e37	18 40		. @
l3e39h:
	ld a,(0f870h)		;3e39	3a 70 f8	: p .
	cp 000h			;3e3c	fe 00		. .
	jp nz,02df1h		;3e3e	c2 f1 2d	. . -
	ld a,(0f874h)		;3e41	3a 74 f8	: t .
	cp 000h			;3e44	fe 00		. .
	jr nz,l3e79h		;3e46	20 31		  1
l3e48h:
	call 0196ah		;3e48	cd 6a 19	. j .
	ld a,005h		;3e4b	3e 05		> .
	ld (0f80ah),a		;3e4d	32 0a f8	2 . .
	call sub_1a8bh		;3e50	cd 8b 1a	. . .
	ld b,0c8h		;3e53	06 c8		. .
	call 01a9ah		;3e55	cd 9a 1a	. . .
	ld a,(0f876h)		;3e58	3a 76 f8	: v .
	cp 000h			;3e5b	fe 00		. .
	jr z,l3e72h		;3e5d	28 13		( .
	ld hl,(0f86ah)		;3e5f	2a 6a f8	* j .
	inc hl			;3e62	23		#
	ld (0f86ah),hl		;3e63	22 6a f8	" j .
	ld ix,0f4d8h		;3e66	dd 21 d8 f4	. ! . .
	call 01134h		;3e6a	cd 34 11	. 4 .
	call sub_24b9h		;3e6d	cd b9 24	. . $
	jr l3e79h		;3e70	18 07		. .
l3e72h:
	ld a,(0f870h)		;3e72	3a 70 f8	: p .
	cp 000h			;3e75	fe 00		. .
	jr nz,l3e48h		;3e77	20 cf		  .
l3e79h:
	xor a			;3e79	af		.
	ld (0f872h),a		;3e7a	32 72 f8	2 r .
	ld (0f874h),a		;3e7d	32 74 f8	2 t .
	ld a,(0f81ah)		;3e80	3a 1a f8	: . .
	inc a			;3e83	3c		<
	ld (0f81ah),a		;3e84	32 1a f8	2 . .
	ld b,a			;3e87	47		G
	ld a,(0f812h)		;3e88	3a 12 f8	: . .
	inc a			;3e8b	3c		<
	cp b			;3e8c	b8		.
	jp nz,l2deeh		;3e8d	c2 ee 2d	. . -
	ld a,(0f816h)		;3e90	3a 16 f8	: . .
	cp 000h			;3e93	fe 00		. .
	jr nz,l3ea6h		;3e95	20 0f		  .
	ld a,(0f814h)		;3e97	3a 14 f8	: . .
	cp 000h			;3e9a	fe 00		. .
	jr z,l3ea6h		;3e9c	28 08		( .
	ld a,001h		;3e9e	3e 01		> .
	ld (0f816h),a		;3ea0	32 16 f8	2 . .
	jp 02dd9h		;3ea3	c3 d9 2d	. . -
l3ea6h:
	ld a,(0f818h)		;3ea6	3a 18 f8	: . .
	inc a			;3ea9	3c		<
	ld (0f818h),a		;3eaa	32 18 f8	2 . .
	ld b,a			;3ead	47		G
	ld a,(0f80eh)		;3eae	3a 0e f8	: . .
	inc a			;3eb1	3c		<
	cp b			;3eb2	b8		.
	jp nz,l2dd4h+1		;3eb3	c2 d5 2d	. . -
	ld hl,(0f828h)		;3eb6	2a 28 f8	* ( .
	inc hl			;3eb9	23		#
	ld (0f828h),hl		;3eba	22 28 f8	" ( .
	ld ix,0f05ah		;3ebd	dd 21 5a f0	. ! Z .
	call 01134h		;3ec1	cd 34 11	. 4 .
	jp 02d12h		;3ec4	c3 12 2d	. . -
	ld a,020h		;3ec7	3e 20		>  
	ld hl,0f780h		;3ec9	21 80 f7	! . .
	ld de,0f781h		;3ecc	11 81 f7	. . .
	ld bc,00050h		;3ecf	01 50 00	. P .
	ld (hl),a		;3ed2	77		w
	ldir			;3ed3	ed b0		. .
	ld hl,02ee1h		;3ed5	21 e1 2e	! . .
	ld de,0f78dh		;3ed8	11 8d f7	. . .
	ld bc,00037h		;3edb	01 37 00	. 7 .
	ldir			;3ede	ed b0		. .
	halt			;3ee0	76		v
	ld b,(hl)		;3ee1	46		F
	ld b,c			;3ee2	41		A
	ld d,l			;3ee3	55		U
	ld c,h			;3ee4	4c		L
	ld d,h			;3ee5	54		T
	jr nz,$+75		;3ee6	20 49		  I
	ld c,(hl)		;3ee8	4e		N
	jr nz,$+79		;3ee9	20 4d		  M
	ld b,c			;3eeb	41		A
	ld c,c			;3eec	49		I
	ld c,(hl)		;3eed	4e		N
	jr nz,$+85		;3eee	20 53		  S
	ld d,h			;3ef0	54		T
	ld b,c			;3ef1	41		A
sub_3ef2h:
	ld d,h			;3ef2	54		T
	ld d,l			;3ef3	55		U
	ld d,e			;3ef4	53		S
	jr nz,$+84		;3ef5	20 52		  R
	ld b,l			;3ef7	45		E
	ld b,a			;3ef8	47		G
	ld c,c			;3ef9	49		I
	ld d,e			;3efa	53		S
	ld d,h			;3efb	54		T
	ld b,l			;3efc	45		E
	ld d,d			;3efd	52		R
	ld l,020h		;3efe	2e 20		.  
	ld d,d			;3f00	52		R
	ld b,l			;3f01	45		E
	ld d,e			;3f02	53		S
l3f03h:
	ld b,l			;3f03	45		E
	ld d,h			;3f04	54		T
	jr nz,l3f5bh		;3f05	20 54		  T
	ld c,a			;3f07	4f		O
	jr nz,$+85		;3f08	20 53		  S
	ld d,h			;3f0a	54		T
	ld b,c			;3f0b	41		A
	ld d,d			;3f0c	52		R
	ld d,h			;3f0d	54		T
	jr nz,$+87		;3f0e	20 55		  U
	ld d,b			;3f10	50		P
	jr nz,$+67		;3f11	20 41		  A
	ld b,a			;3f13	47		G
	ld b,c			;3f14	41		A
	ld c,c			;3f15	49		I
	ld c,(hl)		;3f16	4e		N
	ld a,020h		;3f17	3e 20		>  
	ld hl,0f000h		;3f19	21 00 f0	! . .
	ld de,0f001h		;3f1c	11 01 f0	. . .
	ld bc,0004fh		;3f1f	01 4f 00	. O .
	ld (hl),a		;3f22	77		w
	ldir			;3f23	ed b0		. .
	ld hl,01939h		;3f25	21 39 19	! 9 .
	ld de,0f022h		;3f28	11 22 f0	. " .
	ld bc,0000dh		;3f2b	01 0d 00	. . .
	ldir			;3f2e	ed b0		. .
	ld a,(0f888h)		;3f30	3a 88 f8	: . .
	cp 000h			;3f33	fe 00		. .
	jr z,l3f50h		;3f35	28 19		( .
	call sub_3001h		;3f37	cd 01 30	. . 0
	ei			;3f3a	fb		.
	call 030a1h		;3f3b	cd a1 30	. . 0
	di			;3f3e	f3		.
	call 019b9h		;3f3f	cd b9 19	. . .
	ld hl,01939h		;3f42	21 39 19	! 9 .
	ld de,0f022h		;3f45	11 22 f0	. " .
	ld bc,0000dh		;3f48	01 0d 00	. . .
	ldir			;3f4b	ed b0		. .
	call sub_2a65h		;3f4d	cd 65 2a	. e *
l3f50h:
	ld a,(0f87ch)		;3f50	3a 7c f8	: | .
	cp 000h			;3f53	fe 00		. .
	jp z,02f69h		;3f55	ca 69 2f	. i /
	call sub_29c9h		;3f58	cd c9 29	. . )
l3f5bh:
	call sub_3001h		;3f5b	cd 01 30	. . 0
	ei			;3f5e	fb		.
	call 030a1h		;3f5f	cd a1 30	. . 0
	di			;3f62	f3		.
	call 019b9h		;3f63	cd b9 19	. . .
	call sub_2a65h		;3f66	cd 65 2a	. e *
	ld hl,(0f89ah)		;3f69	2a 9a f8	* . .
	ld (0f802h),hl		;3f6c	22 02 f8	" . .
	ld hl,(0f828h)		;3f6f	2a 28 f8	* ( .
	ld ix,0f05ah		;3f72	dd 21 5a f0	. ! Z .
	call 01134h		;3f76	cd 34 11	. 4 .
	ld a,(0f80ch)		;3f79	3a 0c f8	: . .
	ld (0f818h),a		;3f7c	32 18 f8	2 . .
l3f7fh:
	xor a			;3f7f	af		.
	ld (0f816h),a		;3f80	32 16 f8	2 . .
l3f83h:
	ld a,001h		;3f83	3e 01		> .
	ld (0f81ah),a		;3f85	32 1a f8	2 . .
l3f88h:
	call 0196ah		;3f88	cd 6a 19	. j .
	call sub_2939h		;3f8b	cd 39 29	. 9 )
	ld hl,(0f816h)		;3f8e	2a 16 f8	* . .
	ld ix,0f7b2h		;3f91	dd 21 b2 f7	. ! . .
	call 01134h		;3f95	cd 34 11	. 4 .
	ld hl,(0f818h)		;3f98	2a 18 f8	* . .
	ld ix,0f7bch		;3f9b	dd 21 bc f7	. ! . .
	call 01134h		;3f9f	cd 34 11	. 4 .
	ld hl,(0f81ah)		;3fa2	2a 1a f8	* . .
	ld ix,0f7c6h		;3fa5	dd 21 c6 f7	. ! . .
	call 01134h		;3fa9	cd 34 11	. 4 .
	ld a,005h		;3fac	3e 05		> .
	ld (0f80ah),a		;3fae	32 0a f8	2 . .
	call sub_1a8bh		;3fb1	cd 8b 1a	. . .
	ld b,0c8h		;3fb4	06 c8		. .
	call 01a9ah		;3fb6	cd 9a 1a	. . .
	ld a,(0f870h)		;3fb9	3a 70 f8	: p .
	cp 000h			;3fbc	fe 00		. .
	jr nz,l3f88h		;3fbe	20 c8		  .
	ld a,(0f81ah)		;3fc0	3a 1a f8	: . .
	ld b,a			;3fc3	47		G
	ld a,(0f812h)		;3fc4	3a 12 f8	: . .
	cp b			;3fc7	b8		.
	jr z,l3fd1h		;3fc8	28 07		( .
	ld a,b			;3fca	78		x
	inc a			;3fcb	3c		<
	ld (0f81ah),a		;3fcc	32 1a f8	2 . .
	jr l3f88h		;3fcf	18 b7		. .
l3fd1h:
	ld a,(0f814h)		;3fd1	3a 14 f8	: . .
	cp 000h			;3fd4	fe 00		. .
	jr z,l3fe6h		;3fd6	28 0e		( .
	ld a,(0f816h)		;3fd8	3a 16 f8	: . .
	cp 001h			;3fdb	fe 01		. .
	jr z,l3fe6h		;3fdd	28 07		( .
	ld a,001h		;3fdf	3e 01		> .
	ld (0f816h),a		;3fe1	32 16 f8	2 . .
	jr l3f83h		;3fe4	18 9d		. .
l3fe6h:
	ld a,(0f818h)		;3fe6	3a 18 f8	: . .
	ld b,a			;3fe9	47		G
	ld a,(0f80eh)		;3fea	3a 0e f8	: . .
	cp b			;3fed	b8		.
	jr z,l3ff7h		;3fee	28 07		( .
	ld a,b			;3ff0	78		x
	inc a			;3ff1	3c		<
	ld (0f818h),a		;3ff2	32 18 f8	2 . .
	jr l3f7fh		;3ff5	18 88		. .
l3ff7h:
	ld hl,(0f828h)		;3ff7	2a 28 f8	* ( .
	inc hl			;3ffa	23		#
	ld (0f828h),hl		;3ffb	22 28 f8	" ( .
l3ffeh:
	jp l3269h		;3ffe	c3 69 32	. i 2
	sbc a,b			;4001	98		.
	ret m			;4002	f8		.
	ld hl,01642h		;4003	21 42 16	! B .
	ld de,0f140h		;4006	11 40 f1	. @ .
	ld bc,0001dh		;4009	01 1d 00	. . .
	ldir			;400c	ed b0		. .
	ei			;400e	fb		.
	halt			;400f	76		v
	cp 03fh			;4010	fe 3f		. ?
	jr z,l3ffeh		;4012	28 ea		( .
l4014h:
	ld a,008h		;4014	3e 08		> .
	ld (0f898h),a		;4016	32 98 f8	2 . .
	ld hl,0168dh		;4019	21 8d 16	! . .
	ld de,0f190h		;401c	11 90 f1	. . .
	ld bc,0001ah		;401f	01 1a 00	. . .
	ldir			;4022	ed b0		. .
	ei			;4024	fb		.
	halt			;4025	76		v
	cp 03fh			;4026	fe 3f		. ?
	jr z,l4014h		;4028	28 ea		( .
l402ah:
	ld a,004h		;402a	3e 04		> .
	ld (0f898h),a		;402c	32 98 f8	2 . .
	ld hl,0165fh		;402f	21 5f 16	! _ .
	ld de,0f1e0h		;4032	11 e0 f1	. . .
	ld bc,0000ch		;4035	01 0c 00	. . .
	ldir			;4038	ed b0		. .
	ei			;403a	fb		.
	halt			;403b	76		v
	cp 03fh			;403c	fe 3f		. ?
	jr z,l402ah		;403e	28 ea		( .
l4040h:
	ld a,005h		;4040	3e 05		> .
	ld (0f898h),a		;4042	32 98 f8	2 . .
	ei			;4045	fb		.
	halt			;4046	76		v
	cp 03fh			;4047	fe 3f		. ?
	jr z,l4040h		;4049	28 f5		( .
l404bh:
	ld a,006h		;404b	3e 06		> .
	ld (0f898h),a		;404d	32 98 f8	2 . .
	ld hl,0166bh		;4050	21 6b 16	! k .
	ld de,0f230h		;4053	11 30 f2	. 0 .
	ld bc,0000ah		;4056	01 0a 00	. . .
	ldir			;4059	ed b0		. .
	ei			;405b	fb		.
	halt			;405c	76		v
	cp 03fh			;405d	fe 3f		. ?
	jr z,l404bh		;405f	28 ea		( .
l4061h:
	ld a,007h		;4061	3e 07		> .
	ld (0f898h),a		;4063	32 98 f8	2 . .
	ei			;4066	fb		.
	halt			;4067	76		v
	cp 03fh			;4068	fe 3f		. ?
	jr z,l4061h		;406a	28 f5		( .
l406ch:
	ld a,00dh		;406c	3e 0d		> .
	ld (0f898h),a		;406e	32 98 f8	2 . .
	ld hl,016a7h		;4071	21 a7 16	! . .
	ld de,0f280h		;4074	11 80 f2	. . .
	ld bc,00015h		;4077	01 15 00	. . .
	ldir			;407a	ed b0		. .
	ld hl,016bch		;407c	21 bc 16	! . .
	ld de,0f780h		;407f	11 80 f7	. . .
	ld bc,00035h		;4082	01 35 00	. 5 .
	ldir			;4085	ed b0		. .
	ei			;4087	fb		.
	halt			;4088	76		v
	cp 03fh			;4089	fe 3f		. ?
	jr z,l406ch		;408b	28 df		( .
l408dh:
	ld a,00eh		;408d	3e 0e		> .
	ld (0f898h),a		;408f	32 98 f8	2 . .
	ei			;4092	fb		.
	halt			;4093	76		v
	cp 03fh			;4094	fe 3f		. ?
	jr z,l408dh		;4096	28 f5		( .
l4098h:
	ld a,00ah		;4098	3e 0a		> .
	ld (0f898h),a		;409a	32 98 f8	2 . .
	ld hl,016f1h		;409d	21 f1 16	! . .
	ld de,0f2d0h		;40a0	11 d0 f2	. . .
	ld bc,0000fh		;40a3	01 0f 00	. . .
	ldir			;40a6	ed b0		. .
	ei			;40a8	fb		.
	halt			;40a9	76		v
	cp 03fh			;40aa	fe 3f		. ?
	jr z,l4098h		;40ac	28 ea		( .
l40aeh:
	ld a,00bh		;40ae	3e 0b		> .
	ld (0f898h),a		;40b0	32 98 f8	2 . .
	ld hl,01700h		;40b3	21 00 17	! . .
	ld de,0f320h		;40b6	11 20 f3	.   .
	ld bc,0002bh		;40b9	01 2b 00	. + .
	ldir			;40bc	ed b0		. .
	ei			;40be	fb		.
	halt			;40bf	76		v
	cp 03fh			;40c0	fe 3f		. ?
	jr z,l40aeh		;40c2	28 ea		( .
	ld a,(0f88ch)		;40c4	3a 8c f8	: . .
	cp 000h			;40c7	fe 00		. .
	jr z,l40e1h		;40c9	28 16		( .
l40cbh:
	ld a,00ch		;40cb	3e 0c		> .
	ld (0f898h),a		;40cd	32 98 f8	2 . .
	ld hl,0172bh		;40d0	21 2b 17	! + .
	ld de,0f370h		;40d3	11 70 f3	. p .
	ld bc,0001dh		;40d6	01 1d 00	. . .
	ldir			;40d9	ed b0		. .
	ei			;40db	fb		.
	halt			;40dc	76		v
	cp 03fh			;40dd	fe 3f		. ?
	jr z,l40cbh		;40df	28 ea		( .
l40e1h:
	ld a,009h		;40e1	3e 09		> .
	ld (0f898h),a		;40e3	32 98 f8	2 . .
	ld hl,01748h		;40e6	21 48 17	! H .
	ld a,(0f88ch)		;40e9	3a 8c f8	: . .
	cp 000h			;40ec	fe 00		. .
	jr nz,l40f5h		;40ee	20 05		  .
	ld de,0f370h		;40f0	11 70 f3	. p .
	jr l40f8h		;40f3	18 03		. .
l40f5h:
	ld de,0f3c0h		;40f5	11 c0 f3	. . .
l40f8h:
	ld bc,00015h		;40f8	01 15 00	. . .
	ldir			;40fb	ed b0		. .
	ei			;40fd	fb		.
	halt			;40fe	76		v
	cp 03fh			;40ff	fe 3f		. ?
	jr z,l40e1h		;4101	28 de		( .
	ld a,0d7h		;4103	3e d7		> .
	out (00fh),a		;4105	d3 0f		. .
	ld a,001h		;4107	3e 01		> .
	out (00fh),a		;4109	d3 0f		. .
	ld a,(0f806h)		;410b	3a 06 f8	: . .
	cp 002h			;410e	fe 02		. .
	jr z,l4162h		;4110	28 50		( P
	cp 001h			;4112	fe 01		. .
	jr z,l413ch		;4114	28 26		( &
	ld a,023h		;4116	3e 23		> #
	ld (0f810h),a		;4118	32 10 f8	2 . .
	ld a,(0f808h)		;411b	3a 08 f8	: . .
	cp 001h			;411e	fe 01		. .
	jr z,l412fh		;4120	28 0d		( .
	ld a,010h		;4122	3e 10		> .
	ld (0f812h),a		;4124	32 12 f8	2 . .
	ld hl,00040h		;4127	21 40 00	! @ .
	ld (0f87ah),hl		;412a	22 7a f8	" z .
	jr l4186h		;412d	18 57		. W
l412fh:
	ld a,00ah		;412f	3e 0a		> .
	ld (0f812h),a		;4131	32 12 f8	2 . .
	ld hl,00028h		;4134	21 28 00	! ( .
	ld (0f87ah),hl		;4137	22 7a f8	" z .
	jr l4186h		;413a	18 4a		. J
l413ch:
	ld a,04ch		;413c	3e 4c		> L
	ld (0f810h),a		;413e	32 10 f8	2 . .
	ld a,(0f808h)		;4141	3a 08 f8	: . .
	cp 001h			;4144	fe 01		. .
	jr z,l4155h		;4146	28 0d		( .
l4148h:
	ld a,01ah		;4148	3e 1a		> .
	ld (0f812h),a		;414a	32 12 f8	2 . .
	ld hl,00068h		;414d	21 68 00	! h .
l4150h:
	ld (0f87ah),hl		;4150	22 7a f8	" z .
	jr l4186h		;4153	18 31		. 1
l4155h:
	ld a,00fh		;4155	3e 0f		> .
	ld (0f812h),a		;4157	32 12 f8	2 . .
	ld hl,0003ch		;415a	21 3c 00	! < .
	ld (0f87ah),hl		;415d	22 7a f8	" z .
	jr l4186h		;4160	18 24		. $
l4162h:
	ld a,04fh		;4162	3e 4f		> O
	ld (0f810h),a		;4164	32 10 f8	2 . .
	ld a,(0f808h)		;4167	3a 08 f8	: . .
	cp 001h			;416a	fe 01		. .
	jr z,l417bh		;416c	28 0d		( .
	ld a,010h		;416e	3e 10		> .
	ld (0f812h),a		;4170	32 12 f8	2 . .
	ld hl,00040h		;4173	21 40 00	! @ .
l4176h:
	ld (0f87ah),hl		;4176	22 7a f8	" z .
	jr l4186h		;4179	18 0b		. .
l417bh:
	ld a,00ah		;417b	3e 0a		> .
	ld (0f812h),a		;417d	32 12 f8	2 . .
	ld hl,00028h		;4180	21 28 00	! ( .
	ld (0f87ah),hl		;4183	22 7a f8	" z .
l4186h:
	ld a,(0f80ch)		;4186	3a 0c f8	: . .
	ld b,a			;4189	47		G
	ld a,(0f80eh)		;418a	3a 0e f8	: . .
	cp b			;418d	b8		.
	jr nc,l4197h		;418e	30 07		0 .
	ld (0f80ch),a		;4190	32 0c f8	2 . .
	ld a,b			;4193	78		x
	ld (0f80eh),a		;4194	32 0e f8	2 . .
l4197h:
	ld a,(0f80eh)		;4197	3a 0e f8	: . .
	ld b,a			;419a	47		G
	ld a,(0f810h)		;419b	3a 10 f8	: . .
	cp b			;419e	b8		.
	jp nc,l29a2h		;419f	d2 a2 29	. . )
	ld (0f80eh),a		;41a2	32 0e f8	2 . .
	ld a,(0f80ch)		;41a5	3a 0c f8	: . .
	ld b,a			;41a8	47		G
	ld a,(0f810h)		;41a9	3a 10 f8	: . .
	cp b			;41ac	b8		.
	jp nc,l29a2h		;41ad	d2 a2 29	. . )
	ld (0f80ch),a		;41b0	32 0c f8	2 . .
	jp l29a2h		;41b3	c3 a2 29	. . )
	ld a,001h		;41b6	3e 01		> .
	ld (0f81ah),a		;41b8	32 1a f8	2 . .
	ld hl,0e000h		;41bb	21 00 e0	! . .
l41beh:
	ld a,(0f818h)		;41be	3a 18 f8	: . .
	ld (hl),a		;41c1	77		w
	inc hl			;41c2	23		#
	ld a,(0f816h)		;41c3	3a 16 f8	: . .
	ld (hl),a		;41c6	77		w
	inc hl			;41c7	23		#
l41c8h:
	ld a,(0f81ah)		;41c8	3a 1a f8	: . .
	ld (hl),a		;41cb	77		w
	inc hl			;41cc	23		#
	ld a,(0f81eh)		;41cd	3a 1e f8	: . .
	ld (hl),a		;41d0	77		w
	inc hl			;41d1	23		#
	ld a,(0f812h)		;41d2	3a 12 f8	: . .
	ld b,a			;41d5	47		G
	inc b			;41d6	04		.
	ld a,(0f81ah)		;41d7	3a 1a f8	: . .
	inc a			;41da	3c		<
	ld (0f81ah),a		;41db	32 1a f8	2 . .
	cp b			;41de	b8		.
	jr nz,l41beh		;41df	20 dd		  .
	di			;41e1	f3		.
	ld a,003h		;41e2	3e 03		> .
	ld (0f80ah),a		;41e4	32 0a f8	2 . .
	ld a,(0f820h)		;41e7	3a 20 f8	:   .
	inc a			;41ea	3c		<
	ld (0f820h),a		;41eb	32 20 f8	2   .
	call sub_1946h		;41ee	cd 46 19	. F .
	ld a,(0f808h)		;41f1	3a 08 f8	: . .
	cp 000h			;41f4	fe 00		. .
	jr nz,$+12		;41f6	20 0a		  .
	ld a,00dh		;41f8	3e 0d		> .
	call 00c66h		;41fa	cd 66 0c	. f .
	jp nz,l2ec7h		;41fd	c2 c7 2e	. . .
	cpl			;4200	2f		/
	ld hl,(0f89ah)		;4201	2a 9a f8	* . .
	ld (0f802h),hl		;4204	22 02 f8	" . .
	xor a			;4207	af		.
	ld (0f886h),a		;4208	32 86 f8	2 . .
	ld (0f816h),a		;420b	32 16 f8	2 . .
	ld a,001h		;420e	3e 01		> .
	ld (0f818h),a		;4210	32 18 f8	2 . .
l4213h:
	ld a,001h		;4213	3e 01		> .
	ld (0f81ah),a		;4215	32 1a f8	2 . .
l4218h:
	call sub_2939h		;4218	cd 39 29	. 9 )
l421bh:
	call 0196ah		;421b	cd 6a 19	. j .
	ld a,005h		;421e	3e 05		> .
	ld (0f80ah),a		;4220	32 0a f8	2 . .
	ld hl,(0f816h)		;4223	2a 16 f8	* . .
	ld ix,0f7b2h		;4226	dd 21 b2 f7	. ! . .
	call 01134h		;422a	cd 34 11	. 4 .
	ld hl,(0f818h)		;422d	2a 18 f8	* . .
	ld ix,0f7bch		;4230	dd 21 bc f7	. ! . .
	call 01134h		;4234	cd 34 11	. 4 .
	ld hl,(0f81ah)		;4237	2a 1a f8	* . .
	ld ix,0f7c6h		;423a	dd 21 c6 f7	. ! . .
	call 01134h		;423e	cd 34 11	. 4 .
	call sub_1a8bh		;4241	cd 8b 1a	. . .
	ld b,0c8h		;4244	06 c8		. .
	call 01a9ah		;4246	cd 9a 1a	. . .
	ld a,(0f870h)		;4249	3a 70 f8	: p .
	cp 000h			;424c	fe 00		. .
	jr nz,l421bh		;424e	20 cb		  .
	ld a,(0f886h)		;4250	3a 86 f8	: . .
l4253h:
	cp 000h			;4253	fe 00		. .
	jr z,l426bh		;4255	28 14		( .
	ld hl,0175dh		;4257	21 5d 17	! ] .
	ld de,0f5f0h		;425a	11 f0 f5	. . .
	ld bc,00027h		;425d	01 27 00	. ' .
	ldir			;4260	ed b0		. .
	ei			;4262	fb		.
	call 030a1h		;4263	cd a1 30	. . 0
	di			;4266	f3		.
	xor a			;4267	af		.
	ld (0f886h),a		;4268	32 86 f8	2 . .
l426bh:
	ld a,(0f81ah)		;426b	3a 1a f8	: . .
	ld b,a			;426e	47		G
	ld a,(0f812h)		;426f	3a 12 f8	: . .
	cp b			;4272	b8		.
	jr z,l427ch		;4273	28 07		( .
	ld a,b			;4275	78		x
	inc a			;4276	3c		<
	ld (0f81ah),a		;4277	32 1a f8	2 . .
	jr l421bh		;427a	18 9f		. .
l427ch:
	ld a,(0f818h)		;427c	3a 18 f8	: . .
	ld b,a			;427f	47		G
	ld a,(0f810h)		;4280	3a 10 f8	: . .
	cp b			;4283	b8		.
	jr z,l428dh		;4284	28 07		( .
	ld a,b			;4286	78		x
	inc a			;4287	3c		<
	ld (0f818h),a		;4288	32 18 f8	2 . .
	jr l4213h		;428b	18 86		. .
l428dh:
	ld a,(0f814h)		;428d	3a 14 f8	: . .
	cp 000h			;4290	fe 00		. .
	ret z			;4292	c8		.
	ld a,(0f816h)		;4293	3a 16 f8	: . .
	cp 001h			;4296	fe 01		. .
	ret z			;4298	c8		.
	ld a,001h		;4299	3e 01		> .
	ld (0f816h),a		;429b	32 16 f8	2 . .
	jp 0300eh		;429e	c3 0e 30	. . 0
	halt			;42a1	76		v
	ld a,020h		;42a2	3e 20		>  
	ld hl,0f5f0h		;42a4	21 f0 f5	! . .
	ld de,0f5f1h		;42a7	11 f1 f5	. . .
	ld bc,00050h		;42aa	01 50 00	. P .
	ld (hl),a		;42ad	77		w
	ldir			;42ae	ed b0		. .
	ret			;42b0	c9		.
	ld d,b			;42b1	50		P
	ld c,c			;42b2	49		I
	ld c,a			;42b3	4f		O
	ld e,a			;42b4	5f		_
	ld d,h			;42b5	54		T
	ld b,l			;42b6	45		E
	ld d,e			;42b7	53		S
	ld d,h			;42b8	54		T
	ld a,(l2f20h)		;42b9	3a 20 2f	:   /
	jr nz,l4323h		;42bc	20 65		  e
	ld a,b			;42be	78		x
	ld (hl),b		;42bf	70		p
	jr nz,l42fch		;42c0	20 3a		  :
	cpl			;42c2	2f		/
	jr nz,l4337h		;42c3	20 72		  r
	ld h,l			;42c5	65		e
	ld h,e			;42c6	63		c
	jr nz,l4303h		;42c7	20 3a		  :
	cpl			;42c9	2f		/
	jr nz,l433ch		;42ca	20 70		  p
	ld l,c			;42cc	69		i
	ld l,a			;42cd	6f		o
	ld e,a			;42ce	5f		_
	ld (hl),h		;42cf	74		t
	ld h,l			;42d0	65		e
	ld (hl),e		;42d1	73		s
	ld (hl),h		;42d2	74		t
	jr nz,$+99		;42d3	20 61		  a
	ld h,d			;42d5	62		b
	ld l,a			;42d6	6f		o
	ld (hl),d		;42d7	72		r
	ld (hl),h		;42d8	74		t
	ld h,l			;42d9	65		e
	ld h,h			;42da	64		d
	jr nz,l430ch		;42db	20 2f		  /
	ld l,(hl)		;42dd	6e		n
	ld l,a			;42de	6f		o
	jr nz,$+107		;42df	20 69		  i
	ld l,(hl)		;42e1	6e		n
	ld (hl),h		;42e2	74		t
	ld h,l			;42e3	65		e
	ld (hl),d		;42e4	72		r
	ld (hl),d		;42e5	72		r
	ld (hl),l		;42e6	75		u
	ld (hl),b		;42e7	70		p
	ld (hl),h		;42e8	74		t
	jr nz,l4351h		;42e9	20 66		  f
	ld (hl),d		;42eb	72		r
	ld l,a			;42ec	6f		o
	ld l,l			;42ed	6d		m
	jr nz,$+114		;42ee	20 70		  p
	ld l,a			;42f0	6f		o
	ld (hl),d		;42f1	72		r
	ld (hl),h		;42f2	74		t
	jr nz,$+67		;42f3	20 41		  A
	jr nz,l4326h		;42f5	20 2f		  /
	ld h,e			;42f7	63		c
	ld l,b			;42f8	68		h
	ld h,c			;42f9	61		a
	ld l,(hl)		;42fa	6e		n
	ld l,(hl)		;42fb	6e		n
l42fch:
	ld h,l			;42fc	65		e
	ld l,h			;42fd	6c		l
	jr nz,$+68		;42fe	20 42		  B
	jr nz,l436bh		;4300	20 69		  i
	ld l,(hl)		;4302	6e		n
l4303h:
	ld (hl),h		;4303	74		t
	ld h,l			;4304	65		e
	ld (hl),d		;4305	72		r
	ld (hl),d		;4306	72		r
	ld (hl),l		;4307	75		u
	ld (hl),b		;4308	70		p
	ld (hl),h		;4309	74		t
	jr nz,l433bh		;430a	20 2f		  /
l430ch:
	ld c,a			;430c	4f		O
	ld c,e			;430d	4b		K
	jr nz,l433fh		;430e	20 2f		  /
	ld a,(0f802h)		;4310	3a 02 f8	: . .
	cp 0ffh			;4313	fe ff		. .
	jr nz,l4319h		;4315	20 02		  .
l4317h:
	reti			;4317	ed 4d		. M
l4319h:
	ld a,001h		;4319	3e 01		> .
	ld (0f802h),a		;431b	32 02 f8	2 . .
	in a,(010h)		;431e	db 10		. .
	cp (hl)			;4320	be		.
	jr z,l4317h		;4321	28 f4		( .
l4323h:
	ld b,(hl)		;4323	46		F
	push bc			;4324	c5		.
	push af			;4325	f5		.
l4326h:
	ld hl,l30c3h		;4326	21 c3 30	! . 0
	ld ix,(0fffch)		;4329	dd 2a fc ff	. * . .
	call 01161h		;432d	cd 61 11	. a .
	pop af			;4330	f1		.
	call 01180h		;4331	cd 80 11	. . .
	ld hl,l30bch		;4334	21 bc 30	! . 0
l4337h:
	call 01161h		;4337	cd 61 11	. a .
	pop bc			;433a	c1		.
l433bh:
	ld a,b			;433b	78		x
l433ch:
	call 01180h		;433c	cd 80 11	. . .
l433fh:
	ld a,062h		;433f	3e 62		> b
	ld (0fffeh),a		;4341	32 fe ff	2 . .
	reti			;4344	ed 4d		. M
	ld a,001h		;4346	3e 01		> .
	ld (0f804h),a		;4348	32 04 f8	2 . .
	reti			;434b	ed 4d		. M
	ld ix,0f230h		;434d	dd 21 30 f2	. ! 0 .
l4351h:
	ld hl,030b1h		;4351	21 b1 30	! . 0
	call 01161h		;4354	cd 61 11	. a .
	xor a			;4357	af		.
	ld (0f81ch),a		;4358	32 1c f8	2 . .
	ld hl,0025ch		;435b	21 5c 02	! \ .
	ld a,l			;435e	7d		}
	out (012h),a		;435f	d3 12		. .
	ld hl,0025eh		;4361	21 5e 02	! ^ .
	ld a,l			;4364	7d		}
	out (013h),a		;4365	d3 13		. .
	ld a,04fh		;4367	3e 4f		> O
	out (012h),a		;4369	d3 12		. .
l436bh:
	ld a,00fh		;436b	3e 0f		> .
	out (013h),a		;436d	d3 13		. .
	ld a,087h		;436f	3e 87		> .
	out (012h),a		;4371	d3 12		. .
	out (013h),a		;4373	d3 13		. .
	xor a			;4375	af		.
	ld (0fffeh),a		;4376	32 fe ff	2 . .
	ld a,0ffh		;4379	3e ff		> .
	ld (0f802h),a		;437b	32 02 f8	2 . .
	ld (0f804h),a		;437e	32 04 f8	2 . .
	ld a,0e5h		;4381	3e e5		> .
	out (011h),a		;4383	d3 11		. .
	ei			;4385	fb		.
	inc ix			;4386	dd 23		. #
	dec ix			;4388	dd 2b		. +
	di			;438a	f3		.
	in a,(010h)		;438b	db 10		. .
	cp 0e5h			;438d	fe e5		. .
	jr z,l43b8h		;438f	28 27		( '
	push af			;4391	f5		.
	ld hl,l30c3h		;4392	21 c3 30	! . 0
	ld ix,(0fffch)		;4395	dd 2a fc ff	. * . .
	call 01161h		;4399	cd 61 11	. a .
	pop af			;439c	f1		.
	call 01180h		;439d	cd 80 11	. . .
	ld hl,l30bch		;43a0	21 bc 30	! . 0
	call 01161h		;43a3	cd 61 11	. a .
	ld a,0e5h		;43a6	3e e5		> .
	call 01180h		;43a8	cd 80 11	. . .
	ld hl,l30cah		;43ab	21 ca 30	! . 0
	ld ix,(0fffch)		;43ae	dd 2a fc ff	. * . .
	call 01161h		;43b2	cd 61 11	. a .
	jp l3230h		;43b5	c3 30 32	. 0 2
l43b8h:
	ld hl,000ffh		;43b8	21 ff 00	! . .
	ld (0f802h),hl		;43bb	22 02 f8	" . .
	call 019e3h		;43be	cd e3 19	. . .
	xor a			;43c1	af		.
	ld (0f802h),a		;43c2	32 02 f8	2 . .
	ld (0f804h),a		;43c5	32 04 f8	2 . .
	ld b,0ffh		;43c8	06 ff		. .
	ld hl,0e000h		;43ca	21 00 e0	! . .
	ld a,(hl)		;43cd	7e		~
	out (011h),a		;43ce	d3 11		. .
	ei			;43d0	fb		.
	inc ix			;43d1	dd 23		. #
	dec ix			;43d3	dd 2b		. +
	di			;43d5	f3		.
	ld a,(0f802h)		;43d6	3a 02 f8	: . .
	cp 001h			;43d9	fe 01		. .
	jr z,l43eeh		;43db	28 11		( .
	ld hl,030ddh		;43dd	21 dd 30	! . 0
	ld ix,(0fffch)		;43e0	dd 2a fc ff	. * . .
	call 01161h		;43e4	cd 61 11	. a .
	ld a,060h		;43e7	3e 60		> `
	ld (0fffeh),a		;43e9	32 fe ff	2 . .
	jr l441ah		;43ec	18 2c		. ,
l43eeh:
	ld a,(0f804h)		;43ee	3a 04 f8	: . .
	cp 000h			;43f1	fe 00		. .
	jr z,$+19		;43f3	28 11		( .
	ld hl,l30f7h		;43f5	21 f7 30	! . 0
	ld ix,(0fffch)		;43f8	dd 2a fc ff	. * . .
	call 01161h		;43fc	cd 61 11	. a .
	ld a,018h		;43ff	3e 18		> .
	ex af,af'		;4401	08		.
	ld a,04dh		;4402	3e 4d		> M
	call 00c66h		;4404	cd 66 0c	. f .
	jp nz,l2ec7h		;4407	c2 c7 2e	. . .
	ld a,(0f804h)		;440a	3a 04 f8	: . .
	ld b,a			;440d	47		G
	ld a,(0f816h)		;440e	3a 16 f8	: . .
	rlca			;4411	07		.
	rlca			;4412	07		.
	or b			;4413	b0		.
	call 00c66h		;4414	cd 66 0c	. f .
	jp nz,l2ec7h		;4417	c2 c7 2e	. . .
l441ah:
	ld a,(0f81eh)		;441a	3a 1e f8	: . .
	call 00c66h		;441d	cd 66 0c	. f .
	jp nz,l2ec7h		;4420	c2 c7 2e	. . .
	ld a,(0f812h)		;4423	3a 12 f8	: . .
	call 00c66h		;4426	cd 66 0c	. f .
	jp nz,l2ec7h		;4429	c2 c7 2e	. . .
	ld a,(0f808h)		;442c	3a 08 f8	: . .
	cp 000h			;442f	fe 00		. .
	jr nz,l444eh		;4431	20 1b		  .
	ld a,(0f806h)		;4433	3a 06 f8	: . .
	cp 001h			;4436	fe 01		. .
	jr z,l4444h		;4438	28 0a		( .
	ld a,009h		;443a	3e 09		> .
	call 00c66h		;443c	cd 66 0c	. f .
	jp nz,l2ec7h		;443f	c2 c7 2e	. . .
	jr l4467h		;4442	18 23		. #
l4444h:
	ld a,01bh		;4444	3e 1b		> .
	call 00c66h		;4446	cd 66 0c	. f .
	jp nz,l2ec7h		;4449	c2 c7 2e	. . .
	jr l4467h		;444c	18 19		. .
l444eh:
	ld a,(0f806h)		;444e	3a 06 f8	: . .
	cp 001h			;4451	fe 01		. .
	jr z,l445fh		;4453	28 0a		( .
	ld a,00ch		;4455	3e 0c		> .
	call 00c66h		;4457	cd 66 0c	. f .
	jp nz,l2ec7h		;445a	c2 c7 2e	. . .
	jr l4467h		;445d	18 08		. .
l445fh:
	ld a,054h		;445f	3e 54		> T
	call 00c66h		;4461	cd 66 0c	. f .
	jp nz,l2ec7h		;4464	c2 c7 2e	. . .
l4467h:
	ld a,0e5h		;4467	3e e5		> .
	call 00c66h		;4469	cd 66 0c	. f .
	jp nz,l2ec7h		;446c	c2 c7 2e	. . .
	ld b,0c8h		;446f	06 c8		. .
	call 01a9ah		;4471	cd 9a 1a	. . .
	call 00c4fh		;4474	cd 4f 0c	. O .
	jp nz,l2ec7h		;4477	c2 c7 2e	. . .
	ld c,a			;447a	4f		O
	ld b,006h		;447b	06 06		. .
l447dh:
	call 00c4fh		;447d	cd 4f 0c	. O .
	jp nz,l2ec7h		;4480	c2 c7 2e	. . .
	dec b			;4483	05		.
	jr nz,l447dh		;4484	20 f7		  .
	bit 7,c			;4486	cb 79		. y
	jr nz,l4493h		;4488	20 09		  .
	bit 6,c			;448a	cb 71		. q
	jr nz,l4493h		;448c	20 05		  .
	xor a			;448e	af		.
	ld (0f820h),a		;448f	32 20 f8	2   .
	ret			;4492	c9		.
l4493h:
	ld a,(0f88ah)		;4493	3a 8a f8	: . .
	inc a			;4496	3c		<
	ld b,a			;4497	47		G
	ld a,(0f820h)		;4498	3a 20 f8	:   .
	cp b			;449b	b8		.
	jp nz,l27e1h		;449c	c2 e1 27	. . '
	call 019b9h		;449f	cd b9 19	. . .
	ld hl,018e4h		;44a2	21 e4 18	! . .
	ld de,0f370h		;44a5	11 70 f3	. p .
	ld bc,0000eh		;44a8	01 0e 00	. . .
	ldir			;44ab	ed b0		. .
	ld hl,0190dh		;44ad	21 0d 19	! . .
	ld de,0f5f0h		;44b0	11 f0 f5	. . .
	ld bc,00020h		;44b3	01 20 00	.   .
	ldir			;44b6	ed b0		. .
	ei			;44b8	fb		.
	halt			;44b9	76		v
	call 019b9h		;44ba	cd b9 19	. . .
	xor a			;44bd	af		.
	ld (0f820h),a		;44be	32 20 f8	2   .
	jp l27e1h		;44c1	c3 e1 27	. . '
l44c4h:
	ld a,001h		;44c4	3e 01		> .
	ld (0f80ah),a		;44c6	32 0a f8	2 . .
	ld a,(0f820h)		;44c9	3a 20 f8	:   .
	inc a			;44cc	3c		<
	ld (0f820h),a		;44cd	32 20 f8	2   .
	di			;44d0	f3		.
	ld a,007h		;44d1	3e 07		> .
	call 00c66h		;44d3	cd 66 0c	. f .
	jp nz,l2ec7h		;44d6	c2 c7 2e	. . .
	ld a,(0f804h)		;44d9	3a 04 f8	: . .
	call 00c66h		;44dc	cd 66 0c	. f .
	jp nz,l2ec7h		;44df	c2 c7 2e	. . .
	ld b,0c8h		;44e2	06 c8		. .
	call 01a9ah		;44e4	cd 9a 1a	. . .
	ld a,008h		;44e7	3e 08		> .
	call 00c66h		;44e9	cd 66 0c	. f .
	jp nz,l2ec7h		;44ec	c2 c7 2e	. . .
	call 00c4fh		;44ef	cd 4f 0c	. O .
	jp nz,l2ec7h		;44f2	c2 c7 2e	. . .
	ld c,a			;44f5	4f		O
	call 00c4fh		;44f6	cd 4f 0c	. O .
	jp nz,l2ec7h		;44f9	c2 c7 2e	. . .
	bit 7,c			;44fc	cb 79		. y
	jr nz,l4509h		;44fe	20 09		  .
	bit 6,c			;4500	cb 71		. q
	jr nz,l4509h		;4502	20 05		  .
	xor a			;4504	af		.
	ld (0f820h),a		;4505	32 20 f8	2   .
	ret			;4508	c9		.
l4509h:
	ld a,(0f88ah)		;4509	3a 8a f8	: . .
	inc a			;450c	3c		<
	ld b,a			;450d	47		G
	ld a,(0f820h)		;450e	3a 20 f8	:   .
	cp b			;4511	b8		.
	jr nz,l44c4h		;4512	20 b0		  .
	call 019b9h		;4514	cd b9 19	. . .
	ld hl,l18f2h		;4517	21 f2 18	! . .
	ld de,0f370h		;451a	11 70 f3	. p .
	ld bc,0001bh		;451d	01 1b 00	. . .
	ldir			;4520	ed b0		. .
	ld hl,0190dh		;4522	21 0d 19	! . .
	ld de,0f5f0h		;4525	11 f0 f5	. . .
	ld bc,00020h		;4528	01 20 00	.   .
	ldir			;452b	ed b0		. .
	ei			;452d	fb		.
	halt			;452e	76		v
	call 019b9h		;452f	cd b9 19	. . .
	xor a			;4532	af		.
	ld (0f820h),a		;4533	32 20 f8	2   .
	jp l28c4h		;4536	c3 c4 28	. . (
	di			;4539	f3		.
	ld a,002h		;453a	3e 02		> .
	ld (0f80ah),a		;453c	32 0a f8	2 . .
	ld a,00fh		;453f	3e 0f		> .
	call 00c66h		;4541	cd 66 0c	. f .
	jp nz,l2ec7h		;4544	c2 c7 2e	. . .
	ld a,(0f804h)		;4547	3a 04 f8	: . .
	ld b,a			;454a	47		G
	ld a,(0f816h)		;454b	3a 16 f8	: . .
	rlca			;454e	07		.
	rlca			;454f	07		.
	or b			;4550	b0		.
	call 00c66h		;4551	cd 66 0c	. f .
	jp nz,l2ec7h		;4554	c2 c7 2e	. . .
	ld a,(0f818h)		;4557	3a 18 f8	: . .
	call 00c66h		;455a	cd 66 0c	. f .
	jp nz,l2ec7h		;455d	c2 c7 2e	. . .
	ld b,0c8h		;4560	06 c8		. .
	call 01a9ah		;4562	cd 9a 1a	. . .
	ld a,008h		;4565	3e 08		> .
	call 00c66h		;4567	cd 66 0c	. f .
	jp nz,l2ec7h		;456a	c2 c7 2e	. . .
	call 00c4fh		;456d	cd 4f 0c	. O .
	jp nz,l2ec7h		;4570	c2 c7 2e	. . .
	ld c,a			;4573	4f		O
	call 00c4fh		;4574	cd 4f 0c	. O .
	bit 7,c			;4577	cb 79		. y
	jr nz,l4584h		;4579	20 09		  .
	bit 6,c			;457b	cb 71		. q
	jr nz,l4584h		;457d	20 05		  .
	xor a			;457f	af		.
	ld (0f822h),a		;4580	32 22 f8	2 " .
	ret			;4583	c9		.
l4584h:
	ld a,(0f88ah)		;4584	3a 8a f8	: . .
	ld b,a			;4587	47		G
	ld a,(0f822h)		;4588	3a 22 f8	: " .
	cp b			;458b	b8		.
	jr z,l4598h		;458c	28 0a		( .
	inc a			;458e	3c		<
	ld (0f822h),a		;458f	32 22 f8	2 " .
	call l28c4h		;4592	cd c4 28	. . (
	jp sub_2939h		;4595	c3 39 29	. 9 )
l4598h:
	ld a,001h		;4598	3e 01		> .
	ld (0f824h),a		;459a	32 24 f8	2 $ .
	xor a			;459d	af		.
	ld (0f822h),a		;459e	32 22 f8	2 " .
	ret			;45a1	c9		.
	ld a,00fh		;45a2	3e 0f		> .
	ld (0f898h),a		;45a4	32 98 f8	2 . .
	call 01ac5h		;45a7	cd c5 1a	. . .
	call 01b1ch		;45aa	cd 1c 1b	. . .
	call l28c4h		;45ad	cd c4 28	. . (
	call 019b9h		;45b0	cd b9 19	. . .
	call sub_2a65h		;45b3	cd 65 2a	. e *
	ld a,(0f88ch)		;45b6	3a 8c f8	: . .
	cp 000h			;45b9	fe 00		. .
l45bbh:
	jp nz,l2d06h		;45bb	c2 06 2d	. . -
	ld a,(0f87ch)		;45be	3a 7c f8	: | .
	cp 000h			;45c1	fe 00		. .
	call nz,sub_29c9h	;45c3	c4 c9 29	. . )
	jp l2d06h		;45c6	c3 06 2d	. . -
	ld hl,(0f87ah)		;45c9	2a 7a f8	* z .
	ld (0f802h),hl		;45cc	22 02 f8	" . .
	call sub_1946h		;45cf	cd 46 19	. F .
	xor a			;45d2	af		.
	ld (0f818h),a		;45d3	32 18 f8	2 . .
	ld a,(0f814h)		;45d6	3a 14 f8	: . .
	cp 000h			;45d9	fe 00		. .
	jr z,$+73		;45db	28 47		( G
	call sub_27b6h		;45dd	cd b6 27	. . '
l45e0h:
	ld a,(0f816h)		;45e0	3a 16 f8	: . .
	cp 000h			;45e3	fe 00		. .
	jr nz,l45ffh		;45e5	20 18		  .
	ld a,001h		;45e7	3e 01		> .
	ld (0f816h),a		;45e9	32 16 f8	2 . .
	call sub_2939h		;45ec	cd 39 29	. 9 )
	ld a,(0f824h)		;45ef	3a 24 f8	: $ .
	cp 000h			;45f2	fe 00		. .
	jr nz,l4648h		;45f4	20 52		  R
	xor a			;45f6	af		.
	ld (0f820h),a		;45f7	32 20 f8	2   .
	call sub_27b6h		;45fa	cd b6 27	. . '
	jr l45e0h		;45fd	18 e1		. .
l45ffh:
	xor a			;45ff	af		.
	ld h,c			;4600	61		a
	ld (0fffeh),a		;4601	32 fe ff	2 . .
	jr l461ah		;4604	18 14		. .
	ld a,(0fffeh)		;4606	3a fe ff	: . .
	cp 000h			;4609	fe 00		. .
	jr nz,l461ah		;460b	20 0d		  .
	inc hl			;460d	23		#
	djnz $-65		;460e	10 bd		. .
	ld hl,0310ch		;4610	21 0c 31	! . 1
	ld ix,(0fffch)		;4613	dd 2a fc ff	. * . .
	call 01161h		;4617	cd 61 11	. a .
l461ah:
	ld ix,0f230h		;461a	dd 21 30 f2	. ! 0 .
	ld iy,030b1h		;461e	fd 21 b1 30	. ! . 0
	ld hl,0f280h		;4622	21 80 f2	! . .
	call 0119ch		;4625	cd 9c 11	. . .
	ld a,(0ffffh)		;4628	3a ff ff	: . .
	bit 6,a			;462b	cb 77		. w
	jp nz,l3175h		;462d	c2 75 31	. u 1
	ld a,007h		;4630	3e 07		> .
	out (012h),a		;4632	d3 12		. .
	out (013h),a		;4634	d3 13		. .
	ld hl,00250h		;4636	21 50 02	! P .
	ld a,l			;4639	7d		}
	out (012h),a		;463a	d3 12		. .
	ld a,087h		;463c	3e 87		> .
	out (012h),a		;463e	d3 12		. .
	ld a,(0fffeh)		;4640	3a fe ff	: . .
	jp 0049eh		;4643	c3 9e 04	. . .
	ld h,h			;4646	64		d
	ld l,l			;4647	6d		m
l4648h:
	ld h,c			;4648	61		a
	jr nz,l46aeh		;4649	20 63		  c
	ld l,b			;464b	68		h
	ld h,c			;464c	61		a
	ld l,(hl)		;464d	6e		n
	ld l,(hl)		;464e	6e		n
	ld h,l			;464f	65		e
	ld l,h			;4650	6c		l
	jr nz,l4685h		;4651	20 32		  2
	jr nz,l46c8h		;4653	20 73		  s
	ld (hl),h		;4655	74		t
	ld h,c			;4656	61		a
	ld (hl),d		;4657	72		r
	ld (hl),h		;4658	74		t
	ld h,h			;4659	64		d
	ld l,l			;465a	6d		m
	ld h,c			;465b	61		a
	jr nz,l46c1h		;465c	20 63		  c
	ld l,b			;465e	68		h
	ld h,c			;465f	61		a
	ld l,(hl)		;4660	6e		n
	ld l,(hl)		;4661	6e		n
	ld h,l			;4662	65		e
	ld l,h			;4663	6c		l
	jr nz,l4699h		;4664	20 33		  3
	jr nz,l46dbh		;4666	20 73		  s
	ld (hl),h		;4668	74		t
	ld h,c			;4669	61		a
	ld (hl),d		;466a	72		r
	ld (hl),h		;466b	74		t
	ld a,000h		;466c	3e 00		> .
	out (001h),a		;466e	d3 01		. .
	ld a,04fh		;4670	3e 4f		> O
	out (000h),a		;4672	d3 00		. .
	ld a,098h		;4674	3e 98		> .
	out (000h),a		;4676	d3 00		. .
	ld a,09ah		;4678	3e 9a		> .
	out (000h),a		;467a	d3 00		. .
	ld a,b			;467c	78		x
	rlca			;467d	07		.
	rlca			;467e	07		.
	rlca			;467f	07		.
	rlca			;4680	07		.
	or 04dh			;4681	f6 4d		. M
	out (000h),a		;4683	d3 00		. .
l4685h:
	ld a,006h		;4685	3e 06		> .
	out (0fah),a		;4687	d3 fa		. .
	ld a,020h		;4689	3e 20		>  
	out (001h),a		;468b	d3 01		. .
	in a,(001h)		;468d	db 01		. .
l468fh:
	in a,(001h)		;468f	db 01		. .
	bit 5,a			;4691	cb 6f		. o
	jr z,l468fh		;4693	28 fa		( .
	ld a,002h		;4695	3e 02		> .
	out (0fah),a		;4697	d3 fa		. .
l4699h:
	ret			;4699	c9		.
	ld hl,0f000h		;469a	21 00 f0	! . .
	ld de,0f001h		;469d	11 01 f0	. . .
	ld bc,007d0h		;46a0	01 d0 07	. . .
	ld a,020h		;46a3	3e 20		>  
	ld (hl),a		;46a5	77		w
	ldir			;46a6	ed b0		. .
	ret			;46a8	c9		.
	ld b,008h		;46a9	06 08		. .
	ld hl,0f000h		;46ab	21 00 f0	! . .
l46aeh:
	ld a,000h		;46ae	3e 00		> .
l46b0h:
	ld (hl),a		;46b0	77		w
	push af			;46b1	f5		.
	ld a,020h		;46b2	3e 20		>  
	inc hl			;46b4	23		#
	ld (hl),a		;46b5	77		w
	pop af			;46b6	f1		.
	inc hl			;46b7	23		#
	inc a			;46b8	3c		<
	cp 080h			;46b9	fe 80		. .
	jr nz,l46b0h		;46bb	20 f3		  .
	djnz l46aeh		;46bd	10 ef		. .
	ret			;46bf	c9		.
	push hl			;46c0	e5		.
l46c1h:
	push ix			;46c1	dd e5		. .
l46c3h:
	ld hl,l30d4h		;46c3	21 d4 30	! . 0
l46c6h:
	dec hl			;46c6	2b		+
	ld a,l			;46c7	7d		}
l46c8h:
	or h			;46c8	b4		.
	jr nz,l46c6h		;46c9	20 fb		  .
	djnz l46c3h		;46cb	10 f6		. .
	pop ix			;46cd	dd e1		. .
	pop hl			;46cf	e1		.
	ret			;46d0	c9		.
	ld b,019h		;46d1	06 19		. .
	ld de,00050h		;46d3	11 50 00	. P .
	ld hl,0f028h		;46d6	21 28 f0	! ( .
l46d9h:
	ld (hl),a		;46d9	77		w
	add hl,de		;46da	19		.
l46dbh:
	djnz l46d9h		;46db	10 fc		. .
	ret			;46dd	c9		.
	ld a,006h		;46de	3e 06		> .
	out (0ffh),a		;46e0	d3 ff		. .
	out (0fch),a		;46e2	d3 fc		. .
	ld hl,0f000h		;46e4	21 00 f0	! . .
	ld a,l			;46e7	7d		}
	out (0f4h),a		;46e8	d3 f4		. .
	ld a,h			;46ea	7c		|
	out (0f4h),a		;46eb	d3 f4		. .
	ld hl,003bfh		;46ed	21 bf 03	! . .
	ld a,l			;46f0	7d		}
	out (0f5h),a		;46f1	d3 f5		. .
	ld a,h			;46f3	7c		|
	out (0f5h),a		;46f4	d3 f5		. .
	ld hl,0f3c0h		;46f6	21 c0 f3	! . .
	ld a,l			;46f9	7d		}
	out (0f6h),a		;46fa	d3 f6		. .
	ld a,h			;46fc	7c		|
	out (0f6h),a		;46fd	d3 f6		. .
	ld hl,0040fh		;46ff	21 0f 04	! . .
	ld a,l			;4702	7d		}
	out (0f7h),a		;4703	d3 f7		. .
	ld a,h			;4705	7c		|
	out (0f7h),a		;4706	d3 f7		. .
	ld a,000h		;4708	3e 00		> .
	out (0ffh),a		;470a	d3 ff		. .
	ret			;470c	c9		.
	ld a,02ah		;470d	3e 2a		> *
	ld hl,0f3bfh		;470f	21 bf f3	! . .
	ld (hl),a		;4712	77		w
	ld hl,0f7ceh		;4713	21 ce f7	! . .
	ld (hl),a		;4716	77		w
	inc hl			;4717	23		#
	ld (hl),a		;4718	77		w
	ld hl,l3246h		;4719	21 46 32	! F 2
	ld de,0f000h		;471c	11 00 f0	. . .
	ld bc,00013h		;471f	01 13 00	. . .
	ldir			;4722	ed b0		. .
	ld hl,l3259h		;4724	21 59 32	! Y 2
	ld de,0f3c0h		;4727	11 c0 f3	. . .
	ld bc,00013h		;472a	01 13 00	. . .
	ldir			;472d	ed b0		. .
	ret			;472f	c9		.
	ld a,080h		;4730	3e 80		> .
	out (001h),a		;4732	d3 01		. .
	ld a,c			;4734	79		y
	out (000h),a		;4735	d3 00		. .
	ld a,d			;4737	7a		z
	out (000h),a		;4738	d3 00		. .
	ld b,002h		;473a	06 02		. .
	call sub_32c0h		;473c	cd c0 32	. . 2
	ret			;473f	c9		.
	push af			;4740	f5		.
	in a,(001h)		;4741	db 01		. .
	call sub_32deh		;4743	cd de 32	. . 2
	pop af			;4746	f1		.
	ei			;4747	fb		.
	reti			;4748	ed 4d		. M
	push af			;474a	f5		.
l474bh:
	in a,(010h)		;474b	db 10		. .
	ei			;474d	fb		.
	cp 046h			;474e	fe 46		. F
	di			;4750	f3		.
	jr nz,l475eh		;4751	20 0b		  .
	call sub_329ah		;4753	cd 9a 32	. . 2
	ld sp,(0ffffh)		;4756	ed 7b ff ff	. { . .
	xor a			;475a	af		.
	jp 00155h		;475b	c3 55 01	. U .
l475eh:
	cp 048h			;475e	fe 48		. H
	jr z,l474bh		;4760	28 e9		( .
	pop af			;4762	f1		.
	ei			;4763	fb		.
	reti			;4764	ed 4d		. M
	call 00264h		;4766	cd 64 02	. d .
	ei			;4769	fb		.
	ld hl,00260h		;476a	21 60 02	! ` .
	ld a,l			;476d	7d		}
	out (012h),a		;476e	d3 12		. .
	ld a,04fh		;4770	3e 4f		> O
	out (012h),a		;4772	d3 12		. .
	ld a,087h		;4774	3e 87		> .
	out (012h),a		;4776	d3 12		. .
	in a,(010h)		;4778	db 10		. .
	call sub_32a9h		;477a	cd a9 32	. . 2
	ld b,014h		;477d	06 14		. .
	call sub_32c0h		;477f	cd c0 32	. . 2
	ld a,0f0h		;4782	3e f0		> .
	call sub_32d1h		;4784	cd d1 32	. . 2
	ld b,014h		;4787	06 14		. .
	call sub_32c0h		;4789	cd c0 32	. . 2
	call sub_32a9h		;478c	cd a9 32	. . 2
	ld b,014h		;478f	06 14		. .
	call sub_32c0h		;4791	cd c0 32	. . 2
	ld a,0f2h		;4794	3e f2		> .
	ld hl,0f370h		;4796	21 70 f3	! p .
	ld (hl),a		;4799	77		w
	ld b,014h		;479a	06 14		. .
	call sub_32c0h		;479c	cd c0 32	. . 2
	call sub_32a9h		;479f	cd a9 32	. . 2
	ld b,014h		;47a2	06 14		. .
	call sub_32c0h		;47a4	cd c0 32	. . 2
	ld hl,0f000h		;47a7	21 00 f0	! . .
	ld de,0f001h		;47aa	11 01 f0	. . .
	ld bc,007d0h		;47ad	01 d0 07	. . .
	ld a,048h		;47b0	3e 48		> H
	ld (hl),a		;47b2	77		w
	ldir			;47b3	ed b0		. .
l47b5h:
	ld b,014h		;47b5	06 14		. .
	call sub_32c0h		;47b7	cd c0 32	. . 2
	call sub_32a9h		;47ba	cd a9 32	. . 2
	ld b,000h		;47bd	06 00		. .
	call sub_326ch		;47bf	cd 6c 32	. l 2
	ld c,000h		;47c2	0e 00		. .
	ld d,000h		;47c4	16 00		. .
	ld l,004h		;47c6	2e 04		. .
	ld h,006h		;47c8	26 06		& .
l47cah:
	call 03330h		;47ca	cd 30 33	. 0 3
	inc c			;47cd	0c		.
	ld a,c			;47ce	79		y
	cp l			;47cf	bd		.
	jr nz,l47cah		;47d0	20 f8		  .
	ld a,l			;47d2	7d		}
	add a,003h		;47d3	c6 03		. .
	ld l,a			;47d5	6f		o
	inc d			;47d6	14		.
	ld a,d			;47d7	7a		z
	cp h			;47d8	bc		.
	jr nz,l47cah		;47d9	20 ef		  .
	ld a,h			;47db	7c		|
	cp 006h			;47dc	fe 06		. .
	jr nz,l47ebh		;47de	20 0b		  .
l47e0h:
	ld b,001h		;47e0	06 01		. .
	call sub_326ch		;47e2	cd 6c 32	. l 2
	ld l,016h		;47e5	2e 16		. .
	ld h,00ch		;47e7	26 0c		& .
	jr l47cah		;47e9	18 df		. .
l47ebh:
	cp 00ch			;47eb	fe 0c		. .
	jr nz,l47fah		;47ed	20 0b		  .
	ld b,002h		;47ef	06 02		. .
	call sub_326ch		;47f1	cd 6c 32	. l 2
	ld l,028h		;47f4	2e 28		. (
	ld h,012h		;47f6	26 12		& .
	jr l47cah		;47f8	18 d0		. .
l47fah:
	cp 012h			;47fa	fe 12		. .
	jr nz,$+13		;47fc	20 0b		  .
	ld b,003h		;47fe	06 03		. .
	ld (0f816h),a		;4800	32 16 f8	2 . .
	ld a,(0f818h)		;4803	3a 18 f8	: . .
	inc a			;4806	3c		<
	ld b,a			;4807	47		G
	ld (0f818h),a		;4808	32 18 f8	2 . .
	ld a,(0f810h)		;480b	3a 10 f8	: . .
	inc a			;480e	3c		<
	cp b			;480f	b8		.
	ret z			;4810	c8		.
	call sub_2939h		;4811	cd 39 29	. 9 )
	ld a,(0f824h)		;4814	3a 24 f8	: $ .
l4817h:
	cp 000h			;4817	fe 00		. .
	jr nz,l4848h		;4819	20 2d		  -
	xor a			;481b	af		.
	ld (0f820h),a		;481c	32 20 f8	2   .
	call sub_27b6h		;481f	cd b6 27	. . '
	jr l47e0h		;4822	18 bc		. .
	call sub_27b6h		;4824	cd b6 27	. . '
l4827h:
	ld a,(0f818h)		;4827	3a 18 f8	: . .
	inc a			;482a	3c		<
l482bh:
	ld b,a			;482b	47		G
	ld (0f818h),a		;482c	32 18 f8	2 . .
	ld a,(0f810h)		;482f	3a 10 f8	: . .
	inc a			;4832	3c		<
	cp b			;4833	b8		.
	ret z			;4834	c8		.
	call sub_2939h		;4835	cd 39 29	. 9 )
	ld a,(0f824h)		;4838	3a 24 f8	: $ .
	cp 000h			;483b	fe 00		. .
	jr nz,l4848h		;483d	20 09		  .
	xor a			;483f	af		.
	ld (0f820h),a		;4840	32 20 f8	2   .
	call sub_27b6h		;4843	cd b6 27	. . '
	jr l4827h		;4846	18 df		. .
l4848h:
	call 019b9h		;4848	cd b9 19	. . .
	ld hl,018e4h		;484b	21 e4 18	! . .
	ld de,0f370h		;484e	11 70 f3	. p .
	ld bc,0000eh		;4851	01 0e 00	. . .
	ldir			;4854	ed b0		. .
	ld hl,0192dh		;4856	21 2d 19	! - .
	ld de,0f380h		;4859	11 80 f3	. . .
	ld bc,0000bh		;485c	01 0b 00	. . .
	ldir			;485f	ed b0		. .
	ei			;4861	fb		.
l4862h:
	halt			;4862	76		v
	jr l4862h		;4863	18 fd		. .
	ld a,(0f88ch)		;4865	3a 8c f8	: . .
	cp 000h			;4868	fe 00		. .
	jr nz,l4879h		;486a	20 0d		  .
	ld hl,01621h		;486c	21 21 16	! ! .
	ld de,0f01fh		;486f	11 1f f0	. . .
	ld bc,00014h		;4872	01 14 00	. . .
	ldir			;4875	ed b0		. .
	jr l4884h		;4877	18 0b		. .
l4879h:
	ld hl,01939h		;4879	21 39 19	! 9 .
	ld de,0f022h		;487c	11 22 f0	. " .
	ld bc,0000dh		;487f	01 0d 00	. . .
	ldir			;4882	ed b0		. .
l4884h:
	ld hl,01784h		;4884	21 84 17	! . .
	ld de,0f0a0h		;4887	11 a0 f0	. . .
	ld bc,00009h		;488a	01 09 00	. . .
	ldir			;488d	ed b0		. .
	ld hl,(0f88ah)		;488f	2a 8a f8	* . .
	ld h,000h		;4892	26 00		& .
	ld ix,0f0aah		;4894	dd 21 aa f0	. ! . .
	call 01134h		;4898	cd 34 11	. 4 .
	ld hl,0178dh		;489b	21 8d 17	! . .
	ld de,0f050h		;489e	11 50 f0	. P .
	ld bc,00006h		;48a1	01 06 00	. . .
	ldir			;48a4	ed b0		. .
	ld hl,l18c1h		;48a6	21 c1 18	! . .
	ld de,0f0bfh		;48a9	11 bf f0	. . .
	ld bc,00004h		;48ac	01 04 00	. . .
	ldir			;48af	ed b0		. .
	ld hl,l18c5h		;48b1	21 c5 18	! . .
	ld de,0f0c9h		;48b4	11 c9 f0	. . .
	ld bc,00004h		;48b7	01 04 00	. . .
	ldir			;48ba	ed b0		. .
	ld hl,l18c9h		;48bc	21 c9 18	! . .
	ld de,0f0d3h		;48bf	11 d3 f0	. . .
	ld bc,00004h		;48c2	01 04 00	. . .
	ldir			;48c5	ed b0		. .
	ld hl,018cdh		;48c7	21 cd 18	! . .
	ld de,0f0dbh		;48ca	11 db f0	. . .
	ld bc,00008h		;48cd	01 08 00	. . .
	ldir			;48d0	ed b0		. .
	ld hl,018d5h		;48d2	21 d5 18	! . .
	ld de,0f0e5h		;48d5	11 e5 f0	. . .
	ld bc,00006h		;48d8	01 06 00	. . .
	ldir			;48db	ed b0		. .
	ld hl,01793h		;48dd	21 93 17	! . .
	ld de,0f0f0h		;48e0	11 f0 f0	. . .
	ld bc,00016h		;48e3	01 16 00	. . .
	ldir			;48e6	ed b0		. .
	ld hl,017a9h		;48e8	21 a9 17	! . .
	ld de,0f140h		;48eb	11 40 f1	. @ .
	ld bc,00016h		;48ee	01 16 00	. . .
	ldir			;48f1	ed b0		. .
	ld hl,017bfh		;48f3	21 bf 17	! . .
	ld de,0f190h		;48f6	11 90 f1	. . .
	ld bc,00018h		;48f9	01 18 00	. . .
	ldir			;48fc	ed b0		. .
	ld hl,017d7h		;48fe	21 d7 17	! . .
	ld de,0f1e0h		;4901	11 e0 f1	. . .
	ld bc,00018h		;4904	01 18 00	. . .
	ldir			;4907	ed b0		. .
	ld hl,017efh		;4909	21 ef 17	! . .
	ld de,0f230h		;490c	11 30 f2	. 0 .
	ld bc,00013h		;490f	01 13 00	. . .
l4912h:
	ldir			;4912	ed b0		. .
	ld hl,01802h		;4914	21 02 18	! . .
l4917h:
	ld de,0f280h		;4917	11 80 f2	. . .
	ld bc,00013h		;491a	01 13 00	. . .
	ldir			;491d	ed b0		. .
	ld hl,l1815h		;491f	21 15 18	! . .
	ld de,0f2d0h		;4922	11 d0 f2	. . .
	ld bc,00013h		;4925	01 13 00	. . .
	ldir			;4928	ed b0		. .
	ld hl,01828h		;492a	21 28 18	! ( .
	ld de,0f320h		;492d	11 20 f3	.   .
	ld bc,00013h		;4930	01 13 00	. . .
	ldir			;4933	ed b0		. .
	ld hl,l183bh		;4935	21 3b 18	! ; .
	ld de,0f370h		;4938	11 70 f3	. p .
	ld bc,00015h		;493b	01 15 00	. . .
	ldir			;493e	ed b0		. .
	ld hl,01850h		;4940	21 50 18	! P .
	ld de,0f3c0h		;4943	11 c0 f3	. . .
	ld bc,00015h		;4946	01 15 00	. . .
	ldir			;4949	ed b0		. .
	ld hl,01878h		;494b	21 78 18	! x .
	ld de,0f410h		;494e	11 10 f4	. . .
	ld bc,0000eh		;4951	01 0e 00	. . .
	ldir			;4954	ed b0		. .
	ld hl,l1886h		;4956	21 86 18	! . .
	ld de,0f460h		;4959	11 60 f4	. ` .
	ld bc,0000eh		;495c	01 0e 00	. . .
	ldir			;495f	ed b0		. .
	ld hl,0189fh		;4961	21 9f 18	! . .
	ld de,0f4b0h		;4964	11 b0 f4	. . .
	ld bc,00009h		;4967	01 09 00	. . .
	ldir			;496a	ed b0		. .
	ld hl,l1865h		;496c	21 65 18	! e .
	ld de,0f500h		;496f	11 00 f5	. . .
	ld bc,00013h		;4972	01 13 00	. . .
	ldir			;4975	ed b0		. .
	ld hl,l1894h		;4977	21 94 18	! . .
	ld de,0f550h		;497a	11 50 f5	. P .
	ld bc,0000bh		;497d	01 0b 00	. . .
	ldir			;4980	ed b0		. .
	ld hl,l18b4h		;4982	21 b4 18	! . .
	ld de,0f690h		;4985	11 90 f6	. . .
	ld bc,0000dh		;4988	01 0d 00	. . .
	ldir			;498b	ed b0		. .
	ld hl,l18a8h		;498d	21 a8 18	! . .
	ld de,0f6e0h		;4990	11 e0 f6	. . .
	ld bc,0000ch		;4993	01 0c 00	. . .
	ldir			;4996	ed b0		. .
	ld hl,018dbh		;4998	21 db 18	! . .
	ld de,0f780h		;499b	11 80 f7	. . .
	ld bc,00009h		;499e	01 09 00	. . .
	ldir			;49a1	ed b0		. .
	ld hl,00000h		;49a3	21 00 00	! . .
	ld (0f828h),hl		;49a6	22 28 f8	" ( .
	ld (0f82ah),hl		;49a9	22 2a f8	" * .
	ld (0f82ch),hl		;49ac	22 2c f8	" , .
	ld (0f82eh),hl		;49af	22 2e f8	" . .
	ld (0f830h),hl		;49b2	22 30 f8	" 0 .
	ld (0f832h),hl		;49b5	22 32 f8	" 2 .
	ld (0f834h),hl		;49b8	22 34 f8	" 4 .
	ld (0f836h),hl		;49bb	22 36 f8	" 6 .
	ld (0f838h),hl		;49be	22 38 f8	" 8 .
	ld (0f83ah),hl		;49c1	22 3a f8	" : .
	ld (0f83ch),hl		;49c4	22 3c f8	" < .
	ld (0f83eh),hl		;49c7	22 3e f8	" > .
l49cah:
	ld (0f840h),hl		;49ca	22 40 f8	" @ .
	ld (0f842h),hl		;49cd	22 42 f8	" B .
	ld (0f844h),hl		;49d0	22 44 f8	" D .
	ld (0f846h),hl		;49d3	22 46 f8	" F .
	ld (0f848h),hl		;49d6	22 48 f8	" H .
	ld (0f84ah),hl		;49d9	22 4a f8	" J .
	ld (0f84ch),hl		;49dc	22 4c f8	" L .
	ld (0f84eh),hl		;49df	22 4e f8	" N .
	ld (0f850h),hl		;49e2	22 50 f8	" P .
	ld (0f852h),hl		;49e5	22 52 f8	" R .
	ld (0f854h),hl		;49e8	22 54 f8	" T .
	ld (0f856h),hl		;49eb	22 56 f8	" V .
	ld (0f858h),hl		;49ee	22 58 f8	" X .
	ld (0f85ah),hl		;49f1	22 5a f8	" Z .
	ld (0f85ch),hl		;49f4	22 5c f8	" \ .
	ld (0f85eh),hl		;49f7	22 5e f8	" ^ .
	ld (0f860h),hl		;49fa	22 60 f8	" ` .
	ld (0f862h),hl		;49fd	22 62 f8	" b .
	call sub_326ch		;4a00	cd 6c 32	. l 2
	ld l,03fh		;4a03	2e 3f		. ?
	ld h,019h		;4a05	26 19		& .
	jr l49cah		;4a07	18 c1		. .
	ld a,082h		;4a09	3e 82		> .
	ld hl,0f000h		;4a0b	21 00 f0	! . .
	ld (hl),a		;4a0e	77		w
	ld a,090h		;4a0f	3e 90		> .
	ld hl,0f0f0h		;4a11	21 f0 f0	! . .
	ld (hl),a		;4a14	77		w
	ld a,092h		;4a15	3e 92		> .
	ld hl,0f1e0h		;4a17	21 e0 f1	! . .
	ld (hl),a		;4a1a	77		w
	ld a,0a0h		;4a1b	3e a0		> .
	ld hl,0f2d0h		;4a1d	21 d0 f2	! . .
	ld (hl),a		;4a20	77		w
	ld a,0a2h		;4a21	3e a2		> .
	ld hl,0f410h		;4a23	21 10 f4	! . .
	ld (hl),a		;4a26	77		w
	ld a,0b0h		;4a27	3e b0		> .
	ld hl,0f500h		;4a29	21 00 f5	! . .
	ld (hl),a		;4a2c	77		w
	ld a,0b2h		;4a2d	3e b2		> .
	ld hl,0f5f0h		;4a2f	21 f0 f5	! . .
	ld (hl),a		;4a32	77		w
	ld b,032h		;4a33	06 32		. 2
	call sub_32c0h		;4a35	cd c0 32	. . 2
	ld a,040h		;4a38	3e 40		> @
	out (001h),a		;4a3a	d3 01		. .
	ld a,0c0h		;4a3c	3e c0		> .
	out (001h),a		;4a3e	d3 01		. .
	ld a,04ah		;4a40	3e 4a		> J
	out (0fbh),a		;4a42	d3 fb		. .
	ld a,04bh		;4a44	3e 4b		> K
	out (0fbh),a		;4a46	d3 fb		. .
	ld a,003h		;4a48	3e 03		> .
	out (00ch),a		;4a4a	d3 0c		. .
	out (00dh),a		;4a4c	d3 0d		. .
	out (00eh),a		;4a4e	d3 0e		. .
	out (00fh),a		;4a50	d3 0f		. .
	ld a,0d7h		;4a52	3e d7		> .
	out (00eh),a		;4a54	d3 0e		. .
	ld a,001h		;4a56	3e 01		> .
	out (00eh),a		;4a58	d3 0e		. .
	ld hl,00248h		;4a5a	21 48 02	! H .
	ld a,l			;4a5d	7d		}
	out (00ch),a		;4a5e	d3 0c		. .
	in a,(001h)		;4a60	db 01		. .
	call sub_329ah		;4a62	cd 9a 32	. . 2
	call sub_330dh		;4a65	cd 0d 33	. . 3
	call sub_32deh		;4a68	cd de 32	. . 2
	ld a,020h		;4a6b	3e 20		>  
	out (001h),a		;4a6d	d3 01		. .
	ld a,000h		;4a6f	3e 00		> .
	out (0ffh),a		;4a71	d3 ff		. .
	ld b,064h		;4a73	06 64		. d
	call sub_32c0h		;4a75	cd c0 32	. . 2
	ld a,003h		;4a78	3e 03		> .
	out (00dh),a		;4a7a	d3 0d		. .
	out (00ch),a		;4a7c	d3 0c		. .
	out (00eh),a		;4a7e	d3 0e		. .
	out (00fh),a		;4a80	d3 0f		. .
	ld a,006h		;4a82	3e 06		> .
	out (0ffh),a		;4a84	d3 ff		. .
	ld a,05ah		;4a86	3e 5a		> Z
	out (0fbh),a		;4a88	d3 fb		. .
	out (0fch),a		;4a8a	d3 fc		. .
	ld hl,0f000h		;4a8c	21 00 f0	! . .
	ld a,l			;4a8f	7d		}
	out (0f4h),a		;4a90	d3 f4		. .
	ld a,h			;4a92	7c		|
	out (0f4h),a		;4a93	d3 f4		. .
	ld hl,007cfh		;4a95	21 cf 07	! . .
	ld a,l			;4a98	7d		}
	out (0f5h),a		;4a99	d3 f5		. .
	ld a,h			;4a9b	7c		|
	out (0f5h),a		;4a9c	d3 f5		. .
	ld a,080h		;4a9e	3e 80		> .
	out (001h),a		;4aa0	d3 01		. .
	ld a,051h		;4aa2	3e 51		> Q
	out (000h),a		;4aa4	d3 00		. .
	ld a,01ah		;4aa6	3e 1a		> .
	out (000h),a		;4aa8	d3 00		. .
	call sub_329ah		;4aaa	cd 9a 32	. . 2
	ld a,000h		;4aad	3e 00		> .
	out (001h),a		;4aaf	d3 01		. .
	ld a,04fh		;4ab1	3e 4f		> O
	out (000h),a		;4ab3	d3 00		. .
	ld a,098h		;4ab5	3e 98		> .
	out (000h),a		;4ab7	d3 00		. .
	ld a,06ah		;4ab9	3e 6a		> j
	ld b,000h		;4abb	06 00		. .
	call sub_327ah		;4abd	cd 7a 32	. z 2
	ld hl,0f000h		;4ac0	21 00 f0	! . .
	ld a,084h		;4ac3	3e 84		> .
	ld (hl),a		;4ac5	77		w
	ld b,00fh		;4ac6	06 0f		. .
	ld hl,0f001h		;4ac8	21 01 f0	! . .
	call sub_32aeh		;4acb	cd ae 32	. . 2
	ld b,032h		;4ace	06 32		. 2
	call sub_32c0h		;4ad0	cd c0 32	. . 2
	ld b,000h		;4ad3	06 00		. .
	call sub_326ch		;4ad5	cd 6c 32	. l 2
	jp l3366h		;4ad8	c3 66 33	. f 3
	ld d,a			;4adb	57		W
	ld b,h			;4adc	44		D
	ld b,e			;4add	43		C
	ld e,a			;4ade	5f		_
	ld (hl),h		;4adf	74		t
	ld h,l			;4ae0	65		e
	ld (hl),e		;4ae1	73		s
	ld (hl),h		;4ae2	74		t
	jr nz,l4b1fh		;4ae3	20 3a		  :
	jr nz,l4b16h		;4ae5	20 2f		  /
	ld (hl),d		;4ae7	72		r
	ld h,l			;4ae8	65		e
	ld (hl),e		;4ae9	73		s
	ld (hl),h		;4aea	74		t
	ld l,a			;4aeb	6f		o
	ld (hl),d		;4aec	72		r
	ld h,l			;4aed	65		e
	jr nz,l4b55h		;4aee	20 65		  e
	ld (hl),d		;4af0	72		r
	ld (hl),d		;4af1	72		r
	ld l,a			;4af2	6f		o
	ld (hl),d		;4af3	72		r
	jr nz,l4b25h		;4af4	20 2f		  /
	ld d,a			;4af6	57		W
	ld b,h			;4af7	44		D
	ld b,e			;4af8	43		C
	ld e,a			;4af9	5f		_
	ld (hl),h		;4afa	74		t
	ld h,l			;4afb	65		e
	ld (hl),e		;4afc	73		s
	ld (hl),h		;4afd	74		t
	jr nz,l4b61h		;4afe	20 61		  a
	ld h,d			;4b00	62		b
	ld l,a			;4b01	6f		o
	ld (hl),d		;4b02	72		r
	ld (hl),h		;4b03	74		t
	ld h,l			;4b04	65		e
	ld h,h			;4b05	64		d
	cpl			;4b06	2f		/
	ld (hl),h		;4b07	74		t
	ld (hl),d		;4b08	72		r
	ld h,c			;4b09	61		a
	ld h,e			;4b0a	63		c
	ld l,e			;4b0b	6b		k
	jr nz,l4b3eh		;4b0c	20 30		  0
	jr nz,l4b75h		;4b0e	20 65		  e
	ld (hl),d		;4b10	72		r
	ld (hl),d		;4b11	72		r
	ld l,a			;4b12	6f		o
	ld (hl),d		;4b13	72		r
	jr nz,$+49		;4b14	20 2f		  /
l4b16h:
	ld h,c			;4b16	61		a
	ld h,d			;4b17	62		b
	ld l,a			;4b18	6f		o
	ld (hl),d		;4b19	72		r
	ld (hl),h		;4b1a	74		t
	ld h,l			;4b1b	65		e
	ld h,h			;4b1c	64		d
	jr nz,l4b96h		;4b1d	20 77		  w
l4b1fh:
	ld (hl),d		;4b1f	72		r
	ld l,c			;4b20	69		i
	ld (hl),h		;4b21	74		t
	ld h,l			;4b22	65		e
	jr nz,l4b88h		;4b23	20 63		  c
l4b25h:
	ld l,a			;4b25	6f		o
	ld l,l			;4b26	6d		m
	ld l,l			;4b27	6d		m
	ld h,c			;4b28	61		a
	ld l,(hl)		;4b29	6e		n
	ld h,h			;4b2a	64		d
	jr nz,l4b5ch		;4b2b	20 2f		  /
	ld l,c			;4b2d	69		i
	ld h,h			;4b2e	64		d
	jr nz,$+112		;4b2f	20 6e		  n
	ld l,a			;4b31	6f		o
	ld (hl),h		;4b32	74		t
	jr nz,l4b9bh		;4b33	20 66		  f
	ld l,a			;4b35	6f		o
	ld (hl),l		;4b36	75		u
	ld l,(hl)		;4b37	6e		n
	ld h,h			;4b38	64		d
	jr nz,l4b6ah		;4b39	20 2f		  /
	ld h,e			;4b3b	63		c
	ld (hl),d		;4b3c	72		r
	ld h,e			;4b3d	63		c
l4b3eh:
	jr nz,l4ba5h		;4b3e	20 65		  e
	ld (hl),d		;4b40	72		r
	ld (hl),d		;4b41	72		r
	ld l,a			;4b42	6f		o
	ld (hl),d		;4b43	72		r
	jr nz,$+107		;4b44	20 69		  i
	ld l,(hl)		;4b46	6e		n
	jr nz,l4bb2h		;4b47	20 69		  i
	ld h,h			;4b49	64		d
	jr nz,l4bb2h		;4b4a	20 66		  f
	ld l,c			;4b4c	69		i
	ld h,l			;4b4d	65		e
	ld l,h			;4b4e	6c		l
	ld h,h			;4b4f	64		d
	jr nz,l4b81h		;4b50	20 2f		  /
	ld (hl),a		;4b52	77		w
	ld (hl),d		;4b53	72		r
	ld l,c			;4b54	69		i
l4b55h:
	ld (hl),h		;4b55	74		t
	ld h,l			;4b56	65		e
	jr nz,l4bbeh		;4b57	20 65		  e
	ld (hl),d		;4b59	72		r
	ld (hl),d		;4b5a	72		r
	ld l,a			;4b5b	6f		o
l4b5ch:
	ld (hl),d		;4b5c	72		r
	jr nz,l4b8eh		;4b5d	20 2f		  /
	ld h,e			;4b5f	63		c
	ld (hl),d		;4b60	72		r
l4b61h:
	ld h,e			;4b61	63		c
	jr nz,l4bc9h		;4b62	20 65		  e
	ld (hl),d		;4b64	72		r
	ld (hl),d		;4b65	72		r
	ld l,a			;4b66	6f		o
	ld (hl),d		;4b67	72		r
	jr nz,$+49		;4b68	20 2f		  /
l4b6ah:
	ld h,h			;4b6a	64		d
	ld h,c			;4b6b	61		a
	ld (hl),h		;4b6c	74		t
	ld h,c			;4b6d	61		a
	jr nz,l4bddh		;4b6e	20 6d		  m
	ld h,c			;4b70	61		a
	ld (hl),d		;4b71	72		r
	ld l,e			;4b72	6b		k
	jr nz,l4be3h		;4b73	20 6e		  n
l4b75h:
	ld l,a			;4b75	6f		o
	ld (hl),h		;4b76	74		t
	jr nz,l4bdfh		;4b77	20 66		  f
	ld l,a			;4b79	6f		o
	ld (hl),l		;4b7a	75		u
	ld l,(hl)		;4b7b	6e		n
	ld h,h			;4b7c	64		d
	jr nz,l4baeh		;4b7d	20 2f		  /
	ld h,c			;4b7f	61		a
	ld h,d			;4b80	62		b
l4b81h:
	ld l,a			;4b81	6f		o
	ld (hl),d		;4b82	72		r
	ld (hl),h		;4b83	74		t
	ld h,l			;4b84	65		e
	ld h,h			;4b85	64		d
	jr nz,l4bfah		;4b86	20 72		  r
l4b88h:
	ld h,l			;4b88	65		e
	ld h,c			;4b89	61		a
	ld h,h			;4b8a	64		d
	jr nz,l4bf0h		;4b8b	20 63		  c
	ld l,a			;4b8d	6f		o
l4b8eh:
	ld l,l			;4b8e	6d		m
	ld l,l			;4b8f	6d		m
	ld h,c			;4b90	61		a
	ld l,(hl)		;4b91	6e		n
	ld h,h			;4b92	64		d
	jr nz,l4bc4h		;4b93	20 2f		  /
	ld h,e			;4b95	63		c
l4b96h:
	ld (hl),d		;4b96	72		r
	ld h,e			;4b97	63		c
	jr nz,l4bffh		;4b98	20 65		  e
	ld (hl),d		;4b9a	72		r
l4b9bh:
	ld (hl),d		;4b9b	72		r
	ld l,a			;4b9c	6f		o
	ld (hl),d		;4b9d	72		r
	jr nz,$+102		;4b9e	20 64		  d
	ld h,c			;4ba0	61		a
	ld (hl),h		;4ba1	74		t
	ld h,c			;4ba2	61		a
	jr nz,$+104		;4ba3	20 66		  f
l4ba5h:
	ld l,c			;4ba5	69		i
	ld h,l			;4ba6	65		e
	ld l,h			;4ba7	6c		l
	ld h,h			;4ba8	64		d
	jr nz,l4bdah		;4ba9	20 2f		  /
	ld h,d			;4bab	62		b
	ld h,c			;4bac	61		a
	ld h,h			;4bad	64		d
l4baeh:
	jr nz,l4c12h		;4bae	20 62		  b
	ld l,h			;4bb0	6c		l
	ld l,a			;4bb1	6f		o
l4bb2h:
	ld h,e			;4bb2	63		c
	ld l,e			;4bb3	6b		k
	jr nz,$+102		;4bb4	20 64		  d
	ld h,l			;4bb6	65		e
	ld (hl),h		;4bb7	74		t
	ld h,l			;4bb8	65		e
	ld h,e			;4bb9	63		c
	ld (hl),h		;4bba	74		t
	jr nz,$+103		;4bbb	20 65		  e
	ld (hl),d		;4bbd	72		r
l4bbeh:
	ld (hl),d		;4bbe	72		r
	ld l,a			;4bbf	6f		o
	ld (hl),d		;4bc0	72		r
	jr nz,l4bf2h		;4bc1	20 2f		  /
	ld h,(hl)		;4bc3	66		f
l4bc4h:
	ld l,a			;4bc4	6f		o
	ld (hl),d		;4bc5	72		r
	ld l,l			;4bc6	6d		m
	ld h,c			;4bc7	61		a
	ld (hl),h		;4bc8	74		t
l4bc9h:
	jr nz,l4c30h		;4bc9	20 65		  e
	ld (hl),d		;4bcb	72		r
	ld (hl),d		;4bcc	72		r
	ld l,a			;4bcd	6f		o
	ld (hl),d		;4bce	72		r
	jr nz,l4c00h		;4bcf	20 2f		  /
	ld (hl),h		;4bd1	74		t
	ld l,c			;4bd2	69		i
	ld l,l			;4bd3	6d		m
	ld h,l			;4bd4	65		e
	ld l,a			;4bd5	6f		o
	ld (hl),l		;4bd6	75		u
	ld (hl),h		;4bd7	74		t
	jr nz,l4c09h		;4bd8	20 2f		  /
l4bdah:
	ld l,c			;4bda	69		i
	ld l,h			;4bdb	6c		l
	ld l,h			;4bdc	6c		l
l4bddh:
	ld h,l			;4bdd	65		e
	ld h,a			;4bde	67		g
l4bdfh:
	ld h,c			;4bdf	61		a
	ld l,h			;4be0	6c		l
	jr nz,l4c4ch		;4be1	20 69		  i
l4be3h:
	ld l,(hl)		;4be3	6e		n
	ld (hl),h		;4be4	74		t
	ld h,l			;4be5	65		e
	ld (hl),d		;4be6	72		r
	ld (hl),d		;4be7	72		r
	ld (hl),l		;4be8	75		u
	ld (hl),b		;4be9	70		p
	ld (hl),h		;4bea	74		t
	inc l			;4beb	2c		,
	jr nz,$+101		;4bec	20 63		  c
	ld l,b			;4bee	68		h
	ld h,c			;4bef	61		a
l4bf0h:
	ld l,(hl)		;4bf0	6e		n
	ld l,(hl)		;4bf1	6e		n
l4bf2h:
	ld h,l			;4bf2	65		e
	ld l,h			;4bf3	6c		l
	jr nz,l4c30h		;4bf4	20 3a		  :
	cpl			;4bf6	2f		/
	ld l,(hl)		;4bf7	6e		n
	ld l,a			;4bf8	6f		o
	ld (hl),h		;4bf9	74		t
l4bfah:
	jr nz,$+116		;4bfa	20 72		  r
	ld h,l			;4bfc	65		e
	ld h,c			;4bfd	61		a
	ld h,h			;4bfe	64		d
l4bffh:
	ld a,c			;4bff	79		y
l4c00h:
	ld (0f864h),hl		;4c00	22 64 f8	" d .
	ld (0f866h),hl		;4c03	22 66 f8	" f .
	ld (0f868h),hl		;4c06	22 68 f8	" h .
l4c09h:
	ld (0f86ah),hl		;4c09	22 6a f8	" j .
	ld (0f86ch),hl		;4c0c	22 6c f8	" l .
	ld (0f86eh),hl		;4c0f	22 6e f8	" n .
l4c12h:
	ld (0f87eh),hl		;4c12	22 7e f8	" ~ .
	ld (0f880h),hl		;4c15	22 80 f8	" . .
	ld (0f882h),hl		;4c18	22 82 f8	" . .
	ld (0f884h),hl		;4c1b	22 84 f8	" . .
	ld (0f822h),hl		;4c1e	22 22 f8	" " .
	ld (0f820h),hl		;4c21	22 20 f8	"   .
	ld (0f874h),hl		;4c24	22 74 f8	" t .
	ld (0f872h),hl		;4c27	22 72 f8	" r .
	ld (0f870h),hl		;4c2a	22 70 f8	" p .
	ld (0f824h),hl		;4c2d	22 24 f8	" $ .
l4c30h:
	ld hl,00000h		;4c30	21 00 00	! . .
	ld ix,0f05ah		;4c33	dd 21 5a f0	. ! Z .
	call 01134h		;4c37	cd 34 11	. 4 .
	ld ix,0f10eh		;4c3a	dd 21 0e f1	. ! . .
	call 01134h		;4c3e	cd 34 11	. 4 .
	ld ix,0f118h		;4c41	dd 21 18 f1	. ! . .
	call 01134h		;4c45	cd 34 11	. 4 .
	ld ix,0f15eh		;4c48	dd 21 5e f1	. ! ^ .
l4c4ch:
	call 01134h		;4c4c	cd 34 11	. 4 .
	ld ix,0f168h		;4c4f	dd 21 68 f1	. ! h .
	call 01134h		;4c53	cd 34 11	. 4 .
	ld ix,0f1aeh		;4c56	dd 21 ae f1	. ! . .
	call 01134h		;4c5a	cd 34 11	. 4 .
	ld ix,0f1b8h		;4c5d	dd 21 b8 f1	. ! . .
	call 01134h		;4c61	cd 34 11	. 4 .
	ld ix,0f1feh		;4c64	dd 21 fe f1	. ! . .
	call 01134h		;4c68	cd 34 11	. 4 .
	ld ix,0f208h		;4c6b	dd 21 08 f2	. ! . .
	call 01134h		;4c6f	cd 34 11	. 4 .
	ld ix,0f24eh		;4c72	dd 21 4e f2	. ! N .
	call 01134h		;4c76	cd 34 11	. 4 .
	ld ix,0f258h		;4c79	dd 21 58 f2	. ! X .
	call 01134h		;4c7d	cd 34 11	. 4 .
	ld ix,0f29eh		;4c80	dd 21 9e f2	. ! . .
	call 01134h		;4c84	cd 34 11	. 4 .
	ld ix,0f2a8h		;4c87	dd 21 a8 f2	. ! . .
	call 01134h		;4c8b	cd 34 11	. 4 .
	ld ix,0f2eeh		;4c8e	dd 21 ee f2	. ! . .
	call 01134h		;4c92	cd 34 11	. 4 .
	ld ix,0f2f8h		;4c95	dd 21 f8 f2	. ! . .
	call 01134h		;4c99	cd 34 11	. 4 .
	ld ix,0f33eh		;4c9c	dd 21 3e f3	. ! > .
	call 01134h		;4ca0	cd 34 11	. 4 .
	ld ix,0f348h		;4ca3	dd 21 48 f3	. ! H .
	call 01134h		;4ca7	cd 34 11	. 4 .
	ld ix,0f38eh		;4caa	dd 21 8e f3	. ! . .
	call 01134h		;4cae	cd 34 11	. 4 .
	ld ix,0f398h		;4cb1	dd 21 98 f3	. ! . .
	call 01134h		;4cb5	cd 34 11	. 4 .
	ld ix,0f3deh		;4cb8	dd 21 de f3	. ! . .
	call 01134h		;4cbc	cd 34 11	. 4 .
	ld ix,0f3e8h		;4cbf	dd 21 e8 f3	. ! . .
	call 01134h		;4cc3	cd 34 11	. 4 .
	ld ix,0f438h		;4cc6	dd 21 38 f4	. ! 8 .
	call 01134h		;4cca	cd 34 11	. 4 .
	ld ix,0f488h		;4ccd	dd 21 88 f4	. ! . .
	call 01134h		;4cd1	cd 34 11	. 4 .
	ld ix,0f4d8h		;4cd4	dd 21 d8 f4	. ! . .
	call 01134h		;4cd8	cd 34 11	. 4 .
	ld ix,0f528h		;4cdb	dd 21 28 f5	. ! ( .
	call 01134h		;4cdf	cd 34 11	. 4 .
	ld ix,0f578h		;4ce2	dd 21 78 f5	. ! x .
	call 01134h		;4ce6	cd 34 11	. 4 .
	ld ix,0f6aeh		;4ce9	dd 21 ae f6	. ! . .
	call 01134h		;4ced	cd 34 11	. 4 .
	ld ix,0f6b8h		;4cf0	dd 21 b8 f6	. ! . .
	call 01134h		;4cf4	cd 34 11	. 4 .
	ld ix,0f6feh		;4cf7	dd 21 fe f6	. ! . .
	call 01134h		;4cfb	cd 34 11	. 4 .
	ld ix,0f708h		;4cfe	dd 21 08 f7	. ! . .
	call 01134h		;4d02	cd 34 11	. 4 .
	ret			;4d05	c9		.
	xor a			;4d06	af		.
	ld (0f81ch),a		;4d07	32 1c f8	2 . .
	ld a,(0f88ch)		;4d0a	3a 8c f8	: . .
	cp 000h			;4d0d	fe 00		. .
	jp nz,l2f17h		;4d0f	c2 17 2f	. . /
	ld a,(0f80ch)		;4d12	3a 0c f8	: . .
	ld (0f894h),a		;4d15	32 94 f8	2 . .
	ld a,(0f80eh)		;4d18	3a 0e f8	: . .
	inc a			;4d1b	3c		<
	ld (0f892h),a		;4d1c	32 92 f8	2 . .
	xor a			;4d1f	af		.
	ld (0f816h),a		;4d20	32 16 f8	2 . .
	ld (0f896h),a		;4d23	32 96 f8	2 . .
	call l28c4h		;4d26	cd c4 28	. . (
	ld a,(0f894h)		;4d29	3a 94 f8	: . .
	ld (0f818h),a		;4d2c	32 18 f8	2 . .
	call sub_2939h		;4d2f	cd 39 29	. 9 )
	ld a,(0f824h)		;4d32	3a 24 f8	: $ .
	cp 000h			;4d35	fe 00		. .
	jr z,l4d3fh		;4d37	28 06		( .
	call 02d8ch		;4d39	cd 8c 2d	. . -
	call l28c4h		;4d3c	cd c4 28	. . (
l4d3fh:
	ld a,(0f896h)		;4d3f	3a 96 f8	: . .
	cp 000h			;4d42	fe 00		. .
	jr z,l4d56h		;4d44	28 10		( .
	xor a			;4d46	af		.
	ld (0f896h),a		;4d47	32 96 f8	2 . .
	ld a,(0f894h)		;4d4a	3a 94 f8	: . .
	inc a			;4d4d	3c		<
	ld (0f894h),a		;4d4e	32 94 f8	2 . .
	ld (0f818h),a		;4d51	32 18 f8	2 . .
	jr l4d66h		;4d54	18 10		. .
l4d56h:
	ld a,001h		;4d56	3e 01		> .
	ld (0f896h),a		;4d58	32 96 f8	2 . .
	ld a,(0f892h)		;4d5b	3a 92 f8	: . .
	sub 001h		;4d5e	d6 01		. .
	ld (0f892h),a		;4d60	32 92 f8	2 . .
	ld (0f818h),a		;4d63	32 18 f8	2 . .
l4d66h:
	ld a,(0168dh)		;4d66	3a 8d 16	: . .
	cp 000h			;4d69	fe 00		. .
	jr z,l4d7fh		;4d6b	28 12		( .
	ld a,(0f816h)		;4d6d	3a 16 f8	: . .
	cp 000h			;4d70	fe 00		. .
	jr nz,l4d7bh		;4d72	20 07		  .
	ld a,001h		;4d74	3e 01		> .
	ld (0f816h),a		;4d76	32 16 f8	2 . .
	jr l4d7fh		;4d79	18 04		. .
l4d7bh:
	xor a			;4d7b	af		.
	ld (0f816h),a		;4d7c	32 16 f8	2 . .
l4d7fh:
	ld a,(0f894h)		;4d7f	3a 94 f8	: . .
	ld b,a			;4d82	47		G
	ld a,(0f892h)		;4d83	3a 92 f8	: . .
	cp b			;4d86	b8		.
	jp nz,02d2fh		;4d87	c2 2f 2d	. / -
	jr l4dc9h		;4d8a	18 3d		. =
	xor a			;4d8c	af		.
	ld (0f824h),a		;4d8d	32 24 f8	2 $ .
	ld a,(0f816h)		;4d90	3a 16 f8	: . .
	cp 000h			;4d93	fe 00		. .
	jr nz,l4db0h		;4d95	20 19		  .
	ld hl,(0f866h)		;4d97	2a 66 f8	* f .
	inc hl			;4d9a	23		#
	ld (0f866h),hl		;4d9b	22 66 f8	" f .
	ld ix,0f438h		;4d9e	dd 21 38 f4	. ! 8 .
	call 01134h		;4da2	cd 34 11	. 4 .
	ld hl,(0f818h)		;4da5	2a 18 f8	* . .
	ld ix,0f44ch		;4da8	dd 21 4c f4	. ! L .
	call 01134h		;4dac	cd 34 11	. 4 .
	ret			;4daf	c9		.
l4db0h:
	ld hl,(0f868h)		;4db0	2a 68 f8	* h .
	inc hl			;4db3	23		#
	ld (0f868h),hl		;4db4	22 68 f8	" h .
	ld ix,0f488h		;4db7	dd 21 88 f4	. ! . .
	call 01134h		;4dbb	cd 34 11	. 4 .
	ld hl,(0f818h)		;4dbe	2a 18 f8	* . .
	ld ix,0f49ch		;4dc1	dd 21 9c f4	. ! . .
	call 01134h		;4dc5	cd 34 11	. 4 .
	ret			;4dc8	c9		.
l4dc9h:
	ld hl,(0f89ah)		;4dc9	2a 9a f8	* . .
	ld (0f802h),hl		;4dcc	22 02 f8	" . .
	ld a,(0f80ch)		;4dcf	3a 0c f8	: . .
	ld (0f818h),a		;4dd2	32 18 f8	2 . .
	xor a			;4dd5	af		.
	ld (0f816h),a		;4dd6	32 16 f8	2 . .
	ld a,001h		;4dd9	3e 01		> .
	ld (0f81ah),a		;4ddb	32 1a f8	2 . .
	call sub_2939h		;4dde	cd 39 29	. 9 )
	ld a,(0f824h)		;4de1	3a 24 f8	: $ .
	cp 000h			;4de4	fe 00		. .
	jr z,l4deeh		;4de6	28 06		( .
	call 02d8ch		;4de8	cd 8c 2d	. . -
	jp l2ea6h		;4deb	c3 a6 2e	. . .
l4deeh:
	call 019e3h		;4dee	cd e3 19	. . .
	call sub_1946h		;4df1	cd 46 19	. F .
	ld a,004h		;4df4	3e 04		> .
	ld (0f80ah),a		;4df6	32 0a f8	2 . .
	ld hl,(0f816h)		;4df9	2a 16 f8	* . .
	ld ix,0f7b2h		;4dfc	dd 21 b2 f7	. ! . .
	jr nz,$+49		;4e00	20 2f		  /
l4e02h:
	in a,(067h)		;4e02	db 67		. g
	bit 7,a			;4e04	cb 7f		. .
	jr nz,l4e02h		;4e06	20 fa		  .
	ld a,(0ffaah)		;4e08	3a aa ff	: . .
	rlca			;4e0b	07		.
	rlca			;4e0c	07		.
	rlca			;4e0d	07		.
	or b			;4e0e	b0		.
	set 5,a			;4e0f	cb ef		. .
	out (066h),a		;4e11	d3 66		. f
	ld a,c			;4e13	79		y
	out (063h),a		;4e14	d3 63		. c
	ld a,l			;4e16	7d		}
	out (064h),a		;4e17	d3 64		. d
	ld a,h			;4e19	7c		|
	out (065h),a		;4e1a	d3 65		. e
	ret			;4e1c	c9		.
	push bc			;4e1d	c5		.
	ld bc,00200h		;4e1e	01 00 02	. . .
l4e21h:
	ld a,(de)		;4e21	1a		.
	cp (hl)			;4e22	be		.
	jr nz,l4e2ch		;4e23	20 07		  .
	inc hl			;4e25	23		#
	inc de			;4e26	13		.
	dec bc			;4e27	0b		.
	ld a,c			;4e28	79		y
	or b			;4e29	b0		.
	jr nz,l4e21h		;4e2a	20 f5		  .
l4e2ch:
	pop bc			;4e2c	c1		.
	ret			;4e2d	c9		.
	push bc			;4e2e	c5		.
	ld bc,00002h		;4e2f	01 02 00	. . .
l4e32h:
	ld (ix+000h),b		;4e32	dd 70 00	. p .
	inc ix			;4e35	dd 23		. #
	djnz l4e32h		;4e37	10 f9		. .
	dec c			;4e39	0d		.
	jr nz,l4e32h		;4e3a	20 f6		  .
	pop bc			;4e3c	c1		.
	ret			;4e3d	c9		.
	ld a,003h		;4e3e	3e 03		> .
	out (00ch),a		;4e40	d3 0c		. .
	out (00dh),a		;4e42	d3 0d		. .
	out (00eh),a		;4e44	d3 0e		. .
	out (00fh),a		;4e46	d3 0f		. .
	out (044h),a		;4e48	d3 44		. D
	out (045h),a		;4e4a	d3 45		. E
	out (046h),a		;4e4c	d3 46		. F
	out (047h),a		;4e4e	d3 47		. G
	ld hl,00240h		;4e50	21 40 02	! @ .
	ld a,l			;4e53	7d		}
	out (00ch),a		;4e54	d3 0c		. .
	ld hl,00238h		;4e56	21 38 02	! 8 .
	ld a,l			;4e59	7d		}
	out (044h),a		;4e5a	d3 44		. D
	ld a,0d7h		;4e5c	3e d7		> .
	out (00fh),a		;4e5e	d3 0f		. .
	ld a,001h		;4e60	3e 01		> .
	out (00fh),a		;4e62	d3 0f		. .
	ld a,0d7h		;4e64	3e d7		> .
	out (044h),a		;4e66	d3 44		. D
	ld a,001h		;4e68	3e 01		> .
	out (044h),a		;4e6a	d3 44		. D
	ret			;4e6c	c9		.
	ld a,004h		;4e6d	3e 04		> .
	out (0fah),a		;4e6f	d3 fa		. .
	ld a,048h		;4e71	3e 48		> H
	out (0fbh),a		;4e73	d3 fb		. .
	jr l4e7fh		;4e75	18 08		. .
	ld a,004h		;4e77	3e 04		> .
	out (0fah),a		;4e79	d3 fa		. .
	ld a,044h		;4e7b	3e 44		> D
	out (0fbh),a		;4e7d	d3 fb		. .
l4e7fh:
	out (0fch),a		;4e7f	d3 fc		. .
	ld a,l			;4e81	7d		}
	out (0f0h),a		;4e82	d3 f0		. .
	ld a,h			;4e84	7c		|
	out (0f0h),a		;4e85	d3 f0		. .
	ld hl,001ffh		;4e87	21 ff 01	! . .
	ld a,l			;4e8a	7d		}
	out (0f1h),a		;4e8b	d3 f1		. .
	ld a,h			;4e8d	7c		|
	out (0f1h),a		;4e8e	d3 f1		. .
	ld a,000h		;4e90	3e 00		> .
	out (0fah),a		;4e92	d3 fa		. .
	ret			;4e94	c9		.
	nop			;4e95	00		.
	nop			;4e96	00		.
	nop			;4e97	00		.
	dec c			;4e98	0d		.
	nop			;4e99	00		.
	add hl,bc		;4e9a	09		.
	nop			;4e9b	00		.
	dec b			;4e9c	05		.
	nop			;4e9d	00		.
	ld bc,00e00h		;4e9e	01 00 0e	. . .
	nop			;4ea1	00		.
	ld a,(bc)		;4ea2	0a		.
	nop			;4ea3	00		.
	ld b,000h		;4ea4	06 00		. .
	ld (bc),a		;4ea6	02		.
	nop			;4ea7	00		.
	rrca			;4ea8	0f		.
	nop			;4ea9	00		.
	dec bc			;4eaa	0b		.
	nop			;4eab	00		.
	rlca			;4eac	07		.
	nop			;4ead	00		.
	inc bc			;4eae	03		.
	nop			;4eaf	00		.
	djnz l4eb2h		;4eb0	10 00		. .
l4eb2h:
	inc c			;4eb2	0c		.
	nop			;4eb3	00		.
	ex af,af'		;4eb4	08		.
	nop			;4eb5	00		.
	inc b			;4eb6	04		.
	ld hl,l3695h		;4eb7	21 95 36	! . 6
	ld de,0e000h		;4eba	11 00 e0	. . .
	ld bc,00022h		;4ebd	01 22 00	. " .
	ldir			;4ec0	ed b0		. .
	ret			;4ec2	c9		.
	push hl			;4ec3	e5		.
	push ix			;4ec4	dd e5		. .
l4ec6h:
	ei			;4ec6	fb		.
	ld hl,l30d4h		;4ec7	21 d4 30	! . 0
l4ecah:
	dec hl			;4eca	2b		+
	ld a,l			;4ecb	7d		}
	or h			;4ecc	b4		.
	jr nz,l4ecah		;4ecd	20 fb		  .
	di			;4ecf	f3		.
	pop ix			;4ed0	dd e1		. .
	pop hl			;4ed2	e1		.
	ld a,(0ffa6h)		;4ed3	3a a6 ff	: . .
	cp 001h			;4ed6	fe 01		. .
	ld a,000h		;4ed8	3e 00		> .
	ld (0ffa6h),a		;4eda	32 a6 ff	2 . .
	ret z			;4edd	c8		.
	push hl			;4ede	e5		.
	push ix			;4edf	dd e5		. .
	djnz l4ec6h		;4ee1	10 e3		. .
	ld hl,035d1h		;4ee3	21 d1 35	! . 5
	ld ix,(0fffch)		;4ee6	dd 2a fc ff	. * . .
	call 01161h		;4eea	cd 61 11	. a .
	ld a,050h		;4eed	3e 50		> P
	ld (0fffeh),a		;4eef	32 fe ff	2 . .
	pop ix			;4ef2	dd e1		. .
	pop hl			;4ef4	e1		.
	ret			;4ef5	c9		.
	push af			;4ef6	f5		.
	push bc			;4ef7	c5		.
	push de			;4ef8	d5		.
	push hl			;4ef9	e5		.
	ld a,001h		;4efa	3e 01		> .
	ld (0ffa6h),a		;4efc	32 a6 ff	2 . .
	ld a,(0ffa4h)		;4eff	3a a4 ff	: . .
	cp 004h			;4f02	fe 04		. .
	jp z,037c9h		;4f04	ca c9 37	. . 7
	cp 003h			;4f07	fe 03		. .
	jr z,l4f67h		;4f09	28 5c		( \
	cp 002h			;4f0b	fe 02		. .
	jr z,l4f49h		;4f0d	28 3a		( :
	in a,(067h)		;4f0f	db 67		. g
	bit 0,a			;4f11	cb 47		. G
	jr nz,l4f1bh		;4f13	20 06		  .
l4f15h:
	pop hl			;4f15	e1		.
	pop de			;4f16	d1		.
	pop bc			;4f17	c1		.
	pop af			;4f18	f1		.
	reti			;4f19	ed 4d		. M
l4f1bh:
	ld a,(0ffaah)		;4f1b	3a aa ff	: . .
	call 00d7fh		;4f1e	cd 7f 0d	. . .
	in a,(061h)		;4f21	db 61		. a
	bit 1,a			;4f23	cb 4f		. O
	jr nz,l4f38h		;4f25	20 11		  .
	ld hl,03507h		;4f27	21 07 35	! . 5
	ld ix,(0fffch)		;4f2a	dd 2a fc ff	. * . .
	call 01161h		;4f2e	cd 61 11	. a .
	ld a,051h		;4f31	3e 51		> Q
	ld (0fffeh),a		;4f33	32 fe ff	2 . .
	jr l4f15h		;4f36	18 dd		. .
l4f38h:
	ld hl,034e7h		;4f38	21 e7 34	! . 4
	ld ix,(0fffch)		;4f3b	dd 2a fc ff	. * . .
	call 01161h		;4f3f	cd 61 11	. a .
	ld a,052h		;4f42	3e 52		> R
	ld (0fffeh),a		;4f44	32 fe ff	2 . .
	jr l4f15h		;4f47	18 cc		. .
l4f49h:
	in a,(067h)		;4f49	db 67		. g
	bit 0,a			;4f4b	cb 47		. G
	jp z,l3715h		;4f4d	ca 15 37	. . 7
	ld a,(0ffaah)		;4f50	3a aa ff	: . .
	call 00d7fh		;4f53	cd 7f 0d	. . .
	ld hl,l35c3h		;4f56	21 c3 35	! . 5
	ld ix,(0fffch)		;4f59	dd 2a fc ff	. * . .
	call 01161h		;4f5d	cd 61 11	. a .
	ld a,053h		;4f60	3e 53		> S
	ld (0fffeh),a		;4f62	32 fe ff	2 . .
	jr l4f15h		;4f65	18 ae		. .
l4f67h:
	in a,(067h)		;4f67	db 67		. g
	bit 0,a			;4f69	cb 47		. G
	jr z,l4f15h		;4f6b	28 a8		( .
	ld a,(0ffaah)		;4f6d	3a aa ff	: . .
	call 00d7fh		;4f70	cd 7f 0d	. . .
	in a,(061h)		;4f73	db 61		. a
	bit 2,a			;4f75	cb 57		. W
	jr z,l4f8bh		;4f77	28 12		( .
	ld hl,l3516h		;4f79	21 16 35	! . 5
	ld ix,(0fffch)		;4f7c	dd 2a fc ff	. * . .
	call 01161h		;4f80	cd 61 11	. a .
	ld a,054h		;4f83	3e 54		> T
	ld (0fffeh),a		;4f85	32 fe ff	2 . .
	jp l3715h		;4f88	c3 15 37	. . 7
l4f8bh:
	bit 4,a			;4f8b	cb 67		. g
	jr z,l4fa1h		;4f8d	28 12		( .
	ld hl,0352dh		;4f8f	21 2d 35	! - 5
	ld ix,(0fffch)		;4f92	dd 2a fc ff	. * . .
	call 01161h		;4f96	cd 61 11	. a .
	ld a,055h		;4f99	3e 55		> U
	ld (0fffeh),a		;4f9b	32 fe ff	2 . .
	jp l3715h		;4f9e	c3 15 37	. . 7
l4fa1h:
	bit 5,a			;4fa1	cb 6f		. o
	jr z,l4fb7h		;4fa3	28 12		( .
	ld hl,l353bh		;4fa5	21 3b 35	! ; 5
	ld ix,(0fffch)		;4fa8	dd 2a fc ff	. * . .
	call 01161h		;4fac	cd 61 11	. a .
	ld a,056h		;4faf	3e 56		> V
	ld (0fffeh),a		;4fb1	32 fe ff	2 . .
	jp l3715h		;4fb4	c3 15 37	. . 7
l4fb7h:
	ld hl,l3552h		;4fb7	21 52 35	! R 5
	ld ix,(0fffch)		;4fba	dd 2a fc ff	. * . .
	call 01161h		;4fbe	cd 61 11	. a .
	ld a,057h		;4fc1	3e 57		> W
	ld (0fffeh),a		;4fc3	32 fe ff	2 . .
l4fc6h:
	jp l3715h		;4fc6	c3 15 37	. . 7
	in a,(067h)		;4fc9	db 67		. g
	bit 0,a			;4fcb	cb 47		. G
	jr nz,l4ff5h		;4fcd	20 26		  &
	ld de,0e000h		;4fcf	11 00 e0	. . .
	ld hl,0e200h		;4fd2	21 00 e2	! . .
	call sub_361dh		;4fd5	cd 1d 36	. . 6
	jp z,l3715h		;4fd8	ca 15 37	. . 7
	ld a,(0ffaah)		;4fdb	3a aa ff	: . .
	call 00d7fh		;4fde	cd 7f 0d	. . .
	ld hl,0355fh		;4fe1	21 5f 35	! _ 5
	ld ix,(0fffch)		;4fe4	dd 2a fc ff	. * . .
	set 0,c			;4fe8	cb c1		. .
	call 01161h		;4fea	cd 61 11	. a .
	ld a,058h		;4fed	3e 58		> X
	ld (0fffeh),a		;4fef	32 fe ff	2 . .
	jp l3715h		;4ff2	c3 15 37	. . 7
l4ff5h:
	ld a,(0ffaah)		;4ff5	3a aa ff	: . .
	call 00d7fh		;4ff8	cd 7f 0d	. . .
	in a,(061h)		;4ffb	db 61		. a
	bit 0,a			;4ffd	cb 47		. G
	jr z,l5017h		;4fff	28 16		( .
	ret nc			;5001	d0		.
	sbc hl,de		;5002	ed 52		. R
	ret z			;5004	c8		.
	inc de			;5005	13		.
	ld (0d016h),de		;5006	ed 53 16 d0	. S . .
	jr l4fc6h		;500a	18 ba		. .
	push af			;500c	f5		.
	in a,(010h)		;500d	db 10		. .
	cp 052h			;500f	fe 52		. R
	jp z,l41c8h		;5011	ca c8 41	. . A
	ld a,(0d096h)		;5014	3a 96 d0	: . .
l5017h:
	cp 00fh			;5017	fe 0f		. .
	jp z,l41c8h		;5019	ca c8 41	. . A
	ld a,020h		;501c	3e 20		>  
	ld de,0f708h		;501e	11 08 f7	. . .
	ld (de),a		;5021	12		.
	ld a,(0d096h)		;5022	3a 96 d0	: . .
	cp 001h			;5025	fe 01		. .
	jr z,l505fh		;5027	28 36		( 6
	cp 002h			;5029	fe 02		. .
	jr z,l5078h		;502b	28 4b		( K
	cp 003h			;502d	fe 03		. .
	jp z,040b4h		;502f	ca b4 40	. . @
	cp 004h			;5032	fe 04		. .
	jp z,040dah		;5034	ca da 40	. . @
	cp 005h			;5037	fe 05		. .
	jp z,0411ch		;5039	ca 1c 41	. . A
	cp 006h			;503c	fe 06		. .
	jp z,04142h		;503e	ca 42 41	. B A
	cp 007h			;5041	fe 07		. .
	jp z,04161h		;5043	ca 61 41	. a A
	cp 008h			;5046	fe 08		. .
	jp z,l4176h		;5048	ca 76 41	. v A
	cp 009h			;504b	fe 09		. .
	jp z,0418bh		;504d	ca 8b 41	. . A
	cp 00ah			;5050	fe 0a		. .
	jp z,04091h		;5052	ca 91 40	. . @
	cp 00bh			;5055	fe 0b		. .
	jp z,l40f8h+1		;5057	ca f9 40	. . @
	cp 00ch			;505a	fe 0c		. .
	jp z,041a0h		;505c	ca a0 41	. . A
l505fh:
	in a,(010h)		;505f	db 10		. .
	ld d,a			;5061	57		W
	call 03d55h		;5062	cd 55 3d	. U =
	ld b,a			;5065	47		G
	ld a,(0d0b4h)		;5066	3a b4 d0	: . .
	cp b			;5069	b8		.
	jp c,l4218h		;506a	da 18 42	. . B
	ld a,b			;506d	78		x
	ld (0d004h),a		;506e	32 04 d0	2 . .
	ld hl,0f14ch		;5071	21 4c f1	! L .
	ld (hl),d		;5074	72		r
	pop af			;5075	f1		.
	reti			;5076	ed 4d		. M
l5078h:
	in a,(010h)		;5078	db 10		. .
	ld d,a			;507a	57		W
	call 03d55h		;507b	cd 55 3d	. U =
	ld b,a			;507e	47		G
	ld a,(0d0b4h)		;507f	3a b4 d0	: . .
	cp b			;5082	b8		.
	jp c,l4218h		;5083	da 18 42	. . B
	ld a,b			;5086	78		x
	ld (0d006h),a		;5087	32 06 d0	2 . .
	ld hl,0f19ah		;508a	21 9a f1	! . .
	ld (hl),d		;508d	72		r
	pop af			;508e	f1		.
	reti			;508f	ed 4d		. M
	in a,(010h)		;5091	db 10		. .
	call 03d55h		;5093	cd 55 3d	. U =
	cp 0ffh			;5096	fe ff		. .
	jp z,l4218h		;5098	ca 18 42	. . B
	ld hl,00000h		;509b	21 00 00	! . .
	ld de,00000h		;509e	11 00 00	. . .
	ld e,a			;50a1	5f		_
	ld b,064h		;50a2	06 64		. d
l50a4h:
	add hl,de		;50a4	19		.
	dec b			;50a5	05		.
	jr nz,l50a4h		;50a6	20 fc		  .
	ld (0d00ah),hl		;50a8	22 0a d0	" . .
	in a,(010h)		;50ab	db 10		. .
	ld hl,0f1edh		;50ad	21 ed f1	! . .
	ld (hl),a		;50b0	77		w
	pop af			;50b1	f1		.
	reti			;50b2	ed 4d		. M
	in a,(010h)		;50b4	db 10		. .
	call 03d55h		;50b6	cd 55 3d	. U =
	cp 0ffh			;50b9	fe ff		. .
	jp z,l4218h		;50bb	ca 18 42	. . B
	ld c,a			;50be	4f		O
	ld b,009h		;50bf	06 09		. .
l50c1h:
	add a,c			;50c1	81		.
	dec b			;50c2	05		.
	jr nz,l50c1h		;50c3	20 fc		  .
	ld hl,00000h		;50c5	21 00 00	! . .
	ld l,a			;50c8	6f		o
	ld de,(0d00ah)		;50c9	ed 5b 0a d0	. [ . .
	add hl,de		;50cd	19		.
	ld (0d00ah),hl		;50ce	22 0a d0	" . .
	in a,(010h)		;50d1	db 10		. .
	ld hl,0f1eeh		;50d3	21 ee f1	! . .
	ld (hl),a		;50d6	77		w
	pop af			;50d7	f1		.
	reti			;50d8	ed 4d		. M
	in a,(010h)		;50da	db 10		. .
	call 03d55h		;50dc	cd 55 3d	. U =
	cp 0ffh			;50df	fe ff		. .
	jp z,l4218h		;50e1	ca 18 42	. . B
	ld hl,00000h		;50e4	21 00 00	! . .
	ld l,a			;50e7	6f		o
	ld de,(0d00ah)		;50e8	ed 5b 0a d0	. [ . .
	add hl,de		;50ec	19		.
	ld (0d00ah),hl		;50ed	22 0a d0	" . .
	in a,(010h)		;50f0	db 10		. .
	ld hl,0f1efh		;50f2	21 ef f1	! . .
	ld (hl),a		;50f5	77		w
	pop af			;50f6	f1		.
	reti			;50f7	ed 4d		. M
	in a,(010h)		;50f9	db 10		. .
	call 03d55h		;50fb	cd 55 3d	. U =
	cp 0ffh			;50fe	fe ff		. .
	jp z,l4218h		;5100	ca 18 42	. . B
	ld hl,00000h		;5103	21 00 00	! . .
	ld de,00000h		;5106	11 00 00	. . .
	ld e,a			;5109	5f		_
	ld b,064h		;510a	06 64		. d
l510ch:
	add hl,de		;510c	19		.
	dec b			;510d	05		.
	jr nz,l510ch		;510e	20 fc		  .
	ld (0d00ch),hl		;5110	22 0c d0	" . .
	in a,(010h)		;5113	db 10		. .
	ld hl,0f23bh		;5115	21 3b f2	! ; .
	ld (hl),a		;5118	77		w
	pop af			;5119	f1		.
	reti			;511a	ed 4d		. M
	in a,(010h)		;511c	db 10		. .
	call 03d55h		;511e	cd 55 3d	. U =
	cp 0ffh			;5121	fe ff		. .
	jp z,l4218h		;5123	ca 18 42	. . B
	ld c,a			;5126	4f		O
	ld b,009h		;5127	06 09		. .
l5129h:
	add a,c			;5129	81		.
	dec b			;512a	05		.
	jr nz,l5129h		;512b	20 fc		  .
	ld hl,00000h		;512d	21 00 00	! . .
	ld l,a			;5130	6f		o
	ld de,(0d00ch)		;5131	ed 5b 0c d0	. [ . .
	add hl,de		;5135	19		.
	ld (0d00ch),hl		;5136	22 0c d0	" . .
	in a,(010h)		;5139	db 10		. .
	ld hl,0f23ch		;513b	21 3c f2	! < .
	ld (hl),a		;513e	77		w
	pop af			;513f	f1		.
	reti			;5140	ed 4d		. M
	in a,(010h)		;5142	db 10		. .
	call 03d55h		;5144	cd 55 3d	. U =
	cp 0ffh			;5147	fe ff		. .
	jp z,l4218h		;5149	ca 18 42	. . B
	ld hl,00000h		;514c	21 00 00	! . .
	ld l,a			;514f	6f		o
	ld de,(0d00ch)		;5150	ed 5b 0c d0	. [ . .
	add hl,de		;5154	19		.
	ld (0d00ch),hl		;5155	22 0c d0	" . .
	in a,(010h)		;5158	db 10		. .
	ld hl,0f23dh		;515a	21 3d f2	! = .
	ld (hl),a		;515d	77		w
	pop af			;515e	f1		.
	reti			;515f	ed 4d		. M
	in a,(010h)		;5161	db 10		. .
	ld d,a			;5163	57		W
	call 03d55h		;5164	cd 55 3d	. U =
	cp 002h			;5167	fe 02		. .
	jp nc,l4218h		;5169	d2 18 42	. . B
	ld (0d06ah),a		;516c	32 6a d0	2 j .
	ld hl,0f296h		;516f	21 96 f2	! . .
	ld (hl),d		;5172	72		r
	pop af			;5173	f1		.
	reti			;5174	ed 4d		. M
	in a,(010h)		;5176	db 10		. .
	ld d,a			;5178	57		W
	call 03d55h		;5179	cd 55 3d	. U =
	cp 002h			;517c	fe 02		. .
	jp nc,l4218h		;517e	d2 18 42	. . B
	ld (0d08ah),a		;5181	32 8a d0	2 . .
	ld hl,0f2f8h		;5184	21 f8 f2	! . .
	ld (hl),d		;5187	72		r
	pop af			;5188	f1		.
	reti			;5189	ed 4d		. M
	in a,(010h)		;518b	db 10		. .
	ld d,a			;518d	57		W
	call 03d55h		;518e	cd 55 3d	. U =
	cp 002h			;5191	fe 02		. .
	jp nc,l4218h		;5193	d2 18 42	. . B
	ld (0d07ah),a		;5196	32 7a d0	2 z .
	ld hl,0f336h		;5199	21 36 f3	! 6 .
	ld (hl),d		;519c	72		r
	pop af			;519d	f1		.
	reti			;519e	ed 4d		. M
	in a,(010h)		;51a0	db 10		. .
	ld d,a			;51a2	57		W
	call 03d55h		;51a3	cd 55 3d	. U =
	cp 002h			;51a6	fe 02		. .
	jp nc,l4218h		;51a8	d2 18 42	. . B
	ld bc,000bfh		;51ab	01 bf 00	. . .
	ld e,005h		;51ae	1e 05		. .
	cp 001h			;51b0	fe 01		. .
	jr c,l51b9h		;51b2	38 05		8 .
	ld bc,0013fh		;51b4	01 3f 01	. ? .
	ld e,003h		;51b7	1e 03		. .
l51b9h:
	ld (0d0b2h),bc		;51b9	ed 43 b2 d0	. C . .
	ld a,e			;51bd	7b		{
	ld (0d0b4h),a		;51be	32 b4 d0	2 . .
	ld hl,0f105h		;51c1	21 05 f1	! . .
	ld (hl),d		;51c4	72		r
	pop af			;51c5	f1		.
	reti			;51c6	ed 4d		. M
	call 00264h		;51c8	cd 64 02	. d .
	ei			;51cb	fb		.
	ld hl,0ffffh		;51cc	21 ff ff	! . .
l51cfh:
	dec hl			;51cf	2b		+
	ld a,l			;51d0	7d		}
	or h			;51d1	b4		.
	jr nz,l51cfh		;51d2	20 fb		  .
	di			;51d4	f3		.
	ld a,003h		;51d5	3e 03		> .
	out (044h),a		;51d7	d3 44		. D
l51d9h:
	in a,(010h)		;51d9	db 10		. .
l51dbh:
	cp 046h			;51db	fe 46		. F
	jr nz,l51fch		;51dd	20 1d		  .
	call 03dd3h		;51df	cd d3 3d	. . =
	ld sp,(0ffffh)		;51e2	ed 7b ff ff	. { . .
	ld a,003h		;51e6	3e 03		> .
	out (00ch),a		;51e8	d3 0c		. .
	out (00dh),a		;51ea	d3 0d		. .
	out (00eh),a		;51ec	d3 0e		. .
	out (00fh),a		;51ee	d3 0f		. .
	out (044h),a		;51f0	d3 44		. D
	out (045h),a		;51f2	d3 45		. E
	out (046h),a		;51f4	d3 46		. F
	out (047h),a		;51f6	d3 47		. G
	xor a			;51f8	af		.
	jp 00155h		;51f9	c3 55 01	. U .
l51fch:
	cp 048h			;51fc	fe 48		. H
	jr z,l51d9h		;51fe	28 d9		( .
	ld (de),a		;5200	12		.
	ld hl,0356ah		;5201	21 6a 35	! j 5
	ld ix,(0fffch)		;5204	dd 2a fc ff	. * . .
	call 01161h		;5208	cd 61 11	. a .
	ld a,059h		;520b	3e 59		> Y
	ld (0fffeh),a		;520d	32 fe ff	2 . .
	jp l3715h		;5210	c3 15 37	. . 7
	bit 2,a			;5213	cb 57		. W
	jr z,l5229h		;5215	28 12		( .
	ld hl,0357fh		;5217	21 7f 35	! . 5
	ld ix,(0fffch)		;521a	dd 2a fc ff	. * . .
	call 01161h		;521e	cd 61 11	. a .
	ld a,05ah		;5221	3e 5a		> Z
	ld (0fffeh),a		;5223	32 fe ff	2 . .
	jp l3715h		;5226	c3 15 37	. . 7
l5229h:
	bit 4,a			;5229	cb 67		. g
	jp nz,0378fh		;522b	c2 8f 37	. . 7
	bit 5,a			;522e	cb 6f		. o
	jp nz,037a5h		;5230	c2 a5 37	. . 7
	bit 6,a			;5233	cb 77		. w
	jr z,l5254h		;5235	28 1d		( .
	ld de,0e000h		;5237	11 00 e0	. . .
	ld hl,0e200h		;523a	21 00 e2	! . .
	call sub_361dh		;523d	cd 1d 36	. . 6
	jr z,l51dbh		;5240	28 99		( .
	ld hl,03595h		;5242	21 95 35	! . 5
	ld ix,(0fffch)		;5245	dd 2a fc ff	. * . .
	call 01161h		;5249	cd 61 11	. a .
	ld a,05bh		;524c	3e 5b		> [
	ld (0fffeh),a		;524e	32 fe ff	2 . .
	jp l3715h		;5251	c3 15 37	. . 7
l5254h:
	ld de,0e000h		;5254	11 00 e0	. . .
	ld hl,0e200h		;5257	21 00 e2	! . .
	call sub_361dh		;525a	cd 1d 36	. . 6
	jp nz,l37dbh		;525d	c2 db 37	. . 7
	in a,(061h)		;5260	db 61		. a
	bit 7,a			;5262	cb 7f		. .
	jp z,l37dbh		;5264	ca db 37	. . 7
	ld hl,035abh		;5267	21 ab 35	! . 5
	ld ix,(0fffch)		;526a	dd 2a fc ff	. * . .
	call 01161h		;526e	cd 61 11	. a .
	ld a,05ch		;5271	3e 5c		> \
	ld (0fffeh),a		;5273	32 fe ff	2 . .
	jp l3715h		;5276	c3 15 37	. . 7
	push af			;5279	f5		.
	push bc			;527a	c5		.
	push de			;527b	d5		.
	push hl			;527c	e5		.
	push ix			;527d	dd e5		. .
	push iy			;527f	fd e5		. .
	ld hl,l35dah		;5281	21 da 35	! . 5
	ld ix,(0fffch)		;5284	dd 2a fc ff	. * . .
	call 01161h		;5288	cd 61 11	. a .
	ld a,003h		;528b	3e 03		> .
	call 01180h		;528d	cd 80 11	. . .
	ld a,05dh		;5290	3e 5d		> ]
	ld (0fffeh),a		;5292	32 fe ff	2 . .
	pop iy			;5295	fd e1		. .
	pop ix			;5297	dd e1		. .
	pop hl			;5299	e1		.
	pop de			;529a	d1		.
	pop bc			;529b	c1		.
	pop af			;529c	f1		.
	reti			;529d	ed 4d		. M
	in a,(014h)		;529f	db 14		. .
	bit 6,a			;52a1	cb 77		. w
	jr nz,l52a9h		;52a3	20 04		  .
	xor a			;52a5	af		.
	jp 0049eh		;52a6	c3 9e 04	. . .
l52a9h:
	ld hl,l34dbh		;52a9	21 db 34	! . 4
	ld ix,0f370h		;52ac	dd 21 70 f3	. ! p .
	call 01161h		;52b0	cd 61 11	. a .
	ld a,00fh		;52b3	3e 0f		> .
	out (066h),a		;52b5	d3 66		. f
	ld b,001h		;52b7	06 01		. .
	call 01106h		;52b9	cd 06 11	. . .
	in a,(066h)		;52bc	db 66		. f
	cp 00fh			;52be	fe 0f		. .
	jr z,l52e7h		;52c0	28 25		( %
	ld hl,0107ch		;52c2	21 7c 10	! | .
	call 01161h		;52c5	cd 61 11	. a .
	in a,(066h)		;52c8	db 66		. f
	call 01180h		;52ca	cd 80 11	. . .
	ld hl,01076h		;52cd	21 76 10	! v .
	call 01161h		;52d0	cd 61 11	. a .
	ld a,00fh		;52d3	3e 0f		> .
	call 01180h		;52d5	cd 80 11	. . .
	ld hl,034f6h		;52d8	21 f6 34	! . 4
	call 01161h		;52db	cd 61 11	. a .
	ld b,014h		;52de	06 14		. .
	call 01106h		;52e0	cd 06 11	. . .
	xor a			;52e3	af		.
	jp 0049eh		;52e4	c3 9e 04	. . .
l52e7h:
	xor a			;52e7	af		.
	ld (0ffaah),a		;52e8	32 aa ff	2 . .
	call sub_363eh		;52eb	cd 3e 36	. > 6
	xor a			;52ee	af		.
	ld (0fffeh),a		;52ef	32 fe ff	2 . .
	ld (0ffa6h),a		;52f2	32 a6 ff	2 . .
	call sub_3602h		;52f5	cd 02 36	. . 6
	in a,(067h)		;52f8	db 67		. g
	bit 6,a			;52fa	cb 77		. w
	jr nz,l531bh		;52fc	20 1d		  .
	ld a,(0ffaah)		;52fe	3a aa ff	: . .
	cp 000h			;5301	fe 00		. .
	jp nz,03a22h		;5303	c2 22 3a	. " :
	call 00d7fh		;5306	cd 7f 0d	. . .
	ld hl,035f7h		;5309	21 f7 35	! . 5
	ld ix,(0fffch)		;530c	dd 2a fc ff	. * . .
	call 01161h		;5310	cd 61 11	. a .
	ld a,071h		;5313	3e 71		> q
	ld (0fffeh),a		;5315	32 fe ff	2 . .
	jp 03a22h		;5318	c3 22 3a	. " :
l531bh:
	ld a,001h		;531b	3e 01		> .
	ld (0ffa4h),a		;531d	32 a4 ff	2 . .
	ld a,017h		;5320	3e 17		> .
	out (067h),a		;5322	d3 67		. g
	ld b,064h		;5324	06 64		. d
	call l36c3h		;5326	cd c3 36	. . 6
	ld a,(0fffeh)		;5329	3a fe ff	: . .
	cp 000h			;532c	fe 00		. .
	jp nz,03a22h		;532e	c2 22 3a	. " :
	ld a,002h		;5331	3e 02		> .
	ld (0ffa4h),a		;5333	32 a4 ff	2 . .
	call l36b7h		;5336	cd b7 36	. . 6
	ld hl,00000h		;5339	21 00 00	! . .
	ld (0ffa8h),hl		;533c	22 a8 ff	" . .
l533fh:
	ld a,002h		;533f	3e 02		> .
	ld (0ffa0h),a		;5341	32 a0 ff	2 . .
l5344h:
	ld a,(0ffa0h)		;5344	3a a0 ff	: . .
	ld b,a			;5347	47		G
	ld hl,(0ffa8h)		;5348	2a a8 ff	* . .
	ld a,011h		;534b	3e 11		> .
	out (062h),a		;534d	d3 62		. b
	call sub_3602h		;534f	cd 02 36	. . 6
	ld hl,0e000h		;5352	21 00 e0	! . .
	call sub_366dh		;5355	cd 6d 36	. m 6
	ld a,050h		;5358	3e 50		> P
	out (067h),a		;535a	d3 67		. g
	ld b,064h		;535c	06 64		. d
	call l36c3h		;535e	cd c3 36	. . 6
	ld a,(0fffeh)		;5361	3a fe ff	: . .
	cp 000h			;5364	fe 00		. .
	jp nz,03a22h		;5366	c2 22 3a	. " :
	ld a,(0ffa0h)		;5369	3a a0 ff	: . .
	inc a			;536c	3c		<
	ld (0ffa0h),a		;536d	32 a0 ff	2 . .
	cp 004h			;5370	fe 04		. .
	jr nz,l5344h		;5372	20 d0		  .
	in a,(064h)		;5374	db 64		. d
	cp 001h			;5376	fe 01		. .
	jr z,l5382h		;5378	28 08		( .
	ld hl,00001h		;537a	21 01 00	! . .
	ld (0ffa8h),hl		;537d	22 a8 ff	" . .
	jr l533fh		;5380	18 bd		. .
l5382h:
	ld ix,0e000h		;5382	dd 21 00 e0	. ! . .
	call sub_362eh		;5386	cd 2e 36	. . 6
	ld hl,00000h		;5389	21 00 00	! . .
	ld (0ffa8h),hl		;538c	22 a8 ff	" . .
	ld a,002h		;538f	3e 02		> .
	ld (0ffa0h),a		;5391	32 a0 ff	2 . .
l5394h:
	ld a,000h		;5394	3e 00		> .
	ld (0ffa2h),a		;5396	32 a2 ff	2 . .
l5399h:
	ld hl,0e000h		;5399	21 00 e0	! . .
	call sub_366dh		;539c	cd 6d 36	. m 6
	ld a,(0ffa0h)		;539f	3a a0 ff	: . .
	ld b,a			;53a2	47		G
	ld hl,(0ffa8h)		;53a3	2a a8 ff	* . .
	ld a,(0ffa2h)		;53a6	3a a2 ff	: . .
	ld c,a			;53a9	4f		O
	call sub_3602h		;53aa	cd 02 36	. . 6
	ld a,003h		;53ad	3e 03		> .
	ld (0ffa4h),a		;53af	32 a4 ff	2 . .
	ld a,030h		;53b2	3e 30		> 0
	out (067h),a		;53b4	d3 67		. g
	ld b,064h		;53b6	06 64		. d
	call l36c3h		;53b8	cd c3 36	. . 6
	ld a,(0fffeh)		;53bb	3a fe ff	: . .
l53beh:
	cp 000h			;53be	fe 00		. .
	jp nz,03a22h		;53c0	c2 22 3a	. " :
	ld a,004h		;53c3	3e 04		> .
	ld (0ffa4h),a		;53c5	32 a4 ff	2 . .
l53c8h:
	ld hl,0e200h		;53c8	21 00 e2	! . .
	call 03677h		;53cb	cd 77 36	. w 6
	ld a,028h		;53ce	3e 28		> (
	out (067h),a		;53d0	d3 67		. g
	ld b,064h		;53d2	06 64		. d
	call l36c3h		;53d4	cd c3 36	. . 6
	ld a,(0fffeh)		;53d7	3a fe ff	: . .
	cp 000h			;53da	fe 00		. .
	jp nz,03a22h		;53dc	c2 22 3a	. " :
	ld a,(0ffa2h)		;53df	3a a2 ff	: . .
	inc a			;53e2	3c		<
	ld (0ffa2h),a		;53e3	32 a2 ff	2 . .
	cp 011h			;53e6	fe 11		. .
	jr nz,l5399h		;53e8	20 af		  .
	ld a,(0ffa0h)		;53ea	3a a0 ff	: . .
	inc a			;53ed	3c		<
	ld (0ffa0h),a		;53ee	32 a0 ff	2 . .
	cp 004h			;53f1	fe 04		. .
	jr nz,l5394h		;53f3	20 9f		  .
	in a,(064h)		;53f5	db 64		. d
	cp 001h			;53f7	fe 01		. .
	jr z,$+10		;53f9	28 08		( .
	ld hl,00001h		;53fb	21 01 00	! . .
	ld (0fea8h),hl		;53fe	22 a8 fe	" . .
	ld d,d			;5401	52		R
	jr nz,l540dh		;5402	20 09		  .
	call 00264h		;5404	cd 64 02	. d .
	ld sp,l8000h		;5407	31 00 80	1 . .
	jp 0443eh		;540a	c3 3e 44	. > D
l540dh:
	ld a,0d7h		;540d	3e d7		> .
	out (044h),a		;540f	d3 44		. D
	ld a,001h		;5411	3e 01		> .
	out (044h),a		;5413	d3 44		. D
	pop af			;5415	f1		.
	reti			;5416	ed 4d		. M
	pop af			;5418	f1		.
	ld a,03fh		;5419	3e 3f		> ?
	ld de,0f708h		;541b	11 08 f7	. . .
	ld (de),a		;541e	12		.
	reti			;541f	ed 4d		. M
	push af			;5421	f5		.
	push bc			;5422	c5		.
	push de			;5423	d5		.
	push hl			;5424	e5		.
	ld a,001h		;5425	3e 01		> .
	ld (0d024h),a		;5427	32 24 d0	2 $ .
	xor a			;542a	af		.
	ld (0d06eh),a		;542b	32 6e d0	2 n .
	ld a,(0d008h)		;542e	3a 08 d0	: . .
	cp 001h			;5431	fe 01		. .
	jr z,l544dh		;5433	28 18		( .
	cp 002h			;5435	fe 02		. .
	jr z,l546eh		;5437	28 35		( 5
	cp 003h			;5439	fe 03		. .
	jr z,l54a3h		;543b	28 66		( f
	cp 004h			;543d	fe 04		. .
	jr z,l54a5h		;543f	28 64		( d
	cp 005h			;5441	fe 05		. .
	jr z,l54a5h		;5443	28 60		( `
	cp 006h			;5445	fe 06		. .
	jr z,l54a3h		;5447	28 5a		( Z
	cp 007h			;5449	fe 07		. .
	jr z,l5489h		;544b	28 3c		( <
l544dh:
	in a,(067h)		;544d	db 67		. g
	bit 0,a			;544f	cb 47		. G
	jr nz,l5459h		;5451	20 06		  .
l5453h:
	pop hl			;5453	e1		.
	pop de			;5454	d1		.
	pop bc			;5455	c1		.
	pop af			;5456	f1		.
	reti			;5457	ed 4d		. M
l5459h:
	call 03dd3h		;5459	cd d3 3d	. . =
	ld hl,03c5dh		;545c	21 5d 3c	! ] <
	ld de,0f370h		;545f	11 70 f3	. p .
	ld bc,0002eh		;5462	01 2e 00	. . .
	ldir			;5465	ed b0		. .
	ld a,001h		;5467	3e 01		> .
	ld (0d06eh),a		;5469	32 6e d0	2 n .
	jr l5453h		;546c	18 e5		. .
l546eh:
	in a,(067h)		;546e	db 67		. g
	bit 0,a			;5470	cb 47		. G
	jr z,l5453h		;5472	28 df		( .
	ld hl,(0d012h)		;5474	2a 12 d0	* . .
	inc hl			;5477	23		#
	ld (0d012h),hl		;5478	22 12 d0	" . .
	ld ix,0f1aeh		;547b	dd 21 ae f1	. ! . .
	call 01134h		;547f	cd 34 11	. 4 .
	ld a,001h		;5482	3e 01		> .
	ld (0d06eh),a		;5484	32 6e d0	2 n .
	jr l5453h		;5487	18 ca		. .
l5489h:
	in a,(067h)		;5489	db 67		. g
	bit 0,a			;548b	cb 47		. G
	jr z,l5453h		;548d	28 c4		( .
	in a,(061h)		;548f	db 61		. a
	bit 4,a			;5491	cb 67		. g
	jr z,l5453h		;5493	28 be		( .
	ld hl,(0d0ach)		;5495	2a ac d0	* . .
	inc hl			;5498	23		#
	ld (0d0ach),hl		;5499	22 ac d0	" . .
	ld ix,0f4ceh		;549c	dd 21 ce f4	. ! . .
	call 01134h		;54a0	cd 34 11	. 4 .
l54a3h:
	jr l5453h		;54a3	18 ae		. .
l54a5h:
	ld a,(0d008h)		;54a5	3a 08 d0	: . .
	cp 005h			;54a8	fe 05		. .
	jr nz,l54ceh		;54aa	20 22		  "
	ld a,(0d06ah)		;54ac	3a 6a d0	: j .
	cp 001h			;54af	fe 01		. .
	jr nz,l54ceh		;54b1	20 1b		  .
	in a,(067h)		;54b3	db 67		. g
	bit 2,a			;54b5	cb 57		. W
	jr z,l54ceh		;54b7	28 15		( .
	ld hl,(0d0a8h)		;54b9	2a a8 d0	* . .
	inc hl			;54bc	23		#
	ld (0d0a8h),hl		;54bd	22 a8 d0	" . .
	ld ix,0f38eh		;54c0	dd 21 8e f3	. ! . .
	call 01134h		;54c4	cd 34 11	. 4 .
	ld ix,0f370h		;54c7	dd 21 70 f3	. ! p .
	call sub_3d6dh		;54cb	cd 6d 3d	. m =
l54ceh:
	in a,(067h)		;54ce	db 67		. g
	bit 0,a			;54d0	cb 47		. G
	jp nz,l4303h		;54d2	c2 03 43	. . C
	ld a,(0d008h)		;54d5	3a 08 d0	: . .
	cp 005h			;54d8	fe 05		. .
	jp nz,l4253h		;54da	c2 53 42	. S B
	ld a,(0d08ah)		;54dd	3a 8a d0	: . .
	cp 001h			;54e0	fe 01		. .
	jp z,l4253h		;54e2	ca 53 42	. S B
	call 03defh		;54e5	cd ef 3d	. . =
	jp z,l4253h		;54e8	ca 53 42	. S B
	ld hl,(0d01ah)		;54eb	2a 1a d0	* . .
	inc hl			;54ee	23		#
	ld (0d01ah),hl		;54ef	22 1a d0	" . .
	ld ix,0f42eh		;54f2	dd 21 2e f4	. ! . .
	call 01134h		;54f6	cd 34 11	. 4 .
	ld ix,0f410h		;54f9	dd 21 10 f4	. ! . .
	call sub_3d6dh		;54fd	cd 6d 3d	. m =
	jp l4253h		;5500	c3 53 42	. S B
	ld a,(0d008h)		;5503	3a 08 d0	: . .
	cp 005h			;5506	fe 05		. .
	jr z,l550fh		;5508	28 05		( .
	ld a,001h		;550a	3e 01		> .
	ld (0d06eh),a		;550c	32 6e d0	2 n .
l550fh:
	in a,(061h)		;550f	db 61		. a
	bit 0,a			;5511	cb 47		. G
	jr z,l552dh		;5513	28 18		( .
	ld hl,(0d098h)		;5515	2a 98 d0	* . .
	inc hl			;5518	23		#
	ld (0d098h),hl		;5519	22 98 d0	" . .
	ld ix,0f15eh		;551c	dd 21 5e f1	. ! ^ .
	call 01134h		;5520	cd 34 11	. 4 .
	ld ix,0f140h		;5523	dd 21 40 f1	. ! @ .
	call sub_3d6dh		;5527	cd 6d 3d	. m =
	jp l4253h		;552a	c3 53 42	. S B
l552dh:
	bit 2,a			;552d	cb 57		. W
	jr z,l5568h		;552f	28 37		( 7
	ld a,(0d008h)		;5531	3a 08 d0	: . .
	cp 005h			;5534	fe 05		. .
	jr nz,l5550h		;5536	20 18		  .
	ld hl,(0d09eh)		;5538	2a 9e d0	* . .
	inc hl			;553b	23		#
	ld (0d09eh),hl		;553c	22 9e d0	" . .
	ld ix,0f24eh		;553f	dd 21 4e f2	. ! N .
	call 01134h		;5543	cd 34 11	. 4 .
	ld ix,0f230h		;5546	dd 21 30 f2	. ! 0 .
	call sub_3d6dh		;554a	cd 6d 3d	. m =
	jp l4253h		;554d	c3 53 42	. S B
l5550h:
	ld hl,(0d09ch)		;5550	2a 9c d0	* . .
	inc hl			;5553	23		#
	ld (0d09ch),hl		;5554	22 9c d0	" . .
	ld ix,0f1feh		;5557	dd 21 fe f1	. ! . .
	call 01134h		;555b	cd 34 11	. 4 .
	ld ix,0f1e0h		;555e	dd 21 e0 f1	. ! . .
	call sub_3d6dh		;5562	cd 6d 3d	. m =
	jp l4253h		;5565	c3 53 42	. S B
l5568h:
	bit 4,a			;5568	cb 67		. g
	jr z,l5584h		;556a	28 18		( .
	ld hl,(0d0a0h)		;556c	2a a0 d0	* . .
	inc hl			;556f	23		#
	ld (0d0a0h),hl		;5570	22 a0 d0	" . .
	ld ix,0f29eh		;5573	dd 21 9e f2	. ! . .
	call 01134h		;5577	cd 34 11	. 4 .
	ld ix,0f280h		;557a	dd 21 80 f2	. ! . .
	call sub_3d6dh		;557e	cd 6d 3d	. m =
	jp l4253h		;5581	c3 53 42	. S B
l5584h:
	bit 5,a			;5584	cb 6f		. o
	jr z,l55a0h		;5586	28 18		( .
	ld hl,(0d0a2h)		;5588	2a a2 d0	* . .
	inc hl			;558b	23		#
	ld (0d0a2h),hl		;558c	22 a2 d0	" . .
	ld ix,0f2eeh		;558f	dd 21 ee f2	. ! . .
	call 01134h		;5593	cd 34 11	. 4 .
	ld ix,0f2d0h		;5596	dd 21 d0 f2	. ! . .
	call sub_3d6dh		;559a	cd 6d 3d	. m =
	jp l4253h		;559d	c3 53 42	. S B
l55a0h:
	ld a,(0d008h)		;55a0	3a 08 d0	: . .
	cp 005h			;55a3	fe 05		. .
	jr nz,$+99		;55a5	20 61		  a
	in a,(061h)		;55a7	db 61		. a
	bit 6,a			;55a9	cb 77		. w
	jr z,$+93		;55ab	28 5b		( [
	ld a,(0d08ah)		;55ad	3a 8a d0	: . .
	cp 001h			;55b0	fe 01		. .
	jr z,l55b9h		;55b2	28 05		( .
	call 03defh		;55b4	cd ef 3d	. . =
	jr z,l55f0h		;55b7	28 37		( 7
l55b9h:
	ld a,(0d06ah)		;55b9	3a 6a d0	: j .
	cp 001h			;55bc	fe 01		. .
	jr nz,l55d8h		;55be	20 18		  .
	ld hl,(0d0a6h)		;55c0	2a a6 d0	* . .
	inc hl			;55c3	23		#
	ld (0d0a6h),hl		;55c4	22 a6 d0	" . .
	ld ix,0f3deh		;55c7	dd 21 de f3	. ! . .
	call 01134h		;55cb	cd 34 11	. 4 .
	ld ix,0f3c0h		;55ce	dd 21 c0 f3	. ! . .
	call sub_3d6dh		;55d2	cd 6d 3d	. m =
	jp l4253h		;55d5	c3 53 42	. S B
l55d8h:
	ld hl,(0d0a4h)		;55d8	2a a4 d0	* . .
	inc hl			;55db	23		#
	ld (0d0a4h),hl		;55dc	22 a4 d0	" . .
	ld ix,0f33eh		;55df	dd 21 3e f3	. ! > .
	call 01134h		;55e3	cd 34 11	. 4 .
	ld ix,0f320h		;55e6	dd 21 20 f3	. !   .
	call sub_3d6dh		;55ea	cd 6d 3d	. m =
	jp l4253h		;55ed	c3 53 42	. S B
l55f0h:
	ld hl,(0d01ah)		;55f0	2a 1a d0	* . .
	inc hl			;55f3	23		#
	ld (0d01ah),hl		;55f4	22 1a d0	" . .
	ld ix,0f42eh		;55f7	dd 21 2e f4	. ! . .
	call 01134h		;55fb	cd 34 11	. 4 .
	ld ix,018ffh		;55fe	dd 21 ff 18	. ! . .
	adc a,h			;5602	8c		.
	ld a,(0ffaah)		;5603	3a aa ff	: . .
	call 00d7fh		;5606	cd 7f 0d	. . .
	ld hl,0105ah		;5609	21 5a 10	! Z .
	ld ix,(0fffch)		;560c	dd 2a fc ff	. * . .
	call 01161h		;5610	cd 61 11	. a .
	ld a,(0ffaah)		;5613	3a aa ff	: . .
	cp 001h			;5616	fe 01		. .
	jr z,l5622h		;5618	28 08		( .
	ld a,001h		;561a	3e 01		> .
	ld (0ffaah),a		;561c	32 aa ff	2 . .
	jp 038eeh		;561f	c3 ee 38	. . 8
l5622h:
	ld hl,0f3c0h		;5622	21 c0 f3	! . .
	ld ix,0f370h		;5625	dd 21 70 f3	. ! p .
	ld iy,l34dbh		;5629	fd 21 db 34	. ! . 4
	call 0119ch		;562d	cd 9c 11	. . .
	ei			;5630	fb		.
	ld a,(0ffffh)		;5631	3a ff ff	: . .
	bit 6,a			;5634	cb 77		. w
	di			;5636	f3		.
	jp nz,038e7h		;5637	c2 e7 38	. . 8
	ld a,(0fffeh)		;563a	3a fe ff	: . .
	jp 0049eh		;563d	c3 9e 04	. . .
	ld d,a			;5640	57		W
	ld b,h			;5641	44		D
	ld b,h			;5642	44		D
	jr nz,l5697h		;5643	20 52		  R
	ld b,l			;5645	45		E
	ld c,h			;5646	4c		L
	ld c,c			;5647	49		I
	ld b,c			;5648	41		A
	ld b,d			;5649	42		B
	ld c,c			;564a	49		I
	ld c,h			;564b	4c		L
	ld c,c			;564c	49		I
	ld d,h			;564d	54		T
	ld e,c			;564e	59		Y
	jr nz,l56a5h		;564f	20 54		  T
	ld b,l			;5651	45		E
	ld d,e			;5652	53		S
	ld d,h			;5653	54		T
	ld h,(hl)		;5654	66		f
	ld (hl),d		;5655	72		r
	ld l,a			;5656	6f		o
	ld l,l			;5657	6d		m
	jr nz,l56c2h		;5658	20 68		  h
	ld h,l			;565a	65		e
	ld h,c			;565b	61		a
	ld h,h			;565c	64		d
	jr nz,l5699h		;565d	20 3a		  :
	ld (hl),h		;565f	74		t
	ld l,a			;5660	6f		o
	jr nz,l56cbh		;5661	20 68		  h
	ld h,l			;5663	65		e
	ld h,c			;5664	61		a
	ld h,h			;5665	64		d
	jr nz,l56a2h		;5666	20 3a		  :
	ld h,(hl)		;5668	66		f
	ld (hl),d		;5669	72		r
	ld l,a			;566a	6f		o
	ld l,l			;566b	6d		m
	jr nz,l56e2h		;566c	20 74		  t
	ld (hl),d		;566e	72		r
	ld h,c			;566f	61		a
	ld h,e			;5670	63		c
	ld l,e			;5671	6b		k
	jr nz,l56aeh		;5672	20 3a		  :
	ld (hl),h		;5674	74		t
	ld l,a			;5675	6f		o
	jr nz,l56ech		;5676	20 74		  t
	ld (hl),d		;5678	72		r
	ld h,c			;5679	61		a
	ld h,e			;567a	63		c
	ld l,e			;567b	6b		k
	jr nz,$+60		;567c	20 3a		  :
	ld h,e			;567e	63		c
	ld (hl),d		;567f	72		r
	ld h,e			;5680	63		c
	cpl			;5681	2f		/
	ld h,l			;5682	65		e
	ld h,e			;5683	63		c
	ld h,e			;5684	63		c
	jr nz,l56eah		;5685	20 63		  c
	ld l,b			;5687	68		h
	ld h,l			;5688	65		e
	ld h,e			;5689	63		c
	ld l,e			;568a	6b		k
	jr nz,$+42		;568b	20 28		  (
	jr nc,l56beh		;568d	30 2f		0 /
	ld sp,02029h		;568f	31 29 20	1 )  
	ld a,(l6964h)		;5692	3a 64 69	: d i
	ld (hl),e		;5695	73		s
	ld l,e			;5696	6b		k
l5697h:
	jr nz,$+118		;5697	20 74		  t
l5699h:
	ld h,l			;5699	65		e
	ld (hl),e		;569a	73		s
	ld (hl),h		;569b	74		t
	jr nz,l56c6h		;569c	20 28		  (
	ld l,a			;569e	6f		o
	ld l,(hl)		;569f	6e		n
	ld l,h			;56a0	6c		l
	ld a,c			;56a1	79		y
l56a2h:
	jr nz,l5716h		;56a2	20 72		  r
	ld h,l			;56a4	65		e
l56a5h:
	ld h,c			;56a5	61		a
	ld h,h			;56a6	64		d
	ld l,c			;56a7	69		i
	ld l,(hl)		;56a8	6e		n
	ld h,a			;56a9	67		g
	add hl,hl		;56aa	29		)
	jr nz,l571bh		;56ab	20 6e		  n
	ld l,a			;56ad	6f		o
l56aeh:
	cpl			;56ae	2f		/
	ld a,c			;56af	79		y
	ld h,l			;56b0	65		e
	ld (hl),e		;56b1	73		s
	jr nz,$+42		;56b2	20 28		  (
	jr nc,l56e5h		;56b4	30 2f		0 /
	ld sp,02029h		;56b6	31 29 20	1 )  
	ld a,(l6f66h)		;56b9	3a 66 6f	: f o
	ld (hl),d		;56bc	72		r
	ld l,l			;56bd	6d		m
l56beh:
	ld h,c			;56be	61		a
	ld (hl),h		;56bf	74		t
	jr nz,l5730h		;56c0	20 6e		  n
l56c2h:
	ld l,a			;56c2	6f		o
	cpl			;56c3	2f		/
	ld a,c			;56c4	79		y
	ld h,l			;56c5	65		e
l56c6h:
	ld (hl),e		;56c6	73		s
	jr nz,l56f1h		;56c7	20 28		  (
	jr nc,l56fah		;56c9	30 2f		0 /
l56cbh:
	ld sp,02029h		;56cb	31 29 20	1 )  
	ld a,(l4351h+1)		;56ce	3a 52 43	: R C
	scf			;56d1	37		7
	ld (hl),033h		;56d2	36 33		6 3
	cpl			;56d4	2f		/
	ld d,d			;56d5	52		R
	ld b,e			;56d6	43		C
	scf			;56d7	37		7
	ld (hl),033h		;56d8	36 33		6 3
	ld b,d			;56da	42		B
	jr nz,l5705h		;56db	20 28		  (
	jr nc,l570eh		;56dd	30 2f		0 /
	ld sp,02029h		;56df	31 29 20	1 )  
l56e2h:
	ld a,(l4150h)		;56e2	3a 50 41	: P A
l56e5h:
	ld d,e			;56e5	53		S
	ld d,e			;56e6	53		S
	jr nz,l5723h		;56e7	20 3a		  :
	ld b,e			;56e9	43		C
l56eah:
	ld d,d			;56ea	52		R
	ld b,e			;56eb	43		C
l56ech:
	dec l			;56ec	2d		-
	ld b,e			;56ed	43		C
	ld c,b			;56ee	48		H
	ld b,l			;56ef	45		E
	ld b,e			;56f0	43		C
l56f1h:
	ld c,e			;56f1	4b		K
	ld b,l			;56f2	45		E
	ld b,e			;56f3	43		C
	ld b,e			;56f4	43		C
	dec l			;56f5	2d		-
	ld b,e			;56f6	43		C
	ld c,b			;56f7	48		H
	ld b,l			;56f8	45		E
	ld b,e			;56f9	43		C
l56fah:
	ld c,e			;56fa	4b		K
	ld b,h			;56fb	44		D
	ld b,c			;56fc	41		A
	ld d,h			;56fd	54		T
	ld b,c			;56fe	41		A
	jr nz,l5742h		;56ff	20 41		  A
	ld b,h			;5701	44		D
	ld b,h			;5702	44		D
	ld d,d			;5703	52		R
	ld b,l			;5704	45		E
l5705h:
	ld d,e			;5705	53		S
	ld d,e			;5706	53		S
	jr nz,l5756h		;5707	20 4d		  M
	ld b,c			;5709	41		A
	ld d,d			;570a	52		R
	ld c,e			;570b	4b		K
	jr nz,l575ch		;570c	20 4e		  N
l570eh:
	ld c,a			;570e	4f		O
	ld d,h			;570f	54		T
	jr nz,l5758h		;5710	20 46		  F
	ld c,a			;5712	4f		O
	ld d,l			;5713	55		U
	ld c,(hl)		;5714	4e		N
	ld b,h			;5715	44		D
l5716h:
	jr nz,$+60		;5716	20 3a		  :
	ld b,c			;5718	41		A
	ld b,d			;5719	42		B
	ld c,a			;571a	4f		O
l571bh:
	ld d,d			;571b	52		R
	ld d,h			;571c	54		T
	ld b,l			;571d	45		E
	ld b,h			;571e	44		D
	jr nz,l5774h		;571f	20 53		  S
	ld b,l			;5721	45		E
	ld b,l			;5722	45		E
l5723h:
	ld c,e			;5723	4b		K
	jr nz,l5769h		;5724	20 43		  C
	ld c,a			;5726	4f		O
	ld c,l			;5727	4d		M
	ld c,l			;5728	4d		M
	ld b,c			;5729	41		A
	ld c,(hl)		;572a	4e		N
	ld b,h			;572b	44		D
	jr nz,$+60		;572c	20 3a		  :
	ld b,c			;572e	41		A
	ld b,d			;572f	42		B
l5730h:
	ld c,a			;5730	4f		O
	ld d,d			;5731	52		R
	ld d,h			;5732	54		T
	ld b,l			;5733	45		E
	ld b,h			;5734	44		D
	jr nz,l578eh		;5735	20 57		  W
	ld d,d			;5737	52		R
	ld c,c			;5738	49		I
	ld d,h			;5739	54		T
	ld b,l			;573a	45		E
	jr nz,l5780h		;573b	20 43		  C
	ld c,a			;573d	4f		O
	ld c,l			;573e	4d		M
	ld c,l			;573f	4d		M
	ld b,c			;5740	41		A
	ld c,(hl)		;5741	4e		N
l5742h:
	ld b,h			;5742	44		D
	jr nz,l577fh		;5743	20 3a		  :
	ld b,c			;5745	41		A
	ld b,d			;5746	42		B
	ld c,a			;5747	4f		O
	ld d,d			;5748	52		R
	ld d,h			;5749	54		T
	ld b,l			;574a	45		E
	ld b,h			;574b	44		D
	jr nz,l57a0h		;574c	20 52		  R
	ld b,l			;574e	45		E
	ld b,c			;574f	41		A
	ld b,h			;5750	44		D
	jr nz,l5796h		;5751	20 43		  C
	ld c,a			;5753	4f		O
	ld c,l			;5754	4d		M
	ld c,l			;5755	4d		M
l5756h:
	ld b,c			;5756	41		A
	ld c,(hl)		;5757	4e		N
l5758h:
	ld b,h			;5758	44		D
	jr nz,l5795h		;5759	20 3a		  :
	ld c,c			;575b	49		I
l575ch:
	ld b,h			;575c	44		D
	jr nz,$+80		;575d	20 4e		  N
	ld c,a			;575f	4f		O
	ld d,h			;5760	54		T
	jr nz,l57a9h		;5761	20 46		  F
	ld c,a			;5763	4f		O
	ld d,l			;5764	55		U
	ld c,(hl)		;5765	4e		N
	ld b,h			;5766	44		D
	jr nz,l57a3h		;5767	20 3a		  :
l5769h:
	ld b,e			;5769	43		C
	ld d,d			;576a	52		R
	ld b,e			;576b	43		C
	jr nz,$+71		;576c	20 45		  E
	ld d,d			;576e	52		R
	ld d,d			;576f	52		R
	ld c,a			;5770	4f		O
	ld d,d			;5771	52		R
	jr nz,l57bdh		;5772	20 49		  I
l5774h:
	ld c,(hl)		;5774	4e		N
	jr nz,$+75		;5775	20 49		  I
	ld b,h			;5777	44		D
	jr nz,l57b4h		;5778	20 3a		  :
	ld b,e			;577a	43		C
	ld d,d			;577b	52		R
	ld b,e			;577c	43		C
	jr nz,l57c4h		;577d	20 45		  E
l577fh:
	ld d,d			;577f	52		R
l5780h:
	ld d,d			;5780	52		R
	ld c,a			;5781	4f		O
	ld d,d			;5782	52		R
	jr nz,l57ceh		;5783	20 49		  I
	ld c,(hl)		;5785	4e		N
	jr nz,l57cch		;5786	20 44		  D
	ld b,c			;5788	41		A
	ld d,h			;5789	54		T
	ld b,c			;578a	41		A
	jr nz,l57c7h		;578b	20 3a		  :
	ld d,l			;578d	55		U
l578eh:
	ld c,(hl)		;578e	4e		N
	ld b,e			;578f	43		C
	ld c,a			;5790	4f		O
	ld d,d			;5791	52		R
	ld d,d			;5792	52		R
	ld b,l			;5793	45		E
	ld b,e			;5794	43		C
l5795h:
	ld d,h			;5795	54		T
l5796h:
	ld b,c			;5796	41		A
	ld b,d			;5797	42		B
	ld c,h			;5798	4c		L
	ld b,l			;5799	45		E
	jr nz,l57d6h		;579a	20 3a		  :
	ld b,e			;579c	43		C
	ld c,a			;579d	4f		O
	ld d,d			;579e	52		R
	ld d,d			;579f	52		R
l57a0h:
	ld b,l			;57a0	45		E
	ld b,e			;57a1	43		C
	ld d,h			;57a2	54		T
l57a3h:
	ld b,c			;57a3	41		A
	ld b,d			;57a4	42		B
	ld c,h			;57a5	4c		L
	ld b,l			;57a6	45		E
	jr nz,l57e3h		;57a7	20 3a		  :
l57a9h:
	ld b,d			;57a9	42		B
	ld b,c			;57aa	41		A
	ld b,h			;57ab	44		D
	jr nz,l57f0h		;57ac	20 42		  B
	ld c,h			;57ae	4c		L
	ld c,a			;57af	4f		O
	ld b,e			;57b0	43		C
	ld c,e			;57b1	4b		K
	jr nz,l57f8h		;57b2	20 44		  D
l57b4h:
	ld b,l			;57b4	45		E
	ld d,h			;57b5	54		T
	ld b,l			;57b6	45		E
	ld b,e			;57b7	43		C
	ld d,h			;57b8	54		T
	jr nz,l5800h		;57b9	20 45		  E
	ld d,d			;57bb	52		R
	ld d,d			;57bc	52		R
l57bdh:
	ld c,a			;57bd	4f		O
	ld d,d			;57be	52		R
	jr nz,l57fbh		;57bf	20 3a		  :
	ld d,a			;57c1	57		W
	ld b,h			;57c2	44		D
	ld b,e			;57c3	43		C
l57c4h:
	jr nz,$+71		;57c4	20 45		  E
	ld d,d			;57c6	52		R
l57c7h:
	ld d,d			;57c7	52		R
	ld c,a			;57c8	4f		O
	ld d,d			;57c9	52		R
	jr nz,$+60		;57ca	20 3a		  :
l57cch:
	ld d,h			;57cc	54		T
	ld c,c			;57cd	49		I
l57ceh:
	ld c,l			;57ce	4d		M
	ld b,l			;57cf	45		E
	ld c,a			;57d0	4f		O
	ld d,l			;57d1	55		U
	ld d,h			;57d2	54		T
	jr nz,$+60		;57d3	20 3a		  :
	ld b,e			;57d5	43		C
l57d6h:
	ld d,d			;57d6	52		R
	ld b,e			;57d7	43		C
	cpl			;57d8	2f		/
	ld b,l			;57d9	45		E
	ld b,e			;57da	43		C
	ld b,e			;57db	43		C
	jr nz,$+84		;57dc	20 52		  R
	ld b,l			;57de	45		E
	ld b,c			;57df	41		A
	ld b,h			;57e0	44		D
	ld c,c			;57e1	49		I
	ld c,(hl)		;57e2	4e		N
l57e3h:
	ld b,a			;57e3	47		G
	jr nz,$+71		;57e4	20 45		  E
	ld d,d			;57e6	52		R
	ld d,d			;57e7	52		R
	ld c,a			;57e8	4f		O
	ld d,d			;57e9	52		R
	jr nz,l5826h		;57ea	20 3a		  :
	ld b,l			;57ec	45		E
	ld d,d			;57ed	52		R
	ld d,d			;57ee	52		R
	ld c,a			;57ef	4f		O
l57f0h:
	ld d,d			;57f0	52		R
	ld d,e			;57f1	53		S
	ld d,e			;57f2	53		S
	ld b,l			;57f3	45		E
	ld b,l			;57f4	45		E
	ld c,e			;57f5	4b		K
l57f6h:
	jr nz,$+71		;57f6	20 45		  E
l57f8h:
	ld d,d			;57f8	52		R
	ld d,d			;57f9	52		R
	ld c,a			;57fa	4f		O
l57fbh:
	ld d,d			;57fb	52		R
	jr nz,l5838h		;57fc	20 3a		  :
	ld d,d			;57fe	52		R
	ld b,l			;57ff	45		E
l5800h:
	djnz l57f6h		;5800	10 f4		. .
	call sub_3d6dh		;5802	cd 6d 3d	. m =
	jp l4253h		;5805	c3 53 42	. S B
	in a,(061h)		;5808	db 61		. a
	bit 7,a			;580a	cb 7f		. .
	jr z,l5826h		;580c	28 18		( .
	ld hl,(0d0aah)		;580e	2a aa d0	* . .
	inc hl			;5811	23		#
	ld (0d0aah),hl		;5812	22 aa d0	" . .
	ld ix,0f47eh		;5815	dd 21 7e f4	. ! ~ .
	call 01134h		;5819	cd 34 11	. 4 .
	ld ix,0f460h		;581c	dd 21 60 f4	. ! ` .
	call sub_3d6dh		;5820	cd 6d 3d	. m =
	jp l4253h		;5823	c3 53 42	. S B
l5826h:
	ld hl,(0d0aeh)		;5826	2a ae d0	* . .
	inc hl			;5829	23		#
	ld (0d0aeh),hl		;582a	22 ae d0	" . .
	ld ix,0f56eh		;582d	dd 21 6e f5	. ! n .
	call 01134h		;5831	cd 34 11	. 4 .
	ld ix,0f550h		;5834	dd 21 50 f5	. ! P .
l5838h:
	call sub_3d6dh		;5838	cd 6d 3d	. m =
	jp l4253h		;583b	c3 53 42	. S B
	di			;583e	f3		.
	call 03dd3h		;583f	cd d3 3d	. . =
	ld hl,03a40h		;5842	21 40 3a	! @ :
	ld de,0f01fh		;5845	11 1f f0	. . .
	ld bc,00014h		;5848	01 14 00	. . .
	ldir			;584b	ed b0		. .
	call 00264h		;584d	cd 64 02	. d .
	ld hl,00258h		;5850	21 58 02	! X .
	ld a,l			;5853	7d		}
	out (012h),a		;5854	d3 12		. .
	ld a,04fh		;5856	3e 4f		> O
	out (012h),a		;5858	d3 12		. .
	ld a,087h		;585a	3e 87		> .
	out (012h),a		;585c	d3 12		. .
	in a,(010h)		;585e	db 10		. .
	ld a,003h		;5860	3e 03		> .
	out (00ch),a		;5862	d3 0c		. .
	out (00dh),a		;5864	d3 0d		. .
	out (00eh),a		;5866	d3 0e		. .
	out (00fh),a		;5868	d3 0f		. .
	out (044h),a		;586a	d3 44		. D
	out (045h),a		;586c	d3 45		. E
	out (046h),a		;586e	d3 46		. F
	out (047h),a		;5870	d3 47		. G
	ld hl,00210h		;5872	21 10 02	! . .
	ld a,l			;5875	7d		}
	out (044h),a		;5876	d3 44		. D
	ld hl,00000h		;5878	21 00 00	! . .
	ld (0d014h),hl		;587b	22 14 d0	" . .
	ld (0d016h),hl		;587e	22 16 d0	" . .
	ld (0d018h),hl		;5881	22 18 d0	" . .
	ld (0d06eh),hl		;5884	22 6e d0	" n .
l5887h:
	ld a,00ch		;5887	3e 0c		> .
	ld (0d096h),a		;5889	32 96 d0	2 . .
	ld hl,03acfh		;588c	21 cf 3a	! . :
	ld de,0f0f0h		;588f	11 f0 f0	. . .
	ld bc,00014h		;5892	01 14 00	. . .
	ldir			;5895	ed b0		. .
	ei			;5897	fb		.
	halt			;5898	76		v
	di			;5899	f3		.
	cp 03fh			;589a	fe 3f		. ?
	jr z,l5887h		;589c	28 e9		( .
l589eh:
	ld a,001h		;589e	3e 01		> .
	ld (0d096h),a		;58a0	32 96 d0	2 . .
	ld hl,l3a54h		;58a3	21 54 3a	! T :
	ld de,0f140h		;58a6	11 40 f1	. @ .
	ld bc,0000bh		;58a9	01 0b 00	. . .
	ldir			;58ac	ed b0		. .
	ei			;58ae	fb		.
	halt			;58af	76		v
	cp 03fh			;58b0	fe 3f		. ?
	jr z,l589eh		;58b2	28 ea		( .
l58b4h:
	ld a,002h		;58b4	3e 02		> .
	ld (0d096h),a		;58b6	32 96 d0	2 . .
	ld hl,03a5fh		;58b9	21 5f 3a	! _ :
	ld de,0f190h		;58bc	11 90 f1	. . .
	ld bc,00009h		;58bf	01 09 00	. . .
	ldir			;58c2	ed b0		. .
	ei			;58c4	fb		.
	halt			;58c5	76		v
	cp 03fh			;58c6	fe 3f		. ?
	jr z,l58b4h		;58c8	28 ea		( .
l58cah:
	ld a,00ah		;58ca	3e 0a		> .
	ld (0d096h),a		;58cc	32 96 d0	2 . .
	ld hl,l3a68h		;58cf	21 68 3a	! h :
	ld de,0f1e0h		;58d2	11 e0 f1	. . .
	ld bc,0000ch		;58d5	01 0c 00	. . .
	ldir			;58d8	ed b0		. .
	ei			;58da	fb		.
	halt			;58db	76		v
	cp 03fh			;58dc	fe 3f		. ?
	jr z,l58cah		;58de	28 ea		( .
l58e0h:
	ld a,003h		;58e0	3e 03		> .
	ld (0d096h),a		;58e2	32 96 d0	2 . .
	ei			;58e5	fb		.
	halt			;58e6	76		v
	cp 03fh			;58e7	fe 3f		. ?
	jr z,l58e0h		;58e9	28 f5		( .
l58ebh:
	ld a,004h		;58eb	3e 04		> .
	ld (0d096h),a		;58ed	32 96 d0	2 . .
	ei			;58f0	fb		.
	halt			;58f1	76		v
	cp 03fh			;58f2	fe 3f		. ?
	jr z,l58ebh		;58f4	28 f5		( .
l58f6h:
	ld a,00bh		;58f6	3e 0b		> .
	ld (0d096h),a		;58f8	32 96 d0	2 . .
	ld hl,03a74h		;58fb	21 74 3a	! t :
	ld de,0f230h		;58fe	11 30 f2	. 0 .
	ld bc,0000ah		;5901	01 0a 00	. . .
	ldir			;5904	ed b0		. .
	ei			;5906	fb		.
	halt			;5907	76		v
	cp 03fh			;5908	fe 3f		. ?
	jr z,l58f6h		;590a	28 ea		( .
l590ch:
	ld a,005h		;590c	3e 05		> .
	ld (0d096h),a		;590e	32 96 d0	2 . .
	ei			;5911	fb		.
	halt			;5912	76		v
	cp 03fh			;5913	fe 3f		. ?
	jr z,l590ch		;5915	28 f5		( .
l5917h:
	ld a,006h		;5917	3e 06		> .
	ld (0d096h),a		;5919	32 96 d0	2 . .
	ei			;591c	fb		.
	halt			;591d	76		v
	cp 03fh			;591e	fe 3f		. ?
	jr z,l5917h		;5920	28 f5		( .
l5922h:
	ld a,007h		;5922	3e 07		> .
	ld (0d096h),a		;5924	32 96 d0	2 . .
	ld hl,03a7eh		;5927	21 7e 3a	! ~ :
	ld de,0f280h		;592a	11 80 f2	. . .
	ld bc,00015h		;592d	01 15 00	. . .
	ldir			;5930	ed b0		. .
	ei			;5932	fb		.
	halt			;5933	76		v
	cp 03fh			;5934	fe 3f		. ?
	jr z,l5922h		;5936	28 ea		( .
l5938h:
	ld a,008h		;5938	3e 08		> .
	ld (0d096h),a		;593a	32 96 d0	2 . .
	ld hl,l3a93h		;593d	21 93 3a	! . :
	ld de,0f2d0h		;5940	11 d0 f2	. . .
	ld bc,00027h		;5943	01 27 00	. ' .
	ldir			;5946	ed b0		. .
	ei			;5948	fb		.
	halt			;5949	76		v
	cp 03fh			;594a	fe 3f		. ?
	jr z,l5938h		;594c	28 ea		( .
l594eh:
	ld a,009h		;594e	3e 09		> .
	ld (0d096h),a		;5950	32 96 d0	2 . .
	ld hl,l3abah		;5953	21 ba 3a	! . :
	ld de,0f320h		;5956	11 20 f3	.   .
	ld bc,00015h		;5959	01 15 00	. . .
	ldir			;595c	ed b0		. .
	ei			;595e	fb		.
	halt			;595f	76		v
	di			;5960	f3		.
	cp 03fh			;5961	fe 3f		. ?
	jr z,l594eh		;5963	28 e9		( .
	ld a,0d7h		;5965	3e d7		> .
	out (044h),a		;5967	d3 44		. D
	ld a,001h		;5969	3e 01		> .
	out (044h),a		;596b	d3 44		. D
	ld a,(0d004h)		;596d	3a 04 d0	: . .
	ld b,a			;5970	47		G
	ld a,(0d006h)		;5971	3a 06 d0	: . .
	cp b			;5974	b8		.
	jr nc,l597eh		;5975	30 07		0 .
	ld (0d004h),a		;5977	32 04 d0	2 . .
	ld a,b			;597a	78		x
	ld (0d006h),a		;597b	32 06 d0	2 . .
l597eh:
	ld de,(0d00ah)		;597e	ed 5b 0a d0	. [ . .
	ld hl,(0d00ch)		;5982	2a 0c d0	* . .
	sbc hl,de		;5985	ed 52		. R
	jr nc,l5997h		;5987	30 0e		0 .
	ld de,(0d00ah)		;5989	ed 5b 0a d0	. [ . .
	ld hl,(0d00ch)		;598d	2a 0c d0	* . .
	ld (0d00ah),hl		;5990	22 0a d0	" . .
	ld (0d00ch),de		;5993	ed 53 0c d0	. S . .
l5997h:
	ld de,(0d00ch)		;5997	ed 5b 0c d0	. [ . .
	ld hl,(0d0b2h)		;599b	2a b2 d0	* . .
	sbc hl,de		;599e	ed 52		. R
	jp nc,l45bbh		;59a0	d2 bb 45	. . E
	ld hl,(0d0b2h)		;59a3	2a b2 d0	* . .
	ld (0d00ch),hl		;59a6	22 0c d0	" . .
	ld de,(0d00ah)		;59a9	ed 5b 0a d0	. [ . .
	ld hl,(0d0b2h)		;59ad	2a b2 d0	* . .
	sbc hl,de		;59b0	ed 52		. R
	jp nc,l45bbh		;59b2	d2 bb 45	. . E
	ld hl,(0d0b2h)		;59b5	2a b2 d0	* . .
	ld (0d00ah),hl		;59b8	22 0a d0	" . .
	ld a,00fh		;59bb	3e 0f		> .
	ld (0d096h),a		;59bd	32 96 d0	2 . .
	call 03dd3h		;59c0	cd d3 3d	. . =
	call 03e5ah		;59c3	cd 5a 3e	. Z >
	ld a,(0d07ah)		;59c6	3a 7a d0	: z .
	cp 000h			;59c9	fe 00		. .
	call nz,sub_3ef2h	;59cb	c4 f2 3e	. . >
	jp l47b5h		;59ce	c3 b5 47	. . G
	ld a,(0d08ah)		;59d1	3a 8a d0	: . .
	cp 000h			;59d4	fe 00		. .
	jr nz,l59e5h		;59d6	20 0d		  .
	ld hl,03a40h		;59d8	21 40 3a	! @ :
	ld de,0f01fh		;59db	11 1f f0	. . .
	ld bc,00014h		;59de	01 14 00	. . .
	ldir			;59e1	ed b0		. .
	jr l59f0h		;59e3	18 0b		. .
l59e5h:
	ld hl,03cabh		;59e5	21 ab 3c	! . <
	ld de,0f024h		;59e8	11 24 f0	. $ .
	ld bc,00009h		;59eb	01 09 00	. . .
	ldir			;59ee	ed b0		. .
l59f0h:
	ld hl,l3ae3h		;59f0	21 e3 3a	! . :
	ld de,0f0a0h		;59f3	11 a0 f0	. . .
	ld bc,00006h		;59f6	01 06 00	. . .
	ldir			;59f9	ed b0		. .
	ld hl,l3bech		;59fb	21 ec 3b	! . ;
	ld de,l53beh		;59fe	11 be 53	. . S
	ld d,h			;5a01	54		T
	ld c,a			;5a02	4f		O
	ld d,d			;5a03	52		R
	ld b,l			;5a04	45		E
	jr nz,l5a5bh		;5a05	20 54		  T
	ld c,c			;5a07	49		I
	ld c,l			;5a08	4d		M
	ld b,l			;5a09	45		E
	ld c,a			;5a0a	4f		O
	ld d,l			;5a0b	55		U
	ld d,h			;5a0c	54		T
	ld d,e			;5a0d	53		S
	ld b,l			;5a0e	45		E
	ld b,l			;5a0f	45		E
	ld c,e			;5a10	4b		K
	ld d,d			;5a11	52		R
	ld b,l			;5a12	45		E
	ld b,c			;5a13	41		A
	ld b,h			;5a14	44		D
	jr nz,$+71		;5a15	20 45		  E
	ld d,d			;5a17	52		R
	ld d,d			;5a18	52		R
	ld c,a			;5a19	4f		O
	ld d,d			;5a1a	52		R
	jr nz,l5a57h		;5a1b	20 3a		  :
	ld d,a			;5a1d	57		W
	ld d,d			;5a1e	52		R
	ld c,c			;5a1f	49		I
	ld d,h			;5a20	54		T
	ld b,l			;5a21	45		E
	jr nz,l5a69h		;5a22	20 45		  E
	ld d,d			;5a24	52		R
	ld d,d			;5a25	52		R
	ld c,a			;5a26	4f		O
	ld d,d			;5a27	52		R
	jr nz,l5a64h		;5a28	20 3a		  :
	ld c,b			;5a2a	48		H
	ld b,l			;5a2b	45		E
	ld b,c			;5a2c	41		A
	ld b,h			;5a2d	44		D
	ld b,e			;5a2e	43		C
	ld e,c			;5a2f	59		Y
	ld c,h			;5a30	4c		L
	ld c,c			;5a31	49		I
	ld c,(hl)		;5a32	4e		N
	ld b,h			;5a33	44		D
	ld b,l			;5a34	45		E
	ld d,d			;5a35	52		R
	ld d,e			;5a36	53		S
	ld b,l			;5a37	45		E
	ld b,e			;5a38	43		C
	ld d,h			;5a39	54		T
	ld c,a			;5a3a	4f		O
	ld d,d			;5a3b	52		R
	ld b,e			;5a3c	43		C
	ld d,l			;5a3d	55		U
	ld d,d			;5a3e	52		R
	ld d,d			;5a3f	52		R
	ld b,l			;5a40	45		E
	ld c,(hl)		;5a41	4e		N
	ld d,h			;5a42	54		T
	jr nz,$+60		;5a43	20 3a		  :
	ld b,(hl)		;5a45	46		F
	ld c,a			;5a46	4f		O
	ld d,d			;5a47	52		R
	ld c,l			;5a48	4d		M
	ld b,c			;5a49	41		A
	ld d,h			;5a4a	54		T
	ld d,h			;5a4b	54		T
	ld c,c			;5a4c	49		I
	ld c,(hl)		;5a4d	4e		N
	ld b,a			;5a4e	47		G
	ld h,(hl)		;5a4f	66		f
	ld l,a			;5a50	6f		o
	ld (hl),d		;5a51	72		r
	ld l,l			;5a52	6d		m
	ld h,c			;5a53	61		a
	ld (hl),h		;5a54	74		t
	jr nz,l5abch		;5a55	20 65		  e
l5a57h:
	ld (hl),d		;5a57	72		r
	ld (hl),d		;5a58	72		r
	ld l,a			;5a59	6f		o
	ld (hl),d		;5a5a	72		r
l5a5bh:
	jr nz,l5a97h		;5a5b	20 3a		  :
	ld (hl),d		;5a5d	72		r
	ld h,l			;5a5e	65		e
	ld h,e			;5a5f	63		c
	ld h,c			;5a60	61		a
	ld l,h			;5a61	6c		l
	ld l,c			;5a62	69		i
	ld h,d			;5a63	62		b
l5a64h:
	ld (hl),d		;5a64	72		r
	ld h,c			;5a65	61		a
	ld (hl),h		;5a66	74		t
	ld l,c			;5a67	69		i
	ld l,a			;5a68	6f		o
l5a69h:
	ld l,(hl)		;5a69	6e		n
	jr nz,l5ad1h		;5a6a	20 65		  e
	ld (hl),d		;5a6c	72		r
	ld (hl),d		;5a6d	72		r
	ld l,a			;5a6e	6f		o
	ld (hl),d		;5a6f	72		r
	ld l,020h		;5a70	2e 20		.  
	ld d,b			;5a72	50		P
	ld d,d			;5a73	52		R
	ld b,l			;5a74	45		E
	ld d,e			;5a75	53		S
	ld d,e			;5a76	53		S
	jr nz,$+84		;5a77	20 52		  R
	ld b,l			;5a79	45		E
	ld d,h			;5a7a	54		T
	ld d,l			;5a7b	55		U
	ld d,d			;5a7c	52		R
	ld c,(hl)		;5a7d	4e		N
	jr nz,l5ad4h		;5a7e	20 54		  T
	ld c,a			;5a80	4f		O
	jr nz,$+86		;5a81	20 54		  T
	ld d,d			;5a83	52		R
	ld e,c			;5a84	59		Y
	jr nz,$+67		;5a85	20 41		  A
	ld b,a			;5a87	47		G
	ld b,c			;5a88	41		A
	ld c,c			;5a89	49		I
	ld c,(hl)		;5a8a	4e		N
	ld c,b			;5a8b	48		H
	ld b,c			;5a8c	41		A
	ld c,h			;5a8d	4c		L
	ld d,h			;5a8e	54		T
	ld b,l			;5a8f	45		E
	ld b,h			;5a90	44		D
	jr nz,$+114		;5a91	20 70		  p
	ld (hl),d		;5a93	72		r
	ld h,l			;5a94	65		e
	ld (hl),e		;5a95	73		s
	ld (hl),e		;5a96	73		s
l5a97h:
	jr nz,$+84		;5a97	20 52		  R
	ld b,l			;5a99	45		E
	ld d,h			;5a9a	54		T
	ld d,l			;5a9b	55		U
	ld d,d			;5a9c	52		R
	ld c,(hl)		;5a9d	4e		N
	jr nz,$+118		;5a9e	20 74		  t
	ld l,a			;5aa0	6f		o
	jr nz,$+118		;5aa1	20 74		  t
	ld (hl),d		;5aa3	72		r
	ld a,c			;5aa4	79		y
	jr nz,$+99		;5aa5	20 61		  a
	ld h,a			;5aa7	67		g
	ld h,c			;5aa8	61		a
	ld l,c			;5aa9	69		i
	ld l,(hl)		;5aaa	6e		n
	ld b,h			;5aab	44		D
	ld c,c			;5aac	49		I
	ld d,e			;5aad	53		S
	ld c,e			;5aae	4b		K
	jr nz,$+86		;5aaf	20 54		  T
	ld b,l			;5ab1	45		E
	ld d,e			;5ab2	53		S
	ld d,h			;5ab3	54		T
	ld a,004h		;5ab4	3e 04		> .
	out (0fah),a		;5ab6	d3 fa		. .
	ld a,048h		;5ab8	3e 48		> H
	out (0fbh),a		;5aba	d3 fb		. .
l5abch:
	out (0fch),a		;5abc	d3 fc		. .
	ld a,000h		;5abe	3e 00		> .
	out (0f0h),a		;5ac0	d3 f0		. .
	ld a,0e0h		;5ac2	3e e0		> .
	out (0f0h),a		;5ac4	d3 f0		. .
l5ac6h:
	ld hl,001ffh		;5ac6	21 ff 01	! . .
	ld a,l			;5ac9	7d		}
	out (0f1h),a		;5aca	d3 f1		. .
	ld a,h			;5acc	7c		|
	out (0f1h),a		;5acd	d3 f1		. .
	ld a,000h		;5acf	3e 00		> .
l5ad1h:
	out (0fah),a		;5ad1	d3 fa		. .
	ret			;5ad3	c9		.
l5ad4h:
	ld a,004h		;5ad4	3e 04		> .
	out (0fah),a		;5ad6	d3 fa		. .
	ld a,044h		;5ad8	3e 44		> D
	out (0fbh),a		;5ada	d3 fb		. .
	out (0fch),a		;5adc	d3 fc		. .
	ld a,000h		;5ade	3e 00		> .
	out (0f0h),a		;5ae0	d3 f0		. .
	ld a,0e2h		;5ae2	3e e2		> .
	out (0f0h),a		;5ae4	d3 f0		. .
	jr l5ac6h		;5ae6	18 de		. .
l5ae8h:
	in a,(067h)		;5ae8	db 67		. g
	bit 7,a			;5aea	cb 7f		. .
	jr nz,l5ae8h		;5aec	20 fa		  .
	ld a,(0d014h)		;5aee	3a 14 d0	: . .
	or 020h			;5af1	f6 20		.  
	ld b,a			;5af3	47		G
	ld a,(0d06ah)		;5af4	3a 6a d0	: j .
	cp 001h			;5af7	fe 01		. .
	ld a,b			;5af9	78		x
	jr z,l5b00h		;5afa	28 04		( .
	out (066h),a		;5afc	d3 66		. f
	jr l5b04h		;5afe	18 04		. .
l5b00h:
	set 7,a			;5b00	cb ff		. .
	out (066h),a		;5b02	d3 66		. f
l5b04h:
	ld a,(0d018h)		;5b04	3a 18 d0	: . .
	out (063h),a		;5b07	d3 63		. c
	ld hl,(0d016h)		;5b09	2a 16 d0	* . .
	ld a,l			;5b0c	7d		}
	out (064h),a		;5b0d	d3 64		. d
	ld a,h			;5b0f	7c		|
	out (065h),a		;5b10	d3 65		. e
	ret			;5b12	c9		.
	ld hl,03d1fh		;5b13	21 1f 3d	! . =
	ld de,0e000h		;5b16	11 00 e0	. . .
	ld bc,00022h		;5b19	01 22 00	. " .
	ldir			;5b1c	ed b0		. .
	ret			;5b1e	c9		.
	nop			;5b1f	00		.
	nop			;5b20	00		.
	nop			;5b21	00		.
	dec c			;5b22	0d		.
	nop			;5b23	00		.
	add hl,bc		;5b24	09		.
	nop			;5b25	00		.
	dec b			;5b26	05		.
	nop			;5b27	00		.
	ld bc,00e00h		;5b28	01 00 0e	. . .
	nop			;5b2b	00		.
	ld a,(bc)		;5b2c	0a		.
	nop			;5b2d	00		.
	ld b,000h		;5b2e	06 00		. .
	ld (bc),a		;5b30	02		.
	nop			;5b31	00		.
	rrca			;5b32	0f		.
	nop			;5b33	00		.
	dec bc			;5b34	0b		.
	nop			;5b35	00		.
	rlca			;5b36	07		.
	nop			;5b37	00		.
	inc bc			;5b38	03		.
	nop			;5b39	00		.
	djnz l5b3ch		;5b3a	10 00		. .
l5b3ch:
	inc c			;5b3c	0c		.
	nop			;5b3d	00		.
	ex af,af'		;5b3e	08		.
	nop			;5b3f	00		.
	inc b			;5b40	04		.
	jr nc,$+51		;5b41	30 31		0 1
	ld (03433h),a		;5b43	32 33 34	2 3 4
	dec (hl)		;5b46	35		5
	ld (hl),037h		;5b47	36 37		6 7
	jr c,$+59		;5b49	38 39		8 9
	nop			;5b4b	00		.
	ld bc,00302h		;5b4c	01 02 03	. . .
	inc b			;5b4f	04		.
	dec b			;5b50	05		.
	ld b,007h		;5b51	06 07		. .
	ex af,af'		;5b53	08		.
	add hl,bc		;5b54	09		.
	ld hl,03d41h		;5b55	21 41 3d	! A =
	ld bc,0000ah		;5b58	01 0a 00	. . .
	cpir			;5b5b	ed b1		. .
	jr nz,l5b6ah		;5b5d	20 0b		  .
	ld (0d076h),hl		;5b5f	22 76 d0	" v .
	ld ix,(0d076h)		;5b62	dd 2a 76 d0	. * v .
	ld a,(ix+009h)		;5b66	dd 7e 09	. ~ .
	ret			;5b69	c9		.
l5b6ah:
	ld a,0ffh		;5b6a	3e ff		> .
	ret			;5b6c	c9		.
	call sub_3da3h		;5b6d	cd a3 3d	. . =
	ld a,(0d008h)		;5b70	3a 08 d0	: . .
	cp 005h			;5b73	fe 05		. .
	jr z,l5b8dh		;5b75	28 16		( .
	ld hl,(0d07eh)		;5b77	2a 7e d0	* ~ .
	inc hl			;5b7a	23		#
	ld (0d07eh),hl		;5b7b	22 7e d0	" ~ .
	ld ix,0f6aeh		;5b7e	dd 21 ae f6	. ! . .
	call 01134h		;5b82	cd 34 11	. 4 .
	ld ix,0f690h		;5b85	dd 21 90 f6	. ! . .
	call sub_3da3h		;5b89	cd a3 3d	. . =
	ret			;5b8c	c9		.
l5b8dh:
	ld hl,(0d082h)		;5b8d	2a 82 d0	* . .
	inc hl			;5b90	23		#
	ld (0d082h),hl		;5b91	22 82 d0	" . .
	ld ix,0f6feh		;5b94	dd 21 fe f6	. ! . .
	call 01134h		;5b98	cd 34 11	. 4 .
	ld ix,0f6e0h		;5b9b	dd 21 e0 f6	. ! . .
	call sub_3da3h		;5b9f	cd a3 3d	. . =
	ret			;5ba2	c9		.
	push ix			;5ba3	dd e5		. .
	ld de,00005h		;5ba5	11 05 00	. . .
	ld b,009h		;5ba8	06 09		. .
l5baah:
	add ix,de		;5baa	dd 19		. .
	djnz l5baah		;5bac	10 fc		. .
	ld hl,(0d014h)		;5bae	2a 14 d0	* . .
	call 01134h		;5bb1	cd 34 11	. 4 .
	pop ix			;5bb4	dd e1		. .
	push ix			;5bb6	dd e5		. .
	ld b,00bh		;5bb8	06 0b		. .
l5bbah:
	add ix,de		;5bba	dd 19		. .
	djnz l5bbah		;5bbc	10 fc		. .
	ld hl,(0d016h)		;5bbe	2a 16 d0	* . .
	call 01134h		;5bc1	cd 34 11	. 4 .
	pop ix			;5bc4	dd e1		. .
	ld b,00dh		;5bc6	06 0d		. .
l5bc8h:
	add ix,de		;5bc8	dd 19		. .
	djnz l5bc8h		;5bca	10 fc		. .
	ld hl,(0d018h)		;5bcc	2a 18 d0	* . .
	call 01134h		;5bcf	cd 34 11	. 4 .
	ret			;5bd2	c9		.
	ld hl,0f000h		;5bd3	21 00 f0	! . .
	ld de,0f001h		;5bd6	11 01 f0	. . .
	ld (hl),020h		;5bd9	36 20		6  
	ld bc,007cfh		;5bdb	01 cf 07	. . .
	ldir			;5bde	ed b0		. .
	ret			;5be0	c9		.
	ld hl,0f532h		;5be1	21 32 f5	! 2 .
	ld de,0f533h		;5be4	11 33 f5	. 3 .
	ld (hl),020h		;5be7	36 20		6  
	ld bc,0001dh		;5be9	01 1d 00	. . .
	ldir			;5bec	ed b0		. .
	ret			;5bee	c9		.
	ld bc,00200h		;5bef	01 00 02	. . .
	ld hl,0e000h		;5bf2	21 00 e0	! . .
	ld de,0e200h		;5bf5	11 00 e2	. . .
	ld a,(de)		;5bf8	1a		.
	cp (hl)			;5bf9	be		.
	ret nz			;5bfa	c0		.
	inc hl			;5bfb	23		#
	inc de			;5bfc	13		.
	dec bc			;5bfd	0b		.
	ld a,c			;5bfe	79		y
	cp 0f0h			;5bff	fe f0		. .
	ld bc,00006h		;5c01	01 06 00	. . .
	ldir			;5c04	ed b0		. .
	ld hl,l3c2ah		;5c06	21 2a 3c	! * <
	ld de,0f0ceh		;5c09	11 ce f0	. . .
	ld bc,00004h		;5c0c	01 04 00	. . .
	ldir			;5c0f	ed b0		. .
	ld hl,03c2eh		;5c11	21 2e 3c	! . <
	ld de,0f0d6h		;5c14	11 d6 f0	. . .
	ld bc,00008h		;5c17	01 08 00	. . .
	ldir			;5c1a	ed b0		. .
	ld hl,03c36h		;5c1c	21 36 3c	! 6 <
	ld de,0f0e0h		;5c1f	11 e0 f0	. . .
	ld bc,00006h		;5c22	01 06 00	. . .
	ldir			;5c25	ed b0		. .
	ld bc,00009h		;5c27	01 09 00	. . .
	ld de,0f050h		;5c2a	11 50 f0	. P .
	ld a,(0d06ah)		;5c2d	3a 6a d0	: j .
	cp 000h			;5c30	fe 00		. .
	jr nz,l5c3bh		;5c32	20 07		  .
	ld hl,l3ae9h		;5c34	21 e9 3a	! . :
	ldir			;5c37	ed b0		. .
	jr l5c40h		;5c39	18 05		. .
l5c3bh:
	ld hl,l3af2h		;5c3b	21 f2 3a	! . :
	ldir			;5c3e	ed b0		. .
l5c40h:
	ld hl,l3afbh		;5c40	21 fb 3a	! . :
	ld de,0f140h		;5c43	11 40 f1	. @ .
	ld bc,0001dh		;5c46	01 1d 00	. . .
	ldir			;5c49	ed b0		. .
	ld hl,l3b18h		;5c4b	21 18 3b	! . ;
	ld de,0f190h		;5c4e	11 90 f1	. . .
	ld bc,00016h		;5c51	01 16 00	. . .
	ldir			;5c54	ed b0		. .
	ld hl,l3b2eh		;5c56	21 2e 3b	! . ;
	ld de,0f1e0h		;5c59	11 e0 f1	. . .
	ld bc,00017h		;5c5c	01 17 00	. . .
	ldir			;5c5f	ed b0		. .
	ld hl,03b45h		;5c61	21 45 3b	! E ;
	ld de,0f230h		;5c64	11 30 f2	. 0 .
	ld bc,00016h		;5c67	01 16 00	. . .
	ldir			;5c6a	ed b0		. .
	ld hl,03b5bh		;5c6c	21 5b 3b	! [ ;
	ld de,0f280h		;5c6f	11 80 f2	. . .
	ld bc,0000eh		;5c72	01 0e 00	. . .
	ldir			;5c75	ed b0		. .
	ld hl,03b69h		;5c77	21 69 3b	! i ;
	ld de,0f2d0h		;5c7a	11 d0 f2	. . .
	ld bc,00011h		;5c7d	01 11 00	. . .
	ldir			;5c80	ed b0		. .
	ld hl,03b7ah		;5c82	21 7a 3b	! z ;
	ld de,0f320h		;5c85	11 20 f3	.   .
	ld bc,00013h		;5c88	01 13 00	. . .
	ldir			;5c8b	ed b0		. .
	ld hl,03b9ch		;5c8d	21 9c 3b	! . ;
	ld de,0f370h		;5c90	11 70 f3	. p .
	ld bc,0000dh		;5c93	01 0d 00	. . .
	ldir			;5c96	ed b0		. .
	ld hl,l3b8dh		;5c98	21 8d 3b	! . ;
	ld de,0f3c0h		;5c9b	11 c0 f3	. . .
	ld bc,0000fh		;5c9e	01 0f 00	. . .
	ldir			;5ca1	ed b0		. .
	ld hl,03bd5h		;5ca3	21 d5 3b	! . ;
	ld de,0f410h		;5ca6	11 10 f4	. . .
	ld bc,00017h		;5ca9	01 17 00	. . .
	ldir			;5cac	ed b0		. .
	ld hl,l3ba9h		;5cae	21 a9 3b	! . ;
	ld de,0f460h		;5cb1	11 60 f4	. ` .
	ld bc,00018h		;5cb4	01 18 00	. . .
	ldir			;5cb7	ed b0		. .
	ld hl,03bf2h		;5cb9	21 f2 3b	! . ;
	ld de,0f4b0h		;5cbc	11 b0 f4	. . .
	ld bc,0000ch		;5cbf	01 0c 00	. . .
	ldir			;5cc2	ed b0		. .
	ld hl,l3bcbh+1		;5cc4	21 cc 3b	! . ;
	ld de,0f500h		;5cc7	11 00 f5	. . .
	ld bc,00009h		;5cca	01 09 00	. . .
	ldir			;5ccd	ed b0		. .
	ld hl,l3bc1h		;5ccf	21 c1 3b	! . ;
	ld de,0f550h		;5cd2	11 50 f5	. P .
	ld bc,0000bh		;5cd5	01 0b 00	. . .
	ldir			;5cd8	ed b0		. .
	ld hl,l3c1dh		;5cda	21 1d 3c	! . <
	ld de,0f690h		;5cdd	11 90 f6	. . .
	ld bc,0000dh		;5ce0	01 0d 00	. . .
	ldir			;5ce3	ed b0		. .
	ld hl,03c11h		;5ce5	21 11 3c	! . <
	ld de,0f6e0h		;5ce8	11 e0 f6	. . .
	ld bc,0000ch		;5ceb	01 0c 00	. . .
	ldir			;5cee	ed b0		. .
	ld hl,03c3ch		;5cf0	21 3c 3c	! < <
	ld de,0f780h		;5cf3	11 80 f7	. . .
	ld bc,00009h		;5cf6	01 09 00	. . .
	ldir			;5cf9	ed b0		. .
	ld hl,00000h		;5cfb	21 00 00	! . .
	ld (0d026h),hl		;5cfe	22 26 d0	" & .
	ld (0d098h),hl		;5d01	22 98 d0	" . .
	ld (0d012h),hl		;5d04	22 12 d0	" . .
	ld (0d09ch),hl		;5d07	22 9c d0	" . .
	ld (0d09eh),hl		;5d0a	22 9e d0	" . .
	ld (0d0a0h),hl		;5d0d	22 a0 d0	" . .
	ld (0d0a2h),hl		;5d10	22 a2 d0	" . .
	ld (0d0a4h),hl		;5d13	22 a4 d0	" . .
	ld (0d0a6h),hl		;5d16	22 a6 d0	" . .
	ld (0d0a8h),hl		;5d19	22 a8 d0	" . .
	ld (0d01ah),hl		;5d1c	22 1a d0	" . .
	ld (0d0aah),hl		;5d1f	22 aa d0	" . .
	ld (0d0ach),hl		;5d22	22 ac d0	" . .
	ld (0d0aeh),hl		;5d25	22 ae d0	" . .
	ld (0d068h),hl		;5d28	22 68 d0	" h .
	ld (0d07eh),hl		;5d2b	22 7e d0	" ~ .
	ld (0d082h),hl		;5d2e	22 82 d0	" . .
	ld (0d06eh),hl		;5d31	22 6e d0	" n .
	ld (0d022h),hl		;5d34	22 22 d0	" " .
	ld (0d0b0h),hl		;5d37	22 b0 d0	" . .
	ld hl,00000h		;5d3a	21 00 00	! . .
	ld ix,0f0aah		;5d3d	dd 21 aa f0	. ! . .
	call 01134h		;5d41	cd 34 11	. 4 .
	ld ix,0f15eh		;5d44	dd 21 5e f1	. ! ^ .
	call 01134h		;5d48	cd 34 11	. 4 .
	ld ix,0f1aeh		;5d4b	dd 21 ae f1	. ! . .
	call 01134h		;5d4f	cd 34 11	. 4 .
	ld ix,0f1feh		;5d52	dd 21 fe f1	. ! . .
	call 01134h		;5d56	cd 34 11	. 4 .
	ld ix,0f24eh		;5d59	dd 21 4e f2	. ! N .
	call 01134h		;5d5d	cd 34 11	. 4 .
	ld ix,0f29eh		;5d60	dd 21 9e f2	. ! . .
	call 01134h		;5d64	cd 34 11	. 4 .
	ld ix,0f2eeh		;5d67	dd 21 ee f2	. ! . .
	call 01134h		;5d6b	cd 34 11	. 4 .
	ld ix,0f33eh		;5d6e	dd 21 3e f3	. ! > .
	call 01134h		;5d72	cd 34 11	. 4 .
	ld ix,0f38eh		;5d75	dd 21 8e f3	. ! . .
	call 01134h		;5d79	cd 34 11	. 4 .
	ld ix,0f3deh		;5d7c	dd 21 de f3	. ! . .
	call 01134h		;5d80	cd 34 11	. 4 .
	ld ix,0f42eh		;5d83	dd 21 2e f4	. ! . .
	call 01134h		;5d87	cd 34 11	. 4 .
	ld ix,0f47eh		;5d8a	dd 21 7e f4	. ! ~ .
	call 01134h		;5d8e	cd 34 11	. 4 .
	ld ix,0f4ceh		;5d91	dd 21 ce f4	. ! . .
	call 01134h		;5d95	cd 34 11	. 4 .
	ld ix,0f51eh		;5d98	dd 21 1e f5	. ! . .
	call 01134h		;5d9c	cd 34 11	. 4 .
	ld ix,0f56eh		;5d9f	dd 21 6e f5	. ! n .
	call 01134h		;5da3	cd 34 11	. 4 .
	ld ix,0f6aeh		;5da6	dd 21 ae f6	. ! . .
	call 01134h		;5daa	cd 34 11	. 4 .
	ld ix,0f6feh		;5dad	dd 21 fe f6	. ! . .
	call 01134h		;5db1	cd 34 11	. 4 .
	ret			;5db4	c9		.
	call 03dd3h		;5db5	cd d3 3d	. . =
	call 045d1h		;5db8	cd d1 45	. . E
	ld a,(0d08ah)		;5dbb	3a 8a d0	: . .
	cp 000h			;5dbe	fe 00		. .
	jp nz,l4912h		;5dc0	c2 12 49	. . I
	jp l4817h		;5dc3	c3 17 48	. . H
	ld a,(0d00ah)		;5dc6	3a 0a d0	: . .
	ld (0d092h),a		;5dc9	32 92 d0	2 . .
	ld a,(0d00ch)		;5dcc	3a 0c d0	: . .
	inc a			;5dcf	3c		<
	ld (0d090h),a		;5dd0	32 90 d0	2 . .
	xor a			;5dd3	af		.
	ld (0d014h),a		;5dd4	32 14 d0	2 . .
	ld (0d094h),a		;5dd7	32 94 d0	2 . .
	ld a,(0d092h)		;5dda	3a 92 d0	: . .
	ld (0d016h),a		;5ddd	32 16 d0	2 . .
	call 03ea5h		;5de0	cd a5 3e	. . >
	ld a,(0d094h)		;5de3	3a 94 d0	: . .
	cp 000h			;5de6	fe 00		. .
	jr z,l5dfah		;5de8	28 10		( .
	xor a			;5dea	af		.
	ld (0d094h),a		;5deb	32 94 d0	2 . .
	ld a,(0d092h)		;5dee	3a 92 d0	: . .
	inc a			;5df1	3c		<
	ld (0d092h),a		;5df2	32 92 d0	2 . .
	ld (0d016h),a		;5df5	32 16 d0	2 . .
l5df8h:
	jr $+18			;5df8	18 10		. .
l5dfah:
	ld a,001h		;5dfa	3e 01		> .
	ld (0d094h),a		;5dfc	32 94 d0	2 . .
	ld a,(l2000h)		;5dff	3a 00 20	: .  
	push af			;5e02	f5		.
	ld a,b			;5e03	78		x
	cp 000h			;5e04	fe 00		. .
	jr nz,l5df8h		;5e06	20 f0		  .
	ret			;5e08	c9		.
	ld ix,0e000h		;5e09	dd 21 00 e0	. ! . .
	ld bc,00002h		;5e0d	01 02 00	. . .
l5e10h:
	ld (ix+000h),b		;5e10	dd 70 00	. p .
	inc ix			;5e13	dd 23		. #
	djnz l5e10h		;5e15	10 f9		. .
	dec c			;5e17	0d		.
	jr nz,l5e10h		;5e18	20 f6		  .
	ret			;5e1a	c9		.
	ld ix,0e000h		;5e1b	dd 21 00 e0	. ! . .
	ld bc,00002h		;5e1f	01 02 00	. . .
l5e22h:
	ld a,b			;5e22	78		x
	cpl			;5e23	2f		/
	ld (ix+000h),a		;5e24	dd 77 00	. w .
	inc ix			;5e27	dd 23		. #
	djnz l5e22h		;5e29	10 f7		. .
	dec c			;5e2b	0d		.
	jr nz,l5e22h		;5e2c	20 f4		  .
	ret			;5e2e	c9		.
	push hl			;5e2f	e5		.
	push ix			;5e30	dd e5		. .
	xor a			;5e32	af		.
	ld (0d074h),a		;5e33	32 74 d0	2 t .
	ld (0d024h),a		;5e36	32 24 d0	2 $ .
l5e39h:
	ei			;5e39	fb		.
	ld hl,01388h		;5e3a	21 88 13	! . .
l5e3dh:
	dec hl			;5e3d	2b		+
	ld a,l			;5e3e	7d		}
	or h			;5e3f	b4		.
	jr nz,l5e3dh		;5e40	20 fb		  .
	di			;5e42	f3		.
	pop ix			;5e43	dd e1		. .
	pop hl			;5e45	e1		.
	ld a,(0d024h)		;5e46	3a 24 d0	: $ .
	cp 001h			;5e49	fe 01		. .
	ret z			;5e4b	c8		.
	push hl			;5e4c	e5		.
	push ix			;5e4d	dd e5		. .
	djnz l5e39h		;5e4f	10 e8		. .
	ld a,001h		;5e51	3e 01		> .
	ld (0d074h),a		;5e53	32 74 d0	2 t .
	pop ix			;5e56	dd e1		. .
	pop hl			;5e58	e1		.
	ret			;5e59	c9		.
l5e5ah:
	ld a,001h		;5e5a	3e 01		> .
	ld (0d008h),a		;5e5c	32 08 d0	2 . .
	call 03ce8h		;5e5f	cd e8 3c	. . <
	ld a,016h		;5e62	3e 16		> .
	out (067h),a		;5e64	d3 67		. g
	ld b,0ffh		;5e66	06 ff		. .
	call 03e2fh		;5e68	cd 2f 3e	. / >
	ld a,(0d06eh)		;5e6b	3a 6e d0	: n .
	cp 001h			;5e6e	fe 01		. .
	jr z,l5e90h		;5e70	28 1e		( .
	ld a,(0d074h)		;5e72	3a 74 d0	: t .
	cp 000h			;5e75	fe 00		. .
	jr z,l5e96h		;5e77	28 1d		( .
	ld hl,l3bfeh		;5e79	21 fe 3b	! . ;
	ld de,0f370h		;5e7c	11 70 f3	. p .
	ld bc,0000fh		;5e7f	01 0f 00	. . .
	ldir			;5e82	ed b0		. .
	ld hl,03c8bh		;5e84	21 8b 3c	! . <
	ld de,0f5f0h		;5e87	11 f0 f5	. . .
	ld bc,00020h		;5e8a	01 20 00	.   .
	ldir			;5e8d	ed b0		. .
	ei			;5e8f	fb		.
l5e90h:
	halt			;5e90	76		v
	call 03dd3h		;5e91	cd d3 3d	. . =
	jr l5e5ah		;5e94	18 c4		. .
l5e96h:
	ld a,008h		;5e96	3e 08		> .
	ld (0d008h),a		;5e98	32 08 d0	2 . .
	ld a,070h		;5e9b	3e 70		> p
	out (067h),a		;5e9d	d3 67		. g
	ld b,0ffh		;5e9f	06 ff		. .
	call 03e2fh		;5ea1	cd 2f 3e	. / >
	ret			;5ea4	c9		.
	ld a,002h		;5ea5	3e 02		> .
	ld (0d008h),a		;5ea7	32 08 d0	2 . .
	call 03ce8h		;5eaa	cd e8 3c	. . <
	ld a,070h		;5ead	3e 70		> p
	out (067h),a		;5eaf	d3 67		. g
	ld b,0ffh		;5eb1	06 ff		. .
	call 03e2fh		;5eb3	cd 2f 3e	. / >
	ld a,(0d074h)		;5eb6	3a 74 d0	: t .
	cp 000h			;5eb9	fe 00		. .
	jr z,l5edah		;5ebb	28 1d		( .
	call 03de1h		;5ebd	cd e1 3d	. . =
	ld hl,l3c0dh		;5ec0	21 0d 3c	! . <
	ld de,0f528h		;5ec3	11 28 f5	. ( .
	ld bc,00004h		;5ec6	01 04 00	. . .
	ldir			;5ec9	ed b0		. .
	ld hl,(0d068h)		;5ecb	2a 68 d0	* h .
	inc hl			;5ece	23		#
	ld (0d068h),hl		;5ecf	22 68 d0	" h .
	ld ix,0f51eh		;5ed2	dd 21 1e f5	. ! . .
	call 01134h		;5ed6	cd 34 11	. 4 .
	ret			;5ed9	c9		.
l5edah:
	ld a,(0d06eh)		;5eda	3a 6e d0	: n .
	cp 001h			;5edd	fe 01		. .
	ret z			;5edf	c8		.
	ld a,007h		;5ee0	3e 07		> .
	ld (0d008h),a		;5ee2	32 08 d0	2 . .
	call l3cd3h+1		;5ee5	cd d4 3c	. . <
	ld a,028h		;5ee8	3e 28		> (
	out (067h),a		;5eea	d3 67		. g
	ld b,0ffh		;5eec	06 ff		. .
	call 03e2fh		;5eee	cd 2f 3e	. / >
	ret			;5ef1	c9		.
	ld a,003h		;5ef2	3e 03		> .
	ld (0d008h),a		;5ef4	32 08 d0	2 . .
	call 03dd3h		;5ef7	cd d3 3d	. . =
	call sub_3d13h		;5efa	cd 13 3d	. . =
	ld hl,(0d00ah)		;5efd	2a 0a d0	* . .
	ld (0d016h),hl		;5f00	22 16 d0	" . .
	ld a,(0d004h)		;5f03	3a 04 d0	: . .
	ld (0d014h),a		;5f06	32 14 d0	2 . .
	ld hl,l3c45h		;5f09	21 45 3c	! E <
	ld de,0f023h		;5f0c	11 23 f0	. # .
	ld bc,0000ah		;5f0f	01 0a 00	. . .
	ldir			;5f12	ed b0		. .
	call 03cb4h		;5f14	cd b4 3c	. . <
	call 03ce8h		;5f17	cd e8 3c	. . <
	ld a,011h		;5f1a	3e 11		> .
	out (062h),a		;5f1c	d3 62		. b
	ld a,050h		;5f1e	3e 50		> P
	out (067h),a		;5f20	d3 67		. g
	ld b,0ffh		;5f22	06 ff		. .
	call 03e2fh		;5f24	cd 2f 3e	. / >
	ld a,(0d074h)		;5f27	3a 74 d0	: t .
	cp 001h			;5f2a	fe 01		. .
	jr nz,l5f3bh		;5f2c	20 0d		  .
	ld hl,l3bcbh+1		;5f2e	21 cc 3b	! . ;
	ld de,0f3ach		;5f31	11 ac f3	. . .
	ld bc,00007h		;5f34	01 07 00	. . .
	ldir			;5f37	ed b0		. .
	jr l5f41h		;5f39	18 06		. .
l5f3bh:
	in a,(067h)		;5f3b	db 67		. g
	bit 0,a			;5f3d	cb 47		. G
	jr z,l5f89h		;5f3f	28 48		( H
l5f41h:
	ld hl,l3c4fh		;5f41	21 4f 3c	! O <
	ld de,0f370h		;5f44	11 70 f3	. p .
	ld bc,0000eh		;5f47	01 0e 00	. . .
	ldir			;5f4a	ed b0		. .
	ld hl,l3c2ah		;5f4c	21 2a 3c	! * <
	ld de,0f2f0h		;5f4f	11 f0 f2	. . .
	ld bc,00004h		;5f52	01 04 00	. . .
	ldir			;5f55	ed b0		. .
	ld hl,03c2eh		;5f57	21 2e 3c	! . <
	ld de,0f2f7h		;5f5a	11 f7 f2	. . .
	ld bc,00008h		;5f5d	01 08 00	. . .
	ldir			;5f60	ed b0		. .
	ld hl,(0d014h)		;5f62	2a 14 d0	* . .
	ld ix,0f38eh		;5f65	dd 21 8e f3	. ! . .
	call 01134h		;5f69	cd 34 11	. 4 .
	ld hl,(0d016h)		;5f6c	2a 16 d0	* . .
	ld ix,0f398h		;5f6f	dd 21 98 f3	. ! . .
	call 01134h		;5f73	cd 34 11	. 4 .
	ld hl,03c8bh		;5f76	21 8b 3c	! . <
	ld de,0f5f0h		;5f79	11 f0 f5	. . .
	ld bc,00020h		;5f7c	01 20 00	.   .
	ldir			;5f7f	ed b0		. .
	ei			;5f81	fb		.
	halt			;5f82	76		v
	call 03dd3h		;5f83	cd d3 3d	. . =
	jp 03f09h		;5f86	c3 09 3f	. . ?
l5f89h:
	ld a,(0d006h)		;5f89	3a 06 d0	: . .
	ld b,a			;5f8c	47		G
	ld a,(0d014h)		;5f8d	3a 14 d0	: . .
	cp b			;5f90	b8		.
	jr z,l5f9ah		;5f91	28 07		( .
	inc a			;5f93	3c		<
	ld (0d014h),a		;5f94	32 14 d0	2 . .
	jp 03f09h		;5f97	c3 09 3f	. . ?
l5f9ah:
	ld hl,(0d00ch)		;5f9a	2a 0c d0	* . .
	ld de,(0d016h)		;5f9d	ed 5b 16 d0	. [ . .
	sbc hl,de		;5fa1	ed 52		. R
	jr z,l5fadh		;5fa3	28 08		( .
	inc de			;5fa5	13		.
	ld (0d016h),de		;5fa6	ed 53 16 d0	. S . .
	jp l3f03h		;5faa	c3 03 3f	. . ?
l5fadh:
	ld a,006h		;5fad	3e 06		> .
	ld (0d008h),a		;5faf	32 08 d0	2 . .
	ld a,0e5h		;5fb2	3e e5		> .
	ld hl,0e000h		;5fb4	21 00 e0	! . .
	ld de,0e001h		;5fb7	11 01 e0	. . .
	ld (hl),a		;5fba	77		w
	ld bc,001ffh		;5fbb	01 ff 01	. . .
	ldir			;5fbe	ed b0		. .
	ld hl,(0d00ah)		;5fc0	2a 0a d0	* . .
	ld (0d016h),hl		;5fc3	22 16 d0	" . .
	ld a,(0d004h)		;5fc6	3a 04 d0	: . .
	ld (0d014h),a		;5fc9	32 14 d0	2 . .
l5fcch:
	xor a			;5fcc	af		.
	ld (0d018h),a		;5fcd	32 18 d0	2 . .
l5fd0h:
	call 03cb4h		;5fd0	cd b4 3c	. . <
	call 03ce8h		;5fd3	cd e8 3c	. . <
	ld a,030h		;5fd6	3e 30		> 0
	out (067h),a		;5fd8	d3 67		. g
	ld b,0ffh		;5fda	06 ff		. .
	call 03e2fh		;5fdc	cd 2f 3e	. / >
	ld a,(0d018h)		;5fdf	3a 18 d0	: . .
	inc a			;5fe2	3c		<
	ld (0d018h),a		;5fe3	32 18 d0	2 . .
	cp 011h			;5fe6	fe 11		. .
	jr nz,l5fd0h		;5fe8	20 e6		  .
	ld a,(0d014h)		;5fea	3a 14 d0	: . .
	ld b,a			;5fed	47		G
	ld a,(0d006h)		;5fee	3a 06 d0	: . .
	cp b			;5ff1	b8		.
	jr z,l5ffbh		;5ff2	28 07		( .
	ld a,b			;5ff4	78		x
	inc a			;5ff5	3c		<
	ld (0d014h),a		;5ff6	32 14 d0	2 . .
	jr l5fcch		;5ff9	18 d1		. .
l5ffbh:
	ld hl,(0d00ch)		;5ffb	2a 0c d0	* . .
	ld de,(0d090h)		;5ffe	ed 5b 90 d0	. [ . .
	sub 001h		;6002	d6 01		. .
	ld (0d090h),a		;6004	32 90 d0	2 . .
	ld (0d016h),a		;6007	32 16 d0	2 . .
	ld a,(0d092h)		;600a	3a 92 d0	: . .
	ld b,a			;600d	47		G
	ld a,(0d090h)		;600e	3a 90 d0	: . .
	cp b			;6011	b8		.
	jp nz,l47e0h		;6012	c2 e0 47	. . G
	jr l6017h		;6015	18 00		. .
l6017h:
	ld hl,(0d00ah)		;6017	2a 0a d0	* . .
	ld (0d016h),hl		;601a	22 16 d0	" . .
	ld a,(0d004h)		;601d	3a 04 d0	: . .
	ld (0d014h),a		;6020	32 14 d0	2 . .
	ld a,000h		;6023	3e 00		> .
	ld (0d018h),a		;6025	32 18 d0	2 . .
	call 03e09h		;6028	cd 09 3e	. . >
	call 03cb4h		;602b	cd b4 3c	. . <
	ld hl,(0d014h)		;602e	2a 14 d0	* . .
	ld ix,0f7adh		;6031	dd 21 ad f7	. ! . .
	call 01134h		;6035	cd 34 11	. 4 .
	ld hl,(0d016h)		;6038	2a 16 d0	* . .
	ld ix,0f7b7h		;603b	dd 21 b7 f7	. ! . .
	call 01134h		;603f	cd 34 11	. 4 .
	ld hl,(0d018h)		;6042	2a 18 d0	* . .
	ld ix,0f7c1h		;6045	dd 21 c1 f7	. ! . .
	call 01134h		;6049	cd 34 11	. 4 .
	call 03ce8h		;604c	cd e8 3c	. . <
	ld a,004h		;604f	3e 04		> .
	ld (0d008h),a		;6051	32 08 d0	2 . .
	ld a,030h		;6054	3e 30		> 0
	out (067h),a		;6056	d3 67		. g
	ld b,0ffh		;6058	06 ff		. .
	call 03e2fh		;605a	cd 2f 3e	. / >
	ld a,(0d074h)		;605d	3a 74 d0	: t .
	cp 000h			;6060	fe 00		. .
	jr z,l607eh		;6062	28 1a		( .
	call 03de1h		;6064	cd e1 3d	. . =
	ld hl,(0d068h)		;6067	2a 68 d0	* h .
	inc hl			;606a	23		#
	ld (0d068h),hl		;606b	22 68 d0	" h .
	ld ix,0f51eh		;606e	dd 21 1e f5	. ! . .
	call 01134h		;6072	cd 34 11	. 4 .
	ld ix,0f500h		;6075	dd 21 00 f5	. ! . .
	call sub_3d6dh		;6079	cd 6d 3d	. m =
	jr l60cbh		;607c	18 4d		. M
l607eh:
	ld a,(0d06eh)		;607e	3a 6e d0	: n .
	cp 000h			;6081	fe 00		. .
	jr nz,l60cbh		;6083	20 46		  F
	call l3cd3h+1		;6085	cd d4 3c	. . <
	ld a,005h		;6088	3e 05		> .
l608ah:
	ld (0d008h),a		;608a	32 08 d0	2 . .
	ld a,028h		;608d	3e 28		> (
	out (067h),a		;608f	d3 67		. g
	ld a,028h		;6091	3e 28		> (
	out (067h),a		;6093	d3 67		. g
	ld b,0ffh		;6095	06 ff		. .
	call 03e2fh		;6097	cd 2f 3e	. / >
	ld a,(0d074h)		;609a	3a 74 d0	: t .
	cp 000h			;609d	fe 00		. .
	jr z,l60b9h		;609f	28 18		( .
	call 03de1h		;60a1	cd e1 3d	. . =
	ld hl,(0d068h)		;60a4	2a 68 d0	* h .
	inc hl			;60a7	23		#
	ld (0d068h),hl		;60a8	22 68 d0	" h .
	ld ix,0f51eh		;60ab	dd 21 1e f5	. ! . .
	call 01134h		;60af	cd 34 11	. 4 .
	ld ix,0f500h		;60b2	dd 21 00 f5	. ! . .
	call sub_3d6dh		;60b6	cd 6d 3d	. m =
l60b9h:
	ld a,(0d0b0h)		;60b9	3a b0 d0	: . .
	cp 000h			;60bc	fe 00		. .
	jr nz,l60cbh		;60be	20 0b		  .
	call 03e1bh		;60c0	cd 1b 3e	. . >
	ld a,001h		;60c3	3e 01		> .
	ld (0d0b0h),a		;60c5	32 b0 d0	2 . .
	jp l482bh		;60c8	c3 2b 48	. + H
l60cbh:
	xor a			;60cb	af		.
	ld (0d0b0h),a		;60cc	32 b0 d0	2 . .
	ld (0d06eh),a		;60cf	32 6e d0	2 n .
	ld a,(0d018h)		;60d2	3a 18 d0	: . .
	inc a			;60d5	3c		<
	ld (0d018h),a		;60d6	32 18 d0	2 . .
	cp 011h			;60d9	fe 11		. .
	jp nz,l4827h+1		;60db	c2 28 48	. ( H
	ld a,(0d006h)		;60de	3a 06 d0	: . .
	ld b,a			;60e1	47		G
	ld a,(0d014h)		;60e2	3a 14 d0	: . .
	cp b			;60e5	b8		.
	jr z,l60efh		;60e6	28 07		( .
	inc a			;60e8	3c		<
	ld (0d014h),a		;60e9	32 14 d0	2 . .
	jp 04823h		;60ec	c3 23 48	. # H
l60efh:
	ld de,(0d016h)		;60ef	ed 5b 16 d0	. [ . .
	inc de			;60f3	13		.
	ld (0d016h),de		;60f4	ed 53 16 d0	. S . .
	ld hl,(0d00ch)		;60f8	2a 0c d0	* . .
	inc hl			;60fb	23		#
	sbc hl,de		;60fc	ed 52		. R
	jp nz,0481dh		;60fe	c2 1d 48	. . H
	ld hl,(0d026h)		;6101	2a 26 d0	* & .
	inc hl			;6104	23		#
	ld (0d026h),hl		;6105	22 26 d0	" & .
	ld ix,0f0aah		;6108	dd 21 aa f0	. ! . .
	call 01134h		;610c	cd 34 11	. 4 .
	jp l4817h		;610f	c3 17 48	. . H
	ld a,005h		;6112	3e 05		> .
	ld (0d008h),a		;6114	32 08 d0	2 . .
	ld hl,(0d026h)		;6117	2a 26 d0	* & .
	ld ix,0f0aah		;611a	dd 21 aa f0	. ! . .
	call 01134h		;611e	cd 34 11	. 4 .
	ld hl,(0d00ah)		;6121	2a 0a d0	* . .
	ld (0d016h),hl		;6124	22 16 d0	" . .
l6127h:
	ld a,(0d004h)		;6127	3a 04 d0	: . .
	ld (0d014h),a		;612a	32 14 d0	2 . .
l612dh:
	ld a,000h		;612d	3e 00		> .
	ld (0d018h),a		;612f	32 18 d0	2 . .
l6132h:
	call l3cd3h+1		;6132	cd d4 3c	. . <
	ld hl,(0d014h)		;6135	2a 14 d0	* . .
	ld ix,0f7adh		;6138	dd 21 ad f7	. ! . .
	call 01134h		;613c	cd 34 11	. 4 .
	ld hl,(0d016h)		;613f	2a 16 d0	* . .
	ld ix,0f7b7h		;6142	dd 21 b7 f7	. ! . .
	call 01134h		;6146	cd 34 11	. 4 .
	ld hl,(0d018h)		;6149	2a 18 d0	* . .
	ld ix,0f7c1h		;614c	dd 21 c1 f7	. ! . .
	call 01134h		;6150	cd 34 11	. 4 .
	call 03ce8h		;6153	cd e8 3c	. . <
	ld a,028h		;6156	3e 28		> (
	out (067h),a		;6158	d3 67		. g
	ld b,0ffh		;615a	06 ff		. .
	call 03e2fh		;615c	cd 2f 3e	. / >
	ld a,(0d06eh)		;615f	3a 6e d0	: n .
	cp 000h			;6162	fe 00		. .
	jr nz,l6132h		;6164	20 cc		  .
	ld a,(0d018h)		;6166	3a 18 d0	: . .
	cp 00fh			;6169	fe 0f		. .
	jr z,l6173h		;616b	28 06		( .
	inc a			;616d	3c		<
	ld (0d018h),a		;616e	32 18 d0	2 . .
	jr l6132h		;6171	18 bf		. .
l6173h:
	ld a,(0d006h)		;6173	3a 06 d0	: . .
	ld b,a			;6176	47		G
	ld a,(0d014h)		;6177	3a 14 d0	: . .
	cp b			;617a	b8		.
	jr z,l6183h		;617b	28 06		( .
	inc a			;617d	3c		<
	ld (0d014h),a		;617e	32 14 d0	2 . .
	jr l612dh		;6181	18 aa		. .
l6183h:
	ld de,(0d016h)		;6183	ed 5b 16 d0	. [ . .
	ld hl,(0d00ch)		;6187	2a 0c d0	* . .
	sbc hl,de		;618a	ed 52		. R
	jr z,l6197h		;618c	28 09		( .
	ld hl,(0d016h)		;618e	2a 16 d0	* . .
	inc hl			;6191	23		#
	ld (0d016h),hl		;6192	22 16 d0	" . .
	jr l6127h		;6195	18 90		. .
l6197h:
	ld hl,(0d026h)		;6197	2a 26 d0	* & .
	inc hl			;619a	23		#
	ld (0d026h),hl		;619b	22 26 d0	" & .
	jp l4917h		;619e	c3 17 49	. . I
	ld hl,(0d00ah)		;61a1	2a 0a d0	* . .
	ld (0d016h),hl		;61a4	22 16 d0	" . .
	ld a,(0d004h)		;61a7	3a 04 d0	: . .
	ld (0d014h),a		;61aa	32 14 d0	2 . .
	ld a,000h		;61ad	3e 00		> .
	ld (0d018h),a		;61af	32 18 d0	2 . .
l61b2h:
	call l3cd3h+1		;61b2	cd d4 3c	. . <
	ld hl,(0d014h)		;61b5	2a 14 d0	* . .
	ld ix,0f7adh		;61b8	dd 21 ad f7	. ! . .
	call 01134h		;61bc	cd 34 11	. 4 .
	ld hl,(0d016h)		;61bf	2a 16 d0	* . .
	ld ix,0f7b7h		;61c2	dd 21 b7 f7	. ! . .
	call 01134h		;61c6	cd 34 11	. 4 .
	ld hl,(0d018h)		;61c9	2a 18 d0	* . .
	ld ix,0f7c1h		;61cc	dd 21 c1 f7	. ! . .
	call 01134h		;61d0	cd 34 11	. 4 .
	call 03ce8h		;61d3	cd e8 3c	. . <
	ld a,028h		;61d6	3e 28		> (
	out (067h),a		;61d8	d3 67		. g
	ld b,0ffh		;61da	06 ff		. .
	call 03e2fh		;61dc	cd 2f 3e	. / >
	ld a,(0d06eh)		;61df	3a 6e d0	: n .
	cp 000h			;61e2	fe 00		. .
	jr nz,l61b2h		;61e4	20 cc		  .
	ld a,(0d018h)		;61e6	3a 18 d0	: . .
	cp 00fh			;61e9	fe 0f		. .
	jr z,l61f3h		;61eb	28 06		( .
	inc a			;61ed	3c		<
	ld (0d018h),a		;61ee	32 18 d0	2 . .
	jr l61b2h		;61f1	18 bf		. .
l61f3h:
	ld a,(0d006h)		;61f3	3a 06 d0	: . .
	ld b,a			;61f6	47		G
	ld a,(0d014h)		;61f7	3a 14 d0	: . .
	cp b			;61fa	b8		.
	jr z,l6203h		;61fb	28 06		( .
	inc a			;61fd	3c		<
	ld (l7313h+1),a		;61fe	32 14 73	2 . s
	ld a,002h		;6201	3e 02		> .
l6203h:
	or (hl)			;6203	b6		.
	ld (hl),a		;6204	77		w
	ld hl,l8033h		;6205	21 33 80	! 3 .
	dec (hl)		;6208	35		5
	call sub_74cbh		;6209	cd cb 74	. . t
	ret nc			;620c	d0		.
	ld a,0fbh		;620d	3e fb		> .
	jp l72c3h+1		;620f	c3 c4 72	. . r
	ld b,001h		;6212	06 01		. .
	ld c,0ffh		;6214	0e ff		. .
	call l76b0h+1		;6216	cd b1 76	. . v
	call sub_7672h		;6219	cd 72 76	. r v
	ld a,(l8010h)		;621c	3a 10 80	: . .
	and 023h		;621f	e6 23		. #
	ld c,a			;6221	4f		O
	ld a,(l801bh)		;6222	3a 1b 80	: . .
	add a,020h		;6225	c6 20		.  
	cp c			;6227	b9		.
	jp nz,l72c3h+1		;6228	c2 c4 72	. . r
	call l770ah+1		;622b	cd 0b 77	. . w
	jp c,l72c3h+1		;622e	da c4 72	. . r
	jp z,l723dh		;6231	ca 3d 72	. = r
	jp l72c3h+1		;6234	c3 c4 72	. . r
	call 071f3h		;6237	cd f3 71	. . q
	ld a,001h		;623a	3e 01		> .
	out (018h),a		;623c	d3 18		. .
	ld hl,(l8067h)		;623e	2a 67 80	* g .
	call sub_7425h		;6241	cd 25 74	. % t
	ld a,(l8032h)		;6244	3a 32 80	: 2 .
	or a			;6247	b7		.
	jp nz,l7257h		;6248	c2 57 72	. W r
	call sub_74cbh		;624b	cd cb 74	. . t
	jp l7243h+1		;624e	c3 44 72	. D r
	ld a,001h		;6251	3e 01		> .
	ld (l8060h),a		;6253	32 60 80	2 ` .
	call l7261h+1		;6256	cd 62 72	. b r
	jp l7403h		;6259	c3 03 74	. . t
	ld a,00ah		;625c	3e 0a		> .
	ld hl,00000h		;625e	21 00 00	! . .
	call l72a9h+1		;6261	cd aa 72	. . r
	jp z,l727bh+1		;6264	ca 7c 72	. | r
	ld a,00bh		;6267	3e 0b		> .
	call l72a9h+1		;6269	cd aa 72	. . r
	jp z,l7277h+1		;626c	ca 78 72	. x r
	jp l700fh		;626f	c3 0f 70	. . p
	ld hl,(00000h)		;6272	2a 00 00	* . .
	jp (hl)			;6275	e9		.
	ld hl,00000h		;6276	21 00 00	! . .
	ld de,00b60h		;6279	11 60 0b	. ` .
	add hl,de		;627c	19		.
	ld de,00020h		;627d	11 20 00	.   .
	add hl,de		;6280	19		.
	ld bc,00d00h		;6281	01 00 0d	. . .
	ld a,b			;6284	78		x
	cp h			;6285	bc		.
	jp c,l7000h		;6286	da 00 70	. . p
	ld a,(hl)		;6289	7e		~
	or a			;628a	b7		.
	jp z,l7283h		;628b	ca 83 72	. . r
	call sub_702dh		;628e	cd 2d 70	. - p
	jp nz,l7000h		;6291	c2 00 70	. . p
	ld de,00020h		;6294	11 20 00	.   .
	add hl,de		;6297	19		.
	ld a,(hl)		;6298	7e		~
	or a			;6299	b7		.
	jp z,l7000h		;629a	ca 00 70	. . p
	call sub_703eh		;629d	cd 3e 70	. > p
	jp nz,l7000h		;62a0	c2 00 70	. . p
	ret			;62a3	c9		.
	ld de,00002h		;62a4	11 02 00	. . .
	add hl,de		;62a7	19		.
	ex de,hl		;62a8	eb		.
	ld bc,l7071h		;62a9	01 71 70	. q p
	ld hl,00006h		;62ac	21 06 00	! . .
	cp 00ah			;62af	fe 0a		. .
	jp z,l72bfh+1		;62b1	ca c0 72	. . r
	ld bc,l7077h		;62b4	01 77 70	. w p
	ld hl,00006h		;62b7	21 06 00	! . .
	call sub_705ch		;62ba	cd 5c 70	. \ p
	ret			;62bd	c9		.
	ld a,00bh		;62be	3e 0b		> .
	ld hl,l2000h		;62c0	21 00 20	! .  
	call l72a9h+1		;62c3	cd aa 72	. . r
	jp z,l72d1h+1		;62c6	ca d2 72	. . r
	jp l701eh		;62c9	c3 1e 70	. . p
	ld hl,(l2000h)		;62cc	2a 00 20	* .  
	jp (hl)			;62cf	e9		.
	ld a,(de)		;62d0	1a		.
	rlca			;62d1	07		.
	inc (hl)		;62d2	34		4
	rlca			;62d3	07		.
	rrca			;62d4	0f		.
	ld c,01ah		;62d5	0e 1a		. .
	ld c,008h		;62d7	0e 08		. .
	dec de			;62d9	1b		.
	rrca			;62da	0f		.
	dec de			;62db	1b		.
	nop			;62dc	00		.
	nop			;62dd	00		.
	ex af,af'		;62de	08		.
	dec (hl)		;62df	35		5
	djnz l62e9h		;62e0	10 07		. .
	jr nz,l62ebh		;62e2	20 07		  .
	add hl,bc		;62e4	09		.
	ld c,010h		;62e5	0e 10		. .
	ld c,005h		;62e7	0e 05		. .
l62e9h:
	dec de			;62e9	1b		.
	add hl,bc		;62ea	09		.
l62ebh:
	dec de			;62eb	1b		.
	nop			;62ec	00		.
	nop			;62ed	00		.
	dec b			;62ee	05		.
	dec (hl)		;62ef	35		5
	nop			;62f0	00		.
	nop			;62f1	00		.
	nop			;62f2	00		.
	nop			;62f3	00		.
	nop			;62f4	00		.
	nop			;62f5	00		.
	nop			;62f6	00		.
	nop			;62f7	00		.
	nop			;62f8	00		.
	nop			;62f9	00		.
	add a,073h		;62fa	c6 73		. s
	add a,073h		;62fc	c6 73		. s
	add a,073h		;62fe	c6 73		. s
	add a,073h		;6300	c6 73		. s
	add a,073h		;6302	c6 73		. s
	add a,073h		;6304	c6 73		. s
	cp e			;6306	bb		.
	ld (hl),e		;6307	73		s
	jp nz,0c673h		;6308	c2 73 c6	. s .
	ld (hl),e		;630b	73		s
	add a,073h		;630c	c6 73		. s
	add a,073h		;630e	c6 73		. s
	add a,073h		;6310	c6 73		. s
	add a,073h		;6312	c6 73		. s
	add a,073h		;6314	c6 73		. s
	add a,073h		;6316	c6 73		. s
	add a,073h		;6318	c6 73		. s
	add a,a			;631a	87		.
	nop			;631b	00		.
	ld (l8065h),hl		;631c	22 65 80	" e .
	ld hl,00000h		;631f	21 00 00	! . .
	add hl,sp		;6322	39		9
	ld (l801eh),hl		;6323	22 1e 80	" . .
	push bc			;6326	c5		.
	ex de,hl		;6327	eb		.
	ld a,c			;6328	79		y
	and 07fh		;6329	e6 7f		. .
	ld (l8034h),a		;632b	32 34 80	2 4 .
	ld a,b			;632e	78		x
	and 07fh		;632f	e6 7f		. .
	ld (l8032h),a		;6331	32 32 80	2 2 .
	call z,sub_74cbh	;6334	cc cb 74	. . t
	ld a,b			;6337	78		x
	and 080h		;6338	e6 80		. .
	jp z,l7345h		;633a	ca 45 73	. E s
	ld a,001h		;633d	3e 01		> .
	ld (l8033h),a		;633f	32 33 80	2 3 .
	call sub_7425h		;6342	cd 25 74	. % t
	pop bc			;6345	c1		.
	push af			;6346	f5		.
	ld a,b			;6347	78		x
	and 07fh		;6348	e6 7f		. .
	jp nz,l735bh		;634a	c2 5b 73	. [ s
	ld a,001h		;634d	3e 01		> .
	ld (l8032h),a		;634f	32 32 80	2 2 .
	call sub_74cbh		;6352	cd cb 74	. . t
	pop af			;6355	f1		.
	xor a			;6356	af		.
	ld hl,(l801eh)		;6357	2a 1e 80	* . .
	ld sp,hl		;635a	f9		.
	ret			;635b	c9		.
	push af			;635c	f5		.
	in a,(001h)		;635d	db 01		. .
	push hl			;635f	e5		.
	push de			;6360	d5		.
	push bc			;6361	c5		.
	ld a,006h		;6362	3e 06		> .
	out (0fah),a		;6364	d3 fa		. .
	ld a,007h		;6366	3e 07		> .
	out (0fah),a		;6368	d3 fa		. .
	out (0fch),a		;636a	d3 fc		. .
	ld hl,(l7fd5h)		;636c	2a d5 7f	* . .
	ld de,l7800h		;636f	11 00 78	. . x
	add hl,de		;6372	19		.
	ld a,l			;6373	7d		}
	out (0f4h),a		;6374	d3 f4		. .
	ld a,h			;6376	7c		|
	out (0f4h),a		;6377	d3 f4		. .
	ld a,l			;6379	7d		}
	cpl			;637a	2f		/
	ld l,a			;637b	6f		o
	ld a,h			;637c	7c		|
	cpl			;637d	2f		/
	ld h,a			;637e	67		g
	inc hl			;637f	23		#
	ld de,007cfh		;6380	11 cf 07	. . .
	add hl,de		;6383	19		.
	ld de,l7800h		;6384	11 00 78	. . x
	add hl,de		;6387	19		.
	ld a,l			;6388	7d		}
	out (0f5h),a		;6389	d3 f5		. .
	ld a,h			;638b	7c		|
	out (0f5h),a		;638c	d3 f5		. .
	ld hl,l7800h		;638e	21 00 78	! . x
	ld a,l			;6391	7d		}
	out (0f6h),a		;6392	d3 f6		. .
	ld a,h			;6394	7c		|
	out (0f6h),a		;6395	d3 f6		. .
	ld hl,007cfh		;6397	21 cf 07	! . .
	ld a,l			;639a	7d		}
	out (0f7h),a		;639b	d3 f7		. .
	ld a,h			;639d	7c		|
	out (0f7h),a		;639e	d3 f7		. .
	ld a,002h		;63a0	3e 02		> .
	out (0fah),a		;63a2	d3 fa		. .
	ld a,003h		;63a4	3e 03		> .
	out (0fah),a		;63a6	d3 fa		. .
	pop bc			;63a8	c1		.
	pop de			;63a9	d1		.
	pop hl			;63aa	e1		.
	ld a,0d7h		;63ab	3e d7		> .
	out (00eh),a		;63ad	d3 0e		. .
	ld a,001h		;63af	3e 01		> .
	out (00eh),a		;63b1	d3 0e		. .
	pop af			;63b3	f1		.
	ret			;63b4	c9		.
	di			;63b5	f3		.
	call l7361h+1		;63b6	cd 62 73	. b s
	ei			;63b9	fb		.
	reti			;63ba	ed 4d		. M
	di			;63bc	f3		.
	jp l7770h		;63bd	c3 70 77	. p w
	ei			;63c0	fb		.
	reti			;63c1	ed 4d		. M
	ld (l8003h),a		;63c3	32 03 80	2 . .
	ei			;63c6	fb		.
	ld a,(l8060h)		;63c7	3a 60 80	: ` .
	and 001h		;63ca	e6 01		. .
	jp nz,l735dh		;63cc	c2 5d 73	. ] s
	out (01ch),a		;63cf	d3 1c		. .
	call l73ddh+1		;63d1	cd de 73	. . s
	or a			;63d4	b7		.
	jp l73d9h+1		;63d5	c3 da 73	. . s
	ld bc,l7800h		;63d8	01 00 78	. . x
	ld de,l73efh+1		;63db	11 f0 73	. . s
	ld hl,00012h		;63de	21 12 00	! . .
	ld a,(de)		;63e1	1a		.
	ld (bc),a		;63e2	02		.
	inc bc			;63e3	03		.
	inc de			;63e4	13		.
	dec l			;63e5	2d		-
	jp nz,l73e7h		;63e6	c2 e7 73	. . s
	ret			;63e9	c9		.
	ld hl,(0442ah)		;63ea	2a 2a 44	* * D
	ld c,c			;63ed	49		I
	ld d,e			;63ee	53		S
	ld c,e			;63ef	4b		K
	ld b,l			;63f0	45		E
	ld d,h			;63f1	54		T
	ld d,h			;63f2	54		T
	ld b,l			;63f3	45		E
	jr nz,l643bh		;63f4	20 45		  E
	ld d,d			;63f6	52		R
	ld d,d			;63f7	52		R
	ld c,a			;63f8	4f		O
	ld d,d			;63f9	52		R
	ld hl,(l202ah)		;63fa	2a 2a 20	* *  
	ld a,(l731fh+1)		;63fd	3a 20 73	:   s
	rst 38h			;6400	ff		.
	rst 38h			;6401	ff		.
	rst 38h			;6402	ff		.
	rst 38h			;6403	ff		.
	rst 38h			;6404	ff		.
	rst 38h			;6405	ff		.
	rst 38h			;6406	ff		.
	rst 38h			;6407	ff		.
	rst 38h			;6408	ff		.
	rst 38h			;6409	ff		.
	rst 38h			;640a	ff		.
sub_640bh:
	rst 38h			;640b	ff		.
	rst 38h			;640c	ff		.
	rst 38h			;640d	ff		.
	rst 38h			;640e	ff		.
	rst 38h			;640f	ff		.
	rst 18h			;6410	df		.
	rst 38h			;6411	ff		.
	rst 38h			;6412	ff		.
	rst 38h			;6413	ff		.
	rst 18h			;6414	df		.
	rst 38h			;6415	ff		.
	rst 38h			;6416	ff		.
	rst 38h			;6417	ff		.
	rst 18h			;6418	df		.
	rst 38h			;6419	ff		.
	jr nz,l641ch		;641a	20 00		  .
l641ch:
	nop			;641c	00		.
	nop			;641d	00		.
	jr nz,l6420h		;641e	20 00		  .
l6420h:
	nop			;6420	00		.
	nop			;6421	00		.
	nop			;6422	00		.
	nop			;6423	00		.
	nop			;6424	00		.
	nop			;6425	00		.
	nop			;6426	00		.
	nop			;6427	00		.
	nop			;6428	00		.
	nop			;6429	00		.
	nop			;642a	00		.
	nop			;642b	00		.
	nop			;642c	00		.
	nop			;642d	00		.
	nop			;642e	00		.
	nop			;642f	00		.
	nop			;6430	00		.
	nop			;6431	00		.
	nop			;6432	00		.
	nop			;6433	00		.
	nop			;6434	00		.
	nop			;6435	00		.
	nop			;6436	00		.
	nop			;6437	00		.
	nop			;6438	00		.
	nop			;6439	00		.
	rst 38h			;643a	ff		.
l643bh:
	rst 38h			;643b	ff		.
	rst 38h			;643c	ff		.
	rst 38h			;643d	ff		.
	rst 38h			;643e	ff		.
	rst 38h			;643f	ff		.
	rst 38h			;6440	ff		.
	rst 38h			;6441	ff		.
l6442h:
	rst 38h			;6442	ff		.
	rst 38h			;6443	ff		.
	rst 38h			;6444	ff		.
	rst 38h			;6445	ff		.
	rst 38h			;6446	ff		.
	rst 38h			;6447	ff		.
	rst 38h			;6448	ff		.
	rst 38h			;6449	ff		.
	rst 38h			;644a	ff		.
	rst 38h			;644b	ff		.
	rst 38h			;644c	ff		.
	rst 38h			;644d	ff		.
	rst 38h			;644e	ff		.
	rst 38h			;644f	ff		.
	rst 38h			;6450	ff		.
	rst 38h			;6451	ff		.
	rst 38h			;6452	ff		.
	rst 38h			;6453	ff		.
	rst 38h			;6454	ff		.
	rst 38h			;6455	ff		.
	rst 38h			;6456	ff		.
	rst 38h			;6457	ff		.
	rst 38h			;6458	ff		.
	rst 38h			;6459	ff		.
	nop			;645a	00		.
	nop			;645b	00		.
	nop			;645c	00		.
	nop			;645d	00		.
	nop			;645e	00		.
	nop			;645f	00		.
	nop			;6460	00		.
	nop			;6461	00		.
	nop			;6462	00		.
	nop			;6463	00		.
	nop			;6464	00		.
	nop			;6465	00		.
	nop			;6466	00		.
	nop			;6467	00		.
	nop			;6468	00		.
	nop			;6469	00		.
	nop			;646a	00		.
	nop			;646b	00		.
	nop			;646c	00		.
	nop			;646d	00		.
	nop			;646e	00		.
	nop			;646f	00		.
	nop			;6470	00		.
	nop			;6471	00		.
	nop			;6472	00		.
	nop			;6473	00		.
	nop			;6474	00		.
	nop			;6475	00		.
	nop			;6476	00		.
	nop			;6477	00		.
	nop			;6478	00		.
	nop			;6479	00		.
	rst 38h			;647a	ff		.
	rst 38h			;647b	ff		.
	rst 38h			;647c	ff		.
	rst 38h			;647d	ff		.
	rst 38h			;647e	ff		.
	rst 38h			;647f	ff		.
	rst 38h			;6480	ff		.
	rst 38h			;6481	ff		.
	rst 38h			;6482	ff		.
	rst 38h			;6483	ff		.
	rst 38h			;6484	ff		.
	rst 38h			;6485	ff		.
	rst 38h			;6486	ff		.
	rst 38h			;6487	ff		.
	rst 38h			;6488	ff		.
	rst 38h			;6489	ff		.
	rst 38h			;648a	ff		.
	rst 38h			;648b	ff		.
	rst 38h			;648c	ff		.
	rst 38h			;648d	ff		.
	rst 38h			;648e	ff		.
	rst 38h			;648f	ff		.
	rst 38h			;6490	ff		.
	rst 38h			;6491	ff		.
	rst 38h			;6492	ff		.
	rst 38h			;6493	ff		.
	rst 38h			;6494	ff		.
	rst 38h			;6495	ff		.
	rst 38h			;6496	ff		.
	rst 38h			;6497	ff		.
	rst 38h			;6498	ff		.
	rst 38h			;6499	ff		.
	nop			;649a	00		.
	nop			;649b	00		.
	nop			;649c	00		.
	nop			;649d	00		.
	nop			;649e	00		.
	nop			;649f	00		.
	nop			;64a0	00		.
	nop			;64a1	00		.
	nop			;64a2	00		.
	nop			;64a3	00		.
	nop			;64a4	00		.
	nop			;64a5	00		.
	nop			;64a6	00		.
	nop			;64a7	00		.
	nop			;64a8	00		.
	nop			;64a9	00		.
	nop			;64aa	00		.
	nop			;64ab	00		.
	nop			;64ac	00		.
	nop			;64ad	00		.
	nop			;64ae	00		.
	nop			;64af	00		.
	nop			;64b0	00		.
	nop			;64b1	00		.
	nop			;64b2	00		.
	nop			;64b3	00		.
	nop			;64b4	00		.
	nop			;64b5	00		.
	nop			;64b6	00		.
	nop			;64b7	00		.
	nop			;64b8	00		.
	nop			;64b9	00		.
	rst 38h			;64ba	ff		.
	rst 38h			;64bb	ff		.
	rst 38h			;64bc	ff		.
	rst 38h			;64bd	ff		.
	rst 38h			;64be	ff		.
	rst 38h			;64bf	ff		.
	rst 38h			;64c0	ff		.
	rst 38h			;64c1	ff		.
	rst 38h			;64c2	ff		.
	rst 38h			;64c3	ff		.
	rst 38h			;64c4	ff		.
	rst 38h			;64c5	ff		.
	rst 38h			;64c6	ff		.
	rst 38h			;64c7	ff		.
	rst 38h			;64c8	ff		.
	rst 38h			;64c9	ff		.
	rst 38h			;64ca	ff		.
	rst 38h			;64cb	ff		.
	rst 38h			;64cc	ff		.
	rst 38h			;64cd	ff		.
	rst 38h			;64ce	ff		.
	rst 38h			;64cf	ff		.
	rst 38h			;64d0	ff		.
	rst 38h			;64d1	ff		.
	rst 38h			;64d2	ff		.
	rst 38h			;64d3	ff		.
	rst 38h			;64d4	ff		.
	rst 38h			;64d5	ff		.
	rst 38h			;64d6	ff		.
	rst 38h			;64d7	ff		.
	rst 38h			;64d8	ff		.
	rst 38h			;64d9	ff		.
	nop			;64da	00		.
	nop			;64db	00		.
	nop			;64dc	00		.
	nop			;64dd	00		.
	nop			;64de	00		.
	nop			;64df	00		.
	nop			;64e0	00		.
	nop			;64e1	00		.
	nop			;64e2	00		.
	nop			;64e3	00		.
	nop			;64e4	00		.
	nop			;64e5	00		.
	nop			;64e6	00		.
	nop			;64e7	00		.
	nop			;64e8	00		.
	nop			;64e9	00		.
	nop			;64ea	00		.
	nop			;64eb	00		.
	nop			;64ec	00		.
	nop			;64ed	00		.
	nop			;64ee	00		.
	nop			;64ef	00		.
	nop			;64f0	00		.
	nop			;64f1	00		.
	nop			;64f2	00		.
	nop			;64f3	00		.
	nop			;64f4	00		.
	nop			;64f5	00		.
	nop			;64f6	00		.
	nop			;64f7	00		.
	nop			;64f8	00		.
	nop			;64f9	00		.
	rst 38h			;64fa	ff		.
	rst 38h			;64fb	ff		.
	rst 38h			;64fc	ff		.
	rst 38h			;64fd	ff		.
	rst 38h			;64fe	ff		.
	rst 38h			;64ff	ff		.
	rst 38h			;6500	ff		.
	rst 38h			;6501	ff		.
	rst 38h			;6502	ff		.
	rst 38h			;6503	ff		.
	rst 38h			;6504	ff		.
	rst 38h			;6505	ff		.
	rst 38h			;6506	ff		.
	rst 38h			;6507	ff		.
	rst 38h			;6508	ff		.
	rst 38h			;6509	ff		.
	rst 38h			;650a	ff		.
	rst 38h			;650b	ff		.
	rst 38h			;650c	ff		.
	rst 38h			;650d	ff		.
	rst 38h			;650e	ff		.
	rst 38h			;650f	ff		.
	rst 38h			;6510	ff		.
	rst 38h			;6511	ff		.
	rst 38h			;6512	ff		.
	rst 38h			;6513	ff		.
	rst 38h			;6514	ff		.
	rst 38h			;6515	ff		.
	rst 38h			;6516	ff		.
	rst 38h			;6517	ff		.
	rst 18h			;6518	df		.
	rst 38h			;6519	ff		.
	jr nz,l651ch		;651a	20 00		  .
l651ch:
	nop			;651c	00		.
	nop			;651d	00		.
	jr nz,l6520h		;651e	20 00		  .
l6520h:
	nop			;6520	00		.
	nop			;6521	00		.
	nop			;6522	00		.
	nop			;6523	00		.
	nop			;6524	00		.
	nop			;6525	00		.
	nop			;6526	00		.
	nop			;6527	00		.
	nop			;6528	00		.
	nop			;6529	00		.
	nop			;652a	00		.
	nop			;652b	00		.
	nop			;652c	00		.
	nop			;652d	00		.
	nop			;652e	00		.
	nop			;652f	00		.
	nop			;6530	00		.
	nop			;6531	00		.
	nop			;6532	00		.
	nop			;6533	00		.
	nop			;6534	00		.
	nop			;6535	00		.
	nop			;6536	00		.
	nop			;6537	00		.
	nop			;6538	00		.
	nop			;6539	00		.
	rst 38h			;653a	ff		.
	rst 38h			;653b	ff		.
	rst 38h			;653c	ff		.
	rst 38h			;653d	ff		.
	cp a			;653e	bf		.
	rst 38h			;653f	ff		.
	rst 38h			;6540	ff		.
	rst 38h			;6541	ff		.
	cp a			;6542	bf		.
	rst 38h			;6543	ff		.
	rst 38h			;6544	ff		.
	cp a			;6545	bf		.
	rst 38h			;6546	ff		.
	rst 38h			;6547	ff		.
	rst 38h			;6548	ff		.
	rst 38h			;6549	ff		.
	rst 38h			;654a	ff		.
	rst 38h			;654b	ff		.
	rst 38h			;654c	ff		.
	rst 38h			;654d	ff		.
	rst 38h			;654e	ff		.
	rst 38h			;654f	ff		.
	rst 38h			;6550	ff		.
	rst 38h			;6551	ff		.
	rst 38h			;6552	ff		.
	rst 38h			;6553	ff		.
	rst 38h			;6554	ff		.
	rst 38h			;6555	ff		.
	rst 38h			;6556	ff		.
	rst 38h			;6557	ff		.
	rst 38h			;6558	ff		.
	rst 38h			;6559	ff		.
	nop			;655a	00		.
	nop			;655b	00		.
	nop			;655c	00		.
	nop			;655d	00		.
	nop			;655e	00		.
	nop			;655f	00		.
	nop			;6560	00		.
	nop			;6561	00		.
	nop			;6562	00		.
	nop			;6563	00		.
	nop			;6564	00		.
	nop			;6565	00		.
	nop			;6566	00		.
	nop			;6567	00		.
	nop			;6568	00		.
	nop			;6569	00		.
	nop			;656a	00		.
	nop			;656b	00		.
	nop			;656c	00		.
	nop			;656d	00		.
	nop			;656e	00		.
	nop			;656f	00		.
	nop			;6570	00		.
	nop			;6571	00		.
l6572h:
	nop			;6572	00		.
	nop			;6573	00		.
	nop			;6574	00		.
	nop			;6575	00		.
	nop			;6576	00		.
	nop			;6577	00		.
	nop			;6578	00		.
	nop			;6579	00		.
	rst 38h			;657a	ff		.
	rst 38h			;657b	ff		.
	rst 38h			;657c	ff		.
	rst 38h			;657d	ff		.
	rst 38h			;657e	ff		.
	rst 38h			;657f	ff		.
	rst 38h			;6580	ff		.
	rst 38h			;6581	ff		.
	rst 38h			;6582	ff		.
	rst 38h			;6583	ff		.
	rst 38h			;6584	ff		.
	rst 38h			;6585	ff		.
	rst 38h			;6586	ff		.
	rst 38h			;6587	ff		.
	rst 38h			;6588	ff		.
	rst 38h			;6589	ff		.
	rst 38h			;658a	ff		.
	rst 38h			;658b	ff		.
	rst 38h			;658c	ff		.
	rst 38h			;658d	ff		.
	rst 38h			;658e	ff		.
	rst 38h			;658f	ff		.
	rst 38h			;6590	ff		.
	rst 38h			;6591	ff		.
	rst 38h			;6592	ff		.
	rst 38h			;6593	ff		.
	rst 38h			;6594	ff		.
	rst 38h			;6595	ff		.
	rst 30h			;6596	f7		.
	rst 38h			;6597	ff		.
	rst 38h			;6598	ff		.
	rst 38h			;6599	ff		.
	nop			;659a	00		.
	nop			;659b	00		.
	nop			;659c	00		.
	nop			;659d	00		.
	nop			;659e	00		.
	nop			;659f	00		.
	nop			;65a0	00		.
	nop			;65a1	00		.
	nop			;65a2	00		.
	nop			;65a3	00		.
	nop			;65a4	00		.
	nop			;65a5	00		.
	nop			;65a6	00		.
	nop			;65a7	00		.
	nop			;65a8	00		.
	nop			;65a9	00		.
	nop			;65aa	00		.
	nop			;65ab	00		.
	nop			;65ac	00		.
	nop			;65ad	00		.
	nop			;65ae	00		.
	nop			;65af	00		.
	nop			;65b0	00		.
	nop			;65b1	00		.
	nop			;65b2	00		.
	nop			;65b3	00		.
	nop			;65b4	00		.
	nop			;65b5	00		.
	nop			;65b6	00		.
	nop			;65b7	00		.
	nop			;65b8	00		.
	nop			;65b9	00		.
	rst 30h			;65ba	f7		.
	rst 38h			;65bb	ff		.
	rst 38h			;65bc	ff		.
	rst 38h			;65bd	ff		.
	rst 30h			;65be	f7		.
	rst 38h			;65bf	ff		.
	rst 30h			;65c0	f7		.
	rst 38h			;65c1	ff		.
	rst 30h			;65c2	f7		.
	rst 38h			;65c3	ff		.
	rst 30h			;65c4	f7		.
	rst 30h			;65c5	f7		.
	rst 38h			;65c6	ff		.
	rst 38h			;65c7	ff		.
	rst 38h			;65c8	ff		.
	rst 38h			;65c9	ff		.
	rst 38h			;65ca	ff		.
	rst 38h			;65cb	ff		.
	rst 38h			;65cc	ff		.
	rst 38h			;65cd	ff		.
	rst 38h			;65ce	ff		.
	rst 38h			;65cf	ff		.
	rst 38h			;65d0	ff		.
	rst 38h			;65d1	ff		.
	rst 38h			;65d2	ff		.
	rst 38h			;65d3	ff		.
	rst 38h			;65d4	ff		.
	rst 38h			;65d5	ff		.
	rst 38h			;65d6	ff		.
	rst 38h			;65d7	ff		.
	rst 38h			;65d8	ff		.
	rst 38h			;65d9	ff		.
	nop			;65da	00		.
	nop			;65db	00		.
	nop			;65dc	00		.
	nop			;65dd	00		.
	nop			;65de	00		.
	nop			;65df	00		.
	nop			;65e0	00		.
	nop			;65e1	00		.
	nop			;65e2	00		.
	nop			;65e3	00		.
	nop			;65e4	00		.
	nop			;65e5	00		.
	nop			;65e6	00		.
	nop			;65e7	00		.
	nop			;65e8	00		.
	nop			;65e9	00		.
	nop			;65ea	00		.
	nop			;65eb	00		.
	nop			;65ec	00		.
	nop			;65ed	00		.
	nop			;65ee	00		.
	nop			;65ef	00		.
	nop			;65f0	00		.
	nop			;65f1	00		.
	nop			;65f2	00		.
	nop			;65f3	00		.
	nop			;65f4	00		.
	nop			;65f5	00		.
	nop			;65f6	00		.
	nop			;65f7	00		.
	nop			;65f8	00		.
	nop			;65f9	00		.
	rst 38h			;65fa	ff		.
	rst 38h			;65fb	ff		.
	rst 38h			;65fc	ff		.
	rst 38h			;65fd	ff		.
	rst 38h			;65fe	ff		.
	rst 38h			;65ff	ff		.
	and 080h		;6600	e6 80		. .
	ld hl,l8060h		;6602	21 60 80	! ` .
	or (hl)			;6605	b6		.
	ld (hl),a		;6606	77		w
	dec (hl)		;6607	35		5
	call sub_74cbh		;6608	cd cb 74	. . t
	ld hl,00000h		;660b	21 00 00	! . .
	ld (l8065h),hl		;660e	22 65 80	" e .
	ld hl,l72ffh+1		;6611	21 00 73	! . s
	call sub_7425h		;6614	cd 25 74	. % t
	ld a,001h		;6617	3e 01		> .
	ld (l8060h),a		;6619	32 60 80	2 ` .
	jp 01000h		;661c	c3 00 10	. . .
	ld a,000h		;661f	3e 00		> .
	ld (l8069h),hl		;6621	22 69 80	" i .
	call l7720h+1		;6624	cd 21 77	. ! w
	jp c,l72c3h+1		;6627	da c4 72	. . r
	jp z,l7438h		;662a	ca 38 74	. 8 t
	ld a,006h		;662d	3e 06		> .
	jp l73c9h		;662f	c3 c9 73	. . s
	call sub_7481h		;6632	cd 81 74	. . t
	ld a,006h		;6635	3e 06		> .
	ld c,005h		;6637	0e 05		. .
	call sub_7583h		;6639	cd 83 75	. . u
	jp nc,l744ah		;663c	d2 4a 74	. J t
	ld a,028h		;663f	3e 28		> (
	jp l73c9h		;6641	c3 c9 73	. . s
	ld hl,(l8067h)		;6644	2a 67 80	* g .
	ex de,hl		;6647	eb		.
	ld hl,(l8065h)		;6648	2a 65 80	* e .
	add hl,de		;664b	19		.
	ld (l8065h),hl		;664c	22 65 80	" e .
	ld l,000h		;664f	2e 00		. .
	ld h,l			;6651	65		e
	ld (l8067h),hl		;6652	22 67 80	" g .
	call sub_7466h		;6655	cd 66 74	. f t
	ld a,(l8061h)		;6658	3a 61 80	: a .
	or a			;665b	b7		.
	ret z			;665c	c8		.
	jp l742ah		;665d	c3 2a 74	. * t
	ld a,001h		;6660	3e 01		> .
	ld (l8034h),a		;6662	32 34 80	2 4 .
	ld a,(l731fh+1)		;6665	3a 20 73	:   s
	and 002h		;6668	e6 02		. .
	rrca			;666a	0f		.
	ld hl,l8033h		;666b	21 33 80	! 3 .
	cp (hl)			;666e	be		.
	jp z,l747ah		;666f	ca 7a 74	. z t
	inc (hl)		;6672	34		4
	ret			;6673	c9		.
	xor a			;6674	af		.
	ld (hl),a		;6675	77		w
	ld hl,l8032h		;6676	21 32 80	! 2 .
	inc (hl)		;6679	34		4
	ret			;667a	c9		.
	ld hl,(l8069h)		;667b	2a 69 80	* i .
	push hl			;667e	e5		.
	call sub_7547h		;667f	cd 47 75	. G u
	call sub_74aeh		;6682	cd ae 74	. . t
	pop de			;6685	d1		.
	add hl,de		;6686	19		.
	jp nc,l749eh		;6687	d2 9e 74	. . t
	ld a,h			;668a	7c		|
	or l			;668b	b5		.
	jp z,l749eh		;668c	ca 9e 74	. . t
	ld a,001h		;668f	3e 01		> .
	ld (l8061h),a		;6691	32 61 80	2 a .
	ld (l8069h),hl		;6694	22 69 80	" i .
	ret			;6697	c9		.
	ld a,000h		;6698	3e 00		> .
	ld (l8061h),a		;669a	32 61 80	2 a .
	ld (l8069h),a		;669d	32 69 80	2 i .
	ld (l806ah),a		;66a0	32 6a 80	2 j .
	ex de,hl		;66a3	eb		.
	ld (l8067h),hl		;66a4	22 67 80	" g .
	ret			;66a7	c9		.
	push af			;66a8	f5		.
	ld a,l			;66a9	7d		}
	cpl			;66aa	2f		/
	ld l,a			;66ab	6f		o
	ld a,h			;66ac	7c		|
	cpl			;66ad	2f		/
	ld h,a			;66ae	67		g
	inc hl			;66af	23		#
	pop af			;66b0	f1		.
	ret			;66b1	c9		.
	ld a,(l731fh+1)		;66b2	3a 20 73	:   s
	and 01ch		;66b5	e6 1c		. .
	rra			;66b7	1f		.
	rra			;66b8	1f		.
	and 007h		;66b9	e6 07		. .
	ld (l8035h),a		;66bb	32 35 80	2 5 .
	call sub_750ah		;66be	cd 0a 75	. . u
	call sub_7547h		;66c1	cd 47 75	. G u
	ret			;66c4	c9		.
	ld a,(l731fh+1)		;66c5	3a 20 73	:   s
	and 0feh		;66c8	e6 fe		. .
	ld (l731fh+1),a		;66ca	32 20 73	2   s
	call l7720h+1		;66cd	cd 21 77	. ! w
	jp nz,l7508h		;66d0	c2 08 75	. . u
	ld l,004h		;66d3	2e 04		. .
	ld h,000h		;66d5	26 00		& .
	ld (l8067h),hl		;66d7	22 67 80	" g .
	ld a,00ah		;66da	3e 0a		> .
	ld c,001h		;66dc	0e 01		. .
	call sub_7583h		;66de	cd 83 75	. . u
	ld hl,l731fh+1		;66e1	21 20 73	!   s
	jp nc,l74f7h		;66e4	d2 f7 74	. . t
	ld a,(hl)		;66e7	7e		~
	and 001h		;66e8	e6 01		. .
	jp nz,l7508h		;66ea	c2 08 75	. . u
	inc (hl)		;66ed	34		4
	jp l74d3h		;66ee	c3 d3 74	. . t
	ld a,(l8016h)		;66f1	3a 16 80	: . .
	rlca			;66f4	07		.
	rlca			;66f5	07		.
	ld b,a			;66f6	47		G
	ld a,(hl)		;66f7	7e		~
	and 0e3h		;66f8	e6 e3		. .
	add a,b			;66fa	80		.
	ld (hl),a		;66fb	77		w
	call sub_74b8h		;66fc	cd b8 74	. . t
	scf			;66ff	37		7
	ccf			;6700	3f		?
	ret			;6701	c9		.
	scf			;6702	37		7
	ret			;6703	c9		.
	ld a,(l8035h)		;6704	3a 35 80	: 5 .
	rla			;6707	17		.
	rla			;6708	17		.
	ld e,a			;6709	5f		_
	ld d,000h		;670a	16 00		. .
	ld hl,l72d5h+1		;670c	21 d6 72	! . r
	ld a,(l731fh+1)		;670f	3a 20 73	:   s
	and 080h		;6712	e6 80		. .
	ld a,04ch		;6714	3e 4c		> L
	jp z,l7524h		;6716	ca 24 75	. $ u
	ld a,023h		;6719	3e 23		> #
	ld hl,l72e5h+1		;671b	21 e6 72	! . r
	ld (l800ch),a		;671e	32 0c 80	2 . .
	add hl,de		;6721	19		.
	ld a,(l731fh+1)		;6722	3a 20 73	:   s
	and 001h		;6725	e6 01		. .
	jp z,l7535h		;6727	ca 35 75	. 5 u
	ld e,002h		;672a	1e 02		. .
	ld d,000h		;672c	16 00		. .
	add hl,de		;672e	19		.
	ex de,hl		;672f	eb		.
	ld hl,l8036h		;6730	21 36 80	! 6 .
	ld a,(de)		;6733	1a		.
	ld (hl),a		;6734	77		w
	ld (l800dh),a		;6735	32 0d 80	2 . .
	inc hl			;6738	23		#
	inc de			;6739	13		.
	ld a,(de)		;673a	1a		.
	ld (hl),a		;673b	77		w
	inc hl			;673c	23		#
	ld a,080h		;673d	3e 80		> .
	ld (hl),a		;673f	77		w
	ret			;6740	c9		.
	ld hl,00080h		;6741	21 80 00	! . .
	ld a,(l8035h)		;6744	3a 35 80	: 5 .
	or a			;6747	b7		.
	jp z,l7556h		;6748	ca 56 75	. V u
	add hl,hl		;674b	29		)
	dec a			;674c	3d		=
	jp nz,l7551h		;674d	c2 51 75	. Q u
	ld (l8039h),hl		;6750	22 39 80	" 9 .
	ex de,hl		;6753	eb		.
	ld a,(l8034h)		;6754	3a 34 80	: 4 .
	ld l,a			;6757	6f		o
	ld a,(l8036h)		;6758	3a 36 80	: 6 .
	sub l			;675b	95		.
	inc a			;675c	3c		<
	ld l,a			;675d	6f		o
	ld a,(l8060h)		;675e	3a 60 80	: ` .
	and 080h		;6761	e6 80		. .
	jp z,l7576h		;6763	ca 76 75	. v u
	ld a,(l8033h)		;6766	3a 33 80	: 3 .
	xor 001h		;6769	ee 01		. .
	jp nz,l7576h		;676b	c2 76 75	. v u
	ld l,00ah		;676e	2e 0a		. .
	ld a,l			;6770	7d		}
	ld l,000h		;6771	2e 00		. .
	ld h,l			;6773	65		e
	add hl,de		;6774	19		.
	dec a			;6775	3d		=
	jp nz,l757ah		;6776	c2 7a 75	. z u
	ld (l8067h),hl		;6779	22 67 80	" g .
	ret			;677c	c9		.
	push af			;677d	f5		.
	ld a,c			;677e	79		y
	ld (l8062h),a		;677f	32 62 80	2 b .
	call l769ch+1		;6782	cd 9d 76	. . v
	ld hl,(l8067h)		;6785	2a 67 80	* g .
	ld b,h			;6788	44		D
	ld c,l			;6789	4d		M
	dec bc			;678a	0b		.
	ld hl,(l8065h)		;678b	2a 65 80	* e .
	pop af			;678e	f1		.
	push af			;678f	f5		.
	and 00fh		;6790	e6 0f		. .
	cp 00ah			;6792	fe 0a		. .
	call nz,sub_7632h	;6794	c4 32 76	. 2 v
	pop af			;6797	f1		.
	ld c,a			;6798	4f		O
	call sub_75ddh		;6799	cd dd 75	. . u
	ld a,0ffh		;679c	3e ff		> .
	call l76c2h+1		;679e	cd c3 76	. . v
	ret c			;67a1	d8		.
	ld a,c			;67a2	79		y
	call sub_75b3h		;67a3	cd b3 75	. . u
	ret nc			;67a6	d0		.
	ret z			;67a7	c8		.
	ld a,c			;67a8	79		y
	push af			;67a9	f5		.
	jp l7588h		;67aa	c3 88 75	. . u
	ld hl,l8010h		;67ad	21 10 80	! . .
	ld a,(hl)		;67b0	7e		~
	and 0c3h		;67b1	e6 c3		. .
	ld b,a			;67b3	47		G
	ld a,(l801bh)		;67b4	3a 1b 80	: . .
	cp b			;67b7	b8		.
	jp nz,l75d4h		;67b8	c2 d4 75	. . u
	inc hl			;67bb	23		#
	ld a,(hl)		;67bc	7e		~
	cp 000h			;67bd	fe 00		. .
	jp nz,l75d4h		;67bf	c2 d4 75	. . u
	inc hl			;67c2	23		#
	ld a,(hl)		;67c3	7e		~
	and 0bfh		;67c4	e6 bf		. .
	cp 000h			;67c6	fe 00		. .
	jp nz,l75d4h		;67c8	c2 d4 75	. . u
	scf			;67cb	37		7
	ccf			;67cc	3f		?
	ret			;67cd	c9		.
	ld a,(l8062h)		;67ce	3a 62 80	: b .
	dec a			;67d1	3d		=
	ld (l8062h),a		;67d2	32 62 80	2 b .
	scf			;67d5	37		7
	ret			;67d6	c9		.
	push bc			;67d7	c5		.
	push af			;67d8	f5		.
	di			;67d9	f3		.
	ld a,0ffh		;67da	3e ff		> .
	ld hl,l8030h		;67dc	21 30 80	! 0 .
	ld (l800bh),a		;67df	32 0b 80	2 . .
	ld a,(l731fh+1)		;67e2	3a 20 73	:   s
	and 001h		;67e5	e6 01		. .
	jp z,l75f2h		;67e7	ca f2 75	. . u
	ld a,040h		;67ea	3e 40		> @
	ld b,a			;67ec	47		G
	pop af			;67ed	f1		.
	push af			;67ee	f5		.
	add a,b			;67ef	80		.
	ld (hl),a		;67f0	77		w
	inc hl			;67f1	23		#
	call sub_76a4h		;67f2	cd a4 76	. . v
	ld (hl),a		;67f5	77		w
	dec hl			;67f6	2b		+
	pop af			;67f7	f1		.
	and 00fh		;67f8	e6 0f		. .
	cp 006h			;67fa	fe 06		. .
	ld c,009h		;67fc	0e 09		. .
	jp z,0ff09h		;67fe	ca 09 ff	. . .
	rst 38h			;6801	ff		.
	rst 38h			;6802	ff		.
	rst 38h			;6803	ff		.
	rst 38h			;6804	ff		.
	rst 38h			;6805	ff		.
	rst 38h			;6806	ff		.
	rst 38h			;6807	ff		.
	rst 38h			;6808	ff		.
	rst 38h			;6809	ff		.
	rst 38h			;680a	ff		.
	rst 38h			;680b	ff		.
	rst 38h			;680c	ff		.
	rst 38h			;680d	ff		.
	rst 38h			;680e	ff		.
	rst 38h			;680f	ff		.
	rst 38h			;6810	ff		.
	rst 38h			;6811	ff		.
	rst 38h			;6812	ff		.
	rst 38h			;6813	ff		.
	rst 18h			;6814	df		.
	rst 38h			;6815	ff		.
	rst 38h			;6816	ff		.
	rst 38h			;6817	ff		.
	rst 18h			;6818	df		.
	rst 38h			;6819	ff		.
	jr nz,l681ch		;681a	20 00		  .
l681ch:
	nop			;681c	00		.
	nop			;681d	00		.
	nop			;681e	00		.
	nop			;681f	00		.
	nop			;6820	00		.
	nop			;6821	00		.
	nop			;6822	00		.
	nop			;6823	00		.
	nop			;6824	00		.
	nop			;6825	00		.
	nop			;6826	00		.
	nop			;6827	00		.
	nop			;6828	00		.
	nop			;6829	00		.
	nop			;682a	00		.
	nop			;682b	00		.
	nop			;682c	00		.
	nop			;682d	00		.
	nop			;682e	00		.
	nop			;682f	00		.
	nop			;6830	00		.
	nop			;6831	00		.
	nop			;6832	00		.
	nop			;6833	00		.
	nop			;6834	00		.
	nop			;6835	00		.
	nop			;6836	00		.
	nop			;6837	00		.
	nop			;6838	00		.
	nop			;6839	00		.
	rst 38h			;683a	ff		.
	rst 38h			;683b	ff		.
	rst 38h			;683c	ff		.
	rst 38h			;683d	ff		.
	rst 38h			;683e	ff		.
	rst 38h			;683f	ff		.
	rst 38h			;6840	ff		.
	rst 38h			;6841	ff		.
	rst 38h			;6842	ff		.
	rst 38h			;6843	ff		.
	rst 38h			;6844	ff		.
	cp a			;6845	bf		.
	rst 38h			;6846	ff		.
	rst 38h			;6847	ff		.
	rst 38h			;6848	ff		.
	rst 38h			;6849	ff		.
	rst 38h			;684a	ff		.
	rst 38h			;684b	ff		.
	rst 38h			;684c	ff		.
	rst 38h			;684d	ff		.
	rst 38h			;684e	ff		.
	rst 38h			;684f	ff		.
	rst 38h			;6850	ff		.
	rst 38h			;6851	ff		.
	rst 38h			;6852	ff		.
	rst 38h			;6853	ff		.
	rst 38h			;6854	ff		.
	rst 38h			;6855	ff		.
	rst 38h			;6856	ff		.
	rst 38h			;6857	ff		.
	rst 38h			;6858	ff		.
	rst 38h			;6859	ff		.
	nop			;685a	00		.
	nop			;685b	00		.
	nop			;685c	00		.
	nop			;685d	00		.
	nop			;685e	00		.
	nop			;685f	00		.
	nop			;6860	00		.
	nop			;6861	00		.
	nop			;6862	00		.
	nop			;6863	00		.
	nop			;6864	00		.
	nop			;6865	00		.
	nop			;6866	00		.
	nop			;6867	00		.
	nop			;6868	00		.
	nop			;6869	00		.
	nop			;686a	00		.
	nop			;686b	00		.
	nop			;686c	00		.
	nop			;686d	00		.
	nop			;686e	00		.
	nop			;686f	00		.
	nop			;6870	00		.
	nop			;6871	00		.
	nop			;6872	00		.
	nop			;6873	00		.
	nop			;6874	00		.
	nop			;6875	00		.
	nop			;6876	00		.
	nop			;6877	00		.
	nop			;6878	00		.
	nop			;6879	00		.
	rst 38h			;687a	ff		.
	rst 38h			;687b	ff		.
	rst 38h			;687c	ff		.
	rst 38h			;687d	ff		.
	rst 38h			;687e	ff		.
	rst 38h			;687f	ff		.
	rst 38h			;6880	ff		.
	rst 38h			;6881	ff		.
	rst 38h			;6882	ff		.
	rst 38h			;6883	ff		.
	rst 38h			;6884	ff		.
	rst 38h			;6885	ff		.
	rst 38h			;6886	ff		.
	rst 38h			;6887	ff		.
	rst 38h			;6888	ff		.
	rst 38h			;6889	ff		.
	rst 38h			;688a	ff		.
	rst 38h			;688b	ff		.
	rst 38h			;688c	ff		.
	rst 38h			;688d	ff		.
	rst 38h			;688e	ff		.
	rst 38h			;688f	ff		.
	rst 38h			;6890	ff		.
	rst 38h			;6891	ff		.
	rst 38h			;6892	ff		.
	rst 38h			;6893	ff		.
	rst 38h			;6894	ff		.
	rst 38h			;6895	ff		.
	rst 38h			;6896	ff		.
	rst 38h			;6897	ff		.
	rst 38h			;6898	ff		.
	rst 38h			;6899	ff		.
	nop			;689a	00		.
	nop			;689b	00		.
	nop			;689c	00		.
	nop			;689d	00		.
	nop			;689e	00		.
	nop			;689f	00		.
	nop			;68a0	00		.
	nop			;68a1	00		.
	nop			;68a2	00		.
	nop			;68a3	00		.
	nop			;68a4	00		.
	nop			;68a5	00		.
	nop			;68a6	00		.
	nop			;68a7	00		.
	nop			;68a8	00		.
	nop			;68a9	00		.
	nop			;68aa	00		.
	nop			;68ab	00		.
	nop			;68ac	00		.
	nop			;68ad	00		.
	nop			;68ae	00		.
	nop			;68af	00		.
	nop			;68b0	00		.
	nop			;68b1	00		.
	nop			;68b2	00		.
	nop			;68b3	00		.
	nop			;68b4	00		.
	nop			;68b5	00		.
	nop			;68b6	00		.
	nop			;68b7	00		.
	nop			;68b8	00		.
	nop			;68b9	00		.
	rst 38h			;68ba	ff		.
	rst 38h			;68bb	ff		.
	rst 38h			;68bc	ff		.
	rst 38h			;68bd	ff		.
	rst 38h			;68be	ff		.
	rst 38h			;68bf	ff		.
	rst 38h			;68c0	ff		.
	rst 38h			;68c1	ff		.
	rst 38h			;68c2	ff		.
	rst 38h			;68c3	ff		.
	rst 38h			;68c4	ff		.
	rst 38h			;68c5	ff		.
	rst 38h			;68c6	ff		.
	rst 38h			;68c7	ff		.
	rst 38h			;68c8	ff		.
	rst 38h			;68c9	ff		.
	rst 38h			;68ca	ff		.
	rst 38h			;68cb	ff		.
	rst 38h			;68cc	ff		.
	rst 38h			;68cd	ff		.
	rst 38h			;68ce	ff		.
	rst 38h			;68cf	ff		.
	rst 38h			;68d0	ff		.
	rst 38h			;68d1	ff		.
	rst 38h			;68d2	ff		.
	rst 38h			;68d3	ff		.
	rst 38h			;68d4	ff		.
	rst 38h			;68d5	ff		.
	rst 38h			;68d6	ff		.
	rst 38h			;68d7	ff		.
	rst 38h			;68d8	ff		.
	rst 38h			;68d9	ff		.
	nop			;68da	00		.
	nop			;68db	00		.
	nop			;68dc	00		.
	nop			;68dd	00		.
	nop			;68de	00		.
	nop			;68df	00		.
	nop			;68e0	00		.
	nop			;68e1	00		.
	nop			;68e2	00		.
	nop			;68e3	00		.
	nop			;68e4	00		.
	nop			;68e5	00		.
	nop			;68e6	00		.
	nop			;68e7	00		.
	nop			;68e8	00		.
	nop			;68e9	00		.
	nop			;68ea	00		.
	nop			;68eb	00		.
	nop			;68ec	00		.
	nop			;68ed	00		.
	nop			;68ee	00		.
	nop			;68ef	00		.
	nop			;68f0	00		.
	nop			;68f1	00		.
	nop			;68f2	00		.
	nop			;68f3	00		.
	nop			;68f4	00		.
	nop			;68f5	00		.
	nop			;68f6	00		.
	nop			;68f7	00		.
	nop			;68f8	00		.
	nop			;68f9	00		.
	rst 38h			;68fa	ff		.
	rst 38h			;68fb	ff		.
	rst 38h			;68fc	ff		.
	rst 38h			;68fd	ff		.
	rst 38h			;68fe	ff		.
	rst 38h			;68ff	ff		.
	rst 38h			;6900	ff		.
	rst 38h			;6901	ff		.
	rst 38h			;6902	ff		.
	rst 38h			;6903	ff		.
	rst 38h			;6904	ff		.
	rst 38h			;6905	ff		.
	rst 38h			;6906	ff		.
	rst 38h			;6907	ff		.
	rst 38h			;6908	ff		.
	rst 38h			;6909	ff		.
	rst 38h			;690a	ff		.
	rst 38h			;690b	ff		.
	rst 38h			;690c	ff		.
	rst 38h			;690d	ff		.
	rst 38h			;690e	ff		.
	rst 38h			;690f	ff		.
	rst 38h			;6910	ff		.
	rst 38h			;6911	ff		.
	rst 38h			;6912	ff		.
	rst 38h			;6913	ff		.
	rst 38h			;6914	ff		.
	rst 38h			;6915	ff		.
	rst 38h			;6916	ff		.
	rst 38h			;6917	ff		.
	rst 38h			;6918	ff		.
	rst 38h			;6919	ff		.
	jr nz,l691ch		;691a	20 00		  .
l691ch:
	nop			;691c	00		.
	jr nz,l693fh		;691d	20 20		   
	nop			;691f	00		.
	nop			;6920	00		.
	nop			;6921	00		.
	nop			;6922	00		.
	nop			;6923	00		.
	nop			;6924	00		.
	nop			;6925	00		.
	nop			;6926	00		.
	nop			;6927	00		.
	nop			;6928	00		.
	nop			;6929	00		.
	nop			;692a	00		.
	nop			;692b	00		.
	nop			;692c	00		.
	nop			;692d	00		.
	nop			;692e	00		.
	nop			;692f	00		.
	nop			;6930	00		.
	nop			;6931	00		.
	nop			;6932	00		.
	nop			;6933	00		.
	nop			;6934	00		.
	nop			;6935	00		.
	nop			;6936	00		.
	nop			;6937	00		.
	nop			;6938	00		.
	nop			;6939	00		.
	rst 38h			;693a	ff		.
	rst 38h			;693b	ff		.
	rst 38h			;693c	ff		.
	rst 38h			;693d	ff		.
	rst 38h			;693e	ff		.
l693fh:
	rst 38h			;693f	ff		.
	rst 38h			;6940	ff		.
	rst 38h			;6941	ff		.
	rst 38h			;6942	ff		.
	rst 38h			;6943	ff		.
	rst 38h			;6944	ff		.
	rst 28h			;6945	ef		.
	rst 38h			;6946	ff		.
	rst 38h			;6947	ff		.
	rst 38h			;6948	ff		.
	rst 38h			;6949	ff		.
	rst 38h			;694a	ff		.
	rst 38h			;694b	ff		.
	rst 38h			;694c	ff		.
	rst 38h			;694d	ff		.
	rst 38h			;694e	ff		.
	rst 38h			;694f	ff		.
	rst 38h			;6950	ff		.
	rst 38h			;6951	ff		.
	rst 38h			;6952	ff		.
	rst 38h			;6953	ff		.
	rst 38h			;6954	ff		.
	rst 38h			;6955	ff		.
	rst 38h			;6956	ff		.
	rst 38h			;6957	ff		.
	rst 38h			;6958	ff		.
	rst 38h			;6959	ff		.
	nop			;695a	00		.
	nop			;695b	00		.
	nop			;695c	00		.
	nop			;695d	00		.
	nop			;695e	00		.
	nop			;695f	00		.
	nop			;6960	00		.
	nop			;6961	00		.
	nop			;6962	00		.
	nop			;6963	00		.
l6964h:
	nop			;6964	00		.
	nop			;6965	00		.
	nop			;6966	00		.
	nop			;6967	00		.
	nop			;6968	00		.
	nop			;6969	00		.
	nop			;696a	00		.
	nop			;696b	00		.
	nop			;696c	00		.
	nop			;696d	00		.
	nop			;696e	00		.
	nop			;696f	00		.
	nop			;6970	00		.
	nop			;6971	00		.
	nop			;6972	00		.
l6973h:
	nop			;6973	00		.
	nop			;6974	00		.
	nop			;6975	00		.
	nop			;6976	00		.
	nop			;6977	00		.
	nop			;6978	00		.
	nop			;6979	00		.
	rst 38h			;697a	ff		.
	rst 38h			;697b	ff		.
	rst 38h			;697c	ff		.
	rst 38h			;697d	ff		.
	rst 38h			;697e	ff		.
	rst 38h			;697f	ff		.
	rst 38h			;6980	ff		.
	rst 38h			;6981	ff		.
	rst 38h			;6982	ff		.
	rst 38h			;6983	ff		.
	rst 38h			;6984	ff		.
	rst 38h			;6985	ff		.
	rst 38h			;6986	ff		.
	rst 38h			;6987	ff		.
	rst 38h			;6988	ff		.
	rst 38h			;6989	ff		.
	rst 38h			;698a	ff		.
	rst 38h			;698b	ff		.
	rst 38h			;698c	ff		.
	rst 38h			;698d	ff		.
	rst 38h			;698e	ff		.
	rst 38h			;698f	ff		.
	rst 38h			;6990	ff		.
	rst 38h			;6991	ff		.
	rst 38h			;6992	ff		.
	rst 38h			;6993	ff		.
	rst 38h			;6994	ff		.
	rst 38h			;6995	ff		.
	rst 38h			;6996	ff		.
	rst 38h			;6997	ff		.
	rst 38h			;6998	ff		.
	rst 38h			;6999	ff		.
	nop			;699a	00		.
	nop			;699b	00		.
	nop			;699c	00		.
	nop			;699d	00		.
	nop			;699e	00		.
	nop			;699f	00		.
	nop			;69a0	00		.
	nop			;69a1	00		.
	nop			;69a2	00		.
	nop			;69a3	00		.
	nop			;69a4	00		.
	nop			;69a5	00		.
	nop			;69a6	00		.
	nop			;69a7	00		.
	nop			;69a8	00		.
	nop			;69a9	00		.
	nop			;69aa	00		.
	nop			;69ab	00		.
	nop			;69ac	00		.
	nop			;69ad	00		.
	nop			;69ae	00		.
	nop			;69af	00		.
	nop			;69b0	00		.
	nop			;69b1	00		.
	nop			;69b2	00		.
	nop			;69b3	00		.
	nop			;69b4	00		.
	nop			;69b5	00		.
	nop			;69b6	00		.
	nop			;69b7	00		.
	nop			;69b8	00		.
	nop			;69b9	00		.
	rst 38h			;69ba	ff		.
	rst 38h			;69bb	ff		.
	rst 38h			;69bc	ff		.
	rst 38h			;69bd	ff		.
	rst 38h			;69be	ff		.
	rst 38h			;69bf	ff		.
	rst 38h			;69c0	ff		.
	rst 38h			;69c1	ff		.
	rst 38h			;69c2	ff		.
	rst 38h			;69c3	ff		.
	rst 38h			;69c4	ff		.
	rst 38h			;69c5	ff		.
	rst 38h			;69c6	ff		.
	rst 38h			;69c7	ff		.
	rst 38h			;69c8	ff		.
	rst 38h			;69c9	ff		.
	rst 38h			;69ca	ff		.
	rst 38h			;69cb	ff		.
	rst 38h			;69cc	ff		.
	rst 38h			;69cd	ff		.
	rst 38h			;69ce	ff		.
	rst 38h			;69cf	ff		.
	rst 38h			;69d0	ff		.
	rst 38h			;69d1	ff		.
	rst 38h			;69d2	ff		.
	rst 38h			;69d3	ff		.
	rst 38h			;69d4	ff		.
	rst 38h			;69d5	ff		.
	rst 38h			;69d6	ff		.
	rst 38h			;69d7	ff		.
	rst 38h			;69d8	ff		.
	rst 38h			;69d9	ff		.
	nop			;69da	00		.
	nop			;69db	00		.
	nop			;69dc	00		.
	nop			;69dd	00		.
	nop			;69de	00		.
	nop			;69df	00		.
	nop			;69e0	00		.
	nop			;69e1	00		.
	nop			;69e2	00		.
	nop			;69e3	00		.
	nop			;69e4	00		.
	nop			;69e5	00		.
	nop			;69e6	00		.
	nop			;69e7	00		.
	nop			;69e8	00		.
	nop			;69e9	00		.
	nop			;69ea	00		.
	nop			;69eb	00		.
	nop			;69ec	00		.
	nop			;69ed	00		.
	nop			;69ee	00		.
	nop			;69ef	00		.
	nop			;69f0	00		.
	nop			;69f1	00		.
	nop			;69f2	00		.
	nop			;69f3	00		.
	nop			;69f4	00		.
	nop			;69f5	00		.
	nop			;69f6	00		.
	nop			;69f7	00		.
	nop			;69f8	00		.
	nop			;69f9	00		.
	rst 38h			;69fa	ff		.
	rst 38h			;69fb	ff		.
	rst 38h			;69fc	ff		.
	rst 38h			;69fd	ff		.
	rst 38h			;69fe	ff		.
	rst 38h			;69ff	ff		.
	halt			;6a00	76		v
	ld c,002h		;6a01	0e 02		. .
	ld a,(hl)		;6a03	7e		~
	inc hl			;6a04	23		#
	call sub_763ch		;6a05	cd 3c 76	. < v
	dec c			;6a08	0d		.
	jp nz,07609h		;6a09	c2 09 76	. . v
	pop bc			;6a0c	c1		.
	ei			;6a0d	fb		.
	ret			;6a0e	c9		.
	ld a,005h		;6a0f	3e 05		> .
	di			;6a11	f3		.
	out (0fah),a		;6a12	d3 fa		. .
	ld a,049h		;6a14	3e 49		> I
	out (0fbh),a		;6a16	d3 fb		. .
	out (0fch),a		;6a18	d3 fc		. .
	ld a,l			;6a1a	7d		}
	out (0f2h),a		;6a1b	d3 f2		. .
	ld a,h			;6a1d	7c		|
	out (0f2h),a		;6a1e	d3 f2		. .
	ld a,c			;6a20	79		y
	out (0f3h),a		;6a21	d3 f3		. .
	ld a,b			;6a23	78		x
	out (0f3h),a		;6a24	d3 f3		. .
	ld a,001h		;6a26	3e 01		> .
	out (0fah),a		;6a28	d3 fa		. .
	ei			;6a2a	fb		.
	ret			;6a2b	c9		.
	ld a,005h		;6a2c	3e 05		> .
	di			;6a2e	f3		.
	out (0fah),a		;6a2f	d3 fa		. .
	ld a,045h		;6a31	3e 45		> E
	jp l761ch		;6a33	c3 1c 76	. . v
	push af			;6a36	f5		.
	push bc			;6a37	c5		.
	ld b,000h		;6a38	06 00		. .
	ld c,000h		;6a3a	0e 00		. .
	inc b			;6a3c	04		.
	call z,sub_766ah	;6a3d	cc 6a 76	. j v
	in a,(004h)		;6a40	db 04		. .
	and 0c0h		;6a42	e6 c0		. .
	cp 080h			;6a44	fe 80		. .
	jp nz,l7642h		;6a46	c2 42 76	. B v
	pop bc			;6a49	c1		.
	pop af			;6a4a	f1		.
	out (005h),a		;6a4b	d3 05		. .
	ret			;6a4d	c9		.
	push bc			;6a4e	c5		.
	ld b,000h		;6a4f	06 00		. .
	ld c,000h		;6a51	0e 00		. .
	inc b			;6a53	04		.
	call z,sub_766ah	;6a54	cc 6a 76	. j v
	in a,(004h)		;6a57	db 04		. .
	and 0c0h		;6a59	e6 c0		. .
	cp 0c0h			;6a5b	fe c0		. .
	jp nz,l7658h+1		;6a5d	c2 59 76	. Y v
	pop bc			;6a60	c1		.
	in a,(005h)		;6a61	db 05		. .
	ret			;6a63	c9		.
	ld b,000h		;6a64	06 00		. .
	inc c			;6a66	0c		.
	ret nz			;6a67	c0		.
	ei			;6a68	fb		.
	jp l72c3h+1		;6a69	c3 c4 72	. . r
	ld a,004h		;6a6c	3e 04		> .
	call sub_763ch		;6a6e	cd 3c 76	. < v
	ld a,(l801bh)		;6a71	3a 1b 80	: . .
	call sub_763ch		;6a74	cd 3c 76	. < v
	call sub_7654h		;6a77	cd 54 76	. T v
	ld (l8010h),a		;6a7a	32 10 80	2 . .
	ret			;6a7d	c9		.
	ld a,008h		;6a7e	3e 08		> .
	call sub_763ch		;6a80	cd 3c 76	. < v
	call sub_7654h		;6a83	cd 54 76	. T v
	ld (l8010h),a		;6a86	32 10 80	2 . .
	and 0c0h		;6a89	e6 c0		. .
	cp 080h			;6a8b	fe 80		. .
	jp z,l769ch		;6a8d	ca 9c 76	. . v
	call sub_7654h		;6a90	cd 54 76	. T v
	ld (l8011h),a		;6a93	32 11 80	2 . .
	ret			;6a96	c9		.
	di			;6a97	f3		.
	xor a			;6a98	af		.
	ld (l8041h),a		;6a99	32 41 80	2 A .
	ei			;6a9c	fb		.
	ret			;6a9d	c9		.
	push de			;6a9e	d5		.
	ld a,(l8033h)		;6a9f	3a 33 80	: 3 .
	rla			;6aa2	17		.
	rla			;6aa3	17		.
	ld d,a			;6aa4	57		W
	ld a,(l801bh)		;6aa5	3a 1b 80	: . .
	add a,d			;6aa8	82		.
	pop de			;6aa9	d1		.
	ret			;6aaa	c9		.
	push af			;6aab	f5		.
	push hl			;6aac	e5		.
	ld h,c			;6aad	61		a
	ld l,0ffh		;6aae	2e ff		. .
	dec hl			;6ab0	2b		+
	ld a,l			;6ab1	7d		}
	or h			;6ab2	b4		.
	jp nz,l76b6h		;6ab3	c2 b6 76	. . v
	dec b			;6ab6	05		.
	jp nz,l76b2h+1		;6ab7	c2 b3 76	. . v
	pop hl			;6aba	e1		.
	pop af			;6abb	f1		.
	ret			;6abc	c9		.
	push bc			;6abd	c5		.
	dec a			;6abe	3d		=
	scf			;6abf	37		7
	jp z,l76deh+1		;6ac0	ca df 76	. . v
	ld b,001h		;6ac3	06 01		. .
	ld c,001h		;6ac5	0e 01		. .
	call l76b0h+1		;6ac7	cd b1 76	. . v
	ld b,a			;6aca	47		G
	ld a,(l8041h)		;6acb	3a 41 80	: A .
	and 002h		;6ace	e6 02		. .
	ld a,b			;6ad0	78		x
	jp z,l76c4h		;6ad1	ca c4 76	. . v
	scf			;6ad4	37		7
	ccf			;6ad5	3f		?
	call l769ch+1		;6ad6	cd 9d 76	. . v
	pop bc			;6ad9	c1		.
	ret			;6ada	c9		.
	ld a,0ffh		;6adb	3e ff		> .
	call l76c2h+1		;6add	cd c3 76	. . v
	ld a,(l8010h)		;6ae0	3a 10 80	: . .
	ld b,a			;6ae3	47		G
	ld a,(l8011h)		;6ae4	3a 11 80	: . .
	ld c,a			;6ae7	4f		O
	ret			;6ae8	c9		.
	ld a,007h		;6ae9	3e 07		> .
	call sub_763ch		;6aeb	cd 3c 76	. < v
	ld a,(l801bh)		;6aee	3a 1b 80	: . .
	call sub_763ch		;6af1	cd 3c 76	. < v
	ret			;6af4	c9		.
	ld a,00fh		;6af5	3e 0f		> .
	call sub_763ch		;6af7	cd 3c 76	. < v
	ld a,d			;6afa	7a		z
	and 007h		;6afb	e6 07		. .
	call sub_763ch		;6afd	cd 3c 76	. < v
	ld a,e			;6b00	7b		{
	call sub_763ch		;6b01	cd 3c 76	. < v
	ret			;6b04	c9		.
	call l76eeh+1		;6b05	cd ef 76	. . v
	call l76e0h+1		;6b08	cd e1 76	. . v
	ret c			;6b0b	d8		.
	ld a,(l801bh)		;6b0c	3a 1b 80	: . .
	add a,020h		;6b0f	c6 20		.  
	cp b			;6b11	b8		.
	jp nz,l771eh		;6b12	c2 1e 77	. . w
	ld a,c			;6b15	79		y
	cp 000h			;6b16	fe 00		. .
	scf			;6b18	37		7
	ccf			;6b19	3f		?
	ret			;6b1a	c9		.
	ld a,(l8032h)		;6b1b	3a 32 80	: 2 .
	ld e,a			;6b1e	5f		_
	call sub_76a4h		;6b1f	cd a4 76	. . v
	ld d,a			;6b22	57		W
	call l76fah+1		;6b23	cd fb 76	. . v
	call l76e0h+1		;6b26	cd e1 76	. . v
	ret c			;6b29	d8		.
	ld a,(l801bh)		;6b2a	3a 1b 80	: . .
	add a,020h		;6b2d	c6 20		.  
	cp b			;6b2f	b8		.
	jp nz,l773ch+1		;6b30	c2 3d 77	. = w
	ld a,(l8032h)		;6b33	3a 32 80	: 2 .
	cp c			;6b36	b9		.
	scf			;6b37	37		7
	ccf			;6b38	3f		?
	ret			;6b39	c9		.
	ld hl,l8010h		;6b3a	21 10 80	! . .
	ld b,007h		;6b3d	06 07		. .
	ld a,b			;6b3f	78		x
	ld (l800bh),a		;6b40	32 0b 80	2 . .
	call sub_7654h		;6b43	cd 54 76	. T v
	ld (hl),a		;6b46	77		w
	inc hl			;6b47	23		#
	ld a,(l801dh)		;6b48	3a 1d 80	: . .
	dec a			;6b4b	3d		=
	jp nz,l7750h+1		;6b4c	c2 51 77	. Q w
	in a,(004h)		;6b4f	db 04		. .
	and 010h		;6b51	e6 10		. .
	jp z,l7764h+1		;6b53	ca 65 77	. e w
	dec b			;6b56	05		.
	jp nz,l7748h+1		;6b57	c2 49 77	. I w
	ld a,0feh		;6b5a	3e fe		> .
	jp l73c9h		;6b5c	c3 c9 73	. . s
	in a,(0f8h)		;6b5f	db f8		. .
	ld (hl),a		;6b61	77		w
	dec b			;6b62	05		.
	ret z			;6b63	c8		.
	ei			;6b64	fb		.
	ld a,0fdh		;6b65	3e fd		> .
	jp l73c9h		;6b67	c3 c9 73	. . s
	push af			;6b6a	f5		.
	push bc			;6b6b	c5		.
	push hl			;6b6c	e5		.
	ld a,002h		;6b6d	3e 02		> .
	ld (l8041h),a		;6b6f	32 41 80	2 A .
	ld a,(l801ch)		;6b72	3a 1c 80	: . .
	dec a			;6b75	3d		=
	jp nz,l777ah+1		;6b76	c2 7b 77	. { w
	in a,(004h)		;6b79	db 04		. .
	and 010h		;6b7b	e6 10		. .
	jp nz,l778ch		;6b7d	c2 8c 77	. . w
	call sub_7684h		;6b80	cd 84 76	. . v
	jp l778eh+1		;6b83	c3 8f 77	. . w
	call sub_7740h		;6b86	cd 40 77	. @ w
	pop hl			;6b89	e1		.
	pop bc			;6b8a	c1		.
	pop af			;6b8b	f1		.
	ei			;6b8c	fb		.
	reti			;6b8d	ed 4d		. M
	nop			;6b8f	00		.
	nop			;6b90	00		.
	di			;6b91	f3		.
	rst 38h			;6b92	ff		.
	rst 38h			;6b93	ff		.
	rst 38h			;6b94	ff		.
	rst 38h			;6b95	ff		.
	rst 38h			;6b96	ff		.
	rst 38h			;6b97	ff		.
	rst 38h			;6b98	ff		.
	rst 38h			;6b99	ff		.
	nop			;6b9a	00		.
	nop			;6b9b	00		.
	nop			;6b9c	00		.
	nop			;6b9d	00		.
	nop			;6b9e	00		.
	nop			;6b9f	00		.
	nop			;6ba0	00		.
	nop			;6ba1	00		.
	nop			;6ba2	00		.
	nop			;6ba3	00		.
	nop			;6ba4	00		.
	nop			;6ba5	00		.
	nop			;6ba6	00		.
	nop			;6ba7	00		.
	nop			;6ba8	00		.
	nop			;6ba9	00		.
	nop			;6baa	00		.
	nop			;6bab	00		.
	nop			;6bac	00		.
	nop			;6bad	00		.
	nop			;6bae	00		.
	nop			;6baf	00		.
	nop			;6bb0	00		.
	nop			;6bb1	00		.
	nop			;6bb2	00		.
	nop			;6bb3	00		.
	nop			;6bb4	00		.
	nop			;6bb5	00		.
	nop			;6bb6	00		.
	nop			;6bb7	00		.
	nop			;6bb8	00		.
	nop			;6bb9	00		.
	rst 38h			;6bba	ff		.
	rst 38h			;6bbb	ff		.
	rst 38h			;6bbc	ff		.
	rst 38h			;6bbd	ff		.
	rst 38h			;6bbe	ff		.
	rst 38h			;6bbf	ff		.
	rst 38h			;6bc0	ff		.
	rst 38h			;6bc1	ff		.
	rst 38h			;6bc2	ff		.
	rst 38h			;6bc3	ff		.
	rst 38h			;6bc4	ff		.
	cp a			;6bc5	bf		.
	rst 38h			;6bc6	ff		.
	rst 38h			;6bc7	ff		.
	rst 38h			;6bc8	ff		.
	rst 38h			;6bc9	ff		.
	rst 38h			;6bca	ff		.
	rst 38h			;6bcb	ff		.
	rst 38h			;6bcc	ff		.
	rst 38h			;6bcd	ff		.
	rst 38h			;6bce	ff		.
	rst 38h			;6bcf	ff		.
	rst 38h			;6bd0	ff		.
	rst 38h			;6bd1	ff		.
	rst 38h			;6bd2	ff		.
	rst 38h			;6bd3	ff		.
	rst 38h			;6bd4	ff		.
	rst 38h			;6bd5	ff		.
	rst 38h			;6bd6	ff		.
	rst 38h			;6bd7	ff		.
	rst 38h			;6bd8	ff		.
	rst 38h			;6bd9	ff		.
	nop			;6bda	00		.
	nop			;6bdb	00		.
	nop			;6bdc	00		.
	nop			;6bdd	00		.
	nop			;6bde	00		.
	nop			;6bdf	00		.
	nop			;6be0	00		.
	nop			;6be1	00		.
	nop			;6be2	00		.
	nop			;6be3	00		.
	nop			;6be4	00		.
	nop			;6be5	00		.
	nop			;6be6	00		.
	nop			;6be7	00		.
	nop			;6be8	00		.
	nop			;6be9	00		.
	nop			;6bea	00		.
	nop			;6beb	00		.
	nop			;6bec	00		.
	nop			;6bed	00		.
	nop			;6bee	00		.
	nop			;6bef	00		.
	nop			;6bf0	00		.
	nop			;6bf1	00		.
	nop			;6bf2	00		.
	nop			;6bf3	00		.
	nop			;6bf4	00		.
	nop			;6bf5	00		.
	nop			;6bf6	00		.
	nop			;6bf7	00		.
	nop			;6bf8	00		.
	nop			;6bf9	00		.
	jr nz,l6c4eh		;6bfa	20 52		  R
	ld b,e			;6bfc	43		C
	scf			;6bfd	37		7
	jr nc,l6c30h		;6bfe	30 30		0 0
	rst 38h			;6c00	ff		.
	rst 38h			;6c01	ff		.
	rst 38h			;6c02	ff		.
	rst 38h			;6c03	ff		.
	rst 38h			;6c04	ff		.
	rst 38h			;6c05	ff		.
	rst 38h			;6c06	ff		.
	rst 38h			;6c07	ff		.
	rst 38h			;6c08	ff		.
	rst 38h			;6c09	ff		.
	rst 38h			;6c0a	ff		.
	rst 38h			;6c0b	ff		.
	rst 38h			;6c0c	ff		.
	rst 38h			;6c0d	ff		.
	rst 38h			;6c0e	ff		.
	rst 38h			;6c0f	ff		.
	rst 38h			;6c10	ff		.
	rst 38h			;6c11	ff		.
	rst 38h			;6c12	ff		.
	rst 38h			;6c13	ff		.
	rst 38h			;6c14	ff		.
	rst 38h			;6c15	ff		.
	rst 38h			;6c16	ff		.
	rst 38h			;6c17	ff		.
	rst 38h			;6c18	ff		.
	rst 38h			;6c19	ff		.
	jr nz,l6c1ch		;6c1a	20 00		  .
l6c1ch:
	nop			;6c1c	00		.
	nop			;6c1d	00		.
	jr nz,l6c20h		;6c1e	20 00		  .
l6c20h:
	nop			;6c20	00		.
	nop			;6c21	00		.
	nop			;6c22	00		.
	nop			;6c23	00		.
	nop			;6c24	00		.
	nop			;6c25	00		.
	nop			;6c26	00		.
	nop			;6c27	00		.
	nop			;6c28	00		.
	nop			;6c29	00		.
	nop			;6c2a	00		.
	nop			;6c2b	00		.
	nop			;6c2c	00		.
	nop			;6c2d	00		.
	nop			;6c2e	00		.
	nop			;6c2f	00		.
l6c30h:
	nop			;6c30	00		.
	nop			;6c31	00		.
	nop			;6c32	00		.
	nop			;6c33	00		.
	nop			;6c34	00		.
	nop			;6c35	00		.
	nop			;6c36	00		.
	nop			;6c37	00		.
	nop			;6c38	00		.
	nop			;6c39	00		.
	rst 38h			;6c3a	ff		.
	rst 38h			;6c3b	ff		.
	rst 38h			;6c3c	ff		.
	rst 38h			;6c3d	ff		.
	rst 38h			;6c3e	ff		.
	rst 38h			;6c3f	ff		.
	rst 38h			;6c40	ff		.
	rst 38h			;6c41	ff		.
	rst 38h			;6c42	ff		.
	rst 38h			;6c43	ff		.
	rst 38h			;6c44	ff		.
	rst 38h			;6c45	ff		.
	rst 38h			;6c46	ff		.
	rst 38h			;6c47	ff		.
	rst 38h			;6c48	ff		.
	rst 38h			;6c49	ff		.
	rst 38h			;6c4a	ff		.
	rst 38h			;6c4b	ff		.
	rst 38h			;6c4c	ff		.
	rst 38h			;6c4d	ff		.
l6c4eh:
	rst 38h			;6c4e	ff		.
	rst 38h			;6c4f	ff		.
	rst 38h			;6c50	ff		.
	rst 38h			;6c51	ff		.
	rst 38h			;6c52	ff		.
	rst 38h			;6c53	ff		.
	rst 38h			;6c54	ff		.
	rst 38h			;6c55	ff		.
	rst 38h			;6c56	ff		.
	rst 38h			;6c57	ff		.
	rst 38h			;6c58	ff		.
	rst 38h			;6c59	ff		.
	nop			;6c5a	00		.
	nop			;6c5b	00		.
	nop			;6c5c	00		.
	nop			;6c5d	00		.
	nop			;6c5e	00		.
	nop			;6c5f	00		.
	nop			;6c60	00		.
	nop			;6c61	00		.
	nop			;6c62	00		.
	nop			;6c63	00		.
	nop			;6c64	00		.
	nop			;6c65	00		.
	nop			;6c66	00		.
	nop			;6c67	00		.
	nop			;6c68	00		.
	nop			;6c69	00		.
	nop			;6c6a	00		.
	nop			;6c6b	00		.
	nop			;6c6c	00		.
	nop			;6c6d	00		.
	nop			;6c6e	00		.
	nop			;6c6f	00		.
	nop			;6c70	00		.
	nop			;6c71	00		.
	nop			;6c72	00		.
	nop			;6c73	00		.
	nop			;6c74	00		.
	nop			;6c75	00		.
	nop			;6c76	00		.
	nop			;6c77	00		.
	nop			;6c78	00		.
	nop			;6c79	00		.
	rst 38h			;6c7a	ff		.
	rst 38h			;6c7b	ff		.
	rst 38h			;6c7c	ff		.
	rst 38h			;6c7d	ff		.
	rst 38h			;6c7e	ff		.
	rst 38h			;6c7f	ff		.
	rst 38h			;6c80	ff		.
	rst 38h			;6c81	ff		.
	rst 38h			;6c82	ff		.
	rst 38h			;6c83	ff		.
	rst 38h			;6c84	ff		.
	rst 38h			;6c85	ff		.
	rst 38h			;6c86	ff		.
	rst 38h			;6c87	ff		.
	rst 38h			;6c88	ff		.
	rst 38h			;6c89	ff		.
	rst 38h			;6c8a	ff		.
	rst 38h			;6c8b	ff		.
	rst 38h			;6c8c	ff		.
	rst 38h			;6c8d	ff		.
	rst 38h			;6c8e	ff		.
	rst 38h			;6c8f	ff		.
	rst 38h			;6c90	ff		.
	rst 38h			;6c91	ff		.
	rst 38h			;6c92	ff		.
	rst 38h			;6c93	ff		.
	rst 38h			;6c94	ff		.
	rst 38h			;6c95	ff		.
	rst 38h			;6c96	ff		.
	rst 38h			;6c97	ff		.
	rst 38h			;6c98	ff		.
	rst 38h			;6c99	ff		.
	nop			;6c9a	00		.
	nop			;6c9b	00		.
	nop			;6c9c	00		.
	nop			;6c9d	00		.
	nop			;6c9e	00		.
	nop			;6c9f	00		.
	nop			;6ca0	00		.
	nop			;6ca1	00		.
	nop			;6ca2	00		.
	nop			;6ca3	00		.
	nop			;6ca4	00		.
	nop			;6ca5	00		.
	nop			;6ca6	00		.
	nop			;6ca7	00		.
	nop			;6ca8	00		.
	nop			;6ca9	00		.
	nop			;6caa	00		.
	nop			;6cab	00		.
	nop			;6cac	00		.
	nop			;6cad	00		.
	nop			;6cae	00		.
	nop			;6caf	00		.
	nop			;6cb0	00		.
	nop			;6cb1	00		.
	nop			;6cb2	00		.
	nop			;6cb3	00		.
	nop			;6cb4	00		.
	nop			;6cb5	00		.
	nop			;6cb6	00		.
	nop			;6cb7	00		.
	nop			;6cb8	00		.
	nop			;6cb9	00		.
	rst 38h			;6cba	ff		.
	rst 38h			;6cbb	ff		.
	rst 38h			;6cbc	ff		.
	rst 38h			;6cbd	ff		.
	rst 38h			;6cbe	ff		.
	rst 38h			;6cbf	ff		.
	rst 38h			;6cc0	ff		.
	rst 38h			;6cc1	ff		.
	rst 38h			;6cc2	ff		.
	rst 38h			;6cc3	ff		.
	rst 38h			;6cc4	ff		.
	rst 38h			;6cc5	ff		.
	rst 38h			;6cc6	ff		.
	rst 38h			;6cc7	ff		.
	rst 38h			;6cc8	ff		.
	rst 38h			;6cc9	ff		.
	rst 38h			;6cca	ff		.
	rst 38h			;6ccb	ff		.
	rst 38h			;6ccc	ff		.
	rst 38h			;6ccd	ff		.
	rst 38h			;6cce	ff		.
	rst 38h			;6ccf	ff		.
	rst 38h			;6cd0	ff		.
	rst 38h			;6cd1	ff		.
	rst 38h			;6cd2	ff		.
	rst 38h			;6cd3	ff		.
	rst 38h			;6cd4	ff		.
	rst 38h			;6cd5	ff		.
	rst 38h			;6cd6	ff		.
	rst 38h			;6cd7	ff		.
	rst 38h			;6cd8	ff		.
	rst 38h			;6cd9	ff		.
	nop			;6cda	00		.
	nop			;6cdb	00		.
	nop			;6cdc	00		.
	nop			;6cdd	00		.
	nop			;6cde	00		.
	nop			;6cdf	00		.
	nop			;6ce0	00		.
	nop			;6ce1	00		.
	nop			;6ce2	00		.
	nop			;6ce3	00		.
	nop			;6ce4	00		.
	nop			;6ce5	00		.
	nop			;6ce6	00		.
	nop			;6ce7	00		.
	nop			;6ce8	00		.
	nop			;6ce9	00		.
	nop			;6cea	00		.
	nop			;6ceb	00		.
	nop			;6cec	00		.
	nop			;6ced	00		.
	nop			;6cee	00		.
	nop			;6cef	00		.
	nop			;6cf0	00		.
	nop			;6cf1	00		.
	nop			;6cf2	00		.
	nop			;6cf3	00		.
	nop			;6cf4	00		.
	nop			;6cf5	00		.
	nop			;6cf6	00		.
	nop			;6cf7	00		.
	nop			;6cf8	00		.
	nop			;6cf9	00		.
	rst 38h			;6cfa	ff		.
	rst 38h			;6cfb	ff		.
	rst 38h			;6cfc	ff		.
	rst 38h			;6cfd	ff		.
	rst 38h			;6cfe	ff		.
	rst 38h			;6cff	ff		.
	rst 38h			;6d00	ff		.
	rst 38h			;6d01	ff		.
	rst 38h			;6d02	ff		.
	rst 38h			;6d03	ff		.
	rst 38h			;6d04	ff		.
	rst 38h			;6d05	ff		.
	rst 38h			;6d06	ff		.
	rst 38h			;6d07	ff		.
	rst 38h			;6d08	ff		.
	rst 38h			;6d09	ff		.
	rst 38h			;6d0a	ff		.
	rst 38h			;6d0b	ff		.
	rst 38h			;6d0c	ff		.
	rst 38h			;6d0d	ff		.
	rst 38h			;6d0e	ff		.
	rst 38h			;6d0f	ff		.
	rst 38h			;6d10	ff		.
	rst 38h			;6d11	ff		.
	rst 38h			;6d12	ff		.
	rst 38h			;6d13	ff		.
	rst 38h			;6d14	ff		.
	rst 38h			;6d15	ff		.
	rst 38h			;6d16	ff		.
	rst 38h			;6d17	ff		.
	rst 18h			;6d18	df		.
	rst 38h			;6d19	ff		.
	jr nz,l6d1ch		;6d1a	20 00		  .
l6d1ch:
	nop			;6d1c	00		.
	nop			;6d1d	00		.
	jr nz,l6d20h		;6d1e	20 00		  .
l6d20h:
	nop			;6d20	00		.
	nop			;6d21	00		.
	nop			;6d22	00		.
	nop			;6d23	00		.
	nop			;6d24	00		.
	nop			;6d25	00		.
	nop			;6d26	00		.
	nop			;6d27	00		.
	nop			;6d28	00		.
	nop			;6d29	00		.
	nop			;6d2a	00		.
	nop			;6d2b	00		.
	nop			;6d2c	00		.
	nop			;6d2d	00		.
	nop			;6d2e	00		.
	nop			;6d2f	00		.
	nop			;6d30	00		.
	nop			;6d31	00		.
	nop			;6d32	00		.
	nop			;6d33	00		.
	nop			;6d34	00		.
	nop			;6d35	00		.
	nop			;6d36	00		.
	nop			;6d37	00		.
	nop			;6d38	00		.
	nop			;6d39	00		.
	rst 38h			;6d3a	ff		.
	rst 38h			;6d3b	ff		.
	rst 38h			;6d3c	ff		.
	rst 38h			;6d3d	ff		.
	cp a			;6d3e	bf		.
	rst 38h			;6d3f	ff		.
	rst 38h			;6d40	ff		.
	rst 38h			;6d41	ff		.
	cp a			;6d42	bf		.
	rst 38h			;6d43	ff		.
	rst 38h			;6d44	ff		.
	cp a			;6d45	bf		.
	rst 38h			;6d46	ff		.
	rst 38h			;6d47	ff		.
	rst 38h			;6d48	ff		.
	rst 38h			;6d49	ff		.
	rst 38h			;6d4a	ff		.
	rst 38h			;6d4b	ff		.
	rst 38h			;6d4c	ff		.
	rst 38h			;6d4d	ff		.
	rst 38h			;6d4e	ff		.
	rst 38h			;6d4f	ff		.
	rst 38h			;6d50	ff		.
	rst 38h			;6d51	ff		.
	rst 38h			;6d52	ff		.
	rst 38h			;6d53	ff		.
	rst 38h			;6d54	ff		.
	rst 38h			;6d55	ff		.
	rst 38h			;6d56	ff		.
	rst 38h			;6d57	ff		.
	rst 38h			;6d58	ff		.
	rst 38h			;6d59	ff		.
	nop			;6d5a	00		.
	nop			;6d5b	00		.
	nop			;6d5c	00		.
	nop			;6d5d	00		.
	nop			;6d5e	00		.
	nop			;6d5f	00		.
	nop			;6d60	00		.
	nop			;6d61	00		.
	nop			;6d62	00		.
	nop			;6d63	00		.
	nop			;6d64	00		.
	nop			;6d65	00		.
	nop			;6d66	00		.
	nop			;6d67	00		.
	nop			;6d68	00		.
	nop			;6d69	00		.
	nop			;6d6a	00		.
	nop			;6d6b	00		.
	nop			;6d6c	00		.
	nop			;6d6d	00		.
	nop			;6d6e	00		.
	nop			;6d6f	00		.
	nop			;6d70	00		.
	nop			;6d71	00		.
	nop			;6d72	00		.
	nop			;6d73	00		.
	nop			;6d74	00		.
	nop			;6d75	00		.
	nop			;6d76	00		.
	nop			;6d77	00		.
	nop			;6d78	00		.
	nop			;6d79	00		.
	rst 38h			;6d7a	ff		.
	rst 38h			;6d7b	ff		.
	rst 38h			;6d7c	ff		.
	rst 38h			;6d7d	ff		.
	rst 38h			;6d7e	ff		.
	rst 38h			;6d7f	ff		.
	rst 38h			;6d80	ff		.
	rst 38h			;6d81	ff		.
	rst 38h			;6d82	ff		.
	rst 38h			;6d83	ff		.
	rst 38h			;6d84	ff		.
	rst 38h			;6d85	ff		.
	rst 38h			;6d86	ff		.
	rst 38h			;6d87	ff		.
	rst 38h			;6d88	ff		.
	rst 38h			;6d89	ff		.
	rst 38h			;6d8a	ff		.
	rst 38h			;6d8b	ff		.
	rst 38h			;6d8c	ff		.
	rst 38h			;6d8d	ff		.
	rst 38h			;6d8e	ff		.
	rst 38h			;6d8f	ff		.
	rst 38h			;6d90	ff		.
	rst 38h			;6d91	ff		.
	rst 38h			;6d92	ff		.
	rst 38h			;6d93	ff		.
	rst 38h			;6d94	ff		.
	rst 38h			;6d95	ff		.
	rst 38h			;6d96	ff		.
	rst 38h			;6d97	ff		.
	rst 38h			;6d98	ff		.
	rst 38h			;6d99	ff		.
	nop			;6d9a	00		.
	nop			;6d9b	00		.
	nop			;6d9c	00		.
	nop			;6d9d	00		.
	nop			;6d9e	00		.
	nop			;6d9f	00		.
	nop			;6da0	00		.
	nop			;6da1	00		.
	nop			;6da2	00		.
	nop			;6da3	00		.
	nop			;6da4	00		.
	nop			;6da5	00		.
	nop			;6da6	00		.
	nop			;6da7	00		.
	nop			;6da8	00		.
	nop			;6da9	00		.
	nop			;6daa	00		.
	nop			;6dab	00		.
	nop			;6dac	00		.
	nop			;6dad	00		.
	nop			;6dae	00		.
	nop			;6daf	00		.
	nop			;6db0	00		.
	nop			;6db1	00		.
	nop			;6db2	00		.
	nop			;6db3	00		.
	nop			;6db4	00		.
	nop			;6db5	00		.
	nop			;6db6	00		.
	nop			;6db7	00		.
	nop			;6db8	00		.
	nop			;6db9	00		.
	rst 38h			;6dba	ff		.
	rst 38h			;6dbb	ff		.
	rst 38h			;6dbc	ff		.
	rst 38h			;6dbd	ff		.
	rst 38h			;6dbe	ff		.
	rst 38h			;6dbf	ff		.
	rst 38h			;6dc0	ff		.
	rst 38h			;6dc1	ff		.
	rst 38h			;6dc2	ff		.
	rst 38h			;6dc3	ff		.
	rst 38h			;6dc4	ff		.
	rst 38h			;6dc5	ff		.
	rst 38h			;6dc6	ff		.
	rst 38h			;6dc7	ff		.
	rst 38h			;6dc8	ff		.
	rst 38h			;6dc9	ff		.
	rst 38h			;6dca	ff		.
	rst 38h			;6dcb	ff		.
	rst 38h			;6dcc	ff		.
	rst 38h			;6dcd	ff		.
	rst 38h			;6dce	ff		.
	rst 38h			;6dcf	ff		.
	rst 38h			;6dd0	ff		.
	rst 38h			;6dd1	ff		.
	rst 38h			;6dd2	ff		.
	rst 38h			;6dd3	ff		.
	rst 38h			;6dd4	ff		.
	rst 38h			;6dd5	ff		.
	rst 38h			;6dd6	ff		.
	rst 38h			;6dd7	ff		.
	rst 38h			;6dd8	ff		.
	rst 38h			;6dd9	ff		.
	nop			;6dda	00		.
	nop			;6ddb	00		.
	nop			;6ddc	00		.
	nop			;6ddd	00		.
	nop			;6dde	00		.
	nop			;6ddf	00		.
	nop			;6de0	00		.
	nop			;6de1	00		.
	nop			;6de2	00		.
	nop			;6de3	00		.
	nop			;6de4	00		.
	nop			;6de5	00		.
	nop			;6de6	00		.
	nop			;6de7	00		.
	nop			;6de8	00		.
	nop			;6de9	00		.
	nop			;6dea	00		.
	nop			;6deb	00		.
	nop			;6dec	00		.
	nop			;6ded	00		.
	nop			;6dee	00		.
	nop			;6def	00		.
	nop			;6df0	00		.
	nop			;6df1	00		.
	nop			;6df2	00		.
	nop			;6df3	00		.
	nop			;6df4	00		.
	nop			;6df5	00		.
	nop			;6df6	00		.
	nop			;6df7	00		.
	nop			;6df8	00		.
	nop			;6df9	00		.
	ld bc,l7800h		;6dfa	01 00 78	. . x
	ld de,0707dh		;6dfd	11 7d 70	. } p
	jr nz,l6e22h		;6e00	20 20		   
	jr nz,l6e24h		;6e02	20 20		   
	jr nz,l6e26h		;6e04	20 20		   
	jr nz,l6e28h		;6e06	20 20		   
	jr nz,l6e2ah		;6e08	20 20		   
	jr nz,l6e2ch		;6e0a	20 20		   
	jr nz,l6e2eh		;6e0c	20 20		   
	jr nz,l6e30h		;6e0e	20 20		   
	jr nz,l6e32h		;6e10	20 20		   
	jr nz,l6e34h		;6e12	20 20		   
	jr nz,l6e36h		;6e14	20 20		   
	jr nz,l6e38h		;6e16	20 20		   
	jr nz,l6e3ah		;6e18	20 20		   
	jr nz,l6e3ch		;6e1a	20 20		   
	jr nz,l6e3eh		;6e1c	20 20		   
	jr nz,l6e40h		;6e1e	20 20		   
l6e20h:
	jr nz,l6e42h		;6e20	20 20		   
l6e22h:
	jr nz,l6e44h		;6e22	20 20		   
l6e24h:
	jr nz,l6e46h		;6e24	20 20		   
l6e26h:
	jr nz,l6e48h		;6e26	20 20		   
l6e28h:
	jr nz,l6e4ah		;6e28	20 20		   
l6e2ah:
	jr nz,l6e4ch		;6e2a	20 20		   
l6e2ch:
	jr nz,l6e4eh		;6e2c	20 20		   
l6e2eh:
	jr nz,l6e50h		;6e2e	20 20		   
l6e30h:
	jr nz,l6e52h		;6e30	20 20		   
l6e32h:
	jr nz,l6e54h		;6e32	20 20		   
l6e34h:
	jr nz,l6e56h		;6e34	20 20		   
l6e36h:
	jr nz,l6e58h		;6e36	20 20		   
l6e38h:
	jr nz,l6e5ah		;6e38	20 20		   
l6e3ah:
	jr nz,l6e5ch		;6e3a	20 20		   
l6e3ch:
	jr nz,l6e5eh		;6e3c	20 20		   
l6e3eh:
	jr nz,l6e60h		;6e3e	20 20		   
l6e40h:
	jr nz,l6e62h		;6e40	20 20		   
l6e42h:
	jr nz,l6e64h		;6e42	20 20		   
l6e44h:
	jr nz,l6e66h		;6e44	20 20		   
l6e46h:
	jr nz,l6e68h		;6e46	20 20		   
l6e48h:
	jr nz,l6e6ah		;6e48	20 20		   
l6e4ah:
	jr nz,l6e6ch		;6e4a	20 20		   
l6e4ch:
	jr nz,l6e6eh		;6e4c	20 20		   
l6e4eh:
	jr nz,l6e70h		;6e4e	20 20		   
l6e50h:
	jr nz,l6e72h		;6e50	20 20		   
l6e52h:
	jr nz,l6e74h		;6e52	20 20		   
l6e54h:
	jr nz,l6e76h		;6e54	20 20		   
l6e56h:
	jr nz,l6e78h		;6e56	20 20		   
l6e58h:
	jr nz,l6e7ah		;6e58	20 20		   
l6e5ah:
	jr nz,l6e7ch		;6e5a	20 20		   
l6e5ch:
	jr nz,l6e7eh		;6e5c	20 20		   
l6e5eh:
	jr nz,l6e80h		;6e5e	20 20		   
l6e60h:
	jr nz,l6e82h		;6e60	20 20		   
l6e62h:
	jr nz,l6e84h		;6e62	20 20		   
l6e64h:
	jr nz,l6e86h		;6e64	20 20		   
l6e66h:
	jr nz,l6e88h		;6e66	20 20		   
l6e68h:
	jr nz,l6e8ah		;6e68	20 20		   
l6e6ah:
	jr nz,l6e8ch		;6e6a	20 20		   
l6e6ch:
	jr nz,l6e8eh		;6e6c	20 20		   
l6e6eh:
	jr nz,l6e90h		;6e6e	20 20		   
l6e70h:
	jr nz,l6e92h		;6e70	20 20		   
l6e72h:
	jr nz,l6e94h		;6e72	20 20		   
l6e74h:
	jr nz,l6e96h		;6e74	20 20		   
l6e76h:
	jr nz,l6e98h		;6e76	20 20		   
l6e78h:
	jr nz,l6e9ah		;6e78	20 20		   
l6e7ah:
	jr nz,l6e9ch		;6e7a	20 20		   
l6e7ch:
	jr nz,l6e9eh		;6e7c	20 20		   
l6e7eh:
	jr nz,l6ea0h		;6e7e	20 20		   
l6e80h:
	jr nz,l6ea2h		;6e80	20 20		   
l6e82h:
	jr nz,l6ea4h		;6e82	20 20		   
l6e84h:
	jr nz,l6ea6h		;6e84	20 20		   
l6e86h:
	jr nz,l6ea8h		;6e86	20 20		   
l6e88h:
	jr nz,l6eaah		;6e88	20 20		   
l6e8ah:
	jr nz,l6each		;6e8a	20 20		   
l6e8ch:
	jr nz,l6eaeh		;6e8c	20 20		   
l6e8eh:
	jr nz,l6eb0h		;6e8e	20 20		   
l6e90h:
	jr nz,l6eb2h		;6e90	20 20		   
l6e92h:
	jr nz,l6eb4h		;6e92	20 20		   
l6e94h:
	jr nz,l6eb6h		;6e94	20 20		   
l6e96h:
	jr nz,l6eb8h		;6e96	20 20		   
l6e98h:
	jr nz,l6ebah		;6e98	20 20		   
l6e9ah:
	jr nz,l6ebch		;6e9a	20 20		   
l6e9ch:
	jr nz,l6ebeh		;6e9c	20 20		   
l6e9eh:
	jr nz,l6ec0h		;6e9e	20 20		   
l6ea0h:
	jr nz,l6ec2h		;6ea0	20 20		   
l6ea2h:
	jr nz,l6ec4h		;6ea2	20 20		   
l6ea4h:
	jr nz,l6ec6h		;6ea4	20 20		   
l6ea6h:
	jr nz,l6ec8h		;6ea6	20 20		   
l6ea8h:
	jr nz,l6ecah		;6ea8	20 20		   
l6eaah:
	jr nz,l6ecch		;6eaa	20 20		   
l6each:
	jr nz,l6eceh		;6eac	20 20		   
l6eaeh:
	jr nz,l6ed0h		;6eae	20 20		   
l6eb0h:
	jr nz,l6ed2h		;6eb0	20 20		   
l6eb2h:
	jr nz,l6ed4h		;6eb2	20 20		   
l6eb4h:
	jr nz,l6ed6h		;6eb4	20 20		   
l6eb6h:
	jr nz,l6ed8h		;6eb6	20 20		   
l6eb8h:
	jr nz,l6edah		;6eb8	20 20		   
l6ebah:
	jr nz,l6edch		;6eba	20 20		   
l6ebch:
	jr nz,l6edeh		;6ebc	20 20		   
l6ebeh:
	jr nz,l6ee0h		;6ebe	20 20		   
l6ec0h:
	jr nz,l6ee2h		;6ec0	20 20		   
l6ec2h:
	jr nz,l6ee4h		;6ec2	20 20		   
l6ec4h:
	jr nz,l6ee6h		;6ec4	20 20		   
l6ec6h:
	jr nz,l6ee8h		;6ec6	20 20		   
l6ec8h:
	jr nz,l6eeah		;6ec8	20 20		   
l6ecah:
	jr nz,l6eech		;6eca	20 20		   
l6ecch:
	jr nz,l6eeeh		;6ecc	20 20		   
l6eceh:
	jr nz,l6ef0h		;6ece	20 20		   
l6ed0h:
	jr nz,l6ef2h		;6ed0	20 20		   
l6ed2h:
	jr nz,l6ef4h		;6ed2	20 20		   
l6ed4h:
	jr nz,l6ef6h		;6ed4	20 20		   
l6ed6h:
	jr nz,l6ef8h		;6ed6	20 20		   
l6ed8h:
	jr nz,l6efah		;6ed8	20 20		   
l6edah:
	jr nz,l6efch		;6eda	20 20		   
l6edch:
	jr nz,l6efeh		;6edc	20 20		   
l6edeh:
	jr nz,l6f00h		;6ede	20 20		   
l6ee0h:
	jr nz,l6f02h		;6ee0	20 20		   
l6ee2h:
	jr nz,l6f04h		;6ee2	20 20		   
l6ee4h:
	jr nz,l6f06h		;6ee4	20 20		   
l6ee6h:
	jr nz,l6f08h		;6ee6	20 20		   
l6ee8h:
	jr nz,l6f0ah		;6ee8	20 20		   
l6eeah:
	jr nz,l6f0ch		;6eea	20 20		   
l6eech:
	jr nz,l6f0eh		;6eec	20 20		   
l6eeeh:
	jr nz,l6f10h		;6eee	20 20		   
l6ef0h:
	jr nz,l6f12h		;6ef0	20 20		   
l6ef2h:
	jr nz,l6f14h		;6ef2	20 20		   
l6ef4h:
	jr nz,l6f16h		;6ef4	20 20		   
l6ef6h:
	jr nz,l6f18h		;6ef6	20 20		   
l6ef8h:
	jr nz,l6f1ah		;6ef8	20 20		   
l6efah:
	jr nz,l6f1ch		;6efa	20 20		   
l6efch:
	jr nz,l6f1eh		;6efc	20 20		   
l6efeh:
	jr nz,l6f20h		;6efe	20 20		   
l6f00h:
	jr nz,l6f22h		;6f00	20 20		   
l6f02h:
	jr nz,l6f24h		;6f02	20 20		   
l6f04h:
	jr nz,l6f26h		;6f04	20 20		   
l6f06h:
	jr nz,l6f28h		;6f06	20 20		   
l6f08h:
	jr nz,l6f2ah		;6f08	20 20		   
l6f0ah:
	jr nz,l6f2ch		;6f0a	20 20		   
l6f0ch:
	jr nz,l6f2eh		;6f0c	20 20		   
l6f0eh:
	jr nz,l6f30h		;6f0e	20 20		   
l6f10h:
	jr nz,l6f32h		;6f10	20 20		   
l6f12h:
	jr nz,l6f34h		;6f12	20 20		   
l6f14h:
	jr nz,l6f36h		;6f14	20 20		   
l6f16h:
	jr nz,l6f38h		;6f16	20 20		   
l6f18h:
	jr nz,l6f3ah		;6f18	20 20		   
l6f1ah:
	jr nz,l6f3ch		;6f1a	20 20		   
l6f1ch:
	jr nz,l6f3eh		;6f1c	20 20		   
l6f1eh:
	jr nz,l6f40h		;6f1e	20 20		   
l6f20h:
	jr nz,l6f42h		;6f20	20 20		   
l6f22h:
	jr nz,l6f44h		;6f22	20 20		   
l6f24h:
	jr nz,l6f46h		;6f24	20 20		   
l6f26h:
	jr nz,l6f48h		;6f26	20 20		   
l6f28h:
	jr nz,l6f4ah		;6f28	20 20		   
l6f2ah:
	jr nz,l6f4ch		;6f2a	20 20		   
l6f2ch:
	jr nz,l6f4eh		;6f2c	20 20		   
l6f2eh:
	jr nz,l6f50h		;6f2e	20 20		   
l6f30h:
	jr nz,l6f52h		;6f30	20 20		   
l6f32h:
	jr nz,l6f54h		;6f32	20 20		   
l6f34h:
	jr nz,l6f56h		;6f34	20 20		   
l6f36h:
	jr nz,l6f58h		;6f36	20 20		   
l6f38h:
	jr nz,l6f5ah		;6f38	20 20		   
l6f3ah:
	jr nz,l6f5ch		;6f3a	20 20		   
l6f3ch:
	jr nz,l6f5eh		;6f3c	20 20		   
l6f3eh:
	jr nz,l6f60h		;6f3e	20 20		   
l6f40h:
	jr nz,l6f62h		;6f40	20 20		   
l6f42h:
	jr nz,l6f64h		;6f42	20 20		   
l6f44h:
	jr nz,l6f66h		;6f44	20 20		   
l6f46h:
	jr nz,l6f68h		;6f46	20 20		   
l6f48h:
	jr nz,l6f6ah		;6f48	20 20		   
l6f4ah:
	jr nz,l6f6ch		;6f4a	20 20		   
l6f4ch:
	jr nz,l6f6eh		;6f4c	20 20		   
l6f4eh:
	jr nz,l6f70h		;6f4e	20 20		   
l6f50h:
	jr nz,l6f72h		;6f50	20 20		   
l6f52h:
	jr nz,l6f74h		;6f52	20 20		   
l6f54h:
	jr nz,l6f76h		;6f54	20 20		   
l6f56h:
	jr nz,l6f78h		;6f56	20 20		   
l6f58h:
	jr nz,l6f7ah		;6f58	20 20		   
l6f5ah:
	jr nz,l6f7ch		;6f5a	20 20		   
l6f5ch:
	jr nz,l6f7eh		;6f5c	20 20		   
l6f5eh:
	jr nz,l6f80h		;6f5e	20 20		   
l6f60h:
	jr nz,l6f82h		;6f60	20 20		   
l6f62h:
	jr nz,l6f84h		;6f62	20 20		   
l6f64h:
	jr nz,l6f86h		;6f64	20 20		   
l6f66h:
	jr nz,l6f88h		;6f66	20 20		   
l6f68h:
	jr nz,l6f8ah		;6f68	20 20		   
l6f6ah:
	jr nz,l6f8ch		;6f6a	20 20		   
l6f6ch:
	jr nz,l6f8eh		;6f6c	20 20		   
l6f6eh:
	jr nz,l6f90h		;6f6e	20 20		   
l6f70h:
	jr nz,l6f92h		;6f70	20 20		   
l6f72h:
	jr nz,l6f94h		;6f72	20 20		   
l6f74h:
	jr nz,l6f96h		;6f74	20 20		   
l6f76h:
	jr nz,l6f98h		;6f76	20 20		   
l6f78h:
	jr nz,l6f9ah		;6f78	20 20		   
l6f7ah:
	jr nz,l6f9ch		;6f7a	20 20		   
l6f7ch:
	jr nz,l6f9eh		;6f7c	20 20		   
l6f7eh:
	jr nz,l6fa0h		;6f7e	20 20		   
l6f80h:
	jr nz,l6fa2h		;6f80	20 20		   
l6f82h:
	jr nz,l6fa4h		;6f82	20 20		   
l6f84h:
	jr nz,l6fa6h		;6f84	20 20		   
l6f86h:
	jr nz,l6fa8h		;6f86	20 20		   
l6f88h:
	jr nz,l6faah		;6f88	20 20		   
l6f8ah:
	jr nz,l6fach		;6f8a	20 20		   
l6f8ch:
	jr nz,l6faeh		;6f8c	20 20		   
l6f8eh:
	jr nz,l6fb0h		;6f8e	20 20		   
l6f90h:
	jr nz,l6fb2h		;6f90	20 20		   
l6f92h:
	jr nz,l6fb4h		;6f92	20 20		   
l6f94h:
	jr nz,l6fb6h		;6f94	20 20		   
l6f96h:
	jr nz,l6fb8h		;6f96	20 20		   
l6f98h:
	jr nz,l6fbah		;6f98	20 20		   
l6f9ah:
	jr nz,l6fbch		;6f9a	20 20		   
l6f9ch:
	jr nz,l6fbeh		;6f9c	20 20		   
l6f9eh:
	jr nz,l6fc0h		;6f9e	20 20		   
l6fa0h:
	jr nz,l6fc2h		;6fa0	20 20		   
l6fa2h:
	jr nz,l6fc4h		;6fa2	20 20		   
l6fa4h:
	jr nz,l6fc6h		;6fa4	20 20		   
l6fa6h:
	jr nz,l6fc8h		;6fa6	20 20		   
l6fa8h:
	jr nz,l6fcah		;6fa8	20 20		   
l6faah:
	jr nz,l6fcch		;6faa	20 20		   
l6fach:
	jr nz,l6fceh		;6fac	20 20		   
l6faeh:
	jr nz,l6fd0h		;6fae	20 20		   
l6fb0h:
	jr nz,l6fd2h		;6fb0	20 20		   
l6fb2h:
	jr nz,l6fd4h		;6fb2	20 20		   
l6fb4h:
	jr nz,l6fd6h		;6fb4	20 20		   
l6fb6h:
	jr nz,l6fd8h		;6fb6	20 20		   
l6fb8h:
	jr nz,l6fdah		;6fb8	20 20		   
l6fbah:
	jr nz,l6fdch		;6fba	20 20		   
l6fbch:
	jr nz,l6fdeh		;6fbc	20 20		   
l6fbeh:
	jr nz,l6fe0h		;6fbe	20 20		   
l6fc0h:
	jr nz,l6fe2h		;6fc0	20 20		   
l6fc2h:
	jr nz,l6fe4h		;6fc2	20 20		   
l6fc4h:
	jr nz,l6fe6h		;6fc4	20 20		   
l6fc6h:
	jr nz,l6fe8h		;6fc6	20 20		   
l6fc8h:
	jr nz,l6feah		;6fc8	20 20		   
l6fcah:
	jr nz,l6fech		;6fca	20 20		   
l6fcch:
	jr nz,l6feeh		;6fcc	20 20		   
l6fceh:
	jr nz,l6ff0h		;6fce	20 20		   
l6fd0h:
	jr nz,l6ff2h		;6fd0	20 20		   
l6fd2h:
	jr nz,l6ff4h		;6fd2	20 20		   
l6fd4h:
	jr nz,l6ff6h		;6fd4	20 20		   
l6fd6h:
	jr nz,l6ff8h		;6fd6	20 20		   
l6fd8h:
	jr nz,l6ffah		;6fd8	20 20		   
l6fdah:
	jr nz,l6ffch		;6fda	20 20		   
l6fdch:
	jr nz,l6ffeh		;6fdc	20 20		   
l6fdeh:
	jr nz,l7000h		;6fde	20 20		   
l6fe0h:
	jr nz,$+34		;6fe0	20 20		   
l6fe2h:
	jr nz,$+34		;6fe2	20 20		   
l6fe4h:
	jr nz,l7006h		;6fe4	20 20		   
l6fe6h:
	jr nz,$+34		;6fe6	20 20		   
l6fe8h:
	jr nz,$+34		;6fe8	20 20		   
l6feah:
	jr nz,l700ch		;6fea	20 20		   
l6fech:
	jr nz,$+34		;6fec	20 20		   
l6feeh:
	jr nz,$+34		;6fee	20 20		   
l6ff0h:
	jr nz,l7012h		;6ff0	20 20		   
l6ff2h:
	jr nz,$+34		;6ff2	20 20		   
l6ff4h:
	jr nz,$+34		;6ff4	20 20		   
l6ff6h:
	jr nz,l7018h		;6ff6	20 20		   
l6ff8h:
	jr nz,$+34		;6ff8	20 20		   
l6ffah:
	jr nz,$+34		;6ffa	20 20		   
l6ffch:
	jr nz,l701eh		;6ffc	20 20		   
l6ffeh:
	jr nz,$+34		;6ffe	20 20		   
l7000h:
	ld hl,00014h		;7000	21 14 00	! . .
	call 07068h		;7003	cd 68 70	. h p
l7006h:
	jp l73d9h+1		;7006	c3 da 73	. . s
	ld bc,l7800h		;7009	01 00 78	. . x
l700ch:
	ld de,070b0h		;700c	11 b0 70	. . p
l700fh:
	ld hl,0000fh		;700f	21 0f 00	! . .
l7012h:
	call 07068h		;7012	cd 68 70	. h p
	jp l73d9h+1		;7015	c3 da 73	. . s
l7018h:
	ld bc,l7800h		;7018	01 00 78	. . x
	ld de,07092h		;701b	11 92 70	. . p
l701eh:
	ld hl,0001dh		;701e	21 1d 00	! . .
	call 07068h		;7021	cd 68 70	. h p
	jp l73d9h+1		;7024	c3 da 73	. . s
	push hl			;7027	e5		.
	inc hl			;7028	23		#
	ex de,hl		;7029	eb		.
	ld bc,l70c3h		;702a	01 c3 70	. . p
sub_702dh:
	ld hl,00004h		;702d	21 04 00	! . .
	call sub_705ch		;7030	cd 5c 70	. \ p
	pop hl			;7033	e1		.
	jp z,l704fh		;7034	ca 4f 70	. O p
	ret			;7037	c9		.
	push hl			;7038	e5		.
	inc hl			;7039	23		#
	ex de,hl		;703a	eb		.
	ld bc,l70c8h		;703b	01 c8 70	. . p
sub_703eh:
	ld hl,00004h		;703e	21 04 00	! . .
	call sub_705ch		;7041	cd 5c 70	. \ p
	pop hl			;7044	e1		.
	jp z,l704fh		;7045	ca 4f 70	. O p
	ret			;7048	c9		.
	push hl			;7049	e5		.
	inc hl			;704a	23		#
	ld de,00007h		;704b	11 07 00	. . .
	add hl,de		;704e	19		.
l704fh:
	ld a,(hl)		;704f	7e		~
	and 03fh		;7050	e6 3f		. ?
	cp 013h			;7052	fe 13		. .
	pop hl			;7054	e1		.
	ret			;7055	c9		.
	ld a,(de)		;7056	1a		.
	ld h,a			;7057	67		g
	ld a,(bc)		;7058	0a		.
	cp h			;7059	bc		.
	ret nz			;705a	c0		.
	inc de			;705b	13		.
sub_705ch:
	inc bc			;705c	03		.
	dec l			;705d	2d		-
	jp nz,sub_705ch		;705e	c2 5c 70	. \ p
	ret			;7061	c9		.
	ld a,(de)		;7062	1a		.
	ld (bc),a		;7063	02		.
	inc bc			;7064	03		.
	inc de			;7065	13		.
	dec l			;7066	2d		-
	jp nz,07068h		;7067	c2 68 70	. h p
	ret			;706a	c9		.
	jr nz,l70bfh		;706b	20 52		  R
	ld b,e			;706d	43		C
	scf			;706e	37		7
	jr nc,l70a1h		;706f	30 30		0 0
l7071h:
	jr nz,l70c5h		;7071	20 52		  R
	ld b,e			;7073	43		C
	scf			;7074	37		7
	jr nc,$+52		;7075	30 32		0 2
l7077h:
	jr nz,l70a3h		;7077	20 2a		  *
	ld hl,(04f4eh)		;7079	2a 4e 4f	* N O
	jr nz,l70d1h		;707c	20 53		  S
	ld e,c			;707e	59		Y
	ld d,e			;707f	53		S
	ld d,h			;7080	54		T
	ld b,l			;7081	45		E
	ld c,l			;7082	4d		M
	jr nz,$+72		;7083	20 46		  F
	ld c,c			;7085	49		I
	ld c,h			;7086	4c		L
	ld b,l			;7087	45		E
	ld d,e			;7088	53		S
	ld hl,(l202ah)		;7089	2a 2a 20	* *  
	jr nz,$+44		;708c	20 2a		  *
	ld hl,(04f4eh)		;708e	2a 4e 4f	* N O
	jr nz,l70d7h		;7091	20 44		  D
	ld c,c			;7093	49		I
	ld d,e			;7094	53		S
	ld c,e			;7095	4b		K
	ld b,l			;7096	45		E
	ld d,h			;7097	54		T
	ld d,h			;7098	54		T
	ld b,l			;7099	45		E
	jr nz,l70eah		;709a	20 4e		  N
	ld c,a			;709c	4f		O
	ld d,d			;709d	52		R
	jr nz,l70ech		;709e	20 4c		  L
	ld c,c			;70a0	49		I
l70a1h:
	ld c,(hl)		;70a1	4e		N
	ld b,l			;70a2	45		E
l70a3h:
	ld d,b			;70a3	50		P
	ld d,d			;70a4	52		R
	ld c,a			;70a5	4f		O
	ld b,a			;70a6	47		G
	ld hl,(l202ah)		;70a7	2a 2a 20	* *  
	jr nz,$+44		;70aa	20 2a		  *
	ld hl,(04f4eh)		;70ac	2a 4e 4f	* N O
	jr nz,$+77		;70af	20 4b		  K
	ld b,c			;70b1	41		A
	ld d,h			;70b2	54		T
	ld b,c			;70b3	41		A
	ld c,h			;70b4	4c		L
	ld c,a			;70b5	4f		O
	ld b,a			;70b6	47		G
	ld hl,(l202ah)		;70b7	2a 2a 20	* *  
	ld (bc),a		;70ba	02		.
	jp l53c8h		;70bb	c3 c8 53	. . S
	ld e,c			;70be	59		Y
l70bfh:
	ld d,e			;70bf	53		S
	ld c,l			;70c0	4d		M
	jr nz,l7116h		;70c1	20 53		  S
l70c3h:
	ld e,c			;70c3	59		Y
	ld d,e			;70c4	53		S
l70c5h:
	ld b,e			;70c5	43		C
	jr nz,$-59		;70c6	20 c3		  .
l70c8h:
	ld h,d			;70c8	62		b
	ld (hl),e		;70c9	73		s
	ld sp,0bfffh		;70ca	31 ff bf	1 . .
	ld a,073h		;70cd	3e 73		> s
	ld i,a			;70cf	ed 47		. G
l70d1h:
	im 2			;70d1	ed 5e		. ^
	ld c,0ffh		;70d3	0e ff		. .
	ld b,001h		;70d5	06 01		. .
l70d7h:
	call l76b0h+1		;70d7	cd b1 76	. . v
	ld a,099h		;70da	3e 99		> .
	call 070e9h		;70dc	cd e9 70	. . p
	ld hl,00027h		;70df	21 27 00	! ' .
	jp (hl)			;70e2	e9		.
	push af			;70e3	f5		.
	ld a,002h		;70e4	3e 02		> .
	out (012h),a		;70e6	d3 12		. .
	ld a,004h		;70e8	3e 04		> .
l70eah:
	out (013h),a		;70ea	d3 13		. .
l70ech:
	ld a,04fh		;70ec	3e 4f		> O
	out (012h),a		;70ee	d3 12		. .
	ld a,00fh		;70f0	3e 0f		> .
	out (013h),a		;70f2	d3 13		. .
	ld a,083h		;70f4	3e 83		> .
	out (012h),a		;70f6	d3 12		. .
	out (013h),a		;70f8	d3 13		. .
	jp 07103h		;70fa	c3 03 71	. . q
	ld a,008h		;70fd	3e 08		> .
	out (00ch),a		;70ff	d3 0c		. .
	pop af			;7101	f1		.
	ld a,046h		;7102	3e 46		> F
	or 041h			;7104	f6 41		. A
	out (00ch),a		;7106	d3 0c		. .
	ld a,020h		;7108	3e 20		>  
	out (00ch),a		;710a	d3 0c		. .
	ld a,046h		;710c	3e 46		> F
	or 041h			;710e	f6 41		. A
	out (00dh),a		;7110	d3 0d		. .
	ld a,020h		;7112	3e 20		>  
	out (00dh),a		;7114	d3 0d		. .
l7116h:
	ld a,0d7h		;7116	3e d7		> .
	out (00eh),a		;7118	d3 0e		. .
	ld a,001h		;711a	3e 01		> .
	out (00eh),a		;711c	d3 0e		. .
	ld a,0d7h		;711e	3e d7		> .
	out (00fh),a		;7120	d3 0f		. .
	ld a,001h		;7122	3e 01		> .
	out (00fh),a		;7124	d3 0f		. .
	jp l712fh		;7126	c3 2f 71	. / q
	ld a,020h		;7129	3e 20		>  
	out (0f8h),a		;712b	d3 f8		. .
	ld a,0c0h		;712d	3e c0		> .
l712fh:
	out (0fbh),a		;712f	d3 fb		. .
	ld a,000h		;7131	3e 00		> .
	out (0fah),a		;7133	d3 fa		. .
	ld a,04ah		;7135	3e 4a		> J
	out (0fbh),a		;7137	d3 fb		. .
	ld a,04bh		;7139	3e 4b		> K
	out (0fbh),a		;713b	d3 fb		. .
	jp l7146h		;713d	c3 46 71	. F q
	ld a,000h		;7140	3e 00		> .
	out (001h),a		;7142	d3 01		. .
	ld a,04fh		;7144	3e 4f		> O
l7146h:
	out (000h),a		;7146	d3 00		. .
	ld a,098h		;7148	3e 98		> .
	out (000h),a		;714a	d3 00		. .
	ld a,09ah		;714c	3e 9a		> .
	out (000h),a		;714e	d3 00		. .
	ld a,05dh		;7150	3e 5d		> ]
	out (000h),a		;7152	d3 00		. .
	ld a,080h		;7154	3e 80		> .
	out (001h),a		;7156	d3 01		. .
	xor a			;7158	af		.
	out (000h),a		;7159	d3 00		. .
	out (000h),a		;715b	d3 00		. .
	ld a,0e0h		;715d	3e e0		> .
	out (001h),a		;715f	d3 01		. .
	jp 0716eh		;7161	c3 6e 71	. n q
	inc bc			;7164	03		.
	inc bc			;7165	03		.
	ld c,a			;7166	4f		O
	jr nz,$+16		;7167	20 0e		  .
	rst 38h			;7169	ff		.
l716ah:
	ld b,001h		;716a	06 01		. .
	call l76b0h+1		;716c	cd b1 76	. . v
	in a,(004h)		;716f	db 04		. .
	and 01fh		;7171	e6 1f		. .
	jp nz,0716eh		;7173	c2 6e 71	. n q
	ld hl,l716ah		;7176	21 6a 71	! j q
	ld b,(hl)		;7179	46		F
	inc hl			;717a	23		#
	in a,(004h)		;717b	db 04		. .
	and 0c0h		;717d	e6 c0		. .
	cp 080h			;717f	fe 80		. .
l7181h:
	jp nz,l7181h		;7181	c2 81 71	. . q
	ld a,(hl)		;7184	7e		~
	out (005h),a		;7185	d3 05		. .
	dec b			;7187	05		.
	jp nz,07180h		;7188	c2 80 71	. . q
	jp 07194h		;718b	c3 94 71	. . q
	ld hl,00000h		;718e	21 00 00	! . .
	ex de,hl		;7191	eb		.
	ld hl,l7800h		;7192	21 00 78	! . x
	add hl,de		;7195	19		.
	ld a,020h		;7196	3e 20		>  
l7198h:
	ld (hl),a		;7198	77		w
	ld a,e			;7199	7b		{
	cp 0cfh			;719a	fe cf		. .
	jp z,l71a9h		;719c	ca a9 71	. . q
	inc de			;719f	13		.
	jp l7198h		;71a0	c3 98 71	. . q
	ld a,d			;71a3	7a		z
	cp 007h			;71a4	fe 07		. .
	jp z,l71b3h		;71a6	ca b3 71	. . q
l71a9h:
	inc de			;71a9	13		.
	jp l7198h		;71aa	c3 98 71	. . q
	ld de,l7071h		;71ad	11 71 70	. q p
	ld hl,00006h		;71b0	21 06 00	! . .
l71b3h:
	ld bc,l7800h		;71b3	01 00 78	. . x
	call 07068h		;71b6	cd 68 70	. h p
	ld hl,00000h		;71b9	21 00 00	! . .
	ld (l7fd2h),hl		;71bc	22 d2 7f	" . .
	ld (l7fd9h),hl		;71bf	22 d9 7f	" . .
	ld (l7fe4h),hl		;71c2	22 e4 7f	" . .
	ld (l7fe2h),hl		;71c5	22 e2 7f	" . .
	ld (l7fe0h),hl		;71c8	22 e0 7f	" . .
	ld (l7fd7h),hl		;71cb	22 d7 7f	" . .
	ld (l7fdeh),hl		;71ce	22 de 7f	" . .
	ld (l7fd5h),hl		;71d1	22 d5 7f	" . .
	ld hl,00780h		;71d4	21 80 07	! . .
	ld (l7fdbh),hl		;71d7	22 db 7f	" . .
	ld a,000h		;71da	3e 00		> .
	ld (l7fd1h),a		;71dc	32 d1 7f	2 . .
	ld (l7fd4h),a		;71df	32 d4 7f	2 . .
	ld (l7fddh),a		;71e2	32 dd 7f	2 . .
	ld (l7fe6h),a		;71e5	32 e6 7f	2 . .
	ld a,023h		;71e8	3e 23		> #
	out (001h),a		;71ea	d3 01		. .
	ret			;71ec	c9		.
	xor a			;71ed	af		.
	ld (l8032h),a		;71ee	32 32 80	2 2 .
	inc a			;71f1	3c		<
	ld (l8033h),a		;71f2	32 33 80	2 3 .
	ld (l8034h),a		;71f5	32 34 80	2 4 .
	call sub_74cbh		;71f8	cd cb 74	. . t
	jp c,l720bh		;71fb	da 0b 72	. . r
	ld hl,02020h		;71fe	21 20 20	!    
	jr nz,l7223h		;7201	20 20		   
	jr nz,l7225h		;7203	20 20		   
	jr nz,l7227h		;7205	20 20		   
	jr nz,l7229h		;7207	20 20		   
	jr nz,l722bh		;7209	20 20		   
l720bh:
	jr nz,l722dh		;720b	20 20		   
	jr nz,l722fh		;720d	20 20		   
	jr nz,l7231h		;720f	20 20		   
	jr nz,l7233h		;7211	20 20		   
	jr nz,l7235h		;7213	20 20		   
	jr nz,l7237h		;7215	20 20		   
	jr nz,l7239h		;7217	20 20		   
	jr nz,l723bh		;7219	20 20		   
	jr nz,l723dh		;721b	20 20		   
	jr nz,l723fh		;721d	20 20		   
	jr nz,l7241h		;721f	20 20		   
	jr nz,l7243h		;7221	20 20		   
l7223h:
	jr nz,l7245h		;7223	20 20		   
l7225h:
	jr nz,l7247h		;7225	20 20		   
l7227h:
	jr nz,l7249h		;7227	20 20		   
l7229h:
	jr nz,l724bh		;7229	20 20		   
l722bh:
	jr nz,l724dh		;722b	20 20		   
l722dh:
	jr nz,l724fh		;722d	20 20		   
l722fh:
	jr nz,l7251h		;722f	20 20		   
l7231h:
	jr nz,l7253h		;7231	20 20		   
l7233h:
	jr nz,l7255h		;7233	20 20		   
l7235h:
	jr nz,l7257h		;7235	20 20		   
l7237h:
	jr nz,l7259h		;7237	20 20		   
l7239h:
	jr nz,l725bh		;7239	20 20		   
l723bh:
	jr nz,l725dh		;723b	20 20		   
l723dh:
	jr nz,l725fh		;723d	20 20		   
l723fh:
	jr nz,l7261h		;723f	20 20		   
l7241h:
	jr nz,l7263h		;7241	20 20		   
l7243h:
	jr nz,l7265h		;7243	20 20		   
l7245h:
	jr nz,l7267h		;7245	20 20		   
l7247h:
	jr nz,l7269h		;7247	20 20		   
l7249h:
	jr nz,l726bh		;7249	20 20		   
l724bh:
	jr nz,l726dh		;724b	20 20		   
l724dh:
	jr nz,l726fh		;724d	20 20		   
l724fh:
	jr nz,l7271h		;724f	20 20		   
l7251h:
	jr nz,l7273h		;7251	20 20		   
l7253h:
	jr nz,l7275h		;7253	20 20		   
l7255h:
	jr nz,l7277h		;7255	20 20		   
l7257h:
	jr nz,l7279h		;7257	20 20		   
l7259h:
	jr nz,l727bh		;7259	20 20		   
l725bh:
	jr nz,l727dh		;725b	20 20		   
l725dh:
	jr nz,l727fh		;725d	20 20		   
l725fh:
	jr nz,l7281h		;725f	20 20		   
l7261h:
	jr nz,l7283h		;7261	20 20		   
l7263h:
	jr nz,l7285h		;7263	20 20		   
l7265h:
	jr nz,l7287h		;7265	20 20		   
l7267h:
	jr nz,l7289h		;7267	20 20		   
l7269h:
	jr nz,l728bh		;7269	20 20		   
l726bh:
	jr nz,l728dh		;726b	20 20		   
l726dh:
	jr nz,l728fh		;726d	20 20		   
l726fh:
	jr nz,l7291h		;726f	20 20		   
l7271h:
	jr nz,l7293h		;7271	20 20		   
l7273h:
	jr nz,l7295h		;7273	20 20		   
l7275h:
	jr nz,l7297h		;7275	20 20		   
l7277h:
	jr nz,l7299h		;7277	20 20		   
l7279h:
	jr nz,l729bh		;7279	20 20		   
l727bh:
	jr nz,l729dh		;727b	20 20		   
l727dh:
	jr nz,l729fh		;727d	20 20		   
l727fh:
	jr nz,l72a1h		;727f	20 20		   
l7281h:
	jr nz,l72a3h		;7281	20 20		   
l7283h:
	jr nz,l72a5h		;7283	20 20		   
l7285h:
	jr nz,l72a7h		;7285	20 20		   
l7287h:
	jr nz,l72a9h		;7287	20 20		   
l7289h:
	jr nz,l72abh		;7289	20 20		   
l728bh:
	jr nz,l72adh		;728b	20 20		   
l728dh:
	jr nz,l72afh		;728d	20 20		   
l728fh:
	jr nz,l72b1h		;728f	20 20		   
l7291h:
	jr nz,l72b3h		;7291	20 20		   
l7293h:
	jr nz,l72b5h		;7293	20 20		   
l7295h:
	jr nz,l72b7h		;7295	20 20		   
l7297h:
	jr nz,l72b9h		;7297	20 20		   
l7299h:
	jr nz,l72bbh		;7299	20 20		   
l729bh:
	jr nz,l72bdh		;729b	20 20		   
l729dh:
	jr nz,l72bfh		;729d	20 20		   
l729fh:
	jr nz,l72c1h		;729f	20 20		   
l72a1h:
	jr nz,l72c3h		;72a1	20 20		   
l72a3h:
	jr nz,l72c5h		;72a3	20 20		   
l72a5h:
	jr nz,l72c7h		;72a5	20 20		   
l72a7h:
	jr nz,l72c9h		;72a7	20 20		   
l72a9h:
	jr nz,l72cbh		;72a9	20 20		   
l72abh:
	jr nz,l72cdh		;72ab	20 20		   
l72adh:
	jr nz,l72cfh		;72ad	20 20		   
l72afh:
	jr nz,l72d1h		;72af	20 20		   
l72b1h:
	jr nz,l72d3h		;72b1	20 20		   
l72b3h:
	jr nz,l72d5h		;72b3	20 20		   
l72b5h:
	jr nz,l72d7h		;72b5	20 20		   
l72b7h:
	jr nz,l72d9h		;72b7	20 20		   
l72b9h:
	jr nz,l72dbh		;72b9	20 20		   
l72bbh:
	jr nz,l72ddh		;72bb	20 20		   
l72bdh:
	jr nz,l72dfh		;72bd	20 20		   
l72bfh:
	jr nz,l72e1h		;72bf	20 20		   
l72c1h:
	jr nz,l72e3h		;72c1	20 20		   
l72c3h:
	jr nz,l72e5h		;72c3	20 20		   
l72c5h:
	jr nz,l72e7h		;72c5	20 20		   
l72c7h:
	jr nz,l72e9h		;72c7	20 20		   
l72c9h:
	jr nz,l72ebh		;72c9	20 20		   
l72cbh:
	jr nz,l72edh		;72cb	20 20		   
l72cdh:
	jr nz,l72efh		;72cd	20 20		   
l72cfh:
	jr nz,l72f1h		;72cf	20 20		   
l72d1h:
	jr nz,l72f3h		;72d1	20 20		   
l72d3h:
	jr nz,l72f5h		;72d3	20 20		   
l72d5h:
	jr nz,l72f7h		;72d5	20 20		   
l72d7h:
	jr nz,l72f9h		;72d7	20 20		   
l72d9h:
	jr nz,l72fbh		;72d9	20 20		   
l72dbh:
	jr nz,l72fdh		;72db	20 20		   
l72ddh:
	jr nz,l72ffh		;72dd	20 20		   
l72dfh:
	jr nz,l7301h		;72df	20 20		   
l72e1h:
	jr nz,l7303h		;72e1	20 20		   
l72e3h:
	jr nz,l7305h		;72e3	20 20		   
l72e5h:
	jr nz,l7307h		;72e5	20 20		   
l72e7h:
	jr nz,l7309h		;72e7	20 20		   
l72e9h:
	jr nz,l730bh		;72e9	20 20		   
l72ebh:
	jr nz,l730dh		;72eb	20 20		   
l72edh:
	jr nz,l730fh		;72ed	20 20		   
l72efh:
	jr nz,l7311h		;72ef	20 20		   
l72f1h:
	jr nz,l7313h		;72f1	20 20		   
l72f3h:
	jr nz,l7315h		;72f3	20 20		   
l72f5h:
	jr nz,l7317h		;72f5	20 20		   
l72f7h:
	jr nz,l7319h		;72f7	20 20		   
l72f9h:
	jr nz,l731bh		;72f9	20 20		   
l72fbh:
	jr nz,l731dh		;72fb	20 20		   
l72fdh:
	jr nz,l731fh		;72fd	20 20		   
l72ffh:
	jr nz,l7321h		;72ff	20 20		   
l7301h:
	jr nz,l7323h		;7301	20 20		   
l7303h:
	jr nz,l7325h		;7303	20 20		   
l7305h:
	jr nz,l7327h		;7305	20 20		   
l7307h:
	jr nz,l7329h		;7307	20 20		   
l7309h:
	jr nz,l732bh		;7309	20 20		   
l730bh:
	jr nz,l732dh		;730b	20 20		   
l730dh:
	jr nz,l732fh		;730d	20 20		   
l730fh:
	jr nz,l7331h		;730f	20 20		   
l7311h:
	jr nz,l7333h		;7311	20 20		   
l7313h:
	jr nz,l7335h		;7313	20 20		   
l7315h:
	jr nz,l7337h		;7315	20 20		   
l7317h:
	jr nz,l7339h		;7317	20 20		   
l7319h:
	jr nz,l733bh		;7319	20 20		   
l731bh:
	jr nz,l733dh		;731b	20 20		   
l731dh:
	jr nz,l733fh		;731d	20 20		   
l731fh:
	jr nz,l7341h		;731f	20 20		   
l7321h:
	jr nz,l7343h		;7321	20 20		   
l7323h:
	jr nz,l7345h		;7323	20 20		   
l7325h:
	jr nz,l7347h		;7325	20 20		   
l7327h:
	jr nz,l7349h		;7327	20 20		   
l7329h:
	jr nz,l734bh		;7329	20 20		   
l732bh:
	jr nz,l734dh		;732b	20 20		   
l732dh:
	jr nz,l734fh		;732d	20 20		   
l732fh:
	jr nz,l7351h		;732f	20 20		   
l7331h:
	jr nz,l7353h		;7331	20 20		   
l7333h:
	jr nz,l7355h		;7333	20 20		   
l7335h:
	jr nz,l7357h		;7335	20 20		   
l7337h:
	jr nz,l7359h		;7337	20 20		   
l7339h:
	jr nz,l735bh		;7339	20 20		   
l733bh:
	jr nz,l735dh		;733b	20 20		   
l733dh:
	jr nz,l735fh		;733d	20 20		   
l733fh:
	jr nz,l7361h		;733f	20 20		   
l7341h:
	jr nz,l7363h		;7341	20 20		   
l7343h:
	jr nz,l7365h		;7343	20 20		   
l7345h:
	jr nz,l7367h		;7345	20 20		   
l7347h:
	jr nz,l7369h		;7347	20 20		   
l7349h:
	jr nz,l736bh		;7349	20 20		   
l734bh:
	jr nz,l736dh		;734b	20 20		   
l734dh:
	jr nz,l736fh		;734d	20 20		   
l734fh:
	jr nz,l7371h		;734f	20 20		   
l7351h:
	jr nz,l7373h		;7351	20 20		   
l7353h:
	jr nz,l7375h		;7353	20 20		   
l7355h:
	jr nz,l7377h		;7355	20 20		   
l7357h:
	jr nz,l7379h		;7357	20 20		   
l7359h:
	jr nz,l737bh		;7359	20 20		   
l735bh:
	jr nz,l737dh		;735b	20 20		   
l735dh:
	jr nz,l737fh		;735d	20 20		   
l735fh:
	jr nz,l7381h		;735f	20 20		   
l7361h:
	jr nz,l7383h		;7361	20 20		   
l7363h:
	jr nz,l7385h		;7363	20 20		   
l7365h:
	jr nz,l7387h		;7365	20 20		   
l7367h:
	jr nz,l7389h		;7367	20 20		   
l7369h:
	jr nz,l738bh		;7369	20 20		   
l736bh:
	jr nz,l738dh		;736b	20 20		   
l736dh:
	jr nz,l738fh		;736d	20 20		   
l736fh:
	jr nz,l7391h		;736f	20 20		   
l7371h:
	jr nz,l7393h		;7371	20 20		   
l7373h:
	jr nz,l7395h		;7373	20 20		   
l7375h:
	jr nz,l7397h		;7375	20 20		   
l7377h:
	jr nz,l7399h		;7377	20 20		   
l7379h:
	jr nz,l739bh		;7379	20 20		   
l737bh:
	jr nz,l739dh		;737b	20 20		   
l737dh:
	jr nz,l739fh		;737d	20 20		   
l737fh:
	jr nz,l73a1h		;737f	20 20		   
l7381h:
	jr nz,l73a3h		;7381	20 20		   
l7383h:
	jr nz,l73a5h		;7383	20 20		   
l7385h:
	jr nz,l73a7h		;7385	20 20		   
l7387h:
	jr nz,l73a9h		;7387	20 20		   
l7389h:
	jr nz,l73abh		;7389	20 20		   
l738bh:
	jr nz,l73adh		;738b	20 20		   
l738dh:
	jr nz,l73afh		;738d	20 20		   
l738fh:
	jr nz,l73b1h		;738f	20 20		   
l7391h:
	jr nz,l73b3h		;7391	20 20		   
l7393h:
	jr nz,l73b5h		;7393	20 20		   
l7395h:
	jr nz,l73b7h		;7395	20 20		   
l7397h:
	jr nz,l73b9h		;7397	20 20		   
l7399h:
	jr nz,l73bbh		;7399	20 20		   
l739bh:
	jr nz,l73bdh		;739b	20 20		   
l739dh:
	jr nz,l73bfh		;739d	20 20		   
l739fh:
	jr nz,l73c1h		;739f	20 20		   
l73a1h:
	jr nz,l73c3h		;73a1	20 20		   
l73a3h:
	jr nz,l73c5h		;73a3	20 20		   
l73a5h:
	jr nz,l73c7h		;73a5	20 20		   
l73a7h:
	jr nz,l73c9h		;73a7	20 20		   
l73a9h:
	jr nz,l73cbh		;73a9	20 20		   
l73abh:
	jr nz,l73cdh		;73ab	20 20		   
l73adh:
	jr nz,l73cfh		;73ad	20 20		   
l73afh:
	jr nz,l73d1h		;73af	20 20		   
l73b1h:
	jr nz,l73d3h		;73b1	20 20		   
l73b3h:
	jr nz,l73d5h		;73b3	20 20		   
l73b5h:
	jr nz,l73d7h		;73b5	20 20		   
l73b7h:
	jr nz,l73d9h		;73b7	20 20		   
l73b9h:
	jr nz,l73dbh		;73b9	20 20		   
l73bbh:
	jr nz,l73ddh		;73bb	20 20		   
l73bdh:
	jr nz,l73dfh		;73bd	20 20		   
l73bfh:
	jr nz,l73e1h		;73bf	20 20		   
l73c1h:
	jr nz,l73e3h		;73c1	20 20		   
l73c3h:
	jr nz,l73e5h		;73c3	20 20		   
l73c5h:
	jr nz,l73e7h		;73c5	20 20		   
l73c7h:
	jr nz,l73e9h		;73c7	20 20		   
l73c9h:
	jr nz,l73ebh		;73c9	20 20		   
l73cbh:
	jr nz,l73edh		;73cb	20 20		   
l73cdh:
	jr nz,l73efh		;73cd	20 20		   
l73cfh:
	jr nz,l73f1h		;73cf	20 20		   
l73d1h:
	jr nz,l73f3h		;73d1	20 20		   
l73d3h:
	jr nz,l73f5h		;73d3	20 20		   
l73d5h:
	jr nz,l73f7h		;73d5	20 20		   
l73d7h:
	jr nz,l73f9h		;73d7	20 20		   
l73d9h:
	jr nz,l73fbh		;73d9	20 20		   
l73dbh:
	jr nz,l73fdh		;73db	20 20		   
l73ddh:
	jr nz,l73ffh		;73dd	20 20		   
l73dfh:
	jr nz,l7401h		;73df	20 20		   
l73e1h:
	jr nz,l7403h		;73e1	20 20		   
l73e3h:
	jr nz,l7405h		;73e3	20 20		   
l73e5h:
	jr nz,l7407h		;73e5	20 20		   
l73e7h:
	jr nz,l7409h		;73e7	20 20		   
l73e9h:
	jr nz,l740bh		;73e9	20 20		   
l73ebh:
	jr nz,l740dh		;73eb	20 20		   
l73edh:
	jr nz,l740fh		;73ed	20 20		   
l73efh:
	jr nz,l7411h		;73ef	20 20		   
l73f1h:
	jr nz,l7413h		;73f1	20 20		   
l73f3h:
	jr nz,l7415h		;73f3	20 20		   
l73f5h:
	jr nz,l7417h		;73f5	20 20		   
l73f7h:
	jr nz,l7419h		;73f7	20 20		   
l73f9h:
	jr nz,l741bh		;73f9	20 20		   
l73fbh:
	jr nz,l741dh		;73fb	20 20		   
l73fdh:
	jr nz,l741fh		;73fd	20 20		   
l73ffh:
	jr nz,$+1		;73ff	20 ff		  .
l7401h:
	rst 38h			;7401	ff		.
	rst 38h			;7402	ff		.
l7403h:
	rst 38h			;7403	ff		.
	rst 38h			;7404	ff		.
l7405h:
	rst 38h			;7405	ff		.
	rst 38h			;7406	ff		.
l7407h:
	rst 38h			;7407	ff		.
	rst 38h			;7408	ff		.
l7409h:
	rst 38h			;7409	ff		.
	rst 38h			;740a	ff		.
l740bh:
	rst 38h			;740b	ff		.
	rst 38h			;740c	ff		.
l740dh:
	rst 38h			;740d	ff		.
	rst 38h			;740e	ff		.
l740fh:
	rst 38h			;740f	ff		.
	rst 38h			;7410	ff		.
l7411h:
	rst 38h			;7411	ff		.
	rst 38h			;7412	ff		.
l7413h:
	rst 38h			;7413	ff		.
	rst 38h			;7414	ff		.
l7415h:
	rst 38h			;7415	ff		.
	rst 38h			;7416	ff		.
l7417h:
	rst 38h			;7417	ff		.
	rst 38h			;7418	ff		.
l7419h:
	rst 38h			;7419	ff		.
	nop			;741a	00		.
l741bh:
	nop			;741b	00		.
	nop			;741c	00		.
l741dh:
	nop			;741d	00		.
	nop			;741e	00		.
l741fh:
	nop			;741f	00		.
	nop			;7420	00		.
	nop			;7421	00		.
	nop			;7422	00		.
	nop			;7423	00		.
	nop			;7424	00		.
sub_7425h:
	nop			;7425	00		.
	nop			;7426	00		.
	nop			;7427	00		.
	nop			;7428	00		.
	nop			;7429	00		.
l742ah:
	nop			;742a	00		.
	nop			;742b	00		.
	nop			;742c	00		.
	nop			;742d	00		.
	nop			;742e	00		.
	nop			;742f	00		.
	nop			;7430	00		.
	nop			;7431	00		.
	nop			;7432	00		.
	nop			;7433	00		.
	nop			;7434	00		.
	nop			;7435	00		.
	nop			;7436	00		.
	nop			;7437	00		.
l7438h:
	nop			;7438	00		.
	nop			;7439	00		.
	rst 38h			;743a	ff		.
	cp 0ffh			;743b	fe ff		. .
	rst 38h			;743d	ff		.
	rst 38h			;743e	ff		.
	rst 38h			;743f	ff		.
	cp 0ffh			;7440	fe ff		. .
	rst 38h			;7442	ff		.
	rst 38h			;7443	ff		.
	rst 38h			;7444	ff		.
	rst 38h			;7445	ff		.
	rst 38h			;7446	ff		.
	rst 38h			;7447	ff		.
	rst 38h			;7448	ff		.
	rst 38h			;7449	ff		.
l744ah:
	rst 38h			;744a	ff		.
	rst 38h			;744b	ff		.
	rst 38h			;744c	ff		.
	rst 38h			;744d	ff		.
	rst 38h			;744e	ff		.
	rst 38h			;744f	ff		.
	rst 38h			;7450	ff		.
	rst 38h			;7451	ff		.
	rst 38h			;7452	ff		.
	rst 38h			;7453	ff		.
	rst 38h			;7454	ff		.
	rst 38h			;7455	ff		.
	rst 38h			;7456	ff		.
	rst 38h			;7457	ff		.
	rst 38h			;7458	ff		.
	rst 38h			;7459	ff		.
	nop			;745a	00		.
	nop			;745b	00		.
	nop			;745c	00		.
	nop			;745d	00		.
	nop			;745e	00		.
	nop			;745f	00		.
	nop			;7460	00		.
	nop			;7461	00		.
	nop			;7462	00		.
	nop			;7463	00		.
	nop			;7464	00		.
	nop			;7465	00		.
sub_7466h:
	nop			;7466	00		.
	nop			;7467	00		.
	nop			;7468	00		.
	nop			;7469	00		.
	nop			;746a	00		.
	nop			;746b	00		.
	nop			;746c	00		.
	nop			;746d	00		.
	nop			;746e	00		.
	nop			;746f	00		.
	nop			;7470	00		.
	nop			;7471	00		.
	nop			;7472	00		.
l7473h:
	nop			;7473	00		.
	nop			;7474	00		.
	nop			;7475	00		.
	nop			;7476	00		.
	nop			;7477	00		.
	nop			;7478	00		.
	nop			;7479	00		.
l747ah:
	rst 38h			;747a	ff		.
	rst 38h			;747b	ff		.
	rst 38h			;747c	ff		.
	rst 38h			;747d	ff		.
	rst 38h			;747e	ff		.
	rst 38h			;747f	ff		.
	rst 38h			;7480	ff		.
sub_7481h:
	rst 38h			;7481	ff		.
	rst 38h			;7482	ff		.
	rst 38h			;7483	ff		.
	rst 38h			;7484	ff		.
	rst 38h			;7485	ff		.
	rst 38h			;7486	ff		.
	rst 38h			;7487	ff		.
	rst 38h			;7488	ff		.
	rst 38h			;7489	ff		.
	rst 38h			;748a	ff		.
	rst 38h			;748b	ff		.
	rst 38h			;748c	ff		.
	rst 38h			;748d	ff		.
	rst 38h			;748e	ff		.
	rst 38h			;748f	ff		.
	rst 38h			;7490	ff		.
	rst 38h			;7491	ff		.
	cp 0ffh			;7492	fe ff		. .
	rst 38h			;7494	ff		.
	rst 38h			;7495	ff		.
	cp 0ffh			;7496	fe ff		. .
	rst 38h			;7498	ff		.
	cp 000h			;7499	fe 00		. .
	nop			;749b	00		.
	nop			;749c	00		.
	nop			;749d	00		.
l749eh:
	nop			;749e	00		.
	nop			;749f	00		.
	nop			;74a0	00		.
	nop			;74a1	00		.
	nop			;74a2	00		.
	nop			;74a3	00		.
	nop			;74a4	00		.
	nop			;74a5	00		.
	nop			;74a6	00		.
	nop			;74a7	00		.
	nop			;74a8	00		.
	nop			;74a9	00		.
	nop			;74aa	00		.
	nop			;74ab	00		.
	nop			;74ac	00		.
	nop			;74ad	00		.
sub_74aeh:
	nop			;74ae	00		.
	ld b,b			;74af	40		@
	nop			;74b0	00		.
	nop			;74b1	00		.
	nop			;74b2	00		.
	nop			;74b3	00		.
	nop			;74b4	00		.
	nop			;74b5	00		.
	nop			;74b6	00		.
	nop			;74b7	00		.
sub_74b8h:
	nop			;74b8	00		.
	nop			;74b9	00		.
	cp 0feh			;74ba	fe fe		. .
	cp 0feh			;74bc	fe fe		. .
	cp 0feh			;74be	fe fe		. .
	cp 0feh			;74c0	fe fe		. .
	cp 0feh			;74c2	fe fe		. .
	rst 38h			;74c4	ff		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;74c5	fd ff ff	. . .
	rst 38h			;74c8	ff		.
	rst 38h			;74c9	ff		.
	rst 38h			;74ca	ff		.
sub_74cbh:
	rst 38h			;74cb	ff		.
	rst 38h			;74cc	ff		.
	rst 38h			;74cd	ff		.
	rst 38h			;74ce	ff		.
	rst 38h			;74cf	ff		.
	rst 38h			;74d0	ff		.
	rst 38h			;74d1	ff		.
	rst 38h			;74d2	ff		.
l74d3h:
	rst 38h			;74d3	ff		.
	rst 38h			;74d4	ff		.
	rst 38h			;74d5	ff		.
	rst 38h			;74d6	ff		.
	rst 38h			;74d7	ff		.
	rst 38h			;74d8	ff		.
	rst 38h			;74d9	ff		.
	nop			;74da	00		.
	nop			;74db	00		.
	nop			;74dc	00		.
	nop			;74dd	00		.
	nop			;74de	00		.
	nop			;74df	00		.
	nop			;74e0	00		.
	nop			;74e1	00		.
	nop			;74e2	00		.
	nop			;74e3	00		.
	nop			;74e4	00		.
	nop			;74e5	00		.
	nop			;74e6	00		.
	nop			;74e7	00		.
	nop			;74e8	00		.
	nop			;74e9	00		.
	nop			;74ea	00		.
	nop			;74eb	00		.
	nop			;74ec	00		.
	nop			;74ed	00		.
	nop			;74ee	00		.
	nop			;74ef	00		.
	nop			;74f0	00		.
	nop			;74f1	00		.
	nop			;74f2	00		.
	nop			;74f3	00		.
	nop			;74f4	00		.
	nop			;74f5	00		.
	nop			;74f6	00		.
l74f7h:
	nop			;74f7	00		.
	nop			;74f8	00		.
	nop			;74f9	00		.
	rst 38h			;74fa	ff		.
	rst 38h			;74fb	ff		.
	rst 38h			;74fc	ff		.
	rst 38h			;74fd	ff		.
	rst 38h			;74fe	ff		.
	rst 38h			;74ff	ff		.
	rst 38h			;7500	ff		.
	rst 38h			;7501	ff		.
	rst 38h			;7502	ff		.
	rst 38h			;7503	ff		.
	rst 38h			;7504	ff		.
	rst 38h			;7505	ff		.
	rst 38h			;7506	ff		.
	rst 38h			;7507	ff		.
l7508h:
	rst 38h			;7508	ff		.
	rst 38h			;7509	ff		.
sub_750ah:
	rst 38h			;750a	ff		.
	rst 38h			;750b	ff		.
	rst 38h			;750c	ff		.
	rst 38h			;750d	ff		.
	rst 38h			;750e	ff		.
	rst 38h			;750f	ff		.
	rst 38h			;7510	ff		.
	rst 38h			;7511	ff		.
	rst 38h			;7512	ff		.
	rst 38h			;7513	ff		.
	rst 38h			;7514	ff		.
	rst 38h			;7515	ff		.
	rst 38h			;7516	ff		.
	rst 38h			;7517	ff		.
	rst 38h			;7518	ff		.
	rst 38h			;7519	ff		.
	nop			;751a	00		.
	nop			;751b	00		.
	nop			;751c	00		.
	nop			;751d	00		.
	nop			;751e	00		.
	nop			;751f	00		.
	nop			;7520	00		.
	nop			;7521	00		.
	nop			;7522	00		.
	nop			;7523	00		.
l7524h:
	nop			;7524	00		.
	nop			;7525	00		.
	nop			;7526	00		.
	nop			;7527	00		.
	nop			;7528	00		.
	nop			;7529	00		.
	nop			;752a	00		.
	nop			;752b	00		.
	nop			;752c	00		.
	nop			;752d	00		.
	nop			;752e	00		.
	ld b,b			;752f	40		@
	nop			;7530	00		.
	nop			;7531	00		.
	nop			;7532	00		.
	nop			;7533	00		.
	nop			;7534	00		.
l7535h:
	nop			;7535	00		.
	nop			;7536	00		.
	nop			;7537	00		.
	nop			;7538	00		.
	nop			;7539	00		.
	rst 38h			;753a	ff		.
	rst 38h			;753b	ff		.
	rst 38h			;753c	ff		.
	rst 38h			;753d	ff		.
	rst 38h			;753e	ff		.
	rst 38h			;753f	ff		.
	rst 38h			;7540	ff		.
	rst 38h			;7541	ff		.
	rst 38h			;7542	ff		.
	rst 38h			;7543	ff		.
	rst 38h			;7544	ff		.
	rst 38h			;7545	ff		.
	rst 38h			;7546	ff		.
sub_7547h:
	rst 38h			;7547	ff		.
	rst 38h			;7548	ff		.
	rst 38h			;7549	ff		.
	rst 38h			;754a	ff		.
	rst 38h			;754b	ff		.
	rst 38h			;754c	ff		.
	rst 38h			;754d	ff		.
	rst 38h			;754e	ff		.
	rst 38h			;754f	ff		.
	rst 38h			;7550	ff		.
l7551h:
	rst 38h			;7551	ff		.
	rst 38h			;7552	ff		.
	rst 38h			;7553	ff		.
	rst 38h			;7554	ff		.
	rst 38h			;7555	ff		.
l7556h:
	rst 38h			;7556	ff		.
	rst 38h			;7557	ff		.
	rst 38h			;7558	ff		.
	rst 38h			;7559	ff		.
	nop			;755a	00		.
	nop			;755b	00		.
	nop			;755c	00		.
	nop			;755d	00		.
	nop			;755e	00		.
	nop			;755f	00		.
	nop			;7560	00		.
	nop			;7561	00		.
	nop			;7562	00		.
	nop			;7563	00		.
	nop			;7564	00		.
	nop			;7565	00		.
	nop			;7566	00		.
	nop			;7567	00		.
	nop			;7568	00		.
	nop			;7569	00		.
	nop			;756a	00		.
	nop			;756b	00		.
	nop			;756c	00		.
	nop			;756d	00		.
	nop			;756e	00		.
	nop			;756f	00		.
	nop			;7570	00		.
	nop			;7571	00		.
	nop			;7572	00		.
	nop			;7573	00		.
	nop			;7574	00		.
	nop			;7575	00		.
l7576h:
	nop			;7576	00		.
	nop			;7577	00		.
	nop			;7578	00		.
	nop			;7579	00		.
l757ah:
	rst 38h			;757a	ff		.
	rst 38h			;757b	ff		.
	rst 38h			;757c	ff		.
	rst 38h			;757d	ff		.
	rst 38h			;757e	ff		.
	rst 38h			;757f	ff		.
	rst 38h			;7580	ff		.
	rst 38h			;7581	ff		.
	rst 38h			;7582	ff		.
sub_7583h:
	rst 38h			;7583	ff		.
	rst 38h			;7584	ff		.
	rst 38h			;7585	ff		.
	rst 38h			;7586	ff		.
	rst 38h			;7587	ff		.
l7588h:
	rst 38h			;7588	ff		.
	rst 38h			;7589	ff		.
	rst 38h			;758a	ff		.
	rst 38h			;758b	ff		.
	rst 38h			;758c	ff		.
	rst 38h			;758d	ff		.
	rst 38h			;758e	ff		.
	rst 38h			;758f	ff		.
	rst 38h			;7590	ff		.
	rst 38h			;7591	ff		.
	rst 38h			;7592	ff		.
	rst 38h			;7593	ff		.
	rst 38h			;7594	ff		.
	rst 38h			;7595	ff		.
	rst 38h			;7596	ff		.
	rst 38h			;7597	ff		.
	rst 38h			;7598	ff		.
	rst 38h			;7599	ff		.
	nop			;759a	00		.
	nop			;759b	00		.
	nop			;759c	00		.
	nop			;759d	00		.
	nop			;759e	00		.
	nop			;759f	00		.
	nop			;75a0	00		.
	nop			;75a1	00		.
	nop			;75a2	00		.
	nop			;75a3	00		.
	nop			;75a4	00		.
	nop			;75a5	00		.
	nop			;75a6	00		.
	nop			;75a7	00		.
	nop			;75a8	00		.
	nop			;75a9	00		.
	nop			;75aa	00		.
	nop			;75ab	00		.
	nop			;75ac	00		.
	nop			;75ad	00		.
	nop			;75ae	00		.
	nop			;75af	00		.
	nop			;75b0	00		.
	nop			;75b1	00		.
	nop			;75b2	00		.
sub_75b3h:
	nop			;75b3	00		.
	nop			;75b4	00		.
	nop			;75b5	00		.
	nop			;75b6	00		.
	nop			;75b7	00		.
	nop			;75b8	00		.
	nop			;75b9	00		.
	rst 38h			;75ba	ff		.
	rst 38h			;75bb	ff		.
	rst 38h			;75bc	ff		.
	rst 38h			;75bd	ff		.
	rst 38h			;75be	ff		.
	rst 38h			;75bf	ff		.
	rst 38h			;75c0	ff		.
	rst 38h			;75c1	ff		.
	cp 0ffh			;75c2	fe ff		. .
	rst 38h			;75c4	ff		.
	rst 38h			;75c5	ff		.
	rst 38h			;75c6	ff		.
	rst 38h			;75c7	ff		.
	rst 38h			;75c8	ff		.
	rst 38h			;75c9	ff		.
	rst 38h			;75ca	ff		.
	rst 38h			;75cb	ff		.
	rst 38h			;75cc	ff		.
	rst 38h			;75cd	ff		.
	rst 38h			;75ce	ff		.
	rst 38h			;75cf	ff		.
	rst 38h			;75d0	ff		.
	rst 38h			;75d1	ff		.
	rst 38h			;75d2	ff		.
	rst 38h			;75d3	ff		.
l75d4h:
	rst 38h			;75d4	ff		.
	rst 38h			;75d5	ff		.
	rst 38h			;75d6	ff		.
	rst 38h			;75d7	ff		.
	rst 38h			;75d8	ff		.
	ei			;75d9	fb		.
	nop			;75da	00		.
	nop			;75db	00		.
	nop			;75dc	00		.
sub_75ddh:
	nop			;75dd	00		.
	nop			;75de	00		.
	nop			;75df	00		.
	nop			;75e0	00		.
	nop			;75e1	00		.
	nop			;75e2	00		.
	nop			;75e3	00		.
	nop			;75e4	00		.
	nop			;75e5	00		.
	nop			;75e6	00		.
	nop			;75e7	00		.
	nop			;75e8	00		.
	nop			;75e9	00		.
	nop			;75ea	00		.
	nop			;75eb	00		.
	nop			;75ec	00		.
	nop			;75ed	00		.
	nop			;75ee	00		.
	nop			;75ef	00		.
	nop			;75f0	00		.
	nop			;75f1	00		.
l75f2h:
	nop			;75f2	00		.
	nop			;75f3	00		.
	nop			;75f4	00		.
	nop			;75f5	00		.
	nop			;75f6	00		.
	nop			;75f7	00		.
	nop			;75f8	00		.
	nop			;75f9	00		.
	rst 38h			;75fa	ff		.
	rst 38h			;75fb	ff		.
	rst 38h			;75fc	ff		.
	rst 38h			;75fd	ff		.
	rst 38h			;75fe	ff		.
	rst 38h			;75ff	ff		.
	jr nz,l7622h		;7600	20 20		   
	jr nz,l7624h		;7602	20 20		   
	jr nz,l7626h		;7604	20 20		   
	jr nz,l7628h		;7606	20 20		   
	jr nz,l762ah		;7608	20 20		   
	jr nz,l762ch		;760a	20 20		   
	jr nz,l762eh		;760c	20 20		   
	jr nz,l7630h		;760e	20 20		   
	jr nz,sub_7632h		;7610	20 20		   
	jr nz,l7634h		;7612	20 20		   
	jr nz,l7636h		;7614	20 20		   
	jr nz,l7638h		;7616	20 20		   
	jr nz,l763ah		;7618	20 20		   
	jr nz,sub_763ch		;761a	20 20		   
l761ch:
	jr nz,l763eh		;761c	20 20		   
	jr nz,l7640h		;761e	20 20		   
	jr nz,l7642h		;7620	20 20		   
l7622h:
	jr nz,l7644h		;7622	20 20		   
l7624h:
	jr nz,l7646h		;7624	20 20		   
l7626h:
	jr nz,l7648h		;7626	20 20		   
l7628h:
	jr nz,l764ah		;7628	20 20		   
l762ah:
	jr nz,l764ch		;762a	20 20		   
l762ch:
	jr nz,l764eh		;762c	20 20		   
l762eh:
	jr nz,l7650h		;762e	20 20		   
l7630h:
	jr nz,l7652h		;7630	20 20		   
sub_7632h:
	jr nz,sub_7654h		;7632	20 20		   
l7634h:
	jr nz,l7656h		;7634	20 20		   
l7636h:
	jr nz,l7658h		;7636	20 20		   
l7638h:
	jr nz,l765ah		;7638	20 20		   
l763ah:
	jr nz,l765ch		;763a	20 20		   
sub_763ch:
	jr nz,l765eh		;763c	20 20		   
l763eh:
	jr nz,l7660h		;763e	20 20		   
l7640h:
	jr nz,l7662h		;7640	20 20		   
l7642h:
	jr nz,l7664h		;7642	20 20		   
l7644h:
	jr nz,l7666h		;7644	20 20		   
l7646h:
	jr nz,l7668h		;7646	20 20		   
l7648h:
	jr nz,sub_766ah		;7648	20 20		   
l764ah:
	jr nz,l766ch		;764a	20 20		   
l764ch:
	jr nz,l766eh		;764c	20 20		   
l764eh:
	jr nz,l7670h		;764e	20 20		   
l7650h:
	jr nz,sub_7672h		;7650	20 20		   
l7652h:
	jr nz,l7674h		;7652	20 20		   
sub_7654h:
	jr nz,l7676h		;7654	20 20		   
l7656h:
	jr nz,l7678h		;7656	20 20		   
l7658h:
	jr nz,l767ah		;7658	20 20		   
l765ah:
	jr nz,l767ch		;765a	20 20		   
l765ch:
	jr nz,l767eh		;765c	20 20		   
l765eh:
	jr nz,l7680h		;765e	20 20		   
l7660h:
	jr nz,l7682h		;7660	20 20		   
l7662h:
	jr nz,sub_7684h		;7662	20 20		   
l7664h:
	jr nz,l7686h		;7664	20 20		   
l7666h:
	jr nz,l7688h		;7666	20 20		   
l7668h:
	jr nz,l768ah		;7668	20 20		   
sub_766ah:
	jr nz,l768ch		;766a	20 20		   
l766ch:
	jr nz,l768eh		;766c	20 20		   
l766eh:
	jr nz,l7690h		;766e	20 20		   
l7670h:
	jr nz,l7692h		;7670	20 20		   
sub_7672h:
	jr nz,l7694h		;7672	20 20		   
l7674h:
	jr nz,l7696h		;7674	20 20		   
l7676h:
	jr nz,l7698h		;7676	20 20		   
l7678h:
	jr nz,l769ah		;7678	20 20		   
l767ah:
	jr nz,l769ch		;767a	20 20		   
l767ch:
	jr nz,l769eh		;767c	20 20		   
l767eh:
	jr nz,l76a0h		;767e	20 20		   
l7680h:
	jr nz,l76a2h		;7680	20 20		   
l7682h:
	jr nz,sub_76a4h		;7682	20 20		   
sub_7684h:
	jr nz,l76a6h		;7684	20 20		   
l7686h:
	jr nz,l76a8h		;7686	20 20		   
l7688h:
	jr nz,l76aah		;7688	20 20		   
l768ah:
	jr nz,l76ach		;768a	20 20		   
l768ch:
	jr nz,l76aeh		;768c	20 20		   
l768eh:
	jr nz,l76b0h		;768e	20 20		   
l7690h:
	jr nz,l76b2h		;7690	20 20		   
l7692h:
	jr nz,l76b4h		;7692	20 20		   
l7694h:
	jr nz,l76b6h		;7694	20 20		   
l7696h:
	jr nz,l76b8h		;7696	20 20		   
l7698h:
	jr nz,l76bah		;7698	20 20		   
l769ah:
	jr nz,l76bch		;769a	20 20		   
l769ch:
	jr nz,l76beh		;769c	20 20		   
l769eh:
	jr nz,l76c0h		;769e	20 20		   
l76a0h:
	jr nz,l76c2h		;76a0	20 20		   
l76a2h:
	jr nz,l76c4h		;76a2	20 20		   
sub_76a4h:
	jr nz,l76c6h		;76a4	20 20		   
l76a6h:
	jr nz,l76c8h		;76a6	20 20		   
l76a8h:
	jr nz,l76cah		;76a8	20 20		   
l76aah:
	jr nz,l76cch		;76aa	20 20		   
l76ach:
	jr nz,l76ceh		;76ac	20 20		   
l76aeh:
	jr nz,l76d0h		;76ae	20 20		   
l76b0h:
	jr nz,l76d2h		;76b0	20 20		   
l76b2h:
	jr nz,l76d4h		;76b2	20 20		   
l76b4h:
	jr nz,l76d6h		;76b4	20 20		   
l76b6h:
	jr nz,l76d8h		;76b6	20 20		   
l76b8h:
	jr nz,l76dah		;76b8	20 20		   
l76bah:
	jr nz,l76dch		;76ba	20 20		   
l76bch:
	jr nz,l76deh		;76bc	20 20		   
l76beh:
	jr nz,l76e0h		;76be	20 20		   
l76c0h:
	jr nz,l76e2h		;76c0	20 20		   
l76c2h:
	jr nz,l76e4h		;76c2	20 20		   
l76c4h:
	jr nz,l76e6h		;76c4	20 20		   
l76c6h:
	jr nz,l76e8h		;76c6	20 20		   
l76c8h:
	jr nz,l76eah		;76c8	20 20		   
l76cah:
	jr nz,l76ech		;76ca	20 20		   
l76cch:
	jr nz,l76eeh		;76cc	20 20		   
l76ceh:
	jr nz,l76f0h		;76ce	20 20		   
l76d0h:
	jr nz,l76f2h		;76d0	20 20		   
l76d2h:
	jr nz,l76f4h		;76d2	20 20		   
l76d4h:
	jr nz,l76f6h		;76d4	20 20		   
l76d6h:
	jr nz,l76f8h		;76d6	20 20		   
l76d8h:
	jr nz,l76fah		;76d8	20 20		   
l76dah:
	jr nz,l76fch		;76da	20 20		   
l76dch:
	jr nz,l76feh		;76dc	20 20		   
l76deh:
	jr nz,l7700h		;76de	20 20		   
l76e0h:
	jr nz,l7702h		;76e0	20 20		   
l76e2h:
	jr nz,l7704h		;76e2	20 20		   
l76e4h:
	jr nz,l7706h		;76e4	20 20		   
l76e6h:
	jr nz,l7708h		;76e6	20 20		   
l76e8h:
	jr nz,l770ah		;76e8	20 20		   
l76eah:
	jr nz,l770ch		;76ea	20 20		   
l76ech:
	jr nz,l770eh		;76ec	20 20		   
l76eeh:
	jr nz,l7710h		;76ee	20 20		   
l76f0h:
	jr nz,l7712h		;76f0	20 20		   
l76f2h:
	jr nz,l7714h		;76f2	20 20		   
l76f4h:
	jr nz,l7716h		;76f4	20 20		   
l76f6h:
	jr nz,l7718h		;76f6	20 20		   
l76f8h:
	jr nz,l771ah		;76f8	20 20		   
l76fah:
	jr nz,l771ch		;76fa	20 20		   
l76fch:
	jr nz,l771eh		;76fc	20 20		   
l76feh:
	jr nz,l7720h		;76fe	20 20		   
l7700h:
	jr nz,l7722h		;7700	20 20		   
l7702h:
	jr nz,l7724h		;7702	20 20		   
l7704h:
	jr nz,l7726h		;7704	20 20		   
l7706h:
	jr nz,l7728h		;7706	20 20		   
l7708h:
	jr nz,l772ah		;7708	20 20		   
l770ah:
	jr nz,l772ch		;770a	20 20		   
l770ch:
	jr nz,l772eh		;770c	20 20		   
l770eh:
	jr nz,l7730h		;770e	20 20		   
l7710h:
	jr nz,l7732h		;7710	20 20		   
l7712h:
	jr nz,l7734h		;7712	20 20		   
l7714h:
	jr nz,l7736h		;7714	20 20		   
l7716h:
	jr nz,l7738h		;7716	20 20		   
l7718h:
	jr nz,l773ah		;7718	20 20		   
l771ah:
	jr nz,l773ch		;771a	20 20		   
l771ch:
	jr nz,l773eh		;771c	20 20		   
l771eh:
	jr nz,sub_7740h		;771e	20 20		   
l7720h:
	jr nz,l7742h		;7720	20 20		   
l7722h:
	jr nz,l7744h		;7722	20 20		   
l7724h:
	jr nz,l7746h		;7724	20 20		   
l7726h:
	jr nz,l7748h		;7726	20 20		   
l7728h:
	jr nz,l774ah		;7728	20 20		   
l772ah:
	jr nz,l774ch		;772a	20 20		   
l772ch:
	jr nz,l774eh		;772c	20 20		   
l772eh:
	jr nz,l7750h		;772e	20 20		   
l7730h:
	jr nz,l7752h		;7730	20 20		   
l7732h:
	jr nz,l7754h		;7732	20 20		   
l7734h:
	jr nz,l7756h		;7734	20 20		   
l7736h:
	jr nz,l7758h		;7736	20 20		   
l7738h:
	jr nz,l775ah		;7738	20 20		   
l773ah:
	jr nz,l775ch		;773a	20 20		   
l773ch:
	jr nz,l775eh		;773c	20 20		   
l773eh:
	jr nz,l7760h		;773e	20 20		   
sub_7740h:
	jr nz,l7762h		;7740	20 20		   
l7742h:
	jr nz,l7764h		;7742	20 20		   
l7744h:
	jr nz,l7766h		;7744	20 20		   
l7746h:
	jr nz,l7768h		;7746	20 20		   
l7748h:
	jr nz,l776ah		;7748	20 20		   
l774ah:
	jr nz,l776ch		;774a	20 20		   
l774ch:
	jr nz,l776eh		;774c	20 20		   
l774eh:
	jr nz,l7770h		;774e	20 20		   
l7750h:
	jr nz,l7772h		;7750	20 20		   
l7752h:
	jr nz,l7774h		;7752	20 20		   
l7754h:
	jr nz,l7776h		;7754	20 20		   
l7756h:
	jr nz,l7778h		;7756	20 20		   
l7758h:
	jr nz,l777ah		;7758	20 20		   
l775ah:
	jr nz,l777ch		;775a	20 20		   
l775ch:
	jr nz,l777eh		;775c	20 20		   
l775eh:
	jr nz,l7780h		;775e	20 20		   
l7760h:
	jr nz,l7782h		;7760	20 20		   
l7762h:
	jr nz,l7784h		;7762	20 20		   
l7764h:
	jr nz,l7786h		;7764	20 20		   
l7766h:
	jr nz,l7788h		;7766	20 20		   
l7768h:
	jr nz,l778ah		;7768	20 20		   
l776ah:
	jr nz,l778ch		;776a	20 20		   
l776ch:
	jr nz,l778eh		;776c	20 20		   
l776eh:
	jr nz,l7790h		;776e	20 20		   
l7770h:
	jr nz,l7792h		;7770	20 20		   
l7772h:
	jr nz,l7794h		;7772	20 20		   
l7774h:
	jr nz,l7796h		;7774	20 20		   
l7776h:
	jr nz,l7798h		;7776	20 20		   
l7778h:
	jr nz,l779ah		;7778	20 20		   
l777ah:
	jr nz,l779ch		;777a	20 20		   
l777ch:
	jr nz,l779eh		;777c	20 20		   
l777eh:
	jr nz,l77a0h		;777e	20 20		   
l7780h:
	jr nz,l77a2h		;7780	20 20		   
l7782h:
	jr nz,l77a4h		;7782	20 20		   
l7784h:
	jr nz,l77a6h		;7784	20 20		   
l7786h:
	jr nz,l77a8h		;7786	20 20		   
l7788h:
	jr nz,l77aah		;7788	20 20		   
l778ah:
	jr nz,l77ach		;778a	20 20		   
l778ch:
	jr nz,l77aeh		;778c	20 20		   
l778eh:
	jr nz,l77b0h		;778e	20 20		   
l7790h:
	jr nz,l77b2h		;7790	20 20		   
l7792h:
	jr nz,l77b4h		;7792	20 20		   
l7794h:
	jr nz,l77b6h		;7794	20 20		   
l7796h:
	jr nz,l77b8h		;7796	20 20		   
l7798h:
	jr nz,l77bah		;7798	20 20		   
l779ah:
	jr nz,l77bch		;779a	20 20		   
l779ch:
	jr nz,l77beh		;779c	20 20		   
l779eh:
	jr nz,l77c0h		;779e	20 20		   
l77a0h:
	jr nz,l77c2h		;77a0	20 20		   
l77a2h:
	jr nz,l77c4h		;77a2	20 20		   
l77a4h:
	jr nz,l77c6h		;77a4	20 20		   
l77a6h:
	jr nz,l77c8h		;77a6	20 20		   
l77a8h:
	jr nz,l77cah		;77a8	20 20		   
l77aah:
	jr nz,l77cch		;77aa	20 20		   
l77ach:
	jr nz,l77ceh		;77ac	20 20		   
l77aeh:
	jr nz,l77d0h		;77ae	20 20		   
l77b0h:
	jr nz,l77d2h		;77b0	20 20		   
l77b2h:
	jr nz,l77d4h		;77b2	20 20		   
l77b4h:
	jr nz,l77d6h		;77b4	20 20		   
l77b6h:
	jr nz,l77d8h		;77b6	20 20		   
l77b8h:
	jr nz,l77dah		;77b8	20 20		   
l77bah:
	jr nz,l77dch		;77ba	20 20		   
l77bch:
	jr nz,l77deh		;77bc	20 20		   
l77beh:
	jr nz,l77e0h		;77be	20 20		   
l77c0h:
	jr nz,l77e2h		;77c0	20 20		   
l77c2h:
	jr nz,l77e4h		;77c2	20 20		   
l77c4h:
	jr nz,l77e6h		;77c4	20 20		   
l77c6h:
	jr nz,l77e8h		;77c6	20 20		   
l77c8h:
	jr nz,l77eah		;77c8	20 20		   
l77cah:
	jr nz,l77ech		;77ca	20 20		   
l77cch:
	jr nz,l77eeh		;77cc	20 20		   
l77ceh:
	jr nz,l77f0h		;77ce	20 20		   
l77d0h:
	jr nz,l77f2h		;77d0	20 20		   
l77d2h:
	jr nz,l77f4h		;77d2	20 20		   
l77d4h:
	jr nz,l77f6h		;77d4	20 20		   
l77d6h:
	jr nz,l77f8h		;77d6	20 20		   
l77d8h:
	jr nz,l77fah		;77d8	20 20		   
l77dah:
	jr nz,l77fch		;77da	20 20		   
l77dch:
	jr nz,l77feh		;77dc	20 20		   
l77deh:
	jr nz,l7800h		;77de	20 20		   
l77e0h:
	jr nz,l7802h		;77e0	20 20		   
l77e2h:
	jr nz,l7804h		;77e2	20 20		   
l77e4h:
	jr nz,l7806h		;77e4	20 20		   
l77e6h:
	jr nz,l7808h		;77e6	20 20		   
l77e8h:
	jr nz,l780ah		;77e8	20 20		   
l77eah:
	jr nz,l780ch		;77ea	20 20		   
l77ech:
	jr nz,l780eh		;77ec	20 20		   
l77eeh:
	jr nz,l7810h		;77ee	20 20		   
l77f0h:
	jr nz,l7812h		;77f0	20 20		   
l77f2h:
	jr nz,l7814h		;77f2	20 20		   
l77f4h:
	jr nz,l7816h		;77f4	20 20		   
l77f6h:
	jr nz,l7818h		;77f6	20 20		   
l77f8h:
	jr nz,l781ah		;77f8	20 20		   
l77fah:
	jr nz,l781ch		;77fa	20 20		   
l77fch:
	jr nz,l781eh		;77fc	20 20		   
l77feh:
	jr nz,l7820h		;77fe	20 20		   
l7800h:
	rst 38h			;7800	ff		.
	rst 38h			;7801	ff		.
l7802h:
	rst 38h			;7802	ff		.
	rst 38h			;7803	ff		.
l7804h:
	rst 38h			;7804	ff		.
	rst 38h			;7805	ff		.
l7806h:
	rst 38h			;7806	ff		.
	rst 38h			;7807	ff		.
l7808h:
	rst 38h			;7808	ff		.
	rst 38h			;7809	ff		.
l780ah:
	rst 38h			;780a	ff		.
	rst 38h			;780b	ff		.
l780ch:
	rst 38h			;780c	ff		.
	rst 38h			;780d	ff		.
l780eh:
	rst 38h			;780e	ff		.
	rst 38h			;780f	ff		.
l7810h:
	rst 38h			;7810	ff		.
	rst 38h			;7811	ff		.
l7812h:
	rst 38h			;7812	ff		.
	rst 38h			;7813	ff		.
l7814h:
	rst 38h			;7814	ff		.
	rst 38h			;7815	ff		.
l7816h:
	rst 38h			;7816	ff		.
	rst 38h			;7817	ff		.
l7818h:
	rst 38h			;7818	ff		.
	rst 38h			;7819	ff		.
l781ah:
	nop			;781a	00		.
	nop			;781b	00		.
l781ch:
	nop			;781c	00		.
	nop			;781d	00		.
l781eh:
	nop			;781e	00		.
	nop			;781f	00		.
l7820h:
	nop			;7820	00		.
	nop			;7821	00		.
	nop			;7822	00		.
	nop			;7823	00		.
	nop			;7824	00		.
	nop			;7825	00		.
	nop			;7826	00		.
	nop			;7827	00		.
	nop			;7828	00		.
	nop			;7829	00		.
	nop			;782a	00		.
	nop			;782b	00		.
	nop			;782c	00		.
	nop			;782d	00		.
	nop			;782e	00		.
	ld b,b			;782f	40		@
	nop			;7830	00		.
	nop			;7831	00		.
	nop			;7832	00		.
	nop			;7833	00		.
	nop			;7834	00		.
	nop			;7835	00		.
	nop			;7836	00		.
	nop			;7837	00		.
	nop			;7838	00		.
	nop			;7839	00		.
	rst 38h			;783a	ff		.
	rst 38h			;783b	ff		.
	rst 38h			;783c	ff		.
	rst 38h			;783d	ff		.
	rst 38h			;783e	ff		.
	rst 38h			;783f	ff		.
	rst 38h			;7840	ff		.
	rst 38h			;7841	ff		.
	rst 38h			;7842	ff		.
	rst 38h			;7843	ff		.
	rst 38h			;7844	ff		.
	rst 38h			;7845	ff		.
	rst 38h			;7846	ff		.
	rst 38h			;7847	ff		.
	rst 38h			;7848	ff		.
	rst 38h			;7849	ff		.
	rst 38h			;784a	ff		.
	rst 38h			;784b	ff		.
	rst 38h			;784c	ff		.
	rst 38h			;784d	ff		.
	rst 38h			;784e	ff		.
	rst 38h			;784f	ff		.
	rst 38h			;7850	ff		.
	rst 38h			;7851	ff		.
	rst 38h			;7852	ff		.
	rst 38h			;7853	ff		.
	rst 38h			;7854	ff		.
	rst 38h			;7855	ff		.
	rst 38h			;7856	ff		.
	rst 38h			;7857	ff		.
	rst 38h			;7858	ff		.
	ei			;7859	fb		.
	nop			;785a	00		.
	nop			;785b	00		.
	nop			;785c	00		.
	nop			;785d	00		.
	nop			;785e	00		.
	nop			;785f	00		.
	nop			;7860	00		.
	nop			;7861	00		.
	nop			;7862	00		.
	nop			;7863	00		.
	nop			;7864	00		.
	nop			;7865	00		.
	nop			;7866	00		.
	nop			;7867	00		.
	nop			;7868	00		.
	nop			;7869	00		.
	nop			;786a	00		.
	nop			;786b	00		.
	nop			;786c	00		.
	nop			;786d	00		.
	nop			;786e	00		.
	nop			;786f	00		.
	nop			;7870	00		.
	nop			;7871	00		.
	nop			;7872	00		.
	nop			;7873	00		.
	nop			;7874	00		.
	nop			;7875	00		.
	nop			;7876	00		.
	nop			;7877	00		.
	nop			;7878	00		.
	nop			;7879	00		.
	rst 38h			;787a	ff		.
	rst 38h			;787b	ff		.
	rst 38h			;787c	ff		.
	rst 38h			;787d	ff		.
	rst 38h			;787e	ff		.
	rst 38h			;787f	ff		.
	rst 38h			;7880	ff		.
	rst 38h			;7881	ff		.
	rst 38h			;7882	ff		.
	rst 38h			;7883	ff		.
	rst 38h			;7884	ff		.
	rst 38h			;7885	ff		.
	rst 38h			;7886	ff		.
	rst 38h			;7887	ff		.
	rst 38h			;7888	ff		.
	rst 38h			;7889	ff		.
	rst 38h			;788a	ff		.
	rst 38h			;788b	ff		.
	rst 38h			;788c	ff		.
	rst 38h			;788d	ff		.
	rst 38h			;788e	ff		.
	rst 38h			;788f	ff		.
	rst 38h			;7890	ff		.
	rst 38h			;7891	ff		.
	rst 38h			;7892	ff		.
	rst 38h			;7893	ff		.
	rst 38h			;7894	ff		.
	rst 38h			;7895	ff		.
	rst 38h			;7896	ff		.
	rst 38h			;7897	ff		.
	rst 38h			;7898	ff		.
	rst 38h			;7899	ff		.
	nop			;789a	00		.
	nop			;789b	00		.
	nop			;789c	00		.
	nop			;789d	00		.
	nop			;789e	00		.
	nop			;789f	00		.
	nop			;78a0	00		.
	nop			;78a1	00		.
	nop			;78a2	00		.
	nop			;78a3	00		.
	nop			;78a4	00		.
	nop			;78a5	00		.
	nop			;78a6	00		.
	nop			;78a7	00		.
	nop			;78a8	00		.
	nop			;78a9	00		.
	nop			;78aa	00		.
	nop			;78ab	00		.
	nop			;78ac	00		.
	nop			;78ad	00		.
	nop			;78ae	00		.
	nop			;78af	00		.
	nop			;78b0	00		.
	nop			;78b1	00		.
	nop			;78b2	00		.
	nop			;78b3	00		.
	nop			;78b4	00		.
	nop			;78b5	00		.
	nop			;78b6	00		.
	nop			;78b7	00		.
	nop			;78b8	00		.
	nop			;78b9	00		.
	cp 0ffh			;78ba	fe ff		. .
	rst 38h			;78bc	ff		.
	rst 38h			;78bd	ff		.
	cp 0ffh			;78be	fe ff		. .
	rst 38h			;78c0	ff		.
	rst 38h			;78c1	ff		.
	cp 0ffh			;78c2	fe ff		. .
	rst 38h			;78c4	ff		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;78c5	fd ff ff	. . .
	rst 38h			;78c8	ff		.
	rst 38h			;78c9	ff		.
	rst 38h			;78ca	ff		.
	rst 38h			;78cb	ff		.
	rst 38h			;78cc	ff		.
	rst 38h			;78cd	ff		.
	rst 38h			;78ce	ff		.
	rst 38h			;78cf	ff		.
	rst 38h			;78d0	ff		.
	rst 38h			;78d1	ff		.
	rst 38h			;78d2	ff		.
	rst 38h			;78d3	ff		.
	rst 38h			;78d4	ff		.
	rst 38h			;78d5	ff		.
	rst 38h			;78d6	ff		.
	rst 38h			;78d7	ff		.
	rst 38h			;78d8	ff		.
	rst 38h			;78d9	ff		.
	nop			;78da	00		.
	nop			;78db	00		.
	nop			;78dc	00		.
	nop			;78dd	00		.
	nop			;78de	00		.
	nop			;78df	00		.
	nop			;78e0	00		.
	nop			;78e1	00		.
	nop			;78e2	00		.
	nop			;78e3	00		.
	nop			;78e4	00		.
	nop			;78e5	00		.
	nop			;78e6	00		.
	nop			;78e7	00		.
	nop			;78e8	00		.
	nop			;78e9	00		.
	nop			;78ea	00		.
	nop			;78eb	00		.
	nop			;78ec	00		.
	nop			;78ed	00		.
	nop			;78ee	00		.
	nop			;78ef	00		.
	nop			;78f0	00		.
	nop			;78f1	00		.
	nop			;78f2	00		.
	nop			;78f3	00		.
	nop			;78f4	00		.
	nop			;78f5	00		.
	nop			;78f6	00		.
	nop			;78f7	00		.
	nop			;78f8	00		.
	nop			;78f9	00		.
	rst 38h			;78fa	ff		.
	rst 38h			;78fb	ff		.
	rst 38h			;78fc	ff		.
	rst 38h			;78fd	ff		.
	rst 38h			;78fe	ff		.
	rst 38h			;78ff	ff		.
	rst 38h			;7900	ff		.
	rst 38h			;7901	ff		.
	rst 38h			;7902	ff		.
	rst 38h			;7903	ff		.
	rst 38h			;7904	ff		.
	rst 38h			;7905	ff		.
	rst 38h			;7906	ff		.
	rst 38h			;7907	ff		.
	rst 38h			;7908	ff		.
	rst 38h			;7909	ff		.
	rst 38h			;790a	ff		.
	rst 38h			;790b	ff		.
	rst 38h			;790c	ff		.
	rst 38h			;790d	ff		.
	rst 38h			;790e	ff		.
	rst 38h			;790f	ff		.
	rst 38h			;7910	ff		.
	rst 38h			;7911	ff		.
	rst 38h			;7912	ff		.
	rst 38h			;7913	ff		.
	rst 38h			;7914	ff		.
	rst 38h			;7915	ff		.
	rst 38h			;7916	ff		.
	rst 38h			;7917	ff		.
	rst 38h			;7918	ff		.
	rst 38h			;7919	ff		.
	nop			;791a	00		.
	nop			;791b	00		.
	nop			;791c	00		.
	nop			;791d	00		.
	nop			;791e	00		.
	nop			;791f	00		.
	nop			;7920	00		.
	nop			;7921	00		.
	nop			;7922	00		.
	nop			;7923	00		.
	nop			;7924	00		.
	nop			;7925	00		.
	nop			;7926	00		.
	nop			;7927	00		.
	nop			;7928	00		.
	nop			;7929	00		.
	nop			;792a	00		.
	nop			;792b	00		.
	nop			;792c	00		.
	nop			;792d	00		.
	nop			;792e	00		.
	ld b,b			;792f	40		@
	nop			;7930	00		.
	nop			;7931	00		.
	nop			;7932	00		.
	nop			;7933	00		.
	nop			;7934	00		.
	nop			;7935	00		.
	nop			;7936	00		.
	nop			;7937	00		.
	nop			;7938	00		.
	nop			;7939	00		.
	rst 38h			;793a	ff		.
	rst 38h			;793b	ff		.
	rst 38h			;793c	ff		.
	rst 38h			;793d	ff		.
	rst 38h			;793e	ff		.
	rst 38h			;793f	ff		.
	rst 38h			;7940	ff		.
	rst 38h			;7941	ff		.
	rst 38h			;7942	ff		.
	rst 38h			;7943	ff		.
	rst 38h			;7944	ff		.
	rst 38h			;7945	ff		.
	rst 38h			;7946	ff		.
	rst 38h			;7947	ff		.
	rst 38h			;7948	ff		.
	rst 38h			;7949	ff		.
	rst 38h			;794a	ff		.
	rst 38h			;794b	ff		.
	rst 38h			;794c	ff		.
	rst 38h			;794d	ff		.
	rst 38h			;794e	ff		.
	rst 38h			;794f	ff		.
	rst 38h			;7950	ff		.
	rst 38h			;7951	ff		.
	rst 38h			;7952	ff		.
	rst 38h			;7953	ff		.
	rst 38h			;7954	ff		.
	rst 38h			;7955	ff		.
	rst 38h			;7956	ff		.
	rst 38h			;7957	ff		.
	rst 38h			;7958	ff		.
	rst 38h			;7959	ff		.
	nop			;795a	00		.
	nop			;795b	00		.
	nop			;795c	00		.
	nop			;795d	00		.
	nop			;795e	00		.
	nop			;795f	00		.
	nop			;7960	00		.
	nop			;7961	00		.
	nop			;7962	00		.
	nop			;7963	00		.
	nop			;7964	00		.
	nop			;7965	00		.
	nop			;7966	00		.
	nop			;7967	00		.
	nop			;7968	00		.
	nop			;7969	00		.
	nop			;796a	00		.
	nop			;796b	00		.
	nop			;796c	00		.
	nop			;796d	00		.
	nop			;796e	00		.
	nop			;796f	00		.
	nop			;7970	00		.
	nop			;7971	00		.
	nop			;7972	00		.
	nop			;7973	00		.
	nop			;7974	00		.
	nop			;7975	00		.
	nop			;7976	00		.
	nop			;7977	00		.
	nop			;7978	00		.
	nop			;7979	00		.
	rst 38h			;797a	ff		.
	rst 38h			;797b	ff		.
	rst 38h			;797c	ff		.
	rst 38h			;797d	ff		.
	rst 38h			;797e	ff		.
	rst 38h			;797f	ff		.
	rst 38h			;7980	ff		.
	rst 38h			;7981	ff		.
	rst 38h			;7982	ff		.
	rst 38h			;7983	ff		.
	rst 38h			;7984	ff		.
	rst 38h			;7985	ff		.
	rst 38h			;7986	ff		.
	rst 38h			;7987	ff		.
	rst 38h			;7988	ff		.
	rst 38h			;7989	ff		.
	rst 38h			;798a	ff		.
	rst 38h			;798b	ff		.
	rst 38h			;798c	ff		.
	rst 38h			;798d	ff		.
	rst 38h			;798e	ff		.
	rst 38h			;798f	ff		.
	rst 38h			;7990	ff		.
	rst 38h			;7991	ff		.
	rst 38h			;7992	ff		.
	rst 38h			;7993	ff		.
	rst 38h			;7994	ff		.
	rst 38h			;7995	ff		.
	rst 38h			;7996	ff		.
	rst 38h			;7997	ff		.
	rst 38h			;7998	ff		.
	rst 38h			;7999	ff		.
	nop			;799a	00		.
	nop			;799b	00		.
	nop			;799c	00		.
	nop			;799d	00		.
	nop			;799e	00		.
	nop			;799f	00		.
	nop			;79a0	00		.
	nop			;79a1	00		.
	nop			;79a2	00		.
	nop			;79a3	00		.
	nop			;79a4	00		.
	nop			;79a5	00		.
	nop			;79a6	00		.
	nop			;79a7	00		.
	nop			;79a8	00		.
	nop			;79a9	00		.
	nop			;79aa	00		.
	nop			;79ab	00		.
	nop			;79ac	00		.
	nop			;79ad	00		.
	nop			;79ae	00		.
	nop			;79af	00		.
	nop			;79b0	00		.
	nop			;79b1	00		.
	nop			;79b2	00		.
	nop			;79b3	00		.
	nop			;79b4	00		.
	nop			;79b5	00		.
	nop			;79b6	00		.
	nop			;79b7	00		.
	nop			;79b8	00		.
	nop			;79b9	00		.
	cp 0ffh			;79ba	fe ff		. .
	rst 38h			;79bc	ff		.
	rst 38h			;79bd	ff		.
	cp 0ffh			;79be	fe ff		. .
	rst 38h			;79c0	ff		.
	cp 0feh			;79c1	fe fe		. .
	rst 38h			;79c3	ff		.
	rst 38h			;79c4	ff		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;79c5	fd ff ff	. . .
	rst 38h			;79c8	ff		.
	rst 38h			;79c9	ff		.
	rst 38h			;79ca	ff		.
	rst 38h			;79cb	ff		.
	rst 38h			;79cc	ff		.
	rst 38h			;79cd	ff		.
	rst 38h			;79ce	ff		.
	rst 38h			;79cf	ff		.
	rst 38h			;79d0	ff		.
	rst 38h			;79d1	ff		.
	rst 38h			;79d2	ff		.
	rst 38h			;79d3	ff		.
	rst 38h			;79d4	ff		.
	rst 38h			;79d5	ff		.
	rst 38h			;79d6	ff		.
	rst 38h			;79d7	ff		.
	rst 38h			;79d8	ff		.
	ei			;79d9	fb		.
	nop			;79da	00		.
	nop			;79db	00		.
	nop			;79dc	00		.
	nop			;79dd	00		.
	nop			;79de	00		.
	nop			;79df	00		.
	nop			;79e0	00		.
	nop			;79e1	00		.
	nop			;79e2	00		.
	nop			;79e3	00		.
	nop			;79e4	00		.
	nop			;79e5	00		.
	nop			;79e6	00		.
	nop			;79e7	00		.
	nop			;79e8	00		.
	nop			;79e9	00		.
	nop			;79ea	00		.
	nop			;79eb	00		.
	nop			;79ec	00		.
	nop			;79ed	00		.
	nop			;79ee	00		.
	nop			;79ef	00		.
	nop			;79f0	00		.
	nop			;79f1	00		.
	nop			;79f2	00		.
	nop			;79f3	00		.
	nop			;79f4	00		.
	nop			;79f5	00		.
	nop			;79f6	00		.
	nop			;79f7	00		.
	nop			;79f8	00		.
	nop			;79f9	00		.
	rst 38h			;79fa	ff		.
	rst 38h			;79fb	ff		.
	rst 38h			;79fc	ff		.
	rst 38h			;79fd	ff		.
	rst 38h			;79fe	ff		.
	rst 38h			;79ff	ff		.
	jr nz,l7a22h		;7a00	20 20		   
	jr nz,l7a24h		;7a02	20 20		   
	jr nz,l7a26h		;7a04	20 20		   
	jr nz,l7a28h		;7a06	20 20		   
	jr nz,l7a2ah		;7a08	20 20		   
	jr nz,l7a2ch		;7a0a	20 20		   
	jr nz,l7a2eh		;7a0c	20 20		   
	jr nz,l7a30h		;7a0e	20 20		   
	jr nz,l7a32h		;7a10	20 20		   
	jr nz,l7a34h		;7a12	20 20		   
	jr nz,l7a36h		;7a14	20 20		   
	jr nz,l7a38h		;7a16	20 20		   
	jr nz,l7a3ah		;7a18	20 20		   
	jr nz,l7a3ch		;7a1a	20 20		   
	jr nz,l7a3eh		;7a1c	20 20		   
	jr nz,l7a40h		;7a1e	20 20		   
	jr nz,l7a42h		;7a20	20 20		   
l7a22h:
	jr nz,l7a44h		;7a22	20 20		   
l7a24h:
	jr nz,l7a46h		;7a24	20 20		   
l7a26h:
	jr nz,l7a48h		;7a26	20 20		   
l7a28h:
	jr nz,l7a4ah		;7a28	20 20		   
l7a2ah:
	jr nz,l7a4ch		;7a2a	20 20		   
l7a2ch:
	jr nz,l7a4eh		;7a2c	20 20		   
l7a2eh:
	jr nz,l7a50h		;7a2e	20 20		   
l7a30h:
	jr nz,l7a52h		;7a30	20 20		   
l7a32h:
	jr nz,l7a54h		;7a32	20 20		   
l7a34h:
	jr nz,l7a56h		;7a34	20 20		   
l7a36h:
	jr nz,l7a58h		;7a36	20 20		   
l7a38h:
	jr nz,l7a5ah		;7a38	20 20		   
l7a3ah:
	jr nz,l7a5ch		;7a3a	20 20		   
l7a3ch:
	jr nz,l7a5eh		;7a3c	20 20		   
l7a3eh:
	jr nz,l7a60h		;7a3e	20 20		   
l7a40h:
	jr nz,l7a62h		;7a40	20 20		   
l7a42h:
	jr nz,l7a64h		;7a42	20 20		   
l7a44h:
	jr nz,l7a66h		;7a44	20 20		   
l7a46h:
	jr nz,l7a68h		;7a46	20 20		   
l7a48h:
	jr nz,l7a6ah		;7a48	20 20		   
l7a4ah:
	jr nz,l7a6ch		;7a4a	20 20		   
l7a4ch:
	jr nz,l7a6eh		;7a4c	20 20		   
l7a4eh:
	jr nz,l7a70h		;7a4e	20 20		   
l7a50h:
	jr nz,l7a72h		;7a50	20 20		   
l7a52h:
	jr nz,l7a74h		;7a52	20 20		   
l7a54h:
	jr nz,l7a76h		;7a54	20 20		   
l7a56h:
	jr nz,l7a78h		;7a56	20 20		   
l7a58h:
	jr nz,l7a7ah		;7a58	20 20		   
l7a5ah:
	jr nz,l7a7ch		;7a5a	20 20		   
l7a5ch:
	jr nz,l7a7eh		;7a5c	20 20		   
l7a5eh:
	jr nz,l7a80h		;7a5e	20 20		   
l7a60h:
	jr nz,l7a82h		;7a60	20 20		   
l7a62h:
	jr nz,l7a84h		;7a62	20 20		   
l7a64h:
	jr nz,l7a86h		;7a64	20 20		   
l7a66h:
	jr nz,l7a88h		;7a66	20 20		   
l7a68h:
	jr nz,l7a8ah		;7a68	20 20		   
l7a6ah:
	jr nz,l7a8ch		;7a6a	20 20		   
l7a6ch:
	jr nz,l7a8eh		;7a6c	20 20		   
l7a6eh:
	jr nz,l7a90h		;7a6e	20 20		   
l7a70h:
	jr nz,l7a92h		;7a70	20 20		   
l7a72h:
	jr nz,l7a94h		;7a72	20 20		   
l7a74h:
	jr nz,l7a96h		;7a74	20 20		   
l7a76h:
	jr nz,l7a98h		;7a76	20 20		   
l7a78h:
	jr nz,l7a9ah		;7a78	20 20		   
l7a7ah:
	jr nz,l7a9ch		;7a7a	20 20		   
l7a7ch:
	jr nz,l7a9eh		;7a7c	20 20		   
l7a7eh:
	jr nz,l7aa0h		;7a7e	20 20		   
l7a80h:
	jr nz,l7aa2h		;7a80	20 20		   
l7a82h:
	jr nz,l7aa4h		;7a82	20 20		   
l7a84h:
	jr nz,l7aa6h		;7a84	20 20		   
l7a86h:
	jr nz,l7aa8h		;7a86	20 20		   
l7a88h:
	jr nz,l7aaah		;7a88	20 20		   
l7a8ah:
	jr nz,l7aach		;7a8a	20 20		   
l7a8ch:
	jr nz,l7aaeh		;7a8c	20 20		   
l7a8eh:
	jr nz,l7ab0h		;7a8e	20 20		   
l7a90h:
	jr nz,l7ab2h		;7a90	20 20		   
l7a92h:
	jr nz,l7ab4h		;7a92	20 20		   
l7a94h:
	jr nz,l7ab6h		;7a94	20 20		   
l7a96h:
	jr nz,l7ab8h		;7a96	20 20		   
l7a98h:
	jr nz,l7abah		;7a98	20 20		   
l7a9ah:
	jr nz,l7abch		;7a9a	20 20		   
l7a9ch:
	jr nz,l7abeh		;7a9c	20 20		   
l7a9eh:
	jr nz,l7ac0h		;7a9e	20 20		   
l7aa0h:
	jr nz,l7ac2h		;7aa0	20 20		   
l7aa2h:
	jr nz,l7ac4h		;7aa2	20 20		   
l7aa4h:
	jr nz,l7ac6h		;7aa4	20 20		   
l7aa6h:
	jr nz,l7ac8h		;7aa6	20 20		   
l7aa8h:
	jr nz,l7acah		;7aa8	20 20		   
l7aaah:
	jr nz,l7acch		;7aaa	20 20		   
l7aach:
	jr nz,l7aceh		;7aac	20 20		   
l7aaeh:
	jr nz,l7ad0h		;7aae	20 20		   
l7ab0h:
	jr nz,l7ad2h		;7ab0	20 20		   
l7ab2h:
	jr nz,l7ad4h		;7ab2	20 20		   
l7ab4h:
	jr nz,l7ad6h		;7ab4	20 20		   
l7ab6h:
	jr nz,l7ad8h		;7ab6	20 20		   
l7ab8h:
	jr nz,l7adah		;7ab8	20 20		   
l7abah:
	jr nz,l7adch		;7aba	20 20		   
l7abch:
	jr nz,l7adeh		;7abc	20 20		   
l7abeh:
	jr nz,l7ae0h		;7abe	20 20		   
l7ac0h:
	jr nz,l7ae2h		;7ac0	20 20		   
l7ac2h:
	jr nz,l7ae4h		;7ac2	20 20		   
l7ac4h:
	jr nz,l7ae6h		;7ac4	20 20		   
l7ac6h:
	jr nz,l7ae8h		;7ac6	20 20		   
l7ac8h:
	jr nz,l7aeah		;7ac8	20 20		   
l7acah:
	jr nz,l7aech		;7aca	20 20		   
l7acch:
	jr nz,l7aeeh		;7acc	20 20		   
l7aceh:
	jr nz,l7af0h		;7ace	20 20		   
l7ad0h:
	jr nz,l7af2h		;7ad0	20 20		   
l7ad2h:
	jr nz,l7af4h		;7ad2	20 20		   
l7ad4h:
	jr nz,l7af6h		;7ad4	20 20		   
l7ad6h:
	jr nz,l7af8h		;7ad6	20 20		   
l7ad8h:
	jr nz,l7afah		;7ad8	20 20		   
l7adah:
	jr nz,l7afch		;7ada	20 20		   
l7adch:
	jr nz,l7afeh		;7adc	20 20		   
l7adeh:
	jr nz,l7b00h		;7ade	20 20		   
l7ae0h:
	jr nz,l7b02h		;7ae0	20 20		   
l7ae2h:
	jr nz,l7b04h		;7ae2	20 20		   
l7ae4h:
	jr nz,l7b06h		;7ae4	20 20		   
l7ae6h:
	jr nz,l7b08h		;7ae6	20 20		   
l7ae8h:
	jr nz,l7b0ah		;7ae8	20 20		   
l7aeah:
	jr nz,l7b0ch		;7aea	20 20		   
l7aech:
	jr nz,l7b0eh		;7aec	20 20		   
l7aeeh:
	jr nz,l7b10h		;7aee	20 20		   
l7af0h:
	jr nz,l7b12h		;7af0	20 20		   
l7af2h:
	jr nz,l7b14h		;7af2	20 20		   
l7af4h:
	jr nz,l7b16h		;7af4	20 20		   
l7af6h:
	jr nz,l7b18h		;7af6	20 20		   
l7af8h:
	jr nz,l7b1ah		;7af8	20 20		   
l7afah:
	jr nz,l7b1ch		;7afa	20 20		   
l7afch:
	jr nz,l7b1eh		;7afc	20 20		   
l7afeh:
	jr nz,l7b20h		;7afe	20 20		   
l7b00h:
	jr nz,l7b22h		;7b00	20 20		   
l7b02h:
	jr nz,l7b24h		;7b02	20 20		   
l7b04h:
	jr nz,l7b26h		;7b04	20 20		   
l7b06h:
	jr nz,l7b28h		;7b06	20 20		   
l7b08h:
	jr nz,l7b2ah		;7b08	20 20		   
l7b0ah:
	jr nz,l7b2ch		;7b0a	20 20		   
l7b0ch:
	jr nz,l7b2eh		;7b0c	20 20		   
l7b0eh:
	jr nz,l7b30h		;7b0e	20 20		   
l7b10h:
	jr nz,l7b32h		;7b10	20 20		   
l7b12h:
	jr nz,l7b34h		;7b12	20 20		   
l7b14h:
	jr nz,l7b36h		;7b14	20 20		   
l7b16h:
	jr nz,l7b38h		;7b16	20 20		   
l7b18h:
	jr nz,l7b3ah		;7b18	20 20		   
l7b1ah:
	jr nz,l7b3ch		;7b1a	20 20		   
l7b1ch:
	jr nz,l7b3eh		;7b1c	20 20		   
l7b1eh:
	jr nz,l7b40h		;7b1e	20 20		   
l7b20h:
	jr nz,l7b42h		;7b20	20 20		   
l7b22h:
	jr nz,l7b44h		;7b22	20 20		   
l7b24h:
	jr nz,l7b46h		;7b24	20 20		   
l7b26h:
	jr nz,l7b48h		;7b26	20 20		   
l7b28h:
	jr nz,l7b4ah		;7b28	20 20		   
l7b2ah:
	jr nz,l7b4ch		;7b2a	20 20		   
l7b2ch:
	jr nz,l7b4eh		;7b2c	20 20		   
l7b2eh:
	jr nz,l7b50h		;7b2e	20 20		   
l7b30h:
	jr nz,l7b52h		;7b30	20 20		   
l7b32h:
	jr nz,l7b54h		;7b32	20 20		   
l7b34h:
	jr nz,l7b56h		;7b34	20 20		   
l7b36h:
	jr nz,l7b58h		;7b36	20 20		   
l7b38h:
	jr nz,l7b5ah		;7b38	20 20		   
l7b3ah:
	jr nz,l7b5ch		;7b3a	20 20		   
l7b3ch:
	jr nz,l7b5eh		;7b3c	20 20		   
l7b3eh:
	jr nz,l7b60h		;7b3e	20 20		   
l7b40h:
	jr nz,l7b62h		;7b40	20 20		   
l7b42h:
	jr nz,l7b64h		;7b42	20 20		   
l7b44h:
	jr nz,l7b66h		;7b44	20 20		   
l7b46h:
	jr nz,l7b68h		;7b46	20 20		   
l7b48h:
	jr nz,l7b6ah		;7b48	20 20		   
l7b4ah:
	jr nz,l7b6ch		;7b4a	20 20		   
l7b4ch:
	jr nz,l7b6eh		;7b4c	20 20		   
l7b4eh:
	jr nz,l7b70h		;7b4e	20 20		   
l7b50h:
	jr nz,l7b72h		;7b50	20 20		   
l7b52h:
	jr nz,l7b74h		;7b52	20 20		   
l7b54h:
	jr nz,l7b76h		;7b54	20 20		   
l7b56h:
	jr nz,l7b78h		;7b56	20 20		   
l7b58h:
	jr nz,l7b7ah		;7b58	20 20		   
l7b5ah:
	jr nz,l7b7ch		;7b5a	20 20		   
l7b5ch:
	jr nz,l7b7eh		;7b5c	20 20		   
l7b5eh:
	jr nz,l7b80h		;7b5e	20 20		   
l7b60h:
	jr nz,l7b82h		;7b60	20 20		   
l7b62h:
	jr nz,l7b84h		;7b62	20 20		   
l7b64h:
	jr nz,l7b86h		;7b64	20 20		   
l7b66h:
	jr nz,l7b88h		;7b66	20 20		   
l7b68h:
	jr nz,l7b8ah		;7b68	20 20		   
l7b6ah:
	jr nz,l7b8ch		;7b6a	20 20		   
l7b6ch:
	jr nz,l7b8eh		;7b6c	20 20		   
l7b6eh:
	jr nz,l7b90h		;7b6e	20 20		   
l7b70h:
	jr nz,l7b92h		;7b70	20 20		   
l7b72h:
	jr nz,l7b94h		;7b72	20 20		   
l7b74h:
	jr nz,l7b96h		;7b74	20 20		   
l7b76h:
	jr nz,l7b98h		;7b76	20 20		   
l7b78h:
	jr nz,l7b9ah		;7b78	20 20		   
l7b7ah:
	jr nz,l7b9ch		;7b7a	20 20		   
l7b7ch:
	jr nz,l7b9eh		;7b7c	20 20		   
l7b7eh:
	jr nz,l7ba0h		;7b7e	20 20		   
l7b80h:
	jr nz,l7ba2h		;7b80	20 20		   
l7b82h:
	jr nz,l7ba4h		;7b82	20 20		   
l7b84h:
	jr nz,l7ba6h		;7b84	20 20		   
l7b86h:
	jr nz,l7ba8h		;7b86	20 20		   
l7b88h:
	jr nz,l7baah		;7b88	20 20		   
l7b8ah:
	jr nz,l7bach		;7b8a	20 20		   
l7b8ch:
	jr nz,l7baeh		;7b8c	20 20		   
l7b8eh:
	jr nz,l7bb0h		;7b8e	20 20		   
l7b90h:
	jr nz,l7bb2h		;7b90	20 20		   
l7b92h:
	jr nz,l7bb4h		;7b92	20 20		   
l7b94h:
	jr nz,l7bb6h		;7b94	20 20		   
l7b96h:
	jr nz,l7bb8h		;7b96	20 20		   
l7b98h:
	jr nz,l7bbah		;7b98	20 20		   
l7b9ah:
	jr nz,l7bbch		;7b9a	20 20		   
l7b9ch:
	jr nz,l7bbeh		;7b9c	20 20		   
l7b9eh:
	jr nz,l7bc0h		;7b9e	20 20		   
l7ba0h:
	jr nz,l7bc2h		;7ba0	20 20		   
l7ba2h:
	jr nz,l7bc4h		;7ba2	20 20		   
l7ba4h:
	jr nz,l7bc6h		;7ba4	20 20		   
l7ba6h:
	jr nz,l7bc8h		;7ba6	20 20		   
l7ba8h:
	jr nz,l7bcah		;7ba8	20 20		   
l7baah:
	jr nz,l7bcch		;7baa	20 20		   
l7bach:
	jr nz,l7bceh		;7bac	20 20		   
l7baeh:
	jr nz,l7bd0h		;7bae	20 20		   
l7bb0h:
	jr nz,l7bd2h		;7bb0	20 20		   
l7bb2h:
	jr nz,l7bd4h		;7bb2	20 20		   
l7bb4h:
	jr nz,l7bd6h		;7bb4	20 20		   
l7bb6h:
	jr nz,l7bd8h		;7bb6	20 20		   
l7bb8h:
	jr nz,l7bdah		;7bb8	20 20		   
l7bbah:
	jr nz,l7bdch		;7bba	20 20		   
l7bbch:
	jr nz,l7bdeh		;7bbc	20 20		   
l7bbeh:
	jr nz,l7be0h		;7bbe	20 20		   
l7bc0h:
	jr nz,l7be2h		;7bc0	20 20		   
l7bc2h:
	jr nz,l7be4h		;7bc2	20 20		   
l7bc4h:
	jr nz,l7be6h		;7bc4	20 20		   
l7bc6h:
	jr nz,l7be8h		;7bc6	20 20		   
l7bc8h:
	jr nz,l7beah		;7bc8	20 20		   
l7bcah:
	rst 38h			;7bca	ff		.
	nop			;7bcb	00		.
l7bcch:
	nop			;7bcc	00		.
	nop			;7bcd	00		.
l7bceh:
	nop			;7bce	00		.
	nop			;7bcf	00		.
l7bd0h:
	nop			;7bd0	00		.
	nop			;7bd1	00		.
l7bd2h:
	nop			;7bd2	00		.
	nop			;7bd3	00		.
l7bd4h:
	nop			;7bd4	00		.
	add a,b			;7bd5	80		.
l7bd6h:
	rlca			;7bd6	07		.
	nop			;7bd7	00		.
l7bd8h:
	nop			;7bd8	00		.
	nop			;7bd9	00		.
l7bdah:
	nop			;7bda	00		.
	nop			;7bdb	00		.
l7bdch:
	nop			;7bdc	00		.
	nop			;7bdd	00		.
l7bdeh:
	nop			;7bde	00		.
	nop			;7bdf	00		.
l7be0h:
	nop			;7be0	00		.
	nop			;7be1	00		.
l7be2h:
	nop			;7be2	00		.
	nop			;7be3	00		.
l7be4h:
	nop			;7be4	00		.
	nop			;7be5	00		.
l7be6h:
	nop			;7be6	00		.
	nop			;7be7	00		.
l7be8h:
	nop			;7be8	00		.
	nop			;7be9	00		.
l7beah:
	nop			;7bea	00		.
	nop			;7beb	00		.
	nop			;7bec	00		.
	nop			;7bed	00		.
	nop			;7bee	00		.
	nop			;7bef	00		.
	nop			;7bf0	00		.
	nop			;7bf1	00		.
	nop			;7bf2	00		.
	nop			;7bf3	00		.
	nop			;7bf4	00		.
	nop			;7bf5	00		.
	nop			;7bf6	00		.
	nop			;7bf7	00		.
	nop			;7bf8	00		.
	nop			;7bf9	00		.
	rst 38h			;7bfa	ff		.
	rst 38h			;7bfb	ff		.
	rst 38h			;7bfc	ff		.
	rst 38h			;7bfd	ff		.
	rst 38h			;7bfe	ff		.
	rst 38h			;7bff	ff		.
	rst 38h			;7c00	ff		.
	rst 38h			;7c01	ff		.
	rst 38h			;7c02	ff		.
	rst 38h			;7c03	ff		.
	rst 38h			;7c04	ff		.
	rst 38h			;7c05	ff		.
	rst 38h			;7c06	ff		.
	rst 38h			;7c07	ff		.
	rst 38h			;7c08	ff		.
	rst 38h			;7c09	ff		.
	rst 38h			;7c0a	ff		.
	rst 38h			;7c0b	ff		.
	rst 38h			;7c0c	ff		.
	rst 38h			;7c0d	ff		.
	rst 38h			;7c0e	ff		.
	rst 38h			;7c0f	ff		.
	rst 38h			;7c10	ff		.
	rst 38h			;7c11	ff		.
	rst 38h			;7c12	ff		.
	rst 38h			;7c13	ff		.
	rst 38h			;7c14	ff		.
	rst 38h			;7c15	ff		.
	rst 38h			;7c16	ff		.
	rst 38h			;7c17	ff		.
	rst 38h			;7c18	ff		.
	rst 38h			;7c19	ff		.
	nop			;7c1a	00		.
	nop			;7c1b	00		.
	nop			;7c1c	00		.
	nop			;7c1d	00		.
	nop			;7c1e	00		.
	nop			;7c1f	00		.
	nop			;7c20	00		.
	nop			;7c21	00		.
	nop			;7c22	00		.
	nop			;7c23	00		.
	nop			;7c24	00		.
	nop			;7c25	00		.
	nop			;7c26	00		.
	nop			;7c27	00		.
	nop			;7c28	00		.
	nop			;7c29	00		.
	nop			;7c2a	00		.
	nop			;7c2b	00		.
	nop			;7c2c	00		.
	nop			;7c2d	00		.
	nop			;7c2e	00		.
	nop			;7c2f	00		.
	nop			;7c30	00		.
	nop			;7c31	00		.
	nop			;7c32	00		.
	nop			;7c33	00		.
	nop			;7c34	00		.
	nop			;7c35	00		.
	nop			;7c36	00		.
	nop			;7c37	00		.
	nop			;7c38	00		.
	nop			;7c39	00		.
	rst 38h			;7c3a	ff		.
	rst 38h			;7c3b	ff		.
	rst 38h			;7c3c	ff		.
	rst 38h			;7c3d	ff		.
	rst 38h			;7c3e	ff		.
	rst 38h			;7c3f	ff		.
	rst 38h			;7c40	ff		.
	rst 38h			;7c41	ff		.
	rst 38h			;7c42	ff		.
	rst 38h			;7c43	ff		.
	rst 38h			;7c44	ff		.
	rst 38h			;7c45	ff		.
	rst 38h			;7c46	ff		.
	rst 38h			;7c47	ff		.
	rst 38h			;7c48	ff		.
	rst 38h			;7c49	ff		.
	rst 38h			;7c4a	ff		.
	rst 38h			;7c4b	ff		.
	rst 38h			;7c4c	ff		.
	rst 38h			;7c4d	ff		.
	rst 38h			;7c4e	ff		.
	rst 38h			;7c4f	ff		.
	rst 38h			;7c50	ff		.
	rst 38h			;7c51	ff		.
	rst 38h			;7c52	ff		.
	rst 38h			;7c53	ff		.
	rst 38h			;7c54	ff		.
	rst 38h			;7c55	ff		.
	rst 38h			;7c56	ff		.
	rst 38h			;7c57	ff		.
	rst 38h			;7c58	ff		.
	ei			;7c59	fb		.
	nop			;7c5a	00		.
	nop			;7c5b	00		.
	nop			;7c5c	00		.
	nop			;7c5d	00		.
	nop			;7c5e	00		.
	nop			;7c5f	00		.
	nop			;7c60	00		.
	nop			;7c61	00		.
	nop			;7c62	00		.
	nop			;7c63	00		.
	nop			;7c64	00		.
	nop			;7c65	00		.
	nop			;7c66	00		.
	nop			;7c67	00		.
	nop			;7c68	00		.
	nop			;7c69	00		.
	nop			;7c6a	00		.
	nop			;7c6b	00		.
	nop			;7c6c	00		.
	nop			;7c6d	00		.
	nop			;7c6e	00		.
	nop			;7c6f	00		.
	nop			;7c70	00		.
	nop			;7c71	00		.
	nop			;7c72	00		.
	nop			;7c73	00		.
	nop			;7c74	00		.
	nop			;7c75	00		.
	nop			;7c76	00		.
	nop			;7c77	00		.
	nop			;7c78	00		.
	nop			;7c79	00		.
	rst 38h			;7c7a	ff		.
	rst 38h			;7c7b	ff		.
	rst 38h			;7c7c	ff		.
	rst 38h			;7c7d	ff		.
	rst 38h			;7c7e	ff		.
	rst 38h			;7c7f	ff		.
	rst 38h			;7c80	ff		.
	rst 38h			;7c81	ff		.
	rst 38h			;7c82	ff		.
	rst 38h			;7c83	ff		.
	rst 38h			;7c84	ff		.
	rst 38h			;7c85	ff		.
	rst 38h			;7c86	ff		.
	rst 38h			;7c87	ff		.
	rst 38h			;7c88	ff		.
	rst 38h			;7c89	ff		.
	rst 38h			;7c8a	ff		.
	rst 38h			;7c8b	ff		.
	rst 38h			;7c8c	ff		.
	rst 38h			;7c8d	ff		.
	rst 38h			;7c8e	ff		.
	rst 38h			;7c8f	ff		.
	rst 38h			;7c90	ff		.
	rst 38h			;7c91	ff		.
	rst 38h			;7c92	ff		.
	rst 38h			;7c93	ff		.
	rst 38h			;7c94	ff		.
	rst 38h			;7c95	ff		.
	rst 38h			;7c96	ff		.
	rst 38h			;7c97	ff		.
	rst 38h			;7c98	ff		.
	rst 38h			;7c99	ff		.
	nop			;7c9a	00		.
	nop			;7c9b	00		.
	nop			;7c9c	00		.
	nop			;7c9d	00		.
	nop			;7c9e	00		.
	nop			;7c9f	00		.
	ld bc,00000h		;7ca0	01 00 00	. . .
	nop			;7ca3	00		.
	nop			;7ca4	00		.
	nop			;7ca5	00		.
	nop			;7ca6	00		.
	nop			;7ca7	00		.
	nop			;7ca8	00		.
	nop			;7ca9	00		.
	nop			;7caa	00		.
	nop			;7cab	00		.
	nop			;7cac	00		.
	nop			;7cad	00		.
	nop			;7cae	00		.
	nop			;7caf	00		.
	nop			;7cb0	00		.
	nop			;7cb1	00		.
	nop			;7cb2	00		.
	nop			;7cb3	00		.
	nop			;7cb4	00		.
	nop			;7cb5	00		.
	nop			;7cb6	00		.
	nop			;7cb7	00		.
	nop			;7cb8	00		.
	nop			;7cb9	00		.
	rst 38h			;7cba	ff		.
	rst 38h			;7cbb	ff		.
	rst 38h			;7cbc	ff		.
	rst 38h			;7cbd	ff		.
	rst 38h			;7cbe	ff		.
	rst 38h			;7cbf	ff		.
	rst 38h			;7cc0	ff		.
	rst 38h			;7cc1	ff		.
	cp 0ffh			;7cc2	fe ff		. .
	rst 38h			;7cc4	ff		.
	rst 38h			;7cc5	ff		.
	rst 38h			;7cc6	ff		.
	rst 38h			;7cc7	ff		.
	rst 38h			;7cc8	ff		.
	rst 38h			;7cc9	ff		.
	rst 38h			;7cca	ff		.
	rst 38h			;7ccb	ff		.
	rst 38h			;7ccc	ff		.
	rst 38h			;7ccd	ff		.
	rst 38h			;7cce	ff		.
	rst 38h			;7ccf	ff		.
	rst 38h			;7cd0	ff		.
	rst 38h			;7cd1	ff		.
	rst 38h			;7cd2	ff		.
	rst 38h			;7cd3	ff		.
	rst 38h			;7cd4	ff		.
	rst 38h			;7cd5	ff		.
	rst 38h			;7cd6	ff		.
	rst 38h			;7cd7	ff		.
	rst 38h			;7cd8	ff		.
	rst 38h			;7cd9	ff		.
	nop			;7cda	00		.
	nop			;7cdb	00		.
	nop			;7cdc	00		.
	nop			;7cdd	00		.
	nop			;7cde	00		.
	nop			;7cdf	00		.
	nop			;7ce0	00		.
	nop			;7ce1	00		.
	nop			;7ce2	00		.
	nop			;7ce3	00		.
	nop			;7ce4	00		.
	nop			;7ce5	00		.
	nop			;7ce6	00		.
	nop			;7ce7	00		.
	nop			;7ce8	00		.
	nop			;7ce9	00		.
	nop			;7cea	00		.
	nop			;7ceb	00		.
	nop			;7cec	00		.
	nop			;7ced	00		.
	nop			;7cee	00		.
	nop			;7cef	00		.
	nop			;7cf0	00		.
	nop			;7cf1	00		.
	nop			;7cf2	00		.
	nop			;7cf3	00		.
	nop			;7cf4	00		.
	nop			;7cf5	00		.
	nop			;7cf6	00		.
	nop			;7cf7	00		.
	nop			;7cf8	00		.
	nop			;7cf9	00		.
	rst 38h			;7cfa	ff		.
	rst 38h			;7cfb	ff		.
	rst 38h			;7cfc	ff		.
	rst 38h			;7cfd	ff		.
	rst 38h			;7cfe	ff		.
	rst 38h			;7cff	ff		.
	rst 38h			;7d00	ff		.
	rst 38h			;7d01	ff		.
	rst 38h			;7d02	ff		.
	rst 38h			;7d03	ff		.
	rst 38h			;7d04	ff		.
	rst 38h			;7d05	ff		.
	rst 38h			;7d06	ff		.
	rst 38h			;7d07	ff		.
	rst 38h			;7d08	ff		.
	rst 38h			;7d09	ff		.
	rst 38h			;7d0a	ff		.
	rst 38h			;7d0b	ff		.
	rst 38h			;7d0c	ff		.
	rst 38h			;7d0d	ff		.
	rst 38h			;7d0e	ff		.
	rst 38h			;7d0f	ff		.
	rst 38h			;7d10	ff		.
	rst 38h			;7d11	ff		.
	rst 38h			;7d12	ff		.
	rst 38h			;7d13	ff		.
	rst 38h			;7d14	ff		.
	rst 38h			;7d15	ff		.
	rst 38h			;7d16	ff		.
	rst 38h			;7d17	ff		.
	rst 38h			;7d18	ff		.
	rst 38h			;7d19	ff		.
	nop			;7d1a	00		.
	nop			;7d1b	00		.
	nop			;7d1c	00		.
	nop			;7d1d	00		.
	nop			;7d1e	00		.
	nop			;7d1f	00		.
	nop			;7d20	00		.
	nop			;7d21	00		.
	nop			;7d22	00		.
	nop			;7d23	00		.
	nop			;7d24	00		.
	nop			;7d25	00		.
	nop			;7d26	00		.
	nop			;7d27	00		.
	nop			;7d28	00		.
	nop			;7d29	00		.
	nop			;7d2a	00		.
	nop			;7d2b	00		.
	nop			;7d2c	00		.
	nop			;7d2d	00		.
	nop			;7d2e	00		.
	nop			;7d2f	00		.
	nop			;7d30	00		.
	nop			;7d31	00		.
	nop			;7d32	00		.
	nop			;7d33	00		.
	nop			;7d34	00		.
	nop			;7d35	00		.
	nop			;7d36	00		.
	nop			;7d37	00		.
	nop			;7d38	00		.
	nop			;7d39	00		.
	rst 38h			;7d3a	ff		.
	rst 38h			;7d3b	ff		.
	cp 0ffh			;7d3c	fe ff		. .
	rst 38h			;7d3e	ff		.
	rst 38h			;7d3f	ff		.
	cp 0ffh			;7d40	fe ff		. .
	rst 38h			;7d42	ff		.
	rst 38h			;7d43	ff		.
	rst 38h			;7d44	ff		.
	rst 38h			;7d45	ff		.
	rst 38h			;7d46	ff		.
	rst 38h			;7d47	ff		.
	rst 38h			;7d48	ff		.
	rst 38h			;7d49	ff		.
	rst 38h			;7d4a	ff		.
	rst 38h			;7d4b	ff		.
	rst 38h			;7d4c	ff		.
	rst 38h			;7d4d	ff		.
	rst 38h			;7d4e	ff		.
	rst 38h			;7d4f	ff		.
	rst 38h			;7d50	ff		.
	rst 38h			;7d51	ff		.
	rst 38h			;7d52	ff		.
	rst 38h			;7d53	ff		.
	rst 38h			;7d54	ff		.
	rst 38h			;7d55	ff		.
	rst 38h			;7d56	ff		.
	rst 38h			;7d57	ff		.
	rst 38h			;7d58	ff		.
	rst 38h			;7d59	ff		.
	nop			;7d5a	00		.
	nop			;7d5b	00		.
	nop			;7d5c	00		.
	nop			;7d5d	00		.
	nop			;7d5e	00		.
	nop			;7d5f	00		.
	nop			;7d60	00		.
	nop			;7d61	00		.
	nop			;7d62	00		.
	nop			;7d63	00		.
	nop			;7d64	00		.
	nop			;7d65	00		.
	nop			;7d66	00		.
	nop			;7d67	00		.
	nop			;7d68	00		.
	nop			;7d69	00		.
	nop			;7d6a	00		.
	nop			;7d6b	00		.
	nop			;7d6c	00		.
	nop			;7d6d	00		.
	nop			;7d6e	00		.
	nop			;7d6f	00		.
	nop			;7d70	00		.
	nop			;7d71	00		.
	nop			;7d72	00		.
	nop			;7d73	00		.
	nop			;7d74	00		.
	nop			;7d75	00		.
	nop			;7d76	00		.
	nop			;7d77	00		.
	nop			;7d78	00		.
	nop			;7d79	00		.
	rst 38h			;7d7a	ff		.
	rst 38h			;7d7b	ff		.
	rst 38h			;7d7c	ff		.
	rst 38h			;7d7d	ff		.
	rst 38h			;7d7e	ff		.
	rst 38h			;7d7f	ff		.
	rst 38h			;7d80	ff		.
	rst 38h			;7d81	ff		.
	rst 38h			;7d82	ff		.
	rst 38h			;7d83	ff		.
	rst 38h			;7d84	ff		.
	rst 38h			;7d85	ff		.
	rst 38h			;7d86	ff		.
	rst 38h			;7d87	ff		.
	rst 38h			;7d88	ff		.
	rst 38h			;7d89	ff		.
	rst 38h			;7d8a	ff		.
	rst 38h			;7d8b	ff		.
	rst 38h			;7d8c	ff		.
	rst 38h			;7d8d	ff		.
	rst 38h			;7d8e	ff		.
	rst 38h			;7d8f	ff		.
	rst 38h			;7d90	ff		.
	rst 38h			;7d91	ff		.
	rst 38h			;7d92	ff		.
	rst 38h			;7d93	ff		.
	rst 38h			;7d94	ff		.
	rst 38h			;7d95	ff		.
	rst 38h			;7d96	ff		.
	rst 38h			;7d97	ff		.
	rst 38h			;7d98	ff		.
	rst 38h			;7d99	ff		.
	nop			;7d9a	00		.
	nop			;7d9b	00		.
	ld bc,00000h		;7d9c	01 00 00	. . .
	nop			;7d9f	00		.
	ld bc,00000h		;7da0	01 00 00	. . .
	nop			;7da3	00		.
	nop			;7da4	00		.
	nop			;7da5	00		.
	nop			;7da6	00		.
	nop			;7da7	00		.
	nop			;7da8	00		.
	nop			;7da9	00		.
	nop			;7daa	00		.
	nop			;7dab	00		.
	nop			;7dac	00		.
	nop			;7dad	00		.
	nop			;7dae	00		.
	nop			;7daf	00		.
	nop			;7db0	00		.
	nop			;7db1	00		.
	nop			;7db2	00		.
	nop			;7db3	00		.
	ld bc,00000h		;7db4	01 00 00	. . .
	nop			;7db7	00		.
	ld bc,0ff00h		;7db8	01 00 ff	. . .
	rst 38h			;7dbb	ff		.
	rst 38h			;7dbc	ff		.
	rst 38h			;7dbd	ff		.
	rst 38h			;7dbe	ff		.
	rst 38h			;7dbf	ff		.
	rst 38h			;7dc0	ff		.
	rst 38h			;7dc1	ff		.
	rst 38h			;7dc2	ff		.
	rst 38h			;7dc3	ff		.
	rst 38h			;7dc4	ff		.
	rst 38h			;7dc5	ff		.
	rst 38h			;7dc6	ff		.
	rst 38h			;7dc7	ff		.
	rst 38h			;7dc8	ff		.
	rst 38h			;7dc9	ff		.
	rst 38h			;7dca	ff		.
	rst 38h			;7dcb	ff		.
	rst 38h			;7dcc	ff		.
	rst 38h			;7dcd	ff		.
	rst 38h			;7dce	ff		.
	rst 38h			;7dcf	ff		.
	rst 38h			;7dd0	ff		.
	rst 38h			;7dd1	ff		.
	rst 38h			;7dd2	ff		.
	rst 38h			;7dd3	ff		.
	rst 38h			;7dd4	ff		.
	rst 38h			;7dd5	ff		.
	rst 38h			;7dd6	ff		.
	rst 38h			;7dd7	ff		.
	rst 38h			;7dd8	ff		.
	rst 38h			;7dd9	ff		.
	nop			;7dda	00		.
	nop			;7ddb	00		.
	nop			;7ddc	00		.
	nop			;7ddd	00		.
	nop			;7dde	00		.
	nop			;7ddf	00		.
	nop			;7de0	00		.
	nop			;7de1	00		.
	nop			;7de2	00		.
	nop			;7de3	00		.
	nop			;7de4	00		.
	nop			;7de5	00		.
	nop			;7de6	00		.
	nop			;7de7	00		.
	nop			;7de8	00		.
	nop			;7de9	00		.
	nop			;7dea	00		.
	nop			;7deb	00		.
	nop			;7dec	00		.
	nop			;7ded	00		.
	nop			;7dee	00		.
	nop			;7def	00		.
	nop			;7df0	00		.
	nop			;7df1	00		.
	nop			;7df2	00		.
	nop			;7df3	00		.
	nop			;7df4	00		.
	nop			;7df5	00		.
	nop			;7df6	00		.
	nop			;7df7	00		.
	nop			;7df8	00		.
	nop			;7df9	00		.
	rst 38h			;7dfa	ff		.
	rst 38h			;7dfb	ff		.
	rst 38h			;7dfc	ff		.
	rst 38h			;7dfd	ff		.
	rst 38h			;7dfe	ff		.
	rst 38h			;7dff	ff		.
	rst 38h			;7e00	ff		.
	rst 38h			;7e01	ff		.
	rst 38h			;7e02	ff		.
	rst 38h			;7e03	ff		.
	rst 38h			;7e04	ff		.
	rlca			;7e05	07		.
	inc hl			;7e06	23		#
	djnz $+1		;7e07	10 ff		. .
	rst 38h			;7e09	ff		.
	inc b			;7e0a	04		.
	nop			;7e0b	00		.
	nop			;7e0c	00		.
	ld bc,00101h		;7e0d	01 01 01	. . .
	ld bc,0ff06h		;7e10	01 06 ff	. . .
	rst 38h			;7e13	ff		.
	rst 38h			;7e14	ff		.
	nop			;7e15	00		.
	inc bc			;7e16	03		.
	inc b			;7e17	04		.
	rst 38h			;7e18	ff		.
	rst 38h			;7e19	ff		.
	nop			;7e1a	00		.
	nop			;7e1b	00		.
	nop			;7e1c	00		.
	nop			;7e1d	00		.
	nop			;7e1e	00		.
	nop			;7e1f	00		.
	nop			;7e20	00		.
	nop			;7e21	00		.
	nop			;7e22	00		.
	nop			;7e23	00		.
	nop			;7e24	00		.
	nop			;7e25	00		.
	nop			;7e26	00		.
	nop			;7e27	00		.
	nop			;7e28	00		.
	nop			;7e29	00		.
	ld b,(hl)		;7e2a	46		F
	inc b			;7e2b	04		.
	ld bc,00100h		;7e2c	01 00 01	. . .
	ld bc,00e10h		;7e2f	01 10 0e	. . .
	add a,b			;7e32	80		.
	nop			;7e33	00		.
	ld bc,00000h		;7e34	01 00 00	. . .
	nop			;7e37	00		.
	nop			;7e38	00		.
	nop			;7e39	00		.
	rst 38h			;7e3a	ff		.
	nop			;7e3b	00		.
	inc b			;7e3c	04		.
	rst 38h			;7e3d	ff		.
	rst 38h			;7e3e	ff		.
	rst 38h			;7e3f	ff		.
	cp 0ffh			;7e40	fe ff		. .
	rst 38h			;7e42	ff		.
	rst 38h			;7e43	ff		.
	rst 38h			;7e44	ff		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;7e45	fd ff ff	. . .
	rst 38h			;7e48	ff		.
	rst 38h			;7e49	ff		.
	rst 38h			;7e4a	ff		.
	rst 38h			;7e4b	ff		.
	rst 38h			;7e4c	ff		.
	rst 38h			;7e4d	ff		.
	rst 38h			;7e4e	ff		.
	rst 38h			;7e4f	ff		.
	rst 38h			;7e50	ff		.
	rst 38h			;7e51	ff		.
	rst 38h			;7e52	ff		.
	rst 38h			;7e53	ff		.
	rst 38h			;7e54	ff		.
	rst 38h			;7e55	ff		.
	rst 38h			;7e56	ff		.
	rst 38h			;7e57	ff		.
	rst 38h			;7e58	ff		.
	rst 38h			;7e59	ff		.
	ld bc,00500h		;7e5a	01 00 05	. . .
	nop			;7e5d	00		.
	nop			;7e5e	00		.
	nop			;7e5f	00		.
	jr l7e62h		;7e60	18 00		. .
l7e62h:
	nop			;7e62	00		.
	nop			;7e63	00		.
	nop			;7e64	00		.
	nop			;7e65	00		.
	nop			;7e66	00		.
	nop			;7e67	00		.
	nop			;7e68	00		.
	nop			;7e69	00		.
	nop			;7e6a	00		.
	nop			;7e6b	00		.
	nop			;7e6c	00		.
	nop			;7e6d	00		.
	nop			;7e6e	00		.
	nop			;7e6f	00		.
	nop			;7e70	00		.
	nop			;7e71	00		.
	nop			;7e72	00		.
	nop			;7e73	00		.
	nop			;7e74	00		.
	nop			;7e75	00		.
	nop			;7e76	00		.
	nop			;7e77	00		.
	nop			;7e78	00		.
	nop			;7e79	00		.
	rst 38h			;7e7a	ff		.
	rst 38h			;7e7b	ff		.
	rst 38h			;7e7c	ff		.
	rst 38h			;7e7d	ff		.
	rst 38h			;7e7e	ff		.
	rst 38h			;7e7f	ff		.
	rst 38h			;7e80	ff		.
	rst 38h			;7e81	ff		.
	rst 38h			;7e82	ff		.
	rst 38h			;7e83	ff		.
	rst 38h			;7e84	ff		.
	rst 38h			;7e85	ff		.
	rst 38h			;7e86	ff		.
	rst 38h			;7e87	ff		.
	rst 38h			;7e88	ff		.
	rst 38h			;7e89	ff		.
	rst 38h			;7e8a	ff		.
	rst 38h			;7e8b	ff		.
	rst 38h			;7e8c	ff		.
	rst 38h			;7e8d	ff		.
	rst 38h			;7e8e	ff		.
	rst 38h			;7e8f	ff		.
	rst 38h			;7e90	ff		.
	rst 38h			;7e91	ff		.
	rst 38h			;7e92	ff		.
	rst 38h			;7e93	ff		.
	rst 38h			;7e94	ff		.
	rst 38h			;7e95	ff		.
	rst 38h			;7e96	ff		.
	rst 38h			;7e97	ff		.
	rst 38h			;7e98	ff		.
	rst 38h			;7e99	ff		.
	nop			;7e9a	00		.
	nop			;7e9b	00		.
	nop			;7e9c	00		.
	nop			;7e9d	00		.
	nop			;7e9e	00		.
	nop			;7e9f	00		.
	nop			;7ea0	00		.
	nop			;7ea1	00		.
	nop			;7ea2	00		.
	nop			;7ea3	00		.
	nop			;7ea4	00		.
	nop			;7ea5	00		.
	nop			;7ea6	00		.
	nop			;7ea7	00		.
	nop			;7ea8	00		.
	nop			;7ea9	00		.
	nop			;7eaa	00		.
	nop			;7eab	00		.
	nop			;7eac	00		.
	nop			;7ead	00		.
	nop			;7eae	00		.
	nop			;7eaf	00		.
	nop			;7eb0	00		.
	nop			;7eb1	00		.
	nop			;7eb2	00		.
	nop			;7eb3	00		.
	nop			;7eb4	00		.
	nop			;7eb5	00		.
	nop			;7eb6	00		.
	nop			;7eb7	00		.
	nop			;7eb8	00		.
	nop			;7eb9	00		.
	cp 0ffh			;7eba	fe ff		. .
	rst 38h			;7ebc	ff		.
	rst 38h			;7ebd	ff		.
	cp 0ffh			;7ebe	fe ff		. .
	cp 0feh			;7ec0	fe fe		. .
	cp 0ffh			;7ec2	fe ff		. .
	rst 38h			;7ec4	ff		.
	rst 38h			;7ec5	ff		.
	rst 38h			;7ec6	ff		.
	rst 38h			;7ec7	ff		.
	rst 38h			;7ec8	ff		.
	rst 38h			;7ec9	ff		.
	rst 38h			;7eca	ff		.
	rst 38h			;7ecb	ff		.
	rst 38h			;7ecc	ff		.
	rst 38h			;7ecd	ff		.
	rst 38h			;7ece	ff		.
	rst 38h			;7ecf	ff		.
	rst 38h			;7ed0	ff		.
	rst 38h			;7ed1	ff		.
	rst 38h			;7ed2	ff		.
	rst 38h			;7ed3	ff		.
	rst 38h			;7ed4	ff		.
	rst 38h			;7ed5	ff		.
	rst 38h			;7ed6	ff		.
	rst 38h			;7ed7	ff		.
	rst 38h			;7ed8	ff		.
	rst 38h			;7ed9	ff		.
	nop			;7eda	00		.
	nop			;7edb	00		.
	nop			;7edc	00		.
	nop			;7edd	00		.
	nop			;7ede	00		.
	nop			;7edf	00		.
	nop			;7ee0	00		.
	nop			;7ee1	00		.
	nop			;7ee2	00		.
	nop			;7ee3	00		.
	nop			;7ee4	00		.
	nop			;7ee5	00		.
	nop			;7ee6	00		.
	nop			;7ee7	00		.
	nop			;7ee8	00		.
	nop			;7ee9	00		.
	nop			;7eea	00		.
	nop			;7eeb	00		.
	nop			;7eec	00		.
	nop			;7eed	00		.
	nop			;7eee	00		.
	nop			;7eef	00		.
	nop			;7ef0	00		.
	nop			;7ef1	00		.
	nop			;7ef2	00		.
	nop			;7ef3	00		.
	nop			;7ef4	00		.
	nop			;7ef5	00		.
	nop			;7ef6	00		.
	nop			;7ef7	00		.
	nop			;7ef8	00		.
	nop			;7ef9	00		.
	rst 38h			;7efa	ff		.
	rst 38h			;7efb	ff		.
	rst 38h			;7efc	ff		.
	rst 38h			;7efd	ff		.
	rst 38h			;7efe	ff		.
	rst 38h			;7eff	ff		.
	rst 38h			;7f00	ff		.
	rst 38h			;7f01	ff		.
	rst 38h			;7f02	ff		.
	rst 38h			;7f03	ff		.
	rst 38h			;7f04	ff		.
	rst 38h			;7f05	ff		.
	rst 38h			;7f06	ff		.
	rst 38h			;7f07	ff		.
	rst 38h			;7f08	ff		.
	rst 38h			;7f09	ff		.
	rst 38h			;7f0a	ff		.
	rst 38h			;7f0b	ff		.
	rst 38h			;7f0c	ff		.
	rst 38h			;7f0d	ff		.
	rst 38h			;7f0e	ff		.
	rst 38h			;7f0f	ff		.
	rst 38h			;7f10	ff		.
	rst 38h			;7f11	ff		.
	rst 38h			;7f12	ff		.
	rst 38h			;7f13	ff		.
	rst 38h			;7f14	ff		.
	rst 38h			;7f15	ff		.
	rst 38h			;7f16	ff		.
	rst 38h			;7f17	ff		.
	rst 38h			;7f18	ff		.
	rst 38h			;7f19	ff		.
	nop			;7f1a	00		.
	nop			;7f1b	00		.
	nop			;7f1c	00		.
	nop			;7f1d	00		.
	nop			;7f1e	00		.
	nop			;7f1f	00		.
	nop			;7f20	00		.
	nop			;7f21	00		.
	nop			;7f22	00		.
	nop			;7f23	00		.
	nop			;7f24	00		.
	nop			;7f25	00		.
	nop			;7f26	00		.
	nop			;7f27	00		.
	nop			;7f28	00		.
	nop			;7f29	00		.
	nop			;7f2a	00		.
	nop			;7f2b	00		.
	nop			;7f2c	00		.
	nop			;7f2d	00		.
	nop			;7f2e	00		.
	nop			;7f2f	00		.
	nop			;7f30	00		.
	nop			;7f31	00		.
	nop			;7f32	00		.
	nop			;7f33	00		.
	nop			;7f34	00		.
	nop			;7f35	00		.
	nop			;7f36	00		.
	nop			;7f37	00		.
	nop			;7f38	00		.
	nop			;7f39	00		.
	rst 38h			;7f3a	ff		.
	rst 38h			;7f3b	ff		.
	rst 38h			;7f3c	ff		.
	rst 38h			;7f3d	ff		.
	rst 38h			;7f3e	ff		.
	rst 38h			;7f3f	ff		.
	rst 38h			;7f40	ff		.
	rst 38h			;7f41	ff		.
	rst 38h			;7f42	ff		.
	rst 38h			;7f43	ff		.
	rst 38h			;7f44	ff		.
	rst 38h			;7f45	ff		.
	rst 38h			;7f46	ff		.
	rst 38h			;7f47	ff		.
	rst 38h			;7f48	ff		.
	rst 38h			;7f49	ff		.
	rst 38h			;7f4a	ff		.
	rst 38h			;7f4b	ff		.
	rst 38h			;7f4c	ff		.
	rst 38h			;7f4d	ff		.
	rst 38h			;7f4e	ff		.
	rst 38h			;7f4f	ff		.
	rst 38h			;7f50	ff		.
	rst 38h			;7f51	ff		.
	rst 38h			;7f52	ff		.
	rst 38h			;7f53	ff		.
	rst 38h			;7f54	ff		.
	rst 38h			;7f55	ff		.
	rst 38h			;7f56	ff		.
	rst 38h			;7f57	ff		.
	rst 38h			;7f58	ff		.
	rst 38h			;7f59	ff		.
	nop			;7f5a	00		.
	nop			;7f5b	00		.
	nop			;7f5c	00		.
	nop			;7f5d	00		.
	nop			;7f5e	00		.
	nop			;7f5f	00		.
	nop			;7f60	00		.
	nop			;7f61	00		.
	nop			;7f62	00		.
	nop			;7f63	00		.
	nop			;7f64	00		.
	nop			;7f65	00		.
	nop			;7f66	00		.
	nop			;7f67	00		.
	nop			;7f68	00		.
	nop			;7f69	00		.
	nop			;7f6a	00		.
	nop			;7f6b	00		.
	nop			;7f6c	00		.
	nop			;7f6d	00		.
	nop			;7f6e	00		.
	nop			;7f6f	00		.
	nop			;7f70	00		.
	nop			;7f71	00		.
	nop			;7f72	00		.
	nop			;7f73	00		.
	nop			;7f74	00		.
	nop			;7f75	00		.
	nop			;7f76	00		.
	nop			;7f77	00		.
	nop			;7f78	00		.
	nop			;7f79	00		.
	rst 38h			;7f7a	ff		.
	rst 38h			;7f7b	ff		.
	rst 38h			;7f7c	ff		.
	rst 38h			;7f7d	ff		.
	rst 38h			;7f7e	ff		.
	rst 38h			;7f7f	ff		.
	rst 38h			;7f80	ff		.
	rst 38h			;7f81	ff		.
	rst 38h			;7f82	ff		.
	rst 38h			;7f83	ff		.
	rst 38h			;7f84	ff		.
	rst 38h			;7f85	ff		.
	rst 38h			;7f86	ff		.
	rst 38h			;7f87	ff		.
	rst 38h			;7f88	ff		.
	rst 38h			;7f89	ff		.
	rst 38h			;7f8a	ff		.
	rst 38h			;7f8b	ff		.
	rst 38h			;7f8c	ff		.
	rst 38h			;7f8d	ff		.
	rst 38h			;7f8e	ff		.
	rst 38h			;7f8f	ff		.
	rst 38h			;7f90	ff		.
	rst 38h			;7f91	ff		.
	rst 38h			;7f92	ff		.
	rst 38h			;7f93	ff		.
	rst 38h			;7f94	ff		.
	rst 38h			;7f95	ff		.
	rst 38h			;7f96	ff		.
	rst 38h			;7f97	ff		.
	rst 38h			;7f98	ff		.
	rst 38h			;7f99	ff		.
	nop			;7f9a	00		.
	nop			;7f9b	00		.
	nop			;7f9c	00		.
	nop			;7f9d	00		.
	nop			;7f9e	00		.
	nop			;7f9f	00		.
	nop			;7fa0	00		.
	nop			;7fa1	00		.
	nop			;7fa2	00		.
	nop			;7fa3	00		.
	nop			;7fa4	00		.
	nop			;7fa5	00		.
	nop			;7fa6	00		.
	nop			;7fa7	00		.
	nop			;7fa8	00		.
	nop			;7fa9	00		.
	nop			;7faa	00		.
	nop			;7fab	00		.
	nop			;7fac	00		.
	nop			;7fad	00		.
	nop			;7fae	00		.
	nop			;7faf	00		.
	nop			;7fb0	00		.
	nop			;7fb1	00		.
	nop			;7fb2	00		.
	nop			;7fb3	00		.
	nop			;7fb4	00		.
	nop			;7fb5	00		.
	nop			;7fb6	00		.
	nop			;7fb7	00		.
	nop			;7fb8	00		.
	nop			;7fb9	00		.
	rst 38h			;7fba	ff		.
	rst 38h			;7fbb	ff		.
	rst 38h			;7fbc	ff		.
	rst 38h			;7fbd	ff		.
	rst 38h			;7fbe	ff		.
	rst 38h			;7fbf	ff		.
	rst 38h			;7fc0	ff		.
	rst 38h			;7fc1	ff		.
	rst 38h			;7fc2	ff		.
	rst 38h			;7fc3	ff		.
	rst 38h			;7fc4	ff		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;7fc5	fd ff ff	. . .
	rst 38h			;7fc8	ff		.
	rst 38h			;7fc9	ff		.
	rst 38h			;7fca	ff		.
	rst 38h			;7fcb	ff		.
	rst 38h			;7fcc	ff		.
	rst 38h			;7fcd	ff		.
	rst 38h			;7fce	ff		.
	rst 38h			;7fcf	ff		.
	rst 38h			;7fd0	ff		.
l7fd1h:
	rst 38h			;7fd1	ff		.
l7fd2h:
	rst 38h			;7fd2	ff		.
	rst 38h			;7fd3	ff		.
l7fd4h:
	rst 38h			;7fd4	ff		.
l7fd5h:
	rst 38h			;7fd5	ff		.
	rst 38h			;7fd6	ff		.
l7fd7h:
	rst 38h			;7fd7	ff		.
	rst 38h			;7fd8	ff		.
l7fd9h:
	rst 38h			;7fd9	ff		.
	nop			;7fda	00		.
l7fdbh:
	nop			;7fdb	00		.
	nop			;7fdc	00		.
l7fddh:
	nop			;7fdd	00		.
l7fdeh:
	nop			;7fde	00		.
	nop			;7fdf	00		.
l7fe0h:
	nop			;7fe0	00		.
	nop			;7fe1	00		.
l7fe2h:
	nop			;7fe2	00		.
	nop			;7fe3	00		.
l7fe4h:
	nop			;7fe4	00		.
	nop			;7fe5	00		.
l7fe6h:
	nop			;7fe6	00		.
	nop			;7fe7	00		.
	nop			;7fe8	00		.
	nop			;7fe9	00		.
	nop			;7fea	00		.
	nop			;7feb	00		.
	nop			;7fec	00		.
	nop			;7fed	00		.
	nop			;7fee	00		.
	nop			;7fef	00		.
	nop			;7ff0	00		.
	nop			;7ff1	00		.
	nop			;7ff2	00		.
	nop			;7ff3	00		.
	nop			;7ff4	00		.
	nop			;7ff5	00		.
	nop			;7ff6	00		.
	nop			;7ff7	00		.
	nop			;7ff8	00		.
	nop			;7ff9	00		.
	rst 38h			;7ffa	ff		.
	rst 38h			;7ffb	ff		.
	rst 38h			;7ffc	ff		.
	rst 38h			;7ffd	ff		.
	rst 38h			;7ffe	ff		.
	rst 38h			;7fff	ff		.
l8000h:
	rst 38h			;8000	ff		.
	rst 38h			;8001	ff		.
	rst 38h			;8002	ff		.
l8003h:
	rst 38h			;8003	ff		.
	rst 38h			;8004	ff		.
	rst 38h			;8005	ff		.
	rst 38h			;8006	ff		.
	rst 38h			;8007	ff		.
	rst 38h			;8008	ff		.
	rst 38h			;8009	ff		.
	rst 38h			;800a	ff		.
l800bh:
	rst 38h			;800b	ff		.
l800ch:
	rst 38h			;800c	ff		.
l800dh:
	rst 38h			;800d	ff		.
	rst 38h			;800e	ff		.
	rst 38h			;800f	ff		.
l8010h:
	rst 38h			;8010	ff		.
l8011h:
	rst 38h			;8011	ff		.
	rst 38h			;8012	ff		.
	rst 38h			;8013	ff		.
	rst 38h			;8014	ff		.
	rst 38h			;8015	ff		.
l8016h:
	rst 38h			;8016	ff		.
	rst 38h			;8017	ff		.
	rst 38h			;8018	ff		.
	rst 38h			;8019	ff		.
	nop			;801a	00		.
l801bh:
	nop			;801b	00		.
l801ch:
	nop			;801c	00		.
l801dh:
	nop			;801d	00		.
l801eh:
	nop			;801e	00		.
	nop			;801f	00		.
	nop			;8020	00		.
	nop			;8021	00		.
	nop			;8022	00		.
	nop			;8023	00		.
	nop			;8024	00		.
	nop			;8025	00		.
	nop			;8026	00		.
	nop			;8027	00		.
	nop			;8028	00		.
	nop			;8029	00		.
	nop			;802a	00		.
	nop			;802b	00		.
	nop			;802c	00		.
	nop			;802d	00		.
	nop			;802e	00		.
	nop			;802f	00		.
l8030h:
	nop			;8030	00		.
	nop			;8031	00		.
l8032h:
	nop			;8032	00		.
l8033h:
	nop			;8033	00		.
l8034h:
	nop			;8034	00		.
l8035h:
	nop			;8035	00		.
l8036h:
	nop			;8036	00		.
	nop			;8037	00		.
	nop			;8038	00		.
l8039h:
	nop			;8039	00		.
	rst 38h			;803a	ff		.
	rst 38h			;803b	ff		.
	rst 38h			;803c	ff		.
	rst 38h			;803d	ff		.
	rst 38h			;803e	ff		.
	rst 38h			;803f	ff		.
	rst 38h			;8040	ff		.
l8041h:
	rst 38h			;8041	ff		.
	rst 38h			;8042	ff		.
	rst 38h			;8043	ff		.
	rst 38h			;8044	ff		.
	rst 38h			;8045	ff		.
	rst 38h			;8046	ff		.
	rst 38h			;8047	ff		.
	rst 38h			;8048	ff		.
	rst 38h			;8049	ff		.
	rst 38h			;804a	ff		.
	rst 38h			;804b	ff		.
	rst 38h			;804c	ff		.
	rst 38h			;804d	ff		.
	rst 38h			;804e	ff		.
	rst 38h			;804f	ff		.
	rst 38h			;8050	ff		.
	rst 38h			;8051	ff		.
	rst 38h			;8052	ff		.
	rst 38h			;8053	ff		.
	rst 38h			;8054	ff		.
	rst 38h			;8055	ff		.
	rst 38h			;8056	ff		.
	rst 38h			;8057	ff		.
	rst 38h			;8058	ff		.
	rst 38h			;8059	ff		.
	nop			;805a	00		.
	nop			;805b	00		.
	nop			;805c	00		.
	nop			;805d	00		.
	nop			;805e	00		.
	nop			;805f	00		.
l8060h:
	nop			;8060	00		.
l8061h:
	nop			;8061	00		.
l8062h:
	nop			;8062	00		.
	nop			;8063	00		.
	nop			;8064	00		.
l8065h:
	nop			;8065	00		.
	nop			;8066	00		.
l8067h:
	nop			;8067	00		.
	nop			;8068	00		.
l8069h:
	nop			;8069	00		.
l806ah:
	nop			;806a	00		.
	nop			;806b	00		.
	nop			;806c	00		.
	nop			;806d	00		.
	nop			;806e	00		.
	nop			;806f	00		.
	nop			;8070	00		.
	nop			;8071	00		.
	nop			;8072	00		.
	nop			;8073	00		.
	nop			;8074	00		.
	nop			;8075	00		.
	nop			;8076	00		.
	nop			;8077	00		.
	nop			;8078	00		.
	nop			;8079	00		.
	rst 38h			;807a	ff		.
	rst 38h			;807b	ff		.
	rst 38h			;807c	ff		.
	rst 38h			;807d	ff		.
	rst 38h			;807e	ff		.
	rst 38h			;807f	ff		.
	rst 38h			;8080	ff		.
	rst 38h			;8081	ff		.
	rst 38h			;8082	ff		.
	rst 38h			;8083	ff		.
	rst 38h			;8084	ff		.
	rst 38h			;8085	ff		.
	rst 38h			;8086	ff		.
	rst 38h			;8087	ff		.
	rst 38h			;8088	ff		.
	rst 38h			;8089	ff		.
	rst 38h			;808a	ff		.
	rst 38h			;808b	ff		.
	rst 38h			;808c	ff		.
	rst 38h			;808d	ff		.
	rst 38h			;808e	ff		.
	rst 38h			;808f	ff		.
	rst 38h			;8090	ff		.
	rst 38h			;8091	ff		.
	rst 38h			;8092	ff		.
	rst 38h			;8093	ff		.
	rst 38h			;8094	ff		.
	rst 38h			;8095	ff		.
	rst 38h			;8096	ff		.
	rst 38h			;8097	ff		.
	rst 38h			;8098	ff		.
	rst 38h			;8099	ff		.
	nop			;809a	00		.
	nop			;809b	00		.
	nop			;809c	00		.
	nop			;809d	00		.
	nop			;809e	00		.
	nop			;809f	00		.
	nop			;80a0	00		.
	nop			;80a1	00		.
	nop			;80a2	00		.
	nop			;80a3	00		.
	nop			;80a4	00		.
	nop			;80a5	00		.
	nop			;80a6	00		.
	nop			;80a7	00		.
	nop			;80a8	00		.
	nop			;80a9	00		.
	nop			;80aa	00		.
	nop			;80ab	00		.
	nop			;80ac	00		.
	nop			;80ad	00		.
	nop			;80ae	00		.
	ld b,b			;80af	40		@
	nop			;80b0	00		.
	nop			;80b1	00		.
	nop			;80b2	00		.
	nop			;80b3	00		.
	nop			;80b4	00		.
	nop			;80b5	00		.
	nop			;80b6	00		.
	nop			;80b7	00		.
	nop			;80b8	00		.
	nop			;80b9	00		.
	cp 0ffh			;80ba	fe ff		. .
	rst 38h			;80bc	ff		.
	rst 38h			;80bd	ff		.
	cp 0ffh			;80be	fe ff		. .
	rst 38h			;80c0	ff		.
	rst 38h			;80c1	ff		.
	cp 0ffh			;80c2	fe ff		. .
	rst 38h			;80c4	ff		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;80c5	fd ff ff	. . .
	rst 38h			;80c8	ff		.
	rst 38h			;80c9	ff		.
	rst 38h			;80ca	ff		.
	rst 38h			;80cb	ff		.
	rst 38h			;80cc	ff		.
	rst 38h			;80cd	ff		.
	rst 38h			;80ce	ff		.
	rst 38h			;80cf	ff		.
	rst 38h			;80d0	ff		.
	rst 38h			;80d1	ff		.
	rst 38h			;80d2	ff		.
	rst 38h			;80d3	ff		.
	rst 38h			;80d4	ff		.
	rst 38h			;80d5	ff		.
	rst 38h			;80d6	ff		.
	rst 38h			;80d7	ff		.
	ei			;80d8	fb		.
	rst 38h			;80d9	ff		.
	nop			;80da	00		.
	nop			;80db	00		.
	nop			;80dc	00		.
	nop			;80dd	00		.
	nop			;80de	00		.
	nop			;80df	00		.
	nop			;80e0	00		.
	nop			;80e1	00		.
	nop			;80e2	00		.
	nop			;80e3	00		.
	nop			;80e4	00		.
	nop			;80e5	00		.
	nop			;80e6	00		.
	nop			;80e7	00		.
	nop			;80e8	00		.
	nop			;80e9	00		.
	nop			;80ea	00		.
	nop			;80eb	00		.
	nop			;80ec	00		.
	nop			;80ed	00		.
	nop			;80ee	00		.
	nop			;80ef	00		.
	nop			;80f0	00		.
	nop			;80f1	00		.
	nop			;80f2	00		.
	nop			;80f3	00		.
	nop			;80f4	00		.
	nop			;80f5	00		.
	nop			;80f6	00		.
	nop			;80f7	00		.
	nop			;80f8	00		.
	nop			;80f9	00		.
	rst 38h			;80fa	ff		.
	rst 38h			;80fb	ff		.
	rst 38h			;80fc	ff		.
	rst 38h			;80fd	ff		.
	rst 38h			;80fe	ff		.
	rst 38h			;80ff	ff		.
	rst 38h			;8100	ff		.
	rst 38h			;8101	ff		.
	rst 38h			;8102	ff		.
	rst 38h			;8103	ff		.
	rst 38h			;8104	ff		.
	rst 38h			;8105	ff		.
	rst 38h			;8106	ff		.
	rst 38h			;8107	ff		.
	rst 38h			;8108	ff		.
	rst 38h			;8109	ff		.
	rst 38h			;810a	ff		.
	rst 38h			;810b	ff		.
	rst 38h			;810c	ff		.
	rst 38h			;810d	ff		.
	rst 38h			;810e	ff		.
	rst 38h			;810f	ff		.
	rst 38h			;8110	ff		.
	rst 38h			;8111	ff		.
	rst 38h			;8112	ff		.
	rst 38h			;8113	ff		.
	rst 38h			;8114	ff		.
	rst 38h			;8115	ff		.
	rst 38h			;8116	ff		.
	rst 38h			;8117	ff		.
	rst 38h			;8118	ff		.
	rst 38h			;8119	ff		.
	nop			;811a	00		.
	nop			;811b	00		.
	nop			;811c	00		.
	nop			;811d	00		.
	nop			;811e	00		.
	nop			;811f	00		.
	nop			;8120	00		.
	nop			;8121	00		.
	nop			;8122	00		.
	nop			;8123	00		.
	nop			;8124	00		.
	nop			;8125	00		.
	nop			;8126	00		.
	nop			;8127	00		.
	nop			;8128	00		.
	nop			;8129	00		.
	nop			;812a	00		.
	nop			;812b	00		.
	nop			;812c	00		.
	nop			;812d	00		.
	nop			;812e	00		.
	nop			;812f	00		.
	nop			;8130	00		.
	nop			;8131	00		.
	nop			;8132	00		.
	nop			;8133	00		.
	nop			;8134	00		.
	nop			;8135	00		.
	nop			;8136	00		.
	nop			;8137	00		.
	nop			;8138	00		.
	nop			;8139	00		.
	rst 38h			;813a	ff		.
	rst 38h			;813b	ff		.
	cp 0ffh			;813c	fe ff		. .
	rst 38h			;813e	ff		.
	rst 38h			;813f	ff		.
	cp 0ffh			;8140	fe ff		. .
	rst 38h			;8142	ff		.
	rst 38h			;8143	ff		.
	cp 0ffh			;8144	fe ff		. .
	rst 38h			;8146	ff		.
	rst 38h			;8147	ff		.
	rst 38h			;8148	ff		.
	rst 38h			;8149	ff		.
	rst 38h			;814a	ff		.
	rst 38h			;814b	ff		.
	rst 38h			;814c	ff		.
	rst 38h			;814d	ff		.
	rst 38h			;814e	ff		.
	rst 38h			;814f	ff		.
	rst 38h			;8150	ff		.
	rst 38h			;8151	ff		.
	rst 38h			;8152	ff		.
	rst 38h			;8153	ff		.
	rst 38h			;8154	ff		.
	rst 38h			;8155	ff		.
	rst 38h			;8156	ff		.
	rst 38h			;8157	ff		.
	rst 38h			;8158	ff		.
	rst 38h			;8159	ff		.
	nop			;815a	00		.
	nop			;815b	00		.
	nop			;815c	00		.
	nop			;815d	00		.
	nop			;815e	00		.
	nop			;815f	00		.
	nop			;8160	00		.
	nop			;8161	00		.
	nop			;8162	00		.
	nop			;8163	00		.
	nop			;8164	00		.
	nop			;8165	00		.
	nop			;8166	00		.
	nop			;8167	00		.
	nop			;8168	00		.
	nop			;8169	00		.
	nop			;816a	00		.
	nop			;816b	00		.
	nop			;816c	00		.
	nop			;816d	00		.
	nop			;816e	00		.
	nop			;816f	00		.
	nop			;8170	00		.
	nop			;8171	00		.
	nop			;8172	00		.
	nop			;8173	00		.
	nop			;8174	00		.
	nop			;8175	00		.
	nop			;8176	00		.
	nop			;8177	00		.
	nop			;8178	00		.
	nop			;8179	00		.
	rst 38h			;817a	ff		.
	rst 38h			;817b	ff		.
	rst 38h			;817c	ff		.
	rst 38h			;817d	ff		.
	rst 38h			;817e	ff		.
	rst 38h			;817f	ff		.
	rst 38h			;8180	ff		.
	rst 38h			;8181	ff		.
	rst 38h			;8182	ff		.
	rst 38h			;8183	ff		.
	rst 38h			;8184	ff		.
	rst 38h			;8185	ff		.
	rst 38h			;8186	ff		.
	rst 38h			;8187	ff		.
	rst 38h			;8188	ff		.
	rst 38h			;8189	ff		.
	rst 38h			;818a	ff		.
	rst 38h			;818b	ff		.
	rst 38h			;818c	ff		.
	rst 38h			;818d	ff		.
	rst 38h			;818e	ff		.
	rst 38h			;818f	ff		.
	rst 38h			;8190	ff		.
	rst 38h			;8191	ff		.
	rst 38h			;8192	ff		.
	rst 38h			;8193	ff		.
	rst 38h			;8194	ff		.
	rst 38h			;8195	ff		.
	rst 38h			;8196	ff		.
	rst 38h			;8197	ff		.
	rst 38h			;8198	ff		.
	rst 38h			;8199	ff		.
	nop			;819a	00		.
	nop			;819b	00		.
	nop			;819c	00		.
	nop			;819d	00		.
	nop			;819e	00		.
	nop			;819f	00		.
	nop			;81a0	00		.
	nop			;81a1	00		.
	nop			;81a2	00		.
	nop			;81a3	00		.
	nop			;81a4	00		.
	nop			;81a5	00		.
	nop			;81a6	00		.
	nop			;81a7	00		.
	nop			;81a8	00		.
	nop			;81a9	00		.
	nop			;81aa	00		.
	nop			;81ab	00		.
	nop			;81ac	00		.
	nop			;81ad	00		.
	nop			;81ae	00		.
	nop			;81af	00		.
	nop			;81b0	00		.
	nop			;81b1	00		.
	nop			;81b2	00		.
	nop			;81b3	00		.
	nop			;81b4	00		.
	nop			;81b5	00		.
	nop			;81b6	00		.
	nop			;81b7	00		.
	nop			;81b8	00		.
	nop			;81b9	00		.
	cp 0ffh			;81ba	fe ff		. .
	rst 38h			;81bc	ff		.
	rst 38h			;81bd	ff		.
	cp 0ffh			;81be	fe ff		. .
	rst 38h			;81c0	ff		.
	rst 38h			;81c1	ff		.
	cp 0ffh			;81c2	fe ff		. .
	rst 38h			;81c4	ff		.
	rst 38h			;81c5	ff		.
	rst 38h			;81c6	ff		.
	rst 38h			;81c7	ff		.
	rst 38h			;81c8	ff		.
	rst 38h			;81c9	ff		.
	rst 38h			;81ca	ff		.
	rst 38h			;81cb	ff		.
	rst 38h			;81cc	ff		.
	rst 38h			;81cd	ff		.
	rst 38h			;81ce	ff		.
	rst 38h			;81cf	ff		.
	rst 38h			;81d0	ff		.
	rst 38h			;81d1	ff		.
	rst 38h			;81d2	ff		.
	rst 38h			;81d3	ff		.
	ei			;81d4	fb		.
	rst 38h			;81d5	ff		.
	rst 38h			;81d6	ff		.
	rst 38h			;81d7	ff		.
	ei			;81d8	fb		.
	ei			;81d9	fb		.
	nop			;81da	00		.
	nop			;81db	00		.
	nop			;81dc	00		.
	nop			;81dd	00		.
	nop			;81de	00		.
	nop			;81df	00		.
	nop			;81e0	00		.
	nop			;81e1	00		.
	nop			;81e2	00		.
	nop			;81e3	00		.
	nop			;81e4	00		.
	nop			;81e5	00		.
	nop			;81e6	00		.
	nop			;81e7	00		.
	nop			;81e8	00		.
	nop			;81e9	00		.
	nop			;81ea	00		.
	nop			;81eb	00		.
	nop			;81ec	00		.
	nop			;81ed	00		.
	nop			;81ee	00		.
	nop			;81ef	00		.
	nop			;81f0	00		.
	nop			;81f1	00		.
	nop			;81f2	00		.
	nop			;81f3	00		.
	nop			;81f4	00		.
	nop			;81f5	00		.
	nop			;81f6	00		.
	nop			;81f7	00		.
	nop			;81f8	00		.
	nop			;81f9	00		.
	rst 38h			;81fa	ff		.
	rst 38h			;81fb	ff		.
	rst 38h			;81fc	ff		.
	rst 38h			;81fd	ff		.
	rst 38h			;81fe	ff		.
	rst 38h			;81ff	ff		.
	rst 38h			;8200	ff		.
	rst 38h			;8201	ff		.
	rst 38h			;8202	ff		.
	rst 38h			;8203	ff		.
	rst 38h			;8204	ff		.
	rst 38h			;8205	ff		.
	rst 38h			;8206	ff		.
	rst 38h			;8207	ff		.
	rst 38h			;8208	ff		.
	rst 38h			;8209	ff		.
	rst 38h			;820a	ff		.
	rst 38h			;820b	ff		.
	rst 38h			;820c	ff		.
	rst 38h			;820d	ff		.
	rst 38h			;820e	ff		.
	rst 38h			;820f	ff		.
	rst 38h			;8210	ff		.
	rst 38h			;8211	ff		.
	rst 38h			;8212	ff		.
	rst 38h			;8213	ff		.
	rst 38h			;8214	ff		.
	rst 38h			;8215	ff		.
	rst 38h			;8216	ff		.
	rst 38h			;8217	ff		.
	rst 38h			;8218	ff		.
	rst 38h			;8219	ff		.
	nop			;821a	00		.
	nop			;821b	00		.
	nop			;821c	00		.
	nop			;821d	00		.
	nop			;821e	00		.
	nop			;821f	00		.
	nop			;8220	00		.
	nop			;8221	00		.
	nop			;8222	00		.
	nop			;8223	00		.
	nop			;8224	00		.
	nop			;8225	00		.
	nop			;8226	00		.
	nop			;8227	00		.
	nop			;8228	00		.
	nop			;8229	00		.
	nop			;822a	00		.
	nop			;822b	00		.
	nop			;822c	00		.
	nop			;822d	00		.
	nop			;822e	00		.
	nop			;822f	00		.
	nop			;8230	00		.
	nop			;8231	00		.
	nop			;8232	00		.
	nop			;8233	00		.
	nop			;8234	00		.
	nop			;8235	00		.
	nop			;8236	00		.
	nop			;8237	00		.
	nop			;8238	00		.
	nop			;8239	00		.
	rst 38h			;823a	ff		.
	rst 38h			;823b	ff		.
	rst 38h			;823c	ff		.
	rst 38h			;823d	ff		.
	rst 38h			;823e	ff		.
	rst 38h			;823f	ff		.
	cp 0ffh			;8240	fe ff		. .
	rst 38h			;8242	ff		.
	rst 38h			;8243	ff		.
	rst 38h			;8244	ff		.
	rst 38h			;8245	ff		.
	rst 38h			;8246	ff		.
	rst 38h			;8247	ff		.
	rst 38h			;8248	ff		.
	rst 38h			;8249	ff		.
	rst 38h			;824a	ff		.
	rst 38h			;824b	ff		.
	rst 38h			;824c	ff		.
	rst 38h			;824d	ff		.
	rst 38h			;824e	ff		.
	rst 38h			;824f	ff		.
	rst 38h			;8250	ff		.
	rst 38h			;8251	ff		.
	rst 38h			;8252	ff		.
	rst 38h			;8253	ff		.
	rst 38h			;8254	ff		.
	rst 38h			;8255	ff		.
	rst 38h			;8256	ff		.
	rst 38h			;8257	ff		.
	rst 38h			;8258	ff		.
	rst 38h			;8259	ff		.
	nop			;825a	00		.
	nop			;825b	00		.
	nop			;825c	00		.
	nop			;825d	00		.
	nop			;825e	00		.
	nop			;825f	00		.
	nop			;8260	00		.
	nop			;8261	00		.
	nop			;8262	00		.
	nop			;8263	00		.
	nop			;8264	00		.
	nop			;8265	00		.
	nop			;8266	00		.
	nop			;8267	00		.
	nop			;8268	00		.
	nop			;8269	00		.
	nop			;826a	00		.
	nop			;826b	00		.
	nop			;826c	00		.
	nop			;826d	00		.
	nop			;826e	00		.
	nop			;826f	00		.
	nop			;8270	00		.
	nop			;8271	00		.
	nop			;8272	00		.
	nop			;8273	00		.
	nop			;8274	00		.
	nop			;8275	00		.
	nop			;8276	00		.
	nop			;8277	00		.
	nop			;8278	00		.
	nop			;8279	00		.
	rst 38h			;827a	ff		.
	rst 38h			;827b	ff		.
	rst 38h			;827c	ff		.
	rst 38h			;827d	ff		.
	rst 38h			;827e	ff		.
	rst 38h			;827f	ff		.
	rst 38h			;8280	ff		.
	rst 38h			;8281	ff		.
	rst 38h			;8282	ff		.
	rst 38h			;8283	ff		.
	rst 38h			;8284	ff		.
	rst 38h			;8285	ff		.
	rst 38h			;8286	ff		.
	rst 38h			;8287	ff		.
	rst 38h			;8288	ff		.
	rst 38h			;8289	ff		.
	rst 38h			;828a	ff		.
	rst 38h			;828b	ff		.
	rst 38h			;828c	ff		.
	rst 38h			;828d	ff		.
	rst 38h			;828e	ff		.
	rst 38h			;828f	ff		.
	rst 38h			;8290	ff		.
	rst 38h			;8291	ff		.
	rst 38h			;8292	ff		.
	rst 38h			;8293	ff		.
	rst 38h			;8294	ff		.
	rst 38h			;8295	ff		.
	rst 38h			;8296	ff		.
	rst 38h			;8297	ff		.
	rst 38h			;8298	ff		.
	rst 38h			;8299	ff		.
	nop			;829a	00		.
	nop			;829b	00		.
	nop			;829c	00		.
	nop			;829d	00		.
	nop			;829e	00		.
	nop			;829f	00		.
	nop			;82a0	00		.
	nop			;82a1	00		.
	nop			;82a2	00		.
	nop			;82a3	00		.
	nop			;82a4	00		.
	nop			;82a5	00		.
	nop			;82a6	00		.
	nop			;82a7	00		.
	nop			;82a8	00		.
	nop			;82a9	00		.
	nop			;82aa	00		.
	nop			;82ab	00		.
	nop			;82ac	00		.
	nop			;82ad	00		.
	nop			;82ae	00		.
	nop			;82af	00		.
	nop			;82b0	00		.
	nop			;82b1	00		.
	nop			;82b2	00		.
	nop			;82b3	00		.
	nop			;82b4	00		.
	nop			;82b5	00		.
	nop			;82b6	00		.
	nop			;82b7	00		.
	nop			;82b8	00		.
	nop			;82b9	00		.
	cp 0ffh			;82ba	fe ff		. .
	rst 38h			;82bc	ff		.
	cp 0feh			;82bd	fe fe		. .
	rst 38h			;82bf	ff		.
	rst 38h			;82c0	ff		.
	rst 38h			;82c1	ff		.
	cp 0ffh			;82c2	fe ff		. .
	rst 18h			;82c4	df		.
	rst 38h			;82c5	ff		.
	rst 38h			;82c6	ff		.
	rst 38h			;82c7	ff		.
	rst 38h			;82c8	ff		.
	rst 38h			;82c9	ff		.
	rst 38h			;82ca	ff		.
	rst 38h			;82cb	ff		.
	rst 38h			;82cc	ff		.
	rst 38h			;82cd	ff		.
	rst 38h			;82ce	ff		.
	rst 38h			;82cf	ff		.
	rst 38h			;82d0	ff		.
	rst 38h			;82d1	ff		.
	rst 38h			;82d2	ff		.
	rst 38h			;82d3	ff		.
	rst 38h			;82d4	ff		.
	rst 38h			;82d5	ff		.
	rst 38h			;82d6	ff		.
	rst 38h			;82d7	ff		.
	rst 38h			;82d8	ff		.
	ei			;82d9	fb		.
	nop			;82da	00		.
	nop			;82db	00		.
	nop			;82dc	00		.
	nop			;82dd	00		.
	nop			;82de	00		.
	nop			;82df	00		.
	nop			;82e0	00		.
	nop			;82e1	00		.
	nop			;82e2	00		.
	nop			;82e3	00		.
	nop			;82e4	00		.
	nop			;82e5	00		.
	nop			;82e6	00		.
	nop			;82e7	00		.
	nop			;82e8	00		.
	nop			;82e9	00		.
	nop			;82ea	00		.
	nop			;82eb	00		.
	nop			;82ec	00		.
	nop			;82ed	00		.
	nop			;82ee	00		.
	nop			;82ef	00		.
	nop			;82f0	00		.
	nop			;82f1	00		.
	nop			;82f2	00		.
	nop			;82f3	00		.
	nop			;82f4	00		.
	nop			;82f5	00		.
	nop			;82f6	00		.
	nop			;82f7	00		.
	nop			;82f8	00		.
	nop			;82f9	00		.
	rst 38h			;82fa	ff		.
	rst 38h			;82fb	ff		.
	rst 38h			;82fc	ff		.
	rst 38h			;82fd	ff		.
	rst 38h			;82fe	ff		.
	rst 38h			;82ff	ff		.
	rst 38h			;8300	ff		.
	rst 38h			;8301	ff		.
	rst 38h			;8302	ff		.
	rst 38h			;8303	ff		.
	rst 38h			;8304	ff		.
	rst 38h			;8305	ff		.
	rst 38h			;8306	ff		.
	rst 38h			;8307	ff		.
	rst 38h			;8308	ff		.
	rst 38h			;8309	ff		.
	rst 38h			;830a	ff		.
	rst 38h			;830b	ff		.
	rst 38h			;830c	ff		.
	rst 38h			;830d	ff		.
	rst 38h			;830e	ff		.
	rst 38h			;830f	ff		.
	rst 38h			;8310	ff		.
	rst 38h			;8311	ff		.
	rst 38h			;8312	ff		.
	rst 38h			;8313	ff		.
	rst 38h			;8314	ff		.
	rst 38h			;8315	ff		.
	rst 38h			;8316	ff		.
	rst 38h			;8317	ff		.
	rst 38h			;8318	ff		.
	rst 38h			;8319	ff		.
	nop			;831a	00		.
	nop			;831b	00		.
	nop			;831c	00		.
	nop			;831d	00		.
	nop			;831e	00		.
	nop			;831f	00		.
	nop			;8320	00		.
	nop			;8321	00		.
	nop			;8322	00		.
	nop			;8323	00		.
	nop			;8324	00		.
	nop			;8325	00		.
	nop			;8326	00		.
	nop			;8327	00		.
	nop			;8328	00		.
	nop			;8329	00		.
	nop			;832a	00		.
	nop			;832b	00		.
	nop			;832c	00		.
	nop			;832d	00		.
	nop			;832e	00		.
	nop			;832f	00		.
	nop			;8330	00		.
	nop			;8331	00		.
	nop			;8332	00		.
	nop			;8333	00		.
	nop			;8334	00		.
	nop			;8335	00		.
	ld bc,00000h		;8336	01 00 00	. . .
	nop			;8339	00		.
	rst 38h			;833a	ff		.
	rst 38h			;833b	ff		.
	rst 38h			;833c	ff		.
	rst 38h			;833d	ff		.
	rst 38h			;833e	ff		.
	rst 38h			;833f	ff		.
	rst 38h			;8340	ff		.
	rst 38h			;8341	ff		.
	rst 38h			;8342	ff		.
	rst 38h			;8343	ff		.
	rst 38h			;8344	ff		.
	rst 38h			;8345	ff		.
	rst 38h			;8346	ff		.
	rst 38h			;8347	ff		.
	rst 38h			;8348	ff		.
	rst 38h			;8349	ff		.
	rst 38h			;834a	ff		.
	rst 38h			;834b	ff		.
	rst 38h			;834c	ff		.
	rst 38h			;834d	ff		.
	rst 38h			;834e	ff		.
	rst 38h			;834f	ff		.
	rst 38h			;8350	ff		.
	rst 38h			;8351	ff		.
	rst 38h			;8352	ff		.
	rst 38h			;8353	ff		.
	rst 38h			;8354	ff		.
	rst 38h			;8355	ff		.
	rst 38h			;8356	ff		.
	rst 38h			;8357	ff		.
	rst 38h			;8358	ff		.
	ei			;8359	fb		.
	nop			;835a	00		.
	nop			;835b	00		.
	nop			;835c	00		.
	nop			;835d	00		.
	nop			;835e	00		.
	nop			;835f	00		.
	nop			;8360	00		.
	nop			;8361	00		.
	nop			;8362	00		.
	nop			;8363	00		.
	nop			;8364	00		.
	nop			;8365	00		.
	nop			;8366	00		.
	nop			;8367	00		.
	nop			;8368	00		.
	nop			;8369	00		.
	nop			;836a	00		.
	nop			;836b	00		.
	nop			;836c	00		.
	nop			;836d	00		.
	nop			;836e	00		.
	nop			;836f	00		.
	nop			;8370	00		.
	nop			;8371	00		.
	nop			;8372	00		.
	nop			;8373	00		.
	nop			;8374	00		.
	nop			;8375	00		.
	nop			;8376	00		.
	nop			;8377	00		.
	nop			;8378	00		.
	nop			;8379	00		.
	rst 38h			;837a	ff		.
	rst 38h			;837b	ff		.
	rst 38h			;837c	ff		.
	rst 38h			;837d	ff		.
	rst 38h			;837e	ff		.
	rst 38h			;837f	ff		.
	rst 38h			;8380	ff		.
	rst 38h			;8381	ff		.
	rst 38h			;8382	ff		.
	rst 38h			;8383	ff		.
	rst 38h			;8384	ff		.
	rst 38h			;8385	ff		.
	rst 38h			;8386	ff		.
	rst 38h			;8387	ff		.
	rst 38h			;8388	ff		.
	rst 38h			;8389	ff		.
	rst 38h			;838a	ff		.
	rst 38h			;838b	ff		.
	rst 38h			;838c	ff		.
	rst 38h			;838d	ff		.
	rst 38h			;838e	ff		.
	rst 38h			;838f	ff		.
	rst 38h			;8390	ff		.
	rst 38h			;8391	ff		.
	rst 38h			;8392	ff		.
	rst 38h			;8393	ff		.
	rst 38h			;8394	ff		.
	rst 38h			;8395	ff		.
	rst 38h			;8396	ff		.
	rst 38h			;8397	ff		.
	rst 38h			;8398	ff		.
	rst 38h			;8399	ff		.
	nop			;839a	00		.
	nop			;839b	00		.
	nop			;839c	00		.
	nop			;839d	00		.
	nop			;839e	00		.
	nop			;839f	00		.
	nop			;83a0	00		.
	nop			;83a1	00		.
	nop			;83a2	00		.
	nop			;83a3	00		.
	nop			;83a4	00		.
	nop			;83a5	00		.
	nop			;83a6	00		.
	nop			;83a7	00		.
	nop			;83a8	00		.
	nop			;83a9	00		.
	nop			;83aa	00		.
	nop			;83ab	00		.
	nop			;83ac	00		.
	nop			;83ad	00		.
	nop			;83ae	00		.
	nop			;83af	00		.
	nop			;83b0	00		.
	nop			;83b1	00		.
	nop			;83b2	00		.
	nop			;83b3	00		.
	nop			;83b4	00		.
	nop			;83b5	00		.
	nop			;83b6	00		.
	nop			;83b7	00		.
	nop			;83b8	00		.
	nop			;83b9	00		.
	rst 38h			;83ba	ff		.
	rst 38h			;83bb	ff		.
	rst 38h			;83bc	ff		.
	rst 38h			;83bd	ff		.
	rst 38h			;83be	ff		.
	rst 38h			;83bf	ff		.
	rst 38h			;83c0	ff		.
	rst 38h			;83c1	ff		.
	rst 38h			;83c2	ff		.
	rst 38h			;83c3	ff		.
	rst 38h			;83c4	ff		.
	rst 38h			;83c5	ff		.
	rst 38h			;83c6	ff		.
	rst 38h			;83c7	ff		.
	rst 38h			;83c8	ff		.
	rst 38h			;83c9	ff		.
	rst 38h			;83ca	ff		.
	rst 38h			;83cb	ff		.
	rst 38h			;83cc	ff		.
	rst 38h			;83cd	ff		.
	rst 38h			;83ce	ff		.
	rst 38h			;83cf	ff		.
	rst 38h			;83d0	ff		.
	rst 38h			;83d1	ff		.
	rst 38h			;83d2	ff		.
	rst 38h			;83d3	ff		.
	rst 38h			;83d4	ff		.
	rst 38h			;83d5	ff		.
	rst 38h			;83d6	ff		.
	rst 38h			;83d7	ff		.
	rst 38h			;83d8	ff		.
	rst 38h			;83d9	ff		.
	nop			;83da	00		.
	nop			;83db	00		.
	nop			;83dc	00		.
	nop			;83dd	00		.
	nop			;83de	00		.
	nop			;83df	00		.
	nop			;83e0	00		.
	nop			;83e1	00		.
	nop			;83e2	00		.
	nop			;83e3	00		.
	nop			;83e4	00		.
	nop			;83e5	00		.
	nop			;83e6	00		.
	nop			;83e7	00		.
	nop			;83e8	00		.
	nop			;83e9	00		.
	nop			;83ea	00		.
	nop			;83eb	00		.
	nop			;83ec	00		.
	nop			;83ed	00		.
	nop			;83ee	00		.
	nop			;83ef	00		.
	nop			;83f0	00		.
	nop			;83f1	00		.
	nop			;83f2	00		.
	nop			;83f3	00		.
	nop			;83f4	00		.
	nop			;83f5	00		.
	nop			;83f6	00		.
	nop			;83f7	00		.
	nop			;83f8	00		.
	nop			;83f9	00		.
	rst 38h			;83fa	ff		.
	rst 38h			;83fb	ff		.
	rst 38h			;83fc	ff		.
	rst 38h			;83fd	ff		.
	rst 38h			;83fe	ff		.
	rst 38h			;83ff	ff		.
	rst 38h			;8400	ff		.
	rst 38h			;8401	ff		.
	rst 38h			;8402	ff		.
	rst 38h			;8403	ff		.
	rst 38h			;8404	ff		.
	rst 38h			;8405	ff		.
	rst 38h			;8406	ff		.
	rst 38h			;8407	ff		.
	rst 38h			;8408	ff		.
	rst 38h			;8409	ff		.
	rst 38h			;840a	ff		.
	rst 38h			;840b	ff		.
	rst 38h			;840c	ff		.
	rst 38h			;840d	ff		.
	rst 38h			;840e	ff		.
	rst 38h			;840f	ff		.
	rst 38h			;8410	ff		.
	rst 38h			;8411	ff		.
	rst 38h			;8412	ff		.
	rst 38h			;8413	ff		.
	rst 38h			;8414	ff		.
	rst 38h			;8415	ff		.
	rst 38h			;8416	ff		.
	rst 38h			;8417	ff		.
	rst 38h			;8418	ff		.
	rst 38h			;8419	ff		.
	nop			;841a	00		.
	nop			;841b	00		.
	nop			;841c	00		.
	nop			;841d	00		.
	nop			;841e	00		.
	nop			;841f	00		.
	nop			;8420	00		.
	nop			;8421	00		.
	nop			;8422	00		.
	nop			;8423	00		.
	nop			;8424	00		.
	nop			;8425	00		.
	nop			;8426	00		.
	nop			;8427	00		.
	nop			;8428	00		.
	nop			;8429	00		.
	nop			;842a	00		.
	nop			;842b	00		.
	nop			;842c	00		.
	nop			;842d	00		.
	nop			;842e	00		.
	nop			;842f	00		.
	nop			;8430	00		.
	nop			;8431	00		.
	nop			;8432	00		.
	nop			;8433	00		.
	nop			;8434	00		.
	nop			;8435	00		.
	nop			;8436	00		.
	nop			;8437	00		.
	nop			;8438	00		.
	nop			;8439	00		.
	rst 38h			;843a	ff		.
	rst 38h			;843b	ff		.
	rst 38h			;843c	ff		.
	rst 38h			;843d	ff		.
	rst 38h			;843e	ff		.
	rst 38h			;843f	ff		.
	rst 38h			;8440	ff		.
	rst 38h			;8441	ff		.
	rst 38h			;8442	ff		.
	rst 38h			;8443	ff		.
	rst 38h			;8444	ff		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;8445	fd ff ff	. . .
	rst 38h			;8448	ff		.
	rst 38h			;8449	ff		.
	rst 38h			;844a	ff		.
	rst 38h			;844b	ff		.
	rst 38h			;844c	ff		.
	rst 38h			;844d	ff		.
	rst 38h			;844e	ff		.
	rst 38h			;844f	ff		.
	rst 38h			;8450	ff		.
	rst 38h			;8451	ff		.
	rst 38h			;8452	ff		.
	rst 38h			;8453	ff		.
	rst 38h			;8454	ff		.
	rst 38h			;8455	ff		.
	rst 38h			;8456	ff		.
	rst 38h			;8457	ff		.
	rst 38h			;8458	ff		.
	rst 38h			;8459	ff		.
	nop			;845a	00		.
	nop			;845b	00		.
	nop			;845c	00		.
	nop			;845d	00		.
	nop			;845e	00		.
	nop			;845f	00		.
	nop			;8460	00		.
	nop			;8461	00		.
	nop			;8462	00		.
	nop			;8463	00		.
	nop			;8464	00		.
	nop			;8465	00		.
	nop			;8466	00		.
	nop			;8467	00		.
	nop			;8468	00		.
	nop			;8469	00		.
	nop			;846a	00		.
	nop			;846b	00		.
	nop			;846c	00		.
	nop			;846d	00		.
	nop			;846e	00		.
	nop			;846f	00		.
	nop			;8470	00		.
	nop			;8471	00		.
	nop			;8472	00		.
	nop			;8473	00		.
	nop			;8474	00		.
	nop			;8475	00		.
	nop			;8476	00		.
	nop			;8477	00		.
	nop			;8478	00		.
	nop			;8479	00		.
	rst 38h			;847a	ff		.
	rst 38h			;847b	ff		.
	rst 38h			;847c	ff		.
	rst 38h			;847d	ff		.
	rst 38h			;847e	ff		.
	rst 38h			;847f	ff		.
	rst 38h			;8480	ff		.
	rst 38h			;8481	ff		.
	rst 38h			;8482	ff		.
	rst 38h			;8483	ff		.
	rst 38h			;8484	ff		.
	rst 38h			;8485	ff		.
	rst 38h			;8486	ff		.
	rst 38h			;8487	ff		.
	rst 38h			;8488	ff		.
	rst 38h			;8489	ff		.
	rst 38h			;848a	ff		.
	rst 38h			;848b	ff		.
	rst 38h			;848c	ff		.
	rst 38h			;848d	ff		.
	rst 38h			;848e	ff		.
	rst 38h			;848f	ff		.
	rst 38h			;8490	ff		.
	rst 38h			;8491	ff		.
	rst 38h			;8492	ff		.
	rst 38h			;8493	ff		.
	rst 38h			;8494	ff		.
	rst 38h			;8495	ff		.
	rst 38h			;8496	ff		.
	rst 38h			;8497	ff		.
	rst 38h			;8498	ff		.
	rst 38h			;8499	ff		.
	nop			;849a	00		.
	nop			;849b	00		.
	nop			;849c	00		.
	nop			;849d	00		.
	nop			;849e	00		.
	nop			;849f	00		.
	nop			;84a0	00		.
	nop			;84a1	00		.
	nop			;84a2	00		.
	nop			;84a3	00		.
	nop			;84a4	00		.
	nop			;84a5	00		.
	nop			;84a6	00		.
	nop			;84a7	00		.
	nop			;84a8	00		.
	nop			;84a9	00		.
	nop			;84aa	00		.
	nop			;84ab	00		.
	nop			;84ac	00		.
	nop			;84ad	00		.
	nop			;84ae	00		.
	nop			;84af	00		.
	nop			;84b0	00		.
	nop			;84b1	00		.
	nop			;84b2	00		.
	nop			;84b3	00		.
	nop			;84b4	00		.
	nop			;84b5	00		.
	nop			;84b6	00		.
	nop			;84b7	00		.
	nop			;84b8	00		.
	nop			;84b9	00		.
	rst 38h			;84ba	ff		.
	rst 38h			;84bb	ff		.
	ei			;84bc	fb		.
	rst 38h			;84bd	ff		.
	cp 0ffh			;84be	fe ff		. .
	ei			;84c0	fb		.
	rst 38h			;84c1	ff		.
	rst 38h			;84c2	ff		.
	rst 38h			;84c3	ff		.
	in a,(0ffh)		;84c4	db ff		. .
	rst 38h			;84c6	ff		.
	rst 38h			;84c7	ff		.
	ei			;84c8	fb		.
	rst 38h			;84c9	ff		.
	rst 38h			;84ca	ff		.
	rst 38h			;84cb	ff		.
	ei			;84cc	fb		.
	rst 38h			;84cd	ff		.
	rst 38h			;84ce	ff		.
	rst 38h			;84cf	ff		.
	ei			;84d0	fb		.
	rst 38h			;84d1	ff		.
	rst 38h			;84d2	ff		.
	ei			;84d3	fb		.
	ei			;84d4	fb		.
	rst 38h			;84d5	ff		.
	rst 38h			;84d6	ff		.
	ei			;84d7	fb		.
	ei			;84d8	fb		.
	rst 38h			;84d9	ff		.
	nop			;84da	00		.
	nop			;84db	00		.
	nop			;84dc	00		.
	nop			;84dd	00		.
	nop			;84de	00		.
	nop			;84df	00		.
	nop			;84e0	00		.
	nop			;84e1	00		.
	nop			;84e2	00		.
	nop			;84e3	00		.
	nop			;84e4	00		.
	nop			;84e5	00		.
	nop			;84e6	00		.
	nop			;84e7	00		.
	nop			;84e8	00		.
	nop			;84e9	00		.
	nop			;84ea	00		.
	nop			;84eb	00		.
	nop			;84ec	00		.
	nop			;84ed	00		.
	nop			;84ee	00		.
	nop			;84ef	00		.
	nop			;84f0	00		.
	nop			;84f1	00		.
	nop			;84f2	00		.
	nop			;84f3	00		.
	nop			;84f4	00		.
	nop			;84f5	00		.
	nop			;84f6	00		.
	nop			;84f7	00		.
	nop			;84f8	00		.
	nop			;84f9	00		.
	rst 38h			;84fa	ff		.
	rst 38h			;84fb	ff		.
	rst 38h			;84fc	ff		.
	rst 38h			;84fd	ff		.
	rst 38h			;84fe	ff		.
	rst 38h			;84ff	ff		.
	rst 38h			;8500	ff		.
	rst 38h			;8501	ff		.
	rst 38h			;8502	ff		.
	rst 38h			;8503	ff		.
	rst 38h			;8504	ff		.
	rst 38h			;8505	ff		.
	rst 38h			;8506	ff		.
	rst 38h			;8507	ff		.
	rst 38h			;8508	ff		.
	rst 38h			;8509	ff		.
	rst 38h			;850a	ff		.
	rst 38h			;850b	ff		.
	rst 38h			;850c	ff		.
	rst 38h			;850d	ff		.
	rst 38h			;850e	ff		.
	rst 38h			;850f	ff		.
	rst 38h			;8510	ff		.
	rst 38h			;8511	ff		.
	rst 38h			;8512	ff		.
	rst 38h			;8513	ff		.
	rst 38h			;8514	ff		.
	rst 38h			;8515	ff		.
	rst 38h			;8516	ff		.
	rst 38h			;8517	ff		.
	rst 38h			;8518	ff		.
	rst 38h			;8519	ff		.
	nop			;851a	00		.
	nop			;851b	00		.
	nop			;851c	00		.
	nop			;851d	00		.
	nop			;851e	00		.
	nop			;851f	00		.
	nop			;8520	00		.
	nop			;8521	00		.
	nop			;8522	00		.
	nop			;8523	00		.
	nop			;8524	00		.
	nop			;8525	00		.
	nop			;8526	00		.
	nop			;8527	00		.
	nop			;8528	00		.
	nop			;8529	00		.
	nop			;852a	00		.
	nop			;852b	00		.
	nop			;852c	00		.
	nop			;852d	00		.
	nop			;852e	00		.
	nop			;852f	00		.
	nop			;8530	00		.
	nop			;8531	00		.
	nop			;8532	00		.
	nop			;8533	00		.
	nop			;8534	00		.
	nop			;8535	00		.
	nop			;8536	00		.
	nop			;8537	00		.
	nop			;8538	00		.
	nop			;8539	00		.
	rst 38h			;853a	ff		.
	rst 38h			;853b	ff		.
	rst 38h			;853c	ff		.
	rst 38h			;853d	ff		.
	rst 38h			;853e	ff		.
	rst 38h			;853f	ff		.
	rst 38h			;8540	ff		.
	rst 38h			;8541	ff		.
	rst 38h			;8542	ff		.
	rst 38h			;8543	ff		.
	rst 38h			;8544	ff		.
	rst 38h			;8545	ff		.
	rst 38h			;8546	ff		.
	rst 38h			;8547	ff		.
	rst 38h			;8548	ff		.
	rst 38h			;8549	ff		.
	rst 38h			;854a	ff		.
	rst 38h			;854b	ff		.
	rst 38h			;854c	ff		.
	rst 38h			;854d	ff		.
	rst 38h			;854e	ff		.
	rst 38h			;854f	ff		.
	rst 38h			;8550	ff		.
	rst 38h			;8551	ff		.
	rst 38h			;8552	ff		.
	rst 38h			;8553	ff		.
	rst 38h			;8554	ff		.
	rst 38h			;8555	ff		.
	rst 38h			;8556	ff		.
	rst 38h			;8557	ff		.
	rst 38h			;8558	ff		.
	rst 38h			;8559	ff		.
	nop			;855a	00		.
	nop			;855b	00		.
	nop			;855c	00		.
	nop			;855d	00		.
	nop			;855e	00		.
	nop			;855f	00		.
	nop			;8560	00		.
	nop			;8561	00		.
	nop			;8562	00		.
	nop			;8563	00		.
	nop			;8564	00		.
	nop			;8565	00		.
	nop			;8566	00		.
	nop			;8567	00		.
	nop			;8568	00		.
	nop			;8569	00		.
	nop			;856a	00		.
	nop			;856b	00		.
	nop			;856c	00		.
	nop			;856d	00		.
	nop			;856e	00		.
	nop			;856f	00		.
	nop			;8570	00		.
	nop			;8571	00		.
	nop			;8572	00		.
	nop			;8573	00		.
	nop			;8574	00		.
	nop			;8575	00		.
	nop			;8576	00		.
	nop			;8577	00		.
	nop			;8578	00		.
	nop			;8579	00		.
	rst 38h			;857a	ff		.
	rst 38h			;857b	ff		.
	rst 38h			;857c	ff		.
	rst 38h			;857d	ff		.
	rst 38h			;857e	ff		.
	rst 38h			;857f	ff		.
	rst 38h			;8580	ff		.
	rst 38h			;8581	ff		.
	rst 38h			;8582	ff		.
	rst 38h			;8583	ff		.
	rst 38h			;8584	ff		.
	rst 38h			;8585	ff		.
	rst 38h			;8586	ff		.
	rst 38h			;8587	ff		.
	rst 38h			;8588	ff		.
	rst 38h			;8589	ff		.
	rst 38h			;858a	ff		.
	rst 38h			;858b	ff		.
	rst 38h			;858c	ff		.
	rst 38h			;858d	ff		.
	rst 38h			;858e	ff		.
	rst 38h			;858f	ff		.
	rst 38h			;8590	ff		.
	rst 38h			;8591	ff		.
	rst 38h			;8592	ff		.
	rst 38h			;8593	ff		.
	rst 38h			;8594	ff		.
	rst 38h			;8595	ff		.
	rst 38h			;8596	ff		.
	rst 38h			;8597	ff		.
	rst 38h			;8598	ff		.
	rst 38h			;8599	ff		.
	nop			;859a	00		.
	nop			;859b	00		.
	nop			;859c	00		.
	nop			;859d	00		.
	nop			;859e	00		.
	nop			;859f	00		.
	nop			;85a0	00		.
	nop			;85a1	00		.
	nop			;85a2	00		.
	nop			;85a3	00		.
	nop			;85a4	00		.
	nop			;85a5	00		.
	nop			;85a6	00		.
	nop			;85a7	00		.
	nop			;85a8	00		.
	nop			;85a9	00		.
	nop			;85aa	00		.
	nop			;85ab	00		.
	nop			;85ac	00		.
	nop			;85ad	00		.
	nop			;85ae	00		.
	nop			;85af	00		.
	nop			;85b0	00		.
	nop			;85b1	00		.
	nop			;85b2	00		.
	nop			;85b3	00		.
	nop			;85b4	00		.
	nop			;85b5	00		.
	nop			;85b6	00		.
	nop			;85b7	00		.
	nop			;85b8	00		.
	nop			;85b9	00		.
	cp 0ffh			;85ba	fe ff		. .
	rst 38h			;85bc	ff		.
	rst 38h			;85bd	ff		.
	cp 0ffh			;85be	fe ff		. .
	jp m,0feffh		;85c0	fa ff fe	. . .
	rst 38h			;85c3	ff		.
	jp c,0ffffh		;85c4	da ff ff	. . .
	rst 38h			;85c7	ff		.
	rst 38h			;85c8	ff		.
	rst 38h			;85c9	ff		.
	rst 38h			;85ca	ff		.
	rst 38h			;85cb	ff		.
	rst 38h			;85cc	ff		.
	rst 38h			;85cd	ff		.
	rst 38h			;85ce	ff		.
	rst 38h			;85cf	ff		.
	ei			;85d0	fb		.
	rst 38h			;85d1	ff		.
	rst 38h			;85d2	ff		.
	rst 38h			;85d3	ff		.
	ei			;85d4	fb		.
	rst 38h			;85d5	ff		.
	rst 38h			;85d6	ff		.
	rst 38h			;85d7	ff		.
	ei			;85d8	fb		.
	ei			;85d9	fb		.
	nop			;85da	00		.
	nop			;85db	00		.
	nop			;85dc	00		.
	nop			;85dd	00		.
	nop			;85de	00		.
	nop			;85df	00		.
	nop			;85e0	00		.
	nop			;85e1	00		.
	nop			;85e2	00		.
	nop			;85e3	00		.
	nop			;85e4	00		.
	nop			;85e5	00		.
	nop			;85e6	00		.
	nop			;85e7	00		.
	nop			;85e8	00		.
	nop			;85e9	00		.
	nop			;85ea	00		.
	nop			;85eb	00		.
	nop			;85ec	00		.
	nop			;85ed	00		.
	nop			;85ee	00		.
	nop			;85ef	00		.
	nop			;85f0	00		.
	nop			;85f1	00		.
	nop			;85f2	00		.
	nop			;85f3	00		.
	nop			;85f4	00		.
	nop			;85f5	00		.
	nop			;85f6	00		.
	nop			;85f7	00		.
	nop			;85f8	00		.
	nop			;85f9	00		.
	rst 38h			;85fa	ff		.
	rst 38h			;85fb	ff		.
	rst 38h			;85fc	ff		.
	rst 38h			;85fd	ff		.
	rst 38h			;85fe	ff		.
	rst 38h			;85ff	ff		.
	rst 38h			;8600	ff		.
	rst 38h			;8601	ff		.
	rst 38h			;8602	ff		.
	rst 38h			;8603	ff		.
	rst 38h			;8604	ff		.
	rst 38h			;8605	ff		.
	rst 38h			;8606	ff		.
	rst 38h			;8607	ff		.
	rst 38h			;8608	ff		.
	rst 38h			;8609	ff		.
	rst 38h			;860a	ff		.
	rst 38h			;860b	ff		.
	rst 38h			;860c	ff		.
	rst 38h			;860d	ff		.
	rst 38h			;860e	ff		.
	rst 38h			;860f	ff		.
	rst 38h			;8610	ff		.
	rst 38h			;8611	ff		.
	rst 38h			;8612	ff		.
	rst 38h			;8613	ff		.
	rst 38h			;8614	ff		.
	rst 38h			;8615	ff		.
	rst 38h			;8616	ff		.
	rst 38h			;8617	ff		.
	rst 38h			;8618	ff		.
	rst 38h			;8619	ff		.
	nop			;861a	00		.
	nop			;861b	00		.
	nop			;861c	00		.
	nop			;861d	00		.
	nop			;861e	00		.
	nop			;861f	00		.
	nop			;8620	00		.
	nop			;8621	00		.
	nop			;8622	00		.
	nop			;8623	00		.
	nop			;8624	00		.
	nop			;8625	00		.
	nop			;8626	00		.
	nop			;8627	00		.
	nop			;8628	00		.
	nop			;8629	00		.
	nop			;862a	00		.
	nop			;862b	00		.
	nop			;862c	00		.
	nop			;862d	00		.
	nop			;862e	00		.
	nop			;862f	00		.
	nop			;8630	00		.
	nop			;8631	00		.
	nop			;8632	00		.
	nop			;8633	00		.
	nop			;8634	00		.
	nop			;8635	00		.
	nop			;8636	00		.
	nop			;8637	00		.
	nop			;8638	00		.
	nop			;8639	00		.
	rst 38h			;863a	ff		.
	rst 38h			;863b	ff		.
	rst 38h			;863c	ff		.
	rst 38h			;863d	ff		.
	rst 38h			;863e	ff		.
	rst 38h			;863f	ff		.
	rst 38h			;8640	ff		.
	rst 38h			;8641	ff		.
	rst 38h			;8642	ff		.
	rst 38h			;8643	ff		.
	rst 38h			;8644	ff		.
	rst 38h			;8645	ff		.
	rst 38h			;8646	ff		.
	rst 38h			;8647	ff		.
	rst 38h			;8648	ff		.
	rst 38h			;8649	ff		.
	rst 38h			;864a	ff		.
	rst 38h			;864b	ff		.
	rst 38h			;864c	ff		.
	rst 38h			;864d	ff		.
	rst 38h			;864e	ff		.
	rst 38h			;864f	ff		.
	rst 38h			;8650	ff		.
	rst 38h			;8651	ff		.
	rst 38h			;8652	ff		.
	rst 38h			;8653	ff		.
	rst 38h			;8654	ff		.
	rst 38h			;8655	ff		.
	rst 38h			;8656	ff		.
	rst 38h			;8657	ff		.
	rst 38h			;8658	ff		.
	rst 38h			;8659	ff		.
	nop			;865a	00		.
	nop			;865b	00		.
	nop			;865c	00		.
	nop			;865d	00		.
	nop			;865e	00		.
	nop			;865f	00		.
	nop			;8660	00		.
	nop			;8661	00		.
	nop			;8662	00		.
	nop			;8663	00		.
	nop			;8664	00		.
	nop			;8665	00		.
	nop			;8666	00		.
	nop			;8667	00		.
	nop			;8668	00		.
	nop			;8669	00		.
	nop			;866a	00		.
	nop			;866b	00		.
	nop			;866c	00		.
	nop			;866d	00		.
	nop			;866e	00		.
	nop			;866f	00		.
	nop			;8670	00		.
	nop			;8671	00		.
	nop			;8672	00		.
	nop			;8673	00		.
	nop			;8674	00		.
	nop			;8675	00		.
	nop			;8676	00		.
	nop			;8677	00		.
	nop			;8678	00		.
	nop			;8679	00		.
	rst 38h			;867a	ff		.
	rst 38h			;867b	ff		.
	rst 38h			;867c	ff		.
	rst 38h			;867d	ff		.
	rst 38h			;867e	ff		.
	rst 38h			;867f	ff		.
	rst 38h			;8680	ff		.
	rst 38h			;8681	ff		.
	rst 38h			;8682	ff		.
	rst 38h			;8683	ff		.
	rst 38h			;8684	ff		.
	rst 38h			;8685	ff		.
	rst 38h			;8686	ff		.
	rst 38h			;8687	ff		.
	rst 38h			;8688	ff		.
	rst 38h			;8689	ff		.
	rst 38h			;868a	ff		.
	rst 38h			;868b	ff		.
	rst 38h			;868c	ff		.
	rst 38h			;868d	ff		.
	rst 38h			;868e	ff		.
	rst 38h			;868f	ff		.
	rst 38h			;8690	ff		.
	rst 38h			;8691	ff		.
	rst 38h			;8692	ff		.
	rst 38h			;8693	ff		.
	rst 38h			;8694	ff		.
	rst 38h			;8695	ff		.
	rst 38h			;8696	ff		.
	rst 38h			;8697	ff		.
	rst 38h			;8698	ff		.
	rst 38h			;8699	ff		.
	nop			;869a	00		.
	nop			;869b	00		.
	ld bc,00000h		;869c	01 00 00	. . .
	nop			;869f	00		.
	nop			;86a0	00		.
	nop			;86a1	00		.
	nop			;86a2	00		.
	nop			;86a3	00		.
	nop			;86a4	00		.
	nop			;86a5	00		.
	nop			;86a6	00		.
	nop			;86a7	00		.
	nop			;86a8	00		.
	nop			;86a9	00		.
	nop			;86aa	00		.
	nop			;86ab	00		.
	nop			;86ac	00		.
	nop			;86ad	00		.
	nop			;86ae	00		.
	nop			;86af	00		.
	nop			;86b0	00		.
	nop			;86b1	00		.
	nop			;86b2	00		.
	nop			;86b3	00		.
	nop			;86b4	00		.
	nop			;86b5	00		.
	nop			;86b6	00		.
	ld bc,00001h		;86b7	01 01 00	. . .
	rst 38h			;86ba	ff		.
	rst 38h			;86bb	ff		.
	rst 38h			;86bc	ff		.
	rst 38h			;86bd	ff		.
	rst 38h			;86be	ff		.
	rst 38h			;86bf	ff		.
	rst 38h			;86c0	ff		.
	rst 38h			;86c1	ff		.
	rst 38h			;86c2	ff		.
	rst 38h			;86c3	ff		.
	rst 18h			;86c4	df		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;86c5	fd ff ff	. . .
	rst 38h			;86c8	ff		.
	rst 38h			;86c9	ff		.
	rst 38h			;86ca	ff		.
	rst 38h			;86cb	ff		.
	rst 38h			;86cc	ff		.
	rst 38h			;86cd	ff		.
	rst 38h			;86ce	ff		.
	rst 38h			;86cf	ff		.
	rst 38h			;86d0	ff		.
	rst 38h			;86d1	ff		.
	rst 38h			;86d2	ff		.
	rst 38h			;86d3	ff		.
	rst 38h			;86d4	ff		.
	rst 38h			;86d5	ff		.
	rst 38h			;86d6	ff		.
	rst 38h			;86d7	ff		.
	rst 38h			;86d8	ff		.
	ei			;86d9	fb		.
	nop			;86da	00		.
	nop			;86db	00		.
	nop			;86dc	00		.
	nop			;86dd	00		.
	nop			;86de	00		.
	nop			;86df	00		.
	nop			;86e0	00		.
	nop			;86e1	00		.
	nop			;86e2	00		.
	nop			;86e3	00		.
	nop			;86e4	00		.
	nop			;86e5	00		.
	nop			;86e6	00		.
	nop			;86e7	00		.
	nop			;86e8	00		.
	nop			;86e9	00		.
	nop			;86ea	00		.
	nop			;86eb	00		.
	nop			;86ec	00		.
	nop			;86ed	00		.
	nop			;86ee	00		.
	nop			;86ef	00		.
	nop			;86f0	00		.
	nop			;86f1	00		.
	nop			;86f2	00		.
	nop			;86f3	00		.
	nop			;86f4	00		.
	nop			;86f5	00		.
	nop			;86f6	00		.
	nop			;86f7	00		.
	nop			;86f8	00		.
	nop			;86f9	00		.
	rst 38h			;86fa	ff		.
	rst 38h			;86fb	ff		.
	rst 38h			;86fc	ff		.
	rst 38h			;86fd	ff		.
	rst 38h			;86fe	ff		.
	rst 38h			;86ff	ff		.
	rst 38h			;8700	ff		.
	rst 38h			;8701	ff		.
	rst 38h			;8702	ff		.
	rst 38h			;8703	ff		.
	rst 38h			;8704	ff		.
	rst 38h			;8705	ff		.
	rst 38h			;8706	ff		.
	rst 38h			;8707	ff		.
	rst 38h			;8708	ff		.
	rst 38h			;8709	ff		.
	rst 38h			;870a	ff		.
	rst 38h			;870b	ff		.
	rst 38h			;870c	ff		.
	rst 38h			;870d	ff		.
	rst 38h			;870e	ff		.
	rst 38h			;870f	ff		.
	rst 38h			;8710	ff		.
	rst 38h			;8711	ff		.
	rst 38h			;8712	ff		.
	rst 38h			;8713	ff		.
	rst 38h			;8714	ff		.
	rst 38h			;8715	ff		.
	rst 38h			;8716	ff		.
	rst 38h			;8717	ff		.
	rst 38h			;8718	ff		.
	rst 38h			;8719	ff		.
	nop			;871a	00		.
	nop			;871b	00		.
	nop			;871c	00		.
	nop			;871d	00		.
	nop			;871e	00		.
	nop			;871f	00		.
	nop			;8720	00		.
	nop			;8721	00		.
	nop			;8722	00		.
	nop			;8723	00		.
	nop			;8724	00		.
	nop			;8725	00		.
	nop			;8726	00		.
	nop			;8727	00		.
	nop			;8728	00		.
	nop			;8729	00		.
	nop			;872a	00		.
	nop			;872b	00		.
	nop			;872c	00		.
	nop			;872d	00		.
	nop			;872e	00		.
	nop			;872f	00		.
	nop			;8730	00		.
	nop			;8731	00		.
	nop			;8732	00		.
	nop			;8733	00		.
	nop			;8734	00		.
	nop			;8735	00		.
	nop			;8736	00		.
	nop			;8737	00		.
	nop			;8738	00		.
	nop			;8739	00		.
	rst 38h			;873a	ff		.
	rst 38h			;873b	ff		.
	rst 38h			;873c	ff		.
	rst 38h			;873d	ff		.
	rst 38h			;873e	ff		.
	rst 38h			;873f	ff		.
	rst 38h			;8740	ff		.
	rst 38h			;8741	ff		.
	rst 38h			;8742	ff		.
	rst 38h			;8743	ff		.
	rst 38h			;8744	ff		.
	rst 38h			;8745	ff		.
	rst 38h			;8746	ff		.
	rst 38h			;8747	ff		.
	rst 38h			;8748	ff		.
	rst 38h			;8749	ff		.
	rst 38h			;874a	ff		.
	rst 38h			;874b	ff		.
	rst 38h			;874c	ff		.
	rst 38h			;874d	ff		.
	rst 38h			;874e	ff		.
	rst 38h			;874f	ff		.
	rst 38h			;8750	ff		.
	rst 38h			;8751	ff		.
	rst 38h			;8752	ff		.
	rst 38h			;8753	ff		.
	rst 38h			;8754	ff		.
	rst 38h			;8755	ff		.
	rst 38h			;8756	ff		.
	rst 38h			;8757	ff		.
	rst 38h			;8758	ff		.
	rst 38h			;8759	ff		.
	nop			;875a	00		.
	nop			;875b	00		.
	nop			;875c	00		.
	nop			;875d	00		.
	nop			;875e	00		.
	nop			;875f	00		.
	nop			;8760	00		.
	nop			;8761	00		.
	nop			;8762	00		.
	nop			;8763	00		.
	nop			;8764	00		.
	nop			;8765	00		.
	nop			;8766	00		.
	nop			;8767	00		.
	nop			;8768	00		.
	nop			;8769	00		.
	nop			;876a	00		.
	nop			;876b	00		.
	nop			;876c	00		.
	nop			;876d	00		.
	nop			;876e	00		.
	nop			;876f	00		.
	nop			;8770	00		.
	nop			;8771	00		.
	nop			;8772	00		.
	nop			;8773	00		.
	nop			;8774	00		.
	nop			;8775	00		.
	nop			;8776	00		.
	nop			;8777	00		.
	nop			;8778	00		.
	nop			;8779	00		.
	rst 38h			;877a	ff		.
	rst 38h			;877b	ff		.
	rst 38h			;877c	ff		.
	rst 38h			;877d	ff		.
	rst 38h			;877e	ff		.
	rst 38h			;877f	ff		.
	rst 38h			;8780	ff		.
	rst 38h			;8781	ff		.
	rst 38h			;8782	ff		.
	rst 38h			;8783	ff		.
	rst 38h			;8784	ff		.
	rst 38h			;8785	ff		.
	rst 38h			;8786	ff		.
	rst 38h			;8787	ff		.
	rst 38h			;8788	ff		.
	rst 38h			;8789	ff		.
	rst 38h			;878a	ff		.
	rst 38h			;878b	ff		.
	rst 38h			;878c	ff		.
	rst 38h			;878d	ff		.
	rst 38h			;878e	ff		.
	rst 38h			;878f	ff		.
	rst 38h			;8790	ff		.
	rst 38h			;8791	ff		.
	rst 38h			;8792	ff		.
	rst 38h			;8793	ff		.
	rst 38h			;8794	ff		.
	rst 38h			;8795	ff		.
	rst 38h			;8796	ff		.
	rst 38h			;8797	ff		.
	rst 38h			;8798	ff		.
	rst 38h			;8799	ff		.
	nop			;879a	00		.
	nop			;879b	00		.
	nop			;879c	00		.
	nop			;879d	00		.
	nop			;879e	00		.
	nop			;879f	00		.
	nop			;87a0	00		.
	nop			;87a1	00		.
	nop			;87a2	00		.
	nop			;87a3	00		.
	nop			;87a4	00		.
	nop			;87a5	00		.
	nop			;87a6	00		.
	nop			;87a7	00		.
	nop			;87a8	00		.
	nop			;87a9	00		.
	nop			;87aa	00		.
	nop			;87ab	00		.
	nop			;87ac	00		.
	nop			;87ad	00		.
	nop			;87ae	00		.
	nop			;87af	00		.
	nop			;87b0	00		.
	nop			;87b1	00		.
	nop			;87b2	00		.
	nop			;87b3	00		.
	nop			;87b4	00		.
	nop			;87b5	00		.
	nop			;87b6	00		.
	nop			;87b7	00		.
	nop			;87b8	00		.
	nop			;87b9	00		.
	cp 0ffh			;87ba	fe ff		. .
	rst 38h			;87bc	ff		.
	rst 38h			;87bd	ff		.
	cp 0ffh			;87be	fe ff		. .
	rst 38h			;87c0	ff		.
	cp 0feh			;87c1	fe fe		. .
	rst 38h			;87c3	ff		.
	rst 38h			;87c4	ff		.
	rst 38h			;87c5	ff		.
	rst 38h			;87c6	ff		.
	rst 38h			;87c7	ff		.
	rst 38h			;87c8	ff		.
	rst 38h			;87c9	ff		.
	rst 38h			;87ca	ff		.
	rst 38h			;87cb	ff		.
	rst 38h			;87cc	ff		.
	rst 38h			;87cd	ff		.
	rst 38h			;87ce	ff		.
	rst 38h			;87cf	ff		.
	rst 38h			;87d0	ff		.
	rst 38h			;87d1	ff		.
	rst 38h			;87d2	ff		.
	rst 38h			;87d3	ff		.
	ei			;87d4	fb		.
	rst 38h			;87d5	ff		.
	rst 38h			;87d6	ff		.
	rst 38h			;87d7	ff		.
	rst 38h			;87d8	ff		.
	ei			;87d9	fb		.
	nop			;87da	00		.
	nop			;87db	00		.
	nop			;87dc	00		.
	nop			;87dd	00		.
	nop			;87de	00		.
	nop			;87df	00		.
	nop			;87e0	00		.
	nop			;87e1	00		.
	nop			;87e2	00		.
	nop			;87e3	00		.
	nop			;87e4	00		.
	nop			;87e5	00		.
	nop			;87e6	00		.
	nop			;87e7	00		.
	nop			;87e8	00		.
	nop			;87e9	00		.
	nop			;87ea	00		.
	nop			;87eb	00		.
	nop			;87ec	00		.
	nop			;87ed	00		.
	nop			;87ee	00		.
	nop			;87ef	00		.
	nop			;87f0	00		.
	nop			;87f1	00		.
	nop			;87f2	00		.
	nop			;87f3	00		.
	nop			;87f4	00		.
	nop			;87f5	00		.
	nop			;87f6	00		.
	nop			;87f7	00		.
	nop			;87f8	00		.
	nop			;87f9	00		.
	rst 38h			;87fa	ff		.
	rst 38h			;87fb	ff		.
	rst 38h			;87fc	ff		.
	rst 38h			;87fd	ff		.
	rst 38h			;87fe	ff		.
	rst 38h			;87ff	ff		.
	rst 38h			;8800	ff		.
	rst 38h			;8801	ff		.
	rst 38h			;8802	ff		.
	rst 38h			;8803	ff		.
	rst 38h			;8804	ff		.
	rst 38h			;8805	ff		.
	rst 38h			;8806	ff		.
	rst 38h			;8807	ff		.
	rst 38h			;8808	ff		.
	rst 38h			;8809	ff		.
	rst 38h			;880a	ff		.
	rst 38h			;880b	ff		.
	rst 38h			;880c	ff		.
	rst 38h			;880d	ff		.
	rst 38h			;880e	ff		.
	rst 38h			;880f	ff		.
	rst 38h			;8810	ff		.
	rst 38h			;8811	ff		.
	rst 38h			;8812	ff		.
	rst 38h			;8813	ff		.
	rst 38h			;8814	ff		.
	rst 38h			;8815	ff		.
	rst 38h			;8816	ff		.
	rst 38h			;8817	ff		.
	rst 38h			;8818	ff		.
	rst 38h			;8819	ff		.
	nop			;881a	00		.
	nop			;881b	00		.
	nop			;881c	00		.
	nop			;881d	00		.
	nop			;881e	00		.
	nop			;881f	00		.
	nop			;8820	00		.
	nop			;8821	00		.
	nop			;8822	00		.
	nop			;8823	00		.
	nop			;8824	00		.
	nop			;8825	00		.
	nop			;8826	00		.
	nop			;8827	00		.
	nop			;8828	00		.
	nop			;8829	00		.
	nop			;882a	00		.
	nop			;882b	00		.
	nop			;882c	00		.
	nop			;882d	00		.
	nop			;882e	00		.
	ld b,b			;882f	40		@
	nop			;8830	00		.
	nop			;8831	00		.
	nop			;8832	00		.
	nop			;8833	00		.
	nop			;8834	00		.
	nop			;8835	00		.
	ld bc,00000h		;8836	01 00 00	. . .
	nop			;8839	00		.
	rst 38h			;883a	ff		.
	rst 38h			;883b	ff		.
	rst 38h			;883c	ff		.
	rst 38h			;883d	ff		.
	rst 38h			;883e	ff		.
	rst 38h			;883f	ff		.
	rst 38h			;8840	ff		.
	rst 38h			;8841	ff		.
	rst 38h			;8842	ff		.
	rst 38h			;8843	ff		.
	rst 38h			;8844	ff		.
	rst 38h			;8845	ff		.
	rst 38h			;8846	ff		.
	rst 38h			;8847	ff		.
	rst 38h			;8848	ff		.
	rst 38h			;8849	ff		.
	rst 38h			;884a	ff		.
	rst 38h			;884b	ff		.
	rst 38h			;884c	ff		.
	rst 38h			;884d	ff		.
	rst 38h			;884e	ff		.
	rst 38h			;884f	ff		.
	rst 38h			;8850	ff		.
	rst 38h			;8851	ff		.
	rst 38h			;8852	ff		.
	rst 38h			;8853	ff		.
	rst 38h			;8854	ff		.
	rst 38h			;8855	ff		.
	rst 38h			;8856	ff		.
	rst 38h			;8857	ff		.
	rst 38h			;8858	ff		.
	rst 38h			;8859	ff		.
	nop			;885a	00		.
	nop			;885b	00		.
	nop			;885c	00		.
	nop			;885d	00		.
	nop			;885e	00		.
	nop			;885f	00		.
	nop			;8860	00		.
	nop			;8861	00		.
	nop			;8862	00		.
	nop			;8863	00		.
	nop			;8864	00		.
	nop			;8865	00		.
	nop			;8866	00		.
	nop			;8867	00		.
	nop			;8868	00		.
	nop			;8869	00		.
	nop			;886a	00		.
	nop			;886b	00		.
	nop			;886c	00		.
	nop			;886d	00		.
	nop			;886e	00		.
	nop			;886f	00		.
	nop			;8870	00		.
	nop			;8871	00		.
	nop			;8872	00		.
	nop			;8873	00		.
	nop			;8874	00		.
	nop			;8875	00		.
	nop			;8876	00		.
	nop			;8877	00		.
	nop			;8878	00		.
	nop			;8879	00		.
	rst 38h			;887a	ff		.
	rst 38h			;887b	ff		.
	rst 38h			;887c	ff		.
	rst 38h			;887d	ff		.
	rst 38h			;887e	ff		.
	rst 38h			;887f	ff		.
	rst 38h			;8880	ff		.
	rst 38h			;8881	ff		.
	rst 38h			;8882	ff		.
	rst 38h			;8883	ff		.
	rst 38h			;8884	ff		.
	rst 38h			;8885	ff		.
	rst 38h			;8886	ff		.
	rst 38h			;8887	ff		.
	rst 38h			;8888	ff		.
	rst 38h			;8889	ff		.
	rst 38h			;888a	ff		.
	rst 38h			;888b	ff		.
	rst 38h			;888c	ff		.
	rst 38h			;888d	ff		.
	rst 38h			;888e	ff		.
	rst 38h			;888f	ff		.
	rst 38h			;8890	ff		.
	rst 38h			;8891	ff		.
	rst 38h			;8892	ff		.
	rst 38h			;8893	ff		.
	rst 38h			;8894	ff		.
	rst 38h			;8895	ff		.
	rst 38h			;8896	ff		.
	rst 38h			;8897	ff		.
	rst 38h			;8898	ff		.
	rst 38h			;8899	ff		.
	nop			;889a	00		.
	nop			;889b	00		.
	nop			;889c	00		.
	nop			;889d	00		.
	nop			;889e	00		.
	nop			;889f	00		.
	nop			;88a0	00		.
	nop			;88a1	00		.
	nop			;88a2	00		.
	nop			;88a3	00		.
	nop			;88a4	00		.
	nop			;88a5	00		.
	nop			;88a6	00		.
	nop			;88a7	00		.
	nop			;88a8	00		.
	nop			;88a9	00		.
	nop			;88aa	00		.
	nop			;88ab	00		.
	nop			;88ac	00		.
	nop			;88ad	00		.
	nop			;88ae	00		.
	nop			;88af	00		.
	nop			;88b0	00		.
	nop			;88b1	00		.
	nop			;88b2	00		.
	nop			;88b3	00		.
	nop			;88b4	00		.
	nop			;88b5	00		.
	nop			;88b6	00		.
	nop			;88b7	00		.
	nop			;88b8	00		.
	nop			;88b9	00		.
	cp 0ffh			;88ba	fe ff		. .
	rst 38h			;88bc	ff		.
	rst 38h			;88bd	ff		.
	cp 0ffh			;88be	fe ff		. .
	rst 38h			;88c0	ff		.
	rst 38h			;88c1	ff		.
	cp 0ffh			;88c2	fe ff		. .
	rst 18h			;88c4	df		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;88c5	fd ff ff	. . .
	rst 38h			;88c8	ff		.
	rst 38h			;88c9	ff		.
	rst 38h			;88ca	ff		.
	rst 38h			;88cb	ff		.
	rst 38h			;88cc	ff		.
	rst 38h			;88cd	ff		.
	rst 38h			;88ce	ff		.
	rst 38h			;88cf	ff		.
	rst 38h			;88d0	ff		.
	rst 38h			;88d1	ff		.
	rst 38h			;88d2	ff		.
	rst 38h			;88d3	ff		.
	rst 38h			;88d4	ff		.
	rst 38h			;88d5	ff		.
	rst 38h			;88d6	ff		.
	rst 38h			;88d7	ff		.
	ei			;88d8	fb		.
	rst 38h			;88d9	ff		.
	nop			;88da	00		.
	nop			;88db	00		.
	nop			;88dc	00		.
	nop			;88dd	00		.
	nop			;88de	00		.
	nop			;88df	00		.
	nop			;88e0	00		.
	nop			;88e1	00		.
	nop			;88e2	00		.
	nop			;88e3	00		.
	nop			;88e4	00		.
	nop			;88e5	00		.
	nop			;88e6	00		.
	nop			;88e7	00		.
	nop			;88e8	00		.
	nop			;88e9	00		.
	nop			;88ea	00		.
	nop			;88eb	00		.
	nop			;88ec	00		.
	nop			;88ed	00		.
	nop			;88ee	00		.
	nop			;88ef	00		.
	nop			;88f0	00		.
	nop			;88f1	00		.
	nop			;88f2	00		.
	nop			;88f3	00		.
	nop			;88f4	00		.
	nop			;88f5	00		.
	nop			;88f6	00		.
	nop			;88f7	00		.
	nop			;88f8	00		.
	nop			;88f9	00		.
	rst 38h			;88fa	ff		.
	rst 38h			;88fb	ff		.
	rst 38h			;88fc	ff		.
	rst 38h			;88fd	ff		.
	rst 38h			;88fe	ff		.
	rst 38h			;88ff	ff		.
	rst 38h			;8900	ff		.
	rst 38h			;8901	ff		.
	rst 38h			;8902	ff		.
	rst 38h			;8903	ff		.
	rst 38h			;8904	ff		.
	rst 38h			;8905	ff		.
	rst 38h			;8906	ff		.
	rst 38h			;8907	ff		.
	rst 38h			;8908	ff		.
	rst 38h			;8909	ff		.
	rst 38h			;890a	ff		.
	rst 38h			;890b	ff		.
	rst 38h			;890c	ff		.
	rst 38h			;890d	ff		.
	rst 38h			;890e	ff		.
	rst 38h			;890f	ff		.
	rst 38h			;8910	ff		.
	rst 38h			;8911	ff		.
	rst 38h			;8912	ff		.
	rst 38h			;8913	ff		.
	rst 38h			;8914	ff		.
	rst 38h			;8915	ff		.
	rst 38h			;8916	ff		.
	rst 38h			;8917	ff		.
	rst 38h			;8918	ff		.
	rst 38h			;8919	ff		.
	nop			;891a	00		.
	nop			;891b	00		.
	nop			;891c	00		.
	nop			;891d	00		.
	nop			;891e	00		.
	nop			;891f	00		.
	nop			;8920	00		.
	nop			;8921	00		.
	nop			;8922	00		.
	nop			;8923	00		.
	nop			;8924	00		.
	nop			;8925	00		.
	nop			;8926	00		.
	nop			;8927	00		.
	nop			;8928	00		.
	nop			;8929	00		.
	nop			;892a	00		.
	nop			;892b	00		.
	nop			;892c	00		.
	nop			;892d	00		.
	nop			;892e	00		.
	nop			;892f	00		.
	nop			;8930	00		.
	nop			;8931	00		.
	nop			;8932	00		.
	nop			;8933	00		.
	nop			;8934	00		.
	nop			;8935	00		.
	nop			;8936	00		.
	nop			;8937	00		.
	nop			;8938	00		.
	nop			;8939	00		.
	rst 38h			;893a	ff		.
	rst 38h			;893b	ff		.
	rst 38h			;893c	ff		.
	rst 38h			;893d	ff		.
	rst 38h			;893e	ff		.
	rst 38h			;893f	ff		.
	rst 38h			;8940	ff		.
	rst 38h			;8941	ff		.
	rst 38h			;8942	ff		.
	rst 38h			;8943	ff		.
	rst 38h			;8944	ff		.
	rst 38h			;8945	ff		.
	rst 38h			;8946	ff		.
	rst 38h			;8947	ff		.
	rst 38h			;8948	ff		.
	rst 38h			;8949	ff		.
	rst 38h			;894a	ff		.
	rst 38h			;894b	ff		.
	rst 38h			;894c	ff		.
	rst 38h			;894d	ff		.
	rst 38h			;894e	ff		.
	rst 38h			;894f	ff		.
	rst 38h			;8950	ff		.
	rst 38h			;8951	ff		.
	rst 38h			;8952	ff		.
	rst 38h			;8953	ff		.
	rst 38h			;8954	ff		.
	rst 38h			;8955	ff		.
	rst 38h			;8956	ff		.
	rst 38h			;8957	ff		.
	rst 38h			;8958	ff		.
	rst 38h			;8959	ff		.
	nop			;895a	00		.
	nop			;895b	00		.
	nop			;895c	00		.
	nop			;895d	00		.
	nop			;895e	00		.
	nop			;895f	00		.
	nop			;8960	00		.
	nop			;8961	00		.
	nop			;8962	00		.
	nop			;8963	00		.
	nop			;8964	00		.
	nop			;8965	00		.
	nop			;8966	00		.
	nop			;8967	00		.
	nop			;8968	00		.
	nop			;8969	00		.
	nop			;896a	00		.
	nop			;896b	00		.
	nop			;896c	00		.
	nop			;896d	00		.
	nop			;896e	00		.
	nop			;896f	00		.
	nop			;8970	00		.
	nop			;8971	00		.
	nop			;8972	00		.
	nop			;8973	00		.
	nop			;8974	00		.
	nop			;8975	00		.
	nop			;8976	00		.
	nop			;8977	00		.
	nop			;8978	00		.
	nop			;8979	00		.
	rst 38h			;897a	ff		.
	rst 38h			;897b	ff		.
	rst 38h			;897c	ff		.
	rst 38h			;897d	ff		.
	rst 38h			;897e	ff		.
	rst 38h			;897f	ff		.
	rst 38h			;8980	ff		.
	rst 38h			;8981	ff		.
	rst 38h			;8982	ff		.
	rst 38h			;8983	ff		.
	rst 38h			;8984	ff		.
	rst 38h			;8985	ff		.
	rst 38h			;8986	ff		.
	rst 38h			;8987	ff		.
	rst 38h			;8988	ff		.
	rst 38h			;8989	ff		.
	rst 38h			;898a	ff		.
	rst 38h			;898b	ff		.
	rst 38h			;898c	ff		.
	rst 38h			;898d	ff		.
	rst 38h			;898e	ff		.
	rst 38h			;898f	ff		.
	rst 38h			;8990	ff		.
	rst 38h			;8991	ff		.
	rst 38h			;8992	ff		.
	rst 38h			;8993	ff		.
	rst 38h			;8994	ff		.
	rst 38h			;8995	ff		.
	rst 38h			;8996	ff		.
	rst 38h			;8997	ff		.
	rst 38h			;8998	ff		.
	rst 38h			;8999	ff		.
	nop			;899a	00		.
	nop			;899b	00		.
	nop			;899c	00		.
	nop			;899d	00		.
	nop			;899e	00		.
	nop			;899f	00		.
	nop			;89a0	00		.
	nop			;89a1	00		.
	nop			;89a2	00		.
	nop			;89a3	00		.
	nop			;89a4	00		.
	nop			;89a5	00		.
	nop			;89a6	00		.
	nop			;89a7	00		.
	nop			;89a8	00		.
	nop			;89a9	00		.
	nop			;89aa	00		.
	nop			;89ab	00		.
	nop			;89ac	00		.
	nop			;89ad	00		.
	nop			;89ae	00		.
	nop			;89af	00		.
	nop			;89b0	00		.
	nop			;89b1	00		.
	nop			;89b2	00		.
	nop			;89b3	00		.
	nop			;89b4	00		.
	nop			;89b5	00		.
	nop			;89b6	00		.
	nop			;89b7	00		.
	nop			;89b8	00		.
	nop			;89b9	00		.
	cp 0ffh			;89ba	fe ff		. .
	rst 38h			;89bc	ff		.
	cp 0feh			;89bd	fe fe		. .
	rst 38h			;89bf	ff		.
	rst 38h			;89c0	ff		.
	cp 0feh			;89c1	fe fe		. .
	rst 38h			;89c3	ff		.
	rst 18h			;89c4	df		.
	rst 38h			;89c5	ff		.
	rst 38h			;89c6	ff		.
	rst 38h			;89c7	ff		.
	rst 38h			;89c8	ff		.
	rst 38h			;89c9	ff		.
	rst 38h			;89ca	ff		.
	rst 38h			;89cb	ff		.
	rst 38h			;89cc	ff		.
	rst 38h			;89cd	ff		.
	rst 38h			;89ce	ff		.
	rst 38h			;89cf	ff		.
	rst 38h			;89d0	ff		.
	rst 38h			;89d1	ff		.
	rst 38h			;89d2	ff		.
	rst 38h			;89d3	ff		.
	ei			;89d4	fb		.
	rst 38h			;89d5	ff		.
	rst 38h			;89d6	ff		.
	rst 38h			;89d7	ff		.
	ei			;89d8	fb		.
	rst 38h			;89d9	ff		.
	nop			;89da	00		.
	nop			;89db	00		.
	nop			;89dc	00		.
	nop			;89dd	00		.
	nop			;89de	00		.
	nop			;89df	00		.
	nop			;89e0	00		.
	nop			;89e1	00		.
	nop			;89e2	00		.
	nop			;89e3	00		.
	nop			;89e4	00		.
	nop			;89e5	00		.
	nop			;89e6	00		.
	nop			;89e7	00		.
	nop			;89e8	00		.
	nop			;89e9	00		.
	nop			;89ea	00		.
	nop			;89eb	00		.
	nop			;89ec	00		.
	nop			;89ed	00		.
	nop			;89ee	00		.
	nop			;89ef	00		.
	nop			;89f0	00		.
	nop			;89f1	00		.
	nop			;89f2	00		.
	nop			;89f3	00		.
	nop			;89f4	00		.
	nop			;89f5	00		.
	nop			;89f6	00		.
	nop			;89f7	00		.
	nop			;89f8	00		.
	nop			;89f9	00		.
	rst 38h			;89fa	ff		.
	rst 38h			;89fb	ff		.
	rst 38h			;89fc	ff		.
	rst 38h			;89fd	ff		.
	rst 38h			;89fe	ff		.
	rst 38h			;89ff	ff		.
	push hl			;8a00	e5		.
	push hl			;8a01	e5		.
	push hl			;8a02	e5		.
	push hl			;8a03	e5		.
	push hl			;8a04	e5		.
	push hl			;8a05	e5		.
	push hl			;8a06	e5		.
	push hl			;8a07	e5		.
	push hl			;8a08	e5		.
	push hl			;8a09	e5		.
	push hl			;8a0a	e5		.
	push hl			;8a0b	e5		.
	push hl			;8a0c	e5		.
	push hl			;8a0d	e5		.
	push hl			;8a0e	e5		.
	push hl			;8a0f	e5		.
	push hl			;8a10	e5		.
	push hl			;8a11	e5		.
	push hl			;8a12	e5		.
	push hl			;8a13	e5		.
	push hl			;8a14	e5		.
	push hl			;8a15	e5		.
	push hl			;8a16	e5		.
	push hl			;8a17	e5		.
	push hl			;8a18	e5		.
	push hl			;8a19	e5		.
	push hl			;8a1a	e5		.
	push hl			;8a1b	e5		.
	push hl			;8a1c	e5		.
	push hl			;8a1d	e5		.
	push hl			;8a1e	e5		.
	push hl			;8a1f	e5		.
	push hl			;8a20	e5		.
	push hl			;8a21	e5		.
	push hl			;8a22	e5		.
	push hl			;8a23	e5		.
	push hl			;8a24	e5		.
	push hl			;8a25	e5		.
	push hl			;8a26	e5		.
	push hl			;8a27	e5		.
	push hl			;8a28	e5		.
	push hl			;8a29	e5		.
	push hl			;8a2a	e5		.
	push hl			;8a2b	e5		.
	push hl			;8a2c	e5		.
	push hl			;8a2d	e5		.
	push hl			;8a2e	e5		.
	push hl			;8a2f	e5		.
	push hl			;8a30	e5		.
	push hl			;8a31	e5		.
	push hl			;8a32	e5		.
	push hl			;8a33	e5		.
	push hl			;8a34	e5		.
	push hl			;8a35	e5		.
	push hl			;8a36	e5		.
	push hl			;8a37	e5		.
	push hl			;8a38	e5		.
	push hl			;8a39	e5		.
	push hl			;8a3a	e5		.
	push hl			;8a3b	e5		.
	push hl			;8a3c	e5		.
	push hl			;8a3d	e5		.
	push hl			;8a3e	e5		.
	push hl			;8a3f	e5		.
	push hl			;8a40	e5		.
	push hl			;8a41	e5		.
	push hl			;8a42	e5		.
	push hl			;8a43	e5		.
	push hl			;8a44	e5		.
	push hl			;8a45	e5		.
	push hl			;8a46	e5		.
	push hl			;8a47	e5		.
	push hl			;8a48	e5		.
	push hl			;8a49	e5		.
	push hl			;8a4a	e5		.
	push hl			;8a4b	e5		.
	push hl			;8a4c	e5		.
	push hl			;8a4d	e5		.
	push hl			;8a4e	e5		.
	push hl			;8a4f	e5		.
	push hl			;8a50	e5		.
	push hl			;8a51	e5		.
	push hl			;8a52	e5		.
	push hl			;8a53	e5		.
	push hl			;8a54	e5		.
	push hl			;8a55	e5		.
	push hl			;8a56	e5		.
	push hl			;8a57	e5		.
	push hl			;8a58	e5		.
	push hl			;8a59	e5		.
	push hl			;8a5a	e5		.
	push hl			;8a5b	e5		.
	push hl			;8a5c	e5		.
	push hl			;8a5d	e5		.
	push hl			;8a5e	e5		.
	push hl			;8a5f	e5		.
	push hl			;8a60	e5		.
	push hl			;8a61	e5		.
	push hl			;8a62	e5		.
	push hl			;8a63	e5		.
	push hl			;8a64	e5		.
	push hl			;8a65	e5		.
	push hl			;8a66	e5		.
	push hl			;8a67	e5		.
	push hl			;8a68	e5		.
	push hl			;8a69	e5		.
	push hl			;8a6a	e5		.
	push hl			;8a6b	e5		.
	push hl			;8a6c	e5		.
	push hl			;8a6d	e5		.
	push hl			;8a6e	e5		.
	push hl			;8a6f	e5		.
	push hl			;8a70	e5		.
	push hl			;8a71	e5		.
	push hl			;8a72	e5		.
	push hl			;8a73	e5		.
	push hl			;8a74	e5		.
	push hl			;8a75	e5		.
	push hl			;8a76	e5		.
	push hl			;8a77	e5		.
	push hl			;8a78	e5		.
	push hl			;8a79	e5		.
	push hl			;8a7a	e5		.
	push hl			;8a7b	e5		.
	push hl			;8a7c	e5		.
	push hl			;8a7d	e5		.
	push hl			;8a7e	e5		.
	push hl			;8a7f	e5		.
	push hl			;8a80	e5		.
	push hl			;8a81	e5		.
	push hl			;8a82	e5		.
	push hl			;8a83	e5		.
	push hl			;8a84	e5		.
	push hl			;8a85	e5		.
	push hl			;8a86	e5		.
	push hl			;8a87	e5		.
	push hl			;8a88	e5		.
	push hl			;8a89	e5		.
	push hl			;8a8a	e5		.
	push hl			;8a8b	e5		.
	push hl			;8a8c	e5		.
	push hl			;8a8d	e5		.
	push hl			;8a8e	e5		.
	push hl			;8a8f	e5		.
	push hl			;8a90	e5		.
	push hl			;8a91	e5		.
	push hl			;8a92	e5		.
	push hl			;8a93	e5		.
	push hl			;8a94	e5		.
	push hl			;8a95	e5		.
	push hl			;8a96	e5		.
	push hl			;8a97	e5		.
	push hl			;8a98	e5		.
	push hl			;8a99	e5		.
	push hl			;8a9a	e5		.
	push hl			;8a9b	e5		.
	push hl			;8a9c	e5		.
	push hl			;8a9d	e5		.
	push hl			;8a9e	e5		.
	push hl			;8a9f	e5		.
	push hl			;8aa0	e5		.
	push hl			;8aa1	e5		.
	push hl			;8aa2	e5		.
	push hl			;8aa3	e5		.
	push hl			;8aa4	e5		.
	push hl			;8aa5	e5		.
	push hl			;8aa6	e5		.
	push hl			;8aa7	e5		.
	push hl			;8aa8	e5		.
	push hl			;8aa9	e5		.
	push hl			;8aaa	e5		.
	push hl			;8aab	e5		.
	push hl			;8aac	e5		.
	push hl			;8aad	e5		.
	push hl			;8aae	e5		.
	push hl			;8aaf	e5		.
	push hl			;8ab0	e5		.
	push hl			;8ab1	e5		.
	push hl			;8ab2	e5		.
	push hl			;8ab3	e5		.
	push hl			;8ab4	e5		.
	push hl			;8ab5	e5		.
	push hl			;8ab6	e5		.
	push hl			;8ab7	e5		.
	push hl			;8ab8	e5		.
	push hl			;8ab9	e5		.
	push hl			;8aba	e5		.
	push hl			;8abb	e5		.
	push hl			;8abc	e5		.
	push hl			;8abd	e5		.
	push hl			;8abe	e5		.
	push hl			;8abf	e5		.
	push hl			;8ac0	e5		.
	push hl			;8ac1	e5		.
	push hl			;8ac2	e5		.
	push hl			;8ac3	e5		.
	push hl			;8ac4	e5		.
	push hl			;8ac5	e5		.
	push hl			;8ac6	e5		.
	push hl			;8ac7	e5		.
	push hl			;8ac8	e5		.
	push hl			;8ac9	e5		.
	push hl			;8aca	e5		.
	push hl			;8acb	e5		.
	push hl			;8acc	e5		.
	push hl			;8acd	e5		.
	push hl			;8ace	e5		.
	push hl			;8acf	e5		.
	push hl			;8ad0	e5		.
	push hl			;8ad1	e5		.
	push hl			;8ad2	e5		.
	push hl			;8ad3	e5		.
	push hl			;8ad4	e5		.
	push hl			;8ad5	e5		.
	push hl			;8ad6	e5		.
	push hl			;8ad7	e5		.
	push hl			;8ad8	e5		.
	push hl			;8ad9	e5		.
	push hl			;8ada	e5		.
	push hl			;8adb	e5		.
	push hl			;8adc	e5		.
	push hl			;8add	e5		.
	push hl			;8ade	e5		.
	push hl			;8adf	e5		.
	push hl			;8ae0	e5		.
	push hl			;8ae1	e5		.
	push hl			;8ae2	e5		.
	push hl			;8ae3	e5		.
	push hl			;8ae4	e5		.
	push hl			;8ae5	e5		.
	push hl			;8ae6	e5		.
	push hl			;8ae7	e5		.
	push hl			;8ae8	e5		.
	push hl			;8ae9	e5		.
	push hl			;8aea	e5		.
	push hl			;8aeb	e5		.
	push hl			;8aec	e5		.
	push hl			;8aed	e5		.
	push hl			;8aee	e5		.
	push hl			;8aef	e5		.
	push hl			;8af0	e5		.
	push hl			;8af1	e5		.
	push hl			;8af2	e5		.
	push hl			;8af3	e5		.
	push hl			;8af4	e5		.
	push hl			;8af5	e5		.
	push hl			;8af6	e5		.
	push hl			;8af7	e5		.
	push hl			;8af8	e5		.
	push hl			;8af9	e5		.
	push hl			;8afa	e5		.
	push hl			;8afb	e5		.
	push hl			;8afc	e5		.
	push hl			;8afd	e5		.
	push hl			;8afe	e5		.
	push hl			;8aff	e5		.
	push hl			;8b00	e5		.
	push hl			;8b01	e5		.
	push hl			;8b02	e5		.
	push hl			;8b03	e5		.
	push hl			;8b04	e5		.
	push hl			;8b05	e5		.
	push hl			;8b06	e5		.
	push hl			;8b07	e5		.
	push hl			;8b08	e5		.
	push hl			;8b09	e5		.
	push hl			;8b0a	e5		.
	push hl			;8b0b	e5		.
	push hl			;8b0c	e5		.
	push hl			;8b0d	e5		.
	push hl			;8b0e	e5		.
	push hl			;8b0f	e5		.
	push hl			;8b10	e5		.
	push hl			;8b11	e5		.
	push hl			;8b12	e5		.
	push hl			;8b13	e5		.
	push hl			;8b14	e5		.
	push hl			;8b15	e5		.
	push hl			;8b16	e5		.
	push hl			;8b17	e5		.
	push hl			;8b18	e5		.
	push hl			;8b19	e5		.
	push hl			;8b1a	e5		.
	push hl			;8b1b	e5		.
	push hl			;8b1c	e5		.
	push hl			;8b1d	e5		.
	push hl			;8b1e	e5		.
	push hl			;8b1f	e5		.
	push hl			;8b20	e5		.
	push hl			;8b21	e5		.
	push hl			;8b22	e5		.
	push hl			;8b23	e5		.
	push hl			;8b24	e5		.
	push hl			;8b25	e5		.
	push hl			;8b26	e5		.
	push hl			;8b27	e5		.
	push hl			;8b28	e5		.
	push hl			;8b29	e5		.
	push hl			;8b2a	e5		.
	push hl			;8b2b	e5		.
	push hl			;8b2c	e5		.
	push hl			;8b2d	e5		.
	push hl			;8b2e	e5		.
	push hl			;8b2f	e5		.
	push hl			;8b30	e5		.
	push hl			;8b31	e5		.
	push hl			;8b32	e5		.
	push hl			;8b33	e5		.
	push hl			;8b34	e5		.
	push hl			;8b35	e5		.
	push hl			;8b36	e5		.
	push hl			;8b37	e5		.
	push hl			;8b38	e5		.
	push hl			;8b39	e5		.
	push hl			;8b3a	e5		.
	push hl			;8b3b	e5		.
	push hl			;8b3c	e5		.
	push hl			;8b3d	e5		.
	push hl			;8b3e	e5		.
	push hl			;8b3f	e5		.
	push hl			;8b40	e5		.
	push hl			;8b41	e5		.
	push hl			;8b42	e5		.
	push hl			;8b43	e5		.
	push hl			;8b44	e5		.
	push hl			;8b45	e5		.
	push hl			;8b46	e5		.
	push hl			;8b47	e5		.
	push hl			;8b48	e5		.
	push hl			;8b49	e5		.
	push hl			;8b4a	e5		.
	push hl			;8b4b	e5		.
	push hl			;8b4c	e5		.
	push hl			;8b4d	e5		.
	push hl			;8b4e	e5		.
	push hl			;8b4f	e5		.
	push hl			;8b50	e5		.
	push hl			;8b51	e5		.
	push hl			;8b52	e5		.
	push hl			;8b53	e5		.
	push hl			;8b54	e5		.
	push hl			;8b55	e5		.
	push hl			;8b56	e5		.
	push hl			;8b57	e5		.
	push hl			;8b58	e5		.
	push hl			;8b59	e5		.
	push hl			;8b5a	e5		.
	push hl			;8b5b	e5		.
	push hl			;8b5c	e5		.
	push hl			;8b5d	e5		.
	push hl			;8b5e	e5		.
	push hl			;8b5f	e5		.
	push hl			;8b60	e5		.
	push hl			;8b61	e5		.
	push hl			;8b62	e5		.
	push hl			;8b63	e5		.
	push hl			;8b64	e5		.
	push hl			;8b65	e5		.
	push hl			;8b66	e5		.
	push hl			;8b67	e5		.
	push hl			;8b68	e5		.
	push hl			;8b69	e5		.
	push hl			;8b6a	e5		.
	push hl			;8b6b	e5		.
	push hl			;8b6c	e5		.
	push hl			;8b6d	e5		.
	push hl			;8b6e	e5		.
	push hl			;8b6f	e5		.
	push hl			;8b70	e5		.
	push hl			;8b71	e5		.
	push hl			;8b72	e5		.
	push hl			;8b73	e5		.
	push hl			;8b74	e5		.
	push hl			;8b75	e5		.
	push hl			;8b76	e5		.
	push hl			;8b77	e5		.
	push hl			;8b78	e5		.
	push hl			;8b79	e5		.
	push hl			;8b7a	e5		.
	push hl			;8b7b	e5		.
	push hl			;8b7c	e5		.
	push hl			;8b7d	e5		.
	push hl			;8b7e	e5		.
	push hl			;8b7f	e5		.
	push hl			;8b80	e5		.
	push hl			;8b81	e5		.
	push hl			;8b82	e5		.
	push hl			;8b83	e5		.
	push hl			;8b84	e5		.
	push hl			;8b85	e5		.
	push hl			;8b86	e5		.
	push hl			;8b87	e5		.
	push hl			;8b88	e5		.
	push hl			;8b89	e5		.
	push hl			;8b8a	e5		.
	push hl			;8b8b	e5		.
	push hl			;8b8c	e5		.
	push hl			;8b8d	e5		.
	push hl			;8b8e	e5		.
	push hl			;8b8f	e5		.
	push hl			;8b90	e5		.
	push hl			;8b91	e5		.
	push hl			;8b92	e5		.
	push hl			;8b93	e5		.
	push hl			;8b94	e5		.
	push hl			;8b95	e5		.
	push hl			;8b96	e5		.
	push hl			;8b97	e5		.
	push hl			;8b98	e5		.
	push hl			;8b99	e5		.
	push hl			;8b9a	e5		.
	push hl			;8b9b	e5		.
	push hl			;8b9c	e5		.
	push hl			;8b9d	e5		.
	push hl			;8b9e	e5		.
	push hl			;8b9f	e5		.
	push hl			;8ba0	e5		.
	push hl			;8ba1	e5		.
	push hl			;8ba2	e5		.
	push hl			;8ba3	e5		.
	push hl			;8ba4	e5		.
	push hl			;8ba5	e5		.
	push hl			;8ba6	e5		.
	push hl			;8ba7	e5		.
	push hl			;8ba8	e5		.
	push hl			;8ba9	e5		.
	push hl			;8baa	e5		.
	push hl			;8bab	e5		.
	push hl			;8bac	e5		.
	push hl			;8bad	e5		.
	push hl			;8bae	e5		.
	push hl			;8baf	e5		.
	push hl			;8bb0	e5		.
	push hl			;8bb1	e5		.
	push hl			;8bb2	e5		.
	push hl			;8bb3	e5		.
	push hl			;8bb4	e5		.
	push hl			;8bb5	e5		.
	push hl			;8bb6	e5		.
	push hl			;8bb7	e5		.
	push hl			;8bb8	e5		.
	push hl			;8bb9	e5		.
	push hl			;8bba	e5		.
	push hl			;8bbb	e5		.
	push hl			;8bbc	e5		.
	push hl			;8bbd	e5		.
	push hl			;8bbe	e5		.
	push hl			;8bbf	e5		.
	push hl			;8bc0	e5		.
	push hl			;8bc1	e5		.
	push hl			;8bc2	e5		.
	push hl			;8bc3	e5		.
	push hl			;8bc4	e5		.
	push hl			;8bc5	e5		.
	push hl			;8bc6	e5		.
	push hl			;8bc7	e5		.
	push hl			;8bc8	e5		.
	push hl			;8bc9	e5		.
	push hl			;8bca	e5		.
	push hl			;8bcb	e5		.
	push hl			;8bcc	e5		.
	push hl			;8bcd	e5		.
	push hl			;8bce	e5		.
	push hl			;8bcf	e5		.
	push hl			;8bd0	e5		.
	push hl			;8bd1	e5		.
	push hl			;8bd2	e5		.
	push hl			;8bd3	e5		.
	push hl			;8bd4	e5		.
	push hl			;8bd5	e5		.
	push hl			;8bd6	e5		.
	push hl			;8bd7	e5		.
	push hl			;8bd8	e5		.
	push hl			;8bd9	e5		.
	push hl			;8bda	e5		.
	push hl			;8bdb	e5		.
	push hl			;8bdc	e5		.
	push hl			;8bdd	e5		.
	push hl			;8bde	e5		.
	push hl			;8bdf	e5		.
	push hl			;8be0	e5		.
	push hl			;8be1	e5		.
	push hl			;8be2	e5		.
	push hl			;8be3	e5		.
	push hl			;8be4	e5		.
	push hl			;8be5	e5		.
	push hl			;8be6	e5		.
	push hl			;8be7	e5		.
	push hl			;8be8	e5		.
	push hl			;8be9	e5		.
	push hl			;8bea	e5		.
	push hl			;8beb	e5		.
	push hl			;8bec	e5		.
	push hl			;8bed	e5		.
	push hl			;8bee	e5		.
	push hl			;8bef	e5		.
	push hl			;8bf0	e5		.
	push hl			;8bf1	e5		.
	push hl			;8bf2	e5		.
	push hl			;8bf3	e5		.
	push hl			;8bf4	e5		.
	push hl			;8bf5	e5		.
	push hl			;8bf6	e5		.
	push hl			;8bf7	e5		.
	push hl			;8bf8	e5		.
	push hl			;8bf9	e5		.
	push hl			;8bfa	e5		.
	push hl			;8bfb	e5		.
	push hl			;8bfc	e5		.
	push hl			;8bfd	e5		.
	push hl			;8bfe	e5		.
	push hl			;8bff	e5		.
	rst 38h			;8c00	ff		.
	rst 38h			;8c01	ff		.
	rst 38h			;8c02	ff		.
	rst 38h			;8c03	ff		.
	rst 38h			;8c04	ff		.
	rst 38h			;8c05	ff		.
	rst 38h			;8c06	ff		.
	rst 38h			;8c07	ff		.
	rst 38h			;8c08	ff		.
	rst 38h			;8c09	ff		.
	rst 38h			;8c0a	ff		.
	rst 38h			;8c0b	ff		.
	rst 38h			;8c0c	ff		.
	rst 38h			;8c0d	ff		.
	rst 38h			;8c0e	ff		.
	rst 38h			;8c0f	ff		.
	rst 38h			;8c10	ff		.
	rst 38h			;8c11	ff		.
	rst 38h			;8c12	ff		.
	rst 38h			;8c13	ff		.
	rst 38h			;8c14	ff		.
	rst 38h			;8c15	ff		.
	rst 38h			;8c16	ff		.
	rst 38h			;8c17	ff		.
	rst 38h			;8c18	ff		.
	rst 38h			;8c19	ff		.
	nop			;8c1a	00		.
	nop			;8c1b	00		.
	nop			;8c1c	00		.
	nop			;8c1d	00		.
	nop			;8c1e	00		.
	nop			;8c1f	00		.
	nop			;8c20	00		.
	nop			;8c21	00		.
	nop			;8c22	00		.
	nop			;8c23	00		.
	nop			;8c24	00		.
	nop			;8c25	00		.
	nop			;8c26	00		.
	nop			;8c27	00		.
	nop			;8c28	00		.
	nop			;8c29	00		.
	nop			;8c2a	00		.
	nop			;8c2b	00		.
	nop			;8c2c	00		.
	nop			;8c2d	00		.
	nop			;8c2e	00		.
	ld b,b			;8c2f	40		@
	nop			;8c30	00		.
	nop			;8c31	00		.
	nop			;8c32	00		.
	nop			;8c33	00		.
	nop			;8c34	00		.
	nop			;8c35	00		.
	nop			;8c36	00		.
	nop			;8c37	00		.
	nop			;8c38	00		.
	nop			;8c39	00		.
	rst 38h			;8c3a	ff		.
	rst 38h			;8c3b	ff		.
	rst 38h			;8c3c	ff		.
	rst 38h			;8c3d	ff		.
	rst 38h			;8c3e	ff		.
	rst 38h			;8c3f	ff		.
	rst 38h			;8c40	ff		.
	rst 38h			;8c41	ff		.
	rst 38h			;8c42	ff		.
	rst 38h			;8c43	ff		.
	rst 38h			;8c44	ff		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;8c45	fd ff ff	. . .
	rst 38h			;8c48	ff		.
	rst 38h			;8c49	ff		.
	rst 38h			;8c4a	ff		.
	rst 38h			;8c4b	ff		.
	rst 38h			;8c4c	ff		.
	rst 38h			;8c4d	ff		.
	rst 38h			;8c4e	ff		.
	rst 38h			;8c4f	ff		.
	rst 38h			;8c50	ff		.
	rst 38h			;8c51	ff		.
	rst 38h			;8c52	ff		.
	rst 38h			;8c53	ff		.
	rst 38h			;8c54	ff		.
	rst 38h			;8c55	ff		.
	ei			;8c56	fb		.
	rst 38h			;8c57	ff		.
	rst 38h			;8c58	ff		.
	rst 38h			;8c59	ff		.
	nop			;8c5a	00		.
	nop			;8c5b	00		.
	nop			;8c5c	00		.
	nop			;8c5d	00		.
	nop			;8c5e	00		.
	nop			;8c5f	00		.
	nop			;8c60	00		.
	nop			;8c61	00		.
	nop			;8c62	00		.
	nop			;8c63	00		.
	nop			;8c64	00		.
	nop			;8c65	00		.
	nop			;8c66	00		.
	nop			;8c67	00		.
	nop			;8c68	00		.
	nop			;8c69	00		.
	nop			;8c6a	00		.
	nop			;8c6b	00		.
	nop			;8c6c	00		.
	nop			;8c6d	00		.
	nop			;8c6e	00		.
	nop			;8c6f	00		.
	nop			;8c70	00		.
	nop			;8c71	00		.
	nop			;8c72	00		.
	nop			;8c73	00		.
	nop			;8c74	00		.
	nop			;8c75	00		.
	nop			;8c76	00		.
	nop			;8c77	00		.
	nop			;8c78	00		.
	nop			;8c79	00		.
	rst 38h			;8c7a	ff		.
	rst 38h			;8c7b	ff		.
	rst 38h			;8c7c	ff		.
	rst 38h			;8c7d	ff		.
	rst 38h			;8c7e	ff		.
	rst 38h			;8c7f	ff		.
	rst 38h			;8c80	ff		.
	rst 38h			;8c81	ff		.
	rst 38h			;8c82	ff		.
	rst 38h			;8c83	ff		.
	rst 38h			;8c84	ff		.
	rst 38h			;8c85	ff		.
	rst 38h			;8c86	ff		.
	rst 38h			;8c87	ff		.
	rst 38h			;8c88	ff		.
	rst 38h			;8c89	ff		.
	rst 38h			;8c8a	ff		.
	rst 38h			;8c8b	ff		.
	rst 38h			;8c8c	ff		.
	rst 38h			;8c8d	ff		.
	rst 38h			;8c8e	ff		.
	rst 38h			;8c8f	ff		.
	rst 38h			;8c90	ff		.
	rst 38h			;8c91	ff		.
	rst 38h			;8c92	ff		.
	rst 38h			;8c93	ff		.
	rst 38h			;8c94	ff		.
	rst 38h			;8c95	ff		.
	rst 38h			;8c96	ff		.
	rst 38h			;8c97	ff		.
	rst 38h			;8c98	ff		.
	rst 38h			;8c99	ff		.
	nop			;8c9a	00		.
	nop			;8c9b	00		.
	nop			;8c9c	00		.
	nop			;8c9d	00		.
	nop			;8c9e	00		.
	nop			;8c9f	00		.
	nop			;8ca0	00		.
	nop			;8ca1	00		.
	nop			;8ca2	00		.
	nop			;8ca3	00		.
	nop			;8ca4	00		.
	nop			;8ca5	00		.
	nop			;8ca6	00		.
	nop			;8ca7	00		.
	nop			;8ca8	00		.
	nop			;8ca9	00		.
	nop			;8caa	00		.
	nop			;8cab	00		.
	nop			;8cac	00		.
	nop			;8cad	00		.
	nop			;8cae	00		.
	nop			;8caf	00		.
	nop			;8cb0	00		.
	nop			;8cb1	00		.
	nop			;8cb2	00		.
	nop			;8cb3	00		.
	nop			;8cb4	00		.
	nop			;8cb5	00		.
	nop			;8cb6	00		.
	nop			;8cb7	00		.
	nop			;8cb8	00		.
	nop			;8cb9	00		.
	cp 0ffh			;8cba	fe ff		. .
	ei			;8cbc	fb		.
	rst 38h			;8cbd	ff		.
	cp 0ffh			;8cbe	fe ff		. .
	rst 38h			;8cc0	ff		.
	rst 38h			;8cc1	ff		.
	cp 0ffh			;8cc2	fe ff		. .
	in a,(0fdh)		;8cc4	db fd		. .
	rst 38h			;8cc6	ff		.
	rst 38h			;8cc7	ff		.
	rst 38h			;8cc8	ff		.
	rst 38h			;8cc9	ff		.
	rst 38h			;8cca	ff		.
	rst 38h			;8ccb	ff		.
	ei			;8ccc	fb		.
	rst 38h			;8ccd	ff		.
	rst 38h			;8cce	ff		.
	rst 38h			;8ccf	ff		.
	ei			;8cd0	fb		.
	rst 38h			;8cd1	ff		.
	rst 38h			;8cd2	ff		.
	ei			;8cd3	fb		.
	ei			;8cd4	fb		.
	rst 38h			;8cd5	ff		.
	rst 38h			;8cd6	ff		.
	ei			;8cd7	fb		.
	ei			;8cd8	fb		.
	rst 38h			;8cd9	ff		.
	nop			;8cda	00		.
	nop			;8cdb	00		.
	nop			;8cdc	00		.
	nop			;8cdd	00		.
	nop			;8cde	00		.
	nop			;8cdf	00		.
	nop			;8ce0	00		.
	nop			;8ce1	00		.
	nop			;8ce2	00		.
	nop			;8ce3	00		.
	nop			;8ce4	00		.
	nop			;8ce5	00		.
	nop			;8ce6	00		.
	nop			;8ce7	00		.
	nop			;8ce8	00		.
	nop			;8ce9	00		.
	nop			;8cea	00		.
	nop			;8ceb	00		.
	nop			;8cec	00		.
	nop			;8ced	00		.
	nop			;8cee	00		.
	nop			;8cef	00		.
	nop			;8cf0	00		.
	nop			;8cf1	00		.
	nop			;8cf2	00		.
	nop			;8cf3	00		.
	nop			;8cf4	00		.
	nop			;8cf5	00		.
	nop			;8cf6	00		.
	nop			;8cf7	00		.
	nop			;8cf8	00		.
	nop			;8cf9	00		.
	rst 38h			;8cfa	ff		.
	rst 38h			;8cfb	ff		.
	rst 38h			;8cfc	ff		.
	rst 38h			;8cfd	ff		.
	rst 38h			;8cfe	ff		.
	rst 38h			;8cff	ff		.
	rst 38h			;8d00	ff		.
	rst 38h			;8d01	ff		.
	rst 38h			;8d02	ff		.
	rst 38h			;8d03	ff		.
	rst 38h			;8d04	ff		.
	rst 38h			;8d05	ff		.
	rst 38h			;8d06	ff		.
	rst 38h			;8d07	ff		.
	rst 38h			;8d08	ff		.
	rst 38h			;8d09	ff		.
	rst 38h			;8d0a	ff		.
	rst 38h			;8d0b	ff		.
	rst 38h			;8d0c	ff		.
	rst 38h			;8d0d	ff		.
	rst 38h			;8d0e	ff		.
	rst 38h			;8d0f	ff		.
	rst 38h			;8d10	ff		.
	rst 38h			;8d11	ff		.
	rst 38h			;8d12	ff		.
	rst 38h			;8d13	ff		.
	rst 38h			;8d14	ff		.
	rst 38h			;8d15	ff		.
	rst 38h			;8d16	ff		.
	rst 38h			;8d17	ff		.
	rst 38h			;8d18	ff		.
	rst 38h			;8d19	ff		.
	nop			;8d1a	00		.
	nop			;8d1b	00		.
	nop			;8d1c	00		.
	nop			;8d1d	00		.
	nop			;8d1e	00		.
	nop			;8d1f	00		.
	nop			;8d20	00		.
	nop			;8d21	00		.
	nop			;8d22	00		.
	nop			;8d23	00		.
	nop			;8d24	00		.
	nop			;8d25	00		.
	nop			;8d26	00		.
	nop			;8d27	00		.
	nop			;8d28	00		.
	nop			;8d29	00		.
	nop			;8d2a	00		.
	nop			;8d2b	00		.
	nop			;8d2c	00		.
	nop			;8d2d	00		.
	nop			;8d2e	00		.
	ld b,b			;8d2f	40		@
	nop			;8d30	00		.
	nop			;8d31	00		.
	nop			;8d32	00		.
	nop			;8d33	00		.
	nop			;8d34	00		.
	nop			;8d35	00		.
	nop			;8d36	00		.
	nop			;8d37	00		.
	nop			;8d38	00		.
	nop			;8d39	00		.
	rst 38h			;8d3a	ff		.
	rst 38h			;8d3b	ff		.
	rst 38h			;8d3c	ff		.
	rst 38h			;8d3d	ff		.
	rst 38h			;8d3e	ff		.
	rst 38h			;8d3f	ff		.
	rst 38h			;8d40	ff		.
	rst 38h			;8d41	ff		.
	rst 38h			;8d42	ff		.
	rst 38h			;8d43	ff		.
	rst 30h			;8d44	f7		.
	rst 38h			;8d45	ff		.
	rst 38h			;8d46	ff		.
	rst 38h			;8d47	ff		.
	rst 38h			;8d48	ff		.
	rst 38h			;8d49	ff		.
	rst 38h			;8d4a	ff		.
	rst 38h			;8d4b	ff		.
	rst 38h			;8d4c	ff		.
	rst 38h			;8d4d	ff		.
	rst 38h			;8d4e	ff		.
	rst 38h			;8d4f	ff		.
	rst 38h			;8d50	ff		.
	rst 38h			;8d51	ff		.
	rst 38h			;8d52	ff		.
	rst 38h			;8d53	ff		.
	rst 38h			;8d54	ff		.
	rst 38h			;8d55	ff		.
	rst 38h			;8d56	ff		.
	rst 38h			;8d57	ff		.
	rst 38h			;8d58	ff		.
	rst 38h			;8d59	ff		.
	nop			;8d5a	00		.
	nop			;8d5b	00		.
	nop			;8d5c	00		.
	nop			;8d5d	00		.
	nop			;8d5e	00		.
	nop			;8d5f	00		.
	nop			;8d60	00		.
	nop			;8d61	00		.
	nop			;8d62	00		.
	nop			;8d63	00		.
	nop			;8d64	00		.
	nop			;8d65	00		.
	nop			;8d66	00		.
	nop			;8d67	00		.
	nop			;8d68	00		.
	nop			;8d69	00		.
	nop			;8d6a	00		.
	nop			;8d6b	00		.
	nop			;8d6c	00		.
	nop			;8d6d	00		.
	nop			;8d6e	00		.
	nop			;8d6f	00		.
	nop			;8d70	00		.
	nop			;8d71	00		.
	nop			;8d72	00		.
	nop			;8d73	00		.
	nop			;8d74	00		.
	nop			;8d75	00		.
	nop			;8d76	00		.
	nop			;8d77	00		.
	nop			;8d78	00		.
	nop			;8d79	00		.
	rst 38h			;8d7a	ff		.
	rst 38h			;8d7b	ff		.
	rst 38h			;8d7c	ff		.
	rst 38h			;8d7d	ff		.
	rst 38h			;8d7e	ff		.
	rst 38h			;8d7f	ff		.
	rst 38h			;8d80	ff		.
	rst 38h			;8d81	ff		.
	rst 38h			;8d82	ff		.
	rst 38h			;8d83	ff		.
	rst 38h			;8d84	ff		.
	rst 38h			;8d85	ff		.
	rst 38h			;8d86	ff		.
	rst 38h			;8d87	ff		.
	rst 38h			;8d88	ff		.
	rst 38h			;8d89	ff		.
	rst 38h			;8d8a	ff		.
	rst 38h			;8d8b	ff		.
	rst 38h			;8d8c	ff		.
	rst 38h			;8d8d	ff		.
	rst 38h			;8d8e	ff		.
	rst 38h			;8d8f	ff		.
	rst 38h			;8d90	ff		.
	rst 38h			;8d91	ff		.
	rst 38h			;8d92	ff		.
	rst 38h			;8d93	ff		.
	rst 38h			;8d94	ff		.
	rst 38h			;8d95	ff		.
	rst 38h			;8d96	ff		.
	rst 38h			;8d97	ff		.
	rst 38h			;8d98	ff		.
	rst 38h			;8d99	ff		.
	nop			;8d9a	00		.
	nop			;8d9b	00		.
	nop			;8d9c	00		.
	nop			;8d9d	00		.
	nop			;8d9e	00		.
	nop			;8d9f	00		.
	nop			;8da0	00		.
	nop			;8da1	00		.
	nop			;8da2	00		.
	nop			;8da3	00		.
	nop			;8da4	00		.
	nop			;8da5	00		.
	nop			;8da6	00		.
	nop			;8da7	00		.
	nop			;8da8	00		.
	nop			;8da9	00		.
	nop			;8daa	00		.
	nop			;8dab	00		.
	nop			;8dac	00		.
	nop			;8dad	00		.
	nop			;8dae	00		.
	nop			;8daf	00		.
	ld bc,00000h		;8db0	01 00 00	. . .
	nop			;8db3	00		.
	nop			;8db4	00		.
	nop			;8db5	00		.
	nop			;8db6	00		.
	nop			;8db7	00		.
	nop			;8db8	00		.
	nop			;8db9	00		.
	rst 38h			;8dba	ff		.
	rst 38h			;8dbb	ff		.
	rst 38h			;8dbc	ff		.
	rst 38h			;8dbd	ff		.
	rst 38h			;8dbe	ff		.
	rst 38h			;8dbf	ff		.
	rst 38h			;8dc0	ff		.
	rst 38h			;8dc1	ff		.
	rst 38h			;8dc2	ff		.
	rst 38h			;8dc3	ff		.
	jp m,0ffffh		;8dc4	fa ff ff	. . .
	rst 38h			;8dc7	ff		.
	rst 38h			;8dc8	ff		.
	rst 38h			;8dc9	ff		.
	rst 38h			;8dca	ff		.
	rst 38h			;8dcb	ff		.
	rst 38h			;8dcc	ff		.
	rst 38h			;8dcd	ff		.
	rst 38h			;8dce	ff		.
	rst 38h			;8dcf	ff		.
	ei			;8dd0	fb		.
	rst 38h			;8dd1	ff		.
	rst 38h			;8dd2	ff		.
	ei			;8dd3	fb		.
	ei			;8dd4	fb		.
	rst 38h			;8dd5	ff		.
	rst 38h			;8dd6	ff		.
	rst 38h			;8dd7	ff		.
	ei			;8dd8	fb		.
	ei			;8dd9	fb		.
	nop			;8dda	00		.
	nop			;8ddb	00		.
	nop			;8ddc	00		.
	nop			;8ddd	00		.
	nop			;8dde	00		.
	nop			;8ddf	00		.
	nop			;8de0	00		.
	nop			;8de1	00		.
	nop			;8de2	00		.
	nop			;8de3	00		.
	nop			;8de4	00		.
	nop			;8de5	00		.
	nop			;8de6	00		.
	nop			;8de7	00		.
	nop			;8de8	00		.
	nop			;8de9	00		.
	nop			;8dea	00		.
	nop			;8deb	00		.
	nop			;8dec	00		.
	nop			;8ded	00		.
	nop			;8dee	00		.
	nop			;8def	00		.
	nop			;8df0	00		.
	nop			;8df1	00		.
	nop			;8df2	00		.
	nop			;8df3	00		.
	nop			;8df4	00		.
	nop			;8df5	00		.
	nop			;8df6	00		.
	nop			;8df7	00		.
	nop			;8df8	00		.
	nop			;8df9	00		.
	rst 38h			;8dfa	ff		.
	rst 38h			;8dfb	ff		.
	rst 38h			;8dfc	ff		.
	rst 38h			;8dfd	ff		.
	rst 38h			;8dfe	ff		.
	rst 38h			;8dff	ff		.
	push hl			;8e00	e5		.
	push hl			;8e01	e5		.
	push hl			;8e02	e5		.
	push hl			;8e03	e5		.
	push hl			;8e04	e5		.
	push hl			;8e05	e5		.
	push hl			;8e06	e5		.
	push hl			;8e07	e5		.
	push hl			;8e08	e5		.
	push hl			;8e09	e5		.
	push hl			;8e0a	e5		.
	push hl			;8e0b	e5		.
	push hl			;8e0c	e5		.
	push hl			;8e0d	e5		.
	push hl			;8e0e	e5		.
	push hl			;8e0f	e5		.
	push hl			;8e10	e5		.
	push hl			;8e11	e5		.
	push hl			;8e12	e5		.
	push hl			;8e13	e5		.
	push hl			;8e14	e5		.
	push hl			;8e15	e5		.
	push hl			;8e16	e5		.
	push hl			;8e17	e5		.
	push hl			;8e18	e5		.
	push hl			;8e19	e5		.
	push hl			;8e1a	e5		.
	push hl			;8e1b	e5		.
	push hl			;8e1c	e5		.
	push hl			;8e1d	e5		.
	push hl			;8e1e	e5		.
	push hl			;8e1f	e5		.
	push hl			;8e20	e5		.
	push hl			;8e21	e5		.
	push hl			;8e22	e5		.
	push hl			;8e23	e5		.
	push hl			;8e24	e5		.
	push hl			;8e25	e5		.
	push hl			;8e26	e5		.
	push hl			;8e27	e5		.
	push hl			;8e28	e5		.
	push hl			;8e29	e5		.
	push hl			;8e2a	e5		.
	push hl			;8e2b	e5		.
	push hl			;8e2c	e5		.
	push hl			;8e2d	e5		.
	push hl			;8e2e	e5		.
	push hl			;8e2f	e5		.
	push hl			;8e30	e5		.
	push hl			;8e31	e5		.
	push hl			;8e32	e5		.
	push hl			;8e33	e5		.
	push hl			;8e34	e5		.
	push hl			;8e35	e5		.
	push hl			;8e36	e5		.
	push hl			;8e37	e5		.
	push hl			;8e38	e5		.
	push hl			;8e39	e5		.
	push hl			;8e3a	e5		.
	push hl			;8e3b	e5		.
	push hl			;8e3c	e5		.
	push hl			;8e3d	e5		.
	push hl			;8e3e	e5		.
	push hl			;8e3f	e5		.
	push hl			;8e40	e5		.
	push hl			;8e41	e5		.
	push hl			;8e42	e5		.
	push hl			;8e43	e5		.
	push hl			;8e44	e5		.
	push hl			;8e45	e5		.
	push hl			;8e46	e5		.
	push hl			;8e47	e5		.
	push hl			;8e48	e5		.
	push hl			;8e49	e5		.
	push hl			;8e4a	e5		.
	push hl			;8e4b	e5		.
	push hl			;8e4c	e5		.
	push hl			;8e4d	e5		.
	push hl			;8e4e	e5		.
	push hl			;8e4f	e5		.
	push hl			;8e50	e5		.
	push hl			;8e51	e5		.
	push hl			;8e52	e5		.
	push hl			;8e53	e5		.
	push hl			;8e54	e5		.
	push hl			;8e55	e5		.
	push hl			;8e56	e5		.
	push hl			;8e57	e5		.
	push hl			;8e58	e5		.
	push hl			;8e59	e5		.
	push hl			;8e5a	e5		.
	push hl			;8e5b	e5		.
	push hl			;8e5c	e5		.
	push hl			;8e5d	e5		.
	push hl			;8e5e	e5		.
	push hl			;8e5f	e5		.
	push hl			;8e60	e5		.
	push hl			;8e61	e5		.
	push hl			;8e62	e5		.
	push hl			;8e63	e5		.
	push hl			;8e64	e5		.
	push hl			;8e65	e5		.
	push hl			;8e66	e5		.
	push hl			;8e67	e5		.
	push hl			;8e68	e5		.
	push hl			;8e69	e5		.
	push hl			;8e6a	e5		.
	push hl			;8e6b	e5		.
	push hl			;8e6c	e5		.
	push hl			;8e6d	e5		.
	push hl			;8e6e	e5		.
	push hl			;8e6f	e5		.
	push hl			;8e70	e5		.
	push hl			;8e71	e5		.
	push hl			;8e72	e5		.
	push hl			;8e73	e5		.
	push hl			;8e74	e5		.
	push hl			;8e75	e5		.
	push hl			;8e76	e5		.
	push hl			;8e77	e5		.
	push hl			;8e78	e5		.
	push hl			;8e79	e5		.
	push hl			;8e7a	e5		.
	push hl			;8e7b	e5		.
	push hl			;8e7c	e5		.
	push hl			;8e7d	e5		.
	push hl			;8e7e	e5		.
	push hl			;8e7f	e5		.
	push hl			;8e80	e5		.
	push hl			;8e81	e5		.
	push hl			;8e82	e5		.
	push hl			;8e83	e5		.
	push hl			;8e84	e5		.
	push hl			;8e85	e5		.
	push hl			;8e86	e5		.
	push hl			;8e87	e5		.
	push hl			;8e88	e5		.
	push hl			;8e89	e5		.
	push hl			;8e8a	e5		.
	push hl			;8e8b	e5		.
	push hl			;8e8c	e5		.
	push hl			;8e8d	e5		.
	push hl			;8e8e	e5		.
	push hl			;8e8f	e5		.
	push hl			;8e90	e5		.
	push hl			;8e91	e5		.
	push hl			;8e92	e5		.
	push hl			;8e93	e5		.
	push hl			;8e94	e5		.
	push hl			;8e95	e5		.
	push hl			;8e96	e5		.
	push hl			;8e97	e5		.
	push hl			;8e98	e5		.
	push hl			;8e99	e5		.
	push hl			;8e9a	e5		.
	push hl			;8e9b	e5		.
	push hl			;8e9c	e5		.
	push hl			;8e9d	e5		.
	push hl			;8e9e	e5		.
	push hl			;8e9f	e5		.
	push hl			;8ea0	e5		.
	push hl			;8ea1	e5		.
	push hl			;8ea2	e5		.
	push hl			;8ea3	e5		.
	push hl			;8ea4	e5		.
	push hl			;8ea5	e5		.
	push hl			;8ea6	e5		.
	push hl			;8ea7	e5		.
	push hl			;8ea8	e5		.
	push hl			;8ea9	e5		.
	push hl			;8eaa	e5		.
	push hl			;8eab	e5		.
	push hl			;8eac	e5		.
	push hl			;8ead	e5		.
	push hl			;8eae	e5		.
	push hl			;8eaf	e5		.
	push hl			;8eb0	e5		.
	push hl			;8eb1	e5		.
	push hl			;8eb2	e5		.
	push hl			;8eb3	e5		.
	push hl			;8eb4	e5		.
	push hl			;8eb5	e5		.
	push hl			;8eb6	e5		.
	push hl			;8eb7	e5		.
	push hl			;8eb8	e5		.
	push hl			;8eb9	e5		.
	push hl			;8eba	e5		.
	push hl			;8ebb	e5		.
	push hl			;8ebc	e5		.
	push hl			;8ebd	e5		.
	push hl			;8ebe	e5		.
	push hl			;8ebf	e5		.
	push hl			;8ec0	e5		.
	push hl			;8ec1	e5		.
	push hl			;8ec2	e5		.
	push hl			;8ec3	e5		.
	push hl			;8ec4	e5		.
	push hl			;8ec5	e5		.
	push hl			;8ec6	e5		.
	push hl			;8ec7	e5		.
	push hl			;8ec8	e5		.
	push hl			;8ec9	e5		.
	push hl			;8eca	e5		.
	push hl			;8ecb	e5		.
	push hl			;8ecc	e5		.
	push hl			;8ecd	e5		.
	push hl			;8ece	e5		.
	push hl			;8ecf	e5		.
	push hl			;8ed0	e5		.
	push hl			;8ed1	e5		.
	push hl			;8ed2	e5		.
	push hl			;8ed3	e5		.
	push hl			;8ed4	e5		.
	push hl			;8ed5	e5		.
	push hl			;8ed6	e5		.
	push hl			;8ed7	e5		.
	push hl			;8ed8	e5		.
	push hl			;8ed9	e5		.
	push hl			;8eda	e5		.
	push hl			;8edb	e5		.
	push hl			;8edc	e5		.
	push hl			;8edd	e5		.
	push hl			;8ede	e5		.
	push hl			;8edf	e5		.
	push hl			;8ee0	e5		.
	push hl			;8ee1	e5		.
	push hl			;8ee2	e5		.
	push hl			;8ee3	e5		.
	push hl			;8ee4	e5		.
	push hl			;8ee5	e5		.
	push hl			;8ee6	e5		.
	push hl			;8ee7	e5		.
	push hl			;8ee8	e5		.
	push hl			;8ee9	e5		.
	push hl			;8eea	e5		.
	push hl			;8eeb	e5		.
	push hl			;8eec	e5		.
	push hl			;8eed	e5		.
	push hl			;8eee	e5		.
	push hl			;8eef	e5		.
	push hl			;8ef0	e5		.
	push hl			;8ef1	e5		.
	push hl			;8ef2	e5		.
	push hl			;8ef3	e5		.
	push hl			;8ef4	e5		.
	push hl			;8ef5	e5		.
	push hl			;8ef6	e5		.
	push hl			;8ef7	e5		.
	push hl			;8ef8	e5		.
	push hl			;8ef9	e5		.
	push hl			;8efa	e5		.
	push hl			;8efb	e5		.
	push hl			;8efc	e5		.
	push hl			;8efd	e5		.
	push hl			;8efe	e5		.
	push hl			;8eff	e5		.
	push hl			;8f00	e5		.
	push hl			;8f01	e5		.
	push hl			;8f02	e5		.
	push hl			;8f03	e5		.
	push hl			;8f04	e5		.
	push hl			;8f05	e5		.
	push hl			;8f06	e5		.
	push hl			;8f07	e5		.
	push hl			;8f08	e5		.
	push hl			;8f09	e5		.
	push hl			;8f0a	e5		.
	push hl			;8f0b	e5		.
	push hl			;8f0c	e5		.
	push hl			;8f0d	e5		.
	push hl			;8f0e	e5		.
	push hl			;8f0f	e5		.
	push hl			;8f10	e5		.
	push hl			;8f11	e5		.
	push hl			;8f12	e5		.
	push hl			;8f13	e5		.
	push hl			;8f14	e5		.
	push hl			;8f15	e5		.
	push hl			;8f16	e5		.
	push hl			;8f17	e5		.
	push hl			;8f18	e5		.
	push hl			;8f19	e5		.
	push hl			;8f1a	e5		.
	push hl			;8f1b	e5		.
	push hl			;8f1c	e5		.
	push hl			;8f1d	e5		.
	push hl			;8f1e	e5		.
	push hl			;8f1f	e5		.
	push hl			;8f20	e5		.
	push hl			;8f21	e5		.
	push hl			;8f22	e5		.
	push hl			;8f23	e5		.
	push hl			;8f24	e5		.
	push hl			;8f25	e5		.
	push hl			;8f26	e5		.
	push hl			;8f27	e5		.
	push hl			;8f28	e5		.
	push hl			;8f29	e5		.
	push hl			;8f2a	e5		.
	push hl			;8f2b	e5		.
	push hl			;8f2c	e5		.
	push hl			;8f2d	e5		.
	push hl			;8f2e	e5		.
	push hl			;8f2f	e5		.
	push hl			;8f30	e5		.
	push hl			;8f31	e5		.
	push hl			;8f32	e5		.
	push hl			;8f33	e5		.
	push hl			;8f34	e5		.
	push hl			;8f35	e5		.
	push hl			;8f36	e5		.
	push hl			;8f37	e5		.
	push hl			;8f38	e5		.
	push hl			;8f39	e5		.
	push hl			;8f3a	e5		.
	push hl			;8f3b	e5		.
	push hl			;8f3c	e5		.
	push hl			;8f3d	e5		.
	push hl			;8f3e	e5		.
	push hl			;8f3f	e5		.
	push hl			;8f40	e5		.
	push hl			;8f41	e5		.
	push hl			;8f42	e5		.
	push hl			;8f43	e5		.
	push hl			;8f44	e5		.
	push hl			;8f45	e5		.
	push hl			;8f46	e5		.
	push hl			;8f47	e5		.
	push hl			;8f48	e5		.
	push hl			;8f49	e5		.
	push hl			;8f4a	e5		.
	push hl			;8f4b	e5		.
	push hl			;8f4c	e5		.
	push hl			;8f4d	e5		.
	push hl			;8f4e	e5		.
	push hl			;8f4f	e5		.
	push hl			;8f50	e5		.
	push hl			;8f51	e5		.
	push hl			;8f52	e5		.
	push hl			;8f53	e5		.
	push hl			;8f54	e5		.
	push hl			;8f55	e5		.
	push hl			;8f56	e5		.
	push hl			;8f57	e5		.
	push hl			;8f58	e5		.
	push hl			;8f59	e5		.
	push hl			;8f5a	e5		.
	push hl			;8f5b	e5		.
	push hl			;8f5c	e5		.
	push hl			;8f5d	e5		.
	push hl			;8f5e	e5		.
	push hl			;8f5f	e5		.
	push hl			;8f60	e5		.
	push hl			;8f61	e5		.
	push hl			;8f62	e5		.
	push hl			;8f63	e5		.
	push hl			;8f64	e5		.
	push hl			;8f65	e5		.
	push hl			;8f66	e5		.
	push hl			;8f67	e5		.
	push hl			;8f68	e5		.
	push hl			;8f69	e5		.
	push hl			;8f6a	e5		.
	push hl			;8f6b	e5		.
	push hl			;8f6c	e5		.
	push hl			;8f6d	e5		.
	push hl			;8f6e	e5		.
	push hl			;8f6f	e5		.
	push hl			;8f70	e5		.
	push hl			;8f71	e5		.
	push hl			;8f72	e5		.
	push hl			;8f73	e5		.
	push hl			;8f74	e5		.
	push hl			;8f75	e5		.
	push hl			;8f76	e5		.
	push hl			;8f77	e5		.
	push hl			;8f78	e5		.
	push hl			;8f79	e5		.
	push hl			;8f7a	e5		.
	push hl			;8f7b	e5		.
	push hl			;8f7c	e5		.
	push hl			;8f7d	e5		.
	push hl			;8f7e	e5		.
	push hl			;8f7f	e5		.
	push hl			;8f80	e5		.
	push hl			;8f81	e5		.
	push hl			;8f82	e5		.
	push hl			;8f83	e5		.
	push hl			;8f84	e5		.
	push hl			;8f85	e5		.
	push hl			;8f86	e5		.
	push hl			;8f87	e5		.
	push hl			;8f88	e5		.
	push hl			;8f89	e5		.
	push hl			;8f8a	e5		.
	push hl			;8f8b	e5		.
	push hl			;8f8c	e5		.
	push hl			;8f8d	e5		.
	push hl			;8f8e	e5		.
	push hl			;8f8f	e5		.
	push hl			;8f90	e5		.
	push hl			;8f91	e5		.
	push hl			;8f92	e5		.
	push hl			;8f93	e5		.
	push hl			;8f94	e5		.
	push hl			;8f95	e5		.
	push hl			;8f96	e5		.
	push hl			;8f97	e5		.
	push hl			;8f98	e5		.
	push hl			;8f99	e5		.
	push hl			;8f9a	e5		.
	push hl			;8f9b	e5		.
	push hl			;8f9c	e5		.
	push hl			;8f9d	e5		.
	push hl			;8f9e	e5		.
	push hl			;8f9f	e5		.
	push hl			;8fa0	e5		.
	push hl			;8fa1	e5		.
	push hl			;8fa2	e5		.
	push hl			;8fa3	e5		.
	push hl			;8fa4	e5		.
	push hl			;8fa5	e5		.
	push hl			;8fa6	e5		.
	push hl			;8fa7	e5		.
	push hl			;8fa8	e5		.
	push hl			;8fa9	e5		.
	push hl			;8faa	e5		.
	push hl			;8fab	e5		.
	push hl			;8fac	e5		.
	push hl			;8fad	e5		.
	push hl			;8fae	e5		.
	push hl			;8faf	e5		.
	push hl			;8fb0	e5		.
	push hl			;8fb1	e5		.
	push hl			;8fb2	e5		.
	push hl			;8fb3	e5		.
	push hl			;8fb4	e5		.
	push hl			;8fb5	e5		.
	push hl			;8fb6	e5		.
	push hl			;8fb7	e5		.
	push hl			;8fb8	e5		.
	push hl			;8fb9	e5		.
	push hl			;8fba	e5		.
	push hl			;8fbb	e5		.
	push hl			;8fbc	e5		.
	push hl			;8fbd	e5		.
	push hl			;8fbe	e5		.
	push hl			;8fbf	e5		.
	push hl			;8fc0	e5		.
	push hl			;8fc1	e5		.
	push hl			;8fc2	e5		.
	push hl			;8fc3	e5		.
	push hl			;8fc4	e5		.
	push hl			;8fc5	e5		.
	push hl			;8fc6	e5		.
	push hl			;8fc7	e5		.
	push hl			;8fc8	e5		.
	push hl			;8fc9	e5		.
	push hl			;8fca	e5		.
	push hl			;8fcb	e5		.
	push hl			;8fcc	e5		.
	push hl			;8fcd	e5		.
	push hl			;8fce	e5		.
	push hl			;8fcf	e5		.
	push hl			;8fd0	e5		.
	push hl			;8fd1	e5		.
	push hl			;8fd2	e5		.
	push hl			;8fd3	e5		.
	push hl			;8fd4	e5		.
	push hl			;8fd5	e5		.
	push hl			;8fd6	e5		.
	push hl			;8fd7	e5		.
	push hl			;8fd8	e5		.
	push hl			;8fd9	e5		.
	push hl			;8fda	e5		.
	push hl			;8fdb	e5		.
	push hl			;8fdc	e5		.
	push hl			;8fdd	e5		.
	push hl			;8fde	e5		.
	push hl			;8fdf	e5		.
	push hl			;8fe0	e5		.
	push hl			;8fe1	e5		.
	push hl			;8fe2	e5		.
	push hl			;8fe3	e5		.
	push hl			;8fe4	e5		.
	push hl			;8fe5	e5		.
	push hl			;8fe6	e5		.
	push hl			;8fe7	e5		.
	push hl			;8fe8	e5		.
	push hl			;8fe9	e5		.
	push hl			;8fea	e5		.
	push hl			;8feb	e5		.
	push hl			;8fec	e5		.
	push hl			;8fed	e5		.
	push hl			;8fee	e5		.
	push hl			;8fef	e5		.
	push hl			;8ff0	e5		.
	push hl			;8ff1	e5		.
	push hl			;8ff2	e5		.
	push hl			;8ff3	e5		.
	push hl			;8ff4	e5		.
	push hl			;8ff5	e5		.
	push hl			;8ff6	e5		.
	push hl			;8ff7	e5		.
	push hl			;8ff8	e5		.
	push hl			;8ff9	e5		.
	push hl			;8ffa	e5		.
	push hl			;8ffb	e5		.
	push hl			;8ffc	e5		.
	push hl			;8ffd	e5		.
	push hl			;8ffe	e5		.
	push hl			;8fff	e5		.
l9000h:
	rst 38h			;9000	ff		.
	rst 38h			;9001	ff		.
	rst 38h			;9002	ff		.
	rst 38h			;9003	ff		.
	rst 38h			;9004	ff		.
	rst 38h			;9005	ff		.
	rst 38h			;9006	ff		.
	rst 38h			;9007	ff		.
	rst 38h			;9008	ff		.
	rst 38h			;9009	ff		.
	rst 38h			;900a	ff		.
	rst 38h			;900b	ff		.
	rst 38h			;900c	ff		.
	rst 38h			;900d	ff		.
	rst 38h			;900e	ff		.
	rst 38h			;900f	ff		.
	rst 38h			;9010	ff		.
	rst 38h			;9011	ff		.
	rst 38h			;9012	ff		.
	rst 38h			;9013	ff		.
	rst 38h			;9014	ff		.
	rst 38h			;9015	ff		.
	rst 38h			;9016	ff		.
	rst 38h			;9017	ff		.
	rst 38h			;9018	ff		.
	rst 38h			;9019	ff		.
	nop			;901a	00		.
	nop			;901b	00		.
	nop			;901c	00		.
	nop			;901d	00		.
	nop			;901e	00		.
	nop			;901f	00		.
	nop			;9020	00		.
	nop			;9021	00		.
	nop			;9022	00		.
	nop			;9023	00		.
	nop			;9024	00		.
	nop			;9025	00		.
	nop			;9026	00		.
	nop			;9027	00		.
	nop			;9028	00		.
	nop			;9029	00		.
	nop			;902a	00		.
	nop			;902b	00		.
	nop			;902c	00		.
	nop			;902d	00		.
	nop			;902e	00		.
	nop			;902f	00		.
	nop			;9030	00		.
	nop			;9031	00		.
	nop			;9032	00		.
	nop			;9033	00		.
	nop			;9034	00		.
	nop			;9035	00		.
	nop			;9036	00		.
	nop			;9037	00		.
	nop			;9038	00		.
	nop			;9039	00		.
	rst 38h			;903a	ff		.
	rst 38h			;903b	ff		.
	rst 38h			;903c	ff		.
	rst 38h			;903d	ff		.
	rst 38h			;903e	ff		.
	rst 38h			;903f	ff		.
	rst 38h			;9040	ff		.
	rst 38h			;9041	ff		.
	rst 38h			;9042	ff		.
	rst 38h			;9043	ff		.
	rst 38h			;9044	ff		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;9045	fd ff ff	. . .
	rst 38h			;9048	ff		.
	rst 38h			;9049	ff		.
	rst 38h			;904a	ff		.
	rst 38h			;904b	ff		.
	rst 38h			;904c	ff		.
	rst 38h			;904d	ff		.
	rst 38h			;904e	ff		.
	rst 38h			;904f	ff		.
	rst 38h			;9050	ff		.
	rst 38h			;9051	ff		.
	rst 38h			;9052	ff		.
	rst 38h			;9053	ff		.
	rst 38h			;9054	ff		.
	rst 38h			;9055	ff		.
	rst 38h			;9056	ff		.
	rst 38h			;9057	ff		.
	rst 38h			;9058	ff		.
	rst 38h			;9059	ff		.
	nop			;905a	00		.
	nop			;905b	00		.
	nop			;905c	00		.
	nop			;905d	00		.
	nop			;905e	00		.
	nop			;905f	00		.
	nop			;9060	00		.
	nop			;9061	00		.
	nop			;9062	00		.
	nop			;9063	00		.
	nop			;9064	00		.
	nop			;9065	00		.
	nop			;9066	00		.
	nop			;9067	00		.
	nop			;9068	00		.
	nop			;9069	00		.
	nop			;906a	00		.
	nop			;906b	00		.
	nop			;906c	00		.
	nop			;906d	00		.
	nop			;906e	00		.
	nop			;906f	00		.
	nop			;9070	00		.
	nop			;9071	00		.
	nop			;9072	00		.
	nop			;9073	00		.
	nop			;9074	00		.
	nop			;9075	00		.
	nop			;9076	00		.
	nop			;9077	00		.
	nop			;9078	00		.
	nop			;9079	00		.
	rst 38h			;907a	ff		.
	rst 38h			;907b	ff		.
	rst 38h			;907c	ff		.
	rst 38h			;907d	ff		.
	rst 38h			;907e	ff		.
	rst 38h			;907f	ff		.
	rst 38h			;9080	ff		.
	rst 38h			;9081	ff		.
	rst 38h			;9082	ff		.
	rst 38h			;9083	ff		.
	rst 38h			;9084	ff		.
	rst 38h			;9085	ff		.
	rst 38h			;9086	ff		.
	rst 38h			;9087	ff		.
	rst 38h			;9088	ff		.
	rst 38h			;9089	ff		.
	rst 38h			;908a	ff		.
	rst 38h			;908b	ff		.
	rst 38h			;908c	ff		.
	rst 38h			;908d	ff		.
	rst 38h			;908e	ff		.
	rst 38h			;908f	ff		.
	rst 38h			;9090	ff		.
	rst 38h			;9091	ff		.
	rst 38h			;9092	ff		.
	rst 38h			;9093	ff		.
	rst 38h			;9094	ff		.
	rst 38h			;9095	ff		.
	rst 38h			;9096	ff		.
	rst 38h			;9097	ff		.
	rst 38h			;9098	ff		.
	rst 38h			;9099	ff		.
	nop			;909a	00		.
	nop			;909b	00		.
	nop			;909c	00		.
	nop			;909d	00		.
	nop			;909e	00		.
	nop			;909f	00		.
	nop			;90a0	00		.
	nop			;90a1	00		.
	nop			;90a2	00		.
	nop			;90a3	00		.
	nop			;90a4	00		.
	nop			;90a5	00		.
	nop			;90a6	00		.
	nop			;90a7	00		.
	nop			;90a8	00		.
	nop			;90a9	00		.
	nop			;90aa	00		.
	nop			;90ab	00		.
	nop			;90ac	00		.
	nop			;90ad	00		.
	nop			;90ae	00		.
	nop			;90af	00		.
	nop			;90b0	00		.
	nop			;90b1	00		.
	nop			;90b2	00		.
	nop			;90b3	00		.
	nop			;90b4	00		.
	nop			;90b5	00		.
	nop			;90b6	00		.
	nop			;90b7	00		.
	nop			;90b8	00		.
	nop			;90b9	00		.
	cp 0ffh			;90ba	fe ff		. .
	rst 38h			;90bc	ff		.
	cp 0feh			;90bd	fe fe		. .
	rst 38h			;90bf	ff		.
	rst 38h			;90c0	ff		.
	cp 0feh			;90c1	fe fe		. .
	rst 38h			;90c3	ff		.
	rst 38h			;90c4	ff		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;90c5	fd ff ff	. . .
	rst 38h			;90c8	ff		.
	rst 38h			;90c9	ff		.
	rst 38h			;90ca	ff		.
	rst 38h			;90cb	ff		.
	rst 38h			;90cc	ff		.
	rst 38h			;90cd	ff		.
	rst 38h			;90ce	ff		.
	rst 38h			;90cf	ff		.
	ei			;90d0	fb		.
	rst 38h			;90d1	ff		.
	rst 38h			;90d2	ff		.
	rst 38h			;90d3	ff		.
	ei			;90d4	fb		.
	rst 38h			;90d5	ff		.
	rst 38h			;90d6	ff		.
	rst 38h			;90d7	ff		.
	ei			;90d8	fb		.
	ei			;90d9	fb		.
	nop			;90da	00		.
	nop			;90db	00		.
	nop			;90dc	00		.
	nop			;90dd	00		.
	nop			;90de	00		.
	nop			;90df	00		.
	nop			;90e0	00		.
	nop			;90e1	00		.
	nop			;90e2	00		.
	nop			;90e3	00		.
	nop			;90e4	00		.
	nop			;90e5	00		.
	nop			;90e6	00		.
	nop			;90e7	00		.
	nop			;90e8	00		.
	nop			;90e9	00		.
	nop			;90ea	00		.
	nop			;90eb	00		.
	nop			;90ec	00		.
	nop			;90ed	00		.
	nop			;90ee	00		.
	nop			;90ef	00		.
	nop			;90f0	00		.
	nop			;90f1	00		.
	nop			;90f2	00		.
	nop			;90f3	00		.
	nop			;90f4	00		.
	nop			;90f5	00		.
	nop			;90f6	00		.
	nop			;90f7	00		.
	nop			;90f8	00		.
	nop			;90f9	00		.
	rst 38h			;90fa	ff		.
	rst 38h			;90fb	ff		.
	rst 38h			;90fc	ff		.
	rst 38h			;90fd	ff		.
	rst 38h			;90fe	ff		.
	rst 38h			;90ff	ff		.
	rst 38h			;9100	ff		.
	rst 38h			;9101	ff		.
	rst 38h			;9102	ff		.
	rst 38h			;9103	ff		.
	rst 38h			;9104	ff		.
	rst 38h			;9105	ff		.
	rst 38h			;9106	ff		.
	rst 38h			;9107	ff		.
	rst 38h			;9108	ff		.
	rst 38h			;9109	ff		.
	rst 38h			;910a	ff		.
	rst 38h			;910b	ff		.
	rst 38h			;910c	ff		.
	rst 38h			;910d	ff		.
	rst 38h			;910e	ff		.
	rst 38h			;910f	ff		.
	rst 38h			;9110	ff		.
	rst 38h			;9111	ff		.
	rst 38h			;9112	ff		.
	rst 38h			;9113	ff		.
	rst 38h			;9114	ff		.
	rst 38h			;9115	ff		.
	rst 38h			;9116	ff		.
	rst 38h			;9117	ff		.
	rst 38h			;9118	ff		.
	rst 38h			;9119	ff		.
	nop			;911a	00		.
	nop			;911b	00		.
	nop			;911c	00		.
	nop			;911d	00		.
	nop			;911e	00		.
	nop			;911f	00		.
	nop			;9120	00		.
	nop			;9121	00		.
	nop			;9122	00		.
	nop			;9123	00		.
	nop			;9124	00		.
	nop			;9125	00		.
	nop			;9126	00		.
	nop			;9127	00		.
	nop			;9128	00		.
	nop			;9129	00		.
	nop			;912a	00		.
	nop			;912b	00		.
	nop			;912c	00		.
	nop			;912d	00		.
	nop			;912e	00		.
	nop			;912f	00		.
	nop			;9130	00		.
	nop			;9131	00		.
	nop			;9132	00		.
	nop			;9133	00		.
	nop			;9134	00		.
	nop			;9135	00		.
	nop			;9136	00		.
	nop			;9137	00		.
	nop			;9138	00		.
	nop			;9139	00		.
	rst 38h			;913a	ff		.
	rst 38h			;913b	ff		.
	rst 38h			;913c	ff		.
	rst 38h			;913d	ff		.
	rst 38h			;913e	ff		.
	rst 38h			;913f	ff		.
	rst 38h			;9140	ff		.
	rst 38h			;9141	ff		.
	rst 38h			;9142	ff		.
	rst 38h			;9143	ff		.
	rst 38h			;9144	ff		.
	rst 38h			;9145	ff		.
	rst 38h			;9146	ff		.
	rst 38h			;9147	ff		.
	rst 38h			;9148	ff		.
	rst 38h			;9149	ff		.
	rst 38h			;914a	ff		.
	rst 38h			;914b	ff		.
	rst 38h			;914c	ff		.
	rst 38h			;914d	ff		.
	rst 38h			;914e	ff		.
	rst 38h			;914f	ff		.
	rst 38h			;9150	ff		.
	rst 38h			;9151	ff		.
	rst 38h			;9152	ff		.
	rst 38h			;9153	ff		.
	rst 38h			;9154	ff		.
	rst 38h			;9155	ff		.
	rst 38h			;9156	ff		.
	rst 38h			;9157	ff		.
	rst 38h			;9158	ff		.
	rst 38h			;9159	ff		.
	nop			;915a	00		.
	nop			;915b	00		.
	nop			;915c	00		.
	nop			;915d	00		.
	nop			;915e	00		.
	nop			;915f	00		.
	nop			;9160	00		.
	nop			;9161	00		.
	nop			;9162	00		.
	nop			;9163	00		.
	nop			;9164	00		.
	nop			;9165	00		.
	nop			;9166	00		.
	nop			;9167	00		.
	nop			;9168	00		.
	nop			;9169	00		.
	nop			;916a	00		.
	nop			;916b	00		.
	nop			;916c	00		.
	nop			;916d	00		.
	nop			;916e	00		.
	nop			;916f	00		.
	nop			;9170	00		.
	nop			;9171	00		.
	nop			;9172	00		.
	nop			;9173	00		.
	nop			;9174	00		.
	nop			;9175	00		.
	nop			;9176	00		.
	nop			;9177	00		.
	nop			;9178	00		.
	nop			;9179	00		.
	rst 38h			;917a	ff		.
	rst 38h			;917b	ff		.
	rst 38h			;917c	ff		.
	rst 38h			;917d	ff		.
	rst 38h			;917e	ff		.
	rst 38h			;917f	ff		.
	rst 38h			;9180	ff		.
	rst 38h			;9181	ff		.
	rst 38h			;9182	ff		.
	rst 38h			;9183	ff		.
	rst 38h			;9184	ff		.
	rst 38h			;9185	ff		.
	rst 38h			;9186	ff		.
	rst 38h			;9187	ff		.
	rst 38h			;9188	ff		.
	rst 38h			;9189	ff		.
	rst 38h			;918a	ff		.
	rst 38h			;918b	ff		.
	rst 38h			;918c	ff		.
	rst 38h			;918d	ff		.
	rst 38h			;918e	ff		.
	rst 38h			;918f	ff		.
	rst 38h			;9190	ff		.
	rst 38h			;9191	ff		.
	rst 38h			;9192	ff		.
	rst 38h			;9193	ff		.
	rst 38h			;9194	ff		.
	rst 38h			;9195	ff		.
	rst 38h			;9196	ff		.
	rst 38h			;9197	ff		.
	rst 38h			;9198	ff		.
	rst 38h			;9199	ff		.
	nop			;919a	00		.
	nop			;919b	00		.
	nop			;919c	00		.
	nop			;919d	00		.
	nop			;919e	00		.
	nop			;919f	00		.
	nop			;91a0	00		.
	nop			;91a1	00		.
	nop			;91a2	00		.
	nop			;91a3	00		.
	nop			;91a4	00		.
	nop			;91a5	00		.
	nop			;91a6	00		.
	nop			;91a7	00		.
	nop			;91a8	00		.
	nop			;91a9	00		.
	nop			;91aa	00		.
	nop			;91ab	00		.
	nop			;91ac	00		.
	nop			;91ad	00		.
	nop			;91ae	00		.
	ld b,b			;91af	40		@
	nop			;91b0	00		.
	nop			;91b1	00		.
	nop			;91b2	00		.
	nop			;91b3	00		.
	nop			;91b4	00		.
	nop			;91b5	00		.
	nop			;91b6	00		.
	nop			;91b7	00		.
	nop			;91b8	00		.
	nop			;91b9	00		.
	cp 0ffh			;91ba	fe ff		. .
	rst 38h			;91bc	ff		.
	rst 38h			;91bd	ff		.
	cp 0ffh			;91be	fe ff		. .
	rst 38h			;91c0	ff		.
	rst 38h			;91c1	ff		.
	cp 0ffh			;91c2	fe ff		. .
	cp 0ffh			;91c4	fe ff		. .
	rst 38h			;91c6	ff		.
	rst 38h			;91c7	ff		.
	rst 38h			;91c8	ff		.
	rst 38h			;91c9	ff		.
	rst 38h			;91ca	ff		.
	rst 38h			;91cb	ff		.
	rst 38h			;91cc	ff		.
	rst 38h			;91cd	ff		.
	rst 38h			;91ce	ff		.
	rst 38h			;91cf	ff		.
	rst 38h			;91d0	ff		.
	rst 38h			;91d1	ff		.
	rst 38h			;91d2	ff		.
	rst 38h			;91d3	ff		.
	rst 38h			;91d4	ff		.
	rst 38h			;91d5	ff		.
	rst 38h			;91d6	ff		.
	rst 38h			;91d7	ff		.
	ei			;91d8	fb		.
	rst 38h			;91d9	ff		.
	nop			;91da	00		.
	nop			;91db	00		.
	nop			;91dc	00		.
	nop			;91dd	00		.
	nop			;91de	00		.
	nop			;91df	00		.
	nop			;91e0	00		.
	nop			;91e1	00		.
	nop			;91e2	00		.
	nop			;91e3	00		.
	nop			;91e4	00		.
	nop			;91e5	00		.
	nop			;91e6	00		.
	nop			;91e7	00		.
	nop			;91e8	00		.
	nop			;91e9	00		.
	nop			;91ea	00		.
	nop			;91eb	00		.
	nop			;91ec	00		.
	nop			;91ed	00		.
	nop			;91ee	00		.
	nop			;91ef	00		.
	nop			;91f0	00		.
	nop			;91f1	00		.
	nop			;91f2	00		.
	nop			;91f3	00		.
	nop			;91f4	00		.
	nop			;91f5	00		.
	nop			;91f6	00		.
	nop			;91f7	00		.
	nop			;91f8	00		.
	nop			;91f9	00		.
	rst 38h			;91fa	ff		.
	rst 38h			;91fb	ff		.
	rst 38h			;91fc	ff		.
	rst 38h			;91fd	ff		.
	rst 38h			;91fe	ff		.
	rst 38h			;91ff	ff		.
	push hl			;9200	e5		.
	push hl			;9201	e5		.
	push hl			;9202	e5		.
	push hl			;9203	e5		.
	push hl			;9204	e5		.
	push hl			;9205	e5		.
	push hl			;9206	e5		.
	push hl			;9207	e5		.
	push hl			;9208	e5		.
	push hl			;9209	e5		.
	push hl			;920a	e5		.
	push hl			;920b	e5		.
	push hl			;920c	e5		.
	push hl			;920d	e5		.
	push hl			;920e	e5		.
	push hl			;920f	e5		.
	push hl			;9210	e5		.
	push hl			;9211	e5		.
	push hl			;9212	e5		.
	push hl			;9213	e5		.
	push hl			;9214	e5		.
	push hl			;9215	e5		.
	push hl			;9216	e5		.
	push hl			;9217	e5		.
	push hl			;9218	e5		.
	push hl			;9219	e5		.
	push hl			;921a	e5		.
	push hl			;921b	e5		.
	push hl			;921c	e5		.
	push hl			;921d	e5		.
	push hl			;921e	e5		.
	push hl			;921f	e5		.
	push hl			;9220	e5		.
	push hl			;9221	e5		.
	push hl			;9222	e5		.
	push hl			;9223	e5		.
	push hl			;9224	e5		.
	push hl			;9225	e5		.
	push hl			;9226	e5		.
	push hl			;9227	e5		.
	push hl			;9228	e5		.
	push hl			;9229	e5		.
	push hl			;922a	e5		.
	push hl			;922b	e5		.
	push hl			;922c	e5		.
	push hl			;922d	e5		.
	push hl			;922e	e5		.
	push hl			;922f	e5		.
	push hl			;9230	e5		.
	push hl			;9231	e5		.
	push hl			;9232	e5		.
	push hl			;9233	e5		.
	push hl			;9234	e5		.
	push hl			;9235	e5		.
	push hl			;9236	e5		.
	push hl			;9237	e5		.
	push hl			;9238	e5		.
	push hl			;9239	e5		.
	push hl			;923a	e5		.
	push hl			;923b	e5		.
	push hl			;923c	e5		.
	push hl			;923d	e5		.
	push hl			;923e	e5		.
	push hl			;923f	e5		.
	push hl			;9240	e5		.
	push hl			;9241	e5		.
	push hl			;9242	e5		.
	push hl			;9243	e5		.
	push hl			;9244	e5		.
	push hl			;9245	e5		.
	push hl			;9246	e5		.
	push hl			;9247	e5		.
	push hl			;9248	e5		.
	push hl			;9249	e5		.
	push hl			;924a	e5		.
	push hl			;924b	e5		.
	push hl			;924c	e5		.
	push hl			;924d	e5		.
	push hl			;924e	e5		.
	push hl			;924f	e5		.
	push hl			;9250	e5		.
	push hl			;9251	e5		.
	push hl			;9252	e5		.
	push hl			;9253	e5		.
	push hl			;9254	e5		.
	push hl			;9255	e5		.
	push hl			;9256	e5		.
	push hl			;9257	e5		.
	push hl			;9258	e5		.
	push hl			;9259	e5		.
	push hl			;925a	e5		.
	push hl			;925b	e5		.
	push hl			;925c	e5		.
	push hl			;925d	e5		.
	push hl			;925e	e5		.
	push hl			;925f	e5		.
	push hl			;9260	e5		.
	push hl			;9261	e5		.
	push hl			;9262	e5		.
	push hl			;9263	e5		.
	push hl			;9264	e5		.
	push hl			;9265	e5		.
	push hl			;9266	e5		.
	push hl			;9267	e5		.
	push hl			;9268	e5		.
	push hl			;9269	e5		.
	push hl			;926a	e5		.
	push hl			;926b	e5		.
	push hl			;926c	e5		.
	push hl			;926d	e5		.
	push hl			;926e	e5		.
	push hl			;926f	e5		.
	push hl			;9270	e5		.
	push hl			;9271	e5		.
	push hl			;9272	e5		.
	push hl			;9273	e5		.
	push hl			;9274	e5		.
	push hl			;9275	e5		.
	push hl			;9276	e5		.
	push hl			;9277	e5		.
	push hl			;9278	e5		.
	push hl			;9279	e5		.
	push hl			;927a	e5		.
	push hl			;927b	e5		.
	push hl			;927c	e5		.
	push hl			;927d	e5		.
	push hl			;927e	e5		.
	push hl			;927f	e5		.
	push hl			;9280	e5		.
	push hl			;9281	e5		.
	push hl			;9282	e5		.
	push hl			;9283	e5		.
	push hl			;9284	e5		.
	push hl			;9285	e5		.
	push hl			;9286	e5		.
	push hl			;9287	e5		.
	push hl			;9288	e5		.
	push hl			;9289	e5		.
	push hl			;928a	e5		.
	push hl			;928b	e5		.
	push hl			;928c	e5		.
	push hl			;928d	e5		.
	push hl			;928e	e5		.
	push hl			;928f	e5		.
	push hl			;9290	e5		.
	push hl			;9291	e5		.
	push hl			;9292	e5		.
	push hl			;9293	e5		.
	push hl			;9294	e5		.
	push hl			;9295	e5		.
	push hl			;9296	e5		.
	push hl			;9297	e5		.
	push hl			;9298	e5		.
	push hl			;9299	e5		.
	push hl			;929a	e5		.
	push hl			;929b	e5		.
	push hl			;929c	e5		.
	push hl			;929d	e5		.
	push hl			;929e	e5		.
	push hl			;929f	e5		.
	push hl			;92a0	e5		.
	push hl			;92a1	e5		.
	push hl			;92a2	e5		.
	push hl			;92a3	e5		.
	push hl			;92a4	e5		.
	push hl			;92a5	e5		.
	push hl			;92a6	e5		.
	push hl			;92a7	e5		.
	push hl			;92a8	e5		.
	push hl			;92a9	e5		.
	push hl			;92aa	e5		.
	push hl			;92ab	e5		.
	push hl			;92ac	e5		.
	push hl			;92ad	e5		.
	push hl			;92ae	e5		.
	push hl			;92af	e5		.
	push hl			;92b0	e5		.
	push hl			;92b1	e5		.
	push hl			;92b2	e5		.
	push hl			;92b3	e5		.
	push hl			;92b4	e5		.
	push hl			;92b5	e5		.
	push hl			;92b6	e5		.
	push hl			;92b7	e5		.
	push hl			;92b8	e5		.
	push hl			;92b9	e5		.
	push hl			;92ba	e5		.
	push hl			;92bb	e5		.
	push hl			;92bc	e5		.
	push hl			;92bd	e5		.
	push hl			;92be	e5		.
	push hl			;92bf	e5		.
	push hl			;92c0	e5		.
	push hl			;92c1	e5		.
	push hl			;92c2	e5		.
	push hl			;92c3	e5		.
	push hl			;92c4	e5		.
	push hl			;92c5	e5		.
	push hl			;92c6	e5		.
	push hl			;92c7	e5		.
	push hl			;92c8	e5		.
	push hl			;92c9	e5		.
	push hl			;92ca	e5		.
	push hl			;92cb	e5		.
	push hl			;92cc	e5		.
	push hl			;92cd	e5		.
	push hl			;92ce	e5		.
	push hl			;92cf	e5		.
	push hl			;92d0	e5		.
	push hl			;92d1	e5		.
	push hl			;92d2	e5		.
	push hl			;92d3	e5		.
	push hl			;92d4	e5		.
	push hl			;92d5	e5		.
	push hl			;92d6	e5		.
	push hl			;92d7	e5		.
	push hl			;92d8	e5		.
	push hl			;92d9	e5		.
	push hl			;92da	e5		.
	push hl			;92db	e5		.
	push hl			;92dc	e5		.
	push hl			;92dd	e5		.
	push hl			;92de	e5		.
	push hl			;92df	e5		.
	push hl			;92e0	e5		.
	push hl			;92e1	e5		.
	push hl			;92e2	e5		.
	push hl			;92e3	e5		.
	push hl			;92e4	e5		.
	push hl			;92e5	e5		.
	push hl			;92e6	e5		.
	push hl			;92e7	e5		.
	push hl			;92e8	e5		.
	push hl			;92e9	e5		.
	push hl			;92ea	e5		.
	push hl			;92eb	e5		.
	push hl			;92ec	e5		.
	push hl			;92ed	e5		.
	push hl			;92ee	e5		.
	push hl			;92ef	e5		.
	push hl			;92f0	e5		.
	push hl			;92f1	e5		.
	push hl			;92f2	e5		.
	push hl			;92f3	e5		.
	push hl			;92f4	e5		.
	push hl			;92f5	e5		.
	push hl			;92f6	e5		.
	push hl			;92f7	e5		.
	push hl			;92f8	e5		.
	push hl			;92f9	e5		.
	push hl			;92fa	e5		.
	push hl			;92fb	e5		.
	push hl			;92fc	e5		.
	push hl			;92fd	e5		.
	push hl			;92fe	e5		.
	push hl			;92ff	e5		.
	push hl			;9300	e5		.
	push hl			;9301	e5		.
	push hl			;9302	e5		.
	push hl			;9303	e5		.
	push hl			;9304	e5		.
	push hl			;9305	e5		.
	push hl			;9306	e5		.
	push hl			;9307	e5		.
	push hl			;9308	e5		.
	push hl			;9309	e5		.
	push hl			;930a	e5		.
	push hl			;930b	e5		.
	push hl			;930c	e5		.
	push hl			;930d	e5		.
	push hl			;930e	e5		.
	push hl			;930f	e5		.
	push hl			;9310	e5		.
	push hl			;9311	e5		.
	push hl			;9312	e5		.
	push hl			;9313	e5		.
	push hl			;9314	e5		.
	push hl			;9315	e5		.
	push hl			;9316	e5		.
	push hl			;9317	e5		.
	push hl			;9318	e5		.
	push hl			;9319	e5		.
	push hl			;931a	e5		.
	push hl			;931b	e5		.
	push hl			;931c	e5		.
	push hl			;931d	e5		.
	push hl			;931e	e5		.
	push hl			;931f	e5		.
	push hl			;9320	e5		.
	push hl			;9321	e5		.
	push hl			;9322	e5		.
	push hl			;9323	e5		.
	push hl			;9324	e5		.
	push hl			;9325	e5		.
	push hl			;9326	e5		.
	push hl			;9327	e5		.
	push hl			;9328	e5		.
	push hl			;9329	e5		.
	push hl			;932a	e5		.
	push hl			;932b	e5		.
	push hl			;932c	e5		.
	push hl			;932d	e5		.
	push hl			;932e	e5		.
	push hl			;932f	e5		.
	push hl			;9330	e5		.
	push hl			;9331	e5		.
	push hl			;9332	e5		.
	push hl			;9333	e5		.
	push hl			;9334	e5		.
	push hl			;9335	e5		.
	push hl			;9336	e5		.
	push hl			;9337	e5		.
	push hl			;9338	e5		.
	push hl			;9339	e5		.
	push hl			;933a	e5		.
	push hl			;933b	e5		.
	push hl			;933c	e5		.
	push hl			;933d	e5		.
	push hl			;933e	e5		.
	push hl			;933f	e5		.
	push hl			;9340	e5		.
	push hl			;9341	e5		.
	push hl			;9342	e5		.
	push hl			;9343	e5		.
	push hl			;9344	e5		.
	push hl			;9345	e5		.
	push hl			;9346	e5		.
	push hl			;9347	e5		.
	push hl			;9348	e5		.
	push hl			;9349	e5		.
	push hl			;934a	e5		.
	push hl			;934b	e5		.
	push hl			;934c	e5		.
	push hl			;934d	e5		.
	push hl			;934e	e5		.
	push hl			;934f	e5		.
	push hl			;9350	e5		.
	push hl			;9351	e5		.
	push hl			;9352	e5		.
	push hl			;9353	e5		.
	push hl			;9354	e5		.
	push hl			;9355	e5		.
	push hl			;9356	e5		.
	push hl			;9357	e5		.
	push hl			;9358	e5		.
	push hl			;9359	e5		.
	push hl			;935a	e5		.
	push hl			;935b	e5		.
	push hl			;935c	e5		.
	push hl			;935d	e5		.
	push hl			;935e	e5		.
	push hl			;935f	e5		.
	push hl			;9360	e5		.
	push hl			;9361	e5		.
	push hl			;9362	e5		.
	push hl			;9363	e5		.
	push hl			;9364	e5		.
	push hl			;9365	e5		.
	push hl			;9366	e5		.
	push hl			;9367	e5		.
	push hl			;9368	e5		.
	push hl			;9369	e5		.
	push hl			;936a	e5		.
	push hl			;936b	e5		.
	push hl			;936c	e5		.
	push hl			;936d	e5		.
	push hl			;936e	e5		.
	push hl			;936f	e5		.
	push hl			;9370	e5		.
	push hl			;9371	e5		.
	push hl			;9372	e5		.
	push hl			;9373	e5		.
	push hl			;9374	e5		.
	push hl			;9375	e5		.
	push hl			;9376	e5		.
	push hl			;9377	e5		.
	push hl			;9378	e5		.
	push hl			;9379	e5		.
	push hl			;937a	e5		.
	push hl			;937b	e5		.
	push hl			;937c	e5		.
	push hl			;937d	e5		.
	push hl			;937e	e5		.
	push hl			;937f	e5		.
	push hl			;9380	e5		.
	push hl			;9381	e5		.
	push hl			;9382	e5		.
	push hl			;9383	e5		.
	push hl			;9384	e5		.
	push hl			;9385	e5		.
	push hl			;9386	e5		.
	push hl			;9387	e5		.
	push hl			;9388	e5		.
	push hl			;9389	e5		.
	push hl			;938a	e5		.
	push hl			;938b	e5		.
	push hl			;938c	e5		.
	push hl			;938d	e5		.
	push hl			;938e	e5		.
	push hl			;938f	e5		.
	push hl			;9390	e5		.
	push hl			;9391	e5		.
	push hl			;9392	e5		.
	push hl			;9393	e5		.
	push hl			;9394	e5		.
	push hl			;9395	e5		.
	push hl			;9396	e5		.
	push hl			;9397	e5		.
	push hl			;9398	e5		.
	push hl			;9399	e5		.
	push hl			;939a	e5		.
	push hl			;939b	e5		.
	push hl			;939c	e5		.
	push hl			;939d	e5		.
	push hl			;939e	e5		.
	push hl			;939f	e5		.
	push hl			;93a0	e5		.
	push hl			;93a1	e5		.
	push hl			;93a2	e5		.
	push hl			;93a3	e5		.
	push hl			;93a4	e5		.
	push hl			;93a5	e5		.
	push hl			;93a6	e5		.
	push hl			;93a7	e5		.
	push hl			;93a8	e5		.
	push hl			;93a9	e5		.
	push hl			;93aa	e5		.
	push hl			;93ab	e5		.
	push hl			;93ac	e5		.
	push hl			;93ad	e5		.
	push hl			;93ae	e5		.
	push hl			;93af	e5		.
	push hl			;93b0	e5		.
	push hl			;93b1	e5		.
	push hl			;93b2	e5		.
	push hl			;93b3	e5		.
	push hl			;93b4	e5		.
	push hl			;93b5	e5		.
	push hl			;93b6	e5		.
	push hl			;93b7	e5		.
	push hl			;93b8	e5		.
	push hl			;93b9	e5		.
	push hl			;93ba	e5		.
	push hl			;93bb	e5		.
	push hl			;93bc	e5		.
	push hl			;93bd	e5		.
	push hl			;93be	e5		.
	push hl			;93bf	e5		.
	push hl			;93c0	e5		.
	push hl			;93c1	e5		.
	push hl			;93c2	e5		.
	push hl			;93c3	e5		.
	push hl			;93c4	e5		.
	push hl			;93c5	e5		.
	push hl			;93c6	e5		.
	push hl			;93c7	e5		.
	push hl			;93c8	e5		.
	push hl			;93c9	e5		.
	push hl			;93ca	e5		.
	push hl			;93cb	e5		.
	push hl			;93cc	e5		.
	push hl			;93cd	e5		.
	push hl			;93ce	e5		.
	push hl			;93cf	e5		.
	push hl			;93d0	e5		.
	push hl			;93d1	e5		.
	push hl			;93d2	e5		.
	push hl			;93d3	e5		.
	push hl			;93d4	e5		.
	push hl			;93d5	e5		.
	push hl			;93d6	e5		.
	push hl			;93d7	e5		.
	push hl			;93d8	e5		.
	push hl			;93d9	e5		.
	push hl			;93da	e5		.
	push hl			;93db	e5		.
	push hl			;93dc	e5		.
	push hl			;93dd	e5		.
	push hl			;93de	e5		.
	push hl			;93df	e5		.
	push hl			;93e0	e5		.
	push hl			;93e1	e5		.
	push hl			;93e2	e5		.
	push hl			;93e3	e5		.
	push hl			;93e4	e5		.
	push hl			;93e5	e5		.
	push hl			;93e6	e5		.
	push hl			;93e7	e5		.
	push hl			;93e8	e5		.
	push hl			;93e9	e5		.
	push hl			;93ea	e5		.
	push hl			;93eb	e5		.
	push hl			;93ec	e5		.
	push hl			;93ed	e5		.
	push hl			;93ee	e5		.
	push hl			;93ef	e5		.
	push hl			;93f0	e5		.
	push hl			;93f1	e5		.
	push hl			;93f2	e5		.
	push hl			;93f3	e5		.
	push hl			;93f4	e5		.
	push hl			;93f5	e5		.
	push hl			;93f6	e5		.
	push hl			;93f7	e5		.
	push hl			;93f8	e5		.
	push hl			;93f9	e5		.
	push hl			;93fa	e5		.
	push hl			;93fb	e5		.
	push hl			;93fc	e5		.
	push hl			;93fd	e5		.
	push hl			;93fe	e5		.
	push hl			;93ff	e5		.
	rst 38h			;9400	ff		.
	rst 38h			;9401	ff		.
	rst 38h			;9402	ff		.
	rst 38h			;9403	ff		.
	rst 38h			;9404	ff		.
	rst 38h			;9405	ff		.
	rst 38h			;9406	ff		.
	rst 38h			;9407	ff		.
	rst 38h			;9408	ff		.
	rst 38h			;9409	ff		.
	rst 38h			;940a	ff		.
	rst 38h			;940b	ff		.
	rst 38h			;940c	ff		.
	rst 38h			;940d	ff		.
	rst 38h			;940e	ff		.
	rst 38h			;940f	ff		.
	rst 38h			;9410	ff		.
	rst 38h			;9411	ff		.
	rst 38h			;9412	ff		.
	rst 38h			;9413	ff		.
	rst 38h			;9414	ff		.
	rst 38h			;9415	ff		.
	rst 38h			;9416	ff		.
	rst 38h			;9417	ff		.
	rst 38h			;9418	ff		.
	rst 38h			;9419	ff		.
	nop			;941a	00		.
	nop			;941b	00		.
	nop			;941c	00		.
	nop			;941d	00		.
	nop			;941e	00		.
	nop			;941f	00		.
	nop			;9420	00		.
	nop			;9421	00		.
	nop			;9422	00		.
	nop			;9423	00		.
	nop			;9424	00		.
	nop			;9425	00		.
	nop			;9426	00		.
	nop			;9427	00		.
	nop			;9428	00		.
	nop			;9429	00		.
	nop			;942a	00		.
	nop			;942b	00		.
	nop			;942c	00		.
	nop			;942d	00		.
	nop			;942e	00		.
	ld b,b			;942f	40		@
	nop			;9430	00		.
	nop			;9431	00		.
	nop			;9432	00		.
	nop			;9433	00		.
	nop			;9434	00		.
	nop			;9435	00		.
	nop			;9436	00		.
	nop			;9437	00		.
	nop			;9438	00		.
	nop			;9439	00		.
	rst 38h			;943a	ff		.
	rst 38h			;943b	ff		.
	rst 38h			;943c	ff		.
	rst 38h			;943d	ff		.
	rst 38h			;943e	ff		.
	rst 38h			;943f	ff		.
	rst 38h			;9440	ff		.
	rst 38h			;9441	ff		.
	rst 38h			;9442	ff		.
	rst 38h			;9443	ff		.
	rst 38h			;9444	ff		.
	rst 38h			;9445	ff		.
	rst 38h			;9446	ff		.
	rst 38h			;9447	ff		.
	rst 38h			;9448	ff		.
	rst 38h			;9449	ff		.
	rst 38h			;944a	ff		.
	rst 38h			;944b	ff		.
	rst 38h			;944c	ff		.
	rst 38h			;944d	ff		.
	rst 38h			;944e	ff		.
	rst 38h			;944f	ff		.
	rst 38h			;9450	ff		.
	rst 38h			;9451	ff		.
	rst 38h			;9452	ff		.
	rst 38h			;9453	ff		.
	rst 38h			;9454	ff		.
	rst 38h			;9455	ff		.
	rst 38h			;9456	ff		.
	rst 38h			;9457	ff		.
	rst 38h			;9458	ff		.
	rst 38h			;9459	ff		.
	nop			;945a	00		.
	nop			;945b	00		.
	nop			;945c	00		.
	nop			;945d	00		.
	nop			;945e	00		.
	nop			;945f	00		.
	nop			;9460	00		.
	nop			;9461	00		.
	nop			;9462	00		.
	nop			;9463	00		.
	nop			;9464	00		.
	nop			;9465	00		.
	nop			;9466	00		.
	nop			;9467	00		.
	nop			;9468	00		.
	nop			;9469	00		.
	nop			;946a	00		.
	nop			;946b	00		.
	nop			;946c	00		.
	nop			;946d	00		.
	nop			;946e	00		.
	nop			;946f	00		.
	nop			;9470	00		.
	nop			;9471	00		.
	nop			;9472	00		.
	nop			;9473	00		.
	nop			;9474	00		.
	nop			;9475	00		.
	nop			;9476	00		.
	nop			;9477	00		.
	nop			;9478	00		.
	nop			;9479	00		.
	rst 38h			;947a	ff		.
	rst 38h			;947b	ff		.
	rst 38h			;947c	ff		.
	rst 38h			;947d	ff		.
	rst 38h			;947e	ff		.
	rst 38h			;947f	ff		.
	rst 38h			;9480	ff		.
	rst 38h			;9481	ff		.
	rst 38h			;9482	ff		.
	rst 38h			;9483	ff		.
	rst 38h			;9484	ff		.
	rst 38h			;9485	ff		.
	rst 38h			;9486	ff		.
	rst 38h			;9487	ff		.
	rst 38h			;9488	ff		.
	rst 38h			;9489	ff		.
	rst 38h			;948a	ff		.
	rst 38h			;948b	ff		.
	rst 38h			;948c	ff		.
	rst 38h			;948d	ff		.
	rst 38h			;948e	ff		.
	rst 38h			;948f	ff		.
	rst 38h			;9490	ff		.
	rst 38h			;9491	ff		.
	rst 38h			;9492	ff		.
	rst 38h			;9493	ff		.
	rst 38h			;9494	ff		.
	rst 38h			;9495	ff		.
	rst 38h			;9496	ff		.
	rst 38h			;9497	ff		.
	rst 38h			;9498	ff		.
	rst 38h			;9499	ff		.
	nop			;949a	00		.
	nop			;949b	00		.
	nop			;949c	00		.
	nop			;949d	00		.
	nop			;949e	00		.
	nop			;949f	00		.
	nop			;94a0	00		.
	nop			;94a1	00		.
	nop			;94a2	00		.
	nop			;94a3	00		.
	nop			;94a4	00		.
	nop			;94a5	00		.
	nop			;94a6	00		.
	nop			;94a7	00		.
	nop			;94a8	00		.
	nop			;94a9	00		.
	nop			;94aa	00		.
	nop			;94ab	00		.
	nop			;94ac	00		.
	nop			;94ad	00		.
	nop			;94ae	00		.
	ld b,b			;94af	40		@
	nop			;94b0	00		.
	nop			;94b1	00		.
	nop			;94b2	00		.
	nop			;94b3	00		.
	nop			;94b4	00		.
	nop			;94b5	00		.
	nop			;94b6	00		.
	nop			;94b7	00		.
	ld bc,0ff00h		;94b8	01 00 ff	. . .
	rst 38h			;94bb	ff		.
	rst 38h			;94bc	ff		.
	rst 38h			;94bd	ff		.
	rst 38h			;94be	ff		.
	rst 38h			;94bf	ff		.
	rst 38h			;94c0	ff		.
	rst 38h			;94c1	ff		.
	rst 38h			;94c2	ff		.
	rst 38h			;94c3	ff		.
	rst 38h			;94c4	ff		.
	defb 0fdh,0ffh,0ffh ;illegal sequence	;94c5	fd ff ff	. . .
	rst 38h			;94c8	ff		.
	rst 38h			;94c9	ff		.
	rst 38h			;94ca	ff		.
	rst 38h			;94cb	ff		.
	rst 38h			;94cc	ff		.
	rst 38h			;94cd	ff		.
	rst 38h			;94ce	ff		.
	rst 38h			;94cf	ff		.
	rst 38h			;94d0	ff		.
	rst 38h			;94d1	ff		.
	rst 38h			;94d2	ff		.
	rst 38h			;94d3	ff		.
	rst 38h			;94d4	ff		.
	rst 38h			;94d5	ff		.
	rst 38h			;94d6	ff		.
	rst 38h			;94d7	ff		.
	ei			;94d8	fb		.
	rst 38h			;94d9	ff		.
	nop			;94da	00		.
	nop			;94db	00		.
	nop			;94dc	00		.
	nop			;94dd	00		.
	nop			;94de	00		.
	nop			;94df	00		.
	nop			;94e0	00		.
	nop			;94e1	00		.
	nop			;94e2	00		.
	nop			;94e3	00		.
	nop			;94e4	00		.
	nop			;94e5	00		.
	nop			;94e6	00		.
	nop			;94e7	00		.
	nop			;94e8	00		.
	nop			;94e9	00		.
	nop			;94ea	00		.
	nop			;94eb	00		.
	nop			;94ec	00		.
	nop			;94ed	00		.
	nop			;94ee	00		.
	nop			;94ef	00		.
	nop			;94f0	00		.
	nop			;94f1	00		.
	nop			;94f2	00		.
	nop			;94f3	00		.
	nop			;94f4	00		.
	nop			;94f5	00		.
	nop			;94f6	00		.
	nop			;94f7	00		.
	nop			;94f8	00		.
	nop			;94f9	00		.
	rst 38h			;94fa	ff		.
	rst 38h			;94fb	ff		.
	rst 38h			;94fc	ff		.
	rst 38h			;94fd	ff		.
	rst 38h			;94fe	ff		.
	rst 38h			;94ff	ff		.
	rst 38h			;9500	ff		.
	rst 38h			;9501	ff		.
	rst 38h			;9502	ff		.
	rst 38h			;9503	ff		.
	rst 38h			;9504	ff		.
	rst 38h			;9505	ff		.
	rst 38h			;9506	ff		.
	rst 38h			;9507	ff		.
	rst 38h			;9508	ff		.
	rst 38h			;9509	ff		.
	rst 38h			;950a	ff		.
	rst 38h			;950b	ff		.
	rst 38h			;950c	ff		.
	rst 38h			;950d	ff		.
	rst 38h			;950e	ff		.
	rst 38h			;950f	ff		.
	rst 38h			;9510	ff		.
	rst 38h			;9511	ff		.
	rst 38h			;9512	ff		.
	rst 38h			;9513	ff		.
	rst 38h			;9514	ff		.
	rst 38h			;9515	ff		.
	rst 38h			;9516	ff		.
	rst 38h			;9517	ff		.
	rst 38h			;9518	ff		.
	rst 38h			;9519	ff		.
	nop			;951a	00		.
	nop			;951b	00		.
	nop			;951c	00		.
	nop			;951d	00		.
	nop			;951e	00		.
	nop			;951f	00		.
	nop			;9520	00		.
	nop			;9521	00		.
	nop			;9522	00		.
	nop			;9523	00		.
	nop			;9524	00		.
	nop			;9525	00		.
	nop			;9526	00		.
	nop			;9527	00		.
	nop			;9528	00		.
	nop			;9529	00		.
	nop			;952a	00		.
	nop			;952b	00		.
	nop			;952c	00		.
	nop			;952d	00		.
	nop			;952e	00		.
	nop			;952f	00		.
	nop			;9530	00		.
	nop			;9531	00		.
	nop			;9532	00		.
	nop			;9533	00		.
	nop			;9534	00		.
	nop			;9535	00		.
	nop			;9536	00		.
	nop			;9537	00		.
	nop			;9538	00		.
	nop			;9539	00		.
	rst 38h			;953a	ff		.
	rst 38h			;953b	ff		.
	rst 38h			;953c	ff		.
	rst 38h			;953d	ff		.
	rst 38h			;953e	ff		.
	rst 38h			;953f	ff		.
	rst 38h			;9540	ff		.
	rst 38h			;9541	ff		.
	rst 38h			;9542	ff		.
	rst 38h			;9543	ff		.
	rst 38h			;9544	ff		.
	rst 38h			;9545	ff		.
	rst 38h			;9546	ff		.
	rst 38h			;9547	ff		.
	rst 38h			;9548	ff		.
	rst 38h			;9549	ff		.
	rst 38h			;954a	ff		.
	rst 38h			;954b	ff		.
	rst 38h			;954c	ff		.
	rst 38h			;954d	ff		.
	rst 38h			;954e	ff		.
	rst 38h			;954f	ff		.
	rst 38h			;9550	ff		.
	rst 38h			;9551	ff		.
	rst 38h			;9552	ff		.
	rst 38h			;9553	ff		.
	rst 38h			;9554	ff		.
	rst 38h			;9555	ff		.
	rst 38h			;9556	ff		.
	rst 38h			;9557	ff		.
	rst 38h			;9558	ff		.
	ei			;9559	fb		.
	nop			;955a	00		.
	nop			;955b	00		.
	nop			;955c	00		.
	nop			;955d	00		.
	nop			;955e	00		.
	nop			;955f	00		.
	nop			;9560	00		.
	nop			;9561	00		.
	nop			;9562	00		.
	nop			;9563	00		.
	nop			;9564	00		.
	nop			;9565	00		.
	nop			;9566	00		.
	nop			;9567	00		.
	nop			;9568	00		.
	nop			;9569	00		.
	nop			;956a	00		.
	nop			;956b	00		.
	nop			;956c	00		.
	nop			;956d	00		.
	nop			;956e	00		.
	nop			;956f	00		.
	nop			;9570	00		.
	nop			;9571	00		.
	nop			;9572	00		.
	nop			;9573	00		.
	nop			;9574	00		.
	nop			;9575	00		.
	nop			;9576	00		.
	nop			;9577	00		.
	nop			;9578	00		.
	nop			;9579	00		.
	rst 38h			;957a	ff		.
	rst 38h			;957b	ff		.
	rst 38h			;957c	ff		.
	rst 38h			;957d	ff		.
	rst 38h			;957e	ff		.
	rst 38h			;957f	ff		.
	rst 38h			;9580	ff		.
	rst 38h			;9581	ff		.
	rst 38h			;9582	ff		.
	rst 38h			;9583	ff		.
	rst 38h			;9584	ff		.
	rst 38h			;9585	ff		.
	rst 38h			;9586	ff		.
	rst 38h			;9587	ff		.
	rst 38h			;9588	ff		.
	rst 38h			;9589	ff		.
	rst 38h			;958a	ff		.
	rst 38h			;958b	ff		.
	rst 38h			;958c	ff		.
	rst 38h			;958d	ff		.
	rst 38h			;958e	ff		.
	rst 38h			;958f	ff		.
	rst 38h			;9590	ff		.
	rst 38h			;9591	ff		.
	rst 38h			;9592	ff		.
	rst 38h			;9593	ff		.
	rst 38h			;9594	ff		.
	rst 38h			;9595	ff		.
	rst 38h			;9596	ff		.
	rst 38h			;9597	ff		.
	rst 38h			;9598	ff		.
	rst 38h			;9599	ff		.
	nop			;959a	00		.
	nop			;959b	00		.
	nop			;959c	00		.
	nop			;959d	00		.
	nop			;959e	00		.
	nop			;959f	00		.
	nop			;95a0	00		.
	nop			;95a1	00		.
	nop			;95a2	00		.
	nop			;95a3	00		.
	nop			;95a4	00		.
	nop			;95a5	00		.
	nop			;95a6	00		.
	nop			;95a7	00		.
	nop			;95a8	00		.
	nop			;95a9	00		.
	nop			;95aa	00		.
	nop			;95ab	00		.
	nop			;95ac	00		.
	nop			;95ad	00		.
	nop			;95ae	00		.
	nop			;95af	00		.
	nop			;95b0	00		.
	nop			;95b1	00		.
	nop			;95b2	00		.
	nop			;95b3	00		.
	nop			;95b4	00		.
	nop			;95b5	00		.
	nop			;95b6	00		.
	ld bc,00001h		;95b7	01 01 00	. . .
	rst 38h			;95ba	ff		.
	rst 38h			;95bb	ff		.
	rst 38h			;95bc	ff		.
	rst 38h			;95bd	ff		.
	rst 38h			;95be	ff		.
	rst 38h			;95bf	ff		.
	rst 38h			;95c0	ff		.
	rst 38h			;95c1	ff		.
	rst 38h			;95c2	ff		.
	rst 38h			;95c3	ff		.
	rst 38h			;95c4	ff		.
	rst 38h			;95c5	ff		.
	rst 38h			;95c6	ff		.
	rst 38h			;95c7	ff		.
	rst 38h			;95c8	ff		.
	rst 38h			;95c9	ff		.
	rst 38h			;95ca	ff		.
	rst 38h			;95cb	ff		.
	rst 38h			;95cc	ff		.
	rst 38h			;95cd	ff		.
	rst 38h			;95ce	ff		.
	rst 38h			;95cf	ff		.
	rst 38h			;95d0	ff		.
	rst 38h			;95d1	ff		.
	rst 38h			;95d2	ff		.
	rst 38h			;95d3	ff		.
	rst 38h			;95d4	ff		.
	rst 38h			;95d5	ff		.
	rst 38h			;95d6	ff		.
	rst 38h			;95d7	ff		.
	rst 38h			;95d8	ff		.
	rst 38h			;95d9	ff		.
	nop			;95da	00		.
	nop			;95db	00		.
	nop			;95dc	00		.
	nop			;95dd	00		.
	nop			;95de	00		.
	nop			;95df	00		.
	nop			;95e0	00		.
	nop			;95e1	00		.
	nop			;95e2	00		.
	nop			;95e3	00		.
	nop			;95e4	00		.
	nop			;95e5	00		.
	nop			;95e6	00		.
	nop			;95e7	00		.
	nop			;95e8	00		.
	nop			;95e9	00		.
	nop			;95ea	00		.
	nop			;95eb	00		.
	nop			;95ec	00		.
	nop			;95ed	00		.
	nop			;95ee	00		.
	nop			;95ef	00		.
	nop			;95f0	00		.
	nop			;95f1	00		.
	nop			;95f2	00		.
	nop			;95f3	00		.
	nop			;95f4	00		.
	nop			;95f5	00		.
	nop			;95f6	00		.
	nop			;95f7	00		.
	nop			;95f8	00		.
	nop			;95f9	00		.
	rst 38h			;95fa	ff		.
	rst 38h			;95fb	ff		.
	rst 38h			;95fc	ff		.
	rst 38h			;95fd	ff		.
	rst 38h			;95fe	ff		.
	rst 38h			;95ff	ff		.
