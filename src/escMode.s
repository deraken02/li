.data
c:
    .byte ''
help:
    .string ".cache/help"
.text
.global displayHelp
.type displayHelp, @function
displayHelp:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp
    pushq %rdi
    call clearTerm
    movq $57, %rax  /* syscall fork */
    syscall
    cmp $0, %rax
    jne parent
    movq $59, %rax
    movq $help, %rdi
    movq $0, %rsi
    movq $0, %rdx
    syscall
    jmp .end_display_help
parent:
    movq $61, %rax  /* sys_wait4*/
    movq $(-1), %rdi
    movq $0, %rsi
    movq $0, %rdx
    movq $0, %r10
    syscall
    call getchar
    call clearTerm
    popq %rdi       /* file descriptor*/
    call displayContent
.end_display_help:
    call getchar
    movq %rbp, %rsp
    pop %rbp
    ret

.global directionKey
.type directionKey, @function
directionKey:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp

    call getchar
    and $255, %rax
    movq $67, %rbx
    cmp %rax, %rbx
    je .call_next
    movq $68, %rbx
    cmp %rax, %rbx
    je .call_previous
    jmp .end_direction_key
.call_previous:
    call previousChar
    jmp .end_direction_key
.call_next:
    call nextChar
    jmp .end_direction_key
.end_direction_key:
    movq %rbp, %rsp
    pop %rbp
    ret
