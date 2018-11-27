.globl _start
.data
char_tab:	.ascii "0123456789"
op:	.ascii "*"	# знак операции
f_num 	= 10
s_num	= 2
op_add:	.ascii "+"
op_sub:	.ascii "-"
op_mov:	.ascii "*"
op_div:	.ascii "/"
line_breake:	.ascii "\n"
.text
_start:
	mov 	$1, %rcx
	lea	op, %rsi
	lea	op_add, %rdi
	cmpsb
	je	add_op
	dec	%rsi
	lea	op_sub, %di
	cmpsb
	je	sub_op
	dec	%rsi
	lea	op_mov, %di
	cmpsb
	je	mul_op
	dec	%rsi
	lea	op_div, %di
	cmpsb
	je	div_op
	dec	%rsi
	jmp	_exit
add_op:
	mov	$f_num, %rax
	add 	$s_num, %rax
	jmp	_numprint
sub_op:
	mov 	$f_num, %rax
	sub 	$s_num, %rax
	jmp 	_numprint
mul_op:
	mov 	$f_num, %rax
	mov 	$s_num, %rbx
	mul 	%rbx
	jmp 	_numprint
div_op:
	mov 	$f_num, %rax
	mov 	$s_num, %rbx
	div 	%rbx
	jmp 	_numprint
_exit:
	mov		$60, %rax	# Аргументы для выхода
	mov		$0, %rdi	# -
	syscall

_numprint:
	xor	%rcx, %rcx
	movq	$10, %rbx
1:
	xorq	%rdx, %rdx
	div		%rbx
	pushq	%rdx
	inc	%rcx
	testq	%rax, %rax
	jnz	1b
2:
	popq	%rax
	lea	char_tab, %rsi
	add 	%rax, %rsi
	push 	%rcx
	mov 	$1, %rax
	mov 	$1, %rdi
	mov 	$1, %rdx
	syscall
	pop 	%rcx
	dec	%rcx
	jnz	2b
	lea 	line_breake, %rsi
	mov 	$1, %rax
	mov 	$1, %rdi
	mov 	$1, %rdx
	syscall
	jmp	_exit