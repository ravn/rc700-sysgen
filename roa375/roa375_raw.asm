; z80dasm 1.2.0
; command line: z80dasm -a -l -g 0 roa375.rom

	org 00000h

l0000h:
	di			;0000
	ld sp,0bfffh		;0001
l0004h:
	ld hl,l0068h		;0004
l0007h:
	ld a,(hl)		;0007
	or a			;0008
	inc hl			;0009
	jp z,l0007h		;000a
	cp 0ffh			;000d
l000fh:
	jp z,l0013h		;000f
l0012h:
	dec hl			;0012
l0013h:
	ex de,hl		;0013
l0014h:
	ld hl,07000h		;0014
	ld bc,l0798h		;0017
l001ah:
	ld a,(de)		;001a
	ld (hl),a		;001b
	inc de			;001c
l001dh:
	inc hl			;001d
	dec bc			;001e
	ld a,c			;001f
l0020h:
	or b			;0020
	jp nz,l001ah		;0021
	jp 070d0h		;0024
l0027h:
	ld a,003h		;0027
	ld (0801ch),a		;0029
	inc a			;002c
	ld (0801dh),a		;002d
	ld (08042h),a		;0030
	ld a,000h		;0033
	ld b,a			;0035
	in a,(014h)		;0036
	and 080h		;0038
	add a,b			;003a
	ld (07320h),a		;003b
	xor a			;003e
	ld (08033h),a		;003f
	ld (0801bh),a		;0042
	ld (08060h),a		;0045
	ld (08061h),a		;0048
	ld (08041h),a		;004b
	ld c,008h		;004e
	ld hl,08063h		;0050
l0053h:
	ld (hl),a		;0053
	inc hl			;0054
	dec c			;0055
	jp nz,l0053h		;0056
	ei			;0059
	ld a,001h		;005a
	out (014h),a		;005c
	ld a,005h		;005e
	ld (08062h),a		;0060
	jp 07218h		;0063
	retn			;0066
l0068h:
	rst 38h			;0068
	ld bc,07800h		;0069
	ld de,0707dh		;006c
	ld hl,l0014h		;006f
	call 07068h		;0072
	jp 073dah		;0075
	ld bc,07800h		;0078
	ld de,070b0h		;007b
	ld hl,l000fh		;007e
	call 07068h		;0081
	jp 073dah		;0084
	ld bc,07800h		;0087
	ld de,07092h		;008a
	ld hl,l001dh		;008d
	call 07068h		;0090
	jp 073dah		;0093
	push hl			;0096
	inc hl			;0097
	ex de,hl		;0098
	ld bc,070c3h		;0099
	ld hl,l0004h		;009c
	call 0705ch		;009f
	pop hl			;00a2
	jp z,0704fh		;00a3
	ret			;00a6
	push hl			;00a7
	inc hl			;00a8
	ex de,hl		;00a9
	ld bc,070c8h		;00aa
	ld hl,l0004h		;00ad
	call 0705ch		;00b0
	pop hl			;00b3
	jp z,0704fh		;00b4
	ret			;00b7
	push hl			;00b8
	inc hl			;00b9
	ld de,l0007h		;00ba
	add hl,de		;00bd
	ld a,(hl)		;00be
	and 03fh		;00bf
	cp 013h			;00c1
	pop hl			;00c3
	ret			;00c4
	ld a,(de)		;00c5
	ld h,a			;00c6
	ld a,(bc)		;00c7
	cp h			;00c8
	ret nz			;00c9
	inc de			;00ca
	inc bc			;00cb
	dec l			;00cc
	jp nz,0705ch		;00cd
	ret			;00d0
	ld a,(de)		;00d1
	ld (bc),a		;00d2
	inc bc			;00d3
	inc de			;00d4
	dec l			;00d5
	jp nz,07068h		;00d6
	ret			;00d9
	jr nz,l012eh		;00da
	ld b,e			;00dc
	scf			;00dd
	jr nc,l0110h		;00de
	jr nz,l0134h		;00e0
	ld b,e			;00e2
	scf			;00e3
	jr nc,$+52		;00e4
	jr nz,l0112h		;00e6
	ld hl,(04f4eh)		;00e8
	jr nz,l0140h		;00eb
	ld e,c			;00ed
	ld d,e			;00ee
	ld d,h			;00ef
	ld b,l			;00f0
	ld c,l			;00f1
	jr nz,$+72		;00f2
	ld c,c			;00f4
	ld c,h			;00f5
	ld b,l			;00f6
	ld d,e			;00f7
	ld hl,(0202ah)		;00f8
	jr nz,$+44		;00fb
	ld hl,(04f4eh)		;00fd
	jr nz,l0146h		;0100
	ld c,c			;0102
	ld d,e			;0103
	ld c,e			;0104
	ld b,l			;0105
	ld d,h			;0106
	ld d,h			;0107
	ld b,l			;0108
	jr nz,l0159h		;0109
	ld c,a			;010b
	ld d,d			;010c
	jr nz,l015bh		;010d
	ld c,c			;010f
l0110h:
	ld c,(hl)		;0110
	ld b,l			;0111
l0112h:
	ld d,b			;0112
	ld d,d			;0113
	ld c,a			;0114
	ld b,a			;0115
	ld hl,(0202ah)		;0116
	jr nz,$+44		;0119
	ld hl,(04f4eh)		;011b
	jr nz,$+77		;011e
	ld b,c			;0120
	ld d,h			;0121
	ld b,c			;0122
	ld c,h			;0123
	ld c,a			;0124
	ld b,a			;0125
	ld hl,(0202ah)		;0126
	ld (bc),a		;0129
	jp 053c8h		;012a
	ld e,c			;012d
l012eh:
	ld d,e			;012e
	ld c,l			;012f
	jr nz,l0185h		;0130
	ld e,c			;0132
	ld d,e			;0133
l0134h:
	ld b,e			;0134
	jr nz,$-59		;0135
	ld h,d			;0137
	ld (hl),e		;0138
	ld sp,0bfffh		;0139
	ld a,073h		;013c
	ld i,a			;013e
l0140h:
	im 2			;0140
	ld c,0ffh		;0142
	ld b,001h		;0144
l0146h:
	call 076b1h		;0146
	ld a,099h		;0149
	call 070e9h		;014b
	ld hl,l0027h		;014e
	jp (hl)			;0151
	push af			;0152
	ld a,002h		;0153
	out (012h),a		;0155
	ld a,004h		;0157
l0159h:
	out (013h),a		;0159
l015bh:
	ld a,04fh		;015b
	out (012h),a		;015d
	ld a,00fh		;015f
	out (013h),a		;0161
	ld a,083h		;0163
	out (012h),a		;0165
	out (013h),a		;0167
	jp 07103h		;0169
	ld a,008h		;016c
	out (00ch),a		;016e
	pop af			;0170
	ld a,046h		;0171
	or 041h			;0173
	out (00ch),a		;0175
	ld a,020h		;0177
	out (00ch),a		;0179
	ld a,046h		;017b
	or 041h			;017d
	out (00dh),a		;017f
	ld a,020h		;0181
	out (00dh),a		;0183
l0185h:
	ld a,0d7h		;0185
	out (00eh),a		;0187
	ld a,001h		;0189
	out (00eh),a		;018b
	ld a,0d7h		;018d
	out (00fh),a		;018f
	ld a,001h		;0191
	out (00fh),a		;0193
	jp 0712fh		;0195
	ld a,020h		;0198
	out (0f8h),a		;019a
	ld a,0c0h		;019c
	out (0fbh),a		;019e
	ld a,000h		;01a0
	out (0fah),a		;01a2
	ld a,04ah		;01a4
	out (0fbh),a		;01a6
	ld a,04bh		;01a8
	out (0fbh),a		;01aa
	jp 07146h		;01ac
	ld a,000h		;01af
	out (001h),a		;01b1
	ld a,04fh		;01b3
	out (000h),a		;01b5
	ld a,098h		;01b7
	out (000h),a		;01b9
	ld a,09ah		;01bb
	out (000h),a		;01bd
	ld a,05dh		;01bf
	out (000h),a		;01c1
	ld a,080h		;01c3
	out (001h),a		;01c5
	xor a			;01c7
	out (000h),a		;01c8
	out (000h),a		;01ca
	ld a,0e0h		;01cc
	out (001h),a		;01ce
	jp 0716eh		;01d0
	inc bc			;01d3
	inc bc			;01d4
	ld c,a			;01d5
	jr nz,$+16		;01d6
	rst 38h			;01d8
	ld b,001h		;01d9
	call 076b1h		;01db
	in a,(004h)		;01de
	and 01fh		;01e0
	jp nz,0716eh		;01e2
	ld hl,0716ah		;01e5
	ld b,(hl)		;01e8
	inc hl			;01e9
	in a,(004h)		;01ea
	and 0c0h		;01ec
	cp 080h			;01ee
	jp nz,07181h		;01f0
	ld a,(hl)		;01f3
	out (005h),a		;01f4
	dec b			;01f6
	jp nz,07180h		;01f7
	jp 07194h		;01fa
	ld hl,l0000h		;01fd
	ex de,hl		;0200
	ld hl,07800h		;0201
	add hl,de		;0204
	ld a,020h		;0205
	ld (hl),a		;0207
	ld a,e			;0208
	cp 0cfh			;0209
	jp z,071a9h		;020b
	inc de			;020e
	jp 07198h		;020f
	ld a,d			;0212
	cp 007h			;0213
	jp z,071b3h		;0215
	inc de			;0218
	jp 07198h		;0219
	ld de,07071h		;021c
	ld hl,l0004h+2		;021f
	ld bc,07800h		;0222
	call 07068h		;0225
	ld hl,l0000h		;0228
	ld (07fd2h),hl		;022b
	ld (07fd9h),hl		;022e
	ld (07fe4h),hl		;0231
	ld (07fe2h),hl		;0234
	ld (07fe0h),hl		;0237
	ld (07fd7h),hl		;023a
	ld (07fdeh),hl		;023d
	ld (07fd5h),hl		;0240
	ld hl,l0780h		;0243
	ld (07fdbh),hl		;0246
	ld a,000h		;0249
	ld (07fd1h),a		;024b
	ld (07fd4h),a		;024e
	ld (07fddh),a		;0251
	ld (07fe6h),a		;0254
	ld a,023h		;0257
	out (001h),a		;0259
	ret			;025b
	xor a			;025c
	ld (08032h),a		;025d
	inc a			;0260
	ld (08033h),a		;0261
	ld (08034h),a		;0264
	call 074cbh		;0267
	jp c,0720bh		;026a
	ld hl,07320h		;026d
	ld a,002h		;0270
	or (hl)			;0272
	ld (hl),a		;0273
	ld hl,08033h		;0274
	dec (hl)		;0277
	call 074cbh		;0278
	ret nc			;027b
	ld a,0fbh		;027c
	jp 072c4h		;027e
	ld b,001h		;0281
	ld c,0ffh		;0283
	call 076b1h		;0285
	call 07672h		;0288
	ld a,(08010h)		;028b
	and 023h		;028e
	ld c,a			;0290
	ld a,(0801bh)		;0291
	add a,020h		;0294
	cp c			;0296
	jp nz,072c4h		;0297
	call 0770bh		;029a
	jp c,072c4h		;029d
	jp z,0723dh		;02a0
	jp 072c4h		;02a3
	call 071f3h		;02a6
	ld a,001h		;02a9
	out (018h),a		;02ab
	ld hl,(08067h)		;02ad
	call 07425h		;02b0
	ld a,(08032h)		;02b3
	or a			;02b6
	jp nz,07257h		;02b7
	call 074cbh		;02ba
	jp 07244h		;02bd
	ld a,001h		;02c0
	ld (08060h),a		;02c2
	call 07262h		;02c5
	jp 07403h		;02c8
	ld a,00ah		;02cb
	ld hl,l0000h		;02cd
	call 072aah		;02d0
	jp z,0727ch		;02d3
	ld a,00bh		;02d6
	call 072aah		;02d8
	jp z,07278h		;02db
	jp 0700fh		;02de
	ld hl,(l0000h)		;02e1
	jp (hl)			;02e4
	ld hl,l0000h		;02e5
	ld de,00b60h		;02e8
	add hl,de		;02eb
	ld de,l0020h		;02ec
	add hl,de		;02ef
	ld bc,00d00h		;02f0
	ld a,b			;02f3
	cp h			;02f4
	jp c,07000h		;02f5
	ld a,(hl)		;02f8
	or a			;02f9
	jp z,07283h		;02fa
	call 0702dh		;02fd
	jp nz,07000h		;0300
	ld de,l0020h		;0303
	add hl,de		;0306
	ld a,(hl)		;0307
	or a			;0308
	jp z,07000h		;0309
	call 0703eh		;030c
	jp nz,07000h		;030f
	ret			;0312
	ld de,00002h		;0313
	add hl,de		;0316
	ex de,hl		;0317
	ld bc,07071h		;0318
	ld hl,l0004h+2		;031b
	cp 00ah			;031e
	jp z,072c0h		;0320
	ld bc,07077h		;0323
	ld hl,l0004h+2		;0326
	call 0705ch		;0329
	ret			;032c
	ld a,00bh		;032d
	ld hl,02000h		;032f
	call 072aah		;0332
	jp z,072d2h		;0335
	jp 0701eh		;0338
	ld hl,(02000h)		;033b
	jp (hl)			;033e
	ld a,(de)		;033f
	rlca			;0340
	inc (hl)		;0341
	rlca			;0342
	rrca			;0343
	ld c,01ah		;0344
	ld c,008h		;0346
	dec de			;0348
	rrca			;0349
	dec de			;034a
	nop			;034b
	nop			;034c
	ex af,af'		;034d
	dec (hl)		;034e
	djnz l0358h		;034f
	jr nz,l035ah		;0351
	add hl,bc		;0353
	ld c,010h		;0354
	ld c,005h		;0356
l0358h:
	dec de			;0358
	add hl,bc		;0359
l035ah:
	dec de			;035a
	nop			;035b
	nop			;035c
	dec b			;035d
	dec (hl)		;035e
	nop			;035f
	nop			;0360
	nop			;0361
	nop			;0362
	nop			;0363
	nop			;0364
	nop			;0365
	nop			;0366
	nop			;0367
	nop			;0368
	add a,073h		;0369
	add a,073h		;036b
	add a,073h		;036d
	add a,073h		;036f
	add a,073h		;0371
	add a,073h		;0373
	cp e			;0375
	ld (hl),e		;0376
	jp nz,0c673h		;0377
	ld (hl),e		;037a
	add a,073h		;037b
	add a,073h		;037d
	add a,073h		;037f
	add a,073h		;0381
	add a,073h		;0383
	add a,073h		;0385
	add a,073h		;0387
	nop			;0389
	nop			;038a
	ld (08065h),hl		;038b
	ld hl,l0000h		;038e
	add hl,sp		;0391
	ld (0801eh),hl		;0392
	push bc			;0395
	ex de,hl		;0396
	ld a,c			;0397
	and 07fh		;0398
	ld (08034h),a		;039a
	ld a,b			;039d
	and 07fh		;039e
	ld (08032h),a		;03a0
	call z,074cbh		;03a3
	ld a,b			;03a6
	and 080h		;03a7
	jp z,07345h		;03a9
	ld a,001h		;03ac
	ld (08033h),a		;03ae
	call 07425h		;03b1
	pop bc			;03b4
	push af			;03b5
	ld a,b			;03b6
	and 07fh		;03b7
	jp nz,0735bh		;03b9
	ld a,001h		;03bc
	ld (08032h),a		;03be
	call 074cbh		;03c1
	pop af			;03c4
	xor a			;03c5
	ld hl,(0801eh)		;03c6
	ld sp,hl		;03c9
	ret			;03ca
	push af			;03cb
	in a,(001h)		;03cc
	push hl			;03ce
	push de			;03cf
	push bc			;03d0
	ld a,006h		;03d1
	out (0fah),a		;03d3
	ld a,007h		;03d5
	out (0fah),a		;03d7
	out (0fch),a		;03d9
	ld hl,(07fd5h)		;03db
	ld de,07800h		;03de
	add hl,de		;03e1
	ld a,l			;03e2
	out (0f4h),a		;03e3
	ld a,h			;03e5
	out (0f4h),a		;03e6
	ld a,l			;03e8
	cpl			;03e9
	ld l,a			;03ea
	ld a,h			;03eb
	cpl			;03ec
	ld h,a			;03ed
	inc hl			;03ee
	ld de,007cfh		;03ef
	add hl,de		;03f2
	ld de,07800h		;03f3
	add hl,de		;03f6
	ld a,l			;03f7
	out (0f5h),a		;03f8
	ld a,h			;03fa
	out (0f5h),a		;03fb
	ld hl,07800h		;03fd
	ld a,l			;0400
	out (0f6h),a		;0401
	ld a,h			;0403
	out (0f6h),a		;0404
	ld hl,007cfh		;0406
	ld a,l			;0409
	out (0f7h),a		;040a
	ld a,h			;040c
	out (0f7h),a		;040d
	ld a,002h		;040f
	out (0fah),a		;0411
	ld a,003h		;0413
	out (0fah),a		;0415
	pop bc			;0417
	pop de			;0418
	pop hl			;0419
	ld a,0d7h		;041a
	out (00eh),a		;041c
	ld a,001h		;041e
	out (00eh),a		;0420
	pop af			;0422
	ret			;0423
	di			;0424
	call 07362h		;0425
	ei			;0428
	reti			;0429
	di			;042b
	jp 07770h		;042c
	ei			;042f
	reti			;0430
	ld (08003h),a		;0432
	ei			;0435
	ld a,(08060h)		;0436
	and 001h		;0439
	jp nz,0735dh		;043b
	out (01ch),a		;043e
	call 073deh		;0440
	or a			;0443
	jp 073dah		;0444
	ld bc,07800h		;0447
	ld de,073f0h		;044a
	ld hl,l0012h		;044d
	ld a,(de)		;0450
	ld (bc),a		;0451
	inc bc			;0452
	inc de			;0453
	dec l			;0454
	jp nz,073e7h		;0455
	ret			;0458
	ld hl,(0442ah)		;0459
	ld c,c			;045c
	ld d,e			;045d
	ld c,e			;045e
	ld b,l			;045f
	ld d,h			;0460
	ld d,h			;0461
	ld b,l			;0462
	jr nz,$+71		;0463
	ld d,d			;0465
	ld d,d			;0466
	ld c,a			;0467
	ld d,d			;0468
	ld hl,(0202ah)		;0469
	ld a,(07320h)		;046c
	and 080h		;046f
	ld hl,08060h		;0471
	or (hl)			;0474
	ld (hl),a		;0475
	dec (hl)		;0476
	call 074cbh		;0477
	ld hl,l0000h		;047a
	ld (08065h),hl		;047d
	ld hl,07300h		;0480
	call 07425h		;0483
	ld a,001h		;0486
	ld (08060h),a		;0488
	jp 01000h		;048b
	ld a,000h		;048e
	ld (08069h),hl		;0490
	call 07721h		;0493
	jp c,072c4h		;0496
	jp z,07438h		;0499
	ld a,006h		;049c
	jp 073c9h		;049e
	call 07481h		;04a1
	ld a,006h		;04a4
	ld c,005h		;04a6
	call 07583h		;04a8
	jp nc,0744ah		;04ab
	ld a,028h		;04ae
	jp 073c9h		;04b0
	ld hl,(08067h)		;04b3
	ex de,hl		;04b6
	ld hl,(08065h)		;04b7
	add hl,de		;04ba
	ld (08065h),hl		;04bb
	ld l,000h		;04be
	ld h,l			;04c0
	ld (08067h),hl		;04c1
	call 07466h		;04c4
	ld a,(08061h)		;04c7
	or a			;04ca
	ret z			;04cb
	jp 0742ah		;04cc
	ld a,001h		;04cf
	ld (08034h),a		;04d1
	ld a,(07320h)		;04d4
	and 002h		;04d7
	rrca			;04d9
	ld hl,08033h		;04da
	cp (hl)			;04dd
	jp z,0747ah		;04de
	inc (hl)		;04e1
	ret			;04e2
	xor a			;04e3
	ld (hl),a		;04e4
	ld hl,08032h		;04e5
	inc (hl)		;04e8
	ret			;04e9
	ld hl,(08069h)		;04ea
	push hl			;04ed
	call 07547h		;04ee
	call 074aeh		;04f1
	pop de			;04f4
	add hl,de		;04f5
	jp nc,0749eh		;04f6
	ld a,h			;04f9
	or l			;04fa
	jp z,0749eh		;04fb
	ld a,001h		;04fe
	ld (08061h),a		;0500
	ld (08069h),hl		;0503
	ret			;0506
	ld a,000h		;0507
	ld (08061h),a		;0509
	ld (08069h),a		;050c
	ld (0806ah),a		;050f
	ex de,hl		;0512
	ld (08067h),hl		;0513
	ret			;0516
	push af			;0517
	ld a,l			;0518
	cpl			;0519
	ld l,a			;051a
	ld a,h			;051b
	cpl			;051c
	ld h,a			;051d
	inc hl			;051e
	pop af			;051f
	ret			;0520
	ld a,(07320h)		;0521
	and 01ch		;0524
	rra			;0526
	rra			;0527
	and 007h		;0528
	ld (08035h),a		;052a
	call 0750ah		;052d
	call 07547h		;0530
	ret			;0533
	ld a,(07320h)		;0534
	and 0feh		;0537
	ld (07320h),a		;0539
	call 07721h		;053c
	jp nz,07508h		;053f
	ld l,004h		;0542
	ld h,000h		;0544
	ld (08067h),hl		;0546
	ld a,00ah		;0549
	ld c,001h		;054b
	call 07583h		;054d
	ld hl,07320h		;0550
	jp nc,074f7h		;0553
	ld a,(hl)		;0556
	and 001h		;0557
	jp nz,07508h		;0559
	inc (hl)		;055c
	jp 074d3h		;055d
	ld a,(08016h)		;0560
	rlca			;0563
	rlca			;0564
	ld b,a			;0565
	ld a,(hl)		;0566
	and 0e3h		;0567
	add a,b			;0569
	ld (hl),a		;056a
	call 074b8h		;056b
	scf			;056e
	ccf			;056f
	ret			;0570
	scf			;0571
	ret			;0572
	ld a,(08035h)		;0573
	rla			;0576
	rla			;0577
	ld e,a			;0578
	ld d,000h		;0579
	ld hl,072d6h		;057b
	ld a,(07320h)		;057e
	and 080h		;0581
	ld a,04ch		;0583
	jp z,07524h		;0585
	ld a,023h		;0588
	ld hl,072e6h		;058a
	ld (0800ch),a		;058d
	add hl,de		;0590
	ld a,(07320h)		;0591
	and 001h		;0594
	jp z,07535h		;0596
	ld e,002h		;0599
	ld d,000h		;059b
	add hl,de		;059d
	ex de,hl		;059e
	ld hl,08036h		;059f
	ld a,(de)		;05a2
	ld (hl),a		;05a3
	ld (0800dh),a		;05a4
	inc hl			;05a7
	inc de			;05a8
	ld a,(de)		;05a9
	ld (hl),a		;05aa
	inc hl			;05ab
	ld a,080h		;05ac
	ld (hl),a		;05ae
	ret			;05af
	ld hl,00080h		;05b0
	ld a,(08035h)		;05b3
	or a			;05b6
	jp z,07556h		;05b7
	add hl,hl		;05ba
	dec a			;05bb
	jp nz,07551h		;05bc
	ld (08039h),hl		;05bf
	ex de,hl		;05c2
	ld a,(08034h)		;05c3
	ld l,a			;05c6
	ld a,(08036h)		;05c7
	sub l			;05ca
	inc a			;05cb
	ld l,a			;05cc
	ld a,(08060h)		;05cd
	and 080h		;05d0
	jp z,07576h		;05d2
	ld a,(08033h)		;05d5
	xor 001h		;05d8
	jp nz,07576h		;05da
	ld l,00ah		;05dd
	ld a,l			;05df
	ld l,000h		;05e0
	ld h,l			;05e2
	add hl,de		;05e3
	dec a			;05e4
	jp nz,0757ah		;05e5
	ld (08067h),hl		;05e8
	ret			;05eb
	push af			;05ec
	ld a,c			;05ed
	ld (08062h),a		;05ee
	call 0769dh		;05f1
	ld hl,(08067h)		;05f4
	ld b,h			;05f7
	ld c,l			;05f8
	dec bc			;05f9
	ld hl,(08065h)		;05fa
	pop af			;05fd
	push af			;05fe
	and 00fh		;05ff
	cp 00ah			;0601
	call nz,07632h		;0603
	pop af			;0606
	ld c,a			;0607
	call 075ddh		;0608
	ld a,0ffh		;060b
	call 076c3h		;060d
	ret c			;0610
	ld a,c			;0611
	call 075b3h		;0612
	ret nc			;0615
	ret z			;0616
	ld a,c			;0617
	push af			;0618
	jp 07588h		;0619
	ld hl,08010h		;061c
	ld a,(hl)		;061f
	and 0c3h		;0620
	ld b,a			;0622
	ld a,(0801bh)		;0623
	cp b			;0626
	jp nz,075d4h		;0627
	inc hl			;062a
	ld a,(hl)		;062b
	cp 000h			;062c
	jp nz,075d4h		;062e
	inc hl			;0631
	ld a,(hl)		;0632
	and 0bfh		;0633
	cp 000h			;0635
	jp nz,075d4h		;0637
	scf			;063a
	ccf			;063b
	ret			;063c
	ld a,(08062h)		;063d
	dec a			;0640
	ld (08062h),a		;0641
	scf			;0644
	ret			;0645
	push bc			;0646
	push af			;0647
	di			;0648
	ld a,0ffh		;0649
	ld hl,08030h		;064b
	ld (0800bh),a		;064e
	ld a,(07320h)		;0651
	and 001h		;0654
	jp z,075f2h		;0656
	ld a,040h		;0659
	ld b,a			;065b
	pop af			;065c
	push af			;065d
	add a,b			;065e
	ld (hl),a		;065f
	inc hl			;0660
	call 076a4h		;0661
	ld (hl),a		;0664
	dec hl			;0665
	pop af			;0666
	and 00fh		;0667
	cp 006h			;0669
	ld c,009h		;066b
	jp z,07609h		;066d
	ld c,002h		;0670
	ld a,(hl)		;0672
	inc hl			;0673
	call 0763ch		;0674
	dec c			;0677
	jp nz,07609h		;0678
	pop bc			;067b
	ei			;067c
	ret			;067d
	ld a,005h		;067e
	di			;0680
	out (0fah),a		;0681
	ld a,049h		;0683
	out (0fbh),a		;0685
	out (0fch),a		;0687
	ld a,l			;0689
	out (0f2h),a		;068a
	ld a,h			;068c
	out (0f2h),a		;068d
	ld a,c			;068f
	out (0f3h),a		;0690
	ld a,b			;0692
	out (0f3h),a		;0693
	ld a,001h		;0695
	out (0fah),a		;0697
	ei			;0699
	ret			;069a
	ld a,005h		;069b
	di			;069d
	out (0fah),a		;069e
	ld a,045h		;06a0
	jp 0761ch		;06a2
	push af			;06a5
	push bc			;06a6
	ld b,000h		;06a7
	ld c,000h		;06a9
	inc b			;06ab
	call z,0766ah		;06ac
	in a,(004h)		;06af
	and 0c0h		;06b1
	cp 080h			;06b3
	jp nz,07642h		;06b5
	pop bc			;06b8
	pop af			;06b9
	out (005h),a		;06ba
	ret			;06bc
	push bc			;06bd
	ld b,000h		;06be
	ld c,000h		;06c0
	inc b			;06c2
	call z,0766ah		;06c3
	in a,(004h)		;06c6
	and 0c0h		;06c8
	cp 0c0h			;06ca
	jp nz,07659h		;06cc
	pop bc			;06cf
	in a,(005h)		;06d0
	ret			;06d2
	ld b,000h		;06d3
	inc c			;06d5
	ret nz			;06d6
	ei			;06d7
	jp 072c4h		;06d8
	ld a,004h		;06db
	call 0763ch		;06dd
	ld a,(0801bh)		;06e0
	call 0763ch		;06e3
	call 07654h		;06e6
	ld (08010h),a		;06e9
	ret			;06ec
	ld a,008h		;06ed
	call 0763ch		;06ef
	call 07654h		;06f2
	ld (08010h),a		;06f5
	and 0c0h		;06f8
	cp 080h			;06fa
	jp z,0769ch		;06fc
	call 07654h		;06ff
	ld (08011h),a		;0702
	ret			;0705
	di			;0706
	xor a			;0707
	ld (08041h),a		;0708
	ei			;070b
	ret			;070c
	push de			;070d
	ld a,(08033h)		;070e
	rla			;0711
	rla			;0712
	ld d,a			;0713
	ld a,(0801bh)		;0714
	add a,d			;0717
	pop de			;0718
	ret			;0719
	push af			;071a
	push hl			;071b
	ld h,c			;071c
	ld l,0ffh		;071d
	dec hl			;071f
	ld a,l			;0720
	or h			;0721
	jp nz,076b6h		;0722
	dec b			;0725
	jp nz,076b3h		;0726
	pop hl			;0729
	pop af			;072a
	ret			;072b
	push bc			;072c
	dec a			;072d
	scf			;072e
	jp z,076dfh		;072f
	ld b,001h		;0732
	ld c,001h		;0734
	call 076b1h		;0736
	ld b,a			;0739
	ld a,(08041h)		;073a
	and 002h		;073d
	ld a,b			;073f
	jp z,076c4h		;0740
	scf			;0743
	ccf			;0744
	call 0769dh		;0745
	pop bc			;0748
	ret			;0749
	ld a,0ffh		;074a
	call 076c3h		;074c
	ld a,(08010h)		;074f
	ld b,a			;0752
	ld a,(08011h)		;0753
	ld c,a			;0756
	ret			;0757
	ld a,007h		;0758
	call 0763ch		;075a
	ld a,(0801bh)		;075d
	call 0763ch		;0760
	ret			;0763
	ld a,00fh		;0764
	call 0763ch		;0766
	ld a,d			;0769
	and 007h		;076a
	call 0763ch		;076c
	ld a,e			;076f
	call 0763ch		;0770
	ret			;0773
	call 076efh		;0774
	call 076e1h		;0777
	ret c			;077a
	ld a,(0801bh)		;077b
	add a,020h		;077e
l0780h:
	cp b			;0780
	jp nz,0771eh		;0781
	ld a,c			;0784
	cp 000h			;0785
	scf			;0787
	ccf			;0788
	ret			;0789
	ld a,(08032h)		;078a
	ld e,a			;078d
	call 076a4h		;078e
	ld d,a			;0791
	call 076fbh		;0792
	call 076e1h		;0795
l0798h:
	ret c			;0798
	ld a,(0801bh)		;0799
	add a,020h		;079c
	cp b			;079e
	jp nz,0773dh		;079f
	ld a,(08032h)		;07a2
	cp c			;07a5
	scf			;07a6
	ccf			;07a7
	ret			;07a8
	ld hl,08010h		;07a9
	ld b,007h		;07ac
	ld a,b			;07ae
	ld (0800bh),a		;07af
	call 07654h		;07b2
	ld (hl),a		;07b5
	inc hl			;07b6
	ld a,(0801dh)		;07b7
	dec a			;07ba
	jp nz,07751h		;07bb
	in a,(004h)		;07be
	and 010h		;07c0
	jp z,07765h		;07c2
	dec b			;07c5
	jp nz,07749h		;07c6
	ld a,0feh		;07c9
	jp 073c9h		;07cb
	in a,(0f8h)		;07ce
	ld (hl),a		;07d0
	dec b			;07d1
	ret z			;07d2
	ei			;07d3
	ld a,0fdh		;07d4
	jp 073c9h		;07d6
	push af			;07d9
	push bc			;07da
	push hl			;07db
	ld a,002h		;07dc
	ld (08041h),a		;07de
	ld a,(0801ch)		;07e1
	dec a			;07e4
	jp nz,0777bh		;07e5
	in a,(004h)		;07e8
	and 010h		;07ea
	jp nz,0778ch		;07ec
	call 07684h		;07ef
	jp 0778fh		;07f2
	call 07740h		;07f5
	pop hl			;07f8
	pop bc			;07f9
	pop af			;07fa
	ei			;07fb
	reti			;07fc
	nop			;07fe
	nop			;07ff
