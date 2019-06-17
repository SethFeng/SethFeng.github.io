# iOS学习笔记

## HTTP
### NSURLSession
NSURL
NSURLSession
NSURLSessionDataTask
[task resume]

- get
```objective-c
NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
NSInteger code = [httpResp statusCode];
NSDictionary *headers = [httpResp allHeaderFields];
if (code == 200) {
    // parse response data
} else {
	NSLog(@"error: %@", error);
}
```

- post
```objective-c
NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
request.HTTPMethod = @"POST";
```

- response parse
```objective-c
NSString *respStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
NSDictionary *respJson = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
UIImage *image = [UIImage imageWithData:data];
```

## 界面跳转
新起界面
覆盖界面
Storyboard
nib(xib)
Pure code

- storyboard
```objective-c
UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"IDENTIFIER"];
[self.navigationController pushViewController:vc animated:YES];
```

- xib
```objective-c
UIViewController *vc = [[UIViewController alloc] initWithNibName:@"NIBNAME" bundle:nil];
[self.navigationController pushViewController:vc animated:YES];
```

- pure code
```objective-c
UIViewController *vc = [[UIViewController alloc] init];
[self.navigationController pushViewController:vc animated:YES];
```


# 基础控件
## 文本框：text size / text color / background color / press state
## 输入框
## 图片: scale type
## Picker
## 列表
## 多界面
## ViewController
- UITableViewController
- UICollectionViewController
- UIViewController

segue: 定义ViewController切换

- UITabBarController
- UINavigationController
- UISplitViewController

- UICollectionViewController

# 网络
## Socket
## HTTP

# 存储
## KV缓存
## 数据库

# 传感器
## 摄像头
## 麦克风
## 重力感应



# ios
## usr/include
## Frameworks
### Foundataion
Objective-C framework
### UIKit
### WebKit
### CoreImage