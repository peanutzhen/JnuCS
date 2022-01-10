#include "chat.h"
   
int
main(int argc, char const *argv[]) 
{
    system("clear");
    puts("Running...");
    int count = 0;
    for(int i = 20000; i>0;i--)
    {
        int connect_fd = init_connection();
        if(connect_fd <= 0)
        {
            continue;
        }
        else
            count += 1;
    }
    printf("%d\n",count);
    return 0;
} 