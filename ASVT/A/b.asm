.model tiny
.code
org 100h
locals
_start:
	mov	ax, 0b800h
	mov 	es, ax
	mov 	di, 1994
	mov 	ax, 0e41h
	stosw
	xor 	ah, ah
	int 	16h
;
;	int 	19h
	ret
end _start