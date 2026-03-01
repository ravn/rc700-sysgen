; z80dasm 1.2.0
; command line: z80dasm -a -l -g 0xE080 -S /Users/ravn/git/rc700-sysgen/rcbios/src-58k/bios_58k.sym -b /Users/ravn/git/rc700-sysgen/rcbios/src-58k/bios_58k.blk -o /Users/ravn/git/rc700-sysgen/rcbios/src-58k/bios_58k_raw.asm extracted_bios/cpm22_58k_rel1.3_mini.bin

	org 0e080h
trailing_end:	equ 0xf500
ISRSTACK:	equ 0xf620
CONVTAB:	equ 0xf680
SCREENBUF:	equ 0xf800
SCRNEND:	equ 0xffcf
CURX:	equ 0xffd1
CURY:	equ 0xffd2
TIMER1:	equ 0xffdf
TIMER2:	equ 0xffe1
WARMJP:	equ 0xffe5
MOTORTIMER:	equ 0xffe7
RTCCNT:	equ 0xfffc

START:

; BLOCK 'code000' (start 0xe080 end 0xe1bd)
code000_start:
	di			;e080
	ld hl,00000h		;e081
	ld de,0dd00h		;e084
	ld bc,01b01h		;e087
	ldir			;e08a
	ld hl,0de00h		;e08c
	ld de,CONVTAB		;e08f
	ld bc,00180h		;e092
	ldir			;e095
	ld sp,00080h		;e097
	ld a,(lf321h)		;e09a
	ld i,a			;e09d
	im 2			;e09f
	jp le0a4h		;e0a1
le0a4h:
	ld a,002h		;e0a4
	out (012h),a		;e0a6
	ld a,004h		;e0a8
	out (013h),a		;e0aa
	ld a,04fh		;e0ac
	out (012h),a		;e0ae
	ld a,00fh		;e0b0
	out (013h),a		;e0b2
	ld a,083h		;e0b4
	out (012h),a		;e0b6
	out (013h),a		;e0b8
	ld a,008h		;e0ba
	out (00ch),a		;e0bc
	ld a,(0dd80h)		;e0be
	out (00ch),a		;e0c1
	ld a,(0dd81h)		;e0c3
	out (00ch),a		;e0c6
	ld a,(0dd82h)		;e0c8
	out (00dh),a		;e0cb
	ld a,(0dd83h)		;e0cd
	out (00dh),a		;e0d0
	ld a,(0dd84h)		;e0d2
	out (00eh),a		;e0d5
	ld a,(0dd85h)		;e0d7
	out (00eh),a		;e0da
	ld a,(0dd86h)		;e0dc
	out (00fh),a		;e0df
	ld a,(0dd87h)		;e0e1
	out (00fh),a		;e0e4
	ld hl,0dd88h		;e0e6
	ld b,009h		;e0e9
	ld c,00ah		;e0eb
	otir			;e0ed
	ld hl,0dd91h		;e0ef
	ld b,00bh		;e0f2
	ld c,00bh		;e0f4
	otir			;e0f6
	ld a,020h		;e0f8
	out (0f8h),a		;e0fa
	ld a,(0dd9ch)		;e0fc
	out (0fbh),a		;e0ff
	ld a,000h		;e101
	out (0fah),a		;e103
	ld a,(0dd9eh)		;e105
	out (0fbh),a		;e108
	ld a,(0dd9fh)		;e10a
	out (0fbh),a		;e10d
	in a,(014h)		;e10f
	and 080h		;e111
	jp z,le12eh		;e113
	ld hl,le237h		;e116
	ld (hl),010h		;e119
	inc hl			;e11b
	ld (hl),010h		;e11c
	ld a,00fh		;e11e
	ld (0dda6h),a		;e120
	ld hl,0df80h		;e123
	ld de,skew_seq_end	;e126
	ld bc,0009ch		;e129
	ldir			;e12c
le12eh:
	in a,(004h)		;e12e
	and 01fh		;e130
	jp nz,le12eh		;e132
	ld hl,0dda4h		;e135
	ld b,(hl)		;e138
le139h:
	inc hl			;e139
le13ah:
	in a,(004h)		;e13a
	and 0c0h		;e13c
	cp 080h			;e13e
	jp nz,le13ah		;e140
	ld a,(hl)		;e143
	out (005h),a		;e144
	dec b			;e146
	jp nz,le139h		;e147
	ld hl,SCREENBUF		;e14a
	ld de,0f801h		;e14d
	ld bc,007cfh		;e150
	ld (hl),020h		;e153
	ldir			;e155
	ld hl,trailing_end	;e157
	ld de,0f501h		;e15a
	ld bc,000fah		;e15d
	ld (hl),000h		;e160
	ldir			;e162
	ld hl,CURX		;e164
	ld de,CURY		;e167
	ld (hl),000h		;e16a
	ld bc,0002eh		;e16c
	ldir			;e16f
	ld a,000h		;e171
	out (001h),a		;e173
	ld a,(0dda0h)		;e175
	out (000h),a		;e178
	ld a,(0dda1h)		;e17a
	out (000h),a		;e17d
	ld a,(0dda2h)		;e17f
	out (000h),a		;e182
	ld a,(0dda3h)		;e184
	out (000h),a		;e187
	ld a,080h		;e189
	out (001h),a		;e18b
	ld a,000h		;e18d
	out (000h),a		;e18f
	out (000h),a		;e191
	ld a,0e0h		;e193
	out (001h),a		;e195
	ld a,023h		;e197
	out (001h),a		;e199
	ld hl,0dd8eh		;e19b
	ld a,(hl)		;e19e
	and 060h		;e19f
	ld (le234h),a		;e1a1
	ld hl,0dd99h		;e1a4
	ld a,(hl)		;e1a7
	and 060h		;e1a8
	ld (le235h),a		;e1aa
	ld a,(0ddach)		;e1ad
	ld (code002_end),a	;e1b0
	ld hl,(0ddadh)		;e1b3
	ld (MOTORTIMER),hl	;e1b6
	ei			;e1b9
	jp initpad_end		;e1ba
code000_end:
INITPAD:

; BLOCK 'initpad' (start 0xe1bd end 0xe200)
initpad_start:
	defb 000h		;e1bd
	defb 000h		;e1be
	defb 000h		;e1bf
	defb 000h		;e1c0
	defb 000h		;e1c1
	defb 000h		;e1c2
	defb 000h		;e1c3
	defb 000h		;e1c4
	defb 000h		;e1c5
	defb 000h		;e1c6
	defb 000h		;e1c7
	defb 000h		;e1c8
	defb 000h		;e1c9
	defb 000h		;e1ca
	defb 000h		;e1cb
	defb 000h		;e1cc
	defb 000h		;e1cd
	defb 000h		;e1ce
	defb 000h		;e1cf
	defb 000h		;e1d0
	defb 000h		;e1d1
	defb 000h		;e1d2
	defb 000h		;e1d3
	defb 000h		;e1d4
	defb 000h		;e1d5
	defb 000h		;e1d6
	defb 000h		;e1d7
	defb 000h		;e1d8
	defb 000h		;e1d9
	defb 000h		;e1da
	defb 000h		;e1db
	defb 000h		;e1dc
	defb 000h		;e1dd
	defb 000h		;e1de
	defb 000h		;e1df
	defb 000h		;e1e0
	defb 000h		;e1e1
	defb 000h		;e1e2
	defb 000h		;e1e3
	defb 000h		;e1e4
	defb 000h		;e1e5
	defb 000h		;e1e6
	defb 000h		;e1e7
	defb 000h		;e1e8
	defb 000h		;e1e9
	defb 000h		;e1ea
	defb 000h		;e1eb
	defb 000h		;e1ec
	defb 000h		;e1ed
	defb 000h		;e1ee
	defb 000h		;e1ef
	defb 000h		;e1f0
	defb 000h		;e1f1
	defb 000h		;e1f2
	defb 000h		;e1f3
	defb 000h		;e1f4
	defb 000h		;e1f5
	defb 000h		;e1f6
	defb 000h		;e1f7
	defb 000h		;e1f8
	defb 000h		;e1f9
	defb 000h		;e1fa
	defb 000h		;e1fb
	defb 000h		;e1fc
	defb 000h		;e1fd
	defb 000h		;e1fe
	defb 000h		;e1ff
initpad_end:
JMPTAB:

; BLOCK 'code002' (start 0xe200 end 0xe233)
code002_start:
	jp BOOT			;e200
le203h:
	jp WBOOT		;e203
	jp CONST		;e206
	jp CONIN		;e209
	jp CONOUT		;e20c
	jp LIST			;e20f
	jp PUNCH		;e212
	jp READER		;e215
	jp HOME			;e218
	jp SELDSK		;e21b
	jp SETTRK		;e21e
	jp SETSEC		;e221
	jp SETDMA		;e224
	jp SECTRAN		;e227
	jp READ			;e22a
	jp WRITE		;e22d
	jp LISTST		;e230
code002_end:
EXTCFG:

; BLOCK 'extcfg' (start 0xe233 end 0xe24a)
extcfg_start:
	defb 000h		;e233
le234h:
	defb 000h		;e234
le235h:
	defb 000h		;e235
	defb 000h		;e236
le237h:
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
extcfg_end:
INTJP:

; BLOCK 'code004' (start 0xe24a end 0xe259)
code004_start:
	jp READS		;e24a
	jp LINSEL		;e24d
	jp EXIT			;e250
	jp CLOCK		;e253
	jp INTFN5		;e256
code004_end:
MSGPAD:

; BLOCK 'msgpad' (start 0xe259 end 0xe25c)
msgpad_start:
	defb 000h		;e259
	defb 000h		;e25a
	defb 000h		;e25b
msgpad_end:
ERRMSG:

; BLOCK 'errmsg' (start 0xe25c end 0xe274)
errmsg_start:
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
errmsg_end:
SIGNON:

; BLOCK 'signon' (start 0xe274 end 0xe28a)
signon_start:
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
le289h:
	defb 07eh		;e289
signon_end:

; BLOCK 'code008' (start 0xe28a end 0xe7fc)
code008_start:
	or a			;e28a
	ret z			;e28b
	push hl			;e28c
	ld c,a			;e28d
	call CONOUT		;e28e
	pop hl			;e291
	inc hl			;e292
	jp le289h		;e293
le296h:
	ld hl,msgpad_end	;e296
	call le289h		;e299
le29ch:
	jp le29ch		;e29c
CLOCK:
	ld a,0c3h		;e29f
	ld (WARMJP),a		;e2a1
	ld (0ffe6h),hl		;e2a4
	ex de,hl		;e2a7
	ld (TIMER1),hl		;e2a8
	ret			;e2ab
INTFN5:
	or a			;e2ac
	jp z,le2b8h		;e2ad
	ld de,(RTCCNT)		;e2b0
	ld hl,(0fffeh)		;e2b4
	ret			;e2b7
le2b8h:
	ld (RTCCNT),de		;e2b8
	ld (0fffeh),hl		;e2bc
	ret			;e2bf
EXIT:
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
	call sub_f13eh		;e2da
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
BOOT:
	ld sp,00080h		;e2f8
	ld hl,errmsg_end	;e2fb
	call le289h		;e2fe
	xor a			;e301
	ld (00004h),a		;e302
	ld (lead5h),a		;e305
	ld (leaddh),a		;e308
	ld (lead6h),a		;e30b
	in a,(014h)		;e30e
	and 080h		;e310
	jp z,WBOOT		;e312
	ld c,001h		;e315
	call SELDSK		;e317
	call HOME		;e31a
	ld a,b			;e31d
	and 010h		;e31e
	ld a,000h		;e320
	jr nz,le325h		;e322
	inc a			;e324
le325h:
	ld (lee19h),a		;e325
WBOOT:
	ei			;e328
	ld c,000h		;e329
	call SELDSK		;e32b
	xor a			;e32e
	ld (lead7h),a		;e32f
	ld (00003h),a		;e332
	ld (lee19h+1),a		;e335
	ld (le499h),a		;e338
	call HOME		;e33b
	ld sp,00080h		;e33e
	ld bc,0cc00h		;e341
	call SETDMA		;e344
	ld b,000h		;e347
	ld c,001h		;e349
	call SETTRK		;e34b
	ld c,000h		;e34e
	call SETSEC		;e350
le353h:
	push bc			;e353
	call SECTRAN		;e354
	or a			;e357
	jp nz,le296h		;e358
	ld hl,(leae1h)		;e35b
	ld de,00080h		;e35e
	add hl,de		;e361
	ld b,h			;e362
	ld c,l			;e363
	call SETDMA		;e364
	pop bc			;e367
	inc c			;e368
	call SETSEC		;e369
	ld a,c			;e36c
	cp 02ch			;e36d
	jp nz,le353h		;e36f
	ld bc,00080h		;e372
	call SETDMA		;e375
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
	ld a,(lee19h)		;e392
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
WRITE:
	ld a,(le39fh)		;e3a8
	ret			;e3ab
LIST:
	ld a,(le39fh)		;e3ac
	or a			;e3af
	jp z,LIST		;e3b0
	di			;e3b3
	ld a,000h		;e3b4
	ld (le39fh),a		;e3b6
	ld a,005h		;e3b9
	out (00bh),a		;e3bb
	ld a,(le235h)		;e3bd
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
LINSEL:
	ld a,(le3a0h)		;e3eb
	ret			;e3ee
READER:
	call LINSEL		;e3ef
	or a			;e3f2
	jp z,READER		;e3f3
	ld a,(le3a2h)		;e3f6
	push af			;e3f9
	call sub_e3d1h		;e3fa
	pop af			;e3fd
	ret			;e3fe
PUNCH:
	ld a,(le3a1h)		;e3ff
	or a			;e402
	jp z,PUNCH		;e403
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
le424h:
	ex af,af'		;e424
	ld a,028h		;e425
	out (00bh),a		;e427
	ld a,0ffh		;e429
	ld (le39fh),a		;e42b
	ex af,af'		;e42e
	ei			;e42f
	reti			;e430
	ex af,af'		;e432
	in a,(00bh)		;e433
	ld (le3a6h),a		;e435
	ld a,010h		;e438
	out (00bh),a		;e43a
	ex af,af'		;e43c
	ei			;e43d
	reti			;e43e
	ex af,af'		;e440
	in a,(008h)		;e441
	ld (le3a3h),a		;e443
	ex af,af'		;e446
	ei			;e447
	reti			;e448
sub_e44ah:
	ex af,af'		;e44a
	ld a,001h		;e44b
	out (00bh),a		;e44d
	in a,(00bh)		;e44f
	ld (le3a7h),a		;e451
	ld a,030h		;e454
	out (00bh),a		;e456
	ex af,af'		;e458
	ei			;e459
	reti			;e45a
	ex af,af'		;e45c
	ld a,028h		;e45d
	out (00ah),a		;e45f
	ld a,0ffh		;e461
	ld (le3a1h),a		;e463
	ex af,af'		;e466
	ei			;e467
	reti			;e468
sub_e46ah:
	ex af,af'		;e46a
	in a,(00ah)		;e46b
	ld (le3a4h),a		;e46d
	ld a,010h		;e470
	out (00ah),a		;e472
	ex af,af'		;e474
	ei			;e475
	reti			;e476
	ex af,af'		;e478
	in a,(008h)		;e479
	ld (le3a2h),a		;e47b
	ld a,0ffh		;e47e
	ld (le3a0h),a		;e480
	ex af,af'		;e483
	ei			;e484
	reti			;e485
sub_e487h:
	ex af,af'		;e487
	ld a,001h		;e488
	out (00ah),a		;e48a
	in a,(00ah)		;e48c
	ld (le3a5h),a		;e48e
	ld a,030h		;e491
	out (00ah),a		;e493
	ex af,af'		;e495
	ei			;e496
	reti			;e497
le499h:
	nop			;e499
le49ah:
	nop			;e49a
CONST:
	ld a,(le499h)		;e49b
	ret			;e49e
CONIN:
	ld a,(le499h)		;e49f
	or a			;e4a2
	jp z,CONIN		;e4a3
	di			;e4a6
	xor a			;e4a7
	ld (le499h),a		;e4a8
	ei			;e4ab
	in a,(010h)		;e4ac
	ld c,a			;e4ae
	ld hl,0f700h		;e4af
	call sub_e4eah		;e4b2
	ret			;e4b5
le4b6h:
	ex af,af'		;e4b6
	ld a,0ffh		;e4b7
	ld (le499h),a		;e4b9
	ex af,af'		;e4bc
	ei			;e4bd
	reti			;e4be
	ex af,af'		;e4c0
	ld a,0ffh		;e4c1
	ld (le49ah),a		;e4c3
	ex af,af'		;e4c6
	ei			;e4c7
	reti			;e4c8
le4cah:
	nop			;e4ca
le4cbh:
	nop			;e4cb
	nop			;e4cc
sub_e4cdh:
	ld a,h			;e4cd
	cpl			;e4ce
	ld h,a			;e4cf
	ld a,l			;e4d0
	cpl			;e4d1
	ld l,a			;e4d2
	ret			;e4d3
sub_e4d4h:
	call sub_e4cdh		;e4d4
	inc hl			;e4d7
	ret			;e4d8
sub_e4d9h:
	ld hl,(CURY)		;e4d9
	ld a,l			;e4dc
	cp 080h			;e4dd
	ret nz			;e4df
	ld a,h			;e4e0
	cp 007h			;e4e1
	ret			;e4e3
sub_e4e4h:
	ld a,(le4cah)		;e4e4
	or a			;e4e7
	ld a,c			;e4e8
	ret nz			;e4e9
sub_e4eah:
	ld b,000h		;e4ea
	add hl,bc		;e4ec
	ld a,(hl)		;e4ed
	ret			;e4ee
le4efh:
	push af			;e4ef
	ld a,080h		;e4f0
	out (001h),a		;e4f2
	ld a,(CURX)		;e4f4
	out (000h),a		;e4f7
	ld a,(0ffd4h)		;e4f9
	out (000h),a		;e4fc
	pop af			;e4fe
	ret			;e4ff
le500h:
	ld hl,(CURY)		;e500
	ld de,00050h		;e503
	add hl,de		;e506
	ld (CURY),hl		;e507
	ld hl,0ffd4h		;e50a
	inc (hl)		;e50d
	jp le4efh		;e50e
le511h:
	ld hl,(CURY)		;e511
	ld de,0ffb0h		;e514
	add hl,de		;e517
	ld (CURY),hl		;e518
	ld hl,0ffd4h		;e51b
	dec (hl)		;e51e
	jp le4efh		;e51f
sub_e522h:
	ld hl,00000h		;e522
	ld (CURY),hl		;e525
	xor a			;e528
	ld (CURX),a		;e529
	ld (0ffd4h),a		;e52c
	ret			;e52f
le530h:
	cp b			;e530
	ret c			;e531
	sub b			;e532
	jp le530h		;e533
le536h:
	ld hl,(0ffd5h)		;e536
	ld d,h			;e539
	ld e,l			;e53a
	inc de			;e53b
	ld bc,0004fh		;e53c
	ld (hl),020h		;e53f
	ldir			;e541
	ld a,(0ffdbh)		;e543
	cp 000h			;e546
	ret z			;e548
	ld hl,(0ffdch)		;e549
	ld d,h			;e54c
	ld e,l			;e54d
	inc de			;e54e
	ld bc,00009h		;e54f
	ld (hl),000h		;e552
	ldir			;e554
	ret			;e556
le557h:
	ld hl,0f850h		;e557
	ld de,SCREENBUF		;e55a
	ld bc,00780h		;e55d
	ldir			;e560
	ld hl,0ff80h		;e562
	ld (0ffd5h),hl		;e565
	ld a,(0ffdbh)		;e568
	cp 000h			;e56b
	jp z,le536h		;e56d
	ld hl,0f50ah		;e570
	ld de,trailing_end	;e573
	ld bc,000f0h		;e576
	ldir			;e579
	ld hl,0f5f0h		;e57b
	ld (0ffdch),hl		;e57e
	jp le536h		;e581
sub_e584h:
	ld a,000h		;e584
	ld b,003h		;e586
le588h:
	srl h			;e588
	rr l			;e58a
	rra			;e58c
	dec b			;e58d
	jp nz,le588h		;e58e
	cp 000h			;e591
	ret z			;e593
	ld b,005h		;e594
le596h:
	rra			;e596
	dec b			;e597
	jp nz,le596h		;e598
	ret			;e59b
sub_e59ch:
	ld de,trailing_end	;e59c
	add hl,de		;e59f
	cp 000h			;e5a0
	ld b,a			;e5a2
	ld a,000h		;e5a3
	jp nz,le5abh		;e5a5
	and (hl)		;e5a8
	ld (hl),a		;e5a9
	ret			;e5aa
le5abh:
	scf			;e5ab
	rla			;e5ac
	dec b			;e5ad
	jp nz,le5abh		;e5ae
	and (hl)		;e5b1
	ld (hl),a		;e5b2
	ret			;e5b3
le5b4h:
	ld a,000h		;e5b4
	cp c			;e5b6
	jp z,le5bdh		;e5b7
le5bah:
	ldir			;e5ba
	ret			;e5bc
le5bdh:
	cp b			;e5bd
	jp nz,le5bah		;e5be
	ret			;e5c1
sub_e5c2h:
	ld a,000h		;e5c2
	cp c			;e5c4
	jp z,le5cbh		;e5c5
le5c8h:
	lddr			;e5c8
	ret			;e5ca
le5cbh:
	cp b			;e5cb
	jp nz,le5c8h		;e5cc
	ret			;e5cf
	out (01ch),a		;e5d0
	ret			;e5d2
	call sub_e522h		;e5d3
	ld a,002h		;e5d6
	ld (0ffd7h),a		;e5d8
	ret			;e5db
	ret			;e5dc
	ld a,000h		;e5dd
	ld (CURX),a		;e5df
	jp le4efh		;e5e2
	ld hl,SCRNEND		;e5e5
	ld de,0ffceh		;e5e8
	ld bc,007cfh		;e5eb
	ld (hl),020h		;e5ee
	lddr			;e5f0
	call sub_e522h		;e5f2
	call le4efh		;e5f5
	ld a,(0ffdbh)		;e5f8
	cp 000h			;e5fb
	ret z			;e5fd
	xor a			;e5fe
	ld (0ffdbh),a		;e5ff
	ld hl,0f5f9h		;e602
	ld de,0f5f8h		;e605
	ld bc,000f9h		;e608
	ld (hl),000h		;e60b
	lddr			;e60d
	ret			;e60f
	ld de,SCREENBUF		;e610
	ld hl,(CURY)		;e613
	add hl,de		;e616
	ld de,0004fh		;e617
	add hl,de		;e61a
	ld d,h			;e61b
	ld e,l			;e61c
	dec de			;e61d
	ld bc,00000h		;e61e
	ld a,(CURX)		;e621
	cpl			;e624
	inc a			;e625
	add a,04fh		;e626
	ld c,a			;e628
	ld (hl),020h		;e629
	call sub_e5c2h		;e62b
	ld a,(0ffdbh)		;e62e
	cp 000h			;e631
	ret z			;e633
	ld hl,(CURY)		;e634
	ld d,000h		;e637
	ld a,(CURX)		;e639
	ld e,a			;e63c
	add hl,de		;e63d
	call sub_e584h		;e63e
	call sub_e59ch		;e641
	ld a,(CURX)		;e644
	srl a			;e647
	srl a			;e649
	srl a			;e64b
	cpl			;e64d
	add a,009h		;e64e
	ret m			;e650
	ld c,a			;e651
	ld b,000h		;e652
	inc hl			;e654
	ld d,h			;e655
	ld e,l			;e656
	inc de			;e657
	ld a,000h		;e658
	jp le5b4h		;e65a
	ld hl,(CURY)		;e65d
	ld a,(CURX)		;e660
	ld c,a			;e663
	ld b,000h		;e664
	add hl,bc		;e666
	call sub_e4d4h		;e667
	ld de,007cfh		;e66a
	add hl,de		;e66d
	ld b,h			;e66e
	ld c,l			;e66f
	ld hl,SCRNEND		;e670
	ld de,0ffceh		;e673
	ld (hl),020h		;e676
	call sub_e5c2h		;e678
	ld a,(0ffdbh)		;e67b
	cp 000h			;e67e
	ret z			;e680
	ld hl,(CURY)		;e681
	ld d,000h		;e684
	ld a,(CURX)		;e686
	ld e,a			;e689
	add hl,de		;e68a
	call sub_e584h		;e68b
	call sub_e59ch		;e68e
	call sub_e4cdh		;e691
	ld de,0f5f9h		;e694
	add hl,de		;e697
	ld a,080h		;e698
	and h			;e69a
	ret nz			;e69b
	ld b,h			;e69c
	ld c,l			;e69d
	ld h,d			;e69e
	ld l,e			;e69f
	dec de			;e6a0
	ld (hl),000h		;e6a1
	jp sub_e5c2h		;e6a3
	ld a,(CURX)		;e6a6
	cp 000h			;e6a9
	jp z,le6b5h		;e6ab
	dec a			;e6ae
	ld (CURX),a		;e6af
	jp le4efh		;e6b2
le6b5h:
	ld a,04fh		;e6b5
	ld (CURX),a		;e6b7
	ld hl,(CURY)		;e6ba
	ld a,l			;e6bd
	or h			;e6be
	jp nz,le511h		;e6bf
	ld hl,00780h		;e6c2
	ld (CURY),hl		;e6c5
	ld a,018h		;e6c8
	ld (0ffd4h),a		;e6ca
	jp le4efh		;e6cd
sub_e6d0h:
	ld a,(CURX)		;e6d0
	cp 04fh			;e6d3
	jp z,le6dfh		;e6d5
	inc a			;e6d8
	ld (CURX),a		;e6d9
	jp le4efh		;e6dc
le6dfh:
	ld a,000h		;e6df
	ld (CURX),a		;e6e1
	call sub_e4d9h		;e6e4
	jp nz,le500h		;e6e7
	call le4efh		;e6ea
	jp le557h		;e6ed
	call sub_e6d0h		;e6f0
	call sub_e6d0h		;e6f3
	call sub_e6d0h		;e6f6
	jp sub_e6d0h		;e6f9
	call sub_e4d9h		;e6fc
	jp nz,le500h		;e6ff
	jp le557h		;e702
	ld hl,(CURY)		;e705
	ld a,l			;e708
	or h			;e709
	jp nz,le511h		;e70a
	ld hl,00780h		;e70d
	ld (CURY),hl		;e710
	ld a,018h		;e713
	ld (0ffd4h),a		;e715
	jp le4efh		;e718
	call sub_e522h		;e71b
	jp le4efh		;e71e
	ld hl,(CURY)		;e721
	ld b,h			;e724
	ld c,l			;e725
	ld de,0f850h		;e726
	add hl,de		;e729
	ld (le4cbh),hl		;e72a
	ld de,0ffb0h		;e72d
	add hl,de		;e730
	ex de,hl		;e731
	ld h,b			;e732
	ld l,c			;e733
	call sub_e4d4h		;e734
	ld bc,00780h		;e737
	add hl,bc		;e73a
	ld b,h			;e73b
	ld c,l			;e73c
	ld hl,(le4cbh)		;e73d
	call le5b4h		;e740
	ld hl,0ff80h		;e743
	ld (0ffd5h),hl		;e746
	ld a,(0ffdbh)		;e749
	cp 000h			;e74c
	jp z,le536h		;e74e
	ld hl,(CURY)		;e751
	call sub_e584h		;e754
	ld b,h			;e757
	ld c,l			;e758
	ld de,0f50ah		;e759
	add hl,de		;e75c
	ld (le4cbh),hl		;e75d
	ld de,0fff6h		;e760
	add hl,de		;e763
	ex de,hl		;e764
	ld h,b			;e765
	ld l,c			;e766
	call sub_e4d4h		;e767
	ld bc,000f0h		;e76a
	add hl,bc		;e76d
	ld b,h			;e76e
	ld c,l			;e76f
	ld hl,(le4cbh)		;e770
	call le5b4h		;e773
	ld hl,0f5f0h		;e776
	ld (0ffdch),hl		;e779
	jp le536h		;e77c
	ld hl,(CURY)		;e77f
	ld de,SCREENBUF		;e782
	add hl,de		;e785
	ld (0ffd5h),hl		;e786
	call sub_e4d4h		;e789
	ld de,0ff80h		;e78c
	add hl,de		;e78f
	ld b,h			;e790
	ld c,l			;e791
	ld hl,0ff7fh		;e792
	ld de,SCRNEND		;e795
	call sub_e5c2h		;e798
	ld a,(0ffdbh)		;e79b
	cp 000h			;e79e
	jp z,le536h		;e7a0
	ld hl,(CURY)		;e7a3
	call sub_e584h		;e7a6
	ld de,trailing_end	;e7a9
	add hl,de		;e7ac
	ld (0ffdch),hl		;e7ad
	call sub_e4d4h		;e7b0
	ld de,0f5f0h		;e7b3
	add hl,de		;e7b6
	ld b,h			;e7b7
	ld c,l			;e7b8
	ld hl,0f5efh		;e7b9
	ld de,0f5f9h		;e7bc
	call sub_e5c2h		;e7bf
	jp le536h		;e7c2
	ld a,002h		;e7c5
	ld (0ffdbh),a		;e7c7
	ret			;e7ca
	ld a,001h		;e7cb
	ld (0ffdbh),a		;e7cd
	ret			;e7d0
	ld hl,SCREENBUF		;e7d1
	ld de,trailing_end	;e7d4
	ld b,0fah		;e7d7
le7d9h:
	ld a,(de)		;e7d9
	ld c,008h		;e7da
	cp 000h			;e7dc
	jp nz,le7ebh		;e7de
le7e1h:
	ld (hl),020h		;e7e1
	inc hl			;e7e3
	dec c			;e7e4
	jp nz,le7e1h		;e7e5
	jp le7f6h		;e7e8
le7ebh:
	rra			;e7eb
	jp c,le7f1h		;e7ec
	ld (hl),020h		;e7ef
le7f1h:
	inc hl			;e7f1
	dec c			;e7f2
	jp nz,le7ebh		;e7f3
le7f6h:
	inc de			;e7f6
	dec b			;e7f7
	jp nz,le7d9h		;e7f8
	ret			;e7fb
code008_end:
INTVEC:

; BLOCK 'intvec' (start 0xe7fc end 0xe83c)
intvec_start:
	defw 0e5dch		;e7fc
	defw 0e77fh		;e7fe
	defw 0e721h		;e800
	defw 0e5dch		;e802
	defw 0e5dch		;e804
	defw 0e6a6h		;e806
	defw 0e5d3h		;e808
	defw 0e5d0h		;e80a
	defw 0e6a6h		;e80c
	defw 0e6f0h		;e80e
	defw 0e6fch		;e810
	defw 0e5dch		;e812
	defw 0e5e5h		;e814
	defw 0e5ddh		;e816
	defw 0e5dch		;e818
	defw 0e5dch		;e81a
	defw 0e5dch		;e81c
	defw 0e5dch		;e81e
	defw 0e5dch		;e820
	defw 0e5dch		;e822
	defw 0e7c5h		;e824
	defw 0e7cbh		;e826
	defw 0e7d1h		;e828
	defw 0e5dch		;e82a
	defw 0e6d0h		;e82c
	defw 0e5dch		;e82e
	defw 0e705h		;e830
	defw 0e5dch		;e832
	defw 0e5dch		;e834
	defw 0e71bh		;e836
	defw 0e610h		;e838
	defw 0e65dh		;e83a
intvec_end:

; BLOCK 'code010' (start 0xe83c end 0xe9b2)
code010_start:
	ld a,000h		;e83c
	ld (0ffd7h),a		;e83e
	ld a,(0ffdah)		;e841
	rlca			;e844
	and 03eh		;e845
	ld c,a			;e847
	ld b,000h		;e848
	ld hl,code008_end	;e84a
	add hl,bc		;e84d
	ld e,(hl)		;e84e
	inc hl			;e84f
	ld d,(hl)		;e850
	ex de,hl		;e851
	jp (hl)			;e852
sub_e853h:
	ld a,(0ffdah)		;e853
	and 07fh		;e856
	sub 020h		;e858
	ld hl,0ffd7h		;e85a
	dec (hl)		;e85d
	jp z,le865h		;e85e
	ld (0ffdeh),a		;e861
	ret			;e864
le865h:
	ld d,a			;e865
	ld a,(0ffdeh)		;e866
	ld h,a			;e869
	ld a,(code002_end)	;e86a
	or a			;e86d
	jp z,le872h		;e86e
	ex de,hl		;e871
le872h:
	ld a,h			;e872
	ld b,050h		;e873
	call le530h		;e875
	ld (CURX),a		;e878
	ld a,d			;e87b
	ld b,019h		;e87c
	call le530h		;e87e
	ld (0ffd4h),a		;e881
	or a			;e884
	jp z,le4efh		;e885
	ld hl,(CURY)		;e888
	ld de,00050h		;e88b
le88eh:
	add hl,de		;e88e
	dec a			;e88f
	jp nz,le88eh		;e890
	ld (CURY),hl		;e893
	jp le4efh		;e896
sub_e899h:
	ld hl,(CURY)		;e899
	ld d,000h		;e89c
	ld a,(CURX)		;e89e
	ld e,a			;e8a1
	add hl,de		;e8a2
	ld (0ffd8h),hl		;e8a3
	ld a,(0ffdah)		;e8a6
	cp 0c0h			;e8a9
	jp c,le8b0h		;e8ab
	sub 0c0h		;e8ae
le8b0h:
	ld c,a			;e8b0
	cp 080h			;e8b1
	jp c,le8bfh		;e8b3
	and 004h		;e8b6
	ld (le4cah),a		;e8b8
	ld a,c			;e8bb
	jp le8c5h		;e8bc
le8bfh:
	ld hl,CONVTAB		;e8bf
	call sub_e4e4h		;e8c2
le8c5h:
	ld hl,(0ffd8h)		;e8c5
	ld de,SCREENBUF		;e8c8
	add hl,de		;e8cb
	ld (hl),a		;e8cc
	call sub_e6d0h		;e8cd
	ld a,(0ffdbh)		;e8d0
	cp 002h			;e8d3
	ret nz			;e8d5
	ld hl,(0ffd8h)		;e8d6
	call sub_e584h		;e8d9
	ld de,trailing_end	;e8dc
	add hl,de		;e8df
	cp 000h			;e8e0
	ld b,a			;e8e2
	ld a,001h		;e8e3
	jp nz,le8ebh		;e8e5
	or (hl)			;e8e8
	ld (hl),a		;e8e9
	ret			;e8ea
le8ebh:
	rlca			;e8eb
	dec b			;e8ec
	jp nz,le8ebh		;e8ed
	or (hl)			;e8f0
	ld (hl),a		;e8f1
	ret			;e8f2
CONOUT:
	di			;e8f3
	push hl			;e8f4
	ld hl,00000h		;e8f5
	add hl,sp		;e8f8
	ld sp,CONVTAB		;e8f9
	ei			;e8fc
	push hl			;e8fd
	push af			;e8fe
	push bc			;e8ff
	push de			;e900
	ld a,c			;e901
	ld (0ffdah),a		;e902
	ld a,(0ffd7h)		;e905
	or a			;e908
	jp z,le912h		;e909
	call sub_e853h		;e90c
	jp le923h		;e90f
le912h:
	ld a,(0ffdah)		;e912
	cp 020h			;e915
	jp nc,le920h		;e917
	call intvec_end		;e91a
	jp le923h		;e91d
le920h:
	call sub_e899h		;e920
le923h:
	pop de			;e923
	pop bc			;e924
	pop af			;e925
	pop hl			;e926
	di			;e927
	ld sp,hl		;e928
	pop hl			;e929
	ei			;e92a
	ret			;e92b
	ex af,af'		;e92c
	exx			;e92d
	ld hl,00000h		;e92e
	add hl,sp		;e931
	ld sp,ISRSTACK		;e932
	push hl			;e935
	in a,(001h)		;e936
	ld a,006h		;e938
	out (0fah),a		;e93a
	ld a,007h		;e93c
	out (0fah),a		;e93e
	out (0fch),a		;e940
	ld hl,SCREENBUF		;e942
	ld a,l			;e945
	out (0f4h),a		;e946
	ld a,h			;e948
	out (0f4h),a		;e949
	ld hl,007cfh		;e94b
	ld a,l			;e94e
	out (0f5h),a		;e94f
	ld a,h			;e951
	out (0f5h),a		;e952
	ld a,000h		;e954
	out (0f7h),a		;e956
	out (0f7h),a		;e958
	ld a,002h		;e95a
	out (0fah),a		;e95c
	ld a,003h		;e95e
	out (0fah),a		;e960
	ld a,0d7h		;e962
	out (00eh),a		;e964
	ld a,001h		;e966
	out (00eh),a		;e968
	ld hl,RTCCNT		;e96a
	inc (hl)		;e96d
	jp nz,le97dh		;e96e
	inc hl			;e971
	inc (hl)		;e972
	jp nz,le97dh		;e973
	inc hl			;e976
	inc (hl)		;e977
	jp nz,le97dh		;e978
	inc hl			;e97b
	inc (hl)		;e97c
le97dh:
	ld hl,(TIMER1)		;e97d
	ld a,l			;e980
	or h			;e981
	jp z,le98eh		;e982
	dec hl			;e985
	ld a,l			;e986
	or h			;e987
	ld (TIMER1),hl		;e988
	call z,WARMJP		;e98b
le98eh:
	ld hl,(TIMER2)		;e98e
	ld a,l			;e991
	or h			;e992
	jp z,le99fh		;e993
	dec hl			;e996
	ld a,l			;e997
	or h			;e998
	ld (TIMER2),hl		;e999
	call z,sub_f134h	;e99c
le99fh:
	ld hl,(0ffe3h)		;e99f
	ld a,l			;e9a2
	or h			;e9a3
	jp z,le9abh		;e9a4
	dec hl			;e9a7
	ld (0ffe3h),hl		;e9a8
le9abh:
	pop hl			;e9ab
	ld sp,hl		;e9ac
	exx			;e9ad
	ex af,af'		;e9ae
	ei			;e9af
	reti			;e9b0
code010_end:
SKEW_T0:

; BLOCK 'skew_t0' (start 0xe9b2 end 0xe9cc)
skew_t0_start:
	defb 001h		;e9b2
	defb 007h		;e9b3
	defb 00dh		;e9b4
	defb 013h		;e9b5
	defb 019h		;e9b6
	defb 005h		;e9b7
	defb 00bh		;e9b8
	defb 011h		;e9b9
	defb 017h		;e9ba
	defb 003h		;e9bb
	defb 009h		;e9bc
	defb 00fh		;e9bd
	defb 015h		;e9be
	defb 002h		;e9bf
	defb 008h		;e9c0
	defb 00eh		;e9c1
	defb 014h		;e9c2
	defb 01ah		;e9c3
	defb 006h		;e9c4
	defb 00ch		;e9c5
	defb 012h		;e9c6
	defb 018h		;e9c7
	defb 004h		;e9c8
	defb 00ah		;e9c9
	defb 010h		;e9ca
	defb 016h		;e9cb
skew_t0_end:
SKEW_MAXI:

; BLOCK 'skew_maxi' (start 0xe9cc end 0xe9db)
skew_maxi_start:
	defb 001h		;e9cc
	defb 005h		;e9cd
	defb 009h		;e9ce
	defb 00dh		;e9cf
	defb 002h		;e9d0
	defb 006h		;e9d1
	defb 00ah		;e9d2
	defb 00eh		;e9d3
	defb 003h		;e9d4
	defb 007h		;e9d5
	defb 00bh		;e9d6
	defb 00fh		;e9d7
	defb 004h		;e9d8
	defb 008h		;e9d9
	defb 00ch		;e9da
skew_maxi_end:
SKEW_MINI:

; BLOCK 'skew_mini' (start 0xe9db end 0xe9e4)
skew_mini_start:
	defb 001h		;e9db
	defb 003h		;e9dc
	defb 005h		;e9dd
	defb 007h		;e9de
	defb 009h		;e9df
	defb 002h		;e9e0
	defb 004h		;e9e1
	defb 006h		;e9e2
	defb 008h		;e9e3
skew_mini_end:
SKEW_SEQ:

; BLOCK 'skew_seq' (start 0xe9e4 end 0xe9fe)
skew_seq_start:
	defb 001h		;e9e4
	defb 002h		;e9e5
	defb 003h		;e9e6
	defb 004h		;e9e7
	defb 005h		;e9e8
	defb 006h		;e9e9
	defb 007h		;e9ea
	defb 008h		;e9eb
	defb 009h		;e9ec
	defb 00ah		;e9ed
	defb 00bh		;e9ee
	defb 00ch		;e9ef
	defb 00dh		;e9f0
	defb 00eh		;e9f1
	defb 00fh		;e9f2
	defb 010h		;e9f3
	defb 011h		;e9f4
	defb 012h		;e9f5
	defb 013h		;e9f6
	defb 014h		;e9f7
	defb 015h		;e9f8
	defb 016h		;e9f9
	defb 017h		;e9fa
	defb 018h		;e9fb
	defb 019h		;e9fc
	defb 01ah		;e9fd
skew_seq_end:
DPB_FM1:

; BLOCK 'dpb_fm1' (start 0xe9fe end 0xea0d)
dpb_fm1_start:
	defw 0001ah		;e9fe
	defw 00703h		;ea00
	defw 0f200h		;ea02
	defw 03f00h		;ea04
	defw 0c000h		;ea06
	defw 01000h		;ea08
	defw 00200h		;ea0a
	defb 000h		;ea0c
dpb_fm1_end:
DPB_MFM1:

; BLOCK 'dpb_mfm1' (start 0xea0d end 0xea1c)
dpb_mfm1_start:
	defw 00078h		;ea0d
	defw 00f04h		;ea0f
	defw 0c100h		;ea11
	defw 07f01h		;ea13
	defw 0c000h		;ea15
	defw 02000h		;ea17
	defw 00200h		;ea19
	defb 000h		;ea1b
dpb_mfm1_end:
DPB_FM2:

; BLOCK 'dpb_fm2' (start 0xea1c end 0xea2b)
dpb_fm2_start:
	defw 0001ah		;ea1c
	defw 00703h		;ea1e
	defw 0f200h		;ea20
	defw 03f00h		;ea22
	defw 0c000h		;ea24
	defw 01000h		;ea26
	defw 00000h		;ea28
	defb 000h		;ea2a
dpb_fm2_end:
DPB_MFM2:

; BLOCK 'dpb_mfm2' (start 0xea2b end 0xea3a)
dpb_mfm2_start:
	defw 00068h		;ea2b
	defw 00f04h		;ea2d
	defw 0d700h		;ea2f
	defw 07f01h		;ea31
	defw 0c000h		;ea33
	defw 02000h		;ea35
	defw 00000h		;ea37
	defb 000h		;ea39
dpb_mfm2_end:
DSKCFG:

; BLOCK 'dskcfg' (start 0xea3a end 0xeaba)
dskcfg_start:
	defb 0feh		;ea3a
	defb 0e9h		;ea3b
	defb 008h		;ea3c
	defb 01ah		;ea3d
	defb 000h		;ea3e
	defb 001h		;ea3f
	defb 0b2h		;ea40
	defb 0e9h		;ea41
	defb 080h		;ea42
	defb 000h		;ea43
	defb 000h		;ea44
	defb 000h		;ea45
	defb 000h		;ea46
	defb 000h		;ea47
	defb 000h		;ea48
	defb 000h		;ea49
	defb 00dh		;ea4a
	defb 0eah		;ea4b
	defb 010h		;ea4c
	defb 078h		;ea4d
	defb 003h		;ea4e
	defb 003h		;ea4f
	defb 0cch		;ea50
	defb 0e9h		;ea51
	defb 0ffh		;ea52
	defb 000h		;ea53
	defb 000h		;ea54
	defb 000h		;ea55
	defb 000h		;ea56
	defb 000h		;ea57
	defb 000h		;ea58
	defb 000h		;ea59
	defb 0feh		;ea5a
	defb 0e9h		;ea5b
	defb 008h		;ea5c
	defb 01ah		;ea5d
	defb 000h		;ea5e
	defb 001h		;ea5f
	defb 0e4h		;ea60
	defb 0e9h		;ea61
	defb 080h		;ea62
	defb 000h		;ea63
	defb 000h		;ea64
	defb 000h		;ea65
	defb 000h		;ea66
	defb 000h		;ea67
	defb 000h		;ea68
	defb 000h		;ea69
	defb 02bh		;ea6a
	defb 0eah		;ea6b
	defb 008h		;ea6c
	defb 068h		;ea6d
	defb 001h		;ea6e
	defb 002h		;ea6f
	defb 0e4h		;ea70
	defb 0e9h		;ea71
	defb 0ffh		;ea72
	defb 000h		;ea73
	defb 000h		;ea74
	defb 000h		;ea75
	defb 000h		;ea76
	defb 000h		;ea77
	defb 000h		;ea78
	defb 000h		;ea79
	defb 01ah		;ea7a
lea7bh:
	defb 07fh		;ea7b
	defb 000h		;ea7c
	defb 000h		;ea7d
	defb 000h		;ea7e
	defb 01ah		;ea7f
	defb 007h		;ea80
	defb 04dh		;ea81
	defb 01eh		;ea82
	defb 0ffh		;ea83
	defb 001h		;ea84
	defb 040h		;ea85
	defb 002h		;ea86
	defb 00fh		;ea87
	defb 01bh		;ea88
	defb 04dh		;ea89
	defb 01ah		;ea8a
	defb 07fh		;ea8b
	defb 000h		;ea8c
	defb 000h		;ea8d
	defb 000h		;ea8e
	defb 01ah		;ea8f
	defb 007h		;ea90
	defb 04dh		;ea91
	defb 034h		;ea92
	defb 0ffh		;ea93
	defb 000h		;ea94
	defb 040h		;ea95
	defb 001h		;ea96
	defb 01ah		;ea97
	defb 00eh		;ea98
	defb 04dh		;ea99
lea9ah:
	defb 000h		;ea9a
	defb 000h		;ea9b
	defb 000h		;ea9c
	defb 000h		;ea9d
	defb 000h		;ea9e
	defb 000h		;ea9f
	defb 000h		;eaa0
	defb 000h		;eaa1
	defb 0e3h		;eaa2
	defb 0ech		;eaa3
	defb 00dh		;eaa4
	defb 0eah		;eaa5
	defb 09ch		;eaa6
	defb 0edh		;eaa7
	defb 063h		;eaa8
	defb 0edh		;eaa9
	defb 000h		;eaaa
	defb 000h		;eaab
	defb 000h		;eaac
	defb 000h		;eaad
	defb 000h		;eaae
	defb 000h		;eaaf
	defb 000h		;eab0
	defb 000h		;eab1
	defb 0e3h		;eab2
	defb 0ech		;eab3
	defb 00dh		;eab4
	defb 0eah		;eab5
	defb 0f5h		;eab6
	defb 0edh		;eab7
	defb 0bch		;eab8
	defb 0edh		;eab9
dskcfg_end:
WORKSPACE:

; BLOCK 'workspace' (start 0xeaba end 0xee15)
workspace_start:
	defb 000h		;eaba
leabbh:
	defb 000h		;eabb
leabch:
	defb 000h		;eabc
leabdh:
	defb 000h		;eabd
leabeh:
	defb 000h		;eabe
leabfh:
	defb 000h		;eabf
leac0h:
	defb 000h		;eac0
	defb 000h		;eac1
leac2h:
	defb 000h		;eac2
	defb 000h		;eac3
	defb 000h		;eac4
	defb 000h		;eac5
	defb 000h		;eac6
	defb 000h		;eac7
	defb 000h		;eac8
	defb 000h		;eac9
leacah:
	defb 000h		;eaca
leacbh:
	defb 000h		;eacb
	defb 000h		;eacc
leacdh:
	defb 000h		;eacd
leaceh:
	defb 000h		;eace
leacfh:
	defb 000h		;eacf
	defb 000h		;ead0
lead1h:
	defb 000h		;ead1
lead2h:
	defb 000h		;ead2
lead3h:
	defb 000h		;ead3
lead4h:
	defb 000h		;ead4
lead5h:
	defb 000h		;ead5
lead6h:
	defb 000h		;ead6
lead7h:
	defb 000h		;ead7
lead8h:
	defb 000h		;ead8
lead9h:
	defb 000h		;ead9
	defb 000h		;eada
leadbh:
	defb 000h		;eadb
leadch:
	defb 000h		;eadc
leaddh:
	defb 000h		;eadd
leadeh:
	defb 000h		;eade
leadfh:
	defb 000h		;eadf
leae0h:
	defb 000h		;eae0
leae1h:
	defb 000h		;eae1
	defb 000h		;eae2
leae3h:
	defb 000h		;eae3
	defb 000h		;eae4
	defb 000h		;eae5
	defb 000h		;eae6
	defb 000h		;eae7
	defb 000h		;eae8
	defb 000h		;eae9
	defb 000h		;eaea
	defb 000h		;eaeb
	defb 000h		;eaec
	defb 000h		;eaed
	defb 000h		;eaee
	defb 000h		;eaef
	defb 000h		;eaf0
	defb 000h		;eaf1
	defb 000h		;eaf2
	defb 000h		;eaf3
	defb 000h		;eaf4
	defb 000h		;eaf5
	defb 000h		;eaf6
	defb 000h		;eaf7
	defb 000h		;eaf8
	defb 000h		;eaf9
	defb 000h		;eafa
	defb 000h		;eafb
	defb 000h		;eafc
	defb 000h		;eafd
	defb 000h		;eafe
	defb 000h		;eaff
	defb 000h		;eb00
	defb 000h		;eb01
	defb 000h		;eb02
	defb 000h		;eb03
	defb 000h		;eb04
	defb 000h		;eb05
	defb 000h		;eb06
	defb 000h		;eb07
	defb 000h		;eb08
	defb 000h		;eb09
	defb 000h		;eb0a
	defb 000h		;eb0b
	defb 000h		;eb0c
	defb 000h		;eb0d
	defb 000h		;eb0e
	defb 000h		;eb0f
	defb 000h		;eb10
	defb 000h		;eb11
	defb 000h		;eb12
	defb 000h		;eb13
	defb 000h		;eb14
	defb 000h		;eb15
	defb 000h		;eb16
	defb 000h		;eb17
	defb 000h		;eb18
	defb 000h		;eb19
	defb 000h		;eb1a
	defb 000h		;eb1b
	defb 000h		;eb1c
	defb 000h		;eb1d
	defb 000h		;eb1e
	defb 000h		;eb1f
	defb 000h		;eb20
	defb 000h		;eb21
	defb 000h		;eb22
	defb 000h		;eb23
	defb 000h		;eb24
	defb 000h		;eb25
	defb 000h		;eb26
	defb 000h		;eb27
	defb 000h		;eb28
	defb 000h		;eb29
	defb 000h		;eb2a
	defb 000h		;eb2b
	defb 000h		;eb2c
	defb 000h		;eb2d
	defb 000h		;eb2e
	defb 000h		;eb2f
	defb 000h		;eb30
	defb 000h		;eb31
	defb 000h		;eb32
	defb 000h		;eb33
	defb 000h		;eb34
	defb 000h		;eb35
	defb 000h		;eb36
	defb 000h		;eb37
	defb 000h		;eb38
	defb 000h		;eb39
	defb 000h		;eb3a
	defb 000h		;eb3b
	defb 000h		;eb3c
	defb 000h		;eb3d
	defb 000h		;eb3e
	defb 000h		;eb3f
	defb 000h		;eb40
	defb 000h		;eb41
	defb 000h		;eb42
	defb 000h		;eb43
	defb 000h		;eb44
	defb 000h		;eb45
	defb 000h		;eb46
	defb 000h		;eb47
	defb 000h		;eb48
	defb 000h		;eb49
	defb 000h		;eb4a
	defb 000h		;eb4b
	defb 000h		;eb4c
	defb 000h		;eb4d
	defb 000h		;eb4e
	defb 000h		;eb4f
	defb 000h		;eb50
	defb 000h		;eb51
	defb 000h		;eb52
	defb 000h		;eb53
	defb 000h		;eb54
	defb 000h		;eb55
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
workspace_end:

; BLOCK 'code021' (start 0xee15 end 0xf2bf)
code021_start:
	add a,e			;ee15
	jp pe,00000h		;ee16
lee19h:
	ld bc,00000h		;ee19
lee1ch:
	nop			;ee1c
lee1dh:
	nop			;ee1d
lee1eh:
	nop			;ee1e
lee1fh:
	nop			;ee1f
lee20h:
	nop			;ee20
lee21h:
	nop			;ee21
	nop			;ee22
	nop			;ee23
	nop			;ee24
	nop			;ee25
	nop			;ee26
	nop			;ee27
lee28h:
	rst 38h			;ee28
SELDSK:
	ld hl,00000h		;ee29
	add hl,sp		;ee2c
	ld sp,CONVTAB		;ee2d
	push hl			;ee30
	ld hl,00000h		;ee31
	ld a,(lee19h)		;ee34
	cp c			;ee37
	jp c,lee9eh		;ee38
	ld a,c			;ee3b
	ld (leacah),a		;ee3c
	ld bc,00000h		;ee3f
	ld hl,le237h		;ee42
	or a			;ee45
	jp z,lee4dh		;ee46
	inc hl			;ee49
	ld bc,00010h		;ee4a
lee4dh:
	ld a,(hl)		;ee4d
	ld hl,0ee17h		;ee4e
	cp (hl)			;ee51
	jp z,lee64h		;ee52
	push af			;ee55
	push bc			;ee56
	ld a,(lead6h)		;ee57
	or a			;ee5a
	call nz,sub_f00bh	;ee5b
	xor a			;ee5e
	ld (lead6h),a		;ee5f
	pop bc			;ee62
	pop af			;ee63
lee64h:
	ld (0ee17h),a		;ee64
	call sub_f10bh		;ee67
	ld (workspace_end),hl	;ee6a
	inc hl			;ee6d
	inc hl			;ee6e
	inc hl			;ee6f
	inc hl			;ee70
	ld a,(hl)		;ee71
	ld (0ee18h),a		;ee72
	push bc			;ee75
	ld a,(0ee17h)		;ee76
	or a			;ee79
	rla			;ee7a
	ld e,a			;ee7b
	ld d,000h		;ee7c
	ld hl,dpb_mfm2_end	;ee7e
	add hl,de		;ee81
	ld de,dskcfg_end	;ee82
	ld bc,00010h		;ee85
	ldir			;ee88
	pop bc			;ee8a
	ld hl,lea9ah		;ee8b
	add hl,bc		;ee8e
	ex de,hl		;ee8f
	ld hl,0000ah		;ee90
	add hl,de		;ee93
	ex de,hl		;ee94
	ld a,(dskcfg_end)	;ee95
	ld (de),a		;ee98
	inc de			;ee99
	ld a,(leabbh)		;ee9a
	ld (de),a		;ee9d
lee9eh:
	ex de,hl		;ee9e
	pop hl			;ee9f
	ld sp,hl		;eea0
	ex de,hl		;eea1
	ret			;eea2
SETTRK:
	ld h,b			;eea3
	ld l,c			;eea4
	ld (leacbh),hl		;eea5
	ret			;eea8
SETSEC:
	ld a,c			;eea9
	ld (leacdh),a		;eeaa
	ret			;eead
SETDMA:
	ld h,b			;eeae
	ld l,c			;eeaf
	ld (leae1h),hl		;eeb0
	ret			;eeb3
LISTST:
	ld h,b			;eeb4
	ld l,c			;eeb5
	ret			;eeb6
SECTRAN:
	ld a,001h		;eeb7
	ld (leadfh),a		;eeb9
	ld (leadeh),a		;eebc
	ld a,002h		;eebf
	ld (leae0h),a		;eec1
	jp lef4bh		;eec4
READ:
	xor a			;eec7
	ld (leadfh),a		;eec8
	ld a,c			;eecb
	ld (leae0h),a		;eecc
	cp 002h			;eecf
	jp nz,leeech		;eed1
	ld a,(leabch)		;eed4
	ld (lead7h),a		;eed7
	ld a,(leacah)		;eeda
	ld (lead8h),a		;eedd
	ld hl,(leacbh)		;eee0
	ld (lead9h),hl		;eee3
	ld a,(leacdh)		;eee6
	ld (leadbh),a		;eee9
leeech:
	ld a,(lead7h)		;eeec
	or a			;eeef
	jp z,lef41h		;eef0
	dec a			;eef3
	ld (lead7h),a		;eef4
	ld a,(leacah)		;eef7
	ld hl,lead8h		;eefa
	cp (hl)			;eefd
	jp nz,lef41h		;eefe
	ld hl,lead9h		;ef01
	call sub_efffh		;ef04
	jp nz,lef41h		;ef07
	ld a,(leacdh)		;ef0a
	ld hl,leadbh		;ef0d
	cp (hl)			;ef10
	jp nz,lef41h		;ef11
	inc (hl)		;ef14
	ld a,(hl)		;ef15
	ld hl,leabdh		;ef16
	cp (hl)			;ef19
	jp c,lef29h		;ef1a
	ld hl,leadbh		;ef1d
	ld (hl),000h		;ef20
	ld hl,(lead9h)		;ef22
	inc hl			;ef25
	ld (lead9h),hl		;ef26
lef29h:
	xor a			;ef29
	ld (leadeh),a		;ef2a
	ld a,(leacdh)		;ef2d
	ld hl,leabeh		;ef30
	and (hl)		;ef33
	cp (hl)			;ef34
	ld a,000h		;ef35
	jp nz,lef3bh		;ef37
	inc a			;ef3a
lef3bh:
	ld (leadch),a		;ef3b
	jp lef4bh		;ef3e
lef41h:
	xor a			;ef41
	ld (lead7h),a		;ef42
	ld a,(leabeh)		;ef45
	ld (leadeh),a		;ef48
lef4bh:
	ld hl,00000h		;ef4b
	add hl,sp		;ef4e
	ld sp,CONVTAB		;ef4f
	push hl			;ef52
	ld a,(leabfh)		;ef53
	ld b,a			;ef56
	ld a,(leacdh)		;ef57
lef5ah:
	dec b			;ef5a
	jp z,lef63h		;ef5b
	or a			;ef5e
	rra			;ef5f
	jp lef5ah		;ef60
lef63h:
	ld (lead4h),a		;ef63
	ld hl,lead5h		;ef66
	ld a,(hl)		;ef69
	ld (hl),001h		;ef6a
	or a			;ef6c
	jp z,lef94h		;ef6d
	ld a,(leacah)		;ef70
	ld hl,leaceh		;ef73
	cp (hl)			;ef76
	jp nz,lef8dh		;ef77
	ld hl,leacfh		;ef7a
	call sub_efffh		;ef7d
	jp nz,lef8dh		;ef80
	ld a,(lead4h)		;ef83
	ld hl,lead1h		;ef86
	cp (hl)			;ef89
	jp z,lefb1h		;ef8a
lef8dh:
	ld a,(lead6h)		;ef8d
	or a			;ef90
	call nz,sub_f00bh	;ef91
lef94h:
	ld a,(leacah)		;ef94
	ld (leaceh),a		;ef97
	ld hl,(leacbh)		;ef9a
	ld (leacfh),hl		;ef9d
	ld a,(lead4h)		;efa0
	ld (lead1h),a		;efa3
	ld a,(leadeh)		;efa6
	or a			;efa9
	call nz,sub_f011h	;efaa
	xor a			;efad
	ld (lead6h),a		;efae
lefb1h:
	ld a,(leacdh)		;efb1
	ld hl,leabeh		;efb4
	and (hl)		;efb7
	ld l,a			;efb8
	ld h,000h		;efb9
	add hl,hl		;efbb
	add hl,hl		;efbc
	add hl,hl		;efbd
	add hl,hl		;efbe
	add hl,hl		;efbf
	add hl,hl		;efc0
	add hl,hl		;efc1
	ld de,leae3h		;efc2
	add hl,de		;efc5
	ex de,hl		;efc6
	ld hl,(leae1h)		;efc7
	ld bc,00080h		;efca
	ex de,hl		;efcd
	ld a,(leadfh)		;efce
	or a			;efd1
	jp nz,lefdbh		;efd2
	ld a,001h		;efd5
	ld (lead6h),a		;efd7
	ex de,hl		;efda
lefdbh:
	ldir			;efdb
	ld a,(leae0h)		;efdd
	cp 001h			;efe0
	ld hl,leaddh		;efe2
	ld a,(hl)		;efe5
	ld (hl),000h		;efe6
	jp nz,leffch		;efe8
	or a			;efeb
	jp nz,leffch		;efec
	xor a			;efef
	ld (lead6h),a		;eff0
	call sub_f00bh		;eff3
	ld hl,leaddh		;eff6
	ld a,(hl)		;eff9
	ld (hl),000h		;effa
leffch:
	pop hl			;effc
	ld sp,hl		;effd
	ret			;effe
sub_efffh:
	ex de,hl		;efff
	ld hl,leacbh		;f000
	ld a,(de)		;f003
	cp (hl)			;f004
	ret nz			;f005
	inc de			;f006
	inc hl			;f007
	ld a,(de)		;f008
	cp (hl)			;f009
	ret			;f00a
sub_f00bh:
	call sub_f021h		;f00b
	jp lf0e1h		;f00e
sub_f011h:
	ld a,(leadch)		;f011
	or a			;f014
	jp nz,lf01bh		;f015
	ld (lead7h),a		;f018
lf01bh:
	call sub_f021h		;f01b
	jp lf097h		;f01e
sub_f021h:
	ld a,(lead1h)		;f021
	ld c,a			;f024
	ld a,(0ee18h)		;f025
	ld b,a			;f028
	dec a			;f029
	cp c			;f02a
	ld a,(leaceh)		;f02b
	jp nc,lf03ch		;f02e
	or 004h			;f031
	ld (lee19h+1),a		;f033
	ld a,c			;f036
	sub b			;f037
	ld c,a			;f038
	jp lf03fh		;f039
lf03ch:
	ld (lee19h+1),a		;f03c
lf03fh:
	ld b,000h		;f03f
	ld hl,(leac0h)		;f041
	add hl,bc		;f044
	ld a,(hl)		;f045
	ld (lee1eh),a		;f046
	ld a,(leacfh)		;f049
	ld (lee1dh),a		;f04c
	ld hl,leae3h		;f04f
	ld (lee19h+2),hl	;f052
	ld a,(leaceh)		;f055
	ld hl,lead2h		;f058
	cp (hl)			;f05b
	jp nz,lf067h		;f05c
	ld a,(leacfh)		;f05f
	ld hl,lead3h		;f062
	cp (hl)			;f065
	ret z			;f066
lf067h:
	ld a,(leaceh)		;f067
	ld (lead2h),a		;f06a
	ld a,(leacfh)		;f06d
	ld (lead3h),a		;f070
	call sub_f1fah		;f073
	call sub_f1c1h		;f076
	call READS		;f079
	ld a,(lee19h+1)		;f07c
	and 003h		;f07f
	add a,020h		;f081
	cp b			;f083
	ret z			;f084
sub_f085h:
	call sub_f1fah		;f085
	call sub_f175h		;f088
	push bc			;f08b
	call READS		;f08c
	call sub_f1c1h		;f08f
	call READS		;f092
	pop bc			;f095
	ret			;f096
lf097h:
	ld a,00ah		;f097
	ld (lee1fh),a		;f099
lf09ch:
	call sub_f116h		;f09c
	call sub_f1fah		;f09f
	ld hl,(workspace_end)	;f0a2
	ld c,(hl)		;f0a5
	inc hl			;f0a6
	ld b,(hl)		;f0a7
	inc hl			;f0a8
	call sub_f239h		;f0a9
	call sub_f101h		;f0ac
	call sub_f210h		;f0af
	ld c,000h		;f0b2
lf0b4h:
	ld hl,lee20h		;f0b4
	ld a,(hl)		;f0b7
	and 0f8h		;f0b8
	ret z			;f0ba
	and 008h		;f0bb
	jp nz,lf0d7h		;f0bd
	ld a,(lee1fh)		;f0c0
	dec a			;f0c3
	ld (lee1fh),a		;f0c4
	jp z,lf0d7h		;f0c7
	cp 005h			;f0ca
	call z,sub_f085h	;f0cc
	xor a			;f0cf
	cp c			;f0d0
	jp z,lf09ch		;f0d1
	jp lf0e6h		;f0d4
lf0d7h:
	ld a,c			;f0d7
	ld (lead5h),a		;f0d8
	ld a,001h		;f0db
	ld (leaddh),a		;f0dd
	ret			;f0e0
lf0e1h:
	ld a,00ah		;f0e1
	ld (lee1fh),a		;f0e3
lf0e6h:
	call sub_f116h		;f0e6
	call sub_f1fah		;f0e9
	ld hl,(workspace_end)	;f0ec
	ld c,(hl)		;f0ef
	inc hl			;f0f0
	ld b,(hl)		;f0f1
	inc hl			;f0f2
	call sub_f218h		;f0f3
	call sub_f106h		;f0f6
	call sub_f210h		;f0f9
	ld c,001h		;f0fc
	jp lf0b4h		;f0fe
sub_f101h:
	ld a,006h		;f101
	jp lf243h		;f103
sub_f106h:
	ld a,005h		;f106
	jp lf243h		;f108
sub_f10bh:
	ld hl,lea7bh		;f10b
	ld a,(0ee17h)		;f10e
	ld e,a			;f111
	ld d,000h		;f112
	add hl,de		;f114
	ret			;f115
sub_f116h:
	in a,(014h)		;f116
	and 080h		;f118
	ret z			;f11a
	di			;f11b
	ld hl,(TIMER2)		;f11c
	ld a,l			;f11f
	or h			;f120
	ld hl,(MOTORTIMER)	;f121
	ld (TIMER2),hl		;f124
	ei			;f127
	ret nz			;f128
	ld a,001h		;f129
	out (014h),a		;f12b
	ld hl,00032h		;f12d
	call sub_f13eh		;f130
	ret			;f133
sub_f134h:
	in a,(014h)		;f134
	and 080h		;f136
	ret z			;f138
	ld a,000h		;f139
	out (014h),a		;f13b
	ret			;f13d
sub_f13eh:
	ld (0ffe3h),hl		;f13e
lf141h:
	ld hl,(0ffe3h)		;f141
	ld a,l			;f144
	or h			;f145
	jp nz,lf141h		;f146
	ret			;f149
HOME:
	ld a,(leacah)		;f14a
	ld (lee19h+1),a		;f14d
	ld (lead2h),a		;f150
	xor a			;f153
	ld (lead3h),a		;f154
	call sub_f1fah		;f157
	call sub_f175h		;f15a
	call READS		;f15d
	ret			;f160
lf161h:
	in a,(004h)		;f161
	and 0c0h		;f163
	cp 080h			;f165
	jp nz,lf161h		;f167
	ret			;f16a
lf16bh:
	in a,(004h)		;f16b
	and 0c0h		;f16d
	cp 0c0h			;f16f
	jp nz,lf16bh		;f171
	ret			;f174
sub_f175h:
	call sub_f116h		;f175
	call lf161h		;f178
	ld a,007h		;f17b
	out (005h),a		;f17d
	call lf161h		;f17f
	ld a,(lee19h+1)		;f182
	and 003h		;f185
	out (005h),a		;f187
	ret			;f189
	call lf161h		;f18a
	ld a,004h		;f18d
	out (005h),a		;f18f
	call lf161h		;f191
	ld a,(lee19h+1)		;f194
	and 003h		;f197
	out (005h),a		;f199
	call lf16bh		;f19b
	in a,(005h)		;f19e
	ld (lee20h),a		;f1a0
	ret			;f1a3
sub_f1a4h:
	call lf161h		;f1a4
	ld a,008h		;f1a7
	out (005h),a		;f1a9
	call lf16bh		;f1ab
	in a,(005h)		;f1ae
	ld (lee20h),a		;f1b0
	and 0c0h		;f1b3
	cp 080h			;f1b5
	ret z			;f1b7
	call lf16bh		;f1b8
	in a,(005h)		;f1bb
	ld (lee21h),a		;f1bd
	ret			;f1c0
sub_f1c1h:
	call sub_f116h		;f1c1
	call lf161h		;f1c4
	ld a,00fh		;f1c7
	out (005h),a		;f1c9
	call lf161h		;f1cb
	ld a,(lee19h+1)		;f1ce
	and 003h		;f1d1
	out (005h),a		;f1d3
	call lf161h		;f1d5
	ld a,(lee1dh)		;f1d8
	out (005h),a		;f1db
	ret			;f1dd
sub_f1deh:
	ld hl,lee20h		;f1de
	ld d,007h		;f1e1
lf1e3h:
	call lf16bh		;f1e3
	in a,(005h)		;f1e6
	ld (hl),a		;f1e8
	inc hl			;f1e9
	ld a,004h		;f1ea
lf1ech:
	dec a			;f1ec
	jp nz,lf1ech		;f1ed
	in a,(004h)		;f1f0
	and 010h		;f1f2
	ret z			;f1f4
	dec d			;f1f5
	jp nz,lf1e3h		;f1f6
	ret			;f1f9
sub_f1fah:
	di			;f1fa
	xor a			;f1fb
	ld (lee28h),a		;f1fc
	ei			;f1ff
	ret			;f200
READS:
	call sub_f210h		;f201
	ld a,(lee20h)		;f204
	ld b,a			;f207
	ld a,(lee21h)		;f208
	ld c,a			;f20b
	call sub_f1fah		;f20c
	ret			;f20f
sub_f210h:
	ld a,(lee28h)		;f210
	or a			;f213
	jp z,sub_f210h		;f214
	ret			;f217
sub_f218h:
	ld a,005h		;f218
	di			;f21a
	out (0fah),a		;f21b
	ld a,049h		;f21d
lf21fh:
	out (0fbh),a		;f21f
	out (0fch),a		;f221
	ld a,(lee19h+2)		;f223
	out (0f2h),a		;f226
	ld a,(lee1ch)		;f228
	out (0f2h),a		;f22b
	ld a,c			;f22d
	out (0f3h),a		;f22e
	ld a,b			;f230
	out (0f3h),a		;f231
	ld a,001h		;f233
	out (0fah),a		;f235
	ei			;f237
	ret			;f238
sub_f239h:
	ld a,005h		;f239
	di			;f23b
	out (0fah),a		;f23c
	ld a,045h		;f23e
	jp lf21fh		;f240
lf243h:
	push af			;f243
	di			;f244
	call lf161h		;f245
	pop af			;f248
	ld b,(hl)		;f249
	inc hl			;f24a
	add a,b			;f24b
	out (005h),a		;f24c
	call lf161h		;f24e
	ld a,(lee19h+1)		;f251
	out (005h),a		;f254
	call lf161h		;f256
	ld a,(lee1dh)		;f259
	out (005h),a		;f25c
	call lf161h		;f25e
	ld a,(lee19h+1)		;f261
	rra			;f264
	rra			;f265
	and 003h		;f266
	out (005h),a		;f268
	call lf161h		;f26a
	ld a,(lee1eh)		;f26d
	out (005h),a		;f270
	call lf161h		;f272
	ld a,(hl)		;f275
	inc hl			;f276
	out (005h),a		;f277
	call lf161h		;f279
	ld a,(hl)		;f27c
	inc hl			;f27d
	out (005h),a		;f27e
	call lf161h		;f280
	ld a,(hl)		;f283
	out (005h),a		;f284
	call lf161h		;f286
	ld a,(leac2h)		;f289
	out (005h),a		;f28c
	ei			;f28e
	ret			;f28f
	ex af,af'		;f290
	exx			;f291
	ld hl,00000h		;f292
	add hl,sp		;f295
	ld sp,ISRSTACK		;f296
	push hl			;f299
	ld a,0ffh		;f29a
	ld (lee28h),a		;f29c
	ld a,005h		;f29f
lf2a1h:
	dec a			;f2a1
	jp nz,lf2a1h		;f2a2
	in a,(004h)		;f2a5
	and 010h		;f2a7
	jp nz,lf2b2h		;f2a9
	call sub_f1a4h		;f2ac
	jp lf2b5h		;f2af
lf2b2h:
	call sub_f1deh		;f2b2
lf2b5h:
	pop hl			;f2b5
	ld sp,hl		;f2b6
	exx			;f2b7
	ex af,af'		;f2b8
	ei			;f2b9
	reti			;f2ba
sub_f2bch:
	ei			;f2bc
	reti			;f2bd
code021_end:
WORKSPACE2:

; BLOCK 'workspace2' (start 0xf2bf end 0xf300)
workspace2_start:
	defb 000h		;f2bf
	defb 000h		;f2c0
	defb 000h		;f2c1
	defb 000h		;f2c2
	defb 000h		;f2c3
	defb 000h		;f2c4
	defb 000h		;f2c5
	defb 000h		;f2c6
	defb 000h		;f2c7
	defb 000h		;f2c8
	defb 000h		;f2c9
	defb 000h		;f2ca
	defb 000h		;f2cb
	defb 000h		;f2cc
	defb 000h		;f2cd
	defb 000h		;f2ce
	defb 000h		;f2cf
	defb 000h		;f2d0
	defb 000h		;f2d1
	defb 000h		;f2d2
	defb 000h		;f2d3
	defb 000h		;f2d4
	defb 000h		;f2d5
	defb 000h		;f2d6
	defb 000h		;f2d7
	defb 000h		;f2d8
	defb 000h		;f2d9
	defb 000h		;f2da
	defb 000h		;f2db
	defb 000h		;f2dc
	defb 000h		;f2dd
	defb 000h		;f2de
	defb 000h		;f2df
	defb 000h		;f2e0
	defb 000h		;f2e1
	defb 000h		;f2e2
	defb 000h		;f2e3
	defb 000h		;f2e4
	defb 000h		;f2e5
	defb 000h		;f2e6
	defb 000h		;f2e7
	defb 000h		;f2e8
	defb 000h		;f2e9
	defb 000h		;f2ea
	defb 000h		;f2eb
	defb 000h		;f2ec
	defb 000h		;f2ed
	defb 000h		;f2ee
	defb 000h		;f2ef
	defb 000h		;f2f0
	defb 000h		;f2f1
	defb 000h		;f2f2
	defb 000h		;f2f3
	defb 000h		;f2f4
	defb 000h		;f2f5
	defb 000h		;f2f6
	defb 000h		;f2f7
	defb 000h		;f2f8
	defb 000h		;f2f9
	defb 000h		;f2fa
	defb 000h		;f2fb
	defb 000h		;f2fc
	defb 000h		;f2fd
	defb 000h		;f2fe
	defb 000h		;f2ff
workspace2_end:

; BLOCK 'code023' (start 0xf300 end 0xf4bf)
code023_start:
	cp h			;f300
	jp p,le4b6h		;f301
	ret nz			;f304
	call po,sub_f2bch	;f305
	cp h			;f308
	jp p,sub_f2bch		;f309
	inc l			;f30c
	jp (hl)			;f30d
	sub b			;f30e
	jp p,le424h		;f30f
	ld (040e4h),a		;f312
	call po,sub_e44ah	;f315
	ld e,h			;f318
	call po,sub_e46ah	;f319
	ld a,b			;f31c
	call po,sub_e487h	;f31d
	nop			;f320
lf321h:
	di			;f321
	nop			;f322
	nop			;f323
	nop			;f324
	nop			;f325
	nop			;f326
	nop			;f327
	nop			;f328
	nop			;f329
	ld hl,(00016h)		;f32a
	nop			;f32d
	ld (bc),a		;f32e
	nop			;f32f
	ld bc,sub_f101h		;f330
	ret			;f333
	in a,(014h)		;f334
	and 080h		;f336
	ret z			;f338
	ld a,000h		;f339
	out (014h),a		;f33b
	ret			;f33d
	ld (0ffe3h),hl		;f33e
	ld hl,(0ffe3h)		;f341
	ld a,l			;f344
	or h			;f345
	jp nz,lf141h		;f346
	ret			;f349
	ld a,(leacah)		;f34a
	ld (lee19h+1),a		;f34d
	ld (lead2h),a		;f350
	xor a			;f353
	ld (lead3h),a		;f354
	call sub_f1fah		;f357
	call sub_f175h		;f35a
	call READS		;f35d
	ret			;f360
	in a,(004h)		;f361
	and 0c0h		;f363
	cp 080h			;f365
	jp nz,lf161h		;f367
	ret			;f36a
	in a,(004h)		;f36b
	and 0c0h		;f36d
	cp 0c0h			;f36f
	jp nz,lf16bh		;f371
	ret			;f374
	call sub_f116h		;f375
	call lf161h		;f378
	ld a,007h		;f37b
	out (005h),a		;f37d
	call lf161h		;f37f
	ld a,(lee19h+1)		;f382
	and 003h		;f385
	out (005h),a		;f387
	ret			;f389
	call lf161h		;f38a
	ld a,004h		;f38d
	out (005h),a		;f38f
	call lf161h		;f391
	ld a,(lee19h+1)		;f394
	and 003h		;f397
	out (005h),a		;f399
	call lf16bh		;f39b
	in a,(005h)		;f39e
	ld (lee20h),a		;f3a0
	ret			;f3a3
	call lf161h		;f3a4
	ld a,008h		;f3a7
	out (005h),a		;f3a9
	call lf16bh		;f3ab
	in a,(005h)		;f3ae
	ld (lee20h),a		;f3b0
	and 0c0h		;f3b3
	cp 080h			;f3b5
	ret z			;f3b7
	call lf16bh		;f3b8
	in a,(005h)		;f3bb
	ld (lee21h),a		;f3bd
	ret			;f3c0
	call sub_f116h		;f3c1
	call lf161h		;f3c4
	ld a,00fh		;f3c7
	out (005h),a		;f3c9
	call lf161h		;f3cb
	ld a,(lee19h+1)		;f3ce
	and 003h		;f3d1
	out (005h),a		;f3d3
	call lf161h		;f3d5
	ld a,(lee1dh)		;f3d8
	out (005h),a		;f3db
	ret			;f3dd
	ld hl,lee20h		;f3de
	ld d,007h		;f3e1
	call lf16bh		;f3e3
	in a,(005h)		;f3e6
	ld (hl),a		;f3e8
	inc hl			;f3e9
	ld a,004h		;f3ea
	dec a			;f3ec
	jp nz,lf1ech		;f3ed
	in a,(004h)		;f3f0
	and 010h		;f3f2
	ret z			;f3f4
	dec d			;f3f5
	jp nz,lf1e3h		;f3f6
	ret			;f3f9
	di			;f3fa
	xor a			;f3fb
	ld (lee28h),a		;f3fc
	ei			;f3ff
	ret			;f400
	call sub_f210h		;f401
	ld a,(lee20h)		;f404
	ld b,a			;f407
	ld a,(lee21h)		;f408
	ld c,a			;f40b
	call sub_f1fah		;f40c
	ret			;f40f
	ld a,(lee28h)		;f410
	or a			;f413
	jp z,sub_f210h		;f414
	ret			;f417
	ld a,005h		;f418
	di			;f41a
	out (0fah),a		;f41b
	ld a,049h		;f41d
	out (0fbh),a		;f41f
	out (0fch),a		;f421
	ld a,(lee19h+2)		;f423
	out (0f2h),a		;f426
	ld a,(lee1ch)		;f428
	out (0f2h),a		;f42b
	ld a,c			;f42d
	out (0f3h),a		;f42e
	ld a,b			;f430
	out (0f3h),a		;f431
	ld a,001h		;f433
	out (0fah),a		;f435
	ei			;f437
	ret			;f438
	ld a,005h		;f439
	di			;f43b
	out (0fah),a		;f43c
	ld a,045h		;f43e
	jp lf21fh		;f440
	push af			;f443
	di			;f444
	call lf161h		;f445
	pop af			;f448
	ld b,(hl)		;f449
	inc hl			;f44a
	add a,b			;f44b
	out (005h),a		;f44c
	call lf161h		;f44e
	ld a,(lee19h+1)		;f451
	out (005h),a		;f454
	call lf161h		;f456
	ld a,(lee1dh)		;f459
	out (005h),a		;f45c
	call lf161h		;f45e
	ld a,(lee19h+1)		;f461
	rra			;f464
	rra			;f465
	and 003h		;f466
	out (005h),a		;f468
	call lf161h		;f46a
	ld a,(lee1eh)		;f46d
	out (005h),a		;f470
	call lf161h		;f472
	ld a,(hl)		;f475
	inc hl			;f476
	out (005h),a		;f477
	call lf161h		;f479
	ld a,(hl)		;f47c
	inc hl			;f47d
	out (005h),a		;f47e
	call lf161h		;f480
	ld a,(hl)		;f483
	out (005h),a		;f484
	call lf161h		;f486
	ld a,(leac2h)		;f489
	out (005h),a		;f48c
	ei			;f48e
	ret			;f48f
	ex af,af'		;f490
	exx			;f491
	ld hl,00000h		;f492
	add hl,sp		;f495
	ld sp,ISRSTACK		;f496
	push hl			;f499
	ld a,0ffh		;f49a
	ld (lee28h),a		;f49c
	ld a,005h		;f49f
	dec a			;f4a1
	jp nz,lf2a1h		;f4a2
	in a,(004h)		;f4a5
	and 010h		;f4a7
	jp nz,lf2b2h		;f4a9
	call sub_f1a4h		;f4ac
	jp lf2b5h		;f4af
	call sub_f1deh		;f4b2
	pop hl			;f4b5
	ld sp,hl		;f4b6
	exx			;f4b7
	ex af,af'		;f4b8
	ei			;f4b9
	reti			;f4ba
	ei			;f4bc
	reti			;f4bd
code023_end:
TRAILING:

; BLOCK 'trailing' (start 0xf4bf end 0xf500)
trailing_start:
	defb 000h		;f4bf
	defb 000h		;f4c0
	defb 000h		;f4c1
	defb 000h		;f4c2
	defb 000h		;f4c3
	defb 000h		;f4c4
	defb 000h		;f4c5
	defb 000h		;f4c6
	defb 000h		;f4c7
	defb 000h		;f4c8
	defb 000h		;f4c9
	defb 000h		;f4ca
	defb 000h		;f4cb
	defb 000h		;f4cc
	defb 000h		;f4cd
	defb 000h		;f4ce
	defb 000h		;f4cf
	defb 000h		;f4d0
	defb 000h		;f4d1
	defb 000h		;f4d2
	defb 000h		;f4d3
	defb 000h		;f4d4
	defb 000h		;f4d5
	defb 000h		;f4d6
	defb 000h		;f4d7
	defb 000h		;f4d8
	defb 000h		;f4d9
	defb 000h		;f4da
	defb 000h		;f4db
	defb 000h		;f4dc
	defb 000h		;f4dd
	defb 000h		;f4de
	defb 000h		;f4df
	defb 000h		;f4e0
	defb 000h		;f4e1
	defb 000h		;f4e2
	defb 000h		;f4e3
	defb 000h		;f4e4
	defb 000h		;f4e5
	defb 000h		;f4e6
	defb 000h		;f4e7
	defb 000h		;f4e8
	defb 000h		;f4e9
	defb 000h		;f4ea
	defb 000h		;f4eb
	defb 000h		;f4ec
	defb 000h		;f4ed
	defb 000h		;f4ee
	defb 000h		;f4ef
	defb 000h		;f4f0
	defb 000h		;f4f1
	defb 000h		;f4f2
	defb 000h		;f4f3
	defb 000h		;f4f4
	defb 000h		;f4f5
	defb 000h		;f4f6
	defb 000h		;f4f7
	defb 000h		;f4f8
	defb 000h		;f4f9
	defb 000h		;f4fa
	defb 000h		;f4fb
	defb 000h		;f4fc
	defb 000h		;f4fd
	defb 000h		;f4fe
	defb 000h		;f4ff
trailing_end:
ATTRBUF:
