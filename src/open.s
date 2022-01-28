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

    movq %rbp, %rsp
    pop %rbp
    ret

