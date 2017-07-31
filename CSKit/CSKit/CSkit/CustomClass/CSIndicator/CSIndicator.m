//
//  CSIndicator.m
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "CSIndicator.h"

@implementation CSIndicator

+(void)setIndicatorStyleToDefaultStyle
{
    [self setIndicatorStyle:UIBlurEffectStyleLight];
}

+(void)setIndicatorStyle:(UIBlurEffectStyle)style
{
    [CSToastIndicator setToastIndicatorStyle:style];
    [CSProgressIndicator setProgressIndicatorStyle:style];
    [CSNotificationIndicator setNotificationIndicatorStyle:style];
}



///MARK: CSToastIndicator
+(void)showToastMessage:(NSString *)toastMessage
{
    [CSToastIndicator showToastMessage:toastMessage];
}

+(void)dismissToast
{
    [CSToastIndicator dismiss];
}


///MARK: CSProgressIndicator
+(void)showProgressWithmessage:(NSString *)message
{
    [CSProgressIndicator showProgressWithmessage:message userInteractionEnable:YES];
}
+(void)showProgressWithmessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable
{
    [CSProgressIndicator showProgressWithmessage:message userInteractionEnable:userInteractionEnable];
}
+(void)showInfoWithMessage:(NSString *)message
{
    [CSProgressIndicator showInfoWithMessage:message userInteractionEnable:YES];
}
+(void)showInfoWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable
{
    [CSProgressIndicator showInfoWithMessage:message userInteractionEnable:userInteractionEnable];
}
+(void)showSuccessWithMessage:(NSString *)message
{
    [CSProgressIndicator showSuccessWithMessage:message userInteractionEnable:YES];
}
+(void)showSuccessWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable
{
    [CSProgressIndicator showSuccessWithMessage:message userInteractionEnable:userInteractionEnable];
}
+(void)showErrorWithMessage:(NSString *)message
{
    [CSProgressIndicator showErrorWithMessage:message userInteractionEnable:YES];
}
+(void)showErrorWithMessage:(NSString *)message userInteractionEnable:(BOOL)userInteractionEnable
{
    [CSProgressIndicator showErrorWithMessage:message userInteractionEnable:userInteractionEnable];
}
+(void)dismissProgress
{
    [CSProgressIndicator dismiss];
}


///MARK: CSNotificationIndicator
+(void)showNotificationWithTitle:(NSString *)title message:(NSString *)message
{
    [CSNotificationIndicator showNotificationWithTitle:title message:message];
}

+(void)showNotificationWithTitle:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler
{
    [CSNotificationIndicator showNotificationWithTitle:title message:message tapHandler:tapHandler];
}

+(void)showNotificationWithTitle:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler completion:(CSNotificationCompletion)completion
{
    [CSNotificationIndicator showNotificationWithTitle:title message:message tapHandler:tapHandler completion:completion];
}

+(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message
{
    [CSNotificationIndicator showNotificationWithImage:image title:title message:message];
}

+(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler
{
    [CSNotificationIndicator showNotificationWithImage:image title:title message:message tapHandler:tapHandler];
}

+(void)showNotificationWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message tapHandler:(CSNotificationTapHandler)tapHandler completion:(CSNotificationCompletion)completion
{
    [CSNotificationIndicator showNotificationWithImage:image title:title message:message tapHandler:tapHandler completion:completion];
}

+(void)dismissNotification
{
    [CSNotificationIndicator dismiss];
}

@end
