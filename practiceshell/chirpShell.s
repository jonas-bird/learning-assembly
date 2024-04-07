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


   mov BYTE PTR [input_buffer + rax - 1], 0

    # write(1, &command, 50)
    # exec(59)

    mov rax, 59
    mov rdi, offset command
    mov rsi, 0
    mov rdx, 0
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
jonas:
    .string "jonas\n"

command:
    .ascii "/bin/"
input_buffer:
    .space 1000


.section .bss
