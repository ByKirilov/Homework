model tiny
.code
org 	100h
locals
char1 	equ	'o'
color1 	equ 	0eh
pos1 	equ 	148
_start:
	jmp 	begin
state 	db 	0
int_08 	proc near
	push 	ax
	push 	dx
	push 	di
	push 	es
	inc 	byte ptr cs:state
	cmp 	byte ptr cs:state, 9
	jz 	@@1
	cmp 	byte ptr cs:state, 18
	jnz 	@@9
	mov 	byte ptr cs:state, 0
	mov 	dl, ' '
	jmp 	@@2
@@1:
	mov 	dl, char1
@@2:
	mov 	ax, 0b800h
	mov 	es, ax
	mov 	di, 11*160 + pos1
	mov 	dh, color1
	mov 	es:[di], dx
@@9:
	pop 	es
	pop 	di
	pop 	dx
	pop 	ax
	db 	0eah
old_08 	dw	0, 0
int_08 	endp
resid_end 	db	0
begin 	proc near
	cld
	mov 	ax, 3
	int 	10h

	xor 	ax, ax
	mov 	ds, ax
	mov 	di, offset old_08
	mov 	si, 32
	movsw
	movsw

	mov 	ax, offset int_08
	cli
	mov 	ds:[32], ax
	mov 	ax, cs
	mov 	ds:[34], ax
	sti
;
	; mov 	dx, offset begin + 1
	; int 	27h
my_end:
	mov 	cx, offset begin - 100h
	mov 	ax, 3400h
	mov 	es, ax
	mov 	di, 100h
	push 	cs
	pop 	ds
	mov 	si, 100h
_loop:
	movsb
	loop 	_loop

	cli
	xor 	ax, ax
	mov 	ds, ax
	mov 	ax, 3400h
	mov 	ds:[34], ax
	sti

	xor 	ax, ax
	int 	16h
	retf
	
begin	 endp
end _start