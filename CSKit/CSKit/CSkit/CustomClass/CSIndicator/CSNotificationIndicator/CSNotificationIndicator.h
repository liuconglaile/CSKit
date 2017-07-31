//
//  CSNotificationIndicator.h
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void (^CSNotificationTapHandler)(void);///点击通知处理程序
typedef void (^CSNotificationCompletion)(void);///通知完成事件

@interface CSNotificationIndicator : NSObject

/**
 *  将指示符样式设置为默认样式
 */
+(void)setNotificationIndicatorStyleToDefaultStyle;

/**
 *  设置指示器样式
 *
 *  @param style UIBlurEffectStyle style
 */
+(void)setNotificationIndicatorStyle:(UIBlurEffectStyle)style;

/**
 *  展示通知指示器
 *
 *  @param title   标题
 *  @param message 消息
 */
+(void)showNotificationWithTitle:(NSString *)title message:(NSString *)message;

/**
 *  展示通知指示器
 *
 *  @param title      标题
 *  @param message    消息
 *  @param tapHandler 点击处理事件
 */
+(void)showNotificationWithTitle:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler;

/**
 展示通知指示器
 
 @param title 标题
 @param message 消息
 @param tapHandler 点击通知处理程序
 @param completion 通知完成事件
 */
+(void)showNotificationWithTitle:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler completion:(CSNotificationCompletion)completion;

/**
 *  展示通知指示器
 *
 *  @param image   指示图
 *  @param title   标题
 *  @param message 消息
 */
+(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message;

/**
 * 展示通知指示器
 *
 *  @param image      指示图
 *  @param title      标题
 *  @param message    消息
 *  @param tapHandler 点击通知处理程序
 */
+(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler;

/**
 展示通知指示器
 
 @param image 指示图
 @param title 标题
 @param message 消息
 @param tapHandler 点击通知处理程序
 @param completion 通知完成事件
 */
+(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler completion:(CSNotificationCompletion)completion;
/**
 *  销毁通知指示器
 */
+(void)dismiss;

@end
