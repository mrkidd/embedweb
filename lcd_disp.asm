; Copyright (C) 2002 Mason Kidd (mrkidd@mrkidd.com)
; COPYRIGHT 1993-1995 EMAC INC.
;
; This file is part of EmbedWeb.
;
; EmbedWeb is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; EmbedWeb is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with EmbedWeb; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

; lcd_disp: code to control the LCD on an EMAC board

	.module lcd_disp

	.globl _lcdout
	.globl _lcdinit
	.globl _lcd_crlf

; BEGIN EMAC CODE
;************************************************************************
;
; 20X2 character LCD drivers for the MICROPAC 535
;
; COPYRIGHT 1993-1995 EMAC INC.
;
; ESCflag is a bit field that must be declared.
; DLAYA is a 5ms delay routine with no registers affected.
; LCDINIT should be executed before any other LCD subroutines.
;
;        
; LCDOUT: Output the char in ACC to LCD        
; Following are some codes that are supported by this driver (20*2 displays)
;
;        0ah      move cursor to other line (i.e. from 1-2 or 2-1)
;        0dh      move cursor to beginning of line 
;        1ah      clear display and move cursor to home
;        1bh      the next byte received after this will be written to register
;                 0 of the lcd display
;                  

; definitions

	.area XSEG (XDATA)
initdata:
	.db 0x38, 0x08, 0x01, 0x06, 0x0e, 0x80, 0

escflag = psw.5
lcdcmd = 0x28

	.area CSEG (CODE)

;escflag	equ	psw.5		; LCD equate
;lcdcmd   	equ	28h      	; value for P2 to select lcd command port
;initdata:
;         db       38h,08,01,06,0eh,80h,0
;--------------------------------------------------------------
; Dempsey notes
; (1) R1,R2 are corrupted by this subroutine
; (2) Previously there were several returns- now only one: "LCDEXIT"
; (3) From calling program: Use a delay of 5ms (minimum)
;     between command codes LF (0A) and CR (0D)
;---------------------------------------------------------------  

; character passed in R7
_lcdout:  
	mov	A, R7
	mov	r2, a             ; SAVE CHAR IN R2
	mov	P2, #LCDCMD       ; POINT TO COMMAND PORT
	jnb	ESCflag,lcdnt5    ; skip if no ESC
	clr	escflag
	sjmp	reg0out           ; write directly to lcd reg 0

lcdnt5:
	anl	a,#0b11100000      ; SEE IF ANY OF UPPER 3 BITS SET
	jnz	REG1OUT           ; IF YES, PRINT IT
	mov	A,R2              ; RESTORE CHAR
	anl	A,#0b11111000      ; SEE IF CHAR IS < 7
	jz	REG1OUT           ; IF LESS, A=0 SO PRINT USER DEF CHAR 0-7
         
	mov	A,R2              ; SEE IF CONTROL CHAR
	cjne	A,#0x0D,LCNT1      ; IF NOT CR, SKIP
	movx	a,@r1             ; READ COMMAND PORT TO FIND CURSOR POS
	setb	ACC.7             ; SET BIT 7 FOR DDRAM ADDR
	anl	A,#0b11100000      ; MOVE TO LEFT (ONLY VALID ON 2 LINE DISPL)
	mov	R2,A
	sjmp	REG0OUT
         
LCNT1:	cjne	A,#0x0A,LCNT2      ; IF NOT LF, SKIP
	movx	a,@r1             ; READ COMMAND PORT TO FIND CURSOR POS
	cpl	ACC.6             ; SWITCH LINE (ONLY VALID ON 2 LINE DISPL)
	setb	ACC.7             ; SET BIT 7 FOR DDRAM ADDR
	mov	R2,A
	sjmp	REG0OUT
         
LCNT2: 	cjne	A,#0x1B,LCNT3      ; IF NOT ESC, SKIP
	setb	ESCflag           ; indicate ESC received
	sjmp	lcdexit
         
LCNT3: 	cjne	A,#0x1A,LCNT4	  ; EXIT IF NOT CLEAR SCREEN
	mov	r2,#1             ; CLEAR COMMAND
	sjmp	reg0out

				  ; OUTPUT THE CHAR IN R2 TO REG 1
REG1OUT:
	movx	a,@r1             ; READ LCD COMMAND PORT
	jb 	ACC.7,REG1OUT     ; LOOP IF BUSY FLAG SET
	inc	P2                ; POINT TO LCD DATA PORT         
	mov	A,R2              ; RESTORE CHAR
	movx	@r1,a             ; OUTPUT IT
LCNT4:	
	sjmp	lcdexit

         
        			  ; OUTPUT THE CHAR IN R2 TO REG 0
reg0out:
	movx	a,@r1             ; READ LCD COMMAND PORT
	jb  	ACC.7,REG0OUT     ; LOOP IF BUSY FLAG SET
	mov	A,R2              ; RESTORE CHAR
	movx	@r1,a             ; OUTPUT IT
     	sjmp	lcdexit
        
; 
; LCDINIT: Init the LCD
;         
_lcdinit:         
	clr 	ESCflag           ; indicate no esc found
	mov  	P2,#LCDCMD        ; POINT TO COMMAND PORT
	lcall  	DLAYA             ; 5MS DELAY
	lcall  	DLAYA             ; 5MS DELAY
	lcall  	DLAYA             ; 5MS DELAY
	lcall 	DLAYA             ; 5MS DELAY
	mov    	A,#0x30
	movx  	@r1,a             ; OUT TO LCD COMMAND PORT         
	lcall 	DLAYA             ; 5MS DELAY         
	movx  	@r1,a             ; OUT TO LCD COMMAND PORT                  
	lcall 	DLAYA             ; 5MS DELAY         
	movx  	@r1,a             ; OUT TO LCD COMMAND PORT                  
         
	mov  	dptr,#INITDATA    ; POINT TO INIT DATA
        		          ; the last command should take no more than 40 uS. 
  	mov	b,#80             ; for timeout of 80*3 * (12/clock)
lcdnit2:
	movx 	a,@r1             ; read lcd command port
     	jnb   	acc.7,lcdnit1     ; exit if not busy
     	djnz 	b,lcdnit2         ; loop till timeout
     	sjmp 	lcdexit	; exit if timeout

LCDNIT1:
	movx 	a,@r1             ; READ LCD COMMAND PORT
      	jb   	ACC.7,LCDNIT1     ; LOOP IF BUSY FLAG SET				      
     	clr 	A
     	movc  	a,@a+dptr         ; GET BYTE FROM INIT TABLE
     	jz    	lcdexit           ; EXIT IF 0
    	inc   	DPTR              ; POINT TO NEXT BYTE        
     	movx  	@r1,a             ; OUTPUT BYTE
    	sjmp   	LCDNIT1           ; LOOP
         
lcdexit:
	ret   

; END EMAC CODE

; subroutine to output a CR and LF
_lcd_crlf:
	push	ACC
	mov	R7, #0x0a
	acall	_lcdout
	acall	dlaya
	mov	R7, #0x0d
	acall	_lcdout
	pop	ACC
	ret

; BEGIN EMAC CODE
; MISCELLANEOUS DELAYS
;
DLAYA:	
	push 	ACC
      	mov    	A,#100
      	ajmp  	DLAYA2

DLAYB: 	
	push   	ACC
      	mov   	A,#128
	ajmp  	DLAYA2
DLAYC: 
	push 	ACC
      	mov   	A,#255
      	ajmp  	DLAYA2
dlayd:
 	push 	acc
      	mov 	a,#8
DLAYA2:
     	push 	ACC
     	mov   	A,#0x0FF
DLAYA1: 
      	mov   	A,#0x0FF
     	djnz  	ACC,.             ; LEVEL 3 LOOP            
     	pop   	ACC
     	djnz  	ACC,DLAYA2        ; LEVEL 1 LOOP
         
     	pop   	ACC
	ret

; END EMAC CODE
	
