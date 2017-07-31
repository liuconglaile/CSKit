//
//  CSWeakProxy.h
//  CSCategory
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

/**
 用于保存弱对象的代理.它可用于避免保留循环,例如NSTimer或CADisplayLink中的目标.
 
 示例代码:
 
 @implementation MyView {
    NSTimer *_timer;
 }
 
 - (void)initTimer {
 YYWeakProxy *proxy = [YYWeakProxy proxyWithTarget:self];
    _timer = [NSTimer timerWithTimeInterval:0.1 target:proxy selector:@selector(tick:) userInfo:nil repeats:YES];
 }
 
 - (void)tick:(NSTimer *)timer {...}
 
 @end
 */
@interface CSWeakProxy : NSObject

/** 代理目标 */
@property (nullable, nonatomic, weak, readonly) id target;

/**
 为目标创建一个新的弱代理
 
 @param target Target对象
 @return 一个新的代理对象
 */
- (instancetype)initWithTarget:(id)target;

/**
 为目标创建一个新的弱代理
 
 @param target Target对象
 @return 一个新的代理对象
 */
+ (instancetype)proxyWithTarget:(id)target;


@end
NS_ASSUME_NONNULL_END
