title: Android换肤理论分析
date: 2015-12-22 20:53:33
tags: android
---

# 换肤理论基础：View的创建过程。

## 从xml到View：
Activity：
```java
public void setContentView(int layoutResID) {
    ...
    mLayoutInflater.inflate(layoutResID, mContentParent);
    ...
}
```

<!-- more -->

LayoutInflater:
```java
public View inflate(@LayoutRes int resource, @Nullable ViewGroup root, boolean attachToRoot) {
    final Resources res = getContext().getResources();
    ...
    final XmlResourceParser parser = res.getLayout(resource);
    try {
        return inflate(parser, root, attachToRoot);
    } finally {
        parser.close();
    }
    ...
}

public View inflate(XmlPullParser parser, @Nullable ViewGroup root, boolean attachToRoot) {
    ...
    final View temp = createViewFromTag(root, name, inflaterContext, attrs); // 创建用户xml根布局View
    ...
    rInflateChildren(parser, temp, attrs, true); // 创建用户xml根布局的children
    ...
}

// rInflateChildren调用到
void rInflate(XmlPullParser parser, View parent, Context context,
            AttributeSet attrs, boolean finishInflate) throws XmlPullParserException, IOException {
    ...
    final View view = createViewFromTag(parent, name, context, attrs);
    final ViewGroup viewGroup = (ViewGroup) parent;
    final ViewGroup.LayoutParams params = viewGroup.generateLayoutParams(attrs);
    rInflateChildren(parser, view, attrs, true);
    viewGroup.addView(view, params);
    ...
}
```
都指向了LayoutInflater.createViewFromTag()
```java
View createViewFromTag(View parent, String name, Context context, AttributeSet attrs,
            boolean ignoreThemeAttr) {
    ...
    View view;
    if (mFactory2 != null) {
        view = mFactory2.onCreateView(parent, name, context, attrs);
    } else if (mFactory != null) {
        view = mFactory.onCreateView(name, context, attrs);
    } else {
        view = null;
    }

    if (view == null && mPrivateFactory != null) {
        view = mPrivateFactory.onCreateView(parent, name, context, attrs);
    }

    if (view == null) {
        final Object lastContext = mConstructorArgs[0];
        mConstructorArgs[0] = context;
        try {
            if (-1 == name.indexOf('.')) { // 系统View，需要补全前缀，之后调用如同下面的createView()
                view = onCreateView(parent, name, attrs);
            } else {
                view = createView(name, null, attrs);
            }
        } finally {
            mConstructorArgs[0] = lastContext;
        }
    }

    return view;
    ...
}
```

#### xml布局文件中简写的系统View需要补全前缀
    布局的LayoutInflater类型实际为PhoneLayoutInflater。
    系统View自动添加前缀列表，PhoneLayoutInflater.onCreateView()
        android.widget.
        android.webkit.
        android.app.
    添加前缀使用反射尝试找到构造函数来构造View对象，失败了就换个前缀再次尝试下一个前缀。遍历完还是失败，调用super LayoutInflater的方法，添加前缀"android.view."。
    如：LinearLayout补全为android.widget.LinearLayout。

```java
private Factory mFactory;
private Factory2 mFactory2;
private Factory2 mPrivateFactory;
```

#### LayoutInflater构造View可能的选择：
    - mFactory2.onCreateView()
    - mFactory.onCreateView()
    - mPrivateFactory.onCreateView()，由于Activtiy implements LayoutInflater.Factory2，会调用到Activity的onCreateView() 
    - LayoutInflater.createView(String name, String prefix, AttributeSet attrs)

## 实例化View：LayoutInflater.createView()
```java
public final View createView(String name, String prefix, AttributeSet attrs)
            throws ClassNotFoundException, InflateException {
    Constructor<? extends View> constructor = sConstructorMap.get(name);
    Class<? extends View> clazz = null;
    ...
    if (constructor == null) {
        // Class not found in the cache, see if it's real, and try to add it
        clazz = mContext.getClassLoader().loadClass(
                prefix != null ? (prefix + name) : name).asSubclass(View.class);
        
        if (mFilter != null && clazz != null) {
            boolean allowed = mFilter.onLoadClass(clazz);
            if (!allowed) {
                failNotAllowed(name, prefix, attrs);
            }
        }
        constructor = clazz.getConstructor(mConstructorSignature);
        constructor.setAccessible(true);
        sConstructorMap.put(name, constructor); // sConstructorMap缓存使用过的构造函数，减少调用ClassLoader的次数
    } else {
        ...
    }

    Object[] args = mConstructorArgs;
    args[1] = attrs;
    final View view = constructor.newInstance(args);
    ...
    return view;
    ...
}
```
View的对象实例化通过反射调用其构造函数：View(Context context, @Nullable AttributeSet attrs)。
自此，View的Java对象才创建出来。

如果到这里还没有修改记录View的属性，生米已成熟饭，晚矣!

#### DecorView的初始化 PhoneWindow.mDecorView
PhoneWindow
```java
private void installDecor() {
    if (mDecor == null) {
        mDecor = generateDecor(); // 初始化DecorView
        ...
    }
    if (mContentParent == null) {
        mContentParent = generateLayout(mDecor); // 激动，开始布局xml了么？
        ...
    }
    ...
}

protected ViewGroup generateLayout(DecorView decor) {
    ...
    layoutResource = R.layout.screen_simple; // 一个模板布局
    ...
    View in = mLayoutInflater.inflate(layoutResource, null);
    decor.addView(in, new ViewGroup.LayoutParams(MATCH_PARENT, MATCH_PARENT));
    mContentRoot = (ViewGroup) in;

    ViewGroup contentParent = (ViewGroup)findViewById(ID_ANDROID_CONTENT);
    ...
}
```

#### R.layout.screen_simple
```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
/* //device/apps/common/assets/res/layout/screen_simple.xml
**
** Copyright 2006, The Android Open Source Project
**
** Licensed under the Apache License, Version 2.0 (the "License"); 
** you may not use this file except in compliance with the License. 
** You may obtain a copy of the License at 
**
**     http://www.apache.org/licenses/LICENSE-2.0 
**
** Unless required by applicable law or agreed to in writing, software 
** distributed under the License is distributed on an "AS IS" BASIS, 
** WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
** See the License for the specific language governing permissions and 
** limitations under the License.
*/

This is an optimized layout for a screen, with the minimum set of features
enabled.
-->

<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:fitsSystemWindows="true"
    android:orientation="vertical">
    <ViewStub android:id="@+id/action_mode_bar_stub"
              android:inflatedId="@+id/action_mode_bar"
              android:layout="@layout/action_mode_bar"
              android:layout_width="match_parent"
              android:layout_height="wrap_content"
              android:theme="?attr/actionBarTheme" />
    <FrameLayout
         android:id="@android:id/content"
         android:layout_width="match_parent"
         android:layout_height="match_parent"
         android:foregroundInsidePadding="false"
         android:foregroundGravity="fill_horizontal|top"
         android:foreground="?android:attr/windowContentOverlay" />
</LinearLayout>
```
这里解释了Activity.onCreateView打印出来的前三个View

## R.layout.activity_main
```xml
<?xml version="1.0" encoding="utf-8"?>
<RelativeLayout
    xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent">

    <TextView
        android:id="@+id/change_text_color"
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello World!"/>
</RelativeLayout>
```

#### Activity.onCreateView(View parent, String name, Context context, AttributeSet attrs)打印出来的各个字段值：

| parent | name | context | attrs |
| ---- | ---- | ---- | ----|
| null | LinearLayout | skin.theory.MainActivity@e3ae6f5 | android.content.res.XmlBlock$Parser@7f12c8a |
| android.widget.LinearLayout{9fe32fb V.E...... ......I. 0,0-0,0} | ViewStub | android.view.ContextThemeWrapper@de65f18 | android.content.res.XmlBlock$Parser@7f12c8a |
| android.widget.LinearLayout{9fe32fb V.E...... ......I. 0,0-0,0} | FrameLayout | skin.theory.MainActivity@e3ae6f5 | android.content.res.XmlBlock$Parser@7f12c8a |
| android.widget.FrameLayout{66e54c4 V.E...... ......I. 0,0-0,0 #1020002 android:id/content} | RelativeLayout | skin.theory.MainActivity@e3ae6f5 | android.content.res.XmlBlock$Parser@e65ffad |
| android.widget.RelativeLayout{222c2e2 V.E...... ......I. 0,0-0,0} | TextView | skin.theory.MainActivity@e3ae6f5 | android.content.res.XmlBlock$Parser@e65ffad |

View层级关系:
- LinearLayout (PhoneWindow.mContentParent)
    - ViewStub
    - FrameLayout <font color="red">(android:id/content)</font>
        - RelativeLayout
            - TextView
