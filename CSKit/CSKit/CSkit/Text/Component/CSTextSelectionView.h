//
//  CSTextSelectionView.h
//  CSCategory
//
//  Created by mac on 2017/7/25.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#if __has_include(<CSKit/CSKit.h>)
#import <CSKit/CSTextAttribute.h>
#import <CSKit/CSTextInput.h>
#else
#import "CSTextAttribute.h"
#import "CSTextInput.h"
#endif

NS_ASSUME_NONNULL_BEGIN








/**
 单点视图.frame应为四方形.
 更改背景颜色以进行显示。
  
 @discussion 通常,你不应该直接使用这个类.
 */
@interface CSSelectionGrabberDot : UIView
///不要访问此属性.它由'CSTextEffectWindow'使用.
@property (nonatomic, strong) UIView *mirror;
@end


/**
 抓取器 (贴一个点).
 
 @discussion 通常,你不应该直接使用这个类.
 */
@interface CSSelectionGrabber : UIView

@property (nonatomic, readonly) CSSelectionGrabberDot *dot; ///< 点视图
@property (nonatomic) CSTextDirection dotDirection;         ///< 不支持复合方向
@property (nullable, nonatomic, strong) UIColor *color;     ///< 色调颜色,默认为nil

@end








/**
 文本编辑和选择的选择视图.
 
 @discussion 通常,你不应该直接使用这个类.
 */
@interface CSTextSelectionView : UIView

@property (nullable, nonatomic, weak) UIView *hostView; ///< 持有者视图
@property (nullable, nonatomic, strong) UIColor *color; ///< 色调颜色
@property (nonatomic, getter = isCaretBlinks) BOOL caretBlinks; ///< 插入符是否闪烁
@property (nonatomic, getter = isCaretVisible) BOOL caretVisible; ///< 插入符是否可见
@property (nonatomic, getter = isVerticalForm) BOOL verticalForm; ///< 插入符是否垂直形式

@property (nonatomic) CGRect caretRect; ///< caret rect (width==0 or height==0)
@property (nullable, nonatomic, copy) NSArray<CSTextSelectionRect *> *selectionRects; ///< default is nil

@property (nonatomic, readonly) UIView *caretView;
@property (nonatomic, readonly) CSSelectionGrabber *startGrabber;
@property (nonatomic, readonly) CSSelectionGrabber *endGrabber;

- (BOOL)isGrabberContainsPoint:(CGPoint)point;
- (BOOL)isStartGrabberContainsPoint:(CGPoint)point;
- (BOOL)isEndGrabberContainsPoint:(CGPoint)point;
- (BOOL)isCaretContainsPoint:(CGPoint)point;
- (BOOL)isSelectionRectsContainsPoint:(CGPoint)point;

@end
NS_ASSUME_NONNULL_END



