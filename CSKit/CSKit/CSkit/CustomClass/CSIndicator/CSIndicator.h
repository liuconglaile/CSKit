//
//  CSIndicator.h
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSToastIndicator.h"
#import "CSProgressIndicator.h"
#import "CSNotificationIndicator.h"

@interface CSIndicator : NSObject

#pragma mark - 背景样式设置
/**
 *  将指示符样式设置为默认样式
 */
+(void)setIndicatorStyleToDefaultStyle;
/**
 *  设置指示符样式
 *
 *  @param style UIBlurEffectStyle style
 */
+(void)setIndicatorStyle:(UIBlurEffectStyle)style;


#pragma mark - CSToastIndicator

/**
 *  展示消息指示器
 *
 *  @param toastMessage 展示消息
 */
+(void)showToastMessage:(NSString *)toastMessage;

/**
 *  销毁消息指示器
 */
+(void)dismissToast;


#pragma mark - CSProgressIndicator

/**
 展示进度消息指示器
 
 @param message 消息内容
 */
+(void)showProgressWithmessage:(NSString *)message;

/**
 展示进度消息指示器
 
 @param message 消息内容
 @param userInteractionEnable  是否开启交互
 */
+(void)showProgressWithmessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable;

/**
 展示info 样式消息指示器
 
 @param message 消息内容
 */
+(void)showInfoWithMessage:(NSString *)message;

/**
 展示info 样式消息指示器
 
 @param message 消息内容
 @param userInteractionEnable  是否开启交互
 */
+(void)showInfoWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable;

/**
 展示Success 样式消息指示器
 
 @param message 消息内容
 */
+(void)showSuccessWithMessage:(NSString *)message;

/**
 展示Success 样式消息指示器
 
 @param message 消息内容
 @param userInteractionEnable  是否开启交互
 */
+(void)showSuccessWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable;


/**
 展示Error 样式消息指示器
 
 @param message 消息内容
 */
+(void)showErrorWithMessage:(NSString *)message;



/**
 展示Error 样式消息指示器
 
 @param message 消息内容
 @param userInteractionEnable  是否开启交互
 */
+(void)showErrorWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable;

/**
 *  销毁进度指示器
 */
+(void)dismissProgress;



#pragma mark - CSNotificationIndicator
/**
 *  展示通知指示器
 *
 *  @param title   标题
 *  @param message 消息内容
 */
+(void)showNotificationWithTitle:(NSString *)title message:(NSString *)message;

/**
 *  展示通知指示器
 *
 *  @param title      标题
 *  @param message    消息内容
 *  @param tapHandler 点击通知处理程序
 */
+(void)showNotificationWithTitle:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler;

/**
 *  展示通知指示器
 *
 *  @param title   标题
 *  @param message 消息内容
 *  @param tapHandler 点击通知处理程序
 */
+(void)showNotificationWithTitle:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler completion:(CSNotificationCompletion)completion;

/**
 *  展示通知指示器
 *
 *  @param image   image
 *  @param title   标题
 *  @param message 消息内容
 */
+(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message;

/**
 *  展示通知指示器
 *
 *  @param image      image
 *  @param title      标题
 *  @param message    消息内容
 *  @param tapHandler 点击通知处理程序
 */
+(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler;

/**
 展示通知指示器
 
 @param image image
 @param title 标题
 @param message 消息内容
 @param tapHandler 点击通知处理程序
 @param completion 通知完成事件
 */
+(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler completion:(CSNotificationCompletion)completion;

/**
 *  销毁通知指示器
 */
+(void)dismissNotification;

@end
