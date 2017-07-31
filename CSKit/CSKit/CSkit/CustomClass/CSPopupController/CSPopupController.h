//
//  CSPopupController.h
//  CSCategory
//
//  Created by mac on 2017/6/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

/**
 背景蒙版视图样式

 - CSPopupMaskTypeBlackBlur: 黑色高斯模糊效果
 - CSPopupMaskTypeWhiteBlur: 白色高斯模糊效果
 - CSPopupMaskTypeWhite: 纯白色效果
 - CSPopupMaskTypeClear: 全透明效果
 - CSPopupMaskTypeDefault: 黑色半透明效果(默认)
 */
typedef NS_ENUM(NSUInteger, CSPopupMaskType) {
    CSPopupMaskTypeBlackBlur,
    CSPopupMaskTypeWhiteBlur,
    CSPopupMaskTypeWhite,
    CSPopupMaskTypeClear,
    CSPopupMaskTypeDefault
};


/**
 弹出视图约束样式

 - CSPopupLayoutTypeTop: 顶部
 - CSPopupLayoutTypeBottom: 底部
 - CSPopupLayoutTypeLeft: 左边
 - CSPopupLayoutTypeRight: 右边
 - CSPopupLayoutTypeCenter: 居中(默认)
 */
typedef NS_ENUM(NSUInteger, CSPopupLayoutType) {
    CSPopupLayoutTypeTop,
    CSPopupLayoutTypeBottom,
    CSPopupLayoutTypeLeft,
    CSPopupLayoutTypeRight,
    CSPopupLayoutTypeCenter
};


/**
 弹出呈现样式

 - CSPopupTransitStyleFromTop: 从上往下
 - CSPopupTransitStyleFromBottom: 从下往上
 - CSPopupTransitStyleFromLeft: 从左往右
 - CSPopupTransitStyleFromRight: 从右往左
 - CSPopupTransitStyleSlightScale: 弹簧效果
 - CSPopupTransitStyleShrinkInOut: 居中扩散
 - CSPopupTransitStyleDefault: 淡入淡出(默认)
 */
typedef NS_ENUM(NSUInteger, CSPopupTransitStyle) {
    CSPopupTransitStyleFromTop,
    CSPopupTransitStyleFromBottom,
    CSPopupTransitStyleFromLeft,
    CSPopupTransitStyleFromRight,
    CSPopupTransitStyleSlightScale,
    CSPopupTransitStyleShrinkInOut,
    CSPopupTransitStyleDefault
};


@protocol CSPopupDelegate;


@interface CSPopupController : NSObject

@property (nonatomic, weak) id<CSPopupDelegate>  _Nullable delegate;

/** 蒙版样式 */
@property (nonatomic, assign) CSPopupMaskType  maskType;
/** 视图显示位置，default = CSPopupLayoutTypeCenter */
@property (nonatomic, assign) CSPopupLayoutType layoutType;
/** 视图呈现方式，default = CSPopupTransitStyleDefault */
@property (nonatomic, assign) CSPopupTransitStyle transitStyle;
/** 设置蒙版视图的透明度，default = 0.5 */ // 必须设置 maskType 为半透明效果
@property (nonatomic, assign) CGFloat maskAlpha;
/** 是否反方向消失，default = NO */ // 必须设置 layoutType 居中
@property (nonatomic, assign) BOOL dismissOppositeDirection;
/** 点击蒙版视图是否响应dismiss事件,default = YES */
@property (nonatomic, assign) BOOL dismissOnMaskTouched;
/** 是否允许视图拖动，default = NO */
@property (nonatomic, assign) BOOL allowPan;
/** 视图倾斜掉落动画，当transitStyle为CSPopupTransitStyleFromTop样式时可以设置为YES使用掉落动画，default = NO */
@property (nonatomic, assign) BOOL dropTransitionAnimated;
/** 视图是否正在显示中 */
@property (nonatomic, assign, readonly) BOOL isPresenting;
/** 蒙版触摸事件block,主要用来自定义dismiss动画时间及弹性效果 */
@property (nonatomic, copy) void (^maskTouched)(CSPopupController *popupController);
/** 视图将要呈现,应该在present前实现的block */
@property (nonatomic, copy) void (^willPresent)(CSPopupController *popupController);
/** 视图已经呈现 */
@property (nonatomic, copy) void (^didPresent)(CSPopupController *popupController);
/** 视图将要消失 */
@property (nonatomic, copy) void (^willDismiss)(CSPopupController *popupController);
/** 视图已经消失 */
@property (nonatomic, copy) void (^didDismiss)(CSPopupController *popupController);



/**
 构造函数

 @param contentView 需要弹出的视图
 @param duration 动画时间
 @param isElasticAnimated 是否使用弹性动画
 @param sView 父视图
 */
- (void)presentContentView:(nullable UIView *)contentView
                  duration:(NSTimeInterval)duration
           elasticAnimated:(BOOL)isElasticAnimated
                    inView:(nullable UIView *)sView;

//

/**
 构造函数,默认在Window显示

 @param contentView 要弹出的视图
 @param duration 动画时间
 @param isElasticAnimated 是否使用弹性动画
 */
- (void)presentContentView:(nullable UIView *)contentView duration:(NSTimeInterval)duration elasticAnimated:(BOOL)isElasticAnimated;

/**
 构造函数
 
 默认动画时间 0.5
 默认关闭弹性效果
 默认在 window 上显示

 @param contentView 要显示的
 */
- (void)presentContentView:(nullable UIView *)contentView;


/**
 消除所显示的视图

 @param duration 动画时间
 @param isElasticAnimated 是否使用弹性动画
 */
- (void)dismissWithDuration:(NSTimeInterval)duration elasticAnimated:(BOOL)isElasticAnimated;

/**
 parameters等于present时对应设置的values
 */
- (void)dismiss;

/**
  便利构造popupController并设置相应属性值

 @param layoutType 位置约束
 @param maskType 蒙版枚举
 @param dismissOnMaskTouched 蒙版点击响应消失
 @param allowPan 是否运行拖动
 @return 展示视图
 */
+ (instancetype)popupControllerWithLayoutType:(CSPopupLayoutType)layoutType
                                     maskType:(CSPopupMaskType)maskType
                         dismissOnMaskTouched:(BOOL)dismissOnMaskTouched
                                     allowPan:(BOOL)allowPan;


/**
 便利构造函数
 默认显示中间位置
 @param transitStyle 样式枚举
 @param maskType 蒙版枚举
 @param dismissOnMaskTouched 蒙版响应
 @param dismissOppositeDirection 是否反方向消失
 @param allowPan 是否运行拖拽
 @return 展示视图
 */
+ (instancetype)popupControllerLayoutInCenterWithTransitStyle:(CSPopupTransitStyle)transitStyle
                                                     maskType:(CSPopupMaskType)maskType
                                         dismissOnMaskTouched:(BOOL)dismissOnMaskTouched
                                     dismissOppositeDirection:(BOOL)dismissOppositeDirection
                                                     allowPan:(BOOL)allowPan;


@end



@protocol CSPopupDelegate <NSObject>

@optional
///MARK: Block对应的Delegate方法,block优先
- (void)popupControllerWillPresent:(nonnull CSPopupController *)popupController;
- (void)popupControllerDidPresent:(nonnull CSPopupController *)popupController;
- (void)popupControllerWillDismiss:(nonnull CSPopupController *)popupController;
- (void)popupControllerDidDismiss:(nonnull CSPopupController *)popupController;

@end

@interface NSObject (CSPopupController)

/**
 因为CSPopupController内部子视图是默认添加在rootWindow上的,所以如果popupController是局部变量的话不会被引用,生命周期也只在这个方法内。
 为了使内部视图正常响应,所以应将popupController声明为全局属性,保证其生命周期,也可以直接使用改属性
 */
@property (nonatomic, strong) CSPopupController * showPopupController;

@end


NS_ASSUME_NONNULL_END




