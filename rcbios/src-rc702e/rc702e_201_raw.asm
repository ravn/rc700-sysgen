; z80dasm 1.2.0
; command line: z80dasm -a -l -g 0xD700 -S /Users/ravn/git/rc700-sysgen/rcbios/src-rc702e/rc702e_201.sym -b /Users/ravn/git/rc700-sysgen/rcbios/src-rc702e/rc702e_201.blk -o /Users/ravn/git/rc700-sysgen/rcbios/src-rc702e/rc702e_201_raw.asm extracted_bios/cpm22_56k_rc702e_rel2.01_mini.bin

	org 0d700h
ISR_FDC:	equ 0xdffc
trailing_end:	equ 0xec80
RAMDSTAT:	equ 0xf49a
SIOFLG:	equ 0xf4ca
SIOFLG2:	equ 0xf4cc
CONVTAB:	equ 0xf680
CONVTAB2:	equ 0xf700
SCREENBUF:	equ 0xf800
SCRNEND:	equ 0xffcf
CURX:	equ 0xffd1
CURY:	equ 0xffd2
TIMER1:	equ 0xffdf
TIMER2:	equ 0xffe1
WARMJP:	equ 0xffe5

START:

; BLOCK 'code000' (start 0xd700 end 0xd950)
code000_start:
	di			;d700
	ld hl,00000h		;d701
	ld de,0d480h		;d704
	ld bc,02381h		;d707
	ldir			;d70a
	ld hl,trailing_end	;d70c
	ld de,0ec81h		;d70f
	ld (hl),000h		;d712
	ld bc,01380h		;d714
	ldir			;d717
	ld hl,0d580h		;d719
	ld de,CONVTAB		;d71c
	ld bc,00180h		;d71f
	ldir			;d722
	ld sp,00080h		;d724
	ld a,(lec25h)		;d727
	ld i,a			;d72a
	im 2			;d72c
	ld a,020h		;d72e
	out (012h),a		;d730
	ld a,022h		;d732
	out (013h),a		;d734
	ld a,04fh		;d736
	out (012h),a		;d738
	ld a,00fh		;d73a
	out (013h),a		;d73c
INITCONT:
	ld a,083h		;d73e
	out (012h),a		;d740
	out (013h),a		;d742
	ld a,000h		;d744
	out (00ch),a		;d746
	ld a,(0d500h)		;d748
	out (00ch),a		;d74b
	ld a,(0d501h)		;d74d
	out (00ch),a		;d750
	ld a,(0d502h)		;d752
	out (00dh),a		;d755
	ld a,(0d503h)		;d757
	out (00dh),a		;d75a
	ld a,(0d504h)		;d75c
	out (00eh),a		;d75f
	ld a,(0d505h)		;d761
	out (00eh),a		;d764
	ld a,(0d506h)		;d766
	out (00fh),a		;d769
	ld a,(0d507h)		;d76b
	out (00fh),a		;d76e
	ld hl,0d508h		;d770
	ld b,009h		;d773
	ld c,00ah		;d775
	otir			;d777
	ld hl,0d511h		;d779
	ld b,00bh		;d77c
	ld c,00bh		;d77e
	otir			;d780
	in a,(00ah)		;d782
	ld (0f4cfh),a		;d784
	ld a,001h		;d787
	out (00ah),a		;d789
	in a,(00ah)		;d78b
	ld (0f4d0h),a		;d78d
	in a,(00bh)		;d790
	ld (0f4d1h),a		;d792
	ld a,001h		;d795
	out (00bh),a		;d797
	in a,(00bh)		;d799
	ld (0f4d2h),a		;d79b
	ld a,020h		;d79e
	out (0f8h),a		;d7a0
	ld a,(0d51ch)		;d7a2
	out (0fbh),a		;d7a5
	ld a,(0d51eh)		;d7a7
	out (0fbh),a		;d7aa
	ld a,(0d51fh)		;d7ac
	out (0fbh),a		;d7af
	in a,(014h)		;d7b1
	and 080h		;d7b3
	jr z,ld7c6h		;d7b5
	ld hl,0d52fh		;d7b7
	ld a,(hl)		;d7ba
	cp 018h			;d7bb
	jr nz,ld7c6h		;d7bd
	ld (hl),010h		;d7bf
	ld a,041h		;d7c1
	ld (0d537h),a		;d7c3
ld7c6h:
	in a,(004h)		;d7c6
	and 01fh		;d7c8
	jr nz,ld7c6h		;d7ca
	ld hl,0d524h		;d7cc
	ld b,(hl)		;d7cf
ld7d0h:
	inc hl			;d7d0
ld7d1h:
	in a,(004h)		;d7d1
	and 0c0h		;d7d3
	cp 080h			;d7d5
	jr nz,ld7d1h		;d7d7
	ld a,(hl)		;d7d9
	out (005h),a		;d7da
	dec b			;d7dc
	jr nz,ld7d0h		;d7dd
	ld hl,SCREENBUF		;d7df
	ld de,0f801h		;d7e2
	ld bc,007cfh		;d7e5
	ld (hl),020h		;d7e8
	ldir			;d7ea
	ld a,000h		;d7ec
	out (001h),a		;d7ee
	ld a,(0d520h)		;d7f0
	out (000h),a		;d7f3
	ld a,(0d521h)		;d7f5
	out (000h),a		;d7f8
	ld a,(0d522h)		;d7fa
	out (000h),a		;d7fd
	ld a,(0d523h)		;d7ff
	out (000h),a		;d802
	ld a,080h		;d804
	out (001h),a		;d806
	ld a,000h		;d808
	out (000h),a		;d80a
	out (000h),a		;d80c
	ld a,0e0h		;d80e
	out (001h),a		;d810
	ld a,023h		;d812
	out (001h),a		;d814
	ld a,(0d50eh)		;d816
	and 060h		;d819
	ld (lda34h),a		;d81b
	ld a,(0d519h)		;d81e
INIT2:
	and 060h		;d821
	ld (lda35h),a		;d823
	ld a,(0d52ch)		;d826
	ld (code008_end),a	;d829
	ld hl,(0d52dh)		;d82c
	ld (0ffeah),hl		;d82f
	ld a,0ffh		;d832
	ld (0f4c9h),a		;d834
	ld (SIOFLG2),a		;d837
	ld (0f4b4h),a		;d83a
	ld hl,str_bootq_end	;d83d
	ld de,0f4dah		;d840
	ld bc,0000fh		;d843
	ldir			;d846
	ld hl,0d52fh		;d848
	ld de,lda37h		;d84b
	ld bc,00010h		;d84e
	ldir			;d851
	ei			;d853
	ld hl,ld979h		;d854
	call signon_end		;d857
	ld iy,0f4a4h		;d85a
	ld hl,lda3ah		;d85e
	ld (iy+000h),003h	;d861
	call FLUSH		;d865
ld868h:
	call INIT3		;d868
	call nz,INIT3		;d86b
	jr z,ld872h		;d86e
	ld (hl),0ffh		;d870
ld872h:
	dec hl			;d872
	dec (iy+000h)		;d873
	jr nz,ld868h		;d876
	jr ld886h		;d878
INIT3:
	call FDCDMA_RD		;d87a
	call RAMDISK		;d87d
	ld a,b			;d880
	and 060h		;d881
	cp 020h			;d883
	ret			;d885
ld886h:
	xor a			;d886
	out (0e6h),a		;d887
	out (0e7h),a		;d889
	in a,(0e6h)		;d88b
	or a			;d88d
	jr z,ld89fh		;d88e
	ld hl,ld954h		;d890
	call signon_end		;d893
	ld hl,ld95dh		;d896
	call signon_end		;d899
	jp INIT5		;d89c
ld89fh:
	ld hl,0ec81h		;d89f
	ld de,0ec82h		;d8a2
	ld bc,00100h		;d8a5
	ld (hl),0e5h		;d8a8
	ldir			;d8aa
	ld ix,0f488h		;d8ac
	ld iy,0f48ah		;d8b0
	ld (ix+000h),002h	;d8b4
	ld (iy+000h),000h	;d8b8
ld8bch:
	call RAMDISK_INT	;d8bc
	ld a,(RAMDSTAT)		;d8bf
	and 080h		;d8c2
	jr nz,ld8d9h		;d8c4
	inc (iy+000h)		;d8c6
	ld a,010h		;d8c9
	cp (iy+000h)		;d8cb
	jr nz,ld8bch		;d8ce
	xor a			;d8d0
	ld (iy+000h),a		;d8d1
	inc (ix+000h)		;d8d4
	jr nz,ld8bch		;d8d7
ld8d9h:
	ld a,(0f488h)		;d8d9
	cp 011h			;d8dc
	jr nc,ld8efh		;d8de
	ld hl,ld954h		;d8e0
	call signon_end		;d8e3
	ld hl,str_notinst_end	;d8e6
	call signon_end		;d8e9
	jp INIT4		;d8ec
ld8efh:
	ld ix,04000h		;d8ef
	ld (ix+001h),004h	;d8f3
	ld a,080h		;d8f7
	ld (lda3bh),a		;d8f9
	ld a,(0f488h)		;d8fc
	sub 002h		;d8ff
	ld l,a			;d901
	and 080h		;d902
	jr z,ld90ah		;d904
	xor a			;d906
	ld (le80ch),a		;d907
ld90ah:
	ld h,000h		;d90a
	add hl,hl		;d90c
	dec hl			;d90d
	ld (le80dh),hl		;d90e
	ld hl,ld954h		;d911
	call signon_end		;d914
	ld hl,ld973h		;d917
	call signon_end		;d91a
INIT4:
	ld hl,code000_end	;d91d
	call signon_end		;d920
	ld hl,str_waiting_end	;d923
	call signon_end		;d926
	call CONIN		;d929
	ld a,e			;d92c
	cp 059h			;d92d
	jr nz,INIT5		;d92f
	ld a,0ffh		;d931
	ld (lda47h),a		;d933
INIT5:
	ld hl,str_clock_end	;d936
	call signon_end		;d939
	ld hl,lda92h		;d93c
	call signon_end		;d93f
	ld hl,str_timeinit_end	;d942
	call signon_end		;d945
	ld a,00ch		;d948
	ld (lda92h),a		;d94a
	jp BOOTMSG		;d94d
code000_end:
STR_RAMDISK:

; BLOCK 'str_ramdisk' (start 0xd950 end 0xd95c)
str_ramdisk_start:
	defb 055h		;d950
	defb 053h		;d951
	defb 045h		;d952
	defb 020h		;d953
ld954h:
	defb 052h		;d954
	defb 041h		;d955
	defb 04dh		;d956
	defb 02dh		;d957
	defb 044h		;d958
	defb 049h		;d959
	defb 053h		;d95a
	defb 04bh		;d95b
str_ramdisk_end:
STR_NOTINST:

; BLOCK 'str_notinst' (start 0xd95c end 0xd96f)
str_notinst_start:
	defb 000h		;d95c
ld95dh:
	defb 020h		;d95d
	defb 04eh		;d95e
	defb 04fh		;d95f
	defb 054h		;d960
	defb 020h		;d961
	defb 049h		;d962
	defb 04eh		;d963
	defb 053h		;d964
	defb 054h		;d965
	defb 041h		;d966
	defb 04ch		;d967
	defb 04ch		;d968
	defb 045h		;d969
	defb 044h		;d96a
	defb 02eh		;d96b
	defb 00ah		;d96c
	defb 00dh		;d96d
	defb 000h		;d96e
str_notinst_end:
STR_NOTUSED:

; BLOCK 'str_notused' (start 0xd96f end 0xd978)
str_notused_start:
	defb 020h		;d96f
	defb 04eh		;d970
	defb 04fh		;d971
	defb 054h		;d972
ld973h:
	defb 020h		;d973
	defb 055h		;d974
	defb 053h		;d975
	defb 045h		;d976
	defb 044h		;d977
str_notused_end:
STR_WAITING:

; BLOCK 'str_waiting' (start 0xd978 end 0xd98c)
str_waiting_start:
	defb 000h		;d978
ld979h:
	defb 00ch		;d979
	defb 052h		;d97a
	defb 043h		;d97b
	defb 037h		;d97c
	defb 030h		;d97d
	defb 032h		;d97e
	defb 045h		;d97f
	defb 020h		;d980
	defb 057h		;d981
	defb 061h		;d982
	defb 069h		;d983
	defb 074h		;d984
	defb 069h		;d985
	defb 06eh		;d986
	defb 067h		;d987
	defb 02eh		;d988
	defb 00dh		;d989
	defb 00ah		;d98a
	defb 000h		;d98b
str_waiting_end:
STR_BOOTQ:

; BLOCK 'str_bootq' (start 0xd98c end 0xd99f)
str_bootq_start:
	defb 020h		;d98c
	defb 041h		;d98d
	defb 053h		;d98e
	defb 020h		;d98f
	defb 042h		;d990
	defb 04fh		;d991
	defb 04fh		;d992
	defb 054h		;d993
	defb 044h		;d994
	defb 049h		;d995
	defb 053h		;d996
	defb 04bh		;d997
	defb 03fh		;d998
	defb 028h		;d999
	defb 059h		;d99a
	defb 02fh		;d99b
	defb 04eh		;d99c
	defb 029h		;d99d
	defb 000h		;d99e
str_bootq_end:
STR_CLOCK:

; BLOCK 'str_clock' (start 0xd99f end 0xd9ac)
str_clock_start:
	defb 080h		;d99f
	defb 04bh		;d9a0
	defb 06ch		;d9a1
	defb 02eh		;d9a2
	defb 030h		;d9a3
	defb 030h		;d9a4
	defb 02eh		;d9a5
	defb 030h		;d9a6
	defb 030h		;d9a7
	defb 02eh		;d9a8
	defb 030h		;d9a9
	defb 030h		;d9aa
	defb 080h		;d9ab
str_clock_end:
STR_TIMEINIT:

; BLOCK 'str_timeinit' (start 0xd9ac end 0xd9c4)
str_timeinit_start:
	defb 054h		;d9ac
	defb 049h		;d9ad
	defb 04dh		;d9ae
	defb 045h		;d9af
	defb 020h		;d9b0
	defb 04eh		;d9b1
	defb 04fh		;d9b2
	defb 054h		;d9b3
	defb 020h		;d9b4
	defb 049h		;d9b5
	defb 04eh		;d9b6
	defb 049h		;d9b7
	defb 054h		;d9b8
	defb 049h		;d9b9
	defb 041h		;d9ba
	defb 04ch		;d9bb
	defb 049h		;d9bc
	defb 05ah		;d9bd
	defb 045h		;d9be
	defb 044h		;d9bf
	defb 02eh		;d9c0
	defb 00ah		;d9c1
	defb 00dh		;d9c2
	defb 000h		;d9c3
str_timeinit_end:
INIT6:

; BLOCK 'code008' (start 0xd9c4 end 0xda33)
code008_start:
	ld a,(bc)		;d9c4
	ld a,(bc)		;d9c5
	nop			;d9c6
	nop			;d9c7
	nop			;d9c8
	nop			;d9c9
	nop			;d9ca
	nop			;d9cb
	nop			;d9cc
	nop			;d9cd
	nop			;d9ce
	nop			;d9cf
	nop			;d9d0
	nop			;d9d1
	nop			;d9d2
	nop			;d9d3
	nop			;d9d4
	nop			;d9d5
	nop			;d9d6
	nop			;d9d7
	nop			;d9d8
	nop			;d9d9
	nop			;d9da
	nop			;d9db
	nop			;d9dc
	nop			;d9dd
	nop			;d9de
	nop			;d9df
	nop			;d9e0
	nop			;d9e1
	nop			;d9e2
	nop			;d9e3
	nop			;d9e4
	nop			;d9e5
	nop			;d9e6
	nop			;d9e7
	nop			;d9e8
	nop			;d9e9
	nop			;d9ea
	nop			;d9eb
	nop			;d9ec
	nop			;d9ed
	nop			;d9ee
	nop			;d9ef
	nop			;d9f0
	nop			;d9f1
	nop			;d9f2
	nop			;d9f3
	nop			;d9f4
	nop			;d9f5
	nop			;d9f6
	nop			;d9f7
	nop			;d9f8
	nop			;d9f9
	nop			;d9fa
	nop			;d9fb
	nop			;d9fc
	nop			;d9fd
	nop			;d9fe
	nop			;d9ff
JMPTAB:
	jp BOOT			;da00
lda03h:
	jp WBOOT		;da03
	jp ivtdata_end		;da06
	jp CONIN		;da09
	jp CONOUT		;da0c
	jp LIST			;da0f
	jp PUNCH		;da12
	jp READER		;da15
	jp HOME			;da18
	jp SELDSK		;da1b
	jp SETTRK		;da1e
	jp SETSEC		;da21
	jp SETDMA		;da24
	jp READ			;da27
	jp WRITE		;da2a
	jp LISTST		;da2d
	jp SECTRAN		;da30
code008_end:
JTVARS:

; BLOCK 'jtvars' (start 0xda33 end 0xda4a)
jtvars_start:
	defb 000h		;da33
lda34h:
	defb 000h		;da34
lda35h:
	defb 000h		;da35
	defb 000h		;da36
lda37h:
	defb 0ffh		;da37
	defb 0ffh		;da38
	defb 0ffh		;da39
lda3ah:
	defb 0ffh		;da3a
lda3bh:
	defb 0ffh		;da3b
	defb 0ffh		;da3c
	defb 0ffh		;da3d
	defb 0ffh		;da3e
	defb 0ffh		;da3f
	defb 0ffh		;da40
	defb 0ffh		;da41
	defb 0ffh		;da42
	defb 0ffh		;da43
	defb 0ffh		;da44
	defb 0ffh		;da45
	defb 0ffh		;da46
lda47h:
	defb 000h		;da47
	defb 000h		;da48
	defb 000h		;da49
jtvars_end:
INTJP0:

; BLOCK 'code010' (start 0xda4a end 0xda5f)
code010_start:
	jp RAMDISK		;da4a
INTJP1:
	jp CONOUT_INT		;da4d
INTJP2:
	jp LINSEL		;da50
INTJP3:
	jp HALT			;da53
INTJP4:
	jp SETWARM		;da56
INTJP5:
	jp WBOOT		;da59
INTJP6:
	jp WBOOT		;da5c
code010_end:
JTGAP:

; BLOCK 'jtgap' (start 0xda5f end 0xda62)
jtgap_start:
	defb 000h		;da5f
lda60h:
	defb 098h		;da60
	defb 03ah		;da61
jtgap_end:
INTJP7:

; BLOCK 'code012' (start 0xda62 end 0xda6e)
code012_start:
	jp CLOCK		;da62
INTJP8:
	jp SIOWR		;da65
INTJP9:
	jp READER2		;da68
INTJP10:
	jp PUNCH2		;da6b
code012_end:
JTPAD:

; BLOCK 'jtpad' (start 0xda6e end 0xda70)
jtpad_start:
	defb 000h		;da6e
	defb 000h		;da6f
jtpad_end:
ERRPRE:

; BLOCK 'errpre' (start 0xda70 end 0xda78)
errpre_start:
	defb 000h		;da70
	defb 001h		;da71
	defb 002h		;da72
lda73h:
	defb 000h		;da73
	defb 001h		;da74
	defb 002h		;da75
	defb 003h		;da76
	defb 004h		;da77
errpre_end:
ERRMSG:

; BLOCK 'errmsg' (start 0xda78 end 0xda93)
errmsg_start:
	defb 00dh		;da78
	defb 00ah		;da79
	defb 044h		;da7a
	defb 069h		;da7b
	defb 073h		;da7c
	defb 06bh		;da7d
	defb 020h		;da7e
	defb 072h		;da7f
	defb 065h		;da80
	defb 061h		;da81
	defb 064h		;da82
	defb 020h		;da83
	defb 065h		;da84
	defb 072h		;da85
	defb 072h		;da86
	defb 06fh		;da87
	defb 072h		;da88
	defb 020h		;da89
	defb 02dh		;da8a
	defb 020h		;da8b
	defb 072h		;da8c
	defb 065h		;da8d
	defb 073h		;da8e
	defb 065h		;da8f
	defb 074h		;da90
	defb 000h		;da91
lda92h:
	defb 01dh		;da92
errmsg_end:
SIGNON:

; BLOCK 'signon' (start 0xda93 end 0xdab6)
signon_start:
	defb 052h		;da93
	defb 043h		;da94
	defb 037h		;da95
	defb 030h		;da96
	defb 032h		;da97
	defb 045h		;da98
	defb 020h		;da99
	defb 035h		;da9a
	defb 036h		;da9b
	defb 06bh		;da9c
	defb 020h		;da9d
	defb 043h		;da9e
	defb 050h		;da9f
	defb 02fh		;daa0
	defb 04dh		;daa1
	defb 020h		;daa2
	defb 056h		;daa3
	defb 065h		;daa4
	defb 072h		;daa5
	defb 020h		;daa6
	defb 032h		;daa7
	defb 02eh		;daa8
	defb 032h		;daa9
	defb 020h		;daaa
	defb 052h		;daab
	defb 065h		;daac
	defb 06ch		;daad
	defb 020h		;daae
	defb 032h		;daaf
	defb 02eh		;dab0
	defb 030h		;dab1
	defb 031h		;dab2
	defb 00dh		;dab3
	defb 00ah		;dab4
	defb 000h		;dab5
signon_end:
PRTMSG:

; BLOCK 'code017' (start 0xdab6 end 0xe717)
code017_start:
	ld a,(hl)		;dab6
	or a			;dab7
	ret z			;dab8
	push hl			;dab9
	ld c,a			;daba
	call CONOUT		;dabb
	pop hl			;dabe
	inc hl			;dabf
	jr signon_end		;dac0
PRTLOOP:
	ld hl,errpre_end	;dac2
	call signon_end		;dac5
	ld hl,0f4d8h		;dac8
ldacbh:
	di			;dacb
	out (01ch),a		;dacc
	ld a,032h		;dace
	ld (hl),a		;dad0
	ei			;dad1
ldad2h:
	ld a,(hl)		;dad2
	or a			;dad3
	jr nz,ldad2h		;dad4
	jr ldacbh		;dad6
HALT:
	ld a,0c3h		;dad8
	ld (0ffe7h),a		;dada
	ld (0ffe8h),hl		;dadd
	ex de,hl		;dae0
	ld (TIMER1),hl		;dae1
	ret			;dae4
SETWARM:
	di			;dae5
	or a			;dae6
	jr z,ldaf2h		;dae7
	ld de,(0fffch)		;dae9
	ld hl,(0fffeh)		;daed
	ei			;daf0
	ret			;daf1
ldaf2h:
	ld (0fffch),de		;daf2
	ld (0fffeh),hl		;daf6
	ei			;daf9
	ret			;dafa
CLOCK:
	di			;dafb
	or a			;dafc
	jr z,ldb0ch		;dafd
	ld bc,(0f4deh)		;daff
	ld de,(0f4e1h)		;db03
	ld hl,(0f4e4h)		;db07
	ei			;db0a
	ret			;db0b
ldb0ch:
	ld (0f4deh),bc		;db0c
	ld (0f4e1h),de		;db10
	ld (0f4e4h),hl		;db14
	ld a,032h		;db17
	ld (0f4e8h),a		;db19
	ei			;db1c
	xor a			;db1d
SIOWR:
	ld (0f4e7h),a		;db1e
	ret			;db21
LINSEL:
	add a,00ah		;db22
	ld c,a			;db24
ldb25h:
	di			;db25
	ld a,001h		;db26
	out (c),a		;db28
	in a,(c)		;db2a
	ei			;db2c
	and 001h		;db2d
	jr z,ldb25h		;db2f
	ld hl,00002h		;db31
	call FDCSEEK		;db34
	ld d,005h		;db37
	ld a,000h		;db39
	call BOOTCHK		;db3b
	dec b			;db3e
	ret m			;db3f
	sla b			;db40
	or b			;db42
	call BOOTCHK		;db43
	or 080h			;db46
	call BOOTCHK		;db48
	ld hl,00002h		;db4b
	call FDCSEEK		;db4e
	ld a,c			;db51
	cp 00ah			;db52
	ld a,(0f4cfh)		;db54
	jr z,ldb5ch		;db57
	ld a,(0f4d1h)		;db59
ldb5ch:
	and 020h		;db5c
	jr z,BOOTCHK		;db5e
	ld a,0ffh		;db60
	ret			;db62
BOOTCHK:
	di			;db63
	out (c),d		;db64
	out (c),a		;db66
	ei			;db68
	ret			;db69
BOOT:
	ld sp,00080h		;db6a
	ld hl,lda92h		;db6d
	call signon_end		;db70
BOOTMSG:
	xor a			;db73
	ld (00004h),a		;db74
	ld (0f4b5h),a		;db77
	ld (0f491h),a		;db7a
	ld (RAMDSTAT),a		;db7d
	ld (0f492h),a		;db80
WBOOT:
	ei			;db83
	xor a			;db84
	ld (0f493h),a		;db85
	ld (00003h),a		;db88
	ld (lec26h),a		;db8b
	ld (0f4a4h),a		;db8e
	ld sp,00080h		;db91
	ld a,(lda47h)		;db94
	or a			;db97
	jr z,ldbceh		;db98
	ld hl,CONSTAT2		;db9a
	push hl			;db9d
	ld hl,0c400h		;db9e
	xor a			;dba1
	out (0e6h),a		;dba2
	out (0e7h),a		;dba4
	ld b,a			;dba6
	dec b			;dba7
	ld c,0e8h		;dba8
	ld e,010h		;dbaa
	call WBOOT2		;dbac
	ld a,001h		;dbaf
	out (0e6h),a		;dbb1
	ld e,006h		;dbb3
WBOOT2:
	in a,(0e7h)		;dbb5
	and 0c0h		;dbb7
	jr nz,ldbc9h		;dbb9
	xor a			;dbbb
	out (0e7h),a		;dbbc
ldbbeh:
	inir			;dbbe
	ini			;dbc0
	inc a			;dbc2
	out (0e7h),a		;dbc3
	cp e			;dbc5
	ret z			;dbc6
	jr ldbbeh		;dbc7
ldbc9h:
	ld sp,00080h		;dbc9
	ld a,000h		;dbcc
ldbceh:
	ld c,a			;dbce
	call SELDSK		;dbcf
	call HOME		;dbd2
	ld bc,0c400h		;dbd5
	call SETDMA		;dbd8
	ld bc,00001h		;dbdb
	call SETTRK		;dbde
	ld bc,00000h		;dbe1
	call SETSEC		;dbe4
ldbe7h:
	push bc			;dbe7
	call READ		;dbe8
	or a			;dbeb
	jp nz,PRTLOOP		;dbec
	ld hl,(0f49eh)		;dbef
	ld de,00080h		;dbf2
	add hl,de		;dbf5
	ld b,h			;dbf6
	ld c,l			;dbf7
	call SETDMA		;dbf8
	pop bc			;dbfb
	inc bc			;dbfc
	call SETSEC		;dbfd
	ld a,c			;dc00
	cp 02ch			;dc01
	jr nz,ldbe7h		;dc03
CONSTAT2:
	ld bc,00080h		;dc05
	call SETDMA		;dc08
	ld a,0c3h		;dc0b
	ld (00000h),a		;dc0d
	ld hl,lda03h		;dc10
	ld (00001h),hl		;dc13
	ld (00005h),a		;dc16
	ld hl,0cc06h		;dc19
	ld (00006h),hl		;dc1c
	ld a,(00004h)		;dc1f
	and 00fh		;dc22
	ld c,a			;dc24
	ld a,(lda47h)		;dc25
	cp c			;dc28
	jr z,ldc47h		;dc29
	call SELDSK		;dc2b
	ld a,h			;dc2e
	or l			;dc2f
	jr z,ldc41h		;dc30
	ld bc,00002h		;dc32
	call SETTRK		;dc35
	call SETSEC		;dc38
	call READ		;dc3b
	or a			;dc3e
	jr z,ldc47h		;dc3f
ldc41h:
	ld a,(lda47h)		;dc41
	ld (00004h),a		;dc44
ldc47h:
	ld a,(00004h)		;dc47
	ld c,a			;dc4a
	ld hl,0f4b5h		;dc4b
	ld a,(hl)		;dc4e
	ld (hl),001h		;dc4f
	or a			;dc51
	jr z,ldc64h		;dc52
	ld a,(0c407h)		;dc54
	or a			;dc57
	jr z,ldc64h		;dc58
	ld hl,0c409h		;dc5a
	add a,l			;dc5d
	ld l,a			;dc5e
	ld a,(hl)		;dc5f
	or a			;dc60
	jp z,0c403h		;dc61
ldc64h:
	jp 0c400h		;dc64
LISTST:
	ld a,(0f4c9h)		;dc67
	ret			;dc6a
LIST:
	ld a,(0f4c9h)		;dc6b
	or a			;dc6e
	jr z,LIST		;dc6f
	di			;dc71
	xor a			;dc72
	ld (0f4c9h),a		;dc73
	ld a,005h		;dc76
	out (00bh),a		;dc78
	ld a,(lda35h)		;dc7a
	add a,08ah		;dc7d
	out (00bh),a		;dc7f
	ld a,001h		;dc81
	out (00bh),a		;dc83
	ld a,01fh		;dc85
	out (00bh),a		;dc87
	ld a,c			;dc89
	out (009h),a		;dc8a
	ei			;dc8c
	ret			;dc8d
PUNCH2:
	ld a,(0f4cbh)		;dc8e
	ret			;dc91
READER2:
	ld a,(0f4cbh)		;dc92
	or a			;dc95
	jr z,READER2		;dc96
	ld a,(0f4ceh)		;dc98
	push af			;dc9b
	xor a			;dc9c
	ld (0f4cbh),a		;dc9d
	ld a,(lda35h)		;dca0
	ld c,00bh		;dca3
	jr ldcbeh		;dca5
CONOUT_INT:
	ld a,(SIOFLG)		;dca7
	ret			;dcaa
READER:
	ld a,(SIOFLG)		;dcab
	or a			;dcae
	jr z,READER		;dcaf
	ld a,(0f4cdh)		;dcb1
	push af			;dcb4
	xor a			;dcb5
	ld (SIOFLG),a		;dcb6
	ld a,(lda34h)		;dcb9
	ld c,00ah		;dcbc
ldcbeh:
	di			;dcbe
	ld b,005h		;dcbf
	out (c),b		;dcc1
	add a,08ah		;dcc3
	out (c),a		;dcc5
	ld a,001h		;dcc7
	out (c),a		;dcc9
	ld a,01fh		;dccb
	out (c),a		;dccd
	ei			;dccf
	pop af			;dcd0
	ret			;dcd1
PUNCH:
	ld a,(SIOFLG2)		;dcd2
	or a			;dcd5
	jr z,PUNCH		;dcd6
	di			;dcd8
	xor a			;dcd9
	ld (SIOFLG2),a		;dcda
	ld a,005h		;dcdd
	out (00ah),a		;dcdf
	ld a,(lda34h)		;dce1
	add a,08ah		;dce4
	out (00ah),a		;dce6
	ld a,001h		;dce8
	out (00ah),a		;dcea
	ld a,01fh		;dcec
	out (00ah),a		;dcee
	ld a,c			;dcf0
	out (008h),a		;dcf1
	ei			;dcf3
	ret			;dcf4
ISR_SIO0:
	ld (0f4b2h),sp		;dcf5
	ld sp,0f526h		;dcf9
	push af			;dcfc
	ld a,028h		;dcfd
	out (00bh),a		;dcff
	ld a,0ffh		;dd01
	ld (0f4c9h),a		;dd03
	pop af			;dd06
	ld sp,(0f4b2h)		;dd07
	ei			;dd0b
	reti			;dd0c
	ld (0f4b2h),sp		;dd0e
	ld sp,0f526h		;dd12
	push af			;dd15
	in a,(00bh)		;dd16
	ld (0f4d1h),a		;dd18
	ld a,010h		;dd1b
	out (00bh),a		;dd1d
	pop af			;dd1f
	ld sp,(0f4b2h)		;dd20
	ei			;dd24
	reti			;dd25
	ld (0f4b2h),sp		;dd27
	ld sp,0f526h		;dd2b
	push af			;dd2e
	in a,(009h)		;dd2f
	ld (0f4ceh),a		;dd31
	ld a,0ffh		;dd34
	ld (0f4cbh),a		;dd36
	pop af			;dd39
	ld sp,(0f4b2h)		;dd3a
	ei			;dd3e
	reti			;dd3f
	ld (0f4b2h),sp		;dd41
	ld sp,0f526h		;dd45
	push af			;dd48
	ld a,001h		;dd49
	out (00bh),a		;dd4b
	in a,(00bh)		;dd4d
	ld (0f4d2h),a		;dd4f
	ld a,030h		;dd52
	out (00bh),a		;dd54
	xor a			;dd56
	ld (0f4ceh),a		;dd57
	cpl			;dd5a
	ld (0f4cbh),a		;dd5b
	pop af			;dd5e
	ld sp,(0f4b2h)		;dd5f
	ei			;dd63
	reti			;dd64
	ld (0f4b2h),sp		;dd66
	ld sp,0f526h		;dd6a
	push af			;dd6d
	ld a,028h		;dd6e
	out (00ah),a		;dd70
	ld a,0ffh		;dd72
	ld (SIOFLG2),a		;dd74
	pop af			;dd77
	ld sp,(0f4b2h)		;dd78
	ei			;dd7c
	reti			;dd7d
	ld (0f4b2h),sp		;dd7f
	ld sp,0f526h		;dd83
	push af			;dd86
	in a,(00ah)		;dd87
	ld (0f4cfh),a		;dd89
	ld a,010h		;dd8c
	out (00ah),a		;dd8e
	pop af			;dd90
	ld sp,(0f4b2h)		;dd91
	ei			;dd95
	reti			;dd96
	ld (0f4b2h),sp		;dd98
	ld sp,0f526h		;dd9c
	push af			;dd9f
	in a,(008h)		;dda0
	ld (0f4cdh),a		;dda2
	ld a,0ffh		;dda5
	ld (SIOFLG),a		;dda7
	pop af			;ddaa
	ld sp,(0f4b2h)		;ddab
	ei			;ddaf
	reti			;ddb0
	ld (0f4b2h),sp		;ddb2
	ld sp,0f526h		;ddb6
	push af			;ddb9
	ld a,001h		;ddba
	out (00ah),a		;ddbc
	in a,(00ah)		;ddbe
	ld (0f4d0h),a		;ddc0
	ld a,030h		;ddc3
	out (00ah),a		;ddc5
	xor a			;ddc7
	ld (0f4cdh),a		;ddc8
	cpl			;ddcb
	ld (SIOFLG),a		;ddcc
	pop af			;ddcf
	ld sp,(0f4b2h)		;ddd0
	ei			;ddd4
	reti			;ddd5
DSPY_START:
	ld a,h			;ddd7
	cpl			;ddd8
	ld h,a			;ddd9
	ld a,l			;ddda
	cpl			;dddb
	ld l,a			;dddc
	ret			;dddd
DSPY_NEG:
	call DSPY_START		;ddde
	inc hl			;dde1
	ret			;dde2
DSPY_INC:
	ld hl,(CURY)		;dde3
	ld a,l			;dde6
	cp 080h			;dde7
	ret nz			;dde9
	ld a,h			;ddea
	cp 007h			;ddeb
	ret			;dded
DSPY_CHECK:
	ld a,(0f4d3h)		;ddee
	or a			;ddf1
	ld a,c			;ddf2
	ret nz			;ddf3
DSPY_XLAT:
	ld b,000h		;ddf4
	add hl,bc		;ddf6
	ld a,(hl)		;ddf7
	ret			;ddf8
DSPY_CRT:
	push af			;ddf9
	ld a,080h		;ddfa
	out (001h),a		;ddfc
	ld a,(CURX)		;ddfe
	out (000h),a		;de01
	ld a,(0ffd4h)		;de03
	out (000h),a		;de06
	pop af			;de08
	ret			;de09
DSPY_DOWN:
	ld hl,(CURY)		;de0a
	ld de,00050h		;de0d
	add hl,de		;de10
	ld (CURY),hl		;de11
	ld hl,0ffd4h		;de14
	inc (hl)		;de17
	jr DSPY_CRT		;de18
DSPY_UP:
	ld hl,(CURY)		;de1a
	ld de,0ffb0h		;de1d
	add hl,de		;de20
	ld (CURY),hl		;de21
	ld hl,0ffd4h		;de24
	dec (hl)		;de27
	jr DSPY_CRT		;de28
DSPY_HOME:
	ld hl,00000h		;de2a
	ld (CURY),hl		;de2d
	xor a			;de30
	ld (CURX),a		;de31
	ld (0ffd4h),a		;de34
	ret			;de37
DSPY_CLR:
	cp b			;de38
	ret c			;de39
	sub b			;de3a
	jr DSPY_CLR		;de3b
DSPY_SCRL:
	ld hl,(0ffd5h)		;de3d
	ld d,h			;de40
	ld e,l			;de41
	inc de			;de42
	ld bc,0004fh		;de43
	ld (hl),020h		;de46
	ldir			;de48
	ret			;de4a
DSPY_SCRL2:
	ld hl,0f850h		;de4b
	ld de,SCREENBUF		;de4e
	ld bc,00780h		;de51
	ldir			;de54
	ld hl,0ff80h		;de56
	ld (0ffd5h),hl		;de59
	jr DSPY_SCRL		;de5c
	ld a,000h		;de5e
	ld b,003h		;de60
lde62h:
	srl h			;de62
	rr l			;de64
	rra			;de66
	dec b			;de67
	jr nz,lde62h		;de68
	cp 000h			;de6a
	ret z			;de6c
	ld b,005h		;de6d
lde6fh:
	rra			;de6f
	dec b			;de70
	jr nz,lde6fh		;de71
	ret			;de73
DSPY_DIV8:
	ld a,b			;de74
	or c			;de75
	ret z			;de76
	ldir			;de77
	ret			;de79
DSPY_SETBIT:
	ld a,b			;de7a
	or c			;de7b
	ret z			;de7c
	lddr			;de7d
	ret			;de7f
	out (01ch),a		;de80
	ret			;de82
	call DSPY_HOME		;de83
	ld a,002h		;de86
	ld (0ffd7h),a		;de88
	ret			;de8b
	ret			;de8c
	ld a,000h		;de8d
	ld (CURX),a		;de8f
	jp DSPY_CRT		;de92
	ld hl,SCREENBUF		;de95
	ld de,0f801h		;de98
	ld bc,0004fh		;de9b
	ld (hl),020h		;de9e
	ldir			;dea0
	inc hl			;dea2
	inc de			;dea3
	ld bc,0077fh		;dea4
	ld (hl),020h		;dea7
	ldir			;dea9
	ld a,020h		;deab
	ld (0f4d6h),a		;dead
	call DSPY_HOME		;deb0
	jp DSPY_CRT		;deb3
	ld de,SCREENBUF		;deb6
	ld hl,(CURY)		;deb9
	add hl,de		;debc
	ld de,0004fh		;debd
	add hl,de		;dec0
	ld d,h			;dec1
	ld e,l			;dec2
	dec de			;dec3
	ld bc,00000h		;dec4
	ld a,(CURX)		;dec7
	cpl			;deca
	inc a			;decb
	add a,04fh		;decc
	ld c,a			;dece
	ld (hl),020h		;decf
	jp DSPY_SETBIT		;ded1
	ld hl,(CURY)		;ded4
	ld a,(CURX)		;ded7
	ld c,a			;deda
	ld b,000h		;dedb
	add hl,bc		;dedd
	call DSPY_NEG		;dede
	ld de,007cfh		;dee1
	add hl,de		;dee4
	ld b,h			;dee5
	ld c,l			;dee6
	ld hl,SCRNEND		;dee7
	ld de,0ffceh		;deea
	ld (hl),020h		;deed
	jp DSPY_SETBIT		;deef
	ld a,(CURX)		;def2
	cp 000h			;def5
	jr z,ldf00h		;def7
	dec a			;def9
	ld (CURX),a		;defa
	jp DSPY_CRT		;defd
ldf00h:
	ld a,04fh		;df00
	ld (CURX),a		;df02
	ld hl,(CURY)		;df05
	ld a,l			;df08
	or h			;df09
	jp nz,DSPY_UP		;df0a
	ld hl,00780h		;df0d
	ld (CURY),hl		;df10
	ld a,018h		;df13
	ld (0ffd4h),a		;df15
	jp DSPY_CRT		;df18
ISR_CRT:
	ld a,(CURX)		;df1b
	cp 04fh			;df1e
	jr z,ldf29h		;df20
	inc a			;df22
	ld (CURX),a		;df23
	jp DSPY_CRT		;df26
ldf29h:
	ld a,000h		;df29
	ld (CURX),a		;df2b
	call DSPY_INC		;df2e
	jp nz,DSPY_DOWN		;df31
	call DSPY_CRT		;df34
	jp DSPY_SCRL2		;df37
	ld a,(CURX)		;df3a
	ld b,a			;df3d
	add a,004h		;df3e
	and 0fch		;df40
	dec a			;df42
	sub b			;df43
ldf44h:
	push af			;df44
	call ISR_CRT		;df45
	pop af			;df48
	dec a			;df49
	jr nz,ldf44h		;df4a
	ret			;df4c
	call DSPY_INC		;df4d
	jp nz,DSPY_DOWN		;df50
	jp DSPY_SCRL2		;df53
	ld hl,(CURY)		;df56
	ld a,l			;df59
	or h			;df5a
	jp nz,DSPY_UP		;df5b
	ld hl,00780h		;df5e
	ld (CURY),hl		;df61
	ld a,018h		;df64
	ld (0ffd4h),a		;df66
	jp DSPY_CRT		;df69
	call DSPY_HOME		;df6c
	jp DSPY_CRT		;df6f
	ld hl,(CURY)		;df72
	ld b,h			;df75
	ld c,l			;df76
	ld de,0f850h		;df77
	add hl,de		;df7a
	ld (0f4d4h),hl		;df7b
	ld de,0ffb0h		;df7e
	add hl,de		;df81
	ex de,hl		;df82
	ld h,b			;df83
	ld l,c			;df84
	call DSPY_NEG		;df85
	ld bc,00780h		;df88
	add hl,bc		;df8b
	ld b,h			;df8c
	ld c,l			;df8d
	ld hl,(0f4d4h)		;df8e
	call DSPY_DIV8		;df91
	ld hl,0ff80h		;df94
	ld (0ffd5h),hl		;df97
	jp DSPY_SCRL		;df9a
	ld hl,(CURY)		;df9d
	ld de,SCREENBUF		;dfa0
	add hl,de		;dfa3
	ld (0ffd5h),hl		;dfa4
	call DSPY_NEG		;dfa7
	ld de,0ff80h		;dfaa
	add hl,de		;dfad
	ld b,h			;dfae
	ld c,l			;dfaf
	ld hl,0ff7fh		;dfb0
	ld de,SCRNEND		;dfb3
	call DSPY_SETBIT	;dfb6
	jp DSPY_SCRL		;dfb9
CRT_CURSOR:
	adc a,h			;dfbc
	sbc a,09dh		;dfbd
	rst 18h			;dfbf
	ld (hl),d		;dfc0
	rst 18h			;dfc1
	adc a,h			;dfc2
	sbc a,08ch		;dfc3
	sbc a,0f2h		;dfc5
	sbc a,083h		;dfc7
	sbc a,080h		;dfc9
	sbc a,0f2h		;dfcb
	sbc a,03ah		;dfcd
	rst 18h			;dfcf
	ld c,l			;dfd0
	rst 18h			;dfd1
	adc a,h			;dfd2
	sbc a,095h		;dfd3
	sbc a,08dh		;dfd5
	sbc a,08ch		;dfd7
	sbc a,08ch		;dfd9
	sbc a,08ch		;dfdb
	sbc a,08ch		;dfdd
	sbc a,08ch		;dfdf
	sbc a,08ch		;dfe1
	sbc a,08ch		;dfe3
	sbc a,08ch		;dfe5
	sbc a,08ch		;dfe7
	sbc a,08ch		;dfe9
	sbc a,01bh		;dfeb
	rst 18h			;dfed
	adc a,h			;dfee
	sbc a,056h		;dfef
	rst 18h			;dff1
	adc a,h			;dff2
	sbc a,08ch		;dff3
	sbc a,06ch		;dff5
	rst 18h			;dff7
	or (hl)			;dff8
	sbc a,0d4h		;dff9
	sbc a,03eh		;dffb
	nop			;dffd
	ld (0ffd7h),a		;dffe
	ld a,(0ffdah)		;e001
	rlca			;e004
	and 03eh		;e005
	ld c,a			;e007
	ld b,000h		;e008
	ld hl,CRT_CURSOR	;e00a
	add hl,bc		;e00d
	ld e,(hl)		;e00e
	inc hl			;e00f
	ld d,(hl)		;e010
	ex de,hl		;e011
	jp (hl)			;e012
CONOUT_DISP:
	ld a,(0ffdah)		;e013
	and 07fh		;e016
	sub 020h		;e018
	ld hl,0ffd7h		;e01a
	dec (hl)		;e01d
	jr z,le024h		;e01e
	ld (0ffdeh),a		;e020
	ret			;e023
le024h:
	ld d,a			;e024
	ld a,(0ffdeh)		;e025
	ld h,a			;e028
	ld a,(code008_end)	;e029
	or a			;e02c
	jr z,le030h		;e02d
	ex de,hl		;e02f
le030h:
	ld a,h			;e030
	ld b,050h		;e031
	call DSPY_CLR		;e033
	ld (CURX),a		;e036
	ld a,d			;e039
	ld b,019h		;e03a
	call DSPY_CLR		;e03c
	ld (0ffd4h),a		;e03f
	or a			;e042
	jp z,DSPY_CRT		;e043
	ld hl,(CURY)		;e046
	ld de,00050h		;e049
le04ch:
	add hl,de		;e04c
	dec a			;e04d
	jr nz,le04ch		;e04e
	ld (CURY),hl		;e050
	jp DSPY_CRT		;e053
CONOUT_PROC:
	ld hl,(CURY)		;e056
	ld d,000h		;e059
	ld a,(CURX)		;e05b
	ld e,a			;e05e
	add hl,de		;e05f
	ld (0ffd8h),hl		;e060
	ld a,(0ffdah)		;e063
	cp 0c0h			;e066
	jr c,le06ch		;e068
	sub 0c0h		;e06a
le06ch:
	ld c,a			;e06c
	cp 080h			;e06d
	jr c,le079h		;e06f
	and 004h		;e071
	ld (0f4d3h),a		;e073
	ld a,c			;e076
	jr le07fh		;e077
le079h:
	ld hl,CONVTAB		;e079
	call DSPY_CHECK		;e07c
le07fh:
	ld hl,(0ffd8h)		;e07f
	ld de,SCREENBUF		;e082
	add hl,de		;e085
	ld (hl),a		;e086
	jp ISR_CRT		;e087
CONOUT_CLOCK:
	ld hl,(lda60h)		;e08a
	ld (0ffech),hl		;e08d
	ld a,(SCREENBUF)	;e090
	cp 0f3h			;e093
	ret			;e095
CONOUT:
	di			;e096
	push hl			;e097
	ld hl,00000h		;e098
	add hl,sp		;e09b
	ld sp,0f586h		;e09c
	ei			;e09f
	push hl			;e0a0
	push af			;e0a1
	push bc			;e0a2
	push de			;e0a3
	call CONOUT_CLOCK	;e0a4
	jr nz,le0afh		;e0a7
	ld a,(0f4d6h)		;e0a9
	ld (SCREENBUF),a	;e0ac
le0afh:
	ld a,c			;e0af
	ld (0ffdah),a		;e0b0
	ld a,(0ffd7h)		;e0b3
	or a			;e0b6
	jr z,le0beh		;e0b7
	call CONOUT_DISP	;e0b9
	jr le0cdh		;e0bc
le0beh:
	ld a,(0ffdah)		;e0be
	cp 020h			;e0c1
	jr nc,le0cah		;e0c3
	call ISR_FDC		;e0c5
	jr le0cdh		;e0c8
le0cah:
	call CONOUT_PROC	;e0ca
le0cdh:
	pop de			;e0cd
	pop bc			;e0ce
	pop af			;e0cf
	pop hl			;e0d0
	di			;e0d1
	ld sp,hl		;e0d2
	pop hl			;e0d3
	ei			;e0d4
	ret			;e0d5
ISR_MAIN:
	ld (0f4b2h),sp		;e0d6
	ld sp,0f526h		;e0da
	push af			;e0dd
	push bc			;e0de
	push de			;e0df
	push hl			;e0e0
	in a,(001h)		;e0e1
	ld a,006h		;e0e3
	out (0fah),a		;e0e5
	ld a,007h		;e0e7
	out (0fah),a		;e0e9
	out (0fch),a		;e0eb
	ld hl,SCREENBUF		;e0ed
	ld a,l			;e0f0
	out (0f4h),a		;e0f1
	ld a,h			;e0f3
	out (0f4h),a		;e0f4
	ld hl,007cfh		;e0f6
	ld a,l			;e0f9
	out (0f5h),a		;e0fa
	ld a,h			;e0fc
	out (0f5h),a		;e0fd
	ld a,000h		;e0ff
	out (0f7h),a		;e101
	out (0f7h),a		;e103
	ld a,002h		;e105
	out (0fah),a		;e107
	ld a,003h		;e109
	out (0fah),a		;e10b
	ld a,0d7h		;e10d
	out (00eh),a		;e10f
	ld a,001h		;e111
	out (00eh),a		;e113
	ld hl,0fffch		;e115
	inc (hl)		;e118
	jr nz,le125h		;e119
	inc hl			;e11b
	inc (hl)		;e11c
	jr nz,le125h		;e11d
	inc hl			;e11f
	inc (hl)		;e120
	jr nz,le125h		;e121
	inc hl			;e123
	inc (hl)		;e124
le125h:
	ld hl,(TIMER1)		;e125
	ld a,l			;e128
	or h			;e129
	jr z,CONOUT_END		;e12a
	dec hl			;e12c
	ld a,l			;e12d
	or h			;e12e
	ld (TIMER1),hl		;e12f
	call z,0ffe7h		;e132
CONOUT_END:
	ld hl,(TIMER2)		;e135
	ld a,l			;e138
	or h			;e139
	jr z,le145h		;e13a
	dec hl			;e13c
	ld a,l			;e13d
	or h			;e13e
	ld (TIMER2),hl		;e13f
	call z,sub_e54fh	;e142
le145h:
	ld hl,(0ffech)		;e145
	ld a,l			;e148
	or h			;e149
	jr z,le169h		;e14a
	dec hl			;e14c
	ld a,l			;e14d
	or h			;e14e
	ld (0ffech),hl		;e14f
	jr nz,le169h		;e152
	ld a,(SCREENBUF)	;e154
	ld (0f4d6h),a		;e157
	ld a,0f3h		;e15a
	ld (SCREENBUF),a	;e15c
	ld a,080h		;e15f
	out (001h),a		;e161
	ld a,020h		;e163
	out (000h),a		;e165
	out (000h),a		;e167
le169h:
	ld hl,0f4e8h		;e169
	dec (hl)		;e16c
	jr nz,le197h		;e16d
	ld (hl),032h		;e16f
	dec hl			;e171
	ld b,002h		;e172
	dec hl			;e174
le175h:
	dec hl			;e175
	inc (hl)		;e176
	call SELDSK_PRE		;e177
	jr nz,le197h		;e17a
	dec b			;e17c
	jr nz,le175h		;e17d
	dec hl			;e17f
	inc (hl)		;e180
	call SELDSK_PRE		;e181
	ld hl,0f4deh		;e184
	ld a,(hl)		;e187
	cp 032h			;e188
	jr nz,le197h		;e18a
	inc hl			;e18c
	ld a,(hl)		;e18d
	cp 034h			;e18e
	jr nz,le197h		;e190
	ld (hl),030h		;e192
	dec hl			;e194
	ld (hl),030h		;e195
le197h:
	ld hl,0f4e7h		;e197
	ld a,(hl)		;e19a
	or a			;e19b
	jr nz,le1a7h		;e19c
	dec hl			;e19e
	ld bc,0000ch		;e19f
	ld de,0f84fh		;e1a2
	lddr			;e1a5
le1a7h:
	ld hl,(WARMJP)		;e1a7
	ld a,l			;e1aa
	or h			;e1ab
	jr z,le1b2h		;e1ac
	dec hl			;e1ae
	ld (WARMJP),hl		;e1af
le1b2h:
	ld hl,0f4d8h		;e1b2
	ld a,(hl)		;e1b5
	or a			;e1b6
	jr z,le1bah		;e1b7
	dec (hl)		;e1b9
le1bah:
	pop hl			;e1ba
	pop de			;e1bb
	pop bc			;e1bc
	pop af			;e1bd
	ld sp,(0f4b2h)		;e1be
	ei			;e1c2
	reti			;e1c3
SELDSK_PRE:
	ld a,(hl)		;e1c5
	cp 03ah			;e1c6
	ret nz			;e1c8
	ld (hl),030h		;e1c9
	dec hl			;e1cb
	inc (hl)		;e1cc
	ld a,(hl)		;e1cd
	cp 036h			;e1ce
	ret nz			;e1d0
	ld (hl),030h		;e1d1
	dec hl			;e1d3
	ret			;e1d4
SELDSK:
	ld hl,00000h		;e1d5
	add hl,sp		;e1d8
	ld sp,0f586h		;e1d9
	push hl			;e1dc
	ld de,00000h		;e1dd
	ld a,c			;e1e0
	cp 004h			;e1e1
	jp nc,SELDSK_RET	;e1e3
	ld hl,lda73h		;e1e6
	ld b,000h		;e1e9
	add hl,bc		;e1eb
	ld c,(hl)		;e1ec
	ld hl,lda37h		;e1ed
	add hl,bc		;e1f0
	ld a,(hl)		;e1f1
	cp 0ffh			;e1f2
	jp z,SELDSK_RET		;e1f4
	ld a,c			;e1f7
	ld (0f482h),a		;e1f8
	ld bc,00010h		;e1fb
	ld de,lda37h		;e1fe
	ld hl,00000h		;e201
le204h:
	or a			;e204
	jr z,le20ch		;e205
	inc de			;e207
	add hl,bc		;e208
	dec a			;e209
	jr le204h		;e20a
le20ch:
	ld c,l			;e20c
	ld b,h			;e20d
	ex de,hl		;e20e
	push bc			;e20f
	push hl			;e210
	ld a,(hl)		;e211
	push af			;e212
	ld a,(0f492h)		;e213
	or a			;e216
	call nz,DISKRD		;e217
	xor a			;e21a
	ld (0f492h),a		;e21b
	pop af			;e21e
	ld (0f4a2h),a		;e21f
	pop hl			;e222
	ld bc,00008h		;e223
	add hl,bc		;e226
	ld a,(hl)		;e227
	and 003h		;e228
	or 080h			;e22a
	ld (0f4c8h),a		;e22c
	ld a,(hl)		;e22f
	or 00fh			;e230
	ld b,a			;e232
	ld a,003h		;e233
	out (005h),a		;e235
	call FDCRECAL		;e237
	ld a,b			;e23a
	out (005h),a		;e23b
	call FDCRECAL		;e23d
	ld a,028h		;e240
	out (005h),a		;e242
	call SELDSK_DPB		;e244
	ld (0f4a0h),hl		;e247
	inc hl			;e24a
	inc hl			;e24b
	inc hl			;e24c
	inc hl			;e24d
	ld a,(hl)		;e24e
	ld (0f4a3h),a		;e24f
	ld a,(0f4a2h)		;e252
	and 0f8h		;e255
	or a			;e257
	rla			;e258
	ld e,a			;e259
	ld d,000h		;e25a
	ld hl,le820h		;e25c
	add hl,de		;e25f
	ld de,0f4b7h		;e260
	ld bc,00010h		;e263
	ldir			;e266
	ld hl,(0f4b7h)		;e268
	ld bc,0000dh		;e26b
	add hl,bc		;e26e
	ex de,hl		;e26f
	ld hl,le816h		;e270
	ld b,000h		;e273
	ld a,(0f482h)		;e275
	ld c,a			;e278
	add hl,bc		;e279
	add hl,bc		;e27a
	ld bc,00002h		;e27b
	ldir			;e27e
	pop bc			;e280
	ld hl,le9b8h		;e281
	add hl,bc		;e284
	ex de,hl		;e285
	ld hl,0000ah		;e286
	add hl,de		;e289
	ex de,hl		;e28a
	ld a,(0f4b7h)		;e28b
	ld (de),a		;e28e
	inc de			;e28f
	ld a,(0f4b8h)		;e290
	ld (de),a		;e293
	push hl			;e294
	ld hl,0f4b6h		;e295
	ld a,(0f482h)		;e298
	ld (hl),0ffh		;e29b
	cp 004h			;e29d
	jr z,le2a2h		;e29f
	inc (hl)		;e2a1
le2a2h:
	pop de			;e2a2
SELDSK_RET:
	pop hl			;e2a3
	ld sp,hl		;e2a4
	ex de,hl		;e2a5
	ret			;e2a6
SELDSK_DPB:
	ld hl,le931h		;e2a7
	ld a,(0f4a2h)		;e2aa
	and 0f8h		;e2ad
	ld e,a			;e2af
	ld d,000h		;e2b0
	add hl,de		;e2b2
	ret			;e2b3
SETTRK:
	ld (0f483h),bc		;e2b4
	ret			;e2b8
SETSEC:
	ld (0f485h),bc		;e2b9
	ret			;e2bd
SETDMA:
	ld (0f49eh),bc		;e2be
	ret			;e2c2
SECTRAN:
	ld h,b			;e2c3
	ld l,c			;e2c4
	ret			;e2c5
READ:
	xor a			;e2c6
	ld (0f493h),a		;e2c7
	ld a,001h		;e2ca
	ld (0f49ch),a		;e2cc
	ld (0f49bh),a		;e2cf
	ld a,003h		;e2d2
	ld (0f49dh),a		;e2d4
	jp DISKIO		;e2d7
WRITE:
	xor a			;e2da
	ld (0f49ch),a		;e2db
	ld a,c			;e2de
	ld (0f49dh),a		;e2df
	cp 003h			;e2e2
	jr nz,le2feh		;e2e4
	ld a,(0f4b9h)		;e2e6
	ld (0f493h),a		;e2e9
	ld a,(0f482h)		;e2ec
	ld (0f494h),a		;e2ef
	ld hl,(0f483h)		;e2f2
	ld (0f495h),hl		;e2f5
	ld hl,(0f485h)		;e2f8
	ld (0f497h),hl		;e2fb
le2feh:
	ld a,(0f493h)		;e2fe
	or a			;e301
	jr z,le35ch		;e302
	dec a			;e304
	ld (0f493h),a		;e305
	ld a,(0f482h)		;e308
	ld hl,0f494h		;e30b
	cp (hl)			;e30e
	jr nz,le35ch		;e30f
	ld hl,0f495h		;e311
	ld a,(0f483h)		;e314
	cp (hl)			;e317
	jr nz,le35ch		;e318
	ld a,(0f485h)		;e31a
	ld hl,0f497h		;e31d
	cp (hl)			;e320
	jr nz,le35ch		;e321
	ld hl,(0f497h)		;e323
	inc hl			;e326
	ld (0f497h),hl		;e327
	ex de,hl		;e32a
	ld hl,0f4bah		;e32b
	push bc			;e32e
	ld c,(hl)		;e32f
	inc hl			;e330
	ld b,(hl)		;e331
	ex de,hl		;e332
	and a			;e333
	sbc hl,bc		;e334
	pop bc			;e336
	jr c,le346h		;e337
	ld hl,00000h		;e339
	ld (0f497h),hl		;e33c
	ld hl,(0f495h)		;e33f
	inc hl			;e342
	ld (0f495h),hl		;e343
le346h:
	xor a			;e346
	ld (0f49bh),a		;e347
	ld a,(0f485h)		;e34a
	ld hl,0f4bch		;e34d
	and (hl)		;e350
	cp (hl)			;e351
	ld a,000h		;e352
	jr nz,le357h		;e354
	inc a			;e356
le357h:
	ld (0f499h),a		;e357
	jr DISKIO		;e35a
le35ch:
	xor a			;e35c
	ld (0f493h),a		;e35d
	ld a,(0f4bch)		;e360
	ld (0f49bh),a		;e363
DISKIO:
	ld hl,00000h		;e366
	add hl,sp		;e369
	ld sp,0f586h		;e36a
	push hl			;e36d
	ld a,(0f4bdh)		;e36e
	ld b,a			;e371
	ld hl,(0f485h)		;e372
le375h:
	dec b			;e375
	jr z,le37eh		;e376
	srl h			;e378
	rr l			;e37a
	jr le375h		;e37c
le37eh:
	ld (0f48fh),hl		;e37e
	ld hl,0f491h		;e381
	ld a,(hl)		;e384
	ld (hl),001h		;e385
	or a			;e387
	jr z,le3ach		;e388
	ld a,(0f482h)		;e38a
	ld hl,0f487h		;e38d
	cp (hl)			;e390
	jr nz,le3a5h		;e391
	ld hl,0f488h		;e393
	ld a,(0f483h)		;e396
	cp (hl)			;e399
	jr nz,le3a5h		;e39a
	ld a,(0f48fh)		;e39c
	ld hl,0f48ah		;e39f
	cp (hl)			;e3a2
	jr z,le3c9h		;e3a3
le3a5h:
	ld a,(0f492h)		;e3a5
	or a			;e3a8
	call nz,DISKRD		;e3a9
le3ach:
	ld a,(0f482h)		;e3ac
	ld (0f487h),a		;e3af
	ld hl,(0f483h)		;e3b2
	ld (0f488h),hl		;e3b5
	ld hl,(0f48fh)		;e3b8
	ld (0f48ah),hl		;e3bb
	ld a,(0f49bh)		;e3be
	or a			;e3c1
	call nz,sub_e42ah	;e3c2
	xor a			;e3c5
	ld (0f492h),a		;e3c6
le3c9h:
	ld a,(0f485h)		;e3c9
	ld hl,0f4bch		;e3cc
	and (hl)		;e3cf
	ld l,a			;e3d0
	ld h,000h		;e3d1
	add hl,hl		;e3d3
	add hl,hl		;e3d4
	add hl,hl		;e3d5
	add hl,hl		;e3d6
	add hl,hl		;e3d7
	add hl,hl		;e3d8
	add hl,hl		;e3d9
	ld de,0ec81h		;e3da
	add hl,de		;e3dd
	ex de,hl		;e3de
	ld hl,(0f49eh)		;e3df
	ld bc,00080h		;e3e2
	ex de,hl		;e3e5
	ld a,(0f49ch)		;e3e6
	or a			;e3e9
	jr nz,le3f2h		;e3ea
	ld a,001h		;e3ec
	ld (0f492h),a		;e3ee
	ex de,hl		;e3f1
le3f2h:
	ldir			;e3f2
	ld a,(0f49dh)		;e3f4
	cp 001h			;e3f7
	ld hl,RAMDSTAT		;e3f9
	ld a,(hl)		;e3fc
	push af			;e3fd
	or a			;e3fe
	jr z,le405h		;e3ff
	xor a			;e401
	ld (0f491h),a		;e402
le405h:
	pop af			;e405
	ld (hl),000h		;e406
	jr nz,le41ah		;e408
	or a			;e40a
	jr nz,le41ah		;e40b
	xor a			;e40d
	ld (0f492h),a		;e40e
	call DISKRD		;e411
	ld hl,RAMDSTAT		;e414
	ld a,(hl)		;e417
	ld (hl),000h		;e418
le41ah:
	pop hl			;e41a
	ld sp,hl		;e41b
	ret			;e41c
DISKRD:
	ld a,(0f4b6h)		;e41d
	or a			;e420
	jp nz,RAMDISK_INT	;e421
	call DISKWR		;e424
	jp FDCWAIT		;e427
sub_e42ah:
	ld a,(0f499h)		;e42a
	or a			;e42d
	jr nz,le433h		;e42e
	ld (0f493h),a		;e430
le433h:
	ld a,(0f4b6h)		;e433
	or a			;e436
	jp nz,RAMDISK_INT2	;e437
	call DISKWR		;e43a
	jr le4b9h		;e43d
DISKWR:
	ld a,(0f48ah)		;e43f
	ld c,a			;e442
	ld a,(0f4a3h)		;e443
	ld b,a			;e446
	dec a			;e447
	cp c			;e448
	ld a,(0f487h)		;e449
	jr nc,le458h		;e44c
	or 004h			;e44e
	ld (0f4a4h),a		;e450
	ld a,c			;e453
	sub b			;e454
	ld c,a			;e455
	jr le45bh		;e456
le458h:
	ld (0f4a4h),a		;e458
le45bh:
	ld b,000h		;e45b
	ld hl,(0f4beh)		;e45d
	add hl,bc		;e460
	ld a,(hl)		;e461
	ld (0f4a8h),a		;e462
	ld a,(0f488h)		;e465
	ld (0f4a7h),a		;e468
	ld hl,0ec81h		;e46b
	ld (0f4a5h),hl		;e46e
	ld a,(0f487h)		;e471
	ld hl,0f48ch		;e474
	cp (hl)			;e477
	jr nz,le489h		;e478
	ld a,(0f488h)		;e47a
	ld hl,0f48dh		;e47d
	cp (hl)			;e480
	jr nz,le489h		;e481
	ld a,(0f489h)		;e483
	inc hl			;e486
	cp (hl)			;e487
	ret z			;e488
le489h:
	ld a,(0f487h)		;e489
	ld (0f48ch),a		;e48c
	ld hl,(0f488h)		;e48f
	ld (0f48dh),hl		;e492
	call FLUSH		;e495
	call MOTOROFF		;e498
	call RAMDISK		;e49b
	ld a,(0f4a4h)		;e49e
	and 003h		;e4a1
	add a,020h		;e4a3
	cp b			;e4a5
	ret z			;e4a6
sub_e4a7h:
	call FLUSH		;e4a7
	call FDCDMA_RD		;e4aa
	push bc			;e4ad
	call RAMDISK		;e4ae
	call MOTOROFF		;e4b1
	call RAMDISK		;e4b4
	pop bc			;e4b7
	ret			;e4b8
le4b9h:
	ld a,00ah		;e4b9
	ld (0f4a9h),a		;e4bb
le4beh:
	call FDCREAD		;e4be
	call FLUSH		;e4c1
	ld hl,(0f4a0h)		;e4c4
	ld c,(hl)		;e4c7
	inc hl			;e4c8
	ld b,(hl)		;e4c9
	inc hl			;e4ca
	call RAMDISK_DMA	;e4cb
	call FDCRESULT		;e4ce
	call RAMDISK_RD		;e4d1
	ld c,000h		;e4d4
le4d6h:
	ld hl,0f4aah		;e4d6
	ld a,(hl)		;e4d9
	and 0f8h		;e4da
	ret z			;e4dc
	and 008h		;e4dd
	jr nz,le4f5h		;e4df
	ld a,(0f4a9h)		;e4e1
	dec a			;e4e4
	ld (0f4a9h),a		;e4e5
	jr z,le4f5h		;e4e8
	cp 005h			;e4ea
	call z,sub_e4a7h	;e4ec
	xor a			;e4ef
	cp c			;e4f0
	jr z,le4beh		;e4f1
	jr le504h		;e4f3
le4f5h:
	ld a,c			;e4f5
	ld (0f491h),a		;e4f6
	ld a,001h		;e4f9
	ld (RAMDSTAT),a		;e4fb
	ret			;e4fe
FDCWAIT:
	ld a,00ah		;e4ff
	ld (0f4a9h),a		;e501
le504h:
	call FDCREAD		;e504
	call FLUSH		;e507
	ld hl,(0f4a0h)		;e50a
	ld c,(hl)		;e50d
	inc hl			;e50e
	ld b,(hl)		;e50f
	inc hl			;e510
	call RAMDISK_WR		;e511
	call FDCRESULT2		;e514
	call RAMDISK_RD		;e517
	ld c,001h		;e51a
	jr le4d6h		;e51c
FDCRESULT:
	ld a,006h		;e51e
	jp RAMDISK_IO		;e520
FDCRESULT2:
	ld a,005h		;e523
	jp RAMDISK_IO		;e525
FDCREAD:
	di			;e528
	ld hl,(TIMER2)		;e529
	ld a,h			;e52c
	or l			;e52d
	ld a,(0f4c8h)		;e52e
	jr z,le535h		;e531
	or 001h			;e533
le535h:
	out (014h),a		;e535
	ld a,(0f4c8h)		;e537
	and 001h		;e53a
	jr nz,le540h		;e53c
	ei			;e53e
	ret			;e53f
le540h:
	ld a,h			;e540
	or l			;e541
	ld hl,(0ffeah)		;e542
	ld (TIMER2),hl		;e545
	ei			;e548
	ret nz			;e549
	ld hl,00032h		;e54a
	jr FDCSEEK		;e54d
sub_e54fh:
	ld a,000h		;e54f
	out (014h),a		;e551
	ret			;e553
FDCSEEK:
	ld (WARMJP),hl		;e554
le557h:
	ld hl,(WARMJP)		;e557
	ld a,l			;e55a
	or h			;e55b
	jr nz,le557h		;e55c
	ret			;e55e
HOME:
	ld a,(0f492h)		;e55f
	or a			;e562
	jr nz,le568h		;e563
	ld (0f491h),a		;e565
le568h:
	ld a,(0f4b6h)		;e568
	or a			;e56b
	jr z,le574h		;e56c
	xor a			;e56e
	out (0e6h),a		;e56f
	out (0e7h),a		;e571
	ret			;e573
le574h:
	call FDCREAD		;e574
	ld a,(0f482h)		;e577
	ld (0f4a4h),a		;e57a
	ld (0f48ch),a		;e57d
	xor a			;e580
	ld (0f48dh),a		;e581
	ld (0f48eh),a		;e584
	call FLUSH		;e587
	call FDCDMA_RD		;e58a
	call RAMDISK		;e58d
	ret			;e590
FDCRECAL:
	in a,(004h)		;e591
	and 0c0h		;e593
	cp 080h			;e595
	jr nz,FDCRECAL		;e597
	ret			;e599
FDCCMD:
	in a,(004h)		;e59a
	and 0c0h		;e59c
	cp 0c0h			;e59e
	jr nz,FDCCMD		;e5a0
	ret			;e5a2
FDCDMA_RD:
	call FDCRECAL		;e5a3
	ld a,007h		;e5a6
	out (005h),a		;e5a8
	call FDCRECAL		;e5aa
	ld a,(0f4a4h)		;e5ad
	and 003h		;e5b0
	out (005h),a		;e5b2
	ret			;e5b4
	call FDCRECAL		;e5b5
	ld a,004h		;e5b8
	out (005h),a		;e5ba
	call FDCRECAL		;e5bc
	ld a,(0f4a4h)		;e5bf
	and 003h		;e5c2
	out (005h),a		;e5c4
	call FDCCMD		;e5c6
	in a,(005h)		;e5c9
	ld (0f4aah),a		;e5cb
	ret			;e5ce
FDCMOTOR:
	call FDCRECAL		;e5cf
	ld a,008h		;e5d2
	out (005h),a		;e5d4
	call FDCCMD		;e5d6
	in a,(005h)		;e5d9
	ld (0f4aah),a		;e5db
	and 0c0h		;e5de
	cp 080h			;e5e0
	ret z			;e5e2
	call FDCCMD		;e5e3
	in a,(005h)		;e5e6
	ld (0f4abh),a		;e5e8
	ret			;e5eb
MOTOROFF:
	di			;e5ec
	call FDCRECAL		;e5ed
	ld a,00fh		;e5f0
	out (005h),a		;e5f2
	call FDCRECAL		;e5f4
	ld a,(0f4a4h)		;e5f7
	and 003h		;e5fa
	out (005h),a		;e5fc
	call FDCRECAL		;e5fe
	ld a,(0f4a7h)		;e601
	out (005h),a		;e604
	ei			;e606
	ret			;e607
MOTORTIMER:
	ld hl,0f4aah		;e608
	ld d,007h		;e60b
le60dh:
	call FDCCMD		;e60d
	in a,(005h)		;e610
	ld (hl),a		;e612
	inc hl			;e613
	ld a,004h		;e614
le616h:
	dec a			;e616
	jr nz,le616h		;e617
	in a,(004h)		;e619
	and 010h		;e61b
	ret z			;e61d
	dec d			;e61e
	jr nz,le60dh		;e61f
	ret			;e621
FLUSH:
	di			;e622
	xor a			;e623
	ld (0f4b4h),a		;e624
	ei			;e627
	ret			;e628
RAMDISK:
	call RAMDISK_RD		;e629
	ld a,(0f4aah)		;e62c
	ld b,a			;e62f
	ld a,(0f4abh)		;e630
	ld c,a			;e633
	jr FLUSH		;e634
RAMDISK_RD:
	ld a,(0f4b4h)		;e636
	or a			;e639
	jr z,RAMDISK_RD		;e63a
	ret			;e63c
RAMDISK_WR:
	ld a,005h		;e63d
	di			;e63f
	out (0fah),a		;e640
	ld a,049h		;e642
le644h:
	out (0fbh),a		;e644
	out (0fch),a		;e646
	ld a,(0f4a5h)		;e648
	out (0f2h),a		;e64b
	ld a,(0f4a6h)		;e64d
	out (0f2h),a		;e650
	ld a,c			;e652
	out (0f3h),a		;e653
	ld a,b			;e655
	out (0f3h),a		;e656
	ld a,001h		;e658
	out (0fah),a		;e65a
	ei			;e65c
	ret			;e65d
RAMDISK_DMA:
	ld a,005h		;e65e
	di			;e660
	out (0fah),a		;e661
	ld a,045h		;e663
	jr le644h		;e665
RAMDISK_IO:
	push af			;e667
	di			;e668
	call FDCRECAL		;e669
	pop af			;e66c
	ld b,(hl)		;e66d
	inc hl			;e66e
	add a,b			;e66f
	out (005h),a		;e670
	call FDCRECAL		;e672
	ld a,(0f4a4h)		;e675
	out (005h),a		;e678
	call FDCRECAL		;e67a
	ld a,(0f4a7h)		;e67d
	out (005h),a		;e680
	call FDCRECAL		;e682
	ld a,(0f4a4h)		;e685
	rra			;e688
	rra			;e689
	and 003h		;e68a
	out (005h),a		;e68c
	call FDCRECAL		;e68e
	ld a,(0f4a8h)		;e691
	out (005h),a		;e694
	call FDCRECAL		;e696
	ld a,(hl)		;e699
	inc hl			;e69a
	out (005h),a		;e69b
	call FDCRECAL		;e69d
	ld a,(hl)		;e6a0
	inc hl			;e6a1
	out (005h),a		;e6a2
	call FDCRECAL		;e6a4
	ld a,(hl)		;e6a7
	out (005h),a		;e6a8
	call FDCRECAL		;e6aa
	ld a,(0f4c0h)		;e6ad
	out (005h),a		;e6b0
	ei			;e6b2
	ret			;e6b3
	ld (0f4b2h),sp		;e6b4
	ld sp,0f526h		;e6b8
	push af			;e6bb
	push bc			;e6bc
	push de			;e6bd
	push hl			;e6be
	ld a,0ffh		;e6bf
	ld (0f4b4h),a		;e6c1
	ld a,005h		;e6c4
le6c6h:
	dec a			;e6c6
	jr nz,le6c6h		;e6c7
	in a,(004h)		;e6c9
	and 010h		;e6cb
	jr nz,le6d4h		;e6cd
	call FDCMOTOR		;e6cf
	jr le6d7h		;e6d2
le6d4h:
	call MOTORTIMER		;e6d4
le6d7h:
	pop hl			;e6d7
	pop de			;e6d8
	pop bc			;e6d9
	pop af			;e6da
	ld sp,(0f4b2h)		;e6db
	ei			;e6df
	reti			;e6e0
RAMDISK_INT:
	ld e,0e0h		;e6e2
	jr le6e8h		;e6e4
RAMDISK_INT2:
	ld e,0c0h		;e6e6
le6e8h:
	ld hl,0ec81h		;e6e8
	ld a,(0f488h)		;e6eb
	out (0e6h),a		;e6ee
	in a,(0e7h)		;e6f0
	and e			;e6f2
	ld (RAMDSTAT),a		;e6f3
	ret nz			;e6f6
	ld a,(0f48ah)		;e6f7
	out (0e7h),a		;e6fa
	ld b,0ffh		;e6fc
	ld c,0e8h		;e6fe
	ld a,e			;e700
	and 020h		;e701
	jr z,le70bh		;e703
	otir			;e705
	outi			;e707
	jr le70fh		;e709
le70bh:
	inir			;e70b
	ini			;e70d
le70fh:
	in a,(0e7h)		;e70f
	and 0c0h		;e711
	ld (RAMDSTAT),a		;e713
CODE_END:
	ret			;e716
code017_end:
DPBTAB:

; BLOCK 'dpbtab' (start 0xe717 end 0xe7ad)
dpbtab_start:
	defb 020h		;e717
	defb 000h		;e718
	defb 003h		;e719
	defb 007h		;e71a
	defb 000h		;e71b
	defb 09fh		;e71c
	defb 000h		;e71d
	defb 03fh		;e71e
	defb 000h		;e71f
	defb 0c0h		;e720
	defb 000h		;e721
	defb 010h		;e722
	defb 000h		;e723
	defb 000h		;e724
	defb 000h		;e725
	defb 040h		;e726
	defb 000h		;e727
	defb 004h		;e728
	defb 00fh		;e729
	defb 001h		;e72a
	defb 09fh		;e72b
	defb 000h		;e72c
	defb 07fh		;e72d
	defb 000h		;e72e
	defb 0c0h		;e72f
	defb 000h		;e730
	defb 020h		;e731
	defb 000h		;e732
	defb 000h		;e733
	defb 000h		;e734
	defb 048h		;e735
	defb 000h		;e736
	defb 004h		;e737
	defb 00fh		;e738
	defb 001h		;e739
	defb 0aah		;e73a
	defb 000h		;e73b
	defb 07fh		;e73c
	defb 000h		;e73d
	defb 0c0h		;e73e
	defb 000h		;e73f
	defb 020h		;e740
	defb 000h		;e741
	defb 002h		;e742
	defb 000h		;e743
	defb 078h		;e744
	defb 000h		;e745
	defb 004h		;e746
	defb 00fh		;e747
	defb 000h		;e748
	defb 031h		;e749
	defb 002h		;e74a
	defb 07fh		;e74b
	defb 000h		;e74c
	defb 0c0h		;e74d
	defb 000h		;e74e
	defb 020h		;e74f
	defb 000h		;e750
	defb 002h		;e751
	defb 000h		;e752
	defb 080h		;e753
	defb 000h		;e754
	defb 004h		;e755
	defb 00fh		;e756
	defb 000h		;e757
	defb 057h		;e758
	defb 002h		;e759
	defb 0ffh		;e75a
	defb 001h		;e75b
	defb 0ffh		;e75c
	defb 000h		;e75d
	defb 080h		;e75e
	defb 000h		;e75f
	defb 002h		;e760
	defb 000h		;e761
	defb 050h		;e762
	defb 000h		;e763
	defb 004h		;e764
	defb 00fh		;e765
	defb 001h		;e766
	defb 0bdh		;e767
	defb 000h		;e768
	defb 0ffh		;e769
	defb 000h		;e76a
	defb 0f0h		;e76b
	defb 000h		;e76c
	defb 040h		;e76d
	defb 000h		;e76e
	defb 002h		;e76f
	defb 000h		;e770
	defb 050h		;e771
	defb 000h		;e772
	defb 004h		;e773
	defb 00fh		;e774
	defb 000h		;e775
	defb 02bh		;e776
	defb 001h		;e777
	defb 0ffh		;e778
	defb 000h		;e779
	defb 0f0h		;e77a
	defb 000h		;e77b
	defb 040h		;e77c
	defb 000h		;e77d
	defb 002h		;e77e
	defb 000h		;e77f
	defb 01ah		;e780
	defb 000h		;e781
	defb 003h		;e782
	defb 007h		;e783
	defb 000h		;e784
	defb 0f2h		;e785
	defb 000h		;e786
	defb 03fh		;e787
	defb 000h		;e788
	defb 0c0h		;e789
	defb 000h		;e78a
	defb 010h		;e78b
	defb 000h		;e78c
	defb 002h		;e78d
	defb 000h		;e78e
	defb 068h		;e78f
	defb 000h		;e790
	defb 004h		;e791
	defb 00fh		;e792
	defb 000h		;e793
	defb 0d7h		;e794
	defb 001h		;e795
	defb 07fh		;e796
	defb 000h		;e797
	defb 0c0h		;e798
	defb 000h		;e799
	defb 020h		;e79a
	defb 000h		;e79b
	defb 000h		;e79c
	defb 000h		;e79d
	defb 028h		;e79e
	defb 000h		;e79f
	defb 003h		;e7a0
	defb 007h		;e7a1
	defb 000h		;e7a2
	defb 0bdh		;e7a3
	defb 000h		;e7a4
	defb 03fh		;e7a5
	defb 000h		;e7a6
	defb 0c0h		;e7a7
	defb 000h		;e7a8
	defb 010h		;e7a9
	defb 000h		;e7aa
	defb 002h		;e7ab
	defb 000h		;e7ac
dpbtab_end:
DPBASE:

; BLOCK 'dpbase' (start 0xe7ad end 0xe82e)
dpbase_start:
	defb 000h		;e7ad
	defb 000h		;e7ae
	defb 000h		;e7af
	defb 000h		;e7b0
	defb 000h		;e7b1
	defb 000h		;e7b2
	defb 000h		;e7b3
	defb 000h		;e7b4
	defb 000h		;e7b5
	defb 000h		;e7b6
	defb 000h		;e7b7
	defb 000h		;e7b8
	defb 000h		;e7b9
	defb 000h		;e7ba
	defb 000h		;e7bb
	defb 000h		;e7bc
	defb 000h		;e7bd
	defb 000h		;e7be
	defb 000h		;e7bf
	defb 000h		;e7c0
	defb 000h		;e7c1
	defb 000h		;e7c2
	defb 000h		;e7c3
	defb 000h		;e7c4
	defb 000h		;e7c5
	defb 000h		;e7c6
	defb 000h		;e7c7
	defb 000h		;e7c8
	defb 000h		;e7c9
	defb 000h		;e7ca
	defb 000h		;e7cb
	defb 000h		;e7cc
	defb 000h		;e7cd
	defb 000h		;e7ce
	defb 000h		;e7cf
	defb 000h		;e7d0
	defb 000h		;e7d1
	defb 000h		;e7d2
	defb 000h		;e7d3
	defb 000h		;e7d4
	defb 000h		;e7d5
	defb 000h		;e7d6
	defb 000h		;e7d7
	defb 000h		;e7d8
	defb 000h		;e7d9
	defb 000h		;e7da
	defb 000h		;e7db
	defb 000h		;e7dc
	defb 000h		;e7dd
	defb 000h		;e7de
	defb 000h		;e7df
	defb 000h		;e7e0
	defb 000h		;e7e1
	defb 000h		;e7e2
	defb 000h		;e7e3
	defb 000h		;e7e4
	defb 000h		;e7e5
	defb 000h		;e7e6
	defb 000h		;e7e7
	defb 000h		;e7e8
	defb 000h		;e7e9
	defb 000h		;e7ea
	defb 000h		;e7eb
	defb 000h		;e7ec
	defb 000h		;e7ed
	defb 000h		;e7ee
	defb 000h		;e7ef
	defb 000h		;e7f0
	defb 000h		;e7f1
	defb 000h		;e7f2
	defb 000h		;e7f3
	defb 000h		;e7f4
	defb 000h		;e7f5
	defb 000h		;e7f6
	defb 000h		;e7f7
	defb 000h		;e7f8
	defb 000h		;e7f9
	defb 000h		;e7fa
	defb 000h		;e7fb
	defb 000h		;e7fc
	defb 000h		;e7fd
	defb 000h		;e7fe
	defb 000h		;e7ff
	defb 000h		;e800
	defb 000h		;e801
	defb 000h		;e802
	defb 000h		;e803
	defb 000h		;e804
	defb 000h		;e805
	defb 000h		;e806
	defb 020h		;e807
	defb 000h		;e808
	defb 004h		;e809
	defb 00fh		;e80a
	defb 001h		;e80b
le80ch:
	defb 000h		;e80c
le80dh:
	defb 000h		;e80d
	defb 07fh		;e80e
	defb 000h		;e80f
	defb 0c0h		;e810
	defb 000h		;e811
	defb 000h		;e812
	defb 000h		;e813
	defb 002h		;e814
	defb 000h		;e815
le816h:
	defb 002h		;e816
	defb 000h		;e817
	defb 002h		;e818
	defb 000h		;e819
	defb 002h		;e81a
	defb 000h		;e81b
	defb 002h		;e81c
	defb 000h		;e81d
	defb 002h		;e81e
	defb 000h		;e81f
le820h:
	defb 017h		;e820
	defb 0e7h		;e821
	defb 008h		;e822
	defb 010h		;e823
	defb 000h		;e824
	defb 000h		;e825
	defb 001h		;e826
	defb 03bh		;e827
	defb 0eah		;e828
	defb 080h		;e829
	defb 000h		;e82a
	defb 000h		;e82b
	defb 000h		;e82c
	defb 000h		;e82d
dpbase_end:
DPHINIT:

; BLOCK 'dphinit' (start 0xe82e end 0xe8be)
dphinit_start:
	defb 000h		;e82e
	defb 000h		;e82f
	defb 026h		;e830
	defb 0e7h		;e831
	defb 010h		;e832
	defb 020h		;e833
	defb 000h		;e834
	defb 001h		;e835
	defb 002h		;e836
	defb 03bh		;e837
	defb 0eah		;e838
	defb 0ffh		;e839
	defb 000h		;e83a
	defb 000h		;e83b
	defb 000h		;e83c
	defb 000h		;e83d
	defb 000h		;e83e
	defb 000h		;e83f
	defb 035h		;e840
	defb 0e7h		;e841
	defb 010h		;e842
	defb 048h		;e843
	defb 000h		;e844
	defb 003h		;e845
	defb 003h		;e846
	defb 031h		;e847
	defb 0eah		;e848
	defb 0ffh		;e849
	defb 000h		;e84a
	defb 000h		;e84b
	defb 000h		;e84c
	defb 000h		;e84d
	defb 000h		;e84e
	defb 000h		;e84f
	defb 044h		;e850
	defb 0e7h		;e851
	defb 010h		;e852
	defb 078h		;e853
	defb 000h		;e854
	defb 003h		;e855
	defb 003h		;e856
	defb 022h		;e857
	defb 0eah		;e858
	defb 0ffh		;e859
	defb 000h		;e85a
	defb 000h		;e85b
	defb 000h		;e85c
	defb 000h		;e85d
	defb 000h		;e85e
	defb 000h		;e85f
	defb 053h		;e860
	defb 0e7h		;e861
	defb 010h		;e862
	defb 080h		;e863
	defb 000h		;e864
	defb 007h		;e865
	defb 004h		;e866
	defb 03bh		;e867
	defb 0eah		;e868
	defb 0ffh		;e869
	defb 000h		;e86a
	defb 000h		;e86b
	defb 000h		;e86c
	defb 000h		;e86d
	defb 000h		;e86e
	defb 000h		;e86f
	defb 062h		;e870
	defb 0e7h		;e871
	defb 010h		;e872
	defb 050h		;e873
	defb 000h		;e874
	defb 007h		;e875
	defb 004h		;e876
	defb 03bh		;e877
	defb 0eah		;e878
	defb 0ffh		;e879
	defb 000h		;e87a
	defb 000h		;e87b
	defb 000h		;e87c
	defb 000h		;e87d
	defb 000h		;e87e
	defb 000h		;e87f
	defb 071h		;e880
	defb 0e7h		;e881
	defb 010h		;e882
	defb 050h		;e883
	defb 000h		;e884
	defb 003h		;e885
	defb 003h		;e886
	defb 031h		;e887
	defb 0eah		;e888
	defb 0ffh		;e889
	defb 000h		;e88a
	defb 000h		;e88b
	defb 000h		;e88c
	defb 000h		;e88d
	defb 000h		;e88e
	defb 000h		;e88f
	defb 080h		;e890
	defb 0e7h		;e891
	defb 008h		;e892
	defb 01ah		;e893
	defb 000h		;e894
	defb 000h		;e895
	defb 001h		;e896
	defb 008h		;e897
	defb 0eah		;e898
	defb 080h		;e899
	defb 000h		;e89a
	defb 000h		;e89b
	defb 000h		;e89c
	defb 000h		;e89d
	defb 000h		;e89e
	defb 000h		;e89f
	defb 08fh		;e8a0
	defb 0e7h		;e8a1
	defb 008h		;e8a2
	defb 068h		;e8a3
	defb 000h		;e8a4
	defb 001h		;e8a5
	defb 002h		;e8a6
	defb 03bh		;e8a7
	defb 0eah		;e8a8
	defb 0ffh		;e8a9
	defb 000h		;e8aa
	defb 000h		;e8ab
	defb 000h		;e8ac
	defb 000h		;e8ad
	defb 000h		;e8ae
	defb 000h		;e8af
	defb 09eh		;e8b0
	defb 0e7h		;e8b1
	defb 008h		;e8b2
	defb 028h		;e8b3
	defb 000h		;e8b4
	defb 003h		;e8b5
	defb 003h		;e8b6
	defb 055h		;e8b7
	defb 0eah		;e8b8
	defb 0ffh		;e8b9
	defb 000h		;e8ba
	defb 000h		;e8bb
	defb 000h		;e8bc
	defb 000h		;e8bd
dphinit_end:
WKSP1:

; BLOCK 'wksp1' (start 0xe8be end 0xe91e)
wksp1_start:
	defb 000h		;e8be
	defb 000h		;e8bf
	defb 000h		;e8c0
	defb 000h		;e8c1
	defb 000h		;e8c2
	defb 000h		;e8c3
	defb 000h		;e8c4
	defb 000h		;e8c5
	defb 000h		;e8c6
	defb 000h		;e8c7
	defb 000h		;e8c8
	defb 000h		;e8c9
	defb 000h		;e8ca
	defb 000h		;e8cb
	defb 000h		;e8cc
	defb 000h		;e8cd
	defb 000h		;e8ce
	defb 000h		;e8cf
	defb 000h		;e8d0
	defb 000h		;e8d1
	defb 000h		;e8d2
	defb 000h		;e8d3
	defb 000h		;e8d4
	defb 000h		;e8d5
	defb 000h		;e8d6
	defb 000h		;e8d7
	defb 000h		;e8d8
	defb 000h		;e8d9
	defb 000h		;e8da
	defb 000h		;e8db
	defb 000h		;e8dc
	defb 000h		;e8dd
	defb 000h		;e8de
	defb 000h		;e8df
	defb 000h		;e8e0
	defb 000h		;e8e1
	defb 000h		;e8e2
	defb 000h		;e8e3
	defb 000h		;e8e4
	defb 000h		;e8e5
	defb 000h		;e8e6
	defb 000h		;e8e7
	defb 000h		;e8e8
	defb 000h		;e8e9
	defb 000h		;e8ea
	defb 000h		;e8eb
	defb 000h		;e8ec
	defb 000h		;e8ed
	defb 000h		;e8ee
	defb 000h		;e8ef
	defb 000h		;e8f0
	defb 000h		;e8f1
	defb 000h		;e8f2
	defb 000h		;e8f3
	defb 000h		;e8f4
	defb 000h		;e8f5
	defb 000h		;e8f6
	defb 000h		;e8f7
	defb 000h		;e8f8
	defb 000h		;e8f9
	defb 000h		;e8fa
	defb 000h		;e8fb
	defb 000h		;e8fc
	defb 000h		;e8fd
	defb 000h		;e8fe
	defb 000h		;e8ff
	defb 000h		;e900
	defb 000h		;e901
	defb 000h		;e902
	defb 000h		;e903
	defb 000h		;e904
	defb 000h		;e905
	defb 000h		;e906
	defb 000h		;e907
	defb 000h		;e908
	defb 000h		;e909
	defb 000h		;e90a
	defb 000h		;e90b
	defb 000h		;e90c
	defb 000h		;e90d
	defb 000h		;e90e
	defb 000h		;e90f
	defb 000h		;e910
	defb 000h		;e911
	defb 000h		;e912
	defb 000h		;e913
	defb 000h		;e914
	defb 000h		;e915
	defb 000h		;e916
	defb 000h		;e917
	defb 000h		;e918
	defb 000h		;e919
	defb 000h		;e91a
	defb 000h		;e91b
	defb 000h		;e91c
	defb 000h		;e91d
wksp1_end:
DSKCFG:

; BLOCK 'dskcfg' (start 0xe91e end 0xe97f)
dskcfg_start:
	defb 000h		;e91e
	defb 000h		;e91f
	defb 007h		;e920
	defb 0e8h		;e921
	defb 020h		;e922
	defb 010h		;e923
	defb 000h		;e924
	defb 001h		;e925
	defb 002h		;e926
	defb 000h		;e927
	defb 000h		;e928
	defb 000h		;e929
	defb 000h		;e92a
	defb 000h		;e92b
	defb 000h		;e92c
	defb 000h		;e92d
	defb 000h		;e92e
	defb 000h		;e92f
	defb 020h		;e930
le931h:
	defb 07fh		;e931
	defb 000h		;e932
	defb 000h		;e933
	defb 000h		;e934
	defb 010h		;e935
	defb 007h		;e936
	defb 028h		;e937
	defb 020h		;e938
	defb 0ffh		;e939
	defb 000h		;e93a
	defb 040h		;e93b
	defb 001h		;e93c
	defb 010h		;e93d
	defb 00eh		;e93e
	defb 028h		;e93f
	defb 012h		;e940
	defb 0ffh		;e941
	defb 001h		;e942
	defb 040h		;e943
	defb 002h		;e944
	defb 009h		;e945
	defb 01bh		;e946
	defb 028h		;e947
	defb 01eh		;e948
	defb 0ffh		;e949
	defb 001h		;e94a
	defb 040h		;e94b
	defb 002h		;e94c
	defb 00fh		;e94d
	defb 01bh		;e94e
	defb 04dh		;e94f
	defb 010h		;e950
	defb 0ffh		;e951
	defb 003h		;e952
	defb 040h		;e953
	defb 003h		;e954
	defb 008h		;e955
	defb 035h		;e956
	defb 04dh		;e957
	defb 00ah		;e958
	defb 0ffh		;e959
	defb 003h		;e95a
	defb 040h		;e95b
	defb 003h		;e95c
	defb 005h		;e95d
	defb 035h		;e95e
	defb 028h		;e95f
	defb 014h		;e960
	defb 0ffh		;e961
	defb 001h		;e962
	defb 040h		;e963
	defb 002h		;e964
	defb 00ah		;e965
	defb 00ah		;e966
	defb 050h		;e967
	defb 01ah		;e968
	defb 07fh		;e969
	defb 000h		;e96a
	defb 000h		;e96b
	defb 000h		;e96c
	defb 01ah		;e96d
	defb 007h		;e96e
	defb 04dh		;e96f
	defb 034h		;e970
	defb 0ffh		;e971
	defb 000h		;e972
	defb 040h		;e973
	defb 001h		;e974
	defb 01ah		;e975
	defb 00eh		;e976
	defb 04dh		;e977
	defb 00ah		;e978
	defb 0ffh		;e979
	defb 001h		;e97a
	defb 040h		;e97b
	defb 002h		;e97c
	defb 00ah		;e97d
	defb 018h		;e97e
dskcfg_end:
WKSP2:

; BLOCK 'wksp2' (start 0xe97f end 0xe9ae)
wksp2_start:
	defb 028h		;e97f
	defb 000h		;e980
	defb 000h		;e981
	defb 000h		;e982
	defb 000h		;e983
	defb 000h		;e984
	defb 000h		;e985
	defb 000h		;e986
	defb 000h		;e987
	defb 000h		;e988
	defb 000h		;e989
	defb 000h		;e98a
	defb 000h		;e98b
	defb 000h		;e98c
	defb 000h		;e98d
	defb 000h		;e98e
	defb 000h		;e98f
	defb 000h		;e990
	defb 000h		;e991
	defb 000h		;e992
	defb 000h		;e993
	defb 000h		;e994
	defb 000h		;e995
	defb 000h		;e996
	defb 000h		;e997
	defb 000h		;e998
	defb 000h		;e999
	defb 000h		;e99a
	defb 000h		;e99b
	defb 000h		;e99c
	defb 000h		;e99d
	defb 000h		;e99e
	defb 000h		;e99f
	defb 000h		;e9a0
	defb 000h		;e9a1
	defb 000h		;e9a2
	defb 000h		;e9a3
	defb 000h		;e9a4
	defb 000h		;e9a5
	defb 000h		;e9a6
	defb 000h		;e9a7
	defb 000h		;e9a8
	defb 000h		;e9a9
	defb 000h		;e9aa
	defb 000h		;e9ab
	defb 000h		;e9ac
	defb 000h		;e9ad
wksp2_end:
DPHDATA:

; BLOCK 'dphdata' (start 0xe9ae end 0xea08)
dphdata_start:
	defb 000h		;e9ae
	defb 000h		;e9af
	defb 010h		;e9b0
	defb 000h		;e9b1
	defb 001h		;e9b2
	defb 000h		;e9b3
	defb 000h		;e9b4
	defb 000h		;e9b5
	defb 000h		;e9b6
	defb 000h		;e9b7
le9b8h:
	defb 000h		;e9b8
	defb 000h		;e9b9
	defb 000h		;e9ba
	defb 000h		;e9bb
	defb 000h		;e9bc
	defb 000h		;e9bd
	defb 000h		;e9be
	defb 000h		;e9bf
	defb 081h		;e9c0
	defb 0f0h		;e9c1
	defb 035h		;e9c2
	defb 0e7h		;e9c3
	defb 04eh		;e9c4
	defb 0f1h		;e9c5
	defb 001h		;e9c6
	defb 0f1h		;e9c7
	defb 000h		;e9c8
	defb 000h		;e9c9
	defb 000h		;e9ca
	defb 000h		;e9cb
	defb 000h		;e9cc
	defb 000h		;e9cd
	defb 000h		;e9ce
	defb 000h		;e9cf
	defb 081h		;e9d0
	defb 0f0h		;e9d1
	defb 035h		;e9d2
	defb 0e7h		;e9d3
	defb 01bh		;e9d4
	defb 0f2h		;e9d5
	defb 0ceh		;e9d6
	defb 0f1h		;e9d7
	defb 000h		;e9d8
	defb 000h		;e9d9
	defb 000h		;e9da
	defb 000h		;e9db
	defb 000h		;e9dc
	defb 000h		;e9dd
	defb 000h		;e9de
	defb 000h		;e9df
	defb 081h		;e9e0
	defb 0f0h		;e9e1
	defb 044h		;e9e2
	defb 0e7h		;e9e3
	defb 0e8h		;e9e4
	defb 0f2h		;e9e5
	defb 09bh		;e9e6
	defb 0f2h		;e9e7
	defb 000h		;e9e8
	defb 000h		;e9e9
	defb 000h		;e9ea
	defb 000h		;e9eb
	defb 000h		;e9ec
	defb 000h		;e9ed
	defb 000h		;e9ee
	defb 000h		;e9ef
	defb 081h		;e9f0
	defb 0f0h		;e9f1
	defb 035h		;e9f2
	defb 0e7h		;e9f3
	defb 0b5h		;e9f4
	defb 0f3h		;e9f5
	defb 068h		;e9f6
	defb 0f3h		;e9f7
	defb 000h		;e9f8
	defb 000h		;e9f9
	defb 000h		;e9fa
	defb 000h		;e9fb
	defb 000h		;e9fc
	defb 000h		;e9fd
	defb 000h		;e9fe
	defb 000h		;e9ff
	defb 081h		;ea00
	defb 0f0h		;ea01
	defb 08fh		;ea02
	defb 0e7h		;ea03
	defb 000h		;ea04
	defb 000h		;ea05
	defb 035h		;ea06
	defb 0f4h		;ea07
dphdata_end:
SKEW_MAXI26:

; BLOCK 'skew_maxi26' (start 0xea08 end 0xea22)
skew_maxi26_start:
	defb 001h		;ea08
	defb 007h		;ea09
	defb 00dh		;ea0a
	defb 013h		;ea0b
	defb 019h		;ea0c
	defb 005h		;ea0d
	defb 00bh		;ea0e
	defb 011h		;ea0f
	defb 017h		;ea10
	defb 003h		;ea11
	defb 009h		;ea12
	defb 00fh		;ea13
	defb 015h		;ea14
	defb 002h		;ea15
	defb 008h		;ea16
	defb 00eh		;ea17
	defb 014h		;ea18
	defb 01ah		;ea19
	defb 006h		;ea1a
	defb 00ch		;ea1b
	defb 012h		;ea1c
	defb 018h		;ea1d
	defb 004h		;ea1e
	defb 00ah		;ea1f
	defb 010h		;ea20
	defb 016h		;ea21
skew_maxi26_end:
SKEW_MAXI15:

; BLOCK 'skew_maxi15' (start 0xea22 end 0xea31)
skew_maxi15_start:
	defb 001h		;ea22
	defb 005h		;ea23
	defb 009h		;ea24
	defb 00dh		;ea25
	defb 002h		;ea26
	defb 006h		;ea27
	defb 00ah		;ea28
	defb 00eh		;ea29
	defb 003h		;ea2a
	defb 007h		;ea2b
	defb 00bh		;ea2c
	defb 00fh		;ea2d
	defb 004h		;ea2e
	defb 008h		;ea2f
	defb 00ch		;ea30
skew_maxi15_end:
SKEW_QD10A:

; BLOCK 'skew_qd10a' (start 0xea31 end 0xea3b)
skew_qd10a_start:
	defb 001h		;ea31
	defb 003h		;ea32
	defb 005h		;ea33
	defb 007h		;ea34
	defb 009h		;ea35
	defb 002h		;ea36
	defb 004h		;ea37
	defb 006h		;ea38
	defb 008h		;ea39
	defb 00ah		;ea3a
skew_qd10a_end:
SKEW_SEQ26:

; BLOCK 'skew_seq26' (start 0xea3b end 0xea55)
skew_seq26_start:
	defb 001h		;ea3b
	defb 002h		;ea3c
	defb 003h		;ea3d
	defb 004h		;ea3e
	defb 005h		;ea3f
	defb 006h		;ea40
	defb 007h		;ea41
	defb 008h		;ea42
	defb 009h		;ea43
	defb 00ah		;ea44
	defb 00bh		;ea45
	defb 00ch		;ea46
	defb 00dh		;ea47
	defb 00eh		;ea48
	defb 00fh		;ea49
	defb 010h		;ea4a
	defb 011h		;ea4b
	defb 012h		;ea4c
	defb 013h		;ea4d
	defb 014h		;ea4e
	defb 015h		;ea4f
	defb 016h		;ea50
	defb 017h		;ea51
	defb 018h		;ea52
	defb 019h		;ea53
	defb 01ah		;ea54
skew_seq26_end:
SKEW_QD10B:

; BLOCK 'skew_qd10b' (start 0xea55 end 0xea5f)
skew_qd10b_start:
	defb 001h		;ea55
	defb 004h		;ea56
	defb 007h		;ea57
	defb 00ah		;ea58
	defb 003h		;ea59
	defb 006h		;ea5a
	defb 009h		;ea5b
	defb 002h		;ea5c
	defb 005h		;ea5d
	defb 008h		;ea5e
skew_qd10b_end:
ISR_DEFAULT:

; BLOCK 'code030' (start 0xea5f end 0xea62)
code030_start:
	ei			;ea5f
	reti			;ea60
code030_end:
WKSP3:

; BLOCK 'wksp3' (start 0xea62 end 0xebfc)
wksp3_start:
	defb 000h		;ea62
	defb 000h		;ea63
	defb 000h		;ea64
	defb 000h		;ea65
	defb 000h		;ea66
	defb 000h		;ea67
	defb 000h		;ea68
	defb 000h		;ea69
	defb 000h		;ea6a
	defb 000h		;ea6b
	defb 000h		;ea6c
	defb 000h		;ea6d
	defb 000h		;ea6e
	defb 000h		;ea6f
	defb 000h		;ea70
	defb 000h		;ea71
	defb 000h		;ea72
	defb 000h		;ea73
	defb 000h		;ea74
	defb 000h		;ea75
	defb 000h		;ea76
	defb 000h		;ea77
	defb 000h		;ea78
	defb 000h		;ea79
	defb 000h		;ea7a
	defb 000h		;ea7b
	defb 000h		;ea7c
	defb 000h		;ea7d
	defb 000h		;ea7e
	defb 000h		;ea7f
	defb 000h		;ea80
	defb 000h		;ea81
	defb 000h		;ea82
	defb 000h		;ea83
	defb 000h		;ea84
	defb 000h		;ea85
	defb 000h		;ea86
	defb 000h		;ea87
	defb 000h		;ea88
	defb 000h		;ea89
	defb 000h		;ea8a
	defb 000h		;ea8b
	defb 000h		;ea8c
	defb 000h		;ea8d
	defb 000h		;ea8e
	defb 000h		;ea8f
	defb 000h		;ea90
	defb 000h		;ea91
	defb 000h		;ea92
	defb 000h		;ea93
	defb 000h		;ea94
	defb 000h		;ea95
	defb 000h		;ea96
	defb 000h		;ea97
	defb 000h		;ea98
	defb 000h		;ea99
	defb 000h		;ea9a
	defb 000h		;ea9b
	defb 000h		;ea9c
	defb 000h		;ea9d
	defb 000h		;ea9e
	defb 000h		;ea9f
	defb 000h		;eaa0
	defb 000h		;eaa1
	defb 000h		;eaa2
	defb 000h		;eaa3
	defb 000h		;eaa4
	defb 000h		;eaa5
	defb 000h		;eaa6
	defb 000h		;eaa7
	defb 000h		;eaa8
	defb 000h		;eaa9
	defb 000h		;eaaa
	defb 000h		;eaab
	defb 000h		;eaac
	defb 000h		;eaad
	defb 000h		;eaae
	defb 000h		;eaaf
	defb 000h		;eab0
	defb 000h		;eab1
	defb 000h		;eab2
	defb 000h		;eab3
	defb 000h		;eab4
	defb 000h		;eab5
	defb 000h		;eab6
	defb 000h		;eab7
	defb 000h		;eab8
	defb 000h		;eab9
	defb 000h		;eaba
	defb 000h		;eabb
	defb 000h		;eabc
	defb 000h		;eabd
	defb 000h		;eabe
	defb 000h		;eabf
	defb 000h		;eac0
	defb 000h		;eac1
	defb 000h		;eac2
	defb 000h		;eac3
	defb 000h		;eac4
	defb 000h		;eac5
	defb 000h		;eac6
	defb 000h		;eac7
	defb 000h		;eac8
	defb 000h		;eac9
	defb 000h		;eaca
	defb 000h		;eacb
	defb 000h		;eacc
	defb 000h		;eacd
	defb 000h		;eace
	defb 000h		;eacf
	defb 000h		;ead0
	defb 000h		;ead1
	defb 000h		;ead2
	defb 000h		;ead3
	defb 000h		;ead4
	defb 000h		;ead5
	defb 000h		;ead6
	defb 000h		;ead7
	defb 000h		;ead8
	defb 000h		;ead9
	defb 000h		;eada
	defb 000h		;eadb
	defb 000h		;eadc
	defb 000h		;eadd
	defb 000h		;eade
	defb 000h		;eadf
	defb 000h		;eae0
	defb 000h		;eae1
	defb 000h		;eae2
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
wksp3_end:
INTVEC:

; BLOCK 'intvec' (start 0xebfc end 0xec1c)
intvec_start:
	defw 00000h		;ebfc
	defw 00000h		;ebfe
	defw 0ea5fh		;ec00
	defw 0ea5fh		;ec02
	defw 0e0d6h		;ec04
	defw 0e6b4h		;ec06
	defw 0ea5fh		;ec08
	defw 0ea5fh		;ec0a
	defw 0ea5fh		;ec0c
	defw 0ea5fh		;ec0e
	defw 0dcf5h		;ec10
	defw 0dd0eh		;ec12
	defw 0dd27h		;ec14
	defw 0dd41h		;ec16
	defw 0dd66h		;ec18
	defw 0dd7fh		;ec1a
intvec_end:
IVTDATA:

; BLOCK 'ivtdata' (start 0xec1c end 0xec28)
ivtdata_start:
	defb 098h		;ec1c
	defb 0ddh		;ec1d
	defb 0b2h		;ec1e
	defb 0ddh		;ec1f
	defb 042h		;ec20
	defb 0ech		;ec21
	defb 064h		;ec22
	defb 0ech		;ec23
	defb 000h		;ec24
lec25h:
	defb 0ech		;ec25
lec26h:
	defb 000h		;ec26
lec27h:
	defb 000h		;ec27
ivtdata_end:
CONST:

; BLOCK 'code034' (start 0xec28 end 0xec78)
code034_start:
	ld a,(lec26h)		;ec28
	ret			;ec2b
CONIN:
	ld a,(lec26h)		;ec2c
	or a			;ec2f
	jr z,CONIN		;ec30
	di			;ec32
	xor a			;ec33
	ld (lec26h),a		;ec34
	ei			;ec37
	in a,(010h)		;ec38
	ld c,a			;ec3a
	ld hl,CONVTAB2		;ec3b
	call DSPY_XLAT		;ec3e
	ret			;ec41
	ld (0f4b2h),sp		;ec42
	ld sp,0f526h		;ec46
	push af			;ec49
	ld a,0ffh		;ec4a
	ld (lec26h),a		;ec4c
	push hl			;ec4f
	call CONOUT_CLOCK	;ec50
	pop hl			;ec53
	jr nz,lec5ch		;ec54
	ld a,(0f4d6h)		;ec56
	ld (SCREENBUF),a	;ec59
lec5ch:
	pop af			;ec5c
	ld sp,(0f4b2h)		;ec5d
	ei			;ec61
	reti			;ec62
	ld (0f4b2h),sp		;ec64
	ld sp,0f526h		;ec68
	push af			;ec6b
	ld a,0ffh		;ec6c
	ld (lec27h),a		;ec6e
	pop af			;ec71
	ld (0f4b2h),sp		;ec72
	ei			;ec76
	defb 0edh		;ec77
code034_end:
TRAILING:

; BLOCK 'trailing' (start 0xec78 end 0xec80)
trailing_start:
	defb 04dh		;ec78
	defb 082h		;ec79
	defb 084h		;ec7a
	defb 08bh		;ec7b
	defb 000h		;ec7c
	defb 000h		;ec7d
	defb 000h		;ec7e
	defb 000h		;ec7f
trailing_end:
