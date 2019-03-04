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
_start:
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

	mov	ax, 3		; очистка экрана
	int	10h

db	0eah, 0, 1, 0, 20h	; переброс указателя на адрес, куда кладём программу
org	766
dw	0aa55h
end begin
