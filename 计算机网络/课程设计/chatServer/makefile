all: client server test

client: client.c chat.c
	gcc client.c chat.c -o client
server: server.c chat.c
	gcc server.c chat.c -o server
test: test.c chat.c
	gcc test.c chat.c -o test
clean:
	rm client server