# Android

## 操作系统

### Android系统架构

- Applications(System Apps, User Apps)
- Java Framework(View System/Resource Manager/Notification Manager/Content Providers)
- Native C/C++ Libraries
- Android Runtime(Dalvik/ART)
- HAL
- Linux kernel

## Framework

### Handler-Looper-MessageQueue

- HandlerThread(Looper.prepare(sThreadLocal.setLooper(new Looper())) - Looper.loop()开始死循环，不停地从Looper的message queue里取消息执行)) Handler(HandlerThread#getLooper()).post(Message) message add to looper's queue
- Looper#loop - MessageQueue.next(阻塞操作，避免主线程耗尽CPU) - nativePollOnce(pipe管道，有数据写入唤醒)
- Message.obtain()/recycle()

### Application启动过程

- Launcher App - Binder IPC - AMS - Zygote fork一个进程 - 执行ActivityThread.main() - ActivityThread.attach() - AMS.attachApplication() - ActivityThread.bindApplication() - Handler H send msg BIND_APPLICATION - ActivityThread.handleBindApplication - LoadedApk.makeApplication(ActivityThread.mInstrument.newApplication(classname)) - Instrument.callApplicationOnCreate
- 系统服务进程(AMS/WMS/PMS)：system_server(来自zygote)，四大组件通过ApplicationThreadProxy与system_server之间大量Binder通信
- 主线程一直在loop，ActivityThread#main会创建binder线程ApplicationThread，ApplicationThread与AMS通信，遇到消息传递给主线程Handler，loop发现队列有消息就处理。
- 一直loop并不会耗尽CPU，因为loop的queue.next()中的nativePollOnce()会阻塞使主线程进入休眠，收到消息才唤醒
- 每个App进程至少有一个主进程和两个binder进程（ApplicationThread(服务端，客户端是system_server的ApplicationThreadProxy)/ActivityManagerProxy(客户端，服务端是system_server的ActivityManagerService)）
- ApplicationThread extends ApplicationThreadNative extends Binder implements IApplicationThread(extends IInterface)
- ActivityManagerService extends ActivityManagerNative extends Binder implements IActivityManager(extends IInterface)
- aidl写在服务端，提供接口给客户端调用


### Activity启动过程

- ActivityManagerProxy -binder-> AMS -socket-> Zygote fork App进程 -socket-> ActivityThread(main-attach(ApplicationThread)) -> ActivityManagerProxy#attachApplication -binder-> AMS(attachApplication-ApplicationThreadProxy#scheduleLaunchActivity -binder-> ApplicationThread#scheduleLaunchActivity -handler-> ActivityThread#handleLaunchActivity

- Launcher - Activity#startActivity - Instrumentation#startActivity - (ActivityManagerNative.getDefault()取到)ActivityManagerProxy#startActivity - (ServiceManager.getService("activity") BinderProxy)mRemote.transact(START_ACTIVITY_TRANSACTION) --biner--> ActivityManagerNative#onTransact(START_ACTIVITY_TRANSACTION) - AMS#startActivity - ActivityStackSupervisor#startActivityMayWait - ActivityStackSupervisor#startActivityLocked - ActivityStackSupervisor#startActivityUncheckedLocked(LaunchMode) - ActivityStack#startActivityLocked - ActivityStackSupervisor#resumeTopActivitiesLocked - ActivityStack#resumeTopActivityLocked - resumeTopActivityInnerLocked(pause) - ASS.realStartActivityLocked - 
- ActivityThread: Java主程序(main()方法)，创建ActivityThread对象，初始化Looper并开始loop()，有个内部类H Handler，通过收消息推进App的运行
- ActivityManagerService extends ActivtyManagerNative extends Binder implements IActivityManager
- pause: AMS pause - ApplicationThreadProxy#onTransact - schedulerPauseActivity - ActivityThread#sendMsg - H handlePauseActivity
- A Activity起B Activity：A#onPause - B#onCreate-onStart-onResume - A#onStop
- 启动时H收到的msg: LAUNCH_ACTIVITY - ENTER_ANIMATION_COMPLETE


### Service启动过程

- 类似Activity

### View

- ViewRootImpl Choreographer#postCallback(TraversalRunnalble) - doTraversal(遍历) - scheduleTraversals - ViewRootImpl#mView(DecorView) measure/layout/draw  
	Choreographer vsync(无vsync/有vsync/vsync双缓冲/vsync三缓冲) Android 4.1 Project Buffer显示系统优化: VSYNC、Triple Buffer和Choreographer
- onClick

### 图形系统

#### 相关概念： Surface, SurfaceHolder, EGLSurface, SurfaceView, GLSurfaceView, SurfaceTexture, TextureView, SurfaceFlinger, and Vulkan
SurfaceView
TextureView
SurfaceView + SurfaceTexture + EGL + OpenGL
GLSurfaceView
#### 底层

- BufferQueue and gralloc
- SurfaceFlinger, Hardware Composer, and virtual displays
- Surface, Canvas, and SurfaceHolder
- EGLSurface and OpenGL ES(EGL创建平台的画布，OpenGL绘制)
- Vulkan

#### 上层
- SurfaceView and GLSurfaceView
View: App切到前台时由WindowManager把可见的Views渲染到SurfaceFlinger创建的Surface上。主线程执行所有的layout和渲染工作。
SurfaceView: 渲染时只是一个透明的View占位，View可见时由WindowManager通知SurfaceFlinger创建一个新的的Surface，这个过程是异步的，需要用回调监听Surface的创建过程。这个Surface默认在app UI的Surface下面，可以通过zorder设到上面。在这个Surface上的渲染最终都由SurfaceFlinger合成。这
- SurfaceTexture
- TextureView

### Apk包安装过程

### AMS

### WMS

### PMS

### Window

- PhoneWindow - WindowManagerImpl - 

### 对象创建时机

- ActivityRecord什么时候创建：ActivityStackSupervisor#startActivityLocked
- Application什么时候创建 Handler - ActivityThread#handleBindApplication - LoaderApk.makeApplication - Instrumentation.newApplication(clazz.newInstance)
- Activity什么时候创建 ActivityThread#performLaunchActivity
- Window什么时候创建的
- Surface

### 刷机

- aosp源码编译

## 四大组件

### Activity

- Manifest申明(name/LaunchMode/intent-filter(action Main/category LAUNCHER))
- 生命周期(onCreate/onStart/onResume/onPause/onStop/onDestroy)
- Launch Mode(Standard/SingleTop(onNewIntent if at task top, or new instance)/SingleTask(onNewIntent if in task, or new instance)/SingleInstance)
- Fragment(onAttach/onCreate/onViewCreated/onActivityCreated/onStart/onResume/onPause/onStop/onDestroyView/onDestroy/onDetach)
- 跳转系统Activity(拍照/设置悬浮窗权限...)

### Service

- 三种类型：Foreground(startForegroundService, show Notification)/Background(startService)/Bound(bindService)
- startService - onCreate - onStartCommand - stopSelf/stopService - onDestroy
- bindService - onCreate - onBind() - all client unBindService - onUnBind - onDestroy
- startForegroundService - call startForeground(NOTIFICATION_ID, notification) in 5s, or ANR - stopForeground()
- onStartCommand返回值Service被系统杀死后重启方式：START_NOT_STICKY/START_STICKY/START_REDELIVER_INTENT
- Manifest申明(exported=false)
- IntentService(onHandleIntent异步线程(onStartCommand -> HandlerThread post -> onHandleIntent))

### Broadcast/BroadcastReceiver

- 注册方式：静态(Manifest声明，自动启动)/动态(registerReceiver手动启动)，有些广播使用静态注册一家收不到系统广播了
- 

### Content Provider

- app - ContentResolver - ContentProvider增删改查
- 查询系统相册：cursor = MediaStore.Images.Media.query(context.getContentResolver(), MediaStore.Images.Media.EXTERNAL_CONTENT_URI, projectionPhotos);

## View

### 系统View使用

- ...
- ImageView Bitmap
- WebView jsbridge 怎么封装 如何与native通信
- ViewPager PagerAdapter / FragmentPagerAdapter(init all) / FragmentStatePagerAdapter(destroy fragment and cache fragment state)
- RecyclerView：原理：复用同type的子View对象，只需重新bind数据，避免频繁创建View。
- SurfaceView(绘画能放在异步线程的View，创建独立Window，不能做动画)/GLSurfaceView(SurfaceView使用OpenGL线程绘画的实现实例)/TextureView(普通View，可以做动画，有1-3帧延迟，需要window支持硬件加速，需要更多内存)
- 通知栏

### 触摸事件

Decorview dispatchTouchEvent
Activity dispatchTouchEvent
ViewGroup(DecorView) dispatchTouchEvent
DecorView onInterceptTouchEvent
ViewGroup(Child) dispatchTouchEvent
ViewGroup(Child) onInterceptTouchEvent
...no child
View/ViewGroup(last Child) listener.onTouch / onTouchEvent
分发false下沉：dispatchTouchEvent、onInterceptTouchEvent
处理false上浮：listener.onTouch / onTouchEvent
遇true则停
Activity: dispatchTouchEvent / onTouchEvent
ViewGroup: dispatchTouchEvent / onInterceptTouchEvent / super.dispatchTouchEvent
View: dispatchTouchEvent / onTouchEvent
- GestureDetector#onTouchEvent  VelocityTracker#addMovement
- Scroller View#onTouchEvent - Scroller#fling - View#computeScroll - View.scrollTo(Scroller.getX, Scroller.getY)

### 自定义View

- View绘制流程
- onMeasure: 量View大小
setMeasuredDimension(MeasureSpec类型：UNSPECIFIED/ATMOST/EXAXTLY) - for child: ViewGroup#measureChild(child, width, height) - child.measure - child.onMeasure
- onLayout: 在父View中的位置
for child: child.layout(left, top, right, bottom) - child.onLayout()
- onDraw: 绘制
View的绘制机制: ActivityThread#H - Choreographer - ViewRootImpl - DecorView#draw - drawChild

## 动画

### View动画

- 帧动画
- 属性动画
- 补间动画(转场动画)
- AnimationDrawable
- AnimatedVectorDrawable

### Activity动画

## 网络库

### Volley

### OkHttp only one okhttpclient / CustomHttpLoggingInterceptor / Cache
 
### Retrofit StringConverterFactory / ByteArrayConverterFactory / GsonConverterFactory / CacheableCallAdapterFactory(extend retrofit#Call implements enqueue) / client(OkHttpClient)

## 图片库

### Glide

- 仅用于demo

### Picasso

- 东财用

### Fresco 

- 迁移成本大，需要替换View
- 适用于大量图片应用
- SimpleDraweeView.setController(Controller(ImageRequest))
- 大量使用Builder模式(构造函数参数多)：Controller/ImageRequest/
- background/placeholder/failure/retry
- API强大(GenericDraweeHierarchy - ImageRequest(setPostprocessor))
- 离屏缓存Bitmap(预加载) 
- OkHttpClient / JsonConverter
- 列表滚动式停止图片加载：RecyclerView addOnScrollListener state Fresco.getImagePipeline().resume()/pause()

## 后台任务

### new Thread/Thread pool/AsyncTask(ThreadPoolExecutor)
### Service
### AlarmManager: 一段时候后执行一个PendingIntent(如浪客里crash后延迟0.5秒重启app)

- set
- setExact API 19开始系统批量处理Alarm，set设置的时间需要等待系统批量时间到来，setExact不需要，能准时执行
- setRepeating

### JobScheduler: API 21 getSystemService(Context.JOB_SCHEDULAR_SERVICE).scheduler(JobInfo.Builder().build(), new ComponentName(context, MyJobService.class))
### WorkManager: 框架自己选择使用JobScheduler, Firebase JobDispatcher, or AlarmManager.开发者不用关心实现方式

## App多进程模型

### 突破单个进程系统内存分配大小限制
### 隔离逻辑业务，

## Push推送

### Socket + XMPP：开单独进程跑Service连接，收到消息发广播，在主进程通过BroadcastReceiver接收消息，再通过EventBus抛出消息，按需监听。
### WebSockt
### mars
### 第三方：小米、华为、极光

## 存储

### SharedPreference

- 磁盘key-value的xml文件，内存HashMap
- sp - editor opration - commit/apply
- QueueWorker队列存储需要写入磁盘的任务
- commit-同步, apply-异步
- 完全读在内存，避免大量存储

### DB EMOrm
### 文件
### 腾讯MMKV(实现方式mmap，序列化protobuf)

## 音视频

### MediaRecorder

### AudioRecord

### MediaCodec queueInputBuffer/dequeueInputBuffer

### MediaMuxer addTrack / writeSampleData

### 录屏(VirtualDisplay, Suface(SufaceTexture(GLES gen texture))设置给VirtualDisplay, SurfaceTexture设置缓冲区大小和帧回调监听 - frame给一边给本地显示，一边通知MediaCodec从缓冲区Buffer读取内容编码)

### OpenGL

- 接口都在GLES20.java
- shader: opengl语言，glCreateShader(vertext/fragment) glShaderSource glCompileShader
- 创建并使用一个program(glCreateProgram glAttachShader glLinkProgram)

## MultiDex

- 65535(64K reference limit)
- 5.0之前使用Dalvik需要使用MultiDex，打包时生成classesN.dex
- 5.0及之后，不需处理(ART执行预处理，把所有的classesN.dex转成单个.oat执行)

## JobSchedule

## RxJava

- 线程变换原理

## Kotlin

## Android Jetpack

### Architecture

- Data Binding
- AndroidX: 取代support库

## 打包流程

## 优化

### 布局层次

### 内存泄漏

- 静态引用Activity Context：改成Application context引用
- 内部类对外部引用：内部类申明成静态
- 弱引用、软引用
- leakcanary(application.registerActivityLifecycleCallbacks - onActivityDestroyed - KeyedWeakReference<Object> 每个ref一个key，所有key在一个Set里 - ensure gone - 将被回收对象都在ReferenceQueue，从Set移除队列里所有keys - ref还在Set中 - gc - 再次从Set移除queue中 - ref还在Set中，内存泄露，dump hprof heap)
- 软引用与弱引用：GC都回收，弱引用在gc线程扫描到了就回收，用于加速对象回收。做缓存使用Soft，希望GC快速回收使用Weak

### 主线程卡顿

- ANR(Application Not Response) ActivityManagerService定义(按键-5s, broadcast-10s, Service-20s, Service startForeground-5s)
- 耗时计算任务
- 耗时IO任务
- BlockCanary: Looper.getMainLooper().setMessageLogging(Printer)，计算每次打印时间差，主Looper每次执行消息队列里message都会在开始和结束打印一次消息，计算两次事件差即可

### 耗电

### 流量

## 硬件设备

### 摄像头

### 定位

### 加速度传感器

### 蓝牙

### 指纹

## 进程保活

### 提升Android进程优先级

- 有运行的Activity/Service(非空进程，如微信1px Activity(广播监听系统锁屏，锁屏启动透明无界面的Activity，window宽高设置成1px，解锁后finish))
- 前台Service(通知栏显示，可hack不显示通知栏), onStartCommand return START_STICKY,被杀死后系统重启Service，监听onDestroy，在里面启动自己Service
- JobScheduler
- 手机ROM有进程白名单，不杀微信
### 各个品牌的手机接他们对应的推送(手机ROM可能提高自家推送进程优先级)

## 长链接保持

### 进程保活
### 心跳

## 组件化

- 常用组件抽取出来，方便复用。如网络库、图片库、自定义的UI组件库
- 或者指单独的业务模块抽取出组件

### 组建间通信

- 向下注册
- 事件总线

### 小心base下沉

### 代码边界

- module/pins

## 组件化

- 业务模块可选打包成可独立运行的apk或aar
- 业务模块在下沉的共用依赖基础moudle module_base里注册，在基础模块暴露业务模块的对外接口
- Android组件跳转使用ARouter

## 插件化

- 将业务功能模块做成独立的插件，按需加载需要调用的模块
- DexClassLoader(双亲委派：先调用调用基类ClassLoader findClass，找不到再用自己的findClass)
- Atlas
- Droid Plugin

## 热修复

## 路由

## 线程间消息通信

### Callback
### 线程切换Handler
### 事件总线EventBus

## IPC
### Binder

- AIDL: IXxInterface.aidl定义接口 - 系统生成IXxInterface.java extends IInterface，自动生成继承Binder并实现IXxInterface的S
- 传输除基础类型外的类必须实现Parcelable
- 传输数据不能超过1MB
- 一次内存拷贝

## 日志库

## Crash监听
### CrashHandler: Thread.setDefaultUncaughtExceptionHandler(UncaughtExceptionHandler)

## 打点统计

## 响应式编程

## 设计模式

## Java

### HashMap实现机制,HashMap HashTable

- HashMap: Entry<k,v>链表的数组(Hash数组)
- HashMap: 线程不安全，快，接收空的kv
- HashTable: 线程安全(方法加synchroized)，慢，不接受空的key和value

### SparseIntArray

- HashMap对原始类型的key/value需机型自动装箱，导致内存很大(约SparseArray的8倍)。
- 两个原始数据类型数组：key[], value[]
- key[]是有序数组
- 增删改查：二分查找
- 数组地址连续，方便遍历，但是增删效率低(数组长度扩容)。链表地址非连续，需通过next/prev指针遍历，遍历效率低，增删方便(修改指针)。

### Java内存分配
### JVM垃圾回收

### 多线程

- voltile
- synchronized
- 

## 算法

### 二分查找
### ArrayList实现队列
### 快排：时间复杂度-O(nlogn)，思想-先选定第一个数作为锚点，然后从末尾j开始遍历，如果碰到比锚点小的数就与锚点位置互换，转从头i开始找比锚点大的数，知道ij相遇，第一轮结束，保证左边的数都比锚点小，右边的数都比锚点大，再对锚点左右两边递归

## 开发工具

### Eclipse

### Android Device Monitor(deprecated，还能通过命令monitor启动)

- DDMS
- TraceView
- SysTrace 命令行也能用，生成网页报告
- Hierarchy Viewer

### Android Studio

- Android Profiler(Method Trace(CPU Profiler) / Heap Dump(Memory))

- Layout Inspector

### adb

### apktool d

### dex2jar

### jd-gui

## 跨平台

### Weex

- list
- scroller 包ViewAndroid性能低下，每个子View一个层次
- 空间在各端表现不一致

### 小程序

- mpvue

### react native

### Flutter

## 计算机网络

### 物理层 - 数据链路层 - 网络层 - 传输层 - 应用层
### TCP

- 连接三次握手(SYN J - ACK J+1 + SYN K - ACK K+1)，断开四次握手(FIN M - ack M+1 - FIN N - ack N+1)
- 三次握手：ready - ready - go，避免两次握手客户端不知道服务器是否准备好就开始发送数据
- 四次握手：三次握手第二次ACK和SYN，回复和同步消息放在同一个数据包传送。然而断开时，断开回复和确认是不能放在同一个数据包的，因为收到关闭消息后可能自己还有数据没有发送完，需等待数据发送完再发送关闭消息。
- 流量控制：滑动窗口，端到端的。
- 拥塞控制机制：链路上，TCP通过定时器计算往返时间(RTT)和重传超时时间(RTO)，如果网络变糟糕了，发出去的包没收到回复（超时了），发送端就立马重传数据，很可能导致更多拥塞。所以发送端定义了一个缓冲机制-拥塞窗口，根据收到的回复量协调发送量。机制包括四个方面(2算法2跳跃)：1.慢启动(窗口设1，指数增加，迅速达到阈值，进入拥塞避免)；2.拥塞避免(线性增加，直到拥塞发生(超时或三个重复ACK)，阈值减半，窗口置1，进入慢启动)；3.慢启动连续收到3个ack进入快恢复 4.快恢复(窗口设成阈值，进入拥塞避免)
- UDP：都是传输层协议。TCP基于连接，UDP面向非连接(如ping传输小数据)，传输不可靠、适用于少量数据，速度快。

### HTTP

- TCP连接
- HTTP2
- HTTPS: SSL证书(对称加密：DES/AES，速度快，适用于大量数据，但安全性差，需同步密钥；非对称加密：如RSA，公钥加密，私钥解密，持有私钥，公开公钥，安全性好，但速度慢，适用于少量数据；Hash：如MD5/SHA，消息摘要，防消息篡改)
握手阶段(所有消息明文)：客户端生成对称加密

### Linux IPC
1. 管道：在创建时分配一个page大小的内存，缓存区大小比较有限；
2. 消息队列：信息复制两次，额外的CPU消耗；不合适频繁或信息量大的通信；
3. 共享内存：无须复制，共享缓冲区直接付附加到进程虚拟地址空间，速度快；但进程间的同步问题操作系统无法实现，必须各进程利用同步工具解决；
4. 套接字：作为更通用的接口，传输效率低，主要用于不通机器或跨网络的通信；
5. 信号量：常作为一种锁机制，防止某进程正在访问共享资源时，其他进程也访问该资源。因此，主要作为进程间以及同一进程内不同线程之间的同步手段。
6. 信号: 不适用于信息交换，更适用于进程中断控制，比如非法内存访问，杀死某个进程等；
- Binder: Binder数据拷贝只需要一次,基于C/S架构的,有数据传输大小限制，超过1M不适用
- Android OS中的Zygote进程的IPC采用的是Socket（套接字）机制，Android中的Kill Process采用的signal（信号）机制等等。而Binder更多则用在system_server进程与上层App层的IPC交互。


### 阿里电面
- WebView是直接new的么，怎么封装
- Weex渲染原理
- 如何实现跨进程，Binder机制原理
- 图片库如何选型
- 碰到最具有挑战性的点