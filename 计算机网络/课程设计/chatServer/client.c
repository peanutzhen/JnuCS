#include "chat.h"
   
int
main(int argc, char const *argv[]) 
{
    system("clear");
    int connect_fd = init_connection();
    if(connect_fd <= 0)
    {
        perror("init_connection()");
        exit(EXIT_FAILURE);
    }
    puts("You can chat now!\n\"/bye to leave.\"\n");
    while(1)
    {
        int n = 0;
        char msg[BUFFERSIZE];
        printf("Message:\n");
        scanf("%s", msg);
        n = send(connect_fd, msg, strlen(msg),0);
        if(!strcmp(msg, "/bye") || n <= 0)
            break;
        else if(!strcmp(msg, "/debug"))
        {
            char *buf = (char *)malloc(BUFFERSIZE);
            n = recv(connect_fd, buf, BUFFERSIZE, 0);
            if(n < 0)
            {
                free(buf);
                break;
            }
            else
            {
                printf("%s", buf);
                strcpy(msg,"");
                continue;
            }
        }
        strcpy(msg,"");
        system("clear");
    }
    close(connect_fd);
    exit(EXIT_SUCCESS);
} 