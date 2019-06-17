title: Protocol Buffers
date: 2019-02-15 20:00:00
tags: 
- 序列化
- serialization
- protobuf
---

Protocol Buffers是Google推出的一个结构化数据序列化工具。只需定义一次数据结构，就可以使用各种编程语言读写数据。
数据交换格式分为可读格式和二进制格式。JSON是一种常见的可读格式，Protocol Buffers属于二进制格式。
本文以Mac上开发Java程序为例。

# 开发环境
```
brew install protobuf
```

# 基本用法

## 数据模板协议定义-proto
定义一个proto文件student.proto，内容如下：
```
syntax = "proto2";

package com.example.bean;

message Student {
    required int32 id = 1;
    optional string address = 2;
    repeated string prizes = 3;
}
```
`syntax`指定`protobuf`的版本，`package`指定生成Java类的包名，`message`定义数据类，类里定义需要的各个字段。当然，定义的字段类型除官方给的基本类型外，也可以是自己定义的数据类。
一个字段的定义由`修饰符 + 数据类型 + 字段名 + 字段索引`组成。

### 修饰符
修饰符定义了字段在序列化后的数据中是否必须出现和可能出现的次数。
- required 被修饰的字段必须存在且仅存在一次
- optional 被修饰的字段可以不出现或者仅出现1次
- repeated 被修饰的字段可不出现或者出现任意次，

### 基本数据类型
protobuf定义了基本的数据类型。
- 浮点型 double/float
- 整型 int32/int64/uint32/uint64/sint32/sint64/fixed32/fixed64/sfixed32/sfixed64
    为了尽可能的减少数据序列化时整型数据占用的字节数，Protocol Buffer为proto设计了多种整型，用户可以根据自己的使用场景选用合适的类型。
- bool
- string
    字符串值必须是UTF-8编码的或者7位ASCII字符。
- bytes
    二进制序列

### 字段索引
proto里的字段必须手动分配一个对象内唯一的整型索引，且该索引值不应改变。

## proto转源码

### 编译proto成源码
使用官方提供的工具可以方便的由proto生成需要语言的源码文件。
```
protoc student.proto --java_out=.
```
生成的Java源码就在当前目录下，可以拷贝到项目里使用了。当然，项目里是要添加protobuf sdk的。

## 序列化
protobuf为生成的类添加了byte数组和stream两种序列化方式。
```java
Student stu = Student.newBuilder()
        .setId(1001)
        .setAddress("Shanghai")
        .addPrizes("Math")
        .addPrizes("Program")
        .build();

byte[] stuBytes = stu.toByteArray();
Student stu2 = Student.parseFrom(stuBytes);

stu.writeTo(new FileOutputStream("stu_1001.txt"));
Student stu3 = Student.parseFrom(new FileInputStream("stu_1001.txt"));
```

