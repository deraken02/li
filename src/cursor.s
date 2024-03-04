/* Copyright (c) 2022 Delacroix Louis */
.data
CursorUp:
    .string "\033[A"
CursorDown:
    .string "\033[B"
CursorRight:
    .string "\033[C"
CursorLeft:
    .string "\033[D"
PosTerm:
    .string "\033[6n"
line:
    .int    0
col:
    .int    0
char:
    .byte 0
.text


/**
 * Get the line and the column number and complete the global variable
 * @return the column number
 */
.global get_position
.type get_position, @function
get_position:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $4, %rdx
    movq    $PosTerm, %rsi
    movq    $1, %rdi
    movq    $1, %rax
    syscall
    movq    $16, %rdx
    movq    $0, %rdi
    movq    $0, %rax
    syscall             /* Get string Esc[l;cR */
    addq    $2, %rsi
    movq    $0, %rbx
.get_line:
    movb    (%rsi), %al
    cmp     $0, %rax
    je .end_get_pos
    cmp     $82, %rax     /*compare with R*/
    je .end_get_pos
    cmp     $59, %rax     /*compare with ;*/
    je  .init_column
    cmp     $48, %rax     /*compare with 0*/
    jl  .get_line
    imulq   $10, %rbx
    subq    $48, %rax
    addq    %rax, %rbx
    inc     %rsi
    jmp .get_line
.init_column:
    inc     %rsi
    movq    %rbx, line
    movq    $0, %rbx
.get_column:
    movb    (%rsi), %al
    cmp     $0, %rax
    je .end_get_pos
    cmp     $82, %rax     /*compare with R*/
    je .end_get_pos
    cmp     $59, %rax     /*compare with ;*/
    je  .init_column
    cmp     $48, %rax     /*compare with 0*/
    jl  .get_column
    imulq   $10, %rbx
    subq    $48, %rax
    addq    %rax, %rbx
    inc     %rsi
    jmp .get_column
.end_get_pos:
    movq    %rbx, col
    movq    %rbx, %rax
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

    mov    line, %eax

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
