title: Retrofit学习笔记
date: 2016-02-02 10:25:14
tags:
- okhttp
- Android
- Network
categories:
- Android
---

### 线程模型
ConnectionPool
注意OkHttp的线程模型
- 不在主线程调用OkHttp的同步请求
- 主线程处理OkHttp异步请求回调可能碰到坑
若`Response.body().bytes()`第一次触发的是主线程，`Util.closeQuietly(source)`会被调用去操作网络。

<!-- more -->

### 缓存模型

关于`OkHttpClient#clone()`
new Call()的时候没必要clone OkHttpClient，因为Call()构造函数也会`new OkHttpClient()`

### 异步请求回调
- Callback 
`onResponse`在请求的头部回来时就被调用了。如果请求回复的body比较耗时（如下载文件），通过`response.body().byteStream()`读取完流/通过`response.body().byte()`，body下载完成，请求才算完成，才能给UI成功的回调。

TextView setText不可在非UI线程调用
ProgressBar setProgress可在非UI线程调用，为毛？


### 关于文件下载/上传进度
- 下载进度
可以通过在Callback的onResponse里，通过`response.body().byteStream()`获取流，通过读取流发出进度变化消息。
- 上传进度

