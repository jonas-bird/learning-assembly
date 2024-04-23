    ;; File: template_win_32.asm

    ;;  tell the assembler which format we want
    format PE GUI

    ;; define the entry point
    entry _start

    ;; we need to include a set of macros for windo programs (included in FASM)
    include 'win32a.inc'


    ;; define the .text section (executable code)
    section '.text' code readable executable
_start:
    ;; code goes here



    ;; to properly terminate a process:
    ;;   put return code on the stack:
    push 0
    ;;   call ExitProcess Windows API procedure
    call [exitProcess]


    ;; the .data section
    section '.data' data readable writeable
    ;; Put your data here


    ;; idata section contains import information
    section '.idata' import data readable writeable

                                ; 'library' macro from 'win32a.inc' creates proper entry for importing
                                ; procedures from a dynamic link library. For now it is only
    'kernel32.dll',
                                ; library kernel, 'kernel32.dll'
                                ; 'import' macro creates the actual entries for procedures we want to
    import
                                ; from a dynamic link library
    import kernel,
    exitProcess, 'ExitProcess'
