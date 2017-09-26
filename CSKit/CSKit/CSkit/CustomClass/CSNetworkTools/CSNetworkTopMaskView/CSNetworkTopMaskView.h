//
//  CSNetworkTopMaskView.h
//  CSKit
//
//  Created by mac on 2017/8/1.
//  Copyright © 2017年 Moming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSProgressHUD.h"


//当前提示view在父视图上的tag
#define kRequestTipViewTag      2017



@interface CSProgressHUD (Extension)

/**
 在指定view上显示转圈的CSProgressHUD(不会自动消失,需要手动调用隐藏方法,非模态)
 */
+ (void)showLoadingWithView:(UIView *)view text:(NSString *)tipStr;

/**
 在指定view上显示转圈的CSProgressHUD(不会自动消失,需要手动调用隐藏方法,非模态)
 */
+ (void)showToastViewOnView:(UIView *)addView text:(NSString *)message;

/**
 隐藏指定view上创建的CSProgressHUD
 */
+ (void)hideLoadingFromView:(UIView *)view;


@end


/**
 自定义情景遮罩控件
 */
@interface CSNetworkTopMaskView : UIView


/**
 返回一个提示空白view

 @param frame       提示View大小
 @param imageName   图片名字
 @param tipText     提示文字
 @param actionTitle 按钮标题,不要按钮可不传
 @param touchBlock  点击按钮回调Block
 @return            提示控件
 */
+ (CSNetworkTopMaskView *)tipViewByFrame:(CGRect)frame
                            tipImageName:(NSString *)imageName
                                 tipText:(id)tipText
                             actionTitle:(NSString *)actionTitle
                             actionBlock:(void(^)(void))touchBlock;

@end







