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


## Wasp
- Volley + OkHttp
- 友好的请求API，注解+接口
- 强大的回调数据封装
仿Retrofit。
![架构图](https://github.com/orhanobut/wasp/raw/master/images/wasp-diagram.png)
Image部分不使用，使用图片库处理。

```java
public interface GitHubService {
    @GET("users/{user}/repos")
    void listRepos(@Path("user") String user, 
                  Callback<List<Repo>> callback);
}
```

```java
Wasp wasp = new Wasp.Builder(getContext())
            .setEndpoint("https://api.github.com")
            .setParser(new CustomParser())
            .build();
GitHubService gitHubService = wasp.create(GitHubService.class);
gitHubService.listRepos("sethfeng", new Callback<List<Repo>>{
  @Override
  public void onSuccess(WaspResponse response, List<Repo> repo) {
    ...
  }
  @Override
  public void onError(WaspError error) {
    ...
  }
});
```

线程模型和缓存管理使用Volley。


### 接口如何实现发请求？
Wasp#create():
```java
public <T> T create(Class<T> service) {
  if (service == null) {
    throw new NullPointerException("service param may not be null");
  }
  if (!service.isInterface()) {
    throw new IllegalArgumentException("Only interface type is supported");
  }
  NetworkHandler handler = NetworkHandler.newInstance(service, builder);
  return (T) handler.getProxyClass();
}
```
NetworkHandler#getProxyClass()
```java
Object getProxyClass() {
  List<Method> methods = getMethods(service);
  fillMethods(methods);

  return Proxy.newProxyInstance(classLoader, new Class[]{service}, this);
}
```
Java动态代理。
NetworkHandler#invoke():
```java
public Object invoke(Object proxy, final Method method, final Object[] args) throws Throwable {
  final MethodInfo methodInfo = methodInfoCache.get(method.getName());

  switch (methodInfo.getReturnType()) {
    case VOID:
      return invokeCallbackRequest(proxy, method, args);
    case REQUEST:
      return invokeWaspRequest(proxy, method, args);
    case OBSERVABLE:
      return invokeObservable(method, args);
    case SYNC:
      return invokeSyncRequest(method, args);
    default:
      throw new IllegalStateException(
          "Return type should be void, WaspRequest, Observable or Object"
      );
  }
}
```
根据不同的返回值类型，调用Volley的同步/异步请求接口，完成与Volley的对接。
Methods解析：
```java
private void fillMethods(List<Method> methods) {
  for (Method method : methods) {
    MethodInfo methodInfo = MethodInfo.newInstance(context, method);
    methodInfoCache.put(method.getName(), methodInfo);
  }
}
```
MethodInfo#parseXXX()
```java
public interface GitHubService {
    @GET("users/{user}/repos")
    void listRepos(@Path("user") String user, 
                  Callback<List<Repo>> callback);
}
```
parseMethodAnnotations method.getAnnotations() @GET
parseParamAnnotations method.getParameterAnnotations() @Path
parseReturnType method.getGenericReturnType() 异步方式解最后一个参数Callback

Method.parse仅用于请求定义合法化检查，并没有用。真正把注解拼装请求在RequestCreator。
反射影响性能，应避免频繁调用create()，开发时可保持Service的单例。

### 网络回调数据解析Parser
VolleyRequest，继承Volley的Request
```java
protected com.android.volley.Response parseNetworkResponse(NetworkResponse response) {
  try {
    byte[] data = response.data;
    Object responseObject = Wasp.getParser().fromBody(data, responseObjectType,
            HttpHeaderParser.parseCharset(response.headers, PROTOCOL_CHARSET));
    ...
  }
  ...
}
```
EMGsonParser
```java
public <T> T fromBody(byte[] content, Type type, String charset) throws IOException {
    if ("byte[]".equals(type.toString())) {
        return (T) content;
    } else if (type == String.class) {
        return (T) new String(content, charset);
    }
    // Gson解析
    ...
}
```

