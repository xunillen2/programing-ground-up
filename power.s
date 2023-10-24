.section .data

.section .text

.globl _start
_start:

	pushl	$3
	pushl	$2
	call	power
	addl	$8, %esp
	movl %eax,%ebx
#	pushl	%eax

#	pushl	$2
#	pushl	$5
#	call	power
#	addl	$8, %esp

#	popl	%ebx
#	addl	%eax, %ebx

	movl	$1, %eax
	int	$0x80

# PURPOSE:	This function is used to compute the value
#		of the numver raised to a power.
#
# INPUT:	First arg - The base number
#		Second arg - The power to raise
#				it to
#
# OUTPUT:	WIll give the result as a return
#			value
#
# VARIABLES:
#		%ebx - holds the base number
#		%ecx - holds the power
#		-4(%ebp) - holds the current result
#
# HOW DOES STACK LOOK:
#	arg0 - ebp - 12
#	arg1 - ebp - 8
#	ret  - ebp - 4
#	ebp - ebp
power:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$4, %esp

	leal	8(%ebp), %ebx
	movl	%ebx, -4(%ebp)
	movl	12(%ebp), %ecx

	power_loop:
		cmpl	$1, %ecx
		je	power_end
		movl	-4(%ebp), %eax
		imul	%ebx, %eax
		movl	%eax, -4(%ebp)
		decl	%ecx
		jmp	power_loop
	power_end:
		movl	-4(%ebp), %eax
		movl	%ebp, %esp
		popl	%ebp
		ret
