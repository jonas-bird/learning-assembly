.intel_syntax noprefix
.global _start


.section .text
_start:
    nop



# print prompt
    mov rax, 1
    mov rdi, 1
    mov rsi, offset prompt
    mov rdx, 2
    syscall

# get the name of the binary to run
    mov rax, 0
    mov rdi, 0
    mov rsi, offset command
    mov rdx, 100
    syscall
    mov r10, rax

# replace newline with NULL byte
l1:
    mov al, [rsi]
    cmp al, '\n'
    je end1
    inc rsi
    jmp l1
end1:
    mov byte ptr [rsi], 0

# fork process
    mov rax, 57
    syscall

    cmp rax, 0
    jne _start

# execve the input
    mov rax, 59
    mov rdi, offset command
    mov rdx, 0
    mov rsi, 0
    syscall


# exit the program (exit code 0)
    mov rax, 60
    mov rdi, 0
    syscall

.section .data
prompt:
    .string "> "
command:
    .ascii "/bin/"
input:
    .space 100
