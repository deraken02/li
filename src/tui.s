/* Copyright (c) 2024 Delacroix Louis */
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

.global set_fd
.type set_fd, @function
/**
 * Set the value of the file descriptor
 * @param fd the file descriptor
 * @return void
 */
set_fd:
    push %rbp
    movq %rsp, %rbp

    movq %rdi, fd

    movq %rbp, %rsp
    pop  %rbp
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

.global inc_pos
.type inc_pos, @function
/**
 * Increase the variable file_size of 1
 * @return: the new position
 */
inc_pos:
    push    %rbp   /*Sauvegarde le pointeur de base*/
    movq    %rsp, %rbp

    movq    pos, %rax
    movq    file_size, %rbx
    cmp     %rax, %rbx
    jne .not_inc_size
    call    incSize
.not_inc_size:
    inc     %rax
    movq    %rax, pos

    movq    %rbp, %rsp
    pop     %rbp
    ret

.global inc_n_pos
.type inc_n_pos, @function
/**
 * Increase the variable file_size of n
 * @param n the number to increase
 * @return: the new position
 */
inc_n_pos:
    push    %rbp   /*Sauvegarde le pointeur de base*/
    movq    %rsp, %rbp

    movq    pos, %rcx
    addq    %rax, %rcx
    movq    file_size, %rbx
    cmp     %rcx, %rbx
    jg  .not_inc_n_size
    movq    %rcx, file_size
.not_inc_n_size:
    movq    %rcx, pos

    movq    %rbp, %rsp
    pop     %rbp
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

.global dec_n_pos
.type dec_n_pos, @function
/**
 * Decrease the variable file_size of n
 * @param: n the number of charactere to the left
 * @return: the new position
 */
dec_n_pos:
    push    %rbp   /*Sauvegarde le pointeur de base*/
    movq    %rsp, %rbp

    movq    %rax, %rdi
    movq    pos, %rax
    cmp     %rdi, %rax
    jl  .higher
    subq    %rdi, %rax
    jmp .end_dec_pos
.higher:
    movq    $0, %rax
.end_dec_pos:
    movq    %rax, pos
    movq    %rbp, %rsp
    pop     %rbp
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
    call    get_position
    cmp     $1, %rax    /* Verify if the pointer are not in the first column*/
    je      endPreviousChar
    call    decPos
    movq    $8, %rax   /*sys_lseek*/
    movq    fd, %rdi
    movq    pos,%rsi   /*offset*/
    movq    $0, %rdx   /*SEEK_SET*/
    syscall
    call    move_cursor_left
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
    call    inc_pos
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

.globl up_char
.type up_char, @function
/**
 * Simple implementation to move in the up charactere and move the cursor to the up
 * @return: none
 */
up_char:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    pos, %rax
    cmp     $0, %rax
    je   .end_up_char
    call get_position
    movq    %rax, %rdi  /* Store column */
    call get_line
    cmp     $1, %rax    /* Verify row */
    je   .end_up_char
    cmp     $1, %rdi
    je  .go_to_start_line
    movq    %rdi, %rax
    call go_to_left
    movq    $1, %r8
.go_to_start_line:
    movq    $2, %rax
    call go_to_left
    call get_next_char
    inc     %r8
    movq    pos, %rdi
    cmp     $1, %rdi
    je  .go_to_column
    cmp     $10, %rax
    jne .go_to_start_line
.go_to_column:
    call    get_col
    cmp     %rax, %r8
    jl  .end_of_line
    movq    %rax, %rdx
    movq    $0, %rax
    movq    fd, %rdi
    movq    $char, %rsi
    syscall                 /* move the cursor on the visual pointer */
    movq    %rax, %rdi
    jmp .end_up_char
.end_of_line:
    movq    %r8, %rdx
    dec     %rdx
    movq    %rax, %r8
    movq    $0, %rax
    movq    fd, %rdi
    movq    $char, %rsi
    syscall                 /* move the cursor on the visual pointer */
    call    inc_n_pos
    subq    %rax, %r8
    movq    %r8, %rcx
    dec     %rcx
.move_cursor_up_char:
    pushq   %rcx
    call    move_cursor_left
    pop     %rcx
    loop .move_cursor_up_char
.end_up_char:
    call    move_cursor_up
    movq    %rbp, %rsp
    pop     %rbp
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
    call get_position
    pushq %rax
.goToEndOfLine:
    call get_next_char
    movq %rax, %rdi
    call inc_pos
    movq pos, %rbx
    movq file_size, %rcx
    cmp  %rbx, %rcx
    je   .EOF
    cmp  $10, %rdi
    jne  .goToEndOfLine
    call get_col
    movq pos, %rbx
    movq file_size, %rcx
    subq %rbx, %rcx
    cmp  %rax, %rcx
    jl   .EOF
    pop  %r8
.loopRight:
    cmp  $1, %r8
    je  .moveDown
    call inc_pos
    call get_next_char
    dec  %r8
    cmp  $10, %rax
    jne  .loopRight
.moveLeft:
    cmp $0, %r8
    jne .moveDown
    call move_cursor_left
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
    movq file_size, %rdi
    call setFileSize
    cmp $0, %r8
    je .end_erase
    movq %r8, %rdi
    call shift_left
.end_erase:
    movq %rbp, %rsp
    pop %rbp
    ret


/**
 * Shift the pointer and the cursor to the left n times
 * @param n the number of shift
 * @return real number of shift
 */
.global shift_left
.type shift_left, @function
shift_left:
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
.global go_to_left
.type go_to_left, @function
go_to_left:
    push    %rbp
    movq    %rsp, %rbp

    cmp     $0, %rax
    je   .endGoToLeft
    call dec_n_pos
    movq    $8,  %rax
    movq    fd,  %rdi
    movq    pos, %rsi
    movq    $0,  %rdx
    syscall

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
    call inc_pos
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

.global get_next_char
.type get_next_char, @function
get_next_char:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    $0, %rax
    movq    fd, %rdi
    movq    $char, %rsi
    movq    $1, %rdx
    syscall
    call    inc_pos
    movb    char, %al

    movq    %rbp, %rsp
    pop     %rbp
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

