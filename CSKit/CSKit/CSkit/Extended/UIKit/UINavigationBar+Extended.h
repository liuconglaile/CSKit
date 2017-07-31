//
//  UINavigationBar+Extended.h
//  CSCategory
//
//  Created by 刘聪 on 2017/7/3.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (NavigationBar)

/** 设置UINavigationBar的默认barTintColor */
+ (void)runtimeSetDefaultNavBarBarTintColor:(UIColor *)color;
/** 设置UINavigationBar的默认tintColor */
+ (void)runtimeSetDefaultNavBarTintColor:(UIColor *)color;
/** 设置UINavigationBar的默认titleColor */
+ (void)runtimeSetDefaultNavBarTitleColor:(UIColor *)color;
/** 设置UIStatusBar的默认statusBarStyle */
+ (void)runtimeSetDefaultStatusBarStyle:(UIStatusBarStyle)style;
/** 设置默认UINavigationBar的shadowImage是否隐藏 */
+ (void)runtimeSetDefaultNavBarShadowImageHidden:(BOOL)hidden;

@end

@interface UIViewController (NavigationBar)

/** 记录当前视图控制器的导航栏和backgroundImage **/
- (void)runtimeSetNavBarBackgroundImage:(UIImage *)image;
- (UIImage *)navBarBackgroundImage;

/** 记录当前视图控制器的导航栏barTintColor */
- (void)runtimeSetNavBarBarTintColor:(UIColor *)color;
- (UIColor *)navBarBarTintColor;

/** 记录当前视图控制器的导航栏background Alpha */
- (void)runtimeSetNavBarBackgroundAlpha:(CGFloat)alpha;
- (CGFloat)navBarBackgroundAlpha;

/** 记录当前视图控制器的导航栏tintColor */
- (void)runtimeSetNavBarTintColor:(UIColor *)color;
- (UIColor *)navBarTintColor;

/** 记录当前视图控制器titleColor */
- (void)runtimeSetNavBarTitleColor:(UIColor *)color;
- (UIColor *)navBarTitleColor;

/** 记录当前视图控制器statusBarStyle */
- (void)runtimeSetStatusBarStyle:(UIStatusBarStyle)style;
- (UIStatusBarStyle)statusBarStyle;

/** 记录当前视图控制器的导航栏的ShadowImage隐藏 */
- (void)runtimeSetNavBarShadowImageHidden:(BOOL)hidden;
- (BOOL)navBarShadowImageHidden;

/** 记录当前的控制器自定义导航栏 */
- (void)runtimeSetCustomNavBar:(UINavigationBar *)navBar;

+ (void)runtimeSetBackButtonTitleHidden:(BOOL)hidden;

@end

@interface UINavigationBar (Extended)<UINavigationBarDelegate>

/** 设置导航栏所有BarButtonItem的透明度 */
- (void)setBarButtonItemsAlpha:(CGFloat)alpha hasSystemBackIndicator:(BOOL)hasSystemBackIndicator;

/** 设置导航栏在垂直方向上平移多少距离 */
- (void)setTranslationY:(CGFloat)translationY;

/** 获取当前导航栏在垂直方向上偏移了多少 */
- (CGFloat)getTranslationY;

@end


