/* Copyright (c) 2022 Delacroix Louis */
.data
char:
    .byte 0
CursorDown:
    .string "\033[B"
CursorRight:
    .string "\033[C"
CursorLeft:
    .string "\033[D"

CursorUp:
    .string "\033[A"
PosTerm:
    .string "\033[6n"
line:
    .int    0
col:
    .int    0
.text


/**
 * Get the line and the column number and complete the global variable
 * @return the column number
 */
.global getPosition
.type   getPosition, @function
getPosition:
    pushq   %rbp
    movq    %rsp, %rbp

    movl    $4, %edx
    movl    $PosTerm, %esi
    movl    $1, %edi
    movl    $1, %eax
    syscall
    movl    $2, %edx        /* Clean the beginning of the return value */
    movl    $char, %esi
    movl    $0, %edi
    movl    $0, %eax
    syscall
    movq    $0, %r8
    jmp     .loopLine
.addLoopLine:
    cmp     $0, %r8
    je      continueLine
    imulq   $10, %r8
continueLine:
    movb    char, %al
    movq    $48, %rbx
    subq    %rbx, %rax
    addq    %rax, %r8
.loopLine:
    movl    $1, %edx
    movl    $char, %esi
    movl    $0, %edi
    movl    $0, %eax
    syscall
    movb    char, %al
    cmp     $59, %al
    jne     .addLoopLine
    movq    %r8, line
    movq    $0, %r8
    jmp     .loopCol
.addLoopCol:
    cmp     $0, %r8
    je      continueCol
    imulq   $10, %r8
continueCol:
    movb    char, %al
    movq    $48, %rbx
    subq    %rbx, %rax
    addq    %rax, %r8
.loopCol:
    movl    $1, %edx
    movl    $char, %esi
    movl    $0, %edi
    movl    $0, %eax
    syscall
    movb    char, %al
    cmp     $82, %al
    jne     .addLoopCol
    movq    %r8, col

    movq    %r8, %rax
    movq    %rbp, %rsp
    pop     %rbp
    ret

.global MoveCursorLeft
.type   MoveCursorLeft, @function
/**
 * Move visually the cursor to the left
 * @return none
 * Note: the function don't verify the current position of the visual cursor
 */
MoveCursorLeft:
    push    %rbp
    movq    %rsp, %rbp

    movq    $1, %rax
    movq    $1, %rdi
    movq    $CursorLeft, %rsi
    movq    $3, %rdx
    syscall

    movq    %rbp, %rsp
    pop     %rbp
    ret

.global MoveCursorRight
.type   MoveCursorRight, @function
/**
 * Move visual the cursor to the cursor
 * @return none
 * Note: the function don't verify the current position of the visual cursor
 */
MoveCursorRight:
    push    %rbp
    movq    %rsp, %rbp

    movq    $1, %rax
    movq    $1, %rdi
    movq    $CursorRight, %rsi
    movq    $3, %rdx
    syscall

    movq    %rbp, %rsp
    pop     %rbp
    ret

.global MoveCursorUp
.type   MoveCursorUp, @function
/**
 * Move visually the cursor to the up
 * @return none
 * Note: the function don't verify the current position of the visual cursor
 */
MoveCursorUp:
    push    %rbp
    movq    %rsp, %rbp

    movq    $1, %rax
    movq    $1, %rdi
    movq    $CursorUp, %rsi
    movq    $3, %rdx
    syscall

    movq    %rbp, %rsp
    pop     %rbp
    ret

.global MoveCursorDown
.type   MoveCursorDown, @function
/**
 * Move visual the cursor to the down
 * @return none
 * Note: the function don't verify the current position of the visual cursor
 */
MoveCursorDown:
    push    %rbp
    movq    %rsp, %rbp

    movq    $1, %rax
    movq    $1, %rdi
    movq    $CursorDown, %rsi
    movq    $3, %rdx
    syscall

    movq    %rbp, %rsp
    pop     %rbp
    ret

.global getLine
.type   getLine, @function
/**
 * Getter of the line number variable
 * @return : the line number as an int
 * Note: the line number is updated by the function getPosition
 */
getLine:
    push    %rbp
    movq    %rsp, %rbp

    movq    line, %rax

    movq    %rbp, %rsp
    pop     %rbp
    ret

.global getCol
.type   getCol, @function
/**
 * Getter of the column number variable
 * @return : the column number as an int
 * Note: the line number is updated by the function getPosition
 */
getCol:
    push    %rbp
    movq    %rsp, %rbp

    movq    col, %rax

    movq    %rbp, %rsp
    pop     %rbp
    ret
