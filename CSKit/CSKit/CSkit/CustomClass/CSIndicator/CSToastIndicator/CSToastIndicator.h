//
//  CSToastIndicator.h
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CSToastIndicator : NSObject

/**
 *  将指示符样式设置为默认样式
 */
+(void)setToastIndicatorStyleToDefaultStyle;
/**
 *  设置指示器样式
 *
 *  @param style UIBlurEffectStyle style
 */
+(void)setToastIndicatorStyle:(UIBlurEffectStyle)style;
/**
 *  展示图示消息体
 *
 *  @param toastMessage NSString toastMessage
 */
+(void)showToastMessage:(NSString *)toastMessage;
/**
 *  销毁吐司
 */
+(void)dismiss;

@end
