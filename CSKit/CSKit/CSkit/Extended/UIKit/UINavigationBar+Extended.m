//
//  UINavigationBar+Extended.m
//  CSCategory
//
//  Created by 刘聪 on 2017/7/3.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UINavigationBar+Extended.h"
#import <objc/runtime.h>


//===============================================================================================
#pragma mark - 默认导航栏barTintColor,tintColor和状态栏风格你可以更改!!!
//===============================================================================================
@interface UIColor (__NavigationBar)

+ (UIColor *)defaultNavBarBarTintColor;
+ (UIColor *)defaultNavBarTintColor;
+ (UIColor *)defaultNavBarTitleColor;
+ (UIStatusBarStyle)defaultStatusBarStyle;
+ (BOOL)defaultNavBarShadowImageHidden;
+ (CGFloat)defaultNavBarBackgroundAlpha;
+ (UIColor *)middleColor:(UIColor *)fromColor toColor:(UIColor *)toColor percent:(CGFloat)percent;
+ (CGFloat)middleAlpha:(CGFloat)fromAlpha toAlpha:(CGFloat)toAlpha percent:(CGFloat)percent;

@end

@implementation UIColor (NavigationBar)

static char kCSDefaultNavBarBarTintColorKey;
static char kCSDefaultNavBarTintColorKey;
static char kCSDefaultNavBarTitleColorKey;
static char kCSDefaultStatusBarStyleKey;
static char kCSDefaultNavBarShadowImageHiddenKey;

+ (UIColor *)defaultNavBarBarTintColor
{
    UIColor *color = (UIColor *)objc_getAssociatedObject(self, &kCSDefaultNavBarBarTintColorKey);
    return (color != nil) ? color : [UIColor whiteColor];
}
+ (void)runtimeSetDefaultNavBarBarTintColor:(UIColor *)color
{
    objc_setAssociatedObject(self, &kCSDefaultNavBarBarTintColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIColor *)defaultNavBarTintColor
{
    UIColor *color = (UIColor *)objc_getAssociatedObject(self, &kCSDefaultNavBarTintColorKey);
    return (color != nil) ? color : [UIColor colorWithRed:0 green:0.478431 blue:1 alpha:1.0];
}
+ (void)runtimeSetDefaultNavBarTintColor:(UIColor *)color
{
    objc_setAssociatedObject(self, &kCSDefaultNavBarTintColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIColor *)defaultNavBarTitleColor
{
    UIColor *color = (UIColor *)objc_getAssociatedObject(self, &kCSDefaultNavBarTitleColorKey);
    return (color != nil) ? color : [UIColor blackColor];
}
+ (void)runtimeSetDefaultNavBarTitleColor:(UIColor *)color
{
    objc_setAssociatedObject(self, &kCSDefaultNavBarTitleColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (UIStatusBarStyle)defaultStatusBarStyle
{
    id style = objc_getAssociatedObject(self, &kCSDefaultStatusBarStyleKey);
    return (style != nil) ? [style integerValue] : UIStatusBarStyleDefault;
}
+ (void)runtimeSetDefaultStatusBarStyle:(UIStatusBarStyle)style
{
    objc_setAssociatedObject(self, &kCSDefaultStatusBarStyleKey, @(style), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (BOOL)defaultNavBarShadowImageHidden
{
    id hidden = objc_getAssociatedObject(self, &kCSDefaultNavBarShadowImageHiddenKey);
    return (hidden != nil) ? [hidden boolValue] : NO;
}
+ (void)runtimeSetDefaultNavBarShadowImageHidden:(BOOL)hidden
{
    objc_setAssociatedObject(self, &kCSDefaultNavBarShadowImageHiddenKey, @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (CGFloat)defaultNavBarBackgroundAlpha
{
    return 1.0;
}

+ (UIColor *)middleColor:(UIColor *)fromColor toColor:(UIColor *)toColor percent:(CGFloat)percent
{
    CGFloat fromRed = 0;
    CGFloat fromGreen = 0;
    CGFloat fromBlue = 0;
    CGFloat fromAlpha = 0;
    [fromColor getRed:&fromRed green:&fromGreen blue:&fromBlue alpha:&fromAlpha];
    
    CGFloat toRed = 0;
    CGFloat toGreen = 0;
    CGFloat toBlue = 0;
    CGFloat toAlpha = 0;
    [toColor getRed:&toRed green:&toGreen blue:&toBlue alpha:&toAlpha];
    
    CGFloat newRed = fromRed + (toRed - fromRed) * percent;
    CGFloat newGreen = fromGreen + (toGreen - fromGreen) * percent;
    CGFloat newBlue = fromBlue + (toBlue - fromBlue) * percent;
    CGFloat newAlpha = fromAlpha + (toAlpha - fromAlpha) * percent;
    return [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:newAlpha];
}
+ (CGFloat)middleAlpha:(CGFloat)fromAlpha toAlpha:(CGFloat)toAlpha percent:(CGFloat)percent
{
    return fromAlpha + (toAlpha - fromAlpha) * percent;
}


@end

//==========================================================================
#pragma mark - UINavigationBar
//==========================================================================
@implementation UINavigationBar (Extended)

static char kCSBackgroundViewKey;
static char kCSBackgroundImageViewKey;
static int kCSNavBarBottom = 64;

- (UIView *)backgroundView
{
    return (UIView *)objc_getAssociatedObject(self, &kCSBackgroundViewKey);
}
- (void)setBackgroundView:(UIView *)backgroundView
{
    objc_setAssociatedObject(self, &kCSBackgroundViewKey, backgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImageView *)backgroundImageView
{
    return (UIImageView *)objc_getAssociatedObject(self, &kCSBackgroundImageViewKey);
}
- (void)setBackgroundImageView:(UIImageView *)bgImageView
{
    objc_setAssociatedObject(self, &kCSBackgroundImageViewKey, bgImageView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// set navigationBar backgroundImage
- (void)setBackgroundImage:(UIImage *)image
{
    [self.backgroundView removeFromSuperview];
    self.backgroundView = nil;
    if (self.backgroundImageView == nil)
    {
        // add a image(nil color) to _UIBarBackground make it clear
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), kCSNavBarBottom)];
        // _UIBarBackground is first subView for navigationBar
        [self.subviews.firstObject insertSubview:self.backgroundImageView atIndex:0];
    }
    self.backgroundImageView.image = image;
}

// set navigationBar barTintColor
- (void)setBackgroundColor:(UIColor *)color
{
    [self.backgroundImageView removeFromSuperview];
    self.backgroundImageView = nil;
    if (self.backgroundView == nil)
    {
        // add a image(nil color) to _UIBarBackground make it clear
        [self setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), kCSNavBarBottom)];
        // _UIBarBackground is first subView for navigationBar
        [self.subviews.firstObject insertSubview:self.backgroundView atIndex:0];
    }
    self.backgroundView.backgroundColor = color;
}

// set _UIBarBackground alpha (_UIBarBackground subviews alpha <= _UIBarBackground alpha)
- (void)setBackgroundAlpha:(CGFloat)alpha
{
    UIView *barBackgroundView = self.subviews.firstObject;
    barBackgroundView.alpha = alpha;
}

- (void)setBarButtonItemsAlpha:(CGFloat)alpha hasSystemBackIndicator:(BOOL)hasSystemBackIndicator
{
    for (UIView *view in self.subviews)
    {
        if (hasSystemBackIndicator == YES)
        {
            // _UIBarBackground/_UINavigationBarBackground对应的view是系统导航栏，不需要改变其透明度
            Class _UIBarBackgroundClass = NSClassFromString(@"_UIBarBackground");
            if (_UIBarBackgroundClass != nil)
            {
                if ([view isKindOfClass:_UIBarBackgroundClass] == NO) {
                    view.alpha = alpha;
                }
            }
            
            Class _UINavigationBarBackground = NSClassFromString(@"_UINavigationBarBackground");
            if (_UINavigationBarBackground != nil)
            {
                if ([view isKindOfClass:_UINavigationBarBackground] == NO) {
                    view.alpha = alpha;
                }
            }
        }
        else
        {
            // 这里如果不做判断的话，会显示 backIndicatorImage
            if ([view isKindOfClass:NSClassFromString(@"_UINavigationBarBackIndicatorView")] == NO)
            {
                Class _UIBarBackgroundClass = NSClassFromString(@"_UIBarBackground");
                if (_UIBarBackgroundClass != nil)
                {
                    if ([view isKindOfClass:_UIBarBackgroundClass] == NO) {
                        view.alpha = alpha;
                    }
                }
                
                Class _UINavigationBarBackground = NSClassFromString(@"_UINavigationBarBackground");
                if (_UINavigationBarBackground != nil)
                {
                    if ([view isKindOfClass:_UINavigationBarBackground] == NO) {
                        view.alpha = alpha;
                    }
                }
            }
        }
    }
}

// 设置导航栏在垂直方向上平移多少距离
- (void)setTranslationY:(CGFloat)translationY
{
    // CGAffineTransformMakeTranslation  平移
    self.transform = CGAffineTransformMakeTranslation(0, translationY);
}

/** 获取当前导航栏在垂直方向上偏移了多少 */
- (CGFloat)getTranslationY
{
    return self.transform.ty;
}

#pragma mark - call swizzling methods active 主动调用交换方法
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      SEL needSwizzleSelectors[4] = {
                          @selector(setTitleTextAttributes:)
                      };
                      
                      for (int i = 0; i < 4;  i++) {
                          SEL selector = needSwizzleSelectors[i];
                          NSString *newSelectorStr = [NSString stringWithFormat:@"runtime_%@", NSStringFromSelector(selector)];
                          Method originMethod = class_getInstanceMethod(self, selector);
                          Method swizzledMethod = class_getInstanceMethod(self, NSSelectorFromString(newSelectorStr));
                          method_exchangeImplementations(originMethod, swizzledMethod);
                      }
                  });
}

- (void)runtime_setTitleTextAttributes:(NSDictionary<NSString *,id> *)titleTextAttributes
{
    NSMutableDictionary<NSString *,id> *newTitleTextAttributes = [titleTextAttributes mutableCopy];
    if (newTitleTextAttributes == nil) {
        return;
    }
    
    NSDictionary<NSString *,id> *originTitleTextAttributes = self.titleTextAttributes;
    if (originTitleTextAttributes == nil) {
        [self runtime_setTitleTextAttributes:newTitleTextAttributes];
        return;
    }
    
    __block UIColor *titleColor;
    [originTitleTextAttributes enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([key isEqual:NSForegroundColorAttributeName]) {
            titleColor = (UIColor *)obj;
            *stop = YES;
        }
    }];
    
    if (titleColor == nil) {
        [self runtime_setTitleTextAttributes:newTitleTextAttributes];
        return;
    }
    
    if (newTitleTextAttributes[NSForegroundColorAttributeName] == nil) {
        newTitleTextAttributes[NSForegroundColorAttributeName] = titleColor;
    }
    [self runtime_setTitleTextAttributes:newTitleTextAttributes];
}

@end


@interface UIViewController (__NavigationBar)
- (void)setPushToCurrentVCFinished:(BOOL)isFinished;
@end

//==========================================================================
#pragma mark - UINavigationController
//==========================================================================
@implementation UINavigationController (NavigationBar)

static CGFloat kPopDuration = 0.12;
static int kPopDisplayCount = 0;
- (CGFloat)PopProgress
{
    CGFloat all = 60 * kPopDuration;
    int current = MIN(all, kPopDisplayCount);
    return current / all;
}

static CGFloat wrPushDuration = 0.10;
static int wrPushDisplayCount = 0;
- (CGFloat)wrPushProgress
{
    CGFloat all = 60 * kPopDuration;
    int current = MIN(all, kPopDisplayCount);
    return current / all;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.topViewController statusBarStyle];
}

- (void)setNeedsNavigationBarUpdateForBarBackgroundImage:(UIImage *)backgroundImage
{
    [self.navigationBar setBackgroundImage:backgroundImage];
}
- (void)setNeedsNavigationBarUpdateForBarTintColor:(UIColor *)barTintColor
{
    [self.navigationBar setBackgroundColor:barTintColor];
}
- (void)setNeedsNavigationBarUpdateForBarBackgroundAlpha:(CGFloat)barBackgroundAlpha
{
    [self.navigationBar setBackgroundAlpha:barBackgroundAlpha];
}
- (void)setNeedsNavigationBarUpdateForTintColor:(UIColor *)tintColor
{
    self.navigationBar.tintColor = tintColor;
}
- (void)setNeedsNavigationBarUpdateForShadowImageHidden:(BOOL)hidden
{
    self.navigationBar.shadowImage = (hidden == YES) ? [UIImage new] : nil;
}


- (void)setNeedsNavigationBarUpdateForTitleColor:(UIColor *)titleColor
{
    NSDictionary *titleTextAttributes = [self.navigationBar titleTextAttributes];
    if (titleTextAttributes == nil) {
        self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:titleColor};
        return;
    }
    
    NSMutableDictionary *newTitleTextAttributes = [titleTextAttributes mutableCopy];
    newTitleTextAttributes[NSForegroundColorAttributeName] = titleColor;
    self.navigationBar.titleTextAttributes = newTitleTextAttributes;
}

- (void)updateNavigationBarWithFromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC progress:(CGFloat)progress
{
    // change navBarBarTintColor
    UIColor *fromBarTintColor = [fromVC navBarBarTintColor];
    UIColor *toBarTintColor = [toVC navBarBarTintColor];
    UIColor *newBarTintColor = [UIColor middleColor:fromBarTintColor toColor:toBarTintColor percent:progress];
    [self setNeedsNavigationBarUpdateForBarTintColor:newBarTintColor];
    
    // change navBarTintColor
    UIColor *fromTintColor = [fromVC navBarTintColor];
    UIColor *toTintColor = [toVC navBarTintColor];
    UIColor *newTintColor = [UIColor middleColor:fromTintColor toColor:toTintColor percent:progress];
    [self setNeedsNavigationBarUpdateForTintColor:newTintColor];
    
    // change navBarTitleColor
    UIColor *fromTitleColor = [fromVC navBarTitleColor];
    UIColor *toTitleColor = [toVC navBarTitleColor];
    UIColor *newTitleColor = [UIColor middleColor:fromTitleColor toColor:toTitleColor percent:progress];
    [self setNeedsNavigationBarUpdateForTitleColor:newTitleColor];
    
    // change navBar _UIBarBackground alpha
    CGFloat fromBarBackgroundAlpha = [fromVC navBarBackgroundAlpha];
    CGFloat toBarBackgroundAlpha = [toVC navBarBackgroundAlpha];
    CGFloat newBarBackgroundAlpha = [UIColor middleAlpha:fromBarBackgroundAlpha toAlpha:toBarBackgroundAlpha percent:progress];
    [self setNeedsNavigationBarUpdateForBarBackgroundAlpha:newBarBackgroundAlpha];
}

#pragma mark - call swizzling methods active 主动调用交换方法
+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      SEL needSwizzleSelectors[4] = {
                          NSSelectorFromString(@"_updateInteractiveTransition:"),
                          @selector(popToViewController:animated:),
                          @selector(popToRootViewControllerAnimated:),
                          @selector(pushViewController:animated:)
                      };
                      
                      for (int i = 0; i < 4;  i++) {
                          SEL selector = needSwizzleSelectors[i];
                          NSString *newSelectorStr = [[NSString stringWithFormat:@"runtime_%@", NSStringFromSelector(selector)] stringByReplacingOccurrencesOfString:@"__" withString:@"_"];
                          Method originMethod = class_getInstanceMethod(self, selector);
                          Method swizzledMethod = class_getInstanceMethod(self, NSSelectorFromString(newSelectorStr));
                          method_exchangeImplementations(originMethod, swizzledMethod);
                      }
                  });
}

- (NSArray<UIViewController *> *)runtime_popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    __block CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(popNeedDisplay)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [CATransaction setCompletionBlock:^{
        [displayLink invalidate];
        displayLink = nil;
        kPopDisplayCount= 0;
    }];
    [CATransaction setAnimationDuration:kPopDuration];
    [CATransaction begin];
    NSArray<UIViewController *> *vcs = [self runtime_popToViewController:viewController animated:animated];
    [CATransaction commit];
    return vcs;
}

- (NSArray<UIViewController *> *)runtime_popToRootViewControllerAnimated:(BOOL)animated
{
    __block CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(popNeedDisplay)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [CATransaction setCompletionBlock:^{
        [displayLink invalidate];
        displayLink = nil;
        kPopDisplayCount = 0;
    }];
    [CATransaction setAnimationDuration:kPopDuration];
    [CATransaction begin];
    NSArray<UIViewController *> *vcs = [self runtime_popToRootViewControllerAnimated:animated];
    [CATransaction commit];
    return vcs;
}

// change navigationBar barTintColor smooth before pop to current VC finished
- (void)popNeedDisplay
{
    if (self.topViewController != nil && self.topViewController.transitionCoordinator != nil)
    {
        kPopDisplayCount += 1;
        CGFloat popProgress = [self PopProgress];
        UIViewController *fromVC = [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toVC = [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        [self updateNavigationBarWithFromVC:fromVC toVC:toVC progress:popProgress];
    }
}

- (void)runtime_pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    __block CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(pushNeedDisplay)];
    [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [CATransaction setCompletionBlock:^{
        [displayLink invalidate];
        displayLink = nil;
        wrPushDisplayCount = 0;
        [viewController setPushToCurrentVCFinished:YES];
    }];
    [CATransaction setAnimationDuration:wrPushDuration];
    [CATransaction begin];
    [self runtime_pushViewController:viewController animated:animated];
    [CATransaction commit];
}

// change navigationBar barTintColor smooth before push to current VC finished or before pop to current VC finished
- (void)pushNeedDisplay
{
    if (self.topViewController != nil && self.topViewController.transitionCoordinator != nil)
    {
        wrPushDisplayCount += 1;
        CGFloat pushProgress = [self wrPushProgress];
        UIViewController *fromVC = [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toVC = [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
        [self updateNavigationBarWithFromVC:fromVC toVC:toVC progress:pushProgress];
    }
}

#pragma mark - deal the gesture of return
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    __weak typeof (self) weakSelf = self;
    id<UIViewControllerTransitionCoordinator> coor = [self.topViewController transitionCoordinator];
    if ([coor initiallyInteractive] == YES)
    {
        NSString *sysVersion = [[UIDevice currentDevice] systemVersion];
        if ([sysVersion floatValue] >= 10)
        {
            [coor notifyWhenInteractionChangesUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                __strong typeof (self) pThis = weakSelf;
                [pThis dealInteractionChanges:context];
            }];
        }
        else
        {
            [coor notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
                __strong typeof (self) pThis = weakSelf;
                [pThis dealInteractionChanges:context];
            }];
        }
        return YES;
    }
    
    
    NSUInteger itemCount = self.navigationBar.items.count;
    NSUInteger n = self.viewControllers.count >= itemCount ? 2 : 1;
    UIViewController *popToVC = self.viewControllers[self.viewControllers.count - n];
    [self popToViewController:popToVC animated:YES];
    return YES;
}

// deal the gesture of return break off
- (void)dealInteractionChanges:(id<UIViewControllerTransitionCoordinatorContext>)context
{
    void (^animations) (UITransitionContextViewControllerKey) = ^(UITransitionContextViewControllerKey key){
        UIColor *curColor = [[context viewControllerForKey:key] navBarBarTintColor];
        CGFloat curAlpha = [[context viewControllerForKey:key] navBarBackgroundAlpha];
        [self setNeedsNavigationBarUpdateForBarTintColor:curColor];
        [self setNeedsNavigationBarUpdateForBarBackgroundAlpha:curAlpha];
    };
    
    // after that, cancel the gesture of return
    if ([context isCancelled] == YES)
    {
        double cancelDuration = [context transitionDuration] * [context percentComplete];
        [UIView animateWithDuration:cancelDuration animations:^{
            animations(UITransitionContextFromViewControllerKey);
        }];
    }
    else
    {
        // after that, finish the gesture of return
        double finishDuration = [context transitionDuration] * (1 - [context percentComplete]);
        [UIView animateWithDuration:finishDuration animations:^{
            animations(UITransitionContextToViewControllerKey);
        }];
    }
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    UIViewController *fromVC = [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [self.topViewController.transitionCoordinator viewControllerForKey:UITransitionContextToViewControllerKey];
    [self updateNavigationBarWithFromVC:fromVC toVC:toVC progress:percentComplete];
    
    [self updateInteractiveTransition:percentComplete];
}

@end



//==========================================================================
#pragma mark - UIViewController
//==========================================================================
@implementation UIViewController (NavigationBar)

static char kCSPushToCurrentVCFinishedKey;
static char kCSPushToNextVCFinishedKey;
static char kCSNavBarBackgroundImageKey;
static char kCSNavBarBarTintColorKey;
static char kCSNavBarBackgroundAlphaKey;
static char kCSNavBarTintColorKey;
static char kCSNavBarTitleColorKey;
static char kCSStatusBarStyleKey;
static char kCSNavBarShadowImageHiddenKey;
static char kCSCustomNavBarKey;

// navigationBar barTintColor can not change by currentVC before fromVC push to currentVC finished
- (BOOL)pushToCurrentVCFinished
{
    id isFinished = objc_getAssociatedObject(self, &kCSPushToCurrentVCFinishedKey);
    return (isFinished != nil) ? [isFinished boolValue] : NO;
}
- (void)setPushToCurrentVCFinished:(BOOL)isFinished
{
    objc_setAssociatedObject(self, &kCSPushToCurrentVCFinishedKey, @(isFinished), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// navigationBar barTintColor can not change by currentVC when currentVC push to nextVC finished
- (BOOL)pushToNextVCFinished
{
    id isFinished = objc_getAssociatedObject(self, &kCSPushToNextVCFinishedKey);
    return (isFinished != nil) ? [isFinished boolValue] : NO;
}
- (void)setPushToNextVCFinished:(BOOL)isFinished
{
    objc_setAssociatedObject(self, &kCSPushToNextVCFinishedKey, @(isFinished), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// navigationBar backgroundImage
- (UIImage *)navBarBackgroundImage
{
    return (UIImage *)objc_getAssociatedObject(self, &kCSNavBarBackgroundImageKey);
}
- (void)runtimeSetNavBarBackgroundImage:(UIImage *)image
{
    objc_setAssociatedObject(self, &kCSNavBarBackgroundImageKey, image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

// navigationBar barTintColor
- (UIColor *)navBarBarTintColor
{
    UIColor *barTintColor = (UIColor *)objc_getAssociatedObject(self, &kCSNavBarBarTintColorKey);
    return (barTintColor != nil) ? barTintColor : [UIColor defaultNavBarBarTintColor];
}
- (void)runtimeSetNavBarBarTintColor:(UIColor *)color
{
    objc_setAssociatedObject(self, &kCSNavBarBarTintColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([[self customNavBar] isKindOfClass:[UINavigationBar class]])
    {
        UINavigationBar *navBar = (UINavigationBar *)[self customNavBar];
        [navBar setBackgroundColor:color];
    }
    else
    {
        if ([self pushToCurrentVCFinished] == YES && [self pushToNextVCFinished] == NO) {
            [self.navigationController setNeedsNavigationBarUpdateForBarTintColor:color];
        }
    }
}

// navigationBar _UIBarBackground alpha
- (CGFloat)navBarBackgroundAlpha
{
    id barBackgroundAlpha = objc_getAssociatedObject(self, &kCSNavBarBackgroundAlphaKey);
    return (barBackgroundAlpha != nil) ? [barBackgroundAlpha floatValue] : [UIColor defaultNavBarBackgroundAlpha];
    
}
- (void)runtimeSetNavBarBackgroundAlpha:(CGFloat)alpha
{
    
    objc_setAssociatedObject(self, &kCSNavBarBackgroundAlphaKey, @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([[self customNavBar] isKindOfClass:[UINavigationBar class]])
    {
        UINavigationBar *navBar = (UINavigationBar *)[self customNavBar];
        [navBar setBackgroundAlpha:alpha];
    }
    else
    {
        if ([self pushToCurrentVCFinished] == YES && [self pushToNextVCFinished] == NO) {
            [self.navigationController setNeedsNavigationBarUpdateForBarBackgroundAlpha:alpha];
        }
    }
}

// navigationBar tintColor
- (UIColor *)navBarTintColor
{
    UIColor *tintColor = (UIColor *)objc_getAssociatedObject(self, &kCSNavBarTintColorKey);
    return (tintColor != nil) ? tintColor : [UIColor defaultNavBarTintColor];
}
- (void)runtimeSetNavBarTintColor:(UIColor *)color
{
    objc_setAssociatedObject(self, &kCSNavBarTintColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([[self customNavBar] isKindOfClass:[UINavigationBar class]])
    {
        UINavigationBar *navBar = (UINavigationBar *)[self customNavBar];
        navBar.tintColor = color;
    }
    else
    {
        if ([self pushToNextVCFinished] == NO) {
            [self.navigationController setNeedsNavigationBarUpdateForTintColor:color];
        }
    }
}

// navigationBar titleColor
- (UIColor *)navBarTitleColor
{
    UIColor *titleColor = (UIColor *)objc_getAssociatedObject(self, &kCSNavBarTitleColorKey);
    return (titleColor != nil) ? titleColor : [UIColor defaultNavBarTitleColor];
}
- (void)runtimeSetNavBarTitleColor:(UIColor *)color
{
    objc_setAssociatedObject(self, &kCSNavBarTitleColorKey, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if ([[self customNavBar] isKindOfClass:[UINavigationBar class]])
    {
        UINavigationBar *navBar = (UINavigationBar *)[self customNavBar];
        navBar.titleTextAttributes = @{NSForegroundColorAttributeName:color};
    }
    else
    {
        if ([self pushToNextVCFinished] == NO) {
            [self.navigationController setNeedsNavigationBarUpdateForTitleColor:color];
        }
    }
}

// statusBarStyle
- (UIStatusBarStyle)statusBarStyle
{
    id style = objc_getAssociatedObject(self, &kCSStatusBarStyleKey);
    return (style != nil) ? [style integerValue] : [UIColor defaultStatusBarStyle];
}
- (void)runtimeSetStatusBarStyle:(UIStatusBarStyle)style
{
    objc_setAssociatedObject(self, &kCSStatusBarStyleKey, @(style), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setNeedsStatusBarAppearanceUpdate];
}

// shadowImage
- (void)runtimeSetNavBarShadowImageHidden:(BOOL)hidden
{
    objc_setAssociatedObject(self, &kCSNavBarShadowImageHiddenKey, @(hidden), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self.navigationController setNeedsNavigationBarUpdateForShadowImageHidden:hidden];
    
}

+ (void)runtimeSetBackButtonTitleHidden:(BOOL)hidden{
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, (hidden)? -60 : 0)
                                                         forBarMetrics:UIBarMetricsDefault];
}

- (BOOL)navBarShadowImageHidden
{
    id hidden = objc_getAssociatedObject(self, &kCSNavBarShadowImageHiddenKey);
    return (hidden != nil) ? [hidden boolValue] : [UIColor defaultNavBarShadowImageHidden];
}

// custom navigationBar
- (UIView *)customNavBar
{
    UIView *navBar = objc_getAssociatedObject(self, &kCSCustomNavBarKey);
    return (navBar != nil) ? navBar : [UIView new];
}
- (void)runtimeSetCustomNavBar:(UINavigationBar *)navBar
{
    objc_setAssociatedObject(self, &kCSCustomNavBarKey, navBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
                  {
                      SEL needSwizzleSelectors[3] = {
                          @selector(viewWillAppear:),
                          @selector(viewWillDisappear:),
                          @selector(viewDidAppear:)
                      };
                      
                      for (int i = 0; i < 3;  i++) {
                          SEL selector = needSwizzleSelectors[i];
                          NSString *newSelectorStr = [NSString stringWithFormat:@"runtime_%@", NSStringFromSelector(selector)];
                          Method originMethod = class_getInstanceMethod(self, selector);
                          Method swizzledMethod = class_getInstanceMethod(self, NSSelectorFromString(newSelectorStr));
                          method_exchangeImplementations(originMethod, swizzledMethod);
                      }
                  });
}

- (void)runtime_viewWillAppear:(BOOL)animated
{
    [self setPushToNextVCFinished:NO];
    [self.navigationController setNeedsNavigationBarUpdateForTintColor:[self navBarTintColor]];
    [self.navigationController setNeedsNavigationBarUpdateForTitleColor:[self navBarTitleColor]];
    [self runtime_viewWillAppear:animated];
}

- (void)runtime_viewWillDisappear:(BOOL)animated
{
    
    [self setPushToNextVCFinished:YES];
    [self runtime_viewWillDisappear:animated];
}

- (void)runtime_viewDidAppear:(BOOL)animated
{
    UIImage *barBgImage = [self navBarBackgroundImage];
    if (barBgImage != nil) {
        [self.navigationController setNeedsNavigationBarUpdateForBarBackgroundImage:barBgImage];
    } else {
        [self.navigationController setNeedsNavigationBarUpdateForBarTintColor:[self navBarBarTintColor]];
    }
    [self.navigationController setNeedsNavigationBarUpdateForBarBackgroundAlpha:[self navBarBackgroundAlpha]];
    [self.navigationController setNeedsNavigationBarUpdateForTintColor:[self navBarTintColor]];
    [self.navigationController setNeedsNavigationBarUpdateForTitleColor:[self navBarTitleColor]];
    [self.navigationController setNeedsNavigationBarUpdateForShadowImageHidden:[self navBarShadowImageHidden]];
    [self runtime_viewDidAppear:animated];
}

@end


