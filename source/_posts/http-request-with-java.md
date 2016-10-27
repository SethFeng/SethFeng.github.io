title: Java HTTP请求
date: 2016-01-25 13:49:15
tags:
- Java
- HTTP
categories:
- Network
---
移动互联网普及后，越来越多的计算设备添加了联网功能。HTTP几乎成为网络开发中不可避免的网络协议。

#### HTTP协议

###### 历史及功能演变

<!-- more -->

- HTTP 0.9 [Draft](http://www.w3.org/Protocols/HTTP/AsImplemented.html)
    - 1991
    - 地址形式`http : // hostname [ : port ] / path [ ? searchwords ]`，hostname可为域名/数字形式，端口默认80
    - 数据格式为ASCII字符
    - 一次数据传输完断开连接
    - 例子：
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
- HTTP 1.0 [RFC 1945](http://tools.ietf.org/html/rfc1945)
    - 1996
    - 支持POST、HEAD方法
    - 支持请求行、请求头(User-Agent、If-Modified-Since等)和实体(Entity Header/Body)
    - 支持响应状态行、响应头和响应体
    - 返回支持状态码
    - 例子
```
GET http://www.test.com/path/index.html HTTP/1.0
User-Agent: okhttp
```

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
- HTTP 1.1 [RFC 2616](http://tools.ietf.org/html/rfc2616)
    - 1999
    - 2014修订版[RFC 723X](http://tools.ietf.org/html/rfc7230)
    - 支持长连接（之前每个连接都会建立一个TCP连接，加重服务器负担和网络拥塞）
    - 扩展了1.0版本头部字段
    - 例子
```
GET /path/index.html HTTP/1.1
Host: http://www.test.com
User-Agent: okhttp
Connection: Keep-Alive
```
- HTTP 2 [RFC 7540](https://tools.ietf.org/html/rfc7540)
    - 2015
    - ...

mime
multipart/form-data  boundary 可上传多个
application/x-www-form-urlencoded 形如name=tom&age=28
二进制字节 text/plain、application/octet-stream

#### HTTP协议的Java语言实现
###### Apache HttpClient
来自Apache开源项目HttpComponents(http://hc.apache.org)


###### JDK HttpURLConnection
Oracle教程[Custom Networking](http://docs.oracle.com/javase/tutorial/networking/)从几个方面介绍JDK对网络请求的支持：
- Overview
- URL
- Socket
- Datagram
- NetworkInterface
- Cookie

java.net.Handler
```java
protected java.net.URLConnection openConnection(URL u)
    throws IOException {
        return openConnection(u, (Proxy)null);
    }

    protected java.net.URLConnection openConnection(URL u, Proxy p)
        throws IOException {
        return new HttpURLConnection(u, p, this);
    }
```URL.openStream() 
```java
URL oracle = new URL("http://www.oracle.com/");
BufferedReader in = new BufferedReader(
new InputStreamReader(oracle.openStream()));
String inputLine;
while ((inputLine = in.readLine()) != null)
    System.out.println(inputLine);
in.close();
```
```java
public final InputStream openStream() throws java.io.IOException {
    return openConnection().getInputStream();
}

public URLConnection openConnection() throws java.io.IOException {
    return handler.openConnection(this);
}
```
sun.net.www.protocol.http.Handler
```java
protected java.net.URLConnection openConnection(URL u)
    throws IOException {
        return openConnection(u, (Proxy)null);
    }

    protected java.net.URLConnection openConnection(URL u, Proxy p)
        throws IOException {
        return new HttpURLConnection(u, p, this);
    }
```
sun.net.www.protocol.http.HttpURLConnection
```java
protected HttpURLConnection(URL u, Proxy p, Handler handler) {
    ...
}
```
对象创建了，再看getInputStream():
```java
protected HttpClient http;
protected PrintStream ps = null;

public synchronized InputStream getInputStream() throws IOException {
    ...
    if (!checkReuseConnection())
        connect();
    ...
    ps = (PrintStream)http.getOutputStream();

    if (!streaming()) {
        writeRequests();
    }
    http.parseHTTP(responses, pi, this);
    ...
    inputStream = http.getInputStream();

    respCode = getResponseCode();

}

public void connect() throws IOException {
    plainConnect();
}

protected void plainConnect()  throws IOException {
    ...
    http = getNewHttpClient(url, instProxy, connectTimeout);
    http.setReadTimeout(readTimeout);
    ...
    ps = (PrintStream)http.getOutputStream();
    ...
    connected = true;
}
```



HttpClient
```java
public boolean parseHTTP(MessageHeader responses, ProgressSource pi, HttpURLConnection httpuc)
    throws IOException {
        ...
        serverInput = serverSocket.getInputStream();
        ...
    }

@Override
public void openServer(String server, int port) throws IOException {
    serverSocket = doConnect(server, port);
    try {
        OutputStream out = serverSocket.getOutputStream();
        if (capture != null) {
            out = new HttpCaptureOutputStream(out, capture);
        }
        serverOutput = new PrintStream(
            new BufferedOutputStream(out),
                                     false, encoding);
    } catch (UnsupportedEncodingException e) {
        throw new InternalError(encoding+" encoding not found");
    }
    serverSocket.setTcpNoDelay(true);
}
```

NetworkClient
```java
protected Socket doConnect(String var1, int var2) throws IOException, UnknownHostException {
    Socket var3;
    if(this.proxy != null) {
        if(this.proxy.type() == Type.SOCKS) {
            var3 = (Socket)AccessController.doPrivileged(new PrivilegedAction() {
                public Socket run() {
                    return new Socket(NetworkClient.this.proxy);
                }
            });
        } else if(this.proxy.type() == Type.DIRECT) {
            var3 = this.createSocket();
        } else {
            var3 = new Socket(Proxy.NO_PROXY);
        }
    } else {
        var3 = this.createSocket();
    }

    if(this.connectTimeout >= 0) {
        var3.connect(new InetSocketAddress(var1, var2), this.connectTimeout);
    } else if(defaultConnectTimeout > 0) {
        var3.connect(new InetSocketAddress(var1, var2), defaultConnectTimeout);
    } else {
        var3.connect(new InetSocketAddress(var1, var2));
    }

    if(this.readTimeout >= 0) {
        var3.setSoTimeout(this.readTimeout);
    } else if(defaultSoTimeout > 0) {
        var3.setSoTimeout(defaultSoTimeout);
    }

    return var3;
}
```

URLConnection.getInputStream()
```java
URL oracle = new URL("http://www.oracle.com/");
URLConnection yc = oracle.openConnection();
BufferedReader in = new BufferedReader(new InputStreamReader(yc.getInputStream()));
String inputLine;
while ((inputLine = in.readLine()) != null) 
    System.out.println(inputLine);
in.close();
```

HttpURLConnection.getResponse???????
```java
URL url = new URL("http://www.oracle.com/");
HttpURLConnection connection = (HttpURLConnection) url.openConnection();
connection.setRequestMethod("GET");
if (connection.getResponseCode() == HttpURLConnection.HTTP_OK) {
    String message = connection.getResponseMessage();
    System.out.println(message);
}
```
无论是以上哪种方式发送了一个HTTP GET请求，都

sun.net.www.protocol.http.HttpURLConnection extends HttpURLConnection

JDK包java.net支持TCP和UDP网络协议。
- TCP: URL, URLConnection, Socket, and ServerSocket
- UDP: DatagramPacket, DatagramSocket, and MulticastSocket




Android官方博客介绍Android HTTP Client选择(http://android-developers.blogspot.com/2011/09/androids-http-clients.html)时讲到，HttpClient有庞大、灵活的API，稳定、bug少，但庞大的API使得库的功能难以提升。HttpURLConnection在Android 2.3之前有些bug，但2.3之后基本修复。建议Android 2.3以后用HttpURLConnection。


###### Google HttpClient

https://developers.google.com/api-client-library/java/google-http-java-client/

###### Square OkHttp
Android Source HttpUrlConnection default implemantation since KitKat

#### 关于HTTPS
HttpsURLConnection

###### tips
命令行窗口中用telnet测试HTTP协议
```
telnet www.baidu.com 80

GET /index.html HTTP/1.1(CRLF)
Host: baidu.com(CRLF)
(CRLF)

```

```java
String hostName = "www.baidu.com";
String path = "/";
int portNumber = 80;

Socket socket = new Socket(InetAddress.getByName(hostName), portNumber);
PrintWriter out = new PrintWriter(socket.getOutputStream());
BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
StringBuffer sb = new StringBuffer();
sb.append("GET " + path + " HTTP/1.1\r\n");
sb.append("Host: " + hostName + "\r\n");
sb.append("\r\n");
out.print(sb.toString());
out.flush();

String inputLine;
while ((inputLine = in.readLine()) != null) {
    System.out.println(inputLine);
}
```


#### 参考
- http://www.w3.org/Protocols/HTTP/AsImplemented.html
- http://tools.ietf.org/html/rfc1945
- http://tools.ietf.org/html/rfc2616
- http://www.w3.org/Protocols/
- https://tools.ietf.org/html/rfc7540
- http://docs.oracle.com/javase/tutorial/networking/
- http://hc.apache.org
- https://developers.google.com/api-client-library/java/google-http-java-client/