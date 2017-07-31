//
//  CSProgressIndicator.h
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CSProgressIndicator : NSObject

/**
 *  展示进度指示器
 *
 *  @param message 消息体
 */
+(void)showProgressWithmessage:(NSString *)message;

/**
 *  展示进度指示器
 *
 *  @param message               消息体
 *  @param userInteractionEnable 是否打开交互
 */
+(void)showProgressWithmessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable;

/**
 *  展示info 类型进度指示器
 *
 *  @param message NSString message
 */
+(void)showInfoWithMessage:(NSString *)message;

/**
 *  展示Success 类型进度指示器
 *
 *  @param message               message
 *  @param userInteractionEnable 是否打开交互
 */
+(void)showInfoWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable;

/**
 *  展示Success 类型进度指示器
 *
 *  @param message NSString message
 */
+(void)showSuccessWithMessage:(NSString *)message;

/**
 *  展示info 类型进度指示器
 *
 *  @param message               message
 *  @param userInteractionEnable 是否打开交互
 */
+(void)showSuccessWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable;

/**
 *  展示Error 类型进度指示器
 *
 *  @param message NSString message
 */
+(void)showErrorWithMessage:(NSString *)message;

/**
 *  展示Error 类型进度指示器
 *
 *  @param message               message
 *  @param userInteractionEnable 是否打开交互
 */
+(void)showErrorWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable;

/**
 *  销毁吐司
 */
+(void)dismiss;

/**
 *  设置为默认样式
 */
+(void)setProgressIndicatorStyleToDefaultStyle;

/**
 *  设置进度指示器样式
 *
 *  @param style UIBlurEffectStyle style
 */
+(void)setProgressIndicatorStyle:(UIBlurEffectStyle)style;

@end
