.model tiny
.code
org 100h
locals
_start:
	push 	ax
	push 	bx
	push 	cx
	push 	dx
	push 	bp
	push 	si
	push 	di
	push 	cs
	push 	ds
	push 	es
	push 	ss
	pushf

	mov 	ax, 3
	int 	10h

	mov 	ax, 0b800h
	mov 	es, ax
	xor 	di, di
; flags
	mov 	ah, 0ah
	mov 	al, 66h
	stosw
	mov 	al, 6ch
	stosw
	mov 	al, 61h
	stosw
	mov 	al, 67h
	stosw
	mov 	al, 73h
	stosw
	call 	sep_printer
	pop 	ax
	call 	print_value
	add 	di, 136
; ss
	mov 	ah, 0ah
	mov 	al, 73h
	stosw
	mov 	al, 73h
	stosw
	call sep_printer
	pop 	ax
	call 	print_value
	add 	di, 142
; es
	mov 	ah, 0ah
	mov 	al, 65h
	stosw
	mov 	al, 73h
	stosw
	call sep_printer
	pop 	ax
	call 	print_value
	add 	di, 142
; ds
	mov 	ah, 0ah
	mov 	al, 64h
	stosw
	mov 	al, 73h
	stosw
	call sep_printer
	pop 	ax
	call 	print_value
	add 	di, 142
; cs
	mov 	ah, 0ah
	mov 	al, 63h
	stosw
	mov 	al, 73h
	stosw
	call sep_printer
	pop 	ax
	call 	print_value
	add 	di, 142
; di
	mov 	ah, 0ah
	mov 	al, 64h
	stosw
	mov 	al, 69h
	stosw
	call sep_printer
	pop 	ax
	call 	print_value
	add 	di, 142

	xor 	ax, ax
	int 	16h
; si
	mov 	ah, 0ah
	mov 	al, 73h
	stosw
	mov 	al, 69h
	stosw
	call sep_printer
	pop 	ax
	call 	print_value
	add 	di, 142

	xor 	ax, ax
	int 	16h
; bp
	mov 	ah, 0ah
	mov 	al, 62h
	stosw
	mov 	al, 70h
	stosw
	call sep_printer
	pop 	ax
	call 	print_value
	add 	di, 142
; dx
	mov 	ah, 0ah
	mov 	al, 64h
	stosw
	mov 	al, 78h
	stosw
	call sep_printer
	pop 	ax
	call 	print_value
	add 	di, 142
; cx
	mov 	ah, 0ah
	mov 	al, 63h
	stosw
	mov 	al, 78h
	stosw
	call sep_printer
	pop 	ax
	call 	print_value
	add 	di, 142
; bx
	mov 	ah, 0ah
	mov 	al, 62h
	stosw
	mov 	al, 78h
	stosw
	call sep_printer
	pop 	ax
	call 	print_value
	add 	di, 142
; ax
	mov 	ah, 0ah
	mov 	al, 61h
	stosw
	mov 	al, 78h
	stosw
	call sep_printer
	pop 	ax
	call 	print_value
	add 	di, 142
; sp
	mov 	ah, 0ah
	mov 	al, 73h
	stosw
	mov 	al, 70h
	stosw
	call sep_printer
	mov 	ax, sp
	call 	print_value
	add 	di, 142
; sp - val
	mov 	ah, 0ah
	mov 	al, 73h
	stosw
	mov 	al, 70h
	stosw
	mov 	al, 56h
	stosw
	call sep_printer
	pop 	ax
	call 	print_value
	push 	0

	xor 	ax, ax
	int 	16h
	ret
sep_printer proc near
	mov 	ah, 0ah
	mov 	al, 20h
	stosw 	
	mov 	al, 2dh
	stosw
	mov 	al, 20h
	stosw 	
	ret
sep_printer endp
print_value proc near
	mov 	bx, ax
	mov 	ah, 0ah

	; xor 	cx, cx

	mov 	cl, bh
	sar 	cl, 4
	and 	cl, 0fh
	add 	cl, 30h
	cmp 	cl, 3ah
	jl 	_2
	add 	cl, 07h
_2:
	mov 	al, cl
	stosw

	; xor 	cx, cx

	mov 	cl, bh
	and 	cl, 0fh
	add 	cl, 30h
	cmp 	cl, 3ah
	jl 	_3
	add 	cl, 07h
_3:
	mov 	al, cl
	stosw

	; xor 	cx, cx

	mov 	cl, bl
	sar 	cl, 4
	and 	cl, 0fh
	add 	cl, 30h
	cmp 	cl, 3ah
	jl 	_4
	add 	cl, 07h
_4:
	mov 	al, cl
	stosw

	; xor 	cx, cx

	mov 	cl, bl
	and 	cl, 0fh
	add 	cl, 30h
	cmp 	cl, 3ah
	jl 	_5
	add 	cl, 07h
_5:
	mov 	al, cl
	stosw
	ret
print_value endp
end _start
