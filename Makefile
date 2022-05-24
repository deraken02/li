TARGET = li

CC = gcc
ASM = as

CC_FLAGS = -Wall -Wextra -pedantic
CCASM_FLAGS = -g -static
ASM_FLAGS = -a --gstabs

all: $(TARGET) help clear

$(TARGET): src/main.s rawMod.o open.o escMode.o
	$(CC) $(CCASM_FLAGS) $^ -o $@

rawMod.o: src/rawMod.c
	$(CC) -c $(CC_FLAGS) $<

open.o: src/open.s
	as $(ASM_FLAGS) -o $@ $^ 1>/dev/null

escMode.o: src/escMode.s
	as $(ASM_FLAGS) -o $@ $^ 1>/dev/null

help: src/help.s
	$(CC) $(CCASM_FLAGS) $^ -o $@

clear:
	rm -fr *.o

clean:
	rm -fr help li
