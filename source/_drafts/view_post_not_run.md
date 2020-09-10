# 异步线程调用View#post(Runnable)可能不运行

1. 在View未attach到Window时异步线程调用View#post的Runnable，Android L及以下Runnable不会执行，Android L以上View attach到Window后执行。
2. 在View未attach到Window时主线程调用View#post的Runnable，Android L及以下Runnable可能会执行(performTraversals在UI刷新时很容易触发)，Android L以上View attach到Window后执行。

## Android L

View#post:
```java
public boolean post(Runnable action) {
    final AttachInfo attachInfo = mAttachInfo;
    if (attachInfo != null) {
        return attachInfo.mHandler.post(action);
    }
    // Assume that post will succeed later
    ViewRootImpl.getRunQueue().post(action);
    return true;
}
```

ViewRootImpl#getRunQueue:
```java
static final ThreadLocal<RunQueue> sRunQueues = new ThreadLocal<RunQueue>();

static RunQueue getRunQueue() {
    RunQueue rq = sRunQueues.get();
    if (rq != null) {
        return rq;
    }
    rq = new RunQueue();
    sRunQueues.set(rq);
    return rq;
}

private void performTraversals() {
	...
    getRunQueue().executeActions(mAttachInfo.mHandler);
    ...
}
```
View在attach到Window时，post Runnable都会被主线程Handler添加到消息队列等待运行。
在View在未attach到Window时，Runnable会添加到ViewRootImpl的运行队列，ViewRootImpl的运行队列由ThreadLocal修饰，每个线程取的队列不一样。在View刷新时调用到ViewRootImpl#performTraversals，这时队列里Runnable被Handler添加到消息队列的唯一入口。这个入口只会在主线程被调用，其它线程不会被执行，这就导致View在未attach到Window时在异步线程调用View#post的Runnable一直未被Handler添加到消息队列，Runnable一直未执行。

## Android M

View#post:
```java
public boolean post(Runnable action) {
    final AttachInfo attachInfo = mAttachInfo;
    if (attachInfo != null) {
        return attachInfo.mHandler.post(action);
    }

    // Postpone the runnable until we know on which thread it needs to run.
    // Assume that the runnable will be successfully placed after attach.
    getRunQueue().post(action);
    return true;
}

private HandlerActionQueue mRunQueue;

private HandlerActionQueue getRunQueue() {
    if (mRunQueue == null) {
        mRunQueue = new HandlerActionQueue();
    }
    return mRunQueue;
}

void dispatchAttachedToWindow(AttachInfo info, int visibility) {
    ...
    // Transfer all pending runnables.
    if (mRunQueue != null) {
        mRunQueue.executeActions(info.mHandler);
        mRunQueue = null;
    }
    ...
}
```
Android M后，View有自己的RunQueue，并且队列与调用线程无关。在没有attach到Window时，Runnable添加到队列里。当View attach到Window时会调用到dispatchAttachedToWindow，队列里所有action将由主线程Handler添加到消息队列等待运行。