.model tiny
.data
	shift 	db 5
	str_len	db 160
.code
org 100h
locals
_start:
	cld

	mov	ax, 3		; очистка экрана
	int	10h

	mov	ax, 0b800h
	mov	es, ax
	mov 	ds, ax
	xor 	di, di
_1:
	xor	ah, ah
	int	16h
	cmp 	di, 3860
	jle 	print

	push 	ax
	mov 	ax, 5
	mov 	bx, 160
	mul 	bx

	mov 	si, ax
	xor 	di, di
	mov 	cx, 25
	sub 	cx, 5
scroll:
	push 	cx
	mov 	cx, 7
carry:
	lodsw
	stosw
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

	pop 	ax
;---------------------------------
print:
	mov 	bx, ax
	mov	ah, 0ah
	stosw
	add 	di, 2

	mov 	cl, bl
	sar 	cl, 4
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

	add 	di, 2

	mov 	cl, bh
	sar 	cl, 4
	add 	cl, 30h
	cmp 	cl, 3ah
	jl 	_4
	add 	cl, 07h
_4:
	mov 	al, cl
	stosw

	mov 	cl, bh
	and 	cl, 0fh
	add 	cl, 30h
	cmp 	cl, 3ah
	jl 	_5
	add 	cl, 07h
_5:
	mov 	al, cl
	stosw	

	add	di, 146

	cmp 	bh, 1
	jz 	_6

	jmp 	_1
_6:
	ret
	int	19h
end _start