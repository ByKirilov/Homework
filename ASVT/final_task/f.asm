.model tiny
.code
org 100h
locals @@
_start:
main	proc near
	mov	ax, 6
	int	10h
	mov	bp, lines_count
	mov	si, offset buffer
	mov	ax, 0b800h
	mov	es, ax
	xor	dx, dx
@@1:
	cmp	byte ptr cs:is_pause, 1
	jz	@@3
	cmp	dx, 99
	jl	@@2
	cmp	byte ptr cs:is_scrolling, 0
	mov	byte ptr cs:is_scrolling, 1
	jz	@@2
	call	scroll
@@2:
	call	print_2_lines

	cmp	dx, 99
	jge	@@3
	inc	dx
@@3:
	call	i_wait
	cmp	byte ptr cs:is_pause, 0
	jnz	@@1

	cmp	si, offset buffer -1
	jne	@@4
	mov	si, last_byte_off
	add	si, offset buffer
	jmp	@@10
@@4:
	mov	ax, offset buffer -1
	add	ax, last_byte_off
	mov	bx, si
	cmp	bx, ax
	jne	@@5
	mov	si, offset buffer
@@5:
	mov	ax, offset buffer +1
	add	ax, last_byte_off
	mov	bx, si
	cmp	bx, ax
	jne	@@10
	mov	si, offset buffer
@@10:
	jmp	@@1
main 	endp
print_2_lines 	proc near
	cmp	byte ptr cs:revers_scroll, 1
	jnz	@@1
	call	up_print
	jmp	@@10
@@1:
	call	down_print
@@10:
	ret
print_2_lines endp
up_print 	proc near
	std
	mov	di, 2000h+79
	xor 	ax, ax
	lodsb
	mov 	bx, 80
	sub 	bx, ax
	sub 	di, bx
	mov 	cx, ax
	rep 	movsb
	dec 	si
	mov 	di, 79
	xor 	ax, ax
	lodsb
	mov 	bx, 80
	sub 	bx, ax
	sub 	di, bx
	mov 	cx, ax
	rep 	movsb
	dec 	si
	cld
	ret
up_print endp
down_print	proc near
	push	dx
	push	es
	push	ds
	pop	es
	mov	di, offset current_line
	xor	ax, ax
	lodsb
	mov	cx, ax
	rep	movsb
	inc	si
	call	rot
	mov	ax, 80
	mul	dl
	mov	di, ax
	mov	bx, di
	add	bx, 2000h
	mov	cx, 80
	pop	es
	push	si
	mov	si, offset current_line
	rep	movsb
	call	clear_cur_line
	call	upd_shift


	pop	si
	push	es
	push	ds
	pop	es
	mov	di, offset current_line
	xor	ax, ax
	lodsb
	mov	cx, ax
	rep	movsb
	inc	si
	call	rot
	mov	di, bx
	mov	cx, 80
	pop	es
	push	si
	mov	si, offset current_line
	rep	movsb
	call	clear_cur_line
	call	upd_shift
	pop	si
	pop	dx
	ret
down_print endp
upd_shift	proc near
	mov	ax, word ptr cs:d_shift
	add	word ptr cs:shift, ax
	jz	@@1
	jmp	@@2
@@1:
	neg	word ptr cs:d_shift
	mov	al, byte ptr cs:to_left
	xchg	byte ptr cs:to_right, al
	mov	byte ptr cs:to_left, al
	jmp	@@10
@@2:
	cmp	word ptr cs:shift, 640
	jle	@@10
	mov	ax, 640
	sub	word ptr cs:shift, ax
@@10:
	ret
upd_shift endp
clear_cur_line 	proc near
	push	di
	push	cx
	push	ax
	push	es
	push	ds
	pop	es
	mov	di, offset current_line
	xor	ax, ax
	mov	cx, 80
	rep	stosb
	pop	es
	pop	ax
	pop	cx
	pop	di
	ret
clear_cur_line endp
rot 	proc near
	push	es
	push	si
	push	di
	push	cx
	push	ax
	push	bx
	push	dx
	cmp	word ptr cs:shift, 0
	jz	@@10
	cmp	byte ptr cs:to_right, 1
	jnz	@@1
	call	rot_r
	jmp	@@10
@@1:
	cmp	byte ptr cs:to_left, 1
	jnz	@@10
	call	rot_l
@@10:
	pop	dx
	pop	bx
	pop	ax
	pop	cx
	pop	di
	pop	si
	pop	es
	ret
rot endp
rot_l 	proc near
	push 	ds
	pop 	es
	mov 	cx, shift
@@1:
	push 	cx
	mov 	si, offset current_line
	mov 	di, offset current_line
	lodsb
	mov 	bl, al
	xor 	cx, cx
	mov 	cl, 7
	shr 	bl, cl
	shl 	al, 1
	mov 	dh, al
	mov 	cx, 79
@@2:
	push 	cx
	lodsb
	mov 	dl, al
	mov 	bh, al
	xor 	cx, cx
	mov 	cl, 7
	shr 	dl, cl
	or 	dh, dl
	mov 	al, dh
	stosb
	shl 	bh, 1
	mov 	dh, bh
	pop 	cx
	loop 	@@2
	or 	dh, bl
	mov 	al, dh
	stosb
	pop 	cx
	loop 	@@1
@@10:
	ret
rot_l endp
rot_r 	proc near
	push 	ds
	pop 	es
	mov 	cx, shift
@@1:
	push 	cx
	mov 	si, offset current_line
	mov 	di, offset current_line
	xor 	dx, dx
	mov 	cx, 80
@@2:
	push 	cx
	lodsb
	mov 	bh, al
	shr 	bh, 1
	or 	bh, dl
	mov 	dl, al
	mov 	al, bh
	stosb
	xor 	cx, cx
	mov 	cl, 7
	shl 	dl, cl
	pop 	cx
	loop 	@@2
	mov 	si, offset current_line
	mov 	di, offset current_line
	lodsb
	or 	bh, dl
	mov 	al, bh
	stosb
	pop 	cx
	loop 	@@1
@@10:
	ret
rot_r endp
scroll 	proc near
	push 	ds
	push 	si
	push 	es
	pop 	ds
	cmp 	byte ptr cs:revers_scroll, 1
	jz 	@@1
	call 	down_scroll
	jmp 	@@10
@@1:
	call 	up_scroll
@@10:
	pop 	si
	pop 	ds
	ret
scroll endp
down_scroll	proc near
	mov 	si, 80
	xor 	di, di
	mov 	cx, 7920
	rep 	movsb
	mov 	si, 2000h+80
	mov 	di, 2000h
	mov 	cx, 7920
	rep 	movsb
	xor 	al, al
	mov 	di, 7920
	mov 	cx, 80
	rep 	stosb
	mov 	di, 2000h+7920
	mov 	cx, 80
	rep 	stosb
	ret
down_scroll endp
up_scroll 	proc near
	std
	mov 	si, 7920+79-80
	mov 	di, 7920+79
	mov 	cx, 8000
	rep 	movsb
	mov 	si, 2000h+7920+79-80
	mov 	di, 2000h+7920+79
	mov 	cx, 8000
	rep 	movsb
	xor 	al, al
	mov 	di, 79
	mov 	cx, 80
	rep 	stosb
	mov 	di, 2000h+79
	mov 	cx, 80
	rep 	stosb
	cld
	ret
up_scroll endp
i_wait 	proc near
	hlt
	push 	ax
	mov 	ah, 1
	int 	16h
	pop 	ax
	jz 	@@10
	xor 	ax, ax
	int 	16h
	call 	scan_test
@@10:
	ret
i_wait endp
scan_test 	proc near
	push 	ax
	push 	bx
	push 	si
	mov 	bx, ax
	mov 	si, offset scan_table
@@1:
	lodsw
	cmp 	ax, 0
	jz 	@@3
	cmp 	al, bh
	jz 	@@2
	add 	si, 2
	jmp 	@@1
@@2:
	lodsw
	call 	ax
@@3:
	pop 	si
	pop 	bx
	pop 	ax
	ret
scan_test endp
do_exit proc near
	mov 	ax, 3
	int 	10h
	int 	20h
do_exit endp
start_stop proc near
	cmp 	byte ptr cs:is_pause, 0
	jz 	@@1
	mov 	byte ptr cs:is_pause, 0
	ret
@@1:
	mov 	byte ptr cs:is_pause, 1
	ret
start_stop endp
do_left proc near
	cmp 	byte ptr cs:to_left, 1
	jz 	@@10
	cmp 	byte ptr cs:to_right, 1
	jnz 	@@1
	mov 	word ptr cs:d_shift, -1
	jmp 	@@10
@@1:
	mov 	byte ptr cs:to_left, 1
	mov 	word ptr cs:d_shift, 1
	mov 	word ptr cs:shift, 1
@@10:
	ret
do_left endp
do_right proc near
	cmp 	byte ptr cs:to_right, 1
	jz 	@@10
	cmp 	byte ptr cs:to_left, 1
	jnz 	@@1
	mov 	word ptr cs:d_shift, -1
	jmp 	@@10
@@1:
	mov 	byte ptr cs:to_right, 1
	mov 	word ptr cs:d_shift, 1
	mov 	word ptr cs:shift, 1
@@10:
	ret
do_right endp
do_up proc 
	cmp 	byte ptr cs:revers_scroll, 1
	jz 	@@10
	pop 	bx
	pop 	si
	mov 	byte ptr cs:revers_scroll, 1
	mov 	byte ptr cs:is_scrolling, 1
	mov 	dx, 99
	std
	mov 	cx, 200
@@1:
	dec 	si
	cmp 	si, offset buffer-1
	jne 	@@2
	mov 	si, offset buffer
	add 	si, last_byte_off
@@2:
	xor 	ax, ax
	lodsb
	sub 	si, ax
	loop 	@@1
	dec 	si
	cld
	push 	si
	push 	bx
@@10:
	ret
do_up endp
do_down proc near
	cmp 	byte ptr cs:revers_scroll, 0
	jz 	@@10
	pop 	bx
	pop 	si
	mov 	byte ptr cs:revers_scroll, 0
	mov 	cx, 200
@@1:
	inc 	si
	mov 	ax, offset buffer
	add 	ax, last_byte_off
	inc 	ax
	cmp 	si, ax
	jne 	@@2
	mov 	si, offset buffer
@@2:
	xor 	ax, ax
	lodsb
	add 	si, ax
	loop 	@@1
	inc 	si
	push 	si
	push 	bx
@@10:
	ret
do_down endp
state_shift 	proc near
	mov 	byte ptr cs:to_left, 0
	mov 	byte ptr cs:to_right, 0
	mov 	word ptr cs:d_shift, 0
	ret
state_shift endp
scan_table dw 39h, offset start_stop
	dw 4dh, offset do_right
	dw 4bh, offset do_left
	dw 48h, offset do_up
	dw 50h, offset do_down
	dw 1fh, offset state_shift
	dw 1, 	offset do_exit
	dw 0

is_pause 	db 	0
is_scrolling 	db 	0
to_right 	db 	0
to_left 	db	0
shift 		dw 	0
d_shift		dw 	0
current_line 	db 	80 DUP (0)
revers_scroll	db 	0
lines_count 	dw 	?
last_byte_off	dw 	?
buffer 		db 	?
end _start