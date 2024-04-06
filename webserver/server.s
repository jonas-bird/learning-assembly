# assemble with: as -o server.o server.s && ld -o server server.o
# stage 1 of a simple webserver
# program should exit cleanly

# Executable name: server
# version        : 0.01
# created        : 2024/03/31
# target         : x64
.intel_syntax noprefix
.global _start

# stuff to remember rdi rsi rdx r10 r8 r9

.section .text
_start:
        nop
        xor rax, rax
        xor rdi, rdi
        xor rsi, rsi
        xor rdx, rdx

createSocket:
        mov rdi, 2        # PF_INET
        mov rsi, 1        # SOCK_STREAM type
        mov rdx, 0        # IP
        mov rax, 41       # SYS_SOCKETCALL
        syscall

        mov r12, rax      # socket fd is now in r12
                          # r12 is safe according to SysV ABI

bindAddress:
# int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
        mov rdi, r12
        lea rsi, [address] #put address here
        mov rdx, 16
        mov rax, 49       # bind syscall is 49
        syscall
        cmp rax, 0
        jne error       # eventually I can add in specific error logging

listen:


exit:
        mov rdi, 0      # return code
        mov rax, 60     # syscall exit
        syscall

error:
        jmp exit

.section .data
address:
        .2byte 2     # PF_INET/AF_INET
        .2byte 0x921f  # 8082 for assignment needs to be 80 so 0x5000
        .4byte 0     # run on all ports (0.0.0.0)
        .8byte   0       # padding
