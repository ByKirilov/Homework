.model tiny
.code
org 100h
locals
_start:
	cld
	mov	ax, 0b800h
	mov	es, ax
	xor 	di, di
_1:
	xor	ah, ah
	int	16h
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

	cmp 	di, 4160
	jl 	_1
_6:
	int	19h
end _start