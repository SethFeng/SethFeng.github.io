title: Retrofit学习笔记
date: 2016-02-02 10:25:14
tags:
- Retrofit
- Android
- Network
categories:
- Android
---

Version 1.0.0
---
# Annotations

<!-- more -->

- HTTP请求方法`RestMethod`
    + `GET`
    + `POST`
    + `PUT`
    + `DELETE`
    + `HEAD`
- URL组装
    - `Path`
    - `Query`
- HTTP body
    - `Body`
    - body format
        * `Field`与`FormUrlEncoded`
        - `Part`与`Multipart`
- HTTP头部
    + `Header`，参数级，一次设置一个head
    + `Headers`，方法级，一次可设置多个head

# HTTP库
- Client
    接口
- ApacheClient
    Apache HttpComponents的`org.apache.http.client.HttpClient`
- AndroidApachClient
    `AndroidHttpClient`，Apache HttpClient的扩展
- UrlConnectionClient
    JDK里`java.net.HttpURLConnection`
- OkClient
    Square出品的HTTP库OkHttp

# Java到Android，跨平台Platform
- 两个平台
    + Base
    + Android
- 五个自定义
    + Converter
        默认Gson
    + HTTP Client
        * Base
            - OkClient(有OkHttp)
            - UrlConnectionClient
        * Android
            + AndroidApacheClient(BuildVersion<9)
            + UrlConnectionClient
    + Http Executor
        HTTP请求执行的线程池。Base与Android的不同仅在于设置线程优先级时，Android设置成BACKGROUND，Base设置成MIN_PRIORITY。
    + CallbackExecutor
        Base在当前线程执行回调。Android由于回调里有更新UI的需求，使用主线程执行。
    + Log
        Base使用`System.out.println()`，Android使用`android.util.Log.d()`。

# 线程模型
同步方式请求、执行和回调都在同一线程；异步方式Base请求在一线程，执行和回调同在另一线程，Android请求在一线程，执行在另一线程，回调在主线程。
接口定义：
```java
interface GitHub {
    // 同步
    @GET("/repos/{owner}/{repo}/contributors")
    List<Contributor> contributors(
            @Path("owner") String owner,
            @Path("repo") String repo
    );
    // 异步
    @GET("/repos/{owner}/{repo}/contributors")
    void contributors(
            @Path("owner") String owner,
            @Path("repo") String repo,
            Callback<List<Contributor>> callback
    );
}
```
构造接口网络服务：
```java
RestAdapter restAdapter = new RestAdapter.Builder()
        .setServer("https://api.github.com")
        .build();
GitHub github = restAdapter.create(GitHub.class);
```
发起请求：
```java
// 同步请求
List<Contributor> contributors = github.contributors("square", "retrofit");
// 异步请求
github.contributors("square", "retrofit", new Callback<List<Contributor>>() {
    @Override
    public void success(List<Contributor> contributors, Response response) {}
    @Override
    public void failure(RetrofitError error) {}
});
```

# 代码解读
代码主要可以分几个部分：
- HTTP Client
    选用HTTP库
- HTTP annotation
    定义HTTP请求注解API
- mime
    提供HTTP常用数据操作工具类
- Request/Convertor/Callback/Response
    定义HTTP库要使用的对象
interface定义的网络请求是如何转化成Request对象的？ Java动态代理


References
---
https://github.com/square/retrofit
http://android-developers.blogspot.com/2011/09/androids-http-clients.html
http://httpcomponents.apache.org
https://realm.io/cn/news/droidcon-jake-wharton-simple-http-retrofit-2/

