# Lab 1: Number Storage Lab

[toc]

## I. Introduction

This lab extends the section *Information Storage* (chapter 2) in the textbook. It will immerse you in a problem context, which will require you to apply the theoretical concepts taught in the C language course. This will help you to develop basic skills needed to become a device level system developers and digital system designer. While going through this lab concentrate on developing a good understanding of the problem context, as it is a fundamental requirement for becoming a skilled system designer or application developer.

## 2. Lab Instructions or Steps

This code (file name “lab1.c”) is available from the course materials.

 *Activities to do-*

- a)  Using less than 4 sentences, explain what function/action, the two statements marked with “Tag 1” and “Tag 2” perform.

- b)  Compile and run this program with “gcc” on the Linux machine.

- c) When you ran your code, did you get the time executed to be negative? If yes, why did that happen? (Since time cannot be negative). How could you fix this? Figure out how to fix it and do the necessary modifications.

- d) Change the data type of the variable time_stamp from *double* to *long int*. Is there a change in the values reported? If so, which of the values is the correct value? Why is there a difference?

- e) Find out the structure of type “timeval”. Is it a standard C data type or is it platform specific?

- f) Print your output files for all runs in your report. (and the fixed versions if you made changes above ). *Note: If you submit an output file with negative time, you must submit the corrected version also. Failure to do so will lead to loss of 50% of the points for this lab.*

- g) Write a C program to get bit and byte lengths for all the following C numerical data types according to the following table*.* The new C code file should have name “lab1_2.c” and it should generate an output file named “lab1_2_out.txt”. *Hint – You can add codes to the lab1.c program to do this step*.

![image-20211012010522323](C:\Users\XuanQuan\AppData\Roaming\Typora\typora-user-images\image-20211012010522323.png)



Figure 1 Typical sizes (in bytes) of basic C data types (from figure 2.3 in the textbook)

## 3.Lab Device and Environment

### 3.1Environment

```terminal
root@AvA:/mnt/c/Users/XuanQuan# cat /proc/version
Linux version 5.10.16.3-microsoft-standard-WSL2 (oe-user@oe-host) (x86_64-msft-linux-gcc (GCC) 9.3.0, GNU ld (GNU Binutils) 2.34.0.20200220) #1 SMP Fri Apr 2 22:23:49 UTC 2021
```

### 3.2 Lab Device

> 处理器	Intel(R) Core(TM) i7-8550U CPU @ 1.80GHz   1.99 GHz
> 机带 RAM	16.0 GB (15.8 GB 可用)
> 系统类型	64 位操作系统, 基于 x64 的处理器
>
> 版本	Windows 10 家庭版
> 版本号	21H1
> 安装日期	‎2021/‎7/‎30
> 操作系统内部版本	19043.1266

## 4.Results and Analysis

### 4.1 Answer to A

Tag1 declare an int_val variable of type int and give it an address.

Tag2 prints the number of bytes and bits occupied by int_val.

### 4.2 Results of B

```terminal
root@AvA:/codeProject/CSAPP/Lab-1# gcc lab1.c -o lab1
lab1.c: In function ‘main’:
lab1.c:31:3: warning: implicit declaration of function ‘exit’ [-Wimplicit-function-declaration]
   31 |   exit(1);
      |   ^~~~
lab1.c:31:3: warning: incompatible implicit declaration of built-in function ‘exit’
lab1.c:18:1: note: include ‘<stdlib.h>’ or provide a declaration of ‘exit’
   17 | #include <sys/time.h> //For gettimeofday() function
  +++ |+#include <stdlib.h>
   18 |
lab1.c:37:65: warning: format ‘%d’ expects argument of type ‘int’, but argument 3 has type ‘double’ [-Wformat=]
   37 |  fprintf(my_file_pointer, "This program was executed at time : %d secs\n", time_stamp);
      |                                                                ~^          ~~~~~~~~~~
      |                                                                 |          |
      |                                                                 int        double
      |                                                                %f
root@AvA:/codeProject/CSAPP/Lab-1# ./lab1
This program was executed at time : 1953063456 secs
The sizes of different data type for this machine and compiler are -
int data type is 4 bytes or 32 bits long
double data type is 8 bytes or 64 bits long
```

![334f8a5db5f77cbe1f919bf27c88e9c](C:\Users\XuanQuan\AppData\Local\Temp\WeChat Files\334f8a5db5f77cbe1f919bf27c88e9c.png)

Note that we get two different results in the terminal and the file.That is because there is buffering going on, and the actual output probably won't switch at the end-of-line character. I add a 

```c
fprintf(stdout, "%d", time_stamp);
```

after the fprintf function and then the two function get the same results.

### 4.3 Answer to C

Yes, that is because double and int take up the different amount of space on a computer. When we convert double to int, we print out only the lower 32 bits and discard the remaining 32 bits of the double value.

Change the parameter of the print function and fprintf function from %d to %f can fix it.

```c
fprintf(my_file_pointer, "This program was executed at time : %f secs\n", time_stamp);
printf("This program was executed at time : %f secs\n", time_stamp);
```



### 4.4 Answer to D

Yes, we get a new result as 1633976974 secs and change it to the time we get 2021-10-12 02:29:34.That is the correct value.It is because the long int type is also an integer type. But there is also a risk of mistakes because in 64-bit enviroment，the long int is 8 bytes and the int is 4 bytes, and if the time value bigger than 2147483647, then it will still have mistakes in this program.To solve it, we need to change %d to %ld.

### 4.5 Answer to E

```c
/*
DESCRIPTION
    The functions gettimeofday and settimeofday can get and set the time as
    well as a timezone. The tv argument is a timeval struct, as specified
    in <sys/time.h>:
*/

    struct timeval {
          time_t       tv_sec;     /* seconds */
          suseconds_t   tv_usec; /* microseconds */
    };
```

This struct is in the sys/time.h, and the  sys/time.h is a date-time header file for Linux. 

So it is platform specific.

### 4.6 Answer to F

the fixed versions

change from

```c
double time_stamp;
fprintf(my_file_pointer, "This program was executed at time : %d secs\n", time_stamp);
printf("This program was executed at time : %d secs\n", time_stamp);
```

to

```c
long int time_stamp;
fprintf(my_file_pointer, "This program was executed at time : %ld secs\n", time_stamp);
printf("This program was executed at time : %ld secs\n", time_stamp);
```



and we get

![微信图片_20211011205848](D:\XuanQuan\Desktop\微信图片_20211011205848.png)

change the time_stamp to time, we can get 2021-10-11 14:40:57.

### 4.7 Answer to G

The source code are in appendix.

Since it asked the numerical data types, we don't need to show bit and byte lengths for char*.

And we get the lab1_2_out.txt.

![微信图片_20211012025455](D:\XuanQuan\Desktop\微信图片_20211012025455.png)

## 5.Appendix

lab_1_2.c

```c
#include <stdio.h> //For input/output
#include <sys/time.h> //For gettimeofday() function
#include <stdint.h> //For the int32_t and the int64_t

int main()
{

	FILE *my_file_pointer;
	if ( (my_file_pointer = fopen("lab1_2_out.txt", "w")) == NULL)
	{
		printf("Error opening the file, so exiting\n");
		exit(1);
	}

	//Code segment for file I/O
	fprintf(my_file_pointer, "The sizes of different data type for this machine and compiler are -\n");

    fprintf(my_file_pointer, "char data type is %d bytes or %d bits long\n",sizeof(char), sizeof(char)*8 );
	fprintf(my_file_pointer, "unsigned char data type is %d bytes or %d bits long\n",sizeof(unsigned char), sizeof(unsigned char)*8 );
	fprintf(my_file_pointer, "short data type is %d bytes or %d bits long\n",sizeof(short), sizeof(short)*8 );
	fprintf(my_file_pointer, "unsigned short data type is %d bytes or %d bits long\n",sizeof(unsigned short), sizeof(unsigned short)*8 );
	fprintf(my_file_pointer, "int data type is %d bytes or %d bits long\n",sizeof(int), sizeof(int)*8 );
	fprintf(my_file_pointer, "unsigned int data type is %d bytes or %d bits long\n",sizeof(unsigned int), sizeof(unsigned int)*8 ); 
	fprintf(my_file_pointer, "long data type is %d bytes or %d bits long\n",sizeof(long), sizeof(long)*8 );
	fprintf(my_file_pointer, "unsigned long data type is %d bytes or %d bits long\n",sizeof(unsigned long), sizeof(unsigned long)*8 );
    fprintf(my_file_pointer, "int32_t data type is %d bytes or %d bits long\n",sizeof(int32_t), sizeof(int32_t)*8 );
	fprintf(my_file_pointer, "uint32_t data type is %d bytes or %d bits long\n",sizeof(uint32_t), sizeof(uint32_t)*8 );
    fprintf(my_file_pointer, "int64_t data type is %d bytes or %d bits long\n",sizeof(int64_t), sizeof(int64_t)*8 );
	fprintf(my_file_pointer, "uint64_t data type is %d bytes or %d bits long\n",sizeof(uint64_t), sizeof(uint64_t)*8 );
    fprintf(my_file_pointer, "char* data type is %d bytes or %d bits long\n",sizeof(char*), sizeof(char*)*8 );
	fprintf(my_file_pointer, "float data type is %d bytes or %d bits long\n",sizeof(float), sizeof(float)*8 );
	fprintf(my_file_pointer, "double data type is %d bytes or %d bits long\n",sizeof(double), sizeof(double)*8 );
	
	fclose(my_file_pointer); //To close the output file, mandatory to actually get an output !

	return 0;
}

```

