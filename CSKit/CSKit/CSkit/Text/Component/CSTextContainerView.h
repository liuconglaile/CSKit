//
//  CSTextContainerView.h
//  CSCategory
//
//  Created by mac on 2017/7/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<CSKit/CSKit.h>)
#import <CSKit/CSTextLayout.h>
#else
#import "CSTextLayout.h"
#endif
NS_ASSUME_NONNULL_BEGIN



/**
 一个简单的视图diaplay CSTextLayout
 
 这个视图可以成为第一个响应者.
 如果这个视图是第一个响应者,所有的操作(如UIMenu的操作)将转发到'hostView'属性.
 通常,你不应该直接使用这个类
 
 这个类中的所有方法都应该在主线程上调用
 */
@interface CSTextContainerView : UIView

/// 第一反应者的行动将转向这个视图.
@property (nullable, nonatomic, weak) UIView *hostView;

/// 调试选项用于布局调试.设置此属性将让视图重绘它的内容.
@property (nullable, nonatomic, copy) CSTextDebugOption *debugOption;

/// 文字垂直对齐.
@property (nonatomic) CSTextVerticalAlignment textVerticalAlignment;

/// 文本布局.设置此属性将让视图重绘它的内容.
@property (nullable, nonatomic, strong) CSTextLayout *layout;

/// 当布局的内容改变时,内容会淡化动画持续时间.默认值为0(无动画).
@property (nonatomic) NSTimeInterval contentsFadeDuration;

/**
 设置'layout'和'contentsFadeDuration'的便利方法

 @param layout 布局对象
 @param fadeDuration 动画时间
 */
- (void)setLayout:(nullable CSTextLayout *)layout withFadeDuration:(NSTimeInterval)fadeDuration;

@end
NS_ASSUME_NONNULL_END



