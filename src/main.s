.data
c:
    .byte ' '
fd:
    .int 1
strNotFile:
    .string "No file specified\n"
eraseTerm:
    .string "\033[H\033[J"
CursorUp:
    .string "\033[A"
CursorDown:
    .string "\033[B"
CursorRight:
    .string "\033[C"
CursorLeft:
    .string "\033[D"
.text

.globl main
main:
    pushq %rbp
    movq %rsp, %rbp
    movq $2, %rbx           /*Le nombre de paramètre que l'on veut*/
    cmp %rdi, %rbx          /*Comparaison avec argc*/
    jne notFile             /*Imprime une erreur et sort du programme*/
    mov 8(%rsi), %rax       /*Sinon recupère argv[1]*/
    call openFile           /*Ouvre un file descriptor*/
    movq %rax, fd
    call clearTerm
    movq fd, %rdi
    call displayContent
    call enableRawMode
while:
    call getchar
    mov c,%rdi
    call char_handler
    call putchar
    jmp while

notFile:
    movq $1, %rax           /*syscall write*/
    movq $2, %rdi           /*STDERR*/
    movq $strNotFile, %rsi  /*addresse du buffer*/
    movq $18, %rdx          /*nombre d'octet à écrire*/
    syscall                 /*Appel le noyau*/
    jmp end
exit:
    movq fd, %rdi
    call closeFile
    call clearTerm
end:
    movq %rbp, %rsp
    popq %rbp
    ret

.global getchar
.type getchar, @function
getchar:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq $0, %rax /*syscall read*/
    movq $0, %rdi /*clavier en entrée*/
    movq $c, %rsi /*addresse du buffer*/
    movq $1, %rdx /*nombre d'octet à lire*/
    syscall       /*Appel le noyau*/
    mov c, %rax
    movq %rbp, %rsp
    pop %rbp
    ret

.global putchar
.type putchar, @function
putchar:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq $1, %rax /*syscall write*/
    movq fd, %rdi /*File Descriptor*/
    movq $c, %rsi /*addresse du buffer*/
    movq $1, %rdx /*nombre d'octet à écrire*/
    syscall       /*Appel le noyau*/
    movq $1, %rax /*syscall write*/
    movq $1, %rdi /*File Descriptor*/
    movq $c, %rsi /*addresse du buffer*/
    movq $1, %rdx /*nombre d'octet à écrire*/
    syscall       /*Appel le noyau*/
    movq %rbp, %rsp
    pop %rbp
    ret

.global char_handler
.type char_handler, @function
/**
 * Handler for the special charactere
 * @param char the current charactere
 */
char_handler:
    push %rbp
    movq %rsp, %rbp

    mov %rdi, %rax
    and $255, %rax
    movq $27, %rbx          /* Escape */
    cmp %rax, %rbx
    je .call_escMode
    movq $127, %rbx         /* Delete char */
    cmp %rax, %rbx
    je .call_cursorLeft
    movq $3, %rbx
    cmp %rax, %rbx
    je exit
    jmp .end_char_handler
.call_escMode:
    call escMode
    jmp .end_char_handler
.call_cursorLeft:
    call previousChar
    call getchar
    movq c, %rdi
    call char_handler
    jmp .end_char_handler
.end_char_handler:
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

.global escMode
.type escMode, @function
escMode:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    call getchar
    mov c, %rax
    and $255, %rax
    movq $113, %rbx
    cmp %rax, %rbx
    je exit
    movq $91, %rbx
    cmp %rax, %rbx
    je .call_direction_key
    movq $104, %rbx
    cmp %rax, %rbx
    je .call_help
    movq $112, %rbx
    cmp %rax, %rbx
    je .call_menu
    jmp .end_escMode
.call_direction_key:
    call directionKey
    call getchar
    call char_handler
    jmp .end_escMode
.call_help:
    movq fd, %rdi
    call displayHelp
    jmp .end_escMode
.call_menu:
    movq fd, %rdi
    call displayMenu
    jmp .end_escMode
.end_escMode:
    movq %rbp, %rsp
    pop %rbp
    ret

.global previousChar
.type previousChar, @function
previousChar:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq $8, %rax   /*sys_lseek*/
    movq fd, %rdi   /*file descriptor*/
    movq $0, %rsi   /*offset*/
    movq $1, %rdx   /*SEEK_CUR*/
    syscall
    movq $0, %rbx
    cmp %rax, %rbx
    je endPreviousChar
    dec %rax
    movq %rax, %rsi /*offset*/
    movq $8, %rax   /*sys_lseek*/
    movq fd, %rdi   /*file descriptor*/
    movq $0, %rdx   /*SEEK_SET*/
    syscall
    movq $1, %rax
    movq $1, %rdi
    movq $CursorLeft, %rsi
    movq $3, %rdx
    syscall
endPreviousChar:
    movq %rbp, %rsp
    pop %rbp
    ret


.global nextChar
.type nextChar, @function
nextChar:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq $8, %rax   /*sys_lseek*/
    movq fd, %rdi   /*file descriptor*/
    movq $0, %rsi   /*offset*/
    movq $2, %rdx   /*SEEK_END*/
    syscall
    movq %rax, %rbx
    movq $8, %rax   /*sys_lseek*/
    movq fd, %rdi   /*file descriptor*/
    movq $0, %rsi   /*offset*/
    movq $1, %rdx   /*SEEK_CUR*/
    syscall
    cmp %rax, %rbx
    je endNextChar
    inc %rax
    movq %rax, %rsi /*offset*/
    movq $8, %rax   /*sys_lseek*/
    movq fd, %rdi   /*file descriptor*/
    movq $0, %rdx   /*SEEK_SET*/
    syscall
    movq $1, %rax
    movq $1, %rdi
    movq $CursorRight, %rsi
    movq $3, %rdx
    syscall
endNextChar:
    movq %rbp, %rsp
    pop %rbp
    ret
