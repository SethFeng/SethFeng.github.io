title: Android系统栏UI适配
date: 2018-10-18 19:00:00
tags: [Android, UI, SystemBar, StatusBar, NavigationBar]
categories: [Android]
---
系统栏包括了状态栏(StatusBar)和导航栏(NavigationBar)。早期的导航栏时实体按键，现在的手机基本上都使用虚拟导航栏。
状态栏和导航栏默认一直显示。APP在系统栏区域显示内容，可让设备一屏显示更多的内容，提升用户体验。当然，利用系统栏显示内容区域，可能会增加App交互的复杂度。
<!-- more -->
![img](/assets/android_system-ui.png "状态栏和导航栏")

## 隐藏状态栏
状态栏区域用于显示系统网络、电池、时间和通知栏消息Logo等。
隐藏状态栏，让内容显示在状态栏下可以通过在xml设置Activity的Theme，也可以通过代码。
通过Activity Theme隐藏状态栏：
```xml
<item name="android:windowFullscreen">true</item>
```
通过代码隐藏状态栏：
```java
window.setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
        WindowManager.LayoutParams.FLAG_FULLSCREEN)
```
官方推荐的代码隐藏方式是Android 4.1以下用上面代码，4.1及以上使用设置DecorView的systemUiVisibility Flag：
```java
window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_FULLSCREEN
```
但是效果并不好。4.1及以上内容区会抖动(resize)，而且每次窗口重新获取焦点状态栏都会重新出来，需在`onWindowFocusChanged()`再次调用代码隐藏。所以若用代码实现隐藏状态栏，推荐使用设置Window Flag的方式，效果同设置Activity Theme一样好。
Window重新获得焦点时，状态栏会自动出现并消失，此时的状态栏4.4之前是默认的背景色，4.4之后是半透明的。4.4之后可以通过手势从屏幕上边缘向下拖拽显示出半透明状态栏，几秒钟后自动隐藏。
在设计上，有ActionBar的界面状态栏隐藏时应确保ActionBar也隐藏。

## 状态栏显示内容
从Android 4.1开始内容区可以显示在状态栏下面。该模式适合内容区顶部是没有手势交互纯粹内容显示区。如果状态栏下可能显示内容区的手势操作View，用户操作该区域时APP并不能响应，会让用户费解。
通过代码设置内容区显示在状态栏：
```java
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
    activity.window.decorView.systemUiVisibility = 
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
}
```
然而，仅让内容区显示在状态栏下并没有扩大可视内容区。需要设置状态栏透明度才能把状态栏变成可视内容区。
代码设置状态栏颜色：
```java
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
    activity.window.statusBarColor = Color.TRANSPARENT
}
```
xml Theme设置状态栏颜色(v21)：
```xml
<item name="android:statusBarColor">#00ff00</item>
```

所以，要在状态栏下显示内容，从Android 5.0开始适配才有意义。透明状态栏下就不要放ActionBar了，否则会挑战审美下限。
对状态栏设置透明度可能出现状态栏下内容区为偏白色。默认的状态栏为深色模式，状态栏的图标为偏白色。状态栏为偏白色后，上面的图片容易看不清。此时需设置状态栏为浅色模式，让状态栏上的图片显示偏深色，这需要Android 6.0版本才开始支持。
代码设置浅色状态栏：
```java
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
    activity.window.decorView.systemUiVisibility = 
            View.SYSTEM_UI_FLAG_LIGHT_STATUS_BAR
}
```
xml Theme设置状态栏浅色模式(v23)：
```xml
<item name="android:windowLightStatusBar">true</item>
```
如果碰到需要通过设置xml里根布局`android:fitsSystemWindows`属性来适配或者通过设置xml根布局的顶部留空大小来适配内容区和状态栏的重叠问题，先要考虑清楚你的界面是否真的需要设置特殊的系统栏模式。通过`fitsSystemWindows`适配系统会把根布局的孩子往下移到状态栏下，往往并没有增大内容显示区。更复杂的情况可能需手动设置顶部多个View的顶部留空属性(paddingTop/marginTop)。如果适配后发现内容显示区并没有增大，就不要犹豫改用普通默认系统栏模式。
如果需求仅需在半透明系统栏下显示内容区，从Android 4.4开始可以简单的通过设置Theme实现：
```xml
<item name="android:windowTranslucentStatus">true</item>
<item name="android:windowTranslucentNavigation">true</item>
```

## 隐藏导航栏
对于有虚拟导航栏的手机，隐藏导航栏可以扩大内容显示区。在设计上，隐藏导航栏的同时需同时隐藏状态栏。使用该模式时需配合上面介绍的隐藏状态栏的方法，再加上隐藏导航栏的代码：
```java
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
    activity.window.decorView.systemUiVisibility = 
            View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
}
```
该模式在触摸屏幕时导航栏会再次弹出并引起内容区Resize发生抖动，效果并不好。而且每次出现后要再次隐藏需调用代码再执行一次。

## 导航栏显示内容
从Android 4.1开始可以让导航栏区域编程内容区。和状态栏显示内容一样，需设置导航栏的透明度，让导航栏下内容区可见，这种模式才有意义。这种模式常配合状态栏显示内容一起使用。
```java
// 设置导航栏区域作为内容区
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
    activity.window.decorView.systemUiVisibility = 
            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or 
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE
}
```
代码设置系统栏颜色：
```java
// 设置状态栏和导航栏透明度，是系统栏下内容区可见
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
    activity.window.statusBarColor = Color.TRANSPARENT
    activity.window.navigationBarColor = Color.TRANSPARENT
}
```
xml Theme设置状态栏颜色(v21)：
```xml
<item name="android:statusBarColor">#00ff00</item>
<item name="android:navigationBarColor">#00ff00</item>
```

## 全屏模式-Lean Back
从Android 4.1开始支持Lean Back全屏模式。在Lean Back全屏模式下，触摸屏幕任何地方都会退出全屏模式。
```java
// 进入Lean Back全屏模式
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
    activity.window.decorView.systemUiVisibility =  
            View.SYSTEM_UI_FLAG_FULLSCREEN or 
            View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or // hide
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE or 
            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or 
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN // stable
}
```
为优化用户体验，一般进入Activity时设置全屏模式，用户退出全屏模式后如果用户触摸内容区，立即调用代码再次进入全屏模式，否则若干秒后再次调用代码自动进入全屏模式。当Activity窗口重新获取焦点时立即进入全屏模式。
```java
// 退出全屏
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
    activity.window.decorView.systemUiVisibility = 
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE or 
            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or 
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
}
```

```java
// 监听系统栏可见变化
window.decorView.setOnSystemUiVisibilityChangeListener { visibility ->
    if (visibility and View.SYSTEM_UI_FLAG_FULLSCREEN == 0) {
        // system ui visible, should hide it delayed
    } else {
        // system ui gone
    }
}
```

## 全屏模式-Immersive
从Android4.4开始支持沉浸式全屏模式。沉浸式全屏模式与Lean Back全屏模式基本相同，只不过默认情况下，Lean Back模式触摸屏幕就会退出全屏模式，而Immersive模式要从屏幕顶部下滑出状态栏或者从底部上滑出导航栏才能退出全屏模式。用法同Lean Back。
```java
// 进入Immersive全屏模式，比Lean Back多一个View.SYSTEM_UI_FLAG_IMMERSIVE flag
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
    activity.window.decorView.systemUiVisibility = 
            View.SYSTEM_UI_FLAG_IMMERSIVE or // immerse
            View.SYSTEM_UI_FLAG_FULLSCREEN or 
            View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or // hide
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE or 
            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or 
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN // stable
}
```

## 全屏模式-Immersive Sticky
从Android 4.4开始支持Sticky沉浸全屏模式，用户可通过从屏幕顶部下滑出状态栏或者从底部上滑出导航栏才能退出全屏模式，此时的系统栏为半透明。系统会在若干秒后自动隐藏系统栏，用户触摸屏幕也会触发隐藏，无需监听系统栏可见性变化。这种模式适合严重需要用户沉浸场景的页面。需要在Window每次获取焦点时设置。
```java
if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
    activity.window.decorView.systemUiVisibility = 
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or // immerse sticky
            View.SYSTEM_UI_FLAG_FULLSCREEN or 
            View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or // hide
            View.SYSTEM_UI_FLAG_LAYOUT_STABLE or 
            View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or 
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN // stable
}
```

隐藏NavigationBar会被键盘弹起破坏，需要手动再次隐藏