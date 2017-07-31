//
//  CSProgressIndicatorView.h
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark - Defines

#define kCSProgressMaxWidth                         (240.f)
#define kCSProgressMargin_X                         (20.f)
#define kCSProgressMargin_Y                         (20.f)
#define kCSProgressImageSize                        (30.f)
#define kCSProgressImageToLabel                     (15.f)
#define kCSProgressCornerRadius                     (10.f)
#define kCSProgressDefaultAnimationDuration         (0.2f)
#define kCSProgressDefaultFont                      [UIFont systemFontOfSize:15]
#define kCSProgressDefaultTextColor                 [UIColor blackColor]
#define kCSProgressDefaultTextColor_ForDarkStyle    [UIColor whiteColor]
#define kCSProgressDefaultBackgroundColor           [UIColor clearColor]

#define kCSProgressScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kCSProgressScreenHeight   [UIScreen mainScreen].bounds.size.height

/**
 进度指示消息类型

 - FTProgressIndicatorMessageTypeInfo: 基本信息类型
 - FTProgressIndicatorMessageTypeSuccess: 成功信息类型
 - FTProgressIndicatorMessageTypeError: 错误信息类型
 - FTProgressIndicatorMessageTypeProgress: 进度加载信息类型
 */
typedef NS_ENUM(NSUInteger, CSProgressIndicatorMessageType) {
    CSProgressIndicatorMessageTypeInfo,
    CSProgressIndicatorMessageTypeSuccess,
    CSProgressIndicatorMessageTypeError,
    CSProgressIndicatorMessageTypeProgress
};

@interface CSProgressIndicatorView : UIVisualEffectView

/**
 *  userInteractionEnable, 是否开启用户交互
 */
@property (assign, nonatomic) BOOL userInteractionEnable;
/**
 *  展示加载信息吐司
 *
 *  @param type                   type
 *  @param message                消息体
 *  @param style                  style
 *  @param userInteractionEnable  是否开启交互
 */
- (void)showProgressWithType:(CSProgressIndicatorMessageType)type
                     message:(NSString *)message
                       style:(UIBlurEffectStyle)style
       userInteractionEnable:(BOOL)userInteractionEnable;
/**
 *  根据加载消息体获取 frame
 *
 *  @param progressMessage  加载消息体
 *
 *  @return CGSize
 */
- (CGSize )getFrameForProgressViewWithMessage:(NSString *)progressMessage;

@end
