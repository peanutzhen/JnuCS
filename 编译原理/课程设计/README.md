# compilerHW
暨南大学编译原理课程实验。

## 实验内容

选择部分C语言的语法成分，设计其词法分析程序，要求能够识别关键字、运算符、分界符、标识符、常量（至少是整型常量，可以自己扩充识别其他常量）等，并能处理注释、部分复合运算符（如>=等）。

## 实验要求

（1）待分析的简单的语法

  ```
  关键字：begin  if  then  while  do  end
  运算符和界符：:=  +  -  *  /  <  <=  >  >=  <>  =  ;  (  )  #
  其他单词是标识符id和整型常数num，通过以下正规式定义：
  id=l(l|d)*
  num=dd*
  空格、注释：在词法分析中要去掉。
  ```

（2）各种单词符号对应的种别编码

<img src="./pictures/clip_image002.jpg" alt="img" style="zoom:150%;" />

程序实现词法分析，从文件`data.txt`中读取一段小程序，分解出一个个的单词，其中有关键词，有界符、运算符等等，代码还需实现去掉空格、回车、注释等等情况，最后的输出结果是以单词二元组（单词种别码，单词自身的值）的形式输出。

- `Main.java`为项目Java版代码。
- `main.go`为项目Go版代码。

## 用法

- Java 8
- Go 1.16

```bash
# Java版
javac Main.java
java Main
# Go版
go build main.go
./main
```

## 程序输出

<img src="./pictures/image-20210527133028124.png" alt="image-20210527133028124" style="zoom:50%;" />
