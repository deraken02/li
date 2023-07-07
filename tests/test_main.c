#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#define COUNTER 5

typedef struct test_config{
    char name[50];
    int32_t (* func)();
} test_config_t;

extern int32_t openFile(char *path);
extern void erase(void);
extern void set_fd(int32_t fd);
extern void decPos();

int32_t fd;
char filename[7];
test_config_t config[COUNTER];

int32_t test_write()
{
    int32_t sta = 0;
    char results[50]={0};
    write(fd, "Hello", 5);
    close(fd);
    fd = open(filename, O_RDONLY);
    if(read(fd, results, 50) != 5)
    {
        sta = 1;
    }
    else
    {
        if(strncmp("Hello",results,5) != 0)
        {
            sta = 1;
            printf("\n%s\n",results);
        }
    }
    close(fd);
    return sta;
}

int32_t test_append()
{
    int32_t sta = 0;
    char results[50]={0};
    lseek(fd, 0, SEEK_END);
    write(fd, " World", 6);
    close(fd);
    fd = open(filename, O_RDONLY);
    if(read(fd, results, 50) != 11)
    {
        sta = 1;
    }
    else
    {
        if(strncmp("Hello World",results,11) != 0)
        {
            sta = 1;
            printf("\n%s\n",results);
        }
    }
    close(fd);
    return sta;
}

int32_t test_replace()
{
    int32_t sta = 0;
    char results[50]={0};
    write(fd, "Hello", 5);
    close(fd);
    printf("not ");
    return sta;
}

int32_t test_erase1()
{
    int32_t sta = 0;
    char results[50] = {0};
    write(fd, "Hello World1", 12);
    asm( "call setFileSize;"
         :
         :"D"(12):);
    set_fd(fd);
    erase();
    close(fd);
    fd = open(filename, O_RDONLY);
    if(read(fd, results, 50) != 11)
    {
        sta = 1;
        printf("\n%s\n",results);
    }
    else
    {
        if(strncmp("Hello World",results,11) != 0)
        {
            sta = 1;
            printf("\n%s\n",results);
        }
    }
    close(fd);
   return sta;
}

int32_t test_erase2()
{
    int32_t sta = 0;
    char results[50] = {0};
    write(fd, "Hello Worl d", 12);
    asm( "call setFileSize;"
         :
         :"D"(12):);
    set_fd(fd);
    lseek(fd, 11, SEEK_CUR);
    decPos();
    erase();
    close(fd);
    fd = open(filename, O_RDONLY);
    if(read(fd, results, 50) != 11)
    {
        sta = 1;
        printf("\n%s\n",results);
    }
    else
    {
        if(strncmp("Hello World",results,11) != 0)
        {
            sta = 1;
            printf("\n%s\n",results);
        }
    }
    close(fd);
   return sta;
}

void initialize_test()
{
    strcpy(filename,"tester");
    //Write test
    strcpy(config[0].name,"Write in a new file\t\t");
    config[0].func=&test_write;
    //Append test
    strcpy(config[1].name,"Append in an existing file\t");
    config[1].func=&test_append;
    //Replace test
    strcpy(config[2].name,"Replace char in an file\t\t");
    config[2].func=&test_replace;
    //Erase1 test
    strcpy(config[3].name,"Erase char at the end of the file");
    config[3].func=&test_erase1;
    //Erase2 test
    strcpy(config[4].name,"Erase a char int the middle the file");
    config[4].func=&test_erase2;
}

int32_t main()
{
    int32_t sta = 0;
    initialize_test();
    for(uint8_t i = 0; i < COUNTER ; i++)
    {
        asm( "call openFile;"
             :"=r"(fd)
             :"a"(filename):);
        printf("%s\t",config[i].name);
        if(config[i].func() == 0)
        {
            puts("OK");
        }
        else
        {
            puts("NG");
        }
        if (i != 0)
        {
            remove(filename);
        }
    }
    return sta;
}
