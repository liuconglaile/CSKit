//
//  CALayer+Extended.h
//  CSCategory
//
//  Created by mac on 2017/6/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN


/**
 动画类型
 
 - CSTransitionAnimTypeRippleEffect: 水波
 - CSTransitionAnimTypeSuckEffect: 吸走
 - CSTransitionAnimTypePageCurl: 翻开书本
 - CSTransitionAnimTypeOglFlip: 正反翻转
 - CSTransitionAnimTypeCube: 正方体
 - CSTransitionAnimTypeReveal: push推开
 - CSTransitionAnimTypePageUnCurl: 合上书本
 - CSTransitionAnimTypeRamdom: 随机
 */
typedef NS_ENUM(NSUInteger, CSTransitionAnimType) {
    CSTransitionAnimTypeRippleEffect = 0,
    CSTransitionAnimTypeSuckEffect,
    CSTransitionAnimTypePageCurl,
    CSTransitionAnimTypeOglFlip,
    CSTransitionAnimTypeCube,
    CSTransitionAnimTypeReveal,
    CSTransitionAnimTypePageUnCurl,
    CSTransitionAnimTypeRamdom
};


/**
 动画方向
 
 - CSTransitionSubtypesFromTop: 从上
 - CSTransitionSubtypesFromLeft: 从左
 - CSTransitionSubtypesFromBotoom: 从下
 - CSTransitionSubtypesFromRight: 从右
 - CSTransitionSubtypesFromRamdom: 随机
 */
typedef NS_ENUM(NSUInteger, CSTransitionSubType) {
    CSTransitionSubtypesFromTop = 0,
    CSTransitionSubtypesFromLeft,
    CSTransitionSubtypesFromBotoom,
    CSTransitionSubtypesFromRight,
    CSTransitionSubtypesFromRamdom
};



/**
 动画曲线
 
 - CSTransitionCurveDefault: 默认
 - CSTransitionCurveEaseIn: 缓进
 - CSTransitionCurveEaseOut: 缓出
 - CSTransitionCurveEaseInEaseOut: 缓进缓出
 - CSTransitionCurveLinear: 线性
 - CSTransitionCurveRamdom: 随机
 */
typedef NS_ENUM(NSUInteger, CSTransitionCurve) {
    CSTransitionCurveDefault,
    CSTransitionCurveEaseIn,
    CSTransitionCurveEaseOut,
    CSTransitionCurveEaseInEaseOut,
    CSTransitionCurveLinear,
    CSTransitionCurveRamdom,
};


@interface CALayer (Extended)

/**
 拍摄快照无变换,图像大小等于边界.
 */
- (nullable UIImage *)snapshotImage;

/**
 拍摄快照无变换,PDF页面大小等于边界.
 */
- (nullable NSData *)snapshotPDF;

/**
 设置图层阴影的快捷方式
 
 @param color  阴影颜色
 @param offset 阴影偏移
 @param radius 阴影半径
 */
- (void)setLayerShadow:(UIColor*)color offset:(CGSize)offset radius:(CGFloat)radius;

/**
 删除所有子层.
 */
- (void)removeAllSublayers;

@property (nonatomic) CGFloat left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGPoint center;      ///< Shortcut for center.
@property (nonatomic) CGFloat centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint origin;      ///< Shortcut for frame.origin.
@property (nonatomic, getter=frameSize, setter=setFrameSize:) CGSize  size; ///< Shortcut for frame.size.


@property (nonatomic) CGFloat transformRotation;     ///< key path "tranform.rotation"
@property (nonatomic) CGFloat transformRotationX;    ///< key path "tranform.rotation.x"
@property (nonatomic) CGFloat transformRotationY;    ///< key path "tranform.rotation.y"
@property (nonatomic) CGFloat transformRotationZ;    ///< key path "tranform.rotation.z"
@property (nonatomic) CGFloat transformScale;        ///< key path "tranform.scale"
@property (nonatomic) CGFloat transformScaleX;       ///< key path "tranform.scale.x"
@property (nonatomic) CGFloat transformScaleY;       ///< key path "tranform.scale.y"
@property (nonatomic) CGFloat transformScaleZ;       ///< key path "tranform.scale.z"
@property (nonatomic) CGFloat transformTranslationX; ///< key path "tranform.translation.x"
@property (nonatomic) CGFloat transformTranslationY; ///< key path "tranform.translation.y"
@property (nonatomic) CGFloat transformTranslationZ; ///< key path "tranform.translation.z"


/**
 变换深度,应该在其他变换快捷方式之前设置
 transform.m34, -1/1000 是最佳值
 */
@property (nonatomic) CGFloat transformDepth;

/**
 contentGravity属性的包装器.
 */
@property (nonatomic) UIViewContentMode contentMode;

/**
 当内容更改时，向图层的内容添加淡入淡出的动画.
 
 @param duration 动画持续时间
 @param curve    动画曲线.
 */
- (void)addFadeAnimationWithDuration:(NSTimeInterval)duration curve:(UIViewAnimationCurve)curve;

/**
 取消淡化动画,添加必须使用'-addFadeAnimationWithDuration:curve:'.
 */
- (void)removePreviousFadeAnimation;



/**
 转场动画
 
 @param animType 转场动画类型
 @param subType 转动动画方向
 @param curve 转动动画曲线
 @param duration 转动动画时长
 @return 转场动画实例
 */
- (CATransition *)transitionWithAnimType:(CSTransitionAnimType)animType subType:(CSTransitionSubType)subType curve:(CSTransitionCurve)curve duration:(CGFloat)duration;


@end

NS_ASSUME_NONNULL_END


