.globl _start
.data
.set 	N, 100
.set	WRITE, 1
.set	EXIT, 60
operation_symbol:	.skip 1
tmp_number:		.skip N
current_numeral:	.skip 1
big_empty: 		.skip N
small_empty: 		.skip 1
numeral_char_tab:	.ascii "0123456789ABCDEF"
numerals_count = 	. - numeral_char_tab
op_add:	.ascii "+"
op_sub:	.ascii "-"
op_mov:	.ascii "*"
op_div:	.ascii "/"
op_unary_minus: .ascii "~"
op_and:	.ascii "&"
op_or:	.ascii "|"
op_xor:	.ascii "#"
op_exp: .ascii "^"
operations_count = . - op_add
hex_prefix:	.ascii "0x"
line_break:	.ascii "\n"
err_messg:	.ascii "Something wrong\n"
lerr_messg = . - err_messg
no_args_exception:	.ascii "No argumets\n"
lno_args_exception = . - no_args_exception
many_operands_exception:	.ascii "Many operands\n"
lmany_operands_exception = . - many_operands_exception
few_operands_exception:	.ascii "Few operands\n"
lfew_operands_exception = . - few_operands_exception
bad_symbol_exceprion:	.ascii "Bad symbol\n"
lbad_symbol_exceprion = . - bad_symbol_exceprion
division_by_zero_exception:	.ascii "Division by zero\n"
ldivision_by_zero_exception = . - division_by_zero_exception

.macro	my_exit	exit_code=0
	mov	$60, %eax
	mov	$\exit_code, %edi
	syscall
.endm

.macro	raise	except_msg=err_messg lexcept_msg=lerr_messg
	mov 	$WRITE, %rax
	mov 	$1, %rdi
	mov 	$\except_msg, %rsi
	mov 	$\lexcept_msg, %rdx
	syscall
	my_exit	1
.endm

.text
_start:
	xorq 	%r10, %r10		# r10 играет роль счётчика количества операндов на стеке
	mov 	(%rsp), %r11
	dec 	%r11 			# r11 показывает сколько аргументов нам передали
	cmp 	$0, %r11
	jnz 	_continue
	raise	no_args_exception, lno_args_exception
_continue:
	lea 	tmp_number, %r12 	# r12 - указатель на конец строки tmp_number
	mov	$2, %r13
	mov	(%rsp, %r13, 8), %r14	# r14 - текущий аргумент
	jmp 	_parse_argument

_result:
	cmp 	$1, %r10
	jle 	_continue_result
	raise	many_operands_exception, lmany_operands_exception
_continue_result:
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
	lea	op_add, %rdi
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

	lea 	tmp_number, %rax
	sub 	%r12, %rax
	neg 	%rax
	cmp 	$1, %rax
	je 	_continue_grasp_numeral
	raise	bad_symbol_exceprion, lbad_symbol_exceprion
_continue_grasp_numeral:
	lea 	hex_prefix, %rdi
	inc 	%rdi
	cmpsb
	je 	_end_grasp_numeral

	raise	bad_symbol_exceprion, lbad_symbol_exceprion
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
_clear_string:
	rep movsb
	ret
# ---------------------------------------------------
_parse_to_int:
	lea 	tmp_number, %rsi
	xor 	%rax, %rax
	mov 	$2, %rcx
	lea 	hex_prefix, %rdi
	cmpsb
	je 	_set_16
	dec 	%rsi
	mov 	$10, %rbx
	jmp 	_parse_to_int_loop
_set_16:
	inc 	%rsi
	mov 	$16, %rbx
_parse_to_int_loop:
	mov 	(%rsi), %cl
	cmp 	$0, %cl
	jz 	_end_number

	sub 	$'0', %cl
	cmp 	$10, %cl
	jl 	_add_numeral
	sub 	$7, %cl
_add_numeral:
	mul 	%rbx
	add 	%rcx, %rax
	inc 	%rsi
	jmp 	_parse_to_int_loop
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

	dec	%rsi
	lea	op_and, %di
	cmpsb
	je	and_op

	dec	%rsi
	lea	op_or, %di
	cmpsb
	je	or_op

	dec	%rsi
	lea	op_xor, %di
	cmpsb
	je	xor_op

	dec	%rsi
	lea	op_exp, %di
	cmpsb
	je	exp_op
_end_execute_operation:
	call 	_clear_operation_symbol
	jmp 	_continue_parse_argument
# ---------------------------------------------------
add_op:
	cmp	$2, %r10
	jge 	_continue_add
	raise 	few_operands_exception, lfew_operands_exception
_continue_add:
	popq	%rbx
	popq 	%rax
	add 	%rbx, %rax
	pushq	%rax
	dec 	%r10
	jmp 	_end_execute_operation

sub_op:
	cmp	$2, %r10
	jge 	_continue_sub
	raise 	few_operands_exception, lfew_operands_exception
_continue_sub:
	popq	%rbx
	popq 	%rax
	sub 	%rbx, %rax
	pushq	%rax
	dec 	%r10
	jmp 	_end_execute_operation

mul_op:
	cmp	$2, %r10
	jge 	_continue_mul
	raise 	few_operands_exception, lfew_operands_exception
_continue_mul:
	popq	%rbx
	popq 	%rax
	mul 	%rbx
	pushq	%rax
	dec 	%r10
	jmp 	_end_execute_operation

div_op:
	cmp	$2, %r10
	jge 	_continue_div
	raise 	few_operands_exception, lfew_operands_exception
_continue_div:
	xor 	%rcx, %rcx
	popq	%rbx
	popq 	%rax
	test 	%rbx, %rbx
	jnz 	_continue_div2
	raise 	division_by_zero_exception, ldivision_by_zero_exception
_continue_div2:
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
	jge 	_continue_unary_minus
	raise 	few_operands_exception, lfew_operands_exception
_continue_unary_minus:
	popq 	%rax
	neg 	%rax
	pushq 	%rax
	jmp 	_end_execute_operation

xor_op:
	cmp	$2, %r10
	jge 	_continue_xor
	raise 	few_operands_exception, lfew_operands_exception
_continue_xor:
	popq	%rbx
	popq 	%rax
	xor 	%rbx, %rax
	pushq	%rax
	dec 	%r10
	jmp 	_end_execute_operation

and_op:
	cmp	$2, %r10
	jge 	_continue_and
	raise 	few_operands_exception, lfew_operands_exception
_continue_and:
	popq	%rbx
	popq 	%rax
	and 	%rbx, %rax
	pushq	%rax
	dec 	%r10
	jmp 	_end_execute_operation

or_op:
	cmp	$2, %r10
	jge 	_continue_or
	raise 	few_operands_exception, lfew_operands_exception
_continue_or:
	popq	%rbx
	popq 	%rax
	or 	%rbx, %rax
	pushq	%rax
	dec 	%r10
	jmp 	_end_execute_operation

exp_op:
	cmp	$2, %r10
	jge 	_continue_exp
	raise 	few_operands_exception, lfew_operands_exception
_continue_exp:
	popq	%rbx
	popq 	%rcx
	mov 	$1, %rax
	cmp 	$0, %rbx
	jg	_exp_loop
	je 	_exp_save
	mov 	$0, %rax
	jmp 	_exp_save
_exp_loop:
	mul 	%rcx
	dec 	%rbx
	jnz 	_exp_loop
_exp_save:
	pushq	%rax
	dec 	%r10
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
	my_exit
