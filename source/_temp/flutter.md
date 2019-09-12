Flutter学习笔记
===

# 支持的设备

## Android
  - Jelly Bean, v16, 4.1.x或更新
  - ARM

## iOS
  - iOS 8或更新
  - iPhone 4S或更新

# Hello Flutter

安装Flutter后可在命令行执行以下命令创建一个项目：
```shell
flutter create hello_flutter
cd hello_flutter
flutter run
```
`flutter create`同时创建Android和iOS项目，项目文件目录结构如下：
```
.
├── README.md
├── android
│   ├── app
│   │   ├── build.gradle
│   │   └── src
│   │       ├── debug
│   │       │   └── AndroidManifest.xml
│   │       ├── main
│   │       │   ├── AndroidManifest.xml
│   │       │   ├── java
│   │       │   │   ├── com
│   │       │   │   │   └── example
│   │       │   │   │       └── hello_flutter
│   │       │   │   │           └── MainActivity.java
│   │       │   │   └── io
│   │       │   │       └── flutter
│   │       │   │           └── plugins
│   │       │   │               └── GeneratedPluginRegistrant.java
│   │       │   └── res
│   │       │       ├── drawable
│   │       │       │   └── launch_background.xml
│   │       │       ├── mipmap-hdpi
│   │       │       │   └── ic_launcher.png
│   │       │       ├── mipmap-mdpi
│   │       │       │   └── ic_launcher.png
│   │       │       ├── mipmap-xhdpi
│   │       │       │   └── ic_launcher.png
│   │       │       ├── mipmap-xxhdpi
│   │       │       │   └── ic_launcher.png
│   │       │       ├── mipmap-xxxhdpi
│   │       │       │   └── ic_launcher.png
│   │       │       └── values
│   │       │           └── styles.xml
│   │       └── profile
│   │           └── AndroidManifest.xml
│   ├── build.gradle
│   ├── gradle
│   │   └── wrapper
│   │       ├── gradle-wrapper.jar
│   │       └── gradle-wrapper.properties
│   ├── gradle.properties
│   ├── gradlew
│   ├── gradlew.bat
│   ├── hello_flutter_android.iml
│   ├── local.properties
│   └── settings.gradle
├── hello_flutter.iml
├── ios
│   ├── Flutter
│   │   ├── AppFrameworkInfo.plist
│   │   ├── Debug.xcconfig
│   │   ├── Generated.xcconfig
│   │   └── Release.xcconfig
│   ├── Runner
│   │   ├── AppDelegate.h
│   │   ├── AppDelegate.m
│   │   ├── Assets.xcassets
│   │   │   ├── AppIcon.appiconset
│   │   │   │   ├── Contents.json
│   │   │   │   ├── Icon-App-1024x1024@1x.png
│   │   │   │   ├── Icon-App-20x20@1x.png
│   │   │   │   ├── Icon-App-20x20@2x.png
│   │   │   │   ├── Icon-App-20x20@3x.png
│   │   │   │   ├── Icon-App-29x29@1x.png
│   │   │   │   ├── Icon-App-29x29@2x.png
│   │   │   │   ├── Icon-App-29x29@3x.png
│   │   │   │   ├── Icon-App-40x40@1x.png
│   │   │   │   ├── Icon-App-40x40@2x.png
│   │   │   │   ├── Icon-App-40x40@3x.png
│   │   │   │   ├── Icon-App-60x60@2x.png
│   │   │   │   ├── Icon-App-60x60@3x.png
│   │   │   │   ├── Icon-App-76x76@1x.png
│   │   │   │   ├── Icon-App-76x76@2x.png
│   │   │   │   └── Icon-App-83.5x83.5@2x.png
│   │   │   └── LaunchImage.imageset
│   │   │       ├── Contents.json
│   │   │       ├── LaunchImage.png
│   │   │       ├── LaunchImage@2x.png
│   │   │       ├── LaunchImage@3x.png
│   │   │       └── README.md
│   │   ├── Base.lproj
│   │   │   ├── LaunchScreen.storyboard
│   │   │   └── Main.storyboard
│   │   ├── GeneratedPluginRegistrant.h
│   │   ├── GeneratedPluginRegistrant.m
│   │   ├── Info.plist
│   │   └── main.m
│   ├── Runner.xcodeproj
│   │   ├── project.pbxproj
│   │   ├── project.xcworkspace
│   │   │   └── contents.xcworkspacedata
│   │   └── xcshareddata
│   │       └── xcschemes
│   │           └── Runner.xcscheme
│   └── Runner.xcworkspace
│       └── contents.xcworkspacedata
├── lib
│   └── main.dart
├── pubspec.lock
├── pubspec.yaml
└── test
    └── widget_test.dart
```
需重点关注的有：
- pubspec.yaml
  Flutter项目配置文件，包括Flutter版本、依赖库等。
- lib/main.dart
  Flutter APP入口代码文件。
```dart
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

```
- android
  Flutter生成的Android项目根目录，可用Android Studio打开独立开发Android。Android Application继承`FlutterApplication`，Activity继承`FlutterActivity`/`FlutterFragmentActivity`。`Activity`承担了Flutter的`PluginRegistry`插件注册功能，只有注册过的插件才能使用。
```java
// Android插件注册
protected void onCreate(Bundle savedInstanceState) {
  super.onCreate(savedInstanceState);
  GeneratedPluginRegistrant.registerWith(this);
}
```
`GeneratedPluginRegistrant`由Flutter生成，yaml里配置的Flutter插件会在此声明。
- ios
  Flutter生成的iOS项目根目录，可用XCode打开ios/Runner.xcworkspace独立开发iOS。iOS在`AppDelegate`里注册Flutter插件，插件注册类`GeneratedPluginRegistrant`也由Flutter生成。
```objc
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}
```

# Dart

# Flutter

FlutterNativeView vs FlutterView

# Flutter与原生交互

Flutter与Java代码调用bridge太复杂了
MethodChannel一定要传入View作为参数？？？
同一个channel name添加多个MethodChannel，只有最后创建的MethodChannel收到回调

Flutter Dart与Java/Objc交互通过`MethodChannel`实现。创建MethodChannel时传入字符串作为channel的id，通过`setMethodCallHandler`向channel注册被调用的接口，通过`invokeMethod`调用桥接端的对方向channel注册的接口。

## Dart调用Java/Objc

```dart
const methodChannel = const MethodChannel('dni');
try {
  final String result = await methodChannel.invokeMethod('getPlatformString');
} on PlatformException catch (e) {
}
```

```java
MethodChannel methodChannel = new MethodChannel(getFlutterView(), "dni");
methodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        if (methodCall.method.equals("getPlatformString")) {
            result.success("Android");
        } else {
            result.notImplemented();
        }
    }
});
```

```objc
FlutterViewController *controller = (FlutterViewController *)self.window.rootViewController;
FlutterMethodChannel *methodChannel = [FlutterMethodChannel methodChannelWithName:@"dni" binaryMessenger:controller];
[methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
    if ([call.method isEqualToString:@"getPlatformString"]) {
        result(@"iOS");
    } else {
        result(FlutterMethodNotImplemented);
    }
}];
```

## Java/Objc调用Dart

```dart
Future<dynamic> methodChannelHandler(MethodCall methodCall) async {
  if (methodCall.method == "getFlutterString") {
    String stringParam = methodCall.arguments;
    return "Flutter $stringParam";
  }
}
methodChannel.setMethodCallHandler(methodChannelHandler);
```

```java
methodChannel.invokeMethod("getFlutterString", "Android", new MethodChannel.Result() {
    @Override
    public void success(Object o) {
        String result = (String)o;
    }

    @Override
    public void error(String s, String s1, Object o) {
    }

    @Override
    public void notImplemented() {
    }
});
```

```objc
[methodChannel invokeMethod:@"getFlutterString" arguments:@"iOS" result:^(id  _Nullable result) {
    NSString *string = (NSString *)result;
}];
```