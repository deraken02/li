all: li clear

li: li.o
	ld -o li li.o	
li.o:
	as -a --gstabs -o li.o main.s

clear:
	rm -fr *.o
