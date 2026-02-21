;FILEX program version 1.0  19 jan 83
;
boot	equ	0000h		; warmboot entry
bdos	equ	0005h		; bdos entry
				;
false	equ	0		;
true	equ	1		;
				;
reader	equ	3		; bdos functions 
punch	equ	4		;
print	equ	9		;
readco	equ	10		;
open	equ	15		;
close	equ	16		;
delete	equ	19		;
read	equ	20		;
write	equ	21		;
make	equ	22		;
setdma	equ	26		;
				;
ok	equ	0		; result values
nexist	equ	1		;
full	equ	2		;
eof	equ	3		;
transm	equ	4		;
				;
dc1	equ	11h		;
dc3	equ	13h		;
				;
				;
	org	0100h		;
				;
start:	lxi	sp,stack	;
	lxi	d,0080h		;
	lxi	h,conslen	; move program call parameters
	ldax	d		; to cons buffer
	mov	b,a		;
	mov	m,a		;
	inx	h		;
	inx	d		;
m1:	mov	a,b		;	
	ora	a		;
	jz	mm		;
	ldax	d		;
	mov	m,a		;
	inx	h		;
	inx	d		;
	dcr	b		;
	jmp	m1		;
mm:	lxi	d,0080h		;
	ldax	d		;
	cpi	0		;
	jnz	m2		;
	lxi	h,readcons	; readcons:=no parameters specified
	mvi	m,true		; after program name
m2:	lxi	d,sttext	; write('FILEX - ver x.x');
	mvi	c,print		;
	call	bdos		;
				;
act:	lxi	sp,stack	;
	call	getnextitem	; getnextitem;
	lxi	h,itemlen	;
	lxi	d,receive	;
 	call	comp		;
	jz	sleep		; if item='REMOTE' then goto sleep;
	lda	itemlen		;
	cpi	0		;
	jz	endprog		; if item='' then goto endprog;
	lxi	h,itemlen	;
	lxi	d,noend		;
	call	comp		;
	jz	boot		; if item='NOEND' then goto boot;
act2:	call	buildname	; name:=buildname(item) 
	lxi	d,unitnr	;
	lda	remote		;
	sta	lhandside	; lhandside:= (Rx: specified)
	cpi	true		;
	jz	act3		; if not Rx: specified then  
	xra	a		; begin
	sta	sfcbcr		;   sfcbrc:=0;
	lxi	h,sfcb		;   sfcbname:=name
	jmp	act4		; end
act3:	lxi	h,bufname	; else
act4:	call	movename	; begin
	call	getnextitem	;   buf.name:=name
	lxi	h,itemlen	; end;
	lxi	d,equal		; getnextitem;
	call	comp		; if item<>'=' then goto parameter-rror;
	jnz	parmerr		; getnextitem;
	call	getnextitem	; buildname(item);
	call	buildname	; if lhandside=(Rx: specified)
	lda	remote		;   then goto parameter-error;
	lxi	h,lhandside	; if Rx: specified then goto rtol;
	cmp	m		;
	jz	parmerr		;
	cpi	true		;
	jz	rtol		; sfcbname:=name;
	lxi	d,unitnr	; sfcbrc:=0;
	lxi	h,sfcb		;
	call	movename	;
	xra	a		;
	sta	sfcbcr		;
				;
				; LOCAL -> REMOTE
 ltor:	mvi	c,open		; open(source);
	lxi	d,sfcb		;
	call	bdos		;
	cpi	0ffh		; if open-error then abort
	jz	openerr		;
	lda	bufname+1	; if buf.name='' then
	cpi	' '		;
	jnz	ltor1		; begin
	lxi	d,name		;   buf.name:=name (except unitno)
	lxi	h,bufname+1	; end;
	call	moveonlyname	;
ltor1:	mvi	a,2		;
	sta	bufop		; buf.operation:=2; (*make*)
	lxi	h,antal		;
	mvi	m,19		;
	inx	h		;
	mvi	m,0		; antal:=19;
	call	outandin	; outline(buf,antal);
				; inline(buf,antal);
	lda	bufst		;
	cpi	transm		; if transmission error then abort
	jz	trxerr		;
	cpi	ok		; if make-error then abort
	jnz	makeerr		;
	mvi	c,setdma	;
	lxi	d,bufarea	;
	call	bdos		; setdma(buf.area);
	mvi	a,4		;
	sta	bufop		; buf.operation:=4; (* write *)
ltor2:	lxi	d,sfcb		; while not eof(source) do
				; begin
	mvi	c,read		;   read(source);
	call	bdos		;
	ora	a		;
	jnz	closefiles	;
	lxi	h,antal		;
	mvi	m,131		;   antal:=131;
	inx	h		;
	mvi	m,0		;
	call	outandin	;   outline(buf,antal);
				;   inline(buf,antal);
	lda	bufst		;
	cpi	transm		;   if transmission-error then abort
	jz	trxerr		; 
	cpi	ok		;   if write-error then abort
	jnz	writeerr	;
	jmp	ltor2		; end;
				;
				;
				; REMOTE -> LOCAL
rtol:	lxi	d,unitnr	; buf.name:=name
	lxi	h,bufname	;
	call	movename	;
	xra	a		;
	sta	sfcbcr		; sfcbcr:=0;
	lda	sfcb+1		; if destname='' then
	cpi	' '		; begin
	jnz	rtol1		;   sfcbname:=name;
	lxi	d,name		;
	lxi	h,sfcb+1	; 
	call	moveonlyname	; end;
rtol1:	mvi	a,1		;
	sta	bufop		; buf.operation:=1; (*open*)
	lxi	h,antal		;
	mvi	m,19		; antal:=19;
	inx	h		;
	mvi	m,0		;
	call	outandin	; outline(buf,antal);
				; inline(buf,antal);
	lda	bufst		;
	cpi	transm		; if transmission-error then abort
	jz	trxerr		;
	cpi	ok		; if open-error then abort
	jnz	openerr		;
	mvi	c,delete	; delete(destination);
	lxi	d,sfcb		;
	call	bdos		;
	mvi	c,make		; make(destination);
	lxi	d,sfcb		;
	call	bdos		;
	cpi	0ffh		; if make-error then abort
	jz	makeerr		;
	mvi	c,setdma	;
	lxi	d,bufarea	; setdma(buf.area);
	call	bdos		;
	mvi	a,3		; buf.operation:=3; (* read *)
	sta	bufop		;
rtol2:	lxi	h,antal		;
	mvi	m,3		;
	inx	h		;
	mvi	m,0		; antal:=0;
	call	outandin	; outline(buffer,antal);
				; inline(buffer,antal);
	lda	status		; 
	ora	a		; if receive_status=error or
	jnz	trxerr		;    buffer_status=transm_error
	lda	bufst		; then exit to transmission_error
	cmp	transm		; else
	jz	trxerr		; begin
	ora	a		;   if buffer_status<>0
	jnz	closefiles	;   then close files
	lxi	d,sfcb		; end;
	mvi	c,write		;
	call	bdos		;
	ora	a		; if write-error then abort
	jnz	writeerr	;
	jmp	rtol2		;
				;
closefiles:			;
	mvi	a,5		;
	sta	bufop		; buf.operation:=5 (* close *)
	lxi	h,antal		;
	mvi	m,3		; antal:=3;
	call	outandin	; outline(buf,antal);
				; inline(buf,antal);
	lda	bufst		;
	cpi	transm		; if transmission-error then abort
	jz	trxerr		;
	cpi	ok		;
	jnz	clsrerr		; if close-error on remote then abort
	mvi	c,close		;
	lxi	d,sfcb		;
	call	bdos		; close(source/destination);
	cpi	0ffh		;
	jz	clslerr		; if close-error on local then abort
	jmp	act		; goto start:
				;
endprog:			;
	mvi	a,6		;
	sta	bufop		; buf.operation:=6 (* end *)
	lxi	h,antal		;
	mvi	m,3		; antal:=3;
	call	outandin	; outline(buf,antal);
				; inline(buf,antal);
	jmp	boot		; warmboot;
				;end.
				;


 **********************************************************************
 *                                                                    *
 *      sleeping partner                                              *
 *                                                                    *
 **********************************************************************
				; sleep:
sleep:	lxi	d,oktext	; write('REMOTE OPERATION');
	mvi	c,print		;
	call	bdos		;
sleep1:	lxi	h,result	;
	mvi	m,ok		;
	call	inline		; repeat
	lda	status		;   inline(buffer,antal)
	cpi	ok		;   if ok then
	jnz	transerr	;   begin
	lda	bufop		;     case buf.operation of
	lxi	h,jmptable-3	;
	mov	b,a		;
	add	b		;
	add	b		;
	mov	c,a		;
	xra	a		;
	mov	b,a		;
	dad	b		;
	pchl			;
jmptable:			;
	jmp	openf		; 1: openfile(buf.name);
	jmp	makef		; 2: makefile(buf.name);
	jmp	readf		; 3: readfile;
	jmp	writef		; 4: writefile;
	jmp	closef		; 5: closefile;
	jmp	endf		; 6: endsession;
				;
				;
transerr:			;
	lxi	h,result	;
	mvi	m,transm	;
	jmp	senda3		;
openf:	lxi	d,bufname	;
	lxi	h,sfcb		;
	call	movename	;     1: begin (* open *)
	sub	a		;
	sta	sfcbcr		;
	mvi	c,open		;          movename;
	lxi	d,sfcb		;
	call	bdos		;          open(buf.name)
	inr	a		;
	jnz	open1		;
	lxi	h,result	;
	mvi	m,nexist	;
	jmp	senda3		;
open1:	mvi	c,setdma	;          setdma(buf.area)
	lxi	d,bufarea	;
	call	bdos		;
	jmp	senda3		;        end;
				;
makef:	lxi	d,bufname	;
	lxi	h,sfcb		;
	call	movename	;     2: begin (* make *)
	sub	a		;
	sta	sfcbcr		;
	mvi	c,delete	;          movename;
	lxi	d,sfcb		;
	call	bdos		;          delete(buf.name);
	mvi	c,make		;          make(buf.name);
	lxi	d,sfcb		;
	call	bdos		;
	inr	a		;
	jnz	make1		;
	lxi	h,result	;
	mvi	m,full		;
	jmp	senda3		;
make1:	mvi	c,setdma	;          setdma(buf.area);
	lxi	d,bufarea	;
	call	bdos		;
	jmp	senda3		;        end;
				;
readf:	lxi	d,sfcb		;     3: begin (* read *)
	mvi	c,read		;          read;
	call	bdos		;
	ora	a		;
	jz	senda131	;
	lxi	h,result	;
	mvi	m,eof		;
	jmp	senda3		;        end;
				;
writef:	lxi	d,sfcb		;     4: begin (* write *)
	mvi	c,write		;          write;
	call	bdos		;
	ora	a		;
	jz	senda3		;
	lxi	h,result	;
	mvi	m,full		;
	jmp	senda3		;        end;
				;
closef:	lxi	d,sfcb		;     5: begin (* close *)
	mvi	c,close		;          close;
	call	bdos		;
	inr	a		;
	jnz	senda3		;
	lxi	h,result	;
	mvi	m,full		;
	jmp	senda3		;        end;
				;
endf:				;     6: begin (* end *)
				;
				;        end;
				;     end;
				;
senda3:	lxi	h,antal		;
	mvi	m,3		;
	jmp	senda		;
				;
senda131:			;
	lxi	h,antal		;
	mvi	m,131		;
				;
senda:	inx	h		;
	mvi	m,0		;
	lda	result		;
	sta	bufst		;
	call	outline		;     outline(buffer,antal);
	lda	bufop		;
	cpi	6		;   until bufop=6;
	jnz	sleep1		;
				;
	jmp	boot		;
				;
				;
openerr:			;
	lxi	d,mopen	;
	jmp	printerr	;
				;
makeerr:			;
	lxi	d,mmake	;
	jmp	printerr	;
				;
writeerr:			;
	lxi	d,mwrite	;
	jmp	printerr	;
				;
clsrerr:			;
	lxi	d,mremclose	;
	jmp	printerr	;
				;
clslerr:			;
	lxi	d,mlocclose	;
	jmp	printerr	;
				;
trxerr:				;
	lxi	d,mtxmerr	;
	jmp	printerr	;
				;
parmerr:			;
	lxi	d,mparmerr	;
	jmp	printerr	;
				;
				;
printerr:			;
	mvi	c,print		;
	call	bdos		; write error message to console
	lda	readcons	; if read-from-console=false
	cpi	false		;  then goto cpm
	jz	boot		;  else 
	xra	a		;   begin
	sta	conslen		;     len(cons):=0   
	jmp	act		;   end;  
				; goto start;
				;
				;
getnextitem:			; procedure getnextitem
	lxi	h,conspil	; begin
	mvi	b,0		;   while conspil<=len(cons) and
	mov	c,m		;         cons(conspil)=' ' do 
	lxi	h,cons		;   begin
	dcx	h		;
	dad	b		;     conspil:=conspil+1;          
getn2:	lda	conslen		;   end;
	cmp	c		;
	jm	getn3		;
	mov	a,m		;
	cpi	' '		;
	jnz	getn5		;
	inr	c		;
	inx	h		;
	jmp	getn2		;
getn3:	lda	readcons	;   if conspil>len(cons) then  
	cpi	0		;   begin
	jz	getn10		;     if readcons then
	lxi	d,star		;     begin
	mvi	c,print		;       write('* ');
	call	bdos		;       readln(cons);
	lxi	d,consmax	;
	mvi	c,readco	;
	call	bdos		;
	lxi	d,crnl		;       writeln;
	mvi	c,print		;
	call	bdos		;
	lda	conslen		;       
	mov	c,a		;       for i=1 to len(cons) do
	mvi	b,32		;       begin
	lxi	h,cons		;         if cons[i]>='a' then    
getnn:	mov	a,m		;           cons[i]:=cons[i]-('a'-'A');
	cpi	'a'		;              (* convert lower case
	jm	getn		;                      to upper case *)
	sub	b		;       end;
	mov	m,a		;
getn:	inx	h		;
	dcr	c		;
	jnz	getnn		;
	mvi	b,0		;
	mvi	c,1		;       pil := 1;
	lxi	h,cons		;
	dad	b		;
	dcx	h		;
getn4:	lda	conslen		;
	cmp	c		;       while conspil<=len(cons) and
	jm	getn10		;             cons(conspil)=' '  do 
	mov	a,m		;       begin
	cpi	' '		;         conspil:=conspil+1;
	jnz	getn5		;       end;
	inr	c		;
	inx	h		;
	jmp	getn4		;     end
getn10:	lxi	h,itemlen	;     else
	mvi	m,0		;     begin
	ret			;       itemlen:=0;
				;       return;
				;     end;
getn5:	lxi	d,item		;
	mvi	b,1		; i := 1;
	mov	a,m		;
	cpi	'='		; if cons[pil]='=' then
	jnz	getn6		; begin
	stax	d		;   item[1]:='=';
	lxi	h,itemlen	;
	mvi	m,1		;   itemlen:=1;
	inr	c		;
	lxi	h,conspil	;   pil:=pil+1;
	mov	m,c		;   return;
	ret			; end;
getn6:	lda	conslen		; while pil<=len(cons) and
	cmp	c		;       cons(pil)<>' ' and
	jm	getn7		;       cons(pil)<>'=' do
	mov	a,m		; begin
	cpi	' '		;    
	jz	getn7		; 
	cpi	'='		; 
	jz	getn7		; 
	push	b		;    
	push	h		;  
	lxi	h,badchar	;   if pos('<>,;?*[]',cons[pil])<>0 
	mvi	b,m		;   
getchk:	inx	h		;          (* check for illegal characters *)
	cmp	m		;
	jz	parmerr		;     then exit to parameter-error
	dcr	b		;
	jnz	getchk		;     else
	pop	h		;     begin
	pop	b		;       name[i]:=cons[pil];
	stax	d		;       i:=i+1;
	inr	b		;       pil:=pil+1;
	inr	c		;     end;
	inx	d		;
	inx	h		; end;
	jmp	getn6		; 
getn7:	lxi	d,itemlen	; itemlen:=i-1;
	mov	a,b		;
	dcr	a		;
	stax	d		;
	lxi	h,conspil	;
	mov	m,c		;
	ret			;end;
				;
buildname:			; procedure buildname;
	lxi	h,fejl		; begin
	mvi	m,false 	;  fejl:=false;
	lxi	h,remote	;
	mvi	m,false		;  remote:=false;
	mvi	b,11		;
	lxi	h,name		;
build1:	mvi	m,' '		;  name:= '        ';
	inx	h		;  name2:='   ';
	dcr	b		;
	jnz	build1		;
	lxi	h,item+1	; 
	mov	a,m		;
	cpi	':'		; if item[2]=':' then
	jnz	build2		;   begin
	dcx	h		;
	mov	a,m		;
	mvi	c,'A'-1		;
	sub	c		;
	lxi	h,unitnr	;
	mov	m,a		;     unitnr:=ord(item[1])-(ord('A')-1);
	lxi	h,item+2	;     pos := 3;
	mvi	c,3		;
	jmp	build4		;   end;
build2:	inx	h		; else
	mov	a,m		;   begin
	cpi	':'		;     if item[3]=':' and
	jnz	build3		; 
	lxi	h,item		;
	mov	a,m		;
	cpi	'R'		;        item[1]='R' then
	jnz	build3		;
	lxi	h,remote	;          begin
	mvi	m,true		;
	lxi	h,item+1	;            remote:=true;
	mov	a,m		;
	mvi	c,'A'-1		;
	sub	c		;
	lxi	h,unitnr	;
	mov	m,a		;            unitnr:=ord(item[2])-(ord('A')-1);
	lxi	h,item+3	;
	mvi	c,4		;          end; 
	jmp	build4		;     else
build3:	lxi	h,unitnr	;       begin
	mvi	m,0		;       (* no disk specified *)
	lxi	h,item		;       end;
	mvi	c,1		;   end;
build4:	mvi	b,1		; pil :=1;
	lxi	d,name		;
build5:	lda	itemlen		; while pos<=itemlen and
	cmp	c		;       pil<=8       and
	rm			;       item[pos]<>'.'    do
	mvi	a,8		;   begin
	cmp	b		;     name[pil]:=item[pos];
	jm	build6		;     pil:=pil+1;
	mov	a,m		;     pos:=pos+1;
	cpi	'.'		;   end;
	jz	build7		;
	mov	a,m		;
	stax	d		;
	inr	b		;
	inr	c		;
	inx	d		;
	inx	h		;
	jmp	build5		;
build6:	lda	itemlen		; while pos<=itemlen and
	cmp	c		;       item[pos]<>'.'    do
	rm			;   begin	
	mov	a,m		;     pos:=pos+1;
	cpi	'.'		;   end;
	jz	build7		;
	inr	c		;
	inx	h		;
	jmp	build6		;
build7:	inr	c		; while pos<=itemlen and
	inx	h		;       pil<=3            do
	mvi	b,1		;
	lxi	d,name2		;  begin
build8:	lda	itemlen		;    name2[pil]:=item[pos];
	cmp	c		;    pil:=pil+1;
	rm			;    pos:=pos+1;
	mvi	a,3		;  end;
	cmp	b		;
	rm			;
	mov	a,m		;
	cpi	'.'		;
	jz	parmerr		;
	stax	d		;
	inr	b		;
	inr	c		;
	inx	d		;
	inx	h		;
	jmp	build8		;
				;	
				;
movename:			; procedure movename;
	mvi	c,16		; begin
move1:	ldax	d		;
	mov	m,a		;
	inx	d		;
	inx	h		;
	dcr	c		;
	jnz	move1		;
	ret			; end;
				;
moveonlyname:			; procedure moveonlyname;
	mvi	c,15		; begin
	jmp	move1		; end;
				;
comp:	ldax	d		; function compare:boolean;
	cmp	m		; begin
	rnz			;   if len(s1)<>len(s2) then return;
	mov	b,a		;
cmp1:	inx	d		;   for i:=1 to len(s1) do
	inx	h		;   begin
	ldax	d		;     if s1[i]<>s2[i] then return;
	cmp	m		;
	rnz			;   end;
	dcr	b		;
	jnz	cmp1		;
	ret			;  return;
				;end;
				;
				;
				;
outandin:			;procedure outandin;
	call	outline		;begin
	call	inline		;  outline(buf,antal);
	ret			;  inline(buf,antal);
				;end;
				;
				;
inline:				;procedure inline(buf,antal);
				;begin
inl1:	call	rec		; repeat
	cpi	35		;   rec(ch);
	jnz	inl1		; until ord(ch)<>35;
	lxi	h,antal		;
	inx	h		;
	call	rdata		; rdata(right);
	dcx	h		;
	call	rdata		; rdata(left);
	lhld	antal		; antal:=left shift 8 + right;
	mov	b,h		;
	mov	c,l		;
	lxi	h,buffer	;
inl2:				; i:=0;
	mov	a,b		; while antal>0 do
	ora	c		; begin
	jz	inl3		;
	call	rdata		;   rdata(buf.area(i));
	inx	h		;   i:=i+1;
	dcx	b		;   antal:=antal-1;
	jmp	inl2		; end;
inl3:	lxi	h,checksum	; rdata(checksum);
	call	rdata		;
	call	rec		; if rec(ch)=13 then
	cpi	13		;   
	jnz	inl6		;   begin
	mvi	a,0		;
	lhld	antal		;     calc_check:=0;
	mov	b,h		;     i:=0;
	mov	c,l		;
	lxi	h,buffer	;
inl4:	mov	d,a		;     while antal>0 do
	mov	a,b		;     begin
	ora	c		;
	mov	a,d		;
	jz	inl5		;
	add	m		;       calc_check:=calc_check+buf.area(i)
	inx	h		;       i:=i+1;
	dcx	b		;       antal:=antal-1;
	jmp	inl4		;     end;
inl5:	lxi	h,checksum	;     if calck_check+checksum=0 then
	add	m		;       status:=ok
	jnz	inl6		;     else
	sub	a		;       status:=error;
	sta	status		;   end; 
	ret			; else
inl6:	mvi	a,1fh		;   status:=error;
	sta	status		;
	ret			; end;
				;
rdata:	push	h		; procedure rdata(ch);
	push	b		;
	call	rec		; begin
	ani	0fh		;   rec(ch1);
	rlc			;   ch1:=(ch1 and 1111B) shift 4;
	rlc			;
	rlc			;
	rlc			;
	mov	e,a		;
	push	d		;
	call	rec		;   rec(ch2);
	pop	d		;
	ani	0fh		;   ch2:=ch2 and 1111B;
	ora	e		;   ch:=ch1+ch2;
	pop	b		;
	pop	h		;
	mov	m,a		;
	ret			; end;
				;
rec:	mvi	c,reader	; procedure rec(ch);
				; begin
	call	bdos		;   goto readerinput(ch);
	ani	7fh		; end;
	ret			;
				;
				; procedure outline(buf,antal)
outline:			; begin
	mvi	a,35		; write(chr(35));
	call	xmt		;
	lxi	h,antal+1	;
	call	xdata		; xdata(antal div 256);
	dcx	h		;
	call	xdata		; xdata(antal mod 256);
	lhld	antal		;
	mov	b,h		;
	mov	c,l		;
	lxi	h,buffer	; i:=0;
outl1:	mov	a,b		; while antal>0 do
	ora	c		; begin
	jz	outl2		;
	call	xdata		;   xdata(buffer(i));
	inx	h		;   i:=i+1;
	dcx	b		;   antal:=antal-1;
	jmp	outl1		; end;
outl2:	sub	a		; checksum:=0;
	lhld	antal		;
	mov	b,h		;
	mov	c,l		;
	lxi	h,buffer	; i:=0;
outl3:	mov	d,a		; while antal>0 do
	mov	a,b		; begin
	ora	c		;
	mov	a,d		;
	jz	outl4		;
	add	m		;   checksum:=checksum+buffer(i);
	inx	h		;   i:=i+1;
	dcx	b		;   antal:=antal-1;
	jmp	outl3		; end;
outl4:	mov	d,a		;
	sub	a		;
	sub	d		; checksum:=0-checksum;
	sta	checksum	;
	lxi	h,checksum	;
	call	xdata		;
	mvi	a,13		; xmt(13);
	call	xmt		;
	mvi	a,10		; xmt(10);
	call	xmt		;
	ret			; end;
				;
xdata:	mov	a,m		; procedure xdata(i:integer);
	rrc			; begin
	rrc			;   xmt((i div 256)+32);
	rrc			;
	rrc			;
	ani	0fh		;
	ori	40h		;
	call	xmt		;
	mov	a,m		;
	ani	0fh		;
	ori	40h		;
	call	xmt		;  xmt((i mod 256)+32);
	ret			; end;
				;
xmt:	push	psw		;
	push	b		;
	push	d		;
	push	h		;
	mov	e,a		; procedure xmt(c:char);
	push	d		;
xmt1:	lhld	0001		; begin
	mvi	c,4ah		;   while buffer(reader)<>empty do
	mvi	b,0		;   begin
	dad	b		;     
	call	phl		;     read(reader,ch);
	ora	a		;    
	jz	xmt3		;
	mvi	c,reader	;
	call	bdos		;
	cpi	dc3		;
	jnz	xmt1		;     if ch=dc3 then
				;     begin
xmt2:	mvi	c,reader	;       repeat
	call	bdos		;         read(reader,ch);
	cpi	dc1		;
	jnz	xmt2		;       until ch=dc1;
	jmp	xmt1		;     end;
				;   end;
xmt3:	pop	d		;
 	mvi	c,punch		;   write(punch,c);
	call	bdos		;
	pop	h		;
	pop	d		;
	pop	b		;
	pop	psw		;
	ret			;
				;
phl:	pchl			;
				; end;
				;
receive:			;
	db 	6,'REMOTE'	;
noend:
	db	5,'NOEND'	;
equal:
	db	1,'='		;

badchar:
	db	8,'<>,;?*[]'	;


star:	db	'* $'		;

oktext:	db	'Remote operation'		;
	db	13,10,'$'

sttext:	db	'FILEX   vers. 1.0  83.01.19'	;

crnl:	db	13,10,'$'			;
				;
mopen:
	db	'Cannot open source file'
	db	13,10,'$'

mmake:
	db	'Directory full on destination disk'
	db	13,10,'$'

mwrite:	
	db	'No space on destination disk'
	db	13,10,'$'

mremclose:
	db	'Cannot close file on remote disk'
	db	13,10,'$'

mlocclose:
	db	'Cannot close file on local disk'
	db	13,10,'$'

mtxmerr:
	db	'Transmission error'
	db	13,10,'$'

mparmerr:
	db	'*** Parameter error ***'
	db	13,10,'$'


	ds	32		;
stack:				;
fejl:	db	false		;
status:	db	0		;
result:	db	ok		;
lhandside:			;
	db	false		;
checksum:			;
	db	0		;
				;
buffer:	ds	131		;
bufop	equ	buffer		;
bufref	equ	bufop+1		;
bufst	equ	bufref+1	;
bufarea	equ	bufst+1		;
bufname	equ	bufst+1		;
antal:	dw	0		;
				;
sfcb:	ds	36		;
sfcbcr	equ	sfcb+32		;
				;
conspil:db	1		;
consmax:db	80		;
conslen:db	0		;
cons:	ds	80		;
				;
itemlen:db	0		;
item:	ds	20		;
				;
remote:	db	false		;
				;
unitnr:	db	0		;
name:	ds	8		;
name2:	ds	3		;
blanks:	db	0,0,0,0		;
				;
readcons:			;
	db	false		;

	end	start		;        

