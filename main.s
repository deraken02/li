.data
c:
    .byte ' '
fd:
    .int 1
strNotFile:
    .string "No file specified\n"
eraseTerm:
    .string "\033[H\033[J" 
.text

.globl main
main:
    movq $2, %rbx           /*Le nombre de paramètre que l'on veut*/
    cmp %rdi, %rbx          /*Comparaison avec argc*/
    jne notFile              /*Imprime une erreur et sort du programme*/
    pop %rax                /*Sinon recupère argv[0]*/
    pop %rax                /*On récupère le pathname*/
    call openFile           /*Ouvre un file descriptor*/
    call clearTerm
    call enableRawMod
while:
    call getchar
    call putchar
    movq $c,%rax
    movq $27, %rbx
    cmp %rax, %rbx
    je exit
    jmp while

notFile:
    movq $1, %rax           /*syscall write*/
    movq $1, %rdi           /*STDOUT*/
    movq $strNotFile, %rsi  /*addresse du buffer*/
    movq $18, %rdx          /*nombre d'octet à écrire*/
    syscall                 /*Appel le noyau*/
    jmp exit
exit:
    call disableRawMod
    mov $60 ,%rax
    xor %rdi,%rdi   /*exit(0)*/
    syscall

.global openFile
.type openFile, @function
/**
 * Ouvre le fichier passer en paramètre et place le file descriptor dans la variable globale fd
 * @param pathname
 * @return void
 */
openFile:
    push %rbp               /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq %rax, %rdi         /*Place le pathname dans rdi*/
    movq $2, %rax           /*Instruction open*/
    movq $00001101,%rsi     /*O_CREATE | O_TRUNC | O_WRONLY*/
    syscall
    movq %rax, fd

    movq %rbp, %rsp
    pop %rbp
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
    movq fd, %rdi /*File Descriptor*/
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
