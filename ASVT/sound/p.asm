.model tiny
.code
org 100h
locals @@
vector equ 9
_start:
	jmp 	begin
sound_is_on	db 0

bufferlen equ 20
buffer 	db bufferlen dup (0)
head 	dw offset buffer
tail 	dw offset buffer

int_09 proc near
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
old_09 	dw 	0, 0
int_09 endp

Sound proc near
	push	ax 
	push	bx
	push	dx

	cmp 	bl, 2ch
	jz 	ndo
	cmp 	bl, 2dh
	jz 	nre
	cmp 	bl, 2eh
	jz 	nmi
	cmp 	bl, 2fh
	jz 	nfa
	cmp 	bl, 30h
	jz 	nsol
	cmp 	bl, 31h
	jz 	nla
	cmp 	bl, 32h
	jz 	nsi
	cmp 	bl, 1fh
	jz 	nreb
	cmp 	bl, 20h
	jz 	nmib
	cmp 	bl, 22h
	jz 	nsolb
	cmp 	bl, 23h
	jz 	nlab
	cmp 	bl, 24h
	jz 	nsib
	; jmp 	continue
	ret
continue:
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
; до
ndo:
	mov 	ax, 65 ; 262
	jmp 	continue
; ре
nre:
	mov 	ax, 73 ; 294
	jmp 	continue
; ми
nmi:
	mov 	ax, 82 ; 330
	jmp 	continue
; фа
nfa:
	mov 	ax, 87 ; 349
	jmp 	continue
; соль
nsol:
	mov 	ax, 98 ; 392
	jmp 	continue
; ля
nla:
	mov 	ax, 110 ; 440
	jmp 	continue
; си
nsi:
	mov 	ax, 123 ; 394
	jmp 	continue
; ребимоль
nreb:
	mov 	ax, 69 ; 262
	jmp 	continue
; мибимоль
nmib:
	mov 	ax, 78 ; 262
	jmp 	continue
; сольбимоль
nsolb:
	mov 	ax, 92 ; 262
	jmp 	continue
; лябимоль
nlab:
	mov 	ax, 104 ; 262
	jmp 	continue
; сибимоль
nsib:
	mov 	ax, 117 ; 262
	jmp 	continue

Sound endp

No_Sound proc near
	push 	ax
	in	al, 61h
	and	al, not 3
	out	61h, al
	pop	ax
	ret
No_Sound endp


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
	inc 	head
	cmp 	head, offset buffer + bufferlen
	jnz 	@@1
	mov 	head, offset buffer
@@1:
	xor 	ax, ax
	xor 	bx, bx
	mov 	ax, cs:head 	
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

begin proc near
	mov 	si, 4*vector
	mov 	di, offset old_09
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
	mov 	ax, offset int_09
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
	cmp 	bl, 1
	jz 	exit

	cmp 	bl, 0ach
	jz 	sound_off
	cmp 	bl, 0adh
	jz 	sound_off
	cmp 	bl, 0aeh
	jz 	sound_off
	cmp 	bl, 0afh
	jz 	sound_off
	cmp 	bl, 0b0h
	jz 	sound_off
	cmp 	bl, 0b1h
	jz 	sound_off
	cmp 	bl, 0b2h
	jz 	sound_off
	cmp 	bl, 9fh
	jz 	sound_off
	cmp 	bl, 0a0h
	jz 	sound_off
	cmp 	bl, 0a2h
	jz 	sound_off
	cmp 	bl, 0a3h
	jz 	sound_off
	cmp 	bl, 0a4h
	jz 	sound_off
	cmp 	bl, 9ch
	jz 	sound_off

	
	cmp 	sound_is_on, 0ffh
	jz 	@@2
	mov 	byte ptr cs:sound_is_on, 0ffh
	call 	Sound
	jmp 	@@2

sound_off:
	call 	No_Sound
	mov 	byte ptr cs:sound_is_on, 0
	jmp 	@@2

exit:
	call 	No_Sound
	push 	0
	pop 	es
	mov 	di, 4*vector
	push 	cs
	pop 	ds
	mov 	si, offset old_09
	cli
	movsw
	movsw
	sti
	pop 	es
	ret
begin endp
end _start