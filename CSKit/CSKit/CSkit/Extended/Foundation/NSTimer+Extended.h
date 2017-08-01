//
//  NSTimer+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (Extended)

/**
 创建并返回一个新的NSTimer对象并在当前运行时安排它在默认模式下循环

 @param seconds 定时器启动之间的秒数.如果 seconds <= 0.0,此方法选择默认0.1毫秒
 @param block 定时器触发时调用的块.定时器保持strong 直到(NSTimer)无效
 @param repeats 如果是,定时器将重复重新调度自身,直到无效.如果否,定时器将在触发后无效
 @return 根据指定的参数配置新的NSTimer对象
 */
+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;


/**
 创建并返回使用指定的块初始化的新NSTimer对象

 @discussion 您必须使用addTimer:forMode:添加新的计时器到运行循环.
             然后,经过几秒钟,定时器触发,调用块(如果定时器配置为重复,则不需要随后将定时器重新添加到运行循环).
 */
+ (NSTimer *)timerWithTimeInterval:(NSTimeInterval)seconds block:(void (^)(NSTimer *timer))block repeats:(BOOL)repeats;



/**
 *  创建一个不会造成循环引用的循环执行的Timer
 */
+ (instancetype)pltScheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo;


@end


NS_ASSUME_NONNULL_END

