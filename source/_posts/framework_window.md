title: Android Window
date: 2018-09-18 19:00:00
tags: [android, window]
categories: [Android]
---

不像Activity和View，Window算是在Android开发中遇到不那么频繁的类。因为在App开发过程中，我们很少碰到直接面向Window的编程。但是，Window在Android Framework中的作用却十分重要。

## 1. Window与Activity、View的关系
由于App开发大多场景只需面向Activity和View，但是，Window在背后不可或缺。Activity和View的显示和手势交互，都离不开Window。
- Activity负责功能，功能之间的切换通过Activity的生命周期控制(AMS)
- View负责功能的具体显示和触摸事件交互
- Window负责系统底层调度显示(WMS)和触摸事件分发
Activity更多的面向应用，Window更多的面向系统。
<!-- more -->

## 2. Window是何时创建和销毁的(Window层级)
新起Activity会调用到`Activity#attach()`方法，创建新的PhoneWindow对象。

```java
mWindow = new PhoneWindow(this, window);
```

退出Activity会触发`Activity#performDestroy()`方法
```
mWindow.destroy()
```


## 3. View是如何添加到Window的，又是如何从Window移除的
Android App有系统默认的Activity布局。一般，我们通过`Activity#setContentView()`设置View，但其实我们自己的View只是成为默认布局中一个ViewGroup的子View。`PhoneWindow#mContentParent`就是这个ViewGroup。先来看看mContentParent的由来。
`Activity#setContentView()`触发PhoneWindow#setContentView()，PhoneWindow发现DecorView未初始化，通过新建一个DecorView对象初始化mDecor。
mContentParent未初始化，通过Window特性选择合适的系统默认layoutResId，传给DecorView。DecorView布局该布局资源，并添加成DecorView的子View。mContentView通过findViewById()方法找到对应的View。
PhoneWindow初始化mContentParent后，将App开发者通过setContentView()传入的layoutResId通过Inflater布局后添加成mContentParent的子View，或者将传入的View直接添加成mContentParent的子View。
```java
mLayoutInflater.inflate(layoutResID, mContentParent)
mContentParent.addView(view, params)
```
当Activity resume时，Activity会调用PhoneWindow的addView()，再到WindowManagerImpl#addView()，到WindowManagerGlobal的addView()，创建ViewRootImpl，并维护三个数组：mViews(DecorView)、mRoots(ViewRootImpl)、mParams(WindowManager.LayoutParams)。并调用其setView()，接着调用到requestLayout()，再调用scheduleTraversals()，向Choreographer注册一次Handler callback监听。Choreographer是Android显示系统的编舞者，每16ms带一次节奏(1000s / 60fps)。当下一个周期来临，这个回调会被触发，调用到ViewRootImpl#doTraversal()对View做遍历。接着调用到performTraversals()，按需触发performMeasure()、performLayout()、perfromDraw()。这里就进入了View的分析范畴了。
当Activity销毁时，会调用到WindowManagerImpl#removeView()，调用ViewRootImpl#doDie()，又调用WindowManagerImpl的doRemoveView()，维护其三个数组。

## 4. W
W是ViewRootImpl的静态内部类，实现了`IWindow.Stub`接口，完成与WindowManagerService的跨进程访问。
```java
static class W extends IWindow.Stub
```
像windowFocusChanged()事件就是由此处分发的。






