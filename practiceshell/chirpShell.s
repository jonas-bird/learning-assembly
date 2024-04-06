# simple shell program to practice x86-64 assembly

.intel_syntax noprefix
.global _start


.section .text
_start:
    nop
loop:
    nop
    # print prompt write(1, &prompt, 2)
    mov rax, 1
    mov rdi, 1
    mov rsi, offset prompt
    mov rdx, 2
    syscall

    # read input
    # read(0, &input_buffer, 1000)
    mov rax, 0
    mov rdi, 0
    mov rsi, offset input_buffer
    mov rdx, 1000
    syscall

    # ugly hack
    mov qword ptr [input_buffer], 0
    # check to see if the command is whoami
    mov rax, [input_buffer]
    cmp rax, [whoami]
    jne loop

    # write(1, &jonas, 2)
    mov rax, 1
    mov rdi, 1
    mov rsi, offset jonas
    mov rdx, 6
    syscall
    # return to start of event loop
    jmp loop
exit:
    // Exit 0
    mov rdi, 0      # return code
    mov rax, 60     # syscall exit
    syscall

.section .data
prompt:
    .string "> "
input_buffer:
    .space 1000
jonas:
    .string "jonas\n"
whoami:
    .string "whoami\n"

.section .bss
