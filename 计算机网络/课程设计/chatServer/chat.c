#include "chat.h"

int
init_connection()
{
    int client_fd = socket(AF_INET, SOCK_STREAM, 0);
    int error = 0;

    if (client_fd < 0) 
        return client_fd;

    struct sockaddr_in server_socket;

    // 设置服务器socket参数
    server_socket.sin_family = AF_INET; 
    server_socket.sin_port = htons(SERVER_PORT); 

    // 十进制点表示IP to 二进制表示
    error = inet_pton(AF_INET, SERVER_IP, &server_socket.sin_addr);
    if(error <= 0)  
        return error;

    // 与服务器进行链接
    error = connect(client_fd, (struct sockaddr *)&server_socket, sizeof(server_socket));
    if(error < 0)
        return error;

    return client_fd;
}

int
init_server()
{
    struct sockaddr_in server_socket;

    int server_fd = socket(AF_INET, SOCK_STREAM, 0);
    int error = 0;
    if (server_fd <= 0) 
        return server_fd;

    // 将服务器设置为 localhost:SERVER_PORT
    server_socket.sin_family = AF_INET; 
    server_socket.sin_addr.s_addr = INADDR_ANY; 
    server_socket.sin_port = htons(SERVER_PORT); 

    // server_fd 与 socket结构体绑定
    error = bind(server_fd, (struct sockaddr *)&server_socket, sizeof(server_socket));
    if (error < 0) 
        return error;

    // socket变成监听套接字
    error = listen(server_fd, 1024);
    if (error < 0)
        return error;
    
    return server_fd;
}

void *
connection(void *vargp)
{
    int socket_fd = *(int *)vargp;
    pthread_detach(pthread_self());
    free(vargp);

    printf(">> [%d] join.\n", socket_fd);
    
    while(1)
    {
        char *buf = (char *)malloc(sizeof(char)*BUFFERSIZE);
        memset(buf, 0, BUFFERSIZE);
        int n = 0;
        n = recv(socket_fd, buf, BUFFERSIZE, 0);
        if(!strcmp(buf,"/bye") || n < 0)
            break;
        else if(!strcmp(buf,"/debug"))
        {
            struct sockaddr_in sa;
            unsigned sa_len = sizeof(sa);
            getsockname(socket_fd, (struct sockaddr *)&sa, &sa_len);
            memset(buf, 0, BUFFERSIZE);
            sprintf(buf, "Server socket: %s:%d\n", inet_ntoa(sa.sin_addr), ntohs(sa.sin_port));
            send(socket_fd, buf, strlen(buf), 0);
            free(buf);
            continue;
        }
        printf("[%d]: %s\n", socket_fd, buf);
        free(buf);
    }

    printf(">> [%d] out.\n", socket_fd);
    close(socket_fd);
    return NULL;
}