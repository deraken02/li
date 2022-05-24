.data
c:
    .byte ''
help:
    .string ".cache/help.txt"
.text
.global displayHelp
.type displayHelp, @function
displayHelp:
    push %rbp   /*Sauvegarde le pointeur de base*/
    movq %rsp, %rbp
    pushq %rdi       /* file descriptor*/
    call clearTerm
    movl $0, %esi
    movl $help, %edi
    movl $0, %eax
    call open
    movq %rax, %rdi
    call displayContent
    call closeFile
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
