.globl _start
.data
.set 	N, 10
.set	WRITE, 1
empty:	.skip N
tmp_number:		.skip N
operation_symbol:	.skip 1
operands_count: 	.byte 0x0
unary_minus:	.ascii "#"
minus: 	.ascii "-"
other: 	.ascii "w"
bad:	.ascii "-\n"
my_str:	.ascii "#123"
zero:	.ascii "!"
n_l: 	.ascii "\n"
char_tab:	.ascii "0123456789"
operation_char_tab:	.ascii "+-*/#"
operations_count = 	. - operation_char_tab
.text
_start:
	lea 	char_tab, %rsi
	inc 	%rsi
	inc 	%rsi
	inc 	%rsi
	inc 	%rsi
	lea 	char_tab, %rax
	sub 	%rsi, %rax
	neg 	%rax
	nop
_exit:
 	mov  $60, %rax
 	syscall

 _grasp_operation_symbol:
 	mov 	$operations_count, %rbx
	mov 	$1, %rcx
	mov	%r8, %rsi
	lea	operation_char_tab, %rdi
 _grasp_operation_loop:
	cmpsb
	je	_end_grasp_operation
	dec	%rsi
	dec 	%rbx
	jnz 	_grasp_operation_loop
	ret
_end_grasp_operation:
	dec 	%rdi
	mov 	%rdi, %rsi
	lea 	operation_symbol, %rdi
	mov 	$1, %rcx
	rep movsb
	ret
_execute_operation:



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