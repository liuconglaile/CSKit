//
//  CSTextEffectWindow.h
//  CSCategory
//
//  Created by mac on 2017/7/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<CSKit/CSKit.h>)
#import <CSKit/CSTextMagnifier.h>
#import <CSKit/CSTextSelectionView.h>
#else
#import "CSTextMagnifier.h"
#import "CSTextSelectionView.h"
#endif
NS_ASSUME_NONNULL_BEGIN



/**
 用于显示放大镜的窗口和文本视图的额外内容
 
 使用'sharedWindow'获取实例,不要创建自己的实例.
 通常,你不应该直接使用这个类
 */
@interface CSTextEffectWindow : UIWindow

/// 返回共享实例(在App Extension中返回nil).
+ (nullable instancetype)sharedWindow;

/// 使用'弹出'动画在此窗口中显示放大镜.@param mag 放大镜.
- (void)showMagnifier:(CSTextMagnifier *)mag;
/// 更新放大镜的内容和位置.
- (void)moveMagnifier:(CSTextMagnifier *)mag;
/// 用'收缩'动画从此窗口中移除放大镜.
- (void)hideMagnifier:(CSTextMagnifier *)mag;


/// 如果点被选择查看器剪切,则在此窗口中显示选择点.
/// @param selection 选择视图.
- (void)showSelectionDot:(CSTextSelectionView *)selection;
/// 从此窗口中删除选择点.
- (void)hideSelectionDot:(CSTextSelectionView *)selection;

@end
NS_ASSUME_NONNULL_END


