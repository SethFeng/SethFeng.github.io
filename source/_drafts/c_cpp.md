title: C与C++
date: 2019-03-18 19:20:09
tags:
---

std::string -> char* : `std::string#c_str()`


C stdio.h:
FILE* fopen(const char* __path, const char* __mode);
FILE* fdopen(int __fd, const char* __mode);
int fclose(FILE* __fp);

int fputc(int __ch, FILE* __fp);
int fputs(const char* __s, FILE* __fp);

int putc(int __ch, FILE* __fp);
int putchar(int __ch);
int puts(const char* __s);

int fgetc(FILE* __fp);
char* fgets(char* __buf, int __size, FILE* __fp) __overloadable __RENAME_CLANG(fgets);

int getc(FILE* __fp);
int getchar(void);

char* gets(char* __buf) __attribute__((deprecated("gets is unsafe, use fgets instead")));




指针方法用 ->
对象方法用 .


## make

## Makefile

### CMakeLists.txt
```
cmake_minimum_required(VERSION 3.4.1)

set(TARGET_NAME xxx)
add_library(
        ${TARGET_NAME}

        SHARED

        xxx.c
)

target_link_libraries(
        ${TARGET_NAME})
```
`add_library`添加源码，`target_link_libraries`添加依赖库
- 遍历文件夹下所有符合规则的源码文件，`${yy_SRC}`添加到源码下
```
file(GLOB_RECURSE yy_SRC *.c*)
file(GLOB_RECURSE yy_SRC ../../yy/*.c*)
```
- 添加prebuilt库，`${yy}`添加到依赖库下
```
add_library(yy SHARED IMPORTED)
set_target_properties(yy PROPERTIES IMPORTED_LOCATION ../yy/libs/${ANDROID_ABI}/libyy.so)
```
- 打印包含的头文件搜索文件夹
```
get_property(includes
        TARGET ${TARGET_NAME}
        PROPERTY INCLUDE_DIRECTORIES
        )
foreach (dir in ${includes})
    message(STATUS "  - ${dir}")
endforeach ()
```