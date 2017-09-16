//
//  NSObject+KVOExtended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVOExtended)

/**
 注册一个块以接收相对于接收器的指定密钥路径的KVO通知.
 
 @discussion    块和块捕获的对象被保留.调用'removeObserverBlocksForKeyPath:'或'removeObserverBlocks'来释放.
 @param keyPath 跟踪的属性的关键路径,相对于接收者.该值不能为nil.
 @param block   注册KVO通知的块.
 */
- (void)addObserverBlockForKeyPath:(NSString*)keyPath block:(void (^)(id _Nonnull obj, _Nullable id oldVal, _Nullable id newVal))block;

/**
 停止所有块(通过'addObserverBlockForKeyPath:block:'关联)从接收到给定密钥路径指定的属性的更改通知,并释放这些块.
 
 @param keyPath 相对于接收器的密钥路径,哪些块被注册以接收KVO改变通知.
 */
- (void)removeObserverBlocksForKeyPath:(NSString*)keyPath;

/**
 停止所有块 (associated by `addObserverBlockForKeyPath:block:`) 接收更改通知,并释放这些块.
 */
- (void)removeObserverBlocks;

@end

NS_ASSUME_NONNULL_END
