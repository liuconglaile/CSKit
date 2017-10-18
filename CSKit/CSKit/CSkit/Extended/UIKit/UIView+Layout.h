//
//  UIView+Layout.h
//  CSCategory
//
//  Created by mac on 2017/7/6.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSConstraint,CSConstraintMaker;

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Layout)

///MARK: ===================================================
///MARK: Frame相关
///MARK: ===================================================

/** 将点从接收器的坐标系转换为指定的视图或窗口 */
- (CGPoint)convertPoint:(CGPoint)point toViewOrWindow:(nullable UIView *)view;
/** 将点从给定视图或window的坐标系转换为接收器 */
- (CGPoint)convertPoint:(CGPoint)point fromViewOrWindow:(nullable UIView *)view;
/** 将矩形从接收器的坐标系转换为另一个视图或window */
- (CGRect)convertRect:(CGRect)rect toViewOrWindow:(nullable UIView *)view;
/** 将矩形从另一个视图或window的坐标系转换为接收器的坐标系 */
- (CGRect)convertRect:(CGRect)rect fromViewOrWindow:(nullable UIView *)view;


/** 快捷方式 */
@property (nonatomic) CGFloat left;        ///< frame.origin.x
@property (nonatomic) CGFloat top;         ///< frame.origin.y
@property (nonatomic) CGFloat right;       ///< frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      ///< frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       ///< frame.size.width
@property (nonatomic) CGFloat height;      ///< frame.size.height
@property (nonatomic) CGFloat centerX;     ///< center.x
@property (nonatomic) CGFloat centerY;     ///< center.y
@property (nonatomic) CGPoint origin;      ///< frame.origin
@property (nonatomic) CGSize  size;        ///< frame.size

///MARK: ===================================================
///MARK: Frame相关
///MARK: ===================================================



/////MARK: ===================================================
/////MARK: 约束相关
/////MARK: ===================================================
//
//// 约束的属性
//- (NSLayoutConstraint *)constraintForAttribute:(NSLayoutAttribute)attribute;
//// 左约束
//- (NSLayoutConstraint *)leftConstraint;
//- (NSLayoutConstraint *)rightConstraint;
//- (NSLayoutConstraint *)topConstraint;
//- (NSLayoutConstraint *)bottomConstraint;
//// 主导约束
//- (NSLayoutConstraint *)leadingConstraint;
//// 尾端约束
//- (NSLayoutConstraint *)trailingConstraint;
//
//- (NSLayoutConstraint *)widthConstraint;
//- (NSLayoutConstraint *)heightConstraint;
//- (NSLayoutConstraint *)centerXConstraint;
//- (NSLayoutConstraint *)centerYConstraint;
//
//- (NSLayoutConstraint *)baseLineConstraint;
//
//
//
///**
// 添加约束
//
// @param aBlock 返回约束抽象类
// @return 包含所有约束的数组
// */
//- (NSArray *)makeConstraints:(void(^)(CSConstraintMaker *make))aBlock;
//
/////MARK: ===================================================
/////MARK: 约束相关
/////MARK: ===================================================


@end




//@interface CSConstraintMaker : NSObject
//
//@property (nonatomic, strong, readonly) CSConstraint *left;
//@property (nonatomic, strong, readonly) CSConstraint *top;
//@property (nonatomic, strong, readonly) CSConstraint *right;
//@property (nonatomic, strong, readonly) CSConstraint *bottom;
//@property (nonatomic, strong, readonly) CSConstraint *edges;
//@property (nonatomic, strong, readonly) CSConstraint *width;
//@property (nonatomic, strong, readonly) CSConstraint *height;
//@property (nonatomic, strong, readonly) CSConstraint *size;
//@property (nonatomic, strong, readonly) CSConstraint *centerX;
//@property (nonatomic, strong, readonly) CSConstraint *centerY;
//@property (nonatomic, strong, readonly) CSConstraint *center;
//
//- (id)initWithView:(UIView *)aView;
//- (NSArray *)install; // @return    包含所有添加的CSConstraint的数组
//
//@end
//
//@interface CSConstraint : NSObject
//
//@property (nonatomic, strong) NSMutableArray *layoutAttributes;
//@property (nonatomic, weak) UIView *firstItem;
//
//- (instancetype)initWithView:(UIView *)aView;
//- (void)install;
//
//- (CSConstraint *)equalToView:(UIView *)aView;
//- (CSConstraint *)equalTo:(CGFloat)c;
//
//@end

NS_ASSUME_NONNULL_END
