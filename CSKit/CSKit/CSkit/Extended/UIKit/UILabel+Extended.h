//
//  UILabel+Extended.h
//  CSCategory
//
//  Created by mac on 2017/7/5.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSUInteger, UILabelLinkingMode) {
    UILabelLinkingModeNone,
    UILabelLinkingModeUntilFinish,
    UILabelLinkingModeUntilFinishKeeping,
    UILabelLinkingModeWhenFinish,
    UILabelLinkingModeWhenFinishShowing,
    UILabelLinkingModeAlways
};

//UILabel-AutomaticWriting的项目版本号.
FOUNDATION_EXPORT double UILabelAutomaticWritingVersionNumber;
//UILabel-AutomaticWriting的项目版本字符串.
FOUNDATION_EXPORT const unsigned char UILabelAutomaticWritingVersionString[];
extern NSTimeInterval const UILabelAWDefaultDuration;
extern unichar const UILabelAWDefaultCharacter;

@interface UILabel (Extended)

///MARK: =========================================
///MARK: 标签字体自动适配 & 拉进项目就可以了,不需要任何操作
///MARK: =========================================






///MARK: =========================================
///MARK: 动画相关
///MARK: =========================================
@property (strong, nonatomic) NSOperationQueue *automaticWritingOperationQueue;
@property (assign, nonatomic) UIEdgeInsets edgeInsets;
// 设置文本使用自动写入动画
- (void)setTextWithAutomaticWritingAnimation:(NSString *)text;
// 设置文本 根据选择的动画模式
- (void)setText:(NSString *)text automaticWritingAnimationWithBlinkingMode:(UILabelLinkingMode)blinkingMode;
// 设置文本 根据动画持续时长
- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration;
// 设置文本 根据动画模式&动画时长
- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration blinkingMode:(UILabelLinkingMode)blinkingMode;
// 设置文本 根据动画模式&动画时长&闪烁的字符
- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration blinkingMode:(UILabelLinkingMode)blinkingMode blinkingCharacter:(unichar)blinkingCharacter;
// 设置文本 根据动画模式&动画时长&闪烁的字符   带有完成回调
- (void)setText:(NSString *)text automaticWritingAnimationWithDuration:(NSTimeInterval)duration blinkingMode:(UILabelLinkingMode)blinkingMode blinkingCharacter:(unichar)blinkingCharacter completion:(void (^)(void))completion;
///MARK: =========================================
///MARK: 动画相关
///MARK: =========================================



///MARK: =========================================
///MARK: 渲染相关
///MARK: =========================================



/**
 自适应标签 Size
 如果大小设置为CGSizeZero 它将被忽略
 
 @param maxSize  最大 Size
 @param minSize  最小 Size
 @param minFontSize  最小字体大小
 */
- (void)adjustLabelToMaximumSize:(CGSize)maxSize
                     minimumSize:(CGSize)minSize
                 minimumFontSize:(int)minFontSize;
/**
 自适应标签 Size

 @param maxSize 最大 Size
 @param minFontSize 最小字体大小
 */
- (void)adjustLabelToMaximumSize:(CGSize)maxSize
                 minimumFontSize:(int)minFontSize;
/**
 自适应标签 Size

 @param minFontSize 最小字体大小
 */
- (void)adjustLabelSizeWithMinimumFontSize:(int)minFontSize;

/**
 自适应标签 Size (最大大小会自动根据屏幕尺寸来计算)
 */
- (void)adjustLabel;

/**
 垂直方向固定获取动态宽度的UILabel的方法

 @return 原始UILabel修改过的Rect的UILabel(起始位置相同)
 */
- (UILabel *)resizeLabelHorizontal;

/**
 水平方向固定获取动态宽度的UILabel的方法

 @return 原始UILabel修改过的Rect的UILabel(起始位置相同)
 */
- (UILabel *)resizeLabelVertical;

/**
 垂直方向固定获取动态宽度的UILabel的方法

 @param minimumWidth 最小宽度
 @return 原始UILabel修改过的Rect的UILabel(起始位置相同)
 */
- (UILabel *)resizeLabelHorizontal:(CGFloat)minimumWidth;

/**
 水平方向固定获取动态宽度的UILabel的方法

 @param minimumHeigh 最小高度
 @return 原始UILabel修改过的Rect的UILabel(起始位置相同)
 */
- (UILabel *)resizeLabelVertical:(CGFloat)minimumHeigh;


// 获得标签建议 size
- (CGSize)suggestedSizeForWidth:(CGFloat)width;
// 获得富文本建议 size
- (CGSize)suggestSizeForAttributedString:(NSAttributedString *)string width:(CGFloat)width;
// 根据字符串获得建议 size
- (CGSize)suggestSizeForString:(NSString *)string width:(CGFloat)width;

///MARK: =========================================
///MARK: 渲染相关
///MARK: =========================================




@end
