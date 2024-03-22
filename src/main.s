/* Copyright (c) 2024 Delacroix Louis */
.data
c:
    .byte ' '
fd:
    .int 1
strNotFile:
    .string "No file specified\n"
charNotImplement:
    .string "Char not implement\n"
unexpectedIssue:
    .string "Unexpected issue from termios\n"
request_exit:
    .byte 0
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
    movq %rax, %rdi
    call set_fd
    call clearTerm
    call display_content
    movq %rax, %rdi
    call setFileSize
    call enableRawMode
    cmp  $0, %rax
    jne  unexpected
while:
    call getchar
    movb  c,%dil
    call char_handler
    cmp $0, %rax
    jne .special_char
    call putchar
.special_char:
    movb request_exit, %al
    cmpb $0, %al
    je   while
    jmp  exit_pg

unexpected:
    movq $1, %rax           /*syscall write*/
    movq $2, %rdi           /*STDERR*/
    movq $unexpectedIssue, %rsi  /*addresse du buffer*/
    movq $30, %rdx          /*nombre d'octet à écrire*/
    syscall                 /*Appel le noyau*/
    jmp end
notFile:
    movq $1, %rax           /*syscall write*/
    movq $2, %rdi           /*STDERR*/
    movq $strNotFile, %rsi  /*addresse du buffer*/
    movq $18, %rdx          /*nombre d'octet à écrire*/
    syscall                 /*Appel le noyau*/
    jmp end
exit_pg:
    movq fd, %rdi
    call closeFile
    call clearTerm
end:
    movq $0, %rax
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
    movb c, %al
    movq %rbp, %rsp
    pop %rbp
    ret

.global putchar
.type putchar, @function
putchar:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movb request_exit, %al
    cmpb $0, %al
    jne .end_putchar
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
    call incSize
.end_putchar:
    call inc_pos
    movq %rbp, %rsp
    pop %rbp
    ret

.global char_handler
.type char_handler, @function
/**
 * Handler for the special charactere
 * @param char the current charactere
 * @return 1 if the current character is a special character else 0
 */
char_handler:
    push %rbp
    movq %rsp, %rbp

    push $0
    mov %rdi, %rax
    movq $27, %rbx          /* Escape */
    cmp %rax, %rbx
    je .call_escMode
    movq $127, %rbx         /* Delete char */
    cmp %rax, %rbx
    je .call_erase
    movq $9, %rbx           /* Tab */
    cmp %rax, %rbx
    je .call_tab
    movq $3, %rbx
    cmp %rax, %rbx
    sete %al
    mov %al, request_exit
    popq %rbx
    pushq %rax
    jmp .end_char_handler
.call_escMode:
    call escMode
    popq %rax
    pushq $1
    jmp .end_char_handler
.call_erase:
    call erase
    call clearTerm
    movq fd, %rdi
    call display_content
    popq %rax
    pushq $1
    jmp .end_char_handler
.call_tab:
    call tabulation
    popq %rax
    pushq $1
    jmp .end_char_handler
.end_char_handler:
    popq %rax
    movq %rbp, %rsp
    pop %rbp
    ret

.global tabulation
.type tabulation, @function
tabulation:
    push %rbp
    movq %rsp, %rbp

    movq $4, %rcx
    movb $32, c     /* Move SPACE in current char */
.tabloop:
    pushq %rcx
    call putchar
    popq %rcx
    loop .tabloop

    movq %rbp, %rsp
    popq %rbp
    ret

.global escMode
.type escMode, @function
escMode:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp
.begin_escMode:
    call getchar
    movb c, %al
    movq $113, %rbx
    cmp %rax, %rbx
    je .end_of_pg
    movq $91, %rbx
    cmp %rax, %rbx
    je .call_direction_key
    movq $104, %rbx
    cmp %rax, %rbx
    je .call_help
    movq $112, %rbx
    cmp %rax, %rbx
    je .call_menu
    movq $1, %rax           /*syscall write*/
    movq $2, %rdi           /*STDERR*/
    movq $charNotImplement, %rsi
    movq $19, %rdx          /*nombre d'octet à écrire*/
    syscall                 /*Appel le noyau*/
    movb $1, request_exit
    jmp .end_escMode
.end_of_pg:
    movb $1, request_exit
    jmp .end_escMode
.call_direction_key:
    call directionKey
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
    movb c, %al
    movq $27, %rbx          /* Escape */
    cmp %rax, %rbx
    je .begin_escMode
    movq %rbp, %rsp
    pop %rbp
    ret
