//
//  AppDelegate.m
//  CSKit
//
//  Created by 刘聪 on 2017/7/28.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import "AppDelegate.h"
#import "UINavigationBar+Extended.h"
#import "UIColor+Extended.h"

@interface AppDelegate ()

@end

UIColor *MainNavBarColor = nil;
UIColor *MainViewColor = nil;

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setNavBarAppearence];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setNavBarAppearence
{
    MainNavBarColor = [UIColor whiteColor];
    MainViewColor   = [UIColor whiteColor];
    
    // 设置导航栏默认的背景颜色
    [UIColor runtimeSetDefaultNavBarTintColor:MainNavBarColor];
    // 设置导航栏所有按钮的默认颜色
    [UIColor runtimeSetDefaultNavBarTintColor:[UIColor FontColor1]];
    // 设置导航栏标题默认颜色
    [UIColor runtimeSetDefaultNavBarTitleColor:[UIColor FontColor1]];
    // 统一设置状态栏样式
    [UIColor runtimeSetDefaultStatusBarStyle:UIStatusBarStyleDefault];
    // 如果需要设置导航栏底部分割线隐藏，可以在这里统一设置
    // [UIColor wr_setDefaultNavBarShadowImageHidden:YES];
}


@end
