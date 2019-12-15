//Assignment 5b
//Author: Himika Dastidar

//define macros

define(month, w19)				//put month in w19
define(day, w20)				//put day in w20
define(year, x21)				// put year in w21
define(argc, w22)				//put argc in w22
define(argv, x23)				//put argv in x23
define(i_r, w24)				//put i in w24

	.text

fmt:	.string "%s %d%s, %d\n"			//outputs the date in a format
err:	.string "usage: a5b mm dd yyyy\n"	//outputs the error message
mor:	.string "Month out of range\n"		//gives error if month is out of range
dor:	.string	"Day out of range\n"		//day out of range error
yor:	.string	"Year out of range\n"		//year out of range error


jan_m:	.string	"January"
feb_m:	.string "February"
mar_m:	.string "March"
apr_m:	.string "April"
may_m:	.string "May"
jun_m:	.string "June"
jul_m:	.string "July"
aug_m:	.string "August"
sep_m:	.string "September"
oct_m:	.string "October"
nov_m:	.string "November"
dec_m: 	.string "December"



st:	.string "st"				//suffix string st
nd:	.string "nd"				//suffix string nd
rd:	.string "rd"				//suffix string rd
th:	.string	"th"				//suffix string th



	.data
	.balign 8				//word aligned

month_m: .dword	jan_m, feb_m, mar_m, apr_m, may_m, jun_m, jul_m, aug_m, sep_m, oct_m, nov_m, dec_m	//month array
suff_m:	 .dword st, nd, rd, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, st, nd, rd, th, th, th, th, th, th, th, st 				 //suffix array


	.text
	.balign 4
	.global main				//make this visible to OS

main:	stp 	x29, x30, [sp, 16]!		//allocate memory
	mov	x29, sp				//move sp to fp
	
	mov	argc, w0			//copy argc
	mov	argv, x1			//copy argv
	mov	i_r, 1				//i = 1, to ignore the file name


	cmp	argc, 4				//check if there are 4 arguments
	b.ne	error				//go to error state and exit


	ldr	x0, [argv, i_r, SXTW 3]		//load first argument into x0
	bl	atoi				//branch to atoi

	mov	month, w0			//move atoi into month
	cmp	month, 12			// if month > 12 error

	b.gt	m_err
	cmp	month, 1			//if month < 1 error
	b.lt	m_err				//error

	add	i_r, i_r, 1			//i++

	ldr	x0, [argv, i_r, SXTW 3]		//load day into x0

	bl	atoi				//branch to atoi
	mov	day, w0				//load atoi into day

	cmp	day, 31				//if day > 31 throw error
	b.gt	d_err				//throw error

	cmp	day, 1				//if day < 1 throw error	
	b.lt	d_err				//throw error	
	
	add	i_r, i_r, 1			//i++

	ldr	x0, [argv, i_r, SXTW 3]		//load year into x0
	bl	atoi				//branch to atoi
	sxtw	x0, w0				//sign extend what is returned
	mov	year, x0			//load atoi into year
	
	cmp	year, 0				//check if year is >= 0
	b.lt	y_err				//print error message
	
	adrp	argv, month_m			//get the address of month_m into x28
	add	argv, argv,:lo12:month_m	//calculate the proper address
	sub	month, month, 1			//adjust for the fact that index is off by 1

	//print final message
	adrp	x0, fmt				//load format string into x0
	add	x0, x0,:lo12:fmt		//load lower 12 bits
	ldr	x1, [argv, month, SXTW 3]	//retrieve month from month array
	mov	w2, day				//load day into x2

	sub	day, day, 1			//add 1 to day to account for index being off by 1

	adrp	x27, suff_m			//get the base address for suffix array
	add	x27, x27,:lo12:suff_m		//calcualte the lower 12 bits
	ldr	x3, [x27, day, SXTW 3]		//load suffix into x3
	mov	x4, year			//load year into w4

	bl	printf				//print
	b 	end				//branch to end of program

	
	//print error message
error:	adrp	x0, err				//error message for incorrect number of arguments
	add	x0, x0,:lo12:err		//low 12 bits
	bl 	printf				//print
	b	end				//go to end of program


m_err:	adrp	x0, mor				//load adress of error for month
	add	x0, x0,:lo12:mor		//load lower 12 bits
	bl 	printf				//print
	b 	end				//go to end of program

d_err:	adrp	x0, dor				//load address for day
	add	x0, x0,:lo12:dor		//load lower 12 bits
	bl	printf				//print
	b	end				//branch to end

y_err:	adrp	x0, yor				//load address for error for year
	add	x0, x0,:lo12:yor		//load lower 12 bits
	bl	printf				//print

end:	ldp	x29, x30, [sp], 16		//deallocate memory
	ret					//restore state

