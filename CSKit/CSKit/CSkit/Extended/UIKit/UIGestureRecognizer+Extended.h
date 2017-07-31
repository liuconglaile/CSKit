//
//  UIGestureRecognizer+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIGestureRecognizer (Extended)

/**
 使用动作块初始化分配的手势识别器对象.

 @param block 用于处理由接收器识别的手势的动作块.nil是无效的.它被手势保留.
 @return 一个具体的UIGestureRecognizer子类的初始化实例,如果在尝试初始化对象时发生错误,则为nil
 */
- (instancetype)initWithActionBlock:(void (^)(id sender))block;

/**
 将动作块添加到手势识别器对象.它被手势保留.
 
 @param block 由动作消息调用的块.nil不是有效值.
 */
- (void)addActionBlock:(void (^)(id sender))block;

/**
 删除所有操作块.
 */
- (void)removeAllActionBlocks;

@end

NS_ASSUME_NONNULL_END
