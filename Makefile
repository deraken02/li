all: li clear

li: main.s rawMod.o
	gcc -g -static $^ -o $@

rawMod.o: rawMod.c
	gcc -c -Wall -Wextra -pedantic $<

clear:
	rm -fr *.o
