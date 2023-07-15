/* Copyright (c) 2023 Delacroix Louis */
.data
char:
    .byte 0
file_size:
    .quad 0
pos:
    .quad 0
fd:
    .int 1
UselessVar:
    .string "\033[C"
eraseTerm:
    .string "\033[H\033[J"
buffer:
    .space 2048
.text

.global setFd
.type setFd, @function
/**
 * Set the file descriptor in the tui
 * @param fd the file descriptor
 * @return none
 */
setFd:
    push %rbp
    movq %rsp, %rbp

    movq %rax, fd

    movq %rbp, %rsp
    popq %rbp
    ret

.global displayContent
.type displayContent, @function
/**
 * Display the content of the file
 * @param fd the file descritor
 * @param stat the pointer of the struct stat
 * @return void
 */
 displayContent:
    push %rbp
    movq %rsp, %rbp

    call goBegin
    movq $8, %rax   /* sys_lseek*/
    movq $0, %rsi   /* offset*/
    movq $2, %rdx   /* SEEK_SET*/
    syscall
    pushq %rax
    call goBegin
.reader:
    popq %rdx
    movq $0, %rax           /* Read the content */
    movq $buffer, %rsi
    syscall
    movq $1, %rdi           /* on the standard output*/
    movq $1, %rax
    syscall
.endDisplayContent:
    movq %rdx, %rax  /* Return the size of the file */
    movq %rbp, %rsp
    pop %rbp
    ret


.global clearTerm
.type clearTerm, @function
/**
 * Erase the content of the terminal
 * @return: none
 */
clearTerm:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq $1, %rax /*syscall write*/
    movq $1, %rdi /*File Descriptor*/
    movq $eraseTerm, %rsi /*addresse du buffer*/
    movq $6, %rdx /*nombre d'octet à écrire*/
    syscall       /*Appel le noyau*/

    movq %rbp, %rsp
    pop %rbp
    ret

.global setFileSize
.type setFileSize, @function
/**
 * Set the size and fix the pos
 * @return: none
 */
setFileSize:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq %rdi, file_size
    movq %rdi, pos

    movq $0, %rax
    movq %rbp, %rsp
    pop %rbp
    ret

.global incSize
.type incSize, @function
/**
 * Increase the variable file_size of 1
 * @return: the new size
 */
incSize:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq file_size, %rax
    inc %rax
    movq %rax, file_size

    movq %rbp, %rsp
    pop %rbp
    ret

.global incPos
.type incPos, @function
/**
 * Increase the variable file_size of 1
 * @return: the new position
 */
incPos:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq pos, %rax
    movq file_size, %rbx
    cmp %rax, %rbx
    jne .not_inc_size
    call incSize
.not_inc_size:
    inc %rax
    movq %rax, pos

    movq %rbp, %rsp
    pop %rbp
    ret

.global decPos
.type decPos, @function
/**
 * Decrease the variable file_size of 1
 * @return: the new position
 */
decPos:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq pos, %rax
    dec %rax
    movq %rax, pos

    movq %rbp, %rsp
    pop %rbp
    ret

.global decSize
.type decSize, @function
/**
 * Increase the variable file_size of 1
 * @return: the new size
 */
decSize:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq file_size, %rax
    dec %rax
    movq %rax, file_size

    movq %rbp, %rsp
    pop %rbp
    ret

.global previousChar
.type previousChar, @function
/**
 * Simple implementation to move the offset onto the previous charactere and move the visual cursor to the left
 * @return: none
 */
previousChar:
    push    %rbp   /*Sauvegarde le pointeur de base*/
    movq    %rsp, %rbp

    movq    pos, %rax
    cmp     $0, %rax
    je      endPreviousChar
    call    getPosition
    cmp     $1, %rax    /* Verify if the pointer are not in the first column*/
    je      endPreviousChar
    call    decPos
    movq    $8, %rax   /*sys_lseek*/
    movq    fd, %rdi
    movq    pos,%rsi   /*offset*/
    movq    $0, %rdx   /*SEEK_SET*/
    syscall
    call    MoveCursorLeft
endPreviousChar:
    movq    %rbp, %rsp
    pop     %rbp
    ret

.global nextChar
.type nextChar, @function
/**
 * Simple implementation to move the offset in the next charactere and move the visual cursor to the right
 * @return: none
 */
nextChar:
    push    %rbp   /*Sauvegarde le pointeur de base*/
    movq    %rsp, %rbp

    movq    pos, %rax
    movq    file_size, %rbx
    cmp     %rax, %rbx
    je      endNextChar
    call    incPos
    movq    $8, %rax   /*sys_lseek*/
    movq    fd, %rdi
    movq    pos,%rsi   /*offset*/
    movq    $0, %rdx   /*SEEK_SET*/
    syscall
    call    MoveCursorRight
endNextChar:
    movq    %rbp, %rsp
    pop     %rbp
    ret

.global upChar
.type upChar, @function
/**
 * Simple implementation to move in the up charactere and move the cursor to the up
 * @return: none
 */
upChar:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq pos, %rax
    cmp  $0, %rax
    je   .end_upChar
    call getPosition
    movq %rax, %rdi         /* Move the column number*/
    call getLine
    cmp  $1, %rax            /* Verify if the pointer are not in the first line*/
    je .end_upChar
    movq %rdi, %rax
    pushq %rax
    inc  %rax
    movq $1,   %r8
.beginLenLine:
    call goToLeft
    call getNextChar
    cmp  $10,  %rax
    je .endLenLine
    inc  %r8
    movq $1,   %rax
    jmp .beginLenLine
    call incPos
.endLenLine:
    popq %rax
    cmp  %r8, %rax  /* compare the size of the line r8 and the column of the cursor rax*/
    jl .upLineQuiteLong
    pushq %r8
    subq %r8, %rax
    movq %rax, %r8
    inc  %r8
.shiftCursorToLeft:
    call MoveCursorLeft
    dec  %r8
    cmp  $1, %r8
    jne .shiftCursorToLeft
    popq %rax
    dec  %rax
.upLineQuiteLong:
    dec  %rax
    call goToRight
    call MoveCursorUp

.end_upChar:
    movq %rbp, %rsp
    pop %rbp
    ret

.global downChar
.type downChar, @function
/**
 * Simple implementation to move in the down charactere and move the cursor to the down
 * @return: none
 */
downChar:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq pos, %rbx
    movq file_size, %rcx
    cmp  %rbx, %rcx
    je   .end_downChar
    call getPosition
    pushq %rax
.goToEndOfLine:
    call getNextChar
    movq %rax, %rdi
    call incPos
    movq pos, %rbx
    movq file_size, %rcx
    cmp  %rbx, %rcx
    je   .EOF
    cmp  $10, %rdi
    jne  .goToEndOfLine
    call getCol
    movq pos, %rbx
    movq file_size, %rcx
    subq %rbx, %rcx
    cmp  %rax, %rcx
    jl   .EOF
    pop  %r8
.loopRight:
    cmp  $1, %r8
    je  .moveDown
    call incPos
    call getNextChar
    dec  %r8
    cmp  $10, %rax
    jne  .loopRight
.moveLeft:
    cmp $0, %r8
    jne .moveDown
    call MoveCursorLeft
    dec %r8
    jmp .moveLeft
.moveDown:
    call MoveCursorDown
    jmp .end_downChar
.EOF:
    pop %r8
    call clearTerm
    call displayContent
.end_downChar:
    movq %rbp, %rsp
    pop %rbp
    ret



.global erase
/**
 * Erase the charactere before the cursor
 * @return: none
 */
.type erase, @function
erase:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq $0, %r8
    movq pos, %rax
    movq file_size, %rdx
    cmp $0, %rdx            /* The file is empty */
    je .end_erase
    cmp %rax, %rdx          /* The pointer is on the end of the file */
    je .truncate_the_end
    subq %rax, %rdx
    movq $0, %rax
    movq fd, %rdi
    movq $buffer, %rsi
    syscall
    pushq %rax
    call previousChar
    popq %rdx
    movq fd, %rdi
    movq $buffer, %rsi
    movq $1, %rax
    syscall
    movq %rax, %r8
.truncate_the_end:
    call decSize
    movq $77, %rax          /* sys_ftruncate */
    movq fd, %rdi
    movq file_size, %rsi
    syscall
    call clearTerm
    movq fd, %rdi
    call displayContent
    movq file_size, %rdi
    call setFileSize
    cmp $0, %r8
    je .end_erase
    movq %r8, %rdi
    call shiftLeft
.end_erase:
    movq %rbp, %rsp
    pop %rbp
    ret


/**
 * Shift the pointer and the cursor to the left n times
 * @param n the number of shift
 * @return real number of shift
 */
.global shiftLeft
.type shiftLeft, @function
shiftLeft:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq $0, %rax
    pushq %rax
    movq %rdi, %r8
.loop_shift_left:
    cmp $0, %r8
    je .end_shift
    movq pos, %rax
    cmp $0, %rax
    je .end_shift
    call previousChar
    popq %rax
    inc %rax
    pushq %rax
    dec %r8
    jmp .loop_shift_left
.end_shift:
    popq %rax
    movq %rbp, %rsp
    pop %rbp
    ret

/**
 * Shift the pointer to the left n times
 * @param n the number of shift 
 * @return number of shift doned
 * @notes the global variable pos will be modified
 */
.global goToLeft
.type goToLeft, @function
goToLeft:
    push %rbp
    movq %rsp, %rbp

    cmp  $0,  %rax
    je .endGoToLeft
    movq %rax,%rcx
    movq %rax,%rbx
.goToLeftLoop:
    movq pos, %rax
    cmp  $0,  %rax
    je .endGoToLeft
    call decPos
    loop .goToLeftLoop
    movq $8,  %rax
    movq fd,  %rdi
    movq pos, %rsi
    movq $0,  %rdx
    syscall

    movq %rbx, %rax
    subq %rax, %rcx
.endGoToLeft:
    movq %rbp, %rsp
    pop  %rbp
    ret

/**
 * Shift the pointer to the right n times
 * @param n the number of shift 
 * @return number of shift doned
 * @notes the global variable pos will be modified
 */
.global goToRight
.type goToRight, @function
goToRight:
    push %rbp
    movq %rsp, %rbp

    cmp  $0,  %rax
    je .endGoToRight
    movq %rax,%rcx
    movq %rax,%rbx
.goToRightLoop:
    movq pos, %rax
    movq file_size, %r8
    cmp  %r8, %rax
    je .endGoToLeft
    call incPos
    loop .goToRightLoop
    movq $8,  %rax
    movq fd,  %rdi
    movq pos, %rsi
    movq $0,  %rdx
    syscall

    movq %rbx, %rax
    subq %rax, %rcx
.endGoToRight:
    movq %rbp, %rsp
    pop  %rbp
    ret

.global getNextChar
.type getNextChar, @function
getNextChar:
    pushq   %rbp
    movq    %rsp, %rbp

    movq $0, %rax
    movq fd, %rdi
    movq $char, %rsi
    movq $1, %rdx
    syscall
    movb char, %al

    movq %rbp, %rsp
    pop %rbp
    ret

.global goBegin
.type goBegin, @function
/**
 * Go to the beginning of the file
 */
goBegin:
    push %rbp
    movq %rsp, %rbp

    movq $8, %rax   /* sys_lseek*/
    movq fd, %rdi
    movq $0, %rsi   /* offset*/
    movq $0, %rdx   /* SEEK_SET*/
    syscall

    movq %rbp, %rsp
    pop %rbp
    ret

