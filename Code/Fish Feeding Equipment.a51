

		org	0300H

ti0	equ	r6
sec	equ r5
min	equ	11H
nguyen7Led	equ	12H
du7Led	equ	13H
tramUart	equ	14H
chucUart	equ	15H
donviUart	equ	16H
duUart	equ 17H
save equ	19H
DelayServo equ	20H
DelayBT1	equ	21H
DelayBT2	equ	22H
DelayHThi	equ	23H
servo_out	bit	P3.7
;====================================================================
; RESET and INTERRUPT VECTORS
;====================================================================

      ; Reset Vector
      org   0000h
      jmp   Start

		org	0003H
		jmp	ISRINT0

		org	0013H
		jmp	ISRINT1

		org	000BH
		jmp	ISRTIMER0

		org	0023h
		jmp	ISRUART
		
;====================================================================
; CODE SEGMENT
;====================================================================

      org   0030h
Start:
      ; Write your code here

		CLR	P3.6
		CLR	P1.3
		CLR	P1.2
		mov P2, #0FFH
		mov	P0, #0FFH

		mov   TH0,#high(-10000)
		mov    TL0,#low(-10000)
		mov	TMOD,	#00100001B
		mov TH1, #0FDH
		mov SCON,	 #050H
		mov	IE,	#10010111B
		mov	IP,	#00010101B
		
		CLR	TF0
		SETB	TR0
		SETB	TR1

		MOV	ti0, #00H
		mov		save, #05H
		MOV	sec,	save
		MOV	min,	#03CH
		mov A, #00H
		mov	DelayServo,	#100

		CLR	P1.3
		CLR	P1.0

Loop:
		ACALL  Servo_2c
		;MI:
				ACALL  ReadAdc
				SE:
						TIM0:
						LCALL	LUU
						LCALL	 HIENTHI
						CJNE	ti0,	#063H,	TIM0
						mov	ti0,	#00H
				CPL	P3.6
				DJNZ	sec, SE
				mov sec, save

		;DJNZ	min,	 MI
		;mov min, #03BH

 jmp Loop

DELAYHT: 
		MOV DelayHThi, #65
		LoopDelay: 	DJNZ 	DelayHThi,	LoopDelay
RET

DELAYBT:
		MOV		DelayBT1, #255
LoopDelayBT:
		MOV		DelayBT2, #255
		DJNZ	DelayBT2, $
		DJNZ	DelayBT1,LoopDelayBT
		RET

DELAYSV:
	MOV	R7, DelayServo
	DELAYSVV:
	MOV TL0,#LOW(-60000)
	MOV TH0,#HIGH(-60000)
	SETB	TR0
	AGAIN:	JNB	TF0,	AGAIN
	CLR	TR0
	CLR	TF0
	DJNZ R7,DELAYSVV
	MOV	R7,#0
	RET

LUU:
		MOV    A, sec
		MOV    B,#10
		DIV       AB  
		MOV    du7Led,B        
		MOV    nguyen7Led,A 
		ret

HIENTHI:
		SETB		P3.4
		MOV     P0, nguyen7Led
		lCALL   DELAYHT
		CLR		P3.4
		SETB		P3.5
		MOV     P0, du7Led
		lCALL   DELAYHT
		CLR		P3.5
		ret

Servo_2c:
		ACALL MOVE0
		ACALL DELAYSV
		ACALL MOVE45
		ACALL DELAYSV
		ACALL MOVE0

		CLR	P3.7
		SETB	ET0
		mov   TH0,#high(-10000)
		mov    TL0,#low(-10000)
		SETB	TR0
		RET

MOVE45:
	MOV R7,#100
MOVE455:
	SETB servo_out
	CALL DELAY45
	CLR servo_out
	CALL DELAY45
	DJNZ R7,MOVE455
	MOV R7,#0
	RET

MOVE0:
	MOV R7,#100
MOVE00:
	SETB servo_out
	CALL DELAY0
	CLR servo_out
	CALL DELAY0
	DJNZ R7,MOVE00
	MOV R7,#0
	RET

DELAY45:
	MOV TL0,#LOW(-2000)
	MOV TH0,#HIGH(-2000)
	SETB TR0
	JNB  TF0,$
	CLR  TR0
	CLR  TF0
	RET
DELAY0:
	MOV TL0,#LOW(-1500)
	MOV TH0,#HIGH(-1500)
	SETB TR0
	JNB  TF0,$
	CLR  TR0
	CLR  TF0
	RET

ReadAdc:
		SETB	P1.0
		ACALL DELAYHT
		CLR	P1.0
		ACALL DELAYHT
		LOOP1: JNB P1.1, LOOP1

		MOV A, P2
		MOV B, #100
		DIV	AB
		MOV tramUart, A; 14H LUU HANG TRAM
		MOV A, B
		MOV B, #10
		DIV AB
		MOV chucUart, A; 15H LUU HANG CHUC
		MOV donviUart, B

		MOV B, #2
		MOV A, donviUart; 16H LUU HANG DV
		MUL AB
		MOV B, #10
		DIV AB
		MOV donviUart, B
		MOV duUart, A; 17 LUU SO NHO 
		MOV B, #2
		MOV A, chucUart
		MUL AB
		MOV B, duUart
		ADD A, B
		MOV B, #10
		DIV AB
		MOV chucUart, B
		MOV duUart, A
		MOV B, #2
		MOV A, tramUart
		MUL AB
		MOV B, duUart
		ADD A,B
		MOV tramUart, A
		RET

ISRINT0:
		ACALL	DELAYBT
		ACALL	DELAYBT
				INC	save
				mov	sec,	save
				CJNE	sec, #03DH, SE1
						mov	sec,	#01H
						mov save, #01H
				SE1:
		RETI

ISRINT1:
		ACALL	DELAYBT
		ACALL	DELAYBT
		DEC save
				mov	sec,	save
				CJNE	sec, #00H, SE2
						mov	sec,	#03CH
						mov save, #03CH
				SE2:
		RETI

ISRTIMER0:
		CLR	TR0
		mov   TH0,#high(-10000)
		mov    TL0,#low(-10000)
		INC	ti0
		CPL	P1.2
		SETB	TR0
		RETI

ISRUART:
		MOV	A, SBUF
		CLR	RI
		CJNE	A, #031H, KoNDo
				;MOV A, tramUart
				;ADD A, #030H
				;MOV	SBUF,	A
				;HERE1: JNB TI, HERE1
				;CLR TI
				MOV A, chucUart
				ADD A, #030H
				MOV	SBUF,	A
				HERE2: JNB TI, HERE2
				CLR TI
				MOV A, donviUart
				ADD A, #030H
				MOV	SBUF,	A
				HERE3: JNB TI, HERE3
				CLR TI
		KoNDo:
		CJNE	A, #032H, Ko50
				Mov DelayServo, #50
				MOV	SBUF,	#"O"
				HERE4: JNB TI, HERE4
				CLR TI
		Ko50:
		CJNE	A, #033H, Ko100
				Mov DelayServo, #100
				MOV	SBUF,	#"O"
				HERE5: JNB TI, HERE5
				CLR TI
		Ko100:
		CJNE	A, #034H, Ko150
				Mov DelayServo, #150
				MOV	SBUF,	#"O"
				HERE6: JNB TI, HERE6
				CLR TI
		Ko150:
RETI
;====================================================================
      END
