//define macros

MAXVAL = 100				//assembler equates for MAXVAL
BUFSIZE = 100				//Assembler equates for BUFSIZE
NUMBER = '0'				//Assembler equates for NUMBER
TOOBIG = '9'				//Assembler equates for TOOBIG


define(sp_r, w10)			// always put value of sp in w19
define(temp_a, x20)
define(bufp_r, w22)			//always put bufp_r in w22


		.data
sp_m:		.word	0		// initialize sp in memory
bufp_m:		.word	0		//initialize bufp in memory
	
		.bss
val_m:		.skip	MAXVAL * 4	//initialize val[MAXVAL] in memory
buf_m:		.skip	BUFSIZE * 4	//initialize buf[BUFSIZE] in memory


		.text

		//make the following vars global
		.global sp_m
		.global val_m
		.global buf_m
		.global bufp_m
		
fmt:  		.string	"error: stack full\n"			//sring for push
pop_str:	.string	"error: stack empty\n"			//error string for pop
un_str:		.string	"ungetch: too many characters \n"	//errpr string for ungetch	
		.balign 4


//----------------PUSH------------------------------------------------------------//	  
		.global push				//make push visible to Main

push:		stp	x29, x30, [sp, -16]!		//allocate memory
		mov 	x29, sp				//mov sp to x29
		
		adrp	temp_a, sp_m			// get the address of sp
		add	temp_a, temp_a, :lo12:sp_m	// add the low 12 bits to the address
		ldr	sp_r, [temp_a]			//retreive sp from memory
			
		cmp	sp_r, MAXVAL			//if sp < MAXVAL
		b.ge	else				//if sp >= MAXVAL branch to else
			
		//if block
		adrp	temp_a, val_m			//get base address for val array
		add	temp_a, temp_a,:lo12:val_m	//add low 12 bits of val array
		str	w0, [temp_a, sp_r, SXTW 2]	//store value of f in array[sp] 
			
		add	sp_r, sp_r, 1			//increment sp
		adrp	temp_a, sp_m			//load address of sp in x20
		add	temp_a, temp_a,:lo12:sp_m	//load low 12 bits of sp in x20
		str	sp_r, [temp_a]			//store sp++ into memory
		
		b	end				//branch to end of subroutine
			
else:		adrp	x0, fmt				//calculate the address of fmt
		add	x0, x0, :lo12:fmt		//add low 12 bits
		bl 	printf				//print error msg
		bl	clear				//clear()
		mov	w0, 0				//return 0
				
end:		ldp	x29, x30, [sp], 16		//deallocate memory
		ret					//restore state

//----------------POP-----------------------------------------------------//

		.global pop				//make pop visible to OS

pop:		stp	x29, x30, [sp, -16]!		//allocate memory
		mov	x29, sp				//deallocate memory
		
		adrp	x9, sp_m			//put address of sp into x20
		add	x9, x9,:lo12:sp_m		//calculate lower 12 bits
		ldr	sp_r, [x9]			//sp_r = sp from memoy

		cmp	sp_r, 0				//if sp > 0
		b.le	pop_else			// if sp <= 0 branch to else
		
		//if block
		sub	sp_r, sp_r, 1			//sp--
		str	sp_r, [x9]			//store sp in memory

		adrp	x11, val_m			//calculate address of val array
		add	x11, x11,:lo12:val_m		//calulate lower 12 bits
		ldr	w0, [x11, sp_r, SXTW 2]		//load val[--sp] into w22

		b	pop_end				//branch to the end of pop

pop_else:	adrp	x0, pop_str			//calculate address of pop_str
		add	x0, x0, :lo12:pop_str		//calculate low 12 bits
		bl	printf				//printf
		bl	clear				//clear()
		mov	w0, 0				//return 0

pop_end:	ldp	x29, x30, [sp], 16		//deallocate memory
		ret					//restore state


//--------------CLEAR--------------------------------------------------------//			

		.global clear				//make clear visible to main
			
clear:		stp	x29, x30, [sp, -16]!		//allocate memory	
		mov	x29, sp				//mov sp to x29
			
		adrp	x9, sp_m			//calculate address of sp_m
		add	x9, x9, :lo12:sp_m	//calcualte lower 12 bits
		ldr	sp_r, [x9]			//put sp into sp_r
			
		mov	sp_r, 0				// sp = 0
		str	sp_r, [x9]			//store sp in memory
			
		ldp	x29, x30, [sp], 16		//deallocate memory	
		ret					//restore state

//-----------------GETCH----------------------------------------------//

		.global getch

getch:		stp	x29, x30, [sp, -16]!		//allocate memory
		mov	x29, sp				//mov sp to x29

		adrp	temp_a, bufp_m			//get address of bufp
		add	temp_a, x20, :lo12:bufp_m	//add lower 12 bits
		ldr	bufp_r, [x20]			//bufp_r = bufp

		cmp	bufp_r, 0			// if bufp > 0
		b.le	else_gech			//branch if bufp >= 0

		sub	bufp_r, bufp_r, 1		//decrease bufp_r

		adrp	x21, buf_m			//base address of buf[] into x20
		add	x21, x21, :lo12:buf_m		//add the lower 12 bits
		ldr	w9, [x21, bufp_r, SXTW 2]	//load buf[--bufp] into w9
		mov	w0, w9				//return buf[--bufp] 
		str	bufp_r, [temp_a]		//store value of bufp into memory

		b	get_end				//branch to the end
	
else_gech:	bl	getchar				//branch to getchar in C			

get_end:	ldp	x29,x30,[sp], 16		//deallocate memory
		ret 					//restore state


//--------------------UNGETCH--------------------------------------------//
		
		.global ungetch				//make this function visible

ungetch:	stp	x29, x30, [sp, -16]!		//allocate memory
		mov	x29, sp				//mov sp to x29

		adrp	temp_a, bufp_m			//calculate address of bufp_m	
		add	temp_a, temp_a, :lo12:bufp_m	//calculate the lower 12 bits
		ldr	bufp_r, [temp_a]		//bufp_r = bufp

		cmp	bufp_r, BUFSIZE			//if bufp_r> BUFSIZE
		b.le	un_else				//if bufp_r <= BUFSIZE

		//if block
		adrp	x0, un_str			//set up error sstatement
		add	x0, x0, :lo12:un_str		//calcualte lo12 bits
		bl	printf				//print
		b	unc_end				//go to end

un_else:	adrp	x21, buf_m			//calculate address of buf_m
		add	x21, x21, :lo12:buf_m		//calculate lo12 bits
		str	w0, [x21, bufp_r, SXTW 2]	//buf[bufp] = c

		add	bufp_r, bufp_r, 1		//bufp++
		str	bufp_r, [temp_a]		//store in memory

unc_end:	ldp	x29, x30, [sp], 16		//deallocate memory
		ret					//restore state

//------------------------GETOP-----------------------------------------------//
/*                .global getop                           //make this function visible to Main
		
		.data
                i_m = 0                                //declare i in stack
                c_m = 4                                //declare c in stack
		
		i_size = 4
		c_size = 4

                alloc = -(16 + i_size + c_size) & -16
                dealloc = -alloc
		TOOBIG = '9'
		NUMBER = '0'

		.text
		.balign 4

getop:          stp     x29, x30, [sp, alloc]!          //allocate memory
                mov     x29, sp                         //mov sp to x29

		mov	x19, i_m			//move address of i_m into x19
		mov	x20, c_m			//move address of c_m into x20
		
		mov	x14, x0				// pass *s into x14
		
		mov	w15, w1				// pass lim into w15


while:		bl	getch
		mov	w9, w0				//put c from getch to w9

		str	w9, [x20]			//store c in memory

		cmp	w9, ' '				//if c == ' '
		b.eq	while				//go back to while

		cmp	w9, '\t'			//if c = '/t'		
		b.eq	while				//go back to while

		cmp	w9, '\n'			// if c = '/n'
		b.eq	while				//back to while loop

		// check if (c < '0' || c > '9')
		cmp	w9, '0'				//compare c to 0
		b.lt	if_1				//if c < '0' branch to if_1

		cmp	w9, '9'				//compare c to 9
		b.gt	if_1				//if c > '9' branch to if_1
		b	set_c				// go to set c s[0] = c

if_1:		mov	w0, w9				//return c 
		
set_c:		mov	w10, 0				//set i to 0
		str	w10, [x29, i_m]			//store i in memory
		strb	w9, [x14, w10, SXTW]		//store s[0] = c
		mov	w10, 1				// set i to 1
		str	w10, [x29, i_m]			//store i in memory

		b 	for_test			//do the for loop test


for_loop:	str	w11, [x24]			//store lim in w11
		str	w10, [x19]			//store i in w10
		cmp 	w10, w11			// compare to lim
		b.ge	i_inc				// if i >= lim , increment i		

		strb	w9, [x22, w10, SXTW]		//s[i] = c

i_inc: 		add	w10, w10, 1			// i++
		str	w10, [x19]			//store i in memory
	
for_test:	bl	getchar				//getchar()
		ldr	w10, [x19]			//load i from memory
		mov	w9, w0				//get c from getchar

		cmp	w9, '0'				//check if c >= '0'
		b.lt	if_test2			//if c < '0' go to if2

		cmp	w9, '9'				//if c > '9' go to if_2
		b.ge	if_test2			//^

		//if statement
if_2:		mov	w0,  w9				//move c to w0
		bl	ungetch				//branch to ungetch
		mov	w12, '\0'			//set w12 = '/0'
		str	w12, [x14, w10, SXTW 2]		//s[i] = '\0'	
		ldr	w0, NUMBER			//return NUMBER
		b	op_end				//branch to end of program

if_test2:	ldr	w10, [x19]			//load i from memory
		cmp	w10, w15			//compare i and lim
		b.lt	if_2				//branch to else

		//else block
		ldr	w9, [x20]			//load c into w9

while_2:	cmp	w9, '\n'			//compare c to 'n'
		b.eq	end1

		cmp	w9, -1				//compare c to EOF
		b.eq 	end1				// if c = EOF end program

		bl	getchar				// getchar()
		mov	w9, w0				//c = getchar
		str	w9, [x20]			//store c in memory
		b	while_2
		
end1:		sub	w15, w15, 1			//lim-1
		mov	w12, '\0'			// w12 = '/0'
		str	w12, [x14, w15, SXTW 2]		//s[lim-1] = '/0'
		mov	w0, TOOBIG			//return TOOBIG		

op_end:		ldp     x29, x30, [sp], dealloc         //deallocate memory
                ret                                     //restore state
*/
