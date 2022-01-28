all: li clear

li: main.s rawMod.o open.o
	gcc -g -static $^ -o $@

rawMod.o: rawMod.c
	gcc -c -Wall -Wextra -pedantic $<

open.o: open.s
	as -a --gstabs -o $@ $^ 1>/dev/null

clear:
	rm -fr *.o
