//
//  CSNotificationIndicatorView.h
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Defines

#define kCSNotificationMaxHeight                        (200.f)
#define kCSNotificationTitleHeight                      (24.f)
#define kCSNotificationMargin_X                         (10.f)
#define kCSNotificationMargin_Y                         (10.f)
#define kCSNotificationImageSize                        (30.f)
#define kCSNotificationStatusBarHeight                  ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define kCSNotificationDefaultAnimationDuration         (0.2f)
#define kCSNotificationDefaultTitleFont                 [UIFont boldSystemFontOfSize:15]
#define kCSNotificationDefaultMessageFont               [UIFont systemFontOfSize:13]
#define kCSNotificationDefaultTextColor                 [UIColor blackColor]
#define kCSNotificationDefaultTextColor_ForDarkStyle    [UIColor whiteColor]

#define kCSNotificationScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kCSNotificationScreenHeight   [UIScreen mainScreen].bounds.size.height

@interface CSNotificationIndicatorView : UIVisualEffectView

/**
 *  showWithImage
 *
 *  @param image   image
 *  @param title   title
 *  @param message message
 *  @param style   style
 */
-(void)showWithImage:(UIImage *)image title:(NSString *)title message:(NSString *)message style:(UIBlurEffectStyle)style;
/**
 *  getFrameForNotificationViewWithImage
 *
 *  @param image               image
 *  @param notificationMessage message
 *
 *  @return CGSize
 */
-(CGSize )getFrameForNotificationViewWithImage:(UIImage *)image message:(NSString *)notificationMessage;

@end
