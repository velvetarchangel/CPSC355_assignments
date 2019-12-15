all:	a5aMain.o a5a.o
	gcc -o a5a a5aMain.o a5a.o -g3

a5aMain.o: a5aMain.c
	   gcc -c a5aMain.c -g3

a5a.o:	    a5a.asm
	    m4 a5a.asm > a5a.s
	    as a5a.s -o a5a.o -g3
