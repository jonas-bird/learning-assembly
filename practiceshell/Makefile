##
# Practice shell
#
# @file
# @version 0.1
test: chirpShell.s
	as chirpShell.s -o chirpShell.o
	ld chirpShell.o -o ../bin/chirpShell

debug: chirpShell
	gdb -q -x ../bin/chirpShell

clean:
	rm chirpShell.o ../bin/chirpShell ../bin/core.*


# end
