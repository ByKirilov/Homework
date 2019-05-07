.model tiny
.code
org 100h
locals @@
vector equ 9
_start:
	jmp 	begin

bufferlen equ 20
buffer 	db bufferlen dup (0)
head 	dw offset buffer
tail 	dw offset buffer

int_09 proc near
	push	ax
	push	di
	push	es
	in	al, 60h    ;скан. код клавиши из РА
	; запись в буффер
	mov 	bl, al
	call 	save

	pop	es
	pop	di
	in	al, 61h    ;ввод порта РВ
	mov	ah, al
	or 	al, 80h    ;установить бит "подтверждения ввода"
	out	61h, al
	xchg	ah, al     ;вывести старое значение РВ
	nop
	nop
	nop
	out	61h, al
	mov	al, 20h    ;послать сигнал EOI
	out	20h, al    ;контроллеру прерываний
	pop	ax
	iret
old_09 	dw 	0, 0
int_09 endp

Sound proc near
	push	ax 
	push	bx
	push	dx
	mov	bx, ax 
	mov	ax, 34DDh
	mov	dx, 12h 
	cmp	dx, bx 
	jnb	Done 
	div	bx  
	mov 	bx, ax 
	in	al, 61h
	or 	al, 3 
	out	61h, al
	mov	al, 10000110b 
	mov	dx, 43h
	out	dx, al
	dec 	dx
	mov 	al, bl
	out 	dx, al
	mov 	al, bh
	out 	dx, al 
Done:
	pop	dx 
	pop	bx
	pop 	ax
	ret
Sound endp

No_Sound proc near
	push 	ax
	in	al, 61h
	and	al, not 3
	out	61h, al
	pop	ax
	ret
No_Sound endp


get proc near
	push 	ds
	push 	si
	push 	ax
	push 	cs
	pop 	ds
	mov 	si, tail
	cli
	lodsb
	sti
	mov 	bl, al
	; mov 	bl, [cs:tail]
	inc 	tail
	cmp 	tail, offset buffer + bufferlen
	jnz 	@@1
	mov 	tail, offset buffer
@@1:
	pop 	ax
	pop 	si
	pop 	ds
	ret
get endp

save proc near
	push 	es
	push 	di
	push 	cx
	push 	ax
	mov 	cx, head
	push 	cs
	pop 	es
	mov 	di, head
	mov 	al, bl
	cli
	stosb
	sti
	; mov 	[cs:head], bl	;;;;;
	inc 	head
	cmp 	head, offset buffer + bufferlen
	jnz 	@@1
	mov 	head, offset buffer
@@1:
	xor 	ax, ax
	xor 	bx, bx
	mov 	ax, cs:head 	
	mov 	bx, cs:tail
	cmp 	ax, bx
	jnz 	@@2
	mov 	head, cx
@@2:
	pop 	ax
	pop 	cx
	pop 	di
	pop 	es
	ret
save endp

begin:

















_1:
	xor 	ax, ax
	int 	16h
	cmp 	al, 's'
	jz 	_sound
	cmp 	al, 'p'
	jz 	_no_sound
	cmp 	ah, 1
	jz 	_exit
	jmp 	_1
_sound:
	call 	Sound
	jmp 	_1
_no_sound:
	call 	No_Sound
	jmp 	_1
_exit:
	ret
end _start