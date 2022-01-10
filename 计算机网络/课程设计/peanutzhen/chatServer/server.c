#include "chat.h"

int main(int argc, char const *argv[]) 
{
    system("clear");

    // 创建服务器侦听端点
    int server_fd = init_server();
    if(server_fd <= 0)
    {
        perror("init_server()");
        exit(EXIT_FAILURE);
    }
    puts("Server running...");

    // 侦听ing...
    pthread_t tid;
    int *connected_fd;
    struct sockaddr client_socket;
    socklen_t len;
    while(1)
    {
        len = sizeof(struct sockaddr_storage);
        connected_fd = malloc(sizeof(int));
        *connected_fd = accept(server_fd, &client_socket, &len);
        if (connected_fd < 0) 
            continue;
        pthread_create(&tid, NULL, connection, (void *)connected_fd);
    }

    close(server_fd);
    exit(EXIT_SUCCESS);
} 