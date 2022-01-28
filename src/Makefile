TARGET = ../li

CC = gcc
ASM = as

CC_FLAGS = -Wall -Wextra -pedantic
CCASM_FLAGS = -g -static
ASM_FLAGS = -a --gstabs

all: $(TARGET) clear

$(TARGET): main.s rawMod.o open.o
	$(CC) $(CCASM_FLAGS) $^ -o $@

rawMod.o: rawMod.c
	gcc -c $(CC_FLAGS) $<

open.o: open.s
	as $(ASM_FLAGS) -o $@ $^ 1>/dev/null

clear:
	rm -fr *.o
