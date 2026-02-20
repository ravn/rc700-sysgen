; z80dasm 1.2.0
; command line: z80dasm -a -l -g 0xE200 -S syms_58k_z80dasm.sym -b blocks_58k.def -o compas_bios.asm compas_bios_disk.bin

	org 0e200h
DSPSTR:	equ 0xf800

BOOT:

; BLOCK 'jumptable' (start 0xe200 end 0xe233)
jumptable_start:
	jp BOOT_ENTRY		;e200
WBOOT:
	jp WBOOT_ENTRY		;e203
CONST:
	jp CONST_ENTRY		;e206
CONIN:
	jp CONIN_ENTRY		;e209
CONOUT:
	jp CONOUT_ENTRY		;e20c
LIST:
	jp LIST_ENTRY		;e20f
PUNCH:
	jp PUNCH_ENTRY		;e212
READER:
	jp READER_ENTRY		;e215
HOME:
	jp HOME_ENTRY		;e218
SELDSK:
	jp biosdata_end		;e21b
SETTRK:
	jp SETTRK_ENTRY		;e21e
SETSEC:
	jp SETSEC_ENTRY		;e221
SETDMA:
	jp SETDMA_ENTRY		;e224
READ:
	jp READ_ENTRY		;e227
WRITE:
	jp WRITE_ENTRY		;e22a
LISTST:
	jp LISTST_ENTRY		;e22d
SECTRAN:
	jp SECTRAN_ENTRY	;e230
jumptable_end:
ADRMOD:

; BLOCK 'config' (start 0xe233 end 0xe24a)
config_start:
	defb 000h		;e233
WR5A:
	defb 000h		;e234
WR5B:
	defb 000h		;e235
	defb 000h		;e236
DISKFMT:
	defb 008h		;e237
	defb 008h		;e238
	defb 000h		;e239
	defb 000h		;e23a
	defb 000h		;e23b
	defb 000h		;e23c
	defb 000h		;e23d
	defb 000h		;e23e
	defb 000h		;e23f
	defb 000h		;e240
	defb 000h		;e241
	defb 000h		;e242
	defb 000h		;e243
	defb 000h		;e244
	defb 000h		;e245
	defb 000h		;e246
	defb 000h		;e247
	defb 000h		;e248
	defb 000h		;e249
config_end:
JEXTVEC1:

; BLOCK 'extvec' (start 0xe24a end 0xe259)
extvec_start:
	jp EXTVEC1_ENTRY	;e24a
JEXTVEC2:
	jp EXTVEC2_ENTRY	;e24d
JEXTVEC3:
	jp EXTVEC3_ENTRY	;e250
JEXTVEC4:
	jp EXTVEC4_ENTRY	;e253
JEXTVEC5:
	jp EXTVEC5_ENTRY	;e256
extvec_end:

; BLOCK 'pad1' (start 0xe259 end 0xe25c)
pad1_start:
	defb 000h		;e259
	defb 000h		;e25a
	defb 000h		;e25b
pad1_end:
MSG_DISKERR:

; BLOCK 'messages' (start 0xe25c end 0xe289)
messages_start:
	defb 00dh		;e25c
	defb 00ah		;e25d
	defb 044h		;e25e
	defb 049h		;e25f
	defb 053h		;e260
	defb 04bh		;e261
	defb 045h		;e262
	defb 054h		;e263
	defb 054h		;e264
	defb 045h		;e265
	defb 020h		;e266
	defb 052h		;e267
	defb 045h		;e268
	defb 041h		;e269
	defb 044h		;e26a
	defb 020h		;e26b
	defb 045h		;e26c
	defb 052h		;e26d
	defb 052h		;e26e
	defb 04fh		;e26f
	defb 052h		;e270
	defb 00dh		;e271
	defb 00ah		;e272
	defb 000h		;e273
SIGNON:
	defb 00ch		;e274
	defb 035h		;e275
	defb 038h		;e276
	defb 04bh		;e277
	defb 020h		;e278
	defb 043h		;e279
	defb 050h		;e27a
	defb 02fh		;e27b
	defb 04dh		;e27c
	defb 020h		;e27d
	defb 056h		;e27e
	defb 045h		;e27f
	defb 052h		;e280
	defb 053h		;e281
	defb 020h		;e282
	defb 032h		;e283
	defb 02eh		;e284
	defb 032h		;e285
	defb 00dh		;e286
	defb 00ah		;e287
	defb 000h		;e288
messages_end:
PRTSTR:

; BLOCK 'code_main' (start 0xe289 end 0xea25)
code_main_start:
	ld a,(hl)		;e289
	or a			;e28a
	ret z			;e28b
	push hl			;e28c
	ld c,a			;e28d
	call CONOUT_ENTRY	;e28e
	pop hl			;e291
	inc hl			;e292
	jp messages_end		;e293
le296h:
	ld hl,pad1_end		;e296
	call messages_end	;e299
le29ch:
	jp le29ch		;e29c
EXTVEC4_ENTRY:
	ld a,0c3h		;e29f
	ld (0ffe5h),a		;e2a1
	ld (0ffe6h),hl		;e2a4
	ex de,hl		;e2a7
	ld (0ffdfh),hl		;e2a8
	ret			;e2ab
EXTVEC5_ENTRY:
	or a			;e2ac
	jp z,le2b8h		;e2ad
	ld de,(0fffch)		;e2b0
	ld hl,(0fffeh)		;e2b4
	ret			;e2b7
le2b8h:
	ld (0fffch),de		;e2b8
	ld (0fffeh),hl		;e2bc
	ret			;e2bf
EXTVEC3_ENTRY:
	add a,00ah		;e2c0
	ld c,a			;e2c2
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
BOOT_ENTRY:
	ld sp,00080h		;e2f8
	ld hl,SIGNON		;e2fb
	call messages_end	;e2fe
	xor a			;e301
	ld (00004h),a		;e302
	ld (leb48h),a		;e305
	ld (leb50h),a		;e308
	ld (leb49h),a		;e30b
	in a,(014h)		;e30e
	and 080h		;e310
	jp z,WBOOT_ENTRY	;e312
	ld c,001h		;e315
	call biosdata_end	;e317
	call HOME_ENTRY		;e31a
	ld a,b			;e31d
	and 010h		;e31e
	ld a,000h		;e320
	jr nz,le325h		;e322
	inc a			;e324
le325h:
	ld (lee8ch),a		;e325
WBOOT_ENTRY:
	ei			;e328
	ld c,000h		;e329
	call biosdata_end	;e32b
	xor a			;e32e
	ld (leb4ah),a		;e32f
	ld (00003h),a		;e332
	ld (lee8dh),a		;e335
	ld (le4f1h),a		;e338
	call HOME_ENTRY		;e33b
	ld sp,00080h		;e33e
	ld bc,0cc00h		;e341
	call SETDMA_ENTRY	;e344
	ld b,000h		;e347
	ld c,001h		;e349
	call SETTRK_ENTRY	;e34b
	ld c,000h		;e34e
	call SETSEC_ENTRY	;e350
le353h:
	push bc			;e353
	call READ_ENTRY		;e354
	or a			;e357
	jp nz,le296h		;e358
	ld hl,(leb54h)		;e35b
	ld de,00080h		;e35e
	add hl,de		;e361
	ld b,h			;e362
	ld c,l			;e363
	call SETDMA_ENTRY	;e364
	pop bc			;e367
	inc c			;e368
	call SETSEC_ENTRY	;e369
	ld a,c			;e36c
	cp 02ch			;e36d
	jp nz,le353h		;e36f
	ld bc,00080h		;e372
	call SETDMA_ENTRY	;e375
	di			;e378
	ld a,0c3h		;e379
	ld (00000h),a		;e37b
	ld hl,WBOOT		;e37e
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
LISTST_ENTRY:
	ld a,(le39fh)		;e3a8
	ret			;e3ab
LIST_ENTRY:
	ld a,(le39fh)		;e3ac
	or a			;e3af
	jp z,LIST_ENTRY		;e3b0
	di			;e3b3
	ld a,000h		;e3b4
	ld (le39fh),a		;e3b6
	ld a,005h		;e3b9
	out (00bh),a		;e3bb
	ld a,(WR5B)		;e3bd
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
	ld a,(WR5A)		;e3da
	add a,08ah		;e3dd
	out (00ah),a		;e3df
	ld a,001h		;e3e1
	out (00ah),a		;e3e3
	ld a,01bh		;e3e5
	out (00ah),a		;e3e7
	ei			;e3e9
	ret			;e3ea
EXTVEC2_ENTRY:
	ld a,(le3a0h)		;e3eb
	ret			;e3ee
READER_ENTRY:
	call EXTVEC2_ENTRY	;e3ef
	or a			;e3f2
	jp z,READER_ENTRY	;e3f3
	ld a,(le3a2h)		;e3f6
	push af			;e3f9
	call sub_e3d1h		;e3fa
	pop af			;e3fd
	ret			;e3fe
PUNCH_ENTRY:
	ld a,(le3a1h)		;e3ff
	or a			;e402
	jp z,PUNCH_ENTRY	;e403
	di			;e406
	ld a,000h		;e407
	ld (le3a1h),a		;e409
	ld a,005h		;e40c
	out (00ah),a		;e40e
	ld a,(WR5A)		;e410
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
ISR_CRT0:
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
ISR_CRT1:
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
ISR_CRT2:
	ld (lee9ch),sp		;e456
	ld sp,lf620h		;e45a
	push af			;e45d
	in a,(008h)		;e45e
	ld (le3a3h),a		;e460
	pop af			;e463
	ld sp,(lee9ch)		;e464
	ei			;e468
	reti			;e469
ISR_CRT3:
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
ISR_CRT4:
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
ISR_CRT5:
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
ISR_CRT6:
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
ISR_CRT7:
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
CONST_ENTRY:
	ld a,(le4f1h)		;e4f3
	ret			;e4f6
CONIN_ENTRY:
	ld a,(le4f1h)		;e4f7
	or a			;e4fa
	jp z,CONIN_ENTRY	;e4fb
	di			;e4fe
	xor a			;e4ff
	ld (le4f1h),a		;e500
	ei			;e503
	in a,(010h)		;e504
	ld c,a			;e506
	ld hl,lf700h		;e507
	call sub_e558h		;e50a
	ret			;e50d
ISR_CTC1:
	ld (lee9ch),sp		;e50e
	ld sp,lf620h		;e512
	push af			;e515
	ld a,0ffh		;e516
	ld (le4f1h),a		;e518
	pop af			;e51b
	ld sp,(lee9ch)		;e51c
	ei			;e520
	reti			;e521
ISR_CTC2:
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
	ld de,DSPSTR		;e5c8
	ld bc,00780h		;e5cb
	ldir			;e5ce
	ld hl,0ff80h		;e5d0
	ld (0ffd5h),hl		;e5d3
	ld a,(0ffdbh)		;e5d6
	cp 000h			;e5d9
	jp z,le5a4h		;e5db
	ld hl,lf50ah		;e5de
	ld de,lf500h		;e5e1
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
	ld de,lf500h		;e60a
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
	ld de,DSPSTR		;e67e
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
	ld de,DSPSTR		;e7f0
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
	ld de,lf500h		;e817
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
	ld hl,DSPSTR		;e83f
	ld de,lf500h		;e842
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
	ld a,(jumptable_end)	;e8d8
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
	ld de,DSPSTR		;e936
	add hl,de		;e939
	ld (hl),a		;e93a
	call sub_e73eh		;e93b
	ld a,(0ffdbh)		;e93e
	cp 002h			;e941
	ret nz			;e943
	ld hl,(0ffd8h)		;e944
	call sub_e5f2h		;e947
	ld de,lf500h		;e94a
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
CONOUT_ENTRY:
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
ISR_SIO_RX:
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
	ld hl,DSPSTR		;e9b1
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
code_main_end:
XLTTAB_MAXI26:

; BLOCK 'tables' (start 0xea25 end 0xeb0d)
tables_start:
	defb 001h		;ea25
	defb 007h		;ea26
	defb 00dh		;ea27
	defb 013h		;ea28
	defb 019h		;ea29
	defb 005h		;ea2a
	defb 00bh		;ea2b
	defb 011h		;ea2c
	defb 017h		;ea2d
	defb 003h		;ea2e
	defb 009h		;ea2f
	defb 00fh		;ea30
	defb 015h		;ea31
	defb 002h		;ea32
	defb 008h		;ea33
	defb 00eh		;ea34
	defb 014h		;ea35
	defb 01ah		;ea36
	defb 006h		;ea37
	defb 00ch		;ea38
	defb 012h		;ea39
	defb 018h		;ea3a
	defb 004h		;ea3b
	defb 00ah		;ea3c
	defb 010h		;ea3d
	defb 016h		;ea3e
	defb 001h		;ea3f
	defb 005h		;ea40
	defb 009h		;ea41
	defb 00dh		;ea42
	defb 002h		;ea43
	defb 006h		;ea44
	defb 00ah		;ea45
	defb 00eh		;ea46
	defb 003h		;ea47
	defb 007h		;ea48
	defb 00bh		;ea49
	defb 00fh		;ea4a
	defb 004h		;ea4b
	defb 008h		;ea4c
	defb 00ch		;ea4d
	defb 001h		;ea4e
	defb 003h		;ea4f
	defb 005h		;ea50
	defb 007h		;ea51
	defb 009h		;ea52
	defb 002h		;ea53
	defb 004h		;ea54
	defb 006h		;ea55
	defb 008h		;ea56
	defb 001h		;ea57
	defb 002h		;ea58
	defb 003h		;ea59
	defb 004h		;ea5a
	defb 005h		;ea5b
	defb 006h		;ea5c
	defb 007h		;ea5d
	defb 008h		;ea5e
	defb 009h		;ea5f
	defb 00ah		;ea60
	defb 00bh		;ea61
	defb 00ch		;ea62
	defb 00dh		;ea63
	defb 00eh		;ea64
	defb 00fh		;ea65
	defb 010h		;ea66
	defb 011h		;ea67
	defb 012h		;ea68
	defb 013h		;ea69
	defb 014h		;ea6a
	defb 015h		;ea6b
	defb 016h		;ea6c
	defb 017h		;ea6d
	defb 018h		;ea6e
	defb 019h		;ea6f
	defb 01ah		;ea70
	defb 01ah		;ea71
	defb 000h		;ea72
	defb 003h		;ea73
	defb 007h		;ea74
	defb 000h		;ea75
	defb 0f2h		;ea76
	defb 000h		;ea77
	defb 03fh		;ea78
	defb 000h		;ea79
	defb 0c0h		;ea7a
	defb 000h		;ea7b
	defb 010h		;ea7c
	defb 000h		;ea7d
	defb 002h		;ea7e
	defb 000h		;ea7f
	defb 078h		;ea80
	defb 000h		;ea81
	defb 004h		;ea82
	defb 00fh		;ea83
	defb 000h		;ea84
	defb 0c1h		;ea85
	defb 001h		;ea86
	defb 07fh		;ea87
	defb 000h		;ea88
	defb 0c0h		;ea89
	defb 000h		;ea8a
	defb 020h		;ea8b
	defb 000h		;ea8c
	defb 002h		;ea8d
	defb 000h		;ea8e
	defb 01ah		;ea8f
	defb 000h		;ea90
	defb 003h		;ea91
	defb 007h		;ea92
	defb 000h		;ea93
	defb 0f2h		;ea94
	defb 000h		;ea95
	defb 03fh		;ea96
	defb 000h		;ea97
	defb 0c0h		;ea98
	defb 000h		;ea99
	defb 010h		;ea9a
	defb 000h		;ea9b
	defb 000h		;ea9c
	defb 000h		;ea9d
	defb 068h		;ea9e
	defb 000h		;ea9f
	defb 004h		;eaa0
	defb 00fh		;eaa1
	defb 000h		;eaa2
	defb 0d7h		;eaa3
	defb 001h		;eaa4
	defb 07fh		;eaa5
	defb 000h		;eaa6
	defb 0c0h		;eaa7
	defb 000h		;eaa8
	defb 020h		;eaa9
	defb 000h		;eaaa
	defb 000h		;eaab
	defb 000h		;eaac
leaadh:
	defb 071h		;eaad
	defb 0eah		;eaae
	defb 008h		;eaaf
	defb 01ah		;eab0
	defb 000h		;eab1
	defb 001h		;eab2
	defb 025h		;eab3
	defb 0eah		;eab4
	defb 080h		;eab5
	defb 000h		;eab6
	defb 000h		;eab7
	defb 000h		;eab8
	defb 000h		;eab9
	defb 000h		;eaba
	defb 000h		;eabb
	defb 000h		;eabc
	defb 080h		;eabd
	defb 0eah		;eabe
	defb 010h		;eabf
	defb 078h		;eac0
	defb 003h		;eac1
	defb 003h		;eac2
	defb 03fh		;eac3
	defb 0eah		;eac4
	defb 0ffh		;eac5
	defb 000h		;eac6
	defb 000h		;eac7
	defb 000h		;eac8
	defb 000h		;eac9
	defb 000h		;eaca
	defb 000h		;eacb
	defb 000h		;eacc
	defb 071h		;eacd
	defb 0eah		;eace
	defb 008h		;eacf
	defb 01ah		;ead0
	defb 000h		;ead1
	defb 001h		;ead2
	defb 057h		;ead3
	defb 0eah		;ead4
	defb 080h		;ead5
	defb 000h		;ead6
	defb 000h		;ead7
	defb 000h		;ead8
	defb 000h		;ead9
	defb 000h		;eada
	defb 000h		;eadb
	defb 000h		;eadc
	defb 09eh		;eadd
	defb 0eah		;eade
	defb 008h		;eadf
	defb 068h		;eae0
	defb 001h		;eae1
	defb 002h		;eae2
	defb 057h		;eae3
	defb 0eah		;eae4
	defb 0ffh		;eae5
	defb 000h		;eae6
	defb 000h		;eae7
	defb 000h		;eae8
	defb 000h		;eae9
	defb 000h		;eaea
	defb 000h		;eaeb
	defb 000h		;eaec
	defb 01ah		;eaed
leaeeh:
	defb 07fh		;eaee
	defb 000h		;eaef
	defb 000h		;eaf0
	defb 000h		;eaf1
	defb 01ah		;eaf2
	defb 007h		;eaf3
	defb 04dh		;eaf4
	defb 01eh		;eaf5
	defb 0ffh		;eaf6
	defb 001h		;eaf7
	defb 040h		;eaf8
	defb 002h		;eaf9
	defb 00fh		;eafa
	defb 01bh		;eafb
	defb 04dh		;eafc
	defb 01ah		;eafd
	defb 07fh		;eafe
	defb 000h		;eaff
	defb 000h		;eb00
	defb 000h		;eb01
	defb 01ah		;eb02
	defb 007h		;eb03
	defb 04dh		;eb04
	defb 034h		;eb05
	defb 0ffh		;eb06
	defb 000h		;eb07
	defb 040h		;eb08
	defb 001h		;eb09
	defb 01ah		;eb0a
	defb 00eh		;eb0b
	defb 04dh		;eb0c
tables_end:

; BLOCK 'dph' (start 0xeb0d end 0xeb2d)
dph_start:
	defb 000h		;eb0d
	defb 000h		;eb0e
	defb 000h		;eb0f
	defb 000h		;eb10
	defb 000h		;eb11
	defb 000h		;eb12
	defb 000h		;eb13
	defb 000h		;eb14
	defb 056h		;eb15
	defb 0edh		;eb16
	defb 080h		;eb17
	defb 0eah		;eb18
	defb 00fh		;eb19
	defb 0eeh		;eb1a
	defb 0d6h		;eb1b
	defb 0edh		;eb1c
	defb 000h		;eb1d
	defb 000h		;eb1e
	defb 000h		;eb1f
	defb 000h		;eb20
	defb 000h		;eb21
	defb 000h		;eb22
	defb 000h		;eb23
	defb 000h		;eb24
	defb 056h		;eb25
	defb 0edh		;eb26
	defb 080h		;eb27
	defb 0eah		;eb28
	defb 068h		;eb29
	defb 0eeh		;eb2a
	defb 02fh		;eb2b
	defb 0eeh		;eb2c
dph_end:

; BLOCK 'biosdata' (start 0xeb2d end 0xee9e)
biosdata_start:
	defb 000h		;eb2d
leb2eh:
	defb 000h		;eb2e
leb2fh:
	defb 000h		;eb2f
leb30h:
	defb 000h		;eb30
leb31h:
	defb 000h		;eb31
leb32h:
	defb 000h		;eb32
leb33h:
	defb 000h		;eb33
	defb 000h		;eb34
leb35h:
	defb 000h		;eb35
	defb 000h		;eb36
	defb 000h		;eb37
	defb 000h		;eb38
	defb 000h		;eb39
	defb 000h		;eb3a
	defb 000h		;eb3b
	defb 000h		;eb3c
leb3dh:
	defb 000h		;eb3d
leb3eh:
	defb 000h		;eb3e
	defb 000h		;eb3f
leb40h:
	defb 000h		;eb40
leb41h:
	defb 000h		;eb41
leb42h:
	defb 000h		;eb42
	defb 000h		;eb43
leb44h:
	defb 000h		;eb44
leb45h:
	defb 000h		;eb45
leb46h:
	defb 000h		;eb46
leb47h:
	defb 000h		;eb47
leb48h:
	defb 000h		;eb48
leb49h:
	defb 000h		;eb49
leb4ah:
	defb 000h		;eb4a
leb4bh:
	defb 000h		;eb4b
leb4ch:
	defb 000h		;eb4c
	defb 000h		;eb4d
leb4eh:
	defb 000h		;eb4e
leb4fh:
	defb 000h		;eb4f
leb50h:
	defb 000h		;eb50
leb51h:
	defb 000h		;eb51
leb52h:
	defb 000h		;eb52
leb53h:
	defb 000h		;eb53
leb54h:
	defb 000h		;eb54
	defb 000h		;eb55
leb56h:
	defb 000h		;eb56
	defb 000h		;eb57
	defb 000h		;eb58
	defb 000h		;eb59
	defb 000h		;eb5a
	defb 000h		;eb5b
	defb 000h		;eb5c
	defb 000h		;eb5d
	defb 000h		;eb5e
	defb 000h		;eb5f
	defb 000h		;eb60
	defb 000h		;eb61
	defb 000h		;eb62
	defb 000h		;eb63
	defb 000h		;eb64
	defb 000h		;eb65
	defb 000h		;eb66
	defb 000h		;eb67
	defb 000h		;eb68
	defb 000h		;eb69
	defb 000h		;eb6a
	defb 000h		;eb6b
	defb 000h		;eb6c
	defb 000h		;eb6d
	defb 000h		;eb6e
	defb 000h		;eb6f
	defb 000h		;eb70
	defb 000h		;eb71
	defb 000h		;eb72
	defb 000h		;eb73
	defb 000h		;eb74
	defb 000h		;eb75
	defb 000h		;eb76
	defb 000h		;eb77
	defb 000h		;eb78
	defb 000h		;eb79
	defb 000h		;eb7a
	defb 000h		;eb7b
	defb 000h		;eb7c
	defb 000h		;eb7d
	defb 000h		;eb7e
	defb 000h		;eb7f
	defb 000h		;eb80
	defb 000h		;eb81
	defb 000h		;eb82
	defb 000h		;eb83
	defb 000h		;eb84
	defb 000h		;eb85
	defb 000h		;eb86
	defb 000h		;eb87
	defb 000h		;eb88
	defb 000h		;eb89
	defb 000h		;eb8a
	defb 000h		;eb8b
	defb 000h		;eb8c
	defb 000h		;eb8d
	defb 000h		;eb8e
	defb 000h		;eb8f
	defb 000h		;eb90
	defb 000h		;eb91
	defb 000h		;eb92
	defb 000h		;eb93
	defb 000h		;eb94
	defb 000h		;eb95
	defb 000h		;eb96
	defb 000h		;eb97
	defb 000h		;eb98
	defb 000h		;eb99
	defb 000h		;eb9a
	defb 000h		;eb9b
	defb 000h		;eb9c
	defb 000h		;eb9d
	defb 000h		;eb9e
	defb 000h		;eb9f
	defb 000h		;eba0
	defb 000h		;eba1
	defb 000h		;eba2
	defb 000h		;eba3
	defb 000h		;eba4
	defb 000h		;eba5
	defb 000h		;eba6
	defb 000h		;eba7
	defb 000h		;eba8
	defb 000h		;eba9
	defb 000h		;ebaa
	defb 000h		;ebab
	defb 000h		;ebac
	defb 000h		;ebad
	defb 000h		;ebae
	defb 000h		;ebaf
	defb 000h		;ebb0
	defb 000h		;ebb1
	defb 000h		;ebb2
	defb 000h		;ebb3
	defb 000h		;ebb4
	defb 000h		;ebb5
	defb 000h		;ebb6
	defb 000h		;ebb7
	defb 000h		;ebb8
	defb 000h		;ebb9
	defb 000h		;ebba
	defb 000h		;ebbb
	defb 000h		;ebbc
	defb 000h		;ebbd
	defb 000h		;ebbe
	defb 000h		;ebbf
	defb 000h		;ebc0
	defb 000h		;ebc1
	defb 000h		;ebc2
	defb 000h		;ebc3
	defb 000h		;ebc4
	defb 000h		;ebc5
	defb 000h		;ebc6
	defb 000h		;ebc7
	defb 000h		;ebc8
	defb 000h		;ebc9
	defb 000h		;ebca
	defb 000h		;ebcb
	defb 000h		;ebcc
	defb 000h		;ebcd
	defb 000h		;ebce
	defb 000h		;ebcf
	defb 000h		;ebd0
	defb 000h		;ebd1
	defb 000h		;ebd2
	defb 000h		;ebd3
	defb 000h		;ebd4
	defb 000h		;ebd5
	defb 000h		;ebd6
	defb 000h		;ebd7
	defb 000h		;ebd8
	defb 000h		;ebd9
	defb 000h		;ebda
	defb 000h		;ebdb
	defb 000h		;ebdc
	defb 000h		;ebdd
	defb 000h		;ebde
	defb 000h		;ebdf
	defb 000h		;ebe0
	defb 000h		;ebe1
	defb 000h		;ebe2
	defb 000h		;ebe3
	defb 000h		;ebe4
	defb 000h		;ebe5
	defb 000h		;ebe6
	defb 000h		;ebe7
	defb 000h		;ebe8
	defb 000h		;ebe9
	defb 000h		;ebea
	defb 000h		;ebeb
	defb 000h		;ebec
	defb 000h		;ebed
	defb 000h		;ebee
	defb 000h		;ebef
	defb 000h		;ebf0
	defb 000h		;ebf1
	defb 000h		;ebf2
	defb 000h		;ebf3
	defb 000h		;ebf4
	defb 000h		;ebf5
	defb 000h		;ebf6
	defb 000h		;ebf7
	defb 000h		;ebf8
	defb 000h		;ebf9
	defb 000h		;ebfa
	defb 000h		;ebfb
	defb 000h		;ebfc
	defb 000h		;ebfd
	defb 000h		;ebfe
	defb 000h		;ebff
	defb 000h		;ec00
	defb 000h		;ec01
	defb 000h		;ec02
	defb 000h		;ec03
	defb 000h		;ec04
	defb 000h		;ec05
	defb 000h		;ec06
	defb 000h		;ec07
	defb 000h		;ec08
	defb 000h		;ec09
	defb 000h		;ec0a
	defb 000h		;ec0b
	defb 000h		;ec0c
	defb 000h		;ec0d
	defb 000h		;ec0e
	defb 000h		;ec0f
	defb 000h		;ec10
	defb 000h		;ec11
	defb 000h		;ec12
	defb 000h		;ec13
	defb 000h		;ec14
	defb 000h		;ec15
	defb 000h		;ec16
	defb 000h		;ec17
	defb 000h		;ec18
	defb 000h		;ec19
	defb 000h		;ec1a
	defb 000h		;ec1b
	defb 000h		;ec1c
	defb 000h		;ec1d
	defb 000h		;ec1e
	defb 000h		;ec1f
	defb 000h		;ec20
	defb 000h		;ec21
	defb 000h		;ec22
	defb 000h		;ec23
	defb 000h		;ec24
	defb 000h		;ec25
	defb 000h		;ec26
	defb 000h		;ec27
	defb 000h		;ec28
	defb 000h		;ec29
	defb 000h		;ec2a
	defb 000h		;ec2b
	defb 000h		;ec2c
	defb 000h		;ec2d
	defb 000h		;ec2e
	defb 000h		;ec2f
	defb 000h		;ec30
	defb 000h		;ec31
	defb 000h		;ec32
	defb 000h		;ec33
	defb 000h		;ec34
	defb 000h		;ec35
	defb 000h		;ec36
	defb 000h		;ec37
	defb 000h		;ec38
	defb 000h		;ec39
	defb 000h		;ec3a
	defb 000h		;ec3b
	defb 000h		;ec3c
	defb 000h		;ec3d
	defb 000h		;ec3e
	defb 000h		;ec3f
	defb 000h		;ec40
	defb 000h		;ec41
	defb 000h		;ec42
	defb 000h		;ec43
	defb 000h		;ec44
	defb 000h		;ec45
	defb 000h		;ec46
	defb 000h		;ec47
	defb 000h		;ec48
	defb 000h		;ec49
	defb 000h		;ec4a
	defb 000h		;ec4b
	defb 000h		;ec4c
	defb 000h		;ec4d
	defb 000h		;ec4e
	defb 000h		;ec4f
	defb 000h		;ec50
	defb 000h		;ec51
	defb 000h		;ec52
	defb 000h		;ec53
	defb 000h		;ec54
	defb 000h		;ec55
	defb 000h		;ec56
	defb 000h		;ec57
	defb 000h		;ec58
	defb 000h		;ec59
	defb 000h		;ec5a
	defb 000h		;ec5b
	defb 000h		;ec5c
	defb 000h		;ec5d
	defb 000h		;ec5e
	defb 000h		;ec5f
	defb 000h		;ec60
	defb 000h		;ec61
	defb 000h		;ec62
	defb 000h		;ec63
	defb 000h		;ec64
	defb 000h		;ec65
	defb 000h		;ec66
	defb 000h		;ec67
	defb 000h		;ec68
	defb 000h		;ec69
	defb 000h		;ec6a
	defb 000h		;ec6b
	defb 000h		;ec6c
	defb 000h		;ec6d
	defb 000h		;ec6e
	defb 000h		;ec6f
	defb 000h		;ec70
	defb 000h		;ec71
	defb 000h		;ec72
	defb 000h		;ec73
	defb 000h		;ec74
	defb 000h		;ec75
	defb 000h		;ec76
	defb 000h		;ec77
	defb 000h		;ec78
	defb 000h		;ec79
	defb 000h		;ec7a
	defb 000h		;ec7b
	defb 000h		;ec7c
	defb 000h		;ec7d
	defb 000h		;ec7e
	defb 000h		;ec7f
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
	defb 000h		;ee81
	defb 000h		;ee82
	defb 000h		;ee83
	defb 000h		;ee84
	defb 000h		;ee85
	defb 000h		;ee86
	defb 000h		;ee87
lee88h:
	defb 0f6h		;ee88
	defb 0eah		;ee89
lee8ah:
	defb 000h		;ee8a
lee8bh:
	defb 000h		;ee8b
lee8ch:
	defb 001h		;ee8c
lee8dh:
	defb 000h		;ee8d
lee8eh:
	defb 000h		;ee8e
lee8fh:
	defb 000h		;ee8f
lee90h:
	defb 000h		;ee90
lee91h:
	defb 000h		;ee91
lee92h:
	defb 000h		;ee92
lee93h:
	defb 000h		;ee93
lee94h:
	defb 000h		;ee94
	defb 000h		;ee95
	defb 000h		;ee96
	defb 000h		;ee97
	defb 000h		;ee98
	defb 000h		;ee99
	defb 000h		;ee9a
lee9bh:
	defb 0ffh		;ee9b
lee9ch:
	defb 000h		;ee9c
	defb 000h		;ee9d
biosdata_end:
SELDSK_ENTRY:

; BLOCK 'code_disk' (start 0xee9e end 0xf339)
code_disk_start:
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
	ld hl,DISKFMT		;eeb7
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
	ld a,(leb49h)		;eecc
	or a			;eecf
	call nz,sub_f080h	;eed0
	xor a			;eed3
	ld (leb49h),a		;eed4
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
	ld de,dph_end		;eef7
	ld bc,00010h		;eefa
	ldir			;eefd
	pop bc			;eeff
	ld hl,tables_end	;ef00
	add hl,bc		;ef03
	ex de,hl		;ef04
	ld hl,0000ah		;ef05
	add hl,de		;ef08
	ex de,hl		;ef09
	ld a,(dph_end)		;ef0a
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
SETTRK_ENTRY:
	ld h,b			;ef18
	ld l,c			;ef19
	ld (leb3eh),hl		;ef1a
	ret			;ef1d
SETSEC_ENTRY:
	ld a,c			;ef1e
	ld (leb40h),a		;ef1f
	ret			;ef22
SETDMA_ENTRY:
	ld h,b			;ef23
	ld l,c			;ef24
	ld (leb54h),hl		;ef25
	ret			;ef28
SECTRAN_ENTRY:
	ld h,b			;ef29
	ld l,c			;ef2a
	ret			;ef2b
READ_ENTRY:
	ld a,001h		;ef2c
	ld (leb52h),a		;ef2e
	ld (leb51h),a		;ef31
	ld a,002h		;ef34
	ld (leb53h),a		;ef36
	jp lefc0h		;ef39
WRITE_ENTRY:
	xor a			;ef3c
	ld (leb52h),a		;ef3d
	ld a,c			;ef40
	ld (leb53h),a		;ef41
	cp 002h			;ef44
	jp nz,lef61h		;ef46
	ld a,(leb2fh)		;ef49
	ld (leb4ah),a		;ef4c
	ld a,(leb3dh)		;ef4f
	ld (leb4bh),a		;ef52
	ld hl,(leb3eh)		;ef55
	ld (leb4ch),hl		;ef58
	ld a,(leb40h)		;ef5b
	ld (leb4eh),a		;ef5e
lef61h:
	ld a,(leb4ah)		;ef61
	or a			;ef64
	jp z,lefb6h		;ef65
	dec a			;ef68
	ld (leb4ah),a		;ef69
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
	ld hl,leb30h		;ef8b
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
	ld (leb4ah),a		;efb7
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
	ld a,(leb49h)		;f002
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
	ld (leb49h),a		;f023
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
	ld a,(leb52h)		;f043
	or a			;f046
	jp nz,lf050h		;f047
	ld a,001h		;f04a
	ld (leb49h),a		;f04c
	ex de,hl		;f04f
lf050h:
	ldir			;f050
	ld a,(leb53h)		;f052
	cp 001h			;f055
	ld hl,leb50h		;f057
	ld a,(hl)		;f05a
	ld (hl),000h		;f05b
	jp nz,lf071h		;f05d
	or a			;f060
	jp nz,lf071h		;f061
	xor a			;f064
	ld (leb49h),a		;f065
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
	ld (leb4ah),a		;f08d
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
	ld (lee8dh),a		;f0a8
	ld a,c			;f0ab
	sub b			;f0ac
	ld c,a			;f0ad
	jp lf0b4h		;f0ae
lf0b1h:
	ld (lee8dh),a		;f0b1
lf0b4h:
	ld b,000h		;f0b4
	ld hl,(leb33h)		;f0b6
	add hl,bc		;f0b9
	ld a,(hl)		;f0ba
	ld (lee91h),a		;f0bb
	ld a,(leb42h)		;f0be
	ld (lee90h),a		;f0c1
	ld hl,leb56h		;f0c4
	ld (lee8eh),hl		;f0c7
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
	call EXTVEC1_ENTRY	;f0ee
	ld a,(lee8dh)		;f0f1
	and 003h		;f0f4
	add a,020h		;f0f6
	cp b			;f0f8
	ret z			;f0f9
sub_f0fah:
	call sub_f26fh		;f0fa
	call sub_f1eah		;f0fd
	push bc			;f100
	call EXTVEC1_ENTRY	;f101
	call sub_f236h		;f104
	call EXTVEC1_ENTRY	;f107
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
HOME_ENTRY:
	ld a,(leb3dh)		;f1bf
	ld (lee8dh),a		;f1c2
	ld (leb45h),a		;f1c5
	xor a			;f1c8
	ld (leb46h),a		;f1c9
	call sub_f26fh		;f1cc
	call sub_f1eah		;f1cf
	call EXTVEC1_ENTRY	;f1d2
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
	ld a,(lee8dh)		;f1f7
	and 003h		;f1fa
	out (005h),a		;f1fc
	ret			;f1fe
	call lf1d6h		;f1ff
	ld a,004h		;f202
	out (005h),a		;f204
	call lf1d6h		;f206
	ld a,(lee8dh)		;f209
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
	ld a,(lee8dh)		;f243
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
EXTVEC1_ENTRY:
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
	ld a,(lee8eh)		;f298
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
	ld a,(lee8dh)		;f2c6
	out (005h),a		;f2c9
	call lf1d6h		;f2cb
	ld a,(lee90h)		;f2ce
	out (005h),a		;f2d1
	call lf1d6h		;f2d3
	ld a,(lee8dh)		;f2d6
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
	ld a,(leb35h)		;f2fe
	out (005h),a		;f301
	ei			;f303
	ret			;f304
ISR_SIO_SPECIAL:
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
DUMITR:
	ei			;f336
	reti			;f337
code_disk_end:

; BLOCK 'pad2' (start 0xf339 end 0xf400)
pad2_start:
	defb 000h		;f339
	defb 000h		;f33a
	defb 000h		;f33b
	defb 000h		;f33c
	defb 000h		;f33d
	defb 000h		;f33e
	defb 000h		;f33f
	defb 000h		;f340
	defb 000h		;f341
	defb 000h		;f342
	defb 000h		;f343
	defb 000h		;f344
	defb 000h		;f345
	defb 000h		;f346
	defb 000h		;f347
	defb 000h		;f348
	defb 000h		;f349
	defb 000h		;f34a
	defb 000h		;f34b
	defb 000h		;f34c
	defb 000h		;f34d
	defb 000h		;f34e
	defb 000h		;f34f
	defb 000h		;f350
	defb 000h		;f351
	defb 000h		;f352
	defb 000h		;f353
	defb 000h		;f354
	defb 000h		;f355
	defb 000h		;f356
	defb 000h		;f357
	defb 000h		;f358
	defb 000h		;f359
	defb 000h		;f35a
	defb 000h		;f35b
	defb 000h		;f35c
	defb 000h		;f35d
	defb 000h		;f35e
	defb 000h		;f35f
	defb 000h		;f360
	defb 000h		;f361
	defb 000h		;f362
	defb 000h		;f363
	defb 000h		;f364
	defb 000h		;f365
	defb 000h		;f366
	defb 000h		;f367
	defb 000h		;f368
	defb 000h		;f369
	defb 000h		;f36a
	defb 000h		;f36b
	defb 000h		;f36c
	defb 000h		;f36d
	defb 000h		;f36e
	defb 000h		;f36f
	defb 000h		;f370
	defb 000h		;f371
	defb 000h		;f372
	defb 000h		;f373
	defb 000h		;f374
	defb 000h		;f375
	defb 000h		;f376
	defb 000h		;f377
	defb 000h		;f378
	defb 000h		;f379
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
pad2_end:
ITRTAB:

; BLOCK 'ivt' (start 0xf400 end 0xf424)
ivt_start:
	defw 0f336h		;f400
	defw 0e50eh		;f402
	defw 0e523h		;f404
	defw 0f336h		;f406
	defw 0f336h		;f408
	defw 0f336h		;f40a
	defw 0e99ah		;f40c
	defw 0f305h		;f40e
	defw 0e424h		;f410
	defw 0e43dh		;f412
	defw 0e456h		;f414
	defw 0e46bh		;f416
	defw 0e488h		;f418
	defw 0e4a1h		;f41a
	defw 0e4bah		;f41c
	defw 0e4d4h		;f41e
	defw 0f400h		;f420
	defw 00000h		;f422
ivt_end:

; BLOCK 'postivt' (start 0xf424 end 0xf432)
postivt_start:
	defb 000h		;f424
	defb 000h		;f425
	defb 000h		;f426
	defb 000h		;f427
	defb 000h		;f428
	defb 000h		;f429
	defb 02ah		;f42a
	defb 017h		;f42b
	defb 000h		;f42c
	defb 000h		;f42d
	defb 002h		;f42e
	defb 000h		;f42f
	defb 001h		;f430
	defb 001h		;f431
postivt_end:

; BLOCK 'code_fdc' (start 0xf432 end 0xf4fe)
code_fdc_start:
	ld (lee94h),a		;f432
	ret			;f435
	call sub_f18bh		;f436
	call lf1d6h		;f439
	ld a,00fh		;f43c
	out (005h),a		;f43e
	call lf1d6h		;f440
	ld a,(lee8dh)		;f443
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
	ld a,(lee8eh)		;f498
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
	ld a,(lee8dh)		;f4c6
	out (005h),a		;f4c9
	call lf1d6h		;f4cb
	ld a,(lee90h)		;f4ce
	out (005h),a		;f4d1
	call lf1d6h		;f4d3
	ld a,(lee8dh)		;f4d6
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
code_fdc_end:

; BLOCK 'trailing' (start 0xf4fe end 0xf7ff)
trailing_start:
	defb 03ah		;f4fe
	defb 035h		;f4ff
lf500h:
	defb 0e5h		;f500
	defb 0e5h		;f501
	defb 0e5h		;f502
	defb 0e5h		;f503
	defb 0e5h		;f504
	defb 0e5h		;f505
	defb 0e5h		;f506
	defb 0e5h		;f507
	defb 0e5h		;f508
	defb 0e5h		;f509
lf50ah:
	defb 0e5h		;f50a
	defb 0e5h		;f50b
	defb 0e5h		;f50c
	defb 0e5h		;f50d
	defb 0e5h		;f50e
	defb 0e5h		;f50f
	defb 0e5h		;f510
	defb 0e5h		;f511
	defb 0e5h		;f512
	defb 0e5h		;f513
	defb 0e5h		;f514
	defb 0e5h		;f515
	defb 0e5h		;f516
	defb 0e5h		;f517
	defb 0e5h		;f518
	defb 0e5h		;f519
	defb 0e5h		;f51a
	defb 0e5h		;f51b
	defb 0e5h		;f51c
	defb 0e5h		;f51d
	defb 0e5h		;f51e
	defb 0e5h		;f51f
	defb 0e5h		;f520
	defb 0e5h		;f521
	defb 0e5h		;f522
	defb 0e5h		;f523
	defb 0e5h		;f524
	defb 0e5h		;f525
	defb 0e5h		;f526
	defb 0e5h		;f527
	defb 0e5h		;f528
	defb 0e5h		;f529
	defb 0e5h		;f52a
	defb 0e5h		;f52b
	defb 0e5h		;f52c
	defb 0e5h		;f52d
	defb 0e5h		;f52e
	defb 0e5h		;f52f
	defb 0e5h		;f530
	defb 0e5h		;f531
	defb 0e5h		;f532
	defb 0e5h		;f533
	defb 0e5h		;f534
	defb 0e5h		;f535
	defb 0e5h		;f536
	defb 0e5h		;f537
	defb 0e5h		;f538
	defb 0e5h		;f539
	defb 0e5h		;f53a
	defb 0e5h		;f53b
	defb 0e5h		;f53c
	defb 0e5h		;f53d
	defb 0e5h		;f53e
	defb 0e5h		;f53f
	defb 0e5h		;f540
	defb 0e5h		;f541
	defb 0e5h		;f542
	defb 0e5h		;f543
	defb 0e5h		;f544
	defb 0e5h		;f545
	defb 0e5h		;f546
	defb 0e5h		;f547
	defb 0e5h		;f548
	defb 0e5h		;f549
	defb 0e5h		;f54a
	defb 0e5h		;f54b
	defb 0e5h		;f54c
	defb 0e5h		;f54d
	defb 0e5h		;f54e
	defb 0e5h		;f54f
	defb 0e5h		;f550
	defb 0e5h		;f551
	defb 0e5h		;f552
	defb 0e5h		;f553
	defb 0e5h		;f554
	defb 0e5h		;f555
	defb 0e5h		;f556
	defb 0e5h		;f557
	defb 0e5h		;f558
	defb 0e5h		;f559
	defb 0e5h		;f55a
	defb 0e5h		;f55b
	defb 0e5h		;f55c
	defb 0e5h		;f55d
	defb 0e5h		;f55e
	defb 0e5h		;f55f
	defb 0e5h		;f560
	defb 0e5h		;f561
	defb 0e5h		;f562
	defb 0e5h		;f563
	defb 0e5h		;f564
	defb 0e5h		;f565
	defb 0e5h		;f566
	defb 0e5h		;f567
	defb 0e5h		;f568
	defb 0e5h		;f569
	defb 0e5h		;f56a
	defb 0e5h		;f56b
	defb 0e5h		;f56c
	defb 0e5h		;f56d
	defb 0e5h		;f56e
	defb 0e5h		;f56f
	defb 0e5h		;f570
	defb 0e5h		;f571
	defb 0e5h		;f572
	defb 0e5h		;f573
	defb 0e5h		;f574
	defb 0e5h		;f575
	defb 0e5h		;f576
	defb 0e5h		;f577
	defb 0e5h		;f578
	defb 0e5h		;f579
	defb 0e5h		;f57a
	defb 0e5h		;f57b
	defb 0e5h		;f57c
	defb 0e5h		;f57d
	defb 0e5h		;f57e
	defb 0e5h		;f57f
	defb 0e5h		;f580
	defb 0e5h		;f581
	defb 0e5h		;f582
	defb 0e5h		;f583
	defb 0e5h		;f584
	defb 0e5h		;f585
	defb 0e5h		;f586
	defb 0e5h		;f587
	defb 0e5h		;f588
	defb 0e5h		;f589
	defb 0e5h		;f58a
	defb 0e5h		;f58b
	defb 0e5h		;f58c
	defb 0e5h		;f58d
	defb 0e5h		;f58e
	defb 0e5h		;f58f
	defb 0e5h		;f590
	defb 0e5h		;f591
	defb 0e5h		;f592
	defb 0e5h		;f593
	defb 0e5h		;f594
	defb 0e5h		;f595
	defb 0e5h		;f596
	defb 0e5h		;f597
	defb 0e5h		;f598
	defb 0e5h		;f599
	defb 0e5h		;f59a
	defb 0e5h		;f59b
	defb 0e5h		;f59c
	defb 0e5h		;f59d
	defb 0e5h		;f59e
	defb 0e5h		;f59f
	defb 0e5h		;f5a0
	defb 0e5h		;f5a1
	defb 0e5h		;f5a2
	defb 0e5h		;f5a3
	defb 0e5h		;f5a4
	defb 0e5h		;f5a5
	defb 0e5h		;f5a6
	defb 0e5h		;f5a7
	defb 0e5h		;f5a8
	defb 0e5h		;f5a9
	defb 0e5h		;f5aa
	defb 0e5h		;f5ab
	defb 0e5h		;f5ac
	defb 0e5h		;f5ad
	defb 0e5h		;f5ae
	defb 0e5h		;f5af
	defb 0e5h		;f5b0
	defb 0e5h		;f5b1
	defb 0e5h		;f5b2
	defb 0e5h		;f5b3
	defb 0e5h		;f5b4
	defb 0e5h		;f5b5
	defb 0e5h		;f5b6
	defb 0e5h		;f5b7
	defb 0e5h		;f5b8
	defb 0e5h		;f5b9
	defb 0e5h		;f5ba
	defb 0e5h		;f5bb
	defb 0e5h		;f5bc
	defb 0e5h		;f5bd
	defb 0e5h		;f5be
	defb 0e5h		;f5bf
	defb 0e5h		;f5c0
	defb 0e5h		;f5c1
	defb 0e5h		;f5c2
	defb 0e5h		;f5c3
	defb 0e5h		;f5c4
	defb 0e5h		;f5c5
	defb 0e5h		;f5c6
	defb 0e5h		;f5c7
	defb 0e5h		;f5c8
	defb 0e5h		;f5c9
	defb 0e5h		;f5ca
	defb 0e5h		;f5cb
	defb 0e5h		;f5cc
	defb 0e5h		;f5cd
	defb 0e5h		;f5ce
	defb 0e5h		;f5cf
	defb 0e5h		;f5d0
	defb 0e5h		;f5d1
	defb 0e5h		;f5d2
	defb 0e5h		;f5d3
	defb 0e5h		;f5d4
	defb 0e5h		;f5d5
	defb 0e5h		;f5d6
	defb 0e5h		;f5d7
	defb 0e5h		;f5d8
	defb 0e5h		;f5d9
	defb 0e5h		;f5da
	defb 0e5h		;f5db
	defb 0e5h		;f5dc
	defb 0e5h		;f5dd
	defb 0e5h		;f5de
	defb 0e5h		;f5df
	defb 0e5h		;f5e0
	defb 0e5h		;f5e1
	defb 0e5h		;f5e2
	defb 0e5h		;f5e3
	defb 0e5h		;f5e4
	defb 0e5h		;f5e5
	defb 0e5h		;f5e6
	defb 0e5h		;f5e7
	defb 0e5h		;f5e8
	defb 0e5h		;f5e9
	defb 0e5h		;f5ea
	defb 0e5h		;f5eb
	defb 0e5h		;f5ec
	defb 0e5h		;f5ed
	defb 0e5h		;f5ee
lf5efh:
	defb 0e5h		;f5ef
lf5f0h:
	defb 0e5h		;f5f0
	defb 0e5h		;f5f1
	defb 0e5h		;f5f2
	defb 0e5h		;f5f3
	defb 0e5h		;f5f4
	defb 0e5h		;f5f5
	defb 0e5h		;f5f6
	defb 0e5h		;f5f7
lf5f8h:
	defb 0e5h		;f5f8
lf5f9h:
	defb 0e5h		;f5f9
	defb 0e5h		;f5fa
	defb 0e5h		;f5fb
	defb 0e5h		;f5fc
	defb 0e5h		;f5fd
	defb 0e5h		;f5fe
	defb 0e5h		;f5ff
	defb 0e5h		;f600
	defb 0e5h		;f601
	defb 0e5h		;f602
	defb 0e5h		;f603
	defb 0e5h		;f604
	defb 0e5h		;f605
	defb 0e5h		;f606
	defb 0e5h		;f607
	defb 0e5h		;f608
	defb 0e5h		;f609
	defb 0e5h		;f60a
	defb 0e5h		;f60b
	defb 0e5h		;f60c
	defb 0e5h		;f60d
	defb 0e5h		;f60e
	defb 0e5h		;f60f
	defb 0e5h		;f610
	defb 0e5h		;f611
	defb 0e5h		;f612
	defb 0e5h		;f613
	defb 0e5h		;f614
	defb 0e5h		;f615
	defb 0e5h		;f616
	defb 0e5h		;f617
	defb 0e5h		;f618
	defb 0e5h		;f619
	defb 0e5h		;f61a
	defb 0e5h		;f61b
	defb 0e5h		;f61c
	defb 0e5h		;f61d
	defb 0e5h		;f61e
	defb 0e5h		;f61f
lf620h:
	defb 0e5h		;f620
	defb 0e5h		;f621
	defb 0e5h		;f622
	defb 0e5h		;f623
	defb 0e5h		;f624
	defb 0e5h		;f625
	defb 0e5h		;f626
	defb 0e5h		;f627
	defb 0e5h		;f628
	defb 0e5h		;f629
	defb 0e5h		;f62a
	defb 0e5h		;f62b
	defb 0e5h		;f62c
	defb 0e5h		;f62d
	defb 0e5h		;f62e
	defb 0e5h		;f62f
	defb 0e5h		;f630
	defb 0e5h		;f631
	defb 0e5h		;f632
	defb 0e5h		;f633
	defb 0e5h		;f634
	defb 0e5h		;f635
	defb 0e5h		;f636
	defb 0e5h		;f637
	defb 0e5h		;f638
	defb 0e5h		;f639
	defb 0e5h		;f63a
	defb 0e5h		;f63b
	defb 0e5h		;f63c
	defb 0e5h		;f63d
	defb 0e5h		;f63e
	defb 0e5h		;f63f
	defb 0e5h		;f640
	defb 0e5h		;f641
	defb 0e5h		;f642
	defb 0e5h		;f643
	defb 0e5h		;f644
	defb 0e5h		;f645
	defb 0e5h		;f646
	defb 0e5h		;f647
	defb 0e5h		;f648
	defb 0e5h		;f649
	defb 0e5h		;f64a
	defb 0e5h		;f64b
	defb 0e5h		;f64c
	defb 0e5h		;f64d
	defb 0e5h		;f64e
	defb 0e5h		;f64f
	defb 0e5h		;f650
	defb 0e5h		;f651
	defb 0e5h		;f652
	defb 0e5h		;f653
	defb 0e5h		;f654
	defb 0e5h		;f655
	defb 0e5h		;f656
	defb 0e5h		;f657
	defb 0e5h		;f658
	defb 0e5h		;f659
	defb 0e5h		;f65a
	defb 0e5h		;f65b
	defb 0e5h		;f65c
	defb 0e5h		;f65d
	defb 0e5h		;f65e
	defb 0e5h		;f65f
	defb 0e5h		;f660
	defb 0e5h		;f661
	defb 0e5h		;f662
	defb 0e5h		;f663
	defb 0e5h		;f664
	defb 0e5h		;f665
	defb 0e5h		;f666
	defb 0e5h		;f667
	defb 0e5h		;f668
	defb 0e5h		;f669
	defb 0e5h		;f66a
	defb 0e5h		;f66b
	defb 0e5h		;f66c
	defb 0e5h		;f66d
	defb 0e5h		;f66e
	defb 0e5h		;f66f
	defb 0e5h		;f670
	defb 0e5h		;f671
	defb 0e5h		;f672
	defb 0e5h		;f673
	defb 0e5h		;f674
	defb 0e5h		;f675
	defb 0e5h		;f676
	defb 0e5h		;f677
	defb 0e5h		;f678
	defb 0e5h		;f679
	defb 0e5h		;f67a
	defb 0e5h		;f67b
	defb 0e5h		;f67c
	defb 0e5h		;f67d
	defb 0e5h		;f67e
	defb 0e5h		;f67f
lf680h:
	defb 0e5h		;f680
	defb 0e5h		;f681
	defb 0e5h		;f682
	defb 0e5h		;f683
	defb 0e5h		;f684
	defb 0e5h		;f685
	defb 0e5h		;f686
	defb 0e5h		;f687
	defb 0e5h		;f688
	defb 0e5h		;f689
	defb 0e5h		;f68a
	defb 0e5h		;f68b
	defb 0e5h		;f68c
	defb 0e5h		;f68d
	defb 0e5h		;f68e
	defb 0e5h		;f68f
	defb 0e5h		;f690
	defb 0e5h		;f691
	defb 0e5h		;f692
	defb 0e5h		;f693
	defb 0e5h		;f694
	defb 0e5h		;f695
	defb 0e5h		;f696
	defb 0e5h		;f697
	defb 0e5h		;f698
	defb 0e5h		;f699
	defb 0e5h		;f69a
	defb 0e5h		;f69b
	defb 0e5h		;f69c
	defb 0e5h		;f69d
	defb 0e5h		;f69e
	defb 0e5h		;f69f
	defb 0e5h		;f6a0
	defb 0e5h		;f6a1
	defb 0e5h		;f6a2
	defb 0e5h		;f6a3
	defb 0e5h		;f6a4
	defb 0e5h		;f6a5
	defb 0e5h		;f6a6
	defb 0e5h		;f6a7
	defb 0e5h		;f6a8
	defb 0e5h		;f6a9
	defb 0e5h		;f6aa
	defb 0e5h		;f6ab
	defb 0e5h		;f6ac
	defb 0e5h		;f6ad
	defb 0e5h		;f6ae
	defb 0e5h		;f6af
	defb 0e5h		;f6b0
	defb 0e5h		;f6b1
	defb 0e5h		;f6b2
	defb 0e5h		;f6b3
	defb 0e5h		;f6b4
	defb 0e5h		;f6b5
	defb 0e5h		;f6b6
	defb 0e5h		;f6b7
	defb 0e5h		;f6b8
	defb 0e5h		;f6b9
	defb 0e5h		;f6ba
	defb 0e5h		;f6bb
	defb 0e5h		;f6bc
	defb 0e5h		;f6bd
	defb 0e5h		;f6be
	defb 0e5h		;f6bf
	defb 0e5h		;f6c0
	defb 0e5h		;f6c1
	defb 0e5h		;f6c2
	defb 0e5h		;f6c3
	defb 0e5h		;f6c4
	defb 0e5h		;f6c5
	defb 0e5h		;f6c6
	defb 0e5h		;f6c7
	defb 0e5h		;f6c8
	defb 0e5h		;f6c9
	defb 0e5h		;f6ca
	defb 0e5h		;f6cb
	defb 0e5h		;f6cc
	defb 0e5h		;f6cd
	defb 0e5h		;f6ce
	defb 0e5h		;f6cf
	defb 0e5h		;f6d0
	defb 0e5h		;f6d1
	defb 0e5h		;f6d2
	defb 0e5h		;f6d3
	defb 0e5h		;f6d4
	defb 0e5h		;f6d5
	defb 0e5h		;f6d6
	defb 0e5h		;f6d7
	defb 0e5h		;f6d8
	defb 0e5h		;f6d9
	defb 0e5h		;f6da
	defb 0e5h		;f6db
	defb 0e5h		;f6dc
	defb 0e5h		;f6dd
	defb 0e5h		;f6de
	defb 0e5h		;f6df
	defb 0e5h		;f6e0
	defb 0e5h		;f6e1
	defb 0e5h		;f6e2
	defb 0e5h		;f6e3
	defb 0e5h		;f6e4
	defb 0e5h		;f6e5
	defb 0e5h		;f6e6
	defb 0e5h		;f6e7
	defb 0e5h		;f6e8
	defb 0e5h		;f6e9
	defb 0e5h		;f6ea
	defb 0e5h		;f6eb
	defb 0e5h		;f6ec
	defb 0e5h		;f6ed
	defb 0e5h		;f6ee
	defb 0e5h		;f6ef
	defb 0e5h		;f6f0
	defb 0e5h		;f6f1
	defb 0e5h		;f6f2
	defb 0e5h		;f6f3
	defb 0e5h		;f6f4
	defb 0e5h		;f6f5
	defb 0e5h		;f6f6
	defb 0e5h		;f6f7
	defb 0e5h		;f6f8
	defb 0e5h		;f6f9
	defb 0e5h		;f6fa
	defb 0e5h		;f6fb
	defb 0e5h		;f6fc
	defb 0e5h		;f6fd
	defb 0e5h		;f6fe
	defb 0e5h		;f6ff
lf700h:
	defb 0e5h		;f700
	defb 0e5h		;f701
	defb 0e5h		;f702
	defb 0e5h		;f703
	defb 0e5h		;f704
	defb 0e5h		;f705
	defb 0e5h		;f706
	defb 0e5h		;f707
	defb 0e5h		;f708
	defb 0e5h		;f709
	defb 0e5h		;f70a
	defb 0e5h		;f70b
	defb 0e5h		;f70c
	defb 0e5h		;f70d
	defb 0e5h		;f70e
	defb 0e5h		;f70f
	defb 0e5h		;f710
	defb 0e5h		;f711
	defb 0e5h		;f712
	defb 0e5h		;f713
	defb 0e5h		;f714
	defb 0e5h		;f715
	defb 0e5h		;f716
	defb 0e5h		;f717
	defb 0e5h		;f718
	defb 0e5h		;f719
	defb 0e5h		;f71a
	defb 0e5h		;f71b
	defb 0e5h		;f71c
	defb 0e5h		;f71d
	defb 0e5h		;f71e
	defb 0e5h		;f71f
	defb 0e5h		;f720
	defb 0e5h		;f721
	defb 0e5h		;f722
	defb 0e5h		;f723
	defb 0e5h		;f724
	defb 0e5h		;f725
	defb 0e5h		;f726
	defb 0e5h		;f727
	defb 0e5h		;f728
	defb 0e5h		;f729
	defb 0e5h		;f72a
	defb 0e5h		;f72b
	defb 0e5h		;f72c
	defb 0e5h		;f72d
	defb 0e5h		;f72e
	defb 0e5h		;f72f
	defb 0e5h		;f730
	defb 0e5h		;f731
	defb 0e5h		;f732
	defb 0e5h		;f733
	defb 0e5h		;f734
	defb 0e5h		;f735
	defb 0e5h		;f736
	defb 0e5h		;f737
	defb 0e5h		;f738
	defb 0e5h		;f739
	defb 0e5h		;f73a
	defb 0e5h		;f73b
	defb 0e5h		;f73c
	defb 0e5h		;f73d
	defb 0e5h		;f73e
	defb 0e5h		;f73f
	defb 0e5h		;f740
	defb 0e5h		;f741
	defb 0e5h		;f742
	defb 0e5h		;f743
	defb 0e5h		;f744
	defb 0e5h		;f745
	defb 0e5h		;f746
	defb 0e5h		;f747
	defb 0e5h		;f748
	defb 0e5h		;f749
	defb 0e5h		;f74a
	defb 0e5h		;f74b
	defb 0e5h		;f74c
	defb 0e5h		;f74d
	defb 0e5h		;f74e
	defb 0e5h		;f74f
	defb 0e5h		;f750
	defb 0e5h		;f751
	defb 0e5h		;f752
	defb 0e5h		;f753
	defb 0e5h		;f754
	defb 0e5h		;f755
	defb 0e5h		;f756
	defb 0e5h		;f757
	defb 0e5h		;f758
	defb 0e5h		;f759
	defb 0e5h		;f75a
	defb 0e5h		;f75b
	defb 0e5h		;f75c
	defb 0e5h		;f75d
	defb 0e5h		;f75e
	defb 0e5h		;f75f
	defb 0e5h		;f760
	defb 0e5h		;f761
	defb 0e5h		;f762
	defb 0e5h		;f763
	defb 0e5h		;f764
	defb 0e5h		;f765
	defb 0e5h		;f766
	defb 0e5h		;f767
	defb 0e5h		;f768
	defb 0e5h		;f769
	defb 0e5h		;f76a
	defb 0e5h		;f76b
	defb 0e5h		;f76c
	defb 0e5h		;f76d
	defb 0e5h		;f76e
	defb 0e5h		;f76f
	defb 0e5h		;f770
	defb 0e5h		;f771
	defb 0e5h		;f772
	defb 0e5h		;f773
	defb 0e5h		;f774
	defb 0e5h		;f775
	defb 0e5h		;f776
	defb 0e5h		;f777
	defb 0e5h		;f778
	defb 0e5h		;f779
	defb 0e5h		;f77a
	defb 0e5h		;f77b
	defb 0e5h		;f77c
	defb 0e5h		;f77d
	defb 0e5h		;f77e
	defb 0e5h		;f77f
	defb 0e5h		;f780
	defb 0e5h		;f781
	defb 0e5h		;f782
	defb 0e5h		;f783
	defb 0e5h		;f784
	defb 0e5h		;f785
	defb 0e5h		;f786
	defb 0e5h		;f787
	defb 0e5h		;f788
	defb 0e5h		;f789
	defb 0e5h		;f78a
	defb 0e5h		;f78b
	defb 0e5h		;f78c
	defb 0e5h		;f78d
	defb 0e5h		;f78e
	defb 0e5h		;f78f
	defb 0e5h		;f790
	defb 0e5h		;f791
	defb 0e5h		;f792
	defb 0e5h		;f793
	defb 0e5h		;f794
	defb 0e5h		;f795
	defb 0e5h		;f796
	defb 0e5h		;f797
	defb 0e5h		;f798
	defb 0e5h		;f799
	defb 0e5h		;f79a
	defb 0e5h		;f79b
	defb 0e5h		;f79c
	defb 0e5h		;f79d
	defb 0e5h		;f79e
	defb 0e5h		;f79f
	defb 0e5h		;f7a0
	defb 0e5h		;f7a1
	defb 0e5h		;f7a2
	defb 0e5h		;f7a3
	defb 0e5h		;f7a4
	defb 0e5h		;f7a5
	defb 0e5h		;f7a6
	defb 0e5h		;f7a7
	defb 0e5h		;f7a8
	defb 0e5h		;f7a9
	defb 0e5h		;f7aa
	defb 0e5h		;f7ab
	defb 0e5h		;f7ac
	defb 0e5h		;f7ad
	defb 0e5h		;f7ae
	defb 0e5h		;f7af
	defb 0e5h		;f7b0
	defb 0e5h		;f7b1
	defb 0e5h		;f7b2
	defb 0e5h		;f7b3
	defb 0e5h		;f7b4
	defb 0e5h		;f7b5
	defb 0e5h		;f7b6
	defb 0e5h		;f7b7
	defb 0e5h		;f7b8
	defb 0e5h		;f7b9
	defb 0e5h		;f7ba
	defb 0e5h		;f7bb
	defb 0e5h		;f7bc
	defb 0e5h		;f7bd
	defb 0e5h		;f7be
	defb 0e5h		;f7bf
	defb 0e5h		;f7c0
	defb 0e5h		;f7c1
	defb 0e5h		;f7c2
	defb 0e5h		;f7c3
	defb 0e5h		;f7c4
	defb 0e5h		;f7c5
	defb 0e5h		;f7c6
	defb 0e5h		;f7c7
	defb 0e5h		;f7c8
	defb 0e5h		;f7c9
	defb 0e5h		;f7ca
	defb 0e5h		;f7cb
	defb 0e5h		;f7cc
	defb 0e5h		;f7cd
	defb 0e5h		;f7ce
	defb 0e5h		;f7cf
	defb 0e5h		;f7d0
	defb 0e5h		;f7d1
	defb 0e5h		;f7d2
	defb 0e5h		;f7d3
	defb 0e5h		;f7d4
	defb 0e5h		;f7d5
	defb 0e5h		;f7d6
	defb 0e5h		;f7d7
	defb 0e5h		;f7d8
	defb 0e5h		;f7d9
	defb 0e5h		;f7da
	defb 0e5h		;f7db
	defb 0e5h		;f7dc
	defb 0e5h		;f7dd
	defb 0e5h		;f7de
	defb 0e5h		;f7df
	defb 0e5h		;f7e0
	defb 0e5h		;f7e1
	defb 0e5h		;f7e2
	defb 0e5h		;f7e3
	defb 0e5h		;f7e4
	defb 0e5h		;f7e5
	defb 0e5h		;f7e6
	defb 0e5h		;f7e7
	defb 0e5h		;f7e8
	defb 0e5h		;f7e9
	defb 0e5h		;f7ea
	defb 0e5h		;f7eb
	defb 0e5h		;f7ec
	defb 0e5h		;f7ed
	defb 0e5h		;f7ee
	defb 0e5h		;f7ef
	defb 0e5h		;f7f0
	defb 0e5h		;f7f1
	defb 0e5h		;f7f2
	defb 0e5h		;f7f3
	defb 0e5h		;f7f4
	defb 0e5h		;f7f5
	defb 0e5h		;f7f6
	defb 0e5h		;f7f7
	defb 0e5h		;f7f8
	defb 0e5h		;f7f9
	defb 0e5h		;f7fa
	defb 0e5h		;f7fb
	defb 0e5h		;f7fc
	defb 0e5h		;f7fd
	defb 0e5h		;f7fe
trailing_end:
	push hl			;f7ff
DSPSTR:
