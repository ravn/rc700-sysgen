; z80dasm 1.2.0
; command line: z80dasm -a -l -g 0xD480 -S /Users/ravn/git/rc700-sysgen/rcbios/src-rc702e/rc702e_220.sym -b /Users/ravn/git/rc700-sysgen/rcbios/src-rc702e/rc702e_220.blk -o /Users/ravn/git/rc700-sysgen/rcbios/src-rc702e/rc702e_220_raw.asm extracted_bios/cpm22_56k_rc702e_rel2.20_rc703.bin

	org 0d480h
CONSTAT2:	equ 0xdac5
INTFN2:	equ 0xdae8
SIOWR2:	equ 0xdb0b
WBOOT:	equ 0xdb8d
LIST:	equ 0xdc62
PUNCH2:	equ 0xdc85
READER2:	equ 0xdc89
READER:	equ 0xdca2
PUNCH:	equ 0xdcc9
CONOUT:	equ 0xe071
SELDSK:	equ 0xe1a8
SETTRK:	equ 0xe280
SETSEC:	equ 0xe285
SECTRAN:	equ 0xe28f
READ:	equ 0xe292
SCRNEND:	equ 0xffcf
CURX:	equ 0xffd1
CURY:	equ 0xffd2
TIMER1:	equ 0xffdf
TIMER2:	equ 0xffe1
MOTORTIMER:	equ 0xffe7
RTCCNT:	equ 0xfffc

START:

; BLOCK 'code000' (start 0xd480 end 0xd7b3)
code000_start:
	di			;d480
ld481h:
	ld hl,START		;d481
	ld de,ld481h		;d484
	ld (hl),000h		;d487
	ld bc,02b80h		;d489
	ldir			;d48c
ld48eh:
	ld hl,00000h		;d48e
	ld de,START		;d491
	ld bc,01801h		;d494
	ldir			;d497
	ld hl,0d580h		;d499
	ld de,CONVTAB		;d49c
	ld bc,00180h		;d49f
	ldir			;d4a2
	ld hl,00000h		;d4a4
	ld de,00001h		;d4a7
	ld bc,00100h		;d4aa
	ld (hl),000h		;d4ad
	ldir			;d4af
	ld sp,00080h		;d4b1
	ld a,(lec25h)		;d4b4
	ld i,a			;d4b7
	im 2			;d4b9
	jp ld73eh		;d4bb
	ld a,020h		;d4be
	out (012h),a		;d4c0
	ld a,022h		;d4c2
	out (013h),a		;d4c4
	ld a,04fh		;d4c6
	out (012h),a		;d4c8
	ld a,00fh		;d4ca
	out (013h),a		;d4cc
	ld a,083h		;d4ce
	out (012h),a		;d4d0
	out (013h),a		;d4d2
	ld a,000h		;d4d4
	out (00ch),a		;d4d6
ld4d8h:
	ld a,(ld500h)		;d4d8
	out (00ch),a		;d4db
	ld a,(ld500h+1)		;d4dd
	out (00ch),a		;d4e0
	ld a,(ld500h+2)		;d4e2
	out (00dh),a		;d4e5
	ld a,(ld503h)		;d4e7
	out (00dh),a		;d4ea
	ld a,(ld503h+1)		;d4ec
	out (00eh),a		;d4ef
	ld a,(ld505h)		;d4f1
	out (00eh),a		;d4f4
	ld a,(ld505h+1)		;d4f6
	out (00fh),a		;d4f9
	ld a,(ld507h)		;d4fb
	out (00fh),a		;d4fe
ld500h:
	ld hl,ld507h+1		;d500
ld503h:
	ld b,009h		;d503
ld505h:
	ld c,00ah		;d505
ld507h:
	otir			;d507
	ld hl,0d511h		;d509
	ld b,00bh		;d50c
ld50eh:
	ld c,00bh		;d50e
	otir			;d510
	in a,(00ah)		;d512
	ld (lf4cfh),a		;d514
	ld a,001h		;d517
ld519h:
	out (00ah),a		;d519
	in a,(00ah)		;d51b
	ld (lf4d0h),a		;d51d
ld520h:
	in a,(00bh)		;d520
ld522h:
	ld (lf4d1h),a		;d522
	ld a,001h		;d525
	out (00bh),a		;d527
	in a,(00bh)		;d529
	ld (lf4d2h),a		;d52b
	ld a,010h		;d52e
	out (0f8h),a		;d530
	ld hl,0d51ch		;d532
	ld b,004h		;d535
ld537h:
	ld c,0fbh		;d537
	otir			;d539
	in a,(014h)		;d53b
	and 080h		;d53d
	jr z,ld550h		;d53f
	ld hl,0d52fh		;d541
	ld a,(hl)		;d544
	cp 018h			;d545
	jr nz,ld550h		;d547
	ld (hl),010h		;d549
	ld a,041h		;d54b
	ld (ld537h),a		;d54d
ld550h:
	in a,(004h)		;d550
	and 01fh		;d552
	jr nz,ld550h		;d554
	ld hl,ld522h+2		;d556
	ld b,(hl)		;d559
ld55ah:
	inc hl			;d55a
ld55bh:
	in a,(004h)		;d55b
	and 0c0h		;d55d
	cp 080h			;d55f
	jr nz,ld55bh		;d561
	ld a,(hl)		;d563
	out (005h),a		;d564
	dec b			;d566
	jr nz,ld55ah		;d567
	ld hl,SCREENBUF		;d569
	ld de,lf801h		;d56c
	ld bc,007cfh		;d56f
	ld (hl),020h		;d572
	ldir			;d574
	ld a,000h		;d576
	out (001h),a		;d578
	ld a,(ld520h)		;d57a
	out (000h),a		;d57d
	ld a,(ld520h+1)		;d57f
	out (000h),a		;d582
	ld a,(ld522h)		;d584
	out (000h),a		;d587
	ld a,(ld522h+1)		;d589
	out (000h),a		;d58c
	ld a,080h		;d58e
	out (001h),a		;d590
	ld a,000h		;d592
	out (000h),a		;d594
	out (000h),a		;d596
	ld a,0e0h		;d598
	out (001h),a		;d59a
	ld a,023h		;d59c
	out (001h),a		;d59e
	ld a,(ld50eh)		;d5a0
	and 060h		;d5a3
	ld (lda33h+1),a		;d5a5
	ld a,(ld519h)		;d5a8
	and 060h		;d5ab
	ld (lda35h),a		;d5ad
	ld a,(0d52ch)		;d5b0
	ld (lda33h),a		;d5b3
	ld hl,(0d52dh)		;d5b6
	ld (MOTORTIMER),hl	;d5b9
	ld hl,(0d542h)		;d5bc
	ld (0da60h),hl		;d5bf
	ld a,0ffh		;d5c2
	ld (lf4c9h),a		;d5c4
	ld (SIOFLG2),a		;d5c7
	ld (lf4b4h),a		;d5ca
	ld hl,0d4cbh		;d5cd
	ld de,lf4d8h		;d5d0
	ld bc,0000fh		;d5d3
	ldir			;d5d6
	ld hl,0d52fh		;d5d8
	ld de,0da37h		;d5db
	ld bc,00011h		;d5de
	ldir			;d5e1
	ei			;d5e3
	ld hl,0d4b8h		;d5e4
	call 0daach		;d5e7
	ld iy,lf4a4h		;d5ea
	ld ix,lda3ah		;d5ee
	ld (iy+000h),003h	;d5f2
	call sub_e5efh		;d5f6
ld5f9h:
	call sub_d88eh		;d5f9
	call nz,sub_d88eh	;d5fc
	jr z,ld605h		;d5ff
	ld (ix+000h),0ffh	;d601
ld605h:
	dec ix			;d605
	dec (iy+000h)		;d607
	jr nz,ld5f9h		;d60a
	jr ld61ah		;d60c
	call sub_e565h		;d60e
	call RAMDISK		;d611
	ld a,b			;d614
	and 060h		;d615
	cp 020h			;d617
	ret			;d619
ld61ah:
	ld hl,(0d52dh)		;d61a
	ld (TIMER2),hl		;d61d
	in a,(0f8h)		;d620
	ld a,004h		;d622
	di			;d624
	out (0fah),a		;d625
	ld a,044h		;d627
	out (0fbh),a		;d629
	out (0fch),a		;d62b
	ld a,001h		;d62d
	out (0f1h),a		;d62f
	dec a			;d631
	out (0f1h),a		;d632
	out (0f0h),a		;d634
	inc a			;d636
	out (0f0h),a		;d637
	xor a			;d639
	out (0f1h),a		;d63a
	out (0fah),a		;d63c
	ei			;d63e
	out (0eeh),a		;d63f
	ld a,080h		;d641
	out (0efh),a		;d643
	ld b,a			;d645
ld646h:
	djnz ld646h		;d646
	in a,(0f8h)		;d648
	and 001h		;d64a
	jr nz,ld667h		;d64c
	ld a,004h		;d64e
	out (0f9h),a		;d650
	ld hl,00000h		;d652
	ld (lda46h),hl		;d655
	ld hl,ld48eh+1		;d658
	call 0daach		;d65b
	ld hl,0d49ah		;d65e
	call 0daach		;d661
	jp 0d960h		;d664
ld667h:
	ld de,00008h		;d667
	in a,(0eeh)		;d66a
	and 0fch		;d66c
	jr nz,ld677h		;d66e
	xor a			;d670
	ld (lda46h),a		;d671
	jp 0d960h		;d674
ld677h:
	ld b,a			;d677
	cp 020h			;d678
	jr c,ld68eh		;d67a
	ld hl,le77ah		;d67c
	ld (hl),000h		;d67f
	cp 04dh			;d681
	jr c,ld68eh		;d683
	ld (hl),001h		;d685
	dec hl			;d687
	ld (hl),01fh		;d688
	dec hl			;d68a
	inc (hl)		;d68b
	sra e			;d68c
ld68eh:
	ld l,d			;d68e
	ld h,000h		;d68f
ld691h:
	add hl,de		;d691
	djnz ld691h		;d692
	dec hl			;d694
	ld (le77bh),hl		;d695
	ld hl,ld48eh+1		;d698
	call 0daach		;d69b
	ld hl,0d4b0h		;d69e
	call 0daach		;d6a1
	ld a,050h		;d6a4
	ld (lda3ah+1),a		;d6a6
	xor a			;d6a9
	ld (lf48ah),a		;d6aa
	call sub_e6a6h		;d6ad
	jr z,ld6e0h		;d6b0
	ld hl,00100h		;d6b2
	ld de,00101h		;d6b5
	ld bc,04000h		;d6b8
	ld (hl),0e5h		;d6bb
	ldir			;d6bd
	xor a			;d6bf
	ld iy,lf488h		;d6c0
ld6c4h:
	di			;d6c4
	ld a,004h		;d6c5
	out (0fah),a		;d6c7
	ld a,048h		;d6c9
	ld hl,00100h		;d6cb
	ld bc,03fffh		;d6ce
	call sub_e6b4h		;d6d1
	in a,(0eeh)		;d6d4
	and 0fch		;d6d6
	inc (iy+000h)		;d6d8
	cp (iy+000h)		;d6db
	jr nz,ld6c4h		;d6de
ld6e0h:
	ld hl,le93fh		;d6e0
	ld de,01000h		;d6e3
	ld bc,000b9h		;d6e6
	ldir			;d6e9
	call 01000h		;d6eb
	call CONST		;d6ee
	or a			;d6f1
	jr z,ld710h		;d6f2
	call CONIN		;d6f4
	and 05fh		;d6f7
	sub 041h		;d6f9
	cp 005h			;d6fb
	jr nc,ld710h		;d6fd
	ld c,a			;d6ff
	ld hl,0da37h		;d700
	add a,l			;d703
	ld l,a			;d704
	ld a,(hl)		;d705
	inc a			;d706
	jr z,ld710h		;d707
	ld a,c			;d709
	ld (lda47h),a		;d70a
	ld (lda46h),a		;d70d
ld710h:
	ld a,(lda46h)		;d710
	add a,041h		;d713
	ld (0d4eeh),a		;d715
	ld hl,0d4dch		;d718
	call 0daach		;d71b
	ld hl,0da88h		;d71e
	call 0daach		;d721
	ld hl,ld4d8h		;d724
	call 0daach		;d727
	ld a,00ch		;d72a
	ld (0da88h),a		;d72c
	jp ldb7ah		;d72f
	nop			;d732
	nop			;d733
	nop			;d734
	nop			;d735
	nop			;d736
	nop			;d737
	nop			;d738
	nop			;d739
	nop			;d73a
	nop			;d73b
	nop			;d73c
	nop			;d73d
ld73eh:
	nop			;d73e
	nop			;d73f
	nop			;d740
	nop			;d741
	nop			;d742
	nop			;d743
	nop			;d744
	nop			;d745
	nop			;d746
	nop			;d747
	nop			;d748
	nop			;d749
	nop			;d74a
	nop			;d74b
	nop			;d74c
	nop			;d74d
	nop			;d74e
	nop			;d74f
	nop			;d750
	nop			;d751
	nop			;d752
	nop			;d753
	nop			;d754
	nop			;d755
	nop			;d756
	nop			;d757
	nop			;d758
	nop			;d759
	nop			;d75a
	nop			;d75b
	nop			;d75c
	nop			;d75d
	nop			;d75e
	nop			;d75f
	nop			;d760
	nop			;d761
	nop			;d762
	nop			;d763
	nop			;d764
	nop			;d765
	nop			;d766
	nop			;d767
	nop			;d768
	nop			;d769
	nop			;d76a
	nop			;d76b
	nop			;d76c
	nop			;d76d
	nop			;d76e
	nop			;d76f
	nop			;d770
	nop			;d771
	nop			;d772
	nop			;d773
	nop			;d774
	nop			;d775
	nop			;d776
	nop			;d777
	nop			;d778
	nop			;d779
	nop			;d77a
	nop			;d77b
	nop			;d77c
	nop			;d77d
	nop			;d77e
	nop			;d77f
JMPTAB:
	jp BOOT			;d780
	jp WBOOT		;d783
	jp CONST		;d786
	jp CONIN		;d789
	jp CONOUT		;d78c
	jp LIST			;d78f
	jp PUNCH		;d792
	jp READER		;d795
	jp HOME			;d798
	jp SELDSK		;d79b
	jp SETTRK		;d79e
	jp SETSEC		;d7a1
	jp SETDMA		;d7a4
	jp READ			;d7a7
	jp WRITE		;d7aa
	jp LISTST		;d7ad
	jp SECTRAN		;d7b0
code000_end:
JTVARS:

; BLOCK 'jtvars' (start 0xd7b3 end 0xd7ca)
jtvars_start:
	defb 000h		;d7b3
	defb 000h		;d7b4
	defb 000h		;d7b5
	defb 000h		;d7b6
	defb 0ffh		;d7b7
	defb 0ffh		;d7b8
	defb 0ffh		;d7b9
	defb 0ffh		;d7ba
	defb 0ffh		;d7bb
	defb 0ffh		;d7bc
	defb 0ffh		;d7bd
	defb 0ffh		;d7be
	defb 0ffh		;d7bf
	defb 0ffh		;d7c0
	defb 0ffh		;d7c1
	defb 0ffh		;d7c2
	defb 0ffh		;d7c3
	defb 000h		;d7c4
	defb 000h		;d7c5
	defb 000h		;d7c6
	defb 000h		;d7c7
	defb 0aah		;d7c8
	defb 0f4h		;d7c9
jtvars_end:
INTJP0:

; BLOCK 'code002' (start 0xd7ca end 0xd7df)
code002_start:
	jp RAMDISK		;d7ca
INTJP1:
	jp CONOUT_INT		;d7cd
INTJP2:
	jp LINSEL		;d7d0
INTJP3:
	jp CONSTAT2		;d7d3
INTJP4:
	jp INTFN1		;d7d6
INTJP5:
	jp WBOOT		;d7d9
INTJP6:
	jp WBOOT		;d7dc
code002_end:
JTGAP1:

; BLOCK 'jtgap1' (start 0xd7df end 0xd7e2)
jtgap1_start:
	defb 000h		;d7df
	defb 000h		;d7e0
	defb 000h		;d7e1
jtgap1_end:
INTJP7:

; BLOCK 'code004' (start 0xd7e2 end 0xd7ee)
code004_start:
	jp INTFN2		;d7e2
INTJP8:
	jp SIOWR2		;d7e5
INTJP9:
	jp READER2		;d7e8
INTJP10:
	jp PUNCH2		;d7eb
code004_end:
JTGAP2:

; BLOCK 'jtgap2' (start 0xd7ee end 0xd7f3)
jtgap2_start:
	defb 000h		;d7ee
	defb 000h		;d7ef
	defb 000h		;d7f0
	defb 020h		;d7f1
	defb 002h		;d7f2
jtgap2_end:
ERRMSG:

; BLOCK 'errmsg' (start 0xd7f3 end 0xd807)
errmsg_start:
	defb 00dh		;d7f3
	defb 00ah		;d7f4
	defb 044h		;d7f5
	defb 069h		;d7f6
	defb 073h		;d7f7
	defb 06bh		;d7f8
	defb 020h		;d7f9
	defb 065h		;d7fa
	defb 072h		;d7fb
	defb 072h		;d7fc
	defb 06fh		;d7fd
	defb 072h		;d7fe
	defb 020h		;d7ff
	defb 02dh		;d800
	defb 020h		;d801
	defb 072h		;d802
	defb 065h		;d803
	defb 073h		;d804
	defb 065h		;d805
	defb 074h		;d806
errmsg_end:
SIGNON:

; BLOCK 'signon' (start 0xd807 end 0xd82b)
signon_start:
	defb 000h		;d807
	defb 01dh		;d808
	defb 052h		;d809
	defb 043h		;d80a
	defb 037h		;d80b
	defb 030h		;d80c
	defb 032h		;d80d
	defb 045h		;d80e
	defb 020h		;d80f
	defb 035h		;d810
	defb 036h		;d811
	defb 06bh		;d812
	defb 020h		;d813
	defb 043h		;d814
	defb 050h		;d815
	defb 02fh		;d816
	defb 04dh		;d817
	defb 020h		;d818
	defb 056h		;d819
	defb 065h		;d81a
	defb 072h		;d81b
	defb 020h		;d81c
	defb 032h		;d81d
	defb 02eh		;d81e
	defb 032h		;d81f
	defb 020h		;d820
	defb 052h		;d821
	defb 065h		;d822
	defb 06ch		;d823
	defb 020h		;d824
	defb 032h		;d825
	defb 02eh		;d826
	defb 032h		;d827
	defb 030h		;d828
	defb 00dh		;d829
	defb 00ah		;d82a
signon_end:
PRTMSG:

; BLOCK 'code008' (start 0xd82b end 0xe460)
code008_start:
	nop			;d82b
ld82ch:
	ld a,(hl)		;d82c
	or a			;d82d
	ret z			;d82e
	push hl			;d82f
	ld c,a			;d830
	call CONOUT		;d831
	pop hl			;d834
	inc hl			;d835
	jr ld82ch		;d836
	ld hl,lda73h		;d838
	call 0daach		;d83b
	ld hl,0ffe3h		;d83e
	out (01ch),a		;d841
ld843h:
	jr ld843h		;d843
	ld a,0c3h		;d845
	ld (0ffebh),a		;d847
	ld (0ffech),hl		;d84a
	ex de,hl		;d84d
	ld (TIMER1),hl		;d84e
	ret			;d851
	di			;d852
	or a			;d853
	jr z,ld85fh		;d854
SETWARM:
	ld de,(RTCCNT)		;d856
	ld hl,(0fffeh)		;d85a
	ei			;d85d
	ret			;d85e
ld85fh:
	ld (RTCCNT),de		;d85f
	ld (0fffeh),hl		;d863
	ei			;d866
	ret			;d867
	di			;d868
CLOCK_FN:
	or a			;d869
	jr z,ld879h		;d86a
	ld bc,(lf4dch)		;d86c
	ld de,(lf4dfh)		;d870
	ld hl,(lf4e2h)		;d874
	ei			;d877
	ret			;d878
ld879h:
	ld (lf4dch),bc		;d879
	ld (lf4dfh),de		;d87d
	ld (lf4e2h),hl		;d881
	ld a,032h		;d884
	ld (lf4e6h),a		;d886
	ei			;d889
	xor a			;d88a
	ld (lf4e5h),a		;d88b
sub_d88eh:
	ret			;d88e
	add a,00ah		;d88f
	ld c,a			;d891
ld892h:
	di			;d892
	ld a,001h		;d893
	out (c),a		;d895
	in a,(c)		;d897
	ei			;d899
ld89ah:
	and 001h		;d89a
	jr z,ld892h		;d89c
	ld hl,00002h		;d89e
	call sub_e519h		;d8a1
	ld d,005h		;d8a4
	ld a,000h		;d8a6
	call sub_db50h		;d8a8
	dec b			;d8ab
	ret m			;d8ac
	sla b			;d8ad
	or b			;d8af
	call sub_db50h		;d8b0
	or 080h			;d8b3
	call sub_db50h		;d8b5
	ld hl,00002h		;d8b8
	call sub_e519h		;d8bb
	ld a,c			;d8be
	cp 00ah			;d8bf
	ld a,(lf4cfh)		;d8c1
	jr z,ld8c9h		;d8c4
	ld a,(lf4d1h)		;d8c6
ld8c9h:
	and 020h		;d8c9
	jr z,ld8d0h		;d8cb
	ld a,0ffh		;d8cd
	ret			;d8cf
ld8d0h:
	di			;d8d0
	out (c),d		;d8d1
	out (c),a		;d8d3
	ei			;d8d5
	ret			;d8d6
	xor a			;d8d7
	ld (0d84ch),a		;d8d8
	ld hl,(ld89ah)		;d8db
	ld (lda44h),hl		;d8de
	ld hl,ldb68h		;d8e1
	ld (ld89ah),hl		;d8e4
	ret			;d8e7
	push hl			;d8e8
	ld hl,(lda44h)		;d8e9
	ld (ld89ah),hl		;d8ec
	pop hl			;d8ef
	ret			;d8f0
	ld sp,00080h		;d8f1
	ld hl,0da88h		;d8f4
	call 0daach		;d8f7
	ld a,(lda46h)		;d8fa
	ld (00004h),a		;d8fd
	xor a			;d900
	ld (lf4b5h),a		;d901
	ld (lf491h),a		;d904
	ld (RAMDSTAT),a		;d907
	ld (lf492h),a		;d90a
	ei			;d90d
	xor a			;d90e
	ld (lf493h),a		;d90f
	ld (00003h),a		;d912
	ld (lec26h),a		;d915
	ld (lf4a4h),a		;d918
	ld sp,00080h		;d91b
	ld a,(lda47h)		;d91e
	cp 004h			;d921
	jr c,ld940h		;d923
	ld hl,0c400h		;d925
	ld bc,015ffh		;d928
	xor a			;d92b
	ld (lf488h),a		;d92c
	ld a,088h		;d92f
	ld (lf48ah),a		;d931
	di			;d934
	ld a,004h		;d935
	out (0fah),a		;d937
	ld a,044h		;d939
	call sub_e6b4h		;d93b
	jr ld977h		;d93e
ld940h:
	and 003h		;d940
	ld c,a			;d942
	call SELDSK		;d943
	call HOME		;d946
	ld bc,0c400h		;d949
	call SETDMA		;d94c
	ld bc,00001h		;d94f
	call SETTRK		;d952
	dec bc			;d955
	call SETSEC		;d956
ld959h:
	push bc			;d959
	call READ		;d95a
	or a			;d95d
	jp nz,ldab8h		;d95e
	ld hl,(lf49eh)		;d961
	ld de,00080h		;d964
	add hl,de		;d967
	ld b,h			;d968
	ld c,l			;d969
	call SETDMA		;d96a
	pop bc			;d96d
	inc bc			;d96e
	call SETSEC		;d96f
	ld a,c			;d972
	cp 02ch			;d973
	jr nz,ld959h		;d975
ld977h:
	ld bc,00080h		;d977
	call SETDMA		;d97a
	ld a,0c3h		;d97d
	ld (00000h),a		;d97f
	ld hl,lda03h		;d982
	ld (00001h),hl		;d985
	ld (00005h),a		;d988
	ld hl,0cc06h		;d98b
	ld (00006h),hl		;d98e
	ld a,(00004h)		;d991
	and 00fh		;d994
	ld c,a			;d996
	ld a,(lda47h)		;d997
	cp c			;d99a
	jr z,ld9b9h		;d99b
	call SELDSK		;d99d
	ld a,h			;d9a0
	or l			;d9a1
	jr z,ld9b3h		;d9a2
	ld bc,00002h		;d9a4
	call SETTRK		;d9a7
	call SETSEC		;d9aa
	call READ		;d9ad
	or a			;d9b0
	jr z,ld9b9h		;d9b1
ld9b3h:
	ld a,(lda47h)		;d9b3
	ld (00004h),a		;d9b6
ld9b9h:
	ld a,(00004h)		;d9b9
	ld c,a			;d9bc
	and 00fh		;d9bd
	call nz,0db57h		;d9bf
	ld hl,lf4b5h		;d9c2
	ld a,(hl)		;d9c5
	ld (hl),001h		;d9c6
	or a			;d9c8
	jr z,ld9dbh		;d9c9
	ld a,(0c407h)		;d9cb
	or a			;d9ce
	jr z,ld9dbh		;d9cf
	ld hl,0c409h		;d9d1
	add a,l			;d9d4
	ld l,a			;d9d5
	ld a,(hl)		;d9d6
	or a			;d9d7
	jp z,0c403h		;d9d8
ld9dbh:
	jp 0c400h		;d9db
	ld a,(lf4c9h)		;d9de
	ret			;d9e1
ld9e2h:
	ld a,(lf4c9h)		;d9e2
	or a			;d9e5
	jr z,ld9e2h		;d9e6
	di			;d9e8
	xor a			;d9e9
	ld (lf4c9h),a		;d9ea
	ld a,005h		;d9ed
	out (00bh),a		;d9ef
	ld a,(lda35h)		;d9f1
	add a,08ah		;d9f4
	out (00bh),a		;d9f6
	ld a,001h		;d9f8
	out (00bh),a		;d9fa
	ld a,01fh		;d9fc
	out (00bh),a		;d9fe
	ld a,c			;da00
	out (009h),a		;da01
lda03h:
	ei			;da03
	ret			;da04
	ld a,(lf4cbh)		;da05
	ret			;da08
lda09h:
	ld a,(lf4cbh)		;da09
	or a			;da0c
	jr z,lda09h		;da0d
	ld a,(lf4ceh)		;da0f
	push af			;da12
	xor a			;da13
	ld (lf4cbh),a		;da14
	ld a,(lda35h)		;da17
	ld c,00bh		;da1a
	jr lda35h		;da1c
	ld a,(SIOFLG)		;da1e
	ret			;da21
lda22h:
	ld a,(SIOFLG)		;da22
	or a			;da25
	jr z,lda22h		;da26
	ld a,(lf4cdh)		;da28
	push af			;da2b
	xor a			;da2c
	ld (SIOFLG),a		;da2d
	ld a,(lda33h+1)		;da30
lda33h:
	ld c,00ah		;da33
lda35h:
	di			;da35
	ld b,005h		;da36
	out (c),b		;da38
lda3ah:
	add a,08ah		;da3a
	out (c),a		;da3c
	ld a,001h		;da3e
	out (c),a		;da40
	ld a,01fh		;da42
lda44h:
	out (c),a		;da44
lda46h:
	ei			;da46
lda47h:
	pop af			;da47
	ret			;da48
lda49h:
	ld a,(SIOFLG2)		;da49
	or a			;da4c
	jr z,lda49h		;da4d
	di			;da4f
	xor a			;da50
	ld (SIOFLG2),a		;da51
	ld a,005h		;da54
	out (00ah),a		;da56
	ld a,(lda33h+1)		;da58
	add a,08ah		;da5b
	out (00ah),a		;da5d
	ld a,001h		;da5f
	out (00ah),a		;da61
	ld a,01fh		;da63
	out (00ah),a		;da65
	ld a,c			;da67
	out (008h),a		;da68
	ei			;da6a
	ret			;da6b
	ld (lf4b2h),sp		;da6c
	ld sp,lf51eh		;da70
lda73h:
	push af			;da73
	ld a,028h		;da74
	out (00bh),a		;da76
	ld a,0ffh		;da78
	ld (lf4c9h),a		;da7a
	pop af			;da7d
	ld sp,(lf4b2h)		;da7e
	ei			;da82
	reti			;da83
	ld (lf4b2h),sp		;da85
	ld sp,lf51eh		;da89
	push af			;da8c
	in a,(00bh)		;da8d
	ld (lf4d1h),a		;da8f
	ld a,010h		;da92
	out (00bh),a		;da94
	pop af			;da96
	ld sp,(lf4b2h)		;da97
	ei			;da9b
	reti			;da9c
	ld (lf4b2h),sp		;da9e
	ld sp,lf51eh		;daa2
	push af			;daa5
	in a,(009h)		;daa6
	ld (lf4ceh),a		;daa8
	ld a,0ffh		;daab
	ld (lf4cbh),a		;daad
	pop af			;dab0
	ld sp,(lf4b2h)		;dab1
	ei			;dab5
	reti			;dab6
ldab8h:
	ld (lf4b2h),sp		;dab8
	ld sp,lf51eh		;dabc
	push af			;dabf
	ld a,001h		;dac0
	out (00bh),a		;dac2
	in a,(00bh)		;dac4
	ld (lf4d2h),a		;dac6
	ld a,030h		;dac9
	out (00bh),a		;dacb
	xor a			;dacd
	ld (lf4ceh),a		;dace
	cpl			;dad1
INTFN1:
	ld (lf4cbh),a		;dad2
	pop af			;dad5
	ld sp,(lf4b2h)		;dad6
	ei			;dada
	reti			;dadb
	ld (lf4b2h),sp		;dadd
	ld sp,lf51eh		;dae1
	push af			;dae4
	ld a,028h		;dae5
	out (00ah),a		;dae7
	ld a,0ffh		;dae9
	ld (SIOFLG2),a		;daeb
	pop af			;daee
	ld sp,(lf4b2h)		;daef
	ei			;daf3
	reti			;daf4
	ld (lf4b2h),sp		;daf6
	ld sp,lf51eh		;dafa
	push af			;dafd
	in a,(00ah)		;dafe
	ld (lf4cfh),a		;db00
	ld a,010h		;db03
	out (00ah),a		;db05
	pop af			;db07
	ld sp,(lf4b2h)		;db08
	ei			;db0c
	reti			;db0d
LINSEL:
	ld (lf4b2h),sp		;db0f
	ld sp,lf51eh		;db13
	push af			;db16
	in a,(008h)		;db17
	ld (lf4cdh),a		;db19
	ld a,0ffh		;db1c
	ld (SIOFLG),a		;db1e
	pop af			;db21
	ld sp,(lf4b2h)		;db22
	ei			;db26
	reti			;db27
	ld (lf4b2h),sp		;db29
	ld sp,lf51eh		;db2d
	push af			;db30
	ld a,001h		;db31
	out (00ah),a		;db33
	in a,(00ah)		;db35
	ld (lf4d0h),a		;db37
	ld a,030h		;db3a
	out (00ah),a		;db3c
	xor a			;db3e
	ld (lf4cdh),a		;db3f
	cpl			;db42
	ld (SIOFLG),a		;db43
	pop af			;db46
	ld sp,(lf4b2h)		;db47
	ei			;db4b
	reti			;db4c
	ld a,h			;db4e
	cpl			;db4f
sub_db50h:
	ld h,a			;db50
	ld a,l			;db51
	cpl			;db52
	ld l,a			;db53
	ret			;db54
	call sub_ddceh		;db55
	inc hl			;db58
	ret			;db59
	ld hl,(CURY)		;db5a
	ld a,l			;db5d
	cp 080h			;db5e
	ret nz			;db60
	ld a,h			;db61
	cp 007h			;db62
	ret			;db64
	ld a,(lf4d3h)		;db65
ldb68h:
	or a			;db68
	ld a,c			;db69
	ret nz			;db6a
	ld b,000h		;db6b
	add hl,bc		;db6d
	ld a,(hl)		;db6e
	ret			;db6f
ldb70h:
	push af			;db70
BOOT:
	ld a,080h		;db71
	out (001h),a		;db73
	ld a,(CURX)		;db75
	out (000h),a		;db78
ldb7ah:
	ld a,(0ffd4h)		;db7a
	out (000h),a		;db7d
	pop af			;db7f
	ret			;db80
	ld hl,(CURY)		;db81
	ld de,00050h		;db84
	add hl,de		;db87
	ld (CURY),hl		;db88
	ld hl,0ffd4h		;db8b
	inc (hl)		;db8e
	jr ldb70h		;db8f
	ld hl,(CURY)		;db91
	ld de,0ffb0h		;db94
	add hl,de		;db97
	ld (CURY),hl		;db98
	ld hl,0ffd4h		;db9b
	dec (hl)		;db9e
	jr ldb70h		;db9f
	ld hl,00000h		;dba1
	ld (CURY),hl		;dba4
	xor a			;dba7
	ld (CURX),a		;dba8
	ld (0ffd4h),a		;dbab
	ret			;dbae
ldbafh:
	cp b			;dbaf
	ret c			;dbb0
	sub b			;dbb1
	jr ldbafh		;dbb2
ldbb4h:
	ld hl,(0ffd5h)		;dbb4
	ld d,h			;dbb7
	ld e,l			;dbb8
	inc de			;dbb9
	ld bc,0004fh		;dbba
	ld (hl),020h		;dbbd
	ldir			;dbbf
	ret			;dbc1
	ld hl,lf850h		;dbc2
	ld de,SCREENBUF		;dbc5
	ld bc,00780h		;dbc8
	ldir			;dbcb
	ld hl,0ff80h		;dbcd
	ld (0ffd5h),hl		;dbd0
	jr ldbb4h		;dbd3
	ld a,b			;dbd5
	or c			;dbd6
	ret z			;dbd7
	ldir			;dbd8
	ret			;dbda
	ld a,b			;dbdb
	or c			;dbdc
	ret z			;dbdd
	lddr			;dbde
	ret			;dbe0
	out (01ch),a		;dbe1
	ret			;dbe3
	call 0de21h		;dbe4
	ld a,002h		;dbe7
	ld (0ffd7h),a		;dbe9
	ret			;dbec
	ret			;dbed
	ld a,000h		;dbee
	ld (CURX),a		;dbf0
	jp lddf0h		;dbf3
	ld hl,SCREENBUF		;dbf6
	ld de,lf801h		;dbf9
	ld bc,0004fh		;dbfc
	ld (hl),020h		;dbff
	ldir			;dc01
	inc hl			;dc03
	inc de			;dc04
	ld bc,0077fh		;dc05
	ld (hl),020h		;dc08
	ldir			;dc0a
	ld a,020h		;dc0c
	ld (lf4d6h),a		;dc0e
	call 0de21h		;dc11
	jp lddf0h		;dc14
	ld de,SCREENBUF		;dc17
	ld hl,(CURY)		;dc1a
	add hl,de		;dc1d
	ld de,0004fh		;dc1e
	add hl,de		;dc21
	ld d,h			;dc22
	ld e,l			;dc23
	dec de			;dc24
	ld bc,00000h		;dc25
	ld a,(CURX)		;dc28
	cpl			;dc2b
	inc a			;dc2c
	add a,04fh		;dc2d
	ld c,a			;dc2f
	ld (hl),020h		;dc30
	jp 0de5bh		;dc32
	ld hl,(CURY)		;dc35
	ld a,(CURX)		;dc38
	ld c,a			;dc3b
	ld b,000h		;dc3c
	add hl,bc		;dc3e
	call lddd4h+1		;dc3f
	ld de,007cfh		;dc42
	add hl,de		;dc45
	ld b,h			;dc46
	ld c,l			;dc47
	ld hl,SCRNEND		;dc48
	ld de,0ffceh		;dc4b
	ld (hl),020h		;dc4e
	jp 0de5bh		;dc50
	ld a,(CURX)		;dc53
	cp 000h			;dc56
	jr z,ldc61h		;dc58
	dec a			;dc5a
	ld (CURX),a		;dc5b
LISTST:
	jp lddf0h		;dc5e
ldc61h:
	ld a,04fh		;dc61
	ld (CURX),a		;dc63
	ld hl,(CURY)		;dc66
	ld a,l			;dc69
	or h			;dc6a
	jp nz,lde11h		;dc6b
	ld hl,00780h		;dc6e
	ld (CURY),hl		;dc71
	ld a,018h		;dc74
	ld (0ffd4h),a		;dc76
	jp lddf0h		;dc79
	ld a,(CURX)		;dc7c
	cp 04fh			;dc7f
	jr z,ldc8ah		;dc81
	inc a			;dc83
	ld (CURX),a		;dc84
	jp lddf0h		;dc87
ldc8ah:
	ld a,000h		;dc8a
	ld (CURX),a		;dc8c
	call sub_dddah		;dc8f
	jp nz,0de01h		;dc92
	call lddf0h		;dc95
	jp lde42h		;dc98
ldc9bh:
	call 0defch		;dc9b
CONOUT_INT:
	ld a,(CURX)		;dc9e
	and 003h		;dca1
	cp 003h			;dca3
	jr nz,ldc9bh		;dca5
	ret			;dca7
	call sub_dddah		;dca8
	jp nz,0de01h		;dcab
	jp lde42h		;dcae
	ld hl,(CURY)		;dcb1
	ld a,l			;dcb4
	or h			;dcb5
	jp nz,lde11h		;dcb6
	ld hl,00780h		;dcb9
	ld (CURY),hl		;dcbc
	ld a,018h		;dcbf
	ld (0ffd4h),a		;dcc1
	jp lddf0h		;dcc4
	call 0de21h		;dcc7
	jp lddf0h		;dcca
	ld hl,(CURY)		;dccd
	ld b,h			;dcd0
	ld c,l			;dcd1
	ld de,lf850h		;dcd2
	add hl,de		;dcd5
	ld (lf4d4h),hl		;dcd6
	ld de,0ffb0h		;dcd9
	add hl,de		;dcdc
	ex de,hl		;dcdd
	ld h,b			;dcde
	ld l,c			;dcdf
	call lddd4h+1		;dce0
	ld bc,00780h		;dce3
	add hl,bc		;dce6
	ld b,h			;dce7
	ld c,l			;dce8
	ld hl,(lf4d4h)		;dce9
ISR_SIO0:
	call sub_de55h		;dcec
	ld hl,0ff80h		;dcef
	ld (0ffd5h),hl		;dcf2
	jp 0de34h		;dcf5
	ld hl,(CURY)		;dcf8
	ld de,SCREENBUF		;dcfb
	add hl,de		;dcfe
	ld (0ffd5h),hl		;dcff
	call lddd4h+1		;dd02
	ld de,0ff80h		;dd05
	add hl,de		;dd08
	ld b,h			;dd09
	ld c,l			;dd0a
	ld hl,0ff7fh		;dd0b
	ld de,SCRNEND		;dd0e
	call 0de5bh		;dd11
	jp 0de34h		;dd14
	ld l,l			;dd17
	sbc a,078h		;dd18
	rst 18h			;dd1a
	ld c,l			;dd1b
	rst 18h			;dd1c
	ld l,l			;dd1d
	sbc a,06dh		;dd1e
	sbc a,0d3h		;dd20
	sbc a,064h		;dd22
	sbc a,061h		;dd24
	sbc a,0d3h		;dd26
	sbc a,01bh		;dd28
	rst 18h			;dd2a
	jr z,$-31		;dd2b
	ld l,l			;dd2d
	sbc a,076h		;dd2e
	sbc a,06eh		;dd30
	sbc a,06dh		;dd32
	sbc a,06dh		;dd34
	sbc a,06dh		;dd36
	sbc a,06dh		;dd38
	sbc a,06dh		;dd3a
	sbc a,06dh		;dd3c
	sbc a,06dh		;dd3e
	sbc a,06dh		;dd40
	sbc a,06dh		;dd42
	sbc a,06dh		;dd44
	sbc a,0fch		;dd46
	sbc a,06dh		;dd48
	sbc a,031h		;dd4a
	rst 18h			;dd4c
	ld l,l			;dd4d
	sbc a,06dh		;dd4e
	sbc a,047h		;dd50
	rst 18h			;dd52
	sub a			;dd53
	sbc a,0b5h		;dd54
	sbc a,03eh		;dd56
	nop			;dd58
	ld (0ffd7h),a		;dd59
	ld a,(0ffdah)		;dd5c
	rlca			;dd5f
	and 03eh		;dd60
	ld c,a			;dd62
	ld b,000h		;dd63
	ld hl,ldf97h		;dd65
	add hl,bc		;dd68
	ld e,(hl)		;dd69
	inc hl			;dd6a
	ld d,(hl)		;dd6b
	ex de,hl		;dd6c
	jp (hl)			;dd6d
	ld a,(0ffdah)		;dd6e
	and 07fh		;dd71
	sub 020h		;dd73
	ld hl,0ffd7h		;dd75
	dec (hl)		;dd78
	jr z,ldd7fh		;dd79
	ld (0ffdeh),a		;dd7b
	ret			;dd7e
ldd7fh:
	ld d,a			;dd7f
	ld a,(0ffdeh)		;dd80
	ld h,a			;dd83
	ld a,(lda33h)		;dd84
	or a			;dd87
	jr z,ldd8bh		;dd88
	ex de,hl		;dd8a
ldd8bh:
	ld a,h			;dd8b
	ld b,050h		;dd8c
	call sub_de2fh		;dd8e
	ld (CURX),a		;dd91
	ld a,d			;dd94
	ld b,019h		;dd95
	call sub_de2fh		;dd97
	ld (0ffd4h),a		;dd9a
	or a			;dd9d
	jp z,lddf0h		;dd9e
	ld hl,(CURY)		;dda1
	ld de,00050h		;dda4
ldda7h:
	add hl,de		;dda7
	dec a			;dda8
	jr nz,ldda7h		;dda9
	ld (CURY),hl		;ddab
	jp lddf0h		;ddae
	ld hl,(CURY)		;ddb1
	ld d,000h		;ddb4
	ld a,(CURX)		;ddb6
	ld e,a			;ddb9
	add hl,de		;ddba
	ld (0ffd8h),hl		;ddbb
	ld a,(0ffdah)		;ddbe
	cp 0c0h			;ddc1
	jr c,lddc7h		;ddc3
	sub 0c0h		;ddc5
lddc7h:
	ld c,a			;ddc7
	cp 080h			;ddc8
	jr c,lddd4h		;ddca
	and 004h		;ddcc
sub_ddceh:
	ld (lf4d3h),a		;ddce
	ld a,c			;ddd1
	jr sub_dddah		;ddd2
lddd4h:
	ld hl,CONVTAB		;ddd4
	call sub_dde5h		;ddd7
sub_dddah:
	ld hl,(0ffd8h)		;ddda
	ld de,SCREENBUF		;dddd
	add hl,de		;dde0
	ld (hl),a		;dde1
	jp 0defch		;dde2
sub_dde5h:
	ld hl,(0da60h)		;dde5
	ld (0ffe9h),hl		;dde8
	ld a,(SCREENBUF)	;ddeb
	cp 0f3h			;ddee
lddf0h:
	ret			;ddf0
	di			;ddf1
	push hl			;ddf2
	ld hl,00000h		;ddf3
	add hl,sp		;ddf6
	ld sp,lf578h		;ddf7
	ei			;ddfa
	push hl			;ddfb
	push af			;ddfc
	push bc			;ddfd
	push de			;ddfe
	call 0e065h		;ddff
	jr nz,lde0ah		;de02
	ld a,(lf4d6h)		;de04
	ld (SCREENBUF),a	;de07
lde0ah:
	ld a,c			;de0a
	ld (0ffdah),a		;de0b
	ld a,(0ffd7h)		;de0e
lde11h:
	or a			;de11
	jr z,lde19h		;de12
	call sub_dfeeh		;de14
	jr lde28h		;de17
lde19h:
	ld a,(0ffdah)		;de19
	cp 020h			;de1c
	jr nc,lde25h		;de1e
	call 0dfd7h		;de20
	jr lde28h		;de23
lde25h:
	call 0e031h		;de25
lde28h:
	pop de			;de28
	pop bc			;de29
	pop af			;de2a
	pop hl			;de2b
	di			;de2c
	ld sp,hl		;de2d
	pop hl			;de2e
sub_de2fh:
	ei			;de2f
	ret			;de30
	ld (lf4b2h),sp		;de31
	ld sp,lf51eh		;de35
	push af			;de38
	push bc			;de39
	push de			;de3a
	push hl			;de3b
	in a,(001h)		;de3c
	ld a,006h		;de3e
	out (0fah),a		;de40
lde42h:
	ld a,007h		;de42
	out (0fah),a		;de44
	out (0fch),a		;de46
	ld hl,SCREENBUF		;de48
	ld a,l			;de4b
	out (0f4h),a		;de4c
	ld a,h			;de4e
	out (0f4h),a		;de4f
	ld hl,007cfh		;de51
	ld a,l			;de54
sub_de55h:
	out (0f5h),a		;de55
	ld a,h			;de57
	out (0f5h),a		;de58
	ld a,000h		;de5a
	out (0f7h),a		;de5c
	out (0f7h),a		;de5e
	ld a,002h		;de60
	out (0fah),a		;de62
	ld a,003h		;de64
	out (0fah),a		;de66
	ld a,0d7h		;de68
	out (00eh),a		;de6a
	ld a,001h		;de6c
	out (00eh),a		;de6e
	ld hl,RTCCNT		;de70
DSPY_START:
	inc (hl)		;de73
	jr nz,lde80h		;de74
	inc hl			;de76
	inc (hl)		;de77
	jr nz,lde80h		;de78
	inc hl			;de7a
	inc (hl)		;de7b
	jr nz,lde80h		;de7c
	inc hl			;de7e
	inc (hl)		;de7f
lde80h:
	ld hl,(TIMER1)		;de80
	ld a,l			;de83
	or h			;de84
	jr z,lde90h		;de85
	dec hl			;de87
	ld a,l			;de88
	or h			;de89
	ld (TIMER1),hl		;de8a
	call z,0ffebh		;de8d
lde90h:
	ld hl,(TIMER2)		;de90
	ld a,l			;de93
	or h			;de94
	jr z,ldea0h		;de95
	dec hl			;de97
	ld a,l			;de98
	or h			;de99
	ld (TIMER2),hl		;de9a
	call z,sub_e524h	;de9d
ldea0h:
	ld hl,(0ffe9h)		;dea0
	ld a,l			;dea3
	or h			;dea4
	jr z,ldec4h		;dea5
	dec hl			;dea7
	ld a,l			;dea8
	or h			;dea9
	ld (0ffe9h),hl		;deaa
	jr nz,ldec4h		;dead
	ld a,(SCREENBUF)	;deaf
	ld (lf4d6h),a		;deb2
	ld a,0f3h		;deb5
	ld (SCREENBUF),a	;deb7
	ld a,080h		;deba
	out (001h),a		;debc
	ld a,020h		;debe
	out (000h),a		;dec0
	out (000h),a		;dec2
ldec4h:
	ld hl,lf4e6h		;dec4
	dec (hl)		;dec7
	jr nz,ldef2h		;dec8
	ld (hl),032h		;deca
	dec hl			;decc
	ld b,002h		;decd
	dec hl			;decf
lded0h:
	dec hl			;ded0
	inc (hl)		;ded1
	call sub_e198h		;ded2
	jr nz,ldef2h		;ded5
	dec b			;ded7
	jr nz,lded0h		;ded8
	dec hl			;deda
	inc (hl)		;dedb
	call sub_e198h		;dedc
	ld hl,lf4dch		;dedf
	ld a,(hl)		;dee2
	cp 032h			;dee3
	jr nz,ldef2h		;dee5
	inc hl			;dee7
	ld a,(hl)		;dee8
	cp 034h			;dee9
DSPY_XLAT:
	jr nz,ldef2h		;deeb
	ld (hl),030h		;deed
	dec hl			;deef
DSPY_CRT:
	ld (hl),030h		;def0
ldef2h:
	ld hl,lf4e5h		;def2
	ld a,(hl)		;def5
	or a			;def6
	jr nz,ldf02h		;def7
	dec hl			;def9
	ld bc,0000ch		;defa
	ld de,lf84fh		;defd
	lddr			;df00
ldf02h:
	ld hl,(0ffe3h)		;df02
	ld a,l			;df05
	or h			;df06
	jr z,ldf0dh		;df07
	dec hl			;df09
	ld (0ffe3h),hl		;df0a
ldf0dh:
	pop hl			;df0d
	pop de			;df0e
	pop bc			;df0f
	pop af			;df10
DSPY_UP:
	ld sp,(lf4b2h)		;df11
	ei			;df15
	reti			;df16
	ld a,(hl)		;df18
	cp 03ah			;df19
	ret nz			;df1b
	ld (hl),030h		;df1c
	dec hl			;df1e
	inc (hl)		;df1f
	ld a,(hl)		;df20
DSPY_HOME:
	cp 036h			;df21
	ret nz			;df23
	ld (hl),030h		;df24
	dec hl			;df26
	ret			;df27
	ld hl,00000h		;df28
	add hl,sp		;df2b
	ld sp,lf578h		;df2c
DSPY_CLR:
	push hl			;df2f
	ld de,00000h		;df30
	ld a,c			;df33
	cp 005h			;df34
	jp nc,le26fh		;df36
	ld b,000h		;df39
	ld hl,0da37h		;df3b
	add hl,bc		;df3e
	ld a,(hl)		;df3f
	cp 0ffh			;df40
	jp z,le26fh		;df42
	ld a,c			;df45
	ld (lf482h),a		;df46
	ld bc,00010h		;df49
	ex de,hl		;df4c
	ld hl,00000h		;df4d
ldf50h:
	or a			;df50
	jr z,ldf57h		;df51
	add hl,bc		;df53
	dec a			;df54
	jr ldf50h		;df55
ldf57h:
	ld c,l			;df57
	ld b,h			;df58
	ex de,hl		;df59
	push bc			;df5a
	push hl			;df5b
	ld a,(hl)		;df5c
	push af			;df5d
	ld a,(lf492h)		;df5e
	or a			;df61
	call nz,0e3e9h		;df62
	xor a			;df65
	ld (lf492h),a		;df66
	pop af			;df69
	ld (lf4a2h),a		;df6a
	pop bc			;df6d
	ld hl,lf4b6h		;df6e
	ld a,(lf482h)		;df71
	ld (hl),0ffh		;df74
	cp 004h			;df76
	jr z,ldf9eh		;df78
	inc (hl)		;df7a
	push bc			;df7b
	pop hl			;df7c
	ld bc,00008h		;df7d
	add hl,bc		;df80
	ld a,(hl)		;df81
	and 003h		;df82
	or 080h			;df84
	ld (lf4c8h),a		;df86
	ld a,(hl)		;df89
	or 00fh			;df8a
	ld b,a			;df8c
	ld a,003h		;df8d
	out (005h),a		;df8f
	call sub_e553h		;df91
	ld a,b			;df94
	out (005h),a		;df95
ldf97h:
	call sub_e553h		;df97
	ld a,028h		;df9a
	out (005h),a		;df9c
ldf9eh:
	call 0e273h		;df9e
	ld (lf4a0h),hl		;dfa1
DSPY_SCRL:
	inc hl			;dfa4
	inc hl			;dfa5
	inc hl			;dfa6
	inc hl			;dfa7
	ld a,(hl)		;dfa8
	ld (lf4a3h),a		;dfa9
	ld a,(lf4a2h)		;dfac
	and 0f8h		;dfaf
	or a			;dfb1
	rla			;dfb2
	ld e,a			;dfb3
	ld d,000h		;dfb4
	ld hl,le78fh		;dfb6
	add hl,de		;dfb9
	ld de,lf4b7h		;dfba
	ld bc,00010h		;dfbd
	ldir			;dfc0
	ld hl,(lf4b7h)		;dfc2
	ld bc,0000dh		;dfc5
	add hl,bc		;dfc8
	ex de,hl		;dfc9
	ld hl,le785h		;dfca
	ld b,000h		;dfcd
	ld a,(lf482h)		;dfcf
	ld c,a			;dfd2
	add hl,bc		;dfd3
	add hl,bc		;dfd4
	ld bc,00002h		;dfd5
	ldir			;dfd8
	pop bc			;dfda
	ld hl,le897h		;dfdb
	add hl,bc		;dfde
	ex de,hl		;dfdf
	ld hl,0000ah		;dfe0
	add hl,de		;dfe3
	ex de,hl		;dfe4
	ld a,(lf4b7h)		;dfe5
	ld (de),a		;dfe8
	inc de			;dfe9
	ld a,(lf4b8h)		;dfea
	ld (de),a		;dfed
sub_dfeeh:
	ex de,hl		;dfee
	pop hl			;dfef
	ld sp,hl		;dff0
	ex de,hl		;dff1
	ret			;dff2
	ld hl,le840h		;dff3
	ld a,(lf4a2h)		;dff6
	and 0f8h		;dff9
	ld e,a			;dffb
	ld d,000h		;dffc
	add hl,de		;dffe
	ret			;dfff
	ld (lf483h),bc		;e000
	ret			;e004
	ld (lf485h),bc		;e005
ISR_CRT:
	ret			;e009
	ld (lf49eh),bc		;e00a
	ret			;e00e
	ld h,b			;e00f
	ld l,c			;e010
	ret			;e011
	xor a			;e012
	ld (lf493h),a		;e013
	ld a,001h		;e016
	ld (lf49ch),a		;e018
	ld (lf49bh),a		;e01b
	ld a,003h		;e01e
	ld (lf49dh),a		;e020
	jp le332h		;e023
	xor a			;e026
	ld (lf49ch),a		;e027
	ld a,c			;e02a
	ld (lf49dh),a		;e02b
	cp 003h			;e02e
	jr nz,le04ah		;e030
	ld a,(lf4b9h)		;e032
	ld (lf493h),a		;e035
	ld a,(lf482h)		;e038
	ld (lf494h),a		;e03b
	ld hl,(lf483h)		;e03e
	ld (lf495h),hl		;e041
	ld hl,(lf485h)		;e044
	ld (lf497h),hl		;e047
le04ah:
	ld a,(lf493h)		;e04a
	or a			;e04d
	jr z,le0a8h		;e04e
	dec a			;e050
	ld (lf493h),a		;e051
	ld a,(lf482h)		;e054
	ld hl,lf494h		;e057
	cp (hl)			;e05a
	jr nz,le0a8h		;e05b
	ld hl,lf495h		;e05d
	ld a,(lf483h)		;e060
	cp (hl)			;e063
	jr nz,le0a8h		;e064
	ld a,(lf485h)		;e066
	ld hl,lf497h		;e069
	cp (hl)			;e06c
	jr nz,le0a8h		;e06d
	ld hl,(lf497h)		;e06f
	inc hl			;e072
	ld (lf497h),hl		;e073
	ex de,hl		;e076
	ld hl,lf4bah		;e077
	push bc			;e07a
	ld c,(hl)		;e07b
	inc hl			;e07c
	ld b,(hl)		;e07d
	ex de,hl		;e07e
	and a			;e07f
	sbc hl,bc		;e080
	pop bc			;e082
	jr c,le092h		;e083
	ld hl,00000h		;e085
	ld (lf497h),hl		;e088
	ld hl,(lf495h)		;e08b
	inc hl			;e08e
	ld (lf495h),hl		;e08f
le092h:
	xor a			;e092
	ld (lf49bh),a		;e093
	ld a,(lf485h)		;e096
	ld hl,lf4bch		;e099
	and (hl)		;e09c
	cp (hl)			;e09d
	ld a,000h		;e09e
	jr nz,le0a3h		;e0a0
	inc a			;e0a2
le0a3h:
	ld (lf499h),a		;e0a3
	jr le0b2h		;e0a6
le0a8h:
	xor a			;e0a8
	ld (lf493h),a		;e0a9
	ld a,(lf4bch)		;e0ac
	ld (lf49bh),a		;e0af
le0b2h:
	ld hl,00000h		;e0b2
	add hl,sp		;e0b5
	ld sp,lf578h		;e0b6
	push hl			;e0b9
	ld a,(lf4bdh)		;e0ba
	ld b,a			;e0bd
	ld hl,(lf485h)		;e0be
le0c1h:
	dec b			;e0c1
	jr z,le0cah		;e0c2
	srl h			;e0c4
	rr l			;e0c6
	jr le0c1h		;e0c8
le0cah:
	ld (lf48fh),hl		;e0ca
	ld hl,lf491h		;e0cd
	ld a,(hl)		;e0d0
	ld (hl),001h		;e0d1
	or a			;e0d3
	jr z,le0f8h		;e0d4
	ld a,(lf482h)		;e0d6
	ld hl,lf487h		;e0d9
	cp (hl)			;e0dc
	jr nz,le0f1h		;e0dd
	ld hl,lf488h		;e0df
	ld a,(lf483h)		;e0e2
	cp (hl)			;e0e5
	jr nz,le0f1h		;e0e6
	ld a,(lf48fh)		;e0e8
	ld hl,lf48ah		;e0eb
	cp (hl)			;e0ee
	jr z,le115h		;e0ef
le0f1h:
	ld a,(lf492h)		;e0f1
	or a			;e0f4
	call nz,0e3e9h		;e0f5
le0f8h:
	ld a,(lf482h)		;e0f8
	ld (lf487h),a		;e0fb
	ld hl,(lf483h)		;e0fe
	ld (lf488h),hl		;e101
	ld hl,(lf48fh)		;e104
	ld (lf48ah),hl		;e107
	ld a,(lf49bh)		;e10a
	or a			;e10d
	call nz,0e3f6h		;e10e
	xor a			;e111
	ld (lf492h),a		;e112
le115h:
	ld a,(lf485h)		;e115
	ld hl,lf4bch		;e118
	and (hl)		;e11b
	ld l,a			;e11c
	ld h,000h		;e11d
	add hl,hl		;e11f
	add hl,hl		;e120
	add hl,hl		;e121
	add hl,hl		;e122
	add hl,hl		;e123
	add hl,hl		;e124
	add hl,hl		;e125
	ld de,lec81h		;e126
	add hl,de		;e129
	ex de,hl		;e12a
	ld hl,(lf49eh)		;e12b
	ld bc,00080h		;e12e
	ex de,hl		;e131
	ld a,(lf49ch)		;e132
	or a			;e135
	jr nz,le13eh		;e136
	ld a,001h		;e138
	ld (lf492h),a		;e13a
	ex de,hl		;e13d
le13eh:
	ldir			;e13e
	ld a,(lf49dh)		;e140
	cp 001h			;e143
	ld hl,RAMDSTAT		;e145
	ld a,(hl)		;e148
	push af			;e149
	or a			;e14a
	jr z,le151h		;e14b
	xor a			;e14d
	ld (lf491h),a		;e14e
le151h:
	pop af			;e151
	ld (hl),000h		;e152
	jr nz,le166h		;e154
	or a			;e156
	jr nz,le166h		;e157
	xor a			;e159
	ld (lf492h),a		;e15a
	call 0e3e9h		;e15d
	ld hl,RAMDSTAT		;e160
	ld a,(hl)		;e163
	ld (hl),000h		;e164
le166h:
	pop hl			;e166
	ld sp,hl		;e167
	ret			;e168
	ld a,(lf4b6h)		;e169
	or a			;e16c
	jp nz,le6a2h		;e16d
	call sub_e40bh		;e170
	jp le4cbh		;e173
	ld a,(lf499h)		;e176
	or a			;e179
	jr nz,le17fh		;e17a
	ld (lf493h),a		;e17c
le17fh:
	ld a,(lf4b6h)		;e17f
	or a			;e182
	jp nz,sub_e6a6h		;e183
	call sub_e40bh		;e186
	jr le205h		;e189
	ld a,(lf48ah)		;e18b
	ld c,a			;e18e
	ld a,(lf4a3h)		;e18f
	ld b,a			;e192
	dec a			;e193
	cp c			;e194
	ld a,(lf487h)		;e195
sub_e198h:
	jr nc,le1a4h		;e198
	or 004h			;e19a
	ld (lf4a4h),a		;e19c
	ld a,c			;e19f
	sub b			;e1a0
	ld c,a			;e1a1
	jr le1a7h		;e1a2
le1a4h:
	ld (lf4a4h),a		;e1a4
le1a7h:
	ld b,000h		;e1a7
	ld hl,(lf4beh)		;e1a9
	add hl,bc		;e1ac
	ld a,(hl)		;e1ad
	ld (lf4a8h),a		;e1ae
	ld a,(lf488h)		;e1b1
	ld (lf4a7h),a		;e1b4
	ld hl,lec81h		;e1b7
	ld (lf4a5h),hl		;e1ba
	ld a,(lf487h)		;e1bd
	ld hl,lf48ch		;e1c0
	cp (hl)			;e1c3
	jr nz,le1d5h		;e1c4
	ld a,(lf488h)		;e1c6
	ld hl,lf48dh		;e1c9
	cp (hl)			;e1cc
	jr nz,le1d5h		;e1cd
	ld a,(lf489h)		;e1cf
	inc hl			;e1d2
	cp (hl)			;e1d3
	ret z			;e1d4
le1d5h:
	ld a,(lf487h)		;e1d5
	ld (lf48ch),a		;e1d8
	ld hl,(lf488h)		;e1db
	ld (lf48dh),hl		;e1de
	call sub_e5efh		;e1e1
	call sub_e5aeh		;e1e4
	call RAMDISK		;e1e7
	ld a,(lf4a4h)		;e1ea
	and 003h		;e1ed
	add a,020h		;e1ef
	cp b			;e1f1
	ret z			;e1f2
	call sub_e5efh		;e1f3
	call sub_e565h		;e1f6
	push bc			;e1f9
	call RAMDISK		;e1fa
	call sub_e5aeh		;e1fd
	call RAMDISK		;e200
	pop bc			;e203
	ret			;e204
le205h:
	ld a,00ah		;e205
	ld (lf4a9h),a		;e207
le20ah:
	call sub_e4f4h		;e20a
	call sub_e5efh		;e20d
	ld hl,(lf4a0h)		;e210
	ld c,(hl)		;e213
	inc hl			;e214
	ld b,(hl)		;e215
	inc hl			;e216
	call sub_e61eh		;e217
	call sub_e4eah		;e21a
	call sub_e5f6h		;e21d
	ld c,000h		;e220
le222h:
	ld hl,WARMJP2		;e222
	ld a,(hl)		;e225
	and 0f8h		;e226
	ret z			;e228
	and 008h		;e229
	jr nz,le241h		;e22b
	ld a,(lf4a9h)		;e22d
	dec a			;e230
	ld (lf4a9h),a		;e231
	jr z,le241h		;e234
	cp 005h			;e236
	call z,sub_e473h	;e238
	xor a			;e23b
	cp c			;e23c
	jr z,le20ah		;e23d
	jr le250h		;e23f
le241h:
	ld a,c			;e241
	ld (lf491h),a		;e242
	ld a,001h		;e245
	ld (RAMDSTAT),a		;e247
	ret			;e24a
	ld a,00ah		;e24b
	ld (lf4a9h),a		;e24d
le250h:
	call sub_e4f4h		;e250
	call sub_e5efh		;e253
	ld hl,(lf4a0h)		;e256
	ld c,(hl)		;e259
	inc hl			;e25a
	ld b,(hl)		;e25b
	inc hl			;e25c
	call sub_e5fdh		;e25d
	call sub_e4efh		;e260
	call sub_e5f6h		;e263
	ld c,001h		;e266
	jr le222h		;e268
	ld a,006h		;e26a
	jp le627h		;e26c
le26fh:
	ld a,005h		;e26f
	jp le627h		;e271
	di			;e274
	ld hl,(TIMER2)		;e275
	ld a,h			;e278
	or l			;e279
	ld a,(lf4c8h)		;e27a
	jr z,le281h		;e27d
	or 001h			;e27f
le281h:
	out (014h),a		;e281
	ld a,(lf4c8h)		;e283
	and 001h		;e286
	jr nz,le28ch		;e288
SETDMA:
	ei			;e28a
	ret			;e28b
le28ch:
	ld a,h			;e28c
	or l			;e28d
	ld hl,(MOTORTIMER)	;e28e
	ld (TIMER2),hl		;e291
	ei			;e294
	ret nz			;e295
	ld hl,00032h		;e296
	ld (0ffe3h),hl		;e299
le29ch:
	ld hl,(0ffe3h)		;e29c
	ld a,l			;e29f
	or h			;e2a0
	jr nz,le29ch		;e2a1
	ret			;e2a3
	ld a,000h		;e2a4
WRITE:
	out (014h),a		;e2a6
	ret			;e2a8
	ld a,(lf492h)		;e2a9
	or a			;e2ac
	jr nz,le2b2h		;e2ad
	ld (lf491h),a		;e2af
le2b2h:
	xor a			;e2b2
	ld (lf48dh),a		;e2b3
	ld (lf48eh),a		;e2b6
	ld a,(lf4b6h)		;e2b9
	or a			;e2bc
	ret nz			;e2bd
	call sub_e4f4h		;e2be
	ld a,(lf482h)		;e2c1
	ld (lf4a4h),a		;e2c4
	ld (lf48ch),a		;e2c7
	call sub_e5efh		;e2ca
	call sub_e565h		;e2cd
	jp RAMDISK		;e2d0
le2d3h:
	in a,(004h)		;e2d3
	and 0c0h		;e2d5
	cp 080h			;e2d7
	jr nz,le2d3h		;e2d9
	ret			;e2db
le2dch:
	in a,(004h)		;e2dc
	and 0c0h		;e2de
	cp 0c0h			;e2e0
	jr nz,le2dch		;e2e2
	ret			;e2e4
	call sub_e553h		;e2e5
	ld a,007h		;e2e8
	out (005h),a		;e2ea
	call sub_e553h		;e2ec
	ld a,(lf4a4h)		;e2ef
	and 003h		;e2f2
	out (005h),a		;e2f4
	ret			;e2f6
	call sub_e553h		;e2f7
	ld a,004h		;e2fa
	out (005h),a		;e2fc
	call sub_e553h		;e2fe
	ld a,(lf4a4h)		;e301
	and 003h		;e304
	out (005h),a		;e306
	call FDCRESULT		;e308
	in a,(005h)		;e30b
	ld (WARMJP2),a		;e30d
	ret			;e310
	call sub_e553h		;e311
	ld a,008h		;e314
	out (005h),a		;e316
	call FDCRESULT		;e318
	in a,(005h)		;e31b
	ld (WARMJP2),a		;e31d
	and 0c0h		;e320
	cp 080h			;e322
	ret z			;e324
	call FDCRESULT		;e325
	in a,(005h)		;e328
	ld (lf4abh),a		;e32a
	ret			;e32d
	di			;e32e
	call sub_e553h		;e32f
le332h:
	ld a,00fh		;e332
	out (005h),a		;e334
	call sub_e553h		;e336
	ld a,(lf4a4h)		;e339
	and 003h		;e33c
	out (005h),a		;e33e
	call sub_e553h		;e340
	ld a,(lf4a7h)		;e343
	out (005h),a		;e346
	ei			;e348
	ret			;e349
	ld hl,WARMJP2		;e34a
	ld d,007h		;e34d
le34fh:
	call FDCRESULT		;e34f
	in a,(005h)		;e352
	ld (hl),a		;e354
	inc hl			;e355
	ld a,004h		;e356
le358h:
	dec a			;e358
	jr nz,le358h		;e359
	in a,(004h)		;e35b
	and 010h		;e35d
	ret z			;e35f
	dec d			;e360
	jr nz,le34fh		;e361
	ret			;e363
	call sub_e5f6h		;e364
	ld a,(WARMJP2)		;e367
	ld b,a			;e36a
	ld a,(lf4abh)		;e36b
	ld c,a			;e36e
	di			;e36f
	xor a			;e370
	ld (lf4b4h),a		;e371
	ei			;e374
	ret			;e375
le376h:
	ld a,(lf4b4h)		;e376
	or a			;e379
	jr z,le376h		;e37a
	ret			;e37c
	ld a,005h		;e37d
	di			;e37f
	out (0fah),a		;e380
	ld a,049h		;e382
le384h:
	out (0fbh),a		;e384
	out (0fch),a		;e386
	ld a,(lf4a5h)		;e388
	out (0f2h),a		;e38b
	ld a,(lf4a6h)		;e38d
	out (0f2h),a		;e390
	ld a,c			;e392
	out (0f3h),a		;e393
	ld a,b			;e395
	out (0f3h),a		;e396
	ld a,001h		;e398
	out (0fah),a		;e39a
	ei			;e39c
	ret			;e39d
	ld a,005h		;e39e
	di			;e3a0
	out (0fah),a		;e3a1
	ld a,045h		;e3a3
	jr le384h		;e3a5
	push af			;e3a7
	di			;e3a8
	call sub_e553h		;e3a9
	pop af			;e3ac
	ld b,(hl)		;e3ad
	inc hl			;e3ae
	add a,b			;e3af
	out (005h),a		;e3b0
	call sub_e553h		;e3b2
	ld a,(lf4a4h)		;e3b5
	out (005h),a		;e3b8
	call sub_e553h		;e3ba
	ld a,(lf4a7h)		;e3bd
	out (005h),a		;e3c0
	call sub_e553h		;e3c2
	ld a,(lf4a4h)		;e3c5
	rra			;e3c8
	rra			;e3c9
	and 003h		;e3ca
	out (005h),a		;e3cc
	call sub_e553h		;e3ce
	ld a,(lf4a8h)		;e3d1
	out (005h),a		;e3d4
	call sub_e553h		;e3d6
	ld a,(hl)		;e3d9
	inc hl			;e3da
	out (005h),a		;e3db
	call sub_e553h		;e3dd
	ld a,(hl)		;e3e0
	inc hl			;e3e1
	out (005h),a		;e3e2
	call sub_e553h		;e3e4
	ld a,(hl)		;e3e7
	out (005h),a		;e3e8
	call sub_e553h		;e3ea
	ld a,(lf4c0h)		;e3ed
	out (005h),a		;e3f0
	ei			;e3f2
	ret			;e3f3
	ld (lf4b2h),sp		;e3f4
	ld sp,lf51eh		;e3f8
	push af			;e3fb
	push bc			;e3fc
	push de			;e3fd
	push hl			;e3fe
	ld a,0ffh		;e3ff
	ld (lf4b4h),a		;e401
	ld a,005h		;e404
le406h:
	dec a			;e406
	jr nz,le406h		;e407
	in a,(004h)		;e409
sub_e40bh:
	and 010h		;e40b
	jr nz,le414h		;e40d
	call sub_e591h		;e40f
	jr le417h		;e412
le414h:
	call sub_e5cah		;e414
le417h:
	pop hl			;e417
	pop de			;e418
	pop bc			;e419
	pop af			;e41a
	ld sp,(lf4b2h)		;e41b
	ei			;e41f
	reti			;e420
	ld b,048h		;e422
	jr le428h		;e424
	ld b,044h		;e426
le428h:
	di			;e428
	ld a,004h		;e429
	out (0fah),a		;e42b
	ld a,b			;e42d
	ld hl,lec81h		;e42e
	ld bc,003ffh		;e431
	out (0fbh),a		;e434
	out (0fch),a		;e436
	ld a,l			;e438
	out (0f0h),a		;e439
	ld a,h			;e43b
	out (0f0h),a		;e43c
	ld a,c			;e43e
	out (0f1h),a		;e43f
	ld a,b			;e441
	out (0f1h),a		;e442
	xor a			;e444
	out (0fah),a		;e445
	ei			;e447
	ld a,(lf488h)		;e448
	out (0eeh),a		;e44b
	ld a,(lf48ah)		;e44d
	out (0efh),a		;e450
le452h:
	in a,(0eeh)		;e452
	and 002h		;e454
	jr nz,le452h		;e456
	in a,(0eeh)		;e458
	and 001h		;e45a
	ld (RAMDSTAT),a		;e45c
	ret			;e45f
code008_end:
DISKTAB:

; BLOCK 'disktab' (start 0xe460 end 0xe6bf)
disktab_start:
	defb 020h		;e460
	defb 000h		;e461
	defb 003h		;e462
	defb 007h		;e463
	defb 000h		;e464
	defb 09fh		;e465
	defb 000h		;e466
	defb 03fh		;e467
	defb 000h		;e468
	defb 0c0h		;e469
	defb 000h		;e46a
	defb 010h		;e46b
	defb 000h		;e46c
	defb 000h		;e46d
	defb 000h		;e46e
	defb 040h		;e46f
	defb 000h		;e470
	defb 004h		;e471
	defb 00fh		;e472
sub_e473h:
	defb 001h		;e473
	defb 09fh		;e474
	defb 000h		;e475
	defb 07fh		;e476
	defb 000h		;e477
	defb 0c0h		;e478
	defb 000h		;e479
	defb 020h		;e47a
	defb 000h		;e47b
	defb 000h		;e47c
	defb 000h		;e47d
	defb 048h		;e47e
	defb 000h		;e47f
	defb 004h		;e480
	defb 00fh		;e481
	defb 001h		;e482
	defb 0aah		;e483
	defb 000h		;e484
	defb 07fh		;e485
	defb 000h		;e486
	defb 0c0h		;e487
	defb 000h		;e488
	defb 020h		;e489
	defb 000h		;e48a
	defb 002h		;e48b
	defb 000h		;e48c
	defb 078h		;e48d
	defb 000h		;e48e
	defb 004h		;e48f
	defb 00fh		;e490
	defb 000h		;e491
	defb 031h		;e492
	defb 002h		;e493
	defb 07fh		;e494
	defb 000h		;e495
	defb 0c0h		;e496
	defb 000h		;e497
	defb 020h		;e498
	defb 000h		;e499
	defb 002h		;e49a
	defb 000h		;e49b
	defb 080h		;e49c
	defb 000h		;e49d
	defb 004h		;e49e
	defb 00fh		;e49f
	defb 000h		;e4a0
	defb 057h		;e4a1
	defb 002h		;e4a2
	defb 0ffh		;e4a3
	defb 001h		;e4a4
	defb 0ffh		;e4a5
	defb 000h		;e4a6
	defb 080h		;e4a7
	defb 000h		;e4a8
	defb 002h		;e4a9
	defb 000h		;e4aa
	defb 050h		;e4ab
	defb 000h		;e4ac
	defb 004h		;e4ad
	defb 00fh		;e4ae
	defb 001h		;e4af
	defb 0bdh		;e4b0
	defb 000h		;e4b1
	defb 0ffh		;e4b2
	defb 000h		;e4b3
	defb 0f0h		;e4b4
	defb 000h		;e4b5
	defb 040h		;e4b6
	defb 000h		;e4b7
	defb 002h		;e4b8
	defb 000h		;e4b9
	defb 050h		;e4ba
	defb 000h		;e4bb
	defb 004h		;e4bc
	defb 00fh		;e4bd
	defb 000h		;e4be
	defb 085h		;e4bf
	defb 001h		;e4c0
	defb 0ffh		;e4c1
	defb 000h		;e4c2
	defb 0f0h		;e4c3
	defb 000h		;e4c4
	defb 040h		;e4c5
	defb 000h		;e4c6
	defb 002h		;e4c7
	defb 000h		;e4c8
	defb 01ah		;e4c9
	defb 000h		;e4ca
le4cbh:
	defb 003h		;e4cb
	defb 007h		;e4cc
	defb 000h		;e4cd
	defb 0f2h		;e4ce
	defb 000h		;e4cf
	defb 03fh		;e4d0
	defb 000h		;e4d1
	defb 0c0h		;e4d2
	defb 000h		;e4d3
	defb 010h		;e4d4
	defb 000h		;e4d5
	defb 002h		;e4d6
	defb 000h		;e4d7
	defb 068h		;e4d8
	defb 000h		;e4d9
	defb 004h		;e4da
	defb 00fh		;e4db
	defb 000h		;e4dc
	defb 0d7h		;e4dd
	defb 001h		;e4de
	defb 07fh		;e4df
	defb 000h		;e4e0
	defb 0c0h		;e4e1
	defb 000h		;e4e2
	defb 020h		;e4e3
	defb 000h		;e4e4
	defb 000h		;e4e5
	defb 000h		;e4e6
	defb 028h		;e4e7
	defb 000h		;e4e8
	defb 003h		;e4e9
sub_e4eah:
	defb 007h		;e4ea
	defb 000h		;e4eb
	defb 0bdh		;e4ec
	defb 000h		;e4ed
	defb 03fh		;e4ee
sub_e4efh:
	defb 000h		;e4ef
	defb 0c0h		;e4f0
	defb 000h		;e4f1
	defb 010h		;e4f2
	defb 000h		;e4f3
sub_e4f4h:
	defb 002h		;e4f4
	defb 000h		;e4f5
	defb 080h		;e4f6
	defb 000h		;e4f7
	defb 004h		;e4f8
	defb 00fh		;e4f9
	defb 001h		;e4fa
	defb 000h		;e4fb
	defb 000h		;e4fc
	defb 0ffh		;e4fd
	defb 000h		;e4fe
	defb 0f0h		;e4ff
	defb 000h		;e500
	defb 000h		;e501
	defb 000h		;e502
	defb 000h		;e503
	defb 000h		;e504
	defb 002h		;e505
	defb 000h		;e506
	defb 002h		;e507
	defb 000h		;e508
	defb 002h		;e509
	defb 000h		;e50a
	defb 002h		;e50b
	defb 000h		;e50c
	defb 000h		;e50d
	defb 000h		;e50e
	defb 0e0h		;e50f
	defb 0e6h		;e510
	defb 008h		;e511
	defb 010h		;e512
	defb 000h		;e513
	defb 000h		;e514
	defb 001h		;e515
	defb 01ah		;e516
	defb 0e9h		;e517
	defb 080h		;e518
sub_e519h:
	defb 000h		;e519
	defb 000h		;e51a
	defb 000h		;e51b
	defb 000h		;e51c
	defb 000h		;e51d
	defb 000h		;e51e
	defb 0efh		;e51f
	defb 0e6h		;e520
	defb 010h		;e521
	defb 020h		;e522
	defb 000h		;e523
sub_e524h:
	defb 001h		;e524
	defb 002h		;e525
	defb 01ah		;e526
	defb 0e9h		;e527
	defb 0ffh		;e528
HOME:
	defb 000h		;e529
	defb 000h		;e52a
	defb 000h		;e52b
	defb 000h		;e52c
	defb 000h		;e52d
	defb 000h		;e52e
	defb 0feh		;e52f
	defb 0e6h		;e530
	defb 010h		;e531
	defb 048h		;e532
	defb 000h		;e533
	defb 003h		;e534
	defb 003h		;e535
	defb 010h		;e536
	defb 0e9h		;e537
	defb 0ffh		;e538
	defb 000h		;e539
	defb 000h		;e53a
	defb 000h		;e53b
	defb 000h		;e53c
	defb 000h		;e53d
	defb 000h		;e53e
	defb 00dh		;e53f
	defb 0e7h		;e540
	defb 010h		;e541
	defb 078h		;e542
	defb 000h		;e543
	defb 003h		;e544
	defb 003h		;e545
	defb 001h		;e546
	defb 0e9h		;e547
	defb 0ffh		;e548
	defb 000h		;e549
	defb 000h		;e54a
	defb 000h		;e54b
	defb 000h		;e54c
	defb 000h		;e54d
	defb 000h		;e54e
	defb 01ch		;e54f
	defb 0e7h		;e550
	defb 010h		;e551
	defb 080h		;e552
sub_e553h:
	defb 000h		;e553
	defb 007h		;e554
	defb 004h		;e555
	defb 01ah		;e556
	defb 0e9h		;e557
	defb 0ffh		;e558
	defb 000h		;e559
	defb 000h		;e55a
	defb 000h		;e55b
FDCRESULT:
	defb 000h		;e55c
	defb 000h		;e55d
	defb 000h		;e55e
	defb 02bh		;e55f
	defb 0e7h		;e560
	defb 010h		;e561
	defb 050h		;e562
	defb 000h		;e563
	defb 007h		;e564
sub_e565h:
	defb 004h		;e565
	defb 01ah		;e566
	defb 0e9h		;e567
	defb 0ffh		;e568
	defb 000h		;e569
	defb 000h		;e56a
	defb 000h		;e56b
	defb 000h		;e56c
	defb 000h		;e56d
	defb 000h		;e56e
	defb 03ah		;e56f
	defb 0e7h		;e570
	defb 010h		;e571
	defb 050h		;e572
	defb 000h		;e573
FDCDMA_RD:
	defb 003h		;e574
	defb 003h		;e575
	defb 010h		;e576
	defb 0e9h		;e577
	defb 0ffh		;e578
	defb 000h		;e579
	defb 000h		;e57a
	defb 000h		;e57b
	defb 000h		;e57c
	defb 000h		;e57d
	defb 000h		;e57e
	defb 049h		;e57f
	defb 0e7h		;e580
	defb 008h		;e581
	defb 01ah		;e582
	defb 000h		;e583
	defb 000h		;e584
	defb 001h		;e585
	defb 0e7h		;e586
	defb 0e8h		;e587
	defb 080h		;e588
	defb 000h		;e589
	defb 000h		;e58a
	defb 000h		;e58b
	defb 000h		;e58c
	defb 000h		;e58d
	defb 000h		;e58e
	defb 058h		;e58f
	defb 0e7h		;e590
sub_e591h:
	defb 008h		;e591
	defb 068h		;e592
	defb 000h		;e593
FDCDMA_WR:
	defb 001h		;e594
	defb 002h		;e595
	defb 01ah		;e596
	defb 0e9h		;e597
	defb 0ffh		;e598
	defb 000h		;e599
	defb 000h		;e59a
	defb 000h		;e59b
	defb 000h		;e59c
	defb 000h		;e59d
	defb 000h		;e59e
	defb 067h		;e59f
	defb 0e7h		;e5a0
	defb 008h		;e5a1
	defb 028h		;e5a2
	defb 000h		;e5a3
	defb 003h		;e5a4
	defb 003h		;e5a5
	defb 034h		;e5a6
	defb 0e9h		;e5a7
	defb 0ffh		;e5a8
	defb 000h		;e5a9
	defb 000h		;e5aa
	defb 000h		;e5ab
	defb 000h		;e5ac
	defb 000h		;e5ad
sub_e5aeh:
	defb 000h		;e5ae
	defb 076h		;e5af
	defb 0e7h		;e5b0
	defb 010h		;e5b1
	defb 080h		;e5b2
	defb 000h		;e5b3
	defb 007h		;e5b4
	defb 004h		;e5b5
	defb 01ah		;e5b6
	defb 0e9h		;e5b7
	defb 0ffh		;e5b8
	defb 000h		;e5b9
	defb 000h		;e5ba
	defb 000h		;e5bb
	defb 000h		;e5bc
	defb 000h		;e5bd
	defb 000h		;e5be
	defb 020h		;e5bf
	defb 07fh		;e5c0
	defb 000h		;e5c1
	defb 000h		;e5c2
	defb 000h		;e5c3
	defb 010h		;e5c4
	defb 007h		;e5c5
	defb 028h		;e5c6
	defb 020h		;e5c7
	defb 0ffh		;e5c8
	defb 000h		;e5c9
sub_e5cah:
	defb 040h		;e5ca
	defb 001h		;e5cb
	defb 010h		;e5cc
	defb 00eh		;e5cd
	defb 028h		;e5ce
	defb 012h		;e5cf
	defb 0ffh		;e5d0
	defb 001h		;e5d1
	defb 040h		;e5d2
	defb 002h		;e5d3
	defb 009h		;e5d4
	defb 01bh		;e5d5
	defb 028h		;e5d6
	defb 01eh		;e5d7
	defb 0ffh		;e5d8
	defb 001h		;e5d9
	defb 040h		;e5da
	defb 002h		;e5db
	defb 00fh		;e5dc
	defb 01bh		;e5dd
	defb 04dh		;e5de
	defb 010h		;e5df
	defb 0ffh		;e5e0
	defb 003h		;e5e1
	defb 040h		;e5e2
	defb 003h		;e5e3
RAMDISK:
	defb 008h		;e5e4
	defb 035h		;e5e5
	defb 04dh		;e5e6
	defb 00ah		;e5e7
	defb 0ffh		;e5e8
	defb 003h		;e5e9
	defb 040h		;e5ea
	defb 003h		;e5eb
	defb 005h		;e5ec
	defb 035h		;e5ed
	defb 028h		;e5ee
sub_e5efh:
	defb 014h		;e5ef
	defb 0ffh		;e5f0
	defb 001h		;e5f1
	defb 040h		;e5f2
	defb 002h		;e5f3
	defb 00ah		;e5f4
	defb 00ah		;e5f5
sub_e5f6h:
	defb 050h		;e5f6
	defb 01ah		;e5f7
	defb 07fh		;e5f8
	defb 000h		;e5f9
	defb 000h		;e5fa
	defb 000h		;e5fb
	defb 01ah		;e5fc
sub_e5fdh:
	defb 007h		;e5fd
	defb 04dh		;e5fe
	defb 034h		;e5ff
	defb 0ffh		;e600
	defb 000h		;e601
	defb 040h		;e602
	defb 001h		;e603
	defb 01ah		;e604
	defb 00eh		;e605
	defb 04dh		;e606
	defb 00ah		;e607
	defb 0ffh		;e608
	defb 001h		;e609
	defb 040h		;e60a
	defb 002h		;e60b
	defb 00ah		;e60c
	defb 018h		;e60d
	defb 028h		;e60e
	defb 010h		;e60f
	defb 0ffh		;e610
	defb 003h		;e611
	defb 000h		;e612
	defb 000h		;e613
	defb 010h		;e614
	defb 000h		;e615
	defb 040h		;e616
	defb 000h		;e617
	defb 000h		;e618
	defb 000h		;e619
	defb 000h		;e61a
	defb 000h		;e61b
	defb 000h		;e61c
	defb 000h		;e61d
sub_e61eh:
	defb 000h		;e61e
	defb 081h		;e61f
	defb 0f0h		;e620
	defb 0feh		;e621
	defb 0e6h		;e622
	defb 04eh		;e623
	defb 0f1h		;e624
	defb 001h		;e625
	defb 0f1h		;e626
le627h:
	defb 000h		;e627
	defb 000h		;e628
	defb 000h		;e629
	defb 000h		;e62a
	defb 000h		;e62b
	defb 000h		;e62c
	defb 000h		;e62d
	defb 000h		;e62e
	defb 081h		;e62f
	defb 0f0h		;e630
	defb 0feh		;e631
	defb 0e6h		;e632
	defb 01bh		;e633
	defb 0f2h		;e634
	defb 0ceh		;e635
	defb 0f1h		;e636
	defb 000h		;e637
	defb 000h		;e638
	defb 000h		;e639
	defb 000h		;e63a
	defb 000h		;e63b
	defb 000h		;e63c
	defb 000h		;e63d
	defb 000h		;e63e
	defb 081h		;e63f
	defb 0f0h		;e640
	defb 00dh		;e641
	defb 0e7h		;e642
	defb 0e8h		;e643
	defb 0f2h		;e644
	defb 09bh		;e645
	defb 0f2h		;e646
	defb 000h		;e647
	defb 000h		;e648
	defb 000h		;e649
	defb 000h		;e64a
	defb 000h		;e64b
	defb 000h		;e64c
	defb 000h		;e64d
	defb 000h		;e64e
	defb 081h		;e64f
	defb 0f0h		;e650
	defb 0feh		;e651
	defb 0e6h		;e652
	defb 0b5h		;e653
	defb 0f3h		;e654
	defb 068h		;e655
	defb 0f3h		;e656
	defb 000h		;e657
	defb 000h		;e658
	defb 000h		;e659
	defb 000h		;e65a
	defb 000h		;e65b
	defb 000h		;e65c
	defb 000h		;e65d
	defb 000h		;e65e
	defb 081h		;e65f
	defb 0f0h		;e660
	defb 076h		;e661
	defb 0e7h		;e662
	defb 000h		;e663
	defb 000h		;e664
	defb 035h		;e665
	defb 0f4h		;e666
	defb 001h		;e667
	defb 007h		;e668
	defb 00dh		;e669
	defb 013h		;e66a
	defb 019h		;e66b
	defb 005h		;e66c
	defb 00bh		;e66d
	defb 011h		;e66e
	defb 017h		;e66f
	defb 003h		;e670
	defb 009h		;e671
	defb 00fh		;e672
	defb 015h		;e673
ISR_RAMD:
	defb 002h		;e674
	defb 008h		;e675
	defb 00eh		;e676
	defb 014h		;e677
	defb 01ah		;e678
	defb 006h		;e679
	defb 00ch		;e67a
	defb 012h		;e67b
	defb 018h		;e67c
	defb 004h		;e67d
	defb 00ah		;e67e
	defb 010h		;e67f
	defb 016h		;e680
	defb 001h		;e681
	defb 005h		;e682
	defb 009h		;e683
	defb 00dh		;e684
	defb 002h		;e685
	defb 006h		;e686
	defb 00ah		;e687
	defb 00eh		;e688
	defb 003h		;e689
	defb 007h		;e68a
	defb 00bh		;e68b
	defb 00fh		;e68c
	defb 004h		;e68d
	defb 008h		;e68e
	defb 00ch		;e68f
	defb 001h		;e690
	defb 003h		;e691
	defb 005h		;e692
	defb 007h		;e693
	defb 009h		;e694
	defb 002h		;e695
	defb 004h		;e696
	defb 006h		;e697
	defb 008h		;e698
	defb 00ah		;e699
	defb 001h		;e69a
	defb 002h		;e69b
	defb 003h		;e69c
	defb 004h		;e69d
	defb 005h		;e69e
	defb 006h		;e69f
	defb 007h		;e6a0
	defb 008h		;e6a1
le6a2h:
	defb 009h		;e6a2
	defb 00ah		;e6a3
	defb 00bh		;e6a4
	defb 00ch		;e6a5
sub_e6a6h:
	defb 00dh		;e6a6
	defb 00eh		;e6a7
	defb 00fh		;e6a8
	defb 010h		;e6a9
	defb 011h		;e6aa
	defb 012h		;e6ab
	defb 013h		;e6ac
	defb 014h		;e6ad
	defb 015h		;e6ae
	defb 016h		;e6af
	defb 017h		;e6b0
	defb 018h		;e6b1
	defb 019h		;e6b2
	defb 01ah		;e6b3
sub_e6b4h:
	defb 001h		;e6b4
	defb 004h		;e6b5
	defb 007h		;e6b6
	defb 00ah		;e6b7
	defb 003h		;e6b8
	defb 006h		;e6b9
	defb 009h		;e6ba
	defb 002h		;e6bb
	defb 005h		;e6bc
	defb 008h		;e6bd
	defb 000h		;e6be
disktab_end:
DPBINIT:

; BLOCK 'code010' (start 0xe6bf end 0xe975)
code010_start:
	ld hl,le93fh		;e6bf
	ld de,le940h		;e6c2
	ld bc,000b9h		;e6c5
	ld (hl),000h		;e6c8
	ldir			;e6ca
	ld a,(ld48eh)		;e6cc
	cp 05ah			;e6cf
	ret nz			;e6d1
	ld (0da8eh),a		;e6d2
	ld (lf805h),a		;e6d5
	ld a,(lda47h)		;e6d8
	ld c,a			;e6db
	push af			;e6dc
	call SELDSK		;e6dd
	ld bc,00001h		;e6e0
	ld (lf483h),bc		;e6e3
	ld de,04000h		;e6e7
	ld bc,0002ch		;e6ea
	pop af			;e6ed
	and 007h		;e6ee
	ld a,007h		;e6f0
	jr z,le6f7h		;e6f2
	ld bc,0046ch		;e6f4
le6f7h:
	push de			;e6f7
	push bc			;e6f8
	push af			;e6f9
	ld (lf49eh),de		;e6fa
	ld (lf485h),bc		;e6fe
	call READ		;e702
	pop af			;e705
	pop bc			;e706
	pop de			;e707
	ld hl,00080h		;e708
	add hl,de		;e70b
	ex de,hl		;e70c
	inc c			;e70d
	dec a			;e70e
	jr nz,le6f7h		;e70f
	ld hl,04000h		;e711
	ld a,(hl)		;e714
	cp 0c3h			;e715
	ret nz			;e717
	ld de,lf580h		;e718
	ld bc,00100h		;e71b
	ldir			;e71e
	ld de,(lf598h)		;e720
	ld a,d			;e724
	or e			;e725
	jr z,le741h		;e726
	ld l,e			;e728
	ld h,d			;e729
	ld bc,00004h		;e72a
	add hl,bc		;e72d
	push hl			;e72e
	ld a,l			;e72f
	ld (de),a		;e730
	inc de			;e731
	ld a,h			;e732
	ld (de),a		;e733
	inc de			;e734
	ld a,(lf59ah)		;e735
	ld c,a			;e738
	ld (de),a		;e739
	inc de			;e73a
	ld hl,04100h		;e73b
	inc de			;e73e
	ldir			;e73f
le741h:
	ld hl,04200h		;e741
	ld de,(lf595h)		;e744
	ld a,e			;e748
	or d			;e749
	jr z,le75eh		;e74a
	ld bc,(lf597h)		;e74c
	xor a			;e750
	or c			;e751
	jr z,le75eh		;e752
	ld b,c			;e754
	ld c,012h		;e755
	xor a			;e757
le758h:
	add a,c			;e758
	djnz le758h		;e759
	ld c,a			;e75b
	ldir			;e75c
le75eh:
	ld hl,04300h		;e75e
	ld de,(lf589h)		;e761
	ld a,e			;e765
	or d			;e766
	jr z,le773h		;e767
	ld bc,(lf58bh)		;e769
	sla c			;e76d
	ld b,000h		;e76f
	ldir			;e771
le773h:
	pop hl			;e773
	call 0daach		;e774
	ret			;e777
	nop			;e778
	nop			;e779
le77ah:
	nop			;e77a
le77bh:
	nop			;e77b
	nop			;e77c
	nop			;e77d
	nop			;e77e
	nop			;e77f
	nop			;e780
	nop			;e781
	nop			;e782
	nop			;e783
	nop			;e784
le785h:
	nop			;e785
	nop			;e786
	nop			;e787
	nop			;e788
	nop			;e789
	nop			;e78a
	nop			;e78b
	nop			;e78c
	nop			;e78d
	nop			;e78e
le78fh:
	nop			;e78f
	nop			;e790
	nop			;e791
	nop			;e792
	nop			;e793
	nop			;e794
	nop			;e795
	nop			;e796
	nop			;e797
	nop			;e798
	nop			;e799
	nop			;e79a
	nop			;e79b
	nop			;e79c
	nop			;e79d
	nop			;e79e
	nop			;e79f
	nop			;e7a0
	nop			;e7a1
	nop			;e7a2
	nop			;e7a3
	nop			;e7a4
	nop			;e7a5
	nop			;e7a6
	nop			;e7a7
	nop			;e7a8
	nop			;e7a9
	nop			;e7aa
	nop			;e7ab
	nop			;e7ac
	nop			;e7ad
	nop			;e7ae
	nop			;e7af
	nop			;e7b0
	nop			;e7b1
	nop			;e7b2
	nop			;e7b3
	nop			;e7b4
	nop			;e7b5
	nop			;e7b6
	nop			;e7b7
	nop			;e7b8
	nop			;e7b9
	nop			;e7ba
	nop			;e7bb
	nop			;e7bc
	nop			;e7bd
	nop			;e7be
	nop			;e7bf
	nop			;e7c0
	nop			;e7c1
	nop			;e7c2
	nop			;e7c3
	nop			;e7c4
	nop			;e7c5
	nop			;e7c6
	nop			;e7c7
	nop			;e7c8
	nop			;e7c9
	nop			;e7ca
	nop			;e7cb
	nop			;e7cc
	nop			;e7cd
	nop			;e7ce
	nop			;e7cf
	nop			;e7d0
	nop			;e7d1
	nop			;e7d2
	nop			;e7d3
	nop			;e7d4
	nop			;e7d5
	nop			;e7d6
	nop			;e7d7
	nop			;e7d8
	nop			;e7d9
	nop			;e7da
	nop			;e7db
	nop			;e7dc
	nop			;e7dd
	nop			;e7de
	nop			;e7df
	nop			;e7e0
	nop			;e7e1
	nop			;e7e2
	nop			;e7e3
	nop			;e7e4
	nop			;e7e5
	nop			;e7e6
	nop			;e7e7
	nop			;e7e8
	nop			;e7e9
	nop			;e7ea
	nop			;e7eb
	nop			;e7ec
	nop			;e7ed
	nop			;e7ee
	nop			;e7ef
	nop			;e7f0
	nop			;e7f1
	nop			;e7f2
	nop			;e7f3
	nop			;e7f4
	nop			;e7f5
	nop			;e7f6
	nop			;e7f7
	nop			;e7f8
	nop			;e7f9
	nop			;e7fa
	nop			;e7fb
	nop			;e7fc
	nop			;e7fd
	nop			;e7fe
	nop			;e7ff
	nop			;e800
	nop			;e801
	nop			;e802
	nop			;e803
	nop			;e804
	nop			;e805
	nop			;e806
	nop			;e807
	nop			;e808
	nop			;e809
	nop			;e80a
	nop			;e80b
	nop			;e80c
	nop			;e80d
	nop			;e80e
	nop			;e80f
	nop			;e810
	nop			;e811
	nop			;e812
	nop			;e813
	nop			;e814
	nop			;e815
	nop			;e816
	nop			;e817
	nop			;e818
	nop			;e819
	nop			;e81a
	nop			;e81b
	nop			;e81c
	nop			;e81d
	nop			;e81e
	nop			;e81f
	nop			;e820
	nop			;e821
	nop			;e822
	nop			;e823
	nop			;e824
	nop			;e825
	nop			;e826
	nop			;e827
	nop			;e828
	nop			;e829
	nop			;e82a
	nop			;e82b
	nop			;e82c
	nop			;e82d
	nop			;e82e
	nop			;e82f
	nop			;e830
	nop			;e831
	nop			;e832
	nop			;e833
	nop			;e834
	nop			;e835
	nop			;e836
	nop			;e837
	nop			;e838
	nop			;e839
	nop			;e83a
	nop			;e83b
	nop			;e83c
	nop			;e83d
	nop			;e83e
	nop			;e83f
le840h:
	nop			;e840
	nop			;e841
	nop			;e842
	nop			;e843
	nop			;e844
	nop			;e845
	nop			;e846
	nop			;e847
	nop			;e848
	nop			;e849
	nop			;e84a
	nop			;e84b
	nop			;e84c
	nop			;e84d
	nop			;e84e
	nop			;e84f
	nop			;e850
	nop			;e851
	nop			;e852
	nop			;e853
	nop			;e854
	nop			;e855
	nop			;e856
	nop			;e857
	nop			;e858
	nop			;e859
	nop			;e85a
	nop			;e85b
	nop			;e85c
	nop			;e85d
	nop			;e85e
	nop			;e85f
	nop			;e860
	nop			;e861
	nop			;e862
	nop			;e863
	nop			;e864
	nop			;e865
	nop			;e866
	nop			;e867
	nop			;e868
	nop			;e869
	nop			;e86a
	nop			;e86b
	nop			;e86c
	nop			;e86d
	nop			;e86e
	nop			;e86f
	nop			;e870
	nop			;e871
	nop			;e872
	nop			;e873
	nop			;e874
	nop			;e875
	nop			;e876
	nop			;e877
	nop			;e878
	nop			;e879
	nop			;e87a
	nop			;e87b
	nop			;e87c
	nop			;e87d
	nop			;e87e
	nop			;e87f
	nop			;e880
	nop			;e881
	nop			;e882
	nop			;e883
	nop			;e884
	nop			;e885
	nop			;e886
	nop			;e887
	nop			;e888
	nop			;e889
	nop			;e88a
	nop			;e88b
	nop			;e88c
	nop			;e88d
	nop			;e88e
	nop			;e88f
	nop			;e890
	nop			;e891
	nop			;e892
	nop			;e893
	nop			;e894
	nop			;e895
	nop			;e896
le897h:
	nop			;e897
	nop			;e898
	nop			;e899
	nop			;e89a
	nop			;e89b
	nop			;e89c
	nop			;e89d
	nop			;e89e
	nop			;e89f
	nop			;e8a0
	nop			;e8a1
	nop			;e8a2
	nop			;e8a3
	nop			;e8a4
	nop			;e8a5
	nop			;e8a6
	nop			;e8a7
	nop			;e8a8
	nop			;e8a9
	nop			;e8aa
	nop			;e8ab
	nop			;e8ac
	nop			;e8ad
	nop			;e8ae
	nop			;e8af
	nop			;e8b0
	nop			;e8b1
	nop			;e8b2
	nop			;e8b3
	nop			;e8b4
	nop			;e8b5
	nop			;e8b6
	nop			;e8b7
	nop			;e8b8
	nop			;e8b9
	nop			;e8ba
	nop			;e8bb
	nop			;e8bc
	nop			;e8bd
	nop			;e8be
	nop			;e8bf
	nop			;e8c0
	nop			;e8c1
	nop			;e8c2
	nop			;e8c3
	nop			;e8c4
	nop			;e8c5
	nop			;e8c6
	nop			;e8c7
	nop			;e8c8
	nop			;e8c9
	nop			;e8ca
	nop			;e8cb
	nop			;e8cc
	nop			;e8cd
	nop			;e8ce
	nop			;e8cf
	nop			;e8d0
	nop			;e8d1
	nop			;e8d2
	nop			;e8d3
	nop			;e8d4
	nop			;e8d5
	nop			;e8d6
	nop			;e8d7
	nop			;e8d8
	nop			;e8d9
	nop			;e8da
	nop			;e8db
	nop			;e8dc
	nop			;e8dd
	nop			;e8de
	nop			;e8df
	nop			;e8e0
	nop			;e8e1
	nop			;e8e2
	nop			;e8e3
	nop			;e8e4
	nop			;e8e5
	nop			;e8e6
	nop			;e8e7
	nop			;e8e8
	nop			;e8e9
	nop			;e8ea
	nop			;e8eb
	nop			;e8ec
	nop			;e8ed
	nop			;e8ee
	nop			;e8ef
	nop			;e8f0
	nop			;e8f1
	nop			;e8f2
	nop			;e8f3
	nop			;e8f4
	nop			;e8f5
	nop			;e8f6
	nop			;e8f7
	nop			;e8f8
	nop			;e8f9
	nop			;e8fa
	nop			;e8fb
	nop			;e8fc
	nop			;e8fd
	nop			;e8fe
	nop			;e8ff
	nop			;e900
	nop			;e901
	nop			;e902
	nop			;e903
	nop			;e904
	nop			;e905
	nop			;e906
	nop			;e907
	nop			;e908
	nop			;e909
	nop			;e90a
	nop			;e90b
	nop			;e90c
	nop			;e90d
	nop			;e90e
	nop			;e90f
	nop			;e910
	nop			;e911
	nop			;e912
	nop			;e913
	nop			;e914
	nop			;e915
	nop			;e916
	nop			;e917
	nop			;e918
	nop			;e919
	nop			;e91a
	nop			;e91b
	nop			;e91c
	nop			;e91d
	nop			;e91e
	nop			;e91f
	nop			;e920
	nop			;e921
	nop			;e922
	nop			;e923
	nop			;e924
	nop			;e925
	nop			;e926
	nop			;e927
	nop			;e928
	nop			;e929
	nop			;e92a
	nop			;e92b
	nop			;e92c
	nop			;e92d
	nop			;e92e
	nop			;e92f
	nop			;e930
	nop			;e931
	nop			;e932
	nop			;e933
	nop			;e934
	nop			;e935
	nop			;e936
	nop			;e937
	nop			;e938
	nop			;e939
	nop			;e93a
	nop			;e93b
	nop			;e93c
	nop			;e93d
	nop			;e93e
le93fh:
	nop			;e93f
le940h:
	nop			;e940
	nop			;e941
	nop			;e942
	nop			;e943
	nop			;e944
	nop			;e945
	nop			;e946
	nop			;e947
	nop			;e948
	nop			;e949
	nop			;e94a
	nop			;e94b
	nop			;e94c
	nop			;e94d
	nop			;e94e
	nop			;e94f
	nop			;e950
	nop			;e951
	nop			;e952
	nop			;e953
	nop			;e954
	nop			;e955
	nop			;e956
	nop			;e957
	nop			;e958
	nop			;e959
	nop			;e95a
	nop			;e95b
	nop			;e95c
	nop			;e95d
	nop			;e95e
	nop			;e95f
	nop			;e960
	nop			;e961
	nop			;e962
	nop			;e963
	nop			;e964
	nop			;e965
	nop			;e966
	nop			;e967
	nop			;e968
	nop			;e969
	nop			;e96a
	nop			;e96b
	nop			;e96c
	nop			;e96d
	nop			;e96e
	nop			;e96f
	nop			;e970
	nop			;e971
	nop			;e972
	nop			;e973
	nop			;e974
code010_end:
IVTPAD:

; BLOCK 'ivtpad' (start 0xe975 end 0xe980)
ivtpad_start:
	defb 000h		;e975
	defb 000h		;e976
	defb 000h		;e977
	defb 000h		;e978
	defb 000h		;e979
	defb 000h		;e97a
	defb 000h		;e97b
	defb 000h		;e97c
	defb 000h		;e97d
	defb 000h		;e97e
	defb 000h		;e97f
ivtpad_end:
INTVEC:

; BLOCK 'intvec' (start 0xe980 end 0xe9a0)
intvec_start:
	defw 0ec61h		;e980
	defw 0ec61h		;e982
	defw 0e0b1h		;e984
	defw 0e674h		;e986
	defw 0ec61h		;e988
	defw 0ec61h		;e98a
	defw 0ec61h		;e98c
	defw 0ec61h		;e98e
	defw 0dcech		;e990
	defw 0dd05h		;e992
	defw 0dd1eh		;e994
	defw 0dd38h		;e996
	defw 0dd5dh		;e998
	defw 0dd76h		;e99a
	defw 0dd8fh		;e99c
	defw 0dda9h		;e99e
intvec_end:
IVTDATA:

; BLOCK 'ivtdata' (start 0xe9a0 end 0xea00)
ivtdata_start:
	defb 042h		;e9a0
	defb 0ech		;e9a1
	defb 064h		;e9a2
	defb 0ech		;e9a3
	defb 000h		;e9a4
	defb 0ech		;e9a5
	defb 000h		;e9a6
	defb 000h		;e9a7
	defb 03ah		;e9a8
	defb 026h		;e9a9
	defb 0ech		;e9aa
	defb 0c9h		;e9ab
	defb 03ah		;e9ac
	defb 026h		;e9ad
	defb 0ech		;e9ae
	defb 0b7h		;e9af
	defb 028h		;e9b0
	defb 0fah		;e9b1
	defb 0f3h		;e9b2
	defb 0afh		;e9b3
	defb 032h		;e9b4
	defb 026h		;e9b5
	defb 0ech		;e9b6
	defb 0fbh		;e9b7
	defb 0dbh		;e9b8
	defb 010h		;e9b9
	defb 04fh		;e9ba
	defb 021h		;e9bb
	defb 000h		;e9bc
	defb 0f7h		;e9bd
	defb 0cdh		;e9be
	defb 0ebh		;e9bf
	defb 0ddh		;e9c0
	defb 0c9h		;e9c1
	defb 0edh		;e9c2
	defb 073h		;e9c3
	defb 0b2h		;e9c4
	defb 0f4h		;e9c5
	defb 031h		;e9c6
	defb 01eh		;e9c7
	defb 0f5h		;e9c8
	defb 0f5h		;e9c9
	defb 03eh		;e9ca
	defb 0ffh		;e9cb
	defb 032h		;e9cc
	defb 026h		;e9cd
	defb 0ech		;e9ce
	defb 0e5h		;e9cf
	defb 0cdh		;e9d0
	defb 065h		;e9d1
	defb 0e0h		;e9d2
	defb 0e1h		;e9d3
	defb 020h		;e9d4
	defb 006h		;e9d5
	defb 03ah		;e9d6
	defb 0d6h		;e9d7
	defb 0f4h		;e9d8
	defb 032h		;e9d9
	defb 000h		;e9da
	defb 0f8h		;e9db
	defb 0f1h		;e9dc
	defb 0edh		;e9dd
	defb 07bh		;e9de
	defb 0b2h		;e9df
	defb 0f4h		;e9e0
	defb 0fbh		;e9e1
	defb 0edh		;e9e2
	defb 04dh		;e9e3
	defb 0edh		;e9e4
	defb 073h		;e9e5
	defb 0b2h		;e9e6
	defb 0f4h		;e9e7
	defb 031h		;e9e8
	defb 01eh		;e9e9
	defb 0f5h		;e9ea
	defb 0f5h		;e9eb
	defb 03eh		;e9ec
	defb 0ffh		;e9ed
	defb 032h		;e9ee
	defb 027h		;e9ef
	defb 0ech		;e9f0
	defb 0f1h		;e9f1
	defb 0edh		;e9f2
	defb 073h		;e9f3
	defb 0b2h		;e9f4
	defb 0f4h		;e9f5
	defb 0fbh		;e9f6
	defb 0edh		;e9f7
	defb 04dh		;e9f8
	defb 082h		;e9f9
	defb 084h		;e9fa
	defb 08bh		;e9fb
	defb 000h		;e9fc
	defb 000h		;e9fd
	defb 000h		;e9fe
	defb 000h		;e9ff
ivtdata_end:
VERIFY:

; BLOCK 'verify' (start 0xea00 end 0xfa00)
verify_start:
	defb 027h		;ea00
	defb 021h		;ea01
	defb 090h		;ea02
	defb 016h		;ea03
	defb 0e5h		;ea04
	defb 0cdh		;ea05
	defb 043h		;ea06
	defb 027h		;ea07
	defb 0cdh		;ea08
	defb 06ah		;ea09
	defb 00bh		;ea0a
	defb 026h		;ea0b
	defb 020h		;ea0c
	defb 020h		;ea0d
	defb 056h		;ea0e
	defb 045h		;ea0f
	defb 052h		;ea10
	defb 049h		;ea11
	defb 046h		;ea12
	defb 059h		;ea13
	defb 020h		;ea14
	defb 043h		;ea15
	defb 048h		;ea16
	defb 045h		;ea17
	defb 043h		;ea18
	defb 04bh		;ea19
	defb 020h		;ea1a
	defb 052h		;ea1b
	defb 045h		;ea1c
	defb 041h		;ea1d
	defb 044h		;ea1e
	defb 049h		;ea1f
	defb 04eh		;ea20
	defb 047h		;ea21
	defb 020h		;ea22
	defb 041h		;ea23
	defb 042h		;ea24
	defb 04fh		;ea25
	defb 052h		;ea26
	defb 054h		;ea27
	defb 045h		;ea28
	defb 044h		;ea29
	defb 020h		;ea2a
	defb 042h		;ea2b
	defb 059h		;ea2c
	defb 020h		;ea2d
	defb 055h		;ea2e
	defb 053h		;ea2f
	defb 045h		;ea30
	defb 052h		;ea31
	defb 0cdh		;ea32
	defb 036h		;ea33
	defb 027h		;ea34
	defb 0cdh		;ea35
	defb 0b3h		;ea36
	defb 027h		;ea37
	defb 0cdh		;ea38
	defb 0dah		;ea39
	defb 024h		;ea3a
	defb 0cdh		;ea3b
	defb 049h		;ea3c
	defb 027h		;ea3d
	defb 021h		;ea3e
	defb 090h		;ea3f
	defb 016h		;ea40
	defb 0e5h		;ea41
	defb 0cdh		;ea42
	defb 043h		;ea43
	defb 027h		;ea44
	defb 0cdh		;ea45
	defb 083h		;ea46
	defb 00bh		;ea47
	defb 002h		;ea48
	defb 020h		;ea49
	defb 020h		;ea4a
	defb 0cdh		;ea4b
	defb 036h		;ea4c
	defb 027h		;ea4d
	defb 0cdh		;ea4e
	defb 0b3h		;ea4f
	defb 027h		;ea50
	defb 02ah		;ea51
	defb 07eh		;ea52
	defb 015h		;ea53
	defb 0e5h		;ea54
	defb 0cdh		;ea55
	defb 036h		;ea56
	defb 027h		;ea57
	defb 0cdh		;ea58
	defb 0e7h		;ea59
	defb 024h		;ea5a
	defb 0cdh		;ea5b
	defb 0b5h		;ea5c
	defb 00bh		;ea5d
	defb 01eh		;ea5e
	defb 020h		;ea5f
	defb 042h		;ea60
	defb 04ch		;ea61
	defb 04fh		;ea62
	defb 043h		;ea63
	defb 04bh		;ea64
	defb 053h		;ea65
	defb 020h		;ea66
	defb 046h		;ea67
	defb 04fh		;ea68
	defb 055h		;ea69
	defb 04eh		;ea6a
	defb 044h		;ea6b
	defb 020h		;ea6c
	defb 057h		;ea6d
	defb 049h		;ea6e
	defb 054h		;ea6f
	defb 048h		;ea70
	defb 020h		;ea71
	defb 042h		;ea72
	defb 041h		;ea73
	defb 044h		;ea74
	defb 020h		;ea75
	defb 053h		;ea76
	defb 045h		;ea77
	defb 043h		;ea78
	defb 054h		;ea79
	defb 04fh		;ea7a
	defb 052h		;ea7b
	defb 053h		;ea7c
	defb 0cdh		;ea7d
	defb 036h		;ea7e
	defb 027h		;ea7f
	defb 0cdh		;ea80
	defb 0b3h		;ea81
	defb 027h		;ea82
	defb 0cdh		;ea83
	defb 0dah		;ea84
	defb 024h		;ea85
	defb 0cdh		;ea86
	defb 049h		;ea87
	defb 027h		;ea88
	defb 0cdh		;ea89
	defb 013h		;ea8a
	defb 001h		;ea8b
	defb 0c9h		;ea8c
	defb 0cdh		;ea8d
	defb 097h		;ea8e
	defb 016h		;ea8f
	defb 0e1h		;ea90
	defb 07dh		;ea91
	defb 032h		;ea92
	defb 08ch		;ea93
	defb 015h		;ea94
	defb 03ah		;ea95
	defb 08ch		;ea96
	defb 015h		;ea97
	defb 026h		;ea98
	defb 000h		;ea99
	defb 06fh		;ea9a
	defb 0e5h		;ea9b
	defb 021h		;ea9c
	defb 003h		;ea9d
	defb 000h		;ea9e
	defb 0e5h		;ea9f
	defb 0cdh		;eaa0
	defb 0f5h		;eaa1
	defb 026h		;eaa2
	defb 0f1h		;eaa3
	defb 0d2h		;eaa4
	defb 0e2h		;eaa5
	defb 00bh		;eaa6
	defb 0c3h		;eaa7
	defb 042h		;eaa8
	defb 00ch		;eaa9
	defb 021h		;eaaa
	defb 090h		;eaab
	defb 016h		;eaac
	defb 0e5h		;eaad
	defb 0cdh		;eaae
	defb 043h		;eaaf
	defb 027h		;eab0
	defb 0cdh		;eab1
	defb 0dah		;eab2
	defb 024h		;eab3
	defb 0cdh		;eab4
	defb 049h		;eab5
	defb 027h		;eab6
	defb 021h		;eab7
	defb 090h		;eab8
	defb 016h		;eab9
	defb 0e5h		;eaba
	defb 0cdh		;eabb
	defb 043h		;eabc
	defb 027h		;eabd
	defb 0cdh		;eabe
	defb 0dah		;eabf
	defb 024h		;eac0
	defb 0cdh		;eac1
	defb 049h		;eac2
	defb 027h		;eac3
	defb 021h		;eac4
	defb 090h		;eac5
	defb 016h		;eac6
	defb 0e5h		;eac7
	defb 0cdh		;eac8
	defb 043h		;eac9
	defb 027h		;eaca
	defb 0cdh		;eacb
	defb 033h		;eacc
	defb 00ch		;eacd
	defb 02ch		;eace
	defb 020h		;eacf
	defb 020h		;ead0
	defb 056h		;ead1
	defb 045h		;ead2
	defb 052h		;ead3
	defb 049h		;ead4
	defb 046h		;ead5
	defb 059h		;ead6
	defb 020h		;ead7
	defb 044h		;ead8
	defb 055h		;ead9
	defb 04dh		;eada
	defb 04dh		;eadb
	defb 059h		;eadc
	defb 020h		;eadd
	defb 046h		;eade
	defb 049h		;eadf
	defb 04ch		;eae0
	defb 045h		;eae1
	defb 020h		;eae2
	defb 043h		;eae3
	defb 052h		;eae4
	defb 045h		;eae5
	defb 041h		;eae6
	defb 054h		;eae7
	defb 049h		;eae8
	defb 04fh		;eae9
	defb 04eh		;eaea
	defb 020h		;eaeb
	defb 053h		;eaec
	defb 054h		;eaed
	defb 04fh		;eaee
	defb 050h		;eaef
	defb 050h		;eaf0
	defb 045h		;eaf1
	defb 044h		;eaf2
	defb 020h		;eaf3
	defb 042h		;eaf4
	defb 059h		;eaf5
	defb 020h		;eaf6
	defb 055h		;eaf7
	defb 053h		;eaf8
	defb 045h		;eaf9
	defb 052h		;eafa
	defb 0cdh		;eafb
	defb 036h		;eafc
	defb 027h		;eafd
	defb 0cdh		;eafe
	defb 0b3h		;eaff
	defb 027h		;eb00
	defb 0cdh		;eb01
	defb 0dah		;eb02
	defb 024h		;eb03
	defb 0cdh		;eb04
	defb 049h		;eb05
	defb 027h		;eb06
	defb 0cdh		;eb07
	defb 013h		;eb08
	defb 001h		;eb09
	defb 0c9h		;eb0a
	defb 02ah		;eb0b
	defb 006h		;eb0c
	defb 000h		;eb0d
	defb 0f9h		;eb0e
	defb 0cdh		;eb0f
	defb 024h		;eb10
	defb 017h		;eb11
	defb 0cdh		;eb12
	defb 016h		;eb13
	defb 001h		;eb14
	defb 021h		;eb15
	defb 000h		;eb16
	defb 000h		;eb17
	defb 022h		;eb18
	defb 07eh		;eb19
	defb 015h		;eb1a
	defb 02ah		;eb1b
	defb 084h		;eb1c
	defb 015h		;eb1d
	defb 0e5h		;eb1e
	defb 021h		;eb1f
	defb 002h		;eb20
	defb 000h		;eb21
	defb 0e5h		;eb22
	defb 0cdh		;eb23
	defb 015h		;eb24
	defb 027h		;eb25
	defb 0f1h		;eb26
	defb 0d2h		;eb27
	defb 014h		;eb28
	defb 00dh		;eb29
	defb 021h		;eb2a
	defb 090h		;eb2b
	defb 016h		;eb2c
	defb 0e5h		;eb2d
	defb 0cdh		;eb2e
	defb 043h		;eb2f
	defb 027h		;eb30
	defb 0cdh		;eb31
	defb 0dah		;eb32
	defb 024h		;eb33
	defb 0cdh		;eb34
	defb 049h		;eb35
	defb 027h		;eb36
	defb 021h		;eb37
	defb 090h		;eb38
	defb 016h		;eb39
	defb 0e5h		;eb3a
	defb 0cdh		;eb3b
	defb 043h		;eb3c
	defb 027h		;eb3d
	defb 0cdh		;eb3e
	defb 09fh		;eb3f
	defb 00ch		;eb40
	defb 025h		;eb41
	defb 020h		;eb42
	defb 020h		;eb43
	defb 049h		;eb44
	defb 04eh		;eb45
	defb 053h		;eb46
	defb 045h		;eb47
	defb 052h		;eb48
	defb 054h		;eb49
	defb 020h		;eb4a
	defb 046h		;eb4b
	defb 04fh		;eb4c
	defb 052h		;eb4d
	defb 04dh		;eb4e
	defb 041h		;eb4f
	defb 054h		;eb50
	defb 054h		;eb51
	defb 045h		;eb52
	defb 044h		;eb53
	defb 020h		;eb54
	defb 044h		;eb55
	defb 049h		;eb56
	defb 053h		;eb57
	defb 04bh		;eb58
	defb 045h		;eb59
	defb 054h		;eb5a
	defb 054h		;eb5b
	defb 045h		;eb5c
	defb 020h		;eb5d
	defb 049h		;eb5e
	defb 04eh		;eb5f
	defb 020h		;eb60
	defb 044h		;eb61
	defb 052h		;eb62
	defb 049h		;eb63
	defb 056h		;eb64
	defb 045h		;eb65
	defb 020h		;eb66
	defb 0cdh		;eb67
	defb 036h		;eb68
	defb 027h		;eb69
	defb 0cdh		;eb6a
	defb 0b3h		;eb6b
	defb 027h		;eb6c
	defb 021h		;eb6d
	defb 041h		;eb6e
	defb 000h		;eb6f
	defb 0ebh		;eb70
	defb 02ah		;eb71
	defb 084h		;eb72
	defb 015h		;eb73
	defb 019h		;eb74
	defb 0e5h		;eb75
	defb 0cdh		;eb76
	defb 036h		;eb77
	defb 027h		;eb78
	defb 0cdh		;eb79
	defb 0ebh		;eb7a
	defb 029h		;eb7b
	defb 0cdh		;eb7c
	defb 0cbh		;eb7d
	defb 00ch		;eb7e
	defb 013h		;eb7f
	defb 020h		;eb80
	defb 041h		;eb81
	defb 04eh		;eb82
	defb 044h		;eb83
	defb 020h		;eb84
	defb 054h		;eb85
	defb 059h		;eb86
	defb 050h		;eb87
	defb 045h		;eb88
	defb 020h		;eb89
	defb 03ch		;eb8a
	defb 052h		;eb8b
	defb 045h		;eb8c
	defb 054h		;eb8d
	defb 055h		;eb8e
	defb 052h		;eb8f
	defb 04eh		;eb90
	defb 03eh		;eb91
	defb 020h		;eb92
	defb 0cdh		;eb93
	defb 036h		;eb94
	defb 027h		;eb95
	defb 0cdh		;eb96
	defb 0b3h		;eb97
	defb 027h		;eb98
	defb 0cdh		;eb99
	defb 049h		;eb9a
	defb 027h		;eb9b
	defb 021h		;eb9c
	defb 097h		;eb9d
	defb 016h		;eb9e
	defb 0e5h		;eb9f
	defb 0cdh		;eba0
	defb 03dh		;eba1
	defb 027h		;eba2
	defb 021h		;eba3
	defb 08ch		;eba4
	defb 015h		;eba5
	defb 0e5h		;eba6
	defb 0cdh		;eba7
	defb 0cah		;eba8
	defb 024h		;eba9
	defb 0cdh		;ebaa
	defb 049h		;ebab
	defb 027h		;ebac
	defb 021h		;ebad
	defb 090h		;ebae
	defb 016h		;ebaf
	defb 0e5h		;ebb0
	defb 0cdh		;ebb1
	defb 043h		;ebb2
	defb 027h		;ebb3
	defb 0cdh		;ebb4
	defb 0dah		;ebb5
	defb 024h		;ebb6
	defb 0cdh		;ebb7
	defb 049h		;ebb8
	defb 027h		;ebb9
	defb 03ah		;ebba
	defb 08ch		;ebbb
	defb 015h		;ebbc
	defb 026h		;ebbd
	defb 000h		;ebbe
	defb 06fh		;ebbf
	defb 0e5h		;ebc0
	defb 021h		;ebc1
	defb 003h		;ebc2
	defb 000h		;ebc3
	defb 0e5h		;ebc4
	defb 0cdh		;ebc5
	defb 0adh		;ebc6
	defb 026h		;ebc7
	defb 0f1h		;ebc8
	defb 0d2h		;ebc9
	defb 007h		;ebca
	defb 00dh		;ebcb
	defb 0cdh		;ebcc
	defb 013h		;ebcd
	defb 001h		;ebce
	defb 021h		;ebcf
	defb 090h		;ebd0
	defb 016h		;ebd1
	defb 0e5h		;ebd2
	defb 0cdh		;ebd3
	defb 043h		;ebd4
	defb 027h		;ebd5
	defb 0cdh		;ebd6
	defb 0dah		;ebd7
	defb 024h		;ebd8
	defb 0cdh		;ebd9
	defb 049h		;ebda
	defb 027h		;ebdb
	defb 021h		;ebdc
	defb 090h		;ebdd
	defb 016h		;ebde
	defb 0e5h		;ebdf
	defb 0cdh		;ebe0
	defb 043h		;ebe1
	defb 027h		;ebe2
	defb 0cdh		;ebe3
	defb 03eh		;ebe4
	defb 00dh		;ebe5
	defb 01fh		;ebe6
	defb 020h		;ebe7
	defb 020h		;ebe8
	defb 043h		;ebe9
	defb 048h		;ebea
	defb 045h		;ebeb
	defb 043h		;ebec
	defb 04bh		;ebed
	defb 020h		;ebee
	defb 052h		;ebef
	defb 045h		;ebf0
	defb 041h		;ebf1
	defb 044h		;ebf2
	defb 049h		;ebf3
	defb 04eh		;ebf4
	defb 047h		;ebf5
	defb 020h		;ebf6
	defb 043h		;ebf7
	defb 050h		;ebf8
	defb 02fh		;ebf9
	defb 04dh		;ebfa
	defb 020h		;ebfb
	defb 042h		;ebfc
	defb 04ch		;ebfd
	defb 04fh		;ebfe
	defb 043h		;ebff
	defb 04bh		;ec00
	defb 020h		;ec01
	defb 04eh		;ec02
	defb 06fh		;ec03
	defb 02eh		;ec04
	defb 020h		;ec05
	defb 0cdh		;ec06
	defb 036h		;ec07
	defb 027h		;ec08
	defb 0cdh		;ec09
	defb 0b3h		;ec0a
	defb 027h		;ec0b
	defb 021h		;ec0c
	defb 000h		;ec0d
	defb 000h		;ec0e
	defb 0e5h		;ec0f
	defb 021h		;ec10
	defb 003h		;ec11
	defb 000h		;ec12
	defb 0e5h		;ec13
	defb 021h		;ec14
	defb 0ffh		;ec15
	defb 0ffh		;ec16
	defb 0e5h		;ec17
	defb 0cdh		;ec18
	defb 0e7h		;ec19
	defb 024h		;ec1a
	defb 0cdh		;ec1b
	defb 049h		;ec1c
	defb 027h		;ec1d
	defb 021h		;ec1e
	defb 000h		;ec1f
	defb 000h		;ec20
	defb 022h		;ec21
	defb 088h		;ec22
	defb 015h		;ec23
	defb 021h		;ec24
lec25h:
	defb 090h		;ec25
lec26h:
	defb 016h		;ec26
	defb 0e5h		;ec27
CONST:
	defb 0cdh		;ec28
	defb 043h		;ec29
	defb 027h		;ec2a
	defb 021h		;ec2b
CONIN:
	defb 008h		;ec2c
	defb 000h		;ec2d
	defb 0e5h		;ec2e
	defb 0cdh		;ec2f
	defb 036h		;ec30
	defb 027h		;ec31
	defb 0cdh		;ec32
	defb 0ebh		;ec33
	defb 029h		;ec34
	defb 021h		;ec35
	defb 008h		;ec36
	defb 000h		;ec37
	defb 0e5h		;ec38
	defb 0cdh		;ec39
	defb 036h		;ec3a
	defb 027h		;ec3b
	defb 0cdh		;ec3c
	defb 0ebh		;ec3d
	defb 029h		;ec3e
	defb 021h		;ec3f
	defb 008h		;ec40
	defb 000h		;ec41
	defb 0e5h		;ec42
	defb 0cdh		;ec43
	defb 036h		;ec44
	defb 027h		;ec45
	defb 0cdh		;ec46
	defb 0ebh		;ec47
	defb 029h		;ec48
	defb 02ah		;ec49
	defb 088h		;ec4a
	defb 015h		;ec4b
	defb 0e5h		;ec4c
	defb 021h		;ec4d
	defb 003h		;ec4e
	defb 000h		;ec4f
	defb 0e5h		;ec50
	defb 021h		;ec51
	defb 0ffh		;ec52
	defb 0ffh		;ec53
	defb 0e5h		;ec54
	defb 0cdh		;ec55
	defb 0e7h		;ec56
	defb 024h		;ec57
	defb 0cdh		;ec58
	defb 049h		;ec59
	defb 027h		;ec5a
	defb 021h		;ec5b
	defb 09eh		;ec5c
	defb 012h		;ec5d
	defb 0ebh		;ec5e
	defb 02ah		;ec5f
	defb 088h		;ec60
ISR_DEFAULT:
	defb 015h		;ec61
	defb 019h		;ec62
	defb 0e5h		;ec63
	defb 02ah		;ec64
	defb 088h		;ec65
	defb 015h		;ec66
	defb 0e5h		;ec67
	defb 0cdh		;ec68
	defb 019h		;ec69
	defb 001h		;ec6a
	defb 0e1h		;ec6b
	defb 07dh		;ec6c
	defb 02fh		;ec6d
	defb 06fh		;ec6e
	defb 0ebh		;ec6f
	defb 0e1h		;ec70
	defb 073h		;ec71
	defb 021h		;ec72
	defb 09eh		;ec73
	defb 012h		;ec74
	defb 0ebh		;ec75
	defb 02ah		;ec76
	defb 088h		;ec77
	defb 015h		;ec78
	defb 019h		;ec79
	defb 07eh		;ec7a
	defb 01fh		;ec7b
	defb 0d2h		;ec7c
	defb 03eh		;ec7d
	defb 00eh		;ec7e
	defb 02ah		;ec7f
	defb 07eh		;ec80
lec81h:
	defb 015h		;ec81
	defb 023h		;ec82
	defb 022h		;ec83
	defb 07eh		;ec84
	defb 015h		;ec85
	defb 02ah		;ec86
	defb 07eh		;ec87
	defb 015h		;ec88
	defb 0e5h		;ec89
	defb 021h		;ec8a
	defb 001h		;ec8b
	defb 000h		;ec8c
	defb 0e5h		;ec8d
	defb 0cdh		;ec8e
	defb 0adh		;ec8f
	defb 026h		;ec90
	defb 0f1h		;ec91
	defb 0d2h		;ec92
	defb 03eh		;ec93
	defb 00eh		;ec94
	defb 021h		;ec95
	defb 090h		;ec96
	defb 016h		;ec97
	defb 0e5h		;ec98
	defb 0cdh		;ec99
	defb 043h		;ec9a
	defb 027h		;ec9b
	defb 0cdh		;ec9c
	defb 0f4h		;ec9d
	defb 00dh		;ec9e
	defb 01ch		;ec9f
	defb 020h		;eca0
	defb 020h		;eca1
	defb 028h		;eca2
	defb 020h		;eca3
	defb 042h		;eca4
	defb 041h		;eca5
	defb 044h		;eca6
	defb 020h		;eca7
	defb 053h		;eca8
	defb 045h		;eca9
	defb 043h		;ecaa
	defb 054h		;ecab
	defb 04fh		;ecac
	defb 052h		;ecad
	defb 020h		;ecae
	defb 045h		;ecaf
	defb 04eh		;ecb0
	defb 043h		;ecb1
	defb 04fh		;ecb2
	defb 055h		;ecb3
	defb 04eh		;ecb4
	defb 054h		;ecb5
	defb 045h		;ecb6
	defb 052h		;ecb7
	defb 045h		;ecb8
	defb 044h		;ecb9
	defb 020h		;ecba
	defb 029h		;ecbb
	defb 0cdh		;ecbc
	defb 036h		;ecbd
	defb 027h		;ecbe
	defb 0cdh		;ecbf
	defb 0b3h		;ecc0
	defb 027h		;ecc1
	defb 0cdh		;ecc2
	defb 049h		;ecc3
	defb 027h		;ecc4
	defb 021h		;ecc5
	defb 001h		;ecc6
	defb 000h		;ecc7
	defb 0e5h		;ecc8
	defb 021h		;ecc9
	defb 01ch		;ecca
	defb 000h		;eccb
	defb 0e5h		;eccc
	defb 0d1h		;eccd
	defb 0e1h		;ecce
	defb 02bh		;eccf
	defb 022h		;ecd0
	defb 08ah		;ecd1
	defb 015h		;ecd2
	defb 023h		;ecd3
	defb 0e5h		;ecd4
	defb 0d5h		;ecd5
	defb 0cdh		;ecd6
	defb 05eh		;ecd7
	defb 022h		;ecd8
	defb 022h		;ecd9
	defb 0ech		;ecda
	defb 015h		;ecdb
	defb 02ah		;ecdc
	defb 08ah		;ecdd
	defb 015h		;ecde
	defb 023h		;ecdf
	defb 022h		;ece0
	defb 08ah		;ece1
	defb 015h		;ece2
	defb 02ah		;ece3
	defb 0ech		;ece4
	defb 015h		;ece5
	defb 02bh		;ece6
	defb 022h		;ece7
	defb 0ech		;ece8
	defb 015h		;ece9
	defb 07ch		;ecea
	defb 0b5h		;eceb
	defb 0cah		;ecec
	defb 03eh		;eced
	defb 00eh		;ecee
	defb 021h		;ecef
	defb 090h		;ecf0
	defb 016h		;ecf1
	defb 0e5h		;ecf2
	defb 0cdh		;ecf3
	defb 043h		;ecf4
	defb 027h		;ecf5
	defb 021h		;ecf6
	defb 008h		;ecf7
	defb 000h		;ecf8
	defb 0e5h		;ecf9
	defb 0cdh		;ecfa
	defb 036h		;ecfb
	defb 027h		;ecfc
	defb 0cdh		;ecfd
	defb 0ebh		;ecfe
	defb 029h		;ecff
	defb 0cdh		;ed00
	defb 049h		;ed01
	defb 027h		;ed02
	defb 0c3h		;ed03
	defb 014h		;ed04
	defb 00eh		;ed05
	defb 021h		;ed06
	defb 09eh		;ed07
	defb 012h		;ed08
	defb 0ebh		;ed09
	defb 02ah		;ed0a
	defb 088h		;ed0b
	defb 015h		;ed0c
	defb 019h		;ed0d
	defb 016h		;ed0e
	defb 000h		;ed0f
	defb 05eh		;ed10
	defb 0d5h		;ed11
	defb 02ah		;ed12
	defb 088h		;ed13
	defb 015h		;ed14
	defb 0e5h		;ed15
	defb 02ah		;ed16
	defb 080h		;ed17
	defb 015h		;ed18
	defb 0e5h		;ed19
	defb 0cdh		;ed1a
	defb 015h		;ed1b
	defb 027h		;ed1c
	defb 0e1h		;ed1d
	defb 0d1h		;ed1e
	defb 07dh		;ed1f
	defb 0a3h		;ed20
	defb 01fh		;ed21
	defb 0d2h		;ed22
	defb 0adh		;ed23
	defb 00eh		;ed24
	defb 021h		;ed25
	defb 090h		;ed26
	defb 016h		;ed27
	defb 0e5h		;ed28
	defb 0cdh		;ed29
	defb 043h		;ed2a
	defb 027h		;ed2b
	defb 0cdh		;ed2c
	defb 0dah		;ed2d
	defb 024h		;ed2e
	defb 0cdh		;ed2f
	defb 049h		;ed30
	defb 027h		;ed31
	defb 021h		;ed32
	defb 090h		;ed33
	defb 016h		;ed34
	defb 0e5h		;ed35
	defb 0cdh		;ed36
	defb 043h		;ed37
	defb 027h		;ed38
	defb 0cdh		;ed39
	defb 0dah		;ed3a
	defb 024h		;ed3b
	defb 0cdh		;ed3c
	defb 049h		;ed3d
	defb 027h		;ed3e
	defb 021h		;ed3f
	defb 090h		;ed40
	defb 016h		;ed41
	defb 0e5h		;ed42
	defb 0cdh		;ed43
	defb 043h		;ed44
	defb 027h		;ed45
	defb 0cdh		;ed46
	defb 0a1h		;ed47
	defb 00eh		;ed48
	defb 01fh		;ed49
	defb 020h		;ed4a
	defb 020h		;ed4b
	defb 042h		;ed4c
	defb 041h		;ed4d
	defb 044h		;ed4e
	defb 020h		;ed4f
	defb 053h		;ed50
	defb 045h		;ed51
	defb 043h		;ed52
	defb 054h		;ed53
	defb 04fh		;ed54
	defb 052h		;ed55
	defb 020h		;ed56
	defb 046h		;ed57
	defb 04fh		;ed58
	defb 055h		;ed59
	defb 04eh		;ed5a
	defb 044h		;ed5b
	defb 020h		;ed5c
	defb 049h		;ed5d
	defb 04eh		;ed5e
	defb 020h		;ed5f
	defb 044h		;ed60
	defb 049h		;ed61
	defb 052h		;ed62
	defb 045h		;ed63
	defb 043h		;ed64
	defb 054h		;ed65
	defb 04fh		;ed66
	defb 052h		;ed67
	defb 059h		;ed68
	defb 0cdh		;ed69
	defb 036h		;ed6a
	defb 027h		;ed6b
	defb 0cdh		;ed6c
	defb 0b3h		;ed6d
	defb 027h		;ed6e
	defb 0cdh		;ed6f
	defb 0dah		;ed70
	defb 024h		;ed71
	defb 0cdh		;ed72
	defb 049h		;ed73
	defb 027h		;ed74
	defb 0cdh		;ed75
	defb 09fh		;ed76
	defb 016h		;ed77
	defb 0f1h		;ed78
	defb 0d2h		;ed79
	defb 0b7h		;ed7a
	defb 00eh		;ed7b
	defb 0cdh		;ed7c
	defb 028h		;ed7d
	defb 001h		;ed7e
	defb 02ah		;ed7f
	defb 088h		;ed80
	defb 015h		;ed81
	defb 023h		;ed82
	defb 022h		;ed83
	defb 088h		;ed84
	defb 015h		;ed85
	defb 02ah		;ed86
	defb 088h		;ed87
	defb 015h		;ed88
	defb 0e5h		;ed89
	defb 02ah		;ed8a
	defb 0f8h		;ed8b
	defb 014h		;ed8c
	defb 011h		;ed8d
	defb 00ah		;ed8e
	defb 000h		;ed8f
	defb 019h		;ed90
	defb 05eh		;ed91
	defb 023h		;ed92
	defb 056h		;ed93
	defb 0ebh		;ed94
	defb 011h		;ed95
	defb 005h		;ed96
	defb 000h		;ed97
	defb 019h		;ed98
	defb 05eh		;ed99
	defb 023h		;ed9a
	defb 056h		;ed9b
	defb 0d5h		;ed9c
	defb 0cdh		;ed9d
	defb 0e0h		;ed9e
	defb 026h		;ed9f
	defb 02ah		;eda0
	defb 088h		;eda1
	defb 015h		;eda2
	defb 0e5h		;eda3
	defb 02ah		;eda4
	defb 080h		;eda5
	defb 015h		;eda6
	defb 0e5h		;eda7
	defb 0cdh		;eda8
	defb 00ch		;eda9
	defb 027h		;edaa
	defb 021h		;edab
	defb 09eh		;edac
	defb 012h		;edad
	defb 0e5h		;edae
	defb 02ah		;edaf
	defb 088h		;edb0
	defb 015h		;edb1
	defb 02bh		;edb2
	defb 0d1h		;edb3
	defb 019h		;edb4
	defb 016h		;edb5
	defb 000h		;edb6
	defb 05eh		;edb7
	defb 0ebh		;edb8
	defb 0d1h		;edb9
	defb 07dh		;edba
	defb 0a3h		;edbb
	defb 06fh		;edbc
	defb 0d1h		;edbd
	defb 07dh		;edbe
	defb 0b3h		;edbf
	defb 01fh		;edc0
	defb 0d2h		;edc1
	defb 05ch		;edc2
	defb 00dh		;edc3
	defb 021h		;edc4
	defb 090h		;edc5
	defb 016h		;edc6
	defb 0e5h		;edc7
	defb 0cdh		;edc8
	defb 043h		;edc9
	defb 027h		;edca
	defb 0cdh		;edcb
	defb 0dah		;edcc
	defb 024h		;edcd
	defb 0cdh		;edce
	defb 049h		;edcf
	defb 027h		;edd0
	defb 021h		;edd1
	defb 090h		;edd2
	defb 016h		;edd3
	defb 0e5h		;edd4
	defb 0cdh		;edd5
	defb 043h		;edd6
	defb 027h		;edd7
	defb 0cdh		;edd8
	defb 0dah		;edd9
	defb 024h		;edda
	defb 0cdh		;eddb
	defb 049h		;eddc
	defb 027h		;eddd
	defb 02ah		;edde
	defb 07eh		;eddf
	defb 015h		;ede0
	defb 0e5h		;ede1
	defb 021h		;ede2
	defb 000h		;ede3
	defb 000h		;ede4
	defb 0e5h		;ede5
	defb 0cdh		;ede6
	defb 0e0h		;ede7
	defb 026h		;ede8
	defb 0f1h		;ede9
	defb 0d2h		;edea
	defb 05fh		;edeb
	defb 011h		;edec
	defb 021h		;eded
	defb 090h		;edee
	defb 016h		;edef
	defb 0e5h		;edf0
	defb 0cdh		;edf1
	defb 043h		;edf2
	defb 027h		;edf3
	defb 0cdh		;edf4
	defb 032h		;edf5
	defb 00fh		;edf6
	defb 002h		;edf7
	defb 020h		;edf8
	defb 020h		;edf9
	defb 0cdh		;edfa
	defb 036h		;edfb
	defb 027h		;edfc
	defb 0cdh		;edfd
	defb 0b3h		;edfe
	defb 027h		;edff
	defb 02ah		;ee00
	defb 07eh		;ee01
	defb 015h		;ee02
	defb 0e5h		;ee03
	defb 0cdh		;ee04
	defb 036h		;ee05
	defb 027h		;ee06
	defb 0cdh		;ee07
	defb 0e7h		;ee08
	defb 024h		;ee09
	defb 0cdh		;ee0a
	defb 064h		;ee0b
	defb 00fh		;ee0c
	defb 01eh		;ee0d
	defb 020h		;ee0e
	defb 042h		;ee0f
	defb 04ch		;ee10
	defb 04fh		;ee11
	defb 043h		;ee12
	defb 04bh		;ee13
	defb 053h		;ee14
	defb 020h		;ee15
	defb 046h		;ee16
	defb 04fh		;ee17
	defb 055h		;ee18
	defb 04eh		;ee19
	defb 044h		;ee1a
	defb 020h		;ee1b
	defb 057h		;ee1c
	defb 049h		;ee1d
	defb 054h		;ee1e
	defb 048h		;ee1f
	defb 020h		;ee20
	defb 042h		;ee21
	defb 041h		;ee22
	defb 044h		;ee23
	defb 020h		;ee24
	defb 053h		;ee25
	defb 045h		;ee26
	defb 043h		;ee27
	defb 054h		;ee28
	defb 04fh		;ee29
	defb 052h		;ee2a
	defb 053h		;ee2b
	defb 0cdh		;ee2c
	defb 036h		;ee2d
	defb 027h		;ee2e
	defb 0cdh		;ee2f
	defb 0b3h		;ee30
	defb 027h		;ee31
	defb 0cdh		;ee32
	defb 0dah		;ee33
	defb 024h		;ee34
	defb 0cdh		;ee35
	defb 049h		;ee36
	defb 027h		;ee37
	defb 021h		;ee38
	defb 090h		;ee39
	defb 016h		;ee3a
	defb 0e5h		;ee3b
	defb 0cdh		;ee3c
	defb 043h		;ee3d
	defb 027h		;ee3e
	defb 0cdh		;ee3f
	defb 096h		;ee40
	defb 00fh		;ee41
	defb 01bh		;ee42
	defb 020h		;ee43
	defb 020h		;ee44
	defb 043h		;ee45
	defb 052h		;ee46
	defb 045h		;ee47
	defb 041h		;ee48
	defb 054h		;ee49
	defb 045h		;ee4a
	defb 020h		;ee4b
	defb 044h		;ee4c
	defb 055h		;ee4d
	defb 04dh		;ee4e
	defb 04dh		;ee4f
	defb 059h		;ee50
	defb 020h		;ee51
	defb 046h		;ee52
	defb 049h		;ee53
	defb 04ch		;ee54
	defb 045h		;ee55
	defb 020h		;ee56
	defb 028h		;ee57
	defb 059h		;ee58
	defb 02fh		;ee59
	defb 04eh		;ee5a
	defb 029h		;ee5b
	defb 03ah		;ee5c
	defb 020h		;ee5d
	defb 0cdh		;ee5e
	defb 036h		;ee5f
	defb 027h		;ee60
	defb 0cdh		;ee61
	defb 0b3h		;ee62
	defb 027h		;ee63
	defb 0cdh		;ee64
	defb 049h		;ee65
	defb 027h		;ee66
	defb 021h		;ee67
	defb 097h		;ee68
	defb 016h		;ee69
	defb 0e5h		;ee6a
	defb 0cdh		;ee6b
	defb 03dh		;ee6c
	defb 027h		;ee6d
	defb 021h		;ee6e
	defb 08ch		;ee6f
	defb 015h		;ee70
	defb 0e5h		;ee71
	defb 0cdh		;ee72
	defb 0cah		;ee73
	defb 024h		;ee74
	defb 0cdh		;ee75
	defb 049h		;ee76
	defb 027h		;ee77
	defb 03ah		;ee78
	defb 08ch		;ee79
	defb 015h		;ee7a
	defb 026h		;ee7b
	defb 000h		;ee7c
	defb 06fh		;ee7d
	defb 0e5h		;ee7e
	defb 021h		;ee7f
	defb 059h		;ee80
	defb 000h		;ee81
	defb 0e5h		;ee82
	defb 0cdh		;ee83
	defb 0a6h		;ee84
	defb 022h		;ee85
	defb 021h		;ee86
	defb 079h		;ee87
	defb 000h		;ee88
	defb 0e5h		;ee89
	defb 0cdh		;ee8a
	defb 0a6h		;ee8b
	defb 022h		;ee8c
	defb 0cdh		;ee8d
	defb 087h		;ee8e
	defb 023h		;ee8f
	defb 021h		;ee90
	defb 04eh		;ee91
	defb 000h		;ee92
	defb 0e5h		;ee93
	defb 0cdh		;ee94
	defb 0a6h		;ee95
	defb 022h		;ee96
	defb 0cdh		;ee97
	defb 087h		;ee98
	defb 023h		;ee99
	defb 021h		;ee9a
	defb 06eh		;ee9b
	defb 000h		;ee9c
	defb 0e5h		;ee9d
	defb 0cdh		;ee9e
	defb 0a6h		;ee9f
	defb 022h		;eea0
	defb 0cdh		;eea1
	defb 087h		;eea2
	defb 023h		;eea3
	defb 0cdh		;eea4
	defb 03ch		;eea5
	defb 023h		;eea6
	defb 03ah		;eea7
	defb 08ch		;eea8
	defb 015h		;eea9
	defb 026h		;eeaa
	defb 000h		;eeab
	defb 06fh		;eeac
	defb 0e5h		;eead
	defb 021h		;eeae
	defb 003h		;eeaf
	defb 000h		;eeb0
	defb 0e5h		;eeb1
	defb 0cdh		;eeb2
	defb 0adh		;eeb3
	defb 026h		;eeb4
	defb 0e1h		;eeb5
	defb 0d1h		;eeb6
	defb 07dh		;eeb7
	defb 0b3h		;eeb8
	defb 01fh		;eeb9
	defb 0d2h		;eeba
	defb 09fh		;eebb
	defb 00fh		;eebc
	defb 021h		;eebd
	defb 090h		;eebe
	defb 016h		;eebf
	defb 0e5h		;eec0
	defb 0cdh		;eec1
	defb 043h		;eec2
	defb 027h		;eec3
	defb 03ah		;eec4
	defb 08ch		;eec5
	defb 015h		;eec6
	defb 026h		;eec7
	defb 000h		;eec8
	defb 06fh		;eec9
	defb 0ebh		;eeca
	defb 021h		;eecb
	defb 05fh		;eecc
	defb 000h		;eecd
	defb 07dh		;eece
	defb 0a3h		;eecf
	defb 06fh		;eed0
	defb 07ch		;eed1
	defb 0a2h		;eed2
	defb 067h		;eed3
	defb 0e5h		;eed4
	defb 0cdh		;eed5
	defb 036h		;eed6
	defb 027h		;eed7
	defb 0cdh		;eed8
	defb 0ebh		;eed9
	defb 029h		;eeda
	defb 0cdh		;eedb
	defb 049h		;eedc
	defb 027h		;eedd
	defb 03ah		;eede
	defb 08ch		;eedf
	defb 015h		;eee0
	defb 026h		;eee1
	defb 000h		;eee2
	defb 06fh		;eee3
	defb 0e5h		;eee4
	defb 021h		;eee5
	defb 079h		;eee6
	defb 000h		;eee7
	defb 0e5h		;eee8
	defb 0cdh		;eee9
	defb 0a6h		;eeea
	defb 022h		;eeeb
	defb 021h		;eeec
	defb 059h		;eeed
	defb 000h		;eeee
	defb 0e5h		;eeef
	defb 0cdh		;eef0
	defb 0a6h		;eef1
	defb 022h		;eef2
	defb 0cdh		;eef3
	defb 087h		;eef4
	defb 023h		;eef5
	defb 0cdh		;eef6
	defb 03ch		;eef7
	defb 023h		;eef8
	defb 0f1h		;eef9
	defb 0d2h		;eefa
	defb 05ch		;eefb
	defb 011h		;eefc
	defb 021h		;eefd
	defb 090h		;eefe
	defb 016h		;eeff
	defb 0e5h		;ef00
	defb 0cdh		;ef01
	defb 043h		;ef02
	defb 027h		;ef03
	defb 0cdh		;ef04
	defb 0dah		;ef05
	defb 024h		;ef06
	defb 0cdh		;ef07
	defb 049h		;ef08
	defb 027h		;ef09
	defb 021h		;ef0a
	defb 090h		;ef0b
	defb 016h		;ef0c
	defb 0e5h		;ef0d
	defb 0cdh		;ef0e
	defb 043h		;ef0f
	defb 027h		;ef10
	defb 0cdh		;ef11
	defb 085h		;ef12
	defb 010h		;ef13
	defb 038h		;ef14
	defb 020h		;ef15
	defb 020h		;ef16
	defb 057h		;ef17
	defb 041h		;ef18
	defb 052h		;ef19
	defb 04eh		;ef1a
	defb 049h		;ef1b
	defb 04eh		;ef1c
	defb 047h		;ef1d
	defb 03ah		;ef1e
	defb 020h		;ef1f
	defb 054h		;ef20
	defb 048h		;ef21
	defb 049h		;ef22
	defb 053h		;ef23
	defb 020h		;ef24
	defb 04dh		;ef25
	defb 041h		;ef26
	defb 059h		;ef27
	defb 020h		;ef28
	defb 044h		;ef29
	defb 045h		;ef2a
	defb 053h		;ef2b
	defb 054h		;ef2c
	defb 052h		;ef2d
	defb 04fh		;ef2e
	defb 059h		;ef2f
	defb 020h		;ef30
	defb 054h		;ef31
	defb 048h		;ef32
	defb 045h		;ef33
	defb 020h		;ef34
	defb 043h		;ef35
	defb 04fh		;ef36
	defb 04eh		;ef37
	defb 054h		;ef38
	defb 045h		;ef39
	defb 04eh		;ef3a
	defb 054h		;ef3b
	defb 053h		;ef3c
	defb 020h		;ef3d
	defb 04fh		;ef3e
	defb 046h		;ef3f
	defb 020h		;ef40
	defb 054h		;ef41
	defb 048h		;ef42
	defb 045h		;ef43
	defb 020h		;ef44
	defb 044h		;ef45
	defb 049h		;ef46
	defb 053h		;ef47
	defb 04bh		;ef48
	defb 045h		;ef49
	defb 054h		;ef4a
	defb 054h		;ef4b
	defb 045h		;ef4c
	defb 0cdh		;ef4d
	defb 036h		;ef4e
	defb 027h		;ef4f
	defb 0cdh		;ef50
	defb 0b3h		;ef51
	defb 027h		;ef52
	defb 0cdh		;ef53
	defb 0dah		;ef54
	defb 024h		;ef55
	defb 0cdh		;ef56
	defb 049h		;ef57
	defb 027h		;ef58
	defb 021h		;ef59
	defb 090h		;ef5a
	defb 016h		;ef5b
	defb 0e5h		;ef5c
	defb 0cdh		;ef5d
	defb 043h		;ef5e
	defb 027h		;ef5f
	defb 0cdh		;ef60
	defb 0b7h		;ef61
	defb 010h		;ef62
	defb 01bh		;ef63
	defb 020h		;ef64
	defb 020h		;ef65
	defb 020h		;ef66
	defb 020h		;ef67
	defb 020h		;ef68
	defb 020h		;ef69
	defb 020h		;ef6a
	defb 020h		;ef6b
	defb 020h		;ef6c
	defb 020h		;ef6d
	defb 020h		;ef6e
	defb 043h		;ef6f
	defb 04fh		;ef70
	defb 04eh		;ef71
	defb 054h		;ef72
	defb 049h		;ef73
	defb 04eh		;ef74
	defb 055h		;ef75
	defb 045h		;ef76
	defb 020h		;ef77
	defb 028h		;ef78
	defb 059h		;ef79
	defb 02fh		;ef7a
	defb 04eh		;ef7b
	defb 029h		;ef7c
	defb 03ah		;ef7d
	defb 020h		;ef7e
	defb 0cdh		;ef7f
	defb 036h		;ef80
	defb 027h		;ef81
	defb 0cdh		;ef82
	defb 0b3h		;ef83
	defb 027h		;ef84
	defb 0cdh		;ef85
	defb 049h		;ef86
	defb 027h		;ef87
	defb 021h		;ef88
	defb 097h		;ef89
	defb 016h		;ef8a
	defb 0e5h		;ef8b
	defb 0cdh		;ef8c
	defb 03dh		;ef8d
	defb 027h		;ef8e
	defb 021h		;ef8f
	defb 08ch		;ef90
	defb 015h		;ef91
	defb 0e5h		;ef92
	defb 0cdh		;ef93
	defb 0cah		;ef94
	defb 024h		;ef95
	defb 0cdh		;ef96
	defb 049h		;ef97
	defb 027h		;ef98
	defb 03ah		;ef99
	defb 08ch		;ef9a
	defb 015h		;ef9b
	defb 026h		;ef9c
	defb 000h		;ef9d
	defb 06fh		;ef9e
	defb 0e5h		;ef9f
	defb 021h		;efa0
	defb 059h		;efa1
	defb 000h		;efa2
	defb 0e5h		;efa3
	defb 0cdh		;efa4
	defb 0a6h		;efa5
	defb 022h		;efa6
	defb 021h		;efa7
	defb 079h		;efa8
	defb 000h		;efa9
	defb 0e5h		;efaa
	defb 0cdh		;efab
	defb 0a6h		;efac
	defb 022h		;efad
	defb 0cdh		;efae
	defb 087h		;efaf
	defb 023h		;efb0
	defb 021h		;efb1
	defb 04eh		;efb2
	defb 000h		;efb3
	defb 0e5h		;efb4
	defb 0cdh		;efb5
	defb 0a6h		;efb6
	defb 022h		;efb7
	defb 0cdh		;efb8
	defb 087h		;efb9
	defb 023h		;efba
	defb 021h		;efbb
	defb 06eh		;efbc
	defb 000h		;efbd
	defb 0e5h		;efbe
	defb 0cdh		;efbf
	defb 0a6h		;efc0
	defb 022h		;efc1
	defb 0cdh		;efc2
	defb 087h		;efc3
	defb 023h		;efc4
	defb 0cdh		;efc5
	defb 03ch		;efc6
	defb 023h		;efc7
	defb 03ah		;efc8
	defb 08ch		;efc9
	defb 015h		;efca
	defb 026h		;efcb
	defb 000h		;efcc
	defb 06fh		;efcd
	defb 0e5h		;efce
	defb 021h		;efcf
	defb 003h		;efd0
	defb 000h		;efd1
	defb 0e5h		;efd2
	defb 0cdh		;efd3
	defb 0adh		;efd4
	defb 026h		;efd5
	defb 0e1h		;efd6
	defb 0d1h		;efd7
	defb 07dh		;efd8
	defb 0b3h		;efd9
	defb 01fh		;efda
	defb 0d2h		;efdb
	defb 0c0h		;efdc
	defb 010h		;efdd
	defb 021h		;efde
	defb 090h		;efdf
	defb 016h		;efe0
	defb 0e5h		;efe1
	defb 0cdh		;efe2
	defb 043h		;efe3
	defb 027h		;efe4
	defb 03ah		;efe5
	defb 08ch		;efe6
	defb 015h		;efe7
	defb 026h		;efe8
	defb 000h		;efe9
	defb 06fh		;efea
	defb 0ebh		;efeb
	defb 021h		;efec
	defb 05fh		;efed
	defb 000h		;efee
	defb 07dh		;efef
	defb 0a3h		;eff0
	defb 06fh		;eff1
	defb 07ch		;eff2
	defb 0a2h		;eff3
	defb 067h		;eff4
	defb 0e5h		;eff5
	defb 0cdh		;eff6
	defb 036h		;eff7
	defb 027h		;eff8
	defb 0cdh		;eff9
	defb 0ebh		;effa
	defb 029h		;effb
	defb 0cdh		;effc
	defb 0dah		;effd
	defb 024h		;effe
	defb 0cdh		;efff
	defb 049h		;f000
	defb 027h		;f001
	defb 03ah		;f002
	defb 08ch		;f003
	defb 015h		;f004
	defb 026h		;f005
	defb 000h		;f006
	defb 06fh		;f007
	defb 0e5h		;f008
	defb 021h		;f009
	defb 059h		;f00a
	defb 000h		;f00b
	defb 0e5h		;f00c
	defb 0cdh		;f00d
	defb 0a6h		;f00e
	defb 022h		;f00f
	defb 021h		;f010
	defb 079h		;f011
	defb 000h		;f012
	defb 0e5h		;f013
	defb 0cdh		;f014
	defb 0a6h		;f015
	defb 022h		;f016
	defb 0cdh		;f017
	defb 087h		;f018
	defb 023h		;f019
	defb 0cdh		;f01a
	defb 03ch		;f01b
	defb 023h		;f01c
	defb 0f1h		;f01d
	defb 0d2h		;f01e
	defb 05ch		;f01f
	defb 011h		;f020
	defb 0cdh		;f021
	defb 01fh		;f022
	defb 001h		;f023
	defb 0c3h		;f024
	defb 08ch		;f025
	defb 011h		;f026
	defb 021h		;f027
	defb 090h		;f028
	defb 016h		;f029
	defb 0e5h		;f02a
	defb 0cdh		;f02b
	defb 043h		;f02c
	defb 027h		;f02d
	defb 0cdh		;f02e
	defb 080h		;f02f
	defb 011h		;f030
	defb 016h		;f031
	defb 020h		;f032
	defb 020h		;f033
	defb 04eh		;f034
	defb 04fh		;f035
	defb 020h		;f036
	defb 042h		;f037
	defb 041h		;f038
	defb 044h		;f039
	defb 020h		;f03a
	defb 053h		;f03b
	defb 045h		;f03c
	defb 043h		;f03d
	defb 054h		;f03e
	defb 04fh		;f03f
	defb 052h		;f040
	defb 053h		;f041
	defb 020h		;f042
	defb 046h		;f043
	defb 04fh		;f044
	defb 055h		;f045
	defb 04eh		;f046
	defb 044h		;f047
	defb 0cdh		;f048
	defb 036h		;f049
	defb 027h		;f04a
	defb 0cdh		;f04b
	defb 0b3h		;f04c
	defb 027h		;f04d
	defb 0cdh		;f04e
	defb 0dah		;f04f
	defb 024h		;f050
	defb 0cdh		;f051
	defb 049h		;f052
	defb 027h		;f053
	defb 021h		;f054
	defb 090h		;f055
	defb 016h		;f056
	defb 0e5h		;f057
	defb 0cdh		;f058
	defb 043h		;f059
	defb 027h		;f05a
	defb 0cdh		;f05b
	defb 0dah		;f05c
	defb 024h		;f05d
	defb 0cdh		;f05e
	defb 049h		;f05f
	defb 027h		;f060
	defb 021h		;f061
	defb 090h		;f062
	defb 016h		;f063
	defb 0e5h		;f064
	defb 0cdh		;f065
	defb 043h		;f066
	defb 027h		;f067
	defb 0cdh		;f068
	defb 0bbh		;f069
	defb 011h		;f06a
	defb 017h		;f06b
	defb 020h		;f06c
	defb 020h		;f06d
	defb 050h		;f06e
	defb 052h		;f06f
	defb 045h		;f070
	defb 053h		;f071
	defb 053h		;f072
	defb 020h		;f073
	defb 027h		;f074
	defb 043h		;f075
	defb 027h		;f076
	defb 020h		;f077
	defb 054h		;f078
	defb 04fh		;f079
	defb 020h		;f07a
	defb 043h		;f07b
	defb 04fh		;f07c
	defb 04eh		;f07d
	defb 054h		;f07e
	defb 049h		;f07f
	defb 04eh		;f080
	defb 055h		;f081
	defb 045h		;f082
	defb 0cdh		;f083
	defb 036h		;f084
	defb 027h		;f085
	defb 0cdh		;f086
	defb 0b3h		;f087
	defb 027h		;f088
	defb 0cdh		;f089
	defb 0dah		;f08a
	defb 024h		;f08b
	defb 0cdh		;f08c
	defb 049h		;f08d
	defb 027h		;f08e
	defb 021h		;f08f
	defb 090h		;f090
	defb 016h		;f091
	defb 0e5h		;f092
	defb 0cdh		;f093
	defb 043h		;f094
	defb 027h		;f095
	defb 0cdh		;f096
	defb 0ech		;f097
	defb 011h		;f098
	defb 01ah		;f099
	defb 020h		;f09a
	defb 020h		;f09b
	defb 020h		;f09c
	defb 020h		;f09d
	defb 020h		;f09e
	defb 04fh		;f09f
	defb 052h		;f0a0
	defb 020h		;f0a1
	defb 027h		;f0a2
	defb 054h		;f0a3
	defb 027h		;f0a4
	defb 020h		;f0a5
	defb 054h		;f0a6
	defb 04fh		;f0a7
	defb 020h		;f0a8
	defb 054h		;f0a9
	defb 045h		;f0aa
	defb 052h		;f0ab
	defb 04dh		;f0ac
	defb 049h		;f0ad
	defb 04eh		;f0ae
	defb 041h		;f0af
	defb 054h		;f0b0
	defb 045h		;f0b1
	defb 03ah		;f0b2
	defb 020h		;f0b3
	defb 0cdh		;f0b4
	defb 036h		;f0b5
	defb 027h		;f0b6
	defb 0cdh		;f0b7
	defb 0b3h		;f0b8
	defb 027h		;f0b9
	defb 0cdh		;f0ba
	defb 049h		;f0bb
	defb 027h		;f0bc
	defb 021h		;f0bd
	defb 097h		;f0be
	defb 016h		;f0bf
	defb 0e5h		;f0c0
	defb 0cdh		;f0c1
	defb 03dh		;f0c2
	defb 027h		;f0c3
	defb 021h		;f0c4
	defb 08ch		;f0c5
	defb 015h		;f0c6
	defb 0e5h		;f0c7
	defb 0cdh		;f0c8
	defb 0cah		;f0c9
	defb 024h		;f0ca
	defb 0cdh		;f0cb
	defb 049h		;f0cc
	defb 027h		;f0cd
	defb 03ah		;f0ce
	defb 08ch		;f0cf
	defb 015h		;f0d0
	defb 026h		;f0d1
	defb 000h		;f0d2
	defb 06fh		;f0d3
	defb 0e5h		;f0d4
	defb 021h		;f0d5
	defb 043h		;f0d6
	defb 000h		;f0d7
	defb 0e5h		;f0d8
	defb 0cdh		;f0d9
	defb 0a6h		;f0da
	defb 022h		;f0db
	defb 021h		;f0dc
	defb 063h		;f0dd
	defb 000h		;f0de
	defb 0e5h		;f0df
	defb 0cdh		;f0e0
	defb 0a6h		;f0e1
	defb 022h		;f0e2
	defb 0cdh		;f0e3
	defb 087h		;f0e4
	defb 023h		;f0e5
	defb 021h		;f0e6
	defb 054h		;f0e7
	defb 000h		;f0e8
	defb 0e5h		;f0e9
	defb 0cdh		;f0ea
	defb 0a6h		;f0eb
	defb 022h		;f0ec
	defb 0cdh		;f0ed
	defb 087h		;f0ee
	defb 023h		;f0ef
	defb 021h		;f0f0
	defb 074h		;f0f1
	defb 000h		;f0f2
	defb 0e5h		;f0f3
	defb 0cdh		;f0f4
	defb 0a6h		;f0f5
	defb 022h		;f0f6
	defb 0cdh		;f0f7
	defb 087h		;f0f8
	defb 023h		;f0f9
	defb 0cdh		;f0fa
	defb 03ch		;f0fb
	defb 023h		;f0fc
	defb 03ah		;f0fd
	defb 08ch		;f0fe
	defb 000h		;f0ff
	defb 0fch		;f100
	defb 000h		;f101
	defb 0ffh		;f102
	defb 000h		;f103
	defb 0ffh		;f104
	defb 000h		;f105
	defb 000h		;f106
	defb 000h		;f107
	defb 0bdh		;f108
	defb 000h		;f109
	defb 0ffh		;f10a
	defb 008h		;f10b
	defb 0ffh		;f10c
	defb 000h		;f10d
	defb 000h		;f10e
	defb 000h		;f10f
	defb 0ffh		;f110
	defb 000h		;f111
	defb 0ffh		;f112
	defb 000h		;f113
	defb 0ffh		;f114
	defb 000h		;f115
	defb 000h		;f116
	defb 000h		;f117
	defb 0feh		;f118
	defb 000h		;f119
	defb 0ffh		;f11a
	defb 004h		;f11b
	defb 0ffh		;f11c
	defb 000h		;f11d
	defb 000h		;f11e
	defb 000h		;f11f
	defb 0ffh		;f120
	defb 020h		;f121
	defb 0ffh		;f122
	defb 0c8h		;f123
	defb 0ffh		;f124
	defb 000h		;f125
	defb 000h		;f126
	defb 000h		;f127
	defb 0feh		;f128
	defb 000h		;f129
	defb 0ffh		;f12a
	defb 008h		;f12b
	defb 0ffh		;f12c
	defb 000h		;f12d
	defb 000h		;f12e
	defb 000h		;f12f
	defb 05dh		;f130
	defb 000h		;f131
	defb 0ffh		;f132
	defb 021h		;f133
	defb 0ffh		;f134
	defb 000h		;f135
	defb 000h		;f136
	defb 000h		;f137
	defb 0ffh		;f138
	defb 021h		;f139
	defb 0ffh		;f13a
	defb 004h		;f13b
	defb 0ffh		;f13c
	defb 000h		;f13d
	defb 000h		;f13e
	defb 000h		;f13f
	defb 05fh		;f140
	defb 000h		;f141
	defb 0ffh		;f142
	defb 000h		;f143
	defb 0ffh		;f144
	defb 000h		;f145
	defb 000h		;f146
	defb 000h		;f147
	defb 0ffh		;f148
	defb 000h		;f149
	defb 0ffh		;f14a
	defb 090h		;f14b
	defb 0ffh		;f14c
	defb 000h		;f14d
	defb 000h		;f14e
	defb 000h		;f14f
	defb 0f5h		;f150
	defb 000h		;f151
	defb 0ffh		;f152
	defb 000h		;f153
	defb 0ffh		;f154
	defb 000h		;f155
	defb 000h		;f156
	defb 000h		;f157
	defb 0f7h		;f158
	defb 000h		;f159
	defb 0ffh		;f15a
	defb 010h		;f15b
	defb 0ffh		;f15c
	defb 000h		;f15d
	defb 000h		;f15e
	defb 000h		;f15f
	defb 0ffh		;f160
	defb 000h		;f161
	defb 0ffh		;f162
	defb 010h		;f163
	defb 0ffh		;f164
	defb 000h		;f165
	defb 000h		;f166
	defb 000h		;f167
	defb 0ffh		;f168
	defb 000h		;f169
	defb 0ffh		;f16a
	defb 010h		;f16b
	defb 0ffh		;f16c
	defb 010h		;f16d
	defb 000h		;f16e
	defb 000h		;f16f
	defb 0efh		;f170
	defb 000h		;f171
	defb 0ffh		;f172
	defb 004h		;f173
	defb 0ffh		;f174
	defb 000h		;f175
	defb 000h		;f176
	defb 000h		;f177
	defb 0ffh		;f178
	defb 080h		;f179
	defb 0ffh		;f17a
	defb 000h		;f17b
	defb 0ffh		;f17c
	defb 000h		;f17d
	defb 000h		;f17e
	defb 000h		;f17f
	defb 0ffh		;f180
	defb 05ch		;f181
	defb 0ffh		;f182
	defb 000h		;f183
	defb 0ffh		;f184
	defb 000h		;f185
	defb 000h		;f186
	defb 000h		;f187
	defb 07fh		;f188
	defb 000h		;f189
	defb 0ffh		;f18a
	defb 000h		;f18b
	defb 0ffh		;f18c
	defb 030h		;f18d
	defb 000h		;f18e
	defb 000h		;f18f
	defb 0dah		;f190
	defb 000h		;f191
	defb 0ffh		;f192
	defb 000h		;f193
	defb 0ffh		;f194
	defb 000h		;f195
	defb 000h		;f196
	defb 000h		;f197
	defb 0ffh		;f198
	defb 000h		;f199
	defb 0ffh		;f19a
	defb 010h		;f19b
	defb 0ffh		;f19c
	defb 000h		;f19d
	defb 000h		;f19e
	defb 000h		;f19f
	defb 0cfh		;f1a0
	defb 010h		;f1a1
	defb 0ffh		;f1a2
	defb 02ch		;f1a3
	defb 0ffh		;f1a4
	defb 000h		;f1a5
	defb 000h		;f1a6
	defb 000h		;f1a7
	defb 0dfh		;f1a8
	defb 001h		;f1a9
	defb 0fdh		;f1aa
	defb 002h		;f1ab
	defb 0ffh		;f1ac
	defb 000h		;f1ad
	defb 000h		;f1ae
	defb 000h		;f1af
	defb 0ffh		;f1b0
	defb 002h		;f1b1
	defb 0ffh		;f1b2
	defb 024h		;f1b3
	defb 0ffh		;f1b4
	defb 000h		;f1b5
	defb 000h		;f1b6
	defb 000h		;f1b7
	defb 0ffh		;f1b8
	defb 040h		;f1b9
	defb 0ffh		;f1ba
	defb 000h		;f1bb
	defb 0ffh		;f1bc
	defb 000h		;f1bd
	defb 000h		;f1be
	defb 000h		;f1bf
	defb 0ffh		;f1c0
	defb 004h		;f1c1
	defb 0ffh		;f1c2
	defb 000h		;f1c3
	defb 0ffh		;f1c4
	defb 000h		;f1c5
	defb 000h		;f1c6
	defb 000h		;f1c7
	defb 0feh		;f1c8
	defb 000h		;f1c9
	defb 0ffh		;f1ca
	defb 081h		;f1cb
	defb 0ffh		;f1cc
	defb 000h		;f1cd
	defb 000h		;f1ce
	defb 000h		;f1cf
	defb 0feh		;f1d0
	defb 002h		;f1d1
	defb 0ffh		;f1d2
	defb 000h		;f1d3
	defb 0ffh		;f1d4
	defb 000h		;f1d5
	defb 000h		;f1d6
	defb 000h		;f1d7
	defb 0feh		;f1d8
	defb 000h		;f1d9
	defb 0ffh		;f1da
	defb 000h		;f1db
	defb 0ffh		;f1dc
	defb 000h		;f1dd
	defb 000h		;f1de
	defb 000h		;f1df
	defb 0dfh		;f1e0
	defb 001h		;f1e1
	defb 0ffh		;f1e2
	defb 002h		;f1e3
	defb 0ffh		;f1e4
	defb 000h		;f1e5
	defb 000h		;f1e6
	defb 000h		;f1e7
	defb 03fh		;f1e8
	defb 000h		;f1e9
	defb 0ffh		;f1ea
	defb 020h		;f1eb
	defb 0ffh		;f1ec
	defb 000h		;f1ed
	defb 000h		;f1ee
	defb 000h		;f1ef
	defb 0ffh		;f1f0
	defb 000h		;f1f1
	defb 0ffh		;f1f2
	defb 000h		;f1f3
	defb 0ffh		;f1f4
	defb 000h		;f1f5
	defb 000h		;f1f6
	defb 000h		;f1f7
	defb 0fdh		;f1f8
	defb 010h		;f1f9
	defb 0ffh		;f1fa
	defb 000h		;f1fb
	defb 0ffh		;f1fc
	defb 000h		;f1fd
	defb 000h		;f1fe
	defb 000h		;f1ff
	defb 0feh		;f200
	defb 080h		;f201
	defb 0ffh		;f202
	defb 0b0h		;f203
	defb 0ffh		;f204
	defb 000h		;f205
	defb 000h		;f206
	defb 000h		;f207
	defb 0efh		;f208
	defb 030h		;f209
	defb 0ffh		;f20a
	defb 006h		;f20b
	defb 0ffh		;f20c
	defb 000h		;f20d
	defb 000h		;f20e
	defb 000h		;f20f
	defb 0ddh		;f210
	defb 000h		;f211
	defb 0ffh		;f212
	defb 080h		;f213
	defb 0ffh		;f214
	defb 000h		;f215
	defb 000h		;f216
	defb 000h		;f217
	defb 0feh		;f218
	defb 000h		;f219
	defb 0ffh		;f21a
	defb 002h		;f21b
	defb 0ffh		;f21c
	defb 010h		;f21d
	defb 000h		;f21e
	defb 000h		;f21f
	defb 0f7h		;f220
	defb 001h		;f221
	defb 0ffh		;f222
	defb 005h		;f223
	defb 0ffh		;f224
	defb 002h		;f225
	defb 000h		;f226
	defb 000h		;f227
	defb 0eeh		;f228
	defb 000h		;f229
	defb 0ffh		;f22a
	defb 008h		;f22b
	defb 0ffh		;f22c
	defb 000h		;f22d
	defb 000h		;f22e
	defb 000h		;f22f
	defb 0fbh		;f230
	defb 012h		;f231
	defb 0ffh		;f232
	defb 040h		;f233
	defb 0ffh		;f234
	defb 000h		;f235
	defb 000h		;f236
	defb 000h		;f237
	defb 0ffh		;f238
	defb 040h		;f239
	defb 0ffh		;f23a
	defb 000h		;f23b
	defb 0ffh		;f23c
	defb 000h		;f23d
	defb 000h		;f23e
	defb 000h		;f23f
	defb 0fdh		;f240
	defb 000h		;f241
	defb 0ffh		;f242
	defb 001h		;f243
	defb 0ffh		;f244
	defb 000h		;f245
	defb 000h		;f246
	defb 000h		;f247
	defb 0fdh		;f248
	defb 080h		;f249
	defb 0ffh		;f24a
	defb 080h		;f24b
	defb 0ffh		;f24c
	defb 000h		;f24d
	defb 000h		;f24e
	defb 000h		;f24f
	defb 0b3h		;f250
	defb 000h		;f251
	defb 0ffh		;f252
	defb 041h		;f253
	defb 0ffh		;f254
	defb 000h		;f255
	defb 000h		;f256
	defb 000h		;f257
	defb 0ffh		;f258
	defb 000h		;f259
	defb 0ffh		;f25a
	defb 000h		;f25b
	defb 0ffh		;f25c
	defb 000h		;f25d
	defb 000h		;f25e
	defb 000h		;f25f
	defb 0feh		;f260
	defb 000h		;f261
	defb 0ffh		;f262
	defb 000h		;f263
	defb 0ffh		;f264
	defb 000h		;f265
	defb 000h		;f266
	defb 000h		;f267
	defb 05fh		;f268
	defb 000h		;f269
	defb 0ffh		;f26a
	defb 000h		;f26b
	defb 0ffh		;f26c
	defb 021h		;f26d
	defb 000h		;f26e
	defb 000h		;f26f
	defb 0eeh		;f270
	defb 000h		;f271
	defb 0ffh		;f272
	defb 008h		;f273
	defb 0ffh		;f274
	defb 000h		;f275
	defb 000h		;f276
	defb 000h		;f277
	defb 0ffh		;f278
	defb 000h		;f279
	defb 0ffh		;f27a
	defb 004h		;f27b
	defb 0ffh		;f27c
	defb 000h		;f27d
	defb 000h		;f27e
	defb 000h		;f27f
	defb 0bfh		;f280
	defb 000h		;f281
	defb 0ffh		;f282
	defb 000h		;f283
	defb 0ffh		;f284
	defb 000h		;f285
	defb 000h		;f286
	defb 000h		;f287
	defb 0ffh		;f288
	defb 000h		;f289
	defb 0ffh		;f28a
	defb 000h		;f28b
	defb 0ffh		;f28c
	defb 000h		;f28d
	defb 000h		;f28e
	defb 000h		;f28f
	defb 0ffh		;f290
	defb 002h		;f291
	defb 0feh		;f292
	defb 040h		;f293
	defb 0ffh		;f294
	defb 000h		;f295
	defb 000h		;f296
	defb 000h		;f297
	defb 0fch		;f298
	defb 000h		;f299
	defb 0ffh		;f29a
	defb 000h		;f29b
	defb 0ffh		;f29c
	defb 020h		;f29d
	defb 000h		;f29e
	defb 000h		;f29f
	defb 03fh		;f2a0
	defb 020h		;f2a1
	defb 0ffh		;f2a2
	defb 028h		;f2a3
	defb 0ffh		;f2a4
	defb 000h		;f2a5
	defb 000h		;f2a6
	defb 000h		;f2a7
	defb 07fh		;f2a8
	defb 000h		;f2a9
	defb 0ffh		;f2aa
	defb 000h		;f2ab
	defb 0ffh		;f2ac
	defb 000h		;f2ad
	defb 000h		;f2ae
	defb 000h		;f2af
	defb 07fh		;f2b0
	defb 000h		;f2b1
	defb 0ffh		;f2b2
	defb 001h		;f2b3
	defb 0ffh		;f2b4
	defb 000h		;f2b5
	defb 000h		;f2b6
	defb 000h		;f2b7
	defb 0ffh		;f2b8
	defb 000h		;f2b9
	defb 0ffh		;f2ba
	defb 000h		;f2bb
	defb 0ffh		;f2bc
	defb 000h		;f2bd
	defb 000h		;f2be
	defb 000h		;f2bf
	defb 0feh		;f2c0
	defb 020h		;f2c1
	defb 0ffh		;f2c2
	defb 000h		;f2c3
	defb 0ffh		;f2c4
	defb 002h		;f2c5
	defb 000h		;f2c6
	defb 000h		;f2c7
	defb 0ffh		;f2c8
	defb 000h		;f2c9
	defb 0ffh		;f2ca
	defb 000h		;f2cb
	defb 0ffh		;f2cc
	defb 000h		;f2cd
	defb 000h		;f2ce
	defb 000h		;f2cf
	defb 0f7h		;f2d0
	defb 000h		;f2d1
	defb 0ffh		;f2d2
	defb 022h		;f2d3
	defb 0ffh		;f2d4
	defb 000h		;f2d5
	defb 000h		;f2d6
	defb 000h		;f2d7
	defb 0ffh		;f2d8
	defb 000h		;f2d9
	defb 0ffh		;f2da
	defb 082h		;f2db
	defb 0ffh		;f2dc
	defb 000h		;f2dd
	defb 000h		;f2de
	defb 000h		;f2df
	defb 0b5h		;f2e0
	defb 040h		;f2e1
	defb 0ffh		;f2e2
	defb 000h		;f2e3
	defb 0ffh		;f2e4
	defb 000h		;f2e5
	defb 000h		;f2e6
	defb 000h		;f2e7
	defb 0ffh		;f2e8
	defb 000h		;f2e9
	defb 0ffh		;f2ea
	defb 000h		;f2eb
	defb 0ffh		;f2ec
	defb 004h		;f2ed
	defb 000h		;f2ee
	defb 000h		;f2ef
	defb 0ffh		;f2f0
	defb 000h		;f2f1
	defb 0ffh		;f2f2
	defb 000h		;f2f3
	defb 0ffh		;f2f4
	defb 040h		;f2f5
	defb 000h		;f2f6
	defb 000h		;f2f7
	defb 0efh		;f2f8
	defb 000h		;f2f9
	defb 0ffh		;f2fa
	defb 0a0h		;f2fb
	defb 0ffh		;f2fc
	defb 000h		;f2fd
	defb 000h		;f2fe
	defb 000h		;f2ff
	defb 0bah		;f300
	defb 000h		;f301
	defb 0ffh		;f302
	defb 010h		;f303
	defb 0ffh		;f304
	defb 000h		;f305
	defb 000h		;f306
	defb 000h		;f307
	defb 0ffh		;f308
	defb 000h		;f309
	defb 0ffh		;f30a
	defb 080h		;f30b
	defb 0ffh		;f30c
	defb 000h		;f30d
	defb 000h		;f30e
	defb 000h		;f30f
	defb 0efh		;f310
	defb 000h		;f311
	defb 0ffh		;f312
	defb 084h		;f313
	defb 0ffh		;f314
	defb 000h		;f315
	defb 000h		;f316
	defb 000h		;f317
	defb 0b3h		;f318
	defb 000h		;f319
	defb 0ffh		;f31a
	defb 048h		;f31b
	defb 0ffh		;f31c
	defb 000h		;f31d
	defb 000h		;f31e
	defb 000h		;f31f
	defb 0f9h		;f320
	defb 000h		;f321
	defb 0ffh		;f322
	defb 010h		;f323
	defb 0ffh		;f324
	defb 000h		;f325
	defb 000h		;f326
	defb 000h		;f327
	defb 0ffh		;f328
	defb 000h		;f329
	defb 0ffh		;f32a
	defb 020h		;f32b
	defb 0ffh		;f32c
	defb 000h		;f32d
	defb 000h		;f32e
	defb 000h		;f32f
	defb 0ffh		;f330
	defb 000h		;f331
	defb 0ffh		;f332
	defb 020h		;f333
	defb 0ffh		;f334
	defb 000h		;f335
	defb 000h		;f336
	defb 000h		;f337
	defb 0ffh		;f338
	defb 000h		;f339
	defb 0ffh		;f33a
	defb 000h		;f33b
	defb 0ffh		;f33c
	defb 000h		;f33d
	defb 000h		;f33e
	defb 000h		;f33f
	defb 0eeh		;f340
	defb 000h		;f341
	defb 0ffh		;f342
	defb 080h		;f343
	defb 0ffh		;f344
	defb 010h		;f345
	defb 000h		;f346
	defb 000h		;f347
	defb 0ffh		;f348
	defb 000h		;f349
	defb 0ffh		;f34a
	defb 000h		;f34b
	defb 0ffh		;f34c
	defb 000h		;f34d
	defb 000h		;f34e
	defb 000h		;f34f
	defb 0ffh		;f350
	defb 000h		;f351
	defb 0ffh		;f352
	defb 004h		;f353
	defb 0efh		;f354
	defb 002h		;f355
	defb 000h		;f356
	defb 000h		;f357
	defb 0f6h		;f358
	defb 010h		;f359
	defb 0ffh		;f35a
	defb 000h		;f35b
	defb 0bfh		;f35c
	defb 000h		;f35d
	defb 000h		;f35e
	defb 000h		;f35f
	defb 0ffh		;f360
	defb 000h		;f361
	defb 0ffh		;f362
	defb 000h		;f363
	defb 0ffh		;f364
	defb 000h		;f365
	defb 000h		;f366
	defb 000h		;f367
	defb 07ah		;f368
	defb 000h		;f369
	defb 0ffh		;f36a
	defb 000h		;f36b
	defb 0ffh		;f36c
	defb 010h		;f36d
CDISK:
	defb 000h		;f36e
	defb 000h		;f36f
	defb 0ffh		;f370
	defb 000h		;f371
	defb 0ffh		;f372
	defb 020h		;f373
	defb 0ffh		;f374
	defb 000h		;f375
	defb 000h		;f376
	defb 000h		;f377
	defb 0fdh		;f378
	defb 000h		;f379
	defb 0ffh		;f37a
	defb 008h		;f37b
	defb 0ffh		;f37c
	defb 000h		;f37d
	defb 000h		;f37e
	defb 000h		;f37f
	defb 0ffh		;f380
	defb 040h		;f381
	defb 0ffh		;f382
	defb 040h		;f383
	defb 0ffh		;f384
	defb 000h		;f385
	defb 000h		;f386
	defb 000h		;f387
	defb 0ffh		;f388
	defb 048h		;f389
	defb 0ffh		;f38a
	defb 010h		;f38b
	defb 0ffh		;f38c
	defb 000h		;f38d
	defb 000h		;f38e
	defb 000h		;f38f
	defb 0ffh		;f390
	defb 000h		;f391
	defb 0ffh		;f392
	defb 004h		;f393
	defb 0ffh		;f394
	defb 000h		;f395
	defb 000h		;f396
	defb 000h		;f397
	defb 0dfh		;f398
	defb 004h		;f399
	defb 0ffh		;f39a
	defb 050h		;f39b
	defb 0ffh		;f39c
	defb 041h		;f39d
	defb 000h		;f39e
	defb 000h		;f39f
	defb 0ffh		;f3a0
	defb 000h		;f3a1
	defb 0ffh		;f3a2
	defb 010h		;f3a3
	defb 0ffh		;f3a4
	defb 000h		;f3a5
	defb 000h		;f3a6
	defb 000h		;f3a7
	defb 07fh		;f3a8
	defb 000h		;f3a9
	defb 0ffh		;f3aa
	defb 000h		;f3ab
	defb 0ffh		;f3ac
	defb 000h		;f3ad
	defb 000h		;f3ae
	defb 000h		;f3af
	defb 0fdh		;f3b0
	defb 042h		;f3b1
	defb 0ffh		;f3b2
	defb 080h		;f3b3
	defb 0ffh		;f3b4
	defb 001h		;f3b5
	defb 000h		;f3b6
	defb 000h		;f3b7
	defb 0ffh		;f3b8
	defb 000h		;f3b9
	defb 0ffh		;f3ba
	defb 048h		;f3bb
	defb 0ffh		;f3bc
	defb 001h		;f3bd
	defb 000h		;f3be
	defb 000h		;f3bf
	defb 0ddh		;f3c0
	defb 000h		;f3c1
	defb 0ffh		;f3c2
	defb 0e0h		;f3c3
	defb 0ffh		;f3c4
	defb 000h		;f3c5
	defb 000h		;f3c6
	defb 000h		;f3c7
	defb 0fch		;f3c8
	defb 000h		;f3c9
	defb 0ffh		;f3ca
	defb 002h		;f3cb
	defb 0ffh		;f3cc
	defb 000h		;f3cd
	defb 000h		;f3ce
	defb 000h		;f3cf
	defb 0ffh		;f3d0
	defb 000h		;f3d1
	defb 0ffh		;f3d2
	defb 000h		;f3d3
	defb 0feh		;f3d4
	defb 000h		;f3d5
	defb 000h		;f3d6
	defb 000h		;f3d7
	defb 07fh		;f3d8
	defb 000h		;f3d9
	defb 0ffh		;f3da
	defb 002h		;f3db
	defb 0ffh		;f3dc
	defb 000h		;f3dd
	defb 000h		;f3de
	defb 000h		;f3df
	defb 0fdh		;f3e0
	defb 000h		;f3e1
	defb 0ffh		;f3e2
	defb 021h		;f3e3
	defb 0ffh		;f3e4
	defb 000h		;f3e5
	defb 000h		;f3e6
	defb 000h		;f3e7
	defb 0ffh		;f3e8
	defb 000h		;f3e9
	defb 0ffh		;f3ea
	defb 010h		;f3eb
	defb 0ffh		;f3ec
	defb 000h		;f3ed
	defb 000h		;f3ee
	defb 000h		;f3ef
	defb 03fh		;f3f0
	defb 000h		;f3f1
	defb 0ffh		;f3f2
	defb 0c1h		;f3f3
	defb 0ffh		;f3f4
	defb 000h		;f3f5
	defb 000h		;f3f6
	defb 000h		;f3f7
	defb 0dfh		;f3f8
	defb 000h		;f3f9
	defb 0ffh		;f3fa
	defb 000h		;f3fb
	defb 0ffh		;f3fc
	defb 000h		;f3fd
	defb 000h		;f3fe
	defb 000h		;f3ff
	defb 0cfh		;f400
	defb 000h		;f401
	defb 0ffh		;f402
	defb 000h		;f403
	defb 0ffh		;f404
	defb 000h		;f405
	defb 000h		;f406
	defb 000h		;f407
	defb 0ffh		;f408
	defb 084h		;f409
	defb 0ffh		;f40a
	defb 004h		;f40b
	defb 0ffh		;f40c
	defb 000h		;f40d
	defb 000h		;f40e
	defb 000h		;f40f
	defb 0fch		;f410
	defb 000h		;f411
	defb 0ffh		;f412
	defb 048h		;f413
	defb 0ffh		;f414
	defb 004h		;f415
	defb 000h		;f416
	defb 000h		;f417
	defb 0eeh		;f418
	defb 000h		;f419
	defb 0ffh		;f41a
	defb 02ch		;f41b
	defb 0ffh		;f41c
	defb 040h		;f41d
	defb 000h		;f41e
	defb 000h		;f41f
	defb 0ffh		;f420
	defb 000h		;f421
	defb 0ffh		;f422
	defb 001h		;f423
	defb 0ffh		;f424
	defb 000h		;f425
	defb 000h		;f426
	defb 000h		;f427
	defb 0f7h		;f428
	defb 080h		;f429
	defb 0ffh		;f42a
	defb 002h		;f42b
	defb 0fbh		;f42c
	defb 000h		;f42d
	defb 000h		;f42e
	defb 000h		;f42f
	defb 0f8h		;f430
	defb 000h		;f431
	defb 0efh		;f432
	defb 090h		;f433
	defb 0ffh		;f434
	defb 000h		;f435
	defb 000h		;f436
	defb 000h		;f437
	defb 0dfh		;f438
	defb 000h		;f439
	defb 0ffh		;f43a
	defb 08ah		;f43b
	defb 0ffh		;f43c
	defb 000h		;f43d
	defb 000h		;f43e
	defb 000h		;f43f
	defb 0f7h		;f440
	defb 000h		;f441
	defb 0ffh		;f442
	defb 006h		;f443
	defb 0ffh		;f444
	defb 000h		;f445
	defb 000h		;f446
	defb 000h		;f447
	defb 0fbh		;f448
	defb 000h		;f449
	defb 0ffh		;f44a
	defb 000h		;f44b
	defb 0dfh		;f44c
	defb 000h		;f44d
	defb 000h		;f44e
	defb 000h		;f44f
	defb 0ffh		;f450
	defb 000h		;f451
	defb 0ffh		;f452
	defb 090h		;f453
	defb 0ffh		;f454
	defb 000h		;f455
	defb 000h		;f456
	defb 000h		;f457
	defb 07fh		;f458
	defb 000h		;f459
	defb 0ffh		;f45a
	defb 001h		;f45b
	defb 0ffh		;f45c
	defb 000h		;f45d
	defb 000h		;f45e
	defb 000h		;f45f
	defb 0f7h		;f460
	defb 008h		;f461
	defb 0ffh		;f462
	defb 000h		;f463
	defb 0ffh		;f464
	defb 000h		;f465
	defb 000h		;f466
	defb 000h		;f467
	defb 0fbh		;f468
	defb 000h		;f469
	defb 0ffh		;f46a
	defb 008h		;f46b
	defb 0ffh		;f46c
	defb 000h		;f46d
	defb 000h		;f46e
	defb 000h		;f46f
	defb 0bbh		;f470
	defb 000h		;f471
	defb 0ffh		;f472
	defb 000h		;f473
	defb 0ffh		;f474
	defb 000h		;f475
	defb 000h		;f476
	defb 000h		;f477
	defb 0f6h		;f478
	defb 040h		;f479
	defb 0ffh		;f47a
	defb 000h		;f47b
	defb 0ffh		;f47c
	defb 080h		;f47d
	defb 000h		;f47e
	defb 000h		;f47f
	defb 0feh		;f480
	defb 024h		;f481
lf482h:
	defb 0ffh		;f482
lf483h:
	defb 022h		;f483
	defb 0ffh		;f484
lf485h:
	defb 000h		;f485
	defb 000h		;f486
lf487h:
	defb 000h		;f487
lf488h:
	defb 0b7h		;f488
lf489h:
	defb 008h		;f489
lf48ah:
	defb 0ffh		;f48a
	defb 080h		;f48b
lf48ch:
	defb 0ffh		;f48c
lf48dh:
	defb 000h		;f48d
lf48eh:
	defb 000h		;f48e
lf48fh:
	defb 000h		;f48f
	defb 0fdh		;f490
lf491h:
	defb 000h		;f491
lf492h:
	defb 0fbh		;f492
lf493h:
	defb 040h		;f493
lf494h:
	defb 0ffh		;f494
lf495h:
	defb 000h		;f495
	defb 000h		;f496
lf497h:
	defb 000h		;f497
	defb 0ffh		;f498
lf499h:
	defb 000h		;f499
RAMDSTAT:
	defb 0ffh		;f49a
lf49bh:
	defb 001h		;f49b
lf49ch:
	defb 0ffh		;f49c
lf49dh:
	defb 000h		;f49d
lf49eh:
	defb 000h		;f49e
	defb 000h		;f49f
lf4a0h:
	defb 0fbh		;f4a0
	defb 042h		;f4a1
lf4a2h:
	defb 0ffh		;f4a2
lf4a3h:
	defb 000h		;f4a3
lf4a4h:
	defb 0ffh		;f4a4
lf4a5h:
	defb 010h		;f4a5
lf4a6h:
	defb 000h		;f4a6
lf4a7h:
	defb 000h		;f4a7
lf4a8h:
	defb 0feh		;f4a8
lf4a9h:
	defb 000h		;f4a9
WARMJP2:
	defb 0ffh		;f4aa
lf4abh:
	defb 000h		;f4ab
	defb 0ffh		;f4ac
	defb 000h		;f4ad
	defb 000h		;f4ae
	defb 000h		;f4af
	defb 0ffh		;f4b0
	defb 000h		;f4b1
lf4b2h:
	defb 0ffh		;f4b2
	defb 000h		;f4b3
lf4b4h:
	defb 0ffh		;f4b4
lf4b5h:
	defb 000h		;f4b5
lf4b6h:
	defb 000h		;f4b6
lf4b7h:
	defb 000h		;f4b7
lf4b8h:
	defb 0fah		;f4b8
lf4b9h:
	defb 050h		;f4b9
lf4bah:
	defb 0ffh		;f4ba
	defb 094h		;f4bb
lf4bch:
	defb 0ffh		;f4bc
lf4bdh:
	defb 000h		;f4bd
lf4beh:
	defb 000h		;f4be
	defb 000h		;f4bf
lf4c0h:
	defb 0ffh		;f4c0
	defb 000h		;f4c1
	defb 0ffh		;f4c2
	defb 000h		;f4c3
	defb 0ffh		;f4c4
	defb 040h		;f4c5
	defb 000h		;f4c6
	defb 000h		;f4c7
lf4c8h:
	defb 0feh		;f4c8
lf4c9h:
	defb 000h		;f4c9
SIOFLG:
	defb 0fbh		;f4ca
lf4cbh:
	defb 011h		;f4cb
SIOFLG2:
	defb 0ffh		;f4cc
lf4cdh:
	defb 000h		;f4cd
lf4ceh:
	defb 000h		;f4ce
lf4cfh:
	defb 000h		;f4cf
lf4d0h:
	defb 0ffh		;f4d0
lf4d1h:
	defb 000h		;f4d1
lf4d2h:
	defb 0ffh		;f4d2
lf4d3h:
	defb 000h		;f4d3
lf4d4h:
	defb 0ffh		;f4d4
	defb 000h		;f4d5
lf4d6h:
	defb 000h		;f4d6
	defb 000h		;f4d7
lf4d8h:
	defb 0ffh		;f4d8
	defb 000h		;f4d9
	defb 0ffh		;f4da
	defb 040h		;f4db
lf4dch:
	defb 0f7h		;f4dc
	defb 000h		;f4dd
	defb 000h		;f4de
lf4dfh:
	defb 000h		;f4df
	defb 0ffh		;f4e0
	defb 000h		;f4e1
lf4e2h:
	defb 0ffh		;f4e2
	defb 002h		;f4e3
	defb 0ffh		;f4e4
lf4e5h:
	defb 000h		;f4e5
lf4e6h:
	defb 000h		;f4e6
	defb 000h		;f4e7
	defb 0ffh		;f4e8
	defb 001h		;f4e9
	defb 0ffh		;f4ea
	defb 004h		;f4eb
	defb 0ffh		;f4ec
	defb 000h		;f4ed
	defb 000h		;f4ee
	defb 000h		;f4ef
	defb 0ffh		;f4f0
	defb 000h		;f4f1
	defb 0ffh		;f4f2
	defb 000h		;f4f3
	defb 0ffh		;f4f4
	defb 000h		;f4f5
	defb 000h		;f4f6
	defb 000h		;f4f7
	defb 09fh		;f4f8
	defb 008h		;f4f9
	defb 0ffh		;f4fa
	defb 002h		;f4fb
	defb 0ffh		;f4fc
	defb 000h		;f4fd
	defb 000h		;f4fe
	defb 000h		;f4ff
ATTRBUF:
	defb 0ffh		;f500
	defb 00ah		;f501
	defb 0fdh		;f502
	defb 019h		;f503
	defb 0ffh		;f504
	defb 000h		;f505
	defb 000h		;f506
	defb 000h		;f507
	defb 0aeh		;f508
	defb 000h		;f509
	defb 0ffh		;f50a
	defb 004h		;f50b
	defb 0ffh		;f50c
	defb 000h		;f50d
	defb 000h		;f50e
	defb 000h		;f50f
	defb 09bh		;f510
	defb 000h		;f511
	defb 0ffh		;f512
	defb 000h		;f513
	defb 0ffh		;f514
	defb 000h		;f515
	defb 000h		;f516
	defb 000h		;f517
	defb 0fdh		;f518
	defb 000h		;f519
	defb 0ffh		;f51a
	defb 021h		;f51b
	defb 0ffh		;f51c
	defb 000h		;f51d
lf51eh:
	defb 000h		;f51e
	defb 000h		;f51f
	defb 0ffh		;f520
	defb 020h		;f521
	defb 0ffh		;f522
	defb 083h		;f523
	defb 0ffh		;f524
	defb 000h		;f525
	defb 000h		;f526
	defb 000h		;f527
	defb 0ffh		;f528
	defb 000h		;f529
	defb 0ffh		;f52a
	defb 020h		;f52b
	defb 0ffh		;f52c
	defb 000h		;f52d
	defb 000h		;f52e
	defb 000h		;f52f
	defb 0ffh		;f530
	defb 001h		;f531
	defb 0ffh		;f532
	defb 080h		;f533
	defb 0ffh		;f534
	defb 081h		;f535
	defb 000h		;f536
	defb 000h		;f537
	defb 0efh		;f538
	defb 080h		;f539
	defb 0ffh		;f53a
	defb 080h		;f53b
	defb 0ffh		;f53c
	defb 000h		;f53d
	defb 000h		;f53e
	defb 000h		;f53f
	defb 0fdh		;f540
	defb 040h		;f541
	defb 0ffh		;f542
	defb 009h		;f543
	defb 0ffh		;f544
	defb 000h		;f545
	defb 000h		;f546
	defb 000h		;f547
	defb 0ffh		;f548
	defb 088h		;f549
	defb 0ffh		;f54a
	defb 000h		;f54b
	defb 0fbh		;f54c
	defb 000h		;f54d
	defb 000h		;f54e
	defb 000h		;f54f
	defb 0ffh		;f550
	defb 000h		;f551
	defb 0bfh		;f552
	defb 044h		;f553
	defb 0ffh		;f554
	defb 000h		;f555
	defb 000h		;f556
	defb 000h		;f557
	defb 0ffh		;f558
	defb 040h		;f559
	defb 0ffh		;f55a
	defb 000h		;f55b
	defb 0ffh		;f55c
	defb 000h		;f55d
	defb 000h		;f55e
	defb 000h		;f55f
	defb 0ffh		;f560
	defb 020h		;f561
	defb 0ffh		;f562
	defb 008h		;f563
	defb 0ffh		;f564
	defb 000h		;f565
	defb 000h		;f566
	defb 000h		;f567
	defb 0ffh		;f568
	defb 000h		;f569
	defb 0ffh		;f56a
	defb 000h		;f56b
	defb 0ffh		;f56c
	defb 000h		;f56d
	defb 000h		;f56e
	defb 000h		;f56f
	defb 0ffh		;f570
	defb 000h		;f571
	defb 0ffh		;f572
	defb 002h		;f573
	defb 0ffh		;f574
	defb 020h		;f575
	defb 000h		;f576
	defb 000h		;f577
lf578h:
	defb 0efh		;f578
	defb 001h		;f579
	defb 0ffh		;f57a
	defb 000h		;f57b
	defb 0ffh		;f57c
	defb 000h		;f57d
	defb 000h		;f57e
	defb 000h		;f57f
lf580h:
	defb 0ffh		;f580
	defb 000h		;f581
	defb 0ffh		;f582
	defb 000h		;f583
	defb 0ffh		;f584
	defb 000h		;f585
	defb 000h		;f586
	defb 000h		;f587
	defb 0dfh		;f588
lf589h:
	defb 000h		;f589
	defb 0f6h		;f58a
lf58bh:
	defb 000h		;f58b
	defb 0ffh		;f58c
	defb 010h		;f58d
	defb 000h		;f58e
	defb 000h		;f58f
	defb 0ffh		;f590
	defb 000h		;f591
	defb 0ffh		;f592
	defb 002h		;f593
	defb 0ffh		;f594
lf595h:
	defb 000h		;f595
	defb 000h		;f596
lf597h:
	defb 000h		;f597
lf598h:
	defb 0feh		;f598
	defb 004h		;f599
lf59ah:
	defb 0ffh		;f59a
	defb 042h		;f59b
	defb 0ffh		;f59c
	defb 000h		;f59d
	defb 000h		;f59e
	defb 000h		;f59f
	defb 03fh		;f5a0
	defb 000h		;f5a1
	defb 0ffh		;f5a2
	defb 000h		;f5a3
	defb 0ffh		;f5a4
	defb 000h		;f5a5
	defb 000h		;f5a6
	defb 000h		;f5a7
	defb 0fbh		;f5a8
	defb 000h		;f5a9
	defb 0ffh		;f5aa
	defb 040h		;f5ab
	defb 0ffh		;f5ac
	defb 000h		;f5ad
	defb 000h		;f5ae
	defb 000h		;f5af
	defb 0ffh		;f5b0
	defb 000h		;f5b1
	defb 0ffh		;f5b2
	defb 008h		;f5b3
	defb 0ffh		;f5b4
	defb 000h		;f5b5
	defb 000h		;f5b6
	defb 000h		;f5b7
	defb 0ffh		;f5b8
	defb 002h		;f5b9
	defb 0ffh		;f5ba
	defb 000h		;f5bb
	defb 0ffh		;f5bc
	defb 080h		;f5bd
	defb 000h		;f5be
	defb 000h		;f5bf
	defb 03fh		;f5c0
	defb 000h		;f5c1
	defb 0ffh		;f5c2
	defb 089h		;f5c3
	defb 0ffh		;f5c4
	defb 000h		;f5c5
	defb 000h		;f5c6
	defb 000h		;f5c7
	defb 0ffh		;f5c8
	defb 000h		;f5c9
	defb 0ffh		;f5ca
	defb 044h		;f5cb
	defb 0ffh		;f5cc
	defb 000h		;f5cd
	defb 000h		;f5ce
	defb 000h		;f5cf
	defb 0dfh		;f5d0
	defb 090h		;f5d1
	defb 0ffh		;f5d2
	defb 080h		;f5d3
	defb 0ffh		;f5d4
	defb 000h		;f5d5
	defb 000h		;f5d6
	defb 000h		;f5d7
	defb 0ffh		;f5d8
	defb 014h		;f5d9
	defb 0ffh		;f5da
	defb 010h		;f5db
	defb 0ffh		;f5dc
	defb 000h		;f5dd
	defb 000h		;f5de
	defb 000h		;f5df
	defb 0ffh		;f5e0
	defb 000h		;f5e1
	defb 0ffh		;f5e2
	defb 008h		;f5e3
	defb 0ffh		;f5e4
	defb 000h		;f5e5
	defb 000h		;f5e6
	defb 000h		;f5e7
	defb 07fh		;f5e8
	defb 000h		;f5e9
	defb 0ffh		;f5ea
	defb 004h		;f5eb
	defb 0ffh		;f5ec
	defb 000h		;f5ed
	defb 000h		;f5ee
	defb 000h		;f5ef
	defb 0feh		;f5f0
	defb 000h		;f5f1
	defb 0ffh		;f5f2
	defb 001h		;f5f3
	defb 0ffh		;f5f4
	defb 000h		;f5f5
	defb 000h		;f5f6
	defb 000h		;f5f7
	defb 0fdh		;f5f8
	defb 012h		;f5f9
	defb 0ffh		;f5fa
	defb 04ah		;f5fb
	defb 0ffh		;f5fc
	defb 000h		;f5fd
	defb 000h		;f5fe
	defb 000h		;f5ff
	defb 0fbh		;f600
	defb 020h		;f601
	defb 0ffh		;f602
	defb 041h		;f603
	defb 0ffh		;f604
	defb 000h		;f605
	defb 000h		;f606
	defb 000h		;f607
	defb 0c7h		;f608
	defb 002h		;f609
	defb 0ffh		;f60a
	defb 001h		;f60b
	defb 0ffh		;f60c
	defb 008h		;f60d
	defb 000h		;f60e
	defb 000h		;f60f
	defb 0ffh		;f610
	defb 000h		;f611
	defb 0ffh		;f612
	defb 000h		;f613
	defb 0ffh		;f614
	defb 000h		;f615
	defb 000h		;f616
	defb 000h		;f617
	defb 0ffh		;f618
	defb 000h		;f619
	defb 0ffh		;f61a
	defb 0c5h		;f61b
	defb 0fdh		;f61c
	defb 000h		;f61d
	defb 000h		;f61e
	defb 000h		;f61f
ISRSTACK:
	defb 0fdh		;f620
	defb 042h		;f621
	defb 0ffh		;f622
	defb 000h		;f623
	defb 0ffh		;f624
	defb 000h		;f625
	defb 000h		;f626
	defb 000h		;f627
	defb 0efh		;f628
	defb 004h		;f629
	defb 0ffh		;f62a
	defb 00ch		;f62b
	defb 0ffh		;f62c
	defb 000h		;f62d
	defb 000h		;f62e
	defb 000h		;f62f
	defb 0ffh		;f630
	defb 008h		;f631
	defb 0ffh		;f632
	defb 094h		;f633
	defb 0ffh		;f634
	defb 000h		;f635
	defb 000h		;f636
	defb 000h		;f637
	defb 08fh		;f638
	defb 002h		;f639
	defb 0ffh		;f63a
	defb 002h		;f63b
	defb 0ffh		;f63c
	defb 000h		;f63d
	defb 000h		;f63e
	defb 000h		;f63f
	defb 0feh		;f640
	defb 000h		;f641
	defb 0bfh		;f642
	defb 000h		;f643
	defb 0ffh		;f644
	defb 000h		;f645
	defb 000h		;f646
	defb 000h		;f647
	defb 0ffh		;f648
	defb 010h		;f649
	defb 0ffh		;f64a
	defb 000h		;f64b
	defb 0ffh		;f64c
	defb 000h		;f64d
	defb 000h		;f64e
	defb 000h		;f64f
	defb 0ffh		;f650
	defb 002h		;f651
	defb 0ffh		;f652
	defb 000h		;f653
	defb 0ffh		;f654
	defb 000h		;f655
	defb 000h		;f656
	defb 000h		;f657
	defb 0ffh		;f658
	defb 000h		;f659
	defb 0ffh		;f65a
	defb 000h		;f65b
	defb 0ffh		;f65c
	defb 000h		;f65d
	defb 000h		;f65e
	defb 000h		;f65f
	defb 07fh		;f660
	defb 000h		;f661
	defb 0ffh		;f662
	defb 000h		;f663
	defb 0ffh		;f664
	defb 000h		;f665
	defb 000h		;f666
	defb 000h		;f667
	defb 0f9h		;f668
	defb 002h		;f669
	defb 0ffh		;f66a
	defb 040h		;f66b
	defb 0ffh		;f66c
	defb 000h		;f66d
	defb 000h		;f66e
	defb 000h		;f66f
	defb 0ffh		;f670
	defb 080h		;f671
	defb 0ffh		;f672
	defb 000h		;f673
	defb 0ffh		;f674
	defb 000h		;f675
	defb 000h		;f676
	defb 000h		;f677
	defb 0fbh		;f678
	defb 000h		;f679
	defb 0ffh		;f67a
	defb 004h		;f67b
	defb 0ffh		;f67c
	defb 000h		;f67d
	defb 000h		;f67e
	defb 000h		;f67f
CONVTAB:
	defb 0ffh		;f680
	defb 006h		;f681
	defb 0ffh		;f682
	defb 000h		;f683
	defb 0ffh		;f684
	defb 000h		;f685
	defb 000h		;f686
	defb 000h		;f687
	defb 0fdh		;f688
	defb 000h		;f689
	defb 0ffh		;f68a
	defb 080h		;f68b
	defb 0ffh		;f68c
	defb 000h		;f68d
	defb 000h		;f68e
	defb 000h		;f68f
	defb 0ffh		;f690
	defb 000h		;f691
	defb 0ffh		;f692
	defb 000h		;f693
	defb 0ffh		;f694
	defb 000h		;f695
	defb 000h		;f696
	defb 000h		;f697
	defb 0f6h		;f698
	defb 000h		;f699
	defb 0ffh		;f69a
	defb 002h		;f69b
	defb 0ffh		;f69c
	defb 044h		;f69d
	defb 000h		;f69e
	defb 000h		;f69f
	defb 0f6h		;f6a0
	defb 010h		;f6a1
	defb 0ffh		;f6a2
	defb 000h		;f6a3
	defb 0ffh		;f6a4
	defb 000h		;f6a5
	defb 000h		;f6a6
	defb 000h		;f6a7
	defb 0bfh		;f6a8
	defb 000h		;f6a9
	defb 0ffh		;f6aa
	defb 000h		;f6ab
	defb 0ffh		;f6ac
	defb 000h		;f6ad
	defb 000h		;f6ae
	defb 000h		;f6af
	defb 0ffh		;f6b0
	defb 010h		;f6b1
	defb 0ffh		;f6b2
	defb 001h		;f6b3
	defb 0ffh		;f6b4
	defb 000h		;f6b5
	defb 000h		;f6b6
	defb 000h		;f6b7
	defb 0efh		;f6b8
	defb 000h		;f6b9
	defb 0ffh		;f6ba
	defb 040h		;f6bb
	defb 0ffh		;f6bc
	defb 000h		;f6bd
	defb 000h		;f6be
	defb 000h		;f6bf
	defb 0ffh		;f6c0
	defb 000h		;f6c1
	defb 0ffh		;f6c2
	defb 002h		;f6c3
	defb 0ffh		;f6c4
	defb 000h		;f6c5
	defb 000h		;f6c6
	defb 000h		;f6c7
	defb 0ffh		;f6c8
	defb 000h		;f6c9
	defb 0ffh		;f6ca
	defb 000h		;f6cb
	defb 0ffh		;f6cc
	defb 000h		;f6cd
	defb 001h		;f6ce
	defb 000h		;f6cf
	defb 07fh		;f6d0
	defb 000h		;f6d1
	defb 0ffh		;f6d2
	defb 014h		;f6d3
	defb 0ffh		;f6d4
	defb 000h		;f6d5
	defb 000h		;f6d6
	defb 000h		;f6d7
	defb 0ffh		;f6d8
	defb 040h		;f6d9
	defb 0ffh		;f6da
	defb 020h		;f6db
	defb 0ffh		;f6dc
	defb 000h		;f6dd
	defb 000h		;f6de
	defb 000h		;f6df
	defb 0ffh		;f6e0
	defb 000h		;f6e1
	defb 0ffh		;f6e2
	defb 000h		;f6e3
	defb 0ffh		;f6e4
	defb 000h		;f6e5
	defb 000h		;f6e6
	defb 000h		;f6e7
	defb 0f3h		;f6e8
	defb 000h		;f6e9
	defb 0ffh		;f6ea
	defb 060h		;f6eb
	defb 0ffh		;f6ec
	defb 000h		;f6ed
	defb 000h		;f6ee
	defb 000h		;f6ef
	defb 0f7h		;f6f0
	defb 0a0h		;f6f1
	defb 0ffh		;f6f2
	defb 004h		;f6f3
	defb 0ffh		;f6f4
	defb 000h		;f6f5
	defb 000h		;f6f6
	defb 000h		;f6f7
	defb 0ffh		;f6f8
	defb 000h		;f6f9
	defb 0ffh		;f6fa
	defb 0aah		;f6fb
	defb 0ffh		;f6fc
	defb 000h		;f6fd
	defb 000h		;f6fe
	defb 000h		;f6ff
CONVTAB2:
	defb 06bh		;f700
	defb 004h		;f701
	defb 0ffh		;f702
	defb 008h		;f703
	defb 0ffh		;f704
	defb 000h		;f705
	defb 000h		;f706
	defb 000h		;f707
	defb 0dbh		;f708
	defb 010h		;f709
	defb 0ffh		;f70a
	defb 050h		;f70b
	defb 0ffh		;f70c
	defb 000h		;f70d
	defb 000h		;f70e
	defb 000h		;f70f
	defb 0ffh		;f710
	defb 000h		;f711
	defb 0ffh		;f712
	defb 000h		;f713
	defb 0ffh		;f714
	defb 000h		;f715
	defb 000h		;f716
	defb 000h		;f717
	defb 0ffh		;f718
	defb 000h		;f719
	defb 0ffh		;f71a
	defb 009h		;f71b
	defb 0ffh		;f71c
	defb 000h		;f71d
	defb 000h		;f71e
	defb 000h		;f71f
	defb 0ffh		;f720
	defb 020h		;f721
	defb 0ffh		;f722
	defb 002h		;f723
	defb 0ffh		;f724
	defb 000h		;f725
	defb 000h		;f726
	defb 000h		;f727
	defb 0fdh		;f728
	defb 002h		;f729
	defb 0ffh		;f72a
	defb 008h		;f72b
	defb 0ffh		;f72c
	defb 000h		;f72d
	defb 000h		;f72e
	defb 000h		;f72f
	defb 0ffh		;f730
	defb 000h		;f731
	defb 0ffh		;f732
	defb 020h		;f733
	defb 0ffh		;f734
	defb 000h		;f735
	defb 000h		;f736
	defb 000h		;f737
	defb 0bbh		;f738
	defb 020h		;f739
	defb 0ffh		;f73a
	defb 000h		;f73b
	defb 0ffh		;f73c
	defb 000h		;f73d
	defb 000h		;f73e
	defb 000h		;f73f
	defb 0ffh		;f740
	defb 000h		;f741
	defb 0ffh		;f742
	defb 008h		;f743
	defb 0ffh		;f744
	defb 000h		;f745
	defb 000h		;f746
	defb 000h		;f747
	defb 0ffh		;f748
	defb 000h		;f749
	defb 0ffh		;f74a
	defb 018h		;f74b
	defb 0ffh		;f74c
	defb 001h		;f74d
	defb 000h		;f74e
	defb 000h		;f74f
	defb 0ddh		;f750
	defb 000h		;f751
	defb 0ffh		;f752
	defb 040h		;f753
	defb 0ffh		;f754
	defb 000h		;f755
	defb 000h		;f756
	defb 000h		;f757
	defb 0ffh		;f758
	defb 000h		;f759
	defb 0ffh		;f75a
	defb 080h		;f75b
	defb 0ffh		;f75c
	defb 000h		;f75d
	defb 000h		;f75e
	defb 000h		;f75f
	defb 0ffh		;f760
	defb 000h		;f761
	defb 0ffh		;f762
	defb 000h		;f763
	defb 0ffh		;f764
	defb 000h		;f765
	defb 000h		;f766
	defb 000h		;f767
	defb 0ebh		;f768
	defb 000h		;f769
	defb 0ffh		;f76a
	defb 000h		;f76b
	defb 0ffh		;f76c
	defb 000h		;f76d
	defb 000h		;f76e
	defb 000h		;f76f
	defb 0ffh		;f770
	defb 08ch		;f771
	defb 0ffh		;f772
	defb 010h		;f773
	defb 0ffh		;f774
	defb 000h		;f775
	defb 000h		;f776
	defb 000h		;f777
	defb 0fdh		;f778
	defb 000h		;f779
	defb 0ffh		;f77a
	defb 085h		;f77b
	defb 0ffh		;f77c
	defb 000h		;f77d
	defb 000h		;f77e
	defb 000h		;f77f
	defb 0ffh		;f780
	defb 000h		;f781
	defb 0ffh		;f782
	defb 000h		;f783
	defb 0ffh		;f784
	defb 000h		;f785
	defb 000h		;f786
	defb 000h		;f787
	defb 0ffh		;f788
	defb 000h		;f789
	defb 0ffh		;f78a
	defb 031h		;f78b
	defb 0ffh		;f78c
	defb 000h		;f78d
	defb 000h		;f78e
	defb 000h		;f78f
	defb 0feh		;f790
	defb 000h		;f791
	defb 0ffh		;f792
	defb 000h		;f793
	defb 0fbh		;f794
	defb 000h		;f795
	defb 000h		;f796
	defb 000h		;f797
	defb 0efh		;f798
	defb 082h		;f799
	defb 0ffh		;f79a
	defb 090h		;f79b
	defb 0ffh		;f79c
	defb 000h		;f79d
	defb 000h		;f79e
	defb 000h		;f79f
	defb 0fdh		;f7a0
	defb 080h		;f7a1
	defb 0ffh		;f7a2
	defb 090h		;f7a3
	defb 0ffh		;f7a4
	defb 000h		;f7a5
	defb 000h		;f7a6
	defb 000h		;f7a7
	defb 069h		;f7a8
	defb 000h		;f7a9
	defb 0ffh		;f7aa
	defb 000h		;f7ab
	defb 0ffh		;f7ac
	defb 000h		;f7ad
	defb 000h		;f7ae
	defb 000h		;f7af
	defb 0ffh		;f7b0
	defb 000h		;f7b1
	defb 0ffh		;f7b2
	defb 030h		;f7b3
	defb 0ffh		;f7b4
	defb 000h		;f7b5
	defb 000h		;f7b6
	defb 000h		;f7b7
	defb 0dfh		;f7b8
	defb 040h		;f7b9
	defb 0ffh		;f7ba
	defb 060h		;f7bb
	defb 0ffh		;f7bc
	defb 000h		;f7bd
	defb 000h		;f7be
	defb 000h		;f7bf
	defb 0ffh		;f7c0
	defb 000h		;f7c1
	defb 0ffh		;f7c2
	defb 000h		;f7c3
	defb 0ffh		;f7c4
	defb 000h		;f7c5
	defb 000h		;f7c6
	defb 000h		;f7c7
	defb 0ffh		;f7c8
	defb 000h		;f7c9
	defb 0ffh		;f7ca
	defb 000h		;f7cb
	defb 0ffh		;f7cc
	defb 082h		;f7cd
	defb 000h		;f7ce
	defb 000h		;f7cf
	defb 0ffh		;f7d0
	defb 000h		;f7d1
	defb 0ffh		;f7d2
	defb 021h		;f7d3
	defb 0ffh		;f7d4
	defb 000h		;f7d5
	defb 000h		;f7d6
	defb 000h		;f7d7
	defb 07fh		;f7d8
	defb 004h		;f7d9
	defb 0ffh		;f7da
	defb 080h		;f7db
	defb 0ffh		;f7dc
	defb 020h		;f7dd
	defb 000h		;f7de
	defb 000h		;f7df
	defb 0ffh		;f7e0
	defb 002h		;f7e1
	defb 0ffh		;f7e2
	defb 001h		;f7e3
	defb 0ffh		;f7e4
	defb 000h		;f7e5
	defb 000h		;f7e6
	defb 000h		;f7e7
	defb 0ffh		;f7e8
	defb 000h		;f7e9
	defb 0ffh		;f7ea
	defb 088h		;f7eb
	defb 0ffh		;f7ec
	defb 000h		;f7ed
	defb 000h		;f7ee
	defb 000h		;f7ef
	defb 0ffh		;f7f0
	defb 000h		;f7f1
	defb 0ffh		;f7f2
	defb 020h		;f7f3
	defb 0ffh		;f7f4
	defb 000h		;f7f5
	defb 000h		;f7f6
	defb 000h		;f7f7
	defb 0ffh		;f7f8
	defb 080h		;f7f9
	defb 0ffh		;f7fa
	defb 020h		;f7fb
	defb 0ffh		;f7fc
	defb 000h		;f7fd
	defb 000h		;f7fe
	defb 000h		;f7ff
SCREENBUF:
	defb 0b8h		;f800
lf801h:
	defb 040h		;f801
	defb 0ffh		;f802
	defb 001h		;f803
	defb 0fdh		;f804
lf805h:
	defb 000h		;f805
	defb 000h		;f806
	defb 000h		;f807
	defb 0ffh		;f808
	defb 010h		;f809
	defb 0ffh		;f80a
	defb 008h		;f80b
	defb 0ffh		;f80c
	defb 000h		;f80d
	defb 000h		;f80e
	defb 000h		;f80f
	defb 0ffh		;f810
	defb 000h		;f811
	defb 0ffh		;f812
	defb 008h		;f813
	defb 0fbh		;f814
	defb 000h		;f815
	defb 000h		;f816
	defb 000h		;f817
	defb 0efh		;f818
	defb 000h		;f819
	defb 0f7h		;f81a
	defb 004h		;f81b
	defb 0ffh		;f81c
	defb 000h		;f81d
	defb 000h		;f81e
	defb 000h		;f81f
	defb 0dfh		;f820
	defb 000h		;f821
	defb 0ffh		;f822
	defb 011h		;f823
	defb 0ffh		;f824
	defb 000h		;f825
	defb 000h		;f826
	defb 000h		;f827
	defb 0bdh		;f828
	defb 000h		;f829
	defb 0ffh		;f82a
	defb 000h		;f82b
	defb 0ffh		;f82c
	defb 000h		;f82d
	defb 000h		;f82e
	defb 000h		;f82f
	defb 0ebh		;f830
	defb 028h		;f831
	defb 0ffh		;f832
	defb 080h		;f833
	defb 0ffh		;f834
	defb 000h		;f835
	defb 000h		;f836
	defb 000h		;f837
	defb 0feh		;f838
	defb 000h		;f839
	defb 0ffh		;f83a
	defb 004h		;f83b
	defb 0ffh		;f83c
	defb 000h		;f83d
	defb 000h		;f83e
	defb 000h		;f83f
	defb 0a3h		;f840
	defb 001h		;f841
	defb 0ffh		;f842
	defb 080h		;f843
	defb 0f7h		;f844
	defb 000h		;f845
	defb 000h		;f846
	defb 000h		;f847
	defb 0bfh		;f848
	defb 000h		;f849
	defb 0ffh		;f84a
	defb 080h		;f84b
	defb 0ffh		;f84c
	defb 000h		;f84d
	defb 000h		;f84e
lf84fh:
	defb 000h		;f84f
lf850h:
	defb 0ffh		;f850
	defb 000h		;f851
	defb 0ffh		;f852
	defb 020h		;f853
	defb 0ffh		;f854
	defb 000h		;f855
	defb 000h		;f856
	defb 000h		;f857
	defb 0ffh		;f858
	defb 030h		;f859
	defb 0ffh		;f85a
	defb 081h		;f85b
	defb 0ffh		;f85c
	defb 010h		;f85d
	defb 000h		;f85e
	defb 000h		;f85f
	defb 0ffh		;f860
	defb 000h		;f861
	defb 0ffh		;f862
	defb 041h		;f863
	defb 0ffh		;f864
	defb 000h		;f865
	defb 000h		;f866
	defb 000h		;f867
	defb 0efh		;f868
	defb 004h		;f869
	defb 0ffh		;f86a
	defb 000h		;f86b
	defb 0ffh		;f86c
	defb 000h		;f86d
	defb 000h		;f86e
	defb 000h		;f86f
	defb 0efh		;f870
	defb 000h		;f871
	defb 0ffh		;f872
	defb 0e0h		;f873
	defb 0ffh		;f874
	defb 040h		;f875
	defb 000h		;f876
	defb 000h		;f877
	defb 06fh		;f878
	defb 001h		;f879
	defb 0ffh		;f87a
	defb 004h		;f87b
	defb 0ffh		;f87c
	defb 000h		;f87d
	defb 000h		;f87e
	defb 000h		;f87f
	defb 0f3h		;f880
	defb 000h		;f881
	defb 0ffh		;f882
	defb 002h		;f883
	defb 0ffh		;f884
	defb 080h		;f885
	defb 000h		;f886
	defb 000h		;f887
	defb 0ffh		;f888
	defb 028h		;f889
	defb 0ffh		;f88a
	defb 0c2h		;f88b
	defb 0ffh		;f88c
	defb 000h		;f88d
	defb 000h		;f88e
	defb 000h		;f88f
	defb 07fh		;f890
	defb 020h		;f891
	defb 07fh		;f892
	defb 005h		;f893
	defb 0ffh		;f894
	defb 000h		;f895
	defb 000h		;f896
	defb 000h		;f897
	defb 0ffh		;f898
	defb 080h		;f899
	defb 0ffh		;f89a
	defb 000h		;f89b
	defb 0ffh		;f89c
	defb 000h		;f89d
	defb 000h		;f89e
	defb 000h		;f89f
	defb 0f7h		;f8a0
	defb 000h		;f8a1
	defb 0ffh		;f8a2
	defb 000h		;f8a3
	defb 0ffh		;f8a4
	defb 000h		;f8a5
	defb 000h		;f8a6
	defb 000h		;f8a7
	defb 0bfh		;f8a8
	defb 020h		;f8a9
	defb 0feh		;f8aa
	defb 008h		;f8ab
	defb 0bfh		;f8ac
	defb 000h		;f8ad
	defb 000h		;f8ae
	defb 000h		;f8af
	defb 0ffh		;f8b0
	defb 000h		;f8b1
	defb 0ffh		;f8b2
	defb 085h		;f8b3
	defb 0ffh		;f8b4
	defb 000h		;f8b5
	defb 000h		;f8b6
	defb 000h		;f8b7
	defb 0ffh		;f8b8
	defb 000h		;f8b9
	defb 0ffh		;f8ba
	defb 000h		;f8bb
	defb 0ffh		;f8bc
	defb 008h		;f8bd
	defb 000h		;f8be
	defb 000h		;f8bf
	defb 0ffh		;f8c0
	defb 010h		;f8c1
	defb 0ffh		;f8c2
	defb 084h		;f8c3
	defb 0ffh		;f8c4
	defb 000h		;f8c5
	defb 000h		;f8c6
	defb 000h		;f8c7
	defb 0ffh		;f8c8
	defb 000h		;f8c9
	defb 0ffh		;f8ca
	defb 000h		;f8cb
	defb 0ffh		;f8cc
	defb 000h		;f8cd
	defb 000h		;f8ce
	defb 000h		;f8cf
	defb 0ffh		;f8d0
	defb 000h		;f8d1
	defb 0ffh		;f8d2
	defb 000h		;f8d3
	defb 0ffh		;f8d4
	defb 000h		;f8d5
	defb 000h		;f8d6
	defb 000h		;f8d7
	defb 0ffh		;f8d8
	defb 008h		;f8d9
	defb 0ffh		;f8da
	defb 00ch		;f8db
	defb 0ffh		;f8dc
	defb 000h		;f8dd
	defb 000h		;f8de
	defb 000h		;f8df
	defb 0ffh		;f8e0
	defb 008h		;f8e1
	defb 0ffh		;f8e2
	defb 080h		;f8e3
	defb 0ffh		;f8e4
	defb 080h		;f8e5
	defb 000h		;f8e6
	defb 000h		;f8e7
	defb 0dfh		;f8e8
	defb 008h		;f8e9
	defb 0ffh		;f8ea
	defb 040h		;f8eb
	defb 0fbh		;f8ec
	defb 000h		;f8ed
	defb 000h		;f8ee
	defb 000h		;f8ef
	defb 0ffh		;f8f0
	defb 020h		;f8f1
	defb 0ffh		;f8f2
	defb 080h		;f8f3
	defb 0ffh		;f8f4
	defb 000h		;f8f5
	defb 000h		;f8f6
	defb 000h		;f8f7
	defb 0ffh		;f8f8
	defb 000h		;f8f9
	defb 0ffh		;f8fa
	defb 020h		;f8fb
	defb 0ffh		;f8fc
	defb 000h		;f8fd
	defb 000h		;f8fe
	defb 000h		;f8ff
	defb 000h		;f900
	defb 000h		;f901
	defb 000h		;f902
	defb 000h		;f903
	defb 000h		;f904
	defb 000h		;f905
	defb 000h		;f906
	defb 000h		;f907
	defb 000h		;f908
	defb 000h		;f909
	defb 000h		;f90a
	defb 000h		;f90b
	defb 000h		;f90c
	defb 000h		;f90d
	defb 000h		;f90e
	defb 000h		;f90f
	defb 000h		;f910
	defb 000h		;f911
	defb 000h		;f912
	defb 000h		;f913
	defb 010h		;f914
	defb 000h		;f915
	defb 000h		;f916
	defb 004h		;f917
	defb 000h		;f918
	defb 000h		;f919
	defb 004h		;f91a
	defb 000h		;f91b
	defb 000h		;f91c
	defb 000h		;f91d
	defb 010h		;f91e
	defb 000h		;f91f
	defb 000h		;f920
	defb 000h		;f921
	defb 000h		;f922
	defb 000h		;f923
	defb 000h		;f924
	defb 000h		;f925
	defb 000h		;f926
	defb 000h		;f927
	defb 020h		;f928
	defb 000h		;f929
	defb 000h		;f92a
	defb 000h		;f92b
	defb 000h		;f92c
	defb 000h		;f92d
	defb 000h		;f92e
	defb 000h		;f92f
	defb 000h		;f930
	defb 000h		;f931
	defb 000h		;f932
	defb 000h		;f933
	defb 000h		;f934
	defb 000h		;f935
	defb 000h		;f936
	defb 000h		;f937
	defb 000h		;f938
	defb 000h		;f939
	defb 000h		;f93a
	defb 000h		;f93b
	defb 000h		;f93c
	defb 000h		;f93d
	defb 080h		;f93e
	defb 000h		;f93f
	defb 000h		;f940
	defb 000h		;f941
	defb 000h		;f942
	defb 000h		;f943
	defb 000h		;f944
	defb 000h		;f945
	defb 000h		;f946
	defb 000h		;f947
	defb 000h		;f948
	defb 000h		;f949
	defb 020h		;f94a
	defb 000h		;f94b
	defb 000h		;f94c
	defb 000h		;f94d
	defb 000h		;f94e
	defb 000h		;f94f
	defb 000h		;f950
	defb 000h		;f951
	defb 000h		;f952
	defb 000h		;f953
	defb 002h		;f954
	defb 000h		;f955
	defb 000h		;f956
	defb 000h		;f957
	defb 000h		;f958
	defb 000h		;f959
	defb 000h		;f95a
	defb 000h		;f95b
	defb 000h		;f95c
	defb 000h		;f95d
	defb 000h		;f95e
	defb 000h		;f95f
	defb 000h		;f960
	defb 000h		;f961
	defb 000h		;f962
	defb 000h		;f963
	defb 000h		;f964
	defb 000h		;f965
	defb 000h		;f966
	defb 000h		;f967
	defb 000h		;f968
	defb 000h		;f969
	defb 000h		;f96a
	defb 000h		;f96b
	defb 000h		;f96c
	defb 000h		;f96d
	defb 000h		;f96e
	defb 000h		;f96f
	defb 000h		;f970
	defb 000h		;f971
	defb 000h		;f972
	defb 000h		;f973
	defb 000h		;f974
	defb 000h		;f975
	defb 000h		;f976
	defb 000h		;f977
	defb 000h		;f978
	defb 000h		;f979
	defb 000h		;f97a
	defb 000h		;f97b
	defb 026h		;f97c
	defb 000h		;f97d
	defb 000h		;f97e
	defb 000h		;f97f
	defb 000h		;f980
	defb 000h		;f981
	defb 001h		;f982
	defb 000h		;f983
	defb 001h		;f984
	defb 000h		;f985
	defb 000h		;f986
	defb 000h		;f987
	defb 000h		;f988
	defb 000h		;f989
	defb 000h		;f98a
	defb 000h		;f98b
	defb 000h		;f98c
	defb 000h		;f98d
	defb 000h		;f98e
	defb 000h		;f98f
	defb 000h		;f990
	defb 000h		;f991
	defb 000h		;f992
	defb 000h		;f993
	defb 010h		;f994
	defb 000h		;f995
	defb 000h		;f996
	defb 000h		;f997
	defb 000h		;f998
	defb 090h		;f999
	defb 000h		;f99a
	defb 010h		;f99b
	defb 000h		;f99c
	defb 000h		;f99d
	defb 000h		;f99e
	defb 000h		;f99f
	defb 000h		;f9a0
	defb 000h		;f9a1
	defb 000h		;f9a2
	defb 000h		;f9a3
	defb 008h		;f9a4
	defb 000h		;f9a5
	defb 000h		;f9a6
	defb 000h		;f9a7
	defb 000h		;f9a8
	defb 000h		;f9a9
	defb 000h		;f9aa
	defb 000h		;f9ab
	defb 000h		;f9ac
	defb 000h		;f9ad
	defb 000h		;f9ae
	defb 000h		;f9af
	defb 000h		;f9b0
	defb 000h		;f9b1
	defb 000h		;f9b2
	defb 000h		;f9b3
	defb 080h		;f9b4
	defb 000h		;f9b5
	defb 000h		;f9b6
	defb 000h		;f9b7
	defb 000h		;f9b8
	defb 000h		;f9b9
	defb 000h		;f9ba
	defb 000h		;f9bb
	defb 020h		;f9bc
	defb 000h		;f9bd
	defb 000h		;f9be
	defb 020h		;f9bf
	defb 000h		;f9c0
	defb 000h		;f9c1
	defb 000h		;f9c2
	defb 000h		;f9c3
	defb 048h		;f9c4
	defb 000h		;f9c5
	defb 000h		;f9c6
	defb 000h		;f9c7
	defb 000h		;f9c8
	defb 000h		;f9c9
	defb 000h		;f9ca
	defb 000h		;f9cb
	defb 000h		;f9cc
	defb 000h		;f9cd
	defb 000h		;f9ce
	defb 000h		;f9cf
	defb 000h		;f9d0
	defb 000h		;f9d1
	defb 000h		;f9d2
	defb 000h		;f9d3
	defb 000h		;f9d4
	defb 000h		;f9d5
	defb 002h		;f9d6
	defb 000h		;f9d7
	defb 000h		;f9d8
	defb 000h		;f9d9
	defb 000h		;f9da
	defb 000h		;f9db
	defb 000h		;f9dc
	defb 000h		;f9dd
	defb 000h		;f9de
	defb 000h		;f9df
	defb 000h		;f9e0
	defb 000h		;f9e1
	defb 000h		;f9e2
	defb 000h		;f9e3
	defb 000h		;f9e4
	defb 000h		;f9e5
	defb 000h		;f9e6
	defb 000h		;f9e7
	defb 000h		;f9e8
	defb 000h		;f9e9
	defb 000h		;f9ea
	defb 000h		;f9eb
	defb 000h		;f9ec
	defb 000h		;f9ed
	defb 000h		;f9ee
	defb 000h		;f9ef
	defb 000h		;f9f0
	defb 000h		;f9f1
	defb 000h		;f9f2
	defb 000h		;f9f3
	defb 000h		;f9f4
	defb 000h		;f9f5
	defb 000h		;f9f6
	defb 000h		;f9f7
	defb 080h		;f9f8
	defb 000h		;f9f9
	defb 000h		;f9fa
	defb 000h		;f9fb
	defb 000h		;f9fc
	defb 000h		;f9fd
	defb 000h		;f9fe
	defb 000h		;f9ff
verify_end:
