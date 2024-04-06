##
# Assembly hexdump1
#
# @file
# @version 0.1
hexdump1: hexdump1.o
		ld -o ../bin/hexdump1 hexdump1.o -melf_i386
hexdump1.o: hexdump1.asm
		nasm -f elf -g -F stabs hexdump1.asm -l hexdump1.lst

clean:
	rm hexdump1.o ../bin/hexdump1


# end
