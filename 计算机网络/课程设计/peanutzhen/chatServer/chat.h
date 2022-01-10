#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#include <pthread.h>

#define SERVER_PORT 6324        // 随便取的
#define SERVER_IP "127.0.0.1"   // 服务端运行在本地
#define BUFFERSIZE 1024

int init_connection();      // 初始化客户端与服务器的连接
int init_server();          // 初始化服务器socket

void *connection(void *);