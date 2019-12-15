// Assignment 2b
//Author: Himika Dastidar

print1:		.string	"multiplier = 0x%08x(%d)  multiplicand = 0x%08x(%d)\n\n"	  //print the initial value of multiplier and multiplicand

print2:		.string	"product = 0x%08x multiplier = 0x%08x\n"		 //print value of product and multiplier

print3:		.string	"64-bit result = 0x%016lx(%ld)\n" 			//print result in 64 bits

		.balign 4
		.global main


main:		stp	x29, x30, [sp, -16]!
		mov	x29, sp

		//define macros
		define(TRUE, 1)			//TRUE assignment as 1
		define(FALSE, 0)		//FALSE assignment as 0
		define(mult, w19)		// multiplier assignment in w19
		define(mand, w20)		// multiplicand assignment in w20
		define(prod, w21)		//product assignment in w21
		define(i,    w22)		// i assignment in w22
		define(neg,  w23)		// negative assignment in w23

		define(res,  x24)		//result assignment in 64 bit x24
		define(temp1, x25)		//temp1 assignment in 64 bit x25
		define(temp2, x26)		//temp2 assignment in 64 bit x26

		//Intialize vars
		mov	mand, -252645136	//assign value of multiplicand to be -252645136
		mov	mult, -256		//assign value of multiplier to be -256
		mov	prod, 0			//assign value of product to be 0
		mov	i, 0			//assign value of i to be 0
		
		//print initial values

		adrp	x0, print1
		add	x0, x0, :lo12:print1
		mov	w1, mult		// put 8 bit value of mutliplier in w1
		mov	w2, mult		// put decimal value of multiplier in w2
		mov	w3, mand		// put 8 bit value of multiplicand in w3
		mov	w4, mand		// put decimal value of multiplicant in w4
		bl	printf
		
		// determine if multiplier is negative

n_test:		cmp	mult, 0			//compare multiplier to 0
		b.lt	set_neg			//set the value of negative to be TRUE
		mov	neg, FALSE		//if not less than 0, set neg to FALSE
		b	top			//go to the branch test to start the for loop	

set_neg:	mov	neg, TRUE		// set the value to negative to be true == 1

		
		//begin for loop
top:		tst	mult, 0x1		// compare multiplier and 0x1
		b.eq	up_m			// if condition is false, move to up_m
		add	prod, prod, mand	// if condition is true, update value of product		
						// after execution of this skip to if_2
		
up_m:		asr	mult, mult, 1		//multiplier = multiplier >> 1
		// start the 2nd if test	
		tst	prod, 0x1		// compare product and 0x1
		b.eq	else			// if flag is 0, go to else
		orr	mult, mult, 0x80000000	// if flag is 1,  multiplier = multiplier | 0x80000000
		b	shift			// after running or go to shift


else:		and	mult, mult, 0x7FFFFFFF	// multiplier = multiplier & 0x7FFFFFFF



shift:		asr	prod, prod, 1		//prod = prod >>1
		add	i, i, 1			// i += 1
		cmp 	i, 32			// if i < 32
		b.lt	top			// go to top of the for loop

		cmp	neg, TRUE		// if negative 
		b.ne	end			// if neg != 1, end
		sub	prod, prod, mand	// if neg == 1, product -= mand
		

	
		//print out product and multiplier

end:		adrp	x0, print2			//move print 2 into x0
		add	x0, x0, :lo12:print2		//magic
		mov	w1, prod			//move product into w1
		mov	w2, mult			//move multiplier into w2
		bl	printf				//print

		//combine product and multiplier together
		
		sxtw	x21, prod			//sign extend product into x21, cast as long int
		and	temp1, x21, 0xFFFFFFFF		//temp1 = product & 0xFFFFFFFF
		lsl	temp1, temp1, 32		//temp1 << 32 (left logical shift by 32 bits)
		sxtw	x19, mult			//sign extend multiplier from 32 bit to 64 bit as long int	
		and	temp2, x19, 0xFFFFFFFF		//temp2 = multi & 0xFFFFFFFF
		add	res, temp1, temp2		// result = temp1 + temp2	


		//print out 64 bit result
		
		mov	x1, res				//move result inot x1
		mov	x2, res				//move result into x2
		adrp	x0, print3			//move print statement into x0
		add	x0, x0, :lo12:print3		//magic
		bl	printf				//print


		ldp	x29, x30, [sp], 16		//restore state
		ret
