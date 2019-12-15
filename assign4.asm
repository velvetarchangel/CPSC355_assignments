//Assignment 4
//Author: Himika Dastidar

//define all strings

fmt:	.string	"Cuboid %s origin = (%d, %d) \n"
fmt1:	.string	"\tBase width = %d Base length = %d \n"
fmt2:	.string	"\tHeight = %d\n"
fmt3:	.string	"\tVolume = %d\n\n"
fmt4:	.string	"Initial cuboid values: \n"
fmt5:	.string	"\nChanged cuboid values:\n"
fmt6:	.string	"first"
fmt7:	.string	"second"	
	.balign 4


//point struct
point_x = 0			//point.x offset of 0
point_y = 4			// point.y has offset = 4, as x is an int
point_struct_size = 8		//size of point


//dimension struct
dim_width = 0			//dimension width offset
dim_length = 4			// dimension length offset
dim_struct_size = 8		//size of dimension


//cuboid struct
cuboid_origin = 0		//point var in cuboid with offset 0
cuboid_base = 8	
cuboid_height = 16		//var height in cuboid with offset 16
cuboid_volume = 20		//vol in cuboid with offset 20
cuboid_struct_size = 24		//size of cuboid

//newCuboid

base_c = 16									//account for the FR
alloc = -(16 + cuboid_struct_size) & -16					//allocate 1 cuboid size
dealloc = -alloc								//deallocate memory

newCuboid:	stp	x29, x30, [sp, alloc]!					//allocate space
	 	mov	x29, sp							//move sp to fp
			
		str	wzr, [x8, cuboid_origin + point_x]			//store c.origin.x = 0 into x8
	
		str	wzr, [x8, cuboid_origin + point_y]			//store c.origin.y = 0 into x8
		
		mov	w10, 2							// move 2 into w10
		str	w10, [x8, cuboid_base + dim_width]			//store c.base.width = 2 into x8

		mov	w10, 2							//mov 2 into w10
		str	w10, [x8,  cuboid_base+ dim_length]			//store c.base.length = 2 into x8

		mov	w11, 3							//mov 3 into w11
		str	w11, [x8, cuboid_height]				//store c.height = 3 into x8
	
		mul	w11, w11, w10						//length*height stored in w11
		mul	w11, w11, w10						// width*length*height

		str	w11,[x8, cuboid_volume]					//store c.volume in x8

		ldp	x29, x30, [sp], dealloc					//deallocate memory
		ret								//restore state


//move subroutine

move:	stp	x29, x30,[sp, -16]!				//allocate memory
	mov	x29, sp						//move sp to fp
								//find offset for c.origin
	ldr	w10, [x0,cuboid_origin + point_x]		//load c.origin.x
	add	w10, w10, w1					//c.origin.x += deltaX
	str	w10, [x0,cuboid_origin + point_x]		//store c.origin.x into stack
	ldr	w10, [x0,cuboid_origin + point_y]		//load c.origin.y
	add	w10, w10, w2					//c.origin.y += deltaY
	str	w10, [x0,cuboid_origin + point_y]		//store c.origin.y into stack
		

	ldp	x29, x30, [sp], 16				//deallocate memory
	ret							//restore


//scale subroutine


define(factor,w15)						//macro for factor

scale:	stp	x29, x30, [sp, -16]!				//allocate memory
	mov	x29, sp						//restore

	mov	factor, w1					//move arg1 into factor
	ldr	w10, [x0,cuboid_base + dim_width]		//load width into w10
	mul	w10, w10, factor				//c.base.width *= factor
	str	w10, [x0,cuboid_base + dim_width]		// store width into stack

	ldr	w11, [x0,cuboid_base + dim_length]		//load length into w10
	mul	w11, w11, factor				//c.base.length *= factor
	str	w11, [x0,cuboid_base + dim_length]		//store length into stack

	ldr	w12, [x0, cuboid_height]			//load height from memory
	mul	w12, w12, factor				//height *= factor
	str	w12, [x0, cuboid_height]			//store height in memory
	

	//calculate volume
	mul	w13, w12, w11					//w13 = height* length	
	mul	w13, w13, w10					//w13 = w13 * width
	str	w13, [x0, cuboid_volume]			//store volume in memory


	ldp	x29, x30, [sp], 16				//dealloc memory
	ret							//restore state


//printCuboid subroutine
x19_size = 8							//size of x19 register
alloc_p = -(16 + x19_size) & -16				//calculate allocation
dealloc_p = -alloc_p						//calculate deallocation
x19_save = 16							//x19 will be saved after FR

printCuboid:	stp	x29, x30, [sp, alloc_p]!		//allocate memory
		mov	x29, sp					//move sp to fp
		
		
		str	x19,[x29, x19_save]			//store x19 into stack
		mov	x19, x1					//move address of c into x19
		mov	x1, x0					//move *name to x1
		
		//load c.origin.x and c.origin.y

		ldr	x9, [x19, cuboid_origin + point_x]	//put value for c.origin.x in x2
		ldr	x10, [x19, cuboid_origin + point_y]	//x3 = c.origin.y		
		
			
		//first print statement
		mov	x2, x9					//move c.origin.x into x2
		mov	x3, x10					//move c.origin.y into x3
		adrp	x0, fmt					//put "cuboid origin into x0"
		add	x0, x0, :lo12:fmt			//magic
		bl 	printf					//print
		
		ldr	x9, [x19, cuboid_base + dim_width]	//put width in x1
		ldr	x10, [x19, cuboid_base + dim_length]	//put c.length in x2

		//second print statement
		mov	x1, x9					//move c.base.width into x1
		mov	x2, x10					//move c.base.height into x2
		adrp	x0, fmt1				//move string into x0
		add	x0, x0, :lo12:fmt1			//magic
		bl	printf					//print

		//third print statement
		ldr	x9, [x19, cuboid_height]		//load height into x9
		mov	x1, x9					//move c.height into x1
		adrp	x0, fmt2				//move string into x0
		add	x0, x0, :lo12:fmt2			//load the low register
		bl	printf					//print statement
			
		///fourth print statement
		ldr	x9, [x19, cuboid_volume]		//load address of bolume into x9
		mov	x1, x9					//load contents of x9 into x1
		adrp	x0, fmt3				//load string into x0
		add	x0, x0, :lo12:fmt3			//load low registers
		bl	printf					//print
		
		ldr	x19, [x29, x19_save]			//restore x19 back
		ldp	x29, x30, [sp], dealloc_p		//deallocate memory	
		ret						//restore state


//equalSize subroutine


equalSize:	stp	x29, x30, [sp, -16]!			//allocate memory for suburoutine
		mov	x29, sp					//move sp into fp
		
		mov	x9, x0					//move address for c1 

		ldr	w10, [x9, cuboid_base + dim_width]	// load c1.width inot w10
		ldr	w11, [x9, cuboid_base + dim_length]	// load c1.length into w11
		ldr	w12, [x9, cuboid_height]		// load c1.height into w12

		mov	x9, x1					//move address for c2 into x9

		ldr	w13, [x9, cuboid_base + dim_width]	//load c2.width into w13 
		ldr	w14, [x9, cuboid_base + dim_length]	//load c2.length into w14
		ldr	w15, [x9, cuboid_height]		//load c2.height into w15

		cmp	w10, w13				//compare width
		b.ne	end_loop				//if not the same break loop
		
		cmp	w11, w14				//compare length
		b.ne	end_loop				//if not equal break loop

		cmp	w12, w15				//compare height
		b.ne	end_loop				//if not equal break loop
		b	else					//if not equal branch to else

end_loop:	mov	w0,0					//return False 
		b	end					//branch to end

else:		mov	w0, 1					//return TRUE
			
end:		ldp	x29, x30, [sp], 16			//deallocate memory
		ret						//restore state
//main

cuboid_first_size = cuboid_struct_size				//first = newCuboid()
cuboid_second_size = cuboid_struct_size				//second = newCuboid()

cuboid_first_s = 16						//account for FR
cuboid_second_s = cuboid_first_s + cuboid_first_size		//put second on top of first

alloc_m = -(16 + cuboid_first_size + cuboid_second_size) & -16	//allocate space
dealloc_m = -alloc_m						//deallocate space


	.global main
main:	stp	x29, x30, [sp, alloc_m]!			//allocate memory
	mov	x29, sp						//move sp to fp	
	
	adrp	x0, fmt4					// pas "Initial cuboid values" as arg0
	add	x0, x0,:lo12:fmt4				//magic
	bl 	printf						//print

	add	x8, x29, cuboid_first_s				//set up return register
	bl	newCuboid					//branch to printCuboid

	ldr	x0, =fmt6					//pass first
	mov	x1, x8						//pass address of first
	bl	printCuboid					//branch to printCuboid

	add	x8, x29, cuboid_second_s			//set up return register	
	bl	newCuboid					//branch to newCuboid

	ldr	x0,=fmt7					//pass "second"
	mov	x1, x8						//pass address of second
	bl	printCuboid					//branch to printCuboid

	add	x0, x29, cuboid_first_s				//pass address of first cuboid
	add	x1, x29, cuboid_second_s			//pass address of second cuboid

	bl	equalSize					//run the subroutine equalSize
	
	cmp	w0, 0						//if equalSize == FALSE
	b.eq	next						// branch to next

	//if equalSize == TRUE run this
	add	x0, x29, cuboid_first_s				// pass first_cuboid_address arg0
	mov	w1, 3						// pass 3 as arg1
	mov	w2, -6						// pass -6 as arg2
	bl 	move						// branch to move
	
	add	x0, x29, cuboid_second_s			// pass second_cuboid address as arg0
	mov	w1, 4						// pass 4 as arg1
	bl	scale						//branch to scale


next:	adrp	x0, fmt5					// load "Changed cuboid values" in x0
	add	x0, x0, :lo12:fmt5				// magic
	bl 	printf						//print

	ldr	x0, =fmt6					//load "first" as arg0
	add	x1, x29, cuboid_first_s				//load first address as arg1
	bl	printCuboid					//branch to printCuboid

	ldr	x0, =fmt7					//load "second" as arg0
	add	x1, x29, cuboid_second_s			//load second address as arg2
	bl	printCuboid					//branch to printCuboid
	

	ldp	x29, x30, [sp], dealloc_m			//deallocate memory
	ret							//restore state
