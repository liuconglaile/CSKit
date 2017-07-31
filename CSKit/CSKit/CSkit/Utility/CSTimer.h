//
//  CSTimer.h
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN


/**
 CSTimer是基于GCD的线程安全计时器.它具有与NSTimer相似的API.
 CSTimer对象与NSTimer的不同之处在于:
  
 * 使用GCD产生计时器滴答，不受runLoop的影响.
 * 对目标进行弱引用,可避免保留循环.
 * 它总是在主线程上触发.
 */
@interface CSTimer : NSObject

+ (CSTimer *)timerWithTimeInterval:(NSTimeInterval)interval
                            target:(id)target
                          selector:(SEL)selector
                           repeats:(BOOL)repeats;

- (instancetype)initWithFireTime:(NSTimeInterval)start
                        interval:(NSTimeInterval)interval
                          target:(id)target
                        selector:(SEL)selector
                         repeats:(BOOL)repeats NS_DESIGNATED_INITIALIZER;

@property (readonly) BOOL repeats;
@property (readonly) NSTimeInterval timeInterval;
@property (readonly, getter=isValid) BOOL valid;

- (void)invalidate;
- (void)fire;

@end
NS_ASSUME_NONNULL_END

