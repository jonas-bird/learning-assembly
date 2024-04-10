# simple shell program to practice x86-64 assembly

.intel_syntax noprefix
.global _start


.section .text
_start:
    nop
loop:
    nop

    mov rax, 10000000
l0:
    dec rax
    cmp rax, 0
    jne l0


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

# replace newline with NULL byte
l1:
    mov al, [rsi]
    cmp al, '\n'
    je end1
    inc rsi
    jmp l1
end1:
    mov byte ptr [rsi], 0


    # pid_t fork(void);
    mov rax, 57
    syscall

    cmp rax, 0
    jne loop

    # exec(59)
    # int execve(const char *pathname, char *const argv[], char *const envp[]);
    mov rax, 59
    mov rdi, offset command
    mov rsi, 0
    mov rdx, 0
    syscall

exit:
    // Exit 0
    mov rdi, 0      # return code
    mov rax, 60     # syscall exit
    syscall


.section .data
prompt:
    .string "> "
command:
    .ascii "/bin/"
input_buffer:
    .space 1000


.section .bss
