.global openFile
.type openFile, @function
/**
 * Verify if the file exist, if the file exist launch appendFile else launch createFile
 * @param pathname
 * @return int the file descriptor of the file
 */
openFile:
    push %rbp               /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq %rax, %rdi         /*Place le pathname dans rdi*/
    movq $2, %rax           /*Instruction open*/
    movq $0,%rsi            /*O_RDONLY*/
    syscall
    cmp $0, %rax
    jg endOpenFile
    movq %rdi, %rax         /*Place the path dans rax*/
    call createFile
    jmp endOpenFile

endOpenFile:
    movq %rbp, %rsp
    pop %rbp
    ret

.global createFile
.type createFile, @function
/**
 * Create a file and return the file descriptor of the file
 * @param pathname
 * @return int the file descriptor of the create file
 */
createFile:
    push %rbp               /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    movq %rax, %rdi         /*Place le pathname dans rdi*/
    movq $2, %rax           /*Instruction open*/
    movq $00001101,%rsi     /*O_CREATE | O_TRUNC | O_WRONLY*/
    syscall

    movq %rbp, %rsp
    pop %rbp
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

    movq %rdi, %rsi         /* Place le pointeur de stat dans rsi*/
    movq %rax, %rdi         /* Place fd dans rdi*/
    movq $5, %rax           /* Instruction fstat*/
    syscall
    movq 48(%rsi), %rdx           /* Move the size in rdx*/
    movq %rdi, %rsi         /* Move the file descriptor in rsi*/
    movq $0, %rax           /* syscall write*/
    movq $1, %rdi           /* STDOUT*/
    syscall
    movq %rbp, %rsp
    pop %rbp
    ret
