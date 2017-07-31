//
//  UIWindow+Extended.h
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIWindow (Extended)

/**
 最顶级控制器
 
 @return 返回当前最上面的在的ViewController层次结构
 */
- (UIViewController*)topMostController;

/**
 当前的ViewController
 
 @return 返回的ViewController在最顶级控制器堆叠.
 */
- (UIViewController*)currentViewController;

@end
