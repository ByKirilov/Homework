.globl _start
.data
.set 	N, 100
.set	WRITE, 1
.set	EXIT, 60
operands_count:		.word 0
operation_symbol:	.ascii "?"
tmp_number:		.skip N
empty: 			.skip N
current_number:		.quad 0
current_numeral:	.byte 0
numeral_char_tab:	.ascii "0123456789"
operration_char_tab:	.ascii "+-*/#"
op_add:	.ascii "+"
op_sub:	.ascii "-"
op_mov:	.ascii "*"
op_div:	.ascii "/"
line_break:	.ascii "\n"
err_messg:	.ascii "Something wrong\n"
lerr_messg = . - err_messg
.text
_start:
	xorq 	%r10, %r10


_push_num_to_stack:
	lea 	tmp_number, %rsi
	cmp 	$0, (%rsi)
	jz 	_end_push
	call 	_parse_to_int
	pushq 	%rax
	inc 	%r10
	call	_clear_string
_end_push:
	ret
# ---------------------------------------------------
_clear_string:
	lea	empty, %rsi
	lea 	tmp_number, %rdi
	mov 	$N, %rcx
	rep movsb
	ret
# ---------------------------------------------------
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
# ---------------------------------------------------
add_op:
	cmp	$2, %r10
	jl 	_error
	popq	%rax
	popq 	%rbx
	add 	%rbx, %rax
	pushq	%rax
	ret
sub_op:
	cmp	$2, %r10
	jl 	_error
	popq	%rax
	popq 	%rbx
	sub 	%rbx, %rax
	pushq	%rax
	ret
mul_op:
	cmp	$2, %r10
	jl 	_error
	popq	%rax
	popq 	%rbx
	mul 	%rbx
	pushq	%rax
	ret
div_op:
	cmp	$2, %r10
	jl 	_error
	popq	%rax
	popq 	%rbx
	div 	%rbx
	pushq 	%rax
	ret
unary_minus:
	cmp	$1, %r10
	jl 	_error
	popq 	%rax
	neg 	%rax
	pushq 	%rax
# ---------------------------------------------------
_error:
	mov	$WRITE, %rax
	mov	$1, %rdi
	lea	err_messg, %rsi
	mov	$lerr_messg, %rdx
	syscall
	jmp	_exit
# ---------------------------------------------------
_exit:
	mov	$EXIT, %rax
	mov	$0, %rdi
	syscall
# ---------------------------------------------------
_numprint:
	cmp 	$0, %rax
	jge 	_0b
	pushq 	%rax
	mov 	$WRITE, %rax
	mov 	$1, %rdi
	mov 	$op_sub, %rsi
	mov 	$1, %rdx
	syscall
	popq 	%rax
	neg 	%rax
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
	lea	numeral_char_tab, %rsi
	add 	%rax, %rsi
	push 	%rcx
	mov 	$WRITE, %rax
	mov 	$1, %rdi
	mov 	$1, %rdx
	syscall
	pop 	%rcx
	dec	%rcx
	jnz	_2b
	lea 	line_break, %rsi
	mov 	$WRITE, %rax
	mov 	$1, %rdi
	mov 	$1, %rdx
	syscall
	jmp	_exit