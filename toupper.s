
### CONSTANTS ###

# Sys calls
.equ OPEN,	5
.equ WRITE,	4
.equ READ,	3
.equ CLOSE,	6
.equ EXIT,	1

# Options for open
.equ O_RDONLY,			0	# Open file option - read-only
.equ O_CREAT_WRONLY_TRUNC,	03101	# Open file option
					# Create, write only, and trunc (destroy file contets)
# Interrupts
.equ LINUX_SYSCALL,	0x80

# Files
.equ END_OF_FILE, 0


### BUFFERS ###
.section .bss
	.equ	BUFFER_SIZE,	500
	.lcomm	BUFFER_DATA,	BUFFER_SIZE

### PROGRAM CODE ###

.section .text

# Stack positions
.equ ST_SIZE_RESERVE,	8
.equ ST_FD_IN,		0
.equ ST_FD_OUT,		4
.equ ST_ARGC,		8	# Number of args
.equ ST_ARGV_0,		12	# Name of program
.equ ST_ARGV_1,		16	# Input file
.equ ST_ARGV_2,		20	# Output file

.globl _start
_start:
	###INIT###
	subl	$ST_SIZE_RESERVE, %esp
	movl	%esp, %ebp

	open_file:
	open_fd_in:
		movl	ST_ARGV_1(%ebp), %ebx
		movl	$O_RDONLY, %ecx
		movl	$0666, %edx
		movl	$OPEN, %eax
		int	$LINUX_SYSCALL

		movl	%eax, ST_FD_IN(%ebp)	# Store fd

	open_fd_out:
		movl	ST_ARGV_2(%ebp), %ebx
		movl	$O_CREAT_WRONLY_TRUNC, %ecx
		movl	$0666, %edx
		movl	$OPEN, %eax
		int	$LINUX_SYSCALL

		movl	%eax, ST_FD_OUT(%ebp)	# Store fd

	read_loop:
		###READ IN A BLOCK FROM THE INPUT FILE###
		movl	ST_FD_IN(%ebp), %ebx
		movl	$BUFFER_DATA, %ecx
		movl	$BUFFER_SIZE, %edx
		movl	$READ, %eax
		int	$LINUX_SYSCALL

		cmpl	$END_OF_FILE, %eax
		jle	exit			# If we hit end of file, clean and exit

		pushl	$BUFFER_DATA		# If not, run conversion function
		pushl	%eax
		call	convert_to_upper
		popl	%eax
		popl	%ebx

		movl	ST_FD_OUT(%ebp), %ebx
		movl	$BUFFER_DATA, %ecx
		movl	$BUFFER_SIZE, %edx
		movl	$WRITE, %eax
		int	$LINUX_SYSCALL

		jmp	read_loop

        exit:
	close_fd:
                movl    ST_FD_IN(%ebp), %ebx
                movl    $CLOSE, %eax
                int     $LINUX_SYSCALL

                movl    ST_FD_OUT(%ebp), %ebx
                movl    $CLOSE, %eax
                int     $LINUX_SYSCALL

        syscall_exit:
                movl    $0, %ebx
                movl    $EXIT, %eax
                int     $LINUX_SYSCALL


# PURPOSE:
#	Converts chars in buffer to upper
# INPUT:
#	The first parameter is the location of the buffer
#	Second parameter is the lenght of that buffer
# OUTPUT:
#	This function overwrites the current buffer with upper-clasified version.
# VARIABLES:
#	%eax - beginning of buffer
#	%ebx - Lenght of buffer
#	%edi - Current buffer offset
#	%cl - Current byte being examined

###CONSTANTS###
.equ LOWERCASE_A,		'a'
.equ LOWERCASE_Z,		'z'
.equ UPPERCASE_CONVERSION,	'A' - 'a'

###STACK POSITIONS###
.equ ST_BUFFER_LEN,	8
.equ ST_BUFFER,		12

###SET UP VARIABLES###

convert_to_upper:
	pushl	%ebp
	movl	%esp, %ebp

	movl	ST_BUFFER(%ebp), %eax
	movl	ST_BUFFER_LEN(%ebp), %ebx
	xorl	%edi, %edi

	# If buffer len is 0, exit
	cmpl	$0, %ebx
	je	end_convert_loop

	convert_loop:
		movb	(%eax, %edi, 1), %cl

		# Go to next byte unless it is between 'a' and 'z'
		cmpb	$LOWERCASE_A, %cl
		jl	next_byte
		cmpb	$LOWERCASE_Z, %cl
		jg	next_byte

		# Convert to upper
		addb	$UPPERCASE_CONVERSION, %cl
		movb	%cl, (%eax, %edi, 1)
		next_byte:
			incl	%edi
			cmpl	%edi, %ebx
			jne	convert_loop

	end_convert_loop:	# No return values
		movl	%ebp, %esp
		popl	%ebp
		ret
