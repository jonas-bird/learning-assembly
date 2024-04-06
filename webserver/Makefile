##
# Simple web server
#
# @file
# @version 0.1

test: server.s
	as server.s -o server.o
	ld server.o -o ../bin/server

debug: server
	gdb -q -x ../bin/server

clean:
	rm server.o ../bin/server core.*



# end
