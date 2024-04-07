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
        lea rsi, [sockaddr] #put address here
        mov rdx, 16
        mov rax, 49       # bind syscall is 49
        syscall
        cmp rax, 0
        jne error       # eventually I can add in specific error logging

# int listen(int sockfd, int backlog);
listen:
        mov rdi, r12    # should still be there from bind, but just in case move socketfd into arg1
        mov rax, 0x32     # listen syscall is 0x32
        mov rsi, 0
        syscall
        cmp rax, 0
        jne error


loop1:

#  int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
accept:
        mov rax, 0x2b           # syscall for accept is 0x2b
        mov rdi, r12            # move socketfd into arg1
        mov rsi, 0       # arg2 is a NULL pointer for sockaddr of peer socket
        mov rdx, 0              # NULL for length od peer socket
        syscall
        mov r13, rax    # move new socketfd into a safe spot

# ssize_t read(int fd, void *buf, size_t count);
readRequest:
        mov rax, 0x0    # syscall for read
        mov rdi, r13    # use the fd returned by accept
        mov rdx, 255    # probably there is a better way to do this?
        lea rsi, [requestBuffer]
        syscall


# ssize_t write(int fd, const void *buf, size_t count);
writeResponse:
       mov rdi, r13         # get the fd from accept
       lea rsi, [response]  # pointer to our 'http response string'
        mov rdx, 19         # the size of our response
        mov rax, 0x01           # write syscall
        syscall

# int close(int fd)
close:
        mov rax, 3
        mov rdi, r13
        syscall


exit:
        mov rdi, 0      # return code
        mov rax, 60     # syscall exit
        syscall

error:
        mov rdi, 1       # return code for something went wrong
        mov rax, 60     # syscall exit
        syscall


.section .data
sockaddr:
        .2byte 2     # PF_INET/AF_INET
        .2byte 0x921f  # 8082 for assignment needs to be 80 so 0x5000
        .4byte 0x0100007f     # 127.0.0.1 or run on all ports (0.0.0.0)
        .8byte   0       # padding

response:
        .string "HTTP/1.0 200 OK\r\n\r\n"  # should this be NULL terminated?

.section .bss
.lcomm requestBuffer, 256
