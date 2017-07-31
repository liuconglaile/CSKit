//
//  UIControl+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (Extended)

/**
 从内部调度表删除特定事件的所有目标和行动(或事件)
 */
- (void)removeAllTargets;

/**
 从内部调度表添加或替换为特定事件的目标和动作(或事件).
 
 @param target         目标对象-即发送动作消息的对象.如果这是nil,则响应者链将搜索愿意响应该动作消息的对象.
 @param action         识别动作消息的选择器.它不能为NULL.
 @param controlEvents  指定发送操作消息的控制事件的位掩码(指令枚举).
 */
- (void)setTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

/**
 将特定动作(或事件)的块添加到内部分派表.这将引起强引用代码块.
 
 @param block          被调用的块然后是动作消息被发送(不能为nil).代码块会被retained.
 @param controlEvents  指定发送操作消息的控制事件的位掩码(指令枚举).
 */
- (void)addBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(id sender))block;

/**
 将特定动作(或事件)的块添加到内部分派表.这将引起强引用代码块.
 
 @param block          被调用的块然后是动作消息被发送(不能为nil).代码块会被retained.
 @param controlEvents  指定发送操作消息的控制事件的位掩码(指令枚举).
 */
- (void)setBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(id sender))block;

/**
 从内部调度表中删除特定动作(或事件)的所有块.
 
 @param controlEvents  指定发送操作消息的控制事件的位掩码(指令枚举).
 */
- (void)removeAllBlocksForControlEvents:(UIControlEvents)controlEvents;

/**
 给点击事件添加声音
 
 @param name 声音路径
 @param controlEvent 点击事件
 */
- (void)setSoundNamed:(NSString *)name forControlEvent:(UIControlEvents)controlEvent;

@end

NS_ASSUME_NONNULL_END


