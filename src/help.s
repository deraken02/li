/* Copyright (c) 2022 Delacroix Louis */
.LC0:
        .string ".cache/help.txt"
.globl main
main:
        pushq   %rbp
        movq    %rsp, %rbp
        subq    $16, %rsp
        movl    $0, %esi
        movl    $.LC0, %edi
        movl    $0, %eax
        call    open
        movl    %eax, -4(%rbp)
        jmp     .L2
.L3:
        leaq    -5(%rbp), %rax
        movl    $1, %edx
        movq    %rax, %rsi
        movl    $1, %edi
        call    write
.L2:
        leaq    -5(%rbp), %rcx
        movl    -4(%rbp), %eax
        movl    $1, %edx
        movq    %rcx, %rsi
        movl    %eax, %edi
        call    read
        cmpq    $1, %rax
        je      .L3
        movl    -4(%rbp), %eax
        movl    %eax, %edi
        call    close
        movl    $0, %eax
        leave
        ret
