.data
# .set	N, 100
.set	OPEN, 2
.set 	CLOSE, 3
.set	READ, 0
.set	WRITE, 1
.set	O_RDONLY, 0
.set 	O_WRONLY, 1
.set	EXIT, 60
enc_prefix:	.ascii "enc_"
lenc_prefix = . - enc_prefix
filename: 	.skip 20
lfilename = . - filename
enc_filename:	.skip 24
key:	.ascii "qwerty"
N 	= . - key
buffer:	.skip N
enc_text:	.skip N
first_fd:	.quad 0
second_fd:	.quad 0
err_messg:	.ascii "Something wrong\n"
lerr_messg = . - err_messg
.text
.globl _start
_start:
	mov	$2, %rdx
	mov	(%rsp, %rdx, 8), %rdi
	mov 	$5, %rcx
	lea 	filename, %rsi
	rep movsb
#	mov 	%rdi, filename

	mov	$O_RDONLY, %rsi
	lea 	filename, %rdi
	call 	_open
	mov 	%rax, first_fd

	mov 	$lenc_prefix, %rcx
	lea 	enc_filename, %rdi
	lea 	enc_prefix, %rsi
	rep movsb
	lea 	filename, %rsi
	mov 	$lfilename, %rcx
	rep movsb

	mov 	$O_WRONLY, %rsi
	lea 	enc_filename, %rdi
	call	_open
	mov 	%rax, second_fd
_loop:
	call	_read
	push	%rax
	call 	_encode
	call	_write
	pop	%rax
	test 	%rax, %rax
	jnz	_loop

	mov	first_fd, %rdi
	call 	_close
	mov	second_fd, %rdi
	jmp 	_exit
_encode:

_open:
	mov 	$OPEN, %rax
	syscall
	cmp	$0, %rax
	jl	_error
_read:
	mov 	first_fd, %rdi
	mov	$READ, %rax
	lea 	buffer, %rsi
	mov 	$N, %rdx
	syscall
ret
_write:
	mov	%rax, %rdx
	mov	$WRITE, %rax
	mov	second_fd, %rdi
	lea 	buffer, %rsi
	syscall
ret
_close:
	mov	$CLOSE, %rax
	syscall
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