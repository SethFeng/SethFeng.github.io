测试模块 junit http mock


# Kotlin Coroutines

## 协程 vs 线程
都是用来处理多任务
线程是抢占式、协程是非抢占式。线程执行多任务切换线程需要CPU中断，协程不需要
线程可以并发，协程只能并行
线程是CPU的思考方式，协程是人分解任务思考方式

## 设计

CoroutineScope
CoroutineDispatcher


CoroutineStackFrame

## 创建协程


### launch
### async
### runBlocking

## CoroutineScope:


suspend fun

DispatchedContinuation



runBlocking
- BlockingCoroutine()
- BlockingCoroutine#joinBlocking()
- 一个Thread维持一个EventLoop(ThreadLocal)，EventLoop用count记录待执行任务数量

