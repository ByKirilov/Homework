.model tiny
.code
org 100h
locals
_start:
	cld

	mov	ax, 3		; очистка экрана
	int	10h

	mov	ax, 0b800h	
	mov	es, ax		; переброс указателя сегмента на консоль
	mov 	ds, ax		; то же самое, но для чтения, т.к. lodsw использует ds:si
	xor 	di, di
_1:
	xor	ah, ah
	int	16h		; ввод символа
	cmp 	di, 3860	; проверка, дошли ли до конца консоли
	jle 	print		; если нет, печатаем

	push 	ax		; сохраняем введённый символ
	mov 	ax, 5		; величина сдвига (строк)
	mov 	bx, 160
	mul 	bx		; умножаем на ширину строки (80*2), чтобы найти символ,
				; с которого начинаем перемещение
	mov 	si, ax		; полученное смещение кладём в si
	xor 	di, di		; di перемещаем в начало консоли
	mov 	cx, 25		
	sub 	cx, 5		; задаем кол-во повтрорений цикла переноса строк
scroll:
	push 	cx		; сохраняем это значение
	mov 	cx, 7		; задаем кол-во повтрорений цикла для переноса одной строки
carry:
	lodsw			; считываем символ на который смотрит si
	stosw			; пишем его туда, куда смотрит di
	loop 	carry		; повторяем

	add 	di, 146		; переносим di на новую строку
	add 	si, 146		; переносим si на новую строку
	pop	cx		; достаём счётчик внешнего цикла
	loop 	scroll		; повторяем
				; теперь чистим низ
	mov 	cx, 5		; кладём в счётчик, сколько строк надо почистить
	push 	di		; сохраняем текущую позицию di, потому что писать следующие символы будем оттуда
clear:
	push 	cx		; сохраняем счётчик цикла
	mov 	cx, 7		; кладём в счётчик, сколько символов в строке надо почистить
clear_str:
	mov	ax, 0020h	; пишем пробел
	stosw
	loop 	clear_str	; повторяем
	add 	di, 146		; идём на следующую строку

	pop 	cx		; достаём счётчик внешнего цикла
	loop 	clear		; повторяем

	pop 	di		; возвращаем позицию с которой печатать

	pop 	ax		; достаём символ, который печатать
;---------------------------------
print:
	mov 	bx, ax
	mov	ah, 0ah
	stosw
	add 	di, 2

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

	add 	di, 2

	mov 	cl, bh
	sar 	cl, 4
	add 	cl, 30h
	cmp 	cl, 3ah
	jl 	_4
	add 	cl, 07h
_4:
	mov 	al, cl
	stosw

	mov 	cl, bh
	and 	cl, 0fh
	add 	cl, 30h
	cmp 	cl, 3ah
	jl 	_5
	add 	cl, 07h
_5:
	mov 	al, cl
	stosw	

	add	di, 146

	cmp 	bh, 1
	jz 	_6

	jmp 	_1
_6:
	int	19h
end _start
