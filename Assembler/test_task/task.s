.globl _start
.data
.set 	N, 100
.set	WRITE, 1
.set	EXIT, 60
operands_count:		.word 0
operation_symbol:	.ascii "?"
tmp_number:		.skip N
current_number:		.quad 0
current_numeral:	.byte 0
numeral_char_tab:	.ascii "0123456789"
operration_char_tab:	.ascii "+-*/#"
op_add:	.ascii "+"
op_sub:	.ascii "-"
op_mov:	.ascii "*"
op_div:	.ascii "/"
err_messg:	.ascii "Something wrong\n"
lerr_messg = . - err_messg
.text
_start:
	

_parse_to_int:
	lea 	tmp_number, %rsi
	jmp	_ii1
_ii1:
	xor 	%rax, %rax
	mov 	$10, %rbx
_ii2:
	mov 	(%rsi), %cl
	cmp 	$0, %cl
	jz 	_end_number

	sub 	$'0', %cl
	mul 	%rbx
	add 	%rcx, %rax
	inc 	%rsi
	jmp 	_ii2
_end_number:
	ret

add_op:
	popq	%rax
	popq 	%rbx
	add 	%rbx, %rax
	pushq	%rax
	ret
sub_op:
	popq	%rax
	popq 	%rbx
	sub 	%rbx, %rax
	pushq	%rax
	ret
mul_op:
	popq	%rax
	popq 	%rbx
	mul 	%rbx
	pushq	%rax
	ret
div_op:
	popq	%rax
	popq 	%rbx
	div 	%rbx
	pushq 	%rax
	ret
_error:
	mov	$WRITE, %rax
	mov	$1, %rdi
	lea	err_messg, %rsi
	mov	$lerr_messg, %rdx
	syscall
	jmp	_exit
_exit:
	mov	$EXIT, %rax
	mov	$0, %rdi
	syscall
_numprint:
	xor	%rcx, %rcx
	movq	$10, %rbx
1:
	xorq	%rdx, %rdx
	div	%rbx
	pushq	%rdx
	inc	%rcx
	testq	%rax, %rax
	jnz	1b
2:
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
	jnz	2b
	lea 	line_break, %rsi
	mov 	$WRITE, %rax
	mov 	$1, %rdi
	mov 	$1, %rdx
	syscall
	jmp	_exit