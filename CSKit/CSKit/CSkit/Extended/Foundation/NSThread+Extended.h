//
//  NSThread+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSThread (Extended)

/**
 将自动释放池添加到当前线程的当前runloop.
 
 @discussion 如果你创建自己的线程(NSThread / pthread),并且你使用runloop来管理您的任务,您可以使用此方法添加自动释放池到runloop.
             它的行为与主线程的自动释放池相同.
 */
+ (void)addAutoreleasePoolToCurrentRunloop NS_AUTOMATED_REFCOUNT_UNAVAILABLE;

/**
 NS_AUTOMATED_REFCOUNT_UNAVAILABLE 
 
 标记在自动参考计数模式下编译时无法使用的方法和功能
 
 用-fno-objc-arc标记来禁用在ARC工程那些不支持ARC的文件的ARC
 用-fobjc-arc标记启用非ARC工程中支持ARC的文件
 
 */

@end
