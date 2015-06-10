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

;------------------------------------------------------------------------------
;  This file is part of the C51 Compiler package
;  Copyright (c) 1995-1997 Keil Software, Inc.
;------------------------------------------------------------------------------
;  STARTUP.A51:  This code is executed after processor reset.
;
;  To translate this file use A51 with the following invocation:
;
;     A51 STARTUP.A51
;
;  To link the modified STARTUP.OBJ file to your application use the following
;  BL51 invocation:
;
;     BL51 <your object file list>, STARTUP.OBJ <controls>
;
;------------------------------------------------------------------------------
;
;  User-defined Power-On Initialization of Memory
;
;  With the following EQU statements the initialization of memory
;  at processor reset can be defined:
;
; the absolute start-address of IDATA memory is always 0
IDATALEN	equ	0H	; the length of IDATA memory in bytes.
;
XDATASTART	EQU	0D000H	; the absolute start-address of XDATA memory
XDATALEN	EQU	02000H	; the length of XDATA memory in bytes.
;
PDATASTART	EQU	0H	; the absolute start-address of PDATA memory
PDATALEN	EQU	0H	; the length of PDATA memory in bytes.
;
;  Notes:  The IDATA space overlaps physically the DATA and BIT areas of the
;          8051 CPU. At minimum the memory space occupied from the C51 
;          run-time routines must be set to zero.
;------------------------------------------------------------------------------
;
;  Reentrant Stack Initilization
;
;  The following EQU statements define the stack pointer for reentrant
;  functions and initialized it:
;
;  Stack Space for reentrant functions in the SMALL model.
IBPSTACK	EQU	1	; set to 1 if small reentrant is used.
IBPSTACKTOP	EQU	0FFH+1	; set top of stack to highest location+1.
;
;  Stack Space for reentrant functions in the LARGE model.	
XBPSTACK	EQU	0	; set to 1 if large reentrant is used.
XBPSTACKTOP	EQU	0FFFFH+1; set top of stack to highest location+1.
;
;  Stack Space for reentrant functions in the COMPACT model.	
PBPSTACK	EQU	0	; set to 1 if compact reentrant is used.
PBPSTACKTOP	EQU	0FFFFH+1; set top of stack to highest location+1.
;
;------------------------------------------------------------------------------
;
;  Page Definition for Using the Compact Model with 64 KByte xdata RAM
;
;  The following EQU statements define the xdata page used for pdata
;  variables. The EQU PPAGE must conform with the PPAGE control used
;  in the linker invocation.
;
PPAGEENABLE	EQU	0	; set to 1 if pdata object are used.
PPAGE		EQU	0	; define PPAGE number.
;
;------------------------------------------------------------------------------
$include	(bit515.inc)

		NAME	?C_STARTUP


?C_C51STARTUP	SEGMENT   CODE
?STACK		SEGMENT   IDATA

		rseg	?STACK
		DS	1

		EXTRN CODE (?C_START,keypadi)
		PUBLIC	?C_STARTUP

$IF RISM <> 0
                CSEG    AT      8000h
$ELSE
		CSEG	AT	0
$ENDIF

;$IF RISM <> 0
;	stard	EQU	8100H
;$ELSE
;	stard	EQU	0000H
;$ENDIF

;		CSEG	AT	stard
?C_STARTUP:	LJMP	STARTUP1

		CSEG	AT	8013h
 		ljmp	ext1srv
  		
ext1srv:
;		clr	EX1
		call	keypadi
 		setb	EX1
		reti

		RSEG	?C_C51STARTUP

STARTUP1:

; Initilization Specific To The EMAC MicroPac 535 SBC
		
		clr	P5_5
		setb	P5_5		; reset SC26C92 DUART
		clr	P5_5		; bring DUART out of reset
		setb	P5_0		; make A16 of 128K Ram, hi
 		clr	P5_1		; enable memory mapped IO
   
; End Of MicroPac 535 Initilization


IF IDATALEN <> 0
		MOV	R0,#IDATALEN - 1
		CLR	A
IDATALOOP:	MOV	@R0,A
		DJNZ	R0,IDATALOOP
ENDIF

IF XDATALEN <> 0
		MOV	DPTR,#XDATASTART
		MOV	R7,#LOW (XDATALEN)
  IF (LOW (XDATALEN)) <> 0
		MOV	R6,#(HIGH XDATALEN) +1
  ELSE
		MOV	R6,#HIGH (XDATALEN)
  ENDIF
		CLR	A
XDATALOOP:	MOVX	@DPTR,A
		INC	DPTR
		DJNZ	R7,XDATALOOP
		DJNZ	R6,XDATALOOP
ENDIF

IF PPAGEENABLE <> 0
		MOV	P2,#PPAGE
ENDIF

IF PDATALEN <> 0
		MOV	R0,#PDATASTART
		MOV	R7,#LOW (PDATALEN)
		CLR	A
PDATALOOP:	MOVX	@R0,A
		INC	R0
		DJNZ	R7,PDATALOOP
ENDIF

IF IBPSTACK <> 0
EXTRN DATA (?C_IBP)

		MOV	?C_IBP,#LOW IBPSTACKTOP
ENDIF

IF XBPSTACK <> 0
EXTRN DATA (?C_XBP)

		MOV	?C_XBP,#HIGH XBPSTACKTOP
		MOV	?C_XBP+1,#LOW XBPSTACKTOP
ENDIF

IF PBPSTACK <> 0
EXTRN DATA (?C_PBP)
		MOV	?C_PBP,#LOW PBPSTACKTOP
ENDIF

		MOV	SP,#?STACK-1
		LJMP	?C_START

		END
