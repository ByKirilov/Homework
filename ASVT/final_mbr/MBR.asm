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
greeting 	db 'Hello', 0
empty 		db '::EMPTY::', 0
_start:
	mov	ax, 3		; очистка экрана
	int	10h

	cli
	mov 	ax, 2000h
	mov 	ss, ax
	mov 	sp, 0
	sti
	push 	sp

	mov 	ax, 1000h
	mov 	es, ax
	mov 	bx, 0h

	mov 	ah, 2		; номер прерывания (чтение секторов из памяти)
	mov 	al, 9		; количество сегментов
	mov 	ch, 1		; номер цилиндра
	mov 	cl, 1		; номер сегмента дорожки, с которого начинаем копировать
	mov 	dh, 0		; номер головки
	mov 	dl, 0		; номер диска 
	int 	13h


	mov 	ax, 0b800h
	mov 	es, ax
	mov 	di, 76
; Выводим верхушеньку "Hello"
;	mov 	dx, ds
;	mov 	si, offset greeting
;	mov 	ah, 0ah
;greeting_loop:
;	lodsb
;	cmp 	al, 0
;	jz 	_coninue
;	stosw
;	jmp 	greeting_loop
;_coninue:

	mov 	ax, 0a48h
	stosw
	mov 	ax, 0a65h
	stosw
	mov 	ax, 0a6ch
	stosw
	mov 	ax, 0a6ch
	stosw
	mov 	ax, 0a6fh
	stosw

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
;	push 	si
;	push 	ds
;	mov 	ds, dx
;	mov 	si, offset empty
;	mov 	ah, 0ah
;empty_loop:
;	lodsb
;	cmp 	al, 0
;	jz 	_coninue_big_loop
;	stosw
;	jmp 	empty_loop
;_coninue_big_loop:
;	pop 	ds
;	pop 	si

	mov 	al, 3ah
	stosw
	mov 	al, 3ah
	stosw
	mov 	al, 45h
	stosw
	mov 	al, 4dh
	stosw
	mov 	al, 50h
	stosw
	mov 	al, 54h
	stosw
	mov 	al, 59h
	stosw
	mov 	al, 3ah
	stosw
	mov 	al, 3ah
	stosw
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
;------------------------------------------------------------------------------
	mov 	ax, 2
	mov 	bx, 160
	mul 	bx
	mov 	di, ax
	mov 	ax, 0b800h
	mov 	ds, ax
	mov 	si, di
	xor 	bx, bx
	mov 	cx, 80
light_f_str:
	lodsw
	mov 	ah, 0a0h
	stosw
	loop 	light_f_str
navigation:
	xor 	ah, ah
	int 	16h

	cmp 	ah, 50h ; Down
	jz 	down
	cmp 	ah, 48h ; Up
	jz 	up
	cmp 	ah, 1
	jz 	exit
	jmp 	navigation

up:
	sub 	di, 160
	sub 	si, 160
	mov 	cx, 80
dislight_str_up:
	lodsw
	mov 	ah, 0ah
	stosw
	loop 	dislight_str_up
	sub 	di, 320
	sub 	si, 320
	mov 	cx, 80

	cmp 	di, 160
	jg 	light_str_up
	mov 	di, 3200
	mov 	si, 3200
light_str_up:
	lodsw
	mov 	ah, 0a0h
	stosw
	loop 	light_str_up
	jmp 	navigation

down:
	sub 	di, 160
	sub 	si, 160
	mov 	cx, 80
dislight_str_down:
	lodsw
	mov 	ah, 0ah
	stosw
	loop 	dislight_str_down
	mov 	cx, 80

	cmp 	di, 3360
	jl 	light_str_down
	mov 	di, 320
	mov 	si, 320
light_str_down:
	lodsw
	mov 	ah, 0a0h
	stosw
	loop 	light_str_down

	jmp 	navigation








exit:
	mov	ax, 3		; очистка экрана
	int	10h
	ret
	int 	19h
	ret






;------------------------------------------------------------------------------
	mov 	ax, 2000h
	mov 	es, ax		; сегмент оперативной памяти, куда копируем программу
	mov 	ah, 2		; номер прерывания (чтение секторов из памяти)
	mov 	al, 9		; количество сегментов
	mov 	ch, 2		; номер цилиндра
	mov 	cl, 1		; номер сегмента дорожки, с которого начинаем копировать
	mov 	dh, 0		; номер головки
	mov 	dl, 0		; номер диска 
	mov 	bx, 100h	; смещение оперативной памяти, куда копируем программу
	int 	13h		; вызов прерывания

	mov 	ax, 2000h
	mov 	es, ax
	mov 	ah, 2
	mov 	al, 9
	mov 	ch, 3
	mov 	cl, 1
	mov 	dh, 0
	mov 	dl, 0
	mov 	bx, 1300h
	int 	13h

	

db	0eah, 0, 1, 0, 20h	; переброс указателя на адрес, куда кладём программу
org	766
dw	0aa55h
end begin
