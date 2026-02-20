; z80dasm 1.2.0
; command line: z80dasm -a -l -g 0xE200 -o compas_bios.asm compas_bios.bin

	org 0e200h

	jp le2f8h		;e200
le203h:
	jp le328h		;e203
	jp le4f3h		;e206
	jp le4f7h		;e209
	jp le961h		;e20c
	jp le3ach		;e20f
	jp le3ffh		;e212
	jp le3efh		;e215
	jp lf1bfh		;e218
	jp lee9eh		;e21b
	jp lef18h		;e21e
	jp lef1eh		;e221
	jp lef23h		;e224
	jp lef2ch		;e227
	jp lef3ch		;e22a
	jp le3a8h		;e22d
	jp lef29h		;e230
le233h:
	nop			;e233
le234h:
	jr nz,le256h		;e234
	nop			;e236
le237h:
	ex af,af'		;e237
	ex af,af'		;e238
	nop			;e239
	nop			;e23a
	nop			;e23b
	nop			;e23c
	nop			;e23d
	nop			;e23e
	nop			;e23f
	nop			;e240
	nop			;e241
	nop			;e242
	nop			;e243
	nop			;e244
	nop			;e245
	nop			;e246
	nop			;e247
	nop			;e248
	nop			;e249
	jp lf276h		;e24a
	jp le3ebh		;e24d
	jp le2c0h		;e250
	jp le29fh		;e253
le256h:
	jp le2ach		;e256
	nop			;e259
	nop			;e25a
	nop			;e25b
le25ch:
	dec c			;e25c
	ld a,(bc)		;e25d
	ld b,h			;e25e
	ld c,c			;e25f
	ld d,e			;e260
	ld c,e			;e261
	ld b,l			;e262
	ld d,h			;e263
	ld d,h			;e264
	ld b,l			;e265
	jr nz,$+84		;e266
	ld b,l			;e268
	ld b,c			;e269
	ld b,h			;e26a
	jr nz,$+71		;e26b
	ld d,d			;e26d
	ld d,d			;e26e
	ld c,a			;e26f
	ld d,d			;e270
	dec c			;e271
	ld a,(bc)		;e272
	nop			;e273
le274h:
	inc c			;e274
	dec (hl)		;e275
	jr c,le2c3h		;e276
	jr nz,$+69		;e278
	ld d,b			;e27a
	cpl			;e27b
	ld c,l			;e27c
	jr nz,$+88		;e27d
	ld b,l			;e27f
	ld d,d			;e280
	ld d,e			;e281
	jr nz,$+52		;e282
	ld l,032h		;e284
	dec c			;e286
	ld a,(bc)		;e287
	nop			;e288
le289h:
	ld a,(hl)		;e289
	or a			;e28a
	ret z			;e28b
	push hl			;e28c
	ld c,a			;e28d
	call le961h		;e28e
	pop hl			;e291
	inc hl			;e292
	jp le289h		;e293
le296h:
	ld hl,le25ch		;e296
	call le289h		;e299
le29ch:
	jp le29ch		;e29c
le29fh:
	ld a,0c3h		;e29f
	ld (0ffe5h),a		;e2a1
	ld (0ffe6h),hl		;e2a4
	ex de,hl		;e2a7
	ld (0ffdfh),hl		;e2a8
	ret			;e2ab
le2ach:
	or a			;e2ac
	jp z,le2b8h		;e2ad
	ld de,(0fffch)		;e2b0
	ld hl,(0fffeh)		;e2b4
	ret			;e2b7
le2b8h:
	ld (0fffch),de		;e2b8
	ld (0fffeh),hl		;e2bc
	ret			;e2bf
le2c0h:
	add a,00ah		;e2c0
	ld c,a			;e2c2
le2c3h:
	ld d,005h		;e2c3
	ld a,000h		;e2c5
	call sub_e2f1h		;e2c7
	dec b			;e2ca
	ret m			;e2cb
	sla b			;e2cc
	or b			;e2ce
	call sub_e2f1h		;e2cf
	or 080h			;e2d2
	call sub_e2f1h		;e2d4
	ld hl,00002h		;e2d7
	call sub_f1b3h		;e2da
	ld a,c			;e2dd
	cp 00ah			;e2de
	ld a,(le3a4h)		;e2e0
	jp z,le2e9h		;e2e3
	ld a,(le3a6h)		;e2e6
le2e9h:
	and 020h		;e2e9
	jp z,sub_e2f1h		;e2eb
	ld a,0ffh		;e2ee
	ret			;e2f0
sub_e2f1h:
	di			;e2f1
	out (c),d		;e2f2
	out (c),a		;e2f4
	ei			;e2f6
	ret			;e2f7
le2f8h:
	ld sp,00080h		;e2f8
	ld hl,le274h		;e2fb
	call le289h		;e2fe
	xor a			;e301
	ld (00004h),a		;e302
	ld (leb48h),a		;e305
	ld (leb50h),a		;e308
	ld (leb48h+1),a		;e30b
	in a,(014h)		;e30e
	and 080h		;e310
	jp z,le328h		;e312
	ld c,001h		;e315
	call lee9eh		;e317
	call lf1bfh		;e31a
	ld a,b			;e31d
	and 010h		;e31e
	ld a,000h		;e320
	jr nz,le325h		;e322
	inc a			;e324
le325h:
	ld (lee8ch),a		;e325
le328h:
	ei			;e328
	ld c,000h		;e329
	call lee9eh		;e32b
	xor a			;e32e
	ld (leb48h+2),a		;e32f
	ld (00003h),a		;e332
	ld (lee8ch+1),a		;e335
	ld (le4f1h),a		;e338
	call lf1bfh		;e33b
	ld sp,00080h		;e33e
	ld bc,0cc00h		;e341
	call lef23h		;e344
	ld b,000h		;e347
	ld c,001h		;e349
	call lef18h		;e34b
	ld c,000h		;e34e
	call lef1eh		;e350
le353h:
	push bc			;e353
	call lef2ch		;e354
	or a			;e357
	jp nz,le296h		;e358
	ld hl,(leb54h)		;e35b
	ld de,00080h		;e35e
	add hl,de		;e361
	ld b,h			;e362
	ld c,l			;e363
	call lef23h		;e364
	pop bc			;e367
	inc c			;e368
	call lef1eh		;e369
	ld a,c			;e36c
	cp 02ch			;e36d
	jp nz,le353h		;e36f
	ld bc,00080h		;e372
	call lef23h		;e375
	di			;e378
	ld a,0c3h		;e379
	ld (00000h),a		;e37b
	ld hl,le203h		;e37e
	ld (00001h),hl		;e381
	ld (00005h),a		;e384
	ld hl,0d406h		;e387
	ld (00006h),hl		;e38a
	ld a,(00004h)		;e38d
	or a			;e390
	ld c,a			;e391
	ld a,(lee8ch)		;e392
	cp c			;e395
	jp nc,le39bh		;e396
	ld c,000h		;e399
le39bh:
	ei			;e39b
	jp 0cc00h		;e39c
le39fh:
	rst 38h			;e39f
le3a0h:
	rst 38h			;e3a0
le3a1h:
	rst 38h			;e3a1
le3a2h:
	nop			;e3a2
le3a3h:
	nop			;e3a3
le3a4h:
	nop			;e3a4
le3a5h:
	nop			;e3a5
le3a6h:
	nop			;e3a6
le3a7h:
	nop			;e3a7
le3a8h:
	ld a,(le39fh)		;e3a8
	ret			;e3ab
le3ach:
	ld a,(le39fh)		;e3ac
	or a			;e3af
	jp z,le3ach		;e3b0
	di			;e3b3
	ld a,000h		;e3b4
	ld (le39fh),a		;e3b6
	ld a,005h		;e3b9
	out (00bh),a		;e3bb
	ld a,(le234h+1)		;e3bd
	add a,08ah		;e3c0
	out (00bh),a		;e3c2
	ld a,001h		;e3c4
	out (00bh),a		;e3c6
	ld a,007h		;e3c8
	out (00bh),a		;e3ca
	ld a,c			;e3cc
	out (009h),a		;e3cd
	ei			;e3cf
	ret			;e3d0
sub_e3d1h:
	di			;e3d1
	xor a			;e3d2
	ld (le3a0h),a		;e3d3
	ld a,005h		;e3d6
	out (00ah),a		;e3d8
	ld a,(le234h)		;e3da
	add a,08ah		;e3dd
	out (00ah),a		;e3df
	ld a,001h		;e3e1
	out (00ah),a		;e3e3
	ld a,01bh		;e3e5
	out (00ah),a		;e3e7
	ei			;e3e9
	ret			;e3ea
le3ebh:
	ld a,(le3a0h)		;e3eb
	ret			;e3ee
le3efh:
	call le3ebh		;e3ef
	or a			;e3f2
	jp z,le3efh		;e3f3
	ld a,(le3a2h)		;e3f6
	push af			;e3f9
	call sub_e3d1h		;e3fa
	pop af			;e3fd
	ret			;e3fe
le3ffh:
	ld a,(le3a1h)		;e3ff
	or a			;e402
	jp z,le3ffh		;e403
	di			;e406
	ld a,000h		;e407
	ld (le3a1h),a		;e409
	ld a,005h		;e40c
	out (00ah),a		;e40e
	ld a,(le234h)		;e410
	add a,08ah		;e413
	out (00ah),a		;e415
	ld a,001h		;e417
	out (00ah),a		;e419
	ld a,01bh		;e41b
	out (00ah),a		;e41d
	ld a,c			;e41f
	out (008h),a		;e420
	ei			;e422
	ret			;e423
	ld (lee9ch),sp		;e424
	ld sp,lf620h		;e428
	push af			;e42b
	ld a,028h		;e42c
	out (00bh),a		;e42e
	ld a,0ffh		;e430
	ld (le39fh),a		;e432
	pop af			;e435
	ld sp,(lee9ch)		;e436
	ei			;e43a
	reti			;e43b
sub_e43dh:
	ld (lee9ch),sp		;e43d
	ld sp,lf620h		;e441
	push af			;e444
	in a,(00bh)		;e445
	ld (le3a6h),a		;e447
	ld a,010h		;e44a
	out (00bh),a		;e44c
	pop af			;e44e
	ld sp,(lee9ch)		;e44f
	ei			;e453
	reti			;e454
	ld (lee9ch),sp		;e456
	ld sp,lf620h		;e45a
	push af			;e45d
	in a,(008h)		;e45e
	ld (le3a3h),a		;e460
	pop af			;e463
	ld sp,(lee9ch)		;e464
	ei			;e468
	reti			;e469
sub_e46bh:
	ld (lee9ch),sp		;e46b
	ld sp,lf620h		;e46f
	push af			;e472
	ld a,001h		;e473
	out (00bh),a		;e475
	in a,(00bh)		;e477
	ld (le3a7h),a		;e479
	ld a,030h		;e47c
	out (00bh),a		;e47e
	pop af			;e480
	ld sp,(lee9ch)		;e481
	ei			;e485
	reti			;e486
	ld (lee9ch),sp		;e488
	ld sp,lf620h		;e48c
	push af			;e48f
	ld a,028h		;e490
	out (00ah),a		;e492
	ld a,0ffh		;e494
	ld (le3a1h),a		;e496
	pop af			;e499
	ld sp,(lee9ch)		;e49a
	ei			;e49e
	reti			;e49f
sub_e4a1h:
	ld (lee9ch),sp		;e4a1
	ld sp,lf620h		;e4a5
	push af			;e4a8
	in a,(00ah)		;e4a9
	ld (le3a4h),a		;e4ab
	ld a,010h		;e4ae
	out (00ah),a		;e4b0
	pop af			;e4b2
	ld sp,(lee9ch)		;e4b3
	ei			;e4b7
	reti			;e4b8
	ld (lee9ch),sp		;e4ba
	ld sp,lf620h		;e4be
	push af			;e4c1
	in a,(008h)		;e4c2
	ld (le3a2h),a		;e4c4
	ld a,0ffh		;e4c7
	ld (le3a0h),a		;e4c9
	pop af			;e4cc
	ld sp,(lee9ch)		;e4cd
	ei			;e4d1
	reti			;e4d2
sub_e4d4h:
	ld (lee9ch),sp		;e4d4
	ld sp,lf620h		;e4d8
	push af			;e4db
	ld a,001h		;e4dc
	out (00ah),a		;e4de
	in a,(00ah)		;e4e0
	ld (le3a5h),a		;e4e2
	ld a,030h		;e4e5
	out (00ah),a		;e4e7
	pop af			;e4e9
	ld sp,(lee9ch)		;e4ea
	ei			;e4ee
	reti			;e4ef
le4f1h:
	nop			;e4f1
le4f2h:
	nop			;e4f2
le4f3h:
	ld a,(le4f1h)		;e4f3
	ret			;e4f6
le4f7h:
	ld a,(le4f1h)		;e4f7
	or a			;e4fa
	jp z,le4f7h		;e4fb
	di			;e4fe
	xor a			;e4ff
	ld (le4f1h),a		;e500
	ei			;e503
	in a,(010h)		;e504
	ld c,a			;e506
	ld hl,lf700h		;e507
	call sub_e558h		;e50a
	ret			;e50d
	ld (lee9ch),sp		;e50e
	ld sp,lf620h		;e512
	push af			;e515
	ld a,0ffh		;e516
	ld (le4f1h),a		;e518
	pop af			;e51b
	ld sp,(lee9ch)		;e51c
	ei			;e520
	reti			;e521
	ld (lee9ch),sp		;e523
	ld sp,lf620h		;e527
	push af			;e52a
	ld a,0ffh		;e52b
	ld (le4f2h),a		;e52d
	pop af			;e530
	ld sp,(lee9ch)		;e531
	ei			;e535
	reti			;e536
le538h:
	nop			;e538
le539h:
	nop			;e539
	nop			;e53a
sub_e53bh:
	ld a,h			;e53b
	cpl			;e53c
	ld h,a			;e53d
	ld a,l			;e53e
	cpl			;e53f
	ld l,a			;e540
	ret			;e541
sub_e542h:
	call sub_e53bh		;e542
	inc hl			;e545
	ret			;e546
sub_e547h:
	ld hl,(0ffd2h)		;e547
	ld a,l			;e54a
	cp 080h			;e54b
	ret nz			;e54d
	ld a,h			;e54e
	cp 007h			;e54f
	ret			;e551
sub_e552h:
	ld a,(le538h)		;e552
	or a			;e555
	ld a,c			;e556
	ret nz			;e557
sub_e558h:
	ld b,000h		;e558
	add hl,bc		;e55a
	ld a,(hl)		;e55b
	ret			;e55c
le55dh:
	push af			;e55d
	ld a,080h		;e55e
	out (001h),a		;e560
	ld a,(0ffd1h)		;e562
	out (000h),a		;e565
	ld a,(0ffd4h)		;e567
	out (000h),a		;e56a
	pop af			;e56c
	ret			;e56d
le56eh:
	ld hl,(0ffd2h)		;e56e
	ld de,00050h		;e571
	add hl,de		;e574
	ld (0ffd2h),hl		;e575
	ld hl,0ffd4h		;e578
	inc (hl)		;e57b
	jp le55dh		;e57c
le57fh:
	ld hl,(0ffd2h)		;e57f
	ld de,0ffb0h		;e582
	add hl,de		;e585
	ld (0ffd2h),hl		;e586
	ld hl,0ffd4h		;e589
	dec (hl)		;e58c
	jp le55dh		;e58d
sub_e590h:
	ld hl,00000h		;e590
	ld (0ffd2h),hl		;e593
	xor a			;e596
	ld (0ffd1h),a		;e597
	ld (0ffd4h),a		;e59a
	ret			;e59d
le59eh:
	cp b			;e59e
	ret c			;e59f
	sub b			;e5a0
	jp le59eh		;e5a1
le5a4h:
	ld hl,(0ffd5h)		;e5a4
	ld d,h			;e5a7
	ld e,l			;e5a8
	inc de			;e5a9
	ld bc,0004fh		;e5aa
	ld (hl),020h		;e5ad
	ldir			;e5af
	ld a,(0ffdbh)		;e5b1
	cp 000h			;e5b4
	ret z			;e5b6
	ld hl,(0ffdch)		;e5b7
	ld d,h			;e5ba
	ld e,l			;e5bb
	inc de			;e5bc
	ld bc,00009h		;e5bd
	ld (hl),000h		;e5c0
	ldir			;e5c2
	ret			;e5c4
le5c5h:
	ld hl,0f850h		;e5c5
	ld de,0f800h		;e5c8
	ld bc,00780h		;e5cb
	ldir			;e5ce
	ld hl,0ff80h		;e5d0
	ld (0ffd5h),hl		;e5d3
	ld a,(0ffdbh)		;e5d6
	cp 000h			;e5d9
	jp z,le5a4h		;e5db
	ld hl,lf50ah		;e5de
	ld de,0f500h		;e5e1
	ld bc,000f0h		;e5e4
	ldir			;e5e7
	ld hl,lf5f0h		;e5e9
	ld (0ffdch),hl		;e5ec
	jp le5a4h		;e5ef
sub_e5f2h:
	ld a,000h		;e5f2
	ld b,003h		;e5f4
le5f6h:
	srl h			;e5f6
	rr l			;e5f8
	rra			;e5fa
	dec b			;e5fb
	jp nz,le5f6h		;e5fc
	cp 000h			;e5ff
	ret z			;e601
	ld b,005h		;e602
le604h:
	rra			;e604
	dec b			;e605
	jp nz,le604h		;e606
	ret			;e609
sub_e60ah:
	ld de,0f500h		;e60a
	add hl,de		;e60d
	cp 000h			;e60e
	ld b,a			;e610
	ld a,000h		;e611
	jp nz,le619h		;e613
	and (hl)		;e616
	ld (hl),a		;e617
	ret			;e618
le619h:
	scf			;e619
	rla			;e61a
	dec b			;e61b
	jp nz,le619h		;e61c
	and (hl)		;e61f
	ld (hl),a		;e620
	ret			;e621
le622h:
	ld a,000h		;e622
	cp c			;e624
	jp z,le62bh		;e625
le628h:
	ldir			;e628
	ret			;e62a
le62bh:
	cp b			;e62b
	jp nz,le628h		;e62c
	ret			;e62f
sub_e630h:
	ld a,000h		;e630
	cp c			;e632
	jp z,le639h		;e633
le636h:
	lddr			;e636
	ret			;e638
le639h:
	cp b			;e639
	jp nz,le636h		;e63a
	ret			;e63d
	out (01ch),a		;e63e
	ret			;e640
	call sub_e590h		;e641
	ld a,002h		;e644
	ld (0ffd7h),a		;e646
	ret			;e649
	ret			;e64a
	ld a,000h		;e64b
	ld (0ffd1h),a		;e64d
	jp le55dh		;e650
	ld hl,0ffcfh		;e653
	ld de,0ffceh		;e656
	ld bc,007cfh		;e659
	ld (hl),020h		;e65c
	lddr			;e65e
	call sub_e590h		;e660
	call le55dh		;e663
	ld a,(0ffdbh)		;e666
	cp 000h			;e669
	ret z			;e66b
	xor a			;e66c
	ld (0ffdbh),a		;e66d
	ld hl,lf5f9h		;e670
	ld de,lf5f8h		;e673
	ld bc,000f9h		;e676
	ld (hl),000h		;e679
	lddr			;e67b
	ret			;e67d
	ld de,0f800h		;e67e
	ld hl,(0ffd2h)		;e681
	add hl,de		;e684
	ld de,0004fh		;e685
	add hl,de		;e688
	ld d,h			;e689
	ld e,l			;e68a
	dec de			;e68b
	ld bc,00000h		;e68c
	ld a,(0ffd1h)		;e68f
	cpl			;e692
	inc a			;e693
	add a,04fh		;e694
	ld c,a			;e696
	ld (hl),020h		;e697
	call sub_e630h		;e699
	ld a,(0ffdbh)		;e69c
	cp 000h			;e69f
	ret z			;e6a1
	ld hl,(0ffd2h)		;e6a2
	ld d,000h		;e6a5
	ld a,(0ffd1h)		;e6a7
	ld e,a			;e6aa
	add hl,de		;e6ab
	call sub_e5f2h		;e6ac
	call sub_e60ah		;e6af
	ld a,(0ffd1h)		;e6b2
	srl a			;e6b5
	srl a			;e6b7
	srl a			;e6b9
	cpl			;e6bb
	add a,009h		;e6bc
	ret m			;e6be
	ld c,a			;e6bf
	ld b,000h		;e6c0
	inc hl			;e6c2
	ld d,h			;e6c3
	ld e,l			;e6c4
	inc de			;e6c5
	ld a,000h		;e6c6
	jp le622h		;e6c8
	ld hl,(0ffd2h)		;e6cb
	ld a,(0ffd1h)		;e6ce
	ld c,a			;e6d1
	ld b,000h		;e6d2
	add hl,bc		;e6d4
	call sub_e542h		;e6d5
	ld de,007cfh		;e6d8
	add hl,de		;e6db
	ld b,h			;e6dc
	ld c,l			;e6dd
	ld hl,0ffcfh		;e6de
	ld de,0ffceh		;e6e1
	ld (hl),020h		;e6e4
	call sub_e630h		;e6e6
	ld a,(0ffdbh)		;e6e9
	cp 000h			;e6ec
	ret z			;e6ee
	ld hl,(0ffd2h)		;e6ef
	ld d,000h		;e6f2
	ld a,(0ffd1h)		;e6f4
	ld e,a			;e6f7
	add hl,de		;e6f8
	call sub_e5f2h		;e6f9
	call sub_e60ah		;e6fc
	call sub_e53bh		;e6ff
	ld de,lf5f9h		;e702
	add hl,de		;e705
	ld a,080h		;e706
	and h			;e708
	ret nz			;e709
	ld b,h			;e70a
	ld c,l			;e70b
	ld h,d			;e70c
	ld l,e			;e70d
	dec de			;e70e
	ld (hl),000h		;e70f
	jp sub_e630h		;e711
	ld a,(0ffd1h)		;e714
	cp 000h			;e717
	jp z,le723h		;e719
	dec a			;e71c
	ld (0ffd1h),a		;e71d
	jp le55dh		;e720
le723h:
	ld a,04fh		;e723
	ld (0ffd1h),a		;e725
	ld hl,(0ffd2h)		;e728
	ld a,l			;e72b
	or h			;e72c
	jp nz,le57fh		;e72d
	ld hl,00780h		;e730
	ld (0ffd2h),hl		;e733
	ld a,018h		;e736
	ld (0ffd4h),a		;e738
	jp le55dh		;e73b
sub_e73eh:
	ld a,(0ffd1h)		;e73e
	cp 04fh			;e741
	jp z,le74dh		;e743
	inc a			;e746
	ld (0ffd1h),a		;e747
	jp le55dh		;e74a
le74dh:
	ld a,000h		;e74d
	ld (0ffd1h),a		;e74f
	call sub_e547h		;e752
	jp nz,le56eh		;e755
	call le55dh		;e758
	jp le5c5h		;e75b
	call sub_e73eh		;e75e
	call sub_e73eh		;e761
	call sub_e73eh		;e764
	jp sub_e73eh		;e767
	call sub_e547h		;e76a
	jp nz,le56eh		;e76d
	jp le5c5h		;e770
	ld hl,(0ffd2h)		;e773
	ld a,l			;e776
	or h			;e777
	jp nz,le57fh		;e778
	ld hl,00780h		;e77b
	ld (0ffd2h),hl		;e77e
	ld a,018h		;e781
	ld (0ffd4h),a		;e783
	jp le55dh		;e786
	call sub_e590h		;e789
	jp le55dh		;e78c
	ld hl,(0ffd2h)		;e78f
	ld b,h			;e792
	ld c,l			;e793
	ld de,0f850h		;e794
	add hl,de		;e797
	ld (le539h),hl		;e798
	ld de,0ffb0h		;e79b
	add hl,de		;e79e
	ex de,hl		;e79f
	ld h,b			;e7a0
	ld l,c			;e7a1
	call sub_e542h		;e7a2
	ld bc,00780h		;e7a5
	add hl,bc		;e7a8
	ld b,h			;e7a9
	ld c,l			;e7aa
	ld hl,(le539h)		;e7ab
	call le622h		;e7ae
	ld hl,0ff80h		;e7b1
	ld (0ffd5h),hl		;e7b4
	ld a,(0ffdbh)		;e7b7
	cp 000h			;e7ba
	jp z,le5a4h		;e7bc
	ld hl,(0ffd2h)		;e7bf
	call sub_e5f2h		;e7c2
	ld b,h			;e7c5
	ld c,l			;e7c6
	ld de,lf50ah		;e7c7
	add hl,de		;e7ca
	ld (le539h),hl		;e7cb
	ld de,0fff6h		;e7ce
	add hl,de		;e7d1
	ex de,hl		;e7d2
	ld h,b			;e7d3
	ld l,c			;e7d4
	call sub_e542h		;e7d5
	ld bc,000f0h		;e7d8
	add hl,bc		;e7db
	ld b,h			;e7dc
	ld c,l			;e7dd
	ld hl,(le539h)		;e7de
	call le622h		;e7e1
	ld hl,lf5f0h		;e7e4
	ld (0ffdch),hl		;e7e7
	jp le5a4h		;e7ea
	ld hl,(0ffd2h)		;e7ed
	ld de,0f800h		;e7f0
	add hl,de		;e7f3
	ld (0ffd5h),hl		;e7f4
	call sub_e542h		;e7f7
	ld de,0ff80h		;e7fa
	add hl,de		;e7fd
	ld b,h			;e7fe
	ld c,l			;e7ff
	ld hl,0ff7fh		;e800
	ld de,0ffcfh		;e803
	call sub_e630h		;e806
	ld a,(0ffdbh)		;e809
	cp 000h			;e80c
	jp z,le5a4h		;e80e
	ld hl,(0ffd2h)		;e811
	call sub_e5f2h		;e814
	ld de,0f500h		;e817
	add hl,de		;e81a
	ld (0ffdch),hl		;e81b
	call sub_e542h		;e81e
	ld de,lf5f0h		;e821
	add hl,de		;e824
	ld b,h			;e825
	ld c,l			;e826
	ld hl,lf5efh		;e827
	ld de,lf5f9h		;e82a
	call sub_e630h		;e82d
	jp le5a4h		;e830
	ld a,002h		;e833
	ld (0ffdbh),a		;e835
	ret			;e838
	ld a,001h		;e839
	ld (0ffdbh),a		;e83b
	ret			;e83e
	ld hl,0f800h		;e83f
	ld de,0f500h		;e842
	ld b,0fah		;e845
le847h:
	ld a,(de)		;e847
	ld c,008h		;e848
	cp 000h			;e84a
	jp nz,le859h		;e84c
le84fh:
	ld (hl),020h		;e84f
	inc hl			;e851
	dec c			;e852
	jp nz,le84fh		;e853
	jp le864h		;e856
le859h:
	rra			;e859
	jp c,le85fh		;e85a
	ld (hl),020h		;e85d
le85fh:
	inc hl			;e85f
	dec c			;e860
	jp nz,le859h		;e861
le864h:
	inc de			;e864
	dec b			;e865
	jp nz,le847h		;e866
	ret			;e869
le86ah:
	ld c,d			;e86a
	and 0edh		;e86b
	rst 20h			;e86d
	adc a,a			;e86e
	rst 20h			;e86f
	ld c,d			;e870
	and 04ah		;e871
	and 014h		;e873
	rst 20h			;e875
	ld b,c			;e876
	and 03eh		;e877
	and 014h		;e879
	rst 20h			;e87b
	ld e,(hl)		;e87c
	rst 20h			;e87d
	ld l,d			;e87e
	rst 20h			;e87f
	ld c,d			;e880
	and 053h		;e881
	and 04bh		;e883
	and 04ah		;e885
	and 04ah		;e887
	and 04ah		;e889
	and 04ah		;e88b
	and 04ah		;e88d
	and 04ah		;e88f
	and 033h		;e891
	ret pe			;e893
	add hl,sp		;e894
	ret pe			;e895
	ccf			;e896
	ret pe			;e897
	ld c,d			;e898
	and 03eh		;e899
	rst 20h			;e89b
	ld c,d			;e89c
	and 073h		;e89d
	rst 20h			;e89f
	ld c,d			;e8a0
	and 04ah		;e8a1
	and 089h		;e8a3
	rst 20h			;e8a5
	ld a,(hl)		;e8a6
	and 0cbh		;e8a7
	and 03eh		;e8a9
	nop			;e8ab
	ld (0ffd7h),a		;e8ac
	ld a,(0ffdah)		;e8af
	rlca			;e8b2
	and 03eh		;e8b3
	ld c,a			;e8b5
	ld b,000h		;e8b6
	ld hl,le86ah		;e8b8
	add hl,bc		;e8bb
	ld e,(hl)		;e8bc
	inc hl			;e8bd
	ld d,(hl)		;e8be
	ex de,hl		;e8bf
	jp (hl)			;e8c0
sub_e8c1h:
	ld a,(0ffdah)		;e8c1
	and 07fh		;e8c4
	sub 020h		;e8c6
	ld hl,0ffd7h		;e8c8
	dec (hl)		;e8cb
	jp z,le8d3h		;e8cc
	ld (0ffdeh),a		;e8cf
	ret			;e8d2
le8d3h:
	ld d,a			;e8d3
	ld a,(0ffdeh)		;e8d4
	ld h,a			;e8d7
	ld a,(le233h)		;e8d8
	or a			;e8db
	jp z,le8e0h		;e8dc
	ex de,hl		;e8df
le8e0h:
	ld a,h			;e8e0
	ld b,050h		;e8e1
	call le59eh		;e8e3
	ld (0ffd1h),a		;e8e6
	ld a,d			;e8e9
	ld b,019h		;e8ea
	call le59eh		;e8ec
	ld (0ffd4h),a		;e8ef
	or a			;e8f2
	jp z,le55dh		;e8f3
	ld hl,(0ffd2h)		;e8f6
	ld de,00050h		;e8f9
le8fch:
	add hl,de		;e8fc
	dec a			;e8fd
	jp nz,le8fch		;e8fe
	ld (0ffd2h),hl		;e901
	jp le55dh		;e904
sub_e907h:
	ld hl,(0ffd2h)		;e907
	ld d,000h		;e90a
	ld a,(0ffd1h)		;e90c
	ld e,a			;e90f
	add hl,de		;e910
	ld (0ffd8h),hl		;e911
	ld a,(0ffdah)		;e914
	cp 0c0h			;e917
	jp c,le91eh		;e919
	sub 0c0h		;e91c
le91eh:
	ld c,a			;e91e
	cp 080h			;e91f
	jp c,le92dh		;e921
	and 004h		;e924
	ld (le538h),a		;e926
	ld a,c			;e929
	jp le933h		;e92a
le92dh:
	ld hl,lf680h		;e92d
	call sub_e552h		;e930
le933h:
	ld hl,(0ffd8h)		;e933
	ld de,0f800h		;e936
	add hl,de		;e939
	ld (hl),a		;e93a
	call sub_e73eh		;e93b
	ld a,(0ffdbh)		;e93e
	cp 002h			;e941
	ret nz			;e943
	ld hl,(0ffd8h)		;e944
	call sub_e5f2h		;e947
	ld de,0f500h		;e94a
	add hl,de		;e94d
	cp 000h			;e94e
	ld b,a			;e950
	ld a,001h		;e951
	jp nz,le959h		;e953
	or (hl)			;e956
	ld (hl),a		;e957
	ret			;e958
le959h:
	rlca			;e959
	dec b			;e95a
	jp nz,le959h		;e95b
	or (hl)			;e95e
	ld (hl),a		;e95f
	ret			;e960
le961h:
	di			;e961
	push hl			;e962
	ld hl,00000h		;e963
	add hl,sp		;e966
	ld sp,lf680h		;e967
	ei			;e96a
	push hl			;e96b
	push af			;e96c
	push bc			;e96d
	push de			;e96e
	ld a,c			;e96f
	ld (0ffdah),a		;e970
	ld a,(0ffd7h)		;e973
	or a			;e976
	jp z,le980h		;e977
	call sub_e8c1h		;e97a
	jp le991h		;e97d
le980h:
	ld a,(0ffdah)		;e980
	cp 020h			;e983
	jp nc,le98eh		;e985
	call 0e8aah		;e988
	jp le991h		;e98b
le98eh:
	call sub_e907h		;e98e
le991h:
	pop de			;e991
	pop bc			;e992
	pop af			;e993
	pop hl			;e994
	di			;e995
	ld sp,hl		;e996
	pop hl			;e997
	ei			;e998
	ret			;e999
	ld (lee9ch),sp		;e99a
	ld sp,lf620h		;e99e
	push af			;e9a1
	push bc			;e9a2
	push de			;e9a3
	push hl			;e9a4
	in a,(001h)		;e9a5
	ld a,006h		;e9a7
	out (0fah),a		;e9a9
	ld a,007h		;e9ab
	out (0fah),a		;e9ad
	out (0fch),a		;e9af
	ld hl,0f800h		;e9b1
	ld a,l			;e9b4
	out (0f4h),a		;e9b5
	ld a,h			;e9b7
	out (0f4h),a		;e9b8
	ld hl,007cfh		;e9ba
	ld a,l			;e9bd
	out (0f5h),a		;e9be
	ld a,h			;e9c0
	out (0f5h),a		;e9c1
	ld a,000h		;e9c3
	out (0f7h),a		;e9c5
	out (0f7h),a		;e9c7
	ld a,002h		;e9c9
	out (0fah),a		;e9cb
	ld a,003h		;e9cd
	out (0fah),a		;e9cf
	ld a,0d7h		;e9d1
	out (00eh),a		;e9d3
	ld a,001h		;e9d5
	out (00eh),a		;e9d7
	ld hl,0fffch		;e9d9
	inc (hl)		;e9dc
	jp nz,le9ech		;e9dd
	inc hl			;e9e0
	inc (hl)		;e9e1
	jp nz,le9ech		;e9e2
	inc hl			;e9e5
	inc (hl)		;e9e6
	jp nz,le9ech		;e9e7
	inc hl			;e9ea
	inc (hl)		;e9eb
le9ech:
	ld hl,(0ffdfh)		;e9ec
	ld a,l			;e9ef
	or h			;e9f0
	jp z,le9fdh		;e9f1
	dec hl			;e9f4
	ld a,l			;e9f5
	or h			;e9f6
	ld (0ffdfh),hl		;e9f7
	call z,0ffe5h		;e9fa
le9fdh:
	ld hl,(0ffe1h)		;e9fd
	ld a,l			;ea00
	or h			;ea01
	jp z,lea0eh		;ea02
	dec hl			;ea05
	ld a,l			;ea06
	or h			;ea07
	ld (0ffe1h),hl		;ea08
	call z,sub_f1a9h	;ea0b
lea0eh:
	ld hl,(0ffe3h)		;ea0e
	ld a,l			;ea11
	or h			;ea12
	jp z,lea1ah		;ea13
	dec hl			;ea16
	ld (0ffe3h),hl		;ea17
lea1ah:
	pop hl			;ea1a
	pop de			;ea1b
	pop bc			;ea1c
	pop af			;ea1d
	ld sp,(lee9ch)		;ea1e
	ei			;ea22
	reti			;ea23
lea25h:
	ld bc,00d07h		;ea25
	inc de			;ea28
	add hl,de		;ea29
	dec b			;ea2a
	dec bc			;ea2b
	ld de,00317h		;ea2c
	add hl,bc		;ea2f
	rrca			;ea30
	dec d			;ea31
	ld (bc),a		;ea32
	ex af,af'		;ea33
	ld c,014h		;ea34
	ld a,(de)		;ea36
	ld b,00ch		;ea37
	ld (de),a		;ea39
	jr $+6			;ea3a
	ld a,(bc)		;ea3c
	djnz lea55h		;ea3d
	ld bc,00905h		;ea3f
	dec c			;ea42
	ld (bc),a		;ea43
	ld b,00ah		;ea44
	ld c,003h		;ea46
	rlca			;ea48
	dec bc			;ea49
	rrca			;ea4a
	inc b			;ea4b
	ex af,af'		;ea4c
	inc c			;ea4d
	ld bc,00503h		;ea4e
	rlca			;ea51
	add hl,bc		;ea52
	ld (bc),a		;ea53
	inc b			;ea54
lea55h:
	ld b,008h		;ea55
lea57h:
	ld bc,00302h		;ea57
	inc b			;ea5a
	dec b			;ea5b
	ld b,007h		;ea5c
	ex af,af'		;ea5e
	add hl,bc		;ea5f
	ld a,(bc)		;ea60
	dec bc			;ea61
	inc c			;ea62
	dec c			;ea63
	ld c,00fh		;ea64
	djnz lea79h		;ea66
	ld (de),a		;ea68
	inc de			;ea69
	inc d			;ea6a
	dec d			;ea6b
	ld d,017h		;ea6c
	jr lea89h		;ea6e
	ld a,(de)		;ea70
	ld a,(de)		;ea71
	nop			;ea72
	inc bc			;ea73
	rlca			;ea74
	nop			;ea75
	jp p,03f00h		;ea76
lea79h:
	nop			;ea79
	ret nz			;ea7a
	nop			;ea7b
	djnz lea7eh		;ea7c
lea7eh:
	ld (bc),a		;ea7e
	nop			;ea7f
	ld a,b			;ea80
	nop			;ea81
	inc b			;ea82
	rrca			;ea83
	nop			;ea84
	pop bc			;ea85
	ld bc,0007fh		;ea86
lea89h:
	ret nz			;ea89
	nop			;ea8a
	jr nz,lea8dh		;ea8b
lea8dh:
	ld (bc),a		;ea8d
	nop			;ea8e
	ld a,(de)		;ea8f
	nop			;ea90
	inc bc			;ea91
	rlca			;ea92
	nop			;ea93
	jp p,03f00h		;ea94
	nop			;ea97
	ret nz			;ea98
	nop			;ea99
	djnz lea9ch		;ea9a
lea9ch:
	nop			;ea9c
	nop			;ea9d
	ld l,b			;ea9e
	nop			;ea9f
	inc b			;eaa0
	rrca			;eaa1
	nop			;eaa2
	rst 10h			;eaa3
	ld bc,0007fh		;eaa4
	ret nz			;eaa7
	nop			;eaa8
	jr nz,leaabh		;eaa9
leaabh:
	nop			;eaab
	nop			;eaac
leaadh:
	ld (hl),c		;eaad
	jp pe,01a08h		;eaae
	nop			;eab1
	ld bc,lea25h		;eab2
	add a,b			;eab5
	nop			;eab6
	nop			;eab7
	nop			;eab8
	nop			;eab9
	nop			;eaba
	nop			;eabb
	nop			;eabc
	add a,b			;eabd
	jp pe,07810h		;eabe
	inc bc			;eac1
	inc bc			;eac2
	ccf			;eac3
	jp pe,000ffh		;eac4
	nop			;eac7
	nop			;eac8
	nop			;eac9
	nop			;eaca
	nop			;eacb
	nop			;eacc
	ld (hl),c		;eacd
	jp pe,01a08h		;eace
	nop			;ead1
	ld bc,lea57h		;ead2
	add a,b			;ead5
	nop			;ead6
	nop			;ead7
	nop			;ead8
	nop			;ead9
	nop			;eada
	nop			;eadb
	nop			;eadc
	sbc a,(hl)		;eadd
	jp pe,06808h		;eade
	ld bc,05702h		;eae1
	jp pe,000ffh		;eae4
	nop			;eae7
	nop			;eae8
	nop			;eae9
	nop			;eaea
	nop			;eaeb
	nop			;eaec
	ld a,(de)		;eaed
leaeeh:
	ld a,a			;eaee
	nop			;eaef
	nop			;eaf0
	nop			;eaf1
	ld a,(de)		;eaf2
	rlca			;eaf3
	ld c,l			;eaf4
	ld e,0ffh		;eaf5
	ld bc,00240h		;eaf7
	rrca			;eafa
	dec de			;eafb
	ld c,l			;eafc
	ld a,(de)		;eafd
	ld a,a			;eafe
	nop			;eaff
	nop			;eb00
	nop			;eb01
	ld a,(de)		;eb02
	rlca			;eb03
	ld c,l			;eb04
	inc (hl)		;eb05
	rst 38h			;eb06
	nop			;eb07
	ld b,b			;eb08
	ld bc,00e1ah		;eb09
	ld c,l			;eb0c
leb0dh:
	nop			;eb0d
	nop			;eb0e
	jr nz,leb11h		;eb0f
leb11h:
	nop			;eb11
	nop			;eb12
	nop			;eb13
	nop			;eb14
	ld d,(hl)		;eb15
	defb 0edh ;next byte illegal after ed	;eb16
	add a,b			;eb17
	jp pe,lee0fh		;eb18
	sub 0edh		;eb1b
	nop			;eb1d
	nop			;eb1e
	nop			;eb1f
	nop			;eb20
	nop			;eb21
	nop			;eb22
	nop			;eb23
	nop			;eb24
	ld d,(hl)		;eb25
	defb 0edh ;next byte illegal after ed	;eb26
	add a,b			;eb27
	jp pe,lee68h		;eb28
	cpl			;eb2b
	xor 080h		;eb2c
leb2eh:
	jp pe,07810h		;eb2e
leb31h:
	inc bc			;eb31
leb32h:
	inc bc			;eb32
leb33h:
	ccf			;eb33
	jp pe,000ffh		;eb34
	nop			;eb37
	nop			;eb38
	nop			;eb39
	nop			;eb3a
	nop			;eb3b
	nop			;eb3c
leb3dh:
	nop			;eb3d
leb3eh:
	ld (bc),a		;eb3e
	nop			;eb3f
leb40h:
	ex af,af'		;eb40
leb41h:
	nop			;eb41
leb42h:
	ld (bc),a		;eb42
	nop			;eb43
leb44h:
	ld (bc),a		;eb44
leb45h:
	nop			;eb45
leb46h:
	ld (bc),a		;eb46
leb47h:
	ld (bc),a		;eb47
leb48h:
	ld bc,00000h		;eb48
leb4bh:
	nop			;eb4b
leb4ch:
	nop			;eb4c
	nop			;eb4d
leb4eh:
	nop			;eb4e
leb4fh:
	nop			;eb4f
leb50h:
	nop			;eb50
leb51h:
	ld bc,00201h		;eb51
leb54h:
	add a,b			;eb54
	nop			;eb55
leb56h:
	push hl			;eb56
	ld c,(hl)		;eb57
	ld c,b			;eb58
	ld d,b			;eb59
	jr nz,leb7ch		;eb5a
	jr nz,leb7eh		;eb5c
	jr nz,lebb0h		;eb5e
	ld b,c			;eb60
	ld d,e			;eb61
	nop			;eb62
	nop			;eb63
	nop			;eb64
	dec b			;eb65
	ld l,(hl)		;eb66
	nop			;eb67
	nop			;eb68
	nop			;eb69
	nop			;eb6a
	nop			;eb6b
	nop			;eb6c
	nop			;eb6d
	nop			;eb6e
	nop			;eb6f
	nop			;eb70
	nop			;eb71
	nop			;eb72
	nop			;eb73
	nop			;eb74
	nop			;eb75
	push hl			;eb76
	ld c,(hl)		;eb77
	ld c,b			;eb78
	ld d,b			;eb79
	jr nz,leb9ch		;eb7a
leb7ch:
	jr nz,leb9eh		;eb7c
leb7eh:
	jr nz,lebc3h		;eb7e
	ld c,a			;eb80
	ld c,l			;eb81
	nop			;eb82
	nop			;eb83
	nop			;eb84
	ld a,(0006fh)		;eb85
	ld (hl),b		;eb88
	nop			;eb89
	ld (hl),c		;eb8a
	nop			;eb8b
	ld (hl),d		;eb8c
	nop			;eb8d
	nop			;eb8e
	nop			;eb8f
	nop			;eb90
	nop			;eb91
	nop			;eb92
	nop			;eb93
	nop			;eb94
	nop			;eb95
	push hl			;eb96
	push hl			;eb97
	push hl			;eb98
	push hl			;eb99
	push hl			;eb9a
	push hl			;eb9b
leb9ch:
	push hl			;eb9c
	push hl			;eb9d
leb9eh:
	push hl			;eb9e
	push hl			;eb9f
	push hl			;eba0
	push hl			;eba1
	push hl			;eba2
	push hl			;eba3
	push hl			;eba4
	push hl			;eba5
	push hl			;eba6
	push hl			;eba7
	push hl			;eba8
	push hl			;eba9
	push hl			;ebaa
	push hl			;ebab
	push hl			;ebac
	push hl			;ebad
	push hl			;ebae
	push hl			;ebaf
lebb0h:
	push hl			;ebb0
	push hl			;ebb1
	push hl			;ebb2
	push hl			;ebb3
	push hl			;ebb4
	push hl			;ebb5
	push hl			;ebb6
	push hl			;ebb7
	push hl			;ebb8
	push hl			;ebb9
	push hl			;ebba
	push hl			;ebbb
	push hl			;ebbc
	push hl			;ebbd
	push hl			;ebbe
	push hl			;ebbf
	push hl			;ebc0
	push hl			;ebc1
	push hl			;ebc2
lebc3h:
	push hl			;ebc3
	push hl			;ebc4
	push hl			;ebc5
	push hl			;ebc6
	push hl			;ebc7
	push hl			;ebc8
	push hl			;ebc9
	push hl			;ebca
	push hl			;ebcb
	push hl			;ebcc
	push hl			;ebcd
	push hl			;ebce
	push hl			;ebcf
	push hl			;ebd0
	push hl			;ebd1
	push hl			;ebd2
	push hl			;ebd3
	push hl			;ebd4
	push hl			;ebd5
	push hl			;ebd6
	push hl			;ebd7
	push hl			;ebd8
	push hl			;ebd9
	push hl			;ebda
	push hl			;ebdb
	push hl			;ebdc
	push hl			;ebdd
	push hl			;ebde
	push hl			;ebdf
	push hl			;ebe0
	push hl			;ebe1
	push hl			;ebe2
	push hl			;ebe3
	push hl			;ebe4
	push hl			;ebe5
	push hl			;ebe6
	push hl			;ebe7
	push hl			;ebe8
	push hl			;ebe9
	push hl			;ebea
	push hl			;ebeb
	push hl			;ebec
	push hl			;ebed
	push hl			;ebee
	push hl			;ebef
	push hl			;ebf0
	push hl			;ebf1
	push hl			;ebf2
	push hl			;ebf3
	push hl			;ebf4
	push hl			;ebf5
	push hl			;ebf6
	push hl			;ebf7
	push hl			;ebf8
	push hl			;ebf9
	push hl			;ebfa
	push hl			;ebfb
	push hl			;ebfc
	push hl			;ebfd
	push hl			;ebfe
	push hl			;ebff
	push hl			;ec00
	push hl			;ec01
	push hl			;ec02
	push hl			;ec03
	push hl			;ec04
	push hl			;ec05
	push hl			;ec06
	push hl			;ec07
	push hl			;ec08
	push hl			;ec09
	push hl			;ec0a
	push hl			;ec0b
	push hl			;ec0c
	push hl			;ec0d
	push hl			;ec0e
	push hl			;ec0f
	push hl			;ec10
	push hl			;ec11
	push hl			;ec12
	push hl			;ec13
	push hl			;ec14
	push hl			;ec15
	push hl			;ec16
	push hl			;ec17
	push hl			;ec18
	push hl			;ec19
	push hl			;ec1a
	push hl			;ec1b
	push hl			;ec1c
	push hl			;ec1d
	push hl			;ec1e
	push hl			;ec1f
	push hl			;ec20
	push hl			;ec21
	push hl			;ec22
	push hl			;ec23
	push hl			;ec24
	push hl			;ec25
	push hl			;ec26
	push hl			;ec27
	push hl			;ec28
	push hl			;ec29
	push hl			;ec2a
	push hl			;ec2b
	push hl			;ec2c
	push hl			;ec2d
	push hl			;ec2e
	push hl			;ec2f
	push hl			;ec30
	push hl			;ec31
	push hl			;ec32
	push hl			;ec33
	push hl			;ec34
	push hl			;ec35
	push hl			;ec36
	push hl			;ec37
	push hl			;ec38
	push hl			;ec39
	push hl			;ec3a
	push hl			;ec3b
	push hl			;ec3c
	push hl			;ec3d
	push hl			;ec3e
	push hl			;ec3f
	push hl			;ec40
	push hl			;ec41
	push hl			;ec42
	push hl			;ec43
	push hl			;ec44
	push hl			;ec45
	push hl			;ec46
	push hl			;ec47
	push hl			;ec48
	push hl			;ec49
	push hl			;ec4a
	push hl			;ec4b
	push hl			;ec4c
	push hl			;ec4d
	push hl			;ec4e
	push hl			;ec4f
	push hl			;ec50
	push hl			;ec51
	push hl			;ec52
	push hl			;ec53
	push hl			;ec54
	push hl			;ec55
	push hl			;ec56
	push hl			;ec57
	push hl			;ec58
	push hl			;ec59
	push hl			;ec5a
	push hl			;ec5b
	push hl			;ec5c
	push hl			;ec5d
	push hl			;ec5e
	push hl			;ec5f
	push hl			;ec60
	push hl			;ec61
	push hl			;ec62
	push hl			;ec63
	push hl			;ec64
	push hl			;ec65
	push hl			;ec66
	push hl			;ec67
	push hl			;ec68
	push hl			;ec69
	push hl			;ec6a
	push hl			;ec6b
	push hl			;ec6c
	push hl			;ec6d
	push hl			;ec6e
	push hl			;ec6f
	push hl			;ec70
	push hl			;ec71
	push hl			;ec72
	push hl			;ec73
	push hl			;ec74
	push hl			;ec75
	push hl			;ec76
	push hl			;ec77
	push hl			;ec78
	push hl			;ec79
	push hl			;ec7a
	push hl			;ec7b
	push hl			;ec7c
	push hl			;ec7d
	push hl			;ec7e
	push hl			;ec7f
	push hl			;ec80
	push hl			;ec81
	push hl			;ec82
	push hl			;ec83
	push hl			;ec84
	push hl			;ec85
	push hl			;ec86
	push hl			;ec87
	push hl			;ec88
	push hl			;ec89
	push hl			;ec8a
	push hl			;ec8b
	push hl			;ec8c
	push hl			;ec8d
	push hl			;ec8e
	push hl			;ec8f
	push hl			;ec90
	push hl			;ec91
	push hl			;ec92
	push hl			;ec93
	push hl			;ec94
	push hl			;ec95
	push hl			;ec96
	push hl			;ec97
	push hl			;ec98
	push hl			;ec99
	push hl			;ec9a
	push hl			;ec9b
	push hl			;ec9c
	push hl			;ec9d
	push hl			;ec9e
	push hl			;ec9f
	push hl			;eca0
	push hl			;eca1
	push hl			;eca2
	push hl			;eca3
	push hl			;eca4
	push hl			;eca5
	push hl			;eca6
	push hl			;eca7
	push hl			;eca8
	push hl			;eca9
	push hl			;ecaa
	push hl			;ecab
	push hl			;ecac
	push hl			;ecad
	push hl			;ecae
	push hl			;ecaf
	push hl			;ecb0
	push hl			;ecb1
	push hl			;ecb2
	push hl			;ecb3
	push hl			;ecb4
	push hl			;ecb5
	push hl			;ecb6
	push hl			;ecb7
	push hl			;ecb8
	push hl			;ecb9
	push hl			;ecba
	push hl			;ecbb
	push hl			;ecbc
	push hl			;ecbd
	push hl			;ecbe
	push hl			;ecbf
	push hl			;ecc0
	push hl			;ecc1
	push hl			;ecc2
	push hl			;ecc3
	push hl			;ecc4
	push hl			;ecc5
	push hl			;ecc6
	push hl			;ecc7
	push hl			;ecc8
	push hl			;ecc9
	push hl			;ecca
	push hl			;eccb
	push hl			;eccc
	push hl			;eccd
	push hl			;ecce
	push hl			;eccf
	push hl			;ecd0
	push hl			;ecd1
	push hl			;ecd2
	push hl			;ecd3
	push hl			;ecd4
	push hl			;ecd5
	push hl			;ecd6
	push hl			;ecd7
	push hl			;ecd8
	push hl			;ecd9
	push hl			;ecda
	push hl			;ecdb
	push hl			;ecdc
	push hl			;ecdd
	push hl			;ecde
	push hl			;ecdf
	push hl			;ece0
	push hl			;ece1
	push hl			;ece2
	push hl			;ece3
	push hl			;ece4
	push hl			;ece5
	push hl			;ece6
	push hl			;ece7
	push hl			;ece8
	push hl			;ece9
	push hl			;ecea
	push hl			;eceb
	push hl			;ecec
	push hl			;eced
	push hl			;ecee
	push hl			;ecef
	push hl			;ecf0
	push hl			;ecf1
	push hl			;ecf2
	push hl			;ecf3
	push hl			;ecf4
	push hl			;ecf5
	push hl			;ecf6
	push hl			;ecf7
	push hl			;ecf8
	push hl			;ecf9
	push hl			;ecfa
	push hl			;ecfb
	push hl			;ecfc
	push hl			;ecfd
	push hl			;ecfe
	push hl			;ecff
	push hl			;ed00
	push hl			;ed01
	push hl			;ed02
	push hl			;ed03
	push hl			;ed04
	push hl			;ed05
	push hl			;ed06
	push hl			;ed07
	push hl			;ed08
	push hl			;ed09
	push hl			;ed0a
	push hl			;ed0b
	push hl			;ed0c
	push hl			;ed0d
	push hl			;ed0e
	push hl			;ed0f
	push hl			;ed10
	push hl			;ed11
	push hl			;ed12
	push hl			;ed13
	push hl			;ed14
	push hl			;ed15
	push hl			;ed16
	push hl			;ed17
	push hl			;ed18
	push hl			;ed19
	push hl			;ed1a
	push hl			;ed1b
	push hl			;ed1c
	push hl			;ed1d
	push hl			;ed1e
	push hl			;ed1f
	push hl			;ed20
	push hl			;ed21
	push hl			;ed22
	push hl			;ed23
	push hl			;ed24
	push hl			;ed25
	push hl			;ed26
	push hl			;ed27
	push hl			;ed28
	push hl			;ed29
	push hl			;ed2a
	push hl			;ed2b
	push hl			;ed2c
	push hl			;ed2d
	push hl			;ed2e
	push hl			;ed2f
	push hl			;ed30
	push hl			;ed31
	push hl			;ed32
	push hl			;ed33
	push hl			;ed34
	push hl			;ed35
	push hl			;ed36
	push hl			;ed37
	push hl			;ed38
	push hl			;ed39
	push hl			;ed3a
	push hl			;ed3b
	push hl			;ed3c
	push hl			;ed3d
	push hl			;ed3e
	push hl			;ed3f
	push hl			;ed40
	push hl			;ed41
	push hl			;ed42
	push hl			;ed43
	push hl			;ed44
	push hl			;ed45
	push hl			;ed46
	push hl			;ed47
	push hl			;ed48
	push hl			;ed49
	push hl			;ed4a
	push hl			;ed4b
	push hl			;ed4c
	push hl			;ed4d
	push hl			;ed4e
	push hl			;ed4f
	push hl			;ed50
	push hl			;ed51
	push hl			;ed52
	push hl			;ed53
	push hl			;ed54
	push hl			;ed55
	push hl			;ed56
	ld c,(hl)		;ed57
	ld c,b			;ed58
	ld d,b			;ed59
	jr nz,led7ch		;ed5a
	jr nz,led7eh		;ed5c
	jr nz,ledb0h		;ed5e
	ld b,c			;ed60
	ld d,e			;ed61
	nop			;ed62
	nop			;ed63
	nop			;ed64
	dec b			;ed65
	ld l,(hl)		;ed66
	nop			;ed67
	nop			;ed68
	nop			;ed69
	nop			;ed6a
	nop			;ed6b
	nop			;ed6c
	nop			;ed6d
	nop			;ed6e
	nop			;ed6f
	nop			;ed70
	nop			;ed71
	nop			;ed72
	nop			;ed73
	nop			;ed74
	nop			;ed75
	push hl			;ed76
	ld c,(hl)		;ed77
	ld c,b			;ed78
	ld d,b			;ed79
	jr nz,led9ch		;ed7a
led7ch:
	jr nz,led9eh		;ed7c
led7eh:
	jr nz,ledc3h		;ed7e
	ld c,a			;ed80
	ld c,l			;ed81
	nop			;ed82
	nop			;ed83
	nop			;ed84
	ld a,(0006fh)		;ed85
	ld (hl),b		;ed88
	nop			;ed89
	ld (hl),c		;ed8a
	nop			;ed8b
	ld (hl),d		;ed8c
	nop			;ed8d
	nop			;ed8e
	nop			;ed8f
	nop			;ed90
	nop			;ed91
	nop			;ed92
	nop			;ed93
	nop			;ed94
	nop			;ed95
	push hl			;ed96
	push hl			;ed97
	push hl			;ed98
	push hl			;ed99
	push hl			;ed9a
	push hl			;ed9b
led9ch:
	push hl			;ed9c
	push hl			;ed9d
led9eh:
	push hl			;ed9e
	push hl			;ed9f
	push hl			;eda0
	push hl			;eda1
	push hl			;eda2
	push hl			;eda3
	push hl			;eda4
	push hl			;eda5
	push hl			;eda6
	push hl			;eda7
	push hl			;eda8
	push hl			;eda9
	push hl			;edaa
	push hl			;edab
	push hl			;edac
	push hl			;edad
	push hl			;edae
	push hl			;edaf
ledb0h:
	push hl			;edb0
	push hl			;edb1
	push hl			;edb2
	push hl			;edb3
	push hl			;edb4
	push hl			;edb5
	push hl			;edb6
	push hl			;edb7
	push hl			;edb8
	push hl			;edb9
	push hl			;edba
	push hl			;edbb
	push hl			;edbc
	push hl			;edbd
	push hl			;edbe
	push hl			;edbf
	push hl			;edc0
	push hl			;edc1
	push hl			;edc2
ledc3h:
	push hl			;edc3
	push hl			;edc4
	push hl			;edc5
	push hl			;edc6
	push hl			;edc7
	push hl			;edc8
	push hl			;edc9
	push hl			;edca
	push hl			;edcb
	push hl			;edcc
	push hl			;edcd
	push hl			;edce
	push hl			;edcf
	push hl			;edd0
	push hl			;edd1
	push hl			;edd2
	push hl			;edd3
	push hl			;edd4
	push hl			;edd5
	rst 38h			;edd6
	rst 38h			;edd7
	rst 38h			;edd8
	rst 38h			;edd9
	rst 38h			;edda
	rst 38h			;eddb
	rst 38h			;eddc
	rst 38h			;eddd
	rst 38h			;edde
	rst 38h			;eddf
	rst 38h			;ede0
	rst 38h			;ede1
	rst 38h			;ede2
	call m,00000h		;ede3
	nop			;ede6
	nop			;ede7
	nop			;ede8
	nop			;ede9
	nop			;edea
	nop			;edeb
	nop			;edec
	nop			;eded
	nop			;edee
	nop			;edef
	nop			;edf0
	nop			;edf1
	nop			;edf2
	nop			;edf3
	nop			;edf4
	nop			;edf5
	nop			;edf6
	nop			;edf7
	nop			;edf8
	nop			;edf9
	nop			;edfa
	nop			;edfb
	nop			;edfc
	nop			;edfd
	nop			;edfe
	nop			;edff
	nop			;ee00
	nop			;ee01
	nop			;ee02
	nop			;ee03
	nop			;ee04
	nop			;ee05
	nop			;ee06
	nop			;ee07
	nop			;ee08
	nop			;ee09
	nop			;ee0a
	nop			;ee0b
	nop			;ee0c
	nop			;ee0d
	nop			;ee0e
lee0fh:
	ld a,e			;ee0f
	sbc a,0b3h		;ee10
	jp nc,00a92h		;ee12
	ld h,e			;ee15
	rrca			;ee16
	ld c,b			;ee17
	add a,b			;ee18
	add a,b			;ee19
	add a,b			;ee1a
	add a,b			;ee1b
	add a,b			;ee1c
	add a,b			;ee1d
	add a,b			;ee1e
	add a,b			;ee1f
	add a,b			;ee20
	add a,b			;ee21
	add a,b			;ee22
	add a,b			;ee23
	add a,b			;ee24
	add a,b			;ee25
	add a,b			;ee26
	add a,b			;ee27
	add a,b			;ee28
	add a,b			;ee29
	add a,b			;ee2a
	add a,b			;ee2b
	add a,b			;ee2c
	add a,b			;ee2d
	add a,b			;ee2e
	nop			;ee2f
	nop			;ee30
	nop			;ee31
	nop			;ee32
	nop			;ee33
	nop			;ee34
	nop			;ee35
	nop			;ee36
	nop			;ee37
	nop			;ee38
	nop			;ee39
	nop			;ee3a
	nop			;ee3b
	nop			;ee3c
	nop			;ee3d
	nop			;ee3e
	nop			;ee3f
	nop			;ee40
	nop			;ee41
	nop			;ee42
	nop			;ee43
	nop			;ee44
	nop			;ee45
	nop			;ee46
	nop			;ee47
	nop			;ee48
	nop			;ee49
	nop			;ee4a
	nop			;ee4b
	nop			;ee4c
	nop			;ee4d
	nop			;ee4e
	nop			;ee4f
	nop			;ee50
	nop			;ee51
	nop			;ee52
	nop			;ee53
	nop			;ee54
	nop			;ee55
	nop			;ee56
	nop			;ee57
	nop			;ee58
	nop			;ee59
	nop			;ee5a
	nop			;ee5b
	nop			;ee5c
	nop			;ee5d
	nop			;ee5e
	nop			;ee5f
	nop			;ee60
	nop			;ee61
	nop			;ee62
	nop			;ee63
	nop			;ee64
	nop			;ee65
	nop			;ee66
	nop			;ee67
lee68h:
	nop			;ee68
	nop			;ee69
	nop			;ee6a
	nop			;ee6b
	nop			;ee6c
	nop			;ee6d
	nop			;ee6e
	nop			;ee6f
	nop			;ee70
	nop			;ee71
	nop			;ee72
	nop			;ee73
	nop			;ee74
	nop			;ee75
	nop			;ee76
	nop			;ee77
	nop			;ee78
	nop			;ee79
	nop			;ee7a
	nop			;ee7b
	nop			;ee7c
	nop			;ee7d
	nop			;ee7e
	nop			;ee7f
	nop			;ee80
	nop			;ee81
	nop			;ee82
	nop			;ee83
	nop			;ee84
	nop			;ee85
	nop			;ee86
	nop			;ee87
lee88h:
	or 0eah			;ee88
lee8ah:
	ex af,af'		;ee8a
lee8bh:
	rrca			;ee8b
lee8ch:
	ld bc,05600h		;ee8c
lee8fh:
	ex de,hl		;ee8f
lee90h:
	ld (bc),a		;ee90
lee91h:
	add hl,bc		;ee91
lee92h:
	ld a,(bc)		;ee92
lee93h:
	nop			;ee93
lee94h:
	nop			;ee94
	nop			;ee95
	ld (bc),a		;ee96
	nop			;ee97
	ld a,(bc)		;ee98
	ld (bc),a		;ee99
	nop			;ee9a
lee9bh:
	rst 38h			;ee9b
lee9ch:
	dec (hl)		;ee9c
	rst 10h			;ee9d
lee9eh:
	ld hl,00000h		;ee9e
	add hl,sp		;eea1
	ld sp,lf680h		;eea2
	push hl			;eea5
	ld hl,00000h		;eea6
	ld a,(lee8ch)		;eea9
	cp c			;eeac
	jp c,lef13h		;eead
	ld a,c			;eeb0
	ld (leb3dh),a		;eeb1
	ld bc,00000h		;eeb4
	ld hl,le237h		;eeb7
	or a			;eeba
	jp z,leec2h		;eebb
	inc hl			;eebe
	ld bc,00010h		;eebf
leec2h:
	ld a,(hl)		;eec2
	ld hl,lee8ah		;eec3
	cp (hl)			;eec6
	jp z,leed9h		;eec7
	push af			;eeca
	push bc			;eecb
	ld a,(leb48h+1)		;eecc
	or a			;eecf
	call nz,sub_f080h	;eed0
	xor a			;eed3
	ld (leb48h+1),a		;eed4
	pop bc			;eed7
	pop af			;eed8
leed9h:
	ld (lee8ah),a		;eed9
	call sub_f180h		;eedc
	ld (lee88h),hl		;eedf
	inc hl			;eee2
	inc hl			;eee3
	inc hl			;eee4
	inc hl			;eee5
	ld a,(hl)		;eee6
	ld (lee8bh),a		;eee7
	push bc			;eeea
	ld a,(lee8ah)		;eeeb
	or a			;eeee
	rla			;eeef
	ld e,a			;eef0
	ld d,000h		;eef1
	ld hl,leaadh		;eef3
	add hl,de		;eef6
	ld de,0eb2dh		;eef7
	ld bc,00010h		;eefa
	ldir			;eefd
	pop bc			;eeff
	ld hl,leb0dh		;ef00
	add hl,bc		;ef03
	ex de,hl		;ef04
	ld hl,0000ah		;ef05
	add hl,de		;ef08
	ex de,hl		;ef09
	ld a,(0eb2dh)		;ef0a
	ld (de),a		;ef0d
	inc de			;ef0e
	ld a,(leb2eh)		;ef0f
	ld (de),a		;ef12
lef13h:
	ex de,hl		;ef13
	pop hl			;ef14
	ld sp,hl		;ef15
	ex de,hl		;ef16
	ret			;ef17
lef18h:
	ld h,b			;ef18
	ld l,c			;ef19
	ld (leb3eh),hl		;ef1a
	ret			;ef1d
lef1eh:
	ld a,c			;ef1e
	ld (leb40h),a		;ef1f
	ret			;ef22
lef23h:
	ld h,b			;ef23
	ld l,c			;ef24
	ld (leb54h),hl		;ef25
	ret			;ef28
lef29h:
	ld h,b			;ef29
	ld l,c			;ef2a
	ret			;ef2b
lef2ch:
	ld a,001h		;ef2c
	ld (leb51h+1),a		;ef2e
	ld (leb51h),a		;ef31
	ld a,002h		;ef34
	ld (leb51h+2),a		;ef36
	jp lefc0h		;ef39
lef3ch:
	xor a			;ef3c
	ld (leb51h+1),a		;ef3d
	ld a,c			;ef40
	ld (leb51h+2),a		;ef41
	cp 002h			;ef44
	jp nz,lef61h		;ef46
	ld a,(leb2eh+1)		;ef49
	ld (leb48h+2),a		;ef4c
	ld a,(leb3dh)		;ef4f
	ld (leb4bh),a		;ef52
	ld hl,(leb3eh)		;ef55
	ld (leb4ch),hl		;ef58
	ld a,(leb40h)		;ef5b
	ld (leb4eh),a		;ef5e
lef61h:
	ld a,(leb48h+2)		;ef61
	or a			;ef64
	jp z,lefb6h		;ef65
	dec a			;ef68
	ld (leb48h+2),a		;ef69
	ld a,(leb3dh)		;ef6c
	ld hl,leb4bh		;ef6f
	cp (hl)			;ef72
	jp nz,lefb6h		;ef73
	ld hl,leb4ch		;ef76
	call sub_f074h		;ef79
	jp nz,lefb6h		;ef7c
	ld a,(leb40h)		;ef7f
	ld hl,leb4eh		;ef82
	cp (hl)			;ef85
	jp nz,lefb6h		;ef86
	inc (hl)		;ef89
	ld a,(hl)		;ef8a
	ld hl,leb2eh+2		;ef8b
	cp (hl)			;ef8e
	jp c,lef9eh		;ef8f
	ld hl,leb4eh		;ef92
	ld (hl),000h		;ef95
	ld hl,(leb4ch)		;ef97
	inc hl			;ef9a
	ld (leb4ch),hl		;ef9b
lef9eh:
	xor a			;ef9e
	ld (leb51h),a		;ef9f
	ld a,(leb40h)		;efa2
	ld hl,leb31h		;efa5
	and (hl)		;efa8
	cp (hl)			;efa9
	ld a,000h		;efaa
	jp nz,lefb0h		;efac
	inc a			;efaf
lefb0h:
	ld (leb4fh),a		;efb0
	jp lefc0h		;efb3
lefb6h:
	xor a			;efb6
	ld (leb48h+2),a		;efb7
	ld a,(leb31h)		;efba
	ld (leb51h),a		;efbd
lefc0h:
	ld hl,00000h		;efc0
	add hl,sp		;efc3
	ld sp,lf680h		;efc4
	push hl			;efc7
	ld a,(leb32h)		;efc8
	ld b,a			;efcb
	ld a,(leb40h)		;efcc
lefcfh:
	dec b			;efcf
	jp z,lefd8h		;efd0
	or a			;efd3
	rra			;efd4
	jp lefcfh		;efd5
lefd8h:
	ld (leb47h),a		;efd8
	ld hl,leb48h		;efdb
	ld a,(hl)		;efde
	ld (hl),001h		;efdf
	or a			;efe1
	jp z,lf009h		;efe2
	ld a,(leb3dh)		;efe5
	ld hl,leb41h		;efe8
	cp (hl)			;efeb
	jp nz,lf002h		;efec
	ld hl,leb42h		;efef
	call sub_f074h		;eff2
	jp nz,lf002h		;eff5
	ld a,(leb47h)		;eff8
	ld hl,leb44h		;effb
	cp (hl)			;effe
	jp z,lf026h		;efff
lf002h:
	ld a,(leb48h+1)		;f002
	or a			;f005
	call nz,sub_f080h	;f006
lf009h:
	ld a,(leb3dh)		;f009
	ld (leb41h),a		;f00c
	ld hl,(leb3eh)		;f00f
	ld (leb42h),hl		;f012
	ld a,(leb47h)		;f015
	ld (leb44h),a		;f018
	ld a,(leb51h)		;f01b
	or a			;f01e
	call nz,sub_f086h	;f01f
	xor a			;f022
	ld (leb48h+1),a		;f023
lf026h:
	ld a,(leb40h)		;f026
	ld hl,leb31h		;f029
	and (hl)		;f02c
	ld l,a			;f02d
	ld h,000h		;f02e
	add hl,hl		;f030
	add hl,hl		;f031
	add hl,hl		;f032
	add hl,hl		;f033
	add hl,hl		;f034
	add hl,hl		;f035
	add hl,hl		;f036
	ld de,leb56h		;f037
	add hl,de		;f03a
	ex de,hl		;f03b
	ld hl,(leb54h)		;f03c
	ld bc,00080h		;f03f
	ex de,hl		;f042
	ld a,(leb51h+1)		;f043
	or a			;f046
	jp nz,lf050h		;f047
	ld a,001h		;f04a
	ld (leb48h+1),a		;f04c
	ex de,hl		;f04f
lf050h:
	ldir			;f050
	ld a,(leb51h+2)		;f052
	cp 001h			;f055
	ld hl,leb50h		;f057
	ld a,(hl)		;f05a
	ld (hl),000h		;f05b
	jp nz,lf071h		;f05d
	or a			;f060
	jp nz,lf071h		;f061
	xor a			;f064
	ld (leb48h+1),a		;f065
	call sub_f080h		;f068
	ld hl,leb50h		;f06b
	ld a,(hl)		;f06e
	ld (hl),000h		;f06f
lf071h:
	pop hl			;f071
	ld sp,hl		;f072
	ret			;f073
sub_f074h:
	ex de,hl		;f074
	ld hl,leb3eh		;f075
	ld a,(de)		;f078
	cp (hl)			;f079
	ret nz			;f07a
	inc de			;f07b
	inc hl			;f07c
	ld a,(de)		;f07d
	cp (hl)			;f07e
	ret			;f07f
sub_f080h:
	call sub_f096h		;f080
	jp lf156h		;f083
sub_f086h:
	ld a,(leb4fh)		;f086
	or a			;f089
	jp nz,lf090h		;f08a
	ld (leb48h+2),a		;f08d
lf090h:
	call sub_f096h		;f090
	jp lf10ch		;f093
sub_f096h:
	ld a,(leb44h)		;f096
	ld c,a			;f099
	ld a,(lee8bh)		;f09a
	ld b,a			;f09d
	dec a			;f09e
	cp c			;f09f
	ld a,(leb41h)		;f0a0
	jp nc,lf0b1h		;f0a3
	or 004h			;f0a6
	ld (lee8ch+1),a		;f0a8
	ld a,c			;f0ab
	sub b			;f0ac
	ld c,a			;f0ad
	jp lf0b4h		;f0ae
lf0b1h:
	ld (lee8ch+1),a		;f0b1
lf0b4h:
	ld b,000h		;f0b4
	ld hl,(leb33h)		;f0b6
	add hl,bc		;f0b9
	ld a,(hl)		;f0ba
	ld (lee91h),a		;f0bb
	ld a,(leb42h)		;f0be
	ld (lee90h),a		;f0c1
	ld hl,leb56h		;f0c4
	ld (lee8ch+2),hl	;f0c7
	ld a,(leb41h)		;f0ca
	ld hl,leb45h		;f0cd
	cp (hl)			;f0d0
	jp nz,lf0dch		;f0d1
	ld a,(leb42h)		;f0d4
	ld hl,leb46h		;f0d7
	cp (hl)			;f0da
	ret z			;f0db
lf0dch:
	ld a,(leb41h)		;f0dc
	ld (leb45h),a		;f0df
	ld a,(leb42h)		;f0e2
	ld (leb46h),a		;f0e5
	call sub_f26fh		;f0e8
	call sub_f236h		;f0eb
	call lf276h		;f0ee
	ld a,(lee8ch+1)		;f0f1
	and 003h		;f0f4
	add a,020h		;f0f6
	cp b			;f0f8
	ret z			;f0f9
sub_f0fah:
	call sub_f26fh		;f0fa
	call sub_f1eah		;f0fd
	push bc			;f100
	call lf276h		;f101
	call sub_f236h		;f104
	call lf276h		;f107
	pop bc			;f10a
	ret			;f10b
lf10ch:
	ld a,00ah		;f10c
	ld (lee92h),a		;f10e
lf111h:
	call sub_f18bh		;f111
	call sub_f26fh		;f114
	ld hl,(lee88h)		;f117
	ld c,(hl)		;f11a
	inc hl			;f11b
	ld b,(hl)		;f11c
	inc hl			;f11d
	call sub_f2aeh		;f11e
	call sub_f176h		;f121
	call sub_f285h		;f124
	ld c,000h		;f127
lf129h:
	ld hl,lee93h		;f129
	ld a,(hl)		;f12c
	and 0f8h		;f12d
	ret z			;f12f
	and 008h		;f130
	jp nz,lf14ch		;f132
	ld a,(lee92h)		;f135
	dec a			;f138
	ld (lee92h),a		;f139
	jp z,lf14ch		;f13c
	cp 005h			;f13f
	call z,sub_f0fah	;f141
	xor a			;f144
	cp c			;f145
	jp z,lf111h		;f146
	jp lf15bh		;f149
lf14ch:
	ld a,c			;f14c
	ld (leb48h),a		;f14d
	ld a,001h		;f150
	ld (leb50h),a		;f152
	ret			;f155
lf156h:
	ld a,00ah		;f156
	ld (lee92h),a		;f158
lf15bh:
	call sub_f18bh		;f15b
	call sub_f26fh		;f15e
	ld hl,(lee88h)		;f161
	ld c,(hl)		;f164
	inc hl			;f165
	ld b,(hl)		;f166
	inc hl			;f167
	call sub_f28dh		;f168
	call sub_f17bh		;f16b
	call sub_f285h		;f16e
	ld c,001h		;f171
	jp lf129h		;f173
sub_f176h:
	ld a,006h		;f176
	jp lf2b8h		;f178
sub_f17bh:
	ld a,005h		;f17b
	jp lf2b8h		;f17d
sub_f180h:
	ld hl,leaeeh		;f180
	ld a,(lee8ah)		;f183
	ld e,a			;f186
	ld d,000h		;f187
	add hl,de		;f189
	ret			;f18a
sub_f18bh:
	in a,(014h)		;f18b
	and 080h		;f18d
	ret z			;f18f
	di			;f190
	ld hl,(0ffe1h)		;f191
	ld a,l			;f194
	or h			;f195
	ld hl,(0ffe7h)		;f196
	ld (0ffe1h),hl		;f199
	ei			;f19c
	ret nz			;f19d
	ld a,001h		;f19e
	out (014h),a		;f1a0
	ld hl,00032h		;f1a2
	call sub_f1b3h		;f1a5
	ret			;f1a8
sub_f1a9h:
	in a,(014h)		;f1a9
	and 080h		;f1ab
	ret z			;f1ad
	ld a,000h		;f1ae
	out (014h),a		;f1b0
	ret			;f1b2
sub_f1b3h:
	ld (0ffe3h),hl		;f1b3
lf1b6h:
	ld hl,(0ffe3h)		;f1b6
	ld a,l			;f1b9
	or h			;f1ba
	jp nz,lf1b6h		;f1bb
	ret			;f1be
lf1bfh:
	ld a,(leb3dh)		;f1bf
	ld (lee8ch+1),a		;f1c2
	ld (leb45h),a		;f1c5
	xor a			;f1c8
	ld (leb46h),a		;f1c9
	call sub_f26fh		;f1cc
	call sub_f1eah		;f1cf
	call lf276h		;f1d2
	ret			;f1d5
lf1d6h:
	in a,(004h)		;f1d6
	and 0c0h		;f1d8
	cp 080h			;f1da
	jp nz,lf1d6h		;f1dc
	ret			;f1df
lf1e0h:
	in a,(004h)		;f1e0
	and 0c0h		;f1e2
	cp 0c0h			;f1e4
	jp nz,lf1e0h		;f1e6
	ret			;f1e9
sub_f1eah:
	call sub_f18bh		;f1ea
	call lf1d6h		;f1ed
	ld a,007h		;f1f0
	out (005h),a		;f1f2
	call lf1d6h		;f1f4
	ld a,(lee8ch+1)		;f1f7
	and 003h		;f1fa
	out (005h),a		;f1fc
	ret			;f1fe
	call lf1d6h		;f1ff
	ld a,004h		;f202
	out (005h),a		;f204
	call lf1d6h		;f206
	ld a,(lee8ch+1)		;f209
	and 003h		;f20c
	out (005h),a		;f20e
	call lf1e0h		;f210
	in a,(005h)		;f213
	ld (lee93h),a		;f215
	ret			;f218
sub_f219h:
	call lf1d6h		;f219
	ld a,008h		;f21c
	out (005h),a		;f21e
	call lf1e0h		;f220
	in a,(005h)		;f223
	ld (lee93h),a		;f225
	and 0c0h		;f228
	cp 080h			;f22a
	ret z			;f22c
	call lf1e0h		;f22d
	in a,(005h)		;f230
	ld (lee94h),a		;f232
	ret			;f235
sub_f236h:
	call sub_f18bh		;f236
	call lf1d6h		;f239
	ld a,00fh		;f23c
	out (005h),a		;f23e
	call lf1d6h		;f240
	ld a,(lee8ch+1)		;f243
	and 003h		;f246
	out (005h),a		;f248
	call lf1d6h		;f24a
	ld a,(lee90h)		;f24d
	out (005h),a		;f250
	ret			;f252
sub_f253h:
	ld hl,lee93h		;f253
	ld d,007h		;f256
lf258h:
	call lf1e0h		;f258
	in a,(005h)		;f25b
	ld (hl),a		;f25d
	inc hl			;f25e
	ld a,004h		;f25f
lf261h:
	dec a			;f261
	jp nz,lf261h		;f262
	in a,(004h)		;f265
	and 010h		;f267
	ret z			;f269
	dec d			;f26a
	jp nz,lf258h		;f26b
	ret			;f26e
sub_f26fh:
	di			;f26f
	xor a			;f270
	ld (lee9bh),a		;f271
	ei			;f274
	ret			;f275
lf276h:
	call sub_f285h		;f276
	ld a,(lee93h)		;f279
	ld b,a			;f27c
	ld a,(lee94h)		;f27d
	ld c,a			;f280
	call sub_f26fh		;f281
	ret			;f284
sub_f285h:
	ld a,(lee9bh)		;f285
	or a			;f288
	jp z,sub_f285h		;f289
	ret			;f28c
sub_f28dh:
	ld a,005h		;f28d
	di			;f28f
	out (0fah),a		;f290
	ld a,049h		;f292
lf294h:
	out (0fbh),a		;f294
	out (0fch),a		;f296
	ld a,(lee8ch+2)		;f298
	out (0f2h),a		;f29b
	ld a,(lee8fh)		;f29d
	out (0f2h),a		;f2a0
	ld a,c			;f2a2
	out (0f3h),a		;f2a3
	ld a,b			;f2a5
	out (0f3h),a		;f2a6
	ld a,001h		;f2a8
	out (0fah),a		;f2aa
	ei			;f2ac
	ret			;f2ad
sub_f2aeh:
	ld a,005h		;f2ae
	di			;f2b0
	out (0fah),a		;f2b1
	ld a,045h		;f2b3
	jp lf294h		;f2b5
lf2b8h:
	push af			;f2b8
	di			;f2b9
	call lf1d6h		;f2ba
	pop af			;f2bd
	ld b,(hl)		;f2be
	inc hl			;f2bf
	add a,b			;f2c0
	out (005h),a		;f2c1
	call lf1d6h		;f2c3
	ld a,(lee8ch+1)		;f2c6
	out (005h),a		;f2c9
	call lf1d6h		;f2cb
	ld a,(lee90h)		;f2ce
	out (005h),a		;f2d1
	call lf1d6h		;f2d3
	ld a,(lee8ch+1)		;f2d6
	rra			;f2d9
	rra			;f2da
	and 003h		;f2db
	out (005h),a		;f2dd
	call lf1d6h		;f2df
	ld a,(lee91h)		;f2e2
	out (005h),a		;f2e5
	call lf1d6h		;f2e7
	ld a,(hl)		;f2ea
	inc hl			;f2eb
	out (005h),a		;f2ec
	call lf1d6h		;f2ee
	ld a,(hl)		;f2f1
	inc hl			;f2f2
	out (005h),a		;f2f3
	call lf1d6h		;f2f5
	ld a,(hl)		;f2f8
	out (005h),a		;f2f9
	call lf1d6h		;f2fb
	ld a,(0eb35h)		;f2fe
	out (005h),a		;f301
	ei			;f303
	ret			;f304
	ld (lee9ch),sp		;f305
	ld sp,lf620h		;f309
	push af			;f30c
	push bc			;f30d
	push de			;f30e
	push hl			;f30f
	ld a,0ffh		;f310
	ld (lee9bh),a		;f312
	ld a,005h		;f315
lf317h:
	dec a			;f317
	jp nz,lf317h		;f318
	in a,(004h)		;f31b
	and 010h		;f31d
	jp nz,lf328h		;f31f
	call sub_f219h		;f322
	jp lf32bh		;f325
lf328h:
	call sub_f253h		;f328
lf32bh:
	pop hl			;f32b
	pop de			;f32c
	pop bc			;f32d
	pop af			;f32e
	ld sp,(lee9ch)		;f32f
	ei			;f333
	reti			;f334
	ei			;f336
	reti			;f337
	nop			;f339
	nop			;f33a
	nop			;f33b
	nop			;f33c
	nop			;f33d
	nop			;f33e
	nop			;f33f
	nop			;f340
	nop			;f341
	nop			;f342
	nop			;f343
	nop			;f344
	nop			;f345
	nop			;f346
	nop			;f347
	nop			;f348
	nop			;f349
	nop			;f34a
	nop			;f34b
	nop			;f34c
	nop			;f34d
	nop			;f34e
	nop			;f34f
	nop			;f350
	nop			;f351
	nop			;f352
	nop			;f353
	nop			;f354
	nop			;f355
	nop			;f356
	nop			;f357
	nop			;f358
	nop			;f359
	nop			;f35a
	nop			;f35b
	nop			;f35c
	nop			;f35d
	nop			;f35e
	nop			;f35f
	nop			;f360
	nop			;f361
	nop			;f362
	nop			;f363
	nop			;f364
	nop			;f365
	nop			;f366
	nop			;f367
	nop			;f368
	nop			;f369
	nop			;f36a
	nop			;f36b
	nop			;f36c
	nop			;f36d
	nop			;f36e
	nop			;f36f
	nop			;f370
	nop			;f371
	nop			;f372
	nop			;f373
	nop			;f374
	nop			;f375
	nop			;f376
	nop			;f377
	nop			;f378
	nop			;f379
	nop			;f37a
	nop			;f37b
	nop			;f37c
	nop			;f37d
	nop			;f37e
	nop			;f37f
	nop			;f380
	nop			;f381
	nop			;f382
	nop			;f383
	nop			;f384
	nop			;f385
	nop			;f386
	nop			;f387
	nop			;f388
	nop			;f389
	nop			;f38a
	nop			;f38b
	nop			;f38c
	nop			;f38d
	nop			;f38e
	nop			;f38f
	nop			;f390
	nop			;f391
	nop			;f392
	nop			;f393
	nop			;f394
	nop			;f395
	nop			;f396
	nop			;f397
	nop			;f398
	nop			;f399
	nop			;f39a
	nop			;f39b
	nop			;f39c
	nop			;f39d
	nop			;f39e
	nop			;f39f
	nop			;f3a0
	nop			;f3a1
	nop			;f3a2
	nop			;f3a3
	nop			;f3a4
	nop			;f3a5
	nop			;f3a6
	nop			;f3a7
	nop			;f3a8
	nop			;f3a9
	nop			;f3aa
	nop			;f3ab
	nop			;f3ac
	nop			;f3ad
	nop			;f3ae
	nop			;f3af
	nop			;f3b0
	nop			;f3b1
	nop			;f3b2
	nop			;f3b3
	nop			;f3b4
	nop			;f3b5
	nop			;f3b6
	nop			;f3b7
	nop			;f3b8
	nop			;f3b9
	nop			;f3ba
	nop			;f3bb
	nop			;f3bc
	nop			;f3bd
	nop			;f3be
	nop			;f3bf
	nop			;f3c0
	nop			;f3c1
	nop			;f3c2
	nop			;f3c3
	nop			;f3c4
	nop			;f3c5
	nop			;f3c6
	nop			;f3c7
	nop			;f3c8
	nop			;f3c9
	nop			;f3ca
	nop			;f3cb
	nop			;f3cc
	nop			;f3cd
	nop			;f3ce
	nop			;f3cf
	nop			;f3d0
	nop			;f3d1
	nop			;f3d2
	nop			;f3d3
	nop			;f3d4
	nop			;f3d5
	nop			;f3d6
	nop			;f3d7
	nop			;f3d8
	nop			;f3d9
	nop			;f3da
	nop			;f3db
	nop			;f3dc
	nop			;f3dd
	nop			;f3de
	nop			;f3df
	nop			;f3e0
	nop			;f3e1
	nop			;f3e2
	nop			;f3e3
	nop			;f3e4
	nop			;f3e5
	nop			;f3e6
	nop			;f3e7
	nop			;f3e8
	nop			;f3e9
	nop			;f3ea
	nop			;f3eb
	nop			;f3ec
	nop			;f3ed
	nop			;f3ee
	nop			;f3ef
	nop			;f3f0
	nop			;f3f1
	nop			;f3f2
	nop			;f3f3
	nop			;f3f4
	nop			;f3f5
	nop			;f3f6
	nop			;f3f7
	nop			;f3f8
	nop			;f3f9
	nop			;f3fa
	nop			;f3fb
	nop			;f3fc
	nop			;f3fd
	nop			;f3fe
	nop			;f3ff
	ld (hl),0f3h		;f400
	ld c,0e5h		;f402
	inc hl			;f404
	push hl			;f405
	ld (hl),0f3h		;f406
	ld (hl),0f3h		;f408
	ld (hl),0f3h		;f40a
	sbc a,d			;f40c
	jp (hl)			;f40d
	dec b			;f40e
	di			;f40f
	inc h			;f410
	call po,sub_e43dh	;f411
	ld d,(hl)		;f414
	call po,sub_e46bh	;f415
	adc a,b			;f418
	call po,sub_e4a1h	;f419
	cp d			;f41c
	call po,sub_e4d4h	;f41d
	nop			;f420
	call p,00000h		;f421
	nop			;f424
	nop			;f425
	nop			;f426
	nop			;f427
	nop			;f428
	nop			;f429
	ld hl,(00017h)		;f42a
	nop			;f42d
	ld (bc),a		;f42e
	nop			;f42f
	ld bc,03201h		;f430
	sub h			;f433
	xor 0c9h		;f434
	call sub_f18bh		;f436
	call lf1d6h		;f439
	ld a,00fh		;f43c
	out (005h),a		;f43e
	call lf1d6h		;f440
	ld a,(lee8ch+1)		;f443
	and 003h		;f446
	out (005h),a		;f448
	call lf1d6h		;f44a
	ld a,(lee90h)		;f44d
	out (005h),a		;f450
	ret			;f452
	ld hl,lee93h		;f453
	ld d,007h		;f456
	call lf1e0h		;f458
	in a,(005h)		;f45b
	ld (hl),a		;f45d
	inc hl			;f45e
	ld a,004h		;f45f
	dec a			;f461
	jp nz,lf261h		;f462
	in a,(004h)		;f465
	and 010h		;f467
	ret z			;f469
	dec d			;f46a
	jp nz,lf258h		;f46b
	ret			;f46e
	di			;f46f
	xor a			;f470
	ld (lee9bh),a		;f471
	ei			;f474
	ret			;f475
	call sub_f285h		;f476
	ld a,(lee93h)		;f479
	ld b,a			;f47c
	ld a,(lee94h)		;f47d
	ld c,a			;f480
	call sub_f26fh		;f481
	ret			;f484
	ld a,(lee9bh)		;f485
	or a			;f488
	jp z,sub_f285h		;f489
	ret			;f48c
	ld a,005h		;f48d
	di			;f48f
	out (0fah),a		;f490
	ld a,049h		;f492
	out (0fbh),a		;f494
	out (0fch),a		;f496
	ld a,(lee8ch+2)		;f498
	out (0f2h),a		;f49b
	ld a,(lee8fh)		;f49d
	out (0f2h),a		;f4a0
	ld a,c			;f4a2
	out (0f3h),a		;f4a3
	ld a,b			;f4a5
	out (0f3h),a		;f4a6
	ld a,001h		;f4a8
	out (0fah),a		;f4aa
	ei			;f4ac
	ret			;f4ad
	ld a,005h		;f4ae
	di			;f4b0
	out (0fah),a		;f4b1
	ld a,045h		;f4b3
	jp lf294h		;f4b5
	push af			;f4b8
	di			;f4b9
	call lf1d6h		;f4ba
	pop af			;f4bd
	ld b,(hl)		;f4be
	inc hl			;f4bf
	add a,b			;f4c0
	out (005h),a		;f4c1
	call lf1d6h		;f4c3
	ld a,(lee8ch+1)		;f4c6
	out (005h),a		;f4c9
	call lf1d6h		;f4cb
	ld a,(lee90h)		;f4ce
	out (005h),a		;f4d1
	call lf1d6h		;f4d3
	ld a,(lee8ch+1)		;f4d6
	rra			;f4d9
	rra			;f4da
	and 003h		;f4db
	out (005h),a		;f4dd
	call lf1d6h		;f4df
	ld a,(lee91h)		;f4e2
	out (005h),a		;f4e5
	call lf1d6h		;f4e7
	ld a,(hl)		;f4ea
	inc hl			;f4eb
	out (005h),a		;f4ec
	call lf1d6h		;f4ee
	ld a,(hl)		;f4f1
	inc hl			;f4f2
	out (005h),a		;f4f3
	call lf1d6h		;f4f5
	ld a,(hl)		;f4f8
	out (005h),a		;f4f9
	call lf1d6h		;f4fb
	ld a,(00035h)		;f4fe
	nop			;f501
	nop			;f502
	nop			;f503
	nop			;f504
	nop			;f505
	nop			;f506
	nop			;f507
	nop			;f508
	nop			;f509
lf50ah:
	nop			;f50a
	nop			;f50b
	nop			;f50c
	nop			;f50d
	nop			;f50e
	nop			;f50f
	nop			;f510
	nop			;f511
	nop			;f512
	nop			;f513
	nop			;f514
	nop			;f515
	nop			;f516
	nop			;f517
	nop			;f518
	nop			;f519
	nop			;f51a
	nop			;f51b
	nop			;f51c
	nop			;f51d
	nop			;f51e
	nop			;f51f
	nop			;f520
	nop			;f521
	nop			;f522
	nop			;f523
	nop			;f524
	nop			;f525
	nop			;f526
	nop			;f527
	nop			;f528
	nop			;f529
	nop			;f52a
	nop			;f52b
	nop			;f52c
	nop			;f52d
	nop			;f52e
	nop			;f52f
	nop			;f530
	nop			;f531
	nop			;f532
	nop			;f533
	nop			;f534
	nop			;f535
	nop			;f536
	nop			;f537
	nop			;f538
	nop			;f539
	nop			;f53a
	nop			;f53b
	nop			;f53c
	nop			;f53d
	nop			;f53e
	nop			;f53f
	nop			;f540
	nop			;f541
	nop			;f542
	nop			;f543
	nop			;f544
	nop			;f545
	nop			;f546
	nop			;f547
	nop			;f548
	nop			;f549
	nop			;f54a
	nop			;f54b
	nop			;f54c
	nop			;f54d
	nop			;f54e
	nop			;f54f
	nop			;f550
	nop			;f551
	nop			;f552
	nop			;f553
	nop			;f554
	nop			;f555
	nop			;f556
	nop			;f557
	nop			;f558
	nop			;f559
	nop			;f55a
	nop			;f55b
	nop			;f55c
	nop			;f55d
	nop			;f55e
	nop			;f55f
	nop			;f560
	nop			;f561
	nop			;f562
	nop			;f563
	nop			;f564
	nop			;f565
	nop			;f566
	nop			;f567
	nop			;f568
	nop			;f569
	nop			;f56a
	nop			;f56b
	nop			;f56c
	nop			;f56d
	nop			;f56e
	nop			;f56f
	nop			;f570
	nop			;f571
	nop			;f572
	nop			;f573
	nop			;f574
	nop			;f575
	nop			;f576
	nop			;f577
	nop			;f578
	nop			;f579
	nop			;f57a
	nop			;f57b
	nop			;f57c
	nop			;f57d
	nop			;f57e
	nop			;f57f
	nop			;f580
	nop			;f581
	nop			;f582
	nop			;f583
	nop			;f584
	nop			;f585
	nop			;f586
	nop			;f587
	nop			;f588
	nop			;f589
	nop			;f58a
	nop			;f58b
	nop			;f58c
	nop			;f58d
	nop			;f58e
	nop			;f58f
	nop			;f590
	nop			;f591
	nop			;f592
	nop			;f593
	nop			;f594
	nop			;f595
	nop			;f596
	nop			;f597
	nop			;f598
	nop			;f599
	nop			;f59a
	nop			;f59b
	nop			;f59c
	nop			;f59d
	nop			;f59e
	nop			;f59f
	nop			;f5a0
	nop			;f5a1
	nop			;f5a2
	nop			;f5a3
	nop			;f5a4
	nop			;f5a5
	nop			;f5a6
	nop			;f5a7
	nop			;f5a8
	nop			;f5a9
	nop			;f5aa
	nop			;f5ab
	nop			;f5ac
	nop			;f5ad
	nop			;f5ae
	nop			;f5af
	nop			;f5b0
	nop			;f5b1
	nop			;f5b2
	nop			;f5b3
	nop			;f5b4
	nop			;f5b5
	nop			;f5b6
	nop			;f5b7
	nop			;f5b8
	nop			;f5b9
	nop			;f5ba
	nop			;f5bb
	nop			;f5bc
	nop			;f5bd
	nop			;f5be
	nop			;f5bf
	nop			;f5c0
	nop			;f5c1
	nop			;f5c2
	nop			;f5c3
	nop			;f5c4
	nop			;f5c5
	nop			;f5c6
	nop			;f5c7
	nop			;f5c8
	nop			;f5c9
	nop			;f5ca
	nop			;f5cb
	nop			;f5cc
	nop			;f5cd
	nop			;f5ce
	nop			;f5cf
	nop			;f5d0
	nop			;f5d1
	nop			;f5d2
	nop			;f5d3
	nop			;f5d4
	nop			;f5d5
	nop			;f5d6
	nop			;f5d7
	nop			;f5d8
	nop			;f5d9
	nop			;f5da
	nop			;f5db
	nop			;f5dc
	nop			;f5dd
	nop			;f5de
	nop			;f5df
	nop			;f5e0
	nop			;f5e1
	nop			;f5e2
	nop			;f5e3
	nop			;f5e4
	nop			;f5e5
	nop			;f5e6
	nop			;f5e7
	nop			;f5e8
	nop			;f5e9
	nop			;f5ea
	nop			;f5eb
	nop			;f5ec
	nop			;f5ed
	nop			;f5ee
lf5efh:
	nop			;f5ef
lf5f0h:
	nop			;f5f0
	nop			;f5f1
	nop			;f5f2
	nop			;f5f3
	nop			;f5f4
	nop			;f5f5
	nop			;f5f6
	nop			;f5f7
lf5f8h:
	nop			;f5f8
lf5f9h:
	nop			;f5f9
	nop			;f5fa
	push hl			;f5fb
	push hl			;f5fc
	push hl			;f5fd
	push hl			;f5fe
	push hl			;f5ff
	push hl			;f600
	push hl			;f601
	push hl			;f602
	push hl			;f603
	push hl			;f604
	push hl			;f605
	push hl			;f606
	push hl			;f607
	push hl			;f608
	push hl			;f609
	push hl			;f60a
	push hl			;f60b
	push hl			;f60c
	push hl			;f60d
	push hl			;f60e
	push hl			;f60f
	push hl			;f610
	push hl			;f611
	push hl			;f612
	push hl			;f613
	ld e,e			;f614
	jp p,lf32bh		;f615
	ld c,0d7h		;f618
	ld b,0cch		;f61a
	ld a,a			;f61c
	nop			;f61d
	ld b,h			;f61e
	nop			;f61f
lf620h:
	push hl			;f620
	push hl			;f621
	push hl			;f622
	push hl			;f623
	push hl			;f624
	push hl			;f625
	push hl			;f626
	push hl			;f627
	push hl			;f628
	push hl			;f629
	push hl			;f62a
	push hl			;f62b
	push hl			;f62c
	push hl			;f62d
	push hl			;f62e
	push hl			;f62f
	push hl			;f630
	push hl			;f631
	push hl			;f632
	push hl			;f633
	push hl			;f634
	push hl			;f635
	push hl			;f636
	push hl			;f637
	push hl			;f638
	push hl			;f639
	push hl			;f63a
	push hl			;f63b
	push hl			;f63c
	push hl			;f63d
	push hl			;f63e
	push hl			;f63f
	push hl			;f640
	push hl			;f641
	push hl			;f642
	push hl			;f643
	push hl			;f644
	push hl			;f645
	push hl			;f646
	push hl			;f647
	push hl			;f648
	push hl			;f649
	push hl			;f64a
	push hl			;f64b
	push hl			;f64c
	push hl			;f64d
	push hl			;f64e
	push hl			;f64f
	push hl			;f650
	push hl			;f651
	push hl			;f652
	push hl			;f653
	push hl			;f654
	push hl			;f655
	push hl			;f656
	push hl			;f657
	push hl			;f658
	push hl			;f659
	push hl			;f65a
	push hl			;f65b
	push hl			;f65c
	push hl			;f65d
	push hl			;f65e
	push hl			;f65f
	push hl			;f660
	push hl			;f661
	push hl			;f662
	push hl			;f663
	push hl			;f664
	push hl			;f665
	push hl			;f666
	push hl			;f667
	push hl			;f668
	push hl			;f669
	push hl			;f66a
	push hl			;f66b
	push hl			;f66c
	push hl			;f66d
	push hl			;f66e
	push hl			;f66f
	push hl			;f670
	push hl			;f671
	ld bc,03e02h		;f672
	jp (hl)			;f675
	sub c			;f676
	jp (hl)			;f677
	ld a,0d3h		;f678
	ld a,000h		;f67a
	ld b,h			;f67c
	nop			;f67d
	add hl,sp		;f67e
	rst 10h			;f67f
lf680h:
	nop			;f680
	ld bc,00302h		;f681
	inc b			;f684
	dec b			;f685
	ld b,007h		;f686
	ex af,af'		;f688
	add hl,bc		;f689
	ld a,(bc)		;f68a
	dec bc			;f68b
	inc c			;f68c
	dec c			;f68d
	ld c,00fh		;f68e
	djnz $+19		;f690
	ld (de),a		;f692
	inc de			;f693
	inc d			;f694
	dec d			;f695
	ld d,017h		;f696
	jr $+27			;f698
	ld a,(de)		;f69a
	dec de			;f69b
	inc e			;f69c
	dec e			;f69d
	ld e,01fh		;f69e
	jr nz,lf6c3h		;f6a0
	ld (02423h),hl		;f6a2
	dec h			;f6a5
	ld h,027h		;f6a6
	jr z,lf6d3h		;f6a8
	ld hl,(02c2bh)		;f6aa
	dec l			;f6ad
	ld l,02fh		;f6ae
	jr nc,lf6e3h		;f6b0
	ld (03433h),a		;f6b2
	dec (hl)		;f6b5
	ld (hl),037h		;f6b6
	jr c,lf6f3h		;f6b8
	ld a,(03c3bh)		;f6ba
	dec a			;f6bd
	ld a,03fh		;f6be
	dec b			;f6c0
	ld b,c			;f6c1
	ld b,d			;f6c2
lf6c3h:
	ld b,e			;f6c3
	ld b,h			;f6c4
	ld b,l			;f6c5
	ld b,(hl)		;f6c6
	ld b,a			;f6c7
	ld c,b			;f6c8
	ld c,c			;f6c9
	ld c,d			;f6ca
	ld c,e			;f6cb
	ld c,h			;f6cc
	ld c,l			;f6cd
	ld c,(hl)		;f6ce
	ld c,a			;f6cf
	ld d,b			;f6d0
	ld d,c			;f6d1
	ld d,d			;f6d2
lf6d3h:
	ld d,e			;f6d3
	ld d,h			;f6d4
	ld d,l			;f6d5
	ld d,(hl)		;f6d6
	ld d,a			;f6d7
	ld e,b			;f6d8
	ld e,c			;f6d9
	ld e,d			;f6da
	dec bc			;f6db
	inc c			;f6dc
	dec c			;f6dd
	ld e,(hl)		;f6de
	ld e,a			;f6df
	ld d,061h		;f6e0
	ld h,d			;f6e2
lf6e3h:
	ld h,e			;f6e3
	ld h,h			;f6e4
	ld h,l			;f6e5
	ld h,(hl)		;f6e6
	ld h,a			;f6e7
	ld l,b			;f6e8
	ld l,c			;f6e9
	ld l,d			;f6ea
	ld l,e			;f6eb
	ld l,h			;f6ec
	ld l,l			;f6ed
	ld l,(hl)		;f6ee
	ld l,a			;f6ef
	ld (hl),b		;f6f0
	ld (hl),c		;f6f1
	ld (hl),d		;f6f2
lf6f3h:
	ld (hl),e		;f6f3
	ld (hl),h		;f6f4
	ld (hl),l		;f6f5
	halt			;f6f6
	ld (hl),a		;f6f7
	ld a,b			;f6f8
	ld a,c			;f6f9
	ld a,d			;f6fa
	dec de			;f6fb
	inc e			;f6fc
	dec e			;f6fd
	rrca			;f6fe
	ld a,a			;f6ff
lf700h:
	nop			;f700
	ld bc,00302h		;f701
	inc b			;f704
	dec b			;f705
	ld b,007h		;f706
	ex af,af'		;f708
	add hl,bc		;f709
	ld a,(bc)		;f70a
	dec bc			;f70b
	inc c			;f70c
	dec c			;f70d
	ld c,00fh		;f70e
	djnz $+19		;f710
	ld (de),a		;f712
	inc de			;f713
	inc d			;f714
	dec d			;f715
	ld d,017h		;f716
	jr $+27			;f718
	ld a,(de)		;f71a
	dec de			;f71b
	inc e			;f71c
	dec e			;f71d
	ld e,01fh		;f71e
	jr nz,lf743h		;f720
	ld (02423h),hl		;f722
	dec h			;f725
	ld h,027h		;f726
	jr z,lf753h		;f728
	ld hl,(02c2bh)		;f72a
	dec l			;f72d
	ld l,02fh		;f72e
	jr nc,lf763h		;f730
	ld (03433h),a		;f732
	dec (hl)		;f735
	ld (hl),037h		;f736
	jr c,lf773h		;f738
	ld a,(03c3bh)		;f73a
	dec a			;f73d
	ld a,03fh		;f73e
	ld b,b			;f740
	ld b,c			;f741
	ld b,d			;f742
lf743h:
	ld b,e			;f743
	ld b,h			;f744
	ld b,l			;f745
	ld b,(hl)		;f746
	ld b,a			;f747
	ld c,b			;f748
	ld c,c			;f749
	ld c,d			;f74a
	ld c,e			;f74b
	ld c,h			;f74c
	ld c,l			;f74d
	ld c,(hl)		;f74e
	ld c,a			;f74f
	ld d,b			;f750
	ld d,c			;f751
	ld d,d			;f752
lf753h:
	ld d,e			;f753
	ld d,h			;f754
	ld d,l			;f755
	ld d,(hl)		;f756
	ld d,a			;f757
	ld e,b			;f758
	ld e,c			;f759
	ld e,d			;f75a
	ld e,e			;f75b
	ld e,h			;f75c
	ld e,l			;f75d
	ld e,(hl)		;f75e
	ld e,a			;f75f
	ld h,b			;f760
	ld h,c			;f761
	ld h,d			;f762
lf763h:
	ld h,e			;f763
	ld h,h			;f764
	ld h,l			;f765
	ld h,(hl)		;f766
	ld h,a			;f767
	ld l,b			;f768
	ld l,c			;f769
	ld l,d			;f76a
	ld l,e			;f76b
	ld l,h			;f76c
	ld l,l			;f76d
	ld l,(hl)		;f76e
	ld l,a			;f76f
	ld (hl),b		;f770
	ld (hl),c		;f771
	ld (hl),d		;f772
lf773h:
	ld (hl),e		;f773
	ld (hl),h		;f774
	ld (hl),l		;f775
	halt			;f776
	ld (hl),a		;f777
	ld a,b			;f778
	ld a,c			;f779
	ld a,d			;f77a
	ld a,e			;f77b
	ld a,h			;f77c
	ld a,l			;f77d
	ld a,(hl)		;f77e
	ld a,a			;f77f
	add a,b			;f780
	ld bc,00382h		;f781
	inc b			;f784
	dec b			;f785
	add a,(hl)		;f786
	add a,a			;f787
	ex af,af'		;f788
	add hl,bc		;f789
	ld a,(bc)		;f78a
	dec bc			;f78b
	inc c			;f78c
	dec c			;f78d
	ld c,08fh		;f78e
	djnz $-109		;f790
	sub d			;f792
	sub e			;f793
	inc d			;f794
	dec d			;f795
	sub (hl)		;f796
	sub a			;f797
	jr $+27			;f798
	ld a,(de)		;f79a
	dec de			;f79b
	inc e			;f79c
	sbc a,l			;f79d
	ld e,09fh		;f79e
	jr nz,lf7d3h		;f7a0
	ld (03433h),a		;f7a2
	dec (hl)		;f7a5
	ld (hl),037h		;f7a6
	jr c,$+59		;f7a8
	xor d			;f7aa
	jr nc,lf7dah		;f7ab
	xor l			;f7ad
	ld l,08bh		;f7ae
	jr nc,$+51		;f7b0
	ld (03433h),a		;f7b2
	dec (hl)		;f7b5
	ld (hl),037h		;f7b6
	jr c,lf7f3h		;f7b8
	cp d			;f7ba
	jr nc,lf7eah		;f7bb
	cp l			;f7bd
	ld l,083h		;f7be
	ld (de),a		;f7c0
	add a,(hl)		;f7c1
	jp nz,0c4c3h		;f7c2
	push bc			;f7c5
	add a,d			;f7c6
	rst 0			;f7c7
	ex af,af'		;f7c8
	add hl,bc		;f7c9
	ld a,(bc)		;f7ca
	add a,h			;f7cb
	add a,l			;f7cc
	call 0cfceh		;f7cd
	add a,c			;f7d0
	pop de			;f7d1
	add a,a			;f7d2
lf7d3h:
	out (0d4h),a		;f7d3
	push de			;f7d5
	add a,b			;f7d6
	rst 10h			;f7d7
	jr $-37			;f7d8
lf7dah:
	ld a,(de)		;f7da
	in a,(0dch)		;f7db
	defb 0ddh,0deh,030h ;illegal sequence	;f7dd
	ret po			;f7e0
	adc a,(hl)		;f7e1
	jp po,0e4e3h		;f7e2
	push hl			;f7e5
	adc a,d			;f7e6
	rst 20h			;f7e7
	ret pe			;f7e8
	jp (hl)			;f7e9
lf7eah:
	jp pe,08d8ch		;f7ea
	defb 0edh ;next byte illegal after ed	;f7ed
	xor 0efh		;f7ee
	adc a,c			;f7f0
	pop af			;f7f1
	adc a,a			;f7f2
lf7f3h:
	di			;f7f3
	call p,088f5h		;f7f4
	rst 30h			;f7f7
	ret m			;f7f8
	ld sp,hl		;f7f9
	jp m,0fcfbh		;f7fa
	defb 0fdh,0feh,07fh	;f7fd
