title: Android network request
date: 2015-12-23 20:53:33
tags: android
---
# 1. HTTP协议
## 历史
### - HTTP 0.9 [Draft](http://www.w3.org/Protocols/HTTP/AsImplemented.html)
- 1991
- 请求地址形式为`http:// hostname[:port]/path[?searchwords]`。hostname可为域名/数字形式，端口默认80
- 数据格式为ASCII字符
- 一次数据传输完断开连接

<!-- more -->

请求：
```
GET http://www.test.com/path/index.html
```
响应：
```
<html>
<body>
<p>Hello World!</p>
</body>
</html>
```

### - HTTP 1.0 [RFC 1945](http://tools.ietf.org/html/rfc1945)
- 1996
- 支持POST、HEAD方法
- 支持请求行、请求头(User-Agent、If-Modified-Since等)和实体(Entity Header/Body)
- 支持响应状态行、响应头和响应体
- 返回支持状态码

请求：
```
GET http://www.test.com/path/index.html HTTP/1.0
User-Agent: okhttp
```
响应：
```
HTTP/1.0 200 OK
Server: Microsoft-IIS/7.5
Content-Type: text/html

<html>
<body>
<p>Hello World!</p>
</body>
</html>
```
### - HTTP 1.1 [RFC 2616](http://tools.ietf.org/html/rfc2616)
- 1999
- 2014修订版[RFC 723X](http://tools.ietf.org/html/rfc7230)
- 支持长连接，避免每个请求都建立一个TCP连接，加重服务器负担和网络拥塞
- 扩展了1.0版本头部字段

请求：
```
GET /path/index.html HTTP/1.1
Host: http://www.test.com
User-Agent: okhttp
Connection: Keep-Alive
```
### - HTTP 2 [RFC 7540](https://tools.ietf.org/html/rfc7540)
- 2015
- 头部压缩
- Server Push
- ...

现在主要使用1.1版本。
## 关于Request格式
请求行: method + path + version
头：
- 通用头(Cache-Control/Connection/Date等)，Request和Response共用，与请求实体无关。
- 请求头(Host/Accept-Encoding/If_Modified_Since/User-Agent等)，Request专用。
- 实体头(Content-Encoding/Content-Length/Content-Type/Expires/Last-Modified等)。请求携带body时，表明实体的元信息；或者用于自定义头部字段，与是否携带实体无关。
CRLF
[ body ]

## 关于Response格式
状态行: version + code + message
头：
- 通用头，同Request
- 回复头(ETag/Server等)，Response专用。
- 实体头，同Request
CRLF
[ body ]

## 关于MIME
POST请求时最好准确指定Body内容的格式。常见的形式有：
- `text/plain`，纯文本
- `application/x-www-form-urlencoded`，形如"name=tom&age=28"的key-value纯文本
- `application/json`，Json格式纯文本
- `image/jpeg`，JPEG图片

## 关于编码
- 请求行和请求头
特殊字符和中文字符需要编码。如url中查询参数`key=value`中`value`、自定义请求头的值。
- 携带字符串Body的请求(如POST)，发起请求时最好携带编码：
`ContentType: "text/html;charset=UTF-8"`
- 请求的返回结果Body形式是字符串，服务器最好携带编码
`ContentType: "text/html;charset=UTF-8"`

# 2. HTTP的Java实现
HTTP是应用层协议，基于传输层的TCP协议。TCP的Java实现是[Socket](http://docs.oracle.com/javase/tutorial/networking/sockets/definition.html)。
Socket对HTTP GET请求的简单实现:
```java
Socket socket = new Socket();
URL url = new URL("http://sethfeng.github.io");
String host = url.getHost();
int port = url.getDefaultPort();
SocketAddress dest = new InetSocketAddress(host, port);
socket.connect(dest);

String path = "/index.html";
OutputStreamWriter streamWriter = new OutputStreamWriter(socket.getOutputStream());
BufferedWriter bufferedWriter = new BufferedWriter(streamWriter);
bufferedWriter.write("GET " + path + " HTTP/1.1\r\n");
bufferedWriter.write("Host: " + host + "\r\n");
bufferedWriter.write("\r\n");
bufferedWriter.flush();

InputStreamReader streamReader = new InputStreamReader(socket.getInputStream());
BufferedReader bufferedReader = new BufferedReader(streamReader);

StringBuilder result = new StringBuilder();
String line = null;
while ((line = bufferedReader.readLine()) != null) {
    result.append(line + "\n");
}    
```

三种基于Socket的HTTP协议经典实现：
## Apache HttpClient
来自Apache开源项目HttpComponents(http://hc.apache.org)。Android 2.3之后已不建议使用。
```java
HttpClient client = new DefaultHttpClient();  
HttpGet request = new HttpGet();  
request.setURI(new URI("http://sethfeng.github.io/index.html"));  
HttpResponse response = client.execute(request); 
in = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));
...
```
## JDK HttpURLConnection
JDK实现的HTTP对外API：URL、URLConnection、**HttpURLConnection**。
```java
URL oracle = new URL("http://sethfeng.github.io/index.html");
HttpURLConnection urlConnection = (HttpURLConnection) oracle.openConnection();
if (urlConnection.getResponseCode() == HttpURLConnection.HTTP_OK) {
    BufferedReader in = new BufferedReader(new InputStreamReader(urlConnection.getInputStream()));
    StringBuilder result = new StringBuilder();
    String inputLine;
    while ((inputLine = in.readLine()) != null)
        result.append(line + "\n");
    in.close();
}
```
Android 4.4之后，HttpURLConnection底层实现已被OkHttp替换。
## Square OkHttp
```java
OkHttpClient client = new OkHttpClient();
Request request = new Request.Builder()
        .url("http://sethfeng.github.io/index.html")
        .build();
Call call = client.newCall(request);
Response response = call.execute();
String result = response.body().string();
```

# 3. Android网络库
## 网络库 vs HTTP库
HTTP库偏底层，是Java对HTTP协议的封装。
网络库偏上层管理，如线程模型、缓存管理、网络回调。
两个库通常搭配使用。如Volley的HTTP库在Android2.3之前默认使用HttpClient，之后默认使用HttpURLConnection，也可以搭配OkHttp使用。
## 常见网络库
- [volley](https://github.com/mcxiaoke/android-volley)
- [stephanenicolas/robospice](https://github.com/stephanenicolas/robospice)
- [loopj/android-async-http](https://github.com/loopj/android-async-http)
- [square/retrofit](https://github.com/square/retrofit)
- [orhanobut/wasp](https://github.com/orhanobut/wasp)

# 4. 网络库解析OkHttp/Volley/Wasp
## OkHttp
比一般HTTP库做的更多：
- 支持HTTP/2，紧跟时代步伐。
- 连接池管理，默认每个Host同时支持5个连接，同时支持64个请求。
- 支持异步请求、支持并发请求。Android不允许在主线程操作网络请求。

```java
OkHttpClient client = new OkHttpClient();
Request request = new Request.Builder()
                .url("http://sethfeng.github.io/index.html")
                .build();
Call call = client.newCall(request);
// 同步
Response response = call.excute();
// 异步
call.enqueue(new Callback() {
    @Override
    public void onFailure(Request request, IOException e) {
        ...
    }
    @Override
    public void onResponse(Response response) throws IOException {
        ...
    }
});
```


![结构](http://frodoking.github.io/img/android/okhttp_instructure.png)

### - 线程模型

异步请求分发器--Dispatcher：
```java
/** Ready calls in the order they'll be run. */
private final Deque<AsyncCall> readyCalls = new ArrayDeque<>();

/** Running calls. Includes canceled calls that haven't finished yet. */
private final Deque<AsyncCall> runningCalls = new ArrayDeque<>();

/** In-flight synchronous calls. Includes canceled calls that haven't finished yet. */
private final Deque<Call> executedCalls = new ArrayDeque<>();

ExecutorService executorService = new ThreadPoolExecutor(0, Integer.MAX_VALUE, 60, TimeUnit.SECONDS, new SynchronousQueue<Runnable>(), Util.threadFactory("OkHttp Dispatcher", false));

private void promoteCalls() {
    if (runningCalls.size() >= maxRequests) return; // Already running max capacity.
    if (readyCalls.isEmpty()) return; // No ready calls to promote.

    for (Iterator<AsyncCall> i = readyCalls.iterator(); i.hasNext(); ) {
      AsyncCall call = i.next();

      if (runningCallsForHost(call) < maxRequestsPerHost) {
        i.remove();
        runningCalls.add(call);
        getExecutorService().execute(call);
      }

      if (runningCalls.size() >= maxRequests) return; // Reached max capacity.
    }
  }
```
- readyCalls：异步请求等待队列，enqueue()时可能添加，promoteCalls()时可能转移到runningCalls。
- runningCalls：异步请求队列，enqueue()和promoteCalls()时可能添加，finish()移除，并触发promoteCalls()。
- executedCalls：同步请求队列，excute()添加，finish()移除。

finish()在finally{}里，最终都会调用到（最终都会从队列移除）。
求证：readyCalls cancel()并不会立即收到回调，要等执行队列调度执行才会，等得太久了吧？

注意Callback里回调方法执行的线程是网络请求所在线程，使用者在自行实现的回调函数里不能进行UI操作。

### - 请求流程
- Call/AsynCall#execute()
- Call#getResponseWithInterceptorChain()
- Call.getResponse()
- HttpEngine
engine.sendRequest()
engine().readResponse()
engine.readNetworkResponse
transport.readResponseHeaders()
transport.openResponseBody
[ retryEngine ]
- return engine.getResponse()

说好的Socket呢？
发起请求是在Connection.connect()这里，实际执行是在HttpConnection.flush()这里进行一个刷入。这里重点应该关注一下sink和source，他们创建的默认方式都是依托于同一个socket：
this.source = Okio.buffer(Okio.source(socket));
this.sink = Okio.buffer(Okio.sink(socket));
如果再进一步看一下io的源码就能看到：
Source source = source((InputStream)socket.getInputStream(), (Timeout)timeout);
Sink sink = sink((OutputStream)socket.getOutputStream(), (Timeout)timeout);

![请求流程图](http://frodoking.github.io/img/android/okhttp_request_process.png)

### - 拦截器链
根据调用时机的不同，OkHttp提供两种拦截器，以供使用“切面”执行自定义代码。
```java
client.interceptors().add(xxApplicationInterceptor);
client.networkInterceptors().add(xxNetworkInterceptor);
```

`ApplicationInterceptorChain`用于Request发出前拦截，`NetworkInterceptorChain`用于Request发出后拦截。
从使用场景来看，ApplicationInterceptorChain适用于对请求信息进行打印、修改等操作；NetworkInterceptorChain适用于操作Response的接收过程和结果。
![Interceptors](https://raw.githubusercontent.com/wiki/square/okhttp/interceptors@2x.png)
请求过程中的调用时机：
- `Call#getResponseWithInterceptorChain()`调用到`Call.ApplicationInterceptorChain`。
- `engine().readResponse()`调用到`HttpEngine.NetworkInterceptorChain`。`engine().readResponse()`在`engine.sendRequest()`之后，此时请求已发出。
关键点--`Chain#proceed()`：
```java
public Response proceed(Request request) throws IOException {
    ...
    if (chain has next interceptor) response = nextChainInterceptor.proceed(request);
    else response = engine.readNetworkResponse();
    ...
    return response;
}
```

### - 缓存管理
默认不开启缓存。
开启缓存：
```java
client.setCache(new Cache(new File(mContext.getCacheDir() + "/okhttp"), 5 * 1024 * 1024));
```
缓存策略：DiskLruCache
```
root@vbox86p:/data/data/com.feng.androidnetlib/cache/okhttp # ls
2dc5dc93a8774a576e03c0494be88a7e.0
2dc5dc93a8774a576e03c0494be88a7e.1
journal
```
responseCache.get(request)
命中缓存不发请求。

engine.sendRequest()
缓存命中直接给userResponse赋值，readResponse()时发现userResponse不为空，直接返回。
engine().readResponse() -- responseCache.put(response)

### - 连接机制
HttpEngine Connector ConnectionPool Route Transport HttpConnection

连接池可以有多少个连接器？一个连接器能同时发送多少个请求？一个新的请求对应的连接器满负荷状态时，会缓存到连接器还是会新开一个连接器？

 If your service has multiple IP addresses OkHttp will attempt alternate addresses if the first connect fails. 
 Routes使用到项目的可能性（自动更换地址）
Routes是自动的么？能手动设置么？

![详细类关系图](http://frodoking.github.io/img/android/okhttp_okhttpclient_class.png)

### - Tips
- 但是如果请求/返回Body太大（超过1MB），如上传/下载文件，应避免把所有数据都读取到内存，建议使用流方式处理。
- 同一个App应只调用一次`new OkHttpClient()`。多次new会产生多个线程池。
- 单个请求的个性化参数设置：
client = mClient.clone();
对此client进行特殊参数设置。此client与默认OkHttpClient共用一个线程池。

## Volley
```java
RequestQueue requestQueue = Volley.newRequestQueue(mContext);
Request request = requestQueue.add(new StringRequest("http://sethfeng.github.io/index.html",
    new Response.Listener<String>() {
        @Override
        public void onResponse(String response) {
            ...
        }
    },
    new Response.ErrorListener() {
        @Override
        public void onErrorResponse(VolleyError error) {
            ...
        }
}));

```
HTTP库选择：
```java
public static RequestQueue newRequestQueue(Context context, HttpStack stack) {
    if (stack == null) {
            if (Build.VERSION.SDK_INT >= 9) {
                stack = new HurlStack();
            } else {
                stack = new HttpClientStack(AndroidHttpClient.newInstance(userAgent));
            }
        }
}
```
可让OkHttp实现HttpStack，让Volley搭配OkHttp：
```java
class OkHttpStack implements HttpStack {
  private final OkHttpClient client;
  OkHttpStack(OkHttpClient client) {
    this.client = client;
  }
  @Override
  public HttpResponse performRequest(Request<?> request, Map<String, String> additionalHeaders)
      throws IOException, AuthFailureError {
    // Volley request -> OkHttp request
    ...
    Call okHttpCall = client.newCall(okHttpRequest);
    Response okHttpResponse = okHttpCall.execute();
    // OkHttp response -> Volley response
    ...
    return response;
  }
}
```

### - 线程模型
同步/异步 RequestFuture

```java
private final PriorityBlockingQueue<Request<?>> mCacheQueue = new PriorityBlockingQueue<Request<?>>();

private final PriorityBlockingQueue<Request<?>> mNetworkQueue = new PriorityBlockingQueue<Request<?>>();

private NetworkDispatcher[] mDispatchers;

private CacheDispatcher mCacheDispatcher;
```
NetworkDispatcher 4个，处理网络请求
CacheDispatcher 1个，Cache的两层含义：从缓存取/请求等待队列
每个Request有一个全局自增的sequence

RequestQueue#add():
mCacheQueue.add(request);

CacheDispather#run():
request = mCacheQueue.take(); // 队列中有就取一个，没有就一直等待
mNetworkQueue.put(request); // 是否执行受Cachey命中/过期影响

4个NetworkDispatcher#run():
request = mQueue.take(); // mNetworkQueue, 队列中有就取一个，没有就一直等待
NetworkResponse networkResponse = mNetwork.performRequest(request);

插曲：如何实现重复请求过滤？
private final Map<String, Queue<Request<?>>> mWaitingRequests = new HashMap<String, Queue<Request<?>>>();
RequestQueue#add(Request):
第一次请求：
mWaitingRequests.put(cacheKey, null); // 添加到mCacheQueue
第二次请求：
mWaitingRequests.put(cacheKey, stagedRequests); // 不添加到mCacheQueue
第二次请求添加到mCacheQueue:
RequestQueue#finish(Request);
waitingRequests = mWaitingRequests.remove(cacheKey);
mCacheQueue.addAll(waitingRequests);

### - 缓存管理
一个Request对应一个文本文件缓存。
默认启用缓存，缓存大小5M，DiskBasedCache，顺序：无序(HashMap)

If-Modified-Since: Tue, 15 Mar 2016 12:58:50 GMT+00:00
```
root@vbox86p:/data/data/com.feng.androidnetlib/cache/volley # ls
-1161567360-1808666461
```

### - 网络回调
Request构造函数自带Listener和ErrorListener，回调函数分别由Request的deliverResponse和deliverError触发。
deliverResponse/deliverError由ResponseDelivery触发。
ResponseDelivery.ResponseDeliveryRunnable使用Handler处理回调，Looper为主线程的Looper，回调函数在主线程执行。
注意不要在回调函数里处理耗时操作。    

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

# 5. 特殊的网络库
## 图片库
图片是Android一种普遍而又特殊的数据资源，一般要完整展示到UI，处理起来耗流量、耗时、耗内存。
常见的库有Picasso、Glide、Fresco等。

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
## Socket实现自定义协议
自行制定的协议，使用Socket实现可靠的网络服务。

# 参考
- http://www.w3.org/Protocols/HTTP/AsImplemented.html
- http://tools.ietf.org/html/rfc1945
- http://tools.ietf.org/html/rfc2616
- http://www.w3.org/Protocols/
- https://tools.ietf.org/html/rfc7540
- http://docs.oracle.com/javase/tutorial/networking/
- http://hc.apache.org
- http://www.tuicool.com/articles/mq2qm26
- http://frodoking.github.io/2015/03/12/android-okhttp/
- http://blog.csdn.net/chenzujie/article/details/47158645
- http://www.jianshu.com/p/3141d4e46240