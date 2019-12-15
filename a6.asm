//CPSC355 Assignment 6
// Authour: Himika Dastidar

//define macros
define(i_r, w9)
define(fd, w19)
define(nread_r, x20)
define(buf_base_r, x21)
define(argc, w23)
define(argv, x24)


define(x_r, d19)
define(sum_r, d20)
define(x1_r, d21)
define(i_d, d23)
define(return, d24)

//define fixed double values

ans_m:	.double		0r1.0e-13	//ans = 1.0e -13
sum_m:	.double		0r0.0		//sum = 0


buf_size = 8				//expected buffer size
alloc = -(16 + buf_size) & -16		//calculate memory allocateion
dealloc = -alloc			//calculate memory deallocation
buf_s = 16				// to account for FP
AT_FDCWD = -100				// current working directory



//define strings
err_1:	.string		"Incorrect number of arguments.\n"		//error of incorrect number of args
fmt1:	.string		"Error opening file: %s\n Aborting.\n"		//error opening file
header:	.string		"|x		| ln(x)		|\n"		//header
fmt2:	.string		"|%.5f	| %.10f	|\n"				//print answer
fmt3:	.string		"Error closing file \n"				//message for error closing file

	.balign 4
	.global main


main:	stp	x29, x30, [sp, alloc]!		//allocate memory
	mov	x29, sp				//mov sp to fp

//-------read file from command line----------------------------------------------//
	mov	argc, w0			//argc = 1st arg
	mov	argv, x1			//argv = address for array 2nd arg
	cmp	argc, 2				//comapre #argc with 2
	b.eq	open_file			// if #args != 2 throw an error

	//print out error message if there are incorrect# of args
	adrp	x0, err_1			//calculate address of err_1
	add	x0, x0, :lo12:err_1		//calcualte lower 12 bits
	bl	printf				//print
	b	exit				//exit after error

//------------open file-------------------------------------------------------------//
open_file:
	mov	w0, AT_FDCWD			//1st arg (CWD)
	mov	w9, 1				//mov i into w9 to read the first argument
	ldr	x1, [argv, w9, SXTW 3]		//2nd arg (pathname, "input.bin")
	mov	w2, 0				//3rd arg(read only)
	mov 	w3, 0				//4th arg (not used)
	mov	x8, 56				//openat I/O request
	svc	0				//system call

	mov	fd, w0				//store file dedscriptor
	cmp	fd, 0				//if file was opened properly
	b.ge	p_head				//if file opened print header


//------file error statement----------------------------------------------------------//
	
	adrp	x0, fmt1			//calculate address of fmt1
	add	x0, x0,:lo12:fmt1		//calculate lower 12 bits
	bl 	printf
	mov	w0, -1				//return -1
	b 	exit				//branch to exit

//----------read file---------------------------------------------------------------//

//print header for table

p_head:	adrp	x0, header			//calculate address of header
	add	x0, x0,:lo12:header		//calcualte the lower 12 bits
	bl	printf				//print header

read_file:
	mov	w0, fd				//1st arg, fd
	add	x1, x29, buf_s			//2nd arg, base address for buffer
	mov	x2, buf_size			//3rd argument
	mov	x8, 63				//read service request
	svc 	0				// system call

top:	cmp	w0, buf_size			// compare argument size
	b.ne	end				//branch to end
	
	ldr	x_r, [x29, buf_s]		//load x into register x_r

	fmov	d25, 1.0			// mov 1 into d25
	fmov	i_d, 1.0			// set i_d = 1
	adrp	x25, sum_m			//get address of sum_m
	add	x25, x25,:lo12:sum_m		//calculate the low 12 bits
	ldr	sum_r, [x25]			//load sum to sum_r
	fsub	d26, x_r, d25			//calcualte x-1 in d26
	fdiv	d26, d26, x_r			//calculate x-1/x in d26
	fmov	x1_r, d26			//mov (x-1/x) into x1_r
	

//----------------set up arguments for the ln(x) function---------------------------//

set_ln:	fmov	d0, x_r				//arg1 = x
	fmov	d1, i_d				//arg_2 = i
	fmov	d2, x1_r			//arg_3 = (x-1)/x
	bl	ln_x_int			//branch to calculate ln x intermediate

l_test:	fadd	sum_r, sum_r, d0		// sum_r += whatever is returned from ln_x_int
	fabs	return, d0			//math.abs(return value from ln_x_int)
	adrp	x28, ans_m			//load address of ans_m into x28
	add	x28, x28,:lo12:ans_m		//calcualte the lower 12 bits
	ldr	d1, [x28]			//load ans_m into d1
	fadd	i_d, i_d, d25			// i_d ++
	fcmp	return, d1			//compare ans with 1e-13
	b.ge	set_ln				//set up for ln_x_int again 


print_ans:
	adrp	x0, fmt2			//put address of fmt2 into x0
	add	x0, x0, :lo12:fmt2		//calcualte lower 12 bits
	fmov	d0, x_r				//move x into d0
	fmov	d1, sum_r			//mov sum into d1
	bl	printf				//print
	b	read_file			//continue reading file

//------------------close file and exit program--------------------------------------//
end:	mov	w0, fd				//close file
	mov	x8, 57				//close request
	svc	0				//system call
		
	cmp	w0, 0				// compare status of closing
	b.ge	exit


cl_err:
	adrp	x0, fmt3			//calculate address of fmt3
	add	x0, x0, :lo12:fmt3		//calculate lower 12 bits of fmt3
	bl 	printf				//print messafge
	mov	w0, -1				//move -1 into w0

exit:	ldp	x29, x30, [sp], dealloc		//deallocate memory
	ret					//restore state

//============lnx subroutine=============================================//


ln_x_int:	
	
	stp	x29, x30, [sp, -16]!		//allocate memory
	mov	x29, sp				//move sp to fp
	
	fmov	d9, d0				//mov x into d9
	fmov	d10, d1				//mov n into d10
	fmov	d11, 1.0			//mov 1 into d11
	fmov	d12, d2				//mov (x-1/x) into d12
	fmov	d14, d2				//mov (x-1/x) into d14 //keep track of result
	fmov	d15, 1.0			//move counter into d15
	fdiv	d13, d11, d10			//1/i
	b	test
	
loop:	fmul	d14, d14, d12			//answer = answer * (x-1)/x
	fadd	d15, d15, d11			//counter  ++
	
test:	fcmp	d15, d10			//if counter < n
	b.lt	loop				//if d15 < d10 loop again
	
	fmul	d14, d14, d13			//1/n*(x-1/n)^n
	fmov	d0, d14				//return answer

	ldp	x29, x30, [sp], 16		//deallocate memory
	ret					//restore state
