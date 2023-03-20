/* All of rio function implementations are obtained from csapp.c */
/* Please note the usage of wrapper function */

/* $begin cpfile */
#include "csapp.h"

int main(int argc, char **argv) 
{
    int n;
    rio_t rio;
    char buf[MAXLINE];
    int cnt = 10;

    while((n = Rio_readlineb(&rio, buf, MAXLINE)) != 0){
    Rio_readn(STDIN_FILENO, buf, cnt); 
	Rio_writen(STDOUT_FILENO, buf, cnt);
    }
    //exit(0);

    FILE *my_file_pointer;

	if ( (my_file_pointer = fopen("infile.txt", "a+")) == NULL)
	{
		while((n = Rio_readlineb(&rio, buf, MAXLINE)) != 0){
            Rio_readn(STDIN_FILENO, buf, cnt); 
	        Rio_writen(STDOUT_FILENO, buf, cnt);
        }
	}
    else{
        Rio_readlineb(&rio, buf, MAXLINE);
        while((n = rio_readlineb(&rio, buf, MAXLINE)) != 0){
            Rio_writen(STDOUT_FILENO, buf, cnt);
        }
    }

    exit(0);
}
/* $end cpfile */



