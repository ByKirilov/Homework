.model tiny
.code
org 100h
locals @@
vector equ 9
_start:
jmp 	begin
bufferlen equ 20
buffer 	db bufferlen dup (0)
head 	dw offset buffer
tail 	dw offset buffer
begin proc near
	mov 	di, head
	mov 	al, 31
	stosb
	; mov 	cs:head, 31
	mov 	ax, 12
	mov 	head, ax
	inc 	head
begin endp
end _start