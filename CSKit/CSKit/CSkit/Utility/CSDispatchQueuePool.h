//
//  CSDispatchQueuePool.h
//  CSCategory
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libkern/OSAtomic.h>

#ifndef CSDispatchQueuePool_h
/** 主要目的是防止头文件的重复包含和编译 */
#define CSDispatchQueuePool_h


NS_ASSUME_NONNULL_BEGIN

/**
 调度队列池:
 
 分派队列池包含多个串行队列.
 使用这个类来控制队列的线程计数(而不是并发队列).
 */
@interface CSDispatchQueuePool : NSObject

/** 
 UNAVAILABLE_ATTRIBUTE的作用:
 
 告诉编译器该方法不可用,如果强行调用编译器会提示错误.
 比如某个类在构造的时候不想直接通过init来初始化,
 只能通过特定的初始化方法()比如单例,
 就可以将init方法标记为unavailable;

 */
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;



/**
 创建并返回一个调度队列池

 @param name 调度池名字
 @param queueCount 队列计数,有效范围 range(1,32)
 @param qos 队列的优先级(qos)
 @return 返回一个新调度队列池,如果发生错误,则返回 nil
 */
- (instancetype)initWithName:(nullable NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos;


/** 调度池名字 */
@property (nullable, nonatomic, readonly) NSString *name;

/** 从池中获取一个串行队列 */
- (dispatch_queue_t)queue;

/** 基于 QOS 获取默认的调度池,详情可查阅NSQualityOfService API */
+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos;


@end

/** 使用指定的qos从全局队列池中获得一个串行队列 */
extern dispatch_queue_t CSDispatchQueueGetForQOS(NSQualityOfService qos);


NS_ASSUME_NONNULL_END
#endif
