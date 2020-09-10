title: Android 6.0版本之前onVisibilityChanged问题
date: 2020-09-10 20:53:33
tags: [Android, View, onVisibilityChanged]
categories: [Android]
---
开发时碰到一个问题，自定义`View`/`ViewGroup`调用重写`onVisibilityChanged`方法时，Android 6.0以下类的成员变量可能还未初始化，收到的`visibility`值不对。
<!-- more -->
## 问题分析
类定义：
```java
public class TestView extends View {

    private Integer aInt = new Integer(1);

    public TestView(Context context) {
        super(context);
    }

    public TestView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public TestView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void onVisibilityChanged(@NonNull View changedView, int visibility) {
        Log.d(TAG, "onVisibilityChanged: " + visibility + " " + isShown() + " " + aInt);
    }
}
```
XML布局：
```xml
<com.example.test.TestView
    android:layout_width="100dp"
    android:layout_height="100dp"
    android:background="#ff0000"
    android:visibility="gone" />
```
Android 6.0以下打印Log：
```
09-03 17:15:15.732 12778-12778/com.example.test D/TestView: onVisibilityChanged: 8 false null
09-03 17:15:15.736 12778-12778/com.example.test D/TestView: onVisibilityChanged: 4 false 1
09-03 17:15:15.751 12778-12778/com.example.test D/TestView: onVisibilityChanged: 0 false 1
```
`visibility`对应的值含义是`0-VISIBLE`、`4-INVISIBLE`、`8-GONE`，日志最后一次收到的值是0，与XML里设置的`android:visibility="gone"`属性含义不一致。日志里第一次`onVisibilityChanged`由父构造函数-`View`的构造函数调用。类的初始化顺序为：`父类成员变量-父类构造函数-子类成员变量-子类构造函数`，`View`构造函数调用`onVisibilityChanged`时`TestView`的成员变量还未初始化，此时成员变量为Null。
Android 6.0版本开始在构造函数里调用`onVisibilityChanged`时添加了`View`是否已经附着在`Window`的条件判断，修复了`visibility`不一致的问题。
```java
void setFlags(int flags, int mask) {
    ...
    if (mAttachInfo != null) {
        dispatchVisibilityChanged(this, newVisibility);
        ...
    }
    ...
}
```
Android 6.0及以上打印Log：
```
2020-09-03 17:17:53.014 29651-29651/com.example.test D/TestView: onVisibilityChanged: 8 false 1
```
XML布局去掉`android:visibility="gone"`时布局：
```xml
<com.example.test.TestView
    android:layout_width="100dp"
    android:layout_height="100dp"
    android:background="#ff0000" />
```
Android 6.0以下打印Log：
```
09-03 17:22:37.122 13002-13002/com.example.test D/TestView: onVisibilityChanged: 4 false 1
09-03 17:22:37.140 13002-13002/com.example.test D/TestView: onVisibilityChanged: 0 true 1
```
Android 6.0及以上打印Log：
```
2020-09-03 17:22:03.977 30186-30186/com.example.test D/TestView: onVisibilityChanged: 0 true 1
```
## 解决方案
`onVisibilityChanged`里用到成员变量需判空，判断View的可见性时不使用方法里传的`visibility`值，而是使用`View#isShown()`代替。
代码示例：
```java
public class TestView extends View {

    private Integer aInt = new Integer(1);
  
    public TestView(Context context) {
        super(context);
    }

    public TestView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public TestView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void onVisibilityChanged(@NonNull View changedView, int visibility) {
        if (isShown()) {
            ... //可见时不需添加空判断
        } else {
            if (aInt != null) {
                ...
            }
        }
    }
}
```
