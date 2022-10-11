/* Copyright (c) 2022 Delacroix Louis */
.data
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
