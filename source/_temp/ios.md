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

## memory leak



# UI Design
## List
## Picker
- date picker
- else

## Button
## Text
- label
- input

## Image
## Video
## Tab
- fixed
- scrollable
- bottom
- top

## page(indicator)

## progress
- line
- circle
- Determinate
- indeterminate

## slider
## search bar
## alert / dialog
## selection
- single
- multi
- switch

## navigation drawer
## scrollview




#工具类
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