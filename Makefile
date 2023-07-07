TARGET = li

CC = gcc
ASM = as

CC_FLAGS = -g -Wall -Wextra -pedantic
CCASM_FLAGS = -g -static
ASM_FLAGS = -a --gstabs

all: $(TARGET) clear

$(TARGET): main.o rawMod.o open.o escMode.o tui.o cursor.o
	$(CC) $(CCASM_FLAGS) $^ -o $@

test: open.o escMode.o tui.o cursor.o
	$(CC) $(CCASM_FLAGS) $^ tests/test_main.c -o $@
	@rm -fr *.o

main.o: src/main.s
	$(ASM) $(ASM_FLAGS) -o $@ $^ 1>/dev/null

cursor.o: src/cursor.s
	$(ASM) $(ASM_FLAGS) -o $@ $^ 1>/dev/null

tui.o: src/tui.s
	$(ASM) $(ASM_FLAGS) -o $@ $^ 1>/dev/null

rawMod.o: src/rawMod.c
	$(CC) $(CC_FLAGS) -c $^

open.o: src/open.s
	$(ASM) $(ASM_FLAGS) -o $@ $^ 1>/dev/null

escMode.o: src/escMode.s
	$(ASM) $(ASM_FLAGS) -o $@ $^ 1>/dev/null

clear:
	@rm -fr *.o
	@echo "Compilation complete"
	@cat .cache/logo-li.txt
	@shuf -n 1 .cache/acronyme.txt

clean:
	rm -fr li test
