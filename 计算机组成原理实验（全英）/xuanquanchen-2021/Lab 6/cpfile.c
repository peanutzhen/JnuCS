/* All of rio function implementations are obtained from csapp.c */
/* Please note the usage of wrapper function */

/* $begin cpfile */
#include "csapp.h"

int main(int argc, char **argv) 
{
    int n;
    rio_t rio;
    char buf[MAXLINE];
    int fd1 = STDIN_FILENO, fd2;
    if (argc == 1){
    //如果一开始没有给地址
        Rio_readinitb(&rio, STDIN_FILENO);
        while((n = Rio_readn(STDIN_FILENO, buf, 10)) != 0){
	        Rio_writen(STDOUT_FILENO, buf, 10);
        }
    }

    else if (argc == 2){
    //如果一开始给了地址
        fd1 = Open(argv[1], O_RDONLY, 0);
        if (fd1 < 0){
            Rio_readinitb(&rio, STDIN_FILENO);
		    while((n = Rio_readlineb(&rio, buf, MAXLINE)) != 0){
	            Rio_writen(STDOUT_FILENO, buf, n);
        }
    }
        else{
        //DUP2
            fd2 = dup2(STDIN_FILENO,fd1);
            while((n = rio_readlineb(&rio, buf, MAXLINE)) != 0){
                Rio_writen(STDOUT_FILENO, buf, n);
            }
            Close(fd1);
            Close(fd2);
        }   
    }

    else{
        exit(-1);
    }

    exit(0);
}
/* $end cpfile */



