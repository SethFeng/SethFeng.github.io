title: Android文件上传与下载
date: 2016-03-08 18:23:55
tags: [Android, Network, Download, Upload]
categories: [Android]
---

### content type
- 文本文件
text/plain
text/xml
text/html
application/json
- 二进制文件
    - 未知文件格式的二进制流
        application/octet-stream
    - 已知文件格式的二进制流
        application/pdf
        image/jpeg
        audio/mp4
        video/avi

<!-- more -->


### - aws s3
[文档](http://docs.aws.amazon.com/mobile/sdkforandroid/developerguide/s3transferutility.html)
[aws/aws-sdk-android](https://github.com/aws/aws-sdk-android)

### - aliyun oss
[文档](https://help.aliyun.com/document_detail/oss/sdk/android-sdk/preface.html?spm=5176.2060224.103.3.tIxMwm)
[aliyun/aliyun-oss-android-sdk](https://github.com/aliyun/aliyun-oss-android-sdk)
### - qiniu 
[qiniu/android-sdk](https://github.com/qiniu/android-sdk)
[文档](http://developer.qiniu.com/code/v7/sdk/android.html)


## 文件上传/下载库
类似图片库，单次请求数据量可能很大。一般通过HTTP库封装POST/GET请求实现上传/下载。
基于OkHttp的文件上传/下载库FiDu。
### 文件上传
```java
FiDu.getInstance().upload(url, localFile, new FiDuCallback() {
    @Override
    public void onResponse(Response response) {
    }
    @Override
    public void onFailure(Request request, Exception e) {
    }
    @Override
    public void onProgress(int progress) {
    }
});
```
### 文件下载
#### 单线程下载
```java
FiDu.getInstance().download(url, localFile, new FiDuCallback() {
    @Override
    public void onResponse(Response response) {
    }
    @Override
    public void onFailure(Request request, Exception e) {
    }
    @Override
    public void onProgress(int progress) {
    }
});
```
#### 多线程分片下载
使用HTTP GET请求添加头Range获取内容置顶范围，对整个文件分片，使用多线程下载分片，实现下载加速。
```java
FiDu.getInstance().downloadBySegments(url, localFile, callback);
FiDu.getInstance().pauseDownloadBySegments(url);
FiDu.getInstance().resumeDownloadBySegments(url, localFile, callback);
FiDu.getInstance().cancelDownloadBySegments(url);
```

回调执行在主线程，可更新UI，不可做耗时操作。
```java
public void onCreate() {
    super.onCreate();
    FiDu.init(this);
}
```
