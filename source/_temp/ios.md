iOS学习笔记
===

# Objective-C

## Foundation

## Runtime
```objc
#import <objc/runtime.h>
```

## type encoding: https://nshipster.com/type-encodings/
- ObjectType
- class_copyPropertyList
- property_getName
- property_getAttributes
- objc_class Class
- [[class alloc] init]

## block

## value change observe
```objc
static NSString *const observedKeyPath = @"contentSize";

[self.webView.scrollView addObserver:self forKeyPath:observedKeyPath options:NSKeyValueObservingOptionNew context:nil];

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:observedKeyPath]) {
        NSLog(@"%@", change);
    }
}

```

# Swift

# XCode

# UIKit

## widget

### List
### Picker
- date picker
- else

### Button
### Text
- label
- input

### Image
### Video
### Tab
- fixed
- scrollable
- bottom
- top

### page(indicator)

### progress
- line
- circle
- Determinate
- indeterminate

### slider
### search bar
### alert / dialog
### selection
- single
- multi
- switch

### navigation drawer
### scrollview

### 文本框
- text size / text color / background color / press state

### 输入框

### 图片

- scale type
- UIImageView imageNamed, PNG格式只需文件名称，可省略扩展名，其它图片格式要扩展名

### Picker

### 列表

### 多界面

### ViewController

- UITableViewController
- UICollectionViewController
- UIViewController

## 界面跳转
- UINavigationViewController: pushViewController，适用于需要返回键的页面跳转，有ViewController栈
- UIViewController: presentViewController，适用于不需返回键的的模态弹框，无ViewController栈
- addSubView，直接添加View，低层次的View操作

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

segue: 定义ViewController切换

- UITabBarController
- UINavigationController
- UISplitViewController

- UICollectionViewController

# 网络通信

## Socket

## HTTP

## NSURLSession

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

# 本地存储

## KV缓存

## 数据库

# 传感器

## 摄像头

## 麦克风

## 重力感应

# ios

## memory leak

## WKWebView
set webView frame height 设成 contentHeight - 1 不会触发content height变化，否则触发content height = frame height + 1

# 工具类
```Objective-C

+ (void)constrainScrollViewContainerView:(UIScrollView *)scrollView containerView:(UIView *)containerView {
//    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:containerView
//                                                             attribute:NSLayoutAttributeWidth
//                                                             relatedBy:NSLayoutRelationEqual
//                                                                toItem:nil
//                                                             attribute:NSLayoutAttributeWidth
//                                                            multiplier:1
//                                                              constant:500];
//    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:containerView
//                                                              attribute:NSLayoutAttributeHeight
//                                                              relatedBy:NSLayoutRelationEqual
//                                                                 toItem:nil
//                                                              attribute:NSLayoutAttributeHeight
//                                                             multiplier:1
//                                                               constant:500];
//    [containerView addConstraints:@[width, height]];
    [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:containerView
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:scrollView
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1
                                                                constant:0];
    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:containerView
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:scrollView
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1
                                                                 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:containerView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:scrollView
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1
                                                            constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:containerView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:scrollView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0];
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:containerView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:scrollView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1
                                                                constant:0];
    [scrollView addConstraints:@[leading, trailing, top, bottom,  centerX]];
}

+ (void)constrainScrollViewContainerViewBottom:(UIView *)targetView topView:(UIView *)topView containerView:(UIView *)containerView {
    [targetView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:targetView
//                                                             attribute:NSLayoutAttributeWidth
//                                                             relatedBy:NSLayoutRelationEqual
//                                                                toItem:nil
//                                                             attribute:NSLayoutAttributeWidth
//                                                            multiplier:1
//                                                              constant:500];
//    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:targetView
//                                                              attribute:NSLayoutAttributeHeight
//                                                              relatedBy:NSLayoutRelationEqual
//                                                                 toItem:nil
//                                                              attribute:NSLayoutAttributeHeight
//                                                             multiplier:1
//                                                               constant:500];
//    [targetView addConstraints:@[width, height]];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:targetView
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:targetView.superview
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1
                                                                constant:0];
//    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:targetView
//                                                                attribute:NSLayoutAttributeTrailing
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:targetView.superview
//                                                                attribute:NSLayoutAttributeTrailing
//                                                               multiplier:1
//                                                                 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:targetView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:topView
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1
                                                            constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:containerView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:targetView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1
                                                               constant:0];
    [targetView.superview addConstraints:@[top, bottom, leading]];
}

+ (void)constrainVerticalView:(UIView *)targetView topView:(UIView *)topView bottomView:(UIView *)bottomView {
    [targetView setTranslatesAutoresizingMaskIntoConstraints:NO];
//    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:targetView
//                                                             attribute:NSLayoutAttributeWidth
//                                                             relatedBy:NSLayoutRelationEqual
//                                                                toItem:nil
//                                                             attribute:NSLayoutAttributeWidth
//                                                            multiplier:1
//                                                              constant:500];
//    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:targetView
//                                                              attribute:NSLayoutAttributeHeight
//                                                              relatedBy:NSLayoutRelationEqual
//                                                                 toItem:nil
//                                                              attribute:NSLayoutAttributeHeight
//                                                             multiplier:1
//                                                               constant:500];
//    [targetView addConstraints:@[width, height]];
    NSLayoutConstraint *leading = [NSLayoutConstraint constraintWithItem:targetView
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:targetView.superview
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1
                                                                constant:0];
//    NSLayoutConstraint *trailing = [NSLayoutConstraint constraintWithItem:targetView
//                                                                attribute:NSLayoutAttributeTrailing
//                                                                relatedBy:NSLayoutRelationEqual
//                                                                   toItem:targetView.superview
//                                                                attribute:NSLayoutAttributeTrailing
//                                                               multiplier:1
//                                                                 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:targetView
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:topView
                                                           attribute:NSLayoutAttributeBottom
                                                          multiplier:1
                                                            constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:targetView
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:bottomView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:0];
    [targetView.superview addConstraints:@[top, bottom, leading]];
    
}



@implementation EMInScrollTableView

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    [self invalidateIntrinsicContentSize];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(UIViewNoIntrinsicMetric, self.contentSize.height);
}

@end
```

## Timer task
```Objective-C
- (void) startTimer {
   [NSTimer scheduledTimerWithTimeInterval:1 
                                    target:self 
                                  selector:@selector(tick:) 
                                  userInfo:nil
                                   repeats:YES];
}

- (void) tick:(NSTimer *) timer {
   //do something here..

}
```

## delayed task
```Objective-C
double delayInSeconds = 2.0;
dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //code to be executed on the main queue after delay
    [self doSometingWithObject:obj1 andAnotherObject:obj2];
});
```

## lldb debug
- p
- po
- expression @import UIKit


## date format
```Objective-C
NSString *dateStr = @"20100223";

// Convert string to date object
NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
[dateFormat setDateFormat:@"yyyyMMdd"];
NSDate *date = [dateFormat dateFromString:dateStr];  

// Convert date object to desired output format
[dateFormat setDateFormat:@"EEEE MMMM d, YYYY"];
dateStr = [dateFormat stringFromDate:date];  
[dateFormat release];
```

## status bar 
```
- (CGFloat)statusBarHeigh {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    return MIN(statusBarSize.width, statusBarSize.height);
}
```

## NavigationBar
```Objective-C
[self.navigationController.navigationBar setBarTintColor:[UIColor greenColor]];
[self.navigationController.navigationBar setTranslucent:NO];
```
```objc
UINavigationItem *navigationItem = [[UINavigationItem alloc] init];
UIImage *image = [UIImage imageNamed:@"common_back"];
image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(navigationBack)];
navigationItem.leftBarButtonItem = backButton;
[self.navigationBar setItems:@[navigationItem]];
self.navigationBar.barTintColor = RGB_HEX(0xf7f8fa);
self.navigationBar.translucent = NO;
```
```objc
// 获取系统NavigationBar默认高度
CGFloat navigationBarHeight = [[UINavigationController alloc] init].navigationBar.frame.size.height;
```

## image scale
```objc
CGFloat scaledToSize = 1024.0;
UIGraphicsBeginImageContext(CGSizeMake(scaledToSize, scaledToSize));
[image drawInRect:CGRectMake(0, 0, scaledToSize, scaledToSize)];
UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
UIGraphicsEndImageContext();
NSData *avataImageData = UIImageJPEGRepresentation(scaledImage, 0.7);
```

## 相机、相册选照片
```objc
- (void)pressAvatar:(UITapGestureRecognizer *)recognizer {
    UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"选择照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getImageFromCamera];
    }];
    UIAlertAction* albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getImageFromAlbum];
    }];
    [alertVC addAction:cameraAction];
    [alertVC addAction:albumAction];
    alertVC.popoverPresentationController.sourceView = _avatarImageView;
    alertVC.popoverPresentationController.sourceRect = _avatarImageView.bounds;
    [self presentViewController:alertVC animated:NO completion:nil];
}

- (void)getImageFromCamera {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                [self takePhoto];
            } else {
                [ALAlert alertContent:@"请在系统设置打开相机权限"];
            }
        }];
    } else if (status == AVAuthorizationStatusAuthorized) {
        [self takePhoto];
    } else {
        [ALAlert alertContent:@"请在系统设置打开相机权限"];
    }
}

- (void)takePhoto {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (_imagePickerController == nil) {
            _imagePickerController = [[UIImagePickerController alloc] init];
            _imagePickerController.delegate = self;
        }
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:self.imagePickerController animated:NO completion:nil];
    } else {
        [ALAlert alertContent:@"系统相机访问失败"];
    }
}

- (void)getImageFromAlbum {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (status == PHAuthorizationStatusAuthorized) {
                    [self selectAlbum];
                } else {
                    [ALAlert alertContent:@"请在系统设置打开相册权限"];
                }
            });
        }];
    } else if (status == PHAuthorizationStatusAuthorized) {
        [self selectAlbum];
    } else {
        [ALAlert alertContent:@"请在系统设置打开相册权限"];
    }
}

- (void)selectAlbum {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        if (_imagePickerController == nil) {
            _imagePickerController = [[UIImagePickerController alloc] init];
            _imagePickerController.delegate = self;
        }
        self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:self.imagePickerController animated:NO completion:nil];
    } else {
        [ALAlert alertContent:@"系统相册访问失败"];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:NO completion:nil];
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    [self uploadAvatar:image];
    _avatarImageView.image = image;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:nil];
}
```


## ipad action sheet不像iPhone，不能从底部全宽度显示，需要anchor
```objc
UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"选择照片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
UIAlertAction* cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self getImageFromCamera];
}];
UIAlertAction* albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    [self getImageFromAlbum];
}];
[alertVC addAction:cameraAction];
[alertVC addAction:albumAction];
alertVC.popoverPresentationController.sourceView = _avatarImageView;
alertVC.popoverPresentationController.sourceRect = _avatarImageView.bounds;
[self presentViewController:alertVC animated:NO completion:nil];
```


## add tap gesture，多个View不能共用一个UITapGestureRecognizer
```objc
UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self.newsTabEditView action:@selector(handleTap:)];
[self.newsTabEditView addGestureRecognizer:tapGes];

- (void)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
        
    }
}
```

## UIButton tap listen
```objc
[button addTarget:self action:@selector(handleTap:indexPath:) forControlEvents:UIControlEventTouchUpInside];

- (void)handleTap:(UIButton*)sender indexPath:(NSIndexPath *)indexPath {
}
```

## Selector params:
```objc
// with no parameters
action:@selector(switchToNewsDetails)
// with 1 parameter indicating the control that sends the message
action:@selector(switchToNewsDetails:)
// With 2 parameters indicating the control that sends the message and the event that triggered the message:
action:@selector(switchToNewsDetails:event:)
```

## View继承关系
UIButton - UIControl - UIView - UIResponder - NSObject
UILabel - UIView - ...

## static val
```
static NSInteger aPrimitive[5] = {8, 7, 4, 4, 15};
static NSString * const anObject = @"haha";
```


## objc
### property
- atomic / nonatomic get/set线程安全
- strong / weak
- readwrite / readonly
- copy 常见于NSString，避免赋值为NSMutableString，修改NSMutableString影响到属性的值
- class

### NSString
- const char * -> initWithBytes

### synthesize / dynamic 设置get/set方法
#### 缺省
属性默认：`@syntheszie var = _var`，自动生成`xxx()`和`setXxx()`方法
自定义get/set方法
```objc
@property(nonatomic, copy, getter=getMyAString, setter=setMyAString) NSString *aString;
```
##### 默认不自动生成get/set
- readwrite + both custom getter and setter
- readonly + custom getter
- @dynamic
- properties declared in a @protocol
- properties declared in a category
- overridden properties

### 泛型
- NSArray<NSString>
- NSArray<__kindof NSString> 可以是NSMutableString


### 单例singleton
- normal
```objc
+ (id)sharedManager {
    static MyManager *sharedMyManager = nil;
    @synchronized(self) {
        if (sharedMyManager == nil)
            sharedMyManager = [[self alloc] init];
    }
    return sharedMyManager;
}
```
- Grand Central Dispatch (GCD)
```objc
+ (id)sharedManager {
    static MyManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}
```
- non ARC
```
太复杂了...
```

### UIKit常见类继承关系
#### UIScrollViewDelegate
##### UICollectionViewDelegate
##### UICollectionViewDelegateFlowLayout

### 集合类遍历时是非mutable，不可增删item。可在遍历时用新建的一个原集合类copy


### UITableView 
#### 隐藏默认分隔线背景
```objc
self.newsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
self.newsTableView.tableFooterView.hidden = YES;
```
#### reloadSection / reloadRow 闪


### 在storyboard设置gesture recognizer
### 在storyboard设置clip bounds
### 在storyboard设置多个View共用一个gesture recognizer
### 在storyboard设置constraint id，在代码修改该contraint的值


### subView add viewcontroller:
```objc
+ (void)addContentViewController:(__kindof UIViewController *)childViewController parentViewController:(__kindof UIViewController *)parentViewController superview:(__kindof UIView *)superview {
    childViewController.view.frame = superview.bounds;
    [childViewController willMoveToParentViewController:parentViewController];
    [parentViewController addChildViewController:childViewController];
    [superview addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:parentViewController];
}

+ (void)removeAllContentViewController:(__kindof UIViewController *)parentViewController superview:(__kindof UIView *)superview {
    for (UIViewController *childViewController in parentViewController.childViewControllers.copy) {
        if (childViewController.view.superview == superview) {
            [ALMeViewController removeContentViewController:childViewController];
        }
    }
}

+ (void)removeContentViewController:(__kindof UIViewController *)childViewController {
    [childViewController willMoveToParentViewController:nil];
    [childViewController.view removeFromSuperview];
    [childViewController removeFromParentViewController];
}
```

### autolayout
- Label A - Label B -
Content hugging priority: small-wider(expand space)
Content compression resistance priority: bigger-wider(text content compression when width is not enough to show content)

### touch event
#### 分发和响应机制
#### gesture
#### hit test