prtx:       .string "The value of x: %4d, y: %4d, max: %4d\n" 

            .global main
	    .balign 4


main:       stp     x29, x30, [sp, -16]!
            mov     x29, sp

            mov     x19, -10         //store value x = -10 in x19
            mov     x21, -50000      //store value of max = -100 in x21
            mov     x22, -2          //store -2 in x22
            mov     x23, -22         //store -22 in x23
            mov     x24, 11          //store 11 in x24

test:       cmp     x19, 4           // test whether x <=4
            b.gt    done             //if x > 4, terminate

            //loop body
		
top:        mul     x25, x19, x19   //store the vlaue of x^2 in x25
            mul     x27, x23, x25   //update value of x23 to -22x^2
            mul     x25, x25, x19   //update value of x25 to x^3
            mul     x26, x22, x25   //update value of x22 to -2x^3
            mul     x28, x24, x19   //update value of x24 to 11x
      
            // start calculating the polynomial
	    add     x20, x26, x27    //update value of x20 to -2x^3 -22x^2   
            add     x20, x20, x28    //update value of x20 to -2x^3-22x^2+11x
            add     x20, x20,  57    //update value of x20 to -2x^3 -22 x^2 +11x + 57
	


	    cmp     x20, x21	   //compares the value of max and y
	    b.lt    print	   //if y < max, move on to print	
	    mov     x21, x20	   // if y > max, move y into max(x20)		
					

            //move x, y, max into correct registers for printing
            
print:      mov     x1, x19         // move x value to x1
            mov     x2, x20         // move y value to x2
       	    mov	    x3, x21	    // move max value to x3

	     
            adrp    x0, prtx        // print value of x,y, max
            add     x0, x0, :lo12:prtx
            bl      printf

            add     x19, x19, 1      // x ++
	    b	    test

done:       mov     x0, 0	     //reset the x0, x1, x2 registers	
	    mov     x1, 0
	    mov     x2, 0
	    mov     x3, 0
	    ldp     x29, x30, [sp], 16
            ret

