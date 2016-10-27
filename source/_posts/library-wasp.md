title: Android网络库Wasp
date: 2016-01-29 18:00:27
tags:
- Android
- 网络
categories:
- Android
---
# 介绍
通过Wasp库使用HTTP GET方式获取内容的示例介绍Wasp的使用，URL为https://api.github.com/users/sethfeng/repos
使用Java interface提供HTTP API：
```java
public interface GitHubService {
    @GET("users/{user}/repos")
    void listRepos(@Path("user") String user, 
                  Callback<List<Repo>> callback);
}
```

<!-- more -->

创建Wasp：
```java
Wasp wasp = new Wasp.Builder(getContext())
            .setEndpoint("https://api.github.com")
            .build();
```
创建HTTP service：
```
GitHubService service = wasp.create(GitHubService.class);
```
调用HTTP service里方法发送请求：
```java
gitHubService.listRepos("sethfeng", new Callback<List<Repo>>{
  @Override
  public void onSuccess(WaspResponse response, List<Repo> repos) {
    // do something
  }
  @Override
  public void onError(WaspError error) {
    // handle error
  }
});
```

# API
## 请求方法GET/POST
HTTP请求方法使用注解标识：
```java
@GET(...)
```
```java
@POST(...)
```

## URL组装
先来看一个常见的URL组成部分：
`http://example.com/index.html?name=sethfeng`
```
protocol = http
host = example.com
path = /index.html
query = name=sethfeng
```
再看Wasp对各参数的API封装：
### - protocol和host
使用Wasp的`EndPoint`声明，EndPoint又称baseUrl
```java
Wasp.Builder.setEndPoint(protocol + host)
```
### - path
使用注解`Path`设置path中的参数
```java
@GET("/repos/{id}")
void getRepo(@Path("id") String id, 
            Callback<Repo> callback);
```
组装出的url为`https://api.github.com/repos/id`
### - query
query参数设置：
```java
@GET("group/{id}/users")
void groupList(@Path("id") int id, 
              @Query("sort") String sort, 
              Callback<List<User>> callback);
```
组装出的url为`https://api.github.com/repos/id/users?sort=sort`
当query参数为多个时，可使用`QueryMap`替代多个Query：
```java
@GET("group/{id}/users")
void groupList(@Path("id") int id, 
              @QueryMap Map<String, String> query, 
              Callback<List<User>> callback);
```
等同于：
```java
@GET("group/{id}/users")
void groupList(@Path("id") int id, 
              @Query("sort") String sort, 
              @Query("limit") int limit, 
              Callback<List<User>> callback);
```
相应地，query参数要封装成Map传入：
```java
HashMap<String, String> query = new HashMap();
query.put("sort", sort);
query.put("limit", limit);
```
组装出的url为`https://api.github.com/repos/id/users?sort=sort&limit=limit`

## 解析器
Wasp默认使用Gson解析网络请求返回数据。若要自定义解析器，传入自定义的解析器。自定义解析器需要实现`Parser`接口。
```java
public class CustomParser implements Parser {
  @Override
  public <T> T fromBody(String content, Type type) throws IOException { // 结果解析
    ...
  }
  @Override
  public String toBody(Object body) { // POST body组装
    ...
  }
  @Override
  public String getSupportedContentType() {
    ...
  }
}
```
创建Wasp时可设置自定义的解析器：
```
Wasp wasp = new Wasp.Builder(getContext())
            .setEndpoint("https://api.github.com")
            .setParser(new CustomParser())
            .build();
```

## POST请求
HTTP POST请求需要处理HTTP body。`Parser.toBody()`可自定义body参数的处理。
```java
@POST("/repos/{user}/{repo}")
void addName(@Path("user") String user,
             @Path("repo") String repo,
             @Body String body,
             Callback<Repo> callback
);
```
发送POST请求：
```java
gitHubService.addName(user, repo, body, callback);
```

## 同步/异步
异步请求使用网络库统一管理网络访问线程。若需要使用同步方式，网络请求在发起请求的线程里执行。请勿在Android主线程使用同步方式。
同步接口不传入回调，直接调用接口方法获取数据。请求接口声明：
```java
@GET("users/{user}/repos")
List<Repo> listRepos(@Path("user") String user);
```
发送请求：
```java
List<Repo> repos = gitHubService.listRepos(user);
```

## 取消异步请求
在Android界面销毁时可能需要取消已经发送但还未收到结果的网络请求。与异步接口的区别仅在于接口方法返回参数不同：
```java
@GET("users/{user}/repos")
WaspRequest listRepos(@Path("user") String user, 
                      Callback<List<Repo>> callback);
```
发起和取消请求：
```java
// 发起请求
WaspRequest request = gitHubService.listRepos(user, callback);

// 取消请求
request.cancel();
```

# 库维护地址
  - https://github.com/SethFeng/wasp