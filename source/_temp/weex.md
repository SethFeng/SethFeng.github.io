# WEEX

- 对于前端开发入手比较容易，开发技术是我们前端开发已经在用的VUE.js，开发前需要熟悉WEEX官方提供的标签和支持的CSS属性
- 支持加载本地WEEX页面资源，初始版本可打包在发布包中
- 支持修复/热更新
- 支持开机静默更新
- 本地页面打开速度快，基本与原生页面一样无延迟感知，从网络实时下载页面显示有延迟感知
- 集成SDK后Android和iOS发布包大小增加约7M
- 主线WEEX已发布0.26.0版本，基金WEEX基于0.20.1分支版本修改，未遇到重大bug不与主线同步WEEX版本
- 基金WEEX扩展了官方提供的组件，遇到不支持的组件


## Question
- 原理


## hello weex
- 获取源码
```bash
git clone https://github.com/apache/incubator-weex
git submodule update
```
- 安装Web开发工具
```bash
brew install npm
brew install yarn
```
- 安装Weex开发工具
```bash
npm install weex-toolkit -g
```
- 新建`hello_weex`项目
```bash
weex create hello_weex
```
- 在Web端运行
```bash
npm start
```
- 在Android端运行
```bash
weex platform add android
weex run android
```
- 在iOS端运行
```bash
weex platform add ios
weex run ios
```
- 调试
```bash
weex debug
```


## Android Render
WXPageActivity#refresh
renderContainer = new RenderContainer(this);
mInstance = new WXSDKInstance(this);

mInstance.setWXAbstractRenderContainer(renderContainer);
mInstance.registerRenderListener(this);
mInstance.setNestedInstanceInterceptor(this);
mInstance.setBundleUrl(url);
mInstance.setTrackComponent(true);
mContainer.addView(renderContainer);

httpTask = new WXHttpTask()
httpTask.url = url;
httpTask.requestListener
WXHttpManager.getInstance().sendRequest(httpTask);

mInstance.render(TAG, new String(task.response.data, "utf-8"), mConfigMap, null, WXRenderStrategy.APPEND_ASYNC);

WXSDKManager.getInstance().createInstance(this, template, renderOptions, jsonInitData);

WXModuleManager.createDomModule(instance);



































