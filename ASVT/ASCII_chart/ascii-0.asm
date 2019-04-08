.model tiny
.code
org 100h
space	equ 20h
vert 	equ 0b3h
d_vert 	equ 0bah
horiz	equ 0c4h
d_horiz	equ 0cdh
lu_corn	equ 0c9h
ru_corn	equ 0bbh
ld_corn	equ 0c8h
rd_corn	equ 0bch
duu_corn	equ 0d1h
dud_corn	equ 0cfh
cross	equ 0c5h
dul_corn	equ 0c7h
dur_corn	equ 0b6h

i_width	equ 37
i_height	equ 20

locals @@
_start:
jmp 	begin
print_num proc near
	and 	bl, 0fh
	add 	bl, 30h
	cmp 	bl, 3ah
	jl 	@@3
	add 	bl, 07h
@@3:
	mov 	al, bl
	stosw
	ret
print_num endp
begin:
	mov 	ax, 3
	int 	10h

	mov 	ax, 0b800h
	mov 	es, ax
	mov 	di, 48
	mov 	ah, 1eh

	mov 	cx, i_width - 4
	mov 	al, lu_corn
	stosw
	mov 	al, d_horiz 
	stosw
	mov 	al, duu_corn
	stosw
	mov 	al, d_horiz 
upper_border:
	stosw
	loop 	upper_border
	mov 	al, ru_corn
	stosw
	add 	di, 86

	mov 	al, d_vert
	stosw
	mov 	al, space 
	stosw
	mov 	al, vert
	stosw
	mov 	al, space 
	stosw
	mov 	cx, 16
horiz_num:
	mov 	bx, 16
	sub 	bx, cx
	call 	print_num
	mov 	al, 20h
	stosw
	loop 	horiz_num
	mov 	al, d_vert
	stosw
	add 	di, 86

	mov 	al, dul_corn
	stosw
	mov 	al, horiz
	stosw
	mov 	al, cross
	stosw
	mov 	cx, i_width - 4
	mov 	al, horiz
_separator:
	stosw
	loop _separator
	mov 	al, dur_corn
	stosw
	add 	di, 86

	xor 	dl, dl
	mov 	cx, 16
table_outer_loop:
	mov 	al, d_vert
	stosw
	mov 	bx, 16
	sub 	bx, cx
	call 	print_num
	mov 	al, vert
	stosw
	mov 	al, space
	stosw
	push 	cx
	mov 	cx, 16
tabel_inner_loop:
	mov 	al, dl
	stosw
	mov 	al, space
	stosw
	inc 	dl
	loop 	tabel_inner_loop
	pop 	cx
	mov 	al, d_vert
	stosw
	add 	di, 86
	loop 	table_outer_loop

	mov 	al, ld_corn 
	stosw
	mov 	al, d_horiz 
	stosw
	mov 	al, dud_corn
	stosw
	mov 	cx, i_width - 4
	mov 	al, d_horiz
down_border:
	stosw
	loop 	down_border
	mov 	al, rd_corn
	stosw


	xor 	ax, ax
	int 	16h
	retf
	ret



end _start