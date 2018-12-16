.globl _start
.data
tmp_number:		.skip 100
unary_minus:	.ascii "#"
other: 	.ascii "w"
bad:	.ascii "-\n"
my_str:	.ascii "#123"
zero:	.byte 0x21
.text
_start:
	lea	my_str, %rsi
	lea	tmp_number, %rdi
	mov 	$4, %rcx
	rep movsb
	call 	_parse_to_int
	nop
	jmp 	_exit

_parse_to_int:
	lea 	tmp_number, %rsi	# Берём адрес начала строки с числом
	lea 	unary_minus, %rdi	# Адрес символа, отвечающего за унарный минус
	cmpsb				# Проверяем, не является ли первый символ унарным минусом
	jnz	_ii1
	mov 	$1, %di			# Если является, ставим флаг
	inc	%rsi			# И пропускаем этот минус
_ii1:
	dec 	%rsi
	xorq 	%rax, %rax
	mov 	$10, %rbx		# Основание СС
_ii2:
	mov 	(%rsi), %cl 		# Берём символ из буфера
	cmp 	$0, %cl 		# проверяем, не конец ли это строки
	jz 	_end_number 		

	sub 	$'0', %cl 		# Превращаем символ в число
	mul 	%rbx 			# Умножаем то, что уже есть на основание СС
	add 	%rcx, %rax 		# Добавляем к тому, что уже есть, то что получили на этом шаге
	inc 	%rsi			# Указатель на следующий символ
	jmp 	_ii2 			# Повторяем
_end_number:
	cmp 	$1, %di 		# Все символы из строки обработаны. Если установлен флаг, то
	jnz 	_ii3
	neg 	%rax			# делаем число отрицательным
_ii3:
	ret
# По итогу число лешит в RAX

_exit:
	mov 	$60, %rax
	syscall