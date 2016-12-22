#make_bin#

#LOAD_SEGMENT=FFFFh#
#LOAD_OFFSET=0000h#

#CS=0000h#
#IP=0000h#

#DS=0000h#
#ES=0000h#

#SS=0000h#
#SP=FFFEh#

#AX=0000h#
#BX=0000h#
#CX=0000h#
#DX=0000h#
#SI=0000h#
#DI=0000h#
#BP=0000h#



	jmp st1


	PORTA1	equ	00h
	PORTB1	equ	02h
	PORTC1	equ	04h
	creg1	equ	06h
	PORTA2	equ	08h
	PORTB2	equ	0Ah
	PORTC2	equ	0Ch
	creg2	equ	0Eh
	PORTA3	equ	10h
	PORTB3	equ	12h
	portC3	equ	14h
	creg3	equ	16h  

	
	
	table_d	db	40h,79h,24h,30h		; hex codes of display device
		db	19h,12h,02h,78h,
		db	00h,18h,08h,83h,
		db	46h
	table_k	db	0eeh,0edh,0ebh,0e7h,	; hex codes for keypad
		db	0deh,0ddh,0dbh,0d7h,
		db	0beh,0bdh,0bbh,0b7h,
		db	07eh


	num7    equ 78h
	num4    equ 19h
	num1    equ 79h
	num0    equ 40h
	num2    equ 24h

	
	stack1	dw	20 dup(?)
	tstack1	dw	0	
	icno	db	4 dup(0)
	noro	db	78h,19h,40h,24h		; 7402
	nando	db	78h,19h,40h,40h		; 7400
	nand3o	db	78h,19h,79h,40h		; 7410

	alpF	equ	10001110b
        alpA	equ	10001000b
	alpI	equ	11111001b
	alpL	equ	11000111b
	alpP	equ	10001100b
	alpS	equ	10010010b 
	

st1:	cli					;initialize ds,es,ss to start of RAM
	
	  mov       ax,0200h
          mov       es,ax
          mov       ss,ax
          mov       sp,0FFFEH 
          mov       ax,00
          mov       ds,ax


	mov al,10000001b			;initialise 8255(1)
	out creg1,al
	
	mov al,10010010b
	out creg2,al				;initialise 8255(2)



	lea si,icno
	mov dh,06h

						
X0:	mov	al,00h				; check for key release
	out	PORTC1,al
X1:	in	al,PORTC1
	and	al,0f0h
	cmp	al,0f0h
	jnz	X1
	
	call delay20

	mov	al,00h				;check for key press
	out	PORTC1,al
X2:	in	al,PORTC1
	and	al,0f0h
	cmp	al,0f0h
	jz	X2

	call delay20

	mov	al,00h				; check for key press
	out	PORTC1,al
	in	al,PORTC1
	and     al,0f0h
	cmp	al,0f0h
	jz	X2

	mov	al,0eh				; check for key press in column1
	mov	bl,al
	out	PORTC1,al
	in	al,PORTC1
	and	al,0f0h
	cmp	al,0f0h
	jnz	X3

	mov	al,0dh				; check for key press in column2
	mov	bl,al
	out	PORTC1,al
	in	al,PORTC1
	and	al,0f0h
	cmp	al,0f0h
	jnz	X3

	mov	al,0bh				; check for key press in column3
	mov	bl,al
	out	PORTC1,al
	in	al,PORTC1
	and	al,0f0h
	cmp	al,0f0h
	jnz	X3

	mov	al,07h				; check for key press in column4
	mov	bl,al
	out	PORTC1,al
	in	al,PORTC1
	and	al,0f0h
	cmp	al,0f0h
	jnz	X3

X3:	or	al,bl		
	mov	cx,0fh
	mov	di,00h
X4:	cmp	al,table_k[di]
	jz	X5
	inc	di
	loop	X4
X5:	mov	ax,di
	lea	bx,table_d
	xlat

	cmp al,08h 				;check for backspace
	jz X6
	cmp al,83h
	jz X7					;check for enter
	cmp al,46h
	jz X14					;check for test

	mov [si],al				;0-9
	mov bl,al
	mov cx,100

X13:	cmp dh,06h				;1st digit
	jnz X10
	mov al,0e0h
	out PORTA1,al
	mov al,[si]
	out PORTB1,al
	
	call delay1
	jmp X9

X10:	cmp dh,05h				;2nd digit
	jnz X11
	mov al,0e0h
	out PORTA1,al
	mov al,[si]
	out PORTB1,al
	mov al,0d0h
	out PORTA1,al
	mov al,[si-1]
	out PORTB1,al
	dec cx
	jnz X10
	
	call delay1
	jmp X9

X11: 	cmp dh,04h				;3rd digit
	jnz X12
	mov al,0e0h
	out PORTA1,al
	mov al,[si]
	out PORTB1,al
	mov al,0d0h
	out PORTA1,al
	mov al,[si-1]
	out PORTB1,al
	mov al,0b0h
	out PORTA1,al
	mov al,[si-2]
	out PORTB1,al
	dec cx
	jnz X11
	
	call delay1
	jmp X9

X12: 	cmp dh,03h				;4th digit	
	jnz X13

	mov al,0e0h
	out PORTA1,al
	mov al,[si]
	out PORTB1,al
	mov al,0d0h
	out PORTA1,al
	mov al,[si-1]
	out PORTB1,al
	mov al,0b0h
	out PORTA1,al
	mov al,[si-2]
	out PORTB1,al
	mov al,70h
	out PORTA1,al
	mov al,[si-3]
	out PORTB1,al
	dec cx
	jnz X12
	
	call delay1
	jmp X9


X9:	inc si 
	dec dh
	jnz X0
X6:	
	cmp dh,06h
	jmp X0

	cmp dh,05h
	jnz XA
	mov al,0e0h
	out PORTA1,al
	mov al,40h
	out PORTB1,al
	dec si
	jmp X0
	
XA:	cmp dh,04h
	jnz XB
	dec si
	jmp X10

XB:	cmp dh,03h
	jnz XC
	dec si
	jmp X11

XC: 	cmp dh,02h	
	dec si
	jmp X12


X7:	
	lea si,icno
	mov al,70h
	out PORTA1,al
	mov al,[si]
	out PORTB1,al
	inc si
	mov al,0b0h
	out PORTA1,al
	mov al,[si]
	out PORTB1,al
	inc si
	mov al,0d0h
	out PORTA1,al
	mov al,[si]
	out PORTB1,al
	inc si
	mov al,0e0h
	out PORTA1,al
	mov al,[si]
	out PORTB1,al

	call delay1	
	dec cx
	jnz X7
	jmp X0


			;testing
X14:  		
	mov si,0 
	mov di,0
	mov al,icno[si] 
	mov bl,noro[di]
	cmp al,bl
	jnz F
	
	inc si
	inc di
	mov al,icno[si]
	mov bl,noro[di]
	cmp al,bl
	jnz F
	
	inc si
	inc di
	mov al,icno[si]
	mov bl,noro[di]
	cmp al,bl
	jz noa
	mov bl,nand3o[di]
	cmp al,bl
	jz n3
	
	jmp F

noa:   inc  si
       inc  di
       
       mov  al,icno[si]
       mov  bl,noro[di]
       cmp  al,bl
       jz   NOR2
       
       mov  al,icno[si]
       mov  bl,nando[di]
       cmp  al,bl
       jz   NAND2
       
       jmp  F

n3:         
        inc si
        inc di
        
        mov al,icno[si]
        mov bl,nand3o[di]
        cmp al,bl
        jz  NAND3
        
        jmp F	


NOR2:  	
	mov al,00000000b			;00
	out PORTC2,al
	in al,PORTB2
	and al,0fh
	cmp al,0fh
	jnz F
	
	mov al,00000001b			;01
	out PORTC2,al
	in al,PORTB2
	and al,0fh
	cmp al,0fh
	jnz F

	mov al,00000010b			;10
	out PORTC2,al	
	in al,PORTB2
	and al,0fh
	cmp al,0fh
	jnz F

	mov al,00000011b			;11
	out PORTC2,al
	in al,PORTB2
	and al,0fh
	cmp al,0fh
	jnz F
	
	jmp PASS

NAND2:	
	mov al,00100000b			;00
	out PORTC2,al
	in al,PORTB2
	and al,0fh
	cmp al,0fh
	jnz F
	
	mov al,00100001b			;01
	out PORTC2,al
	in al,PORTB2
	and al,0fh
	cmp al,0fh
	jnz F

	mov al,00100010b			;10
	out PORTC2,al	
	in al,PORTB2
	and al,0fh
	cmp al,0fh
	jnz F

	mov al,00100011b			;11
	out PORTC2,al
	in al,PORTB2
	and al,0fh
	cmp al,0fh
	jnz F
	
	jmp PASS

NAND3: 

	mov al,00010000b			;000
	out PORTC2,al
	in al,PORTB2
	and al,07h
	cmp al,07h
	jnz F
	
	mov al,00010001b			;001
	out PORTC2,al
	in al,PORTB2
	and al,07h
	cmp al,07h
	jnz F

	mov al,00010010b			;010
	out PORTC2,al	
	in al,PORTB2
	and al,07h
	cmp al,07h
	jnz F

	mov al,00010011b			;011
	out PORTC2,al
	in al,PORTB2
	and al,07h
	cmp al,07h
	jnz F
	
	
	mov al,00010100b			;100
	out PORTC2,al
	in al,PORTB2
	and al,07h
	cmp al,07h
	jnz F
	
	mov al,00010101b			;101
	out PORTC2,al
	in al,PORTB2
	and al,07h
	cmp al,07h
	jnz F

	mov al,00010110b			;110
	out PORTC2,al	
	in al,PORTB2
	and al,07h
	cmp al,07h
	jnz F

	mov al,00010111b			;111
	out PORTC2,al
	in al,PORTB2
	and al,07h
	cmp al,07h
	jnz F

	jmp PASS



F: 	jmp FAIL

FAIL:
	mov al,0e0h
	mov PORTA1,al
	mov al,alpL
	mov PORTB1,alpL
	mov al,0d0h
	mov PORTA1,al
	mov al,alpI
	mov PORTB1,al
	mov al,0b0h
	mov PORTA1,al
	mov al,alpA
	mov PORTB1,al
	mov al,70h
	mov PORTA1,al
	mov al,alpF
	mov PORTB1,al
	
	call delay1
	
	jmp FAIL
PASS:
	mov al,0e0h
	mov PORTA1,al
	mov al,alpS
	mov PORTB1,alpL
	mov al,0d0h
	mov PORTA1,al
	mov al,alpS
	mov PORTB1,al
	mov al,0b0h
	mov PORTA1,al
	mov al,alpA
	mov PORTB1,al
	mov al,70h
	mov PORTA1,al
	mov al,alpP
	mov PORTB1,al
	
	call delay1
	
	jmp PASS
	
	end1:
	jmp end1
	
delay1	proc	near
	
	mov	al,10110001b		; initializing 8253
	out	creg3,al
	mov	al,10			; transferring lsb of count
	out	portC3,al
	mov	al,00			; transferring msb of count
	out	portc3,al
	mov	al,40h			; triggering gate input
	out	PORTA2,al
	
	
chck:	in	al,PORTB2
	and	al,20h
	cmp	al,20h
	jnz	chck 
	
delay1	endp
	ret  
	
delay20 proc    near
	
	pushf
	push AX
	push bx
	push cx
	push dx
	mov cx,1000h
E1: NOP
	NOP
	NOP
	NOP
	loop E1
	
	pop dx
	pop cx
	pop bx
	pop ax
	popf
	
  ret
  delay20 endp



