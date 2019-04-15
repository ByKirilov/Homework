model tiny
.code
org 	100h
locals
; char_H 		equ 	'H'
; pos_H 		equ 	140
; color_H		equ	0eh

; char_e 		equ 	'e'
; pos_e 		equ 	142
; color_e		equ	0eh

; char_l1		equ 	'l'
; pos_l1 		equ 	144
; color_l1	equ	0eh

; char_l2		equ 	'l'
; pos_l2		equ 	146
; color_l2	equ	0eh

; char_l2		equ 	'l'
; pos_l2		equ 	148
; color_l2	equ	0eh

; char_o		equ 	'o'
; pos_o		equ 	150
; color_o 	equ	0eh

; char_!		equ 	'!'
; pos_!		equ 	152
; color_! 	equ	0eh

_start:
	jmp 	begin
char1 	db 	0
pos1 	dw 	140
color1	db 	0eh
state 	db 	0
int_08 	proc near
	push 	ax
	push 	dx
	push 	di
	push 	es
	push 	ds
	push 	cs
	pop 	ds
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
	mov 	di, pos1
	add 	di, 11*160
	mov 	dh, color1
	mov 	es:[di], dx
@@9:
	pop 	ds
	pop 	es
	pop 	di
	pop 	dx
	pop 	ax
	db 	0eah
old_08 	dw	0, 0
int_08 	endp
dialog		db	'input symbol', 0

begin 	proc near
	cld
	mov 	ax, 3
	int 	10h

	mov 	bx, 3000h

big_loop:
	mov 	ax, 0b800h
	mov 	es, ax
	xor 	di, di 
	push 	cs
	pop 	ds
	mov 	si, offset dialog 
	call 	print_str

	; mov 	di, 160 - 140 + pos1
	xor 	ax, ax
	int 	16h
	cmp 	ah, 1
	jz 	exit

	mov 	byte ptr cs:char1, al
	inc 	pos1
	inc 	pos1

	xor 	ax, ax
	mov 	ds, ax
	push 	cs
	pop 	es
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
my_end:
	mov 	cx, offset begin
	mov 	es, bx
	xor 	di, di
	push 	cs
	pop 	ds
	xor 	si, si
_loop:
	movsb
	loop 	_loop

	cli
	xor 	ax, ax
	mov 	ds, ax
	mov 	ds:[34], bx
	sti
	inc 	bh

	jmp 	big_loop
exit:
	retf

print_str proc
	mov 	ah, 0ah
print_loop:
	lodsb
	cmp 	al, 0
	jz 	_coninue
	stosw
	jmp 	print_loop
_coninue:
	ret
print_str endp

begin	 endp
end _start