/* Copyright (c) 2022 Delacroix Louis */
.data
file_size:
    .quad 0
pos:
    .quad 0
fd:
    .int 1
CursorUp:
    .string "\033[A"
CursorDown:
    .string "\033[B"
CursorRight:
    .string "\033[C"
CursorLeft:
    .string "\033[D"
eraseTerm:
    .string "\033[H\033[J"
c:
    .space 2048
.text

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

    movq %rdi, fd
    movq $8, %rax   /* sys_lseek*/
    movq $0, %rsi   /* offset*/
    movq $0, %rdx   /* SEEK_SET*/
    syscall
    movq $8, %rax   /* sys_lseek*/
    movq $0, %rsi   /* offset*/
    movq $2, %rdx   /* SEEK_SET*/
    syscall
    pushq %rax
    movq $8, %rax   /* sys_lseek*/
    movq $0, %rsi   /* offset*/
    movq $0, %rdx   /* SEEK_SET*/
    syscall
.reader:
    popq %rdx
    movq $0, %rax           /* Read the content */
    movq $c, %rsi
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
 * Increase the variable file_size of 1
 * @return: the new size
 */
setFileSize:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq %rdi, file_size
    movq %rdi, pos

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
previousChar:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq pos, %rax
    cmp $0, %rax
    je endPreviousChar
    dec %rax
    movq %rax, %rsi /*offset*/
    movq fd, %rdi
    movq $8, %rax   /*sys_lseek*/
    movq $0, %rdx   /*SEEK_SET*/
    syscall
    movq $1, %rax
    movq $1, %rdi
    movq $CursorLeft, %rsi
    movq $3, %rdx
    syscall
    call decPos
endPreviousChar:
    movq %rbp, %rsp
    pop %rbp
    ret


.global nextChar
.type nextChar, @function
nextChar:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq pos, %rax
    movq file_size, %rbx
    cmp %rax, %rbx
    je endNextChar
    inc %rax
    movq %rax, %rsi /*offset*/
    movq $8, %rax   /*sys_lseek*/
    movq fd, %rdi
    movq $0, %rdx   /*SEEK_SET*/
    syscall
    movq $1, %rax
    movq $1, %rdi
    movq $CursorRight, %rsi
    movq $3, %rdx
    syscall
    call incPos
endNextChar:
    movq %rbp, %rsp
    pop %rbp
    ret
