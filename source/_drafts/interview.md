# 技术

# 业务


## Java基础
## Android基础
### 四大组件
### 自定义View 触摸事件分发、View刷新机制
### Jetpack
## Android进阶
### 性能优化
#### 卡顿 多线程、IO
#### 内存 泄露、OOM
#### 启动
#### 包体积
#### 监控

## 开源库

### OkHttp
## 大厂面试必问OkHttp考点系列

1 大厂面试必问之Okhttp请求复用与缓存方式详解
2 大厂面试必问之OkHttp连接池复用原理
3 大厂面试必问之OkHttp责任链模式如何运行的
4 大厂面试必问之Dispatcher分发流程

#### 面试题一 Okhttp 框架中有几级请求队列，哪三个队列
1   2级   请求队列   等待队列
2   4级   请求队列   等待队列  阻塞队列  同步队列
3   3级   请求队列   等待队列  阻塞队列  

#### 面试题二   okhttp最多支持同时连几路服务器，同时支出多少并发数
1   8  64 
2   5  60
3   4  32
4   5  64

#### 面试题三  OkHttp对于网络请求都有哪些优化，下列不属于okhttp的优化是
1 通过Socket连接复用来减少请求时 多次握手
2 无缝支持GZIP来减少数据流量
3 缓存响应数据来减少重复的网络请求
4 使用FlutterBuffer数据协议压缩数据量大小

#### 面试题四  你能说说Okhttp的默认拦截器吗(下列属于okhttp的拦截器是[多选题])
1 请求失败重试拦截器 RetryAndFollowUpInterceptor
2 查找连接拦截器 ConnectIntercept
3 读取数据流拦截器 CallServerInterceptor
4 桥接拦截器   BridgeInterceptor

### Retrofit
## 大厂面试必问Retrofit 实现原理
1、Retrofit 与OkHttp的关系
2、Retrofit 如何通过动态代理 实现对Okhttp的调用的
3、retrofit为什么使用注解定义了一个方法，我们就可以使用了，背后的原理是什么？
4、全网最全的OKhttp与Retrofit手写实现让你面试变得游刃有余


### Fresco/Glide/Picasso
### MMKV
### GreenDao

## 架构

## 音视频

## 跨平台









## 腾讯面试必问之探寻Glide源码的三级缓存机制、生命周期绑定及高并发原理探究

主要内容：
1.腾讯面试问题之Glide为什么不用担心内存泄漏？
2.腾讯面试问题之如何监听网络变化
3.腾讯面试问题之怎么实现页面生命周期
4.腾讯面试问题之如何监测内存
5.腾讯面试问题之3级缓存是如何实现的
6.腾讯面试问题之3条主线逻辑及渲染流程分析