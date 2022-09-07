TARGET = li

CC = gcc
ASM = as

CC_FLAGS = -g -Wall -Wextra -pedantic
CCASM_FLAGS = -g -static
ASM_FLAGS = -a --gstabs

all: $(TARGET) clear

$(TARGET): main.o rawMod.o open.o escMode.o
	$(CC) $(CCASM_FLAGS) $^ -o $@

main.o: src/main.s
	as $(ASM_FLAGS) -o $@ $^ 1>/dev/null

rawMod.o: src/rawMod.c
	$(CC) $(CC_FLAGS) -c $^

open.o: src/open.s
	as $(ASM_FLAGS) -o $@ $^ 1>/dev/null

escMode.o: src/escMode.s
	as $(ASM_FLAGS) -o $@ $^ 1>/dev/null

clear:
	rm -fr *.o

clean:
	rm -fr li
