.globl _start
.data
.set 	N, 100
.set	WRITE, 1
.set	EXIT, 60
operands_count:		.word 0
operation_symbol:	.skip 1
tmp_number:		.skip N
current_numeral:	.skip 1
big_empty: 		.skip N
small_empty: 		.skip 1
current_number:		.quad 0
numeral_char_tab:	.ascii "0123456789"
numerals_count = 	. - numeral_char_tab
operation_char_tab:	.ascii "+-*/#"
operations_count = 	. - operation_char_tab
op_add:	.ascii "+"
op_sub:	.ascii "-"
op_mov:	.ascii "*"
op_div:	.ascii "/"
op_unary_minus: .ascii "#"
line_break:	.ascii "\n"
err_messg:	.ascii "Something wrong\n"
lerr_messg = . - err_messg

.text
_start:
	xorq 	%r10, %r10		# r10 играет роль счётчика количества операндов на стеке
	mov 	(%rsp), %r11
	dec 	%r11 			# r11 показывает сколько аргументов нам передали
	cmp 	$0, %r11
	jz 	_error

	lea 	tmp_number, %r12 	# r12 - указатель на конец строки tmp_number
	mov	$2, %r13
	mov	(%rsp, %r13, 8), %r14	# r14 - текущий аргумент
	jmp 	_parse_argument

_result:
	cmp 	$1, %r10
	jg 	_error
	popq 	%rax
	jmp 	_numprint
# ---------------------------------------------------
_parse_argument:
	xor 	%rbx, %rbx
	mov 	(%r14), %bl
	cmp 	$0, %bl
	jz 	_end_argument

	call 	_grasp_operation_symbol
	jmp 	_execute_operation
_continue_grasp:
	call 	_grasp_numeral
_continue_parse_argument:
	xor 	%r8, %r8
	inc 	%r14
	jmp 	_parse_argument
_end_argument:
	call 	_push_num_to_stack
	dec 	%r11
	jz 	_result
	add 	$1, %r13
	mov 	%r13, %rdx
	add 	%r10, %rdx
	mov	(%rsp, %rdx, 8), %r14
	jmp 	_parse_argument
# ---------------------------------------------------
 _grasp_operation_symbol:
 	mov 	$operations_count, %r15
	mov 	$1, %rcx
	mov	%r14, %rsi
	lea	operation_char_tab, %rdi
 _grasp_operation_loop:
	cmpsb
	je	_end_grasp_operation
	dec	%rsi
	dec 	%r15
	jnz 	_grasp_operation_loop
	ret
_end_grasp_operation:
	dec 	%rdi
	mov 	%rdi, %rsi
	lea 	operation_symbol, %rdi
	mov 	$1, %rcx
	rep movsb
	ret
# ---------------------------------------------------
_grasp_numeral:
	mov 	$numerals_count, %r15
	mov 	$1, %rcx
	mov 	%r14, %rsi
	lea 	numeral_char_tab, %rdi
_grasp_numeral_loop:
	cmpsb
	je	_end_grasp_numeral
	dec	%rsi
	dec 	%r15
	jnz 	_grasp_numeral_loop
	jmp 	_error
_end_grasp_numeral:
	dec 	%rdi
	mov 	%rdi, %rsi
	mov 	%r12, %rdi
	mov 	$1, %rcx
	rep movsb
	inc 	%r12
	ret
# ---------------------------------------------------
_push_num_to_stack:
	lea 	tmp_number, %rsi
	cmp 	$0, (%rsi)
	jz 	_end_push
	call 	_parse_to_int
	pop 	%rdx
	pushq 	%rax
	push 	%rdx
	inc 	%r10
	call	_clear_tmp_number
_end_push:
	ret
# ---------------------------------------------------
_clear_tmp_number:
	lea	big_empty, %rsi
	lea 	tmp_number, %rdi
	mov 	$N, %rcx
	jmp 	_clear_string
_clear_operation_symbol:
	lea	small_empty, %rsi
	lea 	operation_symbol, %rdi
	mov 	$1, %rcx
	jmp 	_clear_string
_clear_current_numeral:
	lea	small_empty, %rsi
	lea 	current_numeral, %rdi
	mov 	$1, %rcx
	jmp 	_clear_string
_clear_string:
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
	lea 	tmp_number, %r12
	ret
# ---------------------------------------------------
_execute_operation:
	mov 	$operation_symbol, %rsi
	mov 	(%rsi), %cl
	inc 	%cl
	cmp 	$1, %cl
	je 	_continue_grasp

	call 	_push_num_to_stack

	mov 	$operation_symbol, %rsi
	mov 	$1, %rcx
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
	lea	op_unary_minus, %di
	cmpsb
	je	unary_minus
_end_execute_operation:
	call 	_clear_operation_symbol
	jmp 	_continue_parse_argument
# ---------------------------------------------------
add_op:
	cmp	$2, %r10
	jl 	_error
	popq	%rbx
	popq 	%rax
	add 	%rbx, %rax
	pushq	%rax
	dec 	%r10
	jmp 	_end_execute_operation
sub_op:
	cmp	$2, %r10
	jl 	_error
	popq	%rbx
	popq 	%rax
	sub 	%rbx, %rax
	pushq	%rax
	dec 	%r10
	jmp 	_end_execute_operation
mul_op:
	cmp	$2, %r10
	jl 	_error
	popq	%rbx
	popq 	%rax
	mul 	%rbx
	pushq	%rax
	dec 	%r10
	jmp 	_end_execute_operation
div_op:
	cmp	$2, %r10
	jl 	_error
	xor 	%rcx, %rcx
	popq	%rbx
	popq 	%rax
	cmp 	$0, %rax
	jge 	_do_div
	mov 	$1, %rcx
	neg 	%rax
_do_div:
	xor 	%rdx, %rdx
	idiv 	%rbx
	test 	%rcx, %rcx
	jz 	_complete_div
	neg 	%rax
_complete_div:
	pushq 	%rax
	dec 	%r10
	jmp 	_end_execute_operation
unary_minus:
	cmp	$1, %r10
	jl 	_error
	popq 	%rax
	neg 	%rax
	pushq 	%rax
	jmp 	_end_execute_operation
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