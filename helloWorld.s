.intel_syntax noprefix
.global _start

_start:
    nop
    mov rax, 2
    mov rdi, offset path
    mov rsi, 2
    mov rdx, 0
    syscall

    mov rdi, rax
    mov rax, 1
    mov rsi, offset hello
    mov rdx, 14
    syscall

exit:
    mov rdi, 0
    mov rax, 60
    syscall

path:
    .string "hello.txt"

hello:
    .string "Hello, world!\n"
