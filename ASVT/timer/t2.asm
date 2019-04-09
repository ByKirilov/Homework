model tiny
.code
org 	100h
locals
char1 	equ		0e0h
color1 	equ 	20h
pos1 	equ 	142
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
	mov 	dx, offset begin + 1
	int 	27h
begin	 endp
end _start