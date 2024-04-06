    ;;  Executable name : hexdump1
    ;;  Version         : 1.0
    ;;  Created         : 2024-02-20
    ;;  Last Updated    : 2024-02-20
    ;;  Author          : Jeff Duntemann with additions by jBird
    ;;  Description: Simple assembly program for Linux to convert binary values
    ;;       to hexidecimal strings. Can be used as a simple hex dump utility
    ;;       for files (though without the ASCII equivelent column)
    ;;  Run with:
    ;;      hexdump1 < {input}
    ;;
    ;;  Build using:
    ;;      nasm -f elf -g -F stabs hexdump1.asm hexdump1.lst
    ;;      ld -o hexdump1 hexdump1.o -melf_i386


SECTION .bss                    ; Section containing uninitiated data

    BUFFLEN equ 16              ; Read the file 16 bytes at a time
    Buff:   resb BUFFLEN        ; Text buffer

SECTION .data                   ; Section containing initialized data

    HexStr: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00",10
    HEXLEN  equ $-HexStr

    Digits: db "0123456789ABCDEF"

SECTION .text                   ; Section containing code
global _start                   ; Linker needs this to find entry point
_start:
    nop                         ; no-op for gdb
;; Read a buffer of text from stdin:
Read:
    mov eax,3                   ; Specify sys_read call
    mov ebx,0                   ; Specify File descriptor 0: STDIN
    mov ecx,Buff                ; Pass offset of buffer to read to
    mov edx,BUFFLEN             ; Pass the number of bytes to read at once
    int 80h                     ; Call sys_read to fill the buffer
    mov ebp,eax                 ; Save # of bytes
    cmp eax,0                   ; check for EOF on stdin
    je Done                     ; jump to done if equal to 0 (from compare)

;; Set registers for stepping through buffer:
    mov esi,Buff                ; Put address of the buffer into esi
    mov edi,HexStr              ; Put address of line strinf in edi
    xor ecx,ecx                 ; clear line string pointer (set to 0)

;; Step through buffer and convert binary values to hex:
Scan:
    xor eax,eax                 ; Clear eax (set to 0)

;; Calculate offset into HexStr, this is value in ecx X 3 (2 + 1space)
    mov edx,ecx                 ; Copy the char counter to edx
    shl edx,1                   ; Multiply pointer by 2 through left shift
    add edx,ecx                 ; Add one more to get X3

;; Get char from buffer and put in eax and ebx:
    mov al,byte [esi+ecx]       ; Put a byte from input buffer into al
    mov ebx,eax                 ; Duplicate the byte in bl for the second nybble

;; Look up the low nybble char and insert into the string:
    and al, 0Fh                 ; mask out all but the low nybble
    mov al,byte [Digits+eax]    ; Look up the char equivelent to al and copy to al
    mov byte [HexStr+edx+2],al  ; Write LSB char digit into line string

;; Look up high nybble char and insert into the string:
    shr bl,4                    ; Shift high 4 bits of char into low 4 bits
    mov bl,byte [Digits+ebx]    ; Look up char equivelent of nybble
    mov byte [HexStr+edx+1],bl  ; Write MSB char digit to line string

;; Bump the buffer pointer to the nexr char and see if we reached the end
    inc ecx                     ; Increment string line pointer
    cmp ecx,ebp                 ; Compare to number of chars in buffer
    jna Scan                    ; Loop back if ecx is <= number of chars in buffer

;;
;; write line of hex values to stdout
    mov eax,4                   ; specufy sys_write
    mov ebx,1                   ; specify file descriptor 1: stdout
    mov ecx,HexStr              ; Pass offset of line string
    mov edx,HEXLEN              ; Pass sizr of the line string
    int 80h                     ; Make kernel call to display line
    jmp Read                    ; loop back and load file buffer again

;; Done, exit the process properly:
Done:
    mov eax,1                   ; Code for Exit syscall
    mov ebx,0                   ; Return code 0
    int 80h                     ; Make kernel call
