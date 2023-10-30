
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


	clean:
		movl	ST_FD_IN(%ebp), %ebx
		movl	$CLOSE, %eax
		int	$LINUX_SYSCALL

                movl    ST_FD_OUT(%ebp), %ebx
                movl    $CLOSE, %eax
                int     $LINUX_SYSCALL
	exit:
		movl	$0, %ebx
		movl	$EXIT, %eax
		int	$LINUX_SYSCALL

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
convert_to_upper:
