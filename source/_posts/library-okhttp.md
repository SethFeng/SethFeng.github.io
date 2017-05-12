title: OkHttp
date: 2016-02-02 10:25:14
tags:
- Android
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


# 网络库解析OkHttp/Volley/Wasp
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

### 线程模型

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

### 请求流程
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

### 拦截器链
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

### 缓存管理
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

### 连接机制
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

### 线程模型
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

### 缓存管理
一个Request对应一个文本文件缓存。
默认启用缓存，缓存大小5M，DiskBasedCache，顺序：无序(HashMap)

If-Modified-Since: Tue, 15 Mar 2016 12:58:50 GMT+00:00
```
root@vbox86p:/data/data/com.feng.androidnetlib/cache/volley # ls
-1161567360-1808666461
```

### 网络回调
Request构造函数自带Listener和ErrorListener，回调函数分别由Request的deliverResponse和deliverError触发。
deliverResponse/deliverError由ResponseDelivery触发。
ResponseDelivery.ResponseDeliveryRunnable使用Handler处理回调，Looper为主线程的Looper，回调函数在主线程执行。
注意不要在回调函数里处理耗时操作。   

### Callback.onResponse()注意
> Note that transport-layer success (receiving a HTTP response code, headers and body) does not necessarily indicate application-layer success: response may still indicate an unhappy HTTP response code like 404 or 500.

传输层的成功并不表示应用层的成功。在应用过程中，服务器返回404或者500等非成功状态码，可能需要回调失败。需要区别时，只需在onResponse()里判断response.isSuccessful()。


# 参考
[OkHttp使用教程](http://www.jcodecraeer.com/a/anzhuokaifa/androidkaifa/2015/0106/2275.html)

[OKHttp源码解析](http://frodoking.github.io/2015/03/12/android-okhttp/)
