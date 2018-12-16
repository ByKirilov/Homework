.globl _start
.data
.set 	N, 10
.set	WRITE, 1
empty:	.skip N
tmp_number:		.skip N
operands_count: 	.byte 0x0
unary_minus:	.ascii "#"
minus: 	.ascii "-"
other: 	.ascii "w"
bad:	.ascii "-\n"
my_str:	.ascii "#123"
zero:	.ascii "!"
n_l: 	.ascii "\n"
char_tab:	.ascii "0123456789"
.text
_start:
	lea 	my_str, %rsi
 	lea 	tmp_number, %rdi
 	mov 	$4, %rcx
 	rep movsb
 	call  	_parse_to_int
 	jmp 	_numprint
 	jmp  	_exit

_parse_to_int:
 	lea  	tmp_number, %rsi # Берём адрес начала строки с числом
 	lea  	unary_minus, %rdi # Адрес символа, отвечающего за унарный минус
 	cmpsb    # Проверяем, не является ли первый символ унарным минусом
 	jnz 	_ii1
 	mov  	$1, %di   # Если является, ставим флаг
 	inc 	%rsi   # И пропускаем этот минус
_ii1:
 	dec  	%rsi
 	xorq  	%rax, %rax
 	mov  	$10, %rbx  # Основание СС
_ii2:
 	mov  	(%rsi), %cl   # Берём символ из буфера
 	cmp  	$0, %cl   # проверяем, не конец ли это строки
 	jz  	_end_number   

 	sub  	$'0', %cl   # Превращаем символ в число
 	mul  	%rbx    # Умножаем то, что уже есть на основание СС
 	add  	%rcx, %rax   # Добавляем к тому, что уже есть, то что получили на этом шаге
 	inc  	%rsi   # Указатель на следующий символ
 	jmp  	_ii2    # Повторяем
_end_number:
 	cmp  	$1, %di   # Все символы из строки обработаны. Если установлен флаг, то
 	jnz  	_ii3
 	neg  	%rax   # делаем число отрицательным
_ii3:
 	ret
# По итогу число лешит в RAX

_exit:
 	mov  $60, %rax
 	syscall

_numprint:
	cmp 	$0, %rax 	# Проверяем знак числа
	jge 	_0b
	pushq 	%rax 		# Если отрицательное, сохраняем rax
	mov 	$WRITE, %rax
	mov 	$1, %rdi
	mov 	$minus, %rsi
	mov 	$1, %rdx
	syscall			# Печатаем минус
	popq 	%rax 		# Возвращаем rax на место
	neg 	%rax 		# Переводим число в положительное
_0b:
	xor	%rcx, %rcx
	movq	$10, %rbx
_1b:
	xorq	%rdx, %rdx
	div	%rbx
	pushq	%rdx
	inc	%rcx
	testq	%rax, %rax
	jnz	_1b
_2b:
	popq	%rax
	lea	char_tab, %rsi
	add 	%rax, %rsi
	push 	%rcx
	mov 	$WRITE, %rax
	mov 	$1, %rdi
	mov 	$1, %rdx
	syscall
	pop 	%rcx
	dec	%rcx
	jnz	_2b
	lea 	n_l, %rsi
	mov 	$WRITE, %rax
	mov 	$1, %rdi
	mov 	$1, %rdx
	syscall
	jmp	_exit