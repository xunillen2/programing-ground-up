.section .data

.section .text

.globl _start
.globl factorial

_start:
	pushl	$4
	call	factorial
	subl	$4, %esp
	movl	%eax, %ebx
	
	movl	$0x1, %eax
	int	$0x80


factorial:
	push	%ebp
	movl	%esp, %ebp

	movl	8(%ebp), %eax
	cmpl	$1, %eax
	je	end_factorial

	decl	%eax
	pushl	%eax
	call	factorial
	popl	%ebx
	incl	%ebx
	imul	%ebx, %eax
	
	end_factorial:
		movl	%ebp, %esp
		popl	%ebp
	ret

	
