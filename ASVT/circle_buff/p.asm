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


my_int proc near
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
old_addr 	dw 	0, 0
my_int endp

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
	mov 	ax, cs:head 	; сравнивать надо не офсеты
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

print proc near
	push 	ax
	push 	es
	push 	ds
	push 	di
	mov 	ax, 0b800h
	mov 	es, ax
	mov 	ds, ax
	mov 	di, cx

	cmp 	di, 3860
	jle 	@@1

	mov 	si, 800
	xor 	di, di
	mov 	cx, 20
scroll:
	push 	cx
	mov 	cx, 7
carry:
	; lodsw
	; stosw
	movsw

	loop 	carry

	add 	di, 146
	add 	si, 146
	pop	cx
	loop 	scroll

	mov 	cx, 5
	push 	di
clear:
	push 	cx
	mov 	cx, 7
clear_str:
	mov	ax, 0020h
	stosw
	loop 	clear_str
	add 	di, 146

	pop 	cx
	loop 	clear

	pop 	di
@@1:
	mov 	ah, 0ah
	push 	cx
	mov 	cl, bl
	sar 	cl, 4
	and 	cl, 0fh
	add 	cl, 30h
	cmp 	cl, 3ah
	jl 	_2
	add 	cl, 07h
_2:
	mov 	al, cl
	stosw

	mov 	cl, bl
	and 	cl, 0fh
	add 	cl, 30h
	cmp 	cl, 3ah
	jl 	_3
	add 	cl, 07h
_3:
	mov 	al, cl
	stosw

	pop 	cx
	mov 	cx, di
	add 	cx, 156
	pop 	di
	pop 	ds
	pop 	es
	pop 	ax
	
	ret
print endp













begin proc near
	mov 	si, 4*vector
	mov 	di, offset old_addr
	push 	ds
	xor 	ax, ax
	mov 	ds, ax
	movsw 
	movsw
	push 	ds
	push 	es
	pop 	ds
	pop 	es
	mov 	di, 4*vector
	mov 	ax, offset my_int
	cli
	stosw
	mov 	ax, cs
	stosw
	sti

	mov 	ax, 3
	int 	10h

	mov 	cx, 0
@@1:
	hlt
@@2:
	mov 	ax, head
	mov 	bx, tail
	cmp 	ax, bx
	jz 	@@1
	call 	get
	call 	print
	cmp 	bl, 1
	jz 	exit
	cmp 	bl, 0b9h
	jz 	separate
	jmp 	@@2
separate:
	push 	ax
	push 	es
	push 	di

	mov 	ax, 0b800h
	mov 	es, ax
	mov 	di, cx
	mov 	ax, 0a3dh
	mov 	cx, 5
sep_loop:
	stosw
	loop 	sep_loop
	add 	di, 150
	mov 	cx, di

	pop 	di
	pop 	es
	pop 	ax
	jmp 	@@2
exit:
	push 	0
	pop 	es
	mov 	di, 4*vector
	push 	cs
	pop 	ds
	mov 	si, offset old_addr
	cli
	movsw
	movsw
	sti
	pop 	es
	; ret
	retf
begin endp
end _start
