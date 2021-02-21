scanner : lexical.c parse.tab.c parse.tab.h LinkedList.o
	@gcc lexical.c parse.tab.c LinkedList.o -lfl -lm -std=c99 -D_XOPEN_SOURCE=700 -o scanner 

lexical.c : lexical.l parse.tab.h
	@flex -o lexical.c lexical.l

parse.tab.c parse.tab.h : parse.y
	@bison -d parse.y
	
LinkedList.o : LinkedList.c LinkedList.h
	@gcc -c LinkedList.c -std=c99

clean : 
	rm lexical.c LinkedList.o parse.tab.c parse.tab.h scanner

