.model tiny
.code
org 100h
locals @@
vector equ 9
_start:
	jmp 	begin

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
	mov 	ax, 65
	call 	Sound
	jmp 	_1
_no_sound:
	call 	No_Sound
	jmp 	_1
_exit:
	ret
end _start