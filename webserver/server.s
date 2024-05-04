    # as -o server.o server.s && ld -o server server.o
    # stage 7 of a simple webserver
    # program should send a response to a HTTP request (or any request)

.intel_syntax noprefix


.section .data
    .set SYS_open, 2        # file open syscall
    .set O_RDONLY, 00       # read only
    .set O_WRONLY, 01       # write only
    .set O_RDWR,   02       # read and write
    .set O_CREAT, 0100      # create

address:
    .2byte 2        # PF_INET/AF_INET
    .2byte 0x5000   # 80    use 8282 (0x205A) for local testing
    .4byte 0        # run on all ports (0.0.0.0)
    .8byte   0      # padding

response:
    .string "HTTP/1.0 200 OK\r\n\r\n"  # should this be NULL terminated?
endHeader:
    .string "\r\n\r\n"   # end of HTTP header


.section .text

.global _start

_start:
    nop
    xor rax, rax
    xor rdi, rdi
    xor rsi, rsi
    xor rdx, rdx

createSocket:
    mov rdi, 2              # PF_INET
    mov rsi, 1              # SOCK_STREAM type
    mov rdx, 0              # TCP
    mov rax, 41             #SYS_SOCKETCALL
    syscall

    mov r12, rax            # socket fd is now in r12
    # r12 is safe according to SysV ABI

bindAddress:
    # int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
    mov rdi, r12
    lea rsi, [rip+address]      # put address here
    mov rdx, 16
    mov rax, 49             # bind syscall is 49
    syscall

    # int listen(int sockfd, int backlog);
listen:
    mov rdi, r12            # should still be there from bind, but just in case move socketfd into arg1
    mov rax, 0x32           # listen syscall is 32
    mov rsi, 0
    syscall
    cmp rax, 0
    jne error

eventLoop:
    #  int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
accept:
    mov rax, 0x2b           # syscall for accept is 0x2b
    mov rdi, r12            # move socketfd into arg1
    mov rsi, 0              # arg2 is a NULL pointer for sockaddr of peer socket
    mov rdx, 0              # NULL for length od peer socket
    syscall
    mov r13, rax            # stow away our new fd

fork:
    mov rax, 57    # fork syscall
    syscall
    cmp rax, 0
    jne parent

child:
    mov rax, 3              # syscall for close(fd)
    mov rdi, r12            # move fd from accept into arg1
    syscall
    # ssize_t read(int fd, void *buf, size_t count);
readRequest:
    mov rax, 0x0            # syscall for read
    mov rdi, r13            # use the fd returned by accept
    mov rdx, 0x1000            # probably there is a better way to do this?
    # in real world should check to see if there is more to read
    lea rsi, [requestBuffer]
    syscall
    #mov r15, rax   # r15 should be size of the request

findPath:
    xor rax, rax     # rsi should still be pointing at our request
    mov al, [rsi]
    cmp al, ' '
    je endFindPath
    inc rsi
    jmp findPath

endFindPath:
    inc rsi
    mov rdi, rsi      # setup for read syscall

terminatePath:
    cmp byte ptr [rsi], ' '
    je insertNULL
    inc rsi
    jmp terminatePath

insertNULL:
    mov byte ptr [rsi], 0    # NULL terminate the path portion of the http request

parseRequest:
    mov bl, [requestBuffer]   # First character to see if it is a P(ost) or G(et)
    cmp bl, 'P'
    je postChild
    cmp bl, 'G'
    je getChild
    jmp closeChild

postChild:

    # open("<path>", O_WRONLY|O_CREAT, 0777)
openWFileSyscall:
    mov rsi, (O_CREAT|O_WRONLY)
    mov rdx, 0777       # octal number 511 or 0x1ff
    mov rax, 2
    syscall
    mov r14, rax       # hopefully I dont run out of callee preserved buffers for file descruptors..

    lea rsi, [rip+requestBuffer]
findContent:
    cmp DWORD PTR [rsi], 0x0a0d0a0d
    je endFindContent
    inc rsi
    jmp findContent

endFindContent:
    add rsi, 4
 #   lea rax, [rip+requestBuffer]
 #   sub rax, rsi   # this should be the size of the header up to the start of the content

    mov r15, rsi
    xor rdx, rdx
findEndContent:
    inc rdx
    inc r15
    cmp byte ptr [r15], 0x0
    jne findEndContent

    #  ssize_t write(int fd, const void *buf, size_t count);
writeContent:
    mov rdi, r14  # r14 should be the fd from creating/opening the file from above
    mov rax, 1    # write syscall
    syscall

closeWFile:
    mov rdi, r14
    mov rax, 3
    syscall

writePOSTHeader:
    mov rdi, r13            # get the fd from accept
    lea rsi, [rip+response]     # pointer to our 'http response string'
    mov rdx, 19             # the size of our response
    mov rax, 0x01           # write syscall
    syscall

    jmp closeChild


getChild:

openRFileSyscall:
    mov rsi, O_RDONLY
    mov rax, 2
    syscall
    mov r14, rax       # hopefully I dont run out of callee preserved buffers for file descruptors...

readFile:
    mov rdi, r14        # FD for requested file
    mov rsi, rsp        # on to the stack it goes
    # shouldn't I need to do some things like move rsp= rsp-1000
    mov rdx, 0x1000
    xor rax, rax        # 0 is syscall for read
    syscall
    mov r15, rax       # save size of file

closeRFile:
    mov rdi, r14
    mov rax, 3
    syscall

    # ssize_t write(int fd, const void *buf, size_t count);
writeGETHeader:
    mov rdi, r13            # get the fd from accept
    lea rsi, [rip+response]     # pointer to our 'http response string'
    mov rdx, 19             # the size of our response
    mov rax, 0x01           # write syscall
    syscall

writeResponseBody:
    mov rdi, r13        # r13 is fd from accept
    mov rsi, rsp
    mov rdx, r15        # r15 is the size of the file read onto the stack
    mov rax, 1          # 1 is write syscall
    syscall

    # int close(int fd);
closeChild:
    mov rax, 3              # syscall for close(fd)
    mov rdi, r13            # move fd from accept into arg1
    syscall

nextEvent:
    jmp exit


parent:
    mov rax, 3              # syscall for close(fd)
    mov rdi, r13            # move fd from accept into arg1
    syscall
    jmp eventLoop

exit:
    mov rdi, 0              # return code
    mov rax, 60             # syscall exit
    syscall



error:
    mov rdi, 1              # return code for error
    mov rax, 60             # syscall exit
    syscall


.section .bss
    .lcomm requestBuffer, 0x1000
