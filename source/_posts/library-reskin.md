---
title: Android换肤
author: 冯神柱
---
## 需求：支持夜间模式

## 资源形式：APK内部

## 期待方案特点：代码修改小、皮肤资源与主程序资源辨识度高、效率高、可扩展（自定义View及自定义属性）

## 技术途径
    - 手动设置View属性
        每个View的每个属性都至少要一行代码，且与具体Activity联系紧密。代码冗长，修改麻烦。
    - Activity Theme
        需要重启Activity
    - 资源重定向
        在基类Activity里可实现换肤，无需侵入现有业务Activity及其布局文件和资源文件

<!-- more -->

## 资源重定向
### 原理：见theory
## 找到下手的时机：
    根据theory分析，LayoutInflater构造View对象有4种的选择：
        1. mFactory2.onCreateView()
        2. mFactory.onCreateView()
        3. mPrivateFactory.onCreateView()，会调用到Activity的onCreateView() 
        4. LayoutInflater.createView(String name, String prefix, AttributeSet attrs)
    法1和法2可轻松通过Activity.getLayoutInflater().setFactory()设置，在反射调用View的构造函数前修改其属性。
    法3的mPrivateFactory可以通过Activity的onCreateView()自行初始化View。
    到了法4这步，已经无能为力了...
从这里看，1、2、3没有区别，demo暂时选取法2，截断系统默认createView()的过程。
如何自己实例化出View?仿制！
```java
public class SkinLayoutInflaterFactory implements LayoutInflater.Factory {
    @Override
    public View onCreateView(String name, Context context, AttributeSet attrs) {
        // 实例化View。自行预处理前缀，调用LayoutInflater.createView()实例化
        for (String prefix : sClassPrefixList) {
            try {
                View view = mLayoutInflater.createView(name, prefix, attrs);
                if (view != null) {
                    // 记录需要改变属性的View及其属性
                    addSkinViewIfNecessary(view, attrs);
                    return view;
                }
            } catch (ClassNotFoundException e) {
                // In this case we want to let the base class take a crack
                // at it.
            }
        }

        return mLayoutInflater.createView(name, null, attrs);
    }
}

List<SkinItem> textViewTextColorList = new ArrayList<>();

private void addSkinViewIfNecessary(View view, AttributeSet attrs) {
    if (view instanceof TextView) {
        int n = attrs.getAttributeCount();
        for (int i = 0; i < n; i++) {
            String attrName = attrs.getAttributeName(i);         
            if (attrName.equals("textColor")) {
                int id = 0;
                String attrValue = attrs.getAttributeValue(i);
                if (attrValue.startsWith("@")) { // 如"@2131427389"
                    id = Integer.parseInt(attrValue.substring(1));
                    textViewTextColorList.add(new SkinItem(view, id));
                }
            }
        }
    }
}
```

### 千呼万唤始出来！
遍历记录感兴趣的View及其属性的数据结构，通过重定向资源更新属性值。以替换TextView的textColor为例。
布局：
```xml
<TextView
    android:id="@+id/change_text_color"
    android:textColor="@color/textColor"
    android:layout_width="wrap_content"
    android:layout_height="wrap_content"
    android:text="Hello World!"/>
```
更换主题：
```java
textView.setTextColor(getColor(resId));

// 用老的资源id获取新主题资源，需要一次华丽的转身：id -> name -> new name -> new id
private int getColor(int oldResId, String suffix) {
    String oldResName = mContext.getResources().getResourceEntryName(oldResId);
    String newResName = oldResName + suffix;
    int newResId = mContext.getResources().getIdentifier(newResName, "color", mContext
            .getPackageName());
    return mContext.getResources().getColor(newResId);
}
```
过程说明：
生成的R.java中textColor resource id：
```java
public static final class color {
    ...
    public static final int textColor=0x7f0b003d;
    public static final int textColor_night=0x7f0b003e; 
}
```
oldResId = 2131427389，转16进制为0x7f0b003d，即R.color.textColor 
oldResName = textColor
newResName = textColor_night
newResId 2131427390，转16进制为0x7f0b003e，即R.color.textColor_night 
使用新resource id通过Resource获取新色值，设置到view里，完成这个TextView的textColor属性更改。

### 关注的资源类型：
    - color
    - drawable

## 关注的View属性：
    - TextView textColor(color)
    - View background(color/drawable)
    - ListView divider(color/drawable)
    - AbsListView listSelector(color/drawable)
    - ImageView src(src)

    - View background(drawable)
    - TextView textColor textColorHint drawableLeft
    - ListView divider(drawable)
    - AbsListView listSelector(color/drawable)
    - ExpandableListView childDivider
    - ImageView src
    - 自定义View
    - ...

## 关于资源位置
    资源位置的问题影响的仅仅是资源重定向的问题。
    内置资源重定向：
    外置打包资源重定向：

#### TODO
    - LayoutInflater.Factory解读：
        - Factory/Factory2/FactoryMerger， Factory和Factory2只能设置一个且一次
        - 成员变量mFactory/mFactory2/mPrivateFactory
    - 评估构造View时mConstructorArgs未像系统一样处理时的影响
    - include/merge/viewstub/手动infalte创建View/手动new创建View/手动动态addView和removeView/Fragment对Factory.onCreateView()的影响

## 项目分析
### 1. hongyangAndroid/ChangeSkin
    - 支持内部主题资源(后缀名)和外部主题资源(apk)
    - Applicataion.onCreate()初始化
    - MainActivity extends BaseSkinActivity
    - BaseSkinActivity extends AppCompatActivity
    - BaseSkinActivity.onCreateView()通过AppCompatActivity.getDelegate()反射获取createView
    - 主题属性值以skin开头
### 2. hongyangAndroid/AndroidChangeSkin
    - 支持内部主题资源(后缀名)和外部主题资源(apk)
    - MainActivity extends AppCompatActivity
    - MainActivity.onCreate()/onDestroy()注册和反注册
    - 主题View添加tag指明需要更换的属性
    - 添加ImageView src支持
    - 需要手动遍历View，效率不好
### 3. fengjundev/Android-Skin-Loader
    - 反射new一个AssetManager，反射调用其addAssetPath()，创建一个新的Resources给SkinManager.mResources
    - 主题View加属性skin:enable="true"
    - 动态添加View DynamicAttr

## 参考
- http://blog.zhaiyifan.cn/2015/09/10/Android换肤技术总结/
- http://blog.zhaiyifan.cn/2015/11/20/新的换肤思路/
- https://github.com/brokge/NightModel 每个需要改变主题的View都手动设置一遍
- http://blog.bradcampbell.nz/layoutinflater-factories/ LayoutInflater.Factory讲解
- https://github.com/chrisjenx/Calligraphy 更换文字字体，LayoutInflater.setFactory()
- https://github.com/hongyangAndroid/ChangeSkin 
