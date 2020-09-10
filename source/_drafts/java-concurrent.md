MMtitle: Java Concurrency
date: 2016-01-05 15:01:09
tags:
---
(https://docs.oracle.com/javase/tutorial/essential/concurrency/guardmeth.html)
# 进程与线程
# 线程对象
## 线程的定义方式和运行
new Thread(new Runnable() {run()}).start()
new Thread() {run()}.start()
## Thread.sleep() InterruptedException
## Thread.interrupted()
if (Thread.interrupted()) {
    throw new InterruptedException();
}

## Thread.join()
ThreadA.doJobA()
ThreadB.join() // ThreadB.doJobB(), ThreadA will wait until JobB finished
ThreadA.conninueJobA()
## Thread.
# Synchronized
## method
## this
## Object
## Atomic
...
# 高级并发对象
## Lock
## Excutor
### 接口
### 线程池
### fork/join
## 线程安全的集合类：BlockingQueue/ConcurrentMap/ConcurrentNavigableMap
## AtomicXX
## 



Concurrent包
Runnable
Callable
Future

<!-- more -->

Java BIO NIO AIO
http://bbym010.iteye.com/blog/2100868
http://stevex.blog.51cto.com/4300375/1284437

https://docs.oracle.com/javase/tutorial/essential/concurrency/