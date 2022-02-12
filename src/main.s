.data
c:
    .byte ' '
fd:
    .int 1
strNotFile:
    .string "No file specified\n"
eraseTerm:
    .string "\033[H\033[J" 
stat:
    .long 0         /*st_dev         0*/
    .long 0         /*st_ino         8*/
    .long 0         /*st_mode       16*/
    .int  0         /*st_nlink      24*/
    .int  0         /*st_uid        28*/
    .long 0         /*st_gid        32*/
    .long 0         /*st_rdev       40*/
    .long 0         /*st_size       48*/
    .long 0         /*st_blksize    56*/
    .space 80
.text

.globl main
main:
    movq $2, %rbx           /*Le nombre de paramètre que l'on veut*/
    cmp %rdi, %rbx          /*Comparaison avec argc*/
    jne notFile             /*Imprime une erreur et sort du programme*/
    mov 8(%rsi), %rax       /*Sinon recupère argv[1]*/
    call openFile           /*Ouvre un file descriptor*/
    movq %rax, fd
    call clearTerm
    movq fd, %rax
    movq $stat, %rdi
    call displayContent
    call enableRawMod
while:
    call getchar
    mov c,%rax
    and $255, %rax
    movq $27, %rbx
    cmp %rax, %rbx
    je exit
    movq $3, %rbx
    cmp %rax, %rbx
    je exit
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
    call clearTerm
end:
    call disableRawMod
    mov $60 ,%rax
    xor %rdi,%rdi   /*exit(0)*/
    syscall

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

