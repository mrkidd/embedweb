; Copyright (C) 2002 Mason Kidd (mrkidd@mrkidd.com)
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

; keypad.a51: driver code for keypad

$NOMOD51
$INCLUDE(reg515.inc)

name		keypad
public		kbdinit, keypadi, keypress

sd_keypad	SEGMENT	DATA
			RSEG sd_keypad

keypress:	DS	1
  			
sc_keypad	SEGMENT	CODE
			RSEG	sc_keypad
 		
			USING 0
               
kbdpt	equ	30h      	; value for P2 to access keyboard


kbdtbl: 
	db	'123C456D789EA0BF'

kbdinit:
	setb	IT1			; extern int 1 falling edge
	setb	EX1			; enable external interrupt
	ret

keypadi:
	push	acc
	push	psw
	push	dph
	push	dpl
	push	p2
	mov	dptr, #kbdtbl		; point to translation table
	mov	p2, #kbdpt		; point to keyboard
	movx	a, @r1
	anl	a, #00011111B		; mask lower 5 bits
	movc	a, @a+dptr		; translate to character code
	mov	keypress, A
	pop	p2
	pop	dpl
	pop	dph
	pop	psw
	pop	acc
	reti
     	
         end
