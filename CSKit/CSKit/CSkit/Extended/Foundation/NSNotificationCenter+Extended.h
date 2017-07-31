//
//  NSNotificationCenter+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 为 NSNotificationCenter 提供一些方法,以不同的线程发布通知.
 */
@interface NSNotificationCenter (Extended)


/**
 在主线程上向接收者发送给定通知.如果当前线程是主线程,则同步发布通知; 否则,会异步发布.
 */
- (void)postNotificationOnMainThread:(NSNotification *)notification;

/**
 在主线程上向接收者发送给定通知.

 @param notification 发出的通知.(如果通知为nil 则发生异常).
 @param wait 一个布尔值,指定当前线程在指定的通知发送到主线程的接收器之后是否阻塞. 指定YES阻止此线程; 除此以外,指定NO可立即返回此方法.
 */
- (void)postNotificationOnMainThread:(NSNotification *)notification
                       waitUntilDone:(BOOL)wait;



/**
 创建具有给定名称和发件人的通知,并将其发布到主线程上的接收者.如果当前线程是主线程,则同步发布通知;否则,会异步发布.
 */
- (void)postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object;

/**
 创建具有给定名称和发件人的通知,并将其发布到主线程上的接收者.如果当前线程是主线程,则同步发布通知;否则,会异步发布
 */
- (void)postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object
                                    userInfo:(nullable NSDictionary *)userInfo;

/**
 创建具有给定名称和发件人的通知,并将其发布到主线程上的接收者

 @param name 通知的名称
 @param object 通知发布对象
 @param userInfo 有关通知的信息,可能为nil
 @param wait 一个布尔值,指定当前线程在指定的通知发送到主线程的接收器之后是否阻塞. 指定YES阻止此线程; 除此以外,指定NO可立即返回此方法.
 */
- (void)postNotificationOnMainThreadWithName:(NSString *)name
                                      object:(nullable id)object
                                    userInfo:(nullable NSDictionary *)userInfo
                               waitUntilDone:(BOOL)wait;

@end

NS_ASSUME_NONNULL_END
