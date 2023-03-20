CC:=gcc

main.out: cpfile.o csapp.o
	$(CC) cpfile.c csapp.c -lpthread -o main.out

.PHONY:clean
clean:
	rm -rf *.o *.out
