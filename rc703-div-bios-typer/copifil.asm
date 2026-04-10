;
;
;
         .Z80
;
;======================================================
; PROGRAMMET 'COPIFIL' KOPIER EN NAVNGIVEN FIL P] EN  I
; NAVNGIVEN DISC TIL EN NY NAVNGIVEN FIL P] EN NAVN-  I
; GIVEN DISC.                                         I
;                                                     I
;======================================================
;
;
;
; PROGRAMM\R : PETER HEINRICH
; TASTEOPER\R: LEIF BERTELSEN
; DATO       : 19.03.85
;
;
         ASEG
         ORG 103H
;
START:   CALL  INIT                ; S[T DMA TIL BUFFER FLYT FIL-
                                   ; NAVNE TIL FCB'ER OG FEJLUDSKRIFT.
         CALL  OPENIND             ; OPEN SKRIVFIL.
         JP    Z,FEJL1             ; OPEN OK ? NEJ : FEJL1
;
         CALL  OPENUD              ; OPEN SKRIVEFIL.
         JP    Z,OPRETFIL          ; OPEN OK ? NEJ OPRET DEN.
;
         CALL  SVAR                ; JA M] DEN SLETTES ?
         JP    NZ,SLUT             ; NEJ : SLUT.
         CALL  SLETFIL             ; JA : SLET FILEN.
;
OPRETFIL:CALL  OPRET               ; MAKE SKRIVEFIL.
         JP    Z,FEJL2             ; MAKE OK ? NEJ : FEJL2.
;
IGEN:    CALL  LAES                ; L[S EN SECTOR (128 BYTES).
         JP    NZ,EOF              ; EOF M\DT ? JA EOF.
;
;=======================================================
; BEHANDLING AF DET L[STE OG DANNELSEN AF EN POST      I
; TIL UDDATAFILEN                                      I
;                                                      I
;=======================================================
;
         CALL  SKRIV               ; SKRIV EN SECTOR (128 BYTES).
         JP    NZ,FEJL3            ; GIK DET GODT ? NEJ FEJL3.
         JP    IGEN                ; NY SECTOR.
;
EOF:     LD    C,CLOSE             ; CLOSE L[SEFILEN.
         LD    DE,FCBIND           ;
         CALL  5                   ;
         LD    C,CLOSE             ; CLOSE SKRIVEFILEN.
         LD    DE,FCBUD            ;
         CALL  5                   ;
;
SLUT:    JP    0                   ; AFSLUT PROGRAMMET.
;
INIT:    LD    C,DMA               ;
         LD    DE,BUFFER           ; DMA:= BUFFER.
         CALL  5                   ;
;
         LD    BC,16               ; FLYT FILNAVNET FRA
         LD    HL,5CH              ; KOMANDOLINIEN TIL
         LD    DE,FCBUD            ; FCB.
         LDIR                      ;
;
         LD    BC,16               ; FLYT FILNAVNET FRA
         LD    DE,FCBIND           ; KOMANDOLINIEN TIL
         LDIR                      ; FCB.
;
         LD    BC,11               ; FLYT FILNAVN FRA 
         LD    HL,5CH+1            ; KOMADOLINIEN TIL
         LD    DE,TXT+10           ; FEJLUDSKRIVFT.
         LDIR                      ;
         RET                       ;
;
OPENIND: LD    C,OPEN              ;
         LD    DE,FCBIND           ; OPEN INDPUT FILEN.
         CALL  5                   ;
         CP    -1                  ;
         RET                       ; GIK OPEN GODT? S[T S-BITTEN.
;
OPENUD:  LD    C,OPEN              ;
         LD    DE,FCBUD	           ; OPEN UDDATAFIL
         CALL  5                   ;
         CP    -1                  ; GIK OPEN GODT? S[T S-BITTEN. 
         RET                       ;
;
SVAR:    LD    C,CONOUT            ; SKRIV LEDETEKST P] SK[RMEN.
         LD    DE,TXT              ;
         CALL  5                   ; FILEN FINDES. M] DEN SLETTES.
         LD    C,CONIN             ;
         LD    DE,SVARBUF          ; SVAR J/N.
         CALL  5                   ;
;
         LD    A,(SVARBUF+2)       ; LD A MED J/N.
         CP    'J'                 ;
         RET                       ;
;
SLETFIL: LD    C,DELETE	           ;
         LD    DE,FCBUD            ; SLET UDDATAFILEN.
         CALL  5                   ;
         RET                       ;
;
OPRET:   LD    C,MAKE              ;
         LD    DE,FCBUD            ; OPRET UDDATAFILEN.
         CALL  5                   ;
         CP    -1                  ; GIK MAKE GODT? S[T Z-BITTEN.
         RET
;
LAES:    LD    C,READ              ; INDL[S EN SEKTOR.
         LD    DE,FCBIND           ;
         CALL  5                   ;
         CP    0                   ; M\DTE VI EOF? S[T Z-BITTEN.
         RET                       ;
;
SKRIV:   LD    C,WRITE             ; UDSKRIV EN SEKTOR.
         LD    DE,FCBUD            ;
         CALL  5                   ;
         CP    0                   ; DISKETTE FULD? S[T Z-BITTEN.
         RET                       ;
;
FEJL1:   LD    C,CONOUT	           ;
         LD    DE,FEJL11           ; FILEN FINDES IKKE.
         CALL  5                   ;
         JP   -0                   ;
;
FEJL2:   LD    C,CONOUT            ;
         LD    DE,FEJL22           ; FILEN KAN IKKE OPRETTES.
         CALL  5                   ;
         JP    EOF                 ;
;
FEJL3:   LD    C,CONOUT            ;
         LD    DE,FEJL33           ; DISKETTEN ER FULD.
         CALL  5                   ;
         JP    EOF                 ;
;
;****************************************************************
;*                                                              *
;*                     D A T A D E L E N !                      *
;*                                                              *
;****************************************************************
;
;
FCBIND:  DS    33,0                ; INDDATAFILEN.
;
FCBUD:   DS    33,0                ; UDDATAFILEN.
;
SVARBUF: DB    1                   ;
         DS    1                   ; SVAR P] SLETNING AF FILEN.
         DS    1                   ;
;
TXT:     DB    12,6,2+32,2+32,'FILEN '
         DS    14,0
         DB    ' FINDES. M] DEN SLETTES : (J/N) ? $'
;
FEJL11:  DB    6,2+32,2+32,'FILEN FINDES IKKE ! $'
;
FEJL22:  DB    6,2+32,2+32,'FILEN KAN IKKE OPRETTES ! $'
;
FEJL33:  DB    6,2+32,2+32,'IKKE PLADS P] DISKETTEN ! $'
;
BUFFER:  DS    128,' '             ; BUFFER AREAL TIL FILER.
;
CONOUT   EQU   9                   ;
CONIN    EQU   10                  ;
OPEN     EQU   15                  ;
CLOSE    EQU   16                  ;
DELETE   EQU   19                  ;
READ     EQU   20                  ;
WRITE    EQU   21                  ;
MAKE     EQU   22                  ;
DMA      EQU   26                  ;
;
;
         END   START

