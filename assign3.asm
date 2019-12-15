//Assignment 3
//Author Himika Dastidar


//define macros

define(i, w19) 					//always store i in w19
define(j, w20)					//always store j in w20
define(temp, w21)				//always store temp in w21
define(v_i, w22)				//always store v_i in w22
define(v_min, w23)				//always store v_min in w23
define(min, w24)				//always store min in w24
define(base, x25)				//always store arraybase in w25
define(v_j, w27)				//always store v_j in w27

array_count = 50				//number of elements in the array
v_size = array_count * 4			//size of array: 4 bytes for each integer
i_size = 4					//size of i: 4 bytes
j_size = 4					//size of j: 4 bytes
min_size = 4					//size of min: 4 bytes
temp_size = 4					//size of temp: 4 bytes


//equations for the offsets(base: FP)

temp_s = 16					// store this at the bottom of the frame pointer
min_s = temp_s + temp_size			// store this after temp
i_s = min_s + min_size				//store this after min
j_s = i_s + i_size				//store this after i
v_s = j_s + j_size				//store this after j


//Allocate memory for stack

var_size = v_size + i_size + j_size + min_size + temp_size	//calculate the total stack memory reqd
alloc = -(16 + var_size)& -16					//calculate so that it is multiple of 16
dealloc = -alloc						//calculate how much to deallocate


fp	.req	x29				//assign var name for frame pointer			
lr	.req	x30				//assign var name for link register



//print unsorted array

fmt:	.string "v [%d]: %d\n"			//print array

fmt2:	.string "\nSorted array:\n"		//statement at the beginning of sorted array


	.balign 4				//align reigsters
	.global main				


main:	stp	fp, lr, [sp,alloc]!		//allocate appropriate amount of memory
	mov	fp, sp				//stack pointer = frame pointer

	mov	i, 0				//initialize i = 0
	str	i, [fp, i_s]			//store i in stack
	add	base, fp, v_s			//calculate base
	b	test1				//branch to loop test to initialize array


//initialize the array with rand% 256

init:	bl	rand				//generate random number to w0
	and	w26, w0, 0xFF			//perform mod 256
	ldr	i, [fp, i_s]			//load i into w19
	str	w26, [base, i, sxtw 2]		//store the random number into stack address: array_base + i*4


	//print value

	adrp	x0, fmt				//push print statement to x0
	add	x0, x0, :lo12:fmt		//magic
	ldr	w1, [fp, i_s]			//arg1 = i
	ldr	w2, [base, i ,SXTW 2]		//arg2 : array[i]
	bl	printf				//print

	add	i, i, 1				//i++
	str	i, [fp, i_s]			//update i in stack 	


test1:	cmp	i, array_count			// if i < SIZE
	b.lt	init				// go to loop


	//reset i= 0
	mov	i, 0				//set i = 0
	str	i, [fp, i_s]			//store i to stack
	b 	test_o				//branch to test for outer loop

	//sort array using selection sort
	//loop 2 is the outer loop
	//loop 3 is the inner loop

outer:	ldr	min,[fp, min_s]			//load min 
	ldr	i, [fp, i_s]			//load i
	mov	min, i				// min = i
	str	min, [fp, min_s]		//update min in stack
	add	j, i, 1				// j = i + 1
	str	j, [fp, j_s]			//store j in stack
	b	test_i				//branch to test for inner loop
		
inner:	ldr	min, [fp, min_s]		//load min
	ldr	j, [fp, j_s]			//load j
	ldr	v_j, [base, j, sxtw 2]		//load v[j]	
	ldr	v_min, [base, min, sxtw 2]	//load v[min]

	//if v[j] < v[min]
	cmp	v_j, v_min			//compare v[j] v[min]
	b.ge	inc_j				// if v[j] >= v[min] go to inc_j

	mov	min, j				// min = j
	str	min,[fp, min_s]			//update value of min in stack
	
	//increment j
inc_j:	add	j, j, 1				//increase j
	str	j,[fp, j_s]			//update value of j in stack

	
	//test for inner for loop
test_i:	ldr	j, [fp, j_s]			//load j
	cmp	j, array_count			//compare j and SIZE
	b.lt	inner				// j < SIZE inner loop

	//swap elements
swap:	ldr	min,[fp, min_s]			//load min
	ldr	i, [fp, i_s]			//load i
	ldr	v_min, [base, min, sxtw 2]	//load v[min]
	str	v_min, [fp, temp_s]		// temp = v[min] in memory
	ldr	v_i, [base, i, sxtw 2]		// load v[i] to w27
	str	v_i, [base, min, sxtw 2]	//v[min] = v[i]
	ldr	temp, [fp, temp_s]		//load temp
	str	temp, [base, i, sxtw 2]		//v[min] = temp



	//increment i
	add	i, i, 1				//increase i
	str	i, [fp, i_s]			//store i in memory
	add	j, i, 1				//calculate j again
	str	j, [fp, j_s]			//store j in memory


	//test for the outer for loop
test_o:	ldr	i, [fp, i_s]			//load i into register
	cmp	i, array_count - 1		// compare i < SIZE-1
	b.lt	outer				//if i >= size-1, end the loop


end: 	adrp	x0, fmt2			//push "Sorted array" intO x0
	add	x0, x0, :lo12:fmt2		//magic
	bl	printf				//print "Sorted array"

	//reset i = 0

	mov	i, 0				//set i = 0
	str	i, [fp, i_s]			//push i to stack
	b	test4				//branch to test4

loop4:	adrp	x0, fmt				//push fmt string to x0
	add	x0, x0, :lo12:fmt		//magic
	ldr	w1, [fp, i_s]			//arg1 = i
	ldr	i, [fp,i_s]			//load i into w19
	ldr	w2, [base, i, sxtw 2]		//arg2: v[i]
	bl	printf				//print statement
	add	i, i, 1				//i++
	str	i, [fp, i_s]			//update i in stack

test4:	ldr	i, [fp, i_s]			//load i from memoery
	cmp	i,array_count			// i < size
	b.lt	loop4				// if i < size run loop4


	mov	w0,0				//return 0
	ldp	fp, lr, [sp],dealloc		//deallocate memory
	ret					//restore state
