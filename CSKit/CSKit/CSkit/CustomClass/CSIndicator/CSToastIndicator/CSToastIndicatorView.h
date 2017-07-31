//
//  CSToastIndicatorView.h
//  CSCategory
//
//  Created by mac on 17/4/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - 默认配置

#define kCSToastMaxWidth                        (kCSToastScreenWidth*0.7)
#define kCSToastMaxHeight                       (100.f)
#define kCSToastMargin_X                        (20.f)
#define kCSToastMargin_Y                        (10.f)
#define kCSToastToBottom                        (20.f)
#define kCSToastCornerRadius                    (8.f)
#define kCSToastDefaultAnimationDuration        (0.2f)
#define kCSToastDefaultFont                     [UIFont systemFontOfSize:15]
#define kCSToastDefaultTextColor                [UIColor blackColor]
#define kCSToastDefaultTextColor_ForDarkStyle   [UIColor whiteColor]

#define kCSToastScreenWidth    [UIScreen mainScreen].bounds.size.width
#define kCSToastScreenHeight   [UIScreen mainScreen].bounds.size.height

@interface CSToastIndicatorView : UIVisualEffectView

/**
 *  显示吐司消息
 *
 *  @param toastMessage 消息体
 *  @param style        style
 */
- (void)showToastMessage:(NSString *)toastMessage withStyle:(UIBlurEffectStyle)style;
/**
 *  根据图示视图与消息体获取 frame
 *
 *  @param toastMessage  消息体
 *
 *  @return CGSize
 */
- (CGSize )getFrameForToastViewWithMessage:(NSString *)toastMessage;

@end
