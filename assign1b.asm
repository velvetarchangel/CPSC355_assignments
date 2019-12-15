fmt:	.string		"The value of x: %4d,  y: %4d, max: %4d\n"

final:	.string		"The maximum value is: %4d\n"


	.global main
	.balign	4

main:	stp 	x29, x30, [sp, -16]!
	mov 	x29, sp
	

	define(x_r, x19)		//set up the macro x_r to x19 to keep track of x
	define(y_r, x20)		//set up the macro y_r to x20 to keep track of y
	define(max, x21)		//set up the macro max to x21 to keep track of max


	mov	x_r, -10		//set the value of x_r = -10
	mov	max, -50000		//set value of max = -50000

	
	b 	test			//do the loop test
top:	mul	x23, x_r, x_r		//calculate the value of x^2 and store it in x23
	mul	x23, x23, x_r		//calcualte the value of x^3 and store it in x23
	mov	x28, -2
	mul	x24, x28, x23		//calculate -2x^3 and store in x24
	mov	x23, x_r		//reset the value of x23 to the value of x
	mul	x23, x_r, x_r		//store the value of x^2 in x23
	mov	x28, -22		//store -22 in x29
	madd	y_r, x23, x28, x24 	//store the value of -2x^3 -22 x^2 in y_r
	mov	x28, 11			//set x29 to 11
	madd	y_r, x28, x_r,y_r	//override the value of temp = -2x^3 -22x^2 + 11x
	add	y_r, y_r, 57		//add 57 to the polynomial and store in y_r

	cmp	y_r, max		//check if y > max
	b.lt	print			// swap if the condition holds		
	mov	max, y_r		// put the value of y_r into max


		
print:	mov	x1, x_r			//mov x_r to x1
	mov	x2, y_r			//mov y_r to x2
	mov	x3, max			//mov max to x3
	adrp	x0, fmt
	add	x0, x0, :lo12:fmt
	bl	printf

	add 	x_r, x_r, 1		//increment x


test:	cmp	x_r, 4
	b.le	top
	b	end			//unconditional branch, will end program and print out final answer
	

end:	mov	x1, max
	adrp	x0, final
	add	x0, x0, :lo12:final
	bl	printf

	mov	x0, 0
	mov	x1, 0
	mov	x2, 0
	mov	x3, 0	
	ldp	x29, x30, [sp], 16
	ret
