.model tiny
.code
org 100h
begin:
	jmp short _start
	nop
operator	db 'MBR.180K'
; BPB
BytesPerSec	dw 200h
SectPerClust	db 1
RsvdSectors	dw 1
NumFATs		db 2
RootEntryCnt	dw 64		; 2 А╔╙Б╝Ю═ ╜═ root dir
TotalSectors	dw 360	
MediaByte	db 0FCh		; 1 ё╝╚╝╒═ 9 А╔╙Б╝Ю╝╒ 40 Ф╗╚╗╜╓Ю╝╒
FATsize		dw 2		; 2 А╔╙Б╝Ю═ ╜═ ╙═╕╓К╘ FAT
SecPerTrk	dw 9
NumHeads	dw 1
HidSec		dw 0, 0
TotSec32	dd 0
DrvNum		db 0
Reserved	db 0
Signatura	db ')'		; 29h
; 
Vol_ID		db 'XDRV'
DiskLabel	db 'TestMBRdisk'
FATtype		db 'FAT12   '
;
; ╗Б╝ё╝ 1 А╔╙Б╝Ю MBR, 4 А╔╙Б╝Ю═ FATК ╗ 2 А╔╙Б╝Ю═ rootDir
; Б.╝. ╖═╜ОБ╝ 7 А╔╙Б╝Ю╝╒
; ╔И╔ 2 А ╜Ц╚╔╒╝╘ ╓╝Ю╝ё╗ ╖═╘╛╔╛ ╜═ А╒╝╘ root dir
;  ╗ ╝АБ═╔БАО 39 ╓╝Ю╝╕╔╙ ╜═ Д═╘╚К (╒╙╚НГ═О А╒╝╘ ╖═ёЮЦ╖Г╗╙)
;
greeting 	db 'Hi!', 0		; 7c3eh
empty 		db '::EMPTY::', 0	; 7c44h
navigation_text db 18h, ' - up, ', 19h, ' - down, Enter - Start', 0 ; 7c4ch
; Navig_text 	db 'Navigation', 0	; 7c4eh
; Up_arr		db 18h, ' - up', 0	; 7c59h
; Down_arr	db 19h, ' - down', 0	; 7c60h
; start_prog	db 'Enter - Start', 0	; 7c69h

_start:
	xor 	ax, ax
	mov 	ds, ax
	mov	ax, 3		; очистка экрана
	int	10h

	cli
	mov 	ax, 2000h
	mov 	ss, ax
	xor 	sp, sp
	sti
	push 	sp

	mov 	ax, 1000h
	mov 	ch, 1		; номер цилиндра
	xor 	bx, bx
	call 	load_from_mem


	mov 	ax, 0b800h
	mov 	es, ax
	mov 	di, 76
; Выводим верхушеньку "Hello"
	mov 	si, 7c3eh
	call 	print_str

; Вивели
	mov 	ax, 1000h
	mov 	ds, ax
	xor 	si, si
	mov 	di, 166

	mov 	ah, 0ah
	mov 	cx, 19
; Большой цикл, в котором выводим содержимое
_loop:
	add 	di, 160
	push 	di
	push 	cx

	mov 	bx, 20
	sub 	bx, cx

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
; пробел, тире, пробел
	mov 	al, 20h
	stosw
	mov 	al, 2dh
	stosw
	mov 	al, 20h
	stosw

	add 	si, 242
	push 	si
	sub 	si, 242


	lodsb 

	cmp 	al, 0ffh
	je 	_read_file_info
; Написать строку '::EMPTY::'
	push 	si
	push 	ds
	xor 	dx, dx
	mov 	ds, dx
	mov 	si, 7c44h
	call 	print_str
	pop 	ds
	pop 	si
	jmp 	_new_iter

_read_file_info:
	lodsb
	xor 	cx, cx
	mov 	cl, al
_read_file_info_loop:
	lodsb
	stosw
	loop 	_read_file_info_loop
_new_iter:
	pop 	si
	pop 	cx
	pop 	di
	loop 	_loop
; Footer
	xor 	ax, ax
	mov 	ds, ax 
	mov 	di, 3574
	mov 	si, 7c4ch
	call 	print_str
;------------------------------------------------------------------------------
	mov 	ax, 0b800h
	mov 	ds, ax
	mov 	di, 320
	mov 	si, di
	mov 	ch, 2
	mov 	ah, 0a0h
	call 	c_light_str
navigation:
	xor 	ah, ah
	int 	16h

	cmp 	ah, 50h ; Down
	jz 	down
	cmp 	ah, 48h ; Up
	jz 	up
	cmp 	ah, 1ch
	jz 	_enter
	cmp 	ah, 1
	jz 	exit
	jmp 	navigation

up:
	; sub 	di, 160
	; sub 	si, 160
	dec 	si
	dec 	di
	dec 	si
	dec 	di
	std
	mov 	ah, 0ah
	call 	c_light_str
	cmp 	di, 320
	mov 	ah, 0a0h
	jg 	light_str_up
	mov 	di, 3358
	mov 	si, 3358
	mov 	ch, 40
light_str_up:
	call 	c_light_str
	add 	di, 162
	add 	si, 162
	cld
	sub 	ch, 2
	jmp 	navigation

down:
	sub 	di, 160
	sub 	si, 160
	mov 	ah, 0ah
	call 	c_light_str

	cmp 	di, 3360
	mov 	ah, 0a0h
	jl 	light_str_down
	mov 	di, 320
	mov 	si, 320
	xor 	ch, ch
light_str_down:
	call 	c_light_str
	add 	ch, 2
	jmp 	navigation

exit:
	; mov	ax, 3		; очистка экрана
	; int	10h
	; ret
	int 	19h
	ret
;----------------
_enter:
	; TODO: сделать проверку на наличие файла

	mov 	ax, 2000h
	mov 	bx, 100h	; смещение оперативной памяти, куда копируем программу
	call 	load_from_mem

	inc 	ch

	mov 	ax, 2000h
	mov 	bx, 1300h
	call 	load_from_mem

	dec 	ch
;--------------------------------
	xor 	di, di
	mov 	al, 0eah
	stosb
	mov 	al, 0c3h
	stosb
	mov 	al, 7dh
	stosb

db	0eah, 0, 1, 0, 20h

	jmp 	_start


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

c_light_str proc
	push 	cx
	mov 	bh, ah
	mov 	cx, 80
c_light_str_loop:
	lodsw
	mov 	ah, bh
	stosw
	loop 	c_light_str_loop
	pop 	cx
	ret
c_light_str endp

load_from_mem proc
	mov 	es, ax		; сегмент оперативной памяти, куда копируем программу
	mov 	ah, 2		; номер прерывания (чтение секторов из памяти)
	mov 	al, 9		; количество сегментов
	mov 	cl, 1		; номер сегмента дорожки, с которого начинаем копировать
	mov 	dh, 0		; номер головки
	mov 	dl, 0		; номер диска 
	int 	13h		; вызов прерывания
	ret
load_from_mem endp



org	766
dw	0aa55h
end begin
