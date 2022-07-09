.data
c:
    .space 16
.text
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
    movq $2,%rsi            /*O_RDONLY*/
    syscall
    cmp $0, %rax
    jg endOpenFile
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

    movq $2, %rax           /*Instruction open*/
    movq $578,%rsi          /*O_CREATE | O_TRUNC | O_RDWR*/
    movq $420, %rdx         /*Mode 644*/
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

    movq $8, %rax   /* sys_lseek*/
    movq $0, %rsi   /* offset*/
    movq $0, %rdx   /* SEEK_SET*/
    syscall
.reader:
    movq $0, %rax           /* Read the content */
    movq $c, %rsi
    movq $16, %rdx
    syscall
    pushq %rdi
    movq %rax, %rdx         /* Display the content*/
    movq $1, %rdi           /* on the standard output*/
    movq $1, %rax
    syscall
    popq %rdi
    cmp $16, %rax
    jl .endDisplayContent
    jmp .reader
.endDisplayContent:
    movq %rbp, %rsp
    pop %rbp
    ret

.global closeFile
.type closeFile, @function
/**
 * Close the file
 * @param file descriptor
 */
closeFile:
    push %rbp
    movq %rsp, %rbp

    movq $3, %rax
    syscall

    movq %rbp, %rsp
    pop %rbp
    ret
