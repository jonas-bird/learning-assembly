# assemble with: as -o server.o server.s && ld -o server server.o
# stage 1 of a simple webserver
# program should exit cleanly

# Executable name: server
# version        : 0.01
# created        : 2024/03/31
# target         : x64

.intel_syntax noprefix
.global _start


.section .text
_start:
        nop
        xor rax, rax
        xor rdi, rdi
        xor rsi, rsi
        xor rdx, rdx

createSocket:
        mov rdi, 2      # PF_INET
        mov rsi, 1      # SOCK_STREAM type
        mov rdx, 0        # IP
        mov rax, 41       #SYS_SOCKETCALL
        syscall
        cmp rax, 0
        jne error

bindAddress:

exit:
        mov rdi, 0      # return code
        mov rax, 60     # syscall exit
        syscall

error:
        jmp exit

.section .data

#tcpport:
#       .port 8082
