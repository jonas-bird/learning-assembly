    ;; File: template_linux_32.asm
    ;; template for learning x86 instrucitons
    ;;
    ;; tell the assembler we are making a 32-bit ELF
    format ELF executable

    ;; tell the assembler the entry point:
    entry _start

    ;; define code segment
    segment readable executable

    ;; entry point
_start:


    ;; set return value to 0
    xor ebx, ebx
    mov eax, ebx

    ;; set eax to 1 - 32-bit Linux SYS_exit syscall number
    inc eax

    ;; Call kernel
    int 0x80



    ;; define Data segment
    segment readable writeable
        db 0
